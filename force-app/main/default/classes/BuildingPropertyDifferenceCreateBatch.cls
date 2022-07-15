/**
 * 建物物件差分作成バッチ
 * 移行用のバッチクラスです。
 * 建物物件差分作成用物件に登録された物件の建物物件差分レコードを作成します。2020/5/4：建物物件差分作成用物で指定されたもののみ作成に変更
 **/
global with sharing class BuildingPropertyDifferenceCreateBatch implements Database.Batchable<sObject>{
    
    //コンストラクタ
    global BuildingPropertyDifferenceCreateBatch(){
    }
    
    //データ取得
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        //建物物件差分作成用物件より対象物件を取得
        String soql ='';
        soql += 'SELECT Id ,PropertyId__c';
        soql += '  FROM BuildingPropertyDifferenceCreateTarget__c';
        return Database.getQueryLocator(soql);
    }

    //開始
    global void execute(Database.BatchableContext BC, List<BuildingPropertyDifferenceCreateTarget__c> targetList){
        if (targetList.size() > 0) {
           
            //建物物件差分作成用物件のid,オブジェクトでMap作成
            Map<Id, BuildingPropertyDifferenceCreateTarget__c> targetMap = new Map<Id, BuildingPropertyDifferenceCreateTarget__c>();
            //SELECT用の建物物件差分作成用物件のidリスト作成
            List<id> selectPropertyIdList = new List<id>();

            //建物物件差分作成用物件マップとSELECT用建物物件差分作成用物件のidリストに値を追加
            for (BuildingPropertyDifferenceCreateTarget__c target :targetList){
                targetMap.put(target.PropertyId__c, target);
                selectPropertyIdList.add(target.PropertyId__c);
            }
            //削除用の建物物件差分作成用物件Idリスト作成
            List<BuildingPropertyDifferenceCreateTarget__c> delTargetList = new List<BuildingPropertyDifferenceCreateTarget__c>();
            //更新用の建物物件差分作成用物件Idリスト作成
            List<BuildingPropertyDifferenceCreateTarget__c> updTargetList = new List<BuildingPropertyDifferenceCreateTarget__c>();
            //建物物件差分作成用物件のPropertyIdの物件を取得
            Set<Id> proIdSet = new Set<id>();
            
            List<Property__c> proList = [SELECT id,WebPublishing__c,LiveStatus__c,Name 
                                         FROM Property__c 
                                         WHERE id IN :selectPropertyIdList];

            //取得した物件のSet<Id>を作成
            for (Property__c pro : proList) {
                //Web公開＝する　かつ　現況が　空室or退去予定のみ……差分を作成（idSetにid追加）、建物物件差分を作成用物件を削除
                if (pro.WebPublishing__c == CommonConst.PROPERTY_WEBPUBLISHING_EXISTS && (pro.LiveStatus__c == CommonConst.PROPERTY_LIVESTATUS_VACANCY || pro.LiveStatus__c == CommonConst.PROPERTY_LIVESTATUS_SCHEDULEDTOLEAVE )){
                    //差分作成用IdSetにIdを追加
                    proIdSet.add(pro.id);
                    //削除リストに追加
                    delTargetList.add(targetMap.get(pro.id));

                //それ以外の場合……差分を作成しない、建物物件差分を作成用物件の結果用_現況と結果用_空室の状態を残す
                }else{
                    //結果項目に記入               
                    targetMap.get(pro.id).LiveStatus__c =pro.LiveStatus__c; 
                    targetMap.get(pro.id).WebPublishing__c =pro.WebPublishing__c; 
                    //更新リストに追加
                    updTargetList.add(targetMap.get(pro.id));
                }
            }

            //建物物件差分を作成
            BuildingPropertyUtil.createBuildingPropertyDifference(proIdSet);
            //更新、削除リストがある場合は更新/削除を行う
            if (updTargetList.size() > 0){
                SecureDML.secureUpdate(updTargetList);
            }
            if (delTargetList.size() > 0){
                SecureDML.secureDelete(delTargetList);
            }
        }
    }
    
    /*
    * バッチ処理の終了時に呼び出される
    * 終了処理を実装する
    */
    global void finish(Database.BatchableContext BC) {

    }
}