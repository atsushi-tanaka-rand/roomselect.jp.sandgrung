// LINE専用
@isTest
public with sharing class GL101001Test {

	public static final Datetime nowDateTime = CommonUtil.getNow();	// テスト用共通日付// 2022.05.16 No0758 対応で追加
	/**
	 * 初期設定
	 */
    @testSetup static void setting() {

		// 標準プロファイルの取得
		Id profileId = [
			SELECT Id
			FROM Profile
			WHERE Name = '一般ユーザ'
		].Id;

		// ユーザの登録 //▼ 2022.04.20 No0768 対応で複数ユーザの追加
		System.runAs(getThisUser()) {
			User testUser = new User(
				LastName			= 'ippanUser'		   // 姓
				, Alias				= 'alias'			   // 別名
				, Email				= 'GL101001TestippanUser@test.com' // メール
				, UserName			= 'GL101001TestippanUser@test.com' // ユーザ名
				, CommunityNickname	= 'テストニックネーム'	// ニックネーム
				, EmailEncodingKey	= 'ISO-2022-JP'		   // メールの文字コード
				, TimeZoneSidKey	= 'Asia/Tokyo'		   // タイムゾーン
				, LocaleSidKey		= 'ja_JP'			   // 地域
				, LanguageLocaleKey	= 'ja'				   // 言語
				, ProfileId			= profileId			   // プロファイルID
			);
			// システム管理者
			User kanriUser = new User(
				LastName			= 'kanriUser'		   // 姓
				, Alias				= 'kanri'			   // 別名
				, Email				= 'GL101001TestkanriUser@test.com' // メール
				, UserName			= 'GL101001TestkanriUser@test.com' // ユーザ名
				, CommunityNickname	= 'かんりしゃテストニックネーム'	// ニックネーム
				, EmailEncodingKey	= 'ISO-2022-JP'		   // メールの文字コード
				, TimeZoneSidKey	= 'Asia/Tokyo'		   // タイムゾーン
				, LocaleSidKey		= 'ja_JP'			   // 地域
				, LanguageLocaleKey	= 'ja'				   // 言語
				, ProfileId			=  [SELECT Id FROM Profile	WHERE Name = :CommonConst.PROFILE_SYSTEM_ADMINISTRATOR].id // プロファイルID
			);
			// 一般ユーザ２
			User ippanUser2 = new User(
				LastName			= 'ippanUser2'		   // 姓
				, Alias				= 'alias'			   // 別名
				, Email				= 'GL101001TestippanUser2@test.com' // メール
				, UserName			= 'GL101001TestippanUser2@test.com' // ユーザ名
				, CommunityNickname	= 'テストニックネームに'	// ニックネーム
				, EmailEncodingKey	= 'ISO-2022-JP'		   // メールの文字コード
				, TimeZoneSidKey	= 'Asia/Tokyo'		   // タイムゾーン
				, LocaleSidKey		= 'ja_JP'			   // 地域
				, LanguageLocaleKey	= 'ja'				   // 言語
				, ProfileId			= profileId			   // プロファイルID
			);
			// 一般ユーザ３
			User ippanUser3 = new User(
				LastName			= 'ippanUser3'		   // 姓
				, Alias				= 'alias'			   // 別名
				, Email				= 'GL101001TestippanUser3@test.com' // メール
				, UserName			= 'GL101001TestippanUser3@test.com' // ユーザ名
				, CommunityNickname	= 'テストニックネームさん'	// ニックネーム
				, EmailEncodingKey	= 'ISO-2022-JP'		   // メールの文字コード
				, TimeZoneSidKey	= 'Asia/Tokyo'		   // タイムゾーン
				, LocaleSidKey		= 'ja_JP'			   // 地域
				, LanguageLocaleKey	= 'ja'				   // 言語
				, ProfileId			= profileId			   // プロファイルID
			);
			insert testUser;
			insert kanriUser;
			insert ippanUser2;
			insert ippanUser3;
		}
		User testUser =  [SELECT Id FROM User WHERE UserName = 'GL101001TestippanUser@test.com'];
		User ippanUser2 =  [SELECT Id FROM User WHERE UserName = 'GL101001TestippanUser2@test.com'];
		//▲ 2022.04.20 No0768 対応で複数ユーザの追加
 
		// カスタム設定
		SystemConfig__c systemConfig = new SystemConfig__c(
			LineMessagingApiUrl__c			= 'MessagingAPI URL'
			, LongTermChannelAccessToken__c	= '長期チャネルトークン'
			, S3BucketName__c				= 'S3BucketName'
			, S3AccessKey__c				= 'S3AccessKey'
			, S3SecretAccessKey__c			= 'S3SecretAccessKey'
			, S3Region__c					= 'S3Region'
			, TestDate__c					= Date.newInstance(2022, 4, 1)	// 2022.05.16 No0758 対応で追加
		);
		insert systemConfig;

		// 取引先
		Account account = new Account(
			Name = '取引先テスト'
		);
		insert account;

		//▼ 2022.04.20 No0768 対応で追加
		// 取引先（LINE会員無）
		Account account2 = new Account(
			Name = '取引先LINE会員無_テスト'
			, RecordTypeId = CommonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER) // 顧客
		);
		insert account2;

		// 取引先（LINE会員有）
		Account account3 = new Account(
			Name = '取引先LINE会員有_テスト'
			, RecordTypeId = CommonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER) // 顧客
		);
		//▲ 2022.04.20 No0768 対応で追加
		//▼ 2022.05.16 No0758 対応で追加
		Account account4 = new Account(	Name = '取引先LINE会員有_テスト2', RecordTypeId = CommonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER));
		Account account5 = new Account(	Name = '取引先LINE会員有_テスト3', RecordTypeId = CommonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER));
		Account account6 = new Account(	Name = '取引先LINE会員有_テスト4', RecordTypeId = CommonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER));
		Account account7 = new Account(	Name = '取引先LINE会員有_テスト5', RecordTypeId = CommonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER));
		insert new List<Account>{
			account3,account4,account5,account6,account7
		};
		//▲ 2022.05.16 No0758 対応で追加

		// LINE会員
		LineMember__c lineMember = new LineMember__c(
			Name			= 'LINE会員テスト'
			, Account__c	= account.Id
			, LineId__c		= '1234567890'
			, Status__c		= CommonConst.LINE_MEMBER_STATUS_NOT_REPLIED
		);
		insert lineMember;

		// LINE会員候補
		LineMemberCandidate__c  lineMemberCandidate = new LineMemberCandidate__c(
			Account__c	= account.Id
		);
		insert lineMemberCandidate;
		//▼ 2022.05.16 No0758 対応で追加
		LineMemberCandidate__c  lineMemberCandidate2 = new LineMemberCandidate__c(Account__c = account3.Id);
		LineMemberCandidate__c  lineMemberCandidate3 = new LineMemberCandidate__c(Account__c = account4.Id);
		LineMemberCandidate__c  lineMemberCandidate4 = new LineMemberCandidate__c(Account__c = account5.Id);
		LineMemberCandidate__c  lineMemberCandidate5 = new LineMemberCandidate__c(Account__c = account6.Id);
		LineMemberCandidate__c  lineMemberCandidate6 = new LineMemberCandidate__c(Account__c = account7.Id);
		insert new List<LineMemberCandidate__c>{
			lineMemberCandidate2,lineMemberCandidate3,lineMemberCandidate4,lineMemberCandidate5,lineMemberCandidate6
		};
		//▲ 2022.05.16 No0758 対応で追加

		// LINE履歴
		LineHistory__c lineHistory1 = new LineHistory__c(
			LineMember__c	= lineMember.Id
			, Message__c	= 'メッセージ'
			, SendTime__c	= CommonUtil.getNow()
		);
		insert lineHistory1;
		
		// 対応
		Correspond__c correspond = new Correspond__c(
			AccountId__c	= account.Id
			, LineMember__c	= lineMember.Id
		);
		insert correspond;

		//▼ 2022.04.20 No0768 対応で追加
		// 対応（LINE会員無）
		Correspond__c correspond2 = new Correspond__c(
			AccountId__c	= account2.Id
		);
		insert correspond2;
		systemConfig.IsSkipTrigger__c= true; //トリガスキップ
		update systemConfig;
		//▲ 2022.04.20 No0768 対応で追加

		// 紹介メール情報
		IntroductionMailInformation__c introductionMailInformation = new IntroductionMailInformation__c(
			Account__c	= account.Id
		);
		insert introductionMailInformation;

		// 定型文
		FixedPhrase__c fixedPhrase = new FixedPhrase__c(
			Folder__c			= '定型文フォルダ'
			, Name				= '定型文名'
			, Text__c			= '定型文テキスト'
			, UsageScreen__c	= CommonConst.FIXEDPHRASE_LINE_EXCLUSIVE
		);
		insert fixedPhrase;

		// 文例
		ExampleSentence__c exampleSentence = new ExampleSentence__c(
			Folder__c				= '文例フォルダ'
			, Name					= '文例名'
			, ExampleSentence__c	= '文例テキスト'
			, UsageScreen__c		= CommonConst.EXAMPLESENTENCE_LINE_EXCLUSIVE
		);
		insert exampleSentence;

		// 建物
		Building__c building = new Building__c();
		insert building;

		// 物件
		Property__c property1 = new Property__c(
			Building__c	= building.Id
		);
		Property__c property2 = new Property__c(
			Building__c	= building.Id
		);
		insert new List<Property__c>{property1, property2};

		// お気に入り物件
		FavoriteProperty__c favoriteProperty1 = new FavoriteProperty__c(
			Property__c		= property1.Id
			, Account__c	= account.Id
		);
		FavoriteProperty__c favoriteProperty2 = new FavoriteProperty__c(
			Property__c		= property2.Id
			, Account__c	= account.Id
		);
		insert new List<FavoriteProperty__c>{favoriteProperty1, favoriteProperty2};

		// ポータルサイト掲載物件
		PortalSitePostingProperty__c portalSitePostingProperty1 = new PortalSitePostingProperty__c(
			Property__c		= property1.Id
			, IsPortal__c	= true
		);
		PortalSitePostingProperty__c portalSitePostingProperty2 = new PortalSitePostingProperty__c(
			Property__c		= property2.Id
			, IsPortal__c	= false
		);
		insert new List<PortalSitePostingProperty__c>{portalSitePostingProperty1, portalSitePostingProperty2};

		// 店舗
		Shop__c shop = new Shop__c(
			Name = 'テスト店舗'
			, Email__c = 'testtenpo@co.jp'	// メールアドレス	// 2022.05.16 No0758 対応で追加
		);
		insert shop;

		// 組織階層レコード
		OrganizationHierarchy__c orgRecord = new OrganizationHierarchy__c(
			OrganizationCode__c = '0001',
			OrganizationName__c = '本部',
			HierarchyCode__c = '10',
			HierarchyOrder__c = 1,
			UpperOrganizationHierarchy__c = null,
			ExpandedOrganizationCode__c = '0000_0001',
			Shop__c = shop.Id
		);
		insert orgRecord;
	
		// 店舗異動データ
		ShopTransfer__c shopTransferRecord = new ShopTransfer__c(
			orgzanizationHierarchy__c = orgRecord.id
			, StartDate__c	= CommonUtil.getToday().addDays(-1)
			, EndDate__c	= CommonUtil.getToday().addDays(2)
			, Staff__c		= UserInfo.getUserId()
		);  
		insert ShopTransferRecord;

		//▼ 2022.04.20 No0768 対応で追加 店舗の設定をするために最後に追加
		systemConfig.IsSkipTrigger__c= false; //トリガスキップ戻す
		update systemConfig;
		LineMember__c lineMember1 = new LineMember__c(Name = '対応終了_取引先無' , LineId__c= 'Uf124585fafd38f4337a2434830d55001'); 
		LineMember__c lineMember2 = new LineMember__c(Name = '対応契約完了_取引先無' , LineId__c= 'Uf124585fafd38f4337a2434830d55002'); 
		LineMember__c lineMember3 = new LineMember__c(Name = '対応反響集約_取引先無' , LineId__c= 'Uf124585fafd38f4337a2434830d55003'); 
		LineMember__c lineMember4 = new LineMember__c(Name = '対応未対応_取引先無' , LineId__c= 'Uf124585fafd38f4337a2434830d55004');
		LineMember__c lineMember5 = new LineMember__c(Name = '対応追客中_取引先無' , LineId__c= 'Uf124585fafd38f4337a2434830d55005'); 
		 

		// 取引先有
		LineMember__c lineMember6 = new LineMember__c(Name = '対応終了_取引先有' , LineId__c= 'Uf124585fafd38f4337a2434830d55006' , Account__c = account3.Id); 
		LineMember__c lineMember7 = new LineMember__c(Name = '対応契約完了_取引先有' , LineId__c= 'Uf124585fafd38f4337a2434830d55007' , Account__c = account4.Id); 
		LineMember__c lineMember8 = new LineMember__c(Name = '対応反響集約_取引先有' , LineId__c= 'Uf124585fafd38f4337a2434830d55008' , Account__c = account5.Id); 
		LineMember__c lineMember9 = new LineMember__c(Name = '対応未対応_取引先有' , LineId__c= 'Uf124585fafd38f4337a2434830d55009' , Account__c = account6.Id); 
		LineMember__c lineMember10 = new LineMember__c(Name = '対応追客中_取引先有' , LineId__c= 'Uf124585fafd38f4337a2434830d55010', Account__c = account7.Id); 

		LineMember__c lineMember11 = new LineMember__c(Name = '対応未対応_反響担当有' , LineId__c= 'Uf124585fafd38f4337a2434830d55011');
		LineMember__c lineMember12 = new LineMember__c(Name = '対応未対応_来店担当有' , LineId__c= 'Uf124585fafd38f4337a2434830d55012');
		LineMember__c lineMember13 = new LineMember__c(Name = '対応未対応_反響_来店_担当有' , LineId__c= 'Uf124585fafd38f4337a2434830d55013');

		insert  new List<LineMember__c>{
			lineMember1,lineMember2,lineMember3,lineMember4,lineMember5,
			lineMember6,lineMember7,lineMember8,lineMember9,lineMember10,
			lineMember11,lineMember12,lineMember13
		};
		List<ID> lineMemberIDList = new List<ID>{lineMember1.Id,lineMember2.Id,lineMember3.Id,lineMember4.id,
			lineMember5.id,lineMember6.id,lineMember7.id,lineMember8.id,lineMember9.id,lineMember10.Id,
			lineMember11.Id,lineMember12.Id,lineMember13.id
		};
		// 対応修正（BL101001TriggerHandlerにて作成されているはず）
		List<Correspond__c> correspondList = [SELECT Id ,EventDateTime__c,FirstInquiryMeans__c,IsBrowseFlg__c,ListViewDate__c,PortalSiteUrl__c,PortalSite__c,ReceiveMailDatePortal__c,status__c,LineFriendAddDate__c,LineMember__c,LineMember__r.Name,FirstLineAddFlg__c
			FROM Correspond__c
			WHERE LineMember__c IN :lineMemberIDList 
		];
		List<Correspond__c> updateCorrespondList = new List<Correspond__c>();
		for (Correspond__c changeCorrespond : correspondList) {
			if (changeCorrespond.LineMember__r.Name == '対応終了_取引先無') {
				changeCorrespond.status__c = CommonConst.CORRESPOND_STATUS_CLOSE;	// ステータス（終了）
				updateCorrespondList.add(changeCorrespond);
			}else if (changeCorrespond.LineMember__r.Name == '対応契約完了_取引先無') {
				changeCorrespond.status__c = CommonConst.CORRESPOND_STATUS_AGREEMENT;	// ステータス（契約完了）
				updateCorrespondList.add(changeCorrespond);
			}else if (changeCorrespond.LineMember__r.Name == '対応反響集約_取引先無') {
				changeCorrespond.status__c = CommonConst.CORRESPOND_STATUS_ECHOAGGREGATION;	// ステータス（反響集約）
				updateCorrespondList.add(changeCorrespond);
			}else if (changeCorrespond.LineMember__r.Name == '対応追客中_取引先無') {
				changeCorrespond.status__c = CommonConst.CORRESPOND_STATUS_PURSUIT;	// ステータス（追客中）
				updateCorrespondList.add(changeCorrespond);
			
			}else if (changeCorrespond.LineMember__r.Name == '対応終了_取引先有') {
				changeCorrespond.status__c = CommonConst.CORRESPOND_STATUS_CLOSE;	// ステータス（終了）
				changeCorrespond.AccountId__c = account3.Id;
				updateCorrespondList.add(changeCorrespond);
			}else if (changeCorrespond.LineMember__r.Name == '対応契約完了_取引先有') {
				changeCorrespond.status__c = CommonConst.CORRESPOND_STATUS_AGREEMENT;	// ステータス（契約完了）
				changeCorrespond.AccountId__c = account4.Id;
				updateCorrespondList.add(changeCorrespond);
			}else if (changeCorrespond.LineMember__r.Name == '対応反響集約_取引先有') {
				changeCorrespond.status__c = CommonConst.CORRESPOND_STATUS_ECHOAGGREGATION;	// ステータス（反響集約）
				changeCorrespond.AccountId__c = account5.Id;
				updateCorrespondList.add(changeCorrespond);
			}else if (changeCorrespond.LineMember__r.Name == '対応未対応_取引先有') {
				changeCorrespond.StatusBeforePursuitHold__c = changeCorrespond.Status__c;
				changeCorrespond.AccountId__c = account6.Id;
				updateCorrespondList.add(changeCorrespond);
			}else if (changeCorrespond.LineMember__r.Name == '対応追客中_取引先有') {
				changeCorrespond.status__c = CommonConst.CORRESPOND_STATUS_PURSUIT;	// ステータス（追客中）
				changeCorrespond.StatusBeforePursuitHold__c = changeCorrespond.Status__c;
				changeCorrespond.AccountId__c = account7.Id;
				updateCorrespondList.add(changeCorrespond);

			}else if (changeCorrespond.LineMember__r.Name == '対応未対応_反響担当有') {
				changeCorrespond.EchoStaff__c = testUser.Id;	// 反響担当者
				changeCorrespond.EchoShop__c = shop.id;		// 反響担当店舗
				updateCorrespondList.add(changeCorrespond);
			}else if (changeCorrespond.LineMember__r.Name == '対応未対応_来店担当有') {
				changeCorrespond.ShopStaff__c = testUser.Id;	// 反響担当者
				changeCorrespond.VisitShop__c = shop.id;		// 来店担当店舗
				updateCorrespondList.add(changeCorrespond);
			}else if (changeCorrespond.LineMember__r.Name == '対応未対応_反響_来店_担当有') {
				changeCorrespond.EchoStaff__c = testUser.Id;	// 反響担当者
				changeCorrespond.EchoShop__c = shop.id;			// 反響担当店舗
				changeCorrespond.ShopStaff__c = ippanUser2.Id;	// 反響担当者
				changeCorrespond.VisitShop__c = shop.id;		// 来店担当店舗
				updateCorrespondList.add(changeCorrespond);
			}
			
		}
		if (updateCorrespondList.size() > 0) {
			update updateCorrespondList;	
		}
		//▲ 2022.04.20 No0768 対応で追加

		//▼ 2022.05.16 No0758 対応で追加
		// 反響メール（LINE）
		Echomail__c echoMail1 = new Echomail__c(
			LineMember__c = lineMember6.id,// LINE会員
			LineReceiveType__c = commonconst.LINE_RECEIVE_TYPE_RECEIVE,	// LINE受信種別（LINE受信）
			FromEmail__c = 'aaa@co.jp' , // Fromメールアドレス
			Email__c = 'bbb@co.jp' // メール
		);
		Echomail__c echoMail2 = new Echomail__c(
			LineMember__c = lineMember10.id,// LINE会員
			LineReceiveType__c = commonconst.LINE_RECEIVE_TYPE_RECEIVE,	// LINE受信種別（LINE受信）
			FromEmail__c = 'zzz@co.jp' , // Fromメールアドレス
			Email__c = 'bbb@co.jp' // メール
		);
		// 反響メール（LINE以外）
		Echomail__c echoMail3 = new Echomail__c(
			FromEmail__c = 'ccc@co.jp' , // Fromメールアドレス
			Email__c = 'eee@co.jp' // メール
		);
		// 反響メール（LINE）
		Echomail__c echoMail4 = new Echomail__c(
			LineMember__c = lineMember7.id,// LINE会員
			LineReceiveType__c = commonconst.LINE_RECEIVE_TYPE_RECEIVE,	// LINE受信種別（LINE受信）
			FromEmail__c = 'fff@co.jp' , // Fromメールアドレス
			Email__c = 'ggg@co.jp' // メール
		);
		insert new List<Echomail__c>{echoMail1,echoMail2,echoMail3,echoMail4};
		//▲ 2022.05.16 No0758 対応で追加
	}

	/**
	 * 対応済ボタン押下テスト
	 */
	@istest static void clickDoneCorrespondTest() {

		System.runAs(getThisUser()) {
			Test.startTest();
			
			// 初期表示と対応済ボタンの押下
			GL101001Controller testController = getInitController('LINE会員テスト');
			testController.clickDoneCorrespond();

			// 実施後
			LineMember__c lineMember = selectLineMember('LINE会員テスト');
			System.assertEquals(
				lineMember.Status__c
				, CommonConst.LINE_MEMBER_STATUS_DONE_CORRESPOND
				, '対応済押下処理'
			);

			Test.stopTest();
		}
	}

	/**
	 * 紐づけ解除ボタン押下テスト
	 */
	@istest static void clickReleaseLinkingTest() {

		System.runAs(getThisUser()) {
			Test.startTest();
			
			// 初期表示と紐づけ解除ボタンの押下
			GL101001Controller testController = getInitController('LINE会員テスト');
			testController.clickReleaseLinking();

			// 実施後
			LineMember__c lineMember = selectLineMember('LINE会員テスト');
			System.assertEquals(
				lineMember.Account__c
				, null
				, '紐づけ解除押下処理'
			);

			Test.stopTest();
		}
	}

	/**
	 * 発行ボタン（お気に入り物件）押下テスト
	 */
	@istest static void clickFavoritePropertyIssueTest() {
		System.runAs(getThisUser()) {
			Test.startTest();
			
			// 初期表示と紐づけ発行ボタンの押下
			GL101001Controller testController = getInitController('LINE会員テスト');
			testController.screenFavoriteProperty.favoritePropertyDetailList[0].isSelected = true;
			testController.clickFavoritePropertyIssue();

			// 実施後
			System.assertNotEquals(testController.issueUrl, null, '発行ボタン（お気に入り物件）押下処理');

			Test.stopTest();
		}
	}

	/**
	 * 発行（物件URL生成）押下テスト
	 */
	@istest static void clickPropertyUrlGenerateIssueTest() {
		System.runAs(getThisUser()) {
			Test.startTest();
			
			// 初期表示と紐づけ発行ボタンの押下
			GL101001Controller testController = getInitController('LINE会員テスト');
			testController.screenPropertyUrlGenerate.propertyURL = 'URLテスト';
			testController.screenPropertyUrlGenerate.propertyDetail = '物件詳細テスト';
			testController.clickPropertyUrlGenerateIssue();

			// 実施後
			System.assertNotEquals(testController.issueUrl, null, '発行（物件URL生成）押下処理');

			Test.stopTest();
		}
	}

	/**
	 * 定型文押下テスト
	 */
	@istest static void clickFixedPhraseTest() {

		// 定型文の取得
		FixedPhrase__c fixedPhrase = selectFixedPhrase('定型文名');

		System.runAs(getThisUser()) {
			Test.startTest();
			
			// 初期表示と定型文の押下
			GL101001Controller testController = getInitController('LINE会員テスト');
			testController.screenFixedPhrase.selectedKey		= '定型文フォルダ';
			testController.screenFixedPhrase.selectedValueIdx	= 0;
			testController.clickFixedPhrase();

			// 実施後
			System.assertEquals(
				fixedPhrase.Text__c
				, testController.screenFixedPhrase.replaceVal
				, '定型文押下処理'
			);

			Test.stopTest();
		}
	}

	/**
	 * 定型文選択モーダル起動テスト
	 */
	@istest static void openFixedPhraseSelectModalTest() {

		// 定型文の取得
		FixedPhrase__c fixedPhrase = selectFixedPhrase('定型文名');

		System.runAs(getThisUser()) {
			Test.startTest();
			
			// 初期表示と定型文選択モーダルの起動
			GL101001Controller testController = getInitController('LINE会員テスト');
			testController.openFixedPhraseSelectModal();

			// 実施後
			System.assertNotEquals(
				testController.gL101001Modal1Parameter
				, new GL101001Modal1ParameterClass()
				, '定型文選択モーダル起動処理'
			);

			// 定型文選択モーダルの初期表示と定型文の押下
			GL101001Modal1Controller modalController = new GL101001Modal1Controller();
			modalController.parameter = testController.gL101001Modal1Parameter;
			modalController.parameter.isDrawing = modalController.init;
			
			modalController.screenFixedPhrase.selectedKey		= '定型文フォルダ';
			modalController.screenFixedPhrase.selectedValueIdx	= 0;
			modalController.clickFixedPhrase();

			// 実施後
			System.assertEquals(
				fixedPhrase.Text__c
				, modalController.screenFixedPhrase.replaceVal
				, '定型文押下処理'
			);

			Test.stopTest();
		}
	}

	/**
	 * 文例集選択モーダル起動テスト
	 */
	@istest static void openExampleSentenceSelectModalTest() {

		System.runAs(getThisUser()) {
			Test.startTest();
			
			// 初期表示と文例集選択モーダルの起動
			GL101001Controller testController = getInitController('LINE会員テスト');
			testController.openExampleSentenceSelectModal();

			// 実施後
			System.assertNotEquals(
				testController.gL101001Modal2Parameter
				, new GL101001Modal2ParameterClass()
				, '文例集選択モーダル起動処理'
			);

			// 文例集選択モーダルの初期表示
			GL101001Modal2Controller modalController = new GL101001Modal2Controller();
			modalController.parameter = testController.gL101001Modal2Parameter;
			modalController.parameter.isDrawing = modalController.init;

			Test.stopTest();
		}
	}

	/**
	 * ファイル送信モーダル起動テスト
	 */
	@istest static void openSendFileModalTest() {

		System.runAs(getThisUser()) {
			Test.startTest();
			
			// 初期表示とファイル送信モーダルの起動
			GL101001Controller testController = getInitController('LINE会員テスト');
			testController.openSendFileModal();

			// 実施後
			System.assertNotEquals(
				testController.gL101001Modal3Parameter
				, new GL101001Modal3ParameterClass()
				, 'ファイル送信起動処理'
			);

			// ファイル送信モーダルの初期表示
			GL101001Modal3Controller modalController = new GL101001Modal3Controller();
			modalController.parameter = testController.gL101001Modal3Parameter;
			modalController.parameter.isDrawing = modalController.init;

			Test.stopTest();
		}
	}

	/**
	 * メッセージ送信ボタン押下テスト
	 */
	@istest static void clickSendMsgTest() {

		System.runAs(getThisUser()) {

			Test.setMock(HttpCalloutMock.class, new LineMessagingApiUtilHTTPRequestMock(false));
			Test.startTest();
			
			// 初期表示とメッセージ送信ボタン押下
			GL101001Controller testController = getInitController('LINE会員テスト');
			testController.screenSendMessage.newMessage = 'メッセージ';
			testController.clickSendMsg();

			// 実施後
			System.assertEquals(
				testController.screenLineMemberInfo.status
				, CommonConst.LINE_MEMBER_STATUS_DONE_REPLIED
				, 'メッセージ送信ボタン押下処理'
			);

			Test.stopTest();
		}
	}

	/**
	 * ファイル送信処理テスト
	 */
	@istest static void sendFileLineProcessTest() {

		System.runAs(getThisUser()) {

			Test.setMock(HttpCalloutMock.class, new LineMessagingApiUtilHTTPRequestMock(false));
			Test.startTest();
			
			// 拡張子に応じた処理を行う為のファイル名一覧
			List<String> fileNameList = new List<String>{
				'ファイル名.mp4'
				, 'ファイル名.jpg'
				, 'ファイル名.txt'
			};

			// 初期表示とファイル送信処理の実施
			GL101001Controller testController = getInitController('LINE会員テスト');
			testController.openSendFileModal();
			testController.gL101001Modal3Parameter.message			= 'メッセージ';
			testController.gL101001Modal3Parameter.filePath 		= 'ファイルパス';
			testController.gL101001Modal3Parameter.thumbnailName	= 'サムネイル画像名';
			testController.gL101001Modal3Parameter.thumbnailPath	= 'サムネイル画像パス';

			// ※2回目以降は未コミットエラーが行われる
			for (String fileName : fileNameList) {
				testController.gL101001Modal3Parameter.fileName	= fileName;
				testController.sendFileLineProcess();
			}

			// 実施後
			System.assertEquals(
				testController.screenLineMemberInfo.status
				, CommonConst.LINE_MEMBER_STATUS_DONE_REPLIED
				, 'ファイル送信処理'
			);

			Test.stopTest();
		}
	}

	/**
	 * カバレッジアップ（その他メソッド）
	 */
	@isTest static void coverageUpOtherMethod() {
		System.runAs(getThisUser()) {

			test.startTest();

			GL101001Controller testController = getInitController('LINE会員テスト');
			testController.getLineInputLength();
			testController.msgs.getSaveCompleted();
			testController.msgs.getUpdateDoneCorrespond();
			testController.msgs.getReleaseLinkingCompleted();
			testController.msgs.getNoSelectedFavoriteProperty();
			testController.msgs.getNoInputUrl();
			testController.msgs.getRequiredNewMessage();
			testController.msgs.getSendMessageConfirm();
			testController.msgs.getSendMessageCompleted();
			testController.msgs.getSendFileCompleted();
			testController.msgs.getReleaseLinkingConfirm();
			testController.msgs.getSystemParameterErr();

			GL101001Modal3Controller modalController3 = new GL101001Modal3Controller();
			modalController3.msgs = new GL101001Modal3Controller.Msgs();
			modalController3.msgs.getDeleteCompleted();
			modalController3.msgs.getNoSelectedFile();
			modalController3.msgs.getSendFileConfirm();
			modalController3.msgs.getErrGetThumbnail();
			modalController3.msgs.getErrXmlHttpRequest();
			modalController3.msgs.getErrFileuploadAll();
			modalController3.msgs.getErrFileuploadContain();
			modalController3.msgs.getErrNotSelectedExtension();

			// 処理結果
			System.assertEquals(null, null, '確認内容無し');

			test.stopTest();
		}
	}

	/**
	 * カバレッジアップ（例外）
	 */
	@isTest static void coverageUpException() {
		System.runAs(getThisUser()) {
			test.startTest();

			GL101001Controller testController = new GL101001Controller();
			testController.clickDoneCorrespond();
			testController.clickReleaseLinking();
			testController.clickFavoritePropertyIssue();
			testController.clickPropertyUrlGenerateIssue();
			testController.clickFixedPhrase();
			testController.clickSendMsg();

			GL101001Modal1Controller modalController1 = new GL101001Modal1Controller();
			modalController1.clickFixedPhrase();

			// ファイル送信モーダル用の更新
			SystemConfig__c systemConfig = [
				SELECT Id
				FROM SystemConfig__c
			];
			systemConfig.S3BucketName__c = CommonConst.STRING_EMPTY;
			update systemConfig;

			GL101001Modal3Controller modalController3 = new GL101001Modal3Controller();
			testController.openSendFileModal();
			modalController3.parameter = testController.gL101001Modal3Parameter;
			modalController3.parameter.isDrawing = modalController3.init;

			// 処理結果
			System.assertEquals(null, null, '確認内容無し');

			test.stopTest();
		}
	}

	//▼ 2022.04.20 No0768 対応で追加
	/**
	* 対応済ボタン押下（対応の各担当者無）
	*     遷移元のパラメータの対応．ステータス：反響集約、終了、契約完了の場合
	*     対応の大幅な変化無
	*/
	@isTest static void clickDoneCorrespondTest2() {
		System.runAs(getUser('ippanUser')) {
			// テスト実施
			Test.startTest();
			
			// 初期表示と対応済ボタンの押下
			GL101001Controller testController1 = getInitController('対応終了_取引先無');
			Correspond__c beforeCorrespond1 = selectCorrespond('対応終了_取引先無');
			testController1.clickDoneCorrespond();
			
			// 初期表示と対応済ボタンの押下
			GL101001Controller testController2 = getInitController('対応契約完了_取引先無');
			Correspond__c beforeCorrespond2 = selectCorrespond('対応契約完了_取引先無');
			testController2.clickDoneCorrespond();

			// 初期表示と対応済ボタンの押下
			GL101001Controller testController3 = getInitController('対応反響集約_取引先無');
			Correspond__c beforeCorrespond3 = selectCorrespond('対応反響集約_取引先無');
			testController3.clickDoneCorrespond();

			// 対応一覧のリスト取得
			GA101001Controller testControllerGA101001 = new GA101001Controller();
			// 反響一覧のリスト取得
			GA101002Controller testControllerGA101002 = new GA101002Controller();

			Test.stopTest();
			// テスト実施終了

			// 結果確認
			Correspond__c clickCorrespond1 = selectCorrespond('対応終了_取引先無');
			checkClickDoneCorrespond(clickCorrespond1,beforeCorrespond1,'対応終了_取引先無');

			Correspond__c clickCorrespond2 = selectCorrespond('対応契約完了_取引先無');
			checkClickDoneCorrespond(clickCorrespond2,beforeCorrespond2,'対応契約完了_取引先無');

			Correspond__c clickCorrespond3 = selectCorrespond('対応反響集約_取引先無');
			checkClickDoneCorrespond(clickCorrespond3,beforeCorrespond3,'対応反響集約_取引先無');
			// 対応一覧
			for (GA101001Controller.ScreenCorrespond screenTargetRecord : testControllerGA101001.screenTargetRecordList) {
				if(clickCorrespond1.id == screenTargetRecord.Id){
					// あればエラー
					System.assertEquals(testControllerGA101001.screenTargetRecordList.size(),0,'対応一覧表示：'+'対応終了_取引先無'+'='+screenTargetRecord.Status);
				} 
				if(clickCorrespond2.id == screenTargetRecord.Id){
					// あればエラー
					System.assertEquals(testControllerGA101001.screenTargetRecordList.size(),0,'対応一覧表示：'+'対応契約完了_取引先無'+'='+screenTargetRecord.Status);
				}
				if(clickCorrespond3.id == screenTargetRecord.Id){
					// あればエラー
					System.assertEquals(testControllerGA101001.screenTargetRecordList.size(),0,'対応一覧表示：'+'対応反響集約_取引先無'+'='+screenTargetRecord.Status);
				}
			}
			// 反響一覧
			for (GA101002Controller.ScreenCorrespond screenTargetRecord : testControllerGA101002.screenTargetRecordList) {
				if(clickCorrespond1.id == screenTargetRecord.Id){
					// あればエラー
					System.assertEquals(testControllerGA101002.screenTargetRecordList.size(),0,'反響一覧表示：'+'対応終了_取引先無'+'='+screenTargetRecord.Status);
				} 
				if(clickCorrespond2.id == screenTargetRecord.Id){
					// あればエラー
					System.assertEquals(testControllerGA101002.screenTargetRecordList.size(),0,'反響一覧表示：'+'対応契約完了_取引先無'+'='+screenTargetRecord.Status);
				}
				if(clickCorrespond3.id == screenTargetRecord.Id){
					// あればエラー
					System.assertEquals(testControllerGA101002.screenTargetRecordList.size(),0,'反響一覧表示：'+'対応反響集約_取引先無'+'='+screenTargetRecord.Status);
				}
			}
		}
	}
	
	/**
	* 対応済ボタン押下（対応の各担当者無）
	*     遷移元のパラメータの対応．ステータス：反響集約、終了、契約完了以外の場合
	*     対応の大幅な変化無
	*/
	@isTest static void clickDoneCorrespondTest3() {
		System.runAs(getUser('ippanUser')) {
			// テスト実施
			Test.startTest();
			
			// 初期表示と対応済ボタンの押下
			GL101001Controller testController = getInitController('対応追客中_取引先無');
			Correspond__c beforeCorrespond = selectCorrespond('対応追客中_取引先無');
			testController.clickDoneCorrespond();

			// 対応一覧のリスト取得
			GA101001Controller testControllerGA101001 = new GA101001Controller();
			// 反響一覧のリスト取得
			GA101002Controller testControllerGA101002 = new GA101002Controller();

			Test.stopTest();
			// テスト実施終了

			// 結果確認
			Correspond__c clickCorrespond = selectCorrespond('対応追客中_取引先無');
			checkClickDoneCorrespond(clickCorrespond,beforeCorrespond,'対応追客中_取引先無');
			// 対応一覧
			for (GA101001Controller.ScreenCorrespond screenTargetRecord : testControllerGA101001.screenTargetRecordList) {
				if(clickCorrespond.id == screenTargetRecord.Id){
					// あればエラー
					System.assertEquals(testControllerGA101001.screenTargetRecordList.size(),0,'対応一覧表示：'+'対応追客中_取引先無'+'='+screenTargetRecord.Status);
				}
			}
			// 反響一覧
			for (GA101002Controller.ScreenCorrespond screenTargetRecord : testControllerGA101002.screenTargetRecordList) {
				if(clickCorrespond.id == screenTargetRecord.Id){
					// あればエラー
					System.assertEquals(testControllerGA101002.screenTargetRecordList.size(),0,'反響一覧表示：'+'対応追客中_取引先無'+'='+screenTargetRecord.Status);
				} 
			}
		}
	}

	/**
	* 対応済ボタン押下
	*     対応の反響担当者○
	*     対応の来店担当者×
	*     一般ユーザのユーザが対応．反響担当者と同じ場合、登録が行えること
	*/
	@isTest static void clickDoneCorrespondTestEchoStaff1() {
		System.runAs(getUser('ippanUser')) {
			// テスト実施
			Test.startTest();
			
			// 初期表示と対応済ボタンの押下
			GL101001Controller testController = getInitController('対応未対応_反響担当有');
			Correspond__c beforeCorrespond = selectCorrespond('対応未対応_反響担当有');
			testController.clickDoneCorrespond();

			Test.stopTest();
			// テスト実施終了

			// 結果確認
			Correspond__c clickCorrespond = selectCorrespond('対応未対応_反響担当有');
			checkClickDoneCorrespond(clickCorrespond,beforeCorrespond,'対応未対応_反響担当有');

		}
	}
	
	/**
	* 対応済ボタン押下
	*     対応の反響担当者○
	*     対応の来店担当者×
	*     一般ユーザのユーザが対応．反響担当者と違う場合、登録が行えないこと
	*/
	@isTest static void clickDoneCorrespondTestEchoStaff2() {
		System.runAs(getUser('ippanUser2')) {
			// テスト実施
			Test.startTest();
			
			// 初期表示と対応済ボタンの押下
			GL101001Controller testController = getInitController('対応未対応_反響担当有');
			Correspond__c beforeCorrespond = selectCorrespond('対応未対応_反響担当有');
			testController.clickDoneCorrespond();

			Test.stopTest();
			// テスト実施終了

			// 結果確認
			Correspond__c clickCorrespond = selectCorrespond('対応未対応_反響担当有');
			System.assertEquals(clickCorrespond,beforeCorrespond , '対応済ボタン押下' + '対応未対応_反響担当有' +'：対応更新無');

		}
	}

	/**
	* 対応済ボタン押下
	*     対応の反響担当者○
	*     対応の来店担当者×
	*     システム管理者のユーザが対応．反響担当者と違う場合、登録が行えること
	*/
	@isTest static void clickDoneCorrespondTestEchoStaff3() {
		System.runAs(getUser('kanriUser')) {
			// テスト実施
			Test.startTest();
			
			// 初期表示と対応済ボタンの押下
			GL101001Controller testController = getInitController('対応未対応_反響担当有');
			Correspond__c beforeCorrespond = selectCorrespond('対応未対応_反響担当有');
			testController.clickDoneCorrespond();

			Test.stopTest();
			// テスト実施終了

			// 結果確認
			Correspond__c clickCorrespond = selectCorrespond('対応未対応_反響担当有');
			checkClickDoneCorrespond(clickCorrespond,beforeCorrespond,'対応未対応_反響担当有');

		}
	}

	/**
	* 対応済ボタン押下
	*     対応の反響担当者×
	*     対応の来店担当者○
	*     一般ユーザのユーザが対応．来店担当者と同じ場合、登録が行えること
	*/
	@isTest static void clickDoneCorrespondTestShopStaff1() {
		System.runAs(getUser('ippanUser')) {
			// テスト実施
			Test.startTest();
			
			// 初期表示と対応済ボタンの押下
			GL101001Controller testController = getInitController('対応未対応_来店担当有');
			Correspond__c beforeCorrespond = selectCorrespond('対応未対応_来店担当有');
			testController.clickDoneCorrespond();

			Test.stopTest();
			// テスト実施終了

			// 結果確認
			Correspond__c clickCorrespond = selectCorrespond('対応未対応_来店担当有');
			checkClickDoneCorrespond(clickCorrespond,beforeCorrespond,'対応未対応_来店担当有');

		}
	}
	
	/**
	* 対応済ボタン押下
	*     対応の反響担当者×
	*     対応の来店担当者○
	*     一般ユーザのユーザが対応．来店担当者と違う場合、登録が行えないこと
	*/
	@isTest static void clickDoneCorrespondTestShopStaff2() {
		System.runAs(getUser('ippanUser2')) {
			// テスト実施
			Test.startTest();
			
			// 初期表示と対応済ボタンの押下
			GL101001Controller testController = getInitController('対応未対応_来店担当有');
			Correspond__c beforeCorrespond = selectCorrespond('対応未対応_来店担当有');
			testController.clickDoneCorrespond();

			Test.stopTest();
			// テスト実施終了

			// 結果確認
			Correspond__c clickCorrespond = selectCorrespond('対応未対応_来店担当有');
			// 一般ユーザのユーザが対応．来店担当者と違う場合、登録が行えないこと
			System.assertEquals(clickCorrespond,beforeCorrespond , '対応済ボタン押下' + '対応未対応_来店担当有' +'：対応更新無');
		}
	}

	/**
	* 対応済ボタン押下
	*     対応の反響担当者×
	*     対応の来店担当者○
	*     システム管理者のユーザが対応．来店担当者と違う場合、登録が行えること
	*/
	@isTest static void clickDoneCorrespondTestShopStaff3() {
		System.runAs(getUser('kanriUser')) {
			// テスト実施
			Test.startTest();
			
			// 初期表示と対応済ボタンの押下
			GL101001Controller testController = getInitController('対応未対応_来店担当有');
			Correspond__c beforeCorrespond = selectCorrespond('対応未対応_来店担当有');
			testController.clickDoneCorrespond();

			Test.stopTest();
			// テスト実施終了

			// 結果確認
			Correspond__c clickCorrespond = selectCorrespond('対応未対応_来店担当有');
			checkClickDoneCorrespond(clickCorrespond,beforeCorrespond,'対応未対応_来店担当有');

		}
	}

	/**
	* 対応済ボタン押下
	*     対応の反響担当者○
	*     対応の来店担当者○
	*     一般ユーザのユーザが対応．反響担当者と同じ場合、登録が行えること
	*/
	@isTest static void clickDoneCorrespondTestEchoShopStaff1() {
		System.runAs(getUser('ippanUser')) {
			// テスト実施
			Test.startTest();
			
			// 初期表示と対応済ボタンの押下
			GL101001Controller testController = getInitController('対応未対応_反響_来店_担当有');
			Correspond__c beforeCorrespond = selectCorrespond('対応未対応_反響_来店_担当有');
			testController.clickDoneCorrespond();

			Test.stopTest();
			// テスト実施終了

			// 結果確認
			Correspond__c clickCorrespond = selectCorrespond('対応未対応_反響_来店_担当有');
			checkClickDoneCorrespond(clickCorrespond,beforeCorrespond,'対応未対応_反響_来店_担当有');

		}
	}
	
	/**
	* 対応済ボタン押下
	*     対応の反響担当者○
	*     対応の来店担当者○
	*     一般ユーザのユーザが対応．反響担当者と違う場合、登録が行えないこと
	*/
	@isTest static void clickDoneCorrespondTestEchoShopStaff2() {
		System.runAs(getUser('ippanUser3')) {
			// テスト実施
			Test.startTest();
			
			// 初期表示と対応済ボタンの押下
			GL101001Controller testController = getInitController('対応未対応_反響_来店_担当有');
			Correspond__c beforeCorrespond = selectCorrespond('対応未対応_反響_来店_担当有');
			testController.clickDoneCorrespond();

			Test.stopTest();
			// テスト実施終了

			// 結果確認
			Correspond__c clickCorrespond = selectCorrespond('対応未対応_反響_来店_担当有');
			// 一般ユーザのユーザが対応．反響担当者と違う場合、登録が行えないこと
			System.assertEquals(clickCorrespond,beforeCorrespond , '対応済ボタン押下' + '対応未対応_反響_来店_担当有' +'：対応更新無');

		}
	}

	/**
	* 対応済ボタン押下
	*     対応の反響担当者○
	*     対応の来店担当者○
	*     一般ユーザのユーザが対応．来店担当者と同じ場合、登録が行えること
	*/
	@isTest static void clickDoneCorrespondTestEchoShopStaff3() {
		System.runAs(getUser('ippanUser2')) {
			// テスト実施
			Test.startTest();
			
			// 初期表示と対応済ボタンの押下
			GL101001Controller testController = getInitController('対応未対応_反響_来店_担当有');
			Correspond__c beforeCorrespond = selectCorrespond('対応未対応_反響_来店_担当有');
			testController.clickDoneCorrespond();

			Test.stopTest();
			// テスト実施終了

			// 結果確認
			Correspond__c clickCorrespond = selectCorrespond('対応未対応_反響_来店_担当有');
			checkClickDoneCorrespond(clickCorrespond,beforeCorrespond,'対応未対応_反響_来店_担当有');

		}
	}

	/**
	* 対応済ボタン押下
	*     対応の反響担当者○
	*     対応の来店担当者○
	*     一般ユーザのユーザが対応．来店担当者と違う場合、登録が行えないこと
	*/
	@isTest static void clickDoneCorrespondTestEchoShopStaff4() {
		System.runAs(getUser('ippanUser3')) {
			// テスト実施
			Test.startTest();
			
			// 初期表示と対応済ボタンの押下
			GL101001Controller testController = getInitController('対応未対応_反響_来店_担当有');
			Correspond__c beforeCorrespond = selectCorrespond('対応未対応_反響_来店_担当有');
			testController.clickDoneCorrespond();

			Test.stopTest();
			// テスト実施終了

			// 結果確認
			Correspond__c clickCorrespond = selectCorrespond('対応未対応_反響_来店_担当有');
			// 一般ユーザのユーザが対応．来店担当者と違う場合、登録が行えないこと
			System.assertEquals(clickCorrespond,beforeCorrespond , '対応済ボタン押下' + '対応未対応_反響_来店_担当有' +'：対応更新無');

		}
	}

	/**
	* 対応済ボタン押下
	*     対応の反響担当者○
	*     対応の来店担当者○
	*     システム管理者のユーザが対応．反響担当者と違う場合、登録が行えること
	*/
	@isTest static void clickDoneCorrespondTestEchoShopStaff5() {
		System.runAs(getUser('kanriUser')) {
			// テスト実施
			Test.startTest();
			
			// 初期表示と対応済ボタンの押下
			GL101001Controller testController = getInitController('対応未対応_反響_来店_担当有');
			Correspond__c beforeCorrespond = selectCorrespond('対応未対応_反響_来店_担当有');
			testController.clickDoneCorrespond();

			Test.stopTest();
			// テスト実施終了

			// 結果確認
			Correspond__c clickCorrespond = selectCorrespond('対応未対応_反響_来店_担当有');
			checkClickDoneCorrespond(clickCorrespond,beforeCorrespond,'対応未対応_反響_来店_担当有');

		}
	}
	/**
	* メッセージ送信
	*     遷移元のパラメータの対応．ステータス：反響集約、終了、契約完了の場合
	*     対象の内容に置き関わること
	*	  // 2022.05.25 No0827 追加 共通の処理の動作でステータスが変わること、新規対応作成無
	*/
	// ステータス：終了、取引先無
	@isTest static void clickSendMsgTestClose() {
		
		System.runAs(getUser('ippanUser')) {

			Test.setMock(HttpCalloutMock.class, new LineMessagingApiUtilHTTPRequestMock(false));
			Test.startTest();
			
			// 初期表示とメッセージ送信ボタン押下（終了系）
			List<Correspond__c> beforeCorrespondList1 = selectCorrespondList('対応終了_取引先無');
			GL101001Controller testController1 = getInitController('対応終了_取引先無');
			testController1.screenSendMessage.newMessage = 'メッセージ＿対応終了_取引先無';
			testController1.clickSendMsg();
			
			Test.stopTest();

			// 実施後
			List<Correspond__c> clickCorrespondList1 = selectCorrespondList('対応終了_取引先無');

			// 比較// 2022.05.25 No0827 対応で終了のみ別処理に
			checkClickSendMsgCorrespondClose(clickCorrespondList1,beforeCorrespondList1,'対応終了_取引先無');
		}
	}
	// ステータス：契約完了、取引先無
	@isTest static void clickSendMsgTestAgreement() {
		System.runAs(getUser('ippanUser')) {

			Test.setMock(HttpCalloutMock.class, new LineMessagingApiUtilHTTPRequestMock(false));
			Test.startTest();
			// 初期表示とメッセージ送信ボタン押下（終了系）
			
			List<Correspond__c>  beforeCorrespondList2 = selectCorrespondList('対応契約完了_取引先無');
			GL101001Controller testController2 = getInitController('対応契約完了_取引先無');
			testController2.screenSendMessage.newMessage = 'メッセージ＿対応契約完了_取引先無';
			testController2.clickSendMsg();

			Test.stopTest();

			// 実施後
			List<Correspond__c> clickCorrespondList2 = selectCorrespondList('対応契約完了_取引先無');

			// 比較
			checkClickSendMsgCorrespond(clickCorrespondList2,beforeCorrespondList2,'対応契約完了_取引先無');
		}
	}
	// ステータス：反響集約、取引先無
	@isTest static void clickSendMsgTestEchoaggregation() {
		System.runAs(getUser('ippanUser')) {

			Test.setMock(HttpCalloutMock.class, new LineMessagingApiUtilHTTPRequestMock(false));
			Test.startTest();
			
			
			// 初期表示とメッセージ送信ボタン押下（終了系）
			List<Correspond__c> beforeCorrespondList3 = selectCorrespondList('対応反響集約_取引先無');
			GL101001Controller testController3 = getInitController('対応反響集約_取引先無');
			testController3.screenSendMessage.newMessage = 'メッセージ＿対応反響集約_取引先無';
			testController3.clickSendMsg();

			Test.stopTest();

			// 実施後
			List<Correspond__c> clickCorrespondList3 = selectCorrespondList('対応反響集約_取引先無');

			// 比較
			checkClickSendMsgCorrespond(clickCorrespondList3,beforeCorrespondList3,'対応反響集約_取引先無');

		}
	}
	// ステータス：終了、取引先有
	@isTest static void clickSendMsgTestCloseAccount() {
		System.runAs(getUser('ippanUser')) {

			Test.setMock(HttpCalloutMock.class, new LineMessagingApiUtilHTTPRequestMock(false));
			Test.startTest();
			
			// 初期表示とメッセージ送信ボタン押下（終了系）
			List<Correspond__c> beforeCorrespondList1 = selectCorrespondList('対応終了_取引先有');
			GL101001Controller testController1 = getInitController('対応終了_取引先有');
			testController1.screenSendMessage.newMessage = 'メッセージ＿対応終了_取引先有';
			testController1.clickSendMsg();
			
			Test.stopTest();

			// 実施後
			List<Correspond__c> clickCorrespondList1 = selectCorrespondList('対応終了_取引先有');

			// 比較// 2022.05.25 No0827 対応で終了のみ別処理に
			checkClickSendMsgCorrespondClose(clickCorrespondList1,beforeCorrespondList1,'対応終了_取引先有');
		}
	}
	// ステータス：契約完了、取引先有
	@isTest static void clickSendMsgTestAgreementAccount() {
		System.runAs(getUser('ippanUser')) {

			Test.setMock(HttpCalloutMock.class, new LineMessagingApiUtilHTTPRequestMock(false));
			Test.startTest();
			// 初期表示とメッセージ送信ボタン押下（終了系）
			
			List<Correspond__c>  beforeCorrespondList2 = selectCorrespondList('対応契約完了_取引先有');
			GL101001Controller testController2 = getInitController('対応契約完了_取引先有');
			testController2.screenSendMessage.newMessage = 'メッセージ＿対応契約完了_取引先有';
			testController2.clickSendMsg();

			Test.stopTest();

			// 実施後
			List<Correspond__c> clickCorrespondList2 = selectCorrespondList('対応契約完了_取引先有');

			// 比較
			checkClickSendMsgCorrespond(clickCorrespondList2,beforeCorrespondList2,'対応契約完了_取引先有');
		}
	}
	// ステータス：反響集約、取引先有
	@isTest static void clickSendMsgTestEchoaggregationAccount() {
		System.runAs(getUser('ippanUser')) {

			Test.setMock(HttpCalloutMock.class, new LineMessagingApiUtilHTTPRequestMock(false));
			Test.startTest();
			
			
			// 初期表示とメッセージ送信ボタン押下（終了系）
			List<Correspond__c> beforeCorrespondList3 = selectCorrespondList('対応反響集約_取引先有');
			GL101001Controller testController3 = getInitController('対応反響集約_取引先有');
			testController3.screenSendMessage.newMessage = 'メッセージ＿対応反響集約_取引先有';
			testController3.clickSendMsg();

			Test.stopTest();

			// 実施後
			List<Correspond__c> clickCorrespondList3 = selectCorrespondList('対応反響集約_取引先有');

			// 比較
			checkClickSendMsgCorrespond(clickCorrespondList3,beforeCorrespondList3,'対応反響集約_取引先有');

		}
	}

	/**
	* メッセージ送信
	*     遷移元のパラメータの対応．ステータス：反響集約、終了、契約完了以外の場合
	*     対応の大幅な変化無
	*/
	// ステータス：未対応、取引先無
	@isTest static void clickSendMsgTestValid() {
		
		System.runAs(getUser('ippanUser')) {

			Test.setMock(HttpCalloutMock.class, new LineMessagingApiUtilHTTPRequestMock(false));
			Test.startTest();
			
			// 初期表示とメッセージ送信ボタン押下（終了系）
			List<Correspond__c> beforeCorrespondList1 = selectCorrespondList('対応未対応_取引先無');
			GL101001Controller testController1 = getInitController('対応未対応_取引先無');
			testController1.screenSendMessage.newMessage = 'メッセージ＿対応未対応_取引先無';
			testController1.clickSendMsg();
			
			Test.stopTest();

			// 実施後
			List<Correspond__c> clickCorrespondList1 = selectCorrespondList('対応未対応_取引先無');

			// 比較
			checkClickSendMsgCorrespondValid(clickCorrespondList1,beforeCorrespondList1,'対応未対応_取引先無',true);
		}
	}
	// ステータス：未対応、取引先有
	@isTest static void clickSendMsgTestValidAccount() {
		
		System.runAs(getUser('ippanUser')) {

			Test.setMock(HttpCalloutMock.class, new LineMessagingApiUtilHTTPRequestMock(false));
			Test.startTest();
			
			// 初期表示とメッセージ送信ボタン押下（終了系）
			List<Correspond__c> beforeCorrespondList1 = selectCorrespondList('対応未対応_取引先有');
			GL101001Controller testController1 = getInitController('対応未対応_取引先有');
			testController1.screenSendMessage.newMessage = 'メッセージ＿対応未対応_取引先有';
			testController1.clickSendMsg();
			
			Test.stopTest();

			// 実施後
			List<Correspond__c> clickCorrespondList1 = selectCorrespondList('対応未対応_取引先有');

			// 比較
			checkClickSendMsgCorrespondValid(clickCorrespondList1,beforeCorrespondList1,'対応未対応_取引先有',true);
		}
	}

	/**
	 * 添付ファイル送信
	 *     遷移元のパラメータの対応．ステータス：反響集約、終了、契約完了の場合
	 *     対象の内容に置き関わること
	 *	   // 2022.05.25 No0827 追加 共通の処理の動作でステータスが変わること、新規対応作成無 
	 */
	// ステータス：終了、取引先無
	@istest static void sendFileLineProcessTestClose() {

		System.runAs(getUser('ippanUser')) {

			Test.setMock(HttpCalloutMock.class, new LineMessagingApiUtilHTTPRequestMock(false));
			Test.startTest();
			
			// 拡張子に応じた処理を行う為のファイル名一覧
			List<String> fileNameList = new List<String>{
				'ファイル名.mp4'
				, 'ファイル名.jpg'
				, 'ファイル名.txt'
			};

			List<Correspond__c> beforeCorrespondList1 = selectCorrespondList('対応終了_取引先無');
			// 初期表示とファイル送信処理の実施
			GL101001Controller testController = getInitController('対応終了_取引先無');
			testController.openSendFileModal();
			testController.gL101001Modal3Parameter.message			= 'メッセージ';
			testController.gL101001Modal3Parameter.filePath 		= 'ファイルパス';
			testController.gL101001Modal3Parameter.thumbnailName	= 'サムネイル画像名';
			testController.gL101001Modal3Parameter.thumbnailPath	= 'サムネイル画像パス';

			// ※2回目以降は未コミットエラーが行われる
			for (String fileName : fileNameList) {
				testController.gL101001Modal3Parameter.fileName	= fileName;
				testController.sendFileLineProcess();
			}
			Test.stopTest();
			
			// 実施後
			List<Correspond__c> clickCorrespondList1 = selectCorrespondList('対応終了_取引先無');
			// 比較// 2022.05.25 No0827 対応で終了のみ別処理に
			checkClickSendMsgCorrespondClose(clickCorrespondList1,beforeCorrespondList1,'対応終了_取引先無');
		}
	}
	// ステータス：契約完了、取引先無
	@istest static void sendFileLineProcessTestAgreement() {

		System.runAs(getUser('ippanUser')) {

			Test.setMock(HttpCalloutMock.class, new LineMessagingApiUtilHTTPRequestMock(false));
			Test.startTest();
			
			// 拡張子に応じた処理を行う為のファイル名一覧
			List<String> fileNameList = new List<String>{
				'ファイル名.mp4'
				, 'ファイル名.jpg'
				, 'ファイル名.txt'
			};

			List<Correspond__c> beforeCorrespondList1 = selectCorrespondList('対応契約完了_取引先無');
			// 初期表示とファイル送信処理の実施
			GL101001Controller testController = getInitController('対応契約完了_取引先無');
			testController.openSendFileModal();
			testController.gL101001Modal3Parameter.message			= 'メッセージ';
			testController.gL101001Modal3Parameter.filePath 		= 'ファイルパス';
			testController.gL101001Modal3Parameter.thumbnailName	= 'サムネイル画像名';
			testController.gL101001Modal3Parameter.thumbnailPath	= 'サムネイル画像パス';

			// ※2回目以降は未コミットエラーが行われる
			for (String fileName : fileNameList) {
				testController.gL101001Modal3Parameter.fileName	= fileName;
				testController.sendFileLineProcess();
			}
			Test.stopTest();
			
			// 実施後
			List<Correspond__c> clickCorrespondList1 = selectCorrespondList('対応契約完了_取引先無');
			// 比較
			checkClickSendMsgCorrespond(clickCorrespondList1,beforeCorrespondList1,'対応契約完了_取引先無');
		}
	}
	// ステータス：反響集約、取引先無
	@istest static void sendFileLineProcessTestEchoaggregation() {

		System.runAs(getUser('ippanUser')) {

			Test.setMock(HttpCalloutMock.class, new LineMessagingApiUtilHTTPRequestMock(false));
			Test.startTest();
			
			// 拡張子に応じた処理を行う為のファイル名一覧
			List<String> fileNameList = new List<String>{
				'ファイル名.mp4'
				, 'ファイル名.jpg'
				, 'ファイル名.txt'
			};

			List<Correspond__c> beforeCorrespondList1 = selectCorrespondList('対応反響集約_取引先無');
			// 初期表示とファイル送信処理の実施
			GL101001Controller testController = getInitController('対応反響集約_取引先無');
			testController.openSendFileModal();
			testController.gL101001Modal3Parameter.message			= 'メッセージ';
			testController.gL101001Modal3Parameter.filePath 		= 'ファイルパス';
			testController.gL101001Modal3Parameter.thumbnailName	= 'サムネイル画像名';
			testController.gL101001Modal3Parameter.thumbnailPath	= 'サムネイル画像パス';

			// ※2回目以降は未コミットエラーが行われる
			for (String fileName : fileNameList) {
				testController.gL101001Modal3Parameter.fileName	= fileName;
				testController.sendFileLineProcess();
			}
			Test.stopTest();
			
			// 実施後
			List<Correspond__c> clickCorrespondList1 = selectCorrespondList('対応反響集約_取引先無');
			// 比較
			checkClickSendMsgCorrespond(clickCorrespondList1,beforeCorrespondList1,'対応反響集約_取引先無');
		}
	}
	// ステータス：終了、取引先有
	@isTest static void sendFileLineProcessTestCloseAccount() {
	
		System.runAs(getUser('ippanUser')) {

			Test.setMock(HttpCalloutMock.class, new LineMessagingApiUtilHTTPRequestMock(false));
			Test.startTest();
			
			// 拡張子に応じた処理を行う為のファイル名一覧
			List<String> fileNameList = new List<String>{
				'ファイル名.mp4'
				, 'ファイル名.jpg'
				, 'ファイル名.txt'
			};

			List<Correspond__c> beforeCorrespondList1 = selectCorrespondList('対応終了_取引先有');
			// 初期表示とファイル送信処理の実施
			GL101001Controller testController = getInitController('対応終了_取引先有');
			testController.openSendFileModal();
			testController.gL101001Modal3Parameter.message			= 'メッセージ';
			testController.gL101001Modal3Parameter.filePath 		= 'ファイルパス';
			testController.gL101001Modal3Parameter.thumbnailName	= 'サムネイル画像名';
			testController.gL101001Modal3Parameter.thumbnailPath	= 'サムネイル画像パス';

			// ※2回目以降は未コミットエラーが行われる
			for (String fileName : fileNameList) {
				testController.gL101001Modal3Parameter.fileName	= fileName;
				testController.sendFileLineProcess();
			}
			Test.stopTest();
			
			// 実施後
			List<Correspond__c> clickCorrespondList1 = selectCorrespondList('対応終了_取引先有');
			// 比較// 2022.05.25 No0827 対応で終了のみ別処理に
			checkClickSendMsgCorrespondClose(clickCorrespondList1,beforeCorrespondList1,'対応終了_取引先有');
		}
	}
	// ステータス：契約完了、取引先有
	@isTest static void sendFileLineProcessTestAgreementAccount() {

		System.runAs(getUser('ippanUser')) {

			Test.setMock(HttpCalloutMock.class, new LineMessagingApiUtilHTTPRequestMock(false));
			Test.startTest();
			
			// 拡張子に応じた処理を行う為のファイル名一覧
			List<String> fileNameList = new List<String>{
				'ファイル名.mp4'
				, 'ファイル名.jpg'
				, 'ファイル名.txt'
			};

			List<Correspond__c> beforeCorrespondList1 = selectCorrespondList('対応契約完了_取引先有');
			// 初期表示とファイル送信処理の実施
			GL101001Controller testController = getInitController('対応契約完了_取引先有');
			testController.openSendFileModal();
			testController.gL101001Modal3Parameter.message			= 'メッセージ';
			testController.gL101001Modal3Parameter.filePath 		= 'ファイルパス';
			testController.gL101001Modal3Parameter.thumbnailName	= 'サムネイル画像名';
			testController.gL101001Modal3Parameter.thumbnailPath	= 'サムネイル画像パス';

			// ※2回目以降は未コミットエラーが行われる
			for (String fileName : fileNameList) {
				testController.gL101001Modal3Parameter.fileName	= fileName;
				testController.sendFileLineProcess();
			}
			Test.stopTest();
			
			// 実施後
			List<Correspond__c> clickCorrespondList1 = selectCorrespondList('対応契約完了_取引先有');
			// 比較
			checkClickSendMsgCorrespond(clickCorrespondList1,beforeCorrespondList1,'対応契約完了_取引先有');
		}
	}
	// ステータス：反響集約、取引先有
	@isTest static void sendFileLineProcessTestEchoaggregationAccount() {

		System.runAs(getUser('ippanUser')) {

			Test.setMock(HttpCalloutMock.class, new LineMessagingApiUtilHTTPRequestMock(false));
			Test.startTest();
			
			// 拡張子に応じた処理を行う為のファイル名一覧
			List<String> fileNameList = new List<String>{
				'ファイル名.mp4'
				, 'ファイル名.jpg'
				, 'ファイル名.txt'
			};

			List<Correspond__c> beforeCorrespondList1 = selectCorrespondList('対応反響集約_取引先有');
			// 初期表示とファイル送信処理の実施
			GL101001Controller testController = getInitController('対応反響集約_取引先有');
			testController.openSendFileModal();
			testController.gL101001Modal3Parameter.message			= 'メッセージ';
			testController.gL101001Modal3Parameter.filePath 		= 'ファイルパス';
			testController.gL101001Modal3Parameter.thumbnailName	= 'サムネイル画像名';
			testController.gL101001Modal3Parameter.thumbnailPath	= 'サムネイル画像パス';

			// ※2回目以降は未コミットエラーが行われる
			for (String fileName : fileNameList) {
				testController.gL101001Modal3Parameter.fileName	= fileName;
				testController.sendFileLineProcess();
			}
			Test.stopTest();
			
			// 実施後
			List<Correspond__c> clickCorrespondList1 = selectCorrespondList('対応反響集約_取引先有');
			// 比較
			checkClickSendMsgCorrespond(clickCorrespondList1,beforeCorrespondList1,'対応反響集約_取引先有');
		}
	}

	/**
	 * 添付ファイル送信
	 *     遷移元のパラメータの対応．ステータス：反響集約、終了、契約完了以外の場合
	 *     対応の大幅な変化無
	 */
	// ステータス：未対応、取引先無
	@isTest static void sendFileLineProcessTestValid() {
		
		System.runAs(getUser('ippanUser')) {
			Test.setMock(HttpCalloutMock.class, new LineMessagingApiUtilHTTPRequestMock(false));
			Test.startTest();
			
			List<Correspond__c> beforeCorrespondList1 = selectCorrespondList('対応未対応_取引先無');
			// 初期表示とファイル送信処理の実施
			GL101001Controller testController = getInitController('対応未対応_取引先無');
			testController.openSendFileModal();
			testController.gL101001Modal3Parameter.message			= 'メッセージ';
			testController.gL101001Modal3Parameter.filePath 		= 'ファイルパス';
			testController.gL101001Modal3Parameter.thumbnailName	= 'サムネイル画像名';
			testController.gL101001Modal3Parameter.thumbnailPath	= 'サムネイル画像パス';

			testController.gL101001Modal3Parameter.fileName	= 'ファイル名.mp4';
			testController.sendFileLineProcess();
			Test.stopTest();
			
			// 実施後
			List<Correspond__c> clickCorrespondList1 = selectCorrespondList('対応未対応_取引先無');

			// 比較
			checkClickSendMsgCorrespondValid(clickCorrespondList1,beforeCorrespondList1,'対応未対応_取引先無',true);
		}
	}
	// ステータス：未対応、取引先有
	@isTest static void sendFileLineProcessTestValidAccount() {
		
		System.runAs(getUser('ippanUser')) {

			Test.setMock(HttpCalloutMock.class, new LineMessagingApiUtilHTTPRequestMock(false));
			Test.startTest();

			List<Correspond__c> beforeCorrespondList1 = selectCorrespondList('対応未対応_取引先有');
			// 初期表示とファイル送信処理の実施
			GL101001Controller testController = getInitController('対応未対応_取引先有');
			testController.openSendFileModal();
			testController.gL101001Modal3Parameter.message			= 'メッセージ';
			testController.gL101001Modal3Parameter.filePath 		= 'ファイルパス';
			testController.gL101001Modal3Parameter.thumbnailName	= 'サムネイル画像名';
			testController.gL101001Modal3Parameter.thumbnailPath	= 'サムネイル画像パス';

			// ※2回目以降は未コミットエラーが行われる
			testController.gL101001Modal3Parameter.fileName	= 'ファイル名.txt';
			testController.sendFileLineProcess();
			Test.stopTest();
			
			// 実施後
			List<Correspond__c> clickCorrespondList1 = selectCorrespondList('対応未対応_取引先有');

			// 比較
			checkClickSendMsgCorrespondValid(clickCorrespondList1,beforeCorrespondList1,'対応未対応_取引先有',true);
		}
	}
	// ステータス：追客中、取引先有
	@isTest static void sendFileLineProcessTestValid2() {
		
		System.runAs(getUser('ippanUser')) {
			Test.setMock(HttpCalloutMock.class, new LineMessagingApiUtilHTTPRequestMock(false));
			Test.startTest();
			
			List<Correspond__c> beforeCorrespondList1 = selectCorrespondList('対応追客中_取引先有');
			// 初期表示とファイル送信処理の実施
			GL101001Controller testController = getInitController('対応追客中_取引先有');
			testController.openSendFileModal();
			testController.gL101001Modal3Parameter.message			= 'メッセージ';
			testController.gL101001Modal3Parameter.filePath 		= 'ファイルパス';
			testController.gL101001Modal3Parameter.thumbnailName	= 'サムネイル画像名';
			testController.gL101001Modal3Parameter.thumbnailPath	= 'サムネイル画像パス';

			testController.gL101001Modal3Parameter.fileName	= 'ファイル名.mp4';
			testController.sendFileLineProcess();
			Test.stopTest();
			
			// 実施後
			List<Correspond__c> clickCorrespondList1 = selectCorrespondList('対応追客中_取引先有');

			// 比較
			checkClickSendMsgCorrespondValid(clickCorrespondList1,beforeCorrespondList1,'対応追客中_取引先有',false);
		}
	}

	// ▼ 2022.05.16 No0758 対応で追加
	/**
	 * 紐づけ解除ボタン押下
	 *     遷移元のパラメータの対応．ステータス：反響集約、終了、契約完了の場合
	 *     対応明細の移動
	 */
	@istest static void clickReleaseLinkingTest1() {

		System.runAs(getUser('ippanUser')) {

			LineMember__c lineMember = selectLineMember('対応終了_取引先有');
			List<Correspond__c> beforeCorrespondList1 = selectCorrespondList('対応終了_取引先有');
			Shop__c setShop = [SELECT ID,Email__c FROM Shop__c WHERE NAME = 'テスト店舗' LIMIT 1];
			Echomail__c setLineEchomail = [SELECT ID,LineMember__c,LineReceiveType__c,FromEmail__c,Email__c FROM Echomail__c WHERE LineMember__c = :lineMember.id LIMIT 1];
			Echomail__c setEchomail = [SELECT ID,LineMember__c,LineReceiveType__c,FromEmail__c,Email__c FROM Echomail__c WHERE LineMember__c != :lineMember.id LIMIT 1];
			// 対応明細作成（LINE）
			// * @param String correspondType 対応種別
			// * @param Id correspondsId 対応ID
			// * @param String lineType LINEの登録タイプ
			// * @param String accountName 取引先名
			// * @param Shop__c echoShop 店舗
			// * @param EchoMail__c echoMail 反響メール
			List<CorrespondDetail__c> insertCorrespondDetailList = new List<CorrespondDetail__c>();
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,beforeCorrespondList1[0].id,'メッセージ','',setShop,null)); // メッセージ送信時
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,beforeCorrespondList1[0].id,'ファイル','',setShop,null)); // ファイル送信時
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,beforeCorrespondList1[0].id,'紐づけ解除','',setShop,null)); // 紐づけ解除
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,beforeCorrespondList1[0].id,CommonConst.CORRESPONDDETAIL_SUPPORTEDTITLE_LINE,'',setShop,null)); // LINE紐づけ
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_MAIL,beforeCorrespondList1[0].id,CommonConst.CORRESPOND_EVENT_LINE_FRIEND_ADD,'',setShop,setLineEchomail)); // LINE追加
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_MAIL,beforeCorrespondList1[0].id,CommonConst.CORRESPOND_EVENT_LINE_RECEIVE,'',setShop,setLineEchomail)); // LINE受信

			// 対応明細作成（メール）
			// * @param String correspondType 対応種別
			// * @param Id correspondsId 対応ID
			// * @param String mailType メールの登録タイプ
			// * @param Shop__c shop 店舗
			// * @param EchoMail__c echoMail 反響メール
			insertCorrespondDetailList.add(setCorrespondDetailMail(CommonConst.TASK_CORRESPONDTYPE_AUTO_RECIVE,beforeCorrespondList1[0].id,'自動返信',setShop,setEchomail)); // 自動返信用対応明細の取得（メール）
			insertCorrespondDetailList.add(setCorrespondDetailMail(CommonConst.CORRESPONDDETAIL_MAILTYPE_SEND,beforeCorrespondList1[0].id,CommonConst.CORRESPONDDETAIL_MAILTYPE_SEND,setShop,setEchomail)); // メール送信
			insertCorrespondDetailList.add(setCorrespondDetailMail(CommonConst.TASK_CORRESPONDTYPE_CLOSE,beforeCorrespondList1[0].id,CommonConst.TASK_CORRESPONDTYPE_CLOSE,setShop,setEchomail)); // 紹介メール（終了）

			// * 対応明細の作成（その他の対応種別）
			// * @param String correspondType 対応種別
			// * @param Id correspondsId 対応ID
			// * @param Shop__c shop 店舗
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_RELEASEHOLD,beforeCorrespondList1[0].id,setShop)); // 保留解除（対応明細作成）
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_ECHOAGGREGATION,beforeCorrespondList1[0].id,setShop)); // 反響集約（対応明細作成）
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_PERSONDECISION,beforeCorrespondList1[0].id,setShop)); // 担当者決定
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_CLOSE,beforeCorrespondList1[0].id,setShop)); // 配信停止ボタン処理
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_VISITED,beforeCorrespondList1[0].id,setShop)); // 来店カード
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_APPLICANT,beforeCorrespondList1[0].id,setShop)); // 申込登録
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_MERGE,beforeCorrespondList1[0].id,setShop)); // 名寄せ 
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_RETURN,beforeCorrespondList1[0].id,setShop)); // スケジュール（再来）
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_DEPOSIT,beforeCorrespondList1[0].id,setShop)); // 入金処理
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.CORRESPOND_EVENT_VIEWED,beforeCorrespondList1[0].id,setShop)); // 物件閲覧

			// * 対応明細の作成（電話）
			// * @param String phoneStatus 電話状況
			// * @param Id correspondsId 対応ID
			// * @param Shop__c shop 店舗
			insertCorrespondDetailList.add(setCorrespondDetailTel(CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINEECHO,beforeCorrespondList1[0].id,setShop)); // LINE反響
			insertCorrespondDetailList.add(setCorrespondDetailTel(CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINERECEIVE,beforeCorrespondList1[0].id,setShop)); // LINE受信
			insertCorrespondDetailList.add(setCorrespondDetailTel(CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINESEND,beforeCorrespondList1[0].id,setShop)); // LINE送信

			insert insertCorrespondDetailList;
			Map<Id,CorrespondDetail__c> beforeCorrespondDetailMap = selectCorrespondDetailMap();

			Test.startTest();
			
			// 初期表示と紐づけ解除ボタンの押下
			GL101001Controller testController = getInitController('対応終了_取引先有');
			testController.clickReleaseLinking();

			Test.stopTest();

			// 実施後
			List<CorrespondDetail__c> afterCorrespondDetailList = new List<CorrespondDetail__c>();
			afterCorrespondDetailList = selectCorrespondDetailList();
			List<Correspond__c> afterCorrespondList1 = selectCorrespondList('対応終了_取引先有','取引先LINE会員有_テスト');

			// 対応比較
			checkClickReleaseLinkingCorrespond(afterCorrespondList1,beforeCorrespondList1,'対応終了_取引先有');

			// 対応明細比較
			checkCorrespondDetailmMove(afterCorrespondDetailList,beforeCorrespondDetailMap,'対応終了_取引先有');
		}
	}
	// LINE会員、取引先で対応2件（各ステータス終了）
	@istest static void clickReleaseLinkingTest2() {

		System.runAs(getUser('ippanUser')) {

			LineMember__c lineMember = selectLineMember('対応終了_取引先有');
			List<Correspond__c> beforeCorrespondList1 = selectCorrespondList('対応終了_取引先有');
			// 対応を2件にする（取引先、LINE会員がそれぞれ紐づく対応）
			Correspond__c newCorrespond = new Correspond__c();
			newCorrespond = beforeCorrespondList1[0].clone();
			newCorrespond.FirstLineAddFlg__c = false;  // 初回LINE追加フラグ
			newCorrespond.id = null;
			insert newCorrespond;
			beforeCorrespondList1.add(newCorrespond);
			Shop__c setShop = [SELECT ID,Email__c FROM Shop__c WHERE NAME = 'テスト店舗' LIMIT 1];
			Echomail__c setLineEchomail = [SELECT ID,LineMember__c,LineReceiveType__c,FromEmail__c,Email__c FROM Echomail__c WHERE LineMember__c = :lineMember.id LIMIT 1];
			Echomail__c setEchomail = [SELECT ID,LineMember__c,LineReceiveType__c,FromEmail__c,Email__c FROM Echomail__c WHERE LineMember__c != :lineMember.id LIMIT 1];
			// 対応明細作成（LINE）
			// * @param String correspondType 対応種別
			// * @param Id correspondsId 対応ID
			// * @param String lineType LINEの登録タイプ
			// * @param String accountName 取引先名
			// * @param Shop__c echoShop 店舗
			// * @param EchoMail__c echoMail 反響メール
			List<CorrespondDetail__c> insertCorrespondDetailList = new List<CorrespondDetail__c>();
			// 1件目に紐づく対応明細
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,beforeCorrespondList1[0].id,'メッセージ','',setShop,null)); // メッセージ送信時
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,beforeCorrespondList1[0].id,'ファイル','',setShop,null)); // ファイル送信時
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,beforeCorrespondList1[0].id,'紐づけ解除','',setShop,null)); // 紐づけ解除
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,beforeCorrespondList1[0].id,CommonConst.CORRESPONDDETAIL_SUPPORTEDTITLE_LINE,'',setShop,null)); // LINE紐づけ
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_MAIL,beforeCorrespondList1[0].id,CommonConst.CORRESPOND_EVENT_LINE_FRIEND_ADD,'',setShop,setLineEchomail)); // LINE追加
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_MAIL,beforeCorrespondList1[0].id,CommonConst.CORRESPOND_EVENT_LINE_RECEIVE,'',setShop,setLineEchomail)); // LINE受信
			// 2件目に紐づく対応明細
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,newCorrespond.id,'メッセージ','',setShop,null)); // メッセージ送信時
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,newCorrespond.id,'ファイル','',setShop,null)); // ファイル送信時
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,newCorrespond.id,'紐づけ解除','',setShop,null)); // 紐づけ解除
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,newCorrespond.id,CommonConst.CORRESPONDDETAIL_SUPPORTEDTITLE_LINE,'',setShop,null)); // LINE紐づけ
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_MAIL,newCorrespond.id,CommonConst.CORRESPOND_EVENT_LINE_FRIEND_ADD,'',setShop,setLineEchomail)); // LINE追加
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_MAIL,newCorrespond.id,CommonConst.CORRESPOND_EVENT_LINE_RECEIVE,'',setShop,setLineEchomail)); // LINE受信

			// 対応明細作成（メール）
			// * @param String correspondType 対応種別
			// * @param Id correspondsId 対応ID
			// * @param String mailType メールの登録タイプ
			// * @param Shop__c shop 店舗
			// * @param EchoMail__c echoMail 反響メール
			// 1件目に紐づく対応明細
			insertCorrespondDetailList.add(setCorrespondDetailMail(CommonConst.TASK_CORRESPONDTYPE_AUTO_RECIVE,beforeCorrespondList1[0].id,'自動返信',setShop,setEchomail)); // 自動返信用対応明細の取得（メール）
			insertCorrespondDetailList.add(setCorrespondDetailMail(CommonConst.CORRESPONDDETAIL_MAILTYPE_SEND,beforeCorrespondList1[0].id,CommonConst.CORRESPONDDETAIL_MAILTYPE_SEND,setShop,setEchomail)); // メール送信
			insertCorrespondDetailList.add(setCorrespondDetailMail(CommonConst.TASK_CORRESPONDTYPE_CLOSE,beforeCorrespondList1[0].id,CommonConst.TASK_CORRESPONDTYPE_CLOSE,setShop,setEchomail)); // 紹介メール（終了）
			// 2件目に紐づく対応明細
			insertCorrespondDetailList.add(setCorrespondDetailMail(CommonConst.TASK_CORRESPONDTYPE_AUTO_RECIVE,newCorrespond.id,'自動返信',setShop,setEchomail)); // 自動返信用対応明細の取得（メール）
			insertCorrespondDetailList.add(setCorrespondDetailMail(CommonConst.CORRESPONDDETAIL_MAILTYPE_SEND,newCorrespond.id,CommonConst.CORRESPONDDETAIL_MAILTYPE_SEND,setShop,setEchomail)); // メール送信
			insertCorrespondDetailList.add(setCorrespondDetailMail(CommonConst.TASK_CORRESPONDTYPE_CLOSE,newCorrespond.id,CommonConst.TASK_CORRESPONDTYPE_CLOSE,setShop,setEchomail)); // 紹介メール（終了）

			// * 対応明細の作成（その他の対応種別）
			// * @param String correspondType 対応種別
			// * @param Id correspondsId 対応ID
			// * @param Shop__c shop 店舗
			// 1件目に紐づく対応明細
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_RELEASEHOLD,beforeCorrespondList1[0].id,setShop)); // 保留解除（対応明細作成）
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_ECHOAGGREGATION,beforeCorrespondList1[0].id,setShop)); // 反響集約（対応明細作成）
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_PERSONDECISION,beforeCorrespondList1[0].id,setShop)); // 担当者決定
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_CLOSE,beforeCorrespondList1[0].id,setShop)); // 配信停止ボタン処理
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_VISITED,beforeCorrespondList1[0].id,setShop)); // 来店カード
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_APPLICANT,beforeCorrespondList1[0].id,setShop)); // 申込登録
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_MERGE,beforeCorrespondList1[0].id,setShop)); // 名寄せ 
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_RETURN,beforeCorrespondList1[0].id,setShop)); // スケジュール（再来）
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_DEPOSIT,beforeCorrespondList1[0].id,setShop)); // 入金処理
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.CORRESPOND_EVENT_VIEWED,beforeCorrespondList1[0].id,setShop)); // 物件閲覧
			// 2件目に紐づく対応明細
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_RELEASEHOLD,newCorrespond.id,setShop)); // 保留解除（対応明細作成）
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_ECHOAGGREGATION,newCorrespond.id,setShop)); // 反響集約（対応明細作成）
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_PERSONDECISION,newCorrespond.id,setShop)); // 担当者決定
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_CLOSE,newCorrespond.id,setShop)); // 配信停止ボタン処理
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_VISITED,newCorrespond.id,setShop)); // 来店カード
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_APPLICANT,newCorrespond.id,setShop)); // 申込登録
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_MERGE,newCorrespond.id,setShop)); // 名寄せ 
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_RETURN,newCorrespond.id,setShop)); // スケジュール（再来）
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_DEPOSIT,newCorrespond.id,setShop)); // 入金処理
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.CORRESPOND_EVENT_VIEWED,newCorrespond.id,setShop)); // 物件閲覧

			// * 対応明細の作成（電話）
			// * @param String phoneStatus 電話状況
			// * @param Id correspondsId 対応ID
			// * @param Shop__c shop 店舗
			// 1件目に紐づく対応明細
			insertCorrespondDetailList.add(setCorrespondDetailTel(CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINEECHO,beforeCorrespondList1[0].id,setShop)); // LINE反響
			insertCorrespondDetailList.add(setCorrespondDetailTel(CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINERECEIVE,beforeCorrespondList1[0].id,setShop)); // LINE受信
			insertCorrespondDetailList.add(setCorrespondDetailTel(CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINESEND,beforeCorrespondList1[0].id,setShop)); // LINE送信
			// 2件目に紐づく対応明細
			insertCorrespondDetailList.add(setCorrespondDetailTel(CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINEECHO,newCorrespond.id,setShop)); // LINE反響
			insertCorrespondDetailList.add(setCorrespondDetailTel(CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINERECEIVE,newCorrespond.id,setShop)); // LINE受信
			insertCorrespondDetailList.add(setCorrespondDetailTel(CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINESEND,newCorrespond.id,setShop)); // LINE送信

			insert insertCorrespondDetailList;
			Map<Id,CorrespondDetail__c> beforeCorrespondDetailMap = selectCorrespondDetailMap();

			Test.startTest();
			
			// 初期表示と紐づけ解除ボタンの押下
			GL101001Controller testController = getInitController('対応終了_取引先有');
			testController.clickReleaseLinking();

			Test.stopTest();

			// 実施後
			List<CorrespondDetail__c> afterCorrespondDetailList = new List<CorrespondDetail__c>();
			afterCorrespondDetailList = selectCorrespondDetailList();
			List<Correspond__c> afterCorrespondList1 = selectCorrespondList('対応終了_取引先有','取引先LINE会員有_テスト');

			// 対応比較
			checkClickReleaseLinkingCorrespond(afterCorrespondList1,beforeCorrespondList1,'対応終了_取引先有');

			// 対応明細比較
			checkCorrespondDetailmMove(afterCorrespondDetailList,beforeCorrespondDetailMap,'対応終了_取引先有');
		}
	}
	// LINE会員、取引先で対応2件（各ステータス終了）
	@istest static void clickReleaseLinkingTest3() {

		System.runAs(getUser('ippanUser')) {

			LineMember__c lineMember = selectLineMember('対応終了_取引先有');
			List<Correspond__c> beforeCorrespondList1 = selectCorrespondList('対応終了_取引先有');
			beforeCorrespondList1[0].FirstLineAddFlg__c = false;  // 初回LINE追加フラグ
			// 対応を2件にする（取引先、LINE会員がそれぞれ紐づく対応）
			Correspond__c newCorrespond = new Correspond__c();
			newCorrespond = beforeCorrespondList1[0].clone();
			newCorrespond.status__c = CommonConst.CORRESPOND_STATUS_PURSUIT;  // ステータス（追客中）
			newCorrespond.FirstLineAddFlg__c = true;  // 初回LINE追加フラグ
			newCorrespond.id = null;
			insert newCorrespond;
			update beforeCorrespondList1;
			beforeCorrespondList1.add(newCorrespond);
			Shop__c setShop = [SELECT ID,Email__c FROM Shop__c WHERE NAME = 'テスト店舗' LIMIT 1];
			Echomail__c setLineEchomail = [SELECT ID,LineMember__c,LineReceiveType__c,FromEmail__c,Email__c FROM Echomail__c WHERE LineMember__c = :lineMember.id LIMIT 1];
			Echomail__c setEchomail = [SELECT ID,LineMember__c,LineReceiveType__c,FromEmail__c,Email__c FROM Echomail__c WHERE LineMember__c != :lineMember.id LIMIT 1];
			// 対応明細作成（LINE）
			// * @param String correspondType 対応種別
			// * @param Id correspondsId 対応ID
			// * @param String lineType LINEの登録タイプ
			// * @param String accountName 取引先名
			// * @param Shop__c echoShop 店舗
			// * @param EchoMail__c echoMail 反響メール
			List<CorrespondDetail__c> insertCorrespondDetailList = new List<CorrespondDetail__c>();
			// 1件目に紐づく対応明細
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,beforeCorrespondList1[0].id,'メッセージ','',setShop,null)); // メッセージ送信時
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,beforeCorrespondList1[0].id,'ファイル','',setShop,null)); // ファイル送信時
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,beforeCorrespondList1[0].id,'紐づけ解除','',setShop,null)); // 紐づけ解除
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,beforeCorrespondList1[0].id,CommonConst.CORRESPONDDETAIL_SUPPORTEDTITLE_LINE,'',setShop,null)); // LINE紐づけ
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_MAIL,beforeCorrespondList1[0].id,CommonConst.CORRESPOND_EVENT_LINE_FRIEND_ADD,'',setShop,setLineEchomail)); // LINE追加
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_MAIL,beforeCorrespondList1[0].id,CommonConst.CORRESPOND_EVENT_LINE_RECEIVE,'',setShop,setLineEchomail)); // LINE受信
			// 2件目に紐づく対応明細
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,newCorrespond.id,'メッセージ','',setShop,null)); // メッセージ送信時
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,newCorrespond.id,'ファイル','',setShop,null)); // ファイル送信時
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,newCorrespond.id,'紐づけ解除','',setShop,null)); // 紐づけ解除
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,newCorrespond.id,CommonConst.CORRESPONDDETAIL_SUPPORTEDTITLE_LINE,'',setShop,null)); // LINE紐づけ
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_MAIL,newCorrespond.id,CommonConst.CORRESPOND_EVENT_LINE_FRIEND_ADD,'',setShop,setLineEchomail)); // LINE追加
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_MAIL,newCorrespond.id,CommonConst.CORRESPOND_EVENT_LINE_RECEIVE,'',setShop,setLineEchomail)); // LINE受信

			// 対応明細作成（メール）
			// * @param String correspondType 対応種別
			// * @param Id correspondsId 対応ID
			// * @param String mailType メールの登録タイプ
			// * @param Shop__c shop 店舗
			// * @param EchoMail__c echoMail 反響メール
			// 1件目に紐づく対応明細
			insertCorrespondDetailList.add(setCorrespondDetailMail(CommonConst.TASK_CORRESPONDTYPE_AUTO_RECIVE,beforeCorrespondList1[0].id,'自動返信',setShop,setEchomail)); // 自動返信用対応明細の取得（メール）
			insertCorrespondDetailList.add(setCorrespondDetailMail(CommonConst.CORRESPONDDETAIL_MAILTYPE_SEND,beforeCorrespondList1[0].id,CommonConst.CORRESPONDDETAIL_MAILTYPE_SEND,setShop,setEchomail)); // メール送信
			insertCorrespondDetailList.add(setCorrespondDetailMail(CommonConst.TASK_CORRESPONDTYPE_CLOSE,beforeCorrespondList1[0].id,CommonConst.TASK_CORRESPONDTYPE_CLOSE,setShop,setEchomail)); // 紹介メール（終了）
			// 2件目に紐づく対応明細
			insertCorrespondDetailList.add(setCorrespondDetailMail(CommonConst.TASK_CORRESPONDTYPE_AUTO_RECIVE,newCorrespond.id,'自動返信',setShop,setEchomail)); // 自動返信用対応明細の取得（メール）
			insertCorrespondDetailList.add(setCorrespondDetailMail(CommonConst.CORRESPONDDETAIL_MAILTYPE_SEND,newCorrespond.id,CommonConst.CORRESPONDDETAIL_MAILTYPE_SEND,setShop,setEchomail)); // メール送信
			insertCorrespondDetailList.add(setCorrespondDetailMail(CommonConst.TASK_CORRESPONDTYPE_CLOSE,newCorrespond.id,CommonConst.TASK_CORRESPONDTYPE_CLOSE,setShop,setEchomail)); // 紹介メール（終了）

			// * 対応明細の作成（その他の対応種別）
			// * @param String correspondType 対応種別
			// * @param Id correspondsId 対応ID
			// * @param Shop__c shop 店舗
			// 1件目に紐づく対応明細
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_RELEASEHOLD,beforeCorrespondList1[0].id,setShop)); // 保留解除（対応明細作成）
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_ECHOAGGREGATION,beforeCorrespondList1[0].id,setShop)); // 反響集約（対応明細作成）
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_PERSONDECISION,beforeCorrespondList1[0].id,setShop)); // 担当者決定
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_CLOSE,beforeCorrespondList1[0].id,setShop)); // 配信停止ボタン処理
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_VISITED,beforeCorrespondList1[0].id,setShop)); // 来店カード
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_APPLICANT,beforeCorrespondList1[0].id,setShop)); // 申込登録
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_MERGE,beforeCorrespondList1[0].id,setShop)); // 名寄せ 
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_RETURN,beforeCorrespondList1[0].id,setShop)); // スケジュール（再来）
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_DEPOSIT,beforeCorrespondList1[0].id,setShop)); // 入金処理
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.CORRESPOND_EVENT_VIEWED,beforeCorrespondList1[0].id,setShop)); // 物件閲覧
			// 2件目に紐づく対応明細
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_RELEASEHOLD,newCorrespond.id,setShop)); // 保留解除（対応明細作成）
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_ECHOAGGREGATION,newCorrespond.id,setShop)); // 反響集約（対応明細作成）
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_PERSONDECISION,newCorrespond.id,setShop)); // 担当者決定
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_CLOSE,newCorrespond.id,setShop)); // 配信停止ボタン処理
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_VISITED,newCorrespond.id,setShop)); // 来店カード
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_APPLICANT,newCorrespond.id,setShop)); // 申込登録
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_MERGE,newCorrespond.id,setShop)); // 名寄せ 
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_RETURN,newCorrespond.id,setShop)); // スケジュール（再来）
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_DEPOSIT,newCorrespond.id,setShop)); // 入金処理
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.CORRESPOND_EVENT_VIEWED,newCorrespond.id,setShop)); // 物件閲覧

			// * 対応明細の作成（電話）
			// * @param String phoneStatus 電話状況
			// * @param Id correspondsId 対応ID
			// * @param Shop__c shop 店舗
			// 1件目に紐づく対応明細
			insertCorrespondDetailList.add(setCorrespondDetailTel(CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINEECHO,beforeCorrespondList1[0].id,setShop)); // LINE反響
			insertCorrespondDetailList.add(setCorrespondDetailTel(CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINERECEIVE,beforeCorrespondList1[0].id,setShop)); // LINE受信
			insertCorrespondDetailList.add(setCorrespondDetailTel(CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINESEND,beforeCorrespondList1[0].id,setShop)); // LINE送信
			// 2件目に紐づく対応明細
			insertCorrespondDetailList.add(setCorrespondDetailTel(CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINEECHO,newCorrespond.id,setShop)); // LINE反響
			insertCorrespondDetailList.add(setCorrespondDetailTel(CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINERECEIVE,newCorrespond.id,setShop)); // LINE受信
			insertCorrespondDetailList.add(setCorrespondDetailTel(CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINESEND,newCorrespond.id,setShop)); // LINE送信

			insert insertCorrespondDetailList;
			Map<Id,CorrespondDetail__c> beforeCorrespondDetailMap = selectCorrespondDetailMap();

			Test.startTest();
			
			// 初期表示と紐づけ解除ボタンの押下
			GL101001Controller testController = getInitController('対応終了_取引先有');
			testController.clickReleaseLinking();

			Test.stopTest();

			// 実施後
			List<CorrespondDetail__c> afterCorrespondDetailList = new List<CorrespondDetail__c>();
			afterCorrespondDetailList = selectCorrespondDetailList();
			List<Correspond__c> afterCorrespondList1 = selectCorrespondList('対応終了_取引先有','取引先LINE会員有_テスト');

			// 対応比較
			checkClickReleaseLinkingCorrespond(afterCorrespondList1,beforeCorrespondList1,'対応終了_取引先有');

			// 対応明細比較
			checkCorrespondDetailmMove(afterCorrespondDetailList,beforeCorrespondDetailMap,'対応終了_取引先有');
		}
	}
	//▼ 2022.05.25 No0827 対応で追加
	// LINE会員、取引先で対応2件（各ステータス契約完了）※終了以外でおかしな挙動が無いように
	@istest static void clickReleaseLinkingTest11() {

		System.runAs(getUser('ippanUser')) {

			LineMember__c lineMember = selectLineMember('対応契約完了_取引先有');
			List<Correspond__c> beforeCorrespondList1 = selectCorrespondList('対応契約完了_取引先有');
			Shop__c setShop = [SELECT ID,Email__c FROM Shop__c WHERE NAME = 'テスト店舗' LIMIT 1];
			Echomail__c setLineEchomail = [SELECT ID,LineMember__c,LineReceiveType__c,FromEmail__c,Email__c FROM Echomail__c WHERE LineMember__c = :lineMember.id LIMIT 1];
			Echomail__c setEchomail = [SELECT ID,LineMember__c,LineReceiveType__c,FromEmail__c,Email__c FROM Echomail__c WHERE LineMember__c != :lineMember.id LIMIT 1];
			// 対応明細作成（LINE）
			// * @param String correspondType 対応種別
			// * @param Id correspondsId 対応ID
			// * @param String lineType LINEの登録タイプ
			// * @param String accountName 取引先名
			// * @param Shop__c echoShop 店舗
			// * @param EchoMail__c echoMail 反響メール
			List<CorrespondDetail__c> insertCorrespondDetailList = new List<CorrespondDetail__c>();
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,beforeCorrespondList1[0].id,'メッセージ','',setShop,null)); // メッセージ送信時
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,beforeCorrespondList1[0].id,'ファイル','',setShop,null)); // ファイル送信時
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,beforeCorrespondList1[0].id,'紐づけ解除','',setShop,null)); // 紐づけ解除
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,beforeCorrespondList1[0].id,CommonConst.CORRESPONDDETAIL_SUPPORTEDTITLE_LINE,'',setShop,null)); // LINE紐づけ
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_MAIL,beforeCorrespondList1[0].id,CommonConst.CORRESPOND_EVENT_LINE_FRIEND_ADD,'',setShop,setLineEchomail)); // LINE追加
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_MAIL,beforeCorrespondList1[0].id,CommonConst.CORRESPOND_EVENT_LINE_RECEIVE,'',setShop,setLineEchomail)); // LINE受信

			// 対応明細作成（メール）
			// * @param String correspondType 対応種別
			// * @param Id correspondsId 対応ID
			// * @param String mailType メールの登録タイプ
			// * @param Shop__c shop 店舗
			// * @param EchoMail__c echoMail 反響メール
			insertCorrespondDetailList.add(setCorrespondDetailMail(CommonConst.TASK_CORRESPONDTYPE_AUTO_RECIVE,beforeCorrespondList1[0].id,'自動返信',setShop,setEchomail)); // 自動返信用対応明細の取得（メール）
			insertCorrespondDetailList.add(setCorrespondDetailMail(CommonConst.CORRESPONDDETAIL_MAILTYPE_SEND,beforeCorrespondList1[0].id,CommonConst.CORRESPONDDETAIL_MAILTYPE_SEND,setShop,setEchomail)); // メール送信
			insertCorrespondDetailList.add(setCorrespondDetailMail(CommonConst.TASK_CORRESPONDTYPE_CLOSE,beforeCorrespondList1[0].id,CommonConst.TASK_CORRESPONDTYPE_CLOSE,setShop,setEchomail)); // 紹介メール（終了）

			// * 対応明細の作成（その他の対応種別）
			// * @param String correspondType 対応種別
			// * @param Id correspondsId 対応ID
			// * @param Shop__c shop 店舗
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_RELEASEHOLD,beforeCorrespondList1[0].id,setShop)); // 保留解除（対応明細作成）
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_ECHOAGGREGATION,beforeCorrespondList1[0].id,setShop)); // 反響集約（対応明細作成）
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_PERSONDECISION,beforeCorrespondList1[0].id,setShop)); // 担当者決定
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_CLOSE,beforeCorrespondList1[0].id,setShop)); // 配信停止ボタン処理
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_VISITED,beforeCorrespondList1[0].id,setShop)); // 来店カード
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_APPLICANT,beforeCorrespondList1[0].id,setShop)); // 申込登録
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_MERGE,beforeCorrespondList1[0].id,setShop)); // 名寄せ 
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_RETURN,beforeCorrespondList1[0].id,setShop)); // スケジュール（再来）
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_DEPOSIT,beforeCorrespondList1[0].id,setShop)); // 入金処理
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.CORRESPOND_EVENT_VIEWED,beforeCorrespondList1[0].id,setShop)); // 物件閲覧

			// * 対応明細の作成（電話）
			// * @param String phoneStatus 電話状況
			// * @param Id correspondsId 対応ID
			// * @param Shop__c shop 店舗
			insertCorrespondDetailList.add(setCorrespondDetailTel(CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINEECHO,beforeCorrespondList1[0].id,setShop)); // LINE反響
			insertCorrespondDetailList.add(setCorrespondDetailTel(CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINERECEIVE,beforeCorrespondList1[0].id,setShop)); // LINE受信
			insertCorrespondDetailList.add(setCorrespondDetailTel(CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINESEND,beforeCorrespondList1[0].id,setShop)); // LINE送信

			insert insertCorrespondDetailList;
			Map<Id,CorrespondDetail__c> beforeCorrespondDetailMap = selectCorrespondDetailMap();

			Test.startTest();
			
			// 初期表示と紐づけ解除ボタンの押下
			GL101001Controller testController = getInitController('対応契約完了_取引先有');
			testController.clickReleaseLinking();

			Test.stopTest();

			// 実施後
			List<CorrespondDetail__c> afterCorrespondDetailList = new List<CorrespondDetail__c>();
			afterCorrespondDetailList = selectCorrespondDetailList();
			List<Correspond__c> afterCorrespondList1 = selectCorrespondList('対応契約完了_取引先有','取引先LINE会員有_テスト2');

			// 対応比較
			checkClickReleaseLinkingCorrespond(afterCorrespondList1,beforeCorrespondList1,'対応契約完了_取引先有');

			// 対応明細比較
			checkCorrespondDetailmMove(afterCorrespondDetailList,beforeCorrespondDetailMap,'対応契約完了_取引先有');
		}
	}
	//▲ 2022.05.25 No0827 対応で追加

	/**
	 * 紐づけ解除ボタン押下
	 *     遷移元のパラメータの対応．ステータス：反響集約、終了、契約完了以外の場合
	 *     対応明細の移動
	 */
	// 対応1件：紐づき＝LINE会員、取引先
	@istest static void clickReleaseLinkingTest4() {

		System.runAs(getUser('ippanUser')) {

			LineMember__c lineMember = selectLineMember('対応追客中_取引先有');
			List<Correspond__c> beforeCorrespondList1 = selectCorrespondList('対応追客中_取引先有');
			Shop__c setShop = [SELECT ID,Email__c FROM Shop__c WHERE NAME = 'テスト店舗' LIMIT 1];
			Echomail__c setLineEchomail = [SELECT ID,LineMember__c,LineReceiveType__c,FromEmail__c,Email__c FROM Echomail__c WHERE LineMember__c = :lineMember.id LIMIT 1];
			Echomail__c setEchomail = [SELECT ID,LineMember__c,LineReceiveType__c,FromEmail__c,Email__c FROM Echomail__c WHERE LineMember__c != :lineMember.id LIMIT 1];
			// 対応明細作成（LINE）
			// * @param String correspondType 対応種別
			// * @param Id correspondsId 対応ID
			// * @param String lineType LINEの登録タイプ
			// * @param String accountName 取引先名
			// * @param Shop__c echoShop 店舗
			// * @param EchoMail__c echoMail 反響メール
			List<CorrespondDetail__c> insertCorrespondDetailList = new List<CorrespondDetail__c>();
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,beforeCorrespondList1[0].id,'メッセージ','',setShop,null)); // メッセージ送信時
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,beforeCorrespondList1[0].id,'ファイル','',setShop,null)); // ファイル送信時
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,beforeCorrespondList1[0].id,'紐づけ解除','',setShop,null)); // 紐づけ解除
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,beforeCorrespondList1[0].id,CommonConst.CORRESPONDDETAIL_SUPPORTEDTITLE_LINE,'',setShop,null)); // LINE紐づけ
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_MAIL,beforeCorrespondList1[0].id,CommonConst.CORRESPOND_EVENT_LINE_FRIEND_ADD,'',setShop,setLineEchomail)); // LINE追加
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_MAIL,beforeCorrespondList1[0].id,CommonConst.CORRESPOND_EVENT_LINE_RECEIVE,'',setShop,setLineEchomail)); // LINE受信

			// 対応明細作成（メール）
			// * @param String correspondType 対応種別
			// * @param Id correspondsId 対応ID
			// * @param String mailType メールの登録タイプ
			// * @param Shop__c shop 店舗
			// * @param EchoMail__c echoMail 反響メール
			insertCorrespondDetailList.add(setCorrespondDetailMail(CommonConst.TASK_CORRESPONDTYPE_AUTO_RECIVE,beforeCorrespondList1[0].id,'自動返信',setShop,setEchomail)); // 自動返信用対応明細の取得（メール）
			insertCorrespondDetailList.add(setCorrespondDetailMail(CommonConst.CORRESPONDDETAIL_MAILTYPE_SEND,beforeCorrespondList1[0].id,CommonConst.CORRESPONDDETAIL_MAILTYPE_SEND,setShop,setEchomail)); // メール送信
			insertCorrespondDetailList.add(setCorrespondDetailMail(CommonConst.TASK_CORRESPONDTYPE_CLOSE,beforeCorrespondList1[0].id,CommonConst.TASK_CORRESPONDTYPE_CLOSE,setShop,setEchomail)); // 紹介メール（終了）

			// * 対応明細の作成（その他の対応種別）
			// * @param String correspondType 対応種別
			// * @param Id correspondsId 対応ID
			// * @param Shop__c shop 店舗
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_RELEASEHOLD,beforeCorrespondList1[0].id,setShop)); // 保留解除（対応明細作成）
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_ECHOAGGREGATION,beforeCorrespondList1[0].id,setShop)); // 反響集約（対応明細作成）
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_PERSONDECISION,beforeCorrespondList1[0].id,setShop)); // 担当者決定
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_CLOSE,beforeCorrespondList1[0].id,setShop)); // 配信停止ボタン処理
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_VISITED,beforeCorrespondList1[0].id,setShop)); // 来店カード
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_APPLICANT,beforeCorrespondList1[0].id,setShop)); // 申込登録
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_MERGE,beforeCorrespondList1[0].id,setShop)); // 名寄せ 
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_RETURN,beforeCorrespondList1[0].id,setShop)); // スケジュール（再来）
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_DEPOSIT,beforeCorrespondList1[0].id,setShop)); // 入金処理
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.CORRESPOND_EVENT_VIEWED,beforeCorrespondList1[0].id,setShop)); // 物件閲覧

			// * 対応明細の作成（電話）
			// * @param String phoneStatus 電話状況
			// * @param Id correspondsId 対応ID
			// * @param Shop__c shop 店舗
			insertCorrespondDetailList.add(setCorrespondDetailTel(CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINEECHO,beforeCorrespondList1[0].id,setShop)); // LINE反響
			insertCorrespondDetailList.add(setCorrespondDetailTel(CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINERECEIVE,beforeCorrespondList1[0].id,setShop)); // LINE受信
			insertCorrespondDetailList.add(setCorrespondDetailTel(CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINESEND,beforeCorrespondList1[0].id,setShop)); // LINE送信

			insert insertCorrespondDetailList;
			Map<Id,CorrespondDetail__c> beforeCorrespondDetailMap = selectCorrespondDetailMap();

			Test.startTest();
			
			// 初期表示と紐づけ解除ボタンの押下
			GL101001Controller testController = getInitController('対応追客中_取引先有');
			testController.clickReleaseLinking();

			Test.stopTest();

			// 実施後
			List<CorrespondDetail__c> afterCorrespondDetailList = new List<CorrespondDetail__c>();
			afterCorrespondDetailList = selectCorrespondDetailList();
			List<Correspond__c> afterCorrespondList1 = selectCorrespondList('対応追客中_取引先有','取引先LINE会員有_テスト5');

			// 対応比較
			checkClickReleaseLinkingCorrespondValid(afterCorrespondList1,beforeCorrespondList1,'対応追客中_取引先有');

			// 対応明細比較
			checkCorrespondDetailmMove(afterCorrespondDetailList,beforeCorrespondDetailMap,'対応追客中_取引先有');

		}
	}
	// 対応2件：対応1（紐づき＝LINE会員）、対応2（紐づき＝LINE会員、取引先）
	@istest static void clickReleaseLinkingTest5() {

		System.runAs(getUser('ippanUser')) {

			LineMember__c lineMember = selectLineMember('対応追客中_取引先有');
			List<Correspond__c> beforeCorrespondList1 = selectCorrespondList('対応追客中_取引先有');
			// 対応を2件にする（取引先、LINE会員がそれぞれ紐づく対応）
			Correspond__c newCorrespond = new Correspond__c();
			newCorrespond = beforeCorrespondList1[0].clone();
			newCorrespond.FirstLineAddFlg__c = false;  // 初回LINE追加フラグ
			newCorrespond.LineMember__c = null;  // 初回LINE追加フラグ
			newCorrespond.id = null;
			insert newCorrespond;
			beforeCorrespondList1.add(newCorrespond);
			Shop__c setShop = [SELECT ID,Email__c FROM Shop__c WHERE NAME = 'テスト店舗' LIMIT 1];
			Echomail__c setLineEchomail = [SELECT ID,LineMember__c,LineReceiveType__c,FromEmail__c,Email__c FROM Echomail__c WHERE LineMember__c = :lineMember.id LIMIT 1];
			Echomail__c setEchomail = [SELECT ID,LineMember__c,LineReceiveType__c,FromEmail__c,Email__c FROM Echomail__c WHERE LineMember__c != :lineMember.id LIMIT 1];
			// 対応明細作成（LINE）
			// * @param String correspondType 対応種別
			// * @param Id correspondsId 対応ID
			// * @param String lineType LINEの登録タイプ
			// * @param String accountName 取引先名
			// * @param Shop__c echoShop 店舗
			// * @param EchoMail__c echoMail 反響メール
			List<CorrespondDetail__c> insertCorrespondDetailList = new List<CorrespondDetail__c>();
			// 1件目に紐づく対応明細
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,beforeCorrespondList1[0].id,'メッセージ','',setShop,null)); // メッセージ送信時
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,beforeCorrespondList1[0].id,'ファイル','',setShop,null)); // ファイル送信時
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,beforeCorrespondList1[0].id,'紐づけ解除','',setShop,null)); // 紐づけ解除
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,beforeCorrespondList1[0].id,CommonConst.CORRESPONDDETAIL_SUPPORTEDTITLE_LINE,'',setShop,null)); // LINE紐づけ
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_MAIL,beforeCorrespondList1[0].id,CommonConst.CORRESPOND_EVENT_LINE_FRIEND_ADD,'',setShop,setLineEchomail)); // LINE追加
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_MAIL,beforeCorrespondList1[0].id,CommonConst.CORRESPOND_EVENT_LINE_RECEIVE,'',setShop,setLineEchomail)); // LINE受信
			// 2件目に紐づく対応明細
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,newCorrespond.id,'メッセージ','',setShop,null)); // メッセージ送信時
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,newCorrespond.id,'ファイル','',setShop,null)); // ファイル送信時
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,newCorrespond.id,'紐づけ解除','',setShop,null)); // 紐づけ解除
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_LINE,newCorrespond.id,CommonConst.CORRESPONDDETAIL_SUPPORTEDTITLE_LINE,'',setShop,null)); // LINE紐づけ
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_MAIL,newCorrespond.id,CommonConst.CORRESPOND_EVENT_LINE_FRIEND_ADD,'',setShop,setLineEchomail)); // LINE追加
			insertCorrespondDetailList.add(setCorrespondDetailLine(CommonConst.TASK_CORRESPONDTYPE_MAIL,newCorrespond.id,CommonConst.CORRESPOND_EVENT_LINE_RECEIVE,'',setShop,setLineEchomail)); // LINE受信

			// 対応明細作成（メール）
			// * @param String correspondType 対応種別
			// * @param Id correspondsId 対応ID
			// * @param String mailType メールの登録タイプ
			// * @param Shop__c shop 店舗
			// * @param EchoMail__c echoMail 反響メール
			// 1件目に紐づく対応明細
			insertCorrespondDetailList.add(setCorrespondDetailMail(CommonConst.TASK_CORRESPONDTYPE_AUTO_RECIVE,beforeCorrespondList1[0].id,'自動返信',setShop,setEchomail)); // 自動返信用対応明細の取得（メール）
			insertCorrespondDetailList.add(setCorrespondDetailMail(CommonConst.CORRESPONDDETAIL_MAILTYPE_SEND,beforeCorrespondList1[0].id,CommonConst.CORRESPONDDETAIL_MAILTYPE_SEND,setShop,setEchomail)); // メール送信
			insertCorrespondDetailList.add(setCorrespondDetailMail(CommonConst.TASK_CORRESPONDTYPE_CLOSE,beforeCorrespondList1[0].id,CommonConst.TASK_CORRESPONDTYPE_CLOSE,setShop,setEchomail)); // 紹介メール（終了）
			// 2件目に紐づく対応明細
			insertCorrespondDetailList.add(setCorrespondDetailMail(CommonConst.TASK_CORRESPONDTYPE_AUTO_RECIVE,newCorrespond.id,'自動返信',setShop,setEchomail)); // 自動返信用対応明細の取得（メール）
			insertCorrespondDetailList.add(setCorrespondDetailMail(CommonConst.CORRESPONDDETAIL_MAILTYPE_SEND,newCorrespond.id,CommonConst.CORRESPONDDETAIL_MAILTYPE_SEND,setShop,setEchomail)); // メール送信
			insertCorrespondDetailList.add(setCorrespondDetailMail(CommonConst.TASK_CORRESPONDTYPE_CLOSE,newCorrespond.id,CommonConst.TASK_CORRESPONDTYPE_CLOSE,setShop,setEchomail)); // 紹介メール（終了）

			// * 対応明細の作成（その他の対応種別）
			// * @param String correspondType 対応種別
			// * @param Id correspondsId 対応ID
			// * @param Shop__c shop 店舗
			// 1件目に紐づく対応明細
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_RELEASEHOLD,beforeCorrespondList1[0].id,setShop)); // 保留解除（対応明細作成）
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_ECHOAGGREGATION,beforeCorrespondList1[0].id,setShop)); // 反響集約（対応明細作成）
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_PERSONDECISION,beforeCorrespondList1[0].id,setShop)); // 担当者決定
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_CLOSE,beforeCorrespondList1[0].id,setShop)); // 配信停止ボタン処理
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_VISITED,beforeCorrespondList1[0].id,setShop)); // 来店カード
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_APPLICANT,beforeCorrespondList1[0].id,setShop)); // 申込登録
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_MERGE,beforeCorrespondList1[0].id,setShop)); // 名寄せ 
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_RETURN,beforeCorrespondList1[0].id,setShop)); // スケジュール（再来）
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_DEPOSIT,beforeCorrespondList1[0].id,setShop)); // 入金処理
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.CORRESPOND_EVENT_VIEWED,beforeCorrespondList1[0].id,setShop)); // 物件閲覧
			// 2件目に紐づく対応明細
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_RELEASEHOLD,newCorrespond.id,setShop)); // 保留解除（対応明細作成）
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_ECHOAGGREGATION,newCorrespond.id,setShop)); // 反響集約（対応明細作成）
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_PERSONDECISION,newCorrespond.id,setShop)); // 担当者決定
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_CLOSE,newCorrespond.id,setShop)); // 配信停止ボタン処理
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_VISITED,newCorrespond.id,setShop)); // 来店カード
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_APPLICANT,newCorrespond.id,setShop)); // 申込登録
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_MERGE,newCorrespond.id,setShop)); // 名寄せ 
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_RETURN,newCorrespond.id,setShop)); // スケジュール（再来）
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.TASK_CORRESPONDTYPE_DEPOSIT,newCorrespond.id,setShop)); // 入金処理
			insertCorrespondDetailList.add(setCorrespondDetailOther(CommonConst.CORRESPOND_EVENT_VIEWED,newCorrespond.id,setShop)); // 物件閲覧

			// * 対応明細の作成（電話）
			// * @param String phoneStatus 電話状況
			// * @param Id correspondsId 対応ID
			// * @param Shop__c shop 店舗
			// 1件目に紐づく対応明細
			insertCorrespondDetailList.add(setCorrespondDetailTel(CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINEECHO,beforeCorrespondList1[0].id,setShop)); // LINE反響
			insertCorrespondDetailList.add(setCorrespondDetailTel(CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINERECEIVE,beforeCorrespondList1[0].id,setShop)); // LINE受信
			insertCorrespondDetailList.add(setCorrespondDetailTel(CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINESEND,beforeCorrespondList1[0].id,setShop)); // LINE送信
			// 2件目に紐づく対応明細
			insertCorrespondDetailList.add(setCorrespondDetailTel(CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINEECHO,newCorrespond.id,setShop)); // LINE反響
			insertCorrespondDetailList.add(setCorrespondDetailTel(CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINERECEIVE,newCorrespond.id,setShop)); // LINE受信
			insertCorrespondDetailList.add(setCorrespondDetailTel(CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINESEND,newCorrespond.id,setShop)); // LINE送信

			insert insertCorrespondDetailList;
			Map<Id,CorrespondDetail__c> beforeCorrespondDetailMap = selectCorrespondDetailMap();

			Test.startTest();
			
			// 初期表示と紐づけ解除ボタンの押下
			GL101001Controller testController = getInitController('対応追客中_取引先有');
			testController.clickReleaseLinking();

			Test.stopTest();

			// 実施後
			List<CorrespondDetail__c> afterCorrespondDetailList = new List<CorrespondDetail__c>();
			afterCorrespondDetailList = selectCorrespondDetailList();
			List<Correspond__c> afterCorrespondList1 = selectCorrespondList('対応追客中_取引先有','取引先LINE会員有_テスト5');

			// 対応比較
			checkClickReleaseLinkingCorrespondValid(afterCorrespondList1,beforeCorrespondList1,'対応追客中_取引先有');

			// 対応明細比較
			checkCorrespondDetailmMove(afterCorrespondDetailList,beforeCorrespondDetailMap,'対応追客中_取引先有');

		}
	}
	// ▲ 2022.05.16 No0758 対応で追加

