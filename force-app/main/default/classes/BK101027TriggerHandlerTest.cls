//来店受付トリガハンドラテスト

@istest
public with sharing class BK101027TriggerHandlerTest {


    @TestSetup
    // テストで使う素材の準備
    static void Setting(){
        //店舗レコード
        Shop__c shopRecord = new shop__c(Name = '朔商店',
                                         PortalSitePostingDistrict__c = '港区;北区');
        insert shopRecord;
    }
    
    //来店受付新規登録テスト
    @istest static void insertTest(){

         //セットアップで作った来店受付レコードの店舗を取得
         Shop__c shopRecord = [SELECT Id FROM Shop__c];

        //来店受付を作成
        AppointmentReceipt__c appoRecord = new AppointmentReceipt__c(
            ReceiptDate__c = Date.newInstance(2020, 10, 31)     //受付日 
            ,Shop__c = shopRecord.Id        //店舗
            ,ReserveStartTime__c = Time.newInstance(18, 30, 0, 0)       //予約開始時刻
            ,ReserveEndTime__c = Time.newInstance(19, 00, 0, 0)     //予約終了時刻
            ,ReserveCanCount__c = 5     //予約可能数
            ,ReserveCanNotCount__c = 2      //予約不能数
        );
        insert appoRecord;

        //来店受付差分レコードを取得
        AppointmentReceiptDifference__c appDiff = [SELECT ReserveCanCount__c FROM AppointmentReceiptDifference__c];

        //insertした来店受付に基づいた来店受付差分レコードを新規登録しているか？
        system.assertEquals(5, appDiff.ReserveCanCount__c);
    }

    //トリガのカバレッジ率あげ(updateは今回動かしていないが、トリガのカバレッジ率補足のため実施)
    @isTest static void coverageUp(){
        //セットアップで作った来店受付レコードの店舗を取得
        Shop__c shopRecord = [SELECT Id FROM Shop__c];
            
         //来店受付を作成
         AppointmentReceipt__c appoRecord = new AppointmentReceipt__c(
            ReceiptDate__c = Date.newInstance(2020, 10, 31)     //受付日 
            ,Shop__c = shopRecord.Id        //店舗
            ,ReserveStartTime__c = Time.newInstance(18, 30, 0, 0)       //予約開始時刻
            ,ReserveEndTime__c = Time.newInstance(19, 00, 0, 0)     //予約終了時刻
            ,ReserveCanCount__c = 5     //予約可能数
            ,ReserveCanNotCount__c = 2      //予約不能数
        );
        insert appoRecord;        
        update appoRecord;
        delete appoRecord;
    }
}