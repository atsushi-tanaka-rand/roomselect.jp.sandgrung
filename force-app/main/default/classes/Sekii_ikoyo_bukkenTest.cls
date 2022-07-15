//sekii 移行用バッチ　テストクラス
@isTest 
private class Sekii_ikoyo_bukkenTest {
    
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
            Name = 'テスト物件'
        );
        insert pro;



    }
    
    @isTest static void successTest(){
        
        //バッチ実行
        Sekii_ikoyo_bukken b = new Sekii_ikoyo_bukken();
        Database.executeBatch(b, 200);
        
    }
}