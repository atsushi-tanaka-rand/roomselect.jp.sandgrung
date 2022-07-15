//周辺施設情報取得（周辺施設）のテストクラス No711要望対応 2022.3.30
@ isTest
private class GoogleApiUtilTest7 {
    
    @TestSetup
    // テストに利用するListを用意する。
    static void Setting(){

        // コンフィグ値を設定
        SystemConfig__c settings = new SystemConfig__c();
        settings.SearchStationRange__c = 5000;
        insert settings;

        // 路線を設定
        TrainRoute__c trainRoute = new TrainRoute__c();
        trainRoute.Name = 'テスト路線';
        insert trainRoute;

        //管理者プロファイルを取得
		Id profileId = [SELECT Id FROM Profile WHERE Name = 'システム管理者'].id;
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		User testUser = new User(LastName = 'Admin'	        //姓
				,Alias =  'alias'                           //別名
				,Email = 'GoogleApiUtilTest7@horaguchi.com'                   //メール
				,UserName =  'GoogleApiUtilTest7@horaguchi.com'  //ユーザ名
				,CommunityNickname ='テストニックネーム'     //ニックネーム
				,EmailEncodingKey = 'ISO-2022-JP'           //メールの文字コード
				,TimeZoneSidKey = 'Asia/Tokyo'              //タイムゾーン
				,LocaleSidKey = 'ja_JP'                     //地域
				,LanguageLocaleKey= 'ja'                    //言語
				,ProfileId = profileId                      //プロファイルID
		);
        System.runAs(thisUser) {
		insert testUser;      
        }
    }

    //物件が１件、周辺施設が１件取得できて対象外ではないのパターン
    @isTest static void Surroundtest001(){

        User thisUser = [SELECT Id FROM User WHERE UserName = 'GoogleApiUtilTest7@horaguchi.com'];
        List<Building__c> targetList = new List<Building__c>();
    
        //建物のデータセット
        Building__c addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = '建物1';
        addBuilding.Latitude__c = 35.0;
        addBuilding.Longitude__c = 136.0;
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);
    
