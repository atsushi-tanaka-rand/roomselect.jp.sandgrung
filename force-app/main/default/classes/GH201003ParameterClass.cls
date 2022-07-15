/**
 * 店舗・地区選択のクラス
 */
public class GH201003ParameterClass {
    /** 選択済み店舗または地区 */
    public List<String> selectedShopOrDistrictList { get; set; }
    
    /** 店舗/地区モード */
    public Boolean isShopMode { get; set; }
    
    /** 初回描画フラグ */
    public Boolean isDrawing{ get; set;}
    
    /** 描画実施済みフラグ */
    public Boolean noFirst{ get; set;}

    /** 地域選択フラグ */
    public Boolean regionSelectionFlg{ get; set;}
    
    public GH201003ParameterClass(){
        // 初期化処理
        selectedShopOrDistrictList = new  List<String>();        
        isDrawing = false;
        noFirst = false;
        regionSelectionFlg = false;
    }
}