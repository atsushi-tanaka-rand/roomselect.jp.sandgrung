/* *
 * HP会員一覧
 */
@isTest 
private class GK101001Test {
    //テストに使用するレコードを作成する
    @testSetup static void Setting(){
        // カスタム設定
        SystemConfig__c testSystemConfig = new SystemConfig__c();
        testSystemConfig.UseAuthority_Portal__c = true;
        insert testSystemConfig;

        
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
                UserName = 'GK101001Test@horaguchi.com',
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
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GK101001Test@horaguchi.com'];
        ShopTransfer__c ShopTransferRecord = new ShopTransfer__c(OrgzanizationHierarchy__c = orgRecord2.id,
                                                                    Staff__c = userRecord.id,
                                                                    StartDate__c = Date.newInstance(2000, 12, 1),
                                                                    EndDate__c = Date.newInstance(2999, 12, 1)); 
        insert ShopTransferRecord;

        //本会員作成
        insert new Member__c[]{new Member__c(MemberId__c = 'ichi',
                                              LastName__c = '一子',
                                              FirstName__c = '一山',
                                              LastNameKana__c = 'イチコ',
                                              FirstNameKana__c = 'イチヤマ',
                                              Tell__c = '111-1111',
                                              Email__c = 'email1@mail.com',
                                              Password__c = 'ichiyama',
                                              Birthdate__c = Date.newInstance(1995,1,1),
                                              Gender__c = '女性',
                                              Blacklist__c = false,
                                              JoinDate__c = Date.newInstance(2020,1,1),
                                              MemberStatus__c = '入会'),
                                new Member__c(MemberId__c = 'ni',
                                              LastName__c = '二郎',
                                              FirstName__c = '二山',
                                              LastNameKana__c = 'ジロウ',
                                              FirstNameKana__c = 'ニヤマ',
                                              Tell__c = '222-2222',
                                              Email__c = 'email2@mail.com',
                                              Password__c = 'niyama',
                                              Birthdate__c = Date.newInstance(1995,1,1),
                                              Gender__c = '男性',
                                              Blacklist__c = false,
                                              JoinDate__c = Date.newInstance(2020,1,1),
                                              QuitDate__c =  Date.newInstance(2020,2,1),
                                              MemberStatus__c = '退会')};
    }


    //検索テスト	
    @isTest static void searchTest(){
    
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GK101001Test@horaguchi.com'];
        system.runas(userRecord){

            //コントローラ作成
            GK101001Controller testController = new GK101001Controller();
            testController.MemberStatusRadioButton = '退会';
            testController.searchMemberId = 'email2@mail.com';
            testController.searchName = '二';
            testController.searchTel = '2';

            //検索
            testController.search();

            //検索結果が1件ある？
            system.assertEquals(1, testController.memberList.size());
        }
    }
    
    //検索エラーテスト	
    @isTest static void search_0_Test(){
    
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GK101001Test@horaguchi.com'];
        system.runas(userRecord){

            //コントローラ作成
            GK101001Controller testController = new GK101001Controller();
            testController.MemberStatusRadioButton = '入会';
            testController.searchMemberId = 'email2@mail.com';
            testController.searchName = '二';
            testController.searchTel = '2';

            //検索
            testController.search();
            //0エラー出てる？
            List<ApexPages.Message> messages = ApexPages.getMessages();
            System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_NO_DATA)));

        }
    }


    //ラジオボタン（カバレッジ率あげ）	
    @isTest static void coverageUp(){

        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GK101001Test@horaguchi.com'];
        system.runas(userRecord){

            //コントローラ作成
            GK101001Controller testController = new GK101001Controller();
            testController.getMemberStatusRadioButtonSetting();
        }
    }
    
}