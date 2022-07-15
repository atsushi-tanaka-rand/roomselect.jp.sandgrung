//来店受付メンテナンスバッチ　テストクラス
@isTest 
private class BK101003BatchTest {   
    //テストに使用するレコードを作成する
    @testSetup static void Setting(){

        //データ作成　システム設定 バッチサイズ
        SystemConfig__c sysconf = new SystemConfig__c(
            AppointmentReceiptBatchSize__c = 200,
            PortalManagementCalendar__c = 'HP来店予約管理',
            AppointmentReceiptStartTime__c = '1000',
            AppointmentReceiptEndTime30minAgo__c = '2100'
        );
        insert sysconf;

        //店舗レコード
        Shop__c shopRecord = new shop__c(Name = 'テス店舗',
        PortalSitePostingDistrict__c = '港区;北区',
        IsShopType__c = true ,
        SystemUseStartDate__c = Date.newInstance(2000, 12, 1),
        SystemUseEndDate__c = Date.newInstance(2999, 12, 1)
        );
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
        UserName = 'BK101003Test@horaguchi.com',
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
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'BK101003Test@horaguchi.com'];
        ShopTransfer__c ShopTransferRecord = new ShopTransfer__c(OrgzanizationHierarchy__c = orgRecord2.id,
                                                Staff__c = userRecord.id,
                                                StartDate__c = Date.newInstance(2000, 12, 1),
                                                EndDate__c = Date.newInstance(2999, 12, 1)); 
        insert ShopTransferRecord;
        //来店受付
        AppointmentReceiptStoreDate__c arsd = new AppointmentReceiptStoreDate__c(
                PeopleLimit__c = 2,
                TargetDate__c = CommonUtil.getToday(),
                Shop__c = shopRecord.Id,
                ProcessingFlg__c = true
            );
        insert arsd;
    }
    
    @isTest static void successTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'BK101003Test@horaguchi.com'];
        system.runas(userRecord){

            //バッチ実行
            BK101003Batch b = new BK101003Batch();
            Integer BATCH_SIZE = SystemConfig__c.getInstance().AppointmentReceiptBatchSize__c.intValue(); //バッチサイズ
            Database.executeBatch(b, BATCH_SIZE);

        }
    }

    @isTest static void success2Test(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'BK101003Test@horaguchi.com'];
        system.runas(userRecord){

            //バッチ実行
            BK101003Batch2 b = new BK101003Batch2();
            Integer BATCH_SIZE = SystemConfig__c.getInstance().AppointmentReceiptBatchSize__c.intValue(); //バッチサイズ
            Database.executeBatch(b, BATCH_SIZE);

        }
    }
}