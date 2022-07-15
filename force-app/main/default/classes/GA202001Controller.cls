/*
* 来店カードのコントローラ
*/
global inherited sharing class GA202001Controller {
    
    //******************************************************************** public変数 ********************************************************************
    
    //画面表示用クラス
    public displayVisitCard displayVisitCard { get; set; }// 表示用内部クラス

    //来店状況
    public Boolean isNewAccount { get; set; } // 新規客フラグ
    public Boolean isNewVisitCard { get; set; } // 新規来店フラグ
    public Date today { get; set; } // ご来店日
    
    //選択リストの内容
    public List<SelectOption> sexOption { get; set; } // 性別
    public List<SelectOption> stateOption { get; set; } // 都道府県
    public List<SelectOption> visitReasonOption { get; set; }  // 来店理由
    public List<SelectOption> jobTypeOption { get; set; }  // 職種
    public List<SelectOption> walkingTimeOption { get; set; } // 駅までの徒歩時間←来店カードの項目名は「徒歩」
    public List<SelectOption> occupancyAreaUpperLimitOption { get; set; }  // 占有面積（上限）
    public List<SelectOption> occupancyAreaLowerLimitOption  { get; set; }  // 占有面積（下限）
    public List<SelectOption> buildingAgeOption { get; set; }// 築年数
    public List<SelectOption> trainRouteOption { get; set; }// 路線
    public List<SelectOption> districtOption { get; set; } // 問合せ415で追加　地区
    // ▼2021.10.08 No.307 対応で追加
    public List<SelectOption> AccountPropertyConditions { get; set; } // お客様物件条件
    public String selectCondName { get; set; }//物件条件名
    public String tmpCondName { get; set; }//マップ置換用の物件条件名
    // ▲2021.10.08 No.307 対応

    
    //チェックボックス選択リストの内容
    private List<SelectOption> selectVisitsTriggerList { get; set; } // 来店のきっかけ
    public List<String> visitsTriggerValueList { get; set; }         // 来店のきっかけ選択リスト（値）
    public Map<String, String> visitsTriggerNameList { get; set; }   // 来店のきっかけ選択リスト（値、表示名）
    public Map<String, Boolean> visitsTriggerCheckList { get; set; } // 来店のきっかけチェック状態（値、チェック）
    
    private List<SelectOption> selectPortalSiteList { get; set; } // 閲覧サイト
    public List<String> portalSiteValueList { get; set; }         // 閲覧サイト選択リスト（値）
    public Map<String, String> portalSiteNameList { get; set; }   // 閲覧サイト選択リスト（値、表示名）
    public Map<String, Boolean> portalSiteCheckList { get; set; } // 閲覧サイトチェック状態（値、チェック）
    
    private List<SelectOption> selectHomeMovingReasonList { get; set; } // お引越理由
    public List<String> homeMovingReasonValueList { get; set; }         // お引越理由選択リスト（値）
    public Map<String, String> homeMovingReasonNameList { get; set; }   // お引越理由選択リスト（値、表示名）
    public Map<String, Boolean> homeMovingReasonCheckList { get; set; } // お引越理由チェック状態（値、チェック）
    
    private List<SelectOption> selectContractTypeList { get; set; } // 契約形態
    public List<String> contractTypeValueList { get; set; }         // 契約形態選択リスト（値）
    public Map<String, String> contractTypeNameList { get; set; }   // 契約形態選択リスト（値、表示名）
    public Map<String, Boolean> contractTypeCheckList { get; set; } // 契約形態チェック状態（値、チェック）
    
    private List<SelectOption> selectHomeMovingSeasonList { get; set; } // お引越時期
    public List<String> homeMovingSeasonValueList { get; set; }         // お引越時期選択リスト（値）
    public Map<String, String> homeMovingSeasonNameList { get; set; }   // お引越時期選択リスト（値、表示名）
    public Map<String, Boolean> homeMovingSeasonCheckList { get; set; } // お引越時期チェック状態（値、チェック）
    
    //署名情報

    public Boolean privacy { get; set; }            //個人情報に同意フラグ
    
    public Id parentId { get; set;}    //署名用申込Id
    public Boolean isUpsert { get; set; }  //署名用更新フラグ   
    
    
    //モーダル画面のパラメータ
    public GA102006ParameterClass GA102006Parameter{get; set;}       //郵便番号検索・住所検索モーダル
    public GA104007ParameterClass GA104007Parameter{ get; set; }     // 駅選択モーダル
    public GA202002ParameterClass GA202002Parameter{get; set;}       // 学区選択モーダル　問合せ415で追加
    public GH201003ParameterClass GH201003Paremeter{ get; set; }     // 店舗・地区選択モーダル　問合せ423で追加
    public GH201005ParameterClass GH201005Parameter{ get; set; }     // 商圏・地区選択モーダル　問合せ0588で追加 2022/4/25
    // ▼2021.10.08 No.307 対応で削除「希望駅、希望中学校、希望小学校」

    //エラーフラグ
    public Boolean isOpenError { get; set; } //エラーフラグ
    public Boolean hasErrorMessage { get; set; } //エラーメッセージ保有フラグ
    
    //表示メッセージ
    public String MSG_COM_V_REGISTRATION { get { return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_REGISTRATION,''); } private set; } //js用保存確認メッセージ
    public String MSG_COM_I_REGISTRATION { get { return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_REGISTRATION,''); } private set; } //js用保存完了メッセージ
    
    // ▼2021.10.08 No.307 対応で追加
    public String MSG_COM_V_ADD_PROPERTYCONDITIONS { get { return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_ADD_PROPERTYCONDITIONS); } private set; } //物件条件追加メッセージ
    public String MSG_COM_V_DELETE_PROPERTYCONDITIONS { get { return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_DELETE_PROPERTYCONDITIONS); } private set; } // 物件条件削除メッセージ
    public String MSG_COM_I_E_NG_PROPERTY_SAMENAME { get { return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_E_NG_PROPERTY_SAMENAME); } private set; } // 物件条件が被った際のメッセージ
    public String MSG_COM_I_E_NG_PROPERTYCONDITIONSNAME_EMPTY { get { return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_E_NG_PROPERTYCONDITIONSNAME_EMPTY); } private set; } // 物件条件名が未入力の際のメッセージ
    // ▲2021.10.08 No.307 対応で追加

    
    //******************************************************************** Private変数 ********************************************************************
    
    //パラメータ
    private String acc;//取引先Id
    private String Corresponds;//対応Id
    private String userId;//遷移元のuserId
    
    //取得データ
    private Account account;//取引先
    private VisitCard__c visitCard;//来店カード
    private Correspond__c correspond = new Correspond__c();//対応
    private Map<Id, List<Station__c>> stationMap;//希望路線Idと希望駅Id

    //モーダル画面の判別用フラグ
    private Integer modalMode;
    
    //選択された来店理由
    private String selectedVisitReason = null;

    // ▼ 2022.05.12問合せNo0588で追加
    //区切り文字
    private static final String SPACE_SEPARATOR = ' ';
    // ▲ 2022.05.12問合せNo0588で追加
    
    //******************************************************************** publicメソッド ********************************************************************
    
    //コンストラクタ
    public GA202001Controller() {
        try{
            init();//初期化
        }catch(Exception e){
            //エラーを設定
            isOpenError = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    
    //お客様連絡先 郵便番号モーダルのOpen処理
    public void postmodal1() {
        try{
            hasErrorMessage = FALSE;
            modalMode = 1;  
            openModal();
        }catch(Exception e){
            //エラーを設定
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }  
    
    //お客様勤務先/学校連絡先 郵便番号モーダルのOpen処理
    public void postmodal2() {
        try{
            hasErrorMessage = FALSE;
            modalMode = 2;  
            openModal();
        }catch(Exception e){
            //エラーを設定
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }  
    
    //駅１モーダルOpenの処理
    public void openStations1Modal() {
        
        try{
            hasErrorMessage = FALSE;
            modalMode = 3;
            openModal();
        }catch(Exception e){
            //エラーを設定
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    
    //駅２モーダルOpenの処理
    public void openStations2Modal() {
        
        try{
            hasErrorMessage = FALSE;
            modalMode = 4;
            openModal();
        }catch(Exception e){
            //エラーを設定
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    
    //駅３モーダルOpenの処理
    public void openStations3Modal() {
        
        try{
            hasErrorMessage = FALSE;
            modalMode = 5;
            openModal();
        }catch(Exception e){
            //エラーを設定
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // ▼問合せ415で追加
    //中学校区モーダルOpenの処理
    public void openJuniorHighSchoolDistrictModal() {
        
        try{
            hasErrorMessage = FALSE;
            modalMode = 6;
            openModal();
        }catch(Exception e){
            //エラーを設定
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    //小学校区モーダルOpenの処理
    public void openElementarySchoolDistrictModal() {
    
        try{
            hasErrorMessage = FALSE;
            modalMode = 7;
            openModal();
        }catch(Exception e){
            //エラーを設定
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    // ▲問合せ415で追加

    // ▼問合せ423で追加
    //店舗・地区選択モーダルOpenの処理
    /*
    public void openShopDistrictModal() {

        modalMode = 8;
        openModal();
    }
    // ▲問合せ423で追加
    */
    // ▼ 2022.4.25 問合せNo0588で追加
    public void openDistrictModal() {

        modalMode = 8;
        openModal();
    }
    // ▲ 2022.4.25 問合せNo0588で追加
    
    //モーダル共通Open
    public void openModal() {
        if(modalMode== 1){//開くモーダルに合わせてパラメータを設定
            //お客様連絡先 郵便番号
            GA102006Parameter.isDrawing = true;
            GA102006Parameter.noFirst = true;
            GA102006Parameter.isAddressMoster = true;       /** 住所マスタフラグ */
            //郵便番号個人用モーダル     
            GA102006Parameter.postalCode = this.displayVisitCard.PostalCode;  //モーダルに渡す用郵便番号
            GA102006Parameter.state = this.displayVisitCard.State;            //モーダルに渡す用都道府県
            GA102006Parameter.city = this.displayVisitCard.City;              //モーダルに渡す用市町村
            GA102006Parameter.street = null;                                  //モーダルに渡す用番地
        }else if(modalMode == 2){
            //お客様勤務先/学校連絡先 郵便番号
            GA102006Parameter.isDrawing = true;
            GA102006Parameter.noFirst = true;
            GA102006Parameter.isAddressMoster = true;       /** 住所マスタフラグ */
            //郵便番号個人用モーダル     
            GA102006Parameter.postalCode = this.displayVisitCard.affiliationPostalCode;  //モーダルに渡す用郵便番号
            GA102006Parameter.state = this.displayVisitCard.affiliationState;            //モーダルに渡す用都道府県
            GA102006Parameter.city = this.displayVisitCard.affiliationCity;              //モーダルに渡す用市町村
            GA102006Parameter.street = null;                                  //モーダルに渡す用番地
        }else if(modalMode == 3){
            // 路線１
            this.GA104007Parameter.isDrawing          = true;
            this.GA104007Parameter.noFirst            = true;

            // ▼2021.10.08 No.307 対応で変更
            if (displayVisitCard.displayCond.trainRoute1 != null ){//選択された路線を設定
                this.GA104007Parameter.selectedTrainRoute = [SELECT Id, Name FROM TrainRoute__c WHERE Id = :displayVisitCard.displayCond.trainRoute1];
            }        
            
            this.GA104007Parameter.selectedStation = new List<Station__c>();//パラメータ初期化
            
            if (displayVisitCard.displayCond.stations1.size() > 0) {//選択された駅を設定
                this.GA104007Parameter.selectedStation    = displayVisitCard.displayCond.stations1;
            }
            // ▲2021.10.08 No.307 対応で変更
        }else if(modalMode == 4){
            // 路線2
            this.GA104007Parameter.isDrawing          = true;
            this.GA104007Parameter.noFirst            = true;

            // ▼2021.10.08 No.307 対応で変更
            if (displayVisitCard.displayCond.trainRoute2 != null ){//選択された路線を設定
                this.GA104007Parameter.selectedTrainRoute = [SELECT Id, Name FROM TrainRoute__c WHERE Id = :displayVisitCard.displayCond.trainRoute2];
            }          
            
            this.GA104007Parameter.selectedStation = new List<Station__c>();//パラメータ初期化
            
            if (displayVisitCard.displayCond.stations2.size() > 0) {//選択された駅を設定
                this.GA104007Parameter.selectedStation    = displayVisitCard.displayCond.stations2;
            }
            // ▲2021.10.08 No.307 対応で変更
        }else if(modalMode == 5){
            // 路線3
            this.GA104007Parameter.isDrawing          = true;
            this.GA104007Parameter.noFirst            = true;
            // ▼2021.10.08 No.307 対応で変更
            if (displayVisitCard.displayCond.trainRoute3 != null ){//選択された路線を設定
                this.GA104007Parameter.selectedTrainRoute = [SELECT Id, Name FROM TrainRoute__c WHERE Id = :displayVisitCard.displayCond.trainRoute3];
            }          
            
            this.GA104007Parameter.selectedStation = new List<Station__c>();//パラメータ初期化
            
            if (displayVisitCard.displayCond.stations3.size() > 0) {//選択された駅を設定
                this.GA104007Parameter.selectedStation    = displayVisitCard.displayCond.stations3;
            }
            // ▲2021.10.08 No.307 対応で変更
        // 問合せ415で追加
        } else if (modalMode == 6) {
            // 中学校区
            this.GA202002Parameter.isDrawing          = true;
            this.GA202002Parameter.noFirst            = true;
            // ▼2021.10.08 No.307 対応で変更
            if (displayVisitCard.displayCond.juniorHighSchoolArea != null ){//選択された中学校区を設定
                this.GA202002Parameter.juniorHighSchoolArea = displayVisitCard.displayCond.juniorHighSchoolArea;
            }
            this.GA202002Parameter.selectedSchool = new List<School__c>();//パラメータ初期化
            if (displayVisitCard.displayCond.juniorHighSchoolList.size() > 0) {//選択された学校を設定
                this.GA202002Parameter.selectedSchool    = displayVisitCard.displayCond.juniorHighSchoolList;
            }
            // ▲2021.10.08 No.307 対応で変更
            // モーダル側での小学校か中学校かの判定のため
            this.GA202002Parameter.modalMode = 6;

        } else if (modalMode == 7) {
            // 小学校区
            this.GA202002Parameter.isDrawing          = true;
            this.GA202002Parameter.noFirst            = true;
            // ▼2021.10.08 No.307 対応で変更
            if (displayVisitCard.displayCond.elementarySchoolArea != null ){//選択された小学校区を設定
                this.GA202002Parameter.elementarySchoolArea = displayVisitCard.displayCond.elementarySchoolArea;
            }

            this.GA202002Parameter.selectedSchool = new List<School__c>();//パラメータ初期化
            if (displayVisitCard.displayCond.elementarySchoolList.size() > 0) {//選択された学校を設定
                this.GA202002Parameter.selectedSchool    = displayVisitCard.displayCond.elementarySchoolList;
            }
            // ▲2021.10.08 No.307 対応で変更
            // モーダル側での小学校か中学校かの判定のため
            this.GA202002Parameter.modalMode = 7;
        // 2022.4.25 問合せNo0588で追加
        } else if (modalMode == 8) {
            if(String.isNotBlank(displayVisitCard.displayCond.desiredArea)) {
                GH201005Parameter.selectedDistrict = displayVisitCard.displayCond.desiredArea.Split(SPACE_SEPARATOR); 
            }
            GH201005Parameter.isDrawing = true;
            GH201005Parameter.noFirst = true;
        }
    }
    
    //モーダル共通close
    public void closeModal(){
        if(modalMode== 1){
            //お客様連絡先 郵便番号
            this.displayVisitCard.PostalCode = GA102006Parameter.postalCode ;  //郵便番号
            this.displayVisitCard.State = GA102006Parameter.state ;            //都道府県
            this.displayVisitCard.City = GA102006Parameter.city + GA102006Parameter.street ; //市町村
        }else if(modalMode == 2){
            //お客様勤務先/学校連絡先 郵便番号
            this.displayVisitCard.affiliationPostalCode = GA102006Parameter.postalCode;  //郵便番号
            this.displayVisitCard.affiliationState = GA102006Parameter.state;            //都道府県
            this.displayVisitCard.affiliationCity = GA102006Parameter.city + GA102006Parameter.street;//市町村
        }else if(modalMode == 3){
            // 路線１
            // ▼2021.10.08 No.307 対応で変更
            this.displayVisitCard.displayCond.stations1     = this.GA104007Parameter.selectedStation;//モーダルで選択された駅
            this.displayVisitCard.displayCond.stationsChar1 = convStationListToString(this.GA104007Parameter.selectedStation);//表示用のモーダルで選択された駅
            // ▲2021.10.08 No.307 対応で変更
        }else if(modalMode == 4){
            // 路線2
            // ▼2021.10.08 No.307 対応で変更
            this.displayVisitCard.displayCond.stations2     = this.GA104007Parameter.selectedStation;//モーダルで選択された駅
            this.displayVisitCard.displayCond.stationsChar2 = convStationListToString(this.GA104007Parameter.selectedStation);//表示用のモーダルで選択された駅
            // ▲2021.10.08 No.307 対応で変更        
        }else if(modalMode == 5){
            // 路線3
            // ▼2021.10.08 No.307 対応で変更
            this.displayVisitCard.displayCond.stations3     = this.GA104007Parameter.selectedStation;//モーダルで選択された駅
            this.displayVisitCard.displayCond.stationsChar3 = convStationListToString(this.GA104007Parameter.selectedStation);//表示用のモーダルで選択された駅
            // ▲2021.10.08 No.307 対応で変更
            // ▼問合せ415で追加
        } else if(modalMode == 6) {
            // 中学校
            // ▼2021.10.08 No.307 対応で変更
            this.displayVisitCard.displayCond.juniorHighSchoolList = this.GA202002Parameter.selectedSchool;//モーダルで選択された学校（中学校）
            this.displayVisitCard.displayCond.desiredJuniorHighSchool = convSchoolListToString(this.GA202002Parameter.selectedSchool);//表示用のモーダルで選択された学校（中学校）

            // ▲2021.10.08 No.307 対応で変更
        } else if(modalMode == 7) {
            // 小学校
            // ▼2021.10.08 No.307 対応で変更
            this.displayVisitCard.displayCond.elementarySchoolList = this.GA202002Parameter.selectedSchool;//モーダルで選択された学校（小学校）
            this.displayVisitCard.displayCond.desiredPrimarySchool = convSchoolListToString(this.GA202002Parameter.selectedSchool);//表示用のモーダルで選択された学校（小学校）} 
            // ▲2021.10.08 No.307 対応で変更
            // ▲問合せ415で追加
        // ▼問合せ588で追加
        } else if (modalMode == 8) {
            // 商圏・地区選択モーダルclose処理
            displayVisitCard.displayCond.desiredArea = CommonConst.STRING_EMPTY;
            for(String District : GH201005Parameter.selectedDistrict){
                displayVisitCard.displayCond.desiredArea += (District + SPACE_SEPARATOR);
            }
        // ▲問合せ588で追加
        }
        // ▲2021.10.08 No.307 対応で変更
        // ▲問合せ423で追加
        modalMode = 0;//モーダルの判別フラグを初期化
        
    }
    
    //路線変更処理1
    public void changeTrainRoute1(){
        // ▼2021.10.08 No.307 対応で変更
        this.displayVisitCard.displayCond.stations1 = NEW List<Station__c>();//選択された駅を初期化
        this.displayVisitCard.displayCond.stationsChar1 = null;//表示用の選択された駅を初期化
        // ▲2021.10.08 No.307 対応で変更
    }
    
    //路線変更処理2
    public void changeTrainRoute2(){
        // ▼2021.10.08 No.307 対応で変更
        this.displayVisitCard.displayCond.stations2 = NEW List<Station__c>();//選択された駅を初期化
        this.displayVisitCard.displayCond.stationsChar2 = null;//表示用の選択された駅を初期化
        // ▲2021.10.08 No.307 対応で変更
    }
    
    //路線変更処理3
    public void changeTrainRoute3(){
        // ▼2021.10.08 No.307 対応で変更
        this.displayVisitCard.displayCond.stations3 = NEW List<Station__c>();//選択された駅を初期化
        this.displayVisitCard.displayCond.stationsChar3 = null;//表示用の選択された駅を初期化
        // ▲2021.10.08 No.307 対応で変更
    }

    // ▼問合せ415で追加
    // 中学校変更処理
    public void changeJuniorHighSchool() {
        // ▼2021.10.08 No.307 対応で変更
        this.displayVisitCard.displayCond.juniorHighSchoolList = new List<School__c>();//選択された中学校を初期化
        this.displayVisitCard.displayCond.desiredJuniorHighSchool = null;//表示用の選択された中学校を初期化
        // ▲2021.10.08 No.307 対応で変更
    }

    // 小学校変更処理
    public void changeElementarySchool() {
        // ▼2021.10.08 No.307 対応で変更
        this.displayVisitCard.displayCond.elementarySchoolList = new List<School__c>();//選択された小学校を初期化
        this.displayVisitCard.displayCond.desiredPrimarySchool = null;//表示用の選択された小学校を初期化
        // ▲2021.10.08 No.307 対応で変更
    }
    // ▲問合せ415で追加
    
    //年齢再計算
    public void ageRecalculate(){
        VisitCard__c calculateVisitCard = new VisitCard__c(Birthdate__c = this.displayVisitCard.Birthdate, VisitDate__c = this.today);//計算用レコード作成
        calculateVisitCard.recalculateFormulas();//計算実行
        
        displayVisitCard.age = CommonUtil.decimalToString(calculateVisitCard.Age__c);//表示用レコードに反映
    }
    
    //ご来店のきっかけ変更時の処理
    public void changeVisitTrigger(){
        if(!this.visitsTriggerCheckList.get('閲覧サイト')){//閲覧サイトのチェックが外れた場合、閲覧サイトの全チェックボックスをOFFにする
            
            for (SelectOption portalSiteList : this.selectPortalSiteList) {//閲覧サイトの全チェックボックス
                String value = portalSiteList.getValue();
                String label = portalSiteList.getLabel();
                
                //リスト設定
                this.portalSiteCheckList.put(value,false);
            }
        }
        
        if(!this.visitsTriggerCheckList.get('ご紹介')){//閲覧サイトのチェックが外れた場合、「ご紹介者様」を初期化する
            displayVisitCard.introducer = null;
        }
    }
    
    //お引越し理由変更時の処理
    public void changeHomeMovingReason(){
        if(!this.homeMovingReasonCheckList.get('現状不満')){//現状不満のチェックが外れた場合、「現状不満理由」を初期化する
            displayVisitCard.dissatisfaction = null;
        }
    }
    
    //引越時期変更時の処理
    public void changeHomeMovingSeason(){
        if(!this.homeMovingSeasonCheckList.get('その他')){//その他のチェックが外れた場合、引っ越し時期（日付）を初期化する
            displayVisitCard.homeMovingDate = null;
        }
    }
    
    //来店理由(スタッフ欄)の確定処理
    public void visitReasonConfirm(){
        
        try{
            hasErrorMessage = FALSE;
            if(displayVisitCard.visitReason == null){
                //来店理由が選択されていない場合、エラーを設定
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_NO_SELECTION,'来店理由'));
                throw ex;
            }
        }catch(Exception e){
            //エラーを設定
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    
    //保存
    public void save() {
        Savepoint sp = Database.setSavepoint();      //セーブポイント作成

        try{
            hasErrorMessage = FALSE;
            
            //入力チェック
            BusinessLogicException ex = new BusinessLogicException();
            
            // 電話番号,携帯電話:「携帯電話」「電話番号」どちらかに入力が無ければエラー
            if (String.isblank(displayVisitCard.email)
                && String.isblank(displayVisitCard.phone)
               ){
                   ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_INPUT,'電話番号、メール','どちらか1つ'));
               }
            
            // メール:メールの入力規則をチェックし、間違っていればエラー
            if(CommonUtil.isWrongMailString(displayVisitCard.email)){
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_MAILADDRESS_VALIDATION, 'メール'));
            }
            
            // ご紹介者様:「ご来店のきっかけ」の「ご紹介」にチェックが入っている場合、未入力であればエラー
            if(this.visitsTriggerCheckList.get('ご紹介')
               && String.isblank(displayVisitCard.introducer)){
                   ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED,'ご紹介者様'));
               }
            
            // 現状不満理由:「お引越し理由」の「現状不満」にチェックが入っている場合、未入力であればエラー
            if(this.homeMovingReasonCheckList.get('現状不満')
               && String.isblank(displayVisitCard.dissatisfaction)){
                   ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED,'現状不満理由'));
               }
            
            // 引越時期（日付）までに:「【引越時期・入居人数】・その他」にチェックが入っている場合、未入力であればエラー
            if(this.homeMovingSeasonCheckList.get('その他')
               && displayVisitCard.homeMovingDate == null){
                   ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED,'引越時期'));
               }
            
            // 料金上限:駐車場「台数」に入力があった場合、未入力であればエラー
            // ▼2021.10.08 No.307 対応で変更
            if(String.isnotblank(displayVisitCard.displayCond.carCount)
            && String.isblank(displayVisitCard.displayCond.parkingFeeLimit)){
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED,'1台あたりの料金'));
            }
            // ▲2021.10.08 No.307 対応で変更

            //必須入力確認
            List<String> requiredItem = new List<String>();//入力チェックリストを初期化
            
            if (String.isBlank(displayVisitCard.visitReason)){
                requiredItem.add('来店理由（スタッフ欄）');
            }

            if (String.isBlank(displayVisitCard.visiterLastName) && String.isBlank(displayVisitCard.visiterFirstName)){
                requiredItem.add('名前（姓）もしくは名前（名）');
            }

            if (String.isBlank(displayVisitCard.visiterLastNameKana)){
                requiredItem.add('名前（姓）フリガナもしく名前（名）フリガナ');
            }

            // ▼問合せ415で追加
            // 路線名が入力されていて、駅名が入力されていない場合、エラー
            // ▼2021.10.08 No.307 対応で変更
            if((String.isNotBlank(displayVisitCard.displayCond.trainRoute1) && String.isblank(displayVisitCard.displayCond.stationsChar1)) ||
                (String.isNotBlank(displayVisitCard.displayCond.trainRoute2) && String.isblank(displayVisitCard.displayCond.stationsChar2)) ||
                (String.isNotBlank(displayVisitCard.displayCond.trainRoute3) && String.isblank(displayVisitCard.displayCond.stationsChar3)) ) {
                requiredItem.add('路線名を選択した場合、駅名');
            }// ▲2021.10.08 No.307 対応で変更

            // 校区が入力されていて、学校が入力されていない場合、エラー
            // ▼2021.10.08 No.307 対応で変更
            if((String.isNotBlank(displayVisitCard.displayCond.juniorHighSchoolArea) && String.isblank(displayVisitCard.displayCond.desiredJuniorHighSchool)) ||
                (String.isNotBlank(displayVisitCard.displayCond.elementarySchoolArea) && String.isblank(displayVisitCard.displayCond.desiredPrimarySchool)) ) {
                requiredItem.add('校区を選択した場合、学校');
            }
            // ▲2021.10.08 No.307 対応で変更
            // ▲問合せ415で追加

            if (!requiredItem.isEmpty()){//入力チェック用リストが空ではない場合、エラー追加                
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ',')));
            }
            
            
            //エラーをまとめて投げる
            if (ex.hasMessage()){ 
                throw ex;
            }
            
            //楽観ロックチェック
            //取引先確認
            if (!isNewAccount){
                List<Account> checkOptimisticLockExceptionAccount = new List<Account>();
                checkOptimisticLockExceptionAccount = [ SELECT id
                                                       FROM Account
                                                       WHERE id = :displayVisitCard.accountId
                                                       AND SystemModStamp = :displayVisitCard.accountSystemModStamp ];
                //データ取得できない場合、楽観ロックチェックExceptionを発行
                if (checkOptimisticLockExceptionAccount.isEmpty()){
                    OptimisticLockException optimisticLockException = new OptimisticLockException();
                    throw optimisticLockException;
                }
            }
            
            //来店カード確認
            if (!isNewVisitCard){
                List<VisitCard__c> checkOptimisticLockExceptionVisitCard = new List<VisitCard__c>();
                checkOptimisticLockExceptionVisitCard = [ SELECT id
                                                         FROM VisitCard__c
                                                         WHERE id = :displayVisitCard.visitCardId
                                                         AND SystemModStamp = :displayVisitCard.visitCardSystemModStamp ];
                
                //データ取得できない場合、楽観ロックチェックExceptionを発行
                if (checkOptimisticLockExceptionVisitCard.isEmpty()){
                    OptimisticLockException optimisticLockException = new OptimisticLockException();
                    throw optimisticLockException;
                }
            }
            
            //対応確認
            if(String.isNotBlank(this.Corresponds)){
                List<Correspond__c> checkOptimisticLockExceptionCorrespond = new List<Correspond__c>();
                checkOptimisticLockExceptionCorrespond = [ SELECT id
                                                          FROM Correspond__c
                                                          WHERE id = :displayVisitCard.correspondId
                                                          AND SystemModStamp = :displayVisitCard.correspondSystemModStamp];
                
                //データ取得できない場合、楽観ロックチェックExceptionを発行
                if (checkOptimisticLockExceptionCorrespond.isEmpty()){
                    OptimisticLockException optimisticLockException = new OptimisticLockException();
                    throw optimisticLockException;
                }
            }

            //保存用レコード準備
            List<DesiredTrainRoute__c> saveDesiredTrainRouteList = new List<DesiredTrainRoute__c>();//来店カードへ保存用 希望路線
            List<DesiredStation__c> saveDesiredStationList = new List<DesiredStation__c>();//来店カードへ保存用 希望駅
            // ▼問合せ415で追加
            List<DesiredSchoolArea__c> saveDesiredSchoolAreaList = new List<DesiredSchoolArea__c>();//来店カードへ保存用　希望学区（エリア）
            List<DesiredSchool__c> saveDesiredSchoolList = new List<DesiredSchool__c>();//来店カードへ保存用　希望学校

            List<DesiredTrainRoute__c> saveToAccountDesiredTrainRouteList = new List<DesiredTrainRoute__c>();//取引先へ保存用 希望路線
            List<DesiredStation__c> saveToAccountDesiredStationList = new List<DesiredStation__c>();//取引先へ保存用 希望駅
            // ▼問合せ415で追加
            List<DesiredSchoolArea__c> saveToAccountDesiredSchoolAreaList = new List<DesiredSchoolArea__c>();//取引先へ保存用　希望学区（エリア）
            List<DesiredSchool__c> saveToAccountDesiredSchoolList = new List<DesiredSchool__c>();//取引先へ保存用　希望学校--

			// ▼2021.10.08 No.307 対応で追加
			changeMapData();
			
            // 保存用
            List<AccountPropertyConditions__c> saveCondList = new List<AccountPropertyConditions__c>(); // 保存用　お客様物件条件
            List<AccountPropertyConditions__c> delCondList = new List<AccountPropertyConditions__c>(); // 削除用　お客様物件条件
            // ▲2021.10.08 No.307 対応で追加

            // ▼2021.10.08 No.307 対応で変更
            Map<String, DesiredTrainRoute__c> saveCondTrainRouteMap = new Map<String, DesiredTrainRoute__c>(); // お客様物件条件へ保存用 希望路線(Map)
            Map<String, DesiredSchoolArea__c> saveCondSchoolAreaMap = new Map<String, DesiredSchoolArea__c>();//お客様物件条件へ保存用　希望学区（Map ）
            

            //保存用レコード準備
            List<DesiredStation__c> saveCondStationList = new List<DesiredStation__c>();//お客様物件条件へ保存用 希望駅
            // ▼問合せ415で追加
            List<DesiredSchool__c> saveCondSchoolList = new List<DesiredSchool__c>();//お客様物件条件へ保存用　希望学校            
            // ▲2021.10.08 No.307 対応で追変更
            Account saveAccount = new Account(); //保存用 取引先
            VisitCard__c saveVisitCard = new VisitCard__c();//保存用 来店カード
            Correspond__c saveCorrespond = new Correspond__c();//保存用 対応
            CorrespondDetail__c saveCorrespondDetail = new CorrespondDetail__c();//保存用 対応明細
            
            //保存用変数準備
            String siteView = CommonConst.VISITCARD_SITEVIEW_NOTSAW;//事前にネット：見ていない
            String isProxyCompany = CommonConst.VISITCARD_ISPROXYCOMPANY_NO;//代理会社有無：無
            // ▼2021.10.08 No.307 対応で削除（移動）　駐車場：無
            

            //保存用変数設定
            if(String.isNotBlank(displayVisitCard.proxyCompanyName)){//代行会社名の入力があった場合:有
                isProxyCompany = CommonConst.VISITCARD_ISPROXYCOMPANY_EXISTS;
            }
            
            // ▼2021.10.08 No.307 対応で削除（移動）　台数 が1以上あった場合:有
            
            //来店のきっかけ設定
            List<String> visitsTriggerCheck = new List<String>();
            for(String visitsTriggerValue : this.visitsTriggerValueList ){//全選択値を取得
                if(this.visitsTriggerCheckList.get(visitsTriggerValue)){
                    visitsTriggerCheck.add(visitsTriggerValue);//チェックされていた場合追加
                }
            }
            this.displayVisitCard.visitTrigger = String.join(visitsTriggerCheck, ';');//「;」区切りの文字列にして複数選択リストの値にする
            

            //ポータルサイト設定
            List<String> portalSiteCheck = new List<String>();
            for(String portalSiteValue : this.portalSiteValueList ){//全選択値を取得
                if(this.portalSiteCheckList.get(portalSiteValue)){
                    portalSiteCheck.add(portalSiteValue);//チェックされていた場合追加
                    siteView = CommonConst.VISITCARD_SITEVIEW_SAW;//チェックが一つ以上あった場合:見た
                }
            }
            this.displayVisitCard.portalSite = String.join(portalSiteCheck, ';');//「;」区切りの文字列にして複数選択リストの値にする
            
            //引越理由設定
            List<String> homeMovingReasonCheck = new List<String>();
            for(String homeMovingReasonValue : this.homeMovingReasonValueList ){//全選択値を取得
                if(this.homeMovingReasonCheckList.get(homeMovingReasonValue)){
                    homeMovingReasonCheck.add(homeMovingReasonValue);//チェックされていた場合追加
                }
            }
            this.displayVisitCard.homeMovingReason = String.join(homeMovingReasonCheck, ';');//「;」区切りの文字列にして複数選択リストの値にする
            
            
            //契約形態
            List<String> contractTypeReasonCheck = new List<String>();
            for(String contractTypeValue : this.contractTypeValueList ){//全選択値を取得
                if(this.contractTypeCheckList.get(contractTypeValue)){
                    contractTypeReasonCheck.add(contractTypeValue);//チェックされていた場合追加
                }
            }
            this.displayVisitCard.contractType = String.join(contractTypeReasonCheck, ';');

            //入居時期
            List<String> homeMovingSeasonCheck = new List<String>();
            for(String homeMovingSeasonValue : this.homeMovingSeasonValueList ){//全選択値を取得
                if(this.homeMovingSeasonCheckList.get(homeMovingSeasonValue)){
                    homeMovingSeasonCheck.add(homeMovingSeasonValue);//チェックされていた場合追加
                }
            }
            this.displayVisitCard.homeMovingSeason = String.join(homeMovingSeasonCheck, ';');
            
            // ▼2021.10.08 No.307 対応で削除（移動）
            //希望路線:希望駅作成～//取引先用希望学校を作成
            //取引先作成
            if(!this.isNewAccount){//取引先あればId設定
                saveAccount.Id = displayVisitCard.accountId;//取引先Id
            }
            saveAccount.RecordTypeId = CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_CUSTOMER);//取引先レコードタイプ
            saveAccount.Staff__c = UserInfo.getUserId();//担当者
            saveAccount.VisitsDate__c = this.today;  //来店日

            saveAccount.Name = displayVisitCard.visiterLastName + displayVisitCard.visiterFirstName;//取引先名
            saveAccount.NameKana__c = displayVisitCard.visiterLastNameKana + displayVisitCard.visiterFirstNameKana ;//取引先名（カナ）

            saveAccount.LastName__c = displayVisitCard.visiterLastName;//取引先名 姓
            saveAccount.LastNameKana__c = displayVisitCard.visiterLastNameKana;//取引先名 姓（カナ）

            saveAccount.FirstName__c = displayVisitCard.visiterFirstName;//取引先名 名
            saveAccount.FirstNameKana__c = displayVisitCard.visiterFirstNameKana ;//取引先名 名（カナ）

            saveAccount.Sex__c = displayVisitCard.sex ;//性別 
            saveAccount.Birthdate__c = displayVisitCard.birthdate ;//生年月日 

            saveAccount.PostalCode__c = displayVisitCard.postalCode ;//郵便番号 
            saveAccount.State__c = displayVisitCard.state ;//都道府県 
            saveAccount.City__c = displayVisitCard.city ;//住所１（市区町村） 
            saveAccount.Street__c = displayVisitCard.street ;//住所２（番地） 

            saveAccount.Phone = displayVisitCard.phone ;//電話番号 
            saveAccount.HomePhone__c = displayVisitCard.homePhone ;//自宅TEL
            saveAccount.Email__c = displayVisitCard.email ;//メール 

            saveAccount.Affiliation__c = displayVisitCard.affiliation ;//勤務先/学校名
            saveAccount.JobType__c = displayVisitCard.jobType ;//職種 
            saveAccount.AffiliationPostalCode__c = displayVisitCard.affiliationPostalCode ;//勤務先/学校 郵便番号
            saveAccount.AffiliationState__c = displayVisitCard.affiliationState ;//勤務先/学校 都道府県
            saveAccount.AffiliationCity__c = displayVisitCard.affiliationCity ;//勤務先/学校 住所１（市区町村）
            saveAccount.AffiliationStreet__c = displayVisitCard.affiliationStreet ;//勤務先/学校 住所２（番地）
            saveAccount.AffiliationPhone__c = displayVisitCard.affiliationPhone ;//勤務先/学校 電話番号

            saveAccount.VisitsTrigger__c = displayVisitCard.visitTrigger ;//来店のきっかけ 
            saveAccount.PortalSite__c = displayVisitCard.portalSite ;//ポータルサイト 
            saveAccount.SiteView__c = siteView;//事前にネット
            saveAccount.Introducer__c = displayVisitCard.introducer ;//紹介者 
            saveAccount.HomeMovingReason__c = displayVisitCard.homeMovingReason ;//引越理由 
            saveAccount.Dissatisfaction__c = displayVisitCard.dissatisfaction ;//不満理由 
            saveAccount.ContractType__c = displayVisitCard.contractType ;//契約形態 

            saveAccount.ProxyCompanyName__c = displayVisitCard.proxyCompanyName ;//代理会社名 
            saveAccount.IsProxyCompany__c = isProxyCompany ;//代理会社有無 

            saveAccount.HomeMovingSeason__c = displayVisitCard.homeMovingSeason ;//引越時期 
            saveAccount.HomeMovingDate__c = displayVisitCard.homeMovingDate ;//引越時期（日付）までに 
            saveAccount.TenantCount__c = CommonUtil.stringToDecimal(displayVisitCard.tenantCount) ;//入居人数 

            // ▼2021.10.08 No.307 対応で削除（移動）
            // 取引先に値をセットする処理を、お客様物件条件に変更
            saveAccount = setTargetRecordIsMergeCompletedFlag(saveAccount);// 保存する取引先に名寄せフラグ設定

            // ▼2021.10.08 No.307 対応で削除（移動） 希望学区の選択箇所をIndexを使って合わせる
            // ▲問合せ415で追加


            this.displayVisitCard.account = saveAccount;
            this.acc = saveAccount.Id;

            //来店カード作成
            saveVisitCard.Staff__c = UserInfo.getUserId();//担当者
            if(!this.isNewVisitCard){//来店カードあればId設定
                saveVisitCard.Id = displayVisitCard.visitCardId;//来店カードId
            }

            saveVisitCard.VisitDate__c = this.today;            //来店日
            saveVisitCard.VisitReason__c = displayVisitCard.visitReason ;//来店理由（スタッフ欄） 

            saveVisitCard.VisiterLastName__c = displayVisitCard.visiterLastName ;//姓 
            saveVisitCard.VisiterFirstName__c = displayVisitCard.visiterFirstName ;//名 
            saveVisitCard.VisiterLastNameKana__c = displayVisitCard.visiterLastNameKana ;//姓（カナ） 
            saveVisitCard.VisiterFirstNameKana__c = displayVisitCard.visiterFirstNameKana ;//名（カナ） 
            saveVisitCard.Sex__c = displayVisitCard.sex ;//性別 
            saveVisitCard.Birthdate__c = displayVisitCard.birthdate ;//生年月日 
            
            saveVisitCard.PostalCode__c = displayVisitCard.postalCode ;//郵便番号 
            saveVisitCard.State__c = displayVisitCard.state ;//都道府県 
            saveVisitCard.City__c = displayVisitCard.city ;//住所１（市区町村） 
            saveVisitCard.Street__c = displayVisitCard.street ;//住所２（番地） 
            saveVisitCard.Phone__c = displayVisitCard.phone ;//電話番号 
            saveVisitCard.HomePhone__c = displayVisitCard.homePhone;//自宅TEL
            saveVisitCard.Email__c = displayVisitCard.email ;//メール 

            saveVisitCard.JobType__c = displayVisitCard.jobType ;//職種 
            saveVisitCard.Affiliation__c = displayVisitCard.affiliation ;//勤務先/学校名
            saveVisitCard.AffiliationPostalCode__c = displayVisitCard.affiliationPostalCode ;//勤務先/学校 郵便番号
            saveVisitCard.AffiliationState__c = displayVisitCard.affiliationState ;//勤務先/学校 都道府県
            saveVisitCard.AffiliationCity__c = displayVisitCard.affiliationCity ;//勤務先/学校 住所１（市区町村）
            saveVisitCard.AffiliationStreet__c = displayVisitCard.affiliationStreet ;//勤務先/学校 住所２（番地）
            saveVisitCard.AffiliationPhone__c = displayVisitCard.affiliationPhone ;//勤務先/学校 電話番号

            saveVisitCard.VisitTrigger__c = displayVisitCard.visitTrigger ;//来店のきっかけ 
            saveVisitCard.PortalSite__c = displayVisitCard.portalSite ;//ポータルサイト 
            saveVisitCard.SiteView__c = siteView;//事前にネット
            saveVisitCard.Introducer__c = displayVisitCard.introducer ;//紹介者 
            saveVisitCard.HomeMovingReason__c = displayVisitCard.homeMovingReason ;//引越理由 
            saveVisitCard.Dissatisfaction__c = displayVisitCard.dissatisfaction ;//不満理由 
            saveVisitCard.ContractType__c = displayVisitCard.contractType ;//契約形態 
            saveVisitCard.ProxyCompanyName__c = displayVisitCard.proxyCompanyName ;//代理会社名 
            saveVisitCard.IsProxyCompany__c = isProxyCompany ;//代理会社有無 
            saveVisitCard.HomeMovingSeason__c = displayVisitCard.homeMovingSeason ;//引越時期 
            saveVisitCard.HomeMovingDate__c = displayVisitCard.homeMovingDate ;//引越時期（日付）までに 

            saveVisitCard.TenantCount__c = CommonUtil.stringToDecimal(displayVisitCard.tenantCount) ;//入居人数 

            //希望路線:希望駅作成
            List<DesiredTrainRoute__c> deleteDesiredTrainRoute  = new List<DesiredTrainRoute__c>();
            //希望学区:希望学校作成
            List<DesiredSchoolArea__c> deleteDesiredSchoolArea  = new List<DesiredSchoolArea__c>();
            
            String parking = CommonConst.VISITCARD_PARKING_NO;//駐車場：無

            for(String key : displayVisitCard.displayCondMap.keySet()){
                displayVisitCardCond targetCard = displayVisitCard.displayCondMap.get(key); // 物件条件を1つずつ取り出したオブジェクト
                // 必須の物件条件を取引先・来店カードに保存・更新する。
                if(targetCard.PrerequisiteFlg){

                    //台数 が1以上あった場合:有
                    if(CommonUtil.stringToDecimal(targetCard.carCount) > 0){
                        parking = CommonConst.VISITCARD_PARKING_EXISTS;
                    }

                    saveVisitCard.CarCount__c = CommonUtil.stringToDecimal(targetCard.carCount) ;//台数 
                    saveVisitCard.Parking__c = parking ; //駐車場
                    saveVisitCard.ParkingFeeLimit__c = CommonUtil.stringToDecimal(targetCard.parkingFeeLimit) ;//1台当たりの料金上限 

                    saveAccount.CarCount__c = CommonUtil.stringToDecimal(targetCard.carCount) ;//台数 
                    saveAccount.Parking__c = parking ; //駐車場
                    saveAccount.ParkingFeeLimit__c = CommonUtil.stringToDecimal(targetCard.parkingFeeLimit) ;//1台当たりの料金上限 

                    //希望路線を削除して、希望駅を初期化する
                    // ▼2021.10.08 No.307 対応で削除　取引先（希望路線）来店カード（希望路線）
                    if(String.valueOf(targetCard.visitCardDesiredTrainRoute1) != null){//来店カード希望沿線１
                        deleteDesiredTrainRoute.add(new DesiredTrainRoute__c(Id = targetCard.visitCardDesiredTrainRoute1));
                    }
                    if(String.valueOf(targetCard.accountDesiredTrainRoute1) != null){//取引先希望沿線１
                        deleteDesiredTrainRoute.add(new DesiredTrainRoute__c(Id = targetCard.accountDesiredTrainRoute1));
                    }
                    if(String.valueOf(targetCard.visitCardDesiredTrainRoute2) != null){//来店カード希望沿線2
                        deleteDesiredTrainRoute.add(new DesiredTrainRoute__c(Id = targetCard.visitCardDesiredTrainRoute2));
                    }
                    if(String.valueOf(targetCard.accountDesiredTrainRoute2) != null){//取引先希望沿線2
                        deleteDesiredTrainRoute.add(new DesiredTrainRoute__c(Id = targetCard.accountDesiredTrainRoute2));
                    }
                    if(String.valueOf(targetCard.visitCardDesiredTrainRoute3) != null){//来店カード希望沿線3
                        deleteDesiredTrainRoute.add(new DesiredTrainRoute__c(Id = targetCard.visitCardDesiredTrainRoute3));
                    }
                    if(String.valueOf(targetCard.accountDesiredTrainRoute3) != null){//取引先希望沿線3
                        deleteDesiredTrainRoute.add(new DesiredTrainRoute__c(Id = targetCard.accountDesiredTrainRoute3));
                    }
                    //希望駅がない希望路線を新規に作成する
                    if(String.valueOf(targetCard.trainRoute1) != null){
                        saveDesiredTrainRouteList.add(new DesiredTrainRoute__c(TrainRoute__c = targetCard.trainRoute1));
                        saveToAccountDesiredTrainRouteList.add(new DesiredTrainRoute__c(TrainRoute__c = targetCard.trainRoute1));
                    }
                    if(String.valueOf(targetCard.trainRoute2) != null){
                        saveDesiredTrainRouteList.add(new DesiredTrainRoute__c(TrainRoute__c = targetCard.trainRoute2));
                        saveToAccountDesiredTrainRouteList.add(new DesiredTrainRoute__c(TrainRoute__c = targetCard.trainRoute2));
                    }
                    if(String.valueOf(targetCard.trainRoute3) != null){
                        saveDesiredTrainRouteList.add(new DesiredTrainRoute__c(TrainRoute__c = targetCard.trainRoute3));
                        saveToAccountDesiredTrainRouteList.add(new DesiredTrainRoute__c(TrainRoute__c = targetCard.trainRoute3));
                    }

                    SecureDML.secureUpsert(saveDesiredTrainRouteList);//来店カード用希望路線を作成
                    SecureDML.secureUpsert(saveToAccountDesiredTrainRouteList);//取引先用希望路線を作成

                    //画面で選択された駅から、新規に希望路線に紐付けた希望駅を作成する
                    

                    Integer desiredTrainRouteIndex = 0;
                    if(String.valueOf(targetCard.trainRoute1) != null){
                        for(Station__c desiredStation : targetCard.stations1){//選択された駅1から希望駅を設定
                            saveDesiredStationList.add(new DesiredStation__c(DesiredTrainRoute__c = saveDesiredTrainRouteList[desiredTrainRouteIndex].Id, Station__c = desiredStation.Id));
                            saveToAccountDesiredStationList.add(new DesiredStation__c(DesiredTrainRoute__c = saveToAccountDesiredTrainRouteList[desiredTrainRouteIndex].Id, Station__c = desiredStation.Id));
                        }
                        desiredTrainRouteIndex++;
                    }

                    if(String.valueOf(targetCard.trainRoute2) != null){
                        for(Station__c desiredStation : targetCard.stations2){//選択された駅2から希望駅を設定
                            saveDesiredStationList.add(new DesiredStation__c(DesiredTrainRoute__c = saveDesiredTrainRouteList[desiredTrainRouteIndex].Id, Station__c = desiredStation.Id));
                            saveToAccountDesiredStationList.add(new DesiredStation__c(DesiredTrainRoute__c = saveToAccountDesiredTrainRouteList[desiredTrainRouteIndex].Id, Station__c = desiredStation.Id));
                        }
                        desiredTrainRouteIndex++;
                    }
                    
                    if(String.valueOf(targetCard.trainRoute3) != null){
                        for(Station__c desiredStation : targetCard.stations3){//選択された駅3から希望駅を設定
                            saveDesiredStationList.add(new DesiredStation__c(DesiredTrainRoute__c = saveDesiredTrainRouteList[desiredTrainRouteIndex].Id, Station__c = desiredStation.Id));
                            saveToAccountDesiredStationList.add(new DesiredStation__c(DesiredTrainRoute__c = saveToAccountDesiredTrainRouteList[desiredTrainRouteIndex].Id, Station__c = desiredStation.Id));
                        }
                        desiredTrainRouteIndex++;
                    }

                    SecureDML.secureUpsert(saveDesiredStationList);//来店カード用希望駅を作成
                    SecureDML.secureUpsert(saveToAccountDesiredStationList);//取引先用希望駅を作成


                    //希望学区を削除して、希望学校を初期化する
                    // ▼2021.10.08 No.307 対応で削除　取引先（希望学区）来店カード（希望学区）
                    if(String.valueOf(targetCard.visitCardDesiredElementarySchoolArea) != null){//来店カード小学校希望学区
                        deleteDesiredSchoolArea.add(new DesiredSchoolArea__c(Id = targetCard.visitCardDesiredElementarySchoolArea));
                    }
                    if(String.valueOf(targetCard.visitCardDesiredJuniorHighSchoolArea) != null){//来店カード中学校希望学区
                        deleteDesiredSchoolArea.add(new DesiredSchoolArea__c(Id = targetCard.visitCardDesiredJuniorHighSchoolArea));
                    }
                    if(String.valueOf(targetCard.accountDesiredElementarySchoolArea) != null){//取引先小学校希望学区
                        deleteDesiredSchoolArea.add(new DesiredSchoolArea__c(Id = targetCard.accountDesiredElementarySchoolArea));
                    }
                    if(String.valueOf(targetCard.accountDesiredJuniorHighSchoolArea) != null){//取引先中学校希望学区
                        deleteDesiredSchoolArea.add(new DesiredSchoolArea__c(Id = targetCard.accountDesiredJuniorHighSchoolArea));
                    }

                    //希望学区を新規に作成する
                    if(String.valueOf(targetCard.juniorHighSchoolArea) != null){
                        saveDesiredSchoolAreaList.add(new DesiredSchoolArea__c(SchoolArea__c = targetCard.juniorHighSchoolArea));
                        saveToAccountDesiredSchoolAreaList.add(new DesiredSchoolArea__c(SchoolArea__c = targetCard.juniorHighSchoolArea));
                    }
                    if(String.valueOf(targetCard.elementarySchoolArea) != null){
                        saveDesiredSchoolAreaList.add(new DesiredSchoolArea__c(SchoolArea__c = targetCard.elementarySchoolArea));
                        saveToAccountDesiredSchoolAreaList.add(new DesiredSchoolArea__c(SchoolArea__c = targetCard.elementarySchoolArea));
                    }
                    
                    SecureDML.secureUpsert(saveDesiredSchoolAreaList);//来店カード用希望学区を作成
                    SecureDML.secureUpsert(saveToAccountDesiredSchoolAreaList);//取引先用希望学区を作成
                    
                    //画面で選択された学区から、新規に希望学区に紐付けた希望学校を作成する
                    Integer desiredSchoolIndex = 0;
                    if(String.valueOf(targetCard.juniorHighSchoolArea) != null){
                        for(School__c desiredSchool : targetCard.juniorHighSchoolList){//選択された中学校から希望学校を設定
                            saveDesiredSchoolList.add(new DesiredSchool__c(DesiredSchoolArea__c = saveDesiredSchoolAreaList[desiredSchoolIndex].Id, School__c = desiredSchool.Id));
                            saveToAccountDesiredSchoolList.add(new DesiredSchool__c(DesiredSchoolArea__c = saveToAccountDesiredSchoolAreaList[desiredSchoolIndex].Id, School__c = desiredSchool.Id));
                        }
                        desiredSchoolIndex++;
                    }

                    if(String.valueOf(targetCard.elementarySchoolArea) != null){
                        for(School__c desiredSchool : targetCard.elementarySchoolList){//選択された小学校から希望学校を設定
                            saveDesiredSchoolList.add(new DesiredSchool__c(DesiredSchoolArea__c = saveDesiredSchoolAreaList[desiredSchoolIndex].Id, School__c = desiredSchool.Id));
                            saveToAccountDesiredSchoolList.add(new DesiredSchool__c(DesiredSchoolArea__c = saveToAccountDesiredSchoolAreaList[desiredSchoolIndex].Id, School__c = desiredSchool.Id));
                        }
                        desiredSchoolIndex++;
                    }

                    SecureDML.secureUpsert(saveDesiredSchoolList);//来店カード用希望学校を作成
                    SecureDML.secureUpsert(saveToAccountDesiredSchoolList);//取引先用希望学校を作成
                    // ▲問合せ415で追加

                    Integer addRouteIndex = 0;
                    if(String.valueOf(targetCard.trainRoute1) != null){
                        saveVisitCard.DesiredTrainRoute1__c = saveDesiredTrainRouteList[addRouteIndex].Id ;//希望沿線１ 
                        addRouteIndex++;
                    }
                    if(String.valueOf(targetCard.trainRoute2) != null){
                        saveVisitCard.DesiredTrainRoute2__c = saveDesiredTrainRouteList[addRouteIndex].Id ;//希望沿線２ 
                        addRouteIndex++;
                    }
                    if(String.valueOf(targetCard.trainRoute3) != null){
                        saveVisitCard.DesiredTrainRoute3__c = saveDesiredTrainRouteList[addRouteIndex].Id ;//希望沿線３ 
                        addRouteIndex++;
                    }

                    //路線の選択箇所をIndexを使って合わせる
                    addRouteIndex = 0;
                    if(String.valueOf(targetCard.trainRoute1) != null){
                        saveAccount.DesiredTrainRoute1__c = saveToAccountDesiredTrainRouteList[addRouteIndex].Id ;//希望沿線１ 
                        addRouteIndex++;
                    }
                    if(String.valueOf(targetCard.trainRoute2) != null){
                        saveAccount.DesiredTrainRoute2__c = saveToAccountDesiredTrainRouteList[addRouteIndex].Id ;//希望沿線２ 
                        addRouteIndex++;
                    }
                    if(String.valueOf(targetCard.trainRoute3) != null){
                        saveAccount.DesiredTrainRoute3__c = saveToAccountDesiredTrainRouteList[addRouteIndex].Id ;//希望沿線３ 
                        addRouteIndex++;
                    }

                    // ▼問合せ415で追加
                    //希望学区の選択箇所をIndexを使って合わせる
                    Integer addSchoolAreaIndex = 0;
                    if(String.valueOf(targetCard.juniorHighSchoolArea) != null){
                        saveVisitCard.DesiredJuniorHighSchoolArea__c = saveDesiredSchoolAreaList[addSchoolAreaIndex].Id ;//中学校希望学区（エリア）
                        addSchoolAreaIndex++;
                    }
                    if(String.valueOf(targetCard.elementarySchoolArea) != null){
                        saveVisitCard.DesiredElementarySchoolArea__c = saveDesiredSchoolAreaList[addSchoolAreaIndex].Id ;//小学校希望学区（エリア）
                        addSchoolAreaIndex++;
                    }

                    //希望学区の選択箇所をIndexを使って合わせる
                    addSchoolAreaIndex = 0;
                    if(String.valueOf(targetCard.juniorHighSchoolArea) != null){
                        saveAccount.DesiredJuniorHighSchoolArea__c = saveToAccountDesiredSchoolAreaList[addSchoolAreaIndex].Id ;//中学校希望学区（エリア）
                        addSchoolAreaIndex++;
                    }
                    if(String.valueOf(targetCard.elementarySchoolArea) != null){
                        saveAccount.DesiredElementarySchoolArea__c = saveToAccountDesiredSchoolAreaList[addSchoolAreaIndex].Id ;//小学校希望学区（エリア）
                        addSchoolAreaIndex++;
                    }                    
                    // ▲問合せ415で追加


                    //表示路線再設定
                    targetCard.desiredTrainRoute1 = saveVisitCard.DesiredTrainRoute1__c;//希望沿線１ 
                    targetCard.desiredTrainRoute2 = saveVisitCard.DesiredTrainRoute2__c;//希望沿線２ 
                    targetCard.desiredTrainRoute3 = saveVisitCard.DesiredTrainRoute3__c;//希望沿線３ 
                    
                    //更新時に削除する希望路線再設定
                    targetCard.visitCardDesiredTrainRoute1 = saveVisitCard.DesiredTrainRoute1__c;//来店カード希望沿線１
                    targetCard.visitCardDesiredTrainRoute2 = saveVisitCard.DesiredTrainRoute2__c;//来店カード希望沿線2
                    targetCard.visitCardDesiredTrainRoute3 = saveVisitCard.DesiredTrainRoute3__c;//来店カード希望沿線3
                    targetCard.accountDesiredTrainRoute1 = saveAccount.DesiredTrainRoute1__c;//取引先希望沿線１
                    targetCard.accountDesiredTrainRoute2 = saveAccount.DesiredTrainRoute2__c;//取引先希望沿線2
                    targetCard.accountDesiredTrainRoute3 = saveAccount.DesiredTrainRoute3__c;//取引先希望沿線3

                    saveVisitCard.DesiredArea__c = targetCard.desiredArea ;//希望地域 

                    saveVisitCard.WalkingTime__c = targetCard.walkingTime ;//徒歩 
                    saveVisitCard.IsOneRoom__c = targetCard.isOneRoom ;//ワンルーム 
                    saveVisitCard.Is1K__c = targetCard.is1K ;//1K 
                    saveVisitCard.Is1DK__c = targetCard.is1DK ;//1DK 
                    saveVisitCard.Is1LDK1SLDK__c = targetCard.is1LDK1SLDK ;//1LDK/SLDK 
                    saveVisitCard.Is2K2DK__c = targetCard.is2K2DK ;//2K/DK 
                    saveVisitCard.Is2LDK2SLDK__c = targetCard.is2LDK2SLDK ;//2LDK/SLDK 
                    saveVisitCard.Is3K3DK__c = targetCard.is3K3DK ;//3K/DK 
                    saveVisitCard.Is3LDK3SLDK__c = targetCard.is3LDK3SLDK ;//3LDK/SLDK 
                    saveVisitCard.Is4K4DK4LDKFrom__c = targetCard.is4K4DK4LDKFrom ;//4K/DK/LDK~ 
                    saveVisitCard.IsWooden__c = targetCard.isWooden ;//木造 
                    saveVisitCard.IsLightweightSteel__c = targetCard.isLightweightSteel ;//軽量鉄骨 
                    saveVisitCard.IsSteel__c = targetCard.isSteel ;//鉄骨造 
                    saveVisitCard.IsRC__c = targetCard.isRC ;//RC 
                    saveVisitCard.IsSRC__c = targetCard.isSRC ;//SRC 
                    saveVisitCard.IsNorth__c = targetCard.isNorth ;//北 
                    saveVisitCard.IsNorthEast__c = targetCard.isNorthEast ;//北東 
                    saveVisitCard.IsEast__c = targetCard.isEast ;//東 
                    saveVisitCard.IsSouthEast__c = targetCard.isSouthEast ;//南東 
                    saveVisitCard.IsSouth__c = targetCard.isSouth ;//南 
                    saveVisitCard.IsSouthWest__c = targetCard.isSouthWest ;//南西 
                    saveVisitCard.IsWest__c = targetCard.isWest ;//西 
                    saveVisitCard.IsNorthWest__c = targetCard.isNorthWest ;//北西 
                    saveVisitCard.IsNonDeposit__c = targetCard.isNonDeposit ;//敷金/保証金なし 
                    saveVisitCard.IsNonKeyMoney__c = targetCard.isNonKeyMoney ;//礼金なし 
                    saveVisitCard.IsNonCleaningFee__c = targetCard.isNonCleaningFee ;//定額修繕費なし 
                    saveVisitCard.IsNonRenewalFee__c = targetCard.isNonRenewalFee ;//更新料なし 

                    saveVisitCard.RentFeeFrom__c = CommonUtil.stringToDecimal(targetCard.rentFeeFrom) ;//賃料から 
                    saveVisitCard.RentFeeTo__c = CommonUtil.stringToDecimal(targetCard.rentFeeTo) ;//賃料まで 

                    saveVisitCard.IsIncludeManagementFee__c = targetCard.isIncludeManagementFee ;//管理費込み 
                    saveVisitCard.IsIncludeParkingFee__c = targetCard.isIncludeParkingFee ;//駐車場代込み 
                    saveVisitCard.OccupancyAreaLowerLimit__c = targetCard.occupancyAreaLowerLimit ;//占有面積（下限） 
                    saveVisitCard.OccupancyAreaUpperLimit__c = targetCard.occupancyAreaUpperLimit ;//占有面積（上限） 
                    saveVisitCard.BuildingAge__c = targetCard.buildingAge ;//築年数
                    saveVisitCard.IsDetachedHouse__c = targetCard.isDetachedHouse ;//戸建て 
                    saveVisitCard.IsMaisonette__c = targetCard.isMaisonette ;//メゾネット 
                    saveVisitCard.IsLoft__c = targetCard.isLoft ;//ロフト 
                    saveVisitCard.IsDesigners__c = targetCard.isDesigners ;//デザイナーズ 
                    saveVisitCard.IsRenovation__c = targetCard.isRenovation ;//リノベーション 
                    saveVisitCard.IsAllWestern__c = targetCard.isAllWestern ;//オール洋間 
                    saveVisitCard.IsCondominiumRental__c = targetCard.isCondominiumRental ;//分譲賃貸 
                    saveVisitCard.IsFirstFloor__c = targetCard.isFirstFloor ;//1階 
                    saveVisitCard.IsSecondFloorOver__c = targetCard.isSecondFloorOver ;//2階以上 
                    saveVisitCard.IsTopFloor__c = targetCard.isTopFloor ;//最上階 
                    saveVisitCard.IsCornerRoom__c = targetCard.isCornerRoom ;//角部屋 
                    saveVisitCard.IsBalcony__c = targetCard.isBalcony ;//バルコニー 
                    saveVisitCard.IsRoofBalcony__c = targetCard.isRoofBalcony ;//ルーフバルコニー 
                    saveVisitCard.IsPrivateGarden__c = targetCard.isPrivateGarden ;//専用庭 
                    saveVisitCard.IsParking__c = targetCard.isParking ;//駐車場空きあり 
                    saveVisitCard.IsInSiteParking__c = targetCard.isInSiteParking ;//敷地内駐車場 
                    saveVisitCard.IsPluralCarParking__c = targetCard.isPluralCarParking ;//駐車場2台可 
                    saveVisitCard.IsBuiltInGarage__c = targetCard.isBuiltInGarage ;//ビルトインガレージ 
                    saveVisitCard.IsCarport__c = targetCard.isCarport ;//カーポート 
                    saveVisitCard.IsBicycleParking__c = targetCard.isBicycleParking ;//駐輪場 
                    saveVisitCard.IsBikeStorage__c = targetCard.isBikeStorage ;//バイク可 
                    saveVisitCard.IsSmallBike__c = targetCard.isSmallBike ;//小型バイク 
                    saveVisitCard.IsMediumBike__c = targetCard.isMediumBike ;//中型バイク 
                    saveVisitCard.IsLargeBike__c = targetCard.isLargeBike ;//大型バイク 
                    saveVisitCard.IsElevator__c = targetCard.isElevator ;//エレベーター 
                    saveVisitCard.IsDeliveryBox__c = targetCard.isDeliveryBox ;//宅配ボックス 
                    saveVisitCard.IsCounterKitchen__c = targetCard.isCounterKitchen ;//カウンターキッチン 
                    saveVisitCard.IsSystemKitchen__c = targetCard.isSystemKitchen ;//システムキッチン 
                    saveVisitCard.IsGasStove__c = targetCard.isGasStove ;//ガスコンロ 
                    saveVisitCard.IsElectricStove__c = targetCard.isElectricStove ;//電気コンロ 
                    saveVisitCard.IsInductionHeating__c = targetCard.isInductionHeating ;//IHコンロ 
                    saveVisitCard.IsTwoGasStove__c = targetCard.isTwoGasStove ;//コンロ2口 
                    saveVisitCard.IsMoreGasStove__c = targetCard.isMoreGasStove ;//コンロ3口以上 
                    saveVisitCard.IsSepalateBathAndRestroom__c = targetCard.isSepalateBathAndRestroom ;//バス・トイレ別 
                    saveVisitCard.IsAditionalBoiling__c = targetCard.isAditionalBoiling ;//追焚機能 
                    saveVisitCard.IsDehumidifierForBathroom__c = targetCard.isDehumidifierForBathroom ;//浴室乾燥機 
                    saveVisitCard.IsWashlet__c = targetCard.isWashlet ;//温水洗浄便座 
                    saveVisitCard.IsShowerWashBasin__c = targetCard.isShowerWashBasin ;//シャワー付き洗面台 
                    saveVisitCard.IsRegalLavatory__c = targetCard.isRegalLavatory ;//洗面所独立 
                    saveVisitCard.IsInnerLandry__c = targetCard.isInnerLandry ;//室内洗濯機置場 
                    saveVisitCard.IsTownGas__c = targetCard.isTownGas ;//都市ガス 
                    saveVisitCard.IsPropaneGas__c = targetCard.isPropaneGas ;//プロパンガス 
                    saveVisitCard.IsAllElectric__c = targetCard.isAllElectric ;//オール電化 
                    saveVisitCard.IsAirConditioner__c = targetCard.isAirConditioner ;//エアコン 
                    saveVisitCard.IsFloorHeating__c = targetCard.isFloorHeating ;//床暖房 
                    saveVisitCard.IsShoesBox__c = targetCard.isShoesBox ;//シューズボックス 
                    saveVisitCard.IsShoeCloak__c = targetCard.isShoeCloak ;//シューズクローク 
                    saveVisitCard.IsWalkInCloset__c = targetCard.isWalkInCloset ;//ウォークインクローゼット 
                    saveVisitCard.IsTrunkRoom__c = targetCard.isTrunkRoom ;//トランクルーム 
                    saveVisitCard.IsBSAntenna__c = targetCard.isBSAntenna ;//BSアンテナ 
                    saveVisitCard.IsCSAntenna__c = targetCard.isCSAntenna ;//CSアンテナ 
                    saveVisitCard.IsCATV__c = targetCard.isCATV ;//CATV 
                    saveVisitCard.IsInternetFree__c = targetCard.isInternetFree ;//ネット使用料無料 
                    saveVisitCard.IsMonitorIntercom__c = targetCard.isMonitorIntercom ;//モニター付きインターホン 
                    saveVisitCard.IsAutoLock__c = targetCard.isAutoLock ;//オートロック 
                    saveVisitCard.IsFurniture__c = targetCard.isFurniture ;//家具付き 
                    saveVisitCard.IsHomeAppliance__c = targetCard.isHomeAppliance ;//家電付き 
                    saveVisitCard.IsNoGuarantor__c = targetCard.isNoGuarantor ;//保証人不要 
                    saveVisitCard.IsNonGuaranteeidCompany__c = targetCard.isNonGuaranteeidCompany ;//保証会社不要 
                    saveVisitCard.IsMusicalInstruments__c = targetCard.isMusicalInstruments ;//楽器相談可 
                    saveVisitCard.IsForeigner__c = targetCard.isForeigner ;//外国人契約可 
                    saveVisitCard.IsOfficeAvailable__c = targetCard.isOfficeAvailable ;//事務所利用可 
                    saveVisitCard.IsWelfareAvailable__c = targetCard.isWelfareAvailable ;//生活保護契約可 
                    saveVisitCard.IsPet__c = targetCard.isPet ;//ペット可 
                    saveVisitCard.IsLargePet__c = targetCard.isLargePet ;//ペット(大型犬) 
                    saveVisitCard.IsMiddlePet__c = targetCard.isMiddlePet ;//ペット(中型犬) 
                    saveVisitCard.IsSmallPet__c = targetCard.isSmallPet ;//ペット(小型犬) 
                    saveVisitCard.IsCat__c = targetCard.isCat ;//ペット(猫) 
                    saveVisitCard.IsOtherPet__c = targetCard.isOtherPet ;//ペット(その他) 
                    saveVisitCard.IsTwoTenant__c = targetCard.isTwoTenant ;//2人入居可 
                    saveVisitCard.IsRoomShare__c = targetCard.isRoomShare ;//ルームシェア可 
                    saveVisitCard.IsIppambutsu__c = targetCard.isIppambutsu ;//一般物 
                    saveVisitCard.IsElderly__c = targetCard.isElderly ;//高齢者歓迎 
                    saveVisitCard.IsWoman__c = targetCard.isWoman ;//女性限定 
                    saveVisitCard.IsStudent__c = targetCard.isStudent ;//学生限定マンション 

                    saveAccount.DesiredArea__c = targetCard.desiredArea ;//希望地域 

                    saveAccount.WalkingTime__c = targetCard.walkingTime ;//徒歩 
                    saveAccount.IsOneRoom__c = targetCard.isOneRoom ;//ワンルーム 
                    saveAccount.Is1K__c = targetCard.is1K ;//1K 
                    saveAccount.Is1DK__c = targetCard.is1DK ;//1DK 
                    saveAccount.Is1LDK1SLDK__c = targetCard.is1LDK1SLDK ;//1LDK/SLDK 
                    saveAccount.Is2K2DK__c = targetCard.is2K2DK ;//2K/DK 
                    saveAccount.Is2LDK2SLDK__c = targetCard.is2LDK2SLDK ;//2LDK/SLDK 
                    saveAccount.Is3K3DK__c = targetCard.is3K3DK ;//3K/DK 
                    saveAccount.Is3LDK3SLDK__c = targetCard.is3LDK3SLDK ;//3LDK/SLDK 
                    saveAccount.Is4K4DK4LDKFrom__c = targetCard.is4K4DK4LDKFrom ;//4K/DK/LDK~ 
                    saveAccount.IsWooden__c = targetCard.isWooden ;//木造 
                    saveAccount.IsLightweightSteel__c = targetCard.isLightweightSteel ;//軽量鉄骨 
                    saveAccount.IsSteel__c = targetCard.isSteel ;//鉄骨造 
                    saveAccount.IsRC__c = targetCard.isRC ;//RC 
                    saveAccount.IsSRC__c = targetCard.isSRC ;//SRC 
                    saveAccount.IsNorth__c = targetCard.isNorth ;//北 
                    saveAccount.IsNorthEast__c = targetCard.isNorthEast ;//北東 
                    saveAccount.IsEast__c = targetCard.isEast ;//東 
                    saveAccount.IsSouthEast__c = targetCard.isSouthEast ;//南東 
                    saveAccount.IsSouth__c = targetCard.isSouth ;//南 
                    saveAccount.IsSouthWest__c = targetCard.isSouthWest ;//南西 
                    saveAccount.IsWest__c = targetCard.isWest ;//西 
                    saveAccount.IsNorthWest__c = targetCard.isNorthWest ;//北西 
                    saveAccount.IsNonDeposit__c = targetCard.isNonDeposit ;//敷金/保証金なし 
                    saveAccount.IsNonKeyMoney__c = targetCard.isNonKeyMoney ;//礼金なし 
                    saveAccount.IsNonCleaningFee__c = targetCard.isNonCleaningFee ;//定額修繕費なし 
                    saveAccount.IsNonRenewalFee__c = targetCard.isNonRenewalFee ;//更新料なし 

                    saveAccount.RentFeeFrom__c = CommonUtil.stringToDecimal(targetCard.rentFeeFrom) ;//賃料から 
                    saveAccount.RentFeeTo__c = CommonUtil.stringToDecimal(targetCard.rentFeeTo) ;//賃料まで 

                    saveAccount.IsIncludeManagementFee__c = targetCard.isIncludeManagementFee ;//管理費込み 
                    saveAccount.IsIncludeParkingFee__c = targetCard.isIncludeParkingFee ;//駐車場代込み 
                    saveAccount.OccupancyAreaLowerLimit__c = targetCard.occupancyAreaLowerLimit ;//占有面積（下限） 
                    saveAccount.OccupancyAreaUpperLimit__c = targetCard.occupancyAreaUpperLimit ;//占有面積（上限） 
                    saveAccount.BuildingAge__c = targetCard.buildingAge ;//築年数
                    saveAccount.IsDetachedHouse__c = targetCard.isDetachedHouse ;//戸建て 
                    saveAccount.IsMaisonette__c = targetCard.isMaisonette ;//メゾネット 
                    saveAccount.IsLoft__c = targetCard.isLoft ;//ロフト 
                    saveAccount.IsDesigners__c = targetCard.isDesigners ;//デザイナーズ 
                    saveAccount.IsRenovation__c = targetCard.isRenovation ;//リノベーション 
                    saveAccount.IsAllWestern__c = targetCard.isAllWestern ;//オール洋間 
                    saveAccount.IsCondominiumRental__c = targetCard.isCondominiumRental ;//分譲賃貸 
                    saveAccount.IsFirstFloor__c = targetCard.isFirstFloor ;//1階 
                    saveAccount.IsSecondFloorOver__c = targetCard.isSecondFloorOver ;//2階以上 
                    saveAccount.IsTopFloor__c = targetCard.isTopFloor ;//最上階 
                    saveAccount.IsCornerRoom__c = targetCard.isCornerRoom ;//角部屋 
                    saveAccount.IsBalcony__c = targetCard.isBalcony ;//バルコニー 
                    saveAccount.IsRoofBalcony__c = targetCard.isRoofBalcony ;//ルーフバルコニー 
                    saveAccount.IsPrivateGarden__c = targetCard.isPrivateGarden ;//専用庭 
                    saveAccount.IsParking__c = targetCard.isParking ;//駐車場空きあり 
                    saveAccount.IsInSiteParking__c = targetCard.isInSiteParking ;//敷地内駐車場 
                    saveAccount.IsPluralCarParking__c = targetCard.isPluralCarParking ;//駐車場2台可 
                    saveAccount.IsBuiltInGarage__c = targetCard.isBuiltInGarage ;//ビルトインガレージ 
                    saveAccount.IsCarport__c = targetCard.isCarport ;//カーポート 
                    saveAccount.IsBicycleParking__c = targetCard.isBicycleParking ;//駐輪場 
                    saveAccount.IsBikeStorage__c = targetCard.isBikeStorage ;//バイク可 
                    saveAccount.IsSmallBike__c = targetCard.isSmallBike ;//小型バイク 
                    saveAccount.IsMediumBike__c = targetCard.isMediumBike ;//中型バイク 
                    saveAccount.IsLargeBike__c = targetCard.isLargeBike ;//大型バイク 
                    saveAccount.IsElevator__c = targetCard.isElevator ;//エレベーター 
                    saveAccount.IsDeliveryBox__c = targetCard.isDeliveryBox ;//宅配ボックス 
                    saveAccount.IsCounterKitchen__c = targetCard.isCounterKitchen ;//カウンターキッチン 
                    saveAccount.IsSystemKitchen__c = targetCard.isSystemKitchen ;//システムキッチン 
                    saveAccount.IsGasStove__c = targetCard.isGasStove ;//ガスコンロ 
                    saveAccount.IsElectricStove__c = targetCard.isElectricStove ;//電気コンロ 
                    saveAccount.IsInductionHeating__c = targetCard.isInductionHeating ;//IHコンロ 
                    saveAccount.IsTwoGasStove__c = targetCard.isTwoGasStove ;//コンロ2口 
                    saveAccount.IsMoreGasStove__c = targetCard.isMoreGasStove ;//コンロ3口以上 
                    saveAccount.IsSepalateBathAndRestroom__c = targetCard.isSepalateBathAndRestroom ;//バス・トイレ別 
                    saveAccount.IsAditionalBoiling__c = targetCard.isAditionalBoiling ;//追焚機能 
                    saveAccount.IsDehumidifierForBathroom__c = targetCard.isDehumidifierForBathroom ;//浴室乾燥機 
                    saveAccount.IsWashlet__c = targetCard.isWashlet ;//温水洗浄便座 
                    saveAccount.IsShowerWashBasin__c = targetCard.isShowerWashBasin ;//シャワー付き洗面台 
                    saveAccount.IsRegalLavatory__c = targetCard.isRegalLavatory ;//洗面所独立 
                    saveAccount.IsInnerLandry__c = targetCard.isInnerLandry ;//室内洗濯機置場 
                    saveAccount.IsTownGas__c = targetCard.isTownGas ;//都市ガス 
                    saveAccount.IsPropaneGas__c = targetCard.isPropaneGas ;//プロパンガス 
                    saveAccount.IsAllElectric__c = targetCard.isAllElectric ;//オール電化 
                    saveAccount.IsAirConditioner__c = targetCard.isAirConditioner ;//エアコン 
                    saveAccount.IsFloorHeating__c = targetCard.isFloorHeating ;//床暖房 
                    saveAccount.IsShoesBox__c = targetCard.isShoesBox ;//シューズボックス 
                    saveAccount.IsShoeCloak__c = targetCard.isShoeCloak ;//シューズクローク 
                    saveAccount.IsWalkInCloset__c = targetCard.isWalkInCloset ;//ウォークインクローゼット 
                    saveAccount.IsTrunkRoom__c = targetCard.isTrunkRoom ;//トランクルーム 
                    saveAccount.IsBSAntenna__c = targetCard.isBSAntenna ;//BSアンテナ 
                    saveAccount.IsCSAntenna__c = targetCard.isCSAntenna ;//CSアンテナ 
                    saveAccount.IsCATV__c = targetCard.isCATV ;//CATV 
                    saveAccount.IsInternetFree__c = targetCard.isInternetFree ;//ネット使用料無料 
                    saveAccount.IsMonitorIntercom__c = targetCard.isMonitorIntercom ;//モニター付きインターホン 
                    saveAccount.IsAutoLock__c = targetCard.isAutoLock ;//オートロック 
                    saveAccount.IsFurniture__c = targetCard.isFurniture ;//家具付き 
                    saveAccount.IsHomeAppliance__c = targetCard.isHomeAppliance ;//家電付き 
                    saveAccount.IsNoGuarantor__c = targetCard.isNoGuarantor ;//保証人不要 
                    saveAccount.IsNonGuaranteeidCompany__c = targetCard.isNonGuaranteeidCompany ;//保証会社不要 
                    saveAccount.IsMusicalInstruments__c = targetCard.isMusicalInstruments ;//楽器相談可 
                    saveAccount.IsForeigner__c = targetCard.isForeigner ;//外国人契約可 
                    saveAccount.IsOfficeAvailable__c = targetCard.isOfficeAvailable ;//事務所利用可 
                    saveAccount.IsWelfareAvailable__c = targetCard.isWelfareAvailable ;//生活保護契約可 
                    saveAccount.IsPet__c = targetCard.isPet ;//ペット可 
                    saveAccount.IsLargePet__c = targetCard.isLargePet ;//ペット(大型犬) 
                    saveAccount.IsMiddlePet__c = targetCard.isMiddlePet ;//ペット(中型犬) 
                    saveAccount.IsSmallPet__c = targetCard.isSmallPet ;//ペット(小型犬) 
                    saveAccount.IsCat__c = targetCard.isCat ;//ペット(猫) 
                    saveAccount.IsOtherPet__c = targetCard.isOtherPet ;//ペット(その他) 
                    saveAccount.IsTwoTenant__c = targetCard.isTwoTenant ;//2人入居可 
                    saveAccount.IsRoomShare__c = targetCard.isRoomShare ;//ルームシェア可 
                    saveAccount.IsIppambutsu__c = targetCard.isIppambutsu ;//一般物 
                    saveAccount.IsElderly__c = targetCard.isElderly ;//高齢者歓迎 
                    saveAccount.IsWoman__c = targetCard.isWoman ;//女性限定 
                    saveAccount.IsStudent__c = targetCard.isStudent ;//学生限定マンション 
                    saveAccount.PropertyConditionsName__c = targetCard.Name; // 物件条件名

                    // ▼2021.10.08 No.307 対応で移動
                    SecureDML.secureUpsert(saveAccount);//取引先更新、作成
                    saveVisitCard.Account__c = saveAccount.Id;//取引先Id
                    SecureDML.secureUpsert(saveVisitCard);//来店カード更新、作成
                    // ▲2021.10.08 No.307 対応
    
                } else { // お客様物件条件への登録・更新処理
                    
                    AccountPropertyConditions__c saveCond = new AccountPropertyConditions__c(); // お客様物件条件の保存用変数
                    saveCond.Name = targetCard.Name;
                    parking = CommonConst.VISITCARD_PARKING_NO;//駐車場：無
                    // deleteFlgがfalseのデータのみを登録、更新する。
                    if(!targetCard.deleteFlg){
                        // お客様物件条件が既存の場合はIDをセットする。
                        if(targetCard.dispCondId != null){
                            saveCond.id = targetCard.dispCondId;
                        }

                        // 取引先Idを設定する。
						if(displayVisitCard.account.id == null){
							saveCond.Account__c = saveAccount.Id;
						}else{
							saveCond.Account__c = displayVisitCard.account.id;
						}
                        

                        //台数 が1以上あった場合:有
                        if(CommonUtil.stringToDecimal(targetCard.carCount) > 0){
                            parking = CommonConst.VISITCARD_PARKING_EXISTS;
                        }

                        saveCond.CarCount__c = CommonUtil.stringToDecimal(targetCard.carCount) ;//台数 
                        saveCond.Parking__c = parking ; //駐車場
                        saveCond.ParkingFeeLimit__c = CommonUtil.stringToDecimal(targetCard.parkingFeeLimit) ;//1台当たりの料金上限 

                        //希望路線を削除して、希望駅を初期化する
                        // ▼2021.10.08 No.307 対応で削除　取引先（希望路線）来店カード（希望路線）
                        if(String.valueOf(targetCard.AccountPropertyConditionsTrainRoute1) != null){//希望路線1
                            deleteDesiredTrainRoute.add(new DesiredTrainRoute__c(Id = targetCard.AccountPropertyConditionsTrainRoute1));
                        }
                        if(String.valueOf(targetCard.AccountPropertyConditionsTrainRoute2) != null){//希望路線2
                            deleteDesiredTrainRoute.add(new DesiredTrainRoute__c(Id = targetCard.AccountPropertyConditionsTrainRoute2));
                        }
                        if(String.valueOf(targetCard.AccountPropertyConditionsTrainRoute3) != null){//希望路線3
                            deleteDesiredTrainRoute.add(new DesiredTrainRoute__c(Id = targetCard.AccountPropertyConditionsTrainRoute3));
                        }

                        //希望路線を新規に作成する
                        if(String.valueOf(targetCard.trainRoute1) != null){
                            DesiredTrainRoute__c tmptrainRoute1 = new DesiredTrainRoute__c(TrainRoute__c = targetCard.trainRoute1);
                            saveCondTrainRouteMap.put(targetCard.Name + '1', tmptrainRoute1);
                        }
                        if(String.valueOf(targetCard.trainRoute2) != null){
                            DesiredTrainRoute__c tmptrainRoute2 = new DesiredTrainRoute__c(TrainRoute__c = targetCard.trainRoute2);
                            saveCondTrainRouteMap.put(targetCard.Name + '2', tmptrainRoute2);
                        }
                        if(String.valueOf(targetCard.trainRoute3) != null){
                            DesiredTrainRoute__c tmptrainRoute3 = new DesiredTrainRoute__c(TrainRoute__c = targetCard.trainRoute3);
                            saveCondTrainRouteMap.put(targetCard.Name + '3', tmptrainRoute3);
                        }

                        //希望学区を削除して、希望学校を初期化する
                        // ▼2021.10.08 No.307 対応で削除　取引先（希望学区）来店カード（希望学区）
                        if(String.valueOf(targetCard.AccountPropertyConditionsElementarySchoolArea) != null){//小学校希望学区
                            deleteDesiredSchoolArea.add(new DesiredSchoolArea__c(Id = targetCard.AccountPropertyConditionsElementarySchoolArea));
                        }
                        if(String.valueOf(targetCard.AccountPropertyConditionsJuniorHighSchoolArea) != null){//中学校希望学区
                            deleteDesiredSchoolArea.add(new DesiredSchoolArea__c(Id = targetCard.AccountPropertyConditionsJuniorHighSchoolArea));
                        }

                        //希望学区を新規に作成する
                        if(String.valueOf(targetCard.juniorHighSchoolArea) != null){
                            DesiredSchoolArea__c tmpSchoolArea = new DesiredSchoolArea__c(SchoolArea__c = targetCard.juniorHighSchoolArea);
                            saveCondSchoolAreaMap.put(targetCard.Name + 'junior', tmpSchoolArea);
                        }
                        if(String.valueOf(targetCard.elementarySchoolArea) != null){
                            DesiredSchoolArea__c tmpSchoolArea = new DesiredSchoolArea__c(SchoolArea__c = targetCard.elementarySchoolArea);
                            saveCondSchoolAreaMap.put(targetCard.Name + 'element', tmpSchoolArea);
                        }
                        
                        saveCond.DesiredArea__c = targetCard.desiredArea ;//希望地域 

                        saveCond.WalkingTime__c = targetCard.walkingTime ;//徒歩 
                        saveCond.IsOneRoom__c = targetCard.isOneRoom ;//ワンルーム 
                        saveCond.Is1K__c = targetCard.is1K ;//1K 
                        saveCond.Is1DK__c = targetCard.is1DK ;//1DK 
                        saveCond.Is1LDK1SLDK__c = targetCard.is1LDK1SLDK ;//1LDK/SLDK 
                        saveCond.Is2K2DK__c = targetCard.is2K2DK ;//2K/DK 
                        saveCond.Is2LDK2SLDK__c = targetCard.is2LDK2SLDK ;//2LDK/SLDK 
                        saveCond.Is3K3DK__c = targetCard.is3K3DK ;//3K/DK 
                        saveCond.Is3LDK3SLDK__c = targetCard.is3LDK3SLDK ;//3LDK/SLDK 
                        saveCond.Is4K4DK4LDKFrom__c = targetCard.is4K4DK4LDKFrom ;//4K/DK/LDK~ 
                        saveCond.IsWooden__c = targetCard.isWooden ;//木造 
                        saveCond.IsLightweightSteel__c = targetCard.isLightweightSteel ;//軽量鉄骨 
                        saveCond.IsSteel__c = targetCard.isSteel ;//鉄骨造 
                        saveCond.IsRC__c = targetCard.isRC ;//RC 
                        saveCond.IsSRC__c = targetCard.isSRC ;//SRC 
                        saveCond.IsNorth__c = targetCard.isNorth ;//北 
                        saveCond.IsNorthEast__c = targetCard.isNorthEast ;//北東 
                        saveCond.IsEast__c = targetCard.isEast ;//東 
                        saveCond.IsSouthEast__c = targetCard.isSouthEast ;//南東 
                        saveCond.IsSouth__c = targetCard.isSouth ;//南 
                        saveCond.IsSouthWest__c = targetCard.isSouthWest ;//南西 
                        saveCond.IsWest__c = targetCard.isWest ;//西 
                        saveCond.IsNorthWest__c = targetCard.isNorthWest ;//北西 
                        saveCond.IsNonDeposit__c = targetCard.isNonDeposit ;//敷金/保証金なし 
                        saveCond.IsNonKeyMoney__c = targetCard.isNonKeyMoney ;//礼金なし 
                        saveCond.IsNonCleaningFee__c = targetCard.isNonCleaningFee ;//定額修繕費なし 
                        saveCond.IsNonRenewalFee__c = targetCard.isNonRenewalFee ;//更新料なし 

                        saveCond.RentFeeFrom__c = CommonUtil.stringToDecimal(targetCard.rentFeeFrom) ;//賃料から 
                        saveCond.RentFeeTo__c = CommonUtil.stringToDecimal(targetCard.rentFeeTo) ;//賃料まで 

                        saveCond.IsIncludeManagementFee__c = targetCard.isIncludeManagementFee ;//管理費込み 
                        saveCond.IsIncludeParkingFee__c = targetCard.isIncludeParkingFee ;//駐車場代込み 
                        saveCond.OccupancyAreaLowerLimit__c = targetCard.occupancyAreaLowerLimit ;//占有面積（下限） 
                        saveCond.OccupancyAreaUpperLimit__c = targetCard.occupancyAreaUpperLimit ;//占有面積（上限） 
                        saveCond.BuildingAge__c = targetCard.buildingAge ;//築年数
                        saveCond.IsDetachedHouse__c = targetCard.isDetachedHouse ;//戸建て 
                        saveCond.IsMaisonette__c = targetCard.isMaisonette ;//メゾネット 
                        saveCond.IsLoft__c = targetCard.isLoft ;//ロフト 
                        saveCond.IsDesigners__c = targetCard.isDesigners ;//デザイナーズ 
                        saveCond.IsRenovation__c = targetCard.isRenovation ;//リノベーション 
                        saveCond.IsAllWestern__c = targetCard.isAllWestern ;//オール洋間 
                        saveCond.IsCondominiumRental__c = targetCard.isCondominiumRental ;//分譲賃貸 
                        saveCond.IsFirstFloor__c = targetCard.isFirstFloor ;//1階 
                        saveCond.IsSecondFloorOver__c = targetCard.isSecondFloorOver ;//2階以上 
                        saveCond.IsTopFloor__c = targetCard.isTopFloor ;//最上階 
                        saveCond.IsCornerRoom__c = targetCard.isCornerRoom ;//角部屋 
                        saveCond.IsBalcony__c = targetCard.isBalcony ;//バルコニー 
                        saveCond.IsRoofBalcony__c = targetCard.isRoofBalcony ;//ルーフバルコニー 
                        saveCond.IsPrivateGarden__c = targetCard.isPrivateGarden ;//専用庭 
                        saveCond.IsParking__c = targetCard.isParking ;//駐車場空きあり 
                        saveCond.IsInSiteParking__c = targetCard.isInSiteParking ;//敷地内駐車場 
                        saveCond.IsPluralCarParking__c = targetCard.isPluralCarParking ;//駐車場2台可 
                        saveCond.IsBuiltInGarage__c = targetCard.isBuiltInGarage ;//ビルトインガレージ 
                        saveCond.IsCarport__c = targetCard.isCarport ;//カーポート 
                        saveCond.IsBicycleParking__c = targetCard.isBicycleParking ;//駐輪場 
                        saveCond.IsBikeStorage__c = targetCard.isBikeStorage ;//バイク可 
                        saveCond.IsSmallBike__c = targetCard.isSmallBike ;//小型バイク 
                        saveCond.IsMediumBike__c = targetCard.isMediumBike ;//中型バイク 
                        saveCond.IsLargeBike__c = targetCard.isLargeBike ;//大型バイク 
                        saveCond.IsElevator__c = targetCard.isElevator ;//エレベーター 
                        saveCond.IsDeliveryBox__c = targetCard.isDeliveryBox ;//宅配ボックス 
                        saveCond.IsCounterKitchen__c = targetCard.isCounterKitchen ;//カウンターキッチン 
                        saveCond.IsSystemKitchen__c = targetCard.isSystemKitchen ;//システムキッチン 
                        saveCond.IsGasStove__c = targetCard.isGasStove ;//ガスコンロ 
                        saveCond.IsElectricStove__c = targetCard.isElectricStove ;//電気コンロ 
                        saveCond.IsInductionHeating__c = targetCard.isInductionHeating ;//IHコンロ 
                        saveCond.IsTwoGasStove__c = targetCard.isTwoGasStove ;//コンロ2口 
                        saveCond.IsMoreGasStove__c = targetCard.isMoreGasStove ;//コンロ3口以上 
                        saveCond.IsSepalateBathAndRestroom__c = targetCard.isSepalateBathAndRestroom ;//バス・トイレ別 
                        saveCond.IsAditionalBoiling__c = targetCard.isAditionalBoiling ;//追焚機能 
                        saveCond.IsDehumidifierForBathroom__c = targetCard.isDehumidifierForBathroom ;//浴室乾燥機 
                        saveCond.IsWashlet__c = targetCard.isWashlet ;//温水洗浄便座 
                        saveCond.IsShowerWashBasin__c = targetCard.isShowerWashBasin ;//シャワー付き洗面台 
                        saveCond.IsRegalLavatory__c = targetCard.isRegalLavatory ;//洗面所独立 
                        saveCond.IsInnerLandry__c = targetCard.isInnerLandry ;//室内洗濯機置場 
                        saveCond.IsTownGas__c = targetCard.isTownGas ;//都市ガス 
                        saveCond.IsPropaneGas__c = targetCard.isPropaneGas ;//プロパンガス 
                        saveCond.IsAllElectric__c = targetCard.isAllElectric ;//オール電化 
                        saveCond.IsAirConditioner__c = targetCard.isAirConditioner ;//エアコン 
                        saveCond.IsFloorHeating__c = targetCard.isFloorHeating ;//床暖房 
                        saveCond.IsShoesBox__c = targetCard.isShoesBox ;//シューズボックス 
                        saveCond.IsShoeCloak__c = targetCard.isShoeCloak ;//シューズクローク 
                        saveCond.IsWalkInCloset__c = targetCard.isWalkInCloset ;//ウォークインクローゼット 
                        saveCond.IsTrunkRoom__c = targetCard.isTrunkRoom ;//トランクルーム 
                        saveCond.IsBSAntenna__c = targetCard.isBSAntenna ;//BSアンテナ 
                        saveCond.IsCSAntenna__c = targetCard.isCSAntenna ;//CSアンテナ 
                        saveCond.IsCATV__c = targetCard.isCATV ;//CATV 
                        saveCond.IsInternetFree__c = targetCard.isInternetFree ;//ネット使用料無料 
                        saveCond.IsMonitorIntercom__c = targetCard.isMonitorIntercom ;//モニター付きインターホン 
                        saveCond.IsAutoLock__c = targetCard.isAutoLock ;//オートロック 
                        saveCond.IsFurniture__c = targetCard.isFurniture ;//家具付き 
                        saveCond.IsHomeAppliance__c = targetCard.isHomeAppliance ;//家電付き 
                        saveCond.IsNoGuarantor__c = targetCard.isNoGuarantor ;//保証人不要 
                        saveCond.IsNonGuaranteeidCompany__c = targetCard.isNonGuaranteeidCompany ;//保証会社不要 
                        saveCond.IsMusicalInstruments__c = targetCard.isMusicalInstruments ;//楽器相談可 
                        saveCond.IsForeigner__c = targetCard.isForeigner ;//外国人契約可 
                        saveCond.IsOfficeAvailable__c = targetCard.isOfficeAvailable ;//事務所利用可 
                        saveCond.IsWelfareAvailable__c = targetCard.isWelfareAvailable ;//生活保護契約可 
                        saveCond.IsPet__c = targetCard.isPet ;//ペット可 
                        saveCond.IsLargePet__c = targetCard.isLargePet ;//ペット(大型犬) 
                        saveCond.IsMiddlePet__c = targetCard.isMiddlePet ;//ペット(中型犬) 
                        saveCond.IsSmallPet__c = targetCard.isSmallPet ;//ペット(小型犬) 
                        saveCond.IsCat__c = targetCard.isCat ;//ペット(猫) 
                        saveCond.IsOtherPet__c = targetCard.isOtherPet ;//ペット(その他) 
                        saveCond.IsTwoTenant__c = targetCard.isTwoTenant ;//2人入居可 
                        saveCond.IsRoomShare__c = targetCard.isRoomShare ;//ルームシェア可 
                        saveCond.IsIppambutsu__c = targetCard.isIppambutsu ;//一般物 
                        saveCond.IsElderly__c = targetCard.isElderly ;//高齢者歓迎 
                        saveCond.IsWoman__c = targetCard.isWoman ;//女性限定 
                        saveCond.IsStudent__c = targetCard.isStudent ;//学生限定マンション 

                        saveCondList.add(saveCond); // お客様物件条件登録用リストに追加

                    } else{ 
                        // お客様物件条件が既存の場合はIDをセットする。
                        if(targetCard.dispCondId != null){
                            delCondList.add(new AccountPropertyConditions__c(id=targetCard.dispCondId));
                        }
                    }
                }
            }
            //変更前希望路線削除
            if(!deleteDesiredTrainRoute.isEmpty()){
                SecureDML.secureDelete(deleteDesiredTrainRoute);//希望路線と希望駅を削除
            }
            // 変更前希望学区削除
            if(!deleteDesiredSchoolArea.isEmpty()){
                SecureDML.secureDelete(deleteDesiredSchoolArea);//希望学区と希望学校を削除
            }
            SecureDML.secureUpsert(saveCondTrainRouteMap.values());// 希望路線を作成
            //画面で選択された駅から、新規に希望路線に紐付けた希望駅を作成する
            Integer i = 0;
            for(displayVisitCardCond targetCard: displayVisitCard.displayCondMap.values()){
                if(String.valueOf(targetCard.trainRoute1) != null && !targetCard.deleteFlg && !targetCard.PrerequisiteFlg){
                    for(Station__c desiredStation : targetCard.stations1){//選択された駅1から希望駅を設定
                        saveCondStationList.add(new DesiredStation__c(DesiredTrainRoute__c = saveCondTrainRouteMap.get(targetCard.Name + '1').id, Station__c = desiredStation.Id));
                    }
                    i++;
                }

                if(String.valueOf(targetCard.trainRoute2) != null && !targetCard.deleteFlg && !targetCard.PrerequisiteFlg){
                    for(Station__c desiredStation : targetCard.stations2){//選択された駅2から希望駅を設定
                        saveCondStationList.add(new DesiredStation__c(DesiredTrainRoute__c = saveCondTrainRouteMap.get(targetCard.Name + '2').id, Station__c = desiredStation.Id));
                    }
                    i++;
                }
                
                if(String.valueOf(targetCard.trainRoute3) != null && !targetCard.deleteFlg && !targetCard.PrerequisiteFlg){
                    for(Station__c desiredStation : targetCard.stations3){//選択された駅3から希望駅を設定
                        saveCondStationList.add(new DesiredStation__c(DesiredTrainRoute__c = saveCondTrainRouteMap.get(targetCard.Name + '3').id, Station__c = desiredStation.Id));
                    }
                    i++;
                }
            }
            SecureDML.secureUpsert(saveCondStationList);//お客様物件条件用 希望駅を作成
            SecureDML.secureUpsert(saveCondSchoolAreaMap.values());//お客様物件条件用 希望学区を作成

            //画面で選択された学区から、新規に希望学区に紐付けた希望学校を作成する
            Integer j = 0;
            for(displayVisitCardCond targetCard: displayVisitCard.displayCondMap.values()){
                if(String.valueOf(targetCard.juniorHighSchoolArea) != null && !targetCard.deleteFlg && !targetCard.PrerequisiteFlg){
                    for(School__c desiredSchool : targetCard.juniorHighSchoolList){//選択された中学校から希望学校を設定
                        saveCondSchoolList.add(new DesiredSchool__c(DesiredSchoolArea__c = saveCondSchoolAreaMap.get(targetCard.Name + 'junior').Id, School__c = desiredSchool.Id));
                    }
                    j++;
                }

                if(String.valueOf(targetCard.elementarySchoolArea) != null && !targetCard.deleteFlg && !targetCard.PrerequisiteFlg){
                    for(School__c desiredSchool : targetCard.elementarySchoolList){//選択された小学校から希望学校を設定
                        saveCondSchoolList.add(new DesiredSchool__c(DesiredSchoolArea__c = saveCondSchoolAreaMap.get(targetCard.Name + 'element').Id, School__c = desiredSchool.Id));
                    }
                    j++;
                }
            }
            SecureDML.secureUpsert(saveCondSchoolList);//お客様物件条件用　希望学校を作成
            

            // 希望路線、希望学区をセットする。
            Integer rowIndex = 0;
            for(displayVisitCardCond targetCard: displayVisitCard.displayCondMap.values()){
                if(!targetCard.deleteFlg && !targetCard.PrerequisiteFlg){
                    if(saveCondTrainRouteMap.containsKey(targetCard.Name + '1')){                        
                        saveCondList[rowIndex].DesiredTrainRoute1__c = saveCondTrainRouteMap.get(targetCard.Name + '1').id;//希望路線１
                        targetCard.desiredTrainRoute1 = saveCondList[rowIndex].DesiredTrainRoute1__c;
                        targetCard.AccountPropertyConditionsTrainRoute1 = saveCondList[rowIndex].DesiredTrainRoute1__c;
                    }
                    if(saveCondTrainRouteMap.containsKey(targetCard.Name + '2')){
                        saveCondList[rowIndex].DesiredTrainRoute2__c = saveCondTrainRouteMap.get(targetCard.Name + '2').id;//希望路線２ 
                        targetCard.desiredTrainRoute2 = saveCondList[rowIndex].DesiredTrainRoute2__c;
                        targetCard.AccountPropertyConditionsTrainRoute2 = saveCondList[rowIndex].DesiredTrainRoute2__c;
                    }
                    if(saveCondTrainRouteMap.containsKey(targetCard.Name + '3')){
                        saveCondList[rowIndex].DesiredTrainRoute3__c = saveCondTrainRouteMap.get(targetCard.Name + '3').id;//希望路線３ 
                        targetCard.desiredTrainRoute3 = saveCondList[rowIndex].DesiredTrainRoute3__c;
                        targetCard.AccountPropertyConditionsTrainRoute3 = saveCondList[rowIndex].DesiredTrainRoute3__c;                        
                    }
                    if(String.valueOf(targetCard.juniorHighSchoolArea) != null){
                        saveCondList[rowIndex].DesiredJuniorHighSchoolArea__c = saveCondSchoolAreaMap.get(targetCard.Name + 'junior').Id;//中学校希望学区（エリア）
                        targetCard.AccountPropertyConditionsJuniorHighSchoolArea = saveCondList[rowIndex].DesiredJuniorHighSchoolArea__c;
                    }
                    if(String.valueOf(targetCard.elementarySchoolArea) != null){
                        saveCondList[rowIndex].DesiredElementarySchoolArea__c = saveCondSchoolAreaMap.get(targetCard.Name + 'element').Id;//小学校希望学区（エリア）
                        targetCard.AccountPropertyConditionsElementarySchoolArea = saveCondList[rowIndex].DesiredElementarySchoolArea__c;
                    }
                    rowIndex++;
                }
            }

            // ▲問合せ415で追加
            SecureDML.secureUpsert(saveCondList);//お客様物件条件更新、作成

            // 登録したお客様物件条件のIDをセットする。
            rowIndex = 0;
            for(displayVisitCardCond targetCard: displayVisitCard.displayCondMap.values()){
                if(!targetCard.deleteFlg && !targetCard.PrerequisiteFlg){
                    // お客様物件条件を登録した際のIDをセットし直す。
                    targetCard.dispCondId = saveCondList[rowIndex].id;
                    rowIndex++;
                }
            }
            SecureDML.secureDelete(delCondList);// お客様物件条件　削除
            // ▲2021.10.08 No.307 対応で追加

            //対応作成
            if(!string.isBlank(displayVisitCard.correspondId)){//既存対応あればId設定
                // 対応 更新
                saveCorrespond.Id = displayVisitCard.correspondId;//対応Id
                // スタッフ対応フラグ（ログイン者＝来店担当者はtrue）
                saveCorrespond.StaffSupportedFlg__c = (UserInfo.getUserId() == this.correspond.ShopStaff__c);
            } else {
                // 対応 新規作成
                saveCorrespond.ShopStaff__c	= UserInfo.getUserId();//担当者（来店）
                saveCorrespond.VisitShop__c = CommonUtil.getStaffCurrentShop().Id;//来店担当店舗
            }

            saveCorrespond.AccountId__c = saveAccount.Id;//取引先
            saveCorrespond.Status__c = CommonConst.TASK_CORRESPONDTYPE_VISITED;//ステータス
            saveCorrespond.EventDateTime__c = CommonUtil.getNow();//イベント時刻
            saveCorrespond.IsSupportedListShow__c = FALSE;//対応確認

            saveCorrespond.VisitReason__c = displayVisitCard.visitReason;//来店理由（スタッフ欄）画面．来店理由（スタッフ欄）
            
            //来店日(初回)
            if (this.correspond.VisitDate__c == null) {
                saveCorrespond.VisitDate__c = CommonUtil.getToday();
            }
            SecureDML.secureUpsert(saveCorrespond);
            this.Corresponds = saveCorrespond.Id;
            
            saveCorrespondDetail.SupportedDateTime__c = CommonUtil.getNow();//対応日時
            saveCorrespondDetail.SupportedTitle__c = '来店カード入力';//対応表題
            saveCorrespondDetail.SupportedContent__c = '来店カード入力';//対応内容
            saveCorrespondDetail.Shop__c = CommonUtil.getStaffCurrentShop().Id;//店舗
            saveCorrespondDetail.Staff__c = UserInfo.getUserId();//担当者
            saveCorrespondDetail.Corresponds__c = saveCorrespond.Id;//対応番号
            saveCorrespondDetail.CorrespondType__c	 = CommonConst.TASK_CORRESPONDTYPE_VISITED;//対応種別
            SecureDML.secureUpsert(saveCorrespondDetail);
            // ▼2021.10.08 No.307 対応で削除　変更前希望路線、変更前希望学区
            
            //電子サイン用処理
            this.parentId = saveVisitCard.Id; //親Idを更新
            
            //再登録処理用準備
            displayVisitCard.correspondId = saveCorrespond.Id;//表示対応再設定
            displayVisitCard.correspondSystemModStamp = [SELECT SystemModStamp FROM Correspond__c WHERE Id = :saveCorrespond.Id][0].SystemModStamp;//対応の最終更新日時
            
            displayVisitCard.accountId = saveAccount.Id;//表示取引先再設定
            displayVisitCard.accountSystemModStamp = [SELECT SystemModStamp FROM Account WHERE Id = :saveAccount.Id][0].SystemModStamp;//取引先の最終更新日時
            
            displayVisitCard.visitCardId = saveVisitCard.Id;//表示来店カード再設定
            displayVisitCard.visitCardSystemModStamp = [SELECT SystemModStamp FROM VisitCard__c WHERE Id = :saveVisitCard.Id][0].SystemModStamp;//来店カードの最終更新日時

            // ▼2021.10.08 No.307 対応で削除
            this.isNewAccount   = FALSE; // 新規客フラグ
            this.isNewVisitCard = FALSE; // 新規来店フラグ
            
        }catch(Exception e){
            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }
    
    
    //リモートアクションを用いた、電子サインの添付ファイル保存処理
    @RemoteAction
    global static void saveSignature(String signValue, String parentId, String attachmentId) {
        
        Savepoint sp = Database.setSavepoint();      //セーブポイント作成

        try{

            // 添付ファイル
            Attachment signAttachment = new Attachment();
            
            if (String.isNotBlank(attachmentId)) {  //Idがない場合、更新
                signAttachment.Id = attachmentId;
            } else {                                //Idがある場合、新規
                signAttachment.ParentID = parentId;
            }

            signAttachment.Body = EncodingUtil.base64Decode(signValue.replace('data:image/png;base64,', ''));
            signAttachment.contentType = 'image/png';
            signAttachment.Name = '電子サイン';
            signAttachment.OwnerId = UserInfo.getUserId();

            SecureDML.secureUpsert(signAttachment);

        } catch(Exception e){
            // 異常終了
            Database.rollback(sp);//処理をロールバック
            throw new BusinessLogicException('システムエラーが発生しました。' + e.getMessage());
        }

    }    
    
    
    
    
    //*********************************************************  privateメソッド  ************************************************************
    
    
    
    
    
    //初期化処理
    private void init(){
        this.displayVisitCard = new displayVisitCard();        //表示来店カード初期化
        this.GA102006Parameter = new GA102006ParameterClass ();//郵便番号検索・住所検索モーダル
        this.GA104007Parameter = new GA104007ParameterClass(); //路線図モーダル
        // 問合せ415で追加
        this.GA202002Parameter = new GA202002ParameterClass(); //学区選択モーダル
        this.GH201003Paremeter = new GH201003ParameterClass(); // 店舗・地区選択モーダル
        // ▼ 問合せ588で追加
        this.GH201005Parameter = new GH201005ParameterClass(); // 商圏・地区選択モーダル
        // ▲ 問合せ588で追加

        setSelectOption();//選択リスト設定
        this.today = CommonUtil.getToday();//現在の日付取得
        
        getParamData();  //パラメータ取得と内部クラス設定

        //店舗異動が取得できなければエラー
        CommonUtil.getStaffCurrentShop();

        setSelectCheck();//チェックボックス設定
        // ▼2021.10.08 No.307 対応で変更
        setDisplayCondMapStations(); // 物件条件毎の希望駅をセット
        ageRecalculate();//年齢再計算
        // ▲2021.10.08 No.307 対応で変更
        setDisplayCondMapSchool(); // 物件条件毎の希望学校をセット
    }
    
    
    //パラメータ取得と内部クラス設定
    private void getParamData(){
        
        // パラメータ取得
        if(String.isBlank(this.acc)){
            this.acc = ApexPages.currentPage().getParameters().get('acc');
        }
        if(String.isBlank(this.Corresponds)){
            this.Corresponds = ApexPages.currentPage().getParameters().get('Corresponds');
        }
        if(String.isBlank(this.userId)){
            this.userId = ApexPages.currentPage().getParameters().get('userId');
        }
        //パラメータの担当者ＩＤとログインユーザＩＤが異なる場合エラー
        if(String.isNotBlank(this.userId)){
            if(this.userId != UserInfo.getUserId()){
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_LOGGING_DIFFERENT_USER, UserInfo.getName()));
                throw ex;   
            }
        }
        

        getAccount();    //取引先取得
        getCorrespond(); //対応取得

        // ▼2021.10.08 No.307 対応で追加
        List<AccountPropertyConditions__c> accountPCList = getAccountPropertyConditions(); // お客様物件条件取得
        // ▲2021.10.08 No.307 対応で追加
        
        //isNewAccount設定
        if(this.account != null){//取引先が取得できているかどうか
            isNewAccount = FALSE; 
        }else{
            isNewAccount = TRUE;
            account = new Account();//取引先
        }
        
        //isNewVisitCard設定
        if(this.visitCard != null){//来店カードが取得できているかどうか
            isNewVisitCard  = FALSE; 
        }else{
            isNewVisitCard  = TRUE;
            visitCard = new VisitCard__c();//来店カード
        }
        
        //内部クラス設定
        if(isNewAccount){//新規顧客
            this.displayVisitCard = new displayVisitCard();
        }else if(isNewVisitCard){//既存顧客&新規来店
            // ▼2021.10.08 No.307 対応で変更
            this.displayVisitCard = new displayVisitCard(this.account, accountPCList);
            // ▲2021.10.08 No.307 対応で変更
        }else{//既存顧客＆来店カード作成済み
            // ▼2021.10.08 No.307 対応で変更
            this.displayVisitCard = new displayVisitCard(this.visitCard, this.account, accountPCList);
            // ▲2021.10.08 No.307 対応で変更
        }

        // ▼2021.10.08 No.307 対応で変更
        tmpCondName = displayVisitCard.displayCond.Name;

        // 初期表示のselectCondNameを設定する。
        for(SelectOption val : AccountPropertyConditions){
            if(val.getLabel() == this.displayVisitCard.displayCond.Name){
                selectCondName = val.getValue();
            }
        }
        // ▲2021.10.08 No.307 対応で変更
        
        if(this.Corresponds != null){//パラメータがあれば内部クラスに対応の最終更新日を設定
            this.displayVisitCard.correspondSystemModStamp = this.correspond.SystemModStamp;
            this.displayVisitCard.correspondId = this.correspond.Id;
        }
    }
    
    //取引先設定
    private void getAccount(){
        if(this.acc == null){//パラメータがなければ中断
            return;
        }
        
        List<Account> accountList = [SELECT ID
                                     ,Name
                                     ,SystemModstamp
                                     ,NameKana__c//取引先名（カナ）
                                     ,LastName__c//取引先名 姓
                                     ,LastNameKana__c//取引先名 姓（カナ）
                                     ,FirstName__c//取引先名 名
                                     ,FirstNameKana__c//取引先名 名（カナ）
                                     ,Sex__c//性別 
                                     ,Birthdate__c//生年月日 
                                     ,PostalCode__c//郵便番号 
                                     ,State__c//都道府県 
                                     ,City__c//住所１（市区町村） 
                                     ,Street__c//住所２（番地） 
                                     ,Phone//電話番号 
                                     ,HomePhone__c//自宅TEL
                                     ,Email__c//メール 
                                     ,Affiliation__c//勤務先/学校名
                                     ,JobType__c//職種 
                                     ,AffiliationPostalCode__c//勤務先/学校 郵便番号
                                     ,AffiliationState__c//勤務先/学校 都道府県
                                     ,AffiliationCity__c//勤務先/学校 住所１（市区町村）
                                     ,AffiliationStreet__c//勤務先/学校 住所２（番地）
                                     ,AffiliationPhone__c//勤務先/学校 電話番号
                                     ,VisitsTrigger__c//来店のきっかけ 
                                     ,PortalSite__c//ポータルサイト 
                                     ,SiteView__c//事前にネット
                                     ,Introducer__c//紹介者 
                                     ,HomeMovingReason__c//引越理由 
                                     ,Dissatisfaction__c//不満理由 
                                     ,ContractType__c//契約形態 
                                     ,ProxyCompanyName__c//代理会社名 
                                     ,IsProxyCompany__c//代理会社有無 
                                     ,HomeMovingSeason__c//引越時期 
                                     ,HomeMovingDate__c//引越時期（日付）までに 
                                     ,TenantCount__c//入居人数 
                                     ,DesiredArea__c//希望地域 
                                     ,DesiredTrainRoute1__c//希望沿線１ 
                                     ,DesiredTrainRoute1__r.TrainRoute__c//希望沿線１．路線
                                     ,DesiredTrainRoute1__r.TrainRoute__r.NAME//希望沿線１．路線．路線名
                                     ,DesiredTrainRoute2__c//希望沿線２ 
                                     ,DesiredTrainRoute2__r.TrainRoute__c//希望沿線１．路線
                                     ,DesiredTrainRoute2__r.TrainRoute__r.NAME//希望沿線１．路線．路線名
                                     ,DesiredTrainRoute3__c//希望沿線３ 
                                     ,DesiredTrainRoute3__r.TrainRoute__c//希望沿線１．路線
                                     ,DesiredTrainRoute3__r.TrainRoute__r.NAME//希望沿線１．路線．路線名
                                     ,WalkingTime__c//徒歩 
                                     ,IsOneRoom__c//ワンルーム 
                                     ,Is1K__c//1K 
                                     ,Is1DK__c//1DK 
                                     ,Is1LDK1SLDK__c//1LDK/SLDK 
                                     ,Is2K2DK__c//2K/DK 
                                     ,Is2LDK2SLDK__c//2LDK/SLDK 
                                     ,Is3K3DK__c//3K/DK 
                                     ,Is3LDK3SLDK__c//3LDK/SLDK 
                                     ,Is4K4DK4LDKFrom__c//4K/DK/LDK~ 
                                     ,IsWooden__c//木造 
                                     ,IsLightweightSteel__c//軽量鉄骨 
                                     ,IsSteel__c//鉄骨造 
                                     ,IsRC__c//RC 
                                     ,IsSRC__c//SRC 
                                     ,IsNorth__c//北 
                                     ,IsNorthEast__c//北東 
                                     ,IsEast__c//東 
                                     ,IsSouthEast__c//南東 
                                     ,IsSouth__c//南 
                                     ,IsSouthWest__c//南西 
                                     ,IsWest__c//西 
                                     ,IsNorthWest__c//北西 
                                     ,IsNonDeposit__c//敷金/保証金なし 
                                     ,IsNonKeyMoney__c//礼金なし 
                                     ,IsNonCleaningFee__c//定額修繕費なし 
                                     ,IsNonRenewalFee__c//更新料なし 
                                     ,RentFeeFrom__c//賃料から 
                                     ,RentFeeTo__c//賃料まで 
                                     ,IsIncludeManagementFee__c//管理費込み 
                                     ,IsIncludeParkingFee__c//駐車場代込み 
                                     ,OccupancyAreaLowerLimit__c//占有面積（下限） 
                                     ,OccupancyAreaUpperLimit__c//占有面積（上限） 
                                     ,BuildingAge__c//築年数 
                                     ,CarCount__c//台数 
                                     ,Parking__c//駐車場 
                                     ,ParkingFeeLimit__c//1台当たりの料金上限 
                                     ,IsDetachedHouse__c//戸建て 
                                     ,IsMaisonette__c//メゾネット 
                                     ,IsLoft__c//ロフト 
                                     ,IsDesigners__c//デザイナーズ 
                                     ,IsRenovation__c//リノベーション 
                                     ,IsCondominiumRental__c//分譲賃貸 
                                     ,IsAllWestern__c//オール洋間 
                                     ,IsFirstFloor__c//1階 
                                     ,IsSecondFloorOver__c//2階以上 
                                     ,IsTopFloor__c//最上階 
                                     ,IsCornerRoom__c//角部屋 
                                     ,IsBalcony__c//バルコニー 
                                     ,IsRoofBalcony__c//ルーフバルコニー 
                                     ,IsPrivateGarden__c//専用庭 
                                     ,IsParking__c//駐車場空きあり 
                                     ,IsInSiteParking__c//敷地内駐車場 
                                     ,IsPluralCarParking__c//駐車場2台可 
                                     ,IsBuiltInGarage__c//ビルトインガレージ 
                                     ,IsCarport__c//カーポート 
                                     ,IsBicycleParking__c//駐輪場 
                                     ,IsBikeStorage__c//バイク可 
                                     ,IsSmallBike__c//小型バイク 
                                     ,IsMediumBike__c//中型バイク 
                                     ,IsLargeBike__c//大型バイク 
                                     ,IsElevator__c//エレベーター 
                                     ,IsDeliveryBox__c//宅配ボックス 
                                     ,IsCounterKitchen__c//カウンターキッチン 
                                     ,IsSystemKitchen__c//システムキッチン 
                                     ,IsGasStove__c//ガスコンロ 
                                     ,IsElectricStove__c//電気コンロ 
                                     ,IsInductionHeating__c//IHコンロ 
                                     ,IsTwoGasStove__c//コンロ2口 
                                     ,IsMoreGasStove__c//コンロ3口以上 
                                     ,IsSepalateBathAndRestroom__c//バス・トイレ別 
                                     ,IsAditionalBoiling__c//追焚機能 
                                     ,IsDehumidifierForBathroom__c//浴室乾燥機 
                                     ,IsWashlet__c//温水洗浄便座 
                                     ,IsShowerWashBasin__c//シャワー付き洗面台 
                                     ,IsRegalLavatory__c//洗面所独立 
                                     ,IsInnerLandry__c//室内洗濯機置場 
                                     ,IsTownGas__c//都市ガス 
                                     ,IsPropaneGas__c//プロパンガス 
                                     ,IsAllElectric__c//オール電化 
                                     ,IsAirConditioner__c//エアコン 
                                     ,IsFloorHeating__c//床暖房 
                                     ,IsShoesBox__c//シューズボックス 
                                     ,IsShoeCloak__c//シューズクローク 
                                     ,IsWalkInCloset__c//ウォークインクローゼット 
                                     ,IsTrunkRoom__c//トランクルーム 
                                     ,IsBSAntenna__c//BSアンテナ 
                                     ,IsCSAntenna__c//CSアンテナ 
                                     ,IsCATV__c//CATV 
                                     ,IsInternetFree__c//ネット使用料無料 
                                     ,IsMonitorIntercom__c//モニター付きインターホン 
                                     ,IsAutoLock__c//オートロック 
                                     ,IsFurniture__c//家具付き 
                                     ,IsHomeAppliance__c//家電付き 
                                     ,IsNoGuarantor__c//保証人不要 
                                     ,IsNonGuaranteeidCompany__c//保証会社不要 
                                     ,IsMusicalInstruments__c//楽器相談可 
                                     ,IsForeigner__c//外国人契約可 
                                     ,IsOfficeAvailable__c//事務所利用可 
                                     ,IsWelfareAvailable__c//生活保護契約可 
                                     ,IsPet__c//ペット可 
                                     ,IsLargePet__c//ペット(大型犬) 
                                     ,IsMiddlePet__c//ペット(中型犬) 
                                     ,IsSmallPet__c//ペット(小型犬) 
                                     ,IsCat__c//ペット(猫) 
                                     ,IsOtherPet__c//ペット(その他) 
                                     ,IsTwoTenant__c//2人入居可 
                                     ,IsRoomShare__c//ルームシェア可 
                                     ,IsIppambutsu__c//一般物 
                                     ,IsElderly__c//高齢者歓迎 
                                     ,IsWoman__c//女性限定 
                                     ,IsStudent__c//学生限定マンション 
                                     // ▼問合せ415で追加
                                     ,DesiredJuniorHighSchoolArea__c //中学校希望学区（エリア）
                                     ,DesiredJuniorHighSchoolArea__r.SchoolArea__c // 中学校希望学区（エリア）.希望学区（エリア）
                                     ,DesiredElementarySchoolArea__c //小学校希望学区（エリア）
                                     ,DesiredElementarySchoolArea__r.SchoolArea__c // 小学校希望学区（エリア）.希望学区（エリア）
                                     // ▼2021.10.08 No.307 対応で追加
                                     ,PropertyConditionsName__c // 物件条件名
                                     // ▲2021.10.08 No.307 対応で追加
                                     // ▲問合せ415で追加
                                     ,(
                                         SELECT ID
                                         ,Is1DK__c//1DK
                                         ,Is1K__c//1K
                                         ,Is1LDK1SLDK__c//1LDK/SLDK
                                         ,IsFirstFloor__c//1階
                                         ,ParkingFeeLimit__c//1台当たりの料金上限
                                         ,Is2K2DK__c//2K/DK
                                         ,Is2LDK2SLDK__c//2LDK/SLDK
                                         ,IsSecondFloorOver__c//2階以上
                                         ,IsTwoTenant__c//2人入居可
                                         ,Is3K3DK__c//3K/DK
                                         ,Is3LDK3SLDK__c//3LDK/SLDK
                                         ,Is4K4DK4LDKFrom__c//4K/DK/LDK~
                                         ,IsBSAntenna__c//BSアンテナ
                                         ,IsCATV__c//CATV
                                         ,IsCSAntenna__c//CSアンテナ
                                         ,IsInductionHeating__c//IHコンロ
                                         ,IsRC__c//RC
                                         ,IsSRC__c//SRC
                                         ,IsWalkInCloset__c//ウォークインクローゼット
                                         ,IsAirConditioner__c//エアコン
                                         ,IsElevator__c//エレベーター
                                         ,IsAutoLock__c//オートロック
                                         ,IsAllElectric__c//オール電化
                                         ,IsAllWestern__c//オール洋間
                                         ,IsCarport__c//カーポート
                                         ,IsCounterKitchen__c//カウンターキッチン
                                         ,IsGasStove__c//ガスコンロ
                                         ,IsTwoGasStove__c//コンロ2口
                                         ,IsMoreGasStove__c//コンロ3口以上
                                         ,Introducer__c//紹介者
                                         ,IsSystemKitchen__c//システムキッチン
                                         ,IsShowerWashBasin__c//シャワー付き洗面台
                                         ,IsShoeCloak__c//シューズクローク
                                         ,IsShoesBox__c//シューズボックス
                                         ,IsDesigners__c//デザイナーズ
                                         ,IsTrunkRoom__c//トランクルーム
                                         ,IsInternetFree__c//ネット使用料無料
                                         ,IsBikeStorage__c//バイク可
                                         ,IsSepalateBathAndRestroom__c//バス・トイレ別
                                         ,IsBalcony__c//バルコニー
                                         ,IsBuiltInGarage__c//ビルトインガレージ
                                         ,IsPropaneGas__c//プロパンガス
                                         ,IsOtherPet__c//ペット(その他)
                                         ,IsSmallPet__c//ペット(小型犬)
                                         ,IsLargePet__c//ペット(大型犬)
                                         ,IsMiddlePet__c//ペット(中型犬)
                                         ,IsCat__c//ペット(猫)
                                         ,IsPet__c//ペット可
                                         ,PortalSite__c//ポータルサイト
                                         ,Email__c//メール
                                         ,IsMaisonette__c//メゾネット
                                         ,IsMonitorIntercom__c//モニター付きインターホン
                                         ,IsRenovation__c//リノベーション
                                         ,IsRoofBalcony__c//ルーフバルコニー
                                         ,IsRoomShare__c//ルームシェア可
                                         ,IsLoft__c//ロフト
                                         ,IsOneRoom__c//ワンルーム
                                         ,IsIppambutsu__c//一般物
                                         ,HomeMovingSeason__c//引越時期
                                         ,HomeMovingDate__c//引越時期（日付）までに
                                         ,HomeMovingReason__c//引越理由
                                         ,IsWashlet__c//温水洗浄便座
                                         ,IsFurniture__c//家具付き
                                         ,IsHomeAppliance__c//家電付き
                                         ,IsForeigner__c//外国人契約可
                                         ,IsCornerRoom__c//角部屋
                                         ,IsStudent__c//学生限定マンション
                                         ,IsMusicalInstruments__c//楽器相談可
                                         ,IsIncludeManagementFee__c//管理費込み
                                         ,DesiredTrainRoute1__c//希望沿線１
                                         ,DesiredTrainRoute1__r.TrainRoute__c//希望沿線１．路線
                                         ,DesiredTrainRoute1__r.TrainRoute__r.NAME//希望沿線１．路線．路線名
                                         ,DesiredTrainRoute2__c//希望沿線２
                                         ,DesiredTrainRoute2__r.TrainRoute__c//希望沿線２．路線
                                         ,DesiredTrainRoute2__r.TrainRoute__r.NAME//希望沿線２．路線．路線名
                                         ,DesiredTrainRoute3__c//希望沿線３
                                         ,DesiredTrainRoute3__r.TrainRoute__c//希望沿線３．路線
                                         ,DesiredTrainRoute3__r.TrainRoute__r.NAME//希望沿線３．路線．路線名
                                         ,DesiredArea__c//希望地域
                                         ,Affiliation__c//勤務先/学校
                                         ,AffiliationCity__c//勤務先/学校 住所１（市区町村）
                                         ,AffiliationStreet__c//勤務先/学校 住所２（番地）
                                         ,AffiliationPhone__c//勤務先/学校 電話番号
                                         ,AffiliationState__c//勤務先/学校 都道府県
                                         ,AffiliationPostalCode__c//勤務先/学校 郵便番号
                                         ,ContractType__c//契約形態
                                         ,HomePhone__c//自宅TEL
                                         ,IsLightweightSteel__c//軽量鉄骨
                                         ,IsDetachedHouse__c//戸建て
                                         ,IsNonRenewalFee__c//更新料なし
                                         ,IsElderly__c//高齢者歓迎
                                         ,IsTopFloor__c//最上階
                                         ,IsOfficeAvailable__c//事務所利用可
                                         ,IsInnerLandry__c//室内洗濯機置場
                                         ,City__c//住所１（市区町村）
                                         ,Street__c//住所２（番地）
                                         ,IsWoman__c//女性限定
                                         ,IsSmallBike__c//小型バイク
                                         ,IsFloorHeating__c//床暖房
                                         ,JobType__c//職種
                                         ,VisiterLastName__c//姓
                                         ,VisiterLastNameKana__c//姓（カナ）
                                         ,Sex__c//性別
                                         ,IsWelfareAvailable__c//生活保護契約可
                                         ,Birthdate__c//生年月日
                                         ,IsWest__c//西
                                         ,OccupancyAreaLowerLimit__c//占有面積（下限）
                                         ,OccupancyAreaUpperLimit__c//占有面積（上限）
                                         ,IsPrivateGarden__c//専用庭
                                         ,IsRegalLavatory__c//洗面所独立
                                         ,ProxyCompanyName__c//代理会社名
                                         ,CarCount__c//台数
                                         ,IsLargeBike__c//大型バイク
                                         ,IsDeliveryBox__c//宅配ボックス
                                         ,BuildingAge__c//築年数
                                         ,IsMediumBike__c//中型バイク
                                         ,IsPluralCarParking__c//駐車場2台可
                                         ,IsParking__c//駐車場空きあり
                                         ,IsIncludeParkingFee__c//駐車場代込み
                                         ,IsBicycleParking__c//駐輪場
                                         ,RentFeeFrom__c//賃料から
                                         ,RentFeeTo__c//賃料まで
                                         ,IsAditionalBoiling__c//追焚機能
                                         ,IsNonCleaningFee__c//定額修繕費なし
                                         ,IsSteel__c//鉄骨造
                                         ,IsElectricStove__c//電気コンロ
                                         ,Phone__c//電話番号
                                         ,WalkingTime__c//徒歩
                                         ,IsTownGas__c//都市ガス
                                         ,State__c//都道府県
                                         ,IsEast__c//東
                                         ,IsSouth__c//南
                                         ,IsSouthWest__c//南西
                                         ,IsSouthEast__c//南東
                                         ,TenantCount__c//入居人数
                                         ,Age__c//年齢
                                         ,Dissatisfaction__c//不満理由
                                         ,IsNonDeposit__c//敷金/保証金なし
                                         ,IsInSiteParking__c//敷地内駐車場
                                         ,IsCondominiumRental__c//分譲賃貸
                                         ,IsNonGuaranteeidCompany__c//保証会社不要
                                         ,IsNoGuarantor__c//保証人不要
                                         ,IsNorth__c//北
                                         ,IsNorthWest__c//北西
                                         ,IsNorthEast__c//北東
                                         ,VisiterFirstName__c//名
                                         ,VisiterFirstNameKana__c//名（カナ）
                                         ,IsWooden__c//木造
                                         ,PostalCode__c//郵便番号
                                         ,IsDehumidifierForBathroom__c//浴室乾燥機
                                         ,VisitTrigger__c//来店のきっかけ
                                         ,VisitReason__c//来店理由（スタッフ欄）
                                         ,IsNonKeyMoney__c//礼金なし
                                         ,SystemModstamp//最終更新日時
                                         // ▼問合せ415で追加
                                         ,DesiredJuniorHighSchoolArea__c //中学校希望学区（エリア）
                                         ,DesiredJuniorHighSchoolArea__r.SchoolArea__c // 中学校希望学区（エリア）.希望学区（エリア）
                                         ,DesiredElementarySchoolArea__c //小学校希望学区（エリア）
                                         ,DesiredElementarySchoolArea__r.SchoolArea__c // 小学校希望学区（エリア）.希望学区（エリア）
                                         // ▲問合せ415で追加
                                         FROM VisitsCardAccount__r
                                         ORDER BY SystemModstamp DESC
                                         LIMIT 1
                                     )
                                     FROM Account
                                     WHERE Id = :acc];
        
        //レコード情報が取得できなければビジネスロジックException発行
        if(accountList.isEmpty()) {
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
            throw ex;
        }

        this.account = accountList[0];//取引先を設定
        List<VisitCard__c> v = [SELECT id, Name FROM VisitCard__c];
        if(this.account.VisitsCardAccount__r.size() > 0){//来店カードがあれば設定
            this.visitCard = this.account.VisitsCardAccount__r[0];
        }
    }





    //対応設定
    private void getCorrespond(){
        if(this.Corresponds == null){//パラメータがなければ中断
            return;
        }
        
        List<Correspond__c> correspondList = [SELECT ID
                                              ,ShopStaff__c // 来店担当者
                                              ,Visitdate__c // 来店日
                                              ,SystemModstamp
                                              FROM Correspond__c
                                              WHERE Id = :Corresponds];
        
        //レコード情報が取得できなければビジネスロジックException発行
        if(correspondList.isEmpty()) {
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
            throw ex;
        }
        
        this.correspond = correspondList[0];//対応を設定
    }
    
    //選択リスト設定
    private void setSelectOption(){
        
        sexOption = CommonUtil.getSelectOptionFromObject('VisitCard__c', 'Sex__c');    // 性別
        stateOption = CommonUtil.getSelectOptionFromObject('VisitCard__c', 'State__c');// 都道府県
        visitReasonOption = CommonUtil.getSelectOptionFromObject('VisitCard__c', 'VisitReason__c');// 来店理由
        jobTypeOption = CommonUtil.getSelectOptionFromObject('VisitCard__c', 'JobType__c');// 職種
        walkingTimeOption = CommonUtil.getSelectOptionFromObject('VisitCard__c', 'WalkingTime__c', FALSE);// 駅までの徒歩時間←来店カードの項目名は「徒歩」
        occupancyAreaUpperLimitOption = CommonUtil.getSelectOptionFromObject('VisitCard__c', 'OccupancyAreaUpperLimit__c', FALSE);// 占有面積（上限）
        occupancyAreaLowerLimitOption = CommonUtil.getSelectOptionFromObject('VisitCard__c', 'OccupancyAreaLowerLimit__c', FALSE);// 占有面積（下限）
        buildingAgeOption = CommonUtil.getSelectOptionFromObject('VisitCard__c', 'BuildingAge__c', FALSE);// 築年数

        trainRouteOption = CommonUtil.getSelectOptionFromObjectData('TrainRoute__c','Id','Name','SortOrder__c',TRUE);// 路線
        // ▼2021.10.08 No.307 対応で追加
        // お客様物件条件の選択リスト
        if(String.isBlank(this.acc)){
            String accId = ApexPages.currentPage().getParameters().get('acc');
            // 取引先の物件条件名を取得
            List<Account> accList = [SELECT PropertyConditionsName__c FROM Account WHERE id = :accId LIMIT 1];
            // 作成日が古い順に取得
            List<AccountPropertyConditions__c> apcList = [SELECT id, Name FROM AccountPropertyConditions__c WHERE Account__c =:accId AND IsDeleted__c = FALSE ORDER BY CreatedDate ASC];
            Integer count = 0;
            List<SelectOption> tmpAPC = new List<SelectOption>();
            if(apcList.size() > 0){
                tmpAPC.add(new SelectOption(String.valueOf(count), (String.isBlank(accList[0].PropertyConditionsName__c)? '条件1' : accList[0].PropertyConditionsName__c))); 
            } else {
                tmpAPC.add(new SelectOption(String.valueOf(count), '条件1')); 
            }
            
            count++;
            if(apcList.size() != 0){
                for(AccountPropertyConditions__c apc : apcList){
                    tmpAPC.add(new SelectOption(String.valueOf(count), apc.Name)); 
                    count++;
                }
            }
            AccountPropertyConditions = tmpAPC;
        }
        // ▲2021.10.08 No.307 対応で追加

        // 問合せ415で追加
        List<SelectOption> districtOption = new List<SelectOption>();
        List<SelectOption> beforeProcessList = new List<SelectOption>();
        beforeProcessList = CommonUtil.getSelectOptionFromObject('DesiredSchoolArea__c', 'SchoolArea__c', TRUE);// 問合せ415で追加　学区
        for (SelectOption so : beforeProcessList) {
            if(so.getLabel() != 'その他') {
                districtOption.add(so);
            }
        }
        this.districtOption = districtOption;
    }

    
    //チェックボックス設定
    private void setSelectCheck(){
        
        // ご来店のきっかけ
        this.selectVisitsTriggerList = CommonUtil.getSelectOptionFromObject('VisitCard__c', 'VisitTrigger__c', false);
        // ご来店のきっかけ表示用のList,Map設定
        this.visitsTriggerValueList = new List<String>();
        this.visitsTriggerNameList  = new Map<String, String>();
        this.visitsTriggerCheckList = new Map<String, Boolean>();
        
        for (SelectOption VisitsTrigger : this.selectVisitsTriggerList) {
            String value = VisitsTrigger.getValue();
            String label = VisitsTrigger.getLabel();
            
            
            if (value == '閲覧サイト' || value == 'ご紹介'){//(※)を表示に追加
                label += '(※)';
            }
            
            //リスト設定
            this.visitsTriggerValueList.add(value);
            this.visitsTriggerNameList.put(value,label);
            this.visitsTriggerCheckList.put(value,false);
        }
        
        // 複数選択を別々で切り分ける
        if (this.displayVisitCard.visitTrigger != null){
            list<String> checkvisitsTriggerList = this.displayVisitCard.visitTrigger.Split(';');
            // 切り分けたデータ分チェックをつける
            for(String visitsTrigger : checkvisitsTriggerList){
                if (this.visitsTriggerNameList.containsKey(visitsTrigger)) {//取得した来店カードの選択状態を反映する
                    this.visitsTriggerCheckList.put(visitsTrigger,true);
                }
            } 
        }
        
        // 閲覧サイト
        
        this.selectPortalSiteList  = CommonUtil.getSelectOptionFromObject('VisitCard__c', 'PortalSite__c', false);
        // 閲覧サイト表示用のList,Map設定
        this.portalSiteValueList  = new List<String>();
        this.portalSiteNameList   = new Map<String, String>();
        this.portalSiteCheckList  = new Map<String, Boolean>();
        
        for (SelectOption portalSiteList : this.selectPortalSiteList) {
            String value = portalSiteList.getValue();
            String label = portalSiteList.getLabel();
            
            //リスト設定
            this.portalSiteValueList.add(value);
            this.portalSiteNameList.put(value,label);
            this.portalSiteCheckList.put(value,false);
        }
        
        // 複数選択を別々で切り分ける
        if (this.displayVisitCard.portalSite != null){
            list<String> checkportalSiteList = this.displayVisitCard.portalSite.Split(';');
            // 切り分けたデータ分チェックをつける
            for(String portalSite : checkportalSiteList){
                if (this.portalSiteNameList.containsKey(portalSite)) {//取得した来店カードの選択状態を反映する
                    this.portalSiteCheckList.put(portalSite,true);
                }
            } 
        }
        
        //お引越し理由
        this.selectHomeMovingReasonList  = CommonUtil.getSelectOptionFromObject('VisitCard__c', 'HomeMovingReason__c', false);
        // ご来店のきっかけ表示用のList,Map設定
        this.homeMovingReasonValueList  = new List<String>();
        this.homeMovingReasonNameList   = new Map<String, String>();
        this.homeMovingReasonCheckList  = new Map<String, Boolean>();
        
        for (SelectOption homeMovingReason : this.selectHomeMovingReasonList) {
            String value = homeMovingReason.getValue();
            String label = homeMovingReason.getLabel();
            
            if (value == '現状不満'){//(※)を表示に追加
                label += '(※)';
            }
            
            //リスト設定
            this.homeMovingReasonValueList.add(value);
            this.homeMovingReasonNameList.put(value,label);
            this.homeMovingReasonCheckList.put(value,false);
        }
        
        // 複数選択を別々で切り分ける
        if (this.displayVisitCard.homeMovingReason != null){
            list<String> checkhomeMovingReasonList = this.displayVisitCard.homeMovingReason.Split(';');
            // 切り分けたデータ分チェックをつける
            for(String homeMovingReason : checkhomeMovingReasonList){
                if (this.homeMovingReasonNameList.containsKey(homeMovingReason)) {//取得した来店カードの選択状態を反映する
                    this.homeMovingReasonCheckList.put(homeMovingReason,true);
                }
            } 
        }
        
        //契約形態
        this.selectContractTypeList   = CommonUtil.getSelectOptionFromObject('VisitCard__c', 'ContractType__c', false);
        // ご来店のきっかけ表示用のList,Map設定
        this.contractTypeValueList   = new List<String>();
        this.contractTypeNameList    = new Map<String, String>();
        this.contractTypeCheckList   = new Map<String, Boolean>();
        
        for (SelectOption selectContractType : this.selectContractTypeList) {
            String value = selectContractType.getValue();
            String label = selectContractType.getLabel();
            
            //リスト設定
            this.contractTypeValueList.add(value);
            this.contractTypeNameList.put(value,label);
            this.contractTypeCheckList.put(value,false);
        }
        
        // チェックをつける
        if (this.contractTypeNameList.containsKey(this.displayVisitCard.contractType)) {//取得した来店カードの選択状態を反映する
            this.contractTypeCheckList.put(this.displayVisitCard.contractType,true);
        }
        
        //引越時期
        this.selectHomeMovingSeasonList    = CommonUtil.getSelectOptionFromObject('VisitCard__c', 'HomeMovingSeason__c', false);
        // 引越時期表示用のList,Map設定
        this.homeMovingSeasonValueList    = new List<String>();
        this.homeMovingSeasonNameList     = new Map<String, String>();
        this.homeMovingSeasonCheckList    = new Map<String, Boolean>();
        
        for (SelectOption selectHomeMovingSeason : this.selectHomeMovingSeasonList) {
            String value = selectHomeMovingSeason.getValue();
            String label = selectHomeMovingSeason.getLabel();
            
            //リスト設定
            this.homeMovingSeasonValueList.add(value);
            this.homeMovingSeasonNameList.put(value,label);
            this.homeMovingSeasonCheckList.put(value,false);
        }
        
        // チェックをつける
        if (this.homeMovingSeasonNameList.containsKey(this.displayVisitCard.homeMovingSeason)) {//取得した来店カードの選択状態を反映する
            this.homeMovingSeasonCheckList.put(this.displayVisitCard.homeMovingSeason,true);
        }
        
    }
    
    // ▼2021.10.08 No.307 対応で削除　setStation, selectTrain, setSchool, selectSchool 4つのメソッドを削除


// ▼2021.10.08 No.307 対応
    // 初期表示の際に物件条件の数だけ駅名をセットする。
    private void setDisplayCondMapStations(){

        this.stationMap = selectDisplayCondMapTrain();// 指定した希望路線の情報を取得

        for(String key : displayVisitCard.displayCondMap.keySet()){
            displayVisitCardCond targetCard = displayVisitCard.displayCondMap.get(key);
            targetCard.stations1 = NEW List<Station__c>();//希望駅の初期化
            targetCard.stations2 = NEW List<Station__c>();//希望駅の初期化
            targetCard.stations3 = NEW List<Station__c>();//希望駅の初期化
            targetCard.stationsChar1 = '';
            targetCard.stationsChar2 = '';
            targetCard.stationsChar3 = '';

            if (stationMap.containskey(targetCard.desiredTrainRoute1)) {//希望路線の選択済希望駅をmapで取得
                targetCard.stations1     = stationMap.get(targetCard.desiredTrainRoute1);                  // 駅１
                targetCard.stationsChar1 = convStationListToString(stationMap.get(targetCard.desiredTrainRoute1));
            }
            if (stationMap.containskey(targetCard.desiredTrainRoute2)) {//希望路線の選択済希望駅をmapで取得
                targetCard.stations2     = stationMap.get(targetCard.desiredTrainRoute2);                  // 駅２
                targetCard.stationsChar2 = convStationListToString(stationMap.get(targetCard.desiredTrainRoute2));
            }
            if (stationMap.containskey(targetCard.desiredTrainRoute3)) {//希望路線の選択済希望駅をmapで取得
                targetCard.stations3     = stationMap.get(targetCard.desiredTrainRoute3);                  // 駅３
                targetCard.stationsChar3 = convStationListToString(stationMap.get(targetCard.desiredTrainRoute3));
            }
        }
    }

    // 物件条件の数分の希望路線情報を取得
    private Map<Id, List<Station__c>> selectDisplayCondMapTrain() {
        Set<Id> ids = new Set<Id>();
        Map<Id, List<Station__c>> result = new Map<Id, List<Station__c>>();//map設定
        for(String key : displayVisitCard.displayCondMap.keySet()){
            displayVisitCardCond targetCard = displayVisitCard.displayCondMap.get(key);
            //選択している希望路線のIDをリストにする
            if(targetCard.desiredTrainRoute1 != null){
                ids.add(targetCard.desiredTrainRoute1);
            }

            if(targetCard.DesiredTrainRoute2 != null){
                ids.add(targetCard.desiredTrainRoute2);
            }

            if(targetCard.DesiredTrainRoute3 != null){
                ids.add(targetCard.desiredTrainRoute3);
            }
        }
        //希望路線Idで希望路線と、対応した希望駅を取得して<希望路線,希望駅のリスト>のmapにする
        for (DesiredTrainRoute__c obj : [SELECT Id
            , (SELECT Station__r.Id
                    , Station__r.Name
            FROM  DesiredStationDesiredTrainRoute__r
            )
            FROM DesiredTrainRoute__c
            WHERE Id = :ids
        ]) {
            List<Station__c> stations = new List<Station__c>();
            for (DesiredStation__c child : obj.DesiredStationDesiredTrainRoute__r) {
                stations.add(child.Station__r);
            }
            result.put(obj.Id, stations);
        }
        return result;
    }

    // 初期表示の際に物件条件の数だけ学校情報セット
    private void setDisplayCondMapSchool(){
    
        Map<id, List<school__c>> schoolMap = selectDisplayCondMapSchool();// 指定した希望路線の情報を取得

        for(String key : displayVisitCard.displayCondMap.keySet()){
            displayVisitCardCond targetCard = displayVisitCard.displayCondMap.get(key);
            targetCard.juniorHighSchoolList = new List<School__c>();//希望中学校の初期化
            targetCard.elementarySchoolList = new List<School__c>();//希望小学校の初期化
            targetCard.desiredJuniorHighSchool = '';
            targetCard.desiredPrimarySchool = '';
            
            if (schoolMap.containskey(targetCard.juniorHighSchoolDistrict)) {//希望学区の選択済希望中学校をmapで取得
                targetCard.juniorHighSchoolList     = schoolMap.get(targetCard.juniorHighSchoolDistrict);                  // 中学校
                targetCard.desiredJuniorHighSchool = convSchoolListToString(schoolMap.get(targetCard.juniorHighSchoolDistrict));
            }
            if (schoolMap.containskey(targetCard.elementarySchoolDistrict)) {//希望学区の選択済希望小学校をmapで取得
                targetCard.elementarySchoolList     = schoolMap.get(targetCard.elementarySchoolDistrict);                  // 小学校
                targetCard.desiredPrimarySchool = convSchoolListToString(schoolMap.get(targetCard.elementarySchoolDistrict));
            }
        }
    }

    // 物件条件の数分の希望学校情報を取得
    private Map<id, List<school__c>> selectDisplayCondMapSchool() {
        
        Set<Id> ids = new Set<Id>();
        // 値を返すマップ
        Map<id, List<school__c>> result = new Map<id, List<school__c>>();
        for(String key : displayVisitCard.displayCondMap.keySet()){
            displayVisitCardCond targetCard = displayVisitCard.displayCondMap.get(key);
            //選択している希望学区のIDをリストにする
            if(targetCard.juniorHighSchoolDistrict != null){
                ids.add(targetCard.juniorHighSchoolDistrict);
            }

            if(targetCard.elementarySchoolDistrict != null){
                ids.add(targetCard.elementarySchoolDistrict);
            }
        }
        // 希望学区をもとに希望学校を取得
        List<DesiredSchool__c> desiredScList = new List<DesiredSchool__c>(
            [SELECT id, School__r.id, School__r.NAME, DesiredSchoolArea__c FROM DesiredSchool__c WHERE DesiredSchoolArea__c in :ids]
        );
        
        for (DesiredSchool__c ds: desiredScList) {
            if(!result.containskey(ds.DesiredSchoolArea__c)) {
                List<school__c> resultSchool = new List<school__c>();
                school__c addsc = new school__c(id = ds.School__r.id, NAME = ds.School__r.NAME);
                resultSchool.add(addsc);
                result.put(ds.DesiredSchoolArea__c, resultSchool);
            } else {
                List<school__c> resultSchool = result.get(ds.DesiredSchoolArea__c);
                school__c addsc = new school__c(id = ds.School__r.id, NAME = ds.School__r.NAME);
                resultSchool.add(addsc);
                result.put(ds.DesiredSchoolArea__c, resultSchool);
            }
        }
        return result;
    } 
    // ▲問合せ415で追加
    // ▲2021.10.08 No.307 対応で追加

    // 駅Listから画面表示用の文字列作成
    private String convStationListToString(List<Station__c> objList) {
        List<String> tmp = new List<String>();
        for (Station__c obj : objList) {
            tmp.add(obj.name);
        }
        return String.join(tmp, ';');//「;」区切りの文字列にする
    }

    // ▼問合せ415で追加
    // 学校Listから画面表示用の文字列作成
    private String convSchoolListToString(List<School__c> objList) {
        List<String> tmp = new List<String>();
        for (School__c obj : objList) {
            tmp.add(obj.name);
        }
        return String.join(tmp, ';');//「;」区切りの文字列にする
    }
    // ▲問合せ415で追加
    
    // 名寄せフラグ設定
    private Account setTargetRecordIsMergeCompletedFlag (Account upSertAccount){

        // 取引先の新規作成の場合か、編集時に取引先名（氏名）かメールか電話番号の値が変更されていた場合に、名寄せの確認を行う
        // 2020.09.11 名前比較時の姓と名の間の空白を除去 
        if(isNewAccount
           ||this.displayVisitCard.account.Name != this.displayVisitCard.visiterLastName + this.displayVisitCard.visiterFirstName//名前(姓＋名)
           ||this.displayVisitCard.account.Email__c != this.displayVisitCard.email//メール
           ||this.displayVisitCard.account.Phone != this.displayVisitCard.phone//電話番号
          ){

              //2020.09.03 来店カード情報で取引先の情報が変更された場合、名寄せ不要フラグを初期化する
              upSertAccount.IsMergeUnnecessaryFlag__c = false;

              // 名寄せ確認に数式を使用しているので、確認前に数式の再計算を行う
              upSertAccount.recalculateFormulas();
              
              List<Account> nameMergeList = NameMergeUtil.getCustomerMergeList(upSertAccount, null);// 名寄せ確認
              
              if(nameMergeList.size() == 0){// 名寄せ確認の結果0件なら名寄せ完了
                upSertAccount.IsMergeCompletedFlag__c = true;
              } else {// 名寄せ確認の結果0件でないなら名寄せ未完了
                upSertAccount.IsMergeCompletedFlag__c = false;
                //2020.09.03 名寄せで一致対象とされた取引先の名寄せ不要フラグを更新
                NameMergeUtil.setCustomerMergeUnnecessaryFlag(nameMergeList);
              }
          }
        return upSertAccount;// 名寄せフラグを設定した建物レコードを返す
    }

    // ▼2021.10.08 No.307 対応で追加
    // お客様物件条件を取得
    private List<AccountPropertyConditions__c> getAccountPropertyConditions(){
        List<AccountPropertyConditions__c> accountPCList = [SELECT ID
                                                                    ,Name // お客様物件条件名
                                                                    ,CreatedDate // 作成日時
                                                                    ,IsDeleted__c // 削除
                                                                    ,DesiredArea__c// 希望地域 
                                                                    ,DesiredTrainRoute1__c//希望路線１ 
                                                                    ,DesiredTrainRoute1__r.TrainRoute__c//希望路線１．路線
                                                                    ,DesiredTrainRoute1__r.TrainRoute__r.NAME//希望路線１．路線．路線名
                                                                    ,DesiredTrainRoute2__c//希望路線２ 
                                                                    ,DesiredTrainRoute2__r.TrainRoute__c//希望路線１．路線
                                                                    ,DesiredTrainRoute2__r.TrainRoute__r.NAME//希望路線１．路線．路線名
                                                                    ,DesiredTrainRoute3__c//希望路線３ 
                                                                    ,DesiredTrainRoute3__r.TrainRoute__c//希望路線１．路線
                                                                    ,DesiredTrainRoute3__r.TrainRoute__r.NAME//希望路線１．路線．路線名
                                                                    ,WalkingTime__c//徒歩 
                                                                    ,IsOneRoom__c//ワンルーム 
                                                                    ,Is1K__c//1K 
                                                                    ,Is1DK__c//1DK 
                                                                    ,Is1LDK1SLDK__c//1LDK/SLDK 
                                                                    ,Is2K2DK__c//2K/DK 
                                                                    ,Is2LDK2SLDK__c//2LDK/SLDK 
                                                                    ,Is3K3DK__c//3K/DK 
                                                                    ,Is3LDK3SLDK__c//3LDK/SLDK 
                                                                    ,Is4K4DK4LDKFrom__c//4K/DK/LDK~ 
                                                                    ,IsWooden__c//木造 
                                                                    ,IsLightweightSteel__c//軽量鉄骨 
                                                                    ,IsSteel__c//鉄骨造 
                                                                    ,IsRC__c//RC 
                                                                    ,IsSRC__c//SRC 
                                                                    ,IsNorth__c//北 
                                                                    ,IsNorthEast__c//北東 
                                                                    ,IsEast__c//東 
                                                                    ,IsSouthEast__c//南東 
                                                                    ,IsSouth__c//南 
                                                                    ,IsSouthWest__c//南西 
                                                                    ,IsWest__c//西 
                                                                    ,IsNorthWest__c//北西 
                                                                    ,IsNonDeposit__c//敷金/保証金なし 
                                                                    ,IsNonKeyMoney__c//礼金なし 
                                                                    ,IsNonCleaningFee__c//定額修繕費なし 
                                                                    ,IsNonRenewalFee__c//更新料なし 
                                                                    ,RentFeeFrom__c//賃料から 
                                                                    ,RentFeeTo__c//賃料まで 
                                                                    ,IsIncludeManagementFee__c//管理費込み 
                                                                    ,IsIncludeParkingFee__c//駐車場代込み 
                                                                    ,OccupancyAreaLowerLimit__c//占有面積（下限） 
                                                                    ,OccupancyAreaUpperLimit__c//占有面積（上限） 
                                                                    ,BuildingAge__c//築年数
                                                                    ,IsDetachedHouse__c//戸建て 
                                                                    ,IsMaisonette__c//メゾネット 
                                                                    ,IsLoft__c//ロフト 
                                                                    ,IsDesigners__c//デザイナーズ 
                                                                    ,IsRenovation__c//リノベーション 
                                                                    ,IsCondominiumRental__c//分譲賃貸 
                                                                    ,IsAllWestern__c//オール洋間 
                                                                    ,IsFirstFloor__c//1階 
                                                                    ,IsSecondFloorOver__c//2階以上 
                                                                    ,IsTopFloor__c//最上階 
                                                                    ,IsCornerRoom__c//角部屋 
                                                                    ,IsBalcony__c//バルコニー 
                                                                    ,IsRoofBalcony__c//ルーフバルコニー 
                                                                    ,IsPrivateGarden__c//専用庭 
                                                                    ,IsParking__c//駐車場空きあり 
                                                                    ,IsInSiteParking__c//敷地内駐車場 
                                                                    ,IsPluralCarParking__c//駐車場2台可 
                                                                    ,IsBuiltInGarage__c//ビルトインガレージ 
                                                                    ,IsCarport__c//カーポート 
                                                                    ,IsBicycleParking__c//駐輪場 
                                                                    ,IsBikeStorage__c//バイク可 
                                                                    ,IsSmallBike__c//小型バイク 
                                                                    ,IsMediumBike__c//中型バイク 
                                                                    ,IsLargeBike__c//大型バイク 
                                                                    ,IsElevator__c//エレベーター 
                                                                    ,IsDeliveryBox__c//宅配ボックス 
                                                                    ,IsCounterKitchen__c//カウンターキッチン 
                                                                    ,IsSystemKitchen__c//システムキッチン 
                                                                    ,IsGasStove__c//ガスコンロ 
                                                                    ,IsElectricStove__c//電気コンロ 
                                                                    ,IsInductionHeating__c//IHコンロ 
                                                                    ,IsTwoGasStove__c//コンロ2口 
                                                                    ,IsMoreGasStove__c//コンロ3口以上 
                                                                    ,IsSepalateBathAndRestroom__c//バス・トイレ別 
                                                                    ,IsAditionalBoiling__c//追焚機能 
                                                                    ,IsDehumidifierForBathroom__c//浴室乾燥機 
                                                                    ,IsWashlet__c//温水洗浄便座 
                                                                    ,IsShowerWashBasin__c//シャワー付き洗面台 
                                                                    ,IsRegalLavatory__c//洗面所独立 
                                                                    ,IsInnerLandry__c//室内洗濯機置場 
                                                                    ,IsTownGas__c//都市ガス 
                                                                    ,IsPropaneGas__c//プロパンガス 
                                                                    ,IsAllElectric__c//オール電化 
                                                                    ,IsAirConditioner__c//エアコン 
                                                                    ,IsFloorHeating__c//床暖房 
                                                                    ,IsShoesBox__c//シューズボックス 
                                                                    ,IsShoeCloak__c//シューズクローク 
                                                                    ,IsWalkInCloset__c//ウォークインクローゼット 
                                                                    ,IsTrunkRoom__c//トランクルーム 
                                                                    ,IsBSAntenna__c//BSアンテナ 
                                                                    ,IsCSAntenna__c//CSアンテナ 
                                                                    ,IsCATV__c//CATV 
                                                                    ,IsInternetFree__c//ネット使用料無料 
                                                                    ,IsMonitorIntercom__c//モニター付きインターホン 
                                                                    ,IsAutoLock__c//オートロック 
                                                                    ,IsFurniture__c//家具付き 
                                                                    ,IsHomeAppliance__c//家電付き 
                                                                    ,IsNoGuarantor__c//保証人不要 
                                                                    ,IsNonGuaranteeidCompany__c//保証会社不要 
                                                                    ,IsMusicalInstruments__c//楽器相談可 
                                                                    ,IsForeigner__c//外国人契約可 
                                                                    ,IsOfficeAvailable__c//事務所利用可 
                                                                    ,IsWelfareAvailable__c//生活保護契約可 
                                                                    ,IsPet__c//ペット可 
                                                                    ,IsLargePet__c//ペット(大型犬) 
                                                                    ,IsMiddlePet__c//ペット(中型犬) 
                                                                    ,IsSmallPet__c//ペット(小型犬) 
                                                                    ,IsCat__c//ペット(猫) 
                                                                    ,IsOtherPet__c//ペット(その他) 
                                                                    ,IsTwoTenant__c//2人入居可 
                                                                    ,IsRoomShare__c//ルームシェア可 
                                                                    ,IsIppambutsu__c//一般物 
                                                                    ,IsElderly__c//高齢者歓迎 
                                                                    ,IsWoman__c//女性限定 
                                                                    ,IsStudent__c//学生限定マンション
                                                                    ,CarCount__c//台数
                                                                    ,ParkingFeeLimit__c//1台当たりの料金上限
                                                                    ,Parking__c//駐車場
                                                                    // ▼問合せ415で追加
                                                                    ,DesiredJuniorHighSchoolArea__c //中学校希望学区（エリア）
                                                                    ,DesiredJuniorHighSchoolArea__r.SchoolArea__c // 中学校希望学区（エリア）.希望学区（エリア）
                                                                    ,DesiredElementarySchoolArea__c //小学校希望学区（エリア）
                                                                    ,DesiredElementarySchoolArea__r.SchoolArea__c // 小学校希望学区（エリア）.希望学区（エリア）
                                                            FROM AccountPropertyConditions__c
                                                            WHERE Account__c =:this.acc AND IsDeleted__c = FALSE
                                                            ORDER BY CreatedDate ASC];
        return accountPCList;                                                            
    }

    // 物件条件を切替時の処理
    public void changeConditions(){
        // 入力チェック
        try{
            // 駅・学校・1台あたりの料金の入力チェックを行い、入力に不備があった場合はchatchの処理を行う。
            checkAccountPropertyCond();
            // 物件条件名に入力されている値でdisplayCondMapのキーを置き換える。
            putDispCond(tmpCondName, displayVisitCard);
            // 物件条件名に入力されている値でAccountPropertyConditionsの値を置換える。
            changeSelectOption(AccountPropertyConditions, tmpCondName, displayVisitCard.displayCond.Name);
            // 選択した物件条件をMap置替用変数にセットする。
            tmpCondName = AccountPropertyConditions[Integer.valueOf(selectCondName)].getLabel();
            // 選択した物件条件をdisplayCondにセットする。
            displayVisitCard.displayCond = displayVisitCard.displayCondMap.get(tmpCondName);
            // エラーメッセージをクリアする。
            ApexPages.getMessages().clear();
            
        }catch(Exception e){
            for(SelectOption option : AccountPropertyConditions){
                if(option.getLabel() == tmpCondName){
                    selectCondName = option.getValue();
                }
            }
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }

    }

    // 物件条件追加ボタン押下時の処理
    public void addPropertyCond(){
        try{
            // 駅・学校・1台あたりの料金の入力チェックを行い、入力に不備があった場合はchatchの処理を行う。
            checkAccountPropertyCond();

            // 物件条件名に入力されている値でdisplayCondMapのキーを置き換える。
            putDispCond(tmpCondName, displayVisitCard);

            // 物件条件名に入力されている値でAccountPropertyConditionsの値を置換える。
            changeSelectOption(AccountPropertyConditions, tmpCondName, displayVisitCard.displayCond.Name);

            // 新しい物件条件をセットする。（条件 + displayCondMapサイズ+1）
            Integer propertyNum = displayVisitCard.displayCondMap.size()+1;
            String jouken = '条件';
            String newAddCondMapKey = jouken + propertyNum;

            // displayCondMapにキーが被っていない場合：（条件 + displayCondMapサイズ+1）
            if(!displayVisitCard.displayCondMap.containsKey(newAddCondMapKey)){
                displayVisitCard.displayCondMap.put(newAddCondMapKey, new displayVisitCardCond());
            }else{// displayCondMapにキーが被っている場合：（条件 + displayCondMapサイズ+被らない数値）
                for(Integer i=0; i<displayVisitCard.displayCondMap.size(); i++){
                    propertyNum++;
                    newAddCondMapKey = jouken + propertyNum;
                    if(!displayVisitCard.displayCondMap.containsKey(newAddCondMapKey)){
                        displayVisitCard.displayCondMap.put(newAddCondMapKey, new displayVisitCardCond());
                        break;
                    }
                }
            }
        
            // 表示用displayCondに追加した値,Nameに追加した条件名をセットする。
            displayVisitCard.displayCond = displayVisitCard.displayCondMap.get(newAddCondMapKey);
            displayVisitCard.displayCond.Name = newAddCondMapKey;
            // displayCondMapに追加した値をdisplayCond（表示用）に再度セットする。
            displayVisitCard.displayCondMap.put(newAddCondMapKey, displayVisitCard.displayCond);
            
            //追加した物件条件をMap置替用変数にセットする。
            tmpCondName = newAddCondMapKey;

            // selectOptionに値を追加し、表示用物件条件名に追加した値をセットする。
            AccountPropertyConditions.add(new SelectOption(String.valueOf(AccountPropertyConditions.size()), displayVisitCard.displayCond.Name));
            selectCondName = String.valueOf(AccountPropertyConditions.size()-1);
            // エラーメッセージをクリアする。
            ApexPages.getMessages().clear();

        }catch(Exception e){
            for(SelectOption option : AccountPropertyConditions){
                if(option.getLabel() == tmpCondName){
                    selectCondName = option.getValue();
                }
            }
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }

    // 物件条件削除ボタン押下時の処理
    public void deletePropertyCond(){
        // 保存処理押下時判定用にdeleteFlgをTRUEに変更する。
        displayVisitCard.displayCond.deleteFlg = true;

        // 物件条件名に入力されている値でdisplayCondMapのキーを置き換える。
        putDispCond(tmpCondName, displayVisitCard);

        // 物件条件選択リストの値から削除する。
        AccountPropertyConditions.remove(Integer.valueOf(selectCondName));

        // AccountPropertyConditionsのindexとvalueの値を揃える。
        List<SelectOption> selectAccount = new List<SelectOption>();
        if(AccountPropertyConditions.size() != 0){
            Integer count = 0;
            for(SelectOption sel : AccountPropertyConditions){
                selectAccount.add(new SelectOption(String.valueOf(count), sel.getLabel()));
                count++;
            }
        }
        AccountPropertyConditions = selectAccount;

        // 取引先の物件条件をdisplayVisitCard.displayCondにセットする。
        displayVisitCardCond sortDisplayVisitCard = new displayVisitCardCond();
        String tmpKey;
        for(String key : displayVisitCard.displayCondMap.keySet()){
            if(displayVisitCard.displayCondMap.get(key).PrerequisiteFlg){
                sortDisplayVisitCard = displayVisitCard.displayCondMap.get(key);
                tmpKey = key;
            }
        }
        displayVisitCard.displayCond = sortDisplayVisitCard;

        // Map置き換え用変数に表示用の物件条件名をセットする。
        tmpCondName = displayVisitCard.displayCond.Name;

        // 表示用物件条件名にdisplayVisitCard.displayCondのNameセットする。
        for(SelectOption sel : AccountPropertyConditions){
            if(sel.getLabel() == tmpKey){
                selectCondName = sel.getValue();
            }
        }

    }

    // 駅・学校・1台あたりの料金の入力チェックを行い、入力エラーがあった場合はエクセプションを投げる。
    public void checkAccountPropertyCond(){
        hasErrorMessage = FALSE;
            
        //入力チェック
        BusinessLogicException ex = new BusinessLogicException();
        
        // 料金上限:駐車場「台数」に入力があった場合、未入力であればエラー
        if(String.isnotblank(displayVisitCard.displayCond.carCount)
        && String.isblank(displayVisitCard.displayCond.parkingFeeLimit)){
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED,'1台あたりの料金'));
        }

        //必須入力確認
        List<String> requiredItem = new List<String>();//入力チェックリストを初期化
        
        // 路線名が入力されていて、駅名が入力されていない場合、エラー
        if((String.isNotBlank(displayVisitCard.displayCond.trainRoute1) && String.isblank(displayVisitCard.displayCond.stationsChar1)) ||
            (String.isNotBlank(displayVisitCard.displayCond.trainRoute2) && String.isblank(displayVisitCard.displayCond.stationsChar2)) ||
            (String.isNotBlank(displayVisitCard.displayCond.trainRoute3) && String.isblank(displayVisitCard.displayCond.stationsChar3)) ) {
            requiredItem.add('路線名を選択した場合、駅名');
        }
        // 校区が入力されていて、学校が入力されていない場合、エラー
        if((String.isNotBlank(displayVisitCard.displayCond.juniorHighSchoolArea) && String.isblank(displayVisitCard.displayCond.desiredJuniorHighSchool)) ||
            (String.isNotBlank(displayVisitCard.displayCond.elementarySchoolArea) && String.isblank(displayVisitCard.displayCond.desiredPrimarySchool)) ) {
            requiredItem.add('校区を選択した場合、学校');
        }

        if (!requiredItem.isEmpty()){//入力チェック用リストが空ではない場合、エラー追加                
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ',')));
        }
        //エラーをまとめて投げる
        if (ex.hasMessage()){ 
            throw ex;
        }
    }

    // 物件条件名に入力されている値をdisplayCondMapのキーにセットする。
    public void putDispCond(String tmpCondName, displayVisitCard displayVisitCond){
        displayVisitCond.displayCondMap.remove(tmpCondName);
        displayVisitCond.displayCondMap.put(displayVisitCond.displayCond.Name, displayVisitCond.displayCond);
    }

    // AccountPropertyConditionsの値を物件条件名に入力されている値に置換える。
    public void changeSelectOption(List<SelectOption> AccountPropertyConditions, String tmpCondName, String dispCondName){
        // 物件条件名に入力されている値でAccountPropertyConditionsの値を置換える。
        for(SelectOption sel : AccountPropertyConditions){
            if(sel.getLabel() == tmpCondName){
                AccountPropertyConditions.set(Integer.valueOf(sel.getValue()), new SelectOption(sel.getValue(), dispCondName));
            }
        }
    }

	/**
	 * マップに保持したお客様物件条件と入力で変更したお客様物件条件の置き換えを行う
	 * 同内容のお客様物件条件が登録される事象を防ぐ
	*/
	private void changeMapData(){
		// 保存時に物件条件名の変更が行われた情報を置き換える
		String chengeKey = '';
		for(String key : displayVisitCard.displayCondMap.keySet()){
			displayVisitCardCond targetCard = displayVisitCard.displayCondMap.get(key); // 物件条件を1つずつ取り出したオブジェクト
			// 同IDが存在すればキー情報を保持
			if(displayVisitCard.displayCond.dispCondId == targetCard.dispCondId && targetCard.dispCondId != null ){
				chengeKey = key;
				break;
			}
		}
		// 同IDのデータがあれば元キーを削除し、新たなキーの内容でデータを置き換える
		if(String.isNotBlank(chengeKey)){
			displayVisitCard.displayCondMap.remove(chengeKey);
			displayVisitCard.displayCondMap.put(displayVisitCard.displayCond.Name, displayVisitCard.displayCond); // displayVisitCard.displayCondMapに格納
		}
		
	}
    // ▲2021.10.08 No.307 対応で追加
    
    //***************************************************** 内部クラス *****************************************************************
    
    //来店カードの内部クラス
    public class displayVisitCard{
        
        public VisitCard__c visitCard { get; set; } //レコード本体
        public Account account { get; set; } //レコード本体

        public String correspondId { get; set; } //対応のId
        public String visitCardId { get; set; } //来店カードのId
        public String accountId { get; set; } //取引先のId

        public Datetime correspondSystemModStamp { get; set; } //対応の最終更新日時
        public Datetime visitCardSystemModStamp { get; set; } //来店カードの最終更新日時
        public Datetime accountSystemModStamp { get; set; } //取引先の最終更新日時
        
        public String introducer { get; set; } //紹介者
        public String portalSite { get; set; } //ポータルサイト
        public String email { get; set; } //メール
        public String homeMovingSeason { get; set; } //引越時期
        public Date homeMovingDate { get; set; } //引越時期（日付）までに
        public String homeMovingReason { get; set; } //引越理由
        public String affiliation { get; set; } //勤務先/学校
        public String affiliationCity { get; set; } //勤務先/学校 住所１（市区町村）
        public String affiliationStreet { get; set; } //勤務先/学校 住所２（番地）
        public String affiliationPhone { get; set; } //勤務先/学校 電話番号
        public String affiliationState { get; set; } //勤務先/学校 都道府県
        public String affiliationPostalCode { get; set; } //勤務先/学校 郵便番号
        public String contractType { get; set; } //契約形態
        public String city { get; set; } //住所１（市区町村）
        public String street { get; set; } //住所２（番地）
        public String jobType { get; set; } //職種
        public String visiterLastName { get; set; } //姓
        public String visiterLastNameKana { get; set; } //姓（カナ）
        public String sex { get; set; } //性別
        public Date birthdate { get; set; } //生年月日
        public String proxyCompanyName { get; set; } //代理会社名
        public String phone { get; set; } //電話番号
        public String homePhone { get; set; } //自宅TEL 
        public String state { get; set; } //都道府県
        public String tenantCount { get; set; } //入居人数
        public String age { get; set; } //年齢
        public String dissatisfaction { get; set; } //不満理由
        public String visiterFirstName { get; set; } //名
        public String visiterFirstNameKana { get; set; } //名（カナ）
        public String postalCode { get; set; } //郵便番号
        public String visitTrigger { get; set; } //来店のきっかけ
        public String visitReason { get; set; } //来店理由（スタッフ欄）

        //電子署名
        public String attachmentId {get; set;} //電子署名のId

        // ▼2021.10.08 No.307 対応で削除
        // お客様物件条件に変更

        // ▼2021.10.08 No.307 対応で追加
        public Map<String, displayVisitCardCond> displayCondMap { get; set; } // お客様物件条件
        public displayVisitCardCond displayCond{ get; set; }// 表示用内部クラス(お客様物件条件)
        // ▲2021.10.08 No.307 対応で追加

        //コンストラクタ()
        public displayVisitCard(){
            // ▼2021.10.08 No.307 対応で追加
            // 新規顧客の場合displayCondMapに条件１をセットする。
            Map<String, displayVisitCardCond> displayCondMapTmp = new Map<String, displayVisitCardCond>();
            this.displayCondMap = displayCondMapTmp;
            this.displayCondMap.put('条件1', new displayVisitCardCond());
            this.displayCond = this.displayCondMap.get('条件1');
            this.displayCond.Name = '条件1';
            this.displayCond.PrerequisiteFlg = TRUE; // 取引先物件条件フラグ
            // ▲2021.10.08 No.307 対応で追加
        }
        
        //コンストラクタ(取引先)
        public displayVisitCard(Account inAccount, List<AccountPropertyConditions__c> inAccountPropertyConditionsList){
            this.account   = inAccount;//取引先レコード本体
            this.accountId = inAccount.Id; //取引先の最終更新日時
            this.accountSystemModStamp = inAccount.SystemModStamp; //取引先の最終更新日時
            this.visiterLastName = inAccount.LastName__c;//取引先名 姓	 
            this.visiterLastNameKana = inAccount.LastNameKana__c;//取引先名 姓（カナ）
            this.visiterFirstName = inAccount.FirstName__c;//取引先名 
            this.visiterFirstNameKana = inAccount.FirstNameKana__c;//取引先名 姓（カナ）	 
            this.sex = inAccount.Sex__c;//性別 
            this.birthdate = inAccount.Birthdate__c;//生年月日 
            this.postalCode = inAccount.PostalCode__c;//郵便番号 
            this.state = inAccount.State__c;//都道府県 
            this.city = inAccount.City__c;//住所１（市区町村） 
            this.street = inAccount.Street__c;//住所２（番地） 
            this.phone = inAccount.Phone;//電話番号 
            this.homePhone = inAccount.HomePhone__c;//自宅TEL
            this.email = inAccount.Email__c;//メール 
            this.affiliation = inAccount.Affiliation__c;//勤務先/学校名
            this.jobType = inAccount.JobType__c;//職種 
            this.affiliationPostalCode = inAccount.AffiliationPostalCode__c;//勤務先/学校 郵便番号
            this.affiliationState = inAccount.AffiliationState__c;//勤務先/学校 都道府県
            this.affiliationCity = inAccount.AffiliationCity__c;//勤務先/学校 住所１（市区町村）
            this.affiliationStreet = inAccount.AffiliationStreet__c;//勤務先/学校 住所２（番地）
            this.affiliationPhone = inAccount.AffiliationPhone__c;//勤務先/学校 電話番号
            this.visitTrigger = inAccount.VisitsTrigger__c;//来店のきっかけ 
            this.portalSite = inAccount.PortalSite__c;//ポータルサイト 
            this.introducer = inAccount.Introducer__c;//紹介者 
            this.homeMovingReason = inAccount.HomeMovingReason__c;//引越理由 
            this.dissatisfaction = inAccount.Dissatisfaction__c;//不満理由 
            this.contractType = inAccount.ContractType__c;//契約形態 
            this.proxyCompanyName = inAccount.ProxyCompanyName__c;//代理会社名 
            this.homeMovingSeason = inAccount.HomeMovingSeason__c;//引越時期 
            this.homeMovingDate = inAccount.HomeMovingDate__c;//引越時期（日付）までに 
            this.tenantCount = CommonUtil.decimalToString(inAccount.TenantCount__c);//入居人数 
            
            // ▼2021.10.08 No.307 対応で削除
            // お客様物件条件に変更
            this.displayCond = new displayVisitCardCond();
            this.displayCond.PrerequisiteFlg = TRUE; // 取引先物件条件フラグ
            this.displayCond.deleteFlg = false; // 削除判定フラグ
            this.displayCond.Name = (String.isBlank(inAccount.PropertyConditionsName__c)? '条件1' : inAccount.PropertyConditionsName__c);// 物件条件名
            this.displayCond.desiredArea = inAccount.DesiredArea__c;//希望地域 
            this.displayCond.desiredTrainRoute1 = inAccount.DesiredTrainRoute1__c;//希望路線１
            this.displayCond.trainRoute1 = inAccount.DesiredTrainRoute1__r.TrainRoute__c;//希望路線１．路線
            this.displayCond.trainRoute1Name = inAccount.DesiredTrainRoute1__r.TrainRoute__r.NAME;//希望路線１．路線．路線名
            this.displayCond.desiredTrainRoute2 = inAccount.DesiredTrainRoute2__c;//希望路線２
            this.displayCond.trainRoute2 = inAccount.DesiredTrainRoute2__r.TrainRoute__c;//希望路線２．路線
            this.displayCond.trainRoute2Name = inAccount.DesiredTrainRoute2__r.TrainRoute__r.NAME;//希望路線２．路線．路線名
            this.displayCond.desiredTrainRoute3 = inAccount.DesiredTrainRoute3__c;//希望路線３
            this.displayCond.trainRoute3 = inAccount.DesiredTrainRoute3__r.TrainRoute__c;//希望路線３．路線
            this.displayCond.trainRoute3Name = inAccount.DesiredTrainRoute3__r.TrainRoute__r.NAME;//希望路線３．路線．路線名
            // ▼問合せ415で追加
            this.displayCond.juniorHighSchoolDistrict = inAccount.DesiredJuniorHighSchoolArea__c;// 中学校希望学区（エリア）
            this.displayCond.elementarySchoolDistrict = inAccount.DesiredElementarySchoolArea__c;// 小学校希望学区（エリア）
            this.displayCond.juniorHighSchoolArea = inAccount.DesiredJuniorHighSchoolArea__r.SchoolArea__c;// 中学校希望学区（エリア）.希望学区
            this.displayCond.elementarySchoolArea = inAccount.DesiredElementarySchoolArea__r.SchoolArea__c;// 小学校希望学区（エリア）.希望学区
            
            //更新時に削除する希望路線Id
            // ▼2021.10.08 No.307 対応で追加
            this.displayCond.accountDesiredTrainRoute1 = inAccount.DesiredTrainRoute1__c;//希望路線1
            this.displayCond.accountDesiredTrainRoute2 = inAccount.DesiredTrainRoute2__c;//希望路線2
            this.displayCond.accountDesiredTrainRoute3 = inAccount.DesiredTrainRoute3__c;//希望路線3
            this.displayCond.accountDesiredElementarySchoolArea = inAccount.DesiredJuniorHighSchoolArea__c; //中学校希望学区
            this.displayCond.accountDesiredJuniorHighSchoolArea = inAccount.DesiredElementarySchoolArea__c; //小学校希望学区
            
            this.displayCond.walkingTime = inAccount.WalkingTime__c;//徒歩 
            this.displayCond.isOneRoom = inAccount.IsOneRoom__c;//ワンルーム 
            this.displayCond.is1K = inAccount.Is1K__c;//1K 
            this.displayCond.is1DK = inAccount.Is1DK__c;//1DK 
            this.displayCond.is1LDK1SLDK = inAccount.Is1LDK1SLDK__c;//1LDK/SLDK 
            this.displayCond.is2K2DK = inAccount.Is2K2DK__c;//2K/DK 
            this.displayCond.is2LDK2SLDK = inAccount.Is2LDK2SLDK__c;//2LDK/SLDK 
            this.displayCond.is3K3DK = inAccount.Is3K3DK__c;//3K/DK 
            this.displayCond.is3LDK3SLDK = inAccount.Is3LDK3SLDK__c;//3LDK/SLDK 
            this.displayCond.is4K4DK4LDKFrom = inAccount.Is4K4DK4LDKFrom__c;//4K/DK/LDK~ 
            this.displayCond.isWooden = inAccount.IsWooden__c;//木造 
            this.displayCond.isLightweightSteel = inAccount.IsLightweightSteel__c;//軽量鉄骨 
            this.displayCond.isSteel = inAccount.IsSteel__c;//鉄骨造 
            this.displayCond.isRC = inAccount.IsRC__c;//RC 
            this.displayCond.isSRC = inAccount.IsSRC__c;//SRC 
            this.displayCond.isNorth = inAccount.IsNorth__c;//北 
            this.displayCond.isNorthEast = inAccount.IsNorthEast__c;//北東 
            this.displayCond.isEast = inAccount.IsEast__c;//東 
            this.displayCond.isSouthEast = inAccount.IsSouthEast__c;//南東 
            this.displayCond.isSouth = inAccount.IsSouth__c;//南 
            this.displayCond.isSouthWest = inAccount.IsSouthWest__c;//南西 
            this.displayCond.isWest = inAccount.IsWest__c;//西 
            this.displayCond.isNorthWest = inAccount.IsNorthWest__c;//北西 
            this.displayCond.isNonDeposit = inAccount.IsNonDeposit__c;//敷金/保証金なし 
            this.displayCond.isNonKeyMoney = inAccount.IsNonKeyMoney__c;//礼金なし 
            this.displayCond.isNonCleaningFee = inAccount.IsNonCleaningFee__c;//定額修繕費なし 
            this.displayCond.isNonRenewalFee = inAccount.IsNonRenewalFee__c;//更新料なし 
            this.displayCond.rentFeeFrom = CommonUtil.decimalToString(inAccount.RentFeeFrom__c);//賃料から 
            this.displayCond.rentFeeTo = CommonUtil.decimalToString(inAccount.RentFeeTo__c);//賃料まで 
            this.displayCond.isIncludeManagementFee = inAccount.IsIncludeManagementFee__c;//管理費込み 
            this.displayCond.isIncludeParkingFee = inAccount.IsIncludeParkingFee__c;//駐車場代込み 
            this.displayCond.occupancyAreaLowerLimit = inAccount.OccupancyAreaLowerLimit__c;//占有面積（下限） 
            this.displayCond.occupancyAreaUpperLimit = inAccount.OccupancyAreaUpperLimit__c;//占有面積（上限） 
            this.displayCond.buildingAge = inAccount.BuildingAge__c;//築年数 
            this.displayCond.isDetachedHouse = inAccount.IsDetachedHouse__c;//戸建て 
            this.displayCond.isMaisonette = inAccount.IsMaisonette__c;//メゾネット 
            this.displayCond.isLoft = inAccount.IsLoft__c;//ロフト 
            this.displayCond.isDesigners = inAccount.IsDesigners__c;//デザイナーズ 
            this.displayCond.isRenovation = inAccount.IsRenovation__c;//リノベーション 
            this.displayCond.isCondominiumRental = inAccount.IsCondominiumRental__c;//分譲賃貸 
            this.displayCond.isAllWestern = inAccount.IsAllWestern__c;//オール洋間 
            this.displayCond.isFirstFloor = inAccount.IsFirstFloor__c;//1階 
            this.displayCond.isSecondFloorOver = inAccount.IsSecondFloorOver__c;//2階以上 
            this.displayCond.isTopFloor = inAccount.IsTopFloor__c;//最上階 
            this.displayCond.isCornerRoom = inAccount.IsCornerRoom__c;//角部屋 
            this.displayCond.isBalcony = inAccount.IsBalcony__c;//バルコニー 
            this.displayCond.isRoofBalcony = inAccount.IsRoofBalcony__c;//ルーフバルコニー 
            this.displayCond.isPrivateGarden = inAccount.IsPrivateGarden__c;//専用庭 
            this.displayCond.isParking = inAccount.IsParking__c;//駐車場空きあり 
            this.displayCond.isInSiteParking = inAccount.IsInSiteParking__c;//敷地内駐車場 
            this.displayCond.isPluralCarParking = inAccount.IsPluralCarParking__c;//駐車場2台可 
            this.displayCond.isBuiltInGarage = inAccount.IsBuiltInGarage__c;//ビルトインガレージ 
            this.displayCond.isCarport = inAccount.IsCarport__c;//カーポート 
            this.displayCond.isBicycleParking = inAccount.IsBicycleParking__c;//駐輪場 
            this.displayCond.isBikeStorage = inAccount.IsBikeStorage__c;//バイク可 
            this.displayCond.isSmallBike = inAccount.IsSmallBike__c;//小型バイク 
            this.displayCond.isMediumBike = inAccount.IsMediumBike__c;//中型バイク 
            this.displayCond.isLargeBike = inAccount.IsLargeBike__c;//大型バイク 
            this.displayCond.isElevator = inAccount.IsElevator__c;//エレベーター 
            this.displayCond.isDeliveryBox = inAccount.IsDeliveryBox__c;//宅配ボックス 
            this.displayCond.isCounterKitchen = inAccount.IsCounterKitchen__c;//カウンターキッチン 
            this.displayCond.isSystemKitchen = inAccount.IsSystemKitchen__c;//システムキッチン 
            this.displayCond.isGasStove = inAccount.IsGasStove__c;//ガスコンロ 
            this.displayCond.isElectricStove = inAccount.IsElectricStove__c;//電気コンロ 
            this.displayCond.isInductionHeating = inAccount.IsInductionHeating__c;//IHコンロ 
            this.displayCond.isTwoGasStove = inAccount.IsTwoGasStove__c;//コンロ2口 
            this.displayCond.isMoreGasStove = inAccount.IsMoreGasStove__c;//コンロ3口以上 
            this.displayCond.isSepalateBathAndRestroom = inAccount.IsSepalateBathAndRestroom__c;//バス・トイレ別 
            this.displayCond.isAditionalBoiling = inAccount.IsAditionalBoiling__c;//追焚機能 
            this.displayCond.isDehumidifierForBathroom = inAccount.IsDehumidifierForBathroom__c;//浴室乾燥機 
            this.displayCond.isWashlet = inAccount.IsWashlet__c;//温水洗浄便座 
            this.displayCond.isShowerWashBasin = inAccount.IsShowerWashBasin__c;//シャワー付き洗面台 
            this.displayCond.isRegalLavatory = inAccount.IsRegalLavatory__c;//洗面所独立 
            this.displayCond.isInnerLandry = inAccount.IsInnerLandry__c;//室内洗濯機置場 
            this.displayCond.isTownGas = inAccount.IsTownGas__c;//都市ガス 
            this.displayCond.isPropaneGas = inAccount.IsPropaneGas__c;//プロパンガス 
            this.displayCond.isAllElectric = inAccount.IsAllElectric__c;//オール電化 
            this.displayCond.isAirConditioner = inAccount.IsAirConditioner__c;//エアコン 
            this.displayCond.isFloorHeating = inAccount.IsFloorHeating__c;//床暖房 
            this.displayCond.isShoesBox = inAccount.IsShoesBox__c;//シューズボックス 
            this.displayCond.isShoeCloak = inAccount.IsShoeCloak__c;//シューズクローク 
            this.displayCond.isWalkInCloset = inAccount.IsWalkInCloset__c;//ウォークインクローゼット 
            this.displayCond.isTrunkRoom = inAccount.IsTrunkRoom__c;//トランクルーム 
            this.displayCond.isBSAntenna = inAccount.IsBSAntenna__c;//BSアンテナ 
            this.displayCond.isCSAntenna = inAccount.IsCSAntenna__c;//CSアンテナ 
            this.displayCond.isCATV = inAccount.IsCATV__c;//CATV 
            this.displayCond.isInternetFree = inAccount.IsInternetFree__c;//ネット使用料無料 
            this.displayCond.isMonitorIntercom = inAccount.IsMonitorIntercom__c;//モニター付きインターホン 
            this.displayCond.isAutoLock = inAccount.IsAutoLock__c;//オートロック 
            this.displayCond.isFurniture = inAccount.IsFurniture__c;//家具付き 
            this.displayCond.isHomeAppliance = inAccount.IsHomeAppliance__c;//家電付き 
            this.displayCond.isNoGuarantor = inAccount.IsNoGuarantor__c;//保証人不要 
            this.displayCond.isNonGuaranteeidCompany = inAccount.IsNonGuaranteeidCompany__c;//保証会社不要 
            this.displayCond.isMusicalInstruments = inAccount.IsMusicalInstruments__c;//楽器相談可 
            this.displayCond.isForeigner = inAccount.IsForeigner__c;//外国人契約可 
            this.displayCond.isOfficeAvailable = inAccount.IsOfficeAvailable__c;//事務所利用可 
            this.displayCond.isWelfareAvailable = inAccount.IsWelfareAvailable__c;//生活保護契約可 
            this.displayCond.isPet = inAccount.IsPet__c;//ペット可 
            this.displayCond.isLargePet = inAccount.IsLargePet__c;//ペット(大型犬) 
            this.displayCond.isMiddlePet = inAccount.IsMiddlePet__c;//ペット(中型犬) 
            this.displayCond.isSmallPet = inAccount.IsSmallPet__c;//ペット(小型犬) 
            this.displayCond.isCat = inAccount.IsCat__c;//ペット(猫) 
            this.displayCond.isOtherPet = inAccount.IsOtherPet__c;//ペット(その他) 
            this.displayCond.isTwoTenant = inAccount.IsTwoTenant__c;//2人入居可 
            this.displayCond.isRoomShare = inAccount.IsRoomShare__c;//ルームシェア可 
            this.displayCond.isIppambutsu = inAccount.IsIppambutsu__c;//一般物 
            this.displayCond.isElderly = inAccount.IsElderly__c;//高齢者歓迎 
            this.displayCond.isWoman = inAccount.IsWoman__c;//女性限定 
            this.displayCond.isStudent = inAccount.IsStudent__c;//学生限定マンション

            this.displayCond.carCount = CommonUtil.decimalToString(inAccount.CarCount__c);//台数
            this.displayCond.parkingFeeLimit = CommonUtil.decimalToString(inAccount.ParkingFeeLimit__c); //1台当たりの料金上限

            // 取引先の物件条件を設定した物をマップに格納する。
            Map<String, displayVisitCardCond> displayCondMapTmp = new Map<String, displayVisitCardCond>();
            displayCondMapTmp.put(this.displayCond.Name, this.displayCond);

            if(inAccountPropertyConditionsList.size() > 0){
              for(AccountPropertyConditions__c apc : inAccountPropertyConditionsList){
                    displayCondMapTmp.put(apc.Name, new displayVisitCardCond(apc));
                }
            }
            this.displayCondMap = displayCondMapTmp;
        }
        
        //コンストラクタ(来店カード)
        public displayVisitCard(VisitCard__c inVisitCard, Account inAccount, List<AccountPropertyConditions__c> inAccountPropertyConditionsList){
            
            this.visitCard = inVisitCard;//来店カードレコード
            this.account = inAccount;//取引先レコード本体

            this.visitCardSystemModStamp = inVisitCard.SystemModStamp; //来店カードの最終更新日時
            this.accountSystemModStamp = inAccount.SystemModStamp; //取引先の最終更新日時
            this.visitCardId = inVisitCard.Id; //来店カードの最終更新日時
            this.accountId = inAccount.Id; //取引先の最終更新日時
            
            this.introducer = inVisitCard.Introducer__c;//紹介者

            this.portalSite = inVisitCard.PortalSite__c;//ポータルサイト
            this.email = inVisitCard.Email__c;//メール
            this.homeMovingSeason = inVisitCard.HomeMovingSeason__c;//引越時期
            this.homeMovingDate = inVisitCard.HomeMovingDate__c;//引越時期（日付）までに
            this.homeMovingReason = inVisitCard.HomeMovingReason__c;//引越理由

            this.affiliation = inVisitCard.Affiliation__c;//勤務先/学校
            this.affiliationCity = inVisitCard.AffiliationCity__c;//勤務先/学校 住所１（市区町村）
            this.affiliationStreet = inVisitCard.AffiliationStreet__c;//勤務先/学校 住所２（番地）
            this.affiliationPhone = inVisitCard.AffiliationPhone__c;//勤務先/学校 電話番号
            this.affiliationState = inVisitCard.AffiliationState__c;//勤務先/学校 都道府県
            this.affiliationPostalCode = inVisitCard.AffiliationPostalCode__c;//勤務先/学校 郵便番号
            this.contractType = inVisitCard.ContractType__c;//契約形態
            this.homePhone = inVisitCard.HomePhone__c;//自宅TEL
            this.city = inVisitCard.City__c;//住所１（市区町村）
            this.street = inVisitCard.Street__c;//住所２（番地）
            this.jobType = inVisitCard.JobType__c;//職種
            this.visiterLastName = inVisitCard.VisiterLastName__c;//姓
            this.visiterLastNameKana = inVisitCard.VisiterLastNameKana__c;//姓（カナ）
            this.sex = inVisitCard.Sex__c;//性別
            this.birthdate = inVisitCard.Birthdate__c;//生年月日
            this.proxyCompanyName = inVisitCard.ProxyCompanyName__c;//代理会社名
            
            this.phone = inVisitCard.Phone__c;//電話番号
            this.state = inVisitCard.State__c;//都道府県
            this.tenantCount = CommonUtil.decimalToString(inVisitCard.TenantCount__c);//入居人数
            this.age = CommonUtil.decimalToString(inVisitCard.Age__c);//年齢
            this.dissatisfaction = inVisitCard.Dissatisfaction__c;//不満理由
            this.visiterFirstName = inVisitCard.VisiterFirstName__c;//名
            this.visiterFirstNameKana = inVisitCard.VisiterFirstNameKana__c;//名（カナ）
            this.postalCode = inVisitCard.PostalCode__c;//郵便番号
            this.visitTrigger = inVisitCard.VisitTrigger__c;//来店のきっかけ

            // ▼2021.10.08 No.307 対応で削除
            // お客様物件条件に変更

            //署名項目設定
            List<Attachment> attachmentList = [SELECT id FROM Attachment WHERE Name = '電子サイン' AND parentId = :inVisitCard.Id LIMIT 1];
            if ( !attachmentList.isEmpty()) {
                this.attachmentId = attachmentList[0].Id;
            }

            // ▼2021.10.08 No.307 対応で追加
            this.displayCond = new displayVisitCardCond();
            this.displayCond.PrerequisiteFlg = TRUE; // 取引先物件条件フラグ
            this.displayCond.deleteFlg = false; // 削除判定フラグ
            this.displayCond.Name = (String.isBlank(inAccount.PropertyConditionsName__c)? '条件1' : inAccount.PropertyConditionsName__c);// 物件条件名
            this.displayCond.desiredArea = inVisitCard.DesiredArea__c;//希望地域 
            this.displayCond.desiredTrainRoute1 = inVisitCard.DesiredTrainRoute1__c;//希望路線１
            this.displayCond.trainRoute1 = inVisitCard.DesiredTrainRoute1__r.TrainRoute__c;//希望路線１．路線
            this.displayCond.trainRoute1Name = inVisitCard.DesiredTrainRoute1__r.TrainRoute__r.NAME;//希望路線１．路線．路線名
            this.displayCond.desiredTrainRoute2 = inVisitCard.DesiredTrainRoute2__c;//希望路線２
            this.displayCond.trainRoute2 = inVisitCard.DesiredTrainRoute2__r.TrainRoute__c;//希望路線２．路線
            this.displayCond.trainRoute2Name = inVisitCard.DesiredTrainRoute2__r.TrainRoute__r.NAME;//希望路線２．路線．路線名
            this.displayCond.desiredTrainRoute3 = inVisitCard.DesiredTrainRoute3__c;//希望路線３
            this.displayCond.trainRoute3 = inVisitCard.DesiredTrainRoute3__r.TrainRoute__c;//希望路線３．路線
            this.displayCond.trainRoute3Name = inVisitCard.DesiredTrainRoute3__r.TrainRoute__r.NAME;//希望路線３．路線．路線名
            // ▼問合せ415で追加
            this.displayCond.juniorHighSchoolDistrict = inVisitCard.DesiredJuniorHighSchoolArea__c;// 中学校希望学区（エリア）
            this.displayCond.elementarySchoolDistrict = inVisitCard.DesiredElementarySchoolArea__c;// 小学校希望学区（エリア）
            this.displayCond.juniorHighSchoolArea = inVisitCard.DesiredJuniorHighSchoolArea__r.SchoolArea__c;// 中学校希望学区（エリア）.希望学区
            this.displayCond.elementarySchoolArea = inVisitCard.DesiredElementarySchoolArea__r.SchoolArea__c;// 小学校希望学区（エリア）.希望学区
            //更新時に削除する希望路線Id

            // ▼2021.10.08 No.307 対応で削除　取引先希望路線・希望学区
            // ▼2021.10.08 No.307 対応で追加
            this.displayCond.accountDesiredTrainRoute1 = inAccount.DesiredTrainRoute1__c;//希望路線1　取引先
            this.displayCond.accountDesiredTrainRoute2 = inAccount.DesiredTrainRoute2__c;//希望路線2　取引先
            this.displayCond.accountDesiredTrainRoute3 = inAccount.DesiredTrainRoute3__c;//希望路線3　取引先
            this.displayCond.accountDesiredElementarySchoolArea = inAccount.DesiredJuniorHighSchoolArea__c; //中学校希望学区　取引先
            this.displayCond.accountDesiredJuniorHighSchoolArea = inAccount.DesiredElementarySchoolArea__c; //小学校希望学区　取引先

            this.displayCond.visitCardDesiredTrainRoute1 = inVisitCard.DesiredTrainRoute1__c;//希望路線1　来店カード
            this.displayCond.visitCardDesiredTrainRoute2 = inVisitCard.DesiredTrainRoute2__c;//希望路線2　来店カード
            this.displayCond.visitCardDesiredTrainRoute3 = inVisitCard.DesiredTrainRoute3__c;//希望路線3　来店カード
            this.displayCond.visitCardDesiredElementarySchoolArea = inVisitCard.DesiredJuniorHighSchoolArea__c; //中学校希望学区　来店カード
            this.displayCond.visitCardDesiredJuniorHighSchoolArea = inVisitCard.DesiredElementarySchoolArea__c; //小学校希望学区　来店カード
            
            this.displayCond.walkingTime = inVisitCard.WalkingTime__c;//徒歩 
            this.displayCond.isOneRoom = inVisitCard.IsOneRoom__c;//ワンルーム 
            this.displayCond.is1K = inVisitCard.Is1K__c;//1K 
            this.displayCond.is1DK = inVisitCard.Is1DK__c;//1DK 
            this.displayCond.is1LDK1SLDK = inVisitCard.Is1LDK1SLDK__c;//1LDK/SLDK 
            this.displayCond.is2K2DK = inVisitCard.Is2K2DK__c;//2K/DK 
            this.displayCond.is2LDK2SLDK = inVisitCard.Is2LDK2SLDK__c;//2LDK/SLDK 
            this.displayCond.is3K3DK = inVisitCard.Is3K3DK__c;//3K/DK 
            this.displayCond.is3LDK3SLDK = inVisitCard.Is3LDK3SLDK__c;//3LDK/SLDK 
            this.displayCond.is4K4DK4LDKFrom = inVisitCard.Is4K4DK4LDKFrom__c;//4K/DK/LDK~ 
            this.displayCond.isWooden = inVisitCard.IsWooden__c;//木造 
            this.displayCond.isLightweightSteel = inVisitCard.IsLightweightSteel__c;//軽量鉄骨 
            this.displayCond.isSteel = inVisitCard.IsSteel__c;//鉄骨造 
            this.displayCond.isRC = inVisitCard.IsRC__c;//RC 
            this.displayCond.isSRC = inVisitCard.IsSRC__c;//SRC 
            this.displayCond.isNorth = inVisitCard.IsNorth__c;//北 
            this.displayCond.isNorthEast = inVisitCard.IsNorthEast__c;//北東 
            this.displayCond.isEast = inVisitCard.IsEast__c;//東 
            this.displayCond.isSouthEast = inVisitCard.IsSouthEast__c;//南東 
            this.displayCond.isSouth = inVisitCard.IsSouth__c;//南 
            this.displayCond.isSouthWest = inVisitCard.IsSouthWest__c;//南西 
            this.displayCond.isWest = inVisitCard.IsWest__c;//西 
            this.displayCond.isNorthWest = inVisitCard.IsNorthWest__c;//北西 
            this.displayCond.isNonDeposit = inVisitCard.IsNonDeposit__c;//敷金/保証金なし 
            this.displayCond.isNonKeyMoney = inVisitCard.IsNonKeyMoney__c;//礼金なし 
            this.displayCond.isNonCleaningFee = inVisitCard.IsNonCleaningFee__c;//定額修繕費なし 
            this.displayCond.isNonRenewalFee = inVisitCard.IsNonRenewalFee__c;//更新料なし 
            this.displayCond.rentFeeFrom = CommonUtil.decimalToString(inVisitCard.RentFeeFrom__c);//賃料から 
            this.displayCond.rentFeeTo = CommonUtil.decimalToString(inVisitCard.RentFeeTo__c);//賃料まで 
            this.displayCond.isIncludeManagementFee = inVisitCard.IsIncludeManagementFee__c;//管理費込み 
            this.displayCond.isIncludeParkingFee = inVisitCard.IsIncludeParkingFee__c;//駐車場代込み 
            this.displayCond.occupancyAreaLowerLimit = inVisitCard.OccupancyAreaLowerLimit__c;//占有面積（下限） 
            this.displayCond.occupancyAreaUpperLimit = inVisitCard.OccupancyAreaUpperLimit__c;//占有面積（上限） 
            this.displayCond.buildingAge = inVisitCard.BuildingAge__c;//築年数 
            this.displayCond.isDetachedHouse = inVisitCard.IsDetachedHouse__c;//戸建て 
            this.displayCond.isMaisonette = inVisitCard.IsMaisonette__c;//メゾネット 
            this.displayCond.isLoft = inVisitCard.IsLoft__c;//ロフト 
            this.displayCond.isDesigners = inVisitCard.IsDesigners__c;//デザイナーズ 
            this.displayCond.isRenovation = inVisitCard.IsRenovation__c;//リノベーション 
            this.displayCond.isCondominiumRental = inVisitCard.IsCondominiumRental__c;//分譲賃貸 
            this.displayCond.isAllWestern = inVisitCard.IsAllWestern__c;//オール洋間 
            this.displayCond.isFirstFloor = inVisitCard.IsFirstFloor__c;//1階 
            this.displayCond.isSecondFloorOver = inVisitCard.IsSecondFloorOver__c;//2階以上 
            this.displayCond.isTopFloor = inVisitCard.IsTopFloor__c;//最上階 
            this.displayCond.isCornerRoom = inVisitCard.IsCornerRoom__c;//角部屋 
            this.displayCond.isBalcony = inVisitCard.IsBalcony__c;//バルコニー 
            this.displayCond.isRoofBalcony = inVisitCard.IsRoofBalcony__c;//ルーフバルコニー 
            this.displayCond.isPrivateGarden = inVisitCard.IsPrivateGarden__c;//専用庭 
            this.displayCond.isParking = inVisitCard.IsParking__c;//駐車場空きあり 
            this.displayCond.isInSiteParking = inVisitCard.IsInSiteParking__c;//敷地内駐車場 
            this.displayCond.isPluralCarParking = inVisitCard.IsPluralCarParking__c;//駐車場2台可 
            this.displayCond.isBuiltInGarage = inVisitCard.IsBuiltInGarage__c;//ビルトインガレージ 
            this.displayCond.isCarport = inVisitCard.IsCarport__c;//カーポート 
            this.displayCond.isBicycleParking = inVisitCard.IsBicycleParking__c;//駐輪場 
            this.displayCond.isBikeStorage = inVisitCard.IsBikeStorage__c;//バイク可 
            this.displayCond.isSmallBike = inVisitCard.IsSmallBike__c;//小型バイク 
            this.displayCond.isMediumBike = inVisitCard.IsMediumBike__c;//中型バイク 
            this.displayCond.isLargeBike = inVisitCard.IsLargeBike__c;//大型バイク 
            this.displayCond.isElevator = inVisitCard.IsElevator__c;//エレベーター 
            this.displayCond.isDeliveryBox = inVisitCard.IsDeliveryBox__c;//宅配ボックス 
            this.displayCond.isCounterKitchen = inVisitCard.IsCounterKitchen__c;//カウンターキッチン 
            this.displayCond.isSystemKitchen = inVisitCard.IsSystemKitchen__c;//システムキッチン 
            this.displayCond.isGasStove = inVisitCard.IsGasStove__c;//ガスコンロ 
            this.displayCond.isElectricStove = inVisitCard.IsElectricStove__c;//電気コンロ 
            this.displayCond.isInductionHeating = inVisitCard.IsInductionHeating__c;//IHコンロ 
            this.displayCond.isTwoGasStove = inVisitCard.IsTwoGasStove__c;//コンロ2口 
            this.displayCond.isMoreGasStove = inVisitCard.IsMoreGasStove__c;//コンロ3口以上 
            this.displayCond.isSepalateBathAndRestroom = inVisitCard.IsSepalateBathAndRestroom__c;//バス・トイレ別 
            this.displayCond.isAditionalBoiling = inVisitCard.IsAditionalBoiling__c;//追焚機能 
            this.displayCond.isDehumidifierForBathroom = inVisitCard.IsDehumidifierForBathroom__c;//浴室乾燥機 
            this.displayCond.isWashlet = inVisitCard.IsWashlet__c;//温水洗浄便座 
            this.displayCond.isShowerWashBasin = inVisitCard.IsShowerWashBasin__c;//シャワー付き洗面台 
            this.displayCond.isRegalLavatory = inVisitCard.IsRegalLavatory__c;//洗面所独立 
            this.displayCond.isInnerLandry = inVisitCard.IsInnerLandry__c;//室内洗濯機置場 
            this.displayCond.isTownGas = inVisitCard.IsTownGas__c;//都市ガス 
            this.displayCond.isPropaneGas = inVisitCard.IsPropaneGas__c;//プロパンガス 
            this.displayCond.isAllElectric = inVisitCard.IsAllElectric__c;//オール電化 
            this.displayCond.isAirConditioner = inVisitCard.IsAirConditioner__c;//エアコン 
            this.displayCond.isFloorHeating = inVisitCard.IsFloorHeating__c;//床暖房 
            this.displayCond.isShoesBox = inVisitCard.IsShoesBox__c;//シューズボックス 
            this.displayCond.isShoeCloak = inVisitCard.IsShoeCloak__c;//シューズクローク 
            this.displayCond.isWalkInCloset = inVisitCard.IsWalkInCloset__c;//ウォークインクローゼット 
            this.displayCond.isTrunkRoom = inVisitCard.IsTrunkRoom__c;//トランクルーム 
            this.displayCond.isBSAntenna = inVisitCard.IsBSAntenna__c;//BSアンテナ 
            this.displayCond.isCSAntenna = inVisitCard.IsCSAntenna__c;//CSアンテナ 
            this.displayCond.isCATV = inVisitCard.IsCATV__c;//CATV 
            this.displayCond.isInternetFree = inVisitCard.IsInternetFree__c;//ネット使用料無料 
            this.displayCond.isMonitorIntercom = inVisitCard.IsMonitorIntercom__c;//モニター付きインターホン 
            this.displayCond.isAutoLock = inVisitCard.IsAutoLock__c;//オートロック 
            this.displayCond.isFurniture = inVisitCard.IsFurniture__c;//家具付き 
            this.displayCond.isHomeAppliance = inVisitCard.IsHomeAppliance__c;//家電付き 
            this.displayCond.isNoGuarantor = inVisitCard.IsNoGuarantor__c;//保証人不要 
            this.displayCond.isNonGuaranteeidCompany = inVisitCard.IsNonGuaranteeidCompany__c;//保証会社不要 
            this.displayCond.isMusicalInstruments = inVisitCard.IsMusicalInstruments__c;//楽器相談可 
            this.displayCond.isForeigner = inVisitCard.IsForeigner__c;//外国人契約可 
            this.displayCond.isOfficeAvailable = inVisitCard.IsOfficeAvailable__c;//事務所利用可 
            this.displayCond.isWelfareAvailable = inVisitCard.IsWelfareAvailable__c;//生活保護契約可 
            this.displayCond.isPet = inVisitCard.IsPet__c;//ペット可 
            this.displayCond.isLargePet = inVisitCard.IsLargePet__c;//ペット(大型犬) 
            this.displayCond.isMiddlePet = inVisitCard.IsMiddlePet__c;//ペット(中型犬) 
            this.displayCond.isSmallPet = inVisitCard.IsSmallPet__c;//ペット(小型犬) 
            this.displayCond.isCat = inVisitCard.IsCat__c;//ペット(猫) 
            this.displayCond.isOtherPet = inVisitCard.IsOtherPet__c;//ペット(その他) 
            this.displayCond.isTwoTenant = inVisitCard.IsTwoTenant__c;//2人入居可 
            this.displayCond.isRoomShare = inVisitCard.IsRoomShare__c;//ルームシェア可 
            this.displayCond.isIppambutsu = inVisitCard.IsIppambutsu__c;//一般物 
            this.displayCond.isElderly = inVisitCard.IsElderly__c;//高齢者歓迎 
            this.displayCond.isWoman = inVisitCard.IsWoman__c;//女性限定 
            this.displayCond.isStudent = inVisitCard.IsStudent__c;//学生限定マンション

            this.displayCond.carCount = CommonUtil.decimalToString(inVisitCard.CarCount__c);//台数
            this.displayCond.parkingFeeLimit = CommonUtil.decimalToString(inVisitCard.ParkingFeeLimit__c); //1台当たりの料金上限

            // 取引先の物件条件を設定した物をマップに格納する。
            Map<String, displayVisitCardCond> displayCondMapTmp = new Map<String, displayVisitCardCond>();
            displayCondMapTmp.put(this.displayCond.Name, this.displayCond);
            if(inAccountPropertyConditionsList.size() > 0){
              for(AccountPropertyConditions__c apc : inAccountPropertyConditionsList){
                    displayCondMapTmp.put(apc.Name, new displayVisitCardCond(apc));
                }
            }
            this.displayCondMap = displayCondMapTmp;

            // ▲2021.10.08 No.307 対応で追加
        }
    }
    
    // ▼2021.10.08 No.307 対応で追加
    //お客様物件条件の内部クラス
    public class displayVisitCardCond{

        //選択中の希望駅
        public List<Station__c> stations1 {get; set;}          //駅１
        public List<Station__c> stations2 {get; set;}          //駅２
        public List<Station__c> stations3 {get; set;}          //駅３

        //画面表示用希望駅
        public String stationsChar1 {get; set;}          //駅１文字列
        public String stationsChar2 {get; set;}          //駅２文字列
        public String stationsChar3 {get; set;}          //駅３文字列

        // 選択中の希望中学校
        public List<School__c> juniorHighSchoolList {get; set;}
        // 選択中の希望小学校
        public List<School__c> elementarySchoolList {get; set;}

        // 画面表示用希望中学校
        public String desiredJuniorHighSchool {get; set;} 
        // 画面表示用希望小学校
        public String desiredPrimarySchool {get; set;}

        public Boolean PrerequisiteFlg { get; set; } // 取引先・来店カードから取得した条件ならTRUE
        public Id dispCondId { get; set; } // ID
        public Boolean deleteFlg { get; set; } //削除判定フラグ
        public String Name { get; set; } //物件条件名
        public Datetime CreatedDate { get; set; } //作成日
        public Boolean is1DK { get; set; } //1DK
        public Boolean is1K { get; set; } //1K
        public Boolean is1LDK1SLDK { get; set; } //1LDK/SLDK
        public Boolean isFirstFloor { get; set; } //1階
        public Boolean is2K2DK { get; set; } //2K/DK
        public Boolean is2LDK2SLDK { get; set; } //2LDK/SLDK
        public Boolean isSecondFloorOver { get; set; } //2階以上
        public Boolean isTwoTenant { get; set; } //2人入居可
        public Boolean is3K3DK { get; set; } //3K/DK
        public Boolean is3LDK3SLDK { get; set; } //3LDK/SLDK
        public Boolean is4K4DK4LDKFrom { get; set; } //4K/DK/LDK~
        public Boolean isBSAntenna { get; set; } //BSアンテナ
        public Boolean isCATV { get; set; } //CATV
        public Boolean isCSAntenna { get; set; } //CSアンテナ
        public Boolean isInductionHeating { get; set; } //IHコンロ
        public Boolean isRC { get; set; } //RC
        public Boolean isSRC { get; set; } //SRC
        public Boolean isWalkInCloset { get; set; } //ウォークインクローゼット
        public Boolean isAirConditioner { get; set; } //エアコン
        public Boolean isElevator { get; set; } //エレベーター
        public Boolean isAutoLock { get; set; } //オートロック
        public Boolean isAllElectric { get; set; } //オール電化
        public Boolean isAllWestern { get; set; } //オール洋間
        public Boolean isCarport { get; set; } //カーポート
        public Boolean isCounterKitchen { get; set; } //カウンターキッチン
        public Boolean isGasStove { get; set; } //ガスコンロ
        public Boolean isTwoGasStove { get; set; } //コンロ2口
        public Boolean isMoreGasStove { get; set; } //コンロ3口以上
        public Boolean isSystemKitchen { get; set; } //システムキッチン
        public Boolean isShowerWashBasin { get; set; } //シャワー付き洗面台
        public Boolean isShoeCloak { get; set; } //シューズクローク
        public Boolean isShoesBox { get; set; } //シューズボックス
        public Boolean isDesigners { get; set; } //デザイナーズ
        public Boolean isTrunkRoom { get; set; } //トランクルーム
        public Boolean isInternetFree { get; set; } //ネット使用料無料
        public Boolean isBikeStorage { get; set; } //バイク可
        public Boolean isSepalateBathAndRestroom { get; set; } //バス・トイレ別
        public Boolean isBalcony { get; set; } //バルコニー
        public Boolean isBuiltInGarage { get; set; } //ビルトインガレージ
        public Boolean isPropaneGas { get; set; } //プロパンガス
        public Boolean isOtherPet { get; set; } //ペット(その他)
        public Boolean isSmallPet { get; set; } //ペット(小型犬)
        public Boolean isLargePet { get; set; } //ペット(大型犬)
        public Boolean isMiddlePet { get; set; } //ペット(中型犬)
        public Boolean isCat { get; set; } //ペット(猫)
        public Boolean isPet { get; set; } //ペット可
        public Boolean isMaisonette { get; set; } //メゾネット
        public Boolean isMonitorIntercom { get; set; } //モニター付きインターホン
        public Boolean isRenovation { get; set; } //リノベーション
        public Boolean isRoofBalcony { get; set; } //ルーフバルコニー
        public Boolean isRoomShare { get; set; } //ルームシェア可
        public Boolean isLoft { get; set; } //ロフト
        public Boolean isOneRoom { get; set; } //ワンルーム
        public Boolean isIppambutsu { get; set; } //一般物
        public Boolean isWashlet { get; set; } //温水洗浄便座
        public Boolean isFurniture { get; set; } //家具付き
        public Boolean isHomeAppliance { get; set; } //家電付き
        public Boolean isForeigner { get; set; } //外国人契約可
        public Boolean isCornerRoom { get; set; } //角部屋
        public Boolean isStudent { get; set; } //学生限定マンション
        public Boolean isMusicalInstruments { get; set; } //楽器相談可
        public Boolean isIncludeManagementFee { get; set; } //管理費込み
        public Id desiredTrainRoute1 { get; set; } //希望路線１
        public String trainRoute1 { get; set; } //希望路線１．路線
        public String trainRoute1Name { get; set; } //希望路線１．路線．路線名
        public String desiredTrainRoute2 { get; set; } //希望路線２
        public String trainRoute2 { get; set; } //希望路線２．路線
        public String trainRoute2Name { get; set; } //希望路線２．路線．路線名
        public String desiredTrainRoute3 { get; set; } //希望路線３
        public String trainRoute3 { get; set; } //希望路線３．路線
        public String trainRoute3Name { get; set; } //希望路線３．路線．路線名
        public String desiredArea { get; set; } //希望地域
        public Boolean isLightweightSteel { get; set; } //軽量鉄骨
        public Boolean isDetachedHouse { get; set; } //戸建て
        public Boolean isNonRenewalFee { get; set; } //更新料なし
        public Boolean isElderly { get; set; } //高齢者歓迎
        public Boolean isTopFloor { get; set; } //最上階
        public Boolean isOfficeAvailable { get; set; } //事務所利用可
        public Boolean isInnerLandry { get; set; } //室内洗濯機置場
        public Boolean isWoman { get; set; } //女性限定
        public Boolean isSmallBike { get; set; } //小型バイク
        public Boolean isFloorHeating { get; set; } //床暖房
        public Boolean isWelfareAvailable { get; set; } //生活保護契約可
        public Boolean isWest { get; set; } //西
        public String occupancyAreaLowerLimit { get; set; } //占有面積（下限）
        public String occupancyAreaUpperLimit { get; set; } //占有面積（上限）
        public Boolean isPrivateGarden { get; set; } //専用庭
        public Boolean isRegalLavatory { get; set; } //洗面所独立
        public Boolean isLargeBike { get; set; } //大型バイク
        public Boolean isDeliveryBox { get; set; } //宅配ボックス
        public String buildingAge { get; set; } //築年数
        public Boolean isMediumBike { get; set; } //中型バイク
        public Boolean isPluralCarParking { get; set; } //駐車場2台可
        public Boolean isParking { get; set; } //駐車場空きあり
        public Boolean isIncludeParkingFee { get; set; } //駐車場代込み
        public Boolean isBicycleParking { get; set; } //駐輪場
        public String rentFeeFrom { get; set; } //賃料から
        public String rentFeeTo { get; set; } //賃料まで
        public Boolean isAditionalBoiling { get; set; } //追焚機能
        public Boolean isNonCleaningFee { get; set; } //定額修繕費なし
        public Boolean isSteel { get; set; } //鉄骨造
        public Boolean isElectricStove { get; set; } //電気コンロ
        public String walkingTime { get; set; } //徒歩
        public Boolean isTownGas { get; set; } //都市ガス
        public Boolean isEast { get; set; } //東
        public Boolean isSouth { get; set; } //南
        public Boolean isSouthWest { get; set; } //南西
        public Boolean isSouthEast { get; set; } //南東
        public Boolean isNonDeposit { get; set; } //敷金/保証金なし
        public Boolean isInSiteParking { get; set; } //敷地内駐車場
        public Boolean isCondominiumRental { get; set; } //分譲賃貸
        public Boolean isNonGuaranteeidCompany { get; set; } //保証会社不要
        public Boolean isNoGuarantor { get; set; } //保証人不要
        public Boolean isNorth { get; set; } //北
        public Boolean isNorthWest { get; set; } //北西
        public Boolean isNorthEast { get; set; } //北東
        public Boolean isWooden { get; set; } //木造
        public Boolean isDehumidifierForBathroom { get; set; } //浴室乾燥機
        public Boolean isNonKeyMoney { get; set; } //礼金なし
        public String juniorHighSchoolDistrict { get; set; } //中学校希望学区(エリア)　問合せ415で追加
        public String elementarySchoolDistrict { get; set; } //小学校希望学区(エリア)　問合せ415で追加
        public String juniorHighSchoolArea { get; set; }//中学校希望学区(エリア).希望学区　問合せ415で追加
        public String elementarySchoolArea { get; set; }//小学校希望学区(エリア).希望学区　問合せ415で追加
        public String juniorHighSchool { get; set; } //中学校　問合せ415で追加
        public String elementarySchool { get; set; } //小学校　問合せ415で追加
        public String parkingFeeLimit { get; set; } //1台当たりの料金上限
        public String carCount { get; set; } //台数


        // ▼2021.10.08 No.307 対応で削除 来店カード（希望路線・小学校希望学区・中学校希望学区）、取引先希望路線（希望路線・小学校希望学区・中学校希望学区）
        //更新時に削除する希望路線Id
        public Id AccountPropertyConditionsTrainRoute1 { get; set; } //お客様物件条件　希望路線１
        public Id AccountPropertyConditionsTrainRoute2 { get; set; } //お客様物件条件　希望路線2
        public Id AccountPropertyConditionsTrainRoute3 { get; set; } //お客様物件条件　希望路線3
        public Id AccountPropertyConditionsElementarySchoolArea { get; set; } //お客様物件条件　小学校希望学区
        public Id AccountPropertyConditionsJuniorHighSchoolArea { get; set; } //お客様物件条件　中学校希望学区

        public Id accountDesiredTrainRoute1 { get; set; } //取引先　希望路線１
        public Id accountDesiredTrainRoute2 { get; set; } //取引先　希望路線2
        public Id accountDesiredTrainRoute3 { get; set; } //取引先　希望路線3
        public Id accountDesiredElementarySchoolArea { get; set; } //取引先　小学校希望学区
        public Id accountDesiredJuniorHighSchoolArea { get; set; } //取引先　中学校希望学区

        public Id visitCardDesiredTrainRoute1 { get; set; } //来店カード　希望路線１
        public Id visitCardDesiredTrainRoute2 { get; set; } //来店カード　希望路線2
        public Id visitCardDesiredTrainRoute3 { get; set; } //来店カード　希望路線3
        public Id visitCardDesiredElementarySchoolArea { get; set; } //来店カード　小学校希望学区
        public Id visitCardDesiredJuniorHighSchoolArea { get; set; } //来店カード　中学校希望学区

        // コンストラクタ
        public displayVisitCardCond(){
            this.deleteFlg = false; // 削除判定フラグ
            this.PrerequisiteFlg = false; // 取引先物件条件フラグ
        }
        
        // コンストラクタ（お客様物件条件）
        public displayVisitCardCond(AccountPropertyConditions__c inAccountPropertyConditions){
            this.PrerequisiteFlg = false; // 取引先物件条件フラグ
            this.dispCondId = inAccountPropertyConditions.Id; // ID
            this.deleteFlg = false; // 削除判定フラグ
            this.Name = inAccountPropertyConditions.Name;// 物件条件名
            this.CreatedDate = inAccountPropertyConditions.CreatedDate; // 作成日時
            this.desiredArea = inAccountPropertyConditions.DesiredArea__c;//希望地域 
            this.desiredTrainRoute1 = inAccountPropertyConditions.DesiredTrainRoute1__c;//希望路線１
            this.trainRoute1 = inAccountPropertyConditions.DesiredTrainRoute1__r.TrainRoute__c;//希望路線１．路線
            this.trainRoute1Name = inAccountPropertyConditions.DesiredTrainRoute1__r.TrainRoute__r.NAME;//希望路線１．路線．路線名
            this.desiredTrainRoute2 = inAccountPropertyConditions.DesiredTrainRoute2__c;//希望路線２
            this.trainRoute2 = inAccountPropertyConditions.DesiredTrainRoute2__r.TrainRoute__c;//希望路線２．路線
            this.trainRoute2Name = inAccountPropertyConditions.DesiredTrainRoute2__r.TrainRoute__r.NAME;//希望路線２．路線．路線名
            this.desiredTrainRoute3 = inAccountPropertyConditions.DesiredTrainRoute3__c;//希望路線３
            this.trainRoute3 = inAccountPropertyConditions.DesiredTrainRoute3__r.TrainRoute__c;//希望路線３．路線
            this.trainRoute3Name = inAccountPropertyConditions.DesiredTrainRoute3__r.TrainRoute__r.NAME;//希望路線３．路線．路線名
            // ▼問合せ415で追加
            this.juniorHighSchoolDistrict = inAccountPropertyConditions.DesiredJuniorHighSchoolArea__c;// 中学校希望学区（エリア）
            this.elementarySchoolDistrict = inAccountPropertyConditions.DesiredElementarySchoolArea__c;// 小学校希望学区（エリア）
            this.juniorHighSchoolArea = inAccountPropertyConditions.DesiredJuniorHighSchoolArea__r.SchoolArea__c;// 中学校希望学区（エリア）.希望学区
            this.elementarySchoolArea = inAccountPropertyConditions.DesiredElementarySchoolArea__r.SchoolArea__c;// 小学校希望学区（エリア）.希望学区
            //更新時に削除する希望路線Id

            // ▼2021.10.08 No.307 対応で削除　取引先希望路線・希望学区
            // ▼2021.10.08 No.307 対応で追加
            this.AccountPropertyConditionsTrainRoute1 = inAccountPropertyConditions.DesiredTrainRoute1__c;//希望路線1
            this.AccountPropertyConditionsTrainRoute2 = inAccountPropertyConditions.DesiredTrainRoute2__c;//希望路線2
            this.AccountPropertyConditionsTrainRoute3 = inAccountPropertyConditions.DesiredTrainRoute3__c;//希望路線3
            this.AccountPropertyConditionsElementarySchoolArea = inAccountPropertyConditions.DesiredJuniorHighSchoolArea__c; //中学校希望学区
            this.AccountPropertyConditionsJuniorHighSchoolArea = inAccountPropertyConditions.DesiredElementarySchoolArea__c; //小学校希望学区
            
            this.walkingTime = inAccountPropertyConditions.WalkingTime__c;//徒歩 
            this.isOneRoom = inAccountPropertyConditions.IsOneRoom__c;//ワンルーム 
            this.is1K = inAccountPropertyConditions.Is1K__c;//1K 
            this.is1DK = inAccountPropertyConditions.Is1DK__c;//1DK 
            this.is1LDK1SLDK = inAccountPropertyConditions.Is1LDK1SLDK__c;//1LDK/SLDK 
            this.is2K2DK = inAccountPropertyConditions.Is2K2DK__c;//2K/DK 
            this.is2LDK2SLDK = inAccountPropertyConditions.Is2LDK2SLDK__c;//2LDK/SLDK 
            this.is3K3DK = inAccountPropertyConditions.Is3K3DK__c;//3K/DK 
            this.is3LDK3SLDK = inAccountPropertyConditions.Is3LDK3SLDK__c;//3LDK/SLDK 
            this.is4K4DK4LDKFrom = inAccountPropertyConditions.Is4K4DK4LDKFrom__c;//4K/DK/LDK~ 
            this.isWooden = inAccountPropertyConditions.IsWooden__c;//木造 
            this.isLightweightSteel = inAccountPropertyConditions.IsLightweightSteel__c;//軽量鉄骨 
            this.isSteel = inAccountPropertyConditions.IsSteel__c;//鉄骨造 
            this.isRC = inAccountPropertyConditions.IsRC__c;//RC 
            this.isSRC = inAccountPropertyConditions.IsSRC__c;//SRC 
            this.isNorth = inAccountPropertyConditions.IsNorth__c;//北 
            this.isNorthEast = inAccountPropertyConditions.IsNorthEast__c;//北東 
            this.isEast = inAccountPropertyConditions.IsEast__c;//東 
            this.isSouthEast = inAccountPropertyConditions.IsSouthEast__c;//南東 
            this.isSouth = inAccountPropertyConditions.IsSouth__c;//南 
            this.isSouthWest = inAccountPropertyConditions.IsSouthWest__c;//南西 
            this.isWest = inAccountPropertyConditions.IsWest__c;//西 
            this.isNorthWest = inAccountPropertyConditions.IsNorthWest__c;//北西 
            this.isNonDeposit = inAccountPropertyConditions.IsNonDeposit__c;//敷金/保証金なし 
            this.isNonKeyMoney = inAccountPropertyConditions.IsNonKeyMoney__c;//礼金なし 
            this.isNonCleaningFee = inAccountPropertyConditions.IsNonCleaningFee__c;//定額修繕費なし 
            this.isNonRenewalFee = inAccountPropertyConditions.IsNonRenewalFee__c;//更新料なし 
            this.rentFeeFrom = CommonUtil.decimalToString(inAccountPropertyConditions.RentFeeFrom__c);//賃料から 
            this.rentFeeTo = CommonUtil.decimalToString(inAccountPropertyConditions.RentFeeTo__c);//賃料まで 
            this.isIncludeManagementFee = inAccountPropertyConditions.IsIncludeManagementFee__c;//管理費込み 
            this.isIncludeParkingFee = inAccountPropertyConditions.IsIncludeParkingFee__c;//駐車場代込み 
            this.occupancyAreaLowerLimit = inAccountPropertyConditions.OccupancyAreaLowerLimit__c;//占有面積（下限） 
            this.occupancyAreaUpperLimit = inAccountPropertyConditions.OccupancyAreaUpperLimit__c;//占有面積（上限） 
            this.buildingAge = inAccountPropertyConditions.BuildingAge__c;//築年数 
            this.isDetachedHouse = inAccountPropertyConditions.IsDetachedHouse__c;//戸建て 
            this.isMaisonette = inAccountPropertyConditions.IsMaisonette__c;//メゾネット 
            this.isLoft = inAccountPropertyConditions.IsLoft__c;//ロフト 
            this.isDesigners = inAccountPropertyConditions.IsDesigners__c;//デザイナーズ 
            this.isRenovation = inAccountPropertyConditions.IsRenovation__c;//リノベーション 
            this.isCondominiumRental = inAccountPropertyConditions.IsCondominiumRental__c;//分譲賃貸 
            this.isAllWestern = inAccountPropertyConditions.IsAllWestern__c;//オール洋間 
            this.isFirstFloor = inAccountPropertyConditions.IsFirstFloor__c;//1階 
            this.isSecondFloorOver = inAccountPropertyConditions.IsSecondFloorOver__c;//2階以上 
            this.isTopFloor = inAccountPropertyConditions.IsTopFloor__c;//最上階 
            this.isCornerRoom = inAccountPropertyConditions.IsCornerRoom__c;//角部屋 
            this.isBalcony = inAccountPropertyConditions.IsBalcony__c;//バルコニー 
            this.isRoofBalcony = inAccountPropertyConditions.IsRoofBalcony__c;//ルーフバルコニー 
            this.isPrivateGarden = inAccountPropertyConditions.IsPrivateGarden__c;//専用庭 
            this.isParking = inAccountPropertyConditions.IsParking__c;//駐車場空きあり 
            this.isInSiteParking = inAccountPropertyConditions.IsInSiteParking__c;//敷地内駐車場 
            this.isPluralCarParking = inAccountPropertyConditions.IsPluralCarParking__c;//駐車場2台可 
            this.isBuiltInGarage = inAccountPropertyConditions.IsBuiltInGarage__c;//ビルトインガレージ 
            this.isCarport = inAccountPropertyConditions.IsCarport__c;//カーポート 
            this.isBicycleParking = inAccountPropertyConditions.IsBicycleParking__c;//駐輪場 
            this.isBikeStorage = inAccountPropertyConditions.IsBikeStorage__c;//バイク可 
            this.isSmallBike = inAccountPropertyConditions.IsSmallBike__c;//小型バイク 
            this.isMediumBike = inAccountPropertyConditions.IsMediumBike__c;//中型バイク 
            this.isLargeBike = inAccountPropertyConditions.IsLargeBike__c;//大型バイク 
            this.isElevator = inAccountPropertyConditions.IsElevator__c;//エレベーター 
            this.isDeliveryBox = inAccountPropertyConditions.IsDeliveryBox__c;//宅配ボックス 
            this.isCounterKitchen = inAccountPropertyConditions.IsCounterKitchen__c;//カウンターキッチン 
            this.isSystemKitchen = inAccountPropertyConditions.IsSystemKitchen__c;//システムキッチン 
            this.isGasStove = inAccountPropertyConditions.IsGasStove__c;//ガスコンロ 
            this.isElectricStove = inAccountPropertyConditions.IsElectricStove__c;//電気コンロ 
            this.isInductionHeating = inAccountPropertyConditions.IsInductionHeating__c;//IHコンロ 
            this.isTwoGasStove = inAccountPropertyConditions.IsTwoGasStove__c;//コンロ2口 
            this.isMoreGasStove = inAccountPropertyConditions.IsMoreGasStove__c;//コンロ3口以上 
            this.isSepalateBathAndRestroom = inAccountPropertyConditions.IsSepalateBathAndRestroom__c;//バス・トイレ別 
            this.isAditionalBoiling = inAccountPropertyConditions.IsAditionalBoiling__c;//追焚機能 
            this.isDehumidifierForBathroom = inAccountPropertyConditions.IsDehumidifierForBathroom__c;//浴室乾燥機 
            this.isWashlet = inAccountPropertyConditions.IsWashlet__c;//温水洗浄便座 
            this.isShowerWashBasin = inAccountPropertyConditions.IsShowerWashBasin__c;//シャワー付き洗面台 
            this.isRegalLavatory = inAccountPropertyConditions.IsRegalLavatory__c;//洗面所独立 
            this.isInnerLandry = inAccountPropertyConditions.IsInnerLandry__c;//室内洗濯機置場 
            this.isTownGas = inAccountPropertyConditions.IsTownGas__c;//都市ガス 
            this.isPropaneGas = inAccountPropertyConditions.IsPropaneGas__c;//プロパンガス 
            this.isAllElectric = inAccountPropertyConditions.IsAllElectric__c;//オール電化 
            this.isAirConditioner = inAccountPropertyConditions.IsAirConditioner__c;//エアコン 
            this.isFloorHeating = inAccountPropertyConditions.IsFloorHeating__c;//床暖房 
            this.isShoesBox = inAccountPropertyConditions.IsShoesBox__c;//シューズボックス 
            this.isShoeCloak = inAccountPropertyConditions.IsShoeCloak__c;//シューズクローク 
            this.isWalkInCloset = inAccountPropertyConditions.IsWalkInCloset__c;//ウォークインクローゼット 
            this.isTrunkRoom = inAccountPropertyConditions.IsTrunkRoom__c;//トランクルーム 
            this.isBSAntenna = inAccountPropertyConditions.IsBSAntenna__c;//BSアンテナ 
            this.isCSAntenna = inAccountPropertyConditions.IsCSAntenna__c;//CSアンテナ 
            this.isCATV = inAccountPropertyConditions.IsCATV__c;//CATV 
            this.isInternetFree = inAccountPropertyConditions.IsInternetFree__c;//ネット使用料無料 
            this.isMonitorIntercom = inAccountPropertyConditions.IsMonitorIntercom__c;//モニター付きインターホン 
            this.isAutoLock = inAccountPropertyConditions.IsAutoLock__c;//オートロック 
            this.isFurniture = inAccountPropertyConditions.IsFurniture__c;//家具付き 
            this.isHomeAppliance = inAccountPropertyConditions.IsHomeAppliance__c;//家電付き 
            this.isNoGuarantor = inAccountPropertyConditions.IsNoGuarantor__c;//保証人不要 
            this.isNonGuaranteeidCompany = inAccountPropertyConditions.IsNonGuaranteeidCompany__c;//保証会社不要 
            this.isMusicalInstruments = inAccountPropertyConditions.IsMusicalInstruments__c;//楽器相談可 
            this.isForeigner = inAccountPropertyConditions.IsForeigner__c;//外国人契約可 
            this.isOfficeAvailable = inAccountPropertyConditions.IsOfficeAvailable__c;//事務所利用可 
            this.isWelfareAvailable = inAccountPropertyConditions.IsWelfareAvailable__c;//生活保護契約可 
            this.isPet = inAccountPropertyConditions.IsPet__c;//ペット可 
            this.isLargePet = inAccountPropertyConditions.IsLargePet__c;//ペット(大型犬) 
            this.isMiddlePet = inAccountPropertyConditions.IsMiddlePet__c;//ペット(中型犬) 
            this.isSmallPet = inAccountPropertyConditions.IsSmallPet__c;//ペット(小型犬) 
            this.isCat = inAccountPropertyConditions.IsCat__c;//ペット(猫) 
            this.isOtherPet = inAccountPropertyConditions.IsOtherPet__c;//ペット(その他) 
            this.isTwoTenant = inAccountPropertyConditions.IsTwoTenant__c;//2人入居可 
            this.isRoomShare = inAccountPropertyConditions.IsRoomShare__c;//ルームシェア可 
            this.isIppambutsu = inAccountPropertyConditions.IsIppambutsu__c;//一般物 
            this.isElderly = inAccountPropertyConditions.IsElderly__c;//高齢者歓迎 
            this.isWoman = inAccountPropertyConditions.IsWoman__c;//女性限定 
            this.isStudent = inAccountPropertyConditions.IsStudent__c;//学生限定マンション

            this.carCount = CommonUtil.decimalToString(inAccountPropertyConditions.CarCount__c);//台数
            this.parkingFeeLimit = CommonUtil.decimalToString(inAccountPropertyConditions.ParkingFeeLimit__c); //1台当たりの料金上限
        }
    }
    // ▲2021.10.08 No.307 対応で追加


}