public with sharing class GA101002Modal1ParameterClass {
    
    /** 選択済み店舗のID */
    public List<String> selectedShopListId { get; set; }

    /** 店舗Id */
    public List<SelectOption> selectedShopList { get; set; }

    /** 選択リスト絞り込み条件 */
    public String selectchooseableList { get; set; }
        
    /** 初回描画フラグ */
    public Boolean isDrawing{ get; set;}
    
    /** 描画実施済みフラグ */
    public Boolean noFirst{ get; set;}

    /** 店舗区分（False:インサイドセール、True:インサイドセール以外） */
    public Boolean isShopType { get;set; }                              
    
    public GA101002Modal1ParameterClass() {
        // 初期化処理
        // selectedShopList = new  List<String>();        
        selectedShopListId = new  List<String>(); 
        selectedShopList = new list<SelectOption>();       
        isDrawing = false;
        noFirst = false;
    }
}