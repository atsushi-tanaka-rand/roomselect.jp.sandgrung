@isTest
public with sharing class BuildingPropertyUtilTest {

    /** 部屋帖数 */
    static final Integer I_ROOM_FLOOR_SPACE_VAL = 999;
    static final String  S_ROOM_FLOOR_SPACE_VAL = String.valueOf(I_ROOM_FLOOR_SPACE_VAL) + '.00';

    static final Integer I_ROOM_FLOOR_SPACE_ERR_VAL = 1000;
    static final String  S_ROOM_FLOOR_SPACE_ERR_VAL = String.valueOf(I_ROOM_FLOOR_SPACE_ERR_VAL) + '.00';

    //テストに使用するレコードを作成する
    @testSetup static void Setting() {
        ExampleSentence__c testExampleSentence = new ExampleSentence__c(
            Name = 'CHINTAI文例'
            ,Folder__c = 'CHINTAI文例'
            ,ExampleSentence__c = 'CHINTAI文例テスト文例'
        );
        insert testExampleSentence;

        // 病院
        Hospital__c testHospital = new Hospital__c(
            Name = 'テスト病院'
           ,PhotoFileName__c = 'ファイル名.cbbb' // 写真ファイル名
        );
        insert testHospital;
        
        // 学校
        School__c testSchool = new School__c(
            Name = 'テスト学校'
           ,PhotoFileName__c = 'ファイル名.cbbb' // 写真ファイル名
        );
        insert testSchool;
        
        // 路線 ▼ 2022.03.30 CHINTAI対応変更
        List<TrainRoute__c> trainList = new List<TrainRoute__c>();
        trainList.add(new TrainRoute__c(Name = 'テスト路線1', ChintaiTrainRouteCode__c = '001'));
        trainList.add(new TrainRoute__c(Name = 'テスト路線2', ChintaiTrainRouteCode__c = '002'));
        trainList.add(new TrainRoute__c(Name = 'テスト路線3', ChintaiTrainRouteCode__c = '003'));
        insert trainList;
        
        // 駅
		List<Station__c> stationList = new List<Station__c>();
        stationList.add(new Station__c(Name = 'テスト駅1', TrainRoute__c = trainList[0].Id, ChintaiStationCode__c = '011'));
        stationList.add(new Station__c(Name = 'テスト駅2', TrainRoute__c = trainList[1].Id, ChintaiStationCode__c = '012'));
        stationList.add(new Station__c(Name = 'テスト駅3', TrainRoute__c = trainList[2].Id, ChintaiStationCode__c = '013'));
        insert stationList;
        
        // 周辺施設
        SurroundingFacility__c testSurroundingFacility = new SurroundingFacility__c(
            Name = 'テスト周辺施設'
           ,PhotoFileName__c = 'ファイル名.cbbb' // 写真ファイル名
        );
        insert testSurroundingFacility;

        // 建物
        Building__c testBuilding = new Building__c(
            Name = 'テスト建物'
            ,Supermarket__c = testSurroundingFacility.id
            ,ConvenienceStore__c = testSurroundingFacility.id
            ,GeneralHospital__c = testHospital.id
            ,PrimarySchool1__c = testSchool.id
            ,PrimarySchool2__c = testSchool.id
            ,PrimarySchool3__c = testSchool.id
            ,JuniorHighSchool1__c = testSchool.id
            ,JuniorHighSchool2__c = testSchool.id
            ,JuniorHighSchool3__c = testSchool.id
            ,HighSchool__c = testSurroundingFacility.id
            ,University__c = testSurroundingFacility.id
			,TrainRoute1__c      = trainList[0].Id
            ,TrainRoute2__c      = trainList[1].Id
            ,TrainRoute3__c      = trainList[2].Id
            ,Station1__c         = stationList[0].Id
            ,Station2__c         = stationList[1].Id
            ,Station3__c         = stationList[2].Id 
        );
        insert testBuilding;

        // 物件
        Property__c testProperty = new Property__c(
            Name = 'テスト物件'
            ,Building__c = testBuilding.Id
			,ChintaiMagazineComment__c		= testExampleSentence.Id
        );
        insert testProperty;

        // 物件写真
        PropertyPhoto__c testPropertyPhoto = new PropertyPhoto__c(
            Property__c                 = testProperty.Id   // 物件
            ,PropertyPhotoFileName1__c  = '物件写真ファイル名.aaa'  // 物件写真ファイル名１
            ,PropertyPhotoFileName2__c  = '物件写真ファイル名.aaa'  // 物件写真ファイル名２
            ,PropertyPhotoFileName3__c  = '物件写真ファイル名.aaa'  // 物件写真ファイル名３
            ,PropertyPhotoFileName4__c  = '物件写真ファイル名.aaa'  // 物件写真ファイル名４
            ,PropertyPhotoFileName5__c  = '物件写真ファイル名.aaa'  // 物件写真ファイル名５
            ,PropertyPhotoFileName6__c  = '物件写真ファイル名.aaa'  // 物件写真ファイル名６
            ,PropertyPhotoFileName7__c  = '物件写真ファイル名.aaa'  // 物件写真ファイル名７
            ,PropertyPhotoFileName8__c  = '物件写真ファイル名.aaa'  // 物件写真ファイル名８
            ,PropertyPhotoFileName9__c  = '物件写真ファイル名.aaa'  // 物件写真ファイル名９
            ,PropertyPhotoFileName10__c = '物件写真ファイル名.aaa'  // 物件写真ファイル名１０
            ,PropertyPhotoFileName11__c = ''          // 物件写真ファイル名１１
            ,PropertyPhotoFileName12__c = ''          // 物件写真ファイル名１２
            ,PropertyPhotoFileName13__c = ''          // 物件写真ファイル名１３
            ,PropertyPhotoFileName14__c = ''          // 物件写真ファイル名１４
            ,PropertyPhotoFileName15__c = ''          // 物件写真ファイル名１５
            ,PropertyPhotoFileName16__c = ''          // 物件写真ファイル名１６
            ,PropertyPhotoFileName17__c = ''          // 物件写真ファイル名１７
            ,PropertyPhotoFileName18__c = ''          // 物件写真ファイル名１８
            ,PropertyPhotoFileName19__c = ''          // 物件写真ファイル名１９
            ,PropertyPhotoFileName20__c = ''          // 物件写真ファイル名２０
            ,PropertyPhotoTag1__c       = ''          // 物件写真タグ１
            ,PropertyPhotoTag2__c       = ''          // 物件写真タグ２
            ,PropertyPhotoTag3__c       = ''          // 物件写真タグ３
            ,PropertyPhotoTag4__c       = ''          // 物件写真タグ４
            ,PropertyPhotoTag5__c       = ''          // 物件写真タグ５
            ,PropertyPhotoTag6__c       = ''          // 物件写真タグ６
            ,PropertyPhotoTag7__c       = ''          // 物件写真タグ７
            ,PropertyPhotoTag8__c       = ''          // 物件写真タグ８
            ,PropertyPhotoTag9__c       = ''          // 物件写真タグ９
            ,PropertyPhotoTag10__c      = ''          // 物件写真タグ１０
            ,PropertyPhotoTag11__c      = ''          // 物件写真タグ１１
            ,PropertyPhotoTag12__c      = ''          // 物件写真タグ１２
            ,PropertyPhotoTag13__c      = ''          // 物件写真タグ１３
            ,PropertyPhotoTag14__c      = ''          // 物件写真タグ１４
            ,PropertyPhotoTag15__c      = ''          // 物件写真タグ１５
            ,PropertyPhotoTag16__c      = ''          // 物件写真タグ１６
            ,PropertyPhotoTag17__c      = ''          // 物件写真タグ１７
            ,PropertyPhotoTag18__c      = ''          // 物件写真タグ１８
            ,PropertyPhotoTag19__c      = ''          // 物件写真タグ１９
            ,PropertyPhotoTag20__c      = ''          // 物件写真タグ２０
            ,PropertyPhotoComment1__c   = ''          // 物件写真コメント１
            ,PropertyPhotoComment2__c   = ''          // 物件写真コメント２
            ,PropertyPhotoComment3__c   = ''          // 物件写真コメント３
            ,PropertyPhotoComment4__c   = ''          // 物件写真コメント４
            ,PropertyPhotoComment5__c   = ''          // 物件写真コメント５
            ,PropertyPhotoComment6__c   = ''          // 物件写真コメント６
            ,PropertyPhotoComment7__c   = ''          // 物件写真コメント７
            ,PropertyPhotoComment8__c   = ''          // 物件写真コメント８
            ,PropertyPhotoComment9__c   = ''          // 物件写真コメント９
            ,PropertyPhotoComment10__c  = ''          // 物件写真コメント１０
            ,PropertyPhotoComment11__c  = ''          // 物件写真コメント１１
            ,PropertyPhotoComment12__c  = ''          // 物件写真コメント１２
            ,PropertyPhotoComment13__c  = ''          // 物件写真コメント１３
            ,PropertyPhotoComment14__c  = ''          // 物件写真コメント１４
            ,PropertyPhotoComment15__c  = ''          // 物件写真コメント１５
            ,PropertyPhotoComment16__c  = ''          // 物件写真コメント１６
            ,PropertyPhotoComment17__c  = ''          // 物件写真コメント１７
            ,PropertyPhotoComment18__c  = ''          // 物件写真コメント１８
            ,PropertyPhotoComment19__c  = ''          // 物件写真コメント１９
            ,PropertyPhotoComment20__c  = ''          // 物件写真コメント２０
            ,PrivatePhotoFileName1__c   = '非公開写真ファイル名.aaa'    // 非公開写真ファイル名１
            ,PrivatePhotoFileName2__c   = '非公開写真ファイル名.aaa'    // 非公開写真ファイル名２
            ,PrivatePhotoFileName3__c   = '非公開写真ファイル名.aaa'    // 非公開写真ファイル名３
            ,PrivatePhotoFileName4__c   = '非公開写真ファイル名.aaa'    // 非公開写真ファイル名４
            ,PrivatePhotoFileName5__c   = ''          // 非公開写真ファイル名５
            ,PrivatePhotoFileName6__c   = ''          // 非公開写真ファイル名６
            ,PrivatePhotoFileName7__c   = ''          // 非公開写真ファイル名７
            ,PrivatePhotoFileName8__c   = ''          // 非公開写真ファイル名８
            ,PrivatePhotoType1__c       = ''          // 非公開写真種別１
            ,PrivatePhotoType2__c       = ''          // 非公開写真種別２
            ,PrivatePhotoType3__c       = ''          // 非公開写真種別３
            ,PrivatePhotoType4__c       = ''          // 非公開写真種別４
            ,PrivatePhotoType5__c       = ''          // 非公開写真種別５
            ,PrivatePhotoType6__c       = ''          // 非公開写真種別６
            ,PrivatePhotoType7__c       = ''          // 非公開写真種別７
            ,PrivatePhotoType8__c       = ''          // 非公開写真種別８
            ,PrivatePhotoComment1__c    = ''          // 非公開写真コメント１
            ,PrivatePhotoComment2__c    = ''          // 非公開写真コメント２
            ,PrivatePhotoComment3__c    = ''          // 非公開写真コメント３
            ,PrivatePhotoComment4__c    = ''          // 非公開写真コメント４
            ,PrivatePhotoComment5__c    = ''          // 非公開写真コメント５
            ,PrivatePhotoComment6__c    = ''          // 非公開写真コメント６
            ,PrivatePhotoComment7__c    = ''          // 非公開写真コメント７
            ,PrivatePhotoComment8__c    = ''          // 非公開写真コメント８
            ,PanoramaFileName1__c       = 'パノラマファイル名.aaa'  // パノラマファイル名１
            ,PanoramaFileName2__c       = 'パノラマファイル名.aaa'  // パノラマファイル名２
            ,PanoramaFileName3__c       = 'パノラマファイル名.aaa'  // パノラマファイル名３
            ,PanoramaFileName4__c       = ''          // パノラマファイル名４
            ,PanoramaFileName5__c       = ''          // パノラマファイル名５
            ,PanoramaTag1__c            = ''          // パノラマタグ１
            ,PanoramaTag2__c            = ''          // パノラマタグ２
            ,PanoramaTag3__c            = ''          // パノラマタグ３
            ,PanoramaTag4__c            = ''          // パノラマタグ４
            ,PanoramaTag5__c            = ''          // パノラマタグ５
            ,PanoramaComment1__c        = ''          // パノラマコメント１
            ,PanoramaComment2__c        = ''          // パノラマコメント２
            ,PanoramaComment3__c        = ''          // パノラマコメント３
            ,PanoramaComment4__c        = ''          // パノラマコメント４
            ,PanoramaComment5__c        = ''          // パノラマコメント５
            ,RoomLayoutFileName__c      = '間取り図ファイル名.aaa'      // 間取り図ファイル名
            ,RoomLayoutMemoFileName__c  = '間取り図メモファイル名.aaa'  // 間取り図メモファイル名
        );
        insert testPropertyPhoto;

        // 建物写真
        BuildingPhoto__c testBuildingPhoto = new BuildingPhoto__c(
            Building__c                  = testBuilding.Id // 建物
            ,AppearanceComment__c        = 'ファイル名.cbbb' // 建物外観コメント
            ,AppearanceFileName__c       = 'ファイル名.cbbb' // 建物外観ファイル名
            ,AppearanceParseComment__c   = 'ファイル名.cbbb' // 外観バースコメント
            ,AppearanceParseFileName__c  = 'ファイル名.cbbb' // 外観バースファイル名
            ,EntranceComment__c          = 'ファイル名.cbbb' // エントランスコメント
            ,LobbyComment__c             = 'ファイル名.cbbb' // ロビーコメント
            ,LobbyFileName__c            = 'ファイル名.cbbb' // ロビーファイル名
            ,ParkingComment__c           = 'ファイル名.cbbb' // 駐車場コメント
            ,ParkingFileName__c          = 'ファイル名.cbbb' // 駐車場ファイル名
            ,OtherSharingComment__c      = 'ファイル名.cbbb' // その他共有コメント
            ,OtherSharingFileName__c     = 'ファイル名.cbbb' // その他共有ファイル名
            ,MapComment__c               = 'ファイル名.cbbb' // 地図コメント
            ,MapFileName__c              = 'ファイル名.cbbb' // 地図ファイル名
            ,OtherComment__c             = 'ファイル名.cbbb' // その他コメント
            ,OtherFileName__c            = 'ファイル名.cbbb' // その他ファイル名
            ,SurroundingComment1__c      = 'ファイル名.cbbb' // 周辺写真コメント１
            ,SurroundingFileName1__c     = 'ファイル名.cbbb' // 周辺写真ファイル名１
            ,SurroundingComment2__c      = 'ファイル名.cbbb' // 周辺写真コメント２
            ,SurroundingFileName2__c     = 'ファイル名.cbbb' // 周辺写真ファイル名２
            ,SurroundingComment3__c      = 'ファイル名.cbbb' // 周辺写真コメント３
            ,SurroundingFileName3__c     = 'ファイル名.cbbb' // 周辺写真ファイル名３
            ,SurroundingComment4__c      = 'ファイル名.cbbb' // 周辺写真コメント４
            ,SurroundingFileName4__c     = 'ファイル名.cbbb' // 周辺写真ファイル名４
            ,SurroundingComment5__c      = 'ファイル名.cbbb' // 周辺写真コメント５
            ,SurroundingFileName5__c     = 'ファイル名.cbbb' // 周辺写真ファイル名５
        );
        insert testBuildingPhoto;      
        
        // 部屋
        Room__c room1 = new Room__c (
            ForeignID__c = '部屋1'
            , Property__c = testProperty.Id
            , RoomFloorSpace__c = I_ROOM_FLOOR_SPACE_VAL
        );
        Room__c room2 = new Room__c (
            ForeignID__c = '部屋2'
            , Property__c = testProperty.Id
            , RoomFloorSpace__c = I_ROOM_FLOOR_SPACE_VAL
        );
        Room__c room3 = new Room__c (
            ForeignID__c = '部屋3'
            , Property__c = testProperty.Id
            , RoomFloorSpace__c = I_ROOM_FLOOR_SPACE_VAL
        );
        Room__c room4 = new Room__c (
            ForeignID__c = '部屋4'
            , Property__c = testProperty.Id
            , RoomFloorSpace__c = I_ROOM_FLOOR_SPACE_VAL
        );
        Room__c room5 = new Room__c (
            ForeignID__c = '部屋5'
            , Property__c = testProperty.Id
            , RoomFloorSpace__c = I_ROOM_FLOOR_SPACE_VAL
        );
        Room__c room6 = new Room__c (
            ForeignID__c = '部屋6'
            , Property__c = testProperty.Id
            , RoomFloorSpace__c = I_ROOM_FLOOR_SPACE_VAL
        );
        Room__c room7 = new Room__c (
            ForeignID__c = '部屋7'
            , Property__c = testProperty.Id
            , RoomFloorSpace__c = I_ROOM_FLOOR_SPACE_VAL
        );
        Room__c room8 = new Room__c (
            ForeignID__c = '部屋8'
            , Property__c = testProperty.Id
            , RoomFloorSpace__c = I_ROOM_FLOOR_SPACE_VAL
        );
        Room__c room9 = new Room__c (
            ForeignID__c = '部屋9'
            , Property__c = testProperty.Id
            , RoomFloorSpace__c = I_ROOM_FLOOR_SPACE_VAL
        );
        Room__c room10 = new Room__c (
            ForeignID__c = '部屋10'
            , Property__c = testProperty.Id
            , RoomFloorSpace__c = I_ROOM_FLOOR_SPACE_VAL
        );
        List<Room__c> roomList = new List<Room__c>{
            room1, room2, room3, room4, room5
            , room6, room7, room8, room9, room10
        };
        insert roomList;
    }

    @isTest static void getSuumoScoreTest() {
        Property__c testProp = [SELECT id FROM Property__c WHERE Name = 'テスト物件'];
        BuildingPropertyUtil.getSuumoScore(testProp.id);
    }

    @isTest static void getSuumoScoreNotExistPropTest() {
        Set<id> idSet = new Set<id>();
        BuildingPropertyUtil.getSuumoScore(idSet);
    }

    @isTest static void getSuumoScoreNotExistPhotoTest() {
        Property__c testProp = [SELECT id FROM Property__c WHERE Name = 'テスト物件'];
        Building__c testBuild = [SELECT id FROM Building__c WHERE Name = 'テスト建物'];
        PropertyPhoto__c testPropPhoto = [SELECT id FROM PropertyPhoto__c WHERE Property__c =: testProp.id];
        BuildingPhoto__c testBuildPhoto = [SELECT id FROM BuildingPhoto__c WHERE Building__c =: testBuild.id];
        delete testPropPhoto;
        delete testBuildPhoto;

        BuildingPropertyUtil.getSuumoScore(testProp.id);
    }
    
    // 部屋帖数の桁数テスト
    @isTest static void roomFloorSpaceLengthTest() {

        // ユーザ
        User user = [SELECT Id
                     FROM User
                     WHERE Id = :UserInfo.getUserId()];

        // 物件
        Property__c prop = [SELECT id 
                            FROM Property__c
                            WHERE Name = 'テスト物件'];

        System.runAs(user) {

            // 部屋.部屋帖数より建物物件差分.部屋帖数1～10を作成
            Test.startTest();
            BuildingPropertyUtil.createBuildingPropertyDifference(prop.Id);
            Test.stopTest();

            // 登録された建物物件差分の取得
            BuildingPropertyDifference__c buildingPropDiff = [SELECT RoomFloorSpace1__c
                                                                     , RoomFloorSpace2__c
                                                                     , RoomFloorSpace3__c
                                                                     , RoomFloorSpace4__c
                                                                     , RoomFloorSpace5__c
                                                                     , RoomFloorSpace6__c
                                                                     , RoomFloorSpace7__c
                                                                     , RoomFloorSpace8__c
                                                                     , RoomFloorSpace9__c
                                                                     , RoomFloorSpace10__c
                                                              FROM BuildingPropertyDifference__c
                                                              WHERE PropertyId__c = :prop.Id];

            // 建物物件差分.部屋帖数1～10の桁数チェック("###.00"形式)
            System.assertEquals(String.valueOf(buildingPropDiff.RoomFloorSpace1__c),  S_ROOM_FLOOR_SPACE_VAL);
            System.assertEquals(String.valueOf(buildingPropDiff.RoomFloorSpace2__c),  S_ROOM_FLOOR_SPACE_VAL);
            System.assertEquals(String.valueOf(buildingPropDiff.RoomFloorSpace3__c),  S_ROOM_FLOOR_SPACE_VAL);
            System.assertEquals(String.valueOf(buildingPropDiff.RoomFloorSpace4__c),  S_ROOM_FLOOR_SPACE_VAL);
            System.assertEquals(String.valueOf(buildingPropDiff.RoomFloorSpace5__c),  S_ROOM_FLOOR_SPACE_VAL);
            System.assertEquals(String.valueOf(buildingPropDiff.RoomFloorSpace6__c),  S_ROOM_FLOOR_SPACE_VAL);
            System.assertEquals(String.valueOf(buildingPropDiff.RoomFloorSpace7__c),  S_ROOM_FLOOR_SPACE_VAL);
            System.assertEquals(String.valueOf(buildingPropDiff.RoomFloorSpace8__c),  S_ROOM_FLOOR_SPACE_VAL);
            System.assertEquals(String.valueOf(buildingPropDiff.RoomFloorSpace9__c),  S_ROOM_FLOOR_SPACE_VAL);
            System.assertEquals(String.valueOf(buildingPropDiff.RoomFloorSpace10__c), S_ROOM_FLOOR_SPACE_VAL);
        }

        // 部屋の登録
        Room__c room = new Room__c(
            RoomFloorSpace__c = I_ROOM_FLOOR_SPACE_ERR_VAL
        );
        insert room;

        // 登録した部屋.部屋帖数の桁数チェック("####.00"形式)
        room = [SELECT RoomFloorSpace__c
                FROM Room__c
                WHERE Id = :room.Id];
        System.assertEquals(String.valueOf(room.RoomFloorSpace__c), S_ROOM_FLOOR_SPACE_ERR_VAL);
    }

	// ▼ 2022.03.30 CHINTAI対応追加
	@isTest static void checkChintaiTest() {
		// 物件
		Property__c prop = [SELECT Id FROM Property__c WHERE Name = 'テスト物件'];
		List<TrainRoute__c> trainRouteList = [SELECT Id, ChintaiTrainRouteCode__c FROM TrainRoute__c ORDER BY ChintaiTrainRouteCode__c];
		List <Station__c> stationList = [SELECT Id, ChintaiStationCode__c FROM Station__c ORDER BY ChintaiStationCode__c];
		List<ExampleSentence__c> testExampleSentence = [SELECT Id, ExampleSentence__c FROM ExampleSentence__c];
		Boolean result = BuildingPropertyUtil.createBuildingPropertyDifference(new Set<Id>{prop.Id});
		System.assertEquals(true, result);
		BuildingPropertyDifference__c buildingDiff = [	SELECT 	Id, ChintaiTrainRoutecode1__c, ChintaiTrainRoutecode2__c, ChintaiTrainRoutecode3__c,
																ChintaiStationcode1__c, ChintaiStationcode2__c, ChintaiStationcode3__c, ChintaiMagazineComment__c 
														FROM BuildingPropertyDifference__c 
														WHERE PropertyId__c = :prop.Id];
		System.assertEquals(trainRouteList[0].ChintaiTrainRouteCode__c, buildingDiff.ChintaiTrainRoutecode1__c);
		System.assertEquals(trainRouteList[1].ChintaiTrainRouteCode__c, buildingDiff.ChintaiTrainRoutecode2__c);
		System.assertEquals(trainRouteList[2].ChintaiTrainRouteCode__c, buildingDiff.ChintaiTrainRoutecode3__c);
		System.assertEquals(stationList[0].ChintaiStationCode__c, buildingDiff.ChintaiStationcode1__c);
		System.assertEquals(stationList[1].ChintaiStationCode__c, buildingDiff.ChintaiStationcode2__c);
		System.assertEquals(stationList[2].ChintaiStationCode__c, buildingDiff.ChintaiStationcode3__c);
		System.assertEquals(testExampleSentence[0].ExampleSentence__c, buildingDiff.ChintaiMagazineComment__c);
	}
	// ▲ 2022.03.30 CHINTAI対応追加
}