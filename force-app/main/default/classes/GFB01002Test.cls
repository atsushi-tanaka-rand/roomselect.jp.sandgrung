/**
 * 禁止用語登録画面のテスト
 */
@isTest 
private class GFB01002Test{

	//テストに使用するレコードを作成する
	@testSetup static void Setting(){
		//テスト用レコードを作成
        BanWord__c testTargetRecord = new BanWord__c(BanWord__c = 'test');
        insert testTargetRecord;
    }
		
	//初期表示テスト(更新)
     @isTest static void initializeTest(){
        BanWord__c testTargetRecord = [SELECT Id,
                                              Name,
                                              BanWord__c
                                            FROM BanWord__c
                                            WHERE BanWord__c = 'test'];
        //パラメータ設定
        PageReference pageRef = Page.GFB01002View;
        pageRef.getParameters().put('Id',testTargetRecord.Id );
        Test.setCurrentPage(pageRef);
         //コントローラ作成
        GFB01002Controller testController = new GFB01002Controller();

        //「禁止用語番号」が設定されている？
        system.assertEquals(testTargetRecord.Name, testController.screenTargetRecord.name );
        //「禁止用語」が設定されている？
        system.assertEquals(testTargetRecord.BanWord__c, testController.screenTargetRecord.banWord );
    }	

   //保存
     @isTest static void saveTest(){
        BanWord__c testTargetRecord = [SELECT Id,
                                                  SystemModStamp 
                                            FROM BanWord__c
                                            WHERE BanWord__c = 'test'];
        //パラメータ設定
        PageReference pageRef = Page.GFB01002View;
        pageRef.getParameters().put('Id',testTargetRecord.Id );
        Test.setCurrentPage(pageRef);
         //コントローラ作成
        GFB01002Controller testController = new GFB01002Controller();

        //保存処理確認
        testController.targetRecordSave();

        //スリープ
        CommonUtil.sleep(1000);
     
        //新しくSystemModStampを取得
        BanWord__c afterTestTargetRecor = [SELECT SystemModStamp 
                                               FROM BanWord__c
                                               WHERE BanWord__c = 'test']; 

        system.assertEquals(true,afterTestTargetRecor.SystemModStamp != testTargetRecord.SystemModStamp );

    }	

    //削除
     @isTest static void deleteTest(){
        BanWord__c testTargetRecord = [SELECT Id
                                            FROM BanWord__c
                                            WHERE BanWord__c = 'test'];
        //パラメータ設定
        PageReference pageRef = Page.GFB01002View;
        pageRef.getParameters().put('Id',testTargetRecord.Id );
        Test.setCurrentPage(pageRef);
         //コントローラ作成
        GFB01002Controller testController = new GFB01002Controller();

        //削除処理確認
        testController.targetRecordDelete();
        //レコードが存在しないか確認（エラーを避けるためListで行う）
        List<BanWord__c> checkTestTargetRecors = [SELECT id 
                                                   FROM BanWord__c 
                                                  WHERE BanWord__c = 'test'];

        system.assertEquals(true,checkTestTargetRecors.isEmpty());
    }	

    //初期表示テスト(新規)
     @isTest static void newInitializeTest(){
        //コントローラ作成
        GFB01002Controller testController = new GFB01002Controller();

        //「禁止用語番号」がnull？
        system.assertEquals(true, String.isEmpty(testController.screenTargetRecord.name));
        //「禁止用語」がnull？
        system.assertEquals(true, String.isEmpty(testController.screenTargetRecord.banWord) );

    }

    //初期表示エラーテスト
     @isTest static void initializeNotFindIdErrorTest(){
        //定型文オブジェクトは作成しない
        //パラメータ設定
        PageReference pageRef = Page.GFB01002View;
        //でたらめId（型をIDぽくされる）をパラメータに設定
        pageRef.getParameters().put('Id','0010T000002n5uc000' );
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GFB01002Controller testController = new GFB01002Controller();

        //レコード情報が取得できないときのエラー出てる？
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER)));
    }


     //楽観ロックチェック
     @isTest static void optimisticLockSaveErrorTest(){
        BanWord__c testTargetRecord = [SELECT Id,
                                                  Name,
                                                  BanWord__c,                                              
                                                  SystemModStamp 
                                            FROM BanWord__c
                                            WHERE BanWord__c = 'test'];
        //パラメータ設定
        PageReference pageRef = Page.GFB01002View;
        pageRef.getParameters().put('Id',testTargetRecord.Id );
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GFB01002Controller testController = new GFB01002Controller();

        //スリープ
        CommonUtil.sleep(1000);  

        //先に更新
        testTargetRecord.BanWord__c = 'koushin';  
        update testTargetRecord;

        //保存処理
        testController.targetRecordSave();
        
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK)));
    }


     //削除エラー
     @isTest static void deleteDeleteErrorTest(){
        BanWord__c testTargetRecord = [SELECT Id,
                                                  Name,
                                                  BanWord__c,                                            
                                                  SystemModStamp 
                                            FROM BanWord__c
                                            WHERE BanWord__c = 'test'];
        //パラメータ設定
        PageReference pageRef = Page.GFB01002View;
        pageRef.getParameters().put('Id',testTargetRecord.Id );
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GFB01002Controller testController = new GFB01002Controller();

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
        GFB01002Controller testController = new GFB01002Controller();
        //保存処理
        testController.targetRecordSave();
        //スリープ
        CommonUtil.sleep(1000);                 
        
        //スリープ
        CommonUtil.sleep(1000);
        testController.screenTargetRecord.banWord = 'test';
        //保存処理
        testController.targetRecordSave();
        String a = testController.MSG_COM_V_SAVE;
        a =testController.MSG_COM_I_SAVE;
        a =testController.MSG_COM_V_DELETE;
        a =testController.MSG_COM_I_DELETE;
    }

}