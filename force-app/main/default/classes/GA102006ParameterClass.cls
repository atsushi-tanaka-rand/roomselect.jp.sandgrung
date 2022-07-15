public with sharing class GA102006ParameterClass {
    
    /** 初回描画フラグ */
    public Boolean isDrawing{ get; set;}
    
    /** 描画実施済みフラグ */
    public Boolean noFirst{ get; set;}


    public Boolean isAddressMoster{ get; set;}  /** 住所マスタフラグ */
    public String postalCode{ get; set;}  /** 郵便番号 */     
    public String state{ get; set;}    /** 都道府県 */       
    public String city{ get; set;}    /** 市区町村 */  
    public String street{ get; set;}    /** 町域 */               
    public String aza{ get; set;}     /** 字 */
    public String choazaCodeNew{ get; set;}    /** 町字コード */
    public String obsoleteYM{ get; set;} //廃止年月
        
    public GA102006ParameterClass() {
        // 初期化処理     
        isDrawing = false;
        noFirst = false;
    }
 
}