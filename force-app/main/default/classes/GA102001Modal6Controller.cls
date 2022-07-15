//スケジュールボタン
public with sharing class GA102001Modal6Controller {

    /** 共通クラス */    
    public GA102001Modal6ParameterClass Parameter { get; set; }

    /** エラーフラグ */ 
    public Boolean isOpenError { get; set; }
    
    /** エラーメッセージ保有フラグ */ 
    public Boolean hasErrorMessage { get; set; } 

    public String MSG_COM_V_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_SAVE);} private set;}   // 登録確認メッセージ
    public String MSG_COM_I_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);} private set;}   // 登録完了メッセージ
    
    public Correspond__c Correspond ;          // 対応データ
    public screenCorrespondDetail screenCorrespondDetail { get;set; }   // 対応明細データ

    //選択リスト
    public List<SelectOption> selectScheduleDetailsList { get;set; }    // スケジュール詳細
    public List<SelectOption> selectShopList { get;set; }               // 店舗
    public List<SelectOption> selectStaffList { get;set; }              // 担当者
    public List<SelectOption> screenFavoritePropertyList { get;set; }   // お気に入り物件

    public String loginShop { get;set; }            // ログインユーザ店舗
    public String loginStaff { get;set; }           // ログインユーザ
    public Boolean isChoiceStaffFlg { get;set; }    // 担当者選択フラグ

    //初期表示  
    public Boolean init{
        get{
            if (Parameter.isDrawing) {
                this.isChoiceStaffFlg = false;
                getSelectOption();
                Parameter.isDrawing = false;
                return false;
            }
            return true;
        }
    }

    //選択リストの設定 
    public void getSelectOption() {

        try{
            this.Correspond = new Correspond__c();
            List<CorrespondDetail__c> CorrespondDetail = new List<CorrespondDetail__c>();

            // 店舗情報の取得
            Shop__c shop = CommonUtil.getStaffCurrentShop();
            this.loginShop = shop.id;
            this.loginStaff = UserInfo.getUserId(); 
            this.selectStaffList = new List<SelectOption>();       

            // 対応IDから項目を取得
            List<Correspond__c> CorrespondList = selectCorrespondInfo(Parameter.CorrespondId);
            if (CorrespondList.size() > 0){
                this.Correspond = CorrespondList[0];
            }        

            screenCorrespondDetail = new screenCorrespondDetail();            
            // スケジュール詳細のリストをセット(対応種別に設定)
            this.selectScheduleDetailsList = CommonUtil.getSelectOptionFromObject('CorrespondDetail__c', 'scheduleDetails__c',true);
            
            // 店舗のリストをセット
            selectShopList = CommonUtil.getShopSelectedOptionFromStaffId(CommonConst.STRING_EMPTY,True);
            
            // 担当者のリストをセット
            if (String.isNotBlank(this.Correspond.VisitShop__c)){ //来店店舗が設定されている
                selectStaffList = CommonUtil.getUserSelectedOptionFromShopId(this.Correspond.VisitShop__c,True);
            }else if(String.isNotBlank(this.Correspond.EchoShop__c)){ //反響店舗が設定されている
                selectStaffList = CommonUtil.getUserSelectedOptionFromShopId(this.Correspond.EchoShop__c,True);
            }else {
                selectStaffList.add(new SelectOption(CommonConst.STRING_EMPTY,CommonConst.SELECTION_LIST_NULL)); 
            }

            // 店舗・担当者の初期表示
            setShopStaff();
            
            //お気に入り物件のリストをセット
            setFavoriteProperty();            

        } catch (Exception e) {
            // エラーを設定          
            CommonUtil.setErrorMessage(e);
        }
    }

    //店舗・担当者の初期表示  
    private void setShopStaff(){
        if (String.isNotBlank(this.Correspond.VisitShop__c)){ //来店店舗が設定されている
            selectStaffList = CommonUtil.getUserSelectedOptionFromShopId(this.Correspond.VisitShop__c,True);
            
            // 店舗・担当者の初期表示
            this.screenCorrespondDetail.Shop = this.Correspond.VisitShop__c ;      // 店舗
            this.screenCorrespondDetail.Staff = this.Correspond.ShopStaff__c ;      // 担当者
        
        }else if(String.isNotBlank(this.Correspond.EchoShop__c)){ //反響店舗が設定されている
            selectStaffList = CommonUtil.getUserSelectedOptionFromShopId(this.Correspond.EchoShop__c,True);

            // 店舗・担当者の初期表示
            this.screenCorrespondDetail.Shop = this.Correspond.EchoShop__c ;      // 店舗
            this.screenCorrespondDetail.Staff = this.Correspond.EchoStaff__c ;      // 担当者    
        }
    }

    //お気に入り物件のリストをセット
    public void setFavoriteProperty(){
        this.screenFavoritePropertyList = new List<SelectOption>();
        this.screenFavoritePropertyList.add(new SelectOption('', commonConst.SELECTION_LIST_NULL));
        
        //物件が紐づけられていれば、その物件のみ選択可能
        if(this.Correspond.Property__c != null){
            this.screenFavoritePropertyList.add(new SelectOption(this.Correspond.Property__c
                                            , this.Correspond.Property__r.Building__r.Name + ' ' + this.Correspond.Property__r.Name));
            return;
        }


        List<FavoriteProperty__c> favoritePropertyList = [ SELECT id
                                                            ,Account__c                     //取引先
                                                            ,Property__c                    //物件id
                                                            ,Property__r.Building__c        //物件.建物ID
                                                            ,Property__r.Building__r.Name   //物件.建物.建物名
                                                            ,Property__r.Name               //物件.部屋番号
                                                          	,BuildingYM__c					//築年
                                                          FROM FavoriteProperty__c        
                                                          WHERE Account__c = :this.Correspond.AccountId__c
                                                          ORDER BY BuildingYM__c DESC              		// 築年
                                                          			,Property__r.Building__r.Name ASC   // 物件.建物.建物名
                                                          			, Property__r.Name ASC ];			//物件.部屋番号

        if (favoritePropertyList.size() > 0){
            // リストにセット            
            for(FavoriteProperty__c data:favoritePropertyList){
                this.screenFavoritePropertyList.add(new SelectOption(data.id, data.Property__r.Building__r.Name + ' ' + data.Property__r.Name));
            }            
        }    
    }


    /**
     * 店舗のリストを変更
     */
    public void getShopList(){
        try{
            // 担当者のリストをセット
            if (string.isBlank(screenCorrespondDetail.Shop)){
                selectStaffList = new List<SelectOption>();     //リストの初期化
                selectStaffList.add(new SelectOption(CommonConst.STRING_EMPTY,CommonConst.SELECTION_LIST_NULL));
            }else {
                selectStaffList = CommonUtil.getUserSelectedOptionFromShopId(screenCorrespondDetail.Shop,True);
                screenCorrespondDetail.Staff = CommonConst.STRING_EMPTY;
            }
        } catch (Exception e) {
            // エラーを設定
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    /**
     * 対応種別（＝スケジュール詳細）のリストを変更
     */
    public void changeScheduleDetails(){
        //スケジュール詳細が再来or契約or確認案内のとき
        if (screenCorrespondDetail.ScheduleDetails == CommonConst.TASK_CORRESPONDTYPE_RETURN ||
            screenCorrespondDetail.ScheduleDetails == CommonConst.TASK_CORRESPONDTYPE_CONTRACT ||
            screenCorrespondDetail.ScheduleDetails == CommonConst.TASK_CORRESPONDTYPE_CONFIRM ){

            //担当者選択フラグをtrueにする(選択できる)
            this.isChoiceStaffFlg = true;           

        }else{
            //担当者選択フラグをfalseにする(選択できない)
            this.isChoiceStaffFlg = false;
            setShopStaff();
        }
    }

    /**
     * 登録処理
     * 引数　　：　Id String 所属部署
     * 戻り値　：
     */
    public void saveData(){

        Savepoint sp = Database.setSavepoint();      //セーブポイント作成
        hasErrorMessage = false;
        BusinessLogicException inputCheckException = new BusinessLogicException();
        try{
            // 楽観ロックチェック
            OptimisticLockCheck(this.Correspond);

            //入力チェック
            inputCheckException = inputCheck(); 
            if(inputCheckException.hasMessage()){ // エラーあり
                throw inputCheckException;
            }

            //行動レコードを登録
            saveEvent(Parameter.AccountId);                        
            
            // 対応の登録、更新
            String CorrespondId =  saveCorrespond(Parameter.CorrespondId,this.Correspond);
                 
            // 対応明細の登録
            saveCorrespondDetail(CorrespondId,Parameter.AccountId);

        }catch(Exception e){
            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;//エラーを設定

            CommonUtil.setErrorMessage(e);
        }
    }

    /**
     * 楽観ロックチェック
     * 引数　　：　Correspond Correspond__c 対象の対応オブジェクト
     */
    private void OptimisticLockCheck(Correspond__c Correspond){
        //楽観ロックチェックExceptionを発行(対応)
        List<Correspond__c> checkOptimisticLockExceptionRecord = new List<Correspond__c>();
        checkOptimisticLockExceptionRecord = [ SELECT id
                                                    FROM Correspond__c
                                                    WHERE id = :Correspond.Id
                                                    AND SystemModStamp = :Correspond.systemModStamp ]; //楽観ロックチェック
        if (checkOptimisticLockExceptionRecord.isEmpty()){
            OptimisticLockException ex = new OptimisticLockException();
            throw ex;
        }
    }

    /**
     * 入力チェック
     * 戻り値　：  エラー有無
     */
    private BusinessLogicException inputCheck(){
        BusinessLogicException inputCheckException = new BusinessLogicException();
        //必須入力チェック    
        List<String> requiredItem = new List<String>();//入力チェックリストを初期化

        // 対応種別が入力されていない
        if (screenCorrespondDetail.ScheduleDetails == null) {
            requiredItem.add('対応種別');
        }
        // 開始日時_年月日が入力されていない、開始日時_時分が入力されていない
        if (screenCorrespondDetail.StartDate == null || screenCorrespondDetail.StartDateTime == null) {
            requiredItem.add('開始日時');
        }
        // 終了日時_年月日が入力されていない、終了日時_時分が入力されていない
        if (screenCorrespondDetail.EndDate == null || screenCorrespondDetail.EndDateTime == null) {
            requiredItem.add('終了日時');
        }
        // 店舗が入力されていない
        if (screenCorrespondDetail.Shop == null) {
            requiredItem.add('店舗');
        }
        // 担当者が入力されていない
        if (screenCorrespondDetail.Staff == null) {
            requiredItem.add('担当者');
        }

        // エラーが無ければチェックする
        if(requiredItem.size() == 0){
            Datetime startDateTime = Datetime.newInstance(screenCorrespondDetail.StartDate , screenCorrespondDetail.StartDateTime);
            Datetime endDateTime   = Datetime.newInstance(screenCorrespondDetail.EndDate ,screenCorrespondDetail.EndDateTime);

            if( endDateTime < startDateTime){
                //終了日に開始日より前の日付が設定されています。終了日は開始日以降を設定してください。
                inputCheckException.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_DATE_TERM));
            }
            
            // 有効なユーザで登録できるか判定
            if(!userIsActive(screenCorrespondDetail.Staff)){
                inputCheckException.addMessage(CommonUtil.callMessageCreate('スケジュール登録が行えませんでした、登録するユーザが無効となっています。'));
            }
        }            

        if (!requiredItem.isEmpty()){//入力チェック用リストが空ではない場合、エラー追加                
            inputCheckException.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED,String.join(requiredItem, ',')));
        }

        return inputCheckException;
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
     * 登録処理(行動)
     * 引数　 ：  AccountId String 取引先
     * 戻り値 ：  Boolean
     */
    private Boolean saveEvent(String AccountId){    
        Event saveData = new Event();

        //件名を作成(【スケジュール詳細】+ 表題)
        String subject =  '【' + screenCorrespondDetail.ScheduleDetails + '】' +  screenCorrespondDetail.SupportedTitle;

        // 保存項目
        saveData.Subject       = subject  ;   // 件名															
        saveData.StartDateTime = Datetime.newInstance(screenCorrespondDetail.StartDate,screenCorrespondDetail.StartDateTime);	// 開始日時	
        saveData.EndDateTime   = Datetime.newInstance(screenCorrespondDetail.EndDate,screenCorrespondDetail.EndDateTime);// 終了日時															
        saveData.Description   = setSupportedContent(screenCorrespondDetail,false); // 説明	
        saveData.Shop__c       = screenCorrespondDetail.Shop  ;        // 店舗	
        saveData.WhatId        = AccountId;  // 関連先ID（取引先ID）
        saveData.OwnerId       = screenCorrespondDetail.Staff;
        
        SecureDML.secureInsert(saveData);

        return True;
    }

    /**
     * 登録処理(対応)
     * 引数　　：  Id String 対応ID
     * 　　　　：  Correspond Correspond__c 対応データ
     * 戻り値　：  String 対応Id
     */
    private string saveCorrespond(String Id, Correspond__c Correspond){
        // 保存処理
        Correspond__c saveData = new Correspond__c();

        saveData.Id = Id;
        saveData.EventDateTime__c = CommonUtil.getNow();// イベント時刻	

        SecureDML.secureUpdate(saveData);
        return saveData.Id;
    }
   

    /**
     * 登録処理(対応明細)
     * 引数　　：　CorrespondId String 対応Id
     * 　　　　：　AccountId String 取引先
     * 戻り値　：  Boolean
     */
    private Boolean saveCorrespondDetail(String CorrespondId,String AccountId){
        // 保存処理
        CorrespondDetail__c saveData = new CorrespondDetail__c();

        saveData.Corresponds__c         = CorrespondId;                 // 対応ID
        saveData.CorrespondType__c      = screenCorrespondDetail.ScheduleDetails;    // 対応種別        
        saveData.SupportedDateTime__c   = CommonUtil.getNow();          // 対応日時
        saveData.Shop__c                = this.loginShop;               // 店舗
        saveData.Staff__c               = this.loginStaff;              // 担当者
        saveData.SupportedTitle__c      = screenCorrespondDetail.SupportedTitle;    // 対応表題
        saveData.SupportedContent__c    = setSupportedContent(screenCorrespondDetail,true);   // 対応内容          
        saveData.StartDate__c           = screenCorrespondDetail.StartDate;            //開始日時_年月日
        saveData.StartDateTime__c       = DateTime.newInstance(screenCorrespondDetail.StartDate, screenCorrespondDetail.StartDateTime).format('HH:mm'); //開始日時_時分                        //終了日時_時分
        saveData.EndDate__c             = screenCorrespondDetail.EndDate;                //終了日時_年月日
        saveData.EndDateTime__c         = DateTime.newInstance(screenCorrespondDetail.endDate, screenCorrespondDetail.EndDateTime).format('HH:mm'); //終了日時_時分
    
        SecureDML.secureUpsert(saveData);

        return True;
    }

    /**
     * 対応内容（対応明細）または説明（行動）を作成する
     * 引数　　：  screenCorrespondDetail 表示項目
     * 			   isSupportedContent 対応内容かどうか
     * 　　　　：  
     * 戻り値　：  対応内容
     */
    private String setSupportedContent(screenCorrespondDetail screenCorrespondDetail,Boolean isSupportedContent){
        // 
        String supportedContent = '';
        String favoriteProperty = getSelectOptionLabel(screenFavoritePropertyList, screenCorrespondDetail.BuildingName);//選択された物件        
        // ”スケジュール”
        // ”店舗：”	& {!画面.店舗} 
        // " 担当者：”	& {!画面.担当者} 　
        // ”開始時間：”& {!画面.開始日時} 　
        // ”終了時間：”& {!画面.終了日時}　
        // ”物件：”	& {!画面.物件} 
        // ”内容：”	& {!画面.対応内容}
     
        if(isSupportedContent){ //対応内容だけで入れる項目
            SupportedContent += 'スケジュール' + commonconst.BREAK_CODE;
            SupportedContent += '店舗：' + getSelectOptionLabel(selectShopList, screenCorrespondDetail.Shop) + commonconst.BREAK_CODE; 
            SupportedContent += '担当者：' + getSelectOptionLabel(selectStaffList, screenCorrespondDetail.Staff) + commonconst.BREAK_CODE; 
            SupportedContent += '開始時間：' + Datetime.newInstance(screenCorrespondDetail.StartDate , screenCorrespondDetail.StartDateTime).format('yyyy/MM/dd HH:mm') + commonconst.BREAK_CODE;
            SupportedContent += '終了時間：' + Datetime.newInstance(screenCorrespondDetail.EndDate , screenCorrespondDetail.EndDateTime).format('yyyy/MM/dd HH:mm') + commonconst.BREAK_CODE;
        }        
        SupportedContent += '物件：' + (favoriteProperty == null ? '' : favoriteProperty) + commonconst.BREAK_CODE;
        SupportedContent += '内容：' + screenCorrespondDetail.SupportedContent ;

        return SupportedContent;
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
    
    /**
     * 検索処理（対応履歴：対応）
     * 引数によって内容を絞り込んだ一覧を取得する。
     * 引数　　：  CorrespondId String 対応ID
     * 戻り値　：  List<Correspond__c> 対応のデータ
     */
    private List<Correspond__c> selectCorrespondInfo(String CorrespondId ){
        // 検索SQL作成
        String sql = '';
        sql += 'SELECT Id ';                // 対応.ID
        sql += '      ,AccountId__c ';      // 対応.取引先
        sql += '      ,Status__c ';         // 対応.ステータス
        sql += '      ,EchoShop__c ';       // 対応.反響担当店舗
        sql += '      ,VisitShop__c ';      // 対応.来店担当店舗
        sql += '      ,EchoStaff__c ';      // 対応.反響担当
        sql += '      ,ShopStaff__c ';      // 対応.来店担当
        sql += '      ,Property__c ';       // 対応.物件
        sql += '      ,Property__r.Building__r.Name ';       // 対応.物件.建物.建物名
        sql += '      ,Property__r.Name ';  // 対応.物件.部屋番号
        sql += '      ,EventDateTime__c ';  // 対応.イベント時刻 
        sql += '      ,SystemModstamp ';    // 対応.SystemModstamp
        sql += ' FROM  Correspond__c ';                         // 対応
        sql += ' WHERE Id = \'' + CorrespondId + '\'' ;         // 対応ID

        // 検索実行＆結果返却
        return Database.query(sql);

    }

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
        public String  Shop                 { get; set; }    // 行動.店舗
        public String  Staff                { get; set; }    // 行動.任命先
        public Date    StartDate            { get; set; }    // 行動.開始日
        public time    StartDateTime        { get; set; }    // 行動.開始時
        public Date    EndDate              { get; set; }    // 行動.終了日
        public time    EndDateTime          { get; set; }    // 行動.終了時
        public String  BuildingName         { get; set; }    // 対応.建物.建物名（部屋番号あり）
        public String  SupportedContent     { get; set; }    // 対応明細.対応内容
        public String  ScheduleDetails      { get; set; }    // 対応明細.スケジュール詳細                


        //コンストラクタ
        public screenCorrespondDetail(CorrespondDetail__c targetCorrespondDetailRecord){
            //レコードの連動
            this.targetCorrespondDetailRecord1    = targetCorrespondDetailRecord;   
            this.Id                  = targetCorrespondDetailRecord.Id;                     // 対応.Id（非表示）
            this.systemModStamp      = targetCorrespondDetailRecord.systemModStamp ;        // systemModStamp
            this.CorrespondType      = targetCorrespondDetailRecord.CorrespondType__c ;     // 対応明細.対応種別
            this.SupportedTitle      = targetCorrespondDetailRecord.SupportedTitle__c ;     // 対応明細.対応表題
            this.Shop                = targetCorrespondDetailRecord.Corresponds__r.VisitShop__c;   // 対応.来店担当者店舗
            this.Staff               = targetCorrespondDetailRecord.Corresponds__r.ShopStaff__c;   // 対応.来店担当者担当者
            this.BuildingName        = targetCorrespondDetailRecord.Corresponds__r.Property__r.Building__r.Name +
                                       targetCorrespondDetailRecord.Corresponds__r.Property__r.Name;   // 対応.建物.建物名(部屋番号あり)
            this.SupportedContent    = targetCorrespondDetailRecord.SupportedContent__c ;   // 対応明細.対応内容
            this.ScheduleDetails     = targetCorrespondDetailRecord.scheduleDetails__c;    // 対応明細.スケジュール詳細
            convertNull();
        }

        public screenCorrespondDetail(){

            //レコードの連動
            this.Id                  = '';              // 対応.Id（非表示）
            this.CorrespondType      = CorrespondType ; // 対応明細.対応種別
            this.SupportedTitle      = '' ;             // 対応明細.対応表題
            this.SupportedContent    = '' ;             // 対応明細.対応内容
            this.ScheduleDetails     = null;            // 対応明細.スケジュール詳細
            this.Shop                = null;            // 行動.店舗
            this.Staff               = null;            // 行動.任命先
            this.StartDateTime       = null;            // 行動.開始日
            this.EndDate             = null;            // 行動.開始時
            this.EndDateTime         = null;            // 行動.終了日
            this.StartDate           = null;            // 行動.終了時
            convertNull();
        }

        //null系を変換する
        public void convertNull() {            
            this.Id                  = String.isEmpty(this.Id)? '' : this.Id;                                   // 対応.Id（非表示）
            this.CorrespondType      = String.isEmpty(this.CorrespondType     )? '' : this.CorrespondType     ; // 対応明細.対応種別
            this.SupportedTitle      = String.isEmpty(this.SupportedTitle     )? '' : this.SupportedTitle     ; // 対応明細.対応表題
            this.SupportedContent    = String.isEmpty(this.SupportedContent   )? '' : this.SupportedContent   ; // 対応明細.対応内容
            this.ScheduleDetails     = String.isEmpty(this.ScheduleDetails    )? '' : this.ScheduleDetails    ; // 対応明細.スケジュール詳細
        }
    }


}