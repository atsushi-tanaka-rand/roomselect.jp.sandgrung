//火災保険プラン登録モーダルパラメータクラス
public class GF801004ParameterClass {
    /** 商品明細 */
    public Item__c targetItem { get; set; }
    
    /** 初回描画フラグ */
    public Boolean isDrawing{ get; set;}
    
    /** 描画実施済みフラグ */
    public Boolean noFirst{ get; set;}
    
    //火災保険会社名
    public String companyName{ get; set;}
    
    public GF801004ParameterClass() {
        // 初期化処理
        targetItem = new Item__c();      
        isDrawing = false;
        noFirst = false;
    }
    

}