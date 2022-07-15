/**
 * 付帯商品登録モーダルテスト
 */
@isTest 
private class GF201002Test{
    @testSetup static void Setting(){
        Account acc = new Account(
            Name= 'name'
        );
        insert acc;
        Item__c item = new Item__c(
            Account__C = acc.id,
            ItemName__c = 'test',//商品名
            AuxiliaryItemFeeTaxType__c = '非課税',//課税区部
            AuxiliaryItemFeeCost__c = 5000,//原価
            AuxiliaryItemType__c = '鍵交換',//商品区分
            AuxiliaryItemFee__c = 5000,//料金
            Remarks__c = '備考'
        );
        insert item;

    }
    //初期表示/新規
    @isTest static void newInitializeTest(){
        GF201002Controller GF201002Controller = new GF201002Controller();
        GF201002ParameterClass GF201002Parameter = new GF201002ParameterClass();

        // ページ遷移時の設定
        GF201002Parameter.isDrawing = true;
        GF201002Parameter.noFirst = true;

        GF201002Controller.Parameter = GF201002Parameter;

       
        Boolean isInit = GF201002Controller.init;
        system.assertEquals(GF201002Controller.modalParameter.itemName, null);
    }	    

    //初期表示/編集
    @isTest static void editInitializeTest(){
        Item__c testTargetRecord = [SELECT Id,
                                            ItemName__c,
                                            AuxiliaryItemFeeTaxType__c,
                                            AuxiliaryItemFeeCost__c,                                       
                                            AuxiliaryItemType__c,
                                            AuxiliaryItemFee__c,
                                            Remarks__c
                                            FROM Item__c
                                            WHERE ItemName__c = 'test'];
        GF201002Controller GF201002Controller = new GF201002Controller();
        GF201002ParameterClass GF201002Parameter = new GF201002ParameterClass();
        
        // ページ遷移時の設定
        GF201002Parameter.isDrawing = true;
        GF201002Parameter.noFirst = true;
        GF201002Parameter.targetItem = testTargetRecord;
        GF201002Controller.Parameter = GF201002Parameter;

        // コントローラの初期表示を実行
        Boolean isInit = GF201002Controller.init;
        system.assertEquals(GF201002Controller.modalParameter.itemName, 'test');
    }
    //設定
    @isTest static void sevaTest(){
        GF201002Controller GF201002Controller = new GF201002Controller();
        GF201002ParameterClass GF201002Parameter = new GF201002ParameterClass();

        // ページ遷移時の設定
        GF201002Parameter.isDrawing = true;
        GF201002Parameter.noFirst = true;
        GF201002Controller.Parameter = GF201002Parameter;
        // コントローラの初期表示を実行
        Boolean isInit = GF201002Controller.init;

        //値を設定
        GF201002Controller.modalParameter.auxiliaryItemFeeTaxType = '課税';
        GF201002Controller.modalParameter.itemName = '設定テスト';
        GF201002Controller.modalParameter.auxiliaryItemFeeCost = '5000';
        GF201002Controller.modalParameter.auxiliaryItemType = 'アルソック';
        GF201002Controller.modalParameter.auxiliaryItemFee = '5000';
        GF201002Controller.modalParameter.remarks = '備考';
        //設置
        GF201002Controller.closeModal();
        system.assertEquals(GF201002Parameter.targetItem.ItemName__c, '設定テスト');
    }
    //設定/異常
    @isTest static void sevaErrorTest(){
        GF201002Controller GF201002Controller = new GF201002Controller();
        GF201002ParameterClass GF201002Parameter = new GF201002ParameterClass();

        // ページ遷移時の設定
        GF201002Parameter.isDrawing = true;
        GF201002Parameter.noFirst = true;
        GF201002Controller.Parameter = GF201002Parameter;
        // コントローラの初期表示を実行
        Boolean isInit = GF201002Controller.init;

        //設置
        GF201002Controller.closeModal();
        //必須エラー
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(true, messages[0].getDetail().contains('商品名,原価,料金,商品区分は入力必須です。'));
        
    }
    //2020/5/1　カバレッジ率あげ
    @isTest static void coverageUp(){
        GF201002Controller GF201002Controller = new GF201002Controller();
        GF201002ParameterClass GF201002Parameter = new GF201002ParameterClass();

        // ページ遷移時の設定
        GF201002Parameter.isDrawing = true;
        GF201002Parameter.noFirst = true;
        GF201002Controller.Parameter = GF201002Parameter;
        GF201002Controller.initAction();

        Boolean isInit = true;


        // コントローラの初期表示を実行
        isInit = GF201002Controller.init;
        GF201002Controller.initAction();
        GF201002Controller.getAuxiliaryItemFeeTaxTypeRadioButton();
    }

    
   
}