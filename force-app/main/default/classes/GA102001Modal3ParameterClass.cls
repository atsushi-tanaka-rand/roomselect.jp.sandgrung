public with sharing class GA102001Modal3ParameterClass {
    /** 初回描画フラグ */
    public Boolean isDrawing{ get; set;}
    
    /** 描画実施済みフラグ */
    public Boolean noFirst{ get; set;}


    /** お気に入り物件ID */
    public String FavoritePropertyId { get;set; }

    public GA102001Modal3ParameterClass() {
        // 初期化処理
        isDrawing = false;
        noFirst = false;
    }
}