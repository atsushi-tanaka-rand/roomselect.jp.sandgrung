@isTest
public class GD601007Test {

    //テストに使用するレコードを作成
    @testSetup static void Setting(){
        

        // 路線
        List<TrainRoute__c> trainList = new List<TrainRoute__c>();
        trainList.add(new TrainRoute__c(Name = 'テスト路線1'));
        trainList.add(new TrainRoute__c(Name = 'テスト路線2'));
        trainList.add(new TrainRoute__c(Name = 'テスト路線3'));
        insert trainList;

        // 駅
        List<Station__c> stationList = new List<Station__c>();
        stationList.add(new Station__c(Name = 'テスト駅1', TrainRoute__c = trainList[0].Id));
        stationList.add(new Station__c(Name = 'テスト駅２',  TrainRoute__c = trainList[1].Id));
        stationList.add(new Station__c(Name = 'テスト駅３',  TrainRoute__c = trainList[2].Id));
        insert stationList;

        // 建物テストデータ作成
        Building__c leftBuild = new Building__c(
            Name = '左建物',
            District__c ='北区',
            State__c = '愛知県',
            City__c = '名古屋市物件名寄せ比較町',
            Street__c = '1-1',
            ForeignID__c = '123456789012345',
            TrainRoute1__c = trainList[0].Id,
            TrainRoute2__c = trainList[1].Id,
            TrainRoute3__c = trainList[2].Id,
            Station1__c = stationList[0].Id,
            Station2__c = stationList[1].Id,
            Station3__c = stationList[2].Id,
            StationDistance1__c  = 10,
            CaretakerType__c = CommonConst.BUILDING_CARETAKERTYPE_NORESIDE,
            GroundFloorCount__c = 1,
            MaintenanceBuildingCode__c = 'メンテナンス建物コード'
            );    
        insert leftBuild;
        //スリープ
        CommonUtil.sleep(1000);

        Building__c rightBuild = new Building__c(
            Name = '右建物',
            District__c ='南区',
            State__c = '大阪府',
            City__c = '南大阪市',
            Street__c = '2-2',
            ForeignID__c = '123456789112345',
            TrainRoute1__c = trainList[0].Id,
            TrainRoute2__c = trainList[1].Id,
            Station1__c = stationList[0].Id,
            Station2__c = stationList[1].Id,
            CaretakerType__c = CommonConst.BUILDING_CARETAKERTYPE_RESIDE
            );    
        insert rightBuild;

        //物件
        Property__c leftPro = new Property__c(//左
            Name = '左物件',//名前
            building__c = leftBuild.id,//建物
            FloorType__c = CommonConst.PROPERTY_FLOORTYPE_GROUND,
            Floor__c = 1
            );
            insert leftPro;
        //スリープ
        CommonUtil.sleep(1000);

        Property__c rightPro = new Property__c(//右
            Name = '右物件',//名前
            building__c = rightBuild.id//建物
            );
            insert rightPro;

        //建物写真
        BuildingPhoto__c leftBuildPhoto = new BuildingPhoto__c(//左
            building__c = leftBuild.id,//建物
            AppearanceFileName__c  = '左建物写真'
        );
        insert leftBuildPhoto;

        //建物写真
        BuildingPhoto__c rightBuildPhoto = new BuildingPhoto__c(//右
            building__c = rightBuild.id,//建物
            AppearanceFileName__c = '右建物写真',
            SurroundingPhotoName1__c = '右建物写真2'
        );
        insert rightBuildPhoto;

        //物件写真
        PropertyPhoto__c leftPropertyPhoto = new PropertyPhoto__c(//左
        Property__c = leftPro.id,//建物
        PropertyPhotoComment1__c  = '左物件写真'
        );
        insert leftPropertyPhoto;

        //物件条件
        PropertyConditions__c leftProCond  = new PropertyConditions__c(//左
            Property__c = leftPro.Id
        );
        insert leftProCond;
        PropertyConditions__c rightProCond  = new PropertyConditions__c(//右 
            Property__c = rightPro.Id
        );
        insert rightProCond;

        // 取引先
        Account acc1 = new Account(
            Name = 'テスト取引先1'
        );
        Account acc2 = new Account(
            Name = 'テスト取引先2'
        );
        List<Account> accList = new List<Account>{
            acc1
            , acc2
        };
        insert accList;

        // 空室予約物件
        VacancyReservationProperty__c vacancyReservationProp1 = new VacancyReservationProperty__c(
            Account__c = acc1.Id
            , Building__c = rightBuild.Id
        );        
        VacancyReservationProperty__c vacancyReservationProp2 = new VacancyReservationProperty__c(
            Account__c = acc2.Id    
            , Building__c = rightBuild.Id
        );        
        VacancyReservationProperty__c vacancyReservationProp3 = new VacancyReservationProperty__c(
            Account__c = acc2.Id    
            , Building__c = leftBuild.Id
        );
        List<VacancyReservationProperty__c> vacancyReservationPropList = new List<VacancyReservationProperty__c>{
            vacancyReservationProp1
            , vacancyReservationProp2
            , vacancyReservationProp3
        };

        insert vacancyReservationPropList;
    }

