// 物件トリガーハンドラAPEXテストクラス
@isTest
private class BD301002TriggerHandlerTest {

    //テストに使用するレコードを作成する
    @testSetup static void Setting(){

        // 路線
        TrainRoute__c trainRoute1 = new TrainRoute__c();
        TrainRoute__c trainRoute2 = new TrainRoute__c();
        TrainRoute__c trainRoute3 = new TrainRoute__c();
        List<TrainRoute__c> trainRouteList = new List<TrainRoute__c>{
            trainRoute1
            , trainRoute2
            , trainRoute3
        };
        insert trainRouteList;

        // 駅
        Station__c station1 = new Station__c(
            Name = 'テスト駅1'
            , TrainRoute__c = trainRoute1.Id
        );
        Station__c station2 = new Station__c(
            Name = 'テスト駅2'
            , TrainRoute__c = trainRoute2.Id
        );
        Station__c station3 = new Station__c(
            Name = 'テスト駅3'
            , TrainRoute__c = trainRoute3.Id
        );
        List<Station__c> stationList = new List<Station__c>{
            station1
            , station2
            , station3
        };
        insert stationList;

        // 希望路線
        DesiredTrainRoute__c desiredTrainRoute1 = new DesiredTrainRoute__c(
            TrainRoute__c = trainRoute1.Id
        );
        DesiredTrainRoute__c desiredTrainRoute2 = new DesiredTrainRoute__c(
            TrainRoute__c = trainRoute2.Id
        );
        DesiredTrainRoute__c desiredTrainRoute3 = new DesiredTrainRoute__c(
            TrainRoute__c = trainRoute3.Id
        );
        List<DesiredTrainRoute__c> desiredTrainRouteList = new List<DesiredTrainRoute__c>{
            desiredTrainRoute1
            , desiredTrainRoute2
            , desiredTrainRoute3
        };
        insert desiredTrainRouteList;

        // 希望駅
        DesiredStation__c desiredStation1 = new DesiredStation__c(
            Station__c = station1.Id
            , DesiredTrainRoute__c = desiredTrainRoute1.Id
        );
        DesiredStation__c desiredStation2 = new DesiredStation__c(
            Station__c = station2.Id
            , DesiredTrainRoute__c = desiredTrainRoute2.Id
        );
        DesiredStation__c desiredStation3 = new DesiredStation__c(
            Station__c = station3.Id
            , DesiredTrainRoute__c = desiredTrainRoute3.Id
        );
        List<DesiredStation__c> desiredStationList = new List<DesiredStation__c>{
            desiredStation1
            , desiredStation2
            , desiredStation3
        };
        insert desiredStationList;

        // 希望学区（エリア）
        DesiredSchoolArea__c desiredSchoolArea1 = new DesiredSchoolArea__c();
        DesiredSchoolArea__c desiredSchoolArea2 = new DesiredSchoolArea__c();
        DesiredSchoolArea__c desiredSchoolArea3 = new DesiredSchoolArea__c();
        List<DesiredSchoolArea__c> desiredSchoolAreaList = new List<DesiredSchoolArea__c>{
            desiredSchoolArea1
            , desiredSchoolArea2
            , desiredSchoolArea3
        };
        insert desiredSchoolAreaList;

        // 学校
        School__c school1 = new School__c(
            Name = 'テスト学校1'
        );
        School__c school2 = new School__c(
            Name = 'テスト学校2'
        );
        School__c school3 = new School__c(
            Name = 'テスト学校3'
        );
        List<School__c> schoolList = new List<School__c>{
            school1
            , school2
            , school3
        };
        insert schoolList;

        // 希望学校
        DesiredSchool__c desiredSchool1 = new DesiredSchool__c(
            School__c = school1.Id
            , DesiredSchoolArea__c = desiredSchoolArea1.Id
        );
        DesiredSchool__c desiredSchool2 = new DesiredSchool__c(
            School__c = school2.Id
            , DesiredSchoolArea__c = desiredSchoolArea2.Id
        );
        DesiredSchool__c desiredSchool3 = new DesiredSchool__c(
            School__c = school3.Id
            , DesiredSchoolArea__c = desiredSchoolArea3.Id
        );
        List<DesiredSchool__c> desiredSchoolList = new List<DesiredSchool__c>{
            desiredSchool1
            , desiredSchool2
            , desiredSchool3
        };
        insert desiredSchoolList;

        // 建物
        Building__c building1 = new Building__c (
            Name = '完全条件一致用建物'            
        );
        Building__c building2 = new Building__c (
            Name = '空室予約物件用建物'            
        );
        List<Building__c> buildingList = new List<Building__c>{
            building1
            , building2
        };
        insert buildingList;

        // 取引先
        Account account = new Account(
            Name = '完全条件一致用取引先'
            , OccupancyAreaLowerLimit__c = '20'
            , OccupancyAreaUpperLimit__c = '20'
            , IsOneRoom__c = true
            , Is1K__c = true
            , Is1DK__c = true
            , Is1LDK1SLDK__c = true
            , Is2K2DK__c = true
            , Is2LDK2SLDK__c = true
            , Is3K3DK__c = true
            , Is3LDK3SLDK__c = true
            , Is4K4DK4LDKFrom__c = true
            , IsNorth__c = true
            , IsNorthEast__c = true
            , IsEast__c = true
            , IsSouthEast__c = true
            , IsSouth__c = true
            , IsSouthWest__c = true
            , IsWest__c = true
            , IsNorthWest__c = true
            , rentFeeFrom__c = 10000
            , RentFeeTo__c = 10000
            , IsNonDeposit__c = true
            , IsNonKeyMoney__c = true
            , IsNonCleaningFee__c = true
            , IsNonRenewalFee__c = true
            , IsNonGuaranteeidCompany__c = true
            , IsMaisonette__c = true
            , IsLoft__c = true
            , IsDesigners__c = true
            , IsRenovation__c = true
            , IsCondominiumRental__c = true
            , IsAllWestern__c = true
            , IsFirstFloor__c = true
            , IsSecondFloorOver__c = true
            , IsTopFloor__c = true
            , IsCornerRoom__c = true
            , IsBalcony__c = true
            , IsRoofBalcony__c = true
            , IsPrivateGarden__c = true
            , IsParking__c = true
            , IsInSiteParking__c = true
            , IsPluralCarParking__c = true
            , IsBuiltInGarage__c = true
            , IsCarport__c = true
            , IsBicycleParking__c = true
            , IsBikeStorage__c = true
            , IsSmallBike__c = true
            , IsMediumBike__c = true
            , IsLargeBike__c = true
            , IsElevator__c = true
            , IsDeliveryBox__c = true
            , IsCounterKitchen__c = true
            , IsSystemKitchen__c = true
            , IsGasStove__c = true
            , IsElectricStove__c = true
            , IsInductionHeating__c = true
            , IsTwoGasStove__c = true
            , IsMoreGasStove__c = true
            , IsSepalateBathAndRestroom__c = true
            , IsAditionalBoiling__c = true
            , IsDehumidifierForBathroom__c = true
            , IsWashlet__c = true
            , IsShowerWashBasin__c = true
            , IsRegalLavatory__c = true
            , IsInnerLandry__c = true
            , IsTownGas__c = true
            , IsPropaneGas__c = true
            , IsAllElectric__c = true
            , IsAirConditioner__c = true
            , IsFloorHeating__c = true
            , IsShoesBox__c = true
            , IsShoeCloak__c = true
            , IsWalkInCloset__c = true
            , IsTrunkRoom__c = true
            , IsBSAntenna__c = true
            , IsCSAntenna__c = true
            , IsCATV__c = true
            , IsInternetFree__c = true
            , IsMonitorIntercom__c = true
            , IsAutoLock__c = true
            , IsFurniture__c = true
            , IsHomeAppliance__c = true
            , IsNoGuarantor__c = true
            , IsMusicalInstruments__c = true
            , IsForeigner__c = true
            , IsWelfareAvailable__c = true
            , IsOfficeAvailable__c = true
            , IsPet__c = true
            , IsSmallPet__c = true
            , IsMiddlePet__c = true
            , IsLargePet__c = true
            , IsCat__c = true
            , IsOtherPet__c = true
            , IsTwoTenant__c = true
            , IsRoomShare__c = true
            , IsElderly__c = true
            , IsWoman__c = true
            , IsStudent__c = true
            , IsIppambutsu__c = true
            , IppamGyobutsu__c = CommonConst.ACCOUNT_IPPANGYOBUTSU_IPPAN
        );
        insert account;

        // 対応
        Correspond__c correspond = new Correspond__c(
            AccountId__c = account.Id
            , Status__c = CommonConst.CORRESPOND_STATUS_PURSUITHOLD
            , ExactConditionMatch__c = 'する'
        );
        insert correspond;

        // 物件
        Property__c property1 = new Property__c(
            Name = '完全条件一致用物件'
            , LiveStatus__c = CommonConst.PROPERTY_LIVESTATUS_VACANCY
            , Building__c = building1.Id
            , RoomArea__c = 20
            , RoomCount__c = 1
            , RoomLayout__c = CommonConst.PROPERTY_ROOMLAYOUT_DK
            , BalconyDirection__c = CommonConst.PROPERTY_BALCONYDIRECTION_NORTH
            , RentFeeSearch__c = 10000
            , RentFeeSearchManagement__c = 10000
            , RentFeeSearchParking__c = 10000
            , RentFeeSearchManagementParking__c = 10000
            , SecurityDepositYenSearch__c = 0
            , SecurityDepositMonthSearch__c = 0
            , DepositYenSearch__c = 0
            , DepositMonthSearch__c = 0
            , KeyMoneyYenSearch__c = 0
            , KeyMoneyMonthSearch__c = 0
            , CleaningFeeYenSearch__c = 0
            , CleaningFeeMonthSearch__c = 0
            , RenewalFeeYenSearch__c = 0
            , RenewalFeeMonthSearch__c = 0
            , GuaranteeidCompanyType__c = CommonConst.PROPERTY_GUARANTEEIDCOMPANYTYPE_POSSIBLE
            , FormerSupplier__c = account.Id
        );
        Property__c property2 = new Property__c(
            Name = '空室予約物件用物件1'
            , LiveStatus__c = CommonConst.PROPERTY_LIVESTATUS_VACANCY
            , Building__c = building2.Id
            , RoomCount__c = 4
            , RoomLayout__c = CommonConst.PROPERTY_ROOMLAYOUT_SLDK
            , FormerSupplier__c = account.Id
        );
        Property__c property3 = new Property__c(
            Name = '空室予約物件用物件2'
            , LiveStatus__c = CommonConst.PROPERTY_LIVESTATUS_VACANCY
            , Building__c = building2.Id
            , RoomCount__c = 2
            , RoomLayout__c = CommonConst.PROPERTY_ROOMLAYOUT_SLDK
            , FormerSupplier__c = account.Id
        );
        List<Property__c> propertyList = new List<Property__c>{
            property1
            , property2
            , property3
        };
        insert propertyList;

        // 物件条件
        PropertyConditions__c propertyConditions = new PropertyConditions__c(
            IsMaisonette__c = true
            , IsLoft__c = true
            , IsDesigners__c = true
            , IsRenovation__c = true
            , IsCondominiumRental__c = true
            , IsAllWesternStyleRoom__c = true
            , IsFirstFloor__c = true
            , IsSecondFloorOver__c = true
            , IsTopFloor__c = true
            , IsCornerRoom__c = true
            , IsBalcony__c = true
            , IsRoofBalcony__c = true
            , IsPrivateGarden__c = true
            , IsParking__c = true
            , IsInSiteParking__c = true
            , IsPluralCarParking__c = true
            , IsBuiltInGarage__c = true
            , IsCarport__c = true
            , IsBicycleParking__c = true
            , IsBikeStorage__c = true
            , IsSmallBike__c = true
            , IsMediumBike__c = true
            , IsLargeBike__c = true
            , IsElevator__c = true
            , IsDeliveryBox__c = true
            , IsCounterKitchen__c = true
            , IsSystemKitchen__c = true
            , IsGasStove__c = true
            , IsElectricStove__c = true
            , IsIhStove__c = true
            , IsTwoGasStove__c = true
            , IsMoreGasStove__c = true
            , IsSeparate__c = true
            , IsReheating__c = true
            , IsBathroomDryer__c = true
            , IsWashletToiletSeat__c = true
            , IsShowerWashBasin__c = true
            , IsWashroomDscrete__c = true
            , IsIndoorWashingMachineStorage__c = true
            , IsCityGas__c = true
            , IsPropaneGas__c = true
            , IsAllElectric__c = true
            , IsAirConditioner__c = true
            , IsFloorHeating__c = true
            , IsShoesBox__c = true
            , IsShoeCloak__c = true
            , IsWalkInCloset__c = true
            , IsTrunkRoom__c = true
            , IsBSAntenna__c = true
            , IsCSAntenna__c = true
            , IsCATV__c = true
            , IsInternetFree__c = true
            , IsMonitorIntercom__c = true
            , IsAutoLock__c = true
            , IsFurniture__c = true
            , IsHomeAppliance__c = true
            , IsNoGuarantor__c = true
            , IsMusicalInstruments__c = true
            , IsForeigner__c = true
            , IsWelfareAvailable__c = true
            , IsOfficeAvailable__c = true
            , IsPet__c = true
            , IsSmallPet__c = true
            , IsMiddlePet__c = true
            , IsLargePet__c = true
            , IsCat__c = true
            , IsOtherPet__c = true
            , IsTwoTenant__c = true
            , IsRoomShare__c = true
            , IsElderly__c = true
            , IsWoman__c = true
            , IsStudent__c = true
            , Property__c = property1.Id
        );
        insert propertyConditions;

        // 空室予約物件
        String vacancyStatus1 = CommonConst.VACANCY_STATUS_NONE;
        if (property2.LiveStatus__c == CommonConst.PROPERTY_LIVESTATUS_VACANCY
            || property2.LiveStatus__c == CommonConst.PROPERTY_LIVESTATUS_VACANCY) {
            vacancyStatus1 = CommonConst.VACANCY_STATUS_EXIST;
        }
        VacancyReservationProperty__c vacancyReservationProp1 = new VacancyReservationProperty__c(
            Account__c = account.Id
            , Building__c = property2.Building__c
            , VacancyStatus__c = vacancyStatus1
            , PropertyFloorPlan__c = property2.RoomCount__c + property2.RoomLayout__c
        );
        String vacancyStatus2 = CommonConst.VACANCY_STATUS_NONE;
        if (property3.LiveStatus__c == CommonConst.PROPERTY_LIVESTATUS_VACANCY
            || property3.LiveStatus__c == CommonConst.PROPERTY_LIVESTATUS_VACANCY) {
            vacancyStatus2 = CommonConst.VACANCY_STATUS_EXIST;
        }
        VacancyReservationProperty__c vacancyReservationProp2 = new VacancyReservationProperty__c(
            Account__c = account.Id
            , Building__c = property3.Building__c
            , VacancyStatus__c = vacancyStatus2
            , PropertyFloorPlan__c = property3.RoomCount__c + property3.RoomLayout__c
        );
        List<VacancyReservationProperty__c> vacancyReservationPropList = new List<VacancyReservationProperty__c>{
            vacancyReservationProp1
            , vacancyReservationProp2
        };
        insert vacancyReservationPropList;
    }

