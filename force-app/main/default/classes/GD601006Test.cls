//建物名寄せ画面のテストクラス
@ isTest
private class GD601006Test {

	//テストに使用するテストレコードを作成する。
	@testSetup static void Setting() {

		List<Building__c> buildingRecords = new List<Building__c>();

		Building__c testTargetRecord = new Building__c(Name = 'サクシード', 
													   BuildKana__c = 'サクシード', 
													   PostalCode__c = '464-0859', 
													   state__c = '愛知県', 
													   city__c = '名古屋市', 
													   street__c = '千種区今池３－１４');

		Building__c displayBuildingRecordOne = new Building__c(Name = 'ｻｸｼｰﾄﾞ', 
															   BuildKana__c = 'サクシード', 
															   PostalCode__c = '464-0859', 
															   state__c = '愛知県', 
															   city__c = '名古屋市', 
															   street__c = '千種区新栄３丁目２０－１');


		Building__c displayBuildingRecordTwo = new Building__c(Name = 'SUCCEED', 
															   BuildKana__c = 'サクシード', 
															   PostalCode__c = '464-0859', 
															   state__c = '愛知県', 
															   city__c = '名古屋市', 
															   street__c = '千種区新栄３丁目');

		buildingRecords.add(testTargetRecord);
		buildingRecords.add(displayBuildingRecordOne);
		buildingRecords.add(displayBuildingRecordTwo);

		Insert buildingRecords;

		Id buildingId = testTargetRecord.id;

		List<Property__c> propertyRecords = new List<Property__c>();

		Property__c displayPropertyRecordOne = new Property__c(Name = '101', 
															   LiveStatus__c = '退去予定', 
															   RoomLayout__c = 'k', 
															   RentFee__c = 62000, 
															   RoomArea__c = 26.79, 
															   RoomCount__c = 1, 
															   Building__c = buildingId, 
															   IsMergeCompletedFlag__c = False);

		Property__c displayPropertyRecordTwo = new Property__c(Name = '102', 
															   LiveStatus__c = '空室', 
															   RoomLayout__c = 'k', 
															   RentFee__c = 62000, 
															   RoomArea__c = 26.79, 
															   RoomCount__c = 1, 
															   Building__c = buildingId, 
															   IsMergeCompletedFlag__c = true);

		Property__c displayPropertyRecordThree = new Property__c(Name = '102', 
															     LiveStatus__c = '空室', 
															     RoomLayout__c = 'k', 
															     RentFee__c = 62000, 
															     RoomArea__c = 26.79, 
															     RoomCount__c = 1, 
															     Building__c = buildingId, 
															     IsMergeCompletedFlag__c = true);

		Property__c displayPropertyRecordFour = new Property__c(Name = '103', 
															    LiveStatus__c = '空室', 
															    RoomLayout__c = 'k', 
															    RentFee__c = 62000, 
															    RoomArea__c = 26.79, 
															    RoomCount__c = 1, 
															    Building__c = buildingId, 
															    IsMergeCompletedFlag__c = False);


		propertyRecords.add(displayPropertyRecordOne);
		propertyRecords.add(displayPropertyRecordTwo);
		propertyRecords.add(displayPropertyRecordThree);
		propertyRecords.add(displayPropertyRecordFour);

		Insert propertyRecords;




	}

	//初期表示テスト
	@isTest static void initializeTest() {

		Building__c testTargetRecord = [SELECT
									    Id, 
									    Name, 
									    BuildKana__c, 
									    PostalCode__c, 
									    Address__c
									    FROM Building__c
									    WHERE Name = 'サクシード'
		];

		Building__c displayPropertyRecordOne = [SELECT
											    Id, 
											    Name, 
											    BuildKana__c, 
											    PostalCode__c, 
											    Address__c
											    FROM Building__c
											    WHERE Name = 'ｻｸｼｰﾄﾞ'

		];

		//パラメーター設定
		PageReference pageRef = Page.GD601006View;
		PageRef.getParameters().put('Id', testTargetRecord.Id);
		PageRef.getParameters().put('Mode', '建物名寄せ');
		Test.setCurrentPage(pageRef);

		//コントローラー作成
		GD601006Controller testController = new GD601006Controller();

		//建物名が設定されている？
		system.assertEquals(testTargetRecord.Name, testController.targetRecord.name);

		//建物名（カナ）が設定されている？
		system.assertEquals(testTargetRecord.BuildKana__c, testController.targetRecord.BuildKana__c);

		//郵便番号が設定されている？
		system.assertEquals(testTargetRecord.PostalCode__c, testController.targetRecord.PostalCode__c);

		//住所が設定されている？
		system.assertEquals(testTargetRecord.Address__c, testController.targetRecord.Address__c);

		//検索対象の建物名が正しい？
		//system.assertEquals(displayPropertyRecordOne.Name, testController.displayCandidateResult [0].candidateResult.Name);

		//検索対象の建物名（カナ）が正しい？
		system.assertEquals(displayPropertyRecordOne.BuildKana__c, testController.displayCandidateResult [0].candidateResult.BuildKana__c);

		//郵便番号が正しい？
		system.assertEquals(displayPropertyRecordOne.Postalcode__c, testController.displayCandidateResult [0].candidateResult.Postalcode__c);

		//住所が正しい？
		//system.assertEquals(displayPropertyRecordOne.Address__c, testController.displayCandidateResult [0].candidateResult.Address__c);

	}

