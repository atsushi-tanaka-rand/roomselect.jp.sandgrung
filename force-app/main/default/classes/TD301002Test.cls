/* *
* 退去予定一覧のテスト
*/
@ isTest
private class TD301002Test {
    //テストに使用するレコードを作成する
    @testSetup static void Setting(){
        // 建物テストデータ作成
        Building__c building = new Building__c(
                    Name = 'テスト建物',
                    District__c ='北区',
                    State__c = '愛知県',
                    City__c = '名古屋市退去予定町',
                    Street__c = '1-1');    
        insert building;
        
        // 物件テストデータ作成
        Property__c property = new Property__c(
                    Name = 'テスト物件',
                    Building__c = building.Id,
                    LiveStatus__c = '退去予定',
                    DeliveryType__c = '期日指定',
                    DeliveryYear__c = '2020',
                    DeliveryMonth__c = '1月',
                    DeliveryDay__c = '1');

        Property__c property2 = new Property__c(
                    Name = 'テスト物件2',
                    Building__c = building.Id,
                    LiveStatus__c = '退去予定',
                    DeliveryType__c = '期日指定',
                    DeliveryYear__c = '2020',
                    DeliveryMonth__c = '1月',
                    DeliveryDay__c = '1');
        List<Property__c> proList = new List<Property__c>{property,property2};
        insert proList;
    }
    //カスタム設定の作成
    static SystemConfig__c LiveStatusMaxCountCustomSettings(Decimal maxCount){
        SystemConfig__c settings = new SystemConfig__c();
        settings.LeaveScheduleMaxCount__c = maxCount;//検索上限
        insert settings;
        
        return settings;
    }

    //帳票出力
    @isTest 
    static void outputTest() {
        LiveStatusMaxCountCustomSettings(1000);//検索上限
        
        //パラメータ設定
        PageReference pageRef = Page.TD301002View;
        Test.setCurrentPage(pageRef);
        
        //コントローラー作成
        TD301002Controller TD301002Controller = new TD301002Controller();

        //「エラーフラグ」がfalseに設定されている？
        system.assertEquals(TD301002Controller.isOpenError, false);
        //「出力内容」が設定されている？
        system.assertnotEquals(TD301002Controller.propertyList.size(), 0);
    }
    //カバレッジ率あげ
    @isTest 
    static void coverageUp() {
        LiveStatusMaxCountCustomSettings(1000);//検索上限
        
        //パラメータ設定
        PageReference pageRef = Page.TD301002View;
        Test.setCurrentPage(pageRef);
        
        //コントローラー作成
        TD301002Controller TD301002Controller = new TD301002Controller();

        TD301002Controller.getXmlVer();
        TD301002Controller.getXmlapp();
    }
    
    
    
}