/**
 * RS移行(仮見積)
 **/
global with sharing class BX001002Batch implements Database.Batchable<sObject> {
    // 付帯商品配列数
    private final static Integer ITEM_SIZE = 5;

    global BX001002Batch() {
    }

    // データ取得
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String soql =''
            + 'SELECT ID'                                       // カスタムオブジェクトID
            + ', DisinfectionItem__c'                           // 室内消毒商品
            + ', IndoorDisinfectionItemFee__c'                  // 室内消毒料金
            + ', KeyExchangeFeeItem__c'                         // 鍵交換費商品
            + ', AuxiliaryKeyExchangeFee__c'                    // カギ交換料金
            + ', ReliableSupportItem__c'                        // 安心サポート商品
            + ', ReliableSupportItemFee__c'                     // 安心サポート料金
            + ', FShotItem__c'                                  // Fショット商品
            + ', FShotItemFee__c'                               // Fショット料金
            + ', AlsokLockItem__c'                              // アルソックロック商品	
            + ', AlsokLockItemFee__c'                           // アルソックロック料金	
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
            + ' FROM ProvisionalQuote__c'
            + ' WHERE DisinfectionItem__c    != NULL'
            + '    OR KeyExchangeFeeItem__c  != NULL'
            + '    OR ReliableSupportItem__c != NULL'
            + '    OR FShotItem__c           != NULL'
            + '    OR AlsokLockItem__c       != NULL'
        ;
        return Database.getQueryLocator(soql);   
    }

    // データ処理
    global void execute(Database.BatchableContext BC, List<ProvisionalQuote__c> provList) {

        // データ毎にコンバートを実施
        for (ProvisionalQuote__c prov: provList) {
            convert(prov);
        }

        // 一括更新
        SecureDML.secureUpdate(provList);
    }

    // 終了処理
    global void finish(Database.BatchableContext BC) {
    }

    //--------------------------------------privateメソッド----------------------------------------------------------------------------
    private void convert(ProvisionalQuote__c prov) {

        // 付帯商品配列を初期化
        List<ID> auxiliaryItemId = new ID[ITEM_SIZE];
        List<Decimal> auxiliaryItemFee = new Decimal[ITEM_SIZE];
        for (Integer j = 0; j < ITEM_SIZE; j++) {
            auxiliaryItemId[j] = null;
            auxiliaryItemFee[j] = null;
        }

        // 付帯商品情報を配列に格納
        Integer i = 0;
        if (prov.DisinfectionItem__c != null) {
            // 室内消毒商品がNULLではない場合
            auxiliaryItemId[i]  = prov.DisinfectionItem__c;
            auxiliaryItemFee[i] = prov.IndoorDisinfectionItemFee__c;
            i++;
        }
        if (prov.KeyExchangeFeeItem__c != null) {
            // 鍵交換費商品がNULLではない場合
            auxiliaryItemId[i]  = prov.KeyExchangeFeeItem__c;
            auxiliaryItemFee[i] = prov.AuxiliaryKeyExchangeFee__c;
            i++;
        }
        if (prov.ReliableSupportItem__c != null) {
            // 安心サポート商品がNULLではない場合
            auxiliaryItemId[i]  = prov.ReliableSupportItem__c;
            auxiliaryItemFee[i] = prov.ReliableSupportItemFee__c;
            i++;
        }
        if (prov.FShotItem__c != null) {
            // Fショット商品がNULLではない場合
            auxiliaryItemId[i]  = prov.FShotItem__c;
            auxiliaryItemFee[i] = prov.FShotItemFee__c;
            i++;
        }
        if (prov.AlsokLockItem__c != null) {
            // アルソックロック商品	がNULLではない場合
            auxiliaryItemId[i]  = prov.AlsokLockItem__c;
            auxiliaryItemFee[i] = prov.AlsokLockItemFee__c;
            i++;
        }

        // 仮見積データ変更
        for (Integer j = 1; j <= ITEM_SIZE; j++) {
            prov.put('AuxiliaryItem' + j + '__c', auxiliaryItemId[j-1]);
            prov.put('AuxiliaryItemFee' + j + '__c', auxiliaryItemFee[j-1]);
        }
    }
}