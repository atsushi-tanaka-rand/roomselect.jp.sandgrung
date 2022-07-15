// 自動メンテナンス作成バッチ（写真移動）
global with sharing class BD601005Batch2_5 implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    //※Database.AllowCallouts を宣言することで、100回までのコールアウトが可能になる

    //バッチ共通変数
    global List<t_auto_maintenance_difference__c> errorTargetList = new List<t_auto_maintenance_difference__c>(); //エラー用の自動メンテナンス差分一覧 finishで使用する
    global Map<Id, String> errorMessageMap                        = new Map<Id, String>();                        //エラー用の自動メンテナンス差分ごとの、メッセージ内容

    /** 定数 */
    private static final String IS_AUTOMAINTENANCE_BATCHPROCESSING5 = CommonConst.IS_AUTOMAINTENANCE_BATCHPROCESSING5; //システム変数　項目名

    // コンストラクタ
    public BD601005Batch2_5 () {
    }

    //バッチ処理開始時に最初に呼び出される
    //バッチ処理対象のレコードを返却するQueryLocatorを返す
    global Database.QueryLocator start(Database.BatchableContext BC){

      //自動メンテナンス差分のSQL用 全項目取得
        List<String> itemList = New List<String>();
        Map<String, Schema.sObjectField> omap = t_auto_maintenance_difference__c.SObjecttype.getDescribe().fields.getMap();

        for(String s: omap.keySet()) {
            itemList.add(s);
        }
        String items =  String.join(itemList, ',');

        // SQOL用変数設定
        final String STATUS_2 = CommonConst.AUTOMAINTEDIFF_BATCHSTATUS_2;

        // SOQL作成
        String soql ='';
        soql += 'SELECT ' + items;  //全項目
        soql += ' FROM t_auto_maintenance_difference__c';    //自動メンテナンス差分
        soql += ' WHERE BatchStatus__c = :STATUS_2';         //バッチステータスが2のものに限る
        soql += ' AND ExcecuteBatchNo__c = 5';   // 実行バッチ番号

        // execute実行
        return Database.getQueryLocator(soql);
    }

    //バッチサイズで指定されたレコード数単位で executeが呼び出される
    global void execute(Database.BatchableContext bc, List<t_auto_maintenance_difference__c> targetList) {

        // 強制終了
        if (targetList.size() >= 2) {
            //エラーメッセージ
            String errorMessage = '自動メンテナンス作成バッチは、2件以上同時に行うことはできません';
            
            //ビジネスロジックエクセプション発行
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(errorMessage);
            throw ex;
        }

        try {
            // メイン処理
            AutoMaintenanceUtil.processAutoMaintenanceBatch2(targetList);
        } catch(Exception e) {
            String errMsg = CommonConst.STRING_EMPTY;
            errMsg += 'Exception type caught:' + e.getTypeName() + CommonConst.BREAK_CODE;
            errMsg += 'Message:'               + e.getMessage() + CommonConst.BREAK_CODE;
            errMsg += 'Cause:'                 + e.getCause() + CommonConst.BREAK_CODE;
            errMsg += 'Line number:'           + e.getLineNumber() + CommonConst.BREAK_CODE;
            errMsg += 'getStackTraceString:'   + e.getStackTraceString() + CommonConst.BREAK_CODE;
            //エラーリストに追加(複数件の場合、全て同じエラーになることに注意)
            for (t_auto_maintenance_difference__c target: targetList) {
                errorTargetList.add(target);
                errorMessageMap.put(target.Id, errMsg);
            }
        }
    }

	//バッチ処理の終了時に呼び出される
	//終了処理を実装する
	global void finish(Database.BatchableContext bc) {
		//▼ No.614 異常、正常時にシステム変数を変更する。
		try {
			//エラー対象のステータス更新
			if (errorTargetList.size() > 0) {
				AutoMaintenanceUtil.updateBatchStatus(errorTargetList, CommonConst.AUTOMAINTEDIFF_BATCHSTATUS_E2); //自動メンテナンス差分はステータス：-2で更新する
			} 
			
			//エラー対象の自動メンテナンス作成
			AutoMaintenanceUtil.insertErrorAutoMaintenance(errorTargetList, errorMessageMap);
		}finally {
			// システム変数オブジェクト更新
			AutoMaintenanceUtil.chengeSystemVariablesFlg(IS_AUTOMAINTENANCE_BATCHPROCESSING5);

		}
		//▲ No.614 異常、正常時にシステム変数を変更する。
	}
}