// 条件完全一致物件バッチテストクラス
@isTest
private class BD301005BatchTest {
    
    
    //テストに使用するレコードを作成する
    @testSetup static void Setting(){

        // システム設定
        SystemConfig__c systemConfig = new SystemConfig__c(
            ErrorEmailDestination__c = 'test@mail.address'  // エラーメール送信先
            , ExactConditionMatchBatchPropertySize__c = null
        );
        insert systemConfig;

        // システム変数
        SystemVariables__c systemVariables = new SystemVariables__c(
            VariablesLabel__c = 'システム変数テスト'
            , BooleanValue__c = true
            , VariablesName__c = CommonConst.IS_EXACT_COND_MATCH_PROP_BATCH_PROCESSING
        );
        insert systemVariables;

        //標準プロファイルを取得
        Id profileId = [SELECT Id FROM Profile WHERE Name = '一般ユーザ'].Id;

        // ユーザ作成（※作成にユーザ情報が必要）
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            // ユーザ
            User testUser = new User(LastName            = 'ippanUser'            // 姓
                                     , Alias             =  'alias'               // 別名
                                     , Email             = 'ippanUser@test.com'   // メール
                                     , UserName          =  'ippanUser@test.com'  // ユーザ名
                                     , CommunityNickname ='テストニックネーム'     // ニックネーム
                                     , EmailEncodingKey  = 'ISO-2022-JP'          // メールの文字コード
                                     , TimeZoneSidKey    = 'Asia/Tokyo'           // タイムゾーン
                                     , LocaleSidKey      = 'ja_JP'                // 地域
                                     , LanguageLocaleKey = 'ja'                   // 言語
                                     , ProfileId         = profileId              // プロファイルID
            );
            insert testUser;     
        }

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
            , Latitude__c = 10
            , Longitude__c = 11
        );
        Station__c station2 = new Station__c(
            Name = 'テスト駅2'
            , TrainRoute__c = trainRoute2.Id
            , Latitude__c = 10
            , Longitude__c = 12
        );
        Station__c station3 = new Station__c(
            Name = 'テスト駅3'
            , TrainRoute__c = trainRoute3.Id
            , Latitude__c = 10
            , Longitude__c = 13
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
        Building__c building = new Building__c (
            Name = '完全条件一致用建物'
            , StationDistance1__c = 1
            , StationDistance2__c = 1
            , StationDistance3__c = 1
            , Station1__c = station1.Id
            , Station2__c = station2.Id
            , Station3__c = station3.Id
            , JuniorHighSchool1__c = school1.Id
            , JuniorHighSchool2__c = school2.Id
            , JuniorHighSchool3__c = school3.Id
            , PrimarySchool1__c = school1.Id
            , PrimarySchool2__c = school2.Id
            , PrimarySchool3__c = school3.Id
            , District__c = CommonConst.BUILDING_DISTRICT_NAKA
            , BuildingYM__c = '202101'
            , Structure__c = null
            , PropertyType__c = CommonConst.BUILDING_PROPERTYTYPE_DETACHEDHOUSE
            
        );
        insert building;

        // 取引先
        Account account = new Account(
            Name = '完全条件一致用取引先'
            // ▼2021.10.08 No.307 対応で追加
            , PropertyConditionsName__c = '取引先物件条件'
			, IsReservePropertyConditions__c = true
            // ▲2021.10.08 No.307 対応で追加
            , DesiredJuniorHighSchoolArea__c = desiredSchoolArea1.Id
            , DesiredElementarySchoolArea__c = desiredSchoolArea2.Id
            , DesiredTrainRoute1__c = desiredTrainRoute1.Id
            , DesiredTrainRoute2__c = desiredTrainRoute2.Id
            , DesiredTrainRoute3__c = desiredTrainRoute3.Id
            , WalkingTime__c = '10'
            , DesiredArea__c = CommonConst.BUILDING_DISTRICT_NAKA
            , BuildingAge__c = '1'
            , IsDetachedHouse__c = true
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
            , ExactConditionMatch__c = CommonConst.CORRESPOND_EXACT_CONDITION_MATCH_EXISTS
        );
        insert correspond;

        // 物件
        Property__c property = new Property__c(
            Name = '完全条件一致用物件'
            , LiveStatus__c = CommonConst.PROPERTY_LIVESTATUS_VACANCY
            , Building__c = building.Id
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
        insert property;

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
            , Property__c = property.Id
        );
        insert propertyConditions;

		// ▼2021.10.08 No.307 対応で追加
        // お客様物件条件
		AccountPropertyConditions__c apc1 = new AccountPropertyConditions__c(
			Name = 'お客様物件条件物件【条件1】'
			, Account__c = account.id
            , IsReservePropertyConditions__c = true
			, DesiredJuniorHighSchoolArea__c = desiredSchoolArea1.Id
			, DesiredElementarySchoolArea__c = desiredSchoolArea2.Id
			, DesiredTrainRoute1__c = desiredTrainRoute1.Id
			, DesiredTrainRoute2__c = desiredTrainRoute2.Id
			, DesiredTrainRoute3__c = desiredTrainRoute3.Id
			, WalkingTime__c = '10'
			, DesiredArea__c = CommonConst.BUILDING_DISTRICT_NAKA
			, BuildingAge__c = '1'
			, IsDetachedHouse__c = true
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
			);
		insert(apc1);

        // お客様物件条件
		AccountPropertyConditions__c apc2 = new AccountPropertyConditions__c(
			Name = 'お客様物件条件物件【条件2】'
			, Account__c = account.id
            , IsReservePropertyConditions__c = true
			, DesiredJuniorHighSchoolArea__c = desiredSchoolArea1.Id
			, DesiredElementarySchoolArea__c = desiredSchoolArea2.Id
			, DesiredTrainRoute1__c = desiredTrainRoute1.Id
			, DesiredTrainRoute2__c = desiredTrainRoute2.Id
			, DesiredTrainRoute3__c = desiredTrainRoute3.Id
			, WalkingTime__c = '10'
			, DesiredArea__c = CommonConst.BUILDING_DISTRICT_NAKA
			, BuildingAge__c = '1'
			, IsDetachedHouse__c = true
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
			);
		insert(apc2);
		// ▲2021.10.08 No.307 対応で追加
	}

    /**
     * 正常処理
     */
    @isTest static void normalTest(){

        // システム設定
        SystemConfig__c systemConfig = [SELECT ErrorEmailDestination__c
                                        FROM SystemConfig__c];

        // システム変数
        SystemVariables__c systemVariables = [SELECT Id
                                                     , BooleanValue__c
                                              FROM SystemVariables__c
                                              WHERE VariablesName__c = :CommonConst.IS_EXACT_COND_MATCH_PROP_BATCH_PROCESSING];

        // 条件完全一致バッチ実行
        List<ExactConditionMatchBatchExecution__c> ecmbeList = [SELECT Id
                                                                FROM ExactConditionMatchBatchExecution__c];
        
        // バッチ実施前チェック
        System.assertNotEquals(systemConfig.ErrorEmailDestination__c, null); // システム設定.エラーメール送信先
        System.assertEquals(systemVariables.BooleanValue__c, true);          // システム変数.Boolean値
        System.assertEquals(ecmbeList.size(), 1);                            // 条件完全一致バッチ実行のレコード数

        System.runAs(getUserInfosUser()) {

            // 条件完全一致物件バッチを正常実施
            executeBatch(ErrProcess.None, 100);

            // 送信メールの取得
            List<EmailMessage> emailMessageList = [SELECT TextBody
                                                   FROM EmailMessage];

            // システム変数の再取得
            systemVariables = [SELECT Id
                                      , BooleanValue__c
                               FROM SystemVariables__c
                               WHERE Id = :systemVariables.Id];

            // 条件完全一致バッチ実行の再取得
            ecmbeList = [SELECT Id
                         FROM ExactConditionMatchBatchExecution__c];

            // バッチ実施後チェック
            System.assertEquals(systemVariables.BooleanValue__c, false); // システム変数.Boolean値
            System.assertEquals(ecmbeList.size(), 0);                    // 条件完全一致バッチ実行のレコード数
            System.assertEquals(emailMessageList.size(), 0);             // エラーメールの送信件数
        }
    }

    /**
     * 条件完全一致バッチ実行の複数削除テスト
     */
    @isTest static void exactCondMatchPropMultiDeleteTest(){

        // 建物
        Building__c building = [SELECT Id
                                FROM Building__c
                                WHERE Name = '完全条件一致用建物'];

        // 物件を登録
        Property__c property = new Property__c(
            Name = '条件完全一致用物件2'
            , LiveStatus__c = CommonConst.PROPERTY_LIVESTATUS_VACANCY
            , Building__c = building.Id
            , RoomArea__c = 20
        );
        insert property;

        // 条件完全一致バッチ実行の登録件数チェック
        List<ExactConditionMatchBatchExecution__c> ecmbeList = [SELECT Id
                                                                FROM ExactConditionMatchBatchExecution__c];
        System.assertEquals(ecmbeList.size(), 2);

        System.runAs(getUserInfosUser()) {

            // 条件完全一致物件バッチの正常処理設定    
            Set<Id> propertyIdSet = new Map<Id, Property__c>([SELECT Id
                                                              FROM Property__c]).keySet();
            BD301005Batch b = new BD301005Batch(propertyIdSet); 

            // 条件完全一致物件バッチを実施
            Test.startTest();
            Database.executeBatch(b, 100);
            Test.stopTest();

            // 条件完全一致バッチ実行の再取得
            ecmbeList = [SELECT Id
                         FROM ExactConditionMatchBatchExecution__c];

            // 条件完全一致バッチ実行の削除チェック
            System.assertEquals(ecmbeList.size(), 0);
        }
    }

    // 完全一致条件実施チェック（構造）
    @isTest static void isExecuteExactMatchStructure(){
     
        Account account = [SELECT Id FROM Account WHERE Name = '完全条件一致用取引先'];

        // SRC
        Account updAccount = new Account(
            Id = account.Id
            , IsSRC__c = true
        );
        update updAccount;
        BD301005Batch b = getBatchInstance();
        Database.executeBatch(b, 100);

        // RC
        updAccount = new Account(
            Id = account.Id
            , IsRC__c = true
        );
        update updAccount;
        Database.executeBatch(b, 100);

        // 鉄骨造
        updAccount = new Account(
            Id = account.Id
            , IsSteel__c = true
        );
        update updAccount;
        Database.executeBatch(b, 100); 

        // 軽量鉄骨
        updAccount = new Account(
            Id = account.Id
            , IsLightweightSteel__c = true
        );
        update updAccount; 
        Database.executeBatch(b, 100);   

        // 木造
        updAccount = new Account(
            Id = account.Id
            , IsWooden__c = true
        );
        update updAccount; 
        Database.executeBatch(b, 100);   
    }
    
    // 完全一致条件実施チェック（間取り）
    @isTest static void isExecuteExactMatchRoomLayout1(){
          
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
        BD301005Batch b = getBatchInstance();
        Database.executeBatch(b, 100); 

        // ワンルーム
        updAccount = new Account(
            Id = oldAccount.Id
            , IsOneRoom__c = true
        );
        update updAccount;

        Property__c chgProperty = new Property__c (
            Id = oldProperty.Id
            , RoomCount__c = 1
            , RoomLayout__c = CommonConst.PROPERTY_ROOMLAYOUT_R
        );
        update chgProperty;
        b = getBatchInstance();
        Database.executeBatch(b, 100);   

        // 1K
        updAccount = new Account(
            Id = oldAccount.Id
            , Is1K__c = true
        );
        update updAccount;

        chgProperty = new Property__c (
            Id = oldProperty.Id
            , RoomCount__c = 1
            , RoomLayout__c = CommonConst.PROPERTY_ROOMLAYOUT_SK
        );
        update chgProperty;
        b = getBatchInstance();
        Database.executeBatch(b, 100);   

        // 1DK
        updAccount = new Account(
            Id = oldAccount.Id
            , Is1DK__c = true
        );
        update updAccount; 

        chgProperty = new Property__c (
            Id = oldProperty.Id
            , RoomCount__c = 1
            , RoomLayout__c = CommonConst.PROPERTY_ROOMLAYOUT_SLK
        );
        update chgProperty;
        b = getBatchInstance();
        Database.executeBatch(b, 100);   

        // 1LDK/SLDK
        updAccount = new Account(
            Id = oldAccount.Id
            , Is1LDK1SLDK__c = true
        );
        update updAccount;

        chgProperty = new Property__c (
            Id = oldProperty.Id
            , RoomCount__c = 1
            , RoomLayout__c = CommonConst.PROPERTY_ROOMLAYOUT_SLDK
        );
        update chgProperty;
        b = getBatchInstance();
        Database.executeBatch(b, 100);   

        // 2K/DK
        updAccount = new Account(
            Id = oldAccount.Id
            , Is2K2DK__c = true
        );
        update updAccount;

        chgProperty = new Property__c (
            Id = oldProperty.Id
            , RoomCount__c = 2
            , RoomLayout__c = CommonConst.PROPERTY_ROOMLAYOUT_SLK
        );
        update chgProperty;
        b = getBatchInstance();
        Database.executeBatch(b, 100);   

        // 2LDK/SLDK
        updAccount = new Account(
            Id = oldAccount.Id
            , Is2LDK2SLDK__c = true
        );
        update updAccount;

        chgProperty = new Property__c (
            Id = oldProperty.Id
            , RoomCount__c = 2
            , RoomLayout__c = CommonConst.PROPERTY_ROOMLAYOUT_SLDK
        );
        update chgProperty;
        b = getBatchInstance();
        Database.executeBatch(b, 100);   
    }
    
    // 完全一致条件実施チェック（間取り）
    @isTest static void isExecuteExactMatchRoomLayout2(){
        
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

        // 3K/DK
        updAccount = new Account(
            Id = oldAccount.Id
            , Is3K3DK__c = true
        );
        update updAccount;

        Property__c chgProperty = new Property__c (
            Id = oldProperty.Id
            , RoomCount__c = 3
            , RoomLayout__c = CommonConst.PROPERTY_ROOMLAYOUT_SLK
        );
        update chgProperty;
        BD301005Batch b = getBatchInstance();
        Database.executeBatch(b, 100); 

        // 3LDK/SLDK
        updAccount = new Account(
            Id = oldAccount.Id
            , Is3LDK3SLDK__c = true
        );
        update updAccount;

        chgProperty = new Property__c (
            Id = oldProperty.Id
            , RoomCount__c = 3
            , RoomLayout__c = CommonConst.PROPERTY_ROOMLAYOUT_SLDK
        );
        update chgProperty;
        b = getBatchInstance();
        Database.executeBatch(b, 100); 

        // 4K/DK/LDK~
        updAccount = new Account(
            Id = oldAccount.Id
            , Is4K4DK4LDKFrom__c = true
        );
        update updAccount;

        chgProperty = new Property__c (
            Id = oldProperty.Id
            , RoomCount__c = 4
            , RoomLayout__c = CommonConst.PROPERTY_ROOMLAYOUT_SLDK
        );
        update chgProperty;
        b = getBatchInstance();
        Database.executeBatch(b, 100); 

        // 不一致
        chgProperty = new Property__c (
            Id = oldProperty.Id
            , RoomCount__c = 1
            , RoomLayout__c = null
        );
        update chgProperty;
        b = getBatchInstance();
        Database.executeBatch(b, 100); 
    }
    
    // 完全一致条件実施チェック（方角）
    @isTest static void isExecuteExactMatchDirection(){
        
        // 旧データ
        Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
        Account oldAccount = [SELECT Id FROM Account WHERE Name = '完全条件一致用取引先'];

        // 未選択
        Account updAccount = new Account(
            Id = oldAccount.Id
            , IsNorth__c = false
            , IsNorthEast__c = false
            , IsEast__c = false
            , IsSouthEast__c = false
            , IsSouth__c = false
            , IsSouthWest__c = false
            , IsWest__c = false
            , IsNorthWest__c = false
        );
        update updAccount;
        BD301005Batch b = getBatchInstance();
        Database.executeBatch(b, 100); 

        // 北
        updAccount = new Account(
            Id = oldAccount.Id
            , IsNorth__c = true
        );
        update updAccount;

        Property__c chgProperty = new Property__c (
            Id = oldProperty.Id
            , BalconyDirection__c = CommonConst.PROPERTY_BALCONYDIRECTION_NORTH
        );
        update chgProperty;
        b = getBatchInstance();
        Database.executeBatch(b, 100); 

        // 北東
        updAccount = new Account(
            Id = oldAccount.Id
            , IsNorthEast__c = true
        );
        update updAccount;

        chgProperty = new Property__c (
            Id = oldProperty.Id
            , BalconyDirection__c = CommonConst.PROPERTY_BALCONYDIRECTION_NORTHEAST
        );
        update chgProperty;
        b = getBatchInstance();
        Database.executeBatch(b, 100); 

        // 東
        updAccount = new Account(
            Id = oldAccount.Id
            , IsEast__c = true
        );
        update updAccount;

        chgProperty = new Property__c (
            Id = oldProperty.Id
            , BalconyDirection__c = CommonConst.PROPERTY_BALCONYDIRECTION_EAST
        );
        update chgProperty;
        b = getBatchInstance();
        Database.executeBatch(b, 100); 

        // 南東
        updAccount = new Account(
            Id = oldAccount.Id
            , IsSouthEast__c = true
        );
        update updAccount;

        chgProperty = new Property__c (
            Id = oldProperty.Id
            , BalconyDirection__c = CommonConst.PROPERTY_BALCONYDIRECTION_SOUTHEAST
        );
        update chgProperty;
        b = getBatchInstance();
        Database.executeBatch(b, 100); 
    }
    
    // 完全一致条件実施チェック（方角2）
    @isTest static void isExecuteExactMatchDirection2(){
        
        // 旧データ
        Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
        Account oldAccount = [SELECT Id FROM Account WHERE Name = '完全条件一致用取引先'];

        // 未選択
        Account updAccount = new Account(
            Id = oldAccount.Id
            , IsNorth__c = false
            , IsNorthEast__c = false
            , IsEast__c = false
            , IsSouthEast__c = false
            , IsSouth__c = false
            , IsSouthWest__c = false
            , IsWest__c = false
            , IsNorthWest__c = false
        );
        update updAccount;

        // 南
        updAccount = new Account(
            Id = oldAccount.Id
            , IsSouth__c = true
        );
        update updAccount;

        Property__c chgProperty = new Property__c (
            Id = oldProperty.Id
            , BalconyDirection__c = CommonConst.PROPERTY_BALCONYDIRECTION_SOUTH
        );
        update chgProperty;
        BD301005Batch b = getBatchInstance();
        Database.executeBatch(b, 100);

        // 南西
        updAccount = new Account(
            Id = oldAccount.Id
            , IsSouthWest__c = true
        );
        update updAccount;

        chgProperty = new Property__c (
            Id = oldProperty.Id
            , BalconyDirection__c = CommonConst.PROPERTY_BALCONYDIRECTION_SOUTHWEST
        );
        update chgProperty;
        b = getBatchInstance();
        Database.executeBatch(b, 100);

        // 西
        updAccount = new Account(
            Id = oldAccount.Id
            , IsWest__c = true
        );
        update updAccount;

        chgProperty = new Property__c (
            Id = oldProperty.Id
            , BalconyDirection__c = CommonConst.PROPERTY_BALCONYDIRECTION_WEST
        );
        update chgProperty;
        b = getBatchInstance();
        Database.executeBatch(b, 100);

        // 北西
        updAccount = new Account(
            Id = oldAccount.Id
            , IsNorthWest__c = true
        );
        update updAccount;

        chgProperty = new Property__c (
            Id = oldProperty.Id
            , BalconyDirection__c = CommonConst.PROPERTY_BALCONYDIRECTION_NORTHWEST
        );
        update chgProperty;
        b = getBatchInstance();
        Database.executeBatch(b, 100);

        // 不一致
        chgProperty = new Property__c (
            Id = oldProperty.Id
            , BalconyDirection__c = null
        );
        update chgProperty;
        b = getBatchInstance();
        Database.executeBatch(b, 100);
    }
    
    // 完全一致条件実施チェック（駐輪）
    @isTest static void isExecuteExactMatchBicycleParking(){
        
        // 旧データ
        Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
        PropertyConditions__c oldPropCond = [SELECT Id FROM PropertyConditions__c WHERE Property__c = :oldProperty.Id];

        // 大型バイク
        PropertyConditions__c  chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsLargeBike__c = false
        );
        update chgPropertyCond;

        Property__c chgProperty = new Property__c (
            Id = oldProperty.Id
            , BalconyDirection__c = CommonConst.PROPERTY_BALCONYDIRECTION_WEST
        );
        update chgProperty;
        BD301005Batch b = getBatchInstance();
        Database.executeBatch(b, 100);

        // 中型バイク
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsMediumBike__c = false
        );
        update chgPropertyCond;

        chgProperty = new Property__c (
            Id = oldProperty.Id
            , BalconyDirection__c = CommonConst.PROPERTY_BALCONYDIRECTION_NORTHWEST
        );
        update chgProperty;
        b = getBatchInstance();
        Database.executeBatch(b, 100);

        // 小型バイク
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsSmallBike__c = false
        );
        update chgPropertyCond;

        chgProperty = new Property__c (
            Id = oldProperty.Id
            , BalconyDirection__c = CommonConst.PROPERTY_BALCONYDIRECTION_WEST
        );
        update chgProperty;
        b = getBatchInstance();
        Database.executeBatch(b, 100);

        // バイク可
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsBikeStorage__c = false
        );
        update chgPropertyCond;

        chgProperty = new Property__c (
            Id = oldProperty.Id
            , BalconyDirection__c = CommonConst.PROPERTY_BALCONYDIRECTION_NORTHWEST
        );
        update chgProperty;
        b = getBatchInstance();
        Database.executeBatch(b, 100);

        // 駐輪場
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsBicycleParking__c = false
        );
        update chgPropertyCond;

        chgProperty = new Property__c (
            Id = oldProperty.Id
            , BalconyDirection__c = CommonConst.PROPERTY_BALCONYDIRECTION_WEST
        );
        update chgProperty;
        b = getBatchInstance();
        Database.executeBatch(b, 100);
    }
    
    // 完全一致条件実施チェック（ペット）
    @isTest static void isExecuteExactMatchCondPet(){
        
        // 旧データ
        Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
        PropertyConditions__c oldPropCond = [SELECT Id FROM PropertyConditions__c WHERE Property__c = :oldProperty.Id];

        // ペット(その他)
        PropertyConditions__c chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsOtherPet__c = false
        );
        update chgPropertyCond;

        Property__c chgProperty = new Property__c (
            Id = oldProperty.Id
            , BalconyDirection__c = CommonConst.PROPERTY_BALCONYDIRECTION_WEST
        );
        update chgProperty;
        BD301005Batch b = getBatchInstance();
        Database.executeBatch(b, 100);

        // ペット(猫)
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsCat__c = false
        );
        update chgPropertyCond;

        chgProperty = new Property__c (
            Id = oldProperty.Id
            , BalconyDirection__c = CommonConst.PROPERTY_BALCONYDIRECTION_NORTHWEST
        );
        update chgProperty;
        b = getBatchInstance();
        Database.executeBatch(b, 100);

        // ペット(大型犬)
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsLargePet__c = false
        );
        update chgPropertyCond;

        chgProperty = new Property__c (
            Id = oldProperty.Id
            , BalconyDirection__c = CommonConst.PROPERTY_BALCONYDIRECTION_WEST
        );
        update chgProperty;
        b = getBatchInstance();
        Database.executeBatch(b, 100);

        // ペット(中型犬)
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsMiddlePet__c = false
        );
        update chgPropertyCond;

        chgProperty = new Property__c (
            Id = oldProperty.Id
            , BalconyDirection__c = CommonConst.PROPERTY_BALCONYDIRECTION_NORTHWEST
        );
        update chgProperty;
        b = getBatchInstance();
        Database.executeBatch(b, 100);

        // ペット(小型犬)
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsSmallPet__c = false
        );
        update chgPropertyCond;

        chgProperty = new Property__c (
            Id = oldProperty.Id
            , BalconyDirection__c = CommonConst.PROPERTY_BALCONYDIRECTION_WEST
        );
        update chgProperty;
        b = getBatchInstance();
        Database.executeBatch(b, 100);

        // ペット可
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsPet__c = false
            , IsSmallPet__c = false
            , IsMiddlePet__c = false
            , IsLargePet__c = false
            , IsCat__c = false
            , IsOtherPet__c = false
        );
        update chgPropertyCond;

        chgProperty = new Property__c (
            Id = oldProperty.Id
            , BalconyDirection__c = CommonConst.PROPERTY_BALCONYDIRECTION_NORTHWEST
        );
        update chgProperty;
        b = getBatchInstance();
        Database.executeBatch(b, 100);
    }

    /**
     * レコード削除時の正常動作テスト
     */
    @isTest static void recordDeleteTest() {

        // システム変数を削除
        List<SystemVariables__c> systemVariablesList = [SELECT Id
                                                        FROM SystemVariables__c
                                                        WHERE VariablesName__c = :CommonConst.IS_EXACT_COND_MATCH_PROP_BATCH_PROCESSING];
        delete systemVariablesList;

        // 条件完全一致バッチ実行を削除
        List<ExactConditionMatchBatchExecution__c> ecmbeList = [SELECT Id
                                                                FROM ExactConditionMatchBatchExecution__c];
        delete ecmbeList;

        System.runAs(getUserInfosUser()) {

            // システム変数を再取得
            systemVariablesList = [SELECT Id
                                   FROM SystemVariables__c
                                   WHERE VariablesName__c = :CommonConst.IS_EXACT_COND_MATCH_PROP_BATCH_PROCESSING];

            // 条件完全一致バッチ実行を再取得
            ecmbeList = [SELECT Id
                         FROM ExactConditionMatchBatchExecution__c];

            // レコードの削除確認
            System.assertEquals(systemVariablesList.size(), 0); // システム変数
            System.assertEquals(ecmbeList.size(), 0);           // 条件完全一致バッチ実行

            // 条件完全一致物件バッチを正常実施
            executeBatch(ErrProcess.None, 100);

            // 送信されたメールを取得
            List<EmailMessage> emailMessageList = [SELECT TextBody
                                                   FROM EmailMessage];

            // メールの未送信チェック
            System.assertEquals(emailMessageList.size(), 0);
        }
    }

    /**
     * エラーメールの未送信テスト
     */
    @isTest static void notSendErrMailTest() {

        // システム設定.エラーメール送信先を未設定に更新
        SystemConfig__c systemConfig = [SELECT Id
                                               , ErrorEmailDestination__c
                                        FROM SystemConfig__c];
        systemConfig.ErrorEmailDestination__c = null;
        update systemConfig;

        // システム設定.エラーメール送信先が未設定である事を再確認
        systemConfig = [SELECT Id
                               , ErrorEmailDestination__c
                        FROM SystemConfig__c];
        System.assertEquals(systemConfig.ErrorEmailDestination__c, null);

        System.runAs(getUserInfosUser()) {

            // 条件完全一致物件バッチを異常実施
            executeBatch(ErrProcess.All, 100);

            // 送信されたメールを取得
            List<EmailMessage> emailMessageList = [SELECT TextBody
                                                   FROM EmailMessage];

            // メールの未送信チェック
            System.assertEquals(emailMessageList.size(), 0);
        }
    }

    /**
     * executeメソッドの異常テスト
     */
    @isTest static void executeMethodErrTest() {

        // 対応
        Correspond__c beforeCorrespond = [SELECT Id
                                                 , SystemModstamp
                                          FROM correspond__c
                                          WHERE Status__c = :CommonConst.CORRESPOND_STATUS_PURSUITHOLD
                                                AND ExactConditionMatch__c = :CommonConst.CORRESPOND_EXACT_CONDITION_MATCH_EXISTS];

        // 条件完全一致バッチ実行
        List<ExactConditionMatchBatchExecution__c> beforeEcmbeList = [SELECT Id
                                                                      FROM ExactConditionMatchBatchExecution__c];

        // システム設定
        SystemConfig__c systemConfig = [SELECT ErrorEmailDestination__c
                                        FROM SystemConfig__c];

        // 処理実施前チェック
        System.assertNotEquals(beforeEcmbeList.size(), 0);                   // 条件完全一致バッチ実行
        System.assertNotEquals(systemConfig.ErrorEmailDestination__c, null); // システム設定.エラーメール送信先

        System.runAs(getUserInfosUser()) {

            // 条件完全一致物件バッチを異常実施
            executeBatch(ErrProcess.ExecuteMethod, 100);

            // 送信されたメールを取得
            EmailMessage emailMessage = [SELECT TextBody
                                         FROM EmailMessage];

            // 出力値を確認
            System.debug('テキスト内容:' + emailMessage.TextBody);

            // 対応を再取得
            Correspond__c afterCorrespond = [SELECT Id
                                                    , SystemModstamp
                                             FROM correspond__c
                                             WHERE Id = :beforeCorrespond.Id];

            // 対応明細を取得
            List<CorrespondDetail__c> correspondDetailList = [SELECT Id
                                                              FROM CorrespondDetail__c
                                                              WHERE Corresponds__c = :afterCorrespond.Id];

            // 条件完全一致物件を取得
            List<ExactConditionMatchProperty__c> ecmpList = [SELECT Id
                                                             FROM ExactConditionMatchProperty__c];

            // 条件完全一致バッチ実行を取得
            List<ExactConditionMatchBatchExecution__c> afterEcmbeList = [SELECT Id
                                                                         FROM ExactConditionMatchBatchExecution__c];

            // ロールバックの確認
            System.assertEquals(beforeCorrespond.SystemModstamp, afterCorrespond.SystemModstamp); // 対応
            System.assertEquals(correspondDetailList.size(), 0);                                  // 対応明細
            System.assertEquals(ecmpList.size(), 0);                                              // 条件完全一致物件

            // 条件完全一致バッチ実行の削除未実施の確認
            System.assertEquals(beforeEcmbeList.size(), afterEcmbeList.size());
        }
    }

    /**
     * システム変数メソッドの異常テスト
     */
    @isTest static void systemVariablesErrTest() {

        System.runAs(getUserInfosUser()) {

            // 条件完全一致物件バッチを異常実施
            executeBatch(ErrProcess.SystemVariables, 100);

            // 送信されたメールを取得
            EmailMessage emailMessage = [SELECT TextBody
                                         FROM EmailMessage];

            // 出力値を確認
            System.debug('テキスト内容:' + emailMessage.TextBody);

            // システム変数を取得
            SystemVariables__c systemVariables = [SELECT Id
                                                         , BooleanValue__c
                                                  FROM SystemVariables__c
                                                  WHERE VariablesName__c = :CommonConst.IS_EXACT_COND_MATCH_PROP_BATCH_PROCESSING];

            // システム変数のロールバックの未実施確認
            System.assertEquals(systemVariables.BooleanValue__c, true);
        }
    }

    /**
     * 条件完全一致バッチ実行メソッドの異常テスト
     */
    @isTest static void exactCondMatchPropErrTest() {

        // 条件完全一致バッチ実行
        List<ExactConditionMatchBatchExecution__c> beforeEcmbeList = [SELECT Id
                                                                      FROM ExactConditionMatchBatchExecution__c];

        System.runAs(getUserInfosUser()) {

            // 条件完全一致物件バッチを異常実施
            executeBatch(ErrProcess.ExactCondMatchProp, 100);

            // 送信されたメールを取得
            EmailMessage emailMessage = [SELECT TextBody
                                         FROM EmailMessage];

            // 出力値を確認
            System.debug('テキスト内容:' + emailMessage.TextBody);

            // 条件完全一致バッチ実行の再取得
            List<ExactConditionMatchBatchExecution__c> afterEcmbeList = [SELECT Id
                                                                         FROM ExactConditionMatchBatchExecution__c];

            // 条件完全一致バッチ実行のロールバックの未実施確認
            // ※ロジックで1件削除している為、1件分の差分が発生する
            System.assertEquals(beforeEcmbeList.size(), afterEcmbeList.size() + 1);
        }
    }

    /**
     * executeメソッド + システム変数の異常テスト
     */
    @isTest static void executeAndSystemVariablesErrTest() {
    
        System.runAs(getUserInfosUser()) {

            // 条件完全一致物件バッチの設定
            BD301005Batch b = getBatchInstance();
            BD301005Batch.isExecuteMethodErr          = true;
            BD301005Batch.isSystemVariablesErrTest    = true;

            // 条件完全一致物件バッチを実施
            Test.startTest();
            Database.executeBatch(b, 100);
            Test.stopTest();

            // 送信されたメールを取得
            EmailMessage emailMessage = [SELECT TextBody
                                         FROM EmailMessage];

            // 出力値を確認
            System.debug('テキスト内容:' + emailMessage.TextBody);

            // 置換前のテキスト内容のサイズを取得
            String sTextBody = String.valueOf(emailMessage.TextBody);
            Integer beforeTextBodySize = sTextBody.length();

            // 置換後のテキスト内容のサイズを取得
            String errContentsKey = '【エラー内容】';
            sTextBody = sTextBody.replaceAll(errContentsKey, CommonConst.STRING_EMPTY);
            Integer afterTextBodySize = sTextBody.length();

            // 置換回数から送信内容を確認
            Integer hasErrMsgCnt = (beforeTextBodySize - afterTextBodySize) / errContentsKey.length();
            System.assertEquals(hasErrMsgCnt, 2);
        }
    }

    /**
     * 条件完全一致バッチ実行 + システム変数の異常テスト
     */
    @isTest static void exactCondMatchPropAndSystemVariablesErrTest() {
    
        System.runAs(getUserInfosUser()) {

            // 条件完全一致物件バッチの設定
            BD301005Batch b = getBatchInstance();
            BD301005Batch.isSystemVariablesErrTest    = true;
            BD301005Batch.isExactCondMatchPropErrTest = true;

            // 条件完全一致物件バッチを実施
            Test.startTest();
            Database.executeBatch(b, 100);
            Test.stopTest();

            // 送信されたメールを取得
            EmailMessage emailMessage = [SELECT TextBody
                                         FROM EmailMessage];

            // 出力値を確認
            System.debug('テキスト内容:' + emailMessage.TextBody);

            // 置換前のテキスト内容のサイズを取得
            String sTextBody = String.valueOf(emailMessage.TextBody);
            Integer beforeTextBodySize = sTextBody.length();

            // 置換後のテキスト内容のサイズを取得
            String errContentsKey = '【エラー内容】';
            sTextBody = sTextBody.replaceAll(errContentsKey, CommonConst.STRING_EMPTY);
            Integer afterTextBodySize = sTextBody.length();

            // 置換回数から送信内容を確認
            Integer hasErrMsgCnt = (beforeTextBodySize - afterTextBodySize) / errContentsKey.length();
            System.assertEquals(hasErrMsgCnt, 2);
        }
    }

