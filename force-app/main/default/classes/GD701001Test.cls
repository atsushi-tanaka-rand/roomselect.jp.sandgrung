/**
* 手動メンテ一覧画面のテスト
*/
@isTest 
private class GD701001Test{
    
    //テストに使用するレコードを作成する
    @testSetup static void Setting(){
        //テスト用レコードを作成
        SystemConfig__c s = new SystemConfig__c(ManualLimit__c = 1000);
        insert s;
        
        //取引先レコード（元付業者）
        Account accountRecord = new Account(RecordTypeId = CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_SUPPLIER),
                                            Name = 'オルソン株式会社' ,
                                            Phone = '111-1111-1111' ,
                                            Representative__c = 'オルソン担当者',
                                            RepresentativePhone__c = '222-2222-2222',
                                            Email__c = 'test@oruson.com',
                                            IppamGyobutsu__c = '業物');
        insert accountRecord;
        
        //建物レコード
        Building__c buildingRecord = new Building__c(District__c = '港区',
                                                     Name = 'テスト建物1' );
        insert buildingRecord;
        
        //物件レコード
        Property__c propertyRecord = new Property__c(Building__c = buildingRecord.Id,
                                                     Name = '1',
                                                     ManualMaintenanceDate__c = datetime.newInstance(2019, 12, 21),
                                                     FormerSupplier__c = accountRecord.Id,
                                                     MaintenancePropertyCode__c = '手動登録' );
        insert propertyRecord;
        
        
        //店舗レコード
        Shop__c shopRecord = new shop__c(Name = 'テス店舗',
                                         PortalSitePostingDistrict__c = '港区;北区');
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
            OrganizationName__c = 'テスト店舗',
            HierarchyCode__c = '20',
            HierarchyOrder__c = 1,
            UpperOrganizationHierarchy__c = orgRecord1.Id,
            ExpandedOrganizationCode__c = '0000_0001_0002',
            Shop__c = shopRecord.Id
        );
        insert orgRecord2;

        //ユーザ作成
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name IN ('Standard User', '標準ユーザ')];
        System.assert(profiles.size() > 0);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            insert new User(
                UserName = 'GD701001Test@horaguchi.com',
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
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD701001Test@horaguchi.com'];
        ShopTransfer__c ShopTransferRecord = new ShopTransfer__c(OrgzanizationHierarchy__c = orgRecord2.id,
                                                                 Staff__c = userRecord.id,
                                                                 StartDate__c = Date.newInstance(2000, 12, 1),
                                                                 EndDate__c = Date.newInstance(2999, 12, 1)); 
        insert ShopTransferRecord;
    }
    
    //初期表示テスト	
    @isTest static void initializeTest(){
        
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD701001Test@horaguchi.com'];
        system.runas(userRecord){
            //コントローラ作成
            GD701001Controller testController = new GD701001Controller();
            //地区が設定されている？
            //2020.05.27　地区の初期表示処理削除 
            //system.assertEquals(testController.Districts, '港区;北区');
            //元付業者検索ボックスが空？
            system.assertEquals(testController.FormerSupplier, '');
        }
        
    }
    //検索テスト	
    @isTest static void searchTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD701001Test@horaguchi.com'];
        system.runas(userRecord){
            //コントローラ作成
            GD701001Controller testController = new GD701001Controller();
            testController.Districts = '港区';
            testController.FormerSupplier = 'オルソン';
            testController.search();
            system.assertEquals(testController.accountRecordList[0].Name, 'オルソン株式会社');
        }
        
        
    }
    //検索テスト(0件)	
    @isTest static void searchErrorTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD701001Test@horaguchi.com'];
        system.runas(userRecord){
            //コントローラ作成
            GD701001Controller testController = new GD701001Controller();
            testController.Districts = '港区';
            testController.FormerSupplier = 'testesテスト';
            testController.search();
            List<ApexPages.Message> messages = ApexPages.getMessages();
            System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_NO_DATA)));
        }
        
    }

	// ▼2022.04.20 No.0777 対応
    /**
    * １．最終更新日がnullでないデータが複数件ある場合に、最新のデータが表示されること。
    */
	@isTest static void SearchManualMaintenanceDate_1(){
		
        Account accountRcd = [SELECT Id FROM Account WHERE Name = 'オルソン株式会社' limit 1];
        Building__c buildingRcd = [SELECT Id FROM Building__c WHERE Name = 'テスト建物1' limit 1];

		//最新物件レコード作成
		Property__c propertyRecord_2 = new Property__c(Building__c = buildingRcd.Id,
		Name = '2',
		ManualMaintenanceDate__c = datetime.newInstance(2021, 12, 21),//最終手動メンテ日, 上では2019/12/21
		FormerSupplier__c = accountRcd.Id,
		MaintenancePropertyCode__c = '手動登録' );
		insert propertyRecord_2;


        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD701001Test@horaguchi.com'];
        system.runas(userRecord){
            //コントローラ作成
            GD701001Controller testController = new GD701001Controller();
            testController.Districts = '港区';
            testController.FormerSupplier = 'オルソン';
            testController.search();
            
            for(Account searchResult: testController.accountRecordList){
                 System.assertEquals( propertyRecord_2.ManualMaintenanceDate__c, searchResult.PropertyFormerSupplier__r[0].ManualMaintenanceDate__c);
            }
        }
	}
    /**
    * 2．最終更新日にnullとnullでないデータが複数件ある場合に、最新のデータが表示されること
    */
	@isTest static void SearchManualMaintenanceDate_2(){
		
        Account accountRcd = [SELECT Id FROM Account WHERE Name = 'オルソン株式会社' limit 1];
        Building__c buildingRcd = [SELECT Id FROM Building__c WHERE Name = 'テスト建物1' limit 1];

        //3件で2件は値が入ってる,1件はNULL

		//Null物件レコード作成
		Property__c propertyRecord_2 = new Property__c(Building__c = buildingRcd.Id,
		Name = '2',
		ManualMaintenanceDate__c = null,
		FormerSupplier__c = accountRcd.Id,
		MaintenancePropertyCode__c = '手動登録' );
		insert propertyRecord_2;

        //最新物件レコード作成
        Property__c propertyRecord_3 = new Property__c(Building__c = buildingRcd.Id,
		Name = '3',
		ManualMaintenanceDate__c = datetime.newInstance(2022, 04, 21),
		FormerSupplier__c = accountRcd.Id,
		MaintenancePropertyCode__c = '手動登録' );
		insert propertyRecord_3;

        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD701001Test@horaguchi.com'];
        system.runas(userRecord){
            //コントローラ作成
            GD701001Controller testController = new GD701001Controller();
            testController.Districts = '港区';
            testController.FormerSupplier = 'オルソン';
            testController.search();
            
            for(Account searchResult: testController.accountRecordList){
                System.assertEquals(propertyRecord_3.ManualMaintenanceDate__c , searchResult.PropertyFormerSupplier__r[0].ManualMaintenanceDate__c);
            }
        }
	}

    /**
    * 3. 最終更新日がnullのデータしかない場合に、nullが表示されること
    */
	@isTest static void SearchManualMaintenanceDate_3(){
		
        Account accountRcd = [SELECT Id FROM Account WHERE Name = 'オルソン株式会社' limit 1];
        Building__c buildingRcd = [SELECT Id FROM Building__c WHERE Name = 'テスト建物1' limit 1];

        //settingで登録されたデータをnullにする
        Property__c propertyRcd = [SELECT Id FROM Property__c WHERE Name = '1' limit 1];
        propertyRcd.ManualMaintenanceDate__c = null;
        update propertyRcd;

		//Null物件レコード作成
		Property__c propertyRecord_2 = new Property__c(Building__c = buildingRcd.Id,
		Name = '2',
		ManualMaintenanceDate__c = null,
		FormerSupplier__c = accountRcd.Id,
		MaintenancePropertyCode__c = '手動登録' );
		insert propertyRecord_2;

        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD701001Test@horaguchi.com'];
        system.runas(userRecord){
            //コントローラ作成
            GD701001Controller testController = new GD701001Controller();
            testController.Districts = '港区';
            testController.FormerSupplier = 'オルソン';
            testController.search();
            
            for(Account searchResult: testController.accountRecordList){
                System.assertEquals(null , searchResult.PropertyFormerSupplier__r[0].ManualMaintenanceDate__c);
            }
        }
	}
    // ▲2022.04.20 No.0777 対応
}