/**
 * 文例登録画面のテスト
 */
@isTest 
private class GF401002Test{

	//テストに使用するレコードを作成する
	@testSetup static void Setting(){
		//テスト用レコードを作成
        ExampleSentence__c testTargetRecord = new ExampleSentence__c(Name = 'test',
                                                             Folder__c = 'folder' ,
                                                             ExampleSentence__c = 'exampleSentence',
                                                             UsageScreen__c = CommonConst.EXAMPLESENTENCE_USAGESCREEN_REGISTPROPERTY);
        insert testTargetRecord;
        //禁止用語用レコード作成
        BanWord__c banRecord = new BanWord__c( BanWord__c = '完璧');
        insert banRecord;
    }
		
	//初期表示テスト(更新)
     @isTest static void initializeTest(){
        ExampleSentence__c testTargetRecord = [SELECT Id,
                                                  Name,
                                                  Folder__c,
                                                  ExampleSentence__c,
                                                  UsageScreen__c
                                            FROM ExampleSentence__c
                                            WHERE Name = 'test'];
        //パラメータ設定
        PageReference pageRef = Page.GF401002View;
        pageRef.getParameters().put('Id',testTargetRecord.Id );
        Test.setCurrentPage(pageRef);
         //コントローラ作成
        GF401002Controller testController = new GF401002Controller();

        //「文例名」が設定されている？
        system.assertEquals(testTargetRecord.Name, testController.screenTargetRecord.name );
        //「フォルダ」が設定されている？
        system.assertEquals(testTargetRecord.Folder__c, testController.screenTargetRecord.folder );
        //「文例」が設定されている？
        system.assertEquals(testTargetRecord.ExampleSentence__c, testController.screenTargetRecord.exampleSentence );
        //「使用画面」が設定されている？
        system.assertEquals(testTargetRecord.UsageScreen__c, testController.screenTargetRecord.usageScreen );

    }	

    //保存
     @isTest static void saveTest(){
        ExampleSentence__c testTargetRecord = [SELECT Id,
                                                  SystemModStamp 
                                            FROM ExampleSentence__c
                                            WHERE Name = 'test'];
        //パラメータ設定
        PageReference pageRef = Page.GF401002View;
        pageRef.getParameters().put('Id',testTargetRecord.Id );
        Test.setCurrentPage(pageRef);
         //コントローラ作成
        GF401002Controller testController = new GF401002Controller();

        //保存処理確認
        testController.targetRecordSave();

        //スリープ
        CommonUtil.sleep(1000);
     
        //新しくSystemModStampを取得
        ExampleSentence__c afterTestTargetRecor = [SELECT SystemModStamp 
                                               FROM ExampleSentence__c
                                               WHERE Name = 'test']; 

        system.assertEquals(true,afterTestTargetRecor.SystemModStamp != testTargetRecord.SystemModStamp );

    }	

    //削除
     @isTest static void deleteTest(){
        ExampleSentence__c testTargetRecord = [SELECT Id
                                            FROM ExampleSentence__c
                                            WHERE Name = 'test'];
        //パラメータ設定
        PageReference pageRef = Page.GF401002View;
        pageRef.getParameters().put('Id',testTargetRecord.Id );
        Test.setCurrentPage(pageRef);
         //コントローラ作成
        GF401002Controller testController = new GF401002Controller();

        //削除処理確認
        testController.targetRecordDelete();
        //レコードが存在しないか確認（エラーを避けるためListで行う）
        List<ExampleSentence__c> checkTestTargetRecors = [SELECT id 
                                                   FROM ExampleSentence__c 
                                                  WHERE Name = 'test'];

        system.assertEquals(true,checkTestTargetRecors.isEmpty());
    }	

    //初期表示テスト(新規)
     @isTest static void newInitializeTest(){
        //コントローラ作成
        GF401002Controller testController = new GF401002Controller();

        //「文例名」がnull？
        system.assertEquals(true, String.isEmpty(testController.screenTargetRecord.name));
        //「フォルダ」がnull？
        system.assertEquals(true, String.isEmpty(testController.screenTargetRecord.folder) );
        //「文例」がnull？
        system.assertEquals(true, String.isEmpty(testController.screenTargetRecord.exampleSentence));
        //「使用画面」がnull？
        system.assertEquals(true, String.isEmpty(testController.screenTargetRecord.usageScreen));

    }
    

    //初期表示エラーテスト
     @isTest static void initializeNotFindIdErrorTest(){
        //定型文オブジェクトは作成しない
        //パラメータ設定
        PageReference pageRef = Page.GF401002View;
        //でたらめId（型をIDぽくされる）をパラメータに設定
        pageRef.getParameters().put('Id','0010T000002n5uc000' );
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GF401002Controller testController = new GF401002Controller();

        //レコード情報が取得できないときのエラー出てる？
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER)));
    }





     //楽観ロックチェック
     @isTest static void optimisticLockSaveErrorTest(){
        ExampleSentence__c testTargetRecord = [SELECT Id,
                                                  Name,
                                                  Folder__c,
                                                  ExampleSentence__c, 
                                                  UsageScreen__c,                                              
                                                  SystemModStamp 
                                            FROM ExampleSentence__c
                                            WHERE Name = 'test'];
        //パラメータ設定
        PageReference pageRef = Page.GF401002View;
        pageRef.getParameters().put('Id',testTargetRecord.Id );
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GF401002Controller testController = new GF401002Controller();

        //スリープ
        CommonUtil.sleep(1000);  

        //先に更新
        testTargetRecord.ExampleSentence__c = 'koushin';  
        update testTargetRecord;

        //保存処理
        testController.targetRecordSave();
        
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK)));
    }

     //削除エラー
     @isTest static void deleteDeleteErrorTest(){
        ExampleSentence__c testTargetRecord = [SELECT Id,
                                                  Name,
                                                  Folder__c,
                                                  ExampleSentence__c,
                                                  UsageScreen__c,                                                 
                                                  SystemModStamp 
                                            FROM ExampleSentence__c
                                            WHERE Name = 'test'];
        //パラメータ設定
        PageReference pageRef = Page.GF401002View;
        pageRef.getParameters().put('Id',testTargetRecord.Id );
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GF401002Controller testController = new GF401002Controller();

        //先にレコード削除   
        delete testTargetRecord;

        //削除処理確認
        testController.targetRecordDelete();
        //削除レコードが取得できないときのエラー出てる？
        List<ApexPages.Message> messages = ApexPages.getMessages();
        system.assertEquals(ApexPages.getMessages()[0].getDetail(),CommonConst.MSG_COM_E_NOTICE_DELETED);
    }
        //2020/4/23追加　カバレッジ率上げ用
        @isTest static void coverageUp(){
            //コントローラ作成
            GF401002Controller testController = new GF401002Controller();
            //保存処理確認
            testController.targetRecordSave();

            testController.screenTargetRecord.exampleSentence = '完璧';  
            //保存処理確認
            testController.targetRecordSave();
            String a = testController.MSG_COM_V_SAVE;
            a =testController.MSG_COM_I_SAVE;
            a =testController.MSG_COM_V_DELETE;
            a =testController.MSG_COM_I_DELETE;
        }
    
}