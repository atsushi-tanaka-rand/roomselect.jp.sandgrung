/**
 * お客様情報詳細
 */
public with sharing class GA102001Controller {

    /** 画面表示系 */
    public screenAccount screenAccountRecord { get;set; }                                             // 取引先の項目用
    public screenAccount screenAccountRecord_bak { get;set; }                                         // 取引先の項目用_入力変更前
    public List<screenCorrespond> screenCorrespondRecordList { get;set; }                             // 対応状況の項目用
	// ▼2021.10.08 No.307 対応で追加
	public Map<String, screenPropertyConditions> screenPropertyConditionsMap { get; set; }			// お客様物件条件
	public String screenPropertyConditionsRecSize { get; set; }										// お客様物件条件件数
	public screenPropertyConditions currentScreenPropertyCondition{ get; set; }						// お客様物件条件_カレント
	// ▲2021.10.08 No.307 対応で追加
    public List<screenFavoriteProperty> screenFavoritePropertyList { get;set; }                       // お気に入り物件一覧の項目用
    public List<screenExactConditionMatchProperty> screenExactConditionMatchPropertyList { get;set; } // 条件完全一致物件一覧の項目用
    public List<ScreenVacancyReservationProp> screenVacancyReservationPropList { get; set;}           // 空室予約物件の明細一覧
    public List<screenCorrespondDetail> screenCorrespondDetailList { get;set; }                       // 対応履歴（対応明細）一覧の項目用
    public List<screenApplication> screenApplicationList { get;set; }                                 // 申込一覧の項目用
    public List<screenEchoMail> screenEchoMailList { get;set; }                                       // 反響メール一覧の項目用
    public List<IntroductionMailInformation__c> introMailInfoList { get;set; }                        // 紹介メール情報の表示用リスト(実際は2件以上は出ない) // 追加要望 追加
    public List<screenMemberRecord> screenMemberRecordList { get;set; }                               // 本会員の表示用リスト // ポータルサイト構築 追加
    public Boolean EchoAggregationMessageFlg { get;set; }                                             // 反響集約のメッセージ表示フラグ

    public Correspond__c screenCorrespondRecord { get;set;}                     // ヘッダの対応情報設定用

    public String screenHeaderRecord { get;set;}                                // ヘッダ表示用対応オブジェクト（1件）
    public ScreenStyle screenStyle   { get;set;}                                // 画面スタイル

    public String paramApplication { get;set; }                                 // 申込の引渡しパラメータ作成
    public Boolean setPropertyFlg { get;set; }                                  // 物件のデータを登録したかのフラグ

    public Boolean isOpenError { get; set; }                                    //エラーフラグ
    public Boolean hasErrorMessage { get; set; }                                //エラーメッセージ保有フラグ

    public Boolean HeaderLockFlg { get;set; }                                   // ヘッダ固定制御（モーダル用）

    public String qrUrl { get;set; }                                            // QRの生成用URL
    public Boolean WarningFlg { get;set; }                                      // 申込の警告表示フラグ
    public Boolean mizukimeFlg { get;set; }                                     // 見ず決めフラグ
    public Boolean isChange { get; set; }                                       // 変更有無フラグ
    public Boolean newflg { get; set; }                                         // 新規作成で開いたかどうかのフラグ
    public Boolean ReplyFlg { get; set; }                                       // 返信ボタンの処理を動かすかのフラグ
    public Boolean hasEvent { get; set; }                                       // 対応が行動と紐づいているかのフラグ
 
    public Boolean ResponseConfirmationFlg { get; set; }                        //対応確認を行ったかどうかのフラグ
    
    public Boolean editflg { get; set; }                                       // 問合せNo341で追加 新規登録か編集かどうかのフラグ（状況用）

    //追加要望 追加 Start
    public Boolean isOpetionPorta { get; set; }                                  // 自社ポータル権限フラグ
    //追加要望 追加 End

    /** メッセージ系 */
    public String MSG_CUST_I_NOTICE_MERGE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_CUST_I_NOTICE_MERGE);} private set;}    //名寄せ促すメッセージ
    public String MSG_PROP_I_DUPLICATE_ECHO {get{return CommonUtil.callMessageCreate(CommonConst.MSG_PROP_I_DUPLICATE_ECHO);} private set;}    //反響集約を促すメッセージ
    public String MSG_COM_V_DELETE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_DELETE);} private set;}    //js用削除確認メッセージ
    public String MSG_COM_I_DELETE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_DELETE);} private set;}    //js用削除完了メッセージ
    public String MSG_COM_V_NO_SELECTION {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_NO_SELECTION, 'お気に入り物件');} private set;} // 削除確認メッセージ(お気に入り物件)
    public String MSG_COM_I_CANCEL_CONFIRMATION {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_CANCEL_CONFIRMATION,'遷移');} private set;}    //口コミボタン変更確認メッセージ
    public String MSG_COM_V_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_SAVE);} private set;}   // 登録確認メッセージ
    public String MSG_COM_I_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);} private set;}   // 登録完了メッセ―じ
    public String MSG_PROP_I_PROPERTY_LINKING_COMPLETED_MULTIPLE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_PROP_I_PROPERTY_LINKING_COMPLETED_MULTIPLE);} private set;}   // 紐づけ完了後メッセ―ジ（複数紐づけ）
    public String MSG_PROP_I_PROPERTY_LINKING_COMPLETED {get{return CommonUtil.callMessageCreate(CommonConst.MSG_PROP_I_PROPERTY_LINKING_COMPLETED);} private set;}   // 紐づけ完了後メッセ―ジ（単紐づけ）
    public String MSG_PROP_I_PROPERTY_LINKING {get{return CommonUtil.callMessageCreate(CommonConst.MSG_PROP_I_PROPERTY_LINKING);} private set;}   // 物件の紐づけのメッセージ
    public String MSG_PROP_E_PROPERTY_LINKING_RESIDENCE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_PROP_E_PROPERTY_LINKING_RESIDENCE);} private set;}   // 居住中のメッセージ
    public String MSG_PROP_E_NOTICE_PERSONNEL_UNCONFIGURED {get{return CommonUtil.callMessageCreate(CommonConst.MSG_PROP_E_NOTICE_PERSONNEL_UNCONFIGURED);} private set;}  // 担当者未設定時のエラーメッセージ
    public String MSG_COM_W_SEARCH_NO_DATA {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_NO_DATA);} private set;}  // 該当のデータが存在しない場合のメッセージ
    public String MSG_COM_W_SELECTION_OR_MORE_DELETE_FAVORITEPROPERTY {
        get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SELECTION_OR_MORE,'お気に入り物件,1'.split(','));}
        private set; } // 削除対象未選択チェック時メッセージ（お気に入り物件）
    public String MSG_COM_W_SELECTION_OR_LESS_FAVORITEPROPERTY {
        get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SELECTION_OR_LESS,'お気に入り物件,1'.split(','));}
        private set; } // 削除対象複数選択チェック時メッセージ（お気に入り物件）
    public String MSG_COM_W_SELECTION_OR_MORE_DELETE_EXACTCONDITIONMATCHPROPERTY {
        get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SELECTION_OR_MORE,'条件完全一致物件,1'.split(','));}
        private set; } // 削除対象未選択チェック時メッセージ（条件完全一致物件）
    public String MSG_COM_W_SELECTION_OR_LESS_EXACTCONDITIONMATCHPROPERTY {
        get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SELECTION_OR_LESS,'条件完全一致物件,1'.split(','));}
        private set; } // 削除対象複数選択チェック時メッセージ（条件完全一致物件）
    public String MSG_COM_W_SELECTION_OR_MORE_DELETE_APPLICATION {
        get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SELECTION_OR_MORE,'申込,1'.split(','));}
        private set; } // 対象未選択チェック時メッセージ（申込）
    public String MSG_CUST_I_ECHO_INTEGRATION {
        get{return CommonUtil.callMessageCreate(CommonConst.MSG_CUST_I_ECHO_INTEGRATION,checkStatus );}
        private set; } // 反響集約確認メッセージ
    public String MSG_CUST_I_UNNECESSARY_ECHO_INTEGRATION {
        get{return CommonUtil.callMessageCreate(CommonConst.MSG_CUST_I_UNNECESSARY_ECHO_INTEGRATION);}
        private set; } // 反響集約不要確認メッセージ
    public String MSG_NO_SELECTED_VACANCY_RESERVATION_PROP_ROW {
        get { return CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SELECTION_OR_MORE,'空室予約物件', '1');}
        private set; } // 空室予約物件未選択メッセージ
    public String MSG_SAVE_VACANCY_RESERVATION_PROP {
        get { return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_REGISTRATION, '空室予約物件を');}
        private set; } // 空室予約物件登録メッセージ
    public String MSG_COM_I_RESPONSE_CONFIRMATION{get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_RESPONSE_CONFIRMATION);} private set;}          // 対応確認メッセージ
    public String MSG_COM_I_NO_RESPONSE_CONFIRMATION {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_NO_RESPONSE_CONFIRMATION);} private set;}   // 対応確認不可メッセージ
    public String MSG_PROP_I_IMPORT_END{get{return CommonUtil.callMessageCreate(CommonConst.MSG_PROP_I_IMPORT_END);} private set;}   // 取り込み完了メッセージ
    public String MSG_COM_W_SELECTION_OR_MORE_DELETE_FAVORITEPROPERTY_APPLICATION {
        get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SELECTION_OR_MORE,'申込の際、物件をセットするため、お気に入り物件,1'.split(','));}
        private set; } // 削除対象未選択チェック時メッセージ（お気に入り物件）
    public String MSG_COM_V_RELEASEHOLD {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_RELEASEHOLD);} private set;}  // 保留解除のメッセージ
    public String MSG_CUST_E_SET_PROPERTY {get{ return CommonConst.MSG_CUST_E_SET_PROPERTY;} private set; }
    public String MSG_ACC_W_SITUATION_ECHO_TELEPHONE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_ACC_W_SITUATION_ECHO_TELEPHONE);} private set;}    //電話反響のエラーメッセージ
    
    // メッセージ(js用)
    public String MSG_COM_V_FAVORITE    { get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_REGISTRATION, 'お気に入り物件を');}     private set; }  //js用保存確認メッセージ}
    public String MSG_COM_I_FAVORITE    { get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);}                                 private set; }  //js用保存確認メッセージ}

    //追加要望 追加 Start
    public String MSG_COM_V_DELETE_SENDMAILSTATUS {get{return CommonUtil.callMessageCreate(CommonConst_ptl.MSG_COM_V_DELETE_SENDMAILSTATUS);} private set;}        //紹介メール情報削除確認メッセージ 
    public String MSG_COM_I_DELETE_SENDMAILSTATUS {get{return CommonUtil.callMessageCreate(CommonConst_ptl.MSG_COM_I_DELETE_SENDMAILSTATUS);} private set;}    //紹介メール情報削除完了メッセージ
    public String MSG_COM_E_OPTIONAL_PERMISSION_CHECK {get{return CommonUtil.callMessageCreate(CommonConst_ptl.MSG_COM_E_OPTIONAL_PERMISSION_CHECK,'ポータルサイトのご契約');} private set;}    //名寄せ促すメッセージ
    //画面表示、判断用
    public String INTRODUCTION_SEND {get{return CommonUtil.callMessageCreate(CommonConst_ptl.INTRODUCTION_SEND);} private set;}            //配信 
    public String INTRODUCTION_SENDSTOP {get{return CommonUtil.callMessageCreate(CommonConst_ptl.INTRODUCTION_SENDSTOP);} private set;}    //配信停止  
    public String CORRESPOND_STATUS_PURSUIT   { get{return CommonConst.CORRESPOND_STATUS_PURSUIT  ;} private set; }  // 追客中
    //追加要望 追加 End
	// ▼問合せNo411で追加
    public String MSG_ACC_W_SITUATION_ECHO_LINE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_ACC_W_SITUATION_ECHO_LINE);} private set;}              //リベロ反響のエラーメッセージ
    public String MSG_ACC_W_SITUATION_ECHO_LIVERO {get{return CommonUtil.callMessageCreate(CommonConst.MSG_ACC_W_SITUATION_ECHO_LIVERO);} private set;}          //LINE響のエラーメッセージ
    // ▲問合せNo411で追加
	// ▼2021.10.08 No.307 対応
	public String MSG_COM_V_ADD_PROPERTYCONDITIONS { get { return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_ADD_PROPERTYCONDITIONS); } private set; } //物件条件追加メッセージ
	public String MSG_COM_V_DELETE_PROPERTYCONDITIONS { get { return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_DELETE_PROPERTYCONDITIONS); } private set; } // 物件条件削除メッセージ
	public String MSG_COM_I_E_NG_PROPERTY_SAMENAME { get { return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_E_NG_PROPERTY_SAMENAME); } private set; } // 物件条件が被った際のメッセージ
	public String MSG_COM_I_E_NG_PROPERTYCONDITIONSNAME_EMPTY { get { return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_E_NG_PROPERTYCONDITIONSNAME_EMPTY); } private set; } // 物件条件名が未入力の際のメッセージ
	// ▲2021.10.08 No.307 対応

    public List<Account> accountList { get;set; }                                             // 取引先のデータ(単体になる)
    public List<Correspond__c> correspondList { get;set; }                                    // 対応の一覧表示
    public List<FavoriteProperty__c> favoritePropertyList { get;set; }                        // お気に入り物件の一覧表示
    public List<ExactConditionMatchProperty__c> exactConditionMatchPropertyList { get;set; }  // 条件完全一致物件の一覧表示
    public List<Application__c> applicationList { get;set; }                                  // 申込の一覧表示
    public List<EchoMail__c> echoMailList { get;set; }                                        // 反響メールの一覧表示
	// ▼2021.10.08 No.307 対応で削除「希望駅、希望中学校、希望小学校」

    // ボタンの制御系
    public Map<string,list<Integer>> buttonSetlist { get;set; }                 // ボタンの状態をセット
    public Map<integer,String> buttonState { get;set; }                         // ボタンの状態｛0:押下不可:薄グレー、1:押下可:グレー、2:押下可:青｝
    public Map<integer,String> buttonURL { get;set; }                           // URL設定用
    public Map<integer,String> buttonDisabled { get;set; }                      // 押下可否設定
    public List<Integer> buttonListSet { get;set; }                             // 選ばれたステータスのボタン状態


    // リストボックスの生成
    public list<SelectOption> selectDistrictList { get;set; }                   // 地区のリストボックス設定用 
    public List<SelectOption> selectContractTypeList { get;set; }               // 契約形態
    public List<SelectOption> selectSexList { get;set; }                        // 性別リストボックス
    public List<SelectOption> selectStateList { get;set; }                      // 都道府県リストボックス
    public List<SelectOption> selectCompanyStateList { get;set; }               // 都道府県（会社）
    public List<SelectOption> selectCompanyIndustriesList { get;set; }          // 業種（会社）
    public List<SelectOption> selectAccountIndustryList { get;set; }            // 業種（個人）
    public List<SelectOption> selectJobTypeList { get;set; }                    // 職種
    public List<SelectOption> selectAffiliationStateList { get;set; }           // 都道府県（勤務先/学校）
    public List<SelectOption> selectWalkingTimeList { get;set; }                // 徒歩
    public List<SelectOption> selectOccupancyAreaLowerLimitList { get;set; }    // 占有面積（下限）
    public List<SelectOption> selectOccupancyAreaUpperLimitList { get;set; }    // 占有面積（上限）
    public List<SelectOption> selectBuildingAgeList { get;set; }                // 築年数
    public List<SelectOption> selectTrainRoute { get; set; }                    // 路線
    public List<SelectOption> selectSituationList { get;set; }                  // 問合せNo341で追加　状況リストボックス
    public List<SelectOption> districtOption { get; set; }                      // 問合せ415で追加　地区
    
    private List<SelectOption> selectVisitsTriggerList { get; set; } // 来店のきっかけ
    public List<String> VisitsTriggerValueList { get; set; }         // 来店のきっかけ選択リスト（値）
    public Map<String, String> VisitsTriggerNameList { get; set; }   // 来店のきっかけ選択リスト（値、表示名）
    public Map<String, Boolean> VisitsTriggerCheckList { get; set; } // 来店のきっかけチェック状態（値、チェック）

    private List<SelectOption> selectPortalSiteList { get; set; } // 閲覧サイト
    public List<String> PortalSiteValueList { get; set; }         // 閲覧サイト選択リスト（値）
    public Map<String, String> PortalSiteNameList { get; set; }   // 閲覧サイト選択リスト（値、表示名）
    public Map<String, Boolean> PortalSiteCheckList { get; set; } // 閲覧サイトチェック状態（値、チェック）

    private List<SelectOption> selectHomeMovingReasonList { get; set; } // お引越理由
    public List<String> homeMovingReasonValueList { get; set; }         // お引越理由選択リスト（値）
    public Map<String, String> homeMovingReasonNameList { get; set; }   // お引越理由選択リスト（値、表示名）
    public Map<String, Boolean> homeMovingReasonCheckList { get; set; } // お引越理由チェック状態（値、チェック）

    public List<String> ContractTypeValueList { get; set; }         // 契約形態選択リスト（値）
    public Map<String, String> ContractTypeNameList { get; set; }   // 契約形態選択リスト（値、表示名）
    public Map<String, Boolean> ContractTypeCheckList { get; set; } // 契約形態チェック状態（値、チェック）

    private List<SelectOption> selectHomeMovingSeasonList { get; set; } // お引越時期
    public List<String> HomeMovingSeasonValueList { get; set; }         // お引越時期選択リスト（値）
    public Map<String, String> HomeMovingSeasonNameList { get; set; }   // お引越時期選択リスト（値、表示名）
    public Map<String, Boolean> HomeMovingSeasonCheckList { get; set; } // お引越時期チェック状態（値、チェック）

	// ▼2021.10.08 No.307 対応　お客様物件条件
	public List<SelectOption> AccountPropertyConditions { get; set; } // お客様物件条件選択リスト
	public String selectCondName { get; set; }//物件条件名
	public String tmpCondName { get; set; }//マップ置換用の物件条件名
	// ▲2021.10.08 No.307 対応　お客様物件条件

    /** モーダル画面のパラメータ系 */
    public GA102001Modal1ParameterClass GA102001Paremeter1 { get; set; } // 担当者設定画面用パラメータ
    public GA102001Modal2ParameterClass GA102001Paremeter2 { get; set; } // 対応履歴画面用パラメータ
    public GA102001Modal3ParameterClass GA102001Paremeter3 { get; set; } // お気に入り物件面用パラメータ
    public GA102001Modal4ParameterClass GA102001Paremeter4 { get; set; } // 入金画面用パラメータ
    public GA102001Modal6ParameterClass GA102001Paremeter6 { get; set; } // スケジュール画面用パラメータ
    public GA102001Modal7ParameterClass GA102001Paremeter7 { get; set; } // 自動追客一覧画面パラメータ  //追加要望
    public GA102001Modal8ParameterClass GA102001Paremeter8 { get; set; } // 条件完全一致物件画面用パラメータ
	public GA102001Modal9ParameterClass GA102001Paremeter9 { get; set; } // 物件条件用パラメータ  //2021.10.08 No.307 対応で追加
    public GA102006ParameterClass GA102006Parameter{get; set;}       //郵便番号検索・住所検索モーダル
    public GA104007ParameterClass GA104007Parameter{ get; set; }     // 路線図１モーダル
    public GA202002ParameterClass GA202002Parameter{get; set;}       // 学区選択モーダル　問合せ415で追加
    public GH201003ParameterClass GH201003Paremeter{ get; set; }     // 店舗・地区選択モーダル　問合せ423で追加

    public Integer index { get;set; }                       // 対応履歴の選択行

    public Integer checkCorrespondIndex { get;set; }        // 対応状況の選択行番号
    public String checkCorrespondId { get;set; }            // 対応状況の選択行ID
    public String checkProperty { get;set; }                // 対応状況の選択行物件ID
    public String checkApplication { get;set; }             // 対応状況の選択行申込ID
    public String checkStatus { get;set; }                  // 対応状況の選択行ステータス
    public String checkEvent { get;set; }                   // 対応状況の選択行イベント
    public String checkDistrict { get;set; }                // 対応状況の選択行地区
    public String checkEchoStaff { get;set; }               // 対応状況の選択行反響担当者ID
    public String checkShopStaff { get;set; }               // 対応状況の選択行来店担当者ID
    public String checkBuildingproperty { get;set; }        // 対応状況の選択行物件名
    public Datetime checkPursuitDissolveDate { get;set; }   // 対応状況の選択行津客解除日
    public String linkProperty { get;set; }                // お気に入り物件からの物件紐づけ判定物件ID

    public String selectDistrict { get;set; }               // 地区リスト選択地値

    public String loginStaff { get;set; }                   // ログインユーザ(登録用)
    public String loginShop { get;set; }                    // ログインユーザ店舗
    public String loginUserProfileId  { get;set; }          // ログインユーザプロファイルid

    public Integer ApplicationIndex { get;set; }                // 申込の選択行番号
    public String selectApplicationId { get;set; }              // 選択行申込ID
    public String selectSystemModStampApplication { get;set; }  // 選択行SystemModStamp

    public String PropertyLinkProperty { get;set; }         // 物件紐づけ時の新規物件Id
    public String PropertyLinkId     { get;set; }           // 物件紐づけ時の新規対応Id

    public String selectCorrespondDetailId { get;set; }     // 選択された対応履歴の対応明細Id
    public String correspondType { get;set; }               // ボタン押下した時の対応種別
    public String setStatus { get;set; }                    // ボタン押下した時のステータス
    public String CorrespondDetailEchoMailId { get;set;}    // 対応明細選択行のメールID
    public string CorrespondDetailId { get;set;}            // 対応明細の選択ID

    public String CorrespondDetailCorrespondsId { get;set;} // 対応履歴で選ばれた対応Id

    public Boolean isInsertFlg { get;set; }                 // 登録画面フラグ(True:登録画面,False:表示画面)
    public Boolean contractTypeFlg { get;set; }             // 契約形態のフラグ（True:個人,契約False:法人契約）
    public Boolean changeFlg { get; set; }                  // 変更フラグ

    public String mailButtonParam { get;set; }              // メールボタン押下時のパラメータ

    public String setMailSopId { get;set; }                 // 返信時のメール送信時の店舗Id

    // public String filePath { get;set; }                     // 取込時のファイルパス
    public String   attachmentIdList    { get; set; }   // 添付Id格納用

	public Id lineCorrespondId { get; set;}	// LINE会員対応ID	2022.04.20 No0768 対応で追加

    /** 画面用対応種別定数 */
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
    public String TASK_CORRESPONDTYPE_PERSONDECISION   { get{return CommonConst.TASK_CORRESPONDTYPE_PERSONDECISION  ;} private set; } //担当者決定
    public String TASK_CORRESPONDTYPE_RELEASEHOLD      { get{return CommonConst.TASK_CORRESPONDTYPE_RELEASEHOLD     ;} private set; } //保留解除
    public String TASK_CORRESPONDTYPE_ENDCONTRACT      { get{return CommonConst.TASK_CORRESPONDTYPE_ENDCONTRACT     ;} private set; } //契約完了
    public String TASK_CORRESPONDTYPE_ECHOAGGREGATION  { get{return CommonConst.TASK_CORRESPONDTYPE_ECHOAGGREGATION ;} private set; } //反響集約
    public String TASK_CORRESPONDTYPE_APO_CANCEL       { get{return CommonConst.TASK_CORRESPONDTYPE_APO_CANCEL      ;} private set; } //問合せNo295で追加　アポキャンセル
    public String TASK_CORRESPONDTYPE_SMS              { get{return CommonConst.TASK_CORRESPONDTYPE_SMS             ;} private set; } //SMS
    public String TASK_CORRESPONDTYPE_LINE             { get{return CommonConst.TASK_CORRESPONDTYPE_LINE            ;} private set; } //LINE
    
    public String CORRESPOND_STATUS_NOTSUPPORTED      { get{return CommonConst.CORRESPOND_STATUS_NOTSUPPORTED           ;} private set; }  // 未対応
    public String CORRESPOND_STATUS_APPOINTMENT       { get{return CommonConst.CORRESPOND_STATUS_APPOINTMENT            ;} private set; }  // アポイント確定
    public String CORRESPOND_STATUS_CONSIDERVISITING  { get{return CommonConst.CORRESPOND_STATUS_CONSIDERVISITING       ;} private set; }  // 来店後検討
    public String CORRESPOND_STATUS_AGREEMENT         { get{return CommonConst.CORRESPOND_STATUS_AGREEMENT              ;} private set; }  // 契約完了
    public String CORRESPOND_STATUS_PURSUITHOLD       { get{return CommonConst.CORRESPOND_STATUS_PURSUITHOLD            ;} private set; }  // 追客保留中
    public String CORRESPOND_STATUS_CLOSE             { get{return CommonConst.CORRESPOND_STATUS_CLOSE                  ;} private set; }  // 終了
    public String CORRESPOND_STATUS_APOCANCEL         { get{return CommonConst.CORRESPOND_STATUS_APOCANCEL              ;} private set; }  // アポイントキャンセル
    public String CORRESPOND_STATUS_APOCANCEL_PURSUIT { get{return CommonConst.CORRESPOND_STATUS_APOCANCEL_PURSUIT      ;} private set; }  // アポキャンセル後追客中
    public String CORRESPOND_STATUS_VISITED_PURSUIT   { get{return CommonConst.CORRESPOND_STATUS_VISITED_PURSUIT        ;} private set; }  // 来店後追客中
    public String CORRESPOND_STATUS_APPLCANCEL        { get{return CommonConst.CORRESPOND_STATUS_APPLCANCEL             ;} private set; }  // 申込キャンセル
    public String CORRESPOND_STATUS_APPLCANCEL_PURSUIT{ get{return CommonConst.CORRESPOND_STATUS_APPLCANCEL_PURSUIT     ;} private set; }  // 申込キャンセル後追客中
    public String CORRESPOND_STATUS_ECHOAGGREGATION   { get{return CommonConst.CORRESPOND_STATUS_ECHOAGGREGATION        ;} private set; }  // 反響集約
    private String CORRESPOND_STATUS_TARGET_ECHO_AGGREGATION = '反響集約対象';                                                             // 反響集約対象

    public String CORRESPOND_EVENT_OTHERSTAFFSUPPORTED{ get{return CommonConst.CORRESPOND_EVENT_OTHERSTAFFSUPPORTED     ;} private set; }  // 他スタッフ対応

    public String  ACCOUNT_RECTYPE_CUSTOMER { get{return CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_CUSTOMER);} private set; }   // 顧客：CustomerRecordType
    public String  ACCOUNT_RECTYPE_SUPPLIER { get{return CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_SUPPLIER);} private set; }   // 管理会社・オーナー・サブリース；SupplierRecordType
    public String  ACCOUNT_RECTYPE_FIRE_INSURANCE { get{return CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_FIRE_INSURANCE);} private set; }   // 火災保険会社：FireInsuranceRecordType
    public String  ACCOUNT_RECTYPE_GUARANTEE { get{return CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_GUARANTEE);} private set; }   // 保証会社：GuaranteeRecordType
    public String  ACCOUNT_RECTYPE_AUXILIARY { get{return CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_AUXILIARY);} private set; }   // 付帯業者：AuxiliaryRecordType

    public String PROPERTY_LIVESTATUS_RESIDENT{get{return CommonConst.PROPERTY_LIVESTATUS_RESIDENT;} private set;}   // 居住中

    // public String ACCOUNT_RECTYPE_SUPPLIER { get{return CommonConst.ACCOUNT_RECTYPE_SUPPLIER     ;} private set; }  // 業者

    public Integer COLOR_WHITE { get{return 2;} private set; } //白色
    public Integer COLOR_GRAY_THIN { get{return 2;} private set; } //薄いグレー
    public Integer COLOR_GRAY { get{return 2;} private set; } //グレー    

    /** ボタン位置定数 */
    public Integer BUTTON_MAIL                          { get{return 0;} private set; }     // メール
    public Integer BUTTON_APPOINT_CONFIRMATION          { get{return 1;} private set; }     // アポイント確定
    public Integer BUTTON_VISIT                         { get{return 2;} private set; }     // 来店(iPad)
    public Integer BUTTON_APPLICATION                   { get{return 3;} private set; }     // 申込／申込(iPad)
    public Integer BUTTON_DEPOSIT                       { get{return 4;} private set; }     // 入金
    public Integer BUTTON_CONTRACT_COMPLETED            { get{return 5;} private set; }     // 契約完了
	// ▼ 2021.11.30 LINE連携対応より、ボタン名を修正
	public Integer BUTTON_TEL							{ get{return 6;} private set; }	 // TEL/SMS/メモ
	public Integer BUTTON_LINE							{ get{return 7;} private set; }	 // LINE
	// ▲ 2021.11.30
    public Integer BUTTON_HOLD_FOLLOWER                 { get{return 8;} private set; }     // 追客保留／追客保留解除
    public Integer BUTTON_END                           { get{return 9;} private set; }     // 終了
    public Integer BUTTON_PROPERTY_SEARCH               { get{return 10;} private set; }    // 物件検索
    public Integer BUTTON_NAYORI                        { get{return 11;} private set; }    // 名寄せ
    public Integer BUTTON_APPOINT_CANCEL                { get{return 12;} private set; }    // アポイントキャンセル
    public Integer BUTTON_APPLICATION_CANCEL            { get{return 13;} private set; }    // 申込キャンセル
    public Integer BUTTON_ECHO_AGGREGATION              { get{return 14;} private set; }    // 反響集約
    public Integer BUTTON_SCHEDULE                      { get{return 15;} private set; }    // スケジュール
    public Integer BUTTON_CONSIDER_AFTER_VISITING_STORE { get{return 16;} private set; }    // 来店後検討
    public Integer BUTTON_SET_UP_PERSONNEL              { get{return 17;} private set; }    // 担当者設定
    
    public String accountId { get;set; }        // パラメータ用取引先ID  //問合せNo0531で変更_画面からIDを取得できるようにする
    public String correspondId;                 // パラメータ用対応ID

    public Integer postMode;                    // 住所検索フラグ
    public Integer setStationMode;              // 駅検索フラグ
    public Integer setSchoolMode;               // 問合せ415で追加　学校検索フラグ
    
    /** ローカル変数 */
    private Boolean RefreshCorrespondenceHistory; //対応履歴再表示フラグ
    private boolean RefreshCorrespondenceStatus; //対応状況再表示フラグ
    private Boolean RefreshFavoriteProperty; // お気に入り物件
    private Boolean RefreshExactConditionMatchProperty; // 条件完全一致物件
    private integer openModalFlg;            // 開いたモーダルのフラグ
	// ▼2021.10.08 No.307 対応で削除「取引先保存用希望路線、学区」

    private Integer correspondDetailLimit;  // 対応履歴最大検索数
    

// -----------------------------------------------------------------------------------------------
// 初期処理
// -----------------------------------------------------------------------------------------------
    
    /**
    * 初期表示処理
    */
    public GA102001Controller() {
        isOpenError = false;
        try{
            setCustomersDate();
        }catch (Exception e){
            // エラーを設定
            CommonUtil.setErrorMessage(e);  
            isOpenError = true;
        }
    }

// -----------------------------------------------------------------------------------------------
// 内部クラス
// -----------------------------------------------------------------------------------------------
    /**
    * パラメータの取得
    */
    private void parmAndIsNewSetting(){

        // 取引先ID
        this.accountId = ApexPages.currentPage().getParameters().get('AccountId');

        // 対応ID
        this.correspondId = ApexPages.currentPage().getParameters().get('Corresponds');
		// ▼2022.02.24 値が空文字の場合はnullを設定
		if(String.isBlank(this.accountId)){
			this.accountId = null;
		}

		if(String.isBlank(this.correspondId)){
			this.correspondId = null;
		}
		// ▲2022.02.24 値が空文字の場合はnullを設定
    }

    /**
    * 初期項目制御処理
    */
    private void setCustomersDate(){
        // パラメータの取得
        if (string.isBlank(this.accountId)) {
            parmAndIsNewSetting();
        }
        
        // ログインユーザの情報取得
        Shop__c shop = CommonUtil.getStaffCurrentShop();
        loginStaff = UserInfo.getUserId();     // ログインユーザ
		if(shop != null)loginShop = shop.id;	// ログインユーザ店舗

        //追加要望 追加 Start
        this.isOpetionPorta = AuthorityCheckUtil.getAuthorityOptionPortal(false);
        //追加要望 追加 Start

        //ユーザのプロファイルを取得
        loginUserProfileId = UserInfo.getProfileId();

        // 初期化
        this.screenCorrespondRecordList = new List<screenCorrespond>(); 
        this.screenCorrespondRecord = new Correspond__c();
        this.screenFavoritePropertyList = new List<screenFavoriteProperty>();
        this.screenExactConditionMatchPropertyList = new List<screenExactConditionMatchProperty>();
        this.screenCorrespondDetailList = new List<screenCorrespondDetail>();
        this.screenApplicationList  = new List<screenApplication>();
        this.screenEchoMailList = new List<screenEchoMail>();
        this.introMailInfoList = new List<IntroductionMailInformation__c>();        // 追加要望 追加
        this.screenMemberRecordList = new List<screenMemberRecord>();           // ポータルサイト構築 追加
        this.GA102001Paremeter1 = new GA102001Modal1ParameterClass();
        this.GA102001Paremeter2 = new GA102001Modal2ParameterClass();
        this.GA102001Paremeter3 = new GA102001Modal3ParameterClass();
        this.GA102001Paremeter4 = new GA102001Modal4ParameterClass();
        this.GA102001Paremeter6 = new GA102001Modal6ParameterClass();
        this.GA102001Paremeter7 = new GA102001Modal7ParameterClass();           //追加要望 追加
        this.GA102001Paremeter8 = new GA102001Modal8ParameterClass();
		this.GA102001Paremeter9 = new GA102001Modal9ParameterClass();			// 2021.10.08 No.307 対応で追加
        this.GA102006Parameter = new GA102006ParameterClass();
        this.GA104007Parameter = new GA104007ParameterClass();
        this.GA202002Parameter = new GA202002ParameterClass();                   // 問合せ415で追加　学校選択
        this.GH201003Paremeter = new GH201003ParameterClass();                   // 問合せ423で追加　店舗・地区選択
        this.checkStatus = CommonConst.STRING_EMPTY;
        this.openModalFlg = 0;
        this.checkDistrict = CommonConst.STRING_EMPTY;
        this.checkBuildingproperty = CommonConst.STRING_EMPTY;

		// ▼2021.10.08 No.307 対応で削除「希望駅、希望中学校、希望小学校」

        this.HeaderLockFlg = true;
        // 画面フラグ（表示画面）
        this.isInsertFlg = false;
        this.WarningFlg = false; 
        this.mizukimeFlg = false;
        this.RefreshCorrespondenceHistory = false;
        this.RefreshCorrespondenceStatus = false;
        this.RefreshFavoriteProperty = false;
        this.RefreshExactConditionMatchProperty = false;
        this.EchoAggregationMessageFlg = false;

        List<Member__c> memberList = new List<Member__c>();                  // 本会員の一覧 // ポータルサイト構築 追加

        paramApplication = CommonConst.STRING_EMPTY;

        // システム設定
        this.correspondDetailLimit = Integer.valueOf(SystemConfig__c.getInstance().CorrespondDetailMaxCount__c);

        // ---------------------------------------------------------------------------
        // パラメータの取得によりモードを変更する。
        // ---------------------------------------------------------------------------
        if (!String.isBlank(this.accountId)) {
            // お客様情報のデータを取引先から取得
            // 取引先IDから取引先を取得する。
            accountList = selectAccountInfo(this.accountId);
            if (accountList.size() >  0){
                //問合せNo341で追加
                editFlg = true;
                // 値をセットする。
                screenAccountRecord = new screenAccount(accountList[0]);
                screenAccountRecord_bak = screenAccountRecord.clone();

                // 2020.09.03 名寄せ不要フラグがtrueでない場合、名寄せ完了フラグの確認を行う
                if (screenAccountRecord.IsMergeUnnecessaryFlag == false){
                    screenAccountRecord.IsMergeCompletedFlag = checkIsMergeCompletedFlag(accountList[0]);
                    screenAccountRecord_bak.IsMergeCompletedFlag = screenAccountRecord.IsMergeCompletedFlag;
                }


				// ▼2021.10.08 No.307 対応で変更
				//取引先IDから客様物件情報をセットする。
				setAccountPropertyCondition(accountList[0]);

				// 取れてきたお客様物件条件情報から駅情報をセットする。
				setStation();

				// 問合せ415で追加 取れてきたお客様物件条件情報から学校情報をセットする。
				setSchool();
				// ▲2021.10.08 No.307 対応で変更

                // 新規以外
                // ---------------------------------------------------------------------------
                // 対応状況の取得
                // ---------------------------------------------------------------------------
                this.correspondList = selectCorrespondInfo(this.accountId,CommonConst.STRING_EMPTY);
                if (this.correspondList.size() > 0){
                    // パラメータで対応が取れていない場合は対応状況で取得されているデータから対応状況をセットする。
                    if (String.isBlank(this.correspondId)){
                        this.correspondId = correspondList[0].id;
                    }
                    // リストをセット
                    setCorrespondList(this.correspondList,this.correspondId);
                    // 対応単体取得
                    this.correspondList = selectCorrespondInfo(this.accountId,this.correspondId);
                    if (this.correspondList.size() > 0 ){
                        this.screenCorrespondRecord = this.correspondList[0];
                    }
                }else{
                    // 1件も取得できない状態は1件だけ終了で最新の対応を取得する。
                    List<Correspond__c> correspondEndDate ;                      // 対応の一覧表示
                    correspondEndDate = selectCorrespondInfoAgentEnd(this.accountId);
                    if(correspondEndDate.size() > 0){

                        setCorrespondList(correspondEndDate,this.correspondId);
                    }
                }

                // 追加要望 追加 Start
                // ---------------------------------------------------------------------------
                // 紹介メール情報の取得
                // ---------------------------------------------------------------------------
                this.introMailInfoList = selectIntroMailInfo(this.accountId);
                // 追加要望 追加 End

                // ポータルサイト構築 追加 Start
                // ---------------------------------------------------------------------------
                // 本会員の取得
                // ---------------------------------------------------------------------------
                memberList = selectMember(this.accountId);
                if (memberList.size() > 0){
                    // リストをセット
                    setMemberList(memberList);
                }
                // ポータルサイト構築 追加 End
                // ---------------------------------------------------------------------------
                // お気に入り物件の取得
                // ---------------------------------------------------------------------------
                favoritePropertyList = selectFavoritePropertyInfo(this.accountId,CommonConst.STRING_EMPTY);
                if (favoritePropertyList.size() > 0){
                    // リストをセット
                    setFavoritePropertyList(favoritePropertyList);
                }
                
				// ---------------------------------------------------------------------------
                // 条件完全一致物件の取得
                // ---------------------------------------------------------------------------
                getExactConditionMatchPropertyList();
                
                // ---------------------------------------------------------------------------
                // 空室予約物件明細の設定
                // ---------------------------------------------------------------------------
                this.setScreenVacancyReservationProp();

                // ---------------------------------------------------------------------------
                // 対応履歴（対応明細）の取得
                // ---------------------------------------------------------------------------
                List<CorrespondDetail__c> CorrespondDetailList = selectCorrespondDetailInfo(this.accountId);//2022.01.12 No.489 対応で引数変更
                if (CorrespondDetailList.size() > 0){
                    // リストをセット
                    setCorrespondDetailList(CorrespondDetailList, CommonConst.STRING_EMPTY);//2022.01.12 No.489 対応で引数変更
                }

                // 地区のリスト作成
                selectDistrictList = getSelectDistrictList(this.accountId);

                // ---------------------------------------------------------------------------
                // 申込の取得
                // ---------------------------------------------------------------------------
                this.applicationList = selectApplicationInfo(this.accountId);
                if (this.applicationList.size() > 0){
                    // リストをセット
                    setApplicationList(this.applicationList);
                }

                // ヘッダ部分の出力制御
                setHeaderName(this.screenAccountRecord,this.screenCorrespondRecord);
                newflg = false;

                // 画面スタイルの設定
                this.screenStyle = new screenStyle(this.screenMemberRecordList
                                                   , this.introMailInfoList
                                                   , this.screenApplicationList
                                                   , this.screenFavoritePropertyList
                                                   , this.screenVacancyReservationPropList
                                                   , this.screenExactConditionMatchPropertyList
                                                   , this.screenCorrespondDetailList
                                                   , this.screenEchoMailList);
            }else{
                // 取引先が取れてこない場合編集状態にする
				// ▼2021.10.08 No.307 対応で追加　お客様物件情報をセットする。
				setAccountPropertyCondition(null);
				
                screenAccountRecord = new screenAccount();
                
                screenAccountRecord_bak = screenAccountRecord.clone();
                isInsertFlg = true;  
                newflg = true;
                HeaderLockFlg = false;
				//問合せNo341で追加
				editFlg = false;// 2021.10.08 No.307 対応で追加
            }
            
        }else{
			// ▼2021.10.08 No.307 対応で追加　お客様物件情報をセットする。
			setAccountPropertyCondition(null);

            // 取引先が取れてこない場合編集状態にする
            screenAccountRecord = new screenAccount();
            // パラメータからメールの情報を取得し、メール1に設定する。
            screenAccountRecord.Email = ApexPages.currentPage().getParameters().get('mail');

            screenAccountRecord_bak = screenAccountRecord.clone();
            isInsertFlg = true;  
            newflg = true;
            HeaderLockFlg = false;
            //問合せNo341で追加
            editFlg = false;
        }
        
        // 共通リストボックスの値を設定
        listNewSetting();

        // チェックボックス（オブジェクトはリストボックス）の値を設定
        checkNewSetting();

        // ボタンの設定
        buttonSet();

        // 法人契約
        if (!newflg ){
            if (screenAccountRecord.ContractType == '法人契約'){
                // 法人
                contractTypeFlg = False;
            }else{
                // 個人（法人以外は個人にしておく）
                contractTypeFlg = True;
            }
        }else{
            // 個人（新規はデフォルトで個人）
            contractTypeFlg = True;
        }
    }

    /**
    * リストボックスの設定
    */
    private void listNewSetting(){
        // 都道府県
        this.selectStateList = CommonUtil.getSelectOptionFromObject('Account', 'State__c');
        // 契約形態
        this.selectContractTypeList = CommonUtil.getSelectOptionFromObject('Account', 'ContractType__c',False);
        // 性別リストボックス
        this.selectSexList = CommonUtil.getSelectOptionFromObject('Account', 'Sex__c');
        // 都道府県（会社）
        this.selectCompanyStateList = CommonUtil.getSelectOptionFromObject('Account', 'CompanyState__c');
        // 業種（会社）
        this.selectCompanyIndustriesList = CommonUtil.getSelectOptionFromObject('Account', 'CompanyIndustries__c');
        // 業種（個人）
        this.selectAccountIndustryList = CommonUtil.getSelectOptionFromObject('Account', 'AccountIndustry__c');
        // 職種
        this.selectJobTypeList = CommonUtil.getSelectOptionFromObject('Account', 'JobType__c');
        // 都道府県（勤務先/学校）
        this.selectAffiliationStateList = CommonUtil.getSelectOptionFromObject('Account', 'AffiliationState__c');
		// ▼2021.10.08 No.307 対応で変更
		// 徒歩
		this.selectWalkingTimeList = CommonUtil.getSelectOptionFromObject('AccountPropertyConditions__c', 'WalkingTime__c',false);
		// 占有面積（下限）
		this.selectOccupancyAreaLowerLimitList = CommonUtil.getSelectOptionFromObject('AccountPropertyConditions__c', 'OccupancyAreaLowerLimit__c',false);
		// 占有面積（上限）
		this.selectOccupancyAreaUpperLimitList = CommonUtil.getSelectOptionFromObject('AccountPropertyConditions__c', 'OccupancyAreaUpperLimit__c',false);
		// 築年数
		this.selectBuildingAgeList = CommonUtil.getSelectOptionFromObject('AccountPropertyConditions__c', 'BuildingAge__c',false);
		// ▲2021.10.08 No.307 対応で変更
        //問合せNo341で追加　状況
        this.selectSituationList = CommonUtil.getSelectOptionFromObject('Account', 'Situation__c');
        
        // 路線
        this.selectTrainRoute      = CommonUtil.getSelectOptionFromObjectData('TrainRoute__c','Id','Name','SortOrder__c');
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

    /**
    * チェックボックス（オブジェクトはリストボックス）の設定
    */
    private void checkNewSetting(){

        // ご来店のきっかけ
        this.selectVisitsTriggerList = CommonUtil.getSelectOptionFromObject('Account', 'VisitsTrigger__c', false);
        // ご来店のきっかけ表示用のList,Map設定
        this.VisitsTriggerValueList = new List<String>();
        this.VisitsTriggerNameList  = new Map<String, String>();
        this.VisitsTriggerCheckList = new Map<String, Boolean>();
        for (SelectOption VisitsTrigger : this.selectVisitsTriggerList) {
            String value = VisitsTrigger.getValue();
            String label = VisitsTrigger.getLabel();
            
            
            if (value == '閲覧サイト' || value == 'ご紹介'){
                label += '(※)';
            }
            
            //リスト設定
            this.visitsTriggerValueList.add(value);
            this.visitsTriggerNameList.put(value,label);
            this.visitsTriggerCheckList.put(value,false);
        }
        // 複数選択を別々で切り分ける。
        if (this.screenAccountRecord != null){
            if (this.screenAccountRecord.VisitsTrigger != null){
                list<String> checlkVisitsTriggerList = this.screenAccountRecord.VisitsTrigger.Split(';');
                // 切り分けたデータ分チェックをつける
                for(String VisitsTrigger : checlkVisitsTriggerList){
                    if (this.VisitsTriggerNameList.containsKey(VisitsTrigger)) {
                        this.VisitsTriggerCheckList.put(VisitsTrigger,true);
                    }
                }
            }
        }

        // 閲覧サイト
        this.selectPortalSiteList = CommonUtil.getSelectOptionFromObject('Account', 'PortalSite__c', false);
        // 閲覧サイト表示用のList,Map設定
        this.PortalSiteValueList = new List<String>();
        this.PortalSiteNameList = new Map<String, String>();
        this.PortalSiteCheckList = new Map<String, Boolean>();
        for (SelectOption PortalSite : this.selectPortalSiteList) {
            String value = PortalSite.getValue();
            String label = PortalSite.getLabel();
            this.PortalSiteValueList.add(value);
            this.PortalSiteNameList.put(value,label);
            this.PortalSiteCheckList.put(value,false);
        }
        // 複数選択を別々で切り分ける。
        if (this.screenAccountRecord != null){
            if (this.screenAccountRecord.PortalSite != null){
                list<String> checlkPortalSiteList = this.screenAccountRecord.PortalSite.Split(';');
                // 切り分けたデータ分チェックをつける
                for(String PortalSite : checlkPortalSiteList){
                    if (this.PortalSiteNameList.containsKey(PortalSite)) {
                        this.PortalSiteCheckList.put(PortalSite,true);
                    }
                }
            }
        }

        // 引越理由の選択リスト内容取得
        this.selectHomeMovingReasonList = CommonUtil.getSelectOptionFromObject('Account', 'HomeMovingReason__c', false);
        // 引越理由表示用のList,Map設定(複数選択リスト)
        this.HomeMovingReasonValueList = new List<String>();
        this.HomeMovingReasonNameList = new Map<String, String>();
        this.HomeMovingReasonCheckList = new Map<String, Boolean>();
        for (SelectOption HomeMovingReason : this.selectHomeMovingReasonList) {
            String value = HomeMovingReason.getValue();
            String label = HomeMovingReason.getLabel();

            if (value == '現状不満'){
                label += '(※)';
            }

            this.HomeMovingReasonValueList.add(value);
            this.HomeMovingReasonNameList.put(value,label);
            this.HomeMovingReasonCheckList.put(value,false);
        }
        // 複数選択を別々で切り分ける。
        if (this.screenAccountRecord != null){
            if (this.screenAccountRecord.HomeMovingReason != null){
                list<String> checlkHomeMovingReasonList = this.screenAccountRecord.HomeMovingReason.Split(';');
                // 切り分けたデータ分チェックをつける
                for(String HomeMovingReason : checlkHomeMovingReasonList){
                    if (this.HomeMovingReasonNameList.containsKey(HomeMovingReason)) {
                        this.HomeMovingReasonCheckList.put(HomeMovingReason,true);
                    }
                }
            }
        }
        
        // 契約形態表示用のList,Map設定(複数選択リスト)
        this.ContractTypeValueList = new List<String>();
        this.ContractTypeNameList = new Map<String, String>();
        this.ContractTypeCheckList = new Map<String, Boolean>();
        for (SelectOption ContractType : this.selectContractTypeList) {

            String value = ContractType.getValue();
            String label = ContractType.getLabel();
            this.ContractTypeValueList.add(value);
            this.ContractTypeNameList.put(value,label);
            this.ContractTypeCheckList.put(value,false);
        }
        // 切り分けたデータ分チェックをつける
        if (this.screenAccountRecord != null){
            if (this.ContractTypeNameList.containsKey(this.screenAccountRecord.ContractType)) {
                this.ContractTypeCheckList.put(this.screenAccountRecord.ContractType,true);
            }
        }


        // 引越時期の選択リスト内容取得
        this.selectHomeMovingSeasonList = CommonUtil.getSelectOptionFromObject('Account', 'HomeMovingSeason__c', false);
        // 引越時期表示用のList,Map設定
        this.HomeMovingSeasonValueList = new List<String>();
        this.HomeMovingSeasonNameList = new Map<String, String>();
        this.HomeMovingSeasonCheckList = new Map<String, Boolean>();
        for (SelectOption HomeMovingSeason : this.selectHomeMovingSeasonList) {
            String value = HomeMovingSeason.getValue();
            String label = HomeMovingSeason.getLabel();
            this.HomeMovingSeasonValueList.add(value);
            this.HomeMovingSeasonNameList.put(value,label);
            this.HomeMovingSeasonCheckList.put(value,false);
        }
        // チェックをつける
        if (this.screenAccountRecord != null){
            if (this.HomeMovingSeasonNameList.containsKey(this.screenAccountRecord.HomeMovingSeason)) {
                this.HomeMovingSeasonCheckList.put(this.screenAccountRecord.HomeMovingSeason,true);
            }
        }


    }

    /**
    * ボタンの状態を初期設定
    */
    private Boolean buttonSet(){
        
        //出力用に合わせて変換する。
        buttonSetlist = new Map<String,List<Integer>>();
        buttonState = new Map<Integer, String>();
        buttonURL = new Map<integer,String> ();
        buttonDisabled = new Map<integer,String> ();

        buttonListSet = new List<Integer>();

        // 新規と編集時用でレコードタイプを設定
        string RecordTypeId = CommonConst.STRING_EMPTY;
        if (!String.isBlank(this.accountId)) {
            RecordTypeId = screenAccountRecord.RecordTypeId;
        }

		// ▼ 2021.11.30 LINE連携対応より、ボタン名と不要なコメントを修正
		// ボタンの設定順
		// 0：メール、1：アポイント確定、2：来店Ipad、3：申込（共通）、4：入金、5：契約完了、
		// 6：TEL/SMS/メモ、7：LINE、8：追客保留、9：終了、10：物件検索、11：名寄せ、12：アポキャンセル、
		// 13：申込キャンセル、14：反響集約、15：スケジュール、16：来店後検討
		// ▲ 2021.11.30

        if (RecordTypeId != ACCOUNT_RECTYPE_CUSTOMER){
            // 業者（レコードタイプが顧客以外）
            // 各ステータスによりボタンの設定を行う
            // ｛0:薄グレー、1:グレー、2:青｝
			// ▼ 2021.11.30 LINE連携対応より、TEL/SMS/メモ、LINEのステータスを修正
			buttonSetlist.put(CommonConst.CORRESPOND_STATUS_NOTSUPPORTED	  ,new List<Integer>{2,0,0,0,0,0,2,2,0,1,0,0,0,0,0,0,0,0});   // 未対応
			buttonSetlist.put(CommonConst.CORRESPOND_STATUS_CLOSE			  ,new List<Integer>{2,0,0,0,0,0,2,2,0,1,0,0,0,0,0,0,0,0});   // 終了
			// ▲ 2021.11.30

            // 以降は発生しないステータスではあるが全て押下不可として設定をしておく
            buttonSetlist.put(CommonConst.CORRESPOND_STATUS_PURSUIT           ,new List<Integer>{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0});   // 追客中
            buttonSetlist.put(CommonConst.CORRESPOND_STATUS_APPOINTMENT       ,new List<Integer>{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0});   // アポイント確定
            buttonSetlist.put(CommonConst.CORRESPOND_STATUS_VISITED           ,new List<Integer>{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0});   // 来店済
            buttonSetlist.put(CommonConst.CORRESPOND_STATUS_UNEARNED          ,new List<Integer>{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0});   // 未収入金
            buttonSetlist.put(CommonConst.CORRESPOND_STATUS_DEPOSIT           ,new List<Integer>{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0});   // 入金済
            buttonSetlist.put(CommonConst.CORRESPOND_STATUS_AGREEMENT         ,new List<Integer>{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0});   // 契約完了
            buttonSetlist.put(CommonConst.CORRESPOND_STATUS_PURSUITHOLD       ,new List<Integer>{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0});   // 追客保留中
            buttonSetlist.put(CommonConst.CORRESPOND_STATUS_APOCANCEL         ,new List<Integer>{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0});   // アポイントキャンセル
            buttonSetlist.put(CommonConst.CORRESPOND_STATUS_APOCANCEL_PURSUIT ,new List<Integer>{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0});   // アポキャンセル後追客中
            buttonSetlist.put(CommonConst.CORRESPOND_STATUS_VISITED_PURSUIT   ,new List<Integer>{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0});   // 来店後追客中
            buttonSetlist.put(CommonConst.CORRESPOND_STATUS_APPLCANCEL        ,new List<Integer>{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0});   // 申込キャンセル
            buttonSetlist.put(CommonConst.CORRESPOND_STATUS_APPLCANCEL_PURSUIT,new List<Integer>{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0});   // 申込キャンセル後追客中
            buttonSetlist.put(CommonConst.CORRESPOND_STATUS_ECHOAGGREGATION   ,new List<Integer>{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0});   // 反響集約
            buttonSetlist.put(CommonConst.CORRESPOND_STATUS_CONSIDERVISITING  ,new List<Integer>{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0});   // 来店後検討
            buttonSetlist.put(CommonConst.STRING_EMPTY                        ,new List<Integer>{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0});   // 取引先なし

			// ▼ 2021.11.30 LINE連携対応より、ステータスが終了の場合はメモのみ開くよう修正
			if (this.screenCorrespondRecordList.size() > 0) {

				Set<String> notDispStatusSet = new Set<String> {
					CORRESPOND_STATUS_NOTSUPPORTED,
					CORRESPOND_STATUS_CLOSE
				};

				this.setDispCorrespondType(notDispStatusSet);
			}
			// ▲ 2021.11.30 
        }else{     
            if(screenAccountRecord.IsMergeCompletedFlag){
				// ▼ 2021.11.30 LINE連携対応より、TEL/SMS/メモ、LINEのステータスを修正
				// 名寄せ完了時に名寄せボタンを制御（完全押下不可となる）
				// 各ステータスによりボタンの設定を行う
				// ｛0:薄グレー、1:グレー、2:青｝
				buttonSetlist.put(CommonConst.CORRESPOND_STATUS_NOTSUPPORTED	  ,new List<Integer>{2,2,0,0,0,0,1,2,0,0,2,0,0,0,0,1,0}); // 未対応
				buttonSetlist.put(CommonConst.CORRESPOND_STATUS_PURSUIT			  ,new List<Integer>{2,2,0,0,0,0,1,2,1,1,2,0,0,0,0,1,0}); // 追客中
				buttonSetlist.put(CommonConst.CORRESPOND_STATUS_APPOINTMENT		  ,new List<Integer>{1,0,2,0,0,0,1,1,0,0,2,0,2,0,0,1,0}); // アポイント確定
				buttonSetlist.put(CommonConst.CORRESPOND_STATUS_VISITED			  ,new List<Integer>{0,0,0,2,0,0,1,0,0,1,2,0,0,0,0,1,2}); // 来店済
				buttonSetlist.put(CommonConst.CORRESPOND_STATUS_UNEARNED		  ,new List<Integer>{1,0,0,2,2,0,1,1,0,0,1,0,0,2,0,1,0}); // 未収入金
				buttonSetlist.put(CommonConst.CORRESPOND_STATUS_DEPOSIT			  ,new List<Integer>{1,0,0,2,0,2,1,1,0,0,1,0,0,2,0,1,0}); // 入金済
				buttonSetlist.put(CommonConst.CORRESPOND_STATUS_AGREEMENT		  ,new List<Integer>{1,0,0,0,0,0,1,1,0,0,1,0,0,2,0,1,0}); // 契約完了
				buttonSetlist.put(CommonConst.CORRESPOND_STATUS_PURSUITHOLD		  ,new List<Integer>{1,1,0,0,0,0,1,1,2,1,1,0,0,0,0,1,0}); // 追客保留中
				buttonSetlist.put(CommonConst.CORRESPOND_STATUS_APOCANCEL		  ,new List<Integer>{2,2,0,0,0,0,1,2,1,1,2,0,0,0,0,1,0}); // アポイントキャンセル
				buttonSetlist.put(CommonConst.CORRESPOND_STATUS_APOCANCEL_PURSUIT ,new List<Integer>{2,2,0,0,0,0,1,2,1,1,2,0,0,0,0,1,0}); // アポキャンセル後追客中
				buttonSetlist.put(CommonConst.CORRESPOND_STATUS_VISITED_PURSUIT   ,new List<Integer>{2,2,0,2,0,0,1,2,1,1,2,0,0,0,0,1,0}); // 来店後追客中
				buttonSetlist.put(CommonConst.CORRESPOND_STATUS_APPLCANCEL		  ,new List<Integer>{2,2,0,2,0,0,1,2,1,1,2,0,0,0,0,1,0}); // 申込キャンセル
				buttonSetlist.put(CommonConst.CORRESPOND_STATUS_APPLCANCEL_PURSUIT,new List<Integer>{2,2,0,2,0,0,1,2,1,1,2,0,0,0,0,1,0}); // 申込キャンセル後追客中
				buttonSetlist.put(CommonConst.CORRESPOND_STATUS_CLOSE			  ,new List<Integer>{1,1,0,0,0,0,1,1,0,1,1,0,0,0,0,1,0}); // 終了
				buttonSetlist.put(CommonConst.CORRESPOND_STATUS_ECHOAGGREGATION   ,new List<Integer>{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}); // 反響集約
				buttonSetlist.put(CommonConst.CORRESPOND_STATUS_CONSIDERVISITING  ,new List<Integer>{2,2,0,2,0,0,1,2,1,1,1,0,0,0,0,1,0}); // 来店後検討
				buttonSetlist.put(CommonConst.STRING_EMPTY						  ,new List<Integer>{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}); // 取引先なし
				// ▲ 2021.11.30 
            }else{
                
				// ▼ 2021.11.30 LINE連携対応より、TEL/SMS/メモ、LINEのステータスを修正
				// 各ステータスによりボタンの設定を行う
				// ｛0:薄グレー、1:グレー、2:青｝
				buttonSetlist.put(CommonConst.CORRESPOND_STATUS_NOTSUPPORTED	  ,new List<Integer>{2,2,0,0,0,0,1,2,0,0,2,2,0,0,0,1,0}); // 未対応
				buttonSetlist.put(CommonConst.CORRESPOND_STATUS_PURSUIT			  ,new List<Integer>{2,2,0,0,0,0,1,2,1,1,2,1,0,0,0,1,0}); // 追客中
				buttonSetlist.put(CommonConst.CORRESPOND_STATUS_APPOINTMENT		  ,new List<Integer>{1,0,2,0,0,0,1,1,0,0,2,1,2,0,0,1,0}); // アポイント確定
				buttonSetlist.put(CommonConst.CORRESPOND_STATUS_VISITED			  ,new List<Integer>{0,0,0,2,0,0,1,0,0,1,2,1,0,0,0,1,2}); // 来店済
				buttonSetlist.put(CommonConst.CORRESPOND_STATUS_UNEARNED		  ,new List<Integer>{1,0,0,2,2,0,1,1,0,0,1,1,0,2,0,1,0}); // 未収入金
				buttonSetlist.put(CommonConst.CORRESPOND_STATUS_DEPOSIT			  ,new List<Integer>{1,0,0,2,0,2,1,1,0,0,1,1,0,2,0,1,0}); // 入金済
				buttonSetlist.put(CommonConst.CORRESPOND_STATUS_AGREEMENT		  ,new List<Integer>{1,0,0,0,0,0,1,1,0,0,1,1,0,2,0,1,0}); // 契約完了
				buttonSetlist.put(CommonConst.CORRESPOND_STATUS_PURSUITHOLD		  ,new List<Integer>{1,1,0,0,0,0,1,1,2,1,1,1,0,0,0,1,0}); // 追客保留中
				buttonSetlist.put(CommonConst.CORRESPOND_STATUS_APOCANCEL		  ,new List<Integer>{2,2,0,0,0,0,1,2,1,1,2,1,0,0,0,1,0}); // アポイントキャンセル
				buttonSetlist.put(CommonConst.CORRESPOND_STATUS_APOCANCEL_PURSUIT ,new List<Integer>{2,2,0,0,0,0,1,2,1,1,2,1,0,0,0,1,0}); // アポキャンセル後追客中
				buttonSetlist.put(CommonConst.CORRESPOND_STATUS_VISITED_PURSUIT   ,new List<Integer>{2,2,0,2,0,0,1,2,1,1,2,1,0,0,0,1,0}); // 来店後追客中
				buttonSetlist.put(CommonConst.CORRESPOND_STATUS_APPLCANCEL		  ,new List<Integer>{2,2,0,2,0,0,1,2,1,1,2,1,0,0,0,1,0}); // 申込キャンセル
				buttonSetlist.put(CommonConst.CORRESPOND_STATUS_APPLCANCEL_PURSUIT,new List<Integer>{2,2,0,2,0,0,1,2,1,1,2,1,0,0,0,1,0}); // 申込キャンセル後追客中
				buttonSetlist.put(CommonConst.CORRESPOND_STATUS_CLOSE			  ,new List<Integer>{1,1,0,0,0,0,1,1,0,1,1,1,0,0,0,1,0}); // 終了
				buttonSetlist.put(CommonConst.CORRESPOND_STATUS_ECHOAGGREGATION   ,new List<Integer>{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}); // 反響集約
				buttonSetlist.put(CommonConst.CORRESPOND_STATUS_CONSIDERVISITING  ,new List<Integer>{2,2,0,2,0,0,1,2,1,1,1,1,0,0,0,1,0}); // 来店後検討
				buttonSetlist.put(CommonConst.STRING_EMPTY						  ,new List<Integer>{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}); // 取引先なし
				// ▲ 2021.11.30 
            }
        }
        
        //▼問合せNo341で変更
        if(RecordTypeId == ACCOUNT_RECTYPE_CUSTOMER
            && this.checkStatus == CORRESPOND_STATUS_NOTSUPPORTED
            &&( (screenAccountRecord.Situation == CommonConst.CORRESPONDDETAIL_PHONESTATUS_ECHO && !screenAccountRecord.EchoTelephoneFlag)
            //▼問合せNo411で変更
            || (screenAccountRecord.Situation == CommonConst.CORRESPONDDETAIL_PHONESTATUS_LIVEROECHO && !screenAccountRecord.EchoLiveroFlag)
            || (screenAccountRecord.Situation == CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINEECHO && !screenAccountRecord.EchoLineFlag) )){
            //▲問合せNo341で変更
            // 電話反響選択時に6：TEL/SMSのみ押下できるようボタン制御　問合せ416で検索ボタンも押下できるように変更
            buttonSetlist.put(CommonConst.CORRESPOND_STATUS_NOTSUPPORTED      ,new List<Integer>{0,0,0,0,0,0,2,0,0,0,2,0,0,0,0,0,0});   // 未対応
            
            if(!screenAccountRecord.IsMergeCompletedFlag){
                //電話反響かつ名寄せ未完了の場合
                buttonSetlist.put(CommonConst.CORRESPOND_STATUS_NOTSUPPORTED      ,new List<Integer>{0,0,0,0,0,0,2,0,0,0,2,1,0,0,0,0,0});   // 未対応
            }

			// ▼ 2021.11.30 LINE連携対応より、電話反響時は電話のみ開くよう修正
			Set<String> notDispStatusSet = new Set<String> {
				CORRESPOND_STATUS_NOTSUPPORTED
			};

			this.setDispCorrespondType(notDispStatusSet);
			// ▲ 2021.11.30 
        }
        
        // 反響集約対象のボタンを設定（反響集約ボタンのみ押下可）
        buttonSetlist.put(CORRESPOND_STATUS_TARGET_ECHO_AGGREGATION, new List<Integer>{0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0});

        // メールアドレスが登録されていなければメールのボタンを押下させない
        if(this.screenAccountRecord != null ){    
            // メールが無かったらマップをループで回してない状態にする。
            if(string.isBlank(screenAccountRecord.Email) && string.isBlank(screenAccountRecord.Email2) && string.isBlank(screenAccountRecord.Email3)){
                for(List<integer> buttonList  : buttonSetlist.values()){
                    buttonList[BUTTON_MAIL] = 0;
                }
            }
        }

		//▼2022.05.16問合せNo.0816 対応
        //LINE会員IDの取得
        LineMember__c lineMember = this.selectLineMember(this.screenAccountRecord.Id);
		//LINE会員チェック
        if (String.isBlank(lineMember.Id)) {
			for(List<integer> buttonList  : buttonSetlist.values()){
				buttonList[BUTTON_LINE] = 0;
			}
		}
        //▲2022.05.16問合せNo.0816 対応


        buttonListSet = new List<Integer>{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};   // 取引先なし

        // ボタンの設定をする。
        buttonState.put(0,'menu_btn_inactive');         // 薄グレー
        buttonState.put(1,'menu_btn_active');           // グレー
        buttonState.put(2,'menu_btn_recommend');        // 青

        // URLを設定する
        buttonURL.put(0,'gr');
        buttonURL.put(1,'wh');
        buttonURL.put(2,'wh');

        // 押下制御
        buttonDisabled.put(0,'none');
        buttonDisabled.put(1,CommonConst.STRING_EMPTY);
        buttonDisabled.put(2,CommonConst.STRING_EMPTY);

        setButtonList();
        //配列に入れ込む
        return True;
    }

    /**
     * 取得したデータを一覧にセットする。　
     * 引数　　：　correspondList List<Correspond__c> 対応状況一覧用データ
     * 　　　　：  CorrespondiD String 対応ID
     */
    private void setCorrespondList(List<Correspond__c> correspondList,String CorrespondiD){
        Integer count = 0 ;
        this.EchoAggregationMessageFlg = false;     // 反響集約メッセージフラグを初期化
        integer enabledCorrespondCount = 0;         // 有効な対応件数

        Boolean notselectflg = false;               // 対応状況が選択されていないかどうか
        Boolean echoAggregationSourceFlg = false;   // 反響集約元があるかのフラグ

        //内部クラスに値をセットする。
        for(Correspond__c candidate :correspondList) {
            //出力用に合わせて変換する。
            screenCorrespond screenTargetRecord = new screenCorrespond(candidate);

            // 対応IDがパラメータと同じであればチェックを付ける。
            if (candidate.Id == CorrespondiD){
                // 選択されている状態の項目を取得する。
                
                checkCorrespondIndex = count;
                screenTargetRecord.isSelected = True;
                checkStatus = screenTargetRecord.status;
                checkEvent = screenTargetRecord.event;
                checkCorrespondId = screenTargetRecord.Id;
                checkDistrict = screenTargetRecord.District;
                checkBuildingproperty = screenTargetRecord.buildingproperty;
                checkProperty = screenTargetRecord.Property;
                checkApplication = screenTargetRecord.Application;
                checkEchoStaff = screenTargetRecord.echoStaffName;
                checkShopStaff = screenTargetRecord.shopStaffName;
                checkPursuitDissolveDate = screenTargetRecord.PursuitDissolveDate;
                notselectflg = true;

            }
            count ++;

            // 有効な対応のカウントを取る。
            if(setEnabledCorrespondCount(screenTargetRecord)){
                enabledCorrespondCount ++;
            }            

            // 反響集約レコードチェック
            if(isEchoAggregationRecord(screenTargetRecord)){
                echoAggregationSourceFlg = true;
            }

            //配列に入れ込む
            screenCorrespondRecordList.add(screenTargetRecord);
        }

        // 有効な対応状況の件数が2件以上あり、反響集約元が存在している場合、反響集約メッセージフラグをtrueにする。
        if(enabledCorrespondCount >= 2 && echoAggregationSourceFlg){
            this.EchoAggregationMessageFlg = true;              
        }

        // チェックした対応状況が表示対象外かを確認
        if(!notselectflg && screenCorrespondRecordList.size() > 0 ){
            // チェック対象が判別できない場合に1行目をチェックの対象とする（新規の場合は除く）。
        
            checkCorrespondIndex = 0;
            screenCorrespondRecordList[0].isSelected = True;
            checkStatus = screenCorrespondRecordList[0].status;
            checkEvent = screenCorrespondRecordList[0].event;
            checkCorrespondId = screenCorrespondRecordList[0].Id;
            checkDistrict = screenCorrespondRecordList[0].District;
            checkBuildingproperty = screenCorrespondRecordList[0].buildingproperty;
            checkProperty = screenCorrespondRecordList[0].Property;
            checkApplication = screenCorrespondRecordList[0].Application;
            checkEchoStaff = screenCorrespondRecordList[0].echoStaffName;
            checkShopStaff = screenCorrespondRecordList[0].shopStaffName;
            checkPursuitDissolveDate = screenCorrespondRecordList[0].PursuitDissolveDate;
            this.correspondId = checkCorrespondId;
        }

    }

    /**
     * 有効な対応をカウントする
     * 引数　　：screenTargetRecord screenCorrespond 画面に出力する対応のデータ
     * 戻り値　：Integer 有効な対応のカウント
     */
    private Boolean setEnabledCorrespondCount(screenCorrespond screenTargetRecord){

        // ステータスが終了、契約完了、反響集約以外
        if (!(screenTargetRecord.status == CORRESPOND_STATUS_CLOSE || 
              screenTargetRecord.status == CORRESPOND_STATUS_AGREEMENT || 
              screenTargetRecord.status == CORRESPOND_STATUS_ECHOAGGREGATION)){
            return true;
        }

        return false;
    }
    
    /**
     * 反響集約レコードチェック
     * 引数　　：screenTargetRecord screenCorrespond 画面に出力する対応のデータ
     * 戻り値　：Boolean true:対象レコード、false:対象外レコード
     */
    private Boolean isEchoAggregationRecord(screenCorrespond screenTargetRecord){
        
        // 反響集約のステータス
        Set<String> echoAggregationStatus = new Set<String> {
            CORRESPOND_STATUS_NOTSUPPORTED         // 未対応
            , CORRESPOND_STATUS_PURSUIT            // 追客中
            , CORRESPOND_STATUS_APOCANCEL_PURSUIT  // アポキャンセル後追客中
        };
        
        // 反響集約チェック
        if (echoAggregationStatus.contains(screenTargetRecord.Status)
            && screenTargetRecord.echoAggregationFlg){
            return true;
        }
        return false;
    }
 
    // ポータルサイト構築 追加 Start
    /**
     * 取得したデータを一覧にセットする。　
     * 引数　　：　memberList List<Member__c> 本会員一覧用データ
     */
    private void setMemberList(List<Member__c> memberList){
        //内部クラスに値をセットする。
        for(Member__c member :memberList) {
            //出力用に合わせて変換する。
            screenMemberRecord screenTargetRecord = new screenMemberRecord(member);
            //配列に入れ込む
            this.screenMemberRecordList.add(screenTargetRecord);
        }
    }
    // ポータルサイト構築 追加 End

 
    /**
     * 取得したデータを一覧にセットする。　
     * 引数　　：　favoritePropertyList List<FavoriteProperty__c> お気に入り物件一覧用データ
     */
    private void setFavoritePropertyList(List<FavoriteProperty__c> favoritePropertyList){
        //内部クラスに値をセットする。
        for(FavoriteProperty__c candidate :favoritePropertyList) {
            //出力用に合わせて変換する。
            screenFavoriteProperty screenTargetRecord = new screenFavoriteProperty(candidate);
            //配列に入れ込む
            screenFavoritePropertyList.add(screenTargetRecord);
        }
    }

     /**
     * 取得したデータを一覧にセットする。　
     * 引数　　：　exactConditionMatchPropertyList List<ExactConditionMatchProperty__c> 条件完全一致物件一覧用データ
     */
    private void setExactConditionMatchPropertyList(List<ExactConditionMatchProperty__c> exactConditionMatchPropertyList){
        screenExactConditionMatchProperty screenTargetRecord;
        //内部クラスに値をセットする。
        for(ExactConditionMatchProperty__c candidate :exactConditionMatchPropertyList) {
            //出力用に合わせて変換する。
            screenTargetRecord = new screenExactConditionMatchProperty(candidate);
            //配列に入れ込む
            screenExactConditionMatchPropertyList.add(screenTargetRecord);
        }
    }

    /**
     * 取得したデータを一覧にセットする。
     * @param List<Application__c> Application__cList 対応履歴（対応明細）一覧用データ
	 * @param String district 絞り込み用の地区
     */
    private void setCorrespondDetailList(List<CorrespondDetail__c> CorrespondDetailList, String district){

        List<AggregateResult> AttachmentList = new List<AggregateResult>();
        screenEchoMailList = new List<screenEchoMail>();
        
        //添付ファイルを取得するためのIDリスト
        List<Id> attachmentIdList = new List<Id>();
        
        for(CorrespondDetail__c CorrespondDetail :CorrespondDetailList) {                                  
			//絞り込み用の地区が存在し、対応の地区と一致しない場合は添付IDをセットしない
			if(!String.isBlank(district) && !district.equals(CorrespondDetail.Corresponds__r.District__c))continue;////▼ 2022.01.12 No.489

            if(!string.isBlank(CorrespondDetail.EchoMail__c)){
                attachmentIdList.add(CorrespondDetail.EchoMail__c);
            }else if(CorrespondDetail.CorrespondType__c == CommonConst.TASK_CORRESPONDTYPE_MAIL){ //対応種別がメール
                attachmentIdList.add(CorrespondDetail.Id);
            }
        }
 
        if (attachmentIdList.size() > 0) {         
            // 対象の添付IDを持ってくる
            AttachmentList = [
                select ParentId
                from   Attachment
                where  ParentId in :attachmentIdList
                group by  ParentId
            ];   
        }                   
 
        //内部クラスに値をセットする。
        for(CorrespondDetail__c CorrespondDetail :CorrespondDetailList) {
            // 対応明細の反響メールがあれば反響一覧にセットする。
            if(!string.isBlank(CorrespondDetail.EchoMail__c)){

                // 反響メールリストをセット(ポータルサイトURLがあることで問い合わせメールであると判断)
                if(!string.isBlank(CorrespondDetail.PortalSiteUrl__c)){
                    setEchoMailList(CorrespondDetail);                    
                }
                // ヘッダ部分の出力制御
                setHeaderName(screenAccountRecord,screenCorrespondRecord);
            }
          
			//▼ 2022.01.12 No.489 地区による絞り込みを反響一覧に反映させないよう修正、反響一覧登録フラグがtrueであれば、反響一覧に追加
			if(CorrespondDetail.FirstInquiryPropertyShowFlg__c) {
				setEchoMailList(CorrespondDetail);
			}

			//絞り込み用の地区が存在し、対応の地区と一致しない場合は対応履歴を表示しない
			if(!String.isBlank(district) && !district.equals(CorrespondDetail.Corresponds__r.District__c))continue;

			screenCorrespondDetail screenTargetRecord = new screenCorrespondDetail(CorrespondDetail);
			//▲ 2022.01.12 No.489 地区による絞り込みを反響一覧に反映させないよう修正、反響一覧登録フラグがtrueであれば、反響一覧に追加

            //取込ボタンの制御
            for(AggregateResult Attachment : AttachmentList) {
                String Id = String.valueOf(Attachment.get('ParentId'));                
                if(Id == CorrespondDetail.EchoMail__c || Id == CorrespondDetail.ID){                    
                    // 添付があればフラグを立てる   
                    screenTargetRecord.AttachmentsFlg = true;                      
                }               
            }

			//▼ 2022.01.12 No.489 地区による絞り込みを反響一覧に反映させないよう処理移動
            
            //配列に入れ込む
            screenCorrespondDetailList.add(screenTargetRecord);
        }
    }

    /**
     * 店舗のリストを取得する
     * 引数　　： accountId string 取引先ID
     * 戻り値　： List<SelectOption> 対応明細に紐づく地区の一覧
     */
    private List<SelectOption> getSelectDistrictList(String accountId){
        List<SelectOption> options = new List<SelectOption>();
        List<CorrespondDetail__c> setCorrespondDetailDistrictList = new List<CorrespondDetail__c>();    // 絞り込み用対応明細の地区一覧
        String setDistrict = CommonConst.STRING_EMPTY;

        // 地区のリストボックスを設定する。
        setCorrespondDetailDistrictList = selectDistrictGroup(accountId);

        options.add(new SelectOption(CommonConst.STRING_EMPTY,CommonConst.SELECTION_LIST_NULL));

        if (setCorrespondDetailDistrictList.size() > 0){
            // 取ってきた内容をセットする                
            for(CorrespondDetail__c value : setCorrespondDetailDistrictList){
                if (value.Corresponds__r.District__c == null ){
                    continue;
                }

                if (value.Corresponds__r.District__c != setDistrict){
                    options.add(new Selectoption(value.Corresponds__r.District__c,value.Corresponds__r.District__c));
                    setDistrict = value.Corresponds__r.District__c ;
                }else{
                    setDistrict = value.Corresponds__r.District__c ;
                }
            }   
        }
               
        return options;

    }

    /**
     * 取得したデータを一覧にセットする。　
     * 引数　　：　Application__cList List<Application__c__c> 申込一覧用データ
     */
    private void setApplicationList(List<Application__c> ApplicationList){
        this.screenApplicationList  = new List<screenApplication>();
        //内部クラスに値をセットする。
        for(Application__c candidate :ApplicationList) {
            //出力用に合わせて変換する。
            screenApplication screenTargetRecord = new screenApplication(candidate);

            //配列に入れ込む
            screenApplicationList.add(screenTargetRecord);
        }
    }

    /**
     * 取得したデータを一覧にセットする。　
     * 引数　　：  CorrespondDetail CorrespondDetail__c 対応明細（反響メールが紐づいているデータ）
     */
    private void setEchoMailList(CorrespondDetail__c CorrespondDetail){
        //出力用に合わせて変換する。
        screenEchoMail screenTargetRecord = new screenEchoMail(CorrespondDetail);

        //配列に入れ込む
        screenEchoMailList.add(screenTargetRecord);
    }

    /**
     * ヘッダ部分の出力を設定
     * 引数　　：　
     */
    private void setHeaderName(screenAccount AccountDate,Correspond__c CorrespondRecord ){
        this.screenHeaderRecord = CommonConst.STRING_EMPTY;
        if (!string.isblank(AccountDate.name)){
            this.screenHeaderRecord += AccountDate.name;
        }
        if (!string.isblank(AccountDate.Phone)){
            this.screenHeaderRecord += ' | ' + AccountDate.Phone;
        }
        if (!string.isblank(CorrespondRecord.status__c)){
            this.screenHeaderRecord += ' | ' + CorrespondRecord.Status__c;
        }
        if (!string.isblank(CorrespondRecord.Event__c)){
            this.screenHeaderRecord += ' | ' + CorrespondRecord.Event__c;
        }
        if (CorrespondRecord.EventDateTime__c != null){
            this.screenHeaderRecord += ' | ' + CorrespondRecord.EventDateTime__c.format('yyyy/MM/dd HH:mm', 'JST');
        }
    }

	// ▼2021.10.08 No.307 対応で追加
	/**
	 * お客様物件条件セット
	 * @param Account acc 取引先情報
	 * @return void
	 */
	private void setAccountPropertyCondition(Account acc){
		List<AccountPropertyConditions__c> accountPCList = new List<AccountPropertyConditions__c>();
		if(!String.isBlank(this.accountId)) accountPCList = getAccountPropertyConditions(this.accountId);
		this.screenPropertyConditionsMap = new Map<String, screenPropertyConditions>();
		this.currentScreenPropertyCondition = new screenPropertyConditions();
		//お客様物件条件の選択リスト
		this.AccountPropertyConditions = new List<SelectOption>();
		//取引先の物件条件名
		String accName = '';

		// 取引先からお客様物件条件の値をセットする
		if((acc != null) && (acc != new Account())){
			accName = acc.PropertyConditionsName__c;

			this.screenPropertyConditionsMap.put(accName, new screenPropertyConditions(acc));
			this.AccountPropertyConditions.add(new SelectOption(acc.Id, accName));
			if(String.valueOf(acc.Id).Equals(this.selectCondName)){
				this.currentScreenPropertyCondition = this.screenPropertyConditionsMap.get(accName);
			}
		}else{
			//取引先が取得されていない場合、条件1をMapに追加する。
			accName = '条件1';
			screenPropertyConditions spc = new screenPropertyConditions();
			spc.accountFlg = true;
			this.screenPropertyConditionsMap.put(accName, spc);
			this.currentScreenPropertyCondition = this.screenPropertyConditionsMap.get(accName);
			this.currentScreenPropertyCondition.Name = accName;
			// ▼ 2022.01.21 No.307 対応で選択リストの値の矛盾修正
			this.AccountPropertyConditions.add(new SelectOption(accName, accName));
			// ▲ 2022.01.21 No.307 対応で選択リストの値の矛盾修正
		}
		// お客様物件条件レコードからお客様物件条件の値をセットする
		if(accountPCList.size() > 0){
			for(AccountPropertyConditions__c apc : accountPCList){
				this.screenPropertyConditionsMap.put(apc.Name, new screenPropertyConditions(apc));
				this.AccountPropertyConditions.add(new SelectOption(apc.Id, apc.Name));
				if(String.valueOf(apc.Id).Equals(this.selectCondName)){
					this.currentScreenPropertyCondition = this.screenPropertyConditionsMap.get(apc.Name);
				}
			}
		}
		//表示
		if(String.isBlank(this.currentScreenPropertyCondition.Name)){
			this.currentScreenPropertyCondition = this.screenPropertyConditionsMap.get(accName);
		}
		//お客様条件件数セット
		this.screenPropertyConditionsRecSize = String.valueOf(accountPCList.size());
		// ▼ 2022.01.21 No.307 対応で初期の物件条件名を保持
		this.tmpCondName = this.currentScreenPropertyCondition.Name;
		// ▲ 2022.01.21 No.307 対応
	}
	// ▲2021.10.08 No.307 対応で追加

	// ▼2021.10.08 No.307 対応で変更　駅、学校情報を複数のお客様物件条件にセットするよう対応
	/**
	 * 駅情報セット
	*/
	private void setStation(){

		Map<Id, List<Station__c>> stationMap = selectTrain();// 指定した希望路線の情報を取得

		for(String key : screenPropertyConditionsMap.keySet()){
			screenPropertyConditions targetCond = screenPropertyConditionsMap.get(key);
			targetCond.stations1 = NEW List<Station__c>();//希望駅の初期化
			targetCond.stations2 = NEW List<Station__c>();//希望駅の初期化
			targetCond.stations3 = NEW List<Station__c>();//希望駅の初期化
			targetCond.stationsChar1 = '';
			targetCond.stationsChar2 = '';
			targetCond.stationsChar3 = '';

			if (stationMap.containskey(targetCond.desiredTrainRoute1)) {//希望路線の選択済希望駅をmapで取得
				targetCond.stations1	= stationMap.get(targetCond.desiredTrainRoute1);		// 駅１
				targetCond.stationsChar1 = convStationListToString(stationMap.get(targetCond.desiredTrainRoute1));
			}
			if (stationMap.containskey(targetCond.desiredTrainRoute2)) {//希望路線の選択済希望駅をmapで取得
				targetCond.stations2	= stationMap.get(targetCond.desiredTrainRoute2);		// 駅２
				targetCond.stationsChar2 = convStationListToString(stationMap.get(targetCond.desiredTrainRoute2));
			}
			if (stationMap.containskey(targetCond.desiredTrainRoute3)) {//希望路線の選択済希望駅をmapで取得
				targetCond.stations3	= stationMap.get(targetCond.desiredTrainRoute3);		// 駅３
				targetCond.stationsChar3 = convStationListToString(stationMap.get(targetCond.desiredTrainRoute3));
			}
		}
	}

	/**
	 * 指定した取引先の希望路線の情報を取得
	 *
	 * @return  Map<Id, List<Station__c>>   取引先の希望条件に関連する駅
	 */
	private Map<Id, List<Station__c>> selectTrain() {

		Set<Id> ids = new Set<Id>();
		Map<Id, List<Station__c>> result = new Map<Id, List<Station__c>>();//map設定
		for(String key : screenPropertyConditionsMap.keySet()){
			screenPropertyConditions targetCond = screenPropertyConditionsMap.get(key);
			//選択している希望路線のIDをリストにする
			if(targetCond.desiredTrainRoute1 != null){
				ids.add(targetCond.desiredTrainRoute1);
			}

			if(targetCond.DesiredTrainRoute2 != null){
				ids.add(targetCond.desiredTrainRoute2);
			}

			if(targetCond.DesiredTrainRoute3 != null){
				ids.add(targetCond.desiredTrainRoute3);
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

	// ▼問合せ415で追加
	/**
	 * 学校情報セット
	 */
	private void setSchool(){

		Map<id, List<school__c>> schoolMap = selectSchool();// 指定した希望路線の情報を取得

		for(String key : screenPropertyConditionsMap.keySet()){
			screenPropertyConditions targetCond = screenPropertyConditionsMap.get(key);
			targetCond.juniorHighSchoolList = new List<School__c>();//希望中学校の初期化
			targetCond.elementarySchoolList = new List<School__c>();//希望小学校の初期化
			targetCond.desiredJuniorHighSchool = '';
			targetCond.desiredPrimarySchool = '';
			
			if (schoolMap.containskey(targetCond.juniorHighSchoolDistrict)) {//希望学区の選択済希望中学校をmapで取得
				targetCond.juniorHighSchoolList	= schoolMap.get(targetCond.juniorHighSchoolDistrict);		// 中学校
				targetCond.desiredJuniorHighSchool = convSchoolListToString(schoolMap.get(targetCond.juniorHighSchoolDistrict));
			}
			if (schoolMap.containskey(targetCond.elementarySchoolDistrict)) {//希望学区の選択済希望小学校をmapで取得
				targetCond.elementarySchoolList	= schoolMap.get(targetCond.elementarySchoolDistrict);		// 小学校
				targetCond.desiredPrimarySchool = convSchoolListToString(schoolMap.get(targetCond.elementarySchoolDistrict));
			}
		}
	}

	/**
	 * 指定した取引先の希望学校の情報を取得
	 *
	 * @return  Map<Id, List<Station__c>>   取引先の希望条件に関連する学校
	 */
	private Map<Id, List<School__c>> selectSchool() {

		Set<Id> ids = new Set<Id>();
		// 値を返すマップ
		Map<id, List<school__c>> result = new Map<id, List<school__c>>();
		for(String key : screenPropertyConditionsMap.keySet()){
			screenPropertyConditions targetCond = screenPropertyConditionsMap.get(key);
			//選択している希望学区のIDをリストにする
			if(targetCond.juniorHighSchoolDistrict != null){
				ids.add(targetCond.juniorHighSchoolDistrict);
			}

			if(targetCond.elementarySchoolDistrict != null){
				ids.add(targetCond.elementarySchoolDistrict);
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
	// ▲2021.10.08 No.307 対応で変更　駅、学校情報を複数のお客様物件条件にセットするよう対応

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

    /**
     * 入力チェック
     * 引数　　：　
     * 戻り値　：  エラー有無
     */
    private BusinessLogicException inputCheck(){
        BusinessLogicException inputCheckex = new BusinessLogicException();

        // 契約形態必須
        if (String.isblank(screenAccountRecord.ContractType)){
            inputCheckex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED,'契約形態'));
        }

        // お客様名必須
        if (String.isblank(screenAccountRecord.LastName) && String.isblank(screenAccountRecord.FirstName)){
            inputCheckex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED,'お客様名の 姓 もしくは 名 どちらか'));
        }

        // お客様名_フリガナ必須
        if (String.isblank(screenAccountRecord.LastNameKana) && String.isblank(screenAccountRecord.FirstNameKana)){
            inputCheckex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED,'お客様名フリガナの 姓 もしくは 名 どちらか'));
        }

        // メールもしくは電話番号の１～３が未入力
        if (String.isblank(screenAccountRecord.Phone) &&
            String.isblank(screenAccountRecord.Phone2) &&
            String.isblank(screenAccountRecord.Phone3) &&
            String.isblank(screenAccountRecord.Email) &&
            String.isblank(screenAccountRecord.Email2) &&
            String.isblank(screenAccountRecord.Email3)
            ){
            inputCheckex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED,'メールもしくは電話番号どちらか'));
        }

		// ▼2021.10.08 No.307 対応で削除（移動）　「賃料」、「占有面積」、「路線」、「学校」

		//▼問合せNo341で追加
		if (!editflg && screenAccountRecord.Situation == null){
			inputCheckex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED,'状況'));
		}
		//▲問合せNo341で追加

		// ▼2021.10.08 No.307 対応で追加 お客様物件条件の入力チェック
		inputCheckex = inputAccountPropertyConditionsCheck(inputCheckex);
		
		return inputCheckex;
	}

	// ▼2021.10.08 No.307 対応で追加 お客様物件条件の入力チェック
	/**
	 * 入力チェック(お客様物件条件)
	 * 引数　　：　確認中のエラー情報
	 * 戻り値　：  エラー有無
	 */
	private BusinessLogicException inputAccountPropertyConditionsCheck(BusinessLogicException inputCheckex){
		if(inputCheckex == null){
			//確認中のエラー情報がない場合、インスタンスを生成
			inputCheckex = new BusinessLogicException();
		}

        // 賃料の下限が上限を上回る。
		if (CommonUtil.stringToDecimal(currentScreenPropertyCondition.RentFeeFrom) >CommonUtil.stringToDecimal(currentScreenPropertyCondition.RentFeeTo)){
            inputCheckex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_LOWER_BOUND_EXCEED,'賃料の下限,上限'.split(',')));
        }
        
        // 占有面積の下限が上限を上回る。
		if (CommonUtil.stringToDecimal(currentScreenPropertyCondition.OccupancyAreaLowerLimit) > CommonUtil.stringToDecimal(currentScreenPropertyCondition.OccupancyAreaUpperLimit)){
            inputCheckex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_LOWER_BOUND_EXCEED,'占有面積の下限,上限'.split(',')));
        }

        // ▼問合せ415で追加
        // 路線名が入力されていて、駅名が入力されていない場合、エラー
		if((String.isNotBlank(currentScreenPropertyCondition.trainRoute1) && String.isblank(currentScreenPropertyCondition.stationsChar1)) ||
			(String.isNotBlank(currentScreenPropertyCondition.trainRoute2) && String.isblank(currentScreenPropertyCondition.stationsChar2)) ||
			(String.isNotBlank(currentScreenPropertyCondition.trainRoute3) && String.isblank(currentScreenPropertyCondition.stationsChar3)) ) {
            inputCheckex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED,'路線名を選択した場合、駅名'));
        }

        // 校区が入力されていて、学校が入力されていない場合、エラー
		if((String.isNotBlank(currentScreenPropertyCondition.juniorHighSchoolArea) && String.isblank(currentScreenPropertyCondition.desiredJuniorHighSchool)) ||
			(String.isNotBlank(currentScreenPropertyCondition.elementarySchoolArea) && String.isblank(currentScreenPropertyCondition.desiredPrimarySchool)) ) {
            inputCheckex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED,'校区を選択した場合、学校'));
        }
        // ▲問合せ415で追加
        
        return inputCheckex;
    }
	// ▲2021.10.08 No.307 対応で追加 お客様物件条件の入力チェック

    /**
     * 申込時の対応紐づけ処理
     * 引数　　：　
     * 戻り値　：  新規登録の発生有無
     */
    private boolean setApplication(){
        // チェックされている対応が既に物件と紐づいている。
        List<Correspond__c> LocalCorrespondList = new List<Correspond__c>();
        LocalCorrespondList = selectCorrespondInfo(this.accountId,checkCorrespondId);     
        setPropertyFlg = false;  
        Boolean newFlg = false; 
        // 件数が取れない(バグ)
        if (LocalCorrespondList.size() ==0 ){
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
            throw ex;
        }
        // 楽観ロックチェックExceptionを発行(対応)    
        if (LocalCorrespondList[0].SystemModstamp != screenCorrespondRecordList[checkCorrespondIndex].systemmodstamp){
            OptimisticLockException ex = new OptimisticLockException();
            throw ex;
        }

        // 対象のお気に入り物件一覧が入居中である場合、
        Correspond__c LocalCorrespond = LocalcorrespondList[0];
        // 対象のお気に入り物件の情報を取得(チェックがついている内容)
        List<screenFavoriteProperty> LocalFavoritePropertyList = new List<screenFavoriteProperty>(); 
        
        for(screenFavoriteProperty candidate :this.screenFavoritePropertyList) {
            if (candidate.isSelected){
                
                // チェックされている行のみ抜き出し 
                //配列に入れ込む
                LocalFavoritePropertyList.add(candidate);
            }
        }
        // もしお気に入り物件が2件以上の場合
        Boolean setFlg = false;
        for(screenFavoriteProperty FavoriteProperty:LocalFavoritePropertyList){

            // 対象の物件が既に登録されている場合
            if(FavoriteProperty.Property == LocalCorrespond.Property__c || checkProperty == FavoriteProperty.Property){
                // スキップ
                continue;
            }

            // チェックされたお気に入り物件で既に登録されているか確認する。
            Boolean CorrespondPropertySetFlg = false;
            for(screenCorrespond screenCorrespondRecord : this.screenCorrespondRecordList){
                if (FavoriteProperty.Property == screenCorrespondRecord.property){
                    // セットされていれば登録せずスキップ
                    CorrespondPropertySetFlg = true;
                    continue;
                }
            }
            
            if(CorrespondPropertySetFlg){
                // 更新しない
                continue;
            }

            // 申込が対応に設定されていない場合。
            if(String.isBlank(LocalCorrespond.Application__c) && string.isBlank(LocalCorrespond.Property__c)  && setFlg == false){
                // 更新処理
                saveCorrespondProperty(LocalCorrespond,FavoriteProperty,false);
                setFlg = true;
                setPropertyFlg = true;
                continue;
            }

            // 対応の物件とお気に入り物件が一致していない時
            if(FavoriteProperty.Property != LocalCorrespond.Property__c){
                // 新規に対応を登録する。
                saveCorrespondProperty(LocalCorrespond,FavoriteProperty,true);
                setPropertyFlg = true;
                newflg = true;
            }
        }

        return newflg;
    }

    /**
     *  反響集約（対応更新）
     *  引数    ：  Id String 対応状況選択行ID
     *         ：  EchoStaff String 反響担当者ID
     *         ：  ShopStaff String 来店担当者ID
     */
    private Boolean saveEchoaggregationCorrespond(String Id, String EchoStaff,String ShopStaff){
        // 保存処理
        Correspond__c saveDate = new Correspond__c();

        // 更新により取引先IDをセット
        saveDate.Id = Id;

        // 保存項目
        saveDate.Status__c              =  CORRESPOND_STATUS_ECHOAGGREGATION;               // ステータス（反響集約）
        saveDate.EventDateTime__c       =  CommonUtil.getNow();                             // イベント時刻
        saveDate.ListViewDate__c        =  CommonConst.LAST_DATE;                           // 一覧表示日時
        saveDate.IsEchoNotCalculation__c=  true;                                            // 2020/5/25追加：反響数非計算フラグ
        // ログインユーザーと反響担当者もしくは、来店担当者とが一致しなければ：False、以外はTreu スタッフ対応フラグ
        if (loginStaff == EchoStaff ||loginStaff ==  ShopStaff){
            saveDate.StaffSupportedFlg__c = true;
        }else {
            saveDate.StaffSupportedFlg__c = false;
        }
        saveDate.IsSupportedListShow__c  = true;        // 対応確認フラグ
        saveDate.IsBrowseFlg__c          = true;        // 閲覧フラグ

        SecureDML.secureUpdate(saveDate);

        return True;
    }

    /**
     *  反響集約先の項目を反響元から反映する。
     *  引数　　：  echoMeta Correspond__c  反響元データ
     *  　　　　：  echoFirst Correspond__c 反響先データ
     */
    private void upadaeEchoAggregation(Correspond__c echoMeta,Correspond__c echoFirst){

        echoFirst.EchoStaff__c             = reflectEchoItem(echoMeta.EchoStaff__c,echoFirst.EchoStaff__c);                                 // 担当者（反響）
        echoFirst.EchoShop__c              = reflectEchoItem(echoMeta.EchoShop__c,echoFirst.EchoShop__c);                                   // 反響担当店舗
        echoFirst.PortalSite__c            = reflectEchoItem(echoMeta.PortalSite__c,echoFirst.PortalSite__c);                               // ポータルサイト
        echoFirst.District__c              = reflectEchoItem(echoMeta.District__c,echoFirst.District__c);                                   // 地区
        echoFirst.PortalSiteUrl__c         = reflectEchoItem(echoMeta.PortalSiteUrl__c,echoFirst.PortalSiteUrl__c);                         // ポータルサイトURL
        echoFirst.FirstInquiryProperty__c  = reflectEchoItem(echoMeta.FirstInquiryProperty__c,echoFirst.FirstInquiryProperty__c);           // 初回問合せ物件
        echoFirst.FirstInquiryMeans__c     = reflectEchoItem(echoMeta.FirstInquiryMeans__c,echoFirst.FirstInquiryMeans__c);                 // 初回問合せ方法
        echoFirst.ReceiveMailDatePortal__c = reflectEchoItemDateTime(echoMeta.ReceiveMailDatePortal__c,echoFirst.ReceiveMailDatePortal__c); // メール受信日時（ポータル）
		// ▼ 2022.1.7 LINE連携対応より、LINE会員を追加
		echoFirst.LineMember__c	=	reflectEchoItem(echoMeta.LineMember__c, echoFirst.LineMember__c);
		// ▲ 2022.1.7

        // ▼問合せ323で追加
        if(echoMeta.EventDateTime__c > echoFirst.EventDateTime__c) {
            echoFirst.Remarks__c = echoMeta.Remarks__c;
        }
        echoFirst.EventDateTime__c         = CommonUtil.getNow();                                                                           // イベント時刻
        // ▲問合せ323で追加
        SecureDML.secureUpdate(echoFirst);   // 更新
    }

    /**
     *  反響集約先の項目がない場合、反響元へ書き換える。
     *  引数　　：  echoMetaItem  反響元の項目
     *  　　　　：  echoFirstItem 反響先の項目
     * 戻り値   ：  反響先に設定する項目
     */
    private String reflectEchoItem(String echoMetaItem,String echoFirstItem){
        String ItemReflect = echoFirstItem;
        if(String.isBlank(ItemReflect)){
            // 反響先のデータが無ければ、反響元のデータを反映する。
            ItemReflect = echoMetaItem;
        }
        return ItemReflect;
    }

    /**
     *  反響集約先の項目がない場合、反響元へ書き換える（日付型）。
     *  引数　　：  echoMetaItem Datetime  反響元の項目
     *  　　　　：  echoFirstItem Datetime 反響先の項目
     * 戻り値   ：  反響先に設定する項目
     */
    private Datetime reflectEchoItemDateTime(Datetime echoMetaItem,Datetime echoFirstItem){
        Datetime ItemReflect = echoFirstItem;
        if(ItemReflect == null){
            // 反響先のデータが無ければ、反響元のデータを反映する。
            ItemReflect = echoMetaItem;
        }
        return ItemReflect;
    }

    /**
     *  反響集約（対応明細作成）
     *  引数　　：  CorrespondsId String 対応状況選択行ID
     * 　　　　 ：  loginStaff String ログインユーザID
     * 　　　　 ：  loginShop String ログインユーザ店舗
     * 　　　　 ：  echoMetaStatus String 反響元のステータス
     * 　　　　 ：  echoFirstStatus String 反響先のステータス
     */
    private void saveEchoaggregationCorrespondDetail(String CorrespondsId,String loginStaff,String loginShop,String echoMetaStatus,String echoFirstStatus){
        // 保存処理
        CorrespondDetail__c saveDate = new CorrespondDetail__c();

        // 保存項目        
        saveDate.SupportedDateTime__c = CommonUtil.getNow() ;   // 対応日時
        saveDate.SupportedTitle__c = CORRESPOND_STATUS_ECHOAGGREGATION ;// 対応表題
        saveDate.SupportedContent__c = CommonUtil.callMessageCreate(CommonConst.MSG_CUST_I_ECHO_AGGREGATION_END, echoMetaStatus,echoFirstStatus);// 対応内容
        saveDate.Shop__c =  loginShop;// 店舗
        saveDate.Staff__c = loginStaff;// 担当者
        saveDate.Corresponds__c = CorrespondsId;// 対応番号
        saveDate.CorrespondType__c = TASK_CORRESPONDTYPE_ECHOAGGREGATION ;// 対応種別

        SecureDML.secureInsert(savedate);

    }

    /**
     *  保留解除（対応明細作成）
     *  引数　　：  Id String 対応状況選択行ID
     * 　　　　 ：  loginStaff String ログインユーザID
     * 　　　　 ：  loginShop String ログインユーザ店舗
     */
    private Boolean saveCorrespondDetailEleaseHold(String Id,String loginStaff,String loginShop){
        // 保存処理
        CorrespondDetail__c saveDate = new CorrespondDetail__c();

        // 保存項目        
        saveDate.SupportedDateTime__c = CommonUtil.getNow() ;   // 対応日時
        saveDate.SupportedTitle__c = TASK_CORRESPONDTYPE_RELEASEHOLD ;// 対応表題
        saveDate.SupportedContent__c = '保留を解除しました。'  ;// 対応内容
        saveDate.Shop__c =  loginShop;// 店舗
        saveDate.Staff__c = loginStaff;// 担当者
        saveDate.Corresponds__c = Id;// 対応番号
        saveDate.CorrespondType__c = TASK_CORRESPONDTYPE_RELEASEHOLD ;// 対応種別

        SecureDML.secureInsert(savedate);

        return True;
    }

    /**
     *  名寄せ完了フラグ設定（名寄せ不要フラグの更新を行う）
     *  引数　　：  Account upSertAccount 名寄せ検索対象の取引先
     *　戻り値  ：  名寄せ完了フラグの設定値
     */
    private boolean setTargetRecordIsMergeCompletedFlag (Account upSertAccount){
        Boolean IsMergeCompletedFlag = screenAccountRecord.IsMergeCompletedFlag;
        // 取引先の新規作成の場合か、編集時に取引先名（氏名）かメールか電話番号の値が変更されていた場合に、名寄せの確認を行う
        if(newflg
            ||CommonUtil.isDifferenceTwoString(this.screenAccountRecord.LastName , this.screenAccountRecord_bak.LastName)   //名前(姓)
            ||CommonUtil.isDifferenceTwoString(this.screenAccountRecord.FirstName , this.screenAccountRecord_bak.FirstName) //名前(名)
            ||CommonUtil.isDifferenceTwoString(this.screenAccountRecord.Email , this.screenAccountRecord_bak.Email)         //メール
            ||CommonUtil.isDifferenceTwoString(this.screenAccountRecord.Email2 , this.screenAccountRecord_bak.Email2)       //メール2
            ||CommonUtil.isDifferenceTwoString(this.screenAccountRecord.Email3 , this.screenAccountRecord_bak.Email3)       //メール3
            ||CommonUtil.isDifferenceTwoString(this.screenAccountRecord.Phone , this.screenAccountRecord_bak.phone)         //電話番号
            ||CommonUtil.isDifferenceTwoString(this.screenAccountRecord.Phone2 , this.screenAccountRecord_bak.phone2)       //電話番号2
            ||CommonUtil.isDifferenceTwoString(this.screenAccountRecord.Phone3 , this.screenAccountRecord_bak.phone3)       //電話番号3
            ){
                // 名寄せ確認に数式を使用しているので、確認前に数式の再計算を行う
                upSertAccount.recalculateFormulas();

                // 2020.09.03 名寄せ不要フラグをfalseに更新
                upSertAccount.IsMergeUnnecessaryFlag__c = false;
                
                List<Account> nameMergeList = NameMergeUtil.getCustomerMergeList(upSertAccount, null);// 名寄せ確認
                if(nameMergeList.size() == 0){// 名寄せ確認の結果0件なら名寄せ完了
                    IsMergeCompletedFlag = true;
                } else {// 名寄せ確認の結果0件でないなら名寄せ未完了
                    IsMergeCompletedFlag = false;
                    //2020.09.03 名寄せで一致対象とされた取引先の名寄せ不要フラグを更新
                    NameMergeUtil.setCustomerMergeUnnecessaryFlag(nameMergeList);
                }
            }
        return IsMergeCompletedFlag;// 名寄せフラグを返す
    }

        /**
     *  名寄せ完了フラグ設定（名寄せ不要フラグの更新を行わない）
     *  引数　　：  Account account 名寄せ検索対象の取引先
     *　戻り値  ：  名寄せ完了フラグの設定値
     */
    private boolean checkIsMergeCompletedFlag (Account account){

        boolean IsMergeCompletedFlag = false;
        List<Account> nameMergeList = NameMergeUtil.getCustomerMergeList(account, null);// 名寄せ確認
                
        if(nameMergeList.size() == 0){// 名寄せ確認の結果0件なら名寄せ完了
            IsMergeCompletedFlag = true;
        } else {// 名寄せ確認の結果0件でないなら名寄せ未完了
            IsMergeCompletedFlag = false;
        }
        return IsMergeCompletedFlag;
    }

    /**
     * 対象が反響集約ボタンを押下可とするか判定
     * 戻り値　： Integer 反響集約のボタン押下状態
     */
    private Integer checkEchoAggregation() {
        Integer echoAggregationButtonState = 0;
        // 名寄せ未完了となっている場合
        if(!this.screenAccountRecord.IsMergeCompletedFlag ){
            // 反響集約を押下不可とし、メッセージを非表示にする。
            echoAggregationButtonState = 0;
            this.EchoAggregationMessageFlg = false;
        }else{
            // 名寄せ完了の場合
            echoAggregationButtonState = echoAggregationButtonActivity();
        }
        return echoAggregationButtonState;

    }

    /**
     * 反響集約のボタンの設定を行う
     * 戻り値　： Integer 反響集約のボタン押下状態
     */
    private Integer echoAggregationButtonActivity(){
        Integer echoAggregationButtonState = 0;     
        // 反響集約可能である場合に反響集約のボタンを制御する。
        for (screenCorrespond screenCorrespondRecord :this.screenCorrespondRecordList){
            // 対応状況一覧がチェックされている対応ID
            // 且つ 反響集約レコード
            // 且つ 反響集約メッセージ表示フラグがtrueの場合
            if(screenCorrespondRecord.Id == this.checkCorrespondId
               && isEchoAggregationRecord(screenCorrespondRecord)
               && this.EchoAggregationMessageFlg){
                //反響集約ボタンを押下可にする
                echoAggregationButtonState = 2;
                break;
            }
        
        }

        return echoAggregationButtonState;
    }

    /**
     * 反響集約登録処理
     */
    private void echoRegister(){

        // 集約元データの取得
        List<Correspond__c> echoMetaList = selectEchoAggregation(this.checkCorrespondId,false);

        // 集約先データの取得
        List<Correspond__c> echoFirstList = selectEchoAggregation(this.checkCorrespondId,true);

        // 集約先、集約元が取得できていれば登録処理を行う。
        if(!echoMetaList.isEmpty() && !echoFirstList.isEmpty()){
            // 集約先のデータ更新
            upadaeEchoAggregation(echoMetaList[0],echoFirstList[0]);

            // 対応更新
            saveEchoaggregationCorrespond(this.checkCorrespondId,this.checkEchoStaff,this.checkShopStaff);

            // 対応明細登録
            saveEchoaggregationCorrespondDetail(echoFirstList[0].Id,this.loginStaff,this.loginShop,echoMetaList[0].Status__c,echoFirstList[0].Status__c);
        }

    }

// -----------------------------------------------------------------------------------------------
// 画面の制御
// -----------------------------------------------------------------------------------------------
    /**
     * 担当者選択画面モーダル表示処理
     */
    public void openModal1() {
        try {
            this.hasErrorMessage = False;
            //楽観ロックの有無判定
            throwOptimisticLockOfCorrespond();

        // ヘッダのロックしない
        // this.HeaderLockFlg = false;
        this.RefreshCorrespondenceHistory = true;                   // 対応履歴再描画フラグを立てる
        this.RefreshCorrespondenceStatus = true;                    // 対応状況再描画フラグを立てる
        this.openModalFlg = 1 ;
        GA102001Paremeter1.AccountId = this.accountId;               // 取引先ID
        GA102001Paremeter1.CorrespondId = checkCorrespondId;         // 対応ID
        GA102001Paremeter1.isDrawing = true;
        GA102001Paremeter1.noFirst = true;
        }catch(Exception e){                
            this.hasErrorMessage = True;
            CommonUtil.setErrorMessage(e);
        }
    }

    
    /**
     * 対応履歴画面モーダル表示処理電話
     */
    public void openModal2Tel() {
        this.selectCorrespondDetailId = CommonConst.STRING_EMPTY;

		// ▼ 2021.11.30 LINE連携対応より、ステータスに応じた画面を開くよう修正
		ScreenCorrespond screenCorrespond = this.screenCorrespondRecordList[checkCorrespondIndex];

		// デフォルトは電話を開く（メモへの変更可）
		this.correspondType = TASK_CORRESPONDTYPE_TEL;

		// レコードタイプ、ステータスに応じた画面を開く（対になる画面への変更不可）
		if (screenAccountRecord.RecordTypeId == ACCOUNT_RECTYPE_CUSTOMER) {
			if (screenCorrespond.status == CommonConst.CORRESPOND_STATUS_VISITED) {
				this.screenCorrespondRecordList[checkCorrespondIndex].isDispModal2CorrespondType = false;
				this.correspondType = TASK_CORRESPONDTYPE_MEMO;
			// ▼ 2022.04.20 No0768 対応で追加
			}else {
				// 他は選択可能する。
				this.screenCorrespondRecordList[checkCorrespondIndex].isDispModal2CorrespondType = true;
			// ▲ 2022.04.20 No0768 対応で追加
            }
		} else {
			// 未対応、終了
			if (!screenCorrespond.isDispModal2CorrespondType) {
				this.correspondType = TASK_CORRESPONDTYPE_MEMO;
			}
		}
		// ▲ 2021.11.30

        // this.HeaderLockFlg = false;
        this.setStatus = CommonConst.STRING_EMPTY;

        openModal2State();
    }

    // ▼ 2021.11.30 LINE連携対応より、メモ用処理をLINE用に修正
	/**
	 * LINE専用画面への遷移
	 */
	public void openLineExclusive() {
		
		try {
			this.hasErrorMessage = false;
			// ▼ 2022.1.29 LINE連携対応より、遷移条件を修正
			// LINE会員IDの取得
			LineMember__c lineMember = this.selectLineMember(this.screenAccountRecord.Id);
			this.screenAccountRecord.lineMemberId = lineMember.Id;
			// ▲ 2022.1.29 

			// LINE会員チェック
			if (String.isBlank(this.screenAccountRecord.lineMemberId)) {
				BusinessLogicException ex = new BusinessLogicException();
				ex.addMessage(CommonConst.MSG_ACC_E_NOT_MOVE_LINE_EXCLUSIVE);
				throw ex;
			}

			//▼ 2022.04.20 No0768 対応で追加
			// 有効な対応を取得、無ければ対応を新規登録し設定
			this.lineCorrespondId = CustomerUtil.checkCorrespondLine(lineMember.Id,false).id;
			//▲ 2022.04.20 No0768 対応で追加

		} catch(Exception e) {
			this.hasErrorMessage = true;
			CommonUtil.setErrorMessage(e);
		}
	}
	// ▲ 2021.11.30

    /**
     * 対応履歴画面モーダル表示処理アポイント確定
     */
    public void openModal2Apo() {
        this.selectCorrespondDetailId = CommonConst.STRING_EMPTY;
        this.correspondType = TASK_CORRESPONDTYPE_APPOINTMENT; 
        // this.HeaderLockFlg = false;
        this.setStatus = CORRESPOND_STATUS_APPOINTMENT;

        openModal2State();
    }

    /**
     * 対応履歴画面モーダル表示処理来店後検討
     */
    public void openModal2After() {
        this.selectCorrespondDetailId = CommonConst.STRING_EMPTY;
        this.correspondType = TASK_CORRESPONDTYPE_CONSIDERVISITING; 
        // this.HeaderLockFlg = false;
        this.setStatus = CORRESPOND_STATUS_CONSIDERVISITING;

        openModal2State();
    }

    /**
     * 対応履歴画面モーダル表示処理契約完了
     */
    public void openModal2ContractCompleted() {
        this.selectCorrespondDetailId = CommonConst.STRING_EMPTY;
        this.correspondType = TASK_CORRESPONDTYPE_ENDCONTRACT; 
        // this.HeaderLockFlg = false;
        this.setStatus = CORRESPOND_STATUS_AGREEMENT;

        openModal2State();
    }

    /**
     * 対応履歴画面モーダル表示処理追客保留
     */
    public void openModal2HoldFollower() {
        this.selectCorrespondDetailId = CommonConst.STRING_EMPTY;
        this.correspondType = TASK_CORRESPONDTYPE_PURSUITHOLD; 
        this.setStatus = CORRESPOND_STATUS_PURSUITHOLD;

        openModal2State();
    }

    /**
     * 対応履歴画面モーダル表示処理アポイントキャンセル
     */
    public void openModal2AppointCancel() {
        this.selectCorrespondDetailId = CommonConst.STRING_EMPTY;
        this.correspondType = TASK_CORRESPONDTYPE_APO_CANCEL; //問合せNo295で変更
        this.setStatus = CORRESPOND_STATUS_APOCANCEL;

        openModal2State();
    }

    /**
     * 保留解除
     */
    public void ReleaseHold(){
        Savepoint sp = Database.setsavepoint();
        hasErrorMessage = False;

        try{
            //楽観ロックチェックExceptionを発行(対応)
            List<Correspond__c> checkOptimisticLockExceptionRecord = new List<Correspond__c>();
            checkOptimisticLockExceptionRecord = [ SELECT id
                                                        FROM Correspond__c
                                                        WHERE id = :checkCorrespondId
                                                        AND SystemModStamp = :screenCorrespondRecordList[checkCorrespondIndex].systemmodstamp];
            if (checkOptimisticLockExceptionRecord.isEmpty()){
                // エラーあり
                OptimisticLockException ex = new OptimisticLockException();
                throw ex;
            }
            // 更新処理
            Correspond__c saveDate = new Correspond__c();
            saveDate.id  =  this.checkCorrespondId;                     // ID

            saveDate.EventDateTime__c = CommonUtil.getNow();            // イベント時刻                                                           
            saveDate.IsSupportedListShow__c = false;                    // 対応確認                                                         
            saveDate.IsBrowseFlg__c = false;                             // 閲覧フラグ
            //2020/6/16追加：ステータスを保留前ステータスの値に戻す
            saveDate.Status__c = screenCorrespondRecordList[checkCorrespondIndex].targetCorrespondRecord.StatusBeforePursuitHold__c;
            saveDate.StatusBeforePursuitHold__c = null;                 //追客保留前ステータス

            saveDate.PursuitDissolveDate__c = null;                     // 追客解除日
            saveDate.PursuitDissolveSettingDate__c = null;              // 追客解除設定日時
            // ログインユーザーと反響担当者もしくは、来店担当者とが一致しなければ：False、以外はTreu スタッフ対応フラグ
            if (loginStaff == checkEchoStaff || loginStaff ==  checkShopStaff){
                saveDate.StaffSupportedFlg__c = true;
            }else {
                saveDate.StaffSupportedFlg__c = false;
            }
            //2020/7/13変更：一覧表示日時をステータスによって変更
            saveDate.ListViewDate__c = CustomerUtil.setListViewDateWhenCorrespondCheck(saveDate.Status__c, screenCorrespondRecordList[checkCorrespondIndex].targetCorrespondRecord);
            
            SecureDML.secureUpdate(saveDate);

            // 対応明細を作る
            saveCorrespondDetailEleaseHold(this.checkCorrespondId,this.loginStaff,this.loginShop);

            // 再取得
            // 対応状況再描画
            getCorrespondenceStatusList();
            // 対応履歴再描画
            getCorrespondenceHistoryList();

            //追加要望 追加 start
            //取引先再取得 
            accountList = selectAccountInfo(this.accountId);
            screenAccountRecord = new screenAccount(accountList[0]);
            screenAccountRecord_bak = screenAccountRecord.clone();
            this.introMailInfoList = new List<IntroductionMailInformation__c>();
            //紹介メール情報再取得
            this.introMailInfoList = selectIntroMailInfo(this.accountId);
            //追加要望 追加 end

			// ▼2021.10.08 No.307 対応で予約物件条件更新処理追加
			//取引先の予約物件条件がtrueの場合、falseにアップデート
			if(accountList[0].IsReservePropertyConditions__c){
				Account updateAcc = new Account(Id = accountList[0].Id, IsReservePropertyConditions__c = false);
				SecureDML.secureUpdate(updateAcc);
			}
			//お客様物件条件を再取得
			List<AccountPropertyConditions__c> accountPCList = new List<AccountPropertyConditions__c>();
            accountPCList = getAccountPropertyConditions(this.accountId);
			List<AccountPropertyConditions__c> updatePCList = new List<AccountPropertyConditions__c>();
			//予約物件条件がtrueのお客様物件条件を、falseにアップデート
			for(AccountPropertyConditions__c accountPC: accountPCList){
				if(accountPC.IsReservePropertyConditions__c){
					updatePCList.add(new AccountPropertyConditions__c(Id = accountPC.Id, IsReservePropertyConditions__c = false));
				}
			}
			if(!updatePCList.isEmpty()){
				SecureDML.secureUpdate(updatePCList);
			}
			// ▲2021.10.08 No.307 対応で予約物件条件更新処理追加
			
            // ボタンの再設定
            setButtonList();
        }catch(Exception e){
            database.rollback(sp);
            hasErrorMessage = True;
            CommonUtil.setErrorMessage(e);
        }
    }

    /**
     * 対応履歴画面モーダル表示処理申込キャンセル
     */
    public void openModal2ApplicationCancel() {
        this.selectCorrespondDetailId = CommonConst.STRING_EMPTY;
        this.correspondType = TASK_CORRESPONDTYPE_CANCEL; 
        // this.HeaderLockFlg = false;
        this.setStatus = CORRESPOND_STATUS_APPLCANCEL;

        openModal2State();
    }

    /**
     * 対応履歴画面モーダル表示処理終了
     */
    public void openModal2End() {
        this.selectCorrespondDetailId = CommonConst.STRING_EMPTY;
        this.correspondType = TASK_CORRESPONDTYPE_CLOSE; 
        // this.HeaderLockFlg = false;
        this.setStatus = CORRESPOND_STATUS_CLOSE;

        openModal2State();
    }

    //▼問合せNo0531で追加
    /**
     * 対応履歴画面モーダル表示処理編集
     * 編集は対象のステータスを保持しないようにしメモと電話の更新時の処理のみ動かすようにする
     * @param 
     * @return 
     */
    public void openModal2Edit() {
        try {
            this.hasErrorMessage = False;
            //楽観ロックの有無判定
            throwOptimisticLockOfCorrespondEdit();

            // selectCorrespondDetailIdとcorrespondTypeは画面にてparamで渡しているため初期化、設定は不要
            this.setStatus = CommonConst.STRING_EMPTY;  // ボタン押下した時のステータスを空にする

            // 前のデータが残らないように初期化
            GA102001Paremeter2 = new GA102001Modal2ParameterClass();
            this.RefreshCorrespondenceHistory = true;                   // 対応履歴再描画フラグを立てる
            this.RefreshCorrespondenceStatus = true;                    // 対応状況再描画フラグを立てる
            this.openModalFlg = 2 ;

            GA102001Paremeter2.AccountId = this.accountId;  // 取引先ID
            GA102001Paremeter2.CorrespondId = this.CorrespondDetailCorrespondsId; // 対応ID
            GA102001Paremeter2.CorrespondDetailId = this.selectCorrespondDetailId;  // 対応明細Id
            GA102001Paremeter2.CorrespondType = this.correspondType; // 対応種別
            GA102001Paremeter2.Status = this.setStatus; // ステータス
            GA102001Paremeter2.isDrawing = true;
            GA102001Paremeter2.noFirst = true;
			// ▼ 2021.11.30 LINE連携対応より、対応種別表示フラグを追加
			GA102001Paremeter2.isDispCorrespondType = false;
			// ▲ 2021.11.30

        }catch(Exception e){                
            this.hasErrorMessage = True;
            CommonUtil.setErrorMessage(e);
        }
    }
    //▲問合せNo0531で追加

    /**
    　お気に入り物件画面モーダル表示処理
     */
     public void openModal3(){

        // 選択行を取得（JSで選択件数チェックを行う為、outOfBoundsの考慮不要）
        List<screenFavoriteProperty> selectedDetailList = this.getSelectedDetailFavoriteProperty();
        screenFavoriteProperty selectedDetail = selectedDetailList[0]; 

        this.RefreshCorrespondenceHistory = true;                   // 対応履歴再描画フラグを立てる（対応履歴のTransientの設定のためお気に入り物件が更新されたら再度取り直す）
        this.RefreshFavoriteProperty = true;                        // お気に入り物件再描画フラグを立てる
        this.openModalFlg = 3 ;
        GA102001Paremeter3.FavoritePropertyId = selectedDetail.Id;  // お気に入り物件ID
        GA102001Paremeter3.isDrawing = true;
        GA102001Paremeter3.noFirst = true;

     }

    /**
    　入金画面モーダル表示処理
     */
     public void openModal4(){
        try{
            this.hasErrorMessage = False;
            //楽観ロックの有無判定
            throwOptimisticLockOfCorrespond();

            this.RefreshCorrespondenceHistory = true;                   // 対応履歴再描画フラグを立てる
            this.RefreshCorrespondenceStatus = true;                    // 対応状況再描画フラグを立てる
            this.openModalFlg = 4 ;
            GA102001Paremeter4.ApplicationId = this.checkApplication;     // 申込ID
            GA102001Paremeter4.CorrespondId = this.checkCorrespondId;
            GA102001Paremeter4.isDrawing = true;
            GA102001Paremeter4.noFirst = true;
        }catch(Exception e){                
            this.hasErrorMessage = True;
            CommonUtil.setErrorMessage(e);
        }
     }

     /**
    　スケジュール画面モーダル表示処理
     */
    public void openModal6(){
        this.RefreshCorrespondenceHistory = true;                   // 対応履歴再描画フラグを立てる
        this.RefreshCorrespondenceStatus = true;                    // 対応状況再描画フラグを立てる
        this.openModalFlg = 6 ;
        GA102001Paremeter6.AccountId = this.accountId;  // 取引先ID
        GA102001Paremeter6.CorrespondId = this.checkCorrespondId; // 対応ID      
        GA102001Paremeter6.isDrawing = true;
        GA102001Paremeter6.noFirst = true;
     }

	// ▼2021.10.08 No.307 対応で削除（移動）　物件検索押下時処理
	

    /**
     * 名寄せ押下時処理
     */
    public void openNameIdentification() {
        //楽観ロックの有無判定
        checkOptimisticLockOfAccout();
    }

    /* 
      追加要望 追加 Start
    　自動追客一覧画面モーダル表示処理
     */
    public void openModal7(){
        this.RefreshCorrespondenceHistory = true;                   // 対応履歴再描画フラグを立てる
        this.openModalFlg = 7 ;
        this.GA102001Paremeter7 = new GA102001Modal7ParameterClass();
        this.GA102001Paremeter7.AccountId = this.accountId;                      // 取引先ID
        this.GA102001Paremeter7.correspond = screenCorrespondRecordList[checkCorrespondIndex].targetCorrespondRecord; //対応
		// ▼ 2022.1.29 LINE連携対応より、LINE送信の押下条件を修正
		// ▼ 2021.11.30 LINE連携対応より、LINE会員を追加
        LineMember__c lineMember = this.selectLineMember(this.screenAccountRecord.Id);
		this.GA102001Paremeter7.lineMemberId = lineMember.Id;
		// ▲ 2021.11.30
		// ▲ 2022.1.29

		//紹介メール情報レコードがある
        if (!introMailInfoList.isEmpty()){
            this.GA102001Paremeter7.introMailInfoFirstSendDatetime = this.introMailInfoList[0].Account__r.IntroMailInfoFirstSendDatetime__c;// 初回配信日時
            this.GA102001Paremeter7.introMailInfoId = this.introMailInfoList[0].Id;                                          //紹介メール情報Id
            this.GA102001Paremeter7.introMailInfoSystemModStamp = this.introMailInfoList[0].SystemModStamp;                  //紹介メール情報systemModStamp
			// ▼ 2021.11.30 LINE連携対応より、送信区分を追加
			this.GA102001Paremeter7.isSendLine = this.introMailInfoList[0].isSendLine__c;
			// ▲ 2021.11.30
        }
        this.GA102001Paremeter7.isDrawing = true;
        this.GA102001Paremeter7.noFirst = true;
     }
    //追加要望 追加 End


    /**
    　条件完全一致物件画面モーダル表示処理
     */
    public void openModal8(){
        try{
            this.hasErrorMessage = False;
            //選択行取得
            List<screenExactConditionMatchProperty> detailList = new List<screenExactConditionMatchProperty>();
            for (screenExactConditionMatchProperty detail : screenExactConditionMatchPropertyList) {
                if(detail.isSelected){
                    detailList.add(detail);
                }
            }
            throwOptimisticLockException(detailList);

            // 条件完全一致物件モーダルモーダル表示設定（JSで選択件数チェックを行う為、outOfBoundsの考慮不要）
            openModal8set(detailList[0].Id);
        }catch(Exception e){                
            this.hasErrorMessage = True;
            CommonUtil.setErrorMessage(e);
        }
    }

    /**
    　条件完全一致物件画面モーダル表示設定
     * @param Id exactCondMatchPropId 条件完全一致物件．ID
     */
    public void openModal8set(Id exactCondMatchPropId){
            this.RefreshCorrespondenceHistory = true;                   // 対応履歴再描画フラグを立てる（対応履歴のTransientの設定のため条件完全一致物件が更新されたら再度取り直す）
            this.RefreshExactConditionMatchProperty = true;             // 条件完全一致物件再描画フラグを立てる
            this.openModalFlg = 8;
            GA102001Paremeter8.ExactConditionMatchPropertyId = exactCondMatchPropId;     // 条件完全一致物件ID
            GA102001Paremeter8.isDrawing = true;
            GA102001Paremeter8.noFirst = true;
     }

	// ▼2021.10.08 No.307 対応で追加
	/**
	　物件検索画面モーダル表示処理
	*/
	public void openModal9(){
		//楽観ロックの有無判定
		checkOptimisticLockOfSpc();

		this.GA102001Paremeter9.isDrawing = true;
		this.GA102001Paremeter9.noFirst = true;
		
		//物件条件選択リストを初期化
		this.GA102001Paremeter9.spcSelectList = new List<SelectOption>();

		//取引先を再取得
		List<Account> accountList = selectAccountInfo(this.accountId);
		String accName = accountList[0].PropertyConditionsName__c;

		//取引先を物件条件選択リストにセット
		this.GA102001Paremeter9.spcSelectList.add(new SelectOption(accountList[0].Id, accName));
		//取引先を物件条件選択リスト初期値にセット
		this.GA102001Paremeter9.spcSelect = accountList[0].Id;

		//お客様物件条件を再取得
		List<AccountPropertyConditions__c> accountPCList = new List<AccountPropertyConditions__c>();
		accountPCList = getAccountPropertyConditions(this.accountId);

		//お客様物件条件を物件条件選択リストにセット
		for(AccountPropertyConditions__c accountPC: accountPCList){
			this.GA102001Paremeter9.spcSelectList.add(new SelectOption(accountPC.Id, accountPC.Name));
		}
	}
	// ▲2021.10.08 No.307 対応で追加

     /**
     * お気に入り登録ボタン 押下
     *  選択した物件をお気に入りに登録する
     * @param  なし
     * @return なし
     */
    public void saveFavorite() {
        Savepoint sp = Database.setsavepoint();
        hasErrorMessage = False;
        try {                         
            //選択行取得
            List<ExactConditionMatchProperty__c> deleteList = new List<ExactConditionMatchProperty__c>();
            List<screenExactConditionMatchProperty> detailList = new List<screenExactConditionMatchProperty>();
            for (screenExactConditionMatchProperty detail : screenExactConditionMatchPropertyList) {
                if(detail.isSelected){
                    deleteList.add(new ExactConditionMatchProperty__c(id = detail.Id)); // 削除用のIDを取得
                    detailList.add(detail);                                             // 楽観ロック用の明細レコードを取得
                }
            }
            throwOptimisticLockException(detailList);
            
            // 登録済みのお気に入り取得
            Set<Id> searchSetId = new Set<Id>();
            for (FavoriteProperty__c obj : [SELECT Property__c FROM FavoriteProperty__c WHERE Account__c = :this.accountId]) {
                searchSetId.add(obj.Property__c);
            }
            // 登録用リスト作成
            List<FavoriteProperty__c> favoriteList = new List<FavoriteProperty__c>();
            for (screenExactConditionMatchProperty obj : this.screenExactConditionMatchPropertyList) {
                if (obj.isSelected && !searchSetId.contains(obj.property)) {
                    // お気に入り物件の登録値を取得
                    favoriteList.add(new FavoriteProperty__c(Account__c  = this.accountId
                                                            ,Status__c = null
                                                            ,PreviewImpression__c = null
                                                            ,Property__c = obj.property));
                }
                
                // 重複データ有り・無し含めてチェックボックスを初期化
                obj.isSelected = false;
            }
            // お気に入り登録
            if (favoriteList.size() > 0) {
                SecureDML.secureInsert(favoriteList);
            }

            getFavoritePropertyList();

        } catch(Exception e) {
            database.rollback(sp);
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    /**
    　ボタンの状態設定（チェックを変更した際等）
     */
    public void setButtonList(){

        // チェックされているステータスのボタンを設定する。
        buttonListSet = buttonSetlist.get(this.checkStatus);
        
        // 編集時
        if(!newflg ){
            // 反響集約ボタンが押下可能の場合、他のボタンを押下不可に設定
            if (this.checkEchoAggregation() == 2) {
                buttonListSet = buttonSetlist.get(CORRESPOND_STATUS_TARGET_ECHO_AGGREGATION);
            }    
        }
          
        //アポイント変更用に、ボタン名を変更する
        if(!newflg && checkCorrespondIndex != null){

            List<Event> eventList = [SELECT id FROM Event WHERE Id = :screenCorrespondRecordList[checkCorrespondIndex].targetCorrespondRecord.EventId__c];
            if(!eventList.isEmpty()){
                hasEvent = true;
                buttonSetlist.get(TASK_CORRESPONDTYPE_APPOINTMENT)[1] = 1;//アポイント確定を活性化させる
            }else{
                hasEvent = false;
                buttonSetlist.get(TASK_CORRESPONDTYPE_APPOINTMENT)[1] = 0;//アポイント確定を非活性にする
            }
        }      
    }
    /**
    * 編集ボタン押下時
    */
    public void changeMode(){
        // 登録モードへ移行
        isInsertFlg = True;  

        // 入力変更状態初期化
        changeFlg = False;  

        // ヘッダのロックしない
        this.HeaderLockFlg = false;

        // お客様情報のデータを取引先から取得
        // 取引先IDから取引先を取得する。
        accountList = selectAccountInfo(this.accountId);
        if (accountList.size() >  0){
            // 値をセットする。
            screenAccountRecord = new screenAccount(accountList[0]);
            screenAccountRecord_bak = screenAccountRecord.clone();

			// ▼2021.10.08 No.307 対応で追加　取引先IDから客様物件情報をセットする。
			setAccountPropertyCondition(accountList[0]);

			// ▼2021.10.08 No.307 対応で変更
			// 取れてきたお客様物件条件情報から駅情報をセットする。
			setStation();

			// 問合せ415で追加 取れてきたお客様物件条件情報から学校情報をセットする。
			setSchool();
			// ▲2021.10.08 No.307 対応で変更

            // 共通リストボックスの値を設定
            listNewSetting();

            // チェックボックス（オブジェクトはリストボックス）の値を設定
            checkNewSetting();
        }

        // screenAccountRecord_bak = screenAccountRecord.clone();
    }

    /**
     * 駅１モーダルOpen処理
     */
    public void openStations1Modal() {
        this.GA104007Parameter = new GA104007ParameterClass();

        setStationMode = 1;

        this.GA104007Parameter.isDrawing          = true;
        this.GA104007Parameter.noFirst            = true;
		// ▼2021.10.08 No.307 対応で変更
		if (currentScreenPropertyCondition.trainRoute1 != null ){
			this.GA104007Parameter.selectedTrainRoute = [SELECT Id, Name FROM TrainRoute__c WHERE Id = :currentScreenPropertyCondition.trainRoute1];
		}
		// ▲2021.10.08 No.307 対応で変更

        this.GA104007Parameter.selectedStation = new List<Station__c>();//パラメータ初期化

		// ▼2021.10.08 No.307 対応で変更
		if (this.currentScreenPropertyCondition.stations1.size() > 0) {
			this.GA104007Parameter.selectedStation	= this.currentScreenPropertyCondition.stations1;
		}
		// ▲2021.10.08 No.307 対応で変更
    }

    /**
     * 駅２モーダルOpen処理
     */
    public void openStations2Modal() {
        this.GA104007Parameter = new GA104007ParameterClass();

        setStationMode = 2;
        
        this.GA104007Parameter.isDrawing          = true;
        this.GA104007Parameter.noFirst            = true;
		// ▼2021.10.08 No.307 対応で変更
		if (currentScreenPropertyCondition.trainRoute2 != null ){
			this.GA104007Parameter.selectedTrainRoute = [SELECT Id, Name FROM TrainRoute__c WHERE Id = :currentScreenPropertyCondition.trainRoute2];
		}
		// ▲2021.10.08 No.307 対応で変更

        this.GA104007Parameter.selectedStation = new List<Station__c>();//パラメータ初期化

		// ▼2021.10.08 No.307 対応で変更
		if (this.currentScreenPropertyCondition.stations2.size() > 0) {
			this.GA104007Parameter.selectedStation	= this.currentScreenPropertyCondition.stations2;
		}
		// ▲2021.10.08 No.307 対応で変更
    }


    /**
     * 駅３モーダルOpen処理
     */
    public void openStations3Modal() {
        this.GA104007Parameter = new GA104007ParameterClass();

        setStationMode = 3;

        this.GA104007Parameter.isDrawing          = true;
        this.GA104007Parameter.noFirst            = true;
		// ▼2021.10.08 No.307 対応で変更
		if (currentScreenPropertyCondition.trainRoute3 != null ){
			this.GA104007Parameter.selectedTrainRoute = [SELECT Id, Name FROM TrainRoute__c WHERE Id = :currentScreenPropertyCondition.trainRoute3];
		}
		// ▲2021.10.08 No.307 対応で変更

        this.GA104007Parameter.selectedStation = new List<Station__c>();//パラメータ初期化

		// ▼2021.10.08 No.307 対応で変更
		if (this.currentScreenPropertyCondition.stations3.size() > 0) {
			this.GA104007Parameter.selectedStation	= this.currentScreenPropertyCondition.stations3;
        }
		// ▲2021.10.08 No.307 対応で変更
    }

    // ▼問合せ415で追加
    /**
     * 中学校モーダルOpen処理
     */
    public void openJuniorHighSchoolDistrictModal() {
        hasErrorMessage = False;
        this.GA202002Parameter = new GA202002ParameterClass();

        setSchoolMode = 1;

        this.GA202002Parameter.isDrawing          = true;
        this.GA202002Parameter.noFirst            = true;
		// ▼2021.10.08 No.307 対応で変更
		if (currentScreenPropertyCondition.juniorHighSchoolArea != null ){//選択された中学校区を設定
			this.GA202002Parameter.juniorHighSchoolArea = currentScreenPropertyCondition.juniorHighSchoolArea;
        }
		// ▲2021.10.08 No.307 対応で変更

		// ▼2021.10.08 No.307 対応で変更
        this.GA202002Parameter.selectedSchool = new List<School__c>();//パラメータ初期化
		if (this.currentScreenPropertyCondition.juniorHighSchoolList.size() > 0) {//選択された学校を設定
			this.GA202002Parameter.selectedSchool	= this.currentScreenPropertyCondition.juniorHighSchoolList;
        }
		// ▲2021.10.08 No.307 対応で変更

        // モーダル側での小学校か中学校かの判定のため
        this.GA202002Parameter.modalMode = 6;
    }

    /**
     * 小学校モーダルOpen処理
     */
    public void openElementarySchoolDistrictModal() {
        hasErrorMessage = False;
        this.GA202002Parameter = new GA202002ParameterClass();

        setSchoolMode = 2;

        this.GA202002Parameter.isDrawing          = true;
        this.GA202002Parameter.noFirst            = true;
		// ▼2021.10.08 No.307 対応で変更
		if (currentScreenPropertyCondition.elementarySchoolArea != null ){//選択された小学校区を設定
			this.GA202002Parameter.elementarySchoolArea = currentScreenPropertyCondition.elementarySchoolArea;
        }
		// ▲2021.10.08 No.307 対応で変更

        this.GA202002Parameter.selectedSchool = new List<School__c>();//パラメータ初期化
		// ▼2021.10.08 No.307 対応で変更
		if (this.currentScreenPropertyCondition.elementarySchoolList.size() > 0) {//選択された学校を設定
			this.GA202002Parameter.selectedSchool	= this.currentScreenPropertyCondition.elementarySchoolList;
        }
		// ▲2021.10.08 No.307 対応で変更

        // モーダル側での小学校か中学校かの判定のため
        this.GA202002Parameter.modalMode = 7;
    }
    // ▲問合せ415で追加

    // ▼問合せ423で追加
     /**
     * 店舗・地区モーダルOpen処理
     */
    public void openShopDistrictModal() {
		this.GH201003Paremeter.selectedShopOrDistrictList = new  List<String>();
		// ▼2021.10.08 No.307 対応で変更
		if(String.isNotBlank(currentScreenPropertyCondition.DesiredArea)) {
			GH201003Paremeter.selectedShopOrDistrictList = currentScreenPropertyCondition.DesiredArea.Split(' '); 
        }
		// ▲2021.10.08 No.307 対応で変更
        GH201003Paremeter.isShopMode = false;
        GH201003Paremeter.isDrawing = true;
        GH201003Paremeter.noFirst = true;
        GH201003Paremeter.regionSelectionFlg = true;
    }
    // ▲問合せ423で追加

	// ▼2021.10.08 No.307 対応で追加
	// 物件条件を切替時の処理
	public void changeConditions(){
		hasErrorMessage = false;
		BusinessLogicException inputCheckex = new BusinessLogicException();
		try{
			//登録時
			if(isInsertFlg){
				// 入力チェック
				inputCheckex = inputAccountPropertyConditionsCheck(null);
				// エラーあり
				if(inputCheckex.hasMessage()){
					throw inputCheckex;
				}

				// 物件条件名に入力されている値でscreenPropertyConditionsMapのキーを置き換える。
				putDispCond(this.tmpCondName);

				// 物件条件名に入力されている値でAccountPropertyConditionsの値を置換える。
				changeSelectOptionLabel(this.AccountPropertyConditions, this.tmpCondName, this.currentScreenPropertyCondition.Name);
			}

			// 選択した物件条件をMap置替用変数にセットする。
			String selectCondNameLabel = commonConst.STRING_EMPTY;
			for(SelectOption sel : this.AccountPropertyConditions){
				if(sel.getValue().equals(this.selectCondName)){
					selectCondNameLabel = sel.getLabel();
				}
			}
			this.tmpCondName = selectCondNameLabel;

			// 選択した物件条件をcurrentScreenPropertyConditionにセットする。
			this.currentScreenPropertyCondition = this.screenPropertyConditionsMap.get(this.tmpCondName);
			// エラーメッセージをクリアする。
			ApexPages.getMessages().clear();
		}catch(Exception e){
			hasErrorMessage = true;//エラーを設定
			CommonUtil.setErrorMessage(e);
			isInsertFlg = true;
		}
	}

	// 物件条件名に入力されている値をscreenPropertyConditionsMapのキーにセットする。
	private void putDispCond(String tmpCondName){
		this.screenPropertyConditionsMap.remove(tmpCondName);
		this.screenPropertyConditionsMap.put(this.currentScreenPropertyCondition.Name, this.currentScreenPropertyCondition);
	}

	/**
	 * 選択リストのオプションのラベルを1件置き換える
	 * @param List<SelectOption> target 更新対象の選択リスト
	 * @param String befLabel 更新前のラベル
	 * @param String aftLabel 更新後のラベル
	 * @return void
	 */
	private void changeSelectOptionLabel(List<SelectOption> target, String befLabel, String aftLabel){
		// 物件条件名に入力されている値でAccountPropertyConditionsの値を置換える。
		Integer count = 0;
		for(SelectOption sel : target){
			if(sel.getLabel() == befLabel){
				target.set(count, new SelectOption(sel.getValue(), aftLabel));
			}
			count++;
		}
	}
	// ▲2021.10.08 No.307 対応で追加

	// ▼2021.10.08 No.307 対応で変更
    /**
     * 路線①変更時
     */
    public void changeTrainRoute1(){
		currentScreenPropertyCondition.stationsChar1 = CommonConst.STRING_EMPTY;     // 項目を空にする
		currentScreenPropertyCondition.stations1   = new List<Station__c>();      
    }

    /**
     * 路線②変更時
     */
    public void changeTrainRoute2(){
		currentScreenPropertyCondition.stationsChar2 = CommonConst.STRING_EMPTY;     // 項目を空にする
		currentScreenPropertyCondition.stations2   = new List<Station__c>();     
    }

    /**
     * 路線③変更時
     */
    public void changeTrainRoute3(){
		currentScreenPropertyCondition.stationsChar3 = CommonConst.STRING_EMPTY;     // 項目を空にする
		currentScreenPropertyCondition.stations3   = new List<Station__c>();      
    }

    // ▼問合せ415で追加
    // 中学校変更処理
    public void changeJuniorHighSchool() {
		currentScreenPropertyCondition.juniorHighSchoolList = new List<School__c>();//選択された中学校を初期化
		currentScreenPropertyCondition.desiredJuniorHighSchool = CommonConst.STRING_EMPTY;//表示用の選択された中学校を初期化
    }

    // 小学校変更処理
    public void changeElementarySchool() {
		currentScreenPropertyCondition.elementarySchoolList = new List<School__c>();//選択された小学校を初期化
		currentScreenPropertyCondition.desiredPrimarySchool = CommonConst.STRING_EMPTY;//表示用の選択された小学校を初期化
    }
    // ▲問合せ415で追加
	// ▲2021.10.08 No.307 対応で変更

    /**
     * 郵便番号のモーダル
     */
    public void postmodal1() {
        postMode = 1;
        GA102006Parameter.isDrawing = true;
        GA102006Parameter.noFirst = true;
        GA102006Parameter.isAddressMoster = true;       /** 住所マスタフラグ */
        //郵便番号個人用モーダル     
        GA102006Parameter.postalCode = this.screenAccountRecord.PostalCode;  //モーダルに渡す用郵便番号
        GA102006Parameter.state = this.screenAccountRecord.State;            //モーダルに渡す用都道府県
        GA102006Parameter.city = this.screenAccountRecord.City;              //モーダルに渡す用市町村
        GA102006Parameter.street ='';           //モーダルに渡す用町域     
    }  

    /**
     * 郵便番号のモーダル(法人)
     */
    public void postmodal2() {
        postMode = 2;
        GA102006Parameter.isDrawing = true;
        GA102006Parameter.noFirst = true;
        GA102006Parameter.isAddressMoster = true;       /** 住所マスタフラグ */
        //郵便番号モーダル(法人)     
        GA102006Parameter.postalCode = this.screenAccountRecord.CompanyPostalCode;  //モーダルに渡す用郵便番号
        GA102006Parameter.state = this.screenAccountRecord.CompanyState;            //モーダルに渡す用都道府県
        GA102006Parameter.city = this.screenAccountRecord.CompanyCity;              //モーダルに渡す用市町村
        GA102006Parameter.street ='';           //モーダルに渡す用町域     
    }  
    /**
     * 郵便番号のモーダル(勤務先_学校)
     */
    public void postmodal3() {
        postMode = 3;
        GA102006Parameter.isDrawing = true;
        GA102006Parameter.noFirst = true;
        GA102006Parameter.isAddressMoster = true;       /** 住所マスタフラグ */
        //郵便番号モーダル(勤務先_学校)
        GA102006Parameter.postalCode = this.screenAccountRecord.AffiliationPostalCode;  //モーダルに渡す用郵便番号
        GA102006Parameter.state = this.screenAccountRecord.AffiliationState;            //モーダルに渡す用都道府県
        GA102006Parameter.city = this.screenAccountRecord.AffiliationCity;              //モーダルに渡す用市町村
        GA102006Parameter.street ='';           //モーダルに渡す用町域      
    }  

    /**
     * モーダル閉じたときの処理
     */
    public void closeModal(){
        // 閉じるときにurlとQRの警告文言表示のフラグを初期化する。
        qrUrl = CommonConst.STRING_EMPTY;                         // QRの生成用URL
        WarningFlg =false;                  // 申込の警告表示フラグ

        //▼問合せNo341で追加
        List<Account> accountList = new List<Account>();
        accountList = selectAccountInfo(this.accountId);
        if(accountList.size() > 0){
            Account account = accountList[0];
            screenAccountRecord = new screenAccount();
            screenAccountRecord = new screenAccount(accountList[0]);
            screenAccountRecord.EchoTelephoneFlag = account.EchoTelephoneFlag__c;
            //▼問合せNo411で追加
            screenAccountRecord.EchoLineFlag = account.EchoLineFlag__c;
            screenAccountRecord.EchoLiveroFlag = account.EchoLiveroFlag__c;
            //▲問合せNo411で追加
            if(this.openModalFlg == 7){
                screenAccountRecord.IntroMailInfoStatus = account.IntroMailInfoStatus__c;
                screenAccountRecord.systemModStamp = account.systemModStamp;
            }
        }
        //▲問合せNo341で追加
        
        // 開いたモーダルによって値を返却する。
        if(this.openModalFlg == 1){
            this.checkCorrespondId = GA102001Paremeter1.CorrespondId;         // 対応ID
            this.correspondId= GA102001Paremeter1.CorrespondId;
        }
        //追加要望 追加 start
        //取引先再取得 
        // accountList = selectAccountInfo(this.accountId);
        // screenAccountRecord = new screenAccount(accountList[0]);
        // screenAccountRecord_bak = screenAccountRecord.clone();
        this.introMailInfoList = new List<IntroductionMailInformation__c>();
        //紹介メール情報再取得
        this.introMailInfoList = selectIntroMailInfo(this.accountId);
        //追加要望 追加 end

        //▼ 2021.09.24 No.489 反響一覧登録フラグがtrueであれば、反響一覧に追加
        if(GA102001Paremeter2.echoInsertFlg) {
            List<CorrespondDetail__c> CorrespondDetailList = selectCorrespondDetailInfo(this.accountId);//2022.01.12 No.489 対応で引数変更
            if (CorrespondDetailList.size() > 0){
                // リストをセット
                setCorrespondDetailList(CorrespondDetailList, CommonConst.STRING_EMPTY);//2022.01.12 No.489 対応で引数変更
            }
        }
        //▲ 2021.09.24 No.489

        // 再取得
        if (RefreshCorrespondenceHistory || mizukimeFlg){
            // 対応履歴再描画
            getCorrespondenceHistoryList();

            // 申込一覧再取得
            getApplicationList();

            RefreshCorrespondenceHistory = false;
        }
        if (RefreshCorrespondenceStatus || mizukimeFlg){
            // 対応状況再描画
            getCorrespondenceStatusList();
            //問合せNo341で変更
            //setButtonList();
            buttonSet();
            RefreshCorrespondenceStatus = false;

        }
        if (RefreshFavoriteProperty){
            // お気に入り物件再描画
            getFavoritePropertyList();
            RefreshFavoriteProperty = false;
        }

        if (RefreshExactConditionMatchProperty){
            // 条件完全一致物件再描画
            getExactConditionMatchPropertyList();
            RefreshExactConditionMatchProperty = false;
        }

        mizukimeFlg = false;
        this.openModalFlg = 0;
    }

    /**
     * 駅モーダル閉じたときの処理
     */
    public void closeStationModal() {
        // this.HeaderLockFlg = false;
        WarningFlg =false;                  // 申込の警告表示フラグ
        mizukimeFlg = false;

        if(setStationMode == 1){
            // 路線１
			// ▼2021.10.08 No.307 対応で変更
			this.currentScreenPropertyCondition.stations1	= this.GA104007Parameter.selectedStation;
			this.currentScreenPropertyCondition.stationsChar1 = convStationListToString(this.GA104007Parameter.selectedStation);
			// ▲2021.10.08 No.307 対応で変更
        }else if(setStationMode == 2){
            // 路線２
			// ▼2021.10.08 No.307 対応で変更
			this.currentScreenPropertyCondition.stations2	= this.GA104007Parameter.selectedStation;
			this.currentScreenPropertyCondition.stationsChar2 = convStationListToString(this.GA104007Parameter.selectedStation);
			// ▲2021.10.08 No.307 対応で変更
        }else if (setStationMode == 3){
            // 路線３
			// ▼2021.10.08 No.307 対応で変更
			this.currentScreenPropertyCondition.stations3	= this.GA104007Parameter.selectedStation;
			this.currentScreenPropertyCondition.stationsChar3 = convStationListToString(this.GA104007Parameter.selectedStation);
			// ▲2021.10.08 No.307 対応で変更
        }
        setStationMode = 0;

        changeFlg = true;
    }

    /**
     * モーダル閉じたときの処理(郵便番号)
     */
    public void closePostModal(){
        // this.HeaderLockFlg = false;
        WarningFlg =false;                  // 申込の警告表示フラグ
        mizukimeFlg = false;

        if(postMode== 1){
            // 郵便番号のモーダル
            this.screenAccountRecord.PostalCode = GA102006Parameter.postalCode ;                //郵便番号
            this.screenAccountRecord.State = GA102006Parameter.state ;                          //都道府県
            this.screenAccountRecord.City = GA102006Parameter.city+GA102006Parameter.street ;   //市町村
            this.screenAccountRecord.Street = CommonConst.STRING_EMPTY;
        }else if(postMode == 2){
            // 郵便番号のモーダル(法人)
            this.screenAccountRecord.CompanyPostalCode = GA102006Parameter.postalCode;              //郵便番号
            this.screenAccountRecord.CompanyState = GA102006Parameter.state;                        //都道府県
            this.screenAccountRecord.CompanyCity = GA102006Parameter.city+GA102006Parameter.street; //市町村
            this.screenAccountRecord.CompanyStreet = CommonConst.STRING_EMPTY;
        }else if(postMode == 3){
            // 郵便番号のモーダル(勤務先_学校)
            this.screenAccountRecord.AffiliationPostalCode = GA102006Parameter.postalCode ;             //郵便番号
            this.screenAccountRecord.AffiliationState = GA102006Parameter.state ;                       //都道府県
            this.screenAccountRecord.AffiliationCity = GA102006Parameter.city+GA102006Parameter.street; //市町村
            this.screenAccountRecord.AffiliationStreet = CommonConst.STRING_EMPTY;

        }
        changeFlg = true;
        postMode = 0;
    }

    // ▼問合せ415で追加
    /**
     * 学校モーダル閉じたときの処理
     */
    public void closeSchoolModal() {
        // this.HeaderLockFlg = false;
        WarningFlg =false;                  // 申込の警告表示フラグ
        mizukimeFlg = false;

        if(setSchoolMode == 1){
            // 中学校
			// ▼2021.10.08 No.307 対応で変更
			this.currentScreenPropertyCondition.juniorHighSchoolList = this.GA202002Parameter.selectedSchool;//モーダルで選択された学校（中学校）
			this.currentScreenPropertyCondition.desiredJuniorHighSchool = convSchoolListToString(this.GA202002Parameter.selectedSchool);//表示用のモーダルで選択された学校（中学校）
			// ▲2021.10.08 No.307 対応で変更
        }else if(setSchoolMode == 2){
            // 小学校
			// ▼2021.10.08 No.307 対応で変更
			this.currentScreenPropertyCondition.elementarySchoolList = this.GA202002Parameter.selectedSchool;//モーダルで選択された学校（小学校）
			this.currentScreenPropertyCondition.desiredPrimarySchool = convSchoolListToString(this.GA202002Parameter.selectedSchool);//表示用のモーダルで選択された学校（小学校）
			// ▲2021.10.08 No.307 対応で変更
        }
        setSchoolMode = 0;

        changeFlg = true;
    }
    // ▲問合せ415で追加

    // ▼問合せ423で追加
     /**
     * 店舗・地区モーダル閉じたときの処理
     */
    public void closeShopDistrictModal() {
    
        WarningFlg =false;                  // 申込の警告表示フラグ
        mizukimeFlg = false;

		// ▼2021.10.08 No.307 対応で変更
		currentScreenPropertyCondition.DesiredArea = '';
        for(String District : GH201003Paremeter.selectedShopOrDistrictList){
			currentScreenPropertyCondition.DesiredArea += (District + ' ');
        }
		// ▲2021.10.08 No.307 対応で変更

    }
    // ▲問合せ423で追加

    /**
    * キャンセルボタン押下時
    */
    public void cancelButton(){
        // 表示モードへ移行
        isInsertFlg = false;

        // ヘッダのロック
        this.HeaderLockFlg = true;

		// ▼2021.10.08 No.307 対応で変更
		List<Account> accountList = new List<Account>();
		accountList = selectAccountInfo(this.accountId);

		screenAccountRecord = new screenAccount(accountList[0]);

		setAccountPropertyCondition(accountList[0]);
        
        // 問合せ415で追加
		setStation();
		setSchool();
		// ▲2021.10.08 No.307 対応で変更

        // 対応履歴再描画（対応履歴のTransientの設定のためお気に入り物件が更新されたら再度取り直す）
        getCorrespondenceHistoryList();

        if(screenAccountRecord.ContractType == '法人契約'){
            // 法人
            contractTypeFlg = False;
        }else {
            // 個人（法人以外は個人にしておく）
            contractTypeFlg = True;
        }
        checkNewSetting();
    }

    /**
    　契約形態変更時の処理
     */
    public void getContractType(){
        changeFlg = true;
        if (screenAccountRecord.ContractType == '法人契約'){
            // 法人
            contractTypeFlg = False;
        }else{
            // 個人（法人以外は個人にしておく）
            contractTypeFlg = True;
        }
    }

    /**
     * 年齢再計算
     */
    public void ageRecalculate(){
        //取引先の年齢再計算
        Account newAgeApp = new Account(Birthdate__c = screenAccountRecord.Birthdate);
        newAgeApp.recalculateFormulas();
        screenAccountRecord.Age = newAgeApp.Age__c;
    }

    /**
     * 来店ボタン押下
     */
    public void openVisitCard(){
        this.hasErrorMessage = false;
        WarningFlg = false;
        mizukimeFlg = true;
        
        try{
            //楽観ロックの有無判定
            throwOptimisticLockOfCorrespond();
            // QRのurlを設定する。
            qrUrl = CommonConst.STRING_EMPTY;

            if(checkStatus == CORRESPOND_STATUS_CLOSE || checkStatus == CORRESPOND_STATUS_AGREEMENT || checkStatus == CORRESPOND_STATUS_ECHOAGGREGATION){
                // 反響集約と、終了、契約完了の状態が選ばれているとき対応を含めない
                // https://roomselect--sandpg01.lightning.force.com/?un=【ログインユーザ名】&startURL=【来店カードページURL】?AccountId=【取引先ID】
                qrUrl = URL.getSalesforceBaseUrl().toExternalForm();
                qrUrl += '?un='+UserInfo.getUserName()+ '&startURL=';
                qrUrl += EncodingUtil.urlEncode('/apex/GA202001View?acc='+screenAccountRecord.Id, 'UTF-8');
                qrUrl += EncodingUtil.urlEncode('&userId=' + UserInfo.getUserId(), 'UTF-8');

            }else{
                // 来店カードが無ければ取引先と対応IDをセットする。
                // https://roomselect--sandpg01.lightning.force.com/?un=【ログインユーザ名】&startURL=【来店カードページURL】?AccountId=【取引先ID】&Corresponds=【対応ID】
                qrUrl = URL.getSalesforceBaseUrl().toExternalForm();
                qrUrl += '?un='+UserInfo.getUserName() + '&startURL=';
                qrUrl += EncodingUtil.urlEncode('/apex/GA202001View','UTF-8');
                qrUrl += EncodingUtil.urlEncode('?acc='+screenAccountRecord.Id,'UTF-8');
                qrUrl += EncodingUtil.urlEncode('&Corresponds='+this.checkCorrespondId,'UTF-8');
                qrUrl += EncodingUtil.urlEncode('&userId=' + UserInfo.getUserId(), 'UTF-8');
            }
        
            system.debug('qrUrl='+qrUrl);
        }catch(Exception e){
            this.hasErrorMessage = True;
            CommonUtil.setErrorMessage(e);
        }
    }

    /**
     * 申込ボタン押下
     * 対象の対応に物件がセットされていなければセットする。
     */
    public void openApplicatiou(){
        Savepoint sp = Database.setsavepoint();
        hasErrorMessage = False;
        try{
            boolean newFlg = false;
            linkProperty = checkProperty;
            qrUrl = CommonConst.STRING_EMPTY;
            // 申込時の対応紐づけ処理
            newFlg = setApplication();

            // 新規でデータができている場合対応と物件Idをセットする。※※※※
            if(newflg){
                this.checkProperty = this.PropertyLinkProperty;
                this.checkCorrespondId = this.PropertyLinkId;
            }

            // 対応状況を再設定
            this.screenCorrespondRecordList = new List<screenCorrespond>(); 
            this.correspondList = selectCorrespondInfo(this.accountId,CommonConst.STRING_EMPTY);
            if (this.correspondList.size() > 0){
                this.correspondId = checkCorrespondId;
                // リストをセット
                setCorrespondList(this.correspondList,this.correspondId);
                // 対応単体取得
                // this.correspondList = new Correspond__c();
                this.correspondList = selectCorrespondInfo(this.accountId,this.correspondId);
                if (this.correspondList.size() > 0 ){
                    this.screenCorrespondRecord = this.correspondList[0];
                }
            }

            // パラメータ値を設定する。
            paramApplication = CommonConst.STRING_EMPTY;
            
            if (!String.isBlank(checkApplication)){
                paramApplication += 'applicationId='+checkApplication;
                paramApplication +='&';
            }
            
            paramApplication += 'accountId='+ screenAccountRecord.Id;
            paramApplication += '&propertyId='+ this.checkProperty;
            paramApplication += '&correspondId='+ this.checkCorrespondId;
        }catch(Exception e){
            database.rollback(sp);
            hasErrorMessage = True;
            CommonUtil.setErrorMessage(e);
        }
    }

    /**
     * 申込（iPad）ボタン押下
     * 
     */
    public void openApplicatiouiPod(){
        Savepoint sp = Database.setsavepoint();
        hasErrorMessage = False;
        try{
            linkProperty = checkProperty;
            WarningFlg = true;
            mizukimeFlg = false;
            boolean newFlg = false;
            BusinessLogicException ex = new BusinessLogicException();
            // 申込時の対応紐づけ処理
            newFlg = setApplication();

            // 新規でデータができている場合対応と物件Idをセットする。※※※※
            if(newflg){
                this.checkProperty = this.PropertyLinkProperty ;
                this.checkCorrespondId = this.PropertyLinkId;
            }
            

            this.screenCorrespondRecordList = new List<screenCorrespond>(); 
            this.correspondList = selectCorrespondInfo(this.accountId,CommonConst.STRING_EMPTY);
            if (this.correspondList.size() > 0){                
                this.correspondId = checkCorrespondId;
                // リストをセット
                setCorrespondList(this.correspondList,this.correspondId);
                // 対応単体取得
                // this.correspondList = new Correspond__c();
                this.correspondList = selectCorrespondInfo(this.accountId,this.correspondId);
                if (this.correspondList.size() > 0 ){
                    this.screenCorrespondRecord = this.correspondList[0];
                }
            }

            if (String.isBlank(checkApplication)){
                // iPad用のurlを渡す。
                // https://roomselect--sandpg01.lightning.force.com/?un=【ログインユーザ名】&startURL=【申込ページURL】?acc1=【物件コード】?acc2=【取引先ID】?acc3=【対応ID】
                qrUrl = URL.getSalesforceBaseUrl().toExternalForm();
                qrUrl += '?un='+UserInfo.getUserName() + '&startURL=';
                qrUrl += EncodingUtil.urlEncode('/apex/GA103001View', 'UTF-8');
                qrUrl += EncodingUtil.urlEncode('?propertyId='+ this.checkProperty, 'UTF-8');
                qrUrl += EncodingUtil.urlEncode('&accountId='+ screenAccountRecord.Id, 'UTF-8'); 
                qrUrl += EncodingUtil.urlEncode('&correspondId=' + this.checkCorrespondId, 'UTF-8');
                qrUrl += EncodingUtil.urlEncode('&comeFrom=App','UTF-8');
                qrUrl += EncodingUtil.urlEncode('&userId=' + UserInfo.getUserId(), 'UTF-8');
            }else{
                // iPad用のurlを渡す。（申込あり）
                // https://roomselect--sandpg01.lightning.force.com/?un=【ログインユーザ名】&startURL=【申込ページURL】?acc=【申込番号】?acc2=【対応ID】
                qrUrl = URL.getSalesforceBaseUrl().toExternalForm();
                qrUrl += '?un='+UserInfo.getUserName() + '&startURL=';
                qrUrl += EncodingUtil.urlEncode('/apex/GA103001View', 'UTF-8'); 
                qrUrl += EncodingUtil.urlEncode('?applicationId='+this.checkApplication, 'UTF-8'); 
                qrUrl += EncodingUtil.urlEncode('&correspondId='+this.checkCorrespondId, 'UTF-8');
                qrUrl += EncodingUtil.urlEncode('&comeFrom=App', 'UTF-8');
                qrUrl += EncodingUtil.urlEncode('&userId=' + UserInfo.getUserId(), 'UTF-8');
            }
            system.debug('qrUrl='+qrUrl);
        }catch(Exception e){
            database.rollback(sp);
            hasErrorMessage = True;
            CommonUtil.setErrorMessage(e);
        }
    }

    /**
     * 地区リスト変更時(対応履歴の再描画)
     */
    public void getCorrespondenceHistoryList(){
        // 対応履歴を取得する。
        List<CorrespondDetail__c> localCorrespondDetailList ;
        String District = CommonConst.STRING_EMPTY;
        if(!string.isBlank(selectDistrict)){
            // 入っていたら設定
            District = selectDistrict;
        }

        localCorrespondDetailList = selectCorrespondDetailInfo(this.accountId);//2022.01.12 No.489 対応で引数変更
        screenCorrespondDetailList = new List<screenCorrespondDetail>();
        if (localCorrespondDetailList.size() > 0){
            // リストをセット
            setCorrespondDetailList(localCorrespondDetailList, District);//2022.01.12 No.489 対応で引数変更
        }

        // 地区のリスト作成
        selectDistrictList = getSelectDistrictList(this.accountId);

    }

    /**
     * 対応状況の再表示
     */
    public void getCorrespondenceStatusList(){
        // 対応状況を取得する。
        List<Correspond__c> localCorrespondList;

        localCorrespondList = selectCorrespondInfo(this.accountId,CommonConst.STRING_EMPTY);
        
        this.screenCorrespondRecordList = new List<screenCorrespond>();
        System.debug('★localCorrespondList：' + localCorrespondList);
        System.debug('★this.accountId：' + this.accountId);
        if (localCorrespondList.size() > 0){
            // リストをセット
            setCorrespondList(localCorrespondList,this.checkCorrespondId);
        }else{
            // 1件も取得できない状態は1件だけ条件に関係なく最新の対応を取得する。
            List<Correspond__c> correspondEndDate ;                      // 対応の一覧表示
            correspondEndDate = selectCorrespondInfoAgentEnd(this.accountId);
            System.debug('★correspondEndDate：' + correspondEndDate);
            if(correspondEndDate.size() > 0){

                setCorrespondList(correspondEndDate,this.correspondId);
            }
        }
    }

    /**
     * お気に入り物件の再表示
     */
    public void getFavoritePropertyList(){
        // 対応履歴を取得する。
        List<FavoriteProperty__c> localfavoritePropertyList;
        localfavoritePropertyList = selectFavoritePropertyInfo(this.accountId,CommonConst.STRING_EMPTY);
        this.screenFavoritePropertyList = new List<screenFavoriteProperty>();
        if (localfavoritePropertyList.size() > 0){
            // リストをセット
            setFavoritePropertyList(localfavoritePropertyList);
        }

    }
    /**
     * 条件完全一致物件の再表示
     */
    public void getExactConditionMatchPropertyList(){
        // 条件完全一致物件を取得する。
        List<ExactConditionMatchProperty__c> localExactConditionMatchPropertyList;
        localExactConditionMatchPropertyList = selectExactConditionMatchPropertyInfo(this.accountId);
        this.screenExactConditionMatchPropertyList = new List<screenExactConditionMatchProperty>();
        if (localExactConditionMatchPropertyList.size() > 0){
            // リストをセット
            setExactConditionMatchPropertyList(localExactConditionMatchPropertyList);
        }

    }
    
    /**
     * 空室予約物件明細の設定
     */
    private void setScreenVacancyReservationProp() {

        // 空室予約物件を取得
        List<VacancyReservationProperty__c> vacancyReservationPropList = this.selectVacancyReservationProp(this.accountId);
        
        // 空室予約物件明細の設定
        this.screenVacancyReservationPropList = new List<screenVacancyReservationProp>();
        for (VacancyReservationProperty__c vacancyReservationProp : vacancyReservationPropList) {
            screenVacancyReservationPropList.add(new screenVacancyReservationProp(vacancyReservationProp, this.accountId));
        }
    }

    /**
     * 申込の取得
     */
    public void getApplicationList(){
        // 対応履歴を取得する。
        this.screenApplicationList  = new List<screenApplication>();
        this.applicationList = selectApplicationInfo(this.accountId);
        if (this.applicationList.size() > 0){
            // リストをセット
            setApplicationList(this.applicationList);
        }
    }

    /**
     * お引越し理由変更時の処理
     */
    public void changeHomeMovingReason(){
        changeFlg = true;
        if(!this.homeMovingReasonCheckList.get('現状不満')){//現状不満のチェックが外れた場合、「現状不満理由」を初期化する
            this.screenAccountRecord.dissatisfaction = null;
        }
    }

    /**
     * 取込　ボタン押下
     *  ファイルを取得する
     */
    public void downloadFile() {
        try {
            BusinessLogicException ex = new BusinessLogicException();
           
            // エラー初期化
            this.hasErrorMessage = false;

            List<Id> targetIdList = new List<Id>(); 
            if(String.isNotBlank(CorrespondDetailEchoMailId)){ //受信メールの場合                
                targetIdList.add(CorrespondDetailEchoMailId);
            }else if(String.isNotBlank(CorrespondDetailId)){ //送信メールの場合
                targetIdList.add(CorrespondDetailId);
            }            
     
            // 添付取得
            List<Attachment> attachments = [SELECT Id FROM Attachment WHERE ParentId = :targetIdList];
           
            // データがない場合はエラー
            if (attachments.size() == 0) {
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_NO_DATA));
                throw ex;
            }

            // 添付ファイルID文字列作成（「,」区切り複数）
            String retId = '';
            for(Attachment file : attachments) {
                retId += String.isEmpty(retId) ? '' : ',';
                retId += file.Id;
            }
            this.attachmentIdList = retId;

        } catch(Exception e) {
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    /**
     * メールボタン押下時の対応明細取得
     */
    public void getCorrespondDetail(){
        this.hasErrorMessage = false;
        try {
            //楽観ロックの有無判定
            throwOptimisticLockOfCorrespond();
            mailButtonParam = CommonConst.STRING_EMPTY;
            List<CorrespondDetail__c> CorrespondDetailRecord = new List<CorrespondDetail__c>();
            //▼問合せNo316で変更  
            CorrespondDetailRecord = [ SELECT id,
                                        EchoMail__r.FromPotalSite__c
                                        FROM CorrespondDetail__c
                                        WHERE Corresponds__c = :this.checkCorrespondId
                                        AND   CorrespondType__c = :CommonConst.TASK_CORRESPONDTYPE_MAIL
                                        AND   MailType__c = :CommonConst.CORRESPONDDETAIL_MAILTYPE_RECEIVE
                                        AND   (Not EchoMail__r.FromEmail__c like 'mailer-daemon%')
                                        ORDER BY SupportedDateTime__c DESC
                                        LIMIT 1];

            if(CorrespondDetailRecord.size() > 0 && CorrespondDetailRecord.get(0).EchoMail__r.FromPotalSite__c != null){
                mailButtonParam = 'shopId='+ loginShop + '&accountId=' + screenAccountRecord.Id + '&correspondDetailId=' + CorrespondDetailRecord[0].id + '&correspondId=' + checkCorrespondId;
            //▲問合せNo316で変更
            }else{
                mailButtonParam = 'shopId='+ loginShop + '&accountId=' + screenAccountRecord.Id + '&correspondId=' + checkCorrespondId;
            }

        } catch(Exception e) {
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    /**
     * 対応履歴画面モーダル表示処理
     */
    private void openModal2State() {
        try {
            this.hasErrorMessage = False;
            //楽観ロックの有無判定
            throwOptimisticLockOfCorrespond();
            
            openModal2();
            
        }catch(Exception e){                
            this.hasErrorMessage = True;
            CommonUtil.setErrorMessage(e);
        }
    }

    /**
     * 対応履歴画面モーダル表示設定
     */
    private void openModal2() {
            
        // 前のデータが残らないように初期化
        GA102001Paremeter2 = new GA102001Modal2ParameterClass();

        this.RefreshCorrespondenceHistory = true;                   // 対応履歴再描画フラグを立てる
        this.RefreshCorrespondenceStatus = true;                    // 対応状況再描画フラグを立てる
        this.openModalFlg = 2 ;

        GA102001Paremeter2.AccountId = this.accountId;  // 取引先ID
        GA102001Paremeter2.CorrespondId = this.checkCorrespondId; // 対応ID
        GA102001Paremeter2.CorrespondDetailId = this.selectCorrespondDetailId;  // 対応明細Id
        GA102001Paremeter2.CorrespondType = this.correspondType; // 対応種別
        GA102001Paremeter2.Status = this.setStatus; // ステータス
        GA102001Paremeter2.isDrawing = true;
        GA102001Paremeter2.noFirst = true;

		// ▼2021.10.08 No.307 対応で予約物件条件モーダル追加
		if((!CORRESPOND_STATUS_PURSUITHOLD.equals(checkStatus)) && (this.accountId != null)){
			//追客保留ボタン押下時、予約物件条件モーダルパラメータをセット
			this.GA102001Paremeter2.GA102001Paremeter10 = new GA102001Modal10ParameterClass();
			this.GA102001Paremeter2.GA102001Paremeter10.isDrawing = true;
			this.GA102001Paremeter2.GA102001Paremeter10.noFirst = true;
			
			this.GA102001Paremeter2.GA102001Paremeter10.spcIdList = new List<Id>();//ID
			this.GA102001Paremeter2.GA102001Paremeter10.spcNameList = new List<String>();//物件条件名
			this.GA102001Paremeter2.GA102001Paremeter10.spcReservedList = new List<Boolean>();//予約物件条件
			this.GA102001Paremeter2.GA102001Paremeter10.allSpcReserved = true;//予約物件条件全チェックフラグ
			this.GA102001Paremeter2.GA102001Paremeter10.spcAccountFlgList = new List<Boolean>();//取引先フラグ
			this.GA102001Paremeter2.GA102001Paremeter10.spcIndexList = new List<Integer>();//インデックス

			//取引先を再取得
			List<Account> accountList = selectAccountInfo(this.accountId);

			this.GA102001Paremeter2.GA102001Paremeter10.spcIdList.add(accountList[0].Id);//ID
			this.GA102001Paremeter2.GA102001Paremeter10.spcNameList.add(accountList[0].PropertyConditionsName__c);//物件条件名
			this.GA102001Paremeter2.GA102001Paremeter10.spcReservedList.add(accountList[0].IsReservePropertyConditions__c);//予約物件条件
			if(accountList[0].IsReservePropertyConditions__c == false)this.GA102001Paremeter2.GA102001Paremeter10.allSpcReserved = false;//予約物件条件全チェックフラグ
			this.GA102001Paremeter2.GA102001Paremeter10.spcAccountFlgList.add(true);//取引先フラグ
			this.GA102001Paremeter2.GA102001Paremeter10.spcIndexList.add(0);//インデックス

			//お客様物件条件を再取得
			List<AccountPropertyConditions__c> accountPCList = new List<AccountPropertyConditions__c>();
			accountPCList = getAccountPropertyConditions(this.accountId);

			Integer index = 1;
			for(AccountPropertyConditions__c accountPC: accountPCList){
				this.GA102001Paremeter2.GA102001Paremeter10.spcIdList.add(accountPC.Id);//ID
				this.GA102001Paremeter2.GA102001Paremeter10.spcNameList.add(accountPC.Name);//物件条件名
				this.GA102001Paremeter2.GA102001Paremeter10.spcReservedList.add(accountPC.IsReservePropertyConditions__c);//予約物件条件
				if(accountPC.IsReservePropertyConditions__c == false)this.GA102001Paremeter2.GA102001Paremeter10.allSpcReserved = false;//予約物件条件全チェックフラグ
				this.GA102001Paremeter2.GA102001Paremeter10.spcAccountFlgList.add(false);//取引先フラグ
				this.GA102001Paremeter2.GA102001Paremeter10.spcIndexList.add(index);//インデックス
				index++;
			}
			//バックアップ
			this.GA102001Paremeter2.GA102001Paremeter10.befSpcReservedList = this.GA102001Paremeter2.GA102001Paremeter10.spcReservedList.clone();
			this.GA102001Paremeter2.GA102001Paremeter10.openModalDate = Datetime.now();//アクセス日時（楽観ロックチェック用）
		}
		// ▲2021.10.08 No.307 対応で予約物件条件モーダル追加
		
		// ▼ 2021.11.30 LINE連携対応より、対応種別表示フラグを追加
		GA102001Paremeter2.isDispCorrespondType = this.screenCorrespondRecordList[checkCorrespondIndex].isDispModal2CorrespondType;
		// ▲ 2021.11.30
    }

    //対応の更新日付から楽観ロックの有無判定
    private void throwOptimisticLockOfCorrespond(){
        //最新の対応の更新日付を取得
        List<Correspond__c> latestRecord = new List<Correspond__c>();
        latestRecord = [ SELECT systemModstamp
                         FROM Correspond__c
                         WHERE id = :checkCorrespondId
                       ];     
        DateTime systemModstamp = null;         
        if(latestRecord.size() > 0){
            systemModstamp = latestRecord[0].systemModstamp;
        }
        DateTime preSystemModStamp = null;
        if(screenCorrespondRecordList.size() > 0){
            preSystemModstamp = screenCorrespondRecordList[checkCorrespondIndex].SystemModstamp;
        }
        //楽観ロックチェックExceptionを発行(対応)
        if (systemModstamp != preSystemModStamp){
            OptimisticLockException ex = new OptimisticLockException();
            throw ex;
            
        }
    }

    /**
     * 対応の更新日付から楽観ロックの有無判定（対応履歴の編集ボタン押下から）
     * @param 
     * @return 
     */
    private void throwOptimisticLockOfCorrespondEdit(){
        //最新の対応の更新日付を取得
        List<Correspond__c> latestRecord = new List<Correspond__c>();
        latestRecord = [ SELECT systemModstamp
                            FROM Correspond__c
                            WHERE id = :CorrespondDetailCorrespondsId
                        ];     
        DateTime systemModstamp = null;         
        if(latestRecord.size() > 0){
            systemModstamp = latestRecord[0].systemModstamp;
        }
        for(screenCorrespond screenCorrespondRecord:screenCorrespondRecordList){
            if(CorrespondDetailCorrespondsId != screenCorrespondRecord.Id){
                continue;
            }
            //同じ対応IDで更新日が違っていれば楽観ロックチェックExceptionを発行(対応)
            if (systemModstamp != screenCorrespondRecord.SystemModstamp){
                OptimisticLockException ex = new OptimisticLockException();
                throw ex;
            }
        }           
    }

    //取引先の更新日付から楽観ロックの有無判定
    private Boolean checkOptimisticLockOfAccout(){
        Boolean isNotError = true;
        this.hasErrorMessage = False;
        try{
            //最新の対応の更新日付を取得
            List<Account> latestRecord = new List<Account>();
            latestRecord = [ SELECT systemModStamp
                             FROM Account
                             WHERE id = :accountId
                           ];            
            DateTime systemModstamp = null;         
            if(latestRecord.size() > 0){
                systemModstamp = latestRecord[0].systemModstamp;
            }    
            DateTime preSystemModStamp = screenAccountRecord.SystemModstamp;

            //楽観ロックチェックExceptionを発行(取引先)
            if (systemModstamp != preSystemModstamp){
                isNotError = false;
                OptimisticLockException ex = new OptimisticLockException();
                throw ex;
            }          
        } catch(Exception e) {
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
        return isNotError;
    }

	// ▼2021.10.08 No.307 対応で追加
	//お客様物件条件の更新日付から楽観ロックの有無判定
	private Boolean checkOptimisticLockOfSpc(){
		Boolean isNotError = true;
		this.hasErrorMessage = False;
		try{
			//最新の対応の更新日付を取得
			List<AccountPropertyConditions__c> latestRecords = new List<AccountPropertyConditions__c>();
			latestRecords = [ SELECT Id, systemModStamp
							FROM AccountPropertyConditions__c
							WHERE Account__c = :accountId
						];
			DateTime systemModstamp = null;
			for(AccountPropertyConditions__c spc: latestRecords){
				for(screenPropertyConditions preSpc: screenPropertyConditionsMap.values()){
					if(spc.Id.equals(preSpc.dispCondId)){
						//楽観ロックチェックExceptionを発行(お客様物件条件)
						if (spc.systemModStamp != preSpc.systemModStamp){
							isNotError = false;
							OptimisticLockException ex = new OptimisticLockException();
							throw ex;
						}
					}
				}
			}
		} catch(Exception e) {
			this.hasErrorMessage = true;
			CommonUtil.setErrorMessage(e);
		}
		return isNotError;
	}
	// ▲2021.10.08 No.307 対応で追加

    /**
     * 返信ボタン押下時の担当者設定の判定
     */
    public void personnelCheck(){
        hasErrorMessage = false;
        ReplyFlg = false;
        try {
            setMailSopId = CommonConst.STRING_EMPTY;
            mailButtonParam = CommonConst.STRING_EMPTY;
            List<Correspond__c> CorrespondRecord = new List<Correspond__c>();
            CorrespondRecord = [ SELECT id
                                        ,EchoStaff__c
                                        ,ShopStaff__c
                                        ,EchoShop__c
                                        ,VisitShop__c
                                        FROM Correspond__c
                                        WHERE id = :CorrespondDetailCorrespondsId
                                        ];   
            System.debug('CorrespondRecord:' + CorrespondRecord);
            if(CorrespondRecord.size() > 0){
                if(CorrespondRecord[0].EchoStaff__c == null && CorrespondRecord[0].ShopStaff__c == null){
                    // スタッフが設定されていない
                    ReplyFlg = false;
                }else{
                    // 設定されているので、フラグを立てる。
                    ReplyFlg = true;
                    // 店舗を設定する。
                    if(CorrespondRecord[0].VisitShop__c == loginShop){
                        setMailSopId = CorrespondRecord[0].VisitShop__c;
                    }else if(CorrespondRecord[0].EchoShop__c == loginShop ) {
                        setMailSopId = CorrespondRecord[0].EchoShop__c;
                    }else if(CorrespondRecord[0].VisitShop__c != null){
                        setMailSopId = CorrespondRecord[0].VisitShop__c;
                    }else if(CorrespondRecord[0].EchoShop__c != null ) {
                        setMailSopId = CorrespondRecord[0].EchoShop__c;
                    }
                    
                }

            }


        } catch(Exception e) {
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }


// -----------------------------------------------------------------------------------------------
// オブジェクト操作系
// -----------------------------------------------------------------------------------------------
    /**
     * 登録ボタン 押下
     *  取引先の情報を保存する。
     */
    public void saveDate() {
        Savepoint sp = Database.setSavepoint();      //セーブポイント作成
        hasErrorMessage = false;
        BusinessLogicException inputCheckex = new BusinessLogicException();
        try{
            //楽観ロックチェックExceptionを発行(取引先)
            if (this.accountId != null) {
                List<account> checkOptimisticLockExceptionRecord = new List<Account>();
                checkOptimisticLockExceptionRecord = [ SELECT id
                                                            FROM Account
                                                            WHERE id = :this.accountId
                                                            AND SystemModStamp > :screenAccountRecord.systemModStamp ];                //楽観ロックチェック
                if (!checkOptimisticLockExceptionRecord.isEmpty()){
                    OptimisticLockException ex = new OptimisticLockException();
                    throw ex;
                }
            }
			//楽観ロックチェックExceptionを発行(お客様物件条件) 2021.10.08 No.307 対応で追加
			checkOptimisticLockOfSpc();
            // 入力チェック
            inputCheckex = inputCheck();
            // エラーあり
            if(inputCheckex.hasMessage()){
                throw inputCheckex;
            }
            //問合せNo341で追加
            editflg = true;
			// ▼2021.10.08 No.307 対応で変更
            // 希望路線、希望駅を登録する
			Map<String, DesiredTrainRoute__c> saveCondTrainRouteMap = saveDesiredTrainRouteDesiredStation();

            // 問合せ415で追加　希望学区、希望学校を登録する
			Map<String, DesiredSchoolArea__c> saveCondSchoolAreaMap = saveDesiredSchoolAreaDesiredSchool();
			// ▲2021.10.08 No.307 対応で変更
            
            // 取引先の保存
			saveAccount(saveCondTrainRouteMap, saveCondSchoolAreaMap);

			// ▼2021.10.08 No.307 対応で追加
			// お客様物件条件の保存
			saveAccountPropertyConditions(saveCondTrainRouteMap, saveCondSchoolAreaMap);
			// ▲2021.10.08 No.307 対応で追加

            //▼問合せNo0531で変更
            // 新規登録以外
            if (!newflg){
                isInsertFlg = False;
                // 一度全取得   
                setCustomersDate();
            }
            //▲問合せNo0531で変更
        }catch(Exception e){
            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
            isInsertFlg = true;
        }
    }   

    /**
     * 取引先の情報を保存する。
	 * @param Map<String, DesiredTrainRoute__c> saveCondTrainRouteMap 保存対象希望路線
	 * @param Map<String, DesiredSchoolArea__c> saveCondSchoolAreaMap 保存対象学区
	 * @return void
     */
	private void saveAccount(Map<String, DesiredTrainRoute__c> saveCondTrainRouteMap, Map<String, DesiredSchoolArea__c> saveCondSchoolAreaMap ) {
        // 保存処理
        Account saveDate = new Account();

        if (this.accountId != null) {
            // 更新により取引先IDをセット
            saveDate.Id = this.screenAccountRecord.Id;
        }else{
            // 新規は顧客のレコードタイプをセットする。
            saveDate.RecordTypeId =  CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_CUSTOMER);
        }
        
        saveDate.LastName__c = this.screenAccountRecord.LastName;     // 取引先.姓  
        saveDate.FirstName__c = this.screenAccountRecord.FirstName;   // 取引先.名  
        saveDate.Name  =  this.screenAccountRecord.LastName + this.screenAccountRecord.FirstName;  // 取引先.取引先名
        saveDate.LastNameKana__c = this.screenAccountRecord.LastNameKana;    // 取引先.姓（カナ）
        saveDate.FirstNameKana__c = this.screenAccountRecord.FirstNameKana;  // 取引先.名（カナ）
        saveDate.NameKana__c  =  this.screenAccountRecord.LastNameKana + this.screenAccountRecord.FirstNameKana;  // 取引先.取引先名（カナ）

        saveDate.Sex__c  =  this.screenAccountRecord.Sex;  // 取引先.性別
        saveDate.Birthdate__c  = this.screenAccountRecord.Birthdate;  // 取引先.生年月日
        saveDate.PostalCode__c  =  this.screenAccountRecord.PostalCode;  // 取引先.郵便番号
        saveDate.State__c  =  this.screenAccountRecord.State;  // 取引先.都道府県
        saveDate.City__c  =  this.screenAccountRecord.City;  // 取引先.住所１（市区町村）
        saveDate.Street__c  = this.screenAccountRecord.Street;  // 取引先.住所２（番地）
        saveDate.Situation__c  = this.screenAccountRecord.Situation;  // 問合せNo341で追加 取引先.状況
        if(!contractTypeFlg){
            // 法人のみ登録
            saveDate.CompanyName__c  =  this.screenAccountRecord.CompanyName;  // 取引先.会社名
            saveDate.CompanyNameKana__c  =  this.screenAccountRecord.CompanyNameKana;  // 取引先.会社名（カナ）
            saveDate.CompanyPostalCode__c  =  this.screenAccountRecord.CompanyPostalCode;  // 取引先.会社 郵便番号
            saveDate.CompanyState__c = this.screenAccountRecord.CompanyState;           // 取引先.会社 都道府県
            saveDate.CompanyCity__c  =  this.screenAccountRecord.CompanyCity;  // 取引先.会社 住所１
            saveDate.CompanyStreet__c  =  this.screenAccountRecord.CompanyStreet;  // 取引先.会社 住所２
            saveDate.CompanyIndustries__c  =  this.screenAccountRecord.CompanyIndustries;  // 取引先.会社 業種
            saveDate.CorporationRepresentative__c  =  this.screenAccountRecord.CorporationRepresentative;  // 取引先.担当者（法人用）
            saveDate.Department__c  =  this.screenAccountRecord.Department;  // 取引先.所属部署
            saveDate.Post__c  =  this.screenAccountRecord.Post;  // 取引先.役職
        }
        saveDate.Comment__c  =  this.screenAccountRecord.Comment;  // 取引先.コメント
        saveDate.Phone  =  this.screenAccountRecord.Phone;   // 取引先.電話番号
        saveDate.Phone2__c  =  this.screenAccountRecord.Phone2;  // 取引先.電話番号２
        saveDate.Phone3__c  =  this.screenAccountRecord.Phone3;  // 取引先.電話番号３
        saveDate.Email__c  =  this.screenAccountRecord.Email;  // 取引先.メール
        saveDate.Email2__c  =  this.screenAccountRecord.Email2;  // 取引先.メール２
        saveDate.Email3__c  =  this.screenAccountRecord.Email3;  // 取引先.メール３
        if(contractTypeFlg){
            // 個人のみの登録
            saveDate.Affiliation__c  =  this.screenAccountRecord.Affiliation;  // 取引先.勤務先/学校
            saveDate.AffiliationPhone__c  =  this.screenAccountRecord.AffiliationPhone;           // 勤務先/学校 電話番号
            saveDate.AffiliationPostalCode__c  =  this.screenAccountRecord.AffiliationPostalCode;      // 勤務先/学校 郵便番号
            saveDate.AffiliationState__c  =  this.screenAccountRecord.AffiliationState;           // 勤務先/学校 都道府県
            saveDate.AffiliationCity__c  =  this.screenAccountRecord.AffiliationCity;            // 勤務先/学校 住所１（市区町村）
            saveDate.AffiliationStreet__c  =  this.screenAccountRecord.AffiliationStreet;          // 勤務先/学校 住所２（番地）
            // saveDate.IsMergeCompletedFlag__c  =  this.screenAccountRecord.IsMergeCompletedFlag; // 取引先.名寄せ完了フラグ
        }
        saveDate.HomePhone__c = this.screenAccountRecord.HomePhone;  // 取引先.自宅TEL      
        saveDate.Fax  =  this.screenAccountRecord.Fax;  // 取引先.Fax
        
        saveDate.AccountIndustry__c = this.screenAccountRecord.AccountIndustry; // 取引先.業種（個人）
        saveDate.JobType__c  =  this.screenAccountRecord.JobType;  // 取引先.職種
        saveDate.VisitsDate__c  = this.screenAccountRecord.VisitsDate;  // 取引先.来店日
        saveDate.VisitsTrigger__c  =  this.screenAccountRecord.VisitsTrigger;  // 取引先.来店のきっかけ
        saveDate.PortalSite__c  =  this.screenAccountRecord.PortalSite;  // 取引先.ポータルサイト
        saveDate.SiteView__c  =  this.screenAccountRecord.SiteView;  // 取引先.事前にネット
        saveDate.Introducer__c  =  this.screenAccountRecord.Introducer;  // 取引先.紹介者
        saveDate.Dissatisfaction__c  =  this.screenAccountRecord.Dissatisfaction;  // 取引先.不満理由
        saveDate.ContractType__c  =  this.screenAccountRecord.ContractType;  // 取引先.契約形態
        saveDate.ProxyCompanyName__c  =  this.screenAccountRecord.ProxyCompanyName;  // 取引先.代理会社名
        if(!string.isBlank(this.screenAccountRecord.ProxyCompanyName)){
            saveDate.IsProxyCompany__c  ='有';  // 取引先.代理会社有無
        }else{
            saveDate.IsProxyCompany__c  ='無';
        }
        
        saveDate.HomeMovingDate__c  = this.screenAccountRecord.HomeMovingDate;  // 取引先.引越時期（日付）までに
        saveDate.TenantCount__c  =  CommonUtil.stringToDecimal(this.screenAccountRecord.TenantCount);  // 取引先.入居人数

		// ▼2021.10.08 No.307 対応で表示用物件条件を使用するように変更
		for(screenPropertyConditions targetCond: this.screenPropertyConditionsMap.values()){
			if(targetCond.accountFlg == false){
				//取引先でない物件条件をスキップ
				continue;
			}
			saveDate.PropertyConditionsName__c = targetCond.Name; // 取引先.物件条件名
			saveDate.DesiredArea__c  =  targetCond.DesiredArea;  // 取引先.希望地域
		
			if(saveCondTrainRouteMap.containsKey(targetCond.Name + '1')){
				saveDate.DesiredTrainRoute1__c = saveCondTrainRouteMap.get(targetCond.Name + '1').id;	// 取引先.希望路線１
			}
			if(saveCondTrainRouteMap.containsKey(targetCond.Name + '2')){
				saveDate.DesiredTrainRoute2__c = saveCondTrainRouteMap.get(targetCond.Name + '2').id;	// 取引先.希望路線２
			}
			if(saveCondTrainRouteMap.containsKey(targetCond.Name + '3')){
				saveDate.DesiredTrainRoute3__c = saveCondTrainRouteMap.get(targetCond.Name + '3').id;	// 取引先.希望路線３
			}
			if(String.valueOf(targetCond.juniorHighSchoolArea) != null){
				saveDate.DesiredJuniorHighSchoolArea__c = saveCondSchoolAreaMap.get(targetCond.Name + 'junior').Id;		// 取引先.中学校希望学区（エリア）
			}
			if(String.valueOf(targetCond.elementarySchoolArea) != null){
				saveDate.DesiredElementarySchoolArea__c = saveCondSchoolAreaMap.get(targetCond.Name + 'element').Id;	// 取引先.小学校希望学区（エリア）
			}

			saveDate.WalkingTime__c  =  targetCond.WalkingTime;  // 取引先.駅までの徒歩（分）
			saveDate.IsOneRoom__c  =  targetCond.IsOneRoom;  // 取引先.ワンルーム
			saveDate.Is1K__c  =  targetCond.Is1K;  // 取引先.1K
			saveDate.Is1DK__c  =  targetCond.Is1DK;  // 取引先.1DK
			saveDate.Is1LDK1SLDK__c  =  targetCond.Is1LDK1SLDK;  // 取引先.1LDK/SLDK
			saveDate.Is2K2DK__c  =  targetCond.Is2K2DK;  // 取引先.2K/DK
			saveDate.Is2LDK2SLDK__c  =  targetCond.Is2LDK2SLDK;  // 取引先.2LDK/SLDK
			saveDate.Is3K3DK__c  =  targetCond.Is3K3DK;  // 取引先.3K/DK
			saveDate.Is3LDK3SLDK__c  =  targetCond.Is3LDK3SLDK;  // 取引先.3LDK/SLDK
			saveDate.Is4K4DK4LDKFrom__c  =  targetCond.Is4K4DK4LDKFrom;  // 取引先.4K/DK/LDK~
			saveDate.IsWooden__c  =  targetCond.IsWooden;  // 取引先.木造
			saveDate.IsLightweightSteel__c  =  targetCond.IsLightweightSteel;  // 取引先.軽量鉄骨
			saveDate.IsSteel__c  =  targetCond.IsSteel;  // 取引先.鉄骨造
			saveDate.IsRC__c  =  targetCond.IsRC;  // 取引先.RC
			saveDate.IsSRC__c  =  targetCond.IsSRC;  // 取引先.SRC
			saveDate.IsNorth__c  =  targetCond.IsNorth;  // 取引先.北
			saveDate.IsNorthEast__c  =  targetCond.IsNorthEast;  // 取引先.北東
			saveDate.IsEast__c  =  targetCond.IsEast;  // 取引先.東
			saveDate.IsSouthEast__c  =  targetCond.IsSouthEast;  // 取引先.南東
			saveDate.IsSouth__c  =  targetCond.IsSouth;  // 取引先.南
			saveDate.IsSouthWest__c  =  targetCond.IsSouthWest;  // 取引先.南西
			saveDate.IsWest__c  =  targetCond.IsWest;  // 取引先.西
			saveDate.IsNorthWest__c  =  targetCond.IsNorthWest;  // 取引先.北西
			saveDate.IsNonDeposit__c  =  targetCond.IsNonDeposit;  // 取引先.敷金/保証金なし
			saveDate.IsNonKeyMoney__c  =  targetCond.IsNonKeyMoney;  // 取引先.礼金なし
			saveDate.IsNonCleaningFee__c  =  targetCond.IsNonCleaningFee;  // 取引先.定額修繕費なし
			saveDate.IsNonRenewalFee__c  =  targetCond.IsNonRenewalFee;  // 取引先.更新料なし
			saveDate.RentFeeFrom__c  = CommonUtil.stringToDecimal(targetCond.RentFeeFrom);  // 取引先.希望賃料（下限）
			saveDate.RentFeeTo__c  = CommonUtil.stringToDecimal(targetCond.RentFeeTo);  // 取引先.希望賃料（上限）
			saveDate.OccupancyAreaLowerLimit__c  =  targetCond.OccupancyAreaLowerLimit;  // 取引先.占有面積（下限）
			saveDate.OccupancyAreaUpperLimit__c  =  targetCond.OccupancyAreaUpperLimit;  // 取引先.占有面積（上限）
			saveDate.BuildingAge__c  =  targetCond.BuildingAge;  // 取引先.築年数
			saveDate.IsIncludeManagementFee__c  =  targetCond.IsIncludeManagementFee;  // 取引先.管理費込み
			saveDate.IsIncludeParkingFee__c  =  targetCond.IsIncludeParkingFee;  // 取引先.駐車場代込み
			saveDate.CarCount__c  = CommonUtil.stringToDecimal( targetCond.CarCount);  // 取引先.台数
			saveDate.ParkingFeeLimit__c  = CommonUtil.stringToDecimal(targetCond.ParkingFeeLimit);  // 取引先.1台当たりの料金上限
			if(CommonUtil.stringToDecimal(targetCond.ParkingFeeLimit) > 0){
				saveDate.Parking__c  =  '有';  // 取引先.駐車場
			}else{
				saveDate.Parking__c  =  '無';
			}

			saveDate.IsDetachedHouse__c  =  targetCond.IsDetachedHouse;  // 取引先.戸建て
			saveDate.IsMaisonette__c  =  targetCond.IsMaisonette;  // 取引先.メゾネット
			saveDate.IsLoft__c  =  targetCond.IsLoft;  // 取引先.ロフト
			saveDate.IsDesigners__c  =  targetCond.IsDesigners;  // 取引先.デザイナーズ
			saveDate.IsRenovation__c  =  targetCond.IsRenovation;  // 取引先.リノベーション
			saveDate.IsCondominiumRental__c  =  targetCond.IsCondominiumRental;  // 取引先.分譲賃貸
			saveDate.IsAllWestern__c  =  targetCond.IsAllWestern;  // 取引先.オール洋間
			saveDate.IsFirstFloor__c  =  targetCond.IsFirstFloor;  // 取引先.1階
			saveDate.IsSecondFloorOver__c  =  targetCond.IsSecondFloorOver;  // 取引先.2階以上
			saveDate.IsTopFloor__c  =  targetCond.IsTopFloor;  // 取引先.最上階
			saveDate.IsCornerRoom__c  =  targetCond.IsCornerRoom;  // 取引先.角部屋
			saveDate.IsBalcony__c  =  targetCond.IsBalcony;  // 取引先.バルコニー
			saveDate.IsRoofBalcony__c  =  targetCond.IsRoofBalcony;  // 取引先.ルーフバルコニー
			saveDate.IsPrivateGarden__c  =  targetCond.IsPrivateGarden;  // 取引先.専用庭
			saveDate.IsParking__c  =  targetCond.IsParking;  // 取引先.駐車場空きあり
			saveDate.IsInSiteParking__c  =  targetCond.IsInSiteParking;  // 取引先.敷地内駐車場
			saveDate.IsPluralCarParking__c  =  targetCond.IsPluralCarParking;  // 取引先.駐車場2台可
			saveDate.IsBuiltInGarage__c  =  targetCond.IsBuiltInGarage;  // 取引先.ビルトインガレージ
			saveDate.IsCarport__c  =  targetCond.IsCarport;  // 取引先.カーポート
			saveDate.IsBicycleParking__c  =  targetCond.IsBicycleParking;  // 取引先.駐輪場
			saveDate.IsBikeStorage__c  =  targetCond.IsBikeStorage;  // 取引先.バイク可
			saveDate.IsSmallBike__c  =  targetCond.IsSmallBike;  // 取引先.小型バイク
			saveDate.IsMediumBike__c  =  targetCond.IsMediumBike;  // 取引先.中型バイク
			saveDate.IsLargeBike__c  =  targetCond.IsLargeBike;  // 取引先.大型バイク
			saveDate.IsElevator__c  =  targetCond.IsElevator;  // 取引先.エレベーター
			saveDate.IsDeliveryBox__c  =  targetCond.IsDeliveryBox;  // 取引先.宅配ボックス
			saveDate.IsCounterKitchen__c  =  targetCond.IsCounterKitchen;  // 取引先.カウンターキッチン
			saveDate.IsSystemKitchen__c  =  targetCond.IsSystemKitchen;  // 取引先.システムキッチン
			saveDate.IsGasStove__c  =  targetCond.IsGasStove;  // 取引先.ガスコンロ
			saveDate.IsElectricStove__c  =  targetCond.IsElectricStove;  // 取引先.電気コンロ
			saveDate.IsInductionHeating__c  =  targetCond.IsInductionHeating;  // 取引先.IHコンロ
			saveDate.IsTwoGasStove__c  =  targetCond.IsTwoGasStove;  // 取引先.コンロ2口
			saveDate.IsMoreGasStove__c  =  targetCond.IsMoreGasStove;  // 取引先.コンロ3口以上
			saveDate.IsSepalateBathAndRestroom__c  =  targetCond.IsSepalateBathAndRestroom;  // 取引先.バス・トイレ別
			saveDate.IsAditionalBoiling__c  =  targetCond.IsAditionalBoiling;  // 取引先.追焚機能
			saveDate.IsDehumidifierForBathroom__c  =  targetCond.IsDehumidifierForBathroom;  // 取引先.浴室乾燥機
			saveDate.IsWashlet__c  =  targetCond.IsWashlet;  // 取引先.温水洗浄便座
			saveDate.IsShowerWashBasin__c  =  targetCond.IsShowerWashBasin;  // 取引先.シャワー付き洗面台
			saveDate.IsRegalLavatory__c  =  targetCond.IsRegalLavatory;  // 取引先.洗面所独立
			saveDate.IsInnerLandry__c  =  targetCond.IsInnerLandry;  // 取引先.室内洗濯機置場
			saveDate.IsTownGas__c  =  targetCond.IsTownGas;  // 取引先.都市ガス
			saveDate.IsPropaneGas__c  =  targetCond.IsPropaneGas;  // 取引先.プロパンガス
			saveDate.IsAllElectric__c  =  targetCond.IsAllElectric;  // 取引先.オール電化
			saveDate.IsAirConditioner__c  =  targetCond.IsAirConditioner;  // 取引先.エアコン
			saveDate.IsFloorHeating__c  =  targetCond.IsFloorHeating;   // 取引先.床暖房
			saveDate.IsShoesBox__c  =  targetCond.IsShoesBox;   // 取引先.シューズボックス
			saveDate.IsShoeCloak__c  =  targetCond.IsShoeCloak;  // 取引先.シューズクローク
			saveDate.IsWalkInCloset__c  =  targetCond.IsWalkInCloset;   // 取引先.ウォークインクローゼット
			saveDate.IsTrunkRoom__c  =  targetCond.IsTrunkRoom;  // 取引先.トランクルーム
			saveDate.IsBSAntenna__c  =  targetCond.IsBSAntenna;  // 取引先.BSアンテナ
			saveDate.IsCSAntenna__c  =  targetCond.IsCSAntenna;  // 取引先.CSアンテナ
			saveDate.IsCATV__c  =  targetCond.IsCATV;  // 取引先.CATV
			saveDate.IsInternetFree__c  =  targetCond.IsInternetFree;   // 取引先.ネット使用料無料
			saveDate.IsMonitorIntercom__c  =  targetCond.IsMonitorIntercom;  // 取引先.モニタ付インターホン
			saveDate.IsAutoLock__c  =  targetCond.IsAutoLock;  // 取引先.オートロック
			saveDate.IsFurniture__c  =  targetCond.IsFurniture;  // 取引先.家具付き
			saveDate.IsHomeAppliance__c  =  targetCond.IsHomeAppliance;  // 取引先.家電付き
			saveDate.IsNoGuarantor__c  =  targetCond.IsNoGuarantor;  // 取引先.保証人不要
			saveDate.IsNonGuaranteeidCompany__c  =  targetCond.IsNonGuaranteeidCompany;  // 取引先.保証会社不要
			saveDate.IsMusicalInstruments__c  =  targetCond.IsMusicalInstruments;  // 取引先.楽器相談可
			saveDate.IsForeigner__c  =  targetCond.IsForeigner;  // 取引先.外国人契約可
			saveDate.IsWelfareAvailable__c  =  targetCond.IsWelfareAvailable;  // 取引先.生活保護契約可
			saveDate.IsOfficeAvailable__c  =  targetCond.IsOfficeAvailable;  // 取引先.事務所利用可
			saveDate.IsPet__c  =  targetCond.IsPet;  // 取引先.ペット可
			saveDate.IsSmallPet__c  =  targetCond.IsSmallPet;  // 取引先.ペット(小型犬)
			saveDate.IsMiddlePet__c  =  targetCond.IsMiddlePet;  // 取引先.ペット(中型犬)
			saveDate.IsLargePet__c  =  targetCond.IsLargePet;  // 取引先.ペット(大型犬)
			saveDate.IsCat__c  =  targetCond.IsCat;  // 取引先.ペット(猫)
			saveDate.IsOtherPet__c  =  targetCond.IsOtherPet;  // 取引先.ペット(その他)
			saveDate.IsTwoTenant__c  =  targetCond.IsTwoTenant;  // 取引先.2人入居可
			saveDate.IsRoomShare__c  =  targetCond.IsRoomShare;  // 取引先.ルームシェア可
			saveDate.IsIppambutsu__c  =  targetCond.IsIppambutsu;  // 取引先.一般物
			saveDate.IsElderly__c  =  targetCond.IsElderly;  // 取引先.高齢者歓迎
			saveDate.IsWoman__c  =  targetCond.IsWoman;  // 取引先.女性限定
			saveDate.IsStudent__c  =  targetCond.IsStudent;  // 取引先.学生限定マンション
		}
		// ▲2021.10.08 No.307 対応で表示用物件条件を使用するように変更

        //引越理由設定
        List<String> homeMovingReasonCheck = new List<String>();
        for(String homeMovingReasonValue : this.homeMovingReasonValueList ){//全選択値を取得
            if(this.homeMovingReasonCheckList.get(homeMovingReasonValue)){
                homeMovingReasonCheck.add(homeMovingReasonValue);//チェックされていた場合追加
            }
        }
        this.screenAccountRecord.homeMovingReason = String.join(homeMovingReasonCheck, ';');//「;」区切りの文字列にして複数選択リストの値にする
        saveDate.HomeMovingReason__c = this.screenAccountRecord.homeMovingReason;
        List<String> homeMovingSeasonCheck = new List<String>();
        for(String homeMovingSeasonValue : this.HomeMovingSeasonValueList ){//全選択値を取得
            if(this.HomeMovingSeasonCheckList.get(homeMovingSeasonValue)){
                homeMovingSeasonCheck.add(homeMovingSeasonValue);//チェックされていた場合追加
            }
        }
        this.screenAccountRecord.HomeMovingSeason = String.join(homeMovingSeasonCheck, ';');//「;」区切りの文字列にして複数選択リストの値にする
        saveDate.HomeMovingSeason__c  =  this.screenAccountRecord.HomeMovingSeason;  // 取引先.引越時期

        // 名寄せ (2020.09.03 名寄せ不要フラグ更新処理も実施)
        saveDate.IsMergeCompletedFlag__c = setTargetRecordIsMergeCompletedFlag(saveDate);// 保存する取引先に名寄せフラグ設定

        saveDate.CompanyEstablishmentYear__c = this.screenAccountRecord.CompanyEstablishmentYear;       // 取引先.設立(年)
        saveDate.CompanyEstablishmentMonth__c = this.screenAccountRecord.CompanyEstablishmentMonth;     // 取引先.設立(月)
        saveDate.CompanyCapital__c =CommonUtil.stringToDecimal(this.screenAccountRecord.CompanyCapital);// 取引先.資本金
        saveDate.CompanyPhone__c = this.screenAccountRecord.CompanyPhone ;                                   // 取引先.法人電話番号
        saveDate.CorporationRepresentativePhone__c = this.screenAccountRecord.CorporationRepresentativePhone;// 取引先.担当者電話番号            
        
		// ▼2021.10.08 No.307 対応で削除（移動）　学区

        // 保存処理
        SecureDML.secureUpsert(saveDate);

        this.accountId = saveDate.Id;

		//▼ 2022.01.21 No.307 対応で追加　選択中の物件条件が取引先の場合、選択リストで選択中の物件条件を更新
		if(currentScreenPropertyCondition.Name.equals(saveDate.Name)){
			selectCondName = saveDate.Id;
		}
		//▲ 2022.01.21 No.307 対応で追加
    }

	// ▼2021.10.08 No.307 対応で追加
	/**
	 * お客様物件条件の情報を保存する。
	 * @param Map<String, DesiredTrainRoute__c> saveCondTrainRouteMap 保存対象希望路線
	 * @param Map<String, DesiredSchoolArea__c> saveCondSchoolAreaMap 保存対象学区
	 * @return void
	 */
	private void saveAccountPropertyConditions(Map<String, DesiredTrainRoute__c> saveCondTrainRouteMap, Map<String, DesiredSchoolArea__c> saveCondSchoolAreaMap ){
		// 保存用
		List<AccountPropertyConditions__c> saveCondList = new List<AccountPropertyConditions__c>(); // 保存用　お客様物件条件
		List<AccountPropertyConditions__c> delCondList = new List<AccountPropertyConditions__c>(); // 削除用　お客様物件条件

		for(screenPropertyConditions targetCond: this.screenPropertyConditionsMap.values()){
			if(targetCond.accountFlg){
				//取引先の場合スキップ
				continue;
			}
			AccountPropertyConditions__c saveCond = new AccountPropertyConditions__c(); // お客様物件条件の保存用変数
			saveCond.Name = targetCond.Name;

			String parking = CommonConst.VISITCARD_PARKING_NO;//駐車場：無
			// deleteFlgがfalseのデータのみを登録、更新する。
			if(!targetCond.deleteFlg){
				// お客様物件条件が既存の場合はIDをセットする。
				if(targetCond.dispCondId != null){
					saveCond.id = targetCond.dispCondId;
				}

				// 取引先Idを設定する。
				saveCond.Account__c = this.accountId;

				//台数 が1以上あった場合:有
				if(CommonUtil.stringToDecimal(targetCond.carCount) > 0){
					parking = CommonConst.VISITCARD_PARKING_EXISTS;
				}

				saveCond.CarCount__c = CommonUtil.stringToDecimal(targetCond.carCount) ;//台数 
				saveCond.Parking__c = parking ; //駐車場
				saveCond.ParkingFeeLimit__c = CommonUtil.stringToDecimal(targetCond.parkingFeeLimit) ;//1台当たりの料金上限
				
				saveCond.DesiredArea__c = targetCond.desiredArea ;//希望地域 

				saveCond.WalkingTime__c = targetCond.walkingTime ;//徒歩 
				saveCond.IsOneRoom__c = targetCond.isOneRoom ;//ワンルーム 
				saveCond.Is1K__c = targetCond.is1K ;//1K 
				saveCond.Is1DK__c = targetCond.is1DK ;//1DK 
				saveCond.Is1LDK1SLDK__c = targetCond.is1LDK1SLDK ;//1LDK/SLDK 
				saveCond.Is2K2DK__c = targetCond.is2K2DK ;//2K/DK 
				saveCond.Is2LDK2SLDK__c = targetCond.is2LDK2SLDK ;//2LDK/SLDK 
				saveCond.Is3K3DK__c = targetCond.is3K3DK ;//3K/DK 
				saveCond.Is3LDK3SLDK__c = targetCond.is3LDK3SLDK ;//3LDK/SLDK 
				saveCond.Is4K4DK4LDKFrom__c = targetCond.is4K4DK4LDKFrom ;//4K/DK/LDK~ 
				saveCond.IsWooden__c = targetCond.isWooden ;//木造 
				saveCond.IsLightweightSteel__c = targetCond.isLightweightSteel ;//軽量鉄骨 
				saveCond.IsSteel__c = targetCond.isSteel ;//鉄骨造 
				saveCond.IsRC__c = targetCond.isRC ;//RC 
				saveCond.IsSRC__c = targetCond.isSRC ;//SRC 
				saveCond.IsNorth__c = targetCond.isNorth ;//北 
				saveCond.IsNorthEast__c = targetCond.isNorthEast ;//北東 
				saveCond.IsEast__c = targetCond.isEast ;//東 
				saveCond.IsSouthEast__c = targetCond.isSouthEast ;//南東 
				saveCond.IsSouth__c = targetCond.isSouth ;//南 
				saveCond.IsSouthWest__c = targetCond.isSouthWest ;//南西 
				saveCond.IsWest__c = targetCond.isWest ;//西 
				saveCond.IsNorthWest__c = targetCond.isNorthWest ;//北西 
				saveCond.IsNonDeposit__c = targetCond.isNonDeposit ;//敷金/保証金なし 
				saveCond.IsNonKeyMoney__c = targetCond.isNonKeyMoney ;//礼金なし 
				saveCond.IsNonCleaningFee__c = targetCond.isNonCleaningFee ;//定額修繕費なし 
				saveCond.IsNonRenewalFee__c = targetCond.isNonRenewalFee ;//更新料なし 

				saveCond.RentFeeFrom__c = CommonUtil.stringToDecimal(targetCond.rentFeeFrom) ;//賃料から 
				saveCond.RentFeeTo__c = CommonUtil.stringToDecimal(targetCond.rentFeeTo) ;//賃料まで 

				saveCond.IsIncludeManagementFee__c = targetCond.isIncludeManagementFee ;//管理費込み 
				saveCond.IsIncludeParkingFee__c = targetCond.isIncludeParkingFee ;//駐車場代込み 
				saveCond.OccupancyAreaLowerLimit__c = targetCond.occupancyAreaLowerLimit ;//占有面積（下限） 
				saveCond.OccupancyAreaUpperLimit__c = targetCond.occupancyAreaUpperLimit ;//占有面積（上限） 
				saveCond.BuildingAge__c = targetCond.buildingAge ;//築年数
				saveCond.IsDetachedHouse__c = targetCond.isDetachedHouse ;//戸建て 
				saveCond.IsMaisonette__c = targetCond.isMaisonette ;//メゾネット 
				saveCond.IsLoft__c = targetCond.isLoft ;//ロフト 
				saveCond.IsDesigners__c = targetCond.isDesigners ;//デザイナーズ 
				saveCond.IsRenovation__c = targetCond.isRenovation ;//リノベーション 
				saveCond.IsAllWestern__c = targetCond.isAllWestern ;//オール洋間 
				saveCond.IsCondominiumRental__c = targetCond.isCondominiumRental ;//分譲賃貸 
				saveCond.IsFirstFloor__c = targetCond.isFirstFloor ;//1階 
				saveCond.IsSecondFloorOver__c = targetCond.isSecondFloorOver ;//2階以上 
				saveCond.IsTopFloor__c = targetCond.isTopFloor ;//最上階 
				saveCond.IsCornerRoom__c = targetCond.isCornerRoom ;//角部屋 
				saveCond.IsBalcony__c = targetCond.isBalcony ;//バルコニー 
				saveCond.IsRoofBalcony__c = targetCond.isRoofBalcony ;//ルーフバルコニー 
				saveCond.IsPrivateGarden__c = targetCond.isPrivateGarden ;//専用庭 
				saveCond.IsParking__c = targetCond.isParking ;//駐車場空きあり 
				saveCond.IsInSiteParking__c = targetCond.isInSiteParking ;//敷地内駐車場 
				saveCond.IsPluralCarParking__c = targetCond.isPluralCarParking ;//駐車場2台可 
				saveCond.IsBuiltInGarage__c = targetCond.isBuiltInGarage ;//ビルトインガレージ 
				saveCond.IsCarport__c = targetCond.isCarport ;//カーポート 
				saveCond.IsBicycleParking__c = targetCond.isBicycleParking ;//駐輪場 
				saveCond.IsBikeStorage__c = targetCond.isBikeStorage ;//バイク可 
				saveCond.IsSmallBike__c = targetCond.isSmallBike ;//小型バイク 
				saveCond.IsMediumBike__c = targetCond.isMediumBike ;//中型バイク 
				saveCond.IsLargeBike__c = targetCond.isLargeBike ;//大型バイク 
				saveCond.IsElevator__c = targetCond.isElevator ;//エレベーター 
				saveCond.IsDeliveryBox__c = targetCond.isDeliveryBox ;//宅配ボックス 
				saveCond.IsCounterKitchen__c = targetCond.isCounterKitchen ;//カウンターキッチン 
				saveCond.IsSystemKitchen__c = targetCond.isSystemKitchen ;//システムキッチン 
				saveCond.IsGasStove__c = targetCond.isGasStove ;//ガスコンロ 
				saveCond.IsElectricStove__c = targetCond.isElectricStove ;//電気コンロ 
				saveCond.IsInductionHeating__c = targetCond.isInductionHeating ;//IHコンロ 
				saveCond.IsTwoGasStove__c = targetCond.isTwoGasStove ;//コンロ2口 
				saveCond.IsMoreGasStove__c = targetCond.isMoreGasStove ;//コンロ3口以上 
				saveCond.IsSepalateBathAndRestroom__c = targetCond.isSepalateBathAndRestroom ;//バス・トイレ別 
				saveCond.IsAditionalBoiling__c = targetCond.isAditionalBoiling ;//追焚機能 
				saveCond.IsDehumidifierForBathroom__c = targetCond.isDehumidifierForBathroom ;//浴室乾燥機 
				saveCond.IsWashlet__c = targetCond.isWashlet ;//温水洗浄便座 
				saveCond.IsShowerWashBasin__c = targetCond.isShowerWashBasin ;//シャワー付き洗面台 
				saveCond.IsRegalLavatory__c = targetCond.isRegalLavatory ;//洗面所独立 
				saveCond.IsInnerLandry__c = targetCond.isInnerLandry ;//室内洗濯機置場 
				saveCond.IsTownGas__c = targetCond.isTownGas ;//都市ガス 
				saveCond.IsPropaneGas__c = targetCond.isPropaneGas ;//プロパンガス 
				saveCond.IsAllElectric__c = targetCond.isAllElectric ;//オール電化 
				saveCond.IsAirConditioner__c = targetCond.isAirConditioner ;//エアコン 
				saveCond.IsFloorHeating__c = targetCond.isFloorHeating ;//床暖房 
				saveCond.IsShoesBox__c = targetCond.isShoesBox ;//シューズボックス 
				saveCond.IsShoeCloak__c = targetCond.isShoeCloak ;//シューズクローク 
				saveCond.IsWalkInCloset__c = targetCond.isWalkInCloset ;//ウォークインクローゼット 
				saveCond.IsTrunkRoom__c = targetCond.isTrunkRoom ;//トランクルーム 
				saveCond.IsBSAntenna__c = targetCond.isBSAntenna ;//BSアンテナ 
				saveCond.IsCSAntenna__c = targetCond.isCSAntenna ;//CSアンテナ 
				saveCond.IsCATV__c = targetCond.isCATV ;//CATV 
				saveCond.IsInternetFree__c = targetCond.isInternetFree ;//ネット使用料無料 
				saveCond.IsMonitorIntercom__c = targetCond.isMonitorIntercom ;//モニター付きインターホン 
				saveCond.IsAutoLock__c = targetCond.isAutoLock ;//オートロック 
				saveCond.IsFurniture__c = targetCond.isFurniture ;//家具付き 
				saveCond.IsHomeAppliance__c = targetCond.isHomeAppliance ;//家電付き 
				saveCond.IsNoGuarantor__c = targetCond.isNoGuarantor ;//保証人不要 
				saveCond.IsNonGuaranteeidCompany__c = targetCond.isNonGuaranteeidCompany ;//保証会社不要 
				saveCond.IsMusicalInstruments__c = targetCond.isMusicalInstruments ;//楽器相談可 
				saveCond.IsForeigner__c = targetCond.isForeigner ;//外国人契約可 
				saveCond.IsOfficeAvailable__c = targetCond.isOfficeAvailable ;//事務所利用可 
				saveCond.IsWelfareAvailable__c = targetCond.isWelfareAvailable ;//生活保護契約可 
				saveCond.IsPet__c = targetCond.isPet ;//ペット可 
				saveCond.IsLargePet__c = targetCond.isLargePet ;//ペット(大型犬) 
				saveCond.IsMiddlePet__c = targetCond.isMiddlePet ;//ペット(中型犬) 
				saveCond.IsSmallPet__c = targetCond.isSmallPet ;//ペット(小型犬) 
				saveCond.IsCat__c = targetCond.isCat ;//ペット(猫) 
				saveCond.IsOtherPet__c = targetCond.isOtherPet ;//ペット(その他) 
				saveCond.IsTwoTenant__c = targetCond.isTwoTenant ;//2人入居可 
				saveCond.IsRoomShare__c = targetCond.isRoomShare ;//ルームシェア可 
				saveCond.IsIppambutsu__c = targetCond.isIppambutsu ;//一般物 
				saveCond.IsElderly__c = targetCond.isElderly ;//高齢者歓迎 
				saveCond.IsWoman__c = targetCond.isWoman ;//女性限定 
				saveCond.IsStudent__c = targetCond.isStudent ;//学生限定マンション 

				saveCondList.add(saveCond); // お客様物件条件登録用リストに追加

			} else{ 
				// お客様物件条件が既存の場合はIDをセットする。
				if(targetCond.dispCondId != null){
					delCondList.add(new AccountPropertyConditions__c(id=targetCond.dispCondId));
				}
			}
		}

		// 希望路線、希望学区をセットする。
		Integer rowIndex = 0;
		for(screenPropertyConditions targetCond: this.screenPropertyConditionsMap.values()){
			if(targetCond.accountFlg){
				//取引先の場合スキップ
				continue;
			}
			if(targetCond.deleteFlg != true){
				if(saveCondTrainRouteMap.containsKey(targetCond.Name + '1')){
					saveCondList[rowIndex].DesiredTrainRoute1__c = saveCondTrainRouteMap.get(targetCond.Name + '1').id;//希望沿線１ 
				}
				if(saveCondTrainRouteMap.containsKey(targetCond.Name + '2')){
					saveCondList[rowIndex].DesiredTrainRoute2__c = saveCondTrainRouteMap.get(targetCond.Name + '2').id;//希望沿線２ 
				}
				if(saveCondTrainRouteMap.containsKey(targetCond.Name + '3')){
					saveCondList[rowIndex].DesiredTrainRoute3__c = saveCondTrainRouteMap.get(targetCond.Name + '3').id;//希望沿線３ 
				}
				if(String.valueOf(targetCond.juniorHighSchoolArea) != null){
					saveCondList[rowIndex].DesiredJuniorHighSchoolArea__c = saveCondSchoolAreaMap.get(targetCond.Name + 'junior').Id;//中学校希望学区（エリア）
				}
				if(String.valueOf(targetCond.elementarySchoolArea) != null){
					saveCondList[rowIndex].DesiredElementarySchoolArea__c = saveCondSchoolAreaMap.get(targetCond.Name + 'element').Id;//小学校希望学区（エリア）
				}
				rowIndex++;
			}
		}

		SecureDML.secureUpsert(saveCondList);//お客様物件条件更新、作成
		SecureDML.secureDelete(delCondList);// お客様物件条件　削除

		//▼ 2022.01.20 No.307 対応で追加　物件条件選択リストの選択中物件条件の値を更新する　
		for(AccountPropertyConditions__c saveCond: saveCondList){
			if(currentScreenPropertyCondition.Name.equals(saveCond.Name)){
				selectCondName = saveCond.Id;
			}
		}
		//▲ 2022.01.20 No.307 対応で追加　物件条件選択リストの選択中物件条件の値を更新する　
	}
	// ▲2021.10.08 No.307 対応で追加

	// ▼2021.10.08 No.307 対応で変更　複数のお客様物件条件オブジェクトに対応する希望路線、希望駅、希望学区、希望学校を保存するよう対応
	/**
	 *  希望路線と希望駅を保存する。
	 */
	private Map<String, DesiredTrainRoute__c> saveDesiredTrainRouteDesiredStation(){
		// ▼問合せ415で追加
		Map<String, DesiredTrainRoute__c> saveCondTrainRouteMap = new Map<String, DesiredTrainRoute__c>(); // お客様物件条件へ保存用 希望路線(Map)
		Map<Id, DesiredTrainRoute__c> deleteDesiredTrainRouteMap  = new Map<Id, DesiredTrainRoute__c>();//削除用 希望路線
		List<DesiredStation__c> saveCondStationList = new List<DesiredStation__c>();//お客様物件条件へ保存用 希望駅

		for(screenPropertyConditions targetCond: this.screenPropertyConditionsMap.values()){
			//希望路線を削除して、希望駅を初期化する
			if(String.valueOf(targetCond.desiredTrainRoute1) != null){
				deleteDesiredTrainRouteMap.put(targetCond.desiredTrainRoute1, new DesiredTrainRoute__c(Id = targetCond.desiredTrainRoute1));
			}
			if(String.valueOf(targetCond.desiredTrainRoute2) != null){
				deleteDesiredTrainRouteMap.put(targetCond.desiredTrainRoute2, new DesiredTrainRoute__c(Id = targetCond.desiredTrainRoute2));
			}
			if(String.valueOf(targetCond.desiredTrainRoute3) != null){
				deleteDesiredTrainRouteMap.put(targetCond.desiredTrainRoute3, new DesiredTrainRoute__c(Id = targetCond.desiredTrainRoute3));
			}

			//希望路線を新規に作成する
			if(String.valueOf(targetCond.trainRoute1) != null){
				DesiredTrainRoute__c tmptrainRoute1 = new DesiredTrainRoute__c(TrainRoute__c = targetCond.trainRoute1);
				saveCondTrainRouteMap.put(targetCond.Name + '1', tmptrainRoute1);
			}
			if(String.valueOf(targetCond.trainRoute2) != null){
				DesiredTrainRoute__c tmptrainRoute2 = new DesiredTrainRoute__c(TrainRoute__c = targetCond.trainRoute2);
				saveCondTrainRouteMap.put(targetCond.Name + '2', tmptrainRoute2);
			}
			if(String.valueOf(targetCond.trainRoute3) != null){
				DesiredTrainRoute__c tmptrainRoute3 = new DesiredTrainRoute__c(TrainRoute__c = targetCond.trainRoute3);
				saveCondTrainRouteMap.put(targetCond.Name + '3', tmptrainRoute3);
			}
		}

		//変更前希望路線削除
		if(!deleteDesiredTrainRouteMap.isEmpty()){
			SecureDML.secureDelete(deleteDesiredTrainRouteMap.values());//希望路線と希望駅を削除
		}

		SecureDML.secureUpsert(saveCondTrainRouteMap.values());//来店カード用 希望路線を作成
			
		//画面で選択された駅から、新規に希望路線に紐付けた希望駅を作成する
		for(screenPropertyConditions targetCond: this.screenPropertyConditionsMap.values()){
			if(String.valueOf(targetCond.trainRoute1) != null){
				for(Station__c desiredStation : targetCond.stations1){//選択された駅1から希望駅を設定
					saveCondStationList.add(new DesiredStation__c(DesiredTrainRoute__c = saveCondTrainRouteMap.get(targetCond.Name + '1').id, Station__c = desiredStation.Id));
				}
			}

			if(String.valueOf(targetCond.trainRoute2) != null){
				for(Station__c desiredStation : targetCond.stations2){//選択された駅2から希望駅を設定
					saveCondStationList.add(new DesiredStation__c(DesiredTrainRoute__c = saveCondTrainRouteMap.get(targetCond.Name + '2').id, Station__c = desiredStation.Id));
				}
			}
			
			if(String.valueOf(targetCond.trainRoute3) != null){
				for(Station__c desiredStation : targetCond.stations3){//選択された駅3から希望駅を設定
					saveCondStationList.add(new DesiredStation__c(DesiredTrainRoute__c = saveCondTrainRouteMap.get(targetCond.Name + '3').id, Station__c = desiredStation.Id));
				}
			}
		}
		SecureDML.secureUpsert(saveCondStationList);//お客様物件条件用 希望駅を作成

		return saveCondTrainRouteMap;
	}

    /**
     *  希望学区と希望学校を保存する。
     */
	private Map<String, DesiredSchoolArea__c> saveDesiredSchoolAreaDesiredSchool() {
		// ▼問合せ415で追加
		Map<String, DesiredSchoolArea__c> saveCondSchoolAreaMap = new Map<String, DesiredSchoolArea__c>();//お客様物件条件へ保存用　希望学区(Map)
		Map<Id, DesiredSchoolArea__c> deleteDesiredSchoolAreaMap  = new Map<Id, DesiredSchoolArea__c>();//お客様物件条件へ削除用　希望学区(Map)

		List<DesiredSchool__c> saveCondSchoolList = new List<DesiredSchool__c>();//お客様物件条件へ保存用　希望学校

		for(screenPropertyConditions targetCond: this.screenPropertyConditionsMap.values()){
			//希望学区を削除して、希望学校を初期化する
			// ▼2021.10.08 No.307 対応で削除　取引先（希望学区）来店カード（希望学区）
			if(String.valueOf(targetCond.AccountPropertyConditionsElementarySchoolArea) != null){//小学校希望学区
				deleteDesiredSchoolAreaMap.put(targetCond.AccountPropertyConditionsElementarySchoolArea, 
					new DesiredSchoolArea__c(Id = targetCond.AccountPropertyConditionsElementarySchoolArea));
			}
			if(String.valueOf(targetCond.AccountPropertyConditionsJuniorHighSchoolArea) != null){//中学校希望学区
				deleteDesiredSchoolAreaMap.put(targetCond.AccountPropertyConditionsJuniorHighSchoolArea,
					new DesiredSchoolArea__c(Id = targetCond.AccountPropertyConditionsJuniorHighSchoolArea));
			}

			//希望学区を新規に作成する
			if(String.valueOf(targetCond.juniorHighSchoolArea) != null){
				DesiredSchoolArea__c tmpSchoolArea = new DesiredSchoolArea__c(SchoolArea__c = targetCond.juniorHighSchoolArea);
				saveCondSchoolAreaMap.put(targetCond.Name + 'junior', tmpSchoolArea);
			}
			if(String.valueOf(targetCond.elementarySchoolArea) != null){
				DesiredSchoolArea__c tmpSchoolArea = new DesiredSchoolArea__c(SchoolArea__c = targetCond.elementarySchoolArea);
				saveCondSchoolAreaMap.put(targetCond.Name + 'element', tmpSchoolArea);
			}
		}

		// 変更前希望学区削除
		if(!deleteDesiredSchoolAreaMap.isEmpty()){
			SecureDML.secureDelete(deleteDesiredSchoolAreaMap.values());//希望学区と希望学校を削除
		}

		SecureDML.secureUpsert(saveCondSchoolAreaMap.values());//お客様物件条件用 希望学区を作成

		//画面で選択された学区から、新規に希望学区に紐付けた希望学校を作成する
		for(screenPropertyConditions targetCond: this.screenPropertyConditionsMap.values()){
			if(String.valueOf(targetCond.juniorHighSchoolArea) != null){
				for(School__c desiredSchool : targetCond.juniorHighSchoolList){//選択された中学校から希望学校を設定
					saveCondSchoolList.add(new DesiredSchool__c(DesiredSchoolArea__c = saveCondSchoolAreaMap.get(targetCond.Name + 'junior').Id, School__c = desiredSchool.Id));
				}
			}

			if(String.valueOf(targetCond.elementarySchoolArea) != null){
				for(School__c desiredSchool : targetCond.elementarySchoolList){//選択された小学校から希望学校を設定
					saveCondSchoolList.add(new DesiredSchool__c(DesiredSchoolArea__c = saveCondSchoolAreaMap.get(targetCond.Name + 'element').Id, School__c = desiredSchool.Id));
				}
			}
		}
		SecureDML.secureUpsert(saveCondSchoolList);//お客様物件条件用　希望学校を作成

		return saveCondSchoolAreaMap;
	}
	// ▲2021.10.08 No.307 対応で変更　複数のお客様物件条件オブジェクトに対応する希望路線、希望駅、希望学区、希望学校を保存するよう対応

	// ▼2021.10.08 No.307 対応で追加
	// 物件条件追加ボタン押下時の処理
	public void addPropertyCond(){
		hasErrorMessage = false;
		BusinessLogicException inputCheckex = new BusinessLogicException();
		try{
			// 入力チェック
			inputCheckex = inputAccountPropertyConditionsCheck(null);
			// エラーあり
			if(inputCheckex.hasMessage()){
				throw inputCheckex;
			}

			// 物件条件名に入力されている値でscreenPropertyConditionsMapのキーを置き換える。
			putDispCond(this.tmpCondName);

			// 物件条件名に入力されている値でAccountPropertyConditionsの値を置換える。
			changeSelectOptionLabel(this.AccountPropertyConditions, this.tmpCondName, this.currentScreenPropertyCondition.Name);

			// 新しい物件条件をセットする。（条件 + screenPropertyConditionsMapサイズ+1）
			Integer propertyNum = this.screenPropertyConditionsMap.size()+1;
			String jouken = '条件';
			String newAddCondMapKey = jouken + propertyNum;

			// screenPropertyConditionsMapにキーが被っていない場合：（条件 + screenPropertyConditionsMapサイズ+1）
			if(!this.screenPropertyConditionsMap.containsKey(newAddCondMapKey)){
				this.screenPropertyConditionsMap.put(newAddCondMapKey, new screenPropertyConditions());
			}else{// screenPropertyConditionsMapにキーが被っている場合：（条件 + screenPropertyConditionsMapサイズ+被らない数値）
				for(Integer i=0; i<this.screenPropertyConditionsMap.size(); i++){
					propertyNum++;
					newAddCondMapKey = jouken + propertyNum;
					if(!this.screenPropertyConditionsMap.containsKey(newAddCondMapKey)){
						this.screenPropertyConditionsMap.put(newAddCondMapKey, new screenPropertyConditions());
						break;
					}
				}
			}
		
			// 表示用currentScreenPropertyConditionに追加した値,Nameに追加した条件名をセットする。
			this.currentScreenPropertyCondition = this.screenPropertyConditionsMap.get(newAddCondMapKey);
			this.currentScreenPropertyCondition.Name = newAddCondMapKey;
			// displayCondMapに追加した値をdisplayCond（表示用）に再度セットする。
			this.screenPropertyConditionsMap.put(newAddCondMapKey, this.currentScreenPropertyCondition);
			
			//追加した物件条件をMap置替用変数にセットする。
			this.tmpCondName = newAddCondMapKey;

			// selectOptionに値を追加し、表示用物件条件名に追加した値をセットする。
			String nowTimeStr = String.valueOf(Datetime.now().getTime());
			AccountPropertyConditions.add(new SelectOption(nowTimeStr, newAddCondMapKey));
			selectCondName = nowTimeStr;
		}catch(Exception e){
			hasErrorMessage = true;//エラーを設定
			CommonUtil.setErrorMessage(e);
			isInsertFlg = true;
		}
	}

	// 物件条件削除ボタン押下時の処理
	public void deletePropertyCond(){
		// 保存処理押下時判定用にdeleteFlgをTRUEに変更する。
		this.currentScreenPropertyCondition.deleteFlg = true;

		// 物件条件名に入力されている値でscreenPropertyConditionsMapのキーを置き換える。
		putDispCond(this.tmpCondName);

		// 物件条件選択リストの値から削除する。
		Integer count = 0;
		for(SelectOption sel : AccountPropertyConditions){
			if(sel.getValue().equals(this.selectCondName))break;
			count++;
		}
		AccountPropertyConditions.remove(count);

		// 最新の作成日時のものをscreenPropertyConditionsMapにセットする。（０件の場合は新規でマップにセットする。）
		screenPropertyConditions sortSpc = new screenPropertyConditions();
		Datetime sortDatetime = Datetime.now().addYears(100);
		String tmpKey;
		for(String key : this.screenPropertyConditionsMap.keySet()){
			screenPropertyConditions targetSpc = this.screenPropertyConditionsMap.get(key);
			if(targetSpc.CreatedDate != null && !targetSpc.deleteFlg){
				if(sortDatetime > targetSpc.CreatedDate){
					sortDatetime = targetSpc.CreatedDate;
					sortSpc = targetSpc;
					tmpKey = key;
				}
			}
		}

		// 全ての物件条件が新規追加で作成日時が存在しない場合は、AccountPropertyConditionsの0番目の値をセットする。
		if(sortSpc.CreatedDate == null){
			sortSpc = this.screenPropertyConditionsMap.get(this.AccountPropertyConditions[0].getLabel());
			tmpKey = this.AccountPropertyConditions[0].getLabel();
		}
		this.currentScreenPropertyCondition = sortSpc;

		// Map置き換え用変数に表示用の物件条件名をセットする。
		tmpCondName = this.currentScreenPropertyCondition.Name;

		// 表示用物件条件名にcurrentScreenPropertyConditionのNameをセットする。
		for(SelectOption sel : AccountPropertyConditions){
			if(sel.getLabel() == tmpKey){
				selectCondName = sel.getValue();
			}
		}
	}
	// ▲2021.10.08 No.307 対応で追加

    /**
     * お気に入り物件削除ボタン押下
     *  選択行を削除する。
     */
    public void deleteFavoriteProperty(){
        Savepoint sp = Database.setsavepoint();     // セーブポイント作成
        hasErrorMessage = false;

        try{

            // 選択行を取得（JSで選択件数チェックを行う為、outOfBoundsの考慮不要）
            List<screenFavoriteProperty> selectedDetailList = this.getSelectedDetailFavoriteProperty();
            screenFavoriteProperty selectedDetail = selectedDetailList[0]; 

            // 楽観ロックチェックExceptionを発行
            List<FavoriteProperty__c> checkOptimisticLockExceptionFavoriteProperty = new List<FavoriteProperty__c>();
            checkOptimisticLockExceptionFavoriteProperty = [ SELECT id
                                                             FROM FavoriteProperty__c
                                                             WHERE id = :selectedDetail.Id
                                                             AND SystemModStamp = :selectedDetail.SystemModstamp];
                                                             
            //楽観ロックチェック
            if (checkOptimisticLockExceptionFavoriteProperty.isEmpty()){
                OptimisticLockException ex = new OptimisticLockException();
                throw ex;
            }
            FavoriteProperty__c delDate = new FavoriteProperty__c();

            List<FavoriteProperty__c> favoritePropertyList = [SELECT Id FROM FavoriteProperty__c WHERE Id = :selectedDetail.Id];
            if (favoritePropertyList.size() > 0){
                delDate = favoritePropertyList[0];

                // 対象レコード削除
                SecureDML.secureDelete(delDate);
            }
            // お気に入り物件の再取得
            this.favoritePropertyList = new List<FavoriteProperty__c>();
            this.screenFavoritePropertyList  = new List<screenFavoriteProperty>();
            favoritePropertyList = selectFavoritePropertyInfo(this.accountId,CommonConst.STRING_EMPTY);
            if (favoritePropertyList.size() > 0){
                // リストをセット
                setFavoritePropertyList(favoritePropertyList);
            }
        }catch(Exception e){
            database.rollback(sp);
            hasErrorMessage = True;
            CommonUtil.setErrorMessage(e);
        }
    }
    
    /**
     * 空室予約物件の登録
     */
    public void registVacancyReservationProp(){
        
        Savepoint sp = Database.setsavepoint();
        hasErrorMessage = false;

        try {

            // 選択行を取得
            List<screenFavoriteProperty> selectedDetailList = this.getSelectedDetailFavoriteProperty();
                                                       
            // 楽観ロックチェック
            if (!isOptimisticLockFavoriteProp(selectedDetailList)) {
                throw new OptimisticLockException();
            }
            
            // 重複対象の建物の間取りを取得（key:建物ID、value:物件間取り）
            Map<Id, Set<String>> duplicateBuldingsFloorPlanMap = this.getDuplicateBuldingsFloorPlan(this.accountId);

            // 登録対象の建物の間取りを取得（key:建物.ID、value:物件間取り）
            Map<Id, Set<String>> registBuildingFloorPlanMap = this.getRegistTargetBuldingsFloorPlan(duplicateBuldingsFloorPlanMap
                                                                                                    , selectedDetailList);
            
            // 空室予約物件の登録チェック
            if (registBuildingFloorPlanMap.size() > 0) {

                // 建物の空き間取りを取得
                Map<Id, Set<String>> propMap = this.selectBuildingsFreeFloorPlan(registBuildingFloorPlanMap.keySet());

                // 空室予約物件の登録値を取得
                VacancyReservationProperty__c registEntity;                                                       // 登録エンティティ
                List<VacancyReservationProperty__c> registEntityList = new List<VacancyReservationProperty__c>(); // 登録リスト
 
                for (Id buildingId : registBuildingFloorPlanMap.keySet()) {
                    for (String floorPlan : registBuildingFloorPlanMap.get(buildingId)) {

                        // 空室予約物件の登録値
                        registEntity = new VacancyReservationProperty__c();
                        registEntity.Account__c = this.accountId;                        // 取引先
                        registEntity.Building__c = buildingId;                           // 建物
                        registEntity.PropertyFloorPlan__c = floorPlan;                   // 物件間取り
                        registEntity.VacancyStatus__c = CommonConst.VACANCY_STATUS_NONE; // 空室状況

                        // 空室状況の空きチェック
                        if (propMap.containsKey(buildingId)) {
                            if (propMap.get(buildingId).contains(floorPlan)) {
                                registEntity.VacancyStatus__c = CommonConst.VACANCY_STATUS_EXIST;
                            }
                        }

                        registEntityList.add(registEntity);
                    }
                }

                // 空室予約物件の登録
                SecureDML.secureInsert(registEntityList);
            }
            
            // 空室予約物件明細の再設定
            this.setScreenVacancyReservationProp();
            
            // 選択リストを初期化
            for (screenFavoriteProperty detail : screenFavoritePropertyList) {
                detail.isSelected = false;
            }

        } catch(Exception e) {
            database.rollback(sp);
            hasErrorMessage = True;
            CommonUtil.setErrorMessage(e);
        }
    }

    /**
    * 重複対象の建物の間取りを取得
    * @param String condAccountId 取引先ID
    * @return Map<Id, Set<String>> 重複対象建物の間取り（key:建物ID、value:物件間取り）
    */
    private Map<Id, Set<String>> getDuplicateBuldingsFloorPlan(String condAccountId) {

        // 空室予約物件の重複チェックデータを取得
        List<VacancyReservationProperty__c> vacancyReservationPropList = [SELECT Building__c
                                                                                 , PropertyFloorPlan__c
                                                                          FROM VacancyReservationProperty__c
                                                                          WHERE Account__c = :condAccountId];

        Map<Id, Set<String>> duplicateBuldingsFloorPlanMap = new Map<Id, Set<String>>();
        Set<String> tmpPropertyFloorPlanSet;

        for (VacancyReservationProperty__c vrp : vacancyReservationPropList) {

            // 建物キー毎のvalue値を初期化
            if (!duplicateBuldingsFloorPlanMap.containsKey(vrp.Building__c)) {
                duplicateBuldingsFloorPlanMap.put(vrp.Building__c, new Set<String>());
            }

            // valueを設定
            tmpPropertyFloorPlanSet = duplicateBuldingsFloorPlanMap.get(vrp.Building__c);
            tmpPropertyFloorPlanSet.add(vrp.PropertyFloorPlan__c);
            duplicateBuldingsFloorPlanMap.put(vrp.Building__c, tmpPropertyFloorPlanSet);
        }

        return duplicateBuldingsFloorPlanMap;
    }

    /**
    * 登録対象の建物の間取りを取得
    * @param Map<Id, Set<String>>         duplicateBuldingsFloorPlanMap 重複対象の建物の間取り（key:建物ID、value:物件間取り）
    * @param List<screenFavoriteProperty> selectedDetailList            お気に入り物件の選択行リスト 
    * @return Map<Id, Set<String>> 登録対象の建物の間取り（key:建物.ID、value:物件間取り）
    */
    private Map<Id, Set<String>> getRegistTargetBuldingsFloorPlan(Map<Id, Set<String>> duplicateBuldingsFloorPlanMap
                                                                  , List<screenFavoriteProperty> selectedDetailList) {
        
        Map<Id, Set<String>> registBuildingFloorPlanMap = new Map<Id, Set<String>>();
        Set<String> tmpPropertyFloorPlanSet;

        // 空室予約物件の登録対象の物件を取得
        for (screenFavoriteProperty selectedDetail : selectedDetailList) {
                
            // 重複チェック（建物ID 且つ 間取り）
            if (duplicateBuldingsFloorPlanMap.containsKey(selectedDetail.PropertyBuilding)) {
                if (duplicateBuldingsFloorPlanMap.get(selectedDetail.PropertyBuilding).contains(selectedDetail.FloorPlan)) {
                    continue;
                }
            }
            
            // 建物IDキー毎にvalue値を初期化
            if (!registBuildingFloorPlanMap.containsKey(selectedDetail.PropertyBuilding)) {
                registBuildingFloorPlanMap.put(selectedDetail.PropertyBuilding, new Set<String>());
            }

            // 登録建物マップを設定
            tmpPropertyFloorPlanSet = registBuildingFloorPlanMap.get(selectedDetail.PropertyBuilding);
            tmpPropertyFloorPlanSet.add(selectedDetail.FloorPlan);
            registBuildingFloorPlanMap.put(selectedDetail.PropertyBuilding, tmpPropertyFloorPlanSet);
        }

        return registBuildingFloorPlanMap;
    }

    /**
    * 建物の空き間取りを取得
    * @param Set<ID> condBuildingIdSet 建物ID
    * @return Map<Id, Set<String>> 建物の空き間取り（key:建物ID、value:物件間取り）
    */
    private Map<Id, Set<String>> selectBuildingsFreeFloorPlan(Set<ID> condBuildingIdSet) {

        // 空き間取りを取得
        List<Property__c> propList = [SELECT Building__c
                                             , FloorPlan__c
                                      FROM Property__c
                                      WHERE Building__c = :condBuildingIdSet
                                            AND LiveStatus__c IN (:CommonConst.PROPERTY_LIVESTATUS_VACANCY
                                                                  , :CommonConst.PROPERTY_LIVESTATUS_SCHEDULEDTOLEAVE)
                                     ];

        // 建物の空き間取り（key:建物ID、value:物件間取り）
        Map<Id, Set<String>> buildingsFloorPlanMap = new Map<Id, Set<String>>();
        Set<String> tmpValue;

        // 建物の空き間取りを取得
        for (Property__c prop : propList) {

            // 建物キー毎のvalue値を初期化
            if (!buildingsFloorPlanMap.containsKey(prop.Building__c)) {
                buildingsFloorPlanMap.put(prop.Building__c, new Set<String>());
            }

            // valueを設定
            tmpValue = buildingsFloorPlanMap.get(prop.Building__c);
            tmpValue.add(prop.FloorPlan__c);
            buildingsFloorPlanMap.put(prop.Building__c, tmpValue);
        }

        return buildingsFloorPlanMap;
    }

    /**
     * お気に入り物件の選択行を取得
     * @return List<screenFavoriteProperty> 選択行リスト
     */
    private List<screenFavoriteProperty> getSelectedDetailFavoriteProperty() {

        // 選択行を取得
        List<screenFavoriteProperty> selectedDetailList = new List<screenFavoriteProperty>();
        for (screenFavoriteProperty detail : screenFavoritePropertyList) {
            if (detail.isSelected) {
                selectedDetailList.add(detail);
            }
        }

        return selectedDetailList;
    }
    
    /**
     * 楽観ロックチェック（お気に入り物件）
     * @param List<screenFavoriteProperty> detailList お気に入り物件の明細
     * @return Boolean true:更新データ無し、false:更新データ有り
     */
    private Boolean isOptimisticLockFavoriteProp(List<screenFavoriteProperty> detailList) {
        
        // 条件値を取得
        Map<Id, screenFavoriteProperty> condMap = new Map<Id, screenFavoriteProperty>();
        for (screenFavoriteProperty detail : detailList) {
            condMap.put(detail.Id, detail);
        }
        
        // 楽観ロックチェック用のレコードの取得
        List<FavoriteProperty__c> currentRecordList = [SELECT id
                                                              , SystemModStamp
                                                       FROM FavoriteProperty__c
                                                       WHERE id IN :condMap.keySet()];
 
        // 削除済みチェック
        if (currentRecordList.size() != detailList.size()){
            return false;
        }
        
        return true;
    }

    /**
     * 条件完全一致物件削除ボタン押下
     *  選択行を削除する。
     */
    public void deleteExactConditionMatchProperty(){
        Savepoint sp = Database.setsavepoint();     // セーブポイント作成
        hasErrorMessage = false;
    
        try{
              
            //選択行取得
            List<ExactConditionMatchProperty__c> deleteList = new List<ExactConditionMatchProperty__c>();
            List<screenExactConditionMatchProperty> detailList = new List<screenExactConditionMatchProperty>();
            for (screenExactConditionMatchProperty detail : screenExactConditionMatchPropertyList) {
                
                if(detail.isSelected){
                    deleteList.add(new ExactConditionMatchProperty__c(id = detail.Id)); // 削除用のIDを取得
                    detailList.add(detail);                                             // 楽観ロック用の明細レコードを取得
                }
            }
              
            throwOptimisticLockException(detailList);
              
            //削除処理                                       
            SecureDML.secureDelete(deleteList);
    
            getExactConditionMatchPropertyList();
    
        } catch(Exception e){
            database.rollback(sp);
            hasErrorMessage = True;
            CommonUtil.setErrorMessage(e);
        }
    }


    public void throwOptimisticLockException(List<screenExactConditionMatchProperty> detailList){
        // 条件値を取得
        Map<Id, screenExactConditionMatchProperty> detailMap = new Map<Id, screenExactConditionMatchProperty>();
        for (screenExactConditionMatchProperty detail : detailList) {
            detailMap.put(detail.Id, detail);
        }
        
        // 楽観ロックチェック用のレコードの取得
        List<ExactConditionMatchProperty__c> previousRecordList = new List<ExactConditionMatchProperty__c>();
        previousRecordList = [ SELECT id, systemmodstamp
                            FROM ExactConditionMatchProperty__c
                            WHERE id IN :detailMap.keySet()];
 
        // 楽観ロックチェック
        // 削除済みチェック
        if(previousRecordList.size() == 0){
            OptimisticLockException ex = new OptimisticLockException();
            throw ex;
        }
        
        // 更新済みチェック
        screenExactConditionMatchProperty target;
        for (ExactConditionMatchProperty__c currentData : previousRecordList) {
            target = detailMap.get(currentData.Id);
            if (target.systemmodstamp != currentData.SystemModStamp) {
                OptimisticLockException ex = new OptimisticLockException();
                throw ex;
            }
        }
    }
    
    /**
     * 空室予約物件の削除
     */
    public void delVacancyReservationProp(){
        
        this.hasErrorMessage = false;
        Savepoint sp = Database.setsavepoint();
    
        try {
            // 選択明細行（key:空室予約物件.ID、value:空室予約物件DTO）
            Map<Id, ScreenVacancyReservationProp> selectedDetailMap = new Map<Id, ScreenVacancyReservationProp>();
            // 空室予約物件の削除リスト
            List<VacancyReservationProperty__c> delList = new List<VacancyReservationProperty__c>();
            
            // 明細行、空室予約物件を取得
            for (ScreenVacancyReservationProp detail : this.screenVacancyReservationPropList) {
                if (detail.isSelected){
                    selectedDetailMap.put(detail.VacancyReservationPropId, detail);
                    delList.add(new VacancyReservationProperty__c(Id = detail.VacancyReservationPropId));
                }
            }
        
            // 楽観ロックチェック
            if (!this.isOptimisticLockVacancyReservationProp(selectedDetailMap.values())) {
                throw new OptimisticLockException();
            }
            
            // 空室予約物件の削除
            if (delList.size() > 0) {
                SecureDML.secureDelete(delList);
            }
            
            // 空室予約物件明細の設定
            this.setScreenVacancyReservationProp();
        
        } catch(Exception e) {
            database.rollback(sp);
            this.hasErrorMessage = True;
            CommonUtil.setErrorMessage(e);
        }
    }
    
    /**
     * 楽観ロックチェック（空室予約物件）
     * @param List<ScreenVacancyReservationProp> detailList 空室予約物件の明細
     * @return Boolean true:更新データ無し、false:更新データ有り
     */
    private Boolean isOptimisticLockVacancyReservationProp(List<ScreenVacancyReservationProp> detailList) {
        
        // 条件値を取得
        Map<Id, ScreenVacancyReservationProp> condMap = new Map<Id, ScreenVacancyReservationProp>();
        for (ScreenVacancyReservationProp detail : detailList) {
            condMap.put(detail.VacancyReservationPropId, detail);
        }
        
        // 楽観ロックチェック用のレコードの取得
        List<VacancyReservationProperty__c> currentRecordList = [SELECT id
                                                                        , SystemModStamp
                                                                 FROM VacancyReservationProperty__c
                                                                 WHERE id IN :condMap.keySet()];
 
        // 楽観ロックチェック
        // 削除済みチェック
        if (currentRecordList.size() != detailList.size()){
            return false;
        }
        
        // 更新済みチェック
        for (VacancyReservationProperty__c currentRecord : currentRecordList) {
            if (condMap.get(currentRecord.Id).SystemModStamp != currentRecord.SystemModStamp) {
                return false;
            }
        }
        
        return true;
    }

    //追加要望 追加 Start
    /**
     * 配信停止ボタン押下
     * 紹介メール情報削除を削除。
     */
    public void introMailSendStop(){
        Savepoint sp = Database.setsavepoint();     // セーブポイント作成
        hasErrorMessage = false;
        try{
            //楽観ロックチェックExceptionを発行(取引先・紹介メール情報))
            //取引先
            List<account> checkOptimisticLockExceptionRecordAcc = new List<Account>();
            checkOptimisticLockExceptionRecordAcc = [ SELECT id
                                                        FROM Account
                                                        WHERE id = :this.accountId
                                                        AND SystemModStamp > :screenAccountRecord.systemModStamp ];                //楽観ロックチェック
            //紹介メール情報
            List<IntroductionMailInformation__c> checkOptimisticLockExceptionRecordIntroMail = new List<IntroductionMailInformation__c>();
            checkOptimisticLockExceptionRecordIntroMail = [ SELECT id
                                                            FROM IntroductionMailInformation__c
                                                            WHERE id = :introMailInfoList[0].Id
                                                            AND SystemModStamp > :introMailInfoList[0].SystemModStamp ]; 
            if (!checkOptimisticLockExceptionRecordAcc.isEmpty() || !checkOptimisticLockExceptionRecordIntroMail.isEmpty()){
                OptimisticLockException ex = new OptimisticLockException();
                throw ex;
            }
            //取引先の紹介メール配信状況を「配信停止」、追客回数を0に変更
            SecureDML.secureUpdate(new Account(id = this.accountId, 
                               IntroMailInfoPursuitCount__c = 0,
                               IntroMailInfoStatus__c = CommonConst_ptl.INTRODUCTION_SENDSTOP));

            //紹介メール情報削除
            SecureDML.secureDelete(introMailInfoList[0]);
            
            //取引先再取得 
            accountList = selectAccountInfo(this.accountId);
            screenAccountRecord = new screenAccount(accountList[0]);
            screenAccountRecord_bak = screenAccountRecord.clone();
            //紹介メール情報再取得
            this.introMailInfoList = new List<IntroductionMailInformation__c>();
            this.introMailInfoList = selectIntroMailInfo(this.accountId);
            
        }catch(Exception e){
            database.rollback(sp);
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    //追加要望 追加 End

    /**
     * 反響集約ボタンのOK押下
     * 対応状況の選択されたデータを集約する。
     */
    public void Echoaggregation(){
        Savepoint sp = Database.setsavepoint();     // セーブポイント作成
        hasErrorMessage = false;

        try{
            //楽観ロックチェックExceptionを発行(対応)
            List<Correspond__c> checkOptimisticLockExceptionRecord = new List<Correspond__c>();
            checkOptimisticLockExceptionRecord = [ SELECT id
                                                        FROM Correspond__c
                                                        WHERE id = :checkCorrespondId
                                                        AND SystemModStamp = :screenCorrespondRecordList[checkCorrespondIndex].systemmodstamp];
            if (checkOptimisticLockExceptionRecord.isEmpty()){
                // エラーあり
                OptimisticLockException ex = new OptimisticLockException();
                throw ex;
            }

            // 反響集約の登録
            echoRegister();

            // 対応状況再取得
            getCorrespondenceStatusList();

            // 対応明細再取得
            getCorrespondenceHistoryList();

            //追加要望 追加 start
            //取引先再取得 
            accountList = selectAccountInfo(this.accountId);
            screenAccountRecord = new screenAccount(accountList[0]);
            screenAccountRecord_bak = screenAccountRecord.clone();
            this.introMailInfoList = new List<IntroductionMailInformation__c>();
            //紹介メール情報再取得
            this.introMailInfoList = selectIntroMailInfo(this.accountId);
            //追加要望 追加 end

            // ボタンの再設定
            setButtonList();

        }catch(Exception e){
            database.rollback(sp);
            hasErrorMessage = True;
            CommonUtil.setErrorMessage(e);
        }

    }
    
    /**
     * 反響集約ボタンのCancel押下
     * 対応状況の選択されたデータを集約する。
     */
    public void updUnnecessaryEchoAggregation() {
        
        Savepoint sp = Database.setsavepoint();
        try{
            
            this.hasErrorMessage = false;            
            ScreenCorrespond selectedDetail = screenCorrespondRecordList[checkCorrespondIndex];
            
            // 対応状況（選択行）のレコードを取得
            List<Correspond__c> currentRecord = [SELECT id
                                                 FROM Correspond__c
                                                 WHERE id = :checkCorrespondId
                                                 AND SystemModStamp = :selectedDetail.SystemModStamp];
            
            // 楽観ロックチェック
            if (currentRecord.isEmpty()){
                throw new OptimisticLockException();
            }
            
            // 選択行の反響集約不要フラグを更新
            Correspond__c updCorrespond = new Correspond__c();
            updCorrespond.Id = selectedDetail.Id;
            updCorrespond.IsUnnecessaryEchoAggregation__c = true;
            SecureDML.secureUpdate(updCorrespond);
        
            // 対応状況を再取得
            this.getCorrespondenceStatusList();
            
            // ボタンを再設定
            this.setButtonList();
            
        } catch(Exception e){
            database.rollback(sp);
            this.hasErrorMessage = True;
            CommonUtil.setErrorMessage(e);
        }
    }

    /**
     *  対応確認押下処理
     *  
     */
    public void setResponseconfirmation(){
        Savepoint sp = Database.setsavepoint();
        hasErrorMessage = False;
        ResponseConfirmationFlg = false;
        
        //システム管理者、システム管理者カスタムのプロファイルIDを取得
        Id adminProfileId= [SELECT Id 
                        FROM Profile
                        WHERE Name = :CommonConst.PROFILE_SYSTEM_ADMINISTRATOR].id;
        //▼再販追加
        //Id adminCustomProfileId= [SELECT Id 
        //                 FROM Profile
        //                WHERE Name = :CommonConst.PROFILE_SYSTEM_ADMINISTRATOR_CUSTOM].id;
        List<Profile> adminCustomProfiles = [SELECT Id 
                         FROM Profile
                        WHERE Name = :CommonConst.PROFILE_SYSTEM_ADMINISTRATOR_CUSTOM];
        
        Id adminCustomProfileId = adminCustomProfiles.isEmpty() ? null : adminCustomProfiles[0].Id;
        //▲再販追加
        try{
            // ログインユーザが反響、来店以外のユーザ、管理者のユーザーの場合スルー
            if (loginStaff == checkEchoStaff ||loginStaff == checkShopStaff || loginUserProfileId == adminProfileId || loginUserProfileId  == adminCustomProfileId){
                //楽観ロックチェックExceptionを発行(対応)
                List<Correspond__c> checkOptimisticLockExceptionRecord = new List<Correspond__c>();
                checkOptimisticLockExceptionRecord = [ SELECT id
                                                            FROM Correspond__c
                                                            WHERE id = :checkCorrespondId
                                                            AND SystemModStamp = :screenCorrespondRecordList[checkCorrespondIndex].systemmodstamp];
                

                if (checkOptimisticLockExceptionRecord.isEmpty()){
                    // エラーあり
                    OptimisticLockException ex = new OptimisticLockException();
                    throw ex;
                }
                // 更新処理
                Correspond__c saveDate = new Correspond__c();
                saveDate.id  =  checkCorrespondId;                          // ID

                saveDate.EventDateTime__c = CommonUtil.getNow();            // イベント時刻                                                           
                saveDate.IsSupportedListShow__c = true;                     // 対応確認                                                         
                saveDate.IsBrowseFlg__c = true;                            // 閲覧フラグ

                // ログインユーザーと反響担当者もしくは、来店担当者とが一致しなければ：False、以外はTreu スタッフ対応フラグ
                if (loginStaff == checkEchoStaff ||loginStaff ==  checkShopStaff || loginUserProfileId == adminProfileId || loginUserProfileId  == adminCustomProfileId ){
                    saveDate.StaffSupportedFlg__c = true;
                }else {
                    saveDate.StaffSupportedFlg__c = false;
                }

                //2020/6/15追加：顧客の場合、追客解除設定日時に　追客解除設定日時（保存用）に設定されている日時を設定する
                if (screenAccountRecord.RecordTypeId ==  CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_CUSTOMER)){
                    saveDate.PursuitDissolveSettingDate__c = checkPursuitDissolveDate;//追客解除設定日時 = 追客解除設定日時（保存用）
                }
                
                //2020/7/13変更：一覧表示日時取得 (引数1：ステータス、引数2：対応レコード)
                saveDate.ListViewDate__c = CustomerUtil.setListViewDateWhenCorrespondCheck(screenCorrespondRecordList[checkCorrespondIndex].targetCorrespondRecord.Status__c, screenCorrespondRecordList[checkCorrespondIndex].targetCorrespondRecord);

                SecureDML.secureUpdate(saveDate);
                ResponseConfirmationFlg = true;


                // 確認できれは対応一覧を取り直す。
                this.screenCorrespondRecordList = new List<screenCorrespond>(); 
                this.correspondList = selectCorrespondInfo(this.accountId,CommonConst.STRING_EMPTY);
                if (this.correspondList.size() > 0){
                    // リストをセット
                    setCorrespondList(this.correspondList,this.correspondId);
                    // 対応単体取得
                    this.correspondList = selectCorrespondInfo(this.accountId,this.correspondId);
                    if (this.correspondList.size() > 0 ){
                        this.screenCorrespondRecord = this.correspondList[0];
                        setHeaderName(screenAccountRecord,this.screenCorrespondRecord);
                    }
                    
                }else{
                    // 1件も取得できない状態は1件だけ条件に関係なく最新の対応を取得する。
                    List<Correspond__c> correspondEndDate ;                      // 対応の一覧表示
                    correspondEndDate = selectCorrespondInfoAgentEnd(this.accountId);
                    if(correspondEndDate.size() > 0){

                        setCorrespondList(correspondEndDate,this.correspondId);
                    }
                }

                // ステータスの状態でボタンを設定する。
                setButtonList();
            }
        }catch(Exception e){
            database.rollback(sp);
            hasErrorMessage = True;
            CommonUtil.setErrorMessage(e);
        }
    }

    /**
     *  対応の物件紐づけ処理
     *  引数    ：  Correspond Correspond__c 対応状況選択行
     *          ：  favoriteProperty screenFavoriteProperty お気に入り物件データ
     *          ：  insFlg Boolean 新規登録フラグ
     */
    private void saveCorrespondProperty(Correspond__c Correspond,screenFavoriteProperty favoriteProperty,Boolean insFlg){

            // 更新処理
            Correspond__c saveDate = new Correspond__c();
            
            if (!insFlg){
                // 更新
                saveDate.id = Correspond.Id;
            }else{
                // 登録時のみ
                saveDate.AccountId__c = Correspond.AccountId__c;  // 取引先 ID
                saveDate.EventDateTime__c = CommonUtil.getNow();  // イベント時刻
                saveDate.IsSupportedListShow__c = false;          // 対応確認
                saveDate.EchoStaff__c = Correspond.EchoStaff__c;  // 担当者（反響）
                saveDate.ShopStaff__c = Correspond.ShopStaff__c;  // 担当者（店舗）
                saveDate.EchoShop__c = Correspond.EchoShop__c;    // 反響担当店舗
                saveDate.VisitShop__c = Correspond.VisitShop__c;  // 来店担当店舗
                saveDate.District__c = Correspond.District__c;    // 地区
                saveDate.SendMailDate__c                 = Correspond.SendMailDate__c;               // メール送信日時
                saveDate.ReceiveMailDatePortal__c        = Correspond.ReceiveMailDatePortal__c;      // メール受信日時（ポータル）
                saveDate.ReceiveMailDateOther__c         = Correspond.ReceiveMailDateOther__c;       // メール受信日時（その他）
                saveDate.PhoneIncomingDate__c            = Correspond.PhoneIncomingDate__c;          // 電話着信日時
                saveDate.PhoneOutgoingDate__c            = Correspond.PhoneOutgoingDate__c;          // 電話発信日時
                saveDate.PhoneAbsenceDate__c             = Correspond.PhoneAbsenceDate__c;           // 電話不在日時
                saveDate.BrowseDate__c                   = Correspond.BrowseDate__c;                 // 閲覧日時
                saveDate.PursuitDissolveSettingDate__c   = Correspond.PursuitDissolveSettingDate__c; // 追客解除設定日時
                saveDate.VisitDate__c                    = Correspond.VisitDate__c;                  // 来店日（初回）                 
                saveDate.IsEchoNotCalculation__c         = true;                                     //反響数非計算フラグ                             
                saveDate.IsVisitNotCalculation__c        = true;                                     //来店数非計算フラグ  
                saveDate.Status__c                       = Correspond.Status__c;                     // ステータス
				// ▼ 2021.11.30 LINE連携対応より、LINE会員を追加
				saveDate.LineMember__c	= Correspond.LineMember__c;
				// ▲ 2021.11.30
            }
            // ログインユーザーと来店担当者とが一致しなければ：False、以外はTreu スタッフ対応フラグ
            if (loginStaff ==  checkShopStaff){
                saveDate.StaffSupportedFlg__c = true;
            }else {
                saveDate.StaffSupportedFlg__c = false;
            }
            saveDate.Property__c = favoriteProperty.Property;// 物件
            
            SecureDML.secureUpsert(saveDate);

            // 登録の場合、対応IDと物件IDを保持する。
            if (insFlg){   
                this.PropertyLinkProperty = favoriteProperty.Property;
                this.PropertyLinkId = saveDate.id;
            }
    }

	// ▼ 2021.11.30 LINE連携対応より、対応履歴モーダル.対応種別の表示フラグの設定処理を追加
	/**
	 * 対応履歴モーダル用対応種別の表示フラグの設定
	 * @param Set<String> notDispStatusSet 非表示用ステータス
	 */
	private void setDispCorrespondType(Set<String> notDispStatusSet) {

		for (ScreenCorrespond screenCorrespond : this.screenCorrespondRecordList) {

			screenCorrespond.isDispModal2CorrespondType = true;
			if (notDispStatusSet.contains(screenCorrespond.status)) {
				screenCorrespond.isDispModal2CorrespondType = false;
			}
		}
	}
	// ▲ 2021.11.30

// -----------------------------------------------------------------------------------------------
// SQL取得
// -----------------------------------------------------------------------------------------------
    

    /**
     * 検索処理（取引先）
     * 引数によって内容を絞り込んだデータを取得する。
     * 引数　　：　id String 取引先ID
     * 戻り値　：　List<Account> 取引先データ
     */
    private List<Account> selectAccountInfo(String id){


        // 検索SQL作成
        String sql = CommonConst.STRING_EMPTY;
        sql += 'SELECT Id ';                            // 取引先.Id（非表示）
        sql += '      ,SystemModstamp ';                // SystemModstamp
		sql += '      ,CreatedDate ';                   // 取引先.作成日時 2021.10.08 No.307 対応で追加
		sql += '      ,IsReservePropertyConditions__c ';// 取引先.予約物件条件
        sql += '      ,RecordTypeId ';                  // 取引先.レコードタイプ
        sql += '      ,Name ';                          // 取引先.取引先名  
        sql += '      ,LastName__c ';                   // 取引先.姓  
        sql += '      ,FirstName__c ';                  // 取引先.名  
        sql += '      ,NameKana__c ';                   // 取引先.取引先名（カナ）
        sql += '      ,LastNameKana__c ';               // 取引先.姓（カナ）
        sql += '      ,FirstNameKana__c ';              // 取引先.名（カナ）
        sql += '      ,Sex__c ';                        // 取引先.性別
        sql += '      ,Birthdate__c ';                  // 取引先.生年月日
        sql += '      ,Age__c ';                        // 取引先.年齢
        sql += '      ,PostalCode__c ';                 // 取引先.郵便番号
        sql += '      ,State__c ';                      // 取引先.都道府県
        sql += '      ,City__c ';                       // 取引先.住所１（市区町村）
        sql += '      ,Street__c ';                     // 取引先.住所２（番地）        

        sql += '      ,CompanyName__c ';                // 取引先.会社名
        sql += '      ,CompanyNameKana__c ';            // 取引先.会社名（カナ）
        sql += '      ,CompanyPostalCode__c ';          // 取引先.会社 郵便番号
        sql += '      ,Situation__c ';                  // 問合せNo341で追加　取引先.状況
        sql += '      ,EchoTelephoneFlag__c ';          // 問合せNo341で追加　取引先.電話反響登録済みフラグ
        sql += '      ,EchoLineFlag__c ';               // 問合せNo411で追加　取引先.LINE反響登録済みフラグ
        sql += '      ,EchoLiveroFlag__c ';             // 問合せNo411で追加　取引先.リベロ反響登録済みフラグ
        sql += '      ,CompanyState__c ';               // 取引先.会社 都道府県
        sql += '      ,CompanyCity__c ';                // 取引先.会社 住所１
        sql += '      ,CompanyStreet__c ';              // 取引先.会社 住所２
        sql += '      ,CompanyIndustries__c ';          // 取引先.会社 業種
        sql += '      ,CorporationRepresentative__c ';  // 取引先.担当者（法人用）
        sql += '      ,Department__c ';                 // 取引先.所属部署
        sql += '      ,Post__c ';                       // 取引先.役職
        sql += '      ,Comment__c ';                    // 取引先.コメント

        sql += '      ,Phone ';                         // 取引先.電話番号
        sql += '      ,Phone2__c ';                     // 取引先.電話番号２
        sql += '      ,Phone3__c ';                     // 取引先.電話番号３
        sql += '      ,Email__c ';                      // 取引先.メール
        sql += '      ,Email2__c ';                     // 取引先.メール２
        sql += '      ,Email3__c ';                     // 取引先.メール３

        sql += '      ,Affiliation__c ';                // 勤務先/学校
        sql += '      ,AccountIndustry__c ';            // 勤務先/業種（個人）
        sql += '      ,AffiliationPhone__c ';           // 勤務先/学校 電話番号
        sql += '      ,AffiliationPostalCode__c ';      // 勤務先/学校 郵便番号
        sql += '      ,AffiliationState__c ';           // 勤務先/学校 都道府県
        sql += '      ,AffiliationAddress__c ';         // 勤務先/学校_住所
        sql += '      ,AffiliationCity__c ';            // 勤務先/学校 住所１（市区町村）
        sql += '      ,AffiliationStreet__c ';          // 勤務先/学校 住所２（番地）

        sql += '      ,IsMergeCompletedFlag__c ';       // 取引先.名寄せ完了フラグ
        sql += '      ,IsMergeUnnecessaryFlag__c ';     // 取引先.名寄せ不要フラグ
        sql += '      ,HomePhone__c       ';            // 取引先.自宅TEL
        sql += '      ,Fax ';                           // 取引先.Fax
        sql += '      ,JobType__c ';                    // 取引先.職種
        sql += '      ,VisitsDate__c ';                 // 取引先.来店日
        sql += '      ,VisitsTrigger__c ';              // 取引先.来店のきっかけ
        sql += '      ,PortalSite__c ';                 // 取引先.ポータルサイト
        sql += '      ,SiteView__c ';                   // 取引先.事前にネット
        sql += '      ,Introducer__c ';                 // 取引先.紹介者
        sql += '      ,HomeMovingReason__c ';           // 取引先.引越理由
        sql += '      ,Dissatisfaction__c ';            // 取引先.不満理由
        sql += '      ,ContractType__c ';               // 取引先.契約形態
        sql += '      ,ProxyCompanyName__c ';           // 取引先.代理会社名
        sql += '      ,IsProxyCompany__c ';             // 取引先.代理会社有無
        sql += '      ,HomeMovingSeason__c ';           // 取引先.引越時期
        sql += '      ,HomeMovingDate__c ';             // 取引先.引越時期（日付）までに
        sql += '      ,TenantCount__c ';                // 取引先.入居人数
        sql += '      ,DesiredArea__c ';                // 取引先.希望地域
        sql += '      ,DesiredTrainRoute1__c ';         // 取引先.希望路線１
        sql += '      ,DesiredTrainRoute2__c ';         // 取引先.希望路線２
        sql += '      ,DesiredTrainRoute3__c ';         // 取引先.希望路線３
        sql += '      ,DesiredTrainRoute1__r.TrainRoute__c '; // 取引先.路線１
        sql += '      ,DesiredTrainRoute2__r.TrainRoute__c '; // 取引先.路線２
        sql += '      ,DesiredTrainRoute3__r.TrainRoute__c '; // 取引先.路線３
        sql += '      ,DesiredTrainRoute1__r.TrainRoute__r.name '; // 取引先.路線１
        sql += '      ,DesiredTrainRoute2__r.TrainRoute__r.name '; // 取引先.路線２
        sql += '      ,DesiredTrainRoute3__r.TrainRoute__r.name '; // 取引先.路線３
        sql += '      ,WalkingTime__c ';                // 取引先.駅までの徒歩（分）
        sql += '      ,IsOneRoom__c ';                  // 取引先.ワンルーム
        sql += '      ,Is1K__c ';                       // 取引先.1K
        sql += '      ,Is1DK__c ';                      // 取引先.1DK
        sql += '      ,Is1LDK1SLDK__c ';                // 取引先.1LDK/SLDK
        sql += '      ,Is2K2DK__c ';                    // 取引先.2K/DK
        sql += '      ,Is2LDK2SLDK__c ';                // 取引先.2LDK/SLDK
        sql += '      ,Is3K3DK__c ';                    // 取引先.3K/DK
        sql += '      ,Is3LDK3SLDK__c ';                // 取引先.3LDK/SLDK
        sql += '      ,Is4K4DK4LDKFrom__c ';            // 取引先.4K/DK/LDK~
        sql += '      ,IsWooden__c ';                   // 取引先.木造
        sql += '      ,IsLightweightSteel__c ';         // 取引先.軽量鉄骨
        sql += '      ,IsSteel__c ';                    // 取引先.鉄骨造
        sql += '      ,IsRC__c ';                       // 取引先.RC
        sql += '      ,IsSRC__c ';                      // 取引先.SRC
        sql += '      ,IsNorth__c ';                    // 取引先.北
        sql += '      ,IsNorthEast__c ';                // 取引先.北東
        sql += '      ,IsEast__c ';                     // 取引先.東
        sql += '      ,IsSouthEast__c ';                // 取引先.南東
        sql += '      ,IsSouth__c ';                    // 取引先.南
        sql += '      ,IsSouthWest__c ';                // 取引先.南西
        sql += '      ,IsWest__c ';                     // 取引先.西
        sql += '      ,IsNorthWest__c ';                // 取引先.北西
        sql += '      ,IsNonDeposit__c ';               // 取引先.敷金/保証金なし
        sql += '      ,IsNonKeyMoney__c ';              // 取引先.礼金なし
        sql += '      ,IsNonCleaningFee__c ';           // 取引先.定額修繕費なし
        sql += '      ,IsNonRenewalFee__c ';            // 取引先.更新料なし
        sql += '      ,RentFeeFrom__c ';                // 取引先.希望賃料（下限）
        sql += '      ,RentFeeTo__c ';                  // 取引先.希望賃料（上限）
        sql += '      ,OccupancyAreaLowerLimit__c ';    // 取引先.占有面積（下限）
        sql += '      ,OccupancyAreaUpperLimit__c ';    // 取引先.占有面積（上限）
        sql += '      ,BuildingAge__c ';                // 取引先.築年数
        sql += '      ,IsIncludeManagementFee__c ';     // 取引先.管理費込み
        sql += '      ,IsIncludeParkingFee__c ';        // 取引先.駐車場代込み
        sql += '      ,CarCount__c ';                   // 取引先.台数
        sql += '      ,ParkingFeeLimit__c ';            // 取引先.1台当たりの料金上限
        sql += '      ,Parking__c ';                    // 取引先.駐車場
        sql += '      ,IsDetachedHouse__c ';            // 取引先.戸建て
        sql += '      ,IsMaisonette__c ';               // 取引先.メゾネット
        sql += '      ,IsLoft__c ';                     // 取引先.ロフト
        sql += '      ,IsDesigners__c ';                // 取引先.デザイナーズ
        sql += '      ,IsRenovation__c ';               // 取引先.リノベーション
        sql += '      ,IsCondominiumRental__c ';        // 取引先.分譲賃貸
        sql += '      ,IsAllWestern__c ';               // 取引先.オール洋間
        sql += '      ,IsFirstFloor__c ';               // 取引先.1階
        sql += '      ,IsSecondFloorOver__c ';          // 取引先.2階以上
        sql += '      ,IsTopFloor__c ';                 // 取引先.最上階
        sql += '      ,IsCornerRoom__c ';               // 取引先.角部屋
        sql += '      ,IsBalcony__c ';                  // 取引先.バルコニー
        sql += '      ,IsRoofBalcony__c ';              // 取引先.ルーフバルコニー
        sql += '      ,IsPrivateGarden__c ';            // 取引先.専用庭
        sql += '      ,IsParking__c ';                  // 取引先.駐車場空きあり
        sql += '      ,IsInSiteParking__c ';            // 取引先.敷地内駐車場
        sql += '      ,IsPluralCarParking__c ';         // 取引先.駐車場2台可
        sql += '      ,IsBuiltInGarage__c ';            // 取引先.ビルトインガレージ
        sql += '      ,IsCarport__c ';                  // 取引先.カーポート
        sql += '      ,IsBicycleParking__c ';           // 取引先.駐輪場
        sql += '      ,IsBikeStorage__c ';              // 取引先.バイク可
        sql += '      ,IsSmallBike__c ';                // 取引先.小型バイク
        sql += '      ,IsMediumBike__c ';               // 取引先.中型バイク
        sql += '      ,IsLargeBike__c ';                // 取引先.大型バイク
        sql += '      ,IsElevator__c ';                 // 取引先.エレベーター
        sql += '      ,IsDeliveryBox__c ';              // 取引先.宅配ボックス
        sql += '      ,IsCounterKitchen__c ';           // 取引先.カウンターキッチン
        sql += '      ,IsSystemKitchen__c ';            // 取引先.システムキッチン
        sql += '      ,IsGasStove__c ';                 // 取引先.ガスコンロ
        sql += '      ,IsElectricStove__c ';            // 取引先.電気コンロ
        sql += '      ,IsInductionHeating__c ';         // 取引先.IHコンロ
        sql += '      ,IsTwoGasStove__c ';              // 取引先.コンロ2口
        sql += '      ,IsMoreGasStove__c ';             // 取引先.コンロ3口以上
        sql += '      ,IsSepalateBathAndRestroom__c ';  // 取引先.バス・トイレ別
        sql += '      ,IsAditionalBoiling__c ';         // 取引先.追焚機能
        sql += '      ,IsDehumidifierForBathroom__c ';  // 取引先.浴室乾燥機
        sql += '      ,IsWashlet__c ';                  // 取引先.温水洗浄便座
        sql += '      ,IsShowerWashBasin__c ';          // 取引先.シャワー付き洗面台
        sql += '      ,IsRegalLavatory__c ';            // 取引先.洗面所独立

        sql += '      ,IsInnerLandry__c ';              // 取引先.室内洗濯機置場
        sql += '      ,IsTownGas__c ';                  // 取引先.都市ガス
        sql += '      ,IsPropaneGas__c ';               // 取引先.プロパンガス
        sql += '      ,IsAllElectric__c ';              // 取引先.オール電化
        sql += '      ,IsAirConditioner__c ';           // 取引先.エアコン
        sql += '      ,IsFloorHeating__c ';             // 取引先.床暖房
        sql += '      ,IsShoesBox__c ';                 // 取引先.シューズボックス
        sql += '      ,IsShoeCloak__c ';                // 取引先.シューズクローク
        sql += '      ,IsWalkInCloset__c ';             // 取引先.ウォークインクローゼット
        sql += '      ,IsTrunkRoom__c ';                // 取引先.トランクルーム
        sql += '      ,IsBSAntenna__c ';                // 取引先.BSアンテナ
        sql += '      ,IsCSAntenna__c ';                // 取引先.CSアンテナ
        sql += '      ,IsCATV__c ';                     // 取引先.CATV
        sql += '      ,IsInternetFree__c ';             // 取引先.ネット使用料無料
        sql += '      ,IsMonitorIntercom__c ';          // 取引先.モニタ付インターホン
        sql += '      ,IsAutoLock__c ';                 // 取引先.オートロック
        sql += '      ,IsFurniture__c ';                // 取引先.家具付き
        sql += '      ,IsHomeAppliance__c ';            // 取引先.家電付き
        sql += '      ,IsNoGuarantor__c ';              // 取引先.保証人不要
        sql += '      ,IsNonGuaranteeidCompany__c ';    // 取引先.保証会社不要
        sql += '      ,IsMusicalInstruments__c ';       // 取引先.楽器相談可
        sql += '      ,IsForeigner__c ';                // 取引先.外国人契約可
        sql += '      ,IsWelfareAvailable__c ';         // 取引先.生活保護契約可
        sql += '      ,IsOfficeAvailable__c ';          // 取引先.事務所利用可
        sql += '      ,IsPet__c ';                      // 取引先.ペット可
        sql += '      ,IsSmallPet__c ';                 // 取引先.ペット(小型犬)
        sql += '      ,IsMiddlePet__c ';                // 取引先.ペット(中型犬)
        sql += '      ,IsLargePet__c ';                 // 取引先.ペット(大型犬)
        sql += '      ,IsCat__c ';                      // 取引先.ペット(猫)
        sql += '      ,IsOtherPet__c ';                 // 取引先.ペット(その他)
        sql += '      ,IsTwoTenant__c ';                // 取引先.2人入居可
        sql += '      ,IsRoomShare__c ';                // 取引先.ルームシェア可
        sql += '      ,IsIppambutsu__c ';               // 取引先.一般物
        sql += '      ,IsElderly__c ';                  // 取引先.高齢者歓迎
        sql += '      ,IsWoman__c ';                    // 取引先.女性限定
        sql += '      ,IsStudent__c ';                  // 取引先.学生限定マンション

        sql += '      ,CompanyEstablishmentYear__c ';   // 取引先.設立(年)
        sql += '      ,CompanyEstablishmentMonth__c ';  // 取引先.設立(月)
        sql += '      ,CompanyCapital__c ';             // 取引先.資本金

        sql += '      ,CompanyPhone__c ';                   // 取引先.法人電話番号
        sql += '      ,CorporationRepresentativePhone__c '; // 取引先.担当者電話番号

        sql += '      ,IntroMailInfoStatus__c ';            // 取引先.紹介メール配信状況   //追加要望 追加
        // ▼問合せ415で追加
        sql += '      ,DesiredJuniorHighSchoolArea__c';               //中学校希望学区（エリア）
        sql += '      ,DesiredJuniorHighSchoolArea__r.SchoolArea__c'; // 中学校希望学区（エリア）.希望学区（エリア）
        sql += '      ,DesiredElementarySchoolArea__c';               //小学校希望学区（エリア）
        sql += '      ,DesiredElementarySchoolArea__r.SchoolArea__c'; // 小学校希望学区（エリア）.希望学区（エリア）
        // ▲問合せ415で追加

		sql += '      ,PropertyConditionsName__c ';  // 取引先.物件条件名 2021.10.08 No.307 対応で追加

        sql += '      ,(SELECT Status__c,Event__c,EventDateTime__c FROM CorrespondAccountId__r) ';                  // 対応
		// ▼ 2022.1.29 LINE連携対応より、LINE専用画面の遷移条件の修正から削除
		// ▲ 2022.1.29

        sql += ' FROM  Account         ';

        sql += ' WHERE ID = \'' + CommonUtil.escapeSingleQuotesEx(id) + '\'' ;

       
        // 検索実行＆結果返却
        return Database.query(sql);
    }

	// ▼2021.10.08 No.307 対応で追加
	/**
	 * 検索処理（お客様物件条件）
	 * 引数によって内容を絞り込んだデータを取得する。
	 * 引数　　：　id String 取引先ID
	 * 戻り値　：　List<AccountPropertyConditions__c> お客様物件条件データ
	 */
	private List<AccountPropertyConditions__c> getAccountPropertyConditions(String accountId){
		List<AccountPropertyConditions__c> accountPCList = [SELECT ID
			,SystemModstamp					//お客様物件条件.SystemModstamp
			,Name							//お客様物件条件.お客様物件条件名
			,CreatedDate					//お客様物件条件.作成日時
			,IsDeleted__c					//お客様物件条件.削除
			,IsReservePropertyConditions__c	//お客様物件条件.予約物件条件
			,DesiredArea__c					//お客様物件条件.希望地域
			,DesiredTrainRoute1__c						//お客様物件条件.希望沿線１
			,DesiredTrainRoute1__r.TrainRoute__c		//お客様物件条件.希望沿線１．路線
			,DesiredTrainRoute1__r.TrainRoute__r.NAME	//お客様物件条件.希望沿線１．路線．路線名
			,DesiredTrainRoute2__c						//お客様物件条件.希望沿線２
			,DesiredTrainRoute2__r.TrainRoute__c		//お客様物件条件.希望沿線２．路線
			,DesiredTrainRoute2__r.TrainRoute__r.NAME	//お客様物件条件.希望沿線２．路線．路線名
			,DesiredTrainRoute3__c						//お客様物件条件.希望沿線３
			,DesiredTrainRoute3__r.TrainRoute__c		//お客様物件条件.希望沿線３．路線
			,DesiredTrainRoute3__r.TrainRoute__r.NAME	//お客様物件条件.希望沿線３．路線．路線名
			,WalkingTime__c			//お客様物件条件.徒歩
			,IsOneRoom__c			//お客様物件条件.ワンルーム
			,Is1K__c				//お客様物件条件.1K
			,Is1DK__c				//お客様物件条件.1DK
			,Is1LDK1SLDK__c			//お客様物件条件.1LDK/SLDK
			,Is2K2DK__c				//お客様物件条件.2K/DK
			,Is2LDK2SLDK__c			//お客様物件条件.2LDK/SLDK
			,Is3K3DK__c				//お客様物件条件.3K/DK
			,Is3LDK3SLDK__c			//お客様物件条件.3LDK/SLDK
			,Is4K4DK4LDKFrom__c		//お客様物件条件.4K/DK/LDK~
			,IsWooden__c			//お客様物件条件.木造
			,IsLightweightSteel__c	//お客様物件条件.軽量鉄骨
			,IsSteel__c				//お客様物件条件.鉄骨造
			,IsRC__c				//お客様物件条件.RC
			,IsSRC__c				//お客様物件条件.SRC
			,IsNorth__c				//お客様物件条件.北
			,IsNorthEast__c			//お客様物件条件.北東
			,IsEast__c				//お客様物件条件.東
			,IsSouthEast__c			//お客様物件条件.南東
			,IsSouth__c				//お客様物件条件.南
			,IsSouthWest__c			//お客様物件条件.南西
			,IsWest__c				//お客様物件条件.西
			,IsNorthWest__c			//お客様物件条件.北西
			,IsNonDeposit__c		//お客様物件条件.敷金/保証金なし
			,IsNonKeyMoney__c		//お客様物件条件.礼金なし
			,IsNonCleaningFee__c	//お客様物件条件.定額修繕費なし
			,IsNonRenewalFee__c		//お客様物件条件.更新料なし
			,RentFeeFrom__c			//お客様物件条件.賃料から
			,RentFeeTo__c			//お客様物件条件.賃料まで
			,IsIncludeManagementFee__c	//お客様物件条件.管理費込み
			,IsIncludeParkingFee__c		//お客様物件条件.駐車場代込み
			,OccupancyAreaLowerLimit__c	//お客様物件条件.占有面積（下限）
			,OccupancyAreaUpperLimit__c	//お客様物件条件.占有面積（上限）
			,BuildingAge__c			//お客様物件条件.築年数
			,IsDetachedHouse__c		//お客様物件条件.戸建て
			,IsMaisonette__c		//お客様物件条件.メゾネット
			,IsLoft__c				//お客様物件条件.ロフト
			,IsDesigners__c			//お客様物件条件.デザイナーズ
			,IsRenovation__c		//お客様物件条件.リノベーション
			,IsCondominiumRental__c	//お客様物件条件.分譲賃貸
			,IsAllWestern__c		//お客様物件条件.オール洋間
			,IsFirstFloor__c		//お客様物件条件.1階
			,IsSecondFloorOver__c	//お客様物件条件.2階以上
			,IsTopFloor__c			//お客様物件条件.最上階
			,IsCornerRoom__c		//お客様物件条件.角部屋
			,IsBalcony__c			//お客様物件条件.バルコニー
			,IsRoofBalcony__c		//お客様物件条件.ルーフバルコニー
			,IsPrivateGarden__c		//お客様物件条件.専用庭
			,IsParking__c			//お客様物件条件.駐車場空きあり
			,IsInSiteParking__c		//お客様物件条件.敷地内駐車場
			,IsPluralCarParking__c	//お客様物件条件.駐車場2台可
			,IsBuiltInGarage__c		//お客様物件条件.ビルトインガレージ
			,IsCarport__c			//お客様物件条件.カーポート
			,IsBicycleParking__c	//お客様物件条件.駐輪場
			,IsBikeStorage__c		//お客様物件条件.バイク可
			,IsSmallBike__c			//お客様物件条件.小型バイク
			,IsMediumBike__c		//お客様物件条件.中型バイク
			,IsLargeBike__c			//お客様物件条件.大型バイク
			,IsElevator__c			//お客様物件条件.エレベーター
			,IsDeliveryBox__c		//お客様物件条件.宅配ボックス
			,IsCounterKitchen__c	//お客様物件条件.カウンターキッチン
			,IsSystemKitchen__c		//お客様物件条件.システムキッチン
			,IsGasStove__c			//お客様物件条件.ガスコンロ
			,IsElectricStove__c		//お客様物件条件.電気コンロ
			,IsInductionHeating__c	//お客様物件条件.IHコンロ
			,IsTwoGasStove__c		//お客様物件条件.コンロ2口
			,IsMoreGasStove__c		//お客様物件条件.コンロ3口以上
			,IsSepalateBathAndRestroom__c	//お客様物件条件.バス・トイレ別
			,IsAditionalBoiling__c			//お客様物件条件.追焚機能
			,IsDehumidifierForBathroom__c	//お客様物件条件.浴室乾燥機
			,IsWashlet__c					//お客様物件条件.温水洗浄便座
			,IsShowerWashBasin__c			//お客様物件条件.シャワー付き洗面台
			,IsRegalLavatory__c	//お客様物件条件.洗面所独立
			,IsInnerLandry__c	//お客様物件条件.室内洗濯機置場
			,IsTownGas__c		//お客様物件条件.都市ガス
			,IsPropaneGas__c	//お客様物件条件.プロパンガス
			,IsAllElectric__c	//お客様物件条件.オール電化
			,IsAirConditioner__c//お客様物件条件.エアコン
			,IsFloorHeating__c	//お客様物件条件.床暖房
			,IsShoesBox__c		//お客様物件条件.シューズボックス
			,IsShoeCloak__c		//お客様物件条件.シューズクローク
			,IsWalkInCloset__c	//お客様物件条件.ウォークインクローゼット
			,IsTrunkRoom__c		//お客様物件条件.トランクルーム
			,IsBSAntenna__c		//お客様物件条件.BSアンテナ
			,IsCSAntenna__c		//お客様物件条件.CSアンテナ
			,IsCATV__c				//お客様物件条件.CATV
			,IsInternetFree__c		//お客様物件条件.ネット使用料無料
			,IsMonitorIntercom__c	//お客様物件条件.モニター付きインターホン
			,IsAutoLock__c			//お客様物件条件.オートロック
			,IsFurniture__c			//お客様物件条件.家具付き
			,IsHomeAppliance__c		//お客様物件条件.家電付き
			,IsNoGuarantor__c		//お客様物件条件.保証人不要
			,IsNonGuaranteeidCompany__c	//お客様物件条件.保証会社不要
			,IsMusicalInstruments__c	//お客様物件条件.楽器相談可
			,IsForeigner__c				//お客様物件条件.外国人契約可
			,IsOfficeAvailable__c		//お客様物件条件.事務所利用可
			,IsWelfareAvailable__c		//お客様物件条件.生活保護契約可
			,IsPet__c			//お客様物件条件.ペット可
			,IsLargePet__c		//お客様物件条件.ペット(大型犬)
			,IsMiddlePet__c		//お客様物件条件.ペット(中型犬)
			,IsSmallPet__c		//お客様物件条件.ペット(小型犬)
			,IsCat__c			//お客様物件条件.ペット(猫)
			,IsOtherPet__c		//お客様物件条件.ペット(その他)
			,IsTwoTenant__c		//お客様物件条件.2人入居可
			,IsRoomShare__c		//お客様物件条件.ルームシェア可
			,IsIppambutsu__c	//お客様物件条件.一般物
			,IsElderly__c		//お客様物件条件.高齢者歓迎
			,IsWoman__c			//お客様物件条件.女性限定
			,IsStudent__c		//お客様物件条件.学生限定マンション
			,CarCount__c		//お客様物件条件.台数
			,ParkingFeeLimit__c	//お客様物件条件.1台当たりの料金上限
			,Parking__c			//お客様物件条件.駐車場
			//▼問合せ415で追加
			,DesiredJuniorHighSchoolArea__c					//お客様物件条件.中学校希望学区（エリア）
			,DesiredJuniorHighSchoolArea__r.SchoolArea__c	//お客様物件条件.中学校希望学区（エリア）.希望学区（エリア）
			,DesiredElementarySchoolArea__c					//お客様物件条件.小学校希望学区（エリア）
			,DesiredElementarySchoolArea__r.SchoolArea__c	//お客様物件条件.小学校希望学区（エリア）.希望学区（エリア）
		FROM AccountPropertyConditions__c
		WHERE Account__c =:accountId AND IsDeleted__c = FALSE
		ORDER BY CreatedDate ASC];

		return accountPCList;
	}
	// ▲2021.10.08 No.307 対応で追加

    /**
     * 検索処理（対応）
     * 引数によって内容を絞り込んだ一覧を取得する。
     * 引数　　：　accountId String 取引先Id
     *     　　：  corresponds String 対応ID
     * 戻り値　：  List<Correspond__c> 対応のデータ
     */
    private List<Correspond__c> selectCorrespondInfo(String accountId,String corresponds ){
        // 検索SQL作成
        String sql = CommonConst.STRING_EMPTY;
        sql += 'SELECT Id ';                      // 対応.Id（非表示）
        sql += '      ,SystemModstamp';           // SystemModstamp
        sql += '      ,Name ';                    // 対応.名前
        sql += '      ,Status__c ';               // 対応.ステータス
        sql += '      ,Event__c ';                // 対応.イベント
        sql += '      ,EventDateTime__c ';        // 対応.イベント時刻
        sql += '      ,AccountId__c ';            // 対応.取引先
        sql += '      ,AccountId__r.SystemModstamp ';        // 対応.取引先.SystemModstamp
		sql += '	  ,AccountId__r.RecordTypeId ';// 対応.取引先.レコードタイプ 2021.10.08 No.307 対応で追加
        sql += '      ,EchoStaff__c ';            // 対応.担当者（反響
        sql += '      ,ShopStaff__c ';            // 対応.担当者（店舗）
        sql += '      ,EchoShop__c ';             // 対応.反響担当店舗
        sql += '      ,VisitShop__c ';            // 対応.来店担当者
        sql += '      ,StaffSupportedFlg__c ';    // 対応.スタッフ対応フラグ
        sql += '      ,SendMailDate__c                  ';   // メール送信日時
        sql += '      ,ReceiveMailDatePortal__c         ';   // メール受信日時（ポータル）
        sql += '      ,ReceiveMailDateOther__c          ';   // メール受信日時（その他）
        sql += '      ,PhoneIncomingDate__c             ';   // 電話着信日時
        sql += '      ,PhoneOutgoingDate__c             ';   // 電話発信日時
        sql += '      ,PhoneAbsenceDate__c              ';   // 電話不在日時
        sql += '      ,BrowseDate__c                    ';   // 閲覧日時
        sql += '      ,PursuitDissolveSettingDate__c    ';   // 追客解除設定日時
        sql += '      ,VisitDate__c                     ';   // 来店日（初回）
        sql += '      ,EchoStaff__r.Name      ';  // 対応.担当者（反響）.氏名
        sql += '      ,EchoStaff__r.Department';  // 対応.担当者（反響）.部署
        sql += '      ,ShopStaff__r.Name ';       // 対応.担当者（店舗）.氏名
        sql += '      ,ShopStaff__r.Department '; // 対応.担当者（店舗）ユーザ.部署
        sql += '      ,Property__r.Building__r.Name ';              // 対応.物件.建物.建物名
        sql += '      ,Property__r.Name       ';                    // 対応.物件.部屋番号
        sql += '      ,Property__r.LiveStatus__c ';                 // 対応.物件.現況
        sql += '      ,FirstInquiryProperty__r.Building__r.Name ';  // 対応.初回問合せ物件.建物名
        sql += '      ,FirstInquiryProperty__r.Name ';              // 対応.初回問合せ物件.部屋番号
        sql += '      ,FirstInquiryProperty__r.LiveStatus__c';      // 対応.初回問合せ物件.現況
        sql += '      ,IsUnnecessaryEchoAggregation__c ';           // 反響集約不要フラグ
        sql += '      ,District__c ';             // 対応.地区
        sql += '      ,Application__c ';        // 対応.申込ID
        sql += '      ,Property__c ';           // 対応.物件ID
        sql += '      ,PursuitDissolveDate__c ';    // 対応.追客解除日
        sql += '      ,StatusBeforePursuitHold__c ';    // 2020/6/16追加：保留前ステータス
        sql += '      ,AppointmentStartDate__c ';       // 2020/7/13追加：アポイント開始日0時
        sql += '      ,AccountId__r.Id ';               // 2020/7/13追加：取引先.Id（一覧表示日時メソッドでレコードを使用）
        sql += '      ,EventId__c';                     // 2020/9/18追加
		// ▼ 2021.11.30 LINE連携対応より、LINE会員を追加
		sql += '	,LineMember__c';
		// ▲ 2021.11.30
        sql += ' FROM  Correspond__c ';
        sql += ' WHERE AccountId__c = \'' + CommonUtil.escapeSingleQuotesEx(accountId) + '\'' ;

        // 全ての確認が完了している終了のステータスは表示対象外
        sql += ' AND  (not (Status__c in (\'' + CORRESPOND_STATUS_CLOSE + '\',\''  
                                              + CORRESPOND_STATUS_AGREEMENT + '\',\'' 
                                              + CORRESPOND_STATUS_ECHOAGGREGATION + '\')';
        sql += ' AND  ListViewDate__c >= ' + CommonUtil.getNow().formatGmt('yyyy-MM-dd\'T\'hh:mm:ss.SSS\'Z\'');   // 一覧表示日時
        sql += ' AND  IsSupportedListShow__c = true ';// 対応確認
        sql += ' AND  IsBrowseFlg__c = true ';// 閲覧フラグ
        sql += ' AND  StaffSupportedFlg__c = true )) ';// スタッフ対応フラグ

        // 引数に対応IDが入っているかどうかで条件を決める
        if (!string.isblank(corresponds)){
            sql += ' AND   Id = \'' + CommonUtil.escapeSingleQuotesEx(corresponds) + '\'';     //対応ID
        }

        sql += ' ORDER BY EventDateTime__c DESC ';
        return Database.query(sql);
    }

    /**
     * 検索処理（対応）
     * 終了した対応を非表示にした際に一覧がそれのみであった場合一覧に出なくなるため終了の1件を表示させる用
     * 引数　　：　accountId String 取引先Id
     * 戻り値　：  List<Correspond__c> 対応のデータ
     */
    private List<Correspond__c> selectCorrespondInfoAgentEnd(String accountId ){
        // 検索SQL作成
        String sql = CommonConst.STRING_EMPTY;
        sql += 'SELECT Id ';                      // 対応.Id（非表示）
        sql += '      ,SystemModstamp';           // SystemModstamp
        sql += '      ,Name ';                    // 対応.名前
        sql += '      ,Status__c ';               // 対応.ステータス
        sql += '      ,Event__c ';                // 対応.イベント
        sql += '      ,EventDateTime__c ';        // 対応.イベント時刻
        sql += '      ,AccountId__c ';            // 対応.取引先
        sql += '      ,AccountId__r.SystemModstamp ';        // 対応.取引先.SystemModstamp
		sql += '	  ,AccountId__r.RecordTypeId ';// 対応.取引先.レコードタイプ 2021.10.08 No.307 対応で追加
        sql += '      ,EchoStaff__c ';            // 対応.担当者（反響
        sql += '      ,ShopStaff__c ';            // 対応.担当者（店舗）
        sql += '      ,EchoShop__c ';             // 対応.反響担当店舗
        sql += '      ,VisitShop__c ';            // 対応.来店担当者
        sql += '      ,StaffSupportedFlg__c ';    // 対応.スタッフ対応フラグ
        sql += '      ,SendMailDate__c                  ';   // メール送信日時
        sql += '      ,ReceiveMailDatePortal__c         ';   // メール受信日時（ポータル）
        sql += '      ,ReceiveMailDateOther__c          ';   // メール受信日時（その他）
        sql += '      ,PhoneIncomingDate__c             ';   // 電話着信日時
        sql += '      ,PhoneOutgoingDate__c             ';   // 電話発信日時
        sql += '      ,PhoneAbsenceDate__c              ';   // 電話不在日時
        sql += '      ,BrowseDate__c                    ';   // 閲覧日時
        sql += '      ,EndDate__c                       ';   // 終了日時
        sql += '      ,PursuitDissolveSettingDate__c    ';   // 追客解除設定日時
        sql += '      ,EchoStaff__r.Name      ';  // 対応.担当者（反響）.氏名
        sql += '      ,EchoStaff__r.Department';  // 対応.担当者（反響）.部署
        sql += '      ,ShopStaff__r.Name ';       // 対応.担当者（店舗）.氏名
        sql += '      ,ShopStaff__r.Department '; // 対応.担当者（店舗）ユーザ.部署
        sql += '      ,Property__r.Building__r.Name ';              // 対応.物件.建物.建物名
        sql += '      ,Property__r.Name       ';                    // 対応.物件.部屋番号
        sql += '      ,Property__r.LiveStatus__c ';                 // 対応.物件.現況
        sql += '      ,FirstInquiryProperty__r.Building__r.Name ';  // 対応.初回問合せ物件.建物名
        sql += '      ,FirstInquiryProperty__r.Name ';              // 対応.初回問合せ物件.部屋番号
        sql += '      ,FirstInquiryProperty__r.LiveStatus__c';      // 対応.初回問合せ物件.現況
        sql += '      ,IsUnnecessaryEchoAggregation__c ';           // 反響集約不要フラグ
        sql += '      ,District__c ';             // 対応.地区
        sql += '      ,Application__c ';        // 対応.申込ID
        sql += '      ,Property__c ';           // 対応.物件ID
        sql += '      ,PursuitDissolveDate__c ';    // 対応.追客解除日
        sql += '      ,StatusBeforePursuitHold__c ';    // 2020/6/16追加：保留前ステータス
        sql += '      ,AppointmentStartDate__c ';       // 2020/7/13追加：アポイント開始日0時
        sql += '      ,AccountId__r.Id ';               // 2020/7/13追加：取引先.Id（一覧表示日時メソッドでレコードを使用）
        sql += '      ,EventId__c';                     // 2020/9/18追加
		// ▼ 2021.11.30 LINE連携対応より、LINE会員を追加
		sql += '	,LineMember__c ';
		// ▲ 2021.11.30
        
        sql += ' FROM  Correspond__c ';
        sql += ' WHERE AccountId__c = \'' + CommonUtil.escapeSingleQuotesEx(accountId) + '\'' ;
        sql += ' AND  (Status__c = \'' + CORRESPOND_STATUS_CLOSE + '\'' ;
        sql += ' OR   Status__c = \'' + CORRESPOND_STATUS_AGREEMENT + '\')' ;

        sql += ' ORDER BY EventDateTime__c DESC ';
        sql += ' LIMIT 1 ' ; 
        return Database.query(sql);
    }

    // 追加要望 追加 Start
    /**
     * 検索処理（紹介メール情報）
     * 引数によって内容を絞り込んだ一覧を取得する。
     * 引数　　：　accountId String 取引先Id
     * 戻り値　：　List<IntroductionMailInformation__c> 
     */
    private List<IntroductionMailInformation__c> selectintroMailInfo(String accountId){
        // 検索SQL作成
        String sql = CommonConst.STRING_EMPTY;
        sql += 'SELECT Id ';                            // Id
        sql += ' ,     Correspond__c ';                 // 対応 
        sql += ' ,     Account__r.IntroMailInfoStatus__c ';             // 紹介メール送信状況
        sql += ' ,     Account__r.IntroMailInfoFirstSendDatetime__c ';  // 紹介メール初回配信日時
        sql += ' ,     Account__r.IntroMailInfoLastSendDatetime__c ';   // 紹介メール最終配信日時
        sql += ' ,     Account__r.IntroMailInfoPursuitCount__c ';       // 紹介メール追客回数
        sql += ' ,     Correspond__r.ShopStaffName__c ';                // 対応．来店担当者
        sql += ' ,     Correspond__r.EchoStaffName__c ';                // 対応．反響担当者
        sql += ' ,     SystemModStamp ';                                // SystemModStamp
		// ▼ 2021.11.30 LINE連携対応より、送信区分を追加
		sql += ' ,	isSendLine__c ';
		sql += ' ,	IsSendType__c ';
		// ▲ 2021.11.30
        sql += ' FROM  IntroductionMailInformation__c ';              // 紹介メール情報

        sql += ' WHERE Account__c = \'' + CommonUtil.escapeSingleQuotesEx(accountId) + '\'' ;  // 取引先ID

        sql += ' LIMIT 1 ' ;       // 表示上限を設定

        // 検索実行
        return Database.query(sql);
    }
    // 追加要望 追加 End
    /**

    // ポータルサイト構築 追加 Start
    /**
     * 検索処理（本会員）
     * 引数によって内容を絞り込んだ一覧を取得する。
     * 引数　　：　accountId String 取引先Id
     * 戻り値　：　List<Member__c> 
     */
    private List<Member__c> selectMember(String accountId){
        // 検索SQL作成
        String sql = CommonConst.STRING_EMPTY;
        sql += 'SELECT Id ';                            // 本会員番号
        sql += ' ,     MemberId__c ';                   // 本会員．会員ID
        sql += ' ,     LastName__c ';                   // 本会員．姓 
        sql += ' ,     FirstName__c ';                  // 本会員．名
        sql += ' ,     Tell__c ';                       // 本会員．電話番号
        sql += ' ,     LastAccessDate__c ';             // 本会員．最終アクセス日時
        sql += ' ,     JoinDate__c ';                   // 本会員．入会日
        sql += ' ,     QuitDate__c ';                   // 本会員．退会日
        
        sql += ' FROM  Member__c ';                     // 本会員

        sql += ' WHERE Account__c = \'' + CommonUtil.escapeSingleQuotesEx(accountId) + '\'' ;  // 取引先ID

        sql += ' ORDER BY LastAccessDate__c DESC ';     // 本会員．最終アクセス日時（降順）
        sql += ' LIMIT 1000 ' ;       // 表示上限を設定

        // 検索実行＆結果返却
        return Database.query(sql);
    }
    // ポータルサイト構築 追加 End
    /**
     * 検索処理（お気に入り物件）
     * 引数によって内容を絞り込んだ一覧を取得する。
     * 引数　　：　accountId String 取引先Id
     *     　　：　Id String お気に入り物件ID
     * 戻り値　：　Boolean 件数の取得有無
     */
    private List<FavoriteProperty__c> selectFavoritePropertyInfo(String accountId,String Id ){
        // 検索SQL作成
        String sql = CommonConst.STRING_EMPTY;
        sql += 'SELECT Id ';                            // お気に入り番号（非表示）
        sql += '      ,SystemModstamp';                 // SystemModstamp
        sql += '      ,Property__c ';                   // お気に入り物件.物件コード(非表示)
        sql += '      ,Account__c ';                    // お気に入り物件.取引先(非表示)
        sql += '      ,Property__r.Building__c ';       // お気に入り物件.物件.建物ID
        sql += '      ,Property__r.Building__r.Name ';  // お気に入り物件.物件.建物.建物名
        sql += '      ,Property__r.Name ';              // お気に入り物件.物件.部屋番号
        sql += '      ,PropertyStatus__c ';             // お気に入り物件.状況
        sql += '      ,Address__c ';                    // お気に入り物件.住所
        sql += '      ,RentFee__c ';                    // お気に入り物件.賃料
        sql += '      ,NearestStation__c ';             // お気に入り物件.最寄駅
        sql += '      ,BuildingYM__c ';                 // お気に入り物件.築年
        sql += '      ,ParkingFee__c ';                 // お気に入り物件.駐車場
        sql += '      ,Status__c ';                     // お気に入り物件.ステータス
        sql += '      ,PreviewImpression__c ';          // お気に入り物件.内見感想
        sql += '      ,Property__r.FloorPlan__c ';      // 物件.間取り

        sql += ' FROM  FavoriteProperty__c ';           // お気に入り物件

        sql += ' WHERE Account__c = \'' + CommonUtil.escapeSingleQuotesEx(accountId) + '\'' ;  // 取引先ID
        sql += '	AND Property__c != null' ;  //2022.01.12 No.489 お気に入り物件.物件が存在する
        if (!string.isBlank(Id)){
            // お気に入り物件がセットされている場合、一意で取得する。
            sql += ' AND Id = \'' + CommonUtil.escapeSingleQuotesEx(Id) + '\'' ;  // お気に入り物件ID
        }

        sql += ' ORDER BY BuildingYM__c DESC ';              // お気に入り物件.築年
        sql += ' ,        Property__r.Building__r.Name ASC ';   // お気に入り物件.物件.建物.建物名
        sql += ' ,        Property__r.Name ASC ';               // お気に入り物件.物件.部屋番号

        // 検索実行＆結果返却
        return Database.query(sql);
    }

    /**
     * 検索処理（条件完全一致物件）
     * 引数によって内容を絞り込んだ一覧を取得する。
     * 引数　　：　accountId String 取引先Id
     *     　　：　Id String 条件完全一致物件ID
     * 戻り値　：　Boolean 件数の取得有無
     */
    private List<ExactConditionMatchProperty__c> selectExactConditionMatchPropertyInfo(String accountId){
        // 検索SQL作成
        String sql = CommonConst.STRING_EMPTY;
        sql += 'SELECT Id ';                            // 条件完全一致物件番号（非表示）
        sql += '      ,SystemModstamp';                 // SystemModstamp
        sql += '      ,Property__c ';                   // 条件完全一致物件.物件コード(非表示)
        sql += '      ,Account__c ';                    // 条件完全一致物件.取引先(非表示)
        sql += '      ,Property__r.Building__c ';       // 条件完全一致物件.物件.建物ID
        sql += '      ,Property__r.Building__r.Name ';  // 条件完全一致物件.物件.建物.建物名
        sql += '      ,Property__r.Name ';              // 条件完全一致物件.物件.部屋番号
        sql += '      ,PropertyConditionsName__c ';     // 条件完全一致物件.物件条件名
        sql += '      ,PropertyStatus__c ';             // 条件完全一致物件.状況
        sql += '      ,Address__c ';                    // 条件完全一致物件.住所
        sql += '      ,RentFee__c ';                    // 条件完全一致物件.賃料
        sql += '      ,NearestStation__c ';             // 条件完全一致物件.最寄駅
        sql += '      ,BuildingYM__c ';                 // 条件完全一致物件.築年
        sql += '      ,ParkingFee__c ';                 // 条件完全一致物件.駐車場
        sql += '      ,Status__c ';                     // 条件完全一致物件.ステータス
        sql += '      ,IntroductionImpression__c ';     // 条件完全一致物件.紹介感想

        sql += ' FROM  ExactConditionMatchProperty__c ';           // 条件完全一致物件

        sql += ' WHERE Account__c = \'' + CommonUtil.escapeSingleQuotesEx(accountId) + '\'' ;  // 取引先ID

        sql += ' ORDER BY BuildingYM__c DESC ';              // 条件完全一致物件.築年
        sql += ' ,        Property__r.Building__r.Name ASC ';   // 条件完全一致物件.物件.建物.建物名
        sql += ' ,        Property__r.Name ASC ';               // 条件完全一致物件.物件.部屋番号

        // 検索実行＆結果返却
        return Database.query(sql);
    }

    /**
     * 空室予約物件を取得
     * @param String condAccountId 取引先.ID
     * @return List<VacancyReservationProperty__c> 空室予約物件
     */
    private List<VacancyReservationProperty__c> selectVacancyReservationProp(String condAccountId){

        // クエリを取得
        String sql = CommonConst.STRING_EMPTY;
        sql += 'SELECT Id ';                            // ID
        sql += '       , Building__r.Name ';            // 建物名
        sql += '       , Building__r.Address__c ';      // 住所
        sql += '       , VacancyStatus__c ';            // 空室状況
        sql += '       , PropertyFloorPlan__c ';        // 物件間取り
        sql += '       , SystemModstamp ';              // SystemModstamp
        sql += 'FROM VacancyReservationProperty__c ';
        sql += 'WHERE Account__c = \'' + CommonUtil.escapeSingleQuotesEx(condAccountId) + '\' ';
        sql += 'ORDER BY Building__r.Name ';

        // クエリを実行
        List<VacancyReservationProperty__c> vacancyReservationPropList = Database.query(sql);
        if (vacancyReservationPropList.isEmpty()) {
            vacancyReservationPropList = new List<VacancyReservationProperty__c>();
        }
        
        return vacancyReservationPropList;
    }
    
    /**
     * 検索処理（対応履歴：対応明細）
     * 引数によって内容を絞り込んだ一覧を取得する。
     * 引数　　：　accountId String 取引先Id
     * 戻り値　：　List<CorrespondDetail__c> 対応明細
     */
    private List<CorrespondDetail__c> selectCorrespondDetailInfo(String accountId){
        // 検索SQL作成
        String sql = CommonConst.STRING_EMPTY;
        sql += 'SELECT Id ';                                // 対応明細.活動ID（非表示）
        sql += '      ,CorrespondType__c ';                 // 対応明細.対応種別
        sql += '      ,SupportedTitle__c ';                 // 対応明細.対応表題
        sql += '      ,MailType__c ';                       // 対応明細.メール種別
        sql += '      ,Corresponds__r.District__c ';        // 対応明細.対応.地区
        sql += '      ,Staff__r.name ';                     // 対応明細.担当者.氏名
        sql += '      ,Shop__r.name ';                      // 対応明細.店舗
        sql += '      ,SupportedDateTime__c ';              // 対応明細.対応日時
        sql += '      ,SupportedContent__c ';               // 対応明細.対応内容
        sql += '      ,Email__c ';                          // 対応明細.メール
		sql += '	  ,PhoneStatus__c ';                    // 対応明細.電話状況 // 2022.04.20 No0768 対応で追加
        sql += '      ,Corresponds__r.Application__c ';             // 申込ID（非表示）
        sql += '      ,EchoMail__c ';                       // 対応明細.反響メールId
        // ▼ 2021.09.29 No.489 取得項目追加
        sql += '      ,FirstInquiryPropertyShowFlg__c';                    // 対応明細.初回問合せ物件表示
        sql += '      ,Property__c';                                       // 対応明細.物件
        sql += '      ,Property__r.PropertyCode__c';                       // 対応明細.物件.物件コード
        sql += '      ,Property__r.Building__r.Address__c';                // 対応明細.物件.建物.住所
        sql += '      ,Property__r.Building__r.TrainRoute1__r.Name';       // 対応明細.物件.建物.沿線１
        sql += '      ,Property__r.Building__r.Station1__r.Name';          // 対応明細.物件.建物.駅１
        sql += '      ,Property__r.Building__r.StationWalkTimeFormat1__c'; // 対応明細.物件.建物.駅までの時間（分）１
        sql += '      ,Property__r.FloorPlan__c';                          // 対応明細.物件.間取り
        sql += '      ,Property__r.RentFee__c';                            // 対応明細.物件.賃料
        sql += '      ,CreatedDate ';                                      // 対応明細.作成日
        // ▲ 2021.09.29 No.489 
        sql += '      ,EchoMail__r.FromPotalSite__r.AbbreviationName__c  '; // 反響メール.Fromポータルサイト.サイト名(略称)
        sql += '      ,EchoMail__r.InquiryDateTime__c  ';                   // 反響メール.お問合せ日時
        sql += '      ,EchoMail__r.PropertyCode__c  ';                      // 反響メール.物件コード
        sql += '      ,EchoMail__r.PropertURL__c  ';                        // 反響メール.物件URL
        sql += '      ,EchoMail__r.PropertyAddress__c  ';                   // 反響メール.所在地
        sql += '      ,EchoMail__r.ClosestStation__c ';                     // 反響メール.最寄駅
        sql += '      ,EchoMail__r.WalkTime__c  ';                          // 反響メール.徒歩
        sql += '      ,EchoMail__r.RoomLayout__c  ';                        // 反響メール.間取り
        sql += '      ,EchoMail__r.RentFee__c ';                            // 反響メール.賃料
        sql += '      ,EchoMail__r.InquiryContent__c ';                     // 反響メール.お問合せ内容
		sql += '	  ,EchoMail__r.LineId__c ';								// 反響メール.LINE＠ID  // 2022.04.20 No0768 対応で追加

        sql += '      ,PortalSiteUrl__c ';                  // 対応明細.ポータルサイトURL
        sql += '      ,Corresponds__c ';    // 対応Id

        sql += ' FROM  CorrespondDetail__c ';                              // 対応明細
        sql += ' WHERE Corresponds__r.AccountId__c = \'' + CommonUtil.escapeSingleQuotesEx(accountId) + '\'' ;  // 取引先ID
		//▼ 2022.01.12 No.489 対応で地区で絞り込む処理を削除（移動）
        sql += ' ORDER BY SupportedDateTime__c DESC ';            // 対応明細.対応日時
        sql += ' ,Name DESC ';            // 対応明細.対応明細番号       
        sql += ' LIMIT :correspondDetailLimit ' ;                 // 表示上限を設定

        // 検索実行＆結果返却
        return Database.query(sql);

    }

    /**
     * 検索処理（申込）
     * 引数によって内容を絞り込んだ一覧を取得する。
     * 引数　　：　accountId String 取引先Id
     * 戻り値　：　Boolean 件数の取得有無
     */
    private List<Application__c>  selectApplicationInfo(String accountId ){
        // 検索SQL作成
        String sql = CommonConst.STRING_EMPTY;
        sql += 'SELECT Id ';                                    // 申込.申込ID（非表示）
        sql += '      ,Property__r.Building__r.Name ';          // 申込.物件.建物.建物名
        sql += '      ,SystemModstamp';                         // 申込.System Modstamp
        sql += '      ,Property__r.Name ';                      // 申込.物件.部屋番号
        sql += '      ,ApplicationDate__c ';                    // 申込.申込日
        sql += '      ,TenantDesiredDate__c ';                  // 申込.入居希望日
        sql += '      ,ApplicationType__c ';                    // 申込.申込種別
        sql += '      ,FullName__c ';                           // 申込.名前
        sql += '      ,CompanyName__c ';                        // 申込.会社名
        sql += '      ,TenantCount__c ';                        // 申込.入居人数（本人含め）
        sql += '      ,JointGuarantorFullName__c ';             // 申込.連帯保証人氏名

        sql += ' FROM  Application__c ';                        // 申込
        sql += ' WHERE Account__c = \'' + CommonUtil.escapeSingleQuotesEx(accountId) + '\'' ;    // 取引先ID
        sql += ' ORDER BY ApplicationDate__c DESC ';            // 申込.申込日

        // 検索実行＆結果返却
        return Database.query(sql);

    }

    /**
     * 検索処理（反響メール）
     * 引数によって内容を絞り込んだ一覧を取得する。
     * 引数　　：  Id String 反響メールId
     * 戻り値　：  List<EchoMail__c> 反響メールのデータ
     */
    private List<EchoMail__c> selectEchoMailInfo(String Id ){
        // 検索SQL作成
        String sql = CommonConst.STRING_EMPTY;
        sql += 'SELECT Id ';                                    // 反響メール.番号（非表示）
        sql += '      ,FromPotalSite__r.AbbreviationName__c ';  // 反響メール.Fromポータルサイト.サイト名(略称)
        sql += '      ,InquiryDateTime__c ';                    // 反響メール.お問合せ日時
        sql += '      ,PropertyCode__c ';                       // 反響メール.物件コード
        sql += '      ,PropertURL__c ';                         // 反響メール.物件URL
        sql += '      ,PropertyAddress__c ';                    // 反響メール.所在地
        sql += '      ,ClosestStation__c ';                     // 反響メール.最寄駅
        sql += '      ,WalkTime__c ';                           // 反響メール.徒歩
        sql += '      ,RoomLayout__c ';                         // 反響メール.間取り
        sql += '      ,RentFee__c ';                            // 反響メール.賃料
        sql += '      ,InquiryContent__c ';                     // 反響メール.お問合せ内容
        sql += ' FROM  EchoMail__c ';                           // 反響メール
        sql += ' WHERE Id = \'' + CommonUtil.escapeSingleQuotesEx(Id) + '\'' ;                   // 反響メールID
        sql += ' ORDER BY InquiryDateTime__c DESC ';            // 反響メール.お問合せ日時

        return Database.query(sql);
    }

    /**
     * 地区リストの設定
     * 引数　　：　accountId String 取引先Id
     * 戻り値　：　Boolean 件数の取得有無
     */
     private List<CorrespondDetail__c> selectDistrictGroup(String accountId){
        String sql = CommonConst.STRING_EMPTY;

        sql += ' SELECT   Corresponds__r.District__c ';    // 地区
        sql += ' FROM     CorrespondDetail__c ';
        sql += ' WHERE    Corresponds__r.AccountId__c = \'' + CommonUtil.escapeSingleQuotesEx(accountId) + '\'' ;      // 取引先ID
        sql += ' ORDER BY Corresponds__r.District__c ' ;      // 地区
         
        // 検索実行＆結果返却
        return Database.query(sql);

     }

    /**
     * 反響の対応データ取得
     * 引数　　：　CorrespondId Id 対応Id
     * 　　　　：　getEchoFirstFlg Boolean 取得対象データフラグ（True：反響先、False：反響元）
     * 戻り値　：　List<Correspond__c> 反響の対応データ
     */
    private List<Correspond__c> selectEchoAggregation(Id CorrespondId,Boolean getEchoFirstFlg){
        List<Correspond__c> correspondList = new List<Correspond__c>();

        String sql = CommonConst.STRING_EMPTY;

        sql += ' SELECT Id  ';
        sql += ' ,      Status__c ';                 // ステータス
        sql += ' ,      EchoStaff__c ';              // 担当者（反響）
        sql += ' ,      EchoShop__c ';               // 反響担当店舗
        sql += ' ,      PortalSite__c ';             // ポータルサイト
        sql += ' ,      District__c ';               // 地区
        sql += ' ,      PortalSiteUrl__c ';          // ポータルサイトURL
        sql += ' ,      FirstInquiryProperty__c ';   // 初回問合せ物件
        sql += ' ,      FirstInquiryMeans__c ';      // 初回問合せ方法
        sql += ' ,      ReceiveMailDatePortal__c ';  // メール受信日時（ポータル）
        // ▼問合せ323で追加
        sql += ' ,      EventDateTime__c ';          // イベント時刻
        sql += ' ,      Remarks__c ';                // 備考
        // ▲問合せ323で追加
		// ▼ 2022.1.7 LINE連携対応より、LINE会員を追加
		sql += ' ,	LineMember__c ';
		// ▲ 2022.1.7
        sql += ' FROM   Correspond__c ';
        if(getEchoFirstFlg){
            // 反響集約先の取得
            sql += ' WHERE  Id != :CorrespondId ';       // 反響元の対応IDを含まない
            sql += ' AND    AccountId__c = :accountId '; // 現在の取引先
            sql += ' AND    Status__c NOT IN(:CORRESPOND_STATUS_CLOSE,:CORRESPOND_STATUS_AGREEMENT,:CORRESPOND_STATUS_ECHOAGGREGATION) '; // 有効なステータスのみ
            sql += ' ORDER BY EventDateTime__c DESC ';   // イベント時刻の降順
        }else{
            // 反響集約元の取得
            sql += ' WHERE  Id = :CorrespondId ';
        }
        sql += ' LIMIT 1 ';

        correspondList = Database.query(sql);
        return correspondList;
    }

	// ▼ 2022.1.29 LINE連携対応より、LINE会員の取得処理を追加
	/**
	 * LINE会員の取得
	 * @param Id condAccountId 取引先ID
	 * @return LineMember__c LINE会員
	 */
	private LineMember__c selectLineMember(Id condAccountId) {

		List<LineMember__c> lineMemberList = [
			SELECT Id
			FROM LineMember__c
			WHERE Account__c = :condAccountId
		];

		if (lineMemberList.isEmpty()) {
			return new LineMember__c();
		}

		return lineMemberList[0];
	}
	// ▲ 2022.1.29

// -----------------------------------------------------------------------------------------------
// 画面出力系クラス
// -----------------------------------------------------------------------------------------------
    /**
     * 画面表示用内部クラス(取引先)
     */
    public class screenAccount {
        private Correspond__c targetAccountRecord;    //レコード本体（対応）

        //以下、画面用の項目
        public String Id { get; set; }                           // 取引先.Id（非表示）
        public Datetime SystemModstamp { get; set; }             // SystemModstamp 
        public String RecordTypeId { get;set; }                  // 取引先.レコードタイプ
        public String Name { get; set; }                         // 取引先.取引先名
        public String LastName { get; set; }                     // 取引先.姓  
        public String FirstName { get; set; }                    // 取引先.名  
        public String NameKana { get; set; }                     // 取引先.取引先名（カナ）
        public String LastNameKana { get; set; }                 // 取引先.姓（カナ）
        public String FirstNameKana { get; set; }                // 取引先.名（カナ）
        public String  Sex { get; set; }                         // 取引先.性別
        public Date    Birthdate { get; set; }                   // 取引先.生年月日
        public Decimal  Age { get; set; }                        // 取引先.年齢
        public String  PostalCode { get; set; }                  // 取引先.郵便番号
        public String  Situation { get; set; }                   // 問合せNo341で追加 取引先.状況
        public Boolean EchoTelephoneFlag { get; set; }           // 問合せNo341で追加 取引先.電話反響登録済みフラグ
        public Boolean EchoLineFlag { get; set; }                // 問合せNo411で追加 取引先.LINE反響登録済みフラグ
        public Boolean EchoLiveroFlag { get; set; }              // 問合せNo411で追加 取引先.リベロ反響登録済みフラグ
        public String  State { get; set; }                       // 取引先.都道府県    
        public String  City { get; set; }                        // 取引先.住所１（市区町村）
        public String  Street { get; set; }                      // 取引先.住所２（番地）
        public String  CompanyName { get; set; }                 // 取引先.会社名
        public String  CompanyNameKana { get; set; }             // 取引先.会社名（カナ）
        public String  CompanyPostalCode { get; set; }           // 取引先.会社 郵便番号
        public String  CompanyState { get; set; }                // 取引先.会社 都道府県
        public String  CompanyCity { get; set; }                 // 取引先.会社 住所１
        public String  CompanyStreet { get; set; }               // 取引先.会社 住所２
        public String  CompanyIndustries { get; set; }           // 取引先.会社 業種
        public String  CorporationRepresentative { get; set; }   // 取引先.担当者（法人用）
        public String  Department { get; set; }                  // 取引先.所属部署
        public String  Post { get; set; }                        // 取引先.役職
        public String  Comment { get; set; }                     // 取引先.コメント
        public String  Phone { get; set; }                       // 取引先.電話番号
        public String  Phone2 { get; set; }                      // 取引先.電話番号２
        public String  Phone3 { get; set; }                      // 取引先.電話番号３
        public String  Email { get; set; }                       // 取引先.メール
        public String  Email2 { get; set; }                      // 取引先.メール２
        public String  Email3 { get; set; }                      // 取引先.メール３
        public Boolean  IsMergeCompletedFlag { get;set; }        // 取引先.名寄せ完了フラグ
        public Boolean  IsMergeUnnecessaryFlag { get;set; }      // 取引先.名寄せ不要フラグ
        public String  HomePhone   { get; set; }                 // 取引先.自宅TEL
        public String  JobType { get; set; }                     // 取引先.職種
        public String  Affiliation { get; set; }                 // 取引先.勤務先/学校
        public String  Fax { get; set; }                            // 取引先.Fax
        public string  AccountIndustry { get;set; }              // 取引先.勤務先/学校 業種
        public String  AffiliationPhone { get; set; }            // 取引先.勤務先/学校 電話番号
        public String  AffiliationPostalCode { get; set; }       // 取引先.勤務先/学校 郵便番号
        public String  AffiliationState { get; set; }            // 取引先.勤務先/学校 都道府県
        public String  AffiliationAddress { get; set; }          // 取引先.勤務先/学校_住所
        public String  AffiliationCity { get; set; }             // 取引先.勤務先/学校 住所１（市区町村）
        public String  AffiliationStreet { get; set; }           // 取引先.勤務先/学校 住所２（番地）
        public Date  VisitsDate { get; set; }                  // 取引先.来店日
        public String  VisitsTrigger { get; set; }               // 取引先.来店のきっかけ
        public String  PortalSite { get; set; }                  // 取引先.ポータルサイト
        public String  SiteView { get; set; }                    // 取引先.事前にネット
        public String  Introducer { get; set; }                  // 取引先.紹介者
        public String  HomeMovingReason { get; set; }            // 取引先.引越理由
        public String  Dissatisfaction { get; set; }             // 取引先.不満理由
        public String  ContractType { get; set; }                // 取引先.契約形態
        public String  ProxyCompanyName { get; set; }            // 取引先.代理会社名
        public String  HomeMovingSeason { get; set; }            // 取引先.引越時期
        public Date  HomeMovingDate { get; set; }              // 取引先.引越時期（日付）までに
        public String  TenantCount { get; set; }                 // 取引先.入居人数
		// ▼2021.10.08 No.307 対応で削除（307オブジェクト変更内容の項目）

        public String  CompanyEstablishmentYear { get; set; }     // 取引先.設立(年)
        public String  CompanyEstablishmentMonth { get; set; }    // 取引先.設立(月)
        public String  CompanyCapital { get; set; }               // 取引先.資本金
        public String  CompanyPhone { get; set; }                 // 取引先.法人電話番号
        public String  CorporationRepresentativePhone { get; set; }// 取引先.担当者電話番号  

        public String  IntroMailInfoStatus { get; set; }          // 取引先.紹介メール配信状況  //追加要望　追加
		// ▼2021.10.08 No.307 対応で削除（307オブジェクト変更内容の項目）
		
		// ▼ 2021.11.30 LINE連携対応より、LINE会員IDを追加
		public Id	lineMemberId	{get; set;}
		// ▲ 2021.11.30

        //コンストラクタ
        public screenAccount(){
            this.IsMergeCompletedFlag  =  true; // 取引先.名寄せ完了フラグ
            this.IsMergeUnnecessaryFlag = false; // 取引先.名寄せ完了不要フラグ
            this.ContractType  =  '個人契約';  // 取引先.契約形態
			// ▼2021.10.08 No.307 対応で削除（307オブジェクト変更内容の項目）

        }

        //コンストラクタ
        public screenAccount(Account targetAccountRecord){
            this.Id  =  targetAccountRecord.Id;  // 取引先.Id（非表示）
            this.SystemModstamp = targetAccountRecord.SystemModstamp; // SystemModstamp
            this.RecordTypeId = targetAccountRecord.RecordTypeId;   // 取引先.レコードタイプ
            this.Name  =  targetAccountRecord.Name;  // 取引先.取引先名
            this.LastName =  targetAccountRecord.LastName__c;     // 取引先.姓  
            this.FirstName =  targetAccountRecord.FirstName__c;   // 取引先.名  
            this.NameKana  =  targetAccountRecord.NameKana__c;  // 取引先.取引先名（カナ）
            this.LastNameKana =  targetAccountRecord.LastNameKana__c;    // 取引先.姓（カナ）
            this.FirstNameKana =  targetAccountRecord.FirstNameKana__c;  // 取引先.名（カナ）
            this.Sex  =  targetAccountRecord.Sex__c;  // 取引先.性別
            this.Birthdate            = targetAccountRecord.Birthdate__c;  // 取引先.生年月日
            this.Age  =  targetAccountRecord.Age__c;  // 取引先.年齢
            this.PostalCode  =  targetAccountRecord.PostalCode__c;  // 取引先.郵便番号
            this.Situation = targetAccountRecord.Situation__c;  //問合せNo341で追加　取引先.状況
            this.EchoTelephoneFlag = targetAccountRecord.EchoTelephoneFlag__c;  //問合せNo341で追加　取引先.反響電話登録済みフラグ
            this.EchoLineFlag = targetAccountRecord.EchoLineFlag__c; // 問合せNo411で追加 取引先.LINE反響登録済みフラグ
        	this.EchoLiveroFlag = targetAccountRecord.EchoLiveroFlag__c; // 問合せNo411で追加 取引先.リベロ反響登録済みフラグ
            this.State  =  targetAccountRecord.State__c;  // 取引先.都道府県
            this.City  =  targetAccountRecord.City__c;  // 取引先.住所１（市区町村）
            this.Street = targetAccountRecord.Street__c;  // 取引先.住所２（番地）
            this.CompanyName  =  targetAccountRecord.CompanyName__c;  // 取引先.会社名
            this.CompanyNameKana  =  targetAccountRecord.CompanyNameKana__c;  // 取引先.会社名（カナ）
            this.CompanyPostalCode  =  targetAccountRecord.CompanyPostalCode__c;  // 取引先.会社 郵便番号
            this.CompanyState = targetAccountRecord.CompanyState__c;           // 取引先.会社 都道府県
            this.CompanyCity  =  targetAccountRecord.CompanyCity__c;  // 取引先.会社 住所１
            this.CompanyStreet  =  targetAccountRecord.CompanyStreet__c;  // 取引先.会社 住所２
            this.CompanyIndustries  =  targetAccountRecord.CompanyIndustries__c;  // 取引先.会社 業種
            this.CorporationRepresentative=  targetAccountRecord.CorporationRepresentative__c;  // 取引先.担当者（法人用）
            this.Department  =  targetAccountRecord.Department__c;  // 取引先.所属部署
            this.Post  =  targetAccountRecord.Post__c;  // 取引先.役職
            this.Comment  =  targetAccountRecord.Comment__c;  // 取引先.コメント
            this.Phone  =  targetAccountRecord.Phone;   // 取引先.電話番号
            this.Phone2  =  targetAccountRecord.Phone2__c;  // 取引先.電話番号２
            this.Phone3  =  targetAccountRecord.Phone3__c;  // 取引先.電話番号３
            this.Email  =  targetAccountRecord.Email__c;  // 取引先.メール
            this.Email2  =  targetAccountRecord.Email2__c;  // 取引先.メール２
            this.Email3  =  targetAccountRecord.Email3__c;  // 取引先.メール３
            this.Affiliation  =  targetAccountRecord.Affiliation__c;  // 取引先.勤務先/学校
            this.AffiliationPhone =  targetAccountRecord.AffiliationPhone__c;           // 勤務先/学校 電話番号
            this.AffiliationPostalCode =  targetAccountRecord.AffiliationPostalCode__c;      // 勤務先/学校 郵便番号
            this.AffiliationState =  targetAccountRecord.AffiliationState__c;           // 勤務先/学校 都道府県
            this.AffiliationAddress =  targetAccountRecord.AffiliationAddress__c;         // 勤務先/学校_住所
            this.AffiliationCity =  targetAccountRecord.AffiliationCity__c;            // 勤務先/学校 住所１（市区町村）
            this.AffiliationStreet =  targetAccountRecord.AffiliationStreet__c;          // 勤務先/学校 住所２（番地）
            
            this.IsMergeCompletedFlag  =  targetAccountRecord.IsMergeCompletedFlag__c; // 取引先.名寄せ完了フラグ
            this.IsMergeUnnecessaryFlag  =  targetAccountRecord.IsMergeUnnecessaryFlag__c; // 取引先.名寄せ不要フラグ           
            this.HomePhone = targetAccountRecord.HomePhone__c;                    // 取引先.自宅TEL      
            this.Fax  =  targetAccountRecord.Fax;  // 取引先.Fax
            
            this.AccountIndustry = targetAccountRecord.AccountIndustry__c; // 取引先.業種（個人）
            this.JobType  =  targetAccountRecord.JobType__c;  // 取引先.職種
            this.VisitsDate            = targetAccountRecord.VisitsDate__c;  // 取引先.来店日
            this.VisitsTrigger  =  targetAccountRecord.VisitsTrigger__c;  // 取引先.来店のきっかけ
            this.PortalSite  =  targetAccountRecord.PortalSite__c;  // 取引先.ポータルサイト
            this.SiteView  =  targetAccountRecord.SiteView__c;  // 取引先.事前にネット
            this.Introducer  =  targetAccountRecord.Introducer__c;  // 取引先.紹介者
            this.HomeMovingReason  =  targetAccountRecord.HomeMovingReason__c;  // 取引先.引越理由
            this.Dissatisfaction  =  targetAccountRecord.Dissatisfaction__c;  // 取引先.不満理由
            this.ContractType  =  targetAccountRecord.ContractType__c;  // 取引先.契約形態
            this.ProxyCompanyName  =  targetAccountRecord.ProxyCompanyName__c;  // 取引先.代理会社名
            this.HomeMovingSeason  =  targetAccountRecord.HomeMovingSeason__c;  // 取引先.引越時期
            this.HomeMovingDate            = targetAccountRecord.HomeMovingDate__c;  // 取引先.引越時期（日付）までに
            this.TenantCount  =  CommonUtil.decimalToString(targetAccountRecord.TenantCount__c);  // 取引先.入居人数
			// ▼2021.10.08 No.307 対応で削除（307オブジェクト変更内容の項目）

            this.CompanyEstablishmentYear = targetAccountRecord.CompanyEstablishmentYear__c;            // 取引先.設立(年)
            this.CompanyEstablishmentMonth = targetAccountRecord.CompanyEstablishmentMonth__c;          // 取引先.設立(月)
            this.CompanyCapital = CommonUtil.decimalToString(targetAccountRecord.CompanyCapital__c);    // 取引先.資本金
            this.CompanyPhone = targetAccountRecord.CompanyPhone__c;                                    // 取引先.法人電話番号
            this.CorporationRepresentativePhone = targetAccountRecord.CorporationRepresentativePhone__c;// 取引先.担当者電話番号     

            this.IntroMailInfoStatus = targetAccountRecord.IntroMailInfoStatus__c;                      // 取引先．紹介メール配信状況　//追加要望
			// ▼ 2022.1.29 LINE専用画面の遷移条件の修正から削除
			// ▼ 2021.11.30 LINE連携対応より、LINE会員IDを追加
			this.lineMemberId = null;
			// ▲ 2021.11.30
			// ▲ 2022.1.29
        }
    }

    /**
     * 対応状況（対応）表示用内部クラス
     */
    public class screenCorrespond {
        private Correspond__c targetCorrespondRecord;    //レコード本体（対応）
        
        //以下、画面用の項目
        public Boolean isSelected          { get; set; }    // 選択行

        public String  Id                  { get; set; }    // 対応.Id
        public Datetime SystemModstamp     { get; set; }    // SystemModstamp
        public String  Name                { get; set; }    // 対応.名前
        public String  status              { get; set; }    // 対応.ステータス
        public String  event               { get; set; }    // 対応.イベント
        public String  eventDateTime       { get; set; }    // 対応.イベント時刻
        public Datetime accountSystemModstamp { get; set; } // 対応.取引先SystemModstamp
        public String  echoStaffName       { get; set; }    // 対応.担当者（反響）.氏名
        public String  echoStaffDepartment { get; set; }    // 対応.担当者（反響）.部署
        public String  outputEchoStaff     { get; set; }    // 対応状況表示用反響担当者
        public String  shopStaffName       { get; set; }    // 対応.担当者（店舗）.氏名
        public String  shopStaffDepartment { get; set; }    // 対応.担当者（店舗）.部署
        public String  outputShopStaff     { get; set; }    // 対応状況表示用来店担当者
        public String  District            { get; set; }    // 対応.地区
        public String  buildingName        { get; set; }    // 対応.建物.建物名
        public String  propertyName        { get; set; }    // 対応.物件.部屋番号
        public String  buildingproperty    { get; set; }    // 建物名+部屋番号
        public String  propertyLiveStatus  { get; set; }                // 対応.物件.現況
        public String application         { get; set; }    // 対応.申込(非表示)
        public String property            { get; set; }    // 対応.物件(非表示)
        public Datetime PursuitDissolveDate { get; set; }   // 対応.追客解除日 
        public Boolean echoAggregationFlg { get; set; }   // 反響集約フラグ
		// ▼ 2021.11.30 LINE連携対応より、"モーダル2対応種別表示フラグ"を追加
		public Boolean	isDispModal2CorrespondType	{get;set;}
		// ▲ 2021.11.30

        //コンストラクタ
        public screenCorrespond(Correspond__c targetCorrespondRecord){
            //レコードの連動
            this.targetCorrespondRecord = targetCorrespondRecord;   
            this.isSelected             = False;
            this.Id                     = targetCorrespondRecord.Id;                        // 対応.Id
            this.SystemModstamp         = targetCorrespondRecord.SystemModstamp;            // SystemModstamp
            this.Name                   = targetCorrespondRecord.Name;                      // 対応.名前
            this.Status                 = targetCorrespondRecord.Status__c;                 // 対応.ステータス
            this.Event                  = targetCorrespondRecord.Event__c;                  // 対応.イベント
            this.AccountSystemModstamp  = targetCorrespondRecord.AccountId__r.SystemModstamp;  // 対応.取引先.SystemModstamp
            if (targetCorrespondRecord.EventDateTime__c != null) {
                this.EventDateTime      = targetCorrespondRecord.EventDateTime__c.format('yyyy/MM/dd HH:mm', 'JST');    // 対応.イベント時刻
            }
            this.echoStaffName          = targetCorrespondRecord.EchoStaff__c;         
            this.echoStaffDepartment    = targetCorrespondRecord.EchoStaff__r.Department;   // 対応.担当者（反響）.部署
            this.outputEchoStaff        = targetCorrespondRecord.EchoStaff__r.Name;         // 対応.担当者（来店）.氏名    
            if (!string.isBlank(targetCorrespondRecord.EchoStaff__r.Department)){
                this.outputEchoStaff   += '(' + targetCorrespondRecord.EchoStaff__r.Department + ')';
            }
            this.shopStaffName          = targetCorrespondRecord.shopStaff__c; 
            this.shopStaffDepartment    = targetCorrespondRecord.ShopStaff__r.Department ;  // 対応.担当者（店舗）.部署
            this.outputShopStaff        = targetCorrespondRecord.shopStaff__r.Name;         // 対応.担当者（来店）.氏名     
            if (!string.isBlank(targetCorrespondRecord.ShopStaff__r.Department)){
                this.outputShopStaff   += '(' + targetCorrespondRecord.ShopStaff__r.Department + ')';
            }
            this.District               = targetCorrespondRecord.District__c;               // 対応.地区

            // 物件名の出力判定
            PropertyJudgment(targetCorrespondRecord);
            
            this.application            = targetCorrespondRecord.Application__c;                                    // 対応.申込Id
            this.property               = targetCorrespondRecord.Property__c;                                       // 対応.物件ID
            this.PursuitDissolveDate    = targetCorrespondRecord.PursuitDissolveDate__c;                            // 対応.追客解除日
            this.echoAggregationFlg     = !targetCorrespondRecord.IsUnnecessaryEchoAggregation__c;                  // 反響集約不要フラグ

			// ▼ 2021.11.30 LINE連携対応より、"モーダル2対応種別表示フラグ"を追加
			this.isDispModal2CorrespondType	= true;
			// ▲ 2021.11.30

            convertNull();
        }

        //null系を変換する
        public void convertNull() {            
            this.Id                     = String.isEmpty(this.Id)? CommonConst.STRING_EMPTY : this.Id;
            this.Name                   = String.isEmpty(this.Name)? CommonConst.STRING_EMPTY : this.Name;
            this.Status                 = String.isEmpty(this.Status)? CommonConst.STRING_EMPTY : this.Status;
            this.Event                  = String.isEmpty(this.Event)? CommonConst.STRING_EMPTY : this.Event;
            this.EventDateTime          = String.isEmpty(this.EventDateTime)? CommonConst.STRING_EMPTY : this.EventDateTime;
            this.echoStaffName          = String.isEmpty(this.echoStaffName)? CommonConst.STRING_EMPTY : this.echoStaffName;
            this.echoStaffDepartment    = String.isEmpty(this.echoStaffDepartment)? CommonConst.STRING_EMPTY : this.echoStaffDepartment;
            this.shopStaffName          = String.isEmpty(this.shopStaffName)? CommonConst.STRING_EMPTY : this.shopStaffName;
            this.shopStaffDepartment    = String.isEmpty(this.shopStaffDepartment)? CommonConst.STRING_EMPTY : this.shopStaffDepartment;
            this.District               = String.isEmpty(this.District)? CommonConst.STRING_EMPTY : this.District;
            this.buildingproperty       = String.isEmpty(this.buildingproperty)? CommonConst.STRING_EMPTY : this.buildingproperty;
            this.buildingName           = String.isEmpty(this.buildingName)? CommonConst.STRING_EMPTY : this.buildingName;
            this.propertyName           = String.isEmpty(this.propertyName)? CommonConst.STRING_EMPTY : this.propertyName;
            this.propertyLiveStatus     = String.isBlank(this.propertyLiveStatus)? CommonConst.STRING_EMPTY : this.propertyLiveStatus;
            this.application            = String.isBlank(this.application)? CommonConst.STRING_EMPTY : this.application;
            this.property               = String.isBlank(this.property)? CommonConst.STRING_EMPTY : this.property;
        }

        // 物件名の出力制御
        private void PropertyJudgment(Correspond__c targetCorrespondRecord){
            if(String.isNotBlank(targetCorrespondRecord.Property__r.Name)){
                // 物件から項目を設定する。
                this.BuildingName           = targetCorrespondRecord.Property__r.Building__r.Name;                      // 対応.建物.建物名
                this.PropertyName           = targetCorrespondRecord.Property__r.Name;                                  // 対応.物件.部屋番号
                this.propertyLiveStatus     = targetCorrespondRecord.Property__r.LiveStatus__c;                         // 対応.物件.状況
                this.buildingproperty       = targetCorrespondRecord.Property__r.Building__r.Name + ' ' 
                                            + targetCorrespondRecord.Property__r.Name;                                  // 建物名+物件名

            }else if(String.isNotBlank(targetCorrespondRecord.FirstInquiryProperty__r.Name)){
                // 初回問い合せ物件から項目を設定する。
                this.BuildingName           = targetCorrespondRecord.FirstInquiryProperty__r.Building__r.Name;          // 対応.初回問合せ物件.建物.建物名
                this.PropertyName           = targetCorrespondRecord.FirstInquiryProperty__r.Name;                      // 対応.初回問合せ物件.部屋番号
                this.propertyLiveStatus     = targetCorrespondRecord.FirstInquiryProperty__r.LiveStatus__c;             // 対応.初回問合せ物件.状況
                this.buildingproperty       = targetCorrespondRecord.FirstInquiryProperty__r.Building__r.Name + ' ' 
                                            + targetCorrespondRecord.FirstInquiryProperty__r.Name;                      // 建物名+物件名
            }
        }
    }

    // ポータルサイト構築 追加 Start
    /**
     * 本会員表示用内部クラス
     */
    public class screenMemberRecord{
        //以下、画面用の項目
        public String Id                { get; set; }    // ID
        public String memberId          { get; set; }    // 本会員ID
        public String lastName          { get; set; }    // 本会員．姓
        public String firstName         { get; set; }    // 本会員．名
        public String tell              { get; set; }    // 本会員．電話番号
        public String lastAccessDate    { get; set; }    // 本会員．最終アクセス日時
        public String joinDate          { get; set; }    // 本会員．入会日
        public String quitDate          { get; set; }    // 本会員．退会日

        //コンストラクタ
        public screenMemberRecord(Member__c targetMemberRecord){
            //レコードの連動
            this.Id              = targetMemberRecord.Id ;                   // ID
            this.memberId        = targetMemberRecord.MemberId__c ;          // 本会員ID
            this.lastName        = targetMemberRecord.LastName__c       ;    // 本会員．姓
            this.firstName       = targetMemberRecord.FirstName__c      ;    // 本会員．名
            this.tell            = targetMemberRecord.Tell__c           ;    // 本会員．電話番号
            if (targetMemberRecord.LastAccessDate__c != null) {
                this.lastAccessDate  = targetMemberRecord.LastAccessDate__c.format('yyyy/MM/dd', 'JST') ;    // 本会員．最終アクセス日時
            }
            
            if(targetMemberRecord.JoinDate__c != null){
                this.joinDate        = targetMemberRecord.JoinDate__c.format()       ;    // 本会員．入会日
            }
            if(targetMemberRecord.QuitDate__c != null){
                this.quitDate        = targetMemberRecord.QuitDate__c.format()       ;    // 本会員．退会日
            }
            
        }
    }
    // ポータルサイト構築 追加 End

	// ▼2021.10.08 No.307 対応で追加
	//住居条件、設備・条件 詳細内部クラス
	public class screenPropertyConditions{
		//取引先(1件目)フラグ
		public Boolean accountFlg {get; set;}

		//予約物件条件
		public Boolean isReservePropertyConditions {get; set;}

		//選択中の希望駅
		public List<Station__c> stations1 {get; set;}		//駅１
		public List<Station__c> stations2 {get; set;}		//駅２
		public List<Station__c> stations3 {get; set;}		//駅３

		//画面表示用希望駅
		public String stationsChar1 {get; set;}		//駅１文字列
		public String stationsChar2 {get; set;}		//駅２文字列
		public String stationsChar3 {get; set;}		//駅３文字列

		// 選択中の希望中学校
		public List<School__c> juniorHighSchoolList {get; set;}
		// 選択中の希望小学校
		public List<School__c> elementarySchoolList {get; set;}

		// 画面表示用希望中学校
		public String desiredJuniorHighSchool {get; set;} 
		// 画面表示用希望小学校
		public String desiredPrimarySchool {get; set;}

		public Id dispCondId { get; set; } // ID
		public Datetime SystemModstamp { get; set; }//SystemModstamp
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
		public Id desiredTrainRoute1 { get; set; } //希望沿線１
		public String trainRoute1 { get; set; } //希望沿線１．路線
		public String trainRoute1Name { get; set; } //希望沿線１．路線．路線名
		public String desiredTrainRoute2 { get; set; } //希望沿線２
		public String trainRoute2 { get; set; } //希望沿線２．路線
		public String trainRoute2Name { get; set; } //希望沿線２．路線．路線名
		public String desiredTrainRoute3 { get; set; } //希望沿線３
		public String trainRoute3 { get; set; } //希望沿線３．路線
		public String trainRoute3Name { get; set; } //希望沿線３．路線．路線名
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
		public String  OccupancyAreaLowerLimitOpen { get; set; }	// 占有面積（下限）_表示用
		public String  OccupancyAreaUpperLimitOpen { get; set; }	// 占有面積（上限）_表示用
		public String  BuildingAgeOpen { get; set; }				// 築年数_表示用
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
		public String walkingTime { get; set; } //駅までの徒歩（分）
		public String WalkingTimeOpen { get; set; } //駅までの徒歩（分）_表示時
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
		public String parkingFeeLimit { get; set; } //1台当たりの料金上限
		public String carCount { get; set; } //台数

		// ▼2021.10.08 No.307 対応で削除 来店カード（希望路線・小学校希望学区・中学校希望学区）、取引先希望路線（希望路線・小学校希望学区・中学校希望学区）
		//更新時に削除する希望沿線Id
		public Id AccountPropertyConditionsTrainRoute1 { get; set; } //お客様物件条件希望沿線１
		public Id AccountPropertyConditionsTrainRoute2 { get; set; } //お客様物件条件希望沿線2
		public Id AccountPropertyConditionsTrainRoute3 { get; set; } //お客様物件条件希望沿線3
		public Id AccountPropertyConditionsElementarySchoolArea { get; set; } //お客様物件条件小学校希望学区
		public Id AccountPropertyConditionsJuniorHighSchoolArea { get; set; } //お客様物件条件中学校希望学区

		// コンストラクタ
		public screenPropertyConditions(){
			this.deleteFlg = false; // 削除判定フラグ
			this.accountFlg = false; //取引フラグ
		}
		
		// コンストラクタ（住居条件、設備・条件 詳細、お客様物件条件から設定）
		public screenPropertyConditions(AccountPropertyConditions__c apc){
			this.accountFlg = false; //取引フラグ
			this.isReservePropertyConditions = apc.IsReservePropertyConditions__c;//予約物件条件

			this.stationsChar1 = CommonConst.STRING_EMPTY;		//駅１文字列
			this.stationsChar2 = CommonConst.STRING_EMPTY;		//駅２文字列
			this.stationsChar3 = CommonConst.STRING_EMPTY;		//駅３文字列

			this.dispCondId = apc.Id; // ID
			this.SystemModstamp = apc.SystemModstamp; // SystemModstamp
			this.deleteFlg = false; // 削除判定フラグ
			this.Name = apc.Name;// 物件条件名
			this.CreatedDate = apc.CreatedDate; // 作成日時
			this.desiredArea = apc.DesiredArea__c;//希望地域 
			this.desiredTrainRoute1 = apc.DesiredTrainRoute1__c;//希望沿線１
			this.trainRoute1 = apc.DesiredTrainRoute1__r.TrainRoute__c;//希望沿線１．路線
			this.trainRoute1Name = apc.DesiredTrainRoute1__r.TrainRoute__r.NAME;//希望沿線１．路線．路線名
			this.desiredTrainRoute2 = apc.DesiredTrainRoute2__c;//希望沿線２
			this.trainRoute2 = apc.DesiredTrainRoute2__r.TrainRoute__c;//希望沿線２．路線
			this.trainRoute2Name = apc.DesiredTrainRoute2__r.TrainRoute__r.NAME;//希望沿線２．路線．路線名
			this.desiredTrainRoute3 = apc.DesiredTrainRoute3__c;//希望沿線３
			this.trainRoute3 = apc.DesiredTrainRoute3__r.TrainRoute__c;//希望沿線３．路線
			this.trainRoute3Name = apc.DesiredTrainRoute3__r.TrainRoute__r.NAME;//希望沿線３．路線．路線名
			// ▼問合せ415で追加
			this.juniorHighSchoolDistrict = apc.DesiredJuniorHighSchoolArea__c;// 中学校希望学区（エリア）
			this.elementarySchoolDistrict = apc.DesiredElementarySchoolArea__c;// 小学校希望学区（エリア）
			this.juniorHighSchoolArea = apc.DesiredJuniorHighSchoolArea__r.SchoolArea__c;// 中学校希望学区（エリア）.希望学区
			this.elementarySchoolArea = apc.DesiredElementarySchoolArea__r.SchoolArea__c;// 小学校希望学区（エリア）.希望学区
			// ▼2021.10.08 No.307 対応で削除　取引先希望路線・希望学区
			// ▼2021.10.08 No.307 対応で追加
			this.AccountPropertyConditionsTrainRoute1 = apc.DesiredTrainRoute1__c;//希望路線1
			this.AccountPropertyConditionsTrainRoute2 = apc.DesiredTrainRoute2__c;//希望路線2
			this.AccountPropertyConditionsTrainRoute3 = apc.DesiredTrainRoute3__c;//希望路線3
			this.AccountPropertyConditionsElementarySchoolArea = apc.DesiredJuniorHighSchoolArea__c; //中学校希望学区
			this.AccountPropertyConditionsJuniorHighSchoolArea = apc.DesiredElementarySchoolArea__c; //小学校希望学区

			this.walkingTime = apc.WalkingTime__c;//徒歩

			if(apc.WalkingTime__c != '999'){
				this.WalkingTimeOpen =  apc.WalkingTime__c;  // 取引先.駅までの徒歩（分）
			}else{
				this.WalkingTimeOpen = '';   
			}
			this.isOneRoom = apc.IsOneRoom__c;//ワンルーム 
			this.is1K = apc.Is1K__c;//1K 
			this.is1DK = apc.Is1DK__c;//1DK 
			this.is1LDK1SLDK = apc.Is1LDK1SLDK__c;//1LDK/SLDK 
			this.is2K2DK = apc.Is2K2DK__c;//2K/DK 
			this.is2LDK2SLDK = apc.Is2LDK2SLDK__c;//2LDK/SLDK 
			this.is3K3DK = apc.Is3K3DK__c;//3K/DK 
			this.is3LDK3SLDK = apc.Is3LDK3SLDK__c;//3LDK/SLDK 
			this.is4K4DK4LDKFrom = apc.Is4K4DK4LDKFrom__c;//4K/DK/LDK~ 
			this.isWooden = apc.IsWooden__c;//木造 
			this.isLightweightSteel = apc.IsLightweightSteel__c;//軽量鉄骨 
			this.isSteel = apc.IsSteel__c;//鉄骨造 
			this.isRC = apc.IsRC__c;//RC 
			this.isSRC = apc.IsSRC__c;//SRC 
			this.isNorth = apc.IsNorth__c;//北 
			this.isNorthEast = apc.IsNorthEast__c;//北東 
			this.isEast = apc.IsEast__c;//東 
			this.isSouthEast = apc.IsSouthEast__c;//南東 
			this.isSouth = apc.IsSouth__c;//南 
			this.isSouthWest = apc.IsSouthWest__c;//南西 
			this.isWest = apc.IsWest__c;//西 
			this.isNorthWest = apc.IsNorthWest__c;//北西 
			this.isNonDeposit = apc.IsNonDeposit__c;//敷金/保証金なし 
			this.isNonKeyMoney = apc.IsNonKeyMoney__c;//礼金なし 
			this.isNonCleaningFee = apc.IsNonCleaningFee__c;//定額修繕費なし 
			this.isNonRenewalFee = apc.IsNonRenewalFee__c;//更新料なし 
			this.rentFeeFrom = CommonUtil.decimalToString(apc.RentFeeFrom__c);//賃料から 
			this.rentFeeTo = CommonUtil.decimalToString(apc.RentFeeTo__c);//賃料まで 
			this.isIncludeManagementFee = apc.IsIncludeManagementFee__c;//管理費込み 
			this.isIncludeParkingFee = apc.IsIncludeParkingFee__c;//駐車場代込み 
			this.occupancyAreaLowerLimit = apc.OccupancyAreaLowerLimit__c;//占有面積（下限） 
			this.occupancyAreaUpperLimit = apc.OccupancyAreaUpperLimit__c;//占有面積（上限） 
			this.buildingAge = apc.BuildingAge__c;//築年数 
			if(apc.OccupancyAreaLowerLimit__c == '999' || apc.OccupancyAreaLowerLimit__c == '0'){
				this.OccupancyAreaLowerLimitOpen = '';   
			}else{
				this.OccupancyAreaLowerLimitOpen =  apc.OccupancyAreaLowerLimit__c;  // 取引先.占有面積（下限）_表示用
			}
			if(apc.OccupancyAreaUpperLimit__c == '999' || apc.OccupancyAreaUpperLimit__c == '0'){
				this.OccupancyAreaUpperLimitOpen = '';   
			}else{
				this.OccupancyAreaUpperLimitOpen =  apc.OccupancyAreaUpperLimit__c;  // 取引先.占有面積（上限）_表示用
			}
			if(apc.BuildingAge__c == '999' || apc.BuildingAge__c == '0'){
				this.BuildingAgeOpen = '';   
			}else{
				this.BuildingAgeOpen =  apc.BuildingAge__c;  // 取引先.築年数
			}
			this.isDetachedHouse = apc.IsDetachedHouse__c;//戸建て 
			this.isMaisonette = apc.IsMaisonette__c;//メゾネット 
			this.isLoft = apc.IsLoft__c;//ロフト 
			this.isDesigners = apc.IsDesigners__c;//デザイナーズ 
			this.isRenovation = apc.IsRenovation__c;//リノベーション 
			this.isCondominiumRental = apc.IsCondominiumRental__c;//分譲賃貸 
			this.isAllWestern = apc.IsAllWestern__c;//オール洋間 
			this.isFirstFloor = apc.IsFirstFloor__c;//1階 
			this.isSecondFloorOver = apc.IsSecondFloorOver__c;//2階以上 
			this.isTopFloor = apc.IsTopFloor__c;//最上階 
			this.isCornerRoom = apc.IsCornerRoom__c;//角部屋 
			this.isBalcony = apc.IsBalcony__c;//バルコニー 
			this.isRoofBalcony = apc.IsRoofBalcony__c;//ルーフバルコニー 
			this.isPrivateGarden = apc.IsPrivateGarden__c;//専用庭 
			this.isParking = apc.IsParking__c;//駐車場空きあり 
			this.isInSiteParking = apc.IsInSiteParking__c;//敷地内駐車場 
			this.isPluralCarParking = apc.IsPluralCarParking__c;//駐車場2台可 
			this.isBuiltInGarage = apc.IsBuiltInGarage__c;//ビルトインガレージ 
			this.isCarport = apc.IsCarport__c;//カーポート 
			this.isBicycleParking = apc.IsBicycleParking__c;//駐輪場 
			this.isBikeStorage = apc.IsBikeStorage__c;//バイク可 
			this.isSmallBike = apc.IsSmallBike__c;//小型バイク 
			this.isMediumBike = apc.IsMediumBike__c;//中型バイク 
			this.isLargeBike = apc.IsLargeBike__c;//大型バイク 
			this.isElevator = apc.IsElevator__c;//エレベーター 
			this.isDeliveryBox = apc.IsDeliveryBox__c;//宅配ボックス 
			this.isCounterKitchen = apc.IsCounterKitchen__c;//カウンターキッチン 
			this.isSystemKitchen = apc.IsSystemKitchen__c;//システムキッチン 
			this.isGasStove = apc.IsGasStove__c;//ガスコンロ 
			this.isElectricStove = apc.IsElectricStove__c;//電気コンロ 
			this.isInductionHeating = apc.IsInductionHeating__c;//IHコンロ 
			this.isTwoGasStove = apc.IsTwoGasStove__c;//コンロ2口 
			this.isMoreGasStove = apc.IsMoreGasStove__c;//コンロ3口以上 
			this.isSepalateBathAndRestroom = apc.IsSepalateBathAndRestroom__c;//バス・トイレ別 
			this.isAditionalBoiling = apc.IsAditionalBoiling__c;//追焚機能 
			this.isDehumidifierForBathroom = apc.IsDehumidifierForBathroom__c;//浴室乾燥機 
			this.isWashlet = apc.IsWashlet__c;//温水洗浄便座 
			this.isShowerWashBasin = apc.IsShowerWashBasin__c;//シャワー付き洗面台 
			this.isRegalLavatory = apc.IsRegalLavatory__c;//洗面所独立 
			this.isInnerLandry = apc.IsInnerLandry__c;//室内洗濯機置場 
			this.isTownGas = apc.IsTownGas__c;//都市ガス 
			this.isPropaneGas = apc.IsPropaneGas__c;//プロパンガス 
			this.isAllElectric = apc.IsAllElectric__c;//オール電化 
			this.isAirConditioner = apc.IsAirConditioner__c;//エアコン 
			this.isFloorHeating = apc.IsFloorHeating__c;//床暖房 
			this.isShoesBox = apc.IsShoesBox__c;//シューズボックス 
			this.isShoeCloak = apc.IsShoeCloak__c;//シューズクローク 
			this.isWalkInCloset = apc.IsWalkInCloset__c;//ウォークインクローゼット 
			this.isTrunkRoom = apc.IsTrunkRoom__c;//トランクルーム 
			this.isBSAntenna = apc.IsBSAntenna__c;//BSアンテナ 
			this.isCSAntenna = apc.IsCSAntenna__c;//CSアンテナ 
			this.isCATV = apc.IsCATV__c;//CATV 
			this.isInternetFree = apc.IsInternetFree__c;//ネット使用料無料 
			this.isMonitorIntercom = apc.IsMonitorIntercom__c;//モニター付きインターホン 
			this.isAutoLock = apc.IsAutoLock__c;//オートロック 
			this.isFurniture = apc.IsFurniture__c;//家具付き 
			this.isHomeAppliance = apc.IsHomeAppliance__c;//家電付き 
			this.isNoGuarantor = apc.IsNoGuarantor__c;//保証人不要 
			this.isNonGuaranteeidCompany = apc.IsNonGuaranteeidCompany__c;//保証会社不要 
			this.isMusicalInstruments = apc.IsMusicalInstruments__c;//楽器相談可 
			this.isForeigner = apc.IsForeigner__c;//外国人契約可 
			this.isOfficeAvailable = apc.IsOfficeAvailable__c;//事務所利用可 
			this.isWelfareAvailable = apc.IsWelfareAvailable__c;//生活保護契約可 
			this.isPet = apc.IsPet__c;//ペット可 
			this.isLargePet = apc.IsLargePet__c;//ペット(大型犬) 
			this.isMiddlePet = apc.IsMiddlePet__c;//ペット(中型犬) 
			this.isSmallPet = apc.IsSmallPet__c;//ペット(小型犬) 
			this.isCat = apc.IsCat__c;//ペット(猫) 
			this.isOtherPet = apc.IsOtherPet__c;//ペット(その他) 
			this.isTwoTenant = apc.IsTwoTenant__c;//2人入居可 
			this.isRoomShare = apc.IsRoomShare__c;//ルームシェア可 
			this.isIppambutsu = apc.IsIppambutsu__c;//一般物 
			this.isElderly = apc.IsElderly__c;//高齢者歓迎 
			this.isWoman = apc.IsWoman__c;//女性限定 
			this.isStudent = apc.IsStudent__c;//学生限定マンション

			this.carCount = CommonUtil.decimalToString(apc.CarCount__c);//台数
			this.parkingFeeLimit = CommonUtil.decimalToString(apc.ParkingFeeLimit__c); //1台当たりの料金上限
		}

		// コンストラクタ（住居条件、設備・条件 詳細、取引先から設定）
		public screenPropertyConditions(Account acc){
			this.accountFlg = true; //取引フラグ
			this.isReservePropertyConditions = acc.IsReservePropertyConditions__c;//予約物件条件

			this.stationsChar1 = CommonConst.STRING_EMPTY;		//駅１文字列
			this.stationsChar2 = CommonConst.STRING_EMPTY;		//駅２文字列
			this.stationsChar3 = CommonConst.STRING_EMPTY;		//駅３文字列

			this.dispCondId = null; // ID
			this.SystemModstamp = acc.SystemModstamp; // SystemModstamp
			this.CreatedDate = acc.CreatedDate; //作成日時
			this.deleteFlg = false; // 削除判定フラグ
			this.Name = acc.PropertyConditionsName__c;// 物件条件名
			this.desiredArea = acc.DesiredArea__c;//希望地域 
			this.desiredTrainRoute1 = acc.DesiredTrainRoute1__c;//希望沿線１
			this.trainRoute1 = acc.DesiredTrainRoute1__r.TrainRoute__c;//希望沿線１．路線
			this.trainRoute1Name = acc.DesiredTrainRoute1__r.TrainRoute__r.NAME;//希望沿線１．路線．路線名
			this.desiredTrainRoute2 = acc.DesiredTrainRoute2__c;//希望沿線２
			this.trainRoute2 = acc.DesiredTrainRoute2__r.TrainRoute__c;//希望沿線２．路線
			this.trainRoute2Name = acc.DesiredTrainRoute2__r.TrainRoute__r.NAME;//希望沿線２．路線．路線名
			this.desiredTrainRoute3 = acc.DesiredTrainRoute3__c;//希望沿線３
			this.trainRoute3 = acc.DesiredTrainRoute3__r.TrainRoute__c;//希望沿線３．路線
			this.trainRoute3Name = acc.DesiredTrainRoute3__r.TrainRoute__r.NAME;//希望沿線３．路線．路線名
			// ▼問合せ415で追加
			this.juniorHighSchoolDistrict = acc.DesiredJuniorHighSchoolArea__c;// 中学校希望学区（エリア）
			this.elementarySchoolDistrict = acc.DesiredElementarySchoolArea__c;// 小学校希望学区（エリア）
			this.juniorHighSchoolArea = acc.DesiredJuniorHighSchoolArea__r.SchoolArea__c;// 中学校希望学区（エリア）.希望学区
			this.elementarySchoolArea = acc.DesiredElementarySchoolArea__r.SchoolArea__c;// 小学校希望学区（エリア）.希望学区
			// ▼2021.10.08 No.307 対応で削除　取引先希望路線・希望学区
			// ▼2021.10.08 No.307 対応で追加
			this.AccountPropertyConditionsTrainRoute1 = acc.DesiredTrainRoute1__c;//希望路線1
			this.AccountPropertyConditionsTrainRoute2 = acc.DesiredTrainRoute2__c;//希望路線2
			this.AccountPropertyConditionsTrainRoute3 = acc.DesiredTrainRoute3__c;//希望路線3
			this.AccountPropertyConditionsElementarySchoolArea = acc.DesiredJuniorHighSchoolArea__c; //中学校希望学区
			this.AccountPropertyConditionsJuniorHighSchoolArea = acc.DesiredElementarySchoolArea__c; //小学校希望学区

			this.walkingTime = acc.WalkingTime__c;//徒歩

			if(acc.WalkingTime__c != '999'){
				this.WalkingTimeOpen =  acc.WalkingTime__c;  // 取引先.駅までの徒歩（分）
			}else{
				this.WalkingTimeOpen = '';   
			}
			this.isOneRoom = acc.IsOneRoom__c;//ワンルーム 
			this.is1K = acc.Is1K__c;//1K 
			this.is1DK = acc.Is1DK__c;//1DK 
			this.is1LDK1SLDK = acc.Is1LDK1SLDK__c;//1LDK/SLDK 
			this.is2K2DK = acc.Is2K2DK__c;//2K/DK 
			this.is2LDK2SLDK = acc.Is2LDK2SLDK__c;//2LDK/SLDK 
			this.is3K3DK = acc.Is3K3DK__c;//3K/DK 
			this.is3LDK3SLDK = acc.Is3LDK3SLDK__c;//3LDK/SLDK 
			this.is4K4DK4LDKFrom = acc.Is4K4DK4LDKFrom__c;//4K/DK/LDK~ 
			this.isWooden = acc.IsWooden__c;//木造 
			this.isLightweightSteel = acc.IsLightweightSteel__c;//軽量鉄骨 
			this.isSteel = acc.IsSteel__c;//鉄骨造 
			this.isRC = acc.IsRC__c;//RC 
			this.isSRC = acc.IsSRC__c;//SRC 
			this.isNorth = acc.IsNorth__c;//北 
			this.isNorthEast = acc.IsNorthEast__c;//北東 
			this.isEast = acc.IsEast__c;//東 
			this.isSouthEast = acc.IsSouthEast__c;//南東 
			this.isSouth = acc.IsSouth__c;//南 
			this.isSouthWest = acc.IsSouthWest__c;//南西 
			this.isWest = acc.IsWest__c;//西 
			this.isNorthWest = acc.IsNorthWest__c;//北西 
			this.isNonDeposit = acc.IsNonDeposit__c;//敷金/保証金なし 
			this.isNonKeyMoney = acc.IsNonKeyMoney__c;//礼金なし 
			this.isNonCleaningFee = acc.IsNonCleaningFee__c;//定額修繕費なし 
			this.isNonRenewalFee = acc.IsNonRenewalFee__c;//更新料なし 
			this.rentFeeFrom = CommonUtil.decimalToString(acc.RentFeeFrom__c);//賃料から 
			this.rentFeeTo = CommonUtil.decimalToString(acc.RentFeeTo__c);//賃料まで 
			this.isIncludeManagementFee = acc.IsIncludeManagementFee__c;//管理費込み 
			this.isIncludeParkingFee = acc.IsIncludeParkingFee__c;//駐車場代込み 
			this.occupancyAreaLowerLimit = acc.OccupancyAreaLowerLimit__c;//占有面積（下限） 
			this.occupancyAreaUpperLimit = acc.OccupancyAreaUpperLimit__c;//占有面積（上限） 
			this.buildingAge = acc.BuildingAge__c;//築年数 
			if(acc.OccupancyAreaLowerLimit__c == '999' || acc.OccupancyAreaLowerLimit__c == '0'){
				this.OccupancyAreaLowerLimitOpen = '';   
			}else{
				this.OccupancyAreaLowerLimitOpen =  acc.OccupancyAreaLowerLimit__c;  // 取引先.占有面積（下限）_表示用
			}
			if(acc.OccupancyAreaUpperLimit__c == '999' || acc.OccupancyAreaUpperLimit__c == '0'){
				this.OccupancyAreaUpperLimitOpen = '';   
			}else{
				this.OccupancyAreaUpperLimitOpen =  acc.OccupancyAreaUpperLimit__c;  // 取引先.占有面積（上限）_表示用
			}
			if(acc.BuildingAge__c == '999' || acc.BuildingAge__c == '0'){
				this.BuildingAgeOpen = '';   
			}else{
				this.BuildingAgeOpen =  acc.BuildingAge__c;  // 取引先.築年数
			}
			this.isDetachedHouse = acc.IsDetachedHouse__c;//戸建て 
			this.isMaisonette = acc.IsMaisonette__c;//メゾネット 
			this.isLoft = acc.IsLoft__c;//ロフト 
			this.isDesigners = acc.IsDesigners__c;//デザイナーズ 
			this.isRenovation = acc.IsRenovation__c;//リノベーション 
			this.isCondominiumRental = acc.IsCondominiumRental__c;//分譲賃貸 
			this.isAllWestern = acc.IsAllWestern__c;//オール洋間 
			this.isFirstFloor = acc.IsFirstFloor__c;//1階 
			this.isSecondFloorOver = acc.IsSecondFloorOver__c;//2階以上 
			this.isTopFloor = acc.IsTopFloor__c;//最上階 
			this.isCornerRoom = acc.IsCornerRoom__c;//角部屋 
			this.isBalcony = acc.IsBalcony__c;//バルコニー 
			this.isRoofBalcony = acc.IsRoofBalcony__c;//ルーフバルコニー 
			this.isPrivateGarden = acc.IsPrivateGarden__c;//専用庭 
			this.isParking = acc.IsParking__c;//駐車場空きあり 
			this.isInSiteParking = acc.IsInSiteParking__c;//敷地内駐車場 
			this.isPluralCarParking = acc.IsPluralCarParking__c;//駐車場2台可 
			this.isBuiltInGarage = acc.IsBuiltInGarage__c;//ビルトインガレージ 
			this.isCarport = acc.IsCarport__c;//カーポート 
			this.isBicycleParking = acc.IsBicycleParking__c;//駐輪場 
			this.isBikeStorage = acc.IsBikeStorage__c;//バイク可 
			this.isSmallBike = acc.IsSmallBike__c;//小型バイク 
			this.isMediumBike = acc.IsMediumBike__c;//中型バイク 
			this.isLargeBike = acc.IsLargeBike__c;//大型バイク 
			this.isElevator = acc.IsElevator__c;//エレベーター 
			this.isDeliveryBox = acc.IsDeliveryBox__c;//宅配ボックス 
			this.isCounterKitchen = acc.IsCounterKitchen__c;//カウンターキッチン 
			this.isSystemKitchen = acc.IsSystemKitchen__c;//システムキッチン 
			this.isGasStove = acc.IsGasStove__c;//ガスコンロ 
			this.isElectricStove = acc.IsElectricStove__c;//電気コンロ 
			this.isInductionHeating = acc.IsInductionHeating__c;//IHコンロ 
			this.isTwoGasStove = acc.IsTwoGasStove__c;//コンロ2口 
			this.isMoreGasStove = acc.IsMoreGasStove__c;//コンロ3口以上 
			this.isSepalateBathAndRestroom = acc.IsSepalateBathAndRestroom__c;//バス・トイレ別 
			this.isAditionalBoiling = acc.IsAditionalBoiling__c;//追焚機能 
			this.isDehumidifierForBathroom = acc.IsDehumidifierForBathroom__c;//浴室乾燥機 
			this.isWashlet = acc.IsWashlet__c;//温水洗浄便座 
			this.isShowerWashBasin = acc.IsShowerWashBasin__c;//シャワー付き洗面台 
			this.isRegalLavatory = acc.IsRegalLavatory__c;//洗面所独立 
			this.isInnerLandry = acc.IsInnerLandry__c;//室内洗濯機置場 
			this.isTownGas = acc.IsTownGas__c;//都市ガス 
			this.isPropaneGas = acc.IsPropaneGas__c;//プロパンガス 
			this.isAllElectric = acc.IsAllElectric__c;//オール電化 
			this.isAirConditioner = acc.IsAirConditioner__c;//エアコン 
			this.isFloorHeating = acc.IsFloorHeating__c;//床暖房 
			this.isShoesBox = acc.IsShoesBox__c;//シューズボックス 
			this.isShoeCloak = acc.IsShoeCloak__c;//シューズクローク 
			this.isWalkInCloset = acc.IsWalkInCloset__c;//ウォークインクローゼット 
			this.isTrunkRoom = acc.IsTrunkRoom__c;//トランクルーム 
			this.isBSAntenna = acc.IsBSAntenna__c;//BSアンテナ 
			this.isCSAntenna = acc.IsCSAntenna__c;//CSアンテナ 
			this.isCATV = acc.IsCATV__c;//CATV 
			this.isInternetFree = acc.IsInternetFree__c;//ネット使用料無料 
			this.isMonitorIntercom = acc.IsMonitorIntercom__c;//モニター付きインターホン 
			this.isAutoLock = acc.IsAutoLock__c;//オートロック 
			this.isFurniture = acc.IsFurniture__c;//家具付き 
			this.isHomeAppliance = acc.IsHomeAppliance__c;//家電付き 
			this.isNoGuarantor = acc.IsNoGuarantor__c;//保証人不要 
			this.isNonGuaranteeidCompany = acc.IsNonGuaranteeidCompany__c;//保証会社不要 
			this.isMusicalInstruments = acc.IsMusicalInstruments__c;//楽器相談可 
			this.isForeigner = acc.IsForeigner__c;//外国人契約可 
			this.isOfficeAvailable = acc.IsOfficeAvailable__c;//事務所利用可 
			this.isWelfareAvailable = acc.IsWelfareAvailable__c;//生活保護契約可 
			this.isPet = acc.IsPet__c;//ペット可 
			this.isLargePet = acc.IsLargePet__c;//ペット(大型犬) 
			this.isMiddlePet = acc.IsMiddlePet__c;//ペット(中型犬) 
			this.isSmallPet = acc.IsSmallPet__c;//ペット(小型犬) 
			this.isCat = acc.IsCat__c;//ペット(猫) 
			this.isOtherPet = acc.IsOtherPet__c;//ペット(その他) 
			this.isTwoTenant = acc.IsTwoTenant__c;//2人入居可 
			this.isRoomShare = acc.IsRoomShare__c;//ルームシェア可 
			this.isIppambutsu = acc.IsIppambutsu__c;//一般物 
			this.isElderly = acc.IsElderly__c;//高齢者歓迎 
			this.isWoman = acc.IsWoman__c;//女性限定 
			this.isStudent = acc.IsStudent__c;//学生限定マンション

			this.carCount = CommonUtil.decimalToString(acc.CarCount__c);//台数
			this.parkingFeeLimit = CommonUtil.decimalToString(acc.ParkingFeeLimit__c); //1台当たりの料金上限
		}
	}
	// ▲2021.10.08 No.307 対応で追加

    /**
     * お気に入り物件表示用内部クラス
     */
    public class screenFavoriteProperty {
        private FavoriteProperty__c targetFavoritePropertyRecord;    //レコード本体（お気に入り物件）
        
        //以下、画面用の項目
        public String  Id                    { get; set; }    // お気に入り物件ID
        public Boolean isSelected            { get; set; }    // 選択行
        public Datetime SystemModstamp       { get; set; }    // SystemModstamp
        public String  Property              { get; set; }    // お気に入り物件.物件コード（非表示）
        public String  Account               { get; set; }    // お気に入り物件.取引先（非表示）
        public String  PropertyBuilding      { get; set; }    // お気に入り物件.物件.建物ID(非表示)
        public String  PropertyBuildingName  { get; set; }    // お気に入り物件.物件.建物.建物名
        public String  PropertyName          { get; set; }    // お気に入り物件.物件.部屋番号
        public String  PropertyStatus        { get; set; }    // お気に入り物件.状況
        public String  Address               { get; set; }    // お気に入り物件.住所
        public String  RentFee               { get; set; }    // お気に入り物件.賃料
        public String  NearestStation        { get; set; }    // お気に入り物件.最寄駅
        public String  BuildingYM            { get; set; }    // お気に入り物件.築年
        public String  ParkingFee            { get; set; }    // お気に入り物件.駐車場
        public String  Status                { get; set; }    // お気に入り物件.ステータス
        public String  PreviewImpression     { get; set; }    // お気に入り物件.内見感想
        public String  FloorPlan             { get; set; }    // 物件.間取り
        

        //コンストラクタ
        public screenFavoriteProperty(FavoriteProperty__c targetFavoritePropertyRecord){
            //レコードの連動
            this.targetFavoritePropertyRecord = targetFavoritePropertyRecord;   
            this.Id                    = targetFavoritePropertyRecord.Id;                           // 取引先.Id
            this.isSelected            = False;                                                     // 選択行
            this.SystemModstamp        = targetFavoritePropertyRecord.SystemModstamp;               // SystemModstamp
            this.Property              = targetFavoritePropertyRecord.Property__c;                  // お気に入り物件.物件コード
            this.Account               = targetFavoritePropertyRecord.Account__c;                   // お気に入り物件.取引先
            this.PropertyBuilding      = targetFavoritePropertyRecord.Property__r.Building__c;      // お気に入り物件.物件.建物ID(非表示)
            this.PropertyBuildingName  = targetFavoritePropertyRecord.Property__r.Building__r.Name + ' ' +
                                         targetFavoritePropertyRecord.Property__r.Name; // お気に入り物件.物件.建物.建物名
            this.PropertyName          = targetFavoritePropertyRecord.Property__r.Name;             // お気に入り物件.物件.部屋番号
            this.PropertyStatus        = targetFavoritePropertyRecord.PropertyStatus__c;            // お気に入り物件.状況
            this.Address               = targetFavoritePropertyRecord.Address__c;                   // お気に入り物件.住所
            this.RentFee               = commonUtil.decimalToString(targetFavoritePropertyRecord.RentFee__c);   // お気に入り物件.賃料
            this.NearestStation        = targetFavoritePropertyRecord.NearestStation__c;            // お気に入り物件.最寄駅
            this.BuildingYM            = targetFavoritePropertyRecord.BuildingYM__c;                // お気に入り物件.築年
            this.ParkingFee            = commonUtil.decimalToString(targetFavoritePropertyRecord.ParkingFee__c) ;// お気に入り物件.駐車場
            this.Status                = targetFavoritePropertyRecord.Status__c;                    // お気に入り物件.ステータス
            this.PreviewImpression     = targetFavoritePropertyRecord.PreviewImpression__c;         // お気に入り物件.内見感想
            this.FloorPlan             = targetFavoritePropertyRecord.Property__r.FloorPlan__c;     // 物件.間取り

            convertNull();
        }

        //null系を変換する
        public void convertNull() {       
            this.Id                    = String.isEmpty(this.Id                  )? CommonConst.STRING_EMPTY : this.Id                  ;     
            this.Property              = String.isEmpty(this.Property            )? CommonConst.STRING_EMPTY : this.Property            ; 
            this.Account               = String.isEmpty(this.Account             )? CommonConst.STRING_EMPTY : this.Account            ; 
            this.PropertyBuildingName  = String.isEmpty(this.PropertyBuildingName)? CommonConst.STRING_EMPTY : this.PropertyBuildingName; 
            this.PropertyName          = String.isEmpty(this.PropertyName        )? CommonConst.STRING_EMPTY : this.PropertyName        ; 
            this.PropertyStatus        = String.isEmpty(this.PropertyStatus      )? CommonConst.STRING_EMPTY : this.PropertyStatus      ; 
            this.Address               = String.isEmpty(this.Address             )? CommonConst.STRING_EMPTY : this.Address             ; 
            this.RentFee               = String.isEmpty(this.RentFee             )? CommonConst.STRING_EMPTY : this.RentFee + '円'      ; 
            this.NearestStation        = String.isEmpty(this.NearestStation      )? CommonConst.STRING_EMPTY : this.NearestStation      ; 
            this.BuildingYM            = String.isEmpty(this.BuildingYM          )? CommonConst.STRING_EMPTY : this.BuildingYM          ; 
            this.ParkingFee            = String.isEmpty(this.ParkingFee          )? CommonConst.STRING_EMPTY : this.ParkingFee + '円'   ; 
            this.Status                = String.isEmpty(this.Status              )? CommonConst.STRING_EMPTY : this.Status              ; 
            this.PreviewImpression     = String.isEmpty(this.PreviewImpression   )? CommonConst.STRING_EMPTY : this.PreviewImpression   ; 
            this.FloorPlan             = String.isEmpty(this.FloorPlan           )? CommonConst.STRING_EMPTY : this.FloorPlan           ;
        }
    }

        /**
     * 条件完全一致物件表示用内部クラス
     */
    public class screenExactConditionMatchProperty {
        
        //以下、画面用の項目
        public String  Id                    { get; set; }    // 条件完全一致物件ID
        public Boolean isSelected            { get; set; }    // 選択行
        public Datetime SystemModstamp       { get; set; }    // SystemModstamp
        public String  Property              { get; set; }    // 条件完全一致物件.物件コード（非表示）
        public String  Account               { get; set; }    // 条件完全一致物件.取引先（非表示）
        public String  PropertyBuilding      { get; set; }    // 条件完全一致物件.物件.建物ID(非表示)
        public String  PropertyBuildingName  { get; set; }    // 条件完全一致物件.物件.建物.建物名
        public String  PropertyName          { get; set; }    // 条件完全一致物件.物件.部屋番号
		public List<String> condNameList     { get; set; }	  // 条件完全一致物件.物件条件  2021.10.08 No.307 対応で追加
        public String  PropertyStatus        { get; set; }    // 条件完全一致物件.状況
        public String  Address               { get; set; }    // 条件完全一致物件.住所
        public String  RentFee               { get; set; }    // 条件完全一致物件.賃料
        public String  NearestStation        { get; set; }    // 条件完全一致物件.最寄駅
        public String  BuildingYM            { get; set; }    // 条件完全一致物件.築年
        public String  ParkingFee            { get; set; }    // 条件完全一致物件.駐車場
        public String  Status                { get; set; }    // 条件完全一致物件.ステータス
        public String IntroductionImpression { get; set; }    // 条件完全一致物件.紹介感想

        //コンストラクタ
        public screenExactConditionMatchProperty(ExactConditionMatchProperty__c targetExactConditionMatchPropertyRecord){
            //レコードの連動   
            this.Id                     = targetExactConditionMatchPropertyRecord.Id;                // 取引先.Id
            this.isSelected             = False;                                                     // 選択行
            this.SystemModstamp         = targetExactConditionMatchPropertyRecord.SystemModstamp;               // SystemModstamp
            this.Property               = targetExactConditionMatchPropertyRecord.Property__c;                  // 条件完全一致物件.物件コード
            this.Account                = targetExactConditionMatchPropertyRecord.Account__c;                   // 条件完全一致物件.取引先
            this.PropertyBuilding       = targetExactConditionMatchPropertyRecord.Property__r.Building__c;      // 条件完全一致物件.物件.建物ID(非表示)
            this.PropertyBuildingName   = targetExactConditionMatchPropertyRecord.Property__r.Building__r.Name + ' ' +
                                         targetExactConditionMatchPropertyRecord.Property__r.Name; // 条件完全一致物件.物件.建物.建物名
            this.PropertyName           = targetExactConditionMatchPropertyRecord.Property__r.Name;             // 条件完全一致物件.物件.部屋番号
			// ▼2021.10.08 No.307 対応で条件完全一致物件.物件追加
			if(String.isBlank(targetExactConditionMatchPropertyRecord.PropertyConditionsName__c)){
				this.condNameList		= new List<String>();
			}else{
				this.condNameList		= targetExactConditionMatchPropertyRecord.PropertyConditionsName__c.split(';');
			}
			// ▲2021.10.08 No.307 対応で条件完全一致物件.物件追加
            this.PropertyStatus         = targetExactConditionMatchPropertyRecord.PropertyStatus__c;            // 条件完全一致物件.状況
            this.Address                = targetExactConditionMatchPropertyRecord.Address__c;                   // 条件完全一致物件.住所
            this.RentFee                = commonUtil.decimalToString(targetExactConditionMatchPropertyRecord.RentFee__c);   // 条件完全一致物件.賃料
            this.NearestStation         = targetExactConditionMatchPropertyRecord.NearestStation__c;            // 条件完全一致物件.最寄駅
            this.BuildingYM             = targetExactConditionMatchPropertyRecord.BuildingYM__c;                // 条件完全一致物件.築年
            this.ParkingFee             = commonUtil.decimalToString(targetExactConditionMatchPropertyRecord.ParkingFee__c) ;// 条件完全一致物件件.駐車場
            this.Status                 = targetExactConditionMatchPropertyRecord.Status__c;                    // 条件完全一致物件.ステータス
            this.IntroductionImpression = targetExactConditionMatchPropertyRecord.IntroductionImpression__c;         // 条件完全一致物件.紹介感想

            convertNull();
        }

        //null系を変換する
        public void convertNull() {       
            this.Id                     = String.isEmpty(this.Id                  )? CommonConst.STRING_EMPTY : this.Id                 ;     
            this.Property               = String.isEmpty(this.Property            )? CommonConst.STRING_EMPTY : this.Property           ; 
            this.Account                = String.isEmpty(this.Account             )? CommonConst.STRING_EMPTY : this.Account            ;  
            this.PropertyBuildingName   = String.isEmpty(this.PropertyBuildingName)? CommonConst.STRING_EMPTY : this.PropertyBuildingName; 
            this.PropertyName           = String.isEmpty(this.PropertyName        )? CommonConst.STRING_EMPTY : this.PropertyName          ; 
            this.PropertyStatus         = String.isEmpty(this.PropertyStatus      )? CommonConst.STRING_EMPTY : this.PropertyStatus        ; 
            this.Address                = String.isEmpty(this.Address             )? CommonConst.STRING_EMPTY : this.Address               ; 
            this.RentFee                = String.isEmpty(this.RentFee             )? CommonConst.STRING_EMPTY : this.RentFee + '円'        ; 
            this.NearestStation         = String.isEmpty(this.NearestStation      )? CommonConst.STRING_EMPTY : this.NearestStation        ; 
            this.BuildingYM             = String.isEmpty(this.BuildingYM          )? CommonConst.STRING_EMPTY : this.BuildingYM            ; 
            this.ParkingFee             = String.isEmpty(this.ParkingFee          )? CommonConst.STRING_EMPTY : this.ParkingFee + '円'     ; 
            this.Status                 = String.isEmpty(this.Status              )? CommonConst.STRING_EMPTY : this.Status                ; 
            this.IntroductionImpression = String.isEmpty(this.IntroductionImpression   )? CommonConst.STRING_EMPTY : this.IntroductionImpression; 
        }
    }

    /**
     * 対応履歴（対応明細）表示用内部クラス
     */
    public class screenCorrespondDetail {
        
        //以下、画面用の項目（対応種別とメール種別、添付データ有無に関してはボタンの表示制御を行うためTransientを行わない制御が行えなくなるため）
        Transient public String  Id   { get; set; }                           // 対応明細Id

        public String  CorrespondType  { get; set; }                          // 対応明細.対応種別
        Transient public String  SupportedTitle { get; set; }                 // 対応明細.対応表題
        public String  MailType  { get; set; }                                // 対応明細.メール種別
        Transient public String  CorrespondsDistrict  { get; set; }           // 対応明細.対応.地区
        Transient public String  StaffName  { get; set; }                     // 対応明細.担当者.氏名
        Transient public String  SupportedDateTime  { get; set; }             // 対応明細.対応日時
        Transient public String  SupportedContent  { get; set; }              // 対応明細.対応内容
        Transient public String  MailDraft { get; set; }                      // メール下書.カスタムオブジェクト ID（非表示）
        Transient public String  MailTimeSpecificationSending { get; set; }   // メール時間指定送信.カスタムオブジェクトID（非表示）
        Transient public String  ApplicationId { get; set; }                  // 申込ID（非表示）
        Transient public String  Email { get;set; }                           // 対応明細.メール
        Transient public string  PortalSiteUrl {get;set; }                    // 対応明細.ポータルサイトURL
        Transient public String  Corresponds { get;set; }                     // 対応ID
        public Boolean AttachmentsFlg { get;set; }                            // 添付データ有無
        Transient public String  EchoMail { get;set; }                        // 反響メールId
		
		public String  phoneStatus  { get; set; }	// 対応明細.電話状況	// 2022.04.20 No0768 対応で追加_LINE連携の履歴のボタン制御用
        public String  echoMailLineId  { get; set; }	// 対応明細.反響メール．LINE＠ID	// 2022.04.20 No0768 対応で追加_LINE連携の履歴のボタン制御用


        //コンストラクタ
        public screenCorrespondDetail(CorrespondDetail__c targetCorrespondDetailRecord){ 

            this.Id                 = targetCorrespondDetailRecord.Id;                          // 取引先.Id
            this.CorrespondType     = targetCorrespondDetailRecord.CorrespondType__c;     // 対応明細.対応種別
            this.SupportedTitle     = targetCorrespondDetailRecord.SupportedTitle__c;   // 対応明細.対応表題
            this.MailType           = targetCorrespondDetailRecord.MailType__c;         // 対応明細.メール種別
            this.CorrespondsDistrict= targetCorrespondDetailRecord.Corresponds__r.District__c ;// 対応明細.対応.地区
            this.StaffName          = String.isEmpty(targetCorrespondDetailRecord.Staff__r.name    )? CommonConst.STRING_EMPTY : targetCorrespondDetailRecord.Staff__r.name    ;  // 対応明細.担当者.氏名
            if(!string.isBlank(targetCorrespondDetailRecord.Shop__r.name)){
                this.StaffName         += '(' + targetCorrespondDetailRecord.Shop__r.name +')';
            }
            if (targetCorrespondDetailRecord.SupportedDateTime__c != null) {
                this.SupportedDateTime      = targetCorrespondDetailRecord.SupportedDateTime__c.format('yyyy/MM/dd HH:mm', 'JST');          // 対応明細.対応日時
            }
            //メール種別が受信の場合
            if(targetCorrespondDetailRecord.MailType__c == CommonConst.CORRESPONDDETAIL_MAILTYPE_RECEIVE){   
                this.SupportedContent   = 'FROM：'
                                        + (String.isEmpty(targetCorrespondDetailRecord.Email__c)? '' : targetCorrespondDetailRecord.Email__c) //nullを変換する
                                        + commonconst.BREAK_CODE 
                                        + commonconst.BREAK_CODE 
                                        + targetCorrespondDetailRecord.SupportedContent__c;// 対応明細.対応内容
            }else{
            	this.SupportedContent   = targetCorrespondDetailRecord.SupportedContent__c; // 対応明細.対応内容
            }
            this.ApplicationId      = targetCorrespondDetailRecord.Corresponds__r.Application__c;     // 申込ID（非表示）
            this.Email              = targetCorrespondDetailRecord.Email__c;    //対応明細.メール
            this.PortalSiteUrl      = targetCorrespondDetailRecord.PortalSiteUrl__c; //対応明細.ポータルサイトURL
            this.Corresponds        = targetCorrespondDetailRecord.Corresponds__c; // 対応ID
            this.AttachmentsFlg     = false;                // 添付データ有無
            this.EchoMail           = targetCorrespondDetailRecord.EchoMail__c; //反響メールID

			this.phoneStatus		= targetCorrespondDetailRecord.PhoneStatus__c; // 対応明細.電話状況	// 2022.04.20 No0768 対応で追加
			this.echoMailLineId		= targetCorrespondDetailRecord.EchoMail__r.LineId__c;	// 対応明細.反響メール．LINE＠ID	// 2022.04.20 No0768 対応で追加_LINE連携の履歴のボタン制御用
            convertDate();
        }

        //対象のデータを任意の形に変換する
        public void convertDate() {       
            this.Id                    = String.isEmpty(this.Id                  )? CommonConst.STRING_EMPTY : this.Id;     
            if (this.SupportedContent != null){
                this.SupportedContent = this.SupportedContent.escapeHtml4().replaceAll('\n', '<br/>');
            }
            
        }
    }

    /**
     * 申込表示用内部クラス
     */
    public class screenApplication {
        private Application__c targetApplicationRecord;    //レコード本体（対応）
        
        //以下、画面用の項目
        public String Id                        { get; set; }    // 申込.ID
        public Boolean isSelected               { get; set; }    // 選択行
        public datetime SystemModstamp          { get; set; }    // 申込.SystemModstamp
        public String propertyBuildingRoomName  { get; set; }    // 申込.建物名+部屋番号
        public String propertyBuildingName      { get; set; }    // 申込.物件.建物.建物名
        public String propertyName              { get; set; }    // 申込.物件.部屋番号
        public String applicationDate           { get; set; }    // 申込.申込日
        public String tenantDesiredDate         { get; set; }    // 申込.入居希望日
        public String applicationType           { get; set; }    // 申込.申込種別
        public String tenant                    { get; set; }    // 入居者
        public String fullName                  { get; set; }    // 申込.名前
        public String companyName               { get; set; }    // 申込.会社名
        public String tenantCount               { get; set; }    // 申込.入居人数（本人含め）
        public String jointGuarantorFullName    { get; set; }    // 申込.連帯保証人氏名

        //コンストラクタ
        public screenApplication(Application__c targetApplicationRecord){
            this.targetApplicationRecord = targetApplicationRecord;  

            this.Id                     = targetApplicationRecord.Id;                               // 申込.Id
            this.isSelected             = false;
            this.SystemModstamp         = targetApplicationRecord.SystemModstamp;                   //SystemModstamp
            if(!String.isBlank(targetApplicationRecord.Property__r.Building__r.Name)){
                this.propertyBuildingRoomName   = targetApplicationRecord.Property__r.Building__r.Name + ' ';
            }
            if(!String.isBlank(targetApplicationRecord.Property__r.Name)){
                this.propertyBuildingRoomName   += targetApplicationRecord.Property__r.Name ;
            }
            this.propertyBuildingName   = targetApplicationRecord.Property__r.Building__r.Name;     // 申込.物件.建物.建物名
            this.propertyName           = targetApplicationRecord.Property__r.Name;                 // 申込.物件.部屋番号
            if (targetApplicationRecord.ApplicationDate__c != null) {
                this.applicationDate    = targetApplicationRecord.ApplicationDate__c.format();          // 申込.申込日
            }
            if (targetApplicationRecord.TenantDesiredDate__c != null) {
                this.tenantDesiredDate   = targetApplicationRecord.TenantDesiredDate__c.format();          // 申込.入居希望日
            }
            this.applicationType        = targetApplicationRecord.ApplicationType__c;               // 申込.申込種別
            if (targetApplicationRecord.FullName__c != null ){
                this.tenant             = targetApplicationRecord.FullName__c;                      // 申込.名前
            }else if (targetApplicationRecord.CompanyName__c != null){
                this.tenant             = targetApplicationRecord.CompanyName__c;                   // 申込.会社名
            }            
            this.tenantCount            = String.valueOf(targetApplicationRecord.TenantCount__c);   // 申込.入居人数（本人含め）
            this.jointGuarantorFullName = targetApplicationRecord.JointGuarantorFullName__c ;       // 申込.連帯保証人氏名

            convertNull();
        }

        //null系を変換する
        public void convertNull() {        
            this.Id                    = String.isEmpty(this.Id                      )? CommonConst.STRING_EMPTY : this.Id                      ;    
            this.propertyBuildingName  = String.isEmpty(this.propertyBuildingName    )? CommonConst.STRING_EMPTY : this.propertyBuildingName    ;
            this.propertyName          = String.isEmpty(this.propertyName            )? CommonConst.STRING_EMPTY : this.propertyName            ;
            this.applicationDate       = String.isEmpty(this.applicationDate         )? CommonConst.STRING_EMPTY : this.applicationDate         ;
            this.tenantDesiredDate     = String.isEmpty(this.tenantDesiredDate       )? CommonConst.STRING_EMPTY : this.tenantDesiredDate       ;
            this.applicationType       = String.isEmpty(this.applicationType         )? CommonConst.STRING_EMPTY : this.applicationType         ;
            this.tenant                = String.isEmpty(this.tenant                  )? CommonConst.STRING_EMPTY : this.tenant                  ;
            this.tenantCount           = String.isEmpty(this.tenantCount             )? CommonConst.STRING_EMPTY : this.tenantCount             ;
            this.jointGuarantorFullName= String.isEmpty(this.jointGuarantorFullName  )? CommonConst.STRING_EMPTY : this.jointGuarantorFullName  ;
        }
    }

    /**
     * 反響メール表示用内部クラス
     */
    public class screenEchoMail {
        private EchoMail__c targetEchoMailRecord;    //レコード本体（反響メール）
        
        //以下、画面用の項目
        public String id                            { get; set; }   // 反響メール.ID
        public String fromPotalSiteAbbreviationName { get; set; }   // 反響メール.Fromポータルサイト.サイト名(略称)
        public String inquiryDateTime               { get; set; }   // 反響メール.お問合せ日時
        public String propertyCode                  { get; set; }   // 反響メール.物件コード
        public String propertURL                    { get; set; }   // 反響メール.物件URL
        public String Echopropertydetails           { get; set; }   // 反響物件詳細
        public String propertyAddress               { get; set; }   // 反響メール.所在地
        public String closestStation                { get; set; }   // 反響メール.最寄駅
        public String walkTime                      { get; set; }   // 反響メール.徒歩
        public String roomLayout                    { get; set; }   // 反響メール.間取り
        public String rentFee                       { get; set; }   // 反響メール.賃料
        public String inquiryContent                { get; set; }   // 反響メール.お問合せ内容

        //コンストラクタ
        public screenEchoMail(CorrespondDetail__c targetEchoMailRecord){

            //▼ 2021.09.29 No.489 対応で追加
            if(targetEchoMailRecord.FirstInquiryPropertyShowFlg__c) {
                this.fromPotalSiteAbbreviationName  = '電話';
                this.inquiryDateTime                = targetEchoMailRecord.CreatedDate.format('yyyy/MM/dd HH:mm', 'JST');
                this.propertyCode                   = targetEchoMailRecord.Property__r.PropertyCode__c;                             // 物件コード
                this.propertURL                     = null;                                                                     // 物件URL
                this.Echopropertydetails            = String.isEmpty(targetEchoMailRecord.Property__r.Building__r.Address__c)? CommonConst.STRING_EMPTY : targetEchoMailRecord.Property__r.Building__r.Address__c;
                this.Echopropertydetails            += String.isEmpty(targetEchoMailRecord.Property__r.Building__r.TrainRoute1__r.Name)? CommonConst.STRING_EMPTY : '/'+targetEchoMailRecord.Property__r.Building__r.TrainRoute1__r.Name;
                this.Echopropertydetails            += String.isEmpty(targetEchoMailRecord.Property__r.Building__r.Station1__r.Name)? CommonConst.STRING_EMPTY : targetEchoMailRecord.Property__r.Building__r.Station1__r.Name;
                this.Echopropertydetails            += String.isEmpty(String.valueOf(targetEchoMailRecord.Property__r.Building__r.StationWalkTimeFormat1__c))? CommonConst.STRING_EMPTY : '駅 徒歩'+String.valueOf(targetEchoMailRecord.Property__r.Building__r.StationWalkTimeFormat1__c);
                this.Echopropertydetails            += String.isEmpty(targetEchoMailRecord.Property__r.FloorPlan__c  )? CommonConst.STRING_EMPTY : '/'+targetEchoMailRecord.Property__r.FloorPlan__c;
                this.Echopropertydetails            += String.isEmpty(String.valueOf(targetEchoMailRecord.Property__r.RentFee__c))? CommonConst.STRING_EMPTY : '/'+String.valueOf(targetEchoMailRecord.Property__r.RentFee__c);                              // 反響物件詳細
                this.inquiryContent                 = targetEchoMailRecord.SupportedContent__c;   
            } else {
            //▲ 2021.09.29 No.489
                this.Id                             = targetEchoMailRecord.EchoMail__c;                                      // 反響メール.Id
                this.fromPotalSiteAbbreviationName  = targetEchoMailRecord.EchoMail__r.FromPotalSite__r.AbbreviationName__c;    // 反響メール.Fromポータルサイト.サイト名(略称)
                if (targetEchoMailRecord.EchoMail__r.InquiryDateTime__c != null) {
                    this.inquiryDateTime            = targetEchoMailRecord.EchoMail__r.InquiryDateTime__c.format('yyyy/MM/dd HH:mm', 'JST');  // 反響メール.お問合せ日時
                }
                this.propertyCode                   = targetEchoMailRecord.EchoMail__r.PropertyCode__c;                         // 反響メール.物件コード
                this.propertURL                     = targetEchoMailRecord.EchoMail__r.PropertURL__c;                           // 反響メール.物件URL
                this.Echopropertydetails            = String.isEmpty(targetEchoMailRecord.EchoMail__r.PropertyAddress__c)? CommonConst.STRING_EMPTY : targetEchoMailRecord.EchoMail__r.PropertyAddress__c;
                this.Echopropertydetails            += String.isEmpty(targetEchoMailRecord.EchoMail__r.ClosestStation__c )? CommonConst.STRING_EMPTY : '/'+targetEchoMailRecord.EchoMail__r.ClosestStation__c;
                this.Echopropertydetails            += String.isEmpty(targetEchoMailRecord.EchoMail__r.WalkTime__c       )? CommonConst.STRING_EMPTY : '/'+targetEchoMailRecord.EchoMail__r.WalkTime__c;
                this.Echopropertydetails            += String.isEmpty(targetEchoMailRecord.EchoMail__r.RoomLayout__c     )? CommonConst.STRING_EMPTY : '/'+targetEchoMailRecord.EchoMail__r.RoomLayout__c;
                this.Echopropertydetails            += String.isEmpty(targetEchoMailRecord.EchoMail__r.RentFee__c        )? CommonConst.STRING_EMPTY : '/'+targetEchoMailRecord.EchoMail__r.RentFee__c;                              // 反響物件詳細
                this.propertyAddress                = targetEchoMailRecord.EchoMail__r.PropertyAddress__c;                      // 反響メール.所在地
                this.closestStation                 = targetEchoMailRecord.EchoMail__r.ClosestStation__c;                       // 反響メール.最寄駅
                this.walkTime                       = targetEchoMailRecord.EchoMail__r.WalkTime__c;                             // 反響メール.徒歩
                this.roomLayout                     = targetEchoMailRecord.EchoMail__r.RoomLayout__c;                           // 反響メール.間取り
                this.rentFee                        = targetEchoMailRecord.EchoMail__r.RentFee__c;                              // 反響メール.賃料
                this.inquiryContent                 = targetEchoMailRecord.EchoMail__r.InquiryContent__c;                       // 反響メール.お問合せ内容
            }

            convertNull();
        }

        //null系を変換する
        public void convertNull() {        
            this.Id                             = String.isEmpty(this.Id             )? CommonConst.STRING_EMPTY : this.Id;    
            this.inquiryDateTime                = String.isEmpty(this.inquiryDateTime)? CommonConst.STRING_EMPTY : this.inquiryDateTime;  // 反響メール.お問合せ日時
            this.propertyCode                   = String.isEmpty(this.propertyCode   )? CommonConst.STRING_EMPTY : this.propertyCode;     // 反響メール.物件コード
            this.propertURL                     = String.isEmpty(this.propertURL     )? CommonConst.STRING_EMPTY : this.propertURL;       // 反響メール.物件URL
            this.propertyAddress                = String.isEmpty(this.propertyAddress)? CommonConst.STRING_EMPTY : this.propertyAddress;  // 反響メール.所在地
            this.closestStation                 = String.isEmpty(this.closestStation )? CommonConst.STRING_EMPTY : this.closestStation;   // 反響メール.最寄駅
            this.walkTime                       = String.isEmpty(this.walkTime       )? CommonConst.STRING_EMPTY : this.walkTime;         // 反響メール.徒歩
            this.roomLayout                     = String.isEmpty(this.roomLayout     )? CommonConst.STRING_EMPTY : this.roomLayout;       // 反響メール.間取り
            this.rentFee                        = String.isEmpty(this.rentFee        )? CommonConst.STRING_EMPTY : this.rentFee;          // 反響メール.賃料
            this.inquiryContent                 = String.isEmpty(this.inquiryContent )? CommonConst.STRING_EMPTY : this.inquiryContent;   // 反響メール.お問合せ内容

        }
    }
    
    
    /**
     * 空室予約物件表示用内部クラス
     */
    public class ScreenVacancyReservationProp {

        //以下、画面用の項目
        public Id       VacancyReservationPropId { get; set; }   // 空室予約物件ID
        public Boolean  IsSelected               { get; set; }   // 選択行
        public String   PropName                 { get; set; }   // 物件名
        public String   Address                  { get; set; }   // 住所
        public String   VacancyStatus            { get; set; }   // 空室状況
        public String   PropertyFloorPlan        { get; set; }   // 物件間取り
        public datetime SystemModStamp           { get; set; }   // SystemModstamp
        public String   BuildingRegistGetParam   { get; set; }   // 建物登録画面用Getパラメータ

        //コンストラクタ
        public screenVacancyReservationProp(){
            this.convertFieldsNull();
        }

        //コンストラクタ
        public screenVacancyReservationProp(VacancyReservationProperty__c entity, String accountId){
            this.VacancyReservationPropId  = entity.Id;                             // 空室予約物件ID
            this.IsSelected                = false;                                 // 選択行
            this.PropName                  = entity.Building__r.Name;               // 物件名            
            this.Address                   = entity.Building__r.Address__c;         // 住所
            this.VacancyStatus             = entity.VacancyStatus__c;               // 空室状況
            this.PropertyFloorPlan         = entity.PropertyFloorPlan__c;           // 物件間取り
            this.SystemModStamp            = entity.SystemModstamp;                 // SystemModstamp
            
            // 建物登録画面用Getパラメータ
            this.BuildingRegistGetParam    = 'id=' + entity.Building__c 
                                           + '&accountId=' + accountId;
            
            this.convertFieldsNull();
        }
        
        // フィールドのNULL値変換
        public void convertFieldsNull() {        
            IsSelected                = (IsSelected == null)                   ? false                   : this.IsSelected;          // 選択行
            PropName                  = String.isEmpty(PropName)               ? CommonConst.STRING_EMPTY: PropName;                 // 物件名            
            Address                   = String.isEmpty(Address)                ? CommonConst.STRING_EMPTY: Address;                  // 住所
            VacancyStatus             = String.isEmpty(VacancyStatus)          ? CommonConst.STRING_EMPTY: VacancyStatus;            // 空室状況
            PropertyFloorPlan         = String.isEmpty(PropertyFloorPlan)      ? CommonConst.STRING_EMPTY: PropertyFloorPlan;        // 物件間取り
            SystemModStamp            = (SystemModStamp == null)               ? CommonUtil.getNow()     : SystemModStamp;           // SystemModstamp
            BuildingRegistGetParam    = String.isEmpty(BuildingRegistGetParam) ? CommonConst.STRING_EMPTY: BuildingRegistGetParam;   // 建物登録画面用Getパラメータ
        }
    }

    /**
     * 画面スタイル用内部クラス
     */
    public class ScreenStyle {

        /** HP会員情報 */
        public String MemberRecordOpenIconClass    { get; set; } // 展開アイコンクラス
        public String MemberRecordSectionNoneStyle { get; set; } // セクション非表示スタイル

        /** 自動追客一覧 */
        public String IntroMailOpenIconClass    { get; set; } // 展開アイコンクラス
        public String IntroMailSectionNoneStyle { get; set; } // セクション非表示スタイル

        /** 申込一覧 */
        public String ApplicationOpenIconClass    { get; set; } // 展開アイコンクラス
        public String ApplicationSectionNoneStyle { get; set; } // セクション非表示スタイル

        /** お気に入り物件 */
        public String FavoritePropertyOpenIconClass    { get; set; } // 展開アイコンクラス
        public String FavoritePropertySectionNoneStyle { get; set; } // セクション非表示スタイル

        /** 空室予約物件 */
        public String VacancyRsvPropOpenIconClass    { get; set; } // 展開アイコンクラス
        public String VacancyRsvPropSectionNoneStyle { get; set; } // セクション非表示スタイル

        /** 条件完全一致該当物件 */
        public String ExactCondMatchPropOpenIconClass    { get; set; } // 展開アイコンクラス
        public String ExactCondMatchPropSectionNoneStyle { get; set; } // セクション非表示スタイル

        /** 対応履歴 */
        public String CorrespondDetailOpenIconClass    { get; set; } // 展開アイコンクラス
        public String CorrespondDetailSectionNoneStyle { get; set; } // セクション非表示スタイル

        /** 反響一覧 */
        public String EchoMailOpenIconClass    { get; set; } // 展開アイコンクラス
        public String EchoMailSectionNoneStyle { get; set; } // セクション非表示スタイル

        /**
         * コンストラクタ
         */
        public screenStyle() {
            // HP会員情報
            this.MemberRecordOpenIconClass    = CommonConst.STRING_EMPTY; // 展開アイコンクラス(非展開)
            this.MemberRecordSectionNoneStyle = CommonConst.SECTION_NONE; // セクション非表示スタイル(非表示)

            // 自動追客一覧
            this.IntroMailOpenIconClass    = CommonConst.STRING_EMPTY; // 展開アイコンクラス(非展開)
            this.IntroMailSectionNoneStyle = CommonConst.SECTION_NONE; // セクション非表示スタイル(非表示)

            // 申込一覧
            this.ApplicationOpenIconClass    = CommonConst.STRING_EMPTY; // 展開アイコンクラス(非展開)
            this.ApplicationSectionNoneStyle = CommonConst.SECTION_NONE; // セクション非表示スタイル(非表示)

            // お気に入り物件
            this.FavoritePropertyOpenIconClass    = CommonConst.STRING_EMPTY; // 展開アイコンクラス(非展開)
            this.FavoritePropertySectionNoneStyle = CommonConst.SECTION_NONE; // セクション非表示スタイル(非表示)

            // 空室予約物件
            this.VacancyRsvPropOpenIconClass    = CommonConst.STRING_EMPTY; // 展開アイコンクラス(非展開)
            this.VacancyRsvPropSectionNoneStyle = CommonConst.SECTION_NONE; // セクション非表示スタイル(非表示)

            // 条件完全一致該当物件
            this.ExactCondMatchPropOpenIconClass    = CommonConst.STRING_EMPTY; // 展開アイコンクラス(非展開)
            this.ExactCondMatchPropSectionNoneStyle = CommonConst.SECTION_NONE; // セクション非表示スタイル(非表示)

            // 対応履歴
            this.CorrespondDetailOpenIconClass    = CommonConst.STRING_EMPTY; // 展開アイコンクラス(非展開)
            this.CorrespondDetailSectionNoneStyle = CommonConst.SECTION_NONE; // セクション非表示スタイル(非表示)

            // 反響一覧
            this.EchoMailOpenIconClass    = CommonConst.STRING_EMPTY; // 展開アイコンクラス(非展開)
            this.EchoMailSectionNoneStyle = CommonConst.SECTION_NONE; // セクション非表示スタイル(非表示)
        }

        /**
         * コンストラクタ
         * @param List<screenMemberRecord>                screenMemberRecordList                // HP会員情報
         * @param List<IntroductionMailInformation__c>    introMailInfoList                     // 自動追客一覧
         * @param List<screenApplication>                 screenApplicationList                 // 申込一覧
         * @param List<screenFavoriteProperty>            screenFavoritePropertyList            // お気に入り物件
         * @param List<ScreenVacancyReservationProp>      screenVacancyReservationPropList      // 空室予約物件
         * @param List<screenExactConditionMatchProperty> screenExactConditionMatchPropertyList // 条件完全一致該当物件
         * @param List<screenCorrespondDetail>            screenCorrespondDetailList            // 対応履歴
         * @param List<screenEchoMail>                    screenEchoMailList                    // 反響一覧
         */
        public screenStyle(List<screenMemberRecord>                  screenMemberRecordList
                           , List<IntroductionMailInformation__c>    introMailInfoList
                           , List<screenApplication>                 screenApplicationList
                           , List<screenFavoriteProperty>            screenFavoritePropertyList
                           , List<ScreenVacancyReservationProp>      screenVacancyReservationPropList
                           , List<screenExactConditionMatchProperty> screenExactConditionMatchPropertyList
                           , List<screenCorrespondDetail>            screenCorrespondDetailList
                           , List<screenEchoMail>                    screenEchoMailList){
            
            // スタイルの初期化
            this();

            // HP会員情報
            if (screenMemberRecordList.size() > 0) {
                this.MemberRecordOpenIconClass    = CommonConst.OPEN_SECTION_ICON; // 展開アイコンクラス(展開)
                this.MemberRecordSectionNoneStyle = CommonConst.STRING_EMPTY;      // セクション非表示スタイル(未定義)
            }
            
            // 自動追客一覧
            if (introMailInfoList.size() > 0) {
                this.IntroMailOpenIconClass    = CommonConst.OPEN_SECTION_ICON; // 展開アイコンクラス(展開)
                this.IntroMailSectionNoneStyle = CommonConst.STRING_EMPTY;      // セクション非表示スタイル(未定義)
            }

            // 申込一覧
            if (screenApplicationList.size() > 0) {
                this.ApplicationOpenIconClass    = CommonConst.OPEN_SECTION_ICON; // 展開アイコンクラス(展開)
                this.ApplicationSectionNoneStyle = CommonConst.STRING_EMPTY;      // セクション非表示スタイル(未定義)
            }

            // お気に入り物件
            if (screenFavoritePropertyList.size() > 0) {
                this.FavoritePropertyOpenIconClass    = CommonConst.OPEN_SECTION_ICON; // 展開アイコンクラス(展開)
                this.FavoritePropertySectionNoneStyle = CommonConst.STRING_EMPTY;      // セクション非表示スタイル(未定義)
            }

            // 空室予約物件
            if (screenVacancyReservationPropList.size() > 0) {
                this.VacancyRsvPropOpenIconClass    = CommonConst.OPEN_SECTION_ICON; // 展開アイコンクラス(展開)
                this.VacancyRsvPropSectionNoneStyle = CommonConst.STRING_EMPTY;      // セクション非表示スタイル(未定義)
            }

            // 条件完全一致該当物件
            if (screenExactConditionMatchPropertyList.size() > 0) {
                this.ExactCondMatchPropOpenIconClass    = CommonConst.OPEN_SECTION_ICON; // 展開アイコンクラス(展開)
                this.ExactCondMatchPropSectionNoneStyle = CommonConst.STRING_EMPTY;      // セクション非表示スタイル(未定義)
            }

            // 対応履歴
            if (screenCorrespondDetailList.size() > 0) {
                this.CorrespondDetailOpenIconClass    = CommonConst.OPEN_SECTION_ICON; // 展開アイコンクラス(展開)
                this.CorrespondDetailSectionNoneStyle = CommonConst.STRING_EMPTY;      // セクション非表示スタイル(未定義)
            }

            // 反響一覧
            if (screenEchoMailList.size() > 0) {
                this.EchoMailOpenIconClass    = CommonConst.OPEN_SECTION_ICON; // 展開アイコンクラス(展開)
                this.EchoMailSectionNoneStyle = CommonConst.STRING_EMPTY;      // セクション非表示スタイル(未定義)
            }
        }
    }
}