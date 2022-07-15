// 店舗異動トリガーテスト
@istest
public with sharing class BA101009TriggerHandlerTest {

    // 起点となる日付
    private static Date setDate =  Date.newInstance(2021, 4, 1);

	// 行動の日付セット
	private static List<Date> setEventDateList = new List<Date>{
		Date.newInstance(2021, 4, 2),
		Date.newInstance(2021, 4, 4),
		Date.newInstance(2021, 4,10),
		Date.newInstance(2021, 4,15),
		Date.newInstance(2021, 4,20),
		Date.newInstance(2021, 4,25),
		Date.newInstance(2021, 4,30)
	};
	
	@TestSetup static void Setting(){

        // カスタム設定
        SystemConfig__c testSystemConfig = new SystemConfig__c();
        testSystemConfig.IsSkipTrigger__c = true;
        testSystemConfig.UseAuthority_Portal__c = true;
        testSystemConfig.TestDate__c = setDate;
        insert testSystemConfig;

        //ユーザ作成
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name IN ('一般ユーザ')];
        System.assert(profiles.size() > 0);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            insert new User(
                    UserName = 'Test@horaguchi.com',
                    Email = 'test@example.com',
                    LastName = 'ユーザ１',
                    Alias = 'test',
                    TimeZoneSidKey = 'Asia/Tokyo',
                    LocaleSidKey = 'ja_JP',
                    EmailEncodingKey = 'ISO-2022-JP',
                    LanguageLocaleKey = 'ja',
                    ProfileId = profiles.get(0).Id);
            insert new User(
                    UserName = 'Test2@horaguchi.com',
                    Email = 'test2@example.com',
                    LastName = 'ユーザ２',
                    Alias = 'test2',
                    TimeZoneSidKey = 'Asia/Tokyo',
                    LocaleSidKey = 'ja_JP',
                    EmailEncodingKey = 'ISO-2022-JP',
                    LanguageLocaleKey = 'ja',
                    ProfileId = profiles.get(0).Id);
        }
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'Test@horaguchi.com'];

        //店舗レコード
        Shop__c shopRecord1 = new shop__c(Name = 'テスト店舗１',
                PortalSitePostingDistrict__c = '港区;北区',
                Email__c = 'tempoEmail@rand.co.jp');
        Shop__c shopRecord2 = new shop__c(Name = 'テスト店舗２',
                PortalSitePostingDistrict__c = '港区;北区',
                Email__c = 'tempoEmail2@rand.co.jp');
        List<Shop__c> shopMap = new List<Shop__c>{
            shopRecord1,
            shopRecord2
        };
        insert shopMap;

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
            OrganizationName__c = 'テスト店舗１',
            HierarchyCode__c = '20',
            HierarchyOrder__c = 1,
            UpperOrganizationHierarchy__c = orgRecord1.Id,
            ExpandedOrganizationCode__c = '0000_0001_0002',
            Shop__c = shopRecord1.Id
        );
        insert orgRecord2;
        OrganizationHierarchy__c orgRecord3 = new OrganizationHierarchy__c(
            OrganizationCode__c = '0003',
            OrganizationName__c = 'テスト店舗２',
            HierarchyCode__c = '20',
            HierarchyOrder__c = 1,
            UpperOrganizationHierarchy__c = orgRecord1.Id,
            ExpandedOrganizationCode__c = '0000_0001_0003',
            Shop__c = shopRecord2.Id
        );
        insert orgRecord3;

        
        //来店受付_店舗日別
        // テスト店舗１
         AppointmentReceiptStoreDate__c arsd1 = new AppointmentReceiptStoreDate__c(
              PeopleLimit__c = 4 ,
              TargetDate__c = setDate ,
              Shop__c = shopRecord1.Id ,
              ProcessingFlg__c = true
         );
         insert arsd1;
        //  テスト店舗２
         AppointmentReceiptStoreDate__c arsd2 = new AppointmentReceiptStoreDate__c(
            PeopleLimit__c = 2 ,
            TargetDate__c = setDate ,
            Shop__c = shopRecord2.Id ,
            ProcessingFlg__c = true
        );
        insert arsd2; 
         
        // 来店受付
        // テスト店舗１： 2021/4/1 ～ 2021/4/30 
        // テスト店舗２： 2021/4/1 ～ 2021/4/30 
        List<AppointmentReceipt__c> appointmentReceiptList = new List<AppointmentReceipt__c>();
        appointmentReceiptList.addall(setAppointmentReceiptList(shopRecord1.Id, arsd1.Id, setDate, arsd1.PeopleLimit__c));
        appointmentReceiptList.addall(setAppointmentReceiptList(shopRecord2.Id, arsd2.Id, setDate, arsd2.PeopleLimit__c));
        for (Integer dayCount = 1 ;dayCount <= 30 ;dayCount++) {
            appointmentReceiptList.addall(setAppointmentReceiptList(shopRecord1.Id, arsd1.Id, setDate.addDays(dayCount), arsd1.PeopleLimit__c));    
            appointmentReceiptList.addall(setAppointmentReceiptList(shopRecord2.Id, arsd2.Id, setDate.addDays(dayCount), arsd2.PeopleLimit__c));
        }
        insert appointmentReceiptList;

        // 店舗異動レコード（ユーザ１）
        // テスト店舗１： 2021/4/ 1 ～ 2021/ 4/15
        // テスト店舗２： 2021/4/16 ～ 2999/12/31
        ShopTransfer__c ShopTransferRecord1 = new ShopTransfer__c(OrgzanizationHierarchy__c = orgRecord2.id,Staff__c = userRecord.id,
            StartDate__c = Date.newInstance(2021, 4,  1),EndDate__c = Date.newInstance(2021,  4, 15)); 
        ShopTransfer__c ShopTransferRecord2 = new ShopTransfer__c(OrgzanizationHierarchy__c = orgRecord3.id,Staff__c = userRecord.id,
            StartDate__c = Date.newInstance(2021, 4, 16),EndDate__c = Date.newInstance(2999, 12, 31)); 
        insert ShopTransferRecord1;
        insert ShopTransferRecord2;

        // スキップフラグを戻す
        testSystemConfig.IsSkipTrigger__c = false;
        update testSystemConfig;

        // 行動の登録
        // ユーザ１
        // 行動１： 2021/4/ 2 10:00 ～ 2021/4/ 2 14:00
        // 行動２： 2021/4/ 4 10:00 ～ 2021/4/ 4 18:00
        // 行動３： 2021/4/10 10:00 ～ 2021/4/10 18:00
        // 行動４： 2021/4/15 10:00 ～ 2021/4/15 18:00
        // 行動５： 2021/4/20 10:00 ～ 2021/4/20 18:00
        // 行動６： 2021/4/25 10:00 ～ 2021/4/25 18:00
        // 行動７： 2021/4/30 10:00 ～ 2021/4/30 18:00
        Event eventIns1 = new Event(OwnerId = userRecord.id,SUBJECT = CommonConst.SUBJECT_HOLIDAY,
            StartDateTime = DateTime.newInstance(setEventDateList[0], Time.newInstance(10, 0, 0, 0)),
			endDateTime   = DateTime.newInstance(setEventDateList[0], Time.newInstance(14, 0, 0, 0)));
        Event eventIns2 = new Event(OwnerId = userRecord.id,SUBJECT = CommonConst.SUBJECT_HOLIDAY,
            StartDateTime = DateTime.newInstance(setEventDateList[1], Time.newInstance(10, 0, 0, 0)),
			endDateTime   = DateTime.newInstance(setEventDateList[1], Time.newInstance(18,30, 0, 0)));
        Event eventIns3 = new Event(OwnerId = userRecord.id,SUBJECT = CommonConst.SUBJECT_HOLIDAY,
            StartDateTime = DateTime.newInstance(setEventDateList[2], Time.newInstance(10, 0, 0, 0)),
			endDateTime   = DateTime.newInstance(setEventDateList[2], Time.newInstance(18,30, 0, 0)));
        Event eventIns4 = new Event(OwnerId = userRecord.id,SUBJECT = CommonConst.SUBJECT_HOLIDAY,
			StartDateTime = DateTime.newInstance(setEventDateList[3], Time.newInstance(10, 0, 0, 0)),
			endDateTime   = DateTime.newInstance(setEventDateList[3], Time.newInstance(18,30, 0, 0)));
        Event eventIns5 = new Event(OwnerId = userRecord.id,SUBJECT = CommonConst.SUBJECT_HOLIDAY,
			StartDateTime = DateTime.newInstance(setEventDateList[4], Time.newInstance(10, 0, 0, 0)),
			endDateTime   = DateTime.newInstance(setEventDateList[4], Time.newInstance(18,30, 0, 0)));
        Event eventIns6 = new Event(OwnerId = userRecord.id,SUBJECT = CommonConst.SUBJECT_HOLIDAY,
			StartDateTime = DateTime.newInstance(setEventDateList[5], Time.newInstance(10, 0, 0, 0)),
			endDateTime   = DateTime.newInstance(setEventDateList[5], Time.newInstance(18,30, 0, 0)));
        Event eventIns7 = new Event(OwnerId = userRecord.id,SUBJECT = CommonConst.SUBJECT_HOLIDAY,
			StartDateTime = DateTime.newInstance(setEventDateList[6], Time.newInstance(10, 0, 0, 0)),
			endDateTime   = DateTime.newInstance(setEventDateList[6], Time.newInstance(18,30, 0, 0)));
		List<Event> eventInsList = new List<Event>{
			eventIns1,
			eventIns2,
			eventIns3,
			eventIns4,
			eventIns5,
			eventIns6,
			eventIns7
		};
		insert eventInsList;
		// スキップフラグを戻す
		testSystemConfig.IsSkipTrigger__c = true;
		update testSystemConfig;
        // ユーザ２
        // 行動１： 2021/4/ 2 10:00 ～ 2021/4/ 2 14:00
        // 行動２： 2021/4/ 4 10:00 ～ 2021/4/ 4 18:00
        // 行動３： 2021/4/10 10:00 ～ 2021/4/10 18:00
        // 行動４： 2021/4/15 10:00 ～ 2021/4/15 18:00
        // 行動５： 2021/4/20 10:00 ～ 2021/4/20 18:00
        // 行動６： 2021/4/25 10:00 ～ 2021/4/25 18:00
        // 行動７： 2021/4/30 10:00 ～ 2021/4/30 18:00
        User userRecord2 =  [SELECT Id FROM User WHERE UserName = 'Test2@horaguchi.com'];
        Event eventIns1test2 = new Event(OwnerId = userRecord2.id,SUBJECT = CommonConst.SUBJECT_HOLIDAY,
			StartDateTime = DateTime.newInstance(setEventDateList[0], Time.newInstance(10, 0, 0, 0)),
			endDateTime   = DateTime.newInstance(setEventDateList[0], Time.newInstance(14, 0, 0, 0)));
        Event eventIns2test2 = new Event(OwnerId = userRecord2.id,SUBJECT = CommonConst.SUBJECT_HOLIDAY,
			StartDateTime = DateTime.newInstance(setEventDateList[1], Time.newInstance(10, 0, 0, 0)),
			endDateTime   = DateTime.newInstance(setEventDateList[1], Time.newInstance(18,30, 0, 0)));
        Event eventIns3test2 = new Event(OwnerId = userRecord2.id,SUBJECT = CommonConst.SUBJECT_HOLIDAY,
			StartDateTime = DateTime.newInstance(setEventDateList[2], Time.newInstance(10, 0, 0, 0)),
			endDateTime   = DateTime.newInstance(setEventDateList[2], Time.newInstance(18,30, 0, 0)));
        Event eventIns4test2 = new Event(OwnerId = userRecord2.id,SUBJECT = CommonConst.SUBJECT_HOLIDAY,
			StartDateTime = DateTime.newInstance(setEventDateList[3], Time.newInstance(10, 0, 0, 0)),
			endDateTime   = DateTime.newInstance(setEventDateList[3], Time.newInstance(18,30, 0, 0)));
        Event eventIns5test2 = new Event(OwnerId = userRecord2.id,SUBJECT = CommonConst.SUBJECT_HOLIDAY,
			StartDateTime = DateTime.newInstance(setEventDateList[4], Time.newInstance(10, 0, 0, 0)),
			endDateTime   = DateTime.newInstance(setEventDateList[4], Time.newInstance(18,30, 0, 0)));
        Event eventIns6test2 = new Event(OwnerId = userRecord2.id,SUBJECT = CommonConst.SUBJECT_HOLIDAY,
			StartDateTime = DateTime.newInstance(setEventDateList[5], Time.newInstance(10, 0, 0, 0)),
			endDateTime   = DateTime.newInstance(setEventDateList[5], Time.newInstance(18,30, 0, 0)));
        Event eventIns7test2 = new Event(OwnerId = userRecord2.id,SUBJECT = CommonConst.SUBJECT_HOLIDAY,
			StartDateTime = DateTime.newInstance(setEventDateList[6], Time.newInstance(10, 0, 0, 0)),
			endDateTime   = DateTime.newInstance(setEventDateList[6], Time.newInstance(18,30, 0, 0)));
		List<Event> eventInsList2 = new List<Event>{
			eventIns1test2,
			eventIns2test2,
			eventIns3test2,
			eventIns4test2,
			eventIns5test2,
			eventIns6test2,
			eventIns7test2
		};
		insert eventInsList2;		
		// スキップフラグを戻す
		testSystemConfig.IsSkipTrigger__c = false;
		update testSystemConfig;
		System.debug('★初期設定完了★');
    }

    /**
    * １、店舗異動新規登録
    *     期間内に行動がある場合、対象店舗の来店受付の予約不能数が加算されること
	*     新規登録：テスト店舗１（ユーザ２）2000/12/ 1 ～ 2021/ 4/ 5
    */
    @isTest 
    static void shopTransferInsertTrigger1(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'Test2@horaguchi.com'];
        OrganizationHierarchy__c organizationHierarchy = [SELECT Id,shop__c FROM OrganizationHierarchy__c WHERE OrganizationName__c = 'テスト店舗１' LIMIT 1];

        Test.startTest();
        // 店舗異動の新規登録
        // テスト店舗１（ユーザ２）： 2000/12/ 1 ～ 2021/ 4/ 5
        ShopTransfer__c ShopTransferRecord = new ShopTransfer__c(
            OrgzanizationHierarchy__c = organizationHierarchy.id,
            Staff__c = userRecord.id,
            StartDate__c = Date.newInstance(2000, 12, 1),
            EndDate__c = Date.newInstance(2021, 4, 5)); 
        insert ShopTransferRecord;

        Test.stopTest();

        // 行動期間内の来店受付取得
        List<AppointmentReceipt__c> appointmentReceiptList =[
            SELECT ID,Shop__c,ReceiptDate__c,ReserveCanNotCount__c,ReserveStartTime__c
            FROM   AppointmentReceipt__c
            WHERE  Shop__c = :organizationHierarchy.shop__c 
            AND    ReceiptDate__c = :Date.newInstance(2021, 4, 2)
            ORDER BY ReceiptDate__c
			,ReserveStartTime__c
        ];
		// 予約不能数を取得
		for (AppointmentReceipt__c appointmentReceipt : appointmentReceiptList) {
			if(appointmentReceipt.ReserveStartTime__c >= Time.newInstance(10, 0, 0 ,0) && 
				appointmentReceipt.ReserveStartTime__c <= Time.newInstance(13,30, 0 ,0)){
				system.assertEquals(2,appointmentReceipt.ReserveCanNotCount__c
				,'エラー詳細（開始時刻：'+ appointmentReceipt.ReserveStartTime__c+'）');
			}else{
				system.assertEquals(0,appointmentReceipt.ReserveCanNotCount__c
				,'エラー詳細（開始時刻：'+ appointmentReceipt.ReserveStartTime__c+'）');
			}
		} 
    }

    /**
    * ２、店舗異動新規登録
    *     期間外に行動がある場合、対象店舗の来店受付の予約不能数が加算されないこと
	*	  新規登録：テスト店舗１（ユーザ１）： 2021/11/ 1 ～ 2099/12/ 1
    */
    @isTest 
    static void shopTransferInsertTrigger2(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'Test@horaguchi.com'];
        OrganizationHierarchy__c organizationHierarchy = [SELECT Id,shop__c FROM OrganizationHierarchy__c WHERE OrganizationName__c = 'テスト店舗１' LIMIT 1];
        
		// 行動期間内の来店受付取得
		Map<Id,AppointmentReceipt__c> beforeAppointmentReceiptShop1Map = new Map<Id,AppointmentReceipt__c>([
			SELECT Id, AppointmentReceiptStoreDate__c, ReceiptDate__c, ReserveCanCount__c, ReserveCanNotCount__c, ReserveEndTime__c, ReserveResultCount__c, ReserveStartTime__c, Shop__c
			FROM   AppointmentReceipt__c
			WHERE  Shop__c = :organizationHierarchy.shop__c 
		]);

        Test.startTest();
        // 店舗異動の新規登録
        // テスト店舗１（ユーザ１）： 2021/11/ 1 ～ 2099/12/ 1
        ShopTransfer__c ShopTransferRecord = new ShopTransfer__c(
            OrgzanizationHierarchy__c = organizationHierarchy.id,
            Staff__c = userRecord.id,
            StartDate__c = Date.newInstance(2021, 11, 1),
            EndDate__c = Date.newInstance(2999, 12, 1)); 
        insert ShopTransferRecord;

        Test.stopTest();

		// 行動期間内の来店受付取得
		List<AppointmentReceipt__c> appointmentReceiptShop1List =[
			SELECT Id, AppointmentReceiptStoreDate__c, ReceiptDate__c, ReserveCanCount__c, ReserveCanNotCount__c, ReserveEndTime__c, ReserveResultCount__c, ReserveStartTime__c, Shop__c
			FROM   AppointmentReceipt__c
			WHERE  Shop__c = :organizationHierarchy.shop__c 
			ORDER BY ReceiptDate__c
			,ReserveStartTime__c
		];

        // 予約不能数を取得
        for (AppointmentReceipt__c appointmentReceipt : appointmentReceiptShop1List) {
			if(beforeAppointmentReceiptShop1Map.containsKey(appointmentReceipt.Id)){
				// 件数に変動が無い
                system.assertEquals(beforeAppointmentReceiptShop1Map.get(appointmentReceipt.Id).ReserveCanNotCount__c,appointmentReceipt.ReserveCanNotCount__c
				,'エラー詳細（開始時刻：'+ appointmentReceipt.ReserveStartTime__c+'）');
			}
        }
    }

    /**
    * ３、店舗異動新規登録
    *     期間内の行動が現在日付より過去の場合、対象店舗の来店受付の予約不能数が加算されないこと
	*	  新規登録：テスト店舗２（ユーザ２）： 2021/ 4/ 1 ～ 2021/ 4/21
	*     カスタム設定の日付変更 ： 2021/4/ 1  →  2021/4/16
    */
    @isTest 
    static void shopTransferInsertTrigger3(){
        User user2Record =  [SELECT Id FROM User WHERE UserName = 'Test2@horaguchi.com'];
        OrganizationHierarchy__c organizationHierarchy = [SELECT Id,shop__c FROM OrganizationHierarchy__c WHERE OrganizationName__c = 'テスト店舗２' LIMIT 1];

        // カスタム設定の日付変更
		// 2021/4/ 1  →  2021/4/16
        SystemConfig__c testSystemConfig =[SELECT Id,TestDate__c FROM SystemConfig__c LIMIT 1];
        testSystemConfig.TestDate__c = setDate.addDays(15);
        update testSystemConfig;

		// 行動期間内の来店受付取得
		Map<Id,AppointmentReceipt__c> beforeAppointmentReceiptShopMap = new Map<Id,AppointmentReceipt__c>([
			SELECT Id, AppointmentReceiptStoreDate__c, ReceiptDate__c, ReserveCanCount__c, ReserveCanNotCount__c, ReserveEndTime__c, ReserveResultCount__c, ReserveStartTime__c, Shop__c
			FROM   AppointmentReceipt__c
			WHERE  Shop__c = :organizationHierarchy.shop__c 
		]);
        
        Test.startTest();
        // 店舗異動の新規登録
		// テスト店舗２（ユーザ２）： 2021/ 4/ 1 ～ 2021/ 4/21
        ShopTransfer__c ShopTransferRecord = new ShopTransfer__c(
            OrgzanizationHierarchy__c = organizationHierarchy.id,
            Staff__c = user2Record.id,
            StartDate__c = Date.newInstance(2021, 4, 1),
            EndDate__c = Date.newInstance(2021, 4,21)); 
        insert ShopTransferRecord;

        Test.stopTest();

        // 行動期間内の来店受付取得
        List<AppointmentReceipt__c> appointmentReceiptShopList =[
			SELECT Id, AppointmentReceiptStoreDate__c, ReceiptDate__c, ReserveCanCount__c, ReserveCanNotCount__c, ReserveEndTime__c, ReserveResultCount__c, ReserveStartTime__c, Shop__c
            FROM   AppointmentReceipt__c
            WHERE  Shop__c = :organizationHierarchy.shop__c 
            ORDER BY ReceiptDate__c
			,ReserveStartTime__c
        ]; 
        // 予約不能数を取得
        for (AppointmentReceipt__c appointmentReceipt : appointmentReceiptShopList) {
			AppointmentReceipt__c beforeAppointmentReceipt = beforeAppointmentReceiptShopMap.get(appointmentReceipt.Id);
			if(testSystemConfig.TestDate__c >= appointmentReceipt.ReceiptDate__c){
				// テスト日付以前
                system.assertEquals(beforeAppointmentReceipt.ReserveCanNotCount__c,appointmentReceipt.ReserveCanNotCount__c
				,'エラー詳細（テスト日付以前、開始時刻：'+ appointmentReceipt.ReceiptDate__c + appointmentReceipt.ReserveStartTime__c+'）');
			}else if(checkEventDateTimeSetting(appointmentReceipt.ReceiptDate__c,appointmentReceipt.ReserveStartTime__c) &&
					!(appointmentReceipt.ReceiptDate__c == Date.newInstance(2021, 4,25) || appointmentReceipt.ReceiptDate__c == Date.newInstance(2021, 4,30))){
				// テスト日付以降で行動がセットされている
                system.assertEquals(beforeAppointmentReceipt.ReserveCanNotCount__c + 1,appointmentReceipt.ReserveCanNotCount__c
				,'エラー詳細（テスト日付以降で行動がセットされている、開始時刻：'+ appointmentReceipt.ReceiptDate__c +appointmentReceipt.ReserveStartTime__c+'）');
            }else{
				// テスト日付以降で行動無し
				system.assertEquals(beforeAppointmentReceipt.ReserveCanNotCount__c ,appointmentReceipt.ReserveCanNotCount__c
				,'エラー詳細（テスト日付以降で行動無し、開始時刻：'+ appointmentReceipt.ReceiptDate__c +appointmentReceipt.ReserveStartTime__c+'）');
			}
        }         
    }

    /**
    * ４、店舗異動新規登録（複数）
    *     期間内に行動がある場合、対象店舗の来店受付の予約不能数が加算されること
	*	  新規登録：テスト店舗１（ユーザ２）： 2021/ 4/ 1 ～ 2999 / 12 / 1
	*	  新規登録：テスト店舗２（ユーザ２）： 2021/ 4/ 1 ～ 2999 / 12 / 1
    */
    @isTest 
    static void shopTransferInsertTriggerPlural1(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'Test2@horaguchi.com'];
        OrganizationHierarchy__c organizationHierarchy = [SELECT Id,shop__c FROM OrganizationHierarchy__c WHERE OrganizationName__c = 'テスト店舗１' LIMIT 1];
        OrganizationHierarchy__c organizationHierarchy2 = [SELECT Id,shop__c FROM OrganizationHierarchy__c WHERE OrganizationName__c = 'テスト店舗２' LIMIT 1];

		// 行動期間内の来店受付取得
		Map<Id,AppointmentReceipt__c> beforeAppointmentReceiptShop1Map = new Map<Id,AppointmentReceipt__c>([
			SELECT Id, AppointmentReceiptStoreDate__c, ReceiptDate__c, ReserveCanCount__c, ReserveCanNotCount__c, ReserveEndTime__c, ReserveResultCount__c, ReserveStartTime__c, Shop__c
			FROM   AppointmentReceipt__c
			WHERE  Shop__c = :organizationHierarchy.shop__c 
			ORDER BY ReceiptDate__c
			,ReserveStartTime__c
		]);
		Map<Id,AppointmentReceipt__c> beforeAppointmentReceiptShop2Map = new Map<Id,AppointmentReceipt__c>([
			SELECT Id, AppointmentReceiptStoreDate__c, ReceiptDate__c, ReserveCanCount__c, ReserveCanNotCount__c, ReserveEndTime__c, ReserveResultCount__c, ReserveStartTime__c, Shop__c
			FROM   AppointmentReceipt__c
			WHERE  Shop__c = :organizationHierarchy2.shop__c 
			ORDER BY ReceiptDate__c
			,ReserveStartTime__c
		]);
        
        Test.startTest();
        // 店舗異動の新規登録
		// テスト店舗１（ユーザ２）： 2021/ 4/ 1 ～ 2999 / 12 / 1
		// テスト店舗２（ユーザ２）： 2021/ 4/ 1 ～ 2999 / 12 / 1
        List<ShopTransfer__c> ShopTransferRecordList = new List<ShopTransfer__c>();
        ShopTransferRecordList.add(new ShopTransfer__c(
            OrgzanizationHierarchy__c = organizationHierarchy.id,
            Staff__c = userRecord.id,
            StartDate__c = Date.newInstance(2021, 4, 1),
            EndDate__c = Date.newInstance(2999, 12, 1)));
        ShopTransferRecordList.add( new ShopTransfer__c(
            OrgzanizationHierarchy__c = organizationHierarchy2.id,
            Staff__c = userRecord.id,
            StartDate__c = Date.newInstance(2021, 4, 1),
            EndDate__c = Date.newInstance(2999, 12, 1))); 
        insert ShopTransferRecordList;

        Test.stopTest();

		// 行動期間内の来店受付取得（店舗１）
		List<AppointmentReceipt__c> appointmentReceiptShop1List =[
			SELECT Id, AppointmentReceiptStoreDate__c, ReceiptDate__c, ReserveCanCount__c, ReserveCanNotCount__c, ReserveEndTime__c, ReserveResultCount__c, ReserveStartTime__c, Shop__c
			FROM   AppointmentReceipt__c
			WHERE  Shop__c = :organizationHierarchy.shop__c 
			ORDER BY ReceiptDate__c
			,ReserveStartTime__c
		]; 
		// 予約不能数を取得
		for (AppointmentReceipt__c appointmentReceipt : appointmentReceiptShop1List) {
			AppointmentReceipt__c beforeAppointmentReceipt = beforeAppointmentReceiptShop1Map.get(appointmentReceipt.Id);
			// 行動がセットされている期間は＋１されている
			if(checkEventDateTimeSetting(appointmentReceipt.ReceiptDate__c,appointmentReceipt.ReserveStartTime__c)){
				system.assertEquals(beforeAppointmentReceipt.ReserveCanNotCount__c +1 ,appointmentReceipt.ReserveCanNotCount__c
				,'エラー詳細（テスト店舗１、開始時刻：'+ appointmentReceipt.ReceiptDate__c + appointmentReceipt.ReserveStartTime__c+'）');
			}else{
				// 行動期間外は変動無し
				system.assertEquals(beforeAppointmentReceipt.ReserveCanNotCount__c ,appointmentReceipt.ReserveCanNotCount__c
				,'エラー詳細（テスト店舗１、開始時刻：'+ appointmentReceipt.ReceiptDate__c + appointmentReceipt.ReserveStartTime__c+'）');
			}			
		}   

		// 行動期間内の来店受付取得（店舗２）
		List<AppointmentReceipt__c> appointmentReceiptShop2List =[
			SELECT Id, AppointmentReceiptStoreDate__c, ReceiptDate__c, ReserveCanCount__c, ReserveCanNotCount__c, ReserveEndTime__c, ReserveResultCount__c, ReserveStartTime__c, Shop__c
			FROM   AppointmentReceipt__c
			WHERE  Shop__c = :organizationHierarchy2.shop__c 
			ORDER BY ReceiptDate__c
			,ReserveStartTime__c
		]; 
		// 予約不能数を取得
		for (AppointmentReceipt__c appointmentReceipt : appointmentReceiptShop2List) {
			AppointmentReceipt__c beforeAppointmentReceipt = beforeAppointmentReceiptShop2Map.get(appointmentReceipt.Id);
			if(checkEventDateTimeSetting(appointmentReceipt.ReceiptDate__c,appointmentReceipt.ReserveStartTime__c)){
				// 行動がセットされている期間は＋１されている
				system.assertEquals(beforeAppointmentReceipt.ReserveCanNotCount__c +1 ,appointmentReceipt.ReserveCanNotCount__c
				,'エラー詳細（テスト店舗２、開始時刻：'+ appointmentReceipt.ReceiptDate__c + appointmentReceipt.ReserveStartTime__c+'）');
			}else{
				// 行動期間外は変動無し
				system.assertEquals(beforeAppointmentReceipt.ReserveCanNotCount__c ,appointmentReceipt.ReserveCanNotCount__c
				,'エラー詳細（テスト店舗２、開始時刻：'+ appointmentReceipt.ReceiptDate__c + appointmentReceipt.ReserveStartTime__c+'）');
			}			
		}   
	
    }

    /**
    * ５、店舗異動新規登録（複数）
    *     期間外に行動がある場合、対象店舗の来店受付の予約不能数が加算されないこと
	*	  新規登録：テスト店舗１（ユーザ１）： 2021/ 5/ 1 ～ 2999 / 12 / 1
	*	  新規登録：テスト店舗２（ユーザ１）： 2021/ 5/ 1 ～ 2999 / 12 / 1
    */
    @isTest 
	static void shopTransferInsertTriggerPlural2(){
		User userRecord =  [SELECT Id FROM User WHERE UserName = 'Test@horaguchi.com'];
		OrganizationHierarchy__c organizationHierarchy = [SELECT Id,shop__c FROM OrganizationHierarchy__c WHERE OrganizationName__c = 'テスト店舗１' LIMIT 1];
		OrganizationHierarchy__c organizationHierarchy2 = [SELECT Id,shop__c FROM OrganizationHierarchy__c WHERE OrganizationName__c = 'テスト店舗２' LIMIT 1];
		// 行動期間内の来店受付取得
		Map<Id,AppointmentReceipt__c> beforeAppointmentReceiptShopMap = new Map<Id,AppointmentReceipt__c>([
			SELECT Id, AppointmentReceiptStoreDate__c, ReceiptDate__c, ReserveCanCount__c, ReserveCanNotCount__c, ReserveEndTime__c, ReserveResultCount__c, ReserveStartTime__c, Shop__c
			FROM   AppointmentReceipt__c
		]);
		Test.startTest();
		// 店舗異動の新規登録
		// テスト店舗１（ユーザ１）： 2021/ 5/ 1 ～ 2999 / 12 / 1
		// テスト店舗２（ユーザ１）： 2021/ 5/ 1 ～ 2999 / 12 / 1
		List<ShopTransfer__c> ShopTransferRecordList = new List<ShopTransfer__c>();
		ShopTransferRecordList.add(new ShopTransfer__c(
			OrgzanizationHierarchy__c = organizationHierarchy.id,
			Staff__c = userRecord.id,
			StartDate__c = Date.newInstance(2021, 5, 1),
			EndDate__c = Date.newInstance(2999, 12, 1)));
		ShopTransferRecordList.add( new ShopTransfer__c(
			OrgzanizationHierarchy__c = organizationHierarchy2.id,
			Staff__c = userRecord.id,
			StartDate__c = Date.newInstance(2021, 5, 1),
			EndDate__c = Date.newInstance(2999, 12, 1))); 
		insert ShopTransferRecordList;

		Test.stopTest();

		// 行動期間内の来店受付取得
		List<AppointmentReceipt__c> appointmentReceiptList =[
			SELECT Id, AppointmentReceiptStoreDate__c, ReceiptDate__c, ReserveCanCount__c, ReserveCanNotCount__c, ReserveEndTime__c, ReserveResultCount__c, ReserveStartTime__c, Shop__c
			FROM   AppointmentReceipt__c
			ORDER BY Shop__c
			,ReceiptDate__c
			,ReserveStartTime__c
		];

		// 予約不能数を取得
		for (AppointmentReceipt__c appointmentReceipt : appointmentReceiptList) {
			// 変更前と相違なし
			AppointmentReceipt__c beforeAppointmentReceipt = beforeAppointmentReceiptShopMap.get(appointmentReceipt.Id);
			system.assertEquals(beforeAppointmentReceipt.ReserveCanNotCount__c ,appointmentReceipt.ReserveCanNotCount__c);			
		} 
        
    }

    /**
    * ６、店舗異動削除
    *     期間内に行動がある場合、対象店舗の来店受付の予約不能数が減算されること
	*     削除：テスト店舗２（ユーザ１）：2021/4/16 ～ 2999/12/31
    */
    @isTest 
    static void shopTransferDeleteTrigger1(){

		// 削除：テスト店舗２（ユーザ１）：2021/4/16 ～ 2999/12/31
		ShopTransfer__c ShopTransferRecord = [SELECT Id,OrgzanizationHierarchy__r.shop__c FROM ShopTransfer__c WHERE OrgzanizationHierarchy__r.OrganizationName__c = 'テスト店舗２' LIMIT 1];
		Id shopId = ShopTransferRecord.OrgzanizationHierarchy__r.shop__c;

        Test.startTest();
        // 店舗異動の新規登録
        delete ShopTransferRecord;

        Test.stopTest();

        // 行動期間内の来店受付取得
        List<AppointmentReceipt__c> appointmentReceiptList =[
            SELECT ID,Shop__c,ReceiptDate__c,ReserveStartTime__c,ReserveCanNotCount__c
            FROM   AppointmentReceipt__c
            WHERE  Shop__c = :shopId 
        ];
        
        // 予約不能数を取得
        for (AppointmentReceipt__c appointmentReceipt : appointmentReceiptList) {
			// 店舗２の件数が0となっている
            system.assertEquals(0,appointmentReceipt.ReserveCanNotCount__c
			,'エラー詳細（開始時刻：'+ appointmentReceipt.ReserveStartTime__c+'）');
        }
        
    }

    /**
    * ７、店舗異動削除
    *     期間外に行動がある場合、対象店舗の来店受付の予約不能数が減算されないこと
	*     新規登録：テスト店舗２（ユーザ１）： 2021/ 4/ 1 ～ 2021/ 4/ 1
	*     削除：新規登録
    */
    @isTest 
    static void shopTransferDeleteTrigger2(){
		User userRecord =  [SELECT Id FROM User WHERE UserName = 'Test@horaguchi.com'];
		OrganizationHierarchy__c organizationHierarchy2 = [SELECT Id,shop__c FROM OrganizationHierarchy__c WHERE OrganizationName__c = 'テスト店舗２' LIMIT 1];
		// 行動期間内の来店受付取得
		Map<Id,AppointmentReceipt__c> beforeAppointmentReceiptShopMap = new Map<Id,AppointmentReceipt__c>([
			SELECT Id, AppointmentReceiptStoreDate__c, ReceiptDate__c, ReserveCanCount__c, ReserveCanNotCount__c, ReserveEndTime__c, ReserveResultCount__c, ReserveStartTime__c, Shop__c
			FROM   AppointmentReceipt__c
		]);
		// 店舗異動の新規登録
		// テスト店舗２（ユーザ１）： 2021/ 4/ 1 ～ 2021/ 4/ 1
		ShopTransfer__c ShopTransferRecord = new ShopTransfer__c(
			OrgzanizationHierarchy__c = organizationHierarchy2.id,
			Staff__c = userRecord.id,
			StartDate__c = Date.newInstance(2021, 4, 1),
			EndDate__c = Date.newInstance(2021, 4, 1)); 
		insert ShopTransferRecord;

        Test.startTest();
        // 店舗異動の削除
        delete ShopTransferRecord;

        Test.stopTest();

        // 行動期間内の来店受付取得
		List<AppointmentReceipt__c> appointmentReceiptList =[
			SELECT ID, Shop__c, ReceiptDate__c, ReserveCanNotCount__c
			FROM   AppointmentReceipt__c
		];
        
        // 予約不能数を取得
        for (AppointmentReceipt__c appointmentReceipt : appointmentReceiptList) {
			// 変更前と差異無し
			AppointmentReceipt__c beforeAppointmentReceipt = beforeAppointmentReceiptShopMap.get(appointmentReceipt.Id);
			system.assertEquals(beforeAppointmentReceipt.ReserveCanNotCount__c ,appointmentReceipt.ReserveCanNotCount__c);	
        }
        
    }

    /**
    * ８、店舗異動削除
    *     期間内の行動が現在日付より過去の場合、対象店舗の来店受付の予約不能数が加算されないこと
	*     削除：テスト店舗２（ユーザ１）：2021/4/16 ～ 2999/12/31
	*     カスタム設定の日付変更 ： 2021/4/ 1  →  2021/4/21
    */
    @isTest 
    static void shopTransferDeleteTrigger3(){

        // カスタム設定の日付変更 ： 2021/4/ 1  →  2021/4/21
        SystemConfig__c testSystemConfig =[SELECT Id,TestDate__c FROM SystemConfig__c LIMIT 1];
        testSystemConfig.TestDate__c = setDate.addDays(20);
        update testSystemConfig;
                
		// 削除：テスト店舗２（ユーザ１）：2021/4/16 ～ 2999/12/31
		ShopTransfer__c ShopTransferRecord = [SELECT Id,OrgzanizationHierarchy__r.shop__c FROM ShopTransfer__c WHERE OrgzanizationHierarchy__r.OrganizationName__c = 'テスト店舗２' LIMIT 1];
		Id shopId = ShopTransferRecord.OrgzanizationHierarchy__r.shop__c;
        Test.startTest();
        // 店舗異動の削除
        delete ShopTransferRecord;

        Test.stopTest();

        // 行動期間内の来店受付取得
        List<AppointmentReceipt__c> appointmentReceiptList =[
			SELECT ID, Shop__c, ReceiptDate__c, ReserveStartTime__c, ReserveCanNotCount__c
			FROM   AppointmentReceipt__c
			WHERE  Shop__c = :shopId 
        ];
        
        // 予約不能数を取得
        for (AppointmentReceipt__c appointmentReceipt : appointmentReceiptList) {
			if(appointmentReceipt.ReceiptDate__c == Date.newInstance(2021, 4,25) ||
			   appointmentReceipt.ReceiptDate__c == Date.newInstance(2021, 4,30)){
				// テスト日以降の件数比較
				system.assertEquals(0,appointmentReceipt.ReserveCanNotCount__c
				,'エラー詳細（テスト日付以降、開始時刻：'+appointmentReceipt.ReceiptDate__c + appointmentReceipt.ReserveStartTime__c+'）');
			}else if(appointmentReceipt.ReceiptDate__c == Date.newInstance(2021, 4,20) &&
			         checkEventDateTimeSetting(appointmentReceipt.ReceiptDate__c,appointmentReceipt.ReserveStartTime__c)){
				// テスト日以前の件数は1件
				system.assertEquals(1,appointmentReceipt.ReserveCanNotCount__c
				,'エラー詳細（テスト日付以降、開始時刻：'+appointmentReceipt.ReceiptDate__c + appointmentReceipt.ReserveStartTime__c+'）');
			}else {
				// それ以外0件
				system.assertEquals(0,appointmentReceipt.ReserveCanNotCount__c
				,'エラー詳細（行動範囲外、開始時刻：'+appointmentReceipt.ReceiptDate__c + appointmentReceipt.ReserveStartTime__c+'）');
			}
        }
        
    }

    /**
    * ９、店舗異動削除（複数）
    *     期間内に行動がある場合、対象店舗の来店受付の予約不能数が減算されること
	*     削除：テスト店舗１（ユーザ１）：2021/4/ 1 ～ 2021/ 4/15
	*     削除：テスト店舗２（ユーザ１）：2021/4/16 ～ 2999/12/31
    */
    @isTest 
    static void shopTransferDeleteTriggerPlural1(){
		// 店舗異動取得
        List<ShopTransfer__c> shopTransferList = [SELECT Id,OrgzanizationHierarchy__r.shop__c FROM ShopTransfer__c ];

        Test.startTest();
        // 店舗異動の削除
        delete shopTransferList;

        Test.stopTest();

        // 行動期間内の来店受付取得
        List<AppointmentReceipt__c> appointmentReceiptList =[
			SELECT ID, Shop__c, ReceiptDate__c, ReserveStartTime__c,ReserveCanNotCount__c
			FROM   AppointmentReceipt__c
		];
                
        // 予約不能数を取得
        for (AppointmentReceipt__c appointmentReceipt : appointmentReceiptList) {
			// 全削除で0件になる
            system.assertEquals(0,appointmentReceipt.ReserveCanNotCount__c);
        }
    }

    /**
    * １０、店舗異動削除（複数）
    *     期間外に行動がある場合、対象店舗の来店受付の予約不能数が減算されないこと
	*     新規登録：テスト店舗１（ユーザ２）： 2021/ 5/ 1 ～ 2021/ 6/ 1
	*     新規登録：テスト店舗２（ユーザ２）： 2021/ 5/ 1 ～ 2021/ 6/ 1
	*     削除：新規登録2件
    */
    @isTest 
    static void shopTransferDeleteTriggerPlural2(){
        User userRecord2 =  [SELECT Id FROM User WHERE UserName = 'Test2@horaguchi.com'];
        OrganizationHierarchy__c organizationHierarchy = [SELECT Id,shop__c FROM OrganizationHierarchy__c WHERE OrganizationName__c = 'テスト店舗１' LIMIT 1];
        OrganizationHierarchy__c organizationHierarchy2 = [SELECT Id,shop__c FROM OrganizationHierarchy__c WHERE OrganizationName__c = 'テスト店舗２' LIMIT 1];

		// 行動期間内の来店受付取得
		Map<Id,AppointmentReceipt__c> beforeAppointmentReceiptShopMap = new Map<Id,AppointmentReceipt__c>([
			SELECT Id, AppointmentReceiptStoreDate__c, ReceiptDate__c, ReserveCanCount__c, ReserveCanNotCount__c, ReserveEndTime__c, ReserveResultCount__c, ReserveStartTime__c, Shop__c
			FROM   AppointmentReceipt__c
		]);
		// 店舗異動の新規登録
        // テスト店舗１（ユーザ２）： 2021/ 5/ 1 ～ 2021/ 6/ 1
		List<ShopTransfer__c> ShopTransferRecordList = new List<ShopTransfer__c>();
		ShopTransferRecordList.add(new ShopTransfer__c(
			OrgzanizationHierarchy__c = organizationHierarchy.id,
			Staff__c = userRecord2.id,
			StartDate__c = Date.newInstance(2021, 5, 1),
			EndDate__c = Date.newInstance(2021, 6, 1))); 
		// テスト店舗２（ユーザ２）： 2021/ 5/ 1 ～ 2021/ 6/ 1
		ShopTransferRecordList.add( new ShopTransfer__c(
			OrgzanizationHierarchy__c = organizationHierarchy2.id,
			Staff__c = userRecord2.id,
			StartDate__c = Date.newInstance(2021, 5, 1),
			EndDate__c = Date.newInstance(2021, 6, 1))); 
		insert ShopTransferRecordList;

        Test.startTest();

        // 店舗異動の削除
        delete ShopTransferRecordList;

        Test.stopTest();
        // 行動期間内の来店受付取得
        List<AppointmentReceipt__c> appointmentReceiptList =[
			SELECT ID, Shop__c, ReceiptDate__c, ReserveCanNotCount__c
			FROM   AppointmentReceipt__c
        ];

        // 予約不能数を取得
        for (AppointmentReceipt__c appointmentReceipt : appointmentReceiptList) {
			// 変動無し
			AppointmentReceipt__c beforeAppointmentReceipt = beforeAppointmentReceiptShopMap.get(appointmentReceipt.Id);
			system.assertEquals(beforeAppointmentReceipt.ReserveCanNotCount__c ,appointmentReceipt.ReserveCanNotCount__c);	
        }
    }

    /**
    * １１、店舗異動更新
    *     期間内に行動がある場合、更新前の対象店舗の来店受付の予約不能数が減算され、
    *     更新後の対象店舗の来店受付の予約不能数が加算されること
	*     更新：テスト店舗１（ユーザ１）： 2021/4/ 1 ～ 2021/ 4/15 → 2021/4/10 ～ 2021/ 5/ 1
    */
    @isTest 
    static void shopTransferUpdateTrigger1(){
        OrganizationHierarchy__c organizationHierarchy = [SELECT Id,shop__c FROM OrganizationHierarchy__c WHERE OrganizationName__c = 'テスト店舗１' LIMIT 1];
		// 行動期間内の来店受付取得
		Map<Id,AppointmentReceipt__c> beforeAppointmentReceiptShopMap = new Map<Id,AppointmentReceipt__c>([
			SELECT Id, AppointmentReceiptStoreDate__c, ReceiptDate__c, ReserveCanCount__c, ReserveCanNotCount__c, ReserveEndTime__c, ReserveResultCount__c, ReserveStartTime__c, Shop__c
			FROM   AppointmentReceipt__c
			WHERE  Shop__c = :organizationHierarchy.shop__c 
		]);
		// 店舗異動レコード
        // テスト店舗１（ユーザ１）： 2021/4/ 1 ～ 2021/ 4/15 → 2021/4/10 ～ 2021/ 5/ 1
        ShopTransfer__c ShopTransferRecord = [SELECT Id,StartDate__c,EndDate__c FROM ShopTransfer__c WHERE OrgzanizationHierarchy__r.OrganizationName__c = 'テスト店舗１' LIMIT 1];
        ShopTransferRecord.StartDate__c = Date.newInstance(2021, 4, 10);
        ShopTransferRecord.EndDate__c = Date.newInstance(2021, 5, 1); 

		Test.startTest();
		//更新 
		update ShopTransferRecord;
		Test.stopTest();

		// 行動期間内の来店受付取得
		List<AppointmentReceipt__c> appointmentReceiptShopList =[
			SELECT Id, AppointmentReceiptStoreDate__c, ReceiptDate__c, ReserveCanCount__c, ReserveCanNotCount__c, ReserveEndTime__c, ReserveResultCount__c, ReserveStartTime__c, Shop__c
            ,Shop__r.name
			FROM   AppointmentReceipt__c
			WHERE  Shop__c = :organizationHierarchy.shop__c 
			ORDER BY ReceiptDate__c
			,ReserveStartTime__c
		]; 
		// 予約不能数を取得
		for (AppointmentReceipt__c appointmentReceipt : appointmentReceiptShopList) {
			AppointmentReceipt__c beforeAppointmentReceipt = beforeAppointmentReceiptShopMap.get(appointmentReceipt.Id);
			if(checkEventDateTimeSetting(appointmentReceipt.ReceiptDate__c,appointmentReceipt.ReserveStartTime__c)){
				if (appointmentReceipt.ReceiptDate__c == Date.newInstance(2021, 4, 2) || 
				    appointmentReceipt.ReceiptDate__c == Date.newInstance(2021, 4, 4)) {
					// 2日、4日は期間外で0件
					system.assertEquals(0 ,appointmentReceipt.ReserveCanNotCount__c
					,'エラー詳細（2日4日、開始時刻：'+ appointmentReceipt.ReserveStartTime__c+'）');
				}else {
					// それ以外は1件
					system.assertEquals(1 ,appointmentReceipt.ReserveCanNotCount__c
					,'エラー詳細（それ以外、店舗名：' + appointmentReceipt.Shop__r.name + '、開始時刻：'+ appointmentReceipt.ReceiptDate__c + appointmentReceipt.ReserveStartTime__c+'）');
				}
			}else{
				// 行動無しは変更前のまま
				system.assertEquals(beforeAppointmentReceipt.ReserveCanNotCount__c ,appointmentReceipt.ReserveCanNotCount__c
				,'エラー詳細（行動なし、開始時刻：'+ appointmentReceipt.ReserveStartTime__c+'）');
			}		
		} 
    }

    /**
    * １２、店舗異動更新
    *     期間外に行動がある場合、対象店舗の来店受付の予約不能数が加算されないこと
	*     更新：テスト店舗１（ユーザ１）： 2021/4/ 1 ～ 2021/ 4/15 → 2021/2/10 ～ 2021/ 4/ 1
    */
    @isTest 
    static void shopTransferUpdateTrigger2(){
        OrganizationHierarchy__c organizationHierarchy = [SELECT Id,shop__c FROM OrganizationHierarchy__c WHERE OrganizationName__c = 'テスト店舗１' LIMIT 1];
        // 店舗異動レコード
        // テスト店舗１（ユーザ１）： 2021/4/ 1 ～ 2021/ 4/15 → 2021/2/10 ～ 2021/ 4/ 1
        ShopTransfer__c ShopTransferRecord = [SELECT Id,StartDate__c,EndDate__c FROM ShopTransfer__c WHERE OrgzanizationHierarchy__r.OrganizationName__c = 'テスト店舗１' LIMIT 1];
        ShopTransferRecord.StartDate__c = Date.newInstance(2021, 2, 10);
        ShopTransferRecord.EndDate__c = Date.newInstance(2021, 4, 1); 
        
        Test.startTest();
        //更新 
        update ShopTransferRecord;
        Test.stopTest();

        // 行動期間内の来店受付取得
        List<AppointmentReceipt__c> appointmentReceiptSubtractionList =[
            SELECT ID,Shop__c,ReceiptDate__c,ReserveCanNotCount__c
            FROM   AppointmentReceipt__c
            WHERE  Shop__c = :organizationHierarchy.shop__c 
            AND    ReceiptDate__c = :Date.newInstance(2021, 4, 2)
            AND    ReserveStartTime__c >= :Time.newInstance(10, 0, 0 ,0)
            AND    ReserveEndTime__c <= :Time.newInstance(14, 0, 0 ,0)
        ];  
        // 予約不能数が減っていることを確認
        for (AppointmentReceipt__c appointmentReceipt : appointmentReceiptSubtractionList) {
            system.assertEquals(0,appointmentReceipt.ReserveCanNotCount__c);
        }
    }

    /**
    * １３ 店舗異動更新
    *     期間内の行動が現在日付より過去の場合、対象店舗の来店受付の予約不能数が変動しないこと
	*     カスタム設定の日付変更 ： 2021/4/ 1  →  2021/5/ 1
	*     更新：テスト店舗１（ユーザ１）： 2021/4/ 1 ～ 2021/ 4/15 → 2021/4/ 1 ～ 2021/4/ 1
    */
    @isTest 
    static void shopTransferUpdateTrigger3(){
        OrganizationHierarchy__c organizationHierarchy = [SELECT Id,shop__c FROM OrganizationHierarchy__c WHERE OrganizationName__c = 'テスト店舗１' LIMIT 1];
        // 行動期間内の来店受付取得
        Map<Id,AppointmentReceipt__c> beforeAppointmentReceiptMap = new Map<Id,AppointmentReceipt__c>([
            SELECT ID,ReserveCanNotCount__c
            FROM   AppointmentReceipt__c
            WHERE  Shop__c = :organizationHierarchy.shop__c 
            AND    ReceiptDate__c = :Date.newInstance(2021, 4, 30)
            AND    ReserveStartTime__c >= :Time.newInstance(10, 0, 0 ,0)
            AND    ReserveEndTime__c <= :Time.newInstance(18, 0, 0 ,0)
        ]);
        // 店舗異動レコード
        // テスト店舗１（ユーザ１）： 2021/4/ 1 ～ 2021/ 4/15 → 2021/4/ 1 ～ 2021/4/ 1
        ShopTransfer__c ShopTransferRecord = [SELECT Id,StartDate__c,EndDate__c FROM ShopTransfer__c WHERE OrgzanizationHierarchy__r.OrganizationName__c = 'テスト店舗１' LIMIT 1];
        ShopTransferRecord.StartDate__c = Date.newInstance(2021, 4, 1);
		ShopTransferRecord.EndDate__c = Date.newInstance(2021, 4, 1);
        // カスタム設定の日付変更
		// テスト日付	2021/4/ 1  →  2021/5/ 1
        SystemConfig__c testSystemConfig =[SELECT Id,TestDate__c FROM SystemConfig__c LIMIT 1];
        testSystemConfig.TestDate__c = setDate.addDays(30);
        update testSystemConfig;
        
        Test.startTest();
        //更新 
        update ShopTransferRecord;
        Test.stopTest();

        // 行動期間内の来店受付取得
        List<AppointmentReceipt__c> appointmentReceiptSubtractionList =[
            SELECT ID,Shop__c,ReceiptDate__c,ReserveCanNotCount__c
            FROM   AppointmentReceipt__c
            WHERE  Shop__c = :organizationHierarchy.shop__c 
            AND    ReceiptDate__c = :Date.newInstance(2021, 4, 30)
            AND    ReserveStartTime__c >= :Time.newInstance(10, 0, 0 ,0)
            AND    ReserveEndTime__c <= :Time.newInstance(18, 0, 0 ,0)
        ];          
        // 予約不能数が変わらないことを確認
        for (AppointmentReceipt__c appointmentReceipt : appointmentReceiptSubtractionList) {
            system.assertEquals(beforeAppointmentReceiptMap.get(appointmentReceipt.ID).ReserveCanNotCount__c,appointmentReceipt.ReserveCanNotCount__c);
        }
    }

    /**
    * １４、店舗異動更新（複数）
    *     期間内に行動がある場合、更新前の対象店舗の来店受付の予約不能数が減算され、
    *     更新後の対象店舗の来店受付の予約不能数が加算されること
	*     更新：テスト店舗１（ユーザ１）： 2021/4/ 1 ～ 2021/ 4/15 → 2021/4/16 ～ 2999/12/31
	*     更新：テスト店舗２（ユーザ１）： 2021/4/16 ～ 2999/12/31 → 2021/4/ 1 ～ 2021/ 4/15
    */
    @isTest 
    static void shopTransferUpdateTriggerPlural1(){
        // 店舗異動レコード
        // テスト店舗１（ユーザ１）： 2021/4/ 1 ～ 2021/ 4/15 → 2021/4/16 ～ 2999/12/31
        ShopTransfer__c ShopTransferRecord = [SELECT Id,StartDate__c,EndDate__c FROM ShopTransfer__c WHERE OrgzanizationHierarchy__r.OrganizationName__c = 'テスト店舗１' LIMIT 1];
        ShopTransferRecord.StartDate__c = Date.newInstance(2021, 4, 16);
        ShopTransferRecord.EndDate__c = Date.newInstance(2999, 12, 31); 
        // テスト店舗２（ユーザ１）： 2021/4/16 ～ 2999/12/31 → 2021/4/ 1 ～ 2021/ 4/15
        ShopTransfer__c ShopTransferRecord2 = [SELECT Id,StartDate__c,EndDate__c FROM ShopTransfer__c WHERE OrgzanizationHierarchy__r.OrganizationName__c = 'テスト店舗２' LIMIT 1];
        ShopTransferRecord2.StartDate__c = Date.newInstance(2021, 4, 1);
        ShopTransferRecord2.EndDate__c = Date.newInstance(2021, 4,15);
        List<ShopTransfer__c> ShopTransferRecordList = new List<ShopTransfer__c>{
            ShopTransferRecord,
            ShopTransferRecord2
        };

        Test.startTest();
        //更新 
        update ShopTransferRecordList;
        Test.stopTest();

		OrganizationHierarchy__c organizationHierarchy = [SELECT Id,shop__c FROM OrganizationHierarchy__c WHERE OrganizationName__c = 'テスト店舗１' LIMIT 1];
        
		// 行動期間内の来店受付取得（店舗１）
		List<AppointmentReceipt__c> appointmentReceiptShopList =[
			SELECT Id, AppointmentReceiptStoreDate__c, ReceiptDate__c, ReserveCanCount__c, ReserveCanNotCount__c, ReserveEndTime__c, ReserveResultCount__c, ReserveStartTime__c, Shop__c
			FROM   AppointmentReceipt__c
            WHERE  Shop__c = :organizationHierarchy.shop__c 
			ORDER BY ReceiptDate__c
			,ReserveStartTime__c
		]; 
		// 予約不能数を取得
		for (AppointmentReceipt__c appointmentReceipt : appointmentReceiptShopList) {
			if(checkEventDateTimeSetting(appointmentReceipt.ReceiptDate__c,appointmentReceipt.ReserveStartTime__c)){
				// 行動範囲
				if(appointmentReceipt.ReceiptDate__c == Date.newInstance(2021,4,20) ||
					appointmentReceipt.ReceiptDate__c == Date.newInstance(2021,4,25) ||
					appointmentReceipt.ReceiptDate__c == Date.newInstance(2021,4,30)){
					// 16日以降の行動有は１件
					system.assertEquals(1 ,appointmentReceipt.ReserveCanNotCount__c
					,'エラー詳細（テスト店舗１、加算、開始時刻：'+ appointmentReceipt.ReceiptDate__c + appointmentReceipt.ReserveStartTime__c+'）');
				}else{
					// それ以外の行動有は0件
					system.assertEquals(0 ,appointmentReceipt.ReserveCanNotCount__c
					,'エラー詳細（テスト店舗１、減算、開始時刻：'+ appointmentReceipt.ReceiptDate__c + appointmentReceipt.ReserveStartTime__c+'）');
				}	
			}else{
				// 行動範囲外
				system.assertEquals(0 ,appointmentReceipt.ReserveCanNotCount__c
				,'エラー詳細（テスト店舗１、行動無、開始時刻：'+ appointmentReceipt.ReceiptDate__c + appointmentReceipt.ReserveStartTime__c+'）');
			}
		}

		OrganizationHierarchy__c organizationHierarchy2 = [SELECT Id,shop__c FROM OrganizationHierarchy__c WHERE OrganizationName__c = 'テスト店舗２' LIMIT 1];
		// 行動期間内の来店受付取得（店舗２）
		List<AppointmentReceipt__c> appointmentReceiptShop2List =[
			SELECT Id, AppointmentReceiptStoreDate__c, ReceiptDate__c, ReserveCanCount__c, ReserveCanNotCount__c, ReserveEndTime__c, ReserveResultCount__c, ReserveStartTime__c, Shop__c
			FROM   AppointmentReceipt__c
            WHERE  Shop__c = :organizationHierarchy2.shop__c 
			ORDER BY ReceiptDate__c
			,ReserveStartTime__c
		]; 
		// 予約不能数を取得
		for (AppointmentReceipt__c appointmentReceipt : appointmentReceiptShop2List) {
			if(checkEventDateTimeSetting(appointmentReceipt.ReceiptDate__c,appointmentReceipt.ReserveStartTime__c)){
				// 行動範囲
				if(appointmentReceipt.ReceiptDate__c == Date.newInstance(2021,4,20) ||
				   appointmentReceipt.ReceiptDate__c == Date.newInstance(2021,4,25) ||
				   appointmentReceipt.ReceiptDate__c == Date.newInstance(2021,4,30)){
					// 16日以降の行動有は０件
					system.assertEquals(0 ,appointmentReceipt.ReserveCanNotCount__c
					,'エラー詳細（テスト店舗２、減算、開始時刻：'+ appointmentReceipt.ReceiptDate__c + appointmentReceipt.ReserveStartTime__c+'）');
				}else{
					// それ以外の行動有は1件
					system.assertEquals(1 ,appointmentReceipt.ReserveCanNotCount__c
					,'エラー詳細（テスト店舗２、加算、開始時刻：'+ appointmentReceipt.ReceiptDate__c + appointmentReceipt.ReserveStartTime__c+'）');
					
				}	
			}else{
				// 行動範囲外
				system.assertEquals(0 ,appointmentReceipt.ReserveCanNotCount__c
				,'エラー詳細（テスト店舗２、行動無、開始時刻：'+ appointmentReceipt.ReceiptDate__c + appointmentReceipt.ReserveStartTime__c+'）');
			}		
		} 
    }

    /**
    * １５、店舗異動更新（複数）
    *     期間外に行動がある場合、対象店舗の来店受付の予約不能数が加算されないこと
	*     更新：テスト店舗１（ユーザ１）： 2021/4/ 1 ～ 2021/ 4/15 → 2021/4/ 1 ～ 2021/ 4/ 1
	*     更新：テスト店舗２（ユーザ１）： 2021/4/16 ～ 2999/12/31 → 2021/4/26 ～ 2021/ 4/27
    */
    @isTest 
    static void shopTransferUpdateTriggerPlural2(){
        OrganizationHierarchy__c organizationHierarchy = [SELECT Id,shop__c FROM OrganizationHierarchy__c WHERE OrganizationName__c = 'テスト店舗１' LIMIT 1];
        OrganizationHierarchy__c organizationHierarchy2 = [SELECT Id,shop__c FROM OrganizationHierarchy__c WHERE OrganizationName__c = 'テスト店舗２' LIMIT 1];
        // 店舗異動レコード更新
        // テスト店舗１（ユーザ１）： 2021/4/ 1 ～ 2021/ 4/15 → 2021/4/ 1 ～ 2021/ 4/ 1
        ShopTransfer__c ShopTransferRecord = [SELECT Id,StartDate__c,EndDate__c FROM ShopTransfer__c WHERE OrgzanizationHierarchy__r.OrganizationName__c = 'テスト店舗１' LIMIT 1];
        ShopTransferRecord.StartDate__c = Date.newInstance(2021, 4, 1);
        ShopTransferRecord.EndDate__c = Date.newInstance(2021, 4, 1);
        // テスト店舗２（ユーザ１）： 2021/4/16 ～ 2999/12/31 → 2021/4/26 ～ 2021/ 4/27
        ShopTransfer__c ShopTransferRecord2 = [SELECT Id,StartDate__c,EndDate__c FROM ShopTransfer__c WHERE OrgzanizationHierarchy__r.OrganizationName__c = 'テスト店舗２' LIMIT 1];
        ShopTransferRecord2.StartDate__c = Date.newInstance(2021, 4, 26);
        ShopTransferRecord2.EndDate__c = Date.newInstance(2021, 4, 27);

        List<ShopTransfer__c> ShopTransferRecordList = new List<ShopTransfer__c>{
            ShopTransferRecord,
            ShopTransferRecord2
        };

        Test.startTest();
        //更新 
        update ShopTransferRecordList;
        Test.stopTest();

		// 行動期間内の来店受付取得（店舗１）
		List<AppointmentReceipt__c> appointmentReceiptShop1List =[
			SELECT Id, AppointmentReceiptStoreDate__c, ReceiptDate__c, ReserveCanCount__c, ReserveCanNotCount__c, ReserveEndTime__c, ReserveResultCount__c, ReserveStartTime__c, Shop__c
			FROM   AppointmentReceipt__c
			WHERE  Shop__c = :organizationHierarchy.shop__c 
			ORDER BY ReceiptDate__c
			,ReserveStartTime__c
		]; 
		// 予約不能数を取得
		for (AppointmentReceipt__c appointmentReceipt : appointmentReceiptShop1List) {
			// 期間外のため0件
			system.assertEquals(0 ,appointmentReceipt.ReserveCanNotCount__c
			,'エラー詳細（テスト店舗１、開始時刻：'+ appointmentReceipt.ReceiptDate__c + appointmentReceipt.ReserveStartTime__c+'）');	
		}

		// 行動期間内の来店受付取得（店舗２）
		List<AppointmentReceipt__c> appointmentReceiptShop2List =[
			SELECT Id, AppointmentReceiptStoreDate__c, ReceiptDate__c, ReserveCanCount__c, ReserveCanNotCount__c, ReserveEndTime__c, ReserveResultCount__c, ReserveStartTime__c, Shop__c
			FROM   AppointmentReceipt__c
			WHERE  Shop__c = :organizationHierarchy2.shop__c 
			ORDER BY ReceiptDate__c
			,ReserveStartTime__c
		]; 
		// 予約不能数を取得
		for (AppointmentReceipt__c appointmentReceipt : appointmentReceiptShop2List) {
			// 期間外のため0件
			system.assertEquals(0 ,appointmentReceipt.ReserveCanNotCount__c
			,'エラー詳細（テスト店舗２、開始時刻：'+ appointmentReceipt.ReceiptDate__c + appointmentReceipt.ReserveStartTime__c+'）');
		}
    }

    /**	
    * １６、店舗異動、新規、更新、削除（複数）
    *     期間内に行動がある場合、更新前の対象店舗の来店受付の予約不能数が減算され、
    *     更新後の対象店舗の来店受付の予約不能数が加算されること
	*     新規登録１：テスト店舗１（ユーザ１）： 2021/ 4/19 ～ 2021/ 4/20
	*     新規登録２：テスト店舗２（ユーザ２）： 2021/ 4/ 1 ～ 2021/ 4/20
	*     新規登録３：テスト店舗２（ユーザ２）： 2021/ 4/25 ～ 2021/ 4/30
	*     更新：テスト店舗１（ユーザ１）：2021/4/ 1 ～ 2021/ 4/15　→　 2021/4/ 1 ～ 2021/ 4/ 1
	*     更新：テスト店舗２（ユーザ１）：2021/4/16 ～ 2999/12/31　→　 2021/4/26 ～ 2021/ 4/30
	*     削除：新規登録１、新規登録３
    */
    @isTest 
    static void shopTransferAllTrigger(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'Test@horaguchi.com'];
		User userRecord2 =  [SELECT Id FROM User WHERE UserName = 'Test2@horaguchi.com'];
        OrganizationHierarchy__c organizationHierarchy = [SELECT Id,shop__c FROM OrganizationHierarchy__c WHERE OrganizationName__c = 'テスト店舗１' LIMIT 1];
        OrganizationHierarchy__c organizationHierarchy2 = [SELECT Id,shop__c,shop__R.NAME FROM OrganizationHierarchy__c WHERE OrganizationName__c = 'テスト店舗２' LIMIT 1];

        // 店舗異動レコード
		// 新規登録
        // テスト店舗１（ユーザ１）： 2021/ 4/19 ～ 2021/ 4/20
        ShopTransfer__c ShopTransferRecordInsert = new ShopTransfer__c(
            OrgzanizationHierarchy__c = organizationHierarchy.id,
            Staff__c = userRecord.id,
            StartDate__c = Date.newInstance(2021, 4, 19),
            EndDate__c = Date.newInstance(2021, 4, 20)); 
		// テスト店舗２（ユーザ２）： 2021/ 4/ 1 ～ 2021/ 4/20
		ShopTransfer__c ShopTransferRecordInsert2 = new ShopTransfer__c(
			OrgzanizationHierarchy__c = organizationHierarchy2.id,
			Staff__c = userRecord2.id,
			StartDate__c = Date.newInstance(2021, 4, 1),
			EndDate__c = Date.newInstance(2021, 4, 20)); 
		// テスト店舗２（ユーザ２）： 2021/ 4/25 ～ 2021/ 4/30
		ShopTransfer__c ShopTransferRecordInsert3 = new ShopTransfer__c(
			OrgzanizationHierarchy__c = organizationHierarchy2.id,
			Staff__c = userRecord2.id,
			StartDate__c = Date.newInstance(2021, 4,25),
			EndDate__c = Date.newInstance(2021, 4, 30)); 

		// 更新：テスト店舗１（ユーザ１）：2021/4/ 1 ～ 2021/ 4/15　→　 2021/4/ 1 ～ 2021/ 4/ 1
		ShopTransfer__c ShopTransferRecord = [SELECT Id,StartDate__c,EndDate__c FROM ShopTransfer__c WHERE OrgzanizationHierarchy__r.OrganizationName__c = 'テスト店舗１' LIMIT 1];
		ShopTransferRecord.StartDate__c = Date.newInstance(2021, 4, 1);
		ShopTransferRecord.EndDate__c = Date.newInstance(2021, 4, 1);
		// 更新：テスト店舗２（ユーザ１）：2021/4/16 ～ 2999/12/31　→　 2021/4/26 ～ 2021/ 4/30
		ShopTransfer__c ShopTransferRecord2 = [SELECT Id,StartDate__c,EndDate__c FROM ShopTransfer__c WHERE OrgzanizationHierarchy__r.OrganizationName__c = 'テスト店舗２' LIMIT 1];
		ShopTransferRecord2.StartDate__c = Date.newInstance(2021, 4, 26);
		ShopTransferRecord2.EndDate__c = Date.newInstance(2021, 4, 30);

        Test.startTest();

		List<ShopTransfer__c> ShopTransferRecordList = new List<ShopTransfer__c>{
			ShopTransferRecordInsert,
			ShopTransferRecordInsert2,
			ShopTransferRecordInsert3,
			ShopTransferRecord,
			ShopTransferRecord2
		};

		// 削除
		// 新規登録１、新規登録３
		List<ShopTransfer__c> ShopTransferRecordDelList = new List<ShopTransfer__c>{
			ShopTransferRecordInsert,
			ShopTransferRecordInsert3
		};

        //登録＋更新 
        upsert ShopTransferRecordList;

		// 削除
		delete ShopTransferRecordDelList;
		
        Test.stopTest();

		// 行動期間内の来店受付取得（店舗１）
		List<AppointmentReceipt__c> appointmentReceiptShopList =[
			SELECT Id, AppointmentReceiptStoreDate__c, ReceiptDate__c, ReserveCanCount__c, ReserveCanNotCount__c, ReserveEndTime__c, ReserveResultCount__c, ReserveStartTime__c, Shop__c
			FROM   AppointmentReceipt__c
			WHERE  Shop__c = :organizationHierarchy.shop__c 
			ORDER BY ReceiptDate__c
			,ReserveStartTime__c
		]; 
		// 予約不能数を取得
		for (AppointmentReceipt__c appointmentReceipt : appointmentReceiptShopList) {
			// 全て0件
			system.assertEquals(0 ,appointmentReceipt.ReserveCanNotCount__c
			,'エラー詳細（テスト店舗１、開始時刻：'+ appointmentReceipt.ReceiptDate__c + appointmentReceipt.ReserveStartTime__c+'）');
		} 

		// 行動期間内の来店受付取得（店舗２）
		List<AppointmentReceipt__c> appointmentReceiptShop2List =[
			SELECT Id, AppointmentReceiptStoreDate__c, ReceiptDate__c, ReserveCanCount__c, ReserveCanNotCount__c, ReserveEndTime__c, ReserveResultCount__c, ReserveStartTime__c, Shop__c
			FROM   AppointmentReceipt__c
			WHERE  Shop__c = :organizationHierarchy2.shop__c 
			ORDER BY ReceiptDate__c
			,ReserveStartTime__c
		]; 
		// 予約不能数を取得
		for (AppointmentReceipt__c appointmentReceipt : appointmentReceiptShop2List) {
			// 新規登録２：テスト店舗２（ユーザ２）： 2021/ 4/ 1 ～ 2021/ 4/20
			// 新規登録３：テスト店舗２（ユーザ２）： 2021/ 4/25 ～ 2021/ 4/30
			// 更新：テスト店舗２（ユーザ１）：2021/4/16 ～ 2999/12/31　→　 2021/4/26 ～ 2021/ 4/30
			// 削除：新規登録３
			if (appointmentReceipt.ReceiptDate__c == Date.newInstance(2021, 4, 25) ) {
				// 25日は削除されているため0件
				system.assertEquals(0 ,appointmentReceipt.ReserveCanNotCount__c
				,'エラー詳細（テスト店舗２、開始時刻：'+ appointmentReceipt.ReceiptDate__c + appointmentReceipt.ReserveStartTime__c+'）');
			}else if(checkEventDateTimeSetting(appointmentReceipt.ReceiptDate__c,appointmentReceipt.ReserveStartTime__c)){
				// 他の行動が設定されている日は1件
				system.assertEquals(1 ,appointmentReceipt.ReserveCanNotCount__c
				,'エラー詳細（テスト店舗２、開始時刻：'+ appointmentReceipt.ReceiptDate__c + appointmentReceipt.ReserveStartTime__c+'）');
			}else{
				// それ以外は0件
				system.assertEquals(0 ,appointmentReceipt.ReserveCanNotCount__c
				,'エラー詳細（テスト店舗２、開始時刻：'+ appointmentReceipt.ReceiptDate__c + appointmentReceipt.ReserveStartTime__c+'）');				
			}
		} 
    }

    /**
    * １７、自社ポータル権限無
    *       期間内に行動がある場合でも、対象店舗の来店受付の予約不能数が加算されないこと
	*       新規登録：テスト店舗１（ユーザ２）：2000/12/ 1 ～ 2021/ 4/20
    */
    @isTest 
    static void shopTransferNoAuthority(){
        User userRecord2 =  [SELECT Id FROM User WHERE UserName = 'Test2@horaguchi.com'];
		OrganizationHierarchy__c organizationHierarchy = [SELECT Id,shop__c FROM OrganizationHierarchy__c WHERE OrganizationName__c = 'テスト店舗１' LIMIT 1];

        // 権限を無しにする
        SystemConfig__c testSystemConfig =[SELECT Id,UseAuthority_Portal__c FROM SystemConfig__c LIMIT 1];
        testSystemConfig.UseAuthority_Portal__c = false;
        update testSystemConfig;

        // 行動期間内の来店受付取得
        Map<Id,AppointmentReceipt__c> beforeAppointmentReceiptMap = new Map<Id,AppointmentReceipt__c>([
            SELECT ID,ReserveCanNotCount__c
            FROM   AppointmentReceipt__c
            WHERE  Shop__c = :organizationHierarchy.shop__c 
        ]);
        
        Test.startTest();
        // 店舗異動の新規登録
		// 新規登録：テスト店舗１（ユーザ２）：2000/12/ 1 ～ 2021/ 4/20
        ShopTransfer__c ShopTransferRecord = new ShopTransfer__c(
            OrgzanizationHierarchy__c = organizationHierarchy.id,
            Staff__c = userRecord2.id,
            StartDate__c = Date.newInstance(2000, 12, 1),
            EndDate__c = Date.newInstance(2021, 4, 20)); 
        insert ShopTransferRecord;

        Test.stopTest();

        // 行動期間内の来店受付取得
        List<AppointmentReceipt__c> appointmentReceiptList =[
            SELECT ID,Shop__c,ReceiptDate__c,ReserveStartTime__c,ReserveCanNotCount__c
            FROM   AppointmentReceipt__c
            WHERE  Shop__c = :organizationHierarchy.shop__c 
        ];

        // 予約不能数を取得
        for (AppointmentReceipt__c appointmentReceipt : appointmentReceiptList) {
			// 件数に変動無し
            system.assertEquals(beforeAppointmentReceiptMap.get(appointmentReceipt.ID).ReserveCanNotCount__c,appointmentReceipt.ReserveCanNotCount__c
			,'エラー詳細（テスト店舗１、開始時刻：'+ appointmentReceipt.ReceiptDate__c + appointmentReceipt.ReserveStartTime__c+'）');
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

	/**
	 * 行動範囲内有無の判定
	 * @param  Date checkDate　チェック日付
	 * @param  Time checkTime　チェック時間
	 * @return Boolean True：行動の範囲内、False：行動の範囲外
	 */
	private static Boolean checkEventDateTimeSetting(Date checkDate,Time checkTime){
		// 4月2日は14時まで
		Integer edTime = checkDate == setEventDateList[0]  ? 14 : 18 ;
		Integer edMinute = checkDate == setEventDateList[0]  ? 0 : 30 ;
		for (date setEventDate: setEventDateList){
			if(setEventDate == checkDate &&
			(checkTime >= Time.newInstance(10, 0, 0, 0) &&
			checkTime < Time.newInstance(edTime, edMinute, 0, 0))){
				return true;
			}
		}
		return false;
	}
}