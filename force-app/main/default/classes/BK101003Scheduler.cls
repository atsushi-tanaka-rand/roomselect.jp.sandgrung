/**
 * 来店受付メンテナンスバッチ　スケジューラ
 **/
global class BK101003Scheduler implements Schedulable {

    private final Integer BATCH_SIZE = SystemConfig__c.getInstance().AppointmentReceiptBatchSize__c.intValue(); //バッチサイズ
    
    global void execute(SchedulableContext ctx) {
        //来店受付開始日時、終了時刻30分前　のカスタム設定に不備がなければバッチ実行
        String st = SystemConfig__c.getInstance().AppointmentReceiptStartTime__c;
        String et = SystemConfig__c.getInstance().AppointmentReceiptEndTime30minAgo__c;
        Time stTime = Time.newInstance(Integer.valueOf(st.left(2)), Integer.valueOf(st.right(2)), 0, 0);
        Time etTime = Time.newInstance(Integer.valueOf(et.left(2)), Integer.valueOf(et.right(2)), 0, 0);

        if (stTime <= etTime && etTime <= Time.newInstance(22, 00, 0, 0)){
            //店受付開始日時 < 来店受付終了時刻30分前 <= 22時00分　の場合
            //バッチ実行
            BK101003Batch b = new BK101003Batch();
            Database.executeBatch(b, BATCH_SIZE);
        }
    }
}