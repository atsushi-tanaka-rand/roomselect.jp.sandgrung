/**
 * 管理会社指定商品のパラメータクラス
 */
public with sharing class GD101002Modal1ParameterClass {
    
    /** 初回描画フラグ */
    public Boolean isDrawing{ get; set;}
    
    /** 描画実施済みフラグ */
    public Boolean noFirst{ get; set;}

    public ManagementCompanyItem__c paramMCIRecird{ get; set;}    //返却される商品List
							

    //コンストラクタ
    public GD101002Modal1ParameterClass() {
        
        // フラグ初期化処理
        isDrawing = false;
        noFirst = false;
        
        // 初期化処理
        paramMCIRecird = new ManagementCompanyItem__c();
        
    }
}