// ▼2021.10.08 No.307 対応で追加	
    /**
     * 条件完全一致バッチ実行 + 物件条件名登録テスト（取引先の物件条件に一致）
     */
    @isTest static void registPropertyConditionsName1() {

		// お客様物件条件を削除
		List<AccountPropertyConditions__c> apcList = [SELECT id FROM AccountPropertyConditions__c];
		SecureDML.secureDelete(apcList);

		// システム設定
		SystemConfig__c systemConfig = [SELECT ErrorEmailDestination__c FROM SystemConfig__c];

		// システム変数
		SystemVariables__c systemVariables = [SELECT Id
									, BooleanValue__c
							FROM SystemVariables__c
							WHERE VariablesName__c = :CommonConst.IS_EXACT_COND_MATCH_PROP_BATCH_PROCESSING];

		// 条件完全一致バッチ実行
		List<ExactConditionMatchBatchExecution__c> ecmbeList = [SELECT Id
												FROM ExactConditionMatchBatchExecution__c];
		
		// ▼ 2022.01.27 No.307 対応で追加
		//実行前に存在する対応明細Idを取得
		Map<Id, CorrespondDetail__c> befCDMap = new Map<Id, CorrespondDetail__c>([SELECT Id FROM CorrespondDetail__c]);
		// ▲ 2022.01.27 No.307 対応で追加

		// バッチ実施前チェック
		System.assertNotEquals(systemConfig.ErrorEmailDestination__c, null); // システム設定.エラーメール送信先
		System.assertEquals(systemVariables.BooleanValue__c, true);          // システム変数.Boolean値
		System.assertEquals(ecmbeList.size(), 1);                            // 条件完全一致バッチ実行のレコード数

		System.runAs(getUserInfosUser()) {

			// 条件完全一致物件バッチを正常実施
			executeBatch(ErrProcess.None, 100);

			// 送信メールの取得
			List<EmailMessage> emailMessageList = [SELECT TextBody FROM EmailMessage];

			// システム変数の再取得
			systemVariables = [SELECT Id
						, BooleanValue__c
				FROM SystemVariables__c
				WHERE Id = :systemVariables.Id];

			// 条件完全一致バッチ実行の再取得
			ecmbeList = [SELECT Id FROM ExactConditionMatchBatchExecution__c];

			// バッチ実施後チェック
			System.assertEquals(systemVariables.BooleanValue__c, false); // システム変数.Boolean値
			System.assertEquals(ecmbeList.size(), 0);                    // 条件完全一致バッチ実行のレコード数
			System.assertEquals(emailMessageList.size(), 0);             // エラーメールの送信件数

			List<ExactConditionMatchProperty__c> ecmp = [SELECT PropertyConditionsName__c FROM ExactConditionMatchProperty__c];
			System.assertEquals('取引先物件条件', ecmp[0].PropertyConditionsName__c);
			// ▼ 2022.01.27 No.307 対応で追加
			// 追加された対応明細の対応内容の3行目に物件条件名が表示されることを確認
			List<CorrespondDetail__c> aftCD = [SELECT Id, SupportedContent__c FROM CorrespondDetail__c WHERE Id NOT IN :befCDMap.keySet()];
			System.assertEquals('物件条件名：取引先物件条件', aftCD[0].SupportedContent__c.split(CommonConst.LINE_FEED)[2]);
			// ▲ 2022.01.27 No.307 対応で追加
		}
	}


	/**
     * 条件完全一致バッチ実行 + 物件条件名登録テスト（取引先の物件条件、お客様物件条件1件に一致）
     */
    @isTest static void registPropertyConditionsName2() {

		// お客様物件条件を削除
		List<AccountPropertyConditions__c> apcList = [SELECT id FROM AccountPropertyConditions__c WHERE Name = 'お客様物件条件物件【条件2】'];
		SecureDML.secureDelete(apcList);

		// システム設定
		SystemConfig__c systemConfig = [SELECT ErrorEmailDestination__c
		FROM SystemConfig__c];

		// システム変数
		SystemVariables__c systemVariables = [SELECT Id
									, BooleanValue__c
							FROM SystemVariables__c
							WHERE VariablesName__c = :CommonConst.IS_EXACT_COND_MATCH_PROP_BATCH_PROCESSING];

		// 条件完全一致バッチ実行
		List<ExactConditionMatchBatchExecution__c> ecmbeList = [SELECT Id
												FROM ExactConditionMatchBatchExecution__c];

		// ▼ 2022.01.27 No.307 対応で追加
		//実行前に存在する対応明細Idを取得
		Map<Id, CorrespondDetail__c> befCDMap = new Map<Id, CorrespondDetail__c>([SELECT Id FROM CorrespondDetail__c]);
		// ▲ 2022.01.27 No.307 対応で追加
		// バッチ実施前チェック
		System.assertNotEquals(systemConfig.ErrorEmailDestination__c, null); // システム設定.エラーメール送信先
		System.assertEquals(systemVariables.BooleanValue__c, true);          // システム変数.Boolean値
		System.assertEquals(ecmbeList.size(), 1);                            // 条件完全一致バッチ実行のレコード数

		System.runAs(getUserInfosUser()) {

			// 条件完全一致物件バッチを正常実施
			executeBatch(ErrProcess.None, 100);

			// 送信メールの取得
			List<EmailMessage> emailMessageList = [SELECT TextBody FROM EmailMessage];

			// システム変数の再取得
			systemVariables = [SELECT Id
						, BooleanValue__c
				FROM SystemVariables__c
				WHERE Id = :systemVariables.Id];

			// 条件完全一致バッチ実行の再取得
			ecmbeList = [SELECT Id FROM ExactConditionMatchBatchExecution__c];

			// バッチ実施後チェック
			System.assertEquals(systemVariables.BooleanValue__c, false); // システム変数.Boolean値
			System.assertEquals(ecmbeList.size(), 0);                    // 条件完全一致バッチ実行のレコード数
			System.assertEquals(emailMessageList.size(), 0);             // エラーメールの送信件数

			List<ExactConditionMatchProperty__c> ecmp = [SELECT PropertyConditionsName__c FROM ExactConditionMatchProperty__c];
			System.assertEquals('取引先物件条件;お客様物件条件物件【条件1】', ecmp[0].PropertyConditionsName__c);
			// ▼ 2022.01.27 No.307 対応で追加
			// 追加された対応明細の対応内容の3行目に物件条件名が表示されることを確認
			List<CorrespondDetail__c> aftCD = [SELECT Id, SupportedContent__c FROM CorrespondDetail__c WHERE Id NOT IN :befCDMap.keySet()];
			System.assertEquals('物件条件名：取引先物件条件、お客様物件条件物件【条件1】', aftCD[0].SupportedContent__c.split(CommonConst.LINE_FEED)[2]);
			// ▲ 2022.01.27 No.307 対応で追加
		}
	}
	

	/**
     * 条件完全一致バッチ実行 + 物件条件名登録テスト（取引先の物件条件、お客様物件条件2件に一致）
     */
    @isTest static void registPropertyConditionsName3() {

		// システム設定
		SystemConfig__c systemConfig = [SELECT ErrorEmailDestination__c
		FROM SystemConfig__c];

		// システム変数
		SystemVariables__c systemVariables = [SELECT Id
									, BooleanValue__c
							FROM SystemVariables__c
							WHERE VariablesName__c = :CommonConst.IS_EXACT_COND_MATCH_PROP_BATCH_PROCESSING];

		// 条件完全一致バッチ実行
		List<ExactConditionMatchBatchExecution__c> ecmbeList = [SELECT Id
												FROM ExactConditionMatchBatchExecution__c];

		// ▼ 2022.01.27 No.307 対応で追加
		//実行前に存在する対応明細Idを取得
		Map<Id, CorrespondDetail__c> befCDMap = new Map<Id, CorrespondDetail__c>([SELECT Id FROM CorrespondDetail__c]);
		// ▲ 2022.01.27 No.307 対応で追加

		// バッチ実施前チェック
		System.assertNotEquals(systemConfig.ErrorEmailDestination__c, null); // システム設定.エラーメール送信先
		System.assertEquals(systemVariables.BooleanValue__c, true);          // システム変数.Boolean値
		System.assertEquals(ecmbeList.size(), 1);                            // 条件完全一致バッチ実行のレコード数

		System.runAs(getUserInfosUser()) {

			// 条件完全一致物件バッチを正常実施
			executeBatch(ErrProcess.None, 100);

			// 送信メールの取得
			List<EmailMessage> emailMessageList = [SELECT TextBody FROM EmailMessage];

			// システム変数の再取得
			systemVariables = [SELECT Id
						, BooleanValue__c
				FROM SystemVariables__c
				WHERE Id = :systemVariables.Id];

			// 条件完全一致バッチ実行の再取得
			ecmbeList = [SELECT Id FROM ExactConditionMatchBatchExecution__c];

			// バッチ実施後チェック
			System.assertEquals(systemVariables.BooleanValue__c, false); // システム変数.Boolean値
			System.assertEquals(ecmbeList.size(), 0);                    // 条件完全一致バッチ実行のレコード数
			System.assertEquals(emailMessageList.size(), 0);             // エラーメールの送信件数

			List<ExactConditionMatchProperty__c> ecmp = [SELECT PropertyConditionsName__c FROM ExactConditionMatchProperty__c];
			System.assertEquals('取引先物件条件;お客様物件条件物件【条件1】;お客様物件条件物件【条件2】', ecmp[0].PropertyConditionsName__c); 
			// ▼ 2022.01.27 No.307 対応で追加
			// 追加された対応明細の対応内容の3行目に物件条件名が表示されることを確認
			List<CorrespondDetail__c> aftCD = [SELECT Id, SupportedContent__c FROM CorrespondDetail__c WHERE Id NOT IN :befCDMap.keySet()];
			System.assertEquals('物件条件名：取引先物件条件、お客様物件条件物件【条件1】、お客様物件条件物件【条件2】', aftCD[0].SupportedContent__c.split(CommonConst.LINE_FEED)[2]);
			// ▲ 2022.01.27 No.307 対応で追加
		}
	}

	/**
     * 条件完全一致バッチ実行 + 既存の条件完全一致物件の物件条件名変更なし
     */
    @isTest static void changePropertyConditionsName1() {

		// システム設定
		SystemConfig__c systemConfig = [SELECT ErrorEmailDestination__c
		FROM SystemConfig__c];

		// システム変数
		SystemVariables__c systemVariables = [SELECT Id
									, BooleanValue__c
							FROM SystemVariables__c
							WHERE VariablesName__c = :CommonConst.IS_EXACT_COND_MATCH_PROP_BATCH_PROCESSING];

		// 条件完全一致オブジェクト登録
		createExactConditionMatchProperty();

		// 条件完全一致バッチ実行前
		List<ExactConditionMatchBatchExecution__c> ecmbeList = [SELECT Id
												FROM ExactConditionMatchBatchExecution__c];

		// バッチ実施前チェック
		System.assertNotEquals(systemConfig.ErrorEmailDestination__c, null); // システム設定.エラーメール送信先
		System.assertEquals(systemVariables.BooleanValue__c, true);          // システム変数.Boolean値
		System.assertEquals(ecmbeList.size(), 1);                            // 条件完全一致バッチ実行のレコード数

		System.runAs(getUserInfosUser()) {

			// 条件完全一致物件バッチを正常実施
			executeBatch(ErrProcess.None, 100);

			// 送信メールの取得
			List<EmailMessage> emailMessageList = [SELECT TextBody FROM EmailMessage];

			// システム変数の再取得
			systemVariables = [SELECT Id
						, BooleanValue__c
				FROM SystemVariables__c
				WHERE Id = :systemVariables.Id];

			
			// 条件完全一致バッチ実行の再取得
			ecmbeList = [SELECT Id FROM ExactConditionMatchBatchExecution__c];

			// バッチ実施後チェック
			System.assertEquals(systemVariables.BooleanValue__c, false); // システム変数.Boolean値
			System.assertEquals(ecmbeList.size(), 0);                    // 条件完全一致バッチ実行のレコード数
			System.assertEquals(emailMessageList.size(), 0);             // エラーメールの送信件数

			List<ExactConditionMatchProperty__c> ecmp = [SELECT PropertyConditionsName__c FROM ExactConditionMatchProperty__c];
			System.assertEquals(1, ecmp.size());
			System.assertEquals('取引先物件条件;お客様物件条件物件【条件1】;お客様物件条件物件【条件2】', ecmp[0].PropertyConditionsName__c); 
		}
	}

	/**
     * 条件完全一致バッチ実行 + 既存の条件完全一致物件の物件条件名変更あり
     */
    @isTest static void changePropertyConditionsName2() {

		// システム設定
		SystemConfig__c systemConfig = [SELECT ErrorEmailDestination__c
		FROM SystemConfig__c];

		// システム変数
		SystemVariables__c systemVariables = [SELECT Id
									, BooleanValue__c
							FROM SystemVariables__c
							WHERE VariablesName__c = :CommonConst.IS_EXACT_COND_MATCH_PROP_BATCH_PROCESSING];

		// 条件完全一致オブジェクト登録
		createExactConditionMatchProperty();

		AccountPropertyConditions__c apc = [SELECT id, Name FROM AccountPropertyConditions__c WHERE Name = 'お客様物件条件物件【条件2】' LIMIT 1];
		apc.Name = 'お客様物件条件物件【変更】';
		upsert apc;

		// 条件完全一致バッチ実行前
		List<ExactConditionMatchBatchExecution__c> ecmbeList = [SELECT Id
												FROM ExactConditionMatchBatchExecution__c];

		// バッチ実施前チェック
		System.assertNotEquals(systemConfig.ErrorEmailDestination__c, null); // システム設定.エラーメール送信先
		System.assertEquals(systemVariables.BooleanValue__c, true);          // システム変数.Boolean値
		System.assertEquals(ecmbeList.size(), 1);                            // 条件完全一致バッチ実行のレコード数

		System.runAs(getUserInfosUser()) {

			// 条件完全一致物件バッチを正常実施
			executeBatch(ErrProcess.None, 100);

			// 送信メールの取得
			List<EmailMessage> emailMessageList = [SELECT TextBody FROM EmailMessage];

			// システム変数の再取得
			systemVariables = [SELECT Id
						, BooleanValue__c
				FROM SystemVariables__c
				WHERE Id = :systemVariables.Id];

			
			// 条件完全一致バッチ実行の再取得
			ecmbeList = [SELECT Id FROM ExactConditionMatchBatchExecution__c];

			// バッチ実施後チェック
			System.assertEquals(systemVariables.BooleanValue__c, false); // システム変数.Boolean値
			System.assertEquals(ecmbeList.size(), 0);                    // 条件完全一致バッチ実行のレコード数
			System.assertEquals(emailMessageList.size(), 0);             // エラーメールの送信件数

			List<ExactConditionMatchProperty__c> ecmp = [SELECT PropertyConditionsName__c FROM ExactConditionMatchProperty__c];
			System.assertEquals(1, ecmp.size());
			System.assertEquals('取引先物件条件;お客様物件条件物件【条件1】;お客様物件条件物件【変更】', ecmp[0].PropertyConditionsName__c); 
		}
	}

	/**
     * 条件完全一致バッチ実行 + 取引先.予約物件条件TRUE
     */
    @isTest static void accountIsReservePropertyConditionsTrue() {
		// お客様物件条件を削除
		List<AccountPropertyConditions__c> apcList = [SELECT id FROM AccountPropertyConditions__c];
		SecureDML.secureDelete(apcList);

		List<ExactConditionMatchProperty__c> ecmpBefore = [SELECT id FROM ExactConditionMatchProperty__c];
		System.assertEquals(0, ecmpBefore.size());
		executeBatch(ErrProcess.None, 100);
		List<ExactConditionMatchProperty__c> ecmpAfter = [SELECT id FROM ExactConditionMatchProperty__c];
		System.assertEquals(1, ecmpAfter.size());

	}

	/**
     * 条件完全一致バッチ実行 + 取引先.予約物件条件FALSE
     */
    @isTest static void accountIsReservePropertyConditionsFalse() {
		// お客様物件条件を削除
		List<AccountPropertyConditions__c> apcList = [SELECT id FROM AccountPropertyConditions__c];
		SecureDML.secureDelete(apcList);		

		Account account = [SELECT id FROM Account LIMIT 1];
		account.IsReservePropertyConditions__c = false;
		upsert account;

		List<ExactConditionMatchProperty__c> ecmpBefore = [SELECT id FROM ExactConditionMatchProperty__c];
		System.assertEquals(0, ecmpBefore.size());
		executeBatch(ErrProcess.None, 100);
		List<ExactConditionMatchProperty__c> ecmpAfter = [SELECT id, Name, PropertyConditionsName__c FROM ExactConditionMatchProperty__c];
		System.assertEquals(0, ecmpAfter.size());
	}


	/**
     * 条件完全一致バッチ実行 + お客様物件条件.予約物件条件TRUE
     */
    @isTest static void accountProConIsReservePropertyConditionsTrue() {

		// 取引先の予約物件条件をFALSEに設定する。
		Account account = [SELECT id FROM Account LIMIT 1];
		account.IsReservePropertyConditions__c = false;
		upsert account;

		// お客様物件条件を削除
		AccountPropertyConditions__c apcDel = [SELECT id FROM AccountPropertyConditions__c WHERE Name = 'お客様物件条件物件【条件2】'];
		SecureDML.secureDelete(apcDel);
		
		List<ExactConditionMatchProperty__c> ecmpBefore = [SELECT id FROM ExactConditionMatchProperty__c];
		System.assertEquals(0, ecmpBefore.size());
		executeBatch(ErrProcess.None, 100);
		List<ExactConditionMatchProperty__c> ecmpAfter = [SELECT id, Name, PropertyConditionsName__c FROM ExactConditionMatchProperty__c];
		System.assertEquals(1, ecmpAfter.size());

	}

	/**
     * 条件完全一致バッチ実行 + お客様物件条件.予約物件条件FALSE
     */
    @isTest static void accountProConIsReservePropertyConditionsFalse() {

		// 取引先の予約物件条件をFALSEに設定する。
		Account account = [SELECT id FROM Account LIMIT 1];
		account.IsReservePropertyConditions__c = false;
		upsert account;

		// お客様物件条件を削除
		AccountPropertyConditions__c apcDel = [SELECT id FROM AccountPropertyConditions__c WHERE Name = 'お客様物件条件物件【条件2】'];
		SecureDML.secureDelete(apcDel);

		// お客様物件条件.予約物件条件をFALSEに設定する
		AccountPropertyConditions__c apcUpd = [SELECT id FROM AccountPropertyConditions__c WHERE Name = 'お客様物件条件物件【条件1】'];
		apcUpd.IsReservePropertyConditions__c = false;
		SecureDML.secureUpdate(apcUpd);

		List<ExactConditionMatchProperty__c> ecmpBefore = [SELECT id FROM ExactConditionMatchProperty__c];
		System.assertEquals(0, ecmpBefore.size());
		executeBatch(ErrProcess.None, 100);
		List<ExactConditionMatchProperty__c> ecmpAfter = [SELECT id, Name, PropertyConditionsName__c FROM ExactConditionMatchProperty__c];
		System.assertEquals(0, ecmpAfter.size());
	}

	/**
     * 条件完全一致バッチ実行 + 取引先.物件条件名がNULL
     */
    @isTest static void accountPropertyConditionsNameNullCheck() {

		// 取引先の予約物件条件をFALSEに設定する。
		Account account = [SELECT id FROM Account LIMIT 1];
		account.PropertyConditionsName__c = null;
		upsert account;

		// お客様物件条件を削除
		List<AccountPropertyConditions__c> apcDel = [SELECT id FROM AccountPropertyConditions__c];
		SecureDML.secureDelete(apcDel);

		List<ExactConditionMatchProperty__c> ecmpBefore = [SELECT id FROM ExactConditionMatchProperty__c];
		System.assertEquals(0, ecmpBefore.size());
		executeBatch(ErrProcess.None, 100);
		List<ExactConditionMatchProperty__c> ecmpAfter = [SELECT id, Name, PropertyConditionsName__c FROM ExactConditionMatchProperty__c];
		System.assertEquals(1, ecmpAfter.size());
		System.assertEquals(null, ecmpAfter[0].PropertyConditionsName__c);
	}
	
	
	// 条件完全一致物件オブジェクト登録
	private static void createExactConditionMatchProperty() {

		Account account = [SELECT id FROM Account LIMIT 1];
		Property__c prop = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件' LIMIT 1];
		
		ExactConditionMatchProperty__c ecmp = new ExactConditionMatchProperty__c(
			Property__c = prop.id
			, Account__c = account.Id
			, PropertyConditionsName__c = '取引先物件条件;お客様物件条件物件【条件1】;お客様物件条件物件【条件2】'
		);
		insert ecmp;
		
	}
