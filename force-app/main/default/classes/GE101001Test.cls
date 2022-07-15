/**
 * 業務日報のテストクラス
 */
@isTest 
private class GE101001Test {

    
    // 業務日報テストデータ作成
    static DailyReport__c createDailyReport(Date reportDate, Id userId, Id shopId) {

        DailyReport__c dailyReport = new DailyReport__c();

        dailyReport.ReportDate__c = reportDate;
        dailyReport.Staff__c = userId;
        dailyReport.Shop__c = shopId;

        insert dailyReport;

        dailyReport = [SELECT ID FROM DailyReport__c WHERE ReportDate__c = :reportDate];

        return dailyReport;
    }	
    
    // 店舗テストデータ作成
    static List<Shop__c> createShop(String name) {

        Shop__c shop = new Shop__c();

        shop.Name = name;

        insert shop;

        List<Shop__c> shopList = [SELECT ID, NAME FROM Shop__c WHERE NAME = :name];

        return shopList;
    }	

    // 組織階層テストデータ作成
    static List<OrganizationHierarchy__c> createOrganizationHierarchy(String shopID) {
        OrganizationHierarchy__c org = new OrganizationHierarchy__c();
        org.OrganizationCode__c = '0002';
        org.OrganizationName__c = 'テスト店舗';
        org.HierarchyCode__c = '20';
        org.HierarchyOrder__c = 1;
        org.ExpandedOrganizationCode__c = '0000_0001_0002';
        org.Shop__c = shopID;
        insert org;

        //
        List<OrganizationHierarchy__c> orgList = [SELECT ID, NAME FROM OrganizationHierarchy__c WHERE OrganizationCode__c = '0002'];
        return orgList;
    }

    // 店舗異動テストデータ作成
    static List<ShopTransfer__c> createShopTransfer(String orgID) {

        ShopTransfer__c shopTransfer = new ShopTransfer__c();

        shopTransfer.OrgzanizationHierarchy__c = orgID;
        shopTransfer.Staff__c = UserInfo.getUserId();
        shopTransfer.StartDate__c = CommonUtil.getToday();
        shopTransfer.EndDate__c = CommonUtil.getToday();

        insert shopTransfer;

        List<ShopTransfer__c> shopTransferList = [SELECT ID, NAME, OrgzanizationHierarchy__c, Staff__c, StartDate__c,EndDate__c  FROM ShopTransfer__c WHERE OrgzanizationHierarchy__c = :orgID];

        return shopTransferList;
    }	


	//初期表示テスト
     @isTest static void initializeNotFoundTest(){

        Id createShopId = createShop('テスト店舗')[0].ID;
        Id createOrgId = createOrganizationHierarchy(createShopId)[0].ID;
        createShopTransfer(createOrgId);
        
        // コントローラの初期表示を実行
        GE101001Controller GE101001Controller = new GE101001Controller();

        system.assertEquals(GE101001Controller.dailyReport.Id, null);
        system.assertEquals(GE101001Controller.dailyReport.ReportDate__c, CommonUtil.getToday());
        system.assertEquals(GE101001Controller.dailyReport.Staff__c, UserInfo.getUserId());

    }	

	//初期表示テスト
     @isTest static void initializeTest(){

        Id createShopId = createShop('テスト店舗')[0].ID;
        Id createOrgId = createOrganizationHierarchy(createShopId)[0].ID;
        createShopTransfer(createOrgId);

        DailyReport__c testDailyReport = new DailyReport__c();

        testDailyReport = createDailyReport(CommonUtil.getToday(), UserInfo.getUserId() ,createShopId);

        // コントローラの初期表示を実行
        GE101001Controller GE101001Controller = new GE101001Controller();

        system.assertEquals(GE101001Controller.dailyReport.Id, testDailyReport.Id);

    }	

	//選択(共通)テスト
     @isTest static void setSelectDailyReportTest(){
         
        Id createShopId = createShop('テスト店舗')[0].ID;
        Id createOrgId = createOrganizationHierarchy(createShopId)[0].ID;
        createShopTransfer(createOrgId);

        DailyReport__c testDailyReport = new DailyReport__c();

        createDailyReport(CommonUtil.getToday(), UserInfo.getUserId(), createShopId);
        testDailyReport = createDailyReport(CommonUtil.getToday().addDays(-1), UserInfo.getUserId(),createShopId);

        // コントローラの初期表示を実行
        GE101001Controller GE101001Controller = new GE101001Controller();

        GE101001Controller.selectDailyReportIndex = 1;

        GE101001Controller.setSelectDailyReport();

        system.assertEquals(GE101001Controller.dailyReport.Id, testDailyReport.Id);

    }	

