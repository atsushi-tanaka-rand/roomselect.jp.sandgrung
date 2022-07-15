@isTest
private class GA104001Test {


    public static final String USER_NAME = 'GA104001@horaguchi.com'; 
    public static final String ACCOUNT_CUSTOMER_NAME = '顧客';
    public static final String TRAINROUTE_NAME       = 'テスト路線';
    public static final String STATION_NAME          = 'テスト駅'; 
    public static final String BUILDING_NAME_1       = '建物名１-１';
    public static final String BUILDING_NAME_2       = '建物名１-２';
    public static final String BUILDING_NAME_3       = '建物名１-３';
    public static final String SUPPLIER_NAME         = 'テスト元付業者一般';
    public static final String BUILDING_STATE        = '愛知県';
    public static final String BUILDING_CITY         = '住所１';
    public static final String BUILDING_STREET       = '住所２';

    //テストに使用するレコードを作成
    @testSetup static void Setting(){

        // システム設定
        SystemConfig__c sysconf = new SystemConfig__c(
            PropertySearchMaxCount__c = 5000
        );
        insert sysconf;

        //店舗レコード
        Shop__c testUserShop = new shop__c(
            Name = 'テストユーザ店舗'
            ,PortalSitePostingDistrict__c = '港区'
        );
        insert testUserShop;

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
            OrganizationName__c = 'テスト店舗',
            HierarchyCode__c = '20',
            HierarchyOrder__c = 1,
            UpperOrganizationHierarchy__c = orgRecord1.Id,
            ExpandedOrganizationCode__c = '0000_0001_0002',
            Shop__c = testUserShop.Id
        );
        insert orgRecord2;

