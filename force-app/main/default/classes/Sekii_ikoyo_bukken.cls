/**
 * 移行用のバッチクラスです。
 * 物件検索用の追加項目四つの値を埋めます。
 * トリガの動きを止めて使ってください。
 **/
global with sharing class Sekii_ikoyo_bukken implements Database.Batchable<sObject>{
    
    //コンストラクタ
    global Sekii_ikoyo_bukken(){
    }
    
    //データ取得
    global Database.QueryLocator start(Database.BatchableContext BC){
        //物件取得
        String soql ='';
        soql += 'SELECT Id';
        soql += ' ,RentFee__c';       //賃料
        soql += ' ,ManagementFee__c'; //管理費
        soql += ' ,ParkingFee__c';    //駐車場


        soql += ' FROM Property__c'; //物件が対象
        return Database.getQueryLocator(soql);   
    }
    
    //開始
    global void execute(Database.BatchableContext BC, List<Property__c> targetList){

            
        //更新用List作成
        List<Property__c> updateList = new List<Property__c>();
        
        //物件ループ
        for (Property__c property : targetList){
            
            //物件の計算用項目
            Decimal calcRentFee       = property.RentFee__c       == null ? 0 : property.RentFee__c;       //賃料
            Decimal calcManagementFee = property.ManagementFee__c == null ? 0 : property.ManagementFee__c; //管理費
            Decimal calcParkingFee    = property.ParkingFee__c    == null ? 0 : property.ParkingFee__c;    //駐車場
            
            //更新用物件の作成
            Property__c updateProperty = new Property__c();
            updateProperty.Id = property.Id;
            updateProperty.RentFeeSearch__c                  = calcRentFee;                                      //賃料
            updateProperty.RentFeeSearchManagement__c        = calcRentFee + calcManagementFee;                  //賃料管理費込
            updateProperty.RentFeeSearchParking__c           = calcRentFee +                     calcParkingFee; //賃料駐車場込
            updateProperty.RentFeeSearchManagementParking__c = calcRentFee + calcManagementFee + calcParkingFee; //賃料管理費駐車場込
            
            updateList.add(updateProperty);
        }
        
        //更新
        if (updateList.size() > 0) {
            SecureDML.secureUpdate(updateList);
        }
        
    }
    
    /*
* バッチ処理の終了時に呼び出される
* 終了処理を実装する
*/
    global void finish(Database.BatchableContext BC) {

    }
}