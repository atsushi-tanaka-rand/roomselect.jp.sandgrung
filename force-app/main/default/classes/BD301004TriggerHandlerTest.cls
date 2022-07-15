// 物件条件トリガーハンドラAPEXテストクラス
@isTest
private class BD301004TriggerHandlerTest {

    //テストに使用するレコードを作成する
    @testSetup static void Setting(){

        // 建物
        Building__c building = new Building__c (
            Name = '完全条件一致用建物'            
        );
        insert building;
        
        // 物件
        Property__c property = new Property__c(
            Name = '完全条件一致用物件'
            , Building__c = building.Id
        );
        insert property;

        // 物件条件
        PropertyConditions__c propertyConditions = new PropertyConditions__c(
            IsMaisonette__c = false
            , IsLoft__c = false
            , IsDesigners__c = false
            , IsRenovation__c = false
            , IsCondominiumRental__c = false
            , IsAllWesternStyleRoom__c = false
            , IsFirstFloor__c = false
            , IsSecondFloorOver__c = false
            , IsTopFloor__c = false
            , IsCornerRoom__c = false
            , IsBalcony__c = false
            , IsRoofBalcony__c = false
            , IsPrivateGarden__c = false
            , IsParking__c = false
            , IsInSiteParking__c = false
            , IsPluralCarParking__c = false
            , IsBuiltInGarage__c = false
            , IsCarport__c = false
            , IsBicycleParking__c = false
            , IsBikeStorage__c = false
            , IsSmallBike__c = false
            , IsMediumBike__c = false
            , IsLargeBike__c = false
            , IsElevator__c = false
            , IsDeliveryBox__c = false
            , IsCounterKitchen__c = false
            , IsSystemKitchen__c = false
            , IsGasStove__c = false
            , IsElectricStove__c = false
            , IsIhStove__c = false
            , IsTwoGasStove__c = false
            , IsMoreGasStove__c = false
            , IsSeparate__c = false
            , IsReheating__c = false
            , IsBathroomDryer__c = false
            , IsWashletToiletSeat__c = false
            , IsShowerWashBasin__c = false
            , IsWashroomDscrete__c = false
            , IsIndoorWashingMachineStorage__c = false
            , IsCityGas__c = false
            , IsPropaneGas__c = false
            , IsAllElectric__c = false
            , IsAirConditioner__c = false
            , IsFloorHeating__c = false
            , IsShoesBox__c = false
            , IsShoeCloak__c = false
            , IsWalkInCloset__c = false
            , IsTrunkRoom__c = false
            , IsBSAntenna__c = false
            , IsCSAntenna__c = false
            , IsCATV__c = false
            , IsInternetFree__c = false
            , IsMonitorIntercom__c = false
            , IsAutoLock__c = false
            , IsFurniture__c = false
            , IsHomeAppliance__c = false
            , IsNoGuarantor__c = false
            , IsMusicalInstruments__c = false
            , IsForeigner__c = false
            , IsWelfareAvailable__c = false
            , IsOfficeAvailable__c = false
            , IsPet__c = false
            , IsSmallPet__c = false
            , IsMiddlePet__c = false
            , IsLargePet__c = false
            , IsCat__c = false
            , IsOtherPet__c = false
            , IsTwoTenant__c = false
            , IsRoomShare__c = false
            , IsElderly__c = false
            , IsWoman__c = false
            , IsStudent__c = false
            , Property__c = property.Id
        );
        insert propertyConditions;
    }

    // 完全一致条件実施チェック（構造）
    @isTest static void isExecuteExactMatchStructure(){
        
        // 旧データ
        Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
        PropertyConditions__c oldPropCond = [SELECT Id FROM PropertyConditions__c WHERE Property__c = :oldProperty.Id];

        // オール洋間
        PropertyConditions__c chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsAllWesternStyleRoom__c = true
        );
        update chgPropertyCond;

