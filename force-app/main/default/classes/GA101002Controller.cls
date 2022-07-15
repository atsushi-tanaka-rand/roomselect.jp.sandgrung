/**
 * 反響一覧処理
 */
public with sharing class GA101002Controller {

    /** パブリック変数 */
    Transient public List<screenCorrespond> screenTargetRecordList { get; set; }  // 画面表示用の内部クラスレコード  //問合せNo0438でTransient変更
    
    public Integer CorrespondIndex { get; set; }                        // 明細行Index
    public Boolean isOpenError { get;set; }                             // 初期表示時のエラーフラグ
    public Boolean hasErrorMessage { get; set; }                        // 初期以降エラーメッセージフラグ
    public string EchoStaff {get;set;}                                  // 反響ユーザ（リスト選択時）
    public list<SelectOption> SelectEchoStaffList { get;set;}           // 反響担当者のリスト設定      

    public String ShopsName { get; set; }                               // 店舗
    public Boolean isAppointChecked { get; set; }                       // アポイント確定含む
    
    public String  EVENT_EMAIL {get; private set;}                      // 固定値　メール受信
    public String  EVENT_PURSUIT_VIEWED {get; private set;}             // 固定値　追客(閲覧あり)
    public String  EVENT_OTHERSTAFFSUPPORTED {get; private set;}        // 固定値　他スタッフ対応
    public String  EVENT_VISIT_RESERVATION {get; private set;}          // 固定値　来店予約
    public String  EVENT_PROPERTY_INTRODUCTION_POSSIBLE {get; private set;} // 固定値　物件紹介可能
	// ▼ 2021.11.25 LINE連携対応より、"LINE追加"と"LINE受信"を追加
	public String EVENT_LINE_RECEIVE	{get{return CommonConst.CORRESPOND_EVENT_LINE_RECEIVE;} private set;}
	public String EVENT_LINE_FRIEND_ADD	{get{return CommonConst.CORRESPOND_EVENT_LINE_FRIEND_ADD;} private set;}
	// ▲ 2021.11.25

    // 問合せ409で変更
    public String  EVENT_AUTO_RECIVE {get; private set;}                // 固定値　自動返信　

    public GA101002Modal1ParameterClass GA101002Paremeter { get; set; } // 店舗・地区選択引渡パラメータ

    /** プライベート変数 */
    private List<Correspond__c> CorrespondList;                         // 対応の一覧表示 //問合せNo0438で変更
    private list<SelectOption> SelectEchoShopList;                      // 反響店舗のリスト設定 //問合せNo0438で変更
    private List<String> ShopsIdList;                                   // 店舗Idリスト //問合せNo0438で変更
    private String ShopsId;                                             // 店舗Id //問合せNo0438で変更
    private Boolean isShopType;                                         // 店舗区分（False:インサイドセール、True:インサイドセール以外） //問合せNo0438で変更
    private string LoginUserID;                                         // ログインユーザID
    private Boolean CountChk;                                           // データ取得有無
    private Boolean isOpetionPortal;                                    // 自社ポータル権限 //問合せNo0433で追加

     /**
     * メイン処理
     * 初回読み込み時の処理
     */
    public GA101002Controller() {
        isOpenError = false;
        try {
            // 初期化   
            init();

            // 店舗・地区選択引渡パラメータ初期化
            GA101002Paremeter = new GA101002Modal1ParameterClass();
            ShopsIdList = new List<String>();

            //ログインユーザから店舗を取得する
            // 店舗情報の取得
            Shop__c shop = CommonUtil.getStaffCurrentShop();
            this.isShopType = shop.IsShopType__c;                    // 店舗区分

            ShopsName = shop.Name;                          // 店舗名
            ShopsId = shop.id;                              // 店舗Id

            //反響担当のリストをセット
            SelectEchoStaffList = CommonUtil.getUserSelectedOptionFromShopId(ShopsId,true);

            // 店舗
            SelectEchoShopList = CommonUtil.getShopSelectedOptionFromStaffId(EchoStaff,false,false,false);        

            //検索処理の実行
            CountChk = SelectRecordInfo(ShopsId,EchoStaff,isAppointChecked);

            //権限取得 //問合せNo0433で追加
            this.isOpetionPortal = AuthorityCheckUtil.getAuthorityOptionPortal(false);

            // 件数が0件だった場合
            if (CountChk == false ){ 
                BusinessLogicException ex = new BusinessLogicException();
                screenTargetRecordList = new List<ScreenCorrespond>();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_NO_DATA));
                CommonUtil.setErrorMessage(ex);
                hasErrorMessage = true;
                return;
            } 

            //データを一覧に設定する
            setCorrespondList();

        } catch (Exception e) {
            // エラーを設定
            CommonUtil.setErrorMessage(e);
            isOpenError = true;
        }
    }

    /**
     * 検索ボタン押下処理
     * 検索押下時の動き
     */
     public void  getCorrespondList(){
        hasErrorMessage = false;
         try{
            screenTargetRecordList = new List<ScreenCorrespond>();

            //検索処理の実行
            CountChk = SelectRecordInfo(ShopsId,EchoStaff,isAppointChecked);

            // 件数が0件だった場合
            if (CountChk == false ){ 
                // エラーとして処理
                screenTargetRecordList = new List<ScreenCorrespond>();
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_NO_DATA));
                throw ex;
            } 

            //データを一覧に設定する
            setCorrespondList();
            
         }catch (Exception e){
            // エラーを設定
            CommonUtil.setErrorMessage(e);
            hasErrorMessage = true;
         }
        
        
     }

    /**
     * 店舗・地区選択モーダルopen処理
     */
    public void openModal() {
        GA101002Paremeter.selectedShopListId = ShopsId.Split(';');
        GA101002Paremeter.selectedShopList = SelectEchoShopList.clone();
        GA101002Paremeter.selectchooseableList = LoginUserID;        //ログインユーザから所属部署の初期値セット
        GA101002Paremeter.isShopType = isShopType;
        GA101002Paremeter.isDrawing = true;
        GA101002Paremeter.noFirst = true;
    }

    // 店舗・地区選択モーダルclose処理
    public void closeModal() {
        hasErrorMessage = false;
        try{
            String SearchShopName = CommonConst.STRING_EMPTY;
            ShopsName = CommonConst.STRING_EMPTY;
            ShopsId = CommonConst.STRING_EMPTY;
            ShopsIdList.clear();

            if (GA101002Paremeter.selectedShopList.size() > 0 ){
                // 店舗が設定されている場合、一覧にセットする。
                for(SelectOption Shop : GA101002Paremeter.selectedShopList){
                    ShopsIdList.add(Shop.getValue());
                    if (ShopsId != CommonConst.STRING_EMPTY) {
                        ShopsId += ';';
                        ShopsName += ';';
                    }
                    ShopsId += Shop.getValue();
                    ShopsName += Shop.getLabel();
                }
            }

            SelectEchoStaffList = CommonUtil.getUserSelectedOptionFromShopId(ShopsIdList,true);
        }catch (Exception e){
            // エラーを設定
            CommonUtil.setErrorMessage(e);
            hasErrorMessage = true;
         }

    }


    /**
    初期化メソッド
    */
    private void init(){        
        //初期化
        CorrespondList = new List<Correspond__c>();
        screenTargetRecordList = new List<screenCorrespond>();  
        
        EVENT_EMAIL = CommonConst.CORRESPOND_EVENT_EMAIL;
        EVENT_PURSUIT_VIEWED = CommonConst.CORRESPOND_EVENT_PURSUIT_VIEWED;
        EVENT_OTHERSTAFFSUPPORTED = CommonConst.CORRESPOND_EVENT_OTHERSTAFFSUPPORTED;
        EVENT_VISIT_RESERVATION = CommonConst.CORRESPOND_EVENT_VISIT_RESERVATION;
        EVENT_PROPERTY_INTRODUCTION_POSSIBLE = CommonConst.CORRESPOND_EVENT_PROPERTY_INTRODUCTION_POSSIBLE;

        // 問合せ409で変更
        EVENT_AUTO_RECIVE = CommonConst.CORRESPOND_EVENT_AUTO_RECIVE;
        
        // エラーメッセージフラグ初期化
        hasErrorMessage = false;      

        // ログインのユーザIDを取得
        LoginUserID = UserInfo.getUserId();

        //アポイント確定は初期表示はFalse
        isAppointChecked = false;

        // インデックスを初期化
        CorrespondIndex = 0;

        // 検索結果はfalse
        CountChk = false;

        // 初期はFalseで
        this.isOpetionPortal = false;   //問合せNo0433で追加
    }

    /**
     * 検索処理（反響一覧）
     * 引数によって内容を絞り込んだ一覧を取得する。
     * 引数　　：　Department String 所属部署Id
     * 　　　　：　Staff String 反響担当
     * 　　　　：　AppointChecked Boolean アポイント確定有無
     * 戻り値　：　Boolean 件数の取得有無
     */
    private Boolean selectRecordInfo(string Department,String Staff,Boolean AppointChecked){

        // 選択地区のリスト作成
        List<String> DistrictList = Department.Split(';');

        // 検索SQL作成
        String sql = '';
        sql += 'SELECT Id                     '; // 対応.Id（非表示）
        sql += '      ,Name                   '; // 対応.対応番号（非表示）
        sql += '      ,AccountId__r.ParentId  '; // 対応.取引先ID（非表示）
        sql += '      ,AccountId__r.Name      '; // 対応.取引先 ID.取引先名
        sql += '      ,AccountId__r.Phone     '; // 対応.取引先 ID.電話番号
        sql += '      ,Status__c              '; // 対応.ステータス
        sql += '      ,Event__c               '; // 対応.イベント
        sql += '      ,EventDateTime__c       '; // 対応.イベント時刻
        sql += '      ,Property__r.Building__r.Name ';                   // 対応.物件.建物.建物名
        sql += '      ,Property__r.Name       ';                         // 対応.物件.部屋番号
        sql += '      ,Property__r.Building__r.District__c ';            // 対応.物件.建物.地区
        sql += '      ,FirstInquiryProperty__r.Building__r.Name ';       // 対応.初回問い合せ物件.建物.建物名
        sql += '      ,FirstInquiryProperty__r.Name ';                   // 対応.初回問い合せ物件.部屋番号
        sql += '      ,FirstInquiryProperty__r.Building__r.District__c'; // 対応.初回問い合せ物件.建物.地区
        sql += '      ,EchoStaff__r.Username  '; // 対応.担当者（反響）.ユーザ名
        sql += '      ,EchoStaff__r.Name      '; // 対応.担当者（反響）.氏名
        sql += '      ,EchoStaff__r.Department'; // 対応.ユーザ.部署
        sql += '      ,PortalSite__r.Name     '; // 対応.ポータルサイト.サイト名
        sql += '      ,EchoShop__r.Name       '; // 対応.反響担当店舗.店舗名
        sql += '      ,Memo__c                '; // 対応.メモ
        sql += '      ,StaffSupportedFlg__c';    // 対応.スタッフ対応フラグ
        // 問合せ409で変更
        sql += '      ,AutomaticReplyAfterPursuitFlg__c';    // 対応.自動返信後追客フラグ
        // 問合せ323で追加
        sql += '      ,Remarks__c';              // 対応.備考
		// ▼ 2021.11.25 LINE連携対応より、LINE会員を追加・修正
		sql += '	  ,LineMember__c';
		sql += '	  ,LineMember__r.Account__c';
		// ▲ 2021.11.25
        
        sql += ' FROM  Correspond__c         ';
        sql += ' WHERE ';
		// ▼ 2022.1.29 LINE連携対応より、LINEと取引先が未紐づけの場合も一覧に表示するよう修正
		sql += ' ((AccountId__r.RecordType.DeveloperName = \'' + CommonConst.ACCOUNT_RECTYPE_CUSTOMER + '\'';         // レコードタイプ（顧客）
		sql += '	OR (LineMember__c != null ';
		sql += '		AND LineMember__r.Account__r.RecordType.DeveloperName = null ';
		sql += '		) ';
		sql += '	)';
		// ▲ 2022.1.29
        // 未対応、追客中、追客保留中、アポイント確定（チェックにより含める）
        sql += ' AND (Status__c in (\'' + CommonConst.CORRESPOND_STATUS_NOTSUPPORTED + '\',\'' 
                                        + CommonConst.CORRESPOND_STATUS_PURSUIT  + '\'' ;
        // アポイント確定含むチェック有無
        if (AppointChecked ){
            // アポイント確定含む
            sql +=                ',\'' + CommonConst.CORRESPOND_STATUS_APPOINTMENT + '\'';
        }
        sql +=                    ' ) ';
        // 終了かつ来店担当者が設定されていない対応を出力
        sql +=      ' OR    (Status__c = \'' + CommonConst.CORRESPOND_STATUS_CLOSE + '\'';
        sql +=      '        AND  ShopStaff__c = null ) ';
        //2020/6/16追加：追客保留中かつ保留前ステータスが追客中のものも表示
        sql +=      ' OR     (Status__c = \'' + CommonConst.CORRESPOND_STATUS_PURSUITHOLD + '\'' ;//ステータスが追客保留中 かつ 
        sql +=      '  	    AND StatusBeforePursuitHold__c = \'' + CommonConst.CORRESPOND_STATUS_PURSUIT + '\')' ;//保留前ステータスが追客中
        sql +=      ' )';

        sql += ' AND  (ListViewDate__c <= ' + CommonUtil.getNow().formatGmt('yyyy-MM-dd\'T\'hh:mm:ss.SSS\'Z\'');   // 一覧表示日時
        sql += '       OR    IsSupportedListShow__c = FALSE ';    // 対応確認
        sql += '       OR    IsBrowseFlg__c = FALSE ';            // 閲覧フラグ
        sql += '       OR    StaffSupportedFlg__c = FALSE ) ';    // スタッフ対応フラグ

        Integer count = 0;
        // 反響店舗の入力
        // if(string.isBlank(Department) && (Staff == '全表示') ){
        if(string.isBlank(Department) && string.isBlank(Staff)){
            // 条件が入力されていない場合
        }else if(!string.isBlank(Department)){
            // 条件が入力されている場合
            for(String Id :DistrictList){
                if(count == 0){
                    // 最初のみ条件を指定
                    sql += '   AND EchoShop__c  IN ( ';
                }
                sql +=  '\'' + Id + '\'';
                count += 1;
                if(count  == DistrictList.size()){
                    // 最後のデータで閉める
                    sql += ')';
                }else{
                    // 続いているデータは,で仕切る
                    sql += ',';
                }
            }           
        }

        // 反響担当
        if (!string.isBlank(Staff)) {
            // 反響担当が全表示以外
            sql += ' AND  EchoStaff__c =\'' + CommonUtil.escapeSingleQuotesEx(Staff) + '\'';  
        }          
        sql += ' ) ';


        // メール分
        sql += ' OR (ReceiveMailDatePortal__c != null';        // ポータルサイトのメール受信日時
        sql += '     AND   EchoStaff__c  = null ';              
        sql += '     AND   Status__c  =  \'' + CommonConst.CORRESPOND_STATUS_NOTSUPPORTED + '\'';   //未対応
        sql += '  )';  

        // 問合せメールの未対応で、担当をまだ決めていない場合(IS)
        sql += ' OR ((EchoShop__c != null';        // 反響店舗の入力ありで
        sql += '     AND   EchoShop__r.IsShopType__c = false  ';        // IS店舗
        sql += '     AND   EchoStaff__c  = null ';              
        sql += '     AND   Status__c  =  \'' + CommonConst.CORRESPOND_STATUS_NOTSUPPORTED + '\'';   //未対応
        sql += ' )';
        sql += '     OR (VisitShop__c != null';        // 反響店舗の入力ありで
        sql += '     AND   VisitShop__r.IsShopType__c = false  ';        // IS店舗
        sql += '     AND   EchoStaff__c  = null ';              
        sql += '     AND   Status__c  =  \'' + CommonConst.CORRESPOND_STATUS_NOTSUPPORTED + '\'';   //未対応
        sql += ' )';
        sql += ' )';  
        
        sql += ' ORDER BY  EventDateTime__c DESC';       //対応.イベント時刻（昇順）
        // 検索実行＆結果返却
        CorrespondList = Database.query(sql);

        // 件数が取れない場合
        if (CorrespondList.size() == 0 ){
            return false;
        }

        return true;

    }

    /**
     * ISの店舗を取得する。
     * 引数　　： 
     * 戻り値　： string 店舗ID
     */
    private String SetISShopList(){
        // 選択地区のリスト作成
        String IsShopId = CommonConst.STRING_EMPTY;

        // 検索SQL作成
        String sql = '';
        sql += ' SELECT    Id         '; // 店舗ID
        sql += ' FROM      Shop__c    '; 

        // 所属部署が選ばれていない場合
        sql += ' WHERE Id IN (SELECT ShopName__c ';
        sql += '              FROM   ShopTransfer__c ';     //店舗異動obj
        sql += '              WHERE  StartDate__c <= ' + String.valueOf(CommonUtil.getToday());
        sql += '              AND EndDate__c   >= ' + String.valueOf(CommonUtil.getToday());
        sql += '            )';
        sql += '  AND IsShopType__c = false ';

        // 検索実行＆結果返却
        List<Shop__c> ShopList = Database.query(sql);
        if (ShopList.size() >0) {
            IsShopId = ShopList[0].id;
        }
        return IsShopId;
    }

    //▼問合せNo0433で追加
    /**
     * 検索処理（紹介メール情報の対応ID）
     * 戻り値　：　Set<id>
     */
    private Set<id> selectintroMailInfo(){
        List<IntroductionMailInformation__c> introMailInfoList = [SELECT id,Correspond__c
                                                                  FROM IntroductionMailInformation__c LIMIT :CommonConst.GOVERNOR_SELECT_LIMIT];
        Set<id> introMailInfoCorrespondIdSet = new Set<id>();
        for (IntroductionMailInformation__c introMailInfo : introMailInfoList) {
            introMailInfoCorrespondIdSet.add(introMailInfo.Correspond__c);
        }
        return introMailInfoCorrespondIdSet;
    }
    //▲問合せNo0433で追加

    /**
     * 取得したデータを一覧にセットする。　
     */
    private void setCorrespondList(){

        //初期化
        CorrespondIndex = 0;

        //▼問合せNo0433で追加
        // 紹介メール情報の取得
        Set<id> introMailInfoCorrespondIdSet = selectIntroMailInfo();
        //▲問合せNo0433で追加
        
        //内部クラスに値をセットする。
        for(Correspond__c candidate :CorrespondList) {

            //▼問合せNo0413,0433で追加
            // 紹介メール情報がセットされている対応場合、一覧にセットしない（例外：紹介メール情報がセットされている対応でイベントが「物件紹介可能」は表示対象）
            if (this.isOpetionPortal && introMailInfoCorrespondIdSet.contains(candidate.id) && candidate.Event__c != EVENT_PROPERTY_INTRODUCTION_POSSIBLE){
                continue;
            }
            //▲問合せNo0413,0433で追加

            //出力用に合わせて変換する。
            screenCorrespond screenTargetRecord = new screenCorrespond(candidate);

            //配列に入れ込む
            screenTargetRecordList.add(screenTargetRecord);

        }
    }
    
    /**
     * 画面表示用内部クラス
     */
    public class ScreenCorrespond {
        
        //以下、画面用の項目
        public String  Id                  { get; set; }    // 対応.Id（非表示）
        public String  Name                { get; set; }    // 対応.対応番号（非表示）
        public String  AccountIdParentId   { get; set; }    // 対応.取引先ID（非表示）
        public String  AccountIdName       { get; set; }    // 対応.取引先 ID.取引先名
        public String  Status              { get; set; }    // 対応.ステータス
        public String  Event               { get; set; }    // 対応.イベント
        public String  EventDateTime       { get; set; }    // 対応.イベント時刻
        public String  BuildingName        { get; set; }    // 対応.建物.建物名
        public String  PropertyName        { get; set; }    // 対応.物件.部屋番号
        public String  BuildingDistrict    { get; set; }    // 対応.建物.地区
        public String  EchoStaffUsername   { get; set; }    // 対応.担当者（反響）.ユーザ名
        public String  EchoStaffName       { get; set; }    // 対応.担当者（反響）.氏名
        public String  EchoStaffDepartment { get; set; }    // 対応.ユーザ.部署
        public String  PortalSiteName      { get; set; }    // 対応.ポータルサイト.サイト名
        public String  EchoShopName        { get; set; }    // 対応.反響担当店舗.店舗名
        public String  AccountIdPhone      { get; set; }    // 対応.取引先 ID.電話番号
        public String  Memo                { get; set; }    // 対応.メモ
        public Boolean staffSupportedFlg   { get; set; }    // 対応.スタッフ対応フラグ
        // 問合せ409で変更
        public Boolean AutomaticReplyAfterPursuitFlg { get; set; }    // 対応.自動返信後追客フラグ
        // 問合せ323で追加
        public String remarks               { get; set; }    // 対応.備考
		// ▼ 2021.11.25 LINE連携対応より、"LINE会員ID"と"LINE未紐づけフラグ"を追加
		public Id		lineMemberId			{get;set;}
		public Boolean	isUnlinkedLineMember	{get;set;}
		// ▲ 2021.11.25
        
        //コンストラクタ
        public screenCorrespond(Correspond__c targetCorrespondRecord){


            
            //取引先レコードの連動
            this.Id                     = targetCorrespondRecord.Id;                        // 対応.Id（非表示）
            this.Name                   = targetCorrespondRecord.Name;                      // 対応.対応番号（非表示）
            this.AccountIdParentId      = targetCorrespondRecord.AccountId__c;              // 対応.取引先ID（非表示）
            this.AccountIdName          = targetCorrespondRecord.AccountId__r.Name ;        // 対応.取引先 ID.取引先名
            this.Status                 = targetCorrespondRecord.Status__c;                 // 対応.ステータス
            this.Event                  = targetCorrespondRecord.Event__c;                  // 対応.イベント
            if (targetCorrespondRecord.EventDateTime__c != null) {
                // ▼問合せ323で変更
                String eveDate = targetCorrespondRecord.EventDateTime__c.format('yyyy/MM/dd HH:mm', 'JST'); // 対応.イベント時刻
                this.EventDateTime = eveDate.substring(0, 10) + '<br/>' + eveDate.substring(10);
                // ▲問合せ323で変更
            }

            // 物件名の出力判定
            PropertyJudgment(targetCorrespondRecord);
            
            this.EchoStaffUsername      = targetCorrespondRecord.EchoStaff__r.Username;     // 対応.担当者（反響）.ユーザ名
            this.EchoStaffName          = targetCorrespondRecord.EchoStaff__r.Name;         // 対応.担当者（反響）.氏名            
            if (targetCorrespondRecord.EchoStaff__r.Department != null) {
                this.EchoStaffDepartment    =  '（'+ targetCorrespondRecord.EchoStaff__r.Department + '）';   // 対応.ユーザ.部署
            }
            this.PortalSiteName         = targetCorrespondRecord.PortalSite__r.Name;        // 対応.ポータルサイト.サイト名
            this.EchoShopName           = targetCorrespondRecord.EchoShop__r.Name;          // 対応.反響担当店舗.店舗名
            // ▼問合せ323で変更
            String phoneNo = targetCorrespondRecord.AccountId__r.Phone;
            if(!String.isBlank(phoneNo) && phoneNo.length() >= 8) {
                this.AccountIdPhone         = phoneNo.substring(0, 8) + '<br/>' + phoneNo.substring(8); // 対応.取引先 ID.電話番号
            } else {
                this.AccountIdPhone     = phoneNo;
            }
            // ▲問合せ323で変更
            this.Memo                   = targetCorrespondRecord.Memo__c;                   // 対応.メモ
            this.staffSupportedFlg      = targetCorrespondRecord.StaffSupportedFlg__c;      // 対応.スタッフ対応フラグ
            // 問合せ409で変更
            this.AutomaticReplyAfterPursuitFlg = targetCorrespondRecord.AutomaticReplyAfterPursuitFlg__c; // 対応.自動返信後追客フラグ
            // 問合せ323で追加
            if(!String.isBlank(targetCorrespondRecord.Remarks__c)) {
                this.remarks = targetCorrespondRecord.Remarks__c.replace('\n','<br/>');         // 対応.備考
            } else {
                this.remarks = targetCorrespondRecord.Remarks__c;
            }

			// ▼ 2021.11.25 LINE連携対応より、"LINE会員ID"と"LINE未紐づけフラグ"を追加
			this.lineMemberId = targetCorrespondRecord.LineMember__c;
			this.isUnlinkedLineMember =
				String.isBlank(targetCorrespondRecord.LineMember__r.Account__c) && String.isNotBlank(this.lineMemberId);
			// ▲ 2021.11.25
            

            convertNull();
        }

        //空白をnullに変更する
        public void convertNull() {
            this.Id                  = String.isBlank(this.Id)?                  null : this.Id;
            this.Name                = String.isBlank(this.Name)?                null : this.Name;
            this.AccountIdParentId   = String.isBlank(this.AccountIdParentId)?   null : this.AccountIdParentId;
            this.AccountIdName       = String.isBlank(this.AccountIdName)?       null : this.AccountIdName;
            this.Status              = String.isBlank(this.Status)?              null : this.Status;
            this.Event               = String.isBlank(this.Event)?               null : this.Event;
            this.EventDateTime       = String.isBlank(this.EventDateTime)?       null : this.EventDateTime;
            this.BuildingName        = String.isBlank(this.BuildingName)?        null : this.BuildingName;
            this.PropertyName        = String.isBlank(this.PropertyName)?        null : this.PropertyName;
            this.BuildingDistrict    = String.isBlank(this.BuildingDistrict)?    null : this.BuildingDistrict;
            this.EchoStaffUsername   = String.isBlank(this.EchoStaffUsername)?   null : this.EchoStaffUsername;
            this.EchoStaffName       = String.isBlank(this.EchoStaffName)?       'なし' : this.EchoStaffName;
            this.EchoStaffDepartment = String.isBlank(this.EchoStaffDepartment)? null : this.EchoStaffDepartment;
            this.PortalSiteName      = String.isBlank(this.PortalSiteName)?      null : this.PortalSiteName;
            this.EchoShopName        = String.isBlank(this.EchoShopName)?        null : this.EchoShopName;
            this.AccountIdPhone      = String.isBlank(this.AccountIdPhone)?      null : this.AccountIdPhone;
            this.Memo                = String.isBlank(this.Memo)?                 null : this.Memo;
			// ▼ 2021.11.24 LINE連携対応より、"LINE会員ID"を追加
			this.lineMemberId		 = String.isBlank(this.lineMemberId)? null: this.lineMemberId;
			// ▲ 2021.11.24
        }
        
        // 物件名の出力制御
        private void PropertyJudgment(Correspond__c targetCorrespondRecord){
            if(String.isNotBlank(targetCorrespondRecord.Property__r.Name)){
                // 物件から項目を設定する。
                this.BuildingName           = targetCorrespondRecord.Property__r.Building__r.Name;                      // 対応.建物.建物名
                this.PropertyName           = targetCorrespondRecord.Property__r.Name;                                  // 対応.物件.部屋番号
                this.BuildingDistrict       = targetCorrespondRecord.Property__r.Building__r.District__c;               // 対応.建物.地区
            }else if(String.isNotBlank(targetCorrespondRecord.FirstInquiryProperty__r.Name)){
                // 初回問い合せ物件から項目を設定する。
                this.BuildingName           = targetCorrespondRecord.FirstInquiryProperty__r.Building__r.Name;          // 対応.初回問合せ物件.建物.建物名
                this.PropertyName           = targetCorrespondRecord.FirstInquiryProperty__r.Name;                      // 対応.初回問合せ物件.部屋番号
                this.BuildingDistrict       = targetCorrespondRecord.firstInquiryProperty__r.Building__r.District__c;   // 対応.初回問合せ物件.建物.地区
            }
        }

    }
    
}