// 物件メンテナンス履歴モーダル　パラメータクラス
public class GA104006Modal4ParameterClass {

    /** 物件メンテナンス履歴 */
    public List<PropertyMaintenanceHistory__c> propertyMaintenanceHistoryList { get; set; }

    /** 初回描画フラグ */
    public Boolean isDrawing { get; set;}
    
    /** 描画実施済みフラグ */
    public Boolean noFirst { get; set; }

    /** コンストラクタ */
    public GA104006Modal4ParameterClass() {
        propertyMaintenanceHistoryList = new List<PropertyMaintenanceHistory__c>();
        isDrawing = false;
        noFirst = false;
    }
}