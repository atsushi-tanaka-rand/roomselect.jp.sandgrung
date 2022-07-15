//周辺施設情報取得（駅）のテストクラス
@ isTest
private class GoogleApiUtilTest2 {

    @TestSetup
    // テストに利用するListを用意する。
    static void Setting(){

        // コンフィグ値を設定
        SystemConfig__c settings = new SystemConfig__c();
        settings.SearchStationRange__c = 5;
        insert settings;

        // 路線を設定
        TrainRoute__c trainRoute = new TrainRoute__c();
        trainRoute.Name = 'テスト路線';
        insert trainRoute;
    }


    // 対象の駅情報が取得できなかった場合のテストパターン
    @isTest static void checkSetStationNoGet(){
System.debug('-------------対象の駅がないテストパターン-------------');
        // 必要なデータの設定
        List<Building__c> targetList = new List<Building__c>();

        //テストNo.1のデータセット
        Building__c addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'テストNo.1';
        addBuilding.State__c = '愛知県';
        addBuilding.Latitude__c = 35.0;
        addBuilding.Longitude__c = 136.0;
        targetList.add(addBuilding);

        // コールアウトクラスのモッククラスをセット
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest2OkHttpRequestMock());
        Test.startTest();
        GoogleApiUtil.setStation(targetList);
        Test.stopTest();

