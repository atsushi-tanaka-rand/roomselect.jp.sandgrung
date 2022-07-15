/**
 * LINEユーザ一覧
 */
public with sharing class GL101002Controller {

	/** 画面項目 */
	public ScreenLineUserList screenLineUser {get; set;} // LINEユーザ一覧

	/* フラグ */
	public Boolean isOpenError	 { get; set; } // 初期表示エラーフラグ
	public Boolean hasErrorMessage { get; set; } // エラーメッセージ保有フラグ

	/**
	 * コンストラクタ
	 */
	public GL101002Controller() {

		try {
			// エラーフラグの初期化
			this.isOpenError	 = false;
			this.hasErrorMessage = false;

			 // 店舗情報取得
			 // 店舗情報が取得できない場合は例外をスロー
			 Shop__c shop = CommonUtil.getStaffCurrentShop();

			 // 画面項目の初期化
			 this.screenLineUser = new ScreenLineUserList(shop.id);

			 // 検索結果の設定
			 this.setSearchResult();

		} catch(Exception ex) {

			 // 初期表示エラーフラグの更新
			 this.isOpenError = true;

			 // エラーメッセージの設定・表示
			 CommonUtil.setErrorMessage(ex);
		}
	}

	/**
	 * LINEユーザの検索
	 */
	public void searchLineUser() {

		try {
			this.hasErrorMessage = false;

			// 検索結果の設定
			this.setSearchResult();

		 } catch(Exception ex) {

			// エラーメッセージの設定・表示
			this.hasErrorMessage = true;
			CommonUtil.setErrorMessage(ex);
		}
	}

	/**
	 * 検索結果の設定
	 */
	public void setSearchResult() {

		// 検索条件の取得
		String condAccountName	= this.screenLineUser.condUserName;				// お客様名
		String condPhone		= this.screenLineUser.condPhone;				// 電話番号
		String condLineId		= this.screenLineUser.condLineId;				// LINE ID
		String condStatus		= this.screenLineUser.selectCondStatus;			// ステータス
		String condShop			= this.screenLineUser.selectCondCorrespondShop; // 対応店舗
		String condLastReplyer	= this.screenLineUser.selectCondLastReplyer;	// 最終返信者

		// LINE会員の取得
		List<LineMember__c> lineMemberList = this.selectLineMember(condAccountName
																	, condPhone
																	, condLineId
																	, condStatus
																	, condLastReplyer);

		// LINE会員のIDを取得
		Set<Id> lineMemberIdSet = new Set<Id>();
		for (LineMember__c lineMember : lineMemberList) {
			lineMemberIdSet.add(lineMember.Id);
		}

		// 対応の取得（key:LINE会員.ID、value:対応）
		Map<Id, Correspond__c> lineMembercorrespondMap = this.selectCorrespond(lineMemberIdSet);

		// 検索結果の設定
		this.screenLineUser.setSearchResultList(lineMemberList, lineMembercorrespondMap, condShop);

		// 明細件数が0件の場合はエラーメッセージの表示・設定
		if (this.screenLineUser.searchResultList.size() == 0) {

			this.hasErrorMessage = true;

			BusinessLogicException ex = new BusinessLogicException();
			ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_NO_DATA));
			CommonUtil.setErrorMessage(ex);
		}
	}

	/**
	 * LINE会員の取得
	 * @param String condAccountName	お客様名
	 * @param String condPhone			電話番号
	 * @param String condLineId			LINE ID
	 * @param String condStatus			ステータス
	 * @param String condLastReplyer	最終返信者
	 * @return List<LineMember__c>		LINE会員
	 */
	private List<LineMember__c> selectLineMember(String condAccountName
												 , String condPhone
												 , String condLineId
												 , String condStatus
												 , String condLastReplyer) {

		// メソッドの戻り値
		List<LineMember__c> returnList = new List<LineMember__c>();

		// SELECT ～ FROM句の取得
		String sql = 'SELECT Id '
					+ '		, Name '
					+ '		, Account__c '
					+ '		, Account__r.Name '
					+ '		, Account__r.Phone '
					+ '		, LineId__c '
					+ '		, Status__c '
					+ '		, lastSendTime__c '
					+ '		, lastReciveTime__c '
					+ '		, AddFriendTime__c '
					+ '		, (SELECT CreatedBy.Name '
					+ '		 FROM LineHistoryLineMember__r '
					+ '		 WHERE SendType__c = \'担当者\' '
					+ '		 ORDER BY SendTime__c DESC '
					+ '		 LIMIT 1) '
					+ 'FROM LineMember__c ';

		// WHERE句作成用
		List<String> condList = new List<String>();

		// お客様名
		if (!String.isBlank(condAccountName)) {
			condList.add('Account__r.Name LIKE ' + this.getCondStrPartialMatch(condAccountName));
		}

		// 電話番号
		if (!String.isBlank(condPhone)) {
			condList.add('Account__r.Phone LIKE ' + this.getCondStrPartialMatch(condPhone));
		}

		// LINE ID
		if (!String.isBlank(condLineId)) {
			condList.add('LineId__c LIKE ' + this.getCondStrPartialMatch(condLineId));
		}

		// ステータス
		if (!String.isBlank(condStatus)) {
			condList.add('Status__c LIKE :condStatus');
		}

		// WHERE句の取得
		if (condList.size() > 0) {
			sql += 'WHERE ';
			for (String cond : condList) {
				sql += cond + ' AND ';
			}
			sql = sql.removeEnd('AND ');
		}

		// ▼ 2022.05.25 No0827 対応で変更
		sql += 'ORDER BY LastReciveTime__c DESC NULLS FIRST ';	// 最終受信時刻降順
		sql += ' , AddFriendTime__c DESC '; // ともだち追加時刻降順
		// ▲ 2022.05.25 No0827 対応で変更
		sql += ' LIMIT 1000 ' ;

		// 検索結果の取得
		List<LineMember__c> lineMemberList = Database.query(sql);

		// 最終返信者に条件が設定されている場合、最終返信者がnullのレコードを排除
		if (String.isBlank(condLastReplyer) && !lineMemberList.isEmpty()) {
			returnList = lineMemberList;
		} else {
			for (LineMember__c lineMember : lineMemberList) {
				// 1度も返信を行っていない場合
				if (lineMember.LineHistoryLineMember__r.size() == 0) {
					continue;
				}
				// 「最終返信者」が一致しない場合
				if (condLastReplyer != lineMember.LineHistoryLineMember__r[0].CreatedById) {
					continue;
				}

				returnList.add(lineMember);
			}
		}
		return returnList;
	}

	/**
	 * 部分一致条件文字列の取得
	 * @param String condVal 条件値
	 * @return String 部分一致条件文字列
	 */
	private String getCondStrPartialMatch(String condVal) {
		return '\'%'+ CommonUtil.convertDisableWildcard(CommonUtil.escapeSingleQuotesEx(condVal)) + '%\'';
	}

	/**
	 * 対応の取得
	 * @param Set<Id> lineMemberIdSet LINE会員ID
	 * @return Map<Id, Correspond__c> key:LINE会員.ID、value:対応
	 */
	private Map<Id, Correspond__c> selectCorrespond(Set<Id> lineMemberIdSet) {
		// 検索条件で使用するステータスの設定 ◀ 2022.04.20 No0768 対応で削除

		List<Correspond__c> correspondList = [
			SELECT Id
			, AccountId__c		// 取引先
			, EchoShop__c		// 反響担当店舗
			, EchoShop__r.Name	// 反響担当店舗.店舗名
			//▼ 2022.04.25 No0804 対応で追加
			, VisitShop__c		// 来店担当店舗ID
			, VisitShopName__c	// 来店担当店舗名
			//▲ 2022.04.25 No0804 対応で追加
			, LineMember__c	// LINE会員
			FROM Correspond__c
			WHERE LineMember__c = :lineMemberIdSet
			ORDER BY AccountId__c
					, CreatedDate DESC];

		// LINE会員単位の最新レコードのみを取得
		Map<Id, Correspond__c> correspondShopMap = new Map<Id, Correspond__c>();
		for (Correspond__c correspond : correspondList) {

			if (correspondShopMap.containsKey(correspond.LineMember__c)) {
				continue;
			}

			correspondShopMap.put(correspond.LineMember__c, correspond);
		}

		return correspondShopMap;
	}

	/**
	 * 対応店舗変更処理
	 */
	public void chgShop() {
		this.screenLineUser.setCondLastReplyer();
	}
	
	/**
	 * LINEユーザ一覧
	 */
	public class ScreenLineUserList {

		/** 検索条件部 */
		public String condUserName	{get; set;} // お客様名
		public String condPhone		{get; set;} // 電話番号
		public String condLineId	{get; set;} // LINE ID

		public List<selectOption> condStatus			{get; set;} // ステータス
		public List<selectOption> condCorrespondShop	{get; set;} // 対応店舗
		public List<selectOption> condLastReplyer		{get; set;} // 最終返信者

		public String selectCondStatus			{get; set;} // ステータス（選択値）
		public String selectCondCorrespondShop	{get; set;} // 対応店舗（選択値）
		public String selectCondLastReplyer		{get; set;} // 最終返信者（選択値）

		/** 検索結果部 */
		public List<LineUserDetail> searchResultList {get; set;} // 明細

		/**
		 * コンストラクタ
		 * @param Id shopId			対応店舗ID
		 */
		public ScreenLineUserList(Id shopId) {

			/** 検索条件部 */
			this.condUserName	= CommonConst.STRING_EMPTY; // お客様名
			this.condPhone		= CommonConst.STRING_EMPTY; // 電話番号
			this.condLineId		= CommonConst.STRING_EMPTY; // LINE ID

			this.selectCondStatus			= CommonConst.STRING_EMPTY;	// ステータス（選択値）
			this.selectCondCorrespondShop	= shopId;					// 対応店舗（選択値）
			this.selectCondLastReplyer		= CommonConst.STRING_EMPTY;	// 最終返信者（選択値）

			// ステータス
			this.condStatus = CommonUtil.getSelectOptionFromObject(LineMember__c.getSObjectType().getDescribe().getName()
																	, LineMember__c.Status__c.getDescribe().getName());

			// 対応店舗
			this.condCorrespondShop = CommonUtil.getSelectOptionFromObjectData(Shop__c.getSObjectType().getDescribe().getName()
																				, Shop__c.Id.getDescribe().getName()
																				, Shop__c.Name.getDescribe().getName()
																				, Shop__c.SortOrder__c.getDescribe().getName());

			// 最終返信者
			this.setCondLastReplyer();

			/** 検索結果部 */
			this.searchResultList = new List<LineUserDetail>(); // 明細
		}

		/**
		 * 検索結果の設定
		 * @param List<LineMember__c> 		lineUserList			LINE会員
		 * @param Map<Id, Correspond__c>	lineMembercorrespondMap	対応店舗（key:LINE会員.ID、value:対応）
		 * @param String					selectCorrespondShop	選択された対応店舗
		 */
		public void setSearchResultList(List<LineMember__c> lineMemberList
										, Map<Id, Correspond__c> lineMembercorrespondMap
										, String selectCorrespondShop) {

			// 対応
			Correspond__c correspond;

			this.searchResultList = new List<LineUserDetail>();
			for (LineMember__c lineMember : lineMemberList) {

				// 対応店舗の条件設定時、値が存在しないレコードを排除
				if (String.isNotBlank(selectCorrespondShop)){
					//▼ 2022.04.25 No0804 対応で変更
					// LINE会員と対応が紐づいていない
					if (!lineMembercorrespondMap.containsKey(lineMember.Id)){
						continue;
					}

					//▼ 2022.05.25 No0827 対応で変更
					// 対応の反響担当店舗、来店担当店舗のどちらかがセットされている対応は検索条件を考慮する。
					if (lineMembercorrespondMap.get(lineMember.Id).EchoShop__c  != null ||
						lineMembercorrespondMap.get(lineMember.Id).VisitShop__c != null) {
						
						// 反響担当店舗が検索条件と一致しない（来店担当店舗が存在しない場合のみ）
						if(lineMembercorrespondMap.get(lineMember.Id).EchoShop__c != selectCorrespondShop 
							&& lineMembercorrespondMap.get(lineMember.Id).VisitShop__c == null){
							continue;
						}

						// 来店担当店舗が検索条件と一致しない
						if(lineMembercorrespondMap.get(lineMember.Id).VisitShop__c != selectCorrespondShop
							&& lineMembercorrespondMap.get(lineMember.Id).VisitShop__c != null){
							continue;
						}
						//▲ 2022.04.25 No0804 対応で変更
					}
					//▲ 2022.05.25 No0827 対応で変更


				}

				// 対応の取得
				correspond = new Correspond__c();
				if (lineMembercorrespondMap.containsKey(lineMember.Id)) {
					correspond = lineMembercorrespondMap.get(lineMember.Id);
				}

				// ユーザ一覧明細の設定
				this.searchResultList.add(new LineUserDetail(lineMember, correspond));
			}
		}

		/**
		 * 最終返信者の設定
		 */
		public void setCondLastReplyer() {

			// 店舗条件の取得
			List<Id> shopIdList = new List<String>();
			if (String.isNotBlank(this.selectCondCorrespondShop)) {
				shopIdList.add(this.selectCondCorrespondShop);
			}

			// 対応店舗に紐づいた最終返信者が選択されているかの確認
			this.condLastReplyer = CommonUtil.getUserSelectedOptionFromShopId(shopIdList, true);
			Boolean isExists = false;
			for (selectOption selectCon : condLastReplyer) {
				if(selectCon.getValue().equals(this.selectCondLastReplyer)) {
					isExists = true;
					break;
				} 
			}
			if (!isExists) {
				this.selectCondLastReplyer = CommonConst.STRING_EMPTY;
			}
		}
	}

	/**
	 * 明細
	 */
	public class LineUserDetail {

		/** 定数 */
		private final String STYLE_STATUS_NOT_REPLIED = 'notReplied'; // ステータス = "未返信"用スタイルクラス

		/** 画面項目 */
		public String	userName		{get; set;} // お客様名
		public Id		accountId		{get; set;} // 取引先ID
		public String	phone			{get; set;} // 電話番号
		public Id		lineMemberId	{get; set;} // LINE会員ID
		public String	lineId			{get; set;} // LINE ID
		public String	lineName		{get; set;} // LINE名
		public String	status			{get; set;} // ステータス
		public String	correspondShop	{get; set;} // 対応店舗
		public Id		correspondId	{get; set;} // 対応ID
		public String	lastReciveTime	{get; set;} // 最終受信時刻
		public String	lastSendTime	{get; set;} // 最終送信時刻
		public String	lastReplyer		{get; set;} // 最終返信者
		public String	addFriendTime	{get; set;} // ともだち追加時刻
		public Boolean	isLinking		{get; set;} // 紐づけフラグ

		/** スタイル */
		public String notReplied {get; set;}		

		/**
		 * コンストラクタ
		 * @param LineMember__c lineMember	LINE会員
		 * @param Correspond__c correspond	対応
		 */
		public lineUserDetail(LineMember__c lineMember,Correspond__c correspond) {

			/** 画面項目 */
			this.userName		= lineMember.Account__r.Name;					// お客様名
			this.accountId		= lineMember.Account__c;						// 取引先ID
			this.Phone			= lineMember.Account__r.Phone;					// 電話番号
			this.lineMemberId	= lineMember.Id;								// LINE会員ID
			this.LineId			= lineMember.LineId__c;							// LINE ID
			this.lineName		= lineMember.Name;								// LINE名
			this.status			= lineMember.Status__c;							// ステータス
			// 来店担当店舗があれば来店担当店舗。なければ反響担当店舗を設定する
			this.correspondShop = (correspond.VisitShop__c != null ) ? correspond.VisitShopName__c : correspond.EchoShop__r.Name;	// 対応店舗	2022.04.25 No0804 対応で変更
			this.correspondId	= correspond.Id;								// 対応ID
			this.lastReciveTime	= String.valueOf(lineMember.lastReciveTime__c);	// 最終受信時刻
			this.lastSendTime	= String.valueOf(lineMember.lastSendTime__c);	// 最終送信時刻

			// 最終返信者
			if (lineMember.LineHistoryLineMember__r.size() > 0) {
				this.lastReplyer = lineMember.LineHistoryLineMember__r[0].CreatedBy.Name;
			}

			this.AddFriendTime = String.valueOf(lineMember.AddFriendTime__c); // ともだち追加時刻

			// 紐づけフラグ
			this.isLinking = false;
			if (String.isBlank(this.userName)) {
				this.isLinking = true;
			}

			/** スタイル */
			this.notReplied = CommonConst.STRING_EMPTY;
			if (this.status == CommonConst.LINE_MEMBER_STATUS_NOT_REPLIED) {
				this.notReplied = this.STYLE_STATUS_NOT_REPLIED;
			}
		}
	}
}