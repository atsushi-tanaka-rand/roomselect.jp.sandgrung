//紹介メール情報メンテナンスバッチ　テストクラス
@isTest 
private class BK101035BatchTest {   
    //テストに使用するレコードを作成する
    @testSetup static void Setting(){
        //データ作成　システム設定 バッチサイズ
        SystemConfig__c sysconf = new SystemConfig__c(
            IntroductionMailInformationBatchSize__c = 200,
            UseAuthority_Portal__c = true
        );
        insert sysconf;

        //取引先
        Account acc = new Account (Name = '配信メール太郎', IntroMailInfoPursuitCount__c = 10);
        insert acc;

        //対応
        Correspond__c corr = new Correspond__c(AccountId__c = acc.id);
        insert corr;

        //紹介メール情報
        IntroductionMailInformation__c introMail = new IntroductionMailInformation__c(Account__c = acc.id,Correspond__c = corr.id);
        insert introMail;
    }
    
    @isTest static void successTest(){
        //バッチ実行
        BK101035Batch b = new BK101035Batch();
        Integer BATCH_SIZE = SystemConfig__c.getInstance().IntroductionMailInformationBatchSize__c.intValue(); //バッチサイズ
        Database.executeBatch(b, BATCH_SIZE);

    }

}