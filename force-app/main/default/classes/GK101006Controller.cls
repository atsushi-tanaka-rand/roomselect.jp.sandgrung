/* *
 * ニュースリリース詳細画面のコントローラ
 */
public inherited sharing class GK101006Controller {

    /** パブリック変数 */
    // パラメータ
    public Id newsReleaseId                     { get; set; }   // ニュースリリースId
    public String selectExampleSentenceText     { get; set; }   // 選択文例テキスト
    public String selectFixedPhraseFolder       { get; set; }   // 選択定型文フォルダ
    public Integer selectFixedPhraseIndex       { get; set; }   // 選択定型文インデックス
    public Boolean isNew                        { get; set; }   // 新規登録フラグ

    public Id newsReleasePreviewParameterId     { get; set; }   // ニュースリリースプレビュー用Id

    // 処理インデックス関連
    public Integer selectPhotoIndex             { get; set; }   // 対象写真インデックス

    // 表示情報
    public ScreenNewsRelease screenNewsRelease  { get; set; }   // 画面用ニュースリリース情報
    public ScreenFixedPhrase screenFixedPhrase  { get; set; }   // 定型文情報

    // 写真処理関連
    public GD901001ParameterClass releasePhotoGD901001Parameter1 { get; set;}   // 掲載写真1
    public GD901001ParameterClass releasePhotoGD901001Parameter2 { get; set;}   // 掲載写真2
    public GD901001ParameterClass releasePhotoGD901001Parameter3 { get; set;}   // 掲載写真3
    public GD901001ParameterClass releasePhotoGD901001Parameter4 { get; set;}   // 掲載写真4
    public GD901001ParameterClass releasePhotoGD901001Parameter5 { get; set;}   // 掲載写真5
    public GD901001ParameterClass releasePhotoGD901001Parameter6 { get; set;}   // 掲載写真6
    public GD901001ParameterClass releasePhotoGD901001Parameter7 { get; set;}   // サムネイル 2022.4.1 No754 サムネイル追加

    // 選択リスト
    public List<SelectOption> releaseStatusList { get; set; }   // 公開状況
    public List<SelectOption> templateList { get; set; }        // テンプレート
    public List<SelectOption> categoryList { get; set; }        // カテゴリ　2022.4.1 No754 カテゴリ選択リスト追加

    // エラー処理関連
    public Boolean isOpenError      { get; set; }   // エラーフラグ
    public Boolean hasErrorMessage  { get; set; }   // エラーメッセージ保有フラグ
    public Boolean isOpetionPortal{ get; set; }    // 自社ポータル権限 

    /** 定数 */
    // メッセージ定数
    public final String MSG_COM_V_SAVE    { get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_SAVE);}     private set; }  // js用保存確認メッセージ
    public final String MSG_COM_I_SAVE    { get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);}     private set; }  // js用保存完了メッセージ
    public final String MSG_COM_V_DELETE  { get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_DELETE);}   private set; }  // js用削除確認メッセージ
    public final String MSG_COM_I_DELETE  { get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_DELETE);}   private set; }  // js用削除完了メッセージ

    // テンプレートリスト値
    public final String NEWSRELEASE_TEMPLATE_1       { get{return CommonConst_ptl.NEWSRELEASE_TEMPLATE_1;}       private set; } // テンプレート１
    public final String NEWSRELEASE_TEMPLATE_2       { get{return CommonConst_ptl.NEWSRELEASE_TEMPLATE_2;}       private set; } // テンプレート２
    public final String NEWSRELEASE_TEMPLATE_NOTHING { get{return CommonConst_ptl.NEWSRELEASE_TEMPLATE_NOTHING;} private set; } // テンプレートなし

    // ▼ 2022.04.01 No754 カテゴリ選択リストを追加
    /** 選択リスト ニュースリリース カテゴリ  */
    public final String NEWSRELEASE_NOTICE           { get{return CommonConst_ptl.NEWSRELEASE_NOTICE;}           private set; } //お知らせ
    public final String NEWSRELEASE_REALESTTECOLUMN  { get{return CommonConst_ptl.NEWSRELEASE_REALESTTECOLUMN;}  private set; } //不動産コラム
    public final String NEWSRELEASE_LOCALINFORMATION { get{return CommonConst_ptl.NEWSRELEASE_LOCALINFORMATION;} private set; } //地域情報
    public final String NEWSRELEASE_EVENTCMPAIGN     { get{return CommonConst_ptl.NEWSRELEASE_EVENTCMPAIGN;}     private set; } //イベント・キャンペーン
    // ▲ 2022.04.01 No754 カテゴリ選択リストを追加

    // 画像処理用　最大登録可能数
    public final Integer MAXINDEX_NEWSRELEASE_RELEASE      { get{return CommonConst_ptl.MAXINDEX_NEWSRELEASE_RELEASE;}     private set; }  // js用公開写真最大登録数
    public final String PROPERTYPHOTOTYPE_NEWSRELEASE      { get{return CommonConst_ptl.S3_PROPERTYPHOTOTYPE_NEWSRELEASE;} private set; }  // js用公開ニュースリリース写真種別

    /** プライベート変数 */

 
    // コンストラクタ
    public GK101006Controller() {
        try {

            // 権限確認　自社ポータルサイトメソッド
            this.isOpetionPortal = AuthorityCheckUtil.getAuthorityOptionPortal(true);

            // 店舗異動情報の取得（画面操作権限の確認）
            CommonUtil.getStaffCurrentShop();


            // パラメータ取得
            getParm();

            // 初期化
            init();
 
            // ニュースリリースの情報を取得
            setNewsRelease();
            
            // 定型文情報取得
            this.screenFixedPhrase = new ScreenFixedPhrase(selectFixedPhrase());

        } catch(Exception e) {
            // エラー設定
            this.isOpenError = true;
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }

    }

    //************************************************publicメソッド *************************************************************

    // 定型文選択処理
    public void clickFixedPhrase() {
        try {
            this.hasErrorMessage = false;

            // 選択定型文を取得
            List<FixedPhrase__c> fixedPhraseList = this.screenFixedPhrase.fixedPhraseMap.get(this.selectFixedPhraseFolder);
            FixedPhrase__c fixedPhrase = fixedPhraseList[this.selectFixedPhraseIndex];

            // タイトルセット
            this.screenNewsRelease.name = String.isEmpty(fixedPhrase.Subject__c) ? '' : fixedPhrase.Subject__c;

            // 本文セット
            this.screenNewsRelease.body1 = String.isEmpty(fixedPhrase.Text__c) ? '' : fixedPhrase.Text__c;

        } catch(Exception e) {
            // エラー設定
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // 削除ボタン押下処理
    public void clickDeleteButton() {
        Savepoint sp = Database.setSavepoint();
        try {
            this.hasErrorMessage = false;

            // ニュースリリース写真削除
            AmazonS3Util.callNewsReleasePhotoDeleteAll(this.newsReleaseId);

            // ニュースリリース削除
            NewsRelease__c deleteNewsRelease = new NewsRelease__c(
                id = this.newsReleaseId
            );
            SecureDML.secureDelete(deleteNewsRelease);

        } catch(Exception e) {
            Database.rollback(sp);//処理をロールバック
            // エラー設定
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // 保存ボタン処理
    public void clickSaveButton(){
        Savepoint sp = Database.setSavepoint();
        try {
            this.hasErrorMessage = false;

            // 楽観ロックチェック（新規登録でない場合）
            if (!isNew) {
                List<NewsRelease__c> checkNewsRelease = [
                    SELECT
                        Id
                    FROM NewsRelease__c
                    WHERE
                        id = :this.screenNewsRelease.Id
                    AND SystemModStamp = :this.screenNewsRelease.SystemModStamp
                ];
                if (checkNewsRelease.isEmpty()) {
                    throw new OptimisticLockException();
                }
            }

            // 入力チェック
            BusinessLogicException ex = new BusinessLogicException();
            ex = checkInput(ex);

            // 表示固定フラグの有無
            if(this.screenNewsRelease.fixedDisplayFlag){
                ex = checkFixedDisplayFlag(ex);
            }
            
            // 入力チェック結果にエラーがある場合、例外をスローさせる
            if (ex.hasMessage()){ 
                throw ex;
            }

            // 保存処理
            this.newsReleaseId = saveNewsRelease();


            // 初期化
            init();

            // ニュースリリースの情報を取得
            setNewsRelease();
            
            // 定型文情報取得
            this.screenFixedPhrase = new ScreenFixedPhrase(selectFixedPhrase());

        } catch(Exception e) {
            Database.rollback(sp);//処理をロールバック
            // エラー設定
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // プレビューボタン
    public void previewButton(){
        try{
            this.hasErrorMessage = false;

            // 入力チェック
            BusinessLogicException ex = new BusinessLogicException();
            ex = checkInput(ex);
            // 入力チェック結果にエラーがある場合、例外をスローさせる
            if (ex.hasMessage()){ 
                throw ex;
            }

             // プレビュー画面へのパラメータ引渡用のレコードを作成する
             NewsReleasePreviewParameter__c newsReleasePreviewParameter = new NewsReleasePreviewParameter__c(
                Title__c                   = this.screenNewsRelease.name   , // タイトル
                ReleaseStartDate__c        = this.screenNewsRelease.releaseStartDate    , // 掲載開始日
                Template__c                = this.screenNewsRelease.template    , // テンプレート
                Body1__c                   = this.screenNewsRelease.body1    , // 本文１
                Body2__c                   = this.screenNewsRelease.body2    , // 本文２
                HtmlBody__c                = this.screenNewsRelease.htmlBody    , // HTML本文
                ReleasePhotoFilePath1__c   = this.screenNewsRelease.releasePhotoFilePath1    , // 掲載写真ファイルパス１
                ReleasePhotoFilePath2__c   = this.screenNewsRelease.releasePhotoFilePath2    , // 掲載写真ファイルパス２
                LinkSubject1__c            = this.screenNewsRelease.linkSubject1    , // リンク見出し１
                LinkSubject2__c            = this.screenNewsRelease.linkSubject2    , // リンク見出し２
                LinkUrl1__c                = this.screenNewsRelease.linkUrl1    , // リンクURL１
                LinkUrl2__c                = this.screenNewsRelease.linkUrl2     // リンクURL２
            );
            SecureDML.secureInsert(newsReleasePreviewParameter);

            this.newsReleasePreviewParameterId = newsReleasePreviewParameter.id;
            system.debug(this.newsReleasePreviewParameterId);

        } catch(Exception e) {
            // エラー設定
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // 写真アップロード後処理
    public void updateReleasePhoto() {
        try {
            this.hasErrorMessage = false;

            // SystemModStampの変更有無を取得する
            // 物件写真を更新する
            if(this.selectPhotoIndex == 1){
                AmazonS3Util.savePhoto(this.releasePhotoGD901001Parameter1);
            }else if(this.selectPhotoIndex == 2){
                AmazonS3Util.savePhoto(this.releasePhotoGD901001Parameter2);
            }else if(this.selectPhotoIndex == 3){
                AmazonS3Util.savePhoto(this.releasePhotoGD901001Parameter3);
            }else if(this.selectPhotoIndex == 4){
                AmazonS3Util.savePhoto(this.releasePhotoGD901001Parameter4);
            }else if(this.selectPhotoIndex == 5){
                AmazonS3Util.savePhoto(this.releasePhotoGD901001Parameter5);
            }else if(this.selectPhotoIndex == 6){
                AmazonS3Util.savePhoto(this.releasePhotoGD901001Parameter6);
            // ▼ 2022.04.01 No754 サムネイル追加
            }else if(this.selectPhotoIndex == 7){
                AmazonS3Util.savePhoto(this.releasePhotoGD901001Parameter7);
            }
            // ▲ 2022.04.01 No754 サムネイル追加

            // 再取得
            setNewsReleasePhoto();
            
        } catch(Exception e) {
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }

    }

    // 写真画像削除処理
    public void deleteNewsReleasePhotoPhoto(){
        try {
            this.hasErrorMessage = false;

            // 画像削除
            AmazonS3Util.callPhotoDelete(this.screenNewsRelease.Id
                                        , AmazonS3Util.PhotoType.NEWSRELEASE, this.selectPhotoIndex);

            // 再取得
            setNewsReleasePhoto();

        } catch(Exception e) {
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    //************************************************privateメソッド *************************************************************
    //パラメータ取得
    private void getParm(){
        // パラメータ取得
        this.newsReleaseId = ApexPages.currentPage().getParameters().get('id');   // ニュースリリースID
    }

    // 新規、更新フラグの設定
    private void setNewFlg(){
        // パラメータの有無から新規であるかを判断する。
        if(String.isEmpty(this.newsReleaseId)){
            this.isNew = true;
        }
    }
    
    //初期処理
    private void init(){
        
        // エラーフラグ初期化
        this.isOpenError = false;
        this.hasErrorMessage = false;

        this.isNew = false;

        // 選択リストの設定
        selectListSetting();

        // フラグ設定
        setNewFlg();

    }

    // 選択リストの設定
    private void selectListSetting(){
        // 公開状況選択リストの設定
        this.releaseStatusList = CommonUtil.getSelectOptionFromObject('NewsRelease__c', 'ReleaseStatus__c');  

        // テンプレート選択リストの設定
        this.templateList = CommonUtil.getSelectOptionFromObject('NewsRelease__c', 'Template__c', false);  

        // カテゴリの選択リストの設定     2022.03.31 No0754 追加 -->
        this.categoryList = CommonUtil.getSelectOptionFromObject('NewsRelease__c', 'Category__c', true); 
    }

    // ニュースリリースの情報を取得する。
    private void setNewsRelease(){
        NewsRelease__c newsRelease = new newsRelease__c();
        if(!this.isNew){
            // 新規でない場合
            newsRelease = selectNewsRelease(this.newsReleaseId);                  // ニュースリリース情報
            // ニュースリリース情報取得
            this.screenNewsRelease = new screenNewsRelease(newsRelease);
        }else{
            // 新規は初期化する。
            this.screenNewsRelease = new screenNewsRelease();
        }

        // 写真情報のセット
        setNewsReleasePhotoList();
    }

    // 写真情報変更時の取得
    private void setNewsReleasePhoto(){
        NewsRelease__c newsRelease = selectNewsRelease(this.newsReleaseId);                  // ニュースリリース情報

        this.screenNewsRelease.releasePhoto1           = newsRelease.ReleasePhoto1__c;            // 掲載写真１
        this.screenNewsRelease.releasePhoto2           = newsRelease.ReleasePhoto2__c;            // 掲載写真２
        this.screenNewsRelease.releasePhoto3           = newsRelease.ReleasePhoto3__c;            // 掲載写真３
        this.screenNewsRelease.releasePhoto4           = newsRelease.ReleasePhoto4__c;            // 掲載写真４
        this.screenNewsRelease.releasePhoto5           = newsRelease.ReleasePhoto5__c;            // 掲載写真５
        this.screenNewsRelease.releasePhoto6           = newsRelease.ReleasePhoto6__c;            // 掲載写真６
        this.screenNewsRelease.releasePhotoFileName1   = newsRelease.ReleasePhotoFileName1__c;    // 掲載写真ファイル名１
        this.screenNewsRelease.releasePhotoFileName2   = newsRelease.ReleasePhotoFileName2__c;    // 掲載写真ファイル名２
        this.screenNewsRelease.releasePhotoFileName3   = newsRelease.ReleasePhotoFileName3__c;    // 掲載写真ファイル名３
        this.screenNewsRelease.releasePhotoFileName4   = newsRelease.ReleasePhotoFileName4__c;    // 掲載写真ファイル名４
        this.screenNewsRelease.releasePhotoFileName5   = newsRelease.ReleasePhotoFileName5__c;    // 掲載写真ファイル名５
        this.screenNewsRelease.releasePhotoFileName6   = newsRelease.ReleasePhotoFileName6__c;    // 掲載写真ファイル名６
        this.screenNewsRelease.releasePhotoFilePath1   = newsRelease.ReleasePhotoFilePath1__c;    // 掲載写真ファイルパス１
        this.screenNewsRelease.releasePhotoFilePath2   = newsRelease.ReleasePhotoFilePath2__c;    // 掲載写真ファイルパス２
        this.screenNewsRelease.releasePhotoFilePath3   = newsRelease.ReleasePhotoFilePath3__c;    // 掲載写真ファイルパス３
        this.screenNewsRelease.releasePhotoFilePath4   = newsRelease.ReleasePhotoFilePath4__c;    // 掲載写真ファイルパス４
        this.screenNewsRelease.releasePhotoFilePath5   = newsRelease.ReleasePhotoFilePath5__c;    // 掲載写真ファイルパス５
        this.screenNewsRelease.releasePhotoFilePath6   = newsRelease.ReleasePhotoFilePath6__c;    // 掲載写真ファイルパス６
        this.screenNewsRelease.ForeignID               = newsRelease.ForeignID__c;                // 外部Id
        this.screenNewsRelease.SystemModStamp          = newsRelease.SystemModStamp;              // System Mod Stamp
        // ▼ 2022.04.01 No754 サムネイル追加
        this.screenNewsRelease.releasePhoto7           = newsRelease.ReleasePhoto7__c;            // サムネイル
        this.screenNewsRelease.releasePhotoFileName7   = newsRelease.ReleasePhotoFileName7__c;    // サムネイルファイル名
        this.screenNewsRelease.releasePhotoFilePath7   = newsRelease.ReleasePhotoFilePath7__c;    // サムネイルファイルパス
        // ▲ 2022.04.01 No754 サムネイル追加
        // 写真情報のセット
        setNewsReleasePhotoList();
    }

    // 掲載写真の取得
    private void setNewsReleasePhotoList(){
        // コンポーネントパラメータ設定
        this.releasePhotoGD901001Parameter1 = setReleaseParameter(1);
        this.releasePhotoGD901001Parameter2 = setReleaseParameter(2);
        this.releasePhotoGD901001Parameter3 = setReleaseParameter(3);
        this.releasePhotoGD901001Parameter4 = setReleaseParameter(4);
        this.releasePhotoGD901001Parameter5 = setReleaseParameter(5);
        this.releasePhotoGD901001Parameter6 = setReleaseParameter(6);
        this.releasePhotoGD901001Parameter7 = setReleaseParameter(7);    // 2022.04.01 No754 サムネイル追加
    }

    // アップロードの情報をセットする。
    private GD901001ParameterClass setReleaseParameter(Integer fileNo){
        GD901001ParameterClass photoGD901001Parameter = new GD901001ParameterClass();
        photoGD901001Parameter.isNew = this.isNew;
        photoGD901001Parameter.isMosaic = false;
        photoGD901001Parameter.photoType    = CommonConst_ptl.S3_PHOTOTYPE_NEWSRELEASE;
        photoGD901001Parameter.photoSubType = CommonConst_ptl.S3_PROPERTYPHOTOTYPE_NEWSRELEASE+ CommonUtil.decimalToString(fileNo);
        photoGD901001Parameter.parameter    = CommonUtil.decimalToString(fileNo);        // 処理対象番号
        photoGD901001Parameter.fileName = '';
        photoGD901001Parameter.filePath = '';
        photoGD901001Parameter.isArea = true;
        photoGD901001Parameter.height = '100px';
        photoGD901001Parameter.foreignId   = this.screenNewsRelease.ForeignID;  // ニュースリリス外部ID

        return photoGD901001Parameter;

    }

    // 入力チェック
    private BusinessLogicException checkInput(BusinessLogicException ex) {
        // 必須入力チェック
        List<String> requiredItem = new List<String>();

        // 掲載開始日
        if (this.screenNewsRelease.releaseStartDate == null){
            requiredItem.add('掲載開始日');
        }

        // 公開状況
        if (String.isEmpty(this.screenNewsRelease.releaseStatus)){
            requiredItem.add('公開状況');
        }

        // タイトル
        if (String.isEmpty(this.screenNewsRelease.Name)){
            requiredItem.add('タイトル');
        }

        // ▲ 2022.04.01 No754 カテゴリ選択リスト追加
        // カテゴリ
        if (String.isEmpty(this.screenNewsRelease.category)){
            requiredItem.add('カテゴリ');
        }
        // ▲ 2022.04.01 No754 カテゴリ選択リスト追加

        // テキスト定型フォームタブ（テンプレート１とテンプレート２）
        if(this.screenNewsRelease.template == NEWSRELEASE_TEMPLATE_1 || 
           this.screenNewsRelease.template == NEWSRELEASE_TEMPLATE_2){
            // 本文１
            if (String.isEmpty(this.screenNewsRelease.body1)){
                requiredItem.add('本文');
            }
        }

        // HTMLエディタタブ（テンプレートなし）
        if(this.screenNewsRelease.template == NEWSRELEASE_TEMPLATE_NOTHING){
            if (String.isEmpty(this.screenNewsRelease.htmlBody)){
                requiredItem.add('本文');
            }
        }

        // 必須入力チェック用リストが空ではない場合、ビジネスロジックException発行
        if (!requiredItem.isEmpty()){
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ', ')));
        }

        // 掲載終了日が掲載開始日を上回る場合
        if( this.screenNewsRelease.releaseEndDate  < this.screenNewsRelease.releaseStartDate ){
            ex.addMessage(CommonConst.MSG_COM_W_SEARCH_DATE_TERM);
        }

        return ex;
    }

    // 固定表示フラグの他データのチェック
    private BusinessLogicException checkFixedDisplayFlag(BusinessLogicException ex){

        // 検索SQL作成
        String sql = '';
        sql += 'SELECT    ID ';                             // ニュースリリースID
        sql += ' FROM     NewsRelease__c ';                 // ニュースリリースオブジェクト                 
        sql += ' WHERE    FixedDisplayFlag__c = True ';     // 固定表示フラグが立っている。
        if(!isNew){
            // 新規でない場合のみ
            sql += ' AND  ID != :newsReleaseId '; // 自身のIDを含めない
        }
        
        // 検索実行＆結果返却
        List<NewsRelease__c> newsReleaseList = Database.query(sql);
        // レコードが取得できた場合
        if (newsReleaseList.size() > 0) {
            ex.addMessage(CommonConst_ptl.NEWS_E_SAVE_DISPLAY_FLAG_DUPLICATE);
        }
        return ex;
    }

    // ニュースリリースの保存処理
    private String saveNewsRelease(){
        // ニュースリリース
        NewsRelease__c newsRelease = new NewsRelease__c();
        if (!this.isNew) {
            newsRelease.Id = this.screenNewsRelease.Id;
        }
        newsRelease.Description__c  =  this.screenNewsRelease.description;                            // ディスクリプション  2022.05.27 No0833 オウンドメディアのdescription差し替え対応
        newsRelease.name  =                         this.screenNewsRelease.name;                      // タイトル
        newsRelease.ReleaseStartDate__c  =          this.screenNewsRelease.releaseStartDate;          // 掲載開始日
        if(this.screenNewsRelease.releaseEndDate == null){
            // 空は最大日付を設定する
            newsRelease.ReleaseEndDate__c  =            Date.newInstance(4000, 12, 31);               // 掲載終了日
        }else{
            newsRelease.ReleaseEndDate__c  =            this.screenNewsRelease.releaseEndDate;        // 掲載終了日
        }
        
        newsRelease.ReleaseStatus__c  =             this.screenNewsRelease.releaseStatus;             // 公開状況
        newsRelease.Template__c  =                  this.screenNewsRelease.template;                  // テンプレート
        newsRelease.FixedDisplayFlag__c  =          this.screenNewsRelease.fixedDisplayFlag;          // 固定表示フラグ
        newsRelease.Body1__c  =                     replaceEmptyCharacterToSpecialCharacters(this.screenNewsRelease.body1);    // 本文１
        newsRelease.Body2__c  =                     replaceEmptyCharacterToSpecialCharacters(this.screenNewsRelease.body2);    // 本文２
        newsRelease.HtmlBody__c  =                  this.screenNewsRelease.htmlBody;                  // HTML本文
        newsRelease.LinkSubject1__c  =              this.screenNewsRelease.linkSubject1;              // リンク見出し１
        newsRelease.LinkSubject2__c  =              this.screenNewsRelease.linkSubject2;              // リンク見出し２
        newsRelease.LinkUrl1__c  =                  this.screenNewsRelease.linkUrl1;                  // リンクURL１
        newsRelease.LinkUrl2__c  =                  this.screenNewsRelease.linkUrl2;                  // リンクURL２
        // ▼ 2022.04.01 No754 オウンドメディア対応
        newsRelease.Category__c  =                  this.screenNewsRelease.category;                  // カテゴリ
        // ▲ 2022.04.01 No754 オウンドメディア対応

        // 保存処理
        SecureDML.secureUpsert(newsRelease);

        return newsRelease.id;
    }

    // ニュースリリース情報取得
    private NewsRelease__c selectNewsRelease(Id newsReleaseId){
        List<NewsRelease__c> newsReleaseList = [
            SELECT  Id
            ,       name                        // タイトル
            ,       ReleaseStartDate__c         // 掲載開始日
            ,       ReleaseEndDate__c           // 掲載終了日
            ,       ReleaseStatus__c            // 公開状況
            ,       Template__c                 // テンプレート
            ,       FixedDisplayFlag__c         // 固定表示フラグ
            ,       Body1__c                    // 本文１
            ,       Body2__c                    // 本文２
            ,       HtmlBody__c                 // HTML本文
            ,       ReleasePhoto1__c            // 掲載写真１
            ,       ReleasePhoto2__c            // 掲載写真２
            ,       ReleasePhoto3__c            // 掲載写真３
            ,       ReleasePhoto4__c            // 掲載写真４
            ,       ReleasePhoto5__c            // 掲載写真５
            ,       ReleasePhoto6__c            // 掲載写真６
            ,       ReleasePhotoFileName1__c    // 掲載写真ファイル名１
            ,       ReleasePhotoFileName2__c    // 掲載写真ファイル名２
            ,       ReleasePhotoFileName3__c    // 掲載写真ファイル名３
            ,       ReleasePhotoFileName4__c    // 掲載写真ファイル名４
            ,       ReleasePhotoFileName5__c    // 掲載写真ファイル名５
            ,       ReleasePhotoFileName6__c    // 掲載写真ファイル名６
            ,       ReleasePhotoFilePath1__c    // 掲載写真ファイルパス１
            ,       ReleasePhotoFilePath2__c    // 掲載写真ファイルパス２
            ,       ReleasePhotoFilePath3__c    // 掲載写真ファイルパス３
            ,       ReleasePhotoFilePath4__c    // 掲載写真ファイルパス４
            ,       ReleasePhotoFilePath5__c    // 掲載写真ファイルパス５
            ,       ReleasePhotoFilePath6__c    // 掲載写真ファイルパス６
            ,       LinkSubject1__c             // リンク見出し１
            ,       LinkSubject2__c             // リンク見出し２
            ,       LinkUrl1__c                 // リンクURL１
            ,       LinkUrl2__c                 // リンクURL２
            ,       SystemModStamp              // System Mod Stamp
            ,       ForeignID__c                // 外部ID
            // ▼ 2022.04.01 No754 オウンドメディア対応
            ,       Category__c                 // カテゴリ
            ,       ReleasePhoto7__c            // サムネイル
            ,       ReleasePhotoFileName7__c    // サムネイルファイル名
            ,       ReleasePhotoFilePath7__c    // サムネイルファイルパス
            // ▲ 2022.04.01 No754 オウンドメディア対応
            ,       Description__c              // ディスクリプション    2022.05.27 No0833 オウンドメディアのdescription差し替え対応
            FROM    NewsRelease__c
            WHERE   Id = :newsReleaseId
            LIMIT 1
        ];
        // レコードが取得できない場合はビジネスロジックExceptionを発行する
        if (newsReleaseList.isEmpty()) {
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
            throw ex;
        }
        return newsReleaseList[0];
    }

    // 定型文情報取得
    private List<FixedPhrase__c> selectFixedPhrase(){
        List<FixedPhrase__c> fixedPhrase = [
            SELECT
                Id
                ,Name       // 定型文名
                ,Folder__c  // フォルダ
                ,Subject__c // 件名
                ,Text__c        // 本文
            FROM FixedPhrase__c     // 定型文
            WHERE UsageScreen__c = :CommonConst_ptl.FIXEDPHRASE_USAGESCREEN_NEWSRELEASE
            ORDER BY
                Folder__c
                ,Name
        ];
        // レコードが取得できない場合はnewしたリストを返す
        if (fixedPhrase.isEmpty()) {
            return new List<FixedPhrase__c>();
        }
        return fixedPhrase;
    }

    // 空文字を特殊文字に変換する
    private String replaceEmptyCharacterToSpecialCharacters(String target){
        if(String.isEmpty(target)){
            return target;
        }
        // 全角スペース「&emsp;」
        target = target.replace('　', '&emsp;');
        // 半角スペース「&nbsp;」
        target = target.replace(' ', '&nbsp;');

        return target;
    }  




    //************************************************内部クラス *************************************************************
    // 画面表示用クラス
    public class ScreenNewsRelease {
        public String id                    { get; set; }   // Id
        public String description           { get; set; }   // ディスクリプション  2022.05.27 No0833　オウンドメディアのdescription差し替え対応
        public String name                  { get; set; }   // タイトル
        public Date releaseStartDate        { get; set; }   // 掲載開始日
        public date releaseEndDate          { get; set; }   // 掲載終了日
        public String releaseStatus         { get; set; }   // 公開状況
        public String template              { get; set; }   // テンプレート
        public Boolean fixedDisplayFlag     { get; set; }   // 固定表示フラグ
        public String body1                 { get; set; }   // 本文１
        public String body2                 { get; set; }   // 本文２
        public String htmlBody              { get; set; }   // HTML本文
        public String releasePhoto1         { get; set; }   // 掲載写真１
        public String releasePhoto2         { get; set; }   // 掲載写真２
        public String releasePhoto3         { get; set; }   // 掲載写真３
        public String releasePhoto4         { get; set; }   // 掲載写真４
        public String releasePhoto5         { get; set; }   // 掲載写真５
        public String releasePhoto6         { get; set; }   // 掲載写真６
        public String releasePhotoFileName1 { get; set; }   // 掲載写真ファイル名１
        public String releasePhotoFileName2 { get; set; }   // 掲載写真ファイル名２
        public String releasePhotoFileName3 { get; set; }   // 掲載写真ファイル名３
        public String releasePhotoFileName4 { get; set; }   // 掲載写真ファイル名４
        public String releasePhotoFileName5 { get; set; }   // 掲載写真ファイル名５
        public String releasePhotoFileName6 { get; set; }   // 掲載写真ファイル名６
        public String releasePhotoFilePath1 { get; set; }   // 掲載写真ファイルパス１
        public String releasePhotoFilePath2 { get; set; }   // 掲載写真ファイルパス２
        public String releasePhotoFilePath3 { get; set; }   // 掲載写真ファイルパス３
        public String releasePhotoFilePath4 { get; set; }   // 掲載写真ファイルパス４
        public String releasePhotoFilePath5 { get; set; }   // 掲載写真ファイルパス５
        public String releasePhotoFilePath6 { get; set; }   // 掲載写真ファイルパス６
        public String linkSubject1          { get; set; }   // リンク見出し１
        public String linkSubject2          { get; set; }   // リンク見出し２
        public String linkUrl1              { get; set; }   // リンクURL１
        public String linkUrl2              { get; set; }   // リンクURL２
        // ▼ 2022.04.01 No754 オウンドメディア対応
        public String category              { get; set; }   // カテゴリ
        public String releasePhoto7         { get; set; }   // サムネイル
        public String releasePhotoFileName7 { get; set; }   // サムネイルファイル名
        public String releasePhotoFilePath7 { get; set; }   // サムネイルファイルパス
        // ▲ 2022.04.01 No754 オウンドメディア対応

        public String   ForeignID           { get; set; }   // 外部Id
        public Datetime SystemModStamp      { get; set; }   // System Mod Stamp
        
        // コンストラクタ
        public ScreenNewsRelease() {
            this.init();
        }
        // コンストラクタ
        public ScreenNewsRelease(NewsRelease__c newsRelease) {
            this.init();

            this.id                      = newsRelease.Id;                          // ID
            this.description             = newsRelease.Description__c;              // ディスクリプション  2022.05.27 No0833 オウンドメディアのdescription差し替え対応
            this.name                    = newsRelease.name;                        // タイトル
            this.releaseStartDate        = newsRelease.ReleaseStartDate__c;         // 掲載開始日
            this.releaseEndDate          = newsRelease.ReleaseEndDate__c;           // 掲載終了日
            this.releaseStatus           = newsRelease.ReleaseStatus__c;            // 公開状況
            this.template                = newsRelease.Template__c;                 // テンプレート
            this.fixedDisplayFlag        = newsRelease.FixedDisplayFlag__c;         // 固定表示フラグ
            this.body1                   = replaceSpecialCharactersToEmptyCharacter(newsRelease.Body1__c);                    // 本文１
            this.body2                   = replaceSpecialCharactersToEmptyCharacter(newsRelease.Body2__c);                    // 本文２
            this.htmlBody                = newsRelease.HtmlBody__c;                 // HTML本文
            this.releasePhoto1           = newsRelease.ReleasePhoto1__c;            // 掲載写真１
            this.releasePhoto2           = newsRelease.ReleasePhoto2__c;            // 掲載写真２
            this.releasePhoto3           = newsRelease.ReleasePhoto3__c;            // 掲載写真３
            this.releasePhoto4           = newsRelease.ReleasePhoto4__c;            // 掲載写真４
            this.releasePhoto5           = newsRelease.ReleasePhoto5__c;            // 掲載写真５
            this.releasePhoto6           = newsRelease.ReleasePhoto6__c;            // 掲載写真６
            this.releasePhotoFileName1   = newsRelease.ReleasePhotoFileName1__c;    // 掲載写真ファイル名１
            this.releasePhotoFileName2   = newsRelease.ReleasePhotoFileName2__c;    // 掲載写真ファイル名２
            this.releasePhotoFileName3   = newsRelease.ReleasePhotoFileName3__c;    // 掲載写真ファイル名３
            this.releasePhotoFileName4   = newsRelease.ReleasePhotoFileName4__c;    // 掲載写真ファイル名４
            this.releasePhotoFileName5   = newsRelease.ReleasePhotoFileName5__c;    // 掲載写真ファイル名５
            this.releasePhotoFileName6   = newsRelease.ReleasePhotoFileName6__c;    // 掲載写真ファイル名６
            this.releasePhotoFilePath1   = newsRelease.ReleasePhotoFilePath1__c;    // 掲載写真ファイルパス１
            this.releasePhotoFilePath2   = newsRelease.ReleasePhotoFilePath2__c;    // 掲載写真ファイルパス２
            this.releasePhotoFilePath3   = newsRelease.ReleasePhotoFilePath3__c;    // 掲載写真ファイルパス３
            this.releasePhotoFilePath4   = newsRelease.ReleasePhotoFilePath4__c;    // 掲載写真ファイルパス４
            this.releasePhotoFilePath5   = newsRelease.ReleasePhotoFilePath5__c;    // 掲載写真ファイルパス５
            this.releasePhotoFilePath6   = newsRelease.ReleasePhotoFilePath6__c;    // 掲載写真ファイルパス６
            this.linkSubject1            = newsRelease.LinkSubject1__c;             // リンク見出し１
            this.linkSubject2            = newsRelease.LinkSubject2__c;             // リンク見出し２
            this.linkUrl1                = newsRelease.LinkUrl1__c;                 // リンクURL１
            this.linkUrl2                = newsRelease.LinkUrl2__c;                 // リンクURL２
            // ▼ 2022.04.01 No754 オウンドメディア対応
            this.category                = newsRelease.Category__c;                 // カテゴリ
            this.releasePhoto7           = newsRelease.ReleasePhoto7__c;            // サムネイル
            this.releasePhotoFileName7   = newsRelease.ReleasePhotoFileName7__c;    // サムネイルファイル名
            this.releasePhotoFilePath7   = newsRelease.ReleasePhotoFilePath7__c;    // サムネイルファイルパス
            // ▲ 2022.04.01 No754 オウンドメディア対応
            this.ForeignID               = newsRelease.ForeignID__c;                // 外部Id
            this.SystemModStamp          = newsRelease.SystemModStamp;              // System Mod Stamp
 
        }


        
        // 初期化
        private void init() {
            this.id                     = '';       // Id
            this.releaseStartDate       = null;     // 掲載開始日
            this.releaseEndDate         = null;     // 掲載終了日
            this.releaseStatus          = '';       // 公開状況
            this.template               = '';       // テンプレート
            this.fixedDisplayFlag       = false;    // 固定表示フラグ
            this.body1                  = '';       // 本文１
            this.body2                  = '';       // 本文２
            this.htmlBody               = '';       // HTML本文
            this.releasePhoto1          = '';       // 掲載写真１
            this.releasePhoto2          = '';       // 掲載写真２
            this.releasePhoto3          = '';       // 掲載写真３
            this.releasePhoto4          = '';       // 掲載写真４
            this.releasePhoto5          = '';       // 掲載写真５
            this.releasePhoto6          = '';       // 掲載写真６
            this.releasePhotoFileName1  = '';       // 掲載写真ファイル名１
            this.releasePhotoFileName2  = '';       // 掲載写真ファイル名２
            this.releasePhotoFileName3  = '';       // 掲載写真ファイル名３
            this.releasePhotoFileName4  = '';       // 掲載写真ファイル名４
            this.releasePhotoFileName5  = '';       // 掲載写真ファイル名５
            this.releasePhotoFileName6  = '';       // 掲載写真ファイル名６
            this.releasePhotoFilePath1  = '';       // 掲載写真ファイルパス１
            this.releasePhotoFilePath2  = '';       // 掲載写真ファイルパス２
            this.releasePhotoFilePath3  = '';       // 掲載写真ファイルパス３
            this.releasePhotoFilePath4  = '';       // 掲載写真ファイルパス４
            this.releasePhotoFilePath5  = '';       // 掲載写真ファイルパス５
            this.releasePhotoFilePath6  = '';       // 掲載写真ファイルパス６
            this.linkSubject1           = '';       // リンク見出し１
            this.linkSubject2           = '';       // リンク見出し２
            this.linkUrl1               = '';       // リンクURL１
            this.linkUrl2               = '';       // リンクURL２
            // ▼ 2022.04.01 No754 オウンドメディア対応
            this.category               = '';       // カテゴリ
            this.releasePhoto7          = '';       // サムネイル
            this.releasePhotoFileName7  = '';       // サムネイルファイル
            this.releasePhotoFilePath7  = '';       // サムネイルファイルパス
            // ▲ 2022.04.01 No754 オウンドメディア対応
            this.ForeignID              = null;     // 外部Id
            this.SystemModStamp         = null;     // System Mod Stamp
        }

        // 特殊文字の空文字を通常の空文字に変換する
        private String replaceSpecialCharactersToEmptyCharacter(String target){
            if(String.isEmpty(target)){
                return target;
            }
            // 全角スペース「&emsp;」
            target = target.replaceAll('&emsp;', '　');
            // 半角スペース「&nbsp;」
            target = target.replaceAll('&nbsp;', ' ');

            return target;
        } 
    }

    // 画面表示用クラス（定型文）
    public class ScreenFixedPhrase {
        public List<String> folder { get; set; } // フォルダ
        public Map<String, List<FixedPhrase__c>> fixedPhraseMap { get; set; }   // 定型文名
        // コンストラクタ
        public ScreenFixedPhrase() {
            // 初期化
            this.folder = new List<String>();
            this.fixedPhraseMap = new Map<String, List<FixedPhrase__c>>();
        }
        // コンストラクタ
        public ScreenFixedPhrase(List<FixedPhrase__c> fixedPhrase) {
            // 初期化
            this.folder = new List<String>();
            this.fixedPhraseMap = new Map<String, List<FixedPhrase__c>>();

            // フォルダ名をキーとした定型文レコードのMapを作成
            for (FixedPhrase__c record : fixedPhrase) {
                List<FixedPhrase__c> temp = new List<FixedPhrase__c>();
                if (this.fixedPhraseMap.containsKey(record.Folder__c)) {
                    temp = this.fixedPhraseMap.get(record.Folder__c);
                } else {
                    this.folder.add(record.Folder__c);
                }
                temp.add(record);
                this.fixedPhraseMap.put(record.Folder__c, temp);
            }

        }

    }
}