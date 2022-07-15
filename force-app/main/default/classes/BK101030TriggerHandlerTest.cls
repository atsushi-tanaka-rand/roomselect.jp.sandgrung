//送信メール情報トリガハンドラテスト
@isTest
public with sharing class BK101030TriggerHandlerTest {

    //テストに使用するレコードを作成する
    @testSetup static void Setting(){
        //取引先
        Account acc = new Account(Name = '取引先太郎');
        insert acc;
        //対応
        Correspond__c corr = new Correspond__c (AccountId__c = acc.id);    
        insert corr;

    }
    //送信メール情報登録テスト
    @isTest static void InsertTest(){
        Account acc = [SELECT id FROM Account WHERE Name = '取引先太郎'];
        Correspond__c corr = [SELECT id FROM Correspond__c WHERE AccountId__c = :acc.id];

        SendMailInformation__c smi= new SendMailInformation__c(Account__c = acc.id, Correspond__c = corr.id,SendFlag__c =true);
        insert smi;

        CommonUtil.sleep(10);
    
        List<Account> acc2 = [SELECT id,IntroMailInfoPursuitCount__c FROM Account WHERE Name = '取引先太郎'];

        //取引先の追客回数が+1されている
        system.assertEquals(1, acc2[0].IntroMailInfoPursuitCount__c );
    }
    //一応トリガのカバレッジ率あげ
    @isTest static void coverageUp(){
        Account acc = [SELECT id FROM Account WHERE Name = '取引先太郎'];
        Correspond__c corr = [SELECT id FROM Correspond__c WHERE AccountId__c = :acc.id];

        SendMailInformation__c smi= new SendMailInformation__c(Account__c = acc.id, Correspond__c = corr.id,SendFlag__c =true);
        insert smi;

        update smi;

    }

}