    // ▼ 2022.03.30 CHINTAI対応時、変更
    @isTest static void InsertTest(){
        // 建物OBJに登録を行う。
        List<Building__c> buildingList = new List<Building__c>();
        Building__c addBuilding = new Building__c (
            Name = 'テスト建物'
            ,   District__c = '港区'
        );
        buildingList.add(addBuilding);
        insert buildingList;
        
        // 店舗OBJに登録を行う。
        List<Shop__c> shopList = new List<Shop__c>();
        Shop__c addShop = new Shop__c(
            PortalSitePostingDistrict__c = '港区'
            ,   Name = '物件トリガハンドラテスト店舗'
            );
            
        shopList.add(addShop); // insert用のListを作る。
        insert shopList;
        
        // 元付情報を登録（掲載サイト有）
        Account existDispSite = new Account(
            Name = 'テスト株式会社１'
            , at_home_press_ban__c = true
            , HOME_S_press_ban__c = true
            , SUUMO_press_ban__c = false
            , Chintai_press_ban__c = false
            , Our_HP_press_ban__c = false
            );
        insert existDispSite;

        // 登録するデータを用意する。
		Property__c testProperty = new Property__c(
			Name = '123456'
			,   Building__c = addBuilding.Id
			,   MaintenanceType__c = CommonConst.MAINTENANCETYPE_MANUALADD
			,   FormerSupplier__c = existDispSite.Id
			,   WebPublishing__c = CommonConst.PROPERTY_WEBPUBLISHING_EXISTS
		);
		Test.startTest();
        insert testProperty;
		Test.stopTest();
        // 確認のためIdを取得する。(物件差分)
        List<PropertyDifference__c> differenceList = [SELECT Id FROM PropertyDifference__c];
        // 確認のためIdを取得する。(物件メンテナンス履歴)
        List<PropertyMaintenanceHistory__c> maintenanceList = [SELECT Id FROM PropertyMaintenanceHistory__c];
        // 確認のためIdを取得する。(ポータルサイト掲載物件登録)
        List<PortalSitePostingProperty__c> portalList = [SELECT Id FROM PortalSitePostingProperty__c];
        // 確認のためIdを取得する。(物件)
		Property__c updateProperty = [	SELECT 	Id, MaintenanceStartDateTime__c, MaintenanceEndDateTime__c,
        MaintenanceAction__c, MaintenanceStaff__c, MaintenanceType__c, MaintenanceCommentArea__c
										FROM Property__c
										WHERE Id = :testProperty.Id];
		// 確認のためIdを取得する。(条件完全一致物件)
		List<ExactConditionMatchBatchExecution__c> exactConditionMatchBatchExecutionList = [SELECT Id FROM ExactConditionMatchBatchExecution__c];
		// 確認のためIdを取得する。(対応)
		List<Correspond__c> correspondList = [SELECT Id, Status__c FROM Correspond__c];
		// 確認のためIdを取得する。(対応明細)
		List<CorrespondDetail__c> correspondDetailList = [SELECT Id FROM CorrespondDetail__c];
		// 確認のためIdを取得する。(物件コード履歴)
		List<PropertyCodeHistory__c> propertyCodeHistoryList = [SELECT Id FROM PropertyCodeHistory__c];
        
        System.assertEquals(4, differenceList.Size());
        System.assertEquals(1, maintenanceList.Size());
        System.assertEquals(1, portalList.Size());
        System.assertEquals(null, updateProperty.MaintenanceStartDateTime__c);
        System.assertEquals(null, updateProperty.MaintenanceEndDateTime__c);
        System.assertEquals(null, updateProperty.MaintenanceAction__c);
        System.assertEquals(null, updateProperty.MaintenanceStaff__c);
        System.assertEquals(null, updateProperty.MaintenanceType__c);
        System.assertEquals(null, updateProperty.MaintenanceCommentArea__c);
        System.assertEquals(3, exactConditionMatchBatchExecutionList.Size());
        System.assertEquals(1, correspondList.Size());
        System.assertEquals(0, correspondDetailList.Size());
        System.assertEquals(4, propertyCodeHistoryList.Size());
    }
    // ▲ 2022.03.30 CHINTAI対応時、変更
    
