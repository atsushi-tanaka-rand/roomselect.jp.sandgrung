// 物件コード履歴トリガハンドラテストクラス
@isTest
private class BD301007TriggerHandlerTest {
    
    //テストに使用するレコードを作成する
    @testSetup static void Setting() {

        // 建物
        Building__c building = new Building__c(
            Name = '建物1'
        );
        insert building;

        // 物件
        Property__c property = new Property__c(
            Name          = '物件1'
            , Building__c = building.Id
        );
        insert property;
    }

    // 物件コード履歴の登録値テスト
    @isTest static void registPropertyCdHistTest() {

        // 物件を取得
        Property__c property = [SELECT Id
                                FROM Property__c
                                WHERE Name = '物件1'];

        // 物件コード履歴を登録
        PropertyCodeHistory__c propertyCdHist = new PropertyCodeHistory__c (
            Property__c = property.Id
        );
        insert propertyCdHist;

        // 物件コード履歴を更新
        update propertyCdHist;

        // 物件コード履歴を削除
        delete propertyCdHist;
    }
}