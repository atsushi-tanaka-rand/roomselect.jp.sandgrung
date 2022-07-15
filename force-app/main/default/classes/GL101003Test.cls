/**
 * LINEユーザ紐づけ画面 
 */
@isTest
public with sharing class GL101003Test {
	public static final String USER_NAME = 'ippanUserGL101003Test@test.com';	// 2022.04.20 No0768 ユーザ名が他と被る可能性があるので一意になりそうな内容へ変更

	/**
	 * テストに使用するレコードの作成
	 */
	@TestSetup
	static void setting() {
		// 標準プロファイルを取得
		Id profileId = [SELECT Id FROM Profile WHERE Name = '一般ユーザ'].Id;

		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

		//▼ 2022.04.20 No0768 対応で変更
		Id accountRecordTypeId = CommonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER); // 顧客
		// カスタム設定を最初に設定
		SystemConfig__c testSystemConfig = new SystemConfig__c(
        	UseAuthority_Portal__c = true // 利用権限
			, IsSkipTrigger__c= true 
		);
        insert testSystemConfig;
		//▲ 2022.04.20 No0768 対応で変更

		System.runAs(thisUser) {
			// ユーザの登録
			User testUser = new User(
				LastName = 'ippanUser', // 姓
				Alias = 'alias', // 別名
				Email = 'ippanUserGL101003Test@test.com', // メール
				UserName = USER_NAME, //ユーザ名
				CommunityNickname = 'テストニックネーム', // ニックネーム
				EmailEncodingKey = 'ISO-2022-JP', // メールの文字コード
				TimeZoneSidKey = 'Asia/Tokyo', // タイムゾーン
				LocaleSidKey = 'ja_JP', // 地域
				LanguageLocaleKey = 'ja', // 言語
				ProfileId = profileId // プロファイルID
			);
			insert testUser;
		}
		User testUser = [SELECT Id FROM User WHERE UserName = :USER_NAME];

         // 店舗データ
		 Shop__c shopRecord = new Shop__c(Name	 = '店舗ユーザテスト_港区'	 // 店舗名
         );
         insert ShopRecord;

        // 組織階層レコード
		 OrganizationHierarchy__c orgRecord = new OrganizationHierarchy__c(
			OrganizationCode__c = '0001',
			OrganizationName__c = '本部',
			HierarchyCode__c = '10',
			HierarchyOrder__c = 1,
			UpperOrganizationHierarchy__c = null,
			ExpandedOrganizationCode__c = '0000_0001',
			Shop__c = ShopRecord.Id
		);
		insert orgRecord;

		// 取引先
		Account accountRecord = new Account(
			Name = 'テスト太郎', // 取引先
            Phone = '00089671122', // 電話
			RecordTypeId =accountRecordTypeId // レコードタイプ：顧客 // 2022.04.20 No0768 対応で追加
		);
		insert accountRecord;

		// LINE会員
		LineMember__c lineMember = new LineMember__c(
			Name = 'テスト太郎', // LINE名
			LineId__c = '000111222', // LINE Id
			FriendRegistCode__c = '555', // ともだち追加コード
			AddFriendTime__c = CommonUtil.getNow() // ともだち追加時刻
		);
		insert lineMember;
		//▼ 2022.04.20 No0768 対応で追加
		// 取引先		
		Account accountRecord1 = new Account(Name = '対応終了_LINE会員候補用', Phone = '11' ,RecordTypeId =accountRecordTypeId );
		Account accountRecord2 = new Account(Name = '対応契約完了_LINE会員候補用', Phone = '12',RecordTypeId =accountRecordTypeId );
		Account accountRecord3 = new Account(Name = '対応反響集約_LINE会員候補用', Phone = '13',RecordTypeId =accountRecordTypeId );
		Account accountRecord4 = new Account(Name = '対応未対応_LINE会員候補用', Phone = '14',RecordTypeId =accountRecordTypeId );
		Account accountRecord5 = new Account(Name = '対応追客中_LINE会員候補用', Phone = '15',RecordTypeId =accountRecordTypeId );

		Account accountRecord6 = new Account(Name = '対応追客中_取引先', Phone = '21' ,RecordTypeId =accountRecordTypeId );
		Account accountRecord7 = new Account(Name = '対応終了_取引先', Phone = '22' ,RecordTypeId =accountRecordTypeId );
		Account accountRecord8 = new Account(Name = '対応無_取引先', Phone = '31' ,RecordTypeId =accountRecordTypeId );
		insert  new List<Account>{ accountRecord1,accountRecord2,accountRecord3,accountRecord4,accountRecord5
			,accountRecord6,accountRecord7,accountRecord8
		};

		testSystemConfig.IsSkipTrigger__c = false;
		update testSystemConfig;
		Datetime nowDateTime = CommonUtil.getNow();
		LineMember__c lineMember1 = new LineMember__c(Name = '対応終了_取引先無' , LineId__c= 'Uf124585fafd38f4337a2434830d55001',AddFriendTime__c = nowDateTime ); 
		LineMember__c lineMember2 = new LineMember__c(Name = '対応契約完了_取引先無' , LineId__c= 'Uf124585fafd38f4337a2434830d55002',AddFriendTime__c = nowDateTime); 
		LineMember__c lineMember3 = new LineMember__c(Name = '対応反響集約_取引先無' , LineId__c= 'Uf124585fafd38f4337a2434830d55003',AddFriendTime__c = nowDateTime); 
		LineMember__c lineMember4 = new LineMember__c(Name = '対応未対応_取引先無' , LineId__c= 'Uf124585fafd38f4337a2434830d55004',AddFriendTime__c = nowDateTime);
		LineMember__c lineMember5 = new LineMember__c(Name = '対応追客中_取引先無' , LineId__c= 'Uf124585fafd38f4337a2434830d55005',AddFriendTime__c = nowDateTime); 

		LineMember__c lineMember11 = new LineMember__c(Name = '対応終了_LINE会員候補用' , LineId__c= 'Uf124585fafd38f4337a2434830d55011',AddFriendTime__c = nowDateTime ,FriendRegistCode__c = '011' );
		LineMember__c lineMember12 = new LineMember__c(Name = '対応契約完了_LINE会員候補用' , LineId__c= 'Uf124585fafd38f4337a2434830d55012',AddFriendTime__c = nowDateTime ,FriendRegistCode__c = '012' );
		LineMember__c lineMember13 = new LineMember__c(Name = '対応反響集約_LINE会員候補用' , LineId__c= 'Uf124585fafd38f4337a2434830d55013',AddFriendTime__c = nowDateTime ,FriendRegistCode__c = '013' );
		LineMember__c lineMember14 = new LineMember__c(Name = '対応未対応_LINE会員候補用' , LineId__c= 'Uf124585fafd38f4337a2434830d55014',AddFriendTime__c = nowDateTime ,FriendRegistCode__c = '014' );
		LineMember__c lineMember15 = new LineMember__c(Name = '対応追客中_LINE会員候補用' , LineId__c= 'Uf124585fafd38f4337a2434830d55015',AddFriendTime__c = nowDateTime ,FriendRegistCode__c = '015' ); 
		insert  new List<LineMember__c>{
			lineMember1,lineMember2,lineMember3,lineMember4,lineMember5,
			lineMember11,lineMember12,lineMember13,lineMember14,lineMember15
		};
		// 更新用IDリスト設定
		List<ID> lineMemberIDList = new List<ID>{
			lineMember1.Id,lineMember2.Id,lineMember3.Id,lineMember4.id,lineMember5.id,
			lineMember11.id,lineMember12.id,lineMember13.id,lineMember14.id,lineMember15.id
		};
		// 対応修正（BL101001TriggerHandlerにて作成されているはず）
		List<Correspond__c> correspondList = [SELECT Id ,EventDateTime__c,FirstInquiryMeans__c,IsBrowseFlg__c,ListViewDate__c,PortalSiteUrl__c,PortalSite__c,ReceiveMailDatePortal__c,status__c,LineFriendAddDate__c,LineMember__c,LineMember__r.Name,FirstLineAddFlg__c
			FROM Correspond__c
			WHERE LineMember__c IN :lineMemberIDList 
		];
		List<Correspond__c> updateCorrespondList = new List<Correspond__c>();
		for (Correspond__c changeCorrespond : correspondList) {
			// 既存テストの状態をここで設定
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
			}else if (changeCorrespond.LineMember__r.Name == '対応終了_LINE会員候補用') {
					changeCorrespond.status__c = CommonConst.CORRESPOND_STATUS_CLOSE;	// ステータス（終了）
					updateCorrespondList.add(changeCorrespond);
			}else if (changeCorrespond.LineMember__r.Name == '対応契約完了_LINE会員候補用') {
				changeCorrespond.status__c = CommonConst.CORRESPOND_STATUS_AGREEMENT;	// ステータス（契約完了）
				updateCorrespondList.add(changeCorrespond);
			}else if (changeCorrespond.LineMember__r.Name == '対応反響集約_LINE会員候補用') {
				changeCorrespond.status__c = CommonConst.CORRESPOND_STATUS_ECHOAGGREGATION;	// ステータス（反響集約）
				updateCorrespondList.add(changeCorrespond);
			}else if (changeCorrespond.LineMember__r.Name == '対応追客中_LINE会員候補用') {
				changeCorrespond.status__c = CommonConst.CORRESPOND_STATUS_PURSUIT;	// ステータス（追客中）
				updateCorrespondList.add(changeCorrespond);
			}
			if (updateCorrespondList.size() > 0) {
				update updateCorrespondList;
			}	
		}

		// 対応（取引先）
		Correspond__c correspond1 = new Correspond__c(
			AccountId__c = accountRecord6.Id, // 取引先
			status__c = CommonConst.CORRESPOND_STATUS_PURSUIT	// ステータス（追客中）
		);
		Correspond__c correspond2 = new Correspond__c(
			AccountId__c = accountRecord7.Id, // 取引先
			status__c = CommonConst.CORRESPOND_STATUS_CLOSE	// ステータス（終了）
		);
		insert new List<Correspond__c>{
			correspond1,correspond2
		};

		// LINE会員候補
		LineMemberCandidate__c lineMemberCandidate1 = new LineMemberCandidate__c(Account__c = accountRecord1.Id, FriendRegistCode__c = '011' );
		LineMemberCandidate__c lineMemberCandidate2 = new LineMemberCandidate__c(Account__c = accountRecord2.Id, FriendRegistCode__c = '012' );
		LineMemberCandidate__c lineMemberCandidate3 = new LineMemberCandidate__c(Account__c = accountRecord3.Id, FriendRegistCode__c = '013' );
		LineMemberCandidate__c lineMemberCandidate4 = new LineMemberCandidate__c(Account__c = accountRecord4.Id, FriendRegistCode__c = '014' );
		LineMemberCandidate__c lineMemberCandidate5 = new LineMemberCandidate__c(Account__c = accountRecord5.Id, FriendRegistCode__c = '015' );
		insert  new List<LineMemberCandidate__c>{ lineMemberCandidate1,lineMemberCandidate2,lineMemberCandidate3,lineMemberCandidate4,lineMemberCandidate5};
		testSystemConfig.IsSkipTrigger__c = true;
		update testSystemConfig;
		//▲ 2022.04.20 No0768 対応で追加

		// 対応
		Correspond__c correspond = new Correspond__c(
			AccountId__c = accountRecord.Id, // 取引先
			LineMember__c = lineMember.Id // LINE会員
		);
		insert correspond;

		// LINE会員候補
		LineMemberCandidate__c lineMemberCandidate = new LineMemberCandidate__c(
			Account__c = accountRecord.Id, // 取引先
			FriendRegistCode__c = '555' // ともだち登録コード
		);
		insert lineMemberCandidate;

		// 紹介メール情報
		IntroductionMailInformation__c introductionMailInformation = new IntroductionMailInformation__c(
			Correspond__c = correspond.Id, // 対応
			Account__c = accountRecord.Id // 取引先
		);
		// リストに追加
		List<IntroductionMailInformation__c> introductionMailInformationList = new List<IntroductionMailInformation__c>{
			introductionMailInformation
		};
		insert introductionMailInformationList;

		// ログインユーザ
		ShopTransfer__c shopTransferRecord = new ShopTransfer__c(OrgzanizationHierarchy__c = orgRecord.id,
			Staff__c = testUser.Id, // スタッフ
			StartDate__c = CommonUtil.getToday(),
			EndDate__c = CommonUtil.getToday()
		); 
		insert shopTransferRecord;

	}

	/**
	 * 検索結果表示
	 */
	@isTest
	static void detailDisplayProcessTest() {
		// 検索結果の設定テスト
		// 一般ユーザで実行
		User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];

		// LINE会員
		LineMember__c lineMember = [SELECT Id FROM LineMember__c WHERE Name = 'テスト太郎'];
		
		// 対応
		Correspond__c correspond = [SELECT Id FROM Correspond__c WHERE LineMember__c = :lineMember.Id LIMIT 1 ];

		System.runAs(ippanUser) {
			Test.startTest();
			// 初期表示
			PageReference pageRef = Page.GL101003View;
			pageRef.getParameters().put('lineMemberId', lineMember.Id);
			pageRef.getParameters().put('correspondId', correspond.Id);
			Test.setCurrentPage(pageRef);

			// 検索条件部の値を変更して検索（検索条件不一致）
			GL101003Controller testController = new GL101003Controller();
			testController.screenLineUserLinking.condAccountName = 'Name01';
			testController.screenLineUserLinking.condPhone = 'Phone01';
			testController.screenLineUserLinking.condCreatedDate = CommonUtil.getToday();
			
			// 検索ボタン押下処理
            testController.searchResultDetailSet();
			// 検索結果の確認（assert）
			System.assert(testController.screenLineUserLinking.searchResultList.size() == 0, '');

            Test.stopTest();
		}
	}

	/**
	 * お客様登録と紐づけボタン押下
	 */
	@isTest
	static void linkDataRegisterAccountTest(){
		// 一般ユーザで実行
		User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];

		// LINE会員
		LineMember__c lineMember = [SELECT Id, Name FROM LineMember__c WHERE Name = 'テスト太郎'];

		// 対応
		Correspond__c correspond = [SELECT Id FROM Correspond__c WHERE LineMember__c = :lineMember.Id LIMIT 1];

		System.runAs(ippanUser) {
			Test.startTest();
			// 初期表示
			PageReference pageRef = Page.GL101003View;
			pageRef.getParameters().put('lineMemberId', lineMember.Id);
			pageRef.getParameters().put('correspondId', correspond.Id);
			Test.setCurrentPage(pageRef);
			GL101003Controller testController = new GL101003Controller();

			// 決定ボタン押下処理
			testController.linkDataRegisterAccount();

			// 取引先の確認（assert）
			List<Account> account = [SELECT Id FROM Account WHERE Name = :lineMember.Name];
			System.assert(account[0] != null, '');

			Test.stopTest();
		}
	}

	/**
	 * 決定ボタン押下（マッチング候補者一覧）
	 */
	@isTest
	static void linkDataMatchTest() {
		// 一般ユーザで実行
		User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];

		// LINE会員
		LineMember__c lineMember = [SELECT Id FROM LineMember__c WHERE Name = 'テスト太郎'];

		// 対応
		Correspond__c correspond = [SELECT Id FROM Correspond__c WHERE LineMember__c = :lineMember.Id LIMIT 1];

		System.runAs(ippanUser) {
			Test.startTest();
			// 初期表示
			PageReference pageRef = Page.GL101003View;
			pageRef.getParameters().put('lineMemberId', lineMember.Id);
			pageRef.getParameters().put('correspondId', correspond.Id);
			Test.setCurrentPage(pageRef);
			GL101003Controller testController = new GL101003Controller();

			// 決定ボタン押下処理
			testController.screenLineUserLinking.detailIndex = 0;
			testController.linkDataMatch();

			// 対応明細の確認（assert)
			List<CorrespondDetail__c> correspondDetail = [SELECT Id FROM CorrespondDetail__c WHERE Corresponds__c =:correspond.Id];
			System.assert(correspondDetail[0] != null, '');

			Test.stopTest();
		}
	}

	/**
	 * 決定ボタン押下（検索結果）
	 */
	@isTest
	static void linkDataSearchTest() {
		// 一般ユーザで実行
		User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];

		// LINE会員
		LineMember__c lineMember = [SELECT Id FROM LineMember__c WHERE Name = 'テスト太郎'];

		// 対応
		Correspond__c correspond = [SELECT Id FROM Correspond__c WHERE LineMember__c = :lineMember.Id LIMIT 1];
		System.runAs(ippanUser) {
			Test.startTest();
			// 初期表示
			PageReference pageRef = Page.GL101003View;
			pageRef.getParameters().put('lineMemberId', lineMember.Id);
			pageRef.getParameters().put('correspondId', correspond.Id);
			Test.setCurrentPage(pageRef);

			// 検索処理
			GL101003Controller testController = new GL101003Controller();
			testController.screenLineUserLinking.condAccountName = 'テスト太郎';
            testController.searchResultDetailSet();

			// 決定ボタン押下処理
			testController.screenLineUserLinking.detailIndex = 0;
			testController.linkDataSearch();

			// 対応明細の確認（assert)
			List<CorrespondDetail__c> correspondDetail = [SELECT Id FROM CorrespondDetail__c WHERE Corresponds__c =:correspond.Id];
			
			System.assert(correspondDetail[0] != null, '');

			Test.stopTest();
		}
	}

	/**
	 * 検索結果の設定（例外処理）
	 */
	@isTest
	static void detailDisplayProcessExceptionTest() {
		// 一般ユーザで実行
		User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];
		System.assert(ippanUser != null, '');

		System.runAs(ippanUser) {
			Test.startTest();
			// 初期表示
			PageReference pageRef = Page.GL101003View;
			Test.setCurrentPage(pageRef);

			// 検索条件部の値を変更して検索（例外処理）
			GL101003Controller testController = new GL101003Controller();
            testController.searchResultDetailSet();
            Test.stopTest();
		}
	}

	/**
	 * 決定ボタン押下（例外処理）
	 */
	@isTest
	static void linkDataSearchExceptionTest() {
		// 一般ユーザで実行
		User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];

		// LINE会員
		LineMember__c lineMember = [SELECT Id FROM LineMember__c WHERE Name = 'テスト太郎'];

		// 対応
		Correspond__c correspond = [SELECT Id FROM Correspond__c WHERE LineMember__c = :lineMember.Id LIMIT 1];

		System.runAs(ippanUser) {
			Test.startTest();
			// 初期表示
			PageReference pageRef = Page.GL101003View;
			pageRef.getParameters().put('lineMemberId', lineMember.Id);
			pageRef.getParameters().put('correspondId', correspond.Id);
			Test.setCurrentPage(pageRef);

			// 検索処理
			GL101003Controller testController = new GL101003Controller();
			testController.screenLineUserLinking.condAccountName = 'テスト太郎';
            testController.searchResultDetailSet();

			// データの更新
			lineMember.Name = '更新';
			update lineMember;

			// 決定ボタン押下処理
			testController.screenLineUserLinking.detailIndex = 0;
			testController.linkDataSearch();

			// 対応明細の確認（assert)
			List<CorrespondDetail__c> correspondDetail = [SELECT Id FROM CorrespondDetail__c WHERE Corresponds__c =:correspond.Id];
			System.assert(correspondDetail.size() == 0, '');
			
			Test.stopTest();
		}
	}

	/**
	 * お客様登録と紐づけボタン押下（例外処理）
	 */
	@isTest
	static void linkDataRegisterAccountExceptionTest(){
		// 一般ユーザで実行
		User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];

		// LINE会員
		LineMember__c lineMember = [SELECT Id FROM LineMember__c WHERE Name = 'テスト太郎'];
		System.assert(lineMember != null, 'error:' + (CommonConst.MSG_COM_E_SYSTEM_PARAMETER));

		// 対応
		Correspond__c correspond = [SELECT Id FROM Correspond__c WHERE LineMember__c = :lineMember.Id LIMIT 1];
		System.assert(correspond != null, 'error:' + (CommonConst.MSG_COM_E_SYSTEM_PARAMETER));

		System.runAs(ippanUser) {
			Test.startTest();
			// 初期表示
			PageReference pageRef = Page.GL101003View;
			pageRef.getParameters().put('lineMemberId', lineMember.Id);
			pageRef.getParameters().put('correspondId', correspond.Id);
			Test.setCurrentPage(pageRef);
			GL101003Controller testController = new GL101003Controller();

			// データの更新
			lineMember.Name = '更新';
			update lineMember;

			// 決定ボタン押下処理
			testController.linkDataRegisterAccount();

			// 取引先の確認（assert）
			List<Account> account = [SELECT Id FROM Account WHERE Name = 'LINEユーザ紐づけ画面で登録'];
			System.assert(account.size() == 0, '');

			Test.stopTest();
		}
	}

	/**
	 * メッセージクラステスト
	 */
	@isTest 
	static void coverageUp() {
		// 一般ユーザで実行
		User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];
		System.assert(ippanUser != null, '');

		System.runAs(ippanUser) {
			GL101003Controller testController = new GL101003Controller();
			testController.message.getLinkingMessage();
			testController.message.getCompletionMessage();
			testController.message.getCompletionMessageCorrespons();
			testController.message.getRegisterLinkingMessage();
		}
	}

	//▼ 2022.04.20 No0768 対応で追加
	/**
	* お客様登録と紐づけボタン押下
	*     遷移元のパラメータの対応．ステータス：反響集約、終了、契約完了の場合
	*     
	*/
	// ステータス、LINE会員：終了
	@istest
	static void linkDataRegisterAccountTest02(){
		// 一般ユーザで実行
		User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];

		// LINE会員
		LineMember__c lineMember = [SELECT Id FROM LineMember__c WHERE Name = '対応終了_取引先無'];

		System.runAs(ippanUser) {

			List<Correspond__c> beforeCorrespondList = selectCorrespondList('対応終了_取引先無');
			Test.startTest();
			// 初期表示
			PageReference pageRef = Page.GL101003View;
			pageRef.getParameters().put('lineMemberId', lineMember.Id);
			pageRef.getParameters().put('correspondId', beforeCorrespondList[0].Id);
			Test.setCurrentPage(pageRef);
			GL101003Controller testController = new GL101003Controller();

			// お客様登録と紐づけボタン押下
			testController.linkDataRegisterAccount();

			Test.stopTest();

			// 実施後
			// 取引先の確認（assert）
			List<Account> account = [SELECT Id FROM Account WHERE Name = '対応終了_取引先無'];
			System.assertEquals(account.size() , 1, '');
			List<Correspond__c> correspondList = selectCorrespondList('対応終了_取引先無');
			// 対応が作成され、LINE会員と取引先が新規の対応に紐づく
			checkClickCorrespond(correspondList,beforeCorrespondList,'お客様登録と紐づけボタン押下：'+'対応終了_取引先無');
		}
	}
	// ステータス、LINE会員：契約完了
	@istest
	static void linkDataRegisterAccountTest03(){
		// 一般ユーザで実行
		User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];

		// LINE会員
		LineMember__c lineMember = [SELECT Id FROM LineMember__c WHERE Name = '対応契約完了_取引先無'];

		System.runAs(ippanUser) {

			List<Correspond__c> beforeCorrespondList = selectCorrespondList('対応契約完了_取引先無');
			Test.startTest();
			// 初期表示
			PageReference pageRef = Page.GL101003View;
			pageRef.getParameters().put('lineMemberId', lineMember.Id);
			pageRef.getParameters().put('correspondId', beforeCorrespondList[0].Id);
			Test.setCurrentPage(pageRef);
			GL101003Controller testController = new GL101003Controller();

			// お客様登録と紐づけボタン押下
			testController.linkDataRegisterAccount();

			Test.stopTest();

			// 実施後
			// 取引先の確認（assert）
			List<Account> account = [SELECT Id FROM Account WHERE Name = '対応契約完了_取引先無'];
			System.assertEquals(account.size() , 1, '');
			List<Correspond__c> correspondList = selectCorrespondList('対応契約完了_取引先無');
			// 対応が作成され、LINE会員と取引先が新規の対応に紐づく
			checkClickCorrespond(correspondList,beforeCorrespondList,'お客様登録と紐づけボタン押下：'+'対応契約完了_取引先無');
		}
	}
	// ステータス、LINE会員：反響集約
	@istest
	static void linkDataRegisterAccountTest04(){
		// 一般ユーザで実行
		User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];

		// LINE会員
		LineMember__c lineMember = [SELECT Id FROM LineMember__c WHERE Name = '対応反響集約_取引先無'];

		System.runAs(ippanUser) {

			List<Correspond__c> beforeCorrespondList = selectCorrespondList('対応反響集約_取引先無');
			Test.startTest();
			// 初期表示
			PageReference pageRef = Page.GL101003View;
			pageRef.getParameters().put('lineMemberId', lineMember.Id);
			pageRef.getParameters().put('correspondId', beforeCorrespondList[0].Id);
			Test.setCurrentPage(pageRef);
			GL101003Controller testController = new GL101003Controller();

			// お客様登録と紐づけボタン押下
			testController.linkDataRegisterAccount();

			Test.stopTest();

			// 実施後
			// 取引先の確認（assert）
			List<Account> account = [SELECT Id FROM Account WHERE Name = '対応反響集約_取引先無'];
			System.assertEquals(account.size() , 1, '');
			List<Correspond__c> correspondList = selectCorrespondList('対応反響集約_取引先無');
			// 対応が作成され、LINE会員と取引先が新規の対応に紐づく
			checkClickCorrespond(correspondList,beforeCorrespondList,'お客様登録と紐づけボタン押下：'+'対応反響集約_取引先無');
		}
	}

	/**
	* お客様登録と紐づけボタン押下
	*     遷移元のパラメータの対応．ステータス：反響集約、終了、契約完了以外の場合
	*     対応が作成されず、取引先が新規の対応に紐づく
	*/
	// ステータス、LINE会員：未対応
	@istest
	static void linkDataRegisterAccountTest05(){
		// 一般ユーザで実行
		User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];

		// LINE会員
		LineMember__c lineMember = [SELECT Id FROM LineMember__c WHERE Name = '対応未対応_取引先無'];

		System.runAs(ippanUser) {

			List<Correspond__c> beforeCorrespondList = selectCorrespondList('対応未対応_取引先無');
			Test.startTest();
			// 初期表示
			PageReference pageRef = Page.GL101003View;
			pageRef.getParameters().put('lineMemberId', lineMember.Id);
			pageRef.getParameters().put('correspondId', beforeCorrespondList[0].Id);
			Test.setCurrentPage(pageRef);
			GL101003Controller testController = new GL101003Controller();

			// お客様登録と紐づけボタン押下
			testController.linkDataRegisterAccount();

			Test.stopTest();

			// 実施後
			// 取引先の確認（assert）
			List<Account> account = [SELECT Id FROM Account WHERE Name = '対応未対応_取引先無'];
			System.assertEquals(account.size() , 1, '');
			List<Correspond__c> correspondList = selectCorrespondList('対応未対応_取引先無');
			// 対応が作成されず、取引先が新規の対応に紐づく
			checkDataMatchCorrespondValid(correspondList,beforeCorrespondList,'お客様登録と紐づけボタン押下：'+'対応未対応_取引先無');
		}
	}
	// ステータス、LINE会員：追客中
	@istest
	static void linkDataRegisterAccountTest06(){
		// 一般ユーザで実行
		User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];

		// LINE会員
		LineMember__c lineMember = [SELECT Id FROM LineMember__c WHERE Name = '対応追客中_取引先無'];

		System.runAs(ippanUser) {

			List<Correspond__c> beforeCorrespondList = selectCorrespondList('対応追客中_取引先無');
			Test.startTest();
			// 初期表示
			PageReference pageRef = Page.GL101003View;
			pageRef.getParameters().put('lineMemberId', lineMember.Id);
			pageRef.getParameters().put('correspondId', beforeCorrespondList[0].Id);
			Test.setCurrentPage(pageRef);
			GL101003Controller testController = new GL101003Controller();

			// お客様登録と紐づけボタン押下
			testController.linkDataRegisterAccount();

			Test.stopTest();

			// 実施後
			// 取引先の確認（assert）
			List<Account> account = [SELECT Id FROM Account WHERE Name = '対応追客中_取引先無'];
			System.assertEquals(account.size() , 1, '');
			List<Correspond__c> correspondList = selectCorrespondList('対応追客中_取引先無');
			// 対応が作成されず、取引先が新規の対応に紐づく
			checkDataMatchCorrespondValid(correspondList,beforeCorrespondList,'お客様登録と紐づけボタン押下：'+'対応追客中_取引先無');
		}
	}

	/**
	 * マッチング候補者一覧の決定ボタン押下時
	 *     遷移元のパラメータの対応．ステータス：反響集約、終了、契約完了の場合
	 *     対応が作成され、LINE会員と取引先が新規の対応に紐づく
	 */
	// ステータス、LINE会員：終了
	@isTest
	static void linkDataMatchTest02() {
		// 一般ユーザで実行
		User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];

		// LINE会員
		LineMember__c lineMember = [SELECT Id FROM LineMember__c WHERE Name = '対応終了_LINE会員候補用'];

		System.runAs(ippanUser) {
			List<Correspond__c> beforeCorrespondList = selectCorrespondList('対応終了_LINE会員候補用');
			Test.startTest();
			// 初期表示
			PageReference pageRef = Page.GL101003View;
			pageRef.getParameters().put('lineMemberId', lineMember.Id);
			pageRef.getParameters().put('correspondId', beforeCorrespondList[0].Id);
			Test.setCurrentPage(pageRef);
			GL101003Controller testController = new GL101003Controller();

			// 決定ボタン押下処理
			testController.screenLineUserLinking.detailIndex = 0;
			Integer count = 0 ;
			for (GL101003Controller.AccountDetail AccountDetail : testController.screenLineUserLinking.matchCandidateList) {
				if ('対応終了_LINE会員候補用' == AccountDetail.accountName) {
					testController.screenLineUserLinking.detailIndex = count;
					break;
				}
				count += 1;
			}
			
			testController.linkDataMatch();

			Test.stopTest();

			// 実施後
			List<Correspond__c> correspondList = selectCorrespondList('対応終了_LINE会員候補用');
			// 対応が作成され、LINE会員と取引先が新規の対応に紐づく
			checkClickCorrespond(correspondList,beforeCorrespondList,'マッチング候補者一覧の決定ボタン押下時：'+'対応追客中_取引先無');
		}
	}
	// ステータス、LINE会員：契約完了
	@isTest
	static void linkDataMatchTest03() {
		// 一般ユーザで実行
		User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];

		// LINE会員
		LineMember__c lineMember = [SELECT Id FROM LineMember__c WHERE Name = '対応契約完了_LINE会員候補用'];

		System.runAs(ippanUser) {
			List<Correspond__c> beforeCorrespondList = selectCorrespondList('対応契約完了_LINE会員候補用');
			Test.startTest();
			// 初期表示
			PageReference pageRef = Page.GL101003View;
			pageRef.getParameters().put('lineMemberId', lineMember.Id);
			pageRef.getParameters().put('correspondId', beforeCorrespondList[0].Id);
			Test.setCurrentPage(pageRef);
			GL101003Controller testController = new GL101003Controller();

			// 決定ボタン押下処理
			testController.screenLineUserLinking.detailIndex = 0;
			Integer count = 0 ;
			for (GL101003Controller.AccountDetail AccountDetail : testController.screenLineUserLinking.matchCandidateList) {
				if ('対応契約完了_LINE会員候補用' == AccountDetail.accountName) {
					testController.screenLineUserLinking.detailIndex = count;
					break;
				}
				count += 1;
			}
			testController.linkDataMatch();

			Test.stopTest();

			// 実施後
			List<Correspond__c> correspondList = selectCorrespondList('対応契約完了_LINE会員候補用');
			// 対応が作成され、LINE会員と取引先が新規の対応に紐づく
			checkClickCorrespond(correspondList,beforeCorrespondList,'マッチング候補者一覧の決定ボタン押下時：'+'対応契約完了_LINE会員候補用');
		}
	}
	// ステータス、LINE会員：反響集約
	@isTest
	static void linkDataMatchTest04() {
		// 一般ユーザで実行
		User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];

		// LINE会員
		LineMember__c lineMember = [SELECT Id FROM LineMember__c WHERE Name = '対応反響集約_LINE会員候補用'];

		System.runAs(ippanUser) {
			List<Correspond__c> beforeCorrespondList = selectCorrespondList('対応反響集約_LINE会員候補用');
			Test.startTest();
			// 初期表示
			PageReference pageRef = Page.GL101003View;
			pageRef.getParameters().put('lineMemberId', lineMember.Id);
			pageRef.getParameters().put('correspondId', beforeCorrespondList[0].Id);
			Test.setCurrentPage(pageRef);
			GL101003Controller testController = new GL101003Controller();

			// 決定ボタン押下処理
			testController.screenLineUserLinking.detailIndex = 0;
			Integer count = 0 ;
			for (GL101003Controller.AccountDetail AccountDetail : testController.screenLineUserLinking.matchCandidateList) {
				if ('対応反響集約_LINE会員候補用' == AccountDetail.accountName) {
					testController.screenLineUserLinking.detailIndex = count;
					break;
				}
				count += 1;
			}
			testController.linkDataMatch();

			Test.stopTest();

			// 実施後
			List<Correspond__c> correspondList = selectCorrespondList('対応反響集約_LINE会員候補用');
			// 対応が作成され、LINE会員と取引先が新規の対応に紐づく
			checkClickCorrespond(correspondList,beforeCorrespondList,'マッチング候補者一覧の決定ボタン押下時：'+'対応反響集約_LINE会員候補用');
		}
	}

	/**
	 * マッチング候補者一覧の決定ボタン押下時
	 *     遷移元のパラメータの対応．ステータス：反響集約、終了、契約完了以外の場合
	 *     対応が作成されず、LINE会員が取引先の対応に紐づく
	 */
	// ステータス：未対応
	@isTest
	static void linkDataMatchTest05() {
		// 一般ユーザで実行
		User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];

		// LINE会員
		LineMember__c lineMember = [SELECT Id FROM LineMember__c WHERE Name = '対応未対応_LINE会員候補用'];

		System.runAs(ippanUser) {
			List<Correspond__c> beforeCorrespondList = selectCorrespondList('対応未対応_LINE会員候補用');
			Test.startTest();
			// 初期表示
			PageReference pageRef = Page.GL101003View;
			pageRef.getParameters().put('lineMemberId', lineMember.Id);
			pageRef.getParameters().put('correspondId', beforeCorrespondList[0].Id);
			Test.setCurrentPage(pageRef);
			GL101003Controller testController = new GL101003Controller();

			// 決定ボタン押下処理
			testController.screenLineUserLinking.detailIndex = 0;
			testController.linkDataMatch();

			Test.stopTest();

			// 実施後
			List<Correspond__c> correspondList = selectCorrespondList('対応未対応_LINE会員候補用');
			// 対応が作成されず、LINE会員が取引先の対応に紐づく
			checkDataMatchCorrespondValid(correspondList,beforeCorrespondList,'マッチング候補者一覧の決定ボタン押下時：'+'対応未対応_LINE会員候補用');
		}
	}
	// ステータス：追客中
	@isTest
	static void linkDataMatchTest06() {
		// 一般ユーザで実行
		User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];

		// LINE会員
		LineMember__c lineMember = [SELECT Id FROM LineMember__c WHERE Name = '対応追客中_LINE会員候補用'];

		System.runAs(ippanUser) {
			List<Correspond__c> beforeCorrespondList = selectCorrespondList('対応追客中_LINE会員候補用');
			Test.startTest();
			// 初期表示
			PageReference pageRef = Page.GL101003View;
			pageRef.getParameters().put('lineMemberId', lineMember.Id);
			pageRef.getParameters().put('correspondId', beforeCorrespondList[0].Id);
			Test.setCurrentPage(pageRef);
			GL101003Controller testController = new GL101003Controller();

			// 決定ボタン押下処理
			testController.screenLineUserLinking.detailIndex = 0;
			testController.linkDataMatch();

			Test.stopTest();

			// 実施後
			List<Correspond__c> correspondList = selectCorrespondList('対応追客中_LINE会員候補用');
			// 対応が作成されず、LINE会員が取引先の対応に紐づく
			checkDataMatchCorrespondValid(correspondList,beforeCorrespondList,'マッチング候補者一覧の決定ボタン押下時：'+'対応追客中_LINE会員候補用');
		}
	}

	/**
	 * 検索結果の決定ボタン押下時
	 *     遷移元のパラメータの対応．ステータス：反響集約、終了、契約完了の場合
	 *     
	 */
	// ステータス、LINE会員：終了、取引先：追客中
	@isTest
	static void linkDataSearchTest02() {
		// 一般ユーザで実行
		User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];

		// LINE会員
		LineMember__c lineMember = [SELECT Id FROM LineMember__c WHERE Name = '対応終了_取引先無'];

		System.runAs(ippanUser) {
			List<Correspond__c> beforeCorrespondList = selectCorrespondList('対応終了_取引先無');
			Test.startTest();
			// 初期表示
			PageReference pageRef = Page.GL101003View;
			pageRef.getParameters().put('lineMemberId', lineMember.Id);
			pageRef.getParameters().put('correspondId', beforeCorrespondList[0].Id);
			Test.setCurrentPage(pageRef);

			// 検索処理
			GL101003Controller testController = new GL101003Controller();
			testController.screenLineUserLinking.condAccountName = '対応追客中_取引先';
            testController.searchResultDetailSet();

			// 決定ボタン押下処理
			testController.screenLineUserLinking.detailIndex = 0;
			testController.linkDataSearch();

			Test.stopTest();

			// 実施後
			List<Correspond__c> correspondList = selectCorrespondList('対応終了_取引先無');
			// 対応が作成されず、LINE会員が取引先の対応に紐づく
			checkDataSearchCorrespondValid(correspondList,beforeCorrespondList,'検索結果の決定ボタン押下時：'+'対応終了_取引先無',true);
		}
	}
	// ステータス、LINE会員：終了、取引先：終了
	@isTest
	static void linkDataSearchTest03() {
		// 一般ユーザで実行
		User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];

		// LINE会員
		LineMember__c lineMember = [SELECT Id FROM LineMember__c WHERE Name = '対応終了_取引先無'];

		System.runAs(ippanUser) {
			List<Correspond__c> beforeCorrespondList = selectCorrespondList('対応終了_取引先無');
			Test.startTest();
			// 初期表示
			PageReference pageRef = Page.GL101003View;
			pageRef.getParameters().put('lineMemberId', lineMember.Id);
			pageRef.getParameters().put('correspondId', beforeCorrespondList[0].Id);
			Test.setCurrentPage(pageRef);

			// 検索処理
			GL101003Controller testController = new GL101003Controller();
			testController.screenLineUserLinking.condAccountName = '対応終了_取引先';
            testController.searchResultDetailSet();

			// 決定ボタン押下処理
			testController.screenLineUserLinking.detailIndex = 0;
			testController.linkDataSearch();

			Test.stopTest();

			// 実施後
			List<Correspond__c> correspondList = selectCorrespondList('対応終了_取引先無');
			// 対応が作成され、LINE会員と取引先が新たな対応に紐づく
			checkDataSearchCorrespondValid(correspondList,beforeCorrespondList,'検索結果の決定ボタン押下時：'+'対応終了_取引先無');

			// 取引先とLINE会員の対応の件数を確認
			List<Correspond__c> allCorrespondList = [
				SELECT Id 
				FROM Correspond__c
				WHERE LineMember__r.Name = '対応終了_取引先無'
				OR    AccountId__r.Name = '対応終了_取引先'
			];
			System.assertEquals(allCorrespondList.size(),3, '検索結果の決定ボタン押下時：取引先とLINE会員の対応の件数');
		}
	}

	/**
	 * 検索結果の決定ボタン押下時
	 *     遷移元のパラメータの対応．ステータス：反響集約、終了、契約完了以外の場合
	 *     対応が作成されず、LINEの対応に取引先が紐づく
	 */
	// ステータス、LINE会員：追客中、取引先：追客中
	@isTest
	static void linkDataSearchTest05() {
		// 一般ユーザで実行
		User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];

		// LINE会員
		LineMember__c lineMember = [SELECT Id FROM LineMember__c WHERE Name = '対応追客中_取引先無'];

		System.runAs(ippanUser) {
			List<Correspond__c> beforeCorrespondList = selectCorrespondList('対応追客中_取引先無');
			Test.startTest();
			// 初期表示
			PageReference pageRef = Page.GL101003View;
			pageRef.getParameters().put('lineMemberId', lineMember.Id);
			pageRef.getParameters().put('correspondId', beforeCorrespondList[0].Id);
			Test.setCurrentPage(pageRef);

			// 検索処理
			GL101003Controller testController = new GL101003Controller();
			testController.screenLineUserLinking.condAccountName = '対応追客中_取引先';
            testController.searchResultDetailSet();

			// 決定ボタン押下処理
			testController.screenLineUserLinking.detailIndex = 0;
			testController.linkDataSearch();

			Test.stopTest();

			// 実施後
			List<Correspond__c> correspondList = selectCorrespondList('対応追客中_取引先無');
			// 対応が作成されず、LINEの対応に取引先が紐づく（複数紐づき）
			checkDataSearchCorrespondValid2(correspondList,beforeCorrespondList,'検索結果の決定ボタン押下時：'+'対応追客中_取引先無',true);
		}
	}
	// ステータス、LINE会員：追客中、取引先：対応無
	@isTest
	static void linkDataSearchTest06() {
		// 一般ユーザで実行
		User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];

		// LINE会員
		LineMember__c lineMember = [SELECT Id FROM LineMember__c WHERE Name = '対応追客中_取引先無'];

		System.runAs(ippanUser) {
			List<Correspond__c> beforeCorrespondList = selectCorrespondList('対応追客中_取引先無');
			Test.startTest();
			// 初期表示
			PageReference pageRef = Page.GL101003View;
			pageRef.getParameters().put('lineMemberId', lineMember.Id);
			pageRef.getParameters().put('correspondId', beforeCorrespondList[0].Id);
			Test.setCurrentPage(pageRef);

			// 検索処理
			GL101003Controller testController = new GL101003Controller();
			testController.screenLineUserLinking.condAccountName = '対応無_取引先';
            testController.searchResultDetailSet();

			// 決定ボタン押下処理
			testController.screenLineUserLinking.detailIndex = 0;
			testController.linkDataSearch();

			Test.stopTest();

			// 実施後
			List<Correspond__c> correspondList = selectCorrespondList('対応追客中_取引先無');
			// 対応が作成されず、LINEの対応に取引先が紐づく
			checkDataSearchCorrespondValid2(correspondList,beforeCorrespondList,'検索結果の決定ボタン押下時：'+'対応追客中_取引先無');
		}
	}
	// ステータス、LINE会員：追客中、取引先：終了
	@isTest
	static void linkDataSearchTest07() {
		// 一般ユーザで実行
		User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];

		// LINE会員
		LineMember__c lineMember = [SELECT Id FROM LineMember__c WHERE Name = '対応追客中_取引先無'];

		System.runAs(ippanUser) {
			List<Correspond__c> beforeCorrespondList = selectCorrespondList('対応追客中_取引先無');
			Test.startTest();
			// 初期表示
			PageReference pageRef = Page.GL101003View;
			pageRef.getParameters().put('lineMemberId', lineMember.Id);
			pageRef.getParameters().put('correspondId', beforeCorrespondList[0].Id);
			Test.setCurrentPage(pageRef);

			// 検索処理
			GL101003Controller testController = new GL101003Controller();
			testController.screenLineUserLinking.condAccountName = '対応終了_取引先';
			testController.searchResultDetailSet();

			// 決定ボタン押下処理
			testController.screenLineUserLinking.detailIndex = 0;
			testController.linkDataSearch();

			Test.stopTest();

			// 実施後
			List<Correspond__c> correspondList = selectCorrespondList('対応追客中_取引先無');
			// ※同じ件数でエラーcorrespondList,beforeCorrespondList
			// 対応が作成されず、LINEの対応に取引先が紐づく
			checkDataSearchCorrespondValid2(correspondList,beforeCorrespondList,'検索結果の決定ボタン押下時：'+'対応追客中_取引先無',true);
		}
	}
	
