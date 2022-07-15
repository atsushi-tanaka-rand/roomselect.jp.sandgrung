/* *
* 元付物件詳細画面のテストクラス
*/
@isTest
private class GD701002Test {
    
    // テストに使用するレコードを作成する
    @TestSetup static void setting(){
        
        //レコードタイプID取得
        ID testAccountRecordTypeId = CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_SUPPLIER);
        
        // カスタム設定を登録
        SystemConfig__c sysconf = new SystemConfig__c(
            SupplierPropertyBuildingSearchMaxCount__c = 2
            ,SupplierPropertyBuildingDisplayMaxCount__c = 1
        );
        insert sysconf;
        
        //取引先レコード（元付業者）
        Account accountRecord = new Account(RecordTypeId = CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_SUPPLIER),
                                            FixedTermSend__c = '',
                                            Email__c = 'test@test.co.jp',
                                            Name = 'オルソン株式会社' ,
                                            Phone = '111-1111-1111' ,
                                            Fax = '333-3333-3333',
                                            Representative__c = 'オルソン担当者',
                                            RepresentativePhone__c = '222-2222-2222',
                                            DembutsuStatus__c = '○',
                                            DembutsuDate__c = Date.newInstance(2019, 12, 31),
                                            DembutsuStaff__c = 'テスト電物担当者',
                                            IppamGyobutsu__c = '一般物',
                                            DembutsuEventMemo__c = 'メモ：電物完了(仮)');
        insert accountRecord;

        //建物レコード
        Building__c buildingRecord1 = new Building__c(District__c = '港区',
                                                     Name = '建物A',
                                                     BuildingYM__c = '201801',
                                                     State__c = '愛知県',
                                                     City__c = '名古屋市港区',
                                                     Street__c = '1番地1'
                                                    );
        Building__c buildingRecord2 = new Building__c(District__c = '港区',
                                                     Name = '建物B',
                                                     BuildingYM__c = '201801',
                                                     State__c = '愛知県',
                                                     City__c = '名古屋市港区',
                                                     Street__c = '1番地2'
                                                    );
        List<building__c> buildingRecord = new List<building__c>{
            buildingRecord1
            ,buildingRecord2
        };
        insert buildingRecord;
        
        //物件レコード
        Property__c propertyRecord1 = new Property__c(Name = '1',
                                                     LiveStatus__c = '居住中',
                                                     DeliveryYear__c = '2020',
                                                     DeliveryMonth__c = '1月',
                                                     DeliveryTiming__c = '上旬',
                                                     Score__c = 10,
                                                     RoomLayout__c = 'K',
                                                     RentFee__c = 10000,
                                                     ManagementFee__c = 10000,
                                                     SecurityDepositYen__c = 10000,
                                                     KeyMoneyYen__c = 10000,
                                                     DepositYen__c = 10000,
                                                     FormerSupplier__c = accountRecord.Id,
                                                     Building__c = buildingRecord1.Id);

        Property__c propertyRecord2 = new Property__c(Name = '2',
                                                      LiveStatus__c = '空室',
                                                      DeliveryYear__c = '2020',
                                                      DeliveryMonth__c = '1月',
                                                      DeliveryTiming__c = '上旬',
                                                      Score__c = 10,
                                                      RoomLayout__c = 'K',
                                                      RentFee__c = 10000,
                                                      ManagementFee__c = 10000,
                                                      SecurityDepositYen__c = 10000,
                                                      KeyMoneyYen__c = 10000,
                                                      DepositYen__c = 10000,
                                                      FormerSupplier__c = accountRecord.Id,
                                                      Building__c = buildingRecord1.Id,
                                                      WebPublishing__c = CommonConst.PROPERTY_WEBPUBLISHING_EXISTS);
        List<Property__c> propertyRecordList = new List<Property__c> {propertyRecord1, propertyRecord2};
        insert propertyRecordList;
        
        //店舗レコード
        Shop__c shopRecord = new shop__c(Name = 'テスト店舗',
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
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name IN ('システム管理者')];
        System.assert(profiles.size() > 0);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            insert new User(
                UserName = 'GD701002Test@horaguchi.com',
                Email = 'hutaigyousya_test@example.com',
                LastName = 'FutaiTest',
                Alias = 'F・test',
                TimeZoneSidKey = 'Asia/Tokyo',
                LocaleSidKey = 'ja_JP',
                EmailEncodingKey = 'ISO-2022-JP',
                LanguageLocaleKey = 'ja',
                ProfileId = profiles.get(0).Id);
        }        
        
        //店舗異動レコード
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD701002Test@horaguchi.com'];
        ShopTransfer__c ShopTransferRecord = new ShopTransfer__c(OrgzanizationHierarchy__c = orgRecord2.id,
                                                                 Staff__c = userRecord.id,
                                                                 StartDate__c = Date.newInstance(2000, 12, 1),
                                                                 EndDate__c = Date.newInstance(2999, 12, 1)); 
        insert ShopTransferRecord;
        
        //ポータル掲載物件レコード
        PortalSitePostingProperty__c PortalSitePostingPropertyRecord 
            = new PortalSitePostingProperty__c( Property__c = propertyRecord1.Id
                                               , IsAtHome__c = false
                                               , IsHomes__c = false
                                               , IsSuumo__c = false
                                               , Shop__c = shopRecord.Id);
        insert PortalSitePostingPropertyRecord;
    }
    
    //初期表示テスト
    @isTest
    private static void initializeTest() {
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD701002Test@horaguchi.com'];
        system.runas(userRecord){
            
            
            //取引先レコード取得
            Account testAccout = [SELECT Id, DembutsuDate__c, SystemModStamp FROM Account WHERE Name = 'オルソン株式会社'];
            
            //パラメータ設定
            PageReference pageRef = Page.GD701002View;
            pageRef.getParameters().put('Id', testAccout.Id );    //取引先ID
            pageRef.getParameters().put('Districts', '港区' );    //地区
            Test.setCurrentPage(pageRef);
            
            //コンストラクタ起動
            GD701002Controller testReecord = new GD701002Controller();
            

            
            //表示ボタン押下
            testReecord.buildingIndex = 0;
            testReecord.displayProperty();
            
            //建物次ページ表示
            testReecord.selectBuildingPageIndex = '1';
            testReecord.selectBuildingPage();
        }
    }
    
    //初期表示テスト(パラメータ.地区なし)
    @isTest
    private static void allDistrictsInitializeTest() {
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD701002Test@horaguchi.com'];
        system.runas(userRecord){
            //取引先レコード取得
            Account testAccout = [SELECT Id, SystemModStamp FROM Account WHERE Name = 'オルソン株式会社'];
            
            //パラメータ設定
            PageReference pageRef = Page.GD701002View;
            pageRef.getParameters().put('Id',testAccout.Id );
            Test.setCurrentPage(pageRef);
            
            //コンストラクタ起動
            GD701002Controller testReecord = new GD701002Controller();
            
        }
    }
    
    //初期表示テスト(パラメータ.取引先ID不正)
    @isTest
    private static void initializeErrorTest() {
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD701002Test@horaguchi.com'];
        system.runas(userRecord){
            //取引先レコード取得
            Account testAccout = [SELECT Id, SystemModStamp FROM Account WHERE Name = 'オルソン株式会社'];
            
            //パラメータ設定
            PageReference pageRef = Page.GD701002View;
            pageRef.getParameters().put('Id', 'a0V0T000010C2tLUAS' );    //取引先ID
            pageRef.getParameters().put('Districts', '港区' );    //地区
            Test.setCurrentPage(pageRef);
            
            //コンストラクタ起動
            GD701002Controller testReecord = new GD701002Controller();
            
            //レコード情報が取得できないときのエラー出てる？
            List<ApexPages.Message> messages = ApexPages.getMessages();
            System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_PROP_E_INPUT_ACCOUNT_NOTHING, 'a0V0T000010C2tLUAS')), messages[0]);
        }
    }

    // 一括物件更新ボタンテスト
    @isTest
    private static void clickBulkUpdateResidentTest() {

        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD701002Test@horaguchi.com'];
        system.runas(userRecord){
            Account account = [SELECT ID
                               FROM Account
                               WHERE Name = 'オルソン株式会社'];

            // 初期表示
            PageReference pageRef = Page.GD701002View;
            pageRef.getParameters().put('Id', account.Id );
            pageRef.getParameters().put('Districts', '港区' );
            Test.setCurrentPage(pageRef);

            // 表示ボタン押下
            GD701002Controller testRecord = new GD701002Controller();
            testRecord.selectBuildingId = testRecord.targetDisplayBuildingList[0].buildingItem.Id;
            testRecord.displayProperty();

            // 一括物件更新ボタンテスト
            testRecord.displayPropertyList[1].IsSelected = true;
            testRecord.clickBulkUpdateResident();
        }
    }
    
    // 一括で居住中に変更ボタンテスト
    @isTest
    private static void clickBulkUpdatePropertyTest() {

        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD701002Test@horaguchi.com'];
        system.runas(userRecord){
            Account account = [SELECT ID
                               FROM Account
                               WHERE Name = 'オルソン株式会社'];

            // 初期表示
            PageReference pageRef = Page.GD701002View;
            pageRef.getParameters().put('Id', account.Id );
            pageRef.getParameters().put('Districts', '港区' );
            Test.setCurrentPage(pageRef);

            // 表示ボタン押下
            GD701002Controller testRecord = new GD701002Controller();
            testRecord.selectBuildingId = testRecord.targetDisplayBuildingList[0].buildingItem.Id;
            testRecord.displayProperty();

            // 一括で居住中に変更ボタン押下
            testRecord.displayPropertyList[1].IsSelected = true;
            testRecord.clickBulkUpdateProperty();
        }
    }
    
    // Apexプロパティテスト
    @isTest
    private static void apexPropertyTest() {
        // プロパティを呼び出し
        GD701002Controller testRecord = new GD701002Controller();
        String getVal = testRecord.MSG_CONFIRM_SAVE_BULK_PROP;
        getVal = testRecord.MSG_CONFIRM_SAVE_BULK_RESIDENT;
        getVal = testRecord.MSG_SAVE;
        getVal = testRecord.MSG_ERR_NO_SELECTED;
        getVal = testRecord.MSG_ERR_UPD_LIMIT_OVER;
    }

	/**
	 * 手動メンテ一覧
	 * 一括で居住中に変更
	 * 建物物件差分が作成されず、日報の手動メンテ数が加算されること
	 */
	@isTest
	private static void clickBulkUpdatePropertyManualMaintainTest() {
		// Id={!accountRecordList[AccountIndex].Id}&Districts={!SearchDistricts}'

		User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD701002Test@horaguchi.com'];
		system.runas(userRecord){
			Account account = [SELECT ID
							FROM Account
							WHERE Name = 'オルソン株式会社'];
			Test.startTest();
			// 初期表示
			PageReference pageRef = Page.GD701002View;
			pageRef.getParameters().put('Id', account.Id );
			pageRef.getParameters().put('Districts',null );
			Test.setCurrentPage(pageRef);

			// 表示ボタン押下
			GD701002Controller testRecord = new GD701002Controller();
			testRecord.selectBuildingId = testRecord.targetDisplayBuildingList[0].buildingItem.Id;
			testRecord.displayProperty();

			// 一括で居住中に変更ボタン押下
			testRecord.displayPropertyList[0].IsSelected = true;
			testRecord.displayPropertyList[1].IsSelected = true;
			testRecord.clickBulkUpdateResident();
			Test.stopTest();

			// 建物物件差分が0件
			List<BuildingPropertyDifference__c> BuildingPropertyDifferenceList = new List<BuildingPropertyDifference__c>([SELECT Id, OwnCompanyManageModDate__c,PropertyId__c FROM BuildingPropertyDifference__c]);
			System.assertEquals(0,BuildingPropertyDifferenceList.size());

			// 日報にて 手動メンテ数の加算を確認
			DailyReport__c DailyReport = [SELECT Id,ManualMaintenanceCount__c FROM DailyReport__c WHERE Staff__c = :userRecord.id LIMIT 1];
			System.assertEquals(1,DailyReport.ManualMaintenanceCount__c);
		}
	}

	/**
	 * 手動メンテ一覧
	 * 一括物件更新
	 * 建物物件差分に最新の自社管理修正日がセットされ、日報の手動メンテ数が加算されること
	 */
	@isTest
	private static void clickBulkUpdateResidentManualMaintainTest() {
		User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD701002Test@horaguchi.com'];
		system.runas(userRecord){
			Account account = [SELECT ID
							FROM Account
							WHERE Name = 'オルソン株式会社'];
			Test.startTest();
			// 初期表示
			PageReference pageRef = Page.GD701002View;
			pageRef.getParameters().put('Id', account.Id );
			pageRef.getParameters().put('Districts', null );
			Test.setCurrentPage(pageRef);

			// 表示ボタン押下
			GD701002Controller testRecord = new GD701002Controller();
			testRecord.selectBuildingId = testRecord.targetDisplayBuildingList[0].buildingItem.Id;
			testRecord.displayProperty();

			// 一括物件更新ボタンテスト
			testRecord.displayPropertyList[0].IsSelected = true;
			testRecord.displayPropertyList[1].IsSelected = true;
			testRecord.clickBulkUpdateProperty();
			Test.stopTest();

			// 建物物件差分の自社管理修正日が物件更新後の自社管理修正日と一致
			Map<Id,Property__c> PropertyMap = new Map<Id,Property__c>([SELECT Id, OwnCompanyManageModDate__c FROM Property__c]);
			List<BuildingPropertyDifference__c> BuildingPropertyDifferenceList = new List<BuildingPropertyDifference__c>([SELECT Id, OwnCompanyManageModDate__c,PropertyId__c FROM BuildingPropertyDifference__c]);
			for (BuildingPropertyDifference__c BuildingPropertyDifference : BuildingPropertyDifferenceList) {
				if(PropertyMap.containsKey(BuildingPropertyDifference.PropertyId__c)){
					System.assertEquals(PropertyMap.get(BuildingPropertyDifference.PropertyId__c).OwnCompanyManageModDate__c,BuildingPropertyDifference.OwnCompanyManageModDate__c);
				}
			}
			// 日報にて 手動メンテ数の加算を確認
			DailyReport__c DailyReport = [SELECT Id,ManualMaintenanceCount__c FROM DailyReport__c WHERE Staff__c = :userRecord.id LIMIT 1];
			System.assertEquals(1,DailyReport.ManualMaintenanceCount__c);
		}	
	}
	/**
	 * 電物メンテ一覧（遷移元の違いで特にパラメータはありませんが念のため記載）
	 * 一括で居住中に変更
	 * 建物物件差分が作成されず、日報の手動メンテ数が加算されること
	 */
	@isTest
	private static void clickBulkUpdatePropertyElectricalMaintainTest() {
		// Id={!screenRecordClassList[AccountIndex].targetAccountRecord.Id}&Districts={!SearchDistricts}

		User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD701002Test@horaguchi.com'];
		system.runas(userRecord){
			Account account = [SELECT ID
							FROM Account
							WHERE Name = 'オルソン株式会社'];
			Test.startTest();
			// 初期表示
			PageReference pageRef = Page.GD701002View;
			pageRef.getParameters().put('Id', account.Id );
			pageRef.getParameters().put('Districts', '港区' );
			Test.setCurrentPage(pageRef);

			// 表示ボタン押下
			GD701002Controller testRecord = new GD701002Controller();
			testRecord.selectBuildingId = testRecord.targetDisplayBuildingList[0].buildingItem.Id;
			testRecord.displayProperty();

			// 一括で居住中に変更ボタン押下
			testRecord.displayPropertyList[0].IsSelected = true;
			testRecord.displayPropertyList[1].IsSelected = true;
			testRecord.clickBulkUpdateResident();
			Test.stopTest();

			// 建物物件差分が0件
			List<BuildingPropertyDifference__c> BuildingPropertyDifferenceList = new List<BuildingPropertyDifference__c>([SELECT Id, OwnCompanyManageModDate__c,PropertyId__c FROM BuildingPropertyDifference__c]);
			System.assertEquals(0,BuildingPropertyDifferenceList.size());

			// 日報にて 手動メンテ数の加算を確認
			DailyReport__c DailyReport = [SELECT Id,ManualMaintenanceCount__c FROM DailyReport__c WHERE Staff__c = :userRecord.id LIMIT 1];
			System.assertEquals(1,DailyReport.ManualMaintenanceCount__c);
		}
	}
	/**
	 * 電物メンテ一覧（遷移元の違いで特にパラメータはありませんが念のため記載）
	 * 一括物件更新
	 * 建物物件差分に最新の自社管理修正日がセットされ、日報の手動メンテ数が加算されること
	 */
	@isTest
	private static void clickBulkUpdateResidentElectricalMaintainTest() {
		User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD701002Test@horaguchi.com'];
		system.runas(userRecord){
			Account account = [SELECT ID
							FROM Account
							WHERE Name = 'オルソン株式会社'];
			Test.startTest();
			// 初期表示
			PageReference pageRef = Page.GD701002View;
			pageRef.getParameters().put('Id', account.Id );
			pageRef.getParameters().put('Districts', '港区' );
			Test.setCurrentPage(pageRef);

			// 表示ボタン押下
			GD701002Controller testRecord = new GD701002Controller();
			testRecord.selectBuildingId = testRecord.targetDisplayBuildingList[0].buildingItem.Id;
			testRecord.displayProperty();

			// 一括物件更新ボタンテスト
			testRecord.displayPropertyList[0].IsSelected = true;
			testRecord.displayPropertyList[1].IsSelected = true;
			testRecord.clickBulkUpdateProperty();
			Test.stopTest();

			// 建物物件差分の自社管理修正日が物件更新後の自社管理修正日と一致
			Map<Id,Property__c> PropertyMap = new Map<Id,Property__c>([SELECT Id, OwnCompanyManageModDate__c FROM Property__c]);
			List<BuildingPropertyDifference__c> BuildingPropertyDifferenceList = new List<BuildingPropertyDifference__c>([SELECT Id, OwnCompanyManageModDate__c,PropertyId__c FROM BuildingPropertyDifference__c]);
			for (BuildingPropertyDifference__c BuildingPropertyDifference : BuildingPropertyDifferenceList) {
				if(PropertyMap.containsKey(BuildingPropertyDifference.PropertyId__c)){
					System.assertEquals(PropertyMap.get(BuildingPropertyDifference.PropertyId__c).OwnCompanyManageModDate__c,BuildingPropertyDifference.OwnCompanyManageModDate__c);
				}
			}
			// 日報にて 手動メンテ数の加算を確認
			DailyReport__c DailyReport = [SELECT Id,ManualMaintenanceCount__c FROM DailyReport__c WHERE Staff__c = :userRecord.id LIMIT 1];
			System.assertEquals(1,DailyReport.ManualMaintenanceCount__c);
		}
	}
    @isTest
    private static void ownCompanyManageModDatelTest1() {

        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD701002Test@horaguchi.com'];
        system.runas(userRecord){
            Account account = [SELECT ID
                               FROM Account
                               WHERE Name = 'オルソン株式会社'];
            
            //自社管理修正日をセット
            Property__c prop =  [SELECT Id,name,OwnCompanyManageModDate__c
                                FROM Property__c
                                WHERE Name ='1'];
            prop.OwnCompanyManageModDate__c = Date.newInstance(2022, 04, 19);
            update prop;

            // 初期表示
            PageReference pageRef = Page.GD701002View;
            pageRef.getParameters().put('Id', account.Id );
            pageRef.getParameters().put('Districts', '港区' );

            Test.startTest();
            Test.setCurrentPage(pageRef);
            GD701002Controller testRecord = new GD701002Controller();
            testRecord.selectBuildingId = testRecord.targetDisplayBuildingList[0].buildingItem.Id;
            // 表示ボタン押下
            testRecord.displayProperty();
            Test.stopTest();

            Datetime testDatetime = Datetime.newInstance(2022, 04, 19).addHours(9);
            //結果確認
            //画面上に表示されている自社管理修正日の値がレコードと一致していること
            system.assertEquals(testRecord.displayPropertyList[0].OwnCompanyManageModDate.date(), testDatetime.date());
        }
    }

    @isTest
    private static void ownCompanyManageModDatelTest2() {

        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD701002Test@horaguchi.com'];
        system.runas(userRecord){
            Account account = [SELECT ID
                               FROM Account
                               WHERE Name = 'オルソン株式会社'];
            
            Property__c prop =  [SELECT Id,name,OwnCompanyManageModDate__c
                                FROM Property__c
                                WHERE Name ='1'];
            prop.OwnCompanyManageModDate__c = Date.newInstance(2022, 04, 19);
            update prop;

            // 初期表示
            PageReference pageRef = Page.GD701002View;
            pageRef.getParameters().put('Id', account.Id );
            pageRef.getParameters().put('Districts', '港区' );

            Test.startTest();
            Test.setCurrentPage(pageRef);
            GD701002Controller testRecord = new GD701002Controller();
            testRecord.selectBuildingId = testRecord.targetDisplayBuildingList[0].buildingItem.Id;
            // 表示ボタン押下
            testRecord.displayProperty();
            // 一括更新ボタン押下
            testRecord.displayPropertyList[0].IsSelected = true;
			testRecord.clickBulkUpdateProperty();
            Test.stopTest();
            
            DateTime sysDate = CommonUtil.getNow();
            //結果確認
            //自社管理修正日が一括更新ボタン押下した日付と一致していること
            system.assertEquals(testRecord.displayPropertyList[0].OwnCompanyManageModDate.date(), sysDate.date());
        }
    }
}