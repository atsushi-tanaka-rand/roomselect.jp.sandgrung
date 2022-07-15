/**
* 建物登録のクラス
*/
public inherited sharing class GA104003Controller {

    //Public変数
    
    //データ
    public displayBuilding displayTargetRecord { get; set; }    //画面表示用の内部クラスレコード
    public Building__c targetBuilding { get; set; } // 建物レコード
    public GA102006ParameterClass GA102006Parameter{get; set;} // 郵便番号検索・住所検索のパラメータ
    public List<BuildingMaintenanceHistory__c> targetBuildingMaintenanceHistoryList  { get; set; } //建物メンテナンス履歴
    public List<Property__c> targetPropertyList { get; set; } //物件リスト
    public String deleteTargetPhotoFilePath  { get; set; }//削除対象建物写真パス
    public Integer propertyMaxfloor { get; set;} // 登録済み物件の最大所在階
    public List<ScreenBuildingCdHist> screenBuildingCdHistList                       { get; set; } // 建物コード履歴用内部クラス
    public GA104007ParameterClass GA104007Parameter{ get; set; }  // 駅モーダルパラメタ 2022.04.07 No.782 問合せNo0782_建物画面の沿線名と駅名の登録について

    //選択リスト
    public List<SelectOption> stateOption                  { get; set; }//都道府県リスト
    public List<SelectOption> propertyTypeOption           { get; set; }//物件種別リスト
    public List<SelectOption> structureOption              { get; set; }//建物構造リスト
    public List<SelectOption> importTypeOption             { get; set; }//取込区分リスト
    public List<SelectOption> caretakerTypeOption          { get; set; }//管理人種別リスト
    public List<SelectOption> surroundingEnvironmentOption { get; set; }//周辺環境タグ
    public List<SelectOption> trainRouteOption             { get; set; }// 選択リスト（路線）2022.04.07 No.782 問合せNo0782_建物画面の沿線名と駅名の登録について

    public List<SelectOption> elementarySchoolList         { get; set; }//小学校リスト
    public List<SelectOption> elementarySchool2List        { get; set; }//小学校2リスト
    public List<SelectOption> elementarySchool3List        { get; set; }//小学校3リスト
    public List<SelectOption> juniorHighSchoolList         { get; set; }//中学校リスト
    public List<SelectOption> juniorHighSchool2List        { get; set; }//中学校2リスト
    public List<SelectOption> juniorHighSchool3List        { get; set; }//中学校3リスト

    public Boolean isUnnecessaryMosaic { get; set; }    //モザイク処理不要チェックボックス
    public Boolean isImageUploadFlg    { get; set; }    //画像の有無フラグ（削除ボタン制御用）　//問合せNo0345で追加

    //表示用メッセージ
    public String MSG_COM_V_SAVE                            {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_SAVE);}                            private set;}    //js用保存確認メッセージ
    public String MSG_COM_I_SAVE                            {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);}                            private set;}    //js用保存完了メッセージ
    public String MSG_COM_V_DELETE                          {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_DELETE);}                          private set;}    //js用削除確認メッセージ
    public String MSG_COM_I_DELETE                          {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_DELETE);}                          private set;}    //js用削除完了メッセージ
    public String MSG_PROP_E_SAVE_ADDRESS_MASTER_NOT_EXIST  {get{return CommonUtil.callMessageCreate(CommonConst.MSG_PROP_E_SAVE_ADDRESS_MASTER_NOT_EXIST);}  private set;}    //js用町・字コードが取得できなかった場合メッセージ
    public String MSG_PROP_V_REACQUISITION_SURROUNDING_INFO {get{return CommonUtil.callMessageCreate(CommonConst.MSG_PROP_V_REACQUISITION_SURROUNDING_INFO);} private set;}    //js用周辺情報の再取得を実行するか確認メッセージ
    public String MSG_PROP_I_FACILITY_IMPORT_END            {get{return CommonUtil.callMessageCreate(CommonConst.MSG_PROP_I_FACILITY_IMPORT_END);}            private set;}    //js用周辺情報の完了メッセージ
    public String MSG_COM_W_SELECTION_IMAGE_FILETYPE        {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SELECTION_IMAGE_FILETYPE);}        private set;}    //js用ファイルが画像ではない場合エラーメッセージ
    public String MSG_COM_V_DELETE_IMAGE                    {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_DELETE_IMAGE,'建物');}             private set;}    //js用画像一括削除確認メッセージ　//問合せNo0345で追加
    public String MSG_PROP_W_EXISTS_MAINT_PROP_HIST         {get{return CommonUtil.callMessageCreate(CommonConst.MSG_PROP_W_EXISTS_MAINT_PROP_HIST);}         private set;}    //メンテナンス物件コードの存在警告メッセージ

    public String MSG_NO_SELECTED_BUILDING_CD_HIST_ROW      {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SELECTION_OR_MORE,'メンテナンス建物コード履歴', '1');} private set;} // メンテナンス建物コード履歴未選択メッセージ

    //写真処理関連
    private BuildingPhoto__c targetBuildingPhoto            { get; set; }   // 建物写真オブジェクトレコード
    public List<ScreenAnyPhotoData> anyPhotoData            { get; set; }   // 建物写真情報（周辺写真以外）
    public ScreenSurroundingPhotoData surroundingPhotoData  { get; set; }   // 建物写真情報（周辺写真）
    public String uploadPhotoType               { get; set; }   // 写真種別  ※写真情報（周辺写真以外）のアップロード後処理への連携用
    public Integer deletePhotoIndex             { get; set; }   // 写真削除対象インデックス
    public String BUILDINGPHOTOTYPE_SURROUNDING { get{return CommonConst.S3_BUILDINGPHOTOTYPE_SURROUNDING;} private set; }  // js用写真種別(周辺写真判断用)
    public Integer MAXINDEX_SURROUNDINGPHOTO    { get{return CommonConst.MAXINDEX_BUILDING_SURROUNDING;}    private set; }  // 周辺写真最大登録可能数

    //フラグ
    public  Boolean isNew { get; set; }             //新規登録フラグ
    public  Boolean isOpenError { get; set; }       //エラーフラグ
    public  Boolean hasErrorMessage { get; set; }   //エラーメッセージ保有フラグ
    public  Boolean existsMaintPropCd { get; set; } //メンテナンス物件コード存在フラグ

    //プライベート変数
    private String targetId;                 //対象の建物ID
    public  String accountId{ get; set;}     //取引先ID (パラメータ渡し用)
    private String formerSupplierId;         //元付業者ID（元付物件詳細からの遷移時の、新規建物登録を行う際の、ダミー物件登録時に使用）
    private List<SelectOption> districtList; //地区設定用 
    private Integer modalMode;               //モーダル画面の判別用フラグ 2022.04.08 No.782 問合せNo0782_建物画面の沿線名と駅名の登録について

    // 定数　問合せ278で追加
    public final String REALNETPRO          { get{return CommonConst.PROPERTY_IMPORTTYPE_REALNETPRO;}}      // リアプロ
    public final String DAIWALIVING         { get{return CommonConst.PROPERTY_IMPORTTYPE_DAIWALIVING;}}     // 大和リビング
    public final String MANUAL              { get{return CommonConst.PROPERTY_IMPORTTYPE_MANUAL;}}          // 手動
    public final String SELECTION_LIST_NULL { get{return CommonConst.SELECTION_LIST_NULL;}}                 // --なし--

//＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
//publicメソッド
//＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊

    public GA104003Controller() {
        try{
            
            //初期化
            init();
            
            
            //パラメータ取得
            targetId         = ApexPages.currentPage().getParameters().get('Id');               //パラメータの建物IDを取得
            accountId        = ApexPages.currentPage().getParameters().get('accountId');        //パラメータの取引先IDを取得
            formerSupplierId = ApexPages.currentPage().getParameters().get('formerSupplierId'); //パラメータの元付物件詳細IDを取得
            
            if (String.isBlank(targetId)) { //新規フラグの設定
                isNew = TRUE;
            }else{
                isNew = FALSE;
            }
            
            //データ取得
            if(isNew){
                displayTargetRecord = new displayBuilding(new Building__c());//建物を新規作成
            }else{
                getBuilding();                               // 建物を取得
                getTargetBuildingMaintenanceHistoryList();   // 建物のメンテナンス履歴を取得
                getTargetPropertyList();                     // 建物の物件を取得
                getPhotoData();                              // 建物写真情報を取得
                this.setScreenBuildingCdHist(this.targetId); // メンテナンス建物コード履歴を設定
            }
            
            //数式計算
            recalculateFormula();
            
        }catch(Exception e){
            isOpenError = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
            
        }
    }
    
    //保存ボタン押下処理
    public void saveBuilding(){
        Savepoint sp = Database.setSavepoint();      //セーブポイント作成
        try{
            //変数初期化
            hasErrorMessage = false;//エラーを初期化
            BusinessLogicException ex = new BusinessLogicException();//ビジネスロジックException準備
            
            // ▼ 2022.04.12 No.782 問合せNo0782_建物画面の沿線名と駅名の登録について
            //駅名重複チェック

            //未入力駅名が2つ以上存在する場合を除く

            //駅名1～3が重複している場合
            if((displayTargetRecord.station1 == displayTargetRecord.station2 && displayTargetRecord.station1 != null)||
                (displayTargetRecord.station1 == displayTargetRecord.station3 && displayTargetRecord.station2 != null)||
                (displayTargetRecord.station2 == displayTargetRecord.station3 && displayTargetRecord.station3 != null))
            {
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_PROP_E_SAVE_STATION_DUPLICATE));
            }
            
            // ▲ 2022.04.12 No.782 問合せNo0782_建物画面の沿線名と駅名の登録について

            //町字コードのチェック
            if(String.isNotBlank(displayTargetRecord.city) && String.isBlank(displayTargetRecord.choazaCode)){// 住所１が入力されており、町字コードが空白の場合エラーメッセージ追加
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_PROP_E_SAVE_ADDRESS_MASTER_NOT_EXIST));
            }

            // 問合せ278で追加
            // 初期表示がリアプロ、大和リビングの場合を除き、リアプロ、大和リビングが選択された場合、エラー
            if((displayTargetRecord.importType == REALNETPRO && displayTargetRecord.initialInportType != REALNETPRO) 
            || (displayTargetRecord.importType == DAIWALIVING && displayTargetRecord.initialInportType != DAIWALIVING)) {
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_INPORT_DESTINATION_CAN_NOT_CHANGE, displayTargetRecord.importType));
            }

            // 初期表示が--なし--の場合を除き、--なし--が選択された場合、エラー
            if(String.isBlank(displayTargetRecord.importType) && String.isNotBlank(displayTargetRecord.initialInportType)) {
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_INPORT_DESTINATION_CAN_NOT_CHANGE, SELECTION_LIST_NULL));
            }

            //必須入力チェック
            List<String> requiredItem = new List<String>();//入力チェックリストを初期化

            if (String.isBlank(displayTargetRecord.buildName)){
                requiredItem.add('建物名');
            }
            if (String.isBlank(displayTargetRecord.city)){
                requiredItem.add('住所1');
            }
            if (String.isBlank(displayTargetRecord.street)){
                requiredItem.add('住所2');
            }
            if (String.isBlank(displayTargetRecord.propertyType)){
                requiredItem.add('種別');
            }
            if (String.isBlank(displayTargetRecord.structure)){
                requiredItem.add('構造');
            }
            if (String.isBlank(displayTargetRecord.buildingYM)){
                requiredItem.add('築年月');
            }
            if (String.isBlank(displayTargetRecord.groundFloorCount)){
                requiredItem.add('地上階数');
            }
            if (String.isBlank(displayTargetRecord.undergroundFloorCount)){
                requiredItem.add('地下階数');
            }
            if (displayTargetRecord.latitude == null){
                requiredItem.add('緯度');
            }
            if (displayTargetRecord.longitude == null){
                requiredItem.add('経度');
            }

          
            
            // バス関連の項目に入力があり、番号と対応する駅名、バス停名のいずれかがが未入力の場合
            if(String.isNotBlank(displayTargetRecord.busRoute1) //バス路線名1
               ||String.isNotBlank(displayTargetRecord.busStop1) //バス停名1
               ||String.isNotBlank(displayTargetRecord.busStopDistance1)//バス停1までの距離(m)
               ||String.isNotBlank(displayTargetRecord.busRideTime1)//バス乗車時間1(分)
               ||String.isNotBlank(displayTargetRecord.busStopToStationDistance1)//バス停1からの距離(m)
              ){
                // バス関連の項目の一部だけ入力されていた場合にエラー
                  if(String.isBlank(displayTargetRecord.busRoute1)){
                      requiredItem.add('バス路線名1');
                  }
                  if(String.isBlank(displayTargetRecord.busStop1)){
                      requiredItem.add('バス停名1');
                  }
                  if(String.isBlank(displayTargetRecord.busStopDistance1)){
                      requiredItem.add('物件からバス停1までの距離(m)');
                  }
                  if(String.isBlank(displayTargetRecord.busRideTime1)){
                      requiredItem.add('バス乗車時間1(分)');
                  }
                  if(String.isBlank(displayTargetRecord.busStopToStationDistance1)){
                      requiredItem.add('バス停1から駅までの距離(m)');
                  }
              }        
            
            // バス関連の項目に入力があり、番号と対応する駅名、バス停名のいずれかがが未入力の場合
            if(String.isNotBlank(displayTargetRecord.busRoute2) //バス路線名2
               ||String.isNotBlank(displayTargetRecord.busStop2) //バス停名2
               ||String.isNotBlank(displayTargetRecord.busStopDistance2)//バス停2までの距離(m)
               ||String.isNotBlank(displayTargetRecord.busRideTime2)//バス乗車時間2(分)
               ||String.isNotBlank(displayTargetRecord.busStopToStationDistance2)//バス停2からの距離(m)
              ){
                  // バス関連の項目の一部だけ入力されていた場合にエラー
                  if(String.isBlank(displayTargetRecord.busRoute2)){
                      requiredItem.add('バス路線名2');
                  }
                  if(String.isBlank(displayTargetRecord.busStop2) ){
                      requiredItem.add('バス停名2');
                  }
                  if(String.isBlank(displayTargetRecord.busStopDistance2)){
                      requiredItem.add('物件からバス停2までの距離(m)');
                  }
                  if(String.isBlank(displayTargetRecord.busRideTime2)){
                      requiredItem.add('バス乗車時間2(分)');
                  }
                  if(String.isBlank(displayTargetRecord.busStopToStationDistance2)){
                      requiredItem.add('バス停2から駅までの距離(m)');
                  }
              }
            
            // バス関連の項目に入力があり、番号と対応する駅名、バス停名のいずれかがが未入力の場合
            if(String.isNotBlank(displayTargetRecord.busRoute3) //バス路線名3
               ||String.isNotBlank(displayTargetRecord.busStop3) //バス停名3
               ||String.isNotBlank(displayTargetRecord.busStopDistance3)//バス停3までの距離(m)
               ||String.isNotBlank(displayTargetRecord.busRideTime3)//バス乗車時間3(分)
               ||String.isNotBlank(displayTargetRecord.busStopToStationDistance3)//バス停3からの距離(m)
              ){
                  // バス関連の項目の一部だけ入力されていた場合にエラー
                  if(String.isBlank(displayTargetRecord.busRoute3)){
                      requiredItem.add('バス路線名3');
                  }
                  if(String.isBlank(displayTargetRecord.busStop3)){
                      requiredItem.add('バス停名3');
                  }
                  if(String.isBlank(displayTargetRecord.busStopDistance3)){
                      requiredItem.add('物件からバス停3までの距離(m)');
                  }
                  if(String.isBlank(displayTargetRecord.busRideTime3)){
                      requiredItem.add('バス乗車時間3(分)');
                  }
                  if(String.isBlank(displayTargetRecord.busStopToStationDistance3)){
                      requiredItem.add('バス停3から駅までの距離(m)');
                  }
              }

            if ( !isNew ) {
                Integer photoNum = 1;
                for (PhotoData photo : this.surroundingPhotoData.photoDataList) {
                    // 周辺写真タグ 未選択チェック
                    if (String.isBlank(photo.tag)) {
                        requiredItem.add(photoNum + 'つ目の周辺写真タグ');
                    }
                    // 周辺写真名 未入力チェック
                    if (String.isBlank(photo.photoName)) {
                        requiredItem.add(photoNum + 'つ目の周辺写真名');
                    }
                    // 周辺写真までの距離 未入力チェック
                    if (String.isBlank(photo.distance)) {
                        requiredItem.add(photoNum + 'つ目の周辺写真までの距離');
                    }
                    photoNum++;
                }
            }
             
            if (!requiredItem.isEmpty()){//入力チェック用リストが空ではない場合、エラー追加                
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ',')));
            }
            
            // 地上階数チェック
            if ((this.propertyMaxfloor != null && !String.isBlank(displayTargetRecord.groundFloorCount))
                && this.propertyMaxfloor > Integer.valueOf(displayTargetRecord.groundFloorCount)) {
                List<Integer> floor = new List<Integer> {this.propertyMaxfloor};
                List<Object> parameters = new List<Object> {'物件' 
                                                            , String.format('所在階に{0}', floor)
                                                            , String.format('地上階数には{0}以上', floor)};
                ex.addMessage(CommonUtil.callMessageCreate(String.format(CommonConst.MSG_COM_W_PROPERTYSETTING_REQUIRED, parameters)));
            }
            
             
            //バス乗車時間チェック
            Decimal busStopWalkTime1 = displayTargetRecord.displayCalculateFormulas.BusStopWalkTime1__c;
            if(busStopWalkTime1 != null      && !isBusTimeWithinRange(busStopWalkTime1)){
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_REGISTRATION_COUNT_RANGE,'物件からバス停1までの徒歩時間(分)', '1', '99' ));
            }
            Decimal busRideTime1 = CommonUtil.StringToDecimal(displayTargetRecord.busRideTime1);
            if(busRideTime1 != null          && !isBusTimeWithinRange(busRideTime1)){
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_REGISTRATION_COUNT_RANGE,'バス乗車時間1(分)', '1', '99' ));
            }
            Decimal busStopToStationTime1 = displayTargetRecord.displayCalculateFormulas.BusStopToStationWalkTime1__c;
            if(busStopToStationTime1 != null && !isBusTimeWithinRange(busStopToStationTime1)){
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_REGISTRATION_COUNT_RANGE,'バス停1から駅までの徒歩時間(分)', '1', '99' ));
            }
            
            Decimal busStopWalkTime2 = displayTargetRecord.displayCalculateFormulas.BusStopWalkTime2__c;
            if(busStopWalkTime2 != null      && !isBusTimeWithinRange(busStopWalkTime2)){
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_REGISTRATION_COUNT_RANGE,'物件からバス停2までの徒歩時間(分)', '1', '99' ));
            }
            Decimal busRideTime2 = CommonUtil.StringToDecimal(displayTargetRecord.busRideTime2);
            if(busRideTime2 != null          && !isBusTimeWithinRange(busRideTime2)){
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_REGISTRATION_COUNT_RANGE,'バス乗車時間2(分)', '1', '99' ));
            }
            Decimal busStopToStationTime2 = displayTargetRecord.displayCalculateFormulas.BusStopToStationWalkTime2__c;
            if(busStopToStationTime2 != null && !isBusTimeWithinRange(busStopToStationTime2)){
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_REGISTRATION_COUNT_RANGE,'バス停2から駅までの徒歩時間(分)', '1', '99' ));
            }
            
            Decimal busStopWalkTime3 = displayTargetRecord.displayCalculateFormulas.BusStopWalkTime3__c;
            if(busStopWalkTime3 != null      && !isBusTimeWithinRange(busStopWalkTime3)){
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_REGISTRATION_COUNT_RANGE,'物件からバス停3までの徒歩時間(分)', '1', '99' ));
            }
            Decimal busRideTime3 = CommonUtil.StringToDecimal(displayTargetRecord.busRideTime3);
            if(busRideTime3 != null          && !isBusTimeWithinRange(busRideTime3)){
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_REGISTRATION_COUNT_RANGE,'バス乗車時間3(分)', '1', '99' ));
            }
            Decimal busStopToStationTime3 = displayTargetRecord.displayCalculateFormulas.BusStopToStationWalkTime3__c;
            if(busStopToStationTime3 != null && !isBusTimeWithinRange(busStopToStationTime3)){
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_REGISTRATION_COUNT_RANGE,'バス停3から駅までの徒歩時間(分)', '1', '99' ));
            }
            
            //エラーをまとめて投げる
            if (ex.hasMessage()){ 
                throw ex;
            }

            
            //楽観ロックチェック
            if (!isNew){ //新規でない場合、楽観ロックチェックのためデータ取得
                List<Building__c> checkOptimisticLockExceptionRecord = new List<Building__c>();
                checkOptimisticLockExceptionRecord = [ SELECT id
                                                      FROM Building__c
                                                      WHERE id = :this.displayTargetRecord.buildId
                                                      AND SystemModStamp = :this.displayTargetRecord.systemModStamp ];
                
                //データ取得できない場合、楽観ロックチェックExceptionを発行
                if (checkOptimisticLockExceptionRecord.isEmpty()){
                    OptimisticLockException OptimisticLockex = new OptimisticLockException();
                    throw OptimisticLockex;
                }
            }
     
            //保存処理実行
            Building__c upSertBuilding = new Building__c();//保存する建物を作成
            
            //画面入力内容を保存する建物に設定
            upSertBuilding.ID            = this.displayTargetRecord.buildId;//  建物Id (新規作成の場合は何も代入されない)
            upSertBuilding.Name          = this.displayTargetRecord.buildName;//  建物名
            upSertBuilding.BuildKana__c  = this.displayTargetRecord.buildNameKana;//  建物名（カナ）
            upSertBuilding.BuildName2__c = this.displayTargetRecord.buildName2;//  建物名２
            upSertBuilding.BuildKana2__c = this.displayTargetRecord.buildNameKana2;//  建物名（カナ）２
            upSertBuilding.BuildName3__c = this.displayTargetRecord.buildName3;//  建物名３
            upSertBuilding.BuildKana3__c = this.displayTargetRecord.buildNameKana3; //  建物名（カナ）３
            
            upSertBuilding.PostalCode__c = this.displayTargetRecord.postalCode;     //  建物名（カナ）３
            upSertBuilding.Structure__c  = this.displayTargetRecord.structure;      //  建物構造
            
            upSertBuilding.State__c        = this.displayTargetRecord.state;        //  都道府県
            upSertBuilding.City__c         = this.displayTargetRecord.city;         //  住所１（市区町村）
            upSertBuilding.Street__c       = this.displayTargetRecord.street;       //  住所２（番地）
            upSertBuilding.District__c     = this.displayTargetRecord.district;     //  地区
            upSertBuilding.ChoazaCode__c   = this.displayTargetRecord.choazaCode;   //  町字コード
            upSertBuilding.PropertyType__c = this.displayTargetRecord.propertyType; //  物件種別
            upSertBuilding.BuildingYM__c   = this.displayTargetRecord.buildingYM;   //  築年月
            upSertBuilding.UndergroundFloorCount__c = CommonUtil.stringToDecimal(this.displayTargetRecord.undergroundFloorCount);// 地下階数
            upSertBuilding.GroundFloorCount__c      = CommonUtil.stringToDecimal(this.displayTargetRecord.groundFloorCount);     // 地下階数
            upSertBuilding.HouseCount__c            = CommonUtil.stringToDecimal(this.displayTargetRecord.houseCount);           // 棟総戸数
            
            upSertBuilding.Longitude__c = this.displayTargetRecord.longitude;// 経度
            upSertBuilding.Latitude__c  = this.displayTargetRecord.latitude; // 緯度
            
            upSertBuilding.BuildingRemarksPublic__c  = this.displayTargetRecord.buildingRemarksPublic; //  建物備考（公開）
            upSertBuilding.BuildingRemarksPrivate__c = this.displayTargetRecord.buildingRemarksPrivate;//  建物備考（非公開）
            
            upSertBuilding.ImportType__c              = this.displayTargetRecord.importType;// 取込区分
            
            // 問合せ278で追加　手動に変更した場合、メンテナンス建物コードをnullに変更
            if(this.displayTargetRecord.importType == MANUAL && displayTargetRecord.initialInportType != MANUAL) {
                upSertBuilding.MaintenanceBuildingCode__c = null;// メンテナンス建物コード
            } else {
                upSertBuilding.MaintenanceBuildingCode__c = this.displayTargetRecord.maintenanceBuildingCode;// メンテナンス建物コード
            }
            
            upSertBuilding.CaretakerType__c           = this.displayTargetRecord.caretakerType;              //  管理人種別
            
            upSertBuilding.PrimarySchool1__c          = this.displayTargetRecord.primarySchool1;             //  小学校１Id
            upSertBuilding.PrimarySchoolDistance1__c  = CommonUtil.stringToDecimal(this.displayTargetRecord.primarySchoolDistance1);//  小学校までの距離１
            
            upSertBuilding.PrimarySchool2__c          = this.displayTargetRecord.primarySchool2;             //  小学校2Id
            upSertBuilding.PrimarySchoolDistance2__c  = CommonUtil.stringToDecimal(this.displayTargetRecord.primarySchoolDistance2);//  小学校までの距離2
            
            upSertBuilding.PrimarySchool3__c          = this.displayTargetRecord.primarySchool3;             //  小学校3Id
            upSertBuilding.PrimarySchoolDistance3__c  = CommonUtil.stringToDecimal(this.displayTargetRecord.primarySchoolDistance3);//  小学校までの距離3
            
            upSertBuilding.JuniorHighSchool1__c         = this.displayTargetRecord.juniorHighSchool1;        //  中学校１
            upSertBuilding.JuniorHighSchoolDistance1__c = CommonUtil.stringToDecimal(this.displayTargetRecord.juniorHighSchoolDistance1);//  中学校までの距離１
            
            upSertBuilding.JuniorHighSchool2__c         = this.displayTargetRecord.juniorHighSchool2;        //  中学校2
            upSertBuilding.JuniorHighSchoolDistance2__c = CommonUtil.stringToDecimal(this.displayTargetRecord.juniorHighSchoolDistance2);//  中学校までの距離2
            
            upSertBuilding.JuniorHighSchool3__c         = this.displayTargetRecord.juniorHighSchool3;        //  中学校3
            upSertBuilding.JuniorHighSchoolDistance3__c = CommonUtil.stringToDecimal(this.displayTargetRecord.juniorHighSchoolDistance3);//  中学校までの距離3
            
            upSertBuilding.HighSchool__c                = this.displayTargetRecord.highSchool;               //  高校
            upSertBuilding.HighSchoolDistance__c        = this.displayTargetRecord.highSchoolDistance;//  高校までの距離
            
            upSertBuilding.University__c                = this.displayTargetRecord.university;//  大学
            upSertBuilding.UniversityDistance__c        = this.displayTargetRecord.universityDistance; //  大学までの距離
            
            upSertBuilding.ConvenienceStore__c          = this.displayTargetRecord.convenienceStore; // コンビニ
            upSertBuilding.ConvenienceStoreDistance__c  = this.displayTargetRecord.convenienceStoreDistance;//  コンビニまでの距離
            
            upSertBuilding.Supermarket__c               = this.displayTargetRecord.supermarket;//  スーパーマーケット
            upSertBuilding.SupermarketDistance__c       = this.displayTargetRecord.supermarketDistance; //  スーパーマーケットまでの距離
            
            upSertBuilding.GeneralHospital__c           = this.displayTargetRecord.generalHospital;//  総合病院
            upSertBuilding.GeneralHospitalDistance__c   = this.displayTargetRecord.generalHospitalDistance;//  総合病院までの距離
            
            upSertBuilding.TrainRoute1__c = this.displayTargetRecord.trainRoute1;//  沿線１
            
            upSertBuilding.Station1__c = this.displayTargetRecord.station1;//  駅１
            upSertBuilding.StationDistance1__c = CommonUtil.stringToDecimal(this.displayTargetRecord.stationDistance1);//  駅までの距離1
            
            upSertBuilding.TrainRoute2__c = this.displayTargetRecord.trainRoute2;//  沿線２
            
            upSertBuilding.Station2__c = this.displayTargetRecord.station2;//  駅2
            upSertBuilding.StationDistance2__c = CommonUtil.stringToDecimal(this.displayTargetRecord.stationDistance2);//  駅までの距離2
            
            upSertBuilding.TrainRoute3__c = this.displayTargetRecord.trainRoute3;//  沿線３
            
            upSertBuilding.Station3__c = this.displayTargetRecord.station3;//  駅3
            upSertBuilding.StationDistance3__c = CommonUtil.stringToDecimal(this.displayTargetRecord.stationDistance3);//  駅までの距離3
            
            upSertBuilding.BusRoute1__c = this.displayTargetRecord.busRoute1;//  バス路線名
            upSertBuilding.BusStop1__c = this.displayTargetRecord.busStop1;//  バス停
            upSertBuilding.BusStopDistance1__c = CommonUtil.stringToDecimal(this.displayTargetRecord.busStopDistance1); //  バス停までの距離
            upSertBuilding.BusRideTime1__c = CommonUtil.stringToDecimal(this.displayTargetRecord.busRideTime1);//  バス乗車時間（分）１
            upSertBuilding.BusStopToStationDistance1__c = CommonUtil.stringToDecimal(this.displayTargetRecord.busStopToStationDistance1); //  バス停からの距離
            
            upSertBuilding.BusRoute2__c = this.displayTargetRecord.busRoute2; //  バス路線名2
            upSertBuilding.BusStop2__c = this.displayTargetRecord.busStop2; //  バス停2
            upSertBuilding.BusStopDistance2__c = CommonUtil.stringToDecimal(this.displayTargetRecord.busStopDistance2);//  バス停までの距離2
            upSertBuilding.BusRideTime2__c = CommonUtil.stringToDecimal(this.displayTargetRecord.busRideTime2); //  バス乗車時間（分）2
            upSertBuilding.BusStopToStationDistance2__c = CommonUtil.stringToDecimal(this.displayTargetRecord.busStopToStationDistance2); //  バス停からの距離2
            
            upSertBuilding.BusRoute3__c = this.displayTargetRecord.busRoute3;//  バス路線名3
            upSertBuilding.BusStop3__c = this.displayTargetRecord.busStop3;//  バス停3
            upSertBuilding.BusStopDistance3__c = CommonUtil.stringToDecimal(this.displayTargetRecord.busStopDistance3);//  バス停までの距離3
            upSertBuilding.BusRideTime3__c = CommonUtil.stringToDecimal(this.displayTargetRecord.busRideTime3); //  バス乗車時間（分）3
            upSertBuilding.BusStopToStationDistance3__c = CommonUtil.stringToDecimal(this.displayTargetRecord.busStopToStationDistance3); //  バス停からの距離3
            
            if ( isNew ) {
                upSertBuilding.MaintenanceType__c       = CommonConst.MAINTENANCETYPE_MANUALADD;                        // メンテナンス区分
                upSertBuilding.MaintenanceComment__c    = String.isEmpty(this.displayTargetRecord.maintenanceComment)
                                                        ? '建物を登録しました。' : this.displayTargetRecord.maintenanceComment; // メンテナンスコメント
            }else{
                upSertBuilding.MaintenanceType__c       = CommonConst.MAINTENANCETYPE_MANUALCHG;                        // メンテナンス区分
                upSertBuilding.MaintenanceComment__c    = String.isEmpty(this.displayTargetRecord.maintenanceComment)
                                                        ? '建物を更新しました。' : this.displayTargetRecord.maintenanceComment; // メンテナンスコメント
            }

            upSertBuilding.MaintenanceStaff__c = UserInfo.getUserId();                 //メンテナンススタッフ
            
            upsertBuilding.IsWebCooperationAvailableFlag__c = true; //Web連携可能フラグ
            
            upSertBuilding.IsMergeCompletedFlag__c = this.displayTargetRecord.isMergeCompletedFlag; //  名寄せ完了フラグ
            
            
            upSertBuilding = setTargetRecordIsMergeCompletedFlag(upSertBuilding);// 保存する建物に名寄せフラグ設定
            
            SecureDML.secureUpsert(upSertBuilding);// 建物を保存


            // 建物写真の保存
            BuildingPhoto__c upSertBuildingPhoto = new BuildingPhoto__c();
            upSertBuildingPhoto.Building__c = upSertBuilding.Id;
            
            if ( !isNew) {
                upSertBuildingPhoto.Id          = this.targetBuildingPhoto.Id;
                // コメント
                for (ScreenAnyPhotoData photo : this.anyPhotoData) {
                    switch on photo.photoType {
                        when BUILDING_APPEARANCE {
                            // 建物外観
                            upSertBuildingPhoto.AppearanceComment__c = photo.photoData.comment;
                        }
                        when BUILDING_APPEARANCEPARSE {
                            // 外観パース
                            upSertBuildingPhoto.AppearanceParseComment__c = photo.photoData.comment;
                        }
                        when BUILDING_ENTRANCE {
                            // エントランス
                            upSertBuildingPhoto.EntranceComment__c = photo.photoData.comment;
                        }
                        when BUILDING_LOBBY {
                            // ロビー
                            upSertBuildingPhoto.LobbyComment__c = photo.photoData.comment;
                        }
                        when BUILDING_PARKING {
                            // 駐車場
                            upSertBuildingPhoto.ParkingComment__c = photo.photoData.comment;
                        }
                        when BUILDING_OTHERSHARING {
                            // その他共有
                            upSertBuildingPhoto.OtherSharingComment__c = photo.photoData.comment;
                        }
                        when BUILDING_MAP {
                            // 地図
                            upSertBuildingPhoto.MapComment__c = photo.photoData.comment;
                        }
                        when BUILDING_OTHER {
                            // その他
                            upSertBuildingPhoto.OtherComment__c = photo.photoData.comment;
                        }
                    }
                }
                
         
                // 周辺写真タグ、周辺写真名、周辺写真までの距離、周辺写真コメント
                for (PhotoData photo : this.surroundingPhotoData.photoDataList) {
                    upSertBuildingPhoto.put('SurroundingTag' + photo.index + '__c'      , photo.tag);
                    upSertBuildingPhoto.put('SurroundingPhotoName' + photo.index + '__c', photo.photoName);
                    upSertBuildingPhoto.put('SurroundingDistance' + photo.index + '__c' , CommonUtil.stringToDecimal(photo.distance));
                    upSertBuildingPhoto.put('SurroundingComment' + photo.index + '__c'  , photo.comment);
                }
            }
            SecureDML.secureUpsert(upSertBuildingPhoto);

            // スーモスコア再計算
            updateSuumoScore(this.targetBuilding, this.targetBuildingPhoto);
            
            // ダミー物件保存
            if (isNew) {
                Property__c dummyProperty = new Property__c(
                    Building__c = upSertBuilding.Id
                    , Name = '99999'
                    , MaintenancePropertyCode__c = '手動登録'
                    , LiveStatus__c = commonconst.PROPERTY_LIVESTATUS_VACANCY       // 空室
                );
                if ( String.isNotBlank(formerSupplierId) ) { //元付物件詳細からの新規登録の場合
                    dummyProperty.FormerSupplier__c = formerSupplierId;
                }
                SecureDML.secureInsert(dummyProperty);
            }

        }catch(Exception e){
            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
            
        }
    } 
    
    //郵便番号検索・住所検索 モーダル表示
    public void GA102006FormOpen() {
        GA102006Parameter.isDrawing = true;
        GA102006Parameter.noFirst = true;
        
        GA102006Parameter.isAddressMoster = FALSE;  //住所マスタフラグ
        GA102006Parameter.postalCode = this.displayTargetRecord.postalCode;  //郵便番号
        GA102006Parameter.state = this.displayTargetRecord.state;    //都道府県
        GA102006Parameter.city = this.displayTargetRecord.city;    //市区町村
        GA102006Parameter.street = null;    //町域
        
    }
    
    //郵便番号検索・住所検索 モーダル閉じる
    public void GA102006FormClose() {
        this.displayTargetRecord.postalCode = GA102006Parameter.postalCode;  // 郵便番号
        this.displayTargetRecord.state = GA102006Parameter.state;    //都道府県
        this.displayTargetRecord.city = GA102006Parameter.city + GA102006Parameter.street + GA102006Parameter.aza ;    //市区町村

        this.displayTargetRecord.latitude  = null;       //軽度
        this.displayTargetRecord.longitude = null;      //緯度
        
        changeState();// 都道府県変更時処理
    }
    
    //都道府県変更時
    public void changeState() {         
        hasErrorMessage = false;
        try{
            this.displayTargetRecord.district = CommonUtil.getDistrict(this.displayTargetRecord.city,this.districtList); // 地区を設定
            setChoazaCode(); //町字コードを設定
        }catch(Exception e){
            hasErrorMessage = true;//エラーを設定
            displayTargetRecord.choazaCode = '';//町字コードを初期化
            CommonUtil.setErrorMessage(e);
        }
    }
    
    //住所1変更時
    public void changeCity() {
        hasErrorMessage = false;
        try{
            changeCityOrStreet();//住所1または住所2変更時の処理
            changeState(); //【都道府県選択変更処理】と同様の地区、町字コードの取得処理
        }catch(Exception e){
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        } 
    }
    
    //住所1または住所2変更時
    public void changeCityOrStreet() {
        
        
        //  経度と緯度をクリア
        displayTargetRecord.longitude                 = null; // 経度
        displayTargetRecord.latitude                  = null; // 緯度
        
        // バス・周辺写真以外の"○○までの距離"・"○○までの徒歩時間"をクリア
        displayTargetRecord.primarySchoolDistance1    = null; //  小学校までの距離１
        displayTargetRecord.PrimarySchoolWalkTime1    = null; //  小学校までの時間（分）１
        
        displayTargetRecord.primarySchoolDistance2    = null; //  小学校までの距離2
        displayTargetRecord.PrimarySchoolWalkTime2    = null; //  小学校までの時間（分）2
        
        displayTargetRecord.primarySchoolDistance3    = null; //  小学校までの距離3
        displayTargetRecord.PrimarySchoolWalkTime3    = null; //  小学校までの時間（分）3
        
        displayTargetRecord.juniorHighSchoolDistance1 = null; //  中学校までの距離１
        displayTargetRecord.juniorHighSchoolWalkTime1 = null; //  中学校までの時間（分）１
        
        displayTargetRecord.juniorHighSchoolDistance2 = null; //  中学校までの距離2
        displayTargetRecord.juniorHighSchoolWalkTime2 = null; //  中学校までの時間（分）2
        
        displayTargetRecord.juniorHighSchoolDistance3 = null; //  中学校までの距離3
        displayTargetRecord.juniorHighSchoolWalkTime3 = null; //  中学校までの時間（分）3
        
        displayTargetRecord.highSchoolDistance        = null; //  高校までの距離
        displayTargetRecord.highSchoolWalkTime        = null; //  高校までの時間（分）
        
        displayTargetRecord.universityDistance        = null; //  大学までの距離
        displayTargetRecord.universityWalkTime        = null; //  大学までの時間（分）
        
        displayTargetRecord.convenienceStoreDistance  = null; //  コンビニまでの距離
        displayTargetRecord.convenienceStoreWalkTime  = null; //  コンビニまでの時間（分）
        
        displayTargetRecord.supermarketDistance       = null; //  スーパーマーケットまでの距離
        displayTargetRecord.supermarketWalkTime       = null; //  スーパーマーケットまでの時間（分）
        
        displayTargetRecord.generalHospitalDistance   = null; //  総合病院までの距離
        displayTargetRecord.generalHospitalWalkTime   = null; //  総合病院までの時間（分）
        
        displayTargetRecord.stationDistance1          = null; //  駅までの距離1
        displayTargetRecord.stationWalkTime1          = null; //  駅までの時間(分)１
        
        displayTargetRecord.stationDistance2          = null; //  駅までの距離2
        displayTargetRecord.stationWalkTime2          = null; //  駅までの時間(分)2
        
        displayTargetRecord.stationDistance3          = null; //  駅までの距離3
        displayTargetRecord.stationWalkTime3          = null; //  駅までの時間(分)3
        
        
    }
    
    //削除ボタン押下処理
    public void deleteBuilding(){
        
        Savepoint sp = Database.setSavepoint();      //セーブポイント作成
        try{
            hasErrorMessage = false;//エラーを初期化
            
            SecureDML.secureDelete(targetBuilding);//レコード削除
            
        }catch(Exception e){
            
            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
            
        }
    }    
    
    // 周辺情報取得ボタン押下時
    public void getSurroundingEnvironment() {            
        hasErrorMessage = false;//エラーを初期化
        try{

            BusinessLogicException ex = new BusinessLogicException();//ビジネスロジックException準備
            
            //入力チェック
            if (String.isBlank(displayTargetRecord.city) || String.isBlank(displayTargetRecord.street)){//住所1か2が入力されていなければエラー
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_PROP_E_SAVE_ADDRESS_MASTER_NOT_EXIST));
            }
            
            //エラー発行
            if (ex.hasMessage()) {
                throw ex;
            }
            
            //周辺情報取得
            callGoogleApiUtil();
            
        }catch(Exception e){
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }
    
    
    // 表示している数式の再計算処理
    public void recalculateFormula() {
        // 数式表示用の建物レコードに数式に使用する項目を設定
        displayTargetRecord.displayCalculateFormulas.BuildingYM__c = displayTargetRecord.buildingYM;

        displayTargetRecord.displayCalculateFormulas.PrimarySchoolDistance1__c = CommonUtil.stringToDecimal(displayTargetRecord.PrimarySchoolDistance1);
        displayTargetRecord.displayCalculateFormulas.PrimarySchoolDistance2__c = CommonUtil.stringToDecimal(displayTargetRecord.PrimarySchoolDistance2);
        displayTargetRecord.displayCalculateFormulas.PrimarySchoolDistance3__c = CommonUtil.stringToDecimal(displayTargetRecord.PrimarySchoolDistance3);
        displayTargetRecord.displayCalculateFormulas.JuniorHighSchoolDistance1__c = CommonUtil.stringToDecimal(displayTargetRecord.JuniorHighSchoolDistance1);
        displayTargetRecord.displayCalculateFormulas.JuniorHighSchoolDistance2__c = CommonUtil.stringToDecimal(displayTargetRecord.JuniorHighSchoolDistance2);
        displayTargetRecord.displayCalculateFormulas.JuniorHighSchoolDistance3__c = CommonUtil.stringToDecimal(displayTargetRecord.JuniorHighSchoolDistance3);

        displayTargetRecord.displayCalculateFormulas.StationDistance1__c = CommonUtil.stringToDecimal(displayTargetRecord.stationDistance1);
        displayTargetRecord.displayCalculateFormulas.StationDistance2__c = CommonUtil.stringToDecimal(displayTargetRecord.stationDistance2);
        displayTargetRecord.displayCalculateFormulas.StationDistance3__c = CommonUtil.stringToDecimal(displayTargetRecord.stationDistance3);
        
        displayTargetRecord.displayCalculateFormulas.BusStopDistance1__c          = CommonUtil.stringToDecimal(displayTargetRecord.busStopDistance1);
        displayTargetRecord.displayCalculateFormulas.BusStopToStationDistance1__c = CommonUtil.stringToDecimal(displayTargetRecord.busStopToStationDistance1);
        
        displayTargetRecord.displayCalculateFormulas.BusStopDistance2__c          = CommonUtil.stringToDecimal(displayTargetRecord.busStopDistance2);
        displayTargetRecord.displayCalculateFormulas.BusStopToStationDistance2__c = CommonUtil.stringToDecimal(displayTargetRecord.busStopToStationDistance2);
        
        displayTargetRecord.displayCalculateFormulas.BusStopDistance3__c          = CommonUtil.stringToDecimal(displayTargetRecord.busStopDistance3);
        displayTargetRecord.displayCalculateFormulas.BusStopToStationDistance3__c = CommonUtil.stringToDecimal(displayTargetRecord.busStopToStationDistance3);
        
        displayTargetRecord.displayCalculateFormulas.recalculateFormulas();// 数式表示用の建物レコードで数式の再計算処理を実施する
    }

    // 小学校１の写真取得
    public void getprimarySchoolFilePath1() {
        displayTargetRecord.primarySchoolFilePath1 =  getPhotoFilePath(displayTargetRecord.primarySchool1);
    }

    // 小学校２の写真取得
    public void getprimarySchoolFilePath2() {
        displayTargetRecord.primarySchoolFilePath2 =  getPhotoFilePath(displayTargetRecord.primarySchool2);
    }

    // 小学校３の写真取得
    public void getprimarySchoolFilePath3() {
        displayTargetRecord.primarySchoolFilePath3 =  getPhotoFilePath(displayTargetRecord.primarySchool3);
    }

    // 中学校１の写真取得
    public void getjuniorHighSchoolFilePath1() {
        displayTargetRecord.juniorHighSchoolFilePath1 =  getPhotoFilePath(displayTargetRecord.juniorHighSchool1);
    }

    // 中学校２の写真取得
    public void getjuniorHighSchoolFilePath2() {
        displayTargetRecord.juniorHighSchoolFilePath2 =  getPhotoFilePath(displayTargetRecord.juniorHighSchool2);
    }

    // 中学校３の写真取得
    public void getjuniorHighSchoolFilePath3() {
        displayTargetRecord.juniorHighSchoolFilePath3 =  getPhotoFilePath(displayTargetRecord.juniorHighSchool3);
    }
    
    // モザイク処理不要の変更処理
    public void changeIsUnnecessaryMosaic(){
        isUnnecessaryMosaic = !isUnnecessaryMosaic;// モザイク処理不要のフラグを変更
        // モザイク加工要否セット
        for (ScreenAnyPhotoData photoData : this.anyPhotoData) {
            photoData.GD901001Parameter.isMosaic = !this.isUnnecessaryMosaic;
        }
        this.surroundingPhotoData.GD901001Parameter.isMosaic = !this.isUnnecessaryMosaic;
    }

    // 写真情報（周辺写真以外）アップロード後処理
    public void updateAnyPhoto() {
        try {
            // エラーフラグ初期化
            this.hasErrorMessage = false;

            // SystemModStampの変更有無を取得する
            Boolean isNotOptimisticLockError = this.checkSystemModStamp(this.targetId);

            for (ScreenAnyPhotoData photoData : this.anyPhotoData) {
                if (photoData.GD901001Parameter.parameter == this.uploadPhotoType) {
                    // 建物写真を更新する
                    AmazonS3Util.savePhoto(photoData.GD901001Parameter);
                    // 写真情報の再読み込み
                    this.reloadAnyPhotoData(photoData.photoType);
                }
            }

            // スーモスコア再計算
            this.updateSuumoScore(this.targetBuilding, this.targetBuildingPhoto);

            // 建物写真更新前時点でSystemModStampに変更が無かった場合、SystemModStampを再取得する
            if (isNotOptimisticLockError) {
                this.displayTargetRecord.systemModStamp = this.getSystemModStamp(this.targetId);
            }
        } catch(Exception e) {
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // 写真情報（周辺写真以外）削除処理
    public void deleteAnyPhoto(){
        try {
            // エラーフラグ初期化
            this.hasErrorMessage = false;

            // SystemModStampの変更有無を取得する
            Boolean isNotOptimisticLockError = this.checkSystemModStamp(this.targetId);

            for (ScreenAnyPhotoData photoData : this.anyPhotoData) {
                if (photoData.photoData.index == this.deletePhotoIndex) {
                    // 画像削除
                    AmazonS3Util.callPhotoDelete(this.targetId, photoData.photoType);
                    // 写真再読み込み
                    this.reloadAnyPhotoData(photoData.photoType);
                }
            }

            // スーモスコア再計算
            this.updateSuumoScore(this.targetBuilding, this.targetBuildingPhoto);

            // 建物写真更新前時点でSystemModStampに変更が無かった場合、SystemModStampを再取得する
            if (isNotOptimisticLockError) {
                this.displayTargetRecord.systemModStamp = this.getSystemModStamp(this.targetId);
            }
        } catch(Exception e) {
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // 周辺写真情報アップロード後処理
    public void updateSurroundingPhoto() {
        try {
            // エラーフラグ初期化
            this.hasErrorMessage = false;

            // SystemModStampの変更有無を取得する
            Boolean isNotOptimisticLockError = this.checkSystemModStamp(this.targetId);

            // 建物写真を更新する
            AmazonS3Util.savePhoto(this.surroundingPhotoData.GD901001Parameter);

            // 周辺写真情報の再読み込み（タグ、コメント等は入力中のものを反映し直す）
            List<PhotoData> tempPhotoData = this.surroundingPhotoData.photoDataList.clone();
            this.reloadSurroundingPhotoData();
            for (Integer i = 0; i < tempPhotoData.size(); i++) {
                this.surroundingPhotoData.photoDataList[i].tag          = tempPhotoData[i].tag;
                this.surroundingPhotoData.photoDataList[i].comment      = tempPhotoData[i].comment;
                this.surroundingPhotoData.photoDataList[i].photoName    = tempPhotoData[i].photoName;
                this.surroundingPhotoData.photoDataList[i].distance     = tempPhotoData[i].distance;
            }
            // System.debug('★★★アップロード後this.surroundingPhotoData.GD901001Parameter.registPhotoCount：' + this.surroundingPhotoData.GD901001Parameter.registPhotoCount);
            // this.surroundingPhotoData.GD901001Parameter.registPhotoCount = this.surroundingPhotoData.photoCount;
            // System.debug('★★★アップロード後this.surroundingPhotoData.photoCount：' + this.surroundingPhotoData.photoCount);
            // System.debug('★★★アップロード後this.surroundingPhotoData.photoDataList.size()' + this.surroundingPhotoData.photoDataList.size());

            // スーモスコア再計算
            this.updateSuumoScore(this.targetBuilding, this.targetBuildingPhoto);

            // 建物写真更新前時点でSystemModStampに変更が無かった場合、SystemModStampを再取得する
            if (isNotOptimisticLockError) {
                this.displayTargetRecord.systemModStamp = this.getSystemModStamp(this.targetId);
            }

        } catch(Exception e) {
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // 周辺写真画像削除処理
    public void deleteSurroundingPhoto(){
        try {
            // エラーフラグ初期化
            this.hasErrorMessage = false;

            // SystemModStampの変更有無を取得する
            Boolean isNotOptimisticLockError = this.checkSystemModStamp(this.targetId);

            // 画像削除
            AmazonS3Util.callPhotoDelete(this.targetId, this.surroundingPhotoData.photoType, this.deletePhotoIndex);

            // 写真再読み込み（削除対象をリストから排除する）
            List<PhotoData> tempPhotoData = this.surroundingPhotoData.photoDataList.clone();
            this.surroundingPhotoData.photoDataList = new List<PhotoData>();
            this.surroundingPhotoData.photoCount = 0;
            this.surroundingPhotoData.isNone = true;
            for (Integer i = 0; i < tempPhotoData.size(); i++) {
                if (tempPhotoData[i].index != this.deletePhotoIndex) {
                    this.surroundingPhotoData.isNone = false;
                    this.surroundingPhotoData.photoCount += 1;
                    this.surroundingPhotoData.photoDataList.add(tempPhotoData[i].clone());
                    this.surroundingPhotoData.photoDataList[this.surroundingPhotoData.photoCount - 1].index = this.surroundingPhotoData.photoCount;
                }
            }
            this.surroundingPhotoData.GD901001Parameter.registPhotoCount = this.surroundingPhotoData.photoCount;

            // スーモスコア再計算
            this.updateSuumoScore(this.targetBuilding, this.targetBuildingPhoto);

            // 建物写真更新前時点でSystemModStampに変更が無かった場合、SystemModStampを再取得する
            if (isNotOptimisticLockError) {
                this.displayTargetRecord.systemModStamp = this.getSystemModStamp(this.targetId);
            }
        } catch(Exception e) {
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // 画像一括削除処理 ▼問合せNo0345で追加
    public void deletePhotoAll(){

        Savepoint sp = Database.setSavepoint();      //セーブポイント作成
        try{
            this.hasErrorMessage = false;//エラーを初期化

            // SystemModStampの変更有無を取得する
            Boolean isNotOptimisticLockError = this.checkSystemModStamp(this.targetId);

            // 削除前周辺写真件数取得
            integer surroundingPhotoCount = this.surroundingPhotoData.photoCount;
            
            // 建物画像全削除
            AmazonS3Util.callOnlyBuildingPhotoDeleteAll(this.targetId);

            //建物写真情報を再取得
            for (ScreenAnyPhotoData photoData : this.anyPhotoData) {
                // 写真再読み込み
                this.reloadAnyPhotoData(photoData.photoType);
            }
            // 周辺写真情報設定
            this.surroundingPhotoData = new ScreenSurroundingPhotoData(this.targetBuildingPhoto, this.displayTargetRecord.foreignId, !this.isUnnecessaryMosaic);

            // 削除前に周辺写真がアップされている場合、スーモスコアの再計算を行う
            if (surroundingPhotoCount > 0){
                // スーモスコア再計算
                this.updateSuumoScore(this.targetBuilding, this.targetBuildingPhoto);
            }

            // 建物写真更新前時点でSystemModStampに変更が無かった場合、SystemModStampを再取得する
            if (isNotOptimisticLockError) {
                this.displayTargetRecord.systemModStamp = this.getSystemModStamp(this.targetId);
            }
            this.isImageUploadFlg = false; //画像の有無フラグをFalseに
        }catch(Exception e){
            
            Database.rollback(sp);//処理をロールバック
            this.hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
            
        }
    }
    // 画像一括削除処理 ▲問合せNo0345で追加

    /**
     * メンテナンス建物コード履歴の削除
     */
    public void delBuildingCdHist() {

        this.hasErrorMessage = false;
        Savepoint sp = Database.setsavepoint();
    
        try {
            //  メンテナンス建物コード履歴の削除リストを取得
            List<BuildingCodeHistory__c> delList = new List<BuildingCodeHistory__c>();
            for (ScreenBuildingCdHist detail : this.screenBuildingCdHistList) {
                if (detail.isSelected){
                    delList.add(detail.Entity);
                }
            }
        
            // 楽観ロックチェック
            if (!CommonUtil.isOptimisticLock(delList)) {
                throw new OptimisticLockException();
            }
            
            // メンテナンス建物コード履歴の削除
            if (delList.size() > 0) {
                SecureDML.secureDelete(delList);
            }
            
            // メンテナンス建物コード履歴の設定
            this.setScreenBuildingCdHist(this.targetId);
        
        } catch(Exception e) {
            database.rollback(sp);
            this.hasErrorMessage = True;
            CommonUtil.setErrorMessage(e);
        }
    }

    /**
     * メンテナンス物件コードの存在フラグの設定
     */
    public void setExistsMaintPropCdFlg() {

        // 建物に紐づく物件の取得
        Map<Id, Property__c> propMap = new Map<Id, Property__c>();
        if (this.targetPropertyList.size() > 0) {
            propMap = new Map<Id, Property__c>(this.targetPropertyList);
        }

        // 物件コード履歴の取得
        List<PropertyCodeHistory__c> propertyCdHist;
        propertyCdHist = [SELECT Id
                          FROM PropertyCodeHistory__c
                          WHERE Property__c = :propMap.keySet()
                                AND HistoryMaintenancePropertyCode__c != null
                                AND HistoryMaintenancePropertyCode__c != '手動登録'];

        // 取込先 = "手動"後の建物に紐づくメンテナンス物件コードが存在するかチェック
        this.existsMaintPropCd = (propertyCdHist.size() > 0) ? true: false;
    }
    // ▼ 2022.04.07 No.782 問合せNo0782_建物画面の沿線名と駅名の登録について
    /**
     * 画面.路線1変更時処理
     * @param  なし
     * @return なし
     */
    public void changeTrainRoute1(){
        this.displayTargetRecord.station1Name = null;                      // 表示用の選択された駅を初期化
        this.displayTargetRecord.station1     = null;                          // 選択された駅を初期化
        this.displayTargetRecord.stations1    = new List<Station__c>();    // 選択された駅を初期化
    }
    /**
     * 画面.路線2変更時処理
     * @param  なし
     * @return なし
     */
    public void changeTrainRoute2(){
        this.displayTargetRecord.station2Name = null;                      // 表示用の選択された駅を初期化
        this.displayTargetRecord.station2     = null;                          // 選択された駅を初期化
        this.displayTargetRecord.stations2    = new List<Station__c>();    // 選択された駅を初期化
    }
    /**
     * 画面.路線3変更時処理
     * @param  なし
     * @return なし
     */
    public void changeTrainRoute3(){
        this.displayTargetRecord.station3Name = null;                      // 表示用の選択された駅を初期化
        this.displayTargetRecord.station3     = null;                          // 選択された駅を初期化
        this.displayTargetRecord.stations3    = new List<Station__c>();    // 選択された駅を初期化
    }

        /**
     * 駅１モーダルOpenの処理
     * @param  なし
     * @return なし
     */
    public void openStations1Modal() {
        try {
            hasErrorMessage = false;
            modalMode = 1;
            openModal();
        } catch(Exception e) {
            //エラーを設定
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    /**
     * 駅２モーダルOpenの処理
     * @param  なし
     * @return なし
     */
    public void openStations2Modal() {
        try {
            hasErrorMessage = false;
            modalMode = 2;
            openModal();
        } catch(Exception e) {
            //エラーを設定
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    /**
     * 駅３モーダルOpenの処理
     * @param  なし
     * @return なし
     */
    public void openStations3Modal() {
        try {
            hasErrorMessage = false;
            modalMode = 3;
            openModal();
        } catch(Exception e) {
            //エラーを設定
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    /**
     * 駅Listから画面表示用の文字列作成
     * 
     * @param  List<Station__c> objList 対象となる駅のLIST
     * @return String           文字列(セミコロン区切り)
     */
    private String convStationListToString(List<Station__c> objList) {
        List<String> tmp = new List<String>();
        for (Station__c obj : objList) {
            tmp.add(obj.name);
        }
        return String.join(tmp, ';');
    }
    /**
     * OpenModal共通
     * @param  なし
     * @return なし
     */
    public void openModal() {
        if (modalMode == 1) {
            // 駅１
            this.GA104007Parameter.isDrawing          = true;
            this.GA104007Parameter.noFirst            = true;
            this.GA104007Parameter.singleChoice       = true; //単一選択フラグ=TRUE

            if (displayTargetRecord.trainRoute1 != null ){//選択された路線を設定
                this.GA104007Parameter.selectedTrainRoute = [SELECT Id, Name FROM TrainRoute__c WHERE Id = :displayTargetRecord.trainRoute1];
            }        
            this.GA104007Parameter.selectedStation = new List<Station__c>();//パラメータ初期化
            if (this.displayTargetRecord.stations1.size() > 0) {//選択された駅を設定
                this.GA104007Parameter.selectedStation    = this.displayTargetRecord.stations1;
            }

        } else if (modalMode == 2) {
            // 駅２
            this.GA104007Parameter.isDrawing          = true;
            this.GA104007Parameter.noFirst            = true;
            this.GA104007Parameter.singleChoice       = true; //単一選択フラグ=TRUE

            if (displayTargetRecord.trainRoute2 != null ){//選択された路線を設定
                this.GA104007Parameter.selectedTrainRoute = [SELECT Id, Name FROM TrainRoute__c WHERE Id = :displayTargetRecord.trainRoute2];
            }        
            this.GA104007Parameter.selectedStation = new List<Station__c>();//パラメータ初期化
            if (this.displayTargetRecord.stations2.size() > 0) {//選択された駅を設定
                this.GA104007Parameter.selectedStation    = this.displayTargetRecord.stations2;
            }
        } else if (modalMode == 3) {
            // 駅３
            this.GA104007Parameter.isDrawing          = true;
            this.GA104007Parameter.noFirst            = true;
            this.GA104007Parameter.singleChoice       = true; //単一選択フラグ=TRUE
            
            if (displayTargetRecord.trainRoute3 != null ){//選択された路線を設定
                this.GA104007Parameter.selectedTrainRoute = [SELECT Id, Name FROM TrainRoute__c WHERE Id = :displayTargetRecord.trainRoute3];
            }        
            this.GA104007Parameter.selectedStation = new List<Station__c>();//パラメータ初期化
            if (this.displayTargetRecord.stations3.size() > 0) {//選択された駅を設定
                this.GA104007Parameter.selectedStation    = this.displayTargetRecord.stations3;
            }
        }
    }
    
       /**
     * モーダル共通close
     *  ※modalModeの値により、モーダルを特定
     * @param  なし
     * @return なし
     */
    public void closeModal(){
        if(modalMode== 1){
            // 路線１
            this.displayTargetRecord.station1     = this.GA104007Parameter.selectedStation[0].id;//モーダルで選択された駅
            this.displayTargetRecord.stations1    = this.GA104007Parameter.selectedStation;
            this.displayTargetRecord.station1Name = convStationListToString(this.GA104007Parameter.selectedStation);//表示用のモーダルで選択された駅

        } else if(modalMode == 2){
            // 路線２
            this.displayTargetRecord.station2     = this.GA104007Parameter.selectedStation[0].id;//モーダルで選択された駅
            this.displayTargetRecord.stations2    = this.GA104007Parameter.selectedStation;
            this.displayTargetRecord.station2Name = convStationListToString(this.GA104007Parameter.selectedStation);//表示用のモーダルで選択された駅

        } else if(modalMode == 3){
            // 路線３
            this.displayTargetRecord.station3     = this.GA104007Parameter.selectedStation[0].id;//モーダルで選択された駅
            this.displayTargetRecord.stations3    = this.GA104007Parameter.selectedStation;
            this.displayTargetRecord.station3Name = convStationListToString(this.GA104007Parameter.selectedStation);//表示用のモーダルで選択された駅
        } 
        modalMode = 0;//モーダルの判別フラグを初期化
    }
    // ▲ 2022.04.07 No.782 問合せNo0782_建物画面の沿線名と駅名の登録について

//＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
//privateメソッド
//＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
    
    //初期設定
    private void init(){
        isUnnecessaryMosaic = true;// モザイク処理不要のフラグ初期値に設定 // 問合せ534 初期値trueに変更
        this.isImageUploadFlg = false; //画像の有無フラグ初期値に設定　//問合せNo0345で追加
        CommonUtil.getStaffCurrentShop();

        // 選択リストを取得
        stateOption                  = CommonUtil.getSelectOptionFromObject('Building__c', 'State__c');
        propertyTypeOption           = CommonUtil.getSelectOptionFromObject('Building__c', 'PropertyType__c');
        structureOption              = CommonUtil.getSelectOptionFromObject('Building__c', 'Structure__c');
        importTypeOption             = CommonUtil.getSelectOptionFromObject('Building__c', 'ImportType__c');
        caretakerTypeOption          = CommonUtil.getSelectOptionFromObject('Building__c', 'CaretakerType__c');
        surroundingEnvironmentOption = CommonUtil.getSelectOptionFromObject('BuildingPhoto__c', 'SurroundingTag1__c'); // 建物写真．周辺写真タグ
        districtList                 = CommonUtil.getSelectOptionFromObject('Building__c', 'District__c');

        elementarySchoolList         = CommonUtil.getSelectOptionFromObjectData(CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL,true);//小学校リスト
        elementarySchool2List        = CommonUtil.getSelectOptionFromObjectData(CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL,true);//小学校2リスト
        elementarySchool3List        = CommonUtil.getSelectOptionFromObjectData(CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL,true);//小学校3リスト
        juniorHighSchoolList         = CommonUtil.getSelectOptionFromObjectData(CommonConst.SCHOOL_TYPE_JUNIORHIGHSCHOOL,true);//中学校リスト
        juniorHighSchool2List        = CommonUtil.getSelectOptionFromObjectData(CommonConst.SCHOOL_TYPE_JUNIORHIGHSCHOOL,true);//中学校2リスト
        juniorHighSchool3List        = CommonUtil.getSelectOptionFromObjectData(CommonConst.SCHOOL_TYPE_JUNIORHIGHSCHOOL,true);//中学校3リスト
        this.trainRouteOption        = CommonUtil.getSelectOptionFromObjectData('TrainRoute__c','Id','Name', 'SortOrder__c');// 路線 2022.04.07 No.782 問合せNo0782_建物画面の沿線名と駅名の登録について

        // モーダルに渡すパラメータを初期化
        this.GA102006Parameter = new GA102006ParameterClass();
        this.GA104007Parameter = new GA104007ParameterClass();   // 駅モーダルパラメタ 2022.04.07 No.782 問合せNo0782_建物画面の沿線名と駅名の登録について　

    }
    
    // 名寄せフラグ設定
    private Building__c setTargetRecordIsMergeCompletedFlag (Building__c upSertBuilding){

        // 名寄せチェックのために、都道府県、住所1、住所2を文字列で持つ
        String targetBuildingRecordState  = '';
        String targetBuildingRecordCity   = '';
        String targetBuildingRecordStreet = '';
        
        // 都道府県、住所1、住所2を取得する
        if(this.displayTargetRecord.targetBuildingRecord.State__c != null){// 都道府県
            targetBuildingRecordState = this.displayTargetRecord.targetBuildingRecord.State__c;
        }
        if(this.displayTargetRecord.targetBuildingRecord.City__c != null){// 住所1
            targetBuildingRecordCity = this.displayTargetRecord.targetBuildingRecord.City__c;
        }
        if(this.displayTargetRecord.targetBuildingRecord.Street__c != null){// 住所2
            targetBuildingRecordStreet = this.displayTargetRecord.targetBuildingRecord.Street__c;
        }
        
        // 建物の新規作成の場合か、編集時に建物名か「都道府県＋住所1＋住所2」の値が変更されていた場合に、名寄せの確認を行う
        if(isNew
           ||CommonUtil.isDifferenceTwoString(this.displayTargetRecord.targetBuildingRecord.Name, this.displayTargetRecord.buildName)//建物名1
           ||CommonUtil.isDifferenceTwoString(this.displayTargetRecord.targetBuildingRecord.BuildKana__c, this.displayTargetRecord.buildNameKana)//建物名1カナ
           ||CommonUtil.isDifferenceTwoString(this.displayTargetRecord.targetBuildingRecord.BuildName2__c, this.displayTargetRecord.buildName2)//建物名2
           ||CommonUtil.isDifferenceTwoString(this.displayTargetRecord.targetBuildingRecord.BuildKana2__c, this.displayTargetRecord.buildNameKana2)//建物名2カナ
           ||CommonUtil.isDifferenceTwoString(this.displayTargetRecord.targetBuildingRecord.BuildName3__c, this.displayTargetRecord.buildName3)//建物名3
           ||CommonUtil.isDifferenceTwoString(this.displayTargetRecord.targetBuildingRecord.BuildKana3__c, this.displayTargetRecord.buildNameKana3)//建物名3カナ
           ||CommonUtil.isDifferenceTwoString(targetBuildingRecordState, this.displayTargetRecord.state)//都道府県
           ||CommonUtil.isDifferenceTwoString(targetBuildingRecordCity,this.displayTargetRecord.city)//住所1
           ||CommonUtil.isDifferenceTwoString(targetBuildingRecordStreet,this.displayTargetRecord.street)//住所2
          ){
              // 名寄せ確認に数式を使用しているので、確認前に数式の再計算を行う
              upSertBuilding.recalculateFormulas();
              
              List<Building__c> nameMergeList = NameMergeUtil.getBuildingMergeList(upSertBuilding, null);// 名寄せ確認

              if(nameMergeList.size() == 0){// 名寄せ確認の結果0件なら名寄せ完了
                  upSertBuilding.IsMergeCompletedFlag__c = true;
              } else {// 名寄せ確認の結果0件でないなら名寄せ未完了
                  upSertBuilding.IsMergeCompletedFlag__c = false;
              }
          }
        return upSertBuilding;// 名寄せフラグを設定した建物レコードを返す
    }
    

    //町字コードを設定
    private void setChoazaCode() {
        String searchWord = displayTargetRecord.state + displayTargetRecord.city;// 検索文字列の作成
        
        // 町字コードの取得
        List<JapanGeographicDataCenterAddress__c> inDataCenterAddress = [
            SELECT ChoazaCodeNew__c
            FROM JapanGeographicDataCenterAddress__c
            WHERE ObsoleteYM__c = '000000'
            AND PlaceName__c = :searchWord
        ];
        
        if(inDataCenterAddress.size()>0){// 町字コードの取得ができれば設定
            displayTargetRecord.choazaCode = inDataCenterAddress[0].ChoazaCodeNew__c;
        }else{// 町字コードの取得ができなければ初期化
            displayTargetRecord.choazaCode = '';
        }
    }
    
    // 建物の取得
    private void getBuilding(){
        //パラメータの建物IDを使用して建物を取得
        list<Building__c> myBuilding = [SELECT ID
                                        ,Name// 建物名
                                        ,BuildKana__c// 建物名（カナ）
                                        ,BuildName2__c// 建物名２
                                        ,BuildKana2__c// 建物名（カナ）２
                                        ,BuildName3__c// 建物名３
                                        ,BuildKana3__c// 建物名（カナ）３
                                        ,PostalCode__c// 郵便番号
                                        ,State__c// 都道府県
                                        ,Address__c// 住所
                                        ,City__c// 住所１（市区町村）
                                        ,Street__c// 住所２（番地）
                                        ,District__c// 地区
                                        ,ChoazaCode__c// 町字コード
                                        ,PropertyType__c// 物件種別
                                        ,Structure__c// 建物構造
                                        ,BuildingYM__c// 築年月
                                        ,BuildingYMFormat__c// 築年月
                                        ,BuildingAge__c// 築年数
                                        ,GroundFloorCount__c // 地上階数
                                        ,UndergroundFloorCount__c// 地下階数
                                        ,HouseCount__c// 棟総戸数
                                        ,Leasehold__c// 借地権
                                        ,Location__c// 地勢
                                        ,CaretakerType__c// 管理人種別
                                        ,Longitude__c// 経度
                                        ,Latitude__c// 緯度
                                        ,BuildingRemarksPublic__c// 建物備考（公開）
                                        ,BuildingRemarksPrivate__c// 建物備考（非公開）
                                        ,ImportType__c// 取込区分
                                        ,MaintenanceBuildingCode__c// メンテナンス建物コード
                                        ,PrimarySchool1__c// 小学校１Id
                                        ,PrimarySchool1__r.NAME// 小学校１
                                        ,PrimarySchool1__r.PhotoFilePath__c// 小学校１の写真
                                        ,PrimarySchoolDistance1__c// 小学校までの距離１
                                        ,PrimarySchoolWalkTime1__c// 小学校までの時間（分）１
                                        ,PrimarySchoolWalkTimeFormat1__c// 小学校までの時間（分）１
                                        ,JuniorHighSchool1__c// 中学校１Id
                                        ,JuniorHighSchool1__r.NAME// 中学校１
                                        ,JuniorHighSchool1__r.PhotoFilePath__c// 中学校１の写真
                                        ,JuniorHighSchoolDistance1__c// 中学校までの距離１
                                        ,JuniorHighSchoolWalkTime1__c// 中学校までの時間（分）１
                                        ,JuniorHighSchoolWalkTimeFormat1__c// 中学校までの時間（分）１
                                        ,PrimarySchool2__r.NAME// 小学校２
                                        ,PrimarySchool2__r.PhotoFilePath__c// 小学校２の写真
                                        ,PrimarySchoolDistance2__c// 小学校までの距離２
                                        ,PrimarySchoolWalkTime2__c// 小学校までの時間（分）２
                                        ,PrimarySchoolWalkTimeFormat2__c// 小学校までの時間（分）2
                                        ,JuniorHighSchool2__c// 中学校２Id
                                        ,JuniorHighSchool2__r.NAME// 中学校２
                                        ,JuniorHighSchool2__r.PhotoFilePath__c// 中学校２の写真
                                        ,JuniorHighSchoolDistance2__c// 中学校までの距離２
                                        ,JuniorHighSchoolWalkTime2__c// 中学校までの時間（分）２
                                        ,JuniorHighSchoolWalkTimeFormat2__c// 中学校までの時間（分）2
                                        ,PrimarySchool3__r.NAME// 小学校３
                                        ,PrimarySchool3__r.PhotoFilePath__c// 小学校３の写真
                                        ,PrimarySchoolDistance3__c// 小学校までの距離３
                                        ,PrimarySchoolWalkTime3__c// 小学校までの時間（分）３
                                        ,PrimarySchoolWalkTimeFormat3__c// 小学校までの時間（分）3
                                        ,JuniorHighSchool3__c// 中学校３ID
                                        ,JuniorHighSchool3__r.NAME// 中学校３
                                        ,JuniorHighSchool3__r.PhotoFilePath__c// 中学校３の写真
                                        ,JuniorHighSchoolDistance3__c// 中学校までの距離３
                                        ,JuniorHighSchoolWalkTime3__c// 中学校までの時間（分）３
                                        ,JuniorHighSchoolWalkTimeFormat3__c// 中学校までの時間（分）３
                                        ,HighSchool__c// 高校ID
                                        ,HighSchool__r.NAME// 高校
                                        ,HighSchool__r.PhotoFilePath__c// 高校の写真
                                        ,HighSchoolDistance__c// 高校までの距離
                                        ,HighSchoolWalkTime__c// 高校までの時間（分）
                                        ,HighSchoolWalkTimeFormat__c// 高校までの時間（分）
                                        ,University__c// 大学ID
                                        ,University__r.NAME// 大学
                                        ,University__r.PhotoFilePath__c// 大学の写真
                                        ,UniversityDistance__c// 大学までの距離
                                        ,UniversityWalkTime__c// 大学までの時間（分）
                                        ,UniversityWalkTimeFormat__c// 大学までの時間（分）
                                        ,ConvenienceStore__c// コンビニID
                                        ,ConvenienceStore__r.NAME// コンビニ
                                        ,ConvenienceStore__r.PhotoFilePath__c// コンビニの写真
                                        ,ConvenienceStoreDistance__c// コンビニまでの距離
                                        ,ConvenienceStoreWalkTime__c// コンビニまでの時間（分）
                                        ,ConvenienceStoreWalkTimeFormat__c// コンビニまでの時間（分）
                                        ,Supermarket__c// スーパーマーケットID
                                        ,Supermarket__r.NAME// スーパーマーケット
                                        ,Supermarket__r.PhotoFilePath__c// スーパーマーケットの写真
                                        ,SupermarketDistance__c// スーパーマーケットまでの距離
                                        ,SupermarketWalkTime__c// スーパーマーケットまでの時間（分）
                                        ,SupermarketWalkTimeFormat__c// スーパーマーケットまでの時間（分）
                                        ,GeneralHospital__c// 総合病院ID
                                        ,GeneralHospital__r.NAME// 総合病院
                                        ,GeneralHospital__r.PhotoFilePath__c// 総合病院の写真
                                        ,GeneralHospitalDistance__c// 総合病院までの距離
                                        ,GeneralHospitalWalkTime__c// 総合病院までの時間（分）
                                        ,GeneralHospitalWalkTimeFormat__c// 総合病院までの時間（分）
                                        ,TrainRoute1__c// 沿線１
                                        ,TrainRoute1__r.NAME// 沿線１
                                        ,Station1__c// 駅１
                                        ,Station1__r.NAME// 駅１
                                        ,StationDistance1__c// 駅までの距離
                                        ,StationWalkTime1__c    // 駅までの時間(分)１
                                        ,StationWalkTimeFormat1__c// 駅までの時間(分)１
                                        ,BusRoute1__c// バス路線名
                                        ,BusStop1__c// バス停
                                        ,BusStopDistance1__c// バス停までの距離
                                        ,BusRideTime1__c// バス乗車時間（分）１
                                        ,BusRideTimeFormat1__c// バス乗車時間（分）１
                                        ,BusStopToStationDistance1__c// バス停からの距離
                                        ,TrainRoute2__c// 沿線２
                                        ,TrainRoute2__r.NAME// 沿線２
                                        ,Station2__c// 駅２
                                        ,Station2__r.NAME// 駅２
                                        ,StationDistance2__c// 駅までの距離２
                                        ,StationWalkTime2__c// 駅までの時間(分)２
                                        ,StationWalkTimeFormat2__c// 駅までの時間(分)２
                                        ,BusRoute2__c// バス路線名２
                                        ,BusStop2__c// バス停２
                                        ,BusStopDistance2__c// バス停までの距離２
                                        ,BusRideTime2__c// バス乗車時間（分）２
                                        ,BusRideTimeFormat2__c// バス乗車時間（分）２
                                        ,BusStopToStationDistance2__c// バス停からの距離２
                                        ,TrainRoute3__c// 沿線３
                                        ,TrainRoute3__r.NAME// 沿線３
                                        ,Station3__c// 駅３
                                        ,Station3__r.NAME// 駅３
                                        ,StationDistance3__c// 駅までの距離３
                                        ,StationWalkTime3__c// 駅までの時間(分)３
                                        ,StationWalkTimeFormat3__c// 駅までの時間(分)３
                                        ,BusRoute3__c// バス路線名３
                                        ,BusStop3__c// バス停３
                                        ,BusStopDistance3__c// バス停までの距離３
                                        ,BusRideTime3__c// バス乗車時間（分）３
                                        ,BusRideTimeFormat3__c// バス乗車時間（分）３
                                        ,BusStopToStationDistance3__c// バス停からの距離３
                                        ,MaintenanceComment__c// メンテナンスコメント
                                        ,systemModStamp// 最終更新日
                                        ,IsMergeCompletedFlag__c// 名寄せ完了フラグ
                                        ,IsFirstSurroundingImportFlag__c//初回周辺取込フラグ
                                        ,ForeignID__c// 外部Id
                                        FROM Building__c WHERE ID = :targetId];
        
        if(myBuilding.size() > 0){//建物が取得できれば表示用内部クラスに建物を設定
            targetBuilding = myBuilding[0];
            displayTargetRecord = new displayBuilding(myBuilding[0]);
        }else{//建物が取得できなければエラー
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
            throw ex;
        }
    }
    
    // 建物メンテナンス履歴の取得
    private void getTargetBuildingMaintenanceHistoryList(){
        targetBuildingMaintenanceHistoryList = new List<BuildingMaintenanceHistory__c>();// 建物メンテナンス履歴を初期化

        // パラメータの建物IDを使用して建物メンテナンス履歴を取得
        targetBuildingMaintenanceHistoryList = [SELECT ID
                                                ,MaintenanceComment__c    // メンテナンスコメント
                                                ,CreatedDate              // 作成日
                                                ,MaintenanceType__c       // メンテナンス区分
                                                ,MaintenanceStaff__r.Name // メンテナンススタッフ名前
                                                FROM BuildingMaintenanceHistory__c WHERE Building__c = :targetId
                                                ORDER BY CreatedDate  DESC];
        
    }
    
    
    // 建物に関わる物件の取得
    private void getTargetPropertyList(){
        targetPropertyList = new List<Property__c>();
        // パラメータの建物IDを使用して物件を取得
        targetPropertyList = [SELECT ID
                              ,Name// 部屋番号
                              ,LiveStatus__c// 現況
                              ,RoomLayout__c// 間取り
                              ,RoomArea__c// 専有面積（㎡）
                              ,RentFee__c// 賃料
                              ,PropertyPhotoCount__c// 物件写真枚数
                              ,Floor__c// 所在階
                              FROM Property__c WHERE Building__c = :targetId
                              ORDER BY Name ];
        // 所在階の最大値を取得
        this.propertyMaxfloor = null;
        for (Property__c property : targetPropertyList) {

            // nullチェック
            if (property.Floor__c == null) {
                continue;
            }

            // 最大値更新チェック
            if (this.propertyMaxfloor != null && this.propertyMaxfloor >= property.Floor__c) {
                continue;
            }

            this.propertyMaxfloor = property.Floor__c.intValue();
        }
    }

    
    
    // バス時間が範囲内か
    private Boolean isBusTimeWithinRange(Decimal timeInteger) {
        Boolean returnValue;
        if (timeInteger < 1 || timeInteger > 99) {
            returnValue = false;
        } else {
            returnValue = true;
        }
        return returnValue;
    }
    
    
    // 周辺情報取得呼び出し
    private void callGoogleApiUtil() {
        
        //周辺情報取得用 建物作成
        Building__c b = new Building__c();
        b.State__c      = displayTargetRecord.state;     //都道府県
        b.City__c       = displayTargetRecord.city;      //住所１
        b.Street__c     = displayTargetRecord.street;    //住所２
        b.Latitude__c   = displayTargetRecord.latitude;  //緯度
        b.Longitude__c  = displayTargetRecord.longitude; //経度
        b.ChoazaCode__c = displayTargetRecord.choazaCode;//町字コード
        
        //数式再計算 (住所項目用←周辺情報取得で使用する)
        b.recalculateFormulas();
        
        
        //周辺情報取得　呼び出し(変数の中が変更される)
        GoogleApiUtil.getPeripheralInformation(b);
        

        //数式再計算 (時間項目用←画面で使用する)
        b.recalculateFormulas();
        
        //画面に設定する
        displayTargetRecord.latitude  = b.Latitude__c;  //緯度
        displayTargetRecord.longitude = b.Longitude__c; //経度
        
        // 小中学校
        displayTargetRecord.primarySchool1         = b.PrimarySchool1__c;         //  小学校１　Id
        displayTargetRecord.primarySchoolDistance1 = CommonUtil.DecimalToString(b.PrimarySchoolDistance1__c); //  小学校までの距離１
        displayTargetRecord.displayCalculateFormulas.PrimarySchoolDistance1__c = b.PrimarySchoolDistance1__c; //数式用
        
        displayTargetRecord.primarySchool2         = b.PrimarySchool2__c;         //  小学校2　Id
        displayTargetRecord.primarySchoolDistance2 = CommonUtil.DecimalToString(b.PrimarySchoolDistance2__c); //  小学校までの距離2
        displayTargetRecord.displayCalculateFormulas.PrimarySchoolDistance2__c = b.PrimarySchoolDistance2__c; //数式用
        
        displayTargetRecord.primarySchool3         = b.PrimarySchool3__c;         //  小学校3　Id
        displayTargetRecord.primarySchoolDistance3 = CommonUtil.DecimalToString(b.PrimarySchoolDistance3__c); //  小学校までの距離3
        displayTargetRecord.displayCalculateFormulas.PrimarySchoolDistance3__c = b.PrimarySchoolDistance3__c; //数式用

        displayTargetRecord.juniorHighSchool1         = b.JuniorHighSchool1__c;         //  中学校１
        displayTargetRecord.juniorHighSchoolDistance1 = CommonUtil.DecimalToString(b.JuniorHighSchoolDistance1__c); //  中学校までの距離１
        displayTargetRecord.displayCalculateFormulas.JuniorHighSchoolDistance1__c = b.JuniorHighSchoolDistance1__c; //中学校までの時間（分）１
        
        displayTargetRecord.juniorHighSchool2         = b.JuniorHighSchool2__c;         //  中学校2
        displayTargetRecord.juniorHighSchoolDistance2 = CommonUtil.DecimalToString(b.JuniorHighSchoolDistance2__c); //  中学校までの距離2
        displayTargetRecord.displayCalculateFormulas.JuniorHighSchoolDistance2__c = b.JuniorHighSchoolDistance2__c; //中学校までの時間（分）2

        displayTargetRecord.juniorHighSchool3         = b.JuniorHighSchool3__c;         //  中学校3
        displayTargetRecord.juniorHighSchoolDistance3 = CommonUtil.DecimalToString(b.JuniorHighSchoolDistance3__c); //  中学校までの距離3
        displayTargetRecord.displayCalculateFormulas.JuniorHighSchoolDistance3__c = b.JuniorHighSchoolDistance3__c; //中学校までの時間（分）3
        
        displayTargetRecord.highSchool         = b.HighSchool__c;         //  高校
        displayTargetRecord.highSchoolDistance = b.HighSchoolDistance__c; //  高校までの距離
        displayTargetRecord.highSchoolWalkTime = b.HighSchoolWalkTime__c; //  高校までの時間（分）
        
        displayTargetRecord.university         = b.University__c;         //  大学
        displayTargetRecord.universityDistance = b.UniversityDistance__c; //  大学までの距離
        displayTargetRecord.universityWalkTime = b.UniversityWalkTime__c; //  大学までの時間（分）
        
        displayTargetRecord.convenienceStore         = b.ConvenienceStore__c;         // コンビニ
        displayTargetRecord.convenienceStoreDistance = b.ConvenienceStoreDistance__c; //  コンビニまでの距離
        displayTargetRecord.convenienceStoreWalkTime = b.ConvenienceStoreWalkTime__c; //  コンビニまでの時間（分）
        
        displayTargetRecord.supermarket         = b.Supermarket__c;         //  スーパーマーケット
        displayTargetRecord.supermarketDistance = b.SupermarketDistance__c; //  スーパーマーケットまでの距離
        displayTargetRecord.supermarketWalkTime = b.SupermarketWalkTime__c; //  スーパーマーケットまでの時間（分）
        
        displayTargetRecord.generalHospital         = b.GeneralHospital__c;         //  総合病院
        displayTargetRecord.generalHospitalDistance = b.GeneralHospitalDistance__c; //  総合病院までの距離
        displayTargetRecord.generalHospitalWalkTime = b.GeneralHospitalWalkTime__c; //  総合病院までの時間（分）
        
        displayTargetRecord.trainRoute1      = b.TrainRoute1__c;      //  沿線１
        displayTargetRecord.station1         = b.Station1__c;         //  駅１

        displayTargetRecord.stationDistance1 = CommonUtil.decimalToString(b.StationDistance1__c); //  駅までの距離1
        displayTargetRecord.displayCalculateFormulas.StationDistance1__c = b.StationDistance1__c;    // 駅までの時間(分)1
        
        displayTargetRecord.trainRoute2      = b.TrainRoute2__c;      //  沿線２
        displayTargetRecord.station2         = b.Station2__c;         //  駅2
        displayTargetRecord.stationDistance2 = CommonUtil.decimalToString(b.StationDistance2__c); //  駅までの距離2
        displayTargetRecord.displayCalculateFormulas.StationDistance2__c = b.StationDistance2__c;    // 駅までの時間(分)2
        
        displayTargetRecord.trainRoute3      = b.TrainRoute3__c;      //  沿線３
        displayTargetRecord.station3         = b.Station3__c;         //  駅3
        displayTargetRecord.stationDistance3 = CommonUtil.decimalToString(b.StationDistance3__c); //  駅までの距離3
        displayTargetRecord.displayCalculateFormulas.StationDistance3__c = b.StationDistance3__c;    // 駅までの距離3
        
        //周辺施設のリレーション先の項目設定(リレーションの先の情報を取得する必要がある)
        setFacilityName(b);

        // 建物レコードで数式の再計算処理を実施する
        displayTargetRecord.displayCalculateFormulas.recalculateFormulas(); 
    }
    
    
    //周辺施設の名前設定
    private void setFacilityName(Building__c b) {
        
        //学校
        Set<Id> schoolIdSet = new Set<Id>();//取得データ用IdSet作成
        schoolIdSet.add(b.PrimarySchool1__c);
        schoolIdSet.add(b.PrimarySchool2__c);
        schoolIdSet.add(b.PrimarySchool3__c);
        schoolIdSet.add(b.JuniorHighSchool1__c);
        schoolIdSet.add(b.JuniorHighSchool2__c);
        schoolIdSet.add(b.JuniorHighSchool3__c);
        
        // 小中学校
        Map<Id, School__c> schoolMap = new Map<Id, School__c>([SELECT Id, Name, PhotoFilePath__c FROM School__c WHERE Id IN :schoolIdSet]);
        displayTargetRecord.primarySchool1Name     = schoolMap.containsKey(b.PrimarySchool1__c)    ? schoolMap.get(b.PrimarySchool1__c).Name    : null; //  小学校1名
        displayTargetRecord.primarySchool2Name     = schoolMap.containsKey(b.PrimarySchool2__c)    ? schoolMap.get(b.PrimarySchool2__c).Name    : null; //  小学校2名
        displayTargetRecord.primarySchool3Name     = schoolMap.containsKey(b.PrimarySchool3__c)    ? schoolMap.get(b.PrimarySchool3__c).Name    : null; //  小学校3名
        displayTargetRecord.juniorHighSchool1Name  = schoolMap.containsKey(b.JuniorHighSchool1__c) ? schoolMap.get(b.JuniorHighSchool1__c).Name : null; //  中学校1名
        displayTargetRecord.juniorHighSchool2Name  = schoolMap.containsKey(b.JuniorHighSchool2__c) ? schoolMap.get(b.JuniorHighSchool2__c).Name : null; //  中学校2名
        displayTargetRecord.juniorHighSchool3Name  = schoolMap.containsKey(b.JuniorHighSchool3__c) ? schoolMap.get(b.JuniorHighSchool3__c).Name : null; //  中学校3名
        
        displayTargetRecord.primarySchoolFilePath1     = schoolMap.containsKey(b.PrimarySchool1__c)    ? schoolMap.get(b.PrimarySchool1__c).PhotoFilePath__c    : null; //  小学校1写真
        displayTargetRecord.primarySchoolFilePath2     = schoolMap.containsKey(b.PrimarySchool2__c)    ? schoolMap.get(b.PrimarySchool2__c).PhotoFilePath__c    : null; //  小学校2写真
        displayTargetRecord.primarySchoolFilePath3     = schoolMap.containsKey(b.PrimarySchool3__c)    ? schoolMap.get(b.PrimarySchool3__c).PhotoFilePath__c    : null; //  小学校3写真
        displayTargetRecord.juniorHighSchoolFilePath1  = schoolMap.containsKey(b.JuniorHighSchool1__c) ? schoolMap.get(b.JuniorHighSchool1__c).PhotoFilePath__c : null; //  中学校1写真
        displayTargetRecord.juniorHighSchoolFilePath2  = schoolMap.containsKey(b.JuniorHighSchool2__c) ? schoolMap.get(b.JuniorHighSchool2__c).PhotoFilePath__c : null; //  中学校2写真
        displayTargetRecord.juniorHighSchoolFilePath3  = schoolMap.containsKey(b.JuniorHighSchool3__c) ? schoolMap.get(b.JuniorHighSchool3__c).PhotoFilePath__c : null; //  中学校3写真
        
        
        //周辺施設
        Set<Id> facilityIdSet = new Set<Id>();//取得データ用IdSet作成
        facilityIdSet.add(b.HighSchool__c);
        facilityIdSet.add(b.University__c);
        facilityIdSet.add(b.ConvenienceStore__c);
        facilityIdSet.add(b.SuperMarket__c);
        
        Map<Id, SurroundingFacility__c> facilityMap = new Map<Id, SurroundingFacility__c>([SELECT Id, Name, PhotoFilePath__c FROM SurroundingFacility__c WHERE Id IN :facilityIdSet]);
        displayTargetRecord.highSchoolName       = facilityMap.containsKey(b.HighSchool__c)       ? facilityMap.get(b.HighSchool__c).Name       : null; //  高校名
        displayTargetRecord.universityName       = facilityMap.containsKey(b.University__c)       ? facilityMap.get(b.University__c).Name       : null; //  大学名
        displayTargetRecord.convenienceStoreName = facilityMap.containsKey(b.ConvenienceStore__c) ? facilityMap.get(b.ConvenienceStore__c).Name : null; //  コンビニ名
        displayTargetRecord.superMarketName      = facilityMap.containsKey(b.SuperMarket__c)      ? facilityMap.get(b.SuperMarket__c).Name      : null; //  スーパー名
        
        displayTargetRecord.highSchoolFilePath       = facilityMap.containsKey(b.HighSchool__c)       ? facilityMap.get(b.HighSchool__c).PhotoFilePath__c       : null; //  高校写真
        displayTargetRecord.universityFilePath       = facilityMap.containsKey(b.University__c)       ? facilityMap.get(b.University__c).PhotoFilePath__c       : null; //  大学写真
        displayTargetRecord.convenienceStoreFilePath = facilityMap.containsKey(b.ConvenienceStore__c) ? facilityMap.get(b.ConvenienceStore__c).PhotoFilePath__c : null; //  コンビニ写真
        displayTargetRecord.superMarketFilePath      = facilityMap.containsKey(b.SuperMarket__c)      ? facilityMap.get(b.SuperMarket__c).PhotoFilePath__c      : null; //  スーパー写真
        
        //病院
        Set<Id> hospitalIdSet = new Set<Id>();//取得データ用IdSet作成
        hospitalIdSet.add(b.GeneralHospital__c);

        Map<Id, Hospital__c> hospitalMap = new Map<Id, Hospital__c>([SELECT Id, Name, PhotoFilePath__c FROM Hospital__c WHERE Id IN :hospitalIdSet]);
        displayTargetRecord.generalHospitalName  = hospitalMap.containsKey(b.GeneralHospital__c) ? hospitalMap.get(b.GeneralHospital__c).Name : null;        //  病院名
        // 2022.03.31 No0781 generalHospitalPhotoFilePathが表示に使用されていないためgeneralHospitalFilePathへ変更
		displayTargetRecord.generalHospitalFilePath  = hospitalMap.containsKey(b.GeneralHospital__c) ? hospitalMap.get(b.GeneralHospital__c).PhotoFilePath__c : null;  //  病院写真

        
        //沿線
        Set<Id> trainRouteIdSet = new Set<Id>();//取得データ用IdSet作成
        trainRouteIdSet.add(b.TrainRoute1__c);
        trainRouteIdSet.add(b.TrainRoute2__c);
        trainRouteIdSet.add(b.TrainRoute3__c);
        
        Map<Id, TrainRoute__c> trainRouteMap = new Map<Id, TrainRoute__c>([SELECT Id, Name FROM TrainRoute__c WHERE Id IN :trainRouteIdSet]);
        displayTargetRecord.trainRoute1Name     = trainRouteMap.containsKey(b.TrainRoute1__c) ? trainRouteMap.get(b.TrainRoute1__c).Name : null; //  沿線1名
        displayTargetRecord.trainRoute2Name     = trainRouteMap.containsKey(b.TrainRoute2__c) ? trainRouteMap.get(b.TrainRoute2__c).Name : null; //  沿線2名
        displayTargetRecord.trainRoute3Name     = trainRouteMap.containsKey(b.TrainRoute3__c) ? trainRouteMap.get(b.TrainRoute3__c).Name : null; //  沿線3名
        
        
        //駅
        Set<Id> stationIdSet = new Set<Id>();//取得データ用IdSet作成
        stationIdSet.add(b.Station1__c);
        stationIdSet.add(b.Station2__c);
        stationIdSet.add(b.Station3__c);
        
        Map<Id, Station__c> stationMap = new Map<Id, Station__c>([SELECT Id, Name FROM Station__c WHERE Id IN :stationIdSet]);
        displayTargetRecord.station1Name     = stationMap.containsKey(b.Station1__c) ? stationMap.get(b.Station1__c).Name : null; //  駅1名
        displayTargetRecord.station2Name     = stationMap.containsKey(b.Station2__c) ? stationMap.get(b.Station2__c).Name : null; //  駅2名
        displayTargetRecord.station3Name     = stationMap.containsKey(b.Station3__c) ? stationMap.get(b.Station3__c).Name : null; //  駅3名
        //  ▼　2022.04.15 No.782 問合せNo0782_建物画面の沿線名と駅名の登録について
        station__c bs1 = new station__c(id=b.Station1__c,Name=displayTargetRecord.station1Name);
        displayTargetRecord.stations1        = new List<Station__c>{bs1}; //  表示用のモーダルで選択された駅1
        station__c bs2 = new station__c(id=b.Station2__c,Name=displayTargetRecord.station2Name);
        displayTargetRecord.stations2        = new List<Station__c>{bs2}; //  表示用のモーダルで選択された駅2
        station__c bs3 = new station__c(id=b.Station3__c,Name=displayTargetRecord.station3Name);
        displayTargetRecord.stations3        = new List<Station__c>{bs3}; //  表示用のモーダルで選択された駅3
        //  ▲　2022.04.15 No.782 問合せNo0782_建物画面の沿線名と駅名の登録について
    }
    
    /**
     * メンテナンス建物コード履歴を設定
     * @param String buildingId 建物ID
     */
    private void setScreenBuildingCdHist(String buildingId) {

        // 名寄せ先に紐づく建物コード履歴を取得
        List<BuildingCodeHistory__c> buildingCdHistList = [SELECT Id
                                                                  , Building__c
                                                                  , HistoryBuilding__c
                                                                  , HistoryMaintenanceBuildingCode__c
                                                                  , HistoryImportDestination__c
                                                                  , InformationUpdateDate__c
                                                                  , SystemModStamp
                                                           FROM BuildingCodeHistory__c
                                                           WHERE Building__c = :buildingId
                                                           ORDER BY InformationUpdateDate__c DESC];

        // 明細を設定
        this.screenBuildingCdHistList = new List<ScreenBuildingCdHist>();
        List<ScreenBuildingCdHist> tmpList = new List<ScreenBuildingCdHist>();
        for (BuildingCodeHistory__c buildingCdHist : buildingCdHistList) {

            // 親を先頭行に表示
            if (buildingCdHist.Building__c == buildingCdHist.HistoryBuilding__c) {
                this.screenBuildingCdHistList.add(new ScreenBuildingCdHist(buildingCdHist));
            } else {
                tmpList.add(new ScreenBuildingCdHist(buildingCdHist));
            }
        }
        this.screenBuildingCdHistList.addAll(tmpList);
    }

    // 写真関連情報の取得・設定
    private void getPhotoData() {
        // 建物写真情報取得
        this.targetBuildingPhoto = this.selectBuildingPhoto(this.targetId);

        // 写真情報設定（周辺写真以外）
        this.anyPhotoData = new List<ScreenAnyPhotoData>();
        this.anyPhotoData.add(new ScreenAnyPhotoData(this.targetBuildingPhoto, this.displayTargetRecord.foreignId, AmazonS3Util.PhotoType.BUILDING_APPEARANCE, !this.isUnnecessaryMosaic));        // 建物外観
        this.anyPhotoData.add(new ScreenAnyPhotoData(this.targetBuildingPhoto, this.displayTargetRecord.foreignId, AmazonS3Util.PhotoType.BUILDING_APPEARANCEPARSE, !this.isUnnecessaryMosaic));   // 外観パース
        this.anyPhotoData.add(new ScreenAnyPhotoData(this.targetBuildingPhoto, this.displayTargetRecord.foreignId, AmazonS3Util.PhotoType.BUILDING_ENTRANCE, !this.isUnnecessaryMosaic));          // エントランス
        this.anyPhotoData.add(new ScreenAnyPhotoData(this.targetBuildingPhoto, this.displayTargetRecord.foreignId, AmazonS3Util.PhotoType.BUILDING_LOBBY, !this.isUnnecessaryMosaic));             // ロビー
        this.anyPhotoData.add(new ScreenAnyPhotoData(this.targetBuildingPhoto, this.displayTargetRecord.foreignId, AmazonS3Util.PhotoType.BUILDING_PARKING, !this.isUnnecessaryMosaic));           // 駐車場
        this.anyPhotoData.add(new ScreenAnyPhotoData(this.targetBuildingPhoto, this.displayTargetRecord.foreignId, AmazonS3Util.PhotoType.BUILDING_OTHERSHARING, !this.isUnnecessaryMosaic));      // その他共有
        this.anyPhotoData.add(new ScreenAnyPhotoData(this.targetBuildingPhoto, this.displayTargetRecord.foreignId, AmazonS3Util.PhotoType.BUILDING_MAP, !this.isUnnecessaryMosaic));               // 地図
        this.anyPhotoData.add(new ScreenAnyPhotoData(this.targetBuildingPhoto, this.displayTargetRecord.foreignId, AmazonS3Util.PhotoType.BUILDING_OTHER, !this.isUnnecessaryMosaic));             // その他

        // 周辺写真情報設定
        this.surroundingPhotoData = new ScreenSurroundingPhotoData(this.targetBuildingPhoto, this.displayTargetRecord.foreignId, !this.isUnnecessaryMosaic);

    }
    // 写真情報（周辺写真以外）の再読み込み
    private void reloadAnyPhotoData(AmazonS3Util.PhotoType photoType) {
        // 建物写真情報取得
        this.targetBuildingPhoto = this.selectBuildingPhoto(this.targetId);
        for (Integer i = 0; i < this.anyPhotoData.size(); i++) {
            if (this.anyPhotoData[i].photoType == photoType) {
                this.anyPhotoData[i] = new ScreenAnyPhotoData(this.targetBuildingPhoto, this.displayTargetRecord.foreignId, photoType, !this.isUnnecessaryMosaic);
            }
        }
    }
    // 周辺写真情報の再読み込み
    private void reloadSurroundingPhotoData() {
        // 建物写真情報取得
        this.targetBuildingPhoto = this.selectBuildingPhoto(this.targetId);
        // 周辺写真情報設定
        this.surroundingPhotoData = new ScreenSurroundingPhotoData(this.targetBuildingPhoto, this.displayTargetRecord.foreignId, !this.isUnnecessaryMosaic);
        System.Debug('this.surroundingPhotoData.photoDataList.size()'+this.surroundingPhotoData.photoDataList.size());
    }

    // 建物写真情報の抽出
    private BuildingPhoto__c selectBuildingPhoto(Id targetBuildingId){
        String sql = '';
        sql += 'SELECT Id ';
        sql += '      ,AppearanceFileName__c ';         // 建物外観
        sql += '      ,AppearanceFilePath__c ';
        sql += '      ,AppearanceComment__c ';
        sql += '      ,AppearanceParseFileName__c ';    // 外観パース
        sql += '      ,AppearanceParseFilePath__c ';
        sql += '      ,AppearanceParseComment__c ';
        sql += '      ,EntranceFileName__c ';           // エントランス
        sql += '      ,EntranceFilePath__c ';
        sql += '      ,EntranceComment__c ';
        sql += '      ,LobbyFileName__c ';              // ロビー
        sql += '      ,LobbyFilePath__c ';
        sql += '      ,LobbyComment__c ';
        sql += '      ,ParkingFileName__c ';            // 駐車場
        sql += '      ,ParkingFilePath__c ';
        sql += '      ,ParkingComment__c ';
        sql += '      ,OtherSharingFileName__c ';       // その他共有
        sql += '      ,OtherSharingFilePath__c ';
        sql += '      ,OtherSharingComment__c ';
        sql += '      ,MapFileName__c ';                // 地図
        sql += '      ,MapFilePath__c ';
        sql += '      ,MapComment__c ';
        sql += '      ,OtherFileName__c ';              // その他
        sql += '      ,OtherFilePath__c ';
        sql += '      ,OtherComment__c ';
        for (Integer i = 1; i <= CommonConst.MAXINDEX_BUILDING_SURROUNDING; i++) {  // 周辺写真
        sql += '      ,SurroundingFileName' + i + '__c ';
        sql += '      ,SurroundingFilePath' + i + '__c ';
        sql += '      ,SurroundingTag' + i + '__c ';
        sql += '      ,SurroundingComment' + i + '__c ';
        sql += '      ,SurroundingPhotoName' + i + '__c ';
        sql += '      ,SurroundingDistance' + i + '__c ';
        }
        sql += '      ,PhotoCount__c ';     // 写真枚数 //問合せNo0345で追加
        sql += '  FROM BuildingPhoto__c ';
        sql += ' WHERE Building__c = :targetBuildingId ';
        List<BuildingPhoto__c> buildingPhoto = Database.query(sql);
        if (buildingPhoto.isEmpty()){
            buildingPhoto = new List<BuildingPhoto__c>();
            return new BuildingPhoto__c();
        }
        setImageUploadflg(buildingPhoto[0]); // 写真枚数によりボタン制御のフラグを設定する  //問合せNo0345で追加
        return buildingPhoto[0];
    }

    //▼問合せNo0345で追加
    // 建物写真の写真枚数からフラグの設定をする
    private void setImageUploadflg(BuildingPhoto__c buildingPhoto){
        this.isImageUploadFlg = false;
        //画像の有無フラグをTrueに設定
        if(buildingPhoto.PhotoCount__c > 0){
            this.isImageUploadFlg = true;
        }    
    }
    //▲問合せNo0345で追加

    // SystemModStampのチェック
    private Boolean checkSystemModStamp(Id buildingId) {
        Datetime nowDatetime = this.getSystemModStamp(buildingId);
        if (nowDatetime != this.displayTargetRecord.systemModStamp) {
            return false;
        }
        return true;
    }
    // SystemModStampの取得
    private Datetime getSystemModStamp(Id buildingId) {
        List<Building__c> build = [
            SELECT
                SystemModStamp
            FROM
                Building__c
            WHERE
                Id = :buildingId
        ];
        if (build.size() == 0) {
            return null;
        }
        return build[0].SystemModStamp;
    }

    // スーモスコアの更新
    private void updateSuumoScore(Building__c build, BuildingPhoto__c buildPhoto) {
        // 物件情報取得
        List<Property__c> propList = selectPropertyList(this.targetId);
        // 物件写真情報取得
        List<PropertyPhoto__c> propPhotoList = selectPropertyPhotoList(this.targetId);
        // 物件写真を物件IdをキーにMapに格納
        Map<Id, PropertyPhoto__c> propPhotoMap = new Map<Id, PropertyPhoto__c>();
        for (Property__c prop : propList) {
            propPhotoMap.put(prop.Id, new PropertyPhoto__c());
            for (PropertyPhoto__c propPoto : propPhotoList) {
                if (propPoto.Property__c == prop.Id) {
                    propPhotoMap.put(prop.Id, propPoto);
                }
            }
        }

        // 建物IDを取得
        build = BuildingPropertyUtil.selectBuildingSurroundingFacilityPhoto(this.targetId);

        // スーモスコア再計算
        List<Property__c> updatePropList = new List<Property__c>();
        for (Property__c prop : propList) {
            // 再計算値取得
            Integer newScore = BuildingPropertyUtil.getSuumoScore(
                 build
                ,buildPhoto
                ,prop
                ,propPhotoMap.get(prop.Id)
                ,true
            );
            // スコアの現在値と再計算値に変化がある場合、更新情報を追加
            if (prop.Score__c != newScore) {
                updatePropList.add(
                    new Property__c(
                        Id = prop.Id
                        ,Score__c = newScore
                    )
                );
            }
        }
        // 更新
        if (updatePropList.size() > 0) {
            SecureDML.secureUpdate(updatePropList);
        }
    }

    // 物件情報取得（スーモスコア計算に使用）
    private List<Property__c> selectPropertyList(Id targetBuildingId) {
        List<Property__c> propertyList = [
            SELECT
                Id
                ,SuumoNetCatch__c           // SUUMOネット用キャッチ
                ,SuumoNetCatchComment__c    // SUUMOネット用キャッチコメント
                ,Score__c                   // 点数（スーモスコア）
            FROM
                Property__c
            WHERE
                Building__c = :targetBuildingId
        ];
        if (propertyList.isEmpty()){
            propertyList = new List<Property__c>();
        }
        return propertyList;
    }

    // 物件写真情報取得（スーモスコア計算に使用）
    private List<PropertyPhoto__c> selectPropertyPhotoList(Id targetBuildingId) {
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
        sql += ' WHERE Property__r.Building__c = :targetBuildingId ';
        List<PropertyPhoto__c> propertyPhotoList = Database.query(sql);
        if (propertyPhotoList.isEmpty()){
            propertyPhotoList = new List<PropertyPhoto__c>();
        }
        return propertyPhotoList;
    }

    // 学校写真の取得
    private String getPhotoFilePath(String SchoolId) {
        String PhotoPass = CommonConst.STRING_EMPTY;
        List<School__c> School = [SELECT PhotoFilePath__c FROM School__c WHERE Id = :SchoolId];

        if(School.size()>0){// 
            PhotoPass = School[0].PhotoFilePath__c;
        }

        return PhotoPass;
    }

//＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
//内部クラス
//＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
    
    //画面表示用の建物の内部クラス
    public class displayBuilding {
        public Building__c targetBuildingRecord { get; set; } //レコード本体
        public Building__c displayCalculateFormulas { get; set; } //レコード本体(数式表示更新用)
        
        //以下、画面用の項目
        public Id buildId { get; set; } //  建物Id
        public String buildName { get; set; }     //  建物名
        public String buildNameKana { get; set; } //  建物名（カナ）
        public String buildName2 { get; set; }    //  建物名２
        public String buildNameKana2 { get; set; }//  建物名（カナ）２
        public String buildName3 { get; set; }    //  建物名３
        public String buildNameKana3 { get; set; }//  建物名（カナ）３
        
        public String postalCode { get; set; }    //  郵便番号
        public String state { get; set; }         //  都道府県
        public String address { get; set; }       //  住所
        
        public String city { get; set; }          //  住所１（市区町村）
        public String street { get; set; }        //  住所２（番地）
        public String district { get; set; }      //  地区
        public String choazaCode { get; set; }    //  町字コード
        public String propertyType { get; set; }  //  物件種別
        public String structure { get; set; }     //  建物構造
        public String buildingYM { get; set; }    //  築年月
        public Decimal buildingAge { get; set; }  //  築年数
        
        public String groundFloorCount { get; set; } //  地上階数
        public String undergroundFloorCount { get; set; } //  地下階数
        public String houseCount { get; set; }  //  棟総戸数
        public Decimal longitude { get; set; }  //  経度
        public Decimal latitude { get; set; }   //  緯度
        
        public String buildingRemarksPublic { get; set; } //  建物備考（公開）
        public String buildingRemarksPrivate { get; set; } //  建物備考（非公開）
        
        public String importType     { get; set; } //  取込区分
        public String initImportType { get; set; } //  取込区分（初期選択値）
        
        public String maintenanceBuildingCode { get; set; } //  メンテナンス建物コード
        
        public String caretakerType { get; set; } //  管理人種別
        
        public Id primarySchool1 { get; set; } //  小学校１Id
        public String primarySchool1Name { get; set; } //  小学校１名
        public String primarySchoolDistance1 { get; set; } //  小学校までの距離１
        public Decimal primarySchoolWalkTime1 { get; set; } //  小学校までの時間（分）１
        public String primarySchoolFilePath1 {get; set;} //小学校１画像
        
        public Id primarySchool2 { get; set; } //  小学校2Id
        public String primarySchool2Name { get; set; } //  小学校2名
        public String primarySchoolDistance2 { get; set; } //  小学校までの距離2
        public Decimal PrimarySchoolWalkTime2 { get; set; } //  小学校までの時間（分）2
        public String primarySchoolFilePath2 {get; set;} //小学校2画像
        
        public Id primarySchool3 { get; set; } //  小学校3Id
        public String primarySchool3Name { get; set; } //  小学校3名
        public String primarySchoolDistance3 { get; set; } //  小学校までの距離3
        public Decimal PrimarySchoolWalkTime3 { get; set; } //  小学校までの時間（分）3
        public String primarySchoolFilePath3 {get; set;} //小学校3画像
        
        public Id juniorHighSchool1 { get; set; } //  中学校１
        public String juniorHighSchool1Name { get; set; } //  中学校１名
        public String juniorHighSchoolDistance1 { get; set; } //  中学校までの距離１
        public Decimal juniorHighSchoolWalkTime1 { get; set; } //  中学校までの時間（分）１
        public String juniorHighSchoolFilePath1 {get; set;} //中学校1画像
        
        public Id juniorHighSchool2 { get; set; } //  中学校2
        public String juniorHighSchool2Name { get; set; } //  中学校2名
        public String juniorHighSchoolDistance2 { get; set; } //  中学校までの距離2
        public Decimal juniorHighSchoolWalkTime2 { get; set; } //  中学校までの時間（分）2
        public String juniorHighSchoolFilePath2 {get; set;} //中学校2画像
        
        public Id juniorHighSchool3 { get; set; } //  中学校3
        public String juniorHighSchool3Name { get; set; } //  中学校3名
        public String juniorHighSchoolDistance3 { get; set; } //  中学校までの距離3
        public Decimal juniorHighSchoolWalkTime3 { get; set; } //  中学校までの時間（分）3
        public String juniorHighSchoolFilePath3 {get; set;} //中学校3画像
        
        public Id highSchool { get; set; } //  高校
        public String highSchoolName { get; set; } //  高校名
        public Decimal highSchoolDistance { get; set; } //  高校までの距離
        public Decimal highSchoolWalkTime { get; set; } //  高校までの時間（分）
        public String highSchoolFilePath {get; set;} //高校画像
        
        public Id university { get; set; } //  大学
        public String universityName { get; set; } //  大学名
        public Decimal universityDistance { get; set; } //  大学までの距離
        public Decimal universityWalkTime { get; set; } //  大学までの時間（分）
        public String universityFilePath {get; set;} //大学画像
        
        public Id convenienceStore { get; set; } // コンビニ
        public String convenienceStoreName { get; set; } //  コンビニ名
        public Decimal convenienceStoreDistance { get; set; } //  コンビニまでの距離
        public Decimal convenienceStoreWalkTime { get; set; } //  コンビニまでの時間（分）
        public String convenienceStoreFilePath {get; set;} //コンビニ画像
        
        public Id supermarket { get; set; } //  スーパーマーケット
        public String supermarketName { get; set; } //  スーパーマーケット名
        public Decimal supermarketDistance { get; set; } //  スーパーマーケットまでの距離
        public Decimal supermarketWalkTime { get; set; } //  スーパーマーケットまでの時間（分）
        public String supermarketFilePath {get; set;} //スーパーマーケット画像
        
        public Id generalHospital { get; set; } //  総合病院
        public String generalHospitalName { get; set; } //  総合病院名
        // 2022.03.31 No0781 generalHospitalPhotoFilePathが不要項目のため削除
        public Decimal generalHospitalDistance { get; set; } //  総合病院までの距離
        public Decimal generalHospitalWalkTime { get; set; } //  総合病院までの時間（分）
        public String generalHospitalFilePath {get; set;} //総合病院画像
        // ▼ 2022.04.07 No.782 問合せNo0782_建物画面の沿線名と駅名の登録について
        public List<Station__c> stations1 {get; set;}   // 駅１
        public List<Station__c> stations2 {get; set;}   // 駅２
        public List<Station__c> stations3 {get; set;}   // 駅３
        // ▲ 2022.04.07 No.782 問合せNo0782_建物画面の沿線名と駅名の登録について
        public Id trainRoute1 { get; set; } //  沿線１
        public String trainRoute1Name { get; set; } //  沿線１名
        public Id trainRoute2 { get; set; } //  沿線２
        public String trainRoute2Name { get; set; } //  沿線２名
        public Id trainRoute3 { get; set; } //  沿線３
        public String trainRoute3Name { get; set; } //  沿線３名
        
        public Id station1 { get; set; } //  駅１
        public String station1Name { get; set; } //  駅１名
        public String stationDistance1 { get; set; } //  駅までの距離1
        public Decimal stationWalkTime1 { get; set; } //  駅までの時間(分)１
        
        public Id station2 { get; set; } //  駅2
        public String station2Name { get; set; } //  駅2名
        public String stationDistance2 { get; set; } //  駅までの距離2
        public Decimal stationWalkTime2 { get; set; } //  駅までの時間(分)2
        
        public Id station3 { get; set; } //  駅3
        public String station3Name { get; set; } //  駅3名
        public String stationDistance3 { get; set; } //  駅までの距離3
        public Decimal stationWalkTime3 { get; set; } //  駅までの時間(分)3
        
        public String busRoute1 { get; set; } //  バス路線名
        public String busStop1 { get; set; }  //  バス停
        public String busStopDistance1 { get; set; } //  バス停までの距離
        public String busRideTime1 { get; set; } //  バス乗車時間（分）１
        public String busStopToStationDistance1 { get; set; } //  バス停からの距離
        
        public String busRoute2 { get; set; } //  バス路線名2
        public String busStop2 { get; set; }  //  バス停2
        public String busStopDistance2 { get; set; } //  バス停までの距離2
        public String busRideTime2 { get; set; } //  バス乗車時間（分）2
        public String busStopToStationDistance2 { get; set; } //  バス停からの距離2
        
        public String busRoute3 { get; set; } //  バス路線名3
        public String busStop3 { get; set; }  //  バス停3
        public String busStopDistance3 { get; set; } //  バス停までの距離3
        public String busRideTime3 { get; set; } //  バス乗車時間（分）3
        public String busStopToStationDistance3 { get; set; } //  バス停からの距離3
        
        public String maintenanceComment { get; set; } //  建物のメンテナンスコメント
        
        public Boolean isMergeCompletedFlag { get; set; } //  名寄せ完了フラグ

        public String foreignId { get; set; } // 外部Id
        
        public DateTime systemModstamp { get; set; } //  SystemModstamp

        public String initialInportType { get; set; } //問合せ278で追加　画面初期表示時取込区分
        
        //コンストラクタ
        public displayBuilding(Building__c targetBuildingRecord){
            
            this.targetBuildingRecord = targetBuildingRecord;  //レコード本体(取引先)
            this.displayCalculateFormulas = new Building__c(); //レコード本体(数式表示更新用)
            
            this.buildId = targetBuildingRecord.ID;     //  建物Id
            this.buildName = targetBuildingRecord.Name; //  建物名
            this.buildNameKana = targetBuildingRecord.BuildKana__c;   //  建物名（カナ）
            this.buildName2 = targetBuildingRecord.BuildName2__c;     //  建物名２
            this.buildNameKana2 = targetBuildingRecord.BuildKana2__c; //  建物名（カナ）２
            this.buildName3 = targetBuildingRecord.BuildName3__c;     //  建物名３
            this.buildNameKana3 = targetBuildingRecord.BuildKana3__c; //  建物名（カナ）３
            
            this.postalCode = targetBuildingRecord.PostalCode__c;  // 郵便番号
            this.address = targetBuildingRecord.Address__c;        // 住所
            this.structure = targetBuildingRecord.Structure__c ;   // 建物構造
            this.buildingAge = targetBuildingRecord.BuildingAge__c;// 築年数
            
            this.state = targetBuildingRecord.State__c;           //  都道府県
            this.city = targetBuildingRecord.City__c;             //  住所１（市区町村）
            this.street = targetBuildingRecord.Street__c;         //  住所２（番地）
            this.district = targetBuildingRecord.District__c;     //  地区
            this.choazaCode = targetBuildingRecord.ChoazaCode__c; //  町字コード
            this.propertyType = targetBuildingRecord.PropertyType__c; //  物件種別
            this.buildingYM = targetBuildingRecord.BuildingYM__c; //  築年月
            this.undergroundFloorCount = String.valueOf(targetBuildingRecord.UndergroundFloorCount__c);// 地下階数
            this.groundFloorCount      = String.valueOf(targetBuildingRecord.GroundFloorCount__c);     // 地下階数
            this.houseCount            = String.valueOf(targetBuildingRecord.HouseCount__c);           // 棟総戸数

            this.longitude = targetBuildingRecord.Longitude__c;// 経度
            this.latitude  = targetBuildingRecord.Latitude__c; // 緯度
            
            this.buildingRemarksPublic = targetBuildingRecord.BuildingRemarksPublic__c;   //  建物備考（公開）
            this.buildingRemarksPrivate = targetBuildingRecord.BuildingRemarksPrivate__c; //  建物備考（非公開）
            
            this.importType     = targetBuildingRecord.ImportType__c;// 取込区分
            this.initImportType = targetBuildingRecord.ImportType__c;// 取込区分（初期値）
            
            this.maintenanceBuildingCode = targetBuildingRecord.MaintenanceBuildingCode__c;// メンテナンス建物コード
            
            
            this.caretakerType = targetBuildingRecord.CaretakerType__c;//  管理人種別
            
            this.primarySchool1         = targetBuildingRecord.PrimarySchool1__c;                  //  小学校１Id
            this.primarySchool1Name     = targetBuildingRecord.PrimarySchool1__r.NAME;             //  小学校１名
            this.primarySchoolDistance1 = CommonUtil.decimalToString(targetBuildingRecord.PrimarySchoolDistance1__c);//  小学校までの距離１
            this.PrimarySchoolWalkTime1 = targetBuildingRecord.PrimarySchoolWalkTime1__c;          //  小学校までの時間（分）１
            this.PrimarySchoolFilePath1 = targetBuildingRecord.PrimarySchool1__r.PhotoFilePath__c; //  小学校画像1
            
            this.primarySchool2         = targetBuildingRecord.PrimarySchool2__c;                  //  小学校2Id
            this.primarySchool2Name     = targetBuildingRecord.PrimarySchool2__r.NAME;             //  小学校2名
            this.primarySchoolDistance2 = CommonUtil.decimalToString(targetBuildingRecord.PrimarySchoolDistance2__c); //  小学校までの距離2
            this.PrimarySchoolWalkTime2 = targetBuildingRecord.PrimarySchoolWalkTime2__c;          //  小学校までの時間（分）2
            this.PrimarySchoolFilePath2 = targetBuildingRecord.PrimarySchool2__r.PhotoFilePath__c; //  小学校画像2
            
            
            this.primarySchool3         = targetBuildingRecord.PrimarySchool3__c;                  //  小学校3Id
            this.primarySchool3Name     = targetBuildingRecord.PrimarySchool3__r.NAME;             //  小学校3名
            this.primarySchoolDistance3 = CommonUtil.decimalToString(targetBuildingRecord.PrimarySchoolDistance3__c);//  小学校までの距離3
            this.PrimarySchoolWalkTime3 = targetBuildingRecord.PrimarySchoolWalkTime3__c;          //  小学校までの時間（分）3
            this.PrimarySchoolFilePath3 = targetBuildingRecord.PrimarySchool3__r.PhotoFilePath__c; //  小学校画像3
            
            this.juniorHighSchool1         = targetBuildingRecord.JuniorHighSchool1__c;                  //  中学校１
            this.juniorHighSchool1Name     = targetBuildingRecord.JuniorHighSchool1__r.NAME;             //  中学校１名
            this.juniorHighSchoolDistance1 = CommonUtil.decimalToString(targetBuildingRecord.JuniorHighSchoolDistance1__c);//  中学校までの距離１
            this.juniorHighSchoolWalkTime1 = targetBuildingRecord.JuniorHighSchoolWalkTime1__c;          //  中学校までの時間（分）１
            this.juniorHighSchoolFilePath1 = targetBuildingRecord.JuniorHighSchool1__r.PhotoFilePath__c; //  中学校画像1
            
            this.juniorHighSchool2         = targetBuildingRecord.JuniorHighSchool2__c;                  //  中学校2
            this.juniorHighSchool2Name     = targetBuildingRecord.JuniorHighSchool2__r.Name;             //  中学校2名
            this.juniorHighSchoolDistance2 = CommonUtil.decimalToString(targetBuildingRecord.JuniorHighSchoolDistance2__c);//  中学校までの距離2
            this.juniorHighSchoolWalkTime2 = targetBuildingRecord.JuniorHighSchoolWalkTime2__c;          //  中学校までの時間（分）2
            this.juniorHighSchoolFilePath2 = targetBuildingRecord.JuniorHighSchool2__r.PhotoFilePath__c; //  中学校画像2
            
            this.juniorHighSchool3         = targetBuildingRecord.JuniorHighSchool3__c;                  //  中学校3
            this.juniorHighSchool3Name     = targetBuildingRecord.JuniorHighSchool3__r.Name;             //  中学校3名
            this.juniorHighSchoolDistance3 = CommonUtil.decimalToString(targetBuildingRecord.JuniorHighSchoolDistance3__c);//  中学校までの距離3
            this.juniorHighSchoolWalkTime3 = targetBuildingRecord.JuniorHighSchoolWalkTime3__c;          //  中学校までの時間（分）3
            this.juniorHighSchoolFilePath3 = targetBuildingRecord.JuniorHighSchool3__r.PhotoFilePath__c; //  中学校画像3
            
            this.highSchool         = targetBuildingRecord.HighSchool__c;                  //  高校
            this.highSchoolName     = targetBuildingRecord.HighSchool__r.NAME;             //  高校名
            this.highSchoolDistance = targetBuildingRecord.HighSchoolDistance__c;//  高校までの距離
            this.highSchoolWalkTime = targetBuildingRecord.HighSchoolWalkTime__c;          //  高校までの時間（分）
            this.highSchoolFilePath = targetBuildingRecord.HighSchool__r.PhotoFilePath__c; //  高校画像
            
            this.university         = targetBuildingRecord.University__c;                  //  大学
            this.universityName     = targetBuildingRecord.University__r.NAME;             //  大学名
            this.universityDistance = targetBuildingRecord.UniversityDistance__c;//  大学までの距離
            this.universityWalkTime = targetBuildingRecord.UniversityWalkTime__c;          //  大学までの時間（分）
            this.universityFilePath = targetBuildingRecord.University__r.PhotoFilePath__c; //  大学画像
            
            this.convenienceStore         = targetBuildingRecord.ConvenienceStore__c;                  // コンビニ
            this.convenienceStoreName     = targetBuildingRecord.ConvenienceStore__r.NAME;             // コンビニ名
            this.convenienceStoreDistance = targetBuildingRecord.ConvenienceStoreDistance__c;// コンビニまでの距離
            this.convenienceStoreWalkTime = targetBuildingRecord.ConvenienceStoreWalkTime__c;          // コンビニまでの時間（分）
            this.convenienceStoreFilePath = targetBuildingRecord.ConvenienceStore__r.PhotoFilePath__c; // コンビニ画像
            
            this.supermarket         = targetBuildingRecord.Supermarket__c;                  // スーパーマーケット
            this.supermarketName     = targetBuildingRecord.Supermarket__r.NAME;             // スーパーマーケット名
            this.supermarketDistance = targetBuildingRecord.SupermarketDistance__c;// スーパーマーケットまでの距離
            this.supermarketWalkTime = targetBuildingRecord.SupermarketWalkTime__c;          // スーパーマーケットまでの時間（分）
            this.supermarketFilePath = targetBuildingRecord.Supermarket__r.PhotoFilePath__c; // スーパーマーケット画像
            
            this.generalHospital         = targetBuildingRecord.GeneralHospital__c;                  //  総合病院
            this.generalHospitalName     = targetBuildingRecord.GeneralHospital__r.NAME;             //  総合病院名
            this.generalHospitalDistance = targetBuildingRecord.GeneralHospitalDistance__c;//  総合病院までの距離
            this.generalHospitalWalkTime = targetBuildingRecord.GeneralHospitalWalkTime__c;          //  総合病院までの時間（分）
            this.generalHospitalFilePath = targetBuildingRecord.GeneralHospital__r.PhotoFilePath__c; //  総合病院画像
                
            this.trainRoute1 = targetBuildingRecord.TrainRoute1__c;//  沿線１
            this.trainRoute1Name = targetBuildingRecord.TrainRoute1__r.NAME; //  沿線１名
            
            this.station1 = targetBuildingRecord.Station1__c;//  駅１
            this.station1Name = targetBuildingRecord.Station1__r.NAME; //  駅１名
            // ▼ 2022.04.07 No.782 問合せNo0782_建物画面の沿線名と駅名の登録について
            station__c s1 = new station__c(id=targetBuildingRecord.Station1__c,Name=targetBuildingRecord.Station1__r.NAME);
            this.stations1   = new List<Station__c>{s1};      // 駅１
            system.debug('2278'+this.stations1);
            system.debug('2279:'+s1);
            // ▲ 2022.04.07 No.782 問合せNo0782_建物画面の沿線名と駅名の登録について
            this.stationDistance1 = CommonUtil.decimalToString(targetBuildingRecord.StationDistance1__c);//  駅までの距離1
            this.stationWalkTime1 = targetBuildingRecord.StationWalkTime1__c;//  駅までの時間(分)１
            
            this.trainRoute2 = targetBuildingRecord.TrainRoute2__c;//  沿線２
            this.trainRoute2Name = targetBuildingRecord.TrainRoute2__r.NAME; //  沿線２名
            
            this.station2 = targetBuildingRecord.Station2__c;//  駅2
            this.station2Name = targetBuildingRecord.Station2__r.NAME;//  駅2名
            // ▼ 2022.04.07 No.782 問合せNo0782_建物画面の沿線名と駅名の登録について
            station__c s2 = new station__c(id=targetBuildingRecord.Station2__c,Name=targetBuildingRecord.Station2__r.NAME);
            this.stations2   = new List<Station__c>{s2};      // 駅２
            // ▲ 2022.04.07 No.782 問合せNo0782_建物画面の沿線名と駅名の登録について
            this.stationDistance2 = CommonUtil.decimalToString(targetBuildingRecord.StationDistance2__c);//  駅までの距離2
            this.stationWalkTime2 = targetBuildingRecord.StationWalkTime2__c;//  駅までの時間(分)2
            
            this.trainRoute3 = targetBuildingRecord.TrainRoute3__c;//  沿線３
            this.trainRoute3Name = targetBuildingRecord.TrainRoute3__r.NAME;//  沿線３名
            
            this.station3 = targetBuildingRecord.Station3__c;//  駅3
            this.station3Name = targetBuildingRecord.Station3__r.NAME; //  駅3名
            // ▼ 2022.04.07 No.782 問合せNo0782_建物画面の沿線名と駅名の登録について
            station__c s3 = new station__c(id=targetBuildingRecord.Station3__c,Name=targetBuildingRecord.Station3__r.NAME);
            this.stations3   = new List<Station__c>{s3};      // 駅３
            // ▲ 2022.04.07 No.782 問合せNo0782_建物画面の沿線名と駅名の登録について
            this.stationDistance3 = CommonUtil.decimalToString(targetBuildingRecord.StationDistance3__c); //  駅までの距離3
            this.stationWalkTime3 = targetBuildingRecord.StationWalkTime3__c; //  駅までの時間(分)3
            
            this.busRoute1 = targetBuildingRecord.BusRoute1__c; //  バス路線名
            this.busStop1 = targetBuildingRecord.BusStop1__c;   //  バス停
            this.busStopDistance1 = CommonUtil.decimalToString(targetBuildingRecord.BusStopDistance1__c); //  バス停までの距離
            this.busRideTime1 = CommonUtil.decimalToString(targetBuildingRecord.BusRideTime1__c);         //  バス乗車時間（分）１
            this.busStopToStationDistance1 = CommonUtil.decimalToString(targetBuildingRecord.BusStopToStationDistance1__c); //  バス停からの距離
            
            this.busRoute2 = targetBuildingRecord.BusRoute2__c; //  バス路線名2
            this.busStop2 = targetBuildingRecord.BusStop2__c;   //  バス停2
            this.busStopDistance2 = CommonUtil.decimalToString(targetBuildingRecord.BusStopDistance2__c); //  バス停までの距離2
            this.busRideTime2 = CommonUtil.decimalToString(targetBuildingRecord.BusRideTime2__c);         //  バス乗車時間（分）2
            this.busStopToStationDistance2 = CommonUtil.decimalToString(targetBuildingRecord.BusStopToStationDistance2__c); //  バス停からの距離2
            
            this.busRoute3 = targetBuildingRecord.BusRoute3__c; //  バス路線名3
            this.busStop3 = targetBuildingRecord.BusStop3__c;   //  バス停3
            this.busStopDistance3 = CommonUtil.decimalToString(targetBuildingRecord.BusStopDistance3__c); //  バス停までの距離3
            this.busRideTime3 = CommonUtil.decimalToString(targetBuildingRecord.BusRideTime3__c);         //  バス乗車時間（分）3
            this.busStopToStationDistance3 = CommonUtil.decimalToString(targetBuildingRecord.BusStopToStationDistance3__c); //  バス停からの距離3
            
            this.maintenanceComment = targetBuildingRecord.MaintenanceComment__c;     //  建物のメンテナンスコメント
            
            this.isMergeCompletedFlag = targetBuildingRecord.IsMergeCompletedFlag__c; //  名寄せ完了フラグ
            
            this.foreignId = targetBuildingRecord.ForeignID__c; // 外部Id

            this.systemModstamp = targetBuildingRecord.SystemModstamp;//  SystemModstamp
            // 問合せ278で追加　データ取得時に取込区分を退避
            this.initialInportType = targetBuildingRecord.ImportType__c;
        }
    }

    // 写真情報内部クラス
    private class PhotoData {
        public String fileName  { get; set; }   // ファイル名
        public String filePath  { get; set; }   // ファイルパス
        public String tag       { get; set; }   // タグ             ※周辺写真用
        public String comment   { get; set; }   // コメント
        public String photoName { get; set; }   // 写真名           ※周辺写真用
        public String distance  { get; set; }   // 距離             ※周辺写真用
        public Integer index    { get; set; }   // 削除対象判定用インデックス
    }
    // 写真情報処理用内部クラス
    public class ScreenAnyPhotoData {
        public GD901001ParameterClass GD901001Parameter { get; set; }
        public AmazonS3Util.PhotoType photoType { get; set; }   // 写真種別
        public PhotoData photoData              { get; set; }   // 写真情報
        public Boolean isNone                   { get; set; }   // 登録なしフラグ
        public ScreenAnyPhotoData(BuildingPhoto__c buildingPhoto, String foreignId, AmazonS3Util.PhotoType photoType, Boolean isMosaic) {
            // 初期化
            this.photoData = new PhotoData();
            this.GD901001Parameter = new GD901001ParameterClass();
            this.isNone = true;
            // パラメータ設定
            this.GD901001Parameter.photoType    = CommonConst.S3_PHOTOTYPE_BUILDING;
            this.GD901001Parameter.fileName     = '';
            this.GD901001Parameter.filePath     = '';
            this.GD901001Parameter.isArea       = true;
            this.GD901001Parameter.isMosaic     = isMosaic;
            this.GD901001Parameter.foreignId    = foreignId;  //建物の外部ID
            // データセット
            this.photoType = photoType;
            PhotoData data = new PhotoData();
            switch on photoType {
                when BUILDING_APPEARANCE {
                    // 建物外観
                    this.GD901001Parameter.photoSubType = CommonConst.S3_BUILDINGPHOTOTYPE_APPEARANCE;
                    this.GD901001Parameter.parameter    = CommonConst.S3_BUILDINGPHOTOTYPE_APPEARANCE;
                    data.fileName   = buildingPhoto.AppearanceFileName__c;
                    data.filePath   = buildingPhoto.AppearanceFilePath__c;
                    data.tag        = CommonConst.BUILDINGPHOTO_TAG_APPEARANCE;
                    data.comment    = buildingPhoto.AppearanceComment__c;
                    data.index      = 1;
                }
                when BUILDING_APPEARANCEPARSE {
                    // 外観パース
                    this.GD901001Parameter.photoSubType = CommonConst.S3_BUILDINGPHOTOTYPE_APPEARANCE_PARSE;
                    this.GD901001Parameter.parameter    = CommonConst.S3_BUILDINGPHOTOTYPE_APPEARANCE_PARSE;
                    data.fileName   = buildingPhoto.AppearanceParseFileName__c;
                    data.filePath   = buildingPhoto.AppearanceParseFilePath__c;
                    data.tag        = CommonConst.BUILDINGPHOTO_TAG_APPEARANCE_PARSE;
                    data.comment    = buildingPhoto.AppearanceParseComment__c;
                    data.index      = 2;
                }
                when BUILDING_ENTRANCE {
                    // エントランス
                    this.GD901001Parameter.photoSubType = CommonConst.S3_BUILDINGPHOTOTYPE_ENTRANCE;
                    this.GD901001Parameter.parameter    = CommonConst.S3_BUILDINGPHOTOTYPE_ENTRANCE;
                    data.fileName   = buildingPhoto.EntranceFileName__c;
                    data.filePath   = buildingPhoto.EntranceFilePath__c;
                    data.tag        = CommonConst.BUILDINGPHOTO_TAG_ENTRANCE;
                    data.comment    = buildingPhoto.EntranceComment__c;
                    data.index      = 3;
                }
                when BUILDING_LOBBY {
                    // ロビー
                    this.GD901001Parameter.photoSubType = CommonConst.S3_BUILDINGPHOTOTYPE_LOBBY;
                    this.GD901001Parameter.parameter    = CommonConst.S3_BUILDINGPHOTOTYPE_LOBBY;
                    data.fileName   = buildingPhoto.LobbyFileName__c;
                    data.filePath   = buildingPhoto.LobbyFilePath__c;
                    data.tag        = CommonConst.BUILDINGPHOTO_TAG_LOBBY;
                    data.comment    = buildingPhoto.LobbyComment__c;
                    data.index      = 4;
                }
                when BUILDING_PARKING {
                    // 駐車場
                    this.GD901001Parameter.photoSubType = CommonConst.S3_BUILDINGPHOTOTYPE_PARKING;
                    this.GD901001Parameter.parameter    = CommonConst.S3_BUILDINGPHOTOTYPE_PARKING;
                    data.fileName   = buildingPhoto.ParkingFileName__c;
                    data.filePath   = buildingPhoto.ParkingFilePath__c;
                    data.tag        = CommonConst.BUILDINGPHOTO_TAG_PARKING;
                    data.comment    = buildingPhoto.ParkingComment__c;
                    data.index      = 5;
                }
                when BUILDING_OTHERSHARING {
                    // その他共有
                    this.GD901001Parameter.photoSubType = CommonConst.S3_BUILDINGPHOTOTYPE_OTHERSHARING;
                    this.GD901001Parameter.parameter    = CommonConst.S3_BUILDINGPHOTOTYPE_OTHERSHARING;
                    data.fileName   = buildingPhoto.OtherSharingFileName__c;
                    data.filePath   = buildingPhoto.OtherSharingFilePath__c;
                    data.tag        = CommonConst.BUILDINGPHOTO_TAG_OTHERSHARING;
                    data.comment    = buildingPhoto.OtherSharingComment__c;
                    data.index      = 6;
                }
                when BUILDING_MAP {
                    // 地図
                    this.GD901001Parameter.photoSubType = CommonConst.S3_BUILDINGPHOTOTYPE_MAP;
                    this.GD901001Parameter.parameter    = CommonConst.S3_BUILDINGPHOTOTYPE_MAP;
                    data.fileName   = buildingPhoto.MapFileName__c;
                    data.filePath   = buildingPhoto.MapFilePath__c;
                    data.tag        = CommonConst.BUILDINGPHOTO_TAG_MAP;
                    data.comment    = buildingPhoto.MapComment__c;
                    data.index      = 7;
                }
                when BUILDING_OTHER {
                    // その他
                    this.GD901001Parameter.photoSubType = CommonConst.S3_BUILDINGPHOTOTYPE_OTHER;
                    this.GD901001Parameter.parameter    = CommonConst.S3_BUILDINGPHOTOTYPE_OTHER;
                    data.fileName   = buildingPhoto.OtherFileName__c;
                    data.filePath   = buildingPhoto.OtherFilePath__c;
                    data.tag        = CommonConst.BUILDINGPHOTO_TAG_OTHER;
                    data.comment    = buildingPhoto.OtherComment__c;
                    data.index      = 8;
                }
            }
            this.photoData = data;
            if (!String.isEmpty(data.fileName)) {
                this.GD901001Parameter.fileName = data.fileName;
                this.GD901001Parameter.filePath = data.filePath;
                this.isNone = false;
            }
        }
    }
    // 写真情報処理用内部クラス
    public class ScreenSurroundingPhotoData {
        public GD901001ParameterClass GD901001Parameter { get; set; }
        public AmazonS3Util.PhotoType photoType { get; set; }   // 写真種別
        public List<PhotoData> photoDataList    { get; set; }   // 写真情報
        public Boolean isNone                   { get; set; }   // 登録なしフラグ
        public Integer photoCount               { get; set; }   // 写真登録数
        public ScreenSurroundingPhotoData() {
            // 初期化
            this.photoDataList = new List<PhotoData>();
            this.GD901001Parameter = new GD901001ParameterClass();
        }
        public ScreenSurroundingPhotoData(BuildingPhoto__c buildingPhoto, String foreignId, Boolean isMosaic) {
            // 初期化
            this.photoDataList  = new List<PhotoData>();
            this.GD901001Parameter = new GD901001ParameterClass();
            this.isNone = true;
            this.photoCount = 0;
            // データセット
            this.photoType = AmazonS3Util.PhotoType.BUILDING_SURROUNDING;
            PhotoData data = new PhotoData();
            // 周辺写真
            for (Integer i = 1; i <= CommonConst.MAXINDEX_BUILDING_SURROUNDING; i++) {
                data = new photoData();
                data.fileName   = (String)buildingPhoto.get('SurroundingFileName' + i + '__c');
                data.filePath   = (String)buildingPhoto.get('SurroundingFilePath' + i + '__c');
                data.tag        = (String)buildingPhoto.get('SurroundingTag' + i + '__c');
                data.comment    = (String)buildingPhoto.get('SurroundingComment' + i + '__c');
                data.photoName  = (String)buildingPhoto.get('SurroundingPhotoName' + i + '__c');
                data.distance   = CommonUtil.decimalToString((Decimal)buildingPhoto.get('SurroundingDistance' + i + '__c'));
                data.index      = i;
                if (!String.isEmpty(data.fileName)) {
                    this.photoDataList.add(data);
                    this.photoCount += 1;
                    this.isNone = false;
                }
            }
            // パラメータ設定
            this.GD901001Parameter.photoType    = CommonConst.S3_PHOTOTYPE_BUILDING;
            this.GD901001Parameter.photoSubType = CommonConst.S3_BUILDINGPHOTOTYPE_SURROUNDING;
            this.GD901001Parameter.parameter    = CommonConst.S3_BUILDINGPHOTOTYPE_SURROUNDING;
            this.GD901001Parameter.fileName     = '';
            this.GD901001Parameter.filePath     = '';
            this.GD901001Parameter.isArea       = true;
            this.GD901001Parameter.isMosaic     = isMosaic;
            this.GD901001Parameter.foreignId    = foreignId;  //建物の外部ID
            this.GD901001Parameter.height       = '100px';
            this.GD901001Parameter.registPhotoCount = this.photoCount;
        }
    }

    /**
     * メンテナンス建物コード履歴用内部クラス
     */
    public class ScreenBuildingCdHist {

        // フィールド
        public BuildingCodeHistory__c Entity                    {get; set;} // エンティティ
        public String                 parentRowClass            {get; set;} // 親行クラス
        public Id                     Id                        {get; set;} // ID
        public Boolean                IsSelected                {get; set;} // 選択行
        public String                 HistMaintenanceBuildingCd {get; set;} // 履歴メンテナンス建物コード
        public String                 HistImportDestination     {get; set;} // 履歴取込先
        public String                 InformationUpdateDate     {get; set;} // 情報更新日

        // 定数
        private final String PARENT_ROW_CLASS = 'parent-row'; // 親行（名寄せ先）クラス

        /**
         * コンストラクタ
         */
        public ScreenBuildingCdHist(BuildingCodeHistory__c buildingCdHist) {

            // 親行クラス
            this.parentRowClass            = (buildingCdHist.Building__c == buildingCdHist.HistoryBuilding__c)
                                                ? PARENT_ROW_CLASS : CommonConst.STRING_EMPTY;
            
            // オブジェクト項目
            this.Entity                    = buildingCdHist;                                   // エンティティ
            this.Id                        = buildingCdHist.Id;                                // ID
            this.IsSelected                = false;                                            // 選択行
            this.HistMaintenanceBuildingCd = buildingCdHist.HistoryMaintenanceBuildingCode__c; // 履歴メンテナンス建物コード
            this.HistImportDestination     = buildingCdHist.HistoryImportDestination__c;       // 履歴取込先
        
            this.convertFieldsNull();
        }

        /**
         * フィールドのNULL値変換
         */
        private void convertFieldsNull() { 

            // NULL値チェックのみ
            HistMaintenanceBuildingCd = String.isEmpty(HistMaintenanceBuildingCd) ? CommonConst.STRING_EMPTY: HistMaintenanceBuildingCd; // 履歴メンテナンス建物コード
            HistImportDestination     = String.isEmpty(HistImportDestination)     ? CommonConst.STRING_EMPTY: HistImportDestination;     // 履歴取込先
            
            // NULL値チェック後に処理有り
            // 情報更新日（"yyyy/MM/dd HH:mm"形式に変更）
            InformationUpdateDate     = Entity.InformationUpdateDate__c == null   ? CommonConst.STRING_EMPTY
                                                                                    : Entity.InformationUpdateDate__c.format('yyyy/MM/dd HH:mm');
        }
    }
}