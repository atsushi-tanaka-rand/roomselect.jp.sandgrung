/**
 * データ容量削減_物件メンテナンス履歴取得_居住中であり、月前の自社管理修正日
 **/
global with sharing class BX101001Batch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
	private final Datetime RUN_TIME = CommonUtil.getNow(); //実行時間
	private Datetime searchDateTime; //
	private Integer propMenteHistoryDelBatcMonthAgo; 		// 物件メンテナンス履歴削除バッチ削除月
	private Integer propMenteHistoryPostingEndDelMonthAgo;	// 物件メンテナンス履歴掲載終了削除バッチ削除月
	private String apiName = '';
	private String errorMessage;
	private String CSVFaile;
	private id propertyId;
	private List<PropertyMaintenanceHistory__c> delteteList;

	/*
	* コンストラクタ
	*/ 
	global BX101001Batch(Id ctx) {
		propMenteHistoryDelBatcMonthAgo       = SystemConfig__c.getInstance().PropMenteHistoryDelBatcMonthAgo__c       == null ? -2 : -1 * (Integer)SystemConfig__c.getInstance().PropMenteHistoryDelBatcMonthAgo__c;
		propMenteHistoryPostingEndDelMonthAgo = SystemConfig__c.getInstance().PropMenteHistoryPostingEndDelMonthAgo__c == null ? -1 : -1 * (Integer)SystemConfig__c.getInstance().PropMenteHistoryPostingEndDelMonthAgo__c;
		searchDateTime = DataCapacityUtil.getSearchDateTime(ctx,RUN_TIME.addMonths(propMenteHistoryDelBatcMonthAgo));
		CSVFaile = '';
		errorMessage = '';
		propertyId = null;
		delteteList = new List<PropertyMaintenanceHistory__c>();
	}

	/*
	* バッチ処理開始時に最初に呼び出される
	* バッチ処理対象のレコードを返却するQueryLocatorを返す
	*/ 
	global Database.QueryLocator start(Database.BatchableContext BC){
		String objname = CommonUtil.getNamespace('PropertyMaintenanceHistory__c');
		apiName = CommonUtil.getAPIName(objname);
		// ヘッダ生成
		CSVFaile = apiName + CommonConst.BREAK_CODE;
		return Database.getQueryLocator(DataCapacityUtil.selectPropertyMaintenanceHistory(apiName,searchDateTime));   
    }

	/*
	* バッチサイズで指定されたレコード数単位で executeが呼び出される
	*/
	global void execute(Database.BatchableContext BC, List<PropertyMaintenanceHistory__c> targetList){
		
		try {
			
			// メインデータループ
			for(PropertyMaintenanceHistory__c PropertyHistory : targetList){
				if (PropertyHistory.Property__c != propertyId || propertyId == null){
					propertyId = PropertyHistory.Property__c;
					continue;
				}
				PropertyMaintenanceHistory__c delteteData = new PropertyMaintenanceHistory__c();
				delteteData.id = PropertyHistory.id;
				if(searchDateTime < PropertyHistory.Property__r.OwnCompanyManageModDate__c || searchDateTime == RUN_TIME.addMonths(propMenteHistoryDelBatcMonthAgo)){
					searchDateTime = PropertyHistory.Property__r.OwnCompanyManageModDate__c;
				}
				CSVFaile += DataCapacityUtil.setCsvPropertyMaintenanceData(PropertyHistory);
				delteteList.add(delteteData);

			}
		} catch (Exception ex) {
			errorMessage += ex.getMessage();
			system.debug(ex);
		}
    }

	/*
	* バッチ処理の終了時に呼び出される
	* 終了処理を実装する
	*/
	global void finish(Database.BatchableContext BC) {
		errorMessage += DataCapacityUtil.dataCapacityExecution(CSVFaile, 'PropertyMaintenanceHistory' + RUN_TIME.formatGmt('yyyyMMddhhmmss') + '.csv',delteteList);

		// エラーメール送信
		if(String.isNotEmpty(errorMessage)){
			DataCapacityUtil.mailMessageMolding(errorMessage,'物件メンテナンス履歴削除バッチ');
			return;
		}

		List<PropertyMaintenanceHistory__c> selectDelList = Database.query(DataCapacityUtil.selectPropertyMaintenanceHistory('ID',searchDateTime));
		if(selectDelList.size() > 0 && delteteList.size() > 0){
			// 対象件数が残っている場合、物件メンテナンス履歴削除スケジューラの再実行（居住中であり、2か月前の自社管理修正日）
			Datetime nextBatchTime = CommonUtil.getNow().addMinutes(3);
			BX101001Scheduler cls = new BX101001Scheduler();
			String jobName = '物件メンテナンス履歴削除' + nextBatchTime.format('yyyyMMddHHmm');
			List<Property__c> ownCompanyManageModDateList = Database.query(DataCapacityUtil.selectPropertyOwnCompanyManageModDate(RUN_TIME.addMonths(propMenteHistoryDelBatcMonthAgo)));
			if(ownCompanyManageModDateList.size() > 0 ){
				// 現在日付から2か月前で存在している最新の自社管理修正日と検索日を比較
				// 検索日が過去であれば最新の自社管理修正日をセット
				// そうでなければ検索日をセットする
				if(ownCompanyManageModDateList[0].OwnCompanyManageModDate__c > searchDateTime){
					jobName += '_' + ownCompanyManageModDateList[0].OwnCompanyManageModDate__c.format('yyyyMMddHHmmss') ;
				}else{
					jobName += '_' + searchDateTime.format('yyyyMMddHHmmss') ;
				}
			}			
			
			String sch = nextBatchTime.format('0 m H d M ? yyyy');
			//テストクラスで実際のバッチを実行しない（カバレッジ率上げ用）
			if (Test.isRunningTest()){
				return;
			}
			System.schedule(jobName, sch, cls);

		// 物件メンテナンス履歴掲載終了削除バッチ実行フラグがTrueのみ実行
		}else if(SystemConfig__c.getInstance().PropMenteHistoryPostingEndDelBatchFlg__c){
			// 対象件数が残っていない場合、物件メンテナンス履歴削除スケジューラの生成（掲載終了の重複）
			Datetime nextBatchTime = CommonUtil.getNow().addMinutes(3);
			BX101001Scheduler_2 cls = new BX101001Scheduler_2();
			String jobName = '物件メンテナンス履歴削除掲載終了_' + RUN_TIME.addMonths(propMenteHistoryPostingEndDelMonthAgo).format('yyyyMMddHHmmss');
			String sch = nextBatchTime.format('0 m H d M ? yyyy');

			//テストクラスで実際のバッチを実行しない（カバレッジ率上げ用）
			if (Test.isRunningTest()){
				return;
			}

			System.schedule(jobName, sch, cls);
		}
	}
}