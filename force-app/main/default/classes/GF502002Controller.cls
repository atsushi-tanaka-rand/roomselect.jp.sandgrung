/**
 * 高校・大学登録
 */
public with sharing class GF502002Controller {

    // 内部クラス
    public ScreenRegistSchool screenRegistSchool      { get; set; } // 高校・大学登録画面

    // 画面項目
    public List<SelectOption> photoMosaicSelectOption { get; set; } // モザイク要否ラジオボタン

    // JS用メッセージ
    public String MSG_COM_V_SAVE   {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_SAVE);}   private set;} // 保存確認メッセージ
    public String MSG_COM_I_SAVE   {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);}   private set;} // 保存完了メッセージ
    public String MSG_COM_V_DELETE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_DELETE);} private set;} // 削除確認メッセージ

    // フラグ
    public Boolean isOpenError     { get; set; } // エラーフラグ
    public Boolean hasErrorMessage { get; set; } // エラーメッセージ保有フラグ

    // モザイク
    public final String MOSAIC_VAL_EXISTS   = 'true';
    public final String MOSAIC_LABEL_EXISTS = 'モザイク有';
    public final String MOSAIC_VAL_NONE     = 'false';
    public final String MOSAIC_LABEL_NONE   = 'モザイクなし';

//＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
//publicメソッド
//＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊

    /**
     * コンストラクタ
     */
    public GF502002Controller() {

        this.isOpenError = false;
        this.hasErrorMessage = false;

        try{
            // ユーザの店舗情報の存在チェック
            // 取得できない場合、例外を発生させる
            CommonUtil.getStaffCurrentShop();

            // パラメータの取得
            Id surroundingFacilityId = ApexPages.currentPage().getParameters().get('surroundingFacilityId'); // 周辺施設ID
            
            // 周辺施設の取得
            SurroundingFacility__c surroundingFacility = this.selectSurroundingFacility(surroundingFacilityId);
            if (surroundingFacility.Id == null) {
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
                throw ex;
            }

            // 画面表示用内部クラスの設定
            this.screenRegistSchool = new ScreenRegistSchool(surroundingFacility);

            // モザイク要否ラジオボタンの設定
            this.photoMosaicSelectOption = new List<SelectOption>();
            this.photoMosaicSelectOption.add(new SelectOption(MOSAIC_VAL_EXISTS, MOSAIC_LABEL_EXISTS));
            this.photoMosaicSelectOption.add(new SelectOption(MOSAIC_VAL_NONE  , MOSAIC_LABEL_NONE));

        } catch(Exception e) {
            isOpenError = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    /**
     * 学校保存処理
     */
    public void saveSchool() {
        
        Savepoint sp = Database.setSavepoint();
        hasErrorMessage = false;

        try{
            // 必須チェック
            BusinessLogicException ex = this.getRequiredItemMsg();
            if (ex.hasMessage()) { 
                throw ex;
            }

            // 楽観ロックチェック
            Boolean isOptimisticLock = CommonUtil.isOptimisticLock(this.screenRegistSchool.SurroundingFacility);
            if (!isOptimisticLock) {
                throw new OptimisticLockException();
            }

            // 周辺施設の更新
            SurroundingFacility__c updSurroundingFacility = new SurroundingFacility__c();
            updSurroundingFacility.Id         = this.screenRegistSchool.SurroundingFacilityId; // Id
            updSurroundingFacility.Name       = this.screenRegistSchool.Name;                  // 施設名
            updSurroundingFacility.Remarks__c = this.screenRegistSchool.Remarks;               // 備考
  
            SecureDML.secureUpdate(updSurroundingFacility);

        } catch(Exception e) {
            Database.rollback(sp);
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    /**
     * 写真情報アップロード後処理
     */
    public void updateCompletePhoto() {
        
        this.hasErrorMessage = false;

        try {
            // S3の写真情報を更新
            AmazonS3Util.savePhoto(this.screenRegistSchool.GD901001Parameter);

            // 内部クラスの写真情報を更新
            this.setScreenRegistSchoolPhotoInfo();

        } catch(Exception e) {
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    /**
     * 写真情報削除処理
     */
    public void deletePhoto(){
        
        this.hasErrorMessage = false;

        try {
            // S3の写真情報を削除
            AmazonS3Util.callPhotoDelete(this.screenRegistSchool.SurroundingFacilityId
                                         , AmazonS3Util.PhotoType.SURROUNDING_FACILITY);
            
            // 内部クラスの写真情報を更新
            this.setScreenRegistSchoolPhotoInfo();

        } catch(Exception e) {
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    /**
     * モザイク（パラメータクラス）の設定
     */
    public void setParamMoosaic() {
        Boolean isMosaic = this.screenRegistSchool.selectedMosaic == MOSAIC_VAL_EXISTS ? true : false;
        this.screenRegistSchool.GD901001Parameter.isMosaic = isMosaic;
    }

//＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
//privateメソッド
//＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊

    /**
     * 周辺施設の取得
     * @param Id condId 周辺施設.Id
     * @return SurroundingFacility__c 周辺施設
     */
    private SurroundingFacility__c selectSurroundingFacility(Id condId){

        SurroundingFacility__c result = new SurroundingFacility__c();

        // 周辺施設の取得
        List<SurroundingFacility__c> surroundingFacilityList = 
            [SELECT Id
                    , Name             // 施設
                    , Address__c       // 住所
                    , Latitude__c      // 緯度
                    , Longitude__c     // 経度
                    , Remarks__c       // 備考
                    , PhotoFilePath__c // 写真ファイルパス
                    , PhotoFileName__c // 写真ファイル名
                    , ForeignID__c     // 外部ID
                    , SystemModStamp
             FROM SurroundingFacility__c
             WHERE Id = :condId];
        
        // 取得値の設定
        if(!surroundingFacilityList.isEmpty()){
            result = surroundingFacilityList[0];
        }

        return result;
    }

    /**
     * 内部クラスの写真情報を更新
     */
    private void setScreenRegistSchoolPhotoInfo() {

        // 最新レコードの取得
        SurroundingFacility__c latestRecord;
        latestRecord = this.selectSurroundingFacility(this.screenRegistSchool.SurroundingFacilityId);

        // 内部クラスの更新
        this.screenRegistSchool.SurroundingFacility = latestRecord;             // 周辺施設
        this.screenRegistSchool.setGD901001Parameter(latestRecord);             // 画像アップロード用 共通部品の設定
        this.screenRegistSchool.PhotoFilePath = latestRecord.PhotoFilePath__c;  // 写真ファイルパス
        this.screenRegistSchool.PhotoFileName = latestRecord.PhotoFileName__c;  // 写真ファイル名
        this.screenRegistSchool.setPhotoDisp();                                 // 写真画面情報
    }

    /**
     * 必須入力メッセージの取得
     * @return BusinessLogicException 例外情報
     */
    private BusinessLogicException getRequiredItemMsg() {

        BusinessLogicException ex = new BusinessLogicException(); // 例外情報
        List<String> requiredItem = new List<String>();           // 必須項目名

        // 学校名チェック
        if (String.isBlank(this.screenRegistSchool.Name)){
            requiredItem.add('学校名');
        }

        // エラーメッセージの取得
        if (!requiredItem.isEmpty()){             
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ',')));
        }

        return ex;
    }

//＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
//内部クラス
//＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
    
    /**
     * 高校・大学登録画面情報
     */
    public class ScreenRegistSchool {

        // オブジェクト
        public SurroundingFacility__c SurroundingFacility { get; set; } // 周辺施設

        // パラメータクラス
        public GD901001ParameterClass GD901001Parameter   { get; set; } // 画像アップロード用 共通部品

        // スタイルクラス
        public String  PhotoNoneIconClass    { get; set; }

        // 項目
        public Id      SurroundingFacilityId { get; set; } // 周辺施設.ID
        public String  Name                  { get; set; } // 学校名
        public String  Address               { get; set; } // 住所
        public Decimal Latitude              { get; set; } // 緯度
        public Decimal Longitude             { get; set; } // 経度
        public String  Remarks               { get; set; } // 備考
        public String  PhotoFileName         { get; set; } // 写真ファイル名
        public String  PhotoFilePath         { get; set; } // 写真ファイルパス
        public String  selectedMosaic        { get; set; } // モザイク選択値
        public Boolean isPhotoNone           { get; set; } // 写真無しフラグ(true:無し、false:有り)

        // 定数
        public  final String PHOTO_NONE_ICON_CLASS = 'photo-None-Icon'; // 写真無し時アイコンクラス
        private final String MOSAIC_VAL_EXISTS     = 'true';            // モザイク有
        private final String MOSAIC_VAL_NONE       = 'false';           // モザイクなし
        
        /**
         * コンストラクタ
         * @param SurroundingFacility__c screenRegistSchool 周辺施設
         */
        public ScreenRegistSchool(SurroundingFacility__c surroundingFacility) {

            // オブジェクト
            this.surroundingFacility = surroundingFacility;  // 周辺施設

            // 項目
            this.SurroundingFacilityId = surroundingFacility.Id;               // 周辺施設.ID
            this.Name                  = surroundingFacility.Name;             // 学校名
            this.Address               = surroundingFacility.Address__c;       // 住所
            this.Latitude              = surroundingFacility.Latitude__c;      // 緯度
            this.Longitude             = surroundingFacility.Longitude__c;     // 経度
            this.Remarks               = surroundingFacility.Remarks__c;       // 備考
            this.PhotoFileName         = surroundingFacility.PhotoFileName__c; // 写真ファイル名
            this.PhotoFilePath         = surroundingFacility.PhotoFilePath__c; // 写真ファイルパス
            this.selectedMosaic        = this.MOSAIC_VAL_NONE;                 // モザイク選択値

            // パラメータクラス
            this.setGD901001Parameter(surroundingFacility);  // 画像アップロード用 共通部品

            // 写真画面の設定
            this.setPhotoDisp();

            // null値を空文字に変換
            this.convertNull();
        }

        /**
         * null値を空文字に変換
         */
        public void convertNull() {
            this.SurroundingFacilityId = this.SurroundingFacilityId == null  ? CommonConst.STRING_EMPTY : this.SurroundingFacilityId;
            this.Name                  = String.isBlank(this.Name)           ? CommonConst.STRING_EMPTY : this.Name;
            this.Address               = String.isBlank(this.Address)        ? CommonConst.STRING_EMPTY : this.Address;
            this.Remarks               = String.isBlank(this.Remarks)        ? CommonConst.STRING_EMPTY : this.Remarks;
            this.selectedMosaic        = String.isBlank(this.selectedMosaic) ? CommonConst.STRING_EMPTY : this.selectedMosaic;
        }

        /**
         * 写真画面の設定
         */
        public void setPhotoDisp() {

            // 画像無し設定値
            this.PhotoNoneIconClass = PHOTO_NONE_ICON_CLASS; // アイコンスタイルクラス
            this.isPhotoNone        = true;                  // 写真無しフラグ

            // 画像有り設定値
            if (!String.isEmpty(this.PhotoFileName)) {
                this.PhotoNoneIconClass = CommonConst.STRING_EMPTY; // アイコンスタイルクラス
                this.isPhotoNone        = false;                    // 写真無しフラグ
            }
        }

        /**
         * 画像アップロード用 共通部品の設定
         * @param SurroundingFacility__c screenRegistSchool 周辺施設
         */
        public void setGD901001Parameter(SurroundingFacility__c surroundingFacility) {
            
            this.GD901001Parameter = new GD901001ParameterClass();
            this.GD901001Parameter.photoType    = CommonConst.S3_PHOTOTYPE_SURROUNDING_FACILITY;
            this.GD901001Parameter.photoSubType = CommonConst.S3_PHOTOTYPE_SURROUNDING_FACILITY;
            this.GD901001Parameter.isArea       = true;
            this.GD901001Parameter.isMosaic     = this.selectedMosaic == this.MOSAIC_VAL_EXISTS ? true: false;
            this.GD901001Parameter.foreignId    = surroundingFacility.ForeignID__c;
            this.GD901001Parameter.fileName     = surroundingFacility.PhotoFileName__c;
            this.GD901001Parameter.filePath     = surroundingFacility.PhotoFilePath__c;
        }
    }
}