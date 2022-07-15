/**
 * データ容量削減_テストクラス　
 **/
@isTest 
private class DataCapacityUtilTest {   
    //テストに使用するレコードを作成する
    @testSetup static void Setting(){
        //データ作成　システム設定 バッチサイズ
        SystemConfig__c sysconf = new SystemConfig__c(
            UseAuthority_Portal__c = true,
            TestDate__c =  Date.newInstance(2021, 7, 1),
			PropMenteHistoryPostingEndDelBatchFlg__c = false
        );
        insert sysconf;

		//標準プロファイルを取得
		Id profileId = [SELECT Id FROM Profile WHERE Name = '一般ユーザ'].id;
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		User testUser = new User(LastName = 'ippanUser'	//姓
				,Alias =  'alias'                           //別名
				,Email = 'ippanUser@test.com'               //メール
				,UserName =  'ippanUser@test.com'           //ユーザ名
				,CommunityNickname ='テストニックネーム'     //ニックネーム
				,EmailEncodingKey = 'ISO-2022-JP'           //メールの文字コード
				,TimeZoneSidKey = 'Asia/Tokyo'              //タイムゾーン
				,LocaleSidKey = 'ja_JP'                     //地域
				,LanguageLocaleKey= 'ja'                    //言語
				,ProfileId = profileId                      //プロファイルID
		);
		System.runAs(thisUser){
			insert testUser;      
		}
		// 建物
		Building__c testBuilding = new Building__c(
			Name = 'テスト建物'
		);
		insert testBuilding;
		// 物件
        Property__c testProperty = new Property__c(
            Name = 'テスト物件２か月前'
            ,Building__c = testBuilding.Id
			,LiveStatus__c = commonConst.PROPERTY_LIVESTATUS_RESIDENT
			,OwnCompanyManageModDate__c = sysconf.TestDate__c.addMonths(-2)
        );
		// 物件
		Property__c testProperty2 = new Property__c(
			Name = 'テスト物件掲載終了'
			,Building__c = testBuilding.Id
			,LiveStatus__c = commonConst.PROPERTY_LIVESTATUS_RESIDENT
			,OwnCompanyManageModDate__c = sysconf.TestDate__c.addMonths(-1)
		);
		insert testProperty;
		insert testProperty2;

		// 物件メンテナンス履歴（BX101001）
		List<PropertyMaintenanceHistory__c> testPropertyMaintenanceHistoryList = new List<PropertyMaintenanceHistory__c> {
			new PropertyMaintenanceHistory__c(Property__c = testProperty.id,MaintenanceCommentArea__c = 'AAAA', MaintenanceType__c =CommonConst.MAINTENANCETYPE_MANUALCHG),
			new PropertyMaintenanceHistory__c(Property__c = testProperty.id,MaintenanceCommentArea__c = 'AAAA', MaintenanceType__c =CommonConst.MAINTENANCETYPE_MANUALCHG)
		};
		insert testPropertyMaintenanceHistoryList;
		// 物件メンテナンス履歴（BX101001）
		List<PropertyMaintenanceHistory__c> testPropertyMaintenanceHistoryList2 = new List<PropertyMaintenanceHistory__c> {
			new PropertyMaintenanceHistory__c(Property__c = testProperty2.id,MaintenanceCommentArea__c = commonconst.AUTOMAINTENANCE_TYPE_ENDOFPOSTING, MaintenanceType__c =CommonConst.MAINTENANCETYPE_MANUALCHG)
		};
		insert testPropertyMaintenanceHistoryList2;

		// 自動メンテナンス（BX101002Batch）
		List<AutoMaintenance__c> testAutoMaintenanceList = new List<AutoMaintenance__c> {
			new AutoMaintenance__c(Building__c = testBuilding.Id, Property__c = testProperty.id ),
			new AutoMaintenance__c(Building__c = testBuilding.Id, Property__c = testProperty.id)
		};
		insert testAutoMaintenanceList;		

		// 閲覧履歴（BX101003Batch）
		List<BrowsingHistory__c> testBrowsingHistoryList = new List<BrowsingHistory__c> {
			new BrowsingHistory__c(MemberId__c = '0', BrowsingDate__c = DateTime.newInstance(2020, 10, 31, 12, 0, 00)),
			new BrowsingHistory__c(MemberId__c = '0', BrowsingDate__c = DateTime.newInstance(2020, 10, 31, 12, 0, 00))
		};

		insert testBrowsingHistoryList;


	}

