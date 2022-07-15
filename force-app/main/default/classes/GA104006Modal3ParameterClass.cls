//物件登録画面のおすすめ物件登録モーダル パラメータクラス
public class GA104006Modal3ParameterClass {
    /** おすすめ物件Id */
    public Id Id { get; set; }

    /** 建物Id */
    public Id buildingId { get; set; }

    /** 物件Id */
    public Id propertyId { get; set; }

    /** 物件コード */
    public String propertyCode { get; set; }


    /** おすすめ物件 */
    public RecommendProperty__c recoPro { get; set; }

    /** DB更新フラグ 　　物件登録からの際は登録ボタンではDB更新せず、おすすめ物件一覧画面からの際はDB更新*/
    public Boolean IsUpsertDB { get; set; }

    //再販対応 追加 Start
    /** おすすめ物件 */
    public Boolean isUseAuthorityPanoramaTour { get; set; }

    //再販対応 追加 End

    /** 初回描画フラグ */
    public Boolean isDrawing { get; set;}
    
    /** 描画実施済みフラグ */
    public Boolean noFirst { get; set; }

    public GA104006Modal3ParameterClass() {
        // 初期化処理
        Id = null;
        buildingId = null;
        recoPro = new RecommendProperty__c(); //問合せNo0440で変更
        propertyCode = '';
        propertyId = null;
        IsUpsertDB = false;
        isDrawing = false;
        noFirst = false;
        isUseAuthorityPanoramaTour = false;
    }
}