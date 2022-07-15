//周辺施設情報取得（周辺施設）のテストクラス
@ isTest
private class GoogleApiUtilTest6 {

    @TestSetup
    // テストに利用するListを用意する。
    static void Setting(){

        // コンフィグ値を設定
        SystemConfig__c settings = new SystemConfig__c();
        settings.SearchStationRange__c = 5;
        settings.SurroundingBatchProcessCount__c = 5;
        insert settings;

        // 路線を設定
        TrainRoute__c trainRoute = new TrainRoute__c();
        trainRoute.Name = 'テスト路線';
        insert trainRoute;
    }

    // １件で正常に処理されるパターン（住所あり）
    @isTest static void checkOtherTestInput1Ok(){
        System.debug('-------------１件で正常に処理されるテストパターン（住所あり）-------------');

        // 必要なデータの設定
        List<Building__c> targetList = new List<Building__c>();

        // 建物データ増産
        Building__c addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'データ１';
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);

        // コールアウトクラスのモッククラスをセット
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest6OkHttpRequestMock());
        Test.startTest();
        GoogleApiUtil.getPeripheralInformation(targetList);
        Test.stopTest();

        // 取得結果の確認
        for(Building__c building : targetList){
            System.debug('建物名：'+building.Name);
            System.debug('緯度：'+building.Latitude__c);
            System.debug('経度：'+building.Longitude__c);
        }
    }

       // ２件で正常に処理されるパターン（住所あり）
       @isTest static void checkOtherTestInput2Ok(){
        System.debug('-------------２件で正常に処理されるテストパターン（住所あり）-------------');

        // 必要なデータの設定
        List<Building__c> targetList = new List<Building__c>();

        // 建物データ増産
        Building__c addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'データ１';
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);

        addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'データ２';
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);

        // コールアウトクラスのモッククラスをセット
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest6OkHttpRequestMock());
        Test.startTest();
        GoogleApiUtil.getPeripheralInformation(targetList);
        Test.stopTest();

        // 取得結果の確認
        for(Building__c building : targetList){
            System.debug('建物名：'+building.Name);
            System.debug('緯度：'+building.Latitude__c);
            System.debug('経度：'+building.Longitude__c);
        }
    }

       // ３件で正常に処理されるパターン（住所あり）
       @isTest static void checkOtherTestInput3Ok(){
        System.debug('-------------３件で正常に処理されるテストパターン（住所あり）-------------');

        // 必要なデータの設定
        List<Building__c> targetList = new List<Building__c>();

        // 建物データ増産
        Building__c addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'データ１';
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);

        addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'データ２';
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);

        addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'データ３';
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);

        // コールアウトクラスのモッククラスをセット
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest6OkHttpRequestMock());
        Test.startTest();
        GoogleApiUtil.getPeripheralInformation(targetList);
        Test.stopTest();

        // 取得結果の確認
        for(Building__c building : targetList){
            System.debug('建物名：'+building.Name);
            System.debug('緯度：'+building.Latitude__c);
            System.debug('経度：'+building.Longitude__c);
        }
    }

       // ４件で正常に処理されるパターン（住所あり）
       @isTest static void checkOtherTestInput4Ok(){
        System.debug('-------------４件で正常に処理されるテストパターン（住所あり）-------------');

        // 必要なデータの設定
        List<Building__c> targetList = new List<Building__c>();

        // 建物データ増産
        Building__c addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'データ１';
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);

        addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'データ２';
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);

        addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'データ３';
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);

        addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'データ４';
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);

        // コールアウトクラスのモッククラスをセット
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest6OkHttpRequestMock());
        Test.startTest();
        GoogleApiUtil.getPeripheralInformation(targetList);
        Test.stopTest();

        // 取得結果の確認
        for(Building__c building : targetList){
            System.debug('建物名：'+building.Name);
            System.debug('緯度：'+building.Latitude__c);
            System.debug('経度：'+building.Longitude__c);
        }
    }

    // ５件で正常に処理されるパターン（住所あり）
    @isTest static void checkOtherTestInput5Ok(){
        System.debug('-------------５件で正常に処理されるテストパターン（住所あり）-------------');

        // 必要なデータの設定
        List<Building__c> targetList = new List<Building__c>();

        // 建物データ増産
        Building__c addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'データ１';
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);

        addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'データ２';
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);

        addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'データ３';
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);

        addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'データ４';
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);

        addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'データ５';
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);

        // コールアウトクラスのモッククラスをセット
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest6OkHttpRequestMock());
        Test.startTest();
        GoogleApiUtil.getPeripheralInformation(targetList);
        Test.stopTest();

        // 取得結果の確認
        for(Building__c building : targetList){
            System.debug('建物名：'+building.Name);
            System.debug('緯度：'+building.Latitude__c);
            System.debug('経度：'+building.Longitude__c);
        }
    }

       // ５件で処理対象外となるパターン（住所なし）
       @isTest static void checkOtherTestInput5Ng(){
        System.debug('-------------５件で処理対象外となるテストパターン（住所なし）-------------');

        // 必要なデータの設定
        List<Building__c> targetList = new List<Building__c>();

        // 建物データ増産
        Building__c addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'データ１';
        targetList.add(addBuilding);

        addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'データ２';
        targetList.add(addBuilding);

        addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'データ３';
        targetList.add(addBuilding);

        addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'データ４';
        targetList.add(addBuilding);

        addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'データ５';
        targetList.add(addBuilding);

        // コールアウトクラスのモッククラスをセット
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest6OkHttpRequestMock());
        Test.startTest();
        GoogleApiUtil.getPeripheralInformation(targetList);
        Test.stopTest();

        // 取得結果の確認
        for(Building__c building : targetList){
            System.debug('建物名：'+building.Name);
            System.debug('緯度：'+building.Latitude__c);
            System.debug('経度：'+building.Longitude__c);
        }
    }

    // ６件で処理対象外として処理されるパターン（住所あり）
    @isTest static void checkOtherTestInput6Ng(){
        System.debug('-------------６件で処理対象外として処理されるテストパターン（住所あり）-------------');

        // 必要なデータの設定
        List<Building__c> targetList = new List<Building__c>();

        // 建物データ増産
        Building__c addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'データ１';
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);

        addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'データ２';
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);

        addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'データ３';
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);

        addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'データ４';
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);

        addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'データ５';
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);

        addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'データ６';
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);

        // コールアウトクラスのモッククラスをセット
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest6OkHttpRequestMock());
        Test.startTest();
        GoogleApiUtil.getPeripheralInformation(targetList);
        Test.stopTest();

        // 取得結果の確認
        for(Building__c building : targetList){
            System.debug('建物名：'+building.Name);
            System.debug('緯度：'+building.Latitude__c);
            System.debug('経度：'+building.Longitude__c);
        }
    }
}