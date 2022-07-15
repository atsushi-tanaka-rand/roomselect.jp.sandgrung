/* *
 * 物件MAP照会のテスト
 */
@isTest 
private class GA104002Test {

    /**
    * テストに使用するレコードを作成する
    */
    @TestSetup static void setting(){  
        system.debug('初期設定開始');       
        
        //駅作成用路線作成
        TrainRoute__c trainRoute = new TrainRoute__c(NAME = 'テスト路線');
        insert trainRoute;
        
        //周辺施設作成

        //周辺施設
        List<SurroundingFacility__c> highschool = new List<SurroundingFacility__c>();    //高校
        List<SurroundingFacility__c> university = new List<SurroundingFacility__c>();    //大学
        List<SurroundingFacility__c> convinienstore = new List<SurroundingFacility__c>();//コンビニ
        List<SurroundingFacility__c> supermarket = new List<SurroundingFacility__c>();   //スーパーマーケット

        //病院
        List<Hospital__c> hospital = new List<Hospital__c>();

        //学校
        List<School__c> primarySchool = new List<School__c>();//小学校
        List<School__c> juniorHighSchool = new List<School__c>();//中学校

        //駅
        List<Station__c> station = new List<Station__c>();


        //周辺施設設定200件ずつ
        for(Integer i = 0 ; i < 200 ; i++){
            //高校
            highschool.add(new SurroundingFacility__c(Name = CommonConst.SURROUDING_FACILITY_TYPE_HIGHSCHOOL + i
                                                     ,Latitude__c = 0.0000001 * i
                                                     ,Longitude__c = 0.0000000
                                                     ,FacilityType__c = CommonConst.SURROUDING_FACILITY_TYPE_HIGHSCHOOL
                                                     ));
            //大学
            university.add(new SurroundingFacility__c(Name = CommonConst.SURROUDING_FACILITY_TYPE_UNIVERSITY + i
                                                     ,Latitude__c = 0.0000001 * i
                                                     ,Longitude__c = 1.0000000
                                                     ,FacilityType__c = CommonConst.SURROUDING_FACILITY_TYPE_UNIVERSITY
                                                     ));
            //コンビニ
            convinienstore.add(new SurroundingFacility__c(Name = CommonConst.SURROUDING_FACILITY_TYPE_CONVINIENTSTORE + i
                                                         ,Latitude__c = 0.0000001 * i
                                                         ,Longitude__c = 2.0000000
                                                         ,FacilityType__c = CommonConst.SURROUDING_FACILITY_TYPE_CONVINIENTSTORE
                                                         ));
            //スーパーマーケット
            supermarket.add(new SurroundingFacility__c(Name = CommonConst.SURROUDING_FACILITY_TYPE_SUPERMARKET + i
                                                      ,Latitude__c = 0.0000001 * i
                                                      ,Longitude__c = 3.0000000
                                                      ,FacilityType__c = CommonConst.SURROUDING_FACILITY_TYPE_SUPERMARKET
                                                      ));
            //病院
            hospital.add(new Hospital__c(Name = '病院' + i
                                        ,Latitude__c = 0.0000001 * i
                                        ,Longitude__c = 4.0000000
                                        ));
            //小学校
            primarySchool.add(new School__c(Name = CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL + i
                                           ,Latitude__c = 0.0000001 * i
                                           ,Longitude__c = 5.0000000
                                           ,Type__c = CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL
                                           ));
            //中学校
            juniorHighSchool.add(new School__c(Name = CommonConst.SCHOOL_TYPE_JUNIORHIGHSCHOOL + i
                                              ,Latitude__c = 0.0000001 * i
                                              ,Longitude__c = 6.0000000
                                              ,Type__c = CommonConst.SCHOOL_TYPE_JUNIORHIGHSCHOOL
                                              ));
            //駅
            station.add(new Station__c(Name = '駅' + i
                                      ,Latitude__c = 0.0000001 * i
                                      ,Longitude__c = 7.0000000
                                      ,TrainRoute__c = trainRoute.Id//作成した駅
                                      ));
        }

        
        //周辺施設作成
        insert highschool;      //高校
        insert university;      //大学
        insert convinienstore;  //コンビニ
        insert supermarket;     //スーパーマーケット
        insert hospital;        //病院
        insert primarySchool;   //小学校
        insert juniorHighSchool;//中学校
        insert station;         //駅

        //建物作成
        List<Building__c> building = new List<Building__c>();
        
        //建物設定10件
        for(Integer i = 0 ; i < 10 ; i++){

            //インデックス/200の余りを使用
            Integer n = i / 200;
            Integer Num =  i - ( n * 200 );

            system.debug(i);
            system.debug(Num);


            building.add(new Building__c(Name = '建物' + i//建物名
            ,ConvenienceStore__c = convinienstore[Num].Id//コンビニ
            ,ConvenienceStoreDistance__c = 1//コンビニまでの距離
            ,Supermarket__c = supermarket[Num].Id//スーパーマーケット
            ,SupermarketDistance__c = 1//スーパーマーケットまでの距離
            ,Latitude__c = 0.0000001 * i//緯度
            ,Station1__c = station[Num].Id//駅１
            ,Station2__c = station[Num].Id//駅２
            ,Station3__c = station[Num].Id//駅３
            ,StationDistance1__c = 1//駅までの距離
            ,StationDistance2__c = 1//駅までの距離２
            ,StationDistance3__c = 1//駅までの距離３
            ,TrainRoute1__c = trainRoute.Id//沿線１
            ,TrainRoute2__c = trainRoute.Id//沿線２
            ,TrainRoute3__c = trainRoute.Id//沿線３
            ,Longitude__c = 8.0000000//経度
            ,HighSchool__c = highschool[Num].Id//高校
            ,HighSchoolDistance__c = 1//高校までの距離
            ,PrimarySchool1__c = primarySchool[Num].Id//小学校１
            ,PrimarySchool2__c = primarySchool[Num].Id//小学校２
            ,PrimarySchool3__c = primarySchool[Num].Id//小学校３
            ,PrimarySchoolDistance1__c = 1//小学校までの距離１
            ,PrimarySchoolDistance2__c = 1//小学校までの距離２
            ,PrimarySchoolDistance3__c = 1//小学校までの距離３
            ,GeneralHospital__c = hospital[Num].Id//総合病院
            ,GeneralHospitalDistance__c = 1//総合病院までの距離
            ,University__c = university[Num].Id//大学
            ,UniversityDistance__c = 1//大学までの距離
            ,JuniorHighSchool1__c = juniorHighSchool[Num].Id//中学校１
            ,JuniorHighSchool2__c = juniorHighSchool[Num].Id//中学校２
            ,JuniorHighSchool3__c = juniorHighSchool[Num].Id//中学校３
            ,JuniorHighSchoolDistance1__c = 1//中学校までの距離１
            ,JuniorHighSchoolDistance2__c = 1//中学校までの距離２
            ,JuniorHighSchoolDistance3__c = 1//中学校までの距離３
                                      ));
        }
        
        //建物作成
        insert building;

        //物件作成
        List<Property__c> property = new List<Property__c>();
        
        //物件設定20件
        for(Integer i = 0 ; i < 20 ; i++){

            //インデックス/100の余りを使用
            Integer n = i / 10;
            Integer Num =  i - ( n * 10 );

            system.debug(i);
            system.debug(Num);


            property.add(new Property__c(Name = '物件' + i//物件名
                                       , Building__c = building[Num].Id//建物Id
                                       , LiveStatus__c = CommonConst.PROPERTY_LIVESTATUS_RESIDENT //現況
                                      ));
        }
        
        //物件作成
        insert property;

        

        //物件Map照会用パラメータ
        PropertyMapParameter__c propertyMapParameter = new PropertyMapParameter__c();

        String propertyIdList = '';

        for(Property__c prop : property){
            propertyIdList += ',' + prop.Id;
        }

        propertyMapParameter.PropertyIdList__c = propertyIdList;

        insert propertyMapParameter;

        system.debug('初期設定終了');        

    }

 
    //***************************************************** テストメソッド *****************************************************************
    
    // 初期表示
    @isTest static void initializeTest() {

        //物件Map照会用パラメータを取得
        List<PropertyMapParameter__c> propertyMapParameter = new List<PropertyMapParameter__c>();
        propertyMapParameter = [SELECT Id, PropertyIdList__c FROM PropertyMapParameter__c];

        system.assertEquals(1, propertyMapParameter.size());//物件Map照会用パラメータを取得できているか確認

        //画面起動
        PageReference pageRef = Page.GA104002View;
        pageRef.getParameters().put('propertyMapParamId', propertyMapParameter[0].Id);
        pageRef.getParameters().put('isClient', 'false');
        Test.setCurrentPage(pageRef);

        GA104002Controller GA104002Controller = new GA104002Controller();//コンストラクタ起動

        //コンストラクタ起動結果確認
        //パラメータ反映
        system.assertEquals(propertyMapParameter[0].Id, GA104002Controller.propertyMapParameterId);
        system.assertEquals('false', GA104002Controller.isClient);

        //エラー未発生
        system.assertEquals(FALSE, GA104002Controller.isOpenError);


        //画面起動時に呼び出す物件Map照会用パラメータ削除処理起動
        GA104002Controller.deletePropertyMapParameter();
        
        //削除処理起動結果確認
        propertyMapParameter = [SELECT Id, PropertyIdList__c FROM PropertyMapParameter__c];
        system.assertEquals(TRUE, propertyMapParameter.isEmpty());//物件Map照会用パラメータが削除できているか確認


    }

    // 注釈一括表示／非表示フラグ切替
    @isTest static void changeIsBatchDisplayInfoWindowTest() {

        //物件Map照会用パラメータを取得
        List<PropertyMapParameter__c> propertyMapParameter = new List<PropertyMapParameter__c>();
        propertyMapParameter = [SELECT Id, PropertyIdList__c FROM PropertyMapParameter__c];

        system.assertEquals(1, propertyMapParameter.size());//物件Map照会用パラメータを取得できているか確認

        //画面起動
        PageReference pageRef = Page.GA104002View;
        pageRef.getParameters().put('propertyMapParamId', propertyMapParameter[0].Id);
        pageRef.getParameters().put('isClient', 'false');
        Test.setCurrentPage(pageRef);

        GA104002Controller GA104002Controller = new GA104002Controller();//コンストラクタ起動

        //コンストラクタ起動結果確認
        //パラメータ反映
        system.assertEquals(propertyMapParameter[0].Id, GA104002Controller.propertyMapParameterId);
        system.assertEquals('false', GA104002Controller.isClient);

        //エラー未発生
        system.assertEquals(FALSE, GA104002Controller.isOpenError);

        Boolean isBatchDisplayInfoWindow = GA104002Controller.isBatchDisplayInfoWindow;

        system.assertEquals(isBatchDisplayInfoWindow, GA104002Controller.isBatchDisplayInfoWindow);

        GA104002Controller.changeIsBatchDisplayInfoWindow();//一括表示、非表示の切り替え

        system.assertNotEquals(isBatchDisplayInfoWindow, GA104002Controller.isBatchDisplayInfoWindow);//切り替え確認

        GA104002Controller.changeIsBatchDisplayInfoWindow();//一括表示、非表示の再切り替え

        system.assertEquals(isBatchDisplayInfoWindow, GA104002Controller.isBatchDisplayInfoWindow);//切り替え確認
    }

    // パラメータエラー
    @isTest static void parameterErrorTest() {


        //画面起動
        PageReference pageRef = Page.GA104002View;
        pageRef.getParameters().put('propertyMapParamId', '不正なパラメータ');
        pageRef.getParameters().put('isClient', 'false');
        Test.setCurrentPage(pageRef);

        GA104002Controller GA104002Controller = new GA104002Controller();//コンストラクタ起動

        //コンストラクタ起動結果確認

        //エラー発生
        system.assertEquals(TRUE, GA104002Controller.isOpenError);

        //「エラーフラグ」がTRUEに設定されている？
        system.assertEquals(GA104002Controller.isOpenError, TRUE);

        //「エラーメッセージ」が正しく設定されている？
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonConst.MSG_COM_E_SYSTEM_PARAMETER);
    }

}