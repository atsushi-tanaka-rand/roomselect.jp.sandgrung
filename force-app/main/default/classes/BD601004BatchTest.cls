//周辺情報取得バッチ テストクラス
@isTest
private class BD601004BatchTest {
    @TestSetup static void Setting(){
        // insert用のListを作成
        List<Building__c> insertBuildingList = new List<Building__c>();
        
        // 建物OBJに10件登録
        for(Integer i; i < 10; i++){
            Building__c addBuildimg = new  Building__c();
            
            addBuildimg.Longitude__c = 12;
            addBuildimg.Latitude__c  = 14;
            addBuildimg.IsFirstSurroundingImportFlag__c = true;
            insertBuildingList.add(addBuildimg);

        }

        insert insertBuildingList;
    }

    @isTest static void successTest(){
        
        BD601004Batch b = new BD601004Batch();
        Database.executeBatch(b, 3);

    }

        
}