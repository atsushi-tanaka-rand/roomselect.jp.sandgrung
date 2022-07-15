/**
 *  データ容量削減_閲覧履歴削除スケジューラ
 **/
global with sharing class BX101003Scheduler implements Schedulable{
	private final Integer BATCH_SIZE = CommonConst.DATA_CAPACITY_MAINTENANCE_BATCHSIZE; //バッチサイズ

	global void execute(SchedulableContext ctx) {

		//バッチ実行
		BX101003Batch b = new BX101003Batch();
		Database.executeBatch(b, BATCH_SIZE);
	}
}