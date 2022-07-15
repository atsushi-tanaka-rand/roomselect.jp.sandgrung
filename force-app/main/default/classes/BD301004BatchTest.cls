// 元付業者管理物件変更メール送信バッチ テストクラス
@isTest 
private class BD301004BatchTest {    

    public static final String USER_NAME = 'GA104006@horaguchi.com'; 
    
    //テストに使用するレコードを作成する
    @testSetup static void Setting() {

        //店舗レコード
        Shop__c testUserShop = new shop__c(
            Name = 'テストユーザ店舗'
            ,PortalSitePostingDistrict__c = '港区'
            ,Email__c = 'test@mail.co.jp'
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
            Shop__c = testUserShop.Id
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
        ShopTransfer__c testShopTransfer = new ShopTransfer__c(
            OrgzanizationHierarchy__c = orgRecord2.id,
            Staff__c = thisUser.id,
            StartDate__c = Date.newInstance(2000, 12, 1),
            EndDate__c = Date.newInstance(2999, 12, 1)
        );
        insert testShopTransfer;

        // カスタム設定
        SystemConfig__c testSystemConfig = new SystemConfig__c();
        testSystemConfig.FormerSupplierPropChgSendMailBatSize__c = 200;
        testSystemConfig.UseAuthority_Portal__c = true;
        insert testSystemConfig;
        
        // 取引先（元付）
        Account testFormerSupplier = new Account(
            Name = 'テスト元付業者'
            ,RecordTypeId = CommonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_SUPPLIER)
            ,IsOwner__c = false
            ,IsManagementCompany__c = true
            ,IsSubLease__c = false
            ,IsGuaranteeidCompany__c = false
            ,IsInsuranceCompany__c = false
            ,at_home_press_ban__c = true
            ,HOME_S_press_ban__c = true
            ,SUUMO_press_ban__c = true	
			,Chintai_press_ban__c = true // 2022.04.07 CHINTAI対応追加
            ,Our_HP_press_ban__c = true
        );
        insert testFormerSupplier;
        
        // 建物
        Building__c testBuilding1 = new Building__c(
            Name = 'テスト建物'
            , District__c = '港区'
        );
        Building__c testBuilding2 = new Building__c(
            Name = 'テスト建物'
        );
        Building__c testBuilding3 = new Building__c(
            Name = 'テスト建物'
            , District__c = '西区'
        );
        List<Building__c> testBuilding = new List<Building__c> {
            testBuilding1
            , testBuilding2
            , testBuilding3
        };
        insert testBuilding;

        // 物件
        Property__c testProperty1 = new Property__c(
             Name                        = '_t_2'                                   // 部屋番号
            ,IsMergeCompletedFlag__c    = false                                     // 名寄せ完了フラグ
            ,Building__c                = testBuilding1.Id                          // 建物
            ,FormerSupplier__c          = testFormerSupplier.Id                     // 元付業者
            ,WebPublishing__c           = CommonConst.PROPERTY_WEBPUBLISHING_EXISTS // Web公開
            ,LiveStatus__c              = CommonConst.PROPERTY_LIVESTATUS_VACANCY   // 現況
            ,RentFee__c                 = 50000
        );
        Property__c testProperty2 = new Property__c(
             Name                        = '_t_3'                                   // 部屋番号
            ,IsMergeCompletedFlag__c    = false                                     // 名寄せ完了フラグ
            ,Building__c                = testBuilding2.Id                          // 建物
            ,FormerSupplier__c          = testFormerSupplier.Id                     // 元付業者
            ,WebPublishing__c           = CommonConst.PROPERTY_WEBPUBLISHING_EXISTS // Web公開
            ,LiveStatus__c              = CommonConst.PROPERTY_LIVESTATUS_VACANCY   // 現況
            ,RentFee__c                 = 50000
        );
        Property__c testProperty3 = new Property__c(
             Name                        = '_t_4'                                   // 部屋番号
            ,IsMergeCompletedFlag__c    = false                                     // 名寄せ完了フラグ
            ,Building__c                = testBuilding3.Id                          // 建物
            ,FormerSupplier__c          = testFormerSupplier.Id                     // 元付業者
            ,WebPublishing__c           = CommonConst.PROPERTY_WEBPUBLISHING_EXISTS // Web公開
            ,LiveStatus__c              = CommonConst.PROPERTY_LIVESTATUS_VACANCY   // 現況
            ,RentFee__c                 = 50000
        );
        List<Property__c> testProperty = new List<Property__c> {
            testProperty1
            ,testProperty2
            ,testProperty3
        };

        insert testProperty;

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
            Property__c = testProperty1.Id
            ,Shop__c = testShop1.Id
            ,IsSuumo__c = true
            ,IsHomes__c = true
            ,IsAtHome__c = false
			,IsChintaiNet__c = false // 2022.04.07 CHINTAI対応追加
			,IsChintaiPanoramaPosting__c = false // 2022.04.07 CHINTAI対応追加
            ,IsPortal__c = false
        );
        PortalSitePostingProperty__c testPortalSitePostingProperty2 = new PortalSitePostingProperty__c(
            Property__c = testProperty1.Id
            ,Shop__c = testShop2.Id
            ,IsSuumo__c = true
            ,IsHomes__c = false
            ,IsAtHome__c = true
			,IsChintaiNet__c = false // 2022.04.07 CHINTAI対応追加
			,IsChintaiPanoramaPosting__c = false // 2022.04.07 CHINTAI対応追加
            ,IsPortal__c = false
        );

