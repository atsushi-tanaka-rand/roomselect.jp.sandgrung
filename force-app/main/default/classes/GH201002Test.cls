/**
 * 店舗登録のテスト
 */
@isTest 
private class GH201002Test {

	//テストに使用するレコードを作成する
	@testSetup static void Setting(){
		//テスト用レコードを作成
        Shop__c testTargetRecord = new Shop__c(
                                                  Name = 'ランド店' // 店舗名
                                                 ,Email__c = 'test@mail.com' // メール
                                                 ,Phone__c = '123456' // TEL
                                                 ,Fax__c = '123456789' // FAX
                                                 ,PostalCode__c = '123-4567' // 郵便番号
                                                 ,State__c = '愛知県' // 都道府県
                                                 ,City__c = '名古屋市' // 住所1（丁目まで）
                                                //  ,Street__c = 'テスト町' // 住所２（番地以降）
                                                 ,District__c = '瑞穂区' // 所在地区
                                                 ,BusinessHours__c = '9:00～21:00' // 営業時間
                                                 ,RegularHoliday__c = '金曜日' // 定休日
                                                 ,Homepage__c = '' // 店舗URL
                                                 ,AffiliationAssociation__c = 'テスト協会' // 加盟協会
                                                 ,SystemUseStartDate__c = CommonUtil.getToday() // システム利用開始日
                                                 ,SystemUseEndDate__c = CommonUtil.getToday() // システム利用終了日
                                                 ,PotalCooperationStartDate__c = CommonUtil.getToday() // ポータル連携開始日
                                                 ,PotalCooperationEndDate__c = CommonUtil.getToday() // ポータル連携終了日
                                                 ,SuumoCompanyCode__c = '123456' // SUUMO会社コード
                                                 ,SuumoBranchCode__c = '123' // SUUMO支店コード
                                                 ,AthomeYourCompanyId__c = '123' // athome貴社ID
                                                 ,AthomeYourShopId__c = '12345678901234567890' // athome貴社店舗ID
                                                 ,HomesMemberNumber__c = '1234566' // HOME'S会員番号
												 ,IsChintaiPanoramaContract__c = TRUE	// CHINTAIパノラマ掲載契約 2022/03/24 CHINTAI対応追加
												 ,ChintaiCompanyCode__c = '1234'	//CHINTAI店舗コード 2022/03/24 CHINTAI対応追加
                                                 ,InvoiceRegistNumber__c = '番号123' // インボイス制度登録番号
                                                 ,PortalSitePostingDistrict__c = '瑞穂区' // ポータル掲載地区
                                                 ,IsSuumoPropertyShow__c = TRUE // SUUMO物件名表示
                                                 ,IsHomesPropertyShow__c = TRUE // at home物件名表示
                                                 ,IsAtHomePropertyShow__c = TRUE // HOME'S物件名表示
												 ,IsChintaiPropertyShow__c = TRUE //CHINTAI物件名表示 2022/03/24 CHINTAI対応追加
                                              );

        insert testTargetRecord;

        testTargetRecord = [SELECT Id FROM Shop__c WHERE Name = 'ランド店'];


        Building__c testBuildingRecord = new Building__c(
                                                             Name = 'テスト建物0001' // 建物名
                                                            ,District__c = '瑞穂区' // 地区
                                                        );

        insert testBuildingRecord;

        testBuildingRecord = [SELECT Id FROM Building__c WHERE Name = 'テスト建物0001'];


        Property__c testPropertyRecord = new Property__c(
                                                             Name = 'テスト部屋番号0001' // 部屋番号
                                                            ,Building__c = testBuildingRecord.Id // 建物
                                                        );

        insert testPropertyRecord;

        testPropertyRecord = [SELECT Id FROM Property__c WHERE Name = 'テスト部屋番号0001'];


        PortalSitePostingProperty__c testPortalSitePostingPropertyRecord = new PortalSitePostingProperty__c	(
                                                                                                               IsSuumo__c = TRUE // SUUMO
                                                                                                              ,IsHomes__c = TRUE // HOME'S
                                                                                                              ,IsAtHome__c = TRUE // at home
																											  ,IsChintaiNet__c = TRUE // 2022/03/24 CHINTAI対応追加
                                                                                                              ,Shop__c = testTargetRecord.Id // 店舗
                                                                                                              ,Property__c = testPropertyRecord.Id // 物件
                                                                                                            );

        insert testPortalSitePostingPropertyRecord;


    }
		

