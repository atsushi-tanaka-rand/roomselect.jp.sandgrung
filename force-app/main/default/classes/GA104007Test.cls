/**
 * 駅名選択のテストクラス
 */
@isTest 
private class GA104007Test {

    static GA104007Controller GA104007Controller = new GA104007Controller();
    static GA104007ParameterClass GA104007Parameter = new GA104007ParameterClass();
    
    // 路線テストデータ1件作成
    static List<TrainRoute__c> createTrainRoute(string test0001Name) {

        //駅作成
        List<TrainRoute__c> TrainRouteObj = new List<TrainRoute__c>();

        //路線を1つ作成
        TrainRouteObj.add(new TrainRoute__c(Name = test0001Name));

        insert TrainRouteObj;

        TrainRouteObj = [SELECT ID, NAME  FROM TrainRoute__c WHERE NAME = :test0001Name];

        return TrainRouteObj;
    }	
    
    // 駅テストデータ1件作成
    static List<Station__c> createStation(string test0001Name, Decimal Order, string TrainRouteId) {

        //駅作成
        List<Station__c> StationObj = new List<Station__c>();

        //駅を1つ作成
        StationObj.add(new Station__c(Name = test0001Name
                               ,Order__c = Order
                               ,TrainRoute__c =  TrainRouteId));
        insert StationObj;

        StationObj = [SELECT ID, NAME, Order__c, TrainRoute__c FROM Station__c WHERE NAME = :test0001Name];

        return StationObj;

    }	

	//初期表示テスト
     @isTest static void initializeTest(){

        //　選択済み路線、駅を作成
        string testTrainRoute0001Name = 'testTrainRoute0001';
        string testTrainRoute0002Name = 'testTrainRoute0002';
        string test0001Name = 'test0001';
        string test0002Name = 'test0002';

        List<TrainRoute__c> inTrainRouteList1 = createTrainRoute(testTrainRoute0001Name);

        List<Station__c> inStationList = new List<Station__c>();

        inStationList.add(createStation(test0001Name, 1 , inTrainRouteList1[0].ID)[0]);

        inStationList.add(createStation(test0002Name, 2 , inTrainRouteList1[0].ID)[0]);
        

        // ページ遷移時の設定
        GA104007Parameter.isDrawing = TRUE;
        GA104007Parameter.noFirst = TRUE;

        // 選択済み路線、駅を設定
        GA104007Parameter.selectedTrainRoute = inTrainRouteList1[0];
        GA104007Parameter.selectedStation = inStationList;

        // コントローラの共通クラスを設定
        GA104007Controller.Parameter = GA104007Parameter;

        // コントローラの初期表示を実行
        Boolean isInit = GA104007Controller.init;

        Integer i = 0;
        for(GA104007Controller.DisplayStation inDisplayStation : GA104007Controller.DisplayStationList){
            system.assertEquals( inStationList[i].ID, inDisplayStation.station.ID);// 項目「順序」の昇順で並んでいるか
            system.assertEquals( inDisplayStation.isSelected, TRUE);// チェック済みか
            i++;
        } 
    }	

	//初期表示(パラメータの駅がオブジェクト上に存在しない場合)
     @isTest static void initializeInvalidStationTest(){

        //　選択済み路線、駅を作成
        string testTrainRoute0001Name = 'testTrainRoute0001';
        string testTrainRoute0002Name = 'testTrainRoute0002';
        string test0001Name = 'test0001';
        string test0002Name = 'test0002';

        List<TrainRoute__c> inTrainRouteList1 = createTrainRoute(testTrainRoute0001Name);
        List<TrainRoute__c> inTrainRouteList2 = createTrainRoute(testTrainRoute0002Name);

        List<Station__c> inStationList = new List<Station__c>();

        inStationList.add(createStation(test0001Name, 1 , inTrainRouteList1[0].ID)[0]);

        inStationList.add(createStation(test0002Name, 2 , inTrainRouteList2[0].ID)[0]);
        

        // ページ遷移時の設定
        GA104007Parameter.isDrawing = TRUE;
        GA104007Parameter.noFirst = TRUE;

        // 選択済み路線を設定
        GA104007Parameter.selectedTrainRoute = inTrainRouteList1[0];

        // コントローラの共通クラスを設定
        GA104007Controller.Parameter = GA104007Parameter;

        // コントローラの初期表示を実行
        GA104007Controller.getStation();

        system.assertEquals( GA104007Controller.DisplayStationList.size(), 1);// 選択した路線に関連した駅だけか
        system.assertEquals( GA104007Controller.DisplayStationList[0].station.ID, inStationList[0].ID);// 選択した路線に関連した駅かどうか
        system.assertNotEquals( GA104007Controller.DisplayStationList[0].station.ID, inStationList[1].ID);// 選択ていない路線に関連した駅かどうか

    }	

	//初期表示(パラメータの路線がオブジェクト上に存在しない場合)
     @isTest static void initializeInvalidTrainRouteTest(){

        string testTrainRoute0001Name = 'testTrainRoute0001';
 
        // ページ遷移時の設定
        GA104007Parameter.isDrawing = TRUE;
        GA104007Parameter.noFirst = TRUE;

        // 選択済み路線を設定
        GA104007Parameter.selectedTrainRoute = new TrainRoute__c(Name = testTrainRoute0001Name);

        // コントローラの共通クラスを設定
        GA104007Controller.Parameter = GA104007Parameter;

        // コントローラの初期表示を実行
        GA104007Controller.getStation();

        system.assertEquals( GA104007Controller.DisplayStationList.size(), 0);// 駅が表示されていないかどうか
        system.assertEquals( GA104007Controller.Parameter.selectedTrainRoute.NAME, testTrainRoute0001Name);// 選択した路線の名前かどうか
    }	



	//設定(共通)
     @isTest static void settingSelectTest(){

        //　選択済み路線、駅を作成
        string testTrainRoute0001Name = 'testTrainRoute0001';
        string test0001Name = 'test0001';
        string test0002Name = 'test0002';

        List<TrainRoute__c> inTrainRouteList1 = createTrainRoute(testTrainRoute0001Name);

        List<Station__c> inStationList = new List<Station__c>();

        inStationList.add(createStation(test0001Name, 1 , inTrainRouteList1[0].ID)[0]);

        inStationList.add(createStation(test0002Name, 2 , inTrainRouteList1[0].ID)[0]);
        

        // ページ遷移時の設定
        GA104007Parameter.isDrawing = TRUE;
        GA104007Parameter.noFirst = TRUE;

        // 選択済み路線、駅を設定
        GA104007Parameter.selectedTrainRoute = inTrainRouteList1[0];
        GA104007Parameter.selectedStation = inStationList;

        // コントローラの共通クラスを設定
        GA104007Controller.Parameter = GA104007Parameter;

        // コントローラの初期表示を実行
        GA104007Controller.getStation();

        GA104007Controller.settingSelect();
    }	

	//エラー発生時：初期表示(異常系)
     @isTest static void parameterErrorTest(){

        // ページ遷移時の設定
        GA104007Parameter.isDrawing = TRUE;
        GA104007Parameter.noFirst = TRUE;

        // コントローラの共通クラスを設定
        GA104007Controller.Parameter = GA104007Parameter;

        // コントローラの初期表示を実行
        GA104007Controller.getStation();
                
        //「エラーフラグ」がTRUEに設定されている
        system.assertEquals(GA104007Controller.isOpenError, TRUE);

        //「エラーメッセージ」が正しく設定されている
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonConst.MSG_COM_E_SYSTEM_PARAMETER);
        
    }	

	//エラー発生時：設定(異常系)
     @isTest static void notSelectErrorTest(){

        //路線作成
        string testTrainRoute0001Name = 'testTrainRoute0001';
        string test0001Name = 'test0001';
        string test0002Name = 'test0002';

        List<TrainRoute__c> inTrainRouteList1 = createTrainRoute(testTrainRoute0001Name);

        //駅作成
        List<Station__c> inStationList = new List<Station__c>();

        inStationList.add(createStation(test0001Name, 1 , inTrainRouteList1[0].ID)[0]);

        inStationList.add(createStation(test0002Name, 2 , inTrainRouteList1[0].ID)[0]);
        

        // ページ遷移時の設定
        GA104007Parameter.isDrawing = TRUE;
        GA104007Parameter.noFirst = TRUE;

        // 選択済み路線を設定
        GA104007Parameter.selectedTrainRoute = inTrainRouteList1[0];

        // コントローラの共通クラスを設定
        GA104007Controller.Parameter = GA104007Parameter;

        // コントローラの初期表示を実行
        GA104007Controller.getStation();

        GA104007Controller.settingSelect();

        //「エラーメッセージ保有フラグ」がTRUEに設定されている
        system.assertEquals(GA104007Controller.hasErrorMessage, TRUE);

        //「エラーメッセージ」が正しく設定されている
        List<Object> parameters = new List<Object> {'駅の選択', '1'};

        system.assertEquals(ApexPages.getMessages()[0].getDetail(), String.format(CommonConst.MSG_COM_W_SELECTION_OR_MORE, parameters));
        
    }	
    // ▼ 2022.04.13 No.782 問合せNo0782_建物画面の沿線名と駅名の登録について
    //エラー発生時：設定(異常系)(GA104003用)
    @isTest static void multiSelectionTest(){

        //路線作成
        string testTrainRoute0001Name = 'testTrainRoute0001';
        string test0001Name = 'test0001';
        string test0002Name = 'test0002';

        List<TrainRoute__c> inTrainRouteList1 = createTrainRoute(testTrainRoute0001Name);

        //駅作成
        List<Station__c> inStationList = new List<Station__c>();
        inStationList.add(createStation(test0001Name, 1 , inTrainRouteList1[0].ID)[0]);
        inStationList.add(createStation(test0002Name, 2 , inTrainRouteList1[0].ID)[0]);
        
        // ページ遷移時の設定
        GA104007Parameter.isDrawing = TRUE;
        GA104007Parameter.noFirst = TRUE;
        GA104007Parameter.singleChoice =TRUE; //GA104003フラグ

        // 選択済み路線、駅を設定
        GA104007Parameter.selectedTrainRoute = inTrainRouteList1[0];
        GA104007Parameter.selectedStation = inStationList;

        // コントローラの共通クラスを設定
        GA104007Controller.Parameter = GA104007Parameter;

        // コントローラの初期表示を実行
        GA104007Controller.getStation();
        GA104007Controller.settingSelect();

        //「エラーメッセージ保有フラグ」がTRUEに設定されている
        system.assertEquals(GA104007Controller.hasErrorMessage, TRUE);

        //「エラーメッセージ」が正しく設定されている
        List<Object> parameters = new List<Object> {'駅の選択', '1'};
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), String.format(CommonConst.MSG_COM_W_SELECTION_OR_LESS, parameters));
        
    }	
    // ▲ 2022.04.13 No.782 問合せNo0782_建物画面の沿線名と駅名の登録について

}