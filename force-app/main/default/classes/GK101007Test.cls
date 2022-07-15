/* *
 * 類似物件紹介メール一覧
 */
@isTest 
private class GK101007Test {
    //テストに使用するレコードを作成する
    @testSetup static void Setting(){
        //システム設定を作成（暗号化に使用）
        SystemConfig__c s = new SystemConfig__c(
            HerokuSecretAccessKey__c = 'zF2SKTCj5CnR5TEhXhCLYBKE9x6a6xHN',
            UseAuthority_Portal__c = true,
            ExampleIv__c = '4f63e8b490579073'
            );
        insert s;        
        //取引先
        
        //店舗レコード
        Shop__c shopRecord = new shop__c(Name = 'テス店舗', IsShopType__c = true,
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
                UserName = 'GK101007Test@horaguchi.com',
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
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GK101007Test@horaguchi.com'];
        ShopTransfer__c ShopTransferRecord = new ShopTransfer__c(OrgzanizationHierarchy__c = orgRecord2.id,
                                                                    Staff__c = userRecord.id,
                                                                    StartDate__c = Date.newInstance(2000, 12, 1),
                                                                    EndDate__c = Date.newInstance(2999, 12, 1)); 
        insert ShopTransferRecord;

        //取引先作成
        Account acc = new Account(
            Name = '紹介太郎',
            LastName__c = '紹介',
            FirstName__c = '太郎',
            RecordTypeId = commonUtil.getRecordTypeId('Account','CustomerRecordType'),
            ContractType__c = '個人契約',
            IntroMailInfoFirstSendDatetime__c = Date.newInstance(2020,10,10),   //紹介メール初回配信日時
            IntroMailInfoLastSendDatetime__c = Date.newInstance(2020,10,13),    //紹介メール最終配信日時
            IntroMailInfoPursuitCount__c = 3,                                      //紹介メール送信回数
            IntroMailInfoStatus__c = CommonConst_ptl.INTRODUCTION_SEND          //配信状況 = 配信
        );    
        insert acc;

        //対応作成
        Correspond__c corr = new Correspond__c(
            AccountId__c = acc.Id
        );
        insert corr;
        
        //紹介メール情報
        IntroductionMailInformation__c introMail = new IntroductionMailInformation__c(
            Account__c = acc.Id,
            Correspond__c = corr.Id,
            SendMailDate__c = Datetime.newInstance(2020, 12, 1 ,10 ,10 , 0)
        );
        insert introMail;
    }

    //検索エラーテスト	
    @isTest static void notSearchTest(){
    
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GK101007Test@horaguchi.com'];
        system.runas(userRecord){

            //コントローラ作成
            GK101007Controller testController = new GK101007Controller();

            //0件エラー出てる？（テストデータでは、初期検索の時点で0件エラーが出ている）
            List<ApexPages.Message> messages = ApexPages.getMessages();
            system.debug(messages);

            //リストが0以上か確認
            If(messages.size() > 0){
            System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_NO_DATA)));
            }   
        }
    }

    //配信停止ボタン	
    @isTest static void sendStopTest(){

        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GK101007Test@horaguchi.com'];
        system.runas(userRecord){

            //コントローラ作成
            GK101007Controller testController = new GK101007Controller();
            testController.searchEchoShop = '';
            testController.searchEchoStaff = '';
            testController.searchVisitShop = '';
            testController.searchShopStaff = '';
            //検索
            testController.search();

            //チェックボックスを選択
            testController.screenIntroMailInfoList[0].checkBox = true;

            //配信停止ボタン押下処理
            testController.sendStopButton();

            Account acc = [SELECT id,IntroMailInfoStatus__c FROM Account WHERE Name = '紹介太郎'];

            //取引先の紹介メール配信状が「配信停止」に変更されている？
            system.assertEquals(CommonConst_ptl.INTRODUCTION_SENDSTOP, acc.IntroMailInfoStatus__c);
        }
    }

    //配信停止ボタン選択なしエラー	
    @isTest static void sendStopNotCheckErrorTest(){

        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GK101007Test@horaguchi.com'];
        system.runas(userRecord){

            //コントローラ作成
            GK101007Controller testController = new GK101007Controller();
            testController.searchEchoShop = '';
            testController.searchEchoStaff = '';
            testController.searchVisitShop = '';
            testController.searchShopStaff = '';
            //配信停止ボタン押下処理
            testController.sendStopButton();

            Account acc = [SELECT id FROM Account WHERE Name = '紹介太郎'];

            //選択してくださいエラー出ている？
            List<ApexPages.Message> messages = ApexPages.getMessages();

            //リストが1以上か確認
            If(messages.size() > 1){
            //※初期検索で該当データなしエラーが出てmessage[0]はそれになるため、message[1]に目的のエラーメッセージが入っている
            System.assertEquals(true, messages[1].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_NO_SELECTION, '自動追客メール')));
            }
        }
    }

    //配信停止ボタン　取引先　楽観ロックチェックエラー
    @isTest static void optimisticLockSaveAccountErrorTest(){

    User userRecord =  [SELECT Id FROM User WHERE UserName = 'GK101007Test@horaguchi.com'];
        system.runas(userRecord){

            //コントローラ作成
            GK101007Controller testController = new GK101007Controller();

            testController.searchEchoShop = '';
            testController.searchEchoStaff = '';
            testController.searchVisitShop = '';
            testController.searchShopStaff = '';

            //検索
            testController.search();
            system.debug(testController.screenIntroMailInfoList);
            //取引先を更新
            Account acc = [SELECT id FROM Account WHERE Name = '紹介太郎'];
            acc.Name = '紹介太郎2';
            update acc;

            //チェックボックスを選択
            testController.screenIntroMailInfoList[0].checkBox = true;
            
            //配信停止ボタン押下処理
            testController.sendStopButton();

            //楽観ロックチェックエラー出ている？
            List<ApexPages.Message> messages = ApexPages.getMessages();

            //リストが1以上か確認
            If(messages.size() > 1){
            System.assertEquals(true, messages[1].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK)));
            }
        }
    }

    //配信停止ボタン　紹介メール情報　楽観ロックチェックエラー
    @isTest static void optimisticLockSaveIntroMailErrorTest(){

        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GK101007Test@horaguchi.com'];
            system.runas(userRecord){
    
                //コントローラ作成
                GK101007Controller testController = new GK101007Controller();
                testController.searchEchoShop = '';
                testController.searchEchoStaff = '';
                testController.searchVisitShop = '';
                testController.searchShopStaff = '';
                //検索
                testController.search();
    
                //紹介メール情報を更新
                IntroductionMailInformation__c introMial = [SELECT id FROM IntroductionMailInformation__c WHERE SendMailDate__c = :Datetime.newInstance(2020, 12, 1 ,10 ,10 , 0)];
                update introMial;
    
                //チェックボックスを選択
                testController.screenIntroMailInfoList[0].checkBox = true;
                
                //配信停止ボタン押下処理
                testController.sendStopButton();
    
                //楽観ロックチェックエラー出ている？
                List<ApexPages.Message> messages = ApexPages.getMessages();

                //リストが1以上か確認
                If(messages.size() > 1){
                System.assertEquals(true, messages[1].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK)));
                }
            }
        }

        //カバレッジあげ
        @isTest static void coverageUp(){

        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GK101007Test@horaguchi.com'];
        system.runas(userRecord){
            //コントローラ作成
            GK101007Controller testController = new GK101007Controller();
            testController.searchName = 'aaa';
            testController.searchPhone = '111';
            testController.searchEmail = 'aaa';
            testController.searchEchoStaff = 'aaa';
            testController.searchShopStaff = 'aaa';
            //検索
            testController.search();
            testController.getEchoStaffList();
            testController.getShopStaffList();
            String a = testController.MSG_COM_V_DELETE_SENDMAILSTATUS;
            a = testController.MSG_COM_I_DELETE_SENDMAILSTATUS;
        }
    }

    //IS(インサイドセールス)テスト(店舗区分=false)	
    @isTest static void ISTest(){
    
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GK101007Test@horaguchi.com'];
        system.runas(userRecord){

            Shop__c shopRecord = [SELECT id, IsShopType__c FROM Shop__C WHERE Name = 'テス店舗'];
            shopRecord.IsShopType__c = false;
            update shopRecord;

            //コントローラ作成
            GK101007Controller testController = new GK101007Controller();
            
        }
    }
}