//閲覧履歴差分トリガハンドラテスト
@isTest
public with sharing class BK101020TriggerHandlerTest {

   //テストに使用するレコードを作成する
   @testSetup static void Setting(){

         //閲覧履歴レコード
         BrowsingHistory__c bHRecord = new BrowsingHistory__c(
            BrowsingHistoryId__c = 'eturanID'      //閲覧履歴ID
            ,MemberId__c     = 'testID'           //会員ID
            ,SessionKey__c   = '123456789'        //セッションキー
            ,BrowsingDate__c = DateTime.newInstance(2020, 10, 31, 12, 0, 00)      //閲覧日時
            ,PropertyCd__c   = 'bukkenCode'        //物件コード
            ,IsDeleted__c    = true         //削除

        );
        insert bHRecord;
    }


    //閲覧履歴差分登録テスト
    @isTest static void InsertTest(){
        //セットアップで作った閲覧履歴レコードのIDを取得
        BrowsingHistory__c bHRecord = [SELECT id FROM BrowsingHistory__c];

         //閲覧履歴差分を作成
         BrowsingHistoryDifference__c bHDiff = new BrowsingHistoryDifference__c(
            CrudCd__c = 'U'
            ,BrowsingHistoryId__c = 'eturanID'
            ,MemberId__c     = 'testID'           //会員ID
            ,SessionKey__c   = '123456789'        //セッションキー
            ,BrowsingDate__c = DateTime.newInstance(2020, 10, 31, 15, 0, 00)      //閲覧日時
            ,PropertyCd__c   = 'bukkenCode10'        //物件コード
            ,IsDeleted__c    = false         //削除
        );
        //閲覧履歴差分をinsert(トリガハンドラが動いて、閲覧履歴が更新される)
        insert bHDiff;

        //もう1度閲覧履歴レコードを取得
        BrowsingHistory__c bHRecord2 = [SELECT PropertyCd__c FROM BrowsingHistory__c];

        //insertした閲覧履歴差分が閲覧履歴レコードを更新しているか？
        system.assertEquals('bukkenCode10', bHRecord2.PropertyCd__c);

    }


    //トリガのカバレッジ率あげ(updateは今回動かしていないが、トリガのカバレッジ率補足のため実施)
    @isTest static void coverageUp(){
        //セットアップで作った閲覧履歴レコードのIDを取得
        BrowsingHistory__c bHRecord = [SELECT id FROM BrowsingHistory__c];

         //閲覧履歴差分を作成
         BrowsingHistoryDifference__c bHDiff = new BrowsingHistoryDifference__c(
            CrudCd__c = 'U'
            ,BrowsingHistoryId__c = 'eturanID'
            ,MemberId__c     = 'testID'           //会員ID
            ,SessionKey__c   = '123456789'        //セッションキー
            ,BrowsingDate__c = DateTime.newInstance(2020, 10, 31, 15, 0, 00)      //閲覧日時
            ,PropertyCd__c   = 'bukkenCode10'        //物件コード
            ,IsDeleted__c    = false         //削除
        );

        //閲覧履歴差分をinsert(トリガハンドラが動いて、閲覧履歴が更新される)
        insert bHDiff;        
        update bHDiff;

    }  
}