	/**
	 * 物件メンテナンス履歴（BX101001）実行
	 */
	@isTest static void successTestBX101001Batch(){
		
		//バッチ実行
		Test.startTest();
		Integer BATCH_SIZE = CommonConst.DATA_CAPACITY_MAINTENANCE_BATCHSIZE; //バッチサイズ
		BX101001Batch b = new BX101001Batch(null);
		Database.executeBatch(b, BATCH_SIZE);
		Test.stopTest();

	}

	/**
	 * 物件メンテナンス履歴（BX101001）実行
	 * 物件メンテナンス履歴削除バッチ削除月
	 * 設定が無い場合、2か月前の日付を取得する事
	 */
	@isTest static void testBX101001BatchMonthAgoNull(){
		SystemConfig__c sysCon = [SELECT Id,PropMenteHistoryDelBatcMonthAgo__c,PropMenteHistoryPostingEndDelMonthAgo__c FROM SystemConfig__c];
		sysCon.PropMenteHistoryDelBatcMonthAgo__c = null;
		sysCon.PropMenteHistoryPostingEndDelMonthAgo__c = null;
		update sysCon;
		//バッチ実行
		Test.startTest();
		Integer BATCH_SIZE = CommonConst.DATA_CAPACITY_MAINTENANCE_BATCHSIZE; //バッチサイズ
		BX101001Batch b = new BX101001Batch(null);
		Database.executeBatch(b, BATCH_SIZE);
		Test.stopTest();

	}

	/**
	 * 物件メンテナンス履歴（BX101001）実行
	 * 物件メンテナンス履歴削除バッチ削除月
	 * 設定がある場合、設定した対象の日付を取得する事
	 */
	@isTest static void testBX101001BatchMonthAgo(){
		SystemConfig__c sysCon = [SELECT Id,PropMenteHistoryDelBatcMonthAgo__c,PropMenteHistoryPostingEndDelMonthAgo__c FROM SystemConfig__c];
		sysCon.PropMenteHistoryDelBatcMonthAgo__c = 4;
		sysCon.PropMenteHistoryPostingEndDelMonthAgo__c = 5;
		update sysCon;
		//バッチ実行
		Test.startTest();
		Integer BATCH_SIZE = CommonConst.DATA_CAPACITY_MAINTENANCE_BATCHSIZE; //バッチサイズ
		BX101001Batch b = new BX101001Batch(null);
		Database.executeBatch(b, BATCH_SIZE);
		Test.stopTest();

	}

	/**
	 * 物件メンテナンス履歴（BX101001）の物件メンテナンス履歴掲載終了削除バッチ実行フラグTrue
	 */
	@isTest static void successTestBX101001Batch_2Run(){
		SystemConfig__c sysCon = [SELECT Id,TestDate__c, PropMenteHistoryPostingEndDelBatchFlg__c FROM SystemConfig__c];
		sysCon.TestDate__c =  Date.newInstance(2021, 6, 1);
		// 物件メンテナンス履歴掲載終了削除バッチ実行フラグをtrueにして実行。
		sysCon.PropMenteHistoryPostingEndDelBatchFlg__c = true;
		update sysCon;
		//バッチ実行
		Test.startTest();
		Integer BATCH_SIZE = CommonConst.DATA_CAPACITY_MAINTENANCE_BATCHSIZE; //バッチサイズ
		BX101001Batch b = new BX101001Batch(null);
		Database.executeBatch(b, BATCH_SIZE);
		Test.stopTest();

	}
	/**
	 * 物件メンテナンス履歴（BX101001）の物件メンテナンス履歴掲載終了削除バッチ実行フラグFalse
	 */
	@isTest static void successTestBX101001Batch_2NotRun(){
		SystemConfig__c sysCon = [SELECT Id,TestDate__c, PropMenteHistoryPostingEndDelBatchFlg__c FROM SystemConfig__c];
		sysCon.TestDate__c =  Date.newInstance(2021, 6, 1);
		// 物件メンテナンス履歴掲載終了削除バッチ実行フラグをfalseにして実行。
		sysCon.PropMenteHistoryPostingEndDelBatchFlg__c = false;
		update sysCon;
		//バッチ実行
		Test.startTest();
		Integer BATCH_SIZE = CommonConst.DATA_CAPACITY_MAINTENANCE_BATCHSIZE; //バッチサイズ
		BX101001Batch b = new BX101001Batch(null);
		Database.executeBatch(b, BATCH_SIZE);

		Test.stopTest();

	}

