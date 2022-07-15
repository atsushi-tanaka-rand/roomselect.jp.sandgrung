@isTest
public class GA104006Test {

    public static final String USER_NAME = 'GA104006@horaguchi.com'; 

    //テストに使用するレコードを作成
    @testSetup static void Setting(){

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
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name IN ('システム管理者')];
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

        // カスタム設定
        SystemConfig__c testSystemConfig = new SystemConfig__c();
        testSystemConfig.SupplierSearchMaxCount__c = 1000;
        testSystemConfig.UseAuthority_Portal__c = true;
        testSystemConfig.Theta360bizApiId__c = 'YRJ2hheSXZ';          // パノラマツアー認証Id //ポータルサイト構築 追加 
        testSystemConfig.Theta360bizApiAccessKey__c = '2mNySK4frewxewf487pUJ3tdfcs2Nn';    // パノラマツアーAccessKey //ポータルサイト構築 追加 
        //再販対応 追加 Start
        testSystemConfig.UseAuthority_PanoramaTour__c = true;    //利用権限_パノラマツアー
        //再販対応 追加 End
		testSystemConfig.TaxRate__c = 10;	// 税率
        insert testSystemConfig;

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

        // 建物
        Building__c testBuilding = new Building__c(
            Name = 'テスト建物'
            ,GroundFloorCount__c = 5
            ,Station1__c = testStation1.Id
            ,Station2__c = testStation2.Id
            ,Station3__c = testStation3.Id
            ,TrainRoute1__c = testTrainRoute1.Id
            ,TrainRoute2__c = testTrainRoute2.Id
            ,TrainRoute3__c = testTrainRoute3.Id
            ,StationDistance1__c = 80
            ,StationDistance2__c = 160
            ,StationDistance3__c = 240
            ,CaretakerType__c = '通勤方式'
        );
        // 名寄せ確認用 同名建物用データ 1
        Building__c testBuilding2 = new Building__c(
            Name = 'テスト建物'
            ,GroundFloorCount__c = 5
            ,Station1__c = testStation1.Id
            ,Station2__c = testStation2.Id
            ,Station3__c = testStation3.Id
            ,TrainRoute1__c = testTrainRoute1.Id
            ,TrainRoute2__c = testTrainRoute2.Id
            ,TrainRoute3__c = testTrainRoute3.Id
            ,StationDistance1__c = 90
            ,StationDistance2__c = 170
            ,StationDistance3__c = 250
            ,CaretakerType__c = '常駐'
        );
        // 名寄せ確認用 同名建物用データ 2
        Building__c testBuilding3 = new Building__c(
            Name = 'テスト建物'
            ,GroundFloorCount__c = 5
            ,Station1__c = testStation1.Id
            ,Station2__c = testStation2.Id
            ,Station3__c = testStation3.Id
            ,TrainRoute1__c = testTrainRoute1.Id
            ,TrainRoute2__c = testTrainRoute2.Id
            ,TrainRoute3__c = testTrainRoute3.Id
            ,StationDistance1__c = 100
            ,StationDistance2__c = 180
            ,StationDistance3__c = 260
            ,CaretakerType__c = '巡回方式'
        );
        List<Building__c> testBuildingList = new List<Building__c>{
             testBuilding
            ,testBuilding2
            ,testBuilding3
        };
        insert testBuildingList;