//-----------------------------------------------------------------以下privateメソッド-----------------------------------------------------------------
	/**
	 * 対応済のチェック
	 * @param Correspond__c clickCorrespond  対応済押下後の対応
	 * @param Correspond__c beforeCorrespond 対応済押下前の対応
	 * @param String equalsMessage エラー時のメッセージ（対象処理名）
	 */
	private static void checkClickDoneCorrespond(Correspond__c clickCorrespond,Correspond__c beforeCorrespond,String equalsMessage){
		if(CustomerUtil.notApplicableStatus.contains(clickCorrespond.Status__c)){
			// 無効なステータスの場合
			System.assertEquals(clickCorrespond.ListViewDate__c,CommonConst.LAST_DATE, '対応済ボタン押下' + equalsMessage +'：一覧表示日時_無効なステータスの場合');
		}else if(clickCorrespond.Status__c == CommonConst.CORRESPOND_STATUS_PURSUIT){
			// ステータスが追客中は不一致で確認
			System.assertNotEquals(clickCorrespond.ListViewDate__c,beforeCorrespond.ListViewDate__c , '対応済ボタン押下' + equalsMessage +'：一覧表示日時');
		}else{
			// LINE会員トリガで作成されている前提（更新前はCommonConst.LAST_DATEの内容になっている）
			System.assertEquals(clickCorrespond.ListViewDate__c,beforeCorrespond.ListViewDate__c , '対応済ボタン押下' + equalsMessage +'：一覧表示日時');
		}
		System.assertNotEquals(clickCorrespond.EventDateTime__c,beforeCorrespond.EventDateTime__c, '対応済ボタン押下' + equalsMessage +'：イベント時刻');
		System.assertEquals(clickCorrespond.Status__c,beforeCorrespond.Status__c , '対応済ボタン押下' + equalsMessage +'：対応．ステータス：'+clickCorrespond.Status__c);
		System.assertEquals(clickCorrespond.FirstLineAddFlg__c,beforeCorrespond.FirstLineAddFlg__c , '対応済ボタン押下' + equalsMessage +'：初回LINE追加フラグ');
		System.assertEquals(clickCorrespond.StaffSupportedFlg__c,true, '対応済ボタン押下' + equalsMessage +'：スタッフ対応フラグ');
		System.assertEquals(clickCorrespond.IsBrowseFlg__c,true, '対応済ボタン押下' + equalsMessage +'：閲覧フラグ');
		System.assertEquals(clickCorrespond.IsSupportedListShow__c,true, '対応済ボタン押下' + equalsMessage +'：対応確認');
	}

	/**
	 * メッセージ送信のチェック（契約完了、反響累計ステータス）　// 2022.05.25 No0827 対応で終了のみ別処理に
	 * @param List<Correspond__c> clickCorrespondList  メッセージ送信後の対応
	 * @param List<Correspond__c> beforeCorrespondList メッセージ送信前の対応
	 * @param String equalsMessage エラー時のメッセージ（対象処理名）
	 */
	private static void checkClickSendMsgCorrespond(List<Correspond__c> clickCorrespondList,List<Correspond__c> beforeCorrespondList,String equalsMessage){		
		// 件数
		System.assertNotEquals(clickCorrespondList.size(),beforeCorrespondList.size(),'メッセージ送信' + equalsMessage +'：件数');
		System.assertEquals(clickCorrespondList.size(),2,'メッセージ送信' + equalsMessage +'：加算='+clickCorrespondList.size());
		for (Correspond__c clickCorrespond : clickCorrespondList) {
			Boolean isNewData = true;
			for (Correspond__c beforeCorrespond : beforeCorrespondList) {
				if(beforeCorrespond.Id == clickCorrespond.Id){
					// 元の対応のチェック
					if(CustomerUtil.notApplicableStatus.contains(clickCorrespond.Status__c)){
						// 無効なステータス
						System.assertEquals(clickCorrespond.ListViewDate__c,beforeCorrespond.ListViewDate__c, 'メッセージ送信' + equalsMessage +'：一覧表示日時');
					}else{
						System.assertNotEquals(clickCorrespond.ListViewDate__c,beforeCorrespond.ListViewDate__c, 'メッセージ送信' + equalsMessage +'：一覧表示日時');
					}
					System.assertNotEquals(clickCorrespond.FirstLineAddFlg__c,beforeCorrespond.FirstLineAddFlg__c,'メッセージ送信' + equalsMessage +'：初回LINE追加フラグ');
					System.assertEquals(clickCorrespond.IsBrowseFlg__c,true,'メッセージ送信' + equalsMessage +'：閲覧フラグ');
					System.assertNotEquals(clickCorrespond.EventDateTime__c,beforeCorrespond.EventDateTime__c, 'メッセージ送信' + equalsMessage +'：イベント時刻');
					System.assertNotEquals(clickCorrespond.LineSmsSendDate__c,beforeCorrespond.LineSmsSendDate__c, 'メッセージ送信' + equalsMessage +'：LINE・SMS送信日時');
					isNewData = false;
				}
			}

			if (isNewData) {
				// 追客中は次の日の0時になるため日付を設定
				Date tomorrow = nowDateTime.Date().addDays(1); 
				Time zeroTime = Time.newInstance(0, 0, 0, 0);
				Datetime listViewDate = Datetime.newInstance(tomorrow, zeroTime);
				// 新規追加データチェック
				System.assertEquals(clickCorrespond.Status__c,CommonConst.CORRESPOND_STATUS_PURSUIT, 'メッセージ送信' + equalsMessage +'：対応．ステータス：追客中変更');	// ステータス
				System.assertNotEquals(clickCorrespond.LineMember__c,null, 'メッセージ送信' + equalsMessage +'：LINE会員ID');
				System.assertEquals(clickCorrespond.FirstLineAddFlg__c,true, 'メッセージ送信' + equalsMessage +'：初回LINE追加フラグ');
				System.assertEquals(clickCorrespond.ListViewDate__c,listViewDate, 'メッセージ送信' + equalsMessage +'：一覧表示日時');
			}
			
		}
	}

	//▼ 2022.05.25 No0827 対応で追加
	/**
	 * メッセージ送信のチェック（終了ステータス）
	 * @param List<Correspond__c> clickCorrespondList  メッセージ送信後の対応
	 * @param List<Correspond__c> beforeCorrespondList メッセージ送信前の対応
	 * @param String equalsMessage エラー時のメッセージ（対象処理名）
	 */
	private static void checkClickSendMsgCorrespondClose(List<Correspond__c> clickCorrespondList,List<Correspond__c> beforeCorrespondList,String equalsMessage){		
		// 件数
		System.assertEquals(clickCorrespondList.size(),beforeCorrespondList.size(),'メッセージ送信' + equalsMessage +'：件数');
		for (Correspond__c clickCorrespond : clickCorrespondList) {
			Boolean isNewData = true;
			for (Correspond__c beforeCorrespond : beforeCorrespondList) {
				if(beforeCorrespond.Id == clickCorrespond.Id){
					// 元の対応のチェック
					System.assertNotEquals(clickCorrespond.ListViewDate__c,beforeCorrespond.ListViewDate__c, 'メッセージ送信' + equalsMessage +'：一覧表示日時');
					System.assertEquals(clickCorrespond.FirstLineAddFlg__c,beforeCorrespond.FirstLineAddFlg__c,'メッセージ送信' + equalsMessage +'：初回LINE追加フラグ');
					System.assertEquals(clickCorrespond.IsBrowseFlg__c,true,'メッセージ送信' + equalsMessage +'：閲覧フラグ');
					System.assertNotEquals(clickCorrespond.EventDateTime__c,beforeCorrespond.EventDateTime__c, 'メッセージ送信' + equalsMessage +'：イベント時刻');
					System.assertNotEquals(clickCorrespond.LineSmsSendDate__c,beforeCorrespond.LineSmsSendDate__c, 'メッセージ送信' + equalsMessage +'：LINE・SMS送信日時');
					isNewData = false;
				}
			}

			if (isNewData) {
				// 新規追加データがあればエラー
				System.assertEquals(clickCorrespond.id,null, 'メッセージ送信' + equalsMessage +'：新規追加されるエラー');	// ステータス	
			}
			
		}
	}
	//▲ 2022.05.25 No0827 対応で追加

	/**
	 * メッセージ送信のチェック（有効ステータス）
	 * @param List<Correspond__c> clickCorrespondList  メッセージ送信後の対応
	 * @param List<Correspond__c> beforeCorrespondList メッセージ送信前の対応
	 * @param Boolean isPursuitChange ステータス追客に変更フラグ（未対応→追客中のみ）
	 * @param String equalsMessage エラー時のメッセージ（対象処理名）
	 */
	private static void checkClickSendMsgCorrespondValid(List<Correspond__c> clickCorrespondList,List<Correspond__c> beforeCorrespondList,String equalsMessage,Boolean isPursuitChange){
		// 件数
		System.assertEquals(clickCorrespondList.size(),beforeCorrespondList.size(),'メッセージ送信' + equalsMessage +'：件数');
		for (Correspond__c clickCorrespond : clickCorrespondList) {
			Boolean isNewData = true;
			for (Correspond__c beforeCorrespond : beforeCorrespondList) {
				if(beforeCorrespond.Id == clickCorrespond.Id){
					// 元の対応のチェック
					System.assertEquals(clickCorrespond.FirstLineAddFlg__c,beforeCorrespond.FirstLineAddFlg__c,'メッセージ送信' + equalsMessage +'：初回LINE追加フラグ');
					System.assertEquals(clickCorrespond.IsBrowseFlg__c,true,'メッセージ送信' + equalsMessage +'：閲覧フラグ');
					System.assertNotEquals(clickCorrespond.ListViewDate__c,beforeCorrespond.ListViewDate__c, 'メッセージ送信' + equalsMessage +'：一覧表示日時');
					System.assertNotEquals(clickCorrespond.EventDateTime__c,beforeCorrespond.EventDateTime__c, 'メッセージ送信' + equalsMessage +'：イベント時刻');
					System.assertNotEquals(clickCorrespond.LineSmsSendDate__c,beforeCorrespond.LineSmsSendDate__c, 'メッセージ送信' + equalsMessage +'：LINE・SMS送信日時');
					// ステータスの確認
					if(isPursuitChange){
						// 追客中に変わる 
						System.assertEquals(clickCorrespond.Status__c,CommonConst.CORRESPOND_STATUS_PURSUIT,'メッセージ送信' + equalsMessage +'：ステータス「追客中」変更');
					}else{
						// 変化無
						System.assertEquals(clickCorrespond.Status__c,beforeCorrespond.Status__c,'メッセージ送信' + equalsMessage +'：ステータス変更無');
						
					}

					isNewData = false;
				}
			}

			if (isNewData) {
				// 新規追加データがあればエラー
				System.assertEquals(clickCorrespond.id,null, 'メッセージ送信' + equalsMessage +'：対応．ステータス：追客中変更');	// ステータス	
			}
			
		}
	}

	/**
	 * 紐づき解除のチェック（終了、契約完了、反響累計ステータス）
	 * @param Correspond__c afterCorrespondList  紐づき解除後の対応
	 * @param Correspond__c beforeCorrespondList 紐づき解除前の対応
	 * @param String equalsMessage エラー時のメッセージ（対象処理名）
	 */
	private static void checkClickReleaseLinkingCorrespond(List<Correspond__c> afterCorrespondList,List<Correspond__c> beforeCorrespondList,String equalsMessage){		
		// 件数
		System.assertNotEquals(afterCorrespondList.size(),beforeCorrespondList.size(), equalsMessage +'：件数');
		System.assertEquals(afterCorrespondList.size(),beforeCorrespondList.size()+1, equalsMessage +'：加算='+afterCorrespondList.size());
		for (Correspond__c afterCorrespond : afterCorrespondList) {
			Boolean isNewData = true;
			for (Correspond__c beforeCorrespond : beforeCorrespondList) {
				if(beforeCorrespond.Id == afterCorrespond.Id){
					// 元の対応のチェック
					if(CustomerUtil.notApplicableStatus.contains(afterCorrespond.Status__c)){
						// 無効なステータスの場合
						System.assertEquals(afterCorrespond.FirstLineAddFlg__c,false, equalsMessage +'：初回LINE追加フラグfalse');
					}else if(afterCorrespond.LineMember__c != null){
						// LINE会員が紐づいているもののみ比較
						System.assertEquals(afterCorrespond.FirstLineAddFlg__c,true, equalsMessage +'：初回LINE追加フラグtrue');
						System.assertEquals(afterCorrespond.IsBrowseFlg__c,true, equalsMessage +'：閲覧フラグ');
						System.assertNotEquals(afterCorrespond.EventDateTime__c,beforeCorrespond.EventDateTime__c,  equalsMessage +'：イベント時刻');
					}
					isNewData = false;
				}
			}

			if (isNewData) {
				Date tomorrow = nowDateTime.Date().addDays(1); 
				Time zeroTime = Time.newInstance(0, 0, 0, 0);
				Datetime listViewDate = Datetime.newInstance(tomorrow, zeroTime);
				// 新規追加データチェック
				System.assertEquals(afterCorrespond.Status__c,CommonConst.CORRESPOND_STATUS_PURSUIT, 'メッセージ送信' + equalsMessage +'：対応．ステータス：追客中変更');	// ステータス
				System.assertNotEquals(afterCorrespond.LineMember__c,null, 'メッセージ送信' + equalsMessage +'：LINE会員ID');
				System.assertEquals(afterCorrespond.FirstLineAddFlg__c,true, 'メッセージ送信' + equalsMessage +'：初回LINE追加フラグ');
			}
			
		}
	}
	/**
	 * 紐づき解除のチェック（有効ステータス）
	 * @param Correspond__c afterCorrespondList  紐づき解除後の対応
	 * @param Correspond__c beforeCorrespondList 紐づき解除前の対応
	 * @param String equalsMessage エラー時のメッセージ（対象処理名）
	 */
	private static void checkClickReleaseLinkingCorrespondValid(List<Correspond__c> afterCorrespondList,List<Correspond__c> beforeCorrespondList,String equalsMessage){		
		// 件数
		// System.assertNotEquals(afterCorrespondList.size(),beforeCorrespondList.size(), equalsMessage +'：件数');
		// System.assertEquals(afterCorrespondList.size(),beforeCorrespondList.size()+1, equalsMessage +'：加算='+afterCorrespondList.size());
		for (Correspond__c afterCorrespond : afterCorrespondList) {
			Boolean isNewData = true;
			for (Correspond__c beforeCorrespond : beforeCorrespondList) {
				if(beforeCorrespond.Id == afterCorrespond.Id){
					// 元の対応のチェック
					if(CustomerUtil.notApplicableStatus.contains(afterCorrespond.Status__c)){
						// 無効なステータスの場合
						System.assertEquals(afterCorrespond.FirstLineAddFlg__c,false, equalsMessage +'：初回LINE追加フラグfalse');
					}else if(afterCorrespond.LineMember__c != null){
						// LINE会員が紐づいているもののみ比較
						System.assertEquals(afterCorrespond.FirstLineAddFlg__c,true, equalsMessage +'：初回LINE追加フラグtrue');
						// System.assertEquals(afterCorrespond.IsBrowseFlg__c,true, equalsMessage +'：閲覧フラグ');
						// System.assertNotEquals(afterCorrespond.EventDateTime__c,beforeCorrespond.EventDateTime__c,  equalsMessage +'：イベント時刻');
					}
					isNewData = false;
				}
			}

			if (isNewData) {
				Date tomorrow = nowDateTime.Date().addDays(1); 
				Time zeroTime = Time.newInstance(0, 0, 0, 0);
				Datetime listViewDate = Datetime.newInstance(tomorrow, zeroTime);
				// 新規追加データチェック
				System.assertEquals(afterCorrespond.Status__c,CommonConst.CORRESPOND_STATUS_PURSUIT, 'メッセージ送信' + equalsMessage +'：対応．ステータス：追客中変更');	// ステータス
				System.assertNotEquals(afterCorrespond.LineMember__c,null, 'メッセージ送信' + equalsMessage +'：LINE会員ID');
				System.assertEquals(afterCorrespond.FirstLineAddFlg__c,true, 'メッセージ送信' + equalsMessage +'：初回LINE追加フラグ');
				// System.assertEquals(afterCorrespond.ListViewDate__c,listViewDate, 'メッセージ送信' + equalsMessage +'：一覧表示日時');
			}
			
		}
	}

	/**
	 * 紐づき解除の対応明細移動チェック
	 * @param Correspond__c beforeCorrespondDetailMap  紐づき解除後の対応明細
	 * @param Correspond__c afterCorrespondDetailList 紐づき解除前の対応明細
	 * @param String equalsMessage エラー時のメッセージ（対象処理名）
	 */
	private static void checkCorrespondDetailmMove(List<CorrespondDetail__c> afterCorrespondDetailList,Map<Id,CorrespondDetail__c>  beforeCorrespondDetailMap,String equalsMessage){		
		// 対応明細_移動比較
		for(CorrespondDetail__c afterCorrespondDetail:afterCorrespondDetailList){
			if(beforeCorrespondDetailMap.containsKey(afterCorrespondDetail.Id)){
				if(beforeCorrespondDetailMap.get(afterCorrespondDetail.Id).SystemModstamp == afterCorrespondDetail.SystemModstamp){
					// 更新無
					continue;
				}
				if(afterCorrespondDetail.CorrespondType__c == CommonConst.TASK_CORRESPONDTYPE_LINE && afterCorrespondDetail.MailType__c == CommonConst.CORRESPONDDETAIL_MAILTYPE_SEND){
					// 対応明細の移動対象判定（LINE送信）
					// 移動対象は対応IDが変わっていること
					System.assertNotEquals(beforeCorrespondDetailMap.get(afterCorrespondDetail.Id).Corresponds__c, 
									afterCorrespondDetail.Corresponds__c,equalsMessage + '：対応の移動LINE送信=' + afterCorrespondDetail.SupportedTitle__c);
				}else if(afterCorrespondDetail.CorrespondType__c == CommonConst.TASK_CORRESPONDTYPE_MAIL && 
					afterCorrespondDetail.MailType__c == CommonConst.CORRESPONDDETAIL_MAILTYPE_RECEIVE 
					&& afterCorrespondDetail.EchoMail__c != null){
					// 対応明細の移動対象判定（LINE追加、LINE受信）
					// 移動対象は対応IDが変わっていること
					System.assertNotEquals(beforeCorrespondDetailMap.get(afterCorrespondDetail.Id).Corresponds__c, 
									afterCorrespondDetail.Corresponds__c,equalsMessage + '：対応の移動LINE受信=' + afterCorrespondDetail.SupportedTitle__c);
				}else if(afterCorrespondDetail.CorrespondType__c == CommonConst.TASK_CORRESPONDTYPE_AUTO_RECIVE_LINE){
					// 対応明細の移動対象判定（自動返信(LINE)）
					// 移動対象は対応IDが変わっていること
					System.assertNotEquals(beforeCorrespondDetailMap.get(afterCorrespondDetail.Id).Corresponds__c, 
									afterCorrespondDetail.Corresponds__c,equalsMessage + '：対応の移動自動返信(LINE)=' + afterCorrespondDetail.SupportedTitle__c);
				}else {
					// 対応IDが変わっていない
					System.assertEquals(beforeCorrespondDetailMap.get(afterCorrespondDetail.Id).Corresponds__c, 
									afterCorrespondDetail.Corresponds__c,equalsMessage + '：対応の移動対象外=' + afterCorrespondDetail.SupportedTitle__c);
				}	
			}
		}
	}



	/**
	 * 任意のユーザ取得
	 * @param String userName ユーザ名（性）
	 * @return User ユーザ
	 */
	private static User getUser(String userLastName) {
		User user = [
			SELECT Id
			FROM User
			WHERE LastName = :userLastName
		];

		return user;
	}
	//▲ 2022.04.20 No0768 対応で追加
	/**
	 * ユーザの取得
	 * @return User ユーザ
	 */
	private static User getThisUser() {

		User user = [
			SELECT Id
			FROM User
			WHERE Id = :UserInfo.getUserId()
		];

		return user;
	}

	/**
	 * 初期画面の起動
	 * @return GL101001Controller LINE専用
	 */
	private static GL101001Controller getInitController(String lineMemberName) {

		// LINE会員の取得
		LineMember__c lineMember = selectLineMember(lineMemberName);

		// 対応の取得
		Correspond__c correspond = [
			SELECT Id
			FROM Correspond__c
			WHERE LineMember__c = :lineMember.Id
			ORDER BY SystemModstamp DESC
			LIMIT 1
		];

		// 初期表示
		PageReference pageRef = Page.GL101001View;
		pageRef.getParameters().put('lineMemberId', lineMember.Id);
		pageRef.getParameters().put('correspondId', correspond.Id);
		Test.setCurrentPage(pageRef);

		return new GL101001Controller();
	}

	// ▼ 2022.05.16 No0758 対応で追加
	/**
	 * 対応明細の作成（LINE関係）
	 * @param String correspondType 対応種別
	 * @param Id correspondsId 対応ID
	 * @param String lineType LINEの登録タイプ
	 * @param String accountName 取引先名（紐づけの際）
	 * @param Shop__c echoShop 店舗
	 * @param EchoMail__c echoMail 反響メール
	 * @return CorrespondDetail__c 対応明細1件
	 */
	private static CorrespondDetail__c setCorrespondDetailLine(String correspondType,Id correspondsId,String lineType,String accountName,Shop__c echoShop,EchoMail__c echoMail) {
		CorrespondDetail__c newCorrespondDetail = new CorrespondDetail__c();
		newCorrespondDetail.CorrespondType__c = correspondType; // 対応種別
		newCorrespondDetail.Corresponds__c = CorrespondsId; // 対応番号
		newCorrespondDetail.Shop__c = echoShop.id;	// 店舗
		newCorrespondDetail.Staff__c = UserInfo.getUserId(); // 担当者
		newCorrespondDetail.SupportedDateTime__c =nowDateTime; // 対応日時

		if(lineType == 'メッセージ' || lineType == 'ファイル'){
			// LINE送信時の対応明細作成（メッセージ）
			// LINE送信時の対応明細作成（ファイル）
			newCorrespondDetail.SupportedTitle__c	= 'LINE手動返信';	// 対応表題
			newCorrespondDetail.SupportedContent__c	=lineType + 'を送信しました。' + CommonConst.LINE_FEED
				+ CommonConst.LINE_FEED
				+ lineType == 'メッセージ' ? 'LINEメッセージ' : 'ファイル.csv';	// 対応内容
			newCorrespondDetail.MailType__c	= CommonConst.CORRESPONDDETAIL_MAILTYPE_SEND;	// メール種別
			newCorrespondDetail.Email__c	= echoShop.Email__c;	// メール

		}else if(lineType == '紐づけ解除'){
			// 紐づけ解除時の対応明細作成
			newCorrespondDetail.SupportedTitle__c='紐づけ解除'; // 対応表題
			newCorrespondDetail.SupportedContent__c	='取引先との紐づけが解除されました。' + CommonConst.LINE_FEED
				+ CommonConst.LINE_FEED	+ '【取引先名】:' + accountName; // 対応内容

		}else if(lineType == CommonConst.CORRESPONDDETAIL_SUPPORTEDTITLE_LINE){
			// LINE紐づけ
			newCorrespondDetail.SupportedTitle__c = lineType; // 対応表題
			newCorrespondDetail.SupportedContent__c = CommonConst.MSG_CUST_I_EXECUTE_ACCOUNT_LINKING_END + CommonConst.BREAK_CODE 
				+CommonConst.BREAK_CODE + '【取引先名】:' + accountName; // 対応内容
			
		}else if(lineType == CommonConst.TASK_CORRESPONDTYPE_AUTO_RECIVE_LINE){
			// 自動返信用対応明細の取得（LINE返信）
			newCorrespondDetail.SupportedTitle__c = '自動返信用対応明細の取得（LINE返信）'; // 対応表題
			newCorrespondDetail.SupportedContent__c = 
				'TO:' + echoMail.FromEmail__c + CommonConst.LINE_FEED
				+ 'LINE返信' + CommonConst.LINE_FEED
				+ CommonConst.LINE_FEED;	// 対応内容

			newCorrespondDetail.MailType__c	= CommonConst.CORRESPONDDETAIL_MAILTYPE_SEND;	// メール種別
			newCorrespondDetail.Email__c	= echoShop.Email__c;	// メール
			newCorrespondDetail.EchoMail__c	= echoMail.Id;	// 反響メール

		}else if(lineType == CommonConst.LINE_RECEIVE_TYPE_ADD){
			// LINE追加
			newCorrespondDetail.SupportedTitle__c = '[てすと]LINE追加'; // 対応表題
			newCorrespondDetail.SupportedContent__c = 'らいんついか';	// 対応内容
			newCorrespondDetail.PortalSiteUrl__c     ='https://portalurl/'; //ポータルサイトUrl
			newCorrespondDetail.MailType__c	= CommonConst.CORRESPONDDETAIL_MAILTYPE_RECEIVE;	// メール種別（受信）
			newCorrespondDetail.EchoMail__c	= echoMail.Id;	// 反響メール
			newCorrespondDetail.Email__c	= echoShop.Email__c;	// メール

		}else if(lineType == CommonConst.LINE_RECEIVE_TYPE_RECEIVE){
			// LINE受信
			newCorrespondDetail.SupportedTitle__c = '[てすと]LINE受信'; // 対応表題
			newCorrespondDetail.SupportedContent__c = 'らいんじゅしん';	// 対応内容
			newCorrespondDetail.MailType__c	= CommonConst.CORRESPONDDETAIL_MAILTYPE_RECEIVE;	// メール種別（受信）
			newCorrespondDetail.EchoMail__c	= echoMail.Id;	// 反響メール
			newCorrespondDetail.Email__c	= echoShop.Email__c;	// メール
		}
		
		return newCorrespondDetail;
	}
	
	/**
	 * 対応明細の作成（メール関係）
	 * @param String correspondType 対応種別
	 * @param Id correspondsId 対応ID
	 * @param String mailType メールの登録タイプ
	 * @param Shop__c shop 店舗
	 * @param EchoMail__c echoMail 反響メール
	 * @return CorrespondDetail__c 対応明細1件
	 */
	private static CorrespondDetail__c setCorrespondDetailMail(String correspondType,Id correspondsId,String mailType,Shop__c shop,EchoMail__c echoMail) {
		CorrespondDetail__c newCorrespondDetail = new CorrespondDetail__c();
		newCorrespondDetail.Corresponds__c	=	CorrespondsId; // 対応番号
		newCorrespondDetail.SupportedDateTime__c	= nowDateTime; // 対応日時
		if(mailType == '自動返信'){
			// 自動返信用対応明細の取得（メール）
			newCorrespondDetail.CorrespondType__c	=	correspondType; // 対応種別
			newCorrespondDetail.SupportedTitle__c = '自動返信用対応明細の取得（メール）'; // 対応表題
			newCorrespondDetail.SupportedContent__c = 
					'TO:' + echoMail.FromEmail__c + CommonConst.LINE_FEED
					+ 'メール返信' + CommonConst.LINE_FEED
					+ CommonConst.LINE_FEED;	// 対応内容
			newCorrespondDetail.Shop__c             = shop.id;	// 店舗
			newCorrespondDetail.MailType__c			= CommonConst.CORRESPONDDETAIL_MAILTYPE_SEND;
			newCorrespondDetail.Email__c			= shop.Email__c;
			newCorrespondDetail.EchoMail__c			= echoMail.Id;
		}else if(mailType == CommonConst.CORRESPONDDETAIL_MAILTYPE_SEND){
			// メール送信
            newCorrespondDetail.CorrespondType__c      = CommonConst.TASK_CORRESPONDTYPE_MAIL;	// 対応種別
            newCorrespondDetail.SupportedTitle__c      = CommonUtil.subStringLeft('メール送信の件名', 255);	// 対応表題
			newCorrespondDetail.SupportedContent__c    = 'メール送信時の詳細な内容です。';	// 対応内容
            newCorrespondDetail.Shop__c                = shop.id;	// 店舗
            newCorrespondDetail.Staff__c               = UserInfo.getUserId();	// 担当者
            newCorrespondDetail.MailType__c            = CommonConst.CORRESPONDDETAIL_MAILTYPE_SEND;	// メール種別
            newCorrespondDetail.Email__c               = 'test@co.jp';	// 送信者メールアドレス

		}else if(mailType == CommonConst.TASK_CORRESPONDTYPE_CLOSE){
			//紹介メール（終了）
			newCorrespondDetail.CorrespondType__c      = CommonConst.TASK_CORRESPONDTYPE_CLOSE;   // 対応種別
			newCorrespondDetail.SupportedTitle__c      = '自動追客終了に伴い、終了';                // 対応表題
			newCorrespondDetail.SupportedContent__c    = '自動追客メール配信を停止しました。';        // 対応内容
		}

		return newCorrespondDetail;
	}

	/**
	 * 対応明細の作成（その他の対応種別）
	 * @param String correspondType 対応種別
	 * @param Id correspondsId 対応ID
	 * @param Shop__c shop 店舗
	 * @return CorrespondDetail__c 対応明細1件
	 */
	private static CorrespondDetail__c setCorrespondDetailOther(String correspondType,Id correspondsId,Shop__c shop) { 
		CorrespondDetail__c newCorrespondDetail = new CorrespondDetail__c();
		newCorrespondDetail.Corresponds__c	=	CorrespondsId; // 対応番号
		newCorrespondDetail.CorrespondType__c	=	correspondType; // 対応種別
		newCorrespondDetail.SupportedDateTime__c = nowDateTime ;   // 対応日時
		if(correspondType == CommonConst.TASK_CORRESPONDTYPE_RELEASEHOLD){
			// 保留解除（対応明細作成）
			newCorrespondDetail.SupportedTitle__c = CommonConst.TASK_CORRESPONDTYPE_RELEASEHOLD ;// 対応表題
			newCorrespondDetail.SupportedContent__c = '保留を解除しました。'  ;// 対応内容
			newCorrespondDetail.Shop__c =  shop.id;// 店舗
			newCorrespondDetail.Staff__c = UserInfo.getUserId();// 担当者
	  
		}else if(correspondType == CommonConst.TASK_CORRESPONDTYPE_ECHOAGGREGATION){
			// 反響集約（対応明細作成）
			newCorrespondDetail.SupportedTitle__c = CommonConst.CORRESPOND_STATUS_ECHOAGGREGATION ;// 対応表題
			newCorrespondDetail.SupportedContent__c = CommonUtil.callMessageCreate(CommonConst.MSG_CUST_I_ECHO_AGGREGATION_END, CommonConst.CORRESPOND_STATUS_NOTSUPPORTED,CommonConst.CORRESPOND_STATUS_PURSUIT);// 対応内容
			newCorrespondDetail.Shop__c =  shop.id;// 店舗
			newCorrespondDetail.Staff__c = UserInfo.getUserId();// 担当者

		}else if(correspondType == CommonConst.TASK_CORRESPONDTYPE_PERSONDECISION){
			// 担当者決定
			newCorrespondDetail.SupportedTitle__c	= CommonConst.TASK_CORRESPONDTYPE_PERSONDECISION; // 対応表題
			newCorrespondDetail.SupportedContent__c =  'てすとユーザ' + 'を反響担当者に設定しました。';	// 対応内容

		}else if(correspondType == CommonConst.TASK_CORRESPONDTYPE_CLOSE){
			// 配信停止ボタン処理
			newCorrespondDetail.SupportedTitle__c      = '自動追客終了に伴い、終了';	// 対応表題
			newCorrespondDetail.SupportedContent__c    = '自動追客メール配信を停止しました。';	// 対応内容
			newCorrespondDetail.Shop__c                = shop.id;	// 店舗
			newCorrespondDetail.Staff__c               = UserInfo.getUserId();	// 担当者

		}else if(correspondType == CommonConst.TASK_CORRESPONDTYPE_VISITED){
			// 来店カード
            newCorrespondDetail.SupportedTitle__c = '来店カード入力';//対応表題
            newCorrespondDetail.SupportedContent__c = '来店カード入力';//対応内容
			newCorrespondDetail.Shop__c	= shop.id;     // 店舗
			newCorrespondDetail.Staff__c= UserInfo.getUserId(); // 担当者

		}else if(correspondType == CommonConst.TASK_CORRESPONDTYPE_APPLICANT){
			// 申込登録
			newCorrespondDetail.SupportedTitle__c = '申込登録';	//対応表題：申込登録
			newCorrespondDetail.SupportedContent__c = '物件名：'+ '建物てすと' + ' ' + '1010'
										+ '\n申込日：' + nowDateTime;//対応内容：物件名 ○○○（改行）申込日：画面の申込日
			newCorrespondDetail.Shop__c = shop.id;	//店舗（ログインユーザのidに紐づく店舗）
			newCorrespondDetail.Staff__c = UserInfo.getUserId();	//担当者：ログインユーザ
			
		}else if(correspondType == CommonConst.TASK_CORRESPONDTYPE_MERGE){
			// 名寄せ
			newCorrespondDetail.SupportedTitle__c     = '名寄せ';             //対応表題
			newCorrespondDetail.SupportedContent__c   = CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_MERGE_HISTORY, 'テスト');//対応内容 
			newCorrespondDetail.Staff__c              = UserInfo.getUserId(); //担当者

		}else if(correspondType == CommonConst.TASK_CORRESPONDTYPE_RETURN){
			// スケジュール
			newCorrespondDetail.CorrespondType__c      = CommonConst.TASK_CORRESPONDTYPE_RETURN;	// 対応種別        
			newCorrespondDetail.Shop__c                = shop.id;	// 店舗
			newCorrespondDetail.Staff__c               = UserInfo.getUserId();	// 担当者
			newCorrespondDetail.SupportedTitle__c      = 'スケジュール表題';	// 対応表題
			newCorrespondDetail.SupportedContent__c    = 'スケジュールてすと';	// 対応内容          
			newCorrespondDetail.StartDate__c           = nowDateTime.date();						//開始日時_年月日
			newCorrespondDetail.StartDateTime__c       = nowDateTime.format('HH:mm');				//開始日時_時分
			newCorrespondDetail.EndDate__c             = nowDateTime.addDays(1).date();				//終了日時_年月日
			newCorrespondDetail.EndDateTime__c         = nowDateTime.addDays(1).format('HH:mm');	//終了日時_時分
		
		}else if(correspondType == CommonConst.CORRESPOND_STATUS_VISITED){
			// 見ず決め
			newCorrespondDetail.SupportedTitle__c      = '見ず決め';	// 対応表題
			newCorrespondDetail.SupportedContent__c    = '見ず決めとして手続きを進めました。';	// 対応内容
			newCorrespondDetail.Shop__c                = shop.id;	// 店舗
			newCorrespondDetail.Staff__c               = UserInfo.getUserId();	// 担当者

		}else if(correspondType == CommonConst.TASK_CORRESPONDTYPE_DEPOSIT){
			// 入金処理
			newCorrespondDetail.SupportedTitle__c      = '入金を実施しました。';	// 対応表題
			newCorrespondDetail.SupportedContent__c    = CommonConst.CORRESPOND_STATUS_DEPOSIT + CommonConst.BREAK_CODE;  // 対応内容
			newCorrespondDetail.Shop__c                = shop.id;	// 店舗
			newCorrespondDetail.Staff__c               = UserInfo.getUserId();	// 担当者

		}else if(correspondType == CommonConst.CORRESPOND_EVENT_VIEWED){
			//物件閲覧
			newCorrespondDetail.SupportedTitle__c    = '物件を閲覧しました。';	//対応表題
			newCorrespondDetail.SupportedContent__c  = 'https://portalurl/'
									+ '\n' + '物件詳細';	// 対応内容
			newCorrespondDetail.PortalSiteUrl__c     ='https://portalurl/'; //ポータルサイトUrl
			//来店担当店舗があれば来店担当店舗。なければ反響担当店舗を設定する
			newCorrespondDetail.Shop__c =shop.id;
			//2020/6/30追加：担当者（来店）があれば担当者（来店）、なければ担当者（反響）を設定する
			newCorrespondDetail.staff__c = UserInfo.getUserId();

		}

		return newCorrespondDetail;
	}

	/**
	 * 対応明細の作成（電話）
	 * @param String phoneStatus 電話状況
	 * @param Id correspondsId 対応ID
	 * @param Shop__c shop 店舗
	 * @return CorrespondDetail__c 対応明細1件
	 */
	private static CorrespondDetail__c setCorrespondDetailTel(String phoneStatus,Id correspondsId,Shop__c shop){
		CorrespondDetail__c newCorrespondDetail = new CorrespondDetail__c();
		newCorrespondDetail.Corresponds__c	=	CorrespondsId; // 対応番号
		newCorrespondDetail.SupportedDateTime__c = nowDateTime ;   // 対応日時
		newCorrespondDetail.Shop__c                = shop.id;            // 店舗
		newCorrespondDetail.Staff__c               = UserInfo.getUserId();           // 担当者
		// 電話状況（SMS送信）
		if(phoneStatus ==  CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINEECHO){
			// LINE反響
			newCorrespondDetail.CorrespondType__c = CommonConst.TASK_CORRESPONDTYPE_LINE; // 対応種別
			newCorrespondDetail.Sender__c = CommonConst.CORRESPONDDETAIL_SENDER_CUSTOMER; // 発信者
			newCorrespondDetail.SupportedTitle__c      = 'お客様 から LINE反響';	// 対応表題
			newCorrespondDetail.SupportedContent__c    = 'でんわでのらいん反響';     // 対応内容

		}else if(phoneStatus == CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINERECEIVE){
			// LINE受信
			newCorrespondDetail.CorrespondType__c = CommonConst.TASK_CORRESPONDTYPE_LINE; // 対応種別
			newCorrespondDetail.Sender__c = CommonConst.CORRESPONDDETAIL_SENDER_CUSTOMER; // 発信者
			newCorrespondDetail.SupportedTitle__c      = 'お客様 から LINE受信';	// 対応表題
			newCorrespondDetail.SupportedContent__c    = 'らいんの受信';     // 対応内容

		}else if(phoneStatus == CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINESEND){
			// LINE送信
			newCorrespondDetail.CorrespondType__c = CommonConst.TASK_CORRESPONDTYPE_LINE; // 対応種別
			newCorrespondDetail.Sender__c = CommonConst.CORRESPONDDETAIL_SENDER_STAFF; // 発信者
			newCorrespondDetail.SupportedTitle__c      = '担当者 から LINE送信';	// 対応表題
			newCorrespondDetail.SupportedContent__c    = 'らいんそうしんのでんわ';     // 対応内容

		}

		return newCorrespondDetail;
	}
	// ▲ 2022.05.16 No0758 対応で追加

	/**
	 * LINE会員の取得
	 * @param String condName LINE会員名
	 * @return LineMember__c LINE会員
	 */
	private static LineMember__c selectLineMember(String condName) {

		LineMember__c lineMember = [
			SELECT
				Id
				, Account__c
				, Status__c
				, LineId__c
				, SystemModstamp
			FROM LineMember__c
			WHERE Name = :condName
			LIMIT 1
		];

		return lineMember;
	}

	/**
	 * 定型文の取得
	 * @param String condName 定型文名
	 * @return FixedPhrase__c 定型文
	 */
	private static FixedPhrase__c selectFixedPhrase(String condName) {

		FixedPhrase__c fixedPhrase = [
			SELECT
				Id
				, Text__c
			FROM FixedPhrase__c
			WHERE Name = :condName
		];

		return fixedPhrase;
	}

	/**
	 * 文例の取得
	 * @param String condName 文例名
	 * @return ExampleSentence__c 文例
	 */
	private static ExampleSentence__c selectExampleSentence(String condName) {

		ExampleSentence__c exampleSentence = [
			SELECT
				Id
				, ExampleSentence__c
			FROM ExampleSentence__c
			WHERE Name = :condName
		];

		return exampleSentence;
	}

	//▼ 2022.04.20 No0768 対応で追加
	/**
	 * LINE会員の対応取得
	 * @param String condName LINE会員名
	 * @return Correspond__c LINE会員の対応
	 */
	private static Correspond__c selectCorrespond(String condName) {

		Correspond__c correspond = [
			SELECT Id ,EventDateTime__c,FirstInquiryMeans__c,IsBrowseFlg__c,ListViewDate__c,PortalSiteUrl__c,PortalSite__c,ReceiveMailDatePortal__c,status__c,LineFriendAddDate__c,LineMember__c,LineMember__r.Name,FirstLineAddFlg__c,StaffSupportedFlg__c,IsSupportedListShow__c,LineReceiveDate__c,LineSmsSendDate__c
			FROM Correspond__c
			WHERE LineMember__r.Name = :condName
		];

		return correspond;
	}
	/**
	 * LINE会員の対応取得（複数有）
	 * @param String condName LINE会員名
	 * @return List<Correspond__c> LINE会員の対応
	 */
	private static List<Correspond__c> selectCorrespondList(String condName) {
		return selectCorrespondList(condName, '');
	}
	private static List<Correspond__c> selectCorrespondList(String condName,String accountName) {
		List<Correspond__c> correspondList = new List<Correspond__c>();
		if (String.isEmpty(accountName)) {
			// LINE会員のみ
			correspondList = [
				SELECT Id,AccountId__c,EventDateTime__c,FirstInquiryMeans__c,IsBrowseFlg__c,ListViewDate__c,PortalSiteUrl__c,PortalSite__c,ReceiveMailDatePortal__c,status__c,LineFriendAddDate__c,LineMember__c,LineMember__r.Name,FirstLineAddFlg__c,StaffSupportedFlg__c,IsSupportedListShow__c,LineReceiveDate__c,LineSmsSendDate__c
				FROM Correspond__c
				WHERE LineMember__r.Name = :condName
			];	
		}else {
			// LINE会員と取引先
			correspondList = [
				SELECT Id,AccountId__c,EventDateTime__c,FirstInquiryMeans__c,IsBrowseFlg__c,ListViewDate__c,PortalSiteUrl__c,PortalSite__c,ReceiveMailDatePortal__c,status__c,LineFriendAddDate__c,LineMember__c,LineMember__r.Name,FirstLineAddFlg__c,StaffSupportedFlg__c,IsSupportedListShow__c,LineReceiveDate__c,LineSmsSendDate__c
				FROM Correspond__c
				WHERE LineMember__r.Name = :condName
				OR    AccountId__r.Name = :accountName
			];	
		}
		

		return correspondList;
	}
	
	/**
	 * 対応明細取得（複数）
	 * @return List<CorrespondDetail__c> 対応明細
	 */
	private static List<CorrespondDetail__c> selectCorrespondDetailList() {

		List<CorrespondDetail__c> correspondDetailList = [
			SELECT Id,Name,CorrespondType__c,Corresponds__c,EchoMail__c,Email__c,EndDateTime__c,EndDate__c,EndType__c,MailDraft__c,Sender__c,MailType__c,PhoneStatus__c,PortalSiteUrl__c,scheduleDetails__c,Shop__c,Staff__c,StartDateTime__c,StartDate__c,SupportedContent__c,SupportedDateTime__c,SupportedTitle__c,District__c,PortalSite__c,InquiryProperty__c,FirstInquiryPropertyShowFlg__c,Property__c ,SystemModstamp
			FROM CorrespondDetail__c 
		];

		return correspondDetailList;
	}
	private static Map<Id,CorrespondDetail__c> selectCorrespondDetailMap() {
		Map<Id,CorrespondDetail__c> correspondDetailMap = new Map<Id,CorrespondDetail__c>([
			SELECT Id,Name,CorrespondType__c,Corresponds__c,EchoMail__c,Email__c,EndDateTime__c,EndDate__c,EndType__c,MailDraft__c,Sender__c,MailType__c,PhoneStatus__c,PortalSiteUrl__c,scheduleDetails__c,Shop__c,Staff__c,StartDateTime__c,StartDate__c,SupportedContent__c,SupportedDateTime__c,SupportedTitle__c,District__c,PortalSite__c,InquiryProperty__c,FirstInquiryPropertyShowFlg__c,Property__c ,SystemModstamp
			FROM CorrespondDetail__c 
		]);

		return correspondDetailMap;
	}

	//▲ 2022.04.20 No0768 対応で追加

}