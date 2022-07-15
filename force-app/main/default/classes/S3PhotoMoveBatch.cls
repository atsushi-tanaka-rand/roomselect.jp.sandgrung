/**
 * S3の写真移動用バッチクラスです。
 * 指定した写真を移動します。
 **/
global with sharing class S3PhotoMoveBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    //※Database.AllowCallouts を宣言することで、100回までのコールアウトが可能になる

    /** 定数 */
    private static final String IS_S3FILEMOVE_BATCHPROCESSING = CommonConst.IS_S3FILEMOVE_BATCHPROCESSING; //システム変数　項目名

    // コンストラクタ
    public S3PhotoMoveBatch() {
    }

    // 実行
    global Database.QueryLocator start(Database.BatchableContext BC){
        String soql = '';
        soql += 'SELECT Id';
        soql += '     , FromPhotoFilePath__c';
        soql += '     , ToPhotoFilePath__c';
        soql += '     , BatchStatus__c';
        soql += '  FROM S3FileMove__c';
        soql += '  ORDER BY CreatedDate ';

        // execute実行
        return Database.getQueryLocator(soql);
    }

    
    //バッチサイズで指定されたレコード数単位で executeが呼び出される
    global void execute(Database.BatchableContext bc, List<S3FileMove__c> targetList) {
        try{
            List<String> fromPathList = new List<String>();
            List<String> toPathList   = new List<String>();

            // 移動リスト作成
            for (S3FileMove__c obj : targetList) {
                fromPathList.add(obj.FromPhotoFilePath__c);
                toPathList.add(obj.ToPhotoFilePath__c);
            }

            // メイン処理
            AmazonS3Util.callS3PhotoMoveNonDBUpdate(fromPathList, toPathList);        
            
            SecureDML.secureDelete(targetList);
            
        } catch(Exception e) {
            // エラーステータス更新
            updateBatchStatus(targetList,CommonConst.S3FILEMOVE_BATCHSTATUS_ERROR,e);
        }

    }

    // ステータスの更新(エラーの出力)
    private void updateBatchStatus(List<S3FileMove__c> targetList, String batchStatus,Exception e) {

        // 削除されなかった対象のデータをエラーとするため絞り込む
        Set<Id> S3FileMoveIdList = new Set<Id>();
        for (S3FileMove__c target : targetList) {
            S3FileMoveIdList.add(target.id);
        }
        List<S3FileMove__c> S3FileMoveErrList =[SELECT Id 
                                                FROM S3FileMove__c 
                                                WHERE ID IN :S3FileMoveIdList ];
        
        //更新用変数の宣言
        List<S3FileMove__c> updateList = new List<S3FileMove__c>();
        String errMsg = CommonConst.STRING_EMPTY;
        errMsg += 'Exception type caught:' + e.getTypeName() + CommonConst.BREAK_CODE;
        errMsg += 'Message:'               + e.getMessage() + CommonConst.BREAK_CODE;
        errMsg += 'Cause:'                 + e.getCause() + CommonConst.BREAK_CODE;
        errMsg += 'Line number:'           + e.getLineNumber() + CommonConst.BREAK_CODE;
        errMsg += 'getStackTraceString:'   + e.getStackTraceString() + CommonConst.BREAK_CODE;
        //エラーリストに追加
        for (S3FileMove__c target: S3FileMoveErrList) {
            S3FileMove__c updateData = new S3FileMove__c(
                Id = target.Id
                ,BatchStatus__c = batchStatus 
                ,BatchErrorContent__c = errMsg 
            );
            updateList.add(updateData);
        }
        //更新
        if (!updateList.isEmpty()) {
            SecureDML.secureUpdate(updateList);
        }
    }

    //バッチ処理の終了時に呼び出される
    //終了処理を実装する
    global void finish(Database.BatchableContext bc) {
        // 処理待ちのレコードを取得する
        String S3FILEMOVE_BATCHSTATUS_WAITING_PROCESSING = CommonConst.S3FILEMOVE_BATCHSTATUS_WAITING_PROCESSING;          // 処理待ち

        List<S3FileMove__c> S3FileMoveWaitingProcessList =[SELECT Id 
                                                FROM S3FileMove__c 
                                                WHERE BatchStatus__c = :S3FILEMOVE_BATCHSTATUS_WAITING_PROCESSING ];

        // execute実行
        if(S3FileMoveWaitingProcessList.size() > 0){
            // 処理待ちのデータがあれば再度バッチを動かす
            S3PhotoMoveBatch b = new S3PhotoMoveBatch();
            Database.executeBatch(b, 50);
        }else{
            // 対象が全て完了すれば変数オブジェクト更新
            SystemVariables__c sysConf;
            sysConf = [SELECT Id ,BooleanValue__c FROM SystemVariables__c  WHERE VariablesName__c = :IS_S3FILEMOVE_BATCHPROCESSING];
            sysConf.BooleanValue__c  = false;
            SecureDML.secureUpdate(sysConf);
        }

    }
}