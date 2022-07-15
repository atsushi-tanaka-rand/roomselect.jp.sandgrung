// 条件完全一致物件
public with sharing class GA102001Modal8ParameterClass {
    /** 初回描画フラグ */
    public Boolean isDrawing{ get; set;}
    
    /** 描画実施済みフラグ */
    public Boolean noFirst{ get; set;}

    /** 条件完全一致物件ID */
    public String ExactConditionMatchPropertyId { get;set; }

    public GA102001Modal8ParameterClass() {
        // 初期化処理
        isDrawing = false;
        noFirst = false;
    }
}