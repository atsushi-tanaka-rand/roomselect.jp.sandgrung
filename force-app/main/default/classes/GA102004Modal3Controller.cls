//メール送信画面 の 文例集選択モーダル
public class GA102004Modal3Controller {

    // パラメータ
    public GA102004Modal3ParameterClass parameter { get; set; }

    // エラー処理関連
    public Boolean isOpenError { get; set; }
    public Boolean hasErrorMessage { get; set; }

    // 文例集情報
    public GA102004Controller.ScreenExampleSentence screenExampleSentence { get; set; }

    // 選択情報
    public String selectExampleSentenceText { get; set; }   // 選択文例テキスト

    // ページの初期表示処理実行用
    public Boolean init {
        get {
            if (this.parameter.isDrawing) {
                initAction();
                this.parameter.isDrawing = false;
                return false;
            }
            return true;
        }
    }

    // コンストラクタ
    public GA102004Modal3Controller() {
    }

    // ページの初期表示の具体的な処理
    public void initAction(){
        try{
            // 初期化
            this.isOpenError = false;
            this.hasErrorMessage = false;

            // パラメータから画面項目を設定
            this.screenExampleSentence = this.parameter.exampleSentence.clone();

        } catch (Exception e) {
            this.isOpenError = true;
            CommonUtil.setErrorMessage(e);
        }
    }
}