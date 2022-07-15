/* *
 * プレビュー画面のコントローラ
 */
public inherited sharing class GK101006Controller2 {

    /** 定数 */
    // ポータルサイトのCSS先パス（カスタム項目）
    public final String PORTAL_CSS_PATH { get{return SystemConfig__c.getInstance().PortalCSSPath__c;} private set; }            // ポータルCSSパス

    // テンプレートリスト値
    public final String NEWSRELEASE_TEMPLATE_1       { get{return CommonConst_ptl.NEWSRELEASE_TEMPLATE_1;}       private set; } // テンプレート１
    public final String NEWSRELEASE_TEMPLATE_2       { get{return CommonConst_ptl.NEWSRELEASE_TEMPLATE_2;}       private set; } // テンプレート２
    public final String NEWSRELEASE_TEMPLATE_NOTHING { get{return CommonConst_ptl.NEWSRELEASE_TEMPLATE_NOTHING;} private set; } // テンプレートなし

    /** パブリック変数 */
    public String releaseStartDate      { get; set; }   // 記載開始日
    public String title                 { get; set; }   // タイトル
    public String linkSubject1          { get; set; }   // リンク見出し1
    public String linkUrl1              { get; set; }   // リンクURL1
    public String linkSubject2          { get; set; }   // リンク見出し2
    public String linkUrl2              { get; set; }   // リンクURL2
    public String releasePhotoFilePath1 { get; set; }   // 掲載写真ファイルパス１
    public String releasePhotoFilePath2 { get; set; }   // 掲載写真ファイルパス２
    
    // 出力項目（テンプレート無）
    //2021/2/4:htmBodyをoutputFieldで表示する用
    public NewsReleasePreviewParameter__c screenPreview { get; set; } 

    public String template              { get; set; }   // テンプレート種類

    /** プライベート変数 */
    private Id newsReleasePreviewParameterId;           // ニュースリリースプレビュー用Id

    // エラー処理関連
    private Boolean isOpenError;                        // エラーフラグ
    
    // コンストラクタ
    public GK101006Controller2() {
        try{
            this.isOpenError = false;
            this.screenPreview = new NewsReleasePreviewParameter__c();
            getParamData();     // パラメータ取得
            getPreviewData();   // プレビュー表示用データの取得設定
        } catch (Exception e) {
            // エラーを設定
            CommonUtil.setErrorMessage(e);
            this.isOpenError = true;
        }
    }
    //*********************************************************  publicメソッド  ************************************************************
    // ニュースリリースプレビュー用パラメータ削除
    public void deleteNewsReleasePreviewParameter(){
        if(this.isOpenError){
            // 起動時のエラーが発生していれば削除を実行しない
            return;
        }
        //コンストラクタ内のdeleteはエラーとなるため、apex:pageのActionで呼び出す
        Savepoint sp = Database.setsavepoint();
        try{
            // ニュースリリースプレビュー用パラメータ削除
            NewsReleasePreviewParameter__c deletenewsReleasePreviewParameter = new NewsReleasePreviewParameter__c(
                id = this.newsReleasePreviewParameterId
            );
            SecureDML.secureDelete(deletenewsReleasePreviewParameter);
        } catch (Exception e) {
            // エラーを設定
            database.rollback(sp);
            this.isOpenError = TRUE;
            CommonUtil.setErrorMessage(e);
        }
    }

    //*********************************************************  privateメソッド  ************************************************************

    //パラメータ取得
    private void getParamData(){
        this.newsReleasePreviewParameterId = ApexPages.currentPage().getParameters().get('previewParameterId');//物件Map照会用パラメータ用のI
    }

    // プレビュー表示用データの取得設定
    private void getPreviewData(){
        List<NewsReleasePreviewParameter__c> newsReleasePreviewParameterList =  
                [SELECT Id
                ,       Title__c                    // タイトル
                ,       ReleaseStartDate__c         // 掲載開始日
                ,       Template__c                 // テンプレート
                ,       Body1__c                    // 本文１
                ,       Body2__c                    // 本文２
                ,       HtmlBody__c                 // HTML本文
                ,       ReleasePhotoFilePath1__c    // 掲載写真ファイルパス１
                ,       ReleasePhotoFilePath2__c    // 掲載写真ファイルパス２
                ,       LinkSubject1__c             // リンク見出し１
                ,       LinkSubject2__c             // リンク見出し２
                ,       LinkUrl1__c                 // リンクURL１
                ,       LinkUrl2__c                 // リンクURL２
                FROM    NewsReleasePreviewParameter__c 
                WHERE   Id = :newsReleasePreviewParameterId]; //パラメータのIdでニュースリリースプレビュー用パラメータ取得
        
        // チェック結果にエラーがある場合、例外をスローさせる
        checkNewsReleasePreviewParameter(newsReleasePreviewParameterList);

        // プレビュー内容のセット
        setPreviewDate(newsReleasePreviewParameterList);
        
    }

    // ニュースリリースプレビューパラメータがあるかチェック
    private void checkNewsReleasePreviewParameter(List<NewsReleasePreviewParameter__c> newsReleasePreviewParameterList){
        // データが取れない場合、項目をセットしない
        if(newsReleasePreviewParameterList.isEmpty()) {
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst_ptl.MSG_COM_E_NON_NEWS_PREVIEW_PARAM));
            throw ex;
        }
        
    }

    // パラメータのセットをする。
    private void setPreviewDate(List<NewsReleasePreviewParameter__c> newsReleasePreviewParameterList){
        
        this.template = newsReleasePreviewParameterList[0].Template__c;                                 // テンプレート
        this.title = newsReleasePreviewParameterList[0].Title__c;                                       // タイトル
        this.releaseStartDate = newsReleasePreviewParameterList[0].ReleaseStartDate__c.format();        // 掲載開始日
        // テンプレート有
        if(this.template == NEWSRELEASE_TEMPLATE_1 || this.template == NEWSRELEASE_TEMPLATE_2){
            this.screenPreview.Body1__c = newsReleasePreviewParameterList[0].Body1__c;                  // 本文１
            this.screenPreview.Body2__c = newsReleasePreviewParameterList[0].Body2__c;                  // 本文１
            this.releasePhotoFilePath1 = newsReleasePreviewParameterList[0].ReleasePhotoFilePath1__c;   // 掲載写真ファイルパス１
            this.releasePhotoFilePath2 = newsReleasePreviewParameterList[0].ReleasePhotoFilePath2__c;   // 掲載写真ファイルパス２
            this.linkSubject1 = newsReleasePreviewParameterList[0].LinkSubject1__c;                     // リンク見出し１
            this.linkSubject2 = newsReleasePreviewParameterList[0].LinkSubject2__c;                     // リンク見出し２
            this.linkUrl1 = newsReleasePreviewParameterList[0].LinkUrl1__c;                             // リンクURL１
            this.linkUrl2 = newsReleasePreviewParameterList[0].LinkUrl2__c;                             // リンクURL２
        }else if(this.template == NEWSRELEASE_TEMPLATE_NOTHING){
            // テンプレートなしのみhtmlの出力
            this.screenPreview.HtmlBody__c = newsReleasePreviewParameterList[0].HtmlBody__c;             // HTML本文
        }
    }


}