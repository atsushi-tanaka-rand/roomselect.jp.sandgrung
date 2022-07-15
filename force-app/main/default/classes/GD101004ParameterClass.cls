/**
 * 火災保険会社選択のパラメータクラス
 */
public with sharing class GD101004ParameterClass {
    
    /** 初回描画フラグ */
    public Boolean isDrawing{ get; set;}
    
    /** 描画実施済みフラグ */
    public Boolean noFirst{ get; set;}

    public List<Item__c> itemList{ get; set;}    //返却される商品List
							

    //コンストラクタ
    public GD101004ParameterClass() {
        
        // フラグ初期化処理
        isDrawing = false;
        noFirst = false;
        
        // 初期化処理
        itemList = new List<Item__c>();
        
    }
}