	//登録（共通）
     @isTest static void saveTest(){
         
        Id createShopId = createShop('テスト店舗')[0].ID;
        Id createOrgId = createOrganizationHierarchy(createShopId)[0].ID;
        createShopTransfer(createOrgId);

        DailyReport__c testDailyReport = new DailyReport__c();

        testDailyReport = createDailyReport(CommonUtil.getToday(), UserInfo.getUserId(), createShopId);

        // コントローラの初期表示を実行
        GE101001Controller GE101001Controller = new GE101001Controller();

        GE101001Controller.addPropertyConfirmation = '1';
        GE101001Controller.addPropertyResearch = '1';

        GE101001Controller.save();

        system.assertEquals(GE101001Controller.dailyReport.Id, testDailyReport.Id);
        system.assertEquals(GE101001Controller.dailyReport.PropertyConfirmation__c, 1);
        system.assertEquals(GE101001Controller.dailyReport.PropertyResearch__c, 1);

    }	

	//エラー発生時：登録（共通）
     @isTest static void inputErrorTest(){
         
        Id createShopId = createShop('テスト店舗')[0].ID;
        Id createOrgId = createOrganizationHierarchy(createShopId)[0].ID;
        createShopTransfer(createOrgId);

        DailyReport__c testDailyReport = new DailyReport__c();

        testDailyReport = createDailyReport(CommonUtil.getToday(), UserInfo.getUserId(), createShopId);

        // コントローラの初期表示を実行
        GE101001Controller GE101001Controller = new GE101001Controller();

        GE101001Controller.save();

        //「エラーフラグ」がTRUEに設定されている
        system.assertEquals(GE101001Controller.hasErrorMessage, TRUE);
        
        List<String> requiredItem = new List<String>();
        requiredItem.add('物確（+：増／-：減）と物調（+：増／-：減）のどちらかに');
        

        //「エラーメッセージ」が正しく設定されている
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ',')));

    }	

	//エラー発生時：登録（共通）
     @isTest static void addPropertyConfirmationOutOfRangeErrorTest(){
         
        Id createShopId = createShop('テスト店舗')[0].ID;
        Id createOrgId = createOrganizationHierarchy(createShopId)[0].ID;
        createShopTransfer(createOrgId);

        DailyReport__c testDailyReport = new DailyReport__c();

        testDailyReport = createDailyReport(CommonUtil.getToday(), UserInfo.getUserId(), createShopId);

        // コントローラの初期表示を実行
        GE101001Controller GE101001Controller = new GE101001Controller();

        GE101001Controller.addPropertyConfirmation = '1000';

        GE101001Controller.save();

        //「エラーフラグ」がTRUEに設定されている
        system.assertEquals(GE101001Controller.hasErrorMessage, TRUE);
        
        List<Object> parameters = new List<Object> {'物確' , '0', '999'};

        //「エラーメッセージ」が正しく設定されている
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(String.format(CommonConst.MSG_COM_E_REGISTRATION_COUNT_RANGE, parameters)));

    }	

	//エラー発生時：登録（共通）
     @isTest static void addPropertyResearchOutOfRangeErrorTest(){
         
        Id createShopId = createShop('テスト店舗')[0].ID;
        Id createOrgId = createOrganizationHierarchy(createShopId)[0].ID;
        createShopTransfer(createOrgId);

        DailyReport__c testDailyReport = new DailyReport__c();

        testDailyReport = createDailyReport(CommonUtil.getToday(), UserInfo.getUserId(), createShopId);

        // コントローラの初期表示を実行
        GE101001Controller GE101001Controller = new GE101001Controller();

        GE101001Controller.addPropertyResearch = '1000';

        GE101001Controller.save();

        //「エラーフラグ」がTRUEに設定されている
        system.assertEquals(GE101001Controller.hasErrorMessage, TRUE);
        
        List<Object> parameters = new List<Object> {'物調' , '0', '999'};

        //「エラーメッセージ」が正しく設定されている
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(String.format(CommonConst.MSG_COM_E_REGISTRATION_COUNT_RANGE, parameters)));

    }	

	//エラー発生時：登録（共通）
     @isTest static void optimisticLockErrorTest(){
         
        Id createShopId = createShop('テスト店舗')[0].ID;
        Id createOrgId = createOrganizationHierarchy(createShopId)[0].ID;
        createShopTransfer(createOrgId);

        DailyReport__c testDailyReport = new DailyReport__c();

        testDailyReport = createDailyReport(CommonUtil.getToday(), UserInfo.getUserId(), createShopId);

        // コントローラの初期表示を実行
        GE101001Controller GE101001Controller = new GE101001Controller();

        CommonUtil.sleep(1000);

        update testDailyReport;

        GE101001Controller.addPropertyConfirmation = '1';
        GE101001Controller.addPropertyResearch = '1';

        GE101001Controller.save();

        //「エラーフラグ」がTRUEに設定されている
        system.assertEquals(GE101001Controller.hasErrorMessage, TRUE);
        //「エラーメッセージ」が正しく設定されている
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK));

    }	
}