//来店受付メンテナンスバッチ　テストクラス
@isTest 
private class BK101009BatchTest {   
    //テストに使用するレコードを作成する
    @testSetup static void Setting(){

        //データ作成　システム設定 バッチサイズ
        SystemConfig__c sysconf = new SystemConfig__c(
            ScheduledToLeaveUpdateBatchSize__c = 100
        );
        insert sysconf;
    }
    
    @isTest static void successTest(){
        //来店受付差分
        AppointmentReceiptDifference__c arDiff = new AppointmentReceiptDifference__c(
            CrudCd__c = 'U',
            LinkCd__c = 'HtoS'
        );
        insert arDiff;

        //バッチ実行
        BK101009Batch b = new BK101009Batch();
        Integer BATCH_SIZE = SystemConfig__c.getInstance().ScheduledToLeaveUpdateBatchSize__c.intValue(); //バッチサイズ
        Database.executeBatch(b, BATCH_SIZE);


    }

}