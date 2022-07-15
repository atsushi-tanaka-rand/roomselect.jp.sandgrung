//行動トリガテストクラス
@ isTest
private class BA101008TriggerHandlerTest {

	//▼ 2022.02.09 No0601 追加
	private static Date setDate =  Date.newInstance(2021, 4, 1);

    @TestSetup
    static void Setting(){

        //ユーザ作成
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name IN ('一般ユーザ')];
        System.assert(profiles.size() > 0);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            insert new User(
                UserName = 'Test@horaguchi.com',
                Email = 'test@example.com',
                LastName = 'test',
                Alias = 'test',
                TimeZoneSidKey = 'Asia/Tokyo',
                LocaleSidKey = 'ja_JP',
                EmailEncodingKey = 'ISO-2022-JP',
                LanguageLocaleKey = 'ja',
                ProfileId = profiles.get(0).Id);
        }
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'Test@horaguchi.com'];
        //店舗レコード
        Shop__c shopRecord = new shop__c(Name = 'テスト店舗',
                PortalSitePostingDistrict__c = '港区;北区',
                Email__c = 'tempoEmail@rand.co.jp');
        insert shopRecord;

        // 組織階層レコード
        OrganizationHierarchy__c orgRecord1 = new OrganizationHierarchy__c(
            OrganizationCode__c = '0001',
            OrganizationName__c = '本部',
            HierarchyCode__c = '10',
            HierarchyOrder__c = 1,
            UpperOrganizationHierarchy__c = null,
            ExpandedOrganizationCode__c = '0000_0001',
            Shop__c = null
        );
        insert orgRecord1;
        OrganizationHierarchy__c orgRecord2 = new OrganizationHierarchy__c(
            OrganizationCode__c = '0002',
            OrganizationName__c = 'テスト店舗',
            HierarchyCode__c = '20',
            HierarchyOrder__c = 1,
            UpperOrganizationHierarchy__c = orgRecord1.Id,
            ExpandedOrganizationCode__c = '0000_0001_0002',
            Shop__c = shopRecord.Id
        );
        insert orgRecord2;

        // 店舗異動レコード
        ShopTransfer__c ShopTransferRecord = new ShopTransfer__c(OrgzanizationHierarchy__c = orgRecord2.id,
                                                                Staff__c = userRecord.id,
                                                                StartDate__c = Date.newInstance(2000, 12, 1),
                                                                EndDate__c = Date.newInstance(2999, 12, 1)); 
        insert ShopTransferRecord;

        //来店受付
         AppointmentReceiptStoreDate__c arsd = new AppointmentReceiptStoreDate__c(
             PeopleLimit__c = 2,
             TargetDate__c = CommonUtil.getToday(),
             Shop__c = shopRecord.Id,
             ProcessingFlg__c = true
         );
         insert arsd;    

        // 来店受付
         AppointmentReceipt__c appointmentReceipt = new AppointmentReceipt__c(
              OwnerId = userRecord.id
            , ReceiptDate__c = Date.newInstance(2020,10,10)
            , Shop__c = shopRecord.id
            , ReserveStartTime__c = Time.newInstance(10, 0, 0 ,0)
            , ReserveEndTime__c = Time.newInstance(10, 30, 0 ,0)
            , ReserveCanCount__c = 5
            , ReserveResultCount__c = 0 
            , AppointmentReceiptStoreDate__c = arsd.id
            , ReserveCanNotCount__c = 0
         );
         insert appointmentReceipt;

		 //▼ 2022.02.09 No0601 対応で追加
		 List<AppointmentReceipt__c> appointmentReceiptList = new List<AppointmentReceipt__c>();
		 appointmentReceiptList.addall(setAppointmentReceiptList(shopRecord.Id, arsd.Id, setDate, arsd.PeopleLimit__c));
		 for (Integer dayCount = 1 ;dayCount <= 30 ;dayCount++) {
			 appointmentReceiptList.addall(setAppointmentReceiptList(shopRecord.Id, arsd.Id, setDate.addDays(dayCount), arsd.PeopleLimit__c));    
		 }
		 insert appointmentReceiptList;
		 //▲ 2022.02.09 No0601 対応で追加
    }

    // イベントトリガー
    @isTest static void eventTrigger(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'Test@horaguchi.com'];
        // 行動の登録
        Event eventIns = new Event(
            OwnerId = userRecord.id
            ,StartDateTime = DateTime.newInstance(2020, 10, 10, 10, 0, 00)
            ,endDateTime =  DateTime.newInstance(2020, 10, 10, 14, 0, 00)
            ,SUBJECT = '【商談】'
        );
        insert eventIns;   

        // 対応の登録
        Correspond__c addCorrespond = new Correspond__c(
            EventId__c = eventIns.id,
            VisitReservationFlag__c = true
        );
        insert addCorrespond;

        // 行動の更新
        Event eventUpdate = new Event(
            id = eventIns.id
            ,endDateTime =  DateTime.newInstance(2020, 10, 10, 16, 0, 00)
        );
        update eventUpdate;

        // 行動の削除
        delete eventUpdate;
    }

        // イベントトリガー2
    @isTest static void eventTrigger2(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'Test@horaguchi.com'];
        
        try{
        // 行動の登録(重複しない)
        Event eventInsA = new Event(
            OwnerId = userRecord.id
            ,StartDateTime = DateTime.newInstance(2020, 10, 11, 10, 0, 00)
            ,endDateTime =  DateTime.newInstance(2020, 10, 11, 14, 0, 00)
            ,SUBJECT = '【商談】'
        ); 
        // 行動の登録（重複）
        Event eventInsB = new Event(
            OwnerId = userRecord.id
            ,StartDateTime = DateTime.newInstance(2020, 10, 10, 10, 0, 00)
            ,endDateTime =  DateTime.newInstance(2020, 10, 10, 14, 0, 00)
            ,SUBJECT = '【商談】'
        );
        // 行動の登録（重複）
        Event eventInsC = new Event(
            OwnerId = userRecord.id
            ,StartDateTime = DateTime.newInstance(2020, 10, 10, 10, 0, 00)
            ,endDateTime =  DateTime.newInstance(2020, 10, 10, 14, 0, 00)
            ,SUBJECT = '【商談】'
        );    
        //行動をリストに追加
        List<Event> eventList = new List<Event>(); 
        eventList.add(eventInsA);
        eventList.add(eventInsB);
        eventList.add(eventInsC);
        //リストを追加
        insert eventList;    
        }catch(Exception e){
            System.assertEquals(true, e.getMessage().contains(CommonConst.MSG_CUST_E_REGISTRATION_EVENT_DUPLICATE));
        }

        try{
        // 行動の登録（既存レコードの作成）
        Event eventInsD = new Event(
            OwnerId = userRecord.id
            ,StartDateTime = DateTime.newInstance(2020, 10, 11, 10, 0, 00)
            ,endDateTime =  DateTime.newInstance(2020, 10, 11, 14, 0, 00)
            ,SUBJECT = '【商談】'
        );      
        //追加
        insert eventInsD;  
        
        // 行動の登録（Dに重複）
        Event eventInsE = new Event(
            OwnerId = userRecord.id
            ,StartDateTime = DateTime.newInstance(2020, 10, 11, 10, 0, 00)
            ,endDateTime =  DateTime.newInstance(2020, 10, 11, 14, 0, 00)
            ,SUBJECT = '【商談】'
        );             
        //追加
        update eventInsD;
        insert eventInsE;  
        }catch(Exception e){
            System.assertEquals(true, e.getMessage().contains(CommonConst.MSG_CUST_E_REGISTRATION_EVENT_DUPLICATE));
        }
    }

