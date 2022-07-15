// 建物コード履歴トリガハンドラテストクラス
@isTest
private class BD301006TriggerHandlerTest {
    
    //テストに使用するレコードを作成する
    @testSetup static void Setting() {

        // 建物
        Building__c building = new Building__c(
            Name = '建物1'
        );
        insert building;
    }

    // 建物コード履歴の登録値テスト
    @isTest static void registBuildingCdHistTest() {

        // 建物を取得
        Building__c building = [SELECT Id
                                FROM Building__c
                                WHERE Name = '建物1'];

        // 建物コード履歴を登録
        BuildingCodeHistory__c buildingCdHist = new BuildingCodeHistory__c (
            Building__c = building.Id
        );
        insert buildingCdHist;
        
        // 建物コード履歴を更新
        update buildingCdHist;
        
        // 建物コード履歴を削除
        delete buildingCdHist;
    }
}