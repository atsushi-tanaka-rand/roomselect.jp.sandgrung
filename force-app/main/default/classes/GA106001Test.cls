/**
* 指定メール一覧画面のテスト
*/
@isTest 
private class GA106001Test{
    
    //テストに使用するレコードを作成する
    @testSetup static void Setting(){
        //システム設定を作成
        SystemConfig__c s = new SystemConfig__c(
             SpecifiedMail_InitSearchMaxCount__c = 100
            , SpecifiedMail_NormalSearchMaxCount__c=1000
            );
        insert s;
        
        
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
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name IN ('一般ユーザ')];
        System.assert(profiles.size() > 0);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            insert new User(
                UserName = 'GA106001Test@horaguchi.com',
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
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GA106001Test@horaguchi.com'];
        ShopTransfer__c ShopTransferRecord = new ShopTransfer__c(OrgzanizationHierarchy__c = orgRecord2.id,
                                                                 Staff__c = userRecord.id,
                                                                 StartDate__c = Date.newInstance(2000, 12, 1),
                                                                 EndDate__c = Date.newInstance(2999, 12, 1)); 
        insert ShopTransferRecord;

        //指定メール設定
        insert new SpecifiedMailSetting__c(Folder__c = 'testFolder');

        //反響メール
        insert new EchoMail__c(IsSpecifiedMail__c = true, SpecifiedMailfolder__c = 'testFolder');
    }
    
    //明細選択テスト	
    @isTest static void selectTest(){
        
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GA106001Test@horaguchi.com'];
        system.runas(userRecord){

            //コントローラ作成
            GA106001Controller testController = new GA106001Controller();

            //検索
            testController.search();

            //選択 選択された明細はIdを返却しているので、Idが必要
            EchoMail__c selectedEchoMail = [SELECT id from EchoMail__c limit 1];
            testController.selectedEchoMailId = selectedEchoMail.Id;
            testController.selectItem();

        }
        
    }
    
    //検索エラーテスト	
    @isTest static void searchErrorTest(){
        
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GA106001Test@horaguchi.com'];
        system.runas(userRecord){

            //コントローラ作成
            GA106001Controller testController = new GA106001Controller();

            //検索条件入力
            testController.receivedDate = System.Today();
            testController.folderName   = 'testFolder';
            testController.fromAddress  = 'a';
            testController.toAddress    = 'a';
            testController.subject      = 'a';

            //検索（結果が０なので画面にエラーが出ているはず）
            testController.search();

        }
        
    }
    
}