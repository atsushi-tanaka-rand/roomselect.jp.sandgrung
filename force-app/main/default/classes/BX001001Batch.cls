/**
 * RS移行(申込)
 **/
global with sharing class BX001001Batch implements Database.Batchable<sObject> {
    // 付帯商品配列数
    private final static Integer ITEM_SIZE = 5;

    global BX001001Batch() {
    }

    // データ取得
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String soql =''
            + 'SELECT ID'                                       // カスタムオブジェクトID
            + ', AuxiliaryDisinfection__c'                      // 付帯室内消毒
            + ', AuxiliaryIndoorDisinfectionFee__c'             // 付帯室内消毒料
            + ', AuxiliaryKeyExchange__c'                       // 付帯鍵交換
            + ', AuxiliaryKeyExchangeFee__c'                    // 付帯鍵交換費
            + ', AuxiliaryReliableSupport__c'                   // 付帯安心サポート
            + ', AuxiliaryReliableSupportFee__c'                // 付帯安心サポート料
            + ', AuxiliaryFShot__c'                             // 付帯Fショット
            + ', AuxiliaryFShotFee__c'                          // 付帯Fショット料
            + ', AuxiliaryAlsokLock__c'                         // 付帯アルソックロック
            + ', AuxiliaryAlsokLockFee__c'                      // 付帯アルソックロック料
            + ', AuxiliaryItem1__c'                             // 付帯商品１
            + ', AuxiliaryItemFee1__c'                          // 付帯商品料１
            + ', AuxiliaryItem2__c'                             // 付帯商品２
            + ', AuxiliaryItemFee2__c'                          // 付帯商品料２
            + ', AuxiliaryItem3__c'                             // 付帯商品３
            + ', AuxiliaryItemFee3__c'                          // 付帯商品料３
            + ', AuxiliaryItem4__c'                             // 付帯商品４
            + ', AuxiliaryItemFee4__c'                          // 付帯商品料４
            + ', AuxiliaryItem5__c'                             // 付帯商品５
            + ', AuxiliaryItemFee5__c'                          // 付帯商品料５
            + ' FROM Application__c'
            + ' WHERE AuxiliaryDisinfection__c    != NULL'
            + '    OR AuxiliaryKeyExchange__c     != NULL'
            + '    OR AuxiliaryReliableSupport__c != NULL'
            + '    OR AuxiliaryFShot__c           != NULL'
            + '    OR AuxiliaryAlsokLock__c       != NULL'
        ;
        return Database.getQueryLocator(soql);   
    }

    // データ処理
    global void execute(Database.BatchableContext BC, List<Application__c> apliList) {

        // データ毎にコンバートを実施
        for (Application__c apli: apliList) {
            convert(apli);
        }

        // 一括更新
        SecureDML.secureUpdate(apliList);
    }

    // 終了処理
    global void finish(Database.BatchableContext BC) {
    }

    //--------------------------------------privateメソッド----------------------------------------------------------------------------
    private void convert(Application__c apli) {

        // 付帯商品配列を初期化
        List<ID> auxiliaryItemId = new ID[ITEM_SIZE];
        List<Decimal> auxiliaryItemFee = new Decimal[ITEM_SIZE];
        for (Integer j = 0; j < ITEM_SIZE; j++) {
            auxiliaryItemId[j] = null;
            auxiliaryItemFee[j] = null;
        }

        // 付帯商品情報を配列に格納
        Integer i = 0;
        if (apli.AuxiliaryDisinfection__c != null) {
            // 付帯室内消毒がNULLではない場合
            auxiliaryItemId[i]  = apli.AuxiliaryDisinfection__c;
            auxiliaryItemFee[i] = apli.AuxiliaryIndoorDisinfectionFee__c;
            i++;
        }
        if (apli.AuxiliaryKeyExchange__c != null) {
            // 付帯鍵交換がNULLではない場合
            auxiliaryItemId[i]  = apli.AuxiliaryKeyExchange__c;
            auxiliaryItemFee[i] = apli.AuxiliaryKeyExchangeFee__c;
            i++;
        }
        if (apli.AuxiliaryReliableSupport__c != null) {
            // 付帯安心サポートがNULLではない場合
            auxiliaryItemId[i]  = apli.AuxiliaryReliableSupport__c;
            auxiliaryItemFee[i] = apli.AuxiliaryReliableSupportFee__c;
            i++;
        }
        if (apli.AuxiliaryFShot__c != null) {
            // 付帯FショットがNULLではない場合
            auxiliaryItemId[i]  = apli.AuxiliaryFShot__c;
            auxiliaryItemFee[i] = apli.AuxiliaryFShotFee__c;
            i++;
        }
        if (apli.AuxiliaryAlsokLock__c != null) {
            // 付帯アルソックロックがNULLではない場合
            auxiliaryItemId[i]  = apli.AuxiliaryAlsokLock__c;
            auxiliaryItemFee[i] = apli.AuxiliaryAlsokLockFee__c;
            i++;
        }

        // 申込データ変更
        for (Integer j = 1; j <= ITEM_SIZE; j++) {
            apli.put('AuxiliaryItem' + j + '__c', auxiliaryItemId[j-1]);
            apli.put('AuxiliaryItemFee' + j + '__c', auxiliaryItemFee[j-1]);
        }
    }
}