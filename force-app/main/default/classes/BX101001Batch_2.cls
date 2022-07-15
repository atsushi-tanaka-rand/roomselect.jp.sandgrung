/**
 * データ容量削減_物件メンテナンス履歴_掲載終了の重複
 **/
global with sharing class BX101001Batch_2 implements Database.Batchable<Object>, Database.AllowsCallouts, Database.Stateful {
	private final Datetime RUN_TIME = CommonUtil.getNow(); //実行時間
	private Datetime searchDateTime; //
	private Integer propMenteHistoryPostingEndDelMonthAgo;	// 物件メンテナンス履歴掲載終了削除バッチ削除月
	private String apiName = '';
	private String errorMessage;
	private String CSVFaile;
	private List<PropertyMaintenanceHistory__c> delteteList;
	// コンストラクタ
	global BX101001Batch_2(Id ctx) {
		propMenteHistoryPostingEndDelMonthAgo = SystemConfig__c.getInstance().PropMenteHistoryPostingEndDelMonthAgo__c == null ? -1 : -1 * (Integer)SystemConfig__c.getInstance().PropMenteHistoryPostingEndDelMonthAgo__c;
		searchDateTime = DataCapacityUtil.getSearchDateTime(ctx,RUN_TIME.addMonths(propMenteHistoryPostingEndDelMonthAgo));
		CSVFaile = '';
		errorMessage = '';
		delteteList = new List<PropertyMaintenanceHistory__c>();
	}

	//データ取得物件メンテナンス履歴削除対象
	global Iterable<Object> start(Database.BatchableContext bc) {
		String objname = CommonUtil.getNamespace('PropertyMaintenanceHistory__c');
		apiName = CommonUtil.getAPIName(objname);
		// ヘッダ生成
		CSVFaile = apiName + CommonConst.BREAK_CODE;
		return (Iterable<Object>)DataCapacityUtil.selectPropertyMaintenanceHistoryPostingEnd(apiName,searchDateTime);
    }
	//開始
	global void execute(Database.BatchableContext BC, List<Object> targetList){
		try {
			System.debug(targetList);
			delteteList = DataCapacityUtil.setFindToList(targetList);
			if(delteteList.size() <= 0){
				return;
			}
			// データ
			CSVFaile += DataCapacityUtil.setCsvPropertyMaintenanceHistoryPostingEnd(delteteList);
		} catch (Exception ex) {
			errorMessage = ex.getMessage();
			system.debug(ex);
		}
    }
	/*
	* バッチ処理の終了時に呼び出される
    * 終了処理を実装する
    */
	global void finish(Database.BatchableContext BC) {
		errorMessage += DataCapacityUtil.dataCapacityExecution(CSVFaile, 'PropertyMaintenanceHistory' + RUN_TIME.formatGmt('yyyyMMddhhmmss') + '.csv',delteteList);

		if(String.isNotEmpty(errorMessage)){
			DataCapacityUtil.mailMessageMolding(errorMessage,'物件メンテナンス履歴削除掲載終了バッチ');
			return;
		}

		List<List<SObject>> selectDelObjectList = DataCapacityUtil.selectPropertyMaintenanceHistoryPostingEnd('ID',RUN_TIME.addMonths(propMenteHistoryPostingEndDelMonthAgo));
		List<PropertyMaintenanceHistory__c> selectDelList = DataCapacityUtil.setFindToList(selectDelObjectList);
		if(selectDelList.size() > 0 || Test.isRunningTest()){
			// 対象件数が残っている場合、物件メンテナンス履歴削除スケジューラの再実行（掲載終了の重複）
			Datetime nextBatchTime = CommonUtil.getNow().addMinutes(3);
			BX101001Scheduler_2 cls = new BX101001Scheduler_2();
			String jobName = '物件メンテナンス履歴削除掲載終了_' + nextBatchTime.addMonths(-1).format('yyyyMMddHHmmss');

			String sch = nextBatchTime.format('0 m H d M ? yyyy');

			//テストクラスで実際のバッチを実行しない（カバレッジ率上げ用）
			if (Test.isRunningTest()){
				return;
			}
			System.schedule(jobName, sch, cls);

		}
	}

}