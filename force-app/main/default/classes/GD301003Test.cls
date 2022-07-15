/**
 * 業者選択モーダルテスト
 */
@isTest 
private class GD301003Test{
    @testSetup static void Setting(){
        //取引先作成
        Account accountRecord1 = new Account(
            Name = 'テスト1株式会社',
            Phone = '123-4567',
            Email__c = 'test@test',
            IsOwner__c = true,
            IsSubLease__c = true,
            IsManagementCompany__c =true,
            RecordTypeId =CommonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_SUPPLIER)      
            );
        Account accountRecord2 = new Account(
            Name = 'テスト2株式会社',
            Phone = '987-65432',
            Email__c = 'test2@test',
            IsOwner__c = true,
            RecordTypeId =CommonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_SUPPLIER)      
            );
        List<Account> accountList = new List<Account> {accountRecord1,accountRecord2};
        insert accountList;
        /*
        //システム設定
        SystemConfig__c sc = new SystemConfig__c(SupplierSearchMaxCount__c = 1000);
        insert sc;
        */
    }
    //カスタム設定の作成
    static SystemConfig__c SupplierSearchMaxCount(Decimal maxCount){
        SystemConfig__c settings = new SystemConfig__c();
        settings.SupplierSearchMaxCount__c = maxCount;//検索上限
        insert settings;
        
        return settings;
    }

    //=========================================================================================
    //◇初期表示(オーナーのみ選択可)
    @isTest static void initializeOwnerTest(){
        SupplierSearchMaxCount(1000);
        GD301003Controller GD301003Controller = new GD301003Controller();
        GD301003ParameterClass GD301003Parameter = new GD301003ParameterClass();

        // ページ遷移時の設定
        GD301003Parameter.isDrawing = true;
        GD301003Parameter.noFirst = true;
        GD301003Parameter.supplierType = GD301003ParameterClass.SupplierConst.OWNER;//パラメータ設定

        // コントローラの共通クラスを設定
        GD301003Controller.Parameter = GD301003Parameter;

        // コントローラの初期表示を実行
        Boolean isInit = GD301003Controller.init;

        //全項目空白？
        system.assertEquals(GD301003Controller.accountScreenText, '');
        system.assertEquals(GD301003Controller.telScreenText, '');
        system.assertEquals(GD301003Controller.mailScreenText, '');
        //パラメータの明細リストのサイズは0？
        system.assertEquals(GD301003Controller.targetList.size(), 0);
        //「オーナー」のチェックボックスだけtrueになってる？
        system.assertEquals(GD301003Controller.ownerCheck,true);
        system.assertEquals(GD301003Controller.managementCompanyCheck,false);
        system.assertEquals(GD301003Controller.subleaseCheck,false);
    }

   //◇初期表示（オーナー、管理会社のみ選択可）
   @isTest static void initializeFormerSupplierTest(){
        SupplierSearchMaxCount(1000);
        GD301003Controller GD301003Controller = new GD301003Controller();
        GD301003ParameterClass GD301003Parameter = new GD301003ParameterClass();

        // ページ遷移時の設定
        GD301003Parameter.isDrawing = true;
        GD301003Parameter.noFirst = true;
        GD301003Parameter.supplierType = GD301003ParameterClass.SupplierConst.FORMER_SUPPLIER;//パラメータ設定

        // コントローラの共通クラスを設定
        GD301003Controller.Parameter = GD301003Parameter;

        // コントローラの初期表示を実行
        Boolean isInit = GD301003Controller.init;

        //「オーナー」「管理会社」のチェックボックスがtrueになってる？
        system.assertEquals(GD301003Controller.ownerCheck,true);
        system.assertEquals(GD301003Controller.managementCompanyCheck,true);
        system.assertEquals(GD301003Controller.subleaseCheck,false);
    }

    //◇初期表示（全チェックボックス選択可）
   @isTest static void initializeCreditorTest(){
        SupplierSearchMaxCount(1000);

        GD301003Controller GD301003Controller = new GD301003Controller();
        GD301003ParameterClass GD301003Parameter = new GD301003ParameterClass();

        // ページ遷移時の設定
        GD301003Parameter.isDrawing = true;
        GD301003Parameter.noFirst = true;
        GD301003Parameter.supplierType = GD301003ParameterClass.SupplierConst.CREDITOR;//パラメータ設定

        // コントローラの共通クラスを設定
        GD301003Controller.Parameter = GD301003Parameter;

        // コントローラの初期表示を実行
        Boolean isInit = GD301003Controller.init;

        //全チェックボックスがtrueになってる？
        system.assertEquals(GD301003Controller.ownerCheck,true);
        system.assertEquals(GD301003Controller.managementCompanyCheck,true);
        system.assertEquals(GD301003Controller.subleaseCheck,true);
    }

    //◇検索
    @isTest static void searchTest(){
        SupplierSearchMaxCount(1000);

        GD301003Controller GD301003Controller = new GD301003Controller();
        GD301003ParameterClass GD301003Parameter = new GD301003ParameterClass();
        GD301003Parameter.supplierType = GD301003ParameterClass.SupplierConst.OWNER;//パラメータ設定
        // ページ遷移時の設定
        GD301003Parameter.isDrawing = true;
        GD301003Parameter.noFirst = true;
        // コントローラの共通クラスを設定
        GD301003Controller.Parameter = GD301003Parameter;
        // コントローラの初期表示を実行
        Boolean isInit = GD301003Controller.init;
        //検索処理実
        GD301003Controller.search();
        //「オーナー」がtrueのテストデータ数と表示レコード数（オーナーがtrueのもののみの検索結果）が一致する？
        system.assertEquals(GD301003Controller.targetList.size(),2);
    }

    //◇選択ボタン
    @isTest static void selectButtonTest(){
        SupplierSearchMaxCount(1000);

        GD301003Controller GD301003Controller = new GD301003Controller();
        GD301003ParameterClass GD301003Parameter = new GD301003ParameterClass();
        GD301003Parameter.supplierType = GD301003ParameterClass.SupplierConst.FORMER_SUPPLIER;//パラメータ設定
        // ページ遷移時の設定
        GD301003Parameter.isDrawing = true;
        GD301003Parameter.noFirst = true;
        // コントローラの共通クラスを設定
        GD301003Controller.Parameter = GD301003Parameter;
        // コントローラの初期表示を実行
        Boolean isInit = GD301003Controller.init;

        //オーナーチェックボックスをfalseにする（管理会社のチェックボックスのみtrueにする）
        GD301003Controller.ownerCheck =false;
        //検索処理実
        GD301003Controller.search();
        //明細行を設定
        GD301003Controller.index = 0;
        //選択処理実行
        GD301003Controller.selectButton();
        //パラメータクラスの返却レコードがindex[0]のものと同じ？
        system.assertEquals(GD301003Controller.targetList[GD301003Controller.index].screenAccount,GD301003Parameter.accountRecord);
    }

    //◇初期表示（異常）
    @isTest static void initializeErrorTest(){
        SupplierSearchMaxCount(1000);

        GD301003Controller GD301003Controller = new GD301003Controller();
        GD301003ParameterClass GD301003Parameter = new GD301003ParameterClass();

        // ページ遷移時の設定
        GD301003Parameter.isDrawing = true;
        GD301003Parameter.noFirst = true;
        //パラメータ設定を行わない

        // コントローラの共通クラスを設定
        GD301003Controller.Parameter = GD301003Parameter;

        // コントローラの初期表示を実行
        Boolean isInit = GD301003Controller.init;
        //パラメータが不正ですのエラーが出ている？
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER)));

    }
    //◇検索（異常）
    @isTest static void searchError(){
        SupplierSearchMaxCount(1000);

        GD301003Controller GD301003Controller = new GD301003Controller();
        GD301003ParameterClass GD301003Parameter = new GD301003ParameterClass();
        GD301003Parameter.supplierType = GD301003ParameterClass.SupplierConst.OWNER;//パラメータ設定
        // ページ遷移時の設定
        GD301003Parameter.isDrawing = true;
        GD301003Parameter.noFirst = true;
        // コントローラの共通クラスを設定
        GD301003Controller.Parameter = GD301003Parameter;
        // コントローラの初期表示を実行
        Boolean isInit = GD301003Controller.init;

        //全チェックボックスをfalseにする
        GD301003Controller.ownerCheck =false;
        //検索処理実
        GD301003Controller.search();

        //該当データがありませんのエラー出ている？
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_NO_DATA)));

    }
    //2020-4-27 カバレッジ率あげ
    @isTest static void coverageUp(){
        //システム設定
        SupplierSearchMaxCount(1);

        GD301003Controller GD301003Controller = new GD301003Controller();
        GD301003ParameterClass GD301003Parameter = new GD301003ParameterClass();
        GD301003Parameter.supplierType = GD301003ParameterClass.SupplierConst.OWNER;//パラメータ設定
        // ページ遷移時の設定
        GD301003Parameter.isDrawing = true;
        GD301003Parameter.noFirst = true;
        // コントローラの共通クラスを設定
        GD301003Controller.Parameter = GD301003Parameter;
        // コントローラの初期表示を実行
        Boolean isInit = GD301003Controller.init;
        GD301003Controller.ownerCheck = true;
        GD301003Controller.subleaseCheck = true;
        GD301003Controller.managementCompanyCheck = true;
        //検索処理実
        GD301003Controller.search();
        GD301003Controller.index = -1;
        //検索処理実
        GD301003Controller.selectButton();
    }
    
    @isTest static void coverageUp2(){
        //システム設定
        SupplierSearchMaxCount(1000);

        GD301003Controller GD301003Controller = new GD301003Controller();
        GD301003ParameterClass GD301003Parameter = new GD301003ParameterClass();
        GD301003Parameter.supplierType = GD301003ParameterClass.SupplierConst.OWNER;//パラメータ設定
        // ページ遷移時の設定
        GD301003Parameter.isDrawing = true;
        GD301003Parameter.noFirst = true;
        // コントローラの共通クラスを設定
        GD301003Controller.Parameter = GD301003Parameter;
        // コントローラの初期表示を実行
        Boolean isInit = GD301003Controller.init;
        GD301003Controller.subleaseCheck =true;
        GD301003Controller.telScreenText = 'a';
        GD301003Controller.accountScreenText = 'a';
        GD301003Controller.mailScreenText = 'a';
        //検索処理実
        GD301003Controller.search();

    }

}