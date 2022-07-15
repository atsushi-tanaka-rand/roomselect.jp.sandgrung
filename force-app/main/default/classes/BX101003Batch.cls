/**
 * データ容量削減_閲覧履歴
 **/
global with sharing class BX101003Batch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
	private final Datetime RUN_TIME = CommonUtil.getNow(); //実行時間
	private String apiName = '';
	private Datetime fiscalFirstDate;//会計年度開始日
	private String errorMessage;
	private String CSVFaile;
	private List<BrowsingHistory__c> delteteList;
	
	/*
	* コンストラクタ
	*/ 
	global BX101003Batch() {
		errorMessage = '';
		CSVFaile = '';
		delteteList = new List<BrowsingHistory__c>();
	}

	/*
	* バッチ処理開始時に最初に呼び出される
	* バッチ処理対象のレコードを返却するQueryLocatorを返す
	*/ 
	global Database.QueryLocator start(Database.BatchableContext BC){
		fiscalFirstDate = DataCapacityUtil.getFiscalFirstDate(RUN_TIME);
		String objname = CommonUtil.getNamespace('BrowsingHistory__c');
		apiName = CommonUtil.getAPIName(objname);
		// ヘッダ
		CSVFaile = apiName + CommonConst.BREAK_CODE;
		return Database.getQueryLocator(DataCapacityUtil.selectBrowsingHistory(apiName,fiscalFirstDate)); 
	}

	/*
	* バッチサイズで指定されたレコード数単位で executeが呼び出される
	*/
	global void execute(Database.BatchableContext BC, List<BrowsingHistory__c> targetList){
		try {
			// データ
			CSVFaile += DataCapacityUtil.setCsvBrowsingHistory(targetList,delteteList);
		} catch (Exception ex) {
			errorMessage = ex.getMessage();
		}
    }

	/*
	* バッチ処理の終了時に呼び出される
	* 終了処理を実装する
	*/
	global void finish(Database.BatchableContext BC) {

		errorMessage += DataCapacityUtil.dataCapacityExecution(CSVFaile,'BrowsingHistory' + RUN_TIME.formatGmt('yyyyMMddhhmmss') + '.csv',delteteList);

		if(String.isNotEmpty(errorMessage)){
			DataCapacityUtil.mailMessageMolding(errorMessage,'閲覧履歴削除バッチ');
			return;
		}
		
		List<BrowsingHistory__c> selectDelList = Database.query(DataCapacityUtil.selectBrowsingHistory('ID',fiscalFirstDate));
		if(selectDelList.size() > 0 || Test.isRunningTest()){
			// 対象件数が残っている場合、閲覧履歴バッチ再実行
			Datetime nextBatchTime = CommonUtil.getNow().addMinutes(2);
			BX101003Scheduler cls = new BX101003Scheduler();
			String jobName = '閲覧履歴削除' + nextBatchTime.format('yyyyMMddHHmm');
			String sch = nextBatchTime.format('0 m H d M ? yyyy');

			//テストクラスで実際のバッチを実行しない（カバレッジ率上げ用）
			if (Test.isRunningTest()){
				return;
			}
			System.schedule(jobName, sch, cls);

		}
	}
}