	/**
	 * 物件メンテナンス履歴（BX101001Batch）実行
	 * スケジューラ、エラー
	 * データ削除失敗時、エラーメールが送信され、削除が行われず、処理が終了すること
	 */
	@isTest static void deleteErrorBX101001Batch(){		
		setObjectPermissionsError(CommonUtil.getNamespace('PropertyMaintenanceHistory__c'));

		List<PropertyMaintenanceHistory__c> selectList = Database.query(DataCapacityUtil.selectPropertyMaintenanceHistory('ID',SystemConfig__c.getInstance().TestDate__c.addMonths(-2)));

		User ippanUser = [SELECT Id FROM User WHERE Username = 'ippanUser@test.com' ];
		// 一般ユーザにて実行（削除権限を無しにしてエラーとなるように）
        System.runAs(ippanUser){		
			//バッチ実行
			Test.startTest();
			Integer BATCH_SIZE = CommonConst.DATA_CAPACITY_MAINTENANCE_BATCHSIZE; //バッチサイズ
			BX101001Batch b = new BX101001Batch(null);
			Database.executeBatch(b, BATCH_SIZE);
			Test.stopTest();
		}
		
		// データ削除失敗時、エラーメールが送信され、削除が行われず、処理が終了すること
		List<PropertyMaintenanceHistory__c> afterExecutionList = Database.query(DataCapacityUtil.selectPropertyMaintenanceHistory('ID',SystemConfig__c.getInstance().TestDate__c.addMonths(-2)));
		System.assertEquals(selectList, afterExecutionList);
		
	}