    // 初期表示テスト(新規)
    @isTest static void initializeTest(){
        Building__c build1 = [SELECT Id FROM Building__c WHERE Name = '左建物'];
        Building__c build2 = [SELECT Id FROM Building__c WHERE Name = '右建物'];

        //パラメータ設定
        PageReference pageRef = Page.GD601007View;
        pageRef.getParameters().put('id1', build1.Id);
        pageRef.getParameters().put('id2', build2.Id);

        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GD601007Controller testController = new GD601007Controller();
        System.assertEquals('左建物', testController.leftBuilding.Name);
        System.assertEquals('左物件', testController.leftProList[0].Name);
        System.assertEquals('左建物写真', testController.leftPhoto.AppearanceFileName__c);

    }
    // 初期表示テスト(異常)
    @isTest static void initializeErrorTest(){

        //パラメータ設定
        PageReference pageRef = Page.GD601007View;
        pageRef.getParameters().put('id1', 'エラー発生用の');
        pageRef.getParameters().put('id2', '適当な文字列');

        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GD601007Controller testController = new GD601007Controller();

        //「エラーフラグ」がTRUEに設定されている？
        system.assertEquals(testController.isOpenError, TRUE);

        //「エラーメッセージ」が正しく設定されている？
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonConst.MSG_COM_E_SYSTEM_PARAMETER);
    }

    // 登録ボタン（左に寄せる）
    @isTest static void leftMergeTest(){
        Building__c build1 = [SELECT Id FROM Building__c WHERE Name = '左建物'];
        Building__c build2 = [SELECT Id FROM Building__c WHERE Name = '右建物'];

        //パラメータ設定
        PageReference pageRef = Page.GD601007View;
        pageRef.getParameters().put('id1', build1.Id);
        pageRef.getParameters().put('id2', build2.Id);

        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GD601007Controller testController = new GD601007Controller();


        testController.leftCheckList[0] = TRUE;
        testController.leftCheckList[1] = TRUE;
        testController.leftCheckList[2] = TRUE;

        testController.save();

        List<Building__c> savedBuild1 = [SELECT Id, Name FROM Building__c WHERE Id = :build1.Id];//左の建物レコード
        List<Building__c> savedBuild2 = [SELECT Id, Name FROM Building__c WHERE Id = :build2.Id];//右の建物レコード
        List<BuildingPhoto__c> buildingPhoto = [SELECT Id FROM BuildingPhoto__c WHERE building__c = :build2.Id];//右の建物写真レコード
        List<Property__c> property = [SELECT Id FROM Property__c WHERE building__c = :build2.Id];//右の物件レコード


        System.assertEquals('左建物', savedBuild1[0].Name);//左の建物レコードが、ラジオボタンでチェックした値に更新されている
        System.assertEquals(True, savedBuild2.isEmpty());//右の建物レコードが、削除されている
        System.assertEquals(True, buildingPhoto.isEmpty());//右の建物写真レコードが、削除されている
        System.assertEquals(True, property.isEmpty());//右の物件レコードが削除されている

        
    }
    // 登録ボタン（右に寄せる）
    @isTest static void rightMergeTest(){
        Building__c build1 = [SELECT Id FROM Building__c WHERE Name = '左建物'];
        Building__c build2 = [SELECT Id FROM Building__c WHERE Name = '右建物'];

        //パラメータ設定
        PageReference pageRef = Page.GD601007View;
        pageRef.getParameters().put('id1', build1.Id);
        pageRef.getParameters().put('id2', build2.Id);

        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GD601007Controller testController = new GD601007Controller();

        testController.BasicInfoRadioButton = '右';

        testController.rightCheckList[0] = TRUE;

        testController.save();

        List<Building__c> savedBuild1 = [SELECT Id, Name FROM Building__c WHERE Id = :build1.Id];//左の建物レコード
        List<Building__c> savedBuild2 = [SELECT Id, Name FROM Building__c WHERE Id = :build2.Id];//右の建物レコード
        List<BuildingPhoto__c> buildingPhoto = [SELECT Id FROM BuildingPhoto__c WHERE building__c = :build1.Id];//左の建物写真レコード
        List<Property__c> property = [SELECT Id FROM Property__c WHERE building__c = :build1.Id];//左の物件レコード
        

        System.assertEquals('右建物', savedBuild2[0].Name);//右の建物レコードが、ラジオボタンでチェックした値に更新されている
        System.assertEquals(True, savedBuild1.isEmpty());//左の建物レコードが、削除されている
        System.assertEquals(True, buildingPhoto.isEmpty());//左の建物写真レコードが、削除されている
        System.assertEquals(True, property.isEmpty());//左の物件レコードが削除されている

    }

    // 登録ボタン
    @isTest static void mergeErrorTest(){
        Building__c build1 = [SELECT Id FROM Building__c WHERE Name = '左建物'];
        Building__c build2 = [SELECT Id FROM Building__c WHERE Name = '右建物'];

        //パラメータ設定
        PageReference pageRef = Page.GD601007View;
        pageRef.getParameters().put('id1', build1.Id);
        pageRef.getParameters().put('id2', build2.Id);

        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GD601007Controller testController = new GD601007Controller();

        CommonUtil.sleep(2000);

        upsert build1;


        testController.leftCheckList[0] = TRUE;

        testController.save();

        //「エラーフラグ」がTRUEに設定されている？
        system.assertEquals(testController.hasErrorMessage, TRUE);

        //「エラーメッセージ」が正しく設定されている？
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK));
    
    }
    //カバレッジ率あげる用
    @isTest static void coverageUp(){
        Building__c build1 = [SELECT Id, CaretakerType__c FROM Building__c WHERE Name = '左建物'];
        Building__c build2 = [SELECT Id, CaretakerType__c FROM Building__c WHERE Name = '右建物'];

        build1.CaretakerType__c = CommonConst.BUILDING_CARETAKERTYPE_PATROL;//管理人種別「巡回方式」
        build2.CaretakerType__c = CommonConst.BUILDING_CARETAKERTYPE_COMMUTER;//管理人種別「通勤方式」

        //管理人種別変更
        update build1;
        update build2;


        //パラメータ設定
        PageReference pageRef = Page.GD601007View;
        pageRef.getParameters().put('id1', build2.Id);
        pageRef.getParameters().put('id2', build1.Id);

        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GD601007Controller testController = new GD601007Controller();

        testController.getBuildingRadioButtonSetting();
        testController.getBasicInfoRadioButtonSetting();


        testController.save();//左名寄せ


        //「エラーフラグ」がTRUEに設定されている？
        system.assertEquals(testController.hasErrorMessage, TRUE);

        //「エラーメッセージ」が正しく設定されている？
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SELECTION_OR_MORE,'建物名のチェックボックス','1'));


        testController.leftCheckList[0] = TRUE;

        
        testController.save();//左名寄せ


        testController.leftCheckList[1] = TRUE;
        testController.leftCheckList[2] = TRUE;
        testController.rightCheckList[0] = TRUE;
        testController.rightCheckList[1] = TRUE;
        testController.rightCheckList[2] = TRUE;

        testController.save();//右名寄せ

        //「エラーフラグ」がTRUEに設定されている？
        system.assertEquals(testController.hasErrorMessage, TRUE);

        //「エラーメッセージ」が正しく設定されている？
        system.assertEquals(ApexPages.getMessages()[1].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SELECTION_OR_LESS,'建物名のチェックボックス','3'));

    }
    //カバレッジ率あげる用
    @isTest static void coverageUp2(){
        Building__c build1 = [SELECT Id, CaretakerType__c FROM Building__c WHERE Name = '左建物'];
        Building__c build2 = [SELECT Id, CaretakerType__c FROM Building__c WHERE Name = '右建物'];

        build1.CaretakerType__c = CommonConst.BUILDING_CARETAKERTYPE_PATROL;//管理人種別「巡回方式」
        build2.CaretakerType__c = CommonConst.BUILDING_CARETAKERTYPE_COMMUTER;//管理人種別「通勤方式」

        //管理人種別変更
        update build1;
        update build2;

        BuildingPhoto__c leftBuildPhoto = [SELECT Id FROM BuildingPhoto__c WHERE building__c = :build1.Id];

        leftBuildPhoto.SurroundingPhotoName1__c = '左建物写真2';
        leftBuildPhoto.SurroundingPhotoName2__c = '左建物写真3';

        //建物写真枚数変更
        update leftBuildPhoto;

        //パラメータ設定
        PageReference pageRef = Page.GD601007View;
        pageRef.getParameters().put('id1', build1.Id);
        pageRef.getParameters().put('id2', build2.Id);

        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GD601007Controller testController = new GD601007Controller();

        testController.leftCheckList[0] = TRUE;

        testController.BasicInfoRadioButton = '右';
        testController.save();//右名寄せ

    }

    //ポータルサイト構築 追加 Start
    //おすすめ物件名寄せ
    @isTest static void recoProMerge(){

        //システム設定を作成
        SystemConfig__c s = new SystemConfig__c(
            UseAuthority_Portal__c = true
            );
        insert s;

        //建物取得
        Building__c build1 = [SELECT Id, CaretakerType__c,ForeignID__c FROM Building__c WHERE Name = '左建物'];
        Building__c build2 = [SELECT Id, CaretakerType__c,ForeignID__c FROM Building__c WHERE Name = '右建物'];

        //物件取得
        Property__c leftPro = [SELECT Id,ForeignID__c,PropertyCode__c FROM Property__c WHERE Name = '左物件'];

        //おすすめ物件登録（左）
        RecommendProperty__c leftRecoPro = new RecommendProperty__c(PropertyCode__c = leftPro.PropertyCode__c,
                                                                Property__c = leftPro.Id,
                                                                PhotoFilePath__c = 'https://cloud-cube-jp.s3.amazonaws.com/txxsx2rp38f8/forTest/public/salesforce/photo/building_property/' + build1.ForeignID__c + '/' + leftPro.ForeignID__c + '/PROPERTPHOTO0020201125135447.jpg');
        
        insert leftRecoPro;
        //パラメータ設定
        PageReference pageRef = Page.GD601007View;
        pageRef.getParameters().put('id1', build1.Id);
        pageRef.getParameters().put('id2', build2.Id);

        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GD601007Controller testController = new GD601007Controller();

        testController.leftCheckList[0] = TRUE;

        testController.BasicInfoRadioButton = '右';
        testController.save();//右に名寄せ

        List<RecommendProperty__c> mergeRecoPro = [SELECT PhotoFilePath__c FROM RecommendProperty__c];
        //外部Idが右建物のものになっている？
        system.assertEquals(true,mergeRecoPro[0].PhotoFilePath__c.contains(build2.ForeignID__c));
    }
    
}