//周辺施設情報取得（周辺施設）のテストクラス
@ isTest
private class GoogleApiUtilTest5 {

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

    // 対象の周辺施設が存在しない場合のテストパターン
    @isTest static void checkSurround0(){
        System.debug('-------------対象の周辺施設が存在しないテストパターン-------------');

        // 必要なデータの設定
        List<Building__c> targetList = new List<Building__c>();

        //テストNo.1のデータセット
        Building__c addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'テストNo.1';
        addBuilding.Latitude__c = 35.0;
        addBuilding.Longitude__c = 136.0;
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);

        // コールアウトクラスのモッククラスをセット
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest5NgHttpRequestMock());
        Test.startTest();
        GoogleApiUtil.setSurroundingFacilities(targetList);
        Test.stopTest();

        // 取得結果の確認
        for(Building__c building : targetList){

            if(building.Name == 'テストNo.1') {
                System.debug('★★★最終取得結果★★★');
                System.debug('高校：'+building.HighSchool__c);
                System.debug('高校までの距離：'+building.HighSchoolDistance__c);
                System.debug('大学：'+building.University__c);
                System.debug('大学までの距離：'+building.UniversityDistance__c);
                System.debug('コンビニ：'+building.ConvenienceStore__c);
                System.debug('コンビニまでの距離：'+building.ConvenienceStoreDistance__c);
                System.debug('スーパー：'+building.Supermarket__c);
                System.debug('スーパーまでの距離：'+building.SupermarketDistance__c);
            }
        }
    }

    // 周辺施設が取得できた場合のテストパターン（新規登録）
    @isTest static void checkSurround1new(){
System.debug('-------------周辺施設が取得できた場合のテストパターン（新規登録）-------------');

        // 必要なデータの設定
        List<Building__c> targetList = new List<Building__c>();

        //テストNo.2のデータセット
        Building__c addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'テストNo.2';
        addBuilding.Latitude__c = 35.0;
        addBuilding.Longitude__c = 136.0;
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);

        // コールアウトクラスのモッククラスをセット
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest5OkHttpRequestMock());
        Test.startTest();
        GoogleApiUtil.setSurroundingFacilities(targetList);
        Test.stopTest();

        // 取得結果の確認
        for(Building__c building : targetList){

            if(building.Name == 'テストNo.2') {
                System.debug('★★★最終取得結果★★★');
                System.debug('高校：'+building.HighSchool__c);
                System.debug('高校までの距離：'+building.HighSchoolDistance__c);
                System.debug('大学：'+building.University__c);
                System.debug('大学までの距離：'+building.UniversityDistance__c);
                System.debug('コンビニ：'+building.ConvenienceStore__c);
                System.debug('コンビニまでの距離：'+building.ConvenienceStoreDistance__c);
                System.debug('スーパー：'+building.Supermarket__c);
                System.debug('スーパーまでの距離：'+building.SupermarketDistance__c);
            }
        }
    }

    // 周辺施設が取得できた場合のテストパターン（既に周辺施設に登録あり）
    @isTest static void checkSurround1Existing(){
    System.debug('-------------周辺施設が取得できた場合のテストパターン（既に周辺施設に登録あり）-------------');
    
        // 周辺施設情報の登録
        List<SurroundingFacility__c> surroundingFacilityList = new List<SurroundingFacility__c>();

        SurroundingFacility__c surroundingFacility = new SurroundingFacility__c();
        surroundingFacility.OwnerId = UserInfo.getUserId();
        surroundingFacility.Name = 'テスト周辺施設';
        surroundingFacility.PlaceId__c = 'testPlaceId';
        surroundingFacilityList.add(surroundingFacility);

        insert surroundingFacilityList;

        // 必要なデータの設定
        List<Building__c> targetList = new List<Building__c>();

        //テストNo.2のデータセット
        Building__c addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'テストNo.3';
        addBuilding.Latitude__c = 35.0;
        addBuilding.Longitude__c = 136.0;
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);

        // コールアウトクラスのモッククラスをセット
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest5OkHttpRequestMock());
        Test.startTest();
        GoogleApiUtil.setSurroundingFacilities(targetList);
        Test.stopTest();

        // 取得結果の確認
        for(Building__c building : targetList){

            if(building.Name == 'テストNo.3') {
                System.debug('★★★最終取得結果★★★');
                System.debug('高校：'+building.HighSchool__c);
                System.debug('高校までの距離：'+building.HighSchoolDistance__c);
                System.debug('大学：'+building.University__c);
                System.debug('大学までの距離：'+building.UniversityDistance__c);
                System.debug('コンビニ：'+building.ConvenienceStore__c);
                System.debug('コンビニまでの距離：'+building.ConvenienceStoreDistance__c);
                System.debug('スーパー：'+building.Supermarket__c);
                System.debug('スーパーまでの距離：'+building.SupermarketDistance__c);
            }
        }
    }
}