/**
 * 対応一覧処理
 */
public with sharing class GA101001Controller {

    /** パブリック変数 */
    public List<screenCorrespond> screenTargetRecordList { get;set; }   // 画面表示用の内部クラスレコード
    
    public List<Correspond__c> correspondList { get;set; }              // 対応の一覧表示
    public Integer correspondIndex { get;set; }                         // 明細行Index
    public Boolean isOpenError { get;set; }                             // 初期表示時のエラーフラグ
    public Boolean hasErrorMessage { get; set; }                        // 初期以降エラーメッセージフラグ

    public String shopsName { get;set; }                                // 来店店舗（リスト選択時）
    public list<SelectOption> selectVisitShopList { get;set; }          // 来店店舗のリスト設定 
    public String shopStaff {get;set;}                                  // 来店ユーザ（リスト選択時）
    public list<SelectOption> selectShopStaffList { get;set; }          // 来店担当者のリスト設定     
    public String recordType { get;set; }                               // レコードタイプ（リスト選択時）
    public List<SelectOption> recordTypeList { get;set; }               // レコードタイプのリスト設定

    public Boolean isShopType { get;set; }                              // 店舗区分（False:インサイドセール、True:インサイドセール以外）
    
    public String  EVENT_EMAIL {get; private set;}                      // 固定値　メール受信
    public String  EVENT_PURSUIT_VIEWED {get; private set;}             // 固定値　追客(閲覧あり)
    public String  EVENT_OTHERSTAFFSUPPORTED {get; private set;}        // 固定値　他スタッフ対応
    public String  EVENT_VISIT_RESERVATION {get; private set;}          // 固定値　来店予約
    public String  EVENT_PROPERTY_INTRODUCTION_POSSIBLE {get; private set;} // 固定値　物件紹介可能
	// ▼ 2021.11.24 LINE連携対応より、"LINE追加"と"LINE受信"を追加
	public String EVENT_LINE_RECEIVE	{get{return CommonConst.CORRESPOND_EVENT_LINE_RECEIVE;} private set;}
	public String EVENT_LINE_FRIEND_ADD	{get{return CommonConst.CORRESPOND_EVENT_LINE_FRIEND_ADD;} private set;}
	// ▲ 2021.11.24
    
    // 問合せ409で変更
    public String  EVENT_AUTO_RECIVE {get; private set;}                // 固定値　自動返信　

    /** プライベート変数 */
    private Boolean countChk;                                           // データ取得有無
    private static final String SupplierRecordType = '業者';            // 管理会社・オーナー・サブリース；SupplierRecordType         
    private static final String CustomerRecordType = '顧客';            // 顧客：CustomerRecordType
    private Boolean isOpetionPortal;                                    // 自社ポータル権限 //問合せNo0433で追加

     /**
     * メイン処理
     * 初回読み込み時の処理
     */
    public GA101001Controller() {
        isOpenError = false;
        try {
            // 初期化   
            init();

            //ログインユーザから店舗を取得する
            // 店舗情報の取得
            Shop__c shop = CommonUtil.getStaffCurrentShop();
            ShopsName = shop.id;                            // 店舗名
            isShopType = shop.IsShopType__c;                // 店舗区分

            if (isShopType == false){
                // インサイドセールス
                shopStaff = CommonConst.STRING_EMPTY;
            }else{
                // インサイドセールス以外
                shopStaff = UserInfo.getUserId();
            }
            //店舗（来店）のリストをセット
            selectVisitShopList = CommonUtil.getShopSelectedOptionFromStaffId(shopStaff,false,false);   

            //来店担当のリストをセット
            selectShopStaffList = CommonUtil.getUserSelectedOptionFromShopId(shopsName,true);

            // レコードタイプのリストをセット
            recordTypeList = getRecordType();
            recordType =  '';

            //権限取得 //問合せNo0433で追加
            this.isOpetionPortal = AuthorityCheckUtil.getAuthorityOptionPortal(false);
            

			//検索処理の実行 // ▼2022.01.18 No.0684 対応で変更：初期の検索は担当者を条件に含めない
			countChk = selectRecordInfo(shopsName,'',recordType);
            if (CountChk == false ){ 
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_NO_DATA));
                // throw ex;
                hasErrorMessage = true;
                CommonUtil.setErrorMessage(ex);
                return;
            } 

            //データを一覧に設定する
            setCorrespondList();

            // 初期表示は全体表示にするため空にしておく
            shopStaff = CommonConst.STRING_EMPTY;

        } catch (Exception e) {
            // エラーを設定
            CommonUtil.setErrorMessage(e);
            isOpenError = true;
        }
    }

    /**
     * 店舗選択後処理
     */
     public void getStaffList(){
        hasErrorMessage = false;
        try {
            //来店担当のリストをセット
            selectShopStaffList = CommonUtil.getUserSelectedOptionFromShopId(shopsName,true);
        }catch (Exception e) {
            // エラーを設定
            CommonUtil.setErrorMessage(e);
            hasErrorMessage = true;
             
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
            countChk = SelectRecordInfo(shopsName,shopStaff,recordType);

            // 件数が0件だった場合
            if (CountChk == false ){ 
                // エラーとして処理                
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
    初期化メソッド
    */
    private void init(){        
        //初期化
        correspondList = new List<Correspond__c>();
        screenTargetRecordList = new List<screenCorrespond>();     
        correspondIndex = 0;
        EVENT_EMAIL = CommonConst.CORRESPOND_EVENT_EMAIL;
        EVENT_PURSUIT_VIEWED = CommonConst.CORRESPOND_EVENT_PURSUIT_VIEWED;
        EVENT_OTHERSTAFFSUPPORTED = CommonConst.CORRESPOND_EVENT_OTHERSTAFFSUPPORTED;
        EVENT_VISIT_RESERVATION = CommonConst.CORRESPOND_EVENT_VISIT_RESERVATION;
        EVENT_PROPERTY_INTRODUCTION_POSSIBLE = CommonConst.CORRESPOND_EVENT_PROPERTY_INTRODUCTION_POSSIBLE;

        // 問合せ409で変更
        EVENT_AUTO_RECIVE = CommonConst.CORRESPOND_EVENT_AUTO_RECIVE;
        CountChk = false;

        this.isOpetionPortal = false;   //問合せNo0433で追加
        
    }

    
    /**
     * 検索処理（対応一覧）
     * 引数によって内容を絞り込んだ一覧を取得する。
     * 引数　　：　shop String 店舗
     * 　　　　：　Staff String 来店担当
     * 　　　　：　recordType Boolean レコードタイプID
     * 戻り値　：　Boolean 件数の取得有無
     */
    private Boolean selectRecordInfo(String shop,String staff,String recordType){
        // 検索SQL作成
        String sql = '';
        sql += 'SELECT Id ';                      // 対応.Id（非表示）
        sql += '      ,Name ';                    // 対応.対応番号（非表示）
        sql += '      ,AccountId__r.ParentId ';   // 対応.取引先ID（非表示）
        sql += '      ,AccountId__r.Name ';       // 対応.取引先ID.取引先名
        sql += '      ,AccountId__r.RecordType.DeveloperName'; //対応．取引先ID.レコードタイプ名
        sql += '      ,Status__c ';               // 対応.ステータス
        sql += '      ,Event__c ';                // 対応.イベント
        sql += '      ,EventDateTime__c ';        // 対応.イベント時刻
        sql += '      ,ShopStaff__r.Username ';   // 対応.担当者（店舗）.ユーザ名
        sql += '      ,ShopStaff__r.Name ';       // 対応.担当者（店舗）.氏名
        sql += '      ,ShopStaff__r.Department '; // 対応.ユーザ.部署
        sql += '      ,PortalSite__r.Name ';      // 対応.ポータルサイト.サイト名
        sql += '      ,AccountId__r.Phone ';      // 対応.取引先 ID.電話番号
        sql += '      ,Memo__c ';                 // 対応.メモ
        sql += '      ,StaffSupportedFlg__c';     // 対応.スタッフ対応フラグ
        // 問合せ409で変更
        sql += '      ,AutomaticReplyAfterPursuitFlg__c';    // 対応.自動返信後追客フラグ
		// ▼ 2021.11.24 LINE連携対応より、LINE会員を追加・修正
		sql += '	  ,LineMember__c';
		sql += '	  ,LineMember__r.Account__c';
		// ▲ 2021.11.24
        sql += ' FROM  Correspond__c         ';
        // '来店済','来店後検討','未収入金','入金済','来店後追客中','申込キャンセル','申込キャンセル後追客中',アポイント確定,アポイントキャンセル,アポキャンセル後追客中、契約完了、終了
        //2020/6/16変更：追客保留中で、保留前ステータスがアポイントキャンセル,アポキャンセル後追客中','来店後検討','来店後追客中',申込キャンセル','申込キャンセル後追客中'のどれか
        sql += ' WHERE ((Status__c in (\''   + CommonConst.CORRESPOND_STATUS_VISITED + '\',\'' 
                                            + CommonConst.CORRESPOND_STATUS_CONSIDERVISITING + '\',\'' 
                                            + CommonConst.CORRESPOND_STATUS_UNEARNED + '\',\'' 
                                            + CommonConst.CORRESPOND_STATUS_DEPOSIT + '\',\'' 
                                            + CommonConst.CORRESPOND_STATUS_VISITED_PURSUIT + '\',\'' 
                                            + CommonConst.CORRESPOND_STATUS_APPLCANCEL + '\',\'' 
                                            + CommonConst.CORRESPOND_STATUS_APPLCANCEL_PURSUIT + '\',\''
                                            + CommonConst.CORRESPOND_STATUS_APPOINTMENT + '\',\'' 
                                            + CommonConst.CORRESPOND_STATUS_APOCANCEL + '\',\'' 
                                            + CommonConst.CORRESPOND_STATUS_APOCANCEL_PURSUIT + '\',\'' 
                                            + CommonConst.CORRESPOND_STATUS_AGREEMENT + '\',\'' 
                                            + CommonConst.CORRESPOND_STATUS_CLOSE + '\')'; 
        sql += '		OR  (Status__c =\'' + CommonConst.CORRESPOND_STATUS_PURSUITHOLD + '\'';//追客保留中かつ
        sql += '			 AND (     StatusBeforePursuitHold__c =\'' + CommonConst.CORRESPOND_STATUS_APOCANCEL + '\'';//保留前ステータスが アポイントキャンセル		        
        sql += '				  OR   StatusBeforePursuitHold__c =\'' + CommonConst.CORRESPOND_STATUS_APOCANCEL_PURSUIT + '\'';//アポキャンセル後追客
        sql += '				  OR   StatusBeforePursuitHold__c =\'' + CommonConst.CORRESPOND_STATUS_CONSIDERVISITING + '\'';//来店後検討
        sql += '				  OR   StatusBeforePursuitHold__c =\'' + CommonConst.CORRESPOND_STATUS_VISITED_PURSUIT + '\'';//来店後追客
        sql += '				  OR   StatusBeforePursuitHold__c =\'' + CommonConst.CORRESPOND_STATUS_APPLCANCEL + '\'';//申込キャンセル
        sql += '				  OR   StatusBeforePursuitHold__c =\'' + CommonConst.CORRESPOND_STATUS_APPLCANCEL_PURSUIT + '\'';//申込キャンセル後追客
        sql += '			  	 )';
        sql += '			)';
        sql += '		)';
        sql += ' AND (ListViewDate__c <= ' + CommonUtil.getNow().formatGmt('yyyy-MM-dd\'T\'hh:mm:ss.SSS\'Z\'');   // 一覧表示日時
        sql += '       OR    IsSupportedListShow__c = FALSE ';          // 対応確認フラグ
        sql += '       OR    IsBrowseFlg__c = FALSE ';                  // 閲覧フラグ
        sql += '       OR    StaffSupportedFlg__c = FALSE ) ';          // スタッフ対応フラグ
        // 店舗
        sql += ' AND VisitShop__c  =\'' + CommonUtil.escapeSingleQuotesEx(shop) + '\'';
        // 来店担当
        if (staff != '全表示' && string.isBlank(staff) == False ) {
            // 来店担当が全表示以外
            sql += ' AND  ShopStaff__c =\'' + CommonUtil.escapeSingleQuotesEx(staff) + '\'';  
        }      
        // レコードタイプ
        if(recordType==String.valueOf(commonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_SUPPLIER))){
            // 業者
            sql += ' AND AccountId__r.RecordType.DeveloperName = \'' + CommonConst.ACCOUNT_RECTYPE_SUPPLIER + '\'';
        }else if(recordType==String.valueOf(commonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_CUSTOMER))) {
            // 顧客
            sql += ' AND AccountId__r.RecordType.DeveloperName = \'' + CommonConst.ACCOUNT_RECTYPE_CUSTOMER + '\'';
        }     
        sql += ' ) ';
           
        // メール分
        sql += ' OR (ReceiveMailDateOther__c != NULL';            // その他のメール受信がある
        // 来店担当
        if (staff != '全表示' && string.isBlank(staff) == False ) {
            // 来店担当が全表示以外
            // sql += ' AND ShopStaff__c =\'' + staff + '\'';     // 設定しているスタッフ
            sql += ' AND (ShopStaff__c =\'' + CommonUtil.escapeSingleQuotesEx(staff) + '\'';     // 設定しているスタッフ
            sql += ' OR  ShopStaff__c = null) ';                // もしくは登録のないスタッフ
        }      
        sql += '     AND   VisitShop__c  =\'' + CommonUtil.escapeSingleQuotesEx(shop) + '\'';            // 店舗の設定（メール受信時に対応一覧は店舗が紐づいている内容で来るため）
        sql += '     AND   VisitShop__r.IsShopType__c = true';         // IS店舗でない

        // // 顧客未設定分
        // sql += '      OR  (ShopStaff__c  = null ';  
        // sql += '     AND   EchoStaff__c  = null)) ';  
        
        sql += '     AND   Status__c  =  \'' + CommonConst.CORRESPOND_STATUS_NOTSUPPORTED + '\'';   //未対応
        sql += ')';


        // 業者の新規問合せ
        if(recordType!=String.valueOf(commonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_CUSTOMER))) {
            // 業者の対処となった時のみ
            sql += ' OR ((ListViewDate__c <= ' + CommonUtil.getNow().formatGmt('yyyy-MM-dd\'T\'hh:mm:ss.SSS\'Z\'');   // 一覧表示日時
            sql += '       OR    IsSupportedListShow__c = FALSE ';          // 対応確認フラグ
            sql += '       OR    IsBrowseFlg__c = FALSE ';                  // 閲覧フラグ
            sql += '       OR    StaffSupportedFlg__c = FALSE ) ';          // スタッフ対応フラグ
            if (staff != '全表示' && string.isBlank(staff) == False ) {
                // 来店担当が全表示以外
                sql += ' AND  ShopStaff__c =\'' + CommonUtil.escapeSingleQuotesEx(staff) + '\'';  
            }   
            sql += ' AND AccountId__r.RecordType.DeveloperName = \'' + CommonConst.ACCOUNT_RECTYPE_SUPPLIER + '\'';
            sql += ')';
        }


        sql += ' ORDER BY  EventDateTime__c DESC ';       //対応.イベント時刻（昇順）

        // 検索実行＆結果返却
        correspondList = Database.query(sql);

        // 件数が取れない場合
        if (correspondList.size() == 0 ){
            return false;
        }

        return true;
    }
  

    /**
     * レコードタイプの一覧をセットする
     * 戻り値　： List<SelectOption> レコードタイプ
     */
    public List<SelectOption> getRecordType(){
        List<SelectOption> options = new List<SelectOption>();
        
        // 全件用に先頭にセットする。
        // options.add(new SelectOption('全表示','全表示'));
        options.add(new SelectOption('',CommonConst.SELECTION_LIST_NULL));
        options.add(new SelectOption(commonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER),CustomerRecordType));     // 顧客：CustomerRecordType
        options.add(new SelectOption(commonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_SUPPLIER),SupplierRecordType));     // 管理会社・オーナー・サブリース；SupplierRecordType

        return options;

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
        // screenTargetRecordList = new List<ScreenCorrespond>();

        //▼問合せNo0433で追加
        // 紹介メール情報の取得
        Set<id> introMailInfoCorrespondIdSet = selectIntroMailInfo();
        //▲問合せNo0433で追加
        
        //内部クラスに値をセットする。
        for(Correspond__c candidate :correspondList) {

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
        public Correspond__c targetCorrespondRecord{ get; set;}    //レコード本体（対応）
        
        //以下、画面用の項目
        public String  Id                  { get; set; }    // 対応.Id（非表示）
        public String  Name                { get; set; }    // 対応.対応番号（非表示）
        public String  AccountIdParentId   { get; set; }    // 対応.取引先ID（非表示）
        public String  AccountIdName       { get; set; }    // 対応.取引先 ID.取引先名
        public String  Status              { get; set; }    // 対応.ステータス
        public String  Event               { get; set; }    // 対応.イベント
        public String  EventDateTime       { get; set; }    // 対応.イベント時刻
        public String  shopStaffUsername   { get; set; }    // 対応.担当者（来店）.ユーザ名
        public String  shopStaffName       { get; set; }    // 対応.担当者（来店）.氏名
        public String  shopStaffDepartment { get; set; }    // 対応.ユーザ.部署
        public String  PortalSiteName      { get; set; }    // 対応.ポータルサイト.サイト名
        public String  AccountIdPhone      { get; set; }    // 対応.取引先 ID.電話番号
        public String  Memo                { get; set; }    // 対応.メモ
        public String  RecordType          { get; set; }    // 対応.レコードタイプ
        public Boolean staffSupportedFlg   { get; set; }    // 対応.スタッフ対応フラグ
        // 問合せ409で変更
        public Boolean AutomaticReplyAfterPursuitFlg { get; set; }    // 対応.自動返信後追客フラグ
		// ▼ 2021.11.24 LINE連携対応より、"LINE会員ID"と"LINE未紐づけフラグ"を追加
		public Id		lineMemberId			{get;set;}
		public Boolean	isUnlinkedLineMember	{get;set;}
		// ▲ 2021.11.24
        
        //コンストラクタ
        public screenCorrespond(Correspond__c targetCorrespondRecord){

            //取引先レコードの連動
            this.targetCorrespondRecord = targetCorrespondRecord;   
            this.Id                     = targetCorrespondRecord.Id;                        // 対応.Id（非表示）
            this.Name                   = targetCorrespondRecord.Name;                      // 対応.対応番号（非表示）
            this.AccountIdParentId      = targetCorrespondRecord.AccountId__c;              // 対応.取引先ID（非表示）
            this.AccountIdName          = targetCorrespondRecord.AccountId__r.Name ;        // 対応.取引先 ID.取引先名
            this.Status                 = targetCorrespondRecord.Status__c;                 // 対応.ステータス
            this.Event                  = targetCorrespondRecord.Event__c;                  // 対応.イベント
            if (targetCorrespondRecord.EventDateTime__c != null) {
                this.EventDateTime      = targetCorrespondRecord.EventDateTime__c.format('yyyy/MM/dd HH:mm', 'JST');          // 対応.イベント時刻
            }
            this.shopStaffUsername      = targetCorrespondRecord.shopStaff__r.Username;     // 対応.担当者（来店）.ユーザ名
            this.shopStaffName          = targetCorrespondRecord.shopStaff__r.Name;         // 対応.担当者（来店）.氏名            
            if (targetCorrespondRecord.shopStaff__r.Department != null) {
                this.shopStaffDepartment    =  '（'+ targetCorrespondRecord.shopStaff__r.Department + '）';   // 対応.ユーザ.部署
            }
            this.PortalSiteName         = targetCorrespondRecord.PortalSite__r.Name;        // 対応.ポータルサイト.サイト名
            this.AccountIdPhone         = targetCorrespondRecord.AccountId__r.Phone;        // 対応.取引先 ID.電話番号
            this.Memo                   = targetCorrespondRecord.Memo__c;                   // 対応.メモ
            this.staffSupportedFlg      = targetCorrespondRecord.StaffSupportedFlg__c;      // 対応.スタッフ対応フラグ
            // 問合せ409で変更
            this.AutomaticReplyAfterPursuitFlg = targetCorrespondRecord.AutomaticReplyAfterPursuitFlg__c; // 対応.自動返信後追客フラグ
            //レコードタイプ
            if (targetCorrespondRecord.AccountId__r.RecordType.DeveloperName != null) {
                if (targetCorrespondRecord.AccountId__r.RecordType.DeveloperName == commonConst.ACCOUNT_RECTYPE_CUSTOMER)
                    this.RecordType = '顧客';
                else {
                    this.RecordType = '業者';
                }
            }
			// ▼ 2021.11.24 LINE連携対応より、"LINE会員ID"と"LINE未紐づけフラグ"を追加
			this.lineMemberId = targetCorrespondRecord.LineMember__c;
			this.isUnlinkedLineMember =
				String.isBlank(targetCorrespondRecord.LineMember__r.Account__c) && String.isNotBlank(this.lineMemberId);
			// ▲ 2021.11.24


            convertNull();
        }

        public screenCorrespond(){

            //取引先レコードの連動
            this.Id                     = '';   // 対応.Id（非表示）
            this.Name                   = '';   // 対応.対応番号（非表示）
            this.AccountIdParentId      = '';   // 対応.取引先ID（非表示）
            this.AccountIdName          = '';   // 対応.取引先 ID.取引先名
            this.Status                 = '';   // 対応.ステータス
            this.Event                  = '';   // 対応.イベント
            this.EventDateTime          =null;  // 対応.イベント時刻
            this.shopStaffUsername      = '';   // 対応.担当者（来店）.ユーザ名
            this.shopStaffName          = '';   // 対応.担当者（来店）.氏名            
            this.shopStaffDepartment    = '';   // 対応.ユーザ.部署
            this.PortalSiteName         = '';   // 対応.ポータルサイト.サイト名
            this.AccountIdPhone         = '';   // 対応.取引先 ID.電話番号
            this.Memo                   = '';   // 対応.メモ
            this.RecordType             = '';   // 対応.レコードタイプ
			// ▼ 2021.11.24 LINE連携対応より、"LINE会員ID"と"LINE未紐づけフラグ"を追加
			this.lineMemberId			= CommonConst.STRING_EMPTY;
			this.isUnlinkedLineMember	= false;
			// ▲ 2021.11.24
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
            this.shopStaffUsername   = String.isBlank(this.shopStaffUsername)?   null : this.shopStaffUsername;
            this.shopStaffName       = String.isBlank(this.shopStaffName)?       'なし' : this.shopStaffName;
            this.shopStaffDepartment = String.isBlank(this.shopStaffDepartment)? null : this.shopStaffDepartment;
            this.PortalSiteName      = String.isBlank(this.PortalSiteName)?      null : this.PortalSiteName;
            this.AccountIdPhone      = String.isBlank(this.AccountIdPhone)?      null : this.AccountIdPhone;
            this.Memo                = String.isBlank(this.Memo)?                null : this.Memo;
            this.RecordType          = string.isBlank(this.RecordType)?          null : this.RecordType;
			// ▼ 2021.11.24 LINE連携対応より、"LINE会員ID"を追加
			this.lineMemberId		 = String.isBlank(this.lineMemberId)? null: this.lineMemberId;
			// ▲ 2021.11.24
        }
    }

}