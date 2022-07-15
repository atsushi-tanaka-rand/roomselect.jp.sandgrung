/**
 * 時間指定メール送信バッチ　スケジューラ
 **/
global class BA102001Scheduler implements Schedulable {

  private final Integer BATCH_SIZE = SystemConfig__c.getInstance().MailTimeSpecificationSendingBatchSize__c.intValue(); //バッチサイズ
  
  global void execute(SchedulableContext ctx) {

      //バッチ実行
      BA102001Batch b = new BA102001Batch();
      Database.executeBatch(b, BATCH_SIZE);
  }
}