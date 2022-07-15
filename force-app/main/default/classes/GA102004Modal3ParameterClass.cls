//メール送信画面 の 文例集選択モーダルパラメータ
public class GA102004Modal3ParameterClass {

    /** 文例集情報 */
    public GA102004Controller.ScreenExampleSentence exampleSentence { get; set; }

    /** 初回描画フラグ */
    public Boolean isDrawing { get; set;}

    /** 描画実施済みフラグ */
    public Boolean noFirst { get; set; }

    public GA102004Modal3ParameterClass() {
        // 初期化処理
        this.exampleSentence = new GA102004Controller.ScreenExampleSentence();
        this.isDrawing      = false;
        this.noFirst        = false;
    }
}