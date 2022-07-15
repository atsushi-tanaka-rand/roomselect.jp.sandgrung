/**
 * 地区別（店舗別）メンテナンス条件登録画面テスト
 */
@isTest 
private class GFA01002Test{

	//テストに使用するレコードを作成する
	@testSetup static void Setting(){
		//テスト用レコード作成
        AreaMaintenanceCondition__c testTargetRecord = new AreaMaintenanceCondition__c(
                                                            District__c = '港区' ,    
                                                            PropertyAmountLowerLimit__c = 50000 ,
                                                            PropertyAmountUpperLimit__c = 600000 );
        //地区重複チェック用レコード作成
        AreaMaintenanceCondition__c duplicateAreaRecord = new AreaMaintenanceCondition__c(
                                                            District__c = '昭和区' ,    
                                                            PropertyAmountLowerLimit__c = 40000 ,
                                                            PropertyAmountUpperLimit__c = 700000 );

        List<AreaMaintenanceCondition__c> records = new List<AreaMaintenanceCondition__c> { testTargetRecord, duplicateAreaRecord };
        insert records;
    }
		
	//初期表示テスト(更新)
     @isTest static void initializeTest(){
        AreaMaintenanceCondition__c testTargetRecord = [SELECT Id,
                                                  District__c,
                                                  PropertyAmountLowerLimit__c,
                                                  PropertyAmountUpperLimit__c
                                            FROM AreaMaintenanceCondition__c
                                            WHERE District__c = '港区'];
        //パラメータ設定
        PageReference pageRef = Page.GFA01002View;
        pageRef.getParameters().put('Id',testTargetRecord.Id );
        Test.setCurrentPage(pageRef);
         //コントローラ作成
        GFA01002Controller testController = new GFA01002Controller();

        //「地区」が設定されている？
        system.assertEquals(testTargetRecord.District__c, testController.screenTargetRecord.district );
        //「取り扱い物件　上限額」が設定されている？
        system.assertEquals(testTargetRecord.PropertyAmountLowerLimit__c, commonUtil.stringToDecimal(testController.screenTargetRecord.propertyAmountLowerLimit) );
        //「取り扱い物件　下限額」が設定されている？
        system.assertEquals(testTargetRecord.PropertyAmountUpperLimit__c, commonUtil.stringToDecimal(testController.screenTargetRecord.propertyAmountUpperLimit) );

    }	

    //保存
     @isTest static void saveTest(){
        AreaMaintenanceCondition__c testTargetRecord = [SELECT Id,
                                                  SystemModStamp 
                                            FROM AreaMaintenanceCondition__c
                                            WHERE District__c = '港区'];
        //パラメータ設定
        PageReference pageRef = Page.GFA01002View;
        pageRef.getParameters().put('Id',testTargetRecord.Id );
        Test.setCurrentPage(pageRef);
         //コントローラ作成
        GFA01002Controller testController = new GFA01002Controller();

        //保存処理確認
        testController.targetRecordSave();

        //スリープ
        CommonUtil.sleep(1000);
     
        //新しくSystemModStampを取得
        AreaMaintenanceCondition__c afterTestTargetRecor = [SELECT SystemModStamp 
                                               FROM AreaMaintenanceCondition__c
                                               WHERE District__c = '港区']; 

        system.assertEquals(true,afterTestTargetRecor.SystemModStamp != testTargetRecord.SystemModStamp );

    }	

    //削除
     @isTest static void deleteTest(){
        AreaMaintenanceCondition__c testTargetRecord = [SELECT Id
                                            FROM AreaMaintenanceCondition__c
                                            WHERE District__c = '港区'];
        //パラメータ設定
        PageReference pageRef = Page.GFA01002View;
        pageRef.getParameters().put('Id',testTargetRecord.Id );
        Test.setCurrentPage(pageRef);
         //コントローラ作成
        GFA01002Controller testController = new GFA01002Controller();

        //削除処理確認
        testController.targetRecordDelete();
        //レコードが存在しないか確認（エラーを避けるためListで行う）
        List<AreaMaintenanceCondition__c> checkTestTargetRecors = [SELECT id 
                                                   FROM AreaMaintenanceCondition__c 
                                                  WHERE District__c = '港区'];

        system.assertEquals(true,checkTestTargetRecors.isEmpty());
    }	