        // 分譲賃貸
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsCondominiumRental__c = true
        );
        update chgPropertyCond;

        // リノベーション
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsRenovation__c = true
        );
        update chgPropertyCond;

        // デザイナーズ
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsDesigners__c = true
        );
        update chgPropertyCond;

        // ロフト
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsLoft__c = true
        );
        update chgPropertyCond;

        // メゾネット
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsMaisonette__c = true
        );
        update chgPropertyCond;
    }
    
    // 完全一致条件実施チェック（フロア）
    @isTest static void isExecuteExactMatchFloor(){
        
        // 旧データ
        Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
        PropertyConditions__c oldPropCond = [SELECT Id FROM PropertyConditions__c WHERE Property__c = :oldProperty.Id];

        // 角部屋
        PropertyConditions__c  chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsCornerRoom__c = true
        );
        update chgPropertyCond;

        // 最上階
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsTopFloor__c = true
        );
        update chgPropertyCond;

        // 2階以上
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsSecondFloorOver__c = true
        );
        update chgPropertyCond;

        // 1階
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsFirstFloor__c = true
        );
        update chgPropertyCond;
    }
    
    // 完全一致条件実施チェック（バルコニー）
    @isTest static void isExecuteExactMatchBalcony(){
        
        // 旧データ
        Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
        PropertyConditions__c oldPropCond = [SELECT Id FROM PropertyConditions__c WHERE Property__c = :oldProperty.Id];

        // 専用庭
        PropertyConditions__c  chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsPrivateGarden__c = true
        );
        update chgPropertyCond;

        // ルーフバルコニー
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsRoofBalcony__c = true
        );
        update chgPropertyCond;

        // バルコニー
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsBalcony__c = true
        );
        update chgPropertyCond;
    }
    
    // 完全一致条件実施チェック（駐車）
    @isTest static void isExecuteExactMatchParking(){
        
        // 旧データ
        Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
        PropertyConditions__c oldPropCond = [SELECT Id FROM PropertyConditions__c WHERE Property__c = :oldProperty.Id];

        // カーポート
        PropertyConditions__c  chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsCarport__c = true
        );
        update chgPropertyCond;

        // ビルトインガレージ
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsBuiltInGarage__c = true
        );
        update chgPropertyCond;

        // 駐車場2台可
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsPluralCarParking__c = true
        );
        update chgPropertyCond;

        // 敷地内駐車場
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsInSiteParking__c = true
        );
        update chgPropertyCond;

        // 駐車場空きあり
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsParking__c = true
        );
        update chgPropertyCond;
    }
    
    // 完全一致条件実施チェック（駐輪）
    @isTest static void isExecuteExactMatchBicycleParking(){
        
        // 旧データ
        Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
        PropertyConditions__c oldPropCond = [SELECT Id FROM PropertyConditions__c WHERE Property__c = :oldProperty.Id];

        // 大型バイク
        PropertyConditions__c  chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsLargeBike__c = true
        );
        update chgPropertyCond;

        // 中型バイク
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsMediumBike__c = true
        );
        update chgPropertyCond;

        // 小型バイク
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsSmallBike__c = true
        );
        update chgPropertyCond;

        // バイク可
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsBikeStorage__c = true
        );
        update chgPropertyCond;

        // 駐輪場
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsBicycleParking__c = true
        );
        update chgPropertyCond;
    }
    
    // 完全一致条件実施チェック（共用）
    @isTest static void isExecuteExactMatchShared(){
        
        // 旧データ
        Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
        PropertyConditions__c oldPropCond = [SELECT Id FROM PropertyConditions__c WHERE Property__c = :oldProperty.Id];

        // 宅配ボックス
        PropertyConditions__c chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsDeliveryBox__c = true
        );
        update chgPropertyCond;

        // エレベーター
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsElevator__c = true
        );
        update chgPropertyCond;
    }
    
    // 完全一致条件実施チェック（キッチン）
    @isTest static void isExecuteExactMatchKitchen(){
        
        // 旧データ
        Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
        PropertyConditions__c oldPropCond = [SELECT Id FROM PropertyConditions__c WHERE Property__c = :oldProperty.Id];

        // コンロ3口以上
        PropertyConditions__c  chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsMoreGasStove__c = true
        );
        update chgPropertyCond;

        // コンロ2口
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsTwoGasStove__c = true
        );
        update chgPropertyCond;

        // IHコンロ
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsIhStove__c = true
        );
        update chgPropertyCond;

        // 電気コンロ
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsElectricStove__c = true
        );
        update chgPropertyCond;

        // ガスコンロ
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsGasStove__c = true
        );
        update chgPropertyCond;

        // システムキッチン 
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsSystemKitchen__c = true
        );
        update chgPropertyCond;

        // カウンターキッチン
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsCounterKitchen__c = true
        );
        update chgPropertyCond;
    }
    
    // 完全一致条件実施チェック（バス・トイレ）
    @isTest static void isExecuteExactMatchBathToilet(){
        
        // 旧データ
        Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
        PropertyConditions__c oldPropCond = [SELECT Id FROM PropertyConditions__c WHERE Property__c = :oldProperty.Id];

        // 室内洗濯機置場
        PropertyConditions__c  chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsIndoorWashingMachineStorage__c = true
        );
        update chgPropertyCond;

        // 洗面所独立
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsWashroomDscrete__c = true
        );
        update chgPropertyCond;

        // シャワー付き洗面台
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsShowerWashBasin__c = true
        );
        update chgPropertyCond;

        // 温水洗浄便座
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsWashletToiletSeat__c = true
        );
        update chgPropertyCond;

        // 浴室乾燥機
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsBathroomDryer__c = true
        );
        update chgPropertyCond;

        // 追焚機能
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsReheating__c = true
        );
        update chgPropertyCond;

        // バス・トイレ別
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsSeparate__c = true
        );
        update chgPropertyCond;
    }
    
    // 完全一致条件実施チェック（光熱設備）
    @isTest static void isExecuteExactMatchLightHeatFacility(){
        
        // 旧データ
        Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
        PropertyConditions__c oldPropCond = [SELECT Id FROM PropertyConditions__c WHERE Property__c = :oldProperty.Id];

        // 床暖房
        PropertyConditions__c  chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsFloorHeating__c = true
        );
        update chgPropertyCond;

        // エアコン
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsAirConditioner__c = true
        );
        update chgPropertyCond;

        // オール電化
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsAllElectric__c = true
        );
        update chgPropertyCond;

        // プロパンガス
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsPropaneGas__c = true
        );
        update chgPropertyCond;

        // 都市ガス
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsCityGas__c = true
        );
        update chgPropertyCond;
    }
    
    // 完全一致条件実施チェック（収納）
    @isTest static void isExecuteExactMatchStorage(){
        
        // 旧データ
        Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
        PropertyConditions__c oldPropCond = [SELECT Id FROM PropertyConditions__c WHERE Property__c = :oldProperty.Id];

        // トランクルーム
        PropertyConditions__c  chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsTrunkRoom__c = true
        );
        update chgPropertyCond;

        // ウォークインクローゼット
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsWalkInCloset__c = true
        );
        update chgPropertyCond;

        // シューズクローク
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsShoeCloak__c = true
        );
        update chgPropertyCond;

        // シューズボックス
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsShoesBox__c = true
        );
        update chgPropertyCond;
    }
    
    // 完全一致条件実施チェック（通信設備）
    @isTest static void isExecuteExactMatchCommunicationFacility(){
        
        // 旧データ
        Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
        PropertyConditions__c oldPropCond = [SELECT Id FROM PropertyConditions__c WHERE Property__c = :oldProperty.Id];

        // ネット使用料無料
        PropertyConditions__c  chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsInternetFree__c = true
        );
        update chgPropertyCond;

        // CATV
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsCATV__c = true
        );
        update chgPropertyCond;

        // CSアンテナ
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsCSAntenna__c = true
        );
        update chgPropertyCond;

        // BSアンテナ
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsBSAntenna__c = true
        );
        update chgPropertyCond;
    }
    
    // 完全一致条件実施チェック（セキュリティ）
    @isTest static void isExecuteExactMatchSecurity(){
        
        // 旧データ
        Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
        PropertyConditions__c oldPropCond = [SELECT Id FROM PropertyConditions__c WHERE Property__c = :oldProperty.Id];

        // オートロック
        PropertyConditions__c  chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsAutoLock__c = true
        );
        update chgPropertyCond;

        // モニター付きインターホン
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsMonitorIntercom__c = true
        );
        update chgPropertyCond;
    }
    
    // 完全一致条件実施チェック（家具）
    @isTest static void isExecuteExactMatchFurniture(){
        
        // 旧データ
        Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
        PropertyConditions__c oldPropCond = [SELECT Id FROM PropertyConditions__c WHERE Property__c = :oldProperty.Id];

        // 家電付き
        PropertyConditions__c  chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsHomeAppliance__c = true
        );
        update chgPropertyCond;

        // 家具付き
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsFurniture__c = true
        );
        update chgPropertyCond;
    }
    
    // 完全一致条件実施チェック（入居条件）
    @isTest static void isExecuteExactMatchCondMoveIn1(){
        
        // 旧データ
        Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
        PropertyConditions__c oldPropCond = [SELECT Id FROM PropertyConditions__c WHERE Property__c = :oldProperty.Id];

        // 学生限定マンション
        PropertyConditions__c  chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsStudent__c = true
        );
        update chgPropertyCond;

        // 女性限定
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsWoman__c = true
        );
        update chgPropertyCond;

        // 高齢者歓迎
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsElderly__c = true
        );
        update chgPropertyCond;

        // ルームシェア可
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsRoomShare__c = true
        );
        update chgPropertyCond;

        // 2人入居可
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsTwoTenant__c = true
        );
        update chgPropertyCond;

        // ペット(その他)
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsOtherPet__c = true
        );
        update chgPropertyCond;

        // ペット(猫)
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsCat__c = true
        );
        update chgPropertyCond;

        // ペット(大型犬)
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsLargePet__c = true
        );
        update chgPropertyCond;

        // ペット(中型犬)
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsMiddlePet__c = true
        );
        update chgPropertyCond;

        // ペット(小型犬)
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsSmallPet__c = true
        );
        update chgPropertyCond;

        // ペット可
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsPet__c = true
        );
        update chgPropertyCond;
    }
    
    // 完全一致条件実施チェック（入居条件）
    @isTest static void isExecuteExactMatchCondMoveIn2(){
        
        // 旧データ
        Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
        PropertyConditions__c oldPropCond = [SELECT Id FROM PropertyConditions__c WHERE Property__c = :oldProperty.Id];

        // 事務所利用可
        PropertyConditions__c chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsOfficeAvailable__c = true
        );
        update chgPropertyCond;

        // 生活保護契約可
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsWelfareAvailable__c = true
        );
        update chgPropertyCond;

        // 外国人契約可
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsForeigner__c = true
        );
        update chgPropertyCond;

        // 楽器相談可
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsMusicalInstruments__c = true
        );
        update chgPropertyCond;

        // 保証人不要
        chgPropertyCond = new PropertyConditions__c (
            Id = oldPropCond.Id
            , IsNoGuarantor__c = true
        );
        update chgPropertyCond;
    }

    // 完全一致条件実施チェック（その他）
    @isTest static void isExecuteExactOther(){

        // 旧データ
        Property__c oldProperty = [SELECT Id FROM Property__c WHERE Name = '完全条件一致用物件'];
        PropertyConditions__c oldPropCond = [SELECT Id FROM PropertyConditions__c WHERE Property__c = :oldProperty.Id];

        // 未実施
        PropertyConditions__c chgPropCond = new PropertyConditions__c (
                Id = oldPropCond.Id
        );
        update chgPropCond;

        // スキップ処理
        SystemConfig__c systemConfig = new SystemConfig__c(
            IsSkipPropCondCompareProcess__c = true
        );
        insert systemConfig;

        chgPropCond = new PropertyConditions__c(
            Id = oldPropCond.Id
        );
        update chgPropCond;
    }
}