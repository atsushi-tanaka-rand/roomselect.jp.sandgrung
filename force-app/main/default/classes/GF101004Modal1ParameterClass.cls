//保証会社プラン登録画面　の　商品明細用モーダル　パラメータクラス
public class GF101004Modal1ParameterClass {
    /** 商品明細 */
    public ItemDetail__c targetItemDetail { get; set; }
    
    /** 初回描画フラグ */
    public Boolean isDrawing{ get; set;}
    
    /** 描画実施済みフラグ */
    public Boolean noFirst{ get; set;}
    
    
    public GF101004Modal1ParameterClass() {
        // 初期化処理
        targetItemDetail = new ItemDetail__c();      
        isDrawing = false;
        noFirst = false;
    }
}