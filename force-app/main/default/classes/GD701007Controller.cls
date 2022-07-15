/* *
 * 電物メンテ一覧画面のコントローラ
 */
public inherited sharing class GD701007Controller {
    /** パブリック変数 */
    public Boolean isOpenError{get;set;}
    public Id shopId { get; set; }                                      // 店舗ID
    public String FormerSupplier { get; set; }                          // 元付業者
    public String Districts { get; set; }                               // 地区
    public String SearchDistricts { get; set; }                         // 地区（検索時の値）
    public Integer AccountIndex { get; set; }                           // 明細行Index
    public Boolean hasErrorMessage { get; set; }                        // エラーメッセージ保有フラグ
    public List<screenRecordClass> screenRecordClassList { get; set; }  // 明細表示用内部クラスリスト
    public List<SelectOption> selectDembutsuList { get; set; }          // 電物選択リスト
    public Boolean isIppan { get; set; }                                // 一般チェック
    public Boolean isGyoubutsu { get; set; }                            // 業物チェック
    public Boolean isNoSaveButton { get; set; }                         // 保存ボタン非活性フラグ
    public String MSG_COM_V_SAVE { get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_SAVE);} private set; }//js用保存確認メッセージ
    public String MSG_COM_I_SAVE { get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);} private set; }//js用保存完了メッセージ

    public String todayDateString {get; set;} //本日日付(javascript用)
    public String loginUserName {get; set;}   //ログインユーザ名(javascript用)
    
    /** 共通クラス */
    public GH201003ParameterClass GH201003Paremeter { get; set; }       // 店舗・地区選択引渡パラメータ

    /** プライベート変数 */
    private ID targetAccountRecordTypeId;                               //対象レコードタイプ(商品用)
    private List<screenRecordClass> copyScreenRecordClassList;          //明細表示用内部クラスリストコピー(保存時比較用)
    private List<screenRecordClass> searchResultList { get; set;}       //検索結果一時保存場所
    private Integer indexLimit;                                         // 明細上限
    
    
    //コンストラクタ
    public GD701007Controller() {

        try{
            // 初期化
            init();

            // 一般／業物 初期化
            this.isIppan = true;
            this.isGyoubutsu = false;

            // 取引先レコードタイプID取得
            targetAccountRecordTypeId = CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_SUPPLIER);

            // 店舗情報の取得
            Shop__c shop = CommonUtil.getStaffCurrentShop();
            shopId = shop.Id;                               // 店舗ID
            //2020.05.07　地区の初期表示処理削除 　            
            //Districts = shop.PortalSitePostingDistrict__c;  // 地区            
            //if(!String.isEmpty(Districts)){
            //    SearchDistricts = Districts.replace(';', '_');  // 検索地区の退避（「;」区切り⇒「_」区切りにして退避）
            //}            
        } catch(Exception e) {
            // エラー設定
            isOpenError =true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // 検索ボタン処理
    public void search() {
        try{
            // 検索処理
            searchAccount();

            // 検索結果件数チェック
            if (searchResultList.size() == 0) {
                // ビジネスロジックException発行
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_NO_DATA));
                throw ex;
            }
            
            //検索結果を画面に表示
            AccountIndex = 0;
            screenRecordClassList = new List<screenRecordClass>();
            for (ScreenrecordClass searchResult : searchResultList) {
                screenRecordClassList.add(searchResult);
            }
            
            
            
            // 検索地区の退避（「;」区切り⇒「_」区切りにして退避）
            SearchDistricts = Districts.replace(';', '_');

        }catch(Exception e){
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // 店舗・地区選択モーダルopen処理
    public void openModal() {
        GH201003Paremeter.selectedShopOrDistrictList = Districts.Split(';'); 
        GH201003Paremeter.isShopMode = false;
        GH201003Paremeter.isDrawing = true;
        GH201003Paremeter.noFirst = true;
    }
    
    // 店舗・地区選択モーダルclose処理
    public void closeModal() {
        Districts = '';
        for(String District : GH201003Paremeter.selectedShopOrDistrictList){
            if (Districts != '') {
                Districts += ';';
            }
            Districts += District;
        }
    }

    //保存処理
    public void recordSave(){
        Savepoint sp = Database.setSavepoint();      //セーブポイント作成

        try{
            this.hasErrorMessage = false;
            BusinessLogicException ex = new BusinessLogicException();
            // 更新用取引先リスト
            List<Account> saveAccountList = new List<Account>();
            // 楽観ロックチェック用取引先リスト
            List<Account> optimisticLockAccoutList = new List<Account>();

            // 明細を比較
            for(Integer i = 0; i < this.copyScreenRecordClassList.size(); i++){
                
                //空をnullに置き換える
                this.screenRecordClassList[i].convertNull();
                this.copyScreenRecordClassList[i].convertNull();

                // どれか1つでも変更されていれば処理
                if( this.copyScreenRecordClassList[i].dembutsuStatus    != this.screenRecordClassList[i].dembutsuStatus ||
                    this.copyScreenRecordClassList[i].dembutsuDate      != this.screenRecordClassList[i].dembutsuDate   ||
                    this.copyScreenRecordClassList[i].dembutsuStaff     != this.screenRecordClassList[i].dembutsuStaff  ||
                    this.copyScreenRecordClassList[i].dembutsuEventMemo != this.screenRecordClassList[i].dembutsuEventMemo )
                {
                    Account saveAccount = new Account(Id = this.screenRecordClassList[i].targetAccountRecord.Id);

                    // 各項目を比較して異なっていれば更新用取引先リストに格納
                    List<String> requiredItem = new List<String>();

                    // 電物ステータス
                    if (String.isEmpty(this.screenRecordClassList[i].dembutsuStatus) && !requiredItem.contains('電物')){
                        //空に変更の場合エラーメッセージ
                        requiredItem.add('電物');
                    }else if (this.copyScreenRecordClassList[i].dembutsuStatus != this.screenRecordClassList[i].dembutsuStatus){
                        //変更がある場合更新用取引先リストに格納
                        saveAccount.DembutsuStatus__c = this.screenRecordClassList[i].dembutsuStatus;
                    }

                    // 電物日
                    if (this.copyScreenRecordClassList[i].dembutsuDate != this.screenRecordClassList[i].dembutsuDate){
                        //変更がある場合更新用取引先リストに格納
                        if (String.isBlank(this.screenRecordClassList[i].dembutsuDate)) {
                            saveAccount.DembutsuDate__c = null;
                        } else {
                            saveAccount.DembutsuDate__c = Date.valueOf(this.screenRecordClassList[i].dembutsuDate.replace('/','-'));
                        }
                    }

                    // 電物担当者
                    if(this.copyScreenRecordClassList[i].dembutsuStaff != this.screenRecordClassList[i].dembutsuStaff){
                        //変更がある場合更新用取引先リストに格納
                        saveAccount.DembutsuStaff__c = this.screenRecordClassList[i].dembutsuStaff;
                    }
                    
                    // 電物イベントメモ
                    if(this.copyScreenRecordClassList[i].dembutsuEventMemo != this.screenRecordClassList[i].dembutsuEventMemo){
                        saveAccount.DembutsuEventMemo__c = this.screenRecordClassList[i].dembutsuEventMemo;
                    }
                    
                    //入力チェック用リストが空ではない場合、ビジネスロジックException文言作成
                    if (!requiredItem.isEmpty()){
                        ex.addMessage(CommonUtil.callMessageCreate(screenRecordClassList[i].targetAccountRecord.Name+':'+ CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ',')));
                    }
                    // 更新用取引先リストに追加
                    saveAccountList.add(saveAccount);
                    
                    // 楽観ロックチェック用取引先追加
                    optimisticLockAccoutList.add(this.copyScreenRecordClassList[i].targetAccountRecord);
                }
            }

            //入力チェック用リストが空ではない場合、ビジネスロジックException発行
            if (ex.hasMessage()){ 
                hasErrorMessage = true;
                throw ex;
            }

            // 楽観ロックチェック
            List<Account> accs = [SELECT Id, SystemModStamp FROM ACCOUNT WHERE Id IN :optimisticLockAccoutList];
            Map<Id, Account> mapAccs = new Map<Id, Account>(accs);
            
            for(Account opt : optimisticLockAccoutList){

                // SystemModStampに差異があればExceptionエラー発行
                if(opt.SystemModStamp != mapAccs.get(opt.Id).SystemModStamp){
                    OptimisticLockException ex2 = new OptimisticLockException();
                    throw ex2;
                }
            }

            // 更新
            SecureDML.secureUpsert(saveAccountList);
            
            
            
            // 日報登録、更新処理
            upsertDailyReport();

            // 再検索
            searchAccount();
        
        }catch(Exception e){
            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }


    // 検索処理
    private void searchAccount() {
        List<String> DistrictList = new List<String>();
        List<Account> accountList = new List<Account>();
        List<String> checkIppanGyoubutsuList = new List<String>();

        try{
            //選択地区のリスト作成
            if(!String.isEmpty(Districts)){
                DistrictList = Districts.Split(';');
            }
            
            //検索用SQL
            String sql = '';

            sql += 'SELECT Id';
            sql += '      ,Name';
            sql += '      ,Phone';
            sql += '      ,Representative__c';
            sql += '      ,RepresentativePhone__c';
            sql += '      ,Address__c';
            sql += '      ,DembutsuStatus__c';
            sql += '      ,DembutsuDate__c';
            sql += '      ,DembutsuStaff__c';
            sql += '      ,IppamGyobutsu__c';
            sql += '      ,DembutsuEventMemo__c';
            sql += '      ,SystemModStamp';
            sql += '  FROM Account';
            sql += ' WHERE RecordTypeID = \'' + this.targetAccountRecordTypeId + '\'';
            
            //2020.05.07追加　「業物」を選んでいる場合のみ、定期送信「無」の条件
            if(isGyoubutsu){
                sql += '   AND FixedTermSend__c = \'' + CommonConst.ACCOUNT_FixedTermSend_NO + '\'';  //定期送信「無」
            }
            sql += '   AND (Introduction__c = null OR Introduction__c =\'' + CommonConst.ACCOUNT_INTRODUCTION_NOTHING + '\')';  //紹介 nullまたは「設定なし」(2020.05.07追加)
            sql += '   AND Id      IN (SELECT FormerSupplier__c';  //サブクエリstart (元付業者ID)
            sql += '                     FROM Property__c';

            //条件：地区有り
            if (!String.isEmpty(Districts)){
                sql += '                    WHERE Building__r.District__c IN :DistrictList';
            }
            sql += '                  )';  //サブクエリend
            
            //条件：元付業者有り
            if(!String.isEmpty(this.FormerSupplier)){
                sql += '   AND Name LIKE \'%' + CommonUtil.escapeSingleQuotesEx(this.FormerSupplier) + '%\'';
            }

            //条件：取扱物件「一般物」がTRUE
            if(isIppan){
                checkIppanGyoubutsuList.add(CommonConst.ACCOUNT_IPPANGYOBUTSU_IPPAN);
            }

            //条件：取扱物件「業物」がTRUE
            if(isGyoubutsu){
                checkIppanGyoubutsuList.add(CommonConst.ACCOUNT_IPPANGYOBUTSU_GYOBUTSU);
            }

            sql += '   AND IppamGyobutsu__c IN :checkIppanGyoubutsuList';

            //2020/6/9追加：業物のときは業者名の昇順に
            if (isGyoubutsu){
                sql += ' ORDER BY Name';
            }else {
                sql += ' ORDER BY DembutsuStatus__c';
                sql += '         ,DembutsuDate__c';
            }
            
           
            sql += ' LIMIT ' + indexLimit;


            //検索実行&結果返却
            accountList = Database.query(sql);
            searchResultList = new List<screenRecordClass>();
            for(Account acc : accountList){
                searchResultList.add(new screenRecordClass(acc));
            }

            //保存時比較用コピー
            this.copyScreenRecordClassList = new List<screenRecordClass>();
            for( Integer i = 0; i < this.searchResultList.size(); i++ ){
                this.copyScreenRecordClassList.add(this.searchResultList[i].clone());
            }

            // 保存ボタン非活性フラグをTRUEに設定
            if(searchResultList.size() == 0){
                this.isNoSaveButton = true;
            } else {
                this.isNoSaveButton = false;
            }

        }catch(Exception e){
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    //初期化メソッド
    private void init(){

        // 元付業者初期化
        this.FormerSupplier = '';
        
        // 上限設定
        this.indexLimit = Integer.valueOf(SystemConfig__c.getInstance().DembutsuLimit__c);

        // 店舗・地区選択引渡パラメータ初期化(モーダル用パラメータ)
        this.GH201003Paremeter = new GH201003ParameterClass();

        // エラーメッセージフラグ初期化
        this.hasErrorMessage = false;

        // 保存ボタン非活性フラグ初期化
        this.isNoSaveButton = false;

        // 明細表示用内部クラスリストの初期化
        this.screenRecordClassList = new List<screenRecordClass>();

        // 電物選択リスト取得
        this.selectDembutsuList = CommonUtil.getSelectOptionFromObject('Account', 'DembutsuStatus__c', FALSE);
        this.selectDembutsuList.add(0, new SelectOption('',''));
        
        // javascript用固定文字列
        this.loginUserName = UserInfo.getName();
        this.todayDateString = String.valueOf(CommonUtil.getToday()).replace('-','/');
    }
    
    //日報更新（電物）
    private void upsertDailyReport() {
        
        //本日更新した業者を取得してくる
        List<Account> dembutsuUpdateList = 
            [SELECT id
            FROM Account
            WHERE DembutsuDate__c      = TODAY                   //本日更新の
            AND   DembutsuStaff__c     = :this.loginUserName     //このユーザの
            AND   DembutsuStatus__c    = '○'                    //○の数を数える
            AND   RecordTypeID = :this.targetAccountRecordTypeId //レコードタイプが業者
            AND   (Introduction__c = null OR Introduction__c = :CommonConst.ACCOUNT_INTRODUCTION_NOTHING) //メンテ対象である
            ];
        
        Integer dembutsuCount = dembutsuUpdateList.size(); //日報の値をこの値で更新する
        
        //日報集計部品を呼ぶ
        DailyReportUtil.upsertDailyReportDembutsu(dembutsuCount);
    }
    
    //***************************************************************内部クラス**************************************************************
    
    //明細表示用内部クラス
    public class screenRecordClass {
        public Account targetAccountRecord { get; set; }    //対象取引先レコード

        /** 以下、画面表示用(編集用)の項目 */
        public String dembutsuStatus { get; set; }       //電物
        public String dembutsuDate { get; set; }         //電物日
        public String dembutsuStaff { get; set; }        //電物者(ログインユーザ)
        public String dembutsuEventMemo { get; set; }    //イベントメモ

        //コンストラクタ
        public screenRecordClass(Account targetAccountRecord){


            //取引先レコードの連動
            this.targetAccountRecord = targetAccountRecord;
            this.dembutsuStatus      = targetAccountRecord.DembutsuStatus__c;
            this.dembutsuStaff       = targetAccountRecord.DembutsuStaff__c;
            this.dembutsuEventMemo   = targetAccountRecord.DembutsuEventMemo__c;
            
            if (targetAccountRecord.DembutsuDate__c != null) {
                this.dembutsuDate = String.valueOf(targetAccountRecord.DembutsuDate__c).replace('-','/');
            } else {
                this.dembutsuDate = '';
            }
        }

        //空白をnullに変更する
        public void convertNull() {
            this.dembutsuStatus     = String.isBlank(this.dembutsuStatus)    ? null : this.dembutsuStatus;
            this.dembutsuStaff      = String.isBlank(this.dembutsuStaff)     ? null : this.dembutsuStaff;
            this.dembutsuEventMemo  = String.isBlank(this.dembutsuEventMemo) ? null : this.dembutsuEventMemo;
        }
    }
}