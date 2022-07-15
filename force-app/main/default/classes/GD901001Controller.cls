public with sharing class GD901001Controller {

    /** 共通クラス */
    public GD901001ParameterClass Parameter { get; set; }

    /** S3 関連情報 */
    public String region {get; set;}
    public String bucket {get; set;}
    public String secretKey {get; set;}
    public String accessKeyId {get; set;}
    public String rootDirectory {get; set;}

    /** 圧縮・モザイク関連 */
    public String mosaicApiUrl {get; set;}
    public String mosaicApiKey {get; set;}

    /** ラベリング関連 */
    public String labelingApiUrl {get; set;}
    public String labelingApiKey {get; set;}

	//▼ 2022.01.14 No.0688 対応で追加
	/** パノラマ圧縮関連 */
	public String panoramaCompressApiUrl {get; set;}
	public String panoramaCompressApiKey {get; set;}
	public Decimal panoramaPhotoCompressSize {get; set;}  
	//▲ 2022.01.14 No.0688 対応で追加

    /** リクエスト送信一括処理数 */
    public Integer submitRequestBulkProcessCount {get; set;}

    /** 認証情報 */
    public String sSignature{get; set;}
    public String sPolicy{get; set;}
    public String sCredential{get; set;}
    public String sTimestamp{get; set;}
    public String sS3Path{get; set;}

    /** PHOTOTYPE定数 */
    public String PHOTOTYPE_BUILDING                    { get{return CommonCONST.S3_PHOTOTYPE_BUILDING;}                private set; }  // js用
    public String PHOTOTYPE_PROPERTY                    { get{return CommonCONST.S3_PHOTOTYPE_PROPERTY;}                private set; }  // js用
    public String PHOTOTYPE_SURROUNDING_FACILITY        { get{return CommonCONST.S3_PHOTOTYPE_SURROUNDING_FACILITY;}    private set; }  // js用
    public String PHOTOTYPE_SCHOOL                      { get{return CommonCONST.S3_PHOTOTYPE_SCHOOL;}                  private set; }  // js用
    public String PHOTOTYPE_HOSPITAL                    { get{return CommonCONST.S3_PHOTOTYPE_HOSPITAL;}                private set; }  // js用
    public String PHOTOTYPE_STATION                     { get{return CommonCONST.S3_PHOTOTYPE_STATION;}                 private set; }  // js用
    public String PHOTOTYPE_NEWSRELEASE                 { get{return CommonConst_ptl.S3_PHOTOTYPE_NEWSRELEASE;}         private set; }  // js用：ニュースリリース  // ポータルサイト構築修正　追加
    public String PHOTOTYPE_SHOP                        { get{return CommonConst_ptl.S3_PHOTOTYPE_SHOP;}                private set; }  // js用：店舗写真  // ポータルサイト構築修正　追加
    public String PHOTOSUBTYPE_BUILDING_SURROUNDING     { get{return CommonConst.S3_BUILDINGPHOTOTYPE_SURROUNDING;}     private set; }  // js用：建物.周辺写真
    public String PHOTOSUBTYPE_PROPERTY_PROPERTYPHOTO   { get{return CommonConst.S3_PROPERTYPHOTOTYPE_PROPERTPHOTO;}    private set; }  // js用：物件.物件写真（公開）
    public String PHOTOSUBTYPE_PROPERTY_PRIVATEPHOTO    { get{return CommonConst.S3_PROPERTYPHOTOTYPE_PRIVATEPHOTO;}    private set; }  // js用：物件.物件写真（非公開）
    public String PHOTOSUBTYPE_PROPERTY_PANORAMA        { get{return CommonConst.S3_PROPERTYPHOTOTYPE_PANORAMA;}        private set; }  // js用：物件.パノラマ写真
    public String PHOTOSUBTYPE_PROPERTY_ROOMLAYOUT      { get{return CommonConst.S3_PROPERTYPHOTOTYPE_ROOMLAYOUT;}      private set; }  // js用：物件.間取り図
    public String PHOTOSUBTYPE_PROPERTY_ROOMLAYOUTMEMO  { get{return CommonConst.S3_PROPERTYPHOTOTYPE_ROOMLAYOUTMEMO;}  private set; }  // js用：物件.間取り図メモ
    public Integer PHOTOMAXCOUNT_BUILDING_SURROUNDING   { get{return CommonConst.MAXINDEX_BUILDING_SURROUNDING;}        private set; }  // js用：建物写真.周辺写真
    public Integer PHOTOMAXCOUNT_PORPERTY_PROPERTYPHOTO { get{return CommonConst.MAXINDEX_PROPERTY_PROPERTY;}           private set; }  // js用：物件写真.物件写真
    public Integer PHOTOMAXCOUNT_PORPERTY_PRIVATEPHOTO  { get{return CommonConst.MAXINDEX_PROPERTY_PRIVATE;}            private set; }  // js用：物件写真.非公開写真
    public Integer PHOTOMAXCOUNT_PORPERTY_PANORAMA      { get{return CommonConst.MAXINDEX_PROPERTY_PANORAMA;}           private set; }  // js用：物件写真.パノラマ写真
    public Integer PHOTOMAXCOUNT_NEWSRELEASE_RELEASE    { get{return CommonConst_ptl.MAXINDEX_NEWSRELEASE_RELEASE;}     private set; }  // js用：ニュースリリース掲載写真  // ポータルサイト構築修正 追加
    
    


    /** メッセージ(JavaScript用) */
    public String MSG_E_MULTIPLE         { get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_FILESELECT_MULTIPLE);}    private set; }
    public String MSG_E_EXTENSION        { get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_FILEEXTENSION_NON_JPG);}  private set; }
    public String MSG_E_UPLOAD_CONTAIN   { get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_FILEUPLOAD_CONTAIN);}     private set; }
    public String MSG_E_UPLOAD_ALL       { get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_FILEUPLOAD_ALL);}         private set; }

    
    /**
     * コンストラクタ
     */
    public GD901001Controller() {
        try {
            //S3接続情報取得
            this.region        = SystemConfig__c.getInstance().S3Region__c;
            this.bucket        = SystemConfig__c.getInstance().S3BucketName__c;
            this.secretKey     = SystemConfig__c.getInstance().S3SecretAccessKey__c;
            this.accessKeyId   = SystemConfig__c.getInstance().S3AccessKey__c;
            this.rootDirectory = SystemConfig__c.getInstance().S3RootDirectory__c;

            // 圧縮・モザイク処理情報
            this.mosaicApiUrl  = SystemConfig__c.getInstance().HerokuMosaicApiUrl__c;   // URL
            this.mosaicApiKey  = SystemConfig__c.getInstance().HerokuMosaicApiKey__c;   // ApiKey

            // ラベリング処理情報
            this.labelingApiUrl = SystemConfig__c.getInstance().HerokuLabelingApiUrl__c;   // URL
            this.labelingApiKey = SystemConfig__c.getInstance().HerokuLabelingApiKey__c;   // ApiKey

			//▼ 2022.01.14 No.0688 対応で追加
			// パノラマ圧縮関連
			this.panoramaCompressApiUrl = SystemConfig__c.getInstance().HerokuPanoramaCompressApiUrl__c;   // URL
			this.panoramaCompressApiKey = SystemConfig__c.getInstance().HerokuPanoramaCompressApiKey__c;   // ApiKey
            this.panoramaPhotoCompressSize = SystemConfig__c.getInstance().panoramaPhotoCompressSize__c == null || SystemConfig__c.getInstance().panoramaPhotoCompressSize__c == 0 ? 5 : SystemConfig__c.getInstance().panoramaPhotoCompressSize__c;  // パノラマ写真圧縮サイズ  
			//▲ 2022.01.14 No.0688 対応で追加

            // リクエスト送信一括処理数
            if (SystemConfig__c.getInstance().SubmitRequestBulkProcessCount__c == null || SystemConfig__c.getInstance().SubmitRequestBulkProcessCount__c == 0){
                this.submitRequestBulkProcessCount = 5;
            }else{
                this.submitRequestBulkProcessCount = SystemConfig__c.getInstance().SubmitRequestBulkProcessCount__c.intValue();
            }
        
            //S3の接続情報が存在しない場合はエラー
            if (String.isBlank(this.region) || String.isBlank(this.bucket) ||String.isBlank(this.secretKey)|| String.isBlank(this.accessKeyId)) {
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_GET_AFFILIATION_SHOP));
                throw ex;
            }

            //プロキシ作成
            Datetime now = Datetime.now();
            Datetime dt = now.addDays(1);
            String nowStr = now.formatGMT('yyyyMMdd');
            String timestamp = now.formatGMT('yyyyMMdd') + 'T000000Z';
            String credential = accessKeyId + '/' + nowStr + '/' + region + '/s3/aws4_request';
            String expiration = dt.formatGMT('yyyy-MM-dd') + 'T00:00:00.000Z';
            String temp= '{"expiration":"' + expiration + '",';
            temp+='"conditions":[';
            temp+='{"bucket":"'+ bucket + '"},';
            temp+='["starts-with","$key",""],';
            temp+='{"acl":"public-read"},';
            temp+='{"x-amz-algorithm":"AWS4-HMAC-SHA256"},';
            temp+='{"x-amz-credential":"' + credential + '"},';
            temp+='["starts-with", "$Content-Type", "image/jpeg"],';
            temp+='{"success_action_status": "200"},';
            temp+='{"x-amz-date":"' + timestamp + '"}';
            temp+=']}';
            String policyString = EncodingUtil.base64Encode(Blob.valueOf(temp));
            String policyDocument = policyString;
            temp = EncodingUtil.base64Encode(Blob.valueOf(temp));
            Blob stringToSign = Blob.valueof(temp);
            String policy = policyDocument;

            // 署名計算
            Blob kSecret = Blob.valueof('AWS4' + secretKey);
            Blob kDate = Crypto.generateMac('hmacSHA256', Blob.valueOf(nowStr), kSecret);
            Blob kRegion = Crypto.generateMac('hmacSHA256', Blob.valueOf(REGION), kDate);
            Blob kService = Crypto.generateMac('hmacSHA256', Blob.valueOf('s3'), kRegion);
            Blob kSigning = Crypto.generateMac('hmacSHA256', Blob.valueOf('aws4_request'), kService);
            String signature = EncodingUtil.convertToHex(Crypto.generateMac('hmacSHA256', stringToSign, kSigning));

            //JS用に送信情報設定
            this.sPolicy = policy;
            this.sSignature = signature;
            this.sCredential = credential;
            this.sTimestamp  = timestamp;
            this.sS3Path = 'https://' + this.bucket + '.s3.amazonaws.com';
        } catch(Exception ex) {
            CommonUtil.setErrorMessage(ex);
        }
    }
}