/**
 * 保証会社選択モーダルテスト
 */

@isTest 
private class GD101003Test{
    
    @testSetup static void Setting(){
        //取引先作成
        Account accountRecord1 = new Account(Name = 'テスト保証株式会社');
        Account accountRecord2 = new Account(Name = 'テスト2保証株式会社');
        List<Account> accountList = new List<Account> {accountRecord1,accountRecord2};
        insert accountList;
        //商品作成
        Item__c itemRecord1 = new Item__c(
                Account__c = accountRecord1.id
                ,ItemName__c = 'テスト保証株式会社'
                ,AssuranceContent__c = 'テスト保証内容'
                ,Remarks__c = 'テスト保証備考'
                ,DirectDebitFeeTaxType__c = '課税'
                ,DirectDebitFee__c = 10000
                ,RecordTypeId =CommonUtil.getRecordTypeId('Item__c', commonConst.ITEM_RECTYPE_GUARANTEE_PLAN));

        Item__c itemRecord2 = new Item__c(
                Account__c = accountRecord2.id
                ,ItemName__c = 'テスト2保証株式会社'
                ,AssuranceContent__c = 'テスト2保証内容'
                ,Remarks__c = 'テスト2保証備考'
                ,DirectDebitFeeTaxType__c = '非課税'
                ,DirectDebitFee__c = 10000
                ,RecordTypeId = CommonUtil.getRecordTypeId('Item__c', commonConst.ITEM_RECTYPE_GUARANTEE_PLAN));
        List<Item__c> itemList = new List<Item__c> {itemRecord1,itemRecord2};
        insert itemList;
    }

    //=========================================================================================
    //◇初期表示
    @isTest static void initializeTest(){
        GD101003Controller GD101003Controller = new GD101003Controller();
        GD101003ParameterClass GD101003Parameter = new GD101003ParameterClass();

        // ページ遷移時の設定
        GD101003Parameter.isDrawing = true;
        GD101003Parameter.noFirst = true;

        // コントローラの共通クラスを設定
        GD101003Controller.Parameter = GD101003Parameter;

        // コントローラの初期表示を実行
        Boolean isInit = GD101003Controller.init;

        //全項目空白？
        system.assertEquals(GD101003Controller.accountScreenText, '');
        system.assertEquals(GD101003Controller.itemNameScreenText, '');
        system.assertEquals(GD101003Controller.guaranteePlanScreenText, '');
        //パラメータのitemListのサイズは0？
        system.assertEquals(GD101003Controller.targetList.size(), 0);
    }

    //◇検索
    @isTest static void searchTest(){
        GD101003Controller GD101003Controller = new GD101003Controller();
        GD101003ParameterClass GD101003Parameter = new GD101003ParameterClass();
        // ページ遷移時の設定
        GD101003Parameter.isDrawing = true;
        GD101003Parameter.noFirst = true;
        // コントローラの共通クラスを設定
        GD101003Controller.Parameter = GD101003Parameter;
        // コントローラの初期表示を実行
        Boolean isInit = GD101003Controller.init;

        //検索処理実
        GD101003Controller.search();
        //テストデータ数とtargetRecordのサイズが同じになる？
        system.assertEquals(GD101003Controller.targetList.size(),2);
    }


    //◇選択ボタン押下処理
    @isTest static void selectTest(){
        GD101003Controller GD101003Controller = new GD101003Controller();
        GD101003ParameterClass GD101003Parameter = new GD101003ParameterClass();
        // ページ遷移時の設定
        GD101003Parameter.isDrawing = true;
        GD101003Parameter.noFirst = true;
        // コントローラの共通クラスを設定
        GD101003Controller.Parameter = GD101003Parameter;
        // コントローラの初期表示を実行
        Boolean isInit = GD101003Controller.init;

        //検索処理実
        GD101003Controller.search();
        //ヘッダーチェックボックスTrueに変更
        GD101003Controller.headerCheckbox = true;
        //ヘッダーチェックボックス押下処理
        GD101003Controller.targetList[0].checkBox=true;
        GD101003Controller.targetList[1].checkBox=true;
        //選択ボタン押下処理
        GD101003Controller.selectButton();
        //パラメータクラスのitemListに値が入っている？
        system.assertEquals(GD101003Controller.Parameter.itemList.size(),2);
    } 

    //◇検索結果0件
    @isTest static void searchErrorTest(){
        GD101003Controller GD101003Controller = new GD101003Controller();
        GD101003ParameterClass GD101003Parameter = new GD101003ParameterClass();
        // ページ遷移時の設定
        GD101003Parameter.isDrawing = true;
        GD101003Parameter.noFirst = true;
        // コントローラの共通クラスを設定
        GD101003Controller.Parameter = GD101003Parameter;
        // コントローラの初期表示を実行
        Boolean isInit = GD101003Controller.init;
        
        //検索条件設定
        GD101003Controller.accountScreenText = 'aaaaaaa';
        //検索処理実
        GD101003Controller.search();
        //0件エラー出てる？
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_NO_DATA)));

    }

    
    //◇選択エラー処理
    @isTest static void selectErrorTest(){
        GD101003Controller GD101003Controller = new GD101003Controller();
        GD101003ParameterClass GD101003Parameter = new GD101003ParameterClass();
        // ページ遷移時の設定
        GD101003Parameter.isDrawing = true;
        GD101003Parameter.noFirst = true;
        // コントローラの共通クラスを設定
        GD101003Controller.Parameter = GD101003Parameter;
        // コントローラの初期表示を実行
        Boolean isInit = GD101003Controller.init;

        //検索処理実
        GD101003Controller.search();
        //選択ボタン押下処理
        GD101003Controller.selectButton();
        //パラメータクラスのitemListに値が入っている？
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SELECTION_OR_MORE,'チェックボックス','1')));

    } 
    //2020-4-27 カバレッジ率あげ
    @isTest static void coverageUp(){
        GD101003Controller GD101003Controller = new GD101003Controller();
        GD101003ParameterClass GD101003Parameter = new GD101003ParameterClass();
        // ページ遷移時の設定
        GD101003Parameter.isDrawing = true;
        GD101003Parameter.noFirst = true;
        // コントローラの共通クラスを設定
        GD101003Controller.Parameter = GD101003Parameter;
        // コントローラの初期表示を実行
        Boolean isInit = GD101003Controller.init;
        GD101003Controller.accountScreenText = 'aaaaa';
        GD101003Controller.itemNameScreenText = 'aaaaa';
        GD101003Controller.guaranteePlanScreenText = 'aaaaa';
        //検索処理実
        GD101003Controller.search();

        //選択ボタン押下処理
        GD101003Controller.selectButton();

        
    }

}