	/**
	 * 物件メンテナンス履歴（BX101001Batch_2）実行
	 */
	@isTest static void successTestBX101001Batch_2(){
		PropertyMaintenanceHistory__c testPropertyMaintenanceHistory = [
			SELECT ID 
			FROM   PropertyMaintenanceHistory__c
			WHERE  Property__r.name = 'テスト物件掲載終了'
			LIMIT  1
		];
		Id [] fixedSearchResults= new Id[1];
		fixedSearchResults[0] = testPropertyMaintenanceHistory.id;
		//バッチ実行
		Test.startTest();

		// SOQL実行用の設定（テストクラスではこれが無いと取得できないため）
		Test.setFixedSearchResults(fixedSearchResults);
		Integer BATCH_SIZE = CommonConst.DATA_CAPACITY_MAINTENANCE_BATCHSIZE; //バッチサイズ
		BX101001Batch_2 b = new BX101001Batch_2(null);
		Database.executeBatch(b, BATCH_SIZE);
		Test.stopTest();

	}
	/**
	 * 物件メンテナンス履歴（BX101001Batch_2）実行
	 * 物件メンテナンス履歴掲載終了削除バッチ削除月
	 * 設定が無い場合、1か月前の日付を取得する事
	 */
	@isTest static void testBX101001Batch_2MonthAgoNull(){
		SystemConfig__c sysCon = [SELECT Id,PropMenteHistoryPostingEndDelMonthAgo__c FROM SystemConfig__c];
		sysCon.PropMenteHistoryPostingEndDelMonthAgo__c = null;
		update sysCon;
		PropertyMaintenanceHistory__c testPropertyMaintenanceHistory = [
			SELECT ID 
			FROM   PropertyMaintenanceHistory__c
			WHERE  Property__r.name = 'テスト物件掲載終了'
			LIMIT  1
		];
		Id [] fixedSearchResults= new Id[1];
		fixedSearchResults[0] = testPropertyMaintenanceHistory.id;
		//バッチ実行
		Test.startTest();

		// SOQL実行用の設定（テストクラスではこれが無いと取得できないため）
		Test.setFixedSearchResults(fixedSearchResults);
		Integer BATCH_SIZE = CommonConst.DATA_CAPACITY_MAINTENANCE_BATCHSIZE; //バッチサイズ
		BX101001Batch_2 b = new BX101001Batch_2(null);
		Database.executeBatch(b, BATCH_SIZE);
		Test.stopTest();

	}
	/**
	 * 物件メンテナンス履歴（BX101001Batch_2）実行
	 * 物件メンテナンス履歴掲載終了削除バッチ削除月
	 * 設定がある場合、設定した対象の日付を取得する事
	 */
	@isTest static void testBX101001Batch_2MonthAgo(){
		SystemConfig__c sysCon = [SELECT Id,PropMenteHistoryPostingEndDelMonthAgo__c FROM SystemConfig__c];
		sysCon.PropMenteHistoryPostingEndDelMonthAgo__c = 3;
		update sysCon;
		PropertyMaintenanceHistory__c testPropertyMaintenanceHistory = [
			SELECT ID 
			FROM   PropertyMaintenanceHistory__c
			WHERE  Property__r.name = 'テスト物件掲載終了'
			LIMIT  1
		];
		Id [] fixedSearchResults= new Id[1];
		fixedSearchResults[0] = testPropertyMaintenanceHistory.id;
		//バッチ実行
		Test.startTest();

		// SOQL実行用の設定（テストクラスではこれが無いと取得できないため）
		Test.setFixedSearchResults(fixedSearchResults);
		Integer BATCH_SIZE = CommonConst.DATA_CAPACITY_MAINTENANCE_BATCHSIZE; //バッチサイズ
		BX101001Batch_2 b = new BX101001Batch_2(null);
		Database.executeBatch(b, BATCH_SIZE);
		Test.stopTest();

	}
	/**
	 * 物件メンテナンス履歴（BX101001Batch_2）実行
	 * スケジューラ、エラー
	 * データ削除失敗時、エラーメールが送信され、削除が行われず、処理が終了すること
	 */
	@isTest static void deleteErrorBX101001Batch_2(){		
		setObjectPermissionsError(CommonUtil.getNamespace('PropertyMaintenanceHistory__c'));

		PropertyMaintenanceHistory__c testPropertyMaintenanceHistory = [
			SELECT ID 
			FROM   PropertyMaintenanceHistory__c
			WHERE  Property__r.name = 'テスト物件掲載終了'
			LIMIT  1
		];
		Id [] fixedSearchResults= new Id[1];
		fixedSearchResults[0] = testPropertyMaintenanceHistory.id;
		List<List<SObject>> selectList = new List<List<SObject>>();

		User ippanUser = [SELECT Id FROM User WHERE Username = 'ippanUser@test.com' ];
		// 一般ユーザにて実行（削除権限を無しにしてエラーとなるように）
        System.runAs(ippanUser){		
			//バッチ実行
			Test.startTest();

			// SOQL実行用の設定（テストクラスではこれが無いと取得できないため）
			Test.setFixedSearchResults(fixedSearchResults);
			selectList = DataCapacityUtil.selectPropertyMaintenanceHistoryPostingEnd('ID',SystemConfig__c.getInstance().TestDate__c.addMonths(-1));
			Integer BATCH_SIZE = CommonConst.DATA_CAPACITY_MAINTENANCE_BATCHSIZE; //バッチサイズ
			BX101001Batch_2 b = new BX101001Batch_2(null);
			Database.executeBatch(b, BATCH_SIZE);
			Test.stopTest();
		}


		// データ削除失敗時、エラーメールが送信され、削除が行われず、処理が終了すること
		List<List<SObject>> afterExecutionList = DataCapacityUtil.selectPropertyMaintenanceHistoryPostingEnd('ID',SystemConfig__c.getInstance().TestDate__c.addMonths(-1));
		system.debug(selectList);
		system.debug(afterExecutionList);
		System.assertEquals(selectList, afterExecutionList);
	}



