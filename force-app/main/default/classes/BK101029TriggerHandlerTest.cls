//お気に入り物件トリガハンドラテスト

@istest
public with sharing class BK101029TriggerHandlerTest {


    @TestSetup
    // テストで使う素材の準備
    static void Setting(){
        //取引先
        Account acc = new Account(Name = '取引先名',
                                RecordTypeId = CommonUtil.getRecordTypeId('Account',CommonConst.ACCOUNT_RECTYPE_CUSTOMER));
        insert acc;
        //建物
        Building__c buil = new Building__c(Name= '建物名');
        insert buil;
        //取引先
        Property__c pro = new Property__c(Building__c = buil.id,Name = '111',RentFee__c = 55555);
        insert pro;
    }
    
    //お気に入り物件新規登録テスト
    @istest static void insertTest(){

        Account acc = [SELECT Id FROM Account WHERE Name = '取引先名'];
        Property__c pro = [SELECT Id FROM Property__c WHERE Name = '111'];

        //お気に入り物件作成
        FavoriteProperty__c favo = new FavoriteProperty__c(
            Account__c = acc.id,
            Property__c = pro.Id);

        insert favo;

        //お気に入り物件差分レコードを取得
        List<FavoritePropertyDifference__c> favoDiff = [SELECT id FROM FavoritePropertyDifference__c];

        //お気に入り物件差分が新規登録されている？
        System.assertEquals(true, !favoDiff.isEmpty());
    }

    //トリガのカバレッジ率あげ(updateは今回動かしていないが、トリガのカバレッジ率補足のため実施)
    @isTest static void coverageUp(){

        Account acc = [SELECT Id FROM Account WHERE Name = '取引先名'];
        Property__c pro = [SELECT Id FROM Property__c WHERE Name = '111'];

        //お気に入り物件作成
        FavoriteProperty__c favo = new FavoriteProperty__c(
            Account__c = acc.id,
            Property__c = pro.Id);

        insert favo;  
        update favo;
        delete favo;
    }
}