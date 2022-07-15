/*
* 物件MAP照会のコントローラ
*/
global inherited sharing class GA104002Controller {
    
    //******************************************************************** public変数 ********************************************************************
    
    public string googleMapKey { get; set; }                                               //APIキー
    public List<PropertyMapParameter__c>  PropertyMapParameterList { get; set; }           //物件Map照会用パラメータ
    
    //MAPに表示するデータ
    Transient public List<Property__c> propertyList { get; set; }                                     //物件
    Transient public List<String> propertyIdList { get; set; }                                        //物件Idのリスト
    Transient public List<List<Property__c>> propertyListParentList { get; set; }                     //物件リスト(画面表示用の1000件毎2階層List)
    
    Transient public List<Building__c> buildingList { get; set; }                                     //建物
    Transient public List<List<Building__c>> buildingListParentList { get; set; }                     //建物リスト(画面表示用の1000件毎2階層List)
    
    Transient public List<SurroundingFacility__c> convenienceStoreList { get; set; }                  //コンビニ
    Transient public List<displayConvenienceStore> displayConvenienceStoreList { get; set; }           //表示用コンビニ
    Transient public List<List<displayConvenienceStore>> convenienceStoreListParentList { get; set; } //コンビニリスト(画面表示用の1000件毎2階層List)
    
    Transient public List<SurroundingFacility__c> supermarketList { get; set; }                       //スーパーマーケット
    Transient public List<displaySupermarket> displaySupermarketList { get; set; }                    //表示用スーパーマーケット
    Transient public List<List<displaySupermarket>> supermarketListParentList { get; set; }           //スーパーマーケットリスト(画面表示用の1000件毎2階層List)
    
    Transient public List<Hospital__c> hospitalList { get; set; }                                     //病院
    Transient public List<displayHospital> displayHospitalList { get; set; }                          //表示用病院
    Transient public List<List<displayHospital>> hospitalListParentList { get; set; }                 //病院リスト(画面表示用の1000件毎2階層List)
    
    Transient public List<School__c> primarySchoolList { get; set; }                                  //小学校
    Transient public List<displayPrimarySchool> displayPrimarySchoolList { get; set; }                //表示用小学校
    Transient public List<List<displayPrimarySchool>> primarySchoolListParentList { get; set; }       //小学校リスト(画面表示用の1000件毎2階層List)
    
    Transient public List<School__c> juniorHighSchoolList { get; set; }                               //中学校
    Transient public List<displayJuniorHighSchool> displayJuniorHighSchoolList { get; set; }          //表示用中学校
    Transient public List<List<displayJuniorHighSchool>> juniorHighSchoolListParentList { get; set; } //中学校リスト(画面表示用の1000件毎2階層List)
    
    Transient public List<SurroundingFacility__c> highSchoolList { get; set; }                         //高校
    Transient public List<displayHighSchool> displayHighSchoolList { get; set; }                       //表示用高校
    Transient public List<List<displayHighSchool>> highSchoolListParentList { get; set; }              //高校リスト(画面表示用の1000件毎2階層List)
    
    Transient public List<SurroundingFacility__c> universityList { get; set; }                         //大学
    Transient public List<displayUniversity> displayUniversityList { get; set; }                       //表示用大学
    Transient public List<List<displayUniversity>> universityListParentList { get; set; }              //大学リスト(画面表示用の1000件毎2階層List)
    
    Transient public List<Station__c> stationList { get; set; }                                        //駅
    Transient public List<displayStation> displayStationList { get; set; }                             //駅
    Transient public List<List<displayStation>> stationListParentList { get; set; }                    //駅リスト(画面表示用の1000件毎2階層List)
    
    //パラメータで取得するデータ
    Transient public String propertyMapParameterId { get; set; }                                       //物件Map照会用パラメータ用のId
    Transient public string  isClient { get; set; }                                                    //お客様用フラグ
    Transient public string  accId { get; set; }                                                       //取引先Id
    
    //表示変更用チェックボックス
    public Boolean isConveniCheckbox { get; set; }                                           //コンビニ
    public Boolean isSupermarketCheckbox { get; set; }                                       //スーパーマーケット
    public Boolean isHospitalCheckbox { get; set; }                                          //病院
    public Boolean isPrimarySchoolCheckbox { get; set; }                                     //小学校
    public Boolean isJuniorHighSchoolCheckbox { get; set; }                                  //中学校
    public Boolean isHighSchoolAndUniversityCheckbox { get; set; }                           //高校、大学
    public Boolean isStationCheckbox { get; set; }                                           //駅
    
    //注釈一括表示／非表示の表示／非表示切り替えフラグ
    public Boolean isBatchDisplayInfoWindow { get; set; }                                    //表示／非表示切り替えフラグ
    
    //エラー用の変数
    Transient public Boolean isOpenError { get;set; }                             // 初期表示時のエラーフラグ
    Transient public Boolean hasErrorMessage { get; set; }                        // 初期以降エラーメッセージフラグ
    
    //******************************************************************** Private変数 ********************************************************************
    
    // データ格納用の変数
    Transient private List<SurroundingFacility__c> surroundingFacilityList;//周辺施設
    Transient private List<School__c> primarySchoolList1;                  //小学校1
    Transient private List<School__c> primarySchoolList2;                  //小学校2
    Transient private List<School__c> primarySchoolList3;                  //小学校3
    Transient private List<School__c> juniorHighSchoolList1;               //中学校1
    Transient private List<School__c> juniorHighSchoolList2;               //中学校2
    Transient private List<School__c> juniorHighSchoolList3;               //中学校3
    Transient private List<Station__c> stationList1;                       //駅1
    Transient private List<Station__c> stationList2;                       //駅2
    Transient private List<Station__c> stationList3;                       //駅3
    
    //******************************************************************** publicメソッド ********************************************************************
    
    //コンストラクタ
    public GA104002Controller() {
        try{
            init();              //初期化
            getParamData();      //パラメータ取得
            getMapDisplayData(); //MAPの表示データ設定
        } catch (Exception e) {
            // エラーを設定
            CommonUtil.setErrorMessage(e);
            isOpenError = true;
        }
        
    }   
    
    //一括表示、非表示の切り替え
    public void changeIsBatchDisplayInfoWindow(){
        try{
            hasErrorMessage = FALSE;

            //一括表示、非表示フラグのTRUEとFALSEを入れ替える
            if(isBatchDisplayInfoWindow){
                isBatchDisplayInfoWindow = FALSE;
            }else{
                isBatchDisplayInfoWindow = TRUE;
            }
        } catch (Exception e) {
            // エラーを設定
            hasErrorMessage = TRUE;
            CommonUtil.setErrorMessage(e);
            hasErrorMessage = true;
        }
    }
    
    //物件Map照会用パラメータ削除
    public void deletePropertyMapParameter(){
        //コンストラクタ内のdeleteはエラーとなるため、apex:pageのActionで呼び出す
        Savepoint sp = Database.setsavepoint();
        try{
            if(!PropertyMapParameterList.isEmpty()){
                SecureDML.secureDelete(PropertyMapParameterList);//物件Map照会用パラメータ削除
            }
            
        } catch (Exception e) {
            // エラーを設定
            database.rollback(sp);
            isOpenError = TRUE;
            CommonUtil.setErrorMessage(e);
        }
    }
    
    
    //*********************************************************  privateメソッド  ************************************************************
    
    //初期化処理
    private void init(){

        //エラー用の変数
        isOpenError = FALSE;// 初期表示時のエラーフラグ
        hasErrorMessage = FALSE;// 初期以降エラーメッセージフラグ
        //店舗異動が取得できなければエラー
        CommonUtil.getStaffCurrentShop();
        //googleMapのAPIキーをカスタム設定から取得
        googleMapKey = SystemConfig__c.getInstance().GoogleMapKey__c;
        
        //チェックボックスの初期化
        isConveniCheckbox = FALSE;                //コンビニ
        isSupermarketCheckbox = FALSE;            //スーパーマーケット
        isHospitalCheckbox = FALSE;               //病院
        isPrimarySchoolCheckbox = FALSE;          //小学校
        isJuniorHighSchoolCheckbox = FALSE;       //中学校
        isHighSchoolAndUniversityCheckbox = FALSE;//高校、大学
        isStationCheckbox = FALSE;                //駅
        
        //注釈一括表示／非表示の表示／非表示切り替えフラグの初期化
        isBatchDisplayInfoWindow = TRUE;
        
        //物件Idリストの初期化
        propertyIdList = new List<String>();
        PropertyMapParameterList = new List<PropertyMapParameter__c>();
    }    
    
    //パラメータ取得
    private void getParamData(){
        //物件のIdパラメータ取得
        Transient String propertyId = ApexPages.currentPage().getParameters().get('propertyId');//物件のId
        
        if(propertyId != null){//物件のIdパラメータがある場合物件Idリストに追加
            this.propertyIdList.add(propertyId);
        }else{//物件のIdパラメータがない場合、物件が複数件のため物件Map照会用パラメータ用のId取得
            this.propertyMapParameterId = ApexPages.currentPage().getParameters().get('propertyMapParamId');//物件Map照会用パラメータ用のId
        }
        
        //物件Idが1件もない場合エラー
        if(this.propertyIdList.isEmpty() && this.propertyMapParameterId == null){
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
            throw ex;
        }
        
        //お客様用フラグ取得
        system.debug(ApexPages.currentPage().getParameters().get('isClient'));
        if(ApexPages.currentPage().getParameters().get('isClient') == 'true'){//パラメータは文字列の為Stringで判定する
            this.isClient = 'true';
        }else if(ApexPages.currentPage().getParameters().get('isClient') == 'false'){
            this.isClient = 'false';
        }else{
            //お客様用フラグがない場合エラー
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
            throw ex;
        }
        
        //取引先Id取得
        this.accId = ApexPages.currentPage().getParameters().get('accountId');
    }
    
    //マップ表示用データの取得設定
    private void getMapDisplayData(){
        
        if(propertyMapParameterId != null){
            PropertyMapParameterList = [SELECT Id, PropertyIdList__c FROM PropertyMapParameter__c WHERE Id = :propertyMapParameterId];//パラメータのIdで物件Map照会用パラメータ取得
            
            //レコード情報が取得できなければビジネスロジックException発行
            if(PropertyMapParameterList.isEmpty()) {
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
                throw ex;
            }

            if(PropertyMapParameterList.size() > 0){
                propertyIdList = PropertyMapParameterList[0].PropertyIdList__c.split(',');//物件Map照会用パラメータの、','区切りの物件Idをリストとして取得
            }
        }
        
        //物件
        //物件とそれに紐づく建物を取得
        propertyList = [SELECT ID 
                        ,NAME 
                        ,Building__c  //建物Id
                        ,LiveStatus__c//現況
                        ,PhotoCount__c//写真枚数
                        FROM Property__c 
                        WHERE Id IN :propertyIdList
                        ];

        //レコード情報が取得できなければビジネスロジックException発行
        if(propertyList.isEmpty()) {
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
            throw ex;
        }

        //物件が持つ建物Idをリストにする
        Transient List<Id> propertyBuildingIdList = new List<Id>();//物件が持つ建物Idのリスト

        for(Property__c pro : propertyList){
            propertyBuildingIdList.add(pro.Building__c);
        }

        //建物を物件をもとに取得
        buildingList = [SELECT ID 
                        ,NAME 
                        ,Longitude__c        //経度
                        ,Latitude__c         //緯度
                        ,ConvenienceStore__c //コンビニ
                        ,Supermarket__c      //スーパーマーケット
                        ,GeneralHospital__c  //病院
                        ,PrimarySchool1__c   //小学校1
                        ,PrimarySchool2__c   //小学校2
                        ,PrimarySchool3__c   //小学校3
                        ,JuniorHighSchool1__c//中学校1
                        ,JuniorHighSchool2__c//中学校2
                        ,JuniorHighSchool3__c//中学校3
                        ,HighSchool__c       //高校
                        ,University__c       //大学
                        ,Station1__c         //駅1
                        ,Station2__c         //駅2
                        ,Station3__c         //駅3
                        FROM Building__c WHERE Id IN : propertyBuildingIdList];
        
        //周辺施設取得用のIDリストを作成
        Transient List<Id> buildingIdList = new List<Id>();           //建物
        Transient List<Id> surroundingFacilityIdList = new List<Id>();//周辺施設
        Transient List<Id> hospitalIdList = new List<Id>();           //病院
        Transient List<Id> primarySchool1IdList = new List<Id>();     //小学校1
        Transient List<Id> primarySchool2IdList = new List<Id>();     //小学校2
        Transient List<Id> primarySchool3IdList = new List<Id>();     //小学校3
        Transient List<Id> juniorHighSchool1IdList = new List<Id>();  //中学校1
        Transient List<Id> juniorHighSchool2IdList = new List<Id>();  //中学校2
        Transient List<Id> juniorHighSchool3IdList = new List<Id>();  //中学校3
        Transient List<Id> station1IdList = new List<Id>();           //駅1    
        Transient List<Id> station2IdList = new List<Id>();           //駅2
        Transient List<Id> station3IdList = new List<Id>();           //駅3

        //取得した建物が持つ周辺施設取のIDをリストにする
        for(Building__c build : buildingList){
            buildingIdList.add(build.Id);                            //建物
            surroundingFacilityIdList.add(build.ConvenienceStore__c);//コンビニ
            surroundingFacilityIdList.add(build.Supermarket__c);     //スーパーマーケット
            hospitalIdList.add(build.GeneralHospital__c);            //病院
            primarySchool1IdList.add(build.PrimarySchool1__c);       //小学校1
            primarySchool2IdList.add(build.PrimarySchool2__c);       //小学校2
            primarySchool3IdList.add(build.PrimarySchool3__c);       //小学校3
            juniorHighSchool1IdList.add(build.JuniorHighSchool1__c); //中学校1
            juniorHighSchool2IdList.add(build.JuniorHighSchool2__c); //中学校2
            juniorHighSchool3IdList.add(build.JuniorHighSchool3__c); //中学校3
            surroundingFacilityIdList.add(build.HighSchool__c);      //高校
            surroundingFacilityIdList.add(build.University__c);      //大学
            station1IdList.add(build.Station1__c);                   //駅1
            station2IdList.add(build.Station2__c);                   //駅2
            station3IdList.add(build.Station3__c);                   //駅3
        }
        
        //周辺施設を取得
        surroundingFacilityList = [SELECT ID 
                                   ,NAME 
                                   ,Longitude__c//経度
                                   ,Latitude__c//緯度
                                   ,FacilityType__c//施設区分
                                   ,(SELECT Name 
                                     ,ConvenienceStoreDistance__c//コンビニまでの距離
                                     ,ConvenienceStoreWalkTimeFormat__c//コンビニまでの時間（分）
                                     FROM BuildingConvenienceStore__r //コンビニ
                                     WHERE Id IN : buildingIdList)
                                   ,(SELECT Name 
                                     ,SupermarketDistance__c//スーパーマーケットまでの距離
                                     ,SupermarketWalkTimeFormat__c//スーパーマーケットまでの時間（分）
                                     FROM BuildingSupermarket__r //スーパーマーケット
                                     WHERE Id IN : buildingIdList)
                                   ,(SELECT Name 
                                     ,HighSchoolDistance__c//高校までの距離
                                     ,HighSchoolWalkTimeFormat__c//高校までの時間（分）
                                     FROM BuildingHighSchool__r //高校
                                     WHERE Id IN : buildingIdList)
                                   ,(SELECT Name 
                                     ,UniversityDistance__c//大学までの距離
                                     ,UniversityWalkTimeFormat__c//大学までの時間（分）
                                     FROM BuildingUniversity__r //大学
                                     WHERE Id IN : buildingIdList)
                                   FROM SurroundingFacility__c WHERE Id IN : surroundingFacilityIdList];

        //周辺施設を施設区分別に分ける
        convenienceStoreList = new List<SurroundingFacility__c>();//コンビニ
        supermarketList = new List<SurroundingFacility__c>();     //スーパーマーケット
        highSchoolList = new List<SurroundingFacility__c>();      //高校
        universityList = new List<SurroundingFacility__c>();      //大学
        
        for(SurroundingFacility__c surroundingFacility : surroundingFacilityList){
            if(surroundingFacility.FacilityType__c == CommonConst.SURROUDING_FACILITY_TYPE_CONVINIENTSTORE){//コンビニ
                convenienceStoreList.add(surroundingFacility);
            }
            if(surroundingFacility.FacilityType__c == CommonConst.SURROUDING_FACILITY_TYPE_SUPERMARKET){//スーパー
                supermarketList.add(surroundingFacility);
            }
            if(surroundingFacility.FacilityType__c == CommonConst.SURROUDING_FACILITY_TYPE_HIGHSCHOOL){//高校
                highSchoolList.add(surroundingFacility);
            }
            if(surroundingFacility.FacilityType__c == CommonConst.SURROUDING_FACILITY_TYPE_UNIVERSITY){//大学
                universityList.add(surroundingFacility);
            }
        }
        
        //コンビニのリストを画面に表示できるように内部クラスにする
        displayConvenienceStoreList = new List<displayConvenienceStore>();
        for(SurroundingFacility__c convenienceStore : convenienceStoreList){
            displayConvenienceStoreList.add(new displayConvenienceStore(convenienceStore));
        }
        
        //スーパーマーケットのリストを画面に表示できるように内部クラスにする
        displaySupermarketList = new List<displaySupermarket>();
        for(SurroundingFacility__c supermarket : supermarketList){
            displaySupermarketList.add(new displaySupermarket(supermarket));
        }
        
        //高校のリストを画面に表示できるように内部クラスにする
        displayHighSchoolList = new List<displayHighSchool>();
        for(SurroundingFacility__c highSchool : highSchoolList){
            displayHighSchoolList.add(new displayHighSchool(highSchool));
        }
        
        //大学のリストを画面に表示できるように内部クラスにする
        displayUniversityList = new List<displayUniversity>();
        for(SurroundingFacility__c university : universityList){
            displayUniversityList.add(new displayUniversity(university));
        }
        
        //病院取得
        hospitalList = [SELECT ID 
                        ,NAME 
                        ,Longitude__c//経度
                        ,Latitude__c//緯度
                        ,(SELECT Name 
                          ,GeneralHospitalDistance__c//病院までの距離
                          ,GeneralHospitalWalkTimeFormat__c//病院までの時間（分）
                          FROM BuildingGeneralHospital__r //病院
                          WHERE Id IN : buildingIdList)
                        FROM Hospital__c WHERE Id IN : hospitalIdList];
        
        //病院のリストを画面に表示できるように内部クラスにする
        displayHospitalList = new List<displayHospital>();
        for(Hospital__c hospital : hospitalList){
            displayHospitalList.add(new displayHospital(hospital));
        }
        
        //小学校取得1
        primarySchoolList1 = [SELECT ID 
                              ,NAME 
                              ,Longitude__c//経度
                              ,Latitude__c//緯度
                              ,Type__c//種別(小学校/中学校)
                              ,(SELECT Name 
                                ,PrimarySchoolDistance1__c//小学校までの距離１
                                ,PrimarySchoolWalkTimeFormat1__c//小学校までの時間（分）１
                                ,PrimarySchoolDistance2__c//小学校までの距離2
                                ,PrimarySchoolWalkTimeFormat2__c//小学校までの時間（分）2
                                ,PrimarySchoolDistance3__c//小学校までの距離3
                                ,PrimarySchoolWalkTimeFormat3__c//小学校までの時間（分）3
                                FROM BuildingPrimarySchool1__r //小学校1
                                WHERE Id IN : buildingIdList)
                              FROM School__c WHERE Id IN : primarySchool1IdList];
        
        //小学校取得2
        primarySchoolList2 = [SELECT ID 
                              ,NAME 
                              ,Longitude__c//経度
                              ,Latitude__c//緯度
                              ,Type__c//種別(小学校/中学校)
                              ,(SELECT Name 
                                ,PrimarySchoolDistance1__c//小学校までの距離１
                                ,PrimarySchoolWalkTimeFormat1__c//小学校までの時間（分）１
                                ,PrimarySchoolDistance2__c//小学校までの距離2
                                ,PrimarySchoolWalkTimeFormat2__c//小学校までの時間（分）2
                                ,PrimarySchoolDistance3__c//小学校までの距離3
                                ,PrimarySchoolWalkTimeFormat3__c//小学校までの時間（分）3
                                FROM BuildingPrimarySchool2__r //小学校2
                                WHERE Id IN : buildingIdList)
                              FROM School__c WHERE Id IN : primarySchool2IdList];
        
        //小学校取得3
        primarySchoolList3 = [SELECT ID 
                              ,NAME 
                              ,Longitude__c//経度
                              ,Latitude__c//緯度
                              ,Type__c//種別(小学校/中学校)
                              ,(SELECT Name 
                                ,PrimarySchoolDistance1__c//小学校までの距離１
                                ,PrimarySchoolWalkTimeFormat1__c//小学校までの時間（分）１
                                ,PrimarySchoolDistance2__c//小学校までの距離2
                                ,PrimarySchoolWalkTimeFormat2__c//小学校までの時間（分）2
                                ,PrimarySchoolDistance3__c//小学校までの距離3
                                ,PrimarySchoolWalkTimeFormat3__c//小学校までの時間（分）3
                                FROM BuildingPrimarySchool3__r //小学校3
                                WHERE Id IN : buildingIdList)
                              FROM School__c WHERE Id IN : primarySchool3IdList];
        
        //小学校のリストを画面に表示できるように内部クラスにする
        displayPrimarySchoolList = new List<displayPrimarySchool>();
        for(School__c primarySchool1 : primarySchoolList1){
            displayPrimarySchoolList.add(new displayPrimarySchool(primarySchool1));
        }
        for(School__c primarySchool2 : primarySchoolList2){
            displayPrimarySchoolList.add(new displayPrimarySchool(primarySchool2));
        }
        for(School__c primarySchool3 : primarySchoolList3){
            displayPrimarySchoolList.add(new displayPrimarySchool(primarySchool3));
        }
        
        //中学校取得1
        juniorHighSchoolList1 = [SELECT ID 
                                 ,NAME 
                                 ,Longitude__c//経度
                                 ,Latitude__c//緯度
                                 ,Type__c//種別(小学校/中学校)
                                 ,(SELECT Name 
                                   ,JuniorHighSchoolDistance1__c//中学校までの距離１
                                   ,JuniorHighSchoolWalkTimeFormat1__c//中学校までの時間（分）１
                                   ,JuniorHighSchoolDistance2__c//中学校までの距離2
                                   ,JuniorHighSchoolWalkTimeFormat2__c//中学校までの時間（分）2
                                   ,JuniorHighSchoolDistance3__c//中学校までの距離3
                                   ,JuniorHighSchoolWalkTimeFormat3__c//中学校までの時間（分）3
                                   FROM BuildingJuniorHighSchool1__r //中学校1
                                   WHERE Id IN : buildingIdList)
                                 FROM School__c WHERE Id IN : juniorHighSchool1IdList];
        
        
        
        //中学校取得2
        juniorHighSchoolList2 = [SELECT ID 
                                 ,NAME 
                                 ,Longitude__c//経度
                                 ,Latitude__c//緯度
                                 ,Type__c//種別(小学校/中学校)
                                 ,(SELECT Name 
                                   ,JuniorHighSchoolDistance1__c//中学校までの距離１
                                   ,JuniorHighSchoolWalkTimeFormat1__c//中学校までの時間（分）１
                                   ,JuniorHighSchoolDistance2__c//中学校までの距離2
                                   ,JuniorHighSchoolWalkTimeFormat2__c//中学校までの時間（分）2
                                   ,JuniorHighSchoolDistance3__c//中学校までの距離3
                                   ,JuniorHighSchoolWalkTimeFormat3__c//中学校までの時間（分）3
                                   FROM BuildingJuniorHighSchool2__r //中学校2
                                   WHERE Id IN : buildingIdList)
                                 FROM School__c WHERE Id IN : juniorHighSchool2IdList];
        
        //中学校取得3
        juniorHighSchoolList3 = [SELECT ID 
                                 ,NAME 
                                 ,Longitude__c//経度
                                 ,Latitude__c//緯度
                                 ,Type__c//種別(小学校/中学校)
                                 ,(SELECT Name 
                                   ,JuniorHighSchoolDistance1__c//中学校までの距離１
                                   ,JuniorHighSchoolWalkTimeFormat1__c//中学校までの時間（分）１
                                   ,JuniorHighSchoolDistance2__c//中学校までの距離2
                                   ,JuniorHighSchoolWalkTimeFormat2__c//中学校までの時間（分）2
                                   ,JuniorHighSchoolDistance3__c//中学校までの距離3
                                   ,JuniorHighSchoolWalkTimeFormat3__c//中学校までの時間（分）3
                                   FROM BuildingJuniorHighSchool3__r //中学校3
                                   WHERE Id IN : buildingIdList)
                                 FROM School__c WHERE Id IN : juniorHighSchool3IdList];
        
        //中学校のリストを画面に表示できるように内部クラスにする
        displayJuniorHighSchoolList = new List<displayJuniorHighSchool>();
        for(School__c juniorHighSchool1 : juniorHighSchoolList1){
            displayJuniorHighSchoolList.add(new displayJuniorHighSchool(juniorHighSchool1));
        }
        for(School__c juniorHighSchool2 : juniorHighSchoolList2){
            displayJuniorHighSchoolList.add(new displayJuniorHighSchool(juniorHighSchool2));
        }
        for(School__c juniorHighSchool3 : juniorHighSchoolList3){
            displayJuniorHighSchoolList.add(new displayJuniorHighSchool(juniorHighSchool3));
        }
        
        //駅取得1
        stationList1 = [SELECT ID 
                        ,NAME 
                        ,Longitude__c//経度
                        ,Latitude__c//緯度
                        ,(SELECT Name 
                          ,StationDistance1__c//駅までの距離１
                          ,StationWalkTimeFormat1__c//駅までの時間（分）１
                          FROM BuildingStation1__r //駅1
                          WHERE Id IN : buildingIdList)
                        FROM Station__c WHERE Id IN : station1IdList];
        
        
        //駅取得2
        stationList2 = [SELECT ID 
                        ,NAME 
                        ,Longitude__c//経度
                        ,Latitude__c//緯度
                        ,(SELECT Name 
                          ,StationDistance2__c//駅までの距離2
                          ,StationWalkTimeFormat2__c//駅までの時間（分）2
                          FROM BuildingStation2__r //駅2
                          WHERE Id IN : buildingIdList)
                        FROM Station__c WHERE Id IN : station2IdList];
        
        
        //駅取得3
        stationList3 = [SELECT ID 
                        ,NAME 
                        ,Longitude__c//経度
                        ,Latitude__c//緯度
                        ,(SELECT Name 
                          ,StationDistance3__c//駅までの距離3
                          ,StationWalkTimeFormat3__c//駅までの時間（分）3
                          FROM BuildingStation3__r //駅3
                          WHERE Id IN : buildingIdList)
                        FROM Station__c WHERE Id IN : station3IdList];
        
        
        //駅のリストを画面に表示できるように内部クラスにする
        displayStationList = new List<displayStation>();
        for(Station__c station1 : stationList1){
            displayStationList.add(new displayStation(station1));
        }
        for(Station__c station2 : stationList2){
            displayStationList.add(new displayStation(station2));
        }
        for(Station__c station3 : stationList3){
            displayStationList.add(new displayStation(station3));
        }
        
        //作成した内部クラスを画面に表示できる形に修正
        setPropertyParentList();        //物件
        setBuildingParentList();        //建物
        setConvenienceStoreParentList();//コンビニ
        setSupermarketParentList();     //スーパーマーケット
        setHospitalParentList();        //病院
        setPrimarySchoolParentList();   //小学校
        setJuniorHighSchoolParentList();//中学校
        setHighSchoolParentList();      //高校
        setUniversityParentList();      //大学
        setStationParentList();         //駅
        
    }
    
    //画面表示用に物件リストを加工
    private void setPropertyParentList() {
        //Listを画面表示用に1000件毎に分割した2階層List化する
        this.propertyListParentList = new List<List<Property__c>>();
        this.propertyListParentList.add(new List<Property__c>());
        Integer parentIndex = 0;
        Integer childIndex = 0;
        for (Property__c record : this.propertyList) {
            if (childIndex == 1000) {
                childIndex = 0;
                this.propertyListParentList.add(new List<Property__c>());
                parentIndex++;
            }
            this.propertyListParentList[parentIndex].add(record);
            childIndex++;
        }
    }
    
    //画面表示用に建物リストを加工
    private void setBuildingParentList() {
        //Listを画面表示用に1000件毎に分割した2階層List化する
        this.buildingListParentList = new List<List<Building__c>>();
        this.buildingListParentList.add(new List<Building__c>());
        Integer parentIndex = 0;
        Integer childIndex = 0;
        for (Building__c record : this.buildingList) {
            if (childIndex == 1000) {
                childIndex = 0;
                this.buildingListParentList.add(new List<Building__c>());
                parentIndex++;
            }
            this.buildingListParentList[parentIndex].add(record);
            childIndex++;
        }
    }
    
    //画面表示用にコンビニリストを加工
    private void setConvenienceStoreParentList() {
        //Listを画面表示用に1000件毎に分割した2階層List化する
        this.convenienceStoreListParentList = new List<List<displayConvenienceStore>>();
        this.convenienceStoreListParentList.add(new List<displayConvenienceStore>());
        Integer parentIndex = 0;
        Integer childIndex = 0;
        for (displayConvenienceStore record : this.displayConvenienceStoreList) {
            if (childIndex == 1000) {
                childIndex = 0;
                this.convenienceStoreListParentList.add(new List<displayConvenienceStore>());
                parentIndex++;
            }
            this.convenienceStoreListParentList[parentIndex].add(record);
            childIndex++;
        }
    }
    
    //画面表示用にスーパーマーケットリストを加工
    private void setSupermarketParentList() {
        //Listを画面表示用に1000件毎に分割した2階層List化する
        this.supermarketListParentList = new List<List<displaySupermarket>>();
        this.supermarketListParentList.add(new List<displaySupermarket>());
        Integer parentIndex = 0;
        Integer childIndex = 0;
        for (displaySupermarket record : this.displaySupermarketList) {
            if (childIndex == 1000) {
                childIndex = 0;
                this.supermarketListParentList.add(new List<displaySupermarket>());
                parentIndex++;
            }
            this.supermarketListParentList[parentIndex].add(record);
            childIndex++;
        }
    }
    
    //画面表示用に病院リストを加工
    private void setHospitalParentList() {
        //Listを画面表示用に1000件毎に分割した2階層List化する
        this.hospitalListParentList = new List<List<displayHospital>>();
        this.hospitalListParentList.add(new List<displayHospital>());
        Integer parentIndex = 0;
        Integer childIndex = 0;
        for (displayHospital record : this.displayHospitalList) {
            if (childIndex == 1000) {
                childIndex = 0;
                this.hospitalListParentList.add(new List<displayHospital>());
                parentIndex++;
            }
            this.hospitalListParentList[parentIndex].add(record);
            childIndex++;
        }
    }
    
    //画面表示用に小学校リストを加工
    private void setPrimarySchoolParentList() {
        //Listを画面表示用に1000件毎に分割した2階層List化する
        this.primarySchoolListParentList = new List<List<displayPrimarySchool>>();
        this.primarySchoolListParentList.add(new List<displayPrimarySchool>());
        Integer parentIndex = 0;
        Integer childIndex = 0;
        for (displayPrimarySchool record : this.displayPrimarySchoolList) {
            if (childIndex == 1000) {
                childIndex = 0;
                this.primarySchoolListParentList.add(new List<displayPrimarySchool>());
                parentIndex++;
            }
            this.primarySchoolListParentList[parentIndex].add(record);
            childIndex++;
        }
    }
    
    //画面表示用に中学校リストを加工
    private void setJuniorHighSchoolParentList() {
        //Listを画面表示用に1000件毎に分割した2階層List化する
        this.juniorHighSchoolListParentList = new List<List<displayJuniorHighSchool>>();
        this.juniorHighSchoolListParentList.add(new List<displayJuniorHighSchool>());
        Integer parentIndex = 0;
        Integer childIndex = 0;
        for (displayJuniorHighSchool record : this.displayJuniorHighSchoolList) {
            if (childIndex == 1000) {
                childIndex = 0;
                this.juniorHighSchoolListParentList.add(new List<displayJuniorHighSchool>());
                parentIndex++;
            }
            this.juniorHighSchoolListParentList[parentIndex].add(record);
            childIndex++;
        }
    }
    
    //画面表示用に高校リストを加工
    private void setHighSchoolParentList() {
        //Listを画面表示用に1000件毎に分割した2階層List化する
        this.highSchoolListParentList = new List<List<displayHighSchool>>();
        this.highSchoolListParentList.add(new List<displayHighSchool>());
        Integer parentIndex = 0;
        Integer childIndex = 0;
        for (displayHighSchool record : this.displayHighSchoolList) {
            if (childIndex == 1000) {
                childIndex = 0;
                this.highSchoolListParentList.add(new List<displayHighSchool>());
                parentIndex++;
            }
            this.highSchoolListParentList[parentIndex].add(record);
            childIndex++;
        }
    }
    
    //画面表示用に大学リストを加工
    private void setUniversityParentList() {
        //Listを画面表示用に1000件毎に分割した2階層List化する
        this.universityListParentList = new List<List<displayUniversity>>();
        this.universityListParentList.add(new List<displayUniversity>());
        Integer parentIndex = 0;
        Integer childIndex = 0;
        for (displayUniversity record : this.displayUniversityList) {
            if (childIndex == 1000) {
                childIndex = 0;
                this.universityListParentList.add(new List<displayUniversity>());
                parentIndex++;
            }
            this.universityListParentList[parentIndex].add(record);
            childIndex++;
        }
    }
    
    //画面表示用に駅リストを加工
    private void setStationParentList() {
        //Listを画面表示用に1000件毎に分割した2階層List化する
        this.stationListParentList = new List<List<displayStation>>();
        this.stationListParentList.add(new List<displayStation>());
        Integer parentIndex = 0;
        Integer childIndex = 0;
        for (displayStation record : this.displayStationList) {
            if (childIndex == 1000) {
                childIndex = 0;
                this.stationListParentList.add(new List<displayStation>());
                parentIndex++;
            }
            this.stationListParentList[parentIndex].add(record);
            childIndex++;
        }
    }

    //***************************************************** 内部クラス *****************************************************************
    
    //コンビニの内部クラス
    public class displayConvenienceStore{
        public SurroundingFacility__c convenienceStore { get; set; }    //コンビニ
        public List<List<Building__c>> buildingListParentList { get; set; } //建物リスト(画面表示用の1000件毎2階層List)
        
        //コンストラクタ
        displayConvenienceStore(SurroundingFacility__c inConvenienceStore){
            this.convenienceStore = inConvenienceStore;
            
            //建物Listを画面表示用に1000件毎に分割した2階層List化する
            this.buildingListParentList = new List<List<Building__c>>();
            this.buildingListParentList.add(new List<Building__c>());
            Integer parentIndex = 0;
            Integer childIndex = 0;
            for (Building__c record : inConvenienceStore.BuildingConvenienceStore__r) {
                if (childIndex == 1000) {
                    childIndex = 0;
                    this.buildingListParentList.add(new List<Building__c>());
                    parentIndex++;
                }
                this.buildingListParentList[parentIndex].add(record);
                childIndex++;
            }
        }
    }
    
    //スーパーの内部クラス
    public class displaySupermarket{
        public SurroundingFacility__c supermarket { get; set; }    //コンビニ
        public List<List<Building__c>> buildingListParentList { get; set; } //建物リスト(画面表示用の1000件毎2階層List)
        
        //コンストラクタ
        displaySupermarket(SurroundingFacility__c inSupermarket){
            this.supermarket = inSupermarket;
            
            //建物Listを画面表示用に1000件毎に分割した2階層List化する
            this.buildingListParentList = new List<List<Building__c>>();
            this.buildingListParentList.add(new List<Building__c>());
            Integer parentIndex = 0;
            Integer childIndex = 0;
            for (Building__c record : inSupermarket.BuildingSupermarket__r) {
                if (childIndex == 1000) {
                    childIndex = 0;
                    this.buildingListParentList.add(new List<Building__c>());
                    parentIndex++;
                }
                this.buildingListParentList[parentIndex].add(record);
                childIndex++;
            }
        }
    }
    
    //病院の内部クラス
    public class displayHospital{
        public Hospital__c  hospital { get; set; }    //コンビニ
        public List<List<Building__c>> buildingListParentList { get; set; } //建物リスト(画面表示用の1000件毎2階層List)
        
        //コンストラクタ
        displayHospital(Hospital__c inhospital){
            this.hospital = inhospital;
            
            //建物Listを画面表示用に1000件毎に分割した2階層List化する
            this.buildingListParentList = new List<List<Building__c>>();
            this.buildingListParentList.add(new List<Building__c>());
            Integer parentIndex = 0;
            Integer childIndex = 0;
            for (Building__c record : inhospital.BuildingGeneralHospital__r) {
                if (childIndex == 1000) {
                    childIndex = 0;
                    this.buildingListParentList.add(new List<Building__c>());
                    parentIndex++;
                }
                this.buildingListParentList[parentIndex].add(record);
                childIndex++;
            }
        }
    }
    
    //小学校の内部クラス
    public class displayPrimarySchool{
        public School__c  primarySchool { get; set; }    //小学校
        public Boolean  isPrimarySchool1 { get; set; }    //小学校1に設定されている
        public Boolean  isPrimarySchool2 { get; set; }    //小学校2に設定されている
        public Boolean  isPrimarySchool3 { get; set; }    //小学校3に設定されている
        public List<List<Building__c>> buildingListParentList { get; set; } //建物リスト(画面表示用の1000件毎2階層List)
        
        //コンストラクタ
        displayPrimarySchool(School__c inPrimarySchool){
            this.primarySchool = inPrimarySchool;
            
            //建物Listを画面表示用に1000件毎に分割した2階層List化する
            this.buildingListParentList = new List<List<Building__c>>();
            this.buildingListParentList.add(new List<Building__c>());
            
            //学校1に設定されている建物をリスト化
            Integer parentIndex = 0;
            Integer childIndex = 0;
            if(inPrimarySchool.BuildingPrimarySchool1__r.size() > 0){
                this.isPrimarySchool1 = true;
                for (Building__c record : inPrimarySchool.BuildingPrimarySchool1__r) {
                    if (childIndex == 1000) {
                        childIndex = 0;
                        this.buildingListParentList.add(new List<Building__c>());
                        parentIndex++;
                    }
                    this.buildingListParentList[parentIndex].add(record);
                    childIndex++;
                }
            }
            //学校2に設定されている建物をリスト化
            parentIndex = 0;
            childIndex = 0;
            if(inPrimarySchool.BuildingPrimarySchool2__r.size() > 0){
                this.isPrimarySchool2 = true;
                for (Building__c record : inPrimarySchool.BuildingPrimarySchool2__r) {
                    if (childIndex == 1000) {
                        childIndex = 0;
                        this.buildingListParentList.add(new List<Building__c>());
                        parentIndex++;
                    }
                    this.buildingListParentList[parentIndex].add(record);
                    childIndex++;
                }
            }

            //学校3に設定されている建物をリスト化
            parentIndex = 0;
            childIndex = 0;
            if(inPrimarySchool.BuildingPrimarySchool3__r.size() > 0){
                this.isPrimarySchool3 = true;
                for (Building__c record : inPrimarySchool.BuildingPrimarySchool3__r) {
                    if (childIndex == 1000) {
                        childIndex = 0;
                        this.buildingListParentList.add(new List<Building__c>());
                        parentIndex++;
                    }
                    this.buildingListParentList[parentIndex].add(record);
                    childIndex++;
                }
            }
        }
    }
    
    //中学校の内部クラス
    public class displayJuniorHighSchool{
        public School__c  juniorHighSchool { get; set; }  //中学校
        public Boolean  isJuniorHighSchool1 { get; set; }    //中学校1に設定されている
        public Boolean  isJuniorHighSchool2 { get; set; }    //中学校2に設定されている
        public Boolean  isJuniorHighSchool3 { get; set; }    //中学校3に設定されている
        public List<List<Building__c>> buildingListParentList { get; set; } //建物リスト(画面表示用の1000件毎2階層List)
        
        //コンストラクタ
        displayJuniorHighSchool(School__c injuniorHighSchool){
            this.juniorHighSchool = injuniorHighSchool;
            
            //建物Listを画面表示用に1000件毎に分割した2階層List化する
            this.buildingListParentList = new List<List<Building__c>>();
            this.buildingListParentList.add(new List<Building__c>());

            //学校1に設定されている建物をリスト化
            Integer parentIndex = 0;
            Integer childIndex = 0;
            if(injuniorHighSchool.BuildingJuniorHighSchool1__r.size() > 0){
                this.isJuniorHighSchool1 = true;
                for (Building__c record : injuniorHighSchool.BuildingJuniorHighSchool1__r) {
                    if (childIndex == 1000) {
                        childIndex = 0;
                        this.buildingListParentList.add(new List<Building__c>());
                        parentIndex++;
                    }
                    this.buildingListParentList[parentIndex].add(record);
                    childIndex++;
                }
            }
            //学校2に設定されている建物をリスト化
            parentIndex = 0;
            childIndex = 0;
            if(injuniorHighSchool.BuildingJuniorHighSchool2__r.size() > 0){
                this.isJuniorHighSchool2 = true;
                for (Building__c record : injuniorHighSchool.BuildingJuniorHighSchool2__r) {
                    if (childIndex == 1000) {
                        childIndex = 0;
                        this.buildingListParentList.add(new List<Building__c>());
                        parentIndex++;
                    }
                    this.buildingListParentList[parentIndex].add(record);
                    childIndex++;
                }
            }
            //学校3に設定されている建物をリスト化
            parentIndex = 0;
            childIndex = 0;
            if(injuniorHighSchool.BuildingJuniorHighSchool3__r.size() > 0){
                this.isJuniorHighSchool3 = true;
                for (Building__c record : injuniorHighSchool.BuildingJuniorHighSchool3__r) {
                    if (childIndex == 1000) {
                        childIndex = 0;
                        this.buildingListParentList.add(new List<Building__c>());
                        parentIndex++;
                    }
                    this.buildingListParentList[parentIndex].add(record);
                    childIndex++;
                }
            }
        }
    }
    
    //高校の内部クラス
    public class displayHighSchool{
        public SurroundingFacility__c highSchool { get; set; }    //コンビニ
        public List<List<Building__c>> buildingListParentList { get; set; } //建物リスト(画面表示用の1000件毎2階層List)
        
        //コンストラクタ
        displayHighSchool(SurroundingFacility__c inhighSchool){
            this.highSchool = inhighSchool;
            
            //建物Listを画面表示用に1000件毎に分割した2階層List化する
            this.buildingListParentList = new List<List<Building__c>>();
            this.buildingListParentList.add(new List<Building__c>());
            Integer parentIndex = 0;
            Integer childIndex = 0;
            for (Building__c record : inhighSchool.BuildingHighSchool__r) {
                
                if (childIndex == 1000) {
                    childIndex = 0;
                    this.buildingListParentList.add(new List<Building__c>());
                    parentIndex++;
                }
                this.buildingListParentList[parentIndex].add(record);
                childIndex++;
            }
        }
    }
    
    //大学の内部クラス
    public class displayUniversity{
        public SurroundingFacility__c university { get; set; }    //コンビニ
        public List<List<Building__c>> buildingListParentList { get; set; } //建物リスト(画面表示用の1000件毎2階層List)
        
        //コンストラクタ
        displayUniversity(SurroundingFacility__c inUniversity){
            this.university = inUniversity;
            
            //建物Listを画面表示用に1000件毎に分割した2階層List化する
            this.buildingListParentList = new List<List<Building__c>>();
            this.buildingListParentList.add(new List<Building__c>());
            Integer parentIndex = 0;
            Integer childIndex = 0;
            for (Building__c record : inUniversity.BuildingUniversity__r) {
                if (childIndex == 1000) {
                    childIndex = 0;
                    this.buildingListParentList.add(new List<Building__c>());
                    parentIndex++;
                }
                this.buildingListParentList[parentIndex].add(record);
                childIndex++;
            }
        }
    }
    
    //駅の内部クラス
    public class displayStation{
        public Station__c  station { get; set; }    //駅
        public Boolean  isStation1 { get; set; }    //駅1に設定されている
        public Boolean  isStation2 { get; set; }    //駅2に設定されている
        public Boolean  isStation3 { get; set; }    //駅3に設定されている
        public List<List<Building__c>> buildingListParentList { get; set; } //建物リスト(画面表示用の1000件毎2階層List)
        
        //コンストラクタ
        displayStation(Station__c inStation){
            this.station = inStation;
            
            //建物Listを画面表示用に1000件毎に分割した2階層List化する
            this.buildingListParentList = new List<List<Building__c>>();
            this.buildingListParentList.add(new List<Building__c>());

            //駅1に設定されている建物をリスト化
            Integer parentIndex = 0;
            Integer childIndex = 0;
            if(inStation.BuildingStation1__r.size() > 0){
                this.isStation1 = true;
                for (Building__c record : inStation.BuildingStation1__r) {
                    if (childIndex == 1000) {
                        childIndex = 0;
                        this.buildingListParentList.add(new List<Building__c>());
                        parentIndex++;
                    }
                    this.buildingListParentList[parentIndex].add(record);
                    childIndex++;
                }
            }
            //駅2に設定されている建物をリスト化
            parentIndex = 0;
            childIndex = 0;
            if(inStation.BuildingStation2__r.size() > 0){
                this.isStation2 = true;
                for (Building__c record : inStation.BuildingStation2__r) {
                    if (childIndex == 1000) {
                        childIndex = 0;
                        this.buildingListParentList.add(new List<Building__c>());
                        parentIndex++;
                    }
                    this.buildingListParentList[parentIndex].add(record);
                    childIndex++;
                }
            }
            //駅3に設定されている建物をリスト化
            parentIndex = 0;
            childIndex = 0;
            if(inStation.BuildingStation3__r.size() > 0){
                this.isStation3 = true;
                for (Building__c record : inStation.BuildingStation3__r) {
                    if (childIndex == 1000) {
                        childIndex = 0;
                        this.buildingListParentList.add(new List<Building__c>());
                        parentIndex++;
                    } 
                    this.buildingListParentList[parentIndex].add(record);
                    childIndex++;
                }
            }
        }
    }
}