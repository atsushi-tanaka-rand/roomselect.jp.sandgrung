/**
 * データ容量削減_物件メンテナンス履歴スケジューラ_居住中であり、2か月前の自社管理修正日
 **/
global with sharing class BX101001Scheduler implements Schedulable{
	private final Integer BATCH_SIZE = CommonConst.DATA_CAPACITY_MAINTENANCE_BATCHSIZE; //バッチサイズ

	global void execute(SchedulableContext ctx) {

		//バッチ実行
		BX101001Batch b = new BX101001Batch(ctx.getTriggerId());
		Database.executeBatch(b, BATCH_SIZE);
	}
}