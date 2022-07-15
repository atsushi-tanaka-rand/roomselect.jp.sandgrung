/**
 *建物名寄せ比較のコントローラ
 */
public inherited sharing class GD601007Controller {
    //メッセージ
    public String MSG_COM_V_EXECUTE_MERGE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_EXECUTE_MERGE);} private set;}    //js用名寄せ確認メッセージ
    public String MSG_COM_I_MERGE_END {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_MERGE_END);} private set;}    //js用名寄せ完了メッセージ

    //パブリック変数
    public Boolean isOpenError { get; set; }           //エラーフラグ
    public Boolean hasErrorMessage { get; set; }       //エラーメッセージ保有フラグ
    public String transitionId { get; set; }           //画面遷移用建物Id

    //建物リスト
    public Building__c leftBuilding { get; set; }//左
    public Building__c rightBuilding { get; set; }//右

    //建物写真
    public BuildingPhoto__c leftPhoto { get; set; }//左
    public BuildingPhoto__c rightPhoto { get; set; }//右

    //周辺写真リスト
    public ScreenAnyPhotoData leftSurroundingPhoto { get; set; }//左
    public ScreenAnyPhotoData rightSurroundingPhoto { get; set; }//右

    //関連リスト(物件)
    public List<Property__c> leftProList { get; set; }//左
    public List<Property__c> rightProList { get; set; }//右

    //チェックボックス値
    public list<Boolean> leftCheckList { get; set; }
    public list<Boolean> rightCheckList { get; set; }

    //ラジオボタン値
    public String BuildingRadioButton { get; set; }//建物情報セクション
    public String BasicInfoRadioButton { get; set; }//基本情報セクション

    // AmazonS3への接続に使用する情報
    private static String bucketName       { get{return SystemConfig__c.getInstance().S3BucketName__c;}         private set; }   // バケット名


    //プライベート変数
    private String id1;   //物件IDパラメータ
    private String id2;  //物件IDパラメータ
    private Building__c ExchangeRecord;//左右入れ替え用（初期表示の際のみ使う）
    
    /** 定数 */
    private static final String IS_S3FILEMOVE_BATCHPROCESSING = CommonConst.IS_S3FILEMOVE_BATCHPROCESSING; //システム変数　項目名

    //コンストラクタ
    public GD601007Controller() {
        try{
            this.isOpenError = false;
            this.hasErrorMessage = false;
            //店舗異動が取得できなければエラー
            CommonUtil.getStaffCurrentShop();
            //パラメータ取得        
            this.id1 = ApexPages.currentPage().getParameters().get('id1');//建物id1
            this.id2 = ApexPages.currentPage().getParameters().get('id2'); //建物id2
            
            leftBuilding = new Building__c();
            rightBuilding = new Building__c();
            leftProList = new List<Property__c>();
            rightProList = new List<Property__c>();
            leftPhoto = new BuildingPhoto__c();
            rightPhoto = new BuildingPhoto__c();
            leftSurroundingPhoto = new ScreenAnyPhotoData();
            rightSurroundingPhoto = new ScreenAnyPhotoData();

            //チェックボタン初期値
            leftCheckList = new List<Boolean>{false,false,false};
            rightCheckList = new List<Boolean>{false,false,false};


            init();

        }catch(Exception e){
            //エラーを設定
            isOpenError = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    //************************************publicメソッド************************************************************************
    //建物情報ラジオボタン
    public List<SelectOption> getBuildingRadioButtonSetting(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('左', ''));
        options.add(new SelectOption('右', ''));
        return options;
    }
    //基本情報ラジオボタン
    public List<SelectOption> getBasicInfoRadioButtonSetting(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('左', ''));
        options.add(new SelectOption('右', ''));
        return options;
    }

    //保存
    public void save(){

        Savepoint sp = Database.setSavepoint();      //セーブポイント作成
        hasErrorMessage = false;
        try{
            List<String> checkNameList = new List<String>();
            List<String> checkKanaList = new List<String>();            
            List<String> ItemNameList = new List<String>{'Name', 'BuildName2__c', 'BuildName3__c'};
            List<String> ItemKanaList = new List<String>{'BuildKana__c', 'BuildKana2__c', 'BuildKana3__c'};
            
            //チェックボックスチェック
            for(Integer i = 0;i < 3; i++){
                //左1 > 右1 > 左2 > 右2 > 左3 > 右3 の順で建物名を設定
                if (leftCheckList[i] == true) {
                    checkNameList.add((String)leftBuilding.get(ItemNameList[i]));
                    checkKanaList.add((String)leftBuilding.get(ItemKanaList[i]));
                }
                if (rightCheckList[i] == true) {
                    checkNameList.add((String)rightBuilding.get(ItemNameList[i]));
                    checkKanaList.add((String)rightBuilding.get(ItemKanaList[i]));
                }
            }

            BusinessLogicException b = new BusinessLogicException();
            if (checkNameList.size() == 0) {
                //チェックなし
                b.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SELECTION_OR_MORE,'建物名のチェックボックス','1'));
            } else if (checkNameList.size() > 3) {
                //4件以上チェック
                b.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SELECTION_OR_LESS,'建物名のチェックボックス','3'));
            }

            //エラーあり
            if (b.hasMessage()) {
                throw b;
            }

            //楽観ロックチェック
            List<Building__c> leftCheckOptimisticLockExceptionRecord = new List<Building__c>();
            List<Building__c> rightCheckOptimisticLockExceptionRecord = new List<Building__c>();
            leftCheckOptimisticLockExceptionRecord = [ SELECT id
                                                     FROM Building__c
                                                    WHERE id = :leftBuilding.Id
                                                      AND SystemModStamp = :leftBuilding.systemModStamp ];
            rightCheckOptimisticLockExceptionRecord = [ SELECT id
                                                      FROM Building__c
                                                     WHERE id = :rightBuilding.Id
                                                       AND SystemModStamp = :rightBuilding.systemModStamp ];
            
            //どちらかのデータ取得できない場合、楽観ロックチェックExceptionを発行
            if (leftCheckOptimisticLockExceptionRecord.isEmpty() || rightCheckOptimisticLockExceptionRecord.isEmpty()) {
                OptimisticLockException ex = new OptimisticLockException();
                throw ex;
            }
            
            Building__c mergeBuild;//残す建物
            Building__c delBuild;//消す建物
            List<Property__c> orgProList;//変更する物件（残す建物の元々の物件）
            List<Property__c> mergeProList;//変更する物件
            BuildingPhoto__c mergeBuildPhoto;//残す建物

           
            
            //基本情報のチェック側に寄せる
            if(BasicInfoRadioButton=='左'){
                //残す側を左に設定
                mergeBuild = leftBuilding;
                mergeBuildPhoto = leftPhoto;
                orgProList = leftProList;
                mergeProList = rightProList;//残す側を右（寄せる場合、idを左にする）

                //右を消す側に設定（写真は主従関係なので省略）
                delBuild = rightBuilding;
            }else{
                //残す側を右に設定
                mergeBuild = rightBuilding;
                mergeBuildPhoto = rightPhoto;
                orgProList = rightProList;
                mergeProList = leftProList;//残す側を左（寄せる場合、idを右にする）

                //左を消す側に設定（写真は主従関係なので省略）
                delBuild = leftBuilding;
            }

            //更新設定
            mergeBuild.MaintenanceComment__c= mergeBuild.Name +'に'+delBuild.Name +'を名寄せしました。';//メンテナンスコメント
            mergeBuild.MaintenanceType__c =CommonConst.MAINTENANCETYPE_NAMEIDENTIFICATION;//メンテナンス区分
            mergeBuild.MaintenanceStaff__c =UserInfo.getUserid();//メンテナンススタッフ

            //建物名を設定
            mergeBuild.Name = checkNameList[0];
            mergeBuild.BuildKana__c = checkKanaList[0];

            if (checkNameList.size() > 1) {
                //チェック2件以上
                mergeBuild.BuildName2__c = checkNameList[1];
                mergeBuild.BuildKana2__c = checkKanaList[1];
            } else {
                mergeBuild.BuildName2__c = null;
                mergeBuild.BuildKana2__c = null;
            }

            if (checkNameList.size() > 2) {
                //チェック3件
                mergeBuild.BuildName3__c = checkNameList[2];
                mergeBuild.BuildKana3__c = checkKanaList[2];
            } else {
                mergeBuild.BuildName3__c = null;
                mergeBuild.BuildKana3__c = null;
            }

            //基本情報セクションと建物情報の値が違う場合、上書き
            if (BuildingRadioButton != BasicInfoRadioButton){
                //建物情報
                mergeBuild.PostalCode__c = delBuild.PostalCode__c;//郵便番号
                mergeBuild.State__c = delBuild.State__c;//都道府県
                mergeBuild.City__c = delBuild.City__c;//住所１（市区町村）
                mergeBuild.Street__c = delBuild.Street__c;//住所２（番地）
                mergeBuild.District__c = delBuild.District__c;//地区
                mergeBuild.ChoazaCode__c = delBuild.ChoazaCode__c;//町字コード
                mergeBuild.Longitude__c = delBuild.Longitude__c;//経度
                mergeBuild.Latitude__c = delBuild.Latitude__c;//緯度

            }
            //関連リスト(物件, 物件条件)を更新
            if (mergeProList.size() != 0){
                //物件条件の更新（建物を条件に判定する項目群の更新）
                updatePropertyConditionFromBuilding(mergeProList, mergeBuild);

                //物件を残す建物に紐づけ
                for (Property__c pro : mergeProList){
                    pro.Building__c = mergeBuild.id;
                }
                //物件の点数（スーモスコア）を計算し設定
                setMargePropertyScore(mergeProList, mergeBuild, mergeBuildPhoto);
                //物件の名寄せ完了フラグを判定し設定（寄せられる側の物件も合わせて判定）
                mergeProList.addAll(orgProList);
                NameMergeUtil.setPropertyMergeCompletedFlag(mergeProList);
                //物件を更新
                SecureDML.secureUpdate(mergeProList);
            }
            //ポータルサイト構築 追加 Start
            
            //自社権限の取得
            Boolean isOpetionPortal = AuthorityCheckUtil.getAuthorityOptionPortal(false);

            //おすすめ物件名寄せ
            if (isOpetionPortal && mergeProList.size() != 0){//権限がある　かつ　名寄せされる側に物件がある
                //おすすめ物件の写真ファイルパス更新
                updateRecommendProperty(mergeProList, delBuild.ForeignID__c, mergeBuild.ForeignID__c, mergeBuildPhoto);
            }
            //ポータルサイト構築 追加 End
            //名寄せフラグ更新
            if (NameMergeUtil.getBuildingMergeList(mergeBuild,delBuild.Id).size() != 0){
                //リストあり…名寄せフラグfalse
                mergeBuild.IsMergeCompletedFlag__c = false;
            }else{
                //リスト空…名寄せフラグtrue
                mergeBuild.IsMergeCompletedFlag__c = true;
            }

            //削除側の自動メンテナンスレコードを残る側のidに更新
            List<AutoMaintenance__c> autoMaint =[SELECT id FROM AutoMaintenance__c WHERE Building__c = :delBuild.Id];
            if (autoMaint.size() != 0){
                for (AutoMaintenance__c a :autoMaint){
                    a.Building__c = mergeBuild.id;
                }
                SecureDML.secureUpdate(autoMaint);
            }
           
            //更新
            SecureDML.secureUpdate(mergeBuild);

            //画面遷移用の物件Id設定
            this.transitionId = mergeBuild.id;

            // 写真の移動を行う
            PictureMovement(delBuild,mergeBuild,mergeProList);
            
            // 空室予約物件の名寄せ
            this.mergeVacancyReservationProp(mergeBuild.id, delBuild.Id);

            // 建物コード履歴の名寄せ
            this.mergeBuildingCdHist(mergeBuild.id, delBuild.Id);

            //削除
            SecureDML.secureDelete(delBuild);
      
        }catch(Exception e){
            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }

    }

    //************************************privateメソッド************************************************************************
    //初期処理
    private void init(){
        //■建物取得
        selectBuildingInfo(Id1);
        selectBuildingInfo(Id2);

        //■左右の関連リスト取得
        //物件（部屋番号、現状、間取り、専有面積、賃料、写真枚数）
        if (leftBuilding.PropertyBuilding__r.size()!=0){//左
            leftProList=leftBuilding.PropertyBuilding__r; 
        }
        if (rightBuilding.PropertyBuilding__r.size()!=0){//右
            rightProList=rightBuilding.PropertyBuilding__r; 
        }


        //ラジオボタン初期値
        BuildingRadioButton= '左';
        BasicInfoRadioButton= '左';
    }

    //建物取得、左右レコード振り分け
    private void selectBuildingInfo(String buildingId){
        List<Building__c> buildingList = [
                SELECT id,
                    //建物情報
                    Name,//建物名
                    BuildKana__c,//建物名（カナ）
                    BuildName2__c,//建物名2
                    BuildKana2__c,//建物名（カナ）2
                    BuildName3__c,//建物名3
                    BuildKana3__c,//建物名（カナ）3
                    PostalCode__c,//郵便番号
                    State__c,//都道府県
                    City__c,//住所１（市区町村）
                    Street__c,//住所２（番地）
                    Address__c,//住所
                    District__c,//地区
                    ChoazaCode__c,//町字コード
                    Longitude__c,//経度
                    Latitude__c,//緯度
                    ForeignID__c,//外部ID
                    //基本情報
                    BuildingPhotoCount__c,//建物写真枚数
                    PropertyType__c,//物件種別
                    Structure__c,//建物構造
                    BuildingYM__c,//築年月
                    GroundFloorCount__c,//地上階数
                    UndergroundFloorCount__c,//地下階数
                    HouseCount__c,//棟総戸数
                    CaretakerType__c,//管理人種別
                    BuildingRemarksPublic__c,//建物備考（公開）	
                    //学校情報
                    PrimarySchool1__r.Name,//小学校１
                    PrimarySchool2__r.Name,//小学校２
                    PrimarySchool3__r.Name,//小学校３
                    PrimarySchoolDistance1__c,//小学校までの距離１
                    PrimarySchoolDistance2__c,//小学校までの距離２
                    PrimarySchoolDistance3__c,//小学校までの距離３
                    PrimarySchoolWalkTime1__c,//小学校までの時間（分）１
                    PrimarySchoolWalkTime2__c,//小学校までの時間（分）２
                    PrimarySchoolWalkTime3__c,//小学校までの時間（分）３
                    PrimarySchool1__r.PhotoFileName__c,//小学校１写真ファイル名
                    PrimarySchool2__r.PhotoFileName__c,//小学校２写真ファイル名
                    PrimarySchool3__r.PhotoFileName__c,//小学校３写真ファイル名
                    JuniorHighSchool1__r.Name,//中学校１
                    JuniorHighSchool2__r.Name,//中学校２
                    JuniorHighSchool3__r.Name,//中学校３
                    JuniorHighSchoolDistance1__c,//中学校までの距離１
                    JuniorHighSchoolDistance2__c,//中学校までの距離２
                    JuniorHighSchoolDistance3__c,//中学校までの距離３
                    JuniorHighSchoolWalkTime1__c,//中学校までの時間（分）１
                    JuniorHighSchoolWalkTime2__c,//中学校までの時間（分）２
                    JuniorHighSchoolWalkTime3__c,//中学校までの時間（分）３
                    JuniorHighSchool1__r.PhotoFileName__c,//中学校１写真ファイル名
                    JuniorHighSchool2__r.PhotoFileName__c,//中学校２写真ファイル名
                    JuniorHighSchool3__r.PhotoFileName__c,//中学校３写真ファイル名
                    HighSchool__r.Name,//高校
                    HighSchoolDistance__c,//高校までの距離
                    HighSchoolWalkTime__c,//高校までの時間（分）
                    HighSchool__r.PhotoFileName__c,//高校写真ファイル名
                    University__r.Name,//大学
                    UniversityDistance__c,//大学までの距離
                    UniversityWalkTime__c,//大学までの時間（分）
                    University__r.PhotoFileName__c,//大学写真ファイル名
                    //周辺施設
                    ConvenienceStore__r.Name,//コンビニ
                    ConvenienceStoreDistance__c,//コンビニまでの距離
                    ConvenienceStoreWalkTime__c,//コンビニまでの時間（分）
                    ConvenienceStore__r.PhotoFileName__c,//コンビニ写真ファイル名
                    Supermarket__r.Name,//スーパーマーケット
                    SupermarketDistance__c,//スーパーマーケットまでの距離
                    SupermarketWalkTime__c,//スーパーマーケットまでの時間（分）
                    Supermarket__r.PhotoFileName__c,//スーパーマーケット写真ファイル名
                    GeneralHospital__r.Name,//総合病院
                    GeneralHospitalDistance__c,//総合病院までの距離
                    GeneralHospitalWalkTime__c,//総合病院までの時間（分）
                    GeneralHospital__r.PhotoFileName__c,//総合病院写真ファイル名
                    //路線情報
                    TrainRoute1__r.Name,//沿線１
                    TrainRoute2__r.Name,//沿線２
                    TrainRoute3__r.Name,//沿線３
                    Station1__r.Name,//駅１
                    Station2__r.Name,//駅２
                    Station3__r.Name,//駅３
                    StationDistance1__c,//駅までの距離１
                    StationDistance2__c,//駅までの距離２
                    StationDistance3__c,//駅までの距離３
                    StationWalkTime1__c,//駅までの時間（分）１
                    StationWalkTime2__c,//駅までの時間（分）２
                    StationWalkTime3__c,//駅までの時間（分）３
                    BusRoute1__c,//バス路線名１
                    BusRoute2__c,//バス路線名２
                    BusRoute3__c,//バス路線名３
                    BusStop1__c,//バス停１
                    BusStop2__c,//バス停２
                    BusStop3__c,//バス停３
                    BusStopDistance1__c,//バス停までの距離１
                    BusStopDistance2__c,//バス停までの距離２
                    BusStopDistance3__c,//バス停までの距離３
                    BusStopWalkTime1__c,//バス停までの時間（分）１
                    BusStopWalkTime2__c,//バス停までの時間（分）２
                    BusStopWalkTime3__c,//バス停までの時間（分）３
                    BusRideTime1__c,//バス乗車時間（分）１
                    BusRideTime2__c,//バス乗車時間（分）２
                    BusRideTime3__c,//バス乗車時間（分）３
                    BusStopToStationDistance1__c,//バス停からの距離１
                    BusStopToStationDistance2__c,//バス停からの距離２
                    BusStopToStationDistance3__c,//バス停からの距離３
                    BusStopToStationWalkTime1__c,//バス停からの時間（分）１
                    BusStopToStationWalkTime2__c,//バス停からの時間（分）２
                    BusStopToStationWalkTime3__c,//バス停からの時間（分）３
                    //メンテナンス情報
                    MaintenanceBuildingCode__c,//メンテナンス建物コード
                    ImportType__c,//取込区分

                    //写真
                    (SELECT Id,
                            AppearanceFilePath__c,//建物外観
                            AppearanceFileName__c,//建物外観写真ファイル名
                            AppearanceComment__c,//建物外観コメント
                            AppearanceParseFilePath__c,//外観パース
                            AppearanceParseFileName__c,//外観パース写真ファイル名
                            AppearanceParseComment__c,//外観パースコメント
                            EntranceFilePath__c,//エントランス
                            EntranceFileName__c,//エントランス写真ファイル名
                            EntranceComment__c,//エントランスコメント
                            LobbyFilePath__c,//ロビー
                            LobbyFileName__c,//ロビー写真ファイル名
                            LobbyComment__c,//ロビーコメント
                            ParkingFilePath__c,//駐車場
                            ParkingFileName__c,//駐車場写真ファイル名
                            ParkingComment__c,//駐車場コメント
                            OtherSharingFilePath__c,//その他共有
                            OtherSharingFileName__c,//その他共有写真ファイル名
                            OtherSharingComment__c,//その他共有コメント
                            MapFilePath__c,//地図
                            MapFileName__c,//地図写真ファイル名
                            MapComment__c,//地図コメント
                            OtherFilePath__c,//その他
                            OtherFileName__c,//その他写真ファイル名
                            OtherComment__c,//その他コメント
                            SurroundingFilePath1__c,//周辺写真１
                            SurroundingFileName1__c,//周辺写真ファイル名１
                            SurroundingTag1__c,//周辺写真タグ１
                            SurroundingPhotoName1__c,//周辺写真名１
                            SurroundingComment1__c,//周辺写真ファイルコメント１
                            SurroundingDistance1__c,//周辺写真までの距離１
                            SurroundingFilePath2__c,//周辺写真２
                            SurroundingFileName2__c,//周辺写真ファイル名２
                            SurroundingTag2__c,//周辺写真タグ２
                            SurroundingPhotoName2__c,//周辺写真名２
                            SurroundingComment2__c,//周辺写真ファイルコメント２
                            SurroundingDistance2__c,//周辺写真までの距離２
                            SurroundingFilePath3__c,//周辺写真３
                            SurroundingFileName3__c,//周辺写真ファイル名３
                            SurroundingTag3__c,//周辺写真タグ３
                            SurroundingPhotoName3__c,//周辺写真名３
                            SurroundingComment3__c,//周辺写真ファイルコメント３
                            SurroundingDistance3__c,//周辺写真までの距離３
                            SurroundingFilePath4__c,//周辺写真４
                            SurroundingFileName4__c,//周辺写真ファイル名４
                            SurroundingTag4__c,//周辺写真タグ４
                            SurroundingPhotoName4__c,//周辺写真名４
                            SurroundingComment4__c,//周辺写真ファイルコメント４
                            SurroundingDistance4__c,//周辺写真までの距離４
                            SurroundingFilePath5__c,//周辺写真５
                            SurroundingFileName5__c,//周辺写真ファイル名５
                            SurroundingTag5__c,//周辺写真タグ５
                            SurroundingPhotoName5__c,//周辺写真名５
                            SurroundingComment5__c,//周辺写真ファイルコメント５
                            SurroundingDistance5__c,//周辺写真までの距離５
                            PhotoCount__c//写真枚数
                    FROM BuildingPhotoBuilding__r LIMIT 1),

                    //物件
                    (SELECT Id,
                            //ポータルサイト構築 追加 Start
                            PropertyCode__c,
                            //ポータルサイト構築 追加 End                    
                            Name,//部屋番号
                            LiveStatus__c,//現況
                            RoomLayout__c,//間取り
                            RoomArea__c,//専有面積（㎡）
                            RentFee__c,//賃料
                            PhotoCount__c,//写真枚数
                            FloorType__c,//地下階区分
                            Floor__c,//所在階
                            SuumoNetCatch__c,//SUUMOネット用キャッチ
                            SuumoNetCatchComment__c,//SUUMOネット用キャッチコメント
                            Building__c
                    FROM PropertyBuilding__r),
                    CreatedDate,
                    SystemModstamp  
                FROM Building__c 
                WHERE Id = :buildingId
        ];
        //レコード情報が取得できなければビジネスロジックException発行
        if( buildingList.size()==0 ){
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
            throw ex;
        }

        //★取得1回目の場合、ExchangeListに入れる
        if (ExchangeRecord == null){
            ExchangeRecord = buildingList[0].clone(true,false,true);

        //★取得2回目の場合、どちらが古いかを比較し、左右のレコードに振り分けと、写真リストを取得。
        }else{
            //1回目のレコードが2回目より古い場合、1回目が左、2回目が右のレコードに入る
            if(ExchangeRecord.CreatedDate < buildingList[0].CreatedDate){
                leftBuilding = ExchangeRecord.clone(true,false,true);
                rightBuilding = buildingList[0].clone(true,false,true);
                
            //2回目のレコードが1回目より古い場合、2回目が左、1回目が右のレコードに入る
            }else{
                leftBuilding = buildingList[0].clone(true,false,true);
                rightBuilding = ExchangeRecord.clone(true,false,true);
            }

            Integer leftPhotoCount = 0;
            Integer rightPhotoCount = 0;

            //★写真の取得
            if (leftBuilding.BuildingPhotoBuilding__r.size()!=0){
                if (leftBuilding.BuildingPhotoBuilding__r[0].PhotoCount__c!=0){
                    //左の建物写真
                    leftPhoto = leftBuilding.BuildingPhotoBuilding__r[0];
                    leftSurroundingPhoto = new ScreenAnyPhotoData(leftBuilding.BuildingPhotoBuilding__r[0]);
                    leftPhotoCount = leftSurroundingPhoto.photoCount;
                }
            }
            if (rightBuilding.BuildingPhotoBuilding__r.size()!=0){
                if (rightBuilding.BuildingPhotoBuilding__r[0].PhotoCount__c!=0){
                    //右の建物写真
                    rightPhoto = rightBuilding.BuildingPhotoBuilding__r[0];
                    rightSurroundingPhoto = new ScreenAnyPhotoData(rightBuilding.BuildingPhotoBuilding__r[0]);
                    rightPhotoCount = rightSurroundingPhoto.photoCount;
                }
            }
            //周辺写真枚数を多い方と同じ枚数にする
            matchPhotoCount(leftPhotoCount,rightPhotoCount);
        }
    }

    //写真枚数多い方と同じ枚数にする(左物件の写真枚数、右の写真枚数)
    private void matchPhotoCount(Integer left,Integer right){
        //左>右
        if(left > right){         
            for(Integer i=0 ;i < left - right ;i++){
                rightSurroundingPhoto.photoDataList.add(new PhotoData());
                rightSurroundingPhoto.PhotoCount = left;
            }
        //右>左
        }else if(right > left){
            for(Integer i=0 ;i < right - left ;i++){
                leftSurroundingPhoto.photoDataList.add(new PhotoData());
                leftSurroundingPhoto.PhotoCount = right;
            }
        }
    }

    //物件の点数（スーモスコア）を計算し設定
    private void setMargePropertyScore(List<Property__c> propList, Building__c build, BuildingPhoto__c buildPhoto) {
        // 処理対象の物件Id取得
        List<Id> propIsList = new List<Id>();
        for (Property__c prop : propList) {
            propIsList.add(prop.Id);
        }
        // 物件写真情報取得
        List<PropertyPhoto__c> propPhotoList = selectPropertyPhotoList(propIsList);
        Map<Id, PropertyPhoto__c> propPhotoMap = new Map<Id, PropertyPhoto__c>();
        for (PropertyPhoto__c propPhoto :propPhotoList){
            propPhotoMap.put(propPhoto.Property__c, propPhoto);
        }
        // スーモスコア再計算
        for (Property__c prop : propList) {
            prop.Score__c = BuildingPropertyUtil.getSuumoScore(build, buildPhoto, prop, propPhotoMap.get(prop.Id), true);
        }
    }

    // 物件写真情報取得（スーモスコア計算に使用）
    private List<PropertyPhoto__c> selectPropertyPhotoList(List<Id> targetPropIdList) {
        String sql = '';
        sql += 'SELECT Id ';
        sql += '      ,Property__c ';
        for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PROPERTY; i++) { // 物件写真
        sql += '      ,PropertyPhotoFileName' + i + '__c ';
        sql += '      ,PropertyPhotoFilePath' + i + '__c ';
        sql += '      ,PropertyPhotoTag' + i + '__c ';
        sql += '      ,PropertyPhotoComment' + i + '__c ';
        }
        for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PRIVATE; i++) {  // 物件非公開
        sql += '      ,PrivatePhotoFileName' + i + '__c ';
        sql += '      ,PrivatePhotoFilePath' + i + '__c ';
        sql += '      ,PrivatePhotoType' + i + '__c ';
        sql += '      ,PrivatePhotoComment' + i + '__c ';
        }
        for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PANORAMA; i++) { // 物件パノラマ
        sql += '      ,PanoramaFileName' + i + '__c ';
        sql += '      ,PanoramaFilePath' + i + '__c ';
        sql += '      ,PanoramaTag' + i + '__c ';
        sql += '      ,PanoramaComment' + i + '__c ';
        }
        sql += '      ,RoomLayoutFileName__c ';                     // 物件間取り図
        sql += '      ,RoomLayoutFilePath__c ';
        sql += '      ,RoomLayoutMemoFileName__c ';                 // 物件間取り図（メモ有）
        sql += '      ,RoomLayoutMemoFilePath__c ';
        sql += '  FROM PropertyPhoto__c ';
        sql += ' WHERE Property__c IN :targetPropIdList ';
        List<PropertyPhoto__c> propertyPhotoList = Database.query(sql);
        if (propertyPhotoList.isEmpty()){
            propertyPhotoList = new List<PropertyPhoto__c>();
        }
        return propertyPhotoList;
    }

    //物件条件の建物を条件に判定する項目群の更新
    private void updatePropertyConditionFromBuilding(List<Property__c> propList, Building__c build) {
        // 処理対象の物件Id取得
        List<Id> propIsList = new List<Id>();
        for (Property__c prop : propList) {
            propIsList.add(prop.Id);
        }

        // 物件条件取得
        List<PropertyConditions__c> propCondList = [
            SELECT
                Id
                ,Property__c
                ,IsTwoStation__c        // 2駅利用可
                ,IsTwoTrainRoute__c     // 2沿線利用可
                ,IsThreeStation__c      // 3駅以上利用可
                ,IsThreeTrainRoute__c   // 3沿線以上利用可
                ,IsFrontStation__c      // 駅前
                ,IsTopFloor__c          // 最上階
                ,IsJanitor__c           // 管理人有
                ,IsJanitorReside__c     // 管理人(常駐)
                ,IsJanitorCommuter__c   // 管理人(通勤)
                ,IsJanitorPatrol__c     // 管理人(巡回)
            FROM PropertyConditions__c
            WHERE
                Property__c IN :propIsList
        ];
        if (propCondList.size() == 0) {
            return;
        }
        Map<Id, PropertyConditions__c> propCondMap = new Map<Id, PropertyConditions__c>();
        for (PropertyConditions__c propCond :propCondList){
            propCondMap.put(propCond.Property__c, propCond);
        }
        // 物件条件の自動判定項目値の設定
        // 駅カウント
        Integer StationCount = 0;
        StationCount += String.isEmpty(build.Station1__c) ? 0 : 1;
        StationCount += String.isEmpty(build.Station2__c) ? 0 : 1;
        StationCount += String.isEmpty(build.Station3__c) ? 0 : 1;
        // 沿線カウント（種類カウント）
        Integer TrainRouteCount = 0;
        TrainRouteCount += String.isEmpty(build.TrainRoute1__c) ? 0 : 1;
        if (!String.isEmpty(build.TrainRoute2__c)
            && build.TrainRoute2__c != build.TrainRoute1__c) {
            TrainRouteCount += 1;
        }
        if (!String.isEmpty(build.TrainRoute3__c)
            && build.TrainRoute3__c != build.TrainRoute1__c
            && build.TrainRoute3__c != build.TrainRoute2__c) {
                TrainRouteCount += 1;
            }
        // ２駅利用可, ３駅利用可 判定
        Boolean isTwoStation = false;
        Boolean isThreeStation = false;
        if (StationCount == 3) {
            // 駅数3は ２駅利用可, ３駅利用可をTrue
            isTwoStation = true;
            isThreeStation = true;
        } else if (StationCount == 2) {
            // 駅数2は ２駅利用可をTrue
            isTwoStation = true;
        }
        // ２沿線利用可, ３沿線利用可 判定
        Boolean isTwoTrainRoute = false;
        Boolean isThreeTrainRoute = false;
        if (TrainRouteCount == 3) {
            // 駅数3は ２沿線利用可, ３沿線利用可をTrue
            isTwoTrainRoute = true;
            isThreeTrainRoute = true;
        } else if (TrainRouteCount == 2) {
            // 駅数2は ２沿線利用可をTrue
            isTwoTrainRoute = true;
        }
        // 駅前 判定
        Boolean isFrontStation = false;
        if (build.StationWalkTime1__c <= 1
            || build.StationWalkTime2__c <= 1
            || build.StationWalkTime3__c <= 1) {
            // 駅までの時間 1分以下ありでTrue
            isFrontStation = true;
        }
        // 管理人関連 判定
        Boolean isJanitor           = false;    // 管理人あり
        Boolean isJanitorReside     = false;    // 管理人(常駐)
        Boolean isJanitorCommuter   = false;    // 管理人(通勤)
        Boolean isJanitorPatrol     = false;    // 管理人(巡回)
        if (build.CaretakerType__c == CommonConst.BUILDING_CARETAKERTYPE_RESIDE) {
            // 管理人種別「常駐」は 管理人あり, 管理人(常駐)をtrue
            isJanitor = true;           // 管理人あり
            isJanitorReside = true;     // 管理人(常駐)
        } else if (build.CaretakerType__c == CommonConst.BUILDING_CARETAKERTYPE_NORESIDE) {
            // 管理人種別「非常駐」は 管理人ありをtrue
            isJanitor = true;           // 管理人あり
        } else if (build.CaretakerType__c == CommonConst.BUILDING_CARETAKERTYPE_PATROL) {
            // 管理人種別「巡回方式」は 管理人あり, 管理人(巡回)をtrue
            isJanitor = true;           // 管理人あり
            isJanitorPatrol = true;     // 管理人(巡回)
        } else if (build.CaretakerType__c == CommonConst.BUILDING_CARETAKERTYPE_COMMUTER) {
            // 管理人種別「通勤方式」は 管理人あり, 管理人(通勤)をtrue
            isJanitor = true;           // 管理人あり
            isJanitorCommuter = true;   // 管理人(通勤)
        }

        // 判定値設定
        for (Property__c prop : propList) {
            if (propCondMap.containsKey(prop.Id)) {
                PropertyConditions__c propCond = propCondMap.get(prop.Id);
                propCond.IsTwoStation__c        = isTwoStation;
                propCond.IsThreeStation__c      = isThreeStation;
                propCond.IsTwoTrainRoute__c     = isTwoTrainRoute;
                propCond.IsThreeTrainRoute__c   = isThreeTrainRoute;
                propCond.IsFrontStation__c      = isFrontStation;
                propCond.IsJanitor__c           = isJanitor;
                propCond.IsJanitorReside__c     = isJanitorReside;
                propCond.IsJanitorCommuter__c   = isJanitorCommuter;
                propCond.IsJanitorPatrol__c     = isJanitorPatrol;
                // 最上階 判定
                propCond.IsTopFloor__c          = false;
                if (prop.FloorType__c == CommonConst.PROPERTY_FLOORTYPE_GROUND) {
                    if (prop.Floor__c == build.GroundFloorCount__c) {
                        // 地下階区分「地上」かつ所在階=地上階数は 最上階 true
                        propCond.IsTopFloor__c  = true;
                    }
                }
                propCondMap.put(prop.Id, propCond);
            }
        }
        // 物件条件更新
        SecureDML.secureUpdate(propCondMap.values());
    }

    //ポータルサイト構築 追加 Start
    //おすすめ物件ファイルパス更新
    private void updateRecommendProperty(List<Property__c> proList, String builForeignID, String mergeBuilForeignID, BuildingPhoto__c buildPhoto) {
        // 処理対象の物件コード取得
        Set<String> proCodeSet = new Set<String>();
        for (Property__c prop : proList) {
            proCodeSet.add(prop.PropertyCode__c);
        }

        // 消える物件に紐づくおすすめ物件取得
        List<RecommendProperty__c> recoProList = [
            SELECT
                Id,
                PhotoFilePath__c            //写真ファイルパス
            FROM RecommendProperty__c
            WHERE
                PropertyCode__c IN :proCodeSet
        ];

        //おすすめ物件が空だったら処理を行わない
        if (recoProList.size() == 0) {
            return;
        }

        //更新用おすすめ物件
        List<RecommendProperty__c> updateRecoProList = new List<RecommendProperty__c>();
        for (RecommendProperty__c recoPro : recoProList){
            //写真ファイルパスに値がある
            if (String.isNotBlank(recoPro.PhotoFilePath__c) ){

                //残る方の建物外観・エントランス・ロビーの写真とファイル名に変更（写真ファイルパスが建物写真）
                if (recoPro.PhotoFilePath__c.contains(CommonConst.S3_BUILDINGPHOTOTYPE_APPEARANCE)){
                    //外観写真
                    recoPro.PhotoFilePath__c = String.isBlank(buildPhoto.AppearanceFilePath__c) ? '' : buildPhoto.AppearanceFilePath__c;
                    recoPro.PhotoFileName__c = String.isBlank(buildPhoto.AppearanceFileName__c) ? '' : buildPhoto.AppearanceFileName__c;
                    updateRecoProList.add(recoPro);

                }else if (recoPro.PhotoFilePath__c.contains(CommonConst.S3_BUILDINGPHOTOTYPE_ENTRANCE)){
                    //エントランス
                    recoPro.PhotoFilePath__c = String.isBlank(buildPhoto.EntranceFilePath__c) ? '' : buildPhoto.EntranceFilePath__c;
                    recoPro.PhotoFileName__c = String.isBlank(buildPhoto.EntranceFileName__c) ? '' : buildPhoto.EntranceFileName__c;
                    updateRecoProList.add(recoPro);
                    
                }else if (recoPro.PhotoFilePath__c.contains(CommonConst.S3_BUILDINGPHOTOTYPE_LOBBY)){
                    //ロビー
                    recoPro.PhotoFilePath__c = String.isBlank(buildPhoto.LobbyFilePath__c) ? '' : buildPhoto.LobbyFilePath__c;
                    recoPro.PhotoFileName__c = String.isBlank(buildPhoto.LobbyFileName__c) ? '' : buildPhoto.LobbyFileName__c;
                    updateRecoProList.add(recoPro);
                
                //消える建物外部IDが含まれている（写真ファイルパスが物件写真）
                }else if (recoPro.PhotoFilePath__c.contains(builForeignID)){

                    //おすすめ物件の写真ファイルパスの建物外部ID箇所を、残す側の建物外部IDに置換
                    recoPro.PhotoFilePath__c = recoPro.PhotoFilePath__c.replace(builForeignID, mergeBuilForeignID);
                    updateRecoProList.add(recoPro);
                }
            }
        }
        
        // おすすめ物件更新
        if (! updateRecoProList.isEmpty()){
            SecureDML.secureUpdate(updateRecoProList);
        }
    }
    //ポータルサイト構築 追加 End

    // 写真の移動を行う
    private void PictureMovement(Building__c delBuilding,Building__c mergeBuilding, List<Property__c> mergeProList){


        List<S3FileMove__c> S3FileMoveList = new List<S3FileMove__c>();  

        // IdのSetをキーにして、物件写真レコードをSELECTする
        
        if(mergeProList.size() > 0 ){
            List<PropertyPhoto__c> delPropertyPhotoList =[ SELECT id
                                                            ,PropertyPhotoFilePath1__c
                                                            ,PropertyPhotoFilePath2__c
                                                            ,PropertyPhotoFilePath3__c
                                                            ,PropertyPhotoFilePath4__c
                                                            ,PropertyPhotoFilePath5__c
                                                            ,PropertyPhotoFilePath6__c
                                                            ,PropertyPhotoFilePath7__c
                                                            ,PropertyPhotoFilePath8__c
                                                            ,PropertyPhotoFilePath9__c
                                                            ,PropertyPhotoFilePath10__c
                                                            ,PropertyPhotoFilePath11__c
                                                            ,PropertyPhotoFilePath12__c
                                                            ,PropertyPhotoFilePath13__c
                                                            ,PropertyPhotoFilePath14__c
                                                            ,PropertyPhotoFilePath15__c
                                                            ,PropertyPhotoFilePath16__c
                                                            ,PropertyPhotoFilePath17__c
                                                            ,PropertyPhotoFilePath18__c
                                                            ,PropertyPhotoFilePath19__c
                                                            ,PropertyPhotoFilePath20__c      
                                                            ,RoomLayoutFilePath__c	
                                                            ,RoomLayoutMemoFilePath__c
                                                            ,PanoramaFilePath1__c	
                                                            ,PanoramaFilePath2__c	
                                                            ,PanoramaFilePath3__c	
                                                            ,PanoramaFilePath4__c	
                                                            ,PanoramaFilePath5__c	
                                                            ,PrivatePhotoFilePath1__c
                                                            ,PrivatePhotoFilePath2__c
                                                            ,PrivatePhotoFilePath3__c
                                                            ,PrivatePhotoFilePath4__c
                                                            ,PrivatePhotoFilePath5__c
                                                            ,PrivatePhotoFilePath6__c
                                                            ,PrivatePhotoFilePath7__c
                                                            ,PrivatePhotoFilePath8__c
                                                        FROM PropertyPhoto__c
                                                        WHERE Property__c IN :mergeProList];

            // 物件写真レコードを回して、パスが入っていれば、以下のことを行う
            for(PropertyPhoto__c delPropertyPhoto : delPropertyPhotoList){
                // 変更前のパスと、変更後のパスを入れた、S3ファイル移動レコードを、insertListに追加する
               
                // 物件写真ファイルパス１
                if (String.isnotBlank(delPropertyPhoto.PropertyPhotoFilePath1__c)){
                    S3FileMove__c S3FileMove = saveS3FileMove(delPropertyPhoto.PropertyPhotoFilePath1__c,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                    S3FileMoveList.add(S3FileMove);
                }
                // 物件写真ファイルパス２
                if (String.isnotBlank(delPropertyPhoto.PropertyPhotoFilePath2__c)){
                    S3FileMove__c S3FileMove = saveS3FileMove(delPropertyPhoto.PropertyPhotoFilePath2__c,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                    S3FileMoveList.add(S3FileMove);
                }
                // 物件写真ファイルパス３
                if (String.isnotBlank(delPropertyPhoto.PropertyPhotoFilePath3__c)){
                    S3FileMove__c S3FileMove = saveS3FileMove(delPropertyPhoto.PropertyPhotoFilePath3__c,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                    S3FileMoveList.add(S3FileMove);
                }
                // 物件写真ファイルパス４
                if (String.isnotBlank(delPropertyPhoto.PropertyPhotoFilePath4__c)){
                    S3FileMove__c S3FileMove = saveS3FileMove(delPropertyPhoto.PropertyPhotoFilePath4__c,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                    S3FileMoveList.add(S3FileMove);
                }
                // 物件写真ファイルパス５
                if (String.isnotBlank(delPropertyPhoto.PropertyPhotoFilePath5__c)){
                    S3FileMove__c S3FileMove = saveS3FileMove(delPropertyPhoto.PropertyPhotoFilePath5__c,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                    S3FileMoveList.add(S3FileMove);
                }
                // 物件写真ファイルパス６
                if (String.isnotBlank(delPropertyPhoto.PropertyPhotoFilePath6__c)){
                    S3FileMove__c S3FileMove = saveS3FileMove(delPropertyPhoto.PropertyPhotoFilePath6__c,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                    S3FileMoveList.add(S3FileMove);
                }
                // 物件写真ファイルパス７
                if (String.isnotBlank(delPropertyPhoto.PropertyPhotoFilePath7__c)){
                    S3FileMove__c S3FileMove = saveS3FileMove(delPropertyPhoto.PropertyPhotoFilePath7__c,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                    S3FileMoveList.add(S3FileMove);
                }
                // 物件写真ファイルパス８
                if (String.isnotBlank(delPropertyPhoto.PropertyPhotoFilePath8__c)){
                    S3FileMove__c S3FileMove = saveS3FileMove(delPropertyPhoto.PropertyPhotoFilePath8__c,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                    S3FileMoveList.add(S3FileMove);
                }
                // 物件写真ファイルパス９
                if (String.isnotBlank(delPropertyPhoto.PropertyPhotoFilePath9__c)){
                    S3FileMove__c S3FileMove = saveS3FileMove(delPropertyPhoto.PropertyPhotoFilePath9__c,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                    S3FileMoveList.add(S3FileMove);
                }
                // 物件写真ファイルパス１０
                if (String.isnotBlank(delPropertyPhoto.PropertyPhotoFilePath10__c)){
                    S3FileMove__c S3FileMove = saveS3FileMove(delPropertyPhoto.PropertyPhotoFilePath10__c,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                    S3FileMoveList.add(S3FileMove);
                }
                // 物件写真ファイルパス１１
                if (String.isnotBlank(delPropertyPhoto.PropertyPhotoFilePath11__c)){
                    S3FileMove__c S3FileMove = saveS3FileMove(delPropertyPhoto.PropertyPhotoFilePath11__c,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                    S3FileMoveList.add(S3FileMove);
                }
                // 物件写真ファイルパス１２
                if (String.isnotBlank(delPropertyPhoto.PropertyPhotoFilePath12__c)){
                    S3FileMove__c S3FileMove = saveS3FileMove(delPropertyPhoto.PropertyPhotoFilePath12__c,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                    S3FileMoveList.add(S3FileMove);
                }
                // 物件写真ファイルパス１３
                if (String.isnotBlank(delPropertyPhoto.PropertyPhotoFilePath13__c)){
                    S3FileMove__c S3FileMove = saveS3FileMove(delPropertyPhoto.PropertyPhotoFilePath13__c,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                    S3FileMoveList.add(S3FileMove);
                }
                // 物件写真ファイルパス１４
                if (String.isnotBlank(delPropertyPhoto.PropertyPhotoFilePath14__c)){
                    S3FileMove__c S3FileMove = saveS3FileMove(delPropertyPhoto.PropertyPhotoFilePath14__c,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                    S3FileMoveList.add(S3FileMove);
                }
                // 物件写真ファイルパス１５
                if (String.isnotBlank(delPropertyPhoto.PropertyPhotoFilePath15__c)){
                    S3FileMove__c S3FileMove = saveS3FileMove(delPropertyPhoto.PropertyPhotoFilePath15__c,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                    S3FileMoveList.add(S3FileMove);
                }
                // 物件写真ファイルパス１６
                if (String.isnotBlank(delPropertyPhoto.PropertyPhotoFilePath16__c)){
                    S3FileMove__c S3FileMove = saveS3FileMove(delPropertyPhoto.PropertyPhotoFilePath16__c,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                    S3FileMoveList.add(S3FileMove);
                }
                // 物件写真ファイルパス１７
                if (String.isnotBlank(delPropertyPhoto.PropertyPhotoFilePath17__c)){
                    S3FileMove__c S3FileMove = saveS3FileMove(delPropertyPhoto.PropertyPhotoFilePath17__c,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                    S3FileMoveList.add(S3FileMove);
                }
                // 物件写真ファイルパス１８
                if (String.isnotBlank(delPropertyPhoto.PropertyPhotoFilePath18__c)){
                    S3FileMove__c S3FileMove = saveS3FileMove(delPropertyPhoto.PropertyPhotoFilePath18__c,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                    S3FileMoveList.add(S3FileMove);
                }
                // 物件写真ファイルパス１９
                if (String.isnotBlank(delPropertyPhoto.PropertyPhotoFilePath19__c)){
                    S3FileMove__c S3FileMove = saveS3FileMove(delPropertyPhoto.PropertyPhotoFilePath19__c,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                    S3FileMoveList.add(S3FileMove);
                }
                // 物件写真ファイルパス２０
                if (String.isnotBlank(delPropertyPhoto.PropertyPhotoFilePath20__c)){
                    S3FileMove__c S3FileMove = saveS3FileMove(delPropertyPhoto.PropertyPhotoFilePath20__c,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                    S3FileMoveList.add(S3FileMove);
                }

                // 間取り図ファイルパス
                if (String.isnotBlank(delPropertyPhoto.RoomLayoutFilePath__c)){
                    S3FileMove__c S3FileMove = saveS3FileMove(delPropertyPhoto.RoomLayoutFilePath__c,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                    S3FileMoveList.add(S3FileMove);

                    // 間取り図位置情報ファイルを移動するデータを作成する。
                    String jsonFilePath = AmazonS3Util.extensionConvertJson(delPropertyPhoto.RoomLayoutFilePath__c); 
                    if(String.isnotBlank(jsonFilePath)){
                        S3FileMove = saveS3FileMove(jsonFilePath,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                        S3FileMoveList.add(S3FileMove);
                    }
                }
                // 間取り図メモファイルパス
                if (String.isnotBlank(delPropertyPhoto.RoomLayoutMemoFilePath__c)){
                    S3FileMove__c S3FileMove = saveS3FileMove(delPropertyPhoto.RoomLayoutMemoFilePath__c,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                    S3FileMoveList.add(S3FileMove);
                }
                // パノラマファイルパス１
                if (String.isnotBlank(delPropertyPhoto.PanoramaFilePath1__c)){
                    S3FileMove__c S3FileMove = saveS3FileMove(delPropertyPhoto.PanoramaFilePath1__c,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                    S3FileMoveList.add(S3FileMove);
                }
                // パノラマファイルパス２
                if (String.isnotBlank(delPropertyPhoto.PanoramaFilePath2__c)){
                    S3FileMove__c S3FileMove = saveS3FileMove(delPropertyPhoto.PanoramaFilePath2__c,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                    S3FileMoveList.add(S3FileMove);
                }
                // パノラマファイルパス３
                if (String.isnotBlank(delPropertyPhoto.PanoramaFilePath3__c)){
                    S3FileMove__c S3FileMove = saveS3FileMove(delPropertyPhoto.PanoramaFilePath3__c,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                    S3FileMoveList.add(S3FileMove);
                }
                // パノラマファイルパス４
                if (String.isnotBlank(delPropertyPhoto.PanoramaFilePath4__c)){
                    S3FileMove__c S3FileMove = saveS3FileMove(delPropertyPhoto.PanoramaFilePath4__c,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                    S3FileMoveList.add(S3FileMove);
                }
                // パノラマファイルパス５
                if (String.isnotBlank(delPropertyPhoto.PanoramaFilePath5__c)){
                    S3FileMove__c S3FileMove = saveS3FileMove(delPropertyPhoto.PanoramaFilePath5__c,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                    S3FileMoveList.add(S3FileMove);
                }

                // 非公開写真ファイルパス１
                if (String.isnotBlank(delPropertyPhoto.PrivatePhotoFilePath1__c)){
                    S3FileMove__c S3FileMove = saveS3FileMove(delPropertyPhoto.PrivatePhotoFilePath1__c,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                    S3FileMoveList.add(S3FileMove);
                }
                // 非公開写真ファイルパス２
                if (String.isnotBlank(delPropertyPhoto.PrivatePhotoFilePath2__c)){
                    S3FileMove__c S3FileMove = saveS3FileMove(delPropertyPhoto.PrivatePhotoFilePath2__c,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                    S3FileMoveList.add(S3FileMove);
                }
                // 非公開写真ファイルパス３
                if (String.isnotBlank(delPropertyPhoto.PrivatePhotoFilePath3__c)){
                    S3FileMove__c S3FileMove = saveS3FileMove(delPropertyPhoto.PrivatePhotoFilePath3__c,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                    S3FileMoveList.add(S3FileMove);
                }
                // 非公開写真ファイルパス４
                if (String.isnotBlank(delPropertyPhoto.PrivatePhotoFilePath4__c)){
                    S3FileMove__c S3FileMove = saveS3FileMove(delPropertyPhoto.PrivatePhotoFilePath4__c,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                    S3FileMoveList.add(S3FileMove);
                }
                // 非公開写真ファイルパス５
                if (String.isnotBlank(delPropertyPhoto.PrivatePhotoFilePath5__c)){
                    S3FileMove__c S3FileMove = saveS3FileMove(delPropertyPhoto.PrivatePhotoFilePath5__c,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                    S3FileMoveList.add(S3FileMove);
                }
                // 非公開写真ファイルパス６
                if (String.isnotBlank(delPropertyPhoto.PrivatePhotoFilePath6__c)){
                    S3FileMove__c S3FileMove = saveS3FileMove(delPropertyPhoto.PrivatePhotoFilePath6__c,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                    S3FileMoveList.add(S3FileMove);
                }
                // 非公開写真ファイルパス７
                if (String.isnotBlank(delPropertyPhoto.PrivatePhotoFilePath7__c)){
                    S3FileMove__c S3FileMove = saveS3FileMove(delPropertyPhoto.PrivatePhotoFilePath7__c,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                    S3FileMoveList.add(S3FileMove);
                }
                // 非公開写真ファイルパス８
                if (String.isnotBlank(delPropertyPhoto.PrivatePhotoFilePath8__c)){
                    S3FileMove__c S3FileMove = saveS3FileMove(delPropertyPhoto.PrivatePhotoFilePath8__c,delBuilding.ForeignID__c,mergeBuilding.ForeignID__c);
                    S3FileMoveList.add(S3FileMove);
                }                
            }

            // insertListが0より大きければ、insertする　
            if(S3FileMoveList.size() > 0 ) {
                SecureDML.secureInsert(S3FileMoveList);

                //バッチ処理中フラグ取得
                SystemVariables__c systemConfigData;
                Boolean isProcessing;
                systemConfigData = [SELECT Id ,BooleanValue__c FROM SystemVariables__c  WHERE VariablesName__c = :IS_S3FILEMOVE_BATCHPROCESSING];
                isProcessing = systemConfigData.BooleanValue__c;

                //バッチ実行中でなければ
                if (!isProcessing) {
                    //フラグを実行中に更新
                    systemConfigData.BooleanValue__c = true;
                    SecureDML.secureUpdate(systemConfigData);

                    // バッチを動かす
                    S3PhotoMoveBatch b = new S3PhotoMoveBatch();
                    Database.executeBatch(b, 50);
                }
            }

        }
        
    }

    // s3移動ファイルを保存する
    private s3FileMove__c saveS3FileMove(String propertyPhotoPass,String delForeignIDBuilding,
                                         String mergeForeignIDBuilding){
        s3FileMove__c saveDate = new s3FileMove__c();

        // 画像のパスを移動可能な状態に補正する。
        propertyPhotoPass = PropertyPhotoPass.replace('https://' + bucketName + '.s3.amazonaws.com/', CommonConst.STRING_EMPTY);

        // 建物の外部IDを移動元のファイルパスにする(移動元ファイルパスを生成)。
        string fromPhotoFilePath = PropertyPhotoPass.replace(mergeForeignIDBuilding,delForeignIDBuilding);

        // 登録内容を設定
        saveDate.FromPhotoFilePath__c = fromPhotoFilePath; // 移動元ファイルパス
        saveDate.ToPhotoFilePath__c = PropertyPhotoPass;   // 移動先ファイルパス
        saveDate.BatchStatus__c = CommonConst.S3FILEMOVE_BATCHSTATUS_WAITING_PROCESSING;   // バッチステータス

        return saveDate;
    }
    
    /**
     * 空室予約物件の名寄せ
     * @param Id updBuildingId 名寄せ先の建物.ID
     * @param Id delBuildingId 削除される建物.ID
     */
    private void mergeVacancyReservationProp(Id updBuildingId, Id delBuildingId) {
        
        // 重複データの取得
        List<VacancyReservationProperty__c> duplicateAccList = [SELECT Account__c
                                                                       , PropertyFloorPlan__c
                                                                FROM VacancyReservationProperty__c
                                                                WHERE Building__c = :updBuildingId];
        
        // 重複チェックデータの取得（key:取引先.ID、value:間取り）
        Map<String, Set<String>> duplicateMap = CommonUtil.getKeysSetVal(duplicateAccList, 'Account__c', 'PropertyFloorPlan__c');
        
        // 名寄せ対象の取得
        List<VacancyReservationProperty__c> mergeTargetList = [SELECT Id
                                                                      , Building__c
                                                                      , Account__c
                                                                      , PropertyFloorPlan__c
                                                               FROM VacancyReservationProperty__c
                                                               WHERE Building__c = :delBuildingId];
        
        // DML処理用オブジェクト
        List<VacancyReservationProperty__c> delObjList = new List<VacancyReservationProperty__c>(); // 削除オブジェクト
        List<VacancyReservationProperty__c> updObjList = new List<VacancyReservationProperty__c>(); // 更新オブジェクト
        VacancyReservationProperty__c vacancyReservationProp;
        
        // 建物を名寄せ（建物、取引先、間取りの一意チェック）
        for (VacancyReservationProperty__c mergeTarget : mergeTargetList) {

            if (duplicateMap.containsKey(mergeTarget.Account__c)
                && duplicateMap.get(mergeTarget.Account__c).contains(mergeTarget.PropertyFloorPlan__c)) {
                // 重複データを削除
                vacancyReservationProp = new VacancyReservationProperty__c(Id = mergeTarget.Id);
                delObjList.add(vacancyReservationProp);
            } else {
                // 名寄せ対象を更新
                vacancyReservationProp = new VacancyReservationProperty__c(Id = mergeTarget.Id
                                                                           , Building__c = updBuildingId);
                updObjList.add(vacancyReservationProp);
            }
        }

        // 名寄せ（更新）
        if (updObjList.size() > 0) {
            SecureDML.secureUpdate(updObjList);
        }
        
        // 名寄せ（削除）
        if (delObjList.size() > 0) {
            SecureDML.secureDelete(delObjList);
        }
    }

    /**
     * 建物コード履歴の名寄せ
     * @param Id updBuildingId 名寄せ先の建物.ID
     * @param Id delBuildingId 削除される建物.ID
     */
    private void mergeBuildingCdHist(Id updBuildingId, Id delBuildingId) {

        // 削除対象の建物コード履歴を取得
        List<BuildingCodeHistory__c> mergeTargetBuildingCdHistList = 
            [SELECT Id
                    , Building__c
             FROM BuildingCodeHistory__c
             WHERE Building__c = :delBuildingId
            ];
        
        // 建物を更新
        for (BuildingCodeHistory__c mergeTargetBuildingCdHist : mergeTargetBuildingCdHistList) {
            mergeTargetBuildingCdHist.Building__c = updBuildingId;
        }

        // 建物コード履歴の名寄せ
        if (mergeTargetBuildingCdHistList.size() > 0) {
            SecureDML.secureUpdate(mergeTargetBuildingCdHistList);
        }
    }

    //******************************内部クラス*********************************************** */
    // 写真情報内部クラス
    private class PhotoData {
        public String Tag       { get; set; }   // タグ
        public String FileName  { get; set; }   // ファイル名
        public String FilePath  { get; set; }   // ファイルパス
        public String Comment  { get; set; }   // コメント
        public String Distance { get; set; }   // 距離
    }

    public class ScreenAnyPhotoData{
        public Integer photoCount               { get; set; }   // 写真登録数
        public List<PhotoData> photoDataList    { get; set; }   // 写真情報

        public ScreenAnyPhotoData() {
            // 初期化
            this.photoDataList  = new List<PhotoData>();
        }
        public ScreenAnyPhotoData(BuildingPhoto__c surroundingPhoto) {
            this.photoDataList  = new List<PhotoData>();

            String tagName = '';
            // データセット
            this.photoCount = 0;
            PhotoData data;
            // 物件写真
            for (Integer i = 1; i <= CommonConst.MAXINDEX_BUILDING_SURROUNDING; i++) {
                data = new photoData();
                data.Tag        = (String)surroundingPhoto.get('SurroundingTag' + i + '__c');              
                data.FileName   = (String)surroundingPhoto.get('SurroundingPhotoName' + i + '__c');
                data.FilePath   = (String)surroundingPhoto.get('SurroundingFilePath' + i + '__c');
                data.Comment    = (String)surroundingPhoto.get('SurroundingComment' + i + '__c');
                data.Distance   = CommonUtil.decimalToString((Decimal)surroundingPhoto.get('SurroundingDistance' + i + '__c'));

                // ファイル名が空のデータは対象外とする
                if (String.isEmpty(data.FileName)) {
                    continue;
                }else{
                    this.photoDataList.add(data);
                    photoCount += 1;
                }
            }
        }

    }
}