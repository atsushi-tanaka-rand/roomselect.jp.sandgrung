//物件登録画面の文例選択モーダル パラメータクラス
public class GA104006Modal2ParameterClass {
    /** 文例Id */
    public Id Id { get; set; }

    /** 文例 */
    public String exampleSentence { get; set; }

    /** 返却項目名 */
    public String returnItem { get; set; }

    /** 返却項目最大長 */
    public Integer returnItemMaxLength { get; set; }

    /** 初回描画フラグ */
    public Boolean isDrawing { get; set;}
    
    /** 描画実施済みフラグ */
    public Boolean noFirst { get; set; }

    public GA104006Modal2ParameterClass() {
        // 初期化処理
        Id = null;
        exampleSentence = '';
        returnItem = '';
        returnItemMaxLength = 0;
        isDrawing = false;
        noFirst = false;
    }
}