	//初期表示：表示データあり
     @isTest static void initializeExistsPortalSiteTest(){
        Shop__c testTargetRecord = [SELECT Id, IsChintaiPanoramaContract__c, ChintaiCompanyCode__c FROM Shop__c WHERE Name = 'ランド店'];
        Building__c testBuildingRecord = [SELECT Id, District__c FROM Building__c WHERE Name = 'テスト建物0001'];


        //パラメータ設定
        PageReference pageRef = Page.GH201002View;
        pageRef.getParameters().put('Id',testTargetRecord.Id );
        Test.setCurrentPage(pageRef);

         //コントローラ作成
        GH201002Controller testController = new GH201002Controller();

        //「店舗」が設定されている？
        system.assertEquals(testTargetRecord.Id, testController.screenTargetRecord.targetRecord.Id );
		// ▼ 2022/03/28 CHINTAI対応追加
        system.assertEquals(testTargetRecord.ChintaiCompanyCode__c, testController.screenTargetRecord.ChintaiCompanyCode);
        system.assertEquals(testTargetRecord.IsChintaiPanoramaContract__c, testController.screenTargetRecord.IsChintaiPanoramaContract);
		// ▲ 2022/03/28 CHINTAI対応追加

        //「ポータル明細リスト」が設定されている？
        for(GH201002Controller.portalSiteStatement inPortalSiteStatement : testController.portalSiteStatementList){
            if(inPortalSiteStatement.district == testBuildingRecord.District__c){
                system.assertEquals(inPortalSiteStatement.suumoCount, 1 );
                system.assertEquals(inPortalSiteStatement.athomeCount, 1 );
				system.assertEquals(inPortalSiteStatement.chintaiCount, 1 ); // 2022/03/24 CHINTAI対応追加
            }else{
                system.assertEquals(inPortalSiteStatement.suumoCount, 0 );
                system.assertEquals(inPortalSiteStatement.athomeCount, 0 );
                system.assertEquals(inPortalSiteStatement.homesCount, 0 );
				system.assertEquals(inPortalSiteStatement.chintaiCount, 0); // 2022/03/24 CHINTAI対応追加
            }
        }
    }	
		

	//初期表示：表示データなし
	@isTest static void initializeNotExistsPortalSiteTest(){
         //コントローラ作成
        GH201002Controller testController = new GH201002Controller();

        //「店舗」が新規に設定されている？
        system.assertEquals(null, testController.screenTargetRecord.targetRecord.Id );
		// ▼ 2022/03/28 CHINTAI対応追加
		system.assertEquals(null, testController.screenTargetRecord.ChintaiCompanyCode);
        system.assertEquals(false, testController.screenTargetRecord.IsChintaiPanoramaContract);
		// ▲ 2022/03/28 CHINTAI対応追加

        //「ポータル明細リスト」が設定されている？
        for(GH201002Controller.portalSiteStatement inPortalSiteStatement : testController.portalSiteStatementList){
            system.assertEquals(inPortalSiteStatement.suumoCount, 0 );
            system.assertEquals(inPortalSiteStatement.athomeCount, 0 );
            system.assertEquals(inPortalSiteStatement.homesCount, 0 );
			system.assertEquals(inPortalSiteStatement.chintaiCount, 0); // 2022/03/24 CHINTAI対応追加
        }
    }	
		

