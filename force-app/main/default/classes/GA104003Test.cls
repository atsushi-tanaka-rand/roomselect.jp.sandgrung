/**
 * 建物登録のテストクラス
 */
@isTest 
private class GA104003Test {

    public static final String USER_NAME = 'GA104003@horaguchi.com'; 
    static GA104003Controller GA104003Controller = new GA104003Controller();

    @testSetup static void Setting(){

        // システム設定
        SystemConfig__c sysconf = new SystemConfig__c(
            PropertySearchMaxCount__c = 5000
        );
        insert sysconf;

        //ユーザ作成
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name IN ('一般ユーザ')];
        System.assert(profiles.size() > 0);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            insert new User(
                UserName = USER_NAME,
                Email = 'test@example.com',
                LastName = 'test',
                Alias = 'test',
                TimeZoneSidKey = 'Asia/Tokyo',
                LocaleSidKey = 'ja_JP',
                EmailEncodingKey = 'ISO-2022-JP',
                LanguageLocaleKey = 'ja',
                ProfileId = profiles.get(0).Id
            );
        }

        //▼2022.04.13 No0782 対応で追加
        // 路線
        List<TrainRoute__c> trainList = new List<TrainRoute__c>();
        trainList.add(new TrainRoute__c(Name = 'テスト路線1'));
        trainList.add(new TrainRoute__c(Name = 'テスト路線2'));
        trainList.add(new TrainRoute__c(Name = 'テスト路線3'));
        trainList.add(new TrainRoute__c(Name = '更新確認路線1'));
        trainList.add(new TrainRoute__c(Name = '更新確認路線2'));
        trainList.add(new TrainRoute__c(Name = '更新確認路線3'));
        //▲2022.04.13 No0782 対応で追加
        insert trainList;

        //▼2022.04.13 No0782 対応で追加
        // 駅
        List<Station__c> stationList = new List<Station__c>();
        stationList.add(new Station__c(Name = 'テスト駅1', TrainRoute__c = trainList[0].Id));
        stationList.add(new Station__c(Name = 'テスト駅_重複名称', TrainRoute__c = trainList[0].Id,Remarks__c='0806用1'));
        stationList.add(new Station__c(Name = 'テスト駅2',  TrainRoute__c = trainList[1].Id));
        stationList.add(new Station__c(Name = 'テスト駅_重複名称', TrainRoute__c = trainList[1].Id,Remarks__c='0806用2'));
        stationList.add(new Station__c(Name = 'テスト駅3',  TrainRoute__c = trainList[2].Id));
        stationList.add(new Station__c(Name = '更新確認駅1',  TrainRoute__c = trainList[3].Id));
        stationList.add(new Station__c(Name = '更新確認駅2',  TrainRoute__c = trainList[4].Id));
        stationList.add(new Station__c(Name = '更新確認駅3',  TrainRoute__c = trainList[5].Id));
        //▲2022.04.13 No0782 対応で追加
        insert stationList;
    }

    /** タグ **/
    static List<SelectOption> tagOption = CommonUtil.getSelectOptionFromObject('BuildingPhoto__c', 'Tag__c', FALSE);

    /** 周辺環境タグ **/
    static List<SelectOption> surroundingEnvironmentOption = CommonUtil.getSelectOptionFromObject('BuildingPhoto__c', 'SurroundingEnvironment__c', FALSE);

    
    // 建物テストデータ作成
    static List<Building__c> createBuilding(String name) {

        Building__c building = new Building__c();

        building.Name = name;

        insert building;

        List<Building__c> buildingList = [SELECT ID, SystemModStamp FROM Building__c WHERE Name = :name];

        return buildingList;
    }	

    // 物件テストデータ作成
    static void createProperty(Building__c building) {

        Property__c property1 = new Property__c(
            Floor__c = 4
            , Building__c = building.Id
        );

        Property__c property2 = new Property__c(
            Floor__c = 3
            , Building__c = building.Id
        );

        Property__c property3 = new Property__c(
            Floor__c = null
            , Building__c = building.Id
        );

        List<Property__c> propertyList = new List<Property__c> {
            property1
            , property2
            , property3
        };
        insert propertyList;
    }	

    // 建物写真テストデータ作成
    static List<BuildingPhoto__c> createBuildingPhoto(String buildingID, String tag, String SurroundingEnvironment) {

        BuildingPhoto__c buildingPhoto = new BuildingPhoto__c();

        return null;
    }	    
    
    // 駅テストデータ作成
    static List<Station__c> createStation() {

        List<Station__c> stationList = new List<Station__c>();
        Station__c station = new Station__c();
        TrainRoute__c trainRoute = new TrainRoute__c();

        trainRoute.name = 'testTrain';

        insert trainRoute;

        trainRoute = [SELECT ID FROM TrainRoute__c];

        for( Integer i = 1 ; i < 4 ; i++){
            station = new Station__c();
            station.Name = '駅' + i;
            station.TrainRoute__c = trainRoute.ID;
            stationList.add(Station);
        }

        insert stationList;

        stationList = [SELECT ID, NAME FROM Station__c];

        system.debug('駅作成' + stationList);

        return stationList;
    }	

	//画面表示（初期表示）：表示データなし
     @isTest static void newInintializeTest(){



        // コントローラの初期表示を実行
        GA104003Controller GA104003Controller = new GA104003Controller();

    }	

	//画面表示（初期表示）：表示データあり
     @isTest static void inintializeTest(){

        // テストデータ作成
        List<Building__c> building = new List<Building__c>();
        
        //　建物作成
        building = createBuilding('inintializeTest');

        system.debug('building[0].ID' + building[0].ID);

        // 建物写真作成
        createBuildingPhoto(building[0].ID, '周辺写真', 'コンビニ');

        //パラメータ設定
        PageReference pageRef = Page.GA104003View;
        pageRef.getParameters().put('Id',building[0].ID );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA104003Controller GA104003Controller = new GA104003Controller();
        system.assertEquals(GA104003Controller.isUnnecessaryMosaic, true);

    }	

	//都道府県選択変更処理
     @isTest static void changeStateTest(){

        // テストデータ　国土地理協会住所
        JapanGeographicDataCenterAddress__c centerAddress = new JapanGeographicDataCenterAddress__c();
        
        // 国土地理協会住所 都道府県
        centerAddress.State__c = '北海道';

        // 国土地理協会住所 市区郡町村
        centerAddress.City__c = '建物詳細区テスト';

        // 国土地理協会住所 新町・字コード
        centerAddress.ChoazaCodeNew__c = '11111111111';

        insert centerAddress;



        // コントローラの初期表示を実行
        GA104003Controller GA104003Controller = new GA104003Controller();

        GA104003Controller.displayTargetRecord.state = '北海道';
        GA104003Controller.displayTargetRecord.city = '建物詳細区テスト';

        GA104003Controller.changeState();

        system.debug('choazaCode:' + GA104003Controller.displayTargetRecord.choazaCode);
        system.debug('district:' + GA104003Controller.displayTargetRecord.district);



    }	

	//住所1入力確定処理
     @isTest static void changeCityTest(){

        // テストデータ　国土地理協会住所
        JapanGeographicDataCenterAddress__c centerAddress = new JapanGeographicDataCenterAddress__c();
        
        // 国土地理協会住所 都道府県
        centerAddress.State__c = '北海道';

        // 国土地理協会住所 市区郡町村
        centerAddress.City__c = '建物詳細区テスト';

        // 国土地理協会住所 新町・字コード
        centerAddress.ChoazaCodeNew__c = '11111111111';

        insert centerAddress;



        // コントローラの初期表示を実行
        GA104003Controller GA104003Controller = new GA104003Controller();

        GA104003Controller.displayTargetRecord.state = '北海道';
        GA104003Controller.displayTargetRecord.city = '建物詳細区テスト';

        GA104003Controller.changeCity();

        system.debug('choazaCode:' + GA104003Controller.displayTargetRecord.choazaCode);
        system.debug('district:' + GA104003Controller.displayTargetRecord.district);


    }	

	//周辺情報を再取得ボタン押下処理
     @isTest static void getSurroundingEnvironmentTest(){

        // コントローラの初期表示を実行
        GA104003Controller GA104003Controller = new GA104003Controller();

        GA104003Controller.displayTargetRecord.state = '北海道';
        GA104003Controller.displayTargetRecord.city = '建物詳細区テスト';
        GA104003Controller.displayTargetRecord.street = '住所2';

        GA104003Controller.getSurroundingEnvironment();


    }	
		

	//郵便番号検索・住所検索押下処理
     @isTest static void GA102006FormOpenTest(){

         //コントローラ作成
        GA104003Controller GA104003Controller = new GA104003Controller();

        //郵便番号検索・住所検索表示
        GA104003Controller.GA102006FormOpen();

        //郵便番号検索・住所検索非表示
        GA104003Controller.GA102006FormClose();
    }	

	//保存
     @isTest static void saveBuildingTest(){

        // テストデータ作成
        List<Building__c> building = new List<Building__c>();
        List<BuildingPhoto__c> BuildingPhoto = new List<BuildingPhoto__c>();
        
        //　建物作成
        building = createBuilding('saveBuildingTest');

        system.debug('building[0].ID' + building[0].ID);

        // 建物写真作成
        BuildingPhoto = createBuildingPhoto(building[0].ID, '周辺写真', 'コンビニ');


        //パラメータ設定
        PageReference pageRef = Page.GA104003View;
        pageRef.getParameters().put('Id',building[0].ID );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA104003Controller GA104003Controller = new GA104003Controller();

        //更新時間調整用に待機
        CommonUtil.sleep(2000);

        GA104003Controller.displayTargetRecord.buildName = '建物';
        GA104003Controller.displayTargetRecord.city = '建物';
        GA104003Controller.displayTargetRecord.street = '建物';
        GA104003Controller.displayTargetRecord.propertyType = 'マンション';
        GA104003Controller.displayTargetRecord.structure = 'PC';
        GA104003Controller.displayTargetRecord.buildingYM = '201212';
        GA104003Controller.displayTargetRecord.groundFloorCount = '1';
        GA104003Controller.displayTargetRecord.undergroundFloorCount = '1';
        GA104003Controller.displayTargetRecord.latitude = 30;
        GA104003Controller.displayTargetRecord.longitude = 131;
        GA104003Controller.displayTargetRecord.choazaCode = '1';

        GA104003Controller.saveBuilding();

        Building__c savedBuilding = [SELECT SystemModStamp, Name FROM Building__c WHERE ID = :building[0].ID];

        //BuildingPhoto__c savedBuildingPhoto = [SELECT SystemModStamp FROM BuildingPhoto__c WHERE ID = :BuildingPhoto[0].ID];



    }	

	//削除
     @isTest static void deleteBuildingTest(){

        // テストデータ作成
        List<Building__c> building = new List<Building__c>();
        List<BuildingPhoto__c> BuildingPhoto = new List<BuildingPhoto__c>();
        
        //　建物作成
        building = createBuilding('deleteBuildingTest');

        system.debug('building[0].ID' + building[0].ID);

        // 建物写真作成
        BuildingPhoto = createBuildingPhoto(building[0].ID, '周辺写真', 'コンビニ');

        //パラメータ設定
        PageReference pageRef = Page.GA104003View;
        pageRef.getParameters().put('Id',building[0].ID );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA104003Controller GA104003Controller = new GA104003Controller();

        GA104003Controller.deleteBuilding();

        //「建物」が削除されている？
        List<Building__c> existBuilding = [SELECT ID FROM Building__c WHERE ID = :building[0].ID];

        system.assertEquals(existBuilding.size(), 0 );

    }	

	//初期表示(異常系)
     @isTest static void parameterErrorTest(){


        //パラメータ設定
        PageReference pageRef = Page.GA104003View;
        pageRef.getParameters().put('Id','InvalidID' );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA104003Controller GA104003Controller = new GA104003Controller();

        //「エラーフラグ」がTRUEに設定されている？
        system.assertEquals(GA104003Controller.isOpenError, TRUE);

        //「エラーメッセージ」が正しく設定されている？
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonConst.MSG_COM_E_SYSTEM_PARAMETER);


    }	

	//保存(異常系)1:必須入力エラー
     @isTest static void notInputSaveErrorTest(){



        // コントローラの初期表示を実行
        GA104003Controller GA104003Controller = new GA104003Controller();

        GA104003Controller.saveBuilding();


        //入力チェックエラー文作成
        List<String> requiredItem = new List<String>();

        requiredItem.add('建物名');

        //「エラーメッセージ」が正しく設定されている？
        //system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ',')));

        //「エラーフラグ」がTRUEに設定されている？
        system.assertEquals(GA104003Controller.hasErrorMessage, TRUE);

        // 建物が保存されていないか確認
         List<Building__c> existBuilding = [SELECT ID FROM Building__c];

        //「建物」が保存されていない？
        system.assertEquals(existBuilding.size(), 0 );
        
    }	


	//保存(異常系)3:町・字入力エラー
     @isTest static void notInputChoazaSaveErrorTest(){



        // コントローラの初期表示を実行
        GA104003Controller GA104003Controller = new GA104003Controller();

        GA104003Controller.displayTargetRecord.buildName = '建物名';
        GA104003Controller.displayTargetRecord.city = '住所1';

        GA104003Controller.saveBuilding();
        

        //「エラーメッセージ」が正しく設定されている？
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_PROP_E_SAVE_ADDRESS_MASTER_NOT_EXIST));

        //「エラーフラグ」がTRUEに設定されている？
        system.assertEquals(GA104003Controller.hasErrorMessage, TRUE);

        // 建物が保存されていないか確認
         List<Building__c> existBuilding = [SELECT ID FROM Building__c];

        //「建物」が保存されていない？
        system.assertEquals(existBuilding.size(), 0 );
        
    }	

	//保存(異常系)4:バス入力エラー
     @isTest static void notInputBusSaveErrorTest(){

        // テストデータ作成
        List<Building__c> building = new List<Building__c>();
        
        //　建物作成
        building = createBuilding('notInputBusSaveErrorTest');

        system.debug('building[0].ID' + building[0].ID);

        //パラメータ設定
        PageReference pageRef = Page.GA104003View;
        pageRef.getParameters().put('Id',building[0].ID );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA104003Controller GA104003Controller = new GA104003Controller();
        
        GA104003Controller.displayTargetRecord.buildName = '建物名';

        GA104003Controller.displayTargetRecord.busStop1 = 'バス停名1';//バス停名1
        GA104003Controller.displayTargetRecord.busStop2 = 'バス停名2';//バス停名2
        GA104003Controller.displayTargetRecord.busStop3 = 'バス停名3';//バス停名3

        GA104003Controller.saveBuilding();

        //入力チェックエラー文作成
        List<String> requiredItem = new List<String>();

        requiredItem.add('バス路線名1');
        requiredItem.add('バス停1までの距離(m)');
        requiredItem.add('バス乗車時間1(分)');
        requiredItem.add('バス停1からの距離(m)');
        
        requiredItem.add('バス路線名2');
        requiredItem.add('バス停2までの距離(m)');
        requiredItem.add('バス乗車時間2(分)');
        requiredItem.add('バス停2からの距離(m)');

        requiredItem.add('バス路線名3');
        requiredItem.add('バス停3までの距離(m)');
        requiredItem.add('バス乗車時間3(分)');
        requiredItem.add('バス停3からの距離(m)');

        //「エラーメッセージ」が正しく設定されている？
        //system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ',')));


        //「エラーフラグ」がTRUEに設定されている？
        system.assertEquals(GA104003Controller.hasErrorMessage, TRUE);

    }	

	//保存(異常系)5:楽観ロックチェックエラー
     @isTest static void saveErrorTest(){

        // テストデータ作成
        List<Building__c> building = new List<Building__c>();
        List<BuildingPhoto__c> BuildingPhoto = new List<BuildingPhoto__c>();
        
        //　建物作成
        building = createBuilding('saveErrorTest');

        system.debug('building[0].ID' + building[0].ID);

        // 建物写真作成
        BuildingPhoto = createBuildingPhoto(building[0].ID, '周辺写真', 'コンビニ');

        //パラメータ設定
        PageReference pageRef = Page.GA104003View;
        pageRef.getParameters().put('Id',building[0].ID );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA104003Controller GA104003Controller = new GA104003Controller();

        //更新時間調整用に待機
        CommonUtil.sleep(2000);

        GA104003Controller.displayTargetRecord.buildName = '建物保存';

        GA104003Controller.saveBuilding();

        Building__c savedBuilding = [SELECT SystemModStamp, Name FROM Building__c WHERE ID = :building[0].ID];

        //BuildingPhoto__c savedBuildingPhoto = [SELECT SystemModStamp FROM BuildingPhoto__c WHERE ID = :BuildingPhoto[0].ID];


        //「建物」が更新されている？
        // system.assertNotEquals(savedBuilding.SystemModStamp, GA104003Controller.displayTargetRecord.targetBuildingRecord.SystemModStamp );

        //更新時間調整用に待機
        CommonUtil.sleep(2000);

        GA104003Controller.saveBuilding();

        //「エラーフラグ」がTRUEに設定されている？
        // system.assertEquals(GA104003Controller.hasErrorMessage, TRUE);

        //「エラーメッセージ」が正しく設定されている？
        // system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK));

    }	

	//保存(異常系)4:地上階数入力エラー
    @isTest static void SaveErrorTestGroundFloorCount(){

        // テストデータ作成
        List<Building__c> building = createBuilding('inintializeTest');
        createProperty(building[0]);

        //パラメータ設定
        PageReference pageRef = Page.GA104003View;
        pageRef.getParameters().put('Id',building[0].ID );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA104003Controller GA104003Controller = new GA104003Controller();

        GA104003Controller.displayTargetRecord.groundFloorCount = '2';
        GA104003Controller.saveBuilding();        
    }	

	//削除(異常系)
     @isTest static void deleteErrorTest(){

        // テストデータ作成
        List<Building__c> building = new List<Building__c>();
        List<BuildingPhoto__c> BuildingPhoto = new List<BuildingPhoto__c>();
        
        //　建物作成
        building = createBuilding('saveErrorTest');

        system.debug('building[0].ID' + building[0].ID);

        // 建物写真作成
        BuildingPhoto = createBuildingPhoto(building[0].ID, '周辺写真', 'コンビニ');

        //パラメータ設定
        PageReference pageRef = Page.GA104003View;
        pageRef.getParameters().put('Id',building[0].ID );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA104003Controller GA104003Controller = new GA104003Controller();

        //更新時間調整用に待機
        CommonUtil.sleep(2000);

        GA104003Controller.displayTargetRecord.buildName = '建物保存';

        GA104003Controller.saveBuilding();

        Building__c savedBuilding = [SELECT SystemModStamp, Name FROM Building__c WHERE ID = :building[0].ID];

        //BuildingPhoto__c savedBuildingPhoto = [SELECT SystemModStamp FROM BuildingPhoto__c WHERE ID = :BuildingPhoto[0].ID];


        //「建物」が更新されている？
        // system.assertNotEquals(savedBuilding.SystemModStamp, GA104003Controller.displayTargetRecord.targetBuildingRecord.SystemModStamp );

        GA104003Controller.deleteBuilding();
        GA104003Controller.deleteBuilding();
        

        //「エラーフラグ」がTRUEに設定されている？
        system.assertEquals(GA104003Controller.hasErrorMessage, TRUE);
        
        //「エラーメッセージ」が正しく設定されている？
        system.assertEquals(ApexPages.getMessages()[1].getDetail(),CommonConst.MSG_COM_E_NOTICE_DELETED);
    }	

    
	//保存(異常系)6(2020/01/17追加)
     @isTest static void notInputSurroundingEnvironmentErrorTest(){

        // テストデータ作成
        List<Building__c> building = new List<Building__c>();
        List<BuildingPhoto__c> BuildingPhoto = new List<BuildingPhoto__c>();
        
        //　建物作成
        building = createBuilding('saveErrorTest');

        system.debug('building[0].ID' + building[0].ID);

        // 建物写真作成
        BuildingPhoto = createBuildingPhoto(building[0].ID, '周辺写真', 'コンビニ');

        //パラメータ設定
        PageReference pageRef = Page.GA104003View;
        pageRef.getParameters().put('Id',building[0].ID );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA104003Controller GA104003Controller = new GA104003Controller();

        GA104003Controller.displayTargetRecord.buildName = '建物保存';


        GA104003Controller.saveBuilding();




        system.debug('ApexPages.getMessages()[0].getDetail()' + ApexPages.getMessages()[0].getDetail());
    }	

	//モザイク処理不要チェック変更処理
     @isTest static void changeIsUnnecessaryMosaicTest(){



        // コントローラの初期表示を実行
        GA104003Controller GA104003Controller = new GA104003Controller();

        GA104003Controller.isUnnecessaryMosaic = FALSE;

        //GA104003Controller.changeIsUnnecessaryMosaic();

        //system.assertEquals(TRUE, GA104003Controller.isUnnecessaryMosaic);

        //GA104003Controller.changeIsUnnecessaryMosaic();
        //system.assertEquals(FALSE, GA104003Controller.isUnnecessaryMosaic);

     }
    
    //カバレッジ率上昇
    @isTest static void forCoverage(){
        GA104003Controller g = new GA104003Controller();
        
        //メッセージ系呼び出し
        String a;
        a = g.MSG_COM_V_SAVE;
        a = g.MSG_COM_I_SAVE;
        a = g.MSG_COM_V_DELETE;
        a = g.MSG_COM_I_DELETE;
        a = g.MSG_PROP_E_SAVE_ADDRESS_MASTER_NOT_EXIST;
        a = g.MSG_PROP_V_REACQUISITION_SURROUNDING_INFO;
        a = g.MSG_PROP_I_FACILITY_IMPORT_END;
        a = g.MSG_COM_W_SELECTION_IMAGE_FILETYPE;
        a = g.uploadPhotoType;
        a = g.BUILDINGPHOTOTYPE_SURROUNDING;
        
        Integer b;
        b = g.deletePhotoIndex;
        b = g.MAXINDEX_SURROUNDINGPHOTO;
        
        g.deleteSurroundingPhoto();

    }


    // 一括削除ボタンの操作▼問合せNo0345で追加
    @isTest static void delPhotoButton(){
        // テストデータ作成
        List<Building__c> building = new List<Building__c>();
        List<BuildingPhoto__c> BuildingPhoto = new List<BuildingPhoto__c>();
        
        //　建物作成
        building = createBuilding('saveErrorTest');

        system.debug('building[0].ID' + building[0].ID);

        // 建物写真作成
        BuildingPhoto = createBuildingPhoto(building[0].ID, '周辺写真', 'コンビニ');

        //パラメータ設定
        PageReference pageRef = Page.GA104003View;
        pageRef.getParameters().put('Id',building[0].ID );
        Test.setCurrentPage(pageRef);
        // コントローラの初期表示を実行
        GA104003Controller GA104003Controller = new GA104003Controller();

        GA104003Controller.deletePhotoAll();
    }
    // 一括削除ボタンの操作 ▲問合せNo0345で追加

	//問合せ278で追加　取込区分を手動に変更
    @isTest static void changeManualTest(){

        // テストデータ作成
        List<Building__c> building = new List<Building__c>();
        
        //　建物作成
        building = createBuilding('inintializeTest');
        building[0].ImportType__c = '大和リビング';

        // 建物写真作成
        createBuildingPhoto(building[0].ID, '周辺写真', 'コンビニ');

        //パラメータ設定
        PageReference pageRef = Page.GA104003View;
        pageRef.getParameters().put('Id',building[0].ID );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA104003Controller GA104003Controller = new GA104003Controller();
        GA104003Controller.displayTargetRecord.buildName = '建物';
        GA104003Controller.displayTargetRecord.city = '建物';
        GA104003Controller.displayTargetRecord.street = '建物';
        GA104003Controller.displayTargetRecord.propertyType = 'マンション';
        GA104003Controller.displayTargetRecord.structure = 'PC';
        GA104003Controller.displayTargetRecord.buildingYM = '201212';
        GA104003Controller.displayTargetRecord.groundFloorCount = '1';
        GA104003Controller.displayTargetRecord.undergroundFloorCount = '1';
        GA104003Controller.displayTargetRecord.latitude = 30;
        GA104003Controller.displayTargetRecord.longitude = 131;
        GA104003Controller.displayTargetRecord.choazaCode = '1';
        GA104003Controller.displayTargetRecord.importType = '手動';
        GA104003Controller.saveBuilding();
    }

	//問合せ278で追加　取込区分を手動からリアプロに変更
    @isTest static void changeReaproTest(){

        // テストデータ作成
        List<Building__c> building = new List<Building__c>();
        
        //　建物作成
        building = createBuilding('inintializeTest');
        building[0].ImportType__c = '手動';

        // 建物写真作成
        createBuildingPhoto(building[0].ID, '周辺写真', 'コンビニ');

        //パラメータ設定
        PageReference pageRef = Page.GA104003View;
        pageRef.getParameters().put('Id',building[0].ID );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA104003Controller GA104003Controller = new GA104003Controller();
        GA104003Controller.displayTargetRecord.buildName = '建物';
        GA104003Controller.displayTargetRecord.city = '建物';
        GA104003Controller.displayTargetRecord.street = '建物';
        GA104003Controller.displayTargetRecord.propertyType = 'マンション';
        GA104003Controller.displayTargetRecord.structure = 'PC';
        GA104003Controller.displayTargetRecord.buildingYM = '201212';
        GA104003Controller.displayTargetRecord.groundFloorCount = '1';
        GA104003Controller.displayTargetRecord.undergroundFloorCount = '1';
        GA104003Controller.displayTargetRecord.latitude = 30;
        GA104003Controller.displayTargetRecord.longitude = 131;
        GA104003Controller.displayTargetRecord.choazaCode = '1';
        GA104003Controller.displayTargetRecord.importType = 'リアプロ';
        GA104003Controller.saveBuilding();
    }

	//問合せ278で追加　取込区分を手動から--その他--に変更
    @isTest static void changeNullTest(){

        // テストデータ作成
        List<Building__c> building = new List<Building__c>();
        
        //　建物作成
        building = createBuilding('inintializeTest');
        building[0].ImportType__c = '手動';
        upsert building;

        // 建物写真作成
        createBuildingPhoto(building[0].ID, '周辺写真', 'コンビニ');

        //パラメータ設定
        PageReference pageRef = Page.GA104003View;
        pageRef.getParameters().put('Id',building[0].ID );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA104003Controller GA104003Controller = new GA104003Controller();
        GA104003Controller.displayTargetRecord.buildName = '建物';
        GA104003Controller.displayTargetRecord.city = '建物';
        GA104003Controller.displayTargetRecord.street = '建物';
        GA104003Controller.displayTargetRecord.propertyType = 'マンション';
        GA104003Controller.displayTargetRecord.structure = 'PC';
        GA104003Controller.displayTargetRecord.buildingYM = '201212';
        GA104003Controller.displayTargetRecord.groundFloorCount = '1';
        GA104003Controller.displayTargetRecord.undergroundFloorCount = '1';
        GA104003Controller.displayTargetRecord.latitude = 30;
        GA104003Controller.displayTargetRecord.longitude = 131;
        GA104003Controller.displayTargetRecord.choazaCode = '1';
        GA104003Controller.displayTargetRecord.importType = null;
        GA104003Controller.saveBuilding();
    }

    // 建物コード履歴削除テスト
    @isTest static void delBuildingCdHistTest() {

        // 建物作成
        List<Building__c> building1 = createBuilding('delBuildingCodeHistoryTest1');
        List<Building__c> building2 = createBuilding('delBuildingCodeHistoryTest2');

        // building1に紐づくbuilding2の建物コード履歴を作成
        BuildingCodeHistory__c buildingCdHist = [SELECT Id
                                                        , Building__c
                                                 FROM BuildingCodeHistory__c
                                                 WHERE HistoryBuilding__c = :building2[0].Id];
        
        buildingCdHist.Building__c = building1[0].Id;
        update buildingCdHist;

        // 作成した建物コード履歴を再取得
        buildingCdHist = [SELECT Id
                                 , Building__c
                                 , HistoryBuilding__c
                                 , HistoryMaintenanceBuildingCode__c
                                 , HistoryImportDestination__c
                                 , InformationUpdateDate__c
                                 , SystemModStamp
                          FROM BuildingCodeHistory__c
                          WHERE Id = :buildingCdHist.Id];

        // 初期表示
        PageReference pageRef = Page.GA104003View;
        pageRef.getParameters().put('Id',building1[0].ID );
        Test.setCurrentPage(pageRef);

        // 建物コード履歴の明細を作成
        GA104003Controller testController = new GA104003Controller();
        testController.screenBuildingCdHistList.add(new GA104003Controller.ScreenBuildingCdHist(buildingCdHist));
        testController.screenBuildingCdHistList[0].IsSelected = true;

        // 建物コード履歴の削除
        testController.delBuildingCdHist();

        // 建物コード履歴を再作成
        buildingCdHist = new BuildingCodeHistory__c(
            Building__c                         = building1[0].Id
            , HistoryBuilding__c                = building2[0].Id
            , HistoryMaintenanceBuildingCode__c = CommonConst.STRING_EMPTY
            , HistoryImportDestination__c       = CommonConst.STRING_EMPTY
            , InformationUpdateDate__c          = CommonUtil.getNow()
        );
        insert buildingCdHist;

        // 建物コード履歴の明細を再作成
        testController = new GA104003Controller();
        testController.screenBuildingCdHistList.add(new GA104003Controller.ScreenBuildingCdHist(buildingCdHist));
        testController.screenBuildingCdHistList[0].IsSelected = true;

        // 楽観ロック（削除済み）
        delete new BuildingCodeHistory__c(Id = buildingCdHist.Id);
        testController.delBuildingCdHist();
    }

    // メンテナンス物件コードの存在フラグの設定テスト
    @isTest static void setExistsMaintPropCdFlgTest() {

        // 建物作成
        List<Building__c> building1 = createBuilding('setExistsMaintPropCdFlgTest');
        createProperty(building1[0]);

        // 初期表示
        PageReference pageRef = Page.GA104003View;
        pageRef.getParameters().put('Id',building1[0].ID );
        Test.setCurrentPage(pageRef);

        // メンテナンス物件コードの存在フラグの設定
        GA104003Controller testController = new GA104003Controller();
        testController.setExistsMaintPropCdFlg();
    }

    // カバレッジ向上テスト
    @istest static void coverageUp(){

        GA104003Controller testController = new GA104003Controller();

        // プロパティ
        String propVal;
        propVal = testController.MSG_NO_SELECTED_BUILDING_CD_HIST_ROW;
    }

    // モザイクフラグ初期表示テスト
    @istest static void isUnnecessaryMosaicInitTest(){
        List<Building__c> building1 = createBuilding('isUnnecessaryMosaicInitTest');
        BuildingPhoto__c buildPhoto = new BuildingPhoto__c(
            AppearanceFileName__c = '建物外観'         // 建物外観
            ,AppearanceParseFileName__c = '外観パース'    // 外観パース
            ,EntranceFileName__c = 'エントランス'           // エントランス
            ,LobbyFileName__c = 'ロビー'              // ロビー
            ,ParkingFileName__c  = '駐車場'            // 駐車場
            ,OtherSharingFileName__c = 'その他共有'       // その他共有
            ,MapFileName__c  = '地図'                // 地図
            ,OtherFileName__c = 'その他'              // その他
            ,SurroundingFileName1__c = '周辺写真'     //周辺写真
            ,Building__c = building1[0].id
        );
        insert buildPhoto;

        // 初期表示
        PageReference pageRef = Page.GA104003View;
        pageRef.getParameters().put('Id',building1[0].ID );
        Test.setCurrentPage(pageRef);

        Test.startTest();
        GA104003Controller testController = new GA104003Controller();
        Test.stopTest();

        // モザイク処理不要チェックボックスの値の確認
        System.assertEquals(testController.isUnnecessaryMosaic, true);

        // 建物写真情報（周辺写真以外）リストサイズ確認
        System.assertEquals(testController.anyPhotoData.size(), 8);
        
        // 建物写真情報（周辺写真以外）モザイクフラグ確認
        for(GA104003Controller.ScreenAnyPhotoData param : testController.anyPhotoData) {
            System.assertEquals(param.GD901001Parameter.isMosaic, !testController.isUnnecessaryMosaic);
        }

        // 建物写真情報（周辺写真）モザイクフラグ確認
        System.assertEquals(testController.surroundingPhotoData.GD901001Parameter.isMosaic, !testController.isUnnecessaryMosaic);
    }

    // モザイクフラグ削除テスト
    @istest static void isUnnecessaryMosaicDeleteTest(){
        List<Building__c> building1 = createBuilding('isUnnecessaryMosaicInitTest');

        // 初期表示
        PageReference pageRef = Page.GA104003View;
        pageRef.getParameters().put('Id',building1[0].ID );
        Test.setCurrentPage(pageRef);

        Test.startTest();
        GA104003Controller testController = new GA104003Controller();
        System.assertEquals(testController.isUnnecessaryMosaic, true);
        testController.deletePhotoAll();
        // モザイク不要フラグの値が変わらないこと
        System.assertEquals(testController.isUnnecessaryMosaic, true);

        // 建物写真情報（周辺写真以外）モザイクフラグ確認
        for(GA104003Controller.ScreenAnyPhotoData param : testController.anyPhotoData) {
            System.assertEquals(param.GD901001Parameter.isMosaic, !testController.isUnnecessaryMosaic);
        }

        // 建物写真情報（周辺写真）モザイクフラグ確認
        System.assertEquals(testController.surroundingPhotoData.GD901001Parameter.isMosaic, !testController.isUnnecessaryMosaic);
        
        // モザイク不要フラグをfalseに変更
        testController.isUnnecessaryMosaic = false;
        testController.deletePhotoAll();
        // モザイク不要フラグの値が変わらないこと
        System.assertEquals(testController.isUnnecessaryMosaic, false);

        // 建物写真情報（周辺写真以外）モザイクフラグ確認
        for(GA104003Controller.ScreenAnyPhotoData param : testController.anyPhotoData) {
            System.assertEquals(param.GD901001Parameter.isMosaic, !testController.isUnnecessaryMosaic);
        }

        // 建物写真情報（周辺写真）モザイクフラグ確認
        System.assertEquals(testController.surroundingPhotoData.GD901001Parameter.isMosaic, !testController.isUnnecessaryMosaic);

        Test.stopTest();


    }
    // ▼ 2022.04.13 No.782 問合せNo0782_建物画面の沿線名と駅名の登録について
    //建物新規登録時、沿線のデフォルト値が「--なし--」のこと
     @isTest static void initialTest001(){

        //ユーザ設定
        User thisUser =  [SELECT Id FROM User WHERE UserName = 'GA104003@horaguchi.com'];  

        pageReference pageRef = Page.GA104003View;

        System.runAs(thisUser) {
            Test.startTest();
            Test.setCurrentPage(pageRef);
            // コントローラの初期表示を実行
            GA104003Controller GA104003Controller = new GA104003Controller();
                //★結果確認
                //画面上の沿線のデフォルト値が「--なし--」であることを確認
                system.assertEquals(GA104003Controller.displayTargetRecord.trainRoute1,null);
            Test.stopTest();
        }
    }	

    //既存データの路線および駅名が表示されること
    @isTest static void initialTest002(){

        //ユーザ設定
        User thisUser =  [SELECT Id FROM User WHERE UserName = 'GA104003@horaguchi.com'];  

        //路線、駅セット
        Id trainRoute1 = [SELECT ID FROM TrainRoute__c WHERE NAME = :'テスト路線1' LIMIT 1].Id;
        List<Station__c> stationList1 = [SELECT Id, Name FROM Station__c WHERE NAME = :'テスト駅1' LIMIT 1];
        
        //既存建物レコードセット
        Building__c building = new Building__c();
        building.TrainRoute1__c	 =trainRoute1;
        building.Station1__c =stationList1[0].id;
        building.Name = '既存建物';
        building.City__c = '住所1';
        building.Street__c = '住所2';
        building.PropertyType__c = 'マンション';
        building.Structure__c = 'PC';
        building.BuildingYM__c = '201212';
        building.GroundFloorCount__c = 1;
        building.UndergroundFloorCount__c = 1;
        building.Latitude__c = 30;
        building.Longitude__c = 131;
        building.ChoazaCode__c = '1';
        insert building;
        
        pageReference pageRef = Page.GA104003View;
        pageRef.getParameters().put('id', building.Id);

        System.runAs(thisUser) {
            Test.startTest();
            Test.setCurrentPage(pageRef);
            // コントローラの初期表示を実行
            GA104003Controller GA104003Controller = new GA104003Controller();
                //★結果確認
                //既存データの路線および駅名の初期表示を確認
                system.assertEquals(GA104003Controller.displayTargetRecord.trainRoute1,trainRoute1);
                system.assertEquals(GA104003Controller.displayTargetRecord.station1,stationList1[0].id);
            Test.stopTest();
        }
    }	

    //新規登録する際に、沿線と駅の値が保存されること
    @isTest static void saveTest001(){

        //ユーザ設定
        User thisUser =  [SELECT Id FROM User WHERE UserName = 'GA104003@horaguchi.com'];  
            
        // コントローラの初期表示を実行
        GA104003Controller GA104003Controller = new GA104003Controller();


        //駅、路線セット
        Id trainRoute1 = [SELECT ID FROM TrainRoute__c WHERE NAME = :'テスト路線1' LIMIT 1].Id;
        Id trainRoute2 = [SELECT ID FROM TrainRoute__c WHERE NAME = :'テスト路線2' LIMIT 1].Id;
        Id trainRoute3 = [SELECT ID FROM TrainRoute__c WHERE NAME = :'テスト路線3' LIMIT 1].Id;
        List<Station__c> stationList1 = [SELECT Id, Name FROM Station__c WHERE NAME = :'テスト駅1' LIMIT 1];
        List<Station__c> stationList2 = [SELECT Id, Name FROM Station__c WHERE NAME = :'テスト駅2' LIMIT 1];
        List<Station__c> stationList3 = [SELECT Id, Name FROM Station__c WHERE NAME = :'テスト駅3' LIMIT 1];

        //必須情報入力
        GA104003Controller.displayTargetRecord.buildName = '建物';
        GA104003Controller.displayTargetRecord.city = '建物';
        GA104003Controller.displayTargetRecord.street = '建物';
        GA104003Controller.displayTargetRecord.propertyType = 'マンション';
        GA104003Controller.displayTargetRecord.structure = 'PC';
        GA104003Controller.displayTargetRecord.buildingYM = '201212';
        GA104003Controller.displayTargetRecord.groundFloorCount = '1';
        GA104003Controller.displayTargetRecord.undergroundFloorCount = '1';
        GA104003Controller.displayTargetRecord.latitude = 30;
        GA104003Controller.displayTargetRecord.longitude = 131;
        GA104003Controller.displayTargetRecord.choazaCode = '1';
        GA104003Controller.displayTargetRecord.trainRoute1 =trainRoute1;
        GA104003Controller.displayTargetRecord.stations1 =stationList1;
        GA104003Controller.displayTargetRecord.trainRoute2 =trainRoute2;
        GA104003Controller.displayTargetRecord.stations2 =stationList2;
        GA104003Controller.displayTargetRecord.trainRoute3 =trainRoute3;
        GA104003Controller.displayTargetRecord.stations3 =stationList3;

    
        System.runAs(thisUser) {
            Test.startTest();
                GA104003Controller.openStations1Modal();
                GA104003Controller.closeModal();
                GA104003Controller.openStations2Modal();
                GA104003Controller.closeModal();
                GA104003Controller.openStations3Modal();
                GA104003Controller.closeModal();
                GA104003Controller.saveBuilding();
            Test.stopTest();
            }

        //★結果確認
        //作成された建物の路線と駅を照合
        Building__c af_bd = [SELECT ID,name,TrainRoute1__c,TrainRoute2__c,TrainRoute3__c,Station1__c,Station2__c,Station3__c from Building__c where name ='建物' ];
        system.assertEquals(af_bd.TrainRoute1__c, trainRoute1);
        system.assertEquals(af_bd.TrainRoute2__c, trainRoute2);
        system.assertEquals(af_bd.TrainRoute3__c, trainRoute3);
        system.assertEquals(af_bd.Station1__c, stationList1[0].id);
        system.assertEquals(af_bd.Station2__c, stationList2[0].id);
        system.assertEquals(af_bd.Station3__c, stationList3[0].id);
    }	

    //既存の建物を編集時、沿線と駅の値が保存されること。
    @isTest static void saveTest002(){

        //ユーザ設定
        User thisUser =  [SELECT Id FROM User WHERE UserName = 'GA104003@horaguchi.com'];  

        //路線、駅セット
        Id bftrainRoute1 = [SELECT ID FROM TrainRoute__c WHERE NAME = :'テスト路線1' LIMIT 1].Id;
        Id bftrainRoute2 = [SELECT ID FROM TrainRoute__c WHERE NAME = :'テスト路線2' LIMIT 1].Id;
        Id bftrainRoute3 = [SELECT ID FROM TrainRoute__c WHERE NAME = :'テスト路線3' LIMIT 1].Id;
        Id aftrainRoute1 = [SELECT ID FROM TrainRoute__c WHERE NAME = :'更新確認路線1' LIMIT 1].Id;
        Id aftrainRoute2 = [SELECT ID FROM TrainRoute__c WHERE NAME = :'更新確認路線2' LIMIT 1].Id;
        Id aftrainRoute3 = [SELECT ID FROM TrainRoute__c WHERE NAME = :'更新確認路線3' LIMIT 1].Id;
        List<Station__c> bfstationList1 = [SELECT Id, Name FROM Station__c WHERE NAME = :'テスト駅1' LIMIT 1];
        List<Station__c> bfstationList2 = [SELECT Id, Name FROM Station__c WHERE NAME = :'テスト駅2' LIMIT 1];
        List<Station__c> bfstationList3 = [SELECT Id, Name FROM Station__c WHERE NAME = :'テスト駅3' LIMIT 1];
        List<Station__c> afstationList1 = [SELECT Id, Name FROM Station__c WHERE NAME = :'更新確認駅1' LIMIT 1];
        List<Station__c> afstationList2 = [SELECT Id, Name FROM Station__c WHERE NAME = :'更新確認駅2' LIMIT 1];
        List<Station__c> afstationList3 = [SELECT Id, Name FROM Station__c WHERE NAME = :'更新確認駅3' LIMIT 1];

        //既存建物レコードセット
        Building__c building = new Building__c();
        building.TrainRoute1__c	 =bftrainRoute1;
        building.TrainRoute2__c	 =bftrainRoute2;
        building.TrainRoute3__c	 =bftrainRoute3;
        building.Station1__c =bfstationList1[0].id;
        building.Station2__c =bfstationList2[0].id;
        building.Station3__c =bfstationList3[0].id;
        building.Name = '既存建物';
        building.City__c = '住所1';
        building.Street__c = '住所2';
        building.PropertyType__c = 'マンション';
        building.Structure__c = 'PC';
        building.BuildingYM__c = '201212';
        building.GroundFloorCount__c = 1;
        building.UndergroundFloorCount__c = 1;
        building.Latitude__c = 30;
        building.Longitude__c = 131;
        building.ChoazaCode__c = '1';
        insert building;

        pageReference pageRef = Page.GA104003View;
        pageRef.getParameters().put('id', building.Id);
        Test.setCurrentPage(pageRef);
    
        // コントローラの初期表示を実行
        GA104003Controller GA104003Controller = new GA104003Controller();

        //路線、駅を変更
        GA104003Controller.displayTargetRecord.trainRoute1 =aftrainRoute1;
        GA104003Controller.displayTargetRecord.trainRoute2 =aftrainRoute2;
        GA104003Controller.displayTargetRecord.trainRoute3 =aftrainRoute3;
        GA104003Controller.displayTargetRecord.stations1 =afstationList1;
        GA104003Controller.displayTargetRecord.stations2 =afstationList2;
        GA104003Controller.displayTargetRecord.stations3 =afstationList3;

        
        System.runAs(thisUser) {
            Test.startTest();
                GA104003Controller.openStations1Modal();
                GA104003Controller.closeModal();
                GA104003Controller.openStations2Modal();
                GA104003Controller.closeModal();
                GA104003Controller.openStations3Modal();
                GA104003Controller.closeModal();
                GA104003Controller.saveBuilding();
            Test.stopTest();
            }

        //★結果確認
        //変更後の建物レコードの路線と駅を照合
        Building__c af_bd = [SELECT ID,name,TrainRoute1__c,Station1__c,TrainRoute2__c,Station2__c,TrainRoute3__c,Station3__c from Building__c where name ='既存建物' ];
        system.assertEquals(af_bd.TrainRoute1__c, aftrainRoute1);
        system.assertEquals(af_bd.Station1__c, afstationList1[0].id);
        system.assertEquals(af_bd.TrainRoute2__c, aftrainRoute2);
        system.assertEquals(af_bd.Station2__c, afstationList2[0].id);
        system.assertEquals(af_bd.TrainRoute3__c, aftrainRoute3);
        system.assertEquals(af_bd.Station3__c, afstationList3[0].id);
    }	

    //駅名重複した状態で保存ボタンを押下された場合、エラーメッセージが表示される。
    @isTest static void saveTest003(){

        //ユーザ設定
        User thisUser =  [SELECT Id FROM User WHERE UserName = 'GA104003@horaguchi.com'];  
            
        // コントローラの初期表示を実行
        GA104003Controller GA104003Controller = new GA104003Controller();

        Id trainRoute = [SELECT ID FROM TrainRoute__c WHERE NAME = :'テスト路線1' LIMIT 1].Id;
        List<Station__c> stationList = [SELECT Id, Name FROM Station__c WHERE NAME = :'テスト駅1' LIMIT 1];

        //必須情報入力
        GA104003Controller.displayTargetRecord.buildName = '建物';
        GA104003Controller.displayTargetRecord.city = '建物';
        GA104003Controller.displayTargetRecord.street = '建物';
        GA104003Controller.displayTargetRecord.propertyType = 'マンション';
        GA104003Controller.displayTargetRecord.structure = 'PC';
        GA104003Controller.displayTargetRecord.buildingYM = '201212';
        GA104003Controller.displayTargetRecord.groundFloorCount = '1';
        GA104003Controller.displayTargetRecord.undergroundFloorCount = '1';
        GA104003Controller.displayTargetRecord.latitude = 30;
        GA104003Controller.displayTargetRecord.longitude = 131;
        GA104003Controller.displayTargetRecord.choazaCode = '1';

        //駅1と駅2を同じものを選択
        GA104003Controller.displayTargetRecord.trainRoute1 =trainRoute;
        GA104003Controller.displayTargetRecord.trainRoute2 =trainRoute;
        GA104003Controller.displayTargetRecord.stations1 =stationList;
        GA104003Controller.displayTargetRecord.stations2 =stationList;
    
        System.runAs(thisUser) {
            Test.startTest();
                GA104003Controller.openStations1Modal();
                GA104003Controller.closeModal();
                GA104003Controller.openStations2Modal();
                GA104003Controller.closeModal();
                GA104003Controller.saveBuilding();
                //★結果確認
                //エラーメッセージを取得
                List<ApexPages.Message> messages = ApexPages.getMessages();
                //エラーメッセージの内容を照合
                system.assertEquals(true,messages[0].getDetail().equals('同一の駅が選択されたため、保存できません。'));
            Test.stopTest();
            }
    }

    //路線が変更された場合、駅名がクリアされること
    @isTest static void changeTrainRoutetest(){
        //ユーザ設定
        User thisUser =  [SELECT Id FROM User WHERE UserName = 'GA104003@horaguchi.com'];  

        //路線、駅セット
        Id trainRoute1 = [SELECT ID FROM TrainRoute__c WHERE NAME = :'テスト路線1' LIMIT 1].Id;
        List<Station__c> stationList1 = [SELECT Id, Name FROM Station__c WHERE NAME = :'テスト駅1' LIMIT 1];

        //既存建物レコードセット
        Building__c building = new Building__c();
        building.TrainRoute1__c	 =trainRoute1;
        building.Station1__c =stationList1[0].id;
        building.Name = '既存建物';
        building.City__c = '住所1';
        building.Street__c = '住所2';
        building.PropertyType__c = 'マンション';
        building.Structure__c = 'PC';
        building.BuildingYM__c = '201212';
        building.GroundFloorCount__c = 1;
        building.UndergroundFloorCount__c = 1;
        building.Latitude__c = 30;
        building.Longitude__c = 131;
        building.ChoazaCode__c = '1';
        insert building;

        pageReference pageRef = Page.GA104003View;
        pageRef.getParameters().put('id', building.Id);
        Test.setCurrentPage(pageRef);
   
        // コントローラの初期表示を実行
        GA104003Controller GA104003Controller = new GA104003Controller();

        System.runAs(thisUser) {
            Test.startTest();
                //路線1変更前の駅名照合
                system.assertEquals(GA104003Controller.displayTargetRecord.station1Name,stationList1[0].Name);
                GA104003Controller.changeTrainRoute1();
                //★結果確認
                //路線1変更後、駅名がクリアされたことを確認
                system.assertEquals(GA104003Controller.displayTargetRecord.station1Name,null);
                Test.stopTest();
            }
    }	
    // ▲ 2022.04.13 No.782 問合せNo0782_建物画面の沿線名と駅名の登録について

    // ▼ 2022.04.26 No0806 建物登録の「同一の駅が選択されたため、保存できません。」のエラーについて
    //路線が異なる、同一の名称の駅を登録した状態で保存ボタンを押下された場合、正常に保存される。
    @isTest static void stationCheckTest(){

        //ユーザ設定
        User thisUser =  [SELECT Id FROM User WHERE UserName = 'GA104003@horaguchi.com'];  
    
        //路線、駅セット
        Id trainRoute1 = [SELECT ID FROM TrainRoute__c WHERE NAME = :'テスト路線1' LIMIT 1].Id;
        Id trainRoute2 = [SELECT ID FROM TrainRoute__c WHERE NAME = :'テスト路線2' LIMIT 1].Id;
        List<Station__c> stationList1 = [SELECT Id, Name, Remarks__c FROM Station__c WHERE NAME = :'テスト駅_重複名称' AND Remarks__c = '0806用1'];
        List<Station__c> stationList2 = [SELECT Id, Name, Remarks__c FROM Station__c WHERE NAME = :'テスト駅_重複名称' AND Remarks__c = '0806用2'];

        //既存建物レコードセット
        Building__c building = new Building__c();
        building.TrainRoute1__c	 =trainRoute1;
        building.TrainRoute2__c	 =trainRoute2;
        building.Station1__c =stationList1[0].id;
        building.Station2__c =stationList2[0].id;
        building.Name = '既存建物';
        building.City__c = '住所1';
        building.Street__c = '住所2';
        building.PropertyType__c = 'マンション';
        building.Structure__c = 'PC';
        building.BuildingYM__c = '201212';
        building.GroundFloorCount__c = 1;
        building.UndergroundFloorCount__c = 1;
        building.Latitude__c = 30;
        building.Longitude__c = 131;
        building.ChoazaCode__c = '1';
        insert building;
    
        pageReference pageRef = Page.GA104003View;
        pageRef.getParameters().put('id', building.Id);
        Test.setCurrentPage(pageRef);
        
        // コントローラの初期表示を実行
        GA104003Controller GA104003Controller = new GA104003Controller();

            System.runAs(thisUser) {
                Test.startTest();
                    GA104003Controller.openStations1Modal();
                    GA104003Controller.closeModal();
                    GA104003Controller.openStations2Modal();
                    GA104003Controller.closeModal();
                    GA104003Controller.saveBuilding();
                Test.stopTest();
                }
    
            //★結果確認
            Building__c bd = [SELECT ID,name,TrainRoute1__c,Station1__c,Station1__r.name,TrainRoute2__c,Station2__c,Station2__r.name,TrainRoute3__c,Station3__c from Building__c where name ='既存建物' ];
            //駅1と駅2の名前が同一であることを確認
            system.assertEquals(bd.Station1__r.name, bd.Station2__r.name);
            //駅1と駅2が保存されていることを確認
            system.assertEquals(bd.Station1__c, stationList1[0].id);
            system.assertEquals(bd.Station2__c, stationList2[0].id);
    }	

    //同一の路線かつ同一の名称の駅を登録した状態で保存ボタンを押下された場合、エラーが発生する。
    @isTest static void stationErrorCheckTest(){

        //ユーザ設定
        User thisUser =  [SELECT Id FROM User WHERE UserName = 'GA104003@horaguchi.com'];  
        
        // コントローラの初期表示を実行
        GA104003Controller GA104003Controller = new GA104003Controller();
    
        Id trainRoute = [SELECT ID FROM TrainRoute__c WHERE NAME = :'テスト路線1' LIMIT 1].Id;
        List<Station__c> stationList = [SELECT Id, Name FROM Station__c WHERE NAME = :'テスト駅1' LIMIT 1];
    
        //必須情報入力
        GA104003Controller.displayTargetRecord.buildName = '建物';
        GA104003Controller.displayTargetRecord.city = '建物';
        GA104003Controller.displayTargetRecord.street = '建物';
        GA104003Controller.displayTargetRecord.propertyType = 'マンション';
        GA104003Controller.displayTargetRecord.structure = 'PC';
        GA104003Controller.displayTargetRecord.buildingYM = '201212';
        GA104003Controller.displayTargetRecord.groundFloorCount = '1';
        GA104003Controller.displayTargetRecord.undergroundFloorCount = '1';
        GA104003Controller.displayTargetRecord.latitude = 30;
        GA104003Controller.displayTargetRecord.longitude = 131;
        GA104003Controller.displayTargetRecord.choazaCode = '1';
    
        //駅1と駅2を同じものを選択
        GA104003Controller.displayTargetRecord.trainRoute1 =trainRoute;
        GA104003Controller.displayTargetRecord.trainRoute2 =trainRoute;
        GA104003Controller.displayTargetRecord.stations1 =stationList;
        GA104003Controller.displayTargetRecord.stations2 =stationList;
        
        System.runAs(thisUser) {
            Test.startTest();
                GA104003Controller.openStations1Modal();
                GA104003Controller.closeModal();
                GA104003Controller.openStations2Modal();
                GA104003Controller.closeModal();
                GA104003Controller.saveBuilding();
                //★結果確認
                //駅1と駅2のIDが同一であること
                system.assertEquals(GA104003Controller.displayTargetRecord.stations1,GA104003Controller.displayTargetRecord.stations2);
                //エラーメッセージを取得
                List<ApexPages.Message> messages = ApexPages.getMessages();
                //エラーメッセージの内容を照合
                system.assertEquals(true,messages[0].getDetail().equals('同一の駅が選択されたため、保存できません。'));
            Test.stopTest();
            }
        }
    // ▲ 2022.04.26 No0806 建物登録の「同一の駅が選択されたため、保存できません。」のエラーについて
    

}