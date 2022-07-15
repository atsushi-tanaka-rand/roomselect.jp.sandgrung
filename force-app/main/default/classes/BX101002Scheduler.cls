/**
 *  データ容量削減_自動メンテナンススケジューラ
 **/
global with sharing class BX101002Scheduler implements Schedulable{
    private final Integer BATCH_SIZE = CommonConst.DATA_CAPACITY_MAINTENANCE_BATCHSIZE; //バッチサイズ
	global void execute(SchedulableContext ctx) {

		//バッチ実行
		BX101002Batch b = new BX101002Batch();
		Database.executeBatch(b, BATCH_SIZE);
	}
}