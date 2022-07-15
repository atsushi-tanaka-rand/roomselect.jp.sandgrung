/**
* 電物メンテ一覧画面のテスト
*/
@isTest
private class GD701007Test {
    // テストに使用するレコードを作成する
    @TestSetup static void setting(){
        SystemConfig__c s = new SystemConfig__c(DembutsuLimit__c = 1000);
        insert s;
        
        //取引先レコード（元付業者）
        Account accountRecord = new Account(RecordTypeId = CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_SUPPLIER),
                                            Name = 'オルソン株式会社' ,
                                            Phone = '111-1111-1111' ,
                                            Representative__c = 'オルソン担当者',
                                            RepresentativePhone__c = '222-2222-2222',
                                            DembutsuStatus__c = '○',
                                            DembutsuDate__c = Date.newInstance(2019, 12, 31),
                                            DembutsuStaff__c = 'テスト電物担当者',
                                            IppamGyobutsu__c = '一般物',
                                            DembutsuEventMemo__c = 'メモ：電物完了(仮)',
                                            FixedTermSend__c = '無');
        insert accountRecord;
        
        //建物レコード
        Building__c buildingRecord = new Building__c(District__c = '港区',
                                                     Name = 'テスト建物1' );
        insert buildingRecord;
        
        //物件レコード
        Property__c propertyRecord = new Property__c(Building__c = buildingRecord.Id,
                                                     Name = '1',
                                                     FormerSupplier__c = accountRecord.Id);
        insert propertyRecord;
        
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
        // 2021.02.18 Y.Hirata 再販対応：プロファイル名を”標準ユーザ”から”一般ユーザ”に変更
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name IN ('Standard User', '一般ユーザ')];
        System.assert(profiles.size() > 0);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            insert new User(
                UserName = 'GD701007Test@horaguchi.com',
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
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD701007Test@horaguchi.com'];
        ShopTransfer__c ShopTransferRecord = new ShopTransfer__c(OrgzanizationHierarchy__c = orgRecord2.id,
                                                                 Staff__c = userRecord.id,
                                                                 StartDate__c = Date.newInstance(2000, 12, 1),
                                                                 EndDate__c = Date.newInstance(2999, 12, 1)); 
        insert ShopTransferRecord;
        
    }
    
    // 初期表示テスト
    @isTest static void initializeTest() {
        
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD701007Test@horaguchi.com'];
        system.runas(userRecord){
            //コントローラ作成
            GD701007Controller testController = new GD701007Controller();
            //2020.05.07 地区の初期表示処理削除
            //地区が設定されている？
            //system.assertEquals(testController.Districts, '港区;北区');
            //元付業者検索ボックスが空？
            system.assertEquals(testController.FormerSupplier, '');
        }
        
    }
    
    // 検索テスト
    @isTest static void searchTest() {
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD701007Test@horaguchi.com'];
        system.runas(userRecord){
            //コントローラ作成
            GD701007Controller testController = new GD701007Controller();
            testController.Districts = '港区';
            testController.FormerSupplier = 'オルソン';
            testController.search();
            system.assertEquals(testController.screenRecordClassList[0].targetAccountRecord.Name, 'オルソン株式会社');
        }
    }
    
    // 検索テスト（検索結果0件）
    @isTest static void searchNoResultErrorTest() {
        User userRecord = [SELECT Id FROM User WHERE UserName = 'GD701007Test@horaguchi.com'];
        system.runas(userRecord){
            //コントローラ作成
            GD701007Controller testController = new GD701007Controller();
            testController.Districts = '港区';
            testController.FormerSupplier = '存在しない元付業者名';
            testController.search();
            
            List<ApexPages.Message> messages = ApexPages.getMessages();
            System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_NO_DATA)));
        }
    }
    
    // 保存テスト
    @isTest static void saveTest() {
        User userRecord = [SELECT Id FROM User WHERE UserName = 'GD701007Test@horaguchi.com'];
        system.runas(userRecord){
            
            //取引先レコード取得
            Account testAccount = [SELECT Id, SystemModStamp FROM Account WHERE Name = 'オルソン株式会社'];
            
            //コントローラ作成
            GD701007Controller testController = new GD701007Controller();
            testController.search();
            testController.Districts = '港区';
            testController.FormerSupplier = 'オルソン';
            testController.screenRecordClassList[0].dembutsuStatus = '×';
            testController.AccountIndex = 0;
            
            //スリープ
            CommonUtil.sleep(1000);
            
            //保存処理
            testController.recordSave();
            
            //保存後取引先レコード取得
            Account saveAccount = [SELECT Id, SystemModStamp FROM Account WHERE Id = :testAccount.Id];
            
            //更新日時確認
            system.assert(testAccount.systemModStamp != saveAccount.systemModStamp, 'errror:更新日時が変わっていない');
            
        }
    }
    
    // 保存テスト（楽観ロックチェックエラー）
    @isTest static void saveOptimisticLockErrorTest() {
        User userRecord = [SELECT Id FROM User WHERE UserName = 'GD701007Test@horaguchi.com'];
        system.runas(userRecord){
            
            //取引先レコード取得
            Account testAccount = [SELECT Id, SystemModStamp FROM Account WHERE Name = 'オルソン株式会社'];
            
            //コントローラ作成
            GD701007Controller testController = new GD701007Controller();
            testController.Districts = '港区';
            testController.search();            
            testController.FormerSupplier = 'オルソン';
            testController.screenRecordClassList[0].dembutsuStatus = '×';
            testController.AccountIndex = 0;
            
            //スリープ
            CommonUtil.sleep(1000);
            
            upsert testAccount;
            
            //スリープ
            CommonUtil.sleep(1000);
            
            //保存処理
            testController.recordSave();
            
            //楽観ロックチェックエラー？
            List<ApexPages.Message> messages = ApexPages.getMessages();
            System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK)), messages[0]);
        }
    }
    
    // カバレッジ率上昇
    @isTest static void forCoverage() {
        User userRecord = [SELECT Id FROM User WHERE UserName = 'GD701007Test@horaguchi.com'];
        system.runas(userRecord){
            
            //取引先レコード取得
            Account testAccount = [SELECT Id, SystemModStamp FROM Account WHERE Name = 'オルソン株式会社'];
            
            //コントローラ作成
            GD701007Controller testController = new GD701007Controller();
            
            //カバレッジ率上昇
            testController.Districts = '港区';
            testController.openModal();
            testController.closeModal();
            String a;
            a = testController.MSG_COM_V_SAVE;
            a = testController.MSG_COM_I_SAVE;
            
            
        }
    }
}