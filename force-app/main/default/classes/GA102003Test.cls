@ isTest

private class GA102003Test {
    //テストに使用するレコードを作成する。
    @testSetup static void Setting() {

		// ▼2021.10.08 No.307 対応で追加
		//標準プロファイルを取得
        Id profileId = [SELECT Id FROM Profile WHERE Name = '一般ユーザ'].Id;

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            //ユーザの登録
            User testUser = new User(LastName = 'ippanUser'                     //姓
                                    ,Alias =  'alias'                           //別名
                                    ,Email = 'ippanUser@test.com'               //メール
                                    ,UserName = 'ippanUserGA102003@test.com'  	//ユーザ名
                                    ,CommunityNickname ='テストニックネーム'     //ニックネーム
                                    ,EmailEncodingKey = 'ISO-2022-JP'           //メールの文字コード
                                    ,TimeZoneSidKey = 'Asia/Tokyo'              //タイムゾーン
                                    ,LocaleSidKey = 'ja_JP'                     //地域
                                    ,LanguageLocaleKey= 'ja'                    //言語
                                    ,ProfileId = profileId                      //プロファイルID
            );
            insert testUser;     
        }

		// 路線
        TrainRoute__c testTrainRoute1 = new TrainRoute__c(
            Name = 'テスト路線１'
        );
        TrainRoute__c testTrainRoute2 = new TrainRoute__c(
            Name = 'テスト路線２'
        );
        TrainRoute__c testTrainRoute3 = new TrainRoute__c(
            Name = 'テスト路線３'
        );
        List<TrainRoute__c> testTrainRoute = new List<TrainRoute__c> {
            testTrainRoute1
            ,testTrainRoute2
            ,testTrainRoute3
        };
        insert testTrainRoute;

        // 駅
        Station__c testStation1 = new Station__c(
            Name = 'テスト駅１'
            ,TrainRoute__c = testTrainRoute1.Id
        );
        Station__c testStation2 = new Station__c(
            Name = 'テスト駅２'
            ,TrainRoute__c = testTrainRoute2.Id
        );
        Station__c testStation3 = new Station__c(
            Name = 'テスト駅３'
            ,TrainRoute__c = testTrainRoute3.Id
        );
        List<Station__c> testStation = new List<Station__c> {
            testStation1
            ,testStation2
            ,testStation3
        };
        insert testStation;

        // 希望路線
        DesiredTrainRoute__c testDesiredTrainRoute1 = new DesiredTrainRoute__c(
            TrainRoute__c	 = testTrainRoute[0].Id
        );
        DesiredTrainRoute__c testDesiredTrainRoute2 = new DesiredTrainRoute__c(
            TrainRoute__c	 = testTrainRoute[1].Id
        );
        DesiredTrainRoute__c testDesiredTrainRoute3 = new DesiredTrainRoute__c(
            TrainRoute__c	 = testTrainRoute[2].Id
        );
        List<DesiredTrainRoute__c> testDesiredTrainRoute = new List<DesiredTrainRoute__c> {
            testDesiredTrainRoute1
            ,testDesiredTrainRoute2
            ,testDesiredTrainRoute3
        };
        insert testDesiredTrainRoute;

        // 希望駅
        DesiredStation__c testDesiredTrainStation1 = new DesiredStation__c(
            Station__c	 = testStation[0].Id
            ,DesiredTrainRoute__c	 = testDesiredTrainRoute[0].Id
        );
        DesiredStation__c testDesiredTrainStation2 = new DesiredStation__c(
            Station__c	 = testStation[1].Id
            ,DesiredTrainRoute__c	 = testDesiredTrainRoute[1].Id
        );
        DesiredStation__c testDesiredTrainStation3 = new DesiredStation__c(
            Station__c	 = testStation[2].Id
            ,DesiredTrainRoute__c	 = testDesiredTrainRoute[2].Id
        );
        List<DesiredStation__c> testDesiredTrainStation = new List<DesiredStation__c> {
            testDesiredTrainStation1
            ,testDesiredTrainStation2
            ,testDesiredTrainStation3
        };
        insert testDesiredTrainStation;

		// ▼問合せ415で追加
        // 学校
        School__c testSchool1 = new School__c(
            Name = 'テスト学校1'
            ,City__c = '港区'
            ,Type__c = '中学校'
        );
        School__c testSchool2 = new School__c(
            Name = 'テスト学校2'
            ,City__c = '港区'
            ,Type__c = '小学校'
        );
        List<School__c> testSchool = new List<School__c> {
            testSchool1
            ,testSchool2
        };
        insert testSchool;

        // 希望学区
        DesiredSchoolArea__c testDesiredSchoolArea1 = new DesiredSchoolArea__c(
            SchoolArea__c	 = '港区'
        );
        DesiredSchoolArea__c testDesiredSchoolArea2 = new DesiredSchoolArea__c(
            SchoolArea__c	 = '瑞穂区'
        );
        List<DesiredSchoolArea__c> testDesiredSchoolArea = new List<DesiredSchoolArea__c> {
            testDesiredSchoolArea1
            ,testDesiredSchoolArea2
        };
        insert testDesiredSchoolArea;

        
        // 希望学校
        DesiredSchool__c testDesiredSchool1 = new DesiredSchool__c(
            School__c	 = testSchool[0].Id
            ,DesiredSchoolArea__c	 = testDesiredSchoolArea[0].Id
        );
        DesiredSchool__c testDesiredSchool2 = new DesiredSchool__c(
            School__c	 = testSchool[1].Id
            ,DesiredSchoolArea__c	 = testDesiredSchoolArea[1].Id
        );
        List<DesiredSchool__c> testDesiredSchool = new List<DesiredSchool__c> {
            testDesiredSchool1
            ,testDesiredSchool2
        };
        insert testDesiredSchool;
        // ▲問合せ415で追加
		// ▲2021.10.08 No.307 対応で追加

        //テスト用レコードを作成
        List<SObject> Records = new List<Account>();

