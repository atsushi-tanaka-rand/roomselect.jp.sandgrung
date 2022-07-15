//物件登録画面の部屋明細モーダル パラメータクラス
public class GA104006Modal1ParameterClass {
    /** 部屋 */
    public Room__c targetRoom { get; set; }
    
    /** 初回描画フラグ */
    public Boolean isDrawing { get; set;}
    
    /** 描画実施済みフラグ */
    public Boolean noFirst { get; set; }
    
    public GA104006Modal1ParameterClass() {
        // 初期化処理
        targetRoom = new Room__c();      
        isDrawing = false;
        noFirst = false;
    }
}