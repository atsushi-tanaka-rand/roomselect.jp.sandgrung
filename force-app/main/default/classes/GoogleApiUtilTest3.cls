//周辺施設情報取得（小中学校設定）のテストクラス
@ isTest
private class GoogleApiUtilTest3 {

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

        // 国土地理協会住所
        JapanGeographicDataCenterAddress__c jpAddress = new JapanGeographicDataCenterAddress__c();
        jpAddress.PlaceName__c      = '大阪府大阪市大阪町';
        jpAddress.ChoazaCodeNew__c  = '12345678901';
        insert jpAddress;
    }

    // 対象の小学校、中学校がともに存在しない場合のテストパターン
    @isTest static void checkSetSchoolS0T0(){
        System.debug('-------------対象の小学校、中学校ともに存在しないテストパターン-------------');

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
        addBuilding.ChoazaCode__c  = '12345678901';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);

        // コールアウトクラスのモッククラスをセット
        // 小中学校は距離による設定分岐が存在しないので、
        // 駅設定テストで作成したスタブをそのまま利用する。
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest3OkHttpRequestMock());
        Test.startTest();
        GoogleApiUtil.setSchool(targetList);
        Test.stopTest();

        // 取得結果の確認
        for(Building__c building : targetList){

            if(building.Name == 'テストNo.1') {
                // 以下はnullが設定されていること
                System.debug('★★★最終取得結果★★★');
                System.debug('-----小学校情報-----');
                System.debug('小学校1：'+building.PrimarySchool1__c);
                System.debug('小学校までの距離１：'+building.PrimarySchoolDistance1__c);
                System.debug('小学校までの時間（分）１：'+building.PrimarySchoolWalkTime1__c);
                System.debug('小学校2：'+building.PrimarySchool2__c);
                System.debug('小学校までの距離２：'+building.PrimarySchoolDistance2__c);
                System.debug('小学校までの時間（分）２：'+building.PrimarySchoolWalkTime2__c);
                System.debug('小学校3：'+building.PrimarySchool3__c);
                System.debug('小学校までの距離３：'+building.PrimarySchoolDistance3__c);
                System.debug('小学校までの時間（分）３：'+building.PrimarySchoolWalkTime3__c);
                System.debug('-----中学校情報-----');
                System.debug('中学校1：'+building.JuniorHighSchool1__c);
                System.debug('中学校までの距離１：'+building.JuniorHighSchoolDistance1__c);
                System.debug('中学校までの時間（分）１：'+building.JuniorHighSchoolWalkTime1__c);
                System.debug('中学校2：'+building.JuniorHighSchool2__c);
                System.debug('中学校までの距離２：'+building.JuniorHighSchoolDistance2__c);
                System.debug('中学校までの時間（分）２：'+building.JuniorHighSchoolWalkTime2__c);
                System.debug('中学校3：'+building.JuniorHighSchool3__c);
                System.debug('中学校までの距離３：'+building.JuniorHighSchoolDistance3__c);
                System.debug('中学校までの時間（分）３：'+building.JuniorHighSchoolWalkTime3__c);
            }
        }
    }

    // 対象の小学校が１件、中学校が０件存在する場合のテストパターン
    @isTest static void checkSetSchoolS1T0(){
System.debug('-------------対象の小学校が１件、中学校が０件存在するテストパターン-------------');

        // 小学校情報の登録
        List<School__c> schoolList = new List<School__c>();
        // 小学校１件目
        School__c addSchool = new School__c();
        addSchool.OwnerId = UserInfo.getUserId();
        addSchool.Name = '小学校１';
        addSchool.Latitude__c = 35.0;
        addSchool.Longitude__c = 136.0;
        addSchool.Type__c = CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL;
        schoolList.add(addSchool);

        insert schoolList;

        // 学区情報の登録
        List<SchoolArea__c> schoolAreaList = new List<SchoolArea__c>();
        School__c getPriSchool = [select Id from School__c 
                                where Name = '小学校１' and Type__c = :CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL];
        // 学区１件目
        SchoolArea__c addSchoolArea = new SchoolArea__c();
        addSchoolArea.School__c = getPriSchool.Id;
        addSchoolArea.Name = '学区１';
        addSchoolArea.State__c = '大阪府';
        addSchoolArea.City__c = '大阪市大阪町';
        schoolAreaList.add(addSchoolArea);

        insert schoolAreaList;



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
        addBuilding.ChoazaCode__c  = '12345678901';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);

        // コールアウトクラスのモッククラスをセット
        // 小中学校は距離による設定分岐が存在しないので、
        // 駅設定テストで作成したスタブをそのまま利用する。
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest3OkHttpRequestMock());
        Test.startTest();
        GoogleApiUtil.setSchool(targetList);
        Test.stopTest();

        // 取得結果の確認
        for(Building__c building : targetList){

            if(building.Name == 'テストNo.2') {
                System.debug('★★★最終取得結果★★★');
                System.debug('-----小学校情報-----');
                // 小学校情報が１件設定されていることを確認
                System.debug('小学校1：'+building.PrimarySchool1__c);
                System.debug('小学校までの距離１：'+building.PrimarySchoolDistance1__c);
                System.debug('小学校までの時間（分）１：'+building.PrimarySchoolWalkTime1__c);
                // 以下はnullが設定されていること
                System.debug('小学校2：'+building.PrimarySchool2__c);
                System.debug('小学校までの距離２：'+building.PrimarySchoolDistance2__c);
                System.debug('小学校までの時間（分）２：'+building.PrimarySchoolWalkTime2__c);
                System.debug('小学校3：'+building.PrimarySchool3__c);
                System.debug('小学校までの距離３：'+building.PrimarySchoolDistance3__c);
                System.debug('小学校までの時間（分）３：'+building.PrimarySchoolWalkTime3__c);
                System.debug('-----中学校情報-----');
                System.debug('中学校1：'+building.JuniorHighSchool1__c);
                System.debug('中学校までの距離１：'+building.JuniorHighSchoolDistance1__c);
                System.debug('中学校までの時間（分）１：'+building.JuniorHighSchoolWalkTime1__c);
                System.debug('中学校2：'+building.JuniorHighSchool2__c);
                System.debug('中学校までの距離２：'+building.JuniorHighSchoolDistance2__c);
                System.debug('中学校までの時間（分）２：'+building.JuniorHighSchoolWalkTime2__c);
                System.debug('中学校3：'+building.JuniorHighSchool3__c);
                System.debug('中学校までの距離３：'+building.JuniorHighSchoolDistance3__c);
                System.debug('中学校までの時間（分）３：'+building.JuniorHighSchoolWalkTime3__c);
            }
        }
    }

    // 対象の小学校が１件、中学校が１件存在する場合のテストパターン
    @isTest static void checkSetSchoolS1T1(){
        System.debug('-------------対象の小学校が１件、中学校が１件存在するテストパターン-------------');
        
        // 小学校情報の登録
        List<School__c> schoolList = new List<School__c>();
        // 小学校１件目
        School__c addSchool = new School__c();
        addSchool.OwnerId = UserInfo.getUserId();
        addSchool.Name = '小学校１';
        addSchool.Latitude__c = 35.0;
        addSchool.Longitude__c = 136.0;
        addSchool.Type__c = CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL;
        schoolList.add(addSchool);

        // 中学校情報の登録
        // 中学校１件目
        addSchool = new School__c();
        addSchool.OwnerId = UserInfo.getUserId();
        addSchool.Name = '中学校１';
        addSchool.Latitude__c = 35.0;
        addSchool.Longitude__c = 136.0;
        addSchool.Type__c = CommonConst.SCHOOL_TYPE_JUNIORHIGHSCHOOL;
        schoolList.add(addSchool);

        insert schoolList;

        // 学区情報の登録
        List<SchoolArea__c> schoolAreaList = new List<SchoolArea__c>();
        School__c getPriSchool = [select Id from School__c 
                                where Name = '小学校１' and Type__c = :CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL];
        School__c getJhSchool = [select Id from School__c 
                                where Name = '中学校１' and Type__c = :CommonConst.SCHOOL_TYPE_JUNIORHIGHSCHOOL];
        // 学区１件目
        SchoolArea__c addSchoolArea = new SchoolArea__c();
        addSchoolArea.School__c = getPriSchool.Id;
        addSchoolArea.Name = '学区１';
        addSchoolArea.State__c = '大阪府';
        addSchoolArea.City__c = '大阪市大阪町';
        schoolAreaList.add(addSchoolArea);

        insert schoolAreaList;

        // 進学情報の登録
        List<Advancement__c> advancementList = new List<Advancement__c>();
        // 進学１件目
        Advancement__c addAdvancement = new Advancement__c();
        addAdvancement.PrimarySchool__c = getPriSchool.Id;
        addAdvancement.JuniorHighSchool__c = getJhSchool.Id;
        advancementList.add(addAdvancement);

        insert advancementList;


        // 必要なデータの設定
        List<Building__c> targetList = new List<Building__c>();

        //テストNo.3のデータセット
        Building__c addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'テストNo.3';
        addBuilding.Latitude__c = 35.0;
        addBuilding.Longitude__c = 136.0;
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        addBuilding.ChoazaCode__c  = '12345678901';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);

        // コールアウトクラスのモッククラスをセット
        // 小中学校は距離による設定分岐が存在しないので、
        // 駅設定テストで作成したスタブをそのまま利用する。
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest3OkHttpRequestMock());
        Test.startTest();
        GoogleApiUtil.setSchool(targetList);
        Test.stopTest();

        // 取得結果の確認
        for(Building__c building : targetList){

            if(building.Name == 'テストNo.3') {
                System.debug('★★★最終取得結果★★★');
                System.debug('-----小学校情報-----');
                // 小学校情報が１件設定されていることを確認
                System.debug('小学校1：'+building.PrimarySchool1__c);
                System.debug('小学校までの距離１：'+building.PrimarySchoolDistance1__c);
                System.debug('小学校までの時間（分）１：'+building.PrimarySchoolWalkTime1__c);
                // 以下はnullが設定されていること
                System.debug('小学校2：'+building.PrimarySchool2__c);
                System.debug('小学校までの距離２：'+building.PrimarySchoolDistance2__c);
                System.debug('小学校までの時間（分）２：'+building.PrimarySchoolWalkTime2__c);
                System.debug('小学校3：'+building.PrimarySchool3__c);
                System.debug('小学校までの距離３：'+building.PrimarySchoolDistance3__c);
                System.debug('小学校までの時間（分）３：'+building.PrimarySchoolWalkTime3__c);
                System.debug('-----中学校情報-----');
                // 中学校情報が１件設定されていることを確認
                System.debug('中学校1：'+building.JuniorHighSchool1__c);
                System.debug('中学校までの距離１：'+building.JuniorHighSchoolDistance1__c);
                System.debug('中学校までの時間（分）１：'+building.JuniorHighSchoolWalkTime1__c);
                // 以下はnullが設定されていること
                System.debug('中学校2：'+building.JuniorHighSchool2__c);
                System.debug('中学校までの距離２：'+building.JuniorHighSchoolDistance2__c);
                System.debug('中学校までの時間（分）２：'+building.JuniorHighSchoolWalkTime2__c);
                System.debug('中学校3：'+building.JuniorHighSchool3__c);
                System.debug('中学校までの距離３：'+building.JuniorHighSchoolDistance3__c);
                System.debug('中学校までの時間（分）３：'+building.JuniorHighSchoolWalkTime3__c);
            }
        }
    }

    // 対象の小学校が１件、中学校が１件存在する場合のテストパターン（距離取得ＮＧ）
    @isTest static void checkSetSchoolS1T1Ng(){
        System.debug('-------------対象の小学校が１件、中学校が１件存在するテストパターン（距離取得ＮＧ）-------------');
        
        // 小学校情報の登録
        List<School__c> schoolList = new List<School__c>();
        // 小学校１件目
        School__c addSchool = new School__c();
        addSchool.OwnerId = UserInfo.getUserId();
        addSchool.Name = '小学校１';
        addSchool.Latitude__c = 35.0;
        addSchool.Longitude__c = 136.0;
        addSchool.Type__c = CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL;
        schoolList.add(addSchool);

        // 中学校情報の登録
        // 中学校１件目
        addSchool = new School__c();
        addSchool.OwnerId = UserInfo.getUserId();
        addSchool.Name = '中学校１';
        addSchool.Latitude__c = 35.0;
        addSchool.Longitude__c = 136.0;
        addSchool.Type__c = CommonConst.SCHOOL_TYPE_JUNIORHIGHSCHOOL;
        schoolList.add(addSchool);

        insert schoolList;

        // 学区情報の登録
        List<SchoolArea__c> schoolAreaList = new List<SchoolArea__c>();
        School__c getPriSchool = [select Id from School__c 
                                where Name = '小学校１' and Type__c = :CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL];
        School__c getJhSchool = [select Id from School__c 
                                where Name = '中学校１' and Type__c = :CommonConst.SCHOOL_TYPE_JUNIORHIGHSCHOOL];
        // 学区１件目
        SchoolArea__c addSchoolArea = new SchoolArea__c();
        addSchoolArea.School__c = getPriSchool.Id;
        addSchoolArea.Name = '学区１';
        addSchoolArea.State__c = '大阪府';
        addSchoolArea.City__c = '大阪市大阪町';
        schoolAreaList.add(addSchoolArea);

        insert schoolAreaList;

        // 進学情報の登録
        List<Advancement__c> advancementList = new List<Advancement__c>();
        // 進学１件目
        Advancement__c addAdvancement = new Advancement__c();
        addAdvancement.PrimarySchool__c = getPriSchool.Id;
        addAdvancement.JuniorHighSchool__c = getJhSchool.Id;
        advancementList.add(addAdvancement);

        insert advancementList;


        // 必要なデータの設定
        List<Building__c> targetList = new List<Building__c>();

        //テストNo.3のデータセット
        Building__c addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'テストNo.3';
        addBuilding.Latitude__c = 35.0;
        addBuilding.Longitude__c = 136.0;
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        addBuilding.ChoazaCode__c  = '12345678901';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);

        // コールアウトクラスのモッククラスをセット
        // 小中学校は距離による設定分岐が存在しないので、
        // 駅設定テストで作成したスタブをそのまま利用する。
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest3NgHttpRequestMock());
        Test.startTest();
        GoogleApiUtil.setSchool(targetList);
        Test.stopTest();

        // 取得結果の確認
        for(Building__c building : targetList){

            if(building.Name == 'テストNo.3') {
                System.debug('★★★最終取得結果★★★');
                System.debug('-----小学校情報-----');
                // 小学校情報が１件設定されていることを確認
                System.debug('小学校1：'+building.PrimarySchool1__c);
                System.debug('小学校までの距離１：'+building.PrimarySchoolDistance1__c);
                System.debug('小学校までの時間（分）１：'+building.PrimarySchoolWalkTime1__c);
                // 以下はnullが設定されていること
                System.debug('小学校2：'+building.PrimarySchool2__c);
                System.debug('小学校までの距離２：'+building.PrimarySchoolDistance2__c);
                System.debug('小学校までの時間（分）２：'+building.PrimarySchoolWalkTime2__c);
                System.debug('小学校3：'+building.PrimarySchool3__c);
                System.debug('小学校までの距離３：'+building.PrimarySchoolDistance3__c);
                System.debug('小学校までの時間（分）３：'+building.PrimarySchoolWalkTime3__c);
                System.debug('-----中学校情報-----');
                // 中学校情報が１件設定されていることを確認
                System.debug('中学校1：'+building.JuniorHighSchool1__c);
                System.debug('中学校までの距離１：'+building.JuniorHighSchoolDistance1__c);
                System.debug('中学校までの時間（分）１：'+building.JuniorHighSchoolWalkTime1__c);
                // 以下はnullが設定されていること
                System.debug('中学校2：'+building.JuniorHighSchool2__c);
                System.debug('中学校までの距離２：'+building.JuniorHighSchoolDistance2__c);
                System.debug('中学校までの時間（分）２：'+building.JuniorHighSchoolWalkTime2__c);
                System.debug('中学校3：'+building.JuniorHighSchool3__c);
                System.debug('中学校までの距離３：'+building.JuniorHighSchoolDistance3__c);
                System.debug('中学校までの時間（分）３：'+building.JuniorHighSchoolWalkTime3__c);
            }
        }
    }

    // 対象の小学校が１件、中学校が２件存在する場合のテストパターン
    @isTest static void checkSetSchoolS1T2(){
        System.debug('-------------対象の小学校が１件、中学校が２件存在するテストパターン-------------');
        
        // 小学校情報の登録
        List<School__c> schoolList = new List<School__c>();
        // 小学校１件目
        School__c addSchool = new School__c();
        addSchool.OwnerId = UserInfo.getUserId();
        addSchool.Name = '小学校１';
        addSchool.Latitude__c = 35.0;
        addSchool.Longitude__c = 136.0;
        addSchool.Type__c = CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL;
        schoolList.add(addSchool);

        // 中学校情報の登録
        // 中学校１件目
        addSchool = new School__c();
        addSchool.OwnerId = UserInfo.getUserId();
        addSchool.Name = '中学１';
        addSchool.Latitude__c = 35.0;
        addSchool.Longitude__c = 136.0;
        addSchool.Type__c = CommonConst.SCHOOL_TYPE_JUNIORHIGHSCHOOL;
        schoolList.add(addSchool);
        // 中学校２件目
        addSchool = new School__c();
        addSchool.OwnerId = UserInfo.getUserId();
        addSchool.Name = '中学２';
        addSchool.Latitude__c = 35.0;
        addSchool.Longitude__c = 136.0;
        addSchool.Type__c = CommonConst.SCHOOL_TYPE_JUNIORHIGHSCHOOL;
        schoolList.add(addSchool);

        insert schoolList;

        // 学区情報の登録
        List<SchoolArea__c> schoolAreaList = new List<SchoolArea__c>();
        School__c getPriSchool = [select Id from School__c 
                                where Name = '小学校１' and Type__c = :CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL];
        School__c getJhSchool1 = [select Id from School__c 
                                where Name = '中学１' and Type__c = :CommonConst.SCHOOL_TYPE_JUNIORHIGHSCHOOL];
        School__c getJhSchool2 = [select Id from School__c 
                                where Name = '中学２' and Type__c = :CommonConst.SCHOOL_TYPE_JUNIORHIGHSCHOOL];

System.debug('中学１：'+getJhSchool1.Id);
System.debug('中学２：'+getJhSchool2.Id);

                                // 学区１件目
        SchoolArea__c addSchoolArea = new SchoolArea__c();
        addSchoolArea.School__c = getPriSchool.Id;
        addSchoolArea.Name = '学区１';
        addSchoolArea.State__c = '大阪府';
        addSchoolArea.City__c = '大阪市大阪町';
        schoolAreaList.add(addSchoolArea);

        insert schoolAreaList;

        // 進学情報の登録
        List<Advancement__c> advancementList = new List<Advancement__c>();
        // 進学１件目
        Advancement__c addAdvancement = new Advancement__c();
        addAdvancement.PrimarySchool__c = getPriSchool.Id;
        addAdvancement.JuniorHighSchool__c = getJhSchool1.Id;
        advancementList.add(addAdvancement);
        // 進学２件目
        addAdvancement = new Advancement__c();
        addAdvancement.PrimarySchool__c = getPriSchool.Id;
        addAdvancement.JuniorHighSchool__c = getJhSchool2.Id;
        advancementList.add(addAdvancement);

        insert advancementList;


        // 必要なデータの設定
        List<Building__c> targetList = new List<Building__c>();

        //テストNo.4のデータセット
        Building__c addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'テストNo.4';
        addBuilding.Latitude__c = 35.0;
        addBuilding.Longitude__c = 136.0;
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        addBuilding.ChoazaCode__c  = '12345678901';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);

        // コールアウトクラスのモッククラスをセット
        // 小中学校は距離による設定分岐が存在しないので、
        // 駅設定テストで作成したスタブをそのまま利用する。
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest3OkHttpRequestMock());
        Test.startTest();
        GoogleApiUtil.setSchool(targetList);
        Test.stopTest();

        // 取得結果の確認
        for(Building__c building : targetList){

            if(building.Name == 'テストNo.4') {
                System.debug('★★★最終取得結果★★★');
                System.debug('-----小学校情報-----');
                // 小学校情報が１件設定されていることを確認
                System.debug('小学校1：'+building.PrimarySchool1__c);
                System.debug('小学校までの距離１：'+building.PrimarySchoolDistance1__c);
                System.debug('小学校までの時間（分）１：'+building.PrimarySchoolWalkTime1__c);
                // 以下はnullが設定されていること
                System.debug('小学校2：'+building.PrimarySchool2__c);
                System.debug('小学校までの距離２：'+building.PrimarySchoolDistance2__c);
                System.debug('小学校までの時間（分）２：'+building.PrimarySchoolWalkTime2__c);
                System.debug('小学校3：'+building.PrimarySchool3__c);
                System.debug('小学校までの距離３：'+building.PrimarySchoolDistance3__c);
                System.debug('小学校までの時間（分）３：'+building.PrimarySchoolWalkTime3__c);
                System.debug('-----中学校情報-----');
                // 中学校情報が１件設定されていることを確認
                System.debug('中学校1：'+building.JuniorHighSchool1__c);
                System.debug('中学校までの距離１：'+building.JuniorHighSchoolDistance1__c);
                System.debug('中学校までの時間（分）１：'+building.JuniorHighSchoolWalkTime1__c);
                // 以下はnullが設定されていること
                System.debug('中学校2：'+building.JuniorHighSchool2__c);
                System.debug('中学校までの距離２：'+building.JuniorHighSchoolDistance2__c);
                System.debug('中学校までの時間（分）２：'+building.JuniorHighSchoolWalkTime2__c);
                System.debug('中学校3：'+building.JuniorHighSchool3__c);
                System.debug('中学校までの距離３：'+building.JuniorHighSchoolDistance3__c);
                System.debug('中学校までの時間（分）３：'+building.JuniorHighSchoolWalkTime3__c);
            }
        }
    }

    // 対象の小学校が２件、中学校が２件存在する場合のテストパターン
    @isTest static void checkSetSchoolS2T2(){
        System.debug('-------------対象の小学校が２件、中学校が２件存在するテストパターン-------------');
        
        // 小学校情報の登録
        List<School__c> schoolList = new List<School__c>();
        // 小学校１件目
        School__c addSchool = new School__c();
        addSchool.OwnerId = UserInfo.getUserId();
        addSchool.Name = '小学校１';
        addSchool.Latitude__c = 35.0;
        addSchool.Longitude__c = 136.0;
        addSchool.Type__c = CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL;
        schoolList.add(addSchool);
        // 小学校２件目
        addSchool = new School__c();
        addSchool.OwnerId = UserInfo.getUserId();
        addSchool.Name = '小学校２';
        addSchool.Latitude__c = 35.0;
        addSchool.Longitude__c = 136.0;
        addSchool.Type__c = CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL;
        schoolList.add(addSchool);

        // 中学校情報の登録
        // 中学校１件目
        addSchool = new School__c();
        addSchool.OwnerId = UserInfo.getUserId();
        addSchool.Name = '中学１';
        addSchool.Latitude__c = 35.0;
        addSchool.Longitude__c = 136.0;
        addSchool.Type__c = CommonConst.SCHOOL_TYPE_JUNIORHIGHSCHOOL;
        schoolList.add(addSchool);
        // 中学校２件目
        addSchool = new School__c();
        addSchool.OwnerId = UserInfo.getUserId();
        addSchool.Name = '中学２';
        addSchool.Latitude__c = 35.0;
        addSchool.Longitude__c = 136.0;
        addSchool.Type__c = CommonConst.SCHOOL_TYPE_JUNIORHIGHSCHOOL;
        schoolList.add(addSchool);

        insert schoolList;

        // 学区情報の登録
        List<SchoolArea__c> schoolAreaList = new List<SchoolArea__c>();
        School__c getPriSchool1 = [select Id from School__c 
                                where Name = '小学校１' and Type__c = :CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL];
        School__c getPriSchool2 = [select Id from School__c 
                                where Name = '小学校２' and Type__c = :CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL];
        School__c getJhSchool1 = [select Id from School__c 
                                where Name = '中学１' and Type__c = :CommonConst.SCHOOL_TYPE_JUNIORHIGHSCHOOL];
        School__c getJhSchool2 = [select Id from School__c 
                                where Name = '中学２' and Type__c = :CommonConst.SCHOOL_TYPE_JUNIORHIGHSCHOOL];

        // 学区１件目
        SchoolArea__c addSchoolArea = new SchoolArea__c();
        addSchoolArea.School__c = getPriSchool1.Id;
        addSchoolArea.Name = '学区１';
        addSchoolArea.State__c = '大阪府';
        addSchoolArea.City__c = '大阪市大阪町';
        schoolAreaList.add(addSchoolArea);
        // 学区２件目
        addSchoolArea = new SchoolArea__c();
        addSchoolArea.School__c = getPriSchool2.Id;
        addSchoolArea.Name = '学区２';
        addSchoolArea.State__c = '大阪府';
        addSchoolArea.City__c = '大阪市大阪町';
        schoolAreaList.add(addSchoolArea);

        insert schoolAreaList;

        // 進学情報の登録
        List<Advancement__c> advancementList = new List<Advancement__c>();
        // 進学１件目
        Advancement__c addAdvancement = new Advancement__c();
        addAdvancement.PrimarySchool__c = getPriSchool1.Id;
        addAdvancement.JuniorHighSchool__c = getJhSchool1.Id;
        advancementList.add(addAdvancement);
        // 進学２件目
        addAdvancement = new Advancement__c();
        addAdvancement.PrimarySchool__c = getPriSchool2.Id;
        addAdvancement.JuniorHighSchool__c = getJhSchool2.Id;
        advancementList.add(addAdvancement);

        insert advancementList;


        // 必要なデータの設定
        List<Building__c> targetList = new List<Building__c>();

        //テストNo.5のデータセット
        Building__c addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'テストNo.5';
        addBuilding.Latitude__c = 35.0;
        addBuilding.Longitude__c = 136.0;
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        addBuilding.ChoazaCode__c  = '12345678901';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);

        // コールアウトクラスのモッククラスをセット
        // 小中学校は距離による設定分岐が存在しないので、
        // 駅設定テストで作成したスタブをそのまま利用する。
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest3OkHttpRequestMock());
        Test.startTest();
        GoogleApiUtil.setSchool(targetList);
        Test.stopTest();

        // 取得結果の確認
        for(Building__c building : targetList){

            if(building.Name == 'テストNo.5') {
                System.debug('★★★最終取得結果★★★');
                System.debug('-----小学校情報-----');
                // 小学校情報が２件設定されていることを確認
                System.debug('小学校1：'+building.PrimarySchool1__c);
                System.debug('小学校までの距離１：'+building.PrimarySchoolDistance1__c);
                System.debug('小学校までの時間（分）１：'+building.PrimarySchoolWalkTime1__c);
                System.debug('小学校2：'+building.PrimarySchool2__c);
                System.debug('小学校までの距離２：'+building.PrimarySchoolDistance2__c);
                System.debug('小学校までの時間（分）２：'+building.PrimarySchoolWalkTime2__c);
                // 以下はnullが設定されていること
                System.debug('小学校3：'+building.PrimarySchool3__c);
                System.debug('小学校までの距離３：'+building.PrimarySchoolDistance3__c);
                System.debug('小学校までの時間（分）３：'+building.PrimarySchoolWalkTime3__c);
                System.debug('-----中学校情報-----');
                // 中学校情報が２件設定されていることを確認
                System.debug('中学校1：'+building.JuniorHighSchool1__c);
                System.debug('中学校までの距離１：'+building.JuniorHighSchoolDistance1__c);
                System.debug('中学校までの時間（分）１：'+building.JuniorHighSchoolWalkTime1__c);
                System.debug('中学校2：'+building.JuniorHighSchool2__c);
                System.debug('中学校までの距離２：'+building.JuniorHighSchoolDistance2__c);
                System.debug('中学校までの時間（分）２：'+building.JuniorHighSchoolWalkTime2__c);
                // 以下はnullが設定されていること
                System.debug('中学校3：'+building.JuniorHighSchool3__c);
                System.debug('中学校までの距離３：'+building.JuniorHighSchoolDistance3__c);
                System.debug('中学校までの時間（分）３：'+building.JuniorHighSchoolWalkTime3__c);
            }
        }
    }

   // 対象の小学校が３件、中学校が３件存在する場合のテストパターン
   @isTest static void checkSetSchoolS3T3(){
    System.debug('-------------対象の小学校が３件、中学校が３件存在するテストパターン-------------');
    
        // 小学校情報の登録
        List<School__c> schoolList = new List<School__c>();
        // 小学校１件目
        School__c addSchool = new School__c();
        addSchool.OwnerId = UserInfo.getUserId();
        addSchool.Name = '小学校１';
        addSchool.Latitude__c = 35.0;
        addSchool.Longitude__c = 136.0;
        addSchool.Type__c = CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL;
        schoolList.add(addSchool);
        // 小学校２件目
        addSchool = new School__c();
        addSchool.OwnerId = UserInfo.getUserId();
        addSchool.Name = '小学校２';
        addSchool.Latitude__c = 35.0;
        addSchool.Longitude__c = 136.0;
        addSchool.Type__c = CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL;
        schoolList.add(addSchool);
        // 小学校３件目
        addSchool = new School__c();
        addSchool.OwnerId = UserInfo.getUserId();
        addSchool.Name = '小学校３';
        addSchool.Latitude__c = 35.0;
        addSchool.Longitude__c = 136.0;
        addSchool.Type__c = CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL;
        schoolList.add(addSchool);

        // 中学校情報の登録
        // 中学校１件目
        addSchool = new School__c();
        addSchool.OwnerId = UserInfo.getUserId();
        addSchool.Name = '中学１';
        addSchool.Latitude__c = 35.0;
        addSchool.Longitude__c = 136.0;
        addSchool.Type__c = CommonConst.SCHOOL_TYPE_JUNIORHIGHSCHOOL;
        schoolList.add(addSchool);
        // 中学校２件目
        addSchool = new School__c();
        addSchool.OwnerId = UserInfo.getUserId();
        addSchool.Name = '中学２';
        addSchool.Latitude__c = 35.0;
        addSchool.Longitude__c = 136.0;
        addSchool.Type__c = CommonConst.SCHOOL_TYPE_JUNIORHIGHSCHOOL;
        schoolList.add(addSchool);
        // 中学校３件目
        addSchool = new School__c();
        addSchool.OwnerId = UserInfo.getUserId();
        addSchool.Name = '中学３';
        addSchool.Latitude__c = 35.0;
        addSchool.Longitude__c = 136.0;
        addSchool.Type__c = CommonConst.SCHOOL_TYPE_JUNIORHIGHSCHOOL;
        schoolList.add(addSchool);

        insert schoolList;

        // 学区情報の登録
        List<SchoolArea__c> schoolAreaList = new List<SchoolArea__c>();
        School__c getPriSchool1 = [select Id from School__c 
                                where Name = '小学校１' and Type__c = :CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL];
        School__c getPriSchool2 = [select Id from School__c 
                                where Name = '小学校２' and Type__c = :CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL];
        School__c getPriSchool3 = [select Id from School__c 
                                where Name = '小学校３' and Type__c = :CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL];
        School__c getJhSchool1 = [select Id from School__c 
                                where Name = '中学１' and Type__c = :CommonConst.SCHOOL_TYPE_JUNIORHIGHSCHOOL];
        School__c getJhSchool2 = [select Id from School__c 
                                where Name = '中学２' and Type__c = :CommonConst.SCHOOL_TYPE_JUNIORHIGHSCHOOL];
        School__c getJhSchool3 = [select Id from School__c 
                                where Name = '中学３' and Type__c = :CommonConst.SCHOOL_TYPE_JUNIORHIGHSCHOOL];

        // 学区１件目
        SchoolArea__c addSchoolArea = new SchoolArea__c();
        addSchoolArea.School__c = getPriSchool1.Id;
        addSchoolArea.Name = '学区１';
        addSchoolArea.State__c = '大阪府';
        addSchoolArea.City__c = '大阪市大阪町';
        schoolAreaList.add(addSchoolArea);
        // 学区２件目
        addSchoolArea = new SchoolArea__c();
        addSchoolArea.School__c = getPriSchool2.Id;
        addSchoolArea.Name = '学区２';
        addSchoolArea.State__c = '大阪府';
        addSchoolArea.City__c = '大阪市大阪町';
        schoolAreaList.add(addSchoolArea);
        // 学区３件目
        addSchoolArea = new SchoolArea__c();
        addSchoolArea.School__c = getPriSchool3.Id;
        addSchoolArea.Name = '学区３';
        addSchoolArea.State__c = '大阪府';
        addSchoolArea.City__c = '大阪市大阪町';
        schoolAreaList.add(addSchoolArea);

        insert schoolAreaList;

        // 進学情報の登録
        List<Advancement__c> advancementList = new List<Advancement__c>();
        // 進学１件目
        Advancement__c addAdvancement = new Advancement__c();
        addAdvancement.PrimarySchool__c = getPriSchool1.Id;
        addAdvancement.JuniorHighSchool__c = getJhSchool1.Id;
        advancementList.add(addAdvancement);
        // 進学２件目
        addAdvancement = new Advancement__c();
        addAdvancement.PrimarySchool__c = getPriSchool2.Id;
        addAdvancement.JuniorHighSchool__c = getJhSchool2.Id;
        advancementList.add(addAdvancement);
        // 進学３件目
        addAdvancement = new Advancement__c();
        addAdvancement.PrimarySchool__c = getPriSchool3.Id;
        addAdvancement.JuniorHighSchool__c = getJhSchool3.Id;
        advancementList.add(addAdvancement);

        insert advancementList;


        // 必要なデータの設定
        List<Building__c> targetList = new List<Building__c>();

        //テストNo.6のデータセット
        Building__c addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'テストNo.6';
        addBuilding.Latitude__c = 35.0;
        addBuilding.Longitude__c = 136.0;
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        addBuilding.ChoazaCode__c  = '12345678901';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);

        // コールアウトクラスのモッククラスをセット
        // 小中学校は距離による設定分岐が存在しないので、
        // 駅設定テストで作成したスタブをそのまま利用する。
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest3OkHttpRequestMock());
        Test.startTest();
        GoogleApiUtil.setSchool(targetList);
        Test.stopTest();

        // 取得結果の確認
        for(Building__c building : targetList){

            if(building.Name == 'テストNo.6') {
                System.debug('★★★最終取得結果★★★');
                System.debug('-----小学校情報-----');
                // 小学校情報が３件設定されていることを確認
                System.debug('小学校1：'+building.PrimarySchool1__c);
                System.debug('小学校までの距離１：'+building.PrimarySchoolDistance1__c);
                System.debug('小学校までの時間（分）１：'+building.PrimarySchoolWalkTime1__c);
                System.debug('小学校2：'+building.PrimarySchool2__c);
                System.debug('小学校までの距離２：'+building.PrimarySchoolDistance2__c);
                System.debug('小学校までの時間（分）２：'+building.PrimarySchoolWalkTime2__c);
                System.debug('小学校3：'+building.PrimarySchool3__c);
                System.debug('小学校までの距離３：'+building.PrimarySchoolDistance3__c);
                System.debug('小学校までの時間（分）３：'+building.PrimarySchoolWalkTime3__c);
                System.debug('-----中学校情報-----');
                // 中学校情報が３件設定されていることを確認
                System.debug('中学校1：'+building.JuniorHighSchool1__c);
                System.debug('中学校までの距離１：'+building.JuniorHighSchoolDistance1__c);
                System.debug('中学校までの時間（分）１：'+building.JuniorHighSchoolWalkTime1__c);
                System.debug('中学校2：'+building.JuniorHighSchool2__c);
                System.debug('中学校までの距離２：'+building.JuniorHighSchoolDistance2__c);
                System.debug('中学校までの時間（分）２：'+building.JuniorHighSchoolWalkTime2__c);
                System.debug('中学校3：'+building.JuniorHighSchool3__c);
                System.debug('中学校までの距離３：'+building.JuniorHighSchoolDistance3__c);
                System.debug('中学校までの時間（分）３：'+building.JuniorHighSchoolWalkTime3__c);
            }
        }
    }

    // 対象の小学校が４件、中学校が４件存在する場合のテストパターン
   @isTest static void checkSetSchoolS4T4(){
    System.debug('-------------対象の小学校が４件、中学校が４件存在するテストパターン-------------');
    
        // 小学校情報の登録
        List<School__c> schoolList = new List<School__c>();
        // 小学校１件目
        School__c addSchool = new School__c();
        addSchool.OwnerId = UserInfo.getUserId();
        addSchool.Name = '小学校１';
        addSchool.Latitude__c = 35.0;
        addSchool.Longitude__c = 136.0;
        addSchool.Type__c = CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL;
        schoolList.add(addSchool);
        // 小学校２件目
        addSchool = new School__c();
        addSchool.OwnerId = UserInfo.getUserId();
        addSchool.Name = '小学校２';
        addSchool.Latitude__c = 35.0;
        addSchool.Longitude__c = 136.0;
        addSchool.Type__c = CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL;
        schoolList.add(addSchool);
        // 小学校３件目
        addSchool = new School__c();
        addSchool.OwnerId = UserInfo.getUserId();
        addSchool.Name = '小学校３';
        addSchool.Latitude__c = 35.0;
        addSchool.Longitude__c = 136.0;
        addSchool.Type__c = CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL;
        schoolList.add(addSchool);
        // 小学校４件目
        addSchool = new School__c();
        addSchool.OwnerId = UserInfo.getUserId();
        addSchool.Name = '小学校４';
        addSchool.Latitude__c = 35.0;
        addSchool.Longitude__c = 136.0;
        addSchool.Type__c = CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL;
        schoolList.add(addSchool);

        // 中学校情報の登録
        // 中学校１件目
        addSchool = new School__c();
        addSchool.OwnerId = UserInfo.getUserId();
        addSchool.Name = '中学１';
        addSchool.Latitude__c = 35.0;
        addSchool.Longitude__c = 136.0;
        addSchool.Type__c = CommonConst.SCHOOL_TYPE_JUNIORHIGHSCHOOL;
        schoolList.add(addSchool);
        // 中学校２件目
        addSchool = new School__c();
        addSchool.OwnerId = UserInfo.getUserId();
        addSchool.Name = '中学２';
        addSchool.Latitude__c = 35.0;
        addSchool.Longitude__c = 136.0;
        addSchool.Type__c = CommonConst.SCHOOL_TYPE_JUNIORHIGHSCHOOL;
        schoolList.add(addSchool);
        // 中学校３件目
        addSchool = new School__c();
        addSchool.OwnerId = UserInfo.getUserId();
        addSchool.Name = '中学３';
        addSchool.Latitude__c = 35.0;
        addSchool.Longitude__c = 136.0;
        addSchool.Type__c = CommonConst.SCHOOL_TYPE_JUNIORHIGHSCHOOL;
        schoolList.add(addSchool);
        // 中学校４件目
        addSchool = new School__c();
        addSchool.OwnerId = UserInfo.getUserId();
        addSchool.Name = '中学４';
        addSchool.Latitude__c = 35.0;
        addSchool.Longitude__c = 136.0;
        addSchool.Type__c = CommonConst.SCHOOL_TYPE_JUNIORHIGHSCHOOL;
        schoolList.add(addSchool);

        insert schoolList;

        // 学区情報の登録
        List<SchoolArea__c> schoolAreaList = new List<SchoolArea__c>();
        School__c getPriSchool1 = [select Id from School__c 
                                where Name = '小学校１' and Type__c = :CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL];
        School__c getPriSchool2 = [select Id from School__c 
                                where Name = '小学校２' and Type__c = :CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL];
        School__c getPriSchool3 = [select Id from School__c 
                                where Name = '小学校３' and Type__c = :CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL];
        School__c getPriSchool4 = [select Id from School__c 
                                where Name = '小学校４' and Type__c = :CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL];
        School__c getJhSchool1 = [select Id from School__c 
                                where Name = '中学１' and Type__c = :CommonConst.SCHOOL_TYPE_JUNIORHIGHSCHOOL];
        School__c getJhSchool2 = [select Id from School__c 
                                where Name = '中学２' and Type__c = :CommonConst.SCHOOL_TYPE_JUNIORHIGHSCHOOL];
        School__c getJhSchool3 = [select Id from School__c 
                                where Name = '中学３' and Type__c = :CommonConst.SCHOOL_TYPE_JUNIORHIGHSCHOOL];
        School__c getJhSchool4 = [select Id from School__c 
                                where Name = '中学４' and Type__c = :CommonConst.SCHOOL_TYPE_JUNIORHIGHSCHOOL];

        // 学区１件目
        SchoolArea__c addSchoolArea = new SchoolArea__c();
        addSchoolArea.School__c = getPriSchool1.Id;
        addSchoolArea.Name = '学区１';
        addSchoolArea.State__c = '大阪府';
        addSchoolArea.City__c = '大阪市大阪町';
        schoolAreaList.add(addSchoolArea);
        // 学区２件目
        addSchoolArea = new SchoolArea__c();
        addSchoolArea.School__c = getPriSchool2.Id;
        addSchoolArea.Name = '学区２';
        addSchoolArea.State__c = '大阪府';
        addSchoolArea.City__c = '大阪市大阪町';
        schoolAreaList.add(addSchoolArea);
        // 学区３件目
        addSchoolArea = new SchoolArea__c();
        addSchoolArea.School__c = getPriSchool3.Id;
        addSchoolArea.Name = '学区３';
        addSchoolArea.State__c = '大阪府';
        addSchoolArea.City__c = '大阪市大阪町';
        schoolAreaList.add(addSchoolArea);
        // 学区４件目
        addSchoolArea = new SchoolArea__c();
        addSchoolArea.School__c = getPriSchool4.Id;
        addSchoolArea.Name = '学区４';
        addSchoolArea.State__c = '大阪府';
        addSchoolArea.City__c = '大阪市大阪町';
        schoolAreaList.add(addSchoolArea);

        insert schoolAreaList;

        // 進学情報の登録
        List<Advancement__c> advancementList = new List<Advancement__c>();
        // 進学１件目
        Advancement__c addAdvancement = new Advancement__c();
        addAdvancement.PrimarySchool__c = getPriSchool1.Id;
        addAdvancement.JuniorHighSchool__c = getJhSchool1.Id;
        advancementList.add(addAdvancement);
        // 進学２件目
        addAdvancement = new Advancement__c();
        addAdvancement.PrimarySchool__c = getPriSchool2.Id;
        addAdvancement.JuniorHighSchool__c = getJhSchool2.Id;
        advancementList.add(addAdvancement);
        // 進学３件目
        addAdvancement = new Advancement__c();
        addAdvancement.PrimarySchool__c = getPriSchool3.Id;
        addAdvancement.JuniorHighSchool__c = getJhSchool3.Id;
        advancementList.add(addAdvancement);
        // 進学４件目
        addAdvancement = new Advancement__c();
        addAdvancement.PrimarySchool__c = getPriSchool4.Id;
        addAdvancement.JuniorHighSchool__c = getJhSchool4.Id;
        advancementList.add(addAdvancement);

        insert advancementList;


        // 必要なデータの設定
        List<Building__c> targetList = new List<Building__c>();

        //テストNo.7のデータセット
        Building__c addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = 'テストNo.7';
        addBuilding.Latitude__c = 35.0;
        addBuilding.Longitude__c = 136.0;
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        addBuilding.ChoazaCode__c  = '12345678901';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);

        // コールアウトクラスのモッククラスをセット
        // 小中学校は距離による設定分岐が存在しないので、
        // 駅設定テストで作成したスタブをそのまま利用する。
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest3OkHttpRequestMock());
        Test.startTest();
        GoogleApiUtil.setSchool(targetList);
        Test.stopTest();

        // 取得結果の確認
        for(Building__c building : targetList){

            if(building.Name == 'テストNo.7') {
                System.debug('★★★最終取得結果★★★');
                System.debug('-----小学校情報-----');
                // 小学校情報が３件設定されていることを確認
                System.debug('小学校1：'+building.PrimarySchool1__c);
                System.debug('小学校までの距離１：'+building.PrimarySchoolDistance1__c);
                System.debug('小学校までの時間（分）１：'+building.PrimarySchoolWalkTime1__c);
                System.debug('小学校2：'+building.PrimarySchool2__c);
                System.debug('小学校までの距離２：'+building.PrimarySchoolDistance2__c);
                System.debug('小学校までの時間（分）２：'+building.PrimarySchoolWalkTime2__c);
                System.debug('小学校3：'+building.PrimarySchool3__c);
                System.debug('小学校までの距離３：'+building.PrimarySchoolDistance3__c);
                System.debug('小学校までの時間（分）３：'+building.PrimarySchoolWalkTime3__c);
                System.debug('-----中学校情報-----');
                // 中学校情報が３件設定されていることを確認
                System.debug('中学校1：'+building.JuniorHighSchool1__c);
                System.debug('中学校までの距離１：'+building.JuniorHighSchoolDistance1__c);
                System.debug('中学校までの時間（分）１：'+building.JuniorHighSchoolWalkTime1__c);
                System.debug('中学校2：'+building.JuniorHighSchool2__c);
                System.debug('中学校までの距離２：'+building.JuniorHighSchoolDistance2__c);
                System.debug('中学校までの時間（分）２：'+building.JuniorHighSchoolWalkTime2__c);
                System.debug('中学校3：'+building.JuniorHighSchool3__c);
                System.debug('中学校までの距離３：'+building.JuniorHighSchoolDistance3__c);
                System.debug('中学校までの時間（分）３：'+building.JuniorHighSchoolWalkTime3__c);
            }
        }
    }
}