//▼ 2022.02.09 No0601 対応で追加
	/**
	* １８、休みの登録
	*     　期間内店舗の来店受付の予約不能数が加算されること
	*       新規登録：2021/4/ 1 10:00 ～ 2021/ 4/ 1 15:00
	*/
	@isTest
	static void eventTriggerInsert(){
		User userRecord =  [SELECT Id FROM User WHERE UserName = 'Test@horaguchi.com'];
		OrganizationHierarchy__c organizationHierarchy = [SELECT Id,shop__c FROM OrganizationHierarchy__c WHERE OrganizationName__c =  'テスト店舗' LIMIT 1];
		// 行動の登録
		Event eventIns = new Event(
			OwnerId = userRecord.id
			,StartDateTime = DateTime.newInstance(2021, 4,  1, 10, 0, 0)
			,endDateTime   = DateTime.newInstance(2021, 4,  1, 15, 0, 0)
			,SUBJECT = commonconst.SUBJECT_HOLIDAY
		); 
		Test.startTest();
		insert eventIns;
		Test.stopTest();
		// 行動期間内の来店受付取得
		List<AppointmentReceipt__c> appointmentReceiptList =[
			SELECT Id, ReceiptDate__c, ReserveCanNotCount__c, ReserveStartTime__c
			FROM   AppointmentReceipt__c
			WHERE  Shop__c = :organizationHierarchy.shop__c 
			AND    ReceiptDate__c >= :setDate
			ORDER BY ReceiptDate__c
			,ReserveStartTime__c
		];
		// 予約不能数を取得
		for (AppointmentReceipt__c appointmentReceipt : appointmentReceiptList) {
			if(appointmentReceipt.ReceiptDate__c ==  Date.newInstance(2021, 4, 1) &&
			  (appointmentReceipt.ReserveStartTime__c >= Time.newInstance(10, 0, 0 ,0) && 
			   appointmentReceipt.ReserveStartTime__c < Time.newInstance(15, 0, 0 ,0))
			){
				system.assertEquals(1,appointmentReceipt.ReserveCanNotCount__c
				,'エラー詳細（開始時刻：'+ appointmentReceipt.ReserveStartTime__c+'）');
			}else {
				system.assertEquals(0,appointmentReceipt.ReserveCanNotCount__c
				,'エラー詳細（開始時刻：'+ appointmentReceipt.ReserveStartTime__c+'）');
			}
			
		} 
	}
	/**
	* １９、休みの更新
	*     　期間内店舗の来店受付の予約不能数が変動すること
	*     　更新：2021/4/ 1 10:00 ～ 2021/ 4/ 1 15:00 → 2021/4/20 10:00 ～ 2021/ 4/20 17:00
	*/
	@isTest
	static void eventTriggerUpdate(){
		User userRecord =  [SELECT Id FROM User WHERE UserName = 'Test@horaguchi.com'];
		OrganizationHierarchy__c organizationHierarchy = [SELECT Id,shop__c FROM OrganizationHierarchy__c WHERE OrganizationName__c =  'テスト店舗' LIMIT 1];
		// 行動の登録
		Event eventIns = new Event(
			OwnerId = userRecord.id
			,StartDateTime = DateTime.newInstance(2021, 4,  1, 10, 0, 0)
			,endDateTime   = DateTime.newInstance(2021, 4,  1, 15, 0, 0)
			,SUBJECT = commonconst.SUBJECT_HOLIDAY
		); 
		insert eventIns;
		Test.startTest();
		eventIns.StartDateTime = DateTime.newInstance(2021, 4, 20, 10, 0, 0);
		eventIns.endDateTime   = DateTime.newInstance(2021, 4, 20, 17, 0, 0);
		update eventIns;
		Test.stopTest();
		// 行動期間内の来店受付取得
		List<AppointmentReceipt__c> appointmentReceiptList =[
			SELECT Id, ReceiptDate__c, ReserveCanNotCount__c, ReserveStartTime__c
			FROM   AppointmentReceipt__c
			WHERE  Shop__c = :organizationHierarchy.shop__c 
			AND    ReceiptDate__c >= :setDate
			ORDER BY ReceiptDate__c
			,ReserveStartTime__c
		];
		// 予約不能数を取得
		for (AppointmentReceipt__c appointmentReceipt : appointmentReceiptList) {
			if((appointmentReceipt.ReceiptDate__c ==  Date.newInstance(2021, 4, 20)) &&
				(appointmentReceipt.ReserveStartTime__c >= Time.newInstance(10, 0, 0 ,0) && 
				appointmentReceipt.ReserveStartTime__c < Time.newInstance(17, 0, 0 ,0))
			){
				system.assertEquals(1,appointmentReceipt.ReserveCanNotCount__c
				,'エラー詳細（開始時刻：'+ appointmentReceipt.ReserveStartTime__c+'）');
			}else {
				system.assertEquals(0,appointmentReceipt.ReserveCanNotCount__c
				,'エラー詳細（開始時刻：'+ appointmentReceipt.ReserveStartTime__c+'）');
			}
		} 
	}
	/**
	* ２０、休みの削除
	*     　期間内店舗の来店受付の予約不能数が減算すること
	*       新規登録：2021/4/ 1 10:00 ～ 2021/ 4/ 1 15:00
	*       新規登録：2021/4/10 10:00 ～ 2021/ 4/10 15:00
	*     　削除：2021/4/10 10:00 ～ 2021/ 4/10 15:00
	*/
	@isTest
	static void eventTriggerDelete(){
		User userRecord =  [SELECT Id FROM User WHERE UserName = 'Test@horaguchi.com'];
		OrganizationHierarchy__c organizationHierarchy = [SELECT Id,shop__c FROM OrganizationHierarchy__c WHERE OrganizationName__c =  'テスト店舗' LIMIT 1];
		// 行動の登録
		Event eventInsA = new Event(
			OwnerId = userRecord.id
			,StartDateTime = DateTime.newInstance(2021, 4,  1, 10, 0, 0)
			,endDateTime   = DateTime.newInstance(2021, 4,  1, 15, 0, 0)
			,SUBJECT = commonconst.SUBJECT_HOLIDAY
		); 
		// 行動の登録
		Event eventInsB = new Event(
			OwnerId = userRecord.id
			,StartDateTime = DateTime.newInstance(2021, 4, 10, 10, 0, 0)
			,endDateTime   = DateTime.newInstance(2021, 4, 10, 15, 0, 0)
			,SUBJECT = commonconst.SUBJECT_HOLIDAY
		); 
		List<Event> eventInsList = new List<Event>{
			eventInsA,
			eventInsB
		};
		insert eventInsList;
		Test.startTest();
		delete eventInsB;
		Test.stopTest();
		// 行動期間内の来店受付取得
		List<AppointmentReceipt__c> appointmentReceiptList =[
			SELECT Id, ReceiptDate__c, ReserveCanNotCount__c, ReserveStartTime__c
			FROM   AppointmentReceipt__c
			WHERE  Shop__c = :organizationHierarchy.shop__c 
			AND    ReceiptDate__c >= :setDate
			ORDER BY ReceiptDate__c
			,ReserveStartTime__c
		];
		// 予約不能数を取得
		for (AppointmentReceipt__c appointmentReceipt : appointmentReceiptList) {
			if((appointmentReceipt.ReceiptDate__c ==  Date.newInstance(2021, 4, 1)) &&
				(appointmentReceipt.ReserveStartTime__c >= Time.newInstance(10, 0, 0 ,0) && 
				appointmentReceipt.ReserveStartTime__c < Time.newInstance(15, 0, 0 ,0))
			){
				system.assertEquals(1,appointmentReceipt.ReserveCanNotCount__c
				,'エラー詳細（開始時刻：'+ appointmentReceipt.ReserveStartTime__c+'）');
			}else {
				system.assertEquals(0,appointmentReceipt.ReserveCanNotCount__c
				,'エラー詳細（開始時刻：'+ appointmentReceipt.ReserveStartTime__c+'）');
			}
		} 
	}
	/**
	* ２１、休みの一括登録
	*     　期間内店舗の来店受付の予約不能数が加算されること
	*       新規登録：2021/4/ 1 10:00 ～ 2021/ 4/ 1 15:00
	*       新規登録：2021/4/10 10:00 ～ 2021/ 4/10 15:00
	*/
	@isTest
	static void eventTriggerPluralInsert(){
		User userRecord =  [SELECT Id FROM User WHERE UserName = 'Test@horaguchi.com'];
		OrganizationHierarchy__c organizationHierarchy = [SELECT Id,shop__c FROM OrganizationHierarchy__c WHERE OrganizationName__c =  'テスト店舗' LIMIT 1];
		// 行動の登録
		Event eventInsA = new Event(
			OwnerId = userRecord.id
			,StartDateTime = DateTime.newInstance(2021, 4,  1, 10, 0, 0)
			,endDateTime   = DateTime.newInstance(2021, 4,  1, 15, 0, 0)
			,SUBJECT = commonconst.SUBJECT_HOLIDAY
		); 
		// 行動の登録
		Event eventInsB = new Event(
			OwnerId = userRecord.id
			,StartDateTime = DateTime.newInstance(2021, 4, 10, 10, 0, 0)
			,endDateTime   = DateTime.newInstance(2021, 4, 10, 15, 0, 0)
			,SUBJECT = commonconst.SUBJECT_HOLIDAY
		); 
		List<Event> eventInsList = new List<Event>{
			eventInsA,
			eventInsB
		};
		Test.startTest();
		insert eventInsList;
		Test.stopTest();
		// 行動期間内の来店受付取得
		List<AppointmentReceipt__c> appointmentReceiptList =[
			SELECT Id, ReceiptDate__c, ReserveCanNotCount__c, ReserveStartTime__c
			FROM   AppointmentReceipt__c
			WHERE  Shop__c = :organizationHierarchy.shop__c 
			AND    ReceiptDate__c >= :setDate
			ORDER BY ReceiptDate__c
			,ReserveStartTime__c
		];
		// 予約不能数を取得
		for (AppointmentReceipt__c appointmentReceipt : appointmentReceiptList) {
			if((appointmentReceipt.ReceiptDate__c ==  Date.newInstance(2021, 4, 1) ||
			    appointmentReceipt.ReceiptDate__c ==  Date.newInstance(2021, 4,10)) &&
			  (appointmentReceipt.ReserveStartTime__c >= Time.newInstance(10, 0, 0 ,0) && 
			   appointmentReceipt.ReserveStartTime__c < Time.newInstance(15, 0, 0 ,0))
			){
				system.assertEquals(1,appointmentReceipt.ReserveCanNotCount__c
				,'エラー詳細（開始時刻：'+ appointmentReceipt.ReserveStartTime__c+'）');
			}else {
				system.assertEquals(0,appointmentReceipt.ReserveCanNotCount__c
				,'エラー詳細（開始時刻：'+ appointmentReceipt.ReserveStartTime__c+'）');
			}
			
		} 
	}
	/**
	* ２２、休みの一括更新
	*     　期間内店舗の来店受付の予約不能数が変動すること
	*     　更新：2021/4/ 1 10:00 ～ 2021/ 4/ 1 15:00 → 2021/4/20 13:00 ～ 2021/ 4/20 17:00
	*     　更新：2021/4/10 10:00 ～ 2021/ 4/10 15:00 → 2021/4/ 2 13:00 ～ 2021/ 4/ 2 17:00
	*/
	@isTest
	static void eventTriggerPluralUpdte(){
		User userRecord =  [SELECT Id FROM User WHERE UserName = 'Test@horaguchi.com'];
		OrganizationHierarchy__c organizationHierarchy = [SELECT Id,shop__c FROM OrganizationHierarchy__c WHERE OrganizationName__c =  'テスト店舗' LIMIT 1];
		// 行動の登録
		Event eventInsA = new Event(
			OwnerId = userRecord.id
			,StartDateTime = DateTime.newInstance(2021, 4,  1, 10, 0, 0)
			,endDateTime   = DateTime.newInstance(2021, 4,  1, 15, 0, 0)
			,SUBJECT = commonconst.SUBJECT_HOLIDAY
		); 
		// 行動の登録
		Event eventInsB = new Event(
			OwnerId = userRecord.id
			,StartDateTime = DateTime.newInstance(2021, 4, 10, 10, 0, 0)
			,endDateTime   = DateTime.newInstance(2021, 4, 10, 15, 0, 0)
			,SUBJECT = commonconst.SUBJECT_HOLIDAY
		); 
		List<Event> eventInsList = new List<Event>{
			eventInsA,
			eventInsB
		};
		insert eventInsList;
		Test.startTest();
		eventInsA.StartDateTime = DateTime.newInstance(2021, 4, 20, 13, 0, 0);
		eventInsA.endDateTime   = DateTime.newInstance(2021, 4, 20, 17, 0, 0);

		eventInsB.StartDateTime = DateTime.newInstance(2021, 4,  2, 13, 0, 0);
		eventInsB.endDateTime   = DateTime.newInstance(2021, 4,  2, 17, 0, 0);
		update eventInsList;
		Test.stopTest();
		// 行動期間内の来店受付取得
		List<AppointmentReceipt__c> appointmentReceiptList =[
			SELECT Id, ReceiptDate__c, ReserveCanNotCount__c, ReserveStartTime__c
			FROM   AppointmentReceipt__c
			WHERE  Shop__c = :organizationHierarchy.shop__c 
			AND    ReceiptDate__c >= :setDate
			ORDER BY ReceiptDate__c
			,ReserveStartTime__c
		];
		// 予約不能数を取得
		for (AppointmentReceipt__c appointmentReceipt : appointmentReceiptList) {
			if((appointmentReceipt.ReceiptDate__c ==  Date.newInstance(2021, 4, 2) ||
			    appointmentReceipt.ReceiptDate__c ==  Date.newInstance(2021, 4,20)) &&
			  (appointmentReceipt.ReserveStartTime__c >= Time.newInstance(13, 0, 0 ,0) && 
			   appointmentReceipt.ReserveStartTime__c <  Time.newInstance(17, 0, 0 ,0))
			){
				system.assertEquals(1,appointmentReceipt.ReserveCanNotCount__c
				,'エラー詳細（開始時刻：'+ appointmentReceipt.ReserveStartTime__c+'）');
			}else {
				system.assertEquals(0,appointmentReceipt.ReserveCanNotCount__c
				,'エラー詳細（開始時刻：'+ appointmentReceipt.ReserveStartTime__c+'）');
			}
			
		} 
	}
	/**
	* ２３、休みの一括削除
	*     　期間内店舗の来店受付の予約不能数が減算すること
	*     　削除：2021/4/ 1 10:00 ～ 2021/ 4/ 1 15:00
	*     　削除：2021/4/10 10:00 ～ 2021/ 4/10 15:00
	*/
	@isTest
	static void eventTriggerPluralDelete(){
		User userRecord =  [SELECT Id FROM User WHERE UserName = 'Test@horaguchi.com'];
		OrganizationHierarchy__c organizationHierarchy = [SELECT Id,shop__c FROM OrganizationHierarchy__c WHERE OrganizationName__c =  'テスト店舗' LIMIT 1];
		// 行動の登録
		Event eventInsA = new Event(
			OwnerId = userRecord.id
			,StartDateTime = DateTime.newInstance(2021, 4,  1, 10, 0, 0)
			,endDateTime   = DateTime.newInstance(2021, 4,  1, 15, 0, 0)
			,SUBJECT = commonconst.SUBJECT_HOLIDAY
		); 
		// 行動の登録
		Event eventInsB = new Event(
			OwnerId = userRecord.id
			,StartDateTime = DateTime.newInstance(2021, 4, 10, 10, 0, 0)
			,endDateTime   = DateTime.newInstance(2021, 4, 10, 15, 0, 0)
			,SUBJECT = commonconst.SUBJECT_HOLIDAY
		); 
		List<Event> eventInsList = new List<Event>{
			eventInsA,
			eventInsB
		};
		insert eventInsList;
		Test.startTest();
		delete eventInsList;
		Test.stopTest();
		// 行動期間内の来店受付取得
		List<AppointmentReceipt__c> appointmentReceiptList =[
			SELECT Id, ReceiptDate__c, ReserveCanNotCount__c, ReserveStartTime__c
			FROM   AppointmentReceipt__c
			WHERE  Shop__c = :organizationHierarchy.shop__c 
			AND    ReceiptDate__c >= :setDate
			ORDER BY ReceiptDate__c
			,ReserveStartTime__c
		];
		// 予約不能数を取得
		for (AppointmentReceipt__c appointmentReceipt : appointmentReceiptList) {
			system.assertEquals(0,appointmentReceipt.ReserveCanNotCount__c
			,'エラー詳細（開始時刻：'+ appointmentReceipt.ReserveStartTime__c+'）');
			
		} 
	}