    //初期表示テスト(新規)
     @isTest static void newInitializeTest(){
        //コントローラ作成
        GFA01002Controller testController = new GFA01002Controller();

        //「地区」がnull？
        system.assertEquals(true, String.isEmpty(testController.screenTargetRecord.district));
        //「取扱下限額」がnull？
        system.assertEquals(true, String.isEmpty(testController.screenTargetRecord.propertyAmountUpperLimit) );
        //「取扱上限額」がnull？
        system.assertEquals(true, String.isEmpty(testController.screenTargetRecord.propertyAmountLowerLimit));

    }
    

    //初期表示エラーテスト
     @isTest static void initializeNotFindIdErrorTest(){
        //地区別メンテナンス条件オブジェクトは作成しない
        //パラメータ設定
        PageReference pageRef = Page.GFA01002View;
        //でたらめId（型をIDぽくされる）をパラメータに設定
        pageRef.getParameters().put('Id','0010T000002n5uc000' );
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GFA01002Controller testController = new GFA01002Controller();

        //レコード情報が取得できないときのエラー出てる？
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER)));
    }


    //地区重複チェック
     @isTest static void duplicateAreaErrorTest(){
        AreaMaintenanceCondition__c testTargetRecord = [SELECT Id,
                                            District__c
                                            FROM AreaMaintenanceCondition__c
                                            WHERE District__c = '港区'];
        //パラメータ設定
        PageReference pageRef = Page.GFA01002View;
        pageRef.getParameters().put('Id',testTargetRecord.Id );
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GFA01002Controller testController = new GFA01002Controller();
        //禁止用語登録
        testController.screenTargetRecord.district = '昭和区';
        //保存処理
        testController.targetRecordSave();

         List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_EXISTENCE,'昭和区')));

    }

   //下限額上限額チェック
     @isTest static void ammountErrorTest(){
        AreaMaintenanceCondition__c testTargetRecord = [SELECT Id,
                                            PropertyAmountLowerLimit__c,
                                            PropertyAmountUpperLimit__c 
                                            FROM AreaMaintenanceCondition__c
                                            WHERE District__c = '港区'];
        //パラメータ設定
        PageReference pageRef = Page.GFA01002View;
        pageRef.getParameters().put('Id',testTargetRecord.Id );
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GFA01002Controller testController = new GFA01002Controller();
        //下限設定
        testController.screenTargetRecord.propertyAmountLowerLimit = commonUtil.decimalToString(2000);
        //上限設定
        testController.screenTargetRecord.propertyAmountUpperLimit = commonUtil.decimalToString(1000);

        //保存処理
        testController.targetRecordSave();
        
         List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REGISTRATION_AMOUNT_SETTING)));

    }


     //楽観ロックチェック
     @isTest static void optimisticLockSaveErrorTest(){
        AreaMaintenanceCondition__c testTargetRecord = [SELECT Id,
                                                  Name,
                                                  PropertyAmountLowerLimit__c,  
                                                  PropertyAmountUpperLimit__c,                                               
                                                  SystemModStamp 
                                            FROM AreaMaintenanceCondition__c
                                            WHERE District__c = '港区'];
        //パラメータ設定
        PageReference pageRef = Page.GFA01002View;
        pageRef.getParameters().put('Id',testTargetRecord.Id );
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GFA01002Controller testController = new GFA01002Controller();

        //スリープ
        CommonUtil.sleep(1000);  

        //先に更新
        testTargetRecord.PropertyAmountLowerLimit__c = 0;  
        update testTargetRecord;

        //保存処理
        testController.targetRecordSave();
        
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK)));
    }

     //削除エラー
     @isTest static void deleteDeleteErrorTest(){
        AreaMaintenanceCondition__c testTargetRecord = [SELECT Id,
                                                  Name,
                                                  PropertyAmountLowerLimit__c,  
                                                  PropertyAmountUpperLimit__c,                                               
                                                  SystemModStamp 
                                            FROM AreaMaintenanceCondition__c
                                            WHERE District__c = '港区'];
        //パラメータ設定
        PageReference pageRef = Page.GFA01002View;
        pageRef.getParameters().put('Id',testTargetRecord.Id );
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GFA01002Controller testController = new GFA01002Controller();

        //先にレコード削除   
        delete testTargetRecord;

        //削除処理確認
        testController.targetRecordDelete();
        //削除レコードが取得できないときのエラー出てる？
        List<ApexPages.Message> messages = ApexPages.getMessages();
        system.assertEquals(ApexPages.getMessages()[0].getDetail(),CommonConst.MSG_COM_E_NOTICE_DELETED);
    }
    
}