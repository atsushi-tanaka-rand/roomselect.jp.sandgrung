//申込登録（ipad）の入居者モーダル画面パラメータクラス
public class GA103001Modal1ParameterClass {
    /** 入居者レコード */
    public Tenant__c tenantRecord { get; set; }

    /** 初回描画フラグ */
    public Boolean isDrawing{ get; set;}
    
    /** 描画実施済みフラグ */
    public Boolean noFirst{ get; set;}

    //申込日パラメータ（年齢計算用）
    public Date applicationDate{ get; set; }
    
    
    public GA103001Modal1ParameterClass() {
        // 初期化処理
        tenantRecord = new Tenant__c();      
        isDrawing = false;
        noFirst = false;
    }
}