//********************************************************************************  privateメソッド  *************************************************************************************************
	/**
	 * 来店受付の1日分登録
	 * @param  Id shopId　登録店舗ID
	 * @param  Id arsdId　来店受付_店舗日別ID
	 * @param  Date setDate　登録日付
	 * @param  Decimal reserveCanCount　予約可能数
	 * @return List<AppointmentReceipt__c> 1日の来店受付リスト
	 */
	private static List<AppointmentReceipt__c> setAppointmentReceiptList(Id shopId,Id arsdId,Date setDate,Decimal reserveCanCount){
		List<AppointmentReceipt__c> appointmentReceiptList = new List<AppointmentReceipt__c>();
		Decimal i = 0;
		Integer setStTime = 9;
		Integer setStMins = 0;
		Integer setEndTime = 10;
		Integer setEndMins = 0;
		for (i = 1 ; i < 18; i++){
			Decimal checkTime = i / 2;
			if(checkTime.scale() == 0){
				// 開始日時〇〇時、３０分
				// 終了日時〇〇時＋１、００分
				setStMins = 30;
				setEndTime += 1;
				setEndMins = 0;
			}else{
				// 開始日時〇〇時＋１、００分
				// 終了日時〇〇時、３０分
				setStTime += 1;
				setStMins = 0;
				setEndMins = 30;
			}

			AppointmentReceipt__c appointmentReceipt = new AppointmentReceipt__c(
				ReceiptDate__c = setDate,
				Shop__c = shopId,
				ReserveStartTime__c =Time.newInstance(setStTime, setStMins, 0 ,0),
				ReserveEndTime__c = Time.newInstance(setEndTime, setEndMins, 0 ,0),
				ReserveCanCount__c = reserveCanCount,
				ReserveResultCount__c = 0 ,
				AppointmentReceiptStoreDate__c = arsdId,
				ReserveCanNotCount__c = 0
			);
			appointmentReceiptList.add(appointmentReceipt);
		}
		return appointmentReceiptList;
	}
//▲ 2022.02.09 No0601 対応で追加
}