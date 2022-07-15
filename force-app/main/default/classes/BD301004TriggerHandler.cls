// 物件条件トリガハンドラ
public with sharing class BD301004TriggerHandler {

    /** トリガから実行 */
    private boolean m_isExecuting = false;
    /** 新旧両方のトリガコール内のレコードの数 */
    private integer BatchSize = 0;

    /** コンストラクタ */
    public BD301004TriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    /** 登録前処理 */
    public void onBeforeInsert(PropertyConditions__c[] newObjs){
 
    }
        
    /** 登録後処理 */
    public void onAfterInsert(PropertyConditions__c[] newObjs, Map<ID, PropertyConditions__c> newObjMap){
        // 条件完全一致物件を連絡
        this.contactCondMatchProp(new Map<Id, PropertyConditions__c>(), newObjs);
    }
        
    /** 更新前処理 */
    public void onBeforeUpdate(PropertyConditions__c[] oldObjs, Map<ID, PropertyConditions__c> oldObjMap, PropertyConditions__c[] newObjs, Map<ID, PropertyConditions__c> newObjMap){

    }
        
    /** 更新後処理 */
    public void onAfterUpdate(PropertyConditions__c[] oldObjs, Map<ID, PropertyConditions__c> oldObjMap, PropertyConditions__c[] newObjs, Map<ID, PropertyConditions__c> newObjMap){
        // 条件完全一致物件を連絡
        this.contactCondMatchProp(oldObjMap, newObjs);
    }
        
    /** 削除前処理 */
    public void onBeforeDelete(PropertyConditions__c[] oldObjs, Map<ID, PropertyConditions__c> oldObjMap){
            
    }
        
    /** 削除後処理 */
    public void onAfterDelete(PropertyConditions__c[] oldObjs, Map<ID, PropertyConditions__c> oldObjMap){
            
    }
        
    /** 復元後処理 */
    public void onUndelete(PropertyConditions__c[] newObjs){
            
    }

        
    /**
    * 条件完全一致物件を連絡
    * @param  Map<ID, PropertyConditions__c> oldObjMap 物件条件更新前
    * @param  PropertyConditions__c[]        newObjs   物件条件更新後
    */
    private void contactCondMatchProp(Map<ID, PropertyConditions__c> oldObjMap, PropertyConditions__c[] newObjs) {

        // 実施チェック
        if (SystemConfig__c.getInstance().IsSkipPropCondCompareProcess__c) {
            return;
        }

        // 対象物件チェック
        PropertyConditions__c oldPropCond;
        Set<Id> chgMatchPropIdSet = new Set<Id>();
        for(PropertyConditions__c newObj : newObjs) {

            // 更新前値を取得
            oldPropCond = new PropertyConditions__c();
            if (oldObjMap.containskey(newObj.Id)) {
                oldPropCond = oldObjMap.get(newObj.Id);
            }

            if (!this.isExecuteCondMatchProp(oldPropCond, newObj)) {
                continue;
            }

            // 条件完全一致バッチ実行の登録対象の物件IDの取得
            chgMatchPropIdSet.add(newObj.Property__c);
        }

        // 居住可能物件の取得
        List<Property__c> habitablePropList = selectHabitableProperty(chgMatchPropIdSet);
        if (habitablePropList.size() == 0) {
            return;
        }

        // 条件完全一致バッチ実行
        ExactConditionMatchBatchExecution__c ecmbeEntity;           // エンティティ
        List<ExactConditionMatchBatchExecution__c> registEcmbeList; // 登録リスト

        registEcmbeList = new List<ExactConditionMatchBatchExecution__c>();

        // 条件完全一致バッチ実行の登録値の取得
        for (Property__c habitableProp : habitablePropList) {
            ecmbeEntity = new ExactConditionMatchBatchExecution__c(
                Property__c     = habitableProp.Id
                , PropertyId__c = habitableProp.Id
            );
            registEcmbeList.add(ecmbeEntity);
        }

        SecureDML.secureInsert(registEcmbeList, false);
    }

    /**
    * 条件完全一致物件の連絡実施チェック
    * @param  PropertyConditions__c oldProp 物件条件更新前
    * @param  PropertyConditions__c newProp 物件条件更新後
    * @return Boolean     true:実施する、false:実施しない
    */
    private Boolean isExecuteCondMatchProp(PropertyConditions__c oldProp, PropertyConditions__c newProp) {

        // メゾネット
        if (oldProp.IsMaisonette__c != newProp.IsMaisonette__c
            && newProp.IsMaisonette__c) {
            return true;
        }

        // ロフト
        if (oldProp.IsLoft__c != newProp.IsLoft__c
            && newProp.IsLoft__c) {
            return true;
        }
            
        // デザイナーズ
        if (oldProp.IsDesigners__c != newProp.IsDesigners__c
            && newProp.IsDesigners__c) {
            return true;
        }
            
        // リノベーション
        if (oldProp.IsRenovation__c != newProp.IsRenovation__c
            && newProp.IsRenovation__c) {
            return true;
        }
            
        // 分譲賃貸
        if (oldProp.IsCondominiumRental__c != newProp.IsCondominiumRental__c
            && newProp.IsCondominiumRental__c) {
            return true;
        }
            
        // オール洋間
        if (oldProp.IsAllWesternStyleRoom__c != newProp.IsAllWesternStyleRoom__c
            && newProp.IsAllWesternStyleRoom__c) {
            return true;
        }
        // 1階
        if (oldProp.IsFirstFloor__c != newProp.IsFirstFloor__c
            && newProp.IsFirstFloor__c) {
            return true;
        }

        // 2階以上
        if (oldProp.IsSecondFloorOver__c != newProp.IsSecondFloorOver__c
            && newProp.IsSecondFloorOver__c) {
            return true;
        }

        // 最上階
        if (oldProp.IsTopFloor__c != newProp.IsTopFloor__c
            && newProp.IsTopFloor__c) {
            return true;
        }

        // 角部屋
        if (oldProp.IsCornerRoom__c != newProp.IsCornerRoom__c
            && newProp.IsCornerRoom__c) {
            return true;
        }
        // バルコニー
        if (oldProp.IsBalcony__c != newProp.IsBalcony__c
            && newProp.IsBalcony__c) {
            return true;
        }

        // ルーフバルコニー
        if (oldProp.IsRoofBalcony__c != newProp.IsRoofBalcony__c
            && newProp.IsRoofBalcony__c) {
            return true;
        }

        // 専用庭
        if (oldProp.IsPrivateGarden__c != newProp.IsPrivateGarden__c
            && newProp.IsPrivateGarden__c) {
            return true;
        }

        // 駐車場空きあり
        if (oldProp.IsParking__c != newProp.IsParking__c
            && newProp.IsParking__c) {
            return true;
        }

        // 敷地内駐車場
        if (oldProp.IsInSiteParking__c != newProp.IsInSiteParking__c
            && newProp.IsInSiteParking__c) {
            return true;
        }

        // 駐車場2台可
        if (oldProp.IsPluralCarParking__c != newProp.IsPluralCarParking__c
            && newProp.IsPluralCarParking__c) {
            return true;
        }

        // ビルトインガレージ
        if (oldProp.IsBuiltInGarage__c != newProp.IsBuiltInGarage__c
            && newProp.IsBuiltInGarage__c) {
            return true;
        }

        // カーポート
        if (oldProp.IsCarport__c != newProp.IsCarport__c
            && newProp.IsCarport__c) {
            return true;
        }

        // 駐輪場
        if (oldProp.IsBicycleParking__c != newProp.IsBicycleParking__c
            && newProp.IsBicycleParking__c) {
            return true;
        }

        // バイク可
        if (oldProp.IsBikeStorage__c != newProp.IsBikeStorage__c
            && newProp.IsBikeStorage__c) {
            return true;
        }

        // 小型バイク
        if (oldProp.IsSmallBike__c != newProp.IsSmallBike__c
            && newProp.IsSmallBike__c) {
            return true;
        }

        // 中型バイク
        if (oldProp.IsMediumBike__c != newProp.IsMediumBike__c
            && newProp.IsMediumBike__c) {
            return true;
        }

        // 大型バイク
        if (oldProp.IsLargeBike__c != newProp.IsLargeBike__c
            && newProp.IsLargeBike__c) {
            return true;
        }

        // エレベーター
        if (oldProp.IsElevator__c != newProp.IsElevator__c
            && newProp.IsElevator__c) {
            return true;
        }

        // 宅配ボックス
        if (oldProp.IsDeliveryBox__c != newProp.IsDeliveryBox__c
            && newProp.IsDeliveryBox__c) {
            return true;
        }

        // カウンターキッチン
        if (oldProp.IsCounterKitchen__c != newProp.IsCounterKitchen__c
            && newProp.IsCounterKitchen__c) {
            return true;
        }

        // システムキッチン
        if (oldProp.IsSystemKitchen__c != newProp.IsSystemKitchen__c
            && newProp.IsSystemKitchen__c) {
            return true;
        }

        // ガスコンロ
        if (oldProp.IsGasStove__c != newProp.IsGasStove__c
            && newProp.IsGasStove__c) {
            return true;
        }

        // 電気コンロ
        if (oldProp.IsElectricStove__c != newProp.IsElectricStove__c
            && newProp.IsElectricStove__c) {
            return true;
        }

        // IHコンロ
        if (oldProp.IsIhStove__c != newProp.IsIhStove__c
            && newProp.IsIhStove__c) {
            return true;
        }

        // コンロ2口
        if (oldProp.IsTwoGasStove__c != newProp.IsTwoGasStove__c
            && newProp.IsTwoGasStove__c) {
            return true;
        }

        // コンロ3口以上
        if (oldProp.IsMoreGasStove__c != newProp.IsMoreGasStove__c
            && newProp.IsMoreGasStove__c) {
            return true;
        }
        // バス・トイレ別
        if (oldProp.IsSeparate__c != newProp.IsSeparate__c
            && newProp.IsSeparate__c) {
            return true;
        }

        // 追焚機能
        if (oldProp.IsReheating__c != newProp.IsReheating__c
            && newProp.IsReheating__c) {
            return true;
        }

        // 浴室乾燥機
        if (oldProp.IsBathroomDryer__c != newProp.IsBathroomDryer__c
            && newProp.IsBathroomDryer__c) {
            return true;
        }

        // 温水洗浄便座
        if (oldProp.IsWashletToiletSeat__c != newProp.IsWashletToiletSeat__c
            && newProp.IsWashletToiletSeat__c) {
            return true;
        }

        // シャワー付き洗面台
        if (oldProp.IsShowerWashBasin__c != newProp.IsShowerWashBasin__c
            && newProp.IsShowerWashBasin__c) {
            return true;
        }

        // 洗面所独立
        if (oldProp.IsWashroomDscrete__c != newProp.IsWashroomDscrete__c
            && newProp.IsWashroomDscrete__c) {
            return true;
        }

        // 室内洗濯機置場
        if (oldProp.IsIndoorWashingMachineStorage__c != newProp.IsIndoorWashingMachineStorage__c
            && newProp.IsIndoorWashingMachineStorage__c) {
            return true;
        }

        // 都市ガス
        if (oldProp.IsCityGas__c != newProp.IsCityGas__c
            && newProp.IsCityGas__c) {
            return true;
        }

        // プロパンガス
        if (oldProp.IsPropaneGas__c != newProp.IsPropaneGas__c
            && newProp.IsPropaneGas__c) {
            return true;
        }

        // オール電化
        if (oldProp.IsAllElectric__c != newProp.IsAllElectric__c
            && newProp.IsAllElectric__c) {
            return true;
        }

        // エアコン
        if (oldProp.IsAirConditioner__c != newProp.IsAirConditioner__c
            && newProp.IsAirConditioner__c) {
            return true;
        }

        // 床暖房
        if (oldProp.IsFloorHeating__c != newProp.IsFloorHeating__c
            && newProp.IsFloorHeating__c) {
            return true;
        }
        // シューズボックス
        if (oldProp.IsShoesBox__c != newProp.IsShoesBox__c
            && newProp.IsShoesBox__c) {
            return true;
        }

        // シューズクローク
        if (oldProp.IsShoeCloak__c != newProp.IsShoeCloak__c
            && newProp.IsShoeCloak__c) {
            return true;
        }

        // ウォークインクローゼット
        if (oldProp.IsWalkInCloset__c != newProp.IsWalkInCloset__c
            && newProp.IsWalkInCloset__c) {
            return true;
        }

        // トランクルーム
        if (oldProp.IsTrunkRoom__c != newProp.IsTrunkRoom__c
            && newProp.IsTrunkRoom__c) {
            return true;
        }

        // BSアンテナ
        if (oldProp.IsBSAntenna__c != newProp.IsBSAntenna__c
            && newProp.IsBSAntenna__c) {
            return true;
        }

        // CSアンテナ
        if (oldProp.IsCSAntenna__c != newProp.IsCSAntenna__c
            && newProp.IsCSAntenna__c) {
            return true;
        }

        // CATV
        if (oldProp.IsCATV__c != newProp.IsCATV__c
            && newProp.IsCATV__c) {
            return true;
        }

        // ネット使用料無料
        if (oldProp.IsInternetFree__c != newProp.IsInternetFree__c
            && newProp.IsInternetFree__c) {
            return true;
        }

        // モニター付きインターホン
        if (oldProp.IsMonitorIntercom__c != newProp.IsMonitorIntercom__c
            && newProp.IsMonitorIntercom__c) {
            return true;
        }

        // オートロック
        if (oldProp.IsAutoLock__c != newProp.IsAutoLock__c
            && newProp.IsAutoLock__c) {
            return true;
        }

        // 家具付き
        if (oldProp.IsFurniture__c != newProp.IsFurniture__c
            && newProp.IsFurniture__c) {
            return true;
        }

        // 家電付き
        if (oldProp.IsHomeAppliance__c != newProp.IsHomeAppliance__c
            && newProp.IsHomeAppliance__c) {
            return true;
        }

        // 保証人不要
        if (oldProp.IsNoGuarantor__c != newProp.IsNoGuarantor__c
            && newProp.IsNoGuarantor__c) {
            return true;
        }

        // 楽器相談可
        if (oldProp.IsMusicalInstruments__c != newProp.IsMusicalInstruments__c
            && newProp.IsMusicalInstruments__c) {
            return true;
        }

        // 外国人契約可
        if (oldProp.IsForeigner__c != newProp.IsForeigner__c
            && newProp.IsForeigner__c) {
            return true;
        }

        // 生活保護契約可
        if (oldProp.IsWelfareAvailable__c != newProp.IsWelfareAvailable__c
            && newProp.IsWelfareAvailable__c) {
            return true;
        }

        // 事務所利用可
        if (oldProp.IsOfficeAvailable__c != newProp.IsOfficeAvailable__c
            && newProp.IsOfficeAvailable__c) {
            return true;
        }

        // 2人入居可
        if (oldProp.IsTwoTenant__c != newProp.IsTwoTenant__c
            && newProp.IsTwoTenant__c) {
            return true;
        }

        // ルームシェア可
        if (oldProp.IsRoomShare__c != newProp.IsRoomShare__c
            && newProp.IsRoomShare__c) {
            return true;
        }

        // 高齢者歓迎
        if (oldProp.IsElderly__c != newProp.IsElderly__c
            && newProp.IsElderly__c) {
            return true;
        }

        // 女性限定
        if (oldProp.IsWoman__c != newProp.IsWoman__c
            && newProp.IsWoman__c) {
            return true;
        }

        // 学生限定マンション
        if (oldProp.IsStudent__c != newProp.IsStudent__c
            && newProp.IsStudent__c) {
            return true;
        }
        // ペット可
        if (oldProp.IsPet__c != newProp.IsPet__c
            && newProp.IsPet__c) {
            return true;
        }

        // ペット(小型犬)
        if (oldProp.IsSmallPet__c != newProp.IsSmallPet__c
            && newProp.IsSmallPet__c) {
            return true;
        }

        // ペット(中型犬)
        if (oldProp.IsMiddlePet__c != newProp.IsMiddlePet__c
            && newProp.IsMiddlePet__c) {
            return true;
        }

        // ペット(大型犬)
        if (oldProp.IsLargePet__c != newProp.IsLargePet__c
            && newProp.IsLargePet__c) {
            return true;
        }

        // ペット(猫)
        if (oldProp.IsCat__c != newProp.IsCat__c
            && newProp.IsCat__c) {
            return true;
        }

        // ペット(その他)
        if (oldProp.IsOtherPet__c != newProp.IsOtherPet__c
            && newProp.IsOtherPet__c) {
            return true;
        }

        return false;
    }

    /**
    * 居住可能物件の取得
    * @param  set<Id> chgPropertyIdSet 更新物件ID
    * @return List<Property__c> 居住可能物件
    */
    private List<Property__c> selectHabitableProperty(set<Id> chgPropertyIdSet) {

        // 居住可能物件の取得
        List<Property__c> habitablePropList = 
            [SELECT Id
             FROM Property__c
             WHERE Id IN :chgPropertyIdSet
                   AND LiveStatus__c IN (:CommonConst.PROPERTY_LIVESTATUS_VACANCY
                                         , :CommonConst.PROPERTY_LIVESTATUS_SCHEDULEDTOLEAVE)
            ];

        // 初期化チェック
        if (habitablePropList.isEmpty()) {
            habitablePropList = new List<Property__c>();
        }

        return habitablePropList;
    }
}