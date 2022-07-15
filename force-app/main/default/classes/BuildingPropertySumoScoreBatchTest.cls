//スーモスコア自動更新バッチ　テストクラス
@isTest 
private class BuildingPropertySumoScoreBatchTest {    
    //テストに使用するレコードを作成する
    @testSetup static void Setting(){
        //建物
        Building__c buil = new Building__c(
            Name = 'テスト建物'
        );
        insert buil;
        
        //物件
        Property__c pro = new Property__c(
            Building__c = buil.id,
            Name = 'テスト物件',
            LiveStatus__c = '空室'
        );
        insert pro;

        //物件写真
        PropertyPhoto__c  proPhoto= new PropertyPhoto__c(
            Property__c = pro.id
        );
        insert proPhoto;
        
        //建物写真
        BuildingPhoto__c builPhoto = new BuildingPhoto__c(
            Building__c = buil.id
        );
        insert builPhoto;


    }
    
    @isTest static void successTest(){
        
        //バッチ実行
        BuildingPropertySumoScoreBatch b = new BuildingPropertySumoScoreBatch();
        Database.executeBatch(b, 200);
        
    }
}