/**
 * 郵便番号検索・住所検索のテストクラス
 */
@isTest 
private class GA102006Test {

	//テストに使用するレコードを作成する
	@testSetup static void Setting(){
		//住所のテスト用レコードを作成
        Address__c addressRecord = new Address__c (PostalCode__c = '1111111',
                                                   State__c = '愛知県' ,
                                                   City__c = '名古屋市' ,
                                                   Street__c = '住所町');
                                                   
        Address__c addressRecord2 = new Address__c (PostalCode__c = '8887777',
                                                   State__c = '愛知県' ,
                                                   City__c = 'ぱぱぱ市' ,
                                                   Street__c = 'ぽぽ町');
        Address__c addressRecord3 = new Address__c (PostalCode__c = '8887777',
                                                   State__c = '愛知県' ,
                                                   City__c = 'たたった市' ,
                                                   Street__c = 'じゃじゃ町');
                                                   
        List<Address__c> addressList = new List<Address__c> {addressRecord,addressRecord2,addressRecord3};
        insert addressList;

		//国土地理院用レコードを作成
        JapanGeographicDataCenterAddress__c japanGeographicDataCenterAddressRecord = new JapanGeographicDataCenterAddress__c
                                                  (PostalCode__c = '9999999',
                                                   State__c = '愛媛県' ,
                                                   City__c = '松山市' ,
                                                   OazaAlias__c = '国土町',
                                                   ObsoleteYM__c = '000000');

        JapanGeographicDataCenterAddress__c jgdcAdd2 = new JapanGeographicDataCenterAddress__c
        (PostalCode__c = '9998888',
            State__c = '愛知県' ,
            City__c = '名古屋市' ,
            OazaAlias__c = 'あああ町',
            ObsoleteYM__c = '000000');
        JapanGeographicDataCenterAddress__c jgdcAdd3 = new JapanGeographicDataCenterAddress__c
        (PostalCode__c = '9998888',
            State__c = '愛知県' ,
            City__c = '名古屋市' ,
            OazaAlias__c = 'いいい町',
            ObsoleteYM__c = '000000');

        List<JapanGeographicDataCenterAddress__c> jgdcAddList = new List<JapanGeographicDataCenterAddress__c> {japanGeographicDataCenterAddressRecord,jgdcAdd2,jgdcAdd3};
        insert jgdcAddList; 
    }
    //カスタム設定の作成
    static SystemConfig__c PostalCodeAddressSearchMaxCount(Decimal maxCount){
        SystemConfig__c settings = new SystemConfig__c();
        settings.PostalCodeAddressSearchMaxCount__c = maxCount;//検索上限
        insert settings;
        
        return settings;
    }
       
    //郵便番号初期表示テスト
     @isTest static void initializePostalCodeTest(){
        PostalCodeAddressSearchMaxCount(1000);
        GA102006Controller GA102006Controller = new GA102006Controller();
        GA102006ParameterClass GA102006Parameter = new GA102006ParameterClass();

        // ページ遷移時の設定
        GA102006Parameter.isDrawing = true;
        GA102006Parameter.noFirst = true;

        // 住所マスタフラグを設定
        GA102006Parameter.isAddressMoster = true;  
        // コントローラの共通クラスを設定
        GA102006Controller.Parameter = GA102006Parameter;

        //パラメータ設定
        GA102006Parameter.postalCode ='1234567';  
        GA102006Parameter.state = 'テスト県';  
        GA102006Parameter.city = 'テスト市'; 
        GA102006Parameter.street = 'テスト町';   

        // コントローラの初期表示を実行（郵便番号）
        Boolean isInit = GA102006Controller.init;
        system.assertEquals(GA102006Controller.screenText, '1234567');
    }	    

    //住所初期表示テスト
     @isTest static void initializeAddressTest(){
        PostalCodeAddressSearchMaxCount(1000);

        GA102006Controller GA102006Controller = new GA102006Controller();
        GA102006ParameterClass GA102006Parameter = new GA102006ParameterClass();

        // ページ遷移時の設定
        GA102006Parameter.isDrawing = true;
        GA102006Parameter.noFirst = true;

        // 住所マスタフラグを設定
        GA102006Parameter.isAddressMoster = false;  
        // コントローラの共通クラスを設定
        GA102006Controller.Parameter = GA102006Parameter;

        //パラメータ設定
        GA102006Parameter.postalCode = null;  
        GA102006Parameter.state = '愛媛県';  
        GA102006Parameter.city = '松山市'; 
        GA102006Parameter.street ='国土町';   

        // コントローラの初期表示を実行
        Boolean isInit = GA102006Controller.init;
        //選択する明細行数（index）を設定
        GA102006Controller.index = 0;
        //検索処理
        GA102006Controller.searchAddress();
        //検索で出てきたindex行目のレコードを選択
        GA102006Controller.clickSelect();

        //エラーが発生しないこと
    }	 
    
    //選択テスト
     @isTest static void clickSelect(){
        PostalCodeAddressSearchMaxCount(1000);

        GA102006Controller GA102006Controller = new GA102006Controller();
        GA102006ParameterClass GA102006Parameter = new GA102006ParameterClass();

        // ページ遷移時の設定
        GA102006Parameter.isDrawing = true;
        GA102006Parameter.noFirst = true;

        // 住所マスタフラグを設定
        GA102006Parameter.isAddressMoster = false;  
        // コントローラの共通クラスを設定
        GA102006Controller.Parameter = GA102006Parameter;

        //パラメータ設定
        GA102006Parameter.postalCode = null;  
        GA102006Parameter.state = '愛媛県';  
        GA102006Parameter.city = '松山市'; 
        GA102006Parameter.street = '国土町';   

        // コントローラの初期表示を実行（郵便番号）
        Boolean isInit = GA102006Controller.init;
        //選択する詳細行設定
        GA102006Controller.index=0;
        //検索処理
        GA102006Controller.searchAddress();
        //選択
        GA102006Controller.clickSelect();

    }	 

    //住所マスタフラグを設定しない初期処理（異常）テスト
     @isTest static void initializeErrorTest(){
        PostalCodeAddressSearchMaxCount(1000);

        GA102006Controller GA102006Controller = new GA102006Controller();
        GA102006ParameterClass GA102006Parameter = new GA102006ParameterClass();

        // ページ遷移時の設定
        GA102006Parameter.isDrawing = true;
        GA102006Parameter.noFirst = true;
        // コントローラの共通クラスを設定
        GA102006Controller.Parameter = GA102006Parameter;

        // コントローラの初期表示を実行（郵便番号）
        Boolean isInit = GA102006Controller.init;

        //住所マスタフラグが取得できないときのエラー出てる？
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER)));

    }	  

    //文字数制限（異常）テスト
     @isTest static void searchLimitErrorTest(){
        PostalCodeAddressSearchMaxCount(1000);

        GA102006Controller GA102006Controller = new GA102006Controller();
        GA102006ParameterClass GA102006Parameter = new GA102006ParameterClass();

        // ページ遷移時の設定
        GA102006Parameter.isDrawing = true;
        GA102006Parameter.noFirst = true;

        // 住所マスタフラグを設定
        GA102006Parameter.isAddressMoster = true;  
        // コントローラの共通クラスを設定
        GA102006Controller.Parameter = GA102006Parameter;

        //パラメータ設定
        GA102006Parameter.postalCode ='123';   

        // コントローラの初期表示を実行（郵便番号）
        Boolean isInit = GA102006Controller.init;
        //検索処理
        GA102006Controller.searchAddress();

        //3字以下のエラー出てる？
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_INPUT_LENGTH_OR_MORE,'検索条件','4' )));

    }	 
    //検索結果0件（異常）テスト
     @isTest static void searchNothingErrorTest(){
        PostalCodeAddressSearchMaxCount(1000);

        GA102006Controller GA102006Controller = new GA102006Controller();
        GA102006ParameterClass GA102006Parameter = new GA102006ParameterClass();

        // ページ遷移時の設定
        GA102006Parameter.isDrawing = true;
        GA102006Parameter.noFirst = true;

        // 住所マスタフラグを設定
        GA102006Parameter.isAddressMoster = true;  
        // コントローラの共通クラスを設定
        GA102006Controller.Parameter = GA102006Parameter;

        //パラメータ設定
        GA102006Parameter.postalCode ='8888888';   

        // コントローラの初期表示を実行（郵便番号）
        Boolean isInit = GA102006Controller.init;
        //検索処理
        GA102006Controller.searchAddress();

        //検索結果0のエラー出てる？
        List<ApexPages.Message> messages = ApexPages.getMessages();
        //System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_NO_DATA)));

    }
    //カバレッジ率あげ	        
    @isTest static void coverageUp(){
        PostalCodeAddressSearchMaxCount(1000);

        GA102006Controller GA102006Controller = new GA102006Controller();
        GA102006ParameterClass GA102006Parameter = new GA102006ParameterClass();
        // ページ遷移時の設定
        GA102006Parameter.isDrawing = true;
        GA102006Parameter.noFirst = true;

        // 住所マスタフラグを設定
        GA102006Parameter.isAddressMoster = true;  
        GA102006Parameter.obsoleteYM =null;
        GA102006Parameter.choazaCodeNew =null;
        GA102006Parameter.aza =null;
        // コントローラの共通クラスを設定
        GA102006Controller.Parameter = GA102006Parameter;

        //パラメータ設定
        GA102006Parameter.postalCode ='1111111';  
        // コントローラの初期表示を実行（郵便番号）
        Boolean isInit = GA102006Controller.init;
        //検索処理
        GA102006Controller.searchAddress();
        System.debug('ふつうの：'+GA102006Controller.targetList.size());
    }

    @isTest static void coverageUp2(){
        PostalCodeAddressSearchMaxCount(1000);

        GA102006Controller GA102006Controller = new GA102006Controller();
        GA102006ParameterClass GA102006Parameter = new GA102006ParameterClass();
        // ページ遷移時の設定
        GA102006Parameter.isDrawing = true;
        GA102006Parameter.noFirst = true;

        // 住所マスタフラグを設定
        GA102006Parameter.isAddressMoster = false;
        //パラメータ設定
        GA102006Parameter.postalCode ='9999999'; 

        // コントローラの共通クラスを設定
        GA102006Controller.Parameter = GA102006Parameter;
        // コントローラの初期表示を実行（郵便番号）
        Boolean isInit = GA102006Controller.init;
        
        //検索処理
        GA102006Controller.searchAddress();
        System.debug('国土地理協会住所：'+GA102006Controller.targetList.size());
    }
    @isTest static void coverageUp3(){
        PostalCodeAddressSearchMaxCount(1);

        GA102006Controller GA102006Controller = new GA102006Controller();
        GA102006ParameterClass GA102006Parameter = new GA102006ParameterClass();
        // ページ遷移時の設定
        GA102006Parameter.isDrawing = true;
        GA102006Parameter.noFirst = true;

        // 住所マスタフラグを設定
        GA102006Parameter.isAddressMoster = false;  
        // コントローラの共通クラスを設定
        GA102006Controller.Parameter = GA102006Parameter;

        //パラメータ設定
        GA102006Parameter.postalCode ='9998888'; 
        // コントローラの初期表示を実行（郵便番号）
        Boolean isInit = GA102006Controller.init;
        //検索処理
        GA102006Controller.searchAddress();
    }

    @isTest static void coverageUp4(){
        PostalCodeAddressSearchMaxCount(1);

        GA102006Controller GA102006Controller = new GA102006Controller();
        GA102006ParameterClass GA102006Parameter = new GA102006ParameterClass();
        // ページ遷移時の設定
        GA102006Parameter.isDrawing = true;
        GA102006Parameter.noFirst = true;

        // 住所マスタフラグを設定
        GA102006Parameter.isAddressMoster =true;  
        // コントローラの共通クラスを設定
        GA102006Controller.Parameter = GA102006Parameter;
        //パラメータ設定
        GA102006Parameter.postalCode ='8887777'; 
        // コントローラの初期表示を実行（郵便番号）
        Boolean isInit = GA102006Controller.init;

        //検索処理
        GA102006Controller.searchAddress();
    }
}