	//名寄せ不要ボタン
	@isTest static void mergeCompletedTest() {

		Building__c testTargetRecord = [SELECT
									    Id, 
									    Name, 
									    BuildKana__c, 
									    PostalCode__c, 
									    Address__c, 
									    IsMergeCompletedFlag__c
									    FROM Building__c
									    WHERE Name = 'サクシード'
		];


		//パラメーター設定
		PageReference pageRef = Page.GD601006View;
		PageRef.getParameters().put('Id', testTargetRecord.Id);
		PageRef.getParameters().put('Mode', '建物名寄せ');
		Test.setCurrentPage(pageRef);

		//コントローラー作成
		GD601006Controller testController = new GD601006Controller();

		//名寄せ不要ボタン起動
		testController.margeCompleted();

		//名寄せ不要フラグ確認
		Building__c afterTestTargetRecord = [SELECT IsMergeCompletedFlag__c
										     FROM Building__c
										     WHERE Name = 'サクシード'
		];

		system.assertEquals(true, afterTestTargetRecord.IsMergeCompletedFlag__c);


	}

	//物件対象チェック数確認（正常系）
	@isTest static void checkSelectedNumberTest() {

		Building__c testTargetRecord = [SELECT
									    Id, 
									    Name, 
									    BuildKana__c, 
									    PostalCode__c, 
									    Address__c, 
									    IsMergeCompletedFlag__c
									    FROM Building__c
									    WHERE Name = 'サクシード'
		];


		List<Property__c> displayTargetList = [SELECT
											   Name
											   FROM Property__c

		];

		//パラメーター設定
		PageReference pageRef = Page.GD601006View;
		PageRef.getParameters().put('Id', testTargetRecord.Id);
		PageRef.getParameters().put('Mode', '物件名寄せ');
		Test.setCurrentPage(pageRef);

		//コントローラー作成
		GD601006Controller testController = new GD601006Controller();

		//チェックボックスオン
		testController.displayPropertyCandidateResult [0].isSelected = true;
		testController.displayPropertyCandidateResult [1].isSelected = true;


		//物件対象チェック数確認起動
		testController.checkSelectedNumber();

		system.assertEquals(false, testController.hasErrorMessage);

	}

	//物件対象チェック数確認（異常系）
	@isTest static void checkSelectedNumberErrorTest() {

		Building__c testTargetRecord = [SELECT
									    Id, 
									    Name, 
									    BuildKana__c, 
									    PostalCode__c, 
									    Address__c, 
									    IsMergeCompletedFlag__c
									    FROM Building__c
									    WHERE Name = 'サクシード'
		];


		List<Property__c> displayTargetList = [SELECT
											   Name
											   FROM Property__c

		];

		//パラメーター設定
		PageReference pageRef = Page.GD601006View;
		PageRef.getParameters().put('Id', testTargetRecord.Id);
		PageRef.getParameters().put('Mode', '物件名寄せ');
		Test.setCurrentPage(pageRef);

		//コントローラー作成
		GD601006Controller testController = new GD601006Controller();

		//チェックボックスオン
		testController.displayPropertyCandidateResult [0].isSelected = true;


		//物件対象チェック数確認起動
		testController.checkSelectedNumber();

		system.assertEquals(true, testController.hasErrorMessage);

	}


	//コンストラクタテスト
	@isTest static void initializeErrorTest() {

        //パラメーター設定
		PageReference pageRef = Page.GD601006View;
		PageRef.getParameters().put('Id', '0060T0000023JEAQA2');
		Test.setCurrentPage(pageRef);

		//コントローラー作成
		GD601006Controller testController = new GD601006Controller();

		//エラーメッセージ確認
		List<ApexPages.Message> Messages = ApexPages.getMessages();
		system.assertEquals(true, messages [0].getdetail().contains(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));


	}

}