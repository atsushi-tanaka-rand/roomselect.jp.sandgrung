/**
 * 業者登録
 */

@isTest 
private class GD101002Test{
    public static final String USER_NAME = 'GD101002@horaguchi.com'; 
    @testSetup static void Setting(){
        //★取引先作成
        //取引先1（消せない）
        Account accountRecord1 = new Account(
                Name = 'テスト株式会社'
                ,State__c = '沖縄県'
                ,City__c = '那覇市'
                ,Street__c = 'テスト町4-4'
                ,Phone = '4931-1234'
                ,Representative__c = 'テスト担当者'
                ,IsMergeCompletedFlag__c = true
                ,RecordTypeId = CommonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_SUPPLIER)
                ,at_home_press_ban__c = false
                ,HOME_S_press_ban__c = false
                ,SUUMO_press_ban__c = false
                ,Chintai_press_ban__c = true // 2022.03.31 CHINTAI対応追加
                ,Our_HP_press_ban__c = false
                ,ImportType__c = '手動');
        //取引先2（消せる）
        Account accountRecord2 = new Account(
                Name = 'テスト2株式会社'
                ,State__c = '愛知県'
                ,City__c = '名古屋市テスト町'
                ,Street__c = '1-1'
                ,Phone = '111-111-111'
                ,Representative__c = 'テスト2担当者'
                ,RecordTypeId = CommonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_SUPPLIER));
        List<Account> accountList = new List<Account> {accountRecord1,accountRecord2};
        insert accountList;

        //対応
        Correspond__c corrRecord1 = new Correspond__c(
            AccountId__c = accountRecord1.id);
        Correspond__c corrRecord2 = new Correspond__c(
            AccountId__c = accountRecord2.id);

        List<Correspond__c> corrList = new List<Correspond__c> {corrRecord1,corrRecord2};
        insert corrList;

        //対応明細
        CorrespondDetail__c corrDetailRecord1 = new CorrespondDetail__c(
            Corresponds__c = corrRecord1.id);
        insert corrDetailRecord1;

        //商品（関連リスト用）
        //保証
        Item__c itemRecord1 = new Item__c(
            Account__c = accountRecord1.id
            ,ItemName__c = 'テスト保証'
            ,AssuranceContent__c = 'テスト保証内容'
            ,Remarks__c = 'テスト保証備考'
            ,DirectDebitFeeTaxType__c = '課税'
            ,DirectDebitFee__c = 10000
            ,RecordTypeId =CommonUtil.getRecordTypeId('Item__c', commonConst.ITEM_RECTYPE_GUARANTEE_PLAN));
        Item__c itemRecord2 = new Item__c(
                Account__c = accountRecord2.id
                ,ItemName__c = 'テスト2保証'
                ,AssuranceContent__c = 'テスト2保証内容'
                ,Remarks__c = 'テスト2保証備考'
                ,DirectDebitFeeTaxType__c = '非課税'
                ,DirectDebitFee__c = 10000
                ,RecordTypeId = CommonUtil.getRecordTypeId('Item__c', commonConst.ITEM_RECTYPE_GUARANTEE_PLAN));
        //火災
        Item__c itemRecord3 = new Item__c(
            Account__c = accountRecord1.id
            ,ItemName__c = 'テスト火災保険'
            ,FireInsurance__c = 'テスト火災保険内容'
            ,Remarks__c = 'テスト火災保険備考'
            ,RecordTypeId =CommonUtil.getRecordTypeId('Item__c', commonConst.ITEM_RECTYPE_FIRE_INSURANCE));
        Item__c itemRecord4 = new Item__c(
                Account__c = accountRecord2.id
                ,ItemName__c = 'テスト2火災保険'
                ,FireInsurance__c = 'テスト2火災保険内容'
                ,Remarks__c = 'テスト2火災保険備考'
                ,RecordTypeId = CommonUtil.getRecordTypeId('Item__c', commonConst.ITEM_RECTYPE_FIRE_INSURANCE));
        
        List<Item__c> itemList = new List<Item__c> {itemRecord1,itemRecord2,itemRecord3,itemRecord4};
        insert itemList;

        //取引先保険保証(取引先1に関連)
        InsuranceGuarantee__c insuGuarRecord1 = new InsuranceGuarantee__c(
                              Item__c = itemRecord1.id
                              ,Account__c = accountRecord1.id
                              ,RecordTypeId = CommonUtil.getRecordTypeId('InsuranceGuarantee__c',commonConst.INSURANCE_RECTYPE_GUARANTEE_GUARANTEE));
        InsuranceGuarantee__c insuGuarRecord2 = new InsuranceGuarantee__c(
                                Item__c = itemRecord3.id
                                ,Account__c = accountRecord1.id
                                ,RecordTypeId = CommonUtil.getRecordTypeId('InsuranceGuarantee__c',commonConst.INSURANCE_RECTYPE_GUARANTEE_FIREINSURANCE));
        InsuranceGuarantee__c insuGuarRecord3 = new InsuranceGuarantee__c(
            Item__c = itemRecord2.id
            , Account__c = accountRecord1.id
            , RecordTypeId = CommonUtil.getRecordTypeId(String.valueOf(InsuranceGuarantee__c.getSObjectType())
                                                        , commonConst.INSURANCE_RECTYPE_GUARANTEE_GUARANTEE)
        );
        InsuranceGuarantee__c insuGuarRecord4 = new InsuranceGuarantee__c(
            Item__c = itemRecord4.id
            , Account__c = accountRecord1.id
            , RecordTypeId = CommonUtil.getRecordTypeId(String.valueOf(InsuranceGuarantee__c.getSObjectType())
                                                        , commonConst.INSURANCE_RECTYPE_GUARANTEE_FIREINSURANCE)
        );
        List<InsuranceGuarantee__c> insuGuarList = new List<InsuranceGuarantee__c> {
            insuGuarRecord1
            , insuGuarRecord2
            , insuGuarRecord3
            , insuGuarRecord4
        };
        insert insuGuarList;
        
        //建物（物件作成用）
        Building__c builRecord1 = new Building__c(Name = 'テスト建物');
        insert builRecord1;

        //物件(取引先と取引先保険保証に紐づけ用、テスト取引先1とテスト火災保険1とテスト保証1)
        Property__c propertyRecord1 = new Property__c(
                    Name = '101'
                    ,Building__c = builRecord1.id
                    ,LiveStatus__c = '空室'
                    ,FormerSupplier__c = accountRecord1.id
                    ,FireInsurancePlan__c = itemRecord3.id
                    ,Guaranteeid__c = itemRecord1.id
                    ,AllRentFee__c = 0
                    ,GuaranteeidCompanyType__c = CommonConst.PROPERTY_GUARANTEEIDCOMPANYTYPE_REQUIRED
                    ,FireInsuranceUseType__c = CommonConst.PROPERTY_FIREINSURANCEUSETYPE_EXISTS);
        insert propertyRecord1;        

        //管理会社指定商品(物件管理会社指定と紐づけ)
        ManagementCompanyItem__c manaComItem1 = new ManagementCompanyItem__c(
            ItemName__c = '管理会社指定商品1'
            ,Amount__c = 1000
            ,PaymentType__c = '初回'
            ,TaxType__c = '課税'
            ,Account__c = accountRecord1.id);
        //物件管理会社指定と紐づかない
        ManagementCompanyItem__c manaComItem2 = new ManagementCompanyItem__c(
            ItemName__c = '管理会社指定商品2'
            ,Amount__c = 5000
            ,PaymentType__c = '初回'
            ,TaxType__c = '非課税'
            ,Account__c = accountRecord1.id);
        List<ManagementCompanyItem__c> manaComItemList = new List<ManagementCompanyItem__c> {manaComItem1,manaComItem2};
        insert manaComItemList;

        //物件管理会社指定
        PropertyManageCompayItem__c proManaRecord1 = new PropertyManageCompayItem__c(
            Item__c = manaComItem1.id//管理会社指定商品
            ,Account__c = accountRecord1.id
            ,Property__c = propertyRecord1.id);
        insert proManaRecord1;

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
       List<Profile> profiles = [SELECT Id FROM Profile WHERE Name IN ('システム管理者')];
       System.assert(profiles.size() > 0);
       
       User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
       System.runAs(thisUser){
           
           insert new User(
               UserName = 'GD101002Test@horaguchi.com',
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
       User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD101002Test@horaguchi.com'];
       ShopTransfer__c ShopTransferRecord = new ShopTransfer__c(OrgzanizationHierarchy__c = orgRecord2.id,
                                                                Staff__c = userRecord.id,
                                                                StartDate__c = Date.newInstance(2000, 12, 1),
                                                                EndDate__c = Date.newInstance(2999, 12, 1)); 
       insert ShopTransferRecord;
       SystemConfig__c settings = new SystemConfig__c();
       settings.SupplierRegist_PropertyUpdateMaxCount__c = 50;//検索上限
       settings.SupplierRegist_BuildingMaxCount__c = 50;//建物最大検索数上限
       settings.ErrorEmailDestination__c = 'test@mail.co.jp'; // エラーメール送信先
       insert settings;

       //ポータルサイト掲載物件
       PortalSitePostingProperty__c portalSitePostingProperty = new PortalSitePostingProperty__c(
            IsAtHome__c = false
            ,IsHomes__c = false
            ,IsSuumo__c = false
			,IsChintaiNet__c = false // 2022.03.31 CHINTAI対応追加
            ,IsChintaiPanoramaPosting__c = false // 2022.03.31 CHINTAI対応追加
            ,IsPortal__c = false
            ,Property__c = propertyRecord1.Id
       );
       insert portalSitePostingProperty;
    }

    //=========================================================================================
    //◇初期表示（新規）
    @isTest static void newInitializeTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD101002Test@horaguchi.com'];
        system.runas(userRecord){
            //パラメータ設定
            PageReference pageRef = Page.GD101002View;
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GD101002Controller testController = new GD101002Controller();
            system.assertEquals(true, testController.isNew);
            system.assertEquals(null, testController.screenTargetRecord.Name);
            system.assertEquals(0, testController.screenGuaranteeList.size());
            system.assertEquals(0, testController.screenFireList.size());
            system.assertEquals(0, testController.screenManaComItemList.size());
        }
    }
    //◇初期表示（編集）
    @isTest static void editInitializeTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD101002Test@horaguchi.com'];
        system.runas(userRecord){
            //使用レコード
            Account testAccout = [SELECT Id
                                         ,at_home_press_ban__c
                                         ,HOME_S_press_ban__c
                                         ,SUUMO_press_ban__c
                                         ,Our_HP_press_ban__c
                                  FROM Account WHERE Name = 'テスト株式会社'];

            //パラメータ設定
            PageReference pageRef = Page.GD101002View;
            pageRef.getParameters().put('Id',testAccout.Id );
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GD101002Controller testController = new GD101002Controller();
            system.assertEquals(false, testController.isNew);
            system.assertEquals('テスト株式会社', testController.screenTargetRecord.Name);
            system.assertEquals(2, testController.screenGuaranteeList.size());
            system.assertEquals(2, testController.screenFireList.size());
            system.assertEquals(2, testController.screenManaComItemList.size());

            //サイト非掲載フラグ初期値チェック
            system.assertEquals(testAccout.at_home_press_ban__c, testController.screenTargetRecord.atHomePressBan);
            system.assertEquals(testAccout.HOME_S_press_ban__c, testController.screenTargetRecord.homesPressBan);
            system.assertEquals(testAccout.SUUMO_press_ban__c, testController.screenTargetRecord.suumoPressBan);
            system.assertEquals(testAccout.Our_HP_press_ban__c, testController.screenTargetRecord.ourHpPressBan);
        }
    }

    //◇初期表示（異常）
    @isTest static void errorInitializeTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD101002Test@horaguchi.com'];
        system.runas(userRecord){
            //使用レコード
            Account testAccout = [SELECT Id FROM Account WHERE Name = 'テスト株式会社'];
            //パラメータ設定
            PageReference pageRef = Page.GD101002View;
            pageRef.getParameters().put('Id','0010T000002n5uc000' );
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GD101002Controller testController = new GD101002Controller();

            List<ApexPages.Message> messages = ApexPages.getMessages();
            System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER)));

        }
    }
    //◇保証リスト削除
    @isTest static void guarDelete(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD101002Test@horaguchi.com'];
        system.runas(userRecord){
            //パラメータ設定
            PageReference pageRef = Page.GD101002View;
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GD101002Controller testController = new GD101002Controller();

            //レコード追加
            Item__c item =[SELECT Id,
                                ItemName__c,
                                AssuranceContent__c,
                                Remarks__c,
                                DirectDebitFeeTaxType__c,
                                DirectDebitFee__c,
                                RecordTypeId,
                                DirectDebitFeeTax__c 
                        FROM Item__c 
                        WHERE ItemName__c = 'テスト保証'];
            testController.screenGuaranteeList.add(new GD101002Controller.ScreenGuarantee(item));
            testController.screenGuaranteeList[0].guaranteeCheck = true;
            //削除処理
            testController.deleteGuarantee();
            //リストが0？
            system.assertEquals(0,testController.screenGuaranteeList.size());
        }
    }
    //◇保証リスト削除(異常)
    @isTest static void guarErrorDelete(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD101002Test@horaguchi.com'];
        system.runas(userRecord){
            //使用レコード
            Account testAccout = [SELECT Id FROM Account WHERE Name = 'テスト株式会社'];
            //パラメータ設定
            PageReference pageRef = Page.GD101002View;
            pageRef.getParameters().put('Id',testAccout.Id );
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GD101002Controller testController = new GD101002Controller();
            
            testController.screenGuaranteeList[1].guaranteeCheck = true;  //問合せNo0655でソート順変更による取得データ変更
            //削除処理
            testController.deleteGuarantee();
            //リストが0？
            List<ApexPages.Message> messages = ApexPages.getMessages();
            System.assertEquals(true, messages[0].getDetail().contains('に紐づいているため、削除できません。'));
        }
    }

    //◇火災リスト削除
    @isTest static void fireDelete(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD101002Test@horaguchi.com'];
        system.runas(userRecord){
            //パラメータ設定
            PageReference pageRef = Page.GD101002View;
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GD101002Controller testController = new GD101002Controller();

            //レコード追加
            Item__c item =[SELECT Id,
                            ItemName__c,
                            FireInsurance__c,
                            Remarks__c,
                            DirectDebitFeeTaxType__c,
                            DirectDebitFee__c,
                            RecordTypeId 
                        FROM Item__c 
                        WHERE ItemName__c = 'テスト火災保険'];
            testController.screenFireList.add(new GD101002Controller.ScreenFireInsurance(item));
            testController.screenFireList[0].fireCheck = true;
            //削除処理
            testController.deleteFire();
            //リストが0？
            system.assertEquals(0,testController.screenFireList.size());
        }
    }
    //◇保証リスト削除(異常)
    @isTest static void fireErrorDelete(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD101002Test@horaguchi.com'];
        system.runas(userRecord){
            //使用レコード
            Account testAccout = [SELECT Id FROM Account WHERE Name = 'テスト株式会社'];
            //パラメータ設定
            PageReference pageRef = Page.GD101002View;
            pageRef.getParameters().put('Id',testAccout.Id );
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GD101002Controller testController = new GD101002Controller();
            
            testController.screenFireList[1].fireCheck = true;  //問合せNo0655でソート順変更による取得データ変更
            //削除処理
            testController.deleteFire();
            //リストが0？
            List<ApexPages.Message> messages = ApexPages.getMessages();
            System.assertEquals(true, messages[0].getDetail().contains('に紐づいているため、削除できません。'));
        }
    }

    //◇管理会社指定商品リスト削除
    @isTest static void mciDelete(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD101002Test@horaguchi.com'];
        system.runas(userRecord){
            //パラメータ設定
            PageReference pageRef = Page.GD101002View;
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GD101002Controller testController = new GD101002Controller();

            //モーダル起動呼び出し
            testController.openManagementCompanyItemModal();
                        
            //子(モーダル)起動
            GD101002Modal1Controller testModalController = new GD101002Modal1Controller();

            //親のパラメータを子に渡す(親で設定しているモーダル用のパラメータをそのまま格納)
            testModalController.parameter = testController.GD101002Modal1Parameter;

            //子のinitactionを起動
            testModalController.initAction();

            testModalController.screenMciRecord.itemName = '追加1';
            testModalController.screenMciRecord.amount = '1000';
            testModalController.screenMciRecord.taxType = '課税';
            testModalController.screenMciRecord.paymentType = '初回';
            //画面閉じる
            testModalController.register();
            testController.closeManagementCompanyItemModal();

            //削除処理
            testController.screenManaComItemList[0].manaComItemCheck=true;
            testController.deleteManaComItem();
            //リストが0？
            system.assertEquals(0,testController.screenManaComItemList.size());
        }
    }
    //◇保証リスト削除(異常)
    @isTest static void mciErrorDelete(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD101002Test@horaguchi.com'];
        system.runas(userRecord){
            //使用レコード
            Account testAccout = [SELECT Id FROM Account WHERE Name = 'テスト株式会社'];
            //パラメータ設定
            PageReference pageRef = Page.GD101002View;
            pageRef.getParameters().put('Id',testAccout.Id );
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GD101002Controller testController = new GD101002Controller();
            
            testController.screenManaComItemList[0].manaComItemCheck = true;
            testController.screenManaComItemList[1].manaComItemCheck = true;
            //削除処理
            testController.deleteManaComItem();
            //リストが0？
            List<ApexPages.Message> messages = ApexPages.getMessages();
            System.assertEquals(true, messages[0].getDetail().contains('に紐づいているため、削除できません。'));
        }
    }
    
    //◇管理会社指定商品モーダル（新規）
    @isTest static void newModalTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD101002Test@horaguchi.com'];
        system.runas(userRecord){
            //パラメータ設定
            PageReference pageRef = Page.GD101002View;
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GD101002Controller testController = new GD101002Controller();

            //モーダル起動呼び出し
            testController.openManagementCompanyItemModal();
                        
            //子(モーダル)起動
            GD101002Modal1Controller testModalController = new GD101002Modal1Controller();

            //親のパラメータを子に渡す(親で設定しているモーダル用のパラメータをそのまま格納)
            testModalController.parameter = testController.GD101002Modal1Parameter;

            //子のinitactionを起動
            testModalController.initAction();

            testModalController.screenMciRecord.itemName = '追加1';
            testModalController.screenMciRecord.amount = '1000';
            testModalController.screenMciRecord.taxType = '課税';
            testModalController.screenMciRecord.paymentType = '初回';
            //画面閉じる
            testModalController.register();
            testController.closeManagementCompanyItemModal();
            //入居者リストにレコードが入っていることを確認（新規で親画面を開いているので作成前は0）
            System.assertEquals(true,testController.screenManaComItemList.size() != 0);
        }
    }

    //◇管理会社指定商品モーダル（編集）
    @isTest static void editModalTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD101002Test@horaguchi.com'];
        system.runas(userRecord){
            //使用レコード
            Account testAccout = [SELECT Id FROM Account WHERE Name = 'テスト株式会社'];
            //パラメータ設定
            PageReference pageRef = Page.GD101002View;
            pageRef.getParameters().put('Id',testAccout.Id );
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GD101002Controller testController = new GD101002Controller();

            //管理会社指定商品の行番号番号指定
            testController.manaComItemIndex = 0;
            //モーダル起動呼び出し
            testController.editManagementCompanyItemModal();
                        
            //子(モーダル)起動
            GD101002Modal1Controller testModalController = new GD101002Modal1Controller();

            //親のパラメータを子に渡す(親で設定しているモーダル用のパラメータをそのまま格納)
            testModalController.parameter = testController.GD101002Modal1Parameter;

            //子のinitactionを起動
            testModalController.initAction();

            testModalController.screenMciRecord.itemName = '管理会社指定商品変更';

            //画面閉じる
            testModalController.register();
            testController.closeManagementCompanyItemModal();
            //入居者リストにレコードが入っていることを確認（新規で親画面を開いているので作成前は2）
            System.assertEquals(2,testController.screenManaComItemList.size());
            //選択したレコードの商品名が変更されている？
            System.assertEquals('管理会社指定商品変更',testController.screenManaComItemList[testController.manaComItemIndex].manaComItemRecord.ItemName__c);
        }
    }

    //◇管理会社指定商品モーダル（異常）
    @isTest static void errorModalTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD101002Test@horaguchi.com'];
        system.runas(userRecord){
            //パラメータ設定
            PageReference pageRef = Page.GD101002View;
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GD101002Controller testController = new GD101002Controller();

            //モーダル起動呼び出し
            testController.openManagementCompanyItemModal();
                        
            //子(モーダル)起動
            GD101002Modal1Controller testModalController = new GD101002Modal1Controller();

            //親のパラメータを子に渡す(親で設定しているモーダル用のパラメータをそのまま格納)
            testModalController.parameter = testController.GD101002Modal1Parameter;

            //子のinitactionを起動
            testModalController.initAction();

            //画面閉じる
            testModalController.register();
            
            //必須エラー
            List<ApexPages.Message> messages = ApexPages.getMessages();
            System.assertEquals(true, messages[0].getDetail().contains('は入力必須です。'));
        }
    }

    //◇保存（編集）
    @isTest static void editSaveTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD101002Test@horaguchi.com'];
        system.runas(userRecord){
            //使用レコード
            Account testAccout = [SELECT Id,SystemModStamp FROM Account WHERE Name = 'テスト株式会社'];
            //パラメータ設定
            PageReference pageRef = Page.GD101002View;
            pageRef.getParameters().put('Id',testAccout.Id );
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GD101002Controller testController = new GD101002Controller();

            //電話番号を既存レコードと同じ値に変更
            testController.screenTargetRecord.phone = '111-111-111';
            testController.screenTargetRecord.name = 'テスト株式会社';
            testController.screenTargetRecord.representative = 'aaa';
            testController.screenTargetRecord.chintaiPressBan = false; // 2022.03.31 CHINTAI対応追加

            //保存処理
            testController.save();

            //スリープ
            CommonUtil.sleep(1);

            //新しくSystemModStampを取得
            Account afterTestTargetRecord = [SELECT SystemModStamp,IsMergeCompletedFlag__c, Chintai_press_ban__c
                                                FROM Account
                                                WHERE Name = 'テスト株式会社']; 
            //更新後と更新前でSystemModStampがちがう？
            system.assertEquals(true,afterTestTargetRecord.SystemModStamp != testAccout.SystemModStamp );
            //名寄せ完了がfalseに変更されている？
            system.assertEquals(false,afterTestTargetRecord.IsMergeCompletedFlag__c );
			System.assertEquals(false, afterTestTargetRecord.Chintai_press_ban__c); // 2022.03.31 CHINTAI対応追加
        }
    }

    //◇保存（掲載フラグ変更時）
    @isTest static void editSaveTestSendMail(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD101002Test@horaguchi.com'];
        system.runas(userRecord){
            //使用レコード
            Account testAccout = [SELECT Id,SystemModStamp FROM Account WHERE Name = 'テスト株式会社'];
            //パラメータ設定
            PageReference pageRef = Page.GD101002View;
            pageRef.getParameters().put('Id',testAccout.Id );
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GD101002Controller testController = new GD101002Controller();

            //チェックボックスの値を変更後に保存
            testController.screenTargetRecord.suumoPressBan = true;
            testController.save();

            //スリープ
            CommonUtil.sleep(1);

            //メッセージ確認
            string msg = CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE) + CommonConst.BREAK_TAG
                       + CommonUtil.callMessageCreate(CommonConst.MSG_ACC_I_TRADER_REGIST_SEND_MAIL);
            system.assertEquals(msg, testController.MSG_COM_I_SAVEBUTTON );

            testController = new GD101002Controller();
            testController.screenTargetRecord.atHomePressBan = true;
            testController.save();

            testController = new GD101002Controller();
            testController.screenTargetRecord.homesPressBan = true;
            testController.save();

            testController = new GD101002Controller();
            testController.screenTargetRecord.ourHpPressBan = true;
            testController.save();
        }
    }

    //◇保存（新規）
    @isTest static void newSaveTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD101002Test@horaguchi.com'];
        system.runas(userRecord){
            //パラメータ設定
            PageReference pageRef = Page.GD101002View;
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GD101002Controller testController = new GD101002Controller();
            testController.screenTargetRecord.name = '新規保存テスト';
            testController.screenTargetRecord.representative = '新規テスト担当者';
            testController.screenTargetRecord.phone = '123456';
			testController.screenTargetRecord.chintaiPressBan = true; // 2022.03.31 CHINTAI対応追加
            //保存処理
            testController.save();
            //スリープ
            CommonUtil.sleep(1);

            //SELECTできる？
            List<Account> afterTestTargetRecord = [SELECT SystemModStamp, Chintai_press_ban__c
                                                FROM Account
                                                WHERE Name = '新規保存テスト']; 
            // system.assertEquals(1,afterTestTargetRecor.size() );
			System.assertEquals(true, afterTestTargetRecord[0].Chintai_press_ban__c); // 2022.03.31 CHINTAI対応追加
        }
    }

    //◇保存（異常、必須項目なし）
    @isTest static void requiredErrorSaveTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD101002Test@horaguchi.com'];
        system.runas(userRecord){
            //パラメータ設定
            PageReference pageRef = Page.GD101002View;
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GD101002Controller testController = new GD101002Controller();
            //保存処理
            testController.save();

            //必須エラー
            List<ApexPages.Message> messages = ApexPages.getMessages();
            System.assertEquals(true, messages[0].getDetail().contains('は入力必須です。'));
           
        }
    }

    //◇保存（異常、既に同じ業者がある）
    @isTest static void duplicationErrorSaveTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD101002Test@horaguchi.com'];
        system.runas(userRecord){
            //パラメータ設定
            PageReference pageRef = Page.GD101002View;
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GD101002Controller testController = new GD101002Controller();
            testController.screenTargetRecord.representative = '新規テスト担当者';
            testController.screenTargetRecord.name = 'テスト2株式会社';
            testController.screenTargetRecord.phone = '111-111-111';
            testController.screenTargetRecord.state = '愛知県';
            testController.screenTargetRecord.city = '名古屋市テスト町';
            testController.screenTargetRecord.street = '1-1';

            //保存処理
            testController.save();

            //必須エラー
            List<ApexPages.Message> messages = ApexPages.getMessages();
            // System.assertEquals(true, messages[0].getDetail().contains('は既に存在します。'));      
        }
    }
     //◇保存（異常、火災保険重複がある）
     @isTest static void fireErrorSaveTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD101002Test@horaguchi.com'];
        system.runas(userRecord){
            //パラメータ設定
            PageReference pageRef = Page.GD101002View;
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GD101002Controller testController = new GD101002Controller();
            Item__c item =[SELECT Id,
                                ItemName__c,
                                FireInsurance__c,
                                Remarks__c,
                                DirectDebitFeeTaxType__c,
                                DirectDebitFee__c,
                                RecordTypeId 
                                 FROM Item__c WHERE ItemName__c = 'テスト火災保険'];
            testController.screenFireList.add(new GD101002Controller.ScreenFireInsurance(item));
            testController.screenFireList.add(new GD101002Controller.ScreenFireInsurance(item));
            testController.screenTargetRecord.name = 'a';
            //保存処理
            testController.save();
             //リスト重複エラー
             List<ApexPages.Message> messages = ApexPages.getMessages();
            //  System.assertEquals(true, messages[0].getDetail().contains('選択済のデータが確認されました。選択対象のご確認をお願いします。'));                
        }
    }
    //◇保存（異常、保証重複がある）
    @isTest static void guarErrorSaveTest(){
    User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD101002Test@horaguchi.com'];
    system.runas(userRecord){
        //パラメータ設定
        PageReference pageRef = Page.GD101002View;
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GD101002Controller testController = new GD101002Controller();
        Item__c item =[SELECT Id,
                            ItemName__c,
                            AssuranceContent__c,
                            Remarks__c,
                            DirectDebitFeeTaxType__c,
                            DirectDebitFee__c,
                            RecordTypeId,
                            DirectDebitFeeTax__c 
                            FROM Item__c 
                            WHERE ItemName__c = 'テスト保証'];
        testController.screenGuaranteeList.add(new GD101002Controller.ScreenGuarantee(item));
        testController.screenGuaranteeList.add(new GD101002Controller.ScreenGuarantee(item));
        //保存処理
        testController.screenTargetRecord.name = 'a';
        testController.save();
        //リスト重複エラー
        List<ApexPages.Message> messages = ApexPages.getMessages();
        // System.assertEquals(true, messages[0].getDetail().contains('選択済のデータが確認されました。選択対象のご確認をお願いします。'));                
        }
    }

    //◇削除
    @isTest static void deleteTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD101002Test@horaguchi.com'];
        system.runas(userRecord){
            //使用レコード
            Account testAccout = [SELECT Id FROM Account WHERE Name = 'テスト2株式会社'];
            Id accId = testAccout.id;
            //パラメータ設定
            PageReference pageRef = Page.GD101002View;
            pageRef.getParameters().put('Id',testAccout.Id );
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GD101002Controller testController = new GD101002Controller();

            //削除処理
            testController.deleteButton();
            //スリープ
            CommonUtil.sleep(1);

            //新しくSystemModStampを取得
            List<Account> afterTestTargetRecor = [SELECT id
                                            FROM Account
                                            WHERE Name = 'テスト2株式会社']; 
            List<Correspond__c> corrRecord = [SELECT id
                                            FROM Correspond__c
                                            WHERE AccountId__c = :accId];                   
            //更新後と更新前でSystemModStampがちがう？
            system.assertEquals(0,afterTestTargetRecor.size() );
            //名寄せ完了がfalseに変更されている？
            system.assertEquals(0,corrRecord.size() );
        }
    }
    
    //◇削除(異常)
    @isTest static void deleteErrorTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD101002Test@horaguchi.com'];
        system.runas(userRecord){
            //使用レコード
            Account testAccout = [SELECT Id FROM Account WHERE Name = 'テスト株式会社'];
            Id accId = testAccout.id;
            //パラメータ設定
            PageReference pageRef = Page.GD101002View;
            pageRef.getParameters().put('Id',testAccout.Id );
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GD101002Controller testController = new GD101002Controller();

            //削除処理
            testController.deleteButton();
            //スリープ
            CommonUtil.sleep(1);

            //リスト重複エラー
            List<ApexPages.Message> messages = ApexPages.getMessages();
            System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_CANNOT_DELETE_LINKED,'「'+testController.screenTargetRecord.name + '」は物件')));                
            System.assertEquals(true, messages[1].getDetail().contains(CommonConst.MSG_COM_E_NOTICE_USED));                
        }
    }

    //問合せ278で変更　取込区分を手動に変更
    @isTest static void changeManualTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD101002Test@horaguchi.com'];
        system.runas(userRecord){
            //使用レコード
            Account testAccout = [SELECT Id,SystemModStamp,ImportType__c FROM Account WHERE Name = 'テスト株式会社'];
            testAccout.ImportType__c = '大和リビング';
            upsert testAccout;
            //パラメータ設定
            PageReference pageRef = Page.GD101002View;
            pageRef.getParameters().put('Id',testAccout.Id );
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GD101002Controller testController = new GD101002Controller();

            //電話番号を既存レコードと同じ値に変更
            testController.screenTargetRecord.phone = '111-111-111';

            testController.screenTargetRecord.name = 'テスト株式会社';
            testController.screenTargetRecord.representative = 'aaa';
            testController.screenTargetRecord.importType = '手動';

            //保存処理
            testController.save();
        }
    }

    //問合せ278で変更　取込区分を手動からリアプロに変更
    @isTest static void changeReaproTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD101002Test@horaguchi.com'];
        system.runas(userRecord){
            //使用レコード
            Account testAccout = [SELECT Id,SystemModStamp,ImportType__c FROM Account WHERE Name = 'テスト株式会社'];
            testAccout.ImportType__c = '手動';
            //パラメータ設定
            PageReference pageRef = Page.GD101002View;
            pageRef.getParameters().put('Id',testAccout.Id );
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GD101002Controller testController = new GD101002Controller();

            //電話番号を既存レコードと同じ値に変更
            testController.screenTargetRecord.phone = '111-111-111';

            testController.screenTargetRecord.name = 'テスト株式会社';
            testController.screenTargetRecord.representative = 'aaa';
            testController.screenTargetRecord.importType = 'リアプロ';

            //保存処理
            testController.save();
            // --その他--変更も確認
            testController.screenTargetRecord.importType = null;
            testController.save();
        }
    }

    // 保証会社プランの業者プラン一括変更画面の起動テスト
    @isTest static void openSupplierPlanBulkChgGuaranteeidCorpTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD101002Test@horaguchi.com'];
        system.runas(userRecord){
            // 取引先
            Account account = [SELECT Id
                               FROM Account
                               WHERE Name = 'テスト株式会社'];

            // 物件登録画面の初期表示
            PageReference pageRef = Page.GD101002View;
            pageRef.getParameters().put('Id', account.Id );
            Test.setCurrentPage(pageRef);

            // 保証会社プランの業者プラン一括変更画面の起動
            GD101002Controller testController = new GD101002Controller();
            testController.screenGuaranteeList[1].guaranteeCheck = true;  //問合せNo0655でソート順変更による取得データ変更
            testController.openSupplierPlanBulkChgGuaranteeidCorp();

            // 業者プラン一括変更画面の初期表示
            GD101002Modal2Controller testModalController = new GD101002Modal2Controller();
            testModalController.Parameter = testController.GD101002Modal2Parameter;
            Boolean init = testModalController.init;

            // 保存ボタン押下
            testModalController.screenSupplierPlanBulkChg.changeDestinationSelected = testModalController.ScreenSupplierPlanBulkChg.changeDestinationList[1].getValue();
            testModalController.screenSupplierPlanBulkChg.screenDetailBuildingList[0].selected = true;
            testModalController.saveProcess();

            // クローズ処理
            testController.closeSupplierPlanBulkChg();
        }
    }

    // 火災保険会社プランの業者プラン一括変更画面の起動テスト
    @isTest static void openSupplierPlanBulkChgFireInsuranceCorpTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD101002Test@horaguchi.com'];
        system.runas(userRecord){
            // 取引先
            Account account = [SELECT Id
                               FROM Account
                               WHERE Name = 'テスト株式会社'];

            // 物件登録画面の初期表示
            PageReference pageRef = Page.GD101002View;
            pageRef.getParameters().put('Id', account.Id );
            Test.setCurrentPage(pageRef);

            // 火災保険会社プランの業者プラン一括変更画面の起動テスト
            GD101002Controller testController = new GD101002Controller();
            testController.screenFireList[1].fireCheck = true;  //問合せNo0655でソート順変更による取得データ変更
            testController.openSupplierPlanBulkChgFireInsuranceCorp();

            // 業者プラン一括変更画面の初期表示
            GD101002Modal2Controller testModalController = new GD101002Modal2Controller();
            testModalController.Parameter = testController.GD101002Modal2Parameter;
            Boolean init = testModalController.init;

            // 保存ボタン押下
            testModalController.screenSupplierPlanBulkChg.changeDestinationSelected = testModalController.ScreenSupplierPlanBulkChg.changeDestinationList[1].getValue();
            testModalController.screenSupplierPlanBulkChg.screenDetailBuildingList[0].selected = true;
            testModalController.saveProcess();

            // クローズ処理
            testController.closeSupplierPlanBulkChg();
        }
    }

    // 管理会社指定商品の業者プラン一括変更画面の起動
    @isTest static void openSupplierPlanBulkChgManaCorpItemTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD101002Test@horaguchi.com'];
        system.runas(userRecord){
            // 取引先
            Account account = [SELECT Id
                               FROM Account
                               WHERE Name = 'テスト株式会社'];

            // 物件登録画面の初期表示
            PageReference pageRef = Page.GD101002View;
            pageRef.getParameters().put('Id', account.Id );
            Test.setCurrentPage(pageRef);

            // 管理会社指定商品の業者プラン一括変更画面の起動
            GD101002Controller testController = new GD101002Controller();
            testController.screenManaComItemList[0].manaComItemCheck = true;
            testController.openSupplierPlanBulkChgManaCorpItem();

            // 業者プラン一括変更画面の初期表示
            GD101002Modal2Controller testModalController = new GD101002Modal2Controller();
            testModalController.Parameter = testController.GD101002Modal2Parameter;
            Boolean init = testModalController.init;

            // 保存ボタン押下
            testModalController.screenSupplierPlanBulkChg.changeDestinationSelected = testModalController.ScreenSupplierPlanBulkChg.changeDestinationList[1].getValue();
            testModalController.screenSupplierPlanBulkChg.screenDetailBuildingList[0].selected = true;
            testModalController.saveProcess();

            // クローズ処理
            testController.closeSupplierPlanBulkChg();
        }
    }

    @isTest static void openSupplierPlanBulkChgCoverageUp() {
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runas(thisUser){
            // 取引先
            Account account = [SELECT Id
                               FROM Account
                               WHERE Name = 'テスト株式会社'];

            // 物件登録画面の初期表示
            PageReference pageRef = Page.GD101002View;
            pageRef.getParameters().put('Id', account.Id );
            Test.setCurrentPage(pageRef);

            // 管理会社指定商品の業者プラン一括変更画面の起動
            GD101002Controller testController = new GD101002Controller();
            testController.screenManaComItemList[0].manaComItemCheck = true;
            testController.openSupplierPlanBulkChgManaCorpItem();

            // 業者プラン一括変更画面の初期表示（複数呼び出し）
            GD101002Modal2Controller testModalController = new GD101002Modal2Controller();
            testModalController.Parameter = testController.GD101002Modal2Parameter;
            Boolean init = testModalController.init;
            testModalController.Parameter.isDrawing = false;
            init = testModalController.init;

            // プロパティの呼び出し
            String prop = testModalController.MSG_SELECTION_OR_MORE_BUILDING;
            prop = testModalController.MSG_COMPLETE_SAVE;

            // 保存ボタン押下（変更先未選択）
            testModalController.screenSupplierPlanBulkChg.screenDetailBuildingList[0].selected = true;
            testModalController.saveProcess();
        }
    }
}