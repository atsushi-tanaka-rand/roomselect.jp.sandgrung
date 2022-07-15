/* *
 *類似物件送信者一覧　のコントローラ
 */
public inherited sharing class GK101007Controller {
    
    /** public変数 */
    
    //検索条件
    public String searchName { get; set; }             // 氏名
    public String searchPhone { get; set; }            // 電話
    public String searchEmail { get; set; }            // メール
    public String searchEchoShop { get; set; }         // 反響店舗
    public String searchEchoStaff { get; set; }        // 反響担当者
    public String searchVisitShop { get; set; }        // 来店店舗
    public String searchShopStaff { get; set; }        // 来店担当者

    //明細関係
    public List<ScreenIntroMailInfo> screenIntroMailInfoList { get; set; }   // 表示用紹介メール情報リスト
    public String selectedParm { get; set; }              // 選択された明細のリンクパラメータ
    
    //フラグ類
    public Boolean hasErrorMessage {get; set;}                      // エラーメッセージ保有フラグ
    public Boolean isOpenError {get; set;}                          // 初期エラーフラグ
    public Boolean isOpetionPortal{ get; set; }                     // 自社ポータル権限 
    public List<SelectOption> selectShopList{ get; set; }           // 店舗選択リスト
    public list<SelectOption> selectEchoStaffList { get;set;}       // 反響担当者のリスト設定     
    public list<SelectOption> selectShopStaffList { get;set;}       // 来店担当者のリスト設定     

    //ダイアログメッセージ
    public String MSG_COM_V_DELETE_SENDMAILSTATUS {get{return CommonUtil.callMessageCreate(CommonConst_ptl.MSG_COM_V_DELETE_SENDMAILSTATUS);} private set;}    //js用削除確認メッセージ
    public String MSG_COM_I_DELETE_SENDMAILSTATUS {get{return CommonUtil.callMessageCreate(CommonConst_ptl.MSG_COM_I_DELETE_SENDMAILSTATUS);} private set;}    //js用削除完了メッセージ

    /** private変数 */
    //検索上限数
    final private Integer INDEX_LIMIT = 1000;
    private String loginStaff;                      //ログインユーザ
    public Boolean initSearch;                      //初期検索（検索条件と条件を変更）
    public Boolean initSearch0Error;                //初期検索（初期検索で0件になったとき、初期表示エラーを出さない）

    //コンストラクタ
    public GK101007Controller() {
        try{
            this.initSearch0Error = false;
            // 店舗異動情報の取得（画面操作権限の確認）
            CommonUtil.getStaffCurrentShop();

            //自社権限取得
            this.isOpetionPortal = AuthorityCheckUtil.getAuthorityOptionPortal(true);

            // 初期化
            this.initSearch = true;         //初期検索フラグ
            init();
            this.initSearch = false;

        } catch(Exception e) {
            // エラー設定
            if (! this.initSearch0Error){
                isOpenError = true;
            }
            this.initSearch = false;
            CommonUtil.setErrorMessage(e);
        }

    }
    //************************************************************************** publicメソッド *************************************************************

    // 検索ボタン処理
    public void search() {
        try{
            // エラーフラグ初期化
            hasErrorMessage = false;
            
            // 検索
            searchIntroMailInfo(false);

            // 明細選択を初期化
            selectedParm = null;
    

        }catch(Exception e){
	        hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }


    // 配信停止ボタン処理
    public void sendStopButton(){
        Savepoint sp = Database.setSavepoint();      //セーブポイント作成
        this.hasErrorMessage = false;//エラーを設定
        try{

            IntroductionMailInformation__c targetIntroMail;	//対象紹介メール情報

            Boolean isChecked = false;
            for (ScreenIntroMailInfo screen : screenIntroMailInfoList){
                if (screen.checkBox == true){
                    targetIntroMail = screen.IntroMailInfo;
                    isChecked = true;
                    break;
	            }
            }

            //1つもチェックがない場合、エラー
            if (! isChecked){
                // ビジネスロジックException発行
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_NO_SELECTION, '自動追客メール'));
                throw ex;
            }

            //楽観ロックチェック
            accountOptimisticLockException(targetIntroMail.Account__c, targetIntroMail.Account__r.SystemModStamp);		//取引先
            introMailOptimisticLockException(targetIntroMail.Id, targetIntroMail.SystemModStamp);                       //紹介メール情報
        
            //取引先の紹介メール配信状況を「配信停止」、追客回数を0に変更
            SecureDML.secureUpdate(
                new Account(id = targetIntroMail.Account__c, 
                               IntroMailInfoPursuitCount__c = 0,
                               IntroMailInfoStatus__c = CommonConst_ptl.INTRODUCTION_SENDSTOP)
                );
           
            //対応のステータスを「終了」、終了日時を現在日時に変更
            SecureDML.secureUpdate(
                new Correspond__c(
                    id = targetIntroMail.Correspond__c, 
                    Status__c = CommonConst.CORRESPOND_STATUS_CLOSE,  //ステータス = 終了
                    StatusBeforePursuitHold__c = null,                //追客保留前ステータス
                    EndDate__c = CommonUtil.getNow(),                 //終了日付
                    EventDateTime__c = CommonUtil.getNow(),           //イベント時刻
                    StaffSupportedFlg__c = this.loginStaff == targetIntroMail.Correspond__r.ShopStaff__c ? true : false,//スタッフ対応フラグ
                    IsSupportedListShow__c = true,                    //対応確認
                    IsBrowseFlg__c = true,                            //閲覧フラグ
                    ListViewDate__c = CommonConst.LAST_DATE,          //一覧表示日時
                    IsEchoNotCalculation__c = true                    //反響非計算フラグ
                )
            );

            //対応明細登録
            SecureDML.secureInsert(
                new CorrespondDetail__c(
                    SupportedDateTime__c   = CommonUtil.getNow(),                     // 対応日時
                    Shop__c                = CommonUtil.getStaffCurrentShop().id,     // 店舗
                    Staff__c               = this.loginStaff,                         // 担当者
                    Corresponds__c         = targetIntroMail.Correspond__c,           // 対応ID
                    CorrespondType__c      = CommonConst.TASK_CORRESPONDTYPE_CLOSE,   // 対応種別
                    SupportedTitle__c      = '自動追客終了に伴い、終了',                // 対応表題
                    SupportedContent__c    = '自動追客メール配信を停止しました。'        // 対応内容
                )
            );

            //紹介メール情報削除
            SecureDML.secureDelete(targetIntroMail);
            
            //再検索
            searchIntroMailInfo(true);

        }catch(Exception e){
            
            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }

    // 反響店舗変更時　反響担当者のリスト更新
    public void getEchoStaffList(){
        hasErrorMessage = false;
        try {
            this.searchEchoStaff = null;
            //店舗に値がある場合　店舗に所属するユーザをセット
            this.selectEchoStaffList = getUserSelectedOptionFromShopId(this.searchEchoShop);

        }catch (Exception e) {
            // エラーを設定
            CommonUtil.setErrorMessage(e);
            hasErrorMessage = true;
             
        }
     }
    //来店店舗変更時　来店担当者のリスト更新
    public void getShopStaffList(){
        hasErrorMessage = false;
        try {
            this.searchShopStaff = null;
            //店舗に値がある場合　店舗に所属するユーザをセット
            this.selectShopStaffList = getUserSelectedOptionFromShopId(this.searchVisitShop);

        }catch (Exception e) {
            // エラーを設定
            CommonUtil.setErrorMessage(e);
            hasErrorMessage = true;
             
        }
     }
    
    //************************************************************************** privateメソッド *************************************************************
    
    // 初期化
    private void init() {
        // エラーメッセージフラグ初期化
        hasErrorMessage = false;
        isOpenError = false;


        //所属店舗取得
        Shop__c currentShop = CommonUtil.getStaffCurrentShop(); //ログインユーザ所属店舗
        this.loginStaff = UserInfo.getUserId();                 //ログインユーザId
        Boolean isShopType = currentShop.IsShopType__c;         //店舗区分

        //店舗選択リスト値設定
        selectShopList = CommonUtil.getShopSelectedOptionFromStaffId(loginStaff,true,false);   

        if (isShopType == true){
            //店舗スタッフ
            //来店担当店舗の初期値を所属店舗に設定
            this.searchVisitShop = currentShop.id; // 来店担当店舗   
        }else{
            //店舗スタッフ以外(インサイドセールス)
            //反響担当店舗の初期値を所属店舗に設定
            this.searchEchoShop = currentShop.id; // 反響担当店舗
        }
        //▼再販追加
        //反響・来店担当者のリスト値をセット
        this.selectShopStaffList = getUserSelectedOptionFromShopId(this.searchVisitShop); //来店担当者
        this.selectEchoStaffList = getUserSelectedOptionFromShopId(this.searchEchoShop); //反響担当者
        //▲再販追加      
        //氏名、電話番号、メール、反響担当者、来店担当者
        this.searchName = '';               //検索用氏名
        this.searchPhone = '';              //検索用電話番号
        this.searchEmail = '';              //検索用メール
        this.searchEchoStaff = '';          //反響担当者
        this.searchShopStaff = '';          //来店担当者
        
        //検索結果初期化
        this.screenIntroMailInfoList = new List<ScreenIntroMailInfo>();

        //検索
        searchIntroMailInfo(false);
    }

    //検索
    private void searchIntroMailInfo(Boolean isReSearch){
        this.initSearch0Error = false;  //初期検索時に0件エラーが出ているフラグ
        // SQL用変数作成
        String soqlName   = '%'+ CommonUtil.convertDisableWildcard((this.searchName.replace(' ', '')).replace('　', ''))   + '%';                //氏名
        String soqlEchoStaff  = CommonUtil.convertDisableWildcard(this.searchEchoStaff);       //反響担当者
        String soqlShopStaff = CommonUtil.convertDisableWildcard(this.searchShopStaff);      //来店担当者
        String soqlEchoShop  = CommonUtil.convertDisableWildcard(this.searchEchoShop);       //反響店舗
        String soqlVisitShop = CommonUtil.convertDisableWildcard(this.searchVisitShop);      //来店店舗
        String soqlSearchEmail  = '%'+ CommonUtil.convertDisableWildcard(this.searchEmail) + '%';       //メール
        String soqlSearchPhone = '%'+ CommonUtil.convertDisableWildcard(this.searchPhone) + '%';        //電話番号

        //whereフラグ
	    Boolean whereFlg = false;
                
        // 検索SQL作成
        String sql = '';
        sql += 'SELECT  Id'; 
        sql += '      , Correspond__c';      			        // 対応
        sql += '      , Account__c';     			            // 取引先
        sql += '      , Account__r.IntroMailInfoStatus__c';               // 取引先．紹介メール配信状況
        sql += '      , Account__r.IntroMailInfoFirstSendDatetime__c';    // 取引先．紹介メール初回配信日時
        sql += '      , Account__r.IntroMailInfoLastSendDatetime__c';     // 取引先．紹介メール最終配信日時
        sql += '      , Account__r.IntroMailInfoPursuitCount__c';         // 取引先．紹介メール送信回数
        sql += '      , Account__r.Phone';     			        // 取引先. 電話
        sql += '      , Account__r.Email__c';     			    // 取引先．メール
        sql += '      , Account__r.LastName__c';           	    // 取引先．姓
        sql += '      , Account__r.FirstName__c';           	// 取引先．名
        sql += '      , Correspond__r.Id'; 			            // 対応Id
        sql += '      , Account__r.SystemModStamp';           	// 取引先．SystemModStamp
        sql += '      , Correspond__r.EchoStaff__r.Name';     	// 反響担当者
        sql += '      , Correspond__r.ShopStaff__r.Name';     	// 来店担当者
        sql += '      , Correspond__r.ShopStaff__c';     	    // 来店担当者Id
        sql += '      , SystemModStamp';
        sql += '  FROM IntroductionMailInformation__c';         //紹介メール情報
  
        //検索条件　氏名
        if (!String.isEmpty(this.searchName)){
            sql += whereOrAnd(whereFlg);
            sql += '   Account__r.Name LIKE :soqlName';
            whereFlg = true;
        }

        //メールに入力がある場合
        //メール
        //メール２
        //メール３	
        if(!String.isEmpty(this.searchEmail)){//お客様名/業者名
            sql += whereOrAnd(whereFlg);
            sql += ' ( ';
            sql +=  'Account__r.Email__c  LIKE :soqlSearchEmail ';
            sql += ' OR ';
            sql +=  'Account__r.Email2__c  LIKE :soqlSearchEmail ';
            sql += ' OR ';
            sql +=  'Account__r.Email3__c  LIKE :soqlSearchEmail ';
            sql += ' ) ';
            whereFlg = true;
        }
        
        //電話番号に入力がある場合
        //電話番号
        //電話番号２
        //電話番号３			
        if(!String.isEmpty(this.searchPhone)){//お客様名/業者名
            sql += whereOrAnd(whereFlg);
            sql += ' ( ';
            sql +=  'Account__r.Phone  LIKE :soqlSearchPhone ';
            sql += ' OR ';
            sql +=  'Account__r.Phone2__c  LIKE :soqlSearchPhone ';
            sql += ' OR ';
            sql +=  'Account__r.Phone3__c  LIKE :soqlSearchPhone ';
            sql += ' ) ';
            whereFlg = true;
        }
        
        if (this.initSearch){//初期検索の場合　
            //(反響店舗 = ログインユーザの所属店舗 AND 来店店舗 = なし) OR
            //(来店店舗 = ログインユーザの所属店舗 AND 反響店舗 = なし) OR
            //(反響店舗 = ログインユーザの所属店舗 AND 来店店舗 = ログインユーザの所属店舗)

            sql += whereOrAnd(whereFlg);

            //検索条件　反響店舗
            if (!String.isEmpty(this.searchEchoShop)){
                
                sql += ' ( Correspond__r.EchoShop__c = :soqlEchoShop AND ';
                sql += '   Correspond__r.VisitShop__c = null )';
            }

            //検索条件　来店店舗
            if (!String.isEmpty(this.searchVisitShop)){
                if (!String.isEmpty(this.searchEchoShop)){
                    sql += ' OR ';
                }
                sql += ' ( Correspond__r.EchoShop__c = null AND ';
                sql += '   Correspond__r.VisitShop__c = :soqlVisitShop )';
            }

            //検索条件　来店店舗、反響店舗
            if (!String.isEmpty(this.searchEchoShop) && !String.isEmpty(this.searchVisitShop)){
                sql += ' OR ';
                sql += ' ( Correspond__r.EchoShop__c = :soqlEchoShop AND ';
                sql += '   Correspond__r.VisitShop__c = :soqlVisitShop ) ';
            }

        }else{//初期検索以外
            //検索条件　反響店舗
            if (!String.isEmpty(this.searchEchoShop)){
                sql += whereOrAnd(whereFlg);
                sql += '   Correspond__r.EchoShop__c = :soqlEchoShop';
                whereFlg = true;
            }

            //検索条件　来店店舗
            if (!String.isEmpty(this.searchVisitShop)){
                sql += whereOrAnd(whereFlg);
                sql += '   Correspond__r.VisitShop__c = :soqlVisitShop';
                whereFlg = true;
            }

        }

        //検索条件　反響担当者
        if (!String.isEmpty(this.searchEchoStaff)){
            sql += whereOrAnd(whereFlg);
            sql += '   Correspond__r.EchoStaff__c = :soqlEchoStaff';
            whereFlg = true;
        }

        //検索条件　来店担当者
        if (!String.isEmpty(this.searchShopStaff)){
            sql += whereOrAnd(whereFlg);
            sql += '   Correspond__r.ShopStaff__c = :soqlShopStaff';
            whereFlg = true;
        }
        sql += ' ORDER BY Account__r.IntroMailInfoPursuitCount__c';
        sql += ' LIMIT :INDEX_LIMIT';

        // 検索実行＆結果返却
        List<IntroductionMailInformation__c> searchResultList = Database.query(sql);

        // 検索結果件数チェック
        if (searchResultList.size() == 0) {
            //配信停止後の再検索の場合、エラーは出さない
            if (isReSearch){
                this.screenIntroMailInfoList = new List<ScreenIntroMailInfo>();
            }else{
                // ビジネスロジックException発行
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_NO_DATA));

                if (this.initSearch){//初期検索の場合、初期表示エラーは出さない
                    this.initSearch0Error = true;
                }
                throw ex;
            }

        }else{
            this.screenIntroMailInfoList = new List<ScreenIntroMailInfo>();

            //内部クラス作成
            for (IntroductionMailInformation__c result : searchResultList){
                screenIntroMailInfoList.add(new ScreenIntroMailInfo(result));
            }
        }
       
    }

    //取引先楽観ロックチェック
    private void accountOptimisticLockException(Id objId, Datetime oldSysModStamp){
        List<Account> searchResultList = [SELECT id FROM Account 
                            WHERE id = :objId 
                            AND SystemModStamp = :oldSysModStamp];
        if (searchResultList.isEmpty()){
            OptimisticLockException ex = new OptimisticLockException();
            throw ex;
        }
    }

    //紹介メール情報楽観ロックチェック
    private void introMailOptimisticLockException(Id objId, Datetime oldSysModStamp){
        List<IntroductionMailInformation__c> searchResultList = [SELECT id FROM IntroductionMailInformation__c 
                            WHERE id = :objId 
                            AND SystemModStamp = :oldSysModStamp];
        if (searchResultList.isEmpty()){
            OptimisticLockException ex = new OptimisticLockException();
            throw ex;
        }
    }
    
    //SOQLのWHEREかANDか
    private String whereOrAnd(Boolean whereFlg){
        String reStr;
        if (whereFlg == true){
            reStr = ' AND ';
        }else{
            reStr = ' WHERE ';
        }
        return reStr;
    }
    //▼再販追加
    /** 
    ユーザ選択リスト返却メソッド
    @String shopId　店舗Id  　  
    @return ユーザ選択リスト
    **/    
    private List<SelectOption> getUserSelectedOptionFromShopId(String shopId){
        return CommonUtil.getUserSelectedOptionFromShopId(String.isBlank(shopId) ? new List<String>() : new List<String>{shopId}
                                                          ,true);
    }
    //▲再販追加
    
    //************************************************************************** 内部クラス *************************************************************
    //表示用紹介メール情報
    public class ScreenIntroMailInfo{
        public IntroductionMailInformation__c IntroMailInfo { get; set; }     	//配信メール配信状況
        public boolean checkBox  { get; set; }       		//チェックボックス

        public ScreenIntroMailInfo(IntroductionMailInformation__c obj){
            this.IntroMailInfo = obj;
            this.checkBox = false;
        }
    }
}