	// ▼ 2022.03.30 CHINTAI対応追加
	@isTest static void insertChintaiNotPostedFlgTest(){
		// 建物OBJに登録を行う。
		Building__c testBuilding = new Building__c (Name = 'テスト建物', District__c = '港区');
		insert testBuilding;
		
		// 店舗OBJに登録を行う。
		Shop__c testShop = new Shop__c(PortalSitePostingDistrict__c = '港区', Name = '物件トリガハンドラテスト店舗');
		insert testShop;
		
		// 元付情報を登録（掲載サイト無）
		Account acc = new Account(
			Name = 'テスト株式会社１'
			, at_home_press_ban__c = true
			, HOME_S_press_ban__c = true
			, SUUMO_press_ban__c = false
			, Our_HP_press_ban__c = false
			, Chintai_press_ban__c = true
		);
		insert acc;

		// 登録する物件データを用意する。
		List<Property__c> propertyList = new List<Property__c>();
		Property__c testProperty = new Property__c(
			Name = '123456'
			,   Building__c = testBuilding.Id
			,   FormerSupplier__c = acc.Id
			,   WebPublishing__c = CommonConst.PROPERTY_WEBPUBLISHING_EXISTS
		);
		Test.startTest();
		insert testProperty;
		Test.stopTest();
		
		// 確認のためIdを取得する。(ポータルサイト掲載物件登録)
		List<PortalSitePostingProperty__c> portalList = [
			SELECT Id, IsChintaiNet__c, IsChintaiPanoramaPosting__c FROM PortalSitePostingProperty__c
		];
		System.assertEquals(portalList[0].IsChintaiNet__c, false);
		System.assertEquals(portalList[0].IsChintaiPanoramaPosting__c, false);
	}
	// ▲ 2022.03.30 CHINTAI対応追加

	// ▼ 2022.03.30 CHINTAI対応追加
	@isTest static void insertChintaiPostedFlgTest(){
		// 建物OBJに登録を行う。
		Building__c testBuilding = new Building__c (Name = 'テスト建物', District__c = '港区');
		insert testBuilding;
		
		// 店舗OBJに登録を行う。
		Shop__c testShop = new Shop__c(PortalSitePostingDistrict__c = '港区', Name = '物件トリガハンドラテスト店舗');
		insert testShop;
		
		// 元付情報を登録（掲載サイト無）
		Account acc = new Account(
			Name = 'テスト株式会社２'
			, at_home_press_ban__c = true
			, HOME_S_press_ban__c = true
			, SUUMO_press_ban__c = false
			, Our_HP_press_ban__c = false
			, Chintai_press_ban__c = false
		);
		insert acc;
		// 登録する物件データを用意する。
		List<Property__c> propertyList = new List<Property__c>();
		Property__c testProperty = new Property__c(
			Name = '123456'
			,   Building__c = testBuilding.Id
			,   FormerSupplier__c = acc.Id
			,   WebPublishing__c = CommonConst.PROPERTY_WEBPUBLISHING_EXISTS
		);
		Test.startTest();
		insert testProperty;
		Test.stopTest();
		
		// 確認のためIdを取得する。(ポータルサイト掲載物件登録)
		List<PortalSitePostingProperty__c> portalList = [
			SELECT Id, IsChintaiNet__c, IsChintaiPanoramaPosting__c FROM PortalSitePostingProperty__c
		];
		System.assertEquals(portalList[0].IsChintaiNet__c, true);
		System.assertEquals(portalList[0].IsChintaiPanoramaPosting__c, false);
	}
	// ▲ 2022.03.30 CHINTAI対応追加
    
