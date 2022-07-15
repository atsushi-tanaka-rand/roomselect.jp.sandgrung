/**
 * 紹介メール情報メンテナンスバッチ　スケジューラ
 **/
global class BK101035Scheduler implements Schedulable {

    private final Integer BATCH_SIZE = SystemConfig__c.getInstance().IntroductionMailInformationBatchSize__c.intValue(); //バッチサイズ
    
    global void execute(SchedulableContext ctx) {
  
        //バッチ実行
        BK101035Batch b = new BK101035Batch();
        Database.executeBatch(b, BATCH_SIZE);
    }
  }