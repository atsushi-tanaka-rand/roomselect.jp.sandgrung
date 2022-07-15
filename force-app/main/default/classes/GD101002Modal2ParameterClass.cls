/**
 * 業者プラン一括変更画面のパラメータクラス
 */
public with sharing class GD101002Modal2ParameterClass {
    
    /**
     * 画面種別
     */
    public enum DispKind {
        guaranteeidCorp     // 保証会社
        , fireInsuranceCorp // 火災保険会社
        , manaCorpItem      // 管理会社指定商品
    }

    /** パラメータ */
    public Id        accountId       { get; set;} // 取引先.Id
    public String    accountName     { get; set;} // 取引先.取引先名
    public String    chgOriginalId   { get; set;} // 変更元Id
    public String    chgOriginalName { get; set;} // 変更元名
    public DispKind  openDispKind    { get; set;} // 画面種別
    public Boolean   isDrawing       { get; set;} // 初回描画フラグ
    public Boolean   noFirst         { get; set;} // 描画実施済みフラグ

    /**
     * コンストラクタ
     */
    public GD101002Modal2ParameterClass() {

        // 初期化処理
        this.accountId       = null;                     // 取引先.Id
        this.accountName     = CommonConst.STRING_EMPTY; // 取引先.取引先名
        this.chgOriginalId   = CommonConst.STRING_EMPTY; // 変更元Id
        this.chgOriginalName = CommonConst.STRING_EMPTY; // 変更元名
        this.openDispKind    = null;                     // 画面種別
        this.isDrawing       = false;                    // 初回描画フラグ
        this.noFirst         = false;                    // 描画実施済みフラグ
    }
}