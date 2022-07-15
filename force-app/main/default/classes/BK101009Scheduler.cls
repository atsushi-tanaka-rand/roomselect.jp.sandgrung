/**
 * 来店受付差分バッチ　スケジューラ
 **/
global class BK101009Scheduler implements Schedulable {

    private final Integer BATCH_SIZE = SystemConfig__c.getInstance().ScheduledToLeaveUpdateBatchSize__c.intValue(); //バッチサイズ
    
    global void execute(SchedulableContext ctx) {
  
        //バッチ実行
        BK101009Batch b = new BK101009Batch();
        Database.executeBatch(b, BATCH_SIZE);
    }
  }