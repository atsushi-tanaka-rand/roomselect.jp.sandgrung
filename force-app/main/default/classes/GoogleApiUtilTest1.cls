//周辺施設情報取得（座標設定）のテストクラス
@ isTest
private class GoogleApiUtilTest1 {

    @TestSetup
    // テストに利用するListを用意する。
    static void Setting(){

        // コンフィグ値を設定
        SystemConfig__c settings = new SystemConfig__c();
        settings.SearchStationRange__c = 5000;
        insert settings;
    }


    // 座標設定メソッドの動作確認テスト
    // ※GoogleAPIから座標情報を正常に取得できた場合のテスト
    @isTest static void checkSetCoordinate(){

        // 必要なデータの設定
        List<Building__c> targetList = new List<Building__c>();

        //テストNo.1のデータセット
        // 緯度：設定あり
        // 経度：設定あり
        // 期待値：GoogleApiの取得対象外となること
        Building__c addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'テストNo.1';
        addBuilding.Latitude__c = 123.456;
        addBuilding.Longitude__c = 12.3456;
        targetList.add(addBuilding);

        //テストNo.2のデータセット
        // 緯度：設定あり
        // 経度：設定なし
        // 期待値：GoogleApiの取得結果で緯度、経度ともに上書きされること
        addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'テストNo.2';
        addBuilding.Latitude__c = 123.456;
        targetList.add(addBuilding);

        //テストNo.3のデータセット
        // 緯度：設定なし
        // 経度：設定あり
        // 期待値：GoogleApiの取得結果で緯度、経度ともに上書きされること
        addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'テストNo.3';
        addBuilding.Longitude__c = 12.3456;
        targetList.add(addBuilding);

        //テストNo.4のデータセット
        // 緯度：設定なし
        // 経度：設定なし
        // 期待値：GoogleApiの取得結果で緯度、経度ともに上書きされること
        addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'テストNo.4';
        targetList.add(addBuilding);

        // コールアウトクラスのモッククラスをセット
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest1OkHttpRequestMock());
        Test.startTest();
        GoogleApiUtil.setCoordinate(targetList);
        Test.stopTest();

        // 取得結果の確認
        for(Building__c building : targetList){

            if(building.Name == 'テストNo.1') {
                // 設定値と変わらないことを確認
                System.assertEquals(123.456, building.Latitude__c);
                System.assertEquals(12.3456, building.Longitude__c);
            }
            else {
                // GoogleApiの設定値に上書きされていることを確認
                System.assertEquals(111.222, building.Latitude__c);
                System.assertEquals(33.4444, building.Longitude__c);
            }
        }
    }

    // 座標設定メソッドの動作確認テスト
    // ※GoogleAPIから座標情報を取得できない場合のテスト
    @isTest static void checkSetCoordinateNoGet(){

        // 必要なデータの設定
        List<Building__c> targetList = new List<Building__c>();

        //テストNo.1のデータセット
        // 緯度：設定あり
        // 経度：設定あり
        // 期待値：GoogleApiの取得対象外となること
        Building__c addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'テストNo.1';
        addBuilding.Latitude__c = 123.456;
        addBuilding.Longitude__c = 12.3456;
        targetList.add(addBuilding);

        //テストNo.2のデータセット
        // 緯度：設定あり
        // 経度：設定なし
        // 期待値：GoogleApiの取得結果で緯度、経度ともに上書きされないこと
        addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'テストNo.2';
        addBuilding.Latitude__c = 123.456;
        targetList.add(addBuilding);

        //テストNo.3のデータセット
        // 緯度：設定なし
        // 経度：設定あり
        // 期待値：GoogleApiの取得結果で緯度、経度ともに上書きされないこと
        addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'テストNo.3';
        addBuilding.Longitude__c = 12.3456;
        targetList.add(addBuilding);

        //テストNo.4のデータセット
        // 緯度：設定なし
        // 経度：設定なし
        // 期待値：GoogleApiの取得結果で緯度、経度ともに上書きされないこと
        addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'テストNo.4';
        targetList.add(addBuilding);

        // コールアウトクラスのモッククラスをセット
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest1NgHttpRequestMock());
        Test.startTest();
        GoogleApiUtil.setCoordinate(targetList);
        Test.stopTest();

        // 取得結果の確認
        for(Building__c building : targetList){

            if(building.Name == 'テストNo.1') {
                // 設定値と変わらないことを確認
                System.assertEquals(123.456, building.Latitude__c);
                System.assertEquals(12.3456, building.Longitude__c);
            }
            else if(building.Name == 'テストNo.2') {
                // 設定値と変わらないことを確認
                System.assertEquals(123.456, building.Latitude__c);
                System.assertEquals(null, building.Longitude__c);
            }
            else if(building.Name == 'テストNo.3') {
                // 設定値と変わらないことを確認
                System.assertEquals(null, building.Latitude__c);
                System.assertEquals(12.3456, building.Longitude__c);
            }
            else if(building.Name == 'テストNo.4') {
                // 設定値と変わらないことを確認
                System.assertEquals(null, building.Latitude__c);
                System.assertEquals(null, building.Longitude__c);
            }
        }
    }
}