public class GA102004Modal2ParameterClass {
    /** 定型文情報 */
    public GA102004Controller.ScreenFixedPhrase fixedPhrase { get; set; }

    /** 選択定型文フォルダ */
    public String selectFolder { get; set; }

    /** 選択定型文インデックス */
    public Integer selectIndex { get; set; }

    /** 初回描画フラグ */
    public Boolean isDrawing { get; set;}

    /** 描画実施済みフラグ */
    public Boolean noFirst { get; set; }

    public GA102004Modal2ParameterClass() {
        // 初期化処理
        this.fixedPhrase = new GA102004Controller.ScreenFixedPhrase();
        this.selectFolder   = '';
        this.selectIndex    = null;
        this.isDrawing      = false;
        this.noFirst        = false;
    }
}