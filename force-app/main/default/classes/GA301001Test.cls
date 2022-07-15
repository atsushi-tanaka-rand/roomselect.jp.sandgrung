/* *
 * メール送信保留一覧のテスト
 */
@isTest 
private class GA301001Test {

    // 店舗テストデータ作成
    static List<Shop__c> createShop(String name) {
        Shop__c shop = new Shop__c();
        shop.Name = name;
        insert shop;

        //
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

    // メール下書きテストデータ作成
    static List<MailDraft__c> createMailDraft(String name, String shopID) {

        MailDraft__c mailDraft = new MailDraft__c();

        mailDraft.Name = name;
        mailDraft.Shop__c = shopID;
        mailDraft.Subject__c = name;

        insert mailDraft;

        List<MailDraft__c> mailDraftList = [SELECT ID, NAME, Shop__c FROM MailDraft__c WHERE NAME = :name];

        return mailDraftList;
    }	

    // メール時間指定送信テストデータ作成
    static List<MailTimeSpecificationSending__c> createMailTimeSpecificationSending(String name, String shopID) {

        MailTimeSpecificationSending__c mailTimeSpecificationSending = new MailTimeSpecificationSending__c();

        mailTimeSpecificationSending.Name = name;
        mailTimeSpecificationSending.Shop__c = shopID;
        mailTimeSpecificationSending.Subject__c = name;

        insert mailTimeSpecificationSending;

        List<MailTimeSpecificationSending__c> mailTimeSpecificationSendingList = [SELECT ID, NAME, Shop__c FROM MailTimeSpecificationSending__c WHERE NAME = :name];

        return mailTimeSpecificationSendingList;
    }	

	//画面表示（初期表示・共通）
     @isTest static void inintializeTest(){

        List<Shop__c> shop = createShop('inintializeTest');

        system.debug('shop' + shop );

        List<OrganizationHierarchy__c> org = createOrganizationHierarchy(shop[0].ID);

        List<ShopTransfer__c> shopTransfer = createShopTransfer(org[0].ID); 

        system.debug('shopTransfer' + shopTransfer );

        // コントローラの初期表示を実行
        GA301001Controller GA301001Controller = new GA301001Controller();

        system.assertEquals(shop[0].Id, GA301001Controller.searchShopId);

    }	

	//検索ボタン
     @isTest static void searchMailTest(){

        List<Shop__c> shop = createShop('searchMailTest');

        system.debug('shop' + shop );

        List<OrganizationHierarchy__c> org = createOrganizationHierarchy(shop[0].ID);

        List<ShopTransfer__c> shopTransfer = createShopTransfer(org[0].ID); 

        system.debug('shopTransfer' + shopTransfer );

        List<MailDraft__c> mailDraft = createMailDraft('メール下書きテスト', shop[0].ID);

        system.debug('mailDraft' + mailDraft );

        List<MailTimeSpecificationSending__c> mailTimeSpecificationSending = createMailTimeSpecificationSending('メール時間指定送信テスト', shop[0].ID);
        
        system.debug('mailTimeSpecificationSending' + mailTimeSpecificationSending );

        // コントローラの初期表示を実行
        GA301001Controller GA301001Controller = new GA301001Controller();

        GA301001Controller.searchMail();

        system.assertEquals(mailDraft[0].ID, GA301001Controller.mailDraftList[0].ID);
        system.assertEquals(mailTimeSpecificationSending[0].ID, GA301001Controller.mailTimeSpecificationSendingList[0].ID);

    }	

	//画面表示（初期表示・共通）：ユーザ店舗取得エラー
     @isTest static void inintializeErrorTest(){

        // コントローラの初期表示を実行
        GA301001Controller GA301001Controller = new GA301001Controller();


        //「エラーフラグ」がTRUEに設定されている？
        system.assertEquals(GA301001Controller.isOpenError, TRUE);

        //「エラーメッセージ」が正しく設定されている？
        //system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonConst.MSG_COM_E_GET_AFFILIATION_SHOP);


    }	

	//検索ボタン：検索結果エラー
     @isTest static void searchMailErrorTest(){

        List<Shop__c> shop = createShop('searchMailErrorTest');

        system.debug('shop' + shop );
    
        List<OrganizationHierarchy__c> org = createOrganizationHierarchy(shop[0].ID);

        List<ShopTransfer__c> shopTransfer = createShopTransfer(org[0].ID); 

        system.debug('shopTransfer' + shopTransfer );

        // コントローラの初期表示を実行
        GA301001Controller GA301001Controller = new GA301001Controller();

        GA301001Controller.searchMail();

        //「エラーフラグ」がTRUEに設定されている？
        system.assertEquals(GA301001Controller.hasErrorMessage, TRUE);

        //「エラーメッセージ」が正しく設定されている？
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonConst.MSG_COM_W_SEARCH_NO_DATA);

    }	

}