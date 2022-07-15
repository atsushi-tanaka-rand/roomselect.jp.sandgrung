@isTest
public class TA102004Test {

    public static final String USER_NAME = 'TA102004@horaguchi.com'; 

    //テストに使用するレコードを作成
    @testSetup static void Setting(){
        //店舗レコード
        Shop__c testUserShop = new shop__c(
            Name = 'テストユーザ店舗'
            ,PortalSitePostingDistrict__c = '港区'
            ,Phone__c = '1234567890'
            ,Fax__c = '9999999999'
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
        insert testBuilding;

        // 取引先（元付）
        Account testFormerSupplier = new Account(
            Name = 'テスト元付業者'
            ,RecordTypeId = CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_SUPPLIER)
            ,IsOwner__c = false
            ,IsManagementCompany__c = true
            ,IsSubLease__c = false
            ,IsGuaranteeidCompany__c = false
            ,IsInsuranceCompany__c = false
        );
        // 取引先（貸主）
        Account testCreditor = new Account(
            Name = 'テスト貸主'
            ,RecordTypeId = CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_SUPPLIER)
            ,IsOwner__c = true
            ,IsManagementCompany__c = true
            ,IsSubLease__c = true
            ,IsGuaranteeidCompany__c = false
            ,IsInsuranceCompany__c = false
        );
        // 取引先（所有者）
        Account testOwner = new Account(
            Name = 'テスト所有者'
            ,RecordTypeId = CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_SUPPLIER)
            ,IsOwner__c = true
            ,IsManagementCompany__c = false
            ,IsSubLease__c = false
            ,IsGuaranteeidCompany__c = false
            ,IsInsuranceCompany__c = false
        );
        // 取引先（火災保険会社）
        Account testFireInsuranceComp = new Account(
            Name = 'テスト火災保険会社'
            ,RecordTypeId = CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_FIRE_INSURANCE)
            ,IsOwner__c = false
            ,IsManagementCompany__c = false
            ,IsSubLease__c = false
            ,IsGuaranteeidCompany__c = false
            ,IsInsuranceCompany__c = true
        );
        // 取引先（保証会社）
        Account testGuaranteeComp = new Account(
            Name = 'テスト保証会社'
            ,RecordTypeId = CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_GUARANTEE)
            ,IsOwner__c = false
            ,IsManagementCompany__c = false
            ,IsSubLease__c = false
            ,IsGuaranteeidCompany__c = true
            ,IsInsuranceCompany__c = false
        );
        // 取引先（顧客）
        Account testCustomer = new Account(
            Name = 'テスト申込顧客'
            ,RecordTypeId = CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_CUSTOMER)
            ,IsOwner__c = false
            ,IsManagementCompany__c = false
            ,IsSubLease__c = false
            ,IsGuaranteeidCompany__c = false
            ,IsInsuranceCompany__c = false
        );
        List<Account> testAccount = new List<Account> {
            testFormerSupplier
            ,testCreditor
            ,testOwner
            ,testFireInsuranceComp
            ,testGuaranteeComp
            ,testCustomer
        };
        insert testAccount;

        // 商品（火災保険）
        Item__c testFireInsuranceItem1 = new Item__c(
            Account__c = testFireInsuranceComp.Id
            ,RecordTypeId = CommonUtil.getRecordTypeId('Item__c', CommonConst.ITEM_RECTYPE_FIRE_INSURANCE)
            ,ItemName__c = 'テスト火災保険商品１'
            ,FireInsuranceMonth__c = 2000
            ,FireInsuranceYear__c = null
            ,PaymentType__c = CommonConst.ITEM_PAYMENTTYPE_YEAR
            ,PaymentYear__c = 1
        );
        Item__c testFireInsuranceItem2 = new Item__c(
            Account__c = testFireInsuranceComp.Id
            ,RecordTypeId = CommonUtil.getRecordTypeId('Item__c', CommonConst.ITEM_RECTYPE_FIRE_INSURANCE)
            ,ItemName__c = 'テスト火災保険商品２'
            ,FireInsuranceMonth__c = null
            ,FireInsuranceYear__c = 10000
            ,PaymentType__c = CommonConst.ITEM_PAYMENTTYPE_MONTH
            ,PaymentYear__c = 2
        );
        // 商品（保証）
        Item__c testGuaranteeItem1 = new Item__c(
            Account__c = testGuaranteeComp.Id
            ,RecordTypeId = CommonUtil.getRecordTypeId('Item__c', CommonConst.ITEM_RECTYPE_GUARANTEE_PLAN)
            ,ItemName__c = 'テスト保証商品１'
            ,AssuranceContent__c = '保証内容１行目\n保証内容２行目'
            ,DirectDebitFee__c = 2000
            ,DirectDebitFeeTaxType__c = CommonConst.PROPERTY_TAXTYPE_TAXABLE
        );
        Item__c testGuaranteeItem2 = new Item__c(
            Account__c = testGuaranteeComp.Id
            ,RecordTypeId = CommonUtil.getRecordTypeId('Item__c', CommonConst.ITEM_RECTYPE_GUARANTEE_PLAN)
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
            ,RecordTypeId = CommonUtil.getRecordTypeId('InsuranceGuarantee__c', CommonConst.INSURANCE_RECTYPE_GUARANTEE_FIREINSURANCE)
        );
        InsuranceGuarantee__c testInsuranceGuarantee2 = new InsuranceGuarantee__c(
            Account__c = testFormerSupplier.Id
            ,Item__c = testFireInsuranceItem2.Id
            ,RecordTypeId = CommonUtil.getRecordTypeId('InsuranceGuarantee__c', CommonConst.INSURANCE_RECTYPE_GUARANTEE_FIREINSURANCE)
        );
        // 取引先保険保証（保証）
        InsuranceGuarantee__c testInsuranceGuarantee3 = new InsuranceGuarantee__c(
            Account__c = testFormerSupplier.Id
            ,Item__c = testGuaranteeItem1.Id
            ,RecordTypeId = CommonUtil.getRecordTypeId('InsuranceGuarantee__c', CommonConst.INSURANCE_RECTYPE_GUARANTEE_GUARANTEE)
        );
        InsuranceGuarantee__c testInsuranceGuarantee4 = new InsuranceGuarantee__c(
            Account__c = testFormerSupplier.Id
            ,Item__c = testGuaranteeItem2.Id
            ,RecordTypeId = CommonUtil.getRecordTypeId('InsuranceGuarantee__c', CommonConst.INSURANCE_RECTYPE_GUARANTEE_GUARANTEE)
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

        // 物件
        Property__c testProperty = new Property__c(
            Name                        = 'テスト物件'                               // 部屋番号
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
            ,PropertyRemarksPublic__c   = 'テスト物件備考（公開）'                    // 物件備考（公開）
            ,PropertyRemarksPrivate__c  = 'テスト物件備考（非公開）'                  // 物件備考（非公開）
            ,PropertyComment__c         = 'テスト物件コメント'                       // 物件コメント
            ,RepresentativeComment__c   = 'テスト担当者コメント'                      // 担当者コメント
            ,MaintenanceCommentArea__c  = ''                                        // メンテナンスコメント
            ,RentFee__c                 = 40000                                     // 賃料
            ,WortFee__c                 = 2000                                      // 水道料金
            ,WortFeeTaxType__c          = CommonConst.PROPERTY_TAXTYPE_TAXABLE      // 水道料金税区分
            ,SecurityDepositYen__c      = 20000                                     // 敷金（円）
            ,SecurityDepositMonth__c    = 0.5                                       // 敷金（ヵ月）
            ,SecurityDepositUnit__c     = CommonConst.PROPERTY_FEEUNIT_MONTH        // 敷金単位
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
            ,ParkingType__c             = CommonConst.PROPERTY_PARKINGTYPE_NO_EMPTY // 駐車場種別
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
        );
        insert testProperty;

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
            ,IsElectricStove__c                 = true  // 電気コンロ
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

        //申込
        Application__c testApplication = new Application__c(
            Account__c = testCustomer.Id
            ,Property__c = testProperty.Id
            ,Rent__c = 60000                  //賃料
            ,WortFee__c = 1000                //水道料金
            ,SecurityDeposit__c = 20000       //敷金
            ,ActualFee__c = 10000             //敷引/償却
            ,ManagementFee__c = 5000          //管理費
            ,CATV__c = 2000                   //CATV
            ,Deposit__c = 20000               //保証金
            ,RenewalFeeYen__c = 5000          //更新料/更新事務手数料
            ,TownshipFee__c=3000
            ,GarbageDisposalFee__c=2000
            ,KeyMoney__c=3000
            ,TownshipAdmissionFee__c=2000
            ,BicycleParkingFee__c=3000
            ,CleaningFeeYen__c=2000
            ,KeyExchangeFee__c=5000
            ,CancellationActualFeeUnit__c='円'
            //駐車場
            ,ParkingFee__c=1000
            ,ParkingDeposit__c=2000
            ,ParkingBrokerageFirstFee__c=3000
            ,BikeStorageSmallFirstFee__c=2000
            ,BikeStorageMediumFirstFee__c=3000
            ,BikeStorageLargeFirstFee__c=4000
            //契約者情報
            ,ApplicationType__c='個人'
            ,ApplicationDate__c=Date.newInstance(2020,1,14) 
            ,TenantDesiredDate__c=Date.newInstance(2020,4,1) 
            ,IsTenantPersonInclude__c=true
            ,LastName__c='テスト'
            ,FirstName__c='申込太郎'
            ,LastNameKana__c='テスト'
            ,FirstNameKana__c='モウシコミタロウ'
            ,Birthdate__c=Date.newInstance(1990,1,1) 
            ,IsSpouse__c='有'
            ,ChildrenCount__c=1
            ,Current__c='111-1111'
            ,CurrentState__c='愛知県'
            ,CurrentCity__c='名古屋市テスト町'
            ,CurrentStreet__c='4-1-34'
            ,ResidenceType__c='マンション（分譲）'
            ,ResidenceTermYear__c=3
            ,ResidenceTermMonth__c=1
            ,CurrentPhone__c='1234-111-1234'
            ,CurrentMobilePhone__c='090-0000-0000'
            //契約者勤務先
            ,Affiliation__c='株式会社テスト勤務'
            ,Industries__c='製造業'
            ,AffiliationPostalCode__c='112-1122'
            ,AffiliationState__c='愛知県'
            ,AffiliationCity__c='北名古屋市テスト区'
            ,AffiliationStreet__c='1-3-99'
            ,AffiliationPhone__c='1122-111-2222'
            ,Department__c='営業部'
            ,JobType__c='会社員'
            ,Post__c='係長'
            ,AnnualIncome__c=4000000
            ,ContinuedServiceYearsYear__c=5
            ,ContinuedServiceYearsMonth__c=2
            //車両
            ,CarMaker__c='トヨタ'
            ,CarType__c='シャシュ'
            ,CarColor__c='黒'
            ,RegistNumber__c='名古屋111ん00-00'
            //連帯保証人
            ,JointGuarantorLastName__c='申込'
            ,JointGuarantorFirstName__c='テストの助'
            ,JointGuarantorLastNameKana__c='モウシコミ'
            ,JointGuarantorFirstNameKana__c='テストノスケ'
            ,JointGuarantorPostalCode__c='222-2222'
            ,JointGuarantorState__c='愛知県'
            ,JointGuarantorCity__c='豊田市テス町'
            ,JointGuarantorStreet__c='11-111'
            ,JointGuarantorBirthdate__c=Date.newInstance(1980,1,1) 
            ,JointGuarantorPhone__c='123-1111-2222'
            ,JointGuarantorMobilePhone__c='090-1111-1111'
            ,ApplicantRelationship__c='兄'
            ,JointGuarantorIsSpouse__c='有'
            ,JointGuarantorResidenceType__c='自己所有'
            //連帯保証人勤務先
            ,JointGuarantorAffiliation__c='連帯テスト株式会社'
            ,JointGuarantorIndustries__c='建設業'
            ,JointGuarantorAffiliationPostalCode__c='343-4443'
            ,JointGuarantorAffiliationState__c='静岡県'
            ,JointGuarantorAffiliationCity__c='静岡市テスト町'
            ,JointGuarantorAffiliationStreet__c='4-44'
            ,JointGuarantorAffiliationPhone__c='234-444-4444'
            ,JointGuarantorDepartment__c='販売部'
            ,JointGuarantorJobType__c='会社員'
            ,JointGuarantorPost__c='販売部長'
            ,JointGuarantorAnnualIncome__c=5000000
            ,JointGuarantorContinuedServiceYearsYear__c=15
            ,JointGuarantorContinuedServiceYearsMonth__c=10
            //火災保険の利用有無
            ,IsFireInsurancePlanUse__c=false
        );
        insert testApplication;

        //入居者
        Tenant__c testTenant1 = new Tenant__c(
            Application__c = testApplication.id
            ,LastName__c='申込'
            ,FirstName__c='花子'
            ,LastNameKana__c='モウシコミ'
            ,FirstNameKana__c='ハナコ'
            ,Birthdate__c=Date.newInstance(1990,1,1) 
            ,Age__c=30
            ,Relationship__c='妻'
            ,JobType__c='公務員'
            ,Remarks__c='妻です。'
        );
        Tenant__c testTenant2= new Tenant__c(
            Application__c = testApplication.id
            ,LastName__c='申込'
            ,FirstName__c='小太郎'
            ,LastNameKana__c='モウシコミ'
            ,FirstNameKana__c='コタロウ'
            ,Birthdate__c=Date.newInstance(2015,1,1) 
            ,Age__c=5
            ,Relationship__c='子'
            ,JobType__c='無職'
            ,Remarks__c='子です。'
        ); 
        List<Tenant__c> testTenant = new List<Tenant__c> {
            testTenant1
            ,testTenant2
        };
        insert testTenant;
    }

    // コンストラクタテスト
    @isTest static void newInitializeTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runAs(userRecord){
            Application__c testApplication = [
                SELECT Id
                FROM Application__c
                WHERE FirstName__c = '申込太郎'
            ];
            //パラメータ設定
            PageReference pageRef = Page.TA102004View;
            pageRef.getParameters().put('applicationId', testApplication.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            TA102004Controller testController = new TA102004Controller();
            System.assertNotEquals(null, testController.csvName);
        }
    }

}