//ポータルお気に入り物件差分トリガハンドラテスト
@istest
public with sharing class BK101021TriggerHandlerTest {
    //テストに使用するレコードを作成する
   @testSetup static void Setting(){

        //ポータルお気に入り物件レコード
        PortalFavoriteProperty__c portalRecord = new PortalFavoriteProperty__c(
            portalFavoritePropertId__c = 'okini1'                                  //ポータルお気に入り物件ID
            ,MemberId__c     = 'testID'                                            //会員ID
            ,PropertyCd__c   = 'bukkenCode'                                        //物件コード
            ,BrowsingDate__c = DateTime.newInstance(2020, 10, 31, 12, 0, 00)      //閲覧日時
            ,IsDeleted__c    = true                                                //削除
        );
        insert portalRecord;
   }

   //ポータルお気に入り物件差分登録テスト

   @istest static void InsertTest(){
       //セットアップで作ったポータルお気に入り物件レコードのIDを取得
       PortalFavoriteProperty__c portalRecord = [SELECT id FROM PortalFavoriteProperty__c];

       //ポータルお気に入り物件差分レコードを作成
       PortalFavoritePropertyDifference__c portalDiff = new PortalFavoritePropertyDifference__c(
            portalFavoritePropertId__c = 'okini1'                                  //ポータルお気に入り物件ID
            ,MemberId__c     = 'testID'                                            //会員ID
            ,PropertyCd__c   = 'bukkenCode1'                                        //物件コード
            ,BrowsingDate__c = DateTime.newInstance(2020, 10, 31, 12, 0, 00)      //閲覧日時
            ,IsDeleted__c    = true                                                //削除
            ,CrudCd__c = 'U'                                                       //クラッドコード

       );
       insert portalDiff;
       //もう1度ポータルお気に入り物件レコードを取得
       PortalFavoriteProperty__c portalRecord2 = [SELECT PropertyCd__c FROM PortalFavoriteProperty__c];
       //insertしたポータルお気に入り物件差分がポータルお気に入り物件レコードを更新しているか？
       system.assertEquals('bukkenCode1', portalRecord2.PropertyCd__c);
   }


   //トリガのカバレッジ率あげ
   @istest  static void coverageUp() {
       //セットアップで作ったポータルお気に入り物件レコードのIDを取得
       PortalFavoriteProperty__c portalRecord = [SELECT id FROM PortalFavoriteProperty__c];

        //ポータルお気に入り物件差分レコードを作成
        PortalFavoritePropertyDifference__c portalDiff = new PortalFavoritePropertyDifference__c(
            portalFavoritePropertId__c = 'okini1'                                  //ポータルお気に入り物件ID
            ,MemberId__c     = 'testID'                                            //会員ID
            ,PropertyCd__c   = 'bukkenCode1'                                        //物件コード
            ,BrowsingDate__c = DateTime.newInstance(2020, 10, 31, 12, 0, 00)      //閲覧日時
            ,IsDeleted__c    = true                                                //削除
            ,CrudCd__c = 'U'                                                       //クラッドコード

       );

       //ポータルお気に入り物件差分をinsert(トリガハンドラが動いて、ポータルお気に入り物件が更新される)
       insert portalDiff;        
       update portalDiff;
       delete portalDiff;
       
   }








}