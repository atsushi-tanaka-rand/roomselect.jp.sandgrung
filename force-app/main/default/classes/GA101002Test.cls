/**
 * 反響一覧画面テスト
 */
@isTest
public with sharing class GA101002Test {

    /**
    * テストに使用するレコードを作成する
    */
	@testSetup static void Setting(){

        system.debug('初期設定開始');
        //標準プロファイルを取得
        Id profileId = [SELECT Id FROM Profile WHERE Name = '一般ユーザ'].Id;

        // -----------------------------------------------------------------------------------------------
        // 通常のユーザ
        // -----------------------------------------------------------------------------------------------
        //一般ユーザの登録（店舗）
        User testUser = new User(LastName = 'ippanUser'                                                                 //姓
                    ,Alias =  'alias'                                                 //別名
                    ,Email = 'ippanUser@test.com'      //メール
                    ,UserName =  'ippanUser@test.com'   //ユーザ名
                    ,CommunityNickname ='テストニックネーム'    //ニックネーム
                    ,EmailEncodingKey = 'ISO-2022-JP'                                  //メールの文字コード
                    ,TimeZoneSidKey = 'Asia/Tokyo'                                     //タイムゾーン
                    ,LocaleSidKey = 'ja_JP'                                            //地域
                    ,LanguageLocaleKey= 'ja'                                           //言語
                    ,ProfileId = profileId                                             //プロファイルID

        );
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            insert testUser;         
        }
        
        // 取引先
        Account AccountRecord = new Account(Name = 'テスト太郎', 
											   NameKana__c = 'ﾃｽﾄﾀﾛｳ', 
											   Phone = '025-200-1234', 
											   Email__c = 'aaa@hora', 
											   state__c = '大阪府', 
											   city__c = '大阪市', 
											   street__c = '中央区安土町４－１', 
											   RecordTypeId = commonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER)
        );

        insert AccountRecord; 

        // 店舗データ
        Shop__c ippanShopRecord = new Shop__c(Name     = '店舗ユーザテスト_港区' // 店舗名
                                            , Phone__c = '000-0000-0000' // 電話番号
                                            , Fax__c   = '000-0000-0000' // FAX
                                            , Email__c = 'minato@test.AccountShoninShinseiWebservice.com' // メール
                                            , PortalSitePostingDistrict__c = '港区' // ポータル掲載地区
                                            , District__c = '港区' // 所在地区
                                            , IsShopType__c = True  // 店舗区分
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

        // 建物
        Building__c BuildingRecord = new Building__c( Name = '反響テスト建物' // 建物名
                                                    , District__c = '港区' // 地区
        );       


        // 物件
        Property__c PropertyRecord = new Property__c( Name = ' 101 ' // 部屋番号
                                                    , Building__c = BuildingRecord.Id   // 建物
                                                    , LivedType__c = ' 未入居 ' // 未入居種別
                                                    , LiveStatus__c = ' 空室 ' // 現況
                                                    , RoomLayout__c = ' DK ' // 間取り
        );       


        // 対応データ
        Correspond__c CorrespondRecord = new Correspond__c(AccountId__c              = AccountRecord.Id  // 取引先
                                                        ,Property__c               = PropertyRecord.Id   // 物件
                                                        ,Status__c                 = commonConst.CORRESPOND_STATUS_NOTSUPPORTED  // ステータス
                                                        ,EventDateTime__c          =  Date.valueOf('2020-1-5')  // イベント時刻
                                                        ,IsSupportedListShow__c    = True   // 対応確認
                                                        ,EchoStaff__c              = testUser.Id  // 担当者（反響）
                                                        // ,ShopStaff__c              = ''   // 担当者（来店）
                                                        ,EchoShop__c               = ippanShopRecord.Id  // 反響担当店舗
                                                        // ,VisitShop__c              = ''   // 来店担当店舗
                                                        // ,PortalSite__c             = ''   // ポータルサイト
                                                        ,ListViewDate__c           = Date.valueOf('2020-1-1')  // 一覧表示日時

                                                        // ,SendMailDate__c           = Date.valueOf('2020-1-5') // メール送信日時
                                                        // ,IncomingMailDatePortal__c = Date.valueOf('2020-1-5')   // メール受信日時（ポータル）
                                                        // ,IncomingMailDateOther__c  = Date.valueOf('2020-1-5')   // メール受信日時（その他）
                                                        // ,PhoneIncomingDate__c      = Date.valueOf('2020-1-5')   // 電話着信日時
                                            );
        insert CorrespondRecord;

        // 店舗異動データ（ユーザと店舗の紐づけ）
        ShopTransfer__c ShopTransferRecord = new ShopTransfer__c(OrgzanizationHierarchy__c = orgRecord2.id  //    組織階層
                                                    ,StartDate__c =    Date.valueOf('2020-1-5')             //    開始日
                                                    ,EndDate__c   =    Date.valueOf('2040-1-5')             //    終了日
                                                    ,Staff__c     =   testUser.Id                           //    ユーザ
                                                    );                            
        insert ShopTransferRecord;

        // -----------------------------------------------------------------------------------------------
        //一般ユーザ（0件）
        // -----------------------------------------------------------------------------------------------
        User testUserNothng = new User(LastName = 'ippanUserNothing'                                                                 //姓
                    ,Alias =  'alias'                                                 //別名
                    ,Email = 'ippanUserNothing@test.com'      //メール
                    ,UserName =  'ippanUserNothing@test.com'   //ユーザ名
                    ,CommunityNickname ='テストニックネーム０件'    //ニックネーム
                    ,EmailEncodingKey = 'ISO-2022-JP'                                  //メールの文字コード
                    ,TimeZoneSidKey = 'Asia/Tokyo'                                     //タイムゾーン
                    ,LocaleSidKey = 'ja_JP'                                            //地域
                    ,LanguageLocaleKey= 'ja'                                           //言語
                    ,ProfileId = profileId                                             //プロファイルID

        );
        System.runAs(thisUser){
            insert testUserNothng; 
        }
        
        // 店舗異動データなしデータ用（ユーザと店舗の紐づけ）
        ShopTransfer__c ShopTransferRecordNothong = new ShopTransfer__c(OrgzanizationHierarchy__c = orgRecord2.id   //    組織階層
                                                    ,StartDate__c =    Date.valueOf('2020-1-5')                     //    開始日
                                                    ,EndDate__c   =    Date.valueOf('2040-1-5')                     //    終了日
                                                    ,Staff__c     =   testUserNothng.Id                             //    ユーザ
                                                    );                            
        insert ShopTransferRecordNothong;
        

        // -----------------------------------------------------------------------------------------------
        // インサイドセールスのデータ
        // -----------------------------------------------------------------------------------------------      
        // 一般ユーザの登録（IS）
        User testUserIs = new User(LastName = 'ISUser'                                                                 //姓
                                ,Alias =  'alias'                                                 //別名
                                ,Email = 'testuseris@test.com'      //メール
                                ,UserName =  'testuseris@test.com'   //ユーザ名
                                ,CommunityNickname ='インサイドセールス'    //ニックネーム
                                ,EmailEncodingKey = 'ISO-2022-JP'                                  //メールの文字コード
                                ,TimeZoneSidKey = 'Asia/Tokyo'                                     //タイムゾーン
                                ,LocaleSidKey = 'ja_JP'                                            //地域
                                ,LanguageLocaleKey= 'ja'                                           //言語
                                ,ProfileId = profileId                                             //プロファイルID

                                  );
        System.runAs(thisUser){
            insert testUserIs; 
        }
        
        // 店舗データ
        Shop__c ippanShopRecordIs = new Shop__c(Name     = 'IS店舗ユーザテスト_港区' // 店舗名
                                            , Phone__c = '000-0000-0000' // 電話番号
                                            , Fax__c   = '000-0000-0000' // FAX
                                            , Email__c = 'minato@test.AccountShoninShinseiWebservice.com' // メール
                                            , PortalSitePostingDistrict__c = '港区' // ポータル掲載地区
                                            , District__c = '港区' // 所在地区
                                            , IsShopType__c = False  // 店舗区分
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
        Account AccountRecordIs = new Account(Name = 'ISテスト太郎', 
											   NameKana__c = 'ISﾃｽﾄﾀﾛｳ', 
											   Phone = '025-200-0000', 
											   Email__c = 'aaa@hora', 
											   state__c = '大阪府', 
											   city__c = '大阪市', 
											   street__c = '中央区安土町４－１', 
											   RecordTypeId = commonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER)
        );
        insert AccountRecordIs;


        // 対応データ（IS）
        Correspond__c CorrespondRecordIs = new Correspond__c(AccountId__c              = AccountRecordIs.Id  // 取引先
                                                        ,Property__c               = PropertyRecord.Id   // 物件
                                                        ,Status__c                 = commonConst.CORRESPOND_STATUS_NOTSUPPORTED  // ステータス
                                                        // //,Event__c                  = ''   // イベント
                                                        ,EventDateTime__c          =  Date.valueOf('2020-1-5')  // イベント時刻
                                                        ,IsSupportedListShow__c    = True   // 対応確認
                                                        ,EchoStaff__c              = testUserIS.Id  // 担当者（反響）
                                                        // ,ShopStaff__c              = ''   // 担当者（来店）
                                                        ,EchoShop__c               = ippanShopRecordIs.Id  // 反響担当店舗
                                                        // ,VisitShop__c              = ''   // 来店担当店舗
                                                        // ,PortalSite__c             = ''   // ポータルサイト
                                                        ,ListViewDate__c           = Date.valueOf('2020-1-1')  // 一覧表示日時

                                                        // ,SendMailDate__c           = Date.valueOf('2020-1-5') // メール送信日時
                                                        // ,IncomingMailDatePortal__c = Date.valueOf('2020-1-5')   // メール受信日時（ポータル）
                                                        // ,IncomingMailDateOther__c  = Date.valueOf('2020-1-5')   // メール受信日時（その他）
                                                        // ,PhoneIncomingDate__c      = Date.valueOf('2020-1-5')   // 電話着信日時
                                            );
        insert CorrespondRecordIs;

        // 店舗異動データ（ユーザと店舗の紐づけ）
        ShopTransfer__c ShopTransferRecordIs = new ShopTransfer__c(OrgzanizationHierarchy__c = orgRecord3.id    //    組織階層
                                                    ,StartDate__c =    Date.valueOf('2020-1-5')                 //    開始日
                                                    ,EndDate__c   =    Date.valueOf('2040-1-5')                 //    終了日
                                                    ,Staff__c     =   testUserIs.Id                             //    ユーザ
                                                    );                            
        insert ShopTransferRecordIs;
        
        system.debug('初期設定終了');
    }

    /**
     * 初期表示テスト(更新)
     */
     @isTest static void initializeTest(){

         system.debug('初期表示');

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
		Correspond__c testTargetRecord = [SELECT Name            // 対応.対応番号（非表示）
                                        ,AccountId__r.ParentId   // 対応.取引先ID（非表示）
                                        ,AccountId__r.Name       // 対応.取引先 ID.取引先名
                                        ,Status__c               // 対応.ステータス
                                        ,Event__c                // 対応.イベント
                                        ,EventDateTime__c        // 対応.イベント時刻
                                        ,Property__r.Building__r.Name        // 対応.物件.建物.建物名
                                        ,Property__r.Name        // 対応.物件.部屋番号
                                        ,Property__r.Building__r.District__c // 対応.物件.建物.地区
                                        ,EchoStaff__r.Username   // 対応.担当者（反響）.ユーザ名
                                        ,EchoStaff__r.Name       // 対応.担当者（反響）.氏名
                                        ,EchoStaff__r.Department // 対応.ユーザ.部署
                                        ,PortalSite__r.Name      // 対応.ポータルサイト.サイト名
                                        ,EchoShop__r.Name        // 対応.反響担当店舗.店舗名
                                        ,AccountId__r.Phone      // 対応.取引先 ID.電話番号
                                        ,Memo__c                 // 対応.メモ
                                        FROM  Correspond__c         
								        WHERE EchoStaff__r.Username = 'ippanUser@test.com' 
        ];


        System.runAs(ippanUser){
            try {
                //コントローラ作成
                GA101002Controller testController = new GA101002Controller();

                // 一覧の項目が設定されている
                System.assertEquals(testTargetRecord.Name                    , testController.screenTargetRecordList[0].Name);
                System.assertEquals(testTargetRecord.AccountId__c            , testController.screenTargetRecordList[0].AccountIdParentId);
                System.assertEquals(testTargetRecord.AccountId__r.Name       , testController.screenTargetRecordList[0].AccountIdName);
                System.assertEquals(testTargetRecord.Status__c               , testController.screenTargetRecordList[0].Status);
                System.assertEquals(testTargetRecord.Event__c                , testController.screenTargetRecordList[0].Event);
                System.assertEquals(testTargetRecord.Property__r.Building__r.Name        , testController.screenTargetRecordList[0].BuildingName);
                System.assertEquals(testTargetRecord.Property__r.Name        , testController.screenTargetRecordList[0].PropertyName);
                System.assertEquals(testTargetRecord.Property__r.Building__r.District__c , testController.screenTargetRecordList[0].BuildingDistrict);
                System.assertEquals(testTargetRecord.EchoStaff__r.Username   , testController.screenTargetRecordList[0].EchoStaffUsername);
                System.assertEquals(testTargetRecord.EchoStaff__r.Name       , testController.screenTargetRecordList[0].EchoStaffName);
                System.assertEquals(testTargetRecord.EchoStaff__r.Department , testController.screenTargetRecordList[0].EchoStaffDepartment);
                System.assertEquals(testTargetRecord.PortalSite__r.Name      , testController.screenTargetRecordList[0].PortalSiteName);
                System.assertEquals(testTargetRecord.EchoShop__r.Name        , testController.screenTargetRecordList[0].EchoShopName);
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
                GA101002Controller testController = new GA101002Controller();
            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
        

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
                                        ,Property__r.Building__r.Name        // 対応.物件.建物.建物名
                                        ,Property__r.Name        // 対応.物件.部屋番号
                                        ,Property__r.Building__r.District__c // 対応.物件.建物.地区
                                        ,EchoStaff__r.Username   // 対応.担当者（反響）.ユーザ名
                                        ,EchoStaff__r.Name       // 対応.担当者（反響）.氏名
                                        ,EchoStaff__r.Department // 対応.ユーザ.部署
                                        ,PortalSite__r.Name      // 対応.ポータルサイト.サイト名
                                        ,EchoShop__r.Name        // 対応.反響担当店舗.店舗名
                                        ,AccountId__r.Phone      // 対応.取引先 ID.電話番号
                                        ,Memo__c                 // 対応.メモ
                                        FROM  Correspond__c         
								        WHERE EchoStaff__r.Username = 'testuseris@test.com' 
        ];
        System.runAs(isUser){
            try {
                //コントローラ作成
                GA101002Controller testController = new GA101002Controller();     


                // 一覧の項目が設定されている
                System.assertEquals(testTargetRecordIs.Name                    , testController.screenTargetRecordList[0].Name);
                System.assertEquals(testTargetRecordIs.AccountId__c            , testController.screenTargetRecordList[0].AccountIdParentId);
                System.assertEquals(testTargetRecordIs.AccountId__r.Name       , testController.screenTargetRecordList[0].AccountIdName);
                System.assertEquals(testTargetRecordIs.Status__c               , testController.screenTargetRecordList[0].Status);
                System.assertEquals(testTargetRecordIs.Event__c                , testController.screenTargetRecordList[0].Event);
                System.assertEquals(testTargetRecordIs.Property__r.Building__r.Name        , testController.screenTargetRecordList[0].BuildingName);
                System.assertEquals(testTargetRecordIs.Property__r.Name        , testController.screenTargetRecordList[0].PropertyName);
                System.assertEquals(testTargetRecordIs.Property__r.Building__r.District__c , testController.screenTargetRecordList[0].BuildingDistrict);
                System.assertEquals(testTargetRecordIs.EchoStaff__r.Username   , testController.screenTargetRecordList[0].EchoStaffUsername);
                System.assertEquals(testTargetRecordIs.EchoStaff__r.Name       , testController.screenTargetRecordList[0].EchoStaffName);
                System.assertEquals(testTargetRecordIs.EchoStaff__r.Department , testController.screenTargetRecordList[0].EchoStaffDepartment);
                System.assertEquals(testTargetRecordIs.PortalSite__r.Name      , testController.screenTargetRecordList[0].PortalSiteName);
                System.assertEquals(testTargetRecordIs.EchoShop__r.Name        , testController.screenTargetRecordList[0].EchoShopName);
                System.assertEquals(testTargetRecordIs.Memo__c                 , testController.screenTargetRecordList[0].Memo);                           

            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }


    }	

    /**
     * 検索ボタン押下
     */
    @isTest static void CorrespondListTest(){

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
                // 検索ボタン処理
                //コントローラ作成
                GA101002Controller testController = new GA101002Controller();
                testController.isAppointChecked = True;
                testController.getCorrespondList();
            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }

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
		Correspond__c testTargetRecord = [SELECT Name            // 対応.対応番号（非表示）
                                        ,AccountId__r.ParentId   // 対応.取引先ID（非表示）
                                        ,AccountId__r.Name       // 対応.取引先 ID.取引先名
                                        ,Status__c               // 対応.ステータス
                                        ,Event__c                // 対応.イベント
                                        ,EventDateTime__c        // 対応.イベント時刻
                                        ,Property__r.Building__r.Name        // 対応.物件.建物.建物名
                                        ,Property__r.Name        // 対応.物件.部屋番号
                                        ,Property__r.Building__r.District__c // 対応.物件.建物.地区
                                        ,EchoStaff__r.Username   // 対応.担当者（反響）.ユーザ名
                                        ,EchoStaff__r.Name       // 対応.担当者（反響）.氏名
                                        ,EchoStaff__r.Department // 対応.ユーザ.部署
                                        ,PortalSite__r.Name      // 対応.ポータルサイト.サイト名
                                        ,EchoShop__r.Name        // 対応.反響担当店舗.店舗名
                                        ,AccountId__r.Phone      // 対応.取引先 ID.電話番号
                                        ,Memo__c                 // 対応.メモ
                                        FROM  Correspond__c         
								        WHERE EchoStaff__r.Username = 'ippanUser@test.com' 
        ];
        
        System.runAs(ippanUser){
            try {
                // 検索ボタン処理
                //コントローラ作成
                GA101002Controller testController = new GA101002Controller();
                testController.getCorrespondList();

                // 一覧の項目が設定されている
                System.assertEquals(testTargetRecord.Name                    , testController.screenTargetRecordList[0].Name);
                System.assertEquals(testTargetRecord.AccountId__c            , testController.screenTargetRecordList[0].AccountIdParentId);
                System.assertEquals(testTargetRecord.AccountId__r.Name       , testController.screenTargetRecordList[0].AccountIdName);
                System.assertEquals(testTargetRecord.Status__c               , testController.screenTargetRecordList[0].Status);
                System.assertEquals(testTargetRecord.Event__c                , testController.screenTargetRecordList[0].Event);
                System.assertEquals(testTargetRecord.Property__r.Building__r.Name        , testController.screenTargetRecordList[0].BuildingName);
                System.assertEquals(testTargetRecord.Property__r.Name        , testController.screenTargetRecordList[0].PropertyName);
                System.assertEquals(testTargetRecord.Property__r.Building__r.District__c , testController.screenTargetRecordList[0].BuildingDistrict);
                System.assertEquals(testTargetRecord.EchoStaff__r.Username   , testController.screenTargetRecordList[0].EchoStaffUsername);
                System.assertEquals(testTargetRecord.EchoStaff__r.Name       , testController.screenTargetRecordList[0].EchoStaffName);
                System.assertEquals(testTargetRecord.EchoStaff__r.Department , testController.screenTargetRecordList[0].EchoStaffDepartment);
                System.assertEquals(testTargetRecord.PortalSite__r.Name      , testController.screenTargetRecordList[0].PortalSiteName);
                System.assertEquals(testTargetRecord.EchoShop__r.Name        , testController.screenTargetRecordList[0].EchoShopName);
                System.assertEquals(testTargetRecord.Memo__c                 , testController.screenTargetRecordList[0].Memo);


            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
    }	

    /**
     * 部署選択ポップアップの起動
     */
    @istest static void departmentMordal(){
        //コントローラ作成
        system.debug('部署開始');

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

        // 店舗データ
        Shop__c ShopRecord = [select Name 
                    , Phone__c
                    , Fax__c  
                    , Email__c
                    , PortalSitePostingDistrict__c
                    , District__c
                    , IsShopType__c 
                    from  Shop__c
                    where Name = '店舗ユーザテスト_港区'
                    limit 1
        ];    
        // 一般ユーザで実行
        System.runAs(ippanUser){
            try {
                // 開く前処理
                GA101002Controller testController = new GA101002Controller();
    
                testController.openModal();

                list<SelectOption> SelectEchoShopList = new List<SelectOption>();
                SelectEchoShopList.add(new SelectOption(ShopRecord.Id, ShopRecord.Name));// 第一引数 ： 値を設定 第二引数 : ラベル名(表示名)

                // 部署選択画面
                GA101002Modal1Controller testModalController = new GA101002Modal1Controller();

                // エラー用（パラメータ設定なし）
                testModalController.getSelectOption();


                testModalController.Parameter = new GA101002Modal1ParameterClass();
                testModalController.Parameter.selectedShopList = SelectEchoShopList;
                testModalController.Parameter.selectchooseableList = ippanUser.Id;        //ログインユーザから所属部署の初期値セット
                testModalController.Parameter.isShopType = True;
                testModalController.Parameter.isDrawing = true;
                testModalController.Parameter.noFirst = true;              

                // 実行（通常）
                testModalController.getSelectOption();

                // 選択対象の追加
                testModalController.setSelect();

                // 選択対象の解除
                testModalController.removeSelect();

                // 選択済み対象の設定
                testModalController.settingSelect();

                // 終了処理
                testController.closeModal();

                system.debug('部署終了');
            } catch(BusinessLogicException e){
                    System.assertEquals(e.getMessage(), '部署選択画面でエラー');
            }
        }
    }

    /**
     * 部署選択ポップアップの起動(IS)
     */
    @istest static void departmentMordalIs(){
        //コントローラ作成
        User iSUser = [SELECT Id 
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
        // 店舗データ
        Shop__c ShopRecord = [select Name 
                , Phone__c
                , Fax__c  
                , Email__c
                , PortalSitePostingDistrict__c
                , District__c
                , IsShopType__c 
                from  Shop__c
                where Name = '店舗ユーザテスト_港区'
                limit 1
        ];    
        // 一般ユーザで実行
        System.runAs(iSUser){
            try {
                // 開く前処理
                GA101002Controller testController = new GA101002Controller();

                list<SelectOption> SelectEchoShopList = new List<SelectOption>();
                SelectEchoShopList.add(new SelectOption(ShopRecord.Id, ShopRecord.Name));// 第一引数 ： 値を設定 第二引数 : ラベル名(表示名)

                List<String> shopList = new List<String>();
                shopList.add(ShopRecord.Id);

                testController.openModal();
                // 部署選択画面
                GA101002Modal1Controller testModalController = new GA101002Modal1Controller();
                testModalController.Parameter = new GA101002Modal1ParameterClass();
                testModalController.Parameter.selectedShopList =SelectEchoShopList;
                testModalController.Parameter.selectedShopListId = shopList ;
                testModalController.Parameter.selectchooseableList = iSUser.Id;        //ログインユーザから所属部署の初期値セット
                testModalController.Parameter.isShopType = False;
                testModalController.Parameter.isDrawing = true;
                testModalController.Parameter.noFirst = true;              

                testModalController.getSelectOption();

                // 終了処理
                testController.closeModal();

                system.debug('部署終了');
            } catch(BusinessLogicException e){
                    System.assertEquals(e.getMessage(), '');
            }
        }
    }



}