        // コールアウトクラスのモッククラス（単一周辺施設）をセット
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest7OKHttpRequestMock());
        System.runAs(thisUser) {
            Test.startTest();
            GoogleApiUtil.setSurroundingFacilities(targetList);
            Test.stopTest();

            // MOCKの値を取得
            SurroundingFacility__c MockSF =[SELECT ID,Name,FacilityType__c,PlaceId__c From SurroundingFacility__c Where name ='周辺施設１'];
        
            // ★実行結果確認★
            // Mockの値が設定されたこと
            for(Building__c building : targetList){
                if(building.Name == '建物1') {
                    System.assertEquals(building.HighSchool__c, MockSF.Id);    
                }
            }
        }
    }

    //対象の物件が１件で、周辺施設が１件取得できて対象外の場合、登録されないのテストパターン
    @isTest static void Surroundtest002(){

        //必要なデータの設定
        User thisUser = [SELECT Id FROM User WHERE UserName = 'GoogleApiUtilTest7@horaguchi.com'];
        List<Building__c> targetList = new List<Building__c>();
    
        //建物のデータセット
        Building__c addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = '建物2';
        addBuilding.Latitude__c = 35.0;
        addBuilding.Longitude__c = 136.0;
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);

        // 対象外の周辺施設情報の登録
        List<SurroundingFacility__c> surroundingFacilityList = new List<SurroundingFacility__c>();
        SurroundingFacility__c surroundingFacility = new SurroundingFacility__c();
        surroundingFacility.OwnerId = UserInfo.getUserId();
        surroundingFacility.Name = '周辺施設１';
        surroundingFacility.PlaceId__c = 'testPlaceId';
        surroundingFacility.FacilityType__c = CommonConst.SURROUDING_FACILITY_TYPE_NOTAPPLICABLE;
        surroundingFacilityList.add(surroundingFacility);
        insert surroundingFacilityList;
    
        // コールアウトクラスのモッククラス（単一周辺施設）をセット
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest7OKHttpRequestMock());
        System.runAs(thisUser) {
            Test.startTest();
            GoogleApiUtil.setSurroundingFacilities(targetList);
            Test.stopTest();

            //★実行結果確認★
            // 対象外のため、周辺施設が設定されないこと
            for(Building__c building : targetList){
                if(building.Name == '建物2') {
                    System.assertEquals(building.HighSchool__c, null);    
                }
            }
        }
    }
    //対象の物件が１件、周辺施設が複数件取得できて対象外がない場合、
    //距離の近いものが正しく設定されるのテストパターン
    @isTest static void Surroundtest003(){

        //必要なデータの設定
        User thisUser = [SELECT Id FROM User WHERE UserName = 'GoogleApiUtilTest7@horaguchi.com'];
        List<Building__c> targetList = new List<Building__c>();
    
        //建物のデータセット
        Building__c addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = '建物3';
        addBuilding.Latitude__c = 35.0;
        addBuilding.Longitude__c = 136.0;
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        targetList.add(addBuilding);
    
        // コールアウトクラスのモッククラス（複数周辺施設）をセット
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest7OK2HttpRequestMock());
        System.runAs(thisUser) {
            Test.startTest();
            GoogleApiUtil.setSurroundingFacilities(targetList);
            Test.stopTest();

            // MOCKの値を取得
            SurroundingFacility__c MockSF =[SELECT ID,Name,FacilityType__c From SurroundingFacility__c Where name ='周辺施設１'];

            // ★実行結果確認★
            // Mockの値（周辺施設１）が設定されたこと
            for(Building__c building : targetList){
                if(building.Name == '建物3') {
                    System.assertEquals(building.HighSchool__c, MockSF.Id);  
                }
            }
        }
    }
    //対象の物件が１件で、周辺施設が複数件取得できて対象外が距離の一番近い物の場合、
    //次点の距離が近いものが正しく設定されるのテストパターン
    @isTest static void Surroundtest004(){

        //必要なデータの設定
        User thisUser = [SELECT Id FROM User WHERE UserName = 'GoogleApiUtilTest7@horaguchi.com'];
        List<Building__c> targetList = new List<Building__c>();
    
        //建物のデータセット
        Building__c addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = '建物4';
        addBuilding.Latitude__c = 35.0;
        addBuilding.Longitude__c = 136.0;
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        targetList.add(addBuilding);

        // 周辺施設１を対象外として登録
        List<SurroundingFacility__c> surroundingFacilityList = new List<SurroundingFacility__c>();
        SurroundingFacility__c surroundingFacility = new SurroundingFacility__c();
        surroundingFacility.OwnerId = UserInfo.getUserId();
        surroundingFacility.Name = '周辺施設１';
        surroundingFacility.PlaceId__c = 'testPlaceId';
        surroundingFacility.FacilityType__c = CommonConst.SURROUDING_FACILITY_TYPE_NOTAPPLICABLE;
        surroundingFacilityList.add(surroundingFacility);
        insert surroundingFacilityList;
    
        // コールアウトクラスのモッククラス（複数周辺施設）をセット
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest7OK2HttpRequestMock());
        System.runAs(thisUser) {
            Test.startTest();
            GoogleApiUtil.setSurroundingFacilities(targetList);
            Test.stopTest();
    
            // 周辺施設２を取得
            SurroundingFacility__c MockSF =[SELECT ID,Name,FacilityType__c From SurroundingFacility__c Where name ='周辺施設２'];

            // ★実行結果確認★
            // Mock（周辺施設２）の値が設定されたこと
            for(Building__c building : targetList){
                if(building.Name == '建物4') {
                    System.assertEquals(building.HighSchool__c, MockSF.Id);  
                }
            }
        }
    }
    //対象の物件が複数件の場合、
    //周辺施設が１件取得できて対象外ではない場合、正しく設定されるのテストパターン

    @isTest static void Surroundtest005(){

        User thisUser = [SELECT Id FROM User WHERE UserName = 'GoogleApiUtilTest7@horaguchi.com'];
        List<Building__c> targetList = new List<Building__c>();
        
        //建物Aのデータセット
        Building__c addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = '建物5A';
        addBuilding.Latitude__c = 35.0;
        addBuilding.Longitude__c = 136.0;
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);
        //建物Bのデータセット
        addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = '建物5B';
        addBuilding.Latitude__c = 35.0;
        addBuilding.Longitude__c = 136.0;
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９８';
        addBuilding.recalculateFormulas();
        targetList.add(addBuilding);
        insert targetList;
        
        // コールアウトクラスのモッククラス（単一周辺施設）をセット
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest7OKHttpRequestMock());
        System.runAs(thisUser) {
            Test.startTest();
            GoogleApiUtil.setSurroundingFacilities(targetList);
            Test.stopTest();

            // MOCKの値を取得
            SurroundingFacility__c MockSF =[SELECT ID,Name,FacilityType__c From SurroundingFacility__c Where name ='周辺施設１'];
        
            //★実行結果確認★
            // Mockの値が設定されたこと
            for(Building__c building : targetList){
                if(building.Name == '建物5A') {
                    System.assertEquals(building.HighSchool__c, MockSF.Id);  
                }
                if(building.Name == '建物5B') {
                    System.assertEquals(building.HighSchool__c, MockSF.Id);  
                }
            }
        }   
    }
    //対象の物件が複数件の場合、
    //周辺施設が１件取得できて対象外の場合、登録されないのテストパターン
    @isTest static void Surroundtest006(){

        User thisUser = [SELECT Id FROM User WHERE UserName = 'GoogleApiUtilTest7@horaguchi.com'];
        List<Building__c> targetList = new List<Building__c>();
        
        //建物Aのデータセット
        Building__c addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = '建物6A';
        addBuilding.Latitude__c = 35.0;
        addBuilding.Longitude__c = 136.0;
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        targetList.add(addBuilding);
        //建物Bのデータセット
        addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = '建物6B';
        addBuilding.Latitude__c = 35.0;
        addBuilding.Longitude__c = 136.0;
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９８';
        targetList.add(addBuilding);
        insert targetList;

        // 対象外の周辺施設情報の登録
        List<SurroundingFacility__c> surroundingFacilityList = new List<SurroundingFacility__c>();
        SurroundingFacility__c surroundingFacility = new SurroundingFacility__c();
        surroundingFacility.OwnerId = UserInfo.getUserId();
        surroundingFacility.Name = 'テスト周辺施設';
        surroundingFacility.PlaceId__c = 'testPlaceId';
        surroundingFacility.FacilityType__c = CommonConst.SURROUDING_FACILITY_TYPE_NOTAPPLICABLE;
        surroundingFacilityList.add(surroundingFacility);
        insert surroundingFacilityList;
        
        // コールアウトクラスのモッククラス（単一周辺施設）をセット
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest7OKHttpRequestMock());
        System.runAs(thisUser) {
            Test.startTest();
            GoogleApiUtil.setSurroundingFacilities(targetList);
            Test.stopTest();

            //★実行結果確認★
            // 対象外のため、周辺施設が設定されないこと
            for(Building__c building : targetList){
                if(building.Name == '建物6A') {
                    System.assertEquals(building.HighSchool__c, null);  
                }
                if(building.Name == '建物6B') {
                    System.assertEquals(building.HighSchool__c, null);  
                }
            }
        }
    }
    //対象の物件が複数件の場合、
    //周辺施設が複数件取得できて対象外がない場合、距離の近いものが正しく設定されるのテストパターン
    @isTest static void Surroundtest007(){

        User thisUser = [SELECT Id FROM User WHERE UserName = 'GoogleApiUtilTest7@horaguchi.com'];
        List<Building__c> targetList = new List<Building__c>();
        
        //建物Aのデータセット
        Building__c addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = '建物7A';
        addBuilding.Latitude__c = 35.0;
        addBuilding.Longitude__c = 136.0;
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        targetList.add(addBuilding);
        //建物Bのデータセット
        addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = '建物7B';
        addBuilding.Latitude__c = 35.0;
        addBuilding.Longitude__c = 136.0;
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９８';
        targetList.add(addBuilding);
        insert targetList;
        
        // コールアウトクラスのモッククラス（複数周辺施設）をセット
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest7OK2HttpRequestMock());
        System.runAs(thisUser) {
            Test.startTest();
            GoogleApiUtil.setSurroundingFacilities(targetList);
            Test.stopTest();

            // MOCKの値を取得
            SurroundingFacility__c MockSF =[SELECT ID,Name,FacilityType__c From SurroundingFacility__c Where name ='周辺施設１'];

            //★実行結果確認★
            // Mock（周辺施設１）の値が設定されたこと
            for(Building__c building : targetList){
                if(building.Name == '建物7A') {
                    System.assertEquals(building.HighSchool__c, MockSF.Id);  
                }
                if(building.Name == '建物7B') {
                    System.assertEquals(building.HighSchool__c, MockSF.Id);  
                }
            }
        }
    }
    //対象の物件が複数件の場合かつ周辺施設が複数件取得できて対象外が距離の一番近い物の場合、
    //次点の距離が近いものが正しく設定されるのテストパターン
    @isTest static void Surroundtest008(){

        User thisUser = [SELECT Id FROM User WHERE UserName = 'GoogleApiUtilTest7@horaguchi.com'];
        List<Building__c> targetList = new List<Building__c>();

        //建物Aのデータセット
        Building__c addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = '建物8A';
        addBuilding.Latitude__c = 35.0;
        addBuilding.Longitude__c = 136.0;
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９９';
        targetList.add(addBuilding);

        //建物Bのデータセット
        addBuilding = new Building__c();
        addBuilding.OwnerId = UserInfo.getUserId();
        addBuilding.Name = '建物8B';
        addBuilding.Latitude__c = 35.0;
        addBuilding.Longitude__c = 136.0;
        addBuilding.State__c = '大阪府';
        addBuilding.City__c = '大阪市大阪町';
        addBuilding.Street__c = '５丁目９９－９８';
        targetList.add(addBuilding);
        insert targetList;

        // 対象外の周辺施設情報の登録
        List<SurroundingFacility__c> surroundingFacilityList = new List<SurroundingFacility__c>();
        SurroundingFacility__c surroundingFacility = new SurroundingFacility__c();
        surroundingFacility.OwnerId = UserInfo.getUserId();
        surroundingFacility.Name = '周辺施設１';
        surroundingFacility.PlaceId__c = 'testPlaceId';
        surroundingFacility.FacilityType__c = CommonConst.SURROUDING_FACILITY_TYPE_NOTAPPLICABLE;
        surroundingFacilityList.add(surroundingFacility);
        insert surroundingFacilityList;

        // コールアウトクラスのモッククラス（複数周辺施設）をセット
        Test.setMock(HttpCalloutMock.class, new googleApiUtilTest7OK2HttpRequestMock());
        System.runAs(thisUser) {
            Test.startTest();
            GoogleApiUtil.setSurroundingFacilities(targetList);
            Test.stopTest();

            // MOCKの値を取得
            SurroundingFacility__c MockSF =[SELECT ID,Name,FacilityType__c From SurroundingFacility__c Where name ='周辺施設２'];

            //★実行結果確認★
            // Mockの値（周辺施設２）が設定されたこと
            for(Building__c building : targetList){
                if(building.Name == '建物8A') {
                    System.assertEquals(building.HighSchool__c, MockSF.Id);  
                }
                if(building.Name == '建物8B') {
                    System.assertEquals(building.HighSchool__c, MockSF.Id);  
                }
            }
        }
    }
}