	//保存ボタン押下処理
     @isTest static void targetRecordSaveTest(){
        Shop__c testTargetRecord = [SELECT Id, IsChintaiPanoramaContract__c, ChintaiCompanyCode__c FROM Shop__c WHERE Name = 'ランド店'];


        //パラメータ設定
        PageReference pageRef = Page.GH201002View;
        pageRef.getParameters().put('Id',testTargetRecord.Id );
        Test.setCurrentPage(pageRef);

         //コントローラ作成
        GH201002Controller testController = new GH201002Controller();

        //更新時間調整用に待機
        CommonUtil.sleep(1000);

        //保存
        testController.targetRecordSave();

        Shop__c savedTestTargetRecord = [SELECT SystemModStamp FROM Shop__c WHERE Name = 'ランド店'];

        //「店舗」が設定されている？
        system.assertEquals(testTargetRecord.Id, testController.screenTargetRecord.targetRecord.Id );
		// ▼ 2022/03/28 CHINTAI対応追加
		system.assertEquals(testTargetRecord.ChintaiCompanyCode__c, testController.screenTargetRecord.ChintaiCompanyCode);
		system.assertEquals(testTargetRecord.IsChintaiPanoramaContract__c, testController.screenTargetRecord.IsChintaiPanoramaContract);
		// ▲ 2022/03/28 CHINTAI対応追加

        //「店舗」が更新されている？
        system.assertNotEquals(savedTestTargetRecord.SystemModStamp, testController.screenTargetRecord.targetRecord.systemModStamp );


    }	
		

	//削除ボタン押下処理
     @isTest static void targetRecordDeleteTest(){
        Shop__c testTargetRecord = [SELECT Id FROM Shop__c WHERE Name = 'ランド店'];


        //パラメータ設定
        PageReference pageRef = Page.GH201002View;
        pageRef.getParameters().put('Id',testTargetRecord.Id );
        Test.setCurrentPage(pageRef);

         //コントローラ作成
        GH201002Controller testController = new GH201002Controller();

        //削除
        testController.targetRecordDelete();

        List<Shop__c> deletedTestTargetRecord = [SELECT Id FROM Shop__c WHERE Name = 'ランド店'];

        //「店舗」が削除されている？
        system.assertEquals(deletedTestTargetRecord.size(), 0 );

    }	
		

	//郵便番号検索・住所検索押下処理
     @isTest static void GA102006FormTest(){
        Shop__c testTargetRecord = [SELECT Id FROM Shop__c WHERE Name = 'ランド店'];


        //パラメータ設定
        PageReference pageRef = Page.GH201002View;
        pageRef.getParameters().put('Id',testTargetRecord.Id );
        Test.setCurrentPage(pageRef);

         //コントローラ作成
        GH201002Controller testController = new GH201002Controller();

        //郵便番号検索・住所検索表示
        testController.GA102006FormOpen();

        //郵便番号検索・住所検索非表示
        testController.GA102006FormClose();
    }	
		

	//初期表示(異常系)
     @isTest static void parameterErrorTest(){
        Shop__c testTargetRecord = [SELECT Id FROM Shop__c WHERE Name = 'ランド店'];

        // 存在しないIDを作成
        String stringId = testTargetRecord.Id;
        String convertChar;

        // 作成した店舗レコードIDを修正して、店舗レコードIDと重複しないIDを作成する
        if(stringId.right(1) == '0'){
            convertChar = 'a';
        }else{
            convertChar = '0';
        }

        stringId = stringId.left(stringId.length() - 1) ;
        stringId = stringId + convertChar;


        //パラメータ設定
        PageReference pageRef = Page.GH201002View;
        pageRef.getParameters().put('Id',stringId );
        Test.setCurrentPage(pageRef);

         //コントローラ作成
        GH201002Controller testController = new GH201002Controller();

        //「エラーフラグ」がTRUEに設定されている？
        system.assertEquals(testController.isOpenError, TRUE);
        //「エラーメッセージ」が正しく設定されている？
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonConst.MSG_COM_E_SYSTEM_PARAMETER);

    }	
		

	//保存(異常系)1:必須入力エラー
     @isTest static void targetRecordRequiredNotInputSaveErrorTest(){
        //パラメータ設定
        PageReference pageRef = Page.GH201002View;
        Test.setCurrentPage(pageRef);

         //コントローラ作成
        GH201002Controller testController = new GH201002Controller();

        //保存
        testController.targetRecordSave();

        //「エラーフラグ」がTRUEに設定されている？
        system.assertEquals(testController.hasErrorMessage, TRUE);

        //入力チェックエラー文作成
        List<String> requiredItem = new List<String>();

        requiredItem.add('店舗名');

        //「エラーメッセージ」が正しく設定されている？
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ',')));

        // 事前作成の「ランド店」以外の店舗を取得
        List<Shop__c> savedTestTargetRecord = [SELECT Id FROM Shop__c WHERE Name != 'ランド店'];

        //「店舗」が保存されていない？
        system.assertEquals(savedTestTargetRecord.size(), 0 );

    }	
		

	//保存(異常系)2:楽観ロックチェックエラー
     @isTest static void targetRecordSaveErrorTest(){
        Shop__c testTargetRecord = [SELECT Id FROM Shop__c WHERE Name = 'ランド店'];

        //パラメータ設定
        PageReference pageRef = Page.GH201002View;
        pageRef.getParameters().put('Id',testTargetRecord.Id );
        Test.setCurrentPage(pageRef);

         //コントローラ作成
        GH201002Controller testController = new GH201002Controller();
        
        //更新時間調整用に待機
        CommonUtil.sleep(1000);

        //保存
        testController.targetRecordSave();

        //保存1回目後の更新日時取得
        Shop__c savedTestTargetRecord1 = [SELECT SystemModStamp FROM Shop__c WHERE Name = 'ランド店'];

        //更新時間調整用に待機
        CommonUtil.sleep(1000);

        //再保存
        testController.targetRecordSave();

        //保存2回目後の更新日時取得
        Shop__c savedTestTargetRecord2 = [SELECT SystemModStamp FROM Shop__c WHERE Name = 'ランド店'];

        //「エラーフラグ」がTRUEに設定されている？
        system.assertEquals(testController.hasErrorMessage, TRUE);

        //「エラーメッセージ」が正しく設定されている？
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK));

        //「店舗」が設定されている？
        system.assertEquals(testTargetRecord.Id, testController.screenTargetRecord.targetRecord.Id );

        //「店舗」が2回目の保存で更新されていない？
        system.assertEquals(savedTestTargetRecord1.SystemModStamp, savedTestTargetRecord1.SystemModStamp );
    }	
		

	//削除(異常系)
     @isTest static void targetRecordDeleteErrorTest(){
        Shop__c testTargetRecord = [SELECT Id FROM Shop__c WHERE Name = 'ランド店'];

        //パラメータ設定
        PageReference pageRef = Page.GH201002View;
        pageRef.getParameters().put('Id',testTargetRecord.Id );
        Test.setCurrentPage(pageRef);

         //コントローラ作成
        GH201002Controller testController = new GH201002Controller();
        
        //削除
        testController.targetRecordDelete();

        //再削除
        testController.targetRecordDelete();

        //「エラーフラグ」がTRUEに設定されている？
        system.assertEquals(testController.hasErrorMessage, TRUE);

        //「エラーメッセージ」が正しく設定されている？
        //system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK));
        system.debug('ApexPages.getMessages()[0].getDetail()' + ApexPages.getMessages()[0].getDetail());
        // system.assertEquals(ApexPages.getMessages()[0].getDetail(),CommonConst.MSG_COM_E_NOTICE_DELETED);
    }	

    // 写真処理
    @isTest static void shopPhotoTest(){
        Shop__c testTargetRecord = [SELECT Id FROM Shop__c WHERE Name = 'ランド店'];

        //パラメータ設定
        PageReference pageRef = Page.GH201002View;
        pageRef.getParameters().put('Id',testTargetRecord.Id );
        Test.setCurrentPage(pageRef);

         //コントローラ作成
        GH201002Controller testController = new GH201002Controller();

        // 写真アップロード後処理
        testController.updateShopPhoto();

        // 写真削除処理
        testController.deleteShopPhoto();
    }
}