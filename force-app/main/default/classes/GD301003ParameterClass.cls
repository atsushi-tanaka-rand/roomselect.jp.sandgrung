/**
 * 業者選択のパラメータクラス
 */
public with sharing class GD301003ParameterClass {
    
    /** 初回描画フラグ */
    public Boolean isDrawing{ get; set;}
    
    /** 描画実施済みフラグ */
    public Boolean noFirst{ get; set;}
    
    
    public SupplierConst supplierType{ get; set;} //列挙型(業者)
    
    
    public Account accountRecord{ get; set;}     //返却される取引先
    
							

    //コンストラクタ
    public GD301003ParameterClass() {
        
        // フラグ初期化処理
        isDrawing = false;
        noFirst = false;
        
        // 初期化処理
        accountRecord = new Account();
        
    }
    
    //************************************************************************

    //列挙型(業者)
    public enum SupplierConst {
        FORMER_SUPPLIER   //元付業者
        ,CREDITOR//貸主
        ,OWNER//所有者
    }
    
}