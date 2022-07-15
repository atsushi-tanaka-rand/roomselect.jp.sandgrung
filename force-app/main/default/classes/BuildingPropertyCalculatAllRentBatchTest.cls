// 総賃料再計算修正バッチ　テストクラス
@isTest
private class BuildingPropertyCalculatAllRentBatchTest {

    /**
    * テストに使用するレコードを作成する
    */
    @TestSetup static void setting(){
        // 建物
        Building__c testBuilding = new Building__c(
            Name = 'テスト建物'
        );
        
        insert testBuilding;
        
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
            ,testFireInsuranceComp
            ,testGuaranteeComp
        };
        insert testAccount;
        
        // 商品（火災保険）
        Item__c testFireInsuranceItem = new Item__c(
            Account__c = testFireInsuranceComp.Id
            ,RecordTypeId = CommonUtil.getRecordTypeId('Item__c', commonConst.ITEM_RECTYPE_FIRE_INSURANCE)
            ,ItemName__c = 'テスト火災保険商品１'
            ,FireInsuranceMonth__c = 2000
            ,FireInsuranceYear__c = null
            ,PaymentType__c = CommonConst.ITEM_PAYMENTTYPE_YEAR
            ,PaymentYear__c = 1
        );
        // 商品（保証）
        Item__c testGuaranteeItem = new Item__c(
            Account__c = testGuaranteeComp.Id
            ,RecordTypeId = CommonUtil.getRecordTypeId('Item__c', commonConst.ITEM_RECTYPE_GUARANTEE_PLAN)
            ,ItemName__c = 'テスト保証商品１'
            ,AssuranceContent__c = '保証内容１行目\n保証内容２行目'
            ,DirectDebitFee__c = 2000
            ,DirectDebitFeeTaxType__c = CommonConst.PROPERTY_TAXTYPE_TAXABLE
        );
        
        List<Item__c> testItem = new List<Item__c> {
            testFireInsuranceItem
            ,testGuaranteeItem
        };
        insert testItem;
        
        // 取引先保険保証（火災保険）
        InsuranceGuarantee__c testInsuranceGuarantee1 = new InsuranceGuarantee__c(
            Account__c = testFormerSupplier.Id
            ,Item__c = testFireInsuranceItem.Id
            ,RecordTypeId = CommonUtil.getRecordTypeId('InsuranceGuarantee__c', commonConst.INSURANCE_RECTYPE_GUARANTEE_FIREINSURANCE)
        );

        // 取引先保険保証（保証）
        InsuranceGuarantee__c testInsuranceGuarantee2 = new InsuranceGuarantee__c(
            Account__c = testFormerSupplier.Id
            ,Item__c = testGuaranteeItem.Id
            ,RecordTypeId = CommonUtil.getRecordTypeId('InsuranceGuarantee__c', commonConst.INSURANCE_RECTYPE_GUARANTEE_GUARANTEE)
        );
        List<InsuranceGuarantee__c> testInsuranceGuarantee = new List<InsuranceGuarantee__c> {
            testInsuranceGuarantee1
            ,testInsuranceGuarantee2
        };
        insert testInsuranceGuarantee;

        // 管理会社指定商品
        ManagementCompanyItem__c testManagementCompanyItem = new ManagementCompanyItem__c(
            Account__c = testFormerSupplier.Id
            ,ItemName__c = 'テスト管理会社指定商品１'
            ,Amount__c = 3000
            ,PaymentType__c = CommonConst.MANAGEMENTCOMPANYITEM_PAYMENTTYPE_MONTH
            ,TaxType__c = CommonConst.PROPERTY_TAXTYPE_TAXABLE
        );
        insert testManagementCompanyItem;

        // 物件
        Property__c testProperty = new Property__c(
            Name                        = 'テスト物件'                               // 部屋番号
            ,AllRentFee__c              = 0                                         // 総賃料
            ,Score__c                   = 0                                         // 点数
            ,IsMergeCompletedFlag__c    = false                                     // 名寄せ完了フラグ
            ,Building__c                = testBuilding.Id                           // 建物
            ,FormerSupplier__c          = testFormerSupplier.Id                     // 元付業者
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
            ,RenovationContent__c       = 'テストリノベ施工内容'                      // リノベ施工内容
            ,FreeRentTermMonth__c       = 12                                        // フリーレント期間（ヶ月）
            ,FreeRentContent__c         = 'テストフリーレント内容'                    // フリーレント内容
            ,SpecificExcellentRentRemarks__c            = 'テスト特優賃備考'          // 特優賃備考
            ,PropertyRemarksPublic__c   = 'テスト物件備考（公開）'                    // 物件備考（公開）
            ,PropertyRemarksPrivate__c  = 'テスト物件備考（非公開）'                  // 物件備考（非公開）
            ,PropertyComment__c         = 'テスト物件コメント'                       // 物件コメント
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
            ,FireInsurancePlan__c       = testFireInsuranceItem.Id                             // 火災保険タイトル
            ,GuaranteeidCompanyType__c  = CommonConst.PROPERTY_GUARANTEEIDCOMPANYTYPE_POSSIBLE  // 保証会社（利用区分）
            ,Guaranteeid__c             = testGuaranteeItem.Id                                 // 保証タイトル
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
            ,ImportType__c                  = CommonConst.PROPERTY_IMPORTTYPE_REALNETPRO    // 取込区分
            ,MaintenancePropertyCode__c     = 'qwertyuiop'                          // メンテナンス物件コード
            ,ManualMaintenanceDate__c       = Date.newInstance(2020, 2, 17)         // 手動最終メンテナンス日
            ,AutoMaintenanceDate__c         = Date.newInstance(2020, 2, 15)         // 自動最終メンテナンス日
        );
        insert testProperty;

        // 物件管理会社指定商品
        PropertyManageCompayItem__c testPropertyManageCompayItem = new PropertyManageCompayItem__c(
            Property__c = testProperty.Id
            ,Account__c = testFormerSupplier.Id
            ,Item__c = testManagementCompanyItem.Id
        );
        insert testPropertyManageCompayItem;
    }

    // バッチテスト
    @isTest static void successTest(){
        //バッチ実行
        BuildingPropertyCalculatAllRentBatch b = new BuildingPropertyCalculatAllRentBatch();
        Database.executeBatch(b, 100);
    }
}