//-----------------------------------------------------------------以下privateメソッド-----------------------------------------------------------------
	/**
	 * 対応チェック（終了、契約完了、反響累計ステータス）
	 * @param Correspond__c clickCorrespond  メッセージ送信後の対応
	 * @param Correspond__c beforeCorrespond メッセージ送信前の対応
	 * @param String equalsMessage エラー時のメッセージ（対象処理名）
	 */
	private static void checkClickCorrespond(List<Correspond__c> clickCorrespondList,List<Correspond__c> beforeCorrespondList,String equalsMessage){
		// 件数
		System.assertNotEquals(clickCorrespondList.size(),beforeCorrespondList.size(),equalsMessage +'：件数');
		System.assertEquals(clickCorrespondList.size(),2, equalsMessage +'：加算='+clickCorrespondList.size());
		for (Correspond__c clickCorrespond : clickCorrespondList) {
			Boolean isNewData = true;
			for (Correspond__c beforeCorrespond : beforeCorrespondList) {
				if(beforeCorrespond.Id == clickCorrespond.Id){
					// 元の対応のチェック
					System.assertNotEquals(clickCorrespond.FirstLineAddFlg__c,beforeCorrespond.FirstLineAddFlg__c,equalsMessage +'：初回LINE追加フラグ');
					System.assertEquals(clickCorrespond.Status__c,beforeCorrespond.Status__c, equalsMessage +'：対応．ステータス：変更なし');	// ステータス
					System.assertEquals(clickCorrespond.IsEchoNotCalculation__c,false, equalsMessage +'：反響数非計算フラグ');
					// System.assertEquals(clickCorrespond.IsEchoNotCalculation__c,beforeCorrespond.IsEchoNotCalculation__c, equalsMessage +'：反響数非計算フラグ');
					isNewData = false;
				}
			}

			if (isNewData) {
				// 新規追加データチェック
				System.assertEquals(clickCorrespond.Status__c,CommonConst.CORRESPOND_STATUS_PURSUIT, equalsMessage +'：対応．ステータス：追客中変更');	// ステータス
				System.assertEquals(clickCorrespond.LineMember__c,beforeCorrespondList[0].LineMember__c, equalsMessage +'：LINE会員');
				System.assertEquals(clickCorrespond.FirstLineAddFlg__c,true, equalsMessage +'：初回LINE追加フラグ');
				System.assertNotEquals(clickCorrespond.AccountId__c,null, equalsMessage +'：取引先設定有');
			}
			
		}
	}

	/**
	 * 決定ボタン押下（マッチング候補者一覧）
	 * @param Correspond__c clickCorrespond  メッセージ送信後の対応
	 * @param Correspond__c beforeCorrespond メッセージ送信前の対応
	 * @param String equalsMessage エラー時のメッセージ（対象処理名）
	 */
	private static void checkDataMatchCorrespondValid(List<Correspond__c> clickCorrespondList,List<Correspond__c> beforeCorrespondList,String equalsMessage){
		// 件数
		System.assertEquals(clickCorrespondList.size(),beforeCorrespondList.size(), equalsMessage +'：件数');
		for (Correspond__c clickCorrespond : clickCorrespondList) {
			Boolean isNewData = true;
			for (Correspond__c beforeCorrespond : beforeCorrespondList) {
				if(beforeCorrespond.Id == clickCorrespond.Id){
					// 元の対応のチェック
					System.assertEquals(clickCorrespond.FirstLineAddFlg__c,beforeCorrespond.FirstLineAddFlg__c, equalsMessage +'：初回LINE追加フラグ');
					System.assertEquals(clickCorrespond.IsBrowseFlg__c,beforeCorrespond.IsBrowseFlg__c, equalsMessage +'：閲覧フラグ');
					System.assertEquals(clickCorrespond.ListViewDate__c,beforeCorrespond.ListViewDate__c, equalsMessage +'：一覧表示日時');
					System.assertEquals(clickCorrespond.EventDateTime__c,beforeCorrespond.EventDateTime__c,  equalsMessage +'：イベント時刻');
					System.assertEquals(clickCorrespond.LineSmsSendDate__c,beforeCorrespond.LineSmsSendDate__c, equalsMessage +'：LINE・SMS送信日時');

					System.assertEquals(clickCorrespond.Status__c,beforeCorrespond.Status__c, equalsMessage +'：ステータス変更無');	// ステータスの確認

					// 取引先が設定されている
					System.assertNotEquals(clickCorrespond.AccountId__c,beforeCorrespond.AccountId__c, equalsMessage +'：取引先の設定');
					System.assertNotEquals(clickCorrespond.AccountId__c,null, equalsMessage +'：取引先の設定');

					isNewData = false;
				}
			}

			if (isNewData) {
				// 新規追加データがあればエラー
				System.assertEquals(clickCorrespond.id,null,  equalsMessage +'：対応．ステータス：追客中変更');	// ステータス	
			}
			
		}
	}
	/**
	 * 検索結果の決定ボタン押下時
	 * @param Correspond__c clickCorrespond  検索結果の決定ボタン後の対応
	 * @param Correspond__c beforeCorrespond 検索結果の決定ボタン前の対応
	 * @param String equalsMessage エラー時のメッセージ（対象処理名）
	 * @param Boolean isInsertCorrespondError 対応の新規登録チェック（True：エラー判定、False：チェックする）
	 */
	private static void checkDataSearchCorrespondValid(List<Correspond__c> clickCorrespondList,List<Correspond__c> beforeCorrespondList,String equalsMessage){
		checkDataSearchCorrespondValid(clickCorrespondList,beforeCorrespondList,equalsMessage,false);
	}
	private static void checkDataSearchCorrespondValid(List<Correspond__c> clickCorrespondList,List<Correspond__c> beforeCorrespondList,String equalsMessage,Boolean isInsertCorrespondError){
		// 件数
		System.assertNotEquals(clickCorrespondList.size(),beforeCorrespondList.size(), equalsMessage +'：件数');
		System.assertEquals(clickCorrespondList.size(),2, equalsMessage +'：加算='+clickCorrespondList.size());
		for (Correspond__c clickCorrespond : clickCorrespondList) {
			Boolean isNewData = true;
			for (Correspond__c beforeCorrespond : beforeCorrespondList) {
				if(beforeCorrespond.Id == clickCorrespond.Id){
					// 元の対応のチェック
					System.assertNotEquals(clickCorrespond.FirstLineAddFlg__c,beforeCorrespond.FirstLineAddFlg__c, equalsMessage +'：初回LINE追加フラグ');
					System.assertEquals(clickCorrespond.IsBrowseFlg__c,beforeCorrespond.IsBrowseFlg__c, equalsMessage +'：閲覧フラグ');
					System.assertEquals(clickCorrespond.ListViewDate__c,beforeCorrespond.ListViewDate__c, equalsMessage +'：一覧表示日時');
					System.assertEquals(clickCorrespond.EventDateTime__c,beforeCorrespond.EventDateTime__c,  equalsMessage +'：イベント時刻');
					System.assertEquals(clickCorrespond.LineSmsSendDate__c,beforeCorrespond.LineSmsSendDate__c, equalsMessage +'：LINE・SMS送信日時');
					System.assertEquals(clickCorrespond.Status__c,beforeCorrespond.Status__c, equalsMessage +'：ステータス変更無');// ステータスの確認

					isNewData = false;
				}
			}
			
			if (isNewData && !isInsertCorrespondError) {
				// 新規追加データチェック
				System.assertEquals(clickCorrespond.Status__c,CommonConst.CORRESPOND_STATUS_PURSUIT, equalsMessage +'：対応．ステータス：追客中変更');	// ステータス
				System.assertNotEquals(clickCorrespond.LineMember__c,null,  equalsMessage +'：LINE会員ID');
				System.assertEquals(clickCorrespond.FirstLineAddFlg__c,true, equalsMessage +'：初回LINE追加フラグ');
				System.assertNotEquals(clickCorrespond.ListViewDate__c,CommonConst.LAST_DATE,  equalsMessage +'：一覧表示日時');
			}else if(isInsertCorrespondError){
				// 新規登録時エラー
				System.assertEquals(isInsertCorrespondError,true, equalsMessage +'：対応新規登録されない');
			}
			
			
		}
	}
	/**
	 * 検索結果の決定ボタン押下時（遷移元のパラメータの対応．ステータス：反響集約、終了、契約完了以外の場合）
	 * @param Correspond__c clickCorrespond  メッセージ送信後の対応
	 * @param Correspond__c beforeCorrespond メッセージ送信前の対応
	 * @param String equalsMessage エラー時のメッセージ（対象処理名）
	 * @param Boolean isInsertCorrespondError 対応の新規登録チェック（True：エラー判定、False：チェックする）
	 */
	private static void checkDataSearchCorrespondValid2(List<Correspond__c> clickCorrespondList,List<Correspond__c> beforeCorrespondList,String equalsMessage){
		checkDataSearchCorrespondValid2(clickCorrespondList,beforeCorrespondList,equalsMessage,false);
	}
	private static void checkDataSearchCorrespondValid2(List<Correspond__c> clickCorrespondList,List<Correspond__c> beforeCorrespondList,String equalsMessage,Boolean isInsertCorrespondError){
		// 件数
		System.assertEquals(clickCorrespondList.size(),beforeCorrespondList.size(), equalsMessage +'：件数加算無');
		for (Correspond__c clickCorrespond : clickCorrespondList) {
			Boolean isNewData = true;
			for (Correspond__c beforeCorrespond : beforeCorrespondList) {
				if(beforeCorrespond.Id == clickCorrespond.Id){
					// 元の対応のチェック
					System.assertEquals(clickCorrespond.FirstLineAddFlg__c,beforeCorrespond.FirstLineAddFlg__c, equalsMessage +'：初回LINE追加フラグ');
					System.assertEquals(clickCorrespond.IsBrowseFlg__c,beforeCorrespond.IsBrowseFlg__c, equalsMessage +'：閲覧フラグ');
					System.assertEquals(clickCorrespond.ListViewDate__c,beforeCorrespond.ListViewDate__c, equalsMessage +'：一覧表示日時');
					System.assertEquals(clickCorrespond.EventDateTime__c,beforeCorrespond.EventDateTime__c,  equalsMessage +'：イベント時刻');
					System.assertEquals(clickCorrespond.LineSmsSendDate__c,beforeCorrespond.LineSmsSendDate__c, equalsMessage +'：LINE・SMS送信日時');
					System.assertEquals(clickCorrespond.Status__c,beforeCorrespond.Status__c, equalsMessage +'：ステータス変更無');	// ステータスの確認

					isNewData = false;
				}
			}

			if (isNewData && !isInsertCorrespondError) {
				// 新規追加データチェック
				System.assertEquals(clickCorrespond.Status__c,CommonConst.CORRESPOND_STATUS_PURSUIT, equalsMessage +'：対応．ステータス：追客中変更');	// ステータス
				System.assertNotEquals(clickCorrespond.LineMember__c,null,  equalsMessage +'：LINE会員ID');
				System.assertEquals(clickCorrespond.FirstLineAddFlg__c,true, equalsMessage +'：初回LINE追加フラグ');
				System.assertEquals(clickCorrespond.ListViewDate__c,CommonConst.LAST_DATE,  equalsMessage +'： // 一覧表示日時');
			}else  if(isInsertCorrespondError){
				// 新規登録時エラー
				System.assertEquals(isInsertCorrespondError,true, equalsMessage +'：対応新規登録されない');
			}
			
			
		}
	}
	
	/**
	 * LINE会員の対応取得（複数有）
	 * @param String condName LINE会員名
	 * @return Correspond__c LINE会員の対応
	 */
	private static List<Correspond__c> selectCorrespondList(String condName) {

		List<Correspond__c> correspondList = [
			SELECT Id ,AccountId__c,IsEchoNotCalculation__c	,EventDateTime__c,FirstInquiryMeans__c,IsBrowseFlg__c,ListViewDate__c,PortalSiteUrl__c,PortalSite__c,ReceiveMailDatePortal__c,status__c,LineFriendAddDate__c,LineMember__c,LineMember__r.Name,FirstLineAddFlg__c,LineSmsSendDate__c
			FROM Correspond__c
			WHERE LineMember__r.Name = :condName
		];

		return correspondList;
	}
	//▲ 2022.04.20 No0768 対応で追加
}