//周辺情報取得バッチ
global with sharing class BD601004Batch implements Database.Batchable<sObject>, Database.AllowsCallouts{
//※Database.AllowCallouts を宣言することで、100回までのコールアウトが可能になる

    
    // コンストラクタ
    global BD601004Batch() {
        //なし
    }

    /*
    * バッチ処理開始時に最初に呼び出される
    * バッチ処理対象のレコードを返却するQueryLocatorを返す
    */ 
    global Database.QueryLocator start(Database.BatchableContext BC){

        String soql ='';
        soql += 'SELECT Id, Latitude__c';// 緯度
        soql += ', Longitude__c';    // 経度
        soql += ', Address__c';      // 住所
        soql += ', ChoazaCode__c';   // 町字コード
        soql += ', State__c';        // 都道府県
        soql += ' FROM Building__c'; // 建物が対象
        soql += ' WHERE IsFirstSurroundingImportFlag__c = true'; //フラグがtrueだと対象となる

        return Database.getQueryLocator(soql);
    }

    
    /*
    * バッチサイズで指定されたレコード数単位で executeが呼び出される
    */
    global void execute(Database.BatchableContext bc, List<Building__c> buildingList) {
        
        //周辺情報取得処理
        GoogleApiUtil.getPeripheralInformation(buildingList);
        
        //データの更新
        if (buildingList.size() > 0) {
            
            //フラグの変更
            for (Building__c building : buildingList) {
                building.IsFirstSurroundingImportFlag__c = false;
            }
            
            SecureDML.secureUpdate(buildingList);
        }
        
    }
    
    
    /*
    * バッチ処理の終了時に呼び出される
    * 終了処理を実装する
    */
    global void finish(Database.BatchableContext bc) {
        //なし
    }
    
    //*******************privateメソッド************************
   

}