//メール時間指定送信バッチ　テストクラス
@isTest 
private class BA102001BatchTest {
    
    //テストに使用するレコードを作成する
    @testSetup static void Setting(){

        
        //データ作成　システム設定 バッチサイズ
        SystemConfig__c sysconf = new SystemConfig__c(
            MailTimeSpecificationSendingBatchSize__c = 200
        );
        insert sysconf;
        
        //データ作成　対応レコード
        Correspond__c c = new Correspond__c();
        insert c;
        
        //データ作成　メール時間指定送信
        List<MailTimeSpecificationSending__c> mailList = new List<MailTimeSpecificationSending__c>();
        
        //バッチ対応のために、10通(複数)作成
        for (Integer i =1; i <=10; i++) {
            MailTimeSpecificationSending__c mail = new MailTimeSpecificationSending__c();
            mail.Subject__c = 'testSubject';
            mail.Body__c = 'testBody';
            mail.To__c   = 'aaa@aaa.com';
            mail.From__c = 'bbb@bbb.com';
            mail.SendingDateTime__c = DateTime.newInstance(2000,1,1,1,1,1);
            mailList.add(mail);
        }
        mailList[0].Correspond__c = c.Id; //一つだけ対応を設定
        insert mailList;

        // 添付ファイル
        Attachment testAttachment1 = new Attachment(
            ParentId = mailList[0].Id
            ,Name = 'テスト添付ファイル１'
            ,Body = Blob.valueOf('0000000000000000')
        );
        insert testAttachment1;
        

    }
    
    //メール送信テスト
    @isTest static void successTest(){
        
        //バッチ実行
        BA102001Batch b = new BA102001Batch();
        Integer BATCH_SIZE = SystemConfig__c.getInstance().MailTimeSpecificationSendingBatchSize__c.intValue(); //バッチサイズ
        Database.executeBatch(b, BATCH_SIZE);
        
    }
    
    //メール送信テスト（エラー要素含む）
    @isTest static void errorMailTest(){
        
        //エラーメールを作成する
        MailTimeSpecificationSending__c mail = new MailTimeSpecificationSending__c();
        mail.Subject__c = 'testSubject';
        mail.Body__c = 'testBody';
        mail.To__c   = 'aaaaa';//メールの形式をなしていないのでエラー
        mail.From__c = 'bbbbb';//メールの形式をなしていないのでエラー
        mail.SendingDateTime__c = DateTime.newInstance(2000,1,1,1,1,1);
        insert mail;
        
        //バッチ実行
        BA102001Batch b = new BA102001Batch();
        Integer BATCH_SIZE = SystemConfig__c.getInstance().MailTimeSpecificationSendingBatchSize__c.intValue(); //バッチサイズ
        Database.executeBatch(b, BATCH_SIZE);
        
    }
    
    
}