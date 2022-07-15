//建物物件差分作成バッチ　テストクラス
@isTest 
private class BuildingPropertyDifferenceCreateTest {    
    //テストに使用するレコードを作成する
    @testSetup static void Setting(){
        //建物
        Building__c buil = new Building__c(
            Name = 'テスト建物'
        );
        insert buil;
        
        //物件
        Property__c pro = new Property__c(
            Building__c = buil.Id,
            Name = 'テスト物件'
        );
        insert pro;

        //建物物件差分作成用物件
        BuildingPropertyDifferenceCreateTarget__c createTarget = new BuildingPropertyDifferenceCreateTarget__c(
            PropertyId__c = pro.Id
        );
        insert createTarget;

    }
    
    @isTest static void successTest(){
        
        //バッチ実行
        BuildingPropertyDifferenceCreateBatch b = new BuildingPropertyDifferenceCreateBatch();
        Database.executeBatch(b, 200);
        
    }
}