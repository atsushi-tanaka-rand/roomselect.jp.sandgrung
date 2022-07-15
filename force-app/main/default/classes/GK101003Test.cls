/* *
 * おすすめ物件一覧　テストクラス
 */
@isTest 
public with sharing class GK101003Test {
    //テストに使用するレコードを作成する
    @testSetup static void Setting(){

        //ユーザ作成
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name IN ('一般ユーザ')];
        System.assert(profiles.size() > 0);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            insert new User(
                UserName = 'Test@horaguchi.com',
                Email = 'test@example.com',
                LastName = 'test',
                Alias = 'test',
                TimeZoneSidKey = 'Asia/Tokyo',
                LocaleSidKey = 'ja_JP',
                EmailEncodingKey = 'ISO-2022-JP',
                LanguageLocaleKey = 'ja',
                ProfileId = profiles.get(0).Id);
        }
        //店舗レコード
        Shop__c testUserShop = new shop__c(
            Name = 'テストユーザ店舗'
            ,PortalSitePostingDistrict__c = '港区'
        );
        insert testUserShop;

        // カスタム設定を登録 
        SystemConfig__c sysconf = new SystemConfig__c(
            UseAuthority_Portal__c = true
            ,Theta360bizApiId__c = 'YRJ2hheSXZ'          // パノラマツアー認証Id
            ,Theta360bizApiAccessKey__c = '2mNySK4frewxewf487pUJ3tdfcs2Nn'    // パノラマツアーAccessKey
        );
        insert sysconf;

        // 建物登録
        Building__c testBuilding = new Building__c(
            Name = 'テスト建物'
            ,GroundFloorCount__c = 5
            ,StationDistance1__c = 80
            ,StationDistance2__c = 160
            ,StationDistance3__c = 240
            ,CaretakerType__c = '通勤方式'
        );
        insert testBuilding;
        // 物件登録
        Property__c testProperty = new Property__c(
            Name                        = '_t_'                               // 部屋番号
            ,AllRentFee__c              = 0                                         // 総賃料
            ,Score__c                   = 0                                         // 点数
            ,IsMergeCompletedFlag__c    = false                                     // 名寄せ完了フラグ
            ,Building__c                = testBuilding.Id                           // 建物
            ,Floor__c                   = 1                                         // 所在階
            ,FloorType__c               = CommonConst.PROPERTY_FLOORTYPE_GROUND     // 地下階区分
            ,RoomCount__c               = 3                                         // 部屋数
            ,RoomLayout__c              = 'LDK'                                     // 間取り
            ,RoomArea__c                = 20.25                                     // 専有面積（㎡）
            ,BalconyDirection__c        = CommonConst.PROPERTY_BALCONYDIRECTION_SOUTHEAST  // バルコニー方向
            ,BalconyArea__c             = 4.5                                       // バルコニー面積
            ,IsOwnCompanyPropertyFlag__c = false                                    // 自社物フラグ
            ,LiveStatus__c              = CommonConst.PROPERTY_LIVESTATUS_VACANCY   // 現況
            ,DeliveryType__c            = CommonConst.PROPERTY_DELIVERYTYPE_DUEDATE // 引渡種別
            ,DeliveryYear__c            = '2020'                                    // 引渡年
            ,DeliveryMonth__c           = '3月'                                     // 引渡月
            ,DeliveryTiming__c          = '上旬'                                    // 引渡旬
            ,DeliveryDay__c             = '1'                                       // 引渡日
            ,DeliveryConsultation__c    = 'テスト引渡・入居日（相談内容）'             // 引渡・入居日（相談内容）
            ,LivedType__c               = CommonConst.PROPERTY_LIVEDTYPE_NOTLIVED   // 未入居種別
            ,ContractTermYear__c        = 2                                         // 契約期間（年）
            ,ContractTermMonth__c       = 3                                         // 契約期間（月）
            ,TransactionAspect__c       = '一般媒介'                                 // 取引態様
            ,SpecificExcellentRentFeeFluctuationType__c = '傾斜型'                  // 特優賃料金変動区分
            ,SpecificExcellentRentFeeUpwardRate__c      = 10.5                      // 特優賃上昇率
            ,SpecificExcellentRentSupportYears__c       = 2                         // 特優賃家賃補助年数
            ,SpecificExcellentRentRemarks__c            = 'テスト特優賃備考'          // 特優賃備考
            ,RepresentativeComment__c   = 'テスト担当者コメント'                      // 担当者コメント
            ,MaintenanceCommentArea__c  = ''                                        // メンテナンスコメント
            ,RentFee__c                 = 40000                                     // 賃料
            ,AthomePanoramaContentsId__c    = '1234567890'                          // athomeパノラマコンテンツID
            ,AtHomePanoramaShop__c      = null                                      // athomeパノラマ掲載店舗
            ,HomesPanoramaShop__c       = null                                      // HOME'Sパノラマ掲載店舗
            ,SuumoPanoramaShop__c       = null                                      // SUUMOパノラマ掲載店舗
            ,WebPublishing__c           = CommonConst.PROPERTY_WEBPUBLISHING_NO     // Web公開
            ,IsPropertyNameHiddenFlag__c    = false                                 // 物件名非表示フラグ
            ,ImportType__c                  = CommonConst.PROPERTY_IMPORTTYPE_REALNETPRO    // 取込区分
            ,MaintenancePropertyCode__c     = 'qwertyuiop'                          // メンテナンス物件コード
        );
        insert testProperty;

        // おすすめ物件登録
        insert new RecommendProperty__c[]{new RecommendProperty__c(
            ShopId__c = testUserShop.id
            ,UserId__c = thisUser.id
            ,PropertyCode__c = testProperty.PropertyCode__c
            ,Comment__c = 'テスト'
            ,DisplayFlag__c = true
            ,PanoramaTourUrl__c = 'https://r81572704.theta360.biz/t/aaaaaaa-1856-11eb-85a7-0a60eb835eb0-1'
            ,HomesImportkey__c = ''
            ,PhotoFileName__c = ''
        )};

    }

    //検索テスト	
    @isTest static void search_1_Test(){

        User userRecord =  [SELECT Id FROM User WHERE UserName = 'Test@horaguchi.com'];
        system.runas(userRecord){

            //コントローラ作成
            GK101003Controller testController = new GK101003Controller();

            //検索
            testController.search();

            //検索結果が1件ある？
            system.assertEquals(1, testController.screenRecommendPropertyList.size());
        }
    }

    // 検索テスト０件
    @isTest static void search_0_Test(){

        User userRecord =  [SELECT Id FROM User WHERE UserName = 'Test@horaguchi.com'];
        system.runas(userRecord){

            //コントローラ作成
            GK101003Controller testController = new GK101003Controller();

            // 条件指定
            testController.searchShopsName = 'テストユーザ店舗';             // 店舗リスト
            testController.searchPanoramaTourRegisteAvailable = false;      // パノラマツアー登録有
            testController.searchPanoramaTourRegisteNotAvailable = true;    // パノラマツアー登録無
            testController.searchDisplayFlagRegistering = false;            // おすすめ物件_登録中
            testController.searchDisplayFlagRelease = true;                 // おすすめ物件_解除
        

            //検索
            testController.search();

            //検索結果が1件ある？
            system.assertEquals(0, testController.screenRecommendPropertyList.size());
        }
    }

    // 編集ボタン押下
    @isTest static void editButton_Test(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'Test@horaguchi.com'];
        system.runas(userRecord){

            //コントローラ作成
            GK101003Controller testController = new GK101003Controller();

            //検索
            testController.search();


            testController.openRecommendPropertyRegistration();
            testController.closeRecommendPropertyRegistration();
            
        }
        
    }

    // おすすめ登録解除ボタン
    @isTest static void recommendReleaseButton_Test(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'Test@horaguchi.com'];
        system.runas(userRecord){

            //コントローラ作成
            GK101003Controller testController = new GK101003Controller();

            //検索
            testController.search();

            testController.screenRecommendPropertyList[0].isSelected = true;

            // コールアウトクラスのモッククラスをセット
            Test.setMock(HttpCalloutMock.class, new GK101003TestHttpRequestMock());
            Test.startTest();
            testController.recommendRelease();
            Test.stopTest();

        }
    }


    // 削除ボタン
    @isTest static void deleteButton_Test(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'Test@horaguchi.com'];
        system.runas(userRecord){

            //コントローラ作成
            GK101003Controller testController = new GK101003Controller();

            //検索
            testController.search();


            testController.screenRecommendPropertyList[0].isSelected = true;

            // コールアウトクラスのモッククラスをセット
            Test.setMock(HttpCalloutMock.class, new GK101003TestHttpRequestMock());
            Test.startTest();
            testController.deleteRecommendProperty();
            Test.stopTest();
        }
        
    }
}