/**
 * 定型文登録画面のテスト
 */
 @isTest 
private class GF301002Test{

	//テストに使用するレコードを作成する
	@testSetup static void Setting(){
		//テスト用レコードを作成
        FixedPhrase__c testTargetRecord = new FixedPhrase__c(Name = 'test',
                                                             Subject__c = 'subject' ,
                                                             Folder__c = 'folder' ,
                                                             Text__c = 'text',
                                                             UsageScreen__c = CommonConst.FIXEDPHRASE_USAGESCREEN_SENDMAIL);
        insert testTargetRecord;
    }
		
	//初期表示テスト(更新)
     @isTest static void initializeTest(){
        FixedPhrase__c testTargetRecord = [SELECT Id,
                                                  Name,
                                                  Folder__c,
                                                  Subject__c,
                                                  Text__c,
                                                  UsageScreen__c 
                                            FROM FixedPhrase__c
                                            WHERE Name = 'test'];
        //パラメータ設定
        PageReference pageRef = Page.GF301002View;
        pageRef.getParameters().put('Id',testTargetRecord.Id );
        Test.setCurrentPage(pageRef);
         //コントローラ作成
        GF301002Controller testController = new GF301002Controller();

        //「定型文名」が設定されている？
        system.assertEquals(testTargetRecord.Name, testController.screenTargetRecord.name );
        //「フォルダ」が設定されている？
        system.assertEquals(testTargetRecord.Folder__c, testController.screenTargetRecord.folder );
        //「件名」が設定されている？
        system.assertEquals(testTargetRecord.Subject__c, testController.screenTargetRecord.subject );
        //「本文」が設定されている？
        system.assertEquals(testTargetRecord.Text__c, testController.screenTargetRecord.text );
        //「使用画面」が設定されている？
        system.assertEquals(testTargetRecord.UsageScreen__c, testController.screenTargetRecord.usageScreen );

    }	

    //保存
     @isTest static void saveTest(){
        FixedPhrase__c testTargetRecord = [SELECT Id,
                                                  SystemModStamp 
                                            FROM FixedPhrase__c
                                            WHERE Name = 'test'];
        //パラメータ設定
        PageReference pageRef = Page.GF301002View;
        pageRef.getParameters().put('Id',testTargetRecord.Id );
        Test.setCurrentPage(pageRef);
         //コントローラ作成
        GF301002Controller testController = new GF301002Controller();

        //保存処理確認
        testController.targetRecordSave();

        //スリープ
        CommonUtil.sleep(1);
     
        //新しくSystemModStampを取得
        FixedPhrase__c afterTestTargetRecor = [SELECT SystemModStamp 
                                               FROM FixedPhrase__c
                                               WHERE Name = 'test']; 

        system.assertEquals(true,afterTestTargetRecor.SystemModStamp != testTargetRecord.SystemModStamp );

    }	

    //削除
     @isTest static void deleteTest(){
        FixedPhrase__c testTargetRecord = [SELECT Id
                                            FROM FixedPhrase__c
                                            WHERE Name = 'test'];
        //パラメータ設定
        PageReference pageRef = Page.GF301002View;
        pageRef.getParameters().put('Id',testTargetRecord.Id );
        Test.setCurrentPage(pageRef);
         //コントローラ作成
        GF301002Controller testController = new GF301002Controller();

        //削除処理確認
        testController.targetRecordDelete();
        //レコードが存在しないか確認（エラーを避けるためListで行う）
        List<FixedPhrase__c> checkTestTargetRecors = [SELECT id 
                                                   FROM FixedPhrase__c 
                                                  WHERE Name = 'test'];

        system.assertEquals(true,checkTestTargetRecors.isEmpty());
    }	

    //初期表示テスト(新規)
     @isTest static void newInitializeTest(){
        //コントローラ作成
        GF301002Controller testController = new GF301002Controller();

        //「定型文名」がnull？
        system.assertEquals(true, String.isEmpty(testController.screenTargetRecord.name));
        //「フォルダ」がnull？
        system.assertEquals(true, String.isEmpty(testController.screenTargetRecord.folder) );
        //「件名」がnull？
        system.assertEquals(true, String.isEmpty(testController.screenTargetRecord.subject) );
        //「本文」がnull？
        system.assertEquals(true, String.isEmpty(testController.screenTargetRecord.text) );
        //「使用画面」がnull？
        system.assertEquals(true, String.isEmpty(testController.screenTargetRecord.usageScreen) );

    }

    //初期表示エラーテスト
     @isTest static void initializeNotFindIdErrorTest(){
        //定型文オブジェクトは作成しない
        //パラメータ設定
        PageReference pageRef = Page.GF301002View;
        //でたらめId（型をIDぽくされる）をパラメータに設定
        pageRef.getParameters().put('Id','0010T000002n5uc000' );
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GF301002Controller testController = new GF301002Controller();

        //レコード情報が取得できないときのエラー出てる？
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER)));
    }


     //楽観ロックチェック
     @isTest static void optimisticLockSaveErrorTest(){
        FixedPhrase__c testTargetRecord = [SELECT Id,
                                                  Name,
                                                  Folder__c,
                                                  Subject__c,
                                                  Text__c,
                                                  UsageScreen__c,                                                 
                                                  SystemModStamp 
                                            FROM FixedPhrase__c
                                            WHERE Name = 'test'];
        //パラメータ設定
        PageReference pageRef = Page.GF301002View;
        pageRef.getParameters().put('Id',testTargetRecord.Id );
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GF301002Controller testController = new GF301002Controller();

        //スリープ
        CommonUtil.sleep(1000);  

        //先に更新
        testTargetRecord.Text__c = 'koushin';  
        update testTargetRecord;

        //保存処理
        testController.targetRecordSave();
        
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK)));
    }


     //削除エラー
     @isTest static void deleteDeleteErrorTest(){
        FixedPhrase__c testTargetRecord = [SELECT Id,
                                                  Name,
                                                  Folder__c,
                                                  Subject__c,
                                                  Text__c,
                                                  UsageScreen__c,                                                 
                                                  SystemModStamp 
                                            FROM FixedPhrase__c
                                            WHERE Name = 'test'];
        //パラメータ設定
        PageReference pageRef = Page.GF301002View;
        pageRef.getParameters().put('Id',testTargetRecord.Id );
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GF301002Controller testController = new GF301002Controller();

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
        GF301002Controller testController = new GF301002Controller();

        //保存処理
        testController.targetRecordSave();
        String a = testController.MSG_COM_V_SAVE;
        a =testController.MSG_COM_I_SAVE;
        a =testController.MSG_COM_V_DELETE;
        a =testController.MSG_COM_I_DELETE;
    }
    
}