//メール送信画面の確認モーダル パラメータクラス
public class GA102004Modal1ParameterClass {
    /** メール情報 */
    public GA102004Controller.ScreenMailInfo mailInfo { get; set; }

    /** 店舗Id */
    public Id shopId { get; set; }

    /** 取引先Id */
    public Id accountId { get; set; }

    /** 取引先 */
    public Account account { get; set; }

    /** メール下書きId */
    public Id mailDraftId { get; set; }

    /** メール時間指定送信Id */
    public Id mailTimeSpecificationSendingId { get; set; }

    /** 対応Id */
    public Id correspondId { get; set; }

    /** 対応 */
    public Correspond__c correspond { get; set; }

    /** 対応明細Id */
    public Id correspondDetailId { get; set; }

    /** 返信フラグ */
    public Boolean isReply { get; set; }

    /** MessageId */
    public String messageId { get; set; }

    /** References */
    public String references { get; set; }

    /** 初回描画フラグ */
    public Boolean isDrawing { get; set;}

    /** 描画実施済みフラグ */
    public Boolean noFirst { get; set; }

    //対応オブジェクトの更新日付
    public dateTime compareToTime = null;

    public GA102004Modal1ParameterClass() {
        // 初期化処理
        this.mailInfo           = new GA102004Controller.ScreenMailInfo();
        this.shopId             = null;
        this.accountId          = null;
        this.account            = new Account();
        this.mailDraftId        = null;
        this.mailTimeSpecificationSendingId = null;
        this.correspondId       = null;
        this.correspond         = new Correspond__c();
        this.correspondDetailId = null;
        this.isReply            = false;
        this.messageId          = '';
        this.references         = '';
        this.isDrawing          = false;
        this.noFirst            = false;
        this.compareTotime      = null;
    }

}