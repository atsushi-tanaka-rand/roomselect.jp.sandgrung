/**
 * 対応一覧画面テスト
 */
 @isTest
public with sharing class GA101001Test {

    /**
    * テストに使用するレコードを作成する
    */
    @TestSetup static void setting(){

        system.debug('初期設定開始');

        //標準プロファイルを取得
        Id profileId = [SELECT Id FROM Profile WHERE Name = '一般ユーザ'].id;

        // 建物
        Building__c BuildingRecord = new Building__c( Name = '対応テスト建物'   // 建物名
                                                    , District__c = '港区'      // 地区
        );       

        // 物件
        Property__c PropertyRecord = new Property__c( Name = '101'                      // 部屋番号
                                                    , Building__c = BuildingRecord.Id   // 建物
                                                    , LivedType__c = '未入居'           // 未入居種別
                                                    , LiveStatus__c = '空室'            // 現況
                                                    , RoomLayout__c = 'DK'              // 間取り
        );    

        // -----------------------------------------------------------------------------------------------
        // 通常のユーザ
        // -----------------------------------------------------------------------------------------------
        //一般ユーザの登録（店舗）
        User testUser = new User(LastName = 'ippanUser'                     //姓
                                ,Alias =  'alias'                           //別名
                                ,Email = 'ippanUser@test.com'               //メール
                                ,UserName =  'ippanUser@test.com'           //ユーザ名
                                ,CommunityNickname ='テストニックネーム'     //ニックネーム
                                ,EmailEncodingKey = 'ISO-2022-JP'           //メールの文字コード
                                ,TimeZoneSidKey = 'Asia/Tokyo'              //タイムゾーン
                                ,LocaleSidKey = 'ja_JP'                     //地域
                                ,LanguageLocaleKey= 'ja'                    //言語
                                ,ProfileId = profileId                      //プロファイルID
        );
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            insert testUser;      
        }
		//一般ユーザの登録（店舗）
		User testUser2 = new User(LastName = 'ippanUser2'	//姓
			,Alias =  'alias'								//別名
			,Email = 'ippanUser2@test.com'					//メール
			,UserName =  'ippanUser2@test.com'				//ユーザ名
			,CommunityNickname ='テストニックネーム2'		 //ニックネーム
			,EmailEncodingKey = 'ISO-2022-JP'				//メールの文字コード
			,TimeZoneSidKey = 'Asia/Tokyo'					//タイムゾーン
			,LocaleSidKey = 'ja_JP'							//地域
			,LanguageLocaleKey= 'ja'						//言語
			,ProfileId = profileId							//プロファイルID
		);
		System.runAs(thisUser){
			insert testUser2;      
		}
        
        // 取引先
        Account AccountRecord = new Account(Name = 'テスト太郎'                //取引先名
											,NameKana__c = 'ﾃｽﾄﾀﾛｳ'            //取引先名（カナ）
											,Phone = '025-200-1234'            //電話番号
											,Email__c = 'aaa@hora'             // メール
											,state__c = '大阪府'               //都道府県
											,city__c = '大阪市'                //住所１（市区町村）
											,street__c = '中央区安土町４－１'   //住所２（番地）
											,RecordTypeId = commonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER) //レコードタイプID（顧客）
        );
        insert AccountRecord; 

        // 店舗データ
        Shop__c ippanShopRecord = new Shop__c(Name     = '店舗ユーザテスト_港区'     // 店舗名
                                            , Phone__c = '000-0000-0000'            // 電話番号
                                            , Fax__c   = '000-0000-0000'            // FAX
                                            , Email__c = 'minato@test.AccountShoninShinseiWebservice.com' // メール
                                            , PortalSitePostingDistrict__c = '港区' // ポータル掲載地区
                                            , District__c = '港区'                  // 所在地区
                                            , IsShopType__c = True                  // 店舗区分
        );    
        insert ippanShopRecord;   

        // 組織階層レコード
        OrganizationHierarchy__c orgRecord1 = new OrganizationHierarchy__c(
            OrganizationCode__c = '0001',
            OrganizationName__c = '本部',
            HierarchyCode__c = '10',
            HierarchyOrder__c = 1,
            UpperOrganizationHierarchy__c = null,
            ExpandedOrganizationCode__c = '0000_0001',
            Shop__c = null
        );
        insert orgRecord1;
        OrganizationHierarchy__c orgRecord2 = new OrganizationHierarchy__c(
            OrganizationCode__c = '0002',
            OrganizationName__c = '店舗ユーザテスト_港区',
            HierarchyCode__c = '20',
            HierarchyOrder__c = 1,
            UpperOrganizationHierarchy__c = orgRecord1.Id,
            ExpandedOrganizationCode__c = '0000_0001_0002',
            Shop__c = ippanShopRecord.Id
        );
        insert orgRecord2;

        // 対応データ
        Correspond__c CorrespondRecord = new Correspond__c(AccountId__c            = AccountRecord.Id           // 取引先
                                                        ,Property__c               = PropertyRecord.Id          // 物件
                                                        ,Status__c                 = commonConst.CORRESPOND_STATUS_NOTSUPPORTED  // ステータス（未対応）
                                                        ,EventDateTime__c          =  Date.valueOf('2020-1-5')  // イベント時刻
                                                        ,IsSupportedListShow__c    = True                       // 対応確認
                                                        ,EchoStaff__c              = testUser.Id                // 担当者（反響）
                                                        ,EchoShop__c               = ippanShopRecord.Id         // 反響担当店舗
                                                        ,ShopStaff__c              = testUser.Id                // 担当者（店舗）
                                                        ,VisitShop__c              = ippanShopRecord.Id         // 来店担当店舗
                                                        ,ListViewDate__c           = Date.valueOf('2020-1-1')   // 一覧表示日時
                                                        ,ReceiveMailDateOther__c   = Date.valueOf('2020-1-1')   // メール受信日時（その他）

		);
        insert CorrespondRecord;
		// 対応データ
		Correspond__c CorrespondRecord2 = new Correspond__c(
			AccountId__c            = AccountRecord.Id           // 取引先
			,Property__c			= PropertyRecord.Id          // 物件
			,Status__c				= commonConst.CORRESPOND_STATUS_NOTSUPPORTED  // ステータス（未対応）
			,EventDateTime__c		=  Date.valueOf('2020-1-5')  // イベント時刻
			,IsSupportedListShow__c	= True                       // 対応確認
			,EchoStaff__c			= testUser.Id                // 担当者（反響）
			,EchoShop__c			= ippanShopRecord.Id         // 反響担当店舗
			,ShopStaff__c			= testUser.Id                // 担当者（店舗）
			,VisitShop__c			= ippanShopRecord.Id         // 来店担当店舗
			,ListViewDate__c		= Date.valueOf('2020-1-1')   // 一覧表示日時
			,ReceiveMailDateOther__c= Date.valueOf('2020-1-1')   // メール受信日時（その他）
		);
		insert CorrespondRecord2;

        // 店舗異動データ（ユーザと店舗の紐づけ）
        ShopTransfer__c ShopTransferRecord = new ShopTransfer__c(OrgzanizationHierarchy__c = orgRecord2.id  //組織階層
                                                    ,StartDate__c =    Date.valueOf('2020-1-5')             //開始日
                                                    ,EndDate__c   =    Date.valueOf('2040-1-5')             //終了日
                                                    ,Staff__c     =   testUser.Id                           //ユーザ
                                                    );                            
        insert ShopTransferRecord; 
		// 店舗異動データ（ユーザと店舗の紐づけ）
		ShopTransfer__c ShopTransferRecord2 = new ShopTransfer__c(
			OrgzanizationHierarchy__c = orgRecord2.id	//組織階層
			,StartDate__c =    Date.valueOf('2020-1-5')	//開始日
			,EndDate__c   =    Date.valueOf('2040-1-5')	//終了日
			,Staff__c     =   testUser2.Id				//ユーザ
			);                            
		insert ShopTransferRecord2; 

        // -----------------------------------------------------------------------------------------------
        //一般ユーザ（0件）
        // -----------------------------------------------------------------------------------------------
        User testUserNothng = new User(LastName = 'ippanUserNothing'    //姓
                    ,Alias =  'alias'                                   //別名
                    ,Email = 'ippanUserNothing@test.com'                //メール
                    ,UserName =  'ippanUserNothing@test.com'            //ユーザ名
                    ,CommunityNickname ='テストニックネーム０件'         //ニックネーム
                    ,EmailEncodingKey = 'ISO-2022-JP'                   //メールの文字コード
                    ,TimeZoneSidKey = 'Asia/Tokyo'                      //タイムゾーン
                    ,LocaleSidKey = 'ja_JP'                             //地域
                    ,LanguageLocaleKey= 'ja'                            //言語
                    ,ProfileId = profileId                              //プロファイルID
        );
        System.runAs(thisUser){
            insert testUserNothng; 
        }
        
        // 店舗異動データなしデータ用（ユーザと店舗の紐づけ）
        ShopTransfer__c ShopTransferRecordNothong = new ShopTransfer__c(OrgzanizationHierarchy__c = orgRecord2.id  //組織階層
                                                    ,StartDate__c =    Date.valueOf('2020-1-5')                 //開始日
                                                    ,EndDate__c   =    Date.valueOf('2040-1-5')                 //終了日
                                                    ,Staff__c     =   testUserNothng.Id                         //ユーザ
                                                    );                            
        insert ShopTransferRecordNothong;
        



        // -----------------------------------------------------------------------------------------------
        // インサイドセールスのデータ
        // -----------------------------------------------------------------------------------------------      
        // 一般ユーザの登録（IS）
        User testUserIs = new User(LastName = 'ISUser'                      //姓
                                ,Alias =  'alias'                           //別名
                                ,Email = 'testuseris@test.com'              //メール
                                ,UserName =  'testuseris@test.com'          //ユーザ名
                                ,CommunityNickname ='インサイドセールス'     //ニックネーム
                                ,EmailEncodingKey = 'ISO-2022-JP'           //メールの文字コード
                                ,TimeZoneSidKey = 'Asia/Tokyo'              //タイムゾーン
                                ,LocaleSidKey = 'ja_JP'                     //地域
                                ,LanguageLocaleKey= 'ja'                    //言語
                                ,ProfileId = profileId                      //プロファイルID
        );
        System.runAs(thisUser){
            insert testUserIs; 
        }
		 // 一般ユーザの登録（IS2）
		 User testUserIs2 = new User(LastName = 'ISUser2'	//姓
				,Alias =  'alias'                           //別名
				,Email = 'testuseris2@test.com'				//メール
				,UserName =  'testuseris2@test.com'			//ユーザ名
				,CommunityNickname ='インサイドセールス2'	//ニックネーム
				,EmailEncodingKey = 'ISO-2022-JP'           //メールの文字コード
				,TimeZoneSidKey = 'Asia/Tokyo'              //タイムゾーン
				,LocaleSidKey = 'ja_JP'                     //地域
				,LanguageLocaleKey= 'ja'                    //言語
				,ProfileId = profileId                      //プロファイルID
		);
		System.runAs(thisUser){
			insert testUserIs2; 
		}
        
        // 店舗データ
        Shop__c ippanShopRecordIs = new Shop__c(Name     = 'IS店舗ユーザテスト_港区'    // 店舗名
                                            , Phone__c = '000-0000-0000'               // 電話番号
                                            , Fax__c   = '000-0000-0000'               // FAX
                                            , Email__c = 'minato@test.AccountShoninShinseiWebservice.com' // メール
                                            , PortalSitePostingDistrict__c = '港区'    // ポータル掲載地区
                                            , District__c = '港区'                     // 所在地区
                                            , IsShopType__c = False                    // 店舗区分
        );    
        insert ippanShopRecordIs;  

        // 組織階層データ
        OrganizationHierarchy__c orgRecord3 = new OrganizationHierarchy__c(
            OrganizationCode__c = '0003',
            OrganizationName__c = 'IS店舗ユーザテスト_港区',
            HierarchyCode__c = '20',
            HierarchyOrder__c = 2,
            UpperOrganizationHierarchy__c = orgRecord1.Id,
            ExpandedOrganizationCode__c = '0000_0001_0003',
            Shop__c = ippanShopRecordIs.Id
        );
        insert orgRecord3;

        // 取引先
        Account AccountRecordIs = new Account(Name = 'ISテスト太郎',            //取引先名
											   NameKana__c = 'ISﾃｽﾄﾀﾛｳ',        //取引先名（カナ）
											   Phone = '025-200-0000',          //電話番号
											   Email__c = 'aaa@hora',           // メール
											   state__c = '大阪府',             //都道府県
											   city__c = '大阪市',              //住所１（市区町村）
											   street__c = '中央区安土町４－１', //住所２（番地）
											   RecordTypeId = commonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER)   //レコードタイプID（顧客）
        );
        insert AccountRecordIs;

        // 対応データ（IS）
        Correspond__c CorrespondRecordIs = new Correspond__c(AccountId__c       = AccountRecordIs.Id        // 取引先
                                                        ,Property__c            = PropertyRecord.Id         // 物件
                                                        ,Status__c              = commonConst.CORRESPOND_STATUS_APOCANCEL  // ステータス（アポイントキャンセル）
                                                        ,EventDateTime__c       =  Date.valueOf('2020-1-5') // イベント時刻
                                                        ,IsSupportedListShow__c = True                      // 対応確認
                                                        ,EchoStaff__c           = testUserIS.Id             // 担当者（反響）
                                                        ,EchoShop__c            = ippanShopRecordIs.Id      // 反響担当店舗
                                                        ,ShopStaff__c           = testUserIs.Id             // 担当者（来店）
                                                        ,VisitShop__c           = ippanShopRecordIs.Id      // 来店担当店舗
                                                        ,ListViewDate__c        = Date.valueOf('2020-1-1')  // 一覧表示日時
                                                        ,ReceiveMailDateOther__c   = Date.valueOf('2020-1-1')   // メール受信日時（その他）
                                                        );
        insert CorrespondRecordIs;
		// 対応データ（IS）
		Correspond__c CorrespondRecordIs2 = new Correspond__c(AccountId__c       = AccountRecordIs.Id        // 取引先
			,Property__c            = PropertyRecord.Id         // 物件
			,Status__c              = commonConst.CORRESPOND_STATUS_APOCANCEL  // ステータス（アポイントキャンセル）
			,EventDateTime__c       =  Date.valueOf('2020-1-5') // イベント時刻
			,IsSupportedListShow__c = True                      // 対応確認
			,EchoStaff__c           = testUserIS2.Id             // 担当者（反響）
			,EchoShop__c            = ippanShopRecordIs.Id      // 反響担当店舗
			,ShopStaff__c           = testUserIs2.Id             // 担当者（来店）
			,VisitShop__c           = ippanShopRecordIs.Id      // 来店担当店舗
			,ListViewDate__c        = Date.valueOf('2020-1-1')  // 一覧表示日時
			,ReceiveMailDateOther__c   = Date.valueOf('2020-1-1')   // メール受信日時（その他）
		);
		insert CorrespondRecordIs2;

        // 店舗異動データ（ユーザと店舗の紐づけ）
        ShopTransfer__c ShopTransferRecordIs = new ShopTransfer__c(
			OrgzanizationHierarchy__c = orgRecord3.id  //組織階層
			,StartDate__c =    Date.valueOf('2020-1-5')               //開始日
			,EndDate__c   =    Date.valueOf('2040-1-5')               //終了日
			,Staff__c     =   testUserIs.Id                           //ユーザ
        );                            
        insert ShopTransferRecordIs;
		// 店舗異動データ（ユーザと店舗の紐づけ）
		ShopTransfer__c ShopTransferRecordIs2 = new ShopTransfer__c(
			OrgzanizationHierarchy__c = orgRecord3.id  //組織階層
			,StartDate__c =    Date.valueOf('2020-1-5')               //開始日
			,EndDate__c   =    Date.valueOf('2040-1-5')               //終了日
			,Staff__c     =   testUserIs2.Id                           //ユーザ
		);                            
		insert ShopTransferRecordIs2;


        system.debug('初期設定終了');        
    }


    /**
     * 初期表示テスト(更新)
     */
     @isTest static void initializeTest(){
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

		// 一覧の内容をSQLで取得
		Correspond__c testTargetRecord = [
			SELECT Name            // 対応.対応番号（非表示）
			,AccountId__r.ParentId   // 対応.取引先ID（非表示）
			,AccountId__r.Name       // 対応.取引先 ID.取引先名
			,Status__c               // 対応.ステータス
			,Event__c                // 対応.イベント
			,EventDateTime__c        // 対応.イベント時刻
			,ShopStaff__r.Username   // 対応.担当者（店舗）.ユーザ名
			,ShopStaff__r.Name       // 対応.担当者（店舗）.氏名
			,ShopStaff__r.Department // 対応.ユーザ.部署
			,PortalSite__r.Name      // 対応.ポータルサイト.サイト名
			,EchoShop__r.Name        // 対応.反響担当店舗.店舗名
			,AccountId__r.Phone      // 対応.取引先 ID.電話番号
			,Memo__c                 // 対応.メモ
			FROM  Correspond__c         
			WHERE ShopStaff__r.Username = 'ippanUser@test.com' 
			LIMIT 1
		];


        System.runAs(ippanUser){
            try {
                //コントローラ作成
                GA101001Controller testController = new GA101001Controller();

                // 一覧の項目が設定されている
                System.assertEquals(testTargetRecord.AccountId__c            , testController.screenTargetRecordList[0].AccountIdParentId);
                System.assertEquals(testTargetRecord.AccountId__r.Name       , testController.screenTargetRecordList[0].AccountIdName);
                System.assertEquals(testTargetRecord.Status__c               , testController.screenTargetRecordList[0].Status);
                System.assertEquals(testTargetRecord.Event__c                , testController.screenTargetRecordList[0].Event);
                System.assertEquals(string.valueOf(testTargetRecord.EventDateTime__c.format('yyyy/MM/dd HH:mm', 'JST')) , 
                                    string.valueOf(testController.screenTargetRecordList[0].EventDateTime));
                System.assertEquals(testTargetRecord.ShopStaff__r.Username   , testController.screenTargetRecordList[0].shopStaffUsername);
                System.assertEquals(testTargetRecord.ShopStaff__r.Name       , testController.screenTargetRecordList[0].shopStaffName);
                System.assertEquals(testTargetRecord.ShopStaff__r.Department , testController.screenTargetRecordList[0].shopStaffDepartment);
                System.assertEquals(testTargetRecord.PortalSite__r.Name      , testController.screenTargetRecordList[0].PortalSiteName);
                System.assertEquals(testTargetRecord.AccountId__r.Phone      , testController.screenTargetRecordList[0].AccountIdPhone);
                System.assertEquals(testTargetRecord.Memo__c                 , testController.screenTargetRecordList[0].Memo);

            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }

     }

    /**
     * 検索ボタン押下 ※一般ユーザ
     */
    @isTest static void CorrespondListIppanTest(){
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

        // 一覧の内容をSQLで取得
		Correspond__c testTargetRecord = [
			SELECT Name            // 対応.対応番号（非表示）
			,AccountId__r.ParentId   // 対応.取引先ID（非表示）
			,AccountId__r.Name       // 対応.取引先 ID.取引先名
			,Status__c               // 対応.ステータス
			,Event__c                // 対応.イベント
			,EventDateTime__c        // 対応.イベント時刻
			,ShopStaff__r.Username   // 対応.担当者（店舗）.ユーザ名
			,ShopStaff__r.Name       // 対応.担当者（店舗）.氏名
			,ShopStaff__r.Department // 対応.ユーザ.部署
			,PortalSite__r.Name      // 対応.ポータルサイト.サイト名
			,EchoShop__r.Name        // 対応.反響担当店舗.店舗名
			,AccountId__r.Phone      // 対応.取引先 ID.電話番号
			,Memo__c                 // 対応.メモ
			FROM  Correspond__c         
			WHERE ShopStaff__r.Username = 'ippanUser@test.com' 
			LIMIT 1
        ];
        
        System.runAs(ippanUser){
            try {
                // 検索ボタン処理
                //コントローラ作成
                GA101001Controller testController = new GA101001Controller();
                testController.getCorrespondList();

                // 一覧の項目が設定されている
                System.assertEquals(testTargetRecord.AccountId__c            , testController.screenTargetRecordList[0].AccountIdParentId);
                System.assertEquals(testTargetRecord.AccountId__r.Name       , testController.screenTargetRecordList[0].AccountIdName);
                System.assertEquals(testTargetRecord.Status__c               , testController.screenTargetRecordList[0].Status);
                System.assertEquals(testTargetRecord.Event__c                , testController.screenTargetRecordList[0].Event);
                System.assertEquals(string.valueOf(testTargetRecord.EventDateTime__c.format('yyyy/MM/dd HH:mm', 'JST')) , 
                                    string.valueOf(testController.screenTargetRecordList[0].EventDateTime));
                System.assertEquals(testTargetRecord.ShopStaff__r.Username   , testController.screenTargetRecordList[0].shopStaffUsername);
                System.assertEquals(testTargetRecord.ShopStaff__r.Name       , testController.screenTargetRecordList[0].shopStaffName);
                System.assertEquals(testTargetRecord.ShopStaff__r.Department , testController.screenTargetRecordList[0].shopStaffDepartment);
                System.assertEquals(testTargetRecord.PortalSite__r.Name      , testController.screenTargetRecordList[0].PortalSiteName);
                System.assertEquals(testTargetRecord.AccountId__r.Phone      , testController.screenTargetRecordList[0].AccountIdPhone);
                System.assertEquals(testTargetRecord.Memo__c                 , testController.screenTargetRecordList[0].Memo);


            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }

        //一般ユーザで実行0件
        User ippanUserNothing = [SELECT Id 
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
                            WHERE LastName = 'ippanUserNothing' 
                ];
        
        System.runAs(ippanUserNothing){
            try {
                //コントローラ作成
                GA101001Controller testController = new GA101001Controller();
            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
    }

    
    /**
     * 検索ボタン押下 ※IS用
     */
    @isTest static void CorrespondListIsTest(){
        // インサイドセールスのユーザで実行
        User isUser = [SELECT Id 
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
                            WHERE LastName = 'ISUser' 
                ];

        // 一覧の内容をSQLで取得
		Correspond__c testTargetRecordIs = [SELECT Name            // 対応.対応番号（非表示）
                                        ,AccountId__r.ParentId   // 対応.取引先ID（非表示）
                                        ,AccountId__r.Name       // 対応.取引先 ID.取引先名
                                        ,Status__c               // 対応.ステータス
                                        ,Event__c                // 対応.イベント
                                        ,EventDateTime__c        // 対応.イベント時刻
                                        ,ShopStaff__r.Username   // 対応.担当者（店舗）.ユーザ名
                                        ,ShopStaff__r.Name       // 対応.担当者（店舗）.氏名
                                        ,ShopStaff__r.Department // 対応.ユーザ.部署
                                        ,PortalSite__r.Name      // 対応.ポータルサイト.サイト名
                                        ,EchoShop__r.Name        // 対応.反響担当店舗.店舗名
                                        ,AccountId__r.Phone      // 対応.取引先 ID.電話番号
                                        ,Memo__c                 // 対応.メモ
                                        FROM  Correspond__c         
								        WHERE ShopStaff__r.Username = 'testuseris@test.com' 
        ];
        System.runAs(isUser){
            try {
                //コントローラ作成
                GA101001Controller testController = new GA101001Controller();     

                // 一覧の項目が設定されている
                System.assertEquals(testTargetRecordIs.AccountId__c            , testController.screenTargetRecordList[0].AccountIdParentId);
                System.assertEquals(testTargetRecordIs.AccountId__r.Name       , testController.screenTargetRecordList[0].AccountIdName);
                System.assertEquals(testTargetRecordIs.Status__c               , testController.screenTargetRecordList[0].Status);
                System.assertEquals(testTargetRecordIs.Event__c                , testController.screenTargetRecordList[0].Event);
                System.assertEquals(string.valueOf(testTargetRecordIs.EventDateTime__c.format('yyyy/MM/dd HH:mm', 'JST')) , 
                                    string.valueOf(testController.screenTargetRecordList[0].EventDateTime));
                System.assertEquals(testTargetRecordIs.ShopStaff__r.Username   , testController.screenTargetRecordList[0].shopStaffUsername);
                System.assertEquals(testTargetRecordIs.ShopStaff__r.Name       , testController.screenTargetRecordList[0].shopStaffName);
                System.assertEquals(testTargetRecordIs.ShopStaff__r.Department , testController.screenTargetRecordList[0].shopStaffDepartment);
                System.assertEquals(testTargetRecordIs.PortalSite__r.Name      , testController.screenTargetRecordList[0].PortalSiteName);
                System.assertEquals(testTargetRecordIs.AccountId__r.Phone      , testController.screenTargetRecordList[0].AccountIdPhone);
                System.assertEquals(testTargetRecordIs.Memo__c                 , testController.screenTargetRecordList[0].Memo); 

            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
    }


    @isTest static void getStaffListTest() {


          //一般ユーザで実行0件
        User ippanUserNothing = [SELECT Id 
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
                            WHERE LastName = 'ippanUserNothing' 
                ];
        
        System.runAs(ippanUserNothing){
            try {
                //コントローラ作成
                GA101001Controller testController = new GA101001Controller();
                testController.getStaffList();
            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
    }

	/**
	 * 初期表示時
	 * 一覧（IS）
	 * 検索結果が対象店舗と問合せメールのみで来店担当者で絞り込まれないこと
	 */
	@isTest static void initialDisplayIS(){
		// インサイドセールスのユーザで実行
		User isUser = [SELECT Id 
				FROM User
				WHERE LastName = 'ISUser' 
		];
		Shop__c isShop = [
			SELECT Id 
			FROM   Shop__c
			WHERE  Name    = 'IS店舗ユーザテスト_港区'
			LIMIT  1
		];
		Map<Id,Correspond__c> correspondMap = new Map<Id,Correspond__c>([
			SELECT Id FROM Correspond__c
			WHERE VisitShop__c = :isShop.id
		]);
		
		System.runAs(isUser){
			Test.startTest();
			//コントローラ作成
			GA101001Controller testController = new GA101001Controller();


			Test.stopTest();

			// ISのデータのみ
			for (GA101001Controller.ScreenCorrespond screenTargetRecord : testController.screenTargetRecordList) {
				System.assertEquals(true,correspondMap.containsKey(screenTargetRecord.Id));
			}				
			// ユーザ情報
			System.assertEquals('',testController.shopStaff);
		}
	}

	/**
	 * 初期表示時
	 * 一覧（店舗スタッフ）
	 * 検索結果が対象店舗と問合せメールのみで来店担当者で絞り込まれないこと
	 */
	@isTest static void initialDisplayShop(){
		// 店舗のユーザで実行
		User shopUser = [SELECT Id 
				FROM User
				WHERE LastName = 'ippanUser' 
		];
		Shop__c ippanShop = [
			SELECT Id 
			FROM   Shop__c
			WHERE  Name    = '店舗ユーザテスト_港区'
			LIMIT  1
		];
		Map<Id,Correspond__c> correspondMap = new Map<Id,Correspond__c>([
			SELECT Id FROM Correspond__c
			WHERE VisitShop__c = :ippanShop.id
		]);
		
		System.runAs(shopUser){
			Test.startTest();
			//コントローラ作成
			GA101001Controller testController = new GA101001Controller();


			Test.stopTest();

			// 店舗のデータのみ
			for (GA101001Controller.ScreenCorrespond screenTargetRecord : testController.screenTargetRecordList) {
				System.assertEquals(true,correspondMap.containsKey(screenTargetRecord.Id));
			}				
			// ユーザ情報
			System.assertEquals('',testController.shopStaff);
		}
	}

	/**
	 * 検索ボタン押下時
	 * 担当者無し、一覧（IS）
	 * 検索結果が対象店舗と問合せメールのみで来店担当者で絞り込まれないこと
	 */
	@isTest static void searchButtonISShopOnly(){
		// インサイドセールスのユーザで実行
		User isUser = [SELECT Id 
				FROM User
				WHERE LastName = 'ISUser' 
		];
		Shop__c isShop = [
			SELECT Id 
			FROM   Shop__c
			WHERE  Name    = 'IS店舗ユーザテスト_港区'
			LIMIT  1
		];
		Map<Id,Correspond__c> correspondMap = new Map<Id,Correspond__c>([
			SELECT Id FROM Correspond__c
			WHERE VisitShop__c = :isShop.id
		]);
		
		System.runAs(isUser){
			Test.startTest();
			//コントローラ作成
			GA101001Controller testController = new GA101001Controller();
			// 検索押下
			testController.getCorrespondList();

			Test.stopTest();

			// ISのデータのみ
			for (GA101001Controller.ScreenCorrespond screenTargetRecord : testController.screenTargetRecordList) {
				System.assertEquals(true,correspondMap.containsKey(screenTargetRecord.Id));
			}				
			// ユーザ情報
			System.assertEquals('',testController.shopStaff);
		}
	}

	/**
	 * 検索ボタン押下時
	 * 担当者無し、一覧（店舗スタッフ）
	 * 検索結果が対象店舗と問合せメールのみで来店担当者で絞り込まれないこと
	 */
	@isTest static void searchButtonShopOnly(){
		// 店舗のユーザで実行
		User shopUser = [SELECT Id 
				FROM User
				WHERE LastName = 'ippanUser' 
		];
		Shop__c ippanShop = [
			SELECT Id 
			FROM   Shop__c
			WHERE  Name    = '店舗ユーザテスト_港区'
			LIMIT  1
		];
		Map<Id,Correspond__c> correspondMap = new Map<Id,Correspond__c>([
			SELECT Id FROM Correspond__c
			WHERE VisitShop__c = :ippanShop.id
		]);
		
		System.runAs(shopUser){
			Test.startTest();
			//コントローラ作成
			GA101001Controller testController = new GA101001Controller();
			// 検索押下
			testController.getCorrespondList();

			Test.stopTest();

			// 店舗のデータのみ
			for (GA101001Controller.ScreenCorrespond screenTargetRecord : testController.screenTargetRecordList) {
				System.assertEquals(true,correspondMap.containsKey(screenTargetRecord.Id));
			}				
			// ユーザ情報
			System.assertEquals('',testController.shopStaff);
		}
	}

	/**
	 * 検索ボタン押下時
	 * 担当者有り、一覧（IS）
	 * 検索結果が対象店舗と来店担当者で絞り込まれた内容と問合せメールでの表示となること
	 */
	@isTest static void searchButtonIS(){
		// インサイドセールスのユーザで実行
		User isUser = [SELECT Id 
			FROM User
			WHERE LastName = 'ISUser' 
		];
		Shop__c isShop = [
			SELECT Id 
			FROM   Shop__c
			WHERE  Name    = 'IS店舗ユーザテスト_港区'
			LIMIT  1
		];
		Map<Id,Correspond__c> correspondMap = new Map<Id,Correspond__c>([
			SELECT Id FROM Correspond__c
			WHERE ShopStaff__c = :isUser.id	
		]);
		User iSUser2 = [SELECT Id 
			FROM User
			WHERE LastName = 'ISUser2' 
		];
		Map<Id,Correspond__c> correspondNotRunMap = new Map<Id,Correspond__c>([
			SELECT Id FROM Correspond__c
			WHERE ShopStaff__c = :iSUser2.id
		]);

		System.runAs(isUser){
			Test.startTest();
			//コントローラ作成
			GA101001Controller testController = new GA101001Controller();
			// 担当者設定
			testController.shopStaff = isUser.id;

			// 検索押下
			testController.getCorrespondList();

			Test.stopTest();

			// ISのデータのみ
			for (GA101001Controller.ScreenCorrespond screenTargetRecord : testController.screenTargetRecordList) {
				System.assertEquals(true,correspondMap.containsKey(screenTargetRecord.Id));

				System.assertEquals(false,correspondNotRunMap.containsKey(screenTargetRecord.Id));
			}				
			// ユーザ情報
			System.assertEquals(isUser.id,testController.shopStaff);
		}
	}

	/**
	 * 検索ボタン押下時
	 * 担当者有り、一覧（店舗スタッフ）
	 * 検索結果が対象店舗と来店担当者で絞り込まれた内容と問合せメールでの表示となること
	 */
	@isTest static void searchButtonShop(){
		// 店舗のユーザで実行
		User shopUser = [SELECT Id 
			FROM User
			WHERE LastName = 'ippanUser' 
		];
		Shop__c ippanShop = [
			SELECT Id 
			FROM   Shop__c
			WHERE  Name    = '店舗ユーザテスト_港区'
			LIMIT  1
		];
		Map<Id,Correspond__c> correspondMap = new Map<Id,Correspond__c>([
			SELECT Id FROM Correspond__c
			WHERE VisitShop__c = :ippanShop.id
		]);
		User ippanUser2 = [SELECT Id 
			FROM User
			WHERE LastName = 'ippanUser2' 
		];
		Map<Id,Correspond__c> correspondNotRunMap = new Map<Id,Correspond__c>([
			SELECT Id FROM Correspond__c
			WHERE ShopStaff__c = :ippanUser2.id
		]);

		System.runAs(shopUser){
			Test.startTest();
			//コントローラ作成
			GA101001Controller testController = new GA101001Controller();
			// 担当者設定
			testController.shopStaff = shopUser.id;

			// 検索押下
			testController.getCorrespondList();

			Test.stopTest();

			// ISのデータのみ
			for (GA101001Controller.ScreenCorrespond screenTargetRecord : testController.screenTargetRecordList) {
				System.assertEquals(true,correspondMap.containsKey(screenTargetRecord.Id));

				System.assertEquals(false,correspondNotRunMap.containsKey(screenTargetRecord.Id));
			}				
			// ユーザ情報
			System.assertEquals(shopUser.id,testController.shopStaff);
		}
	}
}