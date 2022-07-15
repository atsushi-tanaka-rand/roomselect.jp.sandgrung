//付帯商品登録やけど今は保証プランの内容はっ付けただけのモーダル画面のパラメータクラス
public class GF201002ParameterClass {
    /** 商品明細 */
    public Item__c targetItem { get; set; }
    
    /** 初回描画フラグ */
    public Boolean isDrawing{ get; set;}
    
    /** 描画実施済みフラグ */
    public Boolean noFirst{ get; set;}
    
    //業者名
    public String auxiliaryCompanyName{ get; set;}
    
    public GF201002ParameterClass() {
        // 初期化処理
        targetItem = new Item__c();      
        isDrawing = false;
        noFirst = false;
    }
}