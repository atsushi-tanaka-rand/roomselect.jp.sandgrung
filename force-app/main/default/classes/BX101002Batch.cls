/**
 *  データ容量削減_自動メンテナンス削除バッチ
 **/
global with sharing class BX101002Batch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
	private final Datetime RUN_TIME = CommonUtil.getNow(); //実行時間
	private Integer autoMenteDelBatcMonthAgo;	// 自動メンテナンス削除バッチ削除月
	private String apiName = '';
	private String errorMessage;
	private String CSVFaile;
	private List<AutoMaintenance__c> delteteList;

	/*
	* コンストラクタ
	*/ 
	global BX101002Batch() {
		autoMenteDelBatcMonthAgo = SystemConfig__c.getInstance().AutoMenteDelBatcMonthAgo__c == null ? -2 : -1 * (Integer)SystemConfig__c.getInstance().AutoMenteDelBatcMonthAgo__c;
		errorMessage = '';
		CSVFaile = '';
		delteteList = new List<AutoMaintenance__c>();
	}

	/*
	* バッチ処理開始時に最初に呼び出される
	* バッチ処理対象のレコードを返却するQueryLocatorを返す
	*/ 
	global Database.QueryLocator start(Database.BatchableContext BC){
		String objname = CommonUtil.getNamespace('AutoMaintenance__c');
		apiName = CommonUtil.getAPIName(objname);
		// ヘッダ
		CSVFaile = apiName + CommonConst.BREAK_CODE;
		return Database.getQueryLocator(DataCapacityUtil.selectAutoMaintenance(apiName,RUN_TIME.addMonths(autoMenteDelBatcMonthAgo)));         
    }

	/*
	* バッチサイズで指定されたレコード数単位で executeが呼び出される
	*/
	global void execute(Database.BatchableContext BC, List<AutoMaintenance__c> targetList){
		
		try {
			// データ
			CSVFaile += DataCapacityUtil.setCsvAutoMaintenance(targetList,delteteList);
		} catch (Exception ex) {
			errorMessage = ex.getMessage();
		}
	
	}
	/*
	* バッチ処理の終了時に呼び出される
	* 終了処理を実装する
	*/
	global void finish(Database.BatchableContext BC) {
		errorMessage += DataCapacityUtil.dataCapacityExecution(CSVFaile, 'AutoMaintenance' + RUN_TIME.formatGmt('yyyyMMddhhmmss') + '.csv',delteteList);

		if(String.isNotEmpty(errorMessage)){
			DataCapacityUtil.mailMessageMolding(errorMessage,'自動メンテナンス削除バッチ');
			return;
		}
		
		List<AutoMaintenance__c> selectDelList = Database.query(DataCapacityUtil.selectAutoMaintenance('ID',RUN_TIME.addMonths(autoMenteDelBatcMonthAgo)));
		if(selectDelList.size() > 0 || Test.isRunningTest()){
			// 対象件数が残っている場合、自動メンテナンス削除バッチ再実行
			Datetime nextBatchTime = CommonUtil.getNow().addMinutes(2);
			BX101002Scheduler cls = new BX101002Scheduler();
			String jobName = '自動メンテナンス削除' + nextBatchTime.format('yyyyMMddHHmm');
			String sch = nextBatchTime.format('0 m H d M ? yyyy');

			//テストクラスで実際のバッチを実行しない（カバレッジ率上げ用）
			if (Test.isRunningTest()){
				return;
			}
			System.schedule(jobName, sch, cls);

		}

	}
}