    // 更新テスト
    @isTest static void UpdateTest(){
        
        // 建物OBJに登録を行う。
        List<Building__c> buildingList = new List<Building__c>();
        Building__c addBuilding = new Building__c (
            Name = 'テスト建物'
            ,   District__c = '港区'
            
        );
        buildingList.add(addBuilding);
        insert buildingList;
        
        // 店舗OBJに登録を行う。
        List<Shop__c> shopList = new List<Shop__c>();
        Shop__c addShop = new Shop__c(
            PortalSitePostingDistrict__c = '港区'
            ,   Name = '物件トリガハンドラテスト店舗'
        );
        shopList.add(addShop); // insert用のListを作る。
        insert shopList;
        
        // 登録するデータを用意する。
        List<Property__c> propertyList = new List<Property__c>();// Propery__cのListを用意する。
        
        for(Integer i = 0; i < 10; i++){ // 10回す。
            Property__c addProperty = new Property__c(
                Name = '123456'
                ,   Building__c = addBuilding.Id
                ,   LivedType__c = CommonConst.PROPERTY_LIVEDTYPE_NOTLIVED
                ,   MaintenanceType__c = CommonConst.MAINTENANCETYPE_MANUALADD
            );
            propertyList.add(addProperty);    // 物件リストへ追加。
        }
        
        // insert!!!
        insert propertyList;
        
        //更新
        List<Property__c> propertyListUpd = new List<Property__c>();// 物件オブジェクトの項目を再設定する。
        for (Property__c newList : propertyList){
            Property__c addPropertyUpd = new Property__c(
                Id = newList.Id
                ,   MaintenanceType__c = CommonConst.MAINTENANCETYPE_MANUALCHG // メンテナンス区分を再設定
                ,   LivedType__c = CommonConst.PROPERTY_LIVEDTYPE_LIVED
            );
            propertyListUpd.add(addPropertyUpd);
        }
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
        update propertyListUpd; // ハンドラーの更新処理が呼び出される。
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
        // 確認のためIdを取得する。(物件差分)
        List<PropertyDifference__c> differenceList = [
            SELECT Id FROM PropertyDifference__c
        ];
        
        // 確認のためIdを取得する。(物件メンテナンス履歴)
        List<PropertyMaintenanceHistory__c> maintenanceList = [
            SELECT Id FROM PropertyMaintenanceHistory__c
        ];
        // 確認のためIdを取得する。(ポータルサイト掲載物件)
        List<PortalSitePostingProperty__c> portalList = [
            SELECT Id FROM PortalSitePostingProperty__c
        ];
        // assertする。
        //System.assertEquals(20, differenceList.Size());
        System.assertEquals(20, maintenanceList.Size());
        //System.assertEquals(0, portalList.Size());
        
    }
    
    //  削除テスト
    @isTest static void DeleteTest(){
        // 建物OBJに登録を行う。
        List<Building__c> buildingList = new List<Building__c>();
        Building__c addBuilding = new Building__c (
            Name = 'テスト建物'
            ,   District__c = '港区'
        );
        buildingList.add(addBuilding);
        insert buildingList;
        
        // 店舗OBJに登録を行う。
        List<Shop__c> shopList = new List<Shop__c>();
        Shop__c addShop = new Shop__c(
            PortalSitePostingDistrict__c = '港区'
            ,   Name = '物件トリガハンドラテスト店舗'
        );
        
        shopList.add(addShop); // insert用のListを作る。
        insert shopList;

        // 登録するデータを用意する。
        List<Property__c> propertyList = new List<Property__c>();// Propery__cのListを用意する。

        for(Integer i = 0; i < 10; i++){ // 10回す。
            Property__c addProperty = new Property__c(
                Name = '123456'
                ,   Building__c = addBuilding.Id
                ,   LivedType__c = CommonConst.PROPERTY_LIVEDTYPE_NOTLIVED
                ,   MaintenanceType__c = CommonConst.MAINTENANCETYPE_MANUALADD
            );
            propertyList.add(addProperty);    // 物件リストへ追加。
        }
        
        // insert!!!
        insert propertyList;

		Test.startTest(); // 2022.03.30 CHINTAI対応追加        
        // Deleteする。
        delete propertyList;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
        // 確認のためIdを取得する。(物件差分)
        List<PropertyDifference__c> differenceList = [
            SELECT Id FROM PropertyDifference__c
        ];
        
        // 確認のためIdを取得する。(ポータルサイト掲載物件登録)
        List<PortalSitePostingProperty__c> portalList = [
            SELECT Id FROM PortalSitePostingProperty__c
        ];

        // assertする。
        System.assertEquals(23, differenceList.Size());
        System.assertEquals(0, portalList.Size());
        
    }
    
    // 完全一致条件実施チェック（保証会社不要）
    @isTest static void isExecuteExactMatchGuaranteeidCompanyType(){
        
        // 旧データ
        Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];

        // 保証会社不要
        Property__c chgProperty = new Property__c (
            Id = oldProperty.Id
            , BalconyDirection__c = CommonConst.PROPERTY_BALCONYDIRECTION_NORTHWEST
            , GuaranteeidCompanyType__c = CommonConst.PROPERTY_GUARANTEEIDCOMPANYTYPE_UNSET
        );
        update chgProperty;

