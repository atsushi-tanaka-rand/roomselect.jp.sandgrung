//紹介メール情報トリガハンドラテスト

@istest
public with sharing class BK101028TriggerHandlerTest {


    @TestSetup
    // テストで使う素材の準備
    static void Setting(){
        //システム設定を作成（暗号化に使用）
        SystemConfig__c s = new SystemConfig__c(
            HerokuSecretAccessKey__c = 'zF2SKTCj5CnR5TEhXhCLYBKE9x6a6xHN',
            UseAuthority_Portal__c = true,
            ExampleIv__c = '4f63e8b490579073'
            );
        insert s;        
        //取引先
        Account acc = new Account(Name = '取引先名',
                                IntroMailInfoPursuitCount__c = 2,
                                RecordTypeId = CommonUtil.getRecordTypeId('Account',CommonConst.ACCOUNT_RECTYPE_CUSTOMER));
        insert acc;
        //対応
        Correspond__c corr = new Correspond__c(AccountId__c = acc.id);
        insert corr;
    }
    
    //紹介メール情報新規登録テスト
    @istest static void insertTest(){

        Account acc = [SELECT Id FROM Account WHERE Name = '取引先名'];
        Correspond__c corr = [SELECT Id FROM Correspond__c WHERE AccountId__c = :acc.id];

        //紹介メール情報作成
        IntroductionMailInformation__c introMail = new IntroductionMailInformation__c(
            Account__c = acc.id,
            Correspond__c = corr.Id,
            Email__c = 'mail@aaa');

        insert introMail;

        //紹介メール情報差分レコードを取得
        List<IntroductionMailInformationDifference__c> introMailDiff = [SELECT id FROM IntroductionMailInformationDifference__c];

        //紹介メール情報差分が新規登録されている？
        System.assertEquals(true, !introMailDiff.isEmpty());
    }

    // ▼ 2021.11.30 LINE連携対応より、追加
    /**
     * LINE送信テスト
     */
    @isTest static void isSendLineTest() {

        // 取引先
        Account account = [SELECT Id
                           FROM Account
                           WHERE Name = '取引先名'
                          ];

        // 紹介メール情報の登録
        IntroductionMailInformation__c introMail = new IntroductionMailInformation__c(
            Account__c      = account.id
            , isSendLine__c = true
        );
        insert introMail;

        // 紹介メール情報差分の取得
        IntroductionMailInformationDifference__c introMailDiff = [SELECT isSendLine__c
                                                                  FROM IntroductionMailInformationDifference__c
                                                                 ];

        // 結果確認
        System.assertEquals(introMailDiff.isSendLine__c
                            , true
                            , '紹介メール情報差分_LINE送信');
    }
    // ▲ 2021.11.30 

    //トリガのカバレッジ率あげ(updateは今回動かしていないが、トリガのカバレッジ率補足のため実施)
    @isTest static void coverageUp(){

        Account acc = [SELECT Id FROM Account WHERE Name = '取引先名'];
        Correspond__c corr = [SELECT Id FROM Correspond__c WHERE AccountId__c = :acc.id];

        //紹介メール情報作成
        IntroductionMailInformation__c introMail = new IntroductionMailInformation__c(
            Account__c = acc.id,
            Correspond__c = corr.Id,
            Email__c = 'mail@aaa');

        insert introMail;
        update introMail;
        delete introMail;
    }
}