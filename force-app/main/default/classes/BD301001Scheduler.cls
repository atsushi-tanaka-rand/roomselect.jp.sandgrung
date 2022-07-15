/**
 * 退去予定更新バッチ　スケジューラ
 **/
global class BD301001Scheduler implements Schedulable {

    private final Integer BATCH_SIZE = SystemConfig__c.getInstance().ScheduledToLeaveUpdateBatchSize__c.intValue(); //バッチサイズ
    
    global void execute(SchedulableContext ctx) {
  
        //バッチ実行
        BD301001Batch b = new BD301001Batch();
        Database.executeBatch(b, BATCH_SIZE);
    }
  }