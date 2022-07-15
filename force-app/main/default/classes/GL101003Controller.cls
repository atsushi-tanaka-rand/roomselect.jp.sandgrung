/**
 * LINEユーザ紐づけ
 */
public with sharing class GL101003Controller {

	/** 画面項目 **/
	public ScreenLineUserLinking screenLineUserLinking {get; set;}

	/** メッセージ **/
	public Msgs message {get; set;}

	/* パラメータID取得用 */
	public Id lineMemberId {get; set;}	// LINE会員.Id
	public Id correspondId {get; set;}	// 対応.Id
	public Id correspondIdPressRow {get; set;} // 行番号に紐づいた対応.Id

	/* フラグ */
	public Boolean isOpenError		{get; set; } // 初期表示フラグ
	public Boolean hasErrorMessage	{get; set; } // エラーメッセージ保有フラグ

	/**
	 * コンストラクタ
	 */
	public GL101003Controller() {

		try {
			// プロパティの初期化
			this.setInitProperty();

			// 店舗情報取得
			// 店舗情報が取得できない場合は例外をスロー
			CommonUtil.getStaffCurrentShop();

			// パラメータに紐づくオブジェクトの取得
			LineMember__c initialLineMember = this.selectLineMember(this.lineMemberId); // LINE会員
			Correspond__c initialCorrespond = this.selectInitialCorrespond(this.correspondId); // 対応
			
			// 正常レコードチェック
			BusinessLogicException ex = this.isNormalRecord(initialLineMember, initialCorrespond);
			if (ex.hasMessage()) {
				throw ex;
			}

			// 画面項目の初期化
			this.screenLineUserLinking = new ScreenLineUserLinking(initialLineMember, initialCorrespond);

			// マッチング候補者一覧の設定
			this.matchDetailDisplay();

		 } catch(Exception ex) {

			// 初期エラーフラグの更新
			this.isOpenError = true;

			// エラーメッセージの設定・表示
			CommonUtil.setErrorMessage(ex);
		}
	}

	/**
	 * 検索結果の明細検索
	 */
	public void searchResultDetailSet() {
		try {
			// エラーフラグの初期化
			this.hasErrorMessage = false;
			BusinessLogicException ex = new BusinessLogicException();

			// 入力チェック（FROM > TO の場合はエラーメッセージの設定）
			if(this.screenLineUserLinking.condCreatedDateFrom > this.screenLineUserLinking.condCreatedDateTo) {
				// エラーメッセージの追加
				ex.addMessage(CommonConst.MSG_COM_W_SEARCH_DATE_TERM);
				throw ex;
			}

			// 明細の設定
			this.searchDetailDisplay();

			// 明細件数が0件の場合はエラーメッセージを設定・表示	
			if (this.screenLineUserLinking.searchResultList.size() == 0) {
				// エラーメッセージの追加
				ex.addMessage(CommonConst.MSG_COM_W_SEARCH_NO_DATA);
				throw ex;
			}

		 } catch(Exception ex) {
			// エラーメッセージの設定・表示
			this.hasErrorMessage = true;
			CommonUtil.setErrorMessage(ex);
		} 
	}

	/**
	 * プロパティの初期化設定
	 */
	private void setInitProperty() {

		// エラーフラグ
		this.isOpenError	 = false;
		this.hasErrorMessage = false;

		// メッセージクラス
		this.message = new Msgs();

		// パラメータの取得
		this.lineMemberId = ApexPages.currentPage().getParameters().get('lineMemberId'); // LINE会員ID
		this.correspondId = ApexPages.currentPage().getParameters().get('correspondId'); // 対応ID
	}

	/**
	 * 正常レコードチェック
	 * @param LineMember__c lineMember LINE会員
	 * @param Correspond__c correspond 対応
	 * @return BusinessLogicException 入力規則用例外クラス
	 */
	private BusinessLogicException isNormalRecord(LineMember__c lineMember, Correspond__c correspond) {

		BusinessLogicException ex = new BusinessLogicException();

		// レコードの存在チェック
		if (String.isEmpty(lineMember.Id) || String.isEmpty(correspond.Id)) {
			ex.addMessage(CommonConst.MSG_COM_E_SYSTEM_PARAMETER);
			return ex;
		}

		// 紐づけ済みチェック
		if (String.isNotBlank(lineMember.Account__c)) {
			ex.addMessage(CommonConst.MSG_CUST_E_ALREADY_LINKING_LINE_MEMBER);
			return ex;
		}

		return ex;
	}

	/**
	 * マッチング候補者一覧の明細表示処理
	 */
	private void matchDetailDisplay() {

		// LINE会員候補の取得
		List<LineMemberCandidate__c> lineMemberCandidateList = this.selectLineMemberCandidate();
		
		// LINE会員候補に紐づいた取引先の取得
		Set<Id> accounIdSet = new Set<Id>();
		for (LineMemberCandidate__c lineMemberCandidate : lineMemberCandidateList) {
			accounIdSet.add(lineMemberCandidate.Account__c);
		}

		// 楽観ロックチェック用
		// 紹介メール情報
		Map<Id, IntroductionMailInformation__c> accountIdIntroductionMailInformationMap = this.selectIntroductionMailInformation(accounIdSet);

		// 取引先の取得
		Map<Id,Account> accountMap = this.selectOptimisticAccount(accounIdSet);

		// 対応の取得
		Map<Id, Correspond__c> accountCorrespondMap = this.selectCorrespond(accounIdSet);

		// 明細一覧の設定
		this.screenLineUserLinking.setMatchDetailList(lineMemberCandidateList, accountCorrespondMap,
		accountIdIntroductionMailInformationMap, accountMap);																					
	}

	/**
	 * 検索結果の明細表示処理
	 */
	private void searchDetailDisplay(){
		// 検索条件の取得
		String candidateAccountName		= this.screenLineUserLinking.condAccountName;		// お客様名
		String candidateAccountPhone	= this.screenLineUserLinking.condPhone;				// 電話番号
		Date candidateCreatedDateFrom	= this.screenLineUserLinking.condCreatedDateFrom;	// 作成日FROM
		Date candidateCreatedDateTo		= this.screenLineUserLinking.condCreatedDateTo;		// 作成日TO

		// 取引先の取得
		List<Account> accountList = this.selectAccount(
			candidateAccountName,
			candidateAccountPhone,
			candidateCreatedDateFrom,
			candidateCreatedDateTo
		);

		// 取引先Idの取得
		Set<Id> accounIdSet = new Set<Id>();
		for (Account account : accountList) {
			accounIdSet.add(account.Id);
		}

		// 楽観ロックチェック用
		// 紹介メール情報の取得
		Map<Id, IntroductionMailInformation__c> accountIdIntroductionMailInformationMap = this.selectIntroductionMailInformation(accounIdSet);

		// 対応の取得
		Map<Id, Correspond__c> accountCorrespondMap = this.selectCorrespond(accounIdSet);

		// 明細一覧の設定
		this.screenLineUserLinking.setSearchDetailList(accountList, accountCorrespondMap, accountIdIntroductionMailInformationMap);
	}

	/**
	 * パラメータに紐づくLINE会員の取得
	 * @param Id lineMemberId	LINE会員.Id
	 * @return LineMember__c LINE会員	
	 */
	private LineMember__c selectLineMember(Id lineMemberId) {
		
		List<lineMember__c> lineMember = [
			SELECT 
				Id ,
				Name , // LINE名
				LineId__c , // LINE ID
				AddFriendTime__c , // ともだち追加時刻
				FriendRegistCode__c, // ともだち登録コード
				Account__c,
				SystemModstamp
			FROM LineMember__c
			WHERE Id = :lineMemberId
		];
		
		// null対策
		if (lineMember.isEmpty()) {
			return new LineMember__c();
		}

		return lineMember[0];
	}

	/**
	 * パラメータに紐づく対応の取得
	 * @param Id correspondId	クエリストリングの対応ID
	 * @return Correspond__c 対応
	 */
	private Correspond__c selectInitialCorrespond(Id correspondId) {
		List<Correspond__c> correspond = [
			SELECT
				Id,
				SystemModstamp
			FROM Correspond__c
			WHERE Id =:correspondId
		];

		// null対策
		if (correspond.isEmpty()) {
			return new Correspond__c();
		}
		return correspond[0];
	}

	/**
	 * LINE会員候補の取得
	 * @return List<LineMemberCandidate__c> LINE会員候補
	 */
	private List<LineMemberCandidate__c> selectLineMemberCandidate() {

		// システム時間の1時間前の時間を取得
		DateTime matchingTargetTime = CommonUtil.getNow().addHours(-1);

		// SELECT～WHERE句の取得
		String sql = 'SELECT '
					+ '  Id, '
					+ '	 Account__c, '
					+ '	 Account__r.Name, '
					+ '	 Account__r.Phone, '
					+ '	 Account__r.Email__c, '
					+ '	 Account__r.SystemModstamp, '
					+ '	 FriendRegistCode__c, '
					+ '  SystemModstamp, '
					+ '	 CreatedDate '
					+ 'FROM LineMemberCandidate__c '
					+ 'WHERE '
					+ '  IsLinking__c = false '
					+ '	 AND CreatedDate >= ' 
					+   	matchingTargetTime.format('yyyy-MM-dd\'T\'HH:mm:ss.000\'+0900\'', 'JST')
					+ ' ORDER BY Account__r.Name '
					+ 'LIMIT 1000 ';

		// 検索結果の取得
		return Database.query(sql);
	}

	/**
	 * 取引先の取得
	 * @param String candidateAccountName お客様名
	 * @param String candidateAccountPhone 電話番号
	 * @param Datetime candidateCreatedDateFrom 作成日FROM
	 * @param Datetime candidateCreatedDateTo	作成日TO
	 * @return List<Account> 取引先
	 */
	private List<Account> selectAccount(
		String candidateAccountName,
		String candidateAccountPhone,
		Datetime candidateCreatedDateFrom,
		Datetime candidateCreatedDateTo) {

		// SELECT～WHERE句の取得
		String sql = 'SELECT '
					+ ' 	Id, '
					+ '		Name, '
					+ '		Phone, '
					+ '		Email__c, '
					+ '		SystemModstamp, '
					+ '		(SELECT '
					+ '			Id, '
					+ '			FriendRegistCode__c, '
					+ '			CreatedDate, '
					+ '			SystemModstamp '
					+ '		FROM LineMemberCandidateAccount__r ) '	// LINE会員候補
					+ 'FROM Account '
					+ 'WHERE '
					+ '  	Id NOT IN '
					+ '			(SELECT Account__c '
					+ '			FROM LineMemberCandidate__c '
					+ '			WHERE IsLinking__c = true) '
					//レコードタイプ／取引先:顧客	//▼ 2022.04.20 No0768 対応で追加
					+ ' AND RecordTypeId =\'' + CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_CUSTOMER) +'\'';

		// FROM TOへの入力確認
		if (candidateCreatedDateFrom != null || candidateCreatedDateTo != null) {
			sql += 'AND Id IN (SELECT Account__c FROM LineMemberCandidate__c WHERE ';
		
			// 作成日FROM
			if (candidateCreatedDateFrom != null) {
				sql += 'CreatedDate >= ' + candidateCreatedDateFrom.format('yyyy-MM-dd\'T\'HH:mm:ss.000\'+0900\'', 'JST');
				sql += ' AND ';
			}

			// 作成日TO
			if (candidateCreatedDateTo != null) {
				sql += 'CreatedDate <= ' + candidateCreatedDateTo.format('yyyy-MM-dd\'T\'HH:mm:ss.000\'+0900\'', 'JST');
			}
			sql = sql.removeEnd('AND ');
			sql += ')';
		}

		// WHERE句作成用
		List<String> conditionsList = new List<String>();

		// お客様名
		if (!String.isBlank(candidateAccountName)) {
			conditionsList.add('Name Like ' + this.getCandidateStrPartialMatch(candidateAccountName));
		}

		// 電話番号
		if (!String.isBlank(candidateAccountPhone)) {
			conditionsList.add('Phone Like ' + this.getCandidateStrPartialMatch(candidateAccountPhone));
		}

		// WHERE句の作成
		if (conditionsList.size() > 0) {
			for (String conditionsClause : conditionsList) {
				sql += ' AND ' + conditionsClause;
			}
		}
		
		// ソート条件
		sql += ' ORDER BY Name ';
		// ガバナ制限考慮
		sql += ' LIMIT 1000 ' ;
		
		// 検索結果の取得
		return Database.query(sql);
	}

	/**
	 * 対応の取得
	 * @param Set<Id> accountIdSet	取引先
	 * @return Map<Id, Correspond__c> key:取引先ID value:対応
	 * 
	 */
	private Map<Id, correspond__c> selectCorrespond(Set<Id> accounIdSet) {
		// 検索条件で使用するステータスの設定
		Set<String> notApplicableStatus = new Set<String>{CommonConst.CORRESPOND_STATUS_CLOSE,
			CommonConst.CORRESPOND_STATUS_AGREEMENT, CommonConst.CORRESPOND_STATUS_ECHOAGGREGATION};

		List<Correspond__c> correspondList = [
			SELECT
				Id,
				AccountId__c // 取引先
			FROM Correspond__c // 対応
			WHERE AccountId__c = :accounIdSet
			AND	Status__c != :notApplicableStatus
			ORDER BY
				AccountID__r.Name ASC, // 取引先名
				CreatedDate DESC // 作成日
			LIMIT 1000 // ガバナ制限考慮
		];
		
		// 取引先単位の最新のレコードのみを取得
		Map<Id, Correspond__c> accountIdCorrespondMap = new Map<Id, Correspond__c>();
		for (Correspond__c correspond : correspondList) {

			if (accountIdCorrespondMap.containsKey(correspond.AccountId__c)) {
				continue;
			}
			accountIdCorrespondMap.put(correspond.AccountId__c, correspond);
		}
		return accountIdCorrespondMap;
	}

	/**
	 * 紹介メール情報の取得
	 * @param Set<Id> accounIdSet　取引先ID
	 * @return List<IntroductionMailInformation__c> 紹介メール情報
	 */
	private Map<Id, IntroductionMailInformation__c> selectIntroductionMailInformation(Set<Id> accounIdSet) {
		// 紹介メール情報の取得
		List<IntroductionMailInformation__c> introductionMailInformationList = [
			SELECT
				Id,
				Account__c,
				SystemModstamp
			FROM IntroductionMailInformation__c
			WHERE Account__c =:accounIdSet
			LIMIT 1000 // ガバナ制限考慮
		];

		// 取引先単位の紹介メール情報を取得
		Map<Id, IntroductionMailInformation__c> accountIdIntroductionMailInformationMap = new Map<Id, IntroductionMailInformation__c>();
		for (IntroductionMailInformation__c introductionMailInformation : introductionMailInformationList) {

			if (accountIdIntroductionMailInformationMap.containsKey(introductionMailInformation.Account__c)) {
				continue;
			}
			accountIdIntroductionMailInformationMap.put(introductionMailInformation.Account__c, introductionMailInformation);
		}

		return accountIdIntroductionMailInformationMap;
	}

	/**
	 * 取引先の取得
	 * @param Set<Id> accountIdSet LINE会員候補に紐づいた取引先ID
	 * @return Map<Id,Account> key:取引先ID value:取引先
	 */
	private Map<Id,Account> selectOptimisticAccount(Set<Id> accounIdSet) {
		// LINE会員候補に紐づいた取引先の取得
		List<Account> accountList = [
			SELECT
				Id,
				SystemModstamp
			FROM Account
			WHERE Id =:accounIdSet
		];

		// Map作成
		Map<Id,Account> accountMap = new Map<Id,Account>(accountList);

		return accountMap;
	}

	/**
	 * 部分一致条件文字列の取得
	 * @param String candVal 条件値
	 * @return String 部分一致条件文字列
	 */
	private String getCandidateStrPartialMatch(String candVal) {
		return '\'%'+ CommonUtil.convertDisableWildcard(CommonUtil.escapeSingleQuotesEx(candVal)) + '%\'';
	}

	/**
	 * マッチング候補者一覧の決定ボタン押下
	 */
	public void linkDataMatch() {
		try {
			// 行番号に紐づいたマッチング候補者一覧
			List<AccountDetail> screenLineUser = this.screenLineUserLinking.matchCandidateList;

			// 楽観ロックチェック
			if (!isLinkingOptimisticLock(screenLineUser)) {
				throw new OptimisticLockException();
			}

			// CRUD処理の呼び出し
			this.linkDataCall(screenLineUser);
		} catch(Exception ex) {
			// エラーメッセージの設定
			this.hasErrorMessage = true;
			CommonUtil.setErrorMessage(ex);
		}
	}

	/**
	 * 検索結果の決定ボタン押下
	 */
	public void linkDataSearch() {
		try {
			// 行番号に紐づいた検索結果の取得
			List<AccountDetail> screenLineUser = screenLineUserLinking.searchResultList;

			// 楽観ロックチェック
			if (!isLinkingOptimisticLock(screenLineUser)) {
				throw new OptimisticLockException();
			}

			// CRUD処理の呼び出し
			this.linkDataCall(screenLineUser);
		} catch(Exception ex) {
			// エラーメッセージの設定
			this.hasErrorMessage = true;
			CommonUtil.setErrorMessage(ex);
		}
	}

	/**
	 * お客様登録と紐づけボタン押下
	 */
	public void linkDataRegisterAccount() {
		// セーブポイントの作成
		Savepoint sp = Database.setSavepoint();
		try {
			// 楽観ロックチェック
			if (!isLinkingInsertAccountOptimisticLock()) {
				throw new OptimisticLockException();
			}

			// 取引先の登録・取得
			Account account = this.linkDataInsertAccount();

			// CRUD処理の呼び出し
			this.linkDataCall(account.Id, account.Name, null, this.correspondId);
		} catch(Exception ex) {
			
			// ロールバック処理
			Database.rollback(sp);
			// エラーメッセージの設定
			this.hasErrorMessage = true;
			CommonUtil.setErrorMessage(ex);
		}
	}

	/**
	 * 紐づけデータの呼び出し
	 * @param Id accountId	取引先ID
	 * @param String accountName 取引先名
	 * @param Id lineMemberCandiDateId LINE会員候補ID
	 * @param Id correspondId 対応ID
	 */
	private void linkDataCall(Id accountId, String accountName, Id lineMemberCandiDateId, Id correspondId) {
		// セーブポイントの作成
		Savepoint sp = Database.setSavepoint();
		try{

			// LINE会員と取引先の紐づけ用の更新
			this.linkDataUpdateLineMember(accountId, this.lineMemberId);

			// LINE会員候補の登録・更新
			this.linkDataUpsertLineMemberCandidate(lineMemberCandiDateId, accountId);

			//▼ 2022.05.16 No0758 対応で移動＋変更
			// 対応の登録、更新
			this.linkDataUpdateCorrespond(this.correspondId, accountId, this.lineMemberId);

			// 対応明細のレコード登録
			this.linkDataInsertCorrespondDetail(this.correspondId, accountName);
			//▲ 2022.05.16 No0758 対応で移動＋変更
			
			// 紹介メール情報の削除
			this.linkDataAutomaticCustomerSuspensionProcess(correspondId, accountId);
		} catch(Exception ex) {
			// ロールバック処理
			Database.rollback(sp);
			throw ex;
		}	
	}

	/**
	 * 紐づけデータの呼び出し（オーバーロード）
	 * @param List<AccountDetail> screenLineUser 明細
	 */
	private void linkDataCall(List<AccountDetail> screenLineUser) {
		// 明細押下行の設定
		AccountDetail screenLineUserPressRow = screenLineUser[screenLineUserLinking.detailIndex];

		// 決定ボタン押下行の取引先IDの取得
		Id accountId = screenLineUserPressRow.accountId;

		// 決定ボタン押下行の取引先名の取得
		String accountName = screenLineUserPressRow.accountName;

		// 決定ボタン押下行のLINE会員候補IDの取得
		Id lineMemberCandiDateId = screenLineUserPressRow.lineMemberCandiDateId;
		
		// 決定ボタン押下行の対応IDの取得
		this.correspondIdPressRow = screenLineUserPressRow.correspondId;

		this.linkDataCall(accountId, accountName, lineMemberCandiDateId, correspondIdPressRow);
	}

	/**
	 * 紐づけ処理時の楽観ロックチェック
	 * @param List<AccountDetail> screenLineUser 明細
	 * @return Boolean true:更新無し、false:更新有り
	 */
	private Boolean isLinkingOptimisticLock(List<AccountDetail> screenLineUser) {

		// 明細押下行の設定
		AccountDetail screenLineUserPressRow = screenLineUser[screenLineUserLinking.detailIndex];

		// LINE会員
		if (!CommonUtil.isOptimisticLock(this.screenLineUserLinking.lineMember)) {
			return false;
		}

		// 対応
		if (!CommonUtil.isOptimisticLock(this.screenLineUserLinking.correspond)) {
			return false;
		}

		// 取引先
		if (!CommonUtil.isOptimisticLock(screenLineUserPressRow.account)) {
			return false;
		}

		// LINE会員候補
		if (!CommonUtil.isOptimisticLock(screenLineUserPressRow.lineMemberCandidate)) {
			return false;
		}

		// 紹介メール情報
		if (!CommonUtil.isOptimisticLock(screenLineUserPressRow.introductionMailInformation)) {
			return false;
		}

		return true;
	}

	/**
	 * 紐づけ処理時の楽観ロックチェック
	 * お客様登録と紐づけボタン押下
	 * @return Boolean true:更新無し、false:更新有り
	 */
	private Boolean isLinkingInsertAccountOptimisticLock() {

		// LINE会員
		if (!CommonUtil.isOptimisticLock(this.screenLineUserLinking.lineMember)) {
			return false;
		}

		// 対応
		if (!CommonUtil.isOptimisticLock(this.screenLineUserLinking.correspond)) {
			return false;
		}

		return true;
	}

	/**
	 * 対応明細のレコード登録
	 * @param Id correspondId	押下行に紐づいた対応ID
	 * @param String accountName　押下行に紐づいた取引先名
	 */
	private void linkDataInsertCorrespondDetail(Id correspondId, String accountName) {
		
		// 対応明細オブジェクトのレコード登録
		CorrespondDetail__c correspondDetail = new CorrespondDetail__c(
			Corresponds__c = correspondId, // 対応番号
			CorrespondType__c = CommonConst.TASK_CORRESPONDTYPE_LINE, // 対応種別
			SupportedContent__c = CommonConst.MSG_CUST_I_EXECUTE_ACCOUNT_LINKING_END + CommonConst.BREAK_CODE +
								CommonConst.BREAK_CODE + '【取引先名】:' + accountName, // 対応内容
			SupportedDateTime__c = CommonUtil.getNow(), // 対応日時
			Shop__c = CommonUtil.getStaffCurrentShop().Id, // 店舗
			Staff__c = UserInfo.getUserId(), // 担当者
			SupportedTitle__c = CommonConst.CORRESPONDDETAIL_SUPPORTEDTITLE_LINE // 対応表題
		);
		SecureDML.secureInsert(correspondDetail);
	}

	/**
	 * LINE会員の更新
	 * @param Id accountId		押下行に紐づいた取引先ID
	 * @param Id lineMemberId	クエリストリングのLINE会員ID
	 */
	private void linkDataUpdateLineMember(Id accountId, Id lineMemberId) {
		// LINE会員と取引先の紐づけ用の更新
		LineMember__c updateLineMember = new LineMember__c(Id = lineMemberId,
															Account__c = accountId //取引先
		);
		SecureDML.secureUpdate(updateLineMember);
	}

	/**
	 * LINE会員候補の登録・更新
	 * @param String lineMemberCandiDateId 押下行に紐づいたLINE会員候補
	 * @param Id accountId 押下行に紐づいた取引先ID
	 */
	private void linkDataUpsertLineMemberCandidate(Id lineMemberCandiDateId, Id accountId) {
		LineMemberCandidate__c upsertLineMemberCandidate = new LineMemberCandidate__c(
			// LINE会員候補の登録・更新（アップサート）
			Id = lineMemberCandiDateId,
			Account__c = accountId, // 取引先
			IsLinking__c = true // 紐づけフラグ
		);
		SecureDML.secureUpsert(upsertLineMemberCandidate);
	}

	//▼ 2022.05.16 No0758 対応で変更
	/**
	 * 対応の更新、作成
	 * @param Id correspondId	押下行に紐づいた対応ID
	 * @param Id accountId		押下行に紐づいた取引先ID
	 * @param Id lineMemberId	押下行に紐づいたLINE会員ID
	 */
	private void linkDataUpdateCorrespond(Id correspondId, Id accountId, Id lineMemberId){
		// 対応の新規登録
		Correspond__c correspondData = CustomerUtil.checkCorrespondLine(lineMemberId,true);

		Correspond__c updateCorrespond = new Correspond__c();
		updateCorrespond.Id = correspondId;
		updateCorrespond.AccountId__c = accountId; // 取引先
		// 新規登録があった場合、現在の対応の初回LINE追加フラグをFalseにする
		if(correspondId != correspondData.Id){
			updateCorrespond.FirstLineAddFlg__c = false; // 初回LINE追加フラグ
		}
		//▼ 2022.05.16 No0759 対応で追加 
		if (correspondIdPressRow != null){
			// 紐づけ先の取引先に対応があれば、反響数を計算しないようにする。
			updateCorrespond.IsEchoNotCalculation__c = true;	// 反響数非計算フラグ
		}
		SecureDML.secureUpdate(updateCorrespond);
		//▲ 2022.05.16 No0759 対応で変更
	}
	//▲ 2022.05.16 No0758 対応で変更

	/**
	 * 紐づけのための取引先の登録
	 * @return Account 取引先
	 */
	private Account linkDataInsertAccount() {

		// 取引先の登録
		Account account = new Account(
			Name				= this.screenLineUserLinking.infoLineName,		// LINE名
			LastName__c			= this.screenLineUserLinking.infoLineName,		// 姓
			Email__c			= this.screenLineUserLinking.infoLineId,		// メールアドレス
			RecordTypeId		= CommonUtil.getRecordTypeId(Account.getSObjectType().getDescribe().getName(), CommonConst.ACCOUNT_RECTYPE_CUSTOMER),	// レコードタイプ
			RemarksPublic__c	= 'LINEユーザ紐づけ画面で登録'
		);
		SecureDML.secureInsert(account);
		return account;
	}

	/**
	 * 条件に合致する紹介メール情報の削除
	 * @param Id correspondId	押下行に紐づいた対応ID
	 * @param Id accountId		押下行に紐づいた取引先ID
	 */
	private void linkDataAutomaticCustomerSuspensionProcess(Id correspondId, Id accountId) {

		// 紹介メール情報の取得
		List<IntroductionMailInformation__c> introductionMailInformationList = [
			SELECT Id
			FROM IntroductionMailInformation__c
			WHERE Correspond__c =:correspondId
			AND	 Account__c =:accountId
		];

		// 紹介メール情報の削除
		if(!introductionMailInformationList.isEmpty() && AuthorityCheckUtil.getAuthorityOptionPortal(false)) {
			SecureDML.secureDelete(introductionMailInformationList);
			this.deliveryStopProcess(accountId);
		}
	}

	/**
	 * 取引先レコードの更新
	 * @param Id accountId		押下行に紐づいた取引先ID
	 */
	private void deliveryStopProcess(Id accountId) {

		// 取引先の更新
		Account accountUpdate = new Account(Id = accountId, 
											IntroMailInfoStatus__c = CommonConst_ptl.INTRODUCTION_SENDSTOP // 紹介メール配信状況
		);
		SecureDML.secureUpdate(accountUpdate);
	}
	
	/**
	 * LINEユーザ紐づけ画面項目クラス
	 */
	public class ScreenLineUserLinking {

		/** 項目 */
		public String infoLineId		{get; set;} // LINE会員情報.LINE ID
		public String infoLineName		{get; set;} // LINE会員情報.LINE名
		public String infoAddFriendDate {get; set;} // LINE会員情報.友達登録日時
		public String infoLineFrirendCd {get; set;} // LINE会員情報.LINE友達登録コード

		public List<AccountDetail> matchCandidateList {get; set;} // マッチング候補者一覧．明細

		public String condAccountName	{get; set;} // お客様情報検索.お客様名
		public String condPhone			{get; set;} // お客様情報検索.電話番号
		public Date condCreatedDate		{get; set;} // お客様情報検索.作成日
		public Date condCreatedDateFrom	{get; set;} // お客様情報検索.作成日FROM
		public Date condCreatedDateTo	{get; set;} // お客様情報検索.作成日To

		public List<AccountDetail> searchResultList {get; set;} // 検索結果．明細

		public Integer detailIndex {get; set;} //行番号

		public LineMember__c lineMember {get; set;} // クエリストリングIDに対応したLINE会員
		public Correspond__c correspond {get; set;} // クエリストリングIDに対応した対応

		/**
		 * コンストラクタ
		 * @param LineMember__c lineMember	LINE会員
		 * @param Correspond__c correspond	対応
		 */
		public screenLineUserLinking(LineMember__c lineMember, Correspond__c correspond) {

			// 項目の設定
			this.infoLineId			= lineMember.LineId__c;
			this.infoLineName		= lineMember.Name;
			this.infoAddFriendDate	= lineMember.AddFriendTime__c.format('yyyy/MM/dd HH:mm:ss');	
			this.infoLineFrirendCd	= lineMember.FriendRegistCode__c;

			this.matchCandidateList = new List<AccountDetail>();

			this.condAccountName	= CommonConst.STRING_EMPTY;
			this.condPhone			= CommonConst.STRING_EMPTY;
			this.condCreatedDate	= null;
			this.condCreatedDateFrom	= null;
			this.condCreatedDateTo		= null;

			this.searchResultList = new List<AccountDetail>();

			// オブジェクト情報の設定
			this.lineMember = lineMember;
			this.correspond = correspond;
		}

		/**
		 * 明細一覧の表示
		 * @param List<LineMemberCandidate__c> lineMemberCandidate	LINE会員候補
		 * @param Map<Id, correspond__c> Key:取引先ID value:対応
		 * @param Map<Id, IntroductionMailInformation__c> Key:取引先ID Value:紹介メール情報
		 * @param Map<Id, Account>  Key:取引先ID Value:取引先
		 */
		public void setMatchDetailList(
			List<LineMemberCandidate__c> lineMemberCandidateList,
			Map<Id, correspond__c> accountCorrespondMap,
			Map<Id, IntroductionMailInformation__c> accountIdIntroductionMailInformationMap,
			Map<Id, Account> accountMap
		) {
			// 対応
			Correspond__c correspond;

			// 明細の初期化
			this.matchCandidateList = new List<AccountDetail>();
			
			for (lineMemberCandidate__c lineMemberCandidate : lineMemberCandidateList) {

				// 対応の取得
				correspond = new Correspond__c();
				if (accountCorrespondMap.containsKey(lineMemberCandidate.Account__c)){
					correspond = accountCorrespondMap.get(lineMemberCandidate.Account__c);
				}

				// 取引先の取得
				Account account = new Account();
				if (accountMap.containsKey(lineMemberCandidate.Account__c)) {
					account = accountMap.get(lineMemberCandidate.Account__c);
				}

				// 紹介メール情報の取得
				IntroductionMailInformation__c introductionMailInformation = new IntroductionMailInformation__c();
				if (accountIdIntroductionMailInformationMap.containsKey(lineMemberCandidate.Account__c)) {
					introductionMailInformation = accountIdIntroductionMailInformationMap.get(lineMemberCandidate.Account__c);
				}

				// 明細の表示設定
				this.matchCandidateList.add(new accountDetail(lineMemberCandidate, correspond,
				introductionMailInformation, account));
			}
		}

		/**
		 * 明細一覧の表示
		 * @param List<Account> accountList	取引先
		 * @param Map<Id, correspond__c> accountCorrespondMap Key:取引先ID Value:対応
		 * @param Map<Id, IntroductionMailInformation__c> accountIdIntroductionMailInformationMap Key:取引先ID Value:紹介メール情報
		 */
		public void setSearchDetailList(
			List<Account> accountList,
			Map<Id, correspond__c> accountCorrespondMap,
			Map<Id, IntroductionMailInformation__c> accountIdIntroductionMailInformationMap
		) {
			// 対応
			Correspond__c correspond;

			// 明細の初期化
			this.searchResultList = new List<AccountDetail>();
			
			for (Account account : accountList) {

				// 対応の取得
				correspond = new Correspond__c();
				if (accountCorrespondMap.containsKey(account.Id)){
					correspond = accountCorrespondMap.get(account.Id);
				}

				// 紹介メール情報の取得
				IntroductionMailInformation__c introductionMailInformation = new IntroductionMailInformation__c();
				if (accountIdIntroductionMailInformationMap.containsKey(account.Id)) {
					introductionMailInformation = accountIdIntroductionMailInformationMap.get(account.Id);
				}

				// 明細の表示設定
				this.searchResultList.add(new accountDetail(account, correspond, introductionMailInformation));
			}
		}
	}

	/**
	 * お客様明細クラス
	 */
	public class AccountDetail {

		/** 項目 */
		public String	accountName											{get; set;} // お客様名
		public String	phone												{get; set;} // 電話番号
		public String	mailAddress											{get; set;} // メールアドレス
		public String	lineFrirendCd										{get; set;} // LINE友達登録コード
		public String	addFriendDate										{get; set;} // ともだち追加時刻
		public Id		correspondId										{get; set;}	// 対応Id
		public Id		accountId											{get; set;} // 取引先Id
		public Id		lineMemberCandiDateId								{get; set;} // LINE会員候補Id
		public LineMemberCandidate__c lineMemberCandidate 					{get; set;} // LINE会員候補
		public Account account												{get; set;} // 取引先
		public IntroductionMailInformation__c introductionMailInformation	{get; set;} // 紹介メール情報

		/**
		 * コンストラクタ　マッチング候補者一覧
		 * @param LineMemberCandiDate__c lineMemberCandiDate	LINE会員候補
		 * @param correspond__c correspond	対応
		 * @param IntroductionMailInformation__c introductionMailInformation 紹介メール情報
		 * @param Account account 取引先
		 */
		public accountDetail(
			LineMemberCandidate__c lineMemberCandidate,
			correspond__c correspond,
			IntroductionMailInformation__c introductionMailInformation,
			Account account
		) {
			// 項目の設定
			this.accountName					= lineMemberCandidate.Account__r.Name;
			this.phone							= lineMemberCandidate.Account__r.Phone;
			this.mailAddress					= lineMemberCandidate.Account__r.Email__c;
			this.lineFrirendCd					= lineMemberCandidate.FriendRegistCode__c;
			this.addFriendDate					= lineMemberCandidate.CreatedDate.format('yyyy/MM/dd HH:mm:ss');
			this.correspondId					= correspond.Id;
			this.accountId						= lineMemberCandidate.Account__c;
			this.lineMemberCandiDateId			= lineMemberCandidate.Id;
			this.lineMemberCandidate			= lineMemberCandidate;
			this.introductionMailInformation	= introductionMailInformation;
			this.account						= account;
		}

		/**
		 * コンストラクタ（オーバーロード） 検索結果一覧
		 * @param Account account	取引先
		 * @param Correspond__C correspond 対応
		 * @param IntroductionMailInformation__c introductionMailInformation 紹介メール情報
		 */
		public accountDetail(
			Account account,
			Correspond__c correspond,
			IntroductionMailInformation__c introductionMailInformation
		) {
			this.accountName	= account.Name;
			this.phone			= account.Phone;
			this.mailAddress	= account.Email__c;
			if(account.LineMemberCandidateAccount__r.size() > 0) {
				this.lineFrirendCd			= account.LineMemberCandidateAccount__r[0].FriendRegistCode__c;
				this.addFriendDate			= account.LineMemberCandidateAccount__r[0].CreatedDate.format('yyyy/MM/dd HH:mm:ss');
				this.lineMemberCandiDateId	= account.LineMemberCandidateAccount__r[0].Id;
				this.lineMemberCandidate	= account.LineMemberCandidateAccount__r[0];
			} else {
				this.lineMemberCandidate = new LineMemberCandidate__c();
			}
			this.correspondId					= correspond.Id;
			this.accountId						= account.Id;
			this.introductionMailInformation	= introductionMailInformation;
			this.account						= account;
		}
	}

	/**
	 * メッセージ格納クラス
	 */
	public class Msgs {
		private final String MSG_CUST_V_EXECUTE_ACCOUNT_LINKING = CommonConst.MSG_CUST_V_EXECUTE_ACCOUNT_LINKING;
		private final String MSG_COM_I_SAVE = CommonConst.MSG_COM_I_SAVE;
		private final String MSG_CUST_I_EXECUTE_LINKING_END = CommonConst.MSG_CUST_I_EXECUTE_LINKING_END;
		private final String MSG_CUST_I_EXECUTE_LINKING_ACCOUNTS_END = CommonConst.MSG_CUST_I_EXECUTE_LINKING_END +
																	CommonConst.BREAK_TAG + CommonConst.MSG_CUST_I_EXECUTE_LINKING_ACCOUNTS_END;
		private final String MSG_CUST_V_EXECUTE_ACCOUNT_REGISTER_LINKING = CommonConst.MSG_CUST_V_EXECUTE_ACCOUNT_REGISTER_LINKING;

		/**
		 * 紐づけ確認メッセージ
		 */
		public String getLinkingMessage() {
			// 取引先との紐づけを行います。よろしいですか？
			return MSG_CUST_V_EXECUTE_ACCOUNT_LINKING;
		}
	
		/**
		 * 完了メッセージ
		 */
		public String getCompletionMessage() {
			// 紐づけが完了しました。
			return MSG_CUST_I_EXECUTE_LINKING_END;
		}

		/**
		 * 完了メッセージ（対応が複数紐づいている場合）
		 */
		public String getCompletionMessageCorrespons() {
			// 紐づけが完了しました。
			// 紐づけされた取引先には、対応が複数存在します。
			return MSG_CUST_I_EXECUTE_LINKING_ACCOUNTS_END;
		}

		/**
		 * お客様登録と紐づけ 確認メッセージ
		 */
		public String getRegisterLinkingMessage() {
			// 取引先の登録と紐づけを行います。よろしいですか？
			return MSG_CUST_V_EXECUTE_ACCOUNT_REGISTER_LINKING;
		}
	}
}