	/**
	 * 自動メンテナンス（BX101002Batch）実行
	 */
	@isTest static void successTestBX101002Batch(){
		// 作成日の変更
		List<AutoMaintenance__c> testAutoMaintenanceList =[SELECT id FROM AutoMaintenance__c];
		Test.setCreatedDate(testAutoMaintenanceList[0].Id, SystemConfig__c.getInstance().TestDate__c.addMonths(-2));

		//バッチ実行
		Test.startTest();
		Integer BATCH_SIZE = CommonConst.DATA_CAPACITY_MAINTENANCE_BATCHSIZE; //バッチサイズ
		BX101002Batch b = new BX101002Batch();
		Database.executeBatch(b, BATCH_SIZE);
		Test.stopTest();
	}

	/**
	 * 自動メンテナンス（BX101002Batch）実行
	 * 自動メンテナンス削除バッチ削除月
	 * 設定が無い場合、2か月前の日付を取得する事
	 */
	@isTest static void testBX101002BatchMonthAgoNull(){
		SystemConfig__c sysCon = [SELECT Id,AutoMenteDelBatcMonthAgo__c FROM SystemConfig__c];
		sysCon.AutoMenteDelBatcMonthAgo__c = null;
		update sysCon;
		// 作成日の変更
		List<AutoMaintenance__c> testAutoMaintenanceList =[SELECT id FROM AutoMaintenance__c];
		Test.setCreatedDate(testAutoMaintenanceList[0].Id, SystemConfig__c.getInstance().TestDate__c.addMonths(-2));

		//バッチ実行
		Test.startTest();
		Integer BATCH_SIZE = CommonConst.DATA_CAPACITY_MAINTENANCE_BATCHSIZE; //バッチサイズ
		BX101002Batch b = new BX101002Batch();
		Database.executeBatch(b, BATCH_SIZE);
		Test.stopTest();
	}

	/**
	 * 自動メンテナンス（BX101002Batch）実行
	 * 自動メンテナンス削除バッチ削除月
	 * 設定がある場合、設定した対象の日付を取得する事
	 */
	@isTest static void testBX101002BatchMonthAgo(){
		SystemConfig__c sysCon = [SELECT Id,AutoMenteDelBatcMonthAgo__c FROM SystemConfig__c];
		sysCon.AutoMenteDelBatcMonthAgo__c = 5;
		update sysCon;
		// 作成日の変更
		List<AutoMaintenance__c> testAutoMaintenanceList =[SELECT id FROM AutoMaintenance__c];
		Test.setCreatedDate(testAutoMaintenanceList[0].Id, SystemConfig__c.getInstance().TestDate__c.addMonths(-6));

		//バッチ実行
		Test.startTest();
		Integer BATCH_SIZE = CommonConst.DATA_CAPACITY_MAINTENANCE_BATCHSIZE; //バッチサイズ
		BX101002Batch b = new BX101002Batch();
		Database.executeBatch(b, BATCH_SIZE);
		Test.stopTest();
	}


	/**
	 * 自動メンテナンス（BX101002Batch）実行
	 * スケジューラ、エラー
	 * データ削除失敗時、エラーメールが送信され、削除が行われず、処理が終了すること
	 */
	@isTest static void deleteErrorBX101002Batch(){
		// 作成日の変更
		List<AutoMaintenance__c> testAutoMaintenanceList =[SELECT id FROM AutoMaintenance__c];
		setObjectPermissionsError(CommonUtil.getNamespace('AutoMaintenance__c'));

		User ippanUser = [SELECT Id FROM User WHERE Username = 'ippanUser@test.com' ];
		// 一般ユーザにて実行（削除権限を無しにしてエラーとなるように）
        System.runAs(ippanUser){

			Test.setCreatedDate(testAutoMaintenanceList[0].Id, SystemConfig__c.getInstance().TestDate__c.addMonths(-2));		
			//バッチ実行
			Test.startTest();
			Integer BATCH_SIZE = CommonConst.DATA_CAPACITY_MAINTENANCE_BATCHSIZE; //バッチサイズ
			BX101002Batch b = new BX101002Batch();
			Database.executeBatch(b, BATCH_SIZE);
			Test.stopTest();
		}
		// データ削除失敗時、エラーメールが送信され、削除が行われず、処理が終了すること
		List<AutoMaintenance__c> afterExecutionList =[SELECT id FROM AutoMaintenance__c];
		System.assertEquals(testAutoMaintenanceList, afterExecutionList);
	}

