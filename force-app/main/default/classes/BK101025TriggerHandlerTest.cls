//検索履歴差分トリガハンドラテスト
@isTest
public with sharing class BK101025TriggerHandlerTest {

   //テストに使用するレコードを作成する
   @testSetup static void Setting(){

        //検索履歴レコード
        SearchHistory__c sHRecord = new SearchHistory__c(
            SearchHistoryId__c = 'sHID'      //検索履歴ID（検索履歴オブジェクトで必須項目）
            ,MemberId__c    =   'kaiinID'       //会員ID（検索履歴オブジェクトで必須項目）
            ,SearchDate__c   = DateTime.newInstance(2020, 10, 31, 12, 0, 00)      //検索日時（検索履歴オブジェクトで必須項目）
            ,SaveDate__c = DateTime.newInstance(2020, 10, 31, 12, 0, 00)      //閲覧日時
            ,TrainRouteStation__c   =   '大阪環状線大阪駅'            //沿線・駅
        );
        insert sHRecord;
    }

    //検索履歴差分登録テスト
    @isTest static void InsertTest(){
        //セットアップで作った検索履歴レコードのIDを取得
        SearchHistory__c sHRecord = [SELECT id FROM SearchHistory__c];

        //検索履歴差分を作成
        SearchHistoryDifference__c sHDiff = new SearchHistoryDifference__c(
            CrudCd__c = 'U'
            ,SearchHistoryId__c = 'sHID'      //検索履歴ID（検索履歴オブジェクトで必須項目）
            ,MemberId__c    =   'kaiinID'       //会員ID（検索履歴オブジェクトで必須項目）
            ,SearchDate__c   = DateTime.newInstance(2020, 10, 30, 12, 0, 00)      //検索日時（検索履歴オブジェクトで必須項目）
            ,SaveDate__c = DateTime.newInstance(2020, 10, 30, 12, 0, 00)      //閲覧日時
            ,TrainRouteStation__c   =   '大阪環状線福島駅'            //沿線・駅
        );
        //検索履歴差分をinsert(トリガハンドラが動いて、検索履歴が更新される)
        insert sHDiff;

        //もう1度検索履歴レコードを取得
        SearchHistory__c sHRecord2 = [SELECT TrainRouteStation__c FROM SearchHistory__c];

        //insertした検索履歴差分が検索履歴レコードを更新しているか？
        system.assertEquals('大阪環状線福島駅', sHRecord2.TrainRouteStation__c);

        }

    //トリガのカバレッジ率あげ(updateは今回動かしていないが、トリガのカバレッジ率補足のため実施)
    @isTest static void coverageUp(){
        //セットアップで作った検索履歴レコードのIDを取得
        SearchHistory__c sHRecord = [SELECT id FROM SearchHistory__c];
        

        //検索履歴差分を作成
        SearchHistoryDifference__c sHDiff = new SearchHistoryDifference__c(
            CrudCd__c = 'U'
            ,SearchHistoryId__c = 'sHID'      //検索履歴ID（検索履歴オブジェクトで必須項目）
            ,MemberId__c    =   'kaiinID'       //会員ID（検索履歴オブジェクトで必須項目）
            ,SearchDate__c   = DateTime.newInstance(2020, 10, 31, 12, 0, 00)      //検索日時（検索履歴オブジェクトで必須項目）
            ,SaveDate__c = DateTime.newInstance(2020, 10, 31, 12, 0, 00)      //閲覧日時
            ,TrainRouteStation__c   =   '大阪環状線福島駅'            //沿線・駅
        );

        //検索履歴差分をinsert(トリガハンドラが動いて、検索履歴が更新される)
        insert sHDiff;        
        update sHDiff;

    }
}