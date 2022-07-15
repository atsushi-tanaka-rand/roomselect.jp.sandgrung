/**
 * 画像アップロードのパラメータクラス
 */
public with sharing class GD901001ParameterClass {
    public Boolean isNew{ get; set;}            // 新規作成
    public Boolean isArea{ get; set;}           // ファイルの選択専用エリア
    public Boolean isMosaic{ get; set;}         // モザイク処理の実施
    public String photoType{ get; set;}         // 写真のタイプ
    public String height{ get; set;}            // 部品の高さ　 ※指定が無い場合は100%
    public String width{ get; set;}             // 部品の幅     ※指定が無い場合は100%
    public String foreignId {get; set;}         // 外部ID       ※建物,周辺施設,学校,病院,駅の外部ID
    public String foreignId2 {get; set;}        // 外部ID       ※物件の外部ID ※foreignIdには物件IDを指定
    public String fileName{ get; set;}          // ファイル名
    public String filePath{ get; set;}          // ファイルパス
    public String fileTag{get; set;}            // タグ
    public String parameter{ get; set;}         // 多機能パラメタ
    public String photoSubType{get; set;}       // 写真のサブタイプ
    public Integer registPhotoCount{get; set;}  // 登録済み写真枚数

    public GD901001ParameterClass() {
        // 初期化処理
        this.isNew = false;
        this.isArea = false;
        this.isMosaic = false;
        this.height = '100%';
        this.width  = '100%';
        this.registPhotoCount = 0;
        this.foreignId      = CommonConst.STRING_EMPTY;
        this.foreignId2     = CommonConst.STRING_EMPTY;
        this.fileName       = CommonConst.STRING_EMPTY;
        this.filePath       = CommonConst.STRING_EMPTY;
        this.fileTag        = CommonConst.STRING_EMPTY;
        this.parameter      = CommonConst.STRING_EMPTY;
        this.photoType      = CommonConst.STRING_EMPTY;
        this.photoSubType   = CommonConst.STRING_EMPTY;
    }
}