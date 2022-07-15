//退去予定更新バッチ　テストクラス
@isTest 
private class BD301001BatchTest {    
    //テストに使用するレコードを作成する
    @testSetup static void Setting(){

        
        //データ作成　システム設定 バッチサイズ
        SystemConfig__c sysconf = new SystemConfig__c(
            ScheduledToLeaveUpdateBatchSize__c = 200
        );
        insert sysconf;

        Building__c buil = new Building__c(
            Name = 'testBuil'
        );
        insert buil;
        Property__c pro = new Property__c(
            Building__c =buil.id,
            Name = '退去予定更新',
            LiveStatus__c = '退去予定',
            DeliveryType__c = '期日指定',
            DeliveryYear__c = '2000',
            DeliveryMonth__c = '1月',
            DeliveryDay__c = '10',
            OwnCompanyManageModDate__c = System.now().addmonths(-1),
            Webpublishing__c = CommonConst.PROPERTY_WEBPUBLISHING_EXISTS
        );
        insert  pro;
    }
    
    @isTest static void successTest(){
        
        //バッチ実行
        BD301001Batch b = new BD301001Batch();
        Integer BATCH_SIZE = SystemConfig__c.getInstance().ScheduledToLeaveUpdateBatchSize__c.intValue(); //バッチサイズ
        Database.executeBatch(b, BATCH_SIZE);
        
    }
}