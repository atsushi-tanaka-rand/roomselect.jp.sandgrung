/**
 *  データ容量削減_物件メンテナンス履歴スケジューラ_掲載終了の重複
 **/
global with sharing class BX101001Scheduler_2 implements Schedulable{
	private final Integer BATCH_SIZE = CommonConst.DATA_CAPACITY_MAINTENANCE_BATCHSIZE; //バッチサイズ

	global void execute(SchedulableContext ctx) {

		//バッチ実行
		BX101001Batch_2 b = new BX101001Batch_2(ctx.getTriggerId());
		Database.executeBatch(b, BATCH_SIZE);
	}
}