//メール送信画面 の 定型文選択モーダル
public class GA102004Modal2Controller {

    // パラメータ
    public GA102004Modal2ParameterClass parameter { get; set; }

    // エラー処理関連
    public Boolean isOpenError { get; set; }
    public Boolean hasErrorMessage { get; set; }

    // 定型文情報
    public GA102004Controller.ScreenFixedPhrase screenFixedPhrase { get; set; }

    // 選択情報
    public String selectFixedPhraseFolder { get; set; } // 選択定型文フォルダ
    public Integer selectFixedPhraseIndex { get; set; } // 選択定型文インデックス

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
    public GA102004Modal2Controller() {
    }

    // ページの初期表示の具体的な処理
    public void initAction(){
        try{
            // 初期化
            this.isOpenError = false;
            this.hasErrorMessage = false;

            // パラメータから画面項目を設定
            this.screenFixedPhrase = this.parameter.fixedPhrase.clone();

        } catch (Exception e) {
            this.isOpenError = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // 定型文選択処理
    public void clickFixedPhrase() {
        try {
            this.hasErrorMessage = false;

            // 選択情報をパラメータへ設定
            this.parameter.selectFolder = this.selectFixedPhraseFolder;
            this.parameter.selectIndex = this.selectFixedPhraseIndex;

        } catch(Exception e) {
            // エラー設定
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

}