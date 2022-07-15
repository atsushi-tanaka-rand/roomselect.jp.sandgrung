/* *
 * HP会員詳細
 */
@isTest 
private class GK101002Test {
    //テストに使用するレコードを作成する
    @testSetup static void Setting(){
        //システム設定を作成（暗号化に使用）
        SystemConfig__c s = new SystemConfig__c(
            HerokuSecretAccessKey__c = 'zF2SKTCj5CnR5TEhXhCLYBKE9x6a6xHN',
            UseAuthority_Portal__c = true,
            ExampleIv__c = '4f63e8b490579073'
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
                UserName = 'GK101002Test@horaguchi.com',
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
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GK101002Test@horaguchi.com'];
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
                                              Tell__c = '1111111111',
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
                                              Tell__c = '22222222222',
                                              Email__c = 'email2@mail.com',
                                              Password__c = 'niyama',
                                              Birthdate__c = Date.newInstance(1995,1,1),
                                              Gender__c = '男性',
                                              Blacklist__c = true,
                                              JoinDate__c = Date.newInstance(2020,1,1),
                                              QuitDate__c =  Date.newInstance(2020,2,1),
                                              MemberStatus__c = '退会'),
                                new Member__c(MemberId__c = 'san',
                                              LastName__c = '三郎',
                                              FirstName__c = '三山',
                                              LastNameKana__c = 'サブロウ',
                                              FirstNameKana__c = 'サンヤマ',
                                              Tell__c = '3333333333',
                                              Email__c = 'email3@mail.com',
                                              Password__c = 'sannyama',
                                              Birthdate__c = Date.newInstance(1995,1,1),
                                              Gender__c = '男性',
                                              Blacklist__c = false,
                                              JoinDate__c = Date.newInstance(2020,1,1),
                                              MemberStatus__c = '入会')};

