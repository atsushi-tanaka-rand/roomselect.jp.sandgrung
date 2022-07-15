// 物件登録画面 の 物件メンテナンス履歴モーダル
public with sharing class GA104006Modal4Controller {

    public GA104006Modal4ParameterClass parameter { get; set; } // パラメータ

    /** ページの初期表示処理実行用 */
    public Boolean init {
        get {
            if (this.parameter.isDrawing) {
                this.parameter.isDrawing = false;
                return false;
            }
            return true;
        }
    }
}