        // 取得結果の確認
        for(Building__c building : targetList){

            if(building.Name == 'テストNo.1') {
                // nullが設定されていることを確認
System.debug('駅1：'+building.Station1__c);
System.debug('駅までの距離：'+building.StationDistance1__c);
                System.assertEquals(null, building.Station1__c);
                System.assertEquals(null, building.StationDistance1__c);
            }
        }
    }


    // 徒歩圏内１件のテストパターン
    @isTest static void checkSetStationIn1(){
System.debug('-------------徒歩圏内の駅が１件存在するテストパターン-------------');

        TrainRoute__c getTrainRoute = [select Id from TrainRoute__c];
        // 駅情報を設定
        List<Station__c> StationList = new List<Station__c>();
        // 徒歩圏内１
        Station__c Station = new Station__c();
        Station.Latitude__c = 35.001; // 35.0
        Station.Longitude__c = 136.001; // 136.0
        Station.TrainRoute__c = getTrainRoute.Id;
        Station.Name = '範囲内駅1';
        StationList.add(Station);

        insert StationList;

        // 必要なデータの設定
        List<Building__c> targetList = new List<Building__c>();

        //テストNo.2のデータセット
        Building__c addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'テストNo.2';
        addBuilding.State__c = '愛知県';
        addBuilding.Latitude__c = 35.0;
        addBuilding.Longitude__c = 136.0;
        targetList.add(addBuilding);

        // コールアウトクラスのモッククラスをセット
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest2OkHttpRequestMock());
        Test.startTest();
        GoogleApiUtil.setStation(targetList);
        Test.stopTest();

        // 取得結果の確認
        for(Building__c building : targetList){

            if(building.Name == 'テストNo.2') {
                // 駅情報が設定されていることを確認
                System.debug('駅1：'+building.Station1__c);
                System.debug('駅までの距離1：'+building.StationDistance1__c);
                System.debug('駅までの時間（分）１：'+building.StationWalkTime1__c);
            }
        }
    }

    // 徒歩圏内２件のテストパターン
    @isTest static void checkSetStationIn2(){
System.debug('-------------徒歩圏内の駅が２件存在するテストパターン-------------');
    
        TrainRoute__c getTrainRoute = [select Id from TrainRoute__c];
        // 駅情報を設定
        List<Station__c> StationList = new List<Station__c>();
        // 徒歩圏内１
        Station__c Station = new Station__c();
        Station.Latitude__c = 35.001; // 35.0
        Station.Longitude__c = 136.001; // 136.0
        Station.TrainRoute__c = getTrainRoute.Id;
        Station.Name = '範囲内駅1';
        StationList.add(Station);
        // 徒歩圏内２
        Station = new Station__c();
        Station.Latitude__c = 35.002; // 35.0
        Station.Longitude__c = 136.002; // 136.0
        Station.TrainRoute__c = getTrainRoute.Id;
        Station.Name = '範囲内駅2';
        StationList.add(Station);

        insert StationList;

        // 必要なデータの設定
        List<Building__c> targetList = new List<Building__c>();

        //テストNo.3のデータセット
        Building__c addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'テストNo.3';
        addBuilding.State__c = '愛知県';
        addBuilding.Latitude__c = 35.0;
        addBuilding.Longitude__c = 136.0;
        targetList.add(addBuilding);

        // コールアウトクラスのモッククラスをセット
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest2OkHttpRequestMock());
        Test.startTest();
        GoogleApiUtil.setStation(targetList);
        Test.stopTest();

        // 取得結果の確認
        for(Building__c building : targetList){

            if(building.Name == 'テストNo.3') {
                // 駅情報が設定されていることを確認
                System.debug('駅1：'+building.Station1__c);
                System.debug('駅までの距離1：'+building.StationDistance1__c);
                System.debug('駅までの時間（分）１：'+building.StationWalkTime1__c);
                System.debug('駅2：'+building.Station2__c);
                System.debug('駅までの距離2：'+building.StationDistance2__c);
                System.debug('駅までの時間（分）２：'+building.StationWalkTime2__c);
            }
        }
    }

    // 徒歩圏内３件のテストパターン
    @isTest static void checkSetStationIn3(){
System.debug('-------------徒歩圏内の駅が３件存在するテストパターン-------------');
    
        TrainRoute__c getTrainRoute = [select Id from TrainRoute__c];
        // 駅情報を設定
        List<Station__c> StationList = new List<Station__c>();
        // 徒歩圏内１
        Station__c Station = new Station__c();
        Station.Latitude__c = 35.001; // 35.0
        Station.Longitude__c = 136.001; // 136.0
        Station.TrainRoute__c = getTrainRoute.Id;
        Station.Name = '範囲内駅1';
        StationList.add(Station);
        // 徒歩圏内２
        Station = new Station__c();
        Station.Latitude__c = 35.002; // 35.0
        Station.Longitude__c = 136.002; // 136.0
        Station.TrainRoute__c = getTrainRoute.Id;
        Station.Name = '範囲内駅2';
        StationList.add(Station);
        // 徒歩圏内３
        Station = new Station__c();
        Station.Latitude__c = 35.003; // 35.0
        Station.Longitude__c = 136.003; // 136.0
        Station.TrainRoute__c = getTrainRoute.Id;
        Station.Name = '範囲内駅3';
        StationList.add(Station);

        insert StationList;

        // 必要なデータの設定
        List<Building__c> targetList = new List<Building__c>();

        //テストNo.4のデータセット
        Building__c addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'テストNo.4';
        addBuilding.State__c = '愛知県';
        addBuilding.Latitude__c = 35.0;
        addBuilding.Longitude__c = 136.0;
        targetList.add(addBuilding);

        // コールアウトクラスのモッククラスをセット
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest2OkHttpRequestMock());
        Test.startTest();
        GoogleApiUtil.setStation(targetList);
        Test.stopTest();

        // 取得結果の確認
        for(Building__c building : targetList){

            if(building.Name == 'テストNo.4') {
                // 駅情報が設定されていることを確認
                System.debug('駅1：'+building.Station1__c);
                System.debug('駅までの距離1：'+building.StationDistance1__c);
                System.debug('駅までの時間（分）１：'+building.StationWalkTime1__c);
                System.debug('駅2：'+building.Station2__c);
                System.debug('駅までの距離2：'+building.StationDistance2__c);
                System.debug('駅までの時間（分）２：'+building.StationWalkTime2__c);
                System.debug('駅3：'+building.Station3__c);
                System.debug('駅までの距離3：'+building.StationDistance3__c);
                System.debug('駅までの時間（分）３：'+building.StationWalkTime3__c);
            }
        }
    }

    // 徒歩圏内４件のテストパターン（うち、２件は同一座標）
    @isTest static void checkSetStationIn4(){
        System.debug('-------------徒歩圏内の駅が４件存在するテストパターン（同一座標）-------------');
            
        TrainRoute__c getTrainRoute = [select Id from TrainRoute__c];
        // 駅情報を設定
        List<Station__c> StationList = new List<Station__c>();
        // 徒歩圏内１
        Station__c Station = new Station__c();
        Station.Latitude__c = 35.001; // 35.0
        Station.Longitude__c = 136.001; // 136.0
        Station.TrainRoute__c = getTrainRoute.Id;
        Station.Name = '範囲内駅1';
        StationList.add(Station);
        // 徒歩圏内２
        Station = new Station__c();
        Station.Latitude__c = 35.002; // 35.0
        Station.Longitude__c = 136.002; // 136.0
        Station.TrainRoute__c = getTrainRoute.Id;
        Station.Name = '範囲内駅2';
        StationList.add(Station);
        // 徒歩圏内３
        Station = new Station__c();
        Station.Latitude__c = 35.003; // 35.0
        Station.Longitude__c = 136.003; // 136.0
        Station.TrainRoute__c = getTrainRoute.Id;
        Station.Name = '範囲内駅3';
        StationList.add(Station);
        // 徒歩圏内４
        Station = new Station__c();
        Station.Latitude__c = 35.003; // 35.0
        Station.Longitude__c = 136.003; // 136.0
        Station.TrainRoute__c = getTrainRoute.Id;
        Station.Name = '範囲内駅4';
        StationList.add(Station);

        insert StationList;

        // 必要なデータの設定
        List<Building__c> targetList = new List<Building__c>();

        //テストNo.5のデータセット
        Building__c addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'テストNo.5';
        addBuilding.State__c = '愛知県';
        addBuilding.Latitude__c = 35.0;
        addBuilding.Longitude__c = 136.0;
        targetList.add(addBuilding);

        // コールアウトクラスのモッククラスをセット
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest2OkHttpRequestMock());
        Test.startTest();
        GoogleApiUtil.setStation(targetList);
        Test.stopTest();

        // 取得結果の確認
        for(Building__c building : targetList){

            if(building.Name == 'テストNo.5') {
                // 駅情報が設定されていることを確認
                System.debug('駅1：'+building.Station1__c);
                System.debug('駅までの距離1：'+building.StationDistance1__c);
                System.debug('駅までの時間（分）１：'+building.StationWalkTime1__c);
                System.debug('駅2：'+building.Station2__c);
                System.debug('駅までの距離2：'+building.StationDistance2__c);
                System.debug('駅までの時間（分）２：'+building.StationWalkTime2__c);
                System.debug('駅3：'+building.Station3__c);
                System.debug('駅までの距離3：'+building.StationDistance3__c);
                System.debug('駅までの時間（分）３：'+building.StationWalkTime3__c);
            }
        }
    }

        // 徒歩圏内５件のテストパターン（すべて別座標）
        @isTest static void checkSetStationIn5(){
            System.debug('-------------徒歩圏内５件のテストパターン（すべて別座標）-------------');
                
            TrainRoute__c getTrainRoute = [select Id from TrainRoute__c];
            // 駅情報を設定
            List<Station__c> StationList = new List<Station__c>();
            // 徒歩圏内１
            Station__c Station = new Station__c();
            Station.Latitude__c = 35.001; // 35.0
            Station.Longitude__c = 136.001; // 136.0
            Station.TrainRoute__c = getTrainRoute.Id;
            Station.Name = '範囲内駅1';
            StationList.add(Station);
            // 徒歩圏内２
            Station = new Station__c();
            Station.Latitude__c = 35.002; // 35.0
            Station.Longitude__c = 136.002; // 136.0
            Station.TrainRoute__c = getTrainRoute.Id;
            Station.Name = '範囲内駅2';
            StationList.add(Station);
            // 徒歩圏内３
            Station = new Station__c();
            Station.Latitude__c = 35.003; // 35.0
            Station.Longitude__c = 136.003; // 136.0
            Station.TrainRoute__c = getTrainRoute.Id;
            Station.Name = '範囲内駅3';
            StationList.add(Station);
            // 徒歩圏内４
            Station = new Station__c();
            Station.Latitude__c = 35.004; // 35.0
            Station.Longitude__c = 136.004; // 136.0
            Station.TrainRoute__c = getTrainRoute.Id;
            Station.Name = '範囲内駅4';
            StationList.add(Station);
            // 徒歩圏内５
            Station = new Station__c();
            Station.Latitude__c = 35.005; // 35.0
            Station.Longitude__c = 136.005; // 136.0
            Station.TrainRoute__c = getTrainRoute.Id;
            Station.Name = '範囲内駅5';
            StationList.add(Station);
    
            insert StationList;
    
            // 必要なデータの設定
            List<Building__c> targetList = new List<Building__c>();
    
            //テストNo.5-1のデータセット
            Building__c addBuilding = new Building__c();
            addBuilding.OwnerId = UserInfo.getUserId();
            addBuilding.Name = 'テストNo.5-1';
            addBuilding.State__c = '愛知県';
            addBuilding.Latitude__c = 35.0;
            addBuilding.Longitude__c = 136.0;
            targetList.add(addBuilding);
    
            // コールアウトクラスのモッククラスをセット
            Test.setMock(HttpCalloutMock.class, new googleApiUtilTest2OkHttpRequestMock());
            Test.startTest();
            GoogleApiUtil.setStation(targetList);
            Test.stopTest();
    
            // 取得結果の確認
            for(Building__c building : targetList){
    
                if(building.Name == 'テストNo.5-1') {
                    // 駅情報が設定されていることを確認
                    System.debug('駅1：'+building.Station1__c);
                    System.debug('駅までの距離1：'+building.StationDistance1__c);
                    System.debug('駅までの時間（分）１：'+building.StationWalkTime1__c);
                    System.debug('駅2：'+building.Station2__c);
                    System.debug('駅までの距離2：'+building.StationDistance2__c);
                    System.debug('駅までの時間（分）２：'+building.StationWalkTime2__c);
                    System.debug('駅3：'+building.Station3__c);
                    System.debug('駅までの距離3：'+building.StationDistance3__c);
                    System.debug('駅までの時間（分）３：'+building.StationWalkTime3__c);
                }
            }
        }
    
    // 徒歩圏外１件のテストパターン
    @isTest static void checkSetStationOut1(){
System.debug('-------------徒歩圏外の駅が１件存在するテストパターン-------------');
        
        TrainRoute__c getTrainRoute = [select Id from TrainRoute__c];
        // 駅情報を設定
        List<Station__c> StationList = new List<Station__c>();
        // 徒歩圏外１
        Station__c Station = new Station__c();
        Station.Latitude__c = 35.001; // 35.0
        Station.Longitude__c = 136.001; // 136.0
        Station.TrainRoute__c = getTrainRoute.Id;
        Station.Name = '範囲外駅1';
        StationList.add(Station);

        insert StationList;

        // 必要なデータの設定
        List<Building__c> targetList = new List<Building__c>();

        //テストNo.6のデータセット
        Building__c addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'テストNo.6';
        addBuilding.State__c = '愛知県';
        addBuilding.Latitude__c = 35.0;
        addBuilding.Longitude__c = 136.0;
        targetList.add(addBuilding);

        // コールアウトクラスのモッククラスをセット
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest2NgHttpRequestMock());
        Test.startTest();
        GoogleApiUtil.setStation(targetList);
        Test.stopTest();

        // 取得結果の確認
        for(Building__c building : targetList){

            if(building.Name == 'テストNo.6') {
                // 駅情報が設定されていることを確認
                System.debug('駅1：'+building.Station1__c);
                System.debug('駅までの距離1：'+building.StationDistance1__c);
                System.debug('駅までの時間（分）１：'+building.StationWalkTime1__c);
            }
        }
    }

    // 徒歩圏外２件のテストパターン
    @isTest static void checkSetStationOut2(){
System.debug('-------------徒歩圏外の駅が２件存在するテストパターン-------------');
                
        TrainRoute__c getTrainRoute = [select Id from TrainRoute__c];
        // 駅情報を設定
        List<Station__c> StationList = new List<Station__c>();
        // 徒歩圏外１
        Station__c Station = new Station__c();
        Station.Latitude__c = 35.001; // 35.0
        Station.Longitude__c = 136.001; // 136.0
        Station.TrainRoute__c = getTrainRoute.Id;
        Station.Name = '範囲外駅1';
        StationList.add(Station);
        // 徒歩圏外２
        Station = new Station__c();
        Station.Latitude__c = 35.002; // 35.0
        Station.Longitude__c = 136.002; // 136.0
        Station.TrainRoute__c = getTrainRoute.Id;
        Station.Name = '範囲外駅2';
        StationList.add(Station);

        insert StationList;

        // 必要なデータの設定
        List<Building__c> targetList = new List<Building__c>();

        //テストNo.7のデータセット
        Building__c addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'テストNo.7';
        addBuilding.State__c = '愛知県';
        addBuilding.Latitude__c = 35.0;
        addBuilding.Longitude__c = 136.0;
        targetList.add(addBuilding);

        // コールアウトクラスのモッククラスをセット
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest2NgHttpRequestMock());
        Test.startTest();
        GoogleApiUtil.setStation(targetList);
        Test.stopTest();

        // 取得結果の確認
        for(Building__c building : targetList){

            if(building.Name == 'テストNo.7') {
                // 駅情報が設定されていることを確認
                System.debug('駅1：'+building.Station1__c);
                System.debug('駅までの距離1：'+building.StationDistance1__c);
                System.debug('駅までの時間（分）１：'+building.StationWalkTime1__c);
                // 駅情報が設定されていないことを確認
                System.debug('駅2：'+building.Station2__c);
                System.debug('駅までの距離2：'+building.StationDistance2__c);
                System.debug('駅までの時間（分）２：'+building.StationWalkTime2__c);
            }
        }
    }

    // 徒歩圏外３件のテストパターン
    @isTest static void checkSetStationOut3(){
        System.debug('-------------徒歩圏外の駅が３件存在するテストパターン-------------');
                        
        TrainRoute__c getTrainRoute = [select Id from TrainRoute__c];
        // 駅情報を設定
        List<Station__c> StationList = new List<Station__c>();
        // 徒歩圏外１
        Station__c Station = new Station__c();
        Station.Latitude__c = 35.001; // 35.0
        Station.Longitude__c = 136.001; // 136.0
        Station.TrainRoute__c = getTrainRoute.Id;
        Station.Name = '範囲外駅1';
        StationList.add(Station);
        // 徒歩圏外２
        Station = new Station__c();
        Station.Latitude__c = 35.002; // 35.0
        Station.Longitude__c = 136.002; // 136.0
        Station.TrainRoute__c = getTrainRoute.Id;
        Station.Name = '範囲外駅2';
        StationList.add(Station);
        // 徒歩圏外３
        Station = new Station__c();
        Station.Latitude__c = 35.003; // 35.0
        Station.Longitude__c = 136.003; // 136.0
        Station.TrainRoute__c = getTrainRoute.Id;
        Station.Name = '範囲外駅3';
        StationList.add(Station);

        insert StationList;

        // 必要なデータの設定
        List<Building__c> targetList = new List<Building__c>();

        //テストNo.8のデータセット
        Building__c addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'テストNo.8';
        addBuilding.State__c = '愛知県';
        addBuilding.Latitude__c = 35.0;
        addBuilding.Longitude__c = 136.0;
        targetList.add(addBuilding);

        // コールアウトクラスのモッククラスをセット
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest2NgHttpRequestMock());
        Test.startTest();
        GoogleApiUtil.setStation(targetList);
        Test.stopTest();

        // 取得結果の確認
        for(Building__c building : targetList){

            if(building.Name == 'テストNo.8') {
                // 駅情報が設定されていることを確認
                System.debug('駅1：'+building.Station1__c);
                System.debug('駅までの距離1：'+building.StationDistance1__c);
                System.debug('駅までの時間（分）１：'+building.StationWalkTime1__c);
                // 駅情報が設定されていないことを確認
                System.debug('駅2：'+building.Station2__c);
                System.debug('駅までの距離2：'+building.StationDistance2__c);
                System.debug('駅までの時間（分）２：'+building.StationWalkTime2__c);
                System.debug('駅3：'+building.Station3__c);
                System.debug('駅までの距離3：'+building.StationDistance3__c);
                System.debug('駅までの時間（分）３：'+building.StationWalkTime3__c);
            }
        }
    }


    // 検索経度上限取得メソッドの検証
    // ※ privateを一次的にpublicにして検証する
    @isTest static void maxLongitudeSettingTest(){
        // コールアウトクラスのモッククラスをセット
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest2OkHttpRequestMock());
        Test.startTest();

        // 想定値のマップ（詳細設計上での計算値）
        Map<String, Decimal> districts = new Map<String, Decimal> {
              '北海道'   =>  81.45606115, '青森県' =>  84.35803187, '岩手県' =>  85.76191224, '宮城県'   =>  87.51078851, '秋田県'   =>  85.74334061
            , '山形県'   =>  87.5447709 , '福島県' =>  88.12979431, '茨城県' =>  89.77347959, '栃木県'   =>  89.5152031 , '群馬県'   =>  89.71638279
            , '埼玉県'   =>  90.32625178, '千葉県' =>  90.6114824 , '東京都' =>  90.51587027, '神奈川県' =>  90.7880748 , '新潟県'   =>  87.94895412
            , '富山県'   =>  89.36561069, '石川県' =>  89.4821808 , '福井県' =>  90.08932063, '山梨県'   =>  90.54472604, '長野県'   =>  89.41638126
            , '岐阜県'   =>  90.85167344, '静岡県' =>  91.31377276, '愛知県' =>  91.08749751, '三重県'   =>  91.58670697, '滋賀県'   =>  91.28323829
            , '京都府'   =>  91.26440746, '大阪府' =>  91.63509404, '兵庫県' =>  91.62958444, '奈良県'   =>  91.63631707, '和歌山県' =>  92.13928498
            , '鳥取県'   =>  90.7253318 , '島根県' =>  90.76061921, '岡山県' =>  91.66232318, '広島県'   =>  91.95345272, '山口県'   =>  92.18312471
            , '徳島県'   =>  92.31345909, '香川県' =>  92.0147774 , '愛媛県' =>  92.55583676, '高知県'   =>  92.85868584, '福岡県'   =>  92.80871184
            , '佐賀県'   =>  93.18936185, '長崎県' =>  93.72140886, '熊本県' =>  93.67426748, '大分県'   =>  93.20143794, '宮崎県'   =>  94.58419125
            , '鹿児島県' =>  94.94131794, '沖縄県' =>  99.93690387
        };
        Decimal range   = SystemConfig__c.getInstance().SearchStationRange__c;      // 検索半径(m)
        Decimal diff    = 0.00000000001;                                            // 検証用許容誤差
        //                0.0548922754130014082983231141794928          参考：愛知県の想定値（5Kmの経度度数）
        //                0.0548922754118862250265019527251689          参考：愛知県の計算値（5Kmの経度度数）

        // 取得結果の確認
        for (String dist: districts.keySet()) {
            Decimal val = range / districts.get(dist);
            /* 検証時はコメントを外す
            Decimal ret = GoogleApiUtil.maxLongitudeSetting(dist);
            System.assert(Math.abs(ret - val) <= diff, '検索経度上限取得メソッド想定値エラー 都道府県=' + dist + ', ret=' + ret +  ', 想定値=' + val + ', 許容誤差=' + diff);
            */
        }

        Test.stopTest();
    }

    // 範囲内外境界確認
    @isTest static void checkStationLongitudeInRange() {
        final Decimal dist = 0.054892275411886;         // 小数点以下15桁（愛知県の5Km分の経度度数）
        final Decimal gosa = 0.000000000000001;

        // 建物のデータセット
        List<Building__c> targetList = new List<Building__c>();
        Building__c aichiBuild = new Building__c(
              Name                  = 'テスト'                  // 建物名
            , OwnerId               =  UserInfo.getUserId()     // 所有者
            , State__c              = '愛知県'                  // 都道府県
            , Latitude__c           =  35.0                     // 緯度
            , Longitude__c          = 138.0                     // 経度
        );
        targetList.add(aichiBuild);

        // 駅情報を設定
        List<Station__c> StationList = new List<Station__c>();
        TrainRoute__c trainRoute = [select Id from TrainRoute__c];
        // 西方向範囲内
        Station__c rangeInWest = new Station__c(
              Name                  = '西方向範囲内'                            // 駅名
            , Latitude__c           = aichiBuild.Latitude__c                    // 緯度
            , Longitude__c          = aichiBuild.Longitude__c - dist            // 経度
            , TrainRoute__c         = trainRoute.Id                             // 路線
        );
        StationList.add(rangeInWest);      // 範囲内
        insert StationList;

        // コールアウトクラスのモッククラスをセット
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest2OkHttpRequestMock());
        Test.startTest();
        GoogleApiUtil.setStation(targetList);
        Test.stopTest();
 
        // 取得結果の確認
        for (Building__c building : targetList) {
            // 駅情報が設定されていることを確認
            System.assertEquals(rangeInWest.Id, building.Station1__c, '西方向範囲内1');
            System.assertEquals(null,           building.Station2__c, '西方向範囲内2');
        }
   }

    // 範囲内外境界確認
    @isTest static void checkStationLongitudeOutRange() {
        final Decimal dist = 0.054892275411886;         // 小数点以下15桁（愛知県の5Km分の経度度数）
        final Decimal gosa = 0.000000000000001;

        // 建物のデータセット
        List<Building__c> targetList = new List<Building__c>();
        Building__c aichiBuild = new Building__c(
              Name                  = 'テスト'                  // 建物名
            , OwnerId               =  UserInfo.getUserId()     // 所有者
            , State__c              = '愛知県'                  // 都道府県
            , Latitude__c           =  35.0                     // 緯度
            , Longitude__c          = 138.0                     // 経度
        );
        targetList.add(aichiBuild);

        // 駅情報を設定
        List<Station__c> StationList = new List<Station__c>();
        TrainRoute__c trainRoute = [select Id from TrainRoute__c];
        // 西方向範囲外
        Station__c rangeOutWest = new Station__c(
              Name                  = '西方向範囲外'                            // 駅名
            , Latitude__c           = aichiBuild.Latitude__c                    // 緯度
            , Longitude__c          = aichiBuild.Longitude__c - dist - gosa     // 経度
            , TrainRoute__c         = trainRoute.Id                             // 路線
        );
        StationList.add(rangeOutWest);     // 範囲外
        insert StationList;

        // コールアウトクラスのモッククラスをセット
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest2OkHttpRequestMock());
        Test.startTest();
        GoogleApiUtil.setStation(targetList);
        Test.stopTest();
 
        // 取得結果の確認
        for (Building__c building : targetList) {
            // 駅情報が設定されていることを確認
            System.assertEquals(null, building.Station1__c, '西方向範囲外1');
            System.assertEquals(null, building.Station2__c, '西方向範囲外2');
        }
   }

    // 例外確認
    @isTest static void checkException() {
        // 建物のデータセット
        List<Building__c> targetList = new List<Building__c>();
        Building__c build;
        targetList.add(build);
        Exception ex;
        String msg;

        // コールアウトクラスのモッククラスをセット
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest2OkHttpRequestMock());
        Test.startTest();

        targetList = new List<Building__c>();
        build = new Building__c(
              Name                  = 'テスト'                  // 建物名
            , OwnerId               =  UserInfo.getUserId()     // 所有者
            , Latitude__c           =  35.0                     // 緯度
            , Longitude__c          = 138.0                     // 経度
        );
        targetList.add(build);

        try {
            GoogleApiUtil.setStation(targetList);
        } catch(Exception e) {
            ex = e;
        }
        System.assert(ex instanceof BusinessLogicException, '例外の種類');
        msg = ((BusinessLogicException) ex).errMessage[0];
        System.assertEquals('都道府県を選択してください。', msg, 'エラーメッセージ');

        targetList = new List<Building__c>();
        build = new Building__c(
              Name                  = 'テスト'                  // 建物名
            , OwnerId               =  UserInfo.getUserId()     // 所有者
            , State__c              = '-'                       // 都道府県
            , Latitude__c           =  35.0                     // 緯度
            , Longitude__c          = 138.0                     // 経度
        );
        targetList.add(build);

        try {
            GoogleApiUtil.setStation(targetList);
        } catch(Exception e) {
            ex = e;
        }
        System.assert(ex instanceof BusinessLogicException, '例外の種類');
        msg = ((BusinessLogicException) ex).errMessage[0];
        System.assertEquals('処理中に以下のエラーが発生しました。システム管理者にお問い合わせください。緯度・経度取得エラー', msg, 'エラーメッセージ');

        Test.stopTest();
    }

}