        // 実施チェック
        chgProperty = new Property__c (
            Id = oldProperty.Id
            , GuaranteeidCompanyType__c = CommonConst.PROPERTY_GUARANTEEIDCOMPANYTYPE_POSSIBLE
        );
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
        update chgProperty;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
    }

    // 完全一致条件実施チェック（占有面積）
    @isTest static void isExecuteExactMatchRoomArea(){
        
        // 旧データ
        Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];

        // 占有面積（上限）
        Property__c chgProperty = new Property__c (
            Id = oldProperty.Id
            ,   RoomArea__c = 21
        );
        update chgProperty;

        // 占有面積（下限）
        chgProperty = new Property__c (
                Id = oldProperty.Id
                ,   RoomArea__c = 19
        );
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
		update chgProperty;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
    }

	// ▼ 2022.03.30 CHINTAI対応追加 完全一致条件実施チェック（更新料なし）
	@isTest static void checkRenewalFee() {
		// 旧データ
		Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];

		Property__c chgProperty = new Property__c (
			Id = oldProperty.Id
			,   RenewalFeeYenSearch__c = 1
			,   RenewalFeeMonthSearch__c = 1
		);
		update chgProperty;

		chgProperty = new Property__c (
			Id = oldProperty.Id
			,   RenewalFeeYenSearch__c = 0
		);
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
		update chgProperty;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
	}
	// ▲ 2022.03.30 CHINTAI対応追加

	// ▼ 2022.03.30 CHINTAI対応追加 完全一致条件実施チェック（定額修繕費なし）
	@isTest static void checkFixedAmountRepairCosts() {
		// 旧データ
		Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];

		Property__c chgProperty = new Property__c (
			Id = oldProperty.Id
			,   CleaningFeeYenSearch__c = 1
			,   CleaningFeeMonthSearch__c = 1
		);
		update chgProperty;

		chgProperty = new Property__c (
			Id = oldProperty.Id
			,   CleaningFeeYenSearch__c = 0
		);
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
		update chgProperty;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
	}
	// ▲ 2022.03.30 CHINTAI対応追加

	// ▼ 2022.03.30 CHINTAI対応追加 完全一致条件実施チェック（礼金なし）
	@isTest static void checkKeyMoney() {
		// 旧データ
		Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];

		Property__c chgProperty = new Property__c (
			Id = oldProperty.Id
			,   KeyMoneyYenSearch__c = 1
			,   KeyMoneyMonthSearch__c = 1
		);
		update chgProperty;

		chgProperty = new Property__c (
			Id = oldProperty.Id
			,   KeyMoneyYenSearch__c = 0
		);
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
		update chgProperty;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
	}
	// ▲ 2022.03.30 CHINTAI対応追加

	// ▼ 2022.03.30 CHINTAI対応追加 完全一致条件実施チェック（敷金/保証金なし）
	@isTest static void checkSecurityDeposit() {
		// 旧データ
		Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];

		Property__c chgProperty = new Property__c (
			Id = oldProperty.Id
			,   SecurityDepositYenSearch__c = 1
			,   SecurityDepositMonthSearch__c = 1
			,   DepositYenSearch__c = 1
			,   DepositMonthSearch__c = 1
		);
		update chgProperty;

		chgProperty = new Property__c (
				Id = oldProperty.Id
				,   SecurityDepositYenSearch__c = 0
				,   SecurityDepositMonthSearch__c = 0
				,   DepositYenSearch__c = 0
		);
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
		update chgProperty;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
	}
	// ▲ 2022.03.30 CHINTAI対応追加

	// 2022.03.30 CHINTAI対応時、テストメソッド（isExecuteExactMatchMoney）の中身を分割し、削除
	// 分割先メソッド→checkRenewalFee(),checkFixedAmountRepairCosts(),checkKeyMoney(),checkSecurityDeposit()

	// ▼ 2022.03.30 CHINTAI対応追加 完全一致条件実施チェック（間取り未選択）
	@isTest static void checkRoomNotSelected() {
		// 旧データ
		Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
		Account oldAccount = [SELECT Id FROM Account WHERE Name = '完全条件一致用取引先'];

		// 未選択
		Account updAccount = new Account(
			Id = oldAccount.Id
			, IsOneRoom__c = false
			, Is1K__c = false
			, Is1DK__c = false
			, Is1LDK1SLDK__c = false
			, Is2K2DK__c = false
			, Is2LDK2SLDK__c = false
			, Is3K3DK__c = false
			, Is3LDK3SLDK__c = false
			, Is4K4DK4LDKFrom__c = false
		);
		update updAccount;

		Property__c chgProperty = new Property__c (
			Id = oldProperty.Id
			, RoomCount__c = 5
		);
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
		update chgProperty;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
	}
	// ▲ 2022.03.30 CHINTAI対応追加

	// ▼ 2022.03.30 CHINTAI対応追加 完全一致条件実施チェック（ワンルーム）
	@isTest static void checkOneRoom() {
		// 旧データ
		Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
		Account oldAccount = [SELECT Id FROM Account WHERE Name = '完全条件一致用取引先'];

		// ワンルーム
		Account updAccount = new Account(
			Id = oldAccount.Id
			, IsOneRoom__c = true
			, Is1K__c = false
			, Is1DK__c = false
			, Is1LDK1SLDK__c = false
			, Is2K2DK__c = false
			, Is2LDK2SLDK__c = false
			, Is3K3DK__c = false
			, Is3LDK3SLDK__c = false
			, Is4K4DK4LDKFrom__c = false
		);
		update updAccount;

		Property__c chgProperty = new Property__c (
			Id = oldProperty.Id
			, RoomCount__c = 1
			, RoomLayout__c = CommonConst.PROPERTY_ROOMLAYOUT_R
		);
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
		update chgProperty;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
	}
	// ▲ 2022.03.30 CHINTAI対応追加

	// ▼ 2022.03.30 CHINTAI対応追加 完全一致条件実施チェック（1K）
	@isTest static void check1K() {
		// 旧データ
		Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
		Account oldAccount = [SELECT Id FROM Account WHERE Name = '完全条件一致用取引先'];

		// 1K
		Account updAccount = new Account(
			Id = oldAccount.Id
			, IsOneRoom__c = false
			, Is1K__c = true
			, Is1DK__c = false
			, Is1LDK1SLDK__c = false
			, Is2K2DK__c = false
			, Is2LDK2SLDK__c = false
			, Is3K3DK__c = false
			, Is3LDK3SLDK__c = false
			, Is4K4DK4LDKFrom__c = false
		);
		update updAccount;

		Property__c chgProperty = new Property__c (
			Id = oldProperty.Id
			, RoomCount__c = 1
			, RoomLayout__c = CommonConst.PROPERTY_ROOMLAYOUT_K
		);
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
		update chgProperty;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
	}
	// ▲ 2022.03.30 CHINTAI対応追加

	// ▼ 2022.03.30 CHINTAI対応追加 完全一致条件実施チェック（1DK）
	@isTest static void check1DK() {
		// 旧データ
		Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
		Account oldAccount = [SELECT Id FROM Account WHERE Name = '完全条件一致用取引先'];

		// 1DK
		Account updAccount = new Account(
			Id = oldAccount.Id
			, IsOneRoom__c = false
			, Is1K__c = false
			, Is1DK__c = true
			, Is1LDK1SLDK__c = false
			, Is2K2DK__c = false
			, Is2LDK2SLDK__c = false
			, Is3K3DK__c = false
			, Is3LDK3SLDK__c = false
			, Is4K4DK4LDKFrom__c = false
		);
		update updAccount;

		Property__c chgProperty = new Property__c (
            Id = oldProperty.Id
            , RoomCount__c = 1
            , RoomLayout__c = CommonConst.PROPERTY_ROOMLAYOUT_DK
        );
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
		update chgProperty;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
	}
	// ▲ 2022.03.30 CHINTAI対応追加

	// ▼ 2022.03.30 CHINTAI対応追加 完全一致条件実施チェック（1LDK/SLDK）
	@isTest static void check1LDK_SLDK() {
		// 旧データ
		Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
		Account oldAccount = [SELECT Id FROM Account WHERE Name = '完全条件一致用取引先'];

		// 1LDK/SLDK
		Account updAccount = new Account(
			Id = oldAccount.Id
			, IsOneRoom__c = false
			, Is1K__c = false
			, Is1DK__c = false
			, Is1LDK1SLDK__c = true
			, Is2K2DK__c = false
			, Is2LDK2SLDK__c = false
			, Is3K3DK__c = false
			, Is3LDK3SLDK__c = false
			, Is4K4DK4LDKFrom__c = false
		);
		update updAccount;

		Property__c chgProperty = new Property__c (
            Id = oldProperty.Id
            , RoomCount__c = 1
            , RoomLayout__c = CommonConst.PROPERTY_ROOMLAYOUT_SLDK
        );
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
		update chgProperty;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
	}
	// ▲ 2022.03.30 CHINTAI対応追加

	// ▼ 2022.03.30 CHINTAI対応追加 完全一致条件実施チェック（2K/DK）
	@isTest static void check2K_DK() {
		// 旧データ
		Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
		Account oldAccount = [SELECT Id FROM Account WHERE Name = '完全条件一致用取引先'];

		// 2K/DK
		Account updAccount = new Account(
			Id = oldAccount.Id
			, IsOneRoom__c = false
			, Is1K__c = false
			, Is1DK__c = false
			, Is1LDK1SLDK__c = false
			, Is2K2DK__c = true
			, Is2LDK2SLDK__c = false
			, Is3K3DK__c = false
			, Is3LDK3SLDK__c = false
			, Is4K4DK4LDKFrom__c = false
		);
		update updAccount;

		Property__c chgProperty = new Property__c (
            Id = oldProperty.Id
            , RoomCount__c = 2
            , RoomLayout__c = CommonConst.PROPERTY_ROOMLAYOUT_SLK
        );
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
		update chgProperty;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
	}
	// ▲ 2022.03.30 CHINTAI対応追加

	// ▼ 2022.03.30 CHINTAI対応追加 完全一致条件実施チェック（2LDK/SLDK）
	@isTest static void check2LDK_SLDK() {
		// 旧データ
		Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
		Account oldAccount = [SELECT Id FROM Account WHERE Name = '完全条件一致用取引先'];

		// 2LDK/SLDK
		Account updAccount = new Account(
			Id = oldAccount.Id
			, IsOneRoom__c = false
			, Is1K__c = false
			, Is1DK__c = false
			, Is1LDK1SLDK__c = false
			, Is2K2DK__c = false
			, Is2LDK2SLDK__c = true
			, Is3K3DK__c = false
			, Is3LDK3SLDK__c = false
			, Is4K4DK4LDKFrom__c = false
		);
		update updAccount;

		Property__c chgProperty = new Property__c (
            Id = oldProperty.Id
            , RoomCount__c = 2
            , RoomLayout__c = CommonConst.PROPERTY_ROOMLAYOUT_SLDK
        );
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
		update chgProperty;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
	}
	// ▲ 2022.03.30 CHINTAI対応追加
        
    // 2022.03.30 CHINTAI対応にて、テストメソッド（isExecuteExactMatchRoomLayout1）の中身を分割し、削除
	// 分割先メソッド→checkRoomNotSelected(),checkOneRoom(),check1K(),check1DK(),check1LDK_SLDK,check2K_DK(),check2LDK_SLDK

	// ▼ 2022.03.30 CHINTAI対応追加 完全一致条件実施チェック（3K/DK）
	@isTest static void check3K_DK() {
		// 旧データ
		Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
		Account oldAccount = [SELECT Id FROM Account WHERE Name = '完全条件一致用取引先'];

		// 3K/DK
		Account updAccount = new Account(
			Id = oldAccount.Id
			, IsOneRoom__c = false
			, Is1K__c = false
			, Is1DK__c = false
			, Is1LDK1SLDK__c = false
			, Is2K2DK__c = false
			, Is2LDK2SLDK__c = false
			, Is3K3DK__c = true
			, Is3LDK3SLDK__c = false
			, Is4K4DK4LDKFrom__c = false
		);
		update updAccount;

		Property__c chgProperty = new Property__c (
            Id = oldProperty.Id
            , RoomCount__c = 3
            , RoomLayout__c = CommonConst.PROPERTY_ROOMLAYOUT_K
        );
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
		update chgProperty;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
	}
	// ▲ 2022.03.30 CHINTAI対応追加

	// ▼ 2022.03.30 CHINTAI対応追加 完全一致条件実施チェック（3LDK/SLDK）
	@isTest static void check3LDK_SLDK() {
		// 旧データ
		Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
		Account oldAccount = [SELECT Id FROM Account WHERE Name = '完全条件一致用取引先'];

		// 3LDK/SLDK
		Account updAccount = new Account(
			Id = oldAccount.Id
			, IsOneRoom__c = false
			, Is1K__c = false
			, Is1DK__c = false
			, Is1LDK1SLDK__c = false
			, Is2K2DK__c = false
			, Is2LDK2SLDK__c = false
			, Is3K3DK__c = false
			, Is3LDK3SLDK__c = true
			, Is4K4DK4LDKFrom__c = false
		);
		update updAccount;

		Property__c chgProperty = new Property__c (
            Id = oldProperty.Id
            , RoomCount__c = 3
            , RoomLayout__c = CommonConst.PROPERTY_ROOMLAYOUT_LDK
        );
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
		update chgProperty;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
	}
	// ▲ 2022.03.30 CHINTAI対応追加

	// ▼ 2022.03.30 CHINTAI対応追加 完全一致条件実施チェック（4K/DK/LDK）
	@isTest static void check4K_DK_LDK() {
		// 旧データ
		Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
		Account oldAccount = [SELECT Id FROM Account WHERE Name = '完全条件一致用取引先'];

		// 3LDK/SLDK
		Account updAccount = new Account(
			Id = oldAccount.Id
			, IsOneRoom__c = false
			, Is1K__c = false
			, Is1DK__c = false
			, Is1LDK1SLDK__c = false
			, Is2K2DK__c = false
			, Is2LDK2SLDK__c = false
			, Is3K3DK__c = false
			, Is3LDK3SLDK__c = false
			, Is4K4DK4LDKFrom__c = true
		);
		update updAccount;

		Property__c chgProperty = new Property__c (
            Id = oldProperty.Id
            , RoomCount__c = 4
            , RoomLayout__c = CommonConst.PROPERTY_ROOMLAYOUT_LDK
        );
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
		update chgProperty;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
	}
	// ▲ 2022.03.30 CHINTAI対応追加

	// ▼ 2022.03.30 CHINTAI対応追加 完全一致条件実施チェック（不一致）
	@isTest static void checkDisagreement() {
		// 旧データ
		Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
		Account oldAccount = [SELECT Id FROM Account WHERE Name = '完全条件一致用取引先'];

		// 不一致
		Account updAccount = new Account(
			Id = oldAccount.Id
			, IsOneRoom__c = false
			, Is1K__c = false
			, Is1DK__c = false
			, Is1LDK1SLDK__c = false
			, Is2K2DK__c = false
			, Is2LDK2SLDK__c = false
			, Is3K3DK__c = false
			, Is3LDK3SLDK__c = false
			, Is4K4DK4LDKFrom__c = true
		);
		update updAccount;

		Property__c chgProperty = new Property__c (
            Id = oldProperty.Id
            , RoomCount__c = 1
            , RoomLayout__c = null
        );
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
		update chgProperty;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
	}
	// ▲ 2022.03.30 CHINTAI対応追加
    
	// 2022.03.30 CHINTAI対応にて、テストメソッド（isExecuteExactMatchRoomLayout2）の中身を分割し、削除
	// 分割先メソッド→check3K_DK(),check3LDK_SLDK(),check4K_DK_LDK(),checkDisagreement()

	// ▼ 2022.03.30 CHINTAI対応追加 完全一致条件実施チェック（方角:北）
    @isTest static void checkNorth(){
		// 旧データ
		Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
		Account oldAccount = [SELECT Id FROM Account WHERE Name = '完全条件一致用取引先'];

		Account updAccount = new Account(
			Id = oldAccount.Id
			, IsNorth__c = true
			, IsNorthEast__c = false
			, IsEast__c = false
			, IsSouthEast__c = false
			, IsSouth__c = false
			, IsSouthWest__c = false
			, IsWest__c = false
			, IsNorthWest__c = false
		);
		update updAccount;

		Property__c chgProperty = new Property__c (
			Id = oldProperty.Id
			, BalconyDirection__c = CommonConst.PROPERTY_BALCONYDIRECTION_NORTH
		);
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
		update chgProperty;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
	}
	// ▲ 2022.03.30 CHINTAI対応追加

	// ▼ 2022.03.30 CHINTAI対応追加 完全一致条件実施チェック（方角:北東）
    @isTest static void checkNorthEast(){
		// 旧データ
		Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
		Account oldAccount = [SELECT Id FROM Account WHERE Name = '完全条件一致用取引先'];

		Account updAccount = new Account(
			Id = oldAccount.Id
			, IsNorth__c = false
			, IsNorthEast__c = true
			, IsEast__c = false
			, IsSouthEast__c = false
			, IsSouth__c = false
			, IsSouthWest__c = false
			, IsWest__c = false
			, IsNorthWest__c = false
		);
		update updAccount;

		Property__c chgProperty = new Property__c (
			Id = oldProperty.Id
			, BalconyDirection__c = CommonConst.PROPERTY_BALCONYDIRECTION_NORTHEAST
		);
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
		update chgProperty;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
	}
	// ▲ 2022.03.30 CHINTAI対応追加

	// ▼ 2022.03.30 CHINTAI対応追加 完全一致条件実施チェック（方角:東）
	@isTest static void checkEast(){
		// 旧データ
		Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
		Account oldAccount = [SELECT Id FROM Account WHERE Name = '完全条件一致用取引先'];

		Account updAccount = new Account(
			Id = oldAccount.Id
			, IsNorth__c = false
			, IsNorthEast__c = false
			, IsEast__c = true
			, IsSouthEast__c = false
			, IsSouth__c = false
			, IsSouthWest__c = false
			, IsWest__c = false
			, IsNorthWest__c = false
		);
		update updAccount;

		Property__c chgProperty = new Property__c (
			Id = oldProperty.Id
			, BalconyDirection__c = CommonConst.PROPERTY_BALCONYDIRECTION_EAST
		);
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
		update chgProperty;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
	}
	// ▲ 2022.03.30 CHINTAI対応追加

	// ▼ 2022.03.30 CHINTAI対応追加 完全一致条件実施チェック（方角:南東）
	@isTest static void checkSouthEast(){
		// 旧データ
		Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
		Account oldAccount = [SELECT Id FROM Account WHERE Name = '完全条件一致用取引先'];

		Account updAccount = new Account(
			Id = oldAccount.Id
			, IsNorth__c = false
			, IsNorthEast__c = false
			, IsEast__c = false
			, IsSouthEast__c = true
			, IsSouth__c = false
			, IsSouthWest__c = false
			, IsWest__c = false
			, IsNorthWest__c = false
		);
		update updAccount;

		Property__c chgProperty = new Property__c (
			Id = oldProperty.Id
			, BalconyDirection__c = CommonConst.PROPERTY_BALCONYDIRECTION_SOUTHEAST
		);
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
		update chgProperty;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
	}
	// ▲ 2022.03.30 CHINTAI対応追加

	// ▼ 2022.03.30 CHINTAI対応追加 完全一致条件実施チェック（方角:南）
	@isTest static void checkSouth(){
		// 旧データ
		Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
		Account oldAccount = [SELECT Id FROM Account WHERE Name = '完全条件一致用取引先'];

		Account updAccount = new Account(
			Id = oldAccount.Id
			, IsNorth__c = false
			, IsNorthEast__c = false
			, IsEast__c = false
			, IsSouthEast__c = false
			, IsSouth__c = true
			, IsSouthWest__c = false
			, IsWest__c = false
			, IsNorthWest__c = false
		);
		update updAccount;

		Property__c chgProperty = new Property__c (
			Id = oldProperty.Id
			, BalconyDirection__c = CommonConst.PROPERTY_BALCONYDIRECTION_SOUTH
		);
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
		update chgProperty;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
	}
	// ▲ 2022.03.30 CHINTAI対応追加

	// ▼ 2022.03.30 CHINTAI対応追加 完全一致条件実施チェック（方角:南西）
	@isTest static void checkSouthWest(){
		// 旧データ
		Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
		Account oldAccount = [SELECT Id FROM Account WHERE Name = '完全条件一致用取引先'];

		Account updAccount = new Account(
			Id = oldAccount.Id
			, IsNorth__c = false
			, IsNorthEast__c = false
			, IsEast__c = false
			, IsSouthEast__c = false
			, IsSouth__c = false
			, IsSouthWest__c = true
			, IsWest__c = false
			, IsNorthWest__c = false
		);
		update updAccount;

		Property__c chgProperty = new Property__c (
			Id = oldProperty.Id
			, BalconyDirection__c = CommonConst.PROPERTY_BALCONYDIRECTION_SOUTHWEST
		);
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
		update chgProperty;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
	}
	// ▲ 2022.03.30 CHINTAI対応追加

	// ▼ 2022.03.30 CHINTAI対応追加 完全一致条件実施チェック（方角:西）
	@isTest static void checkWest(){
		// 旧データ
		Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
		Account oldAccount = [SELECT Id FROM Account WHERE Name = '完全条件一致用取引先'];

		Account updAccount = new Account(
			Id = oldAccount.Id
			, IsNorth__c = false
			, IsNorthEast__c = false
			, IsEast__c = false
			, IsSouthEast__c = false
			, IsSouth__c = false
			, IsSouthWest__c = false
			, IsWest__c = true
			, IsNorthWest__c = false
		);
		update updAccount;

		Property__c chgProperty = new Property__c (
			Id = oldProperty.Id
			, BalconyDirection__c = CommonConst.PROPERTY_BALCONYDIRECTION_WEST
		);
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
		update chgProperty;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
	}
	// ▲ 2022.03.30 CHINTAI対応追加

	// ▼ 2022.03.30 CHINTAI対応追加 完全一致条件実施チェック（方角:北西）
	@isTest static void checkNorthWest(){
		// 旧データ
		Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
		Account oldAccount = [SELECT Id FROM Account WHERE Name = '完全条件一致用取引先'];

		Account updAccount = new Account(
			Id = oldAccount.Id
			, IsNorth__c = false
			, IsNorthEast__c = false
			, IsEast__c = false
			, IsSouthEast__c = false
			, IsSouth__c = false
			, IsSouthWest__c = false
			, IsWest__c = false
			, IsNorthWest__c = true
		);
		update updAccount;

		Property__c chgProperty = new Property__c (
			Id = oldProperty.Id
			, BalconyDirection__c = CommonConst.PROPERTY_BALCONYDIRECTION_NORTHWEST
		);
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
		update chgProperty;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
	}
	// ▲ 2022.03.30 CHINTAI対応追加

	// 2022.03.30 CHINTAI対応にて、テストメソッド（isExecuteExactMatchDirection）の内容を分割し、削除
    // 分割先メソッド→checkNorth(),checkNorthEast(),checkEast(),checkSouthEast()

	// 2022.03.30 CHINTAI対応にて、テストメソッド（isExecuteExactMatchDirection2）の内容を分割し、削除
	// 分割先メソッド→checkSouth(),checkSouthWest(),checkWest(),checkNorthWest()

	// ▼ 2022.03.30 CHINTAI対応追加 完全一致条件実施チェック（賃料）
    @isTest static void checkRentFee(){
		// 旧データ
		Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
		Account oldAccount = [SELECT Id FROM Account WHERE Name = '完全条件一致用取引先'];

		Account updAccount = new Account(
			Id = oldAccount.Id
			, isIncludeManagementFee__c = false
			, isIncludeParkingFee__c = false
		);
		update updAccount;

		Property__c chgProperty = new Property__c (
			Id = oldProperty.Id
			, RentFeeSearch__c = 5000
		);
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
		update chgProperty;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
	}
	// ▲ 2022.03.30 CHINTAI対応追加

	// ▼ 2022.03.30 CHINTAI対応追加 完全一致条件実施チェック（賃料 + 管理費）
    @isTest static void checkRentManagement(){
		// 旧データ
		Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
		Account oldAccount = [SELECT Id FROM Account WHERE Name = '完全条件一致用取引先'];

		Account updAccount = new Account(
			Id = oldAccount.Id
			, isIncludeManagementFee__c = true
			, isIncludeParkingFee__c = false
		);
		update updAccount;

		Property__c chgProperty = new Property__c (
			Id = oldProperty.Id
			, RentFeeSearchManagement__c = 5000
		);
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
		update chgProperty;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
	}
	// ▲ 2022.03.30 CHINTAI対応追加

	// ▼ 2022.03.30 CHINTAI対応追加 完全一致条件実施チェック（賃料 + 駐車場）
	@isTest static void checkRentParking(){
		// 旧データ
		Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
		Account oldAccount = [SELECT Id FROM Account WHERE Name = '完全条件一致用取引先'];

		Account updAccount = new Account(
			Id = oldAccount.Id
			, isIncludeManagementFee__c = false
			, isIncludeParkingFee__c = true
		);
		update updAccount;

		Property__c chgProperty = new Property__c (
			Id = oldProperty.Id
			, RentFeeSearchParking__c = 5000
		);
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
		update chgProperty;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
	}
	// ▲ 2022.03.30 CHINTAI対応追加

	// ▼ 2022.03.30 CHINTAI対応追加 完全一致条件実施チェック（賃料 + 管理費 + 駐車場）
	@isTest static void checkRentManagementParking(){
		// 旧データ
		Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
		Account oldAccount = [SELECT Id FROM Account WHERE Name = '完全条件一致用取引先'];

		Account updAccount = new Account(
			Id = oldAccount.Id
			, rentFeeFrom__c = null
			, isIncludeManagementFee__c = true
			, isIncludeParkingFee__c = true
		);
		update updAccount;

		Property__c chgProperty = new Property__c (
			Id = oldProperty.Id
			, RentFeeSearchManagementParking__c = 15000
		);
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
		update chgProperty;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
	}
	// ▲ 2022.03.30 CHINTAI対応追加

	// 2022.03.30 CHINTAI対応にて、テストメソッド（isExecuteExactMatchDesiredRent）の内容を分割し、削除
    // 分割先メソッド→checkRentFee(),checkRentManagement(),checkRentParking(),checkRentManagementParking()

	// ▼ 2022.03.30 CHINTAI対応追加 完全一致条件実施チェック（現況_退去予定）
	@isTest static void checkLiveStatus_SCHEDULEDTOLEAVE(){

		// 旧データ
		Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
		
		// 現況1
		Property__c chgProperty = new Property__c (
			Id = oldProperty.Id
			, LiveStatus__c = CommonConst.PROPERTY_LIVESTATUS_SCHEDULEDTOLEAVE
		);
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
		update chgProperty;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
	}
	// ▲ 2022.03.30 CHINTAI対応追加

	// ▼ 2022.03.30 CHINTAI対応追加 完全一致条件実施チェック（現況_居住中）
	@isTest static void checkLiveStatus_RESIDENT(){
		// 旧データ
		Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
		// 現況2
		Property__c chgProperty = new Property__c (
			Id = oldProperty.Id
			, LiveStatus__c = CommonConst.PROPERTY_LIVESTATUS_RESIDENT
		);
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
		update chgProperty;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
	}
	// ▲ 2022.03.30 CHINTAI対応追加

	// ▼ 2022.03.30 CHINTAI対応追加 完全一致条件実施チェック（値更新無し）
	@isTest static void checkUpdateNoChange(){
		// 旧データ
		Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
		Property__c chgProperty = new Property__c (
			Id = oldProperty.Id
		);
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
		update chgProperty;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
	}
	// ▲ 2022.03.30 CHINTAI対応追加

	// ▼ 2022.03.30 CHINTAI対応追加 完全一致条件実施チェック（スキップ処理あり）
	@isTest static void checkSkipPropCompareProcess(){
		// 旧データ
		Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
		// スキップ処理
        SystemConfig__c systemConfig = new SystemConfig__c(
            IsSkipPropCompareProcess__c = true
        );
        insert systemConfig;

		Property__c chgProperty = new Property__c(
            Id = oldProperty.Id
        );
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
		update chgProperty;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
    }
	// ▲ 2022.03.30 CHINTAI対応追加

	// 2022.03.30 CHINTAI対応にて、テストメソッド（isExecuteExactOther）の内容を分割し、削除
    // 分割先メソッド→checkLiveStatus_SCHEDULEDTOLEAVE(),checkLiveStatus_RESIDENT(),checkUpdateNoChange(),checkSkipPropCompareProcess()

	// 空室予約物件の更新
	@isTest static void updVacancyReservationProperty(){
		// 値変更有り
		Property__c property1 = [SELECT Id
										, LiveStatus__c
										, Building__c
										, RoomCount__c
										, RoomLayout__c
										, FormerSupplier__c
								 FROM Property__c
								 WHERE Name = '空室予約物件用物件1'];
		
		// 値変更無し
		Property__c property2 = [SELECT Id
										, LiveStatus__c 
								 FROM Property__c
								 WHERE Name = '空室予約物件用物件2'];

		// 建物IDが一致する物件を居住中に更新
		property1.LiveStatus__c = CommonConst.PROPERTY_LIVESTATUS_RESIDENT;
		List<Property__c> propertyList = new List<Property__c>{
			property1
			, property2
		};
		update propertyList;

		// 建物IDが一致する物件を空室に更新
		property1.LiveStatus__c = CommonConst.PROPERTY_LIVESTATUS_VACANCY;
		propertyList = new List<Property__c>{
			property1
			, property2
		};
		update propertyList;
		
		// 建物IDが一致し、空室、居住中が存在する物件のうち空室を削除
		Property__c insertProperty = new Property__c(
			Name = '空室予約物件用物件3'
			, LiveStatus__c = CommonConst.PROPERTY_LIVESTATUS_RESIDENT
			, Building__c = property1.Building__c
			, RoomCount__c = property1.RoomCount__c
			, RoomLayout__c = property1.RoomLayout__c
			, FormerSupplier__c = property1.FormerSupplier__c
		);
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
		insert insertProperty;
		delete property1;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
	}
    
    // 物件コード履歴の更新
    @isTest static void updPropertyCdHist(){

        Building__c building = [SELECT Id FROM BUilding__c LIMIT 1];

        // 対象の物件を登録
        Property__c property = new Property__c(
            Building__c                  = building.Id
            , ImportType__c              = CommonConst.PROPERTY_IMPORTTYPE_REALNETPRO
            , MaintenancePropertyCode__c = '1234567'
        );
        insert property;

        // 取込先を初期化して物件コード履歴を更新
        property.ImportType__c              = CommonConst.PROPERTY_IMPORTTYPE_MANUAL;
        property.MaintenancePropertyCode__c = null;
		
		Test.startTest(); // 2022.03.30 CHINTAI対応追加
        update property;
		Test.stopTest();	//  2022.03.30 CHINTAI対応追加
    }
}