		PortalSitePostingProperty__c testPortalSitePostingProperty3 = new PortalSitePostingProperty__c(
            Property__c = testProperty2.Id
            ,Shop__c = testShop2.Id
            ,IsSuumo__c = true
            ,IsHomes__c = false
            ,IsAtHome__c = true
			,IsChintaiNet__c = false // 2022.04.07 CHINTAI対応追加
			,IsChintaiPanoramaPosting__c = false // 2022.04.07 CHINTAI対応追加
            ,IsPortal__c = false
        );

        List<PortalSitePostingProperty__c> testPortalSitePostingProperty = new List<PortalSitePostingProperty__c> {
            testPortalSitePostingProperty1
            ,testPortalSitePostingProperty2
			,testPortalSitePostingProperty3
        };
        insert testPortalSitePostingProperty;
        
        // 地区別メンテナンス条件
        AreaMaintenanceCondition__c areaMaintenanceCondition1 = new AreaMaintenanceCondition__c (
            PropertyAmountLowerLimit__c = 10000
            , PropertyAmountUpperLimit__c = 100000
            , District__c = '港区'
        );
        AreaMaintenanceCondition__c areaMaintenanceCondition2 = new AreaMaintenanceCondition__c (
            PropertyAmountLowerLimit__c = 100000000
            , PropertyAmountUpperLimit__c = 100000000
            , District__c = '西区'
        );
        List<AreaMaintenanceCondition__c> areaMaintenanceCondition = new List<AreaMaintenanceCondition__c> {
            areaMaintenanceCondition1
            , areaMaintenanceCondition2
        };
        insert areaMaintenanceCondition;
    }
    
    // ポータルサイト掲載物件更新
    @isTest static void updateTest() {
      
        Account account = [SELECT Id, Name FROM Account WHERE Name = 'テスト元付業者'];

        //バッチ実行
		Test.startTest();
        BD301004Batch b = new BD301004Batch(account.Id, true, true, false, false, account.Name, true, true, true, true);
        Integer BATCH_SIZE = SystemConfig__c.getInstance().FormerSupplierPropChgSendMailBatSize__c.intValue(); //バッチサイズ
        Database.executeBatch(b, BATCH_SIZE);
		Test.stopTest();
		// ▼ 2022.04.01 CHINTAI対応追加
		List<PortalSitePostingProperty__c> portalList = [SELECT Id, IsChintaiNet__c, IsChintaiPanoramaPosting__c FROM PortalSitePostingProperty__c WHERE Property__r.FormerSupplier__c = :account.Id];
		System.assertEquals(false, portalList[0].IsChintaiNet__c);
		System.assertEquals(false, portalList[0].IsChintaiPanoramaPosting__c);
		// ▲ 2022.04.01 CHINTAI対応追加
    }

    // ポータルサイト掲載物件削除
    @isTest static void deleteTest() {
        Account account = [SELECT Id, Name FROM Account WHERE Name = 'テスト元付業者'];
		// ▼ 2022.04.01 CHINTAI対応追加、ポータルサイト掲載物件が削除される
		List<PortalSitePostingProperty__c> beforePortalList = [SELECT Id FROM PortalSitePostingProperty__c WHERE Property__r.FormerSupplier__c = :account.Id];
		System.assertEquals(true, beforePortalList.size() > 0);
        //バッチ実行
        Test.startTest();
        BD301004Batch b = new BD301004Batch(account.Id, false, false, false, false, account.Name, true, true, true, true);
        Integer BATCH_SIZE = SystemConfig__c.getInstance().FormerSupplierPropChgSendMailBatSize__c.intValue(); //バッチサイズ
		Database.executeBatch(b, BATCH_SIZE);
        Test.stopTest();
		List<PortalSitePostingProperty__c> afterPortalList = [SELECT Id FROM PortalSitePostingProperty__c WHERE Property__r.FormerSupplier__c = :account.Id];
		System.assertEquals(false, afterPortalList.size() > 0);
        // ▲ 2022.04.01 CHINTAI対応追加
    }

    // ポータルサイト掲載物件登録
    @isTest static void registTest() {
        
        Account account = [SELECT Id, Name FROM Account WHERE Name = 'テスト元付業者'];
		
		//既存データを削除
        List<PortalSitePostingProperty__c> portalSitePostingProperty = [SELECT Id FROM PortalSitePostingProperty__c];
        delete portalSitePostingProperty;
		
        // ▼ 2022.04.01 CHINTAI対応追加 バッチ実行
		Test.startTest();
        BD301004Batch b = new BD301004Batch(account.Id, false, false, true, true, account.Name, true, true, true, true);
        Integer BATCH_SIZE = SystemConfig__c.getInstance().FormerSupplierPropChgSendMailBatSize__c.intValue(); //バッチサイズ
        Database.executeBatch(b, BATCH_SIZE);
		Test.stopTest();
        List<PortalSitePostingProperty__c> afterPortalList = [SELECT Id, IsChintaiNet__c, IsChintaiPanoramaPosting__c FROM PortalSitePostingProperty__c WHERE Property__r.FormerSupplier__c = :account.Id];
		System.assertEquals(true, afterPortalList.size() > 0);
		System.assertEquals(false, afterPortalList[0].IsChintaiNet__c);
		System.assertEquals(false, afterPortalList[0].IsChintaiPanoramaPosting__c);
        // ▲ 2022.04.01 CHINTAI対応追加
    }

}