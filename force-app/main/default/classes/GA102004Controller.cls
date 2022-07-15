/* *
 * メール送信画面のコントローラ
 */
public inherited sharing class GA102004Controller {

    /** パブリック変数 */
    // パラメータ
    public Id shopId                            { get; set; }   // 店舗Id
    public Id accountId                         { get; set; }   // 取引先Id
    public String email                         { get; set; }   // メールアドレス
    public Id mailDraftId                       { get; set; }   // メール下書きId
    public Id mailTimeSpecificationSendingId    { get; set; }   // メール時間指定送信Id
    public Id correspondId                      { get; set; }   // 対応Id
    public Id correspondDetailId                { get; set; }   // 対応明細Id
    public Boolean isReply                      { get; set; }   // 返信フラグ
    public String isSueURL                      { get; set; }   // 発行URL
    public Boolean isInitPropertyDetail         { get; set; }   // 物件詳細情報初期表示フラグ

    public ScreenMailInfo screenMailInfo        { get; set; }   // メール情報
    public ScreenFixedPhrase screenFixedPhrase  { get; set; }   // 定型文情報
    public ScreenExampleSentence screenExampleSentence  { get; set; }   // 文例情報
    public List<Attachment> attachmentList      { get; set; }   // 添付ファイル情報
    public Integer attachmentTotalSize          { get; set; }   // 添付ファイル合計サイズ
	// ▼ 2021.12.3 LINE連携対応より、ユーザヘッダ部の追加
	public ScreenUserHead screenUserHead {get; set;}
	// ▲ 2021.12.3

    public String selectFixedPhraseFolder       { get; set; }   // 選択定型文フォルダ
    public Integer selectFixedPhraseIndex       { get; set; }   // 選択定型文インデックス

    public String selectExampleSentenceText     { get; set; }   // 選択文例テキスト

    public Integer deleteAttachmentIndex        { get; set; }   // 添付ファイル削除対象インデックス
    public Id tempAttachmentParentId            { get; set; }   // 添付ファイル一時保存用ParentId

    // ポータルサイト構築 追加 Start
    public List<screenFavoriteProperty> screenFavoritePropertyList  { get; set; }   // お気に入り物件情報リスト 
    public Integer creenFavoritePropertyCount   { get; set; }                       // お気に入り物件情報件数
    // ポータルサイト構築 追加 End

    // エラー処理関連
    public Boolean isOpenError      { get; set; }   // エラーフラグ
    public Boolean hasErrorMessage  { get; set; }   // エラーメッセージ保有フラグ

    // 自社ポータルの権限フラグ
    public Boolean authorityOptionPortalFlg  { get; set; }   // 自社ポータルの権限フラグ // ポータルサイト構築 追加
    public Boolean portalRedirecAddFlg       { get; set; }   // 自社ポータルリダイレクト内容追加フラグ（True ：自社ポータルでのリダイレクトの内容を追加する
                                                             //                                      False：自社ポータルでのリダイレクトの内容を追加しない）// ポータル問合せNo0016で追加

    // 選択リスト
    public List<SelectOption> sendingTimeList { get; set; } // 送信時刻（00～23）

    // パラメータ
    public GA102004Modal1ParameterClass GA102004Modal1Parameter { get; set; }   // 確認モーダル用
    public GA102004Modal2ParameterClass GA102004Modal2Parameter { get; set; }   // 定型文選択モーダル用
    public GA102004Modal3ParameterClass GA102004Modal3Parameter { get; set; }   // 文例集選択モーダル用

    /** 定数 */
    // メッセージ定数
    public String MSG_COM_V_SAVE    { get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_SAVE);}     private set; }  // js用保存確認メッセージ
    public String MSG_COM_I_SAVE    { get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);}     private set; }  // js用保存完了メッセージ
    public String MSG_COM_V_DELETE  { get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_DELETE);}   private set; }  // js用削除確認メッセージ
    public String MSG_COM_I_DELETE  { get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_DELETE);}   private set; }  // js用削除完了メッセージ

    /** プライベート変数 */
    public Shop__c shop                             { get; set; }   // 店舗
    private Account sendAccount                     { get; set; }   // 取引先
    private Correspond__c correspond                { get; set; }   // 対応
    private CorrespondDetail__c correspondDetail    { get; set; }   // 対応明細
    private MailDraft__c mailDraft                  { get; set; }   // メール下書き
    private MailTimeSpecificationSending__c mailTimeSpecificationSending { get; set; }  // メール時間指定送信
    private EchoMail__c echoMail                    { get; set; }   // 反響メール
    private Id attachmentParentId                   { get; set; }   // 添付ファイル参照先Id
    private String shopUserName; //店舗担当者名

    //対応オブジェクトの更新日付
    public dateTime compareToTime = null;

    // ポータルサイト構築 追加 Start
    /** プライベート定数 */
    final private Integer INDEX_LIMIT = 1000;   //検索上限数
    final private String PORTAL_SITE_URL = SystemConfig__c.getInstance().PortalSiteURL__c + 'detail';   // ポータルサイトURL
    // ポータルサイト構築 追加 End


    private enum Mode {
        DRAFT               // 下書き
        ,TIMESPECIFICATION  // 時間指定
        ,REPLY              // 返信
        ,OTHER
    }
    private Mode mode { get; set; }

    public GA102004Controller() {
        try {
            // ポータルサイト構築 追加 Start
            // 権限取得　自社ポータルサイト
            this.authorityOptionPortalFlg = AuthorityCheckUtil.getAuthorityOptionPortal(false);
            this.portalRedirecAddFlg = false;       //ポータル問合せNo0016で追加
            // ポータルサイト構築 追加 End

            // エラーフラグ初期化
            this.isOpenError = false;
            this.hasErrorMessage = false;

            // パラメータ取得
            this.shopId                         = ApexPages.currentPage().getParameters().get('shopId');                        // 店舗Id
            this.accountId                      = ApexPages.currentPage().getParameters().get('accountId');                     // 取引先Id
            this.email                          = ApexPages.currentPage().getParameters().get('email');                         // メールアドレス
            this.mailDraftId                    = ApexPages.currentPage().getParameters().get('mailDraftId');                   // メール下書きId
            this.mailTimeSpecificationSendingId = ApexPages.currentPage().getParameters().get('mailTimeSpecificationSendingId');// メール時間指定送信Id
            this.correspondId                   = ApexPages.currentPage().getParameters().get('correspondId');                  // 対応Id
            this.correspondDetailId             = ApexPages.currentPage().getParameters().get('correspondDetailId');            // 対応明細Id
            String temp                         = ApexPages.currentPage().getParameters().get('isReply');                       // 返信フラグ
            this.isReply = null;
            if (String.isNotEmpty(temp)) {
                if (temp.toLowerCase() == 'true') {
                    this.isReply = true;
                } else if (temp.toLowerCase() == 'false') {
                    this.isReply = false;
                }
            }

            // パラメータ必須チェック
            // 取引先Id nullはエラー
            if (this.accountId == null) {
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
                throw ex;
            }

            //店舗異動が取得できない場合エラー
            CommonUtil.getStaffCurrentShop();

            // 初期化
            this.mailDraft                      = new MailDraft__c();
            this.mailTimeSpecificationSending   = new MailTimeSpecificationSending__c();
            this.attachmentList                 = new List<Attachment>();
            this.attachmentTotalSize            = 0;
            this.correspond                     = new Correspond__c();
            this.correspondDetail               = new CorrespondDetail__c();
            this.echoMail                       = new EchoMail__c();

            // 処理パータンの判定と情報取得
            if (String.isNotEmpty(this.mailDraftId)) {
                // メール下書きId指定ありの場合
                this.mode = GA102004Controller.Mode.DRAFT;
                // メール下書き 情報取得
                this.mailDraft = selectMailDraft(this.mailDraftId);
                // 添付ファイル 情報取得
                this.attachmentList = selectAttachment(this.mailDraftId);
                this.attachmentParentId = this.mailDraftId;
                // 対応Id取得
                if (this.correspondId == null) {
                    this.correspondId = this.mailDraft.Correspond__c;
                }
                // 対応明細Id取得
                if (this.correspondDetailId == null) {
                    this.correspondDetailId = this.mailDraft.CorrespondDetail__c;
                }
                // 返信フラグの取得
                if (this.isReply == null) {
                    this.isReply = mailDraft.IsReply__c;
                }
            } else if (String.isNotEmpty(this.mailTimeSpecificationSendingId)) {
                // メール時間指定送信Id指定ありの場合
                this.mode = GA102004Controller.Mode.TIMESPECIFICATION;
                // メール時間指定送信 情報取得
                this.mailTimeSpecificationSending = selectMailTimeSpecificationSending(this.mailTimeSpecificationSendingId);
                // 添付ファイル 情報取得
                this.attachmentList = selectAttachment(this.mailTimeSpecificationSendingId);
                this.attachmentParentId = this.mailTimeSpecificationSendingId;
                // 対応Id取得
                if (this.correspondId == null) {
                    this.correspondId = this.mailTimeSpecificationSending.Correspond__c;
                }
                // 対応明細Id取得
                if (this.correspondDetailId == null) {
                    this.correspondDetailId = this.mailTimeSpecificationSending.CorrespondDetail__c;
                }
                // 返信フラグの取得
                if (this.isReply == null) {
                    this.isReply = mailTimeSpecificationSending.IsReply__c;
                }
            } else if (this.isReply == true && String.isNotEmpty(this.correspondDetailId)) {
                this.mode = GA102004Controller.Mode.REPLY;
            } else {
                this.mode = GA102004Controller.Mode.OTHER;
            }
            if (this.isReply == null) {
                this.isReply = false;
            }

            // 取引先（送信先）情報取得
            this.sendAccount = this.selectAccount(this.accountId);

			// ▼ 2021.12.3 LINE連携対応より、ユーザヘッダ部の追加
			this.setScreenUserHead();
			// ▲ 2021.12.3

            // 対応 情報取得
            if (String.isNotEmpty(this.correspondId)) {
                this.correspond = selectCorrespond(this.correspondId);
                //更新前のSystemModstamp取得
                compareToTime = this.correspond.systemModstamp;
            }
            // 対応明細、反響メール 情報取得
            if (String.isNotEmpty(this.correspondDetailId)) {
                // 対応明細
                this.correspondDetail = selectCorrespondDetail(this.correspondDetailId);
                // 反響メール （対応明細に紐付く）
                this.echoMail = selectEchoMail(this.correspondDetail.EchoMail__c);
            }

            // 店舗（送信者）
            Shop__c staffCurrentShop = CommonUtil.getStaffCurrentShop();
            this.shop = new Shop__c();
            // ログイン者店舗＝反響担当店舗の場合その店舗
            if (staffCurrentShop.Id == this.correspond.EchoShop__c) {
                this.shopId = staffCurrentShop.Id;
            // 来店担当店舗が設定されていればその店舗
            } else if (String.isNotEmpty(this.correspond.VisitShop__c)) {
                this.shopId = this.correspond.VisitShop__c;
            // 反響担当店舗が設定されていればその店舗
            } else if (String.isNotEmpty(this.correspond.EchoShop__c)) {
                this.shopId = this.correspond.EchoShop__c;
            }
            if (this.shopId == null) {
                // 来店担当店舗、反響担当店舗がなく、パラメータ指定がない場合、以下でセット
                if (this.mode == GA102004Controller.Mode.DRAFT && String.isNotEmpty(this.mailDraft.Shop__c)) {
                    // メール下書きで、店舗Idが登録されている場合
                    this.shopId = this.mailDraft.Shop__c;
                } else if (this.mode == GA102004Controller.Mode.TIMESPECIFICATION && String.isNotEmpty(this.mailTimeSpecificationSending.Shop__c)) {
                    // メール時間指定送信で、店舗Idが登録されている場合
                    this.shopId = this.mailTimeSpecificationSending.Shop__c;
                } else {
                    // ログインユーザの店舗
                    this.shop = staffCurrentShop;
                    this.shopId = this.shop.Id;
                }
            }
            if (String.isEmpty(this.shop.Id)) {
                this.shop = selectShop(this.shopId);
            }
            
            // 担当者
            if (String.isNotEmpty(this.correspond.ShopStaffName__c)) { 
                this.shopUserName = this.correspond.ShopStaffName__c; //来店担当者がいれば優先する
            } else if (String.isNotEmpty(this.correspond.EchoStaffName__c)) {
                this.shopUserName = this.correspond.EchoStaffName__c; //反響担当者
            } else {
                this.shopUserName = '';
            }
            
            

            // 画面表示情報作成
            switch on this.mode {
            when DRAFT {
                // メール下書き
                this.screenMailInfo = new ScreenMailInfo(this.sendAccount, this.shop, this.mailDraft);
            }
            when TIMESPECIFICATION {
                // メール時間指定送信
                this.screenMailInfo = new ScreenMailInfo(this.sendAccount, this.shop, this.mailTimeSpecificationSending);
            }
            when REPLY {
                // 返信メール
                this.screenMailInfo = new ScreenMailInfo(this.sendAccount, this.shop, this.echoMail);
            }
            when OTHER {
                // その他
                this.screenMailInfo = new ScreenMailInfo(this.sendAccount, this.shop);
            }
            }

            // 物件詳細の初期表示フラグを設定（ポータルサイトからの反響メール）
            this.isInitPropertyDetail = false;
            if (this.mode == GA102004Controller.Mode.OTHER
                && String.isNotEmpty(this.echoMail.FromPotalSite__c)) {
                this.isInitPropertyDetail = true;
            }

            // 送信先 初期選択
            if (String.isNotEmpty(this.email)) {
                if (this.mode != GA102004Controller.Mode.DRAFT && this.mode != GA102004Controller.Mode.TIMESPECIFICATION) {
                    this.screenMailInfo.clearSendToChecked();
                }
                this.screenMailInfo.setSendToChecked(this.email, true);
            }

            // 定型文情報取得
            this.screenFixedPhrase = new ScreenFixedPhrase(selectFixedPhrase());
            // 文例情報取得
            this.screenExampleSentence = new ScreenExampleSentence(selectExampleSentence());

            // ポータルサイト構築 追加 Start
            // お気に入り物件情報の取得
            this.screenFavoritePropertyList = new List<screenFavoriteProperty>();
            if(this.authorityOptionPortalFlg){
                this.screenFavoritePropertyList = setScreenFavoriteProperty(selectFavoriteProperty(this.accountId));
                this.portalRedirecAddFlg = true;            //ポータル問合せNo0016で追加
            }
            this.creenFavoritePropertyCount = this.screenFavoritePropertyList.size();
            // ポータルサイト構築 追加 End            

            // 送信時刻用のリスト作成
            this.sendingTimeList = new List<SelectOption>();
            this.sendingTimeList.add(new SelectOption('', ''));
            for (Integer i = 0; i < 24; i++) {
                this.sendingTimeList.add(
                    new SelectOption(
                        String.valueOf(i).leftPad(2, '0')
                        ,String.valueOf(i).leftPad(2, '0')
                    )
                );
            }

            // 確認モーダルパラメータ初期化
            this.GA102004Modal1Parameter = new GA102004Modal1ParameterClass();
            // 定型文モーダルパラメータ初期化
            this.GA102004Modal2Parameter = new GA102004Modal2ParameterClass();
            // 文例集モーダルパラメータ初期化
            this.GA102004Modal3Parameter = new GA102004Modal3ParameterClass();

        } catch(Exception e) {
            // エラー設定
            this.isOpenError = true;
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }

    }

    // 物件詳細の初期表示
    public void initPropertyDetail() {
        try {
            this.hasErrorMessage = false;
            // 物件詳細を本文に初期表示（ポータルサイトからの反響メール）
            if (this.isInitPropertyDetail) {
                this.screenMailInfo.body = getPropertyDetail(this.echoMail) + '\n' + this.screenMailInfo.body; 
            }
        } catch(Exception e) {
            // エラー設定
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // 発行ボタン押下処理
    public void clickIssue() {
        try {
            this.hasErrorMessage = false;

            // URL 入力チェック
            if (String.isEmpty(screenMailInfo.propertyURL)) {
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_INPUT, '発行を行う場合,URL'.split(',')));
                throw ex;
            }

            this.portalRedirecAddFlg = false;       //ポータル問合せNo0016で追加

            // リダイレクトURL作成、設定
            isSueURL = '';
            isSueURL = screenMailInfo.propertyDetail + '<br>' + getPropertyDetailURL(screenMailInfo.propertyURL, screenMailInfo.propertyDetail);
            isSueURL = isSueURL;

            //▼ポータル問合せNo0016で追加
            if(this.authorityOptionPortalFlg){
                this.portalRedirecAddFlg = true;
            }
            //▲ポータル問合せNo0016で追加
        } catch(Exception e) {
            // エラー設定
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // ポータルサイト構築 追加 Start
    // 発行ボタン押下処理（お気に入り物件）
    public void clickIssueFavoriteProperty() {
        try {
            this.hasErrorMessage = false;

            // リダイレクトURL作成、設定
            isSueURL = '';
            for(screenFavoriteProperty screenFavoriteProperty : screenFavoritePropertyList ){
                // チェックの無いお気に入り物件は除外
                if(!screenFavoriteProperty.isSelected){
                    continue;
                }
                isSueURL += screenFavoriteProperty.propertyDetail + '<br>' + getPropertyDetailURL(screenFavoriteProperty.propertyURL, screenFavoriteProperty.propertyDetail) + '<br> <br>' ;
            }

            if(string.isEmpty(isSueURL)){
                // １件もリダイレクトURLが作成できなければエラーとする。
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_NO_SELECTION, 'お気に入り物件'));
                throw ex;
            }

        } catch(Exception e) {
            // エラー設定
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    // ポータルサイト構築 追加 End

    // 定型文選択処理
    public void clickFixedPhrase() {
        try {
            this.hasErrorMessage = false;

            // 選択定型文を取得
            List<FixedPhrase__c> fixedPhraseList = this.screenFixedPhrase.fixedPhraseMap.get(this.selectFixedPhraseFolder);
            FixedPhrase__c fixedPhrase = fixedPhraseList[this.selectFixedPhraseIndex];

            // 件名セット
            this.screenMailInfo.subject = this.replaceText(
                String.isEmpty(fixedPhrase.Subject__c) ? '' : fixedPhrase.Subject__c
                ,this.shopUserName
                ,this.shop
                ,this.sendAccount
                ,this.echoMail
                ,this.screenMailInfo.sendingTime
            );

            // 本文セット
            this.screenMailInfo.body = this.replaceText(
                String.isEmpty(fixedPhrase.Text__c) ? '' : fixedPhrase.Text__c
                ,this.shopUserName
                ,this.shop
                ,this.sendAccount
                ,this.echoMail
                ,this.screenMailInfo.sendingTime
            );

        } catch(Exception e) {
            // エラー設定
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // 削除ボタン押下処理
    public void clickDelete() {
        Savepoint sp = Database.setSavepoint();
        try {
            this.hasErrorMessage = false;

            switch on this.mode {
            when DRAFT {
                // 下書き削除

                // 添付ファイル 削除
                SecureDML.secureDelete(this.attachmentList);

                // メール下書き 削除
                SecureDML.secureDelete(this.mailDraft);

            }
            when TIMESPECIFICATION {
                // 時間指定送信削除

                // メール下書き 作成（時間指定送信⇒下書き）
                MailDraft__c insMailDraft = new MailDraft__c();
                insMailDraft.Name                   = this.mailTimeSpecificationSending.Name;               // 名称
                insMailDraft.From__c                = this.mailTimeSpecificationSending.From__c;            // 送信者
                insMailDraft.To__c                  = this.mailTimeSpecificationSending.To__c;              // 宛先
                insMailDraft.Cc__c                  = this.mailTimeSpecificationSending.Cc__c;              // CC
                insMailDraft.Subject__c             = this.mailTimeSpecificationSending.Subject__c;         // 件名
                insMailDraft.Body__c                = this.mailTimeSpecificationSending.Body__c;            // メール内容
                insMailDraft.Shop__c                = this.mailTimeSpecificationSending.Shop__c;            // 店舗
                insMailDraft.Account__c             = this.mailTimeSpecificationSending.Account__c;         // 取引先
                insMailDraft.SendingDateTime__c     = this.mailTimeSpecificationSending.SendingDateTime__c; // 送信予定日時
                insMailDraft.Correspond__c          = this.mailTimeSpecificationSending.Correspond__c;      // 対応
                insMailDraft.CorrespondDetail__c    = this.mailTimeSpecificationSending.CorrespondDetail__c;// 対応明細
                insMailDraft.IsReply__c             = this.mailTimeSpecificationSending.IsReply__c;         // 返信フラグ
				// ▼ 2021.12.3 LINE連携対応より、LINE紹介フラグを追加
				insMailDraft.IsLineIntroduction__c	= this.mailTimeSpecificationSending.IsLineIntroduction__c;
				// ▲ 2021.12.3
                SecureDML.secureInsert(insMailDraft);

                // 添付ファイル 移行（時間指定送信⇒下書き）
                if (this.attachmentList.size() > 0) {
                    List<Attachment> attachment = [
                        SELECT
                            Id
                            ,Name
                            ,Body
                            ,OwnerId
                        FROM Attachment
                        WHERE
                            ParentId = :this.attachmentList[0].ParentId
                    ];
                    List<Attachment> newAttachmentList = new List<Attachment>();
                    for (Attachment record : attachment) {
                        Attachment tempAtt = new Attachment();
                        tempAtt.Name       = record.Name;
                        tempAtt.Body       = record.Body;
                        tempAtt.ParentId   = insMailDraft.Id;
                        newAttachmentList.add(tempAtt);
                    }
                    SecureDML.secureInsert(newAttachmentList);
                    SecureDML.secureDelete(this.attachmentList);
                }

                // メール時間指定送信 削除
                SecureDML.secureDelete(this.mailTimeSpecificationSending);

            }
            }

        } catch(Exception e) {
            Database.rollback(sp);//処理をロールバック
            // エラー設定
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // 添付ファイル押下処理（添付の削除）
    public void clickAttachmentDelete() {
        try {
            this.hasErrorMessage = false;

            // 削除処理
            List<Attachment> delAttachment = [
                SELECT
                    Id
                FROM
                    Attachment
                WHERE
                    Id = :this.attachmentList[this.deleteAttachmentIndex].Id
            ];
            SecureDML.secureDelete(delAttachment);

            // 削除後の添付を再取得
            this.attachmentList = selectAttachment(this.attachmentParentId);

        } catch(Exception e) {
            // エラー設定
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // 定型文選択（モーダル起動）ボタン押下処理
    public void openFixedPhraseSelect() {
        try {
            this.hasErrorMessage = false;

            // 入力チェック
            BusinessLogicException ex = new BusinessLogicException();

            // モーダル起動準備
            this.GA102004Modal2Parameter = new GA102004Modal2ParameterClass();
            this.GA102004Modal2Parameter.fixedPhrase    = this.screenFixedPhrase;
            this.GA102004Modal2Parameter.isDrawing      = true;
            this.GA102004Modal2Parameter.noFirst        = true;

        } catch(Exception e) {
            // エラー設定
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // 定型文選択（モーダル起動）ボタン終了処理
    public void closeFixedPhraseSelect() {
        try {
            this.hasErrorMessage = false;

            // 入力チェック
            BusinessLogicException ex = new BusinessLogicException();

            // モーダル選択値取得処理
            this.selectFixedPhraseFolder = this.GA102004Modal2Parameter.selectFolder;
            this.selectFixedPhraseIndex  = this.GA102004Modal2Parameter.selectIndex;

            // 定型文選択処理
            clickFixedPhrase();

        } catch(Exception e) {
            // エラー設定
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // 文例集選択（モーダル起動）ボタン押下処理
    public void openExampleSentenceSelect() {
        try {
            this.hasErrorMessage = false;

            // 入力チェック
            BusinessLogicException ex = new BusinessLogicException();

            // モーダル起動準備
            this.GA102004Modal3Parameter = new GA102004Modal3ParameterClass();
            this.GA102004Modal3Parameter.exampleSentence    = this.screenExampleSentence;
            this.GA102004Modal3Parameter.isDrawing          = true;
            this.GA102004Modal3Parameter.noFirst            = true;

        } catch(Exception e) {
            // エラー設定
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // 確認ボタン押下処理
    public void clickConfirm() {
        try {
            this.hasErrorMessage = false;

            // 入力チェック
            BusinessLogicException ex = new BusinessLogicException();

            // 件名,本文 必須入力チェック
            List<String> requiredItem = new List<String>();
            if (String.isEmpty(this.screenMailInfo.subject)){
                requiredItem.add('件名');
            }
            if (String.isEmpty(this.screenMailInfo.body)){
                requiredItem.add('本文');
            }
            if (!requiredItem.isEmpty()){
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ', ')));
            }
            // 宛先 必須選択チェック
            Boolean isChecked = false;
            for (CheckText sendTo : this.screenMailInfo.sendTo) {
                if (sendTo.isCheck) {
                    isChecked = true;
                    break;
                }
            }
            if (!isChecked) {
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_NO_SELECTION, '宛先'));
            }
            // 送信日時チェック
            if (this.screenMailInfo.sendingDate != null || String.isNotEmpty(this.screenMailInfo.sendingTime)) {
                // 日付・時刻いずれか１つでも入力

                if (this.screenMailInfo.sendingDate == null || String.isEmpty(this.screenMailInfo.sendingTime)) {
                    // 日付・時刻いずれか１つでも未入力
                    ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_INPUT, '日時指定を行う場合,日付と時刻両方'.split(',')));
                } else {
                    // 日付・時刻両方入力あり
                    Date tempDate = this.screenMailInfo.sendingDate;
                    Datetime tempDateTime = Datetime.newInstance(tempDate.year(), tempDate.month(), tempDate.day(), Integer.valueOf(this.screenMailInfo.sendingTime), 0, 0);
                    // 過去日時チェック
                    if (tempDateTime < CommonUtil.getNow()) {
                        ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SENDPALNDATETIME_OLD));
                    }
                }
            }

            // 入力チェック結果にエラーがある場合、例外をスローさせる
            if (ex.hasMessage()){ 
                throw ex;
            }


            // 確認モーダル処理
            this.GA102004Modal1Parameter.mailInfo           = this.screenMailInfo;
            this.GA102004Modal1Parameter.shopId             = this.shopId;
            this.GA102004Modal1Parameter.accountId          = this.accountId;
            this.GA102004Modal1Parameter.account            = this.sendAccount;
            this.GA102004Modal1Parameter.mailDraftId        = this.mailDraftId;
            this.GA102004Modal1Parameter.mailTimeSpecificationSendingId = this.mailTimeSpecificationSendingId;
            this.GA102004Modal1Parameter.correspondId       = this.correspondId;
            this.GA102004Modal1Parameter.correspond         = this.correspond;
            this.GA102004Modal1Parameter.correspondDetailId = this.correspondDetailId;
            this.GA102004Modal1Parameter.isReply            = this.isReply;
            this.GA102004Modal1Parameter.messageId          = '';
            this.GA102004Modal1Parameter.references         = '';
            if (this.isReply) {
                this.GA102004Modal1Parameter.messageId      = String.isEmpty(this.echoMail.MessageId__c)  ? '' : this.echoMail.MessageId__c;
                this.GA102004Modal1Parameter.references     = String.isEmpty(this.echoMail.References__c) ? '' : this.echoMail.References__c;
            }
            this.GA102004Modal1Parameter.isDrawing          = true;
            this.GA102004Modal1Parameter.noFirst            = true;
            this.GA102004Modal1Parameter.compareToTime      = this.compareToTime;

        } catch(Exception e) {
            // エラー設定
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // 下書き保存ボタン押下処理
    public void clickDraftSave() {
        Savepoint sp = Database.setSavepoint();
        try {
            this.hasErrorMessage = false;

            // 件名 必須入力チェック
            if (String.isEmpty(this.screenMailInfo.subject)){
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, '件名'));
                throw ex;
            }


            // 下書き保存処理

            // メール下書き 情報作成（画面⇒下書き）
            MailDraft__c upsMailDraft = new MailDraft__c();
            upsMailDraft.Id                     = this.mailDraft.Id;
            upsMailDraft.Name                   = CommonUtil.subStringLeft(this.screenMailInfo.subject, 80);   // 名称　※件名をセット（最大80文字）
            upsMailDraft.From__c                = this.screenMailInfo.sendFromMail; // 送信者
            String temp = '';
            for (CheckText mail : this.screenMailInfo.sendTo) {
                if (mail.isCheck) {
                    temp += String.isEmpty(temp) ? '' : ';';
                    temp += mail.value;
                }
            }
            upsMailDraft.To__c                  = temp;                             // 宛先
            temp = '';
            for (CheckText mail : this.screenMailInfo.cc) {
                if (mail.isCheck) {
                    temp += String.isEmpty(temp) ? '' : ';';
                    temp += mail.value;
                }
            }
            upsMailDraft.Cc__c                  = temp;                             // CC
            upsMailDraft.Subject__c             = this.screenMailInfo.subject;      // 件名
            upsMailDraft.Body__c                = this.screenMailInfo.body;         // メール内容
            upsMailDraft.Shop__c                = this.shopId;                      // 店舗
            upsMailDraft.Account__c             = this.accountId;                   // 取引先
            Datetime tempDateTime = null;
            if (this.screenMailInfo.sendingDate != null && String.isNotEmpty(this.screenMailInfo.sendingTime)) {
                Date tempDate = this.screenMailInfo.sendingDate;
                tempDateTime = Datetime.newInstance(tempDate.year(), tempDate.month(), tempDate.day(), Integer.valueOf(this.screenMailInfo.sendingTime), 0, 0);
            }
            upsMailDraft.SendingDateTime__c     = tempDateTime;                     // 送信予定日時
            upsMailDraft.Correspond__c          = this.correspondId;                // 対応
            upsMailDraft.CorrespondDetail__c    = this.correspondDetailId;          // 対応明細
            upsMailDraft.IsReply__c             = this.isReply;                     // 返信フラグ
			upsMailDraft.IsLineIntroduction__c  = this.screenMailInfo.isLineFriendIntroduction; // 2021.12.3 LINE連携対応より、LINE紹介フラグを追加
            SecureDML.secureUpsert(upsMailDraft);


            // 添付ファイル一時保存情報の取得
            if (String.isNotEmpty(this.tempAttachmentParentId)) {
                List<Attachment> attachment = [
                    SELECT
                        Name
                        ,Body
                        ,OwnerId
                    FROM Attachment
                    WHERE
                        ParentId = :this.tempAttachmentParentId
                ];
                List<Attachment> newAttachmentList = new List<Attachment>();
                for (Attachment record : attachment) {
                    Attachment tempAtt = new Attachment();
                    tempAtt.Name       = record.Name;
                    tempAtt.Body       = record.Body;
                    tempAtt.ParentId   = upsMailDraft.Id;
                    newAttachmentList.add(tempAtt);
                }
                SecureDML.secureInsert(newAttachmentList);
                // 添付ファイル一時保存情報の削除
                SecureDML.secureDelete(attachment);
                List<MailDraft__c> delMailDraft = [
                    SELECT
                        Id
                    FROM MailDraft__c
                    WHERE
                        Id = :this.tempAttachmentParentId
                ];
                SecureDML.secureDelete(delMailDraft);
            }

            // 時間指定送信 の下書き保存の場合
            if (this.mode == GA102004Controller.Mode.TIMESPECIFICATION) {
                // 添付ファイル 移行（時間指定送信⇒下書き）
                if (this.attachmentList.size() > 0) {
                    List<Attachment> attachment = [
                        SELECT
                            Name
                            ,Body
                            ,OwnerId
                        FROM Attachment
                        WHERE
                            ParentId = :this.attachmentList[0].ParentId
                    ];
                    List<Attachment> newAttachmentList = new List<Attachment>();
                    for (Attachment record : attachment) {
                        Attachment tempAtt = new Attachment();
                        tempAtt.Name       = record.Name;
                        tempAtt.Body       = record.Body;
                        tempAtt.ParentId   = upsMailDraft.Id;
                        newAttachmentList.add(tempAtt);
                    }
                    SecureDML.secureInsert(newAttachmentList);
                    SecureDML.secureDelete(this.attachmentList);
                }

                // メール時間指定送信 削除
                SecureDML.secureDelete(this.mailTimeSpecificationSending);

            }

            // 添付ファイル一時レコード削除（不要なレコードが残ってしまっていた場合の念のための削除）
            GA102004Controller.deleteTempMailDraft();

        } catch(Exception e) {
            Database.rollback(sp);//処理をロールバック
            // エラー設定
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // 初期表示・文字置換用の物件詳細取得（反響メールより）
    private String getPropertyDetail(EchoMail__c echoMail) {
        String propertyDetail = '';
        // 所在地
        propertyDetail += echoMail.PropertyAddress__c;
        // 最寄駅
        propertyDetail += propertyDetail == '' && String.isNotEmpty(echoMail.ClosestStation__c) ? '' : '/';
        propertyDetail += String.isNotEmpty(echoMail.ClosestStation__c) ? echoMail.ClosestStation__c : '';
        // 徒歩
        propertyDetail += propertyDetail == '' && String.isNotEmpty(echoMail.WalkTime__c) ? '' : '/';
        propertyDetail += String.isNotEmpty(echoMail.WalkTime__c) ? echoMail.WalkTime__c : '';
        // 間取り
        propertyDetail += propertyDetail == '' && String.isNotEmpty(echoMail.RoomLayout__c) ? '' : '/';
        propertyDetail += String.isNotEmpty(echoMail.RoomLayout__c) ? echoMail.RoomLayout__c : '';
        // 賃料
        propertyDetail += propertyDetail == '' && String.isNotEmpty(echoMail.RentFee__c) ? '' : '/';
        propertyDetail += String.isNotEmpty(echoMail.RentFee__c) ? echoMail.RentFee__c : '';
        // 物件URL
        // ポータルサイト構築 変更 Start
        String potalSiteURL = '';
        if(this.authorityOptionPortalFlg){
            potalSiteURL = PORTAL_SITE_URL + '?propertyCd=' + echoMail.PropertyCode__c;         // ポータルサイトURL
        }else{
            potalSiteURL = echoMail.PropertURL__c;
        }
        String propertyURL = getPropertyDetailURL(potalSiteURL, String.isNotEmpty(echoMail.PropertyName__c) ? echoMail.PropertyName__c : '');
        // ポータルサイト構築 変更 End 
        propertyDetail += propertyDetail == '' && String.isNotEmpty(propertyURL) ? '' : '\n';
        propertyDetail += propertyURL;

        return propertyDetail;

    }

    // リダイレクトURL作成
    // https://【リダイレクトURL】?rs=<portalsaite=【ポータルサイトURL】&utm_source=mail&utm_medium=email&utm_campaign=【現在日付】&account=【取引先ID】&property=【物件詳細】&correspond=【対応ID】>
    // 【リダイレクトURL】  ：herokuのリダイレクト用のURL
    // 【ポータルサイトURL】：ポータルサイトの自社物件のURL（URL欄の入力内容）
    // 【取引先ID】         ：メール送信先のお客様のID     （パラメータ．取引先ID）
    // 【物件詳細】         ：ポータルサイトの自社物件詳細 （物件詳細欄の入力内容）
    // 【対応ID】           ：メール送信指定された対応ID （パラメータ．対応ID）
    // &utm_source=mail&utm_medium=email&utm_campaign=【現在日付】：自社ポータルでの追加のパラメータ【現在日付】は「yyyyMMdd」
    // ※<>部分については暗号化を行う。
    private String getPropertyDetailURL(String potalSiteURL, String propertyDetail) {

        // リダイレクトURL（heroku）
        String reDirectURL = SystemConfig__c.getInstance().RedirectURL__c;

        // パラメータ内容作成
        String param = '';
        param += 'portalsite=' + potalSiteURL;
        //▼ポータル問合せNo0016で追加
        if(this.authorityOptionPortalFlg && this.portalRedirecAddFlg){
            // 送信メールへのパラメータ追加
            param += '&utm_source=mail&utm_medium=email&utm_campaign='+CommonUtil.getNow().format('yyyyMMdd');
        }
        //▲ポータル問合せNo0016で追加
        param += '&account=' + this.accountId;
        param += '&property=' + propertyDetail;
        param += '&correspond=' + this.correspondId;

        // URL番号採番
        String urlNo = numberingRedirectUrl();

        // リダイレクトURLパラメータ情報作成（採番URL番号でパラメータ内容を登録）
        RedirectUrlParameter__c urlParam = new RedirectUrlParameter__c();
        urlParam.Name           = urlNo;
        urlParam.Parameter__c   = param;
        SecureDML.secureInsert(urlParam);

        // リダイレクトURL番号履歴情報作成
        RedirectUrlNoHistory__c urlNoHist = new RedirectUrlNoHistory__c();
        urlNoHist.Name          = urlNo;
        SecureDML.secureInsert(urlNoHist);

        //2020.05.07　削除してはいけないためコメントアウト 2020/6/12コメントアウト取り消し
        // リダイレクトURLパラメータ情報削除（1日以上経過しているレコードが対象）
        deleteRedirectUrlParameter();

        // リダイレクトURL作成
        reDirectURL = reDirectURL + '?rs=' + urlNo;

        return reDirectURL;

    }

    // リダイレクトURL番号の採番
    private String numberingRedirectUrl() {
        String urlNo = '';
        Boolean noExists = true;
        // URL番号の採番（重複しない番号が生成できるまでループ）
        while (noExists) {
            urlNo = CommonUtil.getRandomString(10);
            noExists = existsRedirectUrlNo(urlNo);
        }
        return urlNo;
    }

    // ポータルサイト構築 追加 Start
    // お気に入り物件をセットする
    private List<screenFavoriteProperty> setScreenFavoriteProperty(List<FavoriteProperty__c> favoritePropertyList){
        List<screenFavoriteProperty> screenFavoritePropertyList = new List<screenFavoriteProperty>();
        // Map<Id, screenFavoriteProperty> screenFavoritePropertyMap = new Map<Id, screenFavoriteProperty>();
        List<Id> PropertyIdList = new List<Id>();
        for(FavoriteProperty__c favoriteProperty : favoritePropertyList){
            screenFavoritePropertyList.add(new screenFavoriteProperty(favoriteProperty,PORTAL_SITE_URL));
            PropertyIdList.add(favoriteProperty.Property__c);
        }
        // お気に入り物件が自社ポータルの掲載が可能かを取得する。
        List<PortalSitePostingProperty__c> portalSitePostingPropertyList = selectPortalSitePostingProperty(PropertyIdList);
        for(screenFavoriteProperty screenFavoriteProperty : screenFavoritePropertyList){
            for(PortalSitePostingProperty__c portalSitePostingProperty : portalSitePostingPropertyList){
                // 一致しない物件IDはスルー
                if(portalSitePostingProperty.Property__c != screenFavoriteProperty.propertyId){
                    continue;
                }

                // 対象のポータルサイト掲載物件にて自社ポータルのフラグが立っていなければ次のループへ
                if(!portalSitePostingProperty.IsPortal__c){
                    continue;
                }
                // 自社ポータルがあればフラグを立てる
                screenFavoriteProperty.isPortalFlg = portalSitePostingProperty.IsPortal__c;
                break;
            }

        }

        return screenFavoritePropertyList;
    }
    // ポータルサイト構築 追加 End


    // 文字列置換処理
    private String replaceText(String editText ,String userName, Shop__c shop, Account account, EchoMail__c echoMail ,String sendingTime) {
        // 文字列置換パターンを作成
        Map<String, String> replaceTextMap = new Map<String, String>();
        replaceTextMap.put('{お客様名}', String.isEmpty(account.Name) ? '' : account.Name);
        replaceTextMap.put('{担当者名}', String.isEmpty(userName) ? '' : userName);
        replaceTextMap.put('{店舗名}', String.isEmpty(shop.Name) ? '' : shop.Name);
        replaceTextMap.put('{郵便番号}', String.isEmpty(shop.PostalCode__c) ? '' : shop.PostalCode__c);
        replaceTextMap.put('{店舗住所１}', String.isEmpty(shop.City__c) ? '' : shop.City__c);
        replaceTextMap.put('{店舗住所２}', String.isEmpty(shop.Street__c) ? '' : shop.Street__c);
        replaceTextMap.put('{電話番号}', String.isEmpty(shop.Phone__c) ? '' : shop.Phone__c);
        replaceTextMap.put('{FAX}', String.isEmpty(shop.Fax__c) ? '' : shop.Fax__c);
        replaceTextMap.put('{営業時間}', String.isEmpty(shop.BusinessHours__c) ? '' : shop.BusinessHours__c);
        replaceTextMap.put('{定休日}', String.isEmpty(shop.RegularHoliday__c) ? '' : shop.RegularHoliday__c);
        replaceTextMap.put('{店舗HP}', String.isEmpty(shop.Homepage__c) ? '' : shop.Homepage__c);
        String temp = '';
        if (String.isNotEmpty(echoMail.PropertURL__c)) {
            temp = getPropertyDetail(echoMail);
        }
        replaceTextMap.put('{反響メール物件URL}', String.isEmpty(temp) ? '' : temp);

        
        //↓現在の時刻を取得し、当てはまる時間帯で合わせて挨拶が変える処理
        //送信予定時刻が設定されている場合は送信予定時刻、設定されていない場合は現時刻を設定する
        String getTime = '';
        if(sendingTime != null){
           getTime = sendingTime;
        }else{
           getTime = CommonUtil.getNow().format('H'); 
        }
        
        Integer partTime = Integer.valueOf(getTime); 
        System.debug(partTime);
        
        //(5時から10時)なら'おはようございます。'
        if(5 <= partTime && partTime <= 10){
            replaceTextMap.put('{あいさつ}', 'おはようございます。');
        }
           //(11時から17時)なら'こんにちは。'
        if(11 <= partTime && partTime <= 17){
            replaceTextMap.put('{あいさつ}', 'こんにちは。');
        }
           //(18時から20時)なら'こんばんは。'
        if(18 <= partTime && partTime <= 20){
            replaceTextMap.put('{あいさつ}', 'こんばんは。');
        }
           //(21時から4時)なら'夜分遅くに失礼いたします。'
        if(21 <= partTime || partTime <= 4){
            replaceTextMap.put('{あいさつ}', '夜分遅くに失礼いたします。');
        }   

        // 文字列置換
        temp = editText;
        for (String key : replaceTextMap.keySet()) {
            temp = temp.replace(key, replaceTextMap.get(key));
        }

        return temp;

    }

	// ▼ 2021.12.3 LINE連携対応より、ユーザヘッダ部の取得処理の追加
	/**
	 * ユーザヘッダ部の設定
	 */
	private void setScreenUserHead() {

		// LINE会員の取得
		LineMember__c lineMember = this.selectLineMember(this.accountId);

		// ユーザヘッダ部の設定
		this.screenUserHead = new screenUserHead(lineMember, this.sendAccount.Name);
	}

	/**
	 * LINE会員の取得
	 * @param Id condAccountId 取引先Id
	 * @return LineMember__c LINE会員
	 */
	private LineMember__c selectLineMember(Id condAccountId) {

		List<LineMember__c> lineMemberList = [
			SELECT
				Name
			FROM LineMember__c
			WHERE Account__c = :condAccountId
		];

		if (lineMemberList.isEmpty()) {
			return new LineMember__c();
		}

		return lineMemberList[0];
	}
	// ▲ 2021.12.3

    // 店舗情報取得
    private Shop__c selectShop(Id shopId) {
        List<Shop__c> shop = [
            SELECT
                Id
                ,Name               // 店舗名
                ,Email__c           // メール
                ,PostalCode__c      // 郵便番号
                ,City__c            // 住所１（市区町村）
                ,Street__c          // 住所２（番地）
                ,Phone__c           // 電話番号
                ,Fax__c             // FAX
                ,BusinessHours__c   // 営業時間
                ,RegularHoliday__c  // 定休日
                ,Homepage__c        // HP
            FROM Shop__c            // 店舗
            WHERE
                Id  = :shopId
        ];
        // レコードが取得できない場合はビジネスロジックExceptionを発行する
        if (shop.isEmpty()) {
            shop = new List<Shop__c>();
            return new Shop__c();
        }
        return shop[0];
    }

    // 取引先情報取得
    private Account selectAccount(Id accountId) {
        List<Account> account = [
            SELECT
                Id
                ,RecordTypeId   // レコードタイプId
                ,Name           // 取引先名
                ,Email__c       // メール
                ,Email2__c      // メール２
                ,Email3__c      // メール３
            FROM Account     // 取引先
            WHERE
                Id  = :accountId
        ];
        // レコードが取得できない場合はビジネスロジックExceptionを発行する
        if (account.isEmpty()) {
            account = new List<Account>();
            return new Account();
        }
        return account[0];
    }

    // 対応情報取得
    private Correspond__c selectCorrespond(Id correspondId){
        List<Correspond__c> correspond = [
            SELECT
                Id
                ,Status__c        // ステータス
                ,EchoStaff__c     // 反響担当者
                ,EchoStaffName__c // 反響担当者名
                ,ShopStaff__c     // 来店担当者
                ,ShopStaffName__c // 来店担当者名
                ,EchoShop__c      // 反響担当店舗
                ,VisitShop__c     // 来店担当店舗
                ,StatusBeforePursuitHold__c //2020/6/16追加：保留前ステータス
                ,PursuitDissolveDate__c     //2020/7/13追加：追客解除設定日時（保存用）　(Modal1の送信時のメソッドで使う)
                ,AppointmentStartDate__c    //2020/7/13追加：アポイント開始日0時　(Modal1の送信時のメソッドで使う)
                ,AccountId__r.Id            //2020/7/13追加：取引先Id　(Modal1の送信時のメソッドで使う)
                ,AccountId__r.RecordTypeId  //2020/7/13追加：取引先レコードタイプId　(Modal1の送信時のメソッドで使う)
                ,systemModstamp   // 2021/1/27追加:SystemModstamp(更新前のsystemModstampを取得時に使う)
            FROM Correspond__c    // 対応
            WHERE
                Id  = :correspondId
        ];
        // レコードが取得できない場合はビジネスロジックExceptionを発行する
        if (correspond.isEmpty()) {
            correspond = new List<Correspond__c>();
            return new Correspond__c();
        }
        return correspond[0];
    }

    // 対応明細情報取得
    private CorrespondDetail__c selectCorrespondDetail(Id correspondDetailId){
        List<CorrespondDetail__c> correspondDetail = [
            SELECT
                Id
                ,Shop__c                // 店舗
                ,EchoMail__c            // 反響メール
            FROM CorrespondDetail__c    // 対応明細
            WHERE
                Id  = :correspondDetailId
        ];
        // レコードが取得できない場合はビジネスロジックExceptionを発行する
        if (correspondDetail.isEmpty()) {
            correspondDetail = new List<CorrespondDetail__c>();
            return new CorrespondDetail__c();
        }
        return correspondDetail[0];
    }

    // 定型文情報取得
    private List<FixedPhrase__c> selectFixedPhrase(){
        List<FixedPhrase__c> fixedPhrase = [
            SELECT
                Id
                ,Name       // 定型文名
                ,Folder__c  // フォルダ
                ,Subject__c // 件名
                ,Text__c    // 本文
            FROM FixedPhrase__c // 定型文
            WHERE
                Folder__c != null       // フォルダ未設定は参照しない
            AND Folder__c != ''
            AND UsageScreen__c = :CommonConst.FIXEDPHRASE_USAGESCREEN_SENDMAIL  //使用画面がメール送信画面
            ORDER BY
                Folder__c
                ,Name
        ];
        // レコードが取得できない場合はビジネスロジックExceptionを発行する
        if (fixedPhrase.isEmpty()) {
            fixedPhrase = new List<FixedPhrase__c>();
            return new List<FixedPhrase__c>();
        }
        return fixedPhrase;
    }

    // 文例情報取得
    private List<ExampleSentence__c> selectExampleSentence(){
        List<ExampleSentence__c> exampleSentence = [
            SELECT
                Id
                ,Name       // 文例名
                ,Folder__c  // フォルダ
                ,ExampleSentence__c //文例
            FROM ExampleSentence__c // 文例
            WHERE
                Folder__c != null       // フォルダ未設定は参照しない
            AND Folder__c != ''
            AND UsageScreen__c = :CommonConst.EXAMPLESENTENCE_USAGESCREEN_SENDMAIL  //使用画面がメール送信画面
            ORDER BY
                Folder__c
                ,Name
        ];
        // レコードが取得できない場合はビジネスロジックExceptionを発行する
        if (exampleSentence.isEmpty()) {
            exampleSentence = new List<ExampleSentence__c>();
            return new List<ExampleSentence__c>();
        }
        return exampleSentence;
    }

    // 反響メール情報取得
    private EchoMail__c selectEchoMail(Id echoMailId){
        List<EchoMail__c> echoMail = [
            SELECT
                Id
                ,FromPotalSite__c   // Fromポータルサイト
                ,PropertyName__c    // 物件名
                ,PropertyAddress__c // 所在地
                ,ClosestStation__c  // 最寄駅
                ,WalkTime__c        // 徒歩
                ,RoomLayout__c      // 間取り
                ,RentFee__c         // 賃料
                ,PropertURL__c      // 物件URL
                ,Subject__c         // 件名
                ,Body__c            // 本文
                ,MessageId__c       // MessageId
                ,References__c      // References
                ,PropertyCode__c    // 物件コード   // ポータルサイト構築 追加
            FROM EchoMail__c        // 反響メール
            WHERE
                Id  = :echoMailId
        ];
        // レコードが取得できない場合はビジネスロジックExceptionを発行する
        if (echoMail.isEmpty()) {
            echoMail = new List<EchoMail__c>();
            return new EchoMail__c();
        }
        return echoMail[0];
    }

    // メール下書き情報取得
    private MailDraft__c selectMailDraft(Id mailDraftId){
        List<MailDraft__c> mailDraft = [
            SELECT
                Id
                ,Name                   // 名称
                ,From__c                // 送信者
                ,To__c                  // 宛先
                ,Cc__c                  // CC
                ,Subject__c             // 件名
                ,Body__c                // メール内容
                ,Shop__c                // 店舗
                ,Account__c             // 取引先
                ,Account__r.Name        // 取引先名
                ,SendingDateTime__c     // 送信予定日時
                ,Correspond__c          // 対応
                ,CorrespondDetail__c    // 対応明細
                ,IsReply__c             // 返信フラグ
				,IsLineIntroduction__c  // 2021.12.3 LINE連携対応より、LINE紹介フラグを追加
            FROM MailDraft__c           // メール下書き
            WHERE
                Id  = :mailDraftId
        ];
        // レコードが取得できない場合はビジネスロジックExceptionを発行する
        if (mailDraft.isEmpty()) {
            mailDraft = new List<MailDraft__c>();
            return new MailDraft__c();
        }
        return mailDraft[0];
    }

    // メール時間指定送信情報取得
    private MailTimeSpecificationSending__c selectMailTimeSpecificationSending(Id mailTimeSpecificationSendingId){
        List<MailTimeSpecificationSending__c> mailTimeSpecificationSending = [
            SELECT
                Id
                ,Name                   // 名称
                ,From__c                // 送信者
                ,To__c                  // 宛先
                ,Cc__c                  // CC
                ,Subject__c             // 件名
                ,Body__c                // メール内容
                ,Shop__c                // 店舗
                ,Account__c             // 取引先
                ,Account__r.Name        // 取引先名
                ,SendingDateTime__c     // 送信予定日時
                ,Correspond__c          // 対応
                ,CorrespondDetail__c    // 対応明細
                ,IsReply__c             // 返信フラグ
				,IsLineIntroduction__c  // 2021.12.3 LINE連携対応より、LINE紹介フラグを追加
            FROM MailTimeSpecificationSending__c    // メール時間指定送信
            WHERE
                Id  = :mailTimeSpecificationSendingId
        ];
        // レコードが取得できない場合はビジネスロジックExceptionを発行する
        if (mailTimeSpecificationSending.isEmpty()) {
            mailTimeSpecificationSending = new List<MailTimeSpecificationSending__c>();
            return new MailTimeSpecificationSending__c();
        }
        return mailTimeSpecificationSending[0];
    }

    // 添付ファイルレコード情報取得
    private List<Attachment> selectAttachment(Id targetId){
        this.attachmentTotalSize    = 0;
        List<Attachment> attachmentList = [
            SELECT
                Id
                ,ParentId           // 参照先Id（メール下書きId、メール時間指定送信Id）
                ,Name               // ファイル名
                ,LastModifiedDate   // 最終更新日
                ,BodyLength         // 内容の長さ
                ,ContentType        // コンテンツタイプ
            FROM Attachment         // 添付ファイル
            WHERE
                ParentId    = :targetId
        ];
        if (attachmentList.isEmpty()) {
            attachmentList = new List<Attachment>();
        }
        for (Attachment att : attachmentList) {
            this.attachmentTotalSize += att.BodyLength;
        }
        return attachmentList;
    }

    // ポータルサイト構築 追加 Start
    // お気に入り物件の取得
    private List<FavoriteProperty__c> selectFavoriteProperty(Id accountId){
        List<FavoriteProperty__c> favoriteList =[SELECT id,                                             // お気に入り物件ID
                                                        Property__c,                                    // 物件ID
                                                        Property__r.PropertyCode__c,                    // 物件コード
                                                        Property__r.Name,                               // 物件名
                                                        Property__r.Building__c,                        // 建物ID
                                                        Property__r.Building__r.Name,                   // 建物名
                                                        Property__r.Building__r.Address__c,             // 建物住所
                                                        Account__c ,                                    // 取引先ID
                                                        Property__r.Building__r.TrainRoute1__r.name,    // 沿線１名
                                                        Property__r.Building__r.Station1__r.name,       // 駅１名
                                                        Property__r.Building__r.City__c,                // 建物.住所１（市区町村）
                                                        Property__r.Building__r.StationWalkTime1__c     // 建物.駅までの時間（分）１
                                                FROM FavoriteProperty__c
                                                WHERE Account__c = :accountId
                                                ORDER BY Property__r.Building__r.BuildingAge__c  DESC     // 建物．築年数（降順）
                                                ,        Property__r.Building__r.Name                     // 建物．建物名（昇順）
                                                ,        Property__r.Name                                 // 物件．物件名（昇順）
                                                LIMIT :INDEX_LIMIT];
        if(favoriteList.isEmpty()){
            favoriteList = new List<FavoriteProperty__c>();
        }    
        return favoriteList;  
    }

    // ポータルサイト掲載物件取得（物件IDから取得）
    private List<PortalSitePostingProperty__c> selectPortalSitePostingProperty(List<id> propertyIdList){
        List<PortalSitePostingProperty__c> portalSitePostingPropertyList = [SELECT id,                                             // ID
                                                                                    Property__c,                                   // 物件ID
                                                                                    IsPortal__c                                    // 自社ポータル
                                                                            FROM PortalSitePostingProperty__c
                                                                            WHERE Property__c in :propertyIdList];
        if(portalSitePostingPropertyList.isEmpty()){
            portalSitePostingPropertyList = new List<PortalSitePostingProperty__c>();
        }    
        return portalSitePostingPropertyList;

    }
    // ポータルサイト構築 追加 End


    // 添付ファイル一時レコード削除（不要なレコードが残ってしまっていた場合の念のための削除）
    public static void deleteTempMailDraft(){
        DateTime nowTime = CommonUtil.getNow();
        nowTime = nowTime.addMinutes(-5);
        List<MailDraft__c> tempMailDraft = [
            SELECT
                Id
            FROM MailDraft__c   // メール下書き
            WHERE
                Name            = 'Temporary of Attachment'
            AND SystemModStamp  < :nowTime  // 作成されて5分以上経過
            AND Account__c      = null
        ];
        if (tempMailDraft.size() > 0) {
            SecureDML.secureDelete(tempMailDraft);
        }
    }

    // リダイレクトURL番号の利用状況取得
    private Boolean existsRedirectUrlNo(String targetNo){
        List<RedirectUrlNoHistory__c> urlNo = [
            SELECT
                Id
            FROM RedirectUrlNoHistory__c    // リダイレクトURL番号履歴
            WHERE
                Name    = :targetNo
        ];
        return urlNo.size() > 0;
    }

    // リダイレクトURLパラメータの削除（生成後１日以上経過しているレコード）
    private void deleteRedirectUrlParameter() {
        DateTime targetDateTime = CommonUtil.getNow();
        targetDateTime = targetDateTime.addDays(-1);
        List<RedirectUrlParameter__c> urlParam = [
            SELECT
                Id
            FROM RedirectUrlParameter__c    // リダイレクトURLパラメータ
            WHERE
                CreatedDate < :targetDateTime
        ];
        if (urlParam.size() > 0) {
            SecureDML.secureDelete(urlParam);
        }
    }

    // 画面表示用クラス
    public class ScreenMailInfo {
        public String propertyURL       { get; set; }   // 物件URL
        public String propertyDetail    { get; set; }   // 物件詳細
        public Date sendingDate         { get; set; }   // 送信予定日
        public String sendingTime       { get; set; }   // 送信予定時刻
        public String sendingDateTime   { get; set; }   // 送信予定日時（アラート表示用）
        public String sendFrom          { get; set; }   // 送信者名
        public String sendFromMail      { get; set; }   // 送信者メールアドレス
        public String sendToName        { get; set; }   // 宛先名
        public List<CheckText> sendTo   { get; set; }   // 宛先
        public List<CheckText> cc       { get; set; }   // CC

        public String subject           { get; set; }   // 件名
        public String body              { get; set; }   // 本文
        public String attachmentFileNames   { get; set; }   // 添付ファイル名（全体）
		// ▼ 2021.12.3 LINE連携対応より、LINEともだち紹介を追加
		public Boolean isLineFriendIntroduction {get; set;}
		// ▲ 2021.12.3

        // コンストラクタ
        public ScreenMailInfo() {
            this.init();
        }
        // コンストラクタ
        public ScreenMailInfo(Account account, Shop__c shop) {
            this.init();
            this.setAccountInfo(account, true);
            this.sendFrom       = Shop.Name;
            this.sendFromMail   = Shop.Email__c;
        }
        // コンストラクタ（反響メール）
        public ScreenMailInfo(Account account, Shop__c shop, EchoMail__c echoMail) {
            this.init();
            this.setAccountInfo(account, true);
            this.sendFrom       = Shop.Name;
            this.sendFromMail   = Shop.Email__c;
            this.subject = 'Re:' + echoMail.Subject__c;
            String tempBody = echoMail.Body__c;
            if (String.isNotEmpty(tempBody)) {
                // 改行を\nに統一
                tempBody = tempBody.replace('\r\n', '\n');
                tempBody = tempBody.replace('\r'  , '\n');
                // 改行単位で分割し行毎の先頭に「> 」を付加
                List<String> tempRowList = tempBody.split('\n');
                for (String row : tempRowList) {
                    this.body += '> ' + row + '\n';
                }
            }
        }
        // コンストラクタ（メール下書き）
        public ScreenMailInfo(Account account, Shop__c shop, MailDraft__c mailDraft) {
            this.init();
            this.setAccountInfo(account, false);
            this.sendFrom       = Shop.Name;
            this.sendFromMail   = Shop.Email__c;
            if (mailDraft.SendingDateTime__c != null) {
                this.sendingDate    = mailDraft.SendingDateTime__c.Date();
                this.sendingTime    = mailDraft.SendingDateTime__c.format('HH');
            }
            this.subject        = mailDraft.Subject__c;
            this.body           = mailDraft.Body__c;
			// ▼ 2021.12.3 LINE連携対応より、LINEともだち紹介を追加
			this.isLineFriendIntroduction = mailDraft.IsLineIntroduction__c;
			// ▲ 2021.12.3

            // 宛先選択
            if (String.isNotEmpty(mailDraft.To__c)) {
                List<String> tempList = mailDraft.To__c.split(';');
                for (String mail : tempList) {
                    this.setSendToChecked(mail, true);
                }
            }
            // CC選択
            if (String.isNotEmpty(mailDraft.Cc__c)) {
                List<String> tempList = mailDraft.Cc__c.split(';');
                for (String mail : tempList) {
                    this.setCcChecked(mail, true);
                }
            }
        }
        // コンストラクタ（メール時間指定送信）
        public ScreenMailInfo(Account account, Shop__c shop, MailTimeSpecificationSending__c mailTimeSpecificationSending) {
            this.init();
            this.setAccountInfo(account, false);
            this.sendFrom       = Shop.Name;
            this.sendFromMail   = Shop.Email__c;
            if (mailTimeSpecificationSending.SendingDateTime__c != null) {
                this.sendingDate    = mailTimeSpecificationSending.SendingDateTime__c.Date();
                this.sendingTime    = mailTimeSpecificationSending.SendingDateTime__c.format('HH');
                this.sendingDateTime = mailTimeSpecificationSending.SendingDateTime__c.format('yyyy/MM/dd HH:00');
            }
            this.subject        = mailTimeSpecificationSending.Subject__c;
            this.body           = mailTimeSpecificationSending.Body__c;
			// ▼ 2021.12.3 LINE連携対応より、LINEともだち紹介を追加
			this.isLineFriendIntroduction = mailTimeSpecificationSending.IsLineIntroduction__c;
			// ▲ 2021.12.3

            // 宛先選択
            if (String.isNotEmpty(mailTimeSpecificationSending.To__c)) {
                List<String> tempList = mailTimeSpecificationSending.To__c.split(';');
                for (String mail : tempList) {
                    this.setSendToChecked(mail, true);
                }
            }
            // CC選択
            if (String.isNotEmpty(mailTimeSpecificationSending.Cc__c)) {
                List<String> tempList = mailTimeSpecificationSending.Cc__c.split(';');
                for (String mail : tempList) {
                    this.setCcChecked(mail, true);
                }
            }
        }
        // 初期化
        private void init() {
            this.propertyURL = '';
            this.propertyDetail = '';
            this.sendingDate = null;
            this.sendingTime = '';
            this.sendingDateTime = '';
            this.sendFrom = '';
            this.sendFromMail = '';
            this.sendTo = new List<CheckText>();
            this.cc     = new List<CheckText>();
            this.subject = '';
            this.body = '';
            this.attachmentFileNames = '';
			// ▼ 2021.12.3 LINE連携対応より、LINEともだち紹介を追加
			this.isLineFriendIntroduction = false;
			// ▲ 2021.12.3
        }
        // 取引先（送信先）の情報設定
        private void setAccountInfo(Account account, Boolean init) {
            this.sendToName = account.Name;
            this.sendTo = new List<CheckText>();
            this.cc     = new List<CheckText>();
            if (String.isNotEmpty(account.Email__c)) {
                this.sendTo.add(new CheckText(account.Email__c , '１：' + account.Email__c , init));
            }
            if (String.isNotEmpty(account.Email2__c)) {
                this.sendTo.add(new CheckText(account.Email2__c, '２：' + account.Email2__c));
                this.cc.add(    new CheckText(account.Email2__c, '２：' + account.Email2__c));
            }
            if (String.isNotEmpty(account.Email3__c)) {
                this.sendTo.add(new CheckText(account.Email3__c, '３：' + account.Email3__c));
                this.cc.add(    new CheckText(account.Email3__c, '３：' + account.Email3__c));
            }
        }
        // 送信先選択変更
        public void setSendToChecked(String value, Boolean isCheck) {
            for (Integer i = 0; i < this.sendTo.size(); i++) {
                if (this.sendTo[i].value == value) {
                    this.sendTo[i].isCheck = isCheck;
                }
            } 
        }
        // CC選択変更
        public void setCcChecked(String value, Boolean isCheck) {
            for (Integer i = 0; i < this.Cc.size(); i++) {
                if (this.Cc[i].value == value) {
                    this.Cc[i].isCheck = isCheck;
                }
            } 
        }
        // 送信先選択変更
        public void clearSendToChecked() {
            for (Integer i = 0; i < this.sendTo.size(); i++) {
                this.sendTo[i].isCheck = false;
            } 
        }
    }
    public class CheckText {
        public Boolean isCheck  { get; set; }   // チェック状態
        public String value     { get; set; }   // 値
        public String label     { get; set; }   // 表示名
        public CheckText() {
            this.isCheck = false;
            this.value = '';
            this.label = '';
        }
        public CheckText(String value, String label) {
            this.isCheck = false;
            this.value = value;
            this.label = label;
        }
        public CheckText(String value, String label, Boolean isCheck) {
            this.isCheck = isCheck;
            this.value = value;
            this.label = label;
        }
    }

	// ▼ 2021.12.3 LINE連携対応より、ユーザヘッダ部の追加
	/**
	 * ユーザヘッダ部クラス
	 */
	public class ScreenUserHead {

		/** 項目 */
		public String accountName	{get; set;} // 取引先名
		public String lineName		{get; set;} // LINE名

		/**
		 * コンストラクタ
		 * @param LineMember__c	lineMember  LINE会員
		 * @param String		accountName 取引先名
		 */
		public screenUserHead(LineMember__c lineMember, String accountName) {
			this.accountName	= accountName;
			this.lineName		= lineMember.Name;
		}
	}
	// ▲ 2021.12.3

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

    // 画面表示用クラス（文例）
    public class ScreenExampleSentence {
        public List<String> folder { get; set; } // フォルダ
        public Map<String, List<ExampleSentence__c>> exampleSentenceMap { get; set; }   // 文例名
        // コンストラクタ
        public ScreenExampleSentence() {
            // 初期化
            this.folder = new List<String>();
            this.exampleSentenceMap = new Map<String, List<ExampleSentence__c>>();
        }
        // コンストラクタ
        public ScreenExampleSentence(List<ExampleSentence__c> exampleSentenceList) {
            // 初期化
            this.folder = new List<String>();
            this.exampleSentenceMap = new Map<String, List<ExampleSentence__c>>();

            // フォルダ名をキーとした文例レコードのMapを作成
            for (ExampleSentence__c record : exampleSentenceList) {
                List<ExampleSentence__c> temp = new List<ExampleSentence__c>();
                record.ExampleSentence__c = record.ExampleSentence__c.replace('\n','<br>');
                if (this.exampleSentenceMap.containsKey(record.Folder__c)) {
                    temp = this.exampleSentenceMap.get(record.Folder__c);
                } else {
                    this.folder.add(record.Folder__c);
                }
                temp.add(record);
                this.exampleSentenceMap.put(record.Folder__c, temp);
            }

        }

    }    

    // ポータルサイト構築 追加 Start
    // 画面表示用クラス（お気に入り物件）
    public class screenFavoriteProperty{
        public Id portalFavoritePropertyId      { get; set; }   // お気に入り物件ID
        public Id propertyId                    { get; set; }   // 物件ID
        public string propertyCode              { get; set; }   // 物件コード
        public Id buildingId                    { get; set; }   // 建物ID
        public Id accountId                     { get; set; }   // 取引先ID
        public String buildingTrainRoute1Name   { get; set; }   // 沿線１名
        public String buildingStation1Name      { get; set; }   // 駅１名
        
        public Boolean isSelected               { get; set; }   // チェック
        public String buildingName              { get; set; }   // 建物名
        public String propertyName              { get; set; }   // 物件名
        public String buildingCity              { get; set; }   // 建物.住所１（市区町村）

        public String buildingStationWalkTime1  { get; set; }   // 建物.駅までの時間（分）１

        public String propertyDetail            { get; set; }   // 物件詳細
        public String propertyURL               { get; set; }   // 物件URL

        public Boolean isPortalFlg              { get; set; }   // ポータルサイト掲載物件自社ポータルフラグ

        // コンストラクタ
        public screenFavoriteProperty() {
            // 初期化
            this.init();
        }

        public screenFavoriteProperty(FavoriteProperty__c favoriteProperty ,String portalSiteUrl) {
            // 初期化
            this.init();
            this.portalFavoritePropertyId   = favoriteProperty.Id ;                                             // お気に入り物件ID
            this.propertyId                 = favoriteProperty.Property__c ;                                    // 物件ID
            this.buildingId                 = favoriteProperty.Property__r.Building__c ;                        // 建物ID
            this.accountId                  = favoriteProperty.Account__c ;                                     // 取引先ID
            this.buildingTrainRoute1Name    = favoriteProperty.Property__r.Building__r.TrainRoute1__r.name;     // 沿線１名
            this.buildingStation1Name       = favoriteProperty.Property__r.Building__r.Station1__r.name;        // 駅１名
            
            this.buildingName               = favoriteProperty.Property__r.Building__r.Name ;                   // 建物名
            this.propertyName               = favoriteProperty.Property__r.Name ;                               // 物件名
            this.buildingCity               = favoriteProperty.Property__r.Building__r.City__c;                 // 建物.住所１（市区町村）
    
            this.buildingStationWalkTime1   = (favoriteProperty.Property__r.Building__r.StationWalkTime1__c == null )  ? '' : CommonUtil.decimalToString(favoriteProperty.Property__r.Building__r.StationWalkTime1__c) ;   // 建物.駅までの時間（分）１

            // 建物.建物名 & "　" & 物件.部屋番号 & "　" & 建物.住所１（市区町村） & "　" & 建物.沿線１ & "　" & 建物.駅１ & "　徒歩" & 建物.駅までの時間（分）１
            this.propertyDetail = this.buildingName 
                                + setPropertyDetail(this.propertyName,'　','') 
                                + setPropertyDetail(this.buildingCity,'　','') 
                                + setPropertyDetail(this.buildingTrainRoute1Name,'　','') 
                                + setPropertyDetail(this.buildingStation1Name,'　','') 
                                + setPropertyDetail(this.buildingStationWalkTime1,'　徒歩約','分');             // 物件詳細

            
            this.propertyURL = portalSiteUrl + '?cd=' + favoriteProperty.Property__r.PropertyCode__c;         // ポータルサイトURL

        }

        // 物件詳細の形を生成（nullかどうかで設定内容を置き換える）
        private String setPropertyDetail(String convertCharacters, String addCharactersForward, String addCharactersBackward){
            if (String.isEmpty(convertCharacters)){
                return '';
            }
            return addCharactersForward + convertCharacters + addCharactersBackward;
        }

        // 初期化
        private void init(){
            this.portalFavoritePropertyId   = null;     // お気に入り物件ID
            this.propertyId                 = null;     // 物件ID
            this.buildingId                 = null;     // 建物ID
            this.accountId                  = null;     // 取引先ID
            this.buildingTrainRoute1Name    = '';       // 沿線１名
            this.buildingStation1Name       = '';       // 駅１名
            this.isSelected                 = false;    // チェック
            this.buildingName               = '';       // 建物名
            this.propertyName               = '';       // 物件名
            this.buildingCity               = '';       // 建物.住所１（市区町村）
            this.buildingStationWalkTime1   = null;     // 建物.駅までの時間（分）１
            this.propertyDetail             = '';       // 物件詳細
            this.propertyURL                = '';       // 物件URL
            this.isPortalFlg                = false;    // ポータルサイト掲載物件自社ポータルフラグ
        }
    }
    // ポータルサイト構築 追加 End


}