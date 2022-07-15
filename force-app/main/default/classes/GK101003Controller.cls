/* *
 * HPおすすめ物件一覧画面コントローラ
 */
public inherited sharing class GK101003Controller {


    /** public変数 */
    // 画面出力
    public List<screenRecommendProperty> screenRecommendPropertyList { get; set; }  // 画面出力用リスト

    // 検索結果の件数や行番
    public Integer recommendPropertyDisplayFlagCount { get; set; }              // おすすめ物件登録中件数
    public Integer panoramaTourRegisterCount { get; set; }                      // パノラマツアー登録件数
    public integer checkedIndex { get;set;}                                     // 選択行（編集時用）
    public integer processingDifferentialNumber { get; set; }                   // 処理件数差分（削除、おすすめ登録解除で処理できなかった件数）
    public integer targetsNumber { get; set; }                                  // 処理対象件数（削除、おすすめ登録解除の対象件数）

    // 選択リスト値
    public List<SelectOption> selectShopList { get; set; }                      // 店舗のリスト設定

    // モーダル関連
    public GA104006Modal3ParameterClass GA104006Modal3Parameter { get; set; }   // おすすめ物件登録モーダル用

    // 検索項目
    public String  searchShopsName { get; set; }                                // 店舗（リスト選択時）
    public Boolean searchPanoramaTourRegisteAvailable { get; set; }             // パノラマツアー登録有
    public Boolean searchPanoramaTourRegisteNotAvailable { get; set; }          // パノラマツアー登録無
    public Boolean searchDisplayFlagRegistering { get; set; }                   // おすすめ物件_登録中
    public Boolean searchDisplayFlagRelease { get; set; }                       // おすすめ物件_解除

    // フラグ類
    public Boolean hasErrorMessage              { get; set; }                   // エラーメッセージ保有フラグ
    public Boolean isOpenError                  { get; set; }                   // 初期エラーフラグ
    public Boolean useAuthorityPortalErrorFlg   { get; set; }                   // 認証フラグ

    // おすすめ物件表示フラグの文言
    public static final String DISPLAY_FLAG_REGISTERING    {get{return '登録中';} private set;}    // 登録中
    public static final String DISPLAY_FLAG_RELEASE        {get{return '解除';} private set;}      // 解除

    // メッセージ
    public String MSG_COM_W_NO_SELECTION {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_NO_SELECTION,'物件');} private set;}                    //js用選択なしメッセージ
    public String MSG_COM_W_SELECTION_ONLY_ONE {get{return CommonUtil.callMessageCreate(CommonConst_ptl.MSG_COM_W_SELECTION_ONLY_ONE,'物件');} private set;}    //js用選択過多メッセージ
    public String MSG_COM_W_REMOVE_RECOMMENDATION {get{return CommonUtil.callMessageCreate(CommonConst_ptl.MSG_COM_W_REMOVE_RECOMMENDATION);} private set;}     //js用おすすめ物件解除確認メッセージ
    public String MSG_COM_I_REMOVE_RECOMMENDATION {get{return CommonUtil.callMessageCreate(CommonConst_ptl.MSG_COM_I_REMOVE_RECOMMENDATION);} private set;}     //js用おすすめ物件解除完了メッセージ
    public String MSG_COM_W_SELECTION_REMOVE_RECOMMENDATION  {get{return CommonUtil.callMessageCreate(CommonConst_ptl.MSG_COM_W_SELECTION_REMOVE_RECOMMENDATION);} private set;}    //js用おすすめ物件解除選択過多メッセージ（50件）
    public String MSG_COM_W_SELECTION_DELETE_RECOMMENDATION  {get{return CommonUtil.callMessageCreate(CommonConst_ptl.MSG_COM_W_SELECTION_DELETE_RECOMMENDATION);} private set;}    //js用おすすめ物件削除選択過多メッセージ（50件）
    public String MSG_COM_V_DELETE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_DELETE);} private set;}    //js用おすすめ物件削除確認メッセージ
    public String MSG_COM_I_DELETE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_DELETE);} private set;}    //js用おすすめ物件削除完了メッセージ
    public String MSG_COM_I_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);} private set;}                                           //js用保存完了メッセージ
    public String MSG_COM_W_SELECTION_OR_MORE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SELECTION_OR_MORE,'登録中の物件,1'.split(','));} private set;}    //js用検選択一定数メッセージ
    public String msgComEPanoramatourPrivate {get; set;}     //js用おすすめ物件パノラマツアー更新失敗メッセージ
    public String msgComEPanoramatourPrivateMultiple {get; set;}     //js用おすすめ物件パノラマツアー一部更新失敗メッセージ
    
    //再販対応 追加 Start
    public Boolean isUseAuthorityPanoramaTour { get; set; } //利用権限_パノラマツアーフラグ
    //再販対応 追加 End
        
    /** private変数 */
    final private Integer INDEX_LIMIT = 1000;                       //検索上限数

    // コンストラクタ
    public GK101003Controller() {
        try{
            // 権限確認　自社ポータルサイト
            AuthorityCheckUtil.getAuthorityOptionPortal(true);

            // 店舗異動情報の取得（画面操作権限の確認）
            CommonUtil.getStaffCurrentShop();

            // 初期化
            init();

        } catch(Exception e) {
            // エラー設定
            if(!SystemConfig__c.getInstance().UseAuthority_Portal__c){
                this.useAuthorityPortalErrorFlg = true;
            }else if(SystemConfig__c.getInstance().UseAuthority_Portal__c){
                isOpenError = true;
            }            
            CommonUtil.setErrorMessage(e);
        }
    }
//************************************************************************** publicメソッド *************************************************************

    // 検索ボタン処理
    public void search(){
        try{
            // おすすめ物件取得処理
            setScreenRecommendProperty();

        } catch(Exception e){
            // 検索エラー
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    //おすすめ物件モーダル起動
    public void openRecommendPropertyRegistration(){
        this.GA104006Modal3Parameter = new GA104006Modal3ParameterClass();
        this.GA104006Modal3Parameter.buildingId = this.screenRecommendPropertyList[checkedIndex].buildingId;
        this.GA104006Modal3Parameter.propertyId = this.screenRecommendPropertyList[checkedIndex].propertyId;
        this.GA104006Modal3Parameter.propertyCode = this.screenRecommendPropertyList[checkedIndex].propertyCode;
        this.GA104006Modal3Parameter.recoPro = this.screenRecommendPropertyList[checkedIndex].recommendProperty;
        this.GA104006Modal3Parameter.isDrawing = true;
        this.GA104006Modal3Parameter.noFirst = true;
        this.GA104006Modal3Parameter.IsUpsertDB = true;
        //再販対応 追加 Start
        this.GA104006Modal3Parameter.isUseAuthorityPanoramaTour = this.isUseAuthorityPanoramaTour;
        //再販対応 追加 End        
    }
    // おすすめ物件モーダル終了
    public void closeRecommendPropertyRegistration() {
        try{
            this.hasErrorMessage = false;
            // 再取得
            setScreenRecommendProperty();
        } catch(Exception e){
            // 検索エラー
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // おすすめ登録解除
    public void recommendRelease(){
        this.hasErrorMessage = false;
        this.processingDifferentialNumber = 0;
        this.targetsNumber = 0; 
        this.msgComEPanoramatourPrivate = CommonUtil.callMessageCreate(CommonConst_ptl.MSG_COM_E_PANORAMATOUR_PRIVATE,'解除');
        this.msgComEPanoramatourPrivateMultiple = CommonUtil.callMessageCreate(CommonConst_ptl.MSG_COM_E_PANORAMATOUR_PRIVATE_MULTIPLE,'解除');

        List<RecommendProperty__c> updateRecommendPropertyList = new List<RecommendProperty__c>();
        try {
            // 対象の抜き出し
            List<Id> recommendPropertyIdList = setTheta360bizChangeTarget(false);
            this.targetsNumber = recommendPropertyIdList.size();
            // パノラマツアーの非公開処理
            updateRecommendPropertyList = Theta360bizApiUtil.callTheta360bizToursStatus(recommendPropertyIdList);

            this.processingDifferentialNumber = this.targetsNumber - updateRecommendPropertyList.size();
        } catch(Exception e) {
            // エラー設定
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
            return;
        }

        // SFデータの更新
        try {
           
            if(updateRecommendPropertyList.size() > 0){
                // 更新処理
                SecureDML.secureUpdate(updateRecommendPropertyList);
            }
            // 再取得
            setScreenRecommendProperty();
        } catch(Exception e) {
            // エラー設定
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // おすすめ物件削除
    public void deleteRecommendProperty(){
        this.hasErrorMessage = false;
        this.processingDifferentialNumber = 0;
        this.targetsNumber = 0; 
        this.msgComEPanoramatourPrivate = CommonUtil.callMessageCreate(CommonConst_ptl.MSG_COM_E_PANORAMATOUR_PRIVATE,'削除');
        this.msgComEPanoramatourPrivateMultiple = CommonUtil.callMessageCreate(CommonConst_ptl.MSG_COM_E_PANORAMATOUR_PRIVATE_MULTIPLE,'削除');

        List<RecommendProperty__c> deleteRecommendPropertyList = new List<RecommendProperty__c>();
        try {
                
            // 対象の抜き出し
            List<Id> recommendPropertyIdList  = setTheta360bizChangeTarget(true);
            this.targetsNumber = recommendPropertyIdList.size();
            // パノラマツアーの非公開処理
            deleteRecommendPropertyList = Theta360bizApiUtil.callTheta360bizToursStatus(recommendPropertyIdList);
            this.processingDifferentialNumber = this.targetsNumber - deleteRecommendPropertyList.size();
        } catch(Exception e) {
            // エラー設定
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
            return;
        }

        // SFデータの削除
        try {
            
            if(deleteRecommendPropertyList.size() > 0){
                // 更新処理
                SecureDML.secureDelete(deleteRecommendPropertyList);
            }
            // 再取得
            setScreenRecommendProperty();
        } catch(Exception e) {
            // エラー設定
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

//************************************************************************** privateメソッド *************************************************************
    // 初期化
    private void init() {
        this.checkedIndex = 0;
        this.processingDifferentialNumber = 0;
        this.targetsNumber = 0; 
        // エラーメッセージフラグ初期化
        hasErrorMessage = false;
        isOpenError = false;
        useAuthorityPortalErrorFlg = false;

        ///利用権限_パノラマツアーを取得
        isUseAuthorityPanoramaTour = AuthorityCheckUtil.getAuthorityOptionPanoramaTour(false);
        //再販対応 追加 End

        // おすすめ物件の初期化
        this.screenRecommendPropertyList = new List<screenRecommendProperty>();
        

        //店舗の選択肢を作成・セット
        this.selectShopList = new List<SelectOption>();
        this.selectShopList = CommonUtil.getShopSelectedOptionFromStaffId(null, true, true, false); //IS不要

        // 検索条件の初期化
        this.searchShopsName = '';                              // 店舗（リスト選択時）
        this.searchPanoramaTourRegisteAvailable  = true ;       // パノラマツアー登録有
        this.searchPanoramaTourRegisteNotAvailable  = true ;    // パノラマツアー登録無
        this.searchDisplayFlagRegistering  = true ;             // おすすめ物件_登録中
        this.searchDisplayFlagRelease  = false ;                // おすすめ物件_解除
    }

    // リストにセット
    private void setScreenRecommendProperty(){
        this.recommendPropertyDisplayFlagCount = 0;
        this.panoramaTourRegisterCount = 0;

        this.screenRecommendPropertyList = new List<screenRecommendProperty>();

        // select
        List<RecommendProperty__c> recommendPropertyList = selectRecommendProperty();

        // 検索結果件数チェック
        if (recommendPropertyList.size() == 0) {
            // 検索結果が０件ならビジネスロジックException発行
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_NO_DATA));
            throw ex;
        }

        // 物件情報の取得
        Map<String, Property__c> propertyMap  = getPropertyMap(recommendPropertyList);

        // リストにセットする
        for(RecommendProperty__c recommendProperty : recommendPropertyList){
            this.screenRecommendPropertyList.add(new screenRecommendProperty(recommendProperty,propertyMap));

            // 件数の設定
            if(recommendProperty.DisplayFlag__c){
                this.recommendPropertyDisplayFlagCount += 1;
            }

            if(recommendProperty.PanoramaTourRegister__c == CommonConst_ptl.PANORAMA_TOUR_REGISTER_AVAILABLE){
                this.panoramaTourRegisterCount += 1;
            }
            
        }

    }

    // おすすめ物件の物件コードを元に物件の情報を取得する
    private Map<String, Property__c> getPropertyMap(List<RecommendProperty__c> recommendPropertyList){
        List<String> propertyCodeList = new List<String>();
        for(RecommendProperty__c recommendProperty : recommendPropertyList){
            propertyCodeList.add(recommendProperty.PropertyCode__c);
        }

        // 物件コードから物件情報の取得
        List<Property__c> propertyList = selectProperty(propertyCodeList);

        
        Map<String, Property__c> propertyMap = new Map<String, Property__c>();
        for(Property__c Property : PropertyList){
            // 物件コードを元に物件情報のマップをセットする
            if(!PropertyMap.containsKey(Property.PropertyCode__c)){
                // セットされていなければ物件コードをキーとしてMapをセットする。
                propertyMap.put(Property.PropertyCode__c, Property);
            }
        }

        return propertyMap;
    }
    
    // おすすめ物件のSQL実行
    private List<RecommendProperty__c> selectRecommendProperty(){
        //whereフラグ
        Boolean whereFlg = false;

        // 検索SQL作成
        String sql = '';
        sql += 'SELECT    ID ';                         // おすすめ物件ID
        sql += ' ,        PropertyCode__c ';            // 物件コード
        sql += ' ,        ShopId__c ';                  // 登録店舗
        sql += ' ,        ShopId__r.name ';             // 登録店舗名
        sql += ' ,        UserId__c ';                  // 店舗スタッフ
        sql += ' ,        UserId__r.name ';             // 店舗スタッフ名
        sql += ' ,        CreatedDate ';                // 登録日
        sql += ' ,        PanoramaTourRegister__c ';    // パノラマツアー登録
        sql += ' ,        DisplayFlag__c ';             // 表示フラグ（おすすめ物件）
        sql += ' ,        Comment__c ';                 // コメント
        sql += ' ,        PanoramaTourUrl__c ';         // パノラマツアーURL
        sql += ' ,        HomesImportkey__c ';          // HOME'Sインポートキー
        sql += ' ,        PhotoFileName__c ';           // 写真ファイル名
        sql += ' ,        PhotoFilePath__c ';           // 写真ファイルパス
        sql += ' ,        SystemModStamp ';             // SystemModStamp
        sql += ' FROM     RecommendProperty__c ';       // おすすめ物件オブジェクト   

        // 検索条件

        // 店舗
        if(String.isNotEmpty(this.searchShopsName)){
            sql += whereOrAnd(whereFlg);
            sql += '   ShopId__c = :searchShopsName'; 
            whereFlg = true;
        }                                

        // パノラマツアー登録
        if(this.searchPanoramaTourRegisteAvailable && !this.searchPanoramaTourRegisteNotAvailable){
            // パノラマツアー登録有
            sql += whereOrAnd(whereFlg);
            sql += '   PanoramaTourRegister__c = \''+ CommonConst_ptl.PANORAMA_TOUR_REGISTER_AVAILABLE +'\''; 
            whereFlg = true;
        }else if(this.searchPanoramaTourRegisteNotAvailable && !this.searchPanoramaTourRegisteAvailable){
            // パノラマツアー登録無
            sql += whereOrAnd(whereFlg);
            sql += '   PanoramaTourRegister__c = \''+ CommonConst_ptl.PANORAMA_TOUR_REGISTER_NOT_AVAILABLE +'\''; 

            whereFlg = true;
        }
        
        // おすすめ物件
        if(this.searchDisplayFlagRegistering && !this.searchDisplayFlagRelease){
            // おすすめ物件_登録中
            sql += whereOrAnd(whereFlg);
            sql += '   DisplayFlag__c = true'; 
        }else if(this.searchDisplayFlagRelease && !this.searchDisplayFlagRegistering){
            // おすすめ物件_解除
            sql += whereOrAnd(whereFlg);
            sql += '   DisplayFlag__c = false'; 
        }
        
        // ソート順
        sql += ' ORDER BY CreatedDate DESC ';           //作成日（降順）
        sql += ' ,        DisplayFlag__c DESC ';        // 表示フラグ（降順 Trueのレコードが先頭）

        // 検索上限
        sql += ' LIMIT    :INDEX_LIMIT' ;

        // 検索実行＆結果返却
        return Database.query(sql);
    }

    // 物件情報のSQL実行
    private List<Property__c> selectProperty(List<String> propertyCodeList){
        List<Property__c> propertyList =[SELECT Id,                 //物件ID
                                                Name,               //物件名
                                                Building__c,        //建物ID
                                                Building__r.Name ,  //建物名
                                                PropertyCode__c     //物件コード
                                                FROM Property__c
                                                WHERE PropertyCode__c in :propertyCodeList
                                                ];
        if(propertyList.isEmpty()){
            propertyList = new List<Property__c>();
        }    
        return propertyList;   
    }

    //SOQLのWHEREかANDか
    private string whereOrAnd(Boolean whereFlg){
        String reStr;
        if (whereFlg == true){
            reStr = ' AND ';
        }else{
            reStr = ' WHERE ';
        }
        return reStr;
    }

    //  チェック対象のおすすめ物件を取り出す
    private List<Id> setTheta360bizChangeTarget(Boolean deleteFlg){
        List<Id> recommendPropertyIdList = new List<Id>();
        for(screenRecommendProperty screenRecommendProperty : this.screenRecommendPropertyList){
            // チェックしていないものは次へ
            if(!screenRecommendProperty.isSelected){
                continue;
            }

            // 解除中は次へ（削除ボタン押下時は判定しない）
            if(screenRecommendProperty.displayFlag == DISPLAY_FLAG_RELEASE && !deleteFlg){
                continue;
            }
            
            recommendPropertyIdList.add(screenRecommendProperty.recommendPropertyId);                     
        }
        return recommendPropertyIdList;
    }

//************************************************************************** 内部クラス *************************************************************

    // おすすめ物件
    public class screenRecommendProperty{
        public id     recommendPropertyId  { get; set; }        // Id
        public String propertyCode         { get; set; }        // 物件コード
        public Id     propertyId           { get; set; }        // 物件Id
        public Id     buildingId           { get; set; }        // 建物Id

        public Boolean isSelected          { get; set; }        // 選択行

        public String shopName             { get; set; }        // 登録店舗
        public String UserName             { get; set; }        // 店舗スタッフ
        public String createdDate          { get; set; }        // 登録日
        public String propertyName         { get; set; }        // 物件名
        public String buildingName         { get; set; }        // 建物名
        public String panoramaTourRegister { get; set; }        // パノラマツアー登録
        public String displayFlag          { get; set; }        // おすすめ物件
        public String comment              { get; set; }        // コメント

        public String panoramaTourUrl      { get; set; }        // パノラマツアーURL
        public Datetime systemModStamp     { get; set; }        // SystemModStamp

        public RecommendProperty__c recommendProperty  { get; set; } // おすすめ物件オブジェクト（おすすめ物件モーダル用）

        // コンストラクタ
        public screenRecommendProperty() {
            this.init();
        }
        // コンストラクタ
        public screenRecommendProperty(RecommendProperty__c RecommendProperty,Map<String, Property__c> propertyMap) {
            this.init();
            this.isSelected           = false;   // 選択行

            this.recommendPropertyId  = RecommendProperty.Id;      // Id
            this.propertyCode         = RecommendProperty.PropertyCode__c;      // 物件コード
            
            this.shopName             = RecommendProperty.ShopId__r.name;      // 登録店舗
            this.UserName             = RecommendProperty.UserId__r.name;      // 店舗スタッフ
            this.createdDate          = RecommendProperty.CreatedDate.format('yyyy/MM/dd', 'JST');    // 登録日

            Property__c Property = propertyMap.get(RecommendProperty.PropertyCode__c);
            if(Property != null){
                this.propertyId           = Property.id;                    // 物件Id
                this.propertyName         = Property.name;                  // 物件名
                this.buildingId           = Property.Building__c;           // 建物Id
                this.buildingName         = Property.Building__r.Name;      // 建物名              
            }


            this.panoramaTourRegister = RecommendProperty.PanoramaTourRegister__c;      // パノラマツアー登録
            // おすすめ物件表示フラグの文言出力
            if(RecommendProperty.DisplayFlag__c){
                this.displayFlag      = DISPLAY_FLAG_REGISTERING;       // 登録中
            }else{
                this.displayFlag      = DISPLAY_FLAG_RELEASE;           // 解除
            }
            this.comment              = RecommendProperty.Comment__c;      // コメント
            this.panoramaTourUrl      = recommendProperty.PanoramaTourUrl__c; // パノラマツアーURL
            this.systemModStamp       = recommendProperty.SystemModStamp;   // systemModStamp

            this.recommendProperty    = RecommendProperty;
        }

        // 初期化
        private void init() {
            this.recommendPropertyId  = null;   // Id
            this.propertyCode         = '';     // 物件コード
            this.isSelected           = false;  // 選択行
            this.shopName             = '';     // 登録店舗
            this.UserName             = '';     // 店舗スタッフ
            this.createdDate          = '';     // 登録日
            this.propertyName         = '';     // 物件名
            this.propertyId           = null;   // 物件Id
            this.propertyName         = '';     // 物件名
            this.buildingId           = null;   // 建物ID
            this.buildingName         = '';     // 建物名
            this.panoramaTourRegister = '';     // パノラマツアー登録
            this.displayFlag          = '';     // おすすめ物件
            this.comment              = '';     // コメント
            this.panoramaTourUrl      = '';     // パノラマツアーURL
            this.systemModStamp       = null;   // systemModStamp
            this.recommendProperty    = null;
        }
    }
}