        //ユーザ作成
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name IN ('一般ユーザ')];
        System.assert(profiles.size() > 0);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            insert new User(
                UserName = USER_NAME,
                Email = 'test@example.com',
                LastName = 'test',
                Alias = 'test',
                TimeZoneSidKey = 'Asia/Tokyo',
                LocaleSidKey = 'ja_JP',
                EmailEncodingKey = 'ISO-2022-JP',
                LanguageLocaleKey = 'ja',
                ProfileId = profiles.get(0).Id
            );
        }

        //店舗異動レコード
        User testUser =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        ShopTransfer__c testShopTransfer = new ShopTransfer__c(
            OrgzanizationHierarchy__c = orgRecord2.id,
            Staff__c = testUser.id,
            StartDate__c = Date.newInstance(2000, 12, 1),
            EndDate__c = Date.newInstance(2999, 12, 1)
        );
        insert testShopTransfer;

        // 路線
        List<TrainRoute__c> trainList = new List<TrainRoute__c>();
        trainList.add(new TrainRoute__c(Name = TRAINROUTE_NAME));
        trainList.add(new TrainRoute__c(Name = 'テスト路線2'));
        trainList.add(new TrainRoute__c(Name = 'テスト路線3'));
		//▼2021.10.08 No.307 対応で追加
        trainList.add(new TrainRoute__c(Name = '更新確認路線1'));
        trainList.add(new TrainRoute__c(Name = '更新確認路線2'));
        trainList.add(new TrainRoute__c(Name = '更新確認路線3'));
		//▲2021.10.08 No.307 対応で追加
        insert trainList;

        // 駅
        List<Station__c> stationList = new List<Station__c>();
        stationList.add(new Station__c(Name = STATION_NAME, TrainRoute__c = trainList[0].Id));
        stationList.add(new Station__c(Name = 'テスト駅２',  TrainRoute__c = trainList[1].Id));
        stationList.add(new Station__c(Name = 'テスト駅３',  TrainRoute__c = trainList[2].Id));
		//▼2021.10.08 No.307 対応で追加
        stationList.add(new Station__c(Name = '更新確認駅1',  TrainRoute__c = trainList[3].Id));
        stationList.add(new Station__c(Name = '更新確認駅2',  TrainRoute__c = trainList[4].Id));
        stationList.add(new Station__c(Name = '更新確認駅3',  TrainRoute__c = trainList[5].Id));
		//▲2021.10.08 No.307 対応で追加
        insert stationList;

        // 業者
        Account supplier = new Account(Name                    = SUPPLIER_NAME
                                      ,RecordTypeId            = CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_SUPPLIER)
                                      ,IsOwner__c              = false
                                      ,IsManagementCompany__c  = true
                                      ,IsSubLease__c           = false
                                      ,IsGuaranteeidCompany__c = false
                                      ,IsInsuranceCompany__c   = false
                                      );
        insert supplier;

        // 希望路線
        List<DesiredTrainRoute__c> desiredTrainRouteList = new List<DesiredTrainRoute__c>();
        desiredTrainRouteList.add(new DesiredTrainRoute__c(TrainRoute__c = trainList[0].Id));
        desiredTrainRouteList.add(new DesiredTrainRoute__c(TrainRoute__c = trainList[1].Id));
        desiredTrainRouteList.add(new DesiredTrainRoute__c(TrainRoute__c = trainList[2].Id));
        insert desiredTrainRouteList;

        // 希望駅
        List<DesiredStation__c> desiredStationList = new List<DesiredStation__c>();
        desiredStationList.add(new DesiredStation__c(DesiredTrainRoute__c = desiredTrainRouteList[0].Id, Station__c = stationList[0].Id));
        desiredStationList.add(new DesiredStation__c(DesiredTrainRoute__c = desiredTrainRouteList[1].Id, Station__c = stationList[1].Id));
        desiredStationList.add(new DesiredStation__c(DesiredTrainRoute__c = desiredTrainRouteList[2].Id, Station__c = stationList[2].Id));
        insert desiredStationList;

        // ▼問合せ367で追加
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
		//▼2021.10.08 No.307 対応で追加
		School__c testSchool3 = new School__c(
            Name = '更新確認学校1'
            ,City__c = '港区'
            ,Type__c = '中学校'
        );
        School__c testSchool4 = new School__c(
            Name = '更新確認学校2'
            ,City__c = '港区'
            ,Type__c = '小学校'
        );
		//▲2021.10.08 No.307 対応で追加
        List<School__c> testSchool = new List<School__c> {
            testSchool1
            ,testSchool2
			//▼2021.10.08 No.307 対応で追加
            ,testSchool3
            ,testSchool4
			//▲2021.10.08 No.307 対応で追加
        };
        insert testSchool;

        // 希望学区
        DesiredSchoolArea__c testDesiredSchoolArea1 = new DesiredSchoolArea__c(
            SchoolArea__c	 = '港区'
        );
        DesiredSchoolArea__c testDesiredSchoolArea2 = new DesiredSchoolArea__c(
            SchoolArea__c	 = '港区'
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
        // ▲問合せ367で追加

        // 顧客
        Account customer = new Account(
              Name = ACCOUNT_CUSTOMER_NAME
            , RecordTypeId          = CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_CUSTOMER)
            , DesiredTrainRoute1__c = desiredTrainRouteList[0].Id
            , DesiredTrainRoute2__c = desiredTrainRouteList[1].Id
            , DesiredTrainRoute3__c = desiredTrainRouteList[2].Id
            , DesiredJuniorHighSchoolArea__c = testDesiredSchoolArea[0].id
            , DesiredElementarySchoolArea__c = testDesiredSchoolArea[1].id
        );
        insert customer;

        // ▼2021.10.08 No.307 対応で追加
        //お客様物件条件
        AccountPropertyConditions__c customerApc = new AccountPropertyConditions__c(
              Name = ACCOUNT_CUSTOMER_NAME
            , Account__c            = customer.Id
            , DesiredTrainRoute1__c = desiredTrainRouteList[0].Id
            , DesiredTrainRoute2__c = desiredTrainRouteList[1].Id
            , DesiredTrainRoute3__c = desiredTrainRouteList[2].Id
            , DesiredJuniorHighSchoolArea__c = testDesiredSchoolArea[0].id
            , DesiredElementarySchoolArea__c = testDesiredSchoolArea[1].id
        );
        insert customerApc;
        // ▲2021.10.08 No.307 対応で追加

        // 建物
        Building__c building = new Building__c(
             Name                = BUILDING_NAME_1                              // 建物名
            ,BuildName2__c       = BUILDING_NAME_2                              // 建物名２
            ,BuildName3__c       = BUILDING_NAME_3                              // 建物名３
            ,BuildKana__c        = 'ﾀﾃﾓﾉﾒｲｶﾅｲﾁｲﾁ'                               // 建物名（カナ）
            ,BuildKana2__c       = 'ﾀﾃﾓﾉﾒｲｶﾅｲﾁﾆ'                                // 建物名（カナ）２
            ,BuildKana3__c       = 'ﾀﾃﾓﾉﾒｲｶﾅｲﾁｻﾝ'                               // 建物名（カナ）３
            ,PostalCode__c       = '498-0004'                                   // 郵便番号
            ,State__c            = '愛知県'                                     // 都道府県
            ,City__c             = '住所１'                                     // 住所１（市区町村）
            ,Street__c           = '住所２'                                     // 住所２（番地）
            ,BuildingYM__c       = '202001'                                     // 築年月
            ,Structure__c        = CommonConst.BUILDING_STRUCTURE_WOODEN        // 建物構造
            ,PropertyType__c     = CommonConst.BUILDING_PROPERTYTYPE_MANSION    // 物件種別
            ,TrainRoute1__c      = trainList[0].Id                              // 沿線１
            ,TrainRoute2__c      = trainList[1].Id                              // 沿線２
            ,TrainRoute3__c      = trainList[2].Id                              // 沿線３
            ,Station1__c         = stationList[0].Id                            // 駅１
            ,Station2__c         = stationList[1].Id                            // 駅２
            ,Station3__c         = stationList[2].Id                            // 駅３
            ,StationDistance1__c = 80                                           // 駅までの距離
            ,StationDistance2__c = 160                                          // 駅までの距離２
            ,StationDistance3__c = 240                                          // 駅までの距離３
            ,JuniorHighSchool1__c = testSchool[0].id                            // 中学校
            ,PrimarySchool1__c    = testSchool[1].id                            // 小学校
        );
        insert building;

        // 物件
        Property__c prop = new Property__c(
              Name                       = '物件名1'                                             // 部屋番号
            , Building__c                = building.Id                                          // 建物
            , RoomCount__c               = 1                                                    // 部屋数＆間取り
            , RoomLayout__c              = CommonConst.PROPERTY_ROOMLAYOUT_R                    // 間取り
            , BalconyDirection__c        = CommonConst.PROPERTY_BALCONYDIRECTION_NORTH           // バルコニー方向
            , LiveStatus__c              = CommonConst.PROPERTY_LIVESTATUS_VACANCY              // 現況
            , RentFee__c                 = 62000                                                 // 賃料
            , KeyMoneyYen__c             = 40000                                                 // 礼金(円)
            , KeyMoneyUnit__c            = CommonConst.PROPERTY_FEEUNIT_YEN                      // 礼金単位
            , KeyMoneyMonthSearch__c     = 0                                                     // (検索用)礼金(ヵ月)
            , KeyMoneyYenSearch__c       = 40000                                                 // (検索用)礼金(円)
            , DepositMonth__c            = 2.6                                                   // 保証料金(ヵ月)
            , DepositYen__c              = 161200                                                // 保証料金(円)
            , DepositMonthSearch__c      = 2.6                                                   // (検索用)保証料金(ヵ月)
            , DepositYenSearch__c        = 161200                                                // (検索用)保証料金(円)
            , DepositUnit__c             = CommonConst.PROPERTY_FEEUNIT_YEN                      // 保証金単位
            , CleaningFeeYen__c          = 127000                                                // 定額修繕費(円)
            , CleaningFeeMonthSearch__c  = 0                                                     // (検索用)定額修繕費(ヵ月)
            , CleaningFeeYenSearch__c    = 127000                                                // (検索用)定額修繕費(円)
            , CleaningFeeUnit__c         = CommonConst.PROPERTY_FEEUNIT_YEN                      // 定額修繕費単位
            , RenewalFeeYen__c           = 61000                                                 // 更新料(円)
            , RenewalFeeMonthSearch__c   = 0                                                     // (検索用)更新料(ヵ月)
            , RenewalFeeYenSearch__c     = 61000                                                 // (検索用)更新料(円)
            , RenewalFeeUnit__c          = CommonConst.PROPERTY_FEEUNIT_YEN                      // 更新料単位
            , RoomArea__c                = 80                                                    // 専有面積（㎡）
            , ManagementFee__c           = 5700                                                  // 管理費
            , ParkingFee__c              = 9200                                                  // 駐車場料金
            , Score__c                   = 24                                                    // 点数
            , GuaranteeidCompanyType__c  = CommonConst.PROPERTY_GUARANTEEIDCOMPANYTYPE_POSSIBLE  // 保証会社（利用区分）
            , FormerSupplier__c          = supplier.Id                                           // 元付業者
            , PropertyRemarksPublic__c   = '物件備考（公開）'                                    // 物件備考（公開）
            , PropertyRemarksPrivate__c  = '物件備考（非公開）'                                  // 物件備考（非公開）
            , ParkingRemarksPublic__c    = '駐車場備考（公開）'                                  // 駐車場備考（公開）
            , ParkingRemarksPrivate__c   = '駐車場備考（非公開）'                                // 駐車場備考（非公開）
            , MonetaryPublic__c          = '金銭備考（公開）'                                    // 金銭備考（公開）
            , MonetaryPrivate__c         = '金銭備考（非公開）'                                  // 金銭備考（非公開）
        );
        insert prop;


        // 物件条件
        PropertyConditions__c porpCond = new PropertyConditions__c(
            Property__c                            = prop.Id        // 物件
            , IsMaisonette__c                      = true           // メゾネット
            , IsLoft__c                            = true           // ロフト
            , IsDesigners__c                       = true           // デザイナーズ
            , IsRenovation__c                      = true           // リノベーション
            , IsCondominiumRental__c               = true           // 分譲賃貸
            , IsAllWesternStyleRoom__c             = true           // オール洋間
            , IsFirstFloor__c                      = true           // 1階
            , IsSecondFloorOver__c                 = true           // 2階以上
            , IsTopFloor__c                        = true           // 最上階
            , IsCornerRoom__c                      = true           // 角部屋
            , IsBalcony__c                         = true           // バルコニー
            , IsRoofBalcony__c                     = true           // ルーフバルコニー
            , IsPrivateGarden__c                   = true           // 専用庭
            , IsParking__c                         = true           // 駐車場空きあり
            , IsInSiteParking__c                   = true           // 敷地内駐車場
            , IsPluralCarParking__c                = true           // 駐車場2台可
            , IsBuiltInGarage__c                   = true           // ビルトインガレージ
            , IsCarport__c                         = true           // カーポート
            , IsBicycleParking__c                  = true           // 駐輪場
            , IsBikeStorage__c                     = true           // バイク可
            , IsSmallBike__c                       = true           // 小型バイク
            , IsMediumBike__c                      = true           // 中型バイク
            , IsLargeBike__c                       = true           // 大型バイク
            , IsElevator__c                        = true           // エレベーター
            , IsDeliveryBox__c                     = true           // 宅配ボックス
            , IsCounterKitchen__c                  = true           // カウンターキッチン
            , IsSystemKitchen__c                   = true           // システムキッチン
            , IsGasStove__c                        = true           // ガスコンロ
            , IsElectricStove__c                   = true           // 電気コンロ
            , IsIhStove__c                         = true           // IHコンロ
            , IsTwoGasStove__c                     = true           // コンロ2口
            , IsMoreGasStove__c                    = true           // コンロ3口以上
            , IsSeparate__c                        = true           // バス・トイレ別
            , IsReheating__c                       = true           // 追焚機能
            , IsBathroomDryer__c                   = true           // 浴室乾燥機
            , IsWashletToiletSeat__c               = true           // 温水洗浄便座
            , IsShowerWashBasin__c                 = true           // シャワー付き洗面台
            , IsWashroomDscrete__c                 = true           // 洗面所独立
            , IsIndoorWashingMachineStorage__c     = true           // 室内洗濯機置場
            , IsCityGas__c                         = true           // 都市ガス
            , IsPropaneGas__c                      = true           // プロパンガス
            , IsAllElectric__c                     = true           // オール電化
            , IsAirConditioner__c                  = true           // エアコン
            , IsFloorHeating__c                    = true           // 床暖房
            , IsShoesBox__c                        = true           // シューズボックス
            , IsShoeCloak__c                       = true           // シューズクローク
            , IsWalkInCloset__c                    = true           // ウォークインクローゼット
            , IsTrunkRoom__c                       = true           // トランクルーム
            , IsBSAntenna__c                       = true           // BSアンテナ
            , IsCSAntenna__c                       = true           // CSアンテナ
            , IsCATV__c                            = true           // CATV
            , IsInternetFree__c                    = true           // ネット使用料無料
            , IsMonitorIntercom__c                 = true           // モニター付きインターホン
            , IsAutoLock__c                        = true           // オートロック
            , IsFurniture__c                       = true           // 家具付き
            , IsHomeAppliance__c                   = true           // 家電付き
            , IsNoGuarantor__c                     = true           // 保証人不要
            , IsMusicalInstruments__c              = true           // 楽器相談可
            , IsForeigner__c                       = true           // 外国人契約可
            , IsWelfareAvailable__c                = true           // 生活保護契約可
            , IsOfficeAvailable__c                 = true           // 事務所利用可
            , IsPet__c                             = true           // ペット可
            , IsSmallPet__c                        = true           // ペット(小型犬)
            , IsMiddlePet__c                       = true           // ペット(中型犬)
            , IsLargePet__c                        = true           // ペット(大型犬)
            , IsCat__c                             = true           // ペット(猫)
            , IsOtherPet__c                        = true           // ペット(その他)
            , IsTwoTenant__c                       = true           // 2人入居可
            , IsRoomShare__c                       = true           // ルームシェア可
            , IsElderly__c                         = true           // 高齢者歓迎
            , IsWoman__c                           = true           // 女性限定
            , IsStudent__c                         = true           // 学生限定
        );


    }

    // 起動（取引先無）
    @isTest static void checkInitNonAccount() {
        // 画面起動
        PageReference pageRef = Page.GA104001View;
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GA104001Controller testController = new GA104001Controller();
    }

    // 起動（取引先有）2021.10.08 No.307 対応で変更
    @isTest static void checkInitExistsAccount() {
        Account acc = [select id, IsLoft__c, IsCornerRoom__c from Account WHERE Name = :ACCOUNT_CUSTOMER_NAME];
        acc.IsLoft__c = TRUE;//ロフト
        acc.IsCornerRoom__c = FALSE;//角部屋
        update acc;

        PageReference pageRef = Page.GA104001View;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', acc.Id);
        pageRef.getParameters().put('AccountId', acc.Id);
        //コントローラ作成
        GA104001Controller testController = new GA104001Controller();

        System.assertEquals(acc.IsLoft__c, testController.dispCondition.isLoft);
        System.assertEquals(acc.IsCornerRoom__c, testController.dispCondition.isCornerRoom);
    }

    // ▼2021.10.08 No.307 対応で追加
    // 起動（お客様物件条件有）
    @isTest static void checkInitExistsApc() {
        AccountPropertyConditions__c apc = [select id, Account__c, IsWooden__c, IsBikeStorage__c from AccountPropertyConditions__c WHERE Account__r.Name = :ACCOUNT_CUSTOMER_NAME LIMIT 1];
        apc.IsWooden__c = TRUE;//木造
        apc.IsBikeStorage__c = FALSE;//バイク可
        update apc;

        PageReference pageRef = Page.GA104001View;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', apc.Id);
        pageRef.getParameters().put('AccountId', apc.Account__c);
        //コントローラ作成
        GA104001Controller testController = new GA104001Controller();

        System.assertEquals(apc.IsWooden__c, testController.dispCondition.isWooden);
        System.assertEquals(apc.IsBikeStorage__c, testController.dispCondition.isBikeStorage);
    }
    // ▲2021.10.08 No.307 対応で追加

    // 物件検索（取引先）2021.10.08 No.307 対応で変更
    @isTest static void searchAllCondition() {
        // 画面起動
        Account acc = [select id, SystemModstamp from Account WHERE Name = :ACCOUNT_CUSTOMER_NAME];
        PageReference pageRef = Page.GA104001View;
        pageRef.getParameters().put('Id', acc.Id);
        pageRef.getParameters().put('AccountId', acc.Id);
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GA104001Controller ctrl = new GA104001Controller();
        

        // 検索条件設定
        // テキスト
        ctrl.dispCondition.propertyName         = BUILDING_NAME_1;  // 物件名
        ctrl.dispCondition.formerSupplierName   = SUPPLIER_NAME;    // 元付業者名
        ctrl.dispCondition.address              = BUILDING_STATE;   // 住所

        // 駅
        Id trainRouteId = [SELECT ID FROM TrainRoute__c WHERE NAME = :TRAINROUTE_NAME LIMIT 1].Id;
        List<Station__c> stationList = [SELECT Id, Name FROM Station__c WHERE NAME = :STATION_NAME LIMIT 1];

        ctrl.dispCondition.trainRoute1  = trainRouteId;          // 希望路線１
        ctrl.dispCondition.trainRoute2  = trainRouteId;          // 希望路線２
        ctrl.dispCondition.trainRoute3  = trainRouteId;          // 希望路線３
        ctrl.dispCondition.stations1    = stationList;             //　希望駅１
        ctrl.dispCondition.stations2    = stationList;             //　希望駅２
        ctrl.dispCondition.stations3    = stationList;             //　希望駅３
        ctrl.dispCondition.walkingTime  = '10';                    //　徒歩

        // 現況
        ctrl.dispCondition.isLiveStatusLive            = true;  // 居住中
        ctrl.dispCondition.isLiveStatusEmpty           = true;  // 空室
        ctrl.dispCondition.IsLiveStatusLeaveSchedule   = true;  // 退去予定
        // 間取り
        ctrl.dispCondition.isOneRoom                   = true;     // ワンルーム
        ctrl.dispCondition.is1K                        = true;     // 1K
        ctrl.dispCondition.is1DK                       = true;     // 1DK
        ctrl.dispCondition.is1LDK1SLDK                 = true;     // 1LDK/SLDK
        ctrl.dispCondition.is2K2DK                     = true;     // 2K/DK
        ctrl.dispCondition.is2LDK2SLDK                 = true;     // 2LDK/SLDK
        ctrl.dispCondition.is3K3DK                     = true;     // 3K/DK 
        ctrl.dispCondition.is3LDK3SLDK                 = true;     // 3LDK/SLDK 
        ctrl.dispCondition.is4K4DK4LDKFrom             = true;     // 4K/DK/LDK~
        // 構造                     = true;     
        ctrl.dispCondition.isWooden                    = true;     // 木造
        ctrl.dispCondition.isLightweightSteel          = true;     // 軽量鉄骨
        ctrl.dispCondition.isSteel                     = true;     // 鉄骨造
        ctrl.dispCondition.isRC                        = true;     // RC
        ctrl.dispCondition.isSRC                       = true;     // SRC
        // 方角                     = true;     
        ctrl.dispCondition.isNorth                     = true;     //北
        ctrl.dispCondition.isNortheast                 = true;     //北東
        ctrl.dispCondition.isEast                      = true;     //東
        ctrl.dispCondition.isSouthEast                 = true;     //南東
        ctrl.dispCondition.isSouth                     = true;     //南
        ctrl.dispCondition.isSouthWest                 = true;     //南西
        ctrl.dispCondition.isWest                      = true;     //西
        ctrl.dispCondition.isNorthWest                 = true;     //北西
        // 敷礼・更新料             = true;     
        ctrl.dispCondition.isNonDeposit                = true;     //敷金/保証金なし
        ctrl.dispCondition.isNonKeyMoney               = true;     //礼金なし
        ctrl.dispCondition.isNonCleaningFee            = true;     //定額修繕費なし
        ctrl.dispCondition.isNonRenewalFee             = true;     //更新料なし
        //住居条件
        ctrl.dispCondition.rentFeeFrom                 = '10000';                     //賃料 From     
        ctrl.dispCondition.rentFeeTo                   = '100000';                    //賃料 To       
        ctrl.dispCondition.isIncludeManagementFee      = true;      // 管理費込み
        ctrl.dispCondition.isIncludeParkingFee         = true;      //駐車場代込み
        ctrl.dispCondition.occupancyAreaLowerLimit     = '0';       //占有面積（下限）
        ctrl.dispCondition.occupancyAreaUpperLimit     = '999';     //占有面積（上限）
        ctrl.dispCondition.buildingAge                 = '999';      //築年数
        ctrl.dispCondition.isScore34Less               = true;     //34点未満
        ctrl.dispCondition.isScore34to35               = true;     //34～35点
        ctrl.dispCondition.isScore36More               = true;     //36点以上
        ctrl.dispCondition.isScoreAll                  = true;     //全て
        // 構造・工法
        ctrl.dispCondition.isDetachedHouse             = true;     //戸建て
        ctrl.dispCondition.isMaisonette                = true;     //メゾネット
        ctrl.dispCondition.isLoft                      = true;     //ロフト
        ctrl.dispCondition.isDesigners                 = true;     //デザイナーズ
        ctrl.dispCondition.isRenovation                = true;     //リノベーション
        ctrl.dispCondition.isCondominiumRental         = true;     //分譲賃貸
        ctrl.dispCondition.isAllWestern                = true;     //オール洋間
        // フロア・庭バルコニー
        ctrl.dispCondition.isFirstFloor                = true;     //1階
        ctrl.dispCondition.isSecondFloorOver           = true;     //2階以上
        ctrl.dispCondition.isTopFloor                  = true;     //最上階
        ctrl.dispCondition.isCornerRoom                = true;     //角部屋
        ctrl.dispCondition.isBalcony                   = true;     //バルコニー
        ctrl.dispCondition.isRoofBalcony               = true;     //ルーフバルコニー
        ctrl.dispCondition.isPrivateGarden             = true;     //専用庭
        // 駐車・駐輪共用部
        ctrl.dispCondition.isParking                   = true;  //駐車場空きあり
        ctrl.dispCondition.isInSiteParking             = true;    //敷地内駐車場
        ctrl.dispCondition.isPluralCarParking          = true;    //駐車場2台可
        ctrl.dispCondition.isBuiltInGarage             = true;    //ビルトインガレージ
        ctrl.dispCondition.isCarport                   = true;    //カーポート
        ctrl.dispCondition.isBicycleParking            = true;    //駐輪場
        ctrl.dispCondition.isBikeStorage               = true;           //バイク可
        ctrl.dispCondition.isSmallBike                 = true;    //小型バイク
        ctrl.dispCondition.isMediumBike                = true;    //中型バイク
        ctrl.dispCondition.isLargeBike                 = true;    //大型バイク
        ctrl.dispCondition.isElevator                  = true;    //エレベーター
        ctrl.dispCondition.isDeliveryBox               = true;    //宅配ボックス
        // キッチン                 = true;
        ctrl.dispCondition.isCounterKitchen            = true;    //カウンターキッチン
        ctrl.dispCondition.isSystemKitchen             = true;    //システムキッチン
        ctrl.dispCondition.isGasStove                  = true;    //ガスコンロ
        ctrl.dispCondition.isElectricStove             = true;    //電気コンロ
        ctrl.dispCondition.isInductionHeating          = true;             //IHコンロ
        ctrl.dispCondition.isTwoGasStove               = true;    //コンロ2口
        ctrl.dispCondition.isMoreGasStove              = true;    //コンロ3口以上
        // バス・トイレ洗面所       = true;
        ctrl.dispCondition.isSepalateBathAndRestroom   = true;    //バス・トイレ別
        ctrl.dispCondition.isAditionalBoiling          = true;    //追焚機能
        ctrl.dispCondition.isDehumidifierForBathroom   = true;    //浴室乾燥機
        ctrl.dispCondition.isWashlet                   = true;    //温水洗浄便座
        ctrl.dispCondition.isShowerWashBasin           = true;    //シャワー付き洗面台
        ctrl.dispCondition.isRegalLavatory             = true;    //洗面所独立
        ctrl.dispCondition.isInnerLandry               = true;    //室内洗濯機置場
        // 光熱設備・空調
        ctrl.dispCondition.isTownGas                   = true; //都市ガス
        ctrl.dispCondition.isPropaneGas                = true; //プロパンガス
        ctrl.dispCondition.isAllElectric               = true; //オール電化
        ctrl.dispCondition.isAirConditioner            = true; //エアコン
        ctrl.dispCondition.isFloorHeating              = true; //床暖房
        // 収納                     = true 
        ctrl.dispCondition.isShoesBox                  = true; //シューズボックス
        ctrl.dispCondition.isShoeCloak                 = true; //シューズクローク
        ctrl.dispCondition.isWalkInCloset              = true; //ウォークインクローゼット
        ctrl.dispCondition.isTrunkRoom                 = true; //トランクルーム
        // 通信設備                 = true 
        ctrl.dispCondition.isBSAntenna                 = true; //BSアンテナ
        ctrl.dispCondition.isCSAntenna                 = true; //CSアンテナ
        ctrl.dispCondition.isCATV                      = true; //CATV
        ctrl.dispCondition.isInternetFree              = true; //ネット使用料無料
        // セキュリティ             = true 
        ctrl.dispCondition.isMonitorIntercom           = true; //モニター付きインターホン
        ctrl.dispCondition.isAutoLock                  = true; //オートロック
        // 家具・家電               = true 
        ctrl.dispCondition.isFurniture                 = true; //家具付き
        ctrl.dispCondition.isHomeAppliance             = true; //家電付き
        // 入居条件・支払方法
        ctrl.dispCondition.isNoGuarantor              = true;   //保証人不要
        ctrl.dispCondition.isNonGuaranteeidCompany    = true;    //保証会社不要
        ctrl.dispCondition.isMusicalInstruments       = true;   //楽器相談可
        ctrl.dispCondition.isForeigner                = true;   //外国人契約可
        ctrl.dispCondition.isWelfareAvailable         = true;  //生活保護契約可
        ctrl.dispCondition.isOfficeAvailable          = true;   //事務所利用可
        ctrl.dispCondition.isPet                      = true;   //ペット可
        ctrl.dispCondition.isSmallPet                 = true;   //ペット(小型犬)
        ctrl.dispCondition.isMiddlePet                = true;   //ペット(中型犬)
        ctrl.dispCondition.isLargePet                 = true;   //ペット(大型犬)
        ctrl.dispCondition.isCat                      = true;   //ペット(猫)
        ctrl.dispCondition.isOtherPet                 = true;   //ペット(その他)
        ctrl.dispCondition.isTwoTenant                = true;   //2人入居可
        ctrl.dispCondition.isRoomShare                = true;   //ルームシェア可
        ctrl.dispCondition.isIppambutsu               = true;   //一般物
        ctrl.dispCondition.isElderly                  = true;   //高齢者歓迎
        ctrl.dispCondition.isWoman                    = true;   //女性限定
        ctrl.dispCondition.isStudent                  = true;   //学生限定マンション
        ctrl.dispCondition.isRentCreditPayment        = true;   //家賃カード決済可
        ctrl.dispCondition.isInitialCostCreditPayment = true;   //初期費用カード決済可

        // 検索実行
        ctrl.searchProperty();

        Account afterAcc = [select id, SystemModstamp from Account WHERE Name = :ACCOUNT_CUSTOMER_NAME];
        System.assertNotEquals(acc.SystemModstamp, afterAcc.SystemModstamp);
    }

    // ▼2021.10.08 No.307 対応で追加
    // 物件検索（お客様物件条件）
    @isTest static void searchAllConditionByApc() {
		// 画面起動
        AccountPropertyConditions__c apc = [select id, Account__c, SystemModstamp from AccountPropertyConditions__c WHERE Account__r.Name = :ACCOUNT_CUSTOMER_NAME];
        PageReference pageRef = Page.GA104001View;
        pageRef.getParameters().put('Id', apc.Id);
        pageRef.getParameters().put('AccountId', apc.Account__c);
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GA104001Controller ctrl = new GA104001Controller();
        

        // 検索条件設定
        // テキスト
        ctrl.dispCondition.propertyName         = BUILDING_NAME_1;  // 物件名
        ctrl.dispCondition.formerSupplierName   = SUPPLIER_NAME;    // 元付業者名
        ctrl.dispCondition.address              = BUILDING_STATE;   // 住所

        // 駅
        Id trainRouteId = [SELECT ID FROM TrainRoute__c WHERE NAME = :TRAINROUTE_NAME LIMIT 1].Id;
        List<Station__c> stationList = [SELECT Id, Name FROM Station__c WHERE NAME = :STATION_NAME LIMIT 1];

        ctrl.dispCondition.trainRoute1  = trainRouteId;          // 希望路線１
        ctrl.dispCondition.trainRoute2  = trainRouteId;          // 希望路線２
        ctrl.dispCondition.trainRoute3  = trainRouteId;          // 希望路線３
        ctrl.dispCondition.stations1    = stationList;             //　希望駅１
        ctrl.dispCondition.stations2    = stationList;             //　希望駅２
        ctrl.dispCondition.stations3    = stationList;             //　希望駅３
        ctrl.dispCondition.walkingTime  = '10';                    //　徒歩

        // 現況
        ctrl.dispCondition.isLiveStatusLive            = true;  // 居住中
        ctrl.dispCondition.isLiveStatusEmpty           = true;  // 空室
        ctrl.dispCondition.IsLiveStatusLeaveSchedule   = true;  // 退去予定
        // 間取り
        ctrl.dispCondition.isOneRoom                   = true;     // ワンルーム
        ctrl.dispCondition.is1K                        = true;     // 1K
        ctrl.dispCondition.is1DK                       = true;     // 1DK
        ctrl.dispCondition.is1LDK1SLDK                 = true;     // 1LDK/SLDK
        ctrl.dispCondition.is2K2DK                     = true;     // 2K/DK
        ctrl.dispCondition.is2LDK2SLDK                 = true;     // 2LDK/SLDK
        ctrl.dispCondition.is3K3DK                     = true;     // 3K/DK 
        ctrl.dispCondition.is3LDK3SLDK                 = true;     // 3LDK/SLDK 
        ctrl.dispCondition.is4K4DK4LDKFrom             = true;     // 4K/DK/LDK~
        // 構造                     = true;     
        ctrl.dispCondition.isWooden                    = true;     // 木造
        ctrl.dispCondition.isLightweightSteel          = true;     // 軽量鉄骨
        ctrl.dispCondition.isSteel                     = true;     // 鉄骨造
        ctrl.dispCondition.isRC                        = true;     // RC
        ctrl.dispCondition.isSRC                       = true;     // SRC
        // 方角                     = true;     
        ctrl.dispCondition.isNorth                     = true;     //北
        ctrl.dispCondition.isNortheast                 = true;     //北東
        ctrl.dispCondition.isEast                      = true;     //東
        ctrl.dispCondition.isSouthEast                 = true;     //南東
        ctrl.dispCondition.isSouth                     = true;     //南
        ctrl.dispCondition.isSouthWest                 = true;     //南西
        ctrl.dispCondition.isWest                      = true;     //西
        ctrl.dispCondition.isNorthWest                 = true;     //北西
        // 敷礼・更新料             = true;     
        ctrl.dispCondition.isNonDeposit                = true;     //敷金/保証金なし
        ctrl.dispCondition.isNonKeyMoney               = true;     //礼金なし
        ctrl.dispCondition.isNonCleaningFee            = true;     //定額修繕費なし
        ctrl.dispCondition.isNonRenewalFee             = true;     //更新料なし
        //住居条件
        ctrl.dispCondition.rentFeeFrom                 = '10000';                     //賃料 From     
        ctrl.dispCondition.rentFeeTo                   = '100000';                    //賃料 To       
        ctrl.dispCondition.isIncludeManagementFee      = true;      // 管理費込み
        ctrl.dispCondition.isIncludeParkingFee         = true;      //駐車場代込み
        ctrl.dispCondition.occupancyAreaLowerLimit     = '0';       //占有面積（下限）
        ctrl.dispCondition.occupancyAreaUpperLimit     = '999';     //占有面積（上限）
        ctrl.dispCondition.buildingAge                 = '999';      //築年数
        ctrl.dispCondition.isScore34Less               = true;     //34点未満
        ctrl.dispCondition.isScore34to35               = true;     //34～35点
        ctrl.dispCondition.isScore36More               = true;     //36点以上
        ctrl.dispCondition.isScoreAll                  = true;     //全て
        // 構造・工法
        ctrl.dispCondition.isDetachedHouse             = true;     //戸建て
        ctrl.dispCondition.isMaisonette                = true;     //メゾネット
        ctrl.dispCondition.isLoft                      = true;     //ロフト
        ctrl.dispCondition.isDesigners                 = true;     //デザイナーズ
        ctrl.dispCondition.isRenovation                = true;     //リノベーション
        ctrl.dispCondition.isCondominiumRental         = true;     //分譲賃貸
        ctrl.dispCondition.isAllWestern                = true;     //オール洋間
        // フロア・庭バルコニー
        ctrl.dispCondition.isFirstFloor                = true;     //1階
        ctrl.dispCondition.isSecondFloorOver           = true;     //2階以上
        ctrl.dispCondition.isTopFloor                  = true;     //最上階
        ctrl.dispCondition.isCornerRoom                = true;     //角部屋
        ctrl.dispCondition.isBalcony                   = true;     //バルコニー
        ctrl.dispCondition.isRoofBalcony               = true;     //ルーフバルコニー
        ctrl.dispCondition.isPrivateGarden             = true;     //専用庭
        // 駐車・駐輪共用部
        ctrl.dispCondition.isParking                   = true;  //駐車場空きあり
        ctrl.dispCondition.isInSiteParking             = true;    //敷地内駐車場
        ctrl.dispCondition.isPluralCarParking          = true;    //駐車場2台可
        ctrl.dispCondition.isBuiltInGarage             = true;    //ビルトインガレージ
        ctrl.dispCondition.isCarport                   = true;    //カーポート
        ctrl.dispCondition.isBicycleParking            = true;    //駐輪場
        ctrl.dispCondition.isBikeStorage               = true;           //バイク可
        ctrl.dispCondition.isSmallBike                 = true;    //小型バイク
        ctrl.dispCondition.isMediumBike                = true;    //中型バイク
        ctrl.dispCondition.isLargeBike                 = true;    //大型バイク
        ctrl.dispCondition.isElevator                  = true;    //エレベーター
        ctrl.dispCondition.isDeliveryBox               = true;    //宅配ボックス
        // キッチン                 = true;
        ctrl.dispCondition.isCounterKitchen            = true;    //カウンターキッチン
        ctrl.dispCondition.isSystemKitchen             = true;    //システムキッチン
        ctrl.dispCondition.isGasStove                  = true;    //ガスコンロ
        ctrl.dispCondition.isElectricStove             = true;    //電気コンロ
        ctrl.dispCondition.isInductionHeating          = true;             //IHコンロ
        ctrl.dispCondition.isTwoGasStove               = true;    //コンロ2口
        ctrl.dispCondition.isMoreGasStove              = true;    //コンロ3口以上
        // バス・トイレ洗面所       = true;
        ctrl.dispCondition.isSepalateBathAndRestroom   = true;    //バス・トイレ別
        ctrl.dispCondition.isAditionalBoiling          = true;    //追焚機能
        ctrl.dispCondition.isDehumidifierForBathroom   = true;    //浴室乾燥機
        ctrl.dispCondition.isWashlet                   = true;    //温水洗浄便座
        ctrl.dispCondition.isShowerWashBasin           = true;    //シャワー付き洗面台
        ctrl.dispCondition.isRegalLavatory             = true;    //洗面所独立
        ctrl.dispCondition.isInnerLandry               = true;    //室内洗濯機置場
        // 光熱設備・空調
        ctrl.dispCondition.isTownGas                   = true; //都市ガス
        ctrl.dispCondition.isPropaneGas                = true; //プロパンガス
        ctrl.dispCondition.isAllElectric               = true; //オール電化
        ctrl.dispCondition.isAirConditioner            = true; //エアコン
        ctrl.dispCondition.isFloorHeating              = true; //床暖房
        // 収納                     = true 
        ctrl.dispCondition.isShoesBox                  = true; //シューズボックス
        ctrl.dispCondition.isShoeCloak                 = true; //シューズクローク
        ctrl.dispCondition.isWalkInCloset              = true; //ウォークインクローゼット
        ctrl.dispCondition.isTrunkRoom                 = true; //トランクルーム
        // 通信設備                 = true 
        ctrl.dispCondition.isBSAntenna                 = true; //BSアンテナ
        ctrl.dispCondition.isCSAntenna                 = true; //CSアンテナ
        ctrl.dispCondition.isCATV                      = true; //CATV
        ctrl.dispCondition.isInternetFree              = true; //ネット使用料無料
        // セキュリティ             = true 
        ctrl.dispCondition.isMonitorIntercom           = true; //モニター付きインターホン
        ctrl.dispCondition.isAutoLock                  = true; //オートロック
        // 家具・家電               = true 
        ctrl.dispCondition.isFurniture                 = true; //家具付き
        ctrl.dispCondition.isHomeAppliance             = true; //家電付き
        // 入居条件・支払方法
        ctrl.dispCondition.isNoGuarantor              = true;   //保証人不要
        ctrl.dispCondition.isNonGuaranteeidCompany    = true;    //保証会社不要
        ctrl.dispCondition.isMusicalInstruments       = true;   //楽器相談可
        ctrl.dispCondition.isForeigner                = true;   //外国人契約可
        ctrl.dispCondition.isWelfareAvailable         = true;  //生活保護契約可
        ctrl.dispCondition.isOfficeAvailable          = true;   //事務所利用可
        ctrl.dispCondition.isPet                      = true;   //ペット可
        ctrl.dispCondition.isSmallPet                 = true;   //ペット(小型犬)
        ctrl.dispCondition.isMiddlePet                = true;   //ペット(中型犬)
        ctrl.dispCondition.isLargePet                 = true;   //ペット(大型犬)
        ctrl.dispCondition.isCat                      = true;   //ペット(猫)
        ctrl.dispCondition.isOtherPet                 = true;   //ペット(その他)
        ctrl.dispCondition.isTwoTenant                = true;   //2人入居可
        ctrl.dispCondition.isRoomShare                = true;   //ルームシェア可
        ctrl.dispCondition.isIppambutsu               = true;   //一般物
        ctrl.dispCondition.isElderly                  = true;   //高齢者歓迎
        ctrl.dispCondition.isWoman                    = true;   //女性限定
        ctrl.dispCondition.isStudent                  = true;   //学生限定マンション
        ctrl.dispCondition.isRentCreditPayment        = true;   //家賃カード決済可
        ctrl.dispCondition.isInitialCostCreditPayment = true;   //初期費用カード決済可

        // 検索実行
        ctrl.searchProperty();

        AccountPropertyConditions__c afterApc = [select id, SystemModstamp from AccountPropertyConditions__c WHERE Account__r.Name = :ACCOUNT_CUSTOMER_NAME];
        System.assertNotEquals(apc.SystemModstamp, afterApc.SystemModstamp);
    }
    // ▲2021.10.08 No.307 対応で追加

    // 検索　※条件なし
    @isTest static void searchNoneCondition() {
        // 画面起動
        PageReference pageRef = Page.GA104001View;
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GA104001Controller ctrl = new GA104001Controller();

        // 検索実行
        ctrl.searchProperty();
    }

    // ▼問合せ367で追加　モーダル動作確認　
    @isTest static void checkModal() {
        Account acc = [select id from Account WHERE Name = :ACCOUNT_CUSTOMER_NAME];
        PageReference pageRef = Page.GA104001View;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', acc.Id);
        pageRef.getParameters().put('AccountId', acc.Id);// ▼2021.10.08 No.307 対応で追加
        //コントローラ作成
        GA104001Controller testController = new GA104001Controller();
        testController.openJuniorHighSchoolDistrictModal();
        testController.closeModal();
        testController.openElementarySchoolDistrictModal();
        testController.closeModal();
        testController.openStations1Modal();
        testController.closeModal();
        testController.openStations2Modal();
        testController.closeModal();
        testController.openStations3Modal();
        testController.closeModal();
        testController.changeJuniorHighSchool();
        testController.changeElementarySchool();
        testController.changeTrainRoute1();
        testController.changeTrainRoute2();
        testController.changeTrainRoute3();
    }

    // ▼問合せ367で追加　検索処理　
    @isTest static void checkSearch() {
        Account acc = [select id from Account WHERE Name = :ACCOUNT_CUSTOMER_NAME];
        PageReference pageRef = Page.GA104001View;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', acc.Id);
        pageRef.getParameters().put('AccountId', acc.Id);// ▼2021.10.08 No.307 対応で追加
        //コントローラ作成
        GA104001Controller testController = new GA104001Controller();
        testController.searchProperty();
    }

    // ▼2021.10.08 No.307 対応で追加

	// 取引先のロールバック確認
	@isTest static void rollbackAccountTest(){
        AccountPropertyConditions__c apc = [select id, Account__c, IsForeigner__c from AccountPropertyConditions__c WHERE Account__r.Name = :ACCOUNT_CUSTOMER_NAME LIMIT 1];
        PageReference pageRef = Page.GA104001View;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', apc.Account__c);
        pageRef.getParameters().put('AccountId', apc.Account__c);

        // コントローラの初期表示を実行
        GA104001Controller testController = new GA104001Controller();
		//路線をエラーとなるように空白とする
		testController.dispCondition.trainRoute1 = [SELECT Id FROM DesiredTrainRoute__c LIMIT 1].Id;
		testController.dispCondition.stations1 = new List<station__c>();
		testController.dispCondition.IsForeigner = true;

        Test.startTest();

		// 検索実行
		testController.searchProperty();
		//エラーが発生していることを確認
		System.assertEquals(true, ApexPages.getMessages().size() != 0);

		// ロールバック確認
		Account aftAcc = [SELECT id, IsForeigner__c FROM Account WHERE Name = :ACCOUNT_CUSTOMER_NAME LIMIT 1];
		//取引先のロールバック
		system.assertEquals(false, aftAcc.IsForeigner__c);

        Test.stopTest();
	}

	// ロールバック確認
    @isTest static void rollbackApcConflictTest(){
		// 路線取得
		List<TrainRoute__c> trList = [SELECT Id, Name FROM TrainRoute__c WHERE Name LIKE '更新確認路線%'];
		// 学校取得
		List<School__c> scList = [SELECT Id, Name FROM School__c WHERE Name LIKE '更新確認学校%' ORDER BY Name];

        AccountPropertyConditions__c apc = [select id, Account__c from AccountPropertyConditions__c WHERE Account__r.Name = :ACCOUNT_CUSTOMER_NAME LIMIT 1];
        PageReference pageRef = Page.GA104001View;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', apc.Id);
        pageRef.getParameters().put('AccountId', apc.Account__c);

        // コントローラの初期表示を実行
        GA104001Controller testController = new GA104001Controller();
		testController.dispCondition.IsForeigner = true;
		
		//路線をセット
		testController.dispCondition.trainRoute1 = trList[0].Id;
		testController.dispCondition.trainRoute2 = trList[1].Id;
		testController.dispCondition.trainRoute3 = trList[2].Id;
		//学校をセット
		testController.dispCondition.juniorHighSchoolList = new List<School__c>{scList[0]};
		testController.dispCondition.elementarySchoolList = new List<School__c>{scList[1]};

        Test.startTest();

		//お客様物件条件に競合するタイミングの変更を実施
		apc.Name = '重複変更';
		update apc;
		// 検索実行
		testController.searchProperty();

		//期待通りのエラーが発生しているか確認
		Boolean hasError = false;
		for(Apexpages.Message msg:ApexPages.getMessages()){
			//他の処理で登録・更新されました。画面を更新してください。
			if (msg.getDetail().contains(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK)) hasError = true;
		}
		system.assertEquals(true, hasError);

		// ロールバック確認
		AccountPropertyConditions__c aftAcc = [SELECT id, IsForeigner__c, DesiredTrainRoute1__r.TrainRoute__r.Name,
		DesiredTrainRoute2__r.TrainRoute__r.Name, DesiredTrainRoute3__r.TrainRoute__r.Name,
		DesiredJuniorHighSchoolArea__c, DesiredElementarySchoolArea__c
		FROM AccountPropertyConditions__c WHERE Account__r.Name = :ACCOUNT_CUSTOMER_NAME LIMIT 1];
		//お客様物件条件のロールバック
		system.assertEquals(false, aftAcc.IsForeigner__c);
		//希望路線のロールバック
		system.assertEquals(false, aftAcc.DesiredTrainRoute1__r.TrainRoute__r.Name.startsWith('更新確認路線'));
		system.assertEquals(false, aftAcc.DesiredTrainRoute2__r.TrainRoute__r.Name.startsWith('更新確認路線'));
		system.assertEquals(false, aftAcc.DesiredTrainRoute3__r.TrainRoute__r.Name.startsWith('更新確認路線'));
		//希望学校のロールバック
		List<Id> dsaIdList = new List<Id>{aftAcc.DesiredJuniorHighSchoolArea__c, aftAcc.DesiredElementarySchoolArea__c};
		List<DesiredSchool__c> aftDsc = [SELECT id FROM DesiredSchool__c
		WHERE DesiredSchoolArea__c IN :dsaIdList AND School__r.Name LIKE '更新確認学校%'];
		system.assertEquals(0, aftDsc.size());

        Test.stopTest();
    }
    // ▲2021.10.08 No.307 対応で追加
}