/**
 * 総賃料の再計算修正バッチ
 * 総賃料の計算をリカバリするように使用するバッチです。
 **/
global with sharing class BuildingPropertyCalculatAllRentBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    // コンストラクタ
    global BuildingPropertyCalculatAllRentBatch() {
    }

    //バッチ処理開始時に最初に呼び出される    
    global Database.QueryLocator start(Database.BatchableContext BC){
        //SOQL作成
        String soql ='';

        // 物件の情報取得（全件）
        soql += ' SELECT  Id ' ;
        soql += ' ,       RentFee__c ' ;                                    // 賃料
        soql += ' ,       WortFee__c' ;                                     // 水道料金
        soql += ' ,       WortFeeTax__c' ;                                  // 水道料金(税込)
        soql += ' ,       WortFeeTaxType__c' ;                              // 水道料金税区分
        soql += ' ,       ManagementFee__c' ;                               // 管理費
        soql += ' ,       ManagementFeeTax__c' ;                            // 管理費(税込)
        soql += ' ,       ManagementFeeTaxType__c' ;                        // 管理費税区分
        soql += ' ,       CATVFee__c' ;                                     // CATV
        soql += ' ,       CATVFeeTax__c' ;                                  // CATV(税込)
        soql += ' ,       CATVTaxType__c' ;                                 // CATV税区分
        soql += ' ,       TownshipFeePaymentType__c ';                      // 町会費支払区分
        soql += ' ,       TownshipFee__c' ;                                 // 町会費
        soql += ' ,       TownshipFeeTax__c' ;                              // 町会費(税込)
        soql += ' ,       TownshipFeeTaxType__c' ;                          // 町会費税区分
        soql += ' ,       GarbageDisposalFeePaymentType__c ' ;              // ゴミ処理費支払区分
        soql += ' ,       GarbageDisposalFee__c' ;                          // ゴミ処理費
        soql += ' ,       GarbageDisposalFeeTax__c' ;                       // ゴミ処理費(税込)
        soql += ' ,       GarbageDisposalFeeTaxType__c' ;                   // ゴミ処理費税区分
        soql += ' ,       BicycleParkingFee__c' ;                           // 駐輪場代
        soql += ' ,       BicycleParkingFeeTax__c' ;                        // 駐輪場代(税込)
        soql += ' ,       BicycleParkingFeeTaxType__c' ;                    // 駐輪場代税区分
        soql += ' ,       ParkingType__c ' ;                                // 駐車場種別
        soql += ' ,       ParkingFee__c' ;                                  // 駐車場料金
        soql += ' ,       ParkingFeeTax__c' ;                               // 駐車場料金(税込)
        soql += ' ,       ParkingFeeTaxType__c' ;                           // 駐車場料金税区分
        soql += ' ,       GuaranteeidCompanyType__c ' ;                     // 保証会社（利用区分）
        soql += ' ,       Guaranteeid__c ' ;                                // 保証会社タイトル

        //---------------火災保険の商品情報を物件に保持する-----------------------
        soql += ' ,       FireInsuranceUseType__c ' ;                       // 火災保険加入義務
        soql += ' ,       FireInsurancePlan__c ' ;                          // 火災保険タイトル
        soql += ' ,       FireInsurancePlan__r.PaymentType__c ' ;           // 保証会社（利用区分）
        soql += ' ,       FireInsurancePlan__r.FireInsuranceMonth__c ' ;    // 火災保険料(月額)   
        //---------------火災保険の商品情報を物件に保持するend-----------------------
        
        soql += ' FROM    Property__c ' ;

        return Database.getQueryLocator(soql);
    }

    //バッチサイズで指定されたレコード数単位で executeが呼び出される。
    global void execute(Database.BatchableContext BC, List<Property__c> selectPropertyList) {
        try {
            List<Id> depositIdList = new List<Id>();                // 物件に紐づく保証プランのIdリスト
            Map<Id,Id> depositIdMap = new Map<Id,Id>();             // 物件に紐づく保証プランのIdマップ（物件Id、保証Id）
            List<Id> propertyIdList = new List<Id>();               // 物件Idリスト
            // 火災、保証、管理会社指定商品の取得を行うIdリストの設定
            setIdList(selectPropertyList,depositIdList ,depositIdMap,propertyIdList);

            // 保証プランの取得
            List<Item__c> DepositItemList = selectDepositItemList(depositIdList);
            
            // 物件管理会社指定商品取得（内部で管理会社指定商品の項目を取得する）
            List<PropertyManageCompayItem__c> propertyManageCompayItemList = selectPropertyManageCompayItemList(propertyIdList);
            
            // 管理会社指定商品の取得
            Map<Id, List<ManagementCompanyItem__c>> manageItemMap = new map<Id, List<ManagementCompanyItem__c>>();  // 管理会社指定商品（物件Id、管理会社指定商品）
            manageItemMap = setManageItemMap(propertyManageCompayItemList);

            List<Property__c> updatePropertyList = new List<Property__c>();         // 保存用の物件情報
            for(Property__c selectProperty :selectPropertyList){

                // 総賃料計算用火災保険のデータを設定
                Item__c fireInsuranceItem = selectProperty.FireInsurancePlan__r;

                // 総賃料計算用保証プランを設定
                Item__c DepositItem = setDepositItem(selectProperty.Id,depositIdMap,DepositItemList);

                // 物件に紐づく管理会社指定商品の内容をセットする。
                List<ManagementCompanyItem__c> manageItemList = new List<ManagementCompanyItem__c>();
                if (manageItemMap.containskey(selectProperty.Id)){
                    manageItemList = manageItemMap.get(selectProperty.Id);
                }

                // 計算用物件データの設定（物件のselectにて火災保険の商品を取得しており、総賃料計算にて物件の数式再計算でエラーとなるため）
                Property__c allRentFeeCalculationProperty = setAllRentFeeCalculationProperty(selectProperty);
                // 総賃料のセット
                selectProperty.AllRentFee__c = BuildingPropertyUtil.calcAllRent(allRentFeeCalculationProperty, manageItemList, fireInsuranceItem, DepositItem);  // 総賃料の算出
                // Listの作成準備(更新対象項目の設定)
                Property__c addProperty = new Property__c(
                    Id = selectProperty.Id ,
                    AllRentFee__c = selectProperty.AllRentFee__c
                );
                updatePropertyList.add(addProperty);// update用のListを作成。
            }

            // 総賃料更新
            SecureDML.secureUpdate(updatePropertyList);
        } catch (Exception e) {
            // エラー
            system.debug('エラー：'+e);
        }
    }

    /*
    * バッチ処理の終了時に呼び出される
    * 終了処理を実装する
    */
    global void finish(Database.BatchableContext BC) {
        // なし
    }


    //******************************************************privateメソッド*******************************************************
    
    // 保証プランの計算用金額の取得
    private static List<Item__c> selectDepositItemList(List<Id> DepositItemIdList){
        List<Item__c> DepositItemList = [
            SELECT  Id                              
            ,       ItemName__c                      // 商品名
            ,       Account__r.IsAllRentFeeType__c   // 総賃料区分
            ,       DirectDebitFeeTaxType__c         // 手数料税区分
            ,       DirectDebitFee__c                // 手数料
            ,       DirectDebitFeeTax__c             // 手数料(税込)
            ,      (SELECT   DepositRate__c          // 保証料(割合)
                    ,        DepositYen__c           // 保証料(金額)
                    ,        IsRentFeeType__c        // 賃料区分
                    FROM     ItemDetailItem__r       // 商品明細
                    LIMIT    1)
            FROM    Item__c                          // 商品
            WHERE   Id IN :DepositItemIdList         // 商品ID
        ];

        if (DepositItemList.isEmpty()){
            return new List<Item__c>();
        }
        return DepositItemList;
    }

    // 物件管理会社指定商品取得（管理会社指定商品の情報も裏で保持）
    private static List<PropertyManageCompayItem__c> selectPropertyManageCompayItemList(List<Id> propertyId){
        List<PropertyManageCompayItem__c> propertyManageCompayItemList = [
            SELECT  Id
            ,       Property__c                     // 物件
            ,       Item__c                         // 管理会社指定プラン
            ,       Item__r.PaymentType__c          // 支払区分
            ,       Item__r.TaxType__c              // 税区分
            ,       Item__r.Amount__c               // 金額
            FROM    PropertyManageCompayItem__c
            WHERE   Property__c IN :propertyId      // 物件Id
        ];
        
        if (propertyManageCompayItemList.isEmpty()){
            return new List<PropertyManageCompayItem__c>();
        }
        return propertyManageCompayItemList;
    }

    // データを取得するIDListを作成
    private static void setIdList(List<Property__c> selectPropertyList,List<Id> depositIdList ,Map<Id,Id> depositIdMap,List<Id> propertyIdList){
        for(Property__c selectProperty :selectPropertyList){
            depositIdList.add(selectProperty.Guaranteeid__c);                   // 保証プランのIdリストをセット
            depositIdMap.put(selectProperty.Id,selectProperty.Guaranteeid__c);  // 物件と保証のIdをセット（物件Id、保証プランId）
            propertyIdList.add(selectProperty.Id);                              // 物件のIdリストをセット
        }
    }

    // 計算用物件データの設定（物件のselectにて火災保険の商品を取得しており、総賃料計算にて物件の数式再計算でエラーとなるため）
    private static Property__c setAllRentFeeCalculationProperty(Property__c selectProperty){
        return new Property__c(
            Id = selectProperty.Id ,
            RentFee__c = selectProperty.RentFee__c ,                                                // 賃料
            WortFee__c = selectProperty.WortFee__c ,                                                // 水道料金
            WortFeeTaxType__c = selectProperty.WortFeeTaxType__c ,                                  // 水道料金税区分
            ManagementFee__c = selectProperty.ManagementFee__c ,                                    // 管理費
            ManagementFeeTaxType__c = selectProperty.ManagementFeeTaxType__c ,                      // 管理費税区分
            CATVFee__c = selectProperty.CATVFee__c ,                                                // CATV
            CATVTaxType__c = selectProperty.CATVTaxType__c ,                                        // CATV税区分
            TownshipFeePaymentType__c = selectProperty.TownshipFeePaymentType__c ,                  // 町会費支払区分
            TownshipFee__c = selectProperty.TownshipFee__c ,                                        // 町会費
            TownshipFeeTaxType__c = selectProperty.TownshipFeeTaxType__c ,                          // 町会費税区分
            GarbageDisposalFeePaymentType__c = selectProperty.GarbageDisposalFeePaymentType__c ,    // ゴミ処理費支払区分
            GarbageDisposalFee__c = selectProperty.GarbageDisposalFee__c ,                          // ゴミ処理費
            GarbageDisposalFeeTaxType__c = selectProperty.GarbageDisposalFeeTaxType__c ,            // ゴミ処理費税区分
            BicycleParkingFee__c = selectProperty.BicycleParkingFee__c ,                            // 駐輪場代
            BicycleParkingFeeTaxType__c = selectProperty.BicycleParkingFeeTaxType__c ,              // 駐輪場代税区分
            ParkingType__c = selectProperty.ParkingType__c ,                                        // 駐車場種別
            ParkingFee__c = selectProperty.ParkingFee__c ,                                          // 駐車場料金
            ParkingFeeTaxType__c = selectProperty.ParkingFeeTaxType__c ,                            // 駐車場料金税区分
            GuaranteeidCompanyType__c = selectProperty.GuaranteeidCompanyType__c ,                  // 保証会社（利用区分）
            Guaranteeid__c = selectProperty.Guaranteeid__c ,                                        // 保証会社タイトル
            FireInsuranceUseType__c = selectProperty.FireInsuranceUseType__c ,                      // 火災保険加入義務
            FireInsurancePlan__c = selectProperty.FireInsurancePlan__c                              // 火災保険タイトル
        );
    }

    // 保証プランのデータをセットする。
    private static Item__c setDepositItem(Id propertyId, Map<Id,Id> depositIdMap, List<Item__c> DepositItemList){

        // 保証プランセット
        Id DepositId = depositIdMap.get(propertyId);
        // 2重ループする（保証プラン）
        for(Item__c DepositItemData:DepositItemList){
            // 物件の保証プランと一致したら
            // 保証プランの情報をセットして抜ける
            if(DepositId == DepositItemData.Id){
                return DepositItemData;
            }
        }

        // 判定で一致しなければnullで返す。
        return null;
    }

    // 対象物件の管理会社指定商品をMapにセットする
    private static Map<Id, List<ManagementCompanyItem__c>> setManageItemMap(List<PropertyManageCompayItem__c> propertyManageCompayItemList){
        Map<Id, List<ManagementCompanyItem__c>> manageItemMap = new map<Id, List<ManagementCompanyItem__c>>();  
        // 物件管理会社指定商品をループで回す。
        for(PropertyManageCompayItem__c propertyManageCompayItem :propertyManageCompayItemList){
            ManagementCompanyItem__c managementCompanyItem = new ManagementCompanyItem__c();
            managementCompanyItem = propertyManageCompayItem.Item__r;       // 管理会社指定商品の情報を入れる。
       
            // 数式（金額（税込み））を再計算する。
            managementCompanyItem.recalculateFormulas();

            // 既に物件Idをキーとしてマップにセットされているか確認
            if (manageItemMap.containsKey(propertyManageCompayItem.Property__c)){
                // セットされていれば対象の物件管理会社をListに追加する。
                manageItemMap.get(propertyManageCompayItem.Property__c).add(managementCompanyItem);
            } else {
                // セットされていなければ物件IdをキーとしてMapをセットする。
                manageItemMap.put(propertyManageCompayItem.Property__c, new List<ManagementCompanyItem__c>{managementCompanyItem});
            }
        }

        return manageItemMap;
    }

}