	/**
	 * 閲覧履歴（BX101003Batch）実行
	 */
	@isTest static void successTestBX101003Batch(){
		//バッチ実行
		Test.startTest();
		Integer BATCH_SIZE = CommonConst.DATA_CAPACITY_MAINTENANCE_BATCHSIZE; //バッチサイズ
		BX101003Batch b = new BX101003Batch();
		Database.executeBatch(b, BATCH_SIZE);
		Test.stopTest();

	}
	
	/**
	 * 閲覧履歴（BX101003Batch）実行
	 * スケジューラ、エラー
	 * データ削除失敗時、エラーメールが送信され、削除が行われず、処理が終了すること
	 */
	@isTest static void deleteErrorBX101003Batch(){		
		Datetime fiscalFirstDate = DataCapacityUtil.getFiscalFirstDate(SystemConfig__c.getInstance().TestDate__c);
		setObjectPermissionsError(CommonUtil.getNamespace('BrowsingHistory__c'));
		List<BrowsingHistory__c> selectList =Database.query(DataCapacityUtil.selectBrowsingHistory('ID',fiscalFirstDate));

		User ippanUser = [SELECT Id FROM User WHERE Username = 'ippanUser@test.com' ];
		// 一般ユーザにて実行（削除権限を無しにしてエラーとなるように）
        System.runAs(ippanUser){		
			//バッチ実行
			Test.startTest();
			Integer BATCH_SIZE = CommonConst.DATA_CAPACITY_MAINTENANCE_BATCHSIZE; //バッチサイズ
			BX101003Batch b = new BX101003Batch();
			Database.executeBatch(b, BATCH_SIZE);
			Test.stopTest();
		}
		// データ削除失敗時、エラーメールが送信され、削除が行われず、処理が終了すること
		List<BrowsingHistory__c> afterExecutionList =Database.query(DataCapacityUtil.selectBrowsingHistory('ID',fiscalFirstDate));
		System.assertEquals(selectList, afterExecutionList);
	}


	//----------------------------privateメソッド-------------------------------------------------------------------------
	/*
	 * 一般ユーザで削除権限を外す
	 * バッチ実行にて削除エラーを起こす用
	 * @param String ObjectName 対象オブジェクトApi名
    */
	private static void setObjectPermissionsError(String ObjectName){
		Id profileId = [SELECT Id FROM Profile WHERE Name = '一般ユーザ'].id;
		Id PermissionSetId = [SELECT Id FROM PermissionSet WHERE ProfileId = :profileId].id;
		List<ObjectPermissions> testObjectPermissionsList= [SELECT Id, PermissionsDelete, PermissionsModifyAllRecords FROM ObjectPermissions
			WHERE SobjectType = :ObjectName AND ParentId = :PermissionSetId
		];
		List<ObjectPermissions> updateObjectPermissionsList = new List<ObjectPermissions>();
		for (ObjectPermissions testObjectPermissions : testObjectPermissionsList) {
			ObjectPermissions updateObjectPermissions = new ObjectPermissions();
			updateObjectPermissions.id = testObjectPermissions.id;
			updateObjectPermissions.PermissionsModifyAllRecords = false;
			updateObjectPermissions.PermissionsDelete = false;
			updateObjectPermissionsList.add(updateObjectPermissions);
		}
		update updateObjectPermissionsList;
	}

}