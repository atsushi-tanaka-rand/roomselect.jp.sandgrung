/**
 * Amazon S3関連共通クラスのテスト
 */
@isTest
public class AmazonS3UtilTest {

    //テストに使用するレコードを作成する
    @testSetup static void Setting() {
        // カスタム設定
        SystemConfig__c testSystemConfig = new SystemConfig__c();
		// ▼ 2022.2.14 LINE連携対応より、コメントアウトの解除
		testSystemConfig.S3Region__c            = 'dummy';
		testSystemConfig.S3BucketName__c        = 'dummy';
		testSystemConfig.S3SecretAccessKey__c   = 'dummy';
		testSystemConfig.S3AccessKey__c         = 'dummy';
		testSystemConfig.S3RootDirectory__c     = 'dummy';
		// ▲ 2022.2.14
        insert testSystemConfig;
        // 建物
        Building__c testBuilding = new Building__c(
            Name = 'テスト建物'
        );
        insert testBuilding;
        Building__c testBuilding2 = new Building__c(
            Name = 'テスト建物２'
        );
        insert testBuilding2;
        // 物件
        Property__c testProperty = new Property__c(
            Name = 'テスト物件'
            ,Building__c = testBuilding.Id
        );
        insert testProperty;
        Property__c testProperty2 = new Property__c(
            Name = 'テスト物件２'
            ,Building__c = testBuilding2.Id
        );
        insert testProperty2;
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
        PropertyPhoto__c testPropertyPhoto2 = new PropertyPhoto__c(
            Property__c                 = testProperty2.Id   // 物件
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
        insert testPropertyPhoto2;
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
        BuildingPhoto__c testBuildingPhoto2 = new BuildingPhoto__c(
            Building__c                  = testBuilding2.Id // 建物
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
        insert testBuildingPhoto2;
        
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

        
        // 路線
        TrainRoute__c testTrainRoute = new TrainRoute__c(
            Name = 'テスト路線'
        );
        insert testTrainRoute;
        
        // 駅
        Station__c testStation = new Station__c(
            Name = 'テスト駅'
           ,PhotoFileName__c = 'ファイル名.cbbb' // 写真ファイル名
           ,TrainRoute__c = testTrainRoute.id
        );
        insert testStation;
        
        // 周辺施設
        SurroundingFacility__c testSurroundingFacility = new SurroundingFacility__c(
            Name = 'テスト周辺施設'
           ,PhotoFileName__c = 'ファイル名.cbbb' // 写真ファイル名
        );
        insert testSurroundingFacility;
    }

    @isTest static void testAll1() {

        // コールアウトクラスのモッククラスをセット ステータスコード200
        Test.setMock(HttpCalloutMock.class, new AmazonS3UtilHTTPRequestMock(false));

        Building__c testBuild = [
            SELECT Id, Name, ForeignID__c
            FROM Building__c
            WHERE Name = 'テスト建物'
        ];
        Building__c testBuild2 = [
            SELECT Id, Name, ForeignID__c
            FROM Building__c
            WHERE Name = 'テスト建物２'
        ];
        Property__c testProp = [
            SELECT Id, Name, ForeignID__c
            FROM Property__c
            WHERE Name = 'テスト物件'
        ];
        Property__c testProp2 = [
            SELECT Id, Name, ForeignID__c
            FROM Property__c
            WHERE Name = 'テスト物件２'
        ];
        Hospital__c testHospital = [
            SELECT Id, Name, ForeignID__c
            FROM Hospital__c
            WHERE Name = 'テスト病院'
        ];
        School__c testSchool = [
            SELECT Id, Name, ForeignID__c
            FROM School__c
            WHERE Name = 'テスト学校'
        ];
        Station__c testStation = [
            SELECT Id, Name, ForeignID__c
            FROM Station__c
            WHERE Name = 'テスト駅'
        ];
        SurroundingFacility__c testSurroundingFacility = [
            SELECT Id, Name, ForeignID__c
            FROM SurroundingFacility__c
            WHERE Name = 'テスト周辺施設'
        ];
        //メソッド実行
        Test.startTest();

        List<Id> testIdList = new List<Id>();
        testIdList.add(testBuild.Id);

        // 物件写真移動
        AmazonS3Util.callPhotoMove(testProp.Id, testProp2.Id, AmazonS3Util.PhotoType.PROPERTY);
        AmazonS3Util.callPhotoMove(testProp.Id, testProp2.Id, AmazonS3Util.PhotoType.PROPERTY_PANORAMA, 1);
        AmazonS3Util.callPhotoMove(testProp.Id, testProp2.Id, AmazonS3Util.PhotoType.PROPERTY_PRIVATE);
        AmazonS3Util.callPhotoMove(testProp.Id, testProp2.Id, AmazonS3Util.PhotoType.PROPERTY_ROOMLAYOUT);
        AmazonS3Util.callPhotoMove(testProp.Id, testProp2.Id, AmazonS3Util.PhotoType.PROPERTY_ROOMLAYOUTMEMO);
        List<AmazonS3Util.PhotoMoveMultipleParameter> pmmParam = new List<AmazonS3Util.PhotoMoveMultipleParameter>();
        pmmParam.add(new AmazonS3Util.PhotoMoveMultipleParameter(testProp2.Id, testProp.Id, AmazonS3Util.PhotoType.PROPERTY));
        pmmParam.add(new AmazonS3Util.PhotoMoveMultipleParameter(testProp2.Id, testProp.Id, AmazonS3Util.PhotoType.PROPERTY_PANORAMA));
        pmmParam.add(new AmazonS3Util.PhotoMoveMultipleParameter(testProp2.Id, testProp.Id, AmazonS3Util.PhotoType.PROPERTY_PRIVATE));
        pmmParam.add(new AmazonS3Util.PhotoMoveMultipleParameter(testProp2.Id, testProp.Id, AmazonS3Util.PhotoType.PROPERTY_ROOMLAYOUT));
        pmmParam.add(new AmazonS3Util.PhotoMoveMultipleParameter(testProp2.Id, testProp.Id, AmazonS3Util.PhotoType.PROPERTY_ROOMLAYOUTMEMO));
        AmazonS3Util.callPhotoMoveMultiple(pmmParam);
        // 物件写真移動２
        AmazonS3Util.callPhotoMoveFromS3('aaaaa.bbb', testProp2.Id, AmazonS3Util.PhotoType.PROPERTY);
        AmazonS3Util.callPhotoMoveFromS3('aaaaa.bbb', testProp2.Id, AmazonS3Util.PhotoType.PROPERTY_PANORAMA);
        AmazonS3Util.callPhotoMoveFromS3('aaaaa.bbb', testProp2.Id, AmazonS3Util.PhotoType.PROPERTY_PRIVATE, 2);
        AmazonS3Util.callPhotoMoveFromS3('aaaaa.bbb', testProp2.Id, AmazonS3Util.PhotoType.PROPERTY_ROOMLAYOUT);
        AmazonS3Util.callPhotoMoveFromS3('aaaaa.bbb', testProp2.Id, AmazonS3Util.PhotoType.PROPERTY_ROOMLAYOUTMEMO);
        List<AmazonS3Util.PhotoMoveFromS3MultipleParameter> pmfmParam = new List<AmazonS3Util.PhotoMoveFromS3MultipleParameter>();
        pmfmParam.add(new AmazonS3Util.PhotoMoveFromS3MultipleParameter('aaaaa.bbb', testProp.Id, AmazonS3Util.PhotoType.PROPERTY));
        pmfmParam.add(new AmazonS3Util.PhotoMoveFromS3MultipleParameter('aaaaa.bbb', testProp.Id, AmazonS3Util.PhotoType.PROPERTY_PANORAMA, 1));
        pmfmParam.add(new AmazonS3Util.PhotoMoveFromS3MultipleParameter('aaaaa.bbb', testProp.Id, AmazonS3Util.PhotoType.PROPERTY_PRIVATE));
        pmfmParam.add(new AmazonS3Util.PhotoMoveFromS3MultipleParameter('aaaaa.bbb', testProp.Id, AmazonS3Util.PhotoType.PROPERTY_ROOMLAYOUT, 1, '', ''));
        pmfmParam.add(new AmazonS3Util.PhotoMoveFromS3MultipleParameter('aaaaa.bbb', testProp.Id, AmazonS3Util.PhotoType.PROPERTY_ROOMLAYOUTMEMO));
        AmazonS3Util.callPhotoMoveFromS3Multiple(pmfmParam);

        // 建物写真移動
        AmazonS3Util.callPhotoMove(testBuild.Id, testBuild2.Id, AmazonS3Util.PhotoType.BUILDING_APPEARANCE);
        pmmParam = new List<AmazonS3Util.PhotoMoveMultipleParameter>();
        pmmParam.add(new AmazonS3Util.PhotoMoveMultipleParameter(testBuild.Id, testBuild2.Id, AmazonS3Util.PhotoType.BUILDING_SURROUNDING));
        AmazonS3Util.callPhotoMoveMultiple(pmmParam);
        // 建物写真移動２
        AmazonS3Util.callPhotoMoveFromS3('aaaaa.bbb', testBuild2.Id, AmazonS3Util.PhotoType.BUILDING_ENTRANCE);
        pmfmParam = new List<AmazonS3Util.PhotoMoveFromS3MultipleParameter>();
        pmfmParam.add(new AmazonS3Util.PhotoMoveFromS3MultipleParameter('aaaaa.bbb', testBuild.Id, AmazonS3Util.PhotoType.BUILDING_OTHER));
        AmazonS3Util.callPhotoMoveFromS3Multiple(pmfmParam);

        AmazonS3Util.AutoMaintePhotoMoveParameter autoParam1 = new AmazonS3Util.AutoMaintePhotoMoveParameter();
        AmazonS3Util.AutoMaintePhotoMoveDataParameter photo1 = new AmazonS3Util.AutoMaintePhotoMoveDataParameter('fromPath', 'toComment', 'toTag', AmazonS3Util.PhotoType.BUILDING_APPEARANCE);
        autoParam1.photoList.add(photo1);

        AmazonS3Util.AutoMaintePhotoMoveParameter autoParam2 = new AmazonS3Util.AutoMaintePhotoMoveParameter(testBuild.id, 'test', new t_auto_maintenance_difference__c());
        AmazonS3Util.AutoMaintePhotoMoveDataParameter photo2 = new AmazonS3Util.AutoMaintePhotoMoveDataParameter('fromPath', 'toComment', 'toTag', 1, AmazonS3Util.PhotoType.BUILDING_APPEARANCE);
        autoParam2.photoList.add(photo2);

        AmazonS3Util amzs3 = new AmazonS3Util();
        List<AmazonS3Util.AutoMaintePhotoMoveParameter> s3MovePhotoList = new List<AmazonS3Util.AutoMaintePhotoMoveParameter>();

        s3MovePhotoList.add(autoParam1);
        s3MovePhotoList.add(autoParam2);
        AmazonS3Util.callPhotoMoveAutoMainte(s3MovePhotoList);

        Test.stopTest();
    }


    @isTest static void testAll2() {

        // コールアウトクラスのモッククラスをセット ステータスコード200
        Test.setMock(HttpCalloutMock.class, new AmazonS3UtilHTTPRequestMock(false));

        Building__c testBuild = [
            SELECT Id, Name, ForeignID__c
            FROM Building__c
            WHERE Name = 'テスト建物'
        ];
        Building__c testBuild2 = [
            SELECT Id, Name, ForeignID__c
            FROM Building__c
            WHERE Name = 'テスト建物２'
        ];
        Property__c testProp = [
            SELECT Id, Name, ForeignID__c
            FROM Property__c
            WHERE Name = 'テスト物件'
        ];
        Property__c testProp2 = [
            SELECT Id, Name, ForeignID__c
            FROM Property__c
            WHERE Name = 'テスト物件２'
        ];
        Hospital__c testHospital = [
            SELECT Id, Name, ForeignID__c
            FROM Hospital__c
            WHERE Name = 'テスト病院'
        ];
        School__c testSchool = [
            SELECT Id, Name, ForeignID__c
            FROM School__c
            WHERE Name = 'テスト学校'
        ];
        Station__c testStation = [
            SELECT Id, Name, ForeignID__c
            FROM Station__c
            WHERE Name = 'テスト駅'
        ];
        SurroundingFacility__c testSurroundingFacility = [
            SELECT Id, Name, ForeignID__c
            FROM SurroundingFacility__c
            WHERE Name = 'テスト周辺施設'
        ];
        //メソッド実行
        Test.startTest();

        //写真保存処理→建物写真をSELECT
        GD901001ParameterClass GD901001param = new GD901001ParameterClass();
        GD901001param.photoType = CommonConst.S3_PHOTOTYPE_BUILDING;
        GD901001param.foreignId = testBuild.ForeignID__c;

        GD901001param.photoSubType = CommonConst.S3_BUILDINGPHOTOTYPE_APPEARANCE;
        AmazonS3Util.savePhoto(GD901001param);

        GD901001param.photoSubType = CommonConst.S3_BUILDINGPHOTOTYPE_APPEARANCE_PARSE;
        AmazonS3Util.savePhoto(GD901001param);

        GD901001param.photoSubType = CommonConst.S3_BUILDINGPHOTOTYPE_ENTRANCE;
        AmazonS3Util.savePhoto(GD901001param);

        GD901001param.photoSubType = CommonConst.S3_BUILDINGPHOTOTYPE_LOBBY;
        AmazonS3Util.savePhoto(GD901001param);

        GD901001param.photoSubType = CommonConst.S3_BUILDINGPHOTOTYPE_PARKING;
        AmazonS3Util.savePhoto(GD901001param);

        GD901001param.photoSubType = CommonConst.S3_BUILDINGPHOTOTYPE_OTHERSHARING;
        AmazonS3Util.savePhoto(GD901001param);

        GD901001param.photoSubType = CommonConst.S3_BUILDINGPHOTOTYPE_MAP;
        AmazonS3Util.savePhoto(GD901001param);

        GD901001param.photoSubType = CommonConst.S3_BUILDINGPHOTOTYPE_OTHER;
        AmazonS3Util.savePhoto(GD901001param);

        GD901001param.photoSubType = CommonConst.S3_BUILDINGPHOTOTYPE_SURROUNDING;
        AmazonS3Util.savePhoto(GD901001param);

        //写真保存処理→物件写真をSELECT
        GD901001param.photoType = CommonConst.S3_PHOTOTYPE_PROPERTY;
        GD901001param.foreignId2 = testProp.ForeignID__c;
        
        GD901001param.photoSubType = CommonConst.S3_PROPERTYPHOTOTYPE_PROPERTPHOTO;// 物件写真

        GD901001param.fileTag = CommonConst.PROPERTYPHOTO_LABELING_KITCHEN;// キッチン
        AmazonS3Util.savePhoto(GD901001param);
        GD901001param.fileTag = CommonConst.PROPERTYPHOTO_LABELING_OTHERROOMS;// その他部屋・スペース
        AmazonS3Util.savePhoto(GD901001param);
        GD901001param.fileTag = CommonConst.PROPERTYPHOTO_LABELING_TOILET;    // トイレ
        AmazonS3Util.savePhoto(GD901001param);
        GD901001param.fileTag = CommonConst.PROPERTYPHOTO_LABELING_BATH;      // バス・シャワールーム
        AmazonS3Util.savePhoto(GD901001param);
        GD901001param.fileTag = CommonConst.PROPERTYPHOTO_LABELING_BALCONY;   // バルコニー
        AmazonS3Util.savePhoto(GD901001param);
        GD901001param.fileTag = CommonConst.PROPERTYPHOTO_LABELING_LIVING;    // 居室・リビング
        AmazonS3Util.savePhoto(GD901001param);
        GD901001param.fileTag = CommonConst.PROPERTYPHOTO_LABELING_ENTRANCE;  // 玄関
        AmazonS3Util.savePhoto(GD901001param);
        GD901001param.fileTag = CommonConst.PROPERTYPHOTO_LABELING_STORAGE;   // 収納
        AmazonS3Util.savePhoto(GD901001param);
        GD901001param.fileTag = CommonConst.PROPERTYPHOTO_LABELING_WASHBASIN; // 洗面設備
        AmazonS3Util.savePhoto(GD901001param);
        
        GD901001param.photoSubType = CommonConst.S3_PROPERTYPHOTOTYPE_PANORAMA;// パノラマ写真
        AmazonS3Util.savePhoto(GD901001param);
        
        GD901001param.photoSubType = CommonConst.S3_PROPERTYPHOTOTYPE_PRIVATEPHOTO;// 非公開写真
        AmazonS3Util.savePhoto(GD901001param);
        
        GD901001param.photoSubType = CommonConst.S3_PROPERTYPHOTOTYPE_ROOMLAYOUT;
        AmazonS3Util.savePhoto(GD901001param);
        
        GD901001param.photoSubType = CommonConst.S3_PROPERTYPHOTOTYPE_ROOMLAYOUTMEMO;
        AmazonS3Util.savePhoto(GD901001param);

        //写真保存処理→病院写真 保存
        GD901001param.photoType = CommonConst.S3_PHOTOTYPE_HOSPITAL;
        GD901001param.foreignId = testHospital.ForeignID__c;

        AmazonS3Util.savePhoto(GD901001param);

        //写真保存処理→学校写真 保存
        GD901001param.photoType = CommonConst.S3_PHOTOTYPE_SCHOOL;
        GD901001param.foreignId = testSchool.ForeignID__c;

        AmazonS3Util.savePhoto(GD901001param);

        //写真保存処理→駅写真 保存
        GD901001param.photoType = CommonConst.S3_PHOTOTYPE_STATION;
        GD901001param.foreignId = testStation.ForeignID__c;

        AmazonS3Util.savePhoto(GD901001param);

        //写真保存処理→周辺施設 保存
        GD901001param.photoType = CommonConst.S3_PHOTOTYPE_SURROUNDING_FACILITY;
        GD901001param.foreignId = testSurroundingFacility.ForeignID__c;

        AmazonS3Util.savePhoto(GD901001param);

        Test.stopTest();
    }

    @isTest static void testAll3() {

        // コールアウトクラスのモッククラスをセット ステータスコード200
        Test.setMock(HttpCalloutMock.class, new AmazonS3UtilHTTPRequestMock(false));

        Building__c testBuild = [
            SELECT Id, Name, ForeignID__c
            FROM Building__c
            WHERE Name = 'テスト建物'
        ];
        Building__c testBuild2 = [
            SELECT Id, Name, ForeignID__c
            FROM Building__c
            WHERE Name = 'テスト建物２'
        ];
        Property__c testProp = [
            SELECT Id, Name, ForeignID__c
            FROM Property__c
            WHERE Name = 'テスト物件'
        ];
        Property__c testProp2 = [
            SELECT Id, Name, ForeignID__c
            FROM Property__c
            WHERE Name = 'テスト物件２'
        ];
        Hospital__c testHospital = [
            SELECT Id, Name, ForeignID__c
            FROM Hospital__c
            WHERE Name = 'テスト病院'
        ];
        School__c testSchool = [
            SELECT Id, Name, ForeignID__c
            FROM School__c
            WHERE Name = 'テスト学校'
        ];
        Station__c testStation = [
            SELECT Id, Name, ForeignID__c
            FROM Station__c
            WHERE Name = 'テスト駅'
        ];
        SurroundingFacility__c testSurroundingFacility = [
            SELECT Id, Name, ForeignID__c
            FROM SurroundingFacility__c
            WHERE Name = 'テスト周辺施設'
        ];
        //メソッド実行
        Test.startTest();

        List<Id> testIdList = new List<Id>();
        testIdList.add(testBuild.Id);

        // 削除
        AmazonS3Util.callPhotoDelete(testProp.Id, AmazonS3Util.PhotoType.PROPERTY);
        AmazonS3Util.callPhotoDelete(testProp.Id, AmazonS3Util.PhotoType.PROPERTY_PRIVATE);
        AmazonS3Util.callPhotoDelete(testProp.Id, AmazonS3Util.PhotoType.PROPERTY_PANORAMA);
        AmazonS3Util.callPhotoDelete(testBuild.Id, AmazonS3Util.PhotoType.BUILDING_SURROUNDING);
        AmazonS3Util.callPhotoDelete(testBuild.Id, AmazonS3Util.PhotoType.BUILDING_OTHERSHARING);
        AmazonS3Util.callPropertyPhotoDeleteType(testProp.Id, AmazonS3Util.PhotoType.PROPERTY);   // 物件指定削除タイプ単位全て // 問合せNo0345で追加
        AmazonS3Util.callPropertyPhotoDeleteAll(testProp.Id);   // 物件指定削除
        AmazonS3Util.callOnlyBuildingPhotoDeleteAll(testBuild.Id);   // 建物削除 // 問合せNo0345で追加
        AmazonS3Util.callBuildingPhotoDeleteAll(testBuild.Id);  // 建物指定削除

        // AmazonS3Util.AutoMaintePhotoMoveParameter autoParam1 = new AmazonS3Util.AutoMaintePhotoMoveParameter();
        // AmazonS3Util.AutoMaintePhotoMoveDataParameter photo1 = new AmazonS3Util.AutoMaintePhotoMoveDataParameter('fromPath', 'toComment', 'toTag', AmazonS3Util.PhotoType.BUILDING_APPEARANCE);
        // autoParam1.photoList.add(photo1);

        // AmazonS3Util.AutoMaintePhotoMoveParameter autoParam2 = new AmazonS3Util.AutoMaintePhotoMoveParameter(testBuild.id, 'test', new t_auto_maintenance_difference__c());
        // AmazonS3Util.AutoMaintePhotoMoveDataParameter photo2 = new AmazonS3Util.AutoMaintePhotoMoveDataParameter('fromPath', 'toComment', 'toTag', 1, AmazonS3Util.PhotoType.BUILDING_APPEARANCE);
        // autoParam2.photoList.add(photo2);

        // AmazonS3Util amzs3 = new AmazonS3Util();
        // List<AmazonS3Util.AutoMaintePhotoMoveParameter> s3MovePhotoList = new List<AmazonS3Util.AutoMaintePhotoMoveParameter>();

        // s3MovePhotoList.add(autoParam1);
        // s3MovePhotoList.add(autoParam2);
        // AmazonS3Util.callPhotoMoveAutoMainte(s3MovePhotoList);


        //物件写真情報の取得
        List<Id> targetIdList = new List<Id>();
        targetIdList.add(testProp.Id);
        AmazonS3Util.callPropertyPhotoDeleteAll(targetIdList);

        Test.stopTest();
    }

	// ▼ 2022.2.14 LINE連携対応より、追加
	/**
	 * S3接続情報の取得テスト
	 */
	@isTest static void getS3ConnectionInfoTest() {

		// システム設定の取得
		SystemConfig__c systemConfig = [
			SELECT
				S3Region__c
				, S3BucketName__c
				, S3SecretAccessKey__c
				, S3AccessKey__c
				, S3RootDirectory__c
			FROM SystemConfig__c
		];

		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		System.runAs(thisUser) {
			Test.startTest();

			// バケット名の取得
			String bucketName = AmazonS3Util.getBucketName();
			System.assertEquals(bucketName, systemConfig.S3BucketName__c, 'バケット名テスト');

			// アクセスキーの取得
			String accessKeyId = AmazonS3Util.getAccessKeyId();
			System.assertEquals(accessKeyId, systemConfig.S3AccessKey__c, 'アクセスキーテスト');

			// シークレットキーの取得
			String secretAccessKey = AmazonS3Util.getSecretAccessKey();
			System.assertEquals(secretAccessKey, systemConfig.S3SecretAccessKey__c, 'シークレットキーテスト');

			// リージョンの取得
			String region = AmazonS3Util.getRegion();
			System.assertEquals(region, systemConfig.S3Region__c, 'リージョンテスト');

			// AmazonS3のURLの取得
			String s3Url = AmazonS3Util.getS3Url();
			System.assertEquals(s3Url, 'https://' + systemConfig.S3BucketName__c + '.s3.amazonaws.com/', 'S3URLテスト');

			// AmazonS3のLINE連携用ドメインの取得
			String s3LineDomain = AmazonS3Util.getS3LineDomain();
			System.assertEquals(s3LineDomain, systemConfig.S3RootDirectory__c + '/public/salesforce/line/' , 'LINE連携用ドメインテスト');

			//  AmazonS3のLINE連携用URLの取得
			String s3LineUrl = AmazonS3Util.getS3LineUrl();
			System.assertEquals(s3LineUrl, 'https://' + systemConfig.S3BucketName__c + '.s3.amazonaws.com/' + systemConfig.S3RootDirectory__c + '/public/salesforce/line/', 'LINE連携用URLテスト');

			Test.stopTest();
		}
	}
	// ▲ 2022.2.14
	// ▼ 2022.2.21 LINE連携対応より、追加
	/**
	 * ファイルの存在チェックテスト
	 */
	@isTest static void isExistsFileTest() {

		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		System.runAs(thisUser) {
			Test.startTest();

			// ファイルの存在チェック（異常終了）
			try {
				AmazonS3Util.isExistsFile('test');
			} catch (Exception ex) {
				System.assertNotEquals(ex.getMessage(), null, 'ファイル無し');
			}

			// ファイルの存在チェック（正常終了）
			Test.setMock(HttpCalloutMock.class, new AmazonS3UtilHTTPRequestMock(false));
			Boolean isExists = AmazonS3Util.isExistsFile('test');
			System.assertEquals(isExists, true, 'ファイル有り');

			Test.stopTest();
		}
	}
	// ▲ 2022.2.21

	// ▼ 2022.4.25 問合せNo.0773対応
    /**
	 * 物件写真アップロード(画面側)
	 * 公開写真
	 * 1.一枚以上の場合、写真最終更新日はセットされること。
	 */
    @isTest static void savephoto_public_test(){

        Property__c testProp = [
            SELECT Id, Name, ForeignID__c
            FROM Property__c
            WHERE Name = 'テスト物件'
        ];
        
        //新しい写真をアップロードデータ作成
        PropertyPhoto__c photoRcd = [SELECT Id FROM PropertyPhoto__c WHERE Property__r.Name = 'テスト物件' limit 1];
        photoRcd.PropertyPhotoFileName1__c = '公開写真テスト1.aaa';
        photoRcd.PropertyPhotoFileName2__c = '公開写真テスト2.aaa';
        update photoRcd;

		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		System.runAs(thisUser) {
            //写真保存処理→建物写真をSELECT
            GD901001ParameterClass GD901001param = new GD901001ParameterClass();
           
            //写真保存処理→物件写真をSELECT
            GD901001param.photoType = CommonConst.S3_PHOTOTYPE_PROPERTY;
            GD901001param.foreignId2 = testProp.ForeignID__c;

            GD901001param.photoSubType = CommonConst.S3_PROPERTYPHOTOTYPE_PROPERTPHOTO;// 物件写真
            AmazonS3Util.savePhoto(GD901001param);

            // コールアウトクラスのモッククラスをセット ステータスコード200
            Test.setMock(HttpCalloutMock.class, new AmazonS3UtilHTTPRequestMock(false));
            
            Test.startTest();
            AmazonS3Util.savePhoto(GD901001param);
            Test.stopTest();

            PropertyPhoto__c propertyphoto = [SELECT Id ,PropertyPhotoLastModifiedDate__c,PropertyPhotoFileName1__c,PropertyPhotoFileName2__c FROM PropertyPhoto__c ORDER BY LastModifiedDate DESC Limit 1];

            //公開写真が１枚以上の場合、写真最終更新日は最大値をセットされること。
            System.assertEquals(CommonUtil.getNow().format('yyyy-MM-dd'),propertyphoto.PropertyPhotoLastModifiedDate__c.format('yyyy-MM-dd') );
        }
    }

     /**
	 * 物件写真アップロード(画面側)
	 * 非公開写真
	 * 2.写真最終更新日はセットされないこと。
	 */
    @isTest static void savephoto_private_test(){

        Property__c testProp = [
            SELECT Id, Name, ForeignID__c
            FROM Property__c
            WHERE Name = 'テスト物件'
        ];
       
        //新しい写真をアップロードデータ作成
        PropertyPhoto__c photoRcd = [SELECT Id FROM PropertyPhoto__c WHERE Property__r.Name = 'テスト物件' limit 1];
        photoRcd.PrivatePhotoFileName1__c = '非公開写真テスト1.aaa';
        update photoRcd;

		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		System.runAs(thisUser) {
			//写真保存処理→建物写真をSELECT
			GD901001ParameterClass GD901001param = new GD901001ParameterClass();
           
            //写真保存処理→物件写真をSELECT
			GD901001param.photoType = CommonConst.S3_PHOTOTYPE_PROPERTY;
            GD901001param.foreignId2 = testProp.ForeignID__c;

            GD901001param.photoSubType = CommonConst.S3_PROPERTYPHOTOTYPE_PRIVATEPHOTO;// 非公開写真
            AmazonS3Util.savePhoto(GD901001param);

            // コールアウトクラスのモッククラスをセット ステータスコード200
            Test.setMock(HttpCalloutMock.class, new AmazonS3UtilHTTPRequestMock(false));
            
            Test.startTest();
            AmazonS3Util.savePhoto(GD901001param);
            Test.stopTest();

            PropertyPhoto__c propertyphoto = [SELECT Id ,PropertyPhotoLastModifiedDate__c,PrivatePhotoFileName1__c FROM PropertyPhoto__c ORDER BY LastModifiedDate DESC Limit 1];
            
            //非公開写真の場合、写真最終更新日は最大値をセットされないこと。
            System.assertEquals(null,propertyphoto.PropertyPhotoLastModifiedDate__c );

        }
    }

	 /**
	 * 物件写真アップロード(画面側)
	 * パノラマ写真
	 * 3.写真最終更新日はセットされないこと。
	 */
    @isTest static void savephoto_Panorama_test(){

        Property__c testProp = [
            SELECT Id, Name, ForeignID__c
            FROM Property__c
            WHERE Name = 'テスト物件'
        ];
       
        //新しい写真をアップロードデータ作成
        PropertyPhoto__c photoRcd = [SELECT Id FROM PropertyPhoto__c WHERE Property__r.Name = 'テスト物件' limit 1];
        photoRcd.PanoramaFileName1__c = 'パノラマ写真テスト1.aaa';
        update photoRcd;

		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		System.runAs(thisUser) {
            //写真保存処理→建物写真をSELECT
            GD901001ParameterClass GD901001param = new GD901001ParameterClass();
           
            //写真保存処理→物件写真をSELECT
            GD901001param.photoType = CommonConst.S3_PHOTOTYPE_PROPERTY;
            GD901001param.foreignId2 = testProp.ForeignID__c;

            GD901001param.photoSubType = CommonConst.S3_PROPERTYPHOTOTYPE_PANORAMA;// パノラマ写真
			AmazonS3Util.savePhoto(GD901001param);

            // コールアウトクラスのモッククラスをセット ステータスコード200
            Test.setMock(HttpCalloutMock.class, new AmazonS3UtilHTTPRequestMock(false));
            
            Test.startTest();
            AmazonS3Util.savePhoto(GD901001param);
            Test.stopTest();

            PropertyPhoto__c propertyphoto = [SELECT Id ,PropertyPhotoLastModifiedDate__c,PanoramaFileName1__c FROM PropertyPhoto__c ORDER BY LastModifiedDate DESC Limit 1];
            
            //非公開写真の場合、写真最終更新日は最大値をセットされないこと。
            System.assertEquals(null,propertyphoto.PropertyPhotoLastModifiedDate__c );
        }
    }

		/**
	 * 物件写真アップロード(自動メンテナンス時)
	 * 公開写真
	 * 4.一枚以上の場合、写真最終更新日はセットされること。
	 */
    @isTest static void maintephoto_public(){
		
        Property__c testProp = [
            SELECT Id, Name, ForeignID__c
            FROM Property__c
            WHERE Name = 'テスト物件'
        ];
        Property__c testProp2 = [
            SELECT Id, Name, ForeignID__c
            FROM Property__c
            WHERE Name = 'テスト物件２'
        ];
        
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		System.runAs(thisUser) {

            List<AmazonS3Util.AutoMaintePhotoMoveParameter> s3MovePhotoList = new List<AmazonS3Util.AutoMaintePhotoMoveParameter>();
            
            AmazonS3Util.AutoMaintePhotoMoveParameter autoParam1 = new AmazonS3Util.AutoMaintePhotoMoveParameter(testProp.id, 'test', new t_auto_maintenance_difference__c());
            AmazonS3Util.AutoMaintePhotoMoveDataParameter photo1 = new AmazonS3Util.AutoMaintePhotoMoveDataParameter('fromPath', 'toComment', CommonConst.AUTOMAINTEDIFF_PROPERTYPHOTOTAG_LIVING, 1,AmazonS3Util.PhotoType.PROPERTY);
            autoParam1.photoList.add(photo1);
  
            s3MovePhotoList.add(autoParam1);

            // コールアウトクラスのモッククラスをセット ステータスコード200
            Test.setMock(HttpCalloutMock.class, new AmazonS3UtilHTTPRequestMock(false));
            
            Test.startTest();
            AmazonS3Util.callPhotoMoveAutoMainte(s3MovePhotoList);
            Test.stopTest();

			PropertyPhoto__c propertyphoto = [SELECT Id ,PropertyPhotoLastModifiedDate__c FROM PropertyPhoto__c ORDER BY LastModifiedDate DESC Limit 1];
            
            //公開写真が１枚以上の場合、写真最終更新日は最大値をセットされること。
            System.assertEquals(CommonUtil.getNow().format('yyyy-MM-dd'),propertyphoto.PropertyPhotoLastModifiedDate__c.format('yyyy-MM-dd') );
        }
    }

	
	/**
	* 物件写真アップロード(自動メンテナンス時)
	* 公開写真
	* 5.0枚以上の場合、写真最終更新日はセットされること。
	*/
    @isTest static void maintephoto_public_empty(){
		
        Property__c testProp = [
            SELECT Id, Name, ForeignID__c
            FROM Property__c
            WHERE Name = 'テスト物件'
        ];
        Property__c testProp2 = [
            SELECT Id, Name, ForeignID__c
            FROM Property__c
            WHERE Name = 'テスト物件２'
        ];
        
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		System.runAs(thisUser) {

            List<AmazonS3Util.AutoMaintePhotoMoveParameter> s3MovePhotoList = new List<AmazonS3Util.AutoMaintePhotoMoveParameter>();
            
            //公開写真0枚はAutoMaintePhotoMoveParameterの設定のみ
            AmazonS3Util.AutoMaintePhotoMoveParameter autoParam1 = new AmazonS3Util.AutoMaintePhotoMoveParameter(testProp.id, 'test', new t_auto_maintenance_difference__c());
  
            s3MovePhotoList.add(autoParam1);

            // コールアウトクラスのモッククラスをセット ステータスコード200
            Test.setMock(HttpCalloutMock.class, new AmazonS3UtilHTTPRequestMock(false));
            
            Test.startTest();
            AmazonS3Util.callPhotoMoveAutoMainte(s3MovePhotoList);
            Test.stopTest();

			PropertyPhoto__c propertyphoto = [SELECT Id ,PropertyPhotoLastModifiedDate__c,PropertyPhotoFileName1__c FROM PropertyPhoto__c ORDER BY LastModifiedDate DESC Limit 1];
            
            //公開写真が0枚の場合、写真最終更新日は最大値をセットされないこと。
            System.assertEquals(null,propertyphoto.PropertyPhotoLastModifiedDate__c);
        }
    }

	/**
	* 物件写真アップロード(自動メンテナンス時)
	* 非公開写真
	* 6.写真最終更新日はセットされないこと。
	*/
    @isTest static void maintephoto_private(){
		
        Property__c testProp = [
            SELECT Id, Name, ForeignID__c
            FROM Property__c
            WHERE Name = 'テスト物件'
        ];
        Property__c testProp2 = [
            SELECT Id, Name, ForeignID__c
            FROM Property__c
            WHERE Name = 'テスト物件２'
        ];
        
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		System.runAs(thisUser) {

            List<AmazonS3Util.AutoMaintePhotoMoveParameter> s3MovePhotoList = new List<AmazonS3Util.AutoMaintePhotoMoveParameter>();
            
            AmazonS3Util.AutoMaintePhotoMoveParameter autoParam1 = new AmazonS3Util.AutoMaintePhotoMoveParameter(testProp.id, 'test', new t_auto_maintenance_difference__c());
			AmazonS3Util.AutoMaintePhotoMoveDataParameter photo1 = new AmazonS3Util.AutoMaintePhotoMoveDataParameter('fromPath', 'toComment', CommonConst.PROPERTYPHOTO_PRIVATEPHOTOTAG_OTHER, 1,AmazonS3Util.PhotoType.PROPERTY_PRIVATE);

			autoParam1.photoList.add(photo1);
  
            s3MovePhotoList.add(autoParam1);

            // コールアウトクラスのモッククラスをセット ステータスコード200
            Test.setMock(HttpCalloutMock.class, new AmazonS3UtilHTTPRequestMock(false));
            
            Test.startTest();
            AmazonS3Util.callPhotoMoveAutoMainte(s3MovePhotoList);
            Test.stopTest();

			PropertyPhoto__c propertyphoto = [SELECT Id ,PropertyPhotoLastModifiedDate__c FROM PropertyPhoto__c ORDER BY LastModifiedDate DESC Limit 1];
            
            //非公開写真が１枚以上の場合、写真最終更新日は最大値をセットされないこと。
            System.assertEquals(null,propertyphoto.PropertyPhotoLastModifiedDate__c );
        }
    }

	/**
	* 物件写真アップロード(自動メンテナンス時)
	* パノラマ写真
	* 7.写真最終更新日はセットされないこと。
	*/
    @isTest static void maintephoto_panorama(){
		
        Property__c testProp = [
            SELECT Id, Name, ForeignID__c
            FROM Property__c
            WHERE Name = 'テスト物件'
        ];
        Property__c testProp2 = [
            SELECT Id, Name, ForeignID__c
            FROM Property__c
            WHERE Name = 'テスト物件２'
        ];
        
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		System.runAs(thisUser) {

            List<AmazonS3Util.AutoMaintePhotoMoveParameter> s3MovePhotoList = new List<AmazonS3Util.AutoMaintePhotoMoveParameter>();
            
            AmazonS3Util.AutoMaintePhotoMoveParameter autoParam1 = new AmazonS3Util.AutoMaintePhotoMoveParameter(testProp.id, 'test', new t_auto_maintenance_difference__c());
			AmazonS3Util.AutoMaintePhotoMoveDataParameter photo1 = new AmazonS3Util.AutoMaintePhotoMoveDataParameter('fromPath', 'toComment', CommonConst.AUTOMAINTEDIFF_PROPERTYPHOTOTAG_LIVING, 1,AmazonS3Util.PhotoType.PROPERTY_PANORAMA);

			autoParam1.photoList.add(photo1);
  
            s3MovePhotoList.add(autoParam1);

            // コールアウトクラスのモッククラスをセット ステータスコード200
            Test.setMock(HttpCalloutMock.class, new AmazonS3UtilHTTPRequestMock(false));
            
            Test.startTest();
            AmazonS3Util.callPhotoMoveAutoMainte(s3MovePhotoList);
            Test.stopTest();

			PropertyPhoto__c propertyphoto = [SELECT Id ,PropertyPhotoLastModifiedDate__c FROM PropertyPhoto__c ORDER BY LastModifiedDate DESC Limit 1];
            
            //パノラマ写真が１枚以上の場合、写真最終更新日は最大値をセットされないこと。
            System.assertEquals(null,propertyphoto.PropertyPhotoLastModifiedDate__c);
        }
    }
    // ▲ 2022.04.25 問合せNo.0773対応

    /**
	* カバーレジ率をアップ 2022/05/10
	*/
    @isTest static void Up_coverage(){
		
        Property__c testProp = [
            SELECT Id, Name, ForeignID__c
            FROM Property__c
            WHERE Name = 'テスト物件'
        ];
        Property__c testProp2 = [
            SELECT Id, Name, ForeignID__c
            FROM Property__c
            WHERE Name = 'テスト物件２'
        ];
        
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		System.runAs(thisUser) {

            List<AmazonS3Util.AutoMaintePhotoMoveParameter> s3MovePhotoList = new List<AmazonS3Util.AutoMaintePhotoMoveParameter>();
            
            AmazonS3Util.AutoMaintePhotoMoveParameter autoParam1 = new AmazonS3Util.AutoMaintePhotoMoveParameter(testProp.id, 'test', new t_auto_maintenance_difference__c());
			AmazonS3Util.AutoMaintePhotoMoveDataParameter photo1 = new AmazonS3Util.AutoMaintePhotoMoveDataParameter('fromPath1', 'toComment1', CommonConst.AUTOMAINTEDIFF_PROPERTYPHOTOTAG_LIVING, 1,AmazonS3Util.PhotoType.PROPERTY_ROOMLAYOUT);
            autoParam1.photoList.add(photo1);
  
            s3MovePhotoList.add(autoParam1);

            // コールアウトクラスのモッククラスをセット ステータスコード200
            Test.setMock(HttpCalloutMock.class, new AmazonS3UtilHTTPRequestMock(false));
            
            Test.startTest();
            AmazonS3Util.callPhotoMoveAutoMainte(s3MovePhotoList);
            Test.stopTest();
        }
    }

	@isTest static void Up2_coverage(){
		
        Property__c testProp = [
            SELECT Id, Name, ForeignID__c
            FROM Property__c
            WHERE Name = 'テスト物件'
        ];
        Property__c testProp2 = [
            SELECT Id, Name, ForeignID__c
            FROM Property__c
            WHERE Name = 'テスト物件２'
        ];
        
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		System.runAs(thisUser) {

            List<AmazonS3Util.AutoMaintePhotoMoveParameter> s3MovePhotoList = new List<AmazonS3Util.AutoMaintePhotoMoveParameter>();
            
            AmazonS3Util.AutoMaintePhotoMoveParameter autoParam1 = new AmazonS3Util.AutoMaintePhotoMoveParameter(testProp.id, 'test', new t_auto_maintenance_difference__c());
			AmazonS3Util.AutoMaintePhotoMoveDataParameter photo1 = new AmazonS3Util.AutoMaintePhotoMoveDataParameter('fromPath1', 'toComment1', CommonConst.AUTOMAINTEDIFF_PROPERTYPHOTOTAG_LIVING, 1,AmazonS3Util.PhotoType.PROPERTY_ROOMLAYOUTMEMO);
            autoParam1.photoList.add(photo1);
  
            s3MovePhotoList.add(autoParam1);

            // コールアウトクラスのモッククラスをセット ステータスコード200
            Test.setMock(HttpCalloutMock.class, new AmazonS3UtilHTTPRequestMock(false));
            
            Test.startTest();
            AmazonS3Util.callPhotoMoveAutoMainte(s3MovePhotoList);
            Test.stopTest();
        }
    }

	@isTest static void Up3_coverage(){
		
		Building__c testBuild = [
            SELECT Id, Name, ForeignID__c
            FROM Building__c
            WHERE Name = 'テスト建物'
        ];

        Property__c testProp = [
            SELECT Id, Name, ForeignID__c
            FROM Property__c
            WHERE Name = 'テスト物件'
        ];
        Property__c testProp2 = [
            SELECT Id, Name, ForeignID__c
            FROM Property__c
            WHERE Name = 'テスト物件２'
        ];
        
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		System.runAs(thisUser) {

            List<AmazonS3Util.AutoMaintePhotoMoveParameter> s3MovePhotoList = new List<AmazonS3Util.AutoMaintePhotoMoveParameter>();
            
            AmazonS3Util.AutoMaintePhotoMoveParameter autoParam1 = new AmazonS3Util.AutoMaintePhotoMoveParameter(testBuild.id, 'test', new t_auto_maintenance_difference__c());
			AmazonS3Util.AutoMaintePhotoMoveDataParameter photo1 = new AmazonS3Util.AutoMaintePhotoMoveDataParameter('fromPath1', 'toComment1', CommonConst.AUTOMAINTDIFF_BUILDINGPHOTOTAG_APPEARANCE, 1,AmazonS3Util.PhotoType.BUILDING_APPEARANCE);
			AmazonS3Util.AutoMaintePhotoMoveDataParameter photo2 = new AmazonS3Util.AutoMaintePhotoMoveDataParameter('fromPath2', 'toComment2', CommonConst.AUTOMAINTDIFF_BUILDINGPHOTOTAG_APPEARANCE_PARSE, 1,AmazonS3Util.PhotoType.BUILDING_APPEARANCEPARSE);
			AmazonS3Util.AutoMaintePhotoMoveDataParameter photo3 = new AmazonS3Util.AutoMaintePhotoMoveDataParameter('fromPath3', 'toComment3', CommonConst.AUTOMAINTDIFF_BUILDINGPHOTOTAG_ENTRANCE, 1,AmazonS3Util.PhotoType.BUILDING_ENTRANCE);
			AmazonS3Util.AutoMaintePhotoMoveDataParameter photo4 = new AmazonS3Util.AutoMaintePhotoMoveDataParameter('fromPath4', 'toComment4', CommonConst.AUTOMAINTDIFF_BUILDINGPHOTOTAG_LOBBY, 1,AmazonS3Util.PhotoType.BUILDING_LOBBY);
			AmazonS3Util.AutoMaintePhotoMoveDataParameter photo5 = new AmazonS3Util.AutoMaintePhotoMoveDataParameter('fromPath5', 'toComment5', CommonConst.AUTOMAINTDIFF_BUILDINGPHOTOTAG_PARKING, 1,AmazonS3Util.PhotoType.BUILDING_PARKING);
			AmazonS3Util.AutoMaintePhotoMoveDataParameter photo6 = new AmazonS3Util.AutoMaintePhotoMoveDataParameter('fromPath6', 'toComment6', CommonConst.AUTOMAINTDIFF_BUILDINGPHOTOTAG_MAP, 1,AmazonS3Util.PhotoType.BUILDING_MAP);
			AmazonS3Util.AutoMaintePhotoMoveDataParameter photo7 = new AmazonS3Util.AutoMaintePhotoMoveDataParameter('fromPath7', 'toComment7', CommonConst.AUTOMAINTDIFF_BUILDINGPHOTOTAG_OTHERSHARING, 1,AmazonS3Util.PhotoType.BUILDING_OTHERSHARING);
			AmazonS3Util.AutoMaintePhotoMoveDataParameter photo8 = new AmazonS3Util.AutoMaintePhotoMoveDataParameter('fromPath8', 'toComment8', CommonConst.AUTOMAINTDIFF_BUILDINGPHOTOTAG_OTHER, 1,AmazonS3Util.PhotoType.BUILDING_OTHER);
			//AmazonS3Util.AutoMaintePhotoMoveDataParameter photo9 = new AmazonS3Util.AutoMaintePhotoMoveDataParameter('fromPath9', 'toComment9', CommonConst.AUTOMAINTDIFF_BUILDINGPHOTOTAG_SURROUNDING, 1,AmazonS3Util.PhotoType.BUILDING_SURROUNDING);

            autoParam1.photoList.add(photo1);
			autoParam1.photoList.add(photo2);
			autoParam1.photoList.add(photo3);
			autoParam1.photoList.add(photo4);
			autoParam1.photoList.add(photo5);
			autoParam1.photoList.add(photo6);
			autoParam1.photoList.add(photo7);
			autoParam1.photoList.add(photo8);
			//autoParam1.photoList.add(photo9);


            s3MovePhotoList.add(autoParam1);

            // コールアウトクラスのモッククラスをセット ステータスコード200
            Test.setMock(HttpCalloutMock.class, new AmazonS3UtilHTTPRequestMock(false));
            
            Test.startTest();
            AmazonS3Util.callPhotoMoveAutoMainte(s3MovePhotoList);
            Test.stopTest();
        }
    }
}