// ▲2021.10.08 No.307 対応で追加

    /**
     * バッチのインスタンスを取得
     */
    private static BD301005Batch getBatchInstance() {

        Property__c property = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
        Set<Id> propertyId = new Set<Id>{
            property.Id
        };

        return new BD301005Batch(propertyId); 
    }

    /**
     * ユーザ情報のユーザの取得
     * @return ユーザ
     */
    private static User getUserInfosUser() {
        return [SELECT Id 
                FROM User
                WHERE Id = :UserInfo.getUserId()];
    }

    /**
     * 条件完全一致物件バッチの実行
     */
    private static void executeBatch(ErrProcess errProcess, Integer batSize) {
        
        // 条件完全一致物件バッチの設定
        BD301005Batch b = getBatchInstance();
        switch on errProcess {
            when ExecuteMethod {
                BD301005Batch.isExecuteMethodErr = true;
            }
            when SystemVariables {
                BD301005Batch.isSystemVariablesErrTest = true;
            }
            when ExactCondMatchProp {
                BD301005Batch.isExactCondMatchPropErrTest = true;
            }
            when All {
                BD301005Batch.isExecuteMethodErr          = true;
                BD301005Batch.isSystemVariablesErrTest    = true;
                BD301005Batch.isExactCondMatchPropErrTest = true;
            }
        }

        // 条件完全一致物件バッチを実施
        Test.startTest();
        Database.executeBatch(b, batSize);
        Test.stopTest();
    }

    /**
     * エラー処理
     */
    private enum ErrProcess {
        None                 // 無し
        , ExecuteMethod      // executeメソッド
        , SystemVariables    // システム変数
        , ExactCondMatchProp // 条件完全一致バッチ実行
        , All                // 全エラー
    }
}