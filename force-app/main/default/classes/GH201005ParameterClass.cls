/**
 * 商圏・地区選択のクラス
 */
public class GH201005ParameterClass {
    
    /** 選択されている商圏 */
    public String selectedTradeArea { get; set; }
    
    /** 選択済み地区名 */
    public List<String> selectedDistrict { get; set; }
    
    /** 初回描画フラグ */
    public Boolean isDrawing{ get; set;}
    
    /** 描画実施済みフラグ */
    public Boolean noFirst{ get; set;}
    
    public GH201005ParameterClass(){
        // 初期化処理
        selectedTradeArea = null;
        selectedDistrict = new List<String>();
        isDrawing = false;
        noFirst = false;
    }
}