        Account testTargetRecord = new Account(Name = '坂井 美里', 
                                               FirstName__c = '美里', LastName__c = '坂井', 
                                               NameKana__c = 'サカイミサト', 
                                               Phone = '025-200-1234', 
                                               Phone2__c = '080-2345-5678',
                                               Email__c = 'aaa@hora',
                                               Email2__c = 'bbb@hora', 
                                               state__c = '大阪府', 
                                               city__c = '大阪市', 
                                               street__c = '中央区安土町４－１', 
                                               EchoLineFlag__c = true,
                                               EchoLiveroFlag__c = true,
                                               RecordTypeId = commonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER));

        Account displayRecordOne = new Account(Name = '坂井 美里', 
                                               FirstName__c = '美里', LastName__c = '坂井', 
                                               NameKana__c = 'サカイミサト２', 
                                               Phone = '025-200-1234', 
                                               Email__c = 'aaa@hora',
                                               IsMergeUnnecessaryFlag__c = true, 
                                               RecordTypeId = commonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER));

        Account displayRecordPhoneError = new Account(Name = '坂井 美里', 
                                                      FirstName__c = '美里', LastName__c = '坂井', 
                                                      NameKana__c = 'サカイミサト３', 
                                                      Email__c = 'aaa@hora', 
                                                      Phone = '080-2345-6789', 
                                                      Phone2__c = '025-234-5678', 
                                                      Phone3__c = '090-1234-5678',
                                                      IsMergeUnnecessaryFlag__c = true, 
                                                      RecordTypeId = commonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER));

        Account forCoverageAccount      = new Account(Name = '坂井 美里',
                                                      FirstName__c = '美里', LastName__c = '坂井', 
                                                      NameKana__c = 'サカイミサト４', 
                                                      Email__c  = 'ccc@hora',
                                                      Email2__c = 'bbb@hora',
                                                      Email3__c = 'aaa@hora', 
                                                      Phone     = '080-2345-6789', 
                                                      Phone2__c = '111-1111-1111', 
                                                      Phone3__c = '222-2222-2222', 
                                                      RecordTypeId = commonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER));


        Records.add(testTargetRecord);
        Records.add(displayRecordOne);
        Records.add(displayRecordPhoneError);
        Records.add(forCoverageAccount);

        Insert Records;
        //追加要望 追加 Start
        //システム設定を作成（暗号化に使用）
        SystemConfig__c s = new SystemConfig__c(
            HerokuSecretAccessKey__c = 'zF2SKTCj5CnR5TEhXhCLYBKE9x6a6xHN',
            UseAuthority_Portal__c = true,
            ExampleIv__c = '4f63e8b490579073'
            );
        insert s;    

        //対応
        Correspond__c corr = new Correspond__c (AccountId__c = testTargetRecord.id);    
        insert corr;

        //紹介メール情報
        IntroductionMailInformation__c smi= new IntroductionMailInformation__c(Account__c = testTargetRecord.id, Correspond__c = corr.id);
        insert smi;
   
        //追加要望 追加 End

        // 建物
        Building__c buiding1 = new Building__c();
        Building__c buiding2 = new Building__c();
        List<Building__c> buidingList = new List<Building__c> {
            buiding1
            , buiding2
        };
        insert buidingList;

        // 空室予約物件
        VacancyReservationProperty__c vacancyReservationProp1 = new VacancyReservationProperty__c(
            Account__c = testTargetRecord.Id
            , Building__c = buiding1.Id
        );
        VacancyReservationProperty__c vacancyReservationProp2 = new VacancyReservationProperty__c(
			// ▼ 2022.2.3 LINE連携対応より、重複削除用の値に修正
            Account__c = displayRecordOne.Id    
			// ▲ 2022.2.3
            , Building__c = buiding1.Id 
        );        
        VacancyReservationProperty__c vacancyReservationProp3 = new VacancyReservationProperty__c(
            Account__c = displayRecordOne.Id    
            , Building__c = buiding2.Id
        );
        List<VacancyReservationProperty__c> vacancyReservationPropList = new List<VacancyReservationProperty__c>{
            vacancyReservationProp1
            , vacancyReservationProp2
            , vacancyReservationProp3
        };

        insert vacancyReservationPropList;

		// ▼ 2022.2.3 LINE連携対応より、追加
		// LINE会員
		LineMember__c lineMember1 = new LineMember__c(
			Account__c	= testTargetRecord.Id
			, LineId__c	= '1234567890'
		);
		LineMember__c lineMember2 = new LineMember__c(
			Account__c	= displayRecordOne.Id
			, LineId__c	= '2345678901'
		);
		List<LineMember__c> lineMemberList = new List<LineMember__c> {
			lineMember1
			, lineMember2
		};
		insert lineMemberList;

		// LINE会員候補
		LineMemberCandidate__c lineMemberCandidate1 = new LineMemberCandidate__c(
			Account__c	= testTargetRecord.Id
		);
		LineMemberCandidate__c lineMemberCandidate2 = new LineMemberCandidate__c(
			Account__c	= displayRecordOne.Id
		);
		List<LineMemberCandidate__c> lineMemberCandidateList = new List<LineMemberCandidate__c> {
			lineMemberCandidate1
			, lineMemberCandidate2
		};
		insert lineMemberCandidateList;
		// ▲ 2022.2.3
    }

    //初期表示テスト
    @isTest static void initializeTest() {
        Account testTargetRecord = [SELECT Id, 
                                    Name, 
                                    NameKana__c, 
                                    Phone, 
                                    Phone2__c, 
                                    Phone3__c, 
                                    Email__c, 
                                    Email2__c, 
                                    Email3__c, 
                                    Address__c
                                    FROM Account
                                    WHERE Name = '坂井 美里' AND NameKana__c = 'サカイミサト'
        ];

        Account displayRecordOne = [SELECT Id, 
                                    Name, 
                                    NameKana__c, 
                                    Phone, 
                                    Phone2__c, 
                                    Phone3__c, 
                                    Email__c, 
                                    Email2__c, 
                                    Email3__c, 
                                    Address__c
                                    FROM Account
                                    WHERE Name = '坂井 美里' AND NameKana__c != 'サカイミサト' AND Phone != '080-2345-6789'
        ];

        //パラメーター設定
        PageReference pageRef = Page.GA102003View;
        PageRef.getParameters().put('Id', testTargetRecord.Id);
        Test.setCurrentPage(pageRef);

        //コントローラー作成
        GA102003Controller testController = new GA102003Controller();

        //お客様名が設定されている？
        system.assertEquals(testTargetRecord.Name, testController.targetRecord.name);

        //お客様名(カナ)が設定されている？
        system.assertEquals(testTargetRecord.NameKana__c, testController.targetRecord.NameKana__c);

        //メールが設定されている？
        system.assertEquals(testTargetRecord.Email__c, testController.targetRecord.Email__c);

        //メール２が設定されている？
        system.assertEquals(testTargetRecord.Email2__c, testController.targetRecord.Email2__c);

        //メール３が設定されている？
        system.assertEquals(testTargetRecord.Email3__c, testController.targetRecord.Email3__c);

        //電話が設定されている？
        system.assertEquals(testTargetRecord.Phone, testController.targetRecord.Phone);

        //電話２が設定されている？
        system.assertEquals(testTargetRecord.Phone2__c, testController.targetRecord.Phone2__c);

        //電話３が設定されている？
        system.assertEquals(testTargetRecord.Phone3__c, testController.targetRecord.Phone3__c);

        //住所が設定されている？
        system.assertEquals(testTargetRecord.Address__c, testController.targetRecord.Address__c);


        //検索対象のお客様名が正しい？
        system.assertEquals(displayRecordOne.Name, testController.displayCandidateResult [0].candidateResult.Name);

        //検索対象のお客様名（カナ）が正しい？
        system.assertEquals(displayRecordOne.NameKana__c, testController.displayCandidateResult [0].candidateResult.NameKana__c);

        //検索対象のメールが正しい？
        system.assertEquals(displayRecordOne.Email__c, testController.displayCandidateResult [0].candidateResult.Email__c);

        //検索対象の電話番号が正しい？
        system.assertEquals(displayRecordOne.Phone, testController.displayCandidateResult [0].candidateResult.Phone);
    }

    //名寄せ不要ボタン
    @isTest static void mergeAccountsTest() {
        Account testTargetRecord = [SELECT Id, 
                                    Name, 
                                    NameKana__c, 
                                    Phone, 
                                    Phone2__c, 
                                    Phone3__c, 
                                    Email__c, 
                                    Email2__c, 
                                    Email3__c, 
                                    Address__c, 
                                    IsMergeUnnecessaryFlag__c
                                    FROM Account
                                    WHERE Name = '坂井 美里' AND NameKana__c = 'サカイミサト'
        ];


        //パラメーター設定
        PageReference pageRef = Page.GA102003View;
        PageRef.getParameters().put('Id', testTargetRecord.Id);
        Test.setCurrentPage(pageRef);

        //コントローラー作成
        GA102003Controller testController = new GA102003Controller();

        //名寄せ不要ボタン起動
        testController.margeCompleted();

        //名寄せ完了フラグ・名寄せ不要フラグ確認
        Account afterTestTargetRecord = [SELECT IsMergeUnnecessaryFlag__c, IsMergeCompletedFlag__c
                                         FROM Account
                                         WHERE Name = '坂井 美里' AND NameKana__c = 'サカイミサト'
        ];

        system.assertEquals(true, afterTestTargetRecord.IsMergeUnnecessaryFlag__c);
        system.assertEquals(true, afterTestTargetRecord.IsMergeCompletedFlag__c);



    }

    //マージ結果確認（他に名寄せ対象データ有り）
    @isTest static void mergeCompltedTest() {

        Account testTargetRecord = [SELECT Id, 
                                    Name, 
                                    NameKana__c, 
                                    Phone, 
                                    Phone2__c, 
                                    Phone3__c, 
                                    Email__c, 
                                    Email2__c, 
                                    Email3__c, 
                                    Address__c, 
                                    EchoLineFlag__c,
                                    EchoLiveroFlag__c,
                                    IsMergeCompletedFlag__c
                                    FROM Account
                                    WHERE Name = '坂井 美里' AND NameKana__c = 'サカイミサト'
        ];

        //パラメーター設定
        PageReference pageRef = Page.GA102003View;
        PageRef.getParameters().put('Id', testTargetRecord.Id);
        Test.setCurrentPage(pageRef);

        //コントローラー作成
        GA102003Controller testController = new GA102003Controller();

        //明細行を０に設定
        testController.mergeSelectedIndex = 0;

        //選択ボタンを起動
        testController.mergeAccounts();

        //名寄せ元データの削除確認
        List<Account> afterTestTargetRecord = [SELECT id
                                               FROM Account
                                               WHERE Name = '坂井 美里' AND NameKana__c = 'サカイミサト'
        ];
        system.assertEquals(true, afterTestTargetRecord.isEmpty());

        //名寄せ先データの名寄せ不要フラグ確認
        Account displayRecordOne = [SELECT id, IsMergeUnnecessaryFlag__c
                                    FROM Account
                                    WHERE Name = '坂井 美里' AND NameKana__c = 'サカイミサト２'
        ];
        system.assertEquals(false, displayRecordOne.IsMergeUnnecessaryFlag__c);

        //名寄せ一致したデータの名寄せ不要フラグ確認
        Account displayRecordPhoneError = [SELECT id, IsMergeUnnecessaryFlag__c
                                           FROM Account
                                           WHERE Name = '坂井 美里' AND NameKana__c = 'サカイミサト３'
        ];
        system.assertEquals(false, displayRecordPhoneError.IsMergeUnnecessaryFlag__c);

    }

   //マージ結果確認（他に名寄せ対象データなし）
   @isTest static void mergeCompltedTest2() {

        //不要データ削除
        List<Account> delList = [SELECT id, IsMergeUnnecessaryFlag__c
                                 FROM Account
                                 WHERE Name = '坂井 美里' AND NameKana__c IN ('サカイミサト３', 'サカイミサト４')
        ];
        delete delList;

        Account testTargetRecord = [SELECT Id, 
                                    Name, 
                                    NameKana__c, 
                                    Phone, 
                                    Phone2__c, 
                                    Phone3__c, 
                                    Email__c, 
                                    Email2__c, 
                                    Email3__c, 
                                    Address__c, 

                                    IsMergeCompletedFlag__c
                                    FROM Account
                                    WHERE Name = '坂井 美里' AND NameKana__c = 'サカイミサト'
        ];

        //パラメーター設定
        PageReference pageRef = Page.GA102003View;
        PageRef.getParameters().put('Id', testTargetRecord.Id);
        Test.setCurrentPage(pageRef);

        //コントローラー作成
        GA102003Controller testController = new GA102003Controller();

        //明細行を０に設定
        testController.mergeSelectedIndex = 0;

        //選択ボタンを起動
        testController.mergeAccounts();

        //名寄せ元データの削除確認
        List<Account> afterTestTargetRecord = [SELECT id
                                            FROM Account
                                            WHERE Name = '坂井 美里' AND NameKana__c = 'サカイミサト'
        ];
        system.assertEquals(true, afterTestTargetRecord.isEmpty());

        //名寄せ先データの名寄せ完了フラグ確認
        Account displayRecordOne = [SELECT id, IsMergeCompletedFlag__c
                                    FROM Account
                                    WHERE Name = '坂井 美里' AND NameKana__c = 'サカイミサト２'
        ];
        system.assertEquals(true, displayRecordOne.IsMergeCompletedFlag__c);

    }

    //マージ結果確認（トランザクション確認）
    @isTest static void mergeAccountsTransactionTest() {

        //名寄せ一致したデータが変更されていないことを確認するため、退避
        Account chkAccount = [  SELECT id, LastModifiedDate
                                FROM Account
                                WHERE Name = '坂井 美里' AND NameKana__c = 'サカイミサト２'
        ];


        Account testTargetRecord = [SELECT Id, 
                                    Name, 
                                    NameKana__c, 
                                    Phone, 
                                    Phone2__c, 
                                    Phone3__c, 
                                    Email__c, 
                                    Email2__c, 
                                    Email3__c, 
                                    Address__c, 
                                    IsMergeCompletedFlag__c,
                                    LastModifiedDate
                                    FROM Account
                                    WHERE Name = '坂井 美里' AND NameKana__c = 'サカイミサト'
        ];

        //パラメーター設定
        PageReference pageRef = Page.GA102003View;
        PageRef.getParameters().put('Id', testTargetRecord.Id);
        Test.setCurrentPage(pageRef);

        //コントローラー作成
        GA102003Controller testController = new GA102003Controller();

        //明細行を０に設定
        testController.mergeSelectedIndex = 0;

        //エラーを起こすため、名前に空白を設定
        system.debug(testController.displayCandidateResult[0].candidateResult);
        testController.displayCandidateResult[0].candidateResult.Name = '';

        //選択ボタンを起動
        testController.mergeAccounts();

        // エラーが発生したことを確認
        system.assertEquals(true, testController.hasErrorMessage);


        //名寄せ元データが変更されていないことを確認
        List<Account> afterTestTargetRecord = [SELECT id, LastModifiedDate
                                            FROM Account
                                            WHERE Name = '坂井 美里' AND NameKana__c = 'サカイミサト'
        ];
        system.assertEquals(testTargetRecord.LastModifiedDate, afterTestTargetRecord[0].LastModifiedDate);

        //名寄せ一致したデータが変更されていないことを確認
        Account chkAccountAfter = [ SELECT id, LastModifiedDate
                                    FROM Account
                                    WHERE Name = '坂井 美里' AND NameKana__c = 'サカイミサト２'
        ];
        system.assertEquals(chkAccount.LastModifiedDate, chkAccountAfter.LastModifiedDate);

    }

    //コンストラクタテスト
    @isTest static void initializeErrorTest() {


        //パラメーター設定
        PageReference pageRef = Page.GA102003View;
        PageRef.getParameters().put('Id', '0060T0000023JEAQA2');
        Test.setCurrentPage(pageRef);

        //コントローラー作成
        GA102003Controller testController = new GA102003Controller();

        //エラーメッセージ確認
        List<ApexPages.Message> Messages = ApexPages.getMessages();
        system.assertEquals(true, messages [0].getdetail().contains(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));


    }

    //選択リンクアクションテスト
    @isTest static void selectActionErrorTest() {

        Account testTargetRecord = [SELECT Id, 
                                    Name, 
                                    NameKana__c, 
                                    Phone, 
                                    Phone2__c, 
                                    Phone3__c, 
                                    Email__c, 
                                    Email2__c, 
                                    Email3__c, 
                                    Address__c, 
                                    IsMergeCompletedFlag__c
                                    FROM Account
                                    WHERE Name = '坂井 美里' AND NameKana__c = 'サカイミサト'
        ];

        Account displayRecordPhoneError = [SELECT Id, 
                                           Name, 
                                           NameKana__c, 
                                           Phone, 
                                           Phone2__c, 
                                           Phone3__c, 
                                           Email__c, 
                                           Email2__c, 
                                           Email3__c, 
                                           Address__c
                                           FROM Account
                                           WHERE Phone = '080-2345-6789' AND Phone2__c = '025-234-5678'
        ];


        //パラメーター設定
        PageReference pageRef = Page.GA102003View;
        PageRef.getParameters().put('Id', testTargetRecord.Id);
        Test.setCurrentPage(pageRef);

        //コントローラー作成
        GA102003Controller testController = new GA102003Controller();

        //明細行を1に設定
        testController.mergeSelectedIndex = 1;

        //選択ボタンを起動
        testController.mergeAccounts();


        //エラーメッセージ確認
        List<ApexPages.Message> Messages = ApexPages.getMessages();
        System.debug(messages [0].getdetail());
        system.assertEquals(true, messages [0].getdetail().contains(CommonConst.MSG_COM_W_EXECUTE_MERGE));

    }
    
    //カバレッジ率上昇
    @isTest static void forCoverage() {
        
        Account testTargetRecord = [SELECT Id
                                    FROM Account
                                    WHERE Email3__c = 'aaa@hora'
                                    LIMIT 1
        ];
        //パラメーター設定
        PageReference pageRef = Page.GA102003View;
        PageRef.getParameters().put('Id', testTargetRecord.Id);
        Test.setCurrentPage(pageRef);
        
        //コントローラー作成
        GA102003Controller testController = new GA102003Controller();
        
        //変数呼び出し
        String testString;
        testString = testController.MSG_COM_V_EXECUTE_NON_MERGE;
        testString = testController.MSG_COM_I_NON_MERGE_END;
        testString = testController.MSG_COM_V_EXECUTE_MERGE;
        testString = testController.MSG_COM_I_MERGE_END;
        
        //明細行を2に設定
        testController.mergeSelectedIndex = 1;

        //選択ボタンを起動
        testController.mergeAccounts();
    }
    
    //2020/6/8追加　カバレッジ率上げ用
    @isTest static void coverageUp(){
        Account test1 = new Account(Name = 'カバUP', 
                                    NameKana__c = 'カバ', 
                                    Phone = '1234321', 
                                    Email__c = 'test@test', 
                                    state__c = '愛知県', 
                                    city__c = 'あああ', 
                                    street__c = 'あああ', 
                                    Email2__c = 'test2@test',
                                    Email3__c = 'test3@test', 
                                    Phone2__c = '123456', 
                                    Phone3__c = '222222', 
                                    Affiliation__c = 'テスト1',
                                    RecordTypeId = commonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER));

        Account test2 = new Account(Name = 'カバUP', 
                                    NameKana__c = 'カバ', 
                                    Phone = '1234321', 
                                    Email__c = 'test@test', 
                                    state__c = '愛知県', 
                                    city__c = 'あああ', 
                                    street__c = 'あああ', 
                                    Email2__c = 'test2@test',
                                    Email3__c = 'test3@test', 
                                    Phone2__c = '123456', 
                                    Phone3__c = '222222', 
                                    Affiliation__c = 'テスト2',
                                    RecordTypeId = commonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER));
        List<Account> testRecords = new List<Account>();
        testRecords.add(test1);
        testRecords.add(test2);
        Insert testRecords;

        Account testTargetRecord = [SELECT Id, 
                                    Name, 
                                    NameKana__c, 
                                    Phone, 
                                    Phone2__c, 
                                    Phone3__c, 
                                    Email__c, 
                                    Email2__c, 
                                    Email3__c, 
                                    Address__c
                                    FROM Account
                                    WHERE Affiliation__c = 'テスト1'
        ];

        Account displayRecordOne = [SELECT Id, 
                                    Name, 
                                    NameKana__c, 
                                    Phone, 
                                    Phone2__c, 
                                    Phone3__c, 
                                    Email__c, 
                                    Email2__c, 
                                    Email3__c, 
                                    Address__c
                                    FROM Account
                                    WHERE Affiliation__c = 'テスト2'
        ];

        //パラメーター設定
        PageReference pageRef = Page.GA102003View;
        PageRef.getParameters().put('Id', testTargetRecord.Id);
        Test.setCurrentPage(pageRef);

        //コントローラー作成
        GA102003Controller testController = new GA102003Controller();
        //明細行を０に設定
        testController.mergeSelectedIndex = 0;

        //選択ボタンを起動
        testController.mergeAccounts();
        String a = testController.MSG_COM_I_NON_MERGE_END;
        a =testController.MSG_COM_V_EXECUTE_NON_MERGE;
        a =testController.MSG_COM_V_EXECUTE_MERGE;
        a =testController.MSG_COM_I_MERGE_END;

	}
	

	//2020/10/29 ポータル会員ID追加のテスト

	@istest static void updateTest(){

		Account testTargetRecord = [SELECT Id, 
                                    Name, 
                                    NameKana__c, 
                                    Phone, 
                                    Phone2__c, 
                                    Phone3__c, 
                                    Email__c, 
                                    Email2__c, 
									Email3__c,
                                    Address__c, 
                                    IsMergeCompletedFlag__c
                                    FROM Account
                                    WHERE Name = '坂井 美里' AND NameKana__c = 'サカイミサト'
		];

		//本会員
        Member__c  memdate = new Member__c(
				MemberId__c = 'honkain'
				,LastName__c = '坂井'
				,FirstName__c = '美里'
				,LastNameKana__c = 'サカイ'
				,FirstNameKana__c = 'ミサト'
				,Tell__c = '025-200-1234'
				,Email__c = 'aaa@hora'
				,Password__c = 'password'
				,Birthdate__c = Date.newInstance(1995,1,1)
				,Gender__c = '女性'
				,RecommendMailFlg__c = true
				,Account__c = testTargetRecord.Id
				,JoinDate__c = Date.newInstance(2020,1,1)
				,Blacklist__c = false
			);
		insert memdate;
			
        //パラメーター設定
        PageReference pageRef = Page.GA102003View;
        PageRef.getParameters().put('Id', testTargetRecord.Id);
		Test.setCurrentPage(pageRef);
        
        //コントローラー作成
        GA102003Controller testController = new GA102003Controller();

        //検索結果1行目の取引先に設定
        testController.mergeSelectedIndex = 0;

        //選択ボタンを起動
        testController.mergeAccounts();


		List<Member__c> memList = [SELECT id,Account__c FROM Member__c WHERE Account__c = :testController.displayCandidateResult [testController.mergeSelectedIndex].candidateResult.id];
        //updateした本会員差分で本会員の取引先が更新されている？
        system.assertEquals(true, !memList.isEmpty());
	}
    
	// ▼2021.10.08 No.307 対応で追加
	// No.307 対応_名寄せテストNo1,3
	@isTest static void apcTest1(){
		//不要データ削除
        List<Account> delList = [SELECT id, IsMergeUnnecessaryFlag__c
                                 FROM Account
                                 WHERE Name = '坂井 美里' AND NameKana__c IN ('サカイミサト３', 'サカイミサト４')
        ];
        delete delList;

		//名寄せ元取引先を取得し、ユニークな物件条件名をセット
		Account testBaseRecord = getSpcAccount('サカイミサト');
		testBaseRecord.PropertyConditionsName__c = '条件1';

		//名寄せ先取引先を取得し、ユニークな物件条件名をセット
		Account testTargetRecord = getSpcAccount('サカイミサト２');
		testTargetRecord.PropertyConditionsName__c = '条件2';

		update new List<Account>{testBaseRecord, testTargetRecord};

        //パラメーター設定
        PageReference pageRef = Page.GA102003View;
        PageRef.getParameters().put('Id', testBaseRecord.Id);
        Test.setCurrentPage(pageRef);

        //コントローラー作成
        GA102003Controller testController = new GA102003Controller();

        //明細行を０に設定
        testController.mergeSelectedIndex = 0;

        //選択ボタンを起動
        testController.mergeAccounts();

		//名寄せ先取引先と紐づくお客様物件条件を取得
		List<AccountPropertyConditions__c> apcList = getApcListByAccount(testTargetRecord.Id);
		System.assertEquals(1, apcList.size(), '名寄せ実施後の名寄せ先取引先と紐づくお客様物件条件件数が不正');

		//名寄せ先取引先と紐づくお客様物件条件と、名寄せ前の名寄せ元取引先の物件条件項目を比較
		assertEqualsApc_Account(apcList.get(0), testBaseRecord);
		System.assertEquals('条件1', apcList.get(0).Name, '生成されたお客様物件条件の物件条件名が変更されている');
	}

	// No.307 対応_名寄せテストNo2,4
	@isTest static void apcTest2(){
		//不要データ削除
        List<Account> delList = [SELECT id, IsMergeUnnecessaryFlag__c
                                 FROM Account
                                 WHERE Name = '坂井 美里' AND NameKana__c IN ('サカイミサト３', 'サカイミサト４')
        ];
        delete delList;

		//名寄せ元取引先を取得し、ユニークな物件条件名をセット
		Account testBaseRecord = getSpcAccount('サカイミサト');
		testBaseRecord = setAccountsApcFields(testBaseRecord);
		testBaseRecord.PropertyConditionsName__c = '条件1';

		//名寄せ先取引先を取得し、ユニークな物件条件名をセット
		Account testTargetRecord = getSpcAccount('サカイミサト２');
		testTargetRecord.PropertyConditionsName__c = '条件1';

		update new List<Account>{testBaseRecord, testTargetRecord};

        //パラメーター設定
        PageReference pageRef = Page.GA102003View;
        PageRef.getParameters().put('Id', testBaseRecord.Id);
        Test.setCurrentPage(pageRef);

        //コントローラー作成
        GA102003Controller testController = new GA102003Controller();

        //明細行を０に設定
        testController.mergeSelectedIndex = 0;

        //選択ボタンを起動
        testController.mergeAccounts();

		//名寄せ先取引先と紐づくお客様物件条件を取得
		List<AccountPropertyConditions__c> apcList = getApcListByAccount(testTargetRecord.Id);
		System.assertEquals(1, apcList.size(), '名寄せ実施後の名寄せ先取引先と紐づくお客様物件条件件数が不正');

		//名寄せ先取引先と紐づくお客様物件条件と、名寄せ前の名寄せ元取引先の物件条件項目を比較
		assertEqualsApc_Account(apcList.get(0), testBaseRecord);
		System.assertEquals('条件1(1)', apcList.get(0).Name, '生成されたお客様物件条件の物件条件名が変更されていない');
	}

	// No.307 対応_名寄せテストNo3
	@isTest static void apcTest3(){
		//不要データ削除
        List<Account> delList = [SELECT id, IsMergeUnnecessaryFlag__c
                                 FROM Account
                                 WHERE Name = '坂井 美里' AND NameKana__c IN ('サカイミサト３', 'サカイミサト４')
        ];
        delete delList;

		//名寄せ元取引先を取得し、ユニークな物件条件名をセット
		Account testBaseRecord = getSpcAccount('サカイミサト');
		testBaseRecord = setAccountsApcFields(testBaseRecord);
		testBaseRecord.PropertyConditionsName__c = '条件1';

		//名寄せ先取引先を取得し、ユニークな物件条件名をセット
		Account testTargetRecord = getSpcAccount('サカイミサト２');
		testTargetRecord.PropertyConditionsName__c = '条件2';

		update new List<Account>{testBaseRecord, testTargetRecord};

		//名寄せ元に紐づく、物件条件名がユニークなお客様物件条件を追加
		List<AccountPropertyConditions__c> apcList = new List<AccountPropertyConditions__c>();
		apcList.add(new AccountPropertyConditions__c(Name = '条件3', Account__c = testBaseRecord.Id));
		apcList.add(new AccountPropertyConditions__c(Name = '条件4', Account__c = testBaseRecord.Id));
		apcList.add(new AccountPropertyConditions__c(Name = '条件5', Account__c = testBaseRecord.Id));

		//名寄せ先に紐づく、物件条件名がユニークなお客様物件条件を追加
		apcList.add(new AccountPropertyConditions__c(Name = '条件あ', Account__c = testTargetRecord.Id));
		apcList.add(new AccountPropertyConditions__c(Name = 'あいうえお', Account__c = testTargetRecord.Id));
		apcList.add(new AccountPropertyConditions__c(Name = '０１２３４５６７８９０１２３４５６７８９', Account__c = testTargetRecord.Id));
		
		insert apcList;

        //パラメーター設定
        PageReference pageRef = Page.GA102003View;
        PageRef.getParameters().put('Id', testBaseRecord.Id);
        Test.setCurrentPage(pageRef);

        //コントローラー作成
        GA102003Controller testController = new GA102003Controller();

        //明細行を０に設定
        testController.mergeSelectedIndex = 0;

        //選択ボタンを起動
        testController.mergeAccounts();

		//名寄せ先取引先と紐づくお客様物件条件を取得
		List<AccountPropertyConditions__c> afterApcList = getApcListByAccount(testTargetRecord.Id);
		System.assertEquals(7, afterApcList.size(), '名寄せ実施後の名寄せ先取引先と紐づくお客様物件条件件数が不正');

		//名寄せ先取引先と紐づくお客様物件条件の物件条件名をSetに格納する
		Set<String> apcNameSet = new Set<String>();
		for(AccountPropertyConditions__c apc: afterApcList){
			apcNameSet.add(apc.Name);
		}
		System.assertEquals(7, apcNameSet.size(), '名寄せ実施後の名寄せ先取引先と紐づくお客様物件条件件数の物件条件名に重複がある');
	}

	// No.307 対応_名寄せテストNo6,7
	@isTest static void apcTest4(){
		apcTest4Run();
	}

	private static void apcTest4Run(){
		//不要データ削除
        List<Account> delList = [SELECT id, IsMergeUnnecessaryFlag__c
                                 FROM Account
                                 WHERE Name = '坂井 美里' AND NameKana__c IN ('サカイミサト３', 'サカイミサト４')
        ];
        delete delList;

		//名寄せ元取引先を取得し、ユニークな物件条件名をセット
		Account testBaseRecord = getSpcAccount('サカイミサト');
		testBaseRecord = setAccountsApcFields(testBaseRecord);
		testBaseRecord.PropertyConditionsName__c = '条件1';

		//名寄せ先取引先を取得し、ユニークな物件条件名をセット
		Account testTargetRecord = getSpcAccount('サカイミサト２');
		testTargetRecord.PropertyConditionsName__c = '条件名寄せ先';

		update new List<Account>{testBaseRecord, testTargetRecord};

		//名寄せ元に紐づく、物件条件名がユニークなお客様物件条件を追加
		List<AccountPropertyConditions__c> apcList = new List<AccountPropertyConditions__c>();
		apcList.add(new AccountPropertyConditions__c(Name = '条件名寄せ先', Account__c = testBaseRecord.Id));
		apcList.add(new AccountPropertyConditions__c(Name = '条件2(1)', Account__c = testBaseRecord.Id));
		apcList.add(new AccountPropertyConditions__c(Name = '０１２３４５６７８９０１２３４５６７８９', Account__c = testBaseRecord.Id));

		//名寄せ先に紐づく、物件条件名がユニークなお客様物件条件を追加
		apcList.add(new AccountPropertyConditions__c(Name = '条件1', Account__c = testTargetRecord.Id));
		apcList.add(new AccountPropertyConditions__c(Name = '条件2(1)', Account__c = testTargetRecord.Id));
		apcList.add(new AccountPropertyConditions__c(Name = '０１２３４５６７８９０１２３４５６７８９', Account__c = testTargetRecord.Id));
		
		insert apcList;

        //パラメーター設定
        PageReference pageRef = Page.GA102003View;
        PageRef.getParameters().put('Id', testBaseRecord.Id);
        Test.setCurrentPage(pageRef);

        //コントローラー作成
        GA102003Controller testController = new GA102003Controller();

        //明細行を０に設定
        testController.mergeSelectedIndex = 0;

        //選択ボタンを起動
        testController.mergeAccounts();

		//名寄せ先取引先と紐づくお客様物件条件を取得
		List<AccountPropertyConditions__c> afterApcList = getApcListByAccount(testTargetRecord.Id);
		System.assertEquals(7, afterApcList.size(), '名寄せ実施後の名寄せ先取引先と紐づくお客様物件条件件数が不正');

		//名寄せ先取引先と紐づくお客様物件条件の物件条件名をSetに格納する
		Set<String> apcNameSet = new Set<String>();
		for(AccountPropertyConditions__c apc: afterApcList){
			apcNameSet.add(apc.Name);
		}
		System.assertEquals(7, apcNameSet.size(), '名寄せ実施後の名寄せ先取引先と紐づくお客様物件条件件数の物件条件名に重複がある');
		apcNameSet.add(testTargetRecord.PropertyConditionsName__c);

		//名寄せ実施後の物件条件名をチェックする
		List<String> checkApcNameList = new List<String>{'条件1', '条件名寄せ先', '条件名寄せ先(1)', '条件2(1)', '０１２３４５６７８９０１２３４５６７８９',
		'条件1(1)', '条件2(2)', '０１２３４５６７８９０１２３４５６７８９(1)'};
		for(String checkApcName: checkApcNameList){
			System.assertEquals(true, apcNameSet.contains(checkApcName), '名寄せ実施後の名寄せ先取引先と紐づくお客様物件条件件数の物件条件名に「' + checkApcName + '」が存在しない');
		}
	}

	// No.307 対応_名寄せテストNo8
	@isTest static void apcTest5(){
		//一般ユーザで実行
        User ippanUser = [SELECT Id 
            ,LastName 
            ,Alias
            ,Email
            ,UserName
            ,CommunityNickname
            ,EmailEncodingKey
            ,TimeZoneSidKey 
            ,LocaleSidKey 
            ,LanguageLocaleKey
            ,ProfileId 
            FROM User
            WHERE LastName = 'ippanUser' 
        ];

		System.runAs(ippanUser){
			apcTest4Run();
		}
	}

	// ▼ 2022.2.3 LINE連携対応より、追加
	/**
	 * 重複データの削除テスト
	 */
	@isTest static void deleteDuplicateDataTest() {
		
		// 名寄せ元の取得
		Account account = getSpcAccount('サカイミサト');

		User user = [SELECT Id FROM User WHERE LastName = 'ippanUser'];
		System.runAs(user){
			test.startTest();

			//パラメーター設定
			PageReference pageRef = Page.GA102003View;
			PageRef.getParameters().put('Id', account.Id);
			Test.setCurrentPage(pageRef);

			// 名寄せ元の確認
			System.assertEquals(selectVacancyReservationProperty(account.Id).size(),	1, '名寄せ元の空室予約物件件数');
			System.assertEquals(selectLineMember(account.Id).size(),					1, '名寄せ元のLINE会員件数');
			System.assertEquals(selectLineMemberCandidate(account.Id).size(),			1, '名寄せ元のLINE会員候補件数');

			// 名寄せ先の確認
			GA102003Controller testController = new GA102003Controller();
			testController.mergeSelectedIndex = 0;

			Account targetAcc = testController.displayCandidateResult[testController.mergeSelectedIndex].candidateResult;
			System.assertEquals(targetAcc.NameKana__c, 'サカイミサト２', '名寄せ対象');
			System.assertEquals(selectVacancyReservationProperty(targetAcc.Id).size(),	2, '名寄せ先の空室予約物件件数');
			System.assertEquals(selectLineMember(targetAcc.Id).size(),					1, '名寄せ先のLINE会員件数');
			System.assertEquals(selectLineMemberCandidate(targetAcc.Id).size(),			1, '名寄せ先のLINE会員候補件数');

			// 名寄せの確認
			testController.mergeAccounts();

			System.assertEquals(selectVacancyReservationProperty(targetAcc.Id).size(),	2, '名寄せ後の空室予約物件件数');
			System.assertEquals(selectLineMember(targetAcc.Id).size(),					1, '名寄せ後のLINE会員件数');
			System.assertEquals(selectLineMemberCandidate(targetAcc.Id).size(),			1, '名寄せ後のLINE会員候補件数');

			test.stopTest();
		}
	}

	/**
	 * その他オブジェクトの名寄せテスト
	 */
	@isTest static void mergeOtherObjectDataTest() {
		
		// 名寄せ元の取得
		Account account = getSpcAccount('サカイミサト');

		User user = [SELECT Id FROM User WHERE LastName = 'ippanUser'];
		System.runAs(user){
			test.startTest();

			//パラメーター設定
			PageReference pageRef = Page.GA102003View;
			PageRef.getParameters().put('Id', account.Id);
			Test.setCurrentPage(pageRef);

			// 名寄せ元の確認
			System.assertEquals(selectVacancyReservationProperty(account.Id).size(),	1, '名寄せ元の空室予約物件件数');
			System.assertEquals(selectLineMember(account.Id).size(),					1, '名寄せ元のLINE会員件数');
			System.assertEquals(selectLineMemberCandidate(account.Id).size(),			1, '名寄せ元のLINE会員候補件数');

			// 名寄せ先の確認
			GA102003Controller testController = new GA102003Controller();
			testController.mergeSelectedIndex = 0;

			Account targetAcc = testController.displayCandidateResult[testController.mergeSelectedIndex].candidateResult;
			System.assertEquals(targetAcc.NameKana__c, 'サカイミサト２', '名寄せ対象');

			// 名寄せ先の関連オブジェクトの削除
			delete selectVacancyReservationProperty(targetAcc.Id);
			delete selectLineMember(targetAcc.Id);
			delete selectLineMemberCandidate(targetAcc.Id);

			System.assertEquals(selectVacancyReservationProperty(targetAcc.Id).size(),	0, '名寄せ先の空室予約物件件数');
			System.assertEquals(selectLineMember(targetAcc.Id).size(),					0, '名寄せ先のLINE会員件数');
			System.assertEquals(selectLineMemberCandidate(targetAcc.Id).size(),			0, '名寄せ先のLINE会員候補件数');

			// 名寄せの確認
			testController.mergeAccounts();

			System.assertEquals(selectVacancyReservationProperty(targetAcc.Id).size(),	1, '名寄せ後の空室予約物件件数');
			System.assertEquals(selectLineMember(targetAcc.Id).size(),					1, '名寄せ後のLINE会員件数');
			System.assertEquals(selectLineMemberCandidate(targetAcc.Id).size(),			1, '名寄せ後のLINE会員候補件数');

			test.stopTest();
		}
	}
	// ▲ 2022.2.3

	//物件条件項目を含む取引先レコードを取得
	private static Account getSpcAccount(String nameKana){
		Account acc = [SELECT Id,
			PropertyConditionsName__c,		//物件条件名
			IsReservePropertyConditions__c,	//予約物件条件
			DesiredArea__c,					//希望地域
			DesiredTrainRoute1__c,	//希望沿線１
			DesiredTrainRoute2__c,	//希望沿線２
			DesiredTrainRoute3__c,	//希望沿線３
			WalkingTime__c,			//徒歩
			IsOneRoom__c,			//ワンルーム
			Is1K__c,				//1K
			Is1DK__c,				//1DK
			Is1LDK1SLDK__c,			//1LDK/SLDK
			Is2K2DK__c,				//2K/DK
			Is2LDK2SLDK__c,			//2LDK/SLDK
			Is3K3DK__c,				//3K/DK
			Is3LDK3SLDK__c,			//3LDK/SLDK
			Is4K4DK4LDKFrom__c,		//4K/DK/LDK~
			IsWooden__c,			//木造
			IsLightweightSteel__c,	//軽量鉄骨
			IsSteel__c,				//鉄骨造
			IsRC__c,				//RC
			IsSRC__c,				//SRC
			IsNorth__c,				//北
			IsNorthEast__c,			//北東
			IsEast__c,				//東
			IsSouthEast__c,			//南東
			IsSouth__c,				//南
			IsSouthWest__c,			//南西
			IsWest__c,				//西
			IsNorthWest__c,			//北西
			IsNonDeposit__c,		//敷金/保証金なし
			IsNonKeyMoney__c,		//礼金なし
			IsNonCleaningFee__c,	//定額修繕費なし
			IsNonRenewalFee__c,		//更新料なし
			RentFeeFrom__c,			//賃料から
			RentFeeTo__c,			//賃料まで
			IsIncludeManagementFee__c,	//管理費込み
			IsIncludeParkingFee__c,		//駐車場代込み
			OccupancyAreaLowerLimit__c,	//占有面積（下限）
			OccupancyAreaUpperLimit__c,	//占有面積（上限）
			BuildingAge__c,			//築年数
			IsDetachedHouse__c,		//戸建て
			IsMaisonette__c,		//メゾネット
			IsLoft__c,				//ロフト
			IsDesigners__c,			//デザイナーズ
			IsRenovation__c,		//リノベーション
			IsCondominiumRental__c,	//分譲賃貸
			IsAllWestern__c,		//オール洋間
			IsFirstFloor__c,		//1階
			IsSecondFloorOver__c,	//2階以上
			IsTopFloor__c,			//最上階
			IsCornerRoom__c,		//角部屋
			IsBalcony__c,			//バルコニー
			IsRoofBalcony__c,		//ルーフバルコニー
			IsPrivateGarden__c,		//専用庭
			IsParking__c,			//駐車場空きあり
			IsInSiteParking__c,		//敷地内駐車場
			IsPluralCarParking__c,	//駐車場2台可
			IsBuiltInGarage__c,		//ビルトインガレージ
			IsCarport__c,			//カーポート
			IsBicycleParking__c,	//駐輪場
			IsBikeStorage__c,		//バイク可
			IsSmallBike__c,			//小型バイク
			IsMediumBike__c,		//中型バイク
			IsLargeBike__c,			//大型バイク
			IsElevator__c,			//エレベーター
			IsDeliveryBox__c,		//宅配ボックス
			IsCounterKitchen__c,	//カウンターキッチン
			IsSystemKitchen__c,		//システムキッチン
			IsGasStove__c,			//ガスコンロ
			IsElectricStove__c,		//電気コンロ
			IsInductionHeating__c,	//IHコンロ
			IsTwoGasStove__c,		//コンロ2口
			IsMoreGasStove__c,		//コンロ3口以上
			IsSepalateBathAndRestroom__c,	//バス・トイレ別
			IsAditionalBoiling__c,			//追焚機能
			IsDehumidifierForBathroom__c,	//浴室乾燥機
			IsWashlet__c,					//温水洗浄便座
			IsShowerWashBasin__c,			//シャワー付き洗面台
			IsRegalLavatory__c,	//洗面所独立
			IsInnerLandry__c,	//室内洗濯機置場
			IsTownGas__c,		//都市ガス
			IsPropaneGas__c,	//プロパンガス
			IsAllElectric__c,	//オール電化
			IsAirConditioner__c,//エアコン
			IsFloorHeating__c,	//床暖房
			IsShoesBox__c,		//シューズボックス
			IsShoeCloak__c,		//シューズクローク
			IsWalkInCloset__c,	//ウォークインクローゼット
			IsTrunkRoom__c,		//トランクルーム
			IsBSAntenna__c,		//BSアンテナ
			IsCSAntenna__c,		//CSアンテナ
			IsCATV__c,				//CATV
			IsInternetFree__c,		//ネット使用料無料
			IsMonitorIntercom__c,	//モニター付きインターホン
			IsAutoLock__c,			//オートロック
			IsFurniture__c,			//家具付き
			IsHomeAppliance__c,		//家電付き
			IsNoGuarantor__c,		//保証人不要
			IsNonGuaranteeidCompany__c,	//保証会社不要
			IsMusicalInstruments__c,	//楽器相談可
			IsForeigner__c,				//外国人契約可
			IsOfficeAvailable__c,		//事務所利用可
			IsWelfareAvailable__c,		//生活保護契約可
			IsPet__c,			//ペット可
			IsLargePet__c,		//ペット(大型犬)
			IsMiddlePet__c,		//ペット(中型犬)
			IsSmallPet__c,		//ペット(小型犬)
			IsCat__c,			//ペット(猫)
			IsOtherPet__c,		//ペット(その他)
			IsTwoTenant__c,		//2人入居可
			IsRoomShare__c,		//ルームシェア可
			IsIppambutsu__c,	//一般物
			IsElderly__c,		//高齢者歓迎
			IsWoman__c,			//女性限定
			IsStudent__c,		//学生限定マンション
			CarCount__c,		//台数
			ParkingFeeLimit__c,	//1台当たりの料金上限
			Parking__c,			//駐車場
			DesiredJuniorHighSchoolArea__c,		//中学校希望学区（エリア）
			DesiredElementarySchoolArea__c,		//小学校希望学区（エリア）
			(SELECT Account__c, Name FROM AccountPropertyConditionss__r)	//お客様物件条件
			FROM Account WHERE NameKana__c = :nameKana
			LIMIT 1];
		return acc;
	}

	//取引先Idをキーとして、お客様物件条件を取得
	private static List<AccountPropertyConditions__c> getApcListByAccount(Id accId){
		List<AccountPropertyConditions__c> apcList = [SELECT Id,
			Name,							//物件条件名
			IsReservePropertyConditions__c,	//予約物件条件
			DesiredArea__c,					//希望地域
			DesiredTrainRoute1__c,	//希望沿線１
			DesiredTrainRoute2__c,	//希望沿線２
			DesiredTrainRoute3__c,	//希望沿線３
			WalkingTime__c,			//徒歩
			IsOneRoom__c,			//ワンルーム
			Is1K__c,				//1K
			Is1DK__c,				//1DK
			Is1LDK1SLDK__c,			//1LDK/SLDK
			Is2K2DK__c,				//2K/DK
			Is2LDK2SLDK__c,			//2LDK/SLDK
			Is3K3DK__c,				//3K/DK
			Is3LDK3SLDK__c,			//3LDK/SLDK
			Is4K4DK4LDKFrom__c,		//4K/DK/LDK~
			IsWooden__c,			//木造
			IsLightweightSteel__c,	//軽量鉄骨
			IsSteel__c,				//鉄骨造
			IsRC__c,				//RC
			IsSRC__c,				//SRC
			IsNorth__c,				//北
			IsNorthEast__c,			//北東
			IsEast__c,				//東
			IsSouthEast__c,			//南東
			IsSouth__c,				//南
			IsSouthWest__c,			//南西
			IsWest__c,				//西
			IsNorthWest__c,			//北西
			IsNonDeposit__c,		//敷金/保証金なし
			IsNonKeyMoney__c,		//礼金なし
			IsNonCleaningFee__c,	//定額修繕費なし
			IsNonRenewalFee__c,		//更新料なし
			RentFeeFrom__c,			//賃料から
			RentFeeTo__c,			//賃料まで
			IsIncludeManagementFee__c,	//管理費込み
			IsIncludeParkingFee__c,		//駐車場代込み
			OccupancyAreaLowerLimit__c,	//占有面積（下限）
			OccupancyAreaUpperLimit__c,	//占有面積（上限）
			BuildingAge__c,			//築年数
			IsDetachedHouse__c,		//戸建て
			IsMaisonette__c,		//メゾネット
			IsLoft__c,				//ロフト
			IsDesigners__c,			//デザイナーズ
			IsRenovation__c,		//リノベーション
			IsCondominiumRental__c,	//分譲賃貸
			IsAllWestern__c,		//オール洋間
			IsFirstFloor__c,		//1階
			IsSecondFloorOver__c,	//2階以上
			IsTopFloor__c,			//最上階
			IsCornerRoom__c,		//角部屋
			IsBalcony__c,			//バルコニー
			IsRoofBalcony__c,		//ルーフバルコニー
			IsPrivateGarden__c,		//専用庭
			IsParking__c,			//駐車場空きあり
			IsInSiteParking__c,		//敷地内駐車場
			IsPluralCarParking__c,	//駐車場2台可
			IsBuiltInGarage__c,		//ビルトインガレージ
			IsCarport__c,			//カーポート
			IsBicycleParking__c,	//駐輪場
			IsBikeStorage__c,		//バイク可
			IsSmallBike__c,			//小型バイク
			IsMediumBike__c,		//中型バイク
			IsLargeBike__c,			//大型バイク
			IsElevator__c,			//エレベーター
			IsDeliveryBox__c,		//宅配ボックス
			IsCounterKitchen__c,	//カウンターキッチン
			IsSystemKitchen__c,		//システムキッチン
			IsGasStove__c,			//ガスコンロ
			IsElectricStove__c,		//電気コンロ
			IsInductionHeating__c,	//IHコンロ
			IsTwoGasStove__c,		//コンロ2口
			IsMoreGasStove__c,		//コンロ3口以上
			IsSepalateBathAndRestroom__c,	//バス・トイレ別
			IsAditionalBoiling__c,			//追焚機能
			IsDehumidifierForBathroom__c,	//浴室乾燥機
			IsWashlet__c,					//温水洗浄便座
			IsShowerWashBasin__c,			//シャワー付き洗面台
			IsRegalLavatory__c,	//洗面所独立
			IsInnerLandry__c,	//室内洗濯機置場
			IsTownGas__c,		//都市ガス
			IsPropaneGas__c,	//プロパンガス
			IsAllElectric__c,	//オール電化
			IsAirConditioner__c,//エアコン
			IsFloorHeating__c,	//床暖房
			IsShoesBox__c,		//シューズボックス
			IsShoeCloak__c,		//シューズクローク
			IsWalkInCloset__c,	//ウォークインクローゼット
			IsTrunkRoom__c,		//トランクルーム
			IsBSAntenna__c,		//BSアンテナ
			IsCSAntenna__c,		//CSアンテナ
			IsCATV__c,				//CATV
			IsInternetFree__c,		//ネット使用料無料
			IsMonitorIntercom__c,	//モニター付きインターホン
			IsAutoLock__c,			//オートロック
			IsFurniture__c,			//家具付き
			IsHomeAppliance__c,		//家電付き
			IsNoGuarantor__c,		//保証人不要
			IsNonGuaranteeidCompany__c,	//保証会社不要
			IsMusicalInstruments__c,	//楽器相談可
			IsForeigner__c,				//外国人契約可
			IsOfficeAvailable__c,		//事務所利用可
			IsWelfareAvailable__c,		//生活保護契約可
			IsPet__c,			//ペット可
			IsLargePet__c,		//ペット(大型犬)
			IsMiddlePet__c,		//ペット(中型犬)
			IsSmallPet__c,		//ペット(小型犬)
			IsCat__c,			//ペット(猫)
			IsOtherPet__c,		//ペット(その他)
			IsTwoTenant__c,		//2人入居可
			IsRoomShare__c,		//ルームシェア可
			IsIppambutsu__c,	//一般物
			IsElderly__c,		//高齢者歓迎
			IsWoman__c,			//女性限定
			IsStudent__c,		//学生限定マンション
			CarCount__c,		//台数
			ParkingFeeLimit__c,	//1台当たりの料金上限
			Parking__c,			//駐車場
			DesiredJuniorHighSchoolArea__c,		//中学校希望学区（エリア）
			DesiredElementarySchoolArea__c		//小学校希望学区（エリア）
			FROM AccountPropertyConditions__c WHERE Account__c = :accId];

		return apcList;
	}

	private static Account setAccountsApcFields(Account acc){
		List<DesiredTrainRoute__c> dtrList = [SELECT Id FROM DesiredTrainRoute__c];
		List<DesiredSchool__c> edsList = [SELECT Id, DesiredSchoolArea__c FROM DesiredSchool__c WHERE School__r.Type__c = '小学校'];
		List<DesiredSchool__c> cdsList = [SELECT Id, DesiredSchoolArea__c FROM DesiredSchool__c WHERE School__r.Type__c = '中学校'];
		
		acc.PropertyConditionsName__c = '条件1';//物件条件名
		acc.IsReservePropertyConditions__c = true;//予約物件条件
		acc.DesiredArea__c = 'テスト地域';//希望地域
		acc.DesiredTrainRoute1__c = dtrList[0].Id;//希望沿線１
		acc.DesiredTrainRoute2__c = dtrList[1].Id;//希望沿線２
		acc.DesiredTrainRoute3__c = dtrList[2].Id;//希望沿線３
		acc.WalkingTime__c = '20';//徒歩
		acc.IsOneRoom__c = true;//ワンルーム
		acc.Is1K__c = true;//1K
		acc.Is1DK__c = true;//1DK
		acc.Is1LDK1SLDK__c = true;//1LDK/SLDK
		acc.Is2K2DK__c = true;//2K/DK
		acc.Is2LDK2SLDK__c = true;//2LDK/SLDK
		acc.Is3K3DK__c = true;//3K/DK
		acc.Is3LDK3SLDK__c = true;//3LDK/SLDK
		acc.Is4K4DK4LDKFrom__c = true;//4K/DK/LDK~
		acc.IsWooden__c = true;//木造
		acc.IsLightweightSteel__c = true;//軽量鉄骨
		acc.IsSteel__c = true;//鉄骨造
		acc.IsRC__c = true;//RC
		acc.IsSRC__c = true;//SRC
		acc.IsNorth__c = true;//北
		acc.IsNorthEast__c = true;//北東
		acc.IsEast__c = true;//東
		acc.IsSouthEast__c = true;//南東
		acc.IsSouth__c = true;//南
		acc.IsSouthWest__c = true;//南西
		acc.IsWest__c = true;//西
		acc.IsNorthWest__c = true;//北西
		acc.IsNonDeposit__c = true;//敷金/保証金なし
		acc.IsNonKeyMoney__c = true;//礼金なし
		acc.IsNonCleaningFee__c = true;//定額修繕費なし
		acc.IsNonRenewalFee__c = true;//更新料なし
		acc.RentFeeFrom__c = 50000;//賃料から
		acc.RentFeeTo__c = 150000;//賃料まで
		acc.IsIncludeManagementFee__c = true;//管理費込み
		acc.IsIncludeParkingFee__c = true;//駐車場代込み
		acc.OccupancyAreaLowerLimit__c = '25';//占有面積（下限）
		acc.OccupancyAreaUpperLimit__c = '40';//占有面積（上限）
		acc.BuildingAge__c = '10';//築年数
		acc.IsDetachedHouse__c = true;//戸建て
		acc.IsMaisonette__c = true;//メゾネット
		acc.IsLoft__c = true;//ロフト
		acc.IsDesigners__c = true;//デザイナーズ
		acc.IsRenovation__c = true;//リノベーション
		acc.IsCondominiumRental__c = true;//分譲賃貸
		acc.IsAllWestern__c = true;//オール洋間
		acc.IsFirstFloor__c = true;//1階
		acc.IsSecondFloorOver__c = true;//2階以上
		acc.IsTopFloor__c = true;//最上階
		acc.IsCornerRoom__c = true;//角部屋
		acc.IsBalcony__c = true;//バルコニー
		acc.IsRoofBalcony__c = true;//ルーフバルコニー
		acc.IsPrivateGarden__c = true;//専用庭
		acc.IsParking__c = true;//駐車場空きあり
		acc.IsInSiteParking__c = true;//敷地内駐車場
		acc.IsPluralCarParking__c = true;//駐車場2台可
		acc.IsBuiltInGarage__c = true;//ビルトインガレージ
		acc.IsCarport__c = true;//カーポート
		acc.IsBicycleParking__c = true;//駐輪場
		acc.IsBikeStorage__c = true;//バイク可
		acc.IsSmallBike__c = true;//小型バイク
		acc.IsMediumBike__c = true;//中型バイク
		acc.IsLargeBike__c = true;//大型バイク
		acc.IsElevator__c = true;//エレベーター
		acc.IsDeliveryBox__c = true;//宅配ボックス
		acc.IsCounterKitchen__c = true;//カウンターキッチン
		acc.IsSystemKitchen__c = true;//システムキッチン
		acc.IsGasStove__c = true;//ガスコンロ
		acc.IsElectricStove__c = true;//電気コンロ
		acc.IsInductionHeating__c = true;//IHコンロ
		acc.IsTwoGasStove__c = true;//コンロ2口
		acc.IsMoreGasStove__c = true;//コンロ3口以上
		acc.IsSepalateBathAndRestroom__c = true;//バス・トイレ別
		acc.IsAditionalBoiling__c = true;//追焚機能
		acc.IsDehumidifierForBathroom__c = true;//浴室乾燥機
		acc.IsWashlet__c = true;//温水洗浄便座
		acc.IsShowerWashBasin__c = true;//シャワー付き洗面台
		acc.IsRegalLavatory__c = true;//洗面所独立
		acc.IsInnerLandry__c = true;//室内洗濯機置場
		acc.IsTownGas__c = true;//都市ガス
		acc.IsPropaneGas__c = true;//プロパンガス
		acc.IsAllElectric__c = true;//オール電化
		acc.IsAirConditioner__c = true;//エアコン
		acc.IsFloorHeating__c = true;//床暖房
		acc.IsShoesBox__c = true;//シューズボックス
		acc.IsShoeCloak__c = true;//シューズクローク
		acc.IsWalkInCloset__c = true;//ウォークインクローゼット
		acc.IsTrunkRoom__c = true;//トランクルーム
		acc.IsBSAntenna__c = true;//BSアンテナ
		acc.IsCSAntenna__c = true;//CSアンテナ
		acc.IsCATV__c = true;//CATV
		acc.IsInternetFree__c = true;//ネット使用料無料
		acc.IsMonitorIntercom__c = true;//モニター付きインターホン
		acc.IsAutoLock__c = true;//オートロック
		acc.IsFurniture__c = true;//家具付き
		acc.IsHomeAppliance__c = true;//家電付き
		acc.IsNoGuarantor__c = true;//保証人不要
		acc.IsNonGuaranteeidCompany__c = true;//保証会社不要
		acc.IsMusicalInstruments__c = true;//楽器相談可
		acc.IsForeigner__c = true;//外国人契約可
		acc.IsOfficeAvailable__c = true;//事務所利用可
		acc.IsWelfareAvailable__c = true;//生活保護契約可
		acc.IsPet__c = true;//ペット可
		acc.IsLargePet__c = true;//ペット(大型犬)
		acc.IsMiddlePet__c = true;//ペット(中型犬)
		acc.IsSmallPet__c = true;//ペット(小型犬)
		acc.IsCat__c = true;//ペット(猫)
		acc.IsOtherPet__c = true;//ペット(その他)
		acc.IsTwoTenant__c = true;//2人入居可
		acc.IsRoomShare__c = true;//ルームシェア可
		acc.IsIppambutsu__c = true;//一般物
		acc.IsElderly__c = true;//高齢者歓迎
		acc.IsWoman__c = true;//女性限定
		acc.IsStudent__c = true;//学生限定マンション
		acc.CarCount__c = 2;//台数
		acc.ParkingFeeLimit__c = 20000;//1台当たりの料金上限
		acc.Parking__c = '有';//駐車場
		acc.DesiredJuniorHighSchoolArea__c = cdsList[0].DesiredSchoolArea__c;//中学校希望学区（エリア）
		acc.DesiredElementarySchoolArea__c = edsList[0].DesiredSchoolArea__c;//小学校希望学区（エリア）

		return acc;
	}

	//取引先レコードとお客様物件条件レコ―ドの物件条件項目が一致するか確認する
	private static void assertEqualsApc_Account(AccountPropertyConditions__c apc, Account acc){
		System.assertEquals(apc.IsReservePropertyConditions__c, acc.IsReservePropertyConditions__c, '検査対象取引先とお客様物件条件の予約物件条件が不一致');
		System.assertEquals(apc.DesiredArea__c, acc.DesiredArea__c, '検査対象取引先とお客様物件条件の希望地域が不一致');
		System.assertEquals(apc.DesiredTrainRoute1__c, acc.DesiredTrainRoute1__c, '検査対象取引先とお客様物件条件の希望沿線１が不一致');
		System.assertEquals(apc.DesiredTrainRoute2__c, acc.DesiredTrainRoute2__c, '検査対象取引先とお客様物件条件の希望沿線２が不一致');
		System.assertEquals(apc.DesiredTrainRoute3__c, acc.DesiredTrainRoute3__c, '検査対象取引先とお客様物件条件の希望沿線３が不一致');
		System.assertEquals(apc.WalkingTime__c, acc.WalkingTime__c, '検査対象取引先とお客様物件条件の徒歩が不一致');
		System.assertEquals(apc.IsOneRoom__c, acc.IsOneRoom__c, '検査対象取引先とお客様物件条件のワンルームが不一致');
		System.assertEquals(apc.Is1K__c, acc.Is1K__c, '検査対象取引先とお客様物件条件の1Kが不一致');
		System.assertEquals(apc.Is1DK__c, acc.Is1DK__c, '検査対象取引先とお客様物件条件の1DKが不一致');
		System.assertEquals(apc.Is1LDK1SLDK__c, acc.Is1LDK1SLDK__c, '検査対象取引先とお客様物件条件の1LDK/SLDKが不一致');
		System.assertEquals(apc.Is2K2DK__c, acc.Is2K2DK__c, '検査対象取引先とお客様物件条件の2K/DKが不一致');
		System.assertEquals(apc.Is2LDK2SLDK__c, acc.Is2LDK2SLDK__c, '検査対象取引先とお客様物件条件の2LDK/SLDKが不一致');
		System.assertEquals(apc.Is3K3DK__c, acc.Is3K3DK__c, '検査対象取引先とお客様物件条件の3K/DKが不一致');
		System.assertEquals(apc.Is3LDK3SLDK__c, acc.Is3LDK3SLDK__c, '検査対象取引先とお客様物件条件の3LDK/SLDKが不一致');
		System.assertEquals(apc.Is4K4DK4LDKFrom__c, acc.Is4K4DK4LDKFrom__c, '検査対象取引先とお客様物件条件の4K/DK/LDK~が不一致');
		System.assertEquals(apc.IsWooden__c, acc.IsWooden__c, '検査対象取引先とお客様物件条件の木造が不一致');
		System.assertEquals(apc.IsLightweightSteel__c, acc.IsLightweightSteel__c, '検査対象取引先とお客様物件条件の軽量鉄骨が不一致');
		System.assertEquals(apc.IsSteel__c, acc.IsSteel__c, '検査対象取引先とお客様物件条件の鉄骨造が不一致');
		System.assertEquals(apc.IsRC__c, acc.IsRC__c, '検査対象取引先とお客様物件条件のRCが不一致');
		System.assertEquals(apc.IsSRC__c, acc.IsSRC__c, '検査対象取引先とお客様物件条件のSRCが不一致');
		System.assertEquals(apc.IsNorth__c, acc.IsNorth__c, '検査対象取引先とお客様物件条件の北が不一致');
		System.assertEquals(apc.IsNorthEast__c, acc.IsNorthEast__c, '検査対象取引先とお客様物件条件の北東が不一致');
		System.assertEquals(apc.IsEast__c, acc.IsEast__c, '検査対象取引先とお客様物件条件の東が不一致');
		System.assertEquals(apc.IsSouthEast__c, acc.IsSouthEast__c, '検査対象取引先とお客様物件条件の南東が不一致');
		System.assertEquals(apc.IsSouth__c, acc.IsSouth__c, '検査対象取引先とお客様物件条件の南が不一致');
		System.assertEquals(apc.IsSouthWest__c, acc.IsSouthWest__c, '検査対象取引先とお客様物件条件の南西が不一致');
		System.assertEquals(apc.IsWest__c, acc.IsWest__c, '検査対象取引先とお客様物件条件の西が不一致');
		System.assertEquals(apc.IsNorthWest__c, acc.IsNorthWest__c, '検査対象取引先とお客様物件条件の北西が不一致');
		System.assertEquals(apc.IsNonDeposit__c, acc.IsNonDeposit__c, '検査対象取引先とお客様物件条件の敷金/保証金なしが不一致');
		System.assertEquals(apc.IsNonKeyMoney__c, acc.IsNonKeyMoney__c, '検査対象取引先とお客様物件条件の礼金なしが不一致');
		System.assertEquals(apc.IsNonCleaningFee__c, acc.IsNonCleaningFee__c, '検査対象取引先とお客様物件条件の定額修繕費なしが不一致');
		System.assertEquals(apc.IsNonRenewalFee__c, acc.IsNonRenewalFee__c, '検査対象取引先とお客様物件条件の更新料なしが不一致');
		System.assertEquals(apc.RentFeeFrom__c, acc.RentFeeFrom__c, '検査対象取引先とお客様物件条件の賃料からが不一致');
		System.assertEquals(apc.RentFeeTo__c, acc.RentFeeTo__c, '検査対象取引先とお客様物件条件の賃料までが不一致');
		System.assertEquals(apc.IsIncludeManagementFee__c, acc.IsIncludeManagementFee__c, '検査対象取引先とお客様物件条件の管理費込みが不一致');
		System.assertEquals(apc.IsIncludeParkingFee__c, acc.IsIncludeParkingFee__c, '検査対象取引先とお客様物件条件の駐車場代込みが不一致');
		System.assertEquals(apc.OccupancyAreaLowerLimit__c, acc.OccupancyAreaLowerLimit__c, '検査対象取引先とお客様物件条件の占有面積（下限）が不一致');
		System.assertEquals(apc.OccupancyAreaUpperLimit__c, acc.OccupancyAreaUpperLimit__c, '検査対象取引先とお客様物件条件の占有面積（上限）が不一致');
		System.assertEquals(apc.BuildingAge__c, acc.BuildingAge__c, '検査対象取引先とお客様物件条件の築年数が不一致');
		System.assertEquals(apc.IsDetachedHouse__c, acc.IsDetachedHouse__c, '検査対象取引先とお客様物件条件の戸建てが不一致');
		System.assertEquals(apc.IsMaisonette__c, acc.IsMaisonette__c, '検査対象取引先とお客様物件条件のメゾネットが不一致');
		System.assertEquals(apc.IsLoft__c, acc.IsLoft__c, '検査対象取引先とお客様物件条件のロフトが不一致');
		System.assertEquals(apc.IsDesigners__c, acc.IsDesigners__c, '検査対象取引先とお客様物件条件のデザイナーズが不一致');
		System.assertEquals(apc.IsRenovation__c, acc.IsRenovation__c, '検査対象取引先とお客様物件条件のリノベーションが不一致');
		System.assertEquals(apc.IsCondominiumRental__c, acc.IsCondominiumRental__c, '検査対象取引先とお客様物件条件の分譲賃貸が不一致');
		System.assertEquals(apc.IsAllWestern__c, acc.IsAllWestern__c, '検査対象取引先とお客様物件条件のオール洋間が不一致');
		System.assertEquals(apc.IsFirstFloor__c, acc.IsFirstFloor__c, '検査対象取引先とお客様物件条件の1階が不一致');
		System.assertEquals(apc.IsSecondFloorOver__c, acc.IsSecondFloorOver__c, '検査対象取引先とお客様物件条件の2階以上が不一致');
		System.assertEquals(apc.IsTopFloor__c, acc.IsTopFloor__c, '検査対象取引先とお客様物件条件の最上階が不一致');
		System.assertEquals(apc.IsCornerRoom__c, acc.IsCornerRoom__c, '検査対象取引先とお客様物件条件の角部屋が不一致');
		System.assertEquals(apc.IsBalcony__c, acc.IsBalcony__c, '検査対象取引先とお客様物件条件のバルコニーが不一致');
		System.assertEquals(apc.IsRoofBalcony__c, acc.IsRoofBalcony__c, '検査対象取引先とお客様物件条件のルーフバルコニーが不一致');
		System.assertEquals(apc.IsPrivateGarden__c, acc.IsPrivateGarden__c, '検査対象取引先とお客様物件条件の専用庭が不一致');
		System.assertEquals(apc.IsParking__c, acc.IsParking__c, '検査対象取引先とお客様物件条件の駐車場空きありが不一致');
		System.assertEquals(apc.IsInSiteParking__c, acc.IsInSiteParking__c, '検査対象取引先とお客様物件条件の敷地内駐車場が不一致');
		System.assertEquals(apc.IsPluralCarParking__c, acc.IsPluralCarParking__c, '検査対象取引先とお客様物件条件の駐車場2台可が不一致');
		System.assertEquals(apc.IsBuiltInGarage__c, acc.IsBuiltInGarage__c, '検査対象取引先とお客様物件条件のビルトインガレージが不一致');
		System.assertEquals(apc.IsCarport__c, acc.IsCarport__c, '検査対象取引先とお客様物件条件のカーポートが不一致');
		System.assertEquals(apc.IsBicycleParking__c, acc.IsBicycleParking__c, '検査対象取引先とお客様物件条件の駐輪場が不一致');
		System.assertEquals(apc.IsBikeStorage__c, acc.IsBikeStorage__c, '検査対象取引先とお客様物件条件のバイク可が不一致');
		System.assertEquals(apc.IsSmallBike__c, acc.IsSmallBike__c, '検査対象取引先とお客様物件条件の小型バイクが不一致');
		System.assertEquals(apc.IsMediumBike__c, acc.IsMediumBike__c, '検査対象取引先とお客様物件条件の中型バイクが不一致');
		System.assertEquals(apc.IsLargeBike__c, acc.IsLargeBike__c, '検査対象取引先とお客様物件条件の大型バイクが不一致');
		System.assertEquals(apc.IsElevator__c, acc.IsElevator__c, '検査対象取引先とお客様物件条件のエレベーターが不一致');
		System.assertEquals(apc.IsDeliveryBox__c, acc.IsDeliveryBox__c, '検査対象取引先とお客様物件条件の宅配ボックスが不一致');
		System.assertEquals(apc.IsCounterKitchen__c, acc.IsCounterKitchen__c, '検査対象取引先とお客様物件条件のカウンターキッチンが不一致');
		System.assertEquals(apc.IsSystemKitchen__c, acc.IsSystemKitchen__c, '検査対象取引先とお客様物件条件のシステムキッチンが不一致');
		System.assertEquals(apc.IsGasStove__c, acc.IsGasStove__c, '検査対象取引先とお客様物件条件のガスコンロが不一致');
		System.assertEquals(apc.IsElectricStove__c, acc.IsElectricStove__c, '検査対象取引先とお客様物件条件の電気コンロが不一致');
		System.assertEquals(apc.IsInductionHeating__c, acc.IsInductionHeating__c, '検査対象取引先とお客様物件条件のIHコンロが不一致');
		System.assertEquals(apc.IsTwoGasStove__c, acc.IsTwoGasStove__c, '検査対象取引先とお客様物件条件のコンロ2口が不一致');
		System.assertEquals(apc.IsMoreGasStove__c, acc.IsMoreGasStove__c, '検査対象取引先とお客様物件条件のコンロ3口以上が不一致');
		System.assertEquals(apc.IsSepalateBathAndRestroom__c, acc.IsSepalateBathAndRestroom__c, '検査対象取引先とお客様物件条件のバス・トイレ別が不一致');
		System.assertEquals(apc.IsAditionalBoiling__c, acc.IsAditionalBoiling__c, '検査対象取引先とお客様物件条件の追焚機能が不一致');
		System.assertEquals(apc.IsDehumidifierForBathroom__c, acc.IsDehumidifierForBathroom__c, '検査対象取引先とお客様物件条件の浴室乾燥機が不一致');
		System.assertEquals(apc.IsWashlet__c, acc.IsWashlet__c, '検査対象取引先とお客様物件条件の温水洗浄便座が不一致');
		System.assertEquals(apc.IsShowerWashBasin__c, acc.IsShowerWashBasin__c, '検査対象取引先とお客様物件条件のシャワー付き洗面台が不一致');
		System.assertEquals(apc.IsRegalLavatory__c, acc.IsRegalLavatory__c, '検査対象取引先とお客様物件条件の洗面所独立が不一致');
		System.assertEquals(apc.IsInnerLandry__c, acc.IsInnerLandry__c, '検査対象取引先とお客様物件条件の室内洗濯機置場が不一致');
		System.assertEquals(apc.IsTownGas__c, acc.IsTownGas__c, '検査対象取引先とお客様物件条件の都市ガスが不一致');
		System.assertEquals(apc.IsPropaneGas__c, acc.IsPropaneGas__c, '検査対象取引先とお客様物件条件のプロパンガスが不一致');
		System.assertEquals(apc.IsAllElectric__c, acc.IsAllElectric__c, '検査対象取引先とお客様物件条件のオール電化が不一致');
		System.assertEquals(apc.IsAirConditioner__c, acc.IsAirConditioner__c, '検査対象取引先とお客様物件条件のエアコンが不一致');
		System.assertEquals(apc.IsFloorHeating__c, acc.IsFloorHeating__c, '検査対象取引先とお客様物件条件の床暖房が不一致');
		System.assertEquals(apc.IsShoesBox__c, acc.IsShoesBox__c, '検査対象取引先とお客様物件条件のシューズボックスが不一致');
		System.assertEquals(apc.IsShoeCloak__c, acc.IsShoeCloak__c, '検査対象取引先とお客様物件条件のシューズクロークが不一致');
		System.assertEquals(apc.IsWalkInCloset__c, acc.IsWalkInCloset__c, '検査対象取引先とお客様物件条件のウォークインクローゼットが不一致');
		System.assertEquals(apc.IsTrunkRoom__c, acc.IsTrunkRoom__c, '検査対象取引先とお客様物件条件のトランクルームが不一致');
		System.assertEquals(apc.IsBSAntenna__c, acc.IsBSAntenna__c, '検査対象取引先とお客様物件条件のBSアンテナが不一致');
		System.assertEquals(apc.IsCSAntenna__c, acc.IsCSAntenna__c, '検査対象取引先とお客様物件条件のCSアンテナが不一致');
		System.assertEquals(apc.IsCATV__c, acc.IsCATV__c, '検査対象取引先とお客様物件条件のCATVが不一致');
		System.assertEquals(apc.IsInternetFree__c, acc.IsInternetFree__c, '検査対象取引先とお客様物件条件のネット使用料無料が不一致');
		System.assertEquals(apc.IsMonitorIntercom__c, acc.IsMonitorIntercom__c, '検査対象取引先とお客様物件条件のモニター付きインターホンが不一致');
		System.assertEquals(apc.IsAutoLock__c, acc.IsAutoLock__c, '検査対象取引先とお客様物件条件のオートロックが不一致');
		System.assertEquals(apc.IsFurniture__c, acc.IsFurniture__c, '検査対象取引先とお客様物件条件の家具付きが不一致');
		System.assertEquals(apc.IsHomeAppliance__c, acc.IsHomeAppliance__c, '検査対象取引先とお客様物件条件の家電付きが不一致');
		System.assertEquals(apc.IsNoGuarantor__c, acc.IsNoGuarantor__c, '検査対象取引先とお客様物件条件の保証人不要が不一致');
		System.assertEquals(apc.IsNonGuaranteeidCompany__c, acc.IsNonGuaranteeidCompany__c, '検査対象取引先とお客様物件条件の保証会社不要が不一致');
		System.assertEquals(apc.IsMusicalInstruments__c, acc.IsMusicalInstruments__c, '検査対象取引先とお客様物件条件の楽器相談可が不一致');
		System.assertEquals(apc.IsForeigner__c, acc.IsForeigner__c, '検査対象取引先とお客様物件条件の外国人契約可が不一致');
		System.assertEquals(apc.IsOfficeAvailable__c, acc.IsOfficeAvailable__c, '検査対象取引先とお客様物件条件の事務所利用可が不一致');
		System.assertEquals(apc.IsWelfareAvailable__c, acc.IsWelfareAvailable__c, '検査対象取引先とお客様物件条件の生活保護契約可が不一致');
		System.assertEquals(apc.IsPet__c, acc.IsPet__c, '検査対象取引先とお客様物件条件のペット可が不一致');
		System.assertEquals(apc.IsLargePet__c, acc.IsLargePet__c, '検査対象取引先とお客様物件条件のペット(大型犬)が不一致');
		System.assertEquals(apc.IsMiddlePet__c, acc.IsMiddlePet__c, '検査対象取引先とお客様物件条件のペット(中型犬)が不一致');
		System.assertEquals(apc.IsSmallPet__c, acc.IsSmallPet__c, '検査対象取引先とお客様物件条件のペット(小型犬)が不一致');
		System.assertEquals(apc.IsCat__c, acc.IsCat__c, '検査対象取引先とお客様物件条件のペット(猫)が不一致');
		System.assertEquals(apc.IsOtherPet__c, acc.IsOtherPet__c, '検査対象取引先とお客様物件条件のペット(その他)が不一致');
		System.assertEquals(apc.IsTwoTenant__c, acc.IsTwoTenant__c, '検査対象取引先とお客様物件条件の2人入居可が不一致');
		System.assertEquals(apc.IsRoomShare__c, acc.IsRoomShare__c, '検査対象取引先とお客様物件条件のルームシェア可が不一致');
		System.assertEquals(apc.IsIppambutsu__c, acc.IsIppambutsu__c, '検査対象取引先とお客様物件条件の一般物が不一致');
		System.assertEquals(apc.IsElderly__c, acc.IsElderly__c, '検査対象取引先とお客様物件条件の高齢者歓迎が不一致');
		System.assertEquals(apc.IsWoman__c, acc.IsWoman__c, '検査対象取引先とお客様物件条件の女性限定が不一致');
		System.assertEquals(apc.IsStudent__c, acc.IsStudent__c, '検査対象取引先とお客様物件条件の学生限定マンションが不一致');
		System.assertEquals(apc.CarCount__c, acc.CarCount__c, '検査対象取引先とお客様物件条件の台数が不一致');
		System.assertEquals(apc.ParkingFeeLimit__c, acc.ParkingFeeLimit__c, '検査対象取引先とお客様物件条件の1台当たりの料金上限が不一致');
		System.assertEquals(apc.Parking__c, acc.Parking__c, '検査対象取引先とお客様物件条件の駐車場が不一致');
		System.assertEquals(apc.DesiredJuniorHighSchoolArea__c, acc.DesiredJuniorHighSchoolArea__c, '検査対象取引先とお客様物件条件の中学校希望学区（エリア）が不一致');
		System.assertEquals(apc.DesiredElementarySchoolArea__c, acc.DesiredElementarySchoolArea__c, '検査対象取引先とお客様物件条件の小学校希望学区（エリア）が不一致');
	}
	// ▲2021.10.08 No.307 対応で追加
	// ▼ 2022.2.3 LINE連携対応より、追加
	/**
	 * 空室予約物件の取得
	 * @param Id condAccountId 取引先ID
	 * @return List<VacancyReservationProperty__c> 空室予約物件
	 */
	private static List<VacancyReservationProperty__c> selectVacancyReservationProperty(Id condAccountId) {

		List<VacancyReservationProperty__c> vrpList = [
			SELECT Id
			FROM VacancyReservationProperty__c
			WHERE Account__c = :condAccountId
		];

		return vrpList;
	}

	/**
	 * LINE会員の取得
	 * @param Id condAccountId 取引先ID
	 * @return List<LineMember__c> LINE会員
	 */
	private static List<LineMember__c> selectLineMember(Id condAccountId) {

		List<LineMember__c> lineMemberList = [
			SELECT Id
			FROM LineMember__c
			WHERE Account__c = :condAccountId
		];

		return lineMemberList;
	}

	/**
	 * LINE会員候補の取得
	 * @param Id condAccountId 取引先ID
	 * @return List<LineMemberCandidate__c> LINE会員候補
	 */
	private static List<LineMemberCandidate__c> selectLineMemberCandidate(Id condAccountId) {

		List<LineMemberCandidate__c> lineMemberCandidateList = [
			SELECT Id
			FROM LineMemberCandidate__c
			WHERE Account__c = :condAccountId
		];

		return lineMemberCandidateList;
	}
}