        insert  new SearchHistory__c(memberId__c = 'ichi',
                                     SearchHistoryId__c = 'id',
                                     SearchDate__c = Datetime.newInstance(2020,1,1),
                                     CsAntenna__c = true);
    }


    //初期表示テスト	
    @isTest static void initializeTest(){
    
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GK101002Test@horaguchi.com'];
        system.runas(userRecord){
            Member__c member = [SELECT id,
                                    MemberId__c,
                                    Email__c
                            FROM Member__c
                            WHERE Email__c = 'email1@mail.com'];            
            //パラメータ設定
            PageReference pageRef = Page.GK101002View;
            pageRef.getParameters().put('Id',member.Id );
            pageRef.getParameters().put('MemberId',member.MemberId__c );
            Test.setCurrentPage(pageRef);

            //コントローラ作成
            GK101002Controller testController = new GK101002Controller();

            //初期表示で渡したレコードのメールアドレスが表示されている？
            system.assertEquals('email1@mail.com', testController.memberIdEmail );
        }
    }

    //初期表示パラメータ不正エラーテスト	
    @isTest static void initializeIllegalParamErrorTest(){

        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GK101002Test@horaguchi.com'];
        system.runas(userRecord){
            PageReference pageRef = Page.GK101002View;
            //存在しない本会員のIdをパラメータとして渡す
            pageRef.getParameters().put('Id','0010T000002n5uc000' );
            pageRef.getParameters().put('MemberId','tekitou' );
            Test.setCurrentPage(pageRef);

            //コントローラ作成
            GK101002Controller testController = new GK101002Controller();
            List<ApexPages.Message> messages = ApexPages.getMessages();
            //不正なパラメータのエラーが出ている？
            System.assertEquals(true, messages[0].getDetail().contains(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
        }
    }

    //初期表示パラメータなしエラーテスト	
    @isTest static void initializeNullParamErrorTest(){

        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GK101002Test@horaguchi.com'];
        system.runas(userRecord){
            //パラメータを入れない
            PageReference pageRef = Page.GK101002View;
            Test.setCurrentPage(pageRef);

            //コントローラ作成
            GK101002Controller testController = new GK101002Controller();
            List<ApexPages.Message> messages = ApexPages.getMessages();
            //不正なパラメータのエラーが出ている？
            System.assertEquals(true, messages[0].getDetail().contains(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
        }
    }
    //保存テスト	
    @isTest static void saveTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GK101002Test@horaguchi.com'];
        system.runas(userRecord){
            Member__c member = [SELECT id,
                                    MemberId__c,
                                    Email__c,
                                    Tell__c,
                                    SystemModStamp
                            FROM Member__c
                            WHERE Email__c = 'email1@mail.com'];            
            //パラメータ設定
            PageReference pageRef = Page.GK101002View;
            pageRef.getParameters().put('Id',member.Id );
            pageRef.getParameters().put('MemberId',member.MemberId__c );
            Test.setCurrentPage(pageRef);

            //コントローラ作成
            GK101002Controller testController = new GK101002Controller();
            testController.blackListFlg = true;
            //スリープ
            CommonUtil.sleep(1000);  

            //保存処理
            testController.save();

            Member__c newMember = [SELECT id,Email__c,
                    SystemModStamp
            FROM Member__c
            WHERE Email__c = 'email1@mail.com'];            
            //SystemModStampの値が変わっている？
            system.assertEquals(true, member.SystemModStamp != newMember.SystemModStamp);
        }
    }

    //必須入力エラーテスト	
    @isTest static void saveNullErrorTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GK101002Test@horaguchi.com'];
        system.runas(userRecord){
            Member__c member = [SELECT id,
                                    MemberId__c,
                                    Email__c
                            FROM Member__c
                            WHERE Email__c = 'email1@mail.com'];            
            //パラメータ設定
            PageReference pageRef = Page.GK101002View;
            pageRef.getParameters().put('Id',member.Id );
            pageRef.getParameters().put('MemberId',member.MemberId__c );
            Test.setCurrentPage(pageRef);

            //コントローラ作成
            GK101002Controller testController = new GK101002Controller();
            //会員IDの値をnullに
            testController.memberIdEmail = '';
            //保存処理
            testController.save();

            List<ApexPages.Message> messages = ApexPages.getMessages();
            //会員IDは必須ですのエラーが出ている？
            System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, '会員ID')));
        }
    }

    //@なしエラーテスト	
    @isTest static void saveMailErrorTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GK101002Test@horaguchi.com'];
        system.runas(userRecord){
            Member__c member = [SELECT id,
                                    MemberId__c,
                                    Email__c
                            FROM Member__c
                            WHERE Email__c = 'email1@mail.com'];            
            //パラメータ設定
            PageReference pageRef = Page.GK101002View;
            pageRef.getParameters().put('Id',member.Id );
            pageRef.getParameters().put('MemberId',member.MemberId__c );
            Test.setCurrentPage(pageRef);

            //コントローラ作成
            GK101002Controller testController = new GK101002Controller();
            //会員IDの値から@を抜く
            testController.memberIdEmail = 'aaa';
            //保存処理
            testController.save();

            List<ApexPages.Message> messages = ApexPages.getMessages();
            //@は1つ入れてくださいのエラーが出ている？
            System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_MAILADDRESS_VALIDATION, '会員ID')));
        }
    }

    //メールアドレス重複エラー
    @isTest static void saveDuplicateErrorTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GK101002Test@horaguchi.com'];
        system.runas(userRecord){
            Member__c member = [SELECT id,
                                    MemberId__c,
                                    Email__c
                            FROM Member__c
                            WHERE Email__c = 'email1@mail.com'];            
            //パラメータ設定
            PageReference pageRef = Page.GK101002View;
            pageRef.getParameters().put('Id',member.Id );
            pageRef.getParameters().put('MemberId',member.MemberId__c );
            Test.setCurrentPage(pageRef);

            //コントローラ作成
            GK101002Controller testController = new GK101002Controller();
            //他レコードのメールアドレスと重複する値を設定（ブラックリストフラグがtrueのレコード）
            testController.memberIdEmail = 'email2@mail.com';
            //保存処理
            testController.save();

            List<ApexPages.Message> messages = ApexPages.getMessages();
            //重複エラーが出ている？
            System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_EXISTENCE, testController.memberIdEmail)));
        }
    }
    
    //楽観ロックチェックエラー
    @isTest static void saveOptimisticLockErrorTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GK101002Test@horaguchi.com'];
        system.runas(userRecord){
            Member__c member = [SELECT id,
                                    MemberId__c,
                                    Email__c,
                                    Tell__c
                            FROM Member__c
                            WHERE Email__c = 'email1@mail.com'];            
            //パラメータ設定
            PageReference pageRef = Page.GK101002View;
            pageRef.getParameters().put('Id',member.Id );
            pageRef.getParameters().put('MemberId',member.MemberId__c );
            Test.setCurrentPage(pageRef);

            //コントローラ作成
            GK101002Controller testController = new GK101002Controller();

            //スリープ
            CommonUtil.sleep(1000);  

            //対象の本会員を更新
            update member;

            //保存処理
            testController.save();

            List<ApexPages.Message> messages = ApexPages.getMessages();
            //楽観ロックエラーが出ている？
            System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK)));
        }
    }

    //カバレッジ率あげ
    @isTest static void coverageUp(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GK101002Test@horaguchi.com'];
        system.runas(userRecord){
            Member__c member = [SELECT id,
                                    MemberId__c,
                                    Email__c,
                                    SystemModStamp
                            FROM Member__c
                            WHERE Email__c = 'email3@mail.com'];            
            //パラメータ設定
            PageReference pageRef = Page.GK101002View;
            pageRef.getParameters().put('Id',member.Id );
            pageRef.getParameters().put('MemberId',member.MemberId__c );
            Test.setCurrentPage(pageRef);

            //コントローラ作成
            GK101002Controller testController = new GK101002Controller();
            testController.blackListFlg = false;
            
            //保存処理
            testController.save();
            String a = testController.MSG_COM_I_SAVE;
            a = testController.MSG_COM_V_BLACKLIST_CHANGE;
            a = testController.MSG_COM_V_UPDATE_MEMBER;
            a = testController.WITHDRAWAL;
        }
    }
        
}