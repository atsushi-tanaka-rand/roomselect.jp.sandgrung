//自動メンテナンス作成バッチ
global with sharing class BD601005Batch_3 implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    //※Database.AllowCallouts を宣言することで、100回までのコールアウトが可能になる

    //バッチ共通変数
    global List<t_auto_maintenance_difference__c> errorTargetList; //エラー用の自動メンテナンス差分一覧 finishで使用する
    global Map<Id, String> errorMessageMap;                        //エラー用の自動メンテナンス差分ごとの、メッセージ内容

	/** テストクラス用変数 */
	@TestVisible static Boolean isExceptionTest = false;

    // コンストラクタ
    global BD601005Batch_3 () {
    }
    
    //バッチ処理開始時に最初に呼び出される
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        //バッチ共通変数初期化
        errorTargetList = new List<t_auto_maintenance_difference__c>();
        errorMessageMap = new Map<Id, String>();


        //SQL用 全項目取得String作成
        List<String> itemList = New List<String>();
        Map<String, Schema.sObjectField> omap = t_auto_maintenance_difference__c.SObjecttype.getDescribe().fields.getMap();
        for(String s: omap.keySet()) {
            itemList.add(s);
        }
        String items =  String.join(itemList, ',');
        
        //SQL用変数設定
        final String STATUS_1 = CommonConst.AUTOMAINTEDIFF_BATCHSTATUS_1; //バッチステータス
        
        //SQL作成
        String soql ='';
        soql += ' SELECT ' + items; //全項目
        soql += ' FROM t_auto_maintenance_difference__c';   //自動メンテナンス差分
        soql += ' WHERE BatchStatus__c = :STATUS_1';        //バッチステータスが1のものに限る
        soql += ' AND ExcecuteBatchNo__c = 3';   // 実行バッチ番号
        // soql += ' ORDER BY CreatedDate';
        // soql += ' LIMIT ' + Integer.valueOf(SystemConfig__c.getInstance().AutoMaintenanceBatchProcessMaxCount__c);   // 処理上限設定
        
        return Database.getQueryLocator(soql);
    }
    
    
    //バッチサイズで指定されたレコード数単位で executeが呼び出される
    global void execute(Database.BatchableContext bc, List<t_auto_maintenance_difference__c> targetList) {
        
        //強制終了
        if (targetList.size() >= 2) { //HTTPコールアウトの上限数の都合で、1件ずつしか処理不可
            
            //エラーメッセージ
            String errorMessage = '自動メンテナンス作成バッチは、2件以上同時に行うことはできません';
            
            //ビジネスロジックエクセプション発行
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(errorMessage);
            throw ex;
        }
        
        try {

            //メイン処理
            AutoMaintenanceUtil.processAutoMaintenanceBatch1(targetList);
            
            
        } catch (Exception e) {
            String errMsg = CommonConst.STRING_EMPTY;
            if (e instanceof BusinessLogicException){//ビジネスロジックExceptionの場合
                errMsg = e.getMessage();
            } else {
                errMsg += 'Exception type caught:' + e.getTypeName() + CommonConst.BREAK_CODE;
                errMsg += 'Message:'               + e.getMessage() + CommonConst.BREAK_CODE;
                errMsg += 'Cause:'                 + e.getCause() + CommonConst.BREAK_CODE;
                errMsg += 'Line number:'           + e.getLineNumber() + CommonConst.BREAK_CODE;
                errMsg += 'getStackTraceString:'   + e.getStackTraceString() + CommonConst.BREAK_CODE;
            }
            //エラーリストに追加(複数件の場合、全て同じエラーになることに注意)
            for (t_auto_maintenance_difference__c target: targetList) {
                errorTargetList.add(target);
                errorMessageMap.put(target.Id, errMsg);
            }

            // ロールバック ※SavePointが空でない時のみ
            // 自動メンテナンスに表示する為、エラーメールは飛ばさない！
            if (AutoMaintenanceUtil.savePoint != null) {
                Database.rollback(AutoMaintenanceUtil.savePoint);
            }   
        }
    }
    
    
	//バッチ処理の終了時に呼び出される
	global void finish(Database.BatchableContext bc) {
		//▼ No.614 異常終了時の処理を追加
		try {
			// テストクラスの例外処理
			// ※異なる例外を発生させる為、例外をスロー
			if (isExceptionTest && Test.isRunningTest()) {
				throw new BusinessLogicException();
			}
			
			//エラー対象のステータス更新
			AutoMaintenanceUtil.updateBatchStatus(errorTargetList, CommonConst.AUTOMAINTEDIFF_BATCHSTATUS_E1); //自動メンテナンス差分はステータス：-1で更新する
		
			//エラー対象の自動メンテナンス作成
			AutoMaintenanceUtil.insertErrorAutoMaintenance(errorTargetList, errorMessageMap); 
		
			//バッチ2呼び出し
			BD601005Batch2_3 batch = new BD601005Batch2_3();
			Database.executeBatch(batch, 1);
		} catch (Exception e) {
			// システム変数オブジェクト更新
			AutoMaintenanceUtil.chengeSystemVariablesFlg(CommonConst.IS_AUTOMAINTENANCE_BATCHPROCESSING3);
			
		}
		//▲ No.614 異常終了時の処理を追加
	}
	//*******************privateメソッド************************
    
    
}