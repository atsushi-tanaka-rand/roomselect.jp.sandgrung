/**
 * RS移行(反響累計)
 **/
global with sharing class BX001003Batch implements Database.Batchable<sObject> {

    global BX001003Batch() {
    }

    // データ取得
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String soql =''
            + 'SELECT ID'                                       // カスタムオブジェクトID
            + ', AuxiliaryIndoorDisinfectionFee__c'             // 付帯室内消毒料
            + ', AuxiliaryKeyExchangeFee__c'                    // 付帯鍵交換費
            + ', AuxiliaryReliableSupportFee__c'                // 付帯安心サポート料
            + ', AuxiliaryFShotFee__c'                          // 付帯Fショット料
            + ', AuxiliaryAlsokLockFee__c'                      // 付帯アルソックロック料
            + ' FROM EchoTotal__c'
            + ' WHERE AuxiliaryIndoorDisinfectionFee__c     != NULL'
            + '    OR AuxiliaryKeyExchangeFee__c            != NULL'
            + '    OR AuxiliaryReliableSupportFee__c        != NULL'
            + '    OR AuxiliaryFShotFee__c                  != NULL'
            + '    OR AuxiliaryAlsokLockFee__c              != NULL'
        ;
        return Database.getQueryLocator(soql);
    }

    // データ処理
    global void execute(Database.BatchableContext BC, List<EchoTotal__c> ectoList) {
        // 付帯商品反響累計の登録
        List<AuxiliaryItemEchoTotal__c> insAuxiEchoList = createChild(ectoList);
        if (!insAuxiEchoList.isEmpty()) {
            SecureDML.secureInsert(insAuxiEchoList);
        }
    }

    // 終了処理
    global void finish(Database.BatchableContext BC) {
    }

    //--------------------------------------privateメソッド----------------------------------------------------------------------------
    // 付帯商品反響累計の作成
    private List<AuxiliaryItemEchoTotal__c> createChild(List<EchoTotal__c> ectoList) {
        List<AuxiliaryItemEchoTotal__c> childList = new List<AuxiliaryItemEchoTotal__c>();

        for (EchoTotal__c et: ectoList) {
            // 付帯商品情報を配列に格納
            if (et.AuxiliaryIndoorDisinfectionFee__c != null && et.AuxiliaryIndoorDisinfectionFee__c != 0) {
                // 付帯室内消毒料がNULLではない場合
                childList.add(new AuxiliaryItemEchoTotal__c(
                    EchoTotal__c           = et.Id                                      // 反響累計
                    , AuxiliaryItemType__c = '消毒'                                     // 付帯商品種別
                    , AuxiliaryItemFee__c  = et.AuxiliaryIndoorDisinfectionFee__c       // 付帯商品料
                ));
            }
            if (et.AuxiliaryKeyExchangeFee__c != null && et.AuxiliaryKeyExchangeFee__c != 0) {
                // 付帯鍵交換費がNULLではない場合
                childList.add(new AuxiliaryItemEchoTotal__c(
                    EchoTotal__c           = et.Id                                      // 反響累計
                    , AuxiliaryItemType__c = '鍵交換'                                   // 付帯商品種別
                    , AuxiliaryItemFee__c  = et.AuxiliaryKeyExchangeFee__c              // 付帯商品料
                ));
            }
            if (et.AuxiliaryReliableSupportFee__c != null && et.AuxiliaryReliableSupportFee__c != 0) {
                // 付帯安心サポート料がNULLではない場合
                childList.add(new AuxiliaryItemEchoTotal__c(
                    EchoTotal__c           = et.Id                                      // 反響累計
                    , AuxiliaryItemType__c = '安心サポート'                             // 付帯商品種別
                    , AuxiliaryItemFee__c  = et.AuxiliaryReliableSupportFee__c          // 付帯商品料
                ));
            }
            if (et.AuxiliaryFShotFee__c != null && et.AuxiliaryFShotFee__c != 0) {
                // 付帯Fショット料がNULLではない場合
                childList.add(new AuxiliaryItemEchoTotal__c(
                    EchoTotal__c           = et.Id                                      // 反響累計
                    , AuxiliaryItemType__c = 'Fショット'                                // 付帯商品種別
                    , AuxiliaryItemFee__c  = et.AuxiliaryFShotFee__c                    // 付帯商品料
                ));
            }
            if (et.AuxiliaryAlsokLockFee__c != null && et.AuxiliaryAlsokLockFee__c != 0) {
                // 付帯アルソックロック料がNULLではない場合
                childList.add(new AuxiliaryItemEchoTotal__c(
                    EchoTotal__c           = et.Id                                      // 反響累計
                    , AuxiliaryItemType__c = 'アルソック'                               // 付帯商品種別
                    , AuxiliaryItemFee__c  = et.AuxiliaryAlsokLockFee__c                // 付帯商品料
                ));
            }
        }

        return childList;
    }

}