        // 取引先（元付）
        Account testFormerSupplier = new Account(
            Name = 'テスト元付業者'
            ,RecordTypeId = CommonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_SUPPLIER)
            ,IsOwner__c = false
            ,IsManagementCompany__c = true
            ,IsSubLease__c = false
            ,IsGuaranteeidCompany__c = false
            ,IsInsuranceCompany__c = false
        );
        // 取引先（貸主）
        Account testCreditor = new Account(
            Name = 'テスト貸主'
            ,RecordTypeId = CommonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_SUPPLIER)
            ,IsOwner__c = true
            ,IsManagementCompany__c = true
            ,IsSubLease__c = true
            ,IsGuaranteeidCompany__c = false
            ,IsInsuranceCompany__c = false
        );
        // 取引先（所有者）
        Account testOwner = new Account(
            Name = 'テスト所有者'
            ,RecordTypeId = CommonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_SUPPLIER)
            ,IsOwner__c = true
            ,IsManagementCompany__c = false
            ,IsSubLease__c = false
            ,IsGuaranteeidCompany__c = false
            ,IsInsuranceCompany__c = false
        );
        // 取引先（火災保険会社）
        Account testFireInsuranceComp = new Account(
            Name = 'テスト火災保険会社'
            ,RecordTypeId = CommonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_FIRE_INSURANCE)
            ,IsOwner__c = false
            ,IsManagementCompany__c = false
            ,IsSubLease__c = false
            ,IsGuaranteeidCompany__c = false
            ,IsInsuranceCompany__c = true
        );
        // 取引先（保証会社）
        Account testGuaranteeComp = new Account(
            Name = 'テスト保証会社'
            ,RecordTypeId = CommonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_GUARANTEE)
            ,IsOwner__c = false
            ,IsManagementCompany__c = false
            ,IsSubLease__c = false
            ,IsGuaranteeidCompany__c = true
            ,IsInsuranceCompany__c = false
        );
        List<Account> testAccount = new List<Account> {
            testFormerSupplier
            ,testCreditor
            ,testOwner
            ,testFireInsuranceComp
            ,testGuaranteeComp
        };
        insert testAccount;

        // 商品（火災保険）
        Item__c testFireInsuranceItem1 = new Item__c(
            Account__c = testFireInsuranceComp.Id
            ,RecordTypeId = CommonUtil.getRecordTypeId('Item__c', commonConst.ITEM_RECTYPE_FIRE_INSURANCE)
            ,ItemName__c = 'テスト火災保険商品１'
            ,FireInsuranceMonth__c = 2000
            ,FireInsuranceYear__c = null
            ,PaymentType__c = CommonConst.ITEM_PAYMENTTYPE_YEAR
            ,PaymentYear__c = 1
        );
        Item__c testFireInsuranceItem2 = new Item__c(
            Account__c = testFireInsuranceComp.Id
            ,RecordTypeId = CommonUtil.getRecordTypeId('Item__c', commonConst.ITEM_RECTYPE_FIRE_INSURANCE)
            ,ItemName__c = 'テスト火災保険商品２'
            ,FireInsuranceMonth__c = null
            ,FireInsuranceYear__c = 10000
            ,PaymentType__c = CommonConst.ITEM_PAYMENTTYPE_MONTH
            ,PaymentYear__c = 2
        );
        // 商品（保証）
        Item__c testGuaranteeItem1 = new Item__c(
            Account__c = testGuaranteeComp.Id
            ,RecordTypeId = CommonUtil.getRecordTypeId('Item__c', commonConst.ITEM_RECTYPE_GUARANTEE_PLAN)
            ,ItemName__c = 'テスト保証商品１'
            ,AssuranceContent__c = '保証内容１行目\n保証内容２行目'
            ,DirectDebitFee__c = 2000
            ,DirectDebitFeeTaxType__c = CommonConst.PROPERTY_TAXTYPE_TAXABLE
        );
        Item__c testGuaranteeItem2 = new Item__c(
            Account__c = testGuaranteeComp.Id
            ,RecordTypeId = CommonUtil.getRecordTypeId('Item__c', commonConst.ITEM_RECTYPE_GUARANTEE_PLAN)
            ,ItemName__c = 'テスト保証商品２'
            ,AssuranceContent__c = '保証内容１行目\n保証内容２行目'
            ,DirectDebitFee__c = 5000
            ,DirectDebitFeeTaxType__c = CommonConst.PROPERTY_TAXTYPE_NOTAXABLE
        );
        List<Item__c> testItem = new List<Item__c> {
            testFireInsuranceItem1
            ,testFireInsuranceItem2
            ,testGuaranteeItem1
            ,testGuaranteeItem2
        };
        insert testItem;

        // 取引先保険保証（火災保険）
        InsuranceGuarantee__c testInsuranceGuarantee1 = new InsuranceGuarantee__c(
            Account__c = testFormerSupplier.Id
            ,Item__c = testFireInsuranceItem1.Id
            ,RecordTypeId = CommonUtil.getRecordTypeId('InsuranceGuarantee__c', commonConst.INSURANCE_RECTYPE_GUARANTEE_FIREINSURANCE)
        );
        InsuranceGuarantee__c testInsuranceGuarantee2 = new InsuranceGuarantee__c(
            Account__c = testFormerSupplier.Id
            ,Item__c = testFireInsuranceItem2.Id
            ,RecordTypeId = CommonUtil.getRecordTypeId('InsuranceGuarantee__c', commonConst.INSURANCE_RECTYPE_GUARANTEE_FIREINSURANCE)
        );
        // 取引先保険保証（保証）
        InsuranceGuarantee__c testInsuranceGuarantee3 = new InsuranceGuarantee__c(
            Account__c = testFormerSupplier.Id
            ,Item__c = testGuaranteeItem1.Id
            ,RecordTypeId = CommonUtil.getRecordTypeId('InsuranceGuarantee__c', commonConst.INSURANCE_RECTYPE_GUARANTEE_GUARANTEE)
        );
        InsuranceGuarantee__c testInsuranceGuarantee4 = new InsuranceGuarantee__c(
            Account__c = testFormerSupplier.Id
            ,Item__c = testGuaranteeItem2.Id
            ,RecordTypeId = CommonUtil.getRecordTypeId('InsuranceGuarantee__c', commonConst.INSURANCE_RECTYPE_GUARANTEE_GUARANTEE)
        );
        List<InsuranceGuarantee__c> testInsuranceGuarantee = new List<InsuranceGuarantee__c> {
            testInsuranceGuarantee1
            ,testInsuranceGuarantee2
            ,testInsuranceGuarantee3
            ,testInsuranceGuarantee4
        };
        insert testInsuranceGuarantee;

        // 管理会社指定商品
        ManagementCompanyItem__c testManagementCompanyItem1 = new ManagementCompanyItem__c(
            Account__c = testFormerSupplier.Id
            ,ItemName__c = 'テスト管理会社指定商品１'
            ,Amount__c = 3000
            ,PaymentType__c = CommonConst.MANAGEMENTCOMPANYITEM_PAYMENTTYPE_MONTH
            ,TaxType__c = CommonConst.PROPERTY_TAXTYPE_TAXABLE
        );
        ManagementCompanyItem__c testManagementCompanyItem2 = new ManagementCompanyItem__c(
            Account__c = testFormerSupplier.Id
            ,ItemName__c = 'テスト管理会社指定商品２'
            ,Amount__c = 5000
            ,PaymentType__c = CommonConst.MANAGEMENTCOMPANYITEM_PAYMENTTYPE_YEAR
            ,TaxType__c = CommonConst.PROPERTY_TAXTYPE_NOTAXABLE
        );
        ManagementCompanyItem__c testManagementCompanyItem3 = new ManagementCompanyItem__c(
            Account__c = testFormerSupplier.Id
            ,ItemName__c = 'テスト管理会社指定商品３'
            ,Amount__c = 4000
            ,PaymentType__c = CommonConst.MANAGEMENTCOMPANYITEM_PAYMENTTYPE_FIRST
            ,TaxType__c = CommonConst.PROPERTY_TAXTYPE_TAXABLE
        );
        List<ManagementCompanyItem__c> testManagementCompanyItem = new List<ManagementCompanyItem__c> {
            testManagementCompanyItem1
            ,testManagementCompanyItem2
            ,testManagementCompanyItem3
        };
        insert testManagementCompanyItem;

        // 文例 ▼ 2022.03.30 CHINTAI対応時、記載場所移動
        String usageScreen = CommonConst.EXAMPLESENTENCE_USAGESCREEN_REGISTPROPERTY; //使用画面
        ExampleSentence__c testExampleSentence1 = new ExampleSentence__c(
            Name = 'テスト文例１'
            ,Folder__c = 'テスト文例フォルダ１'
            ,ExampleSentence__c = 'テスト文例内容１\nテスト文例内容２行目'
            ,UsageScreen__c = usageScreen
        );
        for (Integer i; i < 26; i++) {
            testExampleSentence1.ExampleSentence__c += '1234567890';
        }
        ExampleSentence__c testExampleSentence2 = new ExampleSentence__c(
            Name = 'テスト文例２'
            ,Folder__c = 'テスト文例フォルダ１'
            ,ExampleSentence__c = 'テスト文例内容２\nテスト文例内容２行目'
            ,UsageScreen__c = usageScreen
        );
        ExampleSentence__c testExampleSentence3 = new ExampleSentence__c(
            Name = 'テスト文例３'
            ,Folder__c = 'テスト文例フォルダ２'
            ,ExampleSentence__c = 'テスト文例内容３\nテスト文例内容２行目'
            ,UsageScreen__c = usageScreen
        );
        List<ExampleSentence__c> testExampleSentence = new List<ExampleSentence__c> {
            testExampleSentence1
            ,testExampleSentence2
            ,testExampleSentence3
        };
        insert testExampleSentence;
		// ▲ 2022.03.30 CHINTAI対応時、記載場所移動

        // 物件
        Property__c testProperty = new Property__c(
            Name                        = '_t_'                               // 部屋番号
            ,AllRentFee__c              = 0                                         // 総賃料
            ,Score__c                   = 0                                         // 点数
            ,IsMergeCompletedFlag__c    = false                                     // 名寄せ完了フラグ
            ,Building__c                = testBuilding.Id                           // 建物
            ,FormerSupplier__c          = testFormerSupplier.Id                     // 元付業者
            ,Creditor__c                = testCreditor.Id                           // 貸主
            ,Owner__c                   = testOwner.Id                              // 所有者
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
            ,RentType__c                = CommonConst.PROPERTY_RENTTYPE_APPLICABLE  // 定期借家区分
            ,RentTermYear__c            = 3                                         // 定借期間（年）
            ,RentTermMonth__c           = 4                                         // 定借期間（月）
            ,RentTermDay__c             = 5                                         // 定借期間（日）
            ,RenovationComplateYear__c  = 2019                                      // リノベ施工完了（年）
            ,RenovationComplateMonth__c = 11                                        // リノベ施工完了（月）
            ,RenovationContent__c       = 'テストリノベ施工内容'                      // リノベ施工内容
            ,FreeRentTermMonth__c       = 12                                        // フリーレント期間（ヶ月）
            ,FreeRentContent__c         = 'テストフリーレント内容'                    // フリーレント内容
            ,SpecificExcellentRentBurdenUpperLimit__c   = 10000                     // 特優賃入居負担額上限
            ,SpecificExcellentRentBurdenLowerLimit__c   = 2000                      // 特優賃入居負担額下限
            ,SpecificExcellentRentFeeFluctuationType__c = '傾斜型'                  // 特優賃料金変動区分
            ,SpecificExcellentRentFeeUpwardRate__c      = 10.5                      // 特優賃上昇率
            ,SpecificExcellentRentSupportYears__c       = 2                         // 特優賃家賃補助年数
            ,SpecificExcellentRentRemarks__c            = 'テスト特優賃備考'          // 特優賃備考
            ,PropertyRemarksPublic__c   = '_t_備考（公開）'                    // 物件備考（公開）
            ,PropertyRemarksPrivate__c  = '_t_備考（非公開）'                  // 物件備考（非公開）
            ,PropertyComment__c         = '_t_コメント'                       // 物件コメント
            ,RepresentativeComment__c   = 'テスト担当者コメント'                      // 担当者コメント
            ,MaintenanceCommentArea__c  = ''                                        // メンテナンスコメント
            ,RentFee__c                 = 40000                                     // 賃料
            ,WortFee__c                 = 2000                                      // 水道料金
            ,WortFeeTaxType__c          = CommonConst.PROPERTY_TAXTYPE_TAXABLE      // 水道料金税区分
            ,SecurityDepositYen__c      = null                                      // 敷金（円）
            ,SecurityDepositMonth__c    = null                                      // 敷金（ヵ月）
            ,SecurityDepositUnit__c     = CommonConst.PROPERTY_FEEUNIT_YEN          // 敷金単位
            ,CancellationActualFeeYen__c    = 40000                                 // 敷引・償却（円）
            ,CancellationActualFeeMonth__c  = 1                                     // 敷引・償却（ヵ月）
            ,CancellationActualFeeRate__c   = null                                  // 敷引・償却（％）
            ,CancellationActualFeeUnit__c   = CommonConst.PROPERTY_FEEUNIT_MONTH    // 敷引・償却単位
            ,ManagementFee__c           = 2500                                      // 管理費
            ,ManagementFeeTaxType__c    = CommonConst.PROPERTY_TAXTYPE_TAXABLE      // 管理費税区分
            ,CATVFee__c                 = 3000                                      // CATV
            ,CATVTaxType__c             = CommonConst.PROPERTY_TAXTYPE_TAXABLE      // CATV税区分
            ,DepositYen__c              = 44000                                     // 保証料金（円）
            ,DepositMonth__c            = 1.1                                       // 保証料金（ヵ月）
            ,DepositUnit__c             = CommonConst.PROPERTY_FEEUNIT_MONTH        // 保証金単位
            ,RenewalFeeYen__c           = 48000                                     // 更新料（円）
            ,RenewalFeeMonth__c         = 1.2                                       // 更新料（ヵ月）
            ,RenewalFeeUnit__c          = CommonConst.PROPERTY_FEEUNIT_MONTH        // 更新料単位
            ,RenewalFeeTaxType__c       = CommonConst.PROPERTY_TAXTYPE_TAXABLE      // 更新料税区分
            ,TownshipFee__c             = 1000                                      // 町会費
            ,TownshipFeeTaxType__c      = CommonConst.PROPERTY_TAXTYPE_TAXABLE      // 町会費税区分
            ,TownshipFeePaymentType__c  = CommonConst.PROPERTY_PAYMENTTYPE_MONTH    // 町会費支払区分
            ,GarbageDisposalFee__c      = 1500                                      // ゴミ処理費
            ,GarbageDisposalFeeTaxType__c       = CommonConst.PROPERTY_TAXTYPE_TAXABLE      // ゴミ処理費税区分
            ,GarbageDisposalFeePaymentType__c   = CommonConst.PROPERTY_PAYMENTTYPE_MONTH    // ゴミ処理費支払区分
            ,KeyMoneyYen__c             = 52000                                     // 礼金（円）
            ,KeyMoneyMonth__c           = 1.3                                       // 礼金（ヵ月）
            ,KeyMoneyUnit__c            = CommonConst.PROPERTY_FEEUNIT_MONTH        // 礼金単位
            ,TownshipInitialFee__c      = 5000                                      // 入町費
            ,TownshipInitialFeeTaxType__c   = CommonConst.PROPERTY_TAXTYPE_TAXABLE  // 入町費税区分
            ,CleaningFeeYen__c          = 56000                                     // 定額修繕費（円）
            ,CleaningFeeMonth__c        = 1.4                                       // 定額修繕費（ヵ月）
            ,CleaningFeeUnit__c         = CommonConst.PROPERTY_FEEUNIT_MONTH        // 定額修繕費単位
            ,CleaningFeeTaxType__c      = CommonConst.PROPERTY_TAXTYPE_TAXABLE      // 定額修繕費税区分
            ,CleaningFeePaymentType__c  = CommonConst.PROPERTY_PAYMENTTYPE_BEFORE_OCCUPANCY // 定額修繕費支払区分
            ,KeyExchangeFee__c          = 3500                                      // 鍵交換費
            ,KeyExchangeFeeTaxType__c   = CommonConst.PROPERTY_TAXTYPE_TAXABLE      // 鍵交換費税区分
            ,MonetaryPublic__c          = 'テスト金銭備考（公開）'                    // 金銭備考（公開）
            ,MonetaryPrivate__c         = 'テスト金銭備考（非公開）'                  // 金銭備考（非公開）
            ,BicycleParkingType__c      = CommonConst.PROPERTY_BICYCLEPARKINGTYPE_EXISTS    // 駐輪場種別
            ,BicycleParkingFee__c       = 500                                       // 駐輪場代
            ,BicycleParkingFeeTaxType__c = CommonConst.PROPERTY_TAXTYPE_TAXABLE     // 駐輪場代税区分
            ,ParkingType__c             = CommonConst.PROPERTY_PARKINGTYPE_NEIGHBORHOOD_SECURE // 駐車場種別
            ,ParkingDistance__c         = 120                                       // 近隣駐車場までの距離
            ,ParkingFee__c              = 4000                                      // 駐車場料金
            ,ParkingFeeTaxType__c       = CommonConst.PROPERTY_TAXTYPE_TAXABLE      // 駐車場料金税区分
            ,ParkingDepositYen__c       = 12000                                     // 駐車場保証料金
            ,ParkingDepositMonth__c     = 0.3                                       // 駐車場保証料金（ヵ月）
            ,ParkingDepositTaxType__c   = CommonConst.PROPERTY_TAXTYPE_TAXABLE      // 駐車場保証料金税区分
            ,ParkingDepositUnit__c      = CommonConst.PROPERTY_FEEUNIT_MONTH        // 駐車場保証料金単位
            ,ParkingCompoundingFeeYen__c        = 16000                             // 駐車場手数料（円）
            ,ParkingCompoundingFeeMonth__c      = 0.4                               // 駐車場手数料（ヵ月）
            ,ParkingCompoundingFeeUnit__c       = CommonConst.PROPERTY_FEEUNIT_MONTH    // 駐車場手数料単位
            ,ParkingCompoundingFeeTaxType__c    = CommonConst.PROPERTY_TAXTYPE_TAXABLE  // 駐車場手数料税区分
            ,ParkingRemarksPublic__c    = 'テスト駐車場備考（公開）'                  // 駐車場備考（公開）
            ,ParkingRemarksPrivate__c   = 'テスト駐車場備考（非公開）'                // 駐車場備考（非公開）
            ,BikeStorageType__c         = CommonConst.PROPERTY_BIKESTORAGETYPE_EXISTS   // バイク置場種別
            ,BikeParkingSmallFee__c         = 1100                                  // 小型バイク置場料金
            ,BikeParkingSmallFeeTaxType__c  = CommonConst.PROPERTY_TAXTYPE_TAXABLE  // 小型バイク置場料金税区分
            ,BikeParkingMediumFee__c        = 2200                                  // 中型バイク置場料金
            ,BikeParkingMediumFeeTaxType__c = CommonConst.PROPERTY_TAXTYPE_TAXABLE  // 中型バイク置場料金税区分
            ,BikeParkinLargeFee__c          = 3300                                  // 大型バイク置場料金
            ,BikeParkinLargeFeeTaxType__c   = CommonConst.PROPERTY_TAXTYPE_TAXABLE  // 大型バイク置場料金税区分
            ,IsShortTermPenalty__c          = CommonConst.PROPERTY_ISSHORTTERMPENALTY_EXISTS    // 短期解約違約金有無
            ,ShortTermPenaltyLessYear__c    = 1                                     // 短期解約違約金未満（年）
            ,ShortTermPenaltyFee__c         = 2                                     // 短期解約違約金
            ,ShortTermPenaltyLessYear2__c   = 2                                     // 短期解約違約金未満（年）２
            ,ShortTermPenaltyFee2__c        = 3                                     // 短期解約違約金２
            ,FireInsuranceUseType__c    = CommonConst.PROPERTY_FIREINSURANCEUSETYPE_EXISTS      // 火災保険料（加入義務）
            ,FireInsurancePlan__c       = testFireInsuranceItem1.Id                             // 火災保険タイトル
            ,GuaranteeidCompanyType__c  = CommonConst.PROPERTY_GUARANTEEIDCOMPANYTYPE_POSSIBLE  // 保証会社（利用区分）
            ,Guaranteeid__c             = testGuaranteeItem1.Id                                 // 保証タイトル
            ,ADFeeYen__c                = 36000                                     // 広告料（円）
            ,ADFeeMonth__c              = 0.9                                       // 広告料（ヵ月）
            ,ADFeeRate__c               = null                                      // 広告料（％）
            ,ADFeeUnit__c               = CommonConst.PROPERTY_FEEUNIT_MONTH        // 広告料単位
            ,ADFeeTaxType__c            = CommonConst.PROPERTY_TAXTYPE_TAXINCLUDED  // 広告料税区分
            ,ADFeeComment__c            = 'テスト広告料コメント'                      // 広告料コメント
            ,ADRemarksPublic__c         = 'テスト広告備考（公開）'                    // 広告備考（公開）
            ,ADRemarksPrivate__c        = 'テスト広告備考（非公開）'                  // 広告備考（非公開）
            ,RewardBurdenLender__c          = 10.5                                  // 報酬負担貸主
            ,RewardBurdenBorrower__c        = 19.5                                  // 報酬負担借主
            ,RewardSplitFormerSupplier__c   = 30.5                                  // 報酬配分元付
            ,RewardSplitCustomer__c         = 39.5                                  // 報酬配分客付
            ,KeyPlace__c                = 'テスト鍵所在'                             // 鍵所在
            ,AthomePanoramaContentsId__c    = '1234567890'                          // athomeパノラマコンテンツID
            ,AtHomePanoramaShop__c      = null                                      // athomeパノラマ掲載店舗
            ,HomesPanoramaShop__c       = null                                      // HOME'Sパノラマ掲載店舗
            ,SuumoPanoramaShop__c       = null                                      // SUUMOパノラマ掲載店舗
            ,WebPublishing__c           = CommonConst.PROPERTY_WEBPUBLISHING_NO     // Web公開
            ,IsPropertyNameHiddenFlag__c    = false                                 // 物件名非表示フラグ
            // ,WebPostingComment__c           = 'テストWeb掲載時コメント'               // Web掲載時コメント
            ,ImportType__c                  = CommonConst.PROPERTY_IMPORTTYPE_REALNETPRO    // 取込区分
            ,MaintenancePropertyCode__c     = 'qwertyuiop'                          // メンテナンス物件コード
            ,ManualMaintenanceDate__c       = Date.newInstance(2020, 2, 17)         // 手動最終メンテナンス日
            ,AutoMaintenanceDate__c         = Date.newInstance(2020, 2, 15)         // 自動最終メンテナンス日
            // ,HomesPropertyFeature__c        = 'テストHOME\'S物件の特徴'              // HOME'S物件の特徴
            ,HomesRemarks__c                = 'テストHOME\'S備考'                    // HOME'S備考
            // ,SuumoNetCatch__c               = 'テストSUUMOネット用キャッチ'           // SUUMOネット用キャッチ
            // ,SuumoNetCatchComment__c        = 'テストSUUMOネット用キャッチコメント'    // SUUMOネット用キャッチコメント
            ,SuumoRemarks__c                = 'テストSUUMO備考'                      // SUUMO備考
            // ,AthomeRecommendComment__c      = 'テストathomeおすすめコメント'          // athomeおすすめコメント
            ,AthomeRecommendCommentStaffId__c   = 'asdfghjkl'                       // athomeおすすめコメントスタッフID
            ,AtHomeRemarks__c               = 'テストathome備考'                     // athome備考
            ,ChintaiMagazineComment__c		= testExampleSentence3.Id				// CHINTAI雑誌コメント 2022.03.30 CHINTAI対応追加
        );
        // 名寄せ確認用 同名物件用データ 1(※テスト時に名称変更)
        Property__c testProperty2 = new Property__c(
            Name                        = '_t_2'                              // 部屋番号
            ,IsMergeCompletedFlag__c    = false                                     // 名寄せ完了フラグ
            ,Building__c                = testBuilding2.Id                          // 建物
            ,FormerSupplier__c          = testFormerSupplier.Id                     // 元付業者
            ,Creditor__c                = testCreditor.Id                           // 貸主
            ,Owner__c                   = testOwner.Id                              // 所有者
        );
        // 名寄せ確認用 同名物件用データ 2(※テスト時に名称変更)
        Property__c testProperty3 = new Property__c(
            Name                        = '_t_3'                              // 部屋番号
            ,IsMergeCompletedFlag__c    = true                                      // 名寄せ完了フラグ
            ,Building__c                = testBuilding3.Id                          // 建物
            ,FormerSupplier__c          = testFormerSupplier.Id                     // 元付業者
            ,Creditor__c                = testCreditor.Id                           // 貸主
            ,Owner__c                   = testOwner.Id                              // 所有者
        );
        // 名寄せ確認用 同名物件用データ 3(※テスト時に名称変更)
        Property__c testProperty4 = new Property__c(
            Name                        = '_t_4'                              // 部屋番号
            ,IsMergeCompletedFlag__c    = true                                      // 名寄せ完了フラグ
            ,Building__c                = testBuilding3.Id                          // 建物
            ,FormerSupplier__c          = testFormerSupplier.Id                     // 元付業者
            ,Creditor__c                = testCreditor.Id                           // 貸主
            ,Owner__c                   = testOwner.Id                              // 所有者
        );
        // 所在階異常データ
        Property__c testProperty5 = new Property__c(
            Name                        = '_t_5'                              // 部屋番号
            ,IsMergeCompletedFlag__c    = true                                // 名寄せ完了フラグ
            ,Building__c                = testBuilding.Id                     // 建物
            ,FormerSupplier__c          = testFormerSupplier.Id               // 元付業者
            ,Creditor__c                = testCreditor.Id                     // 貸主
            ,Owner__c                   = testOwner.Id                        // 所有者
            ,Floor__c                   = 7                                   // 所在階
        );
        List<Property__c> testPropertyList = new List<Property__c> {
             testProperty
            ,testProperty2
            ,testProperty3
            ,testProperty4
            ,testProperty5
        };
        insert testPropertyList;

        // 部屋
        Room__c testRoom1 = new Room__c(
            Property__c = testProperty.Id
            ,RoomFloorSpace__c = 6
            ,RoomType__c = '洋室'
        );
        Room__c testRoom2 = new Room__c(
            Property__c = testProperty.Id
            ,RoomFloorSpace__c = 5.5
            ,RoomType__c = '和室'
        );
        Room__c testRoom3 = new Room__c(
            Property__c = testProperty.Id
            ,RoomFloorSpace__c = 6
            ,RoomType__c = 'LDK'
        );
        List<Room__c> testRoom = new List<Room__c> {
            testRoom1
            ,testRoom2
            ,testRoom3
        };
        insert testRoom;

        Integer byteSize = 1000;
        String bodyString = ('0').repeat(byteSize);
        // 添付ファイル
        Attachment testAttachment = new Attachment(
            ParentId = testProperty.Id
            ,Name = 'テスト添付'
            ,Body = Blob.valueOf(bodyString)
        );
        insert testAttachment;

        // 物件管理会社指定商品
        PropertyManageCompayItem__c testPropertyManageCompayItem1 = new PropertyManageCompayItem__c(
            Property__c = testProperty.Id
            ,Account__c = testFormerSupplier.Id
            ,Item__c = testManagementCompanyItem2.Id
        );
        PropertyManageCompayItem__c testPropertyManageCompayItem2 = new PropertyManageCompayItem__c(
            Property__c = testProperty.Id
            ,Account__c = testFormerSupplier.Id
            ,Item__c = testManagementCompanyItem3.Id
        );
        List<PropertyManageCompayItem__c> testPropertyManageCompayItem = new List<PropertyManageCompayItem__c> {
            testPropertyManageCompayItem1
            ,testPropertyManageCompayItem2
        };
        insert testPropertyManageCompayItem;

        // 店舗
        Shop__c testShop1 = new Shop__c(
            Name = 'テスト店舗１'
            ,PortalSitePostingDistrict__c = '港区'
        );
        Shop__c testShop2 = new Shop__c(
            Name = 'テスト店舗２'
            ,PortalSitePostingDistrict__c = '西区'
        );
        List<Shop__c> testShop = new List<Shop__c> {
            testShop1
            ,testShop2
        };
        insert testShop;

        // ポータルサイト掲載物件
        PortalSitePostingProperty__c testPortalSitePostingProperty1 = new PortalSitePostingProperty__c(
            Property__c = testProperty.Id
            ,Shop__c = testShop1.Id
            ,IsSuumo__c = true
            ,IsHomes__c = true
            ,IsAtHome__c = false
            ,IsChintaiNet__c = false // 2022.03.30 CHINTAI対応追加
            ,IsChintaiPanoramaPosting__c = false // 2022.03.30 CHINTAI対応追加
        );
        PortalSitePostingProperty__c testPortalSitePostingProperty2 = new PortalSitePostingProperty__c(
            Property__c = testProperty.Id
            ,Shop__c = testShop2.Id
            ,IsSuumo__c = true
            ,IsHomes__c = false
            ,IsAtHome__c = true
            ,IsChintaiNet__c = true // 2022.03.30 CHINTAI対応追加
            ,IsChintaiPanoramaPosting__c = false // 2022.03.30 CHINTAI対応追加
        );
        List<PortalSitePostingProperty__c> testPortalSitePostingProperty = new List<PortalSitePostingProperty__c> {
            testPortalSitePostingProperty1
            ,testPortalSitePostingProperty2
        };
        insert testPortalSitePostingProperty;

        // 2022.03.30 CHINTAI対応時、記載場所移動

        // 物件メンテナンス履歴
        PropertyMaintenanceHistory__c testPropertyMaintenanceHistory = new PropertyMaintenanceHistory__c(
            Property__c = testProperty.Id
            // ,LastModifiedDate
            ,MaintenanceType__c = '手動追加'
            // ,LastModifiedBy.Name
            ,MaintenanceCommentArea__c = 'テストメンテナンスコメント'
        );
        insert testPropertyMaintenanceHistory;

        // 物件条件
        PropertyConditions__c testPropertyConditions = new PropertyConditions__c(
            Property__c                         = testProperty.Id  // 物件
            ,IsRenovation__c                    = true  // リノベーション
            ,IsFreeRent__c                      = true  // フリーレント
            ,IsSpecialRent__c                   = true  // 特定優良賃貸住宅
            ,IsBicycleParking__c                = true  // 駐輪場
            ,IsPluralCarParking__c              = true  // 駐車場2台可
            ,IsMaisonette__c                    = true  // メゾネット
            ,IsLoft__c                          = true  // ロフト
            ,IsDesigners__c                     = true  // デザイナーズ
            ,IsCondominiumRental__c             = true  // 分譲賃貸
            ,IsAllWesternStyleRoom__c           = true  // オール洋間
            ,IsTowerMansion__c                  = true  // タワーマンション
            ,IsBarrierFree__c                   = true  // バリアフリー
            ,IsOuterWallTile__c                 = true  // 外壁タイル張り
            ,IsDampingStructure__c              = true  // 制震構造
            ,IsSeismicStructure__c              = false // 耐震構造
            ,IsSeismicIsolationStructure__c     = false // 免震構造
            ,IsUndergroundRoom__c               = true  // 地下室
            ,IsSoundproofRoom__c                = true  // 防音室
            ,IsSepticTank__c                    = true  // 浄化槽
            ,IsQuietResidenceTown__c            = true  // 閑静な住宅街
            ,IsCornerRoom__c                    = true  // 角部屋
            ,IsBayWindow__c                     = true  // 出窓
            ,IsPrivateGarden__c                 = true  // 専用庭
            ,IsBalcony__c                       = true  // バルコニー
            ,IsRoofBalcony__c                   = true  // ルーフバルコニー
            ,IsWoodDeck__c                      = true  // ウッドデッキ
            ,IsBuiltInGarage__c                 = true  // ビルトインガレージ
            ,IsCarport__c                       = true  // カーポート
            ,IsElevator__c                      = true  // エレベーター
            ,IsPluralElevators__c               = true  // エレベーター2基
            ,IsInSiteTtrashArea__c              = true  // 敷地内ごみ置き場
            ,IsAnytimeTtrashArea__c             = true  // 24時間ゴミ出し可
            ,IsFrontService__c                  = true  // フロントサービス
            ,IsDeliveryBox__c                   = true  // 宅配ボックス
            ,IsCleaningBox__c                   = true  // クリーニングボックス
            ,IsCoinLaundry__c                   = true  // コインランドリー
            ,IsCounterKitchen__c                = true  // カウンターキッチン
            ,IsSystemKitchen__c                 = true  // システムキッチン
            ,IsGasStove__c                      = true  // ガスコンロ
            ,IsElectricStove__c                 = false // 電気コンロ
            ,IsIhStove__c                       = false // IHコンロ
            ,IsTwoGasStove__c                   = true  // コンロ2口
            ,IsMoreGasStove__c                  = false // コンロ3口以上
            ,IsWaterPurifier__c                 = true  // 浄水器
            ,IsDishwasher__c                    = true  // 食器洗い乾燥機
            ,IsDisposer__c                      = true  // ディスポーザー
            ,IsSeparate__c                      = true  // バス・トイレ別
            ,IsReheating__c                     = true  // 追焚機能
            ,IsHotWaterFormula__c               = true  // 高温差湯式
            ,IsBathroomDryer__c                 = true  // 浴室乾燥機
            ,IsBathroomFloorHeating__c          = true  // 浴室床暖房
            ,IsTvBath__c                        = true  // TV付浴室
            ,IsWashletToiletSeat__c             = true  // 温水洗浄便座
            ,IsTanklessToilet__c                = true  // タンクレストイレ
            ,IsWashroomDscrete__c               = true  // 洗面所独立
            ,IsShowerWashBasin__c               = true  // シャワー付洗面台
            ,IsShowerRoom__c                    = true  // シャワールーム
            ,IsMistSauna__c                     = true  // ミストサウナ
            ,IsIndoorWashingMachineStorage__c   = true  // 室内洗濯機置場
            ,IsCityGas__c                       = true  // 都市ガス
            ,IsPropaneGas__c                    = false // プロパンガス
            ,IsAllElectric__c                   = false // オール電化
            ,IsAirConditioner__c                = true  // エアコン
            ,IsFloorHeating__c                  = true  // 床暖房
            ,IsGasHeating__c                    = true  // ガス暖房
            ,IsKeroseneHeating__c               = true  // 灯油暖房
            ,IsFurniture__c                     = true  // 家具付き
            ,IsHomeAppliance__c                 = true  // 家電付き
            ,IsWashingDryer__c                  = true  // 洗濯乾燥機
            ,IsFlooring__c                      = true  // フローリング
            ,IsCushionFloor__c                  = true  // クッションフロア
            ,IsSolidWood__c                     = true  // 無垢材使用
            ,IsStormShutter__c                  = true  // 雨戸
            ,IsShutter__c                       = true  // シャッター
            ,IsElectricShutter__c               = true  // 電動シャッター
            ,IsHighSash__c                      = true  // ハイサッシ
            ,IsSoundproofSash__c                = true  // 防音サッシ
            ,IsPairGlass__c                     = true  // 複層ガラス
            ,IsShoesBox__c                      = true  // シューズボックス
            ,IsShoeCloak__c                     = true  // シューズクローク
            ,IsWalkInCloset__c                  = true  // ウォークインクローゼット
            ,IsTrunkRoom__c                     = true  // トランクルーム
            ,IsUnderfloorStorage__c             = true  // 床下収納
            ,IsBSAntenna__c                     = true  // BSアンテナ
            ,IsCSAntenna__c                     = true  // CSアンテナ
            ,IsCATV__c                          = true  // CATV
            ,IsCATVInternet__c                  = true  // CATVインターネット
            ,IsCATVFree__c                      = true  // CATV使用料不要
            ,IsOpticalFiber__c                  = true  // 光ファイバー
            ,IsInternetFree__c                  = true  // ネット使用料無料
            ,IsMonitorIntercom__c               = true  // モニター付きインターホン
            ,IsAutoLock__c                      = true  // オートロック
            ,IsDimpleKey__c                     = true  // ディンプルキー
            ,IsSurveillanceCamera__c            = true  // 防犯カメラ
            ,IsSecurityGlass__c                 = true  // 防犯ガラス
            ,IsAnytimeSecurity__c               = true  // 24時間セキュリティ
            ,IsSecurityCompanyJoin__c           = true  // セキュリティ会社加入済
            ,IsNoGuarantor__c                   = true  // 保証人不要
            ,IsMusicalInstruments__c            = true  // 楽器相談可
            ,IsForeigner__c                     = true  // 外国人契約可
            ,IsWelfareAvailable__c              = true  // 生活保護契約可
            ,IsOfficeAvailable__c               = true  // 事務所利用可
            ,IsPet__c                           = true  // ペット相談
            ,IsSmallPet__c                      = true  // ペット（小型犬）
            ,IsMiddlePet__c                     = true  // ペット（中型犬）
            ,IsLargePet__c                      = true  // ペット（大型犬）
            ,IsCat__c                           = true  // ペット（猫）
            ,IsOtherPet__c                      = true  // ペット（その他）
            ,IsTwoTenant__c                     = true  // 2人入居可
            ,IsRoomShare__c                     = true  // ルームシェア可
            ,IsMonthly__c                       = true  // マンスリー可
            ,IsCustomize__c                     = true  // カスタマイズ可
            ,IsDIY__c                           = true  // DIY可
            ,IsITImportantDescription__c        = true  // IT重説 対応物件
            ,IsRentCreditPayment__c             = true  // 家賃カード決済可
            ,IsInitialCostCreditPayment__c      = true  // 初期費用カード決済可
            ,IsWoman__c                         = true  // 女性限定
            ,IsStudent__c                       = true  // 学生限定
            ,IsCorporation__c                   = true  // 法人契約限定
            ,IsElderly__c                       = true  // 高齢者歓迎
            ,IsLbgt__c                          = true  // LGBTフレンドリー
            ,IsNotChild__c                      = true  // 子供不可
            ,PetRemarks__c                      = 'テストペット（その他）備考'  // ペット（その他）備考
            ,IsTwoStation__c                    = true  // 2駅利用可
            ,IsTwoTrainRoute__c                 = true  // 2沿線利用可
            ,IsThreeStation__c                  = true  // 3駅以上利用可
            ,IsThreeTrainRoute__c               = true  // 3沿線以上利用可
            ,IsFrontStation__c                  = true  // 駅前
            ,IsParking__c                       = true  // 駐車場空きあり
            ,IsInSiteParking__c                 = true  // 敷地内駐車場
            ,IsBikeStorage__c                   = true  // バイク可
            ,IsSmallBike__c                     = true  // 小型バイク
            ,IsMediumBike__c                    = true  // 中型バイク
            ,IsLargeBike__c                     = true  // 大型バイク
            ,IsFirstFloor__c                    = true  // 1階
            ,IsSecondFloorOver__c               = true  // 2階以上
            ,IsTopFloor__c                      = true  // 最上階
            ,IsSouth__c                         = true  // 南向き
            ,IsJanitor__c                       = true  // 管理人有
            ,IsJanitorReside__c                 = true  // 管理人（常駐）
            ,IsJanitorCommuter__c               = true  // 管理人（通勤）
            ,IsJanitorPatrol__c                 = true  // 管理人（巡回）
            ,IsTurnkey__c                       = true  // 即入居可
            ,IsNotFixedTermTenant__c            = true  // 定期借家を含まない
            ,ContractRemarks__c                 = 'テスト契約備考'             // 契約備考
            ,FacilityRemarksPublic__c           = 'テスト設備備考（公開）'      // 設備備考（公開）
            ,FacilityRemarksPrivate__c          = 'テスト設備備考（非公開）'    // 設備備考（非公開）
        );
        insert testPropertyConditions;

        PropertyPhoto__c testPropertyPhoto = new PropertyPhoto__c(
            Property__c                 = testProperty.Id   // 物件
            ,PropertyPhotoFileName1__c  = null          // 物件写真ファイル名１
            ,PropertyPhotoFileName2__c  = null          // 物件写真ファイル名２
            ,PropertyPhotoFileName3__c  = null          // 物件写真ファイル名３
            ,PropertyPhotoFileName4__c  = null          // 物件写真ファイル名４
            ,PropertyPhotoFileName5__c  = null          // 物件写真ファイル名５
            ,PropertyPhotoFileName6__c  = null          // 物件写真ファイル名６
            ,PropertyPhotoFileName7__c  = null          // 物件写真ファイル名７
            ,PropertyPhotoFileName8__c  = null          // 物件写真ファイル名８
            ,PropertyPhotoFileName9__c  = null          // 物件写真ファイル名９
            ,PropertyPhotoFileName10__c = null          // 物件写真ファイル名１０
            ,PropertyPhotoFileName11__c = null          // 物件写真ファイル名１１
            ,PropertyPhotoFileName12__c = null          // 物件写真ファイル名１２
            ,PropertyPhotoFileName13__c = null          // 物件写真ファイル名１３
            ,PropertyPhotoFileName14__c = null          // 物件写真ファイル名１４
            ,PropertyPhotoFileName15__c = null          // 物件写真ファイル名１５
            ,PropertyPhotoFileName16__c = null          // 物件写真ファイル名１６
            ,PropertyPhotoFileName17__c = null          // 物件写真ファイル名１７
            ,PropertyPhotoFileName18__c = null          // 物件写真ファイル名１８
            ,PropertyPhotoFileName19__c = null          // 物件写真ファイル名１９
            ,PropertyPhotoFileName20__c = null          // 物件写真ファイル名２０
            ,PropertyPhotoTag1__c       = null          // 物件写真タグ１
            ,PropertyPhotoTag2__c       = null          // 物件写真タグ２
            ,PropertyPhotoTag3__c       = null          // 物件写真タグ３
            ,PropertyPhotoTag4__c       = null          // 物件写真タグ４
            ,PropertyPhotoTag5__c       = null          // 物件写真タグ５
            ,PropertyPhotoTag6__c       = null          // 物件写真タグ６
            ,PropertyPhotoTag7__c       = null          // 物件写真タグ７
            ,PropertyPhotoTag8__c       = null          // 物件写真タグ８
            ,PropertyPhotoTag9__c       = null          // 物件写真タグ９
            ,PropertyPhotoTag10__c      = null          // 物件写真タグ１０
            ,PropertyPhotoTag11__c      = null          // 物件写真タグ１１
            ,PropertyPhotoTag12__c      = null          // 物件写真タグ１２
            ,PropertyPhotoTag13__c      = null          // 物件写真タグ１３
            ,PropertyPhotoTag14__c      = null          // 物件写真タグ１４
            ,PropertyPhotoTag15__c      = null          // 物件写真タグ１５
            ,PropertyPhotoTag16__c      = null          // 物件写真タグ１６
            ,PropertyPhotoTag17__c      = null          // 物件写真タグ１７
            ,PropertyPhotoTag18__c      = null          // 物件写真タグ１８
            ,PropertyPhotoTag19__c      = null          // 物件写真タグ１９
            ,PropertyPhotoTag20__c      = null          // 物件写真タグ２０
            ,PropertyPhotoComment1__c   = null          // 物件写真コメント１
            ,PropertyPhotoComment2__c   = null          // 物件写真コメント２
            ,PropertyPhotoComment3__c   = null          // 物件写真コメント３
            ,PropertyPhotoComment4__c   = null          // 物件写真コメント４
            ,PropertyPhotoComment5__c   = null          // 物件写真コメント５
            ,PropertyPhotoComment6__c   = null          // 物件写真コメント６
            ,PropertyPhotoComment7__c   = null          // 物件写真コメント７
            ,PropertyPhotoComment8__c   = null          // 物件写真コメント８
            ,PropertyPhotoComment9__c   = null          // 物件写真コメント９
            ,PropertyPhotoComment10__c  = null          // 物件写真コメント１０
            ,PropertyPhotoComment11__c  = null          // 物件写真コメント１１
            ,PropertyPhotoComment12__c  = null          // 物件写真コメント１２
            ,PropertyPhotoComment13__c  = null          // 物件写真コメント１３
            ,PropertyPhotoComment14__c  = null          // 物件写真コメント１４
            ,PropertyPhotoComment15__c  = null          // 物件写真コメント１５
            ,PropertyPhotoComment16__c  = null          // 物件写真コメント１６
            ,PropertyPhotoComment17__c  = null          // 物件写真コメント１７
            ,PropertyPhotoComment18__c  = null          // 物件写真コメント１８
            ,PropertyPhotoComment19__c  = null          // 物件写真コメント１９
            ,PropertyPhotoComment20__c  = null          // 物件写真コメント２０
            ,PrivatePhotoFileName1__c   = null          // 非公開写真ファイル名１
            ,PrivatePhotoFileName2__c   = null          // 非公開写真ファイル名２
            ,PrivatePhotoFileName3__c   = null          // 非公開写真ファイル名３
            ,PrivatePhotoFileName4__c   = null          // 非公開写真ファイル名４
            ,PrivatePhotoFileName5__c   = null          // 非公開写真ファイル名５
            ,PrivatePhotoFileName6__c   = null          // 非公開写真ファイル名６
            ,PrivatePhotoFileName7__c   = null          // 非公開写真ファイル名７
            ,PrivatePhotoFileName8__c   = null          // 非公開写真ファイル名８
            ,PrivatePhotoType1__c       = null          // 非公開写真種別１
            ,PrivatePhotoType2__c       = null          // 非公開写真種別２
            ,PrivatePhotoType3__c       = null          // 非公開写真種別３
            ,PrivatePhotoType4__c       = null          // 非公開写真種別４
            ,PrivatePhotoType5__c       = null          // 非公開写真種別５
            ,PrivatePhotoType6__c       = null          // 非公開写真種別６
            ,PrivatePhotoType7__c       = null          // 非公開写真種別７
            ,PrivatePhotoType8__c       = null          // 非公開写真種別８
            ,PrivatePhotoComment1__c    = null          // 非公開写真コメント１
            ,PrivatePhotoComment2__c    = null          // 非公開写真コメント２
            ,PrivatePhotoComment3__c    = null          // 非公開写真コメント３
            ,PrivatePhotoComment4__c    = null          // 非公開写真コメント４
            ,PrivatePhotoComment5__c    = null          // 非公開写真コメント５
            ,PrivatePhotoComment6__c    = null          // 非公開写真コメント６
            ,PrivatePhotoComment7__c    = null          // 非公開写真コメント７
            ,PrivatePhotoComment8__c    = null          // 非公開写真コメント８
            ,PanoramaFileName1__c       = null          // パノラマファイル名１
            ,PanoramaFileName2__c       = null          // パノラマファイル名２
            ,PanoramaFileName3__c       = null          // パノラマファイル名３
            ,PanoramaFileName4__c       = null          // パノラマファイル名４
            ,PanoramaFileName5__c       = null          // パノラマファイル名５
            ,PanoramaTag1__c            = null          // パノラマタグ１
            ,PanoramaTag2__c            = null          // パノラマタグ２
            ,PanoramaTag3__c            = null          // パノラマタグ３
            ,PanoramaTag4__c            = null          // パノラマタグ４
            ,PanoramaTag5__c            = null          // パノラマタグ５
            ,PanoramaComment1__c        = null          // パノラマコメント１
            ,PanoramaComment2__c        = null          // パノラマコメント２
            ,PanoramaComment3__c        = null          // パノラマコメント３
            ,PanoramaComment4__c        = null          // パノラマコメント４
            ,PanoramaComment5__c        = null          // パノラマコメント５
            ,RoomLayoutFileName__c      = null          // 間取り図ファイル名
            ,RoomLayoutMemoFileName__c  = null          // 間取り図メモファイル名
        );
        insert testPropertyPhoto;

        //ポータルサイト構築 追加 Start
        // おすすめ物件登録
        RecommendProperty__c recoPro = new RecommendProperty__c(Comment__c = 'コメント',
                PropertyCode__c = testProperty.PropertyCode__c,
                Property__c = testProperty.id,
                PhotoFileName__c = 'tatemono.aaa');
        insert recoPro;
        //ポータルサイト構築 追加 End

        // 建物写真
        BuildingPhoto__c buildingPhoto = new BuildingPhoto__c (AppearanceFileName__c = 'tatemono.aaa'
                                                               , Building__c = testProperty.Building__c);
        insert buildingPhoto;
    }

    // 初期表示テスト(新規)
    @isTest static void newInitializeTest(){
        Building__c testBuild = [
            SELECT Id, Name
            FROM Building__c
            WHERE Name = 'テスト建物'
            AND CaretakerType__c = '通勤方式'
        ];
        //パラメータ設定
        PageReference pageRef = Page.GA104006View;
        pageRef.getParameters().put('buildingId', testBuild.Id);
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GA104006Controller testController = new GA104006Controller();
        System.assertEquals(true, testController.isNew);
    }

    // 初期表示テスト(編集)
    @isTest static void updateInitializeTest(){
        Property__c testProp = [
            SELECT Id, Name
            FROM Property__c
            WHERE Name = '_t_'
        ];
        //パラメータ設定
        PageReference pageRef = Page.GA104006View;
        pageRef.getParameters().put('propertyId', testProp.Id);
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GA104006Controller testController = new GA104006Controller();
        System.assertEquals(false, testController.isOpenError);
    }

    // 初期表示テスト(パラメータ異常)
    @isTest static void paramErrorInitializeTest(){
        //パラメータ設定(なし)
        PageReference pageRef = Page.GA104006View;
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GA104006Controller testController = new GA104006Controller();
        System.assertEquals(true, testController.isOpenError);
    }

    // 物件コピーボタン押下処理テスト
    @isTest static void clickPropertyCopyButtonTest() {
        Property__c testProp = [
            SELECT Id, Name
            FROM Property__c
            WHERE Name = '_t_'
        ];
        //パラメータ設定
        PageReference pageRef = Page.GA104006View;
        pageRef.getParameters().put('propertyId', testProp.Id);
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GA104006Controller testController = new GA104006Controller();
        testController.clickPropertyCopyButton();
        System.assertEquals(true, testController.isCopy);
    }

    // 削除ボタン押下処理テスト(名寄せ対象データなし)
    @isTest static void clickDeleteButtonTest() {
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runAs(userRecord){
            Property__c testProp = [
                SELECT Id, Name
                FROM Property__c
                WHERE Name = '_t_'
            ];
            //パラメータ設定
            PageReference pageRef = Page.GA104006View;
            pageRef.getParameters().put('propertyId', testProp.Id);
            Test.setCurrentPage(pageRef);
            //ポータルサイト構築 変更 Start
            // コールアウトクラスのモッククラスをセット
            Test.setMock(HttpCalloutMock.class, new GK101003TestHttpRequestMock());
            Test.startTest();
            //コントローラ作成
            GA104006Controller testController = new GA104006Controller();
            testController.clickDeleteButton();
            Test.stopTest();
            //ポータルサイト構築 変更 End
            System.assertEquals(false, testController.hasErrorMessage);
        }
    }

    // 削除ボタン押下処理テスト(名寄せ対象データ１件あり)
    @isTest static void clickDeleteButtonTest2() {
        Test.startTest();
         // テスト対象物件データ退避
         Property__c testProp = [
            SELECT Id, Name
            FROM Property__c
            WHERE Name = '_t_'
        ];
        //同名の物件データを作成
        Property__c testProp2 = [
            SELECT Id, Name, IsMergeCompletedFlag__c
            FROM Property__c
            WHERE Name = '_t_2' Limit 1
        ];
        testProp2.Name = '_t_';
        testProp2.IsMergeCompletedFlag__c = FALSE;
        update testProp2;

        //ポータルサイト構築 追加 Start
        SystemConfig__c testSystemConfig = [
            SELECT Id, UseAuthority_Portal__c
            FROM SystemConfig__c Limit 1
        ];
        testSystemConfig.UseAuthority_Portal__c = false;
        update testSystemConfig;
        //ポータルサイト構築 追加 End
        Test.stopTest();

        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runAs(userRecord){
            //パラメータ設定
            PageReference pageRef = Page.GA104006View;
            pageRef.getParameters().put('propertyId', testProp.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA104006Controller testController = new GA104006Controller();
            testController.clickDeleteButton();
            System.assertEquals(true, testController.hasErrorMessage);
        }

        //同名物件データを再取得し、名寄せ完了フラグがTRUEであることを確認
        Property__c resultProp = [
            SELECT Id, Name, IsMergeCompletedFlag__c
            FROM Property__c
            WHERE Id = :testProp2.Id
        ];        
        // System.assertEquals(true, resultProp.IsMergeCompletedFlag__c);
    }

    // 削除ボタン押下処理テスト(名寄せ対象データ2件以上あり)
    @isTest static void clickDeleteButtonTest3() {
        Test.startTest();
        // テスト対象物件データ退避
        Property__c testProp = [
            SELECT Id, Name
            FROM Property__c
            WHERE Name = '_t_'
        ];
        //同名の物件データを作成
        List<Property__c> testPropList = [
            SELECT Id, Name, IsMergeCompletedFlag__c
            FROM Property__c
            WHERE Name IN ('_t_2', '_t_3', '_t_4')
        ];
        for (Property__c prop : testPropList) {
            prop.Name = '_t_';
            prop.IsMergeCompletedFlag__c = TRUE;
        }
        update testPropList;
        //ポータルサイト構築 追加 Start
        SystemConfig__c testSystemConfig = [
            SELECT Id, UseAuthority_Portal__c
            FROM SystemConfig__c Limit 1
        ];
        testSystemConfig.UseAuthority_Portal__c = false;
        update testSystemConfig;
        //ポータルサイト構築 追加 End
        Test.stopTest();

        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runAs(userRecord){
            //パラメータ設定
            PageReference pageRef = Page.GA104006View;
            pageRef.getParameters().put('propertyId', testProp.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA104006Controller testController = new GA104006Controller();
            testController.clickDeleteButton();
            System.assertEquals(true, testController.hasErrorMessage);
        }

        //同名物件データを再取得し、名寄せ完了フラグがFALSEであることを確認
        List<Property__c> resultPropList = [
            SELECT Id, Name, IsMergeCompletedFlag__c
            FROM Property__c
            WHERE Name = '_t_'
            AND IsDeleted = FALSE
        ];        
        for (Property__c resultProp : resultPropList) {
            // System.assertEquals(true, resultProp.IsMergeCompletedFlag__c);
        }
    }    

    // 部屋登録モーダル(新規)起動処理テスト
    @isTest static void openRoomModalCreateTest() {
        Property__c testProp = [
            SELECT Id, Name
            FROM Property__c
            WHERE Name = '_t_'
        ];
        //パラメータ設定
        PageReference pageRef = Page.GA104006View;
        pageRef.getParameters().put('propertyId', testProp.Id);
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GA104006Controller testController = new GA104006Controller();
        testController.openRoomModalCreate();
        //モーダル起動
        GA104006Modal1Controller testModalController = new GA104006Modal1Controller();

        //処理前部屋数退避
        Integer prevRoomListSize = testController.screenPropertyRecord.ScreenRoomList.size();

        //モーダルへパラメータを引渡
        testModalController.parameter = testController.GA104006Modal1Parameter;
        //モーダルの初期表示処理
        testModalController.initAction();

        //部屋追加
        testModalController.parameter.targetRoom.Property__c = testModalController.screenRecord.PropertyId;
        testModalController.parameter.targetRoom.RoomFloorSpace__c = 3;
        testModalController.parameter.targetRoom.RoomType__c = '洋室';

        //モーダルを閉じる
        testModalController.closeModal();
        testController.closeRoomModal();

        System.assertEquals(true, testController.screenPropertyRecord.ScreenRoomList.size() > prevRoomListSize);

    }

    // 部屋登録モーダル(編集)起動処理テスト
    @isTest static void openRoomModalUpdateTest() {
        Property__c testProp = [
            SELECT Id, Name
            FROM Property__c
            WHERE Name = '_t_'
        ];
        //パラメータ設定
        PageReference pageRef = Page.GA104006View;
        pageRef.getParameters().put('propertyId', testProp.Id);
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GA104006Controller testController = new GA104006Controller();
        //処理する部屋のインデックス設定
        testController.selectedRoomIndex = 0;
        testController.openRoomModalUpdate();
        //モーダル起動
        GA104006Modal1Controller testModalController = new GA104006Modal1Controller();

        //処理前部屋帖数退避
        Decimal prevRoomFloorSpace = testController.screenPropertyRecord.ScreenRoomList[testController.selectedRoomIndex].Room.RoomFloorSpace__c;

        //モーダルへパラメータを引渡
        testModalController.parameter = testController.GA104006Modal1Parameter;
        //モーダルの初期表示処理
        testModalController.initAction();

        //部屋追加
        testModalController.parameter.targetRoom.Property__c = testModalController.screenRecord.PropertyId;
        testModalController.parameter.targetRoom.RoomFloorSpace__c = prevRoomFloorSpace + 1;
        testModalController.parameter.targetRoom.RoomType__c = '洋室';

        //モーダルを閉じる
        testModalController.closeModal();
        testController.closeRoomModal();

        System.assertEquals(false, testController.screenPropertyRecord.ScreenRoomList.size() == prevRoomFloorSpace);

    }

    // 部屋削除ボタン押下処理テスト
    @isTest static void clickRoomDeleteTest() {
        Property__c testProp = [
            SELECT Id, Name
            FROM Property__c
            WHERE Name = '_t_'
        ];
        //パラメータ設定
        PageReference pageRef = Page.GA104006View;
        pageRef.getParameters().put('propertyId', testProp.Id);
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GA104006Controller testController = new GA104006Controller();
        //処理前部屋数退避
        Integer prevRoomListSize = testController.screenPropertyRecord.ScreenRoomList.size();
        //1件目の部屋を選択
        testController.screenPropertyRecord.ScreenRoomList[0].IsChecked = true;
        testController.clickRoomDelete();

        System.assertEquals(true, testController.screenPropertyRecord.ScreenRoomList.size() < prevRoomListSize);

    }

    // 添付ファイルの再読み込み処理テスト
    @isTest static void reloadAttachmentTest() {
        Property__c testProp = [
            SELECT Id, Name
            FROM Property__c
            WHERE Name = '_t_'
        ];
        //パラメータ設定
        PageReference pageRef = Page.GA104006View;
        pageRef.getParameters().put('propertyId', testProp.Id);
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GA104006Controller testController = new GA104006Controller();
        testController.reloadAttachment();

        System.assertEquals(true, testController.screenPropertyAttachmentsRecord.Id.size() > 0);

    }

    // 業者選択モーダル起動（元付業者）処理テスト
    @isTest static void formerSupplierSelectModalTest() {
        Property__c testProp = [
            SELECT Id, Name
            FROM Property__c
            WHERE Name = '_t_'
        ];
        //パラメータ設定
        PageReference pageRef = Page.GA104006View;
        pageRef.getParameters().put('propertyId', testProp.Id);
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GA104006Controller testController = new GA104006Controller();
        testController.formerSupplierSelectModal();
        //モーダル起動
        GD301003Controller testModalController = new GD301003Controller();

        //モーダルへパラメータを引渡
        testModalController.Parameter = testController.GD301003Parameter;
        //モーダルの初期表示処理
        testModalController.initAction();
        //モーダルの検索処理
        testModalController.search();
        //検索1件名を選択
        testModalController.index = 0;
        testModalController.selectButton();

        //モーダルを閉じる
        testController.closeGD301003Modal();

        System.assertEquals(false, testController.GD301003Parameter.accountRecord.Id == null);

    }

    // 業者選択モーダル起動（貸主）処理テスト
    @isTest static void formerCreditorModalTest() {
        Property__c testProp = [
            SELECT Id, Name
            FROM Property__c
            WHERE Name = '_t_'
        ];
        //パラメータ設定
        PageReference pageRef = Page.GA104006View;
        pageRef.getParameters().put('propertyId', testProp.Id);
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GA104006Controller testController = new GA104006Controller();
        testController.formerCreditorModal();
        //モーダル起動
        GD301003Controller testModalController = new GD301003Controller();

        //モーダルへパラメータを引渡
        testModalController.Parameter = testController.GD301003Parameter;
        //モーダルの初期表示処理
        testModalController.initAction();
        //モーダルの検索処理
        testModalController.search();
        //検索1件名を選択
        testModalController.index = 0;
        testModalController.selectButton();

        //モーダルを閉じる
        testController.closeGD301003Modal();

        System.assertEquals(false, testController.GD301003Parameter.accountRecord.Id == null);

    }

    // 業者選択モーダル起動（所有者）処理テスト
    @isTest static void ownerSelectModalTest() {
        Property__c testProp = [
            SELECT Id, Name
            FROM Property__c
            WHERE Name = '_t_'
        ];
        //パラメータ設定
        PageReference pageRef = Page.GA104006View;
        pageRef.getParameters().put('propertyId', testProp.Id);
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GA104006Controller testController = new GA104006Controller();
        testController.ownerSelectModal();
        //モーダル起動
        GD301003Controller testModalController = new GD301003Controller();

        //モーダルへパラメータを引渡
        testModalController.Parameter = testController.GD301003Parameter;
        //モーダルの初期表示処理
        testModalController.initAction();
        //モーダルの検索処理
        testModalController.search();
        //検索1件名を選択
        testModalController.index = 0;
        testModalController.selectButton();

        //モーダルを閉じる
        testController.closeGD301003Modal();

        System.assertEquals(false, testController.GD301003Parameter.accountRecord.Id == null);

    }

    

    // キャンセルボタン押下処理テスト
    @isTest static void clickCancelButtonTest() {
        Property__c testProp = [
            SELECT Id, Name
            FROM Property__c
            WHERE Name = '_t_'
        ];
        //パラメータ設定
        PageReference pageRef = Page.GA104006View;
        pageRef.getParameters().put('propertyId', testProp.Id);
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GA104006Controller testController = new GA104006Controller();
        testController.clickCancelButton();
        System.assertEquals(false, testController.hasErrorMessage);
    }

    // 保存ボタン押下処理テスト
    @isTest static void clickSaveButtonTest() {
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runAs(userRecord){
            Property__c testProp = [
                SELECT Id, Name, ChintaiMagazineComment__r.ExampleSentence__c // 2022.03.30 CHINTAI対応追加
                FROM Property__c
                WHERE Name = '_t_'
            ];
            //パラメータ設定
            PageReference pageRef = Page.GA104006View;
            pageRef.getParameters().put('propertyId', testProp.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA104006Controller testController = new GA104006Controller();
            testController.clickSaveButton();
            System.assertEquals(false, testController.hasErrorMessage);
            System.assertEquals('テスト文例内容３\nテスト文例内容２行目', testProp.ChintaiMagazineComment__r.ExampleSentence__c); // 2022.03.30 CHINTAI対応追加
        }
    }

    // 保存ボタン押下処理テスト（異常時）
    @isTest static void clickSaveButtonErrTest() {
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runAs(userRecord){
            Property__c testProp = [
                SELECT Id, Name
                FROM Property__c
                WHERE Name = '_t_5'
             ];
            //パラメータ設定
            PageReference pageRef = Page.GA104006View;
            pageRef.getParameters().put('propertyId', testProp.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA104006Controller testController = new GA104006Controller();
            testController.clickSaveButton();
            System.assertEquals(true, testController.hasErrorMessage);
        }
    }

    // 一時保存ボタン押下処理テスト
    @isTest static void clickTempSaveButtonTest() {
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runAs(userRecord){
            Property__c testProp = [
                SELECT Id, Name
                FROM Property__c
                WHERE Name = '_t_'
            ];
            //パラメータ設定
            PageReference pageRef = Page.GA104006View;
            pageRef.getParameters().put('propertyId', testProp.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA104006Controller testController = new GA104006Controller();
            testController.clickTempSaveButton();
            System.assertEquals(false, testController.hasErrorMessage);
        }
    }

    //ポータルサイト構築 追加 Start
    // 部屋登録モーダル(新規)起動処理テスト
    @isTest static void recoProModalTest() {
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runas(userRecord){

            Property__c testProp = [
                SELECT Id, Name ,PropertyCode__c,Building__c  
                FROM Property__c
                WHERE Name = '_t_'
            ];
            //物件写真変更
            PropertyPhoto__c proPhoto = [SELECT Id From PropertyPhoto__c WHERE Property__c = :testProp.Id];
            proPhoto.PropertyPhotoTag1__c = 'キッチン';
            proPhoto.PropertyPhotoFileName1__c = 'syasin.aaa';
            update proPhoto;

            proPhoto.recalculateFormulas();

            // 建物写真
            BuildingPhoto__c builPro = [SELECT Id,AppearanceFileName__c,AppearanceFilePath__c From BuildingPhoto__c WHERE Building__c = :testProp.Building__c];

            //おすすめ物件登録
            RecommendProperty__c recoPro = new RecommendProperty__c(Comment__c = 'コメント',
                                                                    PropertyCode__c = testProp.PropertyCode__c,
                                                                    PhotoFileName__c = 'tatemono.aaa',
                                                                    PhotoFilePath__c = proPhoto.PropertyPhotoFileName1__c);
            insert recoPro;
            Test.startTest();
            //パラメータ設定
            PageReference pageRef = Page.GA104006View;
            pageRef.getParameters().put('propertyId', testProp.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA104006Controller testController = new GA104006Controller();
            
            

            testController.openRecommendPropertyRegistration();
            

            //モーダル起動
            GA104006Modal3Controller testModalController = new GA104006Modal3Controller();

            //モーダルへパラメータを引渡
            testModalController.parameter = testController.GA104006Modal3Parameter;
            //モーダルの初期表示処理

            testModalController.initAction();
            //●●●初期表示が問題ない
            System.assertEquals('コメント', testModalController.screenRecoPro.comment);

            //チェックを外して保存ボタン押下
            testModalController.screenPhotoList[0].checkBox = false;
            testModalController.registrationCleck();
            //●●●チェックしてくださいエラー出ている？
            List<ApexPages.Message> messages = ApexPages.getMessages();
            System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_NO_SELECTION,'写真')));
            
            //モーダルでおすすめ物件の内容変更
            testModalController.screenPhotoList[0].checkBox = true;
            testModalController.screenRecoPro.comment = 'コメント変更';
            testModalController.registrationCleck();

            //●●●モーダルの変更が親画面に反映されている
            System.assertEquals('コメント変更', testController.recoPro.Comment__c);
            testController.closeRecommendPropertyRegistration();
            //保存ボタン
            testController.clickSaveButton();
            Test.stopTest();
            List<RecommendProperty__c> reRecoPro = [SELECT Comment__c FROM RecommendProperty__c WHERE Comment__c = 'コメント変更'];
            
            //●●●変更内容がDBに保存されている
            System.assertEquals(1, reRecoPro.size());
        }
    
    }
    @isTest
    static void createPropertyMapParameterTest(){
        //コントローラ作成
        GA104006Controller testController = new GA104006Controller();
        testController.createPropertyMapParameter();
    }
    @isTest
    static void closeExampleSentenceSelectForSummoTest(){
        Property__c testProp = [
            SELECT Id, Name
            FROM Property__c
            WHERE Name = '_t_'
        ];
        ExampleSentence__c testExSentence = [
            SELECT Id, Name, Folder__c,UsageScreen__c
            FROM ExampleSentence__c
            WHERE Name = 'テスト文例１'
        ];
        //パラメータ設定
        PageReference pageRef = Page.GA104006View;
        pageRef.getParameters().put('propertyId', testProp.Id);
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GA104006Controller testController = new GA104006Controller();
        testController.openSuumoNetCatchExampleSentenceSelect();
        //モーダル起動
        GA104006Modal2Controller testModalController = new GA104006Modal2Controller();

        //モーダルへパラメータを引渡
        testModalController.Parameter = testController.GA104006Modal2Parameter;

        //モーダルの初期表示処理
        testModalController.initAction();
        //フォルダを選択
        testModalController.screenRecord.selectFolder = testExSentence.Folder__c;
        testModalController.changeFolder();
        //文例を選択
        testModalController.screenRecord.selectExampleSentence = testExSentence.Id;
        testModalController.changeExampleSentence();
        //モーダルの終了処理
        testModalController.closeModal();

        //モーダル後処理
        testController.closeExampleSentenceSelect();
    }

    //問合せ278で追加　取込区分を手動に変更
    @isTest static void changeManualTest() {
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runAs(userRecord){
            Property__c testProp = [
                SELECT Id, Name, ImportType__c
                FROM Property__c
                WHERE Name = '_t_'
            ];
            testProp.ImportType__c = '大和リビング';
            upsert testProp;
            //パラメータ設定
            PageReference pageRef = Page.GA104006View;
            pageRef.getParameters().put('propertyId', testProp.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA104006Controller testController = new GA104006Controller();
            testController.screenPropertyRecord.importType = '手動';
            testController.clickSaveButton();
        }
    }

    //問合せ278で追加　取込区分を手動からリアプロに変更
    @isTest static void changeReaproTest() {
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runAs(userRecord){
            Property__c testProp = [
                SELECT Id, Name, ImportType__c
                FROM Property__c
                WHERE Name = '_t_'
            ];
            testProp.ImportType__c = '手動';
            upsert testProp;
            //パラメータ設定
            PageReference pageRef = Page.GA104006View;
            pageRef.getParameters().put('propertyId', testProp.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA104006Controller testController = new GA104006Controller();
            testController.screenPropertyRecord.importType = 'リアプロ';
            testController.clickSaveButton();
            // --その他--変更も確認
            testController.screenPropertyRecord.importType = null;
            testController.clickSaveButton();
        }
    }

    // 問合せ352で追加　未入居かつ退去予定時にエラーを表示
    @isTest static void unoccupancyAndScheduledToMoveOutTest() {
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runAs(userRecord){
            Property__c testProp = [
                SELECT Id, Name,LivedType__c,LiveStatus__c
                FROM Property__c
                WHERE Name = '_t_'
            ]; 
            testProp.LivedType__c = CommonConst.PROPERTY_LIVEDTYPE_NOTLIVED;
            testProp.LiveStatus__c = CommonConst.PROPERTY_LIVESTATUS_SCHEDULEDTOLEAVE;
            update testProp;
            //パラメータ設定
            PageReference pageRef = Page.GA104006View;
            pageRef.getParameters().put('propertyId', testProp.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA104006Controller testController = new GA104006Controller();
            testController.clickSaveButton();
        }
    }

    // 物件コード履歴削除テスト
    @isTest static void delPropertyCdHistTest() {

        // 物件コード履歴
        Property__c property1 = [SELECT Id FROM Property__c WHERE Name = '_t_'];
        Property__c property2 = [SELECT Id FROM Property__c WHERE Name = '_t_2'];

        // property1に紐づくproperty2の建物コード履歴を作成
        PropertyCodeHistory__c propertyCdHist = [SELECT Id
                                                        , Property__c
                                                 FROM PropertyCodeHistory__c
                                                 WHERE HistoryProperty__c = :property2.Id];

        propertyCdHist.Property__c = property1.Id;
        update propertyCdHist;

        // 作成した物件コード履歴を再取得
        propertyCdHist = [SELECT Id
                                 , Property__c
                                 , HistoryProperty__c
                                 , HistoryMaintenancePropertyCode__c
                                 , HistoryImportDestination__c
                                 , InformationUpdateDate__c
                                 , SystemModStamp
                          FROM PropertyCodeHistory__c
                          WHERE Id = :propertyCdHist.Id];

        // 初期表示
        PageReference pageRef = Page.GA104006View;
        pageRef.getParameters().put('propertyId', property1.Id);
        Test.setCurrentPage(pageRef);
		Test.startTest();


        // 物件コード履歴の明細を作成
        GA104006Controller testController = new GA104006Controller();
        testController.screenPropertyCdHistList = new List<GA104006Controller.ScreenPropertyCdHist>();
        testController.screenPropertyCdHistList.add(new GA104006Controller.ScreenPropertyCdHist(propertyCdHist));
        testController.screenPropertyCdHistList[0].IsSelected = true;

        // 物件コード履歴の削除
        testController.delPropertyCdHist();

        // 物件コード履歴を再作成
        propertyCdHist = new PropertyCodeHistory__c(
            Property__c                         = property1.Id
            , HistoryProperty__c                = property2.Id
            , HistoryMaintenancePropertyCode__c = CommonConst.STRING_EMPTY
            , HistoryImportDestination__c       = CommonConst.STRING_EMPTY
            , InformationUpdateDate__c          = CommonUtil.getNow()
        );
        insert propertyCdHist;

        // 物件コード履歴の明細を再作成
        testController = new GA104006Controller();
        testController.screenPropertyCdHistList = new List<GA104006Controller.ScreenPropertyCdHist>();
        testController.screenPropertyCdHistList.add(new GA104006Controller.ScreenPropertyCdHist(propertyCdHist));
        testController.screenPropertyCdHistList[0].IsSelected = true;

        // 楽観ロック（削除済み）
        delete new PropertyCodeHistory__c(Id = propertyCdHist.Id);
        testController.delPropertyCdHist();
		Test.stopTest();
    }

    // カバレッジ向上テスト
    @istest static void coverageUp(){

        GA104006Controller testController = new GA104006Controller();

        // プロパティ
        String propVal;
        propVal = testController.MSG_NO_SELECTED_PROPERTY_CD_HIST_ROW;
    }

    // 写真関連テスト
    @isTest static void photoTest() {
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runAs(userRecord){
            Property__c testProp = [
                SELECT Id, Name
                FROM Property__c
                WHERE Name = '_t_'
            ];
            //パラメータ設定
            PageReference pageRef = Page.GA104006View;
            pageRef.getParameters().put('propertyId', testProp.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA104006Controller testController = new GA104006Controller();
            Test.startTest();
            testController.updatePublicPhoto();
            testController.updatePrivatePhoto();
            testController.updatePanoramaPhoto();
            testController.updateFloorplanMemoPhoto();
            testController.appAfterSaveFloorplanPhoto();
            Test.stopTest();
        }
    }

    // エラーのため分割
    @isTest static void photoTest2() {
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runAs(userRecord){
            Property__c testProp = [
                SELECT Id, Name
                FROM Property__c
                WHERE Name = '_t_'
            ];
            //パラメータ設定
            PageReference pageRef = Page.GA104006View;
            pageRef.getParameters().put('propertyId', testProp.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA104006Controller testController = new GA104006Controller();
            Test.startTest();
            testController.deletePublicPhoto();
            testController.deletePrivatePhoto();
            testController.deletePanoramaPhoto();
            testController.deleteFloorplanPhoto();
            testController.deletePublicPhotoAll();
            testController.deletePrivatePhotoAll();
            testController.deletePanoramaPhotoAll();
            Test.stopTest();
        }
    }

    // 物件メンテナンス履歴モーダルテスト
    @isTest static void testPropertyHistoryModal() {
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runAs(userRecord){
            Property__c testProp = [
                SELECT Id, Name
                FROM Property__c
                WHERE Name = '_t_'
            ];
            //パラメータ設定
            PageReference pageRef = Page.GA104006View;
            pageRef.getParameters().put('propertyId', testProp.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA104006Controller testController = new GA104006Controller();
            GA104006Modal4Controller testModal = new GA104006Modal4Controller();
            testModal.parameter = new GA104006Modal4ParameterClass();
            Boolean result = testModal.init;
            GA104006Modal4Controller testModal2 = new GA104006Modal4Controller();
            testModal2.parameter = new GA104006Modal4ParameterClass();
            testModal2.parameter.isDrawing = true;
            Boolean result2 = testModal2.init;
            Test.startTest();
            testController.openPropertyHistoryModal();
            Test.stopTest();
        }
    }

    // 選択行確認テスト
    @isTest static void selectedLineTest() {
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runAs(userRecord){
            Property__c testProp = [
                SELECT Id, Name
                FROM Property__c
                WHERE Name = '_t_'
            ];
            //パラメータ設定
            PageReference pageRef = Page.GA104006View;
            pageRef.getParameters().put('propertyId', testProp.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA104006Controller testController = new GA104006Controller();
            testController.screenPropertyRecord.GuaranteeidCompanyType =  CommonConst.PROPERTY_GUARANTEEIDCOMPANYTYPE_UNSET;
            testController.guaranteePlanItemList.clear();
            List<GA104006Controller.ScreenFireInsuranceItem> saveFireInsuranceItemList = new List<GA104006Controller.ScreenFireInsuranceItem>();
            for (GA104006Controller.ScreenFireInsuranceItem item : testController.fireInsuranceItemList) {
                if (item.IsChecked2) {
                    item.IsChecked2 = false;
                } else {
                    testController.screenPropertyRecord.FireInsuranceCompany = item.AccountId;
                    testController.screenPropertyRecord.FireInsurancePlan = item.Id;
                    item.IsChecked2 = true;
                }
                saveFireInsuranceItemList.add(item);
            }
            testController.fireInsuranceItemList = saveFireInsuranceItemList;

            List<GA104006Controller.ScreenManagementCompanyItem> saveScreenManagementCompanyItemList = new List<GA104006Controller.ScreenManagementCompanyItem>();
            for (GA104006Controller.ScreenManagementCompanyItem item2 : testController.managementCompanyItemList) {
                item2.IsChecked = true;
                saveScreenManagementCompanyItemList.add(item2);
            }
            testController.managementCompanyItemList = saveScreenManagementCompanyItemList;

            Test.startTest();
            testController.clickSaveButton();
            Test.stopTest();
        }
    }

    // 単位変更テスト
    @isTest static void changeUnitTest() {
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runAs(userRecord){
            Property__c testProp = [
                SELECT Id, Name
                FROM Property__c
                WHERE Name = '_t_'
            ];
            //パラメータ設定
            PageReference pageRef = Page.GA104006View;
            pageRef.getParameters().put('propertyId', testProp.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA104006Controller testController = new GA104006Controller();
            Shop__c shop = [SELECT Id, Name FROM Shop__c WHERE NAME = 'テストユーザ店舗'];
            String shopId = shop.id;
            Test.startTest();
            testController.clickSaveButton();
            testController.screenPropertyRecord.SecurityDeposit = '2.0';
            testController.screenPropertyRecord.SecurityDepositUnit = CommonConst.PROPERTY_FEEUNIT_MONTH;
            testController.screenPropertyRecord.CancellationActualFee = '10000';
            testController.screenPropertyRecord.CancellationActualFeeUnit = CommonConst.PROPERTY_FEEUNIT_YEN;
            testController.screenPropertyRecord.Deposit = null;
            testController.screenPropertyRecord.RenewalFee = '10000';
            testController.screenPropertyRecord.RenewalFeeUnit = CommonConst.PROPERTY_FEEUNIT_YEN;
            testController.screenPropertyRecord.KeyMoney = '10000';
            testController.screenPropertyRecord.KeyMoneyUnit = CommonConst.PROPERTY_FEEUNIT_YEN;
            testController.screenPropertyRecord.CleaningFee = '10000';
            testController.screenPropertyRecord.CleaningFeeUnit = CommonConst.PROPERTY_FEEUNIT_YEN;
            testController.screenPropertyRecord.ParkingDeposit = '10000';
            testController.screenPropertyRecord.ParkingDepositUnit = CommonConst.PROPERTY_FEEUNIT_YEN;
            testController.screenPropertyRecord.ParkingCompoundingFee = '10000';
            testController.screenPropertyRecord.ParkingCompoundingFeeUnit = CommonConst.PROPERTY_FEEUNIT_YEN;
            testController.screenPropertyRecord.ParkingDeposit = '10000';
            testController.screenPropertyRecord.ParkingDepositUnit = CommonConst.PROPERTY_FEEUNIT_YEN;
            testController.screenPropertyRecord.ADFee = '10000';
            testController.screenPropertyRecord.ADFeeUnit = CommonConst.PROPERTY_FEEUNIT_YEN;
            testController.screenPropertyRecord.SuumoRemarks = '';
            testController.clickSaveButton();
            testController.screenPropertyRecord.CancellationActualFee = '100';
            testController.screenPropertyRecord.CancellationActualFeeUnit = CommonConst.PROPERTY_FEEUNIT_RATE;
            testController.screenPropertyRecord.ADFee = '100';
            testController.screenPropertyRecord.ADFeeUnit = CommonConst.PROPERTY_FEEUNIT_RATE;
            testController.screenPropertyRecord.RewardBurdenLender = '50.0';
            testController.clickSaveButton();
            testController.screenPropertyRecord.CancellationActualFee = '100';
            testController.screenPropertyRecord.CancellationActualFeeUnit = CommonConst.PROPERTY_FEEUNIT_RATE;
            testController.screenPropertyRecord.SecurityDeposit = null;
            testController.screenPropertyRecord.Deposit = '10000';
            testController.screenPropertyRecord.DepositUnit = CommonConst.PROPERTY_FEEUNIT_YEN;
            testController.screenPropertyRecord.RewardBurdenLender = '50.1';
            testController.screenPropertyRecord.AtHomePanoramaShopId = shopId;
            testController.clickSaveButton();
            testController.screenPropertyRecord.RewardBurdenLender = '50.1';
            testController.screenPropertyRecord.DepositUnit = CommonConst.PROPERTY_FEEUNIT_YEN;
            testController.screenPropertyRecord.AtHomePanoramaShopId = null;
            testController.clickSaveButton();

            Test.stopTest();
        }
    }

    // テスト
    @isTest static void portalSiteMsgTest() {
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runAs(userRecord){
            Property__c testProp2 = [
                SELECT Id, Name
                FROM Property__c
                WHERE Name = '_t_'
            ];
            Building__c testBuild = [
                SELECT Id, Name
                FROM Building__c
                WHERE Name = 'テスト建物'
                AND CaretakerType__c = '通勤方式'
            ];
            
            // 店舗
            Shop__c testShop3 = new Shop__c(
                Name = 'テスト店舗3'
                ,PortalSitePostingDistrict__c = '港区'
            );
            Shop__c testShop4 = new Shop__c(
                Name = 'テスト店舗4'
                ,PortalSitePostingDistrict__c = '西区'
            );
            List<Shop__c> testShop = new List<Shop__c> {
                testShop3
                ,testShop4
            };
            insert testShop;

            // ポータルサイト掲載物件
            PortalSitePostingProperty__c testPortalSitePostingProperty1 = new PortalSitePostingProperty__c(
                Property__c = testProp2.Id
                ,Shop__c = testShop3.Id
                ,IsSuumo__c = true
                ,IsHomes__c = true
                ,IsAtHome__c = false
            );
            PortalSitePostingProperty__c testPortalSitePostingProperty2 = new PortalSitePostingProperty__c(
                Property__c = testProp2.Id
                ,Shop__c = testShop4.Id
                ,IsSuumo__c = true
                ,IsHomes__c = false
                ,IsAtHome__c = true
            );
            List<PortalSitePostingProperty__c> testPortalSitePostingProperty = new List<PortalSitePostingProperty__c> {
                testPortalSitePostingProperty1
                ,testPortalSitePostingProperty2
            };
            insert testPortalSitePostingProperty;
            
            //パラメータ設定
            PageReference pageRef = Page.GA104006View;
            pageRef.getParameters().put('buildingId', testBuild.Id);
            pageRef.getParameters().put('propertyId', testProp2.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA104006Controller testController = new GA104006Controller();
            Shop__c shop = [SELECT Id, Name,SuumoFtpServerAdress__c,HomesFtpServerAdress__c, AtHomeFtpServerAdress__c
                            FROM Shop__c 
                            WHERE NAME = 'テストユーザ店舗'];
            String shopId = shop.id;
            
            Test.startTest();
            testController.clickSaveButton();
            Test.stopTest();
        }
    }

    // チェックボックス変更テスト
    @isTest static void changeCheckBoxTest() {
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runAs(userRecord){
            Property__c testProp = [
                SELECT Id, Name
                FROM Property__c
                WHERE Name = '_t_'
            ];
            //パラメータ設定
            PageReference pageRef = Page.GA104006View;
            pageRef.getParameters().put('propertyId', testProp.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA104006Controller testController = new GA104006Controller();
            Test.startTest();
            testController.screenPropertyRecord.PropertyConditions.IsMaisonette__c = true;
            testController.clickSaveButton();
            testController.screenPropertyRecord.PropertyConditions.IsMaisonette__c = false;
            testController.clickSaveButton();
            testController.screenPropertyRecord.PropertyConditions.IsMaisonette__c = true;
            testController.clickSaveButton();

            Test.stopTest();
        }
    }

    // 
    @isTest static void createReturnMessageTest() {
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runAs(userRecord){
            Property__c testProp = [
                SELECT Id, Name
                FROM Property__c
                WHERE Name = '_t_'
            ];
            //パラメータ設定
            PageReference pageRef = Page.GA104006View;
            pageRef.getParameters().put('propertyId', testProp.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA104006Controller testController = new GA104006Controller();
            Test.startTest();
            testController.screenPropertyRecord.WortFee = '10000';
            testController.screenPropertyRecord.WortFeeTaxType = CommonConst.PROPERTY_TAXTYPE_NOTAXABLE;
            testController.screenPropertyRecord.ManagementFee = '10000';
            testController.screenPropertyRecord.ManagementFeeTaxType = CommonConst.PROPERTY_TAXTYPE_NOTAXABLE;
            testController.screenPropertyRecord.CATVFee = '10000';
            testController.screenPropertyRecord.CATVTaxType = CommonConst.PROPERTY_TAXTYPE_NOTAXABLE;
            testController.screenPropertyRecord.TownshipFee = '10000';
            testController.screenPropertyRecord.TownshipFeeTaxType = CommonConst.PROPERTY_TAXTYPE_NOTAXABLE;
            testController.screenPropertyRecord.TownshipFeePaymentType = CommonConst.PROPERTY_PAYMENTTYPE_MONTH;
            testController.screenPropertyRecord.GarbageDisposalFee = '10000';
            testController.screenPropertyRecord.GarbageDisposalFeeTaxType = CommonConst.PROPERTY_TAXTYPE_NOTAXABLE;
            testController.screenPropertyRecord.GarbageDisposalFeePaymentType = CommonConst.PROPERTY_PAYMENTTYPE_MONTH;
            testController.screenPropertyRecord.TownshipInitialFee = '10000';
            testController.screenPropertyRecord.TownshipInitialFeeTaxType = CommonConst.PROPERTY_TAXTYPE_NOTAXABLE;
            testController.screenPropertyRecord.KeyExchangeFee = '10000';
            testController.screenPropertyRecord.KeyExchangeFeeTaxType = CommonConst.PROPERTY_TAXTYPE_NOTAXABLE;
            testController.screenPropertyRecord.BicycleParkingFee = '10000';
            testController.screenPropertyRecord.BicycleParkingFeeTaxType = CommonConst.PROPERTY_TAXTYPE_NOTAXABLE;
            testController.screenPropertyRecord.ParkingFee = '10000';
            testController.screenPropertyRecord.ParkingFeeTaxType = CommonConst.PROPERTY_TAXTYPE_NOTAXABLE;
            testController.screenPropertyRecord.BikeParkingSmallFee = '10000';
            testController.screenPropertyRecord.BikeParkingSmallFeeTaxType = CommonConst.PROPERTY_TAXTYPE_NOTAXABLE;
            testController.screenPropertyRecord.BikeParkingMediumFee = '10000';
            testController.screenPropertyRecord.BikeParkingMediumFeeTaxType = CommonConst.PROPERTY_TAXTYPE_NOTAXABLE;
            testController.screenPropertyRecord.BikeParkinLargeFee = '10000';
            testController.screenPropertyRecord.BikeParkinLargeFeeTaxType = CommonConst.PROPERTY_FEEUNIT_YEN;
            testController.clickSaveButton();

            Test.stopTest();
        }
    }
    //▼問合せNo0598で追加
    /**
    * １、おすすめ物件モーダル保存ボタン
    * 　　おすすめ物件保存時の履歴が作成されないこと
    * ２、モーダル保存ボタン押下から物件登録保存
    * 　　おすすめ物件保存時の履歴が作成されること
    * ３、２保存後、物件登録画面から再度保存
    * 　　おすすめ物件保存時の履歴が作成されないこと
    */
    @isTest static void recommendPropertyMaintenanceHistory(){

        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runas(userRecord){

            Property__c testProp = [
                SELECT Id, PropertyCode__c  
                FROM Property__c
                WHERE Name = '_t_'
            ];

            //おすすめ物件登録
            RecommendProperty__c recoPro = new RecommendProperty__c(Comment__c = 'コメント',
                                                                    PropertyCode__c = testProp.PropertyCode__c,
                                                                    PhotoFileName__c = 'tatemono.aaa',
                                                                    PhotoFilePath__c = 'aaa\tatemono.aaa');
            insert recoPro;
            Test.startTest();
            //パラメータ設定
            PageReference pageRef = Page.GA104006View;
            pageRef.getParameters().put('propertyId', testProp.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA104006Controller testController = new GA104006Controller();
            
            testController.openRecommendPropertyRegistration();

            //モーダル起動
            GA104006Modal3Controller testModalController = new GA104006Modal3Controller();

            //モーダルへパラメータを引渡
            testModalController.parameter = testController.GA104006Modal3Parameter;

            //モーダルの初期表示処理
            testModalController.initAction();
            testModalController.screenRecoPro.comment = 'コメント変更';

            // 登録ボタン押下
            testModalController.registrationCleck();

            // おすすめ物件モーダル終了
            testController.closeRecommendPropertyRegistration();

            // * １、おすすめ物件モーダル保存ボタン
            // * 　　おすすめ物件保存時の履歴が作成されないこと
            System.assertEquals(1, testController.propertyMaintenanceHistoryList.size());

            // 保存ボタン押下
            testController.clickSaveButton();

            // * ２、モーダル保存ボタン押下から物件登録保存
            // * 　　おすすめ物件保存時の履歴が作成されること
            System.assertEquals(2, testController.propertyMaintenanceHistoryList.size());
            PropertyMaintenanceHistory__c testPropertyMaintenanceHistory = [
                SELECT Id, MaintenanceCommentArea__c  
                FROM PropertyMaintenanceHistory__c
                WHERE Property__c = :testProp.Id
                ORDER BY CreatedDate DESC
                LIMIT 1 
            ];
            System.assertEquals(true, testPropertyMaintenanceHistory.MaintenanceCommentArea__c.contains('おすすめ物件登録'));

            // 保存ボタン押下
            testController.clickSaveButton();

            // * ３、２保存後、物件登録画面から再度保存
            // * 　　おすすめ物件保存時の履歴が作成されないこと
            System.assertEquals(3, testController.propertyMaintenanceHistoryList.size());
            testPropertyMaintenanceHistory = [
                SELECT Id, MaintenanceCommentArea__c  
                FROM PropertyMaintenanceHistory__c
                WHERE Property__c = :testProp.Id
                ORDER BY CreatedDate DESC
                LIMIT 1 
            ];
            System.assertEquals(false, testPropertyMaintenanceHistory.MaintenanceCommentArea__c.contains('おすすめ物件登録'));

            Test.stopTest();
        }
        
    }

    /**
    * ４、モーダルから×で閉じる
    * 　　おすすめ物件保存時の履歴が作成されないこと
    *     ※モーダルを閉じる際のコントロール側での実行が無いため直接物件登録の保存を押下する
    */
    @isTest static void recommendPropertyCloseMaintenanceHistory(){

        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runas(userRecord){

            Property__c testProp = [
                SELECT Id, PropertyCode__c  
                FROM Property__c
                WHERE Name = '_t_'
            ];

            //おすすめ物件登録
            RecommendProperty__c recoPro = new RecommendProperty__c(Comment__c = 'コメント',
                                                                    PropertyCode__c = testProp.PropertyCode__c,
                                                                    PhotoFileName__c = 'tatemono.aaa',
                                                                    PhotoFilePath__c = 'aaa\tatemono.aaa');
            insert recoPro;
            Test.startTest();
            //パラメータ設定
            PageReference pageRef = Page.GA104006View;
            pageRef.getParameters().put('propertyId', testProp.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA104006Controller testController = new GA104006Controller();
            
            testController.openRecommendPropertyRegistration();

            //モーダル起動
            GA104006Modal3Controller testModalController = new GA104006Modal3Controller();

            //モーダルへパラメータを引渡
            testModalController.parameter = testController.GA104006Modal3Parameter;

            //モーダルの初期表示処理
            testModalController.initAction();
            testModalController.screenRecoPro.comment = 'コメント変更あ';

            // 保存ボタン押下
            // ※モーダルを閉じる際のコントロール側での実行が無いため直接物件登録の保存を押下する
            testController.clickSaveButton();

            // * ４、モーダルから×で閉じる
            // * 　　おすすめ物件保存時の履歴が作成されないこと
            System.assertEquals(2, testController.propertyMaintenanceHistoryList.size());
            for(PropertyMaintenanceHistory__c propertyMaintenanceHistory  : testController.propertyMaintenanceHistoryList){
                System.assertEquals(false, propertyMaintenanceHistory.MaintenanceCommentArea__c.contains('おすすめ物件登録'));
            }

            Test.stopTest();
        }
        
    }

    /**
    * ５、モーダル保存ボタン押下から物件登録保存
    * 　　おすすめ物件保存時の履歴と変更内容が１つの履歴として作成されること
    */
    @isTest static void multipleChangesMaintenanceHistory(){

        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runas(userRecord){

            Property__c testProp = [
                SELECT Id, PropertyCode__c  
                FROM Property__c
                WHERE Name = '_t_'
            ];

            //おすすめ物件登録
            RecommendProperty__c recoPro = new RecommendProperty__c(Comment__c = 'コメント２',
                                                                    PropertyCode__c = testProp.PropertyCode__c,
                                                                    PhotoFileName__c = 'tatemono.aaa',
                                                                    PhotoFilePath__c = 'aaa\tatemono.aaa');
            insert recoPro;
            Test.startTest();
            //パラメータ設定
            PageReference pageRef = Page.GA104006View;
            pageRef.getParameters().put('propertyId', testProp.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA104006Controller testController = new GA104006Controller();
            
            testController.openRecommendPropertyRegistration();

            //モーダル起動
            GA104006Modal3Controller testModalController = new GA104006Modal3Controller();

            //モーダルへパラメータを引渡
            testModalController.parameter = testController.GA104006Modal3Parameter;

            //モーダルの初期表示処理
            testModalController.initAction();
            testModalController.screenRecoPro.comment = 'コメント変更２';

            // 登録ボタン押下
            testModalController.registrationCleck();

            // 項目変更
            testController.screenPropertyRecord.RentFee = '50000';        // 賃料

            // おすすめ物件モーダル終了
            testController.closeRecommendPropertyRegistration();

            // 保存ボタン押下
            testController.clickSaveButton();

            // * ５、モーダル保存ボタン押下から物件登録保存
            // * 　　おすすめ物件保存時の履歴と変更内容が１つの履歴として作成されること
            System.assertEquals(2, testController.propertyMaintenanceHistoryList.size());
            PropertyMaintenanceHistory__c testPropertyMaintenanceHistory = [
                SELECT Id, MaintenanceCommentArea__c  
                FROM PropertyMaintenanceHistory__c
                WHERE Property__c = :testProp.Id
                ORDER BY CreatedDate DESC
                LIMIT 1 
            ];
            System.assertEquals(true, testPropertyMaintenanceHistory.MaintenanceCommentArea__c.contains('50,000円'));
            System.assertEquals(true, testPropertyMaintenanceHistory.MaintenanceCommentArea__c.contains('おすすめ物件登録'));

            Test.stopTest();
        }
        
    }

    /**
    * ６、コピー元の物件でおすすめ物件をモーダルで保存
    * 　　コピー物件が保存時におすすめ物件の履歴が作成されないこと
    */
    @isTest static void propertyCopyRecommendPropertyHistory(){

        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runas(userRecord){

            Property__c testProp = [
                SELECT Id, PropertyCode__c  
                FROM Property__c
                WHERE Name = '_t_'
            ];

            //おすすめ物件登録
            RecommendProperty__c recoPro = new RecommendProperty__c(Comment__c = 'コメント３',
                                                                    PropertyCode__c = testProp.PropertyCode__c,
                                                                    PhotoFileName__c = 'tatemono.aaa',
                                                                    PhotoFilePath__c = 'aaa\tatemono.aaa');
            insert recoPro;
            Test.startTest();
            //パラメータ設定
            PageReference pageRef = Page.GA104006View;
            pageRef.getParameters().put('propertyId', testProp.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA104006Controller testController = new GA104006Controller();
           
            testController.openRecommendPropertyRegistration();

            //モーダル起動
            GA104006Modal3Controller testModalController = new GA104006Modal3Controller();

            //モーダルへパラメータを引渡
            testModalController.parameter = testController.GA104006Modal3Parameter;

            //モーダルの初期表示処理
            testModalController.initAction();
            testModalController.screenRecoPro.comment = 'コメント変更３';

            // 登録ボタン押下
            testModalController.registrationCleck();
            
            // おすすめ物件モーダル終了
            testController.closeRecommendPropertyRegistration();

            // 物件コピー
            testController.clickPropertyCopyButton();

            // 物件名変更
            testController.screenPropertyRecord.Name = '_t_2';

            // 保存ボタン押下
            testController.clickSaveButton();

            // * ６、コピー元の物件でおすすめ物件をモーダルで保存
            // * 　　コピー物件が保存時におすすめ物件の履歴が作成されないこと
            System.assertEquals(1, testController.propertyMaintenanceHistoryList.size());
            System.assertEquals(true, testController.propertyMaintenanceHistoryList[0].MaintenanceCommentArea__c.contains('物件を登録しました。'));

            Test.stopTest();
        }
        
    }

    /**
    * ７、コピー元の物件でおすすめ物件をモーダルで保存
    * 　　物件登録画面からキャンセルボタン押下後、保存ボタン押下でおすすめ物件の履歴が作成されること
    */
    @isTest static void propertyCopyCancelRecommendPropertyHistory(){

        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runas(userRecord){

            Property__c testProp = [
                SELECT Id, PropertyCode__c  
                FROM Property__c
                WHERE Name = '_t_'
            ];

            //おすすめ物件登録
            RecommendProperty__c recoPro = new RecommendProperty__c(Comment__c = 'コメント４',
                                                                    PropertyCode__c = testProp.PropertyCode__c,
                                                                    PhotoFileName__c = 'tatemono.aaa',
                                                                    PhotoFilePath__c = 'aaa\tatemono.aaa');
            insert recoPro;
            Test.startTest();
            //パラメータ設定
            PageReference pageRef = Page.GA104006View;
            pageRef.getParameters().put('propertyId', testProp.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA104006Controller testController = new GA104006Controller();
            
            

            testController.openRecommendPropertyRegistration();

            //モーダル起動
            GA104006Modal3Controller testModalController = new GA104006Modal3Controller();

            //モーダルへパラメータを引渡
            testModalController.parameter = testController.GA104006Modal3Parameter;

            //モーダルの初期表示処理
            testModalController.initAction();
            testModalController.screenRecoPro.comment = 'コメント変更３';

            // 登録ボタン押下
            testModalController.registrationCleck();
            
            // おすすめ物件モーダル終了
            testController.closeRecommendPropertyRegistration();

            // 物件コピー
            testController.clickPropertyCopyButton();

            // 物件名変更
            testController.screenPropertyRecord.Name = '_t_2';

            // キャンセルボタン押下
            testController.clickCancelButton();

            // 保存ボタン押下
            testController.clickSaveButton();

            // * ７、コピー元の物件でおすすめ物件をモーダルで保存
            // * 　　物件登録画面からキャンセルボタン押下後、保存ボタン押下でおすすめ物件の履歴が作成されること
            System.assertEquals(2, testController.propertyMaintenanceHistoryList.size());
            PropertyMaintenanceHistory__c testPropertyMaintenanceHistory = [
                SELECT Id, MaintenanceCommentArea__c  
                FROM PropertyMaintenanceHistory__c
                WHERE Property__c = :testProp.Id
                ORDER BY CreatedDate DESC
                LIMIT 1 
            ];
            System.assertEquals(true, testPropertyMaintenanceHistory.MaintenanceCommentArea__c.contains('おすすめ物件登録'));

            Test.stopTest();
        }
        
    }
    //▲問合せNo0598で追加

// ▼2022.02.02 No.0676 対応
    /**
    * １．保存押下
    * 　　報酬負担貸主：空
	* 　　報酬負担借主：空
	*     エラー無く保存でき、仲介手数料の金額に仲介手数料率（100%）が考慮されること
    */
	@isTest static void decisionBrokerageFirstFeeRate01(){
		Property__c testProp2 = [SELECT Id, Name,RentFee__c	FROM Property__c WHERE Name = '_t_'];
		Building__c testBuild = [SELECT Id, Name FROM Building__c WHERE Name = 'テスト建物'	AND CaretakerType__c = '通勤方式'];

		// 想定仲介手数料
		// RentFee__c * (1 + SystemConfig__c.TaxRate__c))
        Decimal beforeBrokerageFeeTax = testProp2.RentFee__c *(1+(0.01 * SystemConfig__c.getInstance().TaxRate__c));

		//パラメータ設定
		PageReference pageRef = Page.GA104006View;
		pageRef.getParameters().put('buildingId', testBuild.Id);
		pageRef.getParameters().put('propertyId', testProp2.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		//コントローラ作成
		GA104006Controller testController = new GA104006Controller();
		testController.screenPropertyRecord.RewardBurdenLender = '';	// 報酬負担貸主
		testController.screenPropertyRecord.RewardBurdenBorrower = '';	// 報酬負担借主

		// 登録ボタン押下
		testController.clickSaveButton();

		Test.stopTest();
		
		Property__c  propertyBrokerageFeeTax = [SELECT ID, BrokerageFeeTax__c FROM Property__c WHERE Name = '_t_' LIMIT 1];
		// 保存成功
		System.assertEquals(false,testController.hasErrorMessage);
		// 仲介手数料
		System.assertEquals(beforeBrokerageFeeTax,propertyBrokerageFeeTax.BrokerageFeeTax__c);
		
	}
	/**
    * ２．保存押下
	*     報酬負担貸主：０
    *     報酬負担借主：０
	*     エラー無く保存でき、仲介手数料の金額に仲介手数料率（100%）が考慮されること
    */
	@isTest static void decisionBrokerageFirstFeeRate02(){
		Property__c testProp2 = [SELECT Id, Name,RentFee__c	FROM Property__c WHERE Name = '_t_'];
		Building__c testBuild = [SELECT Id, Name FROM Building__c WHERE Name = 'テスト建物'	AND CaretakerType__c = '通勤方式'];

		// 想定仲介手数料
		// RentFee__c * (1 + SystemConfig__c.TaxRate__c))
        Decimal beforeBrokerageFeeTax = testProp2.RentFee__c *(1+(0.01 * SystemConfig__c.getInstance().TaxRate__c));

		//パラメータ設定
		PageReference pageRef = Page.GA104006View;
		pageRef.getParameters().put('buildingId', testBuild.Id);
		pageRef.getParameters().put('propertyId', testProp2.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		//コントローラ作成
		GA104006Controller testController = new GA104006Controller();
		testController.screenPropertyRecord.RewardBurdenLender = '0';	// 報酬負担貸主
		testController.screenPropertyRecord.RewardBurdenBorrower = '0';	// 報酬負担借主

		// 登録ボタン押下
		testController.clickSaveButton();

		Test.stopTest();
		
		Property__c  propertyBrokerageFeeTax = [SELECT ID, BrokerageFeeTax__c FROM Property__c WHERE Name = '_t_' LIMIT 1];
		// 保存成功
		System.assertEquals(false,testController.hasErrorMessage);
		// 仲介手数料
		System.assertEquals(beforeBrokerageFeeTax,propertyBrokerageFeeTax.BrokerageFeeTax__c);
		
	}
	/**
    * ３．保存押下
	*     報酬負担貸主：１００
	*     報酬負担借主：０
	*     エラー無く保存でき、仲介手数料の金額に報酬負担借主が考慮されること
    */
	@isTest static void decisionBrokerageFirstFeeRate03(){
		Property__c testProp2 = [SELECT Id, Name,RentFee__c	FROM Property__c WHERE Name = '_t_'];
		Building__c testBuild = [SELECT Id, Name FROM Building__c WHERE Name = 'テスト建物'	AND CaretakerType__c = '通勤方式'];

		// 想定仲介手数料
		// RentFee__c * (1 + SystemConfig__c.TaxRate__c))
		Decimal beforeBrokerageFeeTax = testProp2.RentFee__c *(1+(0.01 * SystemConfig__c.getInstance().TaxRate__c))*0;

		//パラメータ設定
		PageReference pageRef = Page.GA104006View;
		pageRef.getParameters().put('buildingId', testBuild.Id);
		pageRef.getParameters().put('propertyId', testProp2.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		//コントローラ作成
		GA104006Controller testController = new GA104006Controller();
		testController.screenPropertyRecord.RewardBurdenLender = '100';	// 報酬負担貸主
		testController.screenPropertyRecord.RewardBurdenBorrower = '0';	// 報酬負担借主

		// 登録ボタン押下
		testController.clickSaveButton();

		Test.stopTest();
		
		Property__c  propertyBrokerageFeeTax = [SELECT ID, BrokerageFeeTax__c FROM Property__c WHERE Name = '_t_' LIMIT 1];
		// 保存成功
		System.assertEquals(false,testController.hasErrorMessage);
		// 仲介手数料
		System.assertEquals(beforeBrokerageFeeTax,propertyBrokerageFeeTax.BrokerageFeeTax__c);
		
	}
	/**
    * ４．保存押下
    *     報酬負担貸主：０
	*     報酬負担借主：１００
	*     エラー無く保存でき、仲介手数料の金額に報酬負担借主が考慮されること
    */
	@isTest static void decisionBrokerageFirstFeeRate04(){
		Property__c testProp2 = [SELECT Id, Name,RentFee__c	FROM Property__c WHERE Name = '_t_'];
		Building__c testBuild = [SELECT Id, Name FROM Building__c WHERE Name = 'テスト建物'	AND CaretakerType__c = '通勤方式'];

		// 想定仲介手数料
		// RentFee__c * (1 + $Setup.SystemConfig__c.TaxRate__c) * RewardBurdenBorrower__c)
		Decimal beforeBrokerageFeeTax = testProp2.RentFee__c *(1+(0.01 * SystemConfig__c.getInstance().TaxRate__c));

		//パラメータ設定
		PageReference pageRef = Page.GA104006View;
		pageRef.getParameters().put('buildingId', testBuild.Id);
		pageRef.getParameters().put('propertyId', testProp2.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		//コントローラ作成
		GA104006Controller testController = new GA104006Controller();
		testController.screenPropertyRecord.RewardBurdenLender = '0';	// 報酬負担貸主
		testController.screenPropertyRecord.RewardBurdenBorrower = '100';	// 報酬負担借主

		// 登録ボタン押下
		testController.clickSaveButton();

		Test.stopTest();
		
		Property__c  propertyBrokerageFeeTax = [SELECT ID, BrokerageFeeTax__c FROM Property__c WHERE Name = '_t_' LIMIT 1];
		// 保存成功
		System.assertEquals(false,testController.hasErrorMessage);
		// 仲介手数料
		System.assertEquals(beforeBrokerageFeeTax,propertyBrokerageFeeTax.BrokerageFeeTax__c);
		
	}
	/**
    * ５．保存押下
    *     報酬負担貸主：５０
	*     報酬負担借主：５０
	*     エラー無く保存でき、仲介手数料の金額に報酬負担借主が考慮されること
    */
	@isTest static void decisionBrokerageFirstFeeRate05(){
		Property__c testProp2 = [SELECT Id, Name,RentFee__c	FROM Property__c WHERE Name = '_t_'];
		Building__c testBuild = [SELECT Id, Name FROM Building__c WHERE Name = 'テスト建物'	AND CaretakerType__c = '通勤方式'];

		// 想定仲介手数料
		// RentFee__c * (1 + $Setup.SystemConfig__c.TaxRate__c) * RewardBurdenBorrower__c)
		Decimal beforeBrokerageFeeTax = testProp2.RentFee__c *(1+(0.01 * SystemConfig__c.getInstance().TaxRate__c))*(0.01 * 50);

		//パラメータ設定
		PageReference pageRef = Page.GA104006View;
		pageRef.getParameters().put('buildingId', testBuild.Id);
		pageRef.getParameters().put('propertyId', testProp2.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		//コントローラ作成
		GA104006Controller testController = new GA104006Controller();
		testController.screenPropertyRecord.RewardBurdenLender = '50';	// 報酬負担貸主
		testController.screenPropertyRecord.RewardBurdenBorrower = '50';	// 報酬負担借主

		// 登録ボタン押下
		testController.clickSaveButton();

		Test.stopTest();
		
		Property__c  propertyBrokerageFeeTax = [SELECT ID, BrokerageFeeTax__c FROM Property__c WHERE Name = '_t_' LIMIT 1];
		// 保存成功
		System.assertEquals(false,testController.hasErrorMessage);
		// 仲介手数料
		System.assertEquals(beforeBrokerageFeeTax,propertyBrokerageFeeTax.BrokerageFeeTax__c);
		
	}
	/**
    * ６．保存押下
    * 　　報酬負担貸主＋
	* 　　報酬負担借主＝１００
	*     エラー無く保存でき、仲介手数料の金額に報酬負担借主が考慮されること	
    */
	@isTest static void decisionBrokerageFirstFeeRate06(){
		Property__c testProp2 = [SELECT Id, Name,RentFee__c	FROM Property__c WHERE Name = '_t_'];
		Building__c testBuild = [SELECT Id, Name FROM Building__c WHERE Name = 'テスト建物'	AND CaretakerType__c = '通勤方式'];

		// 想定仲介手数料
		// RentFee__c * (1 + $Setup.SystemConfig__c.TaxRate__c) * RewardBurdenBorrower__c)
		Decimal beforeBrokerageFeeTax = testProp2.RentFee__c*(1+(0.01 * SystemConfig__c.getInstance().TaxRate__c))*(0.01 * 89.9);
		//パラメータ設定
		PageReference pageRef = Page.GA104006View;
		pageRef.getParameters().put('buildingId', testBuild.Id);
		pageRef.getParameters().put('propertyId', testProp2.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		//コントローラ作成
		GA104006Controller testController = new GA104006Controller();
		testController.screenPropertyRecord.RewardBurdenLender = '10.1';	// 報酬負担貸主
		testController.screenPropertyRecord.RewardBurdenBorrower = '89.9';	// 報酬負担借主

		// 登録ボタン押下
		testController.clickSaveButton();

		Test.stopTest();
		
		Property__c  propertyBrokerageFeeTax = [SELECT ID, BrokerageFeeTax__c FROM Property__c WHERE Name = '_t_' LIMIT 1];
		// 保存成功
		System.assertEquals(false,testController.hasErrorMessage);
		// 仲介手数料
		System.assertEquals(beforeBrokerageFeeTax,propertyBrokerageFeeTax.BrokerageFeeTax__c);
		
	}
	/**
    * ７．保存押下
    * 　　報酬負担貸主＋
	*     報酬負担借主＝１００より上
	*     エラーが発生し、保存されないこと
    */
	@isTest static void decisionBrokerageFirstFeeRate07(){
		Property__c testProp2 = [SELECT Id, Name,RentFee__c	FROM Property__c WHERE Name = '_t_'];
		Building__c testBuild = [SELECT Id, Name FROM Building__c WHERE Name = 'テスト建物'	AND CaretakerType__c = '通勤方式'];

		//パラメータ設定
		PageReference pageRef = Page.GA104006View;
		pageRef.getParameters().put('buildingId', testBuild.Id);
		pageRef.getParameters().put('propertyId', testProp2.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		//コントローラ作成
		GA104006Controller testController = new GA104006Controller();
		testController.screenPropertyRecord.RewardBurdenLender = '50.1';	// 報酬負担貸主
		testController.screenPropertyRecord.RewardBurdenBorrower = '50';	// 報酬負担借主

		// 登録ボタン押下
		testController.clickSaveButton();

		Test.stopTest();
		
		// エラー
		System.assertEquals(true,testController.hasErrorMessage);		
	}
	/**
    * ８．保存押下
    * 　　報酬負担貸主＋
	*     報酬負担借主＝１００以下
	*     エラー無く保存でき、仲介手数料の金額に報酬負担借主が考慮されること
    */
	@isTest static void decisionBrokerageFirstFeeRate08(){
		Property__c testProp2 = [SELECT Id, Name,RentFee__c	FROM Property__c WHERE Name = '_t_'];
		Building__c testBuild = [SELECT Id, Name FROM Building__c WHERE Name = 'テスト建物'	AND CaretakerType__c = '通勤方式'];

		// 想定仲介手数料
		// RentFee__c * (1 + $Setup.SystemConfig__c.TaxRate__c) * RewardBurdenBorrower__c)
		Decimal beforeBrokerageFeeTax = testProp2.RentFee__c *(1+(0.01 * SystemConfig__c.getInstance().TaxRate__c))*(0.01 * 30);
		//パラメータ設定
		PageReference pageRef = Page.GA104006View;
		pageRef.getParameters().put('buildingId', testBuild.Id);
		pageRef.getParameters().put('propertyId', testProp2.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		//コントローラ作成
		GA104006Controller testController = new GA104006Controller();
		testController.screenPropertyRecord.RewardBurdenLender = '60';	// 報酬負担貸主
		testController.screenPropertyRecord.RewardBurdenBorrower = '30';	// 報酬負担借主

		// 登録ボタン押下
		testController.clickSaveButton();

		Test.stopTest();
		
		Property__c  propertyBrokerageFeeTax = [SELECT ID, BrokerageFeeTax__c FROM Property__c WHERE Name = '_t_' LIMIT 1];
		// 保存成功
		System.assertEquals(false,testController.hasErrorMessage);
		// 仲介手数料
		System.assertEquals(beforeBrokerageFeeTax,propertyBrokerageFeeTax.BrokerageFeeTax__c);
		
	}
	/**
	* ９．一時保存
	* 　　報酬負担貸主：空
	* 　　報酬負担借主：空
	*     エラー無く保存できること
    */
	@isTest static void decisionBrokerageFirstFeeRateTempSave01(){
		Property__c testProp2 = [SELECT Id, Name,RentFee__c	FROM Property__c WHERE Name = '_t_'];
		Building__c testBuild = [SELECT Id, Name FROM Building__c WHERE Name = 'テスト建物'	AND CaretakerType__c = '通勤方式'];

		// 想定仲介手数料
		// RentFee__c * (1 + SystemConfig__c.TaxRate__c))
        Decimal beforeBrokerageFeeTax = testProp2.RentFee__c *(1+(0.01 * SystemConfig__c.getInstance().TaxRate__c));

		//パラメータ設定
		PageReference pageRef = Page.GA104006View;
		pageRef.getParameters().put('buildingId', testBuild.Id);
		pageRef.getParameters().put('propertyId', testProp2.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		//コントローラ作成
		GA104006Controller testController = new GA104006Controller();
		testController.screenPropertyRecord.RewardBurdenLender = '';	// 報酬負担貸主
		testController.screenPropertyRecord.RewardBurdenBorrower = '';	// 報酬負担借主

		// 一時保存押下
		testController.clickTempSaveButton();

		Test.stopTest();
		
		Property__c  propertyBrokerageFeeTax = [SELECT ID, BrokerageFeeTax__c FROM Property__c WHERE Name = '_t_' LIMIT 1];
		// 保存成功
		System.assertEquals(false,testController.hasErrorMessage);
		// 仲介手数料
		System.assertEquals(beforeBrokerageFeeTax,propertyBrokerageFeeTax.BrokerageFeeTax__c);
		
	}
	/**
	* 10．一時保存
	*     報酬負担貸主：０
    *     報酬負担借主：０
	*     エラー無く保存できること
    */
	@isTest static void decisionBrokerageFirstFeeRateTempSave02(){
		Property__c testProp2 = [SELECT Id, Name,RentFee__c	FROM Property__c WHERE Name = '_t_'];
		Building__c testBuild = [SELECT Id, Name FROM Building__c WHERE Name = 'テスト建物'	AND CaretakerType__c = '通勤方式'];

		// 想定仲介手数料
		// RentFee__c * (1 + SystemConfig__c.TaxRate__c))
        Decimal beforeBrokerageFeeTax = testProp2.RentFee__c *(1+(0.01 * SystemConfig__c.getInstance().TaxRate__c));

		//パラメータ設定
		PageReference pageRef = Page.GA104006View;
		pageRef.getParameters().put('buildingId', testBuild.Id);
		pageRef.getParameters().put('propertyId', testProp2.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		//コントローラ作成
		GA104006Controller testController = new GA104006Controller();
		testController.screenPropertyRecord.RewardBurdenLender = '0';	// 報酬負担貸主
		testController.screenPropertyRecord.RewardBurdenBorrower = '0';	// 報酬負担借主

		// 一時保存押下
		testController.clickTempSaveButton();

		Test.stopTest();
		
		Property__c  propertyBrokerageFeeTax = [SELECT ID, BrokerageFeeTax__c FROM Property__c WHERE Name = '_t_' LIMIT 1];
		// 保存成功
		System.assertEquals(false,testController.hasErrorMessage);
		// 仲介手数料
		System.assertEquals(beforeBrokerageFeeTax,propertyBrokerageFeeTax.BrokerageFeeTax__c);
		
	}
	/**
	* 11．一時保存
    * 　　報酬負担貸主＋
	*     報酬負担借主＝１００より上
	*     エラー無く保存できること
    */
	@isTest static void decisionBrokerageFirstFeeRateTempSave03(){
		Property__c testProp2 = [SELECT Id, Name,RentFee__c	FROM Property__c WHERE Name = '_t_'];
		Building__c testBuild = [SELECT Id, Name FROM Building__c WHERE Name = 'テスト建物'	AND CaretakerType__c = '通勤方式'];

		// RentFee__c * (1 + $Setup.SystemConfig__c.TaxRate__c) * RewardBurdenBorrower__c)
		Decimal beforeBrokerageFeeTax = testProp2.RentFee__c *(1+(0.01 * SystemConfig__c.getInstance().TaxRate__c))*(0.01 * 950);
		//パラメータ設定
		PageReference pageRef = Page.GA104006View;
		pageRef.getParameters().put('buildingId', testBuild.Id);
		pageRef.getParameters().put('propertyId', testProp2.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		//コントローラ作成
		GA104006Controller testController = new GA104006Controller();
		testController.screenPropertyRecord.RewardBurdenLender = '50.1';	// 報酬負担貸主
		testController.screenPropertyRecord.RewardBurdenBorrower = '950';	// 報酬負担借主

		// 一時保存押下
		testController.clickTempSaveButton();

		Test.stopTest();
		
		Property__c  propertyBrokerageFeeTax = [SELECT ID, BrokerageFeeTax__c FROM Property__c WHERE Name = '_t_' LIMIT 1];
		// 保存成功
		System.assertEquals(false,testController.hasErrorMessage);
		// 仲介手数料
		System.assertEquals(beforeBrokerageFeeTax,propertyBrokerageFeeTax.BrokerageFeeTax__c);
	}
// ▲2022.02.02 No.0676 対応	

}