/**
 * LINE専用
 */
public with sharing class GL101001Controller {

	/** 定数 */
	private final String SUPPORTED_TITLE_RELEASE_LINKING	= '紐づけ解除';		// 対応表題：紐づけ解除
	private final String SUPPORTED_TITLE_SEND_LINE			= 'LINE手動返信';	// 対応表題：LINE手動返信
	private final String SEND_TYPE_FILE						= 'ファイル';		// 送信種別：ファイル
	private final String SEND_TYPE_MESSAGE					= 'メッセージ';		// 送信種別：メッセージ

	/** パラメータ */
	public Id paramCorrespondId {get; set;} // 対応ID
	public Id paramLineMemberId {get; set;} // LINE会員ID

	/** 画面項目 */
	public ScreenLineMemberInfo			screenLineMemberInfo		{get; set;} // LINE会員情報
	public screenFavoriteProperty		screenFavoriteProperty		{get; set;} // お気に入り物件 
	public ScreenPropertyUrlGenerate	screenPropertyUrlGenerate	{get; set;} // 物件URL生成
	public ScreenFixedPhrase			screenFixedPhrase			{get; set;} // 定型文情報
	public ScreenExampleSentence		screenExampleSentence		{get; set;} // 文例情報
	public List<ScreenMessageHistory>	screenMessageHistory		{get; set;} // メッセージ履歴
	public ScreenSendMessage			screenSendMessage			{get; set;} // メッセージ送信

	/** メッセージ格納クラス */
	public Msgs msgs {get; set;}

	/** 処理結果用項目 */
	public String issueUrl			{get; set;} // 発行URL
	public String jsReplaceBreakCd	{get; set;}	// JS置換用改行コード

	/** モーダル画面用パラメータ */
	public GL101001Modal1ParameterClass gL101001Modal1Parameter {get; set;} // 定型文選択
	public GL101001Modal2ParameterClass gL101001Modal2Parameter {get; set;} // 文例集選択
	public GL101001Modal3ParameterClass gL101001Modal3Parameter {get; set;} // ファイル送信

	/** フラグ */
	public Boolean isOpenError				{get; set;} // エラーフラグ
	public Boolean hasErrorMessage			{get; set;} // エラーメッセージ保有フラグ
	public Boolean authorityOptionPortalFlg	{get; set;} // 自社ポータルの権限フラグ
	public Boolean ResponseConfirmationFlg  {get; set;} // 対応済を行ったかどうかのフラグ 2022.04.20 No0768 対応で追加

	/** スタイル */
	public String classLinkDisabled {get; set;} // リンク無効クラス

	/**
	 * コンストラクタ
	 */
	public GL101001Controller() {

		try {
			BusinessLogicException ex = new BusinessLogicException();

			// パラメータの初期化
			this.setInitParam();

			// ログインユーザの所属店舗の取得（※取得できない場合、例外をスロー）
			CommonUtil.getStaffCurrentShop();

			// LINE会員情報の設定
			if (!this.setScreenLineMemberInfo()) {
				ex.addMessage(this.msgs.getSystemParameterErr());
				throw ex;
			}

			// お気に入り物件の設定
			this.setScreenFavoriteProperty();

			// 物件URL生成の設定
			this.screenPropertyUrlGenerate = new ScreenPropertyUrlGenerate();

			// 定型文の設定
			List<FixedPhrase__c> fixedPhraseList = this.selectFixedPhrase();
			this.screenFixedPhrase = new ScreenFixedPhrase(fixedPhraseList);

			// 文例集の設定
			List<ExampleSentence__c> exampleSentenceList = this.selectExampleSentence();
			this.screenExampleSentence = new ScreenExampleSentence(exampleSentenceList);

			// メッセージ履歴の設定
			this.setScreenMessageHistory();

			// メッセージ送信の設定
			this.screenSendMessage = new ScreenSendMessage();

		} catch(Exception e) {
			// 初期表示エラーフラグの更新
			this.isOpenError = true;

			// エラーメッセージの設定・表示
			CommonUtil.setErrorMessage(e);

			// リンクの無効設定
			this.classLinkDisabled = 'link-disabled';
		}
	}

	/**
	 * 対応済ボタン押下
	 */
	public void clickDoneCorrespond() {

		Savepoint sp = Database.setSavepoint();
		this.hasErrorMessage = false;

		try {
			//▼ 2022.04.20 No0768 対応で追加
			this.ResponseConfirmationFlg = false;	//対応済を行ったかどうかのフラグ
			Id loginStaff = UserInfo.getUserId();     // ログインユーザ
			Id loginUserProfileId = UserInfo.getProfileId();	//ユーザのプロファイルを取得
			//システム管理者、システム管理者カスタムのプロファイルIDを取得
			Id adminProfileId= [SELECT Id FROM Profile	WHERE Name = :CommonConst.PROFILE_SYSTEM_ADMINISTRATOR].id;
			List<Profile> adminCustomProfiles = [SELECT Id FROM Profile	WHERE Name = :CommonConst.PROFILE_SYSTEM_ADMINISTRATOR_CUSTOM];
			Id adminCustomProfileId = adminCustomProfiles.isEmpty() ? null : adminCustomProfiles[0].Id;

			// 対応の反響担当者、来店担当者両方が存在しない
			// ログインユーザが反響、来店以外のユーザ、管理者のユーザーの場合スルー
			if (!(this.screenLineMemberInfo.correspond.EchoStaff__c == null && this.screenLineMemberInfo.correspond.ShopStaff__c == null)) {
				if(!(loginStaff == this.screenLineMemberInfo.correspond.EchoStaff__c ||loginStaff == this.screenLineMemberInfo.correspond.ShopStaff__c || loginUserProfileId == adminProfileId || loginUserProfileId  == adminCustomProfileId)){
					return;
				}
			}
			//▲ 2022.04.20 No0768 対応で追加

			// 楽観ロックチェック
			if (!this.isDoneCorrespondOptimisticLock()) {
				throw new OptimisticLockException();
			}

			// 対応の更新
			this.updCorrespondDoneCorrespond(this.screenLineMemberInfo.correspond); // 2022.04.20 No0768 対応で変更

			// LINE会員の更新
			this.updLineMemberDoneCorrespond(this.screenLineMemberInfo.lineMemberId);

			// LINE会員情報の設定
			this.setScreenLineMemberInfo();

			this.ResponseConfirmationFlg = true;	// 2022.04.20 No0768 対応で追加
		} catch(Exception e) {
			// エラーメッセージの表示・設定
			this.hasErrorMessage = true;
			CommonUtil.setErrorMessage(e);

			// ロールバック
			Database.rollback(sp);
		}
	}

	/**
	 * 紐づけ解除ボタン押下
	 */
	public void clickReleaseLinking() {

		Savepoint sp = Database.setSavepoint();
		this.hasErrorMessage = false;

		try {
			// 楽観ロックチェック
			if (!this.isReleaseLinkingOptimisticLock()) {
				throw new OptimisticLockException();
			}

			// オブジェクト処理
			this.crudReleaseLinking();

			// LINE会員情報の設定
			this.setScreenLineMemberInfo();

			// お気に入り物件の設定
			this.setScreenFavoriteProperty();

		} catch(Exception e) {
			// エラーメッセージの表示・設定
			this.hasErrorMessage = true;
			CommonUtil.setErrorMessage(e);

			// ロールバック
			Database.rollback(sp);
		}
	}

	/**
	 * 発行ボタン（お気に入り物件）押下処理
	 */
	public void clickFavoritePropertyIssue() {

		Savepoint sp = Database.setSavepoint();
		this.hasErrorMessage = false;

		try {
			// リダイレクトURL
			String redirectUlr;

			// クリップボードコピー用の物件URLの作成
			this.issueUrl = CommonConst.STRING_EMPTY;
			for(FavoritePropertyDetail favoritePropertyDetail : this.screenFavoriteProperty.favoritePropertyDetailList){
				
				// 未選択チェック
				if(!favoritePropertyDetail.isSelected){
					continue;
				}

				// リダイレクトURLの取得
				redirectUlr = MailUtil.getRedirectUrl(
					favoritePropertyDetail.propertyURL
					, favoritePropertyDetail.propertyDetail
					, this.screenLineMemberInfo.accountId
					, this.screenLineMemberInfo.correspond.Id
					, true
					, false
				);
				
				// クリップボード値の取得
				this.issueUrl +=
					CommonUtil.callMessageCreate(
						'{0}<br>{1}<br><br>',
						favoritePropertyDetail.propertyDetail,
						redirectUlr
					);
			}

			// リダイレクトURLオブジェクトの一括処理（※ガバナ制限回避の為）
			MailUtil.redirectUrlBulkDml();

		} catch(Exception e) {
			// エラーメッセージの表示・設定
			this.hasErrorMessage = true;
			CommonUtil.setErrorMessage(e);

			// ロールバック
			Database.rollback(sp);
		}
	}

	/**
	 * 発行（物件URL生成）押下処理
	 */
	public void clickPropertyUrlGenerateIssue() {

		Savepoint sp = Database.setSavepoint();
		this.hasErrorMessage = false;
		
		try {
			// 物件URLの作成
			this.issueUrl = 
				this.screenPropertyUrlGenerate.propertyDetail + '<br>' 
				+ MailUtil.getRedirectUrl(
					this.screenPropertyUrlGenerate.propertyURL
					, this.screenPropertyUrlGenerate.propertyDetail
					, this.screenLineMemberInfo.accountId
					, this.screenLineMemberInfo.correspond.Id
					, false
					, true
				);

		} catch(Exception e) {
			// エラーメッセージの表示・設定
			this.hasErrorMessage = true;
			CommonUtil.setErrorMessage(e);

			// ロールバック
			Database.rollback(sp);
		}
	}

	/**
	 * 定型文押下処理
	 */
	public void clickFixedPhrase() {

		Savepoint sp = Database.setSavepoint();
		this.hasErrorMessage = false;

		try {
			// 選択されたフォルダ、定型文を取得
			List<FixedPhraseValue> fixedPhraseList = this.screenFixedPhrase.fixedPhraseMap.get(this.screenFixedPhrase.selectedKey);
			FixedPhraseValue fixedPhraseValue = fixedPhraseList[this.screenFixedPhrase.selectedValueIdx];

			// 本文の置換処理
			String replaceVal = MailUtil.getMailReplaceText(
				fixedPhraseValue.text
				, this.screenLineMemberInfo.correspond.Id
			);

			// 新規メッセージへの設定（※改行コードをJS用に置換）
			this.screenFixedPhrase.replaceVal = replaceVal.replaceAll(
				CommonConst.LINE_FEED
				, CommonConst.LINE_EXCLUSIVE_JS_BREAK_CD
			);

		} catch(Exception e) {
			// エラーメッセージの表示・設定
			this.hasErrorMessage = true;
			CommonUtil.setErrorMessage(e);

			// ロールバック
			Database.rollback(sp);
		}
	}

	/**
	 * 定型文選択モーダルの起動処理
	 */
	public void openFixedPhraseSelectModal() {

		// モーダル起動準備
		this.gL101001Modal1Parameter = new GL101001Modal1ParameterClass();
		this.gL101001Modal1Parameter.screenFixedPhrase	= this.screenFixedPhrase;
		this.gL101001Modal1Parameter.correspondId		= this.screenLineMemberInfo.correspond.Id;
		this.gL101001Modal1Parameter.isDrawing			= true;
		this.gL101001Modal1Parameter.noFirst			= true;
	}

	/**
	 * 文例集選択モーダルの起動処理
	 */
	public void openExampleSentenceSelectModal() {

		// モーダル起動準備
		this.gL101001Modal2Parameter = new GL101001Modal2ParameterClass();
		this.gL101001Modal2Parameter.screenExampleSentence	= this.screenExampleSentence;
		this.gL101001Modal2Parameter.isDrawing				= true;
		this.gL101001Modal2Parameter.noFirst				= true;
	}

	/**
	 * ファイル送信モーダルの起動処理
	 */
	public void openSendFileModal() {

		// モーダル起動準備
		this.gL101001Modal3Parameter = new GL101001Modal3ParameterClass();
		this.gL101001Modal3Parameter.isDrawing	= true;
		this.gL101001Modal3Parameter.noFirst	= true;
		this.gL101001Modal3Parameter.lineId		= this.screenLineMemberInfo.lineId;
	}

	/**
	 * メッセージ送信ボタン押下処理
	 */
	public void clickSendMsg() {

		Savepoint sp;
		this.hasErrorMessage = false;

		try {
			// 楽観ロックチェック
			if (!this.isSendLineOptimisticLock()) {
				throw new OptimisticLockException();
			}

			// LINE送信処理
			LineMessagingApiUtil.sendTextMsg(
				this.screenLineMemberInfo.lineId
				, this.screenSendMessage.newMessage
				, CommonConst.LINE_FEED
			);

			// 外部APIのコールアウト対応の為、このタイミングで作成
			sp = Database.setSavepoint();

			// オブジェクト処理
			this.crudSendLine(true);

			// LINE会員情報の設定
			this.setScreenLineMemberInfo();

			// メッセージ履歴の設定
			this.setScreenMessageHistory();

			// メッセージ送信
			this.screenSendMessage = new ScreenSendMessage();

		} catch(Exception e) {
			// エラーメッセージの表示・設定
			this.hasErrorMessage = true;
			CommonUtil.setErrorMessage(e);

			// ロールバック
			if (sp != null) {
				Database.rollback(sp);
			}
		}
	}

	/**
	 * LINEへのファイル送信処理
	 */
	public void sendFileLineProcess() {

		Savepoint sp;
		this.hasErrorMessage = false;

		try {
			// 楽観ロックチェック
			if (!this.isSendLineOptimisticLock()) {
				throw new OptimisticLockException();
			}

			// LINEのファイル送信
			this.sendLineFile();

			// 外部APIのコールアウト対応の為、このタイミングで作成
			sp = Database.setSavepoint();

			// オブジェクト処理
			this.crudSendLine(false);

			// LINE会員情報の設定
			this.setScreenLineMemberInfo();

			// メッセージ履歴の設定
			this.setScreenMessageHistory();

		} catch(Exception e) {
			// エラーメッセージの表示・設定
			this.hasErrorMessage = true;
			CommonUtil.setErrorMessage(e);

			// ロールバック
			if (sp != null) {
				Database.rollback(sp);
			}
		}
	}

	/**
	 * LINE入力文字数の取得
	 * @return Decimal LINE入力文字数
	 */
	public Decimal getLineInputLength() {

		Decimal lineInputLength = SystemConfig__c.getInstance().LineInputLength__c;
		if (lineInputLength == null) {
			lineInputLength = 1000;
		}

		return lineInputLength;
	}

	/**
	 * パラメータの初期化
	 */
	private void setInitParam() {

		// フラグ
		this.isOpenError	 = false;
		this.hasErrorMessage = false;

		// メッセージ格納クラス
		this.msgs = new Msgs();

		// 処理結果用項目
		this.issueUrl			= CommonConst.STRING_EMPTY;
		this.jsReplaceBreakCd	= CommonConst.LINE_EXCLUSIVE_JS_BREAK_CD;

		// スタイル
		this.classLinkDisabled = CommonConst.STRING_EMPTY;

		// 自社ポータルサイトの権限
		this.authorityOptionPortalFlg = AuthorityCheckUtil.getAuthorityOptionPortal(false);

		// Getパラメータ
		this.paramCorrespondId = ApexPages.currentPage().getParameters().get('correspondId');
		this.paramLineMemberId = ApexPages.currentPage().getParameters().get('lineMemberId');
	}

	/**
	 * LINE会員情報の設定
	 * @return true:LINE会員有り、false:LINE会員無し
	 */
	private Boolean setScreenLineMemberInfo() {

		// 初期化
		this.screenLineMemberInfo = new ScreenLineMemberInfo();

		// LINE会員情報の存在チェック
		LineMember__c lineMember = this.selectLineMember(this.paramLineMemberId);
		if (String.isBlank(lineMember.Id)) {
			return false;
		}

		// 対応の存在チェック
		Correspond__c correspond = this.selectCorrespond(this.paramCorrespondId);
		if (String.isBlank(correspond.Id)) {
			return false;
		}

		// LINE会員候補の取得
		LineMemberCandidate__c lineMemberCandidate = this.selectLineMemberCandidate(lineMember.Account__c);

		// 紹介メール情報の取得
		IntroductionMailInformation__c introductionMailInformation = this.selectIntroductionMailInformation(lineMember.Account__c);
		
		// LINE会員情報の設定
		this.screenLineMemberInfo = new ScreenLineMemberInfo(
			lineMember
			, correspond
			, lineMemberCandidate
			, introductionMailInformation
		);

		return true;
	}

	/**
	 * メッセージ履歴の設定
	 */
	private void setScreenMessageHistory() {

		// 初期化
		this.screenMessageHistory = new List<ScreenMessageHistory>();

		// メッセージ履歴の設定（送信時刻の降順で取得し、昇順で表示）
		List<LineHistory__c> lineHistoryList = this.selectLineHistory(this.screenLineMemberInfo.lineMemberId);
		for (Integer idx = lineHistoryList.size(); idx > 0; idx--) {
			this.screenMessageHistory.add(new ScreenMessageHistory(lineHistoryList[idx - 1]));
		}
	}

	/**
	 * お気に入り物件の設定
	 */
	private void setScreenFavoriteProperty() {

		// 初期化
		this.screenFavoriteProperty = new ScreenFavoriteProperty(this.authorityOptionPortalFlg);

		// お気に入り物件の取得
		List<FavoriteProperty__c> favoritePropertyList;
		favoritePropertyList = this.selectFavoriteProperty(this.screenLineMemberInfo.accountId);

		// お気に入り物件.物件の取得
		Set<Id> propertyIdSet = new Set<Id>();
		for (FavoriteProperty__c favoriteProperty : favoritePropertyList) {
			propertyIdSet.add(favoriteProperty.Property__c);
		}

		// ポータルサイト掲載物件の取得
		List<PortalSitePostingProperty__c> portalSitePostingPropertyList;
		portalSitePostingPropertyList = this.selectPortalSitePostingProperty(propertyIdSet);

		// 選択可能物件IDの取得
		Set<Id> chooseablePropertyIdSet = new Set<Id>();
		for (PortalSitePostingProperty__c portalSitePostingProperty : portalSitePostingPropertyList) {
			if (portalSitePostingProperty.IsPortal__c) {
				chooseablePropertyIdSet.add(portalSitePostingProperty.Property__c);
			}
		}

		// お気に入り物件（明細）の設定
		for (FavoriteProperty__c favoriteProperty : favoritePropertyList) {
			this.screenFavoriteProperty.addDetailList(
				favoriteProperty,
				CommonConst.PORTAL_SITE_URL_DETAIL,
				chooseablePropertyIdSet.contains(favoriteProperty.Property__c)
			);
		}

		// タブ切り替え可否フラグの設定
		this.screenFavoriteProperty.setCanSwitchTab();
	}

	/**
	 * LINEのファイル送信
	 */
	private void sendLineFile() {

		// 拡張子に応じた送信処理の実施
		String extension = LineMessagingApiUtil.getExtension(this.gL101001Modal3Parameter.fileName);
		if (LineMessagingApiUtil.getVideoExtension().contains(extension)) {
			// 動画
			LineMessagingApiUtil.sendVideoMsg(
				this.screenLineMemberInfo.lineId
				, this.gL101001Modal3Parameter.filePath
				, this.gL101001Modal3Parameter.thumbnailPath
			);
		} else if (LineMessagingApiUtil.getImgExtension().contains(extension)) {
			// 画像
			LineMessagingApiUtil.sendImgMsg(
				this.screenLineMemberInfo.lineId
				, this.gL101001Modal3Parameter.filePath
				, this.gL101001Modal3Parameter.filePath
			);
		} else {
			// ファイル
			LineMessagingApiUtil.sendFileMsg(
				this.screenLineMemberInfo.lineId
				, this.gL101001Modal3Parameter.fileName
				, this.gL101001Modal3Parameter.filePath
			);
		}
	}

	/**
	 * 対応済処理時の楽観ロックチェック
	 * @return Boolean true:更新無し、false:更新有り
	 */
	private Boolean isDoneCorrespondOptimisticLock() {

		// LINE会員
		if (!CommonUtil.isOptimisticLock(this.screenLineMemberInfo.lineMember)) {
			return false;
		}

		// 対応
		if (!CommonUtil.isOptimisticLock(this.screenLineMemberInfo.correspond)) {
			return false;
		}

		return true;
	}

	/**
	 * 紐づけ処理時の楽観ロックチェック
	 * @return Boolean true:更新無し、false:更新有り
	 */
	private Boolean isReleaseLinkingOptimisticLock() {

		// LINE会員
		if (!CommonUtil.isOptimisticLock(this.screenLineMemberInfo.lineMember)) {
			return false;
		}

		// LINE会員候補
		if (!CommonUtil.isOptimisticLock(this.screenLineMemberInfo.lineMemberCandidate)) {
			return false;
		}

		// 対応
		if (!CommonUtil.isOptimisticLock(this.screenLineMemberInfo.correspond)) {
			return false;
		}

		// 紹介メール情報
		if (!CommonUtil.isOptimisticLock(this.screenLineMemberInfo.introductionMailInformation)) {
			return false;
		}

		return true;
	}

	/**
	 * LINE送信時の楽観ロックチェック
	 * @return Boolean true:更新無し、false:更新有り
	 */
	private Boolean isSendLineOptimisticLock() {

		// LINE会員
		if (!CommonUtil.isOptimisticLock(this.screenLineMemberInfo.lineMember)) {
			return false;
		}

		// 対応
		if (!CommonUtil.isOptimisticLock(this.screenLineMemberInfo.correspond)) {
			return false;
		}

		return true;
	}

	/**
	 * 定型文の取得
	 * @return List<FixedPhrase__c> 定型文
	 */
	private List<FixedPhrase__c> selectFixedPhrase() {

		List<FixedPhrase__c> fixedPhraseList;
		fixedPhraseList = [
			SELECT
				Name,
				Folder__c,
				Text__c
			FROM FixedPhrase__c
			WHERE
				Folder__c != null
				AND UsageScreen__c = :CommonConst.FIXEDPHRASE_LINE_EXCLUSIVE
			ORDER BY 
				Folder__c,
				Name
			LIMIT 1000
		];

		if (fixedPhraseList.isEmpty()) {
			fixedPhraseList = new List<FixedPhrase__c>();
		}

		return fixedPhraseList;
	}

	/**
	 * 文例の取得
	 * @return List<ExampleSentence__c> 文例
	 */
	private List<ExampleSentence__c> selectExampleSentence() {

		List<ExampleSentence__c> exampleSentenceList = [
			SELECT
				Name,
				Folder__c,
				ExampleSentence__c
			FROM ExampleSentence__c
			WHERE
				Folder__c != null
				AND UsageScreen__c = :CommonConst.EXAMPLESENTENCE_LINE_EXCLUSIVE
			ORDER BY
				Folder__c
				, Name
			LIMIT 1000
		];

		if (exampleSentenceList.isEmpty()) {
			exampleSentenceList = new List<ExampleSentence__c>();
		}

		return exampleSentenceList;
	}

	/**
	 * お気に入り物件の取得
	 * @param Id condAccountId 取引先ID
	 * @return List<FavoriteProperty__c> お気に入り物件
	 */
	private List<FavoriteProperty__c> selectFavoriteProperty(Id condAccountId) {

		List<FavoriteProperty__c> favoritePropertyList = [
			SELECT
				Id,
				Account__c,
				Property__c,
				Property__r.Name,
				Property__r.PropertyCode__c,
				Property__r.Building__c,
				Property__r.Building__r.Name,
				Property__r.Building__r.City__c,
				Property__r.Building__r.TrainRoute1__r.Name,
				Property__r.Building__r.Station1__r.name,
				Property__r.Building__r.StationWalkTime1__c
			FROM FavoriteProperty__c
			WHERE Account__c = :condAccountId
			ORDER BY
				Property__r.Building__r.BuildingAge__c DESC,
				Property__r.Building__r.Name,
				Property__r.Name
			LIMIT 1000
		];

		if (favoritePropertyList.isEmpty()) {
			favoritePropertyList = new List<FavoriteProperty__c>();
		}

		return favoritePropertyList;
	}

	/**
	 * ポータルサイト掲載物件の取得
	 * @param Set<Id> condPropertyIdSet	物件Id
	 * @return List<PortalSitePostingProperty__c> ポータルサイト掲載物件
	 */
	private List<PortalSitePostingProperty__c> selectPortalSitePostingProperty(Set<Id> condPropertyIdSet){

		List<PortalSitePostingProperty__c> portalSitePostingPropertyList = [
			SELECT
				Property__c,
				IsPortal__c
			FROM PortalSitePostingProperty__c
			WHERE Property__c in :condPropertyIdSet
		];

		if(portalSitePostingPropertyList.isEmpty()){
			portalSitePostingPropertyList = new List<PortalSitePostingProperty__c>();
		}

		return portalSitePostingPropertyList;
	}

	/**
	 * LINE会員の取得
	 * @param Id condId LINE会員ID
	 * @return LineMember__c LINE会員
	 */
	private LineMember__c selectLineMember(Id condId) {

		List<LineMember__c> lineMemberList = [
			SELECT
				Id,
				SystemModstamp,
				Name,
				Account__c,
				Account__r.Name,
				Status__c,
				LineId__c
			FROM LineMember__c
			WHERE Id = :condId
		];

		if (lineMemberList.isEmpty()) {
			return new LineMember__c();
		}

		return lineMemberList[0];
	}

	/**
	 * LINE会員候補の取得
	 * @param Id condAccountId 取引先ID
	 * @return LineMember__c LINE会員候補
	 */
	private LineMemberCandidate__c selectLineMemberCandidate(Id condAccountId) {

		List<LineMemberCandidate__c> lineMemberCandidateList = [
			SELECT
				Id,
				SystemModstamp
			FROM LineMemberCandidate__c
			WHERE Account__c = :condAccountId
		];

		if (lineMemberCandidateList.isEmpty()) {
			return new LineMemberCandidate__c();
		}

		return lineMemberCandidateList[0];
	}

	/**
	 * 紹介メール情報の取得
	 * @param Id condAccountId 取引先ID
	 * @return IntroductionMailInformation__c 紹介メール情報
	 */
	private IntroductionMailInformation__c selectIntroductionMailInformation(Id condAccountId) {

		List<IntroductionMailInformation__c> objList = [
			SELECT
				Id,
				SystemModstamp
			FROM IntroductionMailInformation__c
			WHERE Account__c = :condAccountId
		];

		if (objList.isEmpty()) {
			return new IntroductionMailInformation__c();
		}

		return objList[0];
	}

	/**
	 * LINE履歴の取得
	 * @param Id condId LINE会員ID
	 * @return List<LineHistory__c> LINE履歴
	 */
	private List<LineHistory__c> selectLineHistory(Id condLineMemberId) {

		List<LineHistory__c> lineHistoryList = [
			SELECT 
				Message__c,
				SendType__c,
				SendTime__c,
				FileName__c,
				FileURL__c,
				ThumbnailName__c,
				ThumbnailURL__c
			FROM LineHistory__c
			WHERE LineMember__c = :condLineMemberId
			ORDER BY SendTime__c DESC
			LIMIT 1000
		];

		if (lineHistoryList.isEmpty()) {
			lineHistoryList = new List<LineHistory__c>();
		}

		return lineHistoryList;
	}

	/**
	 * 対応の取得
	 * @param Id condId 対応ID
	 * @return Correspond__c 対応
	 */
	private Correspond__c selectCorrespond(Id condId) {

		List<Correspond__c> correspondList = [
			SELECT 
				Id,
				SystemModstamp,
				Status__c,
				LineMember__c,
				LineSmsSendDate__c,
				LineReceiveDate__c,
				LineFriendAddDate__c,
				EventDateTime__c,
				StaffSupportedFlg__c,
				ListViewDate__c,
				EchoStaff__c,
				ShopStaff__c,
				EchoShop__c,
				EchoShop__r.Email__c,
				VisitShop__c ,
                FirstLineAddFlg__c // 初回LINE追加フラグ 2022.04.14 No0758 対応で追加
			FROM Correspond__c
			WHERE Id = :condId
		];

		if (correspondList.isEmpty()) {
			return new Correspond__c();
		}
		
		return correspondList[0];
	}

	/**
	 * 指定された対応IDを除く取引先の対応の取得
	 * @param Id condAccountId	取引先ID
	 * @param Id condExceptId	取得対象外の対応ID
	 * @return List<Correspond__c> 対応
	 */
	private List<Correspond__c> selectExceptOwnAccountCorrespond(
		Id condAccountId
		, Id condExceptId
	) {

		// 2022.04.20 No0768 対応で変更、SOQLの項目追加と条件の変更とソート順
		List<Correspond__c> correspondList = [
			SELECT
				Id
				, LineMember__c
				, Status__c
				, EchoShop__c
				, FirstLineAddFlg__c
			FROM Correspond__c
			WHERE
				AccountId__c = :condAccountId
				AND Id != :condExceptId
			ORDER BY 
				EventDateTime__c DESC
		];

		return correspondList;
	}

	//▼ 2022.04.14 No0758 対応で追加
	/**
	 * 対応明細の移動対象取得
	 * LINE追加、LINE受信、自動返信(LINE)が対象（閲覧あり（LINEリダイレクト）は工数上で除外）
	 * @param Id accountId	取引先ID
	 * @param Id lineMemberId	LINE会員ID
	 * @return List<CorrespondDetail__c> 対応明細
	 */
	private List<CorrespondDetail__c> selectChangeCorrespond(
		Id accountId
		, Id lineMemberId
		) {

		List<CorrespondDetail__c> CorrespondDetailList = [
			SELECT
				Id
				, Corresponds__c
			FROM CorrespondDetail__c
			WHERE				
				// LINE送信、自動返信(LINE)
				// メール種別＝送信
				// 対応種別＝LINE or 自動返信(LINE)
				(Corresponds__r.AccountId__c = :accountId
				 AND MailType__c = :CommonConst.CORRESPONDDETAIL_MAILTYPE_SEND	
				 AND(CorrespondType__c = :CommonConst.TASK_CORRESPONDTYPE_LINE
					 OR CorrespondType__c = :CommonConst.TASK_CORRESPONDTYPE_AUTO_RECIVE_LINE)
				)	
				OR 
				// LINE受信 
				// 対応．取引先＝一致
				// 反響メール．LINE会員＝一致
				(Corresponds__r.AccountId__c = :accountId
				AND EchoMail__r.LineMember__c = :lineMemberId)
		];
		return CorrespondDetailList;
	}
	//▲ 2022.04.14 No0758 対応で追加

	/**
	 * 対応済時の対応の更新
	 * @param Id correspondId 対応ID
	 */
	private void updCorrespondDoneCorrespond(Correspond__c correspond) {

		// ステータスに応じた更新値の取得 2022.04.20 No0768 対応でステータスの設定を除外
		DateTime	updEventDateTime	= CustomerUtil.setListViewDateWhenCorrespondCheck(correspond.Status__c, correspond.id);

		// 更新値の設定 2022.04.20 No0768 対応でステータスの設定を除外
		Correspond__c updateCorrespond = new Correspond__c(
			Id						= correspond.id
			, IsBrowseFlg__c		= true				// 閲覧フラグ
			, ListViewDate__c		= updEventDateTime	// 一覧表示日時
			, StaffSupportedFlg__c  = true				// スタッフ対応フラグ
			, IsSupportedListShow__c= true				// 対応確認  2022.04.20 No0768 対応で追加
			, EventDateTime__c 		= CommonUtil.getNow()	// イベント時刻   
		);

		// 対応の更新
		SecureDML.secureUpdate(updateCorrespond);
	}

	/**
	 * 対応済時のLINE会員の更新
	 * @param Id lineMemberId LINE会員ID
	 */
	private void updLineMemberDoneCorrespond(Id lineMemberId) {

		// 更新値の設定
		LineMember__c lineMember = new LineMember__c();
		lineMember.Id			= lineMemberId;
		lineMember.Status__c	= CommonConst.LINE_MEMBER_STATUS_DONE_CORRESPOND;

		// LINE会員の更新
		SecureDML.secureUpdate(lineMember);
	}

	/**
	 * 紐づけ解除時のオブジェクト処理
	 */
	private void crudReleaseLinking() {

		//▼ 2022.04.14 No0758 対応で変更
		// 対応のコピー
		Correspond__c copyCorrespond = this.updCorrespondReleaseLinking(
			this.screenLineMemberInfo.correspond
			, this.screenLineMemberInfo.accountId
		);
		//▲ 2022.04.14 No0758 対応で変更
		//▼ 2022.05.25 No0827 対応で変更
		// 対応IDを入れなおす。
		if(copyCorrespond.id != null){
			this.paramCorrespondId = copyCorrespond.id;
		}
		//▲ 2022.05.25 No0827 対応で変更

		// 対応明細の新規作成
		this.createCorrespondDetailReleaseLinking(this.screenLineMemberInfo.accountId);

		//▼ 2022.04.14 No0758 対応で追加
		// 対応明細の移動
		this.changeCorrespondDetailReleaseLinking(this.screenLineMemberInfo.accountId,this.screenLineMemberInfo.lineMemberId,this.screenLineMemberInfo.correspond.Id,copyCorrespond);
		//▲ 2022.04.14 No0758 対応で追加
		// LINE会員の更新
		this.updLineMemberReleaseLinking(this.screenLineMemberInfo.lineMemberId);

		// LINE会員候補の更新
		this.updLineMemberCandidateReleaseLinking(this.screenLineMemberInfo.lineMemberCandidateId);

		// 紹介メール情報の更新
		if (String.isNotBlank(this.screenLineMemberInfo.introductionMailInformation.Id)) {
			this.updIntroductionMailInformationReleaseLinking(this.screenLineMemberInfo.introductionMailInformation.Id);
		}
	}

	//▼ 2022.04.14 No0758 対応で変更
	/**
	 * 紐づけ解除時の対応の更新
	 * @param Correspond__c correspondData	対応
	 * @param Id accountId		取引先ID
	 * @return Correspond__c コピーされた対応ID
	 */
	private Correspond__c updCorrespondReleaseLinking(Correspond__c correspondData, Id accountId) {

		// 指定された対応以外の有無
		List<Correspond__c> exceptOwnList = selectExceptOwnAccountCorrespond(accountId, correspondData.Id);
		Integer aliveCorrespondCount = 0;	// 対応の紐づけ解除時の反映対象有無
		List<Correspond__c> upsertCorrespondList = new List<Correspond__c>();
		for (Correspond__c exceptOwn : exceptOwnList) {
			// 現在の取引先の対応で有効な対応を取得
			if (!CustomerUtil.notApplicableStatus.contains(exceptOwn.Status__c)) {
				aliveCorrespondCount += 1;
			}
			// 現対応以外のLINE会員の紐づけを外す
			if (exceptOwn.lineMember__c != null) {
				aliveCorrespondCount -= 1;
				exceptOwn.lineMember__c = null;
				exceptOwn.FirstLineAddFlg__c = false;	// 初回LINE追加フラグ
				upsertCorrespondList.add(exceptOwn);
			}
		}

		Correspond__c newCorrespondLine = new Correspond__c();
		Correspond__c correspond = new Correspond__c();
		// 初回LINE追加フラグがセットされている対応以外で有効な対応が無ければ対応をコピーする
		if(aliveCorrespondCount <= 0){
			newCorrespondLine.Status__c = CommonConst.CORRESPOND_STATUS_PURSUIT; // ステータス、追客中に設定する
			newCorrespondLine.LineMember__c = correspondData.LineMember__c; // LINE会員
			newCorrespondLine.LineReceiveDate__c = correspondData.LineReceiveDate__c; // LINE受信日時
			newCorrespondLine.LineFriendAddDate__c = correspondData.LineFriendAddDate__c; // LINEお友達登録日時
			newCorrespondLine.FirstLineAddFlg__c = true;  // 初回LINE追加フラグ
			newCorrespondLine.IsEchoNotCalculation__c = true; // 反響数非計算フラグ
			newCorrespondLine.IsVisitNotCalculation__c = true; // 来店数非計算フラグ

			upsertCorrespondList.add(newCorrespondLine);
			// コピー元の対応のLINE会員を外す。
			correspond = new Correspond__c(
				Id				= correspondData.id ,
				LineMember__c = null , // LINE会員
				IsBrowseFlg__c = true , // 閲覧フラグ
				FirstLineAddFlg__c = false ,// 初回LINE追加フラグ
				EventDateTime__c = CommonUtil.getNow() //イベント時刻
			);
			upsertCorrespondList.add(correspond);
		}else{
			// 有効な対応が存在するLINE会員の対応を取引先の紐づけを解除
			correspond = new Correspond__c(
				Id	= correspondData.id ,
				AccountId__c = null ,
				IsEchoNotCalculation__c = true, // 反響数非計算フラグ
				IsVisitNotCalculation__c = true, // 来店数非計算フラグ
				EventDateTime__c = CommonUtil.getNow() //イベント時刻
			);
			upsertCorrespondList.add(correspond);
		}
		if(upsertCorrespondList.size() > 0){
			SecureDML.secureUpsert(upsertCorrespondList);
		}
		
		return newCorrespondLine;	// 2022.04.14 No0758 対応で追加
	}

	/**
	 * 紐づけ解除時の対応明細作成
	 * @param Correspond__c correspond 対応
	 */
	private void createCorrespondDetailReleaseLinking(Id accountId) {
		// 対応更新後で有効な取引先の対応に明細を作成 // 2022.04.14 No0758 対応で変更設定する値を取得
		List<Correspond__c> exceptOwnList = selectExceptOwnAccountCorrespond(accountId, null);

		// 登録値の設定
		CorrespondDetail__c correspondDetail = new CorrespondDetail__c(
			Corresponds__c			= exceptOwnList[0].Id
			, CorrespondType__c		= CommonConst.TASK_CORRESPONDTYPE_LINE
			, SupportedDateTime__c	= CommonUtil.getNow()
			, SupportedTitle__c		= this.SUPPORTED_TITLE_RELEASE_LINKING
			, Shop__c				= exceptOwnList[0].EchoShop__c
			, Staff__c				= UserInfo.getUserId()
			, SupportedContent__c	=
				'取引先との紐づけが解除されました。' + CommonConst.LINE_FEED
				+ CommonConst.LINE_FEED
				+ '【取引先名】:' + this.screenLineMemberInfo.accountName
		);

		// 対応明細の登録
		SecureDML.secureInsert(correspondDetail);
	}

	//▼ 2022.04.14 No0758 対応で追加
	/**
	 * 対応明細の移動
	 * @param Id accountId 取引先ID
	 * @param Id lineMemberId LINE会員ID
	 * @param Id copyCorrespondId コピーで作成された対応ID
	 */
	private void changeCorrespondDetailReleaseLinking(Id accountId, Id lineMemberId,Id correspondId,Correspond__c copyCorrespond) {
		List<CorrespondDetail__c> correspondDetailList = selectChangeCorrespond(accountId,lineMemberId);
		List<CorrespondDetail__c> updateCorrespondDetailList = new List<CorrespondDetail__c>();
		// 対応がコピーされている
		for (CorrespondDetail__c correspondDetail : correspondDetailList) {
			CorrespondDetail__c setCorrespondDetail = new CorrespondDetail__c();
			// 対応がコピーされていない場合
			if (copyCorrespond.Id == null ){
				// 取引先単位でLINEのやり取りが実施されていた対応明細を入れ替える
				if(correspondId != correspondDetail.Corresponds__c){
					setCorrespondDetail.Id = correspondDetail.Id;
					setCorrespondDetail.Corresponds__c = correspondId;
					updateCorrespondDetailList.add(setCorrespondDetail);
				}
			}else{
				setCorrespondDetail.Id = correspondDetail.Id;
				setCorrespondDetail.Corresponds__c = copyCorrespond.Id;
				updateCorrespondDetailList.add(setCorrespondDetail);
			}
			
		}

		// 対応明細の更新
		if(updateCorrespondDetailList.size() > 0){
			SecureDML.secureUpdate(updateCorrespondDetailList);
		}
		
	}
	//▲ 2022.04.14 No0758 対応で追加

	/**
	 * 紐づけ解除時のLINE会員の更新
	 * @param Id lineMemberId LINE会員ID
	 */
	private void updLineMemberReleaseLinking(Id lineMemberId) {

		// 更新値の設定
		LineMember__c lineMember = new LineMember__c(
			Id				= lineMemberId
			, Account__c	= null
		);

		// LINE会員の更新
		SecureDML.secureUpdate(lineMember);
	}

	/**
	 * 紐づけ解除時のLINE会員候補の更新
	 * @param Id lineMemberCandidateId LINE会員候補ID
	 */
	private void updLineMemberCandidateReleaseLinking(Id lineMemberCandidateId) {

		// 更新値の設定
		LineMemberCandidate__c lineMemberCandidate = new LineMemberCandidate__c(
			Id				= lineMemberCandidateId
			, IsLinking__c	= false
		);

		// LINE会員の更新
		SecureDML.secureUpdate(lineMemberCandidate);
	}

	/**
	 * 紐づけ解除時の紹介メール情報の更新
	 * @param Id lineMemberCandidateId LINE会員候補ID
	 */
	private void updIntroductionMailInformationReleaseLinking(Id introductionMailInformationId) {

		// 更新値の設定
		IntroductionMailInformation__c introductionMailInformation = new IntroductionMailInformation__c(
			Id				= introductionMailInformationId
			, IsSendLine__c	= false
		);

		// 紹介メール情報の更新
		SecureDML.secureUpdate(introductionMailInformation);
	}

	/**
	 * LINE送信時のオブジェクト処理
	 * @param Boolean	isSendMsg	メッセージ送信フラグ（true:メッセージ、false:ファイル）
	 */
	private void crudSendLine(Boolean isSendMsg) {

		// システム日付の取得
		Datetime sysDate = CommonUtil.getNow();

		// LINE会員の更新
		this.updLineMemberSendLine(this.screenLineMemberInfo.lineMemberId);

		// LINE履歴の新規作成
		this.createLineHistorySendLine(sysDate, isSendMsg);

		//▼ 2022.04.20 No0768 対応で追加
		//▼ 2022.05.25 No0827 対応で変更
		Correspond__c correspondData = new Correspond__c();
		correspondData = this.screenLineMemberInfo.correspond;
		if(this.screenLineMemberInfo.correspond.Status__c != CommonConst.CORRESPOND_STATUS_CLOSE){
			// 終了以外のステータスのみチェック
			// 対応の新規登録の制御
			correspondData = CustomerUtil.checkCorrespondLine(this.screenLineMemberInfo.lineMemberId,true);
		}
		//▲ 2022.05.25 No0827 対応で変更

		// 対応明細の新規作成
		this.createCorrespondDetailSendLine(correspondData, sysDate, isSendMsg);

		// 対応の更新
		if(this.screenLineMemberInfo.correspond.Id != correspondData.Id){
			// 対応が新規追加された際に元の対応を更新
			this.updCorrespondSendLine(this.screenLineMemberInfo.correspond.Id, sysDate,false);
		}else {
			this.updCorrespondSendLine(correspondData.id, sysDate,true);
		}
		//▲ 2022.04.20 No0768 対応で追加

		//▼ 2022.05.26 No0830 対応で追加
		// 再取得を新規、もしくは更新された対応のIDをセットする。
		this.paramCorrespondId = correspondData.Id;
		this.screenLineMemberInfo.correspondLineMemberId = correspondData.Id;
		//▲ 2022.05.26 No0830 対応で追加
	}

	/**
	 * LINE送信時のLINE会員更新
	 * @param Id lineMemberId LINE会員ID
	 */
	private void updLineMemberSendLine(Id lineMemberId) {

		// 更新値の設定
		LineMember__c lineMember = new LineMember__c(
			Id			= lineMemberId
			, Status__c	= CommonConst.LINE_MEMBER_STATUS_DONE_REPLIED
		);

		// LINE会員の更新
		SecureDML.secureUpdate(lineMember);
	}

	/**
	 * LINE送信時のLINE履歴作成
	 * @param Datetime	dateTimeVal 日付
	 * @param Boolean	isSendMsg	メッセージ送信フラグ（true:メッセージ、false:ファイル）
	 */
	private void createLineHistorySendLine(Datetime dateTimeVal, Boolean isSendMsg) {

		// 登録値の設定
		LineHistory__c lineHistory = new LineHistory__c(
			LineMember__c	= this.screenLineMemberInfo.lineMemberId
			, SendType__c	= CommonConst.LINE_HISTORY_SEND_TYPE_MANAGER
			, SendTime__c	= dateTimeVal
		);

		// 送信内容に応じた登録値の設定
		if (isSendMsg) {
			lineHistory.Message__c = this.screenSendMessage.newMessage;
		} else {
			lineHistory.Message__c			= this.gL101001Modal3Parameter.message;
			lineHistory.FileName__c			= this.gL101001Modal3Parameter.fileName;
			lineHistory.FileURL__c			= this.gL101001Modal3Parameter.filePath;
			lineHistory.ThumbnailName__c	= this.gL101001Modal3Parameter.thumbnailName;
			lineHistory.ThumbnailURL__c		= this.gL101001Modal3Parameter.thumbnailPath;
		}

		// LINE履歴の登録
		SecureDML.secureInsert(lineHistory);
	}

	/**
	 * LINE送信時の対応明細作成
	 * @param Correspond__c correspond	対応
	 * @param Datetime		dateTimeVal	日付
	 * @param Boolean		isSendMsg	メッセージ送信フラグ（true:メッセージ、false:ファイル）
	 */
	private void createCorrespondDetailSendLine(
		Correspond__c correspond
		, Datetime dateTimeVal
		, Boolean isSendMsg
	) {

		// 送信種別用（デフォルト：メッセージ送信）
		String sendType		= this.SEND_TYPE_MESSAGE;
		String sendContent	= this.screenSendMessage.newMessage;

		// ファイル送信チェック
		if (!isSendMsg) {
			sendType	= this.SEND_TYPE_FILE;
			sendContent	= this.gL101001Modal3Parameter.fileName;
		}

		// 登録値の設定
		CorrespondDetail__c correspondDetail = new CorrespondDetail__c(
			Corresponds__c			= correspond.Id
			, CorrespondType__c		= CommonConst.TASK_CORRESPONDTYPE_LINE
			, SupportedDateTime__c	= dateTimeVal
			, SupportedTitle__c		= this.SUPPORTED_TITLE_SEND_LINE
			, Shop__c				= correspond.EchoShop__c
			, Staff__c				= UserInfo.getUserId()
			, MailType__c			= CommonConst.CORRESPONDDETAIL_MAILTYPE_SEND
			, Email__c				= correspond.EchoShop__r.Email__c
			, SupportedContent__c	=
				sendType + 'を送信しました。' + CommonConst.LINE_FEED
				+ CommonConst.LINE_FEED
				+ sendContent
		);

		// 対応明細の登録
		SecureDML.secureInsert(correspondDetail);
	}

	/**
	 * LINE送信時の対応更新
	 * @param Id		correspondId 対応ID
	 * @param Datetime	dateTimeVal	 日付
	 * @param Boolean	isFirstLineAddFlg 初回LINE追加フラグ 2022.04.20 No0768 対応で追加
	 */
	private void updCorrespondSendLine(Id correspondId, Datetime dateTimeVal, Boolean isFirstLineAddFlg) {
		
		// ステータスに応じた更新値の取得
		String		updStatus			= CustomerUtil.changeSpecificStatus(correspondId);
		DateTime	updEventDateTime	= CustomerUtil.setListViewDateWhenCorrespondCheck(updStatus, correspondId);

		// 更新値の設定
		Correspond__c correspond = new Correspond__c(
			Id						= correspondId
			, Status__c				= updStatus
			, EventDateTime__c		= dateTimeVal
			, IsBrowseFlg__c		= true
			, ListViewDate__c		= updEventDateTime
			, LineSmsSendDate__c	= dateTimeVal
			, FirstLineAddFlg__c	= isFirstLineAddFlg  // 初回LINE追加フラグ 2022.04.20 No0768 対応で追加
		);

		// 対応の更新
		SecureDML.secureUpdate(correspond);
	}

	/**
	 * メッセージ格納クラス
	 */
	public class Msgs {

		/** メッセージ用項目 */
		private final String SEND_TYPE_FILE		= 'ファイル';	// 送信種別：ファイル
		private final String SEND_TYPE_MESSAGE	= 'メッセージ'; // 送信種別：メッセージ

		/** メッセージ */
		private final String MSG_SAVE_COMPLETED					= CommonConst.MSG_COM_I_SAVE;
		private final String MSG_UPDATE_DONE_CORRESPOND			= CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_UPDATE, '対応済で');
		private final String MSG_RELEASE_LINKING_COMPLETED		= CommonUtil.callMessageCreate(CommonConst.MSG_PROP_I_PROCESS_END, '紐づけ解除');
		private final String MSG_NO_SELECTED_FAVORITE_PROPERTY	= CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_NO_SELECTION, 'お気に入り物件');
		private final String MSG_NO_INPUT_URL					= CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_INPUT, '発行を行う場合' ,'URL');
		private final String MSG_REQUIRED_NEW_MESSAGE			= CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, '新規メッセージ');
		private final String MSG_SEND_MESSAGE_CONFIRM			= CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SEND_CONFIRM, this.SEND_TYPE_MESSAGE);
		private final String MSG_SEND_MESSAGE_COMPLETED			= CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SEND_COMPLETED, this.SEND_TYPE_MESSAGE);
		private final String MSG_SEND_FILE_COMPLETED			= CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SEND_COMPLETED, this.SEND_TYPE_FILE);
		private final String MSG_RELEASE_LINKING_CONFIRM		= CommonConst.MSG_ACC_I_RELEASE_LINKING_CONFIRM;
		private final String MSG_SYSTEM_PARAMETER_ERR			= CommonConst.MSG_COM_E_SYSTEM_PARAMETER;
		private final String MSG_COM_I_NO_RESPONSE_CONFIRMATION = CommonConst.MSG_COM_I_NO_RESPONSE_CONFIRMATION;  // 対応済不可メッセージ 2022.04.20 No0768 対応で追加

		/** 保存完了 */
		public String getSaveCompleted() {
			return this.MSG_SAVE_COMPLETED;
		}

		/** 対応済への更新 */
		public String getUpdateDoneCorrespond() {
			return this.MSG_UPDATE_DONE_CORRESPOND;
		}

		/** 紐づけ解除の完了 */
		public String getReleaseLinkingCompleted() {
			return this.MSG_RELEASE_LINKING_COMPLETED;
		}

		/** お気に入り物件の未選択 */
		public String getNoSelectedFavoriteProperty() {
			return this.MSG_NO_SELECTED_FAVORITE_PROPERTY;
		}

		/** URLの未入力 */
		public String getNoInputUrl() {
			return this.MSG_NO_INPUT_URL;
		}

		/** 新規メッセージの必須入力 */
		public String getRequiredNewMessage() {
			return this.MSG_REQUIRED_NEW_MESSAGE;
		}

		/** メッセージ送信確認 */
		public String getSendMessageConfirm() {
			return this.MSG_SEND_MESSAGE_CONFIRM;
		}

		/** メッセージ送信完了 */
		public String getSendMessageCompleted() {
			return this.MSG_SEND_MESSAGE_COMPLETED;
		}

		/** ファイル送信完了 */
		public String getSendFileCompleted() {
			return this.MSG_SEND_FILE_COMPLETED;
		}

		/** 紐づけ解除確認 */
		public String getReleaseLinkingConfirm() {
			return this.MSG_RELEASE_LINKING_CONFIRM;
		}

		/** パラメータエラー */
		public String getSystemParameterErr() {
			return this.MSG_SYSTEM_PARAMETER_ERR;
		}

		/** 対応済不可メッセージ */ //2022.04.20 No0768 対応で追加
		public String getNoResponseConfirmation() {
			return this.MSG_COM_I_NO_RESPONSE_CONFIRMATION;
		}
	}

	/**
	 * LINE会員情報クラス
	 */
	public class ScreenLineMemberInfo {

		/** 項目 */
		public Id		lineMemberId			{get; set;} // LINE会員ID
		public Id		accountId				{get; set;} // 取引先ID
		public Id		lineMemberCandidateId	{get; set;} // LINE会員候補ID
		public String	lineId					{get; set;} // LINE ID
		public String	accountName				{get; set;} // お客様名
		public String	lineName				{get; set;} // LINE名
		public String	status					{get; set;} // ステータス
		public Id		correspondLineMemberId	{get; set;} // 対応のLINE会員ID

		/** オブジェクト */
		public LineMember__c					lineMember					{get; set;} // LINE会員
		public Correspond__c					correspond					{get; set;} // 対応
		public LineMemberCandidate__c			lineMemberCandidate			{get; set;} // LINE会員候補
		public IntroductionMailInformation__c	introductionMailInformation	{get; set;} // 紹介メール情報

		/**
		 * コンストラクタ（初期化）
		 */
		public screenLineMemberInfo() {

			// 項目
			this.lineMemberId			= null;
			this.accountId				= null;
			this.lineMemberCandidateId	= null;
			this.lineId					= CommonConst.STRING_EMPTY;
			this.accountName			= CommonConst.STRING_EMPTY;
			this.lineName				= CommonConst.STRING_EMPTY;
			this.status					= CommonConst.STRING_EMPTY;
			this.correspondLineMemberId	= null;

			// オブジェクト
			this.lineMember						= new LineMember__c();
			this.correspond						= new Correspond__c();
			this.lineMemberCandidate			= new LineMemberCandidate__c();
			this.introductionMailInformation	= new IntroductionMailInformation__c();
		}

		/**
		 * コンストラクタ（項目設定）
		 * @param LineMember__c						lineMember					LINE会員
		 * @param Correspond__c						correspond					対応
		 * @param LineMemberCandidate__c			lineMemberCandidate			LINE会員候補
		 * @param IntroductionMailInformation__c	introductionMailInformation	紹介メール情報
		 */
		public screenLineMemberInfo(
			LineMember__c lineMember
			, Correspond__c correspond
			, LineMemberCandidate__c lineMemberCandidate
			, IntroductionMailInformation__c introductionMailInformation
		) {

			// 項目
			this.lineMemberId			= lineMember.Id;
			this.accountId				= lineMember.Account__c;
			this.lineMemberCandidateId	= lineMemberCandidate.Id;
			this.lineId					= lineMember.LineId__c;
			this.accountName			= lineMember.Account__r.Name;
			this.lineName				= lineMember.Name;
			this.status					= lineMember.Status__c;
			this.correspondLineMemberId	= correspond.LineMember__c;

			// オブジェクト
			this.lineMember						= lineMember;
			this.correspond						= correspond;
			this.lineMemberCandidate			= lineMemberCandidate;
			this.introductionMailInformation	= introductionMailInformation;
		}
	}

	/**
	 * 定型文クラス
	 */
	public class ScreenFixedPhrase {

		/** 項目 */
		public String	replaceVal			{get; set;} // 置換値
		public String	selectedKey			{get; set;} // 定型文Key選択値
		public Integer	selectedValueIdx	{get; set;} // 定型文Value選択番号

		// 定型文（key:フォルダ、value:定型文Value）
		public Map<String, List<FixedPhraseValue>> fixedPhraseMap {get; set;}

		/**
		 * コンストラクタ（初期化）
		 */
		public ScreenFixedPhrase() {
			
			this.replaceVal			= CommonConst.STRING_EMPTY;
			this.fixedPhraseMap		= new Map<String, List<FixedPhraseValue>>();
			this.selectedKey		= CommonConst.STRING_EMPTY;
			this.selectedValueIdx	= 0;
		}

		/**
		 * コンストラクタ（項目設定）
		 * @param List<FixedPhrase__c> fixedPhraseList 定型文
		 */
		public ScreenFixedPhrase(List<FixedPhrase__c> fixedPhraseList) {

			// 初期化
			this();

			// 定型文Mapの取得
			List<FixedPhraseValue> tempValueList;
			for (FixedPhrase__c fixedPhrase : fixedPhraseList) {

				if (this.fixedPhraseMap.containsKey(fixedPhrase.Folder__c)) {
					tempValueList = this.fixedPhraseMap.get(fixedPhrase.Folder__c);
				} else {
					tempValueList = new List<FixedPhraseValue>();
				}

				tempValueList.add(new FixedPhraseValue(fixedPhrase, tempValueList.size()));
				this.fixedPhraseMap.put(fixedPhrase.Folder__c, tempValueList);
			}
		}
	}

	/**
	 * 定型文Valueクラス
	 */
	public class FixedPhraseValue {

		/** 項目 */
		public Integer	rowNo			{get; set;} // 行番号
		public String	fixedPhraseName	{get; set;} // 定型文名
		public String	text			{get; set;} // 本文

		/**
		 * コンストラクタ
		 * @param FixedPhrase__c fixedPhrase 定型文
		 * @param Integer		 rowNo		 行番号
		 */
		public fixedPhraseValue(FixedPhrase__c fixedPhrase, Integer rowNo) {

			this.rowNo				= rowNo;
			this.fixedPhraseName	= fixedPhrase.Name;
			this.text				= fixedPhrase.Text__c;
		}
	}

	/**
	 * 文例クラス
	 */
	public class ScreenExampleSentence {

		/** 項目 */
		public String	selectExampleSentence	{get; set;} // 選択された文例
		public String	selectedKey				{get; set;} // 文例Key選択値
		public Integer	selectedValueIdx		{get; set;} // 文例Value選択番号

		// 文例（key:フォルダ、value:文例Value）
		public Map<String, List<ExampleSentence__c>> exampleSentenceMap {get; set;}

		/**
		 * コンストラクタ（初期化）
		 */
		public screenExampleSentence() {

			this.exampleSentenceMap	= new Map<String, List<ExampleSentence__c>>();
			this.selectExampleSentence	= CommonConst.STRING_EMPTY;
			this.selectedKey			= CommonConst.STRING_EMPTY;
			this.selectedValueIdx		= 0;
		}

		/**
		 * コンストラクタ（項目設定）
		 * @param st<ExampleSentence__c> exampleSentenceList 文例
		 */
		public screenExampleSentence(List<ExampleSentence__c> exampleSentenceList) {

			// 初期化
			this();

			// 文例Mapの取得
			List<ExampleSentence__c> tempValueList;
			for (ExampleSentence__c exampleSentence : exampleSentenceList) {

				if (this.exampleSentenceMap.containsKey(exampleSentence.Folder__c)) {
					tempValueList = this.exampleSentenceMap.get(exampleSentence.Folder__c);
				} else {
					tempValueList = new List<ExampleSentence__c>();
				}

				tempValueList.add(exampleSentence);
				this.exampleSentenceMap.put(exampleSentence.Folder__c, tempValueList);
			}
		}
	}

	/**
	 * 物件URL生成クラス
	 */
	public class ScreenPropertyUrlGenerate {

		/** 項目 */
		public String propertyURL		{get; set;} // 物件URL
		public String propertyDetail	{get; set;} // 物件詳細

		/**
		 * コンストラクタ
		 */
		public screenPropertyUrlGenerate() {
			this.propertyURL	= CommonConst.STRING_EMPTY;
			this.propertyDetail = CommonConst.STRING_EMPTY;
		}
	}

	/**
	 * お気に入り物件クラス
	 */
	public class ScreenFavoriteProperty {

		/** 項目 */
		public Boolean canSwitchTab				{get; set;} // タブ切り替え可否フラグ
		public Boolean authorityOptionPortalFlg	{get; set;} // 自社ポータルの権限フラグ

		// お気に入り物件明細
		public List<FavoritePropertyDetail> favoritePropertyDetailList {get; set;}

		/**
		 * コンストラクタ（初期化）
		 */
		public screenFavoriteProperty() {

			this.canSwitchTab				= false;
			this.authorityOptionPortalFlg	= false;
			this.favoritePropertyDetailList	= new List<FavoritePropertyDetail>();
		}

		/**
		 * コンストラクタ（項目設定）
		 * @param Boolean authorityOptionPortalFlg 自社ポータルの権限フラグ
		 */
		public screenFavoriteProperty(Boolean authorityOptionPortalFlg) {

			// 初期化
			this();

			// 自社ポータルの権限フラグの設定
			this.authorityOptionPortalFlg = authorityOptionPortalFlg;
		}

		/**
		 * 明細の追加
		 * @param FavoriteProperty__c	favoriteProperty			お気に入り物件
		 * @param String				portalSiteUrl				ポータルサイトURL
		 * @param Boolean				canSelectFavoriteProperty	お気に入り物件選択可能フラグ
		 */
		public void addDetailList(FavoriteProperty__c favoriteProperty
								  , String portalSiteUrl
								  , Boolean canSelectFavoriteProperty) {

			// 明細値の取得
			FavoritePropertyDetail favoritePropertyDetail = 
				new FavoritePropertyDetail(
						favoriteProperty,
						portalSiteUrl,
						canSelectFavoriteProperty
					);
			
			this.favoritePropertyDetailList.add(favoritePropertyDetail);
		}
		
		/**
		 * タブ切り替え可否フラグの設定
		 */
		public void setCanSwitchTab() {
			
			this.canSwitchTab = true;

			// 自社ポータルの権限チェック
			if (!this.authorityOptionPortalFlg) {
				this.canSwitchTab = false;
			}
			
			// お気に入り物件の明細件数チェック
			if (this.favoritePropertyDetailList.size() == 0) {
				this.canSwitchTab = false;
			}
		}
	}

	/**
	 * お気に入り物件明細クラス
	 */
	public class FavoritePropertyDetail {

		/** 項目名 */
		public Boolean	isSelected					{get; set;} // 選択行
		public Id		propertyId					{get; set;} // 物件ID
		public String	buildingTrainRoute1Name		{get; set;} // 沿線１名
		public String	buildingStation1Name		{get; set;} // 駅１名
		public String	buildingName				{get; set;} // 建物名
		public String	propertyName				{get; set;} // 物件名
		public String	buildingCity				{get; set;} // 建物.住所１（市区町村）
		public String	buildingStationWalkTime1	{get; set;} // 建物.駅までの時間（分）１
		public String	propertyDetail				{get; set;} // 物件詳細
		public String	propertyURL					{get; set;} // 物件URL
		public Boolean	isPortalFlg					{get; set;} // ポータルサイト掲載物件自社ポータルフラグ

		/**
		 * コンストラクタ（初期化）
		 */
		public favoritePropertyDetail() {

			this.isSelected					= false;
			this.propertyId					= null;
			this.buildingTrainRoute1Name	= CommonConst.STRING_EMPTY;
			this.buildingStation1Name		= CommonConst.STRING_EMPTY;
			this.buildingName				= CommonConst.STRING_EMPTY;
			this.propertyName				= CommonConst.STRING_EMPTY;
			this.buildingCity				= CommonConst.STRING_EMPTY;
			this.buildingStationWalkTime1	= CommonConst.STRING_EMPTY;
			this.propertyDetail				= CommonConst.STRING_EMPTY;
			this.propertyURL				= CommonConst.STRING_EMPTY;
			this.isPortalFlg				= false;
		}

		/**
		 * コンストラクタ（項目設定）
		 * @param FavoriteProperty__c	favoriteProperty			お気に入り物件
		 * @param String				portalSiteUrl				ポータルサイトURL
		 * @param Boolean				canSelectFavoriteProperty	お気に入り物件選択可能フラグ
		 */
		public favoritePropertyDetail(FavoriteProperty__c favoriteProperty
									  , String portalSiteUrl
									  , Boolean canSelectFavoriteProperty) {
			// 初期化
			this();

			// 項目値の設定
			this.propertyId					= favoriteProperty.Property__c ;
			this.buildingTrainRoute1Name	= favoriteProperty.Property__r.Building__r.TrainRoute1__r.name;
			this.buildingStation1Name		= favoriteProperty.Property__r.Building__r.Station1__r.name;
			this.buildingName				= favoriteProperty.Property__r.Building__r.Name ;
			this.propertyName				= favoriteProperty.Property__r.Name ;
			this.buildingCity				= favoriteProperty.Property__r.Building__r.City__c;
			this.propertyURL				= portalSiteUrl + '?cd=' + favoriteProperty.Property__r.PropertyCode__c;
			this.isPortalFlg				= canSelectFavoriteProperty;
			this.buildingStationWalkTime1	= this.getDecimalToString(favoriteProperty.Property__r.Building__r.StationWalkTime1__c);
			this.propertyDetail				= this.getPropertyDetail();
		}

		/**
		 * 数値⇒文字列の変換値の取得
		 * @param decimal itemVal 項目値
		 * @return String 数値⇒文字列の変換値
		 */
		private String getDecimalToString(decimal itemVal) {

			// 項目値の存在チェック
			if (itemVal == null) {
				return CommonConst.STRING_EMPTY;
			}

			return CommonUtil.decimalToString(itemVal);
		}

		/**
		 * 物件詳細の取得
		 * @return String 物件詳細
		 */
		private String getPropertyDetail() {

			// 物件詳細の取得（指定のフォーマットに変換）
			String propertyDetail =
				this.buildingName
				+ getPropertyDetailFormat(this.propertyName,				null,		null)
				+ getPropertyDetailFormat(this.buildingCity,				null,		null)
				+ getPropertyDetailFormat(this.buildingTrainRoute1Name,		null,		null)
				+ getPropertyDetailFormat(this.buildingStation1Name,		null,		null)
				+ getPropertyDetailFormat(this.buildingStationWalkTime1,	'徒歩約',	'分');

			return propertyDetail;
		}

		/**
		 * 物件詳細用フォーマット値の取得
		 * @param String itemVal 項目値
		 * @param String prefix	 接頭語
		 * @param String suffix	 接尾語
		 * @return 物件詳細用フォーマット値
		 */
		private String getPropertyDetailFormat(String itemVal, String prefix, String suffix) {

			// 項目値の存在チェック
			if (String.isEmpty(itemVal)){
				return CommonConst.STRING_EMPTY;
			}

			// 出力値の取得
			String outPrefix = (String.isEmpty(prefix)) ? CommonConst.STRING_EMPTY: prefix;
			String outSuffix = (String.isEmpty(suffix)) ? CommonConst.STRING_EMPTY: suffix;

			return '  ' + outPrefix + itemVal + outSuffix;
		}
	}

	/**
	 * メッセージ履歴クラス
	 */
	public class ScreenMessageHistory {

		/** 定数 */
		public final String CLASS_TEXT_RIGHT	= 'text-right';	// 右寄せクラス
		public final String CLASS_TEXT_LEFT		= 'text-left';	// 左寄せクラス
		public final String CLASS_LINE_RIGHT	= 'line_right';	// 担当者用LINEクラス
		public final String CLASS_LINE_LEFT		= 'line_left';	// 顧客用LINEクラス

		/** 項目 */
		public String	message		{get; set;} // メッセージ
		public String	sendTime	{get; set;} // 送信時刻
		public String	imgPath		{get; set;} // 画像パス
		public String	filePath	{get; set;} // ファイルパス
		public Boolean	isDispImg	{get; set;} // 画像表示フラグ（true:表示、false:非表示）

		/** スタイル */
		public String lineType	{get; set;} // LINE区分
		public String textAlign	{get; set;} // text-align

		/**
		 * コンストラクタ（初期化）
		 */
		public screenMessageHistory() {

			// 項目
			this.message	= CommonConst.STRING_EMPTY;
			this.sendTime	= CommonConst.STRING_EMPTY;
			this.imgPath	= CommonConst.STRING_EMPTY;
			this.filePath	= CommonConst.STRING_EMPTY;
			this.isDispImg	= false;
			
			// スタイル（担当者である右寄せ）
			this.lineType	= this.CLASS_LINE_RIGHT;
			this.textAlign	= this.CLASS_TEXT_RIGHT;
		}

		/**
		 * コンストラクタ（項目設定）
		 */
		public screenMessageHistory(LineHistory__c lineHistory) {

			// 初期化
			this();

			// 項目
			this.message	= this.getMessage(lineHistory.Message__c);
			this.sendTime	= this.getSendTime(lineHistory.SendTime__c);
			this.imgPath	= this.getImgPath(lineHistory);
			this.filePath	= lineHistory.FileURL__c;
			this.isDispImg	= this.isDispImgFile(lineHistory.FileName__c);

			// スタイル（顧客の場合は左寄せのスタイルを適用）
			if (CommonConst.LINE_HISTORY_SEND_TYPE_CUSTOMER.equals(lineHistory.SendType__c)) {
				this.lineType	= this.CLASS_LINE_LEFT;
				this.textAlign	= this.CLASS_TEXT_LEFT;
			}
		}

		/**
		 * メッセージの取得
		 * @param String msg メッセージ
		 * @return String メッセージ
		 */
		private String getMessage(String msg) {

			// 実施チェック
			if (String.isBlank(msg)) {
				return CommonConst.STRING_EMPTY;
			}

			// メッセージの改行処理
			String rtnMsg = msg.replaceAll(
				CommonConst.LINE_FEED
				, CommonConst.BREAK_TAG
			);

			return rtnMsg;
		}

		/**
		 * 画像パスの取得
		 * @param String extension 拡張子
		 * @return String ファイル（動画はサムネイル画像、それ以外はファイル画像）
		 */
		private String getImgPath(LineHistory__c obj) {

			// 拡張子の取得
			String extension = LineMessagingApiUtil.getExtension(obj.FileName__c);

			// 動画ファイルはサムネイル画像を表示
			if (LineMessagingApiUtil.getVideoExtension().contains(extension)) {
				return obj.ThumbnailURL__c;
			}

			// ファイル画像を表示
			return obj.FileURL__c;
		}

		/**
		 * 表示対象の画像ファイルチェック
		 * @param String fileName ファイル名
		 * @return Boolean true:表示、false:非表示
		 */
		private Boolean isDispImgFile(String fileName) {

			// 拡張子の取得
			String extension = LineMessagingApiUtil.getExtension(fileName);

			// 表示対象拡張子の取得
			List<String> dispExtension = new List<String>();
			dispExtension.addAll(LineMessagingApiUtil.getVideoExtension());
			dispExtension.addAll(LineMessagingApiUtil.getImgExtension());

			// 表示チェック
			if (dispExtension.contains(extension)) {
				return true;
			}

			return false;
		}

		/**
		 * 送信時刻の取得
		 * @param Datetime sendTime 送信時刻
		 * @return String 送信時刻 ※"yyyy/M/d(曜日) HH:mm"形式 or "M/d(曜日) HH:mm"形式
		 */
		private String getSendTime(Datetime sendTime) {

			// 実施チェック
			if (sendTime == null) {
				return CommonConst.STRING_EMPTY;
			}

			// 西暦の取得
			String year = CommonConst.STRING_EMPTY;
			if (sendTime.year() != CommonUtil.getNow().year()){
				year = sendTime.year() + '/';
			}

			// 送信時刻の取得
			String rtnSendTime = CommonUtil.callMessageCreate(
				sendTime.format('{0}M/d({1}) HH:mm')
				, year
				, CommonUtil.getJpnDayWeek(sendTime)
			);

			return rtnSendTime;
		}
	}

	/**
	 * メッセージ送信クラス
	 */
	public class ScreenSendMessage {

		/** 項目 */
		public String newMessage {get; set;} // 新規メッセージ

		/**
		 * コンストラクタ
		 */
		public screenSendMessage() {
			this.newMessage = CommonConst.STRING_EMPTY;
		}
	}
}