//業者名寄せ画面のテストクラス
@ isTest
private class GD101005Test {

	//テストに使用するテストレコードを作成する。
	@testSetup static void Setting() {

		List<SObject> Records = new List<Account>();

		Account testTargetRecord = new Account(Name = '山力株式会社', 

											   Phone = '052-492-6764', 
											   Email__c = 'tosihito83@dsn.ad.jp', 
											   PostalCode__c = '452-0033', 
											   state__c = '愛知県', 
											   city__c = '清須市', 
											   street__c = '西枇杷島町二見2-5-5', 
											   RecordTypeId = commonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_SUPPLIER));

		Account displayRecordOne = new Account(Name = '山力株式会社', 
											   Phone = '052-211-3721', 
											   Email__c = 'aaa@hora', 
											   PostalCode__c = '466-0046', 
											   state__c = '愛知県', 
											   city__c = '名古屋市', 
											   street__c = '昭和区広見町7739', 
											   RecordTypeId = commonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_SUPPLIER));

		Records.add(testTargetRecord);
		Records.add(displayRecordOne);

		Insert Records;


	}

	//初期表示テスト
	@isTest static void initializeTest() {

		Account testTargetRecord = [SELECT Id, 
								    Name, 
								    Phone, 
								    Email__c, 
								    PostalCode__c, 
								    SupplierType__c, 
								    Address__c
								    FROM Account
								    WHERE Name = '山力株式会社' AND Phone = '052-492-6764'
		];

		Account displayRecordOne = [SELECT Id, 
								    Name, 
								    Phone, 
								    Email__c, 
								    PostalCode__c, 
								    SupplierType__c, 
								    Address__c
								    FROM Account
								    WHERE Name = '山力株式会社' AND Phone = '052-211-3721'
		];


		//パラメーター設定
		PageReference pageRef = Page.GD101005View;
		PageRef.getParameters().put('Id', testTargetRecord.Id);
		Test.setCurrentPage(pageRef);

		//コントローラー作成
		GD101005Controller testController = new GD101005Controller();

		//業者名が設定されている？
		system.assertEquals(testTargetRecord.Name, testController.targetRecord.name);

		//種別が設定されている？
		system.assertEquals(testTargetRecord.SupplierType__c, testController.targetRecord.SupplierType__c);

		//メールが設定されている？
		system.assertEquals(testTargetRecord.Email__c, testController.targetRecord.Email__c);

		//電話が設定されている？
		system.assertEquals(testTargetRecord.Phone, testController.targetRecord.Phone);

		//郵便番号が設定されている？
		system.assertEquals(testTargetRecord.PostalCode__c, testController.targetRecord.PostalCode__c);

		//住所が設定されている？
		system.assertEquals(testTargetRecord.Address__c, testController.targetRecord.Address__c);




		//検索対象のお客様名が正しい？
		system.assertEquals(displayRecordOne.Name, testController.displayCandidateResult [0].candidateResult.Name);

		//検索対象のメールが正しい？
		system.assertEquals(displayRecordOne.Email__c, testController.displayCandidateResult [0].candidateResult.Email__c);

		//検索対象の電話番号が正しい？
		system.assertEquals(displayRecordOne.Phone, testController.displayCandidateResult [0].candidateResult.Phone);

        //種別の電話番号が正しい？
		system.assertEquals(displayRecordOne.SupplierType__c, testController.displayCandidateResult [0].candidateResult.SupplierType__c);

        //郵便番号が正しい？
		system.assertEquals(displayRecordOne.Postalcode__c, testController.displayCandidateResult [0].candidateResult.Postalcode__c);

        //住所が正しい？
		system.assertEquals(displayRecordOne.Address__c, testController.displayCandidateResult [0].candidateResult.Address__c);

	}

	//名寄せ不要ボタン
	@isTest static void mergeAccountsTest() {

       Account testTargetRecord = [SELECT Id, 
								    Name, 
								    Phone, 
								    Email__c, 
								    PostalCode__c, 
								    SupplierType__c, 
								    Address__c
								    FROM Account
								    WHERE Name = '山力株式会社' AND Phone = '052-492-6764'
		];


		//パラメーター設定
		PageReference pageRef = Page.GD101005View;
		PageRef.getParameters().put('Id', testTargetRecord.Id);
		Test.setCurrentPage(pageRef);

		//コントローラー作成
		GD101005Controller testController = new GD101005Controller();

		//名寄せ不要ボタン起動
		testController.margeCompleted();

		//名寄せ不要フラグ確認
		Account afterTestTargetRecord = [SELECT IsMergeCompletedFlag__c
									     FROM Account
									     WHERE Name = '山力株式会社' AND Phone = '052-492-6764'
		];

		system.assertEquals(true, afterTestTargetRecord.IsMergeCompletedFlag__c);


	}

	//コンストラクタテスト
	@isTest static void initializeErrorTest() {

        //パラメーター設定
		PageReference pageRef = Page.GD101005View;
		PageRef.getParameters().put('Id', '0060T0000023JEAQA2');
		Test.setCurrentPage(pageRef);

		//コントローラー作成
		GD101005Controller testController = new GD101005Controller();

		//エラーメッセージ確認
		List<ApexPages.Message> Messages = ApexPages.getMessages();
		system.assertEquals(true, messages [0].getdetail().contains(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));


	}


}