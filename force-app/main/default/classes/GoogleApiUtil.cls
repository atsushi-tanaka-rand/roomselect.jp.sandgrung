//周辺情報取得用 グーグルApiに関するメソッドを集めたUtilクラス
public with sharing class GoogleApiUtil {
    
    //システム設定
    private static SystemConfig__c instance = SystemConfig__c.getInstance();
    
    //スキップフラグ(画面で使用する前に設定すること)
    public static Boolean isSkipStation               = false; //駅　　　　の取得をしないフラグ
    public static Boolean isSkipSchools               = false; //小中学校　の取得をしないフラグ
    public static Boolean isSkipHospital              = false; //病院　　　の取得をしないフラグ
    public static Boolean isSkipFacilities            = false; //周辺施設　の取得をしないフラグ
    
    //スキップフラグ(バッチで使用する前に設定すること)　←優先される
    private static Boolean isSkipStationBySystemConfig    = instance.SurroundingBatchIsSkipStation__c;
    private static Boolean isSkipSchoolsBySystemConfig    = instance.SurroundingBatchIsSkipSchools__c;
    private static Boolean isSkipHospitalBySystemConfig   = instance.SurroundingBatchIsSkipHospital__c;
    private static Boolean isSkipFacilitiesBySystemConfig = instance.SurroundingBatchIsSkipFacilities__c;

    //static定数
    private static final Decimal PROCESS_COUNT  = instance.SurroundingBatchProcessCount__c; //一括処理件数
    private static final Decimal SEARCH_RANGE   = instance.SearchStationRange__c; //検索半径(m)
    private static final Decimal MAX_LATITUDE   = maxLatitudeSetting();       // 検索緯度上限
    
    // セーブポイント
    // 注意：GoogleApiUtilの呼び出し元にて、エラー時のロールバックする際に使用。
    public static Savepoint savePoint;
    // ****************************************************************** 周辺情報取得(全体)　*********************************************************    


    //**************************
    // 周辺情報取得(単一)
    //**************************
    public static void getPeripheralInformation (Building__c building){
        List<Building__c> buildingList = new List<Building__c>();
        buildingList.add(building);
        
        getPeripheralInformation(buildingList);
    }
    
    
    //**************************
    // 周辺情報取得(List)
    //**************************
    public static void getPeripheralInformation (List<Building__c> buildingList){
        
        // スキップフラグ設定(システム設定を優先する)
        isSkipStation    = isSkipStationBySystemConfig    ? true : isSkipStation;
        isSkipSchools    = isSkipSchoolsBySystemConfig    ? true : isSkipSchools;
        isSkipHospital   = isSkipHospitalBySystemConfig   ? true : isSkipHospital;
        isSkipFacilities = isSkipFacilitiesBySystemConfig ? true : isSkipFacilities;
        
        
        
        
        // 終了判定　一括処理件数 を超過しているなら
        if(buildingList.size() > PROCESS_COUNT){
            System.debug('周辺施設情報取得は、APIの制限により' + PROCESS_COUNT +'件を超える建物を同時に処理できません');// ログを残す。
            return;
        }
        
        // 対象の設定
        List<Building__c> targetList = new List<Building__c>();
        for(Building__c addBuilding: buildingList){
            if(String.isNotBlank(addBuilding.Address__c)){ // 住所が空じゃなければ対象である
                targetList.add(addBuilding);
            }
        }
        system.debug('targetList.size()='+targetList.size());
        // 終了判定　対象が空なら
        if (targetList.size() == 0) {
            return;
        }

        // 座標設定
        setCoordinate(targetList);
            
        // 対象の再設定
        List<Building__c> temporaryList = new List<Building__c>();
        for(Building__c addBuilding: targetList){
            if(addBuilding.Latitude__c != null && addBuilding.Longitude__c != null){ // 座標が空じゃなければ対象である
                temporaryList.add(addBuilding);
            }
        }
        targetList = temporaryList;
        system.debug('targetList.size()='+targetList.size());
        system.debug('★TargetlistID'+targetList[0].id);
        // 終了判定　対象が空なら
        if (targetList.size() == 0) {
            return;
        }
       
        // 駅設定
        if (!isSkipStation) {
            setStation(targetList);
        }
        
        // 小中学校設定
        if (!isSkipSchools) {
            setSchool(targetList);
        }
      
        // 病院設定
        if (!isSkipHospital) {
            setHospital(targetList);
        }
        
        // 周辺施設設定
        if (!isSkipFacilities) {
            setSurroundingFacilities(targetList); //※この部分の最後でinsertしているので、それ以降httpコールアウトは行えない(エラーとなる)
        }
    }

    // ポータルサイト構築 追加 Start
    // ****************************************************************** 経度、緯度取得　*********************************************************    
    //**************************
    // 住所にて経度緯度取得(単一)
    // Map<String,List<Double>> String  住所
    //                          List<0> 経度
    //                          List<1> 緯度
    //**************************
    public static Map<String,List<Double>> getLongitudeLatitude(String address){
        // 座標設定
        return setCoordinateFromGoogleAPI(address);
    }
    // ポータルサイト構築 追加 End
    
    // ****************************************************************** 座標設定　*********************************************************
    
    //**************************
    // 座標設定(GoogleAPI呼び出しメソッド)
    //**************************
    public static void setCoordinate(List<Building__c> buildingList){

        //建物の情報をGoogleAPI(座標設定)に投げて、緯度と経度を設定する
        for(Building__c building : buildingList){
            //緯度・経度が設定されていない場合のみ行う
            if (building.Latitude__c == null || building.Longitude__c == null) {
                setCoordinateFromGoogleAPI(building);
            }
            
        }
    }


    // ****************************************************************** 駅設定　*********************************************************
    
    
    //**************************
    // 駅設定メソッド
    //**************************
    public static void setStation(List<building__c> targetList){

        for(building__c target : targetList){
            
            // 検索用
            Decimal maxLongitude  = maxLongitudeSetting(target.State__c);       // 都道府県を基準に検索経度上限を設定
            Decimal buildMinLati  = target.Latitude__c  - MAX_LATITUDE;  // 検索用建物からの最低緯度
            Decimal buildMaxLati  = target.Latitude__c  + MAX_LATITUDE;  // 検索用建物からの最高緯度
            Decimal buildMinLongi = target.Longitude__c - maxLongitude;  // 検索用建物からの最低経度
            Decimal buildMaxLongi = target.Longitude__c + maxLongitude;  // 検索用建物からの最高経度

            List<Station__c> selectStationList = [SELECT Id, Latitude__c, Longitude__c, TrainRoute__c
                                                  FROM Station__c
                                                  WHERE Latitude__c  >= :buildMinLati // 最低緯度から
                                                  AND Latitude__c  <= :buildMaxLati   // 最高緯度まで
                                                  AND Longitude__c >= :buildMinLongi  // 最低経度から
                                                  AND Longitude__c <= :buildMaxLongi  // 最高経度まで
                                                  ORDER BY Name
                                                 ];
            
            // (路線用)駅Map作成
            Map<Id, Station__c> stationMap = new Map<Id, Station__c>(selectStationList);

            // ソート
            List<calculateDistanceFacility> calculateStationList = new List<calculateDistanceFacility>();// 計算用駅内部クラスListをnew
            for(Station__c station : selectStationList){
                
                //同座標のものが既にあるか調べる
                Boolean isDuplicateCordinates = false;
                for (calculateDistanceFacility existingStation: calculateStationList) {
                    if (station.Latitude__c == existingStation.latitude && 
                        station.Longitude__c == existingStation.longitude) {

                        isDuplicateCordinates = true;
                        break;
                    }
                }

	            // 計算用駅内部クラスをaddする
                if (!isDuplicateCordinates) { //同座標のものがなければ追加
    	            calculateStationList.add(new calculateDistanceFacility(station.Id, station.Latitude__c, station.Longitude__c, target));
                }
            }
            calculateStationList.sort();

            //取得リストを上位3つの駅にする
            for (Integer i = calculateStationList.size() - 1; i >= 3 ; i--) {
                calculateStationList.remove(i);
            }

            //実際の距離を取得し、距離を上書き
            for (calculateDistanceFacility station : calculateStationList){
                station.distance = getDistanceFromGoogleAPI(target, station.latitude, station.longitude); //距離設定
            }
            
            //再度距離順にソート    
            calculateStationList.sort();
            
            //初期化
            target.Station1__c         = null;
            target.StationDistance1__c = null;
            target.TrainRoute1__c      = null;
            target.Station2__c         = null;
            target.StationDistance2__c = null;
            target.TrainRoute2__c      = null;
            target.Station3__c         = null;
            target.StationDistance3__c = null;
            target.TrainRoute3__c      = null;

            // 建物に駅、路線を設定する
            if(calculateStationList.size() >= 1){
                calculateDistanceFacility station = calculateStationList[0]; //一番目の駅
                target.Station1__c         = station.targetId; //Id設定
                target.StationDistance1__c = station.distance; //距離設定
                target.TrainRoute1__c      = stationMap.get(station.targetId).TrainRoute__c; //路線設定
            }
            
            if(calculateStationList.size() >= 2){
                calculateDistanceFacility station = calculateStationList[1]; //二番目の駅
                target.Station2__c         = station.targetId; //Id設定
                target.StationDistance2__c = station.distance; //距離設定
                target.TrainRoute2__c      = stationMap.get(station.targetId).TrainRoute__c; //路線設定
            }
            
            if(calculateStationList.size() >= 3){
                calculateDistanceFacility station = calculateStationList[2]; //三番目の駅
                target.Station3__c         = station.targetId; //Id設定
                target.StationDistance3__c = station.distance; //距離設定
                target.TrainRoute3__c      = stationMap.get(station.targetId).TrainRoute__c; //路線設定
            }
            
            // 条件(駅までの時間が30分以上)を満たしている場合、駅2,3を設定しない
            target.recalculateFormulas(); //数式再計算
            if (calculateStationList.size() >= 2 && target.StationWalkTime2__c > 30) {

                target.Station2__c         = null;
                target.StationDistance2__c = null;
                target.TrainRoute2__c      = null;
            }
            if (calculateStationList.size() >= 3 && target.StationWalkTime3__c > 30) {

                target.Station3__c         = null;
                target.StationDistance3__c = null;
                target.TrainRoute3__c      = null;
            }
            target.recalculateFormulas(); //数式再計算
        }
    }

    //***************************
    // 検索緯度上限取得メソッド
    //**************************
    private static Decimal maxLatitudeSetting(){
        
        // (1) 1度当たりのkm = 110.94297
        // (2) システム設定の駅検索距離を取得
        // (2) ÷ (1)で計算する
        Decimal sysSearchStationRange = SEARCH_RANGE;
        Decimal retLatitude = sysSearchStationRange / 110.94297;
        
        return retLatitude;
    }
    
    //***************************
    // 検索経度上限取得メソッド
    //**************************
    private static Decimal maxLongitudeSetting(String districts){
        // 建物オブジェクトから都道府県名を取得
        if (String.isBlank(districts)) {
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_NO_SELECTED, '都道府県'));
            throw ex;
        }

        // CommonConstから都道府県の経度緯度を取得
        Decimal baseLatitude  = CommonConst.DISTRICTS_LATITUDE.get(districts);      // 都道府県の緯度
        Decimal baseLongitude = CommonConst.DISTRICTS_LONGITUDE.get(districts);     // 都道府県の経度

        // 緯度・経度が取得できない場合はエラー
        if (baseLatitude == null || baseLongitude == null) {
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_EXCEPTION, '緯度・経度取得エラー'));
            throw ex;
        }

        // 距離計算メソッドを使って計算
        Decimal dist = calcDistance(baseLatitude, baseLatitude, baseLongitude, baseLongitude + 1);
        Decimal retLongitude = SEARCH_RANGE / dist * 1000;

        return retLongitude;
    }
    
    
    //********************************************************　小中学校設定　*******************************************************************

    
    //**************************
    // 小中学校設定
    //**************************
    public static void setSchool(List<building__c> targetList) {

        //小学校設定
        setSchool(targetList, CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL);

        //中学校設定
        setSchool(targetList, CommonConst.SCHOOL_TYPE_JUNIORHIGHSCHOOL);
    }
    
    //**************************
    // 学校設定
    //**************************
    public static void setSchool(List<building__c> targetList ,String schoolType){
        // 学校Mapを作成して初期化
        Map<Id, List<School__c>> schoolMap = new Map<Id, List<School__c>>(); //Map<建物Id、学校のList>
        for(Building__c build : targetList){
            schoolMap.put(build.Id, new List<School__c>());// 学校Mapに追加
        }

        // 町字コードMapを作成（キー：建物Id）
        Map<Id, String> choazaCodeMap = new Map<Id, String>();
        for (Building__c build : targetList) {
            if (String.isNotBlank(build.ChoazaCode__c)) {
                choazaCodeMap.put(build.Id, build.ChoazaCode__c);
            }
        }

        // 国都地理協会住所Mapを作成（キー：町字コード）
        List<JapanGeographicDataCenterAddress__c> jpAddressList = [
            SELECT ChoazaCodeNew__c, PlaceName__c FROM JapanGeographicDataCenterAddress__c WHERE ObsoleteYM__c = '000000' AND ChoazaCodeNew__c IN :choazaCodeMap.values()
        ];
        Map<String, String> jpAddressMap = new Map<String, String>();
        for (JapanGeographicDataCenterAddress__c jpAddress : jpAddressList) {
            jpAddressMap.put(jpAddress.ChoazaCodeNew__c, jpAddress.PlaceName__c);
        }

         // 小学校レコードを検索
        for( Building__c build : targetList){
            
            // 検索用
            Decimal maxLongitude  = maxLongitudeSetting(build.State__c);        // 都道府県を基準に検索経度上限を設定
            Decimal buildMinLati  = build.Latitude__c  - MAX_LATITUDE;  // 検索用建物からの最低緯度
            Decimal buildMaxLati  = build.Latitude__c  + MAX_LATITUDE;  // 検索用建物からの最高緯度
            Decimal buildMinLongi = build.Longitude__c - maxLongitude; // 検索用建物からの最低経度
            Decimal buildMaxLongi = build.Longitude__c + maxLongitude; // 検索用建物からの最高経度
           
            // 小学校を学区ごと取得
            List<School__c> selectSchoolList = [ SELECT Id 
                                                       , Latitude__c
                                                       , Longitude__c
                                                       , ( SELECT Address__c FROM SchoolAreaSchool__r )
                                                       FROM School__c
                                                       WHERE Latitude__c  >= :buildMinLati   // 最低緯度から
                                                       AND Latitude__c  <= :buildMaxLati   // 最高緯度まで
                                                       AND Longitude__c >= :buildMinLongi  // 最低経度から
                                                       AND Longitude__c <= :buildMaxLongi  // 最高経度まで
                                                       AND Type__c = :schoolType  // 種別:小学校or中学校
                                                      ];
            // 建物の国土地理協会住所を取得（町字コードで取得した国土地理協会住所）
            String buildAddress = '';
            if (choazaCodeMap.containsKey(build.Id)) {
                String choazaCode = choazaCodeMap.get(build.Id);    // 町字コード
                if (jpAddressMap.containsKey(choazaCode)) {
                    buildAddress = jpAddressMap.get(choazaCode);    // 国土地理協会住所
                    buildAddress = String.isEmpty(buildAddress) ? '' : buildAddress.deleteWhitespace(); // 空白を除く
                }
            }

            // 対象の学校Listを初期化
            List<School__c> targetSchoolList = new List<School__c>();

            // 建物の国土地理協会住所が存在すれば、学校を検索する
            if (String.isNotBlank(buildAddress)) {

                // 検索学校リストを回す
                for( School__c school : selectSchoolList){
                    // 学区の住所が建物の住所に含まれていたら対象とする
                    for( SchoolArea__c area : school.SchoolAreaSchool__r){

                        // 建物の住所に学区の住所が含まれていたら
                        String areaAddress  = String.isEmpty(area.Address__c)  ? '' : area.Address__c.deleteWhitespace();   // 空白を除く             
                        if(buildAddress.contains(areaAddress)){
                            targetSchoolList.add(school);// 対象学校リストに格納
                            break;// 学区のループを抜ける
                        }
                    }
                }
            }

            // ソート
            List<calculateDistanceFacility> calculateDistanceList = new List<calculateDistanceFacility>();//計算用内部クラスのListを作成

            for(School__c targetSchool : targetSchoolList){// 対象学校Listを回す
                calculateDistanceList.add(new calculateDistanceFacility(targetSchool.Id, targetSchool.Latitude__c, targetSchool.Longitude__c, build));
            }
            calculateDistanceList.sort(); // ソートする
                  
            
            //取得リストを直接距離で近い上位3つの学校にする
            for (Integer i = calculateDistanceList.size() - 1; i >= 3 ; i--) {
                calculateDistanceList.remove(i);
            }
            
            //実際の距離を取得し、距離を上書き
            for( calculateDistanceFacility school :calculateDistanceList){
                school.distance = getDistanceFromGoogleAPI(build, school.latitude, school.longitude); //距離設定
            }

            //再度距離順にソート    
            calculateDistanceList.sort();
            
            //初期化
            if (schoolType == CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL){//小学校のとき小学校項目初期化
                build.PrimarySchool1__c         = null;
                build.PrimarySchoolDistance1__c = null;
                build.PrimarySchool2__c         = null;
                build.PrimarySchoolDistance2__c = null;
                build.PrimarySchool3__c         = null;
                build.PrimarySchoolDistance3__c = null;
            }else{													//中学校のとき小学校項目初期化
                build.JuniorHighSchool1__c         = null;
                build.JuniorHighSchoolDistance1__c = null;
                build.JuniorHighSchool2__c         = null;
                build.JuniorHighSchoolDistance2__c = null;
                build.JuniorHighSchool3__c         = null;
                build.JuniorHighSchoolDistance3__c = null;
            }
                
            //建物に対応する、学校が1つ以上存在するなら
            if(calculateDistanceList.size() >= 1){
                calculateDistanceFacility school          = calculateDistanceList[0];
                if (schoolType == CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL){               //小学校
                    build.PrimarySchool1__c         = school.targetId; //小学校設定
                    build.PrimarySchoolDistance1__c = school.distance; //距離設定
                }else{                                                                  //中学校
                    build.JuniorHighSchool1__c         = school.targetId; //中学校設定
                    build.JuniorHighSchoolDistance1__c = school.distance; //距離設定
                }

            }
            //建物に対応する、小学校が2つ以上存在するなら
            if(calculateDistanceList.size() >= 2){
                calculateDistanceFacility school          = calculateDistanceList[1];
                if (schoolType == CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL){               //小学校
                    build.PrimarySchool2__c         = school.targetId; //小学校設定
                    build.PrimarySchoolDistance2__c = school.distance; //距離設定
                }else{                                                                  //中学校
                    build.JuniorHighSchool2__c         = school.targetId; //中学校設定
                    build.JuniorHighSchoolDistance2__c = school.distance; //距離設定
                }
            }
            
            //建物に対応する、小学校が3つ以上存在するなら
            if(calculateDistanceList.size() >= 3){
                calculateDistanceFacility school          = calculateDistanceList[2];
                if (schoolType == CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL){               //小学校
                    build.PrimarySchool3__c         = school.targetId; //小学校設定
                    build.PrimarySchoolDistance3__c = school.distance; //距離設定
                }else{                                                                  //中学校
                    build.JuniorHighSchool3__c         = school.targetId; //中学校設定
                    build.JuniorHighSchoolDistance3__c = school.distance; //距離設定
                }
            }
            // 時間を反映
            build.recalculateFormulas();
        }
    }    
    
    // ****************************************************************** 病院設定　*********************************************************
    
    
    //**************************
    // 病院設定メソッド
    //**************************
    public static void setHospital(List<building__c> targetList){

        for(building__c target : targetList){
            
            // 検索用
            Decimal maxLongitude  = maxLongitudeSetting(target.State__c);       // 都道府県を基準に検索経度上限を設定
            Decimal buildMinLati  = target.Latitude__c  - MAX_LATITUDE;  // 検索用建物からの最低緯度
            Decimal buildMaxLati  = target.Latitude__c  + MAX_LATITUDE;  // 検索用建物からの最高緯度
            Decimal buildMinLongi = target.Longitude__c - maxLongitude; // 検索用建物からの最低経度
            Decimal buildMaxLongi = target.Longitude__c + maxLongitude; // 検索用建物からの最高経度

            List<Hospital__c> selectHospitalList = [SELECT Id, Latitude__c, Longitude__c 
                                                  FROM Hospital__c
                                                  WHERE Latitude__c  >= :buildMinLati   // 最低緯度から
                                                  AND   Latitude__c  <= :buildMaxLati   // 最高緯度まで
                                                  AND   Longitude__c >= :buildMinLongi  // 最低経度から
                                                  AND   Longitude__c <= :buildMaxLongi  // 最高経度まで
                                                 ];

            // ソート
            List<calculateDistanceFacility> calculateHospitalList = new List<calculateDistanceFacility>();// 計算用駅内部クラスListをnew
            for(Hospital__c hospital : selectHospitalList){
                calculateHospitalList.add(new calculateDistanceFacility(hospital.Id, hospital.Latitude__c, hospital.Longitude__c, target));
            }
            calculateHospitalList.sort();

            //初期化
            target.GeneralHospital__c         = null;
            target.GeneralHospitalDistance__c = null;
 
            // 建物に病院を設定する
            if(calculateHospitalList.size() >= 1){
                calculateDistanceFacility hospital = calculateHospitalList[0]; //一番目の病院
                target.GeneralHospital__c = hospital.targetId; //Id設定
                target.GeneralHospitalDistance__c = getDistanceFromGoogleAPI(target, hospital.latitude, hospital.longitude); //距離設定
            }
            
        }
    }
    
    // ****************************************************************** 周辺情報取得　*********************************************************

    //**************************
    // 周辺施設取得
    //**************************
    public static void setSurroundingFacilities (List<Building__c> targetList){
        
        //変数宣言
        Map<Id, SurroundingFacility__c> highSchoolMap       = new Map<Id, SurroundingFacility__c>(); //Map<建物Id、高校　　>
        Map<Id, SurroundingFacility__c> universityMap       = new Map<Id, SurroundingFacility__c>(); //Map<建物Id、大学　　>
        Map<Id, SurroundingFacility__c> superMarketMap      = new Map<Id, SurroundingFacility__c>(); //Map<建物Id、スーパー>
        Map<Id, SurroundingFacility__c> convenienceStoreMap = new Map<Id, SurroundingFacility__c>(); //Map<建物Id、コンビニ>

        List<String> placeIdList = new List<String>();
        Map<String, SurroundingFacility__c> placeIdMap = new Map<String, SurroundingFacility__c>(); //Map<placeId、周辺施設>　☆
        List<SurroundingFacility__c> insertList = new List<SurroundingFacility__c>();// 周辺施設insert用のList（重複除外前）
        List<SurroundingFacility__c> finalInsertList = new List<SurroundingFacility__c>();// 周辺施設insert用のList（重複除外後）
        
        //GoogleAPIによる周辺情報の取得 高校
        getSurroundingFacilities(targetList, CommonConst.SURROUDING_FACILITY_TYPE_HIGHSCHOOL, highSchoolMap, insertList);
        //GoogleAPIによる周辺情報の取得 大学
        getSurroundingFacilities(targetList, CommonConst.SURROUDING_FACILITY_TYPE_UNIVERSITY, universityMap, insertList);  
        //GoogleAPIによる周辺情報の取得 スーパー
        getSurroundingFacilities(targetList, CommonConst.SURROUDING_FACILITY_TYPE_SUPERMARKET, superMarketMap, insertList);
        //GoogleAPIによる周辺情報の取得 コンビニ
        getSurroundingFacilities(targetList, CommonConst.SURROUDING_FACILITY_TYPE_CONVINIENTSTORE, convenienceStoreMap, insertList);
        
        //建物に距離を設定 (httpコールアウトは、insertより前にしないといけない)
        for (Building__c target: targetList ){
            
            //初期化
            target.HighSchoolDistance__c       = null;
            target.UniversityDistance__c       = null;
            target.SuperMarketDistance__c      = null;
            target.ConvenienceStoreDistance__c = null;
        
            //高校
            SurroundingFacility__c highschool = (SurroundingFacility__c)highSchoolMap.get(target.Id);
            if (highSchool != null) {
                target.HighSchoolDistance__c = getDistanceFromGoogleAPI(target, highSchool.Latitude__c, highSchool.Longitude__c); //距離設定
            }
           
            //大学
            SurroundingFacility__c university = (SurroundingFacility__c)universityMap.get(target.Id);
            if (university != null) {
                target.UniversityDistance__c = getDistanceFromGoogleAPI(target, university.Latitude__c, university.Longitude__c); //距離設定
            }
           
            //スーパー
            SurroundingFacility__c supermarket = (SurroundingFacility__c)supermarketMap.get(target.Id);
            if (supermarket != null) {
                target.SupermarketDistance__c = getDistanceFromGoogleAPI(target, supermarket.Latitude__c, supermarket.Longitude__c); //距離設定
            }
           
            //コンビニ
            SurroundingFacility__c convenienceStore = (SurroundingFacility__c)convenienceStoreMap.get(target.Id);
            if (convenienceStore != null) {
                target.ConvenienceStoreDistance__c = getDistanceFromGoogleAPI(target, convenienceStore.Latitude__c, convenienceStore.Longitude__c); //距離設定
            }
        }
        
        // セーブポイントを設定
        // 注意：GoogleApiUtilの呼び出し元にて、エラー時のロールバックに使用。
        savePoint = Database.setSavepoint();

        //insert処理
        if(!insertList.isEmpty()){

            //重複分を削除する
            for (SurroundingFacility__c surround : insertList) {
                if (placeIdMap.containsKey(surround.PlaceId__c)) {
                   continue;
                } else {
                   placeIdMap.put(surround.PlaceId__c, surround);
                   finalInsertList.add(surround);
                }
            }
            SecureDML.secureInsert(finalInsertList); //注意！！！！ここより後ろではhttpコールアウトは使えない！！！！
        }
        
        //建物にIdを設定
        for (Building__c target: targetList ){
            
            //初期化
            target.HighSchool__c               = null;
            target.University__c               = null;
            target.SuperMarket__c              = null;
            target.ConvenienceStore__c         = null;

            // ▼ 2022.04.01 
            //高校
            SurroundingFacility__c highschool = (SurroundingFacility__c)highSchoolMap.get(target.Id);
            if (highSchool != null) {
                if (highSchool.id != null){
                	target.HighSchool__c         = highSchool.Id; //Id設定
                } else if(placeIdMap.containsKey(highSchool.PlaceId__c)) {
                    // 周辺施設が重複して追加対象外となった場合、同一PlaceIdの施設を設定する
                    target.HighSchool__c         = placeIdMap.get(highSchool.PlaceId__c).id;
                }
            }

            //大学
            SurroundingFacility__c university = (SurroundingFacility__c)universityMap.get(target.Id);
            if (university != null) {
                if (university.id != null){
                	target.university__c         = university.Id; //Id設定
                } else if(placeIdMap.containsKey(university.PlaceId__c)) {
                    // 周辺施設が重複して追加対象外となった場合、同一PlaceIdの施設を設定する
                    target.university__c         = placeIdMap.get(university.PlaceId__c).id;
                }
            }
           
            //スーパー
            SurroundingFacility__c supermarket = (SurroundingFacility__c)supermarketMap.get(target.Id);
            if (supermarket != null) {
                if (supermarket.id != null){
                	target.supermarket__c         = supermarket.Id; //Id設定
                } else if(placeIdMap.containsKey(supermarket.PlaceId__c)) {
                    // 周辺施設が重複して追加対象外となった場合、同一PlaceIdの施設を設定する
                    target.supermarket__c         = placeIdMap.get(supermarket.PlaceId__c).id;
                }
            }
           
            //コンビニ
            SurroundingFacility__c convenienceStore = (SurroundingFacility__c)convenienceStoreMap.get(target.Id);
            if (convenienceStore != null) {
                if (convenienceStore.id != null){
                	target.convenienceStore__c         = convenienceStore.Id; //Id設定
                } else if(placeIdMap.containsKey(convenienceStore.PlaceId__c)) {
                    // 周辺施設が重複して追加対象外となった場合、同一PlaceIdの施設を設定する
                    target.convenienceStore__c         = placeIdMap.get(convenienceStore.PlaceId__c).id;
                }
            }
        // ▲ 2022.04.01 
        }
    }
    
    
    //**************************
    // 周辺施設取得(一種類)
    //**************************
    private static void getSurroundingFacilities (
        List<Building__c> targetList,               //建物リスト
        String keyword,                             //検索する施設の種別(高校、大学、スーパー、コンビニ、病院)
        Map<Id,SurroundingFacility__c> placeMap,   //建物Idに対応する、施設のplace_Id(グーグル固有の値)
        List<SurroundingFacility__c> insertList)    //DBへinsertする周辺施設List

    {
        Map<Id,List<SurroundingFacility__c>> placeMapList =new Map<Id,List<SurroundingFacility__c>>(); //2022.03.28 No0771 MAP追加
        
        //googleApiによる施設取得実施
        for(Building__c building : targetList){
            
            // ▼ 2022.03.28 No.771 周辺施設をリストで取得するように変更
            //周辺施設取得
            List<SurroundingFacility__c> putFacirityList = getSurroundingFacilitiesFromGoogleAPI(building, keyword);//Mapにputするための変数
            //Googleから施設が取得できた場合
            if (putFacirityList != null) {
                placeMapList.put(building.Id, putFacirityList); // 周辺施設調査結果をMapに格納する
            }
            // ▲ 2022.03.28 No.771 周辺施設をリストで取得するように変更
        }
    
        
        // 既存データ取得のために place_id のListを作成
        // ▼ 2022.03.28 No.771　周辺施設リストからplaceIdを取得 
        List<String> placeIdForGetInformationList = new List<String>();
        for (id pId : placeMapList.keySet()){
            List<SurroundingFacility__c> pl = placeMapList.get(pId);
             for (SurroundingFacility__c place : pl) {
                placeIdForGetInformationList.add(place.PlaceId__c);
            }
        }
        // ▲　2022.03.28 No.771　周辺施設リストからplaceIdを取得 
             
        // 既存キーのMapを作成
        Map<String,SurroundingFacility__c> existingKeyMap = new Map<String,SurroundingFacility__c>();//Map<place_id、周辺情報>

        // 既存キーのMap作成のためにDBから周辺施設を取得
        List<SurroundingFacility__c> existingList = [SELECT Id, PlaceId__c, FacilityType__c FROM SurroundingFacility__c WHERE PlaceId__c IN :placeIdForGetInformationList]; //2022.03.28 No.771 FacilityType__c 追加
        for(SurroundingFacility__c existing: existingList){
            existingKeyMap.put(existing.PlaceId__c, existing);// Mapに追加
        }
        
    // 既存 Map になければ、 insertList に追加  
    // ▼ 2022.03.28 No.771 PlaceMapリスト化、周辺施設対象外を対象外とする
    for(Id buildingId : placeMapList.keyset()){
        List<SurroundingFacility__c> facilityList = placeMapList.get(buildingId); // 対象周辺施設リスト 2022.03.28 No0771 リスト化

        for (SurroundingFacility__c facility : facilityList) {
            // 既存MapにあればIdを設定 or なければinsertListに追加
            if(facility != null && existingKeyMap.containsKey(facility.PlaceId__c)){
                SurroundingFacility__c sf = existingKeyMap.get(facility.PlaceId__c);
                if (sf.FacilityType__c != CommonConst.SURROUDING_FACILITY_TYPE_NOTAPPLICABLE) { // 施設区分の値が周辺施設対象外の場合、除外する
                    facility.Id = existingKeyMap.get(facility.PlaceId__c).Id;//Id 設定
                    placeMap.put(buildingId,facility);
                    break;
                }
            } else {
                placeMap.put(buildingId,facility);
                insertList.add(facility);
                break;
            }
        }
    }
    // ▲ 2022.03.28 No.771 PlaceMapリスト化、周辺施設対象外を対象外とする
}
    
    
    //*************************************************************** GoogleAPIメソッド ************************************************************
    
    
    
    //**************************
    // GoogleAPI(座標設定)
    //**************************    
    private static void setCoordinateFromGoogleAPI(Building__c building){
        //Httpコールアウト設定
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        
        //コールアウトに必要な変数設定
        String address;
        if(String.isNotBlank(building.Address__c)){ 
            address = building.Address__c.deleteWhitespace();
        }
        String key     = SystemConfig__c.getInstance().GoogleMapKey__c;
        
        req.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address=' + address + '&components=country:JP&key=' + key);
        req.setMethod('GET');
        req.setTimeout(60000);
        
        //コールアウト
        HttpResponse res = h.send(req);
        
        double lat = null;
        double lon = null;
 
        //返却されたJsonから値を取得
        JsonForGetCoordinate Json = JsonForGetCoordinate.parse(res.getBody());

        //建物に経度、緯度を設定
        if (Json.results.size() > 0) {
            building.Latitude__c  = Json.results[0].geometry.location.lat;// 緯度    
            building.Longitude__c = Json.results[0].geometry.location.lng;// 経度
        }
     
    }
    
    // ポータルサイト構築 追加 Start
    //**************************
    // GoogleAPI(座標設定)（住所から経度緯度のみ取得）
    //**************************    
    private static Map<String,List<Double>> setCoordinateFromGoogleAPI(String address){
        //Httpコールアウト設定
        Http h = new Http();
        HttpRequest req = new HttpRequest();

        // 住所有無
        if(String.isBlank(address)){ 
            return null;
        }
        
        String key     = SystemConfig__c.getInstance().GoogleMapKey__c;
        Map<String,List<Double>> calculateLongitudeLatitudeMap =  new  Map<String,List<Double>>(); 
        try{
            req.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address=' + address.replaceAll(' ','') + '&components=country:JP&key=' + key);
            req.setMethod('GET');
            req.setTimeout(60000);
            
            //コールアウト
            HttpResponse res = h.send(req);
    
            //返却されたJsonから値を取得
            JsonForGetCoordinate Json = JsonForGetCoordinate.parse(res.getBody());
            //経度、緯度を設定
            if (Json.results.size() > 0) {
                List<Double> calculateLongitudeLatitudeList = new List<Double>();
                //緯度 経度
                calculateLongitudeLatitudeList.add(Json.results[0].geometry.location.lat);
                calculateLongitudeLatitudeList.add(Json.results[0].geometry.location.lng);
                calculateLongitudeLatitudeMap.put(address,calculateLongitudeLatitudeList);
            }

            return calculateLongitudeLatitudeMap;
        }catch(Exception e){
            return null;
        }
    }
    // ポータルサイト構築 追加 End
    
    
    //**************************
    // GoogleAPI(周辺施設取得)
    //**************************
    private static List<SurroundingFacility__c> getSurroundingFacilitiesFromGoogleAPI(Building__c building, String keyword){ // ▼ 2022.03.28 No.771 返却値をリスト化

        //検索文字列 設定
        String searchWord; // 検索文字列
                
        // 区分が高校なら
        if(keyword == CommonConst.SURROUDING_FACILITY_TYPE_HIGHSCHOOL){
            searchWord = 'school'     + '&keyword=' + CommonConst.SURROUDING_FACILITY_TYPE_HIGHSCHOOL; // 'type=school&keyword=高校'
        }
        // 区分が大学なら
        else if(keyword == COMMONCONST.SURROUDING_FACILITY_TYPE_UNIVERSITY){
            searchWord = 'university' + '&keyword=' + CommonConst.SURROUDING_FACILITY_TYPE_UNIVERSITY; // 'type=university&keyword=大学';
        }
        // 区分がコンビニなら
        else if(keyword == CommonConst.SURROUDING_FACILITY_TYPE_CONVINIENTSTORE){
            searchWord = 'convenience_store';
        }
        // 区分がスーパーなら
        else if(keyword == CommonConst.SURROUDING_FACILITY_TYPE_SUPERMARKET){
            searchWord = 'supermarket';
        }
        
        //Httpコールアウト設定
        Http h = new Http();	
        HttpRequest req = new HttpRequest();
        
        // コールアウトに必要な変数を設定する
        String lat   = String.valueOf(building.Latitude__c);        // 緯度 型変換DecimalからStringに
        String lon   = String.valueOf(building.Longitude__c);       // 経度 型変換DecimalからStirngに
        String type  = searchWord; 
        String key   = SystemConfig__c.getInstance().GoogleMapKey__c;
        
        // Googleへ問合せ(近いもの順）
        req.setEndpoint('https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=' + lat + ',' + lon + '&language=ja&rankby=distance&types=' + type + '&key=' + key);
        req.setMethod('GET');
        req.setTimeout(60000);
        
        // コールアウト
        HttpResponse res = h.send(req);
        // 返却されたJsonから値を取得
        JsonForGetSurroundingFacilities Json = JsonForGetSurroundingFacilities.parse(res.getBody());
        
        
        // ▼ 2022.03.28 No.771 返却値をリスト化
        // 返却値を設定
        List<SurroundingFacility__c> returnList = new List<SurroundingFacility__c>();

        // 周辺施設が一つでも取得できた場合
        if (Json.results.size() > 0) {
            for (Integer i = 0; i < Json.results.size(); i++) {
                //距離計算(m)
                Decimal distance = calcDistance(building.Latitude__c, Json.results[i].geometry.location.lat, building.Longitude__c, Json.results[i].geometry.location.lng);
                if (distance > SEARCH_RANGE * 1000) { //距離範囲を超えているとnull
                    break;
                }
            
                //返却値設定
                SurroundingFacility__c obj = new SurroundingFacility__c();
                obj.Name         = Json.results[i].name;                   // 名前
                obj.Latitude__c  = Json.results[i].geometry.location.lat ; // 経度
                obj.Longitude__c = Json.results[i].geometry.location.lng;  // 緯度
                obj.Address__c   = Json.results[i].vicinity;               // 住所
                obj.PlaceId__c   = Json.results[i].place_id;               //place_ Id
                obj.FacilityType__c = keyword;                             // 施設区分
                returnList.add(obj);
            }
        }
        return returnList ;
        // ▲ 2022.03.28 No.771 返却値をリスト化
    }


    
    //**************************
    // GoogleAPI(距離取得)
    //**************************
    private static Integer getDistanceFromGoogleAPI(Building__c building, Decimal latitude, Decimal longitude){
        
        //null対応
        if (latitude == null || longitude == null) {
            return null;
        }

        Http h = new Http();
        HttpRequest req = new HttpRequest();        
        
        String startPoint = String.valueOf(building.Latitude__c) + ',' + String.valueOf(building.Longitude__c);   //開始点
        String endPoint   = String.valueOf(latitude)             + ',' + String.valueOf(longitude);               //目的地
        
        String key = SystemConfig__c.getInstance().GoogleMapKey__c;

        // Googleへ問合せ
        req.setEndpoint('https://maps.googleapis.com/maps/api/directions/json?origin=' + startPoint + '&destination=' + endPoint + '&mode=walking&key=' + key); 
        req.setMethod('GET');
        req.setTimeout(60000);
        
        HttpResponse res = h.send(req);
        
        //返却されたJsonから値を取得
        JsonForGetDistance Json = JsonForGetDistance.parse(res.getBody());
         
        //返却値設定
        Integer returnDistance = null;
        if (Json.routes.size() > 0) {
            // 距離を取得
            String resultString  = Json.routes[0].legs[0].distance.text;             // String型なので、ここで受け取る。
            
            if (resultString.contains(' km')) {
                String resultStringRemoveKm = resultString.remove(' km');                // ' km'除外 
                Decimal resultDecimal = Decimal.valueOf(resultStringRemoveKm) * 1000;    // Decimal変換  m変換
                returnDistance = Math.round(resultDecimal);                              // 小数切り捨て
            } else if (resultString.contains(' m')) {
                String resultStringRemoveKm = resultString.remove(' m');                 // ' m'除外 
                Decimal resultDecimal = Decimal.valueOf(resultStringRemoveKm);           // Decimal変換
                returnDistance = Math.round(resultDecimal);                              // 小数切り捨て
            }
        }
        return returnDistance;
        
    }
    
    
    
    // ************************************************************************ 距離計算メソッド ****************************************************************


    
    //****************************
    // 距離計算メソッド
    //****************************
    public static Decimal calcDistance(Decimal lat1, Decimal lat2, Decimal lng1, Decimal lng2){
        
        //世界観測値系
        Decimal GRS80_A  = 6378137.000;//長半径 a(m)
        Decimal GRS80_E2 = 0.00669438002301188;//第一遠心率  eの2乗
        
        Decimal my = deg2rad((lat1 + lat2) / 2.0); //緯度の平均値
        Decimal dy = deg2rad(lat1 - lat2); //緯度の差
        Decimal dx = deg2rad(lng1 - lng2); //経度の差
        
        //卯酉線曲率半径を求める(東と西を結ぶ線の半径)
        Decimal sinMy = Math.sin(my);
        Decimal w = Math.sqrt(1.0 - GRS80_E2 * sinMy * sinMy);
        Decimal n = GRS80_A / w;
        
        //子午線曲線半径を求める(北と南を結ぶ線の半径)
        Decimal mnum = GRS80_A * (1 - GRS80_E2);
        Decimal m = mnum / (w * w * w);
        
        //ヒュベニの公式
        Decimal dym = dy * m;
        Decimal dxncos = dx * n * Math.cos(my);
        return Math.sqrt(dym * dym + dxncos * dxncos);
    }
        
    // 距離計算メソッド用privateメソッド
    private static Decimal deg2rad(Decimal deg){
        return deg * Math.PI / 180.0;
    }    
    
    
    // ************************************************************************ 内部クラス ****************************************************************


    //***************************
    // 距離計算用施設　内部クラス
    //***************************
    public class CalculateDistanceFacility implements Comparable {
        
        Id targetId { get; set; }    // 対象Id
        Decimal latitude { get; set; }    // 緯度
        Decimal longitude { get; set; }   // 経度
        Decimal distance { get; set; }    // 距離
        
        // コンストラクタ
        public calculateDistanceFacility(Id targetId, Decimal latitude, Decimal longitude, Building__c targetBuild){
            
            this.targetId = targetId;            // Id
            this.latitude = latitude;            // 緯度
            this.longitude = longitude;          // 経度
            
            // 距離
            this.distance = GoogleApiUtil.calcDistance(this.latitude, targetBuild.Latitude__c, this.longitude, targetBuild.Longitude__c);
            
        }
        
        // compareToを実装する
        public Integer compareTo(Object compareTo) {
            
            // calculateDistanceFacility型に変換
            calculateDistanceFacility compareToDistance = (calculateDistanceFacility)compareTo;
            
            // 距離を比較する
            if (this.distance == compareToDistance.distance){
                return 0;
            } else if (this.distance > compareToDistance.distance){
                return 1;
            } else {
                return -1;
            }
        }
    }

}