/**
 * 申込登録（ipad）のテスト
 */

@isTest 
private class GA103001Test{
    public static final String USER_NAME = 'GA103001@horaguchi.com'; 
	//テストに使用するレコードを作成する
	@testSetup static void Setting(){
        // システム設定登録
        SystemConfig__c sysCon = new SystemConfig__c();
        sysCon.TaxRate__c = 10;
		insert sysCon;

        //★対応
        Correspond__c correspondRecord = new Correspond__c(District__c = '港区');
        insert correspondRecord;

        //店舗レコード
        Shop__c shopRecord = new shop__c(Name = 'テス店舗',
                                         PortalSitePostingDistrict__c = '港区');
        insert shopRecord;

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
            OrganizationName__c = 'テス店舗',
            HierarchyCode__c = '20',
            HierarchyOrder__c = 1,
            UpperOrganizationHierarchy__c = orgRecord1.Id,
            ExpandedOrganizationCode__c = '0000_0001_0002',
            Shop__c = shopRecord.Id
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
                ProfileId = profiles.get(0).Id);
        }

        //店舗異動レコード
        //User userRecord =  [SELECT Id FROM User WHERE UserName = :UserInfo.getUserId()];
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        ShopTransfer__c ShopTransferRecord = new ShopTransfer__c(OrgzanizationHierarchy__c = orgRecord2.id,
                                                                 Staff__c = userRecord.id,
                                                                 StartDate__c = Date.newInstance(2000, 12, 1),
                                                                 EndDate__c = Date.newInstance(2999, 12, 1)); 
		
		// ▼ 2022.02.15 No0727 トリガー動作による負荷の軽減
		sysCon.IsSkipTrigger__c = true;
		update sysCon; 
        insert ShopTransferRecord;
		sysCon.IsSkipTrigger__c = false;
		update sysCon; 
		// ▲ 2022.02.15 No0727 トリガー動作による負荷の軽減
        
        //★新規登録用---------------------------------------------------------------------------------
        //建物
        Building__c newBuildingRecord = new Building__c( Name = '新規テスト建物'
        ,State__c = '愛知県'
        ,City__c = '名古屋市テスト区'
        ,Street__c = '5-5');
        insert newBuildingRecord;
        //取引先
        Account newAccountRecord1 = new Account(
            Name = '取引先 次郎',
            LastName__c = '取引先',
            FirstName__c = '次郎',
            RecordTypeId = commonUtil.getRecordTypeId('Account','CustomerRecordType'),
            NameKana__c = 'トリヒキサキ ジロウ',
            ContractType__c = '個人契約',
            Birthdate__c = Date.newInstance(1995,1,1),
            PostalCode__c = '111-1111',
            State__c = '愛知県',
            City__c = '名古屋市テスト町',
            Street__c = '4-1-34',
            Phone = '1234-111-1234',
            JobType__c = '会社員'
        );
        Account newAccountRecord2 = new Account(Name = '申込テスト火災株式会社',RecordTypeId = commonUtil.getRecordTypeId('Account','FireInsuranceRecordType')
        );
        Account newAccountRecord3 = new Account(Name = 'テスト新規保証株式会社',RecordTypeId = commonUtil.getRecordTypeId('Account','GuaranteeRecordType')
        );
        List<Account> newAccountList = new List<Account> {newAccountRecord1,newAccountRecord2,newAccountRecord3};
        insert newAccountList;
        //商品
        Item__c newItemRecord1 = new Item__c(
        Account__c = newAccountRecord2.id
            ,RecordTypeId = commonUtil.getRecordTypeId('Item__c','FireInsuranceRecordType')
            ,ItemName__c='テスト新規火災保険'
            ,FireInsuranceMonth__c=2200
            ,FireInsuranceYear__c=22000
        );
        Item__c newItemRecord2 = new Item__c(
            Account__c = newAccountRecord3.id
            ,RecordTypeId = commonUtil.getRecordTypeId('Item__c','GuaranteePlanRecordType')
            ,ItemName__c='テスト新規保証プラン'
            );
        Item__c newItemRecord3 = new Item__c(
            Account__c = newAccountRecord3.id
            ,RecordTypeId = commonUtil.getRecordTypeId('Item__c','GuaranteePlanRecordType')
            ,ItemName__c='テスト2新規保証プラン'
            );
        List<Item__c> newItemList = new List<Item__c> {newItemRecord1,newItemRecord2,newItemRecord3};
        insert newItemList;
        //物件
        Property__c newPropertyRecord = new Property__c(
            Name = '505',
            Building__c = newBuildingRecord.id,
            RentFee__c = 55000,
            WortFee__c = 1500,
            SecurityDepositYen__c = 15000,
            CancellationActualFeeYen__c = 12000,
            ManagementFee__c = 4500,
            CATVFee__c = 2500,
            DepositYen__c = 15000,
            RenewalFeeYen__c = 5500,
            TownshipFee__c = 3300,
            GarbageDisposalFee__c = 2200,
            KeyMoneyYen__c = 3300,
            TownshipInitialFee__c = 2200,
            BicycleParkingFee__c = 3300,
            CleaningFeeYen__c = 2200,
            KeyExchangeFee__c = 5500,
            CancellationActualFeeUnit__c = '実費',
            ParkingFee__c = 1200,
            ParkingDepositYen__c = 2200,
            ParkingCompoundingFeeYen__c = 3200,
            BikeParkingSmallFee__c = 2200,
            BikeParkingMediumFee__c = 3200,
            BikeParkinLargeFee__c = 4200,
            ADFeeYen__c = 2000,
            AllRentFee__c = 2000,
            FireInsurancePlan__c = newItemRecord1.id,
            FormerSupplier__c = newAccountRecord3.id
        );
        //▼問合せNo0569で追加
        // 物件管理会社指定商品有
        Property__c newPropertyRecord2 = new Property__c(
            Name = '509',
            Building__c = newBuildingRecord.id,
            RentFee__c = 55000,
            WortFee__c = 1500,
            SecurityDepositYen__c = 15000,
            CancellationActualFeeYen__c = 12000,
            ManagementFee__c = 4500,
            CATVFee__c = 2500,
            DepositYen__c = 15000,
            RenewalFeeYen__c = 5500,
            TownshipFee__c = 3300,
            GarbageDisposalFee__c = 2200,
            KeyMoneyYen__c = 3300,
            TownshipInitialFee__c = 2200,
            BicycleParkingFee__c = 3300,
            CleaningFeeYen__c = 2200,
            KeyExchangeFee__c = 5500,
            CancellationActualFeeUnit__c = '実費',
            ParkingFee__c = 1200,
            ParkingDepositYen__c = 2200,
            ParkingCompoundingFeeYen__c = 3200,
            BikeParkingSmallFee__c = 2200,
            BikeParkingMediumFee__c = 3200,
            BikeParkinLargeFee__c = 4200,
            ADFeeYen__c = 2000,
            AllRentFee__c = 2000,
            FireInsurancePlan__c = newItemRecord1.id,
            FormerSupplier__c = newAccountRecord3.id
        );
        // 物件管理会社指定商品無（管理会社指定商品無）
        Property__c newPropertyRecord3 = new Property__c(
            Name = '510',
            Building__c = newBuildingRecord.id,
            RentFee__c = 55000,
            WortFee__c = 1500,
            SecurityDepositYen__c = 15000,
            CancellationActualFeeYen__c = 12000,
            ManagementFee__c = 4500,
            CATVFee__c = 2500,
            DepositYen__c = 15000,
            RenewalFeeYen__c = 5500,
            TownshipFee__c = 3300,
            GarbageDisposalFee__c = 2200,
            KeyMoneyYen__c = 3300,
            TownshipInitialFee__c = 2200,
            BicycleParkingFee__c = 3300,
            CleaningFeeYen__c = 2200,
            KeyExchangeFee__c = 5500,
            CancellationActualFeeUnit__c = '実費',
            ParkingFee__c = 1200,
            ParkingDepositYen__c = 2200,
            ParkingCompoundingFeeYen__c = 3200,
            BikeParkingSmallFee__c = 2200,
            BikeParkingMediumFee__c = 3200,
            BikeParkinLargeFee__c = 4200,
            ADFeeYen__c = 2000,
            AllRentFee__c = 2000,
            FireInsurancePlan__c = newItemRecord1.id
        );
        List<Property__c> newPropertyRecordList = new List<Property__c>{
            newPropertyRecord,
            newPropertyRecord2,
            newPropertyRecord3
        };
        insert newPropertyRecordList;

        //商品明細
        ItemDetail__c newItemDetailRecord1 = new ItemDetail__c(
            Item__c = newItemRecord2.id,
            PlanDetail__c = '新規のプラン詳細です。',
            FirstFeeDepositRate__c = 20,
            FirstFeeDepositYen__c = 20000,
            DepositRate__c = 30,
            DepositYen__c = 30000,
            IsRentFeeType__c = false,
            DepositRemarks__c = '新規備考です。'
        );
        ItemDetail__c newItemDetailRecord2 = new ItemDetail__c(
            Item__c = newItemRecord3.id,
            PlanDetail__c = '新規のプラン詳細2です。',
            FirstFeeDepositRate__c = 50,
            FirstFeeDepositYen__c = 50000,
            DepositRate__c = 60,
            DepositYen__c = 60000,
            IsRentFeeType__c = true,
            DepositRemarks__c = '新規備考2です。'
        );
        List<ItemDetail__c> newItemDetailList = new List<ItemDetail__c> {newItemDetailRecord1,newItemDetailRecord2};
        insert newItemDetailList;
        //管理会社指定商品
        ManagementCompanyItem__c newaManagementCompanyItemRecord1 = new ManagementCompanyItem__c(
            Account__c = newAccountRecord3.id,
            ItemName__c = 'テスト新規指定商品',
            Amount__c = 5500,
            PaymentType__c = '年額',
            TaxType__c = '非課税'
        );
        ManagementCompanyItem__c newaManagementCompanyItemRecord2 = new ManagementCompanyItem__c(
            Account__c = newAccountRecord3.id,
            ItemName__c = 'テスト2新規指定商品',
            Amount__c = 6200,
            PaymentType__c = '初回',
            TaxType__c = '課税'
        );
        //▼問合せNo0569で追加
        ManagementCompanyItem__c newaManagementCompanyItemRecord3 = new ManagementCompanyItem__c(
            Account__c = newAccountRecord3.id,
            ItemName__c = 'テスト3新規指定商品',
            Amount__c = 6201,
            PaymentType__c = '初回',
            TaxType__c = '課税'
        );
        //▲問合せNo0569で追加
        List<ManagementCompanyItem__c> newaManagementCompanyItemList = new List<ManagementCompanyItem__c> {newaManagementCompanyItemRecord1,newaManagementCompanyItemRecord2,newaManagementCompanyItemRecord3};
        insert newaManagementCompanyItemList;

        //▼問合せNo0569で追加
        // 物件管理会社指定商品
        PropertyManageCompayItem__c propertyManageCompayItem = new PropertyManageCompayItem__c(
            Property__c = newPropertyRecord.Id,
            Account__c = newAccountRecord3.id,
            Item__c = newaManagementCompanyItemRecord1.Id
        );
        PropertyManageCompayItem__c propertyManageCompayItem3 = new PropertyManageCompayItem__c(
            Property__c = newPropertyRecord.Id,
            Account__c = newAccountRecord3.id,
            Item__c = newaManagementCompanyItemRecord3.Id
        );
        List<PropertyManageCompayItem__c> PropertyManageCompayItemList = new List<PropertyManageCompayItem__c>{
            propertyManageCompayItem,
            propertyManageCompayItem3
        };
        insert PropertyManageCompayItemList;
        //▲問合せNo0569で追加

        //★更新用-----------------------------------------------------------------------------

        //申込で取得する用の建物
        Building__c appBuildingRecord = new Building__c( Name = 'テスト建物1'
                                                         ,State__c = '愛知県'
                                                         ,City__c = '名古屋市中区'
                                                         ,Street__c = '1-1');
        insert appBuildingRecord;

        //申込で取得する用の物件
        Property__c appPropertyRecord = new Property__c(Name = '101',Building__c = appBuildingRecord.id);
        insert appPropertyRecord;

        //申込で取得するようの取引先
        Account appAccountRecord1 = new Account(Name = '申込 テスト太郎',RecordTypeId = commonUtil.getRecordTypeId('Account','CustomerRecordType')
        );
        Account appAccountRecord2 = new Account(Name = '申込テスト火災株式会社',RecordTypeId = commonUtil.getRecordTypeId('Account','FireInsuranceRecordType')
        );
        List<Account> appAccountList = new List<Account> {appAccountRecord1,appAccountRecord2};
        insert appAccountList;

		// ▼ 2022.03.01 No0739 同じ申込を2件以上登録できないように対応から申込があるかを確認する
		//申込で取得するようの対応
		Correspond__c appCorrespondRecord = new Correspond__c(District__c = '港区',AccountId__c = appAccountRecord1.id,Status__c = commonconst.CORRESPOND_STATUS_UNEARNED);
		insert appCorrespondRecord;
		// ▲ 2022.03.01 No0739 同じ申込を2件以上登録できないように対応から申込があるかを確認する

        //申込で取得する商品
        Item__c appItemRecord = new Item__c(
        Account__c = appAccountRecord2.id
        ,RecordTypeId = commonUtil.getRecordTypeId('Item__c','FireInsuranceRecordType')
        ,ItemName__c='申込テスト火災保険'
        ,FireInsuranceMonth__c=2000
        ,FireInsuranceYear__c=20000
        );
        insert appItemRecord;

        //申込
        Application__c testApplicationRecord = new Application__c(
            Account__c = appAccountRecord1.id
            ,Property__c = appPropertyRecord.id
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
            ,LastName__c='申込'
            ,FirstName__c='テスト太郎'
            ,LastNameKana__c='モウシコミ'
            ,FirstNameKana__c='テストタロウ'
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
        insert testApplicationRecord;

        //入居者
        Tenant__c appTenantRecord1 = new Tenant__c(
             Application__c = testApplicationRecord.id
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
        Tenant__c appTenantRecord2= new Tenant__c(
             Application__c = testApplicationRecord.id            
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
        List<Tenant__c> appTenantList = new List<Tenant__c> {appTenantRecord1,appTenantRecord2};
        insert appTenantList;

        //申込商品明細
        ApplicantItemDetail__c appItemDetaillRecord1 = new ApplicantItemDetail__c(
            ProvisionalQuote__c=testApplicationRecord.id
            ,GuaranteeidCompanyName__c='申込テスト保証株式会社'
            ,GuaranteeidItemName__c='申込テスト保証プラン'
            ,PlanDetail__c='申込プラン詳細です。'
            ,FirstFeeDepositRate__c=0.1
            ,FirstFeeDepositYen__c=10000
            ,DepositRate__c=0.2
            ,DepositYen__c=20000
            ,IsRentFeeType__c=true
            ,DepositRemarks__c = '備考です。'
            ,IsPlanUse__c=true
        ); 
        ApplicantItemDetail__c appItemDetaillRecord2 = new ApplicantItemDetail__c(
            ProvisionalQuote__c=testApplicationRecord.id            
            ,GuaranteeidCompanyName__c='申込テスト2保証株式会社'
            ,GuaranteeidItemName__c='申込テス2ト保証プラン'
            ,PlanDetail__c = 'プラン詳細2です。'
            ,FirstFeeDepositRate__c=0.3
            ,FirstFeeDepositYen__c=30000
            ,DepositRate__c=0.4
            ,DepositYen__c=40000
            ,IsRentFeeType__c=false
            ,DepositRemarks__c='備考2です。'
            ,IsPlanUse__c=false
        ); 
        List<ApplicantItemDetail__c> appItemDetailList = new List<ApplicantItemDetail__c> {appItemDetaillRecord1,appItemDetaillRecord2};
        insert appItemDetailList;

        //申込指定商品
        ApplicantQuoteManageCompayItem__c appQuoteManageRecord1 = new ApplicantQuoteManageCompayItem__c(
            ProvisionalQuote__c=testApplicationRecord.id                    
            ,ItemName__c='申込テスト指定商品'
            ,AmountTax__c=5000
            ,PaymentType__c='初回'
            ,TaxType__c='課税'
            ,IsPlanUse__c=false
        );    
        ApplicantQuoteManageCompayItem__c appQuoteManageRecord2 = new ApplicantQuoteManageCompayItem__c(
            ProvisionalQuote__c=testApplicationRecord.id                    
            ,ItemName__c='申込テスト2指定商品'
            ,AmountTax__c=6000
            ,PaymentType__c='月額'
            ,TaxType__c= '非課税'
            ,IsPlanUse__c=true         
        );    
        List<ApplicantQuoteManageCompayItem__c> appQuoteManageList = new List<ApplicantQuoteManageCompayItem__c> {appQuoteManageRecord1,appQuoteManageRecord2};
        insert appQuoteManageList;
        
    }
//----------------------------------------------------------------------------------------------------
    //◇◇◇初期表示テスト(新規)
    @isTest static void newInitializeTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runas(userRecord){
            Account testAccountRecord = [SELECT Id,Name
                        FROM Account
                        WHERE Name = '取引先 次郎'];
            Property__c testPropertyRecord = [SELECT Id,Name
                        FROM Property__c
                        WHERE Name = '505'];                                           
            Correspond__c correspondRecord =[SELECT Id 
                    FROM Correspond__c 
                    WHERE District__c = '港区' LIMIT 1];
            //パラメータ設定
            PageReference pageRef = Page.GA103001View;
            pageRef.getParameters().put('accountId',testAccountRecord.Id );
            pageRef.getParameters().put('propertyId',testPropertyRecord.Id );
            pageRef.getParameters().put('correspondId',correspondRecord.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA103001Controller testController = new GA103001Controller();
            system.assertEquals(true, testController.isNew);
            system.assertEquals('取引先', testController.screenTargetRecord.lastName );
            system.assertEquals(CommonUtil.getToday(), testController.screenTargetRecord.applicationDate );
        }
    }
    //◇◇◇初期表示テスト(更新)
    @isTest static void updateInitializeTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runas(userRecord){
            Application__c testApplicationRecord = [SELECT Id,LastName__c
                FROM Application__c
                WHERE LastName__c = '申込'];
            Correspond__c correspondRecord =[SELECT Id 
                FROM Correspond__c 
                WHERE District__c = '港区' LIMIT 1];

            //パラメータ設定
            PageReference pageRef = Page.GA103001View;
            pageRef.getParameters().put('applicationId',testApplicationRecord.Id );
            pageRef.getParameters().put('correspondId',correspondRecord.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA103001Controller testController = new GA103001Controller();
            system.assertEquals(testApplicationRecord.LastName__c, testController.screenTargetRecord.lastName );
        }
    }
    //◇◇◇初期表示テスト(取引先パラメータ異常)
    @isTest static void initializeAccountErrorTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runas(userRecord){
            Account testAccountRecord = [SELECT Id,Name
                        FROM Account
                        WHERE Name = '取引先 次郎'];
            Property__c testPropertyRecord = [SELECT Id,Name
                        FROM Property__c
                        WHERE Name = '505'];                                           
            Correspond__c correspondRecord =[SELECT Id 
                    FROM Correspond__c 
                    WHERE District__c = '港区' LIMIT 1];
            //パラメータ設定
            PageReference pageRef = Page.GA103001View;
            pageRef.getParameters().put('accountId',testAccountRecord.Id );
            pageRef.getParameters().put('correspondId',correspondRecord.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA103001Controller testController = new GA103001Controller();
            System.assertEquals(true, testController.isOpenError);
        }
    }

    //◇◇◇初期表示テスト(申込パラメータ異常)
    @isTest static void initializeApplicationErorTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runas(userRecord){
            Application__c testApplicationRecord = [SELECT Id,LastName__c
                FROM Application__c
                WHERE LastName__c = '申込'];                                     
            Correspond__c correspondRecord =[SELECT Id 
                    FROM Correspond__c 
                    WHERE District__c = '港区' LIMIT 1];
            //パラメータ設定
            PageReference pageRef = Page.GA103001View;
            pageRef.getParameters().put('correspondId',correspondRecord.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA103001Controller testController = new GA103001Controller();
            System.assertEquals(true, testController.isOpenError);
        }
    }

    //◇◇◇初期表示テスト(対応パラメータ異常)
    @isTest static void initializeCorrespondTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runas(userRecord){
            Application__c testApplicationRecord = [SELECT Id,LastName__c
                FROM Application__c
                WHERE LastName__c = '申込'];                                          
            Correspond__c correspondRecord =[SELECT Id 
                    FROM Correspond__c 
                    WHERE District__c = '港区' LIMIT 1];
            //パラメータ設定
            PageReference pageRef = Page.GA103001View;
            pageRef.getParameters().put('correspondId',correspondRecord.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA103001Controller testController = new GA103001Controller();
            System.assertEquals(true, testController.isOpenError);
        }
    }

    //◇◇◇初期表示テスト(物件パラメータ異常)
    @isTest static void initializePropertyErrorTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runas(userRecord){
            Account testApplicationRecord = [SELECT Id,Name
                        FROM Account
                        WHERE Name = '取引先 次郎'];
            Property__c testPropertyRecord = [SELECT Id,Name
                        FROM Property__c
                        WHERE Name = '505'];                                           
            Correspond__c correspondRecord =[SELECT Id 
                    FROM Correspond__c 
                    WHERE District__c = '港区' LIMIT 1];
            //パラメータ設定
            PageReference pageRef = Page.GA103001View;
            pageRef.getParameters().put('applicationId',testApplicationRecord.Id );
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA103001Controller testController = new GA103001Controller();
            System.assertEquals(true, testController.isOpenError);
        }
    }

    //◇◇◇年齢再計算
    @isTest static void ageRecalculateTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runas(userRecord){
            Application__c testApplicationRecord = [SELECT Id,LastName__c
                FROM Application__c
                WHERE LastName__c = '申込'];
            Correspond__c correspondRecord =[SELECT Id 
                FROM Correspond__c 
                WHERE District__c = '港区' LIMIT 1];
            //パラメータ設定
            PageReference pageRef = Page.GA103001View;
            pageRef.getParameters().put('applicationId',testApplicationRecord.Id );
            pageRef.getParameters().put('correspondId',correspondRecord.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA103001Controller testController = new GA103001Controller();
            //申込日変更
            testController.screenTargetRecord.birthdate = Date.newInstance(2000, 1, 1);
            //年齢再計算
            testController.ageRecalculate();
            System.assertEquals(20, testController.screenTargetRecord.age);

        }
    }
    //◇◇◇入居者モーダル（新規）
    @isTest static void newOpenTenantTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runas(userRecord){
            Application__c testApplicationRecord = [SELECT Id,LastName__c
                FROM Application__c
                WHERE LastName__c = '申込'];
            Correspond__c correspondRecord =[SELECT Id 
                FROM Correspond__c 
                WHERE District__c = '港区' LIMIT 1];
            //パラメータ設定
            PageReference pageRef = Page.GA103001View;
            pageRef.getParameters().put('applicationId',testApplicationRecord.Id );
            pageRef.getParameters().put('correspondId',correspondRecord.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA103001Controller testController = new GA103001Controller();

            //モーダル起動呼び出し
            testController.openModalCreateTenant();
            
            //子(モーダル)起動
            GA103001Modal1Controller testModalController = new GA103001Modal1Controller();

            //親のパラメータを子に渡す(親で設定しているモーダル用のパラメータをそのまま格納)
            testModalController.parameter = testController.GA103001Modal1Parameter;

            //子のinitactionを起動
            testModalController.initAction();

            //画面の名前項目が空白であることを確認
            System.assert(String.isEmpty((testModalController.modalParameter.firstName)), 'error:画面の姓項目が空白でではない');
            System.assert(String.isEmpty((testModalController.modalParameter.lastName)), 'error:画面の名項目が空白ではない');
            System.assert(String.isEmpty((testModalController.modalParameter.firstNameKana)), 'error:姓（カナ）の名前項目が空白ではない');
            System.assert(String.isEmpty((testModalController.modalParameter.lastNameKana)), 'error:画面の名（カナ）項目が空白ではない');
            System.assert((testModalController.modalParameter.birthdate) == null, 'error:画面の生年月日項目が空白ではない');
            System.assert(String.isEmpty((commonUtil.decimalToString(testModalController.modalParameter.age))), 'error:画面の年齢が空白ではない');
            System.assert(String.isEmpty((testModalController.modalParameter.relationship)), 'error:画面の続柄項目が空白でではない');
            System.assert(String.isEmpty((testModalController.modalParameter.jobType)), 'error:画面の職種項目が空白ではない');
            System.assert(String.isEmpty((testModalController.modalParameter.remarks)), 'error:画面の備考項目が空白ではない');
        }
    }
       //◇◇◇入居者モーダル（新規）
    @isTest static void newCloseTenantTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runas(userRecord){
            Account testAccountRecord = [SELECT Id,Name
                        FROM Account
                        WHERE Name = '取引先 次郎'];
            Property__c testPropertyRecord = [SELECT Id,Name
                        FROM Property__c
                        WHERE Name = '505'];            
            Correspond__c correspondRecord =[SELECT Id 
                FROM Correspond__c 
                WHERE District__c = '港区' LIMIT 1];
            //パラメータ設定
            PageReference pageRef = Page.GA103001View;
            pageRef.getParameters().put('accountId',testAccountRecord.Id );
            pageRef.getParameters().put('propertyId',testPropertyRecord.Id );
            pageRef.getParameters().put('correspondId',correspondRecord.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA103001Controller testController = new GA103001Controller();

            //モーダル起動呼び出し
            testController.openModalCreateTenant();
            
            //子(モーダル)起動
            GA103001Modal1Controller testModalController = new GA103001Modal1Controller();

            //親のパラメータを子に渡す(親で設定しているモーダル用のパラメータをそのまま格納)
            testModalController.parameter = testController.GA103001Modal1Parameter;

            //子のinitactionを起動
            testModalController.initAction();

            testModalController.modalParameter.firstName = '入居者';
            testModalController.modalParameter.lastName = 'テスト';
            testModalController.modalParameter.birthdate = Date.newInstance(2010, 1, 1);
            //画面閉じる
            testModalController.closeTenantModal();
            testController.closeTenantModal();
            //入居者リストにレコードが入っていることを確認（新規で親画面を開いているので作成前は0）
            System.assertEquals(true,testController.tenantList.size() != 0,'error:入居者リストにレコードが入っている');
        }
    }
    //◇◇◇入居者モーダル（更新）
    @isTest static void updateOpenModalTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runas(userRecord){
            Application__c testApplicationRecord = [SELECT Id,LastName__c
                FROM Application__c
                WHERE LastName__c = '申込'];
            Correspond__c correspondRecord =[SELECT Id 
                FROM Correspond__c 
                WHERE District__c = '港区' LIMIT 1];
            //パラメータ設定
            PageReference pageRef = Page.GA103001View;
            pageRef.getParameters().put('applicationId',testApplicationRecord.Id );
            pageRef.getParameters().put('correspondId',correspondRecord.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA103001Controller testController = new GA103001Controller();

            //編集モーダル起動
            testController.selectedIndex = 0;    //VFで設定される変数なので直接設定する
            testController.openModalUpdateTenant();

            //子(モーダル)起動
            GA103001Modal1Controller testModalController = new GA103001Modal1Controller();

            //親のパラメータを子に渡す(親で設定しているモーダル用のパラメータをそのまま格納)
            testModalController.parameter = testController.GA103001Modal1Parameter;

            //子のinitactionを起動
            testModalController.initAction();

            //画面の名前項目がDBと一致することを確認
            System.assertEquals(testModalController.modalParameter.firstName, '花子', 'error:画面の名前項目が違う');

        }
    }

    //◇◇◇入居者モーダル登録・年齢再計算
    @isTest static void recalculateTenantTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runas(userRecord){
            Application__c testApplicationRecord = [SELECT Id,LastName__c
                FROM Application__c
                WHERE LastName__c = '申込'];
            Correspond__c correspondRecord =[SELECT Id 
                FROM Correspond__c 
                WHERE District__c = '港区' LIMIT 1];
            //パラメータ設定
            PageReference pageRef = Page.GA103001View;
            pageRef.getParameters().put('applicationId',testApplicationRecord.Id );
            pageRef.getParameters().put('correspondId',correspondRecord.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA103001Controller testController = new GA103001Controller();

            //編集モーダル起動
            testController.selectedIndex = 0;    //VFで設定される変数なので直接設定する
            testController.openModalUpdateTenant();

            //子(モーダル)起動
            GA103001Modal1Controller testModalController = new GA103001Modal1Controller();

            //親のパラメータを子に渡す(親で設定しているモーダル用のパラメータをそのまま格納)
            testModalController.parameter = testController.GA103001Modal1Parameter;

            //子のinitactionを起動
            testModalController.initAction();

            testModalController.modalParameter.birthdate = Date.newInstance(2010, 1, 1);
            testModalController.ageRecalculateTenant();
            //画面閉じる
            testModalController.closeTenantModal();
            testController.closeTenantModal();
            //画面の名前項目がDBと一致することを確認
            System.assertEquals(testController.tenantList[0].Age__c, 10, 'error:年齢が変更されていない');
            System.assertEquals(testController.tenantList[0].LastName__c, '申込', 'error:年齢以外が一致している');
            System.assertEquals(testController.tenantList[0].FirstName__c, '花子', 'error:年齢以外が一致している');

        }
    }

    //◇◇◇入居者モーダル登録（異常）
    @isTest static void saveErrorTenantTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runas(userRecord){
            Application__c testApplicationRecord = [SELECT Id,LastName__c
                FROM Application__c
                WHERE LastName__c = '申込'];
            Correspond__c correspondRecord =[SELECT Id 
                FROM Correspond__c 
                WHERE District__c = '港区' LIMIT 1];
            //パラメータ設定
            PageReference pageRef = Page.GA103001View;
            pageRef.getParameters().put('applicationId',testApplicationRecord.Id );
            pageRef.getParameters().put('correspondId',correspondRecord.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA103001Controller testController = new GA103001Controller();

            //モーダル起動呼び出し
            testController.openModalCreateTenant();
            
            //子(モーダル)起動
            GA103001Modal1Controller testModalController = new GA103001Modal1Controller();

            //親のパラメータを子に渡す(親で設定しているモーダル用のパラメータをそのまま格納)
            testModalController.parameter = testController.GA103001Modal1Parameter;

            //子のinitactionを起動
            testModalController.initAction();

            //画面閉じる
            testModalController.closeTenantModal();
            testController.closeTenantModal();
            
            List<ApexPages.Message> messages = ApexPages.getMessages();
            System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, '姓,名,姓（カナ）,名（カナ）,生年月日')));
        }
    }
    //◇◇◇入居者モーダル削除
    @isTest static void deleteTenantTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runas(userRecord){
            Application__c testApplicationRecord = [SELECT Id,LastName__c
                FROM Application__c
                WHERE LastName__c = '申込'];
            Correspond__c correspondRecord =[SELECT Id 
                FROM Correspond__c 
                WHERE District__c = '港区' LIMIT 1];
            //パラメータ設定
            PageReference pageRef = Page.GA103001View;
            pageRef.getParameters().put('applicationId',testApplicationRecord.Id );
            pageRef.getParameters().put('correspondId',correspondRecord.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA103001Controller testController = new GA103001Controller();

            //入居者レコード削除
            testController.selectedIndex = 0;    //VFで設定される変数なので直接設定する
            testController.TenantRecordDelete();

            //入居者リストにレコードが入っていることを確認（新規で親画面を開いているので作成前は0）
            System.assertEquals(true,testController.tenantList.size() == 1,'error:入居者レコードが削除されていない');
        }
    }
    //◇◇◇確認画面
    @isTest static void confirmTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runas(userRecord){
            Application__c testApplicationRecord = [SELECT Id,LastName__c
                FROM Application__c
                WHERE LastName__c = '申込'];
            Correspond__c correspondRecord =[SELECT Id 
                FROM Correspond__c 
                WHERE District__c = '港区' LIMIT 1];
            //パラメータ設定
            PageReference pageRef = Page.GA103001View;
            pageRef.getParameters().put('applicationId',testApplicationRecord.Id );
            pageRef.getParameters().put('correspondId',correspondRecord.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA103001Controller testController = new GA103001Controller();

            //確認ボタン押下
            testController.confirm();


            //入居者リストにレコードが入っていることを確認（新規で親画面を開いているので作成前は0）
            System.assertEquals(true, testController.isConfirm);
            System.assertEquals(false, testController.privacy);
            System.assertEquals(false, testController.isUpsert);
        }
    }

    //◇◇◇確認画面(異常)
    @isTest static void confirmErrorTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runas(userRecord){
            Account testAccountRecord = [SELECT Id,Name
                        FROM Account
                        WHERE Name = '取引先 次郎'];
            Property__c testPropertyRecord = [SELECT Id,Name
                        FROM Property__c
                        WHERE Name = '505'];            
            Correspond__c correspondRecord =[SELECT Id 
                FROM Correspond__c 
                WHERE District__c = '港区' LIMIT 1];
            //パラメータ設定
            PageReference pageRef = Page.GA103001View;
            pageRef.getParameters().put('propertyId',testPropertyRecord.Id );
            pageRef.getParameters().put('AccountId',testAccountRecord.Id );
            pageRef.getParameters().put('correspondId',correspondRecord.Id);
            pageRef.getParameters().put('comeFrom','App');//アプリで開いている場合のみ必須チェックされる
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA103001Controller testController = new GA103001Controller();

            //追加必須入力
            testController.screenTargetRecord.tenantDesiredDate = CommonUtil.getToday();//入居希望日
            testController.screenTargetRecord.lastNameKana = '契約者情報姓(カナ)';//契約者情報 姓(カナ)
            testController.screenTargetRecord.firstNameKana = '契約者情報名(カナ)';//契約者情報 名(カナ)
            testController.screenTargetRecord.childrenCount = '1';//契約者情報 子供
            testController.screenTargetRecord.residenceType = '自己所有';//契約者情報 子供
            testController.screenTargetRecord.residenceTermYear = '1';//契約者情報 住居期間(年/月)
            testController.screenTargetRecord.residenceTermMonth = '1';//契約者情報 住居期間(年/月)

            testController.screenTargetRecord.affiliation = '株式会社テスト勤務';//勤務先情報 勤務先
            testController.screenTargetRecord.industries = '製造業';//勤務先情報 業種
            testController.screenTargetRecord.affiliationPostalCode = '112-1122';//勤務先情報 郵便番号(現住所)
            testController.screenTargetRecord.affiliationState = '愛知県';//勤務先情報 都道府県
            testController.screenTargetRecord.affiliationCity = '北名古屋市テスト区';//勤務先情報 所在地１
            testController.screenTargetRecord.affiliationStreet = '1-3-99';//勤務先情報 所在地２
            testController.screenTargetRecord.affiliationPhone = '1122-111-2222';//勤務先情報 電話番号
            testController.screenTargetRecord.jobType = '会社員';//勤務先情報 職種
            testController.screenTargetRecord.annualIncome = '5000000';//勤務先情報 年収
            testController.screenTargetRecord.continuedServiceYearsYear = '5';//勤務先情報 勤続年数(年/月)
            testController.screenTargetRecord.continuedServiceYearsMonth = '2';//勤務先情報 勤続年数(年/月)

            testController.screenTargetRecord.jointGuarantorLastName = '申込';//連帯保証人または緊急連絡先 姓
            testController.screenTargetRecord.jointGuarantorFirstName = 'テストの助';//連帯保証人または緊急連絡先 名
            testController.screenTargetRecord.jointGuarantorLastNameKana = 'モウシコミ';//連帯保証人または緊急連絡先 姓(カナ)
            testController.screenTargetRecord.jointGuarantorFirstNameKana = 'テストノスケ';//連帯保証人または緊急連絡先 名(カナ)
            testController.screenTargetRecord.jointGuarantorPostalCode ='222-2222';//連帯保証人または緊急連絡先 郵便番号(現住所)
            testController.screenTargetRecord.jointGuarantorState ='愛知県';//連帯保証人または緊急連絡先 都道府県
            testController.screenTargetRecord.jointGuarantorCity ='豊田市テス町';//連帯保証人または緊急連絡先 住所1
            testController.screenTargetRecord.jointGuarantorStreet ='11-111';//連帯保証人または緊急連絡先 住所2
            testController.screenTargetRecord.jointGuarantorBirthdate = Date.newInstance(1980,1,1) ;//連帯保証人または緊急連絡先 生年月日
            testController.screenTargetRecord.applicantRelationship = '兄' ;//連帯保証人または緊急連絡先 お申込者との関係
            testController.screenTargetRecord.jointGuarantorResidenceType = '自己所有' ;//連帯保証人または緊急連絡先 住居種別

            testController.screenTargetRecord.jointGuarantorAffiliation = '連帯テスト株式会社';//連帯保証人勤務先 会社名
            testController.screenTargetRecord.jointGuarantorIndustries = '建設業';//連帯保証人勤務先 業種
            testController.screenTargetRecord.jointGuarantorAffiliationPostalCode = '343-4443';//連帯保証人勤務先 郵便番号(現住所)
            testController.screenTargetRecord.jointGuarantorAffiliationState = '静岡県';//連帯保証人勤務先 都道府県
            testController.screenTargetRecord.jointGuarantorAffiliationCity = '静岡市テスト町';//連帯保証人勤務先 所在地1
            testController.screenTargetRecord.jointGuarantorAffiliationStreet = '4-44';//連帯保証人勤務先 所在地2
            testController.screenTargetRecord.jointGuarantorAffiliationPhone = '234-444-4444';//連帯保証人勤務先 電話番号
            testController.screenTargetRecord.jointGuarantorJobType = '会社員';//連帯保証人勤務先 職種
            testController.screenTargetRecord.jointGuarantorAnnualIncome = '5000000';//連帯保証人勤務先 年収
            testController.screenTargetRecord.jointGuarantorContinuedServiceYearsYear = '5';//連帯保証人勤務先 勤続年数(年/月)
            testController.screenTargetRecord.jointGuarantorContinuedServiceYearsMonth = '5';//連帯保証人勤務先 勤続年数(年/月)


            //電話番号、携帯番号、申込日をNULLに
            testController.screenTargetRecord.currentPhone ='';
            testController.screenTargetRecord.currentMobilePhone ='';
            testController.screenTargetRecord.applicationDate =null;

            //確認ボタン押下
            testController.confirm();

            //エラーメッセージが出る
            List<ApexPages.Message> messages = ApexPages.getMessages();

            System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED,'[契約者情報]の申込日')));
            System.assertEquals(true, messages[1].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_INPUT,'[契約者情報]の電話番号、携帯番号','どちらか1つ')));
            System.assertEquals(true, messages[2].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_INPUT,'[連帯保証人または緊急連絡先]の電話番号、携帯番号','どちらか1つ')));
            //System.assertEquals(true, messages[2].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED,'申込日')));
        }
    }

    //◇◇◇確認画面キャンセル
    @isTest static void cancelTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runas(userRecord){
            Application__c testApplicationRecord = [SELECT Id,LastName__c
                FROM Application__c
                WHERE LastName__c = '申込'];
            Correspond__c correspondRecord =[SELECT Id 
                FROM Correspond__c 
                WHERE District__c = '港区' LIMIT 1];
            //パラメータ設定
            PageReference pageRef = Page.GA103001View;
            pageRef.getParameters().put('applicationId',testApplicationRecord.Id );
            pageRef.getParameters().put('correspondId',correspondRecord.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA103001Controller testController = new GA103001Controller();

            //確認ボタン押下
            testController.confirm();
            testController.cancel();


            System.assertEquals(false, testController.isConfirm);

        }
    }

    //◇◇◇保存
    @isTest static void saveTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runas(userRecord){
            Application__c testApplicationRecord = [SELECT Id,
            LastName__c,
            SystemModStamp 
                FROM Application__c 
                WHERE LastName__c = '申込'];
            Correspond__c correspondRecord =[SELECT Id 
                FROM Correspond__c 
                WHERE District__c = '港区' LIMIT 1];
            //パラメータ設定
            PageReference pageRef = Page.GA103001View;
            pageRef.getParameters().put('applicationId',testApplicationRecord.Id );
            pageRef.getParameters().put('correspondId',correspondRecord.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA103001Controller testController = new GA103001Controller();

            //確認ボタン押下
            testController.confirm();
            
            //保存処理確認
            testController.save();
            List<ApexPages.Message> messages = ApexPages.getMessages();

            //スリープ
            CommonUtil.sleep(1);
        
            //新しくSystemModStampを取得
            Application__c afterTestTargetRecor = [SELECT SystemModStamp 
                                                FROM Application__c
                                                WHERE LastName__c = '申込']; 

            system.assertEquals(true,afterTestTargetRecor.SystemModStamp != testApplicationRecord.SystemModStamp );
        }
    }

   //◇◇◇保存（楽観ロックチェック）
   @isTest static void saveErrorTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runas(userRecord){
            Application__c testApplicationRecord = [SELECT Id,LastName__c,SystemModStamp 
                FROM Application__c 
                WHERE LastName__c = '申込'];
            Correspond__c correspondRecord =[SELECT Id 
                FROM Correspond__c 
                WHERE District__c = '港区' LIMIT 1];
            //パラメータ設定
            PageReference pageRef = Page.GA103001View;
            pageRef.getParameters().put('applicationId',testApplicationRecord.Id );
            pageRef.getParameters().put('correspondId',correspondRecord.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA103001Controller testController = new GA103001Controller();

            //確認ボタン押下
            testController.confirm();
            //先に更新
            testApplicationRecord.FirstName__c = 'koushin';  
            update testApplicationRecord;
            //スリープ
            CommonUtil.sleep(1);
            //保存処理確認
            testController.save();

            //スリープ
            CommonUtil.sleep(1);

            List<ApexPages.Message> messages = ApexPages.getMessages();
            System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK)));
        }
    }

	//ログインユーザパラメータエラー
    @isTest static void loginUserErrorTest(){
        
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runas(userRecord){
            Account testAccountRecord = [SELECT Id,Name
                        FROM Account
                        WHERE Name = '取引先 次郎'];
            Property__c testPropertyRecord = [SELECT Id,Name
                        FROM Property__c
                        WHERE Name = '505'];                                           
            Correspond__c correspondRecord =[SELECT Id 
                    FROM Correspond__c 
                    WHERE District__c = '港区' LIMIT 1];

            //パラメータ設定
            PageReference pageRef = Page.GA103001View;
            pageRef.getParameters().put('accountId',testAccountRecord.Id );
            pageRef.getParameters().put('propertyId',testPropertyRecord.Id );
            pageRef.getParameters().put('correspondId',correspondRecord.Id);
            pageRef.getParameters().put('userId','ABC' );//ログインユーザと異なるId
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA103001Controller testController = new GA103001Controller();

            //エラーを確認
            system.assertEquals(TRUE, testController.isOpenError);
            system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_LOGGING_DIFFERENT_USER, UserInfo.getName()));//「エラーメッセージ」の表示が正しいか確認

        }
    }

    //2020/4/30追加　カバレッジ率上げ用
    @isTest static void coverageUp(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runas(userRecord){
            Application__c testApplicationRecord2 = [SELECT Id,LastName__c,SystemModStamp,InformalOffer__c,JointGuarantorIsSpouse__c,JointGuarantorAffiliation__c
            FROM Application__c 
            WHERE LastName__c = '申込'];
            testApplicationRecord2.JointGuarantorIsSpouse__c =  '無';
            testApplicationRecord2.InformalOffer__c =  '無';
            testApplicationRecord2.JointGuarantorAffiliation__c = null;
            update testApplicationRecord2;

            Application__c testApplicationRecord = [SELECT Id,LastName__c,SystemModStamp,JointGuarantorAffiliation__c
            FROM Application__c 
            WHERE LastName__c = '申込'];

            Correspond__c correspondRecord =[SELECT Id 
                FROM Correspond__c 
                WHERE District__c = '港区' LIMIT 1];
            //パラメータ設定
            PageReference pageRef = Page.GA103001View;
            pageRef.getParameters().put('applicationId',testApplicationRecord.Id );
            pageRef.getParameters().put('correspondId',correspondRecord.Id);
            Test.setCurrentPage(pageRef);
            
            //コントローラ作成
            GA103001Controller testController = new GA103001Controller();
            //ラジオボタン
            testController.getJointGuarantorRadioButtonSetting();
            //郵便番号モーダル
            testController.modal1();
            testController.closeModal();
            testController.modal2();
            testController.closeModal();
            testController.modal3();
            testController.closeModal();
            testController.modal4();
            testController.closeModal();
            testController.modal5();
            testController.closeModal();

            //確認ボタン必須チェック
            testController.isApp=true;
            testController.screenTargetRecord.applicationType = '個人';
            testController.screenTargetRecord.residenceTermYear = null;
            testController.screenTargetRecord.continuedServiceYearsYear = null;
            testController.screenTargetRecord.jointGuarantorContinuedServiceYearsYear = null ;
            testController.confirm();
            testController.screenTargetRecord.applicationType = '法人';
            testController.confirm();
            testController.screenTargetRecord.applicationType = '学生';
            testController.screenTargetRecord.affiliationSchool = null;
            testController.confirm();
            testController.selectedIndex = 0;
            testController.TenantRecordDelete();
            testController.save();
            //モーダル起動呼び出し
            testController.openModalCreateTenant();

            //子(モーダル)起動
            GA103001Modal1Controller testModalController = new GA103001Modal1Controller();

            //親のパラメータを子に渡す(親で設定しているモーダル用のパラメータをそのまま格納)
            testModalController.parameter = testController.GA103001Modal1Parameter;
            testModalController.parameter.tenantRecord = null;

            //子のinitactionを起動
            testModalController.initAction();
            //メッセージ系
            String a = testController.MSG_COM_V_SAVE;
            a =testController.MSG_COM_I_SAVE;
            a =testController.MSG_COM_V_DELETE;
            a =testController.MSG_COM_I_DELETE;  
            a =testController.MSG_COM_V_DELETE;  
            a =testController.MSG_COM_I_CANCEL_CONFIRMATION;      
        }
    }
    @isTest static void coverageUp2(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runas(userRecord){
            Account testAccountRecord2 = [SELECT Id,Name,ContractType__c
                        FROM Account
                        WHERE Name = '取引先 次郎'];
            testAccountRecord2.JobType__c = '学生';
            update testAccountRecord2;

            Account testAccountRecord = [SELECT Id,Name
            FROM Account
            WHERE Name = '取引先 次郎'];
            Property__c testPropertyRecord = [SELECT Id,Name
                        FROM Property__c
                        WHERE Name = '505'];            
            Correspond__c correspondRecord =[SELECT Id 
                FROM Correspond__c 
                WHERE District__c = '港区' LIMIT 1];
            //パラメータ設定
            PageReference pageRef = Page.GA103001View;
            pageRef.getParameters().put('propertyId',testPropertyRecord.Id );
            pageRef.getParameters().put('AccountId',testAccountRecord.Id );
            pageRef.getParameters().put('correspondId',correspondRecord.Id);
            pageRef.getParameters().put('comeFrom','App');//アプリで開いている場合のみ必須チェックされる
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA103001Controller testController = new GA103001Controller();
            testController.screenTargetRecord.jointGuarantorAffiliation = null;
            testController.selectedIndex = 0;
            

            //保存
            testController.save();
            testController.isNew =true;
            testController.screenTargetRecord.applicationType = '学生';
            testController.save();
            testController.screenTargetRecord.isTenantPersonInclude =false;
            testController.screenTargetRecord.applicationType = '法人';
            testController.screenTargetRecord.rentFee = '5000';
            testController.save();
        }
    }

    //2020/4/30追加　カバレッジ率上げ用
    @isTest static void coverageUp3(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runas(userRecord){
            Application__c testApplicationRecord2 = [SELECT Id,LastName__c,SystemModStamp,JointGuarantorAffiliation__c
            FROM Application__c 
            WHERE LastName__c = '申込'];
            testApplicationRecord2.JointGuarantorAffiliation__c = null;
            update testApplicationRecord2;

            Application__c testApplicationRecord = [SELECT Id,LastName__c,SystemModStamp,JointGuarantorAffiliation__c
            FROM Application__c 
            WHERE LastName__c = '申込'];

            //パラメータ設定
            PageReference pageRef = Page.GA103001View;
            pageRef.getParameters().put('applicationId',testApplicationRecord.Id );

            Test.setCurrentPage(pageRef);
            
            //コントローラ作成
            GA103001Controller testController = new GA103001Controller();
        }
    }

    //▼問合せNo0569で追加
    /**
    * 物件管理会社指定商品有
    * 対象の管理会社指定商品のみチェックがついていること
    */
    @isTest static void propertyManageCompayItemChecked(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runas(userRecord){
            Account testAccountRecord = [SELECT Id,Name
                        FROM Account
                        WHERE Name = '取引先 次郎'];
            Property__c testPropertyRecord = [SELECT Id,Name
                        FROM Property__c
                        WHERE Name = '505'];                                           
            Correspond__c correspondRecord =[SELECT Id 
                    FROM Correspond__c 
                    WHERE District__c = '港区' LIMIT 1];
            //パラメータ設定
            PageReference pageRef = Page.GA103001View;
            pageRef.getParameters().put('accountId',testAccountRecord.Id );
            pageRef.getParameters().put('propertyId',testPropertyRecord.Id );
            pageRef.getParameters().put('correspondId',correspondRecord.Id);
            Test.setCurrentPage(pageRef);

            Test.startTest();
            //コントローラ作成
            GA103001Controller testController = new GA103001Controller();

            Test.stopTest();

            // 管理会社指定商品チェック状態確認
            system.assertEquals(true, testController.quoteManageCompayItemList[0].isPlanUse);
            system.assertEquals(false, testController.quoteManageCompayItemList[1].isPlanUse );
            system.assertEquals(true, testController.quoteManageCompayItemList[2].isPlanUse);

        }
    }

    /**
    * 物件管理会社指定商品無
    * 管理会社指定商品にチェックがついていないこと
    */
    @isTest static void propertyManageCompayItemunChecked(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runas(userRecord){
                        Account testAccountRecord = [SELECT Id,Name
                        FROM Account
                        WHERE Name = '取引先 次郎'];
            Property__c testPropertyRecord = [SELECT Id,Name
                        FROM Property__c
                        WHERE Name = '509'];                                           
            Correspond__c correspondRecord =[SELECT Id 
                    FROM Correspond__c 
                    WHERE District__c = '港区' LIMIT 1];
            //パラメータ設定
            PageReference pageRef = Page.GA103001View;
            pageRef.getParameters().put('accountId',testAccountRecord.Id );
            pageRef.getParameters().put('propertyId',testPropertyRecord.Id );
            pageRef.getParameters().put('correspondId',correspondRecord.Id);
            Test.setCurrentPage(pageRef);

            Test.startTest();
            //コントローラ作成
            GA103001Controller testController = new GA103001Controller();

            Test.stopTest();

            // 管理会社指定商品チェック状態確認
            system.assertEquals(false, testController.quoteManageCompayItemList[0].isPlanUse);
            system.assertEquals(false, testController.quoteManageCompayItemList[1].isPlanUse);
            system.assertEquals(false, testController.quoteManageCompayItemList[2].isPlanUse);

        }
    }
    /**
    * 管理会社指定商品無、物件管理会社指定商品無
    * 管理会社指定商品がリストに無く、エラーとならないこと
    */
    @isTest static void propertyManageCompayItemNothing(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runas(userRecord){
                        Account testAccountRecord = [SELECT Id,Name
                        FROM Account
                        WHERE Name = '取引先 次郎'];
            Property__c testPropertyRecord = [SELECT Id,Name
                        FROM Property__c
                        WHERE Name = '510'];                                           
            Correspond__c correspondRecord =[SELECT Id 
                    FROM Correspond__c 
                    WHERE District__c = '港区' LIMIT 1];
            //パラメータ設定
            PageReference pageRef = Page.GA103001View;
            pageRef.getParameters().put('accountId',testAccountRecord.Id );
            pageRef.getParameters().put('propertyId',testPropertyRecord.Id );
            pageRef.getParameters().put('correspondId',correspondRecord.Id);
            Test.setCurrentPage(pageRef);

            Test.startTest();
            //コントローラ作成
            GA103001Controller testController = new GA103001Controller();

            Test.stopTest();

            // 管理会社指定商品チェック状態確認0件
            system.assertEquals(0, testController.quoteManageCompayItemList.size());

        }
    }
    //▲問合せNo0569で追加

	// ▼ 2022.02.15 No0727 付帯保証プラン・火災保証プランの金額変更
	/**
    * 新規登録処理
    * 申込．賃料が入力項目の賃料の内容で保存されること
	* 申込．総賃料が入力項目の項目から合算で保存されること
    */
    @isTest static void applicationCalculationRentFee(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runas(userRecord){
			Account testAccountRecord = [SELECT Id,Name
				FROM Account
				WHERE Name = '取引先 次郎'];
            Property__c testPropertyRecord = [SELECT Id,Name
                        FROM Property__c
                        WHERE Name = '510'];                                           
            Correspond__c correspondRecord =[SELECT Id 
                    FROM Correspond__c 
                    WHERE District__c = '港区' LIMIT 1];
            //パラメータ設定
            PageReference pageRef = Page.GA103001View;
            pageRef.getParameters().put('accountId',testAccountRecord.Id );
            pageRef.getParameters().put('propertyId',testPropertyRecord.Id );
            pageRef.getParameters().put('correspondId',correspondRecord.Id);
            Test.setCurrentPage(pageRef);

			Test.startTest();
            //コントローラ作成
            GA103001Controller testController = new GA103001Controller();

			// 入力項目
			testController.screenTargetRecord.rentFee = '20000'; // 賃料
			testController.screenTargetRecord.wortFeeTax = '1000';// 申込．水道料金
			testController.screenTargetRecord.managementFeeTax = '2000';// 申込．共益費
			testController.screenTargetRecord.catvFeeTax = '2000';// 申込．CATV
			testController.screenTargetRecord.townshipFeeTax = '200';// 申込．町会費
			testController.screenTargetRecord.garbageDisposalFeeTax = '3000';// 申込．ゴミ処理費
			testController.screenTargetRecord.bicycleParkingFeeTax = '1000';// 申込．駐輪場代
			testController.screenTargetRecord.bikeParkingSmallFeeTax = '2000';// 申込．バイク置き場代（小型）日割額
			testController.screenTargetRecord.bikeParkingMediumFeeTax = '3000';// 申込．バイク置き場代（中型）日割額
			testController.screenTargetRecord.bikeParkinLargeFeeTax = '4000';// 申込．バイク置き場代（大型）日割額
			testController.screenTargetRecord.parkingFeeTax = '5000';// 申込．駐車場

			//確認ボタン押下
			testController.confirm();
			
			//保存処理確認
			testController.save();
			List<ApexPages.Message> messages = ApexPages.getMessages();

			//スリープ
			CommonUtil.sleep(1);

            Test.stopTest();

			// 申込情報取得
			Application__c app = [ SELECT Id, AllRentFee__c, RentFee__c, Rent__c FROM Application__c 
				WHERE Account__c = :testAccountRecord.Id 
				LIMIT 1];

			// 賃料
			system.assertEquals(CommonUtil.stringToDecimal(testController.screenTargetRecord.rentFee), app.RentFee__c);
			// 総賃料（入力項目＋テスト新規火災保険（月額2200円）＝45400）
			system.assertEquals(45400, app.AllRentFee__c);

        }
    }
    
	/**
    * 更新処理
    * 申込．賃料が入力項目の賃料の内容で保存されること
	* 申込．総賃料が入力項目の項目から合算で保存されること
    */
    @isTest static void applicationCalculationRentFeeUpDate(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        system.runas(userRecord){
			Account testAccountRecord = [SELECT Id,Name
				FROM Account
				WHERE Name = '取引先 次郎'];
            Property__c testPropertyRecord = [SELECT Id,Name
                        FROM Property__c
                        WHERE Name = '510'];                                           
            Correspond__c correspondRecord =[SELECT Id 
                    FROM Correspond__c 
                    WHERE District__c = '港区' LIMIT 1];
            //パラメータ設定
            PageReference pageRef = Page.GA103001View;
            pageRef.getParameters().put('accountId',testAccountRecord.Id );
            pageRef.getParameters().put('propertyId',testPropertyRecord.Id );
            pageRef.getParameters().put('correspondId',correspondRecord.Id);
            Test.setCurrentPage(pageRef);
        	//コントローラ作成
			GA103001Controller testController = new GA103001Controller();

			// 入力項目
			testController.screenTargetRecord.lastName = '申込の更新後再度計算する内容';
			testController.screenTargetRecord.rentFee = '20000'; // 賃料
			testController.screenTargetRecord.wortFeeTax = '1000';// 申込．水道料金
			testController.screenTargetRecord.managementFeeTax = '2000';// 申込．共益費
			testController.screenTargetRecord.catvFeeTax = '2000';// 申込．CATV
			testController.screenTargetRecord.townshipFeeTax = '200';// 申込．町会費
			testController.screenTargetRecord.garbageDisposalFeeTax = '3000';// 申込．ゴミ処理費
			testController.screenTargetRecord.bicycleParkingFeeTax = '1000';// 申込．駐輪場代
			testController.screenTargetRecord.bikeParkingSmallFeeTax = '2000';// 申込．バイク置き場代（小型）日割額
			testController.screenTargetRecord.bikeParkingMediumFeeTax = '3000';// 申込．バイク置き場代（中型）日割額
			testController.screenTargetRecord.bikeParkinLargeFeeTax = '4000';// 申込．バイク置き場代（大型）日割額
			testController.screenTargetRecord.parkingFeeTax = '5000';// 申込．駐車場

			//確認ボタン押下
			testController.confirm();
			
			//保存処理
			testController.save();

			// 保存後の申込情報取得
			Application__c application = ([SELECT Id,AllRentFee__c, RentFee__c,FireInsuranceTitle__c FROM Application__c WHERE LastName__c ='申込の更新後再度計算する内容' LIMIT 1]);

			//パラメータ設定
			PageReference pageRef2 = Page.GA103001View;
			pageRef2.getParameters().put('applicationId',application.Id );
			pageRef2.getParameters().put('correspondId',correspondRecord.Id);
			Test.setCurrentPage(pageRef2);
			
			Test.startTest();
			//コントローラ作成
			GA103001Controller testController2 = new GA103001Controller();
			// 入力項目
			testController2.screenTargetRecord.rentFee = '80000'; // 賃料
			testController2.screenTargetRecord.wortFeeTax = '0';// 申込．水道料金
			testController2.screenTargetRecord.managementFeeTax = '9000';// 申込．共益費
			testController2.screenTargetRecord.catvFeeTax = '6000';// 申込．CATV
			testController2.screenTargetRecord.townshipFeeTax = '8200';// 申込．町会費
			testController2.screenTargetRecord.garbageDisposalFeeTax = '53000';// 申込．ゴミ処理費
			testController2.screenTargetRecord.bicycleParkingFeeTax = '19000';// 申込．駐輪場代
			testController2.screenTargetRecord.bikeParkingSmallFeeTax = '28000';// 申込．バイク置き場代（小型）日割額
			testController2.screenTargetRecord.bikeParkingMediumFeeTax = '38000';// 申込．バイク置き場代（中型）日割額
			testController2.screenTargetRecord.bikeParkinLargeFeeTax = '48000';// 申込．バイク置き場代（大型）日割額
			testController2.screenTargetRecord.parkingFeeTax = '58000';// 申込．駐車場
			//確認ボタン押下
			testController2.confirm();
			//保存処理
			testController2.save();

            Test.stopTest();
			// 更新後再取得
			Application__c applicationUpdate = ([SELECT Id,AllRentFee__c, RentFee__c FROM Application__c WHERE LastName__c ='申込の更新後再度計算する内容' LIMIT 1]);

			// 賃料
			system.assertEquals(20000, application.RentFee__c);
			// 総賃料
			system.assertEquals(45400, application.AllRentFee__c);

			// 賃料
			system.assertEquals(80000, applicationUpdate.RentFee__c);
			// 総賃料
			system.assertEquals(349400, applicationUpdate.AllRentFee__c);

        }
    }

	// ▲ 2022.02.15 No0727 付帯保証プラン・火災保証プランの金額変更

	// ▼ 2022.03.01 No0739 同じ申込を2件以上登録できないように対応から申込があるかを確認する
	/**
	* 新規登録処理後
	* 画面再描画で申込の登録
	* 申込が新規登録された後、再描画後でも申込が新規で作成されず、更新されること
	*/
    @isTest static void applicationRedrawUpDate(){
		User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
		system.runas(userRecord){
			Account testAccountRecord = [SELECT Id,Name
				FROM Account
				WHERE Name = '取引先 次郎'];
			Property__c testPropertyRecord = [SELECT Id,Name
						FROM Property__c
						WHERE Name = '510'];                                           
			Correspond__c correspondRecord =[SELECT Id 
					FROM Correspond__c 
					WHERE District__c = '港区' LIMIT 1];
			//パラメータ設定
			PageReference pageRef = Page.GA103001View;
			pageRef.getParameters().put('accountId',testAccountRecord.Id );
			pageRef.getParameters().put('propertyId',testPropertyRecord.Id );
			pageRef.getParameters().put('correspondId',correspondRecord.Id);
			pageRef.getParameters().put('comeFrom','App');//アプリで開いている場合のみ必須チェックされる
			Test.setCurrentPage(pageRef);

			Test.startTest();
            //コントローラ作成
            GA103001Controller testController = new GA103001Controller();

			//確認ボタン押下
			testController.confirm();
			
			//保存処理確認
			testController.save();
			List<ApexPages.Message> messages = ApexPages.getMessages();

			//スリープ
			CommonUtil.sleep(1);


			// 再描画（仮）
			//コントローラ作成
			GA103001Controller testController2 = new GA103001Controller();
			//確認ボタン押下
			testController2.confirm();

			//保存処理確認
			testController2.save();

            Test.stopTest();

			// 申込情報取得
			List<Application__c> app = [ SELECT Id FROM Application__c 
				WHERE Account__c = :testAccountRecord.Id ];

			// 申込件数
			system.assertEquals(1, app.size());

        }
	}
	
	/**
	* 更新処理
	* 対象の申込が更新されること
	*/
    @isTest static void applicationUpDate(){
		User userRecord =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
		system.runas(userRecord){
			Account testAccountRecord = [SELECT Id,Name FROM Account
				WHERE Name = '申込 テスト太郎'];
			Property__c testPropertyRecord = [SELECT Id FROM Property__c
				WHERE Name = '101'];                                           
			Correspond__c correspondRecord =[SELECT Id FROM Correspond__c 
				WHERE AccountId__c = :testAccountRecord.id LIMIT 1];
			Application__c testApplicationRecord = [SELECT Id FROM Application__c 
				WHERE Account__c = :testAccountRecord.Id];
			//パラメータ設定
			PageReference pageRef = Page.GA103001View;
			pageRef.getParameters().put('accountId',testAccountRecord.Id );
			pageRef.getParameters().put('propertyId',testPropertyRecord.Id );
			pageRef.getParameters().put('correspondId',correspondRecord.Id);
			pageRef.getParameters().put('applicationId',testApplicationRecord.Id);
			pageRef.getParameters().put('comeFrom','App');//アプリで開いている場合のみ必須チェックされる
			Test.setCurrentPage(pageRef);

			Test.startTest();
            //コントローラ作成
            GA103001Controller testController = new GA103001Controller();

			//確認ボタン押下
			testController.confirm();
			
			//保存処理確認
			testController.save();
			List<ApexPages.Message> messages = ApexPages.getMessages();

			//スリープ
			CommonUtil.sleep(1);

			// 申込情報取得
			List<Application__c> app = [ SELECT Id FROM Application__c 
			WHERE Account__c = :testAccountRecord.Id ];
		
			// 申込件数
			system.assertEquals(1, app.size());
		}
	}
	// ▲ 2022.03.01 No0739 同じ申込を2件以上登録できないように対応から申込があるかを確認する
}