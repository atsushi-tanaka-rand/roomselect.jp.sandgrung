//本会員差分トリガハンドラテスト
@isTest
public with sharing class BK101018TriggerHandlerTest {

    //テストに使用するレコードを作成する
    @testSetup static void Setting(){
        //システム設定を作成（暗号化に使用）
        SystemConfig__c s = new SystemConfig__c(
            ExampleIv__c = '4f63e8b490579073',
            HerokuSecretAccessKey__c = 'zF2SKTCj5CnR5TEhXhCLYBKE9x6a6xHN');
        insert s;

        



    }
    //本会員差分登録テスト
    @isTest static void InsertTest(){
        //本会員差分
        MemberDifference__c  memDiff= new MemberDifference__c(MemberId__c = 'ichi',
                CrudCd__c = 'C',
                LinkCd__c = 'HtoS',
                LastName__c = PortalUtil.encryption('一子'),
                FirstName__c = PortalUtil.encryption('一山'),
                LastNameKana__c = PortalUtil.encryption('イチコ'),
                FirstNameKana__c = PortalUtil.encryption('イチヤマ'),
                Tell__c = PortalUtil.encryption('111-1111'),
                Email__c = PortalUtil.encryption('email1@mail.com'),
                Password__c = PortalUtil.encryption('ichiyama'),
                Birthdate__c = Date.newInstance(1995,1,1),
                Gender__c = '女性',
                Blacklist__c = false,
                JoinDate__c = Date.newInstance(2020,1,1),
                MemberStatus__c = '入会');
        insert memDiff;
        
        List<Member__c> memList = [SELECT id,MemberId__c FROM Member__c WHERE FirstName__c = '一山'];
        //insertした本会員差分を元にした本会員が作成されている？
        system.assertEquals(true, ! memList.isEmpty() );
}
    //一応トリガのカバレッジ率あげ
    @isTest static void coverageUp(){
        MemberDifference__c  memDiff= new MemberDifference__c(MemberId__c = 'ichi',
        CrudCd__c = 'C',
        LinkCd__c = '',
        LastName__c = PortalUtil.encryption('一子'),
        FirstName__c = PortalUtil.encryption('一山'),
        LastNameKana__c = PortalUtil.encryption('イチコ'),
        FirstNameKana__c = PortalUtil.encryption('イチヤマ'),
        Tell__c = PortalUtil.encryption('111-1111'),
        Email__c = PortalUtil.encryption('email1@mail.com'),
        Password__c = PortalUtil.encryption('ichiyama'),
        Birthdate__c = Date.newInstance(1995,1,1),
        Gender__c = '女性',
        Blacklist__c = false,
        JoinDate__c = Date.newInstance(2020,1,1),
        MemberStatus__c = '入会');

        insert memDiff;

        update memDiff;
}

}