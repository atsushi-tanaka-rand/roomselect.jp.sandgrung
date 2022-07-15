/**
 * 顧客関連共通クラステスト
 */
@isTest
public with sharing class CustomerUtilTest {

	/**
	 * 初期設定
	 */
	@testSetup static void setting(){

		// 標準プロファイルの取得
		Id profileId = [
			SELECT Id
			FROM Profile
			WHERE Name = '一般ユーザ'
		].Id;

		// ユーザの登録
		System.runAs(getThisUser()) {
			User testUser = new User(
				LastName			= 'ippanUser'		   // 姓
				, Alias				= 'alias'			   // 別名
				, Email				= 'ippanUserCustomerUtilTest@test.com' // メール
				, UserName			= 'ippanUserCustomerUtilTest@test.com' // ユーザ名	// 2022.04.20 No0768 ユーザ名が他と被る可能性があるので一意になりそうな内容へ変更
				, CommunityNickname	= 'テストニックネーム'	// ニックネーム
				, EmailEncodingKey	= 'ISO-2022-JP'		   // メールの文字コード
				, TimeZoneSidKey	= 'Asia/Tokyo'		   // タイムゾーン
				, LocaleSidKey		= 'ja_JP'			   // 地域
				, LanguageLocaleKey	= 'ja'				   //言語
				, ProfileId			= profileId			   // プロファイルID
			);
			
			insert testUser;     
		}
		User testUser =  [SELECT Id FROM User WHERE UserName = 'ippanUserCustomerUtilTest@test.com'];

		// 取引先の登録
		Account account1 = new Account(
			Name = '取引先テスト1'
			, RecordTypeId = CommonUtil.getRecordTypeId(Account.getSObjectType().getDescribe().getName()
														, CommonConst.ACCOUNT_RECTYPE_CUSTOMER)
		);
		Account account2 = new Account(
			Name = '取引先テスト2'
			, RecordTypeId = CommonUtil.getRecordTypeId(Account.getSObjectType().getDescribe().getName()
														, CommonConst.ACCOUNT_RECTYPE_SUPPLIER)
		);
		List<Account> accountList = new List<Account> {
			account1
			, account2
		};
		insert accountList;

		// 対応の登録
		Correspond__c correspond1 = new Correspond__c(
			AccountId__c				= account1.Id
			, Status__c					= CommonConst.CORRESPOND_STATUS_NOTSUPPORTED
			, PursuitDissolveDate__c	= Datetime.newInstance(2000, 1, 1)
			, AppointmentStartDate__c	= Datetime.newInstance(2000, 1, 2)
		);
		Correspond__c correspond2 = new Correspond__c(
			AccountId__c				= account2.Id
			, Status__c					= CommonConst.CORRESPOND_STATUS_NOTSUPPORTED
			, PursuitDissolveDate__c	= Datetime.newInstance(2000, 1, 1)
			, AppointmentStartDate__c	= Datetime.newInstance(2000, 1, 2)
		);
		List<Correspond__c> correspondList = new List<Correspond__c>{
			correspond1
			, correspond2
		};
		insert correspondList;

		// ▼ 2022.02.15 No0727 追加申込の共通部品
        //★建物
        Building__c appBuildingRecord = new Building__c( Name = 'テスト建物1'
                                                         ,State__c = '愛知県'
                                                         ,City__c = '名古屋市中区'
                                                         ,Street__c = '1-1');
        insert appBuildingRecord;
		//★物件
		Property__c appPropertyRecord = new Property__c(Name = '101',Building__c = appBuildingRecord.id);
		insert appPropertyRecord;
		// 申込
		Application__c testApplicationRecord = new Application__c(
			Account__c = account1.id
			,Property__c = appPropertyRecord.id
			,Corresponds__c = correspond1.id
			,Rent__c = 60000                  //賃料
			,WortFee__c = 1000                //水道料金
			,SecurityDeposit__c = 20000       //敷金
			,ActualFee__c = 10000             //敷引/償却
			,ManagementFee__c = 5000          //管理費
			,CATV__c = 2000                   //CATV
			,Deposit__c = 20000               //保証金
			,RenewalFeeYen__c = 5000          //更新料/更新事務手数料
			,TownshipFee__c=3000
			,GarbageDisposalFee__c=2000
			,KeyMoney__c=3000
			,TownshipAdmissionFee__c=2000
			,BicycleParkingFee__c=3000
			,CleaningFeeYen__c=2000
			,KeyExchangeFee__c=5000
			,CancellationActualFeeUnit__c='円'
			//駐車場
			,ParkingFee__c=1000
			,ParkingDeposit__c=2000
			,ParkingBrokerageFirstFee__c=3000
			,BikeStorageSmallFirstFee__c=2000
			,BikeStorageMediumFirstFee__c=3000
			,BikeStorageLargeFirstFee__c=4000
			//契約者情報
			,ApplicationType__c='個人'
			,ApplicationDate__c=Date.newInstance(2020,1,14) 
			,TenantDesiredDate__c=Date.newInstance(2020,4,1) 
			,IsTenantPersonInclude__c=true
			,LastName__c='申込'
			,FirstName__c='テスト太郎'
			,LastNameKana__c='モウシコミ'
			,FirstNameKana__c='テストタロウ'
			,Birthdate__c=Date.newInstance(1990,1,1) 
			,IsSpouse__c='有'
			,ChildrenCount__c=1
			,Current__c='111-1111'
			,CurrentState__c='愛知県'
			,CurrentCity__c='名古屋市テスト町'
			,CurrentStreet__c='4-1-34'
			,ResidenceType__c='マンション（分譲）'
			,ResidenceTermYear__c=3
			,ResidenceTermMonth__c=1
			,CurrentPhone__c='1234-111-1234'
			,CurrentMobilePhone__c='090-0000-0000'
			//契約者勤務先
			,Affiliation__c='株式会社テスト勤務'
			,Industries__c='製造業'
			,AffiliationPostalCode__c='112-1122'
			,AffiliationState__c='愛知県'
			,AffiliationCity__c='北名古屋市テスト区'
			,AffiliationStreet__c='1-3-99'
			,AffiliationPhone__c='1122-111-2222'
			,Department__c='営業部'
			,JobType__c='会社員'
			,Post__c='係長'
			,AnnualIncome__c=4000000
			,ContinuedServiceYearsYear__c=5
			,ContinuedServiceYearsMonth__c=2
			//車両
			,CarMaker__c='トヨタ'
			,CarType__c='シャシュ'
			,CarColor__c='黒'
			,RegistNumber__c='名古屋111ん00-00'
			//連帯保証人
			,JointGuarantorLastName__c='申込'
			,JointGuarantorFirstName__c='テストの助'
			,JointGuarantorLastNameKana__c='モウシコミ'
			,JointGuarantorFirstNameKana__c='テストノスケ'
			,JointGuarantorPostalCode__c='222-2222'
			,JointGuarantorState__c='愛知県'
			,JointGuarantorCity__c='豊田市テス町'
			,JointGuarantorStreet__c='11-111'
			,JointGuarantorBirthdate__c=Date.newInstance(1980,1,1) 
			,JointGuarantorPhone__c='123-1111-2222'
			,JointGuarantorMobilePhone__c='090-1111-1111'
			,ApplicantRelationship__c='兄'
			,JointGuarantorIsSpouse__c='有'
			,JointGuarantorResidenceType__c='自己所有'
			//連帯保証人勤務先
			,JointGuarantorAffiliation__c='連帯テスト株式会社'
			,JointGuarantorIndustries__c='建設業'
			,JointGuarantorAffiliationPostalCode__c='343-4443'
			,JointGuarantorAffiliationState__c='静岡県'
			,JointGuarantorAffiliationCity__c='静岡市テスト町'
			,JointGuarantorAffiliationStreet__c='4-44'
			,JointGuarantorAffiliationPhone__c='234-444-4444'
			,JointGuarantorDepartment__c='販売部'
			,JointGuarantorJobType__c='会社員'
			,JointGuarantorPost__c='販売部長'
			,JointGuarantorAnnualIncome__c=5000000
			,JointGuarantorContinuedServiceYearsYear__c=15
			,JointGuarantorContinuedServiceYearsMonth__c=10
			//火災保険の利用有無
			,IsFireInsurancePlanUse__c=false
			// 口コミ画面用金額
			,RentFee__c = 10000
			,AllRentFee__c = 20000
		);
		insert testApplicationRecord;
		Account accountRecord = new Account(Name = 'テスト保証株式会社',IsAllRentFeeType__c = true);	// 総賃料に口座手数料を含む
		insert accountRecord;
		//保証プラン
		// テスト保証株式会社：付帯商品、賃料割合（保証会社）５０％、手数料１０００
		Item__c guaranteeItemRecord = new Item__c(
			Account__c = accountRecord.id
			,IsAuxiliary__c = true
			,ItemName__c = 'テスト保証プラン1'
			,RecordTypeId = commonUtil.getRecordTypeId(commonUtil.getNamespace('Item__c'),commonConst.ITEM_RECTYPE_GUARANTEE_PLAN)
			,RentFeeRate__c = 50
			,DirectDebitFee__c = 1000);
		insert guaranteeItemRecord;
		// 初回保証料(割合)
		// 総賃料、総賃料に口座振替手数料を含む、手数料税込み
		ItemDetail__c itemDetail = new ItemDetail__c(PlanDetail__c = '割合総賃料口座税込み',IsRentFeeType__c = true,Item__c = guaranteeItemRecord.id,FirstFeeDepositRate__c = 50,DepositRate__c=60);
		insert itemDetail;
		// ▲ 2022.02.15 No0727 追加申込の共通部品
		System.debug('完');
	}

	/**
	 * ステータス変更テスト
	 */
	@istest static void chgStatusTest() {

		// ステータス変更マップ（key:現在のステータス、（key:追客保留前ステータス、value:更新後のステータス））
		Map<String, Map<String, String>> statusMap = new Map<String, Map<String, String>>{
			CommonConst.CORRESPOND_STATUS_NOTSUPPORTED			=>	new Map<String, String>{null => CommonConst.CORRESPOND_STATUS_PURSUIT}
			, CommonConst.CORRESPOND_STATUS_APOCANCEL			=>	new Map<String, String>{null => CommonConst.CORRESPOND_STATUS_APOCANCEL_PURSUIT}
			, CommonConst.CORRESPOND_STATUS_APPLCANCEL			=>	new Map<String, String>{null => CommonConst.CORRESPOND_STATUS_APPLCANCEL_PURSUIT}
			, CommonConst.CORRESPOND_STATUS_CONSIDERVISITING	=>	new Map<String, String>{null =>	CommonConst.CORRESPOND_STATUS_VISITED_PURSUIT}
			, CommonConst.CORRESPOND_STATUS_CLOSE				=>	new Map<String, String>{null =>	CommonConst.CORRESPOND_STATUS_PURSUIT}
			, CommonConst.CORRESPOND_STATUS_PURSUITHOLD			=>	new Map<String, String>{CommonConst.CORRESPOND_STATUS_PURSUIT				=>	CommonConst.CORRESPOND_STATUS_PURSUIT
																							, CommonConst.CORRESPOND_STATUS_APOCANCEL			=>	CommonConst.CORRESPOND_STATUS_APOCANCEL_PURSUIT
																							, CommonConst.CORRESPOND_STATUS_APOCANCEL_PURSUIT	=>	CommonConst.CORRESPOND_STATUS_APOCANCEL_PURSUIT
																							, CommonConst.CORRESPOND_STATUS_CONSIDERVISITING	=>	CommonConst.CORRESPOND_STATUS_VISITED_PURSUIT
																							, CommonConst.CORRESPOND_STATUS_VISITED_PURSUIT		=>	CommonConst.CORRESPOND_STATUS_VISITED_PURSUIT
																							, CommonConst.CORRESPOND_STATUS_APPLCANCEL			=>	CommonConst.CORRESPOND_STATUS_APPLCANCEL_PURSUIT
																							, CommonConst.CORRESPOND_STATUS_APPLCANCEL_PURSUIT	=>	CommonConst.CORRESPOND_STATUS_APPLCANCEL_PURSUIT
																						   }
		};

		// 取引先の取得
		Account account = [
			SELECT Id
			FROM Account
			WHERE Name = '取引先テスト1'
		];

		// ステータスに応じた対応を作成
		List<Correspond__c> correspondList = new List<Correspond__c>();
		for (String statusKey : statusMap.keySet()) {
			for (String statusBeforePursuitHoldKey : statusMap.get(statusKey).keySet()) {
				correspondList.add(
					new Correspond__c(
						Status__c						= statusKey
						, StatusBeforePursuitHold__c	= statusBeforePursuitHoldKey
						, AccountId__c					= account.Id
					)
				);
			}
		}
		insert correspondList;
	
		System.runAs(getThisUser()) {
			Test.startTest();

			// 更新後ステータスチェック
			for (Correspond__c correspond : correspondList) {

				// 更新後ステータスの取得
				String updStatus = CustomerUtil.changeSpecificStatus(correspond.id);

				// 実施後
				System.assertEquals(
					updStatus
					, statusMap.get(correspond.Status__c).get(correspond.StatusBeforePursuitHold__c)
					, '更新後ステータス'
				);
			}

			Test.stopTest();
		}
	}

	/**
	 * 一覧表示日時テスト
	 */
	@istest static void listViewDateTest() {

		// 翌日付の取得
		Datetime tommorowDate = getTommorowDate();

		// 対応の取得
		Correspond__c correspond = [
			SELECT
				Id
				, PursuitDissolveDate__c
				, AppointmentStartDate__c
			FROM Correspond__c
			WHERE AccountId__r.Name = '取引先テスト1'
		];

		// 一覧表示日時マップ（key:更新後のステータス、value:日付の設定値）
		Map<String, Datetime> listViewDateMap = new Map<String, DateTime>{
			CommonConst.CORRESPOND_STATUS_PURSUIT				=>	tommorowDate
			, CommonConst.CORRESPOND_STATUS_APOCANCEL_PURSUIT	=>	tommorowDate
			, CommonConst.CORRESPOND_STATUS_VISITED_PURSUIT		=>	tommorowDate
			, CommonConst.CORRESPOND_STATUS_APPLCANCEL_PURSUIT	=>	tommorowDate
			, CommonConst.CORRESPOND_STATUS_PURSUITHOLD			=>	correspond.PursuitDissolveDate__c
			, CommonConst.CORRESPOND_STATUS_APPOINTMENT			=>	correspond.AppointmentStartDate__c.addDays(-1)
		};

		System.runAs(getThisUser()) {
			Test.startTest();
			
			// 一覧表示日時チェック
			for (String statusKey : listViewDateMap.keySet()) {

				// 一覧表示日時の取得
				DateTime listViewDate = CustomerUtil.setListViewDateWhenCorrespondCheck(statusKey, correspond.id);

				// 実施後
				System.assertEquals(
					listViewDate
					, listViewDateMap.get(statusKey)
					, '一覧表示日時の取得値'
				);
			}

			Test.stopTest();
		}
	}

	/**
	 * 業者の対応テスト
	 */
	@istest static void CorrespondSupplierTest() {

		// 対応の取得
		Correspond__c correspond = [
			SELECT
				Id
				, Status__c 
			FROM Correspond__c
			WHERE AccountId__r.Name = '取引先テスト2'
		];

		System.runAs(getThisUser()) {
			Test.startTest();
			
			// 更新後ステータスチェック
			String updStatus = CustomerUtil.changeSpecificStatus(correspond.id);
			System.assertEquals(
				updStatus
				, correspond.Status__c
				, '更新後ステータス'
			);

			// 一覧表示日時チェック
			DateTime listViewDate = CustomerUtil.setListViewDateWhenCorrespondCheck(CommonConst.CORRESPOND_STATUS_PURSUIT, correspond.id);
			System.assertEquals(
				listViewDate
				, CommonConst.LAST_DATE
				, '一覧表示日時の取得値'
			);

			Test.stopTest();
		}
	}

	// ▼ 2022.02.15 No0727 追加申込の共通部品
	/**
	 * 総賃料の計算（物件外）
	 */
	@istest static void calcAllRentApplicationTest() {
		Application__c application = [SELECT ID
			,Rent__c,WortFee__c,ManagementFee__c,CATV__c,TownshipFee__c,GarbageDisposalFee__c,BicycleParkingFee__c
			,BikeStorageSmallFirstFee__c,BikeStorageMediumFirstFee__c,BikeStorageLargeFirstFee__c,ParkingFee__c,FireInsuranceMonth__c
			FROM Application__c LIMIT 1];
		List<ApplicantQuoteManageCompayItem__c> manageItemList = new List<ApplicantQuoteManageCompayItem__c>();
		Test.startTest();
		// 総賃料の計算（物件外）
		Decimal allRentFee = CustomerUtil.calcAllRentApplication(application,manageItemList);

		Test.stopTest();
		
		System.assertEquals(
			allRentFee
			, 86000
			, '総賃料の計算（物件外）'
		);
	}
	/**
	 * 付帯保証プランのデータ取得
	 * 付帯保証金額計算
	 * 選択リスト値の金額返却
	 */
	@istest static void getDepositPlanTest() {
		Application__c application = [SELECT ID,RentFee__c,AllRentFee__c FROM Application__c LIMIT 1];
		Map<Id, Decimal> auxiliaryMap = new Map<Id, Decimal>();
		Test.startTest();
		// 付帯保証プランのデータ取得
		List<ItemDetail__c> itemDetailList = CustomerUtil.getDepositPlan(); 
		id auxiliaryDepositPlan = itemDetailList[0].id;
        for (ItemDetail__c itemDetail : itemDetailList) {
			auxiliaryMap.put(itemDetail.id,CustomerUtil.depositPlanCalculation(itemDetail,application.RentFee__c,application.AllRentFee__c));
        }
		// 選択リスト値の金額返却
		String auxiliaryFireInsuranceFee = CustomerUtil.returnScreenMoney(auxiliaryMap,auxiliaryDepositPlan);
		Test.stopTest();
		System.assertEquals(
			auxiliaryFireInsuranceFee
			, '5,250'
			, '選択リスト値の金額返却'
		);
	}
	/**
	 * その他付帯商品名の選択リストを作成
	 */
	@istest static void getEtceteraAuxiliaryItemNameListFromTypeTest() {
		Application__c application = [SELECT ID
			, AuxiliaryItem1__c                             // 付帯商品１．付帯商品Id
			, AuxiliaryItem1__r.AuxiliaryItemType__c        // 付帯商品１．付帯商品種別
			, AuxiliaryItem1__r.Account__r.Name             // 付帯商品１．付帯業者
			, AuxiliaryItem1__r.ItemName__c                 // 付帯商品１．付帯商品
			, auxiliaryItemFee1__c                          // 付帯商品料１（販売価格１）
			, AuxiliaryItem2__c                             // 付帯商品２．付帯商品Id
			, AuxiliaryItem2__r.AuxiliaryItemType__c        // 付帯商品２．付帯商品種別
			, AuxiliaryItem2__r.Account__r.Name             // 付帯商品２．付帯業者
			, AuxiliaryItem2__r.ItemName__c                 // 付帯商品２．付帯商品
			, auxiliaryItemFee2__c                          // 付帯商品料２（販売価格２）
			, AuxiliaryItem3__c                             // 付帯商品３．付帯商品Id
			, AuxiliaryItem3__r.AuxiliaryItemType__c        // 付帯商品３．付帯商品種別
			, AuxiliaryItem3__r.Account__r.Name             // 付帯商品３．付帯業者
			, AuxiliaryItem3__r.ItemName__c                 // 付帯商品３．付帯商品
			, auxiliaryItemFee3__c                          // 付帯商品料３（販売価格３）
			, AuxiliaryItem4__c                             // 付帯商品４．付帯商品Id
			, AuxiliaryItem4__r.AuxiliaryItemType__c        // 付帯商品４．付帯商品種別
			, AuxiliaryItem4__r.Account__r.Name             // 付帯商品４．付帯業者
			, AuxiliaryItem4__r.ItemName__c                 // 付帯商品４．付帯商品
			, auxiliaryItemFee4__c                          // 付帯商品料４（販売価格４）
			, AuxiliaryItem5__c                             // 付帯商品５．付帯商品Id
			, AuxiliaryItem5__r.AuxiliaryItemType__c        // 付帯商品５．付帯商品種別
			, AuxiliaryItem5__r.Account__r.Name             // 付帯商品５．付帯業者
			, AuxiliaryItem5__r.ItemName__c                 // 付帯商品５．付帯商品
			, auxiliaryItemFee5__c                          // 付帯商品料５（販売価格５）
			, AuxiliaryItem6__c                             // 付帯商品６．付帯商品Id
			, AuxiliaryItem6__r.AuxiliaryItemType__c        // 付帯商品６．付帯商品種別
			, AuxiliaryItem6__r.Account__r.Name             // 付帯商品６．付帯業者
			, AuxiliaryItem6__r.ItemName__c                 // 付帯商品６．付帯商品
			, auxiliaryItemFee6__c                          // 付帯商品料６（販売価格６）
			, AuxiliaryItem7__c                             // 付帯商品７．付帯商品Id
			, AuxiliaryItem7__r.AuxiliaryItemType__c        // 付帯商品７．付帯商品種別
			, AuxiliaryItem7__r.Account__r.Name             // 付帯商品７．付帯業者
			, AuxiliaryItem7__r.ItemName__c                 // 付帯商品７．付帯商品
			, auxiliaryItemFee7__c                          // 付帯商品料７（販売価格７）
			, AuxiliaryItem8__c                             // 付帯商品８．付帯商品Id
			, AuxiliaryItem8__r.AuxiliaryItemType__c        // 付帯商品８．付帯商品種別
			, AuxiliaryItem8__r.Account__r.Name             // 付帯商品８．付帯業者
			, AuxiliaryItem8__r.ItemName__c                 // 付帯商品８．付帯商品
			, auxiliaryItemFee8__c                          // 付帯商品料８（販売価格８）
			, AuxiliaryItem9__c                             // 付帯商品９．付帯商品Id
			, AuxiliaryItem9__r.AuxiliaryItemType__c        // 付帯商品９．付帯商品種別
			, AuxiliaryItem9__r.Account__r.Name             // 付帯商品９．付帯業者
			, AuxiliaryItem9__r.ItemName__c                 // 付帯商品９．付帯商品
			, auxiliaryItemFee9__c                          // 付帯商品料９（販売価格９）
			, AuxiliaryItem10__c                            // 付帯商品１０．付帯商品Id
			, AuxiliaryItem10__r.AuxiliaryItemType__c       // 付帯商品１０．付帯商品種別
			, AuxiliaryItem10__r.Account__r.Name            // 付帯商品１０．付帯業者
			, AuxiliaryItem10__r.ItemName__c                // 付帯商品１０．付帯商品
			, auxiliaryItemFee10__c                         // 付帯商品料１０（販売価格１０）
		FROM Application__c LIMIT 1];
		Map<Id, Item__c> etceteraAuxiliaryItemMap = new Map<Id, Item__c>();
		Test.startTest();
		// 付帯商品のリスト
		List<CustomerUtil.AuxiliaryItem> etceteraAuxiliaryItemList = new List<CustomerUtil.AuxiliaryItem>();
		for (Integer i = 1; i <= 10; i++) {
			CustomerUtil.AuxiliaryItem item = new CustomerUtil.AuxiliaryItem(application, i);
			if (!String.isempty(item.auxiliaryItemId)) {
				etceteraAuxiliaryItemList.add(item);
			}
		}
		// その他付帯商品名の選択リストを作成
		List<SelectOption> SelectEtceteraAuxiliaryItemNameList = CustomerUtil.getEtceteraAuxiliaryItemNameListFromType('テスト',etceteraAuxiliaryItemMap);
		Test.stopTest();
		// System.assertEquals(
		// 	SelectEtceteraAuxiliaryItemNameList
		// 	, correspond.Status__c
		// 	, 'その他付帯商品名の選択リストを作成'
		// );
	}
	/**
	 * Decimal⇒Stringのコンバート
	 */
	@istest static void decimalToStringExTest() {

		Test.startTest();
		// Decimal⇒Stringのコンバート
		String decimalToString = CustomerUtil.decimalToStringEx(0);
		Test.stopTest();
		System.assertEquals(
			decimalToString
			, null
			, 'Decimal⇒Stringのコンバート ='+decimalToString
		);
	}
	/**
	 * 付帯火災保険のデータ取得
	 * その他付帯商品の一覧を検索
	 */
	@istest static void getFireInsuranceListTest() {

		Test.startTest();

		// 付帯火災保険のデータ取得
		List<Item__c> itemList= CustomerUtil.getFireInsuranceList();
		// その他付帯商品の一覧を検索
		Map<Id, Item__c> etceteraAuxiliaryItemMap = CustomerUtil.searchEtceteraAuxiaryItemRecode();
		Test.stopTest();
		// System.assertEquals(
		// 	updStatus
		// 	, correspond.Status__c
		// 	, '更新後ステータス'
		// );
	}
	// ▲ 2022.02.15 No0727 追加申込の共通部品

	//▼ 2022.04.20 No0768 対応で追加

	/**
	 * LINE画面遷移時に対応が無い場合に新規登録する処理
	 * ステータス：終了
	*/
	@istest static void checkCorrespondLineTest01(){
		// Line会員登録
		Datetime nowDateTime = CommonUtil.getNow();
		LineMember__c lineMember = new LineMember__c(Name = '対応終了' , LineId__c= 'Uf124585fafd38f4337a2434830d55001',AddFriendTime__c = nowDateTime ); 
		insert lineMember;
		Correspond__c correspond = [SELECT Id ,EventDateTime__c
			FROM Correspond__c
			WHERE LineMember__c = :lineMember.id 
			LIMIT 1
		];
		correspond.status__c = CommonConst.CORRESPOND_STATUS_CLOSE;
		System.runAs(getThisUser()) {
			Test.startTest();

			CustomerUtil.checkCorrespondLine(lineMember.id,true);

			Test.stopTest();
		}
	}
	/**
	 * LINE画面遷移時に対応が無い場合に新規登録する処理
	 * 対応無
	*/
	@istest static void checkCorrespondLineTest02(){
		// Line会員登録
		Datetime nowDateTime = CommonUtil.getNow();
		SystemConfig__c testSystemConfig = new SystemConfig__c(
			UseAuthority_Portal__c = true // 利用権限
			, IsSkipTrigger__c= true 
		);
        insert testSystemConfig;
		LineMember__c lineMember = new LineMember__c(Name = '対応無' , LineId__c= 'Uf124585fafd38f4337a2434830d55001',AddFriendTime__c = nowDateTime ); 
		insert lineMember;	
		
		System.runAs(getThisUser()) {
			Test.startTest();

			CustomerUtil.checkCorrespondLine(lineMember.id,false);

			Test.stopTest();
		}
	}
	

	//▲ 2022.04.20 No0768 対応で追加
	
//---------------------------------------------------------------------------------------------
//●privateメソッド	
	// ▲ 2022.02.15 No0727 追加

	/**
	 * ユーザの取得
	 * @return User ユーザ
	 */
	private static User getThisUser() {

		User user = [
			SELECT Id
			FROM User
			WHERE Id = :UserInfo.getUserId()
		];

		return user;
	}

	/**
	 * 翌日付の取得
	 * @return DateTime 翌日付
	 */
	private static DateTime getTommorowDate() {

		Date tomorrow = CommonUtil.getToday().addDays(1); 
		Time zeroTime = Time.newInstance(0, 0, 0, 0);

		return Datetime.newInstance(tomorrow, zeroTime);
	}

}