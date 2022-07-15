//周辺施設情報取得（病院）のテストクラス
@ isTest
private class GoogleApiUtilTest4 {

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

    // 対象の病院が存在しない場合のテストパターン
    @isTest static void checkHospital0(){
        System.debug('-------------対象の病院が存在しないテストパターン-------------');

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
        // 小中学校は距離による設定分岐が存在しないので、
        // 駅設定テストで作成したスタブをそのまま利用する。
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest2OkHttpRequestMock());
        Test.startTest();
        GoogleApiUtil.setHospital(targetList);
        Test.stopTest();

        // 取得結果の確認
        for(Building__c building : targetList){

            if(building.Name == 'テストNo.1') {
                System.debug('★★★最終取得結果★★★');
                System.debug('病院：'+building.GeneralHospital__c);
                System.debug('総合病院までの距離：'+building.GeneralHospitalDistance__c);
            }
        }
    }

    // 対象の病院が存在する場合のテストパターン
    @isTest static void checkHospital1Ok(){
System.debug('-------------対象の病院が存在するテストパターン（距離取得ＯＫ）-------------');

        // 病院情報の登録
        List<Hospital__c> hospitalList = new List<Hospital__c>();

        Hospital__c addHospital = new Hospital__c();
        addHospital.OwnerId = UserInfo.getUserId();
        addHospital.Name = 'テスト総合病院';
        addHospital.Latitude__c = 35.0;
        addHospital.Longitude__c = 136.0;
        hospitalList.add(addHospital);

        insert hospitalList;

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
        // 小中学校は距離による設定分岐が存在しないので、
        // 駅設定テストで作成したスタブをそのまま利用する。
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest4OkHttpRequestMock());
        Test.startTest();
        GoogleApiUtil.setHospital(targetList);
        Test.stopTest();

        // 取得結果の確認
        for(Building__c building : targetList){

            if(building.Name == 'テストNo.2') {
                System.debug('★★★最終取得結果★★★');
                System.debug('病院：'+building.GeneralHospital__c);
                System.debug('総合病院までの距離：'+building.GeneralHospitalDistance__c);
            }
        }
    }

    // 対象の病院が存在する場合のテストパターン
    @isTest static void checkHospital1Ng(){
        System.debug('-------------対象の病院が存在するテストパターン（距離取得ＮＧ）-------------');
            
        // 病院情報の登録
        List<Hospital__c> hospitalList = new List<Hospital__c>();

        Hospital__c addHospital = new Hospital__c();
        addHospital.OwnerId = UserInfo.getUserId();
        addHospital.Name = 'テスト総合病院';
        addHospital.Latitude__c = 35.0;
        addHospital.Longitude__c = 136.0;
        hospitalList.add(addHospital);

        insert hospitalList;

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
        // 小中学校は距離による設定分岐が存在しないので、
        // 駅設定テストで作成したスタブをそのまま利用する。
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest4NgHttpRequestMock());
        Test.startTest();
        GoogleApiUtil.setHospital(targetList);
        Test.stopTest();

        // 取得結果の確認
        for(Building__c building : targetList){

            if(building.Name == 'テストNo.3') {
                System.debug('★★★最終取得結果★★★');
                System.debug('病院：'+building.GeneralHospital__c);
                System.debug('総合病院までの距離：'+building.GeneralHospitalDistance__c);
            }
        }
    }
}