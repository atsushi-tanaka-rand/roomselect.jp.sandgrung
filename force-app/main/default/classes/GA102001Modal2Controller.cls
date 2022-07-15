// 対応履歴画面
public with sharing class GA102001Modal2Controller {

    /** 共通クラス */    
    public GA102001Modal2ParameterClass Parameter { get; set; }

    /** エラーフラグ */ 
    public Boolean isOpenError { get; set; }
    
    /** エラーメッセージ保有フラグ */ 
    public Boolean hasErrorMessage { get; set; } 

    // 画面用対応種別定数
    public String TASK_CORRESPONDTYPE_MEMO             { get{return CommonConst.TASK_CORRESPONDTYPE_MEMO            ;} private set; } //メモ
    public String TASK_CORRESPONDTYPE_APPOINTMENT      { get{return CommonConst.TASK_CORRESPONDTYPE_APPOINTMENT     ;} private set; } //アポイント確定
    public String TASK_CORRESPONDTYPE_MAIL             { get{return CommonConst.TASK_CORRESPONDTYPE_MAIL            ;} private set; } //メール
    public String TASK_CORRESPONDTYPE_VISITED          { get{return CommonConst.TASK_CORRESPONDTYPE_VISITED         ;} private set; } //来店済
    public String TASK_CORRESPONDTYPE_CONSIDERVISITING { get{return CommonConst.TASK_CORRESPONDTYPE_CONSIDERVISITING;} private set; } //来店後検討
    public String TASK_CORRESPONDTYPE_APPLICANT        { get{return CommonConst.TASK_CORRESPONDTYPE_APPLICANT       ;} private set; } //申込登録
    public String TASK_CORRESPONDTYPE_PURSUITHOLD      { get{return CommonConst.TASK_CORRESPONDTYPE_PURSUITHOLD     ;} private set; } //追客保留
    public String TASK_CORRESPONDTYPE_TEL              { get{return CommonConst.TASK_CORRESPONDTYPE_TEL             ;} private set; } //電話
    public String TASK_CORRESPONDTYPE_MERGE            { get{return CommonConst.TASK_CORRESPONDTYPE_MERGE           ;} private set; } //名寄せ
    public String TASK_CORRESPONDTYPE_CANCEL           { get{return CommonConst.TASK_CORRESPONDTYPE_CANCEL          ;} private set; } //キャンセル
    public String TASK_CORRESPONDTYPE_CLOSE            { get{return CommonConst.TASK_CORRESPONDTYPE_CLOSE           ;} private set; } //終了
    public String TASK_CORRESPONDTYPE_APO_CANCEL       { get{return CommonConst.TASK_CORRESPONDTYPE_APO_CANCEL      ;} private set; } //問合せNo295で追加　アポキャンセル
    public String TASK_CORRESPONDTYPE_SMS              { get{return CommonConst.TASK_CORRESPONDTYPE_SMS             ;} private set; } //SMS
    public String TASK_CORRESPONDTYPE_LINE             { get{return CommonConst.TASK_CORRESPONDTYPE_LINE            ;} private set; } //LINE

    public String CORRESPOND_STATUS_CLOSE              { get{return CommonConst.CORRESPOND_STATUS_CLOSE             ;} private set; } //終了
    public String MSG_COM_V_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_SAVE);} private set;}   // 登録確認メッセージ
    public String MSG_COM_I_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);} private set;}   // 登録完了メッセージ

	public String CORRESPOND_EXACT_CONDITION_MATCH_NO	{ get{return CommonConst.CORRESPOND_EXACT_CONDITION_MATCH_NO	;} private set; }// 条件完全一致.しない 2021.10.08 No.307 対応で追加

    public Correspond__c Correspond ;          // 対応データ
    public Account account ;          // 取引先データ

    public List<SelectOption> selectSenderList { get;set; }     // 2020/6/10追加：発信者のリスト
    public List<SelectOption> selectSituationList { get;set; }  // 対応状況のリスト
    public List<SelectOption> selectPortalSiteList { get;set; } // ポータルサイトのリスト
    public List<SelectOption> selectDistrictList { get;set; }   // 地区のリスト
    public List<SelectOption> selectApoCancelList { get;set; }  // 問合せNo295で追加　アポキャンセル理由のリスト
    public List<SelectOption> selectExactConditionMatchList { get;set; }  //条件完全一致のリスト
    public List<SelectOption> screenFavoritePropertyList { get;set; }   // 問合せ416で追加　お気に入り物件（value:カスタムオブジェクトID、label:お問合せ物件）
	public List<SelectOption> selectGuidanceMethodList { get;set; }   // 案内方法のリスト
	
    // 2020.09.24 ▼ 来店担当追加
    public List<SelectOption> selectShopStaff1List { get;set; }  // 来店担当者_担当者
    public List<SelectOption> selectVisitShop1List { get;set; }  // 来店担当者_店舗
    public List<SelectOption> selectShopStaff2List { get;set; }  // 来店担当者_担当者
    public List<SelectOption> selectVisitShop2List { get;set; }  // 来店担当者_店舗
    //ラジオボタン値
    public String STAFF_ONE       { get{return '１名　';} private set; } //１名
    public String STAFF_TWO       { get{return '２名';} private set; } //２名
    public String staffCountValue { get; set; }       //担当 １名 OR ２名
    //出力メッセージ用
    public static String STAFF_ONE_MSG = '（担当者１）';
    public static String STAFF_TWO_MSG = '（担当者２）';
    // 2020.09.24 ▲ 来店担当追加

    public screenCorrespondDetail screenCorrespondDetail { get;set; }   // 対象データ

    public String loginStaff { get;set; }       // ログインユーザ(登録用)
    public String loginShop { get;set; }        // ログインユーザ店舗

    public Boolean insCorrespondDetailFlg { get;set; }           // 登録、更新フラグ（対応明細）
    public Boolean isEcho { get;set; }           // 2020/6/25追加：反響フラグ（電話対応が電話反響/LINE反響/Livero反響のどれか）
   
    private Boolean isShopType;                 // 店舗区分(ISの判断)
    private List<SelectOption> selectPortalSiteNormalList { get;set; } // 画面表示用のポータルサイトのリスト
    private List<SelectOption> selectPortalSiteLiveroList { get;set; } // リベロのポータルサイトのリスト
    private Id portalSiteLiveroId;//2020/6/25追加：ポータルサイトの選択肢リベロ
    private Event selectedEvent;    //アポイント変更取得時に取得されたイベント（担当者１用）
    private Event selectedEvent2;   //アポイント変更取得時に取得されたイベント（担当者２用） 2020/09/24 追加
    private Boolean echoInsertFlg { get;set; } // 2021.09.24 No.489で追加 反響一覧登録フラグ
    private String inquiryPropId { get;set; } // 2021.09.24 No.489で追加 問合せ物件ID

	// ▼ 2021.11.30 LINE連携対応より、メモと電話の切り替え用対応種別を追加
	public List<SelectOption>	chgCorrespondTypeList	{get; set;}
	public String				selectedCorrespondType	{get; set;}
	// ▲ 2021.11.30

    public Boolean init{
        get{
            if (Parameter.isDrawing) {
				// ▼ 2021.11.30 LINE連携対応より、メモと電話の切り替え用対応種別を追加
				this.selectedCorrespondType = CommonConst.STRING_EMPTY;
				// ▲ 2021.11.30
                getSelectOption();
                Parameter.isDrawing = false;
                return false;
            }
            return true;
        }
    }

    //2020/6/10追加：電話の発信者が変更されたとき、状況の選択リストを変更する
    public void changeSender(){
        selectSituationList.clear();
        selectSituationList.add(new SelectOption('', CommonConst.SELECTION_LIST_NULL));//なし
        
        //担当者に変更された
        if (screenCorrespondDetail.Sender == CommonConst.CORRESPONDDETAIL_SENDER_STAFF){
            selectSituationList.add(new SelectOption(CommonConst.CORRESPONDDETAIL_PHONESTATUS_CONTACT, CommonConst.CORRESPONDDETAIL_PHONESTATUS_CONTACT));//電話連絡（担当→お客様）繋がった
            selectSituationList.add(new SelectOption(CommonConst.CORRESPONDDETAIL_PHONESTATUS_NOCONTACT, CommonConst.CORRESPONDDETAIL_PHONESTATUS_NOCONTACT));//電話連絡（担当→お客様）繋がらない
            selectSituationList.add(new SelectOption(CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINESEND, CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINESEND));//2020/6/25追加：LINE送信
            selectSituationList.add(new SelectOption(CommonConst.CORRESPONDDETAIL_PHONESTATUS_SEND_SMS, CommonConst.CORRESPONDDETAIL_PHONESTATUS_SEND_SMS));//SMS送信
            
        //お客様に変更された
        }else if (screenCorrespondDetail.Sender == CommonConst.CORRESPONDDETAIL_SENDER_CUSTOMER){
            selectSituationList.add(new SelectOption(commonConst.CORRESPONDDETAIL_PHONESTATUS_ECHO,CommonConst.CORRESPONDDETAIL_PHONESTATUS_ECHO));//電話反響
            selectSituationList.add(new SelectOption(CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINEECHO, CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINEECHO));//2020/6/25追加：LINE反響
            selectSituationList.add(new SelectOption(CommonConst.CORRESPONDDETAIL_PHONESTATUS_LIVEROECHO, CommonConst.CORRESPONDDETAIL_PHONESTATUS_LIVEROECHO));//2020/6/25追加：Livero反響
            selectSituationList.add(new SelectOption(CommonConst.CORRESPONDDETAIL_PHONESTATUS_CALL, CommonConst.CORRESPONDDETAIL_PHONESTATUS_CALL));//電話連絡（お客様→担当）
            selectSituationList.add(new SelectOption(CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINERECEIVE, CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINERECEIVE));//2020/6/25追加：LINE受信
            selectSituationList.add(new SelectOption(CommonConst.CORRESPONDDETAIL_PHONESTATUS_RECEIVE_SMS, CommonConst.CORRESPONDDETAIL_PHONESTATUS_RECEIVE_SMS));//SMS受信
        }
        //2020/6/25追加：ポータルサイトの選択肢を画面表示（LINE反響以外）用に変更
        this.selectPortalSiteList = this.selectPortalSiteNormalList;

        // 選択リストの選択値を初期化
        screenCorrespondDetail.PhoneStatus = '';         // 電話状況
        screenCorrespondDetail.PortalSite = '';          // ポータルサイト
        screenCorrespondDetail.District = '';            // 地区
        screenCorrespondDetail.SelectedInquiryProp = ''; // お問合せ物件

        //反響フラグをfalseに
        isEcho = false;
    }

    //2020/6/10追加 6/25変更：電話の状況が変更されたとき
    public void changePhoneStatus(){
        //状況が反響系（電話反響・LINE反響・Livero反響）
        if (screenCorrespondDetail.PhoneStatus == CommonConst.CORRESPONDDETAIL_PHONESTATUS_LIVEROECHO ||
            screenCorrespondDetail.PhoneStatus == CommonConst.CORRESPONDDETAIL_PHONESTATUS_ECHO ||
            screenCorrespondDetail.PhoneStatus == CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINEECHO){

            //反響フラグをtrueにする
            isEcho = true;
            
            //状況が電話反響・LINE反響
            if (screenCorrespondDetail.PhoneStatus != CommonConst.CORRESPONDDETAIL_PHONESTATUS_LIVEROECHO){
                //ポータルサイトの選択肢を画面表示（リベロ反響以外）用に、ポータルサイトの値を「--なし--」に変更
                SettingPhonePortalSite(false); 
            
            //状況がリベロ反響
            }else{
                //ポータルサイトの選択肢をリベロ用に、ポータルサイトの値を「Livero」に変更
                SettingPhonePortalSite(true);   
            }

        //状況が反響系以外
        }else{
            //反響フラグをfalseにする
            isEcho = false;

            //ポータルサイトの選択肢を画面表示（リベロ反響以外）用に、ポータルサイトの値を「--なし--」に変更
            SettingPhonePortalSite(false);  
            
            // リストボックスの初期化
            screenCorrespondDetail.District = '';                                   // 地区
            screenCorrespondDetail.SelectedInquiryProp = CommonConst.STRING_EMPTY;  // お問合せ物件
        }
    }

    public void getSelectOption() {

        try{
            this.isEcho = false;//反響フラグfalse（電話用）
            this.echoInsertFlg = false;// 2021.09.24 No.489で追加 反響一覧登録フラグ
            //問合せNo295で追加
            this.selectApoCancelList = new List<SelectOption>();
            selectSituationList = new List<SelectOption>();
            this.Correspond = new Correspond__c();
            List<CorrespondDetail__c> CorrespondDetail = new List<CorrespondDetail__c>();
            // 問合せ416で追加
            CorrespondDetail__c targetCorrespondDetail = new CorrespondDetail__c();
            selectShopStaff1List = new List<SelectOption>(); 
            selectShopStaff2List = new List<SelectOption>(); 
            // 店舗情報の取得
            Shop__c shop = CommonUtil.getStaffCurrentShop();
			//▼問合せNo341でテスト時に店舗がnullの場合のエラーを出さないよう変更
			if (!Test.isRunningTest() || Test.isRunningTest() && (shop != null)){
				this.loginShop = shop.id;                            // 店舗名
				this.isShopType = shop.IsShopType__c;                // 店舗区分(ISの判断)
			}
			//▲問合せNo341でテスト時に店舗がnullの場合のエラーを出さないよう変更
			this.loginStaff = UserInfo.getUserId();
            
            //▼問合せNo341で追加　取引先情報取得
            this.account = new Account();
            List<Account> accountList = new List<Account>();
            accountList = selectAccountInfo();
            if(accountList.size() > 0){
            	this.account = accountList[0];
            }
            //▲問合せNo341で追加
            
            // 対応IDから項目を取得
            List<Correspond__c> CorrespondList = selectCorrespondInfo(Parameter.CorrespondId);
            if (CorrespondList.size() > 0){
                this.Correspond = CorrespondList[0];
            }
            
            // 対応明細IDの取得有無で登録か更新かの判断
            if (String.isEmpty(Parameter.CorrespondDetailId)) {
                // 登録
                insCorrespondDetailFlg = True;
            }else{
                // 更新
                insCorrespondDetailFlg = False;
            }

            if (insCorrespondDetailFlg){
                // 登録時
                screenCorrespondDetail = new screenCorrespondDetail(Parameter.CorrespondType);

                // 対応種別により設定する状況の一覧を変える。
                if (Parameter.CorrespondType == CommonConst.TASK_CORRESPONDTYPE_TEL) {
                    this.selectSenderList = CommonUtil.getSelectOptionFromObject('CorrespondDetail__c', 'Sender__c',true);   //2020/6/10追加：発信者
                    this.selectSituationList = CommonUtil.getSelectOptionFromObject('CorrespondDetail__c', 'PhoneStatus__c',true);   // 電話状況
                    this.selectPortalSiteList = getPortalSiteSelectedOptionFromId(true,false);// 2020/6/25変更：ポータルサイト
                    this.selectDistrictList = CommonUtil.getSelectOptionFromObject('Correspond__c', 'District__c',true);   // 地区
                    //問合せ416で追加　お気に入り物件
                    setFavoriteProperty(null);   
                }else if(Parameter.CorrespondType == CommonConst.TASK_CORRESPONDTYPE_CLOSE){
                    this.selectSituationList = CommonUtil.getSelectOptionFromObject('CorrespondDetail__c', 'EndType__c');   // 終了種別
                }else if(Parameter.CorrespondType == CommonConst.TASK_CORRESPONDTYPE_PURSUITHOLD){
                    this.selectExactConditionMatchList = CommonUtil.getSelectOptionFromObject('Correspond__c', 'ExactConditionMatch__c',false);   // 条件完全一致
                    screenCorrespondDetail.ExactConditionMatch = CommonConst.CORRESPOND_EXACT_CONDITION_MATCH_NO;
                    if(this.Correspond.ExactConditionMatch__c != null){
                    	screenCorrespondDetail.ExactConditionMatch = this.Correspond.ExactConditionMatch__c; 
                    }
                }
                
                // 取れてきた対応の情報をセットする。
                //this.screenCorrespondDetail.District = this.Correspond.District__c ;    // 地区 2020/6/10削除：電話系変更に伴い地区の初期値削除

                //アポイント確定のみ、店舗と担当者、案内方法リストを設定
                if(Parameter.CorrespondType == CommonConst.TASK_CORRESPONDTYPE_APPOINTMENT){
                    // 2020.09.24 ▼ 来店担当追加
                    // 来店担当者_店舗のリストをセット
                    selectVisitShop1List = CommonUtil.getShopSelectedOptionFromStaffId(CommonConst.STRING_EMPTY,True);
                    selectVisitShop2List = selectVisitShop1List.clone();
                    // 来店担当者_担当者のリストをセット
                    if (string.isBlank(this.Correspond.VisitShop__c)){
                        selectShopStaff1List.add(new SelectOption(CommonConst.STRING_EMPTY,CommonConst.SELECTION_LIST_NULL));
                        selectShopStaff2List.add(new SelectOption(CommonConst.STRING_EMPTY,CommonConst.SELECTION_LIST_NULL));                    
                    }else {
                        selectShopStaff1List = CommonUtil.getUserSelectedOptionFromShopId(this.Correspond.VisitShop__c,True);
                        selectShopStaff2List = selectShopStaff1List.clone();
                    }
                    // 登録時、来店担当を初期表示
                    this.screenCorrespondDetail.VisitShop = this.Correspond.VisitShop__c ;      // 来店店舗 １
                    this.screenCorrespondDetail.ShopStaff = this.Correspond.ShopStaff__c ;      // 来店担当者１
                    this.screenCorrespondDetail.VisitShop2 = this.Correspond.VisitShop__c ;     // 来店店舗 ２
                    //担当者が１名を初期表示
                    this.staffCountValue = STAFF_ONE;
                    // 2020.09.24 ▲ 来店担当追加
                            
                    //案内方法リストを設定
                    this.selectGuidanceMethodList = CommonUtil.getSelectOptionFromObject('Correspond__c', 'FirstGuidanceMethod__c',true);   //案内方法
                   
                }

                if((this.Correspond.Status__c == CommonConst.CORRESPOND_STATUS_CLOSE ||
                    this.Correspond.Status__c == CommonConst.CORRESPOND_STATUS_AGREEMENT )&& 
                    this.screenCorrespondDetail.CorrespondType == CommonConst.TASK_CORRESPONDTYPE_APPOINTMENT){
                        // 終了、契約完了からアポイント確定を開く場合は物件を設定しない。
                }else{
                    if(!string.isBlank(this.Correspond.Property__r.Building__r.Name)){
                        // 登録されている物件を表示
                        this.screenCorrespondDetail.BuildingName       = Correspond.Property__r.Building__r.Name + ' ';
                        if(!String.isBlank(this.Correspond.Property__r.Name)){
                            this.screenCorrespondDetail.BuildingName      += this.Correspond.Property__r.Name ;
                        }
                    }else{
                        // 初回問合せ分を表示
                        if(!String.isBlank(this.Correspond.FirstInquiryProperty__r.Building__r.Name)){
                            this.screenCorrespondDetail.BuildingName       = this.Correspond.FirstInquiryProperty__r.Building__r.Name + ' ';
                        }
                        if(!String.isBlank(this.Correspond.FirstInquiryProperty__r.Name)){
                            this.screenCorrespondDetail.BuildingName      += this.Correspond.FirstInquiryProperty__r.Name;
                        }
                        
                    }
                }


            }else{
                // 更新時

                // データ取得
                CorrespondDetail = selectCorrespondDetailInfo(parameter.CorrespondDetailId);
                // 設定
                for(CorrespondDetail__c selectData:CorrespondDetail){
                    screenCorrespondDetail = new screenCorrespondDetail(selectData);
                }
                // 対応種別により設定する状況の一覧を変える。
                if (this.isModalTelStatus()) {
                    this.selectSenderList = CommonUtil.getSelectOptionFromObject('CorrespondDetail__c', 'Sender__c',true);   //2020/6/10追加：発信者
                    this.selectSituationList = CommonUtil.getSelectOptionFromObject('CorrespondDetail__c', 'PhoneStatus__c');  // 電話状況
                    this.selectPortalSiteList = getPortalSiteSelectedOptionFromId(true,false);// 2020/6/25変更：ポータルサイト
                    this.selectDistrictList = CommonUtil.getSelectOptionFromObject('Correspond__c', 'District__c',true);   // 地区
                    //問合せ416で追加　お気に入り物件が存在する場合、表示用選択リストを作成
                    if(CorrespondDetail.size() != 0) {
                        targetCorrespondDetail = CorrespondDetail.get(0);
                    }
                    setFavoriteProperty(targetCorrespondDetail);
                }else if(screenCorrespondDetail.CorrespondType == CommonConst.TASK_CORRESPONDTYPE_CLOSE){
                    this.selectSituationList = CommonUtil.getSelectOptionFromObject('CorrespondDetail__c', 'EndType__c');   // 終了種別
                }                
                
            }

			// ▼ 2021.11.30 LINE連携対応より、メモと電話の切り替え用対応種別を追加
			// 対応種別の取得
			this.chgCorrespondTypeList = new List<SelectOption>{
				new SelectOption(TASK_CORRESPONDTYPE_TEL,   TASK_CORRESPONDTYPE_TEL),
				new SelectOption(TASK_CORRESPONDTYPE_MEMO,  TASK_CORRESPONDTYPE_MEMO)
			};

			// デフォルトは電話固定
			if (String.isBlank(this.selectedCorrespondType)) {
				this.selectedCorrespondType = TASK_CORRESPONDTYPE_TEL;
			}
			// ▲ 2021.11.30

            selectedEvent = null;
            // 2020.09.24 ▼ 来店担当追加
            //担当者が１名を初期設定
            this.staffCountValue = STAFF_ONE;
            selectedEvent2 = null;
            // 2020.09.24 ▲ 来店担当追加

            //アポイント変更時の初期処理(現在アポイント確定である場合のみ)
            if(Parameter.Status == CommonConst.TASK_CORRESPONDTYPE_APPOINTMENT && Correspond.Status__c == CommonConst.CORRESPOND_STATUS_APPOINTMENT) {

                // 2020.09.24 ▼ 来店担当追加
                // 来店担当者_店舗のリストをセット
                selectVisitShop1List = CommonUtil.getShopSelectedOptionFromStaffId(CommonConst.STRING_EMPTY,True);
                selectVisitShop2List = selectVisitShop1List.clone();
                List<Event> eventList = [
                    SELECT 
                        Id, Subject, StartDateTime, EndDateTime, Description, OwnerId, Shop__c, GuidanceMethod__c 
                    FROM Event 
                    WHERE Id IN (:Correspond.EventId__c , :Correspond.EventId2__c)
                    ORDER BY CreatedDate];

                if(!eventList.isEmpty()){
                    for (Event event : eventList) {
                        // 担当者１の行動IDと一致した場合
                        if (event.Id == Correspond.EventId__c){
                            // 担当者１のリストをセット
                            if (string.isBlank(event.Shop__c)){
                                selectShopStaff1List.add(new SelectOption(CommonConst.STRING_EMPTY,CommonConst.SELECTION_LIST_NULL));
                            }else {
                                selectShopStaff1List = CommonUtil.getUserSelectedOptionFromShopId(event.Shop__c,True);
                            }
                            //担当者１の情報を設定
                            selectedEvent = event;
                            screenCorrespondDetail.SupportedTitle   = event.Subject.removeStart('【' + CommonConst.TASK_CORRESPONDTYPE_OPPORTUNITY + '】' );
                            screenCorrespondDetail.VisitShop        = event.Shop__c;
                            screenCorrespondDetail.ShopStaff        = event.OwnerId;
                            screenCorrespondDetail.StartDate        = event.startDateTime.date();
                            screenCorrespondDetail.StartDateTime    = event.startDateTime.Time();
                            screenCorrespondDetail.EndDate          = event.EndDateTime.date();
                            screenCorrespondDetail.EndDateTime      = event.EndDateTime.Time();
                            screenCorrespondDetail.SupportedContent = event.Description;

                            //案内方法は共通部(担当者1,2)である
                            screenCorrespondDetail.GuidanceMethod   = event.GuidanceMethod__c;
                        }
                        // 担当者２の行動IDと一致した場合
                        if (event.Id == Correspond.EventId2__c){
                            // 担当者２のリストをセット
                            if (string.isBlank(event.Shop__c)){
                                selectShopStaff2List.add(new SelectOption(CommonConst.STRING_EMPTY,CommonConst.SELECTION_LIST_NULL));
                            }else {
                                selectShopStaff2List = CommonUtil.getUserSelectedOptionFromShopId(event.Shop__c,True);
                            }
                            //担当者２の情報を設定
                            selectedEvent2 = event;
                            screenCorrespondDetail.SupportedTitle   = event.Subject.removeStart('【' + CommonConst.TASK_CORRESPONDTYPE_OPPORTUNITY + '】' );
                            screenCorrespondDetail.VisitShop2       = event.Shop__c;
                            screenCorrespondDetail.ShopStaff2       = event.OwnerId;
                            screenCorrespondDetail.StartDate2       = event.startDateTime.date();
                            screenCorrespondDetail.StartDateTime2   = event.startDateTime.Time();
                            screenCorrespondDetail.EndDate2         = event.EndDateTime.date();
                            screenCorrespondDetail.EndDateTime2     = event.EndDateTime.Time();
                            screenCorrespondDetail.SupportedContent = event.Description;
                            //担当者が２名を設定
                            this.staffCountValue = STAFF_TWO;
                        }
                    }
                }
                // 2020.09.24 ▲ 来店担当追加
            }
            //▼問合せNo295で追加
            if(screenCorrespondDetail.CorrespondType == TASK_CORRESPONDTYPE_APO_CANCEL){
                this.selectApoCancelList.add(new SelectOption(CommonConst.STRING_EMPTY,CommonConst.SELECTION_LIST_NULL));
                this.selectApoCancelList.add(new SelectOption(CommonConst.APOCANCEL_LAST_MINUTE_CANCELLATION,CommonConst.APOCANCEL_LAST_MINUTE_CANCELLATION));
                this.selectApoCancelList.add(new SelectOption(CommonConst.APOCANCEL_OTHER_DECISION,CommonConst.APOCANCEL_OTHER_DECISION));
                this.selectApoCancelList.add(new SelectOption(CommonConst.APOCANCEL_OTHER,CommonConst.APOCANCEL_OTHER));
            }
            //▲問合せNo295で追加
        } catch (Exception e) {
            // エラーを設定
            CommonUtil.setErrorMessage(e);
        }

    }

    // 2020.09.24 ▼ 来店担当追加 
    /**
     * 来店担当者_店舗１のリストを変更
     */
    public void getVisitShopList1(){
        try{
            // 来店担当者_担当者１のリストをセット
            if (string.isBlank(screenCorrespondDetail.VisitShop)){
                selectShopStaff1List = new List<SelectOption>();     //リストの初期化
                selectShopStaff1List.add(new SelectOption(CommonConst.STRING_EMPTY,CommonConst.SELECTION_LIST_NULL));
            }else {
                selectShopStaff1List = CommonUtil.getUserSelectedOptionFromShopId(screenCorrespondDetail.VisitShop,True);
                screenCorrespondDetail.ShopStaff = CommonConst.STRING_EMPTY;
            }

        } catch (Exception e) {
            // エラーを設定
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    /**
     * 来店担当者_店舗２のリストを変更
     */
    public void getVisitShopList2(){
        try{
            // 来店担当者_担当者２のリストをセット
            if (string.isBlank(screenCorrespondDetail.VisitShop2)){
                selectShopStaff2List = new List<SelectOption>();     //リストの初期化
                selectShopStaff2List.add(new SelectOption(CommonConst.STRING_EMPTY,CommonConst.SELECTION_LIST_NULL));
            }else {
                selectShopStaff2List = CommonUtil.getUserSelectedOptionFromShopId(screenCorrespondDetail.VisitShop2,True);
                screenCorrespondDetail.ShopStaff2 = CommonConst.STRING_EMPTY;
            }

        } catch (Exception e) {
            // エラーを設定
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    /**
     * １名 OR ２名ラジオボタンの初期設定処理
     */
    public List<SelectOption> getstaffCountList(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(STAFF_ONE, STAFF_ONE));
        options.add(new SelectOption(STAFF_TWO, STAFF_TWO));
        return options;
    }

    /**
     * 選択リストから現在選択されている値のラベルを取得
     */
    public string getSelectOptionLabel(List<SelectOption> optList, String selectVal){

        for (SelectOption opt : optList) {
            if (opt.getValue() == selectVal){
                return opt.getLabel();
            }
        }
        return null;
    }

    // 2020.09.24 ▲ 来店担当追加

    /**
     * 登録処理
     * 引数　　：　Id String 所属部署
     * 戻り値　：
     */
    public void saveDate(){

        Savepoint sp = Database.setSavepoint();      //セーブポイント作成
        hasErrorMessage = false;
        BusinessLogicException inputCheckException = new BusinessLogicException();
        try{
            // 楽観ロックチェック
            OptimisticLockCheck(this.Correspond,screenCorrespondDetail,this.account);

            inputCheckException = inputCheck(screenCorrespondDetail.CorrespondType);
            // エラーあり
            if(inputCheckException.hasMessage()){
                throw inputCheckException;
            }

            // アポイント確定の場合、行動レコードを登録
            if(Parameter.Status == CommonConst.CORRESPOND_STATUS_APPOINTMENT){
                saveEvent(Parameter.AccountId);                        
            }

			// ▼2022.02.24 No.307 対応で追加（移動）
			// 追客保留の場合、取引先、お客様物件条件の予約物件条件を更新
			if(Parameter.CorrespondType == TASK_CORRESPONDTYPE_PURSUITHOLD){
				updateReserved();
			}
			// ▲2022.02.24 No.307 対応で追加（移動）

            // 対応の登録、更新
            String CorrespondId =  saveCorrespond(Parameter.CorrespondId,this.Correspond);
                 
            // 対応明細の登録
            saveCorrespondDetail(CorrespondId,Parameter.AccountId);
            
            //▼問合せNo341で追加
            if(this.account != null && screenCorrespondDetail.PhoneStatus == CommonConst.CORRESPONDDETAIL_PHONESTATUS_ECHO){
                this.account.EchoTelephoneFlag__c = true;
                SecureDML.secureUpdate(this.account);
            }
            //▲問合せNo341で追加
            //▼問合せNo411で追加
            if(this.account != null && screenCorrespondDetail.PhoneStatus == CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINEECHO){
                this.account.EchoLineFlag__c = true;
                SecureDML.secureUpdate(this.account);
            }
            if(this.account != null && screenCorrespondDetail.PhoneStatus == CommonConst.CORRESPONDDETAIL_PHONESTATUS_LIVEROECHO){
                this.account.EchoLiveroFlag__c = true;
                SecureDML.secureUpdate(this.account);
            }
            //▲問合せNo411で追加
        
            //申込キャンセルの場合は、申込レコードを削除            
            if (Parameter.Status == CommonConst.CORRESPOND_STATUS_APPLCANCEL){
                if (string.isNotBlank(Correspond.Application__c)){
                    deleteApplication();
                }
            }
            // アポイントキャンセルの場合、行動レコードを削除
            else if(Parameter.Status == CommonConst.CORRESPOND_STATUS_APOCANCEL) {
                // 2020.09.24 ▼ 来店担当追加
                List<Event> eventList = [SELECT Id FROM Event WHERE Id in (:Correspond.EventId__c, :Correspond.EventId2__c) ];
                // 2020.09.24 ▲ 来店担当追加
                if(!eventList.isEmpty()){
                    SecureDML.secureDelete(eventList);
                }
            }

			// ▼2022.02.24 No.307 対応で削除（移動）
        }catch(Exception e){
            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;//エラーを設定

            CommonUtil.setErrorMessage(e);
        }
    }

	// ▼2021.10.08 No.307 対応で追加
	/**
	 * 予約物件条件更新
	 */
	private void updateReserved(){
		Map<Id, Account> updateAccMap = new Map<Id, Account>();//保存対象取引先
		Map<Id, AccountPropertyConditions__c> updateApcMap = new Map<Id, AccountPropertyConditions__c>();//保存対象予約物件条件
		GA102001Modal10ParameterClass paremeter10 = Parameter.GA102001Paremeter10;//予約物件条件モーダルパラメータ

		//条件完全一致しない場合、予約物件条件をすべてfalseとする
		if(CommonConst.CORRESPOND_EXACT_CONDITION_MATCH_NO.equals(screenCorrespondDetail.ExactConditionMatch)){
			List<Boolean> falseList = new List<Boolean>();
			for(Boolean spcReserved: paremeter10.spcReservedList){
				falseList.add(false);
			}
			paremeter10.spcReservedList = falseList;
		}else if(paremeter10.spcIndexList.size() == 1){
			//条件完全一致を実施し、物件条件が1件のみの場合、予約物件条件をtrueとする
			paremeter10.spcReservedList[0] = true;
		}

		for(Integer spcIndex: paremeter10.spcIndexList){
			if(paremeter10.befSpcReservedList[spcIndex] == paremeter10.spcReservedList[spcIndex]){
				//予約物件条件の変わらないものは処理しない
				continue;
			}
			Id recId = paremeter10.spcIdList[spcIndex];
			Boolean spcReserved = paremeter10.spcReservedList[spcIndex];
			if(paremeter10.spcAccountFlgList[spcIndex]){
				//取引先
				Account updateAcc = new Account(Id = recId, IsReservePropertyConditions__c = spcReserved);
				updateAccMap.put(recId, updateAcc);
			}else{
				//予約物件条件
				AccountPropertyConditions__c updateApc = new AccountPropertyConditions__c(Id = recId, IsReservePropertyConditions__c = spcReserved);
				updateApcMap.put(recId, updateApc);
			}
		}

		if(!updateAccMap.isEmpty()){
			//楽観ロックチェックとして、最終更新日時がモーダルを開いたタイミング以前となる、IDが更新対象と一致する取引先の件数を取得
			List<Account> lockCheckAccList = new List<Account>();
			lockCheckAccList = [SELECT Id FROM Account WHERE SystemModstamp < :paremeter10.openModalDate AND Id IN :updateAccMap.keySet()];
			if(updateAccMap.size() != lockCheckAccList.size()){
				OptimisticLockException ex = new OptimisticLockException();
				throw ex;
			}
			SecureDML.secureUpdate(updateAccMap.values());
		}
		if(!updateApcMap.isEmpty()){
			//楽観ロックチェックとして、最終更新日時がモーダルを開いたタイミング以前となる、IDが更新対象と一致するお客様物件条件の件数を取得
			List<AccountPropertyConditions__c> lockCheckApcList = new List<AccountPropertyConditions__c>();
			lockCheckApcList = [SELECT Id FROM AccountPropertyConditions__c WHERE SystemModstamp < :paremeter10.openModalDate AND Id IN :updateApcMap.keySet()];
			if(updateApcMap.size() != lockCheckApcList.size()){
				OptimisticLockException ex = new OptimisticLockException();
				throw ex;
			}
			SecureDML.secureUpdate(updateApcMap.values());
		}
	}
	// ▲2021.10.08 No.307 対応で追加

    // ▼問合せ416で追加
    //お気に入り物件のリストをセット
    public void setFavoriteProperty(CorrespondDetail__c correspondDetail){
        this.screenFavoritePropertyList = new List<SelectOption>();

        // 更新時
        if(correspondDetail != null) {

            // 対応明細．お気に入り物件を設定（nullの場合は"--なし--"を表示）
            SelectOption inquiryPropOption = new SelectOption(commonConst.STRING_EMPTY
                                                              , commonConst.SELECTION_LIST_NULL);

            if (correspondDetail.InquiryProperty__c != null) {
                inquiryPropOption = new SelectOption(correspondDetail.Id
                                                     , correspondDetail.InquiryProperty__c);
            }

            this.screenFavoritePropertyList.add(inquiryPropOption);
            return;
        }
        
        // 新規登録時
        this.screenFavoritePropertyList.add(new SelectOption('', commonConst.SELECTION_LIST_NULL));
        List<FavoriteProperty__c> favoritePropertyList = [ SELECT id
                                                            ,Account__c                     //取引先
                                                            ,Property__c                    //物件id
                                                            ,Property__r.Building__c        //物件.建物ID
                                                            ,Property__r.Building__r.Name   //物件.建物.建物名
                                                            ,Property__r.Name               //物件.部屋番号
                                                          	,BuildingYM__c					//築年
                                                          FROM FavoriteProperty__c        
                                                          WHERE Account__c = :this.Correspond.AccountId__c
														  AND Property__c != null		//2022.01.12 No.489 物件idが存在すること
                                                          ORDER BY BuildingYM__c DESC              		// 築年
                                                          			,Property__r.Building__r.Name ASC   // 物件.建物.建物名
                                                          			, Property__r.Name ASC ];			//物件.部屋番号

        if (favoritePropertyList.size() > 0){

            // お問合せ物件（お気に入り物件.物件.建物.建物名 + ' ' + お気に入り物件.物件.物件名）
            String inquiryPropName;

            // 対応明細．お問合せ物件を設定 2021.09.24 No.489 valueをProperty__cに変更
            for(FavoriteProperty__c data:favoritePropertyList){
                inquiryPropName = data.Property__r.Building__r.Name + ' ' + data.Property__r.Name;
                this.screenFavoritePropertyList.add(new SelectOption(data.Property__c, inquiryPropName));
            }           
        }
    }
    // ▲問合せ416で追加

    /**
     * 楽観ロックチェック
     * 引数　　：　Correspond Correspond__c 対象の対応オブジェクト
     * 　　　　：  screenCorrespondDetail screenCorrespondDetail 対象の対応明細
     */
    private void OptimisticLockCheck(Correspond__c Correspond,screenCorrespondDetail screenCorrespondDetail,Account account){
        //楽観ロックチェックExceptionを発行(対応)
        List<Correspond__c> checkOptimisticLockExceptionRecord = new List<Correspond__c>();
        checkOptimisticLockExceptionRecord = [ SELECT id
                                                    FROM Correspond__c
                                                    WHERE id = :Correspond.Id
                                                    AND SystemModStamp = :Correspond.systemModStamp ];                //楽観ロックチェック
        if (checkOptimisticLockExceptionRecord.isEmpty()){
            OptimisticLockException ex = new OptimisticLockException();
            throw ex;
        }

        if (!insCorrespondDetailFlg){
            // 楽観ロックチェックExceptionを発行(対応明細)
            // 更新時のみ
            List<CorrespondDetail__c> checkOptimisticLockExceptionRecord2 = new List<CorrespondDetail__c>();
            
            checkOptimisticLockExceptionRecord2 = [ SELECT id
                                                        FROM CorrespondDetail__c
                                                        WHERE id = :screenCorrespondDetail.Id
                                                        AND SystemModStamp = :screenCorrespondDetail.systemModStamp ];                //楽観ロックチェック
            if (checkOptimisticLockExceptionRecord2.isEmpty()){
                OptimisticLockException ex = new OptimisticLockException();
                throw ex;
            }
        }
            }

    /**
     * 入力チェック
     * 引数　　：　CorrespondType string チェック対象ステータス
     * 戻り値　：  エラー有無
     */
     private BusinessLogicException inputCheck(String CorrespondType){
        BusinessLogicException inputCheckException = new BusinessLogicException();
        //必須入力チェック
        List<String> requiredItem = new List<String>();//入力チェックリストを初期化
		// ▼2022.01.27 No.307 対応で追加 他エラーメッセージ
		List<String> otherItem = new List<String>();
		// ▲2022.01.27 No.307 対応で追加

        // アポイント確定のみ入力チェック
        if (CorrespondType == TASK_CORRESPONDTYPE_APPOINTMENT){

            // 2020.09.24 ▼ 来店担当追加
            // 開始日時_年月日が入力されていない、開始日時_時分が入力されていない
            if (screenCorrespondDetail.StartDate == null || screenCorrespondDetail.StartDateTime == null) {
                requiredItem.add('開始日時' + STAFF_ONE_MSG);
            }
            // 終了日時_年月日が入力されていない、終了日時_時分が入力されていない
            if (screenCorrespondDetail.EndDate == null || screenCorrespondDetail.EndDateTime == null) {
                requiredItem.add('終了日時' + STAFF_ONE_MSG);
            }

            // 担当者が「2名」を選択時
            if (staffCountValue == STAFF_TWO){
                // 開始日時_年月日が入力されていない、開始日時_時分が入力されていない
                if (screenCorrespondDetail.StartDate2 == null || screenCorrespondDetail.StartDateTime2 == null) {
                    requiredItem.add('開始日時' + STAFF_TWO_MSG);
                }
                // 終了日時_年月日が入力されていない、終了日時_時分が入力されていない
                if (screenCorrespondDetail.EndDate2 == null || screenCorrespondDetail.EndDateTime2 == null) {
                    requiredItem.add('終了日時' + STAFF_TWO_MSG);
                }
            }

            // 案内方法が入力されていない
            if (String.isBlank(this.screenCorrespondDetail.GuidanceMethod)) {
                requiredItem.add('案内方法');
            }

            // エラーが無ければチェックする
            if(requiredItem.size() == 0){

                Datetime startDateTime1 = Datetime.newInstance(screenCorrespondDetail.StartDate , screenCorrespondDetail.StartDateTime);
                Datetime endDateTime1   = Datetime.newInstance(screenCorrespondDetail.EndDate ,screenCorrespondDetail.EndDateTime);
                Datetime startDateTime2;
                Datetime endDateTime2;

                if( endDateTime1 < startDateTime1){
                    //終了日に開始日より前の日付が設定されています。終了日は開始日以降を設定してください。
                    inputCheckException.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_DATE_TERM) + STAFF_ONE_MSG);
                }

                // 担当者が「2名」を選択時
                if (staffCountValue == STAFF_TWO){

                    startDateTime2 = Datetime.newInstance(screenCorrespondDetail.StartDate2 , screenCorrespondDetail.StartDateTime2);
                    endDateTime2   = Datetime.newInstance(screenCorrespondDetail.EndDate2 ,screenCorrespondDetail.EndDateTime2);
    
                    if( endDateTime2 < startDateTime2){
                        //終了日に開始日より前の日付が設定されています。終了日は開始日以降を設定してください。
                        inputCheckException.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_DATE_TERM) + STAFF_TWO_MSG);
                    }

                    if ((StartDateTime1 <= StartDateTime2 && EndDateTime1 > StartDateTime2) || (StartDateTime1 < EndDateTime2 && EndDateTime1 >= EndDateTime2)){
                        //担当者１と担当者２の時間が重複している場合
                        inputCheckException.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_CUST_E_REGISTRATION_TIME_DUPLICATE ,STAFF_ONE_MSG , STAFF_TWO_MSG)); 
                    }
                }
            }
                
            // 有効なユーザでアポ確できるか判定
            if(!userIsActive(screenCorrespondDetail.ShopStaff)){
                inputCheckException.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_USER_DISABLED_APPOINTMENTS) + STAFF_ONE_MSG);
            }
            // 担当者が「2名」を選択時
            if (staffCountValue == STAFF_TWO){
                if(!userIsActive(screenCorrespondDetail.ShopStaff2)){
                    inputCheckException.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_USER_DISABLED_APPOINTMENTS) + STAFF_TWO_MSG);
                }                    
            }
        }

        // 追客保留時にチェック
        if (CorrespondType == TASK_CORRESPONDTYPE_PURSUITHOLD){
            // ▼問合せNo295で追加
            // 表題が入力されていない
            if (String.isBlank(screenCorrespondDetail.SupportedTitle)) {
                requiredItem.add('表題');
            }

            // 保留理由が入力されていない
            if (String.isBlank(screenCorrespondDetail.SupportedContent)) {
                requiredItem.add('保留理由');
            }
            // ▲問合せNo295で追加
            // 開始日時_年月日が入力されていない、開始日時_時分が入力されていない
            if (screenCorrespondDetail.PursuitDissolveDate == null || screenCorrespondDetail.PursuitDissolveTime == null) {
                requiredItem.add('追客解除日');
            }
			// ▼2022.01.27 No.307 対応で追加 条件完全一致予約が「はい」かつ、予約物件条件が1件も選択されない
			if (CommonConst.CORRESPOND_EXACT_CONDITION_MATCH_EXISTS.equals(screenCorrespondDetail.ExactConditionMatch)
			&& (Parameter.GA102001Paremeter10.spcReservedList.contains(TRUE) == false)
			// ▼2022.02.16 No.307 取引先以外の物件条件がない場合は予約物件条件モーダルを表示しないためエラーとしない
			&& (Parameter.GA102001Paremeter10.spcIndexList.size() != 1)){
			// ▲2022.02.16 No.307 対応で追加
				//条件一致予約する際は予約物件条件を選択してください。
				otherItem.add(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SELECTION, '条件完全一致予約する際', '予約物件条件'));
			}
			// ▲2022.01.27 No.307 対応で追加
        }

        // ▼問合せNo295で追加
        //アポキャンセル時にチェック
        if(CorrespondType == TASK_CORRESPONDTYPE_APO_CANCEL){
            // アポキャンセル理由の入力がない
            if (String.isBlank(screenCorrespondDetail.SupportedTitle) ){
                requiredItem.add('アポキャンセル理由');
            }

            // 対応内容の入力がない
            if (String.isBlank(screenCorrespondDetail.SupportedContent) && screenCorrespondDetail.SupportedTitle != '他決'){
                requiredItem.add('対応内容');
            }
            
            // 物件確認及び提案内容の入力がない
            if (String.isBlank(screenCorrespondDetail.SupportedContent) && screenCorrespondDetail.SupportedTitle == '他決'){
                requiredItem.add('物件確認及び提案内容');
            }
        }

        // 終了時にチェック
        if(CorrespondType == TASK_CORRESPONDTYPE_CLOSE){
            // 状況の入力が無い
            if (String.isBlank(screenCorrespondDetail.PhoneStatus) ){
                requiredItem.add('状況');
            }

            // 終了理由の入力が無い
            if (String.isBlank(screenCorrespondDetail.SupportedContent) ){
                requiredItem.add('終了理由');
            }
        }
        // ▲問合せNo295で追加
         
        // 電話時にチェック
        if (this.isModalTelStatus()){
            // 状況の入力が無い
            if (String.isBlank(screenCorrespondDetail.PhoneStatus) ){
                requiredItem.add('状況');
            }

            // 2020/6/25変更：反響系（電話/LINE/Livero）以外で対応内容の入力が無い
            if (!isEcho && String.isBlank(screenCorrespondDetail.SupportedContent)){
                requiredItem.add('対応内容');
            }

            // 2020/6/25変更：反響系（電話/LINE/Livero）でポータルサイトの入力が無い。
            if (isEcho && String.isBlank(screenCorrespondDetail.PortalSite)){
                requiredItem.add('ポータルサイト');
            }

            // 2020/6/25変更：反響系（電話/LINE/Livero）で地区の入力が無い
            if (isEcho && String.isBlank(screenCorrespondDetail.District)){
                requiredItem.add('地区');
            }
            // ▼問合せNo341で追加　担当者が選択されており、電話反響アラート(Attention)が表示されている場合
            if (screenCorrespondDetail.Sender == CommonConst.CORRESPONDDETAIL_SENDER_STAFF && Correspond.Status__c == CommonConst.CORRESPOND_STATUS_NOTSUPPORTED && !this.account.EchoTelephoneFlag__c && this.account.Situation__c == CommonConst.CORRESPONDDETAIL_PHONESTATUS_ECHO){
                inputCheckException.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_ACC_W_TEL_SENDER));
            }
            // ▲問合せNo341で追加
            // ▼問合せNo411で追加　担当者が選択されており、Livero反響アラート(Attention)、LINE反響アラート(Attention)が表示されている場合
            if (screenCorrespondDetail.Sender == CommonConst.CORRESPONDDETAIL_SENDER_STAFF && Correspond.Status__c == CommonConst.CORRESPOND_STATUS_NOTSUPPORTED && !this.account.EchoLiveroFlag__c && this.account.Situation__c == CommonConst.CORRESPONDDETAIL_PHONESTATUS_LIVEROECHO){
                inputCheckException.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_ACC_W_LIVERO_SENDER));
            }
            if (screenCorrespondDetail.Sender == CommonConst.CORRESPONDDETAIL_SENDER_STAFF && Correspond.Status__c == CommonConst.CORRESPOND_STATUS_NOTSUPPORTED && !this.account.EchoLineFlag__c && this.account.Situation__c == CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINEECHO){
                inputCheckException.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_ACC_W_LINE_SENDER));
            }
            // ▲問合せNo411で追加
        }
        if (!requiredItem.isEmpty()){//入力チェック用リストが空ではない場合、エラー追加                
            inputCheckException.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED,String.join(requiredItem, ',')));
        }

		// ▼2022.01.27 No.307 対応で追加 
		if (!otherItem.isEmpty()){//他エラーメッセージリストが空ではない場合、エラー追加
			for(String other: otherItem){
				inputCheckException.addMessage(other);
			}
        }
		// ▲2022.01.27 No.307 対応で追加 

        return inputCheckException;
     }

    /**
     * 時分が日付として認識できるか判定（時分は文字列です）
     * 引数　　：  DetermineTime String 時分
     * 戻り値　：  変更可否
     */
    private Boolean isTime(String DetermineTime){

        try{
            // 日付となる用に年月日を固定で設定（文字列）
            Datetime.parse('2020/01/01 ' + DetermineTime);
        }catch(Exception e){
            // 変換不可
            return false;
        }
        // 変換可
        return true;
        
    }

    /**
     * ユーザの有効チェック
     * 引数　　：  userId String 対象のユーザ
     * 戻り値　：  有効かどうか
     */
    private Boolean userIsActive(String userId){
        // 検索SQL作成
        String sql = '';
        sql += ' SELECT Id ';                                   // ID
        sql += ' FROM  User ';                                  // ユーザ
        sql += ' WHERE IsActive = true ';//有効
        sql += ' AND id = :userId'; //ユーザId

        // 検索実行＆結果返却
        list<User> userList =  Database.query(sql);

        if (userList.size() > 0){
            // 件数が取れたら有効
            return true;
        }
        // 取れなければ無効
        return false;

    }

    /**
     * 対応内容を対応種別等の状態によって内容を変化する
     * 引数　　：  screenCorrespondDetail 表示項目
     * 　　　　：  
     * 戻り値　：  対応内容
     */
    private String setSupportedContent(screenCorrespondDetail screenCorrespondDetail){
        // 
        string SupportedContent = '';
        if (screenCorrespondDetail.CorrespondType == TASK_CORRESPONDTYPE_APPOINTMENT){
            // アポイント確定
            // ”スケジュール”
            // ”開始時間：”　&　開始日時
            // "終了時間："　＆　終了日時
            // ”案内方法：”　＆　{!画面.案内方法}
            // ”内容：”　＆　{!画面.対応内容}
            SupportedContent += 'スケジュール' + commonconst.BREAK_CODE;
            // 2020.09.24 ▼ 来店担当追加
            SupportedContent += STAFF_ONE_MSG + commonconst.BREAK_CODE;
            SupportedContent += '来店店舗：' + getSelectOptionLabel(selectVisitShop1List, screenCorrespondDetail.VisitShop) + commonconst.BREAK_CODE; 
            SupportedContent += '来店担当：' + getSelectOptionLabel(selectShopStaff1List, screenCorrespondDetail.ShopStaff) + commonconst.BREAK_CODE; 
            SupportedContent += '開始時間：' + Datetime.newInstance(screenCorrespondDetail.StartDate , screenCorrespondDetail.StartDateTime).format('yyyy/MM/dd HH:mm') + commonconst.BREAK_CODE;
            SupportedContent += '終了時間：' + Datetime.newInstance(screenCorrespondDetail.EndDate , screenCorrespondDetail.EndDateTime).format('yyyy/MM/dd HH:mm') + commonconst.BREAK_CODE;
            if (staffCountValue == STAFF_TWO){
                SupportedContent += commonconst.BREAK_CODE;
                SupportedContent += STAFF_TWO_MSG + commonconst.BREAK_CODE;
                SupportedContent += '来店店舗：' + getSelectOptionLabel(selectVisitShop2List, screenCorrespondDetail.VisitShop2) + commonconst.BREAK_CODE; 
                SupportedContent += '来店担当：' + getSelectOptionLabel(selectShopStaff2List, screenCorrespondDetail.ShopStaff2) + commonconst.BREAK_CODE; 
                SupportedContent += '開始時間：' + Datetime.newInstance(screenCorrespondDetail.StartDate2 , screenCorrespondDetail.StartDateTime2).format('yyyy/MM/dd HH:mm') + commonconst.BREAK_CODE;
                SupportedContent += '終了時間：' + Datetime.newInstance(screenCorrespondDetail.EndDate2 , screenCorrespondDetail.EndDateTime2).format('yyyy/MM/dd HH:mm') + commonconst.BREAK_CODE;
                SupportedContent += commonconst.BREAK_CODE;
            }
            SupportedContent += '案内方法：' + screenCorrespondDetail.GuidanceMethod  + commonconst.BREAK_CODE;
            SupportedContent += '内容：' + screenCorrespondDetail.SupportedContent ;
        
        }else if (screenCorrespondDetail.CorrespondType == TASK_CORRESPONDTYPE_PURSUITHOLD){
            //2020/7/1追加：追客保留中
            // ”スケジュール” 
            // "追客解除日："　＆　画面.追客解除日
            // ”条件完全一致 :” ＆　画面.条件完全一致 ＆ 改行
            // ”物件条件名 :” ＆　画面.予約物件条件にて選択された物件条件名を'、'区切り ＆ 改行	※条件完全一致が'する'の場合のみ
            // ”内容：”　＆　{!画面.対応内容}
            SupportedContent += 'スケジュール' + commonconst.BREAK_CODE;
            SupportedContent += '追客解除日：' + Datetime.newInstance(screenCorrespondDetail.PursuitDissolveDate , screenCorrespondDetail.PursuitDissolveTime).format('yyyy/MM/dd HH:mm') + commonconst.BREAK_CODE;
            SupportedContent += '条件完全一致：' + screenCorrespondDetail.ExactConditionMatch + commonconst.BREAK_CODE;

			// ▼2022.02.10 No.710 対応で物件条件名追加
			//条件完全一致が'する'の場合のみ物件条件名を追加する
			if(CommonConst.CORRESPOND_EXACT_CONDITION_MATCH_EXISTS.equals(screenCorrespondDetail.ExactConditionMatch)){
				GA102001Modal10ParameterClass paremeter10 = Parameter.GA102001Paremeter10;//予約物件条件モーダルパラメータ
				List<String> propCondList = new List<String>();//物件条件名リスト
				for(Integer spcIndex: paremeter10.spcIndexList){
					//予約物件条件モーダルでチェックされた物件条件名をリストに追加
					if(paremeter10.spcReservedList[spcIndex]){
						propCondList.add(paremeter10.spcNameList[spcIndex]);
					}
				}
				SupportedContent += '物件条件名：' + String.join(propCondList, '、') + commonconst.BREAK_CODE;
			}
			// ▲2022.02.10 No.710 対応で物件条件名追加

            SupportedContent += '内容：' + screenCorrespondDetail.SupportedContent ;
            
        }else{
            // 電話、メモ、来店後検討、追客保留、アポイントキャンセル、申込キャンセル、契約完了、終了は入力の内容をそのまま返す。
            SupportedContent = screenCorrespondDetail.SupportedContent;
        }

        return SupportedContent;
    }

    /**
     * スタッフ対応フラグ判定
     * 引数　　：  Correspond Correspond__c 対応情報
     *        ：  CorrespondType String 対応種別
     *        ：  Status String ステータス
     * 戻り値　：  True:担当スタッフ/False:他スタッフ
     */
    private boolean setStaffSupportedFlg(Correspond__c Correspond,String CorrespondType,String Status){
        Boolean setflg = true;
        if (this.isModalTelStatus() || 
            CorrespondType == CommonConst.TASK_CORRESPONDTYPE_APPOINTMENT ||
            CorrespondType == CommonConst.TASK_CORRESPONDTYPE_PURSUITHOLD ||
            CorrespondType == CommonConst.TASK_CORRESPONDTYPE_MEMO ||
            CorrespondType == CommonConst.TASK_CORRESPONDTYPE_APO_CANCEL ||
            Status == CommonConst.CORRESPOND_STATUS_PURSUITHOLD ||
            Status == CommonConst.CORRESPOND_STATUS_CLOSE ||
            Status == CommonConst.CORRESPOND_STATUS_APOCANCEL ){
            // TEL、アポイント確定、追客保留、アポイントキャンセル、終了の場合  

            // ログインユーザーと反響担当者もしくは、来店担当者とが一致しなければ：False、以外はTreu
            if (Correspond.EchoStaff__c == this.loginStaff || Correspond.ShopStaff__c == this.loginStaff){
                setflg = true;
            }else {
                setflg = false;
            }

        }else if(CorrespondType == CommonConst.CORRESPOND_STATUS_CONSIDERVISITING || 
                 Status == CommonConst.CORRESPOND_STATUS_APPLCANCEL ||
                 Status == CommonConst.CORRESPOND_STATUS_AGREEMENT ){
            // 来店後検討、申込キャンセル、契約完了の場合

            // ログインユーザーと来店担当者が一致しなければ：False、一致はTrue
            if (Correspond.ShopStaff__c == this.loginStaff){
                setflg = true;
            }else {
                setflg = false;
            }
        }

        return setflg;
    }

    /**
     * ポータルサイトURL取得
     * 引数　　：  PortalSiteId string ポータルサイトID
     * 戻り値　：  ポータルサイトURL
     */
    private String setPortalSiteUrl(String PortalSiteId){
                
        List<PortalSite__c> PortalSite = new List<PortalSite__c>();
        PortalSite = [ SELECT id,URL__c
                        FROM PortalSite__c
                        WHERE id = :PortalSiteId];
        if (PortalSite.size() > 0){
            return PortalSite[0].URL__c;
        }
        return '';
    }

    /**
     * 登録処理(対応)
     * 引数　　：  Id String 対応ID
     * 　　　　：  Correspond Correspond__c 対応データ
     * 戻り値　：  String 対応Id
     */
    private string saveCorrespond(String Id,Correspond__c Correspond){
        // 保存処理
        Correspond__c saveData = new Correspond__c();

        // 終了時の新規登録フラグ
        Boolean insCorrespondFlgTel = false;    // 電話

        Date today = CommonUtil.getToday(); //本日日付取得      // ポータルサイト構築 追加
        //2020/6/10変更 6/25変更：ステータスが終了/契約完了 で 反響フラグがtrue（電話反響/LIINE反響/Livero反響のどれか）のときのみに新規で対応を登録する。
        if((Correspond.Status__c == CommonConst.CORRESPOND_STATUS_CLOSE || 
            Correspond.Status__c == CommonConst.CORRESPOND_STATUS_AGREEMENT ) && 
           screenCorrespondDetail.CorrespondType == CommonConst.TASK_CORRESPONDTYPE_TEL && 
           isEcho && 
           !string.isBlank(screenCorrespondDetail.PortalSite)){
            // 対応新規作成フラグ
            insCorrespondFlgTel = true;
        }else{
            // 更新によりIDをセット
            saveData.Id = Id;
        }
        
        // 保存項目
        // メモ出力
        
        //2020/6/10変更：対応種別が電話の場合、対応のメモに「発信者」　＋　' から '　＋　「状況」を設定
        if(this.isModalTelStatus()){
            saveData.Memo__c = screenCorrespondDetail.Sender + ' から ' + screenCorrespondDetail.PhoneStatus;// メモ

        //対応種別が電話以外の場合、対応のメモに表題を設定する    
        }else{
            saveData.Memo__c = screenCorrespondDetail.SupportedTitle;    // メモ
        }

        if (insCorrespondDetailFlg){
            // 登録時のみ
            // イベント時刻
            saveData.EventDateTime__c = CommonUtil.getNow();// イベント時刻		
            
            // 対応確認フラグ
            if(screenCorrespondDetail.CorrespondType == CommonConst.TASK_CORRESPONDTYPE_MEMO ){
                // 対応種別がメモであった場合の登録
                // 変更しない
            }else if(Parameter.CorrespondType == TASK_CORRESPONDTYPE_TEL || 
                    Parameter.Status == CommonConst.CORRESPOND_STATUS_AGREEMENT ||
                    Parameter.Status == CommonConst.CORRESPOND_STATUS_PURSUITHOLD ||
                    Parameter.Status == CommonConst.CORRESPOND_STATUS_CLOSE ) {
                // 電話、契約完了、追客保留、終了は対応確認フラグをtrue
                saveData.IsSupportedListShow__c = true;
            }else{
                saveData.IsSupportedListShow__c = false;
            }

            // スタッフ対応フラグ
            if(insCorrespondFlgTel){
                // 終了系からの電話対応時には対応フラグを初期値(true)で判断する。
            }else{
                saveData.StaffSupportedFlg__c = setStaffSupportedFlg(Correspond,Parameter.CorrespondType,Parameter.Status);  
            }


            // 閲覧フラグを状況が終了時trueとする。
            if(Parameter.Status == CommonConst.CORRESPOND_STATUS_CLOSE){
                saveData.IsBrowseFlg__c = true; 
            }else{
                // 終了以外の場合でも　対応種別が電話、契約完了、追客保留である場合、閲覧フラグを立てる
                if(Parameter.CorrespondType == TASK_CORRESPONDTYPE_TEL ||
                    Parameter.Status == CommonConst.CORRESPOND_STATUS_AGREEMENT ||
                    Parameter.Status == CommonConst.CORRESPOND_STATUS_PURSUITHOLD ){
                    saveData.IsBrowseFlg__c = true;
                }
            }
                               
            // 追客解除日はどちらかの日付が入っている状態で登録が可能
            if (screenCorrespondDetail.PursuitDissolveDate != null && screenCorrespondDetail.PursuitDissolveTime != null){
                // GMT標準となっているため時間の補正を行い登録
                Datetime PursuitDissolveDate = datetime.newInstance(screenCorrespondDetail.PursuitDissolveDate,screenCorrespondDetail.PursuitDissolveTime);
                saveData.PursuitDissolveDate__c = PursuitDissolveDate ;// 追客解除日	
                saveData.PursuitDissolveSettingDate__c = PursuitDissolveDate;// 追客解除設定日時															
            }
            
            // 申込キャンセルでは再度申込を可能とするため、申込と物件を空の状態にする。
            if (Parameter.Status == CommonConst.CORRESPOND_STATUS_APPLCANCEL){
                saveData.Application__c = null;// 申込		
                saveData.Property__c    = null;// 物件
            }        

            //対応種別の状態によりステータスを登録する。
            if (Parameter.CorrespondType == TASK_CORRESPONDTYPE_MEMO ){
                // メモであった場合は変更しない
            }else if(Parameter.CorrespondType == TASK_CORRESPONDTYPE_TEL){
                // 電話は以下の状態で変更する。
			
                //2020/6/10変更：ステータスが未対応
                if (Correspond.Status__c == CommonConst.CORRESPOND_STATUS_NOTSUPPORTED){
                    //発信者が担当者の場合　追客中
                    if (screenCorrespondDetail.Sender == CommonConst.CORRESPONDDETAIL_SENDER_STAFF){
                        saveData.Status__c = CommonConst.CORRESPOND_STATUS_PURSUIT;
                    }
                    
                //2020/6/16追加：ステータスが追客保留中
                }else if (Correspond.Status__c == CommonConst.CORRESPOND_STATUS_PURSUITHOLD){   
                    //発信者が担当者の場合、保留前ステータスの値からステータスを設定
                    if (screenCorrespondDetail.Sender == CommonConst.CORRESPONDDETAIL_SENDER_STAFF){
                        saveData.Status__c = CustomerUtil.changeStatusToStatusBeforePursuitHold(this.Correspond.StatusBeforePursuitHold__c);
                    }           
                    
                //2020/6/10変更：ステータスがアポイントキャンセル
                }else if(Correspond.Status__c == CommonConst.CORRESPOND_STATUS_APOCANCEL){
                    //発信者が担当者の場合　アポキャンセル後追客中
                    if (screenCorrespondDetail.Sender == CommonConst.CORRESPONDDETAIL_SENDER_STAFF){
                        saveData.Status__c = CommonConst.CORRESPOND_STATUS_APOCANCEL_PURSUIT;
                        
                    }

                //2020/6/10変更：ステータスが申込キャンセル
                }else if(Correspond.Status__c == CommonConst.CORRESPOND_STATUS_APPLCANCEL){
                    //発信者が担当者の場合　申込キャンセル後追客中
                    if (screenCorrespondDetail.Sender == CommonConst.CORRESPONDDETAIL_SENDER_STAFF){
                        saveData.Status__c = CommonConst.CORRESPOND_STATUS_APPLCANCEL_PURSUIT;

                    }

                //2020/6/10変更：ステータスが来店後検討
                }else if(Correspond.Status__c == CommonConst.CORRESPOND_STATUS_CONSIDERVISITING){
                    //発信者が担当者の場合　来店後追客中
                    if (screenCorrespondDetail.Sender == CommonConst.CORRESPONDDETAIL_SENDER_STAFF){
                        saveData.Status__c = CommonConst.CORRESPOND_STATUS_VISITED_PURSUIT;

                    }

                //2020/6/10追加：ステータスが終了
                }else if (Correspond.Status__c == CommonConst.CORRESPOND_STATUS_CLOSE){
                    //発信者が担当者の場合　追客中
                    if (screenCorrespondDetail.Sender == CommonConst.CORRESPONDDETAIL_SENDER_STAFF){
                        saveData.Status__c = CommonConst.CORRESPOND_STATUS_PURSUIT;
                    
                    //対応新規登録フラグがtrue（電話/LINE/Livero反響）の場合　未対応
                    }else if (insCorrespondFlgTel){
                        saveData.Status__c = CommonConst.CORRESPOND_STATUS_NOTSUPPORTED;
                    }

                //2020/6/10追加：ステータスが契約完了  
                }else if (Correspond.Status__c == CommonConst.CORRESPOND_STATUS_AGREEMENT){
                    //対応新規登録フラグがtrue（電話/LINE/Livero反響）の場合　未対応
                    if (insCorrespondFlgTel){
                        saveData.Status__c = CommonConst.CORRESPOND_STATUS_NOTSUPPORTED;
                    }         
                }
            }else{
                // 上記以外は普通にセットする。
                saveData.Status__c = Parameter.Status;
            }
                    
            //対応種別ごとに設定する項目
            // 電話でのみ設定
            if (Parameter.CorrespondType == TASK_CORRESPONDTYPE_TEL){//電話による設定
                // ポータルサイト

                if (isEcho && (String.isBlank(this.Correspond.PortalSite__c) || insCorrespondFlgTel)){
                    // ポータルサイトが設定されている場合のみ設定する。
                    saveData.PortalSite__c  = screenCorrespondDetail.PortalSite;                        // ポータルサイト
                    saveData.PortalSiteUrl__c = setPortalSiteUrl(screenCorrespondDetail.PortalSite);    // ポータルサイトURL
                }

                // メール受信日時（ポータル）
                if (isEcho && (this.Correspond.ReceiveMailDatePortal__c == null || insCorrespondFlgTel )){
                    // 2020/6/10変更 6/25変更：反響フラグがtrue（状況が電話/LINE/Livero反響）であり、メール受信日時（ポータル）の項目が空の場合か新規で対応が作成される場合に入れるようにする（本来のメール受信日時を上書きしてしまうから）
                    // メール受信のポータルをセットする。
                    saveData.ReceiveMailDatePortal__c = commonUtil.getNow().addSeconds(-1);    
                }

                // 初回問い合せ手段
                if (isEcho && (String.isBlank(this.Correspond.FirstInquiryMeans__c) || insCorrespondFlgTel )){
                    // 2020/6/10変更 6/25変更：反響フラグがtrueであり、対応の項目が空の場合か新規で対応が作成される場合に入れるようにする（上書きしてしまうから）
                    
                    //電話状況が電話反響
                    if (screenCorrespondDetail.PhoneStatus == CommonConst.CORRESPONDDETAIL_PHONESTATUS_ECHO){
                        saveData.FirstInquiryMeans__c = CommonConst.FIRSTINQUIRYMEANS_PHONE;//電話

                    //電話状況がLINE反響
                    }else if (screenCorrespondDetail.PhoneStatus == CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINEECHO){
                        saveData.FirstInquiryMeans__c = CommonConst.FIRSTINQUIRYMEANS_LINE; //LINE
                    
                    //電話状況がLivero反響
                    }else if (screenCorrespondDetail.PhoneStatus == CommonConst.CORRESPONDDETAIL_PHONESTATUS_LIVEROECHO){
                        saveData.FirstInquiryMeans__c = CommonConst.FIRSTINQUIRYMEANS_MAIL; //メール
                    }
                }

                //2020/6/10変更：電話日時
                //発信者がお客様
                if (screenCorrespondDetail.Sender == CommonConst.CORRESPONDDETAIL_SENDER_CUSTOMER){
                    //状況がLivero反響でない場合のみ、電話着信日時に時間を入れる
                    if (screenCorrespondDetail.PhoneStatus != CommonConst.CORRESPONDDETAIL_PHONESTATUS_LIVEROECHO){
                        saveData.PhoneIncomingDate__c = commonUtil.getNow();
                    }

                //発信者が担当者
                }else{
                    // "SMS送信"、"LINE送信"の場合、LINE・SMS送信日時を更新
                    if (screenCorrespondDetail.PhoneStatus == CommonConst.CORRESPONDDETAIL_PHONESTATUS_SEND_SMS
                        || screenCorrespondDetail.PhoneStatus == CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINESEND) {
                        saveData.LineSmsSendDate__c = commonUtil.getNow();
                    //状況が、電話連絡(繋がらない)の場合、電話不在日時に時間を入れる
                    }else if (screenCorrespondDetail.PhoneStatus == CommonConst.CORRESPONDDETAIL_PHONESTATUS_NOCONTACT){
                        saveData.PhoneAbsenceDate__c = commonUtil.getNow();
                    // "電話連絡(繋がった)"場合、電話発信日時を更新
                    } else {
                        saveData.PhoneOutgoingDate__c = commonUtil.getNow();
                    }
                }

                // 地区の設定（電話のみ）
                if (isEcho && (String.isBlank(this.Correspond.District__c) || insCorrespondFlgTel)){
                    // 2020/6/10追加 2020/6/25変更：反響系（電話/LINE/Livero反響）かつ変更前の対応の地区が設定されていないもしくは新規で対応が作成されるときのみ、地区を設定する
                    saveData.District__c = screenCorrespondDetail.District;
                }

                //2020/6/15追加：対応明細の発信者がお客様の場合、追客解除設定日時をnullに変更
                if (screenCorrespondDetail.Sender == CommonConst.CORRESPONDDETAIL_SENDER_CUSTOMER){
                    //追客解除設定日時をnullに更新する
                    saveData.PursuitDissolveSettingDate__c = null;
                }

                //▼ 2021.09.24 No.489 対応の初回問合せ物件が登録されていない場合
                if(Correspond.FirstInquiryProperty__c == null) {
                    // 選択されたお問合せ物件を取得
                    String inquiryProp = screenCorrespondDetail.SelectedInquiryProp;
                    // 取得できた場合
                    if(String.isNotBlank(inquiryProp)) {
                        saveData.FirstInquiryProperty__c = inquiryProp;
                        this.inquiryPropId = inquiryProp;
                    // 反響一覧登録フラグを立てる
                    this.echoInsertFlg = true;
                    Parameter.echoInsertFlg = this.echoInsertFlg;
					}
				}
                //▲ 2021.09.24 No.489

            //2020/7/13追加：アポイント確定でのみ設定
            }else if (Parameter.CorrespondType == TASK_CORRESPONDTYPE_APPOINTMENT){//アポイント確定でのみ設定
                //アポイント開始日0時を画面の開始日に設定
                Time zeroTime = Time.newInstance(0, 0, 0, 0);
                saveData.AppointmentStartDate__c = Datetime.newInstance(screenCorrespondDetail.StartDate,zeroTime);
                
                //行動Id__cを設定
                saveData.EventId__c = selectedEvent.Id;
                // 2020.09.24 ▼ 来店担当追加
                if (staffCountValue == STAFF_TWO){
                    saveData.EventId2__c = selectedEvent2.Id;
                }

                //来店担当が２名⇒１名になった場合、担当者２の行動IDを削除
                if (Correspond.EventId2__c != null && staffCountValue == STAFF_ONE){
                    saveData.EventId2__c = null;
                }                
                // 2020.09.24 ▲ 来店担当追加

                // ポータルサイト構築 追加 Start
                saveData.AppointmentReceiptNoMaintenance__c = false;        // 来店受付メンテ不要をFalseにする。
                // ポータルサイト構築 追加 End

                //初回行動Idがnullの場合、初回案内方法と初回行動Idを更新
                if(string.isBlank(this.Correspond.FirstEventId__c)){
                    saveData.FirstGuidanceMethod__c = this.screenCorrespondDetail.GuidanceMethod; //初回案内方法
                    saveData.FirstEventId__c = selectedEvent.Id; //初回行動Id
                }   
                //アポイント変更でのみ設定
                if(Correspond.Status__c == CommonConst.CORRESPOND_STATUS_APPOINTMENT){
                    //初回のアポイント確定が変更された場合、初回案内方法を更新
                    if (this.Correspond.EventId__c == this.Correspond.FirstEventId__c){
                        saveData.FirstGuidanceMethod__c = this.screenCorrespondDetail.GuidanceMethod; //初回案内方法
                    }
                }
            //2020/7/13追加：キャンセル（アポキャンセル）でのみ設定
            }else if ( Parameter.CorrespondType == TASK_CORRESPONDTYPE_APO_CANCEL){//キャンセル（アポキャンセル）でのみ設定
                //アポイント開始日0時をnullに設定
                saveData.AppointmentStartDate__c = null;

                //初回のアポイント確定がキャンセルされた場合、初回案内方法と初回行動idをnullで更新
                if (this.Correspond.EventId__c == this.Correspond.FirstEventId__c){
                    saveData.FirstGuidanceMethod__c = null; //初回案内方法
                    saveData.FirstEventId__c = null; //初回行動Id
                }

                // 2020.09.24 ▼ 来店担当追加
                // 行動IDをクリア
                saveData.EventId__c = null;
                saveData.EventId2__c = null;
                // 2020.09.24 ▲ 来店担当追加

                // ポータルサイト構築 追加 Start
                if (Correspond.VisitReservationFlag__c && AuthorityCheckUtil.getAuthorityOptionPortal(false)) {
                    // "来店予約フラグ=Trueの場合、True
                    saveData.FirstVisitReservationCancelFlg__c = true;
                    // "来店予約フラグ=Trueの場合、システム日付（日時）
                    saveData.VisitReservationCancelDate__c = today;
                }

                saveData.AppointmentReceiptNoMaintenance__c = false;        // 来店受付メンテ不要をFalseにする。
                // ポータルサイト構築 追加 End   
            }

            //2020/6/15追加：追客解除設定日時、追客解除設定日時（保存用）設定
            //対応種別が電話かつ発信者が担当者 または 対応種別がアポイント確定 または 対応種別が終了 の場合
            if ((Parameter.CorrespondType == TASK_CORRESPONDTYPE_TEL && screenCorrespondDetail.Sender == CommonConst.CORRESPONDDETAIL_SENDER_STAFF) ||
                 Parameter.CorrespondType == TASK_CORRESPONDTYPE_APPOINTMENT || 
                 Parameter.CorrespondType == TASK_CORRESPONDTYPE_CLOSE){
                //追客解除設定日時、追客解除設定日時（保存用）をnullに更新
                saveData.PursuitDissolveSettingDate__c = null;          //追客解除設定日時
                saveData.PursuitDissolveDate__c = null;                 //追客解除設定日時（保存用）
            }

            //2020/6/19追加：追客保留前ステータス
            //終了モード
            if (Parameter.CorrespondType == TASK_CORRESPONDTYPE_CLOSE){
                saveData.StatusBeforePursuitHold__c = null;

            //電話モード
            }else if (Parameter.CorrespondType == TASK_CORRESPONDTYPE_TEL){
                //ステータスが追客保留中　かつ　担当者から電話を掛けたときのみ
                if (Correspond.Status__c == CommonConst.CORRESPOND_STATUS_PURSUITHOLD
                 && screenCorrespondDetail.Sender == CommonConst.CORRESPONDDETAIL_SENDER_STAFF){
                    saveData.StatusBeforePursuitHold__c = null;
                }

            //追客保留モード
            }else if (Parameter.CorrespondType == CommonConst.TASK_CORRESPONDTYPE_PURSUITHOLD){        
                //追客保留モードの場合、現ステータスを保留前ステータスに値を保持 
                saveData.StatusBeforePursuitHold__c = this.Correspond.Status__c;
            }

            // 対応種別「契約完了」「終了」の場合
            if(Parameter.CorrespondType == CommonConst.TASK_CORRESPONDTYPE_ENDCONTRACT || Parameter.CorrespondType == TASK_CORRESPONDTYPE_CLOSE){
				// 一覧表示日時は/対応種別「契約完了」「終了」では最終日付を入れる                
                saveData.ListViewDate__c = CommonConst.LAST_DATE;
            	//問合せ397で変更
            	// 終了日時は/対応種別「契約完了」「終了」では現在日時を入れる  
                saveData.EndDate__c = CommonUtil.getNow();

            }else if(Parameter.CorrespondType == TASK_CORRESPONDTYPE_TEL){
                //2020/7/13変更：対応種別「電話」では　対応確認を兼ねた一覧表示日時取得
                //変更後の引数になる項目を取得
                //ステータス
                String parmStatus = (String.isNotBlank(saveData.Status__c)) ? (saveData.Status__c) : (this.correspond.Status__c);//変更あればそっちに
                //追客解除設定日時（保存）
                Datetime parmPursuitDissolveDate;
                if (screenCorrespondDetail.Sender == CommonConst.CORRESPONDDETAIL_SENDER_STAFF){//電話モーダルでは担当から電話をかけたときにnullに変更されている
                    parmPursuitDissolveDate = saveData.PursuitDissolveDate__c;
                }else{
                    parmPursuitDissolveDate = this.correspond.PursuitDissolveDate__c;
                }
                //2020/7/13変更：対応確認を兼ねた一覧表示日時取得　（引数1：更新後ステータス、引数2：取引先レコードタイプ、引数3：アポ開始日0時、引数4：追客解除設定日時（保存用））
                saveData.ListViewDate__c = CustomerUtil.setListViewDateWhenCorrespondCheck(parmStatus , this.correspond.AccountId__r.RecordTypeId ,this.correspond.AppointmentStartDate__c ,parmPursuitDissolveDate);
            
            }else if (Parameter.CorrespondType == TASK_CORRESPONDTYPE_APPOINTMENT){
                //2020/7/13変更：対応種別「アポイント確定」では現在日時を設定する。
                saveData.ListViewDate__c = CommonUtil.getNow();

            }else if(Parameter.CorrespondType == TASK_CORRESPONDTYPE_PURSUITHOLD){
                //対応種別「追客保留時」では追客解除日を設定する。
                saveData.ListViewDate__c = Datetime.newInstance(screenCorrespondDetail.PursuitDissolveDate,screenCorrespondDetail.PursuitDissolveTime);   // 一覧表示日時
                //対応種別「追客保留」時で条件完全一致を設定する。
                saveData.ExactConditionMatch__c = screenCorrespondDetail.ExactConditionMatch;
            }


            // 終了系から電話対応をした場合の登録
            if(insCorrespondFlgTel){
                saveData.EchoStaff__c = this.loginStaff;                 // 担当者（反響）
                saveData.EchoShop__c = this.loginShop;                   // 反響担当店舗
                saveData.IsBrowseFlg__c = true;                    // 閲覧フラグ
                saveData.AccountId__c = Correspond.AccountId__c;    // 取引先
                //▼ 2021.09.24 No.489 対応の初回問合せ物件が登録されていない場合
                if(Correspond.FirstInquiryProperty__c == null) {
                    // 選択されたお問合せ物件を取得
                    String inquiryProp = screenCorrespondDetail.SelectedInquiryProp;
                    // 取得できた場合
                    if(String.isNotBlank(inquiryProp)) {
                        saveData.FirstInquiryProperty__c = inquiryProp;
                        this.inquiryPropId = inquiryProp;
                    // 反響一覧登録フラグを立てる
                    this.echoInsertFlg = true;
                    Parameter.echoInsertFlg = this.echoInsertFlg;
					}
				}
                //▲ 2021.09.24 No.489
            }   

        }
        SecureDML.secureUpsert(saveData);
        return saveData.Id;
    }
   

    /**
     * 登録処理(対応明細)
     * 引数　　：　CorrespondId String 対応Id
     *        ：  AccountId String 取引先
     * 戻り値　：  
     */
    private Boolean saveCorrespondDetail(String CorrespondId,String AccountId){
        // 保存処理
        CorrespondDetail__c saveDate = new CorrespondDetail__c();
        // 保存項目
        // 更新か新規登録かで内容を判断する。
        if (insCorrespondDetailFlg){
            // 登録時
            saveDate.SupportedDateTime__c   = CommonUtil.getNow();          // 対応日時
            saveDate.Shop__c                = this.loginShop;               // 店舗
            saveDate.Staff__c               = this.loginStaff;              // 担当者
            saveDate.Corresponds__c         = CorrespondId;                 // 対応ID
            saveDate.CorrespondType__c      = screenCorrespondDetail.CorrespondType;    // 対応種別
            
            // 電話状況が"SNS"、"LINE"の場合は対応種別の値を変更
            if (screenCorrespondDetail.PhoneStatus.indexOf(TASK_CORRESPONDTYPE_SMS) != -1) {
                saveDate.CorrespondType__c = TASK_CORRESPONDTYPE_SMS;
            } else if (screenCorrespondDetail.PhoneStatus.indexOf(TASK_CORRESPONDTYPE_LINE) != -1) {
                saveDate.CorrespondType__c = TASK_CORRESPONDTYPE_LINE;
            }
        }else{
            // 更新時
            saveDate.id =screenCorrespondDetail.Id;  
        }       

        if(this.isModalTelStatus()){
            // 2020/6/10：電話の場合、表題を状況に設定
            saveDate.SupportedTitle__c = screenCorrespondDetail.Sender + ' から ' + screenCorrespondDetail.PhoneStatus;// 対応表題
        }else{
            saveDate.SupportedTitle__c = screenCorrespondDetail.SupportedTitle;    // 対応表題
        }
        saveDate.SupportedContent__c   = setSupportedContent(screenCorrespondDetail);   // 対応内容
        saveDate.PortalSiteUrl__c      = setPortalSiteUrl(screenCorrespondDetail.PortalSite);    // ポータルサイトURL
        
        if (this.isModalTelStatus()){
            // 対応種別が電話
            saveDate.PhoneStatus__c     = screenCorrespondDetail.PhoneStatus;    // 電話状況
            //2020/6/10追加：発信者を保存
            saveDate.Sender__c          = screenCorrespondDetail.Sender;         //発信者
            //2020/6/25追加：電話_ポータルサイトを保存
            if (String.isNotBlank(screenCorrespondDetail.PortalSite)){
                saveDate.PortalSite__c          = screenCorrespondDetail.PortalSite;//電話_ポータルサイト
            }
            //2020/6/25追加：電話_地区を保存
            if (String.isNotBlank(screenCorrespondDetail.District)){
                saveDate.District__c          = screenCorrespondDetail.District;   //電話_地区
            }
            // 電話_お問合せ物件を保存（新規時のみ）
            if (insCorrespondDetailFlg) {
                saveDate.InquiryProperty__c  = this.getSelectOptionLabel(screenFavoritePropertyList
                                                                         , screenCorrespondDetail.SelectedInquiryProp);
            }
            //▼ 2021.09.24 No.489 反響一覧登録フラグがtrueであれば、物件IDと初回問合せ物件表示を登録
            if(echoInsertFlg) {
                saveDate.Property__c = this.inquiryPropId; 
                saveDate.FirstInquiryPropertyShowFlg__c = true;
            }
            //▲ 2021.09.24 No.489

        }else if (screenCorrespondDetail.CorrespondType == TASK_CORRESPONDTYPE_CLOSE){
            // 対応種別が終了
            saveDate.EndType__c         = screenCorrespondDetail.PhoneStatus;    // 終了種別
            saveDate.SupportedTitle__c = screenCorrespondDetail.PhoneStatus;     // 問合せNo295で追加　状況を対応表題として表示
        }

            
        // アポイント確定のみ開始日時と終了日時を登録
        if (screenCorrespondDetail.CorrespondType == TASK_CORRESPONDTYPE_APPOINTMENT){
            saveDate.StartDate__c = screenCorrespondDetail.StartDate;            //開始日時_年月日
            saveDate.StartDateTime__c = DateTime.newInstance(screenCorrespondDetail.StartDate, screenCorrespondDetail.StartDateTime).format('HH:mm'); //開始日時_時分                        //終了日時_時分
            saveDate.EndDate__c = screenCorrespondDetail.EndDate;                //終了日時_年月日
            saveDate.EndDateTime__c = DateTime.newInstance(screenCorrespondDetail.endDate, screenCorrespondDetail.EndDateTime).format('HH:mm'); //終了日時_時分
        }
        
        SecureDML.secureUpsert(saveDate);

        return True;
    }

    /**
     * 登録処理(行動)
     * 引数　　：　Correspond Correspond__c 対応情報
     * 　　　　：  isShopType Bollean 店舗区分
     *        ：  AccountId String 取引先
     * 戻り値　：  
     */
    private Boolean saveEvent(String AccountId){
    //private Boolean saveEvent(Correspond__c Correspond,Boolean isShopType,String AccountId){

        // 2020.09.24 ▼ 来店担当追加
        List<Event> saveDataList = new List<Event>();
        Event saveData = new Event();
        Event saveData2 = new Event();

        // *** 担当者１の登録処理 ***
 
        // 保存項目
        // 更新か新規登録かで内容を判断する。
        // 登録時（IDをいれない）
        if(selectedEvent != null){
            saveData.Id            = selectedEvent.Id; //Id
        }

        saveData.Subject           = '【' + CommonConst.TASK_CORRESPONDTYPE_OPPORTUNITY + '】' + screenCorrespondDetail.SupportedTitle  ;   // 件名															
        saveData.StartDateTime     = Datetime.newInstance(screenCorrespondDetail.StartDate,screenCorrespondDetail.StartDateTime);	// 開始日時	
        saveData.EndDateTime       = Datetime.newInstance(screenCorrespondDetail.EndDate,screenCorrespondDetail.EndDateTime);// 終了日時															
        saveData.Description       = screenCorrespondDetail.SupportedContent  ; // 説明	
        saveData.Shop__c           = screenCorrespondDetail.VisitShop  ;        // 店舗	
        saveData.WhatId            = AccountId;  // 関連先ID（取引先ID）
        saveData.OwnerId           = screenCorrespondDetail.ShopStaff;
        saveData.GuidanceMethod__c = screenCorrespondDetail.GuidanceMethod; //案内方法

        // ポータルサイト構築 追加 Start
        saveData.AppointmentReceiptNoMaintenance__c = this.Correspond.AppointmentReceiptNoMaintenance__c;    // 来店受付メンテ不要
        if(this.Correspond.FirstVisitReservationCancelFlg__c){
            // 初回来店予約キャンセルフラグがTrueなら来店受付メンテ不要をFalseにする。
            saveData.AppointmentReceiptNoMaintenance__c = false;
        }
        // ポータルサイト構築 追加 End
        saveDataList.add(saveData);

        // *** 担当者２の登録処理 ***
        if (staffCountValue == STAFF_TWO){
            // 登録時（IDをいれない）
            if(selectedEvent2 != null){
                saveData2.Id        = selectedEvent2.Id; //Id
            }
            saveData2.Subject           = '【' + CommonConst.TASK_CORRESPONDTYPE_OPPORTUNITY + '】' + screenCorrespondDetail.SupportedTitle  ;   // 件名															
            saveData2.StartDateTime     = Datetime.newInstance(screenCorrespondDetail.StartDate,screenCorrespondDetail.StartDateTime2);	// 開始日時	
            saveData2.EndDateTime       = Datetime.newInstance(screenCorrespondDetail.EndDate,screenCorrespondDetail.EndDateTime2);// 終了日時															
            saveData2.Description       = screenCorrespondDetail.SupportedContent  ; // 説明	
            saveData2.Shop__c           = screenCorrespondDetail.VisitShop2 ;        // 店舗	
            saveData2.WhatId            = AccountId;  // 関連先ID（取引先ID）
            saveData2.OwnerId           = screenCorrespondDetail.ShopStaff2;
            saveData2.GuidanceMethod__c = screenCorrespondDetail.GuidanceMethod; //案内方法
            // ポータルサイト構築 追加 Start
            saveData2.AppointmentReceiptNoMaintenance__c = this.Correspond.AppointmentReceiptNoMaintenance__c;    // 来店受付メンテ不要
            if(this.Correspond.FirstVisitReservationCancelFlg__c){
                // 初回来店予約キャンセルフラグがTrueなら来店受付メンテ不要をFalseにする。
                saveData2.AppointmentReceiptNoMaintenance__c = false;
            }
            // ポータルサイト構築 追加 End
            saveDataList.add(saveData2);
        }
        
        SecureDML.secureUpsert(saveDataList);

        //来店担当が２名⇒１名になった場合、担当者２の行動を削除
        if (Correspond.EventId2__c != null && staffCountValue == STAFF_ONE){
           if(selectedEvent2 != null){
            SecureDML.secureDelete(selectedEvent2);
           }            
        }

        selectedEvent  = saveData;
        selectedEvent2 = saveData2;
        // 2020.09.24 ▲ 来店担当追加
        return True;
    }

    /**
     * 検索処理（対応履歴：対応）
     * 引数によって内容を絞り込んだ一覧を取得する。
     * 引数　　：  CorrespondId String 対応ID
     * 戻り値　：  List<Correspond__c> 対応のデータ
     */
    private List<Correspond__c> selectCorrespondInfo(String CorrespondId ){
        // 検索SQL作成
        String sql = '';
        sql += 'SELECT Id ';                     // 対応.ID（非表示）
        sql += '      ,VisitShopName__c ';       // 対応.来店担当者店舗
        sql += '      ,ShopStaffName__c ';       // 対応.来店担当者担当者
        sql += '      ,Property__r.Building__r.Name ';       // 対応.物件.建物.建物名
        sql += '      ,Property__r.Name ';       // 対応.物件.部屋番号
        sql += '      ,FirstInquiryProperty__r.Building__r.Name ';       // 対応.物件.部屋番号
        sql += '      ,FirstInquiryProperty__r.Name ';       // 対応.物件.部屋番号
        sql += '      ,ExactConditionMatch__c ';       // 対応.条件完全一致
        sql += '      ,EchoStaff__c ';          // 対応.反響担当
        sql += '      ,ShopStaff__c ';          // 対応.来店担当
        sql += '      ,Status__c ';             // 対応.ステータス
        sql += '      ,FirstInquiryMeans__c ';  // 対応.初回問い合せ
        sql += '      ,SystemModstamp ';
        
        sql += '      ,AccountId__c ';    // 取引先
        sql += '      ,Property__c ';    // 物件
        sql += '      ,EventDateTime__c ';    // イベント時刻
        sql += '      ,StaffSupportedFlg__c ';    // スタッフ対応フラグ
        sql += '      ,IsSupportedListShow__c ';    // 対応確認フラグ
        sql += '      ,EchoShop__c ';    // 反響担当店舗
        sql += '      ,VisitShop__c ';    // 来店担当店舗
        sql += '      ,PortalSite__c ';    // ポータルサイト
        sql += '      ,PursuitDissolveDate__c ';    // 追客解除設定日時（保存用）
        sql += '      ,District__c ';    // 地区
        sql += '      ,PortalSiteUrl__c ';    // ポータルサイトURL
        sql += '      ,IsBrowseFlg__c ';    // 閲覧フラグ
        sql += '      ,Memo__c ';    // メモ
        sql += '      ,ListViewDate__c ';    // 一覧表示日時
        sql += '      ,FirstInquiryProperty__c ';    // 初回問合せ物件
        sql += '      ,Application__c ';    // 申込
        sql += '      ,SendMailDate__c ';    // メール送信日時
        sql += '      ,ReceiveMailDatePortal__c ';    // メール受信日時（ポータル）
        sql += '      ,ReceiveMailDateOther__c ';    // メール受信日時（その他）
        sql += '      ,PhoneIncomingDate__c ';    // 電話着信日時
        sql += '      ,PhoneOutgoingDate__c ';    // 電話発信日時
        sql += '      ,PhoneAbsenceDate__c ';    // 電話不在日時
        sql += '      ,BrowseDate__c ';    // 閲覧日時
        //問合せ397で追加変更
        sql += '      ,EndDate__c ';       // 終了日時
        sql += '      ,PursuitDissolveSettingDate__c ';    // 追客解除設定日時
        sql += '      ,VisitReason__c ';    // 来店理由（スタッフ欄）
        sql += '      ,StatusBeforePursuitHold__c ';    // 2020/6/16追加：保留前ステータス 
        sql += '      ,AppointmentStartDate__c ';       // 2020/7/13追加：アポイント開始日0時
        sql += '      ,AccountId__r.Id ';               // 2020/7/13追加：取引先.Id（一覧表示日時メソッドでレコードを使用）
        sql += '      ,AccountId__r.RecordTypeId ';     // 2022/1/12追加：取引先.レコードタイプId
        sql += '      ,EventId__c';                     // 2020/9/18追加：行動Id　　　　　　　　　　
        sql += '      ,EventId2__c';           	      // 2020/9/24追加：行動Id2
        sql += '      ,VisitReservationFlag__c ';       // 来店予約フラグ // ポータルサイト構築 追加　　　
        sql += '      ,AppointmentReceiptNoMaintenance__c ';       // 来店受付メンテ不要 // ポータルサイト構築 追加　
        sql += '      ,FirstVisitReservationCancelFlg__c ';  // 初回来店予約キャンセルフラグ // ポータルサイト構築 追加　
        sql += '      ,FirstGuidanceMethod__c ';  // 初回案内方法　
        sql += '      ,FirstEventId__c ';         // 初回行動Id　
        sql += ' FROM  Correspond__c ';                         // 対応
        sql += ' WHERE Id = \'' + CorrespondId + '\'' ;         // 対応ID

        // 検索実行＆結果返却
        return Database.query(sql);

    }

    /**
     * 検索処理（対応履歴：対応明細）
     * 引数によって内容を絞り込んだ一覧を取得する。
     * 引数　　：  CorrespondDetailId String 対応明細ID
     * 戻り値　：  List<CorrespondDetail__c> 対応明細のデータ
     */
    private List<CorrespondDetail__c> selectCorrespondDetailInfo(String CorrespondDetailId ){
        // 検索SQL作成
        String sql = '';
        sql += 'SELECT Id ';                                    // 対応明細.活動ID（非表示）
        sql += '      ,SystemModstamp ';                        // 対応明細.SystemModstamp
        sql += '      ,CorrespondType__c ';                     // 対応明細.対応種別
        sql += '      ,SupportedTitle__c ';                     // 対応明細.対応表題
        sql += '      ,PhoneStatus__c ';                        // 対応明細.電話状況
        sql += '      ,Sender__c ';                             // 2020/6/10追加：対応明細.発信者
        sql += '      ,EndType__c ';                            // 対応明細.終了種別
        sql += '      ,Corresponds__r.PursuitDissolveDate__c '; // 対応.追客解除日（保存用）
        sql += '      ,Corresponds__r.PursuitDissolveSettingDate__c '; // 2020/6/15追加：追客解除設定日時
        sql += '      ,PortalSite__c ';                         // 2020/6/25変更：対応明細.ポータルサイト
        // 2020.09.24 ▼ 来店担当追加
        sql += '      ,Corresponds__r.VisitShop__c ';           // 対応.来店担当者店舗
        sql += '      ,Corresponds__r.ShopStaff__c ';           // 対応.来店担当者担当者
        // 2020.09.24 ▲ 来店担当追加      
        sql += '      ,Corresponds__r.Property__r.Building__r.Name ';  // 対応.建物.建物名
        sql += '      ,Corresponds__r.Property__r.Name ';       // 対応.物件.部屋番号
        sql += '      ,Corresponds__r.Status__c ';              // 対応.ステータス
        sql += '      ,Corresponds__r.FirstInquiryMeans__c ';   // 対応.初回問い合せ
        sql += '      ,SupportedContent__c ';                   // 対応明細.対応内容
        sql += '      ,District__c ';                           // 2020/6/25変更：対応明細.地区
        sql += '      ,InquiryProperty__c ';                    // 問合せ416で追加　お問い合わせ物件
        sql += ' FROM  CorrespondDetail__c ';                   // 対応明細
        sql += ' WHERE Id = \'' + CorrespondDetailId + '\'' ;   // 対応明細ID
        // 検索実行＆結果返却
        return Database.query(sql);

    }

    /** 
    * ポータルサイト一覧設定
    * 引数　　：  hasNormalBlank boolean リベロ以外の選択肢に--なし--を一番上に追加するかどうか
    * 引数　　：  hasLiveroBlank boolean リベの選択肢に--なし--を一番上に追加するかどうか
    * 戻り値　：  List<PortalSite> ポータルサイト選択リスト
    * 2020/6/25変更：状況がLivero反響用とそれ以外用のポータルサイトの選択肢も設定する。
    * 初期値はになる
    **/
    private List<SelectOption> getPortalSiteSelectedOptionFromId(Boolean hasNormalBlank,Boolean hasLiveroBlank){
        
        this.selectPortalSiteNormalList = new List<SelectOption>();// 通常のポータルサイト用を初期化
		this.selectPortalSiteLiveroList = new List<SelectOption>();// リベロ用のポータルサイト用を初期化
        // 2020/6/25変更：SOQLを静的に変更
        List<PortalSite__c> PortalSiteList = [SELECT Id
                                             		 ,Name
                                              		 ,SelectionType__c 
                                              FROM PortalSite__c
                                              ORDER BY SortOrder__c
                                              LIMIT :CommonConst.GOVERNOR_SELECT_LIMIT];
        
        // リベロ以外用に-- なし -- を追加する。
        if(hasNormalBlank){
            this.selectPortalSiteNormalList.add(new SelectOption('',CommonConst.SELECTION_LIST_NULL));// 第一引数 ： 値が空 第二引数 ： '-- なし -- '
        }
        //リベロ用に--なし--を追加する。
        if(hasLiveroBlank){
            this.selectPortalSiteLiveroList.add(new SelectOption('',CommonConst.SELECTION_LIST_NULL));// 第一引数 ： 値が空 第二引数 ： '-- なし -- '
        }

        // 検索したListを回して、SelectOption型のListに追加。
        for(PortalSite__c reccord : PortalSiteList){

            //選択肢タイプがリベロの場合、リベロ用ポータルサイト選択リストにリベロの選択肢を追加
            if (reccord.SelectionType__c == CommonConst.PORTALSITE_SELECTIONTYPE_LIVERO){
                this.selectPortalSiteLiveroList.add(new SelectOption(reccord.Id, reccord.Name));// 第一引数 ： 値を設定 第二引数 : ラベル名(表示名)
                this.portalSiteLiveroId = reccord.Id;
            //選択肢タイプがリベロ以外の場合、通常ポータルサイト選択リストに選択肢を追加
            }else{
                this.selectPortalSiteNormalList.add(new SelectOption(reccord.Id, reccord.Name));// 第一引数 ： 値を設定 第二引数 : ラベル名(表示名)
            }
        }

        //電話状況が「Livero反響」のとき、ポータルサイト選択リストはリベロポータルサイトを返却
        if (screenCorrespondDetail.PhoneStatus == CommonConst.CORRESPONDDETAIL_PHONESTATUS_LIVEROECHO){
            return this.selectPortalSiteLiveroList;
        }else{
            //電話状況が「Livero反響」以外のとき、ポータルサイト選択リストはリベロ以外ポータルサイトを返却
            return this.selectPortalSiteNormalList;
        }

    }

    //2020/6/23追加：申込削除処理
    private void deleteApplication(){
        //申込の値を更新してから（反響累計に金額が残るため）、申込を削除
            Application__c deleteApp = new Application__c(
                id = Correspond.Application__c,
                IsReviewEntry__c = false,           //口コミ記入
                PaymentDate__c = null,              //入金日
                BrokerageFirstFee__c = null,        //仲介手数料
                ParkingBrokerageFirstFee__c = null, //駐車場紹介料
                ADFee__c = null,                    //広告宣伝費
                AuxiliaryDepositPlanFee__c = null,  //付帯保証プラン料
                AuxiliaryFireInsuranceFee__c = null,//付帯火災保険料
                AuxiliaryIndoorDisinfectionFee__c = null,//付帯室内消毒料
                AuxiliaryKeyExchangeFee__c = null,  //付帯鍵交換費
                AuxiliaryReliableSupportFee__c = null,//付帯安心サポート料
                AuxiliaryFShotFee__c = null,        //付帯Fショット料
                AuxiliaryAlsokLockFee__c = null     //付帯アルソック料
            );
            SecureDML.secureUpdate(deleteApp);
            SecureDML.secureDelete(deleteApp);

    }

    //2020/6/25追加：電話状況変更時のポータルサイト選択リストの選択肢と値を設定
    private void SettingPhonePortalSite(Boolean isLivero){
        //リベロ反響の場合
        if (isLivero){
            //ポータルサイトの選択肢をリベロ反響用に変更
            this.selectPortalSiteList = this.selectPortalSiteLiveroList;
            //ポータルサイトの値を「Livero」に変更
            screenCorrespondDetail.PortalSite = this.portalSiteLiveroId;   

        //リベロ反響以外の場合
        }else{
            //ポータルサイトの選択肢を画面表示（リベロ反響以外）用に変更
            this.selectPortalSiteList = this.selectPortalSiteNormalList;
            //電話状況の値が「Livero反響」 または 反響系でないとき（電話反響・LINE反響以外のとき）、ポータルサイトの値を「--なし--」に変更
            if (screenCorrespondDetail.PhoneStatus == CommonConst.PORTALSITE_SELECTIONTYPE_LIVERO || !isEcho ){
                screenCorrespondDetail.PortalSite = '';  
            }
        }
    }

    /**
    * 問合せNo341で追加
    * 取引先情報取得
    * 引数によって内容を絞り込んだ一覧を取得する。
    * 引数　　：  AccountId 取引先ID
    * 戻り値　：  List<Account> 取引先のデータ
    */
    private List<Account> selectAccountInfo(){
        // 検索SQL作成
        String sql = '';
        sql += 'SELECT Id ';                                    // 取引先.Id
        sql += '      ,SystemModstamp ';                        // 取引先.SystemModstamp
        sql += '      ,EchoTelephoneFlag__c ';                  // 取引先.電話反響登録済みフラグ
        sql += '      ,Situation__c ';                			// 取引先.状況
        // ▼問合せNo411で追加
        sql += '      ,EchoLineFlag__c ';               		// 取引先.LINE反響登録済みフラグ
        sql += '      ,EchoLiveroFlag__c ';             		// 取引先.リベロ反響登録済みフラグ
        // ▲問合せNo411で追加
        sql += ' FROM  Account ';             					// 取引先

        sql += ' WHERE Id = \'' + Parameter.AccountId + '\'' ;  // 取引先ID
        // 検索実行＆結果返却
        return Database.query(sql);
    }

    /**
    * TEL/SMS/LINEモーダルの表示ステータスチェック（Getメソッド）
    * @return Boolean true:表示ステータス、false:非表示ステータス
    */
    public Boolean getIsModalTelStatus() {
        return this.isModalTelStatus();
    }

    /**
    * TEL/SMS/LINEモーダルの表示ステータスチェック
    * @return Boolean true:表示ステータス、false:非表示ステータス
    */
    private Boolean isModalTelStatus() {

        // 対象ステータス
        List<String> openTargetStatus = new List<String> {
            TASK_CORRESPONDTYPE_TEL     // 電話
            , TASK_CORRESPONDTYPE_SMS   // SMS
            , TASK_CORRESPONDTYPE_LINE  // LINE
        };

        // ステータスチェック
        if (openTargetStatus.contains(this.screenCorrespondDetail.CorrespondType)) {
            return true;
        }

        return false;
    }

	// ▼ 2021.11.30 LINE連携対応より、メモと電話の切り替え用対応種別を追加
	/**
	 * 対応種別の変更
	 */
	public void chgCorrespondType() {

		// 電話、メモの切り替え
		this.Parameter.CorrespondType = TASK_CORRESPONDTYPE_MEMO;
		if (this.selectedCorrespondType == TASK_CORRESPONDTYPE_TEL) {
			this.Parameter.CorrespondType = TASK_CORRESPONDTYPE_TEL;
		}
		
		// 画面情報の再取得
		this.getSelectOption();
	}
	// ▲ 2021.11.30

    /**
     * 対応明細表示用内部クラス
     */
    public class screenCorrespondDetail {
        private CorrespondDetail__c targetCorrespondDetailRecord1;    //レコード本体（対応明細）
        
        //以下、画面用の項目
        
        public String  Id                   { get; set; }    // 取引先.Id（非表示）
        public Datetime systemModStamp      { get; set; }    // systemModStamp
        public String  CorrespondType       { get; set; }    // 対応明細.対応種別
        public String  SupportedTitle       { get; set; }    // 対応明細.対応表題
        public String  PhoneStatus          { get; set; }    // 対応明細.電話状況
        public String  Sender               { get; set; }    // 2020/6/10追加：対応明細.発信者
        public String  EndType              { get; set; }    // 対応明細.終了種別
        public Date    PursuitDissolveDate  { get; set; }    // 対応.追客解除日（保存用）(年月日)
        public Time    PursuitDissolveTime  { get; set; }    // 対応.追客解除日（保存用）(時分)
        public String  PortalSite           { get; set; }    // 対応明細.ポータルサイト
        // 2020.09.24 ▼ 来店担当追加
        public String  VisitShop            { get; set; }    // 行動.店舗（担当店舗１）
        public String  ShopStaff            { get; set; }    // 行動.任命先（担当者１）
        public String  VisitShop2           { get; set; }    // 行動.店舗（担当店舗２）
        public String  ShopStaff2           { get; set; }    // 行動.任命先（担当者２）
        public Date    StartDate            { get; set; }    // 行動.開始日（担当１）
        public time    StartDateTime        { get; set; }    // 行動.開始時（担当１）
        public Date    EndDate              { get; set; }    // 行動.終了日（担当１）
        public time    EndDateTime          { get; set; }    // 行動.終了時（担当１）
        public Date    StartDate2           { get; set; }    // 行動.開始日（担当２）
        public time    StartDateTime2       { get; set; }    // 行動.開始時（担当２）
        public Date    EndDate2             { get; set; }    // 行動.終了日（担当２）
        public time    EndDateTime2         { get; set; }    // 行動.終了時（担当２）
        // 2020.09.24 ▲ 来店担当追加
        public String  GuidanceMethod       { get; set; }    // 行動.案内方法
        public String  BuildingName         { get; set; }    // 対応.建物.建物名（部屋番号あり）
        public String  SupportedContent     { get; set; }    // 対応明細.対応内容
        public String  District             { get; set; }    // 対応明細.地区        
        public String  ExactConditionMatch  { get; set; }    // 対応.条件完全一致
        public String  SelectedInquiryProp  { get; set; }    // お問合せ物件選択値

        //コンストラクタ
        public screenCorrespondDetail(CorrespondDetail__c targetCorrespondDetailRecord){
            //レコードの連動
            this.targetCorrespondDetailRecord1    = targetCorrespondDetailRecord;   
            this.Id                  = targetCorrespondDetailRecord.Id;                     // 対応.Id（非表示）
            this.systemModStamp      = targetCorrespondDetailRecord.systemModStamp ;        // systemModStamp
            this.CorrespondType      = targetCorrespondDetailRecord.CorrespondType__c ;     // 対応明細.対応種別
            this.SupportedTitle      = targetCorrespondDetailRecord.SupportedTitle__c ;     // 対応明細.対応表題
            this.PhoneStatus         = targetCorrespondDetailRecord.PhoneStatus__c ;        // 対応明細.電話状況
            this.Sender              = targetCorrespondDetailRecord.Sender__c;              // 2020/6/10追加：対応明細.発信者
            this.EndType             = targetCorrespondDetailRecord.EndType__c ;            // 対応明細.終了種別
            //2020/6/15変更：追客解除設定日時（保存用）（PursuitDissolveDate__c）から追客解除設定日時（PursuitDissolveSettingDate__c）に変更
            if (targetCorrespondDetailRecord.Corresponds__r.PursuitDissolveSettingDate__c != null){
                this.PursuitDissolveDate = targetCorrespondDetailRecord.Corresponds__r.PursuitDissolveSettingDate__c.date();   // 対応.追客解除日(年月日)
                this.PursuitDissolveTime = targetCorrespondDetailRecord.Corresponds__r.PursuitDissolveSettingDate__c.time();   // 対応.追客解除日(時分)
            }
            this.PortalSite          = targetCorrespondDetailRecord.PortalSite__c ;   // 2020/6/10追加：対応明細.ポータルサイト
            // 2020.09.24 ▼ 来店担当追加　※登録時の初期表示用
            this.VisitShop           = targetCorrespondDetailRecord.Corresponds__r.VisitShop__c;   // 対応.来店担当者店舗
            this.ShopStaff           = targetCorrespondDetailRecord.Corresponds__r.ShopStaff__c;   // 対応.来店担当者担当者
            // 2020.09.24 ▲ 来店担当追加
            this.BuildingName        = targetCorrespondDetailRecord.Corresponds__r.Property__r.Building__r.Name +
                                       targetCorrespondDetailRecord.Corresponds__r.Property__r.Name;   // 対応.建物.建物名(部屋番号あり)
            this.SupportedContent    = targetCorrespondDetailRecord.SupportedContent__c ;   // 対応明細.対応内容

            this.District            = targetCorrespondDetailRecord.District__c;    // 2020/6/10追加：対応明細.地区
            this.SelectedInquiryProp = targetCorrespondDetailRecord.InquiryProperty__c; // 対応明細．お問い合わせ物件
            convertNull();
        }

        public screenCorrespondDetail(String CorrespondType){
            //レコードの連動
            this.Id                  = '';              // 対応.Id（非表示）
            this.CorrespondType      = CorrespondType ; // 対応明細.対応種別
            this.SupportedTitle      = '' ;             // 対応明細.対応表題
            this.PhoneStatus         = '' ;             // 対応明細.電話状況
            this.Sender              = null ;           // 2020/6/10追加：対応明細.発信者
            this.EndType             = '' ;             // 対応明細.終了種別
            this.PursuitDissolveDate = null ;           // 対応.追客解除日(年月日)
            this.PursuitDissolveTime = null ;           // 対応.追客解除日(時分)
            this.PortalSite          = '' ;             // 対応明細.ポータルサイト
            this.SupportedContent    = '' ;             // 対応明細.対応内容
            this.District            = null;            // 対応明細.地区
            // 2020.09.24 ▼ 来店担当追加
            this.VisitShop           = null;            // 行動.店舗（担当店舗１）
            this.ShopStaff           = null;            // 行動.任命先（担当者１）
            this.VisitShop2          = null;            // 行動.店舗（担当店舗２）
            this.ShopStaff2          = null;            // 行動.任命先（担当者２）
            this.StartDateTime       = null;            // 行動.開始日（担当１）
            this.EndDate             = null;            // 行動.開始時（担当１）
            this.EndDateTime         = null;            // 行動.終了日（担当１）
            this.StartDate           = null;            // 行動.終了時（担当１）
            this.StartDate2          = null;            // 行動.開始日（担当２）
            this.StartDateTime2      = null;            // 行動.開始時（担当２）
            this.EndDate2            = null;            // 行動.終了日（担当２）
            this.EndDateTime2        = null;            // 行動.終了時（担当２）
            // 2020.09.24 ▲ 来店担当追加

            convertNull();
        }

        //null系を変換する
        public void convertNull() {            
            this.Id                  = String.isEmpty(this.Id)? '' : this.Id;                                   // 対応.Id（非表示）
            this.CorrespondType      = String.isEmpty(this.CorrespondType     )? '' : this.CorrespondType     ; // 対応明細.対応種別
            this.SupportedTitle      = String.isEmpty(this.SupportedTitle     )? '' : this.SupportedTitle     ; // 対応明細.対応表題
            this.PhoneStatus         = String.isEmpty(this.PhoneStatus        )? '' : this.PhoneStatus        ; // 対応明細.電話状況
            this.EndType             = String.isEmpty(this.EndType            )? '' : this.EndType            ; // 対応明細.終了種別
            this.PortalSite          = String.isEmpty(this.PortalSite         )? '' : this.PortalSite         ; // 対応.ポータルサイト
            this.SupportedContent    = String.isEmpty(this.SupportedContent   )? '' : this.SupportedContent   ; // 対応明細.対応内容
            this.District            = String.isEmpty(this.District           )? '' : this.District           ; // 対応.地区
            this.SelectedInquiryProp = String.isEmpty(this.SelectedInquiryProp)? '' : this.SelectedInquiryProp; // お問い合わせ物件選択値
            this.GuidanceMethod      = String.isEmpty(this.GuidanceMethod     )? '' : this.GuidanceMethod     ; // 行動.案内方法
        }
    }

}