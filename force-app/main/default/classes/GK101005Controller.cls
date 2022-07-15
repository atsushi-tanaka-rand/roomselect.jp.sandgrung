/* *
 * ニュースリリース一覧　のコントローラ
 */
public inherited sharing class GK101005Controller {

    /** public変数 */
    // 検索項目
    public String postedPeriodRadioButton { get; set; }             // 掲載期間（ラジオボタン選択内容）
    public Date   searchSpecifiedDate { get; set; }                 // 指定日
    public String searchReleaseStatus { get; set; }                 // 公開状況
    public String searchTitle         { get; set; }                 // タイトル
    public String searchCreatedName   { get; set; }                 // 作成者名
    public List<SelectOption> searchReleaseStatusList { get; set; } // 公開状況（選択リスト）

    // 明細関係
    Transient public List<NewsRelease__c> getNewsReleaseList { get; set; } // ニュースリリースリスト

    // フラグ類
    public Boolean hasErrorMessage { get; set; }                      // エラーメッセージ保有フラグ
    public Boolean isOpenError     { get; set; }                      // 初期エラーフラグ
    public Boolean isOpetionPortal{ get; set; }                       // 自社ポータル権限 


    // 掲載期間ラジオボタン項目
    public final String PERIODRADIOBUTTON_ALL           {get{return '全て';} private set;}     // 全て
    public final String PERIODRADIOBUTTON_TOMORROWSINCE {get{return '明日以降';} private set;} // 明日以降
    public final String PERIODRADIOBUTTON_SPECIFIED     {get{return '指定';} private set;}     // 指定

    // 固定表示フラグ文言
    public final String NEWSRELEASE_FIXEDDISPLAYFLAG_FIXED {get{return CommonUtil.callMessageCreate(CommonConst_ptl.NEWSRELEASE_FIXEDDISPLAYFLAG_FIXED);} private set;}    // 固定表示True時の文言

    /** private変数 */
    final private Integer INDEX_LIMIT = 1000;                       //検索上限数

    // コンストラクタ
    public GK101005Controller() {
        try{
            // 店舗異動情報の取得（画面操作権限の確認）
            CommonUtil.getStaffCurrentShop();

            //自社権限の取得
            this.isOpetionPortal = AuthorityCheckUtil.getAuthorityOptionPortal(true);
            
            // 初期化
            init();

        } catch(Exception e) {
            // エラー設定
            isOpenError = true;
            CommonUtil.setErrorMessage(e);
        }
    }

//************************************************************************** publicメソッド *************************************************************
    // 検索ボタン処理
    public void search(){
        try{
            // ニュースリリース取得処理
            setNewsRelease();

        } catch(Exception e){
            // 検索エラー
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // ラジオボタン
    public List<SelectOption> getpostedPeriodRadioButtonSetting(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(this.PERIODRADIOBUTTON_ALL, '全て'));
        // 明日以降
        options.add(new SelectOption(this.PERIODRADIOBUTTON_TOMORROWSINCE, '明日以降'));
        // 指定
        options.add(new SelectOption(this.PERIODRADIOBUTTON_SPECIFIED, '指定'));
        
        return options;
    }

//************************************************************************** privateメソッド *************************************************************
    // 初期化
    private void init() {

        // 検索項目の初期設定
        this.postedPeriodRadioButton  = this.PERIODRADIOBUTTON_ALL;  // 掲載期間ラジオボタン
        this.searchSpecifiedDate = null;  // 指定日
        this.searchReleaseStatus = '';  // 公開状況（選択リスト）
        this.searchTitle         = '';  // タイトル
        this.searchCreatedName   = '';  // 作成者名

        // 選択リストの設定
        selectListSetting();

        // エラーメッセージフラグ初期化
        hasErrorMessage = false;
        isOpenError = false;
    }

    // 選択リストの設定
    private void selectListSetting(){
        // 公開状況選択リストの設定
        this.searchReleaseStatusList = CommonUtil.getSelectOptionFromObject('NewsRelease__c', 'ReleaseStatus__c');  
    }

    // ニュースリリース取得処理
    private void setNewsRelease(){

        // 検索結果をセットする。
        this.getNewsReleaseList = selectNewsRelease();

        // 検索結果件数チェック
        if (this.getNewsReleaseList.size() == 0) {
            // 検索結果が０件ならビジネスロジックException発行
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_NO_DATA));
            throw ex;
        }

    }

    // SQL実行
    private List<NewsRelease__c> selectNewsRelease(){
        // 現在日付
        Date toDay = CommonUtil.getToday();

        // 検索条件成形
        String searchCreatedNameMolding = '%' + CommonUtil.convertDisableWildcard((this.searchCreatedName.replace('　', '').trim())) + '%';   // 作成者名
        String searchTitleMolding       = '%' + CommonUtil.convertDisableWildcard(this.searchTitle) + '%'; // タイトル


        // 検索SQL作成
        String sql = '';
        sql += 'SELECT    ID ';                             // ニュースリリースID
        sql += ' ,        FixedDisplayFlag__c ';            // 固定表示フラグ
        sql += ' ,        Name ';                           // タイトル
        sql += ' ,        ReleaseStartDate__c ';            // 掲載開始日
        sql += ' ,        ReleaseEndDate__c ';              // 掲載終了日
        sql += ' ,        ReleaseStatus__c ';               // 公開状況
        sql += ' ,        CreatedBy.Name ';                 // 作成者名
        sql += ' FROM     NewsRelease__c ';                 // ニュースリリースオブジェクト                 
        
        // < ▼ 検索条件 ST >

        Boolean whereFlg = false;       //whereフラグ

        // 指定が選択されている場合
        if(this.postedPeriodRadioButton == this.PeriodRadioButton_Specified && this.searchSpecifiedDate != null ){
            // 指定：掲載開始日≦指定日 and 指定日≦掲載終了日
            sql += whereOrAnd(whereFlg);
            sql += '      ReleaseStartDate__c <= :searchSpecifiedDate';
            sql += ' AND  ReleaseEndDate__c   >= :searchSpecifiedDate';
            whereFlg = true;
        }

        // 明日以降が選択されている場合
        if(this.postedPeriodRadioButton == this.PeriodRadioButton_TomorrowSince){
            // 明日以降：現在日付＜掲載開始日
            sql += whereOrAnd(whereFlg);
            sql += '      ReleaseStartDate__c > :toDay ';
            whereFlg = true;
        }

        if(String.isNotBlank(this.searchReleaseStatus)){
            // 公開状況 
            sql += whereOrAnd(whereFlg);
            sql += '      ReleaseStatus__c = :searchReleaseStatus ';
            whereFlg = true;
        }

        if(String.isNotBlank(this.searchTitle)){
            // タイトル 
            sql += whereOrAnd(whereFlg);
            sql += '      Name  LIKE :searchTitleMolding ';
            whereFlg = true;
        }

        if(String.isNotBlank(this.searchCreatedName)){
            // 作成者名
            sql += whereOrAnd(whereFlg);
            sql += '      CreatedBy.Name  LIKE :searchCreatedNameMolding ';
            whereFlg = true;
        }
    
        // < ▲ 検索条件 ED >
    
        // ソート順
        sql += ' ORDER BY FixedDisplayFlag__c DESC ';       // 固定表示フラグ（降順 Trueのレコードが先頭）
        sql += ' ,        ReleaseStartDate__c DESC ';       // 掲載開始日（降順）

        // 検索上限
        sql += ' LIMIT    :INDEX_LIMIT' ;
        
        // 検索実行＆結果返却
        return Database.query(sql);
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
}