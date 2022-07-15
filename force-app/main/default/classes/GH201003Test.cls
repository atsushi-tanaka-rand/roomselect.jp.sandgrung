/**
 * 店舗・地区選択のテストクラス
 */
@isTest 
private class GH201003Test {

    static GH201003Controller GH201003Controller = new GH201003Controller();
    static GH201003ParameterClass GH201003Parameter = new GH201003ParameterClass();
    
    // 店舗テストデータ2件作成
    static void createShop2(string test0001Name, string test0002Name) {

        //店舗作成
        List<Shop__c> shopObj = new List<Shop__c>();

        //取得対象の店舗を2つ作成
        shopObj.add(new Shop__c(Name = test0001Name
                               ,SystemUseStartDate__c = date.today()
                               ,SystemUseEndDate__c =  date.today()));

        shopObj.add(new Shop__c(Name = test0002Name
                               ,SystemUseStartDate__c = date.today()
                               ,SystemUseEndDate__c =  date.today()));

        insert shopObj;
    }	

	//初期表示テスト(店舗)
     @isTest static void initializeShopTest(){

        //店舗作成
        string test0001Name = 'test0001';
        string test0002Name = 'test0002';
         createShop2(test0001Name, test0002Name);
        
        // ページ遷移時の設定
        GH201003Parameter.isDrawing = TRUE;
        GH201003Parameter.noFirst = TRUE;

        // 店舗モードの設定
        GH201003Parameter.isShopMode= TRUE;

        // 選択済み店舗を設定
        GH201003Parameter.selectedShopOrDistrictList.add(test0002Name);

        // コントローラの共通クラスを設定
        GH201003Controller.Parameter = GH201003Parameter;

        // コントローラの初期表示を実行
        GH201003Controller.getSelectOption();

        //「選択可能リスト」に「test0001Name」の店舗が設定されている
        system.assertEquals(test0001Name, GH201003Controller.chooseableOptions[0].getLabel());

        //「選択済みリスト」に「test0002Name」の店舗が設定されている
        system.assertEquals(test0002Name, GH201003Controller.selectedOptions[0].getLabel());
        
    }	
		
	//初期表示テスト(地区)
     @isTest static void initializeDistrictTest(){
        
        // ページ遷移時の設定
        GH201003Parameter.isDrawing = TRUE;
        GH201003Parameter.noFirst = TRUE;
        GH201003Parameter.regionSelectionFlg = true;

        // 地区モードの設定
        GH201003Parameter.isShopMode= FALSE;

        // 選択済み地区を設定
        string test0001Name = '港区';
        GH201003Parameter.selectedShopOrDistrictList.add(test0001Name);

        // コントローラの共通クラスを設定
        GH201003Controller.Parameter = GH201003Parameter;

        // コントローラの初期表示を実行
        GH201003Controller.getSelectOption();

        //「選択済みリスト」に「test0001Name」の地区が設定されている
        //system.assertEquals(test0001Name, GH201003Controller.selectedOptions[0].getLabel());

        //「選択可能リスト」に「test0001Name」の地区が設定されていない
        for(SelectOption inSelect : GH201003Controller.chooseableOptions){
            //system.assertNotEquals(test0001Name, inSelect.getLabel());
        }
    }	
		
	//初期表示テスト(店舗):無効な選択済み店舗あり
     @isTest static void initializeInvalidShopTest(){

        //店舗作成
        string test0001Name = 'test0001';
        string test0002Name = 'test0002';
        string test0003Name = 'hogehoge';

        createShop2(test0001Name, test0002Name);
        
        // ページ遷移時の設定
        GH201003Parameter.isDrawing = TRUE;
        GH201003Parameter.noFirst = TRUE;

        // 店舗モードの設定
        GH201003Parameter.isShopMode = TRUE;

        // 選択済み店舗を設定
        GH201003Parameter.selectedShopOrDistrictList.add(test0002Name);
        GH201003Parameter.selectedShopOrDistrictList.add(test0003Name);

        // コントローラの共通クラスを設定
        GH201003Controller.Parameter = GH201003Parameter;

        // コントローラの初期表示を実行
        GH201003Controller.getSelectOption();

        //「選択済みリスト」に「test0002Name」の店舗が設定されている
        system.assertEquals(test0002Name, GH201003Controller.selectedOptions[0].getLabel());

        //「選択済みリスト」に「test0003Name」の店舗が設定されていない
        system.assertNotEquals(test0003Name, GH201003Controller.selectedOptions[0].getLabel());
        
    }	
		
	//初期表示テスト(地区):無効な選択済み地区あり
     @isTest static void initializeInvalidDistrictTest(){
        
        // ページ遷移時の設定
        GH201003Parameter.isDrawing = TRUE;
        GH201003Parameter.noFirst = TRUE;

        // 地区モードの設定
        GH201003Parameter.isShopMode = FALSE;

        // 選択済み地区を設定
        string test0001Name = 'hoehoge';
        GH201003Parameter.selectedShopOrDistrictList.add(test0001Name);

        // コントローラの共通クラスを設定
        GH201003Controller.Parameter = GH201003Parameter;

        // コントローラの初期表示を実行
        GH201003Controller.getSelectOption();

        //「選択済みリスト」に「test0001Name」の地区が設定されていない
        system.assertEquals(GH201003Controller.selectedOptions.size(), 0);

        //「選択可能リスト」に「test0001Name」の地区が設定されていない
        for(SelectOption inSelect : GH201003Controller.selectedOptions){
            system.assertNotEquals(test0001Name, inSelect.getLabel());
        }
    }	
		
	//選択可能リストの移動
     @isTest static void setSelectTest(){
        
        // ページ遷移時の設定
        GH201003Parameter.isDrawing = TRUE;
        GH201003Parameter.noFirst = TRUE;

        // 地区モードの設定
        GH201003Parameter.isShopMode= FALSE;

        // コントローラの共通クラスを設定
        GH201003Controller.Parameter = GH201003Parameter;

        Boolean isInit = GH201003Controller.init;

        GH201003Controller.chooseableSelection.add('港区');

        // コントローラの選択可能リストの移動を実行
        //GH201003Controller.setSelect();
    }	
		
	//選択可能リストの移動
     @isTest static void removeSelectTest(){
        
        // ページ遷移時の設定
        GH201003Parameter.isDrawing = TRUE;
        GH201003Parameter.noFirst = TRUE;

        // 地区モードの設定
        GH201003Parameter.isShopMode= FALSE;

        // コントローラの共通クラスを設定
        GH201003Controller.Parameter = GH201003Parameter;

        Boolean isInit = GH201003Controller.init;

        GH201003Controller.chooseableSelection.add('港区');

        // コントローラの選択可能リストの移動を実行
        //GH201003Controller.setSelect();
        
        //GH201003Controller.selectedSelection.add('港区');

        // コントローラの選択済みリストの移動を実行
        //GH201003Controller.removeSelect();
    }

    //  設定処理
     @isTest static void settingSelectTest(){

        //店舗作成
        string test0001Name = 'test0001';
        string test0002Name = 'test0002';
        
        createShop2(test0001Name, test0002Name);
        
        // ページ遷移時の設定
        GH201003Parameter.isDrawing = TRUE;
        GH201003Parameter.noFirst = TRUE;

        // 店舗モードの設定
        GH201003Parameter.isShopMode= TRUE;

        // 選択済み店舗を設定
        GH201003Parameter.selectedShopOrDistrictList.add(test0002Name);

        // コントローラの共通クラスを設定
        GH201003Controller.Parameter = GH201003Parameter;

        // コントローラの初期表示を実行
        GH201003Controller.getSelectOption();

        // コントローラの設定を実行
        GH201003Controller.settingSelect();
        
    }	

    //  パラメータエラーテスト
     @isTest static void parameterErrorTest(){
        
        // ページ遷移時の設定
        GH201003Parameter.isDrawing = TRUE;
        GH201003Parameter.noFirst = TRUE;

        // モードの設定
        GH201003Parameter.isShopMode= null;

        // コントローラの共通クラスを設定
        GH201003Controller.Parameter = GH201003Parameter;

        // コントローラの初期表示を実行
        GH201003Controller.getSelectOption();
        
        //「エラーフラグ」がTRUEに設定されている
        system.assertEquals(GH201003Controller.isOpenError, TRUE);

        //「エラーメッセージ」が正しく設定されている
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonConst.MSG_COM_E_SYSTEM_PARAMETER);
        
    }	
}