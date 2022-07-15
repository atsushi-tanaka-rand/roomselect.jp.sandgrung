/* *
 * 物件登録画面のコントローラ
 */
public class GA104006Controller {

    /** パブリック変数 */
    // パラメータ
    public Id propertyId { get; set; }              // 物件ID
    public Id buildingId { get; set; }              // 建物ID
    // フラグ関連
    public Boolean isNew { get; set; }              // 新規登録フラグ
    public Boolean isCopy { get; set; }             // 物件コピーフラグ
    public Boolean isOpenError { get; set; }        // エラーフラグ
    public Boolean hasErrorMessage { get; set; }    // エラーメッセージ保有フラグ
    public String copyPrevWebPublishing { get; set; }   // 物件コピー押下前のweb公開保持用
    public Boolean isRoomLayoutCopy { get; set; }   // 間取り図コピーフラグ
    public Boolean isInsert { get; set; }           // 新規登録フラグ //問合せNo0531で追加
    // 画面表示関連
    public ScreenProperty screenPropertyRecord { get; set; }                                // 画面表示用の内部クラスレコード（物件）
    public List<ScreenRoom> screenRoomRecord { get; set; }                                  // 画面表示用の内部クラスレコード（部屋）
    public ScreenPropertyAttachments screenPropertyAttachmentsRecord { get; set; }          // 画面表示用の内部クラスレコード（添付ファイル）
    public List<PropertyMaintenanceHistory__c> propertyMaintenanceHistoryList { get; set; } // 物件メンテナンス履歴リスト
    public List<ScreenFireInsuranceItem> fireInsuranceItemList { get; set; }                // 火災保険商品リスト
    public List<ScreenGuaranteePlanItem> guaranteePlanItemList { get; set; }                // 保証商品リスト
    public List<ScreenManagementCompanyItem> managementCompanyItemList { get; set; }        // 管理会社指定商品リスト
    public List<ScreenPropertyCdHist> screenPropertyCdHistList         { get; set; }        // 物件コード履歴用内部クラス
    public ScreenAnyPhotoData publicPhotoData { get; set; }                     // 公開物件写真リスト
    public ScreenAnyPhotoData privatePhotoData { get; set; }                    // 非公開物件写真リスト
    public ScreenAnyPhotoData panoramaPhotoData { get; set; }                   // 物件パノラマ写真リスト
    public ScreenAnyPhotoData floorplanPhotoData { get; set; }                  // 間取り図（メモ無）
    public ScreenAnyPhotoData floorplanPhotoMemoData { get; set; }              // 間取り図（メモ有）
    public List<ScreenPrivatePhotoStats> privatePhotoStatsList { get; set; }    // 非公開物件写真アップロード状況リスト
    public String fireInsuranceItemPaymentYear { get; set; }                    // 火災保険加入期間
    public String fireInsuranceItemDetail { get; set; }                         // 火災保険選択プラン詳細
    public String managementCompanyItemAllDetail { get; set; }                  // 管理会社指定商品選択プラン詳細
    // 処理インデックス関連
    public Integer selectedRoomIndex { get; set; }                              // 部屋選択インデックス
    public Integer deletePhotoIndex { get; set; }                               // 削除対象写真インデックス
    public Integer deleteAttachmentIndex { get; set; }                          // 削除対象添付ファイルインデックス
    // 選択リスト関連
    public List<SelectOption> selectLivedTypeList                               { get; set; }   // 選択リスト（未入居種別）
    public List<SelectOption> selectLiveStatusList                              { get; set; }   // 選択リスト（現況）
    public List<SelectOption> selectFloorTypeList                               { get; set; }   // 選択リスト（地下階区分）
    public List<SelectOption> selectRoomLayoutList                              { get; set; }   // 選択リスト（間取り）
    public List<SelectOption> selectBalconyDirectionList                        { get; set; }   // 選択リスト（バルコニー方向）
    public List<SelectOption> selectRentTypeList                                { get; set; }   // 選択リスト（定期借家区分）
    public List<SelectOption> selectSpecificExcellentRentFeeFluctuationTypeList { get; set; }   // 選択リスト（特優賃料金変動区分）
    public List<SelectOption> selectTransactionAspectList                       { get; set; }   // 選択リスト（取引態様）
    public List<SelectOption> selectDeliveryTypeList                            { get; set; }   // 選択リスト（引渡種別）
    public List<SelectOption> selectDeliveryMonthList                           { get; set; }   // 選択リスト（引渡月）
    public List<SelectOption> selectDeliveryTimingList                          { get; set; }   // 選択リスト（引渡旬）
    public List<SelectOption> selectSecurityDepositUnitList                     { get; set; }   // 選択リスト（敷金単位）
    public List<SelectOption> selectRenewalFeeUnitList                          { get; set; }   // 選択リスト（更新料単位）
    public List<SelectOption> selectDepositUnitList                             { get; set; }   // 選択リスト（保証金単位）
    public List<SelectOption> selectTownshipFeePaymentTypeList                  { get; set; }   // 選択リスト（町会費支払区分）
    public List<SelectOption> selectGarbageDisposalFeePaymentTypeList           { get; set; }   // 選択リスト（ゴミ処理費支払区分）
    public List<SelectOption> selectKeyMoneyUnitList                            { get; set; }   // 選択リスト（礼金単位）
    public List<SelectOption> selectCancellationActualFeeUnitList               { get; set; }   // 選択リスト（敷引・償却単位）
    public List<SelectOption> selectCleaningFeeUnitList                         { get; set; }   // 選択リスト（定額修繕費単位）
    public List<SelectOption> selectCleaningFeePaymentTypeList                  { get; set; }   // 選択リスト（定額修繕費支払区分）
    public List<SelectOption> selectBicycleParkingTypeList                      { get; set; }   // 選択リスト（駐輪場種別）
    public List<SelectOption> selectParkingTypeList                             { get; set; }   // 選択リスト（駐車場種別）
    public List<SelectOption> selectParkingDepositUnitList                      { get; set; }   // 選択リスト（駐車場保証料金単位）
    public List<SelectOption> selectParkingCompoundingFeeUnitList               { get; set; }   // 選択リスト（駐車場手数料単位）
    public List<SelectOption> selectBikeStorageTypeList                         { get; set; }   // 選択リスト（バイク置場種別）
    public List<SelectOption> selectIsShortTermPenaltyList                      { get; set; }   // 選択リスト（短期解約違約金有無）
    public List<SelectOption> selectFireInsuranceUseTypeList                    { get; set; }   // 選択リスト（火災保険料（加入義務））
    public List<SelectOption> selectGuaranteeidCompanyTypeList                  { get; set; }   // 選択リスト（保証会社（利用区分））
    public List<SelectOption> selectADFeeUnitList                               { get; set; }   // 選択リスト（広告料単位）
    public List<SelectOption> selectImportTypeList                              { get; set; }   // 選択リスト（取込区分）
    public List<SelectOption> selectWebPublishingList                           { get; set; }   // 選択リスト（Web公開）
    public List<SelectOption> selectPublicPhotoTagList                          { get; set; }   // 選択リスト（物件写真．タグ）
    public List<SelectOption> selectPrivatePhotoTagList                         { get; set; }   // 選択リスト（物件写真．非公開写真タグ）
    public List<SelectOption> selectPanoramaPhotoTagList                        { get; set; }   // 選択リスト（物件パノラマ写真．タグ）
    public List<SelectOption> selectShopList                                    { get; set; }   // athomeパノラマ掲載店舗選択用リスト
    public screenSelectList selectWortFeeTaxTypeList                { get; set; }   // 選択リスト（水道料金税区分）
    public screenSelectList selectRenewalFeeTaxTypeList             { get; set; }   // 選択リスト（更新料税区分）
    public screenSelectList selectManagementFeeTaxTypeList          { get; set; }   // 選択リスト（管理費税区分）
    public screenSelectList selectCATVTaxTypeList                   { get; set; }   // 選択リスト（CATV税区分）
    public screenSelectList selectTownshipInitialFeeTaxTypeList     { get; set; }   // 選択リスト（入町費税区分）
    public screenSelectList selectTownshipFeeTaxTypeList            { get; set; }   // 選択リスト（町会費税区分）
    public screenSelectList selectGarbageDisposalFeeTaxTypeList     { get; set; }   // 選択リスト（ゴミ処理費税区分）
    public screenSelectList selectKeyExchangeFeeTaxTypeList         { get; set; }   // 選択リスト（鍵交換費税区分）
    public screenSelectList selectBicycleParkingFeeTaxTypeList      { get; set; }   // 選択リスト（駐輪場代税区分）
    public screenSelectList selectCleaningFeeTaxTypeList            { get; set; }   // 選択リスト（定額修繕費税区分）
    public screenSelectList selectParkingFeeTaxTypeList             { get; set; }   // 選択リスト（駐車場料金税区分）
    public screenSelectList selectParkingDepositTaxTypeList         { get; set; }   // 選択リスト（駐車場保証料金税区分）
    public screenSelectList selectParkingCompoundingFeeTaxTypeList  { get; set; }   // 選択リスト（駐車場手数料税区分）
    public screenSelectList selectBikeParkingSmallFeeTaxTypeList    { get; set; }   // 選択リスト（小型バイク置場料金税区分）
    public screenSelectList selectBikeParkingMediumFeeTaxTypeList   { get; set; }   // 選択リスト（中型バイク置場料金税区分）
    public screenSelectList selectBikeParkinLargeFeeTaxTypeList     { get; set; }   // 選択リスト（大型バイク置場料金税区分）
    public screenSelectList selectADFeeTaxTypeList                  { get; set; }   // 選択リスト（広告料税区分）
    public screenSelectList selectRewardTypeList                    { get; set; }   // 選択リスト（報酬形態）

    // 間取り図アプリ情報
    public String roomLayoutApiKey   { get; set; }          // 間取り図Apiキー 
    public String roomLayoutApiUrl   { get; set; }          // 間取り図ApiUrl
    public String roomLayoutFileName { get; set; }          // 間取り図作成時ファイル名
    public Boolean roomLayoutAutoAnalysisFlg { get; set; }  // 間取り図自動解析フラグ
    public String roomLayoutNewFileName { get; set; }       // 間取り図アプリ登録後ファイル名 //問合せNo0573で追加

    /** 定数 */
    // メッセージ定数
    public String MSG_COM_V_SAVE    { get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_SAVE);}     private set; }  // js用保存確認メッセージ
    public String MSG_COM_I_SAVE    { get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);}     private set; }  // js用保存完了メッセージ
    public String MSG_COM_V_DELETE  { get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_DELETE);}   private set; }  // js用削除確認メッセージ
    public String MSG_COM_I_DELETE  { get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_DELETE);}   private set; }  // js用削除完了メッセージ
    public String MSG_COM_W_SELECTION_OR_MORE_DELETE_ROOM {
        get{
            return CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SELECTION_OR_MORE,'削除する部屋,1'.split(','));
        }
        private set; } // 削除部屋未選択チェック時メッセージ
    public String MSG_COM_E_SYSTEM_EXCEPTION  { get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_EXCEPTION);}  private set; } // js用異常終了メッセージ
    public String MSG_COM_V_DELETE_IMAGE      { get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_DELETE_IMAGE);}      private set;}  // js用画像一括削除確認メッセージ　//問合せNo0345で追加
    public String MSG_NO_SELECTED_PROPERTY_CD_HIST_ROW {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SELECTION_OR_MORE,'メンテナンス物件コード履歴', '1');} private set;} // メンテナンス物件コード履歴未選択メッセージ
    // 地下階区分
    public String FLOORTYPE_GROUND              { get{return CommonConst.PROPERTY_FLOORTYPE_GROUND;}            private set; }  // 地上
    // バルコニー方向
    public String BALCONYDIRECTION_SOUTHEAST    { get{return CommonConst.PROPERTY_BALCONYDIRECTION_SOUTHEAST;}  private set; }  // 北東
    public String BALCONYDIRECTION_SOUTH        { get{return CommonConst.PROPERTY_BALCONYDIRECTION_SOUTH;}      private set; }  // 北
    public String BALCONYDIRECTION_SOUTHWEST    { get{return CommonConst.PROPERTY_BALCONYDIRECTION_SOUTHWEST;}  private set; }  // 北西
    // 定期借家区分
    public String RENTTYPE_APPLICABLE           { get{return CommonConst.PROPERTY_RENTTYPE_APPLICABLE;}         private set; }  // 該当
    // 引渡種別
    public String DELIVERYTYPE_IMMEDIATE        { get{return CommonConst.PROPERTY_DELIVERYTYPE_IMMEDIATE;}      private set; }  // 即時
    // 料金単位定数
    public String FEEUNIT_YEN                   { get{return CommonConst.PROPERTY_FEEUNIT_YEN;}                 private set; }  // 円
    public String FEEUNIT_MONTH                 { get{return CommonConst.PROPERTY_FEEUNIT_MONTH;}               private set; }  // ヵ月
    public String FEEUNIT_RATE                  { get{return CommonConst.PROPERTY_FEEUNIT_RATE;}                private set; }  // ％
    public String FEEUNIT_ACTUALCOST            { get{return CommonConst.PROPERTY_FEEUNIT_ACTUALCOST;}          private set; }  // 実費
    // 駐車場区分
    public String PARKINGTYPE_EMPTY_EXISTS                 { get{return CommonConst.PROPERTY_PARKINGTYPE_EMPTY_EXISTS;}    private set; }  // 空有
    public String PARKINGTYPE_NO_EMPTY                     { get{return CommonConst.PROPERTY_PARKINGTYPE_NO_EMPTY;}        private set; }  // 空無
    public String PARKINGTYPE_NEIGHBORHOOD_SECURE          { get{return CommonConst.PROPERTY_PARKINGTYPE_NEIGHBORHOOD_SECURE;}        private set; }  // 近隣確保
    // 火災保険利用区分
    public String FIREINSURANCEUSETYPE_EXISTS   { get{return CommonConst.PROPERTY_FIREINSURANCEUSETYPE_EXISTS;} private set; }  // 指定有
    // 保証会社利用区分
    public String GUARANTEEIDCOMPANYTYPE_UNSET  { get{return CommonConst.PROPERTY_GUARANTEEIDCOMPANYTYPE_UNSET;}private set; }  // 未設定
    // 画像処理用　写真種別
    public String PROPERTYPHOTOTYPE_PROPERTPHOTO    { get{return CommonConst.S3_PROPERTYPHOTOTYPE_PROPERTPHOTO;}    private set; }  // js用写真種別
    public String PROPERTYPHOTOTYPE_PRIVATEPHOTO    { get{return CommonConst.S3_PROPERTYPHOTOTYPE_PRIVATEPHOTO;}    private set; }  // js用写真種別
    public String PROPERTYPHOTOTYPE_PANORAMA        { get{return CommonConst.S3_PROPERTYPHOTOTYPE_PANORAMA;}        private set; }  // js用写真種別
    public String PROPERTYPHOTOTYPE_ROOMLAYOUT      { get{return CommonConst.S3_PROPERTYPHOTOTYPE_ROOMLAYOUT;}      private set; }  // js用写真種別
    public String PROPERTYPHOTOTYPE_ROOMLAYOUTMEMO  { get{return CommonConst.S3_PROPERTYPHOTOTYPE_ROOMLAYOUTMEMO;}  private set; }  // js用写真種別
    // 画像処理用　最大登録可能数
    public Integer MAXINDEX_PUBLICPHOTO         { get{return CommonConst.MAXINDEX_PROPERTY_PROPERTY;}           private set; }  // js用公開写真最大登録数
    public Integer MAXINDEX_PRIVATEPHOTO        { get{return CommonConst.MAXINDEX_PROPERTY_PRIVATE;}            private set; }  // js用非公開写真最大登録数
    public Integer MAXINDEX_PANORAMAPHOTO       { get{return CommonConst.MAXINDEX_PROPERTY_PANORAMA;}           private set; }  // js用パノラマ写真最大登録数
    //ポータルサイト構築 追加 Start
    public String MSG_COM_E_OPTIONAL_PERMISSION_CHECK  { get{return CommonUtil.callMessageCreate(CommonConst_ptl.MSG_COM_E_OPTIONAL_PERMISSION_CHECK,'ポータルサイトのご契約');}  private set; }  // 自社HP権限なしメッセージ
    //ポータルサイト構築 追加 End
    public String MSG_PROP_I_ROOMLAYOUT_AUTOANALYSIS { get{return CommonConst.MSG_PROP_I_ROOMLAYOUT_AUTOANALYSIS;}  private set; }  // 間取り図自動解析メッセージ   // 問合せNo0491で追加
    // 問合せ278で追加
    private final String REALNETPRO = CommonConst.PROPERTY_IMPORTTYPE_REALNETPRO;       // リアプロ
    private final String DAIWALIVING = CommonConst.PROPERTY_IMPORTTYPE_DAIWALIVING;     // 大和リビング
    private final String MANUAL = CommonConst.PROPERTY_IMPORTTYPE_MANUAL;               // 手動
    private final String SELECTION_LIST_NULL = CommonConst.SELECTION_LIST_NULL;         // --なし--
    /** パラメータクラス */
    // モーダル関連
    public GA104006Modal1ParameterClass GA104006Modal1Parameter { get; set; }   // 部屋登録モーダル用
    public GA104006Modal2ParameterClass GA104006Modal2Parameter { get; set; }   // 文例選択モーダル用
    //ポータルサイト構築 追加 Start
    public GA104006Modal3ParameterClass GA104006Modal3Parameter { get; set; }   // おすすめ物件登録モーダル用
    //ポータルサイト構築 追加 End
    public GA104006Modal4ParameterClass GA104006Modal4Parameter { get; set; }   // 物件メンテナンス履歴
    public GD301003ParameterClass GD301003Parameter { get; set; }               // 業者選択モーダル用
    //問合せ291で変更
    public  String GA104002Parameter { get; set; }                              // 物件MAP照会用引渡パラメータ
    // 写真処理関連
    public GD901001ParameterClass publicPhotoGD901001Parameter { get; set; }        // 写真登録（公開）
    public GD901001ParameterClass privatePhotoGD901001Parameter { get; set; }       // 写真登録（非公開）
    public GD901001ParameterClass panoramaPhotoGD901001Parameter { get; set; }      // 写真登録（パノラマ）
    public GD901001ParameterClass floorplanPhotoGD901001Parameter { get; set; }     // 写真登録（間取り図）
    public GD901001ParameterClass floorplanMemoPhotoGD901001Parameter { get; set; } // 写真登録（間取り図メモ有）

    //ポータルサイト構築 追加 Start
    public Boolean isUseAuthorityPortal { get; set; }   //利用権限_自社HPフラグ
    public RecommendProperty__c recoPro { get; set; }   //おすすめ物件
    //ポータルサイト構築 追加 End
    //再販対応 追加 Start
    public Boolean isUseAuthorityPanoramaTour { get; set; } //利用権限_パノラマツアーフラグ
    //再販対応 追加 End

    /** プライベート変数 */
    private String prevPage { get; set; }                   // 前画面（手動メンテ/自動メンテ/物件検索）
    private Building__c buildingRecord { get; set; }        // 建物
    private Property__c initPropertyRecord;                 // 初期表示時のレコード（物件）
    private Boolean isOpenModalCreate { get; set; }         // 部屋登録新規モーダルフラグ
    private List<Room__c> deleteRoomList { get; set; }      // 削除する部屋のリスト
    private Datetime MaintenanceStartDateTime { get; set; } // メンテナンス開始時刻
    private Boolean isPhotoDataOperate { get; set; }        // 画像データ操作フラグ
    private Boolean changeBeforeIsPermissionPublishing { get; set; } // 変更前の掲載許可済みフラグ:2020/5/8追加
    private PropertyConditions__c initPropertyConditionsRecord; // 初期表示時のレコード（物件条件）

    // 間取り図コピー関連
    private String fromforeignId;                           // コピー元物件外部ID
    private String floorplanPhotoFileName;                  // コピーファイル名
    private String floorplanPhotoMemoFileName;              // コピーファイル名メモ    

    Integer initFireInsuranceCheckedCount;                  // 火災保険の初期表示行
    Integer saveFireInsuranceCheckedCount;                  // 火災保険の保存ボタン押下時表示行
    Integer initGuaranteePlanCheckedCount;                  // 保証会社の初期表示行
    Integer saveGuaranteePlanCheckedCount;                  // 保証会社の保存ボタン押下時表示行
    List<Integer> initManagementCompanyItemCheckedCountList;// 管理会社指定商品の初期表示行
    List<Integer> saveManagementCompanyItemCheckedCountList;// 管理会社指定商品の保存ボタン押下時表示行

    //▼問合せNo0539で追加
    private String   copyPrevImportType;                // 物件コピー押下前の取込先保持用
    private String   copyPrevMaintenancePropertyCode;   // 物件コピー押下前のメンテナンス物件コード保持用
    private Datetime copyPrevManualMaintenanceDate;     // 物件コピー押下前の手動最終メンテナンス日保持用
    private Datetime copyPrevAutoMaintenanceDate;       // 物件コピー押下前の自動最終メンテナンス日保持用
    private String   copyPrevRealnetproURL;             // 物件コピー押下前のリアプロURL保持用
    private String   copyPrevDaiwalivingURL;            // 物件コピー押下前の大和リビングURL保持用
    //▲問合せNo0539で追加

    // メンテナンスコメント用文字列　(未設定)
    private static final String NOT_SET = '(未設定)';

    //▼問合せNo0598で追加
    private Boolean isRecommendProperty;        //おすすめ物件変更フラグ
    private Boolean isRecommendPropertyCopy;    // コピー元おすすめ物件変更フラグ
    //▲問合せNo0598で追加

    // コンストラクタ
    public GA104006Controller() {
        try {
            // エラーフラグ初期化
            this.isOpenError = false;
            this.hasErrorMessage = false;

            // 画像データ操作フラグ初期化
            this.isPhotoDataOperate = false;

            // 間取り図コピーの項目を初期化
            this.fromforeignId = '';
            this.floorplanPhotoFileName = '';
            this.floorplanPhotoMemoFileName = '';
            this.isRoomLayoutCopy = false;
            this.roomLayoutFileName = '';

            this.initManagementCompanyItemCheckedCountList = new List<Integer>();
            this.saveManagementCompanyItemCheckedCountList = new List<Integer>();

            //店舗異動が取得できなければエラー
            CommonUtil.getStaffCurrentShop();

            // パラメータ取得
            this.propertyId = ApexPages.currentPage().getParameters().get('propertyId');
            this.buildingId = ApexPages.currentPage().getParameters().get('buildingId');
            this.prevPage = ApexPages.currentPage().getParameters().get('formMode');        // 前画面（手動/自動）

            // パラメータチェック
            // 建物Id, 物件Id 両方nullはエラー
            if (this.buildingId == null && this.propertyId == null) {
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
                throw ex;
            }

            // 各種物件情報等のデータ取得／初期化
            if (this.propertyId == null) {
                // 物件Idがnullの場合、新規作成
                this.isNew = true;
                this.isCopy = false;
                this.changeBeforeIsPermissionPublishing = false;//2020/5/8追加

                // 各オブジェクトに空データを格納
                this.buildingRecord = selectBuilding(this.buildingId);                                          // 建物
                this.screenPropertyRecord = new ScreenProperty(
                    new Property__c()
                    ,this.buildingRecord
                    ,new List<PortalSitePostingProperty__c>()
                    ,new List<Room__c>()
                );     
                //▼問合せ393で変更
                this.screenPropertyRecord.ContractTermYear = '2';                                               //契約期間（年）
                this.screenPropertyRecord.ManagementFeeTaxType = CommonConst.PROPERTY_TAXTYPE_NOTAXABLE;        //非課税
                this.screenPropertyRecord.PropertyConditions.IsITImportantDescription__c = true;                //IT重説対応物件
                //▲問合せ393で変更
                this.initPropertyRecord = new Property__c();
                this.screenPropertyAttachmentsRecord = new ScreenPropertyAttachments(new List<Attachment>());   // 添付ファイル
                this.propertyMaintenanceHistoryList = new List<PropertyMaintenanceHistory__c>();                // 物件メンテナンス履歴リスト
                this.fireInsuranceItemList = new List<ScreenFireInsuranceItem>();                               // 火災保険商品リスト
                this.fireInsuranceItemPaymentYear = '';
                this.fireInsuranceItemDetail = '';
                this.guaranteePlanItemList = new List<ScreenGuaranteePlanItem>();                               // 保証商品リスト
                this.managementCompanyItemList = new List<ScreenManagementCompanyItem>();                       // 管理会社指定商品リスト
                this.managementCompanyItemAllDetail = '';
                this.initPropertyConditionsRecord = new PropertyConditions__c();                                // 初期表示時の物件条件
            } else {
                this.isNew = false;
                this.isCopy = false;
                Property__c prop = selectProperty(this.propertyId); // 物件情報Select
                // 建物
                this.buildingRecord = selectBuilding(prop.Building__c);
                this.buildingId = prop.Building__c;
                // 物件
                this.screenPropertyRecord = new ScreenProperty(
                    prop
                    ,this.buildingRecord
                    ,this.selectPortalSitePostingProperty(this.propertyId)
                    ,this.selectRoom(this.propertyId)
                );
                this.initPropertyRecord = prop.clone();
                this.initPropertyConditionsRecord = this.screenPropertyRecord.PropertyConditions.clone();
                this.changeBeforeIsPermissionPublishing = this.screenPropertyRecord.IsPermissionPublishing;//2020/5/8追加
                // 添付ファイル
                this.screenPropertyAttachmentsRecord = new ScreenPropertyAttachments(selectPropertyAttachments(this.propertyId));
                // 物件メンテナンス履歴リスト
                this.propertyMaintenanceHistoryList = new List<PropertyMaintenanceHistory__c>(selectPropertyMaintenanceHistory(this.propertyId));
                // 火災保険商品リスト
                this.fireInsuranceItemList = new List<ScreenFireInsuranceItem>();
                for (InsuranceGuarantee__c record : selectFireInsuranceItem(this.screenPropertyRecord.FormerSupplierId)) {
                    this.fireInsuranceItemList.add(new ScreenFireInsuranceItem(record, this.screenPropertyRecord.FireInsurancePlan));
                }

                // 火災保険商品リストを回して、どれもチェックがついていないなら、火災保険会社と火災保険プランをnullに変更する
                Boolean fireInsuranceItemIsChecked = false;
                Integer fireInsuranceCount = 1;
                for (ScreenFireInsuranceItem fireInsuranceItem : this.fireInsuranceItemList){
                    if (fireInsuranceItem.IsChecked){
                        // チェックがついている。
                        fireInsuranceItemIsChecked = true;
                        // 初期表示時のチェック行を保持
                        this.initFireInsuranceCheckedCount = fireInsuranceCount;
                        break;
                    }
                    fireInsuranceCount++;
                }
                if(!fireInsuranceItemIsChecked){
                    this.screenPropertyRecord.FireInsuranceCompany = null;      // 火災保険会社
                    this.screenPropertyRecord.FireInsurancePlan = null;         // 火災保険タイトル
                }


                // 選択加入期間、プラン詳細を設定
                this.fireInsuranceItemPaymentYear = '';
                this.fireInsuranceItemDetail = '';
                for (ScreenFireInsuranceItem record : this.fireInsuranceItemList) {
                    if (record.IsChecked) {
                        this.fireInsuranceItemPaymentYear = record.PaymentYear;
                        this.fireInsuranceItemDetail = record.Detail;
                    }
                }
                // 保証商品リスト
                this.guaranteePlanItemList = new List<ScreenGuaranteePlanItem>();
                for (InsuranceGuarantee__c record : selectGuaranteePlanItem(this.screenPropertyRecord.FormerSupplierId)) {
                    this.guaranteePlanItemList.add(new ScreenGuaranteePlanItem(record, this.screenPropertyRecord.Guaranteeid));
                }

                // 保証会社リストを回して、どれもチェックがついていないなら、保証会社と保証タイトルをnullに変更する
                Boolean guaranteePlanItemIsChecked = false;
                Integer guaranteePlanCount = 1;
                for (ScreenGuaranteePlanItem guaranteePlanItem : this.guaranteePlanItemList){
                    if (guaranteePlanItem.IsChecked){
                        // チェックがついている
                        guaranteePlanItemIsChecked = true;
                        // 初期表示時のチェック行を保持
                        this.initGuaranteePlanCheckedCount = guaranteePlanCount;
                        break;
                    }
                    guaranteePlanCount++;
                }
                if(!guaranteePlanItemIsChecked){
                    this.screenPropertyRecord.GuaranteeidCompany = null;        // 保証会社
                    this.screenPropertyRecord.Guaranteeid = null;               // 保証タイトル
                }

                // 管理会社指定商品リスト
                this.managementCompanyItemList = new List<ScreenManagementCompanyItem>();
                for (ManagementCompanyItem__c record : selectManagementCompanyItem(this.propertyId, this.screenPropertyRecord.FormerSupplierId)) {
                    this.managementCompanyItemList.add(new ScreenManagementCompanyItem(record));
                }
                // 選択保証プラン詳細を設定
                this.managementCompanyItemAllDetail = '';
                Integer managementCompany = 1;
                for (ScreenManagementCompanyItem record : this.managementCompanyItemList) {
                    if (record.IsChecked) {
                        if (!String.isEmpty(managementCompanyItemAllDetail)) {
                            managementCompanyItemAllDetail += '  /  ';
                        }
                        // 初期表示時のチェック行を保持
                        managementCompanyItemAllDetail += record.Detail;
                        this.initManagementCompanyItemCheckedCountList.add(managementCompany);
                    }
                    managementCompany++;
                }

                // メンテナンス物件コード履歴を設定
                this.setPropertyCdHist(this.propertyId);
            }
            // 写真関連の情報の初期化・情報取得
            this.setAnyPhotoList();
            // モーダル用のパラメータ初期化
            this.GA104006Modal1Parameter = new GA104006Modal1ParameterClass();
            this.GA104006Modal2Parameter = new GA104006Modal2ParameterClass();
            this.GA104006Modal3Parameter = new GA104006Modal3ParameterClass();  // 問合せNo0440で追加
            this.GA104006Modal4Parameter = new GA104006Modal4ParameterClass();
            // 削除対象部屋リスト初期化
            this.deleteRoomList = new List<Room__c>();


            // 選択リスト関連の公開変数の内容取得
            this.selectLivedTypeList                                = CommonUtil.getSelectOptionFromObject('Property__c', 'LivedType__c');                                  // 未入居種別
            this.selectLiveStatusList                               = CommonUtil.getSelectOptionFromObject('Property__c', 'LiveStatus__c');                                 // 現況
            this.selectFloorTypeList                                = CommonUtil.getSelectOptionFromObject('Property__c', 'FloorType__c');                                  // 地下階区分
            this.selectRoomLayoutList                               = CommonUtil.getSelectOptionFromObject('Property__c', 'RoomLayout__c');                                 // 間取り
            this.selectBalconyDirectionList                         = CommonUtil.getSelectOptionFromObject('Property__c', 'BalconyDirection__c');                           // バルコニー方向
            this.selectRentTypeList                                 = CommonUtil.getSelectOptionFromObject('Property__c', 'RentType__c');                                   // 定期借家区分
            this.selectSpecificExcellentRentFeeFluctuationTypeList  = CommonUtil.getSelectOptionFromObject('Property__c', 'SpecificExcellentRentFeeFluctuationType__c');    // 特優賃料金変動区分
            this.selectTransactionAspectList                        = CommonUtil.getSelectOptionFromObject('Property__c', 'TransactionAspect__c');                          // 取引態様
            this.selectDeliveryTypeList                             = CommonUtil.getSelectOptionFromObject('Property__c', 'DeliveryType__c');                               // 引渡種別
            this.selectDeliveryMonthList                            = CommonUtil.getSelectOptionFromObject('Property__c', 'DeliveryMonth__c');                              // 引渡月
            this.selectDeliveryTimingList                           = CommonUtil.getSelectOptionFromObject('Property__c', 'DeliveryTiming__c');                             // 引渡旬
            this.selectSecurityDepositUnitList                      = CommonUtil.getSelectOptionFromObject('Property__c', 'SecurityDepositUnit__c', false);                 // 敷金単位
            this.selectRenewalFeeUnitList                           = CommonUtil.getSelectOptionFromObject('Property__c', 'RenewalFeeUnit__c', false);                      // 更新料単位
            this.selectDepositUnitList                              = CommonUtil.getSelectOptionFromObject('Property__c', 'DepositUnit__c', false);                         // 保証金単位
            this.selectTownshipFeePaymentTypeList                   = CommonUtil.getSelectOptionFromObject('Property__c', 'TownshipFeePaymentType__c', false);              // 町会費支払区分
            this.selectGarbageDisposalFeePaymentTypeList            = CommonUtil.getSelectOptionFromObject('Property__c', 'GarbageDisposalFeePaymentType__c', false);       // ゴミ処理費支払区分
            this.selectKeyMoneyUnitList                             = CommonUtil.getSelectOptionFromObject('Property__c', 'KeyMoneyUnit__c', false);                        // 礼金単位
            this.selectCancellationActualFeeUnitList                = CommonUtil.getSelectOptionFromObject('Property__c', 'CancellationActualFeeUnit__c', false);           // 敷引・償却単位
            this.selectCleaningFeeUnitList                          = CommonUtil.getSelectOptionFromObject('Property__c', 'CleaningFeeUnit__c', false);                     // 定額修繕費単位
            this.selectCleaningFeePaymentTypeList                   = CommonUtil.getSelectOptionFromObject('Property__c', 'CleaningFeePaymentType__c', false);              // 定額修繕費支払区分
            this.selectBicycleParkingTypeList                       = CommonUtil.getSelectOptionFromObject('Property__c', 'BicycleParkingType__c', false);                  // 駐輪場種別
            this.selectParkingTypeList                              = CommonUtil.getSelectOptionFromObject('Property__c', 'ParkingType__c', false);                         // 駐車場種別
            this.selectParkingDepositUnitList                       = CommonUtil.getSelectOptionFromObject('Property__c', 'ParkingDepositUnit__c', false);                  // 駐車場保証料金単位
            this.selectParkingCompoundingFeeUnitList                = CommonUtil.getSelectOptionFromObject('Property__c', 'ParkingCompoundingFeeUnit__c', false);           // 駐車場手数料単位
            this.selectBikeStorageTypeList                          = CommonUtil.getSelectOptionFromObject('Property__c', 'BikeStorageType__c', false);                     // バイク置場種別
            this.selectIsShortTermPenaltyList                       = CommonUtil.getSelectOptionFromObject('Property__c', 'IsShortTermPenalty__c', false);                  // 短期解約違約金有無
            this.selectFireInsuranceUseTypeList                     = CommonUtil.getSelectOptionFromObject('Property__c', 'FireInsuranceUseType__c', false);                // 火災保険料（加入義務）
            this.selectGuaranteeidCompanyTypeList                   = CommonUtil.getSelectOptionFromObject('Property__c', 'GuaranteeidCompanyType__c', false);              // 保証会社（利用区分）
            this.selectADFeeUnitList                                = CommonUtil.getSelectOptionFromObject('Property__c', 'ADFeeUnit__c', false);                           // 広告料単位
            this.selectImportTypeList                               = CommonUtil.getSelectOptionFromObject('Property__c', 'ImportType__c');                                 // 取込区分
            this.selectWebPublishingList                            = CommonUtil.getSelectOptionFromObject('Property__c', 'WebPublishing__c');                              // Web公開
            this.selectPublicPhotoTagList                           = CommonUtil.getSelectOptionFromObject('PropertyPhoto__c', 'PropertyPhotoTag1__c'); // 物件写真．タグ
            this.selectPrivatePhotoTagList                          = CommonUtil.getSelectOptionFromObject('PropertyPhoto__c', 'PrivatePhotoType1__c'); // 物件写真．非公開写真タグ
            this.selectPanoramaPhotoTagList                         = CommonUtil.getSelectOptionFromObject('PropertyPhoto__c', 'PanoramaTag1__c');      // 物件写真．パノラマタグ
            this.selectShopList                                     = CommonUtil.getShopSelectedOptionFromStaffId(null, true, true, false);             // 店舗
            this.selectWortFeeTaxTypeList                           = new screenSelectList(CommonUtil.getSelectOptionFromObject('Property__c', 'WortFeeTaxType__c', false));                // 水道料金税区分
            this.selectRenewalFeeTaxTypeList                        = new screenSelectList(CommonUtil.getSelectOptionFromObject('Property__c', 'RenewalFeeTaxType__c', false));             // 更新料税区分
            this.selectManagementFeeTaxTypeList                     = new screenSelectList(CommonUtil.getSelectOptionFromObject('Property__c', 'ManagementFeeTaxType__c', false));          // 管理費税区分
            this.selectCATVTaxTypeList                              = new screenSelectList(CommonUtil.getSelectOptionFromObject('Property__c', 'CATVTaxType__c', false));                   // CATV税区分
            this.selectTownshipInitialFeeTaxTypeList                = new screenSelectList(CommonUtil.getSelectOptionFromObject('Property__c', 'TownshipInitialFeeTaxType__c', false));     // 入町費税区分
            this.selectTownshipFeeTaxTypeList                       = new screenSelectList(CommonUtil.getSelectOptionFromObject('Property__c', 'TownshipFeeTaxType__c', false));            // 町会費税区分
            this.selectGarbageDisposalFeeTaxTypeList                = new screenSelectList(CommonUtil.getSelectOptionFromObject('Property__c', 'GarbageDisposalFeeTaxType__c', false));     // ゴミ処理費税区分
            this.selectKeyExchangeFeeTaxTypeList                    = new screenSelectList(CommonUtil.getSelectOptionFromObject('Property__c', 'KeyExchangeFeeTaxType__c', false));         // 鍵交換費税区分
            this.selectBicycleParkingFeeTaxTypeList                 = new screenSelectList(CommonUtil.getSelectOptionFromObject('Property__c', 'BicycleParkingFeeTaxType__c', false));      // 駐輪場代税区分
            this.selectCleaningFeeTaxTypeList                       = new screenSelectList(CommonUtil.getSelectOptionFromObject('Property__c', 'CleaningFeeTaxType__c', false));            // 定額修繕費税区分
            this.selectParkingFeeTaxTypeList                        = new screenSelectList(CommonUtil.getSelectOptionFromObject('Property__c', 'ParkingFeeTaxType__c', false));             // 駐車場料金税区分
            this.selectParkingDepositTaxTypeList                    = new screenSelectList(CommonUtil.getSelectOptionFromObject('Property__c', 'ParkingDepositTaxType__c', false));         // 駐車場保証料金税区分
            this.selectParkingCompoundingFeeTaxTypeList             = new screenSelectList(CommonUtil.getSelectOptionFromObject('Property__c', 'ParkingCompoundingFeeTaxType__c', false));  // 駐車場手数料税区分
            this.selectBikeParkingSmallFeeTaxTypeList               = new screenSelectList(CommonUtil.getSelectOptionFromObject('Property__c', 'BikeParkingSmallFeeTaxType__c', false));    // 小型バイク置場料金税区分
            this.selectBikeParkingMediumFeeTaxTypeList              = new screenSelectList(CommonUtil.getSelectOptionFromObject('Property__c', 'BikeParkingMediumFeeTaxType__c', false));   // 中型バイク置場料金税区分
            this.selectBikeParkinLargeFeeTaxTypeList                = new screenSelectList(CommonUtil.getSelectOptionFromObject('Property__c', 'BikeParkinLargeFeeTaxType__c', false));     // 大型バイク置場料金税区分
            this.selectADFeeTaxTypeList                             = new screenSelectList(CommonUtil.getSelectOptionFromObject('Property__c', 'ADFeeTaxType__c', false));                  // 広告料税区分
            this.selectRewardTypeList                               = new screenSelectList(CommonUtil.getSelectOptionFromObject('Property__c', 'RewardType__c', false));                    // 報酬形態
            // 物件情報を元に選択リストの初期選択
            this.selectWortFeeTaxTypeList.setCheckValue(this.screenPropertyRecord.WortFeeTaxType);                              // 水道料金税区分
            this.selectRenewalFeeTaxTypeList.setCheckValue(this.screenPropertyRecord.RenewalFeeTaxType);                        // 更新料税区分
            this.selectManagementFeeTaxTypeList.setCheckValue(this.screenPropertyRecord.ManagementFeeTaxType);                  // 管理費税区分
            this.selectCATVTaxTypeList.setCheckValue(this.screenPropertyRecord.CATVTaxType);                                    // CATV税区分
            this.selectTownshipInitialFeeTaxTypeList.setCheckValue(this.screenPropertyRecord.TownshipInitialFeeTaxType);        // 入町費税区分
            this.selectTownshipFeeTaxTypeList.setCheckValue(this.screenPropertyRecord.TownshipFeeTaxType);                      // 町会費税区分
            this.selectGarbageDisposalFeeTaxTypeList.setCheckValue(this.screenPropertyRecord.GarbageDisposalFeeTaxType);        // ゴミ処理費税区分
            this.selectKeyExchangeFeeTaxTypeList.setCheckValue(this.screenPropertyRecord.KeyExchangeFeeTaxType);                // 鍵交換費税区分
            this.selectBicycleParkingFeeTaxTypeList.setCheckValue(this.screenPropertyRecord.BicycleParkingFeeTaxType);          // 駐輪場代税区分
            this.selectCleaningFeeTaxTypeList.setCheckValue(this.screenPropertyRecord.CleaningFeeTaxType);                      // 定額修繕費税区分
            this.selectParkingFeeTaxTypeList.setCheckValue(this.screenPropertyRecord.ParkingFeeTaxType);                        // 駐車場料金税区分
            this.selectParkingDepositTaxTypeList.setCheckValue(this.screenPropertyRecord.ParkingDepositTaxType);                // 駐車場保証料金税区分
            this.selectParkingCompoundingFeeTaxTypeList.setCheckValue(this.screenPropertyRecord.ParkingCompoundingFeeTaxType);  // 駐車場手数料税区分
            this.selectBikeParkingSmallFeeTaxTypeList.setCheckValue(this.screenPropertyRecord.BikeParkingSmallFeeTaxType);      // 小型バイク置場料金税区分
            this.selectBikeParkingMediumFeeTaxTypeList.setCheckValue(this.screenPropertyRecord.BikeParkingMediumFeeTaxType);    // 中型バイク置場料金税区分
            this.selectBikeParkinLargeFeeTaxTypeList.setCheckValue(this.screenPropertyRecord.BikeParkinLargeFeeTaxType);        // 大型バイク置場料金税区分
            this.selectADFeeTaxTypeList.setCheckValue(this.screenPropertyRecord.ADFeeTaxType);                                  // 広告料税区分
            this.selectRewardTypeList.setCheckValue(this.screenPropertyRecord.RewardType);                                      // 報酬形態

            // メンテナンス開始時刻の設定
            this.MaintenanceStartDateTime = CommonUtil.getNow();

            // 間取りAPIKey、URL取得
            this.roomLayoutApiKey = SystemConfig__c.getInstance().RoomLayoutApiKey__c; 
            this.roomLayoutApiUrl = SystemConfig__c.getInstance().RoomLayoutApiUrl__c; 
            this.roomLayoutAutoAnalysisFlg = SystemConfig__c.getInstance().RoomLayoutAutoAnalysisFlg__c;
            this.roomLayoutNewFileName = CommonConst.STRING_EMPTY;  //問合せNo0573で追加

            //ポータルサイト構築 追加 Start
            //利用権限_自社HPを取得
            isUseAuthorityPortal = AuthorityCheckUtil.getAuthorityOptionPortal(false);
            //▼問合せNo0598で追加
            this.isRecommendProperty = false;
            this.isRecommendPropertyCopy = false;
            //▲問合せNo0598で追加
            //利用権限_自社HPがtrueのときのみおすすめ物件を取得
            if (isUseAuthorityPortal){
                recoPro = getRecommendProperty();
            }           
            //ポータルサイト構築 追加 End

            //再販対応 追加 Start
            ///利用権限_パノラマツアーを取得
            isUseAuthorityPanoramaTour = AuthorityCheckUtil.getAuthorityOptionPanoramaTour(false);
            //再販対応 追加 End

            this.isInsert = this.isNew || this.isCopy;      // 新規登録フラグ //問合せNo0531で追加
        } catch(Exception e) {
            // エラー設定
            this.isOpenError = true;
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    //ポータルサイト構築 追加 Start
    private RecommendProperty__c getRecommendProperty(){
        List<RecommendProperty__c> recoProList = [SELECT Id,
                                                PhotoFilePath__c,       //写真ファイルパス
                                                PhotoFileName__c,       //写真ファイル名
                                                HomesImportkey__c,      //HOME'Sインポートキー
                                                PanoramaTourUrl__c,     //パノラマツアーURL
                                                Comment__c,             //コメント
                                                ShopId__c,              //登録店舗
                                                UserId__c,              //登録ユーザ
                                                SystemModStamp          
                                            FROM RecommendProperty__c
                                            WHERE PropertyCode__c = :screenPropertyRecord.PropertyCode
                                            LIMIT 1];
        if (recoProList.isEmpty()){
            //おすすめ物件から取得できなかったら空を返す
            return new RecommendProperty__c();
        }else{
            //取得できたらそれを返す
            return recoProList[0];
        }
    }

    // 物件コピーボタン押下処理
    public void clickPropertyCopyButton() {
        // 物件コピーモード
        this.isCopy = true;
        this.isInsert = true;
        // web公開を「しない」に変更（キャンセルされたとき用に元の値は保持しておく）
        this.copyPrevWebPublishing = this.screenPropertyRecord.WebPublishing;
        this.screenPropertyRecord.WebPublishing = CommonConst.PROPERTY_WEBPUBLISHING_NO;
        this.propertyMaintenanceHistoryList = new List<PropertyMaintenanceHistory__c>();                // 物件メンテナンス履歴リスト
        
        //▼問合せNo0539で追加
        // コピー前の状態を保持
        this.copyPrevImportType                 = this.screenPropertyRecord.ImportType;                 // 取込先
        this.copyPrevMaintenancePropertyCode    = this.screenPropertyRecord.MaintenancePropertyCode;    // メンテナンス物件コード
        this.copyPrevManualMaintenanceDate      = this.screenPropertyRecord.ManualMaintenanceDate;      // 手動最終メンテナンス日
        this.copyPrevAutoMaintenanceDate        = this.screenPropertyRecord.AutoMaintenanceDate;        // 自動最終メンテナンス日
        this.copyPrevRealnetproURL              = this.screenPropertyRecord.RealnetproURL;              // リアプロURL
        this.copyPrevDaiwalivingURL             = this.screenPropertyRecord.DaiwalivingURL;             // 大和リビングURL
        //▼問合せNo0598で追加
        this.isRecommendPropertyCopy            = this.isRecommendProperty;                             // おすすめ物件変更フラグを保持
        this.isRecommendProperty                = false;                                                // おすすめ物件変更フラグをfalseに
        //▲問合せNo0598で追加
        // 空をセット
        this.screenPropertyRecord.ImportType                = CommonConst.STRING_EMPTY;                 // 取込先
        this.screenPropertyRecord.initialInportType         = CommonConst.STRING_EMPTY;                 // 画面初期表示時取込区分
        this.screenPropertyRecord.MaintenancePropertyCode   = CommonConst.STRING_EMPTY;                 // メンテナンス物件コード
        this.screenPropertyRecord.ManualMaintenanceDate     = null;                                     // 手動最終メンテナンス日
        this.screenPropertyRecord.AutoMaintenanceDate       = null;                                     // 自動最終メンテナンス日
        this.screenPropertyRecord.RealnetproURL             = CommonConst.STRING_EMPTY;                 // リアプロURL
        this.screenPropertyRecord.DaiwalivingURL            = CommonConst.STRING_EMPTY;                 // 大和リビングURL
        //▲問合せNo0539で追加
    }

    // 削除ボタン押下処理
    public void clickDeleteButton() {
        this.hasErrorMessage = false;

        //ポータルサイト構築 追加 Start
        // パノラマツアー非公開設定
        RecommendProperty__c recoProp;
        if (isUseAuthorityPortal){
            try{
                recoProp = recommendPropertyToursStatus(this.propertyId); 
            }catch(Exception e){
                hasErrorMessage = true;//エラーを設定
                CommonUtil.setErrorMessage(e);
                return;
            }
        }
        //ポータルサイト構築 追加 End
        
        Savepoint sp = Database.setSavepoint();
        try{
            this.hasErrorMessage = false;

            // 部屋
            List<Room__c> room = [
                SELECT
                    Id
                FROM
                    Room__c
                WHERE
                    Property__c = :this.propertyId
            ];
            SecureDML.secureDelete(room);

            // ポータルサイト掲載物件
            List<PortalSitePostingProperty__c> potalSitePost = [
                SELECT
                    Id
                FROM
                    PortalSitePostingProperty__c
                WHERE
                    Property__c = :this.propertyId
            ];
            SecureDML.secureDelete(potalSitePost);

            // 物件写真（AmazonS3）
            AmazonS3Util.callPropertyPhotoDeleteAll(this.screenPropertyRecord.Id);

            // 物件写真
            List<PropertyPhoto__c> propPhoto = [
                SELECT
                    Id
                FROM
                    PropertyPhoto__c
                WHERE
                    Property__c = :this.propertyId
            ];
            SecureDML.secureDelete(propPhoto);

            //ポータルサイト構築 追加 Start
            if (isUseAuthorityPortal && recoProp != null ){
                //おすすめ物件
                SecureDML.secureDelete(recoProp);
            }                  
            //ポータルサイト構築 追加 End

            // 物件
            List<Property__c> prop = [
                SELECT
                     Id
                    ,Name 
                    ,Building__r.Name
                FROM
                    Property__c
                WHERE
                    Id = :this.propertyId
            ];
            SecureDML.secureDelete(prop);

            // 削除した物件の名寄せ対象（同名の建物・部屋番号の物件データ）が存在しないか、確認
            List<Property__c> mergeProp = [
                SELECT
                     Id
                    ,IsMergeCompletedFlag__c 
                FROM
                    Property__c
                WHERE
                    Name = :prop[0].Name
                AND Building__r.Name = :prop[0].Building__r.Name
                AND IsDeleted = FALSE
            ];
            // 取得件数により分岐
            if (mergeProp.size() ==0){
                // 0件の場合は、処理終了
                return;
            } else if (mergeProp.size() == 1){
                // 1件の場合は、名寄せ完了フラグをTRUEで更新(重複がなくなった為)
                mergeProp[0].IsMergeCompletedFlag__c = TRUE;
            } else {
                // 2件以上の場合は、名寄せ完了フラグをFALSEで更新
                for (Property__c mprop : mergeProp) {
                    mprop.IsMergeCompletedFlag__c = FALSE;
                }
            }
            // 名寄せ物件を更新
            SecureDML.secureUpdate(mergeProp);

        }catch(Exception e){
            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }

    // 部屋登録モーダル(新規)起動
    public void openRoomModalCreate() {
        this.isOpenModalCreate = true;
        this.GA104006Modal1Parameter = new GA104006Modal1ParameterClass();
        this.GA104006Modal1Parameter.isDrawing = true;
        this.GA104006Modal1Parameter.noFirst = true;
        // 部屋レコードを新規作成
        this.GA104006Modal1Parameter.targetRoom = new Room__c(Property__c = this.propertyId);
    }
    // 部屋登録モーダル(編集)起動
    public void openRoomModalUpdate() {
        this.isOpenModalCreate = false;
        this.GA104006Modal1Parameter = new GA104006Modal1ParameterClass();
        this.GA104006Modal1Parameter.isDrawing = true;
        this.GA104006Modal1Parameter.noFirst = true;
        // 編集押下した部屋レコード
        this.GA104006Modal1Parameter.targetRoom = this.screenPropertyRecord.ScreenRoomList[selectedRoomIndex].Room;
    }
    // 部屋登録モーダル終了
    public void closeRoomModal() {
        if(this.isOpenModalCreate){
            // 新規の場合、部屋を追加
            ScreenRoom screenRoom = new ScreenRoom(
                new Room__c(
                    Property__c         = this.propertyId
                    ,RoomFloorSpace__c  = this.GA104006Modal1Parameter.targetRoom.RoomFloorSpace__c
                    ,RoomType__c        = this.GA104006Modal1Parameter.targetRoom.RoomType__c
                )
            );
            this.screenPropertyRecord.ScreenRoomList.add(screenRoom);
        }
    }
    // 部屋削除ボタン押下処理
    public void clickRoomDelete(){
        // コピーリスト
        List<ScreenRoom> notDeleleList = new List<ScreenRoom>();
        for (ScreenRoom record : this.screenPropertyRecord.ScreenRoomList) {
            // チェックありレコードの場合 
            if (record.IsChecked) {
                // 登録済データであればレコードを削除対象リストに追加
                if (!String.isEmpty(record.Room.id)) {
                    this.deleteRoomList.add(record.Room);
                }
            // チェックなしレコードの場合
            } else {
                // 削除対象外リストに追加
                notDeleleList.add(record);
            }
        }
        // 表示用のリストに削除対象外リストを反映（コピー）する
        this.screenPropertyRecord.ScreenRoomList = notDeleleList.clone();
    }

    // 添付ファイル押下処理（添付の削除）
    public void clickAttachmentDelete() {
        try {
            this.hasErrorMessage = false;

            // 削除処理
            List<Attachment> delAttachment = [
                SELECT
                    Id
                FROM
                    Attachment
                WHERE
                    Id = :this.screenPropertyAttachmentsRecord.Id[this.deleteAttachmentIndex]
            ];
            SecureDML.secureDelete(delAttachment);

            // 添付ファイルの再読み込み
            reloadAttachment();

        } catch(Exception e) {
            // エラー設定
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // 添付ファイルの再読み込み
    public void reloadAttachment() {
        try {
            this.hasErrorMessage = false;
            // 添付ファイルの再読み込み
            this.screenPropertyAttachmentsRecord
                = new ScreenPropertyAttachments(selectPropertyAttachments(this.propertyId));
        } catch(Exception e) {
            // エラー設定
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // 写真関連情報取得
    public void setAnyPhotoList() {
        this.setPublicPhotoList();
        this.setPrivatePhotoList();
        this.setPanoramaPhotoList();
        this.setFloorplanPhotoList();
    }
    // 写真アップロード後処理（公開写真）
    public void updatePublicPhoto() {
        try {
            this.hasErrorMessage = false;

            // 画像データ操作フラグON
            this.isPhotoDataOperate = true;

            // SystemModStampの変更有無を取得する
            Boolean isNotOptimisticLockError = this.checkSystemModStamp(this.propertyId);

            // 物件写真を更新する
            AmazonS3Util.savePhoto(this.publicPhotoGD901001Parameter);

            // 公開写真情報の再読み込み（タグ、コメントは入力中のものを反映し直す）
            List<PhotoData> tempPhotoData = this.publicPhotoData.photoDataList.clone();
            this.setPublicPhotoList();
            for (Integer i = 0; i < tempPhotoData.size(); i++) {
                this.publicPhotoData.photoDataList[i].Tag     = tempPhotoData[i].Tag;
                this.publicPhotoData.photoDataList[i].Comment = tempPhotoData[i].Comment;
            }

            // 物件写真更新前時点でSystemModStampに変更が無かった場合、SystemModStampを再取得する
            if (isNotOptimisticLockError) {
                this.screenPropertyRecord.SystemModStamp = this.getSystemModStamp(this.propertyId);
            }

            // 物件メンテナンス履歴を更新するために物件を更新
            saveMaintenanceHistory('公開写真追加');

            // 物件メンテナンス履歴リスト再取得
            this.propertyMaintenanceHistoryList = selectPropertyMaintenanceHistory(this.propertyId);
            this.screenPropertyRecord.SystemModStamp = this.getSystemModStamp(this.propertyId);

        } catch(Exception e) {
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    // 写真アップロード後処理（非公開写真）
    public void updatePrivatePhoto() {
        try {
            this.hasErrorMessage = false;

            // 画像データ操作フラグON
            this.isPhotoDataOperate = true;

            // SystemModStampの変更有無を取得する
            Boolean isNotOptimisticLockError = this.checkSystemModStamp(this.propertyId);

            // 物件写真を更新する
            AmazonS3Util.savePhoto(this.privatePhotoGD901001Parameter);

            // 非公開写真情報の再読み込み（タグ、コメントは入力中のものを反映し直す）
            List<PhotoData> tempPhotoData = this.privatePhotoData.photoDataList.clone();
            this.setPrivatePhotoList();
            for (Integer i = 0; i < tempPhotoData.size(); i++) {
                this.privatePhotoData.photoDataList[i].Tag     = tempPhotoData[i].Tag;
                this.privatePhotoData.photoDataList[i].Comment = tempPhotoData[i].Comment;
            }

            // 物件写真更新前時点でSystemModStampに変更が無かった場合、SystemModStampを再取得する
            if (isNotOptimisticLockError) {
                this.screenPropertyRecord.SystemModStamp = this.getSystemModStamp(this.propertyId);
            }

            // 物件メンテナンス履歴を更新するために物件を更新
            saveMaintenanceHistory('非公開写真追加');

            // 物件メンテナンス履歴リスト再取得
            this.propertyMaintenanceHistoryList = selectPropertyMaintenanceHistory(this.propertyId);
            this.screenPropertyRecord.SystemModStamp = this.getSystemModStamp(this.propertyId);

        } catch(Exception e) {
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    // 写真アップロード後処理（パノラマ写真）
    public void updatePanoramaPhoto() {
        try {
            this.hasErrorMessage = false;

            // 画像データ操作フラグON
            this.isPhotoDataOperate = true;

            // SystemModStampの変更有無を取得する
            Boolean isNotOptimisticLockError = this.checkSystemModStamp(this.propertyId);

            // 物件写真を更新する
            AmazonS3Util.savePhoto(this.panoramaPhotoGD901001Parameter);

            // パノラマ写真情報の再読み込み（タグ、コメントは入力中のものを反映し直す）
            List<PhotoData> tempPhotoData = this.panoramaPhotoData.photoDataList.clone();
            this.setPanoramaPhotoList();
            for (Integer i = 0; i < tempPhotoData.size(); i++) {
                this.panoramaPhotoData.photoDataList[i].Tag     = tempPhotoData[i].Tag;
                this.panoramaPhotoData.photoDataList[i].Comment = tempPhotoData[i].Comment;
            }

            // スーモスコア再計算
            PropertyPhoto__c propPhoto = this.selectAnyPhotoList(this.propertyId);
            BuildingPhoto__c buildPhoto = this.selectBuildingPhoto(this.buildingRecord.Id);
            Property__c prop = new Property__c();
            prop.Id = this.propertyId;
            prop.Score__c = BuildingPropertyUtil.getSuumoScore(this.buildingRecord, buildPhoto, this.initPropertyRecord, propPhoto);   // 点数
            if (this.screenPropertyRecord.headerScore != prop.Score__c) {
                SecureDML.secureUpdate(prop);
                this.screenPropertyRecord.headerScore = prop.Score__c;
            }

            // 物件写真更新前時点でSystemModStampに変更が無かった場合、SystemModStampを再取得する
            if (isNotOptimisticLockError) {
                this.screenPropertyRecord.SystemModStamp = this.getSystemModStamp(this.propertyId);
            }

            // 物件メンテナンス履歴を更新するために物件を更新
            saveMaintenanceHistory('パノラマ写真追加');

            // 物件メンテナンス履歴リスト再取得
            this.propertyMaintenanceHistoryList = selectPropertyMaintenanceHistory(this.propertyId);
            this.screenPropertyRecord.SystemModStamp = this.getSystemModStamp(this.propertyId);
            
        } catch(Exception e) {
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    // 写真アップロード後処理（間取り図）
    public void updateFloorplanPhoto() {
        try {
            this.hasErrorMessage = false;

            // 画像データ操作フラグON
            this.isPhotoDataOperate = true;

            // SystemModStampの変更有無を取得する
            Boolean isNotOptimisticLockError = this.checkSystemModStamp(this.propertyId);

            // 登録済の間取り図（メモ有/無 両方）を削除する
            if (this.floorplanPhotoData.photoCount > 0) {
                AmazonS3Util.callPhotoDelete(this.screenPropertyRecord.Id, AmazonS3Util.PhotoType.PROPERTY_ROOMLAYOUT);
            }
            if (this.floorplanPhotoMemoData.photoCount > 0) {
                AmazonS3Util.callPhotoDelete(this.screenPropertyRecord.Id, AmazonS3Util.PhotoType.PROPERTY_ROOMLAYOUTMEMO);
            }
            // 物件写真を更新する
            AmazonS3Util.savePhoto(this.floorplanPhotoGD901001Parameter);
            // 間取り図情報の再読み込み
            this.setFloorplanPhotoList();

            // 物件写真更新前時点でSystemModStampに変更が無かった場合、SystemModStampを再取得する
            if (isNotOptimisticLockError) {
                this.screenPropertyRecord.SystemModStamp = this.getSystemModStamp(this.propertyId);
            }
        } catch(Exception e) {
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    // 写真アップロード後処理（間取り図メモ）
    public void updateFloorplanMemoPhoto() {
        try {
            this.hasErrorMessage = false;

            // 画像データ操作フラグON
            this.isPhotoDataOperate = true;

            // SystemModStampの変更有無を取得する
            Boolean isNotOptimisticLockError = this.checkSystemModStamp(this.propertyId);

            // 登録済の間取り図（メモ有）を削除する
            if (this.floorplanPhotoMemoData.photoCount > 0) {
                AmazonS3Util.callPhotoDelete(this.screenPropertyRecord.Id, AmazonS3Util.PhotoType.PROPERTY_ROOMLAYOUTMEMO);
            }
            // 物件写真を更新する
            AmazonS3Util.savePhoto(this.floorplanMemoPhotoGD901001Parameter);
            // 間取り図情報の再読み込み
            this.setFloorplanPhotoList();

            // 物件写真更新前時点でSystemModStampに変更が無かった場合、SystemModStampを再取得する
            if (isNotOptimisticLockError) {
                this.screenPropertyRecord.SystemModStamp = this.getSystemModStamp(this.propertyId);
            }

            // 物件メンテナンス履歴を更新するために物件を更新
            saveMaintenanceHistory('間取り図メモ追加');

            // 物件メンテナンス履歴リスト再取得
            this.propertyMaintenanceHistoryList = selectPropertyMaintenanceHistory(this.propertyId);
            this.screenPropertyRecord.SystemModStamp = this.getSystemModStamp(this.propertyId);

        } catch(Exception e) {
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // 間取り図アプリ保存後処理（間取り図と間取り図メモ）
    public void appAfterSaveFloorplanPhoto() {
        try {
            this.hasErrorMessage = false;

            // 画像データ操作フラグON
            this.isPhotoDataOperate = true;

            // SystemModStampの変更有無を取得する
            Boolean isNotOptimisticLockError = this.checkSystemModStamp(this.propertyId);

            // 登録済の間取り図（メモ有）を削除する
            if (this.floorplanPhotoMemoData.photoCount > 0) {
                AmazonS3Util.callPhotoDelete(this.screenPropertyRecord.Id, AmazonS3Util.PhotoType.PROPERTY_ROOMLAYOUTMEMO);
            }
            
            // 物件写真を更新する。
            PropertyPhoto__c propPhoto = new PropertyPhoto__c();
            propPhoto.id = screenPropertyRecord.PropertyPhotoId;
            propPhoto.Property__c = this.screenPropertyRecord.Id;
            //▼問合せNo0573で変更
            String fileName = AmazonS3Util.getFileName(this.roomLayoutNewFileName);
            if(String.isEmpty(fileName)){
                fileName = this.roomLayoutNewFileName;
            }
            propPhoto.RoomLayoutFileName__c = fileName;   
            //▲問合せNo0573で変更
            propPhoto.RoomLayoutMemoFileName__c = '';
            SecureDML.secureUpsert(propPhoto);

            // 間取り図情報の再読み込み
            this.setFloorplanPhotoList();

            // 物件写真更新前時点でSystemModStampに変更が無かった場合、SystemModStampを再取得する
            if (isNotOptimisticLockError) {
                this.screenPropertyRecord.SystemModStamp = this.getSystemModStamp(this.propertyId);
            }

            // 物件メンテナンス履歴を更新するために物件を更新
            saveMaintenanceHistory('間取り図作成');

            // 物件メンテナンス履歴リスト再取得
            this.propertyMaintenanceHistoryList = selectPropertyMaintenanceHistory(this.propertyId);
            this.screenPropertyRecord.SystemModStamp = this.getSystemModStamp(this.propertyId);
            
        } catch(Exception e) {
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // 写真（公開）画像削除処理
    public void deletePublicPhoto(){
        try {
            this.hasErrorMessage = false;

            // 画像データ操作フラグON
            this.isPhotoDataOperate = true;

            // SystemModStampの変更有無を取得する
            Boolean isNotOptimisticLockError = this.checkSystemModStamp(this.propertyId);

            // 画像削除
            AmazonS3Util.callPhotoDelete(this.screenPropertyRecord.Id
                                        , AmazonS3Util.PhotoType.PROPERTY, this.deletePhotoIndex);

            // 写真再読み込み
            this.reloadAnyPhotoAfterDelete(this.publicPhotoData, this.deletePhotoIndex);
            this.publicPhotoGD901001Parameter.registPhotoCount = this.publicPhotoData.photoCount;

            // 物件写真更新前時点でSystemModStampに変更が無かった場合、SystemModStampを再取得する
            if (isNotOptimisticLockError) {
                this.screenPropertyRecord.SystemModStamp = this.getSystemModStamp(this.propertyId);
            }

            // 物件メンテナンス履歴を更新するために物件を更新
            saveMaintenanceHistory('公開写真削除');

            // 物件メンテナンス履歴リスト再取得
            this.propertyMaintenanceHistoryList = selectPropertyMaintenanceHistory(this.propertyId);
            this.screenPropertyRecord.SystemModStamp = this.getSystemModStamp(this.propertyId);
        
        } catch(Exception e) {
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    // 写真（非公開）画像削除処理
    public void deletePrivatePhoto(){
        try {
            this.hasErrorMessage = false;

            // 画像データ操作フラグON
            this.isPhotoDataOperate = true;

            // SystemModStampの変更有無を取得する
            Boolean isNotOptimisticLockError = this.checkSystemModStamp(this.propertyId);

            // 画像削除
            AmazonS3Util.callPhotoDelete(this.screenPropertyRecord.Id
                                        , AmazonS3Util.PhotoType.PROPERTY_PRIVATE, this.deletePhotoIndex);

            // 写真再読み込み
            this.reloadAnyPhotoAfterDelete(this.privatePhotoData, this.deletePhotoIndex);
            this.privatePhotoGD901001Parameter.registPhotoCount = this.privatePhotoData.photoCount;

            // 物件写真更新前時点でSystemModStampに変更が無かった場合、SystemModStampを再取得する
            if (isNotOptimisticLockError) {
                this.screenPropertyRecord.SystemModStamp = this.getSystemModStamp(this.propertyId);
            }

            // 物件メンテナンス履歴を更新するために物件を更新
            saveMaintenanceHistory('非公開写真削除');

            // 物件メンテナンス履歴リスト再取得
            this.propertyMaintenanceHistoryList = selectPropertyMaintenanceHistory(this.propertyId);
            this.screenPropertyRecord.SystemModStamp = this.getSystemModStamp(this.propertyId);

        } catch(Exception e) {
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    // パノラマ写真画像削除処理
    public void deletePanoramaPhoto(){
        try {
            this.hasErrorMessage = false;

            // 画像データ操作フラグON
            this.isPhotoDataOperate = true;

            // SystemModStampの変更有無を取得する
            Boolean isNotOptimisticLockError = this.checkSystemModStamp(this.propertyId);

            // 画像削除
            AmazonS3Util.callPhotoDelete(this.screenPropertyRecord.Id
                                        , AmazonS3Util.PhotoType.PROPERTY_PANORAMA, this.deletePhotoIndex);

            // 写真再読み込み
            this.reloadAnyPhotoAfterDelete(this.panoramaPhotoData, this.deletePhotoIndex);
            this.panoramaPhotoGD901001Parameter.registPhotoCount = this.panoramaPhotoData.photoCount;

            // 物件の更新
            Property__c prop = new Property__c();
            Boolean updateFlg = false;
            // 削除した結果、パノラマ写真が0件となる場合、HOME'Sパノラマ掲載店舗・SUUMOパノラマ掲載店舗をクリア
            if (this.panoramaPhotoData.photoCount == 0) {
                if (!String.isEmpty(this.screenPropertyRecord.HomesPanoramaShop) || !String.isEmpty(this.screenPropertyRecord.SuumoPanoramaShop)) {
                    this.screenPropertyRecord.HomesPanoramaShop = '';
                    this.screenPropertyRecord.SuumoPanoramaShop = '';
                    prop.HomesPanoramaShop__c = null;
                    prop.SuumoPanoramaShop__c = null;
                    updateFlg = true;
                }
            }
            // スーモスコアの再計算
            PropertyPhoto__c propPhoto = this.selectAnyPhotoList(this.propertyId);
            BuildingPhoto__c buildPhoto = this.selectBuildingPhoto(this.buildingRecord.Id);
            prop.Id = this.propertyId;
            prop.Score__c = BuildingPropertyUtil.getSuumoScore(this.buildingRecord, buildPhoto, this.initPropertyRecord, propPhoto);   // 点数
            if (this.screenPropertyRecord.headerScore != prop.Score__c) {
                this.screenPropertyRecord.headerScore = prop.Score__c;
                updateFlg = true;
            }
            if (updateFlg) {
                SecureDML.secureUpdate(prop);
            }

            // 物件写真更新前時点でSystemModStampに変更が無かった場合、SystemModStampを再取得する
            if (isNotOptimisticLockError) {
                this.screenPropertyRecord.SystemModStamp = this.getSystemModStamp(this.propertyId);
            }

            // 物件メンテナンス履歴を更新するために物件を更新
            saveMaintenanceHistory('パノラマ写真削除');

            // 物件メンテナンス履歴リスト再取得
            this.propertyMaintenanceHistoryList = selectPropertyMaintenanceHistory(this.propertyId);
            this.screenPropertyRecord.SystemModStamp = this.getSystemModStamp(this.propertyId);

        } catch(Exception e) {
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    // 間取り図画像削除処理
    public void deleteFloorplanPhoto(){
        try {
            this.hasErrorMessage = false;

            // 画像データ操作フラグON
            this.isPhotoDataOperate = true;

            // SystemModStampの変更有無を取得する
            Boolean isNotOptimisticLockError = this.checkSystemModStamp(this.propertyId);

            // 画像削除
            AmazonS3Util.callPhotoDelete(this.screenPropertyRecord.Id
                                        , AmazonS3Util.PhotoType.PROPERTY_ROOMLAYOUT);
            AmazonS3Util.callPhotoDelete(this.screenPropertyRecord.Id
                                        , AmazonS3Util.PhotoType.PROPERTY_ROOMLAYOUTMEMO);
            // 写真再読み込み
            this.setFloorplanPhotoList();

            // 物件写真更新前時点でSystemModStampに変更が無かった場合、SystemModStampを再取得する
            if (isNotOptimisticLockError) {
                this.screenPropertyRecord.SystemModStamp = this.getSystemModStamp(this.propertyId);
            }

            // 物件メンテナンス履歴を更新するために物件を更新
            saveMaintenanceHistory('間取り図画像削除');

            // 物件メンテナンス履歴リスト再取得
            this.propertyMaintenanceHistoryList = selectPropertyMaintenanceHistory(this.propertyId);
            this.screenPropertyRecord.SystemModStamp = this.getSystemModStamp(this.propertyId);

        } catch(Exception e) {
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    //▼問合せNo0345で追加
    // 公開写真の一括削除処理
    public void deletePublicPhotoAll(){
        try {
            this.hasErrorMessage = false;

            // 画像データ操作フラグON
            this.isPhotoDataOperate = true;

            // SystemModStampの変更有無を取得する
            Boolean isNotOptimisticLockError = this.checkSystemModStamp(this.propertyId);

            // 画像削除
            AmazonS3Util.callPropertyPhotoDeleteType(this.propertyId,AmazonS3Util.PhotoType.PROPERTY);
            
            // 写真再読み込み
            this.setPublicPhotoList();

            // 物件写真更新前時点でSystemModStampに変更が無かった場合、SystemModStampを再取得する
            if (isNotOptimisticLockError) {
                this.screenPropertyRecord.SystemModStamp = this.getSystemModStamp(this.propertyId);
            }

            // 物件メンテナンス履歴を更新するために物件を更新
            saveMaintenanceHistory('公開写真一括削除');

            // 物件メンテナンス履歴リスト再取得
            this.propertyMaintenanceHistoryList = selectPropertyMaintenanceHistory(this.propertyId);
            this.screenPropertyRecord.SystemModStamp = this.getSystemModStamp(this.propertyId);

        } catch(Exception e) {
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    // 非公開写真の一括削除処理
    public void deletePrivatePhotoAll(){
        try {
            this.hasErrorMessage = false;

            // 画像データ操作フラグON
            this.isPhotoDataOperate = true;

            // SystemModStampの変更有無を取得する
            Boolean isNotOptimisticLockError = this.checkSystemModStamp(this.propertyId);

            // 画像削除
            AmazonS3Util.callPropertyPhotoDeleteType(this.propertyId,AmazonS3Util.PhotoType.PROPERTY_PRIVATE);
            
            // 写真再読み込み
            this.setPrivatePhotoList();

            // 物件写真更新前時点でSystemModStampに変更が無かった場合、SystemModStampを再取得する
            if (isNotOptimisticLockError) {
                this.screenPropertyRecord.SystemModStamp = this.getSystemModStamp(this.propertyId);
            }

            // 物件メンテナンス履歴を更新するために物件を更新
            saveMaintenanceHistory('非公開写真一括削除');

            // 物件メンテナンス履歴リスト再取得
            this.propertyMaintenanceHistoryList = selectPropertyMaintenanceHistory(this.propertyId);
            this.screenPropertyRecord.SystemModStamp = this.getSystemModStamp(this.propertyId);

        } catch(Exception e) {
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    // パノラマツアー写真の一括削除処理
    public void deletePanoramaPhotoAll(){
        try {
            this.hasErrorMessage = false;

            // 画像データ操作フラグON
            this.isPhotoDataOperate = true;

            // SystemModStampの変更有無を取得する
            Boolean isNotOptimisticLockError = this.checkSystemModStamp(this.propertyId);

            // 画像削除
            AmazonS3Util.callPropertyPhotoDeleteType(this.propertyId,AmazonS3Util.PhotoType.PROPERTY_PANORAMA);
            
            // 写真再読み込み
            this.setPanoramaPhotoList();

            // スーモスコアの再計算
            Property__c prop = new Property__c();
            Boolean updateFlg = false;
            PropertyPhoto__c propPhoto = this.selectAnyPhotoList(this.propertyId);
            BuildingPhoto__c buildPhoto = this.selectBuildingPhoto(this.buildingRecord.Id);
            prop.Id = this.propertyId;
            prop.Score__c = BuildingPropertyUtil.getSuumoScore(this.buildingRecord, buildPhoto, this.initPropertyRecord, propPhoto);   // 点数
            if (this.screenPropertyRecord.headerScore != prop.Score__c) {
                this.screenPropertyRecord.headerScore = prop.Score__c;
                updateFlg = true;
            }
            if (updateFlg) {
                SecureDML.secureUpdate(prop);
            }

            // 物件写真更新前時点でSystemModStampに変更が無かった場合、SystemModStampを再取得する
            if (isNotOptimisticLockError) {
                this.screenPropertyRecord.SystemModStamp = this.getSystemModStamp(this.propertyId);
            }

            // 物件メンテナンス履歴を更新するために物件を更新
            saveMaintenanceHistory('パノラマ写真一括削除');

            // 物件メンテナンス履歴リスト再取得
            this.propertyMaintenanceHistoryList = selectPropertyMaintenanceHistory(this.propertyId);
            this.screenPropertyRecord.SystemModStamp = this.getSystemModStamp(this.propertyId);

        } catch(Exception e) {
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    //▲問合せNo0345で追加

    private GD301003ParameterClass.SupplierConst currentGD301003ModalMode { get; set; } // 文例分岐管理項目
    // 業者選択モーダル起動（元付業者）
    public void formerSupplierSelectModal() {
        this.currentGD301003ModalMode = GD301003ParameterClass.SupplierConst.FORMER_SUPPLIER;
        openGD301003Modal();
    }
    // 業者選択モーダル起動（貸主）
    public void formerCreditorModal() {
        this.currentGD301003ModalMode = GD301003ParameterClass.SupplierConst.CREDITOR;
        openGD301003Modal();
    }
    // 業者選択モーダル起動（所有者）
    public void ownerSelectModal() {
        this.currentGD301003ModalMode = GD301003ParameterClass.SupplierConst.OWNER;
        openGD301003Modal();
    }
    // 業者選択モーダル起動
    public void openGD301003Modal() {
        this.GD301003Parameter = new GD301003ParameterClass();
        this.GD301003Parameter.isDrawing = true;
        this.GD301003Parameter.noFirst = true;
        this.GD301003Parameter.supplierType = this.currentGD301003ModalMode;
    }
    // 業者選択モーダル終了
    public void closeGD301003Modal() {
        Account acc = new Account();
        acc = this.GD301003Parameter.accountRecord;
        if (this.currentGD301003ModalMode == GD301003ParameterClass.SupplierConst.FORMER_SUPPLIER) {
            // 元付業者情報
            this.screenPropertyRecord.FormerSupplierId                   = acc.Id;                      // 元付業者Id
            this.screenPropertyRecord.FormerSupplierName                 = acc.Name;                    // 元付業者名
            this.screenPropertyRecord.FormerSupplierPhone                = acc.Phone;                   // 元付業者電話番号
            this.screenPropertyRecord.FormerSupplierFax                  = acc.Fax;                     // 元付業者Fax
            this.screenPropertyRecord.FormerSupplierPostalCode           = acc.PostalCode__c;           // 元付業者郵便番号
            this.screenPropertyRecord.FormerSupplierAddress              = acc.Address__c;              // 元付業者住所
            this.screenPropertyRecord.FormerSupplierState                = acc.State__c;                // 元付業者都道府県
            this.screenPropertyRecord.FormerSupplierCity                 = acc.City__c;                 // 元付業者住所１（市区町村）
            this.screenPropertyRecord.FormerSupplierStreet               = acc.Street__c;               // 元付業者住所２（番地）
            this.screenPropertyRecord.FormerSupplierEmail                = acc.Email__c;                // 元付業者メール
            this.screenPropertyRecord.FormerSupplierRepresentative       = acc.Representative__c;       // 元付業者担当者
            this.screenPropertyRecord.FormerSupplierRepresentativePhone  = acc.RepresentativePhone__c;  // 元付業者担当者電話番号
            this.screenPropertyRecord.FormerSupplierRemarks              = acc.RemarksPublic__c;        // 元付業者備考
            this.screenPropertyRecord.FormerSupplierIsMergeCompletedFlag = acc.IsMergeCompletedFlag__c; // 元付業者名寄せ完了フラグ
            // 商品関係情報再取得
            // 火災保険商品リスト
            this.fireInsuranceItemList = new List<ScreenFireInsuranceItem>();
            for (InsuranceGuarantee__c record : selectFireInsuranceItem(this.screenPropertyRecord.FormerSupplierId)) {
                this.fireInsuranceItemList.add(new ScreenFireInsuranceItem(record, this.screenPropertyRecord.FireInsurancePlan));
            }
            // 選択加入期間、プラン詳細を設定
            this.fireInsuranceItemPaymentYear = '';
            this.fireInsuranceItemDetail = '';
            for (ScreenFireInsuranceItem record : this.fireInsuranceItemList) {
                if (record.IsChecked) {
                    this.fireInsuranceItemPaymentYear = record.PaymentYear;
                    this.fireInsuranceItemDetail = record.Detail;
                }
            }
            // 保証商品リスト
            this.guaranteePlanItemList = new List<ScreenGuaranteePlanItem>();
            for (InsuranceGuarantee__c record : selectGuaranteePlanItem(this.screenPropertyRecord.FormerSupplierId)) {
                this.guaranteePlanItemList.add(new ScreenGuaranteePlanItem(record, this.screenPropertyRecord.Guaranteeid));
            }
            // 管理会社指定商品リスト
            this.managementCompanyItemList = new List<ScreenManagementCompanyItem>();
            for (ManagementCompanyItem__c record : selectManagementCompanyItem(this.propertyId, this.screenPropertyRecord.FormerSupplierId)) {
                this.managementCompanyItemList.add(new ScreenManagementCompanyItem(record));
            }
            // 選択保証プラン詳細を設定
            this.managementCompanyItemAllDetail = '';
            for (ScreenManagementCompanyItem record : this.managementCompanyItemList) {
                if (record.IsChecked) {
                    if (!String.isEmpty(managementCompanyItemAllDetail)) {
                        managementCompanyItemAllDetail += '  /  ';
                    }
                    managementCompanyItemAllDetail += record.Detail;
                }
            }

        } else if (this.currentGD301003ModalMode == GD301003ParameterClass.SupplierConst.CREDITOR) {
            // 貸主情報
            this.screenPropertyRecord.CreditorId                    = acc.Id;                       // 貸主Id
            this.screenPropertyRecord.CreditorName                  = acc.Name;                     // 貸主名
            this.screenPropertyRecord.CreditorPhone                 = acc.Phone;                    // 貸主電話番号
            this.screenPropertyRecord.CreditorFax                   = acc.Fax;                      // 貸主Fax
            this.screenPropertyRecord.CreditorPostalCode            = acc.PostalCode__c;            // 貸主郵便番号
            this.screenPropertyRecord.CreditorAddress               = acc.Address__c;               // 貸主住所
            this.screenPropertyRecord.CreditorState                 = acc.State__c;                 // 貸主都道府県
            this.screenPropertyRecord.CreditorCity                  = acc.City__c;                  // 貸主住所１（市区町村）
            this.screenPropertyRecord.CreditorStreet                = acc.Street__c;                // 貸主住所２（番地）
            this.screenPropertyRecord.CreditorEmail                 = acc.Email__c;                 // 貸主メール
            this.screenPropertyRecord.CreditorRepresentative        = acc.Representative__c;        // 貸主担当者
            this.screenPropertyRecord.CreditorRepresentativePhone   = acc.RepresentativePhone__c;   // 貸主担当者電話番号
            this.screenPropertyRecord.CreditorRemarks               = acc.RemarksPublic__c;         // 貸主備考
            this.screenPropertyRecord.CreditorIsMergeCompletedFlag  = acc.IsMergeCompletedFlag__c;  // 貸主名寄せ完了フラグ

        } else if (this.currentGD301003ModalMode == GD301003ParameterClass.SupplierConst.OWNER) {
            // 所有者情報
            this.screenPropertyRecord.OwnerId                       = acc.Id;                       // 所有者Id
            this.screenPropertyRecord.OwnerName                     = acc.Name;                     // 所有者名
            this.screenPropertyRecord.OwnerPhone                    = acc.Phone;                    // 所有者電話番号
            this.screenPropertyRecord.OwnerFax                      = acc.Fax;                      // 所有者Fax
            this.screenPropertyRecord.OwnerPostalCode               = acc.PostalCode__c;            // 所有者郵便番号
            this.screenPropertyRecord.OwnerAddress                  = acc.Address__c;               // 所有者住所
            this.screenPropertyRecord.OwnerState                    = acc.State__c;                 // 所有者都道府県
            this.screenPropertyRecord.OwnerCity                     = acc.City__c;                  // 所有者住所１（市区町村）
            this.screenPropertyRecord.OwnerStreet                   = acc.Street__c;                // 所有者住所２（番地）
            this.screenPropertyRecord.OwnerEmail                    = acc.Email__c;                 // 所有者メール
            this.screenPropertyRecord.OwnerRepresentative           = acc.Representative__c;        // 所有者担当者
            this.screenPropertyRecord.OwnerRepresentativePhone      = acc.RepresentativePhone__c;   // 所有者担当者電話番号
            this.screenPropertyRecord.OwnerRemarks                  = acc.RemarksPublic__c;         // 所有者備考
            this.screenPropertyRecord.OwnerIsMergeCompletedFlag     = acc.IsMergeCompletedFlag__c;  // 所有者名寄せ完了フラグ

        }
    }
    
    //▼問合せ291で変更
    /**
     * 地図を表示ボタン 押下
     *  物件MAP照会画面への遷移準備処理
     * @param  なし
     * @return なし
     */
    public void createPropertyMapParameter() {
        try {
            // 物件MAP照会へのパラメータ引渡用のレコードを作成する
            PropertyMapParameter__c propMapParam = new PropertyMapParameter__c(
                PropertyIdList__c = propertyId
            );
            SecureDML.secureInsert(propMapParam);
 
            // パラメータをPage公開用の変数に設定
            this.GA104002Parameter = 'isClient=false';
            this.GA104002Parameter += '&propertyMapParamId=' + propMapParam.Id;
 
        } catch(Exception e) {
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    //▲問合せ291で変更
    
    // 文例選択モーダル分岐の列挙
    private enum ExampleSentenceSelect {
        HOMESPROPERTYFEATURE
        ,SUUMONETCATCH
        ,SUUMONETCATCHCOMMENT
        ,ATHOMERECOMMENDCOMMENT
        ,CHINTAIMAGAZINECOMMENT	// 2022.03.25 CHINTAI対応追加
    }
    private ExampleSentenceSelect currentExampleSentenceSelect { get; set; } // 文例分岐管理項目
    
    // 文例選択モーダル起動(HOME'S物件の特徴)
    public void openHomesPropertyFeatureExampleSentenceSelect() {
        openExampleSentenceSelect('HOME\'S物件の特徴', 100);
        this.currentExampleSentenceSelect = ExampleSentenceSelect.HOMESPROPERTYFEATURE;
    }
    // 文例選択モーダル起動(SUUMOネット用キャッチ)
    public void openSuumoNetCatchExampleSentenceSelect() {
        openExampleSentenceSelect('SUUMOネット用キャッチ', 30);
        this.currentExampleSentenceSelect = ExampleSentenceSelect.SUUMONETCATCH;
    }
    // 文例選択モーダル起動(SUUMOネット用キャッチコメント)
    public void openSuumoNetCatchCommentExampleSentenceSelect() {
        openExampleSentenceSelect('SUUMOネット用キャッチコメント', 100);
        this.currentExampleSentenceSelect = ExampleSentenceSelect.SUUMONETCATCHCOMMENT;
    }
    // 文例選択モーダル起動(at homeおすすめコメント)
    public void openAthomeRecommendCommentExampleSentenceSelect() {
        openExampleSentenceSelect('at homeおすすめコメント', 200);
        this.currentExampleSentenceSelect = ExampleSentenceSelect.ATHOMERECOMMENDCOMMENT;
    }
	// ▼ CHINTAI 2022.03.25　CHINTAI対応追加　文例選択モーダル起動(CHINTAI雑誌コメント)
    public void openChintaiMagazineCommentExampleSentenceSelect() {
        openExampleSentenceSelect('CHINTAI雑誌コメント', 160);
        this.currentExampleSentenceSelect = ExampleSentenceSelect.CHINTAIMAGAZINECOMMENT;
    }
	// ▲ CHINTAI 2022.03.25　CHINTAI対応追加　文例選択モーダル起動(CHINTAI雑誌コメント)
    // 文例選択モーダル起動
    public void openExampleSentenceSelect(String itemName, Integer itemMaxLength) {
        this.GA104006Modal2Parameter = new GA104006Modal2ParameterClass();
        this.GA104006Modal2Parameter.returnItem = itemName;
        this.GA104006Modal2Parameter.returnItemMaxLength = itemMaxLength;
        this.GA104006Modal2Parameter.isDrawing = true;
        this.GA104006Modal2Parameter.noFirst = true;
    }
    // 文例選択モーダル終了
    public void closeExampleSentenceSelect() {
        String temp = this.GA104006Modal2Parameter.exampleSentence;
        Integer maxLength = this.GA104006Modal2Parameter.returnItemMaxLength;
        if (this.currentExampleSentenceSelect == ExampleSentenceSelect.HOMESPROPERTYFEATURE) {
            // HOME'S物件の特徴
            this.screenPropertyRecord.HomesPropertyFeatureOrg = this.GA104006Modal2Parameter.Id;
            this.screenPropertyRecord.HomesPropertyFeature = temp.substring(0, temp.length() > maxLength ? maxLength : temp.length());
        } else if (this.currentExampleSentenceSelect == ExampleSentenceSelect.SUUMONETCATCH) {
            // SUUMOネット用キャッチ
            this.screenPropertyRecord.SuumoNetCatchOrg = this.GA104006Modal2Parameter.Id;
            this.screenPropertyRecord.SuumoNetCatch = temp.substring(0, temp.length() > maxLength ? maxLength : temp.length());
            //▼問合せ370で変更
            this.screenPropertyRecord.AthomeRecommendCommentOrg = this.GA104006Modal2Parameter.Id;
            this.screenPropertyRecord.AthomeRecommendComment = this.screenPropertyRecord.SuumoNetCatch;
            this.screenPropertyRecord.HomesPropertyFeatureOrg = this.GA104006Modal2Parameter.Id;
            this.screenPropertyRecord.HomesPropertyFeature = this.screenPropertyRecord.SuumoNetCatch;
            //▲問合せ370で変更
			this.screenPropertyRecord.ChintaiMagazineCommentOrg = this.GA104006Modal2Parameter.Id;	// 2022.03.25　CHINTAI対応追加
			this.screenPropertyRecord.ChintaiMagazineComment = this.screenPropertyRecord.SuumoNetCatch;	// 2022.03.25　CHINTAI対応追加
        } else if (this.currentExampleSentenceSelect == ExampleSentenceSelect.SUUMONETCATCHCOMMENT) {
            // SUUMOネット用キャッチコメント
            this.screenPropertyRecord.SuumoNetCatchCommentOrg = this.GA104006Modal2Parameter.Id;
            this.screenPropertyRecord.SuumoNetCatchComment = temp.substring(0, temp.length() > maxLength ? maxLength : temp.length());
        } else if (this.currentExampleSentenceSelect == ExampleSentenceSelect.ATHOMERECOMMENDCOMMENT) {
            // at homeおすすめコメント
            this.screenPropertyRecord.AthomeRecommendCommentOrg = this.GA104006Modal2Parameter.Id;
            this.screenPropertyRecord.AthomeRecommendComment = temp.substring(0, temp.length() > maxLength ? maxLength : temp.length());
		} 
		// ▼ CHINTAI 2022.03.25　CHINTAI対応追加
		else if (this.currentExampleSentenceSelect == ExampleSentenceSelect.CHINTAIMAGAZINECOMMENT) {
			// CHINTAI雑誌コメント
			this.screenPropertyRecord.ChintaiMagazineCommentOrg = this.GA104006Modal2Parameter.Id;
			this.screenPropertyRecord.ChintaiMagazineComment = temp.substring(0, temp.length() > maxLength ? maxLength : temp.length());
		}
		// ▲ CHINTAI 2022.03.25　CHINTAI対応追加
    }
    //ポータルサイト構築 追加 Start
    //おすすめ物件モーダル起動
    public void openRecommendPropertyRegistration(){
        this.GA104006Modal3Parameter = new GA104006Modal3ParameterClass();
        this.GA104006Modal3Parameter.buildingId = this.buildingId;
        this.GA104006Modal3Parameter.propertyId = this.propertyId;
        this.GA104006Modal3Parameter.propertyCode = this.screenPropertyRecord.PropertyCode;
        this.GA104006Modal3Parameter.recoPro = this.recoPro;
        this.GA104006Modal3Parameter.isDrawing = true;
        this.GA104006Modal3Parameter.noFirst = true;
        this.GA104006Modal3Parameter.IsUpsertDB = false;
        //再販対応 追加 Start
        this.GA104006Modal3Parameter.isUseAuthorityPanoramaTour = this.isUseAuthorityPanoramaTour;
        //再販対応 追加 End
    }
    
    // おすすめ物件モーダル終了
    public void closeRecommendPropertyRegistration() {
        if (this.GA104006Modal3Parameter != null){
            if (this.GA104006Modal3Parameter.recoPro != null){
                this.recoPro = this.GA104006Modal3Parameter.recoPro;
            }
        }   
        // おすすめ物件変更フラグを立てる
        this.isRecommendProperty = true;    //問合せNo0598で追加

    }
    //ポータルサイト構築 追加 End

    // 物件メンテナンス履歴モーダル起動
    public void openPropertyHistoryModal(){
        this.GA104006Modal4Parameter = new GA104006Modal4ParameterClass();
        this.GA104006Modal4Parameter.isDrawing = true;
        this.GA104006Modal4Parameter.noFirst = true;
        this.GA104006Modal4Parameter.propertyMaintenanceHistoryList = this.propertyMaintenanceHistoryList;
    }

    // キャンセルボタン押下処理
    public void clickCancelButton() {
        try {
            this.hasErrorMessage = false;
            // 物件コピーモードの解除
            this.isCopy = false;
            this.isInsert = false;
            // web公開を物件コピー押下前の値に変更
            this.screenPropertyRecord.WebPublishing = this.copyPrevWebPublishing;
            //▼問合せNo0539で追加
            this.screenPropertyRecord.ImportType                = this.copyPrevImportType;                      // 取込先
            this.screenPropertyRecord.initialInportType         = this.copyPrevImportType;                      // 画面初期表示時取込区分
            this.screenPropertyRecord.MaintenancePropertyCode   = this.copyPrevMaintenancePropertyCode;         // メンテナンス物件コード
            this.screenPropertyRecord.ManualMaintenanceDate     = this.copyPrevManualMaintenanceDate;           // 手動最終メンテナンス日
            this.screenPropertyRecord.AutoMaintenanceDate       = this.copyPrevAutoMaintenanceDate;             // 自動最終メンテナンス日
            this.screenPropertyRecord.RealnetproURL             = this.copyPrevRealnetproURL;                   // リアプロURL
            this.screenPropertyRecord.DaiwalivingURL            = this.copyPrevDaiwalivingURL;                  // 大和リビングURL
            //▲問合せNo0539で追加

            // 間取り図コピーの項目を初期化
            this.fromforeignId = '';
            this.floorplanPhotoFileName = '';
            this.floorplanPhotoMemoFileName = '';
            this.isRoomLayoutCopy =false;
            //▼問合せNo0598で追加
            this.isRecommendProperty = this.isRecommendPropertyCopy;        //コピー時のおすすめ物件変更フラグを戻す 
            this.isRecommendPropertyCopy = false;
            //▲問合せNo0598で追加
            // 物件メンテナンス履歴リスト再取得
            this.propertyMaintenanceHistoryList = selectPropertyMaintenanceHistory(this.propertyId);
        } catch(Exception e) {
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    
    // 保存完了後、間取り図アップロード処理（間取り図コピーフラグがある場合のみ）
    public void saveFinish(){
        List<String> fromPathList = new List<String>();     // コピー元ファイルパス 
        List<String> toPathList = new List<String>();      // コピー先ファイルパス
        // 間取り図ファイル名が存在する。
        if(String.isnotBlank(this.floorplanPhotoFileName)){
            String fromPath = this.floorplanPhotoData.buildingForeignId + '/'+
                                this.fromforeignId+ '/' +
                                this.floorplanPhotoFileName;

            String toPath = this.floorplanPhotoData.buildingForeignId + '/' +
                            this.screenPropertyRecord.ForeignID + '/' +
                            this.floorplanPhotoFileName;

            // 間取り図ファイルのコピーデータ作成。
            fromPathList.add(fromPath);
            toPathList.add(toPath);

            // 間取り図位置情報のコピー用データ作成。
            AmazonS3Util.extensionConvertJson(fromPathList,fromPath);
            AmazonS3Util.extensionConvertJson(toPathList,toPath);
            
        }

        // 間取り図メモファイル名が存在する。
        if(String.isnotBlank(this.floorplanPhotoMemoFileName)){
            String fromPathMemo = this.floorplanPhotoData.buildingForeignId + '/' +
                                  this.fromforeignId +'/' +
                                  this.floorplanPhotoMemoFileName;
            String toPathMemo = this.floorplanPhotoData.buildingForeignId + '/' +
                                this.screenPropertyRecord.ForeignID + '/' +
                                this.floorplanPhotoMemoFileName;
            
            fromPathList.add(fromPathMemo);
            toPathList.add(toPathMemo);
        }

        if(fromPathList.size() > 0){
            // S3にファイルコピー
            AmazonS3Util.callS3MoveNonDBUpdate(fromPathList,toPathList);

            // S3にファイルコピー完了後間取り図の再取得
            // 間取り図情報の再読み込み
            this.setFloorplanPhotoList();

            // 間取り図コピーの項目を初期化
            this.fromforeignId = '';
            this.floorplanPhotoFileName = '';
            this.floorplanPhotoMemoFileName = '';
            this.isRoomLayoutCopy = false;
        }
    }

    // 保存ボタン押下処理
    public void clickSaveButton() {
        this.saveButton(false);
    }
    // 一時保存ボタン押下処理
    public void clickTempSaveButton() {
        this.saveButton(true);
    }

    /**
     * メンテナンス物件コード履歴の削除
     */
    public void delPropertyCdHist() {

        this.hasErrorMessage = false;
        Savepoint sp = Database.setsavepoint();
    
        try {
            //  メンテナンス物件コード履歴の削除リストを取得
            List<PropertyCodeHistory__c> delList = new List<PropertyCodeHistory__c>();
            for (ScreenPropertyCdHist detail : this.screenPropertyCdHistList) {
                if (detail.isSelected){
                    delList.add(detail.Entity);
                }
            }
        
            // 楽観ロックチェック
            if (!CommonUtil.isOptimisticLock(delList)) {
                throw new OptimisticLockException();
            }
            
            // メンテナンス物件コード履歴の削除
            if (delList.size() > 0) {
                SecureDML.secureDelete(delList);
            }
            
            // メンテナンス物件コード履歴の設定
            this.setPropertyCdHist(this.propertyId);
        
        } catch(Exception e) {
            database.rollback(sp);
            this.hasErrorMessage = True;
            CommonUtil.setErrorMessage(e);
        }
    }

    // 保存・一時保存時処理
    private void saveButton(Boolean isTempSave) {
        Savepoint sp = Database.setSavepoint(); // セーブポイント作成
        try {
            // 新規登録フラグ設定
            //▼問合せNo0531で変更
            this.isInsert = this.isNew || this.isCopy;
            //▲問合せNo0531で変更
            // エラーフラグ初期化
            this.hasErrorMessage = false;

            // 現在日付
            DateTime toDate = CommonUtil.getToday();
            // 現在日時
            DateTime nowDateTime = CommonUtil.getNow();

            // 画面 料金情報取得
            getFeeTabInput(this.screenPropertyRecord);
            // 画面 画像情報取得
            PropertyPhoto__c propPhoto = new PropertyPhoto__c();
            if (!this.isCopy) {
                propPhoto.Id = this.screenPropertyRecord.PropertyPhotoId;
                propPhoto.RoomLayoutFileName__c = this.floorplanPhotoData.photoDataList[0].FileName;
                for (PhotoData photo : this.publicPhotoData.photoDataList) {
                    propPhoto.put('PropertyPhotoFileName' + photo.Index + '__c', photo.FileName);
                    propPhoto.put('PropertyPhotoComment' + photo.Index + '__c', photo.Comment);
                    propPhoto.put('PropertyPhotoTag' + photo.Index + '__c', photo.Tag);
                }
                for (PhotoData photo : this.privatePhotoData.photoDataList) {
                    propPhoto.put('PrivatePhotoFileName' + photo.Index + '__c', photo.FileName);
                    propPhoto.put('PrivatePhotoComment' + photo.Index + '__c', photo.Comment);
                    propPhoto.put('PrivatePhotoType' + photo.Index + '__c', photo.Tag);
                }
                for (PhotoData photo : this.panoramaPhotoData.photoDataList) {
                    propPhoto.put('PanoramaFileName' + photo.Index + '__c', photo.FileName);
                    propPhoto.put('PanoramaComment' + photo.Index + '__c', photo.Comment);
                    propPhoto.put('PanoramaTag' + photo.Index + '__c', photo.Tag);
                }
            }else{
                this.fromforeignId = this.floorplanPhotoData.foreignId;         // コピー元の物件外部IDを保持
                // 物件コピー時、コピー元の間取り図ファイル名（メモがあればメモも同様）セットする。
                if(this.floorplanPhotoData.photoCount > 0){
                    propPhoto.RoomLayoutFileName__c = this.floorplanPhotoData.photoDataList[0].FileName;
                    this.floorplanPhotoFileName = this.floorplanPhotoData.photoDataList[0].FileName;
                    this.isRoomLayoutCopy = true;
                }
                if(this.floorplanPhotoMemoData.photoCount > 0){
                    propPhoto.RoomLayoutMemoFileName__c = this.floorplanPhotoMemoData.photoDataList[0].FileName;
                    this.floorplanPhotoMemoFileName = this.floorplanPhotoMemoData.photoDataList[0].FileName;
                    this.isRoomLayoutCopy = true;
                }
            }

            // 建物情報再取得
            this.buildingRecord = selectBuilding(this.buildingId);

            // 入力チェック
            BusinessLogicException ex = new BusinessLogicException();
            ex = this.checkInput(ex, isTempSave);

            // 入力チェック結果にエラーがある場合、例外をスローさせる
            if (ex.hasMessage()){ 
                throw ex;
            }

            // 楽観ロックチェック（新規登録・物件コピーでない場合）
            if (!isInsert) {
                List<Property__c> checkProp = [
                    SELECT
                        Id
                    FROM Property__c
                    WHERE
                        id = :this.screenPropertyRecord.Id
                    AND SystemModStamp = :this.screenPropertyRecord.SystemModStamp
                ];
                if (checkProp.isEmpty()) {
                    throw new OptimisticLockException();
                }
            }

            // 保存処理
            // 物件
            Property__c prop = new Property__c();
            if (!isInsert) {
                prop.Id = this.screenPropertyRecord.Id;
            }
            // prop.PropertyCode__c                            = this.screenPropertyRecord.PropertyCode;                               // 物件コード
            prop.Building__c                                = this.buildingRecord.Id;                                               // 建物
            prop.Name                                       = this.screenPropertyRecord.Name;                                       // 部屋番号
            prop.Floor__c                                   = CommonUtil.stringToDecimal(this.screenPropertyRecord.Floor);          // 所在階
            prop.FloorType__c                               = this.screenPropertyRecord.FloorType;                                  // 地下階区分
            prop.RoomCount__c                               = CommonUtil.stringToDecimal(this.screenPropertyRecord.RoomCount);      // 部屋数
            prop.RoomLayout__c                              = this.screenPropertyRecord.RoomLayout;                                 // 間取り
            prop.RoomArea__c                                = CommonUtil.stringToDecimal(this.screenPropertyRecord.RoomArea);       // 専有面積（㎡）
            prop.BalconyDirection__c                        = this.screenPropertyRecord.BalconyDirection;                           // バルコニー方向
            prop.BalconyArea__c                             = CommonUtil.stringToDecimal(this.screenPropertyRecord.BalconyArea);    // バルコニー面積
            prop.IsOwnCompanyPropertyFlag__c                = this.screenPropertyRecord.IsOwnCompanyPropertyFlag;                   // 自社物フラグ
            prop.LiveStatus__c                              = this.screenPropertyRecord.LiveStatus;                                 // 現況
            prop.DeliveryType__c                            = this.screenPropertyRecord.DeliveryType;                               // 引渡種別
            prop.DeliveryYear__c                            = this.screenPropertyRecord.DeliveryYear;                               // 引渡年
            prop.DeliveryMonth__c                           = this.screenPropertyRecord.DeliveryMonth;                              // 引渡月
            prop.DeliveryTiming__c                          = this.screenPropertyRecord.DeliveryTiming;                             // 引渡旬
            prop.DeliveryDay__c                             = this.screenPropertyRecord.DeliveryDay;                                // 引渡日
            prop.LivedType__c                               = this.screenPropertyRecord.LivedType;                                  // 未入居種別
            prop.ContractTermYear__c                        = CommonUtil.stringToDecimal(this.screenPropertyRecord.ContractTermYear);   // 契約期間（年）
            prop.ContractTermMonth__c                       = CommonUtil.stringToDecimal(this.screenPropertyRecord.ContractTermMonth);  // 契約期間（月）
            prop.TransactionAspect__c                       = this.screenPropertyRecord.TransactionAspect;                          // 取引態様
            prop.DeliveryConsultation__c                    = this.screenPropertyRecord.DeliveryConsultation;                       // 引渡・入居日（相談内容）
            prop.RentType__c                                = this.screenPropertyRecord.RentType;                                   // 定期借家区分
            prop.RentTermYear__c                            = CommonUtil.stringToDecimal(this.screenPropertyRecord.RentTermYear);   // 定借期間（年）
            prop.RentTermMonth__c                           = CommonUtil.stringToDecimal(this.screenPropertyRecord.RentTermMonth);  // 定借期間（月）
            prop.RentTermDay__c                             = CommonUtil.stringToDecimal(this.screenPropertyRecord.RentTermDay);    // 定借期間（日）
            prop.RenovationComplateYear__c                  = CommonUtil.stringToDecimal(this.screenPropertyRecord.RenovationComplateYear);                     // リノベ施工完了（年）
            prop.RenovationComplateMonth__c                 = CommonUtil.stringToDecimal(this.screenPropertyRecord.RenovationComplateMonth);                    // リノベ施工完了（月）
            prop.RenovationContent__c                       = this.screenPropertyRecord.RenovationContent;                                                      // リノベ施工内容
            prop.FreeRentTermMonth__c                       = CommonUtil.stringToDecimal(this.screenPropertyRecord.FreeRentTermMonth);                          // フリーレント期間（ヶ月）
            prop.FreeRentContent__c                         = this.screenPropertyRecord.FreeRentContent;                                                        // フリーレント内容
            prop.SpecificExcellentRentBurdenUpperLimit__c   = CommonUtil.stringToDecimal(this.screenPropertyRecord.SpecificExcellentRentBurdenUpperLimit);      // 特優賃入居負担額上限
            prop.SpecificExcellentRentBurdenLowerLimit__c   = CommonUtil.stringToDecimal(this.screenPropertyRecord.SpecificExcellentRentBurdenLowerLimit);      // 特優賃入居負担額下限
            prop.SpecificExcellentRentFeeFluctuationType__c = this.screenPropertyRecord.SpecificExcellentRentFeeFluctuationType;                                // 特優賃料金変動区分
            prop.SpecificExcellentRentFeeUpwardRate__c      = CommonUtil.stringToDecimal(this.screenPropertyRecord.SpecificExcellentRentFeeUpwardRate);         // 特優賃上昇率
            prop.SpecificExcellentRentSupportYears__c       = CommonUtil.stringToDecimal(this.screenPropertyRecord.SpecificExcellentRentSupportYears);          // 特優賃家賃補助年数
            prop.SpecificExcellentRentRemarks__c            = this.screenPropertyRecord.SpecificExcellentRentRemarks;               // 特優賃備考
            prop.PropertyRemarksPublic__c                   = this.screenPropertyRecord.PropertyRemarksPublic;                      // 物件備考（公開）
            // prop.PropertyRemarksPrivate__c                  = this.screenPropertyRecord.PropertyRemarksPrivate;                     // 物件備考（非公開）
            prop.PropertyComment__c                         = this.screenPropertyRecord.PropertyComment;                            // 物件コメント
            prop.RepresentativeComment__c                   = this.screenPropertyRecord.RepresentativeComment;                      // 担当者コメント
            prop.RentFee__c                                 = CommonUtil.stringToDecimal(this.screenPropertyRecord.RentFee);                                    // 賃料
            prop.WortFee__c                                 = CommonUtil.stringToDecimal(this.screenPropertyRecord.WortFee);                                    // 水道料金
            prop.WortFeeTaxType__c                          = prop.WortFee__c == null ? '' : this.screenPropertyRecord.WortFeeTaxType;                          // 水道料金税区分
            prop.SecurityDepositYen__c                      = CommonUtil.stringToDecimal(this.screenPropertyRecord.SecurityDepositYen);                         // 敷金（円）
            prop.SecurityDepositMonth__c                    = CommonUtil.stringToDecimal(this.screenPropertyRecord.SecurityDepositMonth);                       // 敷金（ヵ月）
            prop.SecurityDepositUnit__c                     = screenPropertyRecord.SecurityDepositUnit;                             // 敷金単位
            prop.CancellationActualFeeYen__c                = CommonUtil.stringToDecimal(this.screenPropertyRecord.CancellationActualFeeYen);                   // 敷引・償却（円）
            prop.CancellationActualFeeMonth__c              = CommonUtil.stringToDecimal(this.screenPropertyRecord.CancellationActualFeeMonth);                 // 敷引・償却（ヵ月）
            prop.CancellationActualFeeRate__c               = CommonUtil.stringToDecimal(this.screenPropertyRecord.CancellationActualFeeRate);                  // 敷引・償却（％）
            prop.CancellationActualFeeUnit__c               = this.screenPropertyRecord.CancellationActualFeeUnit;                  // 敷引・償却単位
            prop.ManagementFee__c                           = CommonUtil.stringToDecimal(this.screenPropertyRecord.ManagementFee);                              // 管理費
            prop.ManagementFeeTaxType__c                    = prop.ManagementFee__c == null ? '' : this.screenPropertyRecord.ManagementFeeTaxType;              // 管理費税区分
            prop.CATVFee__c                                 = CommonUtil.stringToDecimal(this.screenPropertyRecord.CATVFee);                                    // CATV
            prop.CATVTaxType__c                             = prop.CATVFee__c == null ? '' : this.screenPropertyRecord.CATVTaxType;                             // CATV税区分
            prop.DepositYen__c                              = CommonUtil.stringToDecimal(this.screenPropertyRecord.DepositYen);                                 // 保証料金（円）
            prop.DepositMonth__c                            = CommonUtil.stringToDecimal(this.screenPropertyRecord.DepositMonth);                               // 保証料金（ヵ月）
            prop.DepositUnit__c                             = this.screenPropertyRecord.DepositUnit;                                // 保証金単位
            prop.RenewalFeeYen__c                           = CommonUtil.stringToDecimal(this.screenPropertyRecord.RenewalFeeYen);                              // 更新料（円）
            prop.RenewalFeeMonth__c                         = CommonUtil.stringToDecimal(this.screenPropertyRecord.RenewalFeeMonth);                            // 更新料（ヵ月）
            prop.RenewalFeeTaxType__c                       = prop.RenewalFeeYen__c == null ? '' : this.screenPropertyRecord.RenewalFeeTaxType;                 // 更新料税区分
            prop.RenewalFeeUnit__c                          = this.screenPropertyRecord.RenewalFeeUnit;                             // 更新料単位
            prop.TownshipFee__c                             = CommonUtil.stringToDecimal(this.screenPropertyRecord.TownshipFee);                                // 町会費
            prop.TownshipFeeTaxType__c                      = prop.TownshipFee__c == null ? '' : this.screenPropertyRecord.TownshipFeeTaxType;                  // 町会費税区分
            prop.TownshipFeePaymentType__c                  = prop.TownshipFee__c == null ? '' : this.screenPropertyRecord.TownshipFeePaymentType;              // 町会費支払区分
            prop.GarbageDisposalFee__c                      = CommonUtil.stringToDecimal(this.screenPropertyRecord.GarbageDisposalFee);                         // ゴミ処理費
            prop.GarbageDisposalFeeTaxType__c               = prop.GarbageDisposalFee__c == null ? '' : this.screenPropertyRecord.GarbageDisposalFeeTaxType;    // ゴミ処理費税区分
            prop.GarbageDisposalFeePaymentType__c           = prop.GarbageDisposalFee__c == null ? '' : this.screenPropertyRecord.GarbageDisposalFeePaymentType;// ゴミ処理費支払区分
            prop.KeyMoneyYen__c                             = CommonUtil.stringToDecimal(this.screenPropertyRecord.KeyMoneyYen);                                // 礼金（円）
            prop.KeyMoneyMonth__c                           = CommonUtil.stringToDecimal(this.screenPropertyRecord.KeyMoneyMonth);                              // 礼金（ヵ月）
            prop.KeyMoneyUnit__c                            = this.screenPropertyRecord.KeyMoneyUnit;                               // 礼金単位
            prop.TownshipInitialFee__c                      = CommonUtil.stringToDecimal(this.screenPropertyRecord.TownshipInitialFee);                         // 入町費
            prop.TownshipInitialFeeTaxType__c               = prop.TownshipInitialFee__c == null ? '' : this.screenPropertyRecord.TownshipInitialFeeTaxType;    // 入町費税区分
            prop.CleaningFeeYen__c                          = CommonUtil.stringToDecimal(this.screenPropertyRecord.CleaningFeeYen);                             // 定額修繕費（円）
            prop.CleaningFeeMonth__c                        = CommonUtil.stringToDecimal(this.screenPropertyRecord.CleaningFeeMonth);                           // 定額修繕費（ヵ月）
            prop.CleaningFeeTaxType__c                      = prop.CleaningFeeYen__c == null ? '' : this.screenPropertyRecord.CleaningFeeTaxType;               // 定額修繕費税区分
            prop.CleaningFeePaymentType__c                  = prop.CleaningFeeYen__c == null ? '' : this.screenPropertyRecord.CleaningFeePaymentType;           // 定額修繕費支払区分
            prop.CleaningFeeUnit__c                         = this.screenPropertyRecord.CleaningFeeUnit;                            // 定額修繕費単位
            prop.KeyExchangeFee__c                          = CommonUtil.stringToDecimal(this.screenPropertyRecord.KeyExchangeFee);                             // 鍵交換費
            prop.KeyExchangeFeeTaxType__c                   = prop.KeyExchangeFee__c == null ? '' : this.screenPropertyRecord.KeyExchangeFeeTaxType;            // 鍵交換費税区分
            prop.MonetaryPublic__c                          = this.screenPropertyRecord.MonetaryPublic;                             // 金銭備考（公開）
            // prop.MonetaryPrivate__c                         = this.screenPropertyRecord.MonetaryPrivate;                            // 金銭備考（非公開）
            prop.BicycleParkingType__c                      = this.screenPropertyRecord.BicycleParkingType;                         // 駐輪場種別
            prop.BicycleParkingFee__c                       = CommonUtil.stringToDecimal(this.screenPropertyRecord.BicycleParkingFee);                          // 駐輪場代
            prop.BicycleParkingFeeTaxType__c                = prop.BicycleParkingFee__c == null ? '' : this.screenPropertyRecord.BicycleParkingFeeTaxType;      // 駐輪場代税区分
            prop.ParkingType__c                             = this.screenPropertyRecord.ParkingType;                                // 駐車場種別
            prop.ParkingDistance__c                         = CommonUtil.stringToDecimal(this.screenPropertyRecord.ParkingDistance);                            // 近隣駐車場までの距離
            prop.ParkingFee__c                              = CommonUtil.stringToDecimal(this.screenPropertyRecord.ParkingFee);                                 // 駐車場料金
            prop.ParkingFeeTaxType__c                       = prop.ParkingFee__c == null ? '' : this.screenPropertyRecord.ParkingFeeTaxType;                    // 駐車場料金税区分
            prop.ParkingDepositYen__c                       = CommonUtil.stringToDecimal(this.screenPropertyRecord.ParkingDepositYen);                          // 駐車場保証料金
            prop.ParkingDepositMonth__c                     = CommonUtil.stringToDecimal(this.screenPropertyRecord.ParkingDepositMonth);                        // 駐車場保証料金（ヵ月）
            prop.ParkingDepositTaxType__c                   = prop.ParkingDepositYen__c == null ? '' : this.screenPropertyRecord.ParkingDepositTaxType;         // 駐車場保証料金税区分
            prop.ParkingDepositUnit__c                      = this.screenPropertyRecord.ParkingDepositUnit;                         // 駐車場保証料金単位
            prop.ParkingCompoundingFeeYen__c                = CommonUtil.stringToDecimal(this.screenPropertyRecord.ParkingCompoundingFeeYen);                   // 駐車場手数料（円）
            prop.ParkingCompoundingFeeMonth__c              = CommonUtil.stringToDecimal(this.screenPropertyRecord.ParkingCompoundingFeeMonth);                 // 駐車場手数料（ヵ月）
            prop.ParkingCompoundingFeeTaxType__c            = prop.ParkingCompoundingFeeYen__c == null ? '' : this.screenPropertyRecord.ParkingCompoundingFeeTaxType;   // 駐車場手数料税区分
            prop.ParkingCompoundingFeeUnit__c               = this.screenPropertyRecord.ParkingCompoundingFeeUnit;                  // 駐車場手数料単位
            prop.ParkingRemarksPublic__c                    = this.screenPropertyRecord.ParkingRemarksPublic;                       // 駐車場備考（公開）
            // prop.ParkingRemarksPrivate__c                   = this.screenPropertyRecord.ParkingRemarksPrivate;                      // 駐車場備考（非公開）
            prop.BikeStorageType__c                         = this.screenPropertyRecord.BikeStorageType;                            // バイク置場種別
            prop.BikeParkingSmallFee__c                     = CommonUtil.stringToDecimal(this.screenPropertyRecord.BikeParkingSmallFee);                        // 小型バイク置場料金
            prop.BikeParkingSmallFeeTaxType__c              = prop.BikeParkingSmallFee__c == null ? '' : this.screenPropertyRecord.BikeParkingSmallFeeTaxType;  // 小型バイク置場料金税区分
            prop.BikeParkingMediumFee__c                    = CommonUtil.stringToDecimal(this.screenPropertyRecord.BikeParkingMediumFee);                       // 中型バイク置場料金
            prop.BikeParkingMediumFeeTaxType__c             = prop.BikeParkingMediumFee__c == null ? '' : this.screenPropertyRecord.BikeParkingMediumFeeTaxType;// 中型バイク置場料金税区分
            prop.BikeParkinLargeFee__c                      = CommonUtil.stringToDecimal(this.screenPropertyRecord.BikeParkinLargeFee);                         // 大型バイク置場料金
            prop.BikeParkinLargeFeeTaxType__c               = prop.BikeParkinLargeFee__c == null ? '' : this.screenPropertyRecord.BikeParkinLargeFeeTaxType;    // 大型バイク置場料金税区分
            prop.IsShortTermPenalty__c                      = this.screenPropertyRecord.IsShortTermPenalty;                         // 短期解約違約金有無
            prop.ShortTermPenaltyLessYear__c                = CommonUtil.stringToDecimal(this.screenPropertyRecord.ShortTermPenaltyLessYear);                   // 短期解約違約金未満（年）
            prop.ShortTermPenaltyFee__c                     = CommonUtil.stringToDecimal(this.screenPropertyRecord.ShortTermPenaltyFee);                        // 短期解約違約金
            prop.ShortTermPenaltyLessYear2__c               = CommonUtil.stringToDecimal(this.screenPropertyRecord.ShortTermPenaltyLessYear2);                  // 短期解約違約金未満（年）
            prop.ShortTermPenaltyFee2__c                    = CommonUtil.stringToDecimal(this.screenPropertyRecord.ShortTermPenaltyFee2);                       // 短期解約違約金
            prop.FireInsuranceUseType__c                    = this.screenPropertyRecord.FireInsuranceUseType;                       // 火災保険料（加入義務）
            prop.FireInsuranceCompany__c                    = this.screenPropertyRecord.FireInsuranceCompany;                       // 火災保険会社
            prop.FireInsurancePlan__c                       = this.screenPropertyRecord.FireInsurancePlan;                          // 火災保険タイトル
            prop.GuaranteeidCompanyType__c                  = this.screenPropertyRecord.GuaranteeidCompanyType;                     // 保証会社（利用区分）
            prop.GuaranteeidCompany__c                      = this.screenPropertyRecord.GuaranteeidCompany;                         // 保証会社
            prop.Guaranteeid__c                             = this.screenPropertyRecord.Guaranteeid;                                // 保証タイトル
            prop.ADFeeYen__c                                = CommonUtil.stringToDecimal(this.screenPropertyRecord.ADFeeYen);                                   // 広告料（円）
            prop.ADFeeMonth__c                              = CommonUtil.stringToDecimal(this.screenPropertyRecord.ADFeeMonth);                                 // 広告料（ヵ月）
            prop.ADFeeRate__c                               = CommonUtil.stringToDecimal(this.screenPropertyRecord.ADFeeRate);                                  // 広告料（％）
            prop.ADFeeTaxType__c                            = prop.ADFeeYen__c == null ? '' : this.screenPropertyRecord.ADFeeTaxType;                           // 広告料税区分
            prop.ADFeeUnit__c                               = this.screenPropertyRecord.ADFeeUnit;                                  // 広告料単位
            prop.ADFeeComment__c                            = this.screenPropertyRecord.ADFeeComment;                               // 広告料コメント
            prop.ADRemarksPublic__c                         = this.screenPropertyRecord.ADRemarksPublic;                            // 広告備考（公開）
            // prop.ADRemarksPrivate__c                        = this.screenPropertyRecord.ADRemarksPrivate;                           // 広告備考（非公開）
            // prop.RewardType__c                              = this.screenPropertyRecord.RewardType;                                 // 報酬形態
            prop.RewardBurdenLender__c                      = CommonUtil.stringToDecimal(this.screenPropertyRecord.RewardBurdenLender);                         // 報酬負担貸主
            prop.RewardBurdenBorrower__c                    = CommonUtil.stringToDecimal(this.screenPropertyRecord.RewardBurdenBorrower);                       // 報酬負担借主
            prop.RewardSplitFormerSupplier__c               = CommonUtil.stringToDecimal(this.screenPropertyRecord.RewardSplitFormerSupplier);                  // 報酬配分元付
            prop.RewardSplitCustomer__c                     = CommonUtil.stringToDecimal(this.screenPropertyRecord.RewardSplitCustomer);                        // 報酬配分客付
            prop.KeyPlace__c                                = this.screenPropertyRecord.KeyPlace;                                   // 鍵所在
            prop.AthomePanoramaContentsId__c                = this.screenPropertyRecord.AthomePanoramaContentsId;                   // athomeパノラマコンテンツID
            prop.AtHomePanoramaShop__c                      = this.screenPropertyRecord.AtHomePanoramaShopId;                       // athomeパノラマ掲載店舗
            // prop.HomesPanoramaShop__c                       = this.screenPropertyRecord.HomesPanoramaShop;                          // HOME'Sパノラマ掲載店舗
            // prop.SuumoPanoramaShop__c                       = this.screenPropertyRecord.SuumoPanoramaShop;                          // SUUMOパノラマ掲載店舗
            prop.FormerSupplier__c                          = this.screenPropertyRecord.FormerSupplierId;                           // 元付業者Id
            prop.Owner__c                                   = this.screenPropertyRecord.OwnerId;                                    // 所有者Id
            prop.Creditor__c                                = this.screenPropertyRecord.CreditorId;                                 // 貸主Id
            prop.WebPublishing__c                           = this.screenPropertyRecord.WebPublishing;                              // Web公開
            prop.IsPropertyNameHiddenFlag__c                = this.screenPropertyRecord.IsPropertyNameHiddenFlag;                   // 物件名非表示フラグ
            prop.ImportType__c                              = this.screenPropertyRecord.ImportType;                                 // 取込区分
            prop.HomesPropertyFeature__c                    = this.screenPropertyRecord.HomesPropertyFeatureOrg;                    // HOME'S物件の特徴元
            prop.HomesRemarks__c                            = this.screenPropertyRecord.HomesRemarks;                               // HOME'S備考
            prop.SuumoNetCatch__c                           = this.screenPropertyRecord.SuumoNetCatchOrg;                           // SUUMOネット用キャッチ元
            prop.SuumoNetCatchComment__c                    = this.screenPropertyRecord.SuumoNetCatchCommentOrg;                    // SUUMOネット用キャッチコメント元
            prop.SuumoRemarks__c                            = this.screenPropertyRecord.SuumoRemarks;                               // SUUMO備考
            prop.AthomeRecommendComment__c                  = this.screenPropertyRecord.AthomeRecommendCommentOrg;                  // athomeおすすめコメント元
            prop.AthomeRecommendCommentStaffId__c           = this.screenPropertyRecord.AthomeRecommendCommentStaffId;              // athomeおすすめコメントスタッフID
            prop.AtHomeRemarks__c                           = this.screenPropertyRecord.AtHomeRemarks;                              // athome備考
            prop.ChintaiMagazineComment__c                  = this.screenPropertyRecord.ChintaiMagazineCommentOrg;                  // CHINTAI雑誌コメント 2022.03.25　CHINTAI対応追加
            if (isInsert) {
                prop.MaintenancePropertyCode__c             = '手動登録';                                                           // メンテナンス物件コード
                prop.MaintenanceType__c                     = CommonConst.MAINTENANCETYPE_MANUALADD;                                // メンテナンス区分
                prop.MaintenanceCommentArea__c                  = String.isEmpty(this.screenPropertyRecord.MaintenanceComment)
                                                            ? '物件を登録しました。' : this.screenPropertyRecord.MaintenanceComment;  // メンテナンスコメント
            } else {
                prop.MaintenanceType__c                     = CommonConst.MAINTENANCETYPE_MANUALCHG;                                // メンテナンス区分
                prop.MaintenanceCommentArea__c                  = String.isEmpty(this.screenPropertyRecord.MaintenanceComment)
                                                            ? '物件を更新しました。' : this.screenPropertyRecord.MaintenanceComment;  // メンテナンスコメント
            }
            // 問合せ278で追加　手動に変更した場合、メンテナンス物件コード、物件詳細画面URLをnullに変更
            if(this.screenPropertyRecord.importType == MANUAL && this.screenPropertyRecord.initialInportType != MANUAL) {
                prop.MaintenancePropertyCode__c = null;// メンテナンス物件コード
                prop.PropertyDetailUrl__c = null;// 物件詳細画面URL
            } else {
                prop.MaintenancePropertyCode__c = this.screenPropertyRecord.MaintenancePropertyCode;// メンテナンス物件コード
            }
            //2020/5/8追加
            if (changeBeforeIsPermissionPublishing != this.screenPropertyRecord.IsPermissionPublishing){
                if (this.screenPropertyRecord.IsPermissionPublishing == true){
                    prop.MaintenanceCommentArea__c += ' 掲載許可済みフラグを"許可する"に変更しました。';
                }else{
                    prop.MaintenanceCommentArea__c += ' 掲載許可済みフラグを"許可しない"に変更しました。';
                }
            }
            changeBeforeIsPermissionPublishing = this.screenPropertyRecord.IsPermissionPublishing;
            
            prop.MaintenanceStartDateTime__c                = this.MaintenanceStartDateTime;                                        // メンテナンス開始時刻
            prop.MaintenanceEndDateTime__c                  = nowDateTime;                                                          // メンテナンス終了時刻
            prop.MaintenanceStaff__c                        = UserInfo.getUserId();                                                 // メンテナンススタッフ（ログインユーザ）
            if (isTempSave) {
                // 一時保存
                prop.MaintenanceAction__c                   = null;                                                                 // メンテナンスアクション元画面は入れない。
                prop.TemporarySaveDate__c                   = nowDateTime;                                                          // 一時保存日
            } else {
                // 保存
                prop.IsBulkConfirmation__c                  = false;                                                                // 一括確認チェック
                prop.BulkConfirmationDate__c                = null;                                                                 // 一括確認日
                prop.OwnCompanyManageModDate__c             = nowDateTime;                                                          // 自社管理修正日
                if (this.prevPage == '手動') {
                    prop.MaintenanceAction__c               = CommonConst.PROPERTY_MAINTENANCEACTION_ORIGINALPROPERTYDETAILS;       // メンテナンスアクション元画面（元付物件詳細）
                    prop.ManualMaintenanceDate__c           = nowDateTime;                                                          // 手動最終メンテナンス日
                    manualMaintenanceCount(nowDateTime);                                                                            // 手動メンテ数の加算判定
                    
                } else if (this.prevPage == '自動') {
                    prop.MaintenanceAction__c               = CommonConst.PROPERTY_MAINTENANCEACTION_AUTOMAINTENANCE;               // メンテナンスアクション元画面（自動メンテナンス）
                    prop.AutoMaintenanceDate__c             = nowDateTime;                                                          // 自動最終メンテナンス日
                } else {
                    prop.ManualModifiedDate__c              = nowDateTime;                                                          // 手動登録更新日
                }
                prop.TemporarySaveDate__c                   = null;                                                                 // 一時保存日
            }
            prop.SecurityDepositYenSearch__c                = this.getNullToDecimalValue(prop.SecurityDepositYen__c);               // (検索用)敷金(円)
            prop.SecurityDepositMonthSearch__c              = this.getNullToDecimalValue(prop.SecurityDepositMonth__c);             // (検索用)敷金(ヵ月)
            prop.DepositYenSearch__c                        = this.getNullToDecimalValue(prop.DepositYen__c);                       // (検索用)保証料金(円)
            prop.DepositMonthSearch__c                      = this.getNullToDecimalValue(prop.DepositMonth__c);                     // (検索用)保証料金(ヵ月)
            prop.KeyMoneyYenSearch__c                       = this.getNullToDecimalValue(prop.KeyMoneyYen__c);                      // (検索用)礼金(円)
            prop.KeyMoneyMonthSearch__c                     = this.getNullToDecimalValue(prop.KeyMoneyMonth__c);                    // (検索用)礼金(ヵ月)
            prop.CleaningFeeYenSearch__c                    = this.getNullToDecimalValue(prop.CleaningFeeYen__c);                   // (検索用)定額修繕費(円)
            prop.CleaningFeeMonthSearch__c                  = this.getNullToDecimalValue(prop.CleaningFeeMonth__c);                 // (検索用)定額修繕費(ヵ月)
            prop.RenewalFeeYenSearch__c                     = this.getNullToDecimalValue(prop.RenewalFeeYen__c);                    // (検索用)更新料(円)
            prop.RenewalFeeMonthSearch__c                   = this.getNullToDecimalValue(prop.RenewalFeeMonth__c);                  // (検索用)更新料(ヵ月)
            prop.RentFeeSearch__c                           = this.getNullToDecimalValue(prop.RentFee__c);                          // (検索用)賃料
            prop.RentFeeSearchManagement__c                 = this.getNullToDecimalValue(prop.RentFee__c)
                                                            + this.getNullToDecimalValue(prop.ManagementFee__c);                    // (検索用)賃料管理費込み
            prop.RentFeeSearchParking__c                    = this.getNullToDecimalValue(prop.RentFee__c)
                                                            + this.getNullToDecimalValue(prop.ParkingFee__c);                       // (検索用)賃料駐車場込み
            prop.RentFeeSearchManagementParking__c          = this.getNullToDecimalValue(prop.RentFee__c)
                                                            + this.getNullToDecimalValue(prop.ManagementFee__c)
                                                            + this.getNullToDecimalValue(prop.ParkingFee__c);                       // (検索用)賃料管理費駐車場込み
            //2020/5/8追加
            prop.IsPermissionPublishing__c                = this.screenPropertyRecord.IsPermissionPublishing;               // 掲載許可済みフラグ


            // 点数（スーモスコア） 計算、設定
            BuildingPhoto__c buildPhoto = this.selectBuildingPhoto(prop.Building__c);
            prop.Score__c = BuildingPropertyUtil.getSuumoScore(this.buildingRecord, buildPhoto, prop, propPhoto);   // 点数
            // 名寄せ完了フラグ 判定、設定
            List<Property__c> nameMergeTargetList = NameMergeUtil.getPropertyMergeList(prop, null);
            prop.IsMergeCompletedFlag__c = nameMergeTargetList.size() == 0;
            // 総賃料 計算、設定
            List<ManagementCompanyItem__c> manageItemList = new List<ManagementCompanyItem__c>();
            Integer managementCompany = 1;
            for (ScreenManagementCompanyItem item : this.managementCompanyItemList) {
                if (item.IsChecked) {
                    manageItemList.add(item.record.clone());
                    // 保存時の行を保持
                    saveManagementCompanyItemCheckedCountList.add(managementCompany);
                }
                managementCompany++;
            }
            // 火災保険が変更された場合
            if (this.initFireInsuranceCheckedCount != this.saveFireInsuranceCheckedCount){
                prop.MaintenanceCommentArea__c += selectItemRow(this.initFireInsuranceCheckedCount, this.saveFireInsuranceCheckedCount, '火災保険変更');
            }
            // 保証会社が変更された場合
            if (this.initGuaranteePlanCheckedCount != this.saveGuaranteePlanCheckedCount){
                prop.MaintenanceCommentArea__c += selectItemRow(this.initGuaranteePlanCheckedCount, this.saveGuaranteePlanCheckedCount, '保証会社変更');
            }
            // 管理会社指定商品が変更された場合
            if (!this.initManagementCompanyItemCheckedCountList.equals(this.saveManagementCompanyItemCheckedCountList)){
                prop.MaintenanceCommentArea__c += selectManagementCompanyItemRow(this.initManagementCompanyItemCheckedCountList, this.saveManagementCompanyItemCheckedCountList, '管理会社指定商品変更');
            }
            // 火災保険情報の取得
            Item__c fireInsuranceItemAllRentFee;
            // 火災保険（加入義務）有
            fireInsuranceItemAllRentFee = selectFireInsuranceItemAllRentFee(this.screenPropertyRecord.FireInsurancePlan);

            // 保証プランの取得
            Item__c DepositItem;
            DepositItem = selectDepositItem(this.screenPropertyRecord.Guaranteeid);
            prop.AllRentFee__c = BuildingPropertyUtil.calcAllRent(prop, manageItemList, fireInsuranceItemAllRentFee, DepositItem);  // 総賃料の算出            
            //▼問合せNo0598で追加
            // おすすめ物件更新履歴
            if(this.isRecommendProperty && this.isUseAuthorityPortal){
                prop.MaintenanceCommentArea__c += ' おすすめ物件登録 ';
            }
            //▲問合せNo0598で追加


            // 物件条件
            PropertyConditions__c propCond = new PropertyConditions__c();
            propCond = this.screenPropertyRecord.PropertyConditions.clone(!isInsert);
            // 更新時のみ物件IDを設定
            if(!isInsert) {
                propCond.Property__c = prop.Id;
                // 更新項目の文字列を取得
                prop.MaintenanceCommentArea__c += BuildingPropertyUtil.getMaintenanceItem(initPropertyRecord, prop, initPropertyConditionsRecord, propCond);
            }
            if (this.isCopy) {
                // コピー時、設備備考（非公開）はnullとする
                propCond.FacilityRemarksPrivate__c = null;
            }

            SecureDML.secureUpsert(prop);
            // 新規の場合、物件IDを設定
            propCond.Property__c = prop.Id;
            SecureDML.secureUpsert(propCond);

            // 部屋
            List<Room__c> room = new List<Room__c>();
            for (ScreenRoom record : this.screenPropertyRecord.ScreenRoomList) {
                if (this.isCopy) {
                    record.Room.Id = null;
                }
                record.Room.Property__c = prop.Id;
                room.add(record.Room);
            }
            SecureDML.secureUpsert(room);
            // 部屋（削除）
            if (!isInsert && !this.deleteRoomList.isEmpty()) {
                SecureDML.secureDelete(this.deleteRoomList);
            }

            // 物件管理会社指定（削除）
            List<PropertyManageCompayItem__c> propertyManageCompayItem = [
                SELECT
                    Id
                FROM PropertyManageCompayItem__c
                WHERE
                    Property__c = :prop.Id
            ];
            if (!propertyManageCompayItem.isEmpty()) {
                SecureDML.secureDelete(propertyManageCompayItem);
            }
            // 物件管理会社指定
            propertyManageCompayItem = new List<PropertyManageCompayItem__c>();
            for (ScreenManagementCompanyItem item : this.managementCompanyItemList) {
                if (item.IsChecked) {
                    propertyManageCompayItem.add(
                        new PropertyManageCompayItem__c(
                            Property__c = prop.Id
                            ,Account__c = this.screenPropertyRecord.FormerSupplierId
                            ,Item__c    = item.Id
                        )
                    );
                }
            }
            if (propertyManageCompayItem.size() > 0) {
                SecureDML.secureInsert(propertyManageCompayItem);
            }

            // 物件写真（コメント、タグの更新）
            propPhoto.Property__c = prop.Id;
            SecureDML.secureUpsert(propPhoto);

            //ポータルサイト構築 追加 Start
            //コピー状態でない　かつ　画面のおすすめ物件が空でない場合のみ
            if (!isCopy && !(recoPro == null || recoPro == new RecommendProperty__c())){

                //おすすめ物件登録/更新
                SecureDML.secureUpsert(recoPro);

            //コピー状態の場合
            }else if (isCopy){    
                //コピー状態の場合、コピー元のおすすめ物件が表示されないよう、newした値を入れる
                recoPro = new RecommendProperty__c();
            }

            //ポータルサイト構築 追加 End

            // 建物物件差分の登録（一時保存でないかつweb公開するとなっている場合）
            // 共通部品【建物物件差分登録】を呼び出し建物物件差分を登録する。
            if (!isTempSave && prop.WebPublishing__c == CommonConst.PROPERTY_WEBPUBLISHING_EXISTS) {
				System.debug('建物差分作成');
                BuildingPropertyUtil.createBuildingPropertyDifference(prop.Id);
            }

            // 画像データ操作フラグONであれば、日報情報更新処理を実行する。
            if (this.isPhotoDataOperate) {
                DailyReportUtil.upsertDailyReportProperty();
            }

            // 新規登録、物件コピーを解除
            this.isNew = false;
            this.isCopy = false;

            // 物件Idを反映する
            this.propertyId = prop.Id;

            // 画面情報の再読み込み
            // 物件
            this.screenPropertyRecord = new ScreenProperty(
                this.selectProperty(this.propertyId)
                ,this.buildingRecord
                ,this.selectPortalSitePostingProperty(this.propertyId)
                ,this.selectRoom(this.propertyId)
            );
            this.initPropertyRecord = prop.clone();
            // 問合せ371で変更　初期表示時のレコード（物件条件）を更新
            this.initPropertyConditionsRecord = this.screenPropertyRecord.PropertyConditions.clone();
            // 添付ファイル
            this.screenPropertyAttachmentsRecord = new ScreenPropertyAttachments(selectPropertyAttachments(this.propertyId));
            // 物件メンテナンス履歴リスト
            this.propertyMaintenanceHistoryList = new List<PropertyMaintenanceHistory__c>(selectPropertyMaintenanceHistory(this.propertyId));
            // 写真関連の情報の初期化
            if (isInsert) {
                // 新規登録時は主に外部Id
                this.publicPhotoData        = new ScreenAnyPhotoData(this.screenPropertyRecord.ForeignID, this.screenPropertyRecord.BuildingForeignID, AmazonS3Util.PhotoType.PROPERTY);
                this.privatePhotoData       = new ScreenAnyPhotoData(this.screenPropertyRecord.ForeignID, this.screenPropertyRecord.BuildingForeignID, AmazonS3Util.PhotoType.PROPERTY_PRIVATE);
                this.panoramaPhotoData      = new ScreenAnyPhotoData(this.screenPropertyRecord.ForeignID, this.screenPropertyRecord.BuildingForeignID, AmazonS3Util.PhotoType.PROPERTY_PANORAMA);
                this.floorplanPhotoData     = new ScreenAnyPhotoData(this.screenPropertyRecord.ForeignID, this.screenPropertyRecord.BuildingForeignID, AmazonS3Util.PhotoType.PROPERTY_ROOMLAYOUT);
                this.floorplanPhotoMemoData = new ScreenAnyPhotoData(this.screenPropertyRecord.ForeignID, this.screenPropertyRecord.BuildingForeignID, AmazonS3Util.PhotoType.PROPERTY_ROOMLAYOUTMEMO);
                this.publicPhotoGD901001Parameter.foreignId         = this.screenPropertyRecord.BuildingForeignID;
                this.publicPhotoGD901001Parameter.foreignId2        = this.screenPropertyRecord.ForeignID;
                this.privatePhotoGD901001Parameter.foreignId        = this.screenPropertyRecord.BuildingForeignID;
                this.privatePhotoGD901001Parameter.foreignId2       = this.screenPropertyRecord.ForeignID;
                this.panoramaPhotoGD901001Parameter.foreignId       = this.screenPropertyRecord.BuildingForeignID;
                this.panoramaPhotoGD901001Parameter.foreignId2      = this.screenPropertyRecord.ForeignID;
                this.floorplanPhotoGD901001Parameter.foreignId      = this.screenPropertyRecord.BuildingForeignID;
                this.floorplanPhotoGD901001Parameter.foreignId2     = this.screenPropertyRecord.ForeignID;
                this.floorplanMemoPhotoGD901001Parameter.foreignId  = this.screenPropertyRecord.BuildingForeignID;
                this.floorplanMemoPhotoGD901001Parameter.foreignId2 = this.screenPropertyRecord.ForeignID;
            } else {
                // 非公開写真のアップロード状況を更新
                this.privatePhotoStatsList = new List<ScreenPrivatePhotoStats>();
                this.privatePhotoStatsList.add(new ScreenPrivatePhotoStats(this.privatePhotoData, 'ブレーカー'));
                this.privatePhotoStatsList.add(new ScreenPrivatePhotoStats(this.privatePhotoData, '鍵'));
                this.privatePhotoStatsList.add(new ScreenPrivatePhotoStats(this.privatePhotoData, '照明'));
                this.privatePhotoStatsList.add(new ScreenPrivatePhotoStats(this.privatePhotoData, 'その他'));
            }

            // メンテナンス開始時刻の再設定
            this.MaintenanceStartDateTime = CommonUtil.getNow();

            // 部屋の削除対象リストを初期化
            this.deleteRoomList = new List<Room__c>();

            // 火災保険、保証会社、管理会社指定商品を初期化
            this.initFireInsuranceCheckedCount = this.saveFireInsuranceCheckedCount;
            this.saveFireInsuranceCheckedCount = null;
            this.initGuaranteePlanCheckedCount = this.saveGuaranteePlanCheckedCount;
            this.saveGuaranteePlanCheckedCount = null;
            this.initManagementCompanyItemCheckedCountList = this.saveManagementCompanyItemCheckedCountList;
            this.saveManagementCompanyItemCheckedCountList = new List<Integer>();

            //▼問合せNo0598で追加
            this.isRecommendProperty = false;
            this.isRecommendPropertyCopy = false;
            //▲問合せNo0598で追加

            // メンテナンス物件コード履歴を設定
            this.setPropertyCdHist(this.propertyId);

        } catch(Exception e) {
            Database.rollback(sp);  // DB処理をロールバック
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    /**
    * 選択された行数と項目を含めた文字列を返す
    * @param  Integer      beforeSelectRow  初期表示行
    * @param  Integer      afterSelectRow  保存時表示行
    * @return String       Item　{項目名}:{初期表示行}列目→{保存時表示行}列目
    */
    private String selectItemRow(Integer beforeSelectRow, Integer afterSelectRow, String Item) {

        String beforeStr = '';
        if(beforeSelectRow != null && beforeSelectRow != 0) {
            beforeStr = String.valueOf(beforeSelectRow) + '列目';
        }
        String afterStr = '';
        if(afterSelectRow != null && afterSelectRow != 0) {
            afterStr = String.valueOf(afterSelectRow) + '列目';
        }
        String resultBeforeItem;
        String resultAfterItem;
        resultBeforeItem = beforeStr.equals('') ? NOT_SET : beforeStr;
        resultAfterItem = afterStr.equals('') ? NOT_SET : afterStr;
        return item + '：' + resultBeforeItem + '→' + resultAfterItem + '　';
    }

    /**
    * 管理会社指定商品について選択された行数と項目を含めた文字列を返す
    * @param  List<Integer> beforeSelectRow  初期表示行のリスト
    * @param  ist<Integer> afterSelectRow  保存時表示行のリスト
    * @return String       Item　{項目名}:{初期表示行}列目→{保存時表示行}列目
    */
    private String selectManagementCompanyItemRow(List<Integer> beforeSelectRow, List<Integer> afterSelectRow, String Item) {

        String beforeStr = '';
        Integer beforeCount = 1;
        if(beforeSelectRow.size() != 0) {
            for(Integer before : beforeSelectRow) {
                beforeStr += String.valueOf(before);
                if(beforeSelectRow.size() != beforeCount) {
                    beforeStr += ',';
                }
                beforeCount++;
            }
            beforeStr += '列目';
        }

        String afterStr = '';
        Integer afterCount = 1;
        if(afterSelectRow.size() != 0) {
            for(Integer after : afterSelectRow) {
                afterStr += String.valueOf(after);
                if(afterSelectRow.size() != afterCount) {
                    afterStr += ',';
                }
                afterCount++;
            }
            afterStr += '列目';
        }
        String resultBeforeItem;
        String resultAfterItem;
        resultBeforeItem = beforeStr.equals('') ? NOT_SET : beforeStr;
        resultAfterItem = afterStr.equals('') ? NOT_SET : afterStr;
        return item + '：' + resultBeforeItem + '→' + resultAfterItem + '　';
    }

    // 入力チェック（保存時）
    private BusinessLogicException checkInput(BusinessLogicException ex, Boolean isTempSave) {

        // 必須入力チェック
        List<String> requiredItem = new List<String>();
        if (String.isEmpty(this.screenPropertyRecord.Name)){
            requiredItem.add('部屋番号');
        }
        // 一時保存もしくは居住中時はチェックしない
        if (!(isTempSave || this.screenPropertyRecord.LiveStatus == CommonConst.PROPERTY_LIVESTATUS_RESIDENT)) {  
            if (String.isEmpty(this.screenPropertyRecord.Floor)){
                requiredItem.add('所在階');
            }
            if (String.isEmpty(this.screenPropertyRecord.RoomCount)){
                requiredItem.add('部屋数');
            }
            if (String.isEmpty(this.screenPropertyRecord.RoomArea)){
                requiredItem.add('専有面積');
            }
            if (String.isEmpty(this.screenPropertyRecord.LiveStatus)){
                requiredItem.add('現況');
            }
            if (String.isEmpty(this.screenPropertyRecord.DeliveryType)){
                requiredItem.add('引渡種別');
            }
            if (String.isEmpty(this.screenPropertyRecord.TransactionAspect)){
                requiredItem.add('取引態様');
            }
            if (String.isEmpty(this.screenPropertyRecord.RentFee)){
                requiredItem.add('賃料');
            }
            if (!this.isCopy) {
                // 公開写真タグ
                for (GA104006Controller.PhotoData photo : this.publicPhotoData.photoDataList) {
                    if (String.isEmpty(photo.tag)) {
                        requiredItem.add('公開写真のタグ');
                        break;
                    }
                }
                // パノラマ写真タグ
                for (GA104006Controller.PhotoData photo : this.panoramaPhotoData.photoDataList) {
                    if (String.isEmpty(photo.tag)) {
                        requiredItem.add('パノラマ写真のタグ');
                        break;
                    }
                }
            }
            if (String.isEmpty(this.screenPropertyRecord.FormerSupplierId)){
                requiredItem.add('元付業者');
            }
        }
        // 必須入力チェック用リストが空ではない場合、ビジネスロジックException発行
        if (!requiredItem.isEmpty()){
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ', ')));
        }

        // 物件コピー時、コピー元と画面の部屋番号に変化が無ければエラー
        if (this.isCopy && this.screenPropertyRecord.Name == this.initPropertyRecord.Name) {
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_EXISTENCE, this.screenPropertyRecord.Name));
        }
        
        // 部屋番号を11byteに入力制限(全角3byte,半角1byte)
        if(String.isNotBlank(this.screenPropertyRecord.Name)){
            Integer nameStringSize = CommonUtil.getByteLength(this.screenPropertyRecord.Name);
            if(nameStringSize >= 11){
                ex.addMessage(CommonConst.MSG_PROP_W_BYTE);
            }
        }

        // 一時保存もしくは居住中時はチェックしない
        if (!(isTempSave || this.screenPropertyRecord.LiveStatus == CommonConst.PROPERTY_LIVESTATUS_RESIDENT)) {  
            // 引渡種別「期日指定」時チェック
            if (this.screenPropertyRecord.DeliveryType == CommonConst.PROPERTY_DELIVERYTYPE_DUEDATE) {
                // 引渡年・引渡月 未入力チェック
                // 引渡旬・引渡日 いずれかの未入力チェック
                if (String.isEmpty(this.screenPropertyRecord.DeliveryYear)
                || String.isEmpty(this.screenPropertyRecord.DeliveryMonth)
                || (String.isEmpty(this.screenPropertyRecord.DeliveryTiming) && String.isEmpty(this.screenPropertyRecord.DeliveryDay))) {
                    ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_INPUT + '（日は旬での指定も可能です。）' , '引渡種別が期日指定の場合,引渡年月日'.split(',')));
                }
            }
            // 引渡日の入力あり時チェック
            if (!String.isEmpty(this.screenPropertyRecord.DeliveryDay)) {
                // 引渡年・引渡月 未入力チェック
                if ((String.isEmpty(this.screenPropertyRecord.DeliveryYear) || String.isEmpty(this.screenPropertyRecord.DeliveryMonth))) {
                    // 引渡種別「期日指定」の場合,等チェック以前にチェックされているのでエラー追加しない
                    if (this.screenPropertyRecord.DeliveryType != CommonConst.PROPERTY_DELIVERYTYPE_DUEDATE) {
                        ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_INPUT, '引渡日を登録する場合,引渡年と引渡月'.split(',')));
                    }
                } else {
                    // 引渡年・引渡月 の入力がある場合
                    // 日付整合性チェック
                    if (!checkIsDate(this.screenPropertyRecord.DeliveryYear, this.screenPropertyRecord.DeliveryMonth, this.screenPropertyRecord.DeliveryDay)) {
                        ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_INPUT, '引渡日に,正しい範囲の日付'.split(',')));
                    }
                }
            }

            // 定期借家区分「該当」
            if (this.screenPropertyRecord.RentType == CommonConst.PROPERTY_RENTTYPE_APPLICABLE) {
                // 定借期限（年・月・日）が未入力
                if (String.isEmpty(this.screenPropertyRecord.RentTermYear)
                    || String.isEmpty(this.screenPropertyRecord.RentTermMonth)
                    || String.isEmpty(this.screenPropertyRecord.RentTermDay)) {
                    // さらに契約期間（年）（月）が両方未入力
                    if (String.isEmpty(this.screenPropertyRecord.ContractTermYear) && String.isEmpty(this.screenPropertyRecord.ContractTermMonth)) {
                        ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_INPUT, '定期借家区分が該当の場合;契約期間（年）,契約期間（月）,定借期限（年, 月, 日）のいずれか'.split(';')));
                    }
                } else {
                    // 定借期限（年・月・日）の入力がある場合
                    // 日付整合性チェック
                    if (!checkIsDate(this.screenPropertyRecord.RentTermYear, this.screenPropertyRecord.RentTermMonth, this.screenPropertyRecord.RentTermDay)) {
                        ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_INPUT, '定借期限に,正しい範囲の日付'.split(',')));
                    }
                }
            // 定期借家区分「該当」以外
            } else {
                // 契約期間（年）（月）未入力チェック
                if (String.isEmpty(this.screenPropertyRecord.ContractTermYear) && String.isEmpty(this.screenPropertyRecord.ContractTermMonth)) {
                    ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_INPUT, '契約期間（年）また;契約期間（月）'.split(';')));
                }
            }

            // 料金変動区分が「傾斜型」の場合、上昇率 未入力チェック
            if (this.screenPropertyRecord.SpecificExcellentRentFeeFluctuationType == CommonConst.PROPERTY_SPECIFICEXCELLENTRENTFEEFLUCTUATIONTYPE_INCLINATION
                && String.isEmpty(this.screenPropertyRecord.SpecificExcellentRentFeeUpwardRate)) {
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_INPUT, '料金変動区分が傾斜型の場合,上昇率'.split(',')));
            }

            // 料金変動区分が「フラット型」の場合、上昇率 入力チェック
            if (this.screenPropertyRecord.SpecificExcellentRentFeeFluctuationType == CommonConst.PROPERTY_SPECIFICEXCELLENTRENTFEEFLUCTUATIONTYPE_FLAT
                && !String.isEmpty(this.screenPropertyRecord.SpecificExcellentRentFeeUpwardRate)) {
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_CASE_CANNOT_INPUT, '料金変動区分がフラット型,上昇率'.split(',')));
            }

            // 賃料下限チェック（5000未満はエラー）
            if (!String.isEmpty(this.screenPropertyRecord.RentFee)) {
                if (CommonUtil.stringToDecimal(this.screenPropertyRecord.RentFee) < 5000) {
                    ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_LOWER_LIMIT, '賃料,5000'.split(',')));
                }
            }

            // 敷金、保証金 未入力時 敷引/償却 入力不可チェック
            if (String.isEmpty(this.screenPropertyRecord.SecurityDeposit)
                && String.isEmpty(this.screenPropertyRecord.Deposit)
                && !String.isEmpty(this.screenPropertyRecord.CancellationActualFee)) {
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_CASE_CANNOT_INPUT, '敷金, 保証金が未入力;敷引/償却'.split(';')));
            }
            // 敷金、保証金 両方入力不可チェック
            if (!String.isEmpty(this.screenPropertyRecord.SecurityDeposit) && !String.isEmpty(this.screenPropertyRecord.Deposit)) {
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_INPUT, '敷金, 保証金;どちらか片方のみ'.split(';')));
            }

			// ▼2022.02.02 No.0676 対応で追加、報酬負担貸主と報酬負担借主で合計が１００を超えた場合エラー
			if(CommonUtil.stringToDecimalNullToZero(this.screenPropertyRecord.RewardBurdenLender) + CommonUtil.stringToDecimalNullToZero(this.screenPropertyRecord.RewardBurdenBorrower) > 100){
				ex.addMessage(CommonConst.MSG_PROP_E_BROKERAGEFEE_RATE);
			}   

            // 単位区分を持つ料金項目について単位毎の入力範囲チェック
            Map<String, String> inputRangeErrorMap = new Map<String, String>();
            Map<String, String> inputRangeCheckFee = new Map<String, String>();     // 入力値
            Map<String, String> inputRangeCheckUnit = new Map<String, String>();    // 入力単位
            List<String> rateCheckTarget = new List<String>();                      // 単位区分に「%」を含む項目
            inputRangeCheckFee.put('敷金', this.screenPropertyRecord.SecurityDeposit);
            inputRangeCheckUnit.put('敷金', this.screenPropertyRecord.SecurityDepositUnit);
            inputRangeCheckFee.put('敷引/償却', this.screenPropertyRecord.CancellationActualFee);
            inputRangeCheckUnit.put('敷引/償却', this.screenPropertyRecord.CancellationActualFeeUnit);
            rateCheckTarget.add('敷引/償却');
            inputRangeCheckFee.put('保証金', this.screenPropertyRecord.Deposit);
            inputRangeCheckUnit.put('保証金', this.screenPropertyRecord.DepositUnit);
            inputRangeCheckFee.put('更新料/更新事務手数料', this.screenPropertyRecord.RenewalFee);
            inputRangeCheckUnit.put('更新料/更新事務手数料', this.screenPropertyRecord.RenewalFeeUnit);
            inputRangeCheckFee.put('礼金', this.screenPropertyRecord.KeyMoney);
            inputRangeCheckUnit.put('礼金', this.screenPropertyRecord.KeyMoneyUnit);
            inputRangeCheckFee.put('定額修繕費/クリーニング費', this.screenPropertyRecord.CleaningFee);
            inputRangeCheckUnit.put('定額修繕費/クリーニング費', this.screenPropertyRecord.CleaningFeeUnit);
            inputRangeCheckFee.put('駐車場保証金', this.screenPropertyRecord.ParkingDeposit);
            inputRangeCheckUnit.put('駐車場保証金', this.screenPropertyRecord.ParkingDepositUnit);
            inputRangeCheckFee.put('駐車場手数料', this.screenPropertyRecord.ParkingCompoundingFee);
            inputRangeCheckUnit.put('駐車場手数料', this.screenPropertyRecord.ParkingCompoundingFeeUnit);
            inputRangeCheckFee.put('広告料', this.screenPropertyRecord.ADFee);
            inputRangeCheckUnit.put('広告料', this.screenPropertyRecord.ADFeeUnit);
            rateCheckTarget.add('広告料');
            for (String key : inputRangeCheckFee.keySet()) {
                String unit = inputRangeCheckUnit.get(key);
                String fee = inputRangeCheckFee.get(key);
                Boolean isRateChack = rateCheckTarget.contains(key);
                // 入力範囲チェック
                if (!this.checkUnitFee(unit, fee, rateCheckTarget.contains(key), key)) {
                    // 入力範囲エラーの場合、単位毎のMapにエラー項目名を追加
                    String temp = '';
                    if (isRateChack && unit == CommonConst.PROPERTY_FEEUNIT_YEN) {
                        unit += '02';
                    } 
                    // 広告料の％である場合、エラー文言を変える必要があるためセットする。
                    if(key == '広告料' && unit == CommonConst.PROPERTY_FEEUNIT_RATE){
                        unit += '02';
                    }
                    if (inputRangeErrorMap.containsKey(unit)) {
                        temp = inputRangeErrorMap.get(unit);
                        temp += ', ';
                    }
                    temp += key;
                    inputRangeErrorMap.put(unit, temp);
                }
            }
            // 「円」の入力範囲エラー
            if (inputRangeErrorMap.containsKey(CommonConst.PROPERTY_FEEUNIT_YEN)) {
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_INPUT + '(' + inputRangeErrorMap.get(CommonConst.PROPERTY_FEEUNIT_YEN) + ')', '料金「円」,100以上もしくは0'.split(',')));
            }
            // 「円」の入力範囲エラー（単位に%を含む項目）
            if (inputRangeErrorMap.containsKey(CommonConst.PROPERTY_FEEUNIT_YEN + '02')) {
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_INPUT + '(' + inputRangeErrorMap.get(CommonConst.PROPERTY_FEEUNIT_YEN + '02') + ')', '単位に%を含む料金の「円」,201以上もしくは0'.split(',')));
            }
            // 「ヵ月」の入力範囲エラー
            if (inputRangeErrorMap.containsKey(CommonConst.PROPERTY_FEEUNIT_MONTH)) {
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_INPUT + '(' + inputRangeErrorMap.get(CommonConst.PROPERTY_FEEUNIT_MONTH) + ')', '料金「ヵ月」,0～99.9'.split(',')));
            }
            // 「％」の入力範囲エラー
            if (inputRangeErrorMap.containsKey(CommonConst.PROPERTY_FEEUNIT_RATE)) {
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_INPUT + '(' + inputRangeErrorMap.get(CommonConst.PROPERTY_FEEUNIT_RATE) + ')', '料金「%」,0～100'.split(',')));
            }
            // 「％」の入力範囲エラー（広告料）
            if (inputRangeErrorMap.containsKey(CommonConst.PROPERTY_FEEUNIT_RATE + '02')) {
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_INPUT + '(' + inputRangeErrorMap.get(CommonConst.PROPERTY_FEEUNIT_RATE + '02') + ')', '料金「%」,0～999'.split(',')));
            }
            // 金額入力時の税区分未選択チェック
            requiredItem = new List<String>();
            if (!String.isEmpty(this.screenPropertyRecord.WortFee) && String.isEmpty(this.screenPropertyRecord.WortFeeTaxType)) {
                requiredItem.add('水道料金');
            }
            if (!String.isEmpty(this.screenPropertyRecord.ManagementFee) && String.isEmpty(this.screenPropertyRecord.ManagementFeeTaxType)) {
                requiredItem.add('管理費');
            }
            if (!String.isEmpty(this.screenPropertyRecord.CATVFee) && String.isEmpty(this.screenPropertyRecord.CATVTaxType)) {
                requiredItem.add('CATV');
            }
            if (!String.isEmpty(this.screenPropertyRecord.RenewalFee) && String.isEmpty(this.screenPropertyRecord.RenewalFeeTaxType)) {
                requiredItem.add('更新料/更新事務手数料');
            }
            if (!String.isEmpty(this.screenPropertyRecord.TownshipFee) && String.isEmpty(this.screenPropertyRecord.TownshipFeeTaxType)) {
                requiredItem.add('町内会費');
            }
            if (!String.isEmpty(this.screenPropertyRecord.GarbageDisposalFee) && String.isEmpty(this.screenPropertyRecord.GarbageDisposalFeeTaxType)) {
                requiredItem.add('ごみ処理費');
            }
            if (!String.isEmpty(this.screenPropertyRecord.TownshipInitialFee) && String.isEmpty(this.screenPropertyRecord.TownshipInitialFeeTaxType)) {
                requiredItem.add('入町費');
            }
            if (!String.isEmpty(this.screenPropertyRecord.CleaningFee) && String.isEmpty(this.screenPropertyRecord.CleaningFeeTaxType)) {
                requiredItem.add('定額修繕費/クリーニング費');
            }
            if (!String.isEmpty(this.screenPropertyRecord.KeyExchangeFee) && String.isEmpty(this.screenPropertyRecord.KeyExchangeFeeTaxType)) {
                requiredItem.add('鍵交換費');
            }
            if (!String.isEmpty(this.screenPropertyRecord.BicycleParkingFee) && String.isEmpty(this.screenPropertyRecord.BicycleParkingFeeTaxType)) {
                requiredItem.add('駐輪場代');
            }
            if (!String.isEmpty(this.screenPropertyRecord.ParkingFee) && String.isEmpty(this.screenPropertyRecord.ParkingFeeTaxType)) {
                requiredItem.add('駐車場料金');
            }
            if (!String.isEmpty(this.screenPropertyRecord.ParkingDeposit) && String.isEmpty(this.screenPropertyRecord.ParkingDepositTaxType)) {
                requiredItem.add('駐車場保証金');
            }
            if (!String.isEmpty(this.screenPropertyRecord.ParkingCompoundingFee) && String.isEmpty(this.screenPropertyRecord.ParkingCompoundingFeeTaxType)) {
                requiredItem.add('駐車場手数料');
            }
            if (!String.isEmpty(this.screenPropertyRecord.BikeParkingSmallFee) && String.isEmpty(this.screenPropertyRecord.BikeParkingSmallFeeTaxType)) {
                requiredItem.add('小型バイク置場料金');
            }
            if (!String.isEmpty(this.screenPropertyRecord.BikeParkingMediumFee) && String.isEmpty(this.screenPropertyRecord.BikeParkingMediumFeeTaxType)) {
                requiredItem.add('中型バイク置場料金');
            }
            if (!String.isEmpty(this.screenPropertyRecord.BikeParkinLargeFee) && String.isEmpty(this.screenPropertyRecord.BikeParkinLargeFeeTaxType)) {
                requiredItem.add('大型バイク置場料金');
            }
            if (!String.isEmpty(this.screenPropertyRecord.ADFee) && String.isEmpty(this.screenPropertyRecord.ADFeeTaxType)) {
                requiredItem.add('広告料');
            }
            if (!requiredItem.isEmpty()){
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_NO_SELECTION + '(' + String.join(requiredItem, ', ') + ')' , '税区分'));
            }
        }

        // 料金（円）項目の最大桁チェック
        checkInputFeeMaxLength(ex, this.screenPropertyRecord.RentFee                    , 8, '賃料');
        checkInputFeeMaxLength(ex, this.screenPropertyRecord.WortFee                    , 6, '水道料金');
        checkInputFeeMaxLength(ex, this.screenPropertyRecord.SecurityDepositYen         ,10, '敷金');
        checkInputFeeMaxLength(ex, this.screenPropertyRecord.CancellationActualFeeYen   ,10, '敷引/償却');
        checkInputFeeMaxLength(ex, this.screenPropertyRecord.ManagementFee              , 6, '管理費');
        checkInputFeeMaxLength(ex, this.screenPropertyRecord.CATVFee                    , 7, 'CATV');
        checkInputFeeMaxLength(ex, this.screenPropertyRecord.DepositYen                 ,10, '保証金');
        checkInputFeeMaxLength(ex, this.screenPropertyRecord.RenewalFeeYen              ,10, '更新料/更新事務手数料');
        checkInputFeeMaxLength(ex, this.screenPropertyRecord.TownshipFee                , 6, '町内会費');
        checkInputFeeMaxLength(ex, this.screenPropertyRecord.GarbageDisposalFee         , 7, 'ごみ処理費');
        checkInputFeeMaxLength(ex, this.screenPropertyRecord.KeyMoneyYen                ,10, '礼金');
        checkInputFeeMaxLength(ex, this.screenPropertyRecord.TownshipInitialFee         , 7, '入町費');
        checkInputFeeMaxLength(ex, this.screenPropertyRecord.CleaningFeeYen             ,10, '定額修繕費/クリーニング費');
        checkInputFeeMaxLength(ex, this.screenPropertyRecord.KeyExchangeFee             , 6, '鍵交換費');
        checkInputFeeMaxLength(ex, this.screenPropertyRecord.BicycleParkingFee          , 7, '駐輪場代');
        checkInputFeeMaxLength(ex, this.screenPropertyRecord.ParkingFee                 , 6, '駐車場料金');
        checkInputFeeMaxLength(ex, this.screenPropertyRecord.ParkingDepositYen          ,10, '駐車場保証金');
        checkInputFeeMaxLength(ex, this.screenPropertyRecord.ParkingCompoundingFeeYen   ,10, '駐車場手数料');
        checkInputFeeMaxLength(ex, this.screenPropertyRecord.BikeParkingSmallFee        , 7, '小型バイク置場料金');
        checkInputFeeMaxLength(ex, this.screenPropertyRecord.BikeParkingMediumFee       , 7, '中型バイク置場料金');
        checkInputFeeMaxLength(ex, this.screenPropertyRecord.BikeParkinLargeFee         , 7, '大型バイク置場料金');
        checkInputFeeMaxLength(ex, this.screenPropertyRecord.ADFeeYen                   ,10, '広告料');

        // 一時保存もしくは居住中時チェック
        if (isTempSave || this.screenPropertyRecord.LiveStatus == CommonConst.PROPERTY_LIVESTATUS_RESIDENT) {   
            // web公開「する」は一時保存時は不可
            if (this.screenPropertyRecord.WebPublishing == CommonConst.PROPERTY_WEBPUBLISHING_EXISTS) {
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_PROP_E_TEMPSAVE_WEBPUBLISHING, '一時保存')); //2022/05/09 問合せNo.0809対応
            }
        }

        // 一時保存もしくは居住中時はチェックしない
        if (!(isTempSave || this.screenPropertyRecord.LiveStatus == CommonConst.PROPERTY_LIVESTATUS_RESIDENT)) {  
            // 駐車場種別「空有」「空無」「近隣確保」時チェック
            if (this.screenPropertyRecord.ParkingType == CommonConst.PROPERTY_PARKINGTYPE_EMPTY_EXISTS
                || this.screenPropertyRecord.ParkingType == CommonConst.PROPERTY_PARKINGTYPE_NO_EMPTY
                || this.screenPropertyRecord.ParkingType == CommonConst.PROPERTY_PARKINGTYPE_NEIGHBORHOOD_SECURE) {
                // 駐車場料金・駐車場保証料金 未入力チェック
                if (String.isEmpty(this.screenPropertyRecord.ParkingFee)) {
                    ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_INPUT, '駐車場種別が空有, 空無, 近隣確保の場合;駐車場料金'.split(';')));
                }
                // 駐車場種別「近隣確保」以外時、近隣駐車場までの距離 入力不可チェック（null・0以外はエラー）
                if (this.screenPropertyRecord.ParkingType != CommonConst.PROPERTY_PARKINGTYPE_NEIGHBORHOOD_SECURE
                    && !(String.isEmpty(this.screenPropertyRecord.ParkingDistance) || this.screenPropertyRecord.ParkingDistance == '0')) {
                    ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_CASE_CANNOT_INPUT, '駐車場種別が近隣確保以外,近隣駐車場までの距離'.split(',')));
                }
                // 駐車場種別「近隣確保」時、近隣駐車場までの距離
                if (this.screenPropertyRecord.ParkingType == CommonConst.PROPERTY_PARKINGTYPE_NEIGHBORHOOD_SECURE) {
                    // 未入力チェック
                    if (String.isEmpty(this.screenPropertyRecord.ParkingDistance)) {
                        ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_INPUT, '駐車場種別が近隣確保の場合,近隣駐車場までの距離'.split(',')));
                    // 入力範囲チェック（0～2000）
                    } else if (CommonUtil.stringToDecimal(this.screenPropertyRecord.ParkingDistance) < 0 || 2000 < CommonUtil.stringToDecimal(this.screenPropertyRecord.ParkingDistance) ) {
                        ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_INPUT, '近隣駐車場までの距離,0～2000'.split(',')));
                    }
                }
            // 駐車場種別「無」時 各種入力不可チェック
            } else if (this.screenPropertyRecord.ParkingType == CommonConst.PROPERTY_PARKINGTYPE_NO) {
                List<String> checkItems = new List<String>();
                // 駐車場2台可
                if (this.screenPropertyRecord.PropertyConditions.IsPluralCarParking__c) {
                    checkItems.add('駐車場2台可');
                }
                // 近隣駐車場までの距離
                if (!String.isEmpty(this.screenPropertyRecord.ParkingDistance)) {
                    checkItems.add('近隣駐車場までの距離');
                }
                // 駐車場料金
                if (!String.isEmpty(this.screenPropertyRecord.ParkingFee)) {
                    checkItems.add('駐車場料金');
                }
                // 駐車場保険料
                if (!String.isEmpty(this.screenPropertyRecord.ParkingDeposit)) {
                    checkItems.add('駐車場保険料');
                }
                // 駐車場手数料
                if (!String.isEmpty(this.screenPropertyRecord.ParkingCompoundingFee)) {
                    checkItems.add('駐車場手数料');
                }
                if (!checkItems.isEmpty()){
                    ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_CASE_CANNOT_INPUT, ('駐車場種別が無;' + String.join(checkItems, ', ')).split(';')));
                }
            }

            // 短期解約違約年数、短期解約違約金 未入力チェック（短期解約違約有無「有」時）
            if (this.screenPropertyRecord.IsShortTermPenalty == CommonConst.PROPERTY_ISSHORTTERMPENALTY_EXISTS
            && (String.isEmpty(this.screenPropertyRecord.ShortTermPenaltyLessYear) || String.isEmpty(this.screenPropertyRecord.ShortTermPenaltyFee))) {
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_INPUT, '短期解約違約金有無が有の場合,短期解約違約年数(1)とその短期解約違約金'.split(',')));
            }

            // 保証会社選択チェック（利用区分「利用必須」「利用可」時）
            if ((this.screenPropertyRecord.GuaranteeidCompanyType == CommonConst.PROPERTY_GUARANTEEIDCOMPANYTYPE_REQUIRED
                || this.screenPropertyRecord.GuaranteeidCompanyType == CommonConst.PROPERTY_GUARANTEEIDCOMPANYTYPE_POSSIBLE)
                && String.isEmpty(this.screenPropertyRecord.Guaranteeid)) {
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SELECTION, '保証会社(利用区分)が利用必須, 利用可の場合;保証プラン'.split(';')));
            }

            // 設備の整合性（単一選択）チェック
            // 制震構造・耐震構造・免震構造
            Integer checkCount = 0;
            if (this.screenPropertyRecord.PropertyConditions.IsDampingStructure__c) {           // 制震構造
                checkCount++;
            }
            if (this.screenPropertyRecord.PropertyConditions.IsSeismicStructure__c) {           // 耐震構造
                checkCount++;
            }
            if (this.screenPropertyRecord.PropertyConditions.IsSeismicIsolationStructure__c) {  // 免震構造
                checkCount++;
            }
            if (checkCount > 1) {
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_REGISTRATION_MULTI_SELECTION, '制震構造,耐震構造,免震構造'));
            }
            // ガスコンロ・オール電化
            checkCount = 0;
            if (this.screenPropertyRecord.PropertyConditions.IsGasStove__c) {       // ガスコンロ
                checkCount++;
            }
            if (this.screenPropertyRecord.PropertyConditions.IsAllElectric__c) {    // オール電化
                checkCount++;
            }
            if (checkCount > 1) {
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_REGISTRATION_PLURAL_SELECTION, 'ガスコンロ,オール電化'.split(',')));
            }
            // ガスコンロ・電気コンロ・IHコンロ
            checkCount = 0;
            if (this.screenPropertyRecord.PropertyConditions.IsGasStove__c) {       // ガスコンロ
                checkCount++;
            }
            if (this.screenPropertyRecord.PropertyConditions.IsElectricStove__c) {  // 電気コンロ
                checkCount++;
            }
            if (this.screenPropertyRecord.PropertyConditions.IsIhStove__c) {        // IHコンロ
                checkCount++;
            }
            if (checkCount > 1) {
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_REGISTRATION_MULTI_SELECTION, 'ガスコンロ,電気コンロ,IHコンロ'));
            }
            // コンロ2口・コンロ3口以上
            checkCount = 0;
            if (this.screenPropertyRecord.PropertyConditions.IsTwoGasStove__c) {    // コンロ2口
                checkCount++;
            }
            if (this.screenPropertyRecord.PropertyConditions.IsMoreGasStove__c) {   // コンロ3口以上
                checkCount++;
            }
            if (checkCount > 1) {
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_REGISTRATION_PLURAL_SELECTION, 'コンロ2口,コンロ3口以上'.split(',')));
            }
            // オール電化・都市ガス
            checkCount = 0;
            if (this.screenPropertyRecord.PropertyConditions.IsAllElectric__c) {    // オール電化
                checkCount++;
            }
            if (this.screenPropertyRecord.PropertyConditions.IsCityGas__c) {        // 都市ガス
                checkCount++;
            }
            if (checkCount > 1) {
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_REGISTRATION_PLURAL_SELECTION, 'オール電化,都市ガス'.split(',')));
            }
            // オール電化・プロパンガス
            checkCount = 0;
            if (this.screenPropertyRecord.PropertyConditions.IsAllElectric__c) {    // オール電化
                checkCount++;
            }
            if (this.screenPropertyRecord.PropertyConditions.IsPropaneGas__c) {     // プロパンガス
                checkCount++;
            }
            if (checkCount > 1) {
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_REGISTRATION_PLURAL_SELECTION, 'オール電化,プロパンガス'.split(',')));
            }
            // オール電化・ガス暖房
            checkCount = 0;
            if (this.screenPropertyRecord.PropertyConditions.IsAllElectric__c) {    // オール電化
                checkCount++;
            }
            if (this.screenPropertyRecord.PropertyConditions.IsGasHeating__c) {     // ガス暖房
                checkCount++;
            }
            if (checkCount > 1) {
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_REGISTRATION_PLURAL_SELECTION, 'オール電化,ガス暖房'.split(',')));
            }
            // 都市ガス・プロパンガス
            checkCount = 0;
            if (this.screenPropertyRecord.PropertyConditions.IsCityGas__c) {        // 都市ガス
                checkCount++;
            }
            if (this.screenPropertyRecord.PropertyConditions.IsPropaneGas__c) {     // プロパンガス
                checkCount++;
            }
            if (checkCount > 1) {
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_REGISTRATION_PLURAL_SELECTION, '都市ガス,プロパンガス'.split(',')));
            }

            // web公開時チェック
            if (this.screenPropertyRecord.WebPublishing == CommonConst.PROPERTY_WEBPUBLISHING_EXISTS) {
                // 間取り図登録チェック
                if (this.floorplanPhotoData.photoCount == 0 || this.isCopy) {   // 間取り図なしはエラー（物件コピー時もエラー）
                    ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_PROP_E_REQUIRED_ROOMLAYOUT));
                }
                // 建物のweb連携可能チェック
                if (!this.buildingRecord.IsWebCooperationAvailableFlag__c) {  // web連携可能項目がfalseはエラー
                    ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_PROP_E_BUILDING_NO_WEBCOOPERATIONAVALIABLE));
                }
            }

            // 禁止用語チェック
            Map<String, String> banWordCheckMap = new Map<String, String>();
            
            if (!this.isCopy) {
                
                //公開写真のコメント
                String comment = '';
                for (PhotoData photo : this.publicPhotoData.photoDataList) {
                    if (!String.isEmpty(photo.Comment)) {
                        comment += photo.Comment;
                    }
                }
                banWordCheckMap.put('公開写真のコメント',CommonUtil.getContainBanWord(comment));

                //パノラマ写真のコメント
                comment = '';
                for (PhotoData photo : this.panoramaPhotoData.photoDataList) {
                    if (!String.isEmpty(photo.Comment)) {
                        comment += photo.Comment;
                    }
                }
                banWordCheckMap.put('パノラマ写真のコメント',CommonUtil.getContainBanWord(comment));
            }
            banWordCheckMap.put('HOME\'S備考',CommonUtil.getContainBanWord(this.screenPropertyRecord.HomesRemarks));
            banWordCheckMap.put('SUUMO備考',CommonUtil.getContainBanWord(this.screenPropertyRecord.SuumoRemarks));
            banWordCheckMap.put('at home備考',CommonUtil.getContainBanWord(this.screenPropertyRecord.AtHomeRemarks));
            
            for (String key : banWordCheckMap.keySet()) {
                if (!String.isEmpty(banWordCheckMap.get(key))) {
                    ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_REGISTRATION_ROHIBITED_TERMS_MULTI, key, banWordCheckMap.get(key)));
                }
            }

            // 物件コピー元の間取り図変更チェック
            if (this.isCopy && this.isRoomLayoutCopy){
                PropertyPhoto__c propPhoto = selectAnyPhotoList(this.propertyId);
                if(propPhoto.RoomLayoutFileName__c != this.floorplanPhotoData.photoDataList[0].FileName ||
                   propPhoto.RoomLayoutMemoFileName__c != this.floorplanPhotoMemoData.photoDataList[0].FileName){
                    ex.addMessage('コピー元の間取り図が'+CommonConst.MSG_COM_W_OPTIMISTIC_LOCK);
                }
            }
        }

        
        if (!isTempSave) {
            // 所在階チェック
            if ((this.screenPropertyRecord.groundFloorCount != null && !String.isEmpty(this.screenPropertyRecord.Floor))
                && Integer.valueOf(this.screenPropertyRecord.Floor) > Integer.valueOf(this.screenPropertyRecord.groundFloorCount)) {
                List<String> groundFloor = new List<String> {this.screenPropertyRecord.groundFloorCount};
                List<Object> parameters = new List<Object> {'建物' 
                                                            , String.format('地上階数に{0}', groundFloor)
                                                            , String.format('所在階には{0}以下', groundFloor)};
                ex.addMessage(CommonUtil.callMessageCreate(String.format(CommonConst.MSG_COM_W_PROPERTYSETTING_REQUIRED, parameters)));
            }
            //未入居種別が未入居かつ現況で退去予定を選択して保存した場合エラー(一時保存を除く)
            if (this.screenPropertyRecord.LivedType == CommonConst.PROPERTY_LIVEDTYPE_NOTLIVED
                && this.screenPropertyRecord.LiveStatus == CommonConst.PROPERTY_LIVESTATUS_SCHEDULEDTOLEAVE) {
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_CASE_CANNOT_SELECT
                                                          ,'未入居種別が' + CommonConst.PROPERTY_LIVEDTYPE_NOTLIVED 
                                                          ,'現況で'+ CommonConst.PROPERTY_LIVESTATUS_SCHEDULEDTOLEAVE ));
            }
        }

        // 問合せ278で追加 初期表示がリアプロ、大和リビングの場合を除き、リアプロ、大和リビングが選択された場合、エラー
        if((screenPropertyRecord.importType == REALNETPRO && this.screenPropertyRecord.initialInportType != REALNETPRO) 
        || (screenPropertyRecord.importType == DAIWALIVING && this.screenPropertyRecord.initialInportType != DAIWALIVING)) {
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_INPORT_DESTINATION_CAN_NOT_CHANGE, screenPropertyRecord.importType));
        }

        // 初期表示が--なし--の場合を除き、--なし--が選択された場合、エラー
        if(String.isBlank(screenPropertyRecord.importType) && String.isNotBlank(screenPropertyRecord.initialInportType)) {
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_INPORT_DESTINATION_CAN_NOT_CHANGE, SELECTION_LIST_NULL));
        }

        return ex;

    }

    // 日付チェック
    private Boolean checkIsDate(String year, String month, String day) {
        try {
            String dateString = '';
            dateString += year;
            dateString += '-' + month.replace('月', '').leftPad(2, '0');  // 「月」を取り除いて2桁0埋め
            dateString += '-' + day.leftPad(2, '0');                      // 2桁0埋め
            Date temp = Date.ValueOf(dateString);
            return true;
        } catch(Exception e) {
            return false;
        }
    }
    // 料金の単位毎の入力範囲チェック
    private Boolean checkUnitFee(String feeUnit, String feeAny, Boolean rateCheck, String fieldName) {
        // 未入力はここではチェックしない
        if (String.isEmpty(feeAny)) {
            return true;
        }
        Decimal fee = CommonUtil.stringToDecimal(feeAny);
        // 単位「ヵ月」
        if (feeUnit == CommonConst.PROPERTY_FEEUNIT_MONTH) {
            // 0～99.9の範囲外はNG
            if (!(0 <= fee && fee <= 99.9)) {
                return false;
            }
        }
        if (!rateCheck) {
            // 単位「円」
            if (feeUnit == CommonConst.PROPERTY_FEEUNIT_YEN) {
                // 0以外かつ100未満はNG
                if (!(fee == 0 || fee >= 100)) {
                    return false;
                }
            }
        } else {
            // 単位「％」
            if (feeUnit == CommonConst.PROPERTY_FEEUNIT_RATE) {
                if(fieldName == '広告料'){
                    // 広告料
                    // 0～999の範囲外はNG
                    if (!(0 <= fee && fee <= 999)) {
                        return false;
                    }
                }else{
                    // 0～100の範囲外はNG
                    if (!(0 <= fee && fee <= 100)) {
                        return false;
                    }
                }
                
            }
            // 単位「円」
            if (feeUnit == CommonConst.PROPERTY_FEEUNIT_YEN) {
                // 0以外かつ200以下はNG
                if (!(fee == 0 || fee > 200)) {
                    return false;
                }
            }
        }
        return true;
    }
    // 料金桁数の最大桁チェック
    private void checkInputFeeMaxLength(BusinessLogicException ex, String fee, Integer maxlength, String feeName) {
        if (CommonUtil.stringToDecimal(fee) == null) {
            return;
        }
        if (CommonUtil.stringToDecimal(fee).precision() > maxlength) {
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_PROP_E_FEE_LIMIT_OVER, feeName));
        }
    }

    // 写真（公開）の取得
    private void setPublicPhotoList(){
        // 初期化
        this.publicPhotoData = new ScreenAnyPhotoData();

        // コンポーネントパラメータ設定
        this.publicPhotoGD901001Parameter = new GD901001ParameterClass();
        this.publicPhotoGD901001Parameter.isNew = this.isNew || this.isCopy;
        this.publicPhotoGD901001Parameter.isMosaic = false;
        this.publicPhotoGD901001Parameter.photoType    = CommonConst.S3_PHOTOTYPE_PROPERTY;
        this.publicPhotoGD901001Parameter.photoSubType = CommonConst.S3_PROPERTYPHOTOTYPE_PROPERTPHOTO;
        this.publicPhotoGD901001Parameter.parameter    = CommonConst.S3_PROPERTYPHOTOTYPE_PROPERTPHOTO;
        this.publicPhotoGD901001Parameter.fileName = '';
        this.publicPhotoGD901001Parameter.filePath = '';
        this.publicPhotoGD901001Parameter.isArea = true;
        this.publicPhotoGD901001Parameter.height = '100px';
        this.publicPhotoGD901001Parameter.foreignId   = this.screenPropertyRecord.BuildingForeignID;  //建物の外部ID
        this.publicPhotoGD901001Parameter.foreignId2  = this.screenPropertyRecord.ForeignID;          //物件の外部ID

        // データ取得
        if (!String.isEmpty(this.propertyId) && !this.isCopy) {
            PropertyPhoto__c propPhoto = selectAnyPhotoList(this.propertyId);
            this.publicPhotoData = new ScreenAnyPhotoData(propPhoto, AmazonS3Util.PhotoType.PROPERTY);
            this.screenPropertyRecord.PropertyPhotoId = propPhoto.Id;
        }
        this.publicPhotoGD901001Parameter.registPhotoCount = this.publicPhotoData.photoCount;
        
    }
    // 写真（非公開）の取得
    private void setPrivatePhotoList(){
        // 初期化
        this.privatePhotoData = new ScreenAnyPhotoData();

        // コンポーネントパラメータ設定
        this.privatePhotoGD901001Parameter = new GD901001ParameterClass();
        this.privatePhotoGD901001Parameter.isNew = this.isNew || this.isCopy;
        this.privatePhotoGD901001Parameter.isMosaic = false;
        // this.privatePhotoGD901001Parameter.isMultiple = false;
        this.privatePhotoGD901001Parameter.photoType    = CommonConst.S3_PHOTOTYPE_PROPERTY;
        this.privatePhotoGD901001Parameter.photoSubType = CommonConst.S3_PROPERTYPHOTOTYPE_PRIVATEPHOTO;
        this.privatePhotoGD901001Parameter.parameter    = CommonConst.S3_PROPERTYPHOTOTYPE_PRIVATEPHOTO;
        this.privatePhotoGD901001Parameter.fileName = '';
        this.privatePhotoGD901001Parameter.filePath = '';
        this.privatePhotoGD901001Parameter.isArea = true;
        this.privatePhotoGD901001Parameter.height = '100px';
        this.privatePhotoGD901001Parameter.foreignId   = this.screenPropertyRecord.BuildingForeignID;  //建物の外部ID
        this.privatePhotoGD901001Parameter.foreignId2  = this.screenPropertyRecord.ForeignID;          //物件の外部ID

        // データ取得
        if (!String.isEmpty(this.propertyId) && !this.isCopy) {
            PropertyPhoto__c propPhoto = selectAnyPhotoList(this.propertyId);
            this.privatePhotoData = new ScreenAnyPhotoData(propPhoto, AmazonS3Util.PhotoType.PROPERTY_PRIVATE);
            this.screenPropertyRecord.PropertyPhotoId = propPhoto.Id;
        }
        this.privatePhotoGD901001Parameter.registPhotoCount = this.privatePhotoData.photoCount;


        this.privatePhotoStatsList = new List<ScreenPrivatePhotoStats>();
        this.privatePhotoStatsList.add(new ScreenPrivatePhotoStats(this.privatePhotoData, 'ブレーカー'));
        this.privatePhotoStatsList.add(new ScreenPrivatePhotoStats(this.privatePhotoData, '鍵'));
        this.privatePhotoStatsList.add(new ScreenPrivatePhotoStats(this.privatePhotoData, '照明'));
        this.privatePhotoStatsList.add(new ScreenPrivatePhotoStats(this.privatePhotoData, 'その他'));

    }
    // パノラマ写真の取得
    private void setPanoramaPhotoList(){
        // 初期化
        this.panoramaPhotoData = new ScreenAnyPhotoData();

        // コンポーネントパラメータ設定
        this.panoramaPhotoGD901001Parameter = new GD901001ParameterClass();
        this.panoramaPhotoGD901001Parameter.isNew = this.isNew || this.isCopy;
        this.panoramaPhotoGD901001Parameter.isMosaic = false;
        // this.panoramaPhotoGD901001Parameter.isMultiple = false;
        this.panoramaPhotoGD901001Parameter.photoType    = CommonConst.S3_PHOTOTYPE_PROPERTY;
        this.panoramaPhotoGD901001Parameter.photoSubType = CommonConst.S3_PROPERTYPHOTOTYPE_PANORAMA;
        this.panoramaPhotoGD901001Parameter.parameter    = CommonConst.S3_PROPERTYPHOTOTYPE_PANORAMA;
        this.panoramaPhotoGD901001Parameter.fileName = '';
        this.panoramaPhotoGD901001Parameter.filePath = '';
        this.panoramaPhotoGD901001Parameter.isArea = true;
        this.panoramaPhotoGD901001Parameter.height = '100px';
        this.panoramaPhotoGD901001Parameter.foreignId   = this.screenPropertyRecord.BuildingForeignID;  //建物の外部ID
        this.panoramaPhotoGD901001Parameter.foreignId2  = this.screenPropertyRecord.ForeignID;          //物件の外部ID

        // データ取得
        if (!String.isEmpty(this.propertyId) && !this.isCopy) {
            PropertyPhoto__c propPhoto = selectAnyPhotoList(this.propertyId);
            this.panoramaPhotoData = new ScreenAnyPhotoData(propPhoto, AmazonS3Util.PhotoType.PROPERTY_PANORAMA);
            this.screenPropertyRecord.PropertyPhotoId = propPhoto.Id;
        }
        this.panoramaPhotoGD901001Parameter.registPhotoCount = this.panoramaPhotoData.photoCount;
    }
    // 間取り図の取得
    private void setFloorplanPhotoList(){
        // 初期化
        this.floorplanPhotoData = new ScreenAnyPhotoData();
        this.floorplanPhotoData.photoCount = 0;
        this.floorplanPhotoData.photoDataList.add(new PhotoData());
        this.floorplanPhotoMemoData = new ScreenAnyPhotoData();
        this.floorplanPhotoMemoData.photoCount = 0;
        this.floorplanPhotoMemoData.photoDataList.add(new PhotoData());

        // コンポーネントパラメータ設定
        this.floorplanPhotoGD901001Parameter = new GD901001ParameterClass();
        this.floorplanPhotoGD901001Parameter.isNew = this.isNew || this.isCopy;
        this.floorplanPhotoGD901001Parameter.isMosaic = false;
        // this.floorplanPhotoGD901001Parameter.isMultiple = false;
        this.floorplanPhotoGD901001Parameter.photoType    = CommonConst.S3_PHOTOTYPE_PROPERTY;
        this.floorplanPhotoGD901001Parameter.photoSubType = CommonConst.S3_PROPERTYPHOTOTYPE_ROOMLAYOUT;
        this.floorplanPhotoGD901001Parameter.parameter    = CommonConst.S3_PROPERTYPHOTOTYPE_ROOMLAYOUT;
        this.floorplanPhotoGD901001Parameter.fileName = '';
        this.floorplanPhotoGD901001Parameter.filePath = '';
        this.floorplanPhotoGD901001Parameter.isArea = false;
        this.floorplanPhotoGD901001Parameter.height = '100px';
        this.floorplanPhotoGD901001Parameter.foreignId   = this.screenPropertyRecord.BuildingForeignID;  //建物の外部ID
        this.floorplanPhotoGD901001Parameter.foreignId2  = this.screenPropertyRecord.ForeignID;          //物件の外部ID

        this.floorplanMemoPhotoGD901001Parameter = new GD901001ParameterClass();
        this.floorplanMemoPhotoGD901001Parameter.isNew = this.isNew || this.isCopy;
        this.floorplanMemoPhotoGD901001Parameter.isMosaic = false;
        // this.floorplanMemoPhotoGD901001Parameter.isMultiple = false;
        this.floorplanMemoPhotoGD901001Parameter.photoType    = CommonConst.S3_PHOTOTYPE_PROPERTY;
        this.floorplanMemoPhotoGD901001Parameter.photoSubType = CommonConst.S3_PROPERTYPHOTOTYPE_ROOMLAYOUTMEMO;
        this.floorplanMemoPhotoGD901001Parameter.parameter    = CommonConst.S3_PROPERTYPHOTOTYPE_ROOMLAYOUTMEMO;
        this.floorplanMemoPhotoGD901001Parameter.fileName = '';
        this.floorplanMemoPhotoGD901001Parameter.filePath = '';
        this.floorplanMemoPhotoGD901001Parameter.isArea = false;
        this.floorplanMemoPhotoGD901001Parameter.height = '100px';
        this.floorplanMemoPhotoGD901001Parameter.foreignId   = this.screenPropertyRecord.BuildingForeignID;  //建物の外部ID
        this.floorplanMemoPhotoGD901001Parameter.foreignId2  = this.screenPropertyRecord.ForeignID;          //物件の外部ID

        // データ取得
        if (this.propertyId != null && !this.isCopy) {
            PropertyPhoto__c propPhoto = selectAnyPhotoList(this.propertyId);
            this.floorplanPhotoData     = new ScreenAnyPhotoData(propPhoto, AmazonS3Util.PhotoType.PROPERTY_ROOMLAYOUT);
            this.floorplanPhotoMemoData = new ScreenAnyPhotoData(propPhoto, AmazonS3Util.PhotoType.PROPERTY_ROOMLAYOUTMEMO);
            this.screenPropertyRecord.PropertyPhotoId = propPhoto.Id;
        }
        this.floorplanPhotoGD901001Parameter.registPhotoCount     =  this.floorplanPhotoData.photoCount;
        this.floorplanMemoPhotoGD901001Parameter.registPhotoCount =  this.floorplanPhotoMemoData.photoCount;

    }

    // 削除後の写真情報編集
    private void reloadAnyPhotoAfterDelete(ScreenAnyPhotoData anyPhoto, Integer deleteIndex) {
        // 削除対象以外の写真情報をセットし直す
        List<PhotoData> tempPhotoData = anyPhoto.photoDataList.clone();
        anyPhoto.photoDataList = new List<PhotoData>();
        anyPhoto.photoCount = 0;
        for (Integer i = 0; i < tempPhotoData.size(); i++) {
            if (tempPhotoData[i].Index != deleteIndex) {
                anyPhoto.photoCount += 1;
                anyPhoto.photoDataList.add(tempPhotoData[i].clone());
                anyPhoto.photoDataList[anyPhoto.photoCount - 1].Index = anyPhoto.photoCount;
            }
        }
    }

    // 料金タブの入力内容取得
    private void getFeeTabInput(ScreenProperty screenProperty) {
        // 金額（円）項目設定（単位ヵ月／％は料金計算）
        // 敷金
        screenProperty.SecurityDepositYen       = calcUnitFee(
                                                    screenProperty.SecurityDepositUnit
                                                    ,screenProperty.SecurityDeposit
                                                    ,screenProperty.RentFee);
        // 敷引/償却
        screenProperty.CancellationActualFeeYen = calcUnitFee(
                                                    screenProperty.CancellationActualFeeUnit
                                                    ,screenProperty.CancellationActualFee
                                                    ,screenProperty.RentFee);
        // 保証金
        screenProperty.DepositYen               = calcUnitFee(
                                                    screenProperty.DepositUnit
                                                    ,screenProperty.Deposit
                                                    ,screenProperty.RentFee);
        // 更新料
        screenProperty.RenewalFeeYen            = calcUnitFee(
                                                    screenProperty.RenewalFeeUnit
                                                    ,screenProperty.RenewalFee
                                                    ,screenProperty.RentFee);
        // 礼金
        screenProperty.KeyMoneyYen              = calcUnitFee(
                                                    screenProperty.KeyMoneyUnit
                                                    ,screenProperty.KeyMoney
                                                    ,screenProperty.RentFee);
        // 定額修繕費/クリーニング費
        screenProperty.CleaningFeeYen           = calcUnitFee(
                                                    screenProperty.CleaningFeeUnit
                                                    ,screenProperty.CleaningFee
                                                    ,screenProperty.RentFee);
        // 駐車場保証料金
        screenProperty.ParkingDepositYen        = calcUnitFee(
                                                    screenProperty.ParkingDepositUnit
                                                    ,screenProperty.ParkingDeposit
                                                    ,screenProperty.RentFee);
        // 駐車場手数料
        screenProperty.ParkingCompoundingFeeYen = calcUnitFee(
                                                    screenProperty.ParkingCompoundingFeeUnit
                                                    ,screenProperty.ParkingCompoundingFee
                                                    ,screenProperty.RentFee);
        // 広告料
        screenProperty.ADFeeYen                 = calcUnitFee(
                                                    screenProperty.ADFeeUnit
                                                    ,screenProperty.ADFee
                                                    ,screenProperty.RentFee);

        // 選択されている料金単位に伴って、円以外の料金項目を更新
        // 敷金
        screenProperty.SecurityDepositMonth         = screenProperty.SecurityDepositUnit == CommonConst.PROPERTY_FEEUNIT_MONTH
                                                    ? screenProperty.SecurityDeposit : '';
        // 敷引/償却
        screenProperty.CancellationActualFeeMonth   = screenProperty.CancellationActualFeeUnit == CommonConst.PROPERTY_FEEUNIT_MONTH
                                                    ? screenProperty.CancellationActualFee : '';
        screenProperty.CancellationActualFeeRate    = screenProperty.CancellationActualFeeUnit == CommonConst.PROPERTY_FEEUNIT_RATE
                                                    ? screenProperty.CancellationActualFee : '';
        // 保証金
        screenProperty.DepositMonth                 = screenProperty.DepositUnit == CommonConst.PROPERTY_FEEUNIT_MONTH
                                                    ? screenProperty.Deposit : '';
        // 更新料
        screenProperty.RenewalFeeMonth              = screenProperty.RenewalFeeUnit == CommonConst.PROPERTY_FEEUNIT_MONTH
                                                    ? screenProperty.RenewalFee : '';
        // 礼金
        screenProperty.KeyMoneyMonth                = screenProperty.KeyMoneyUnit == CommonConst.PROPERTY_FEEUNIT_MONTH
                                                    ? screenProperty.KeyMoney : '';
        // 定額修繕費/クリーニング費
        screenProperty.CleaningFeeMonth             = screenProperty.CleaningFeeUnit == CommonConst.PROPERTY_FEEUNIT_MONTH
                                                    ? screenProperty.CleaningFee : '';
        // 駐車場保証料金
        screenProperty.ParkingDepositMonth          = screenProperty.ParkingDepositUnit == CommonConst.PROPERTY_FEEUNIT_MONTH
                                                    ? screenProperty.ParkingDeposit : '';
        // 駐車場手数料
        screenProperty.ParkingCompoundingFeeMonth   = screenProperty.ParkingCompoundingFeeUnit == CommonConst.PROPERTY_FEEUNIT_MONTH
                                                    ? screenProperty.ParkingCompoundingFee : '';
        // 広告料
        screenProperty.ADFeeMonth                   = screenProperty.ADFeeUnit == CommonConst.PROPERTY_FEEUNIT_MONTH
                                                    ? screenProperty.ADFee : '';
        screenProperty.ADFeeRate                    = screenProperty.ADFeeUnit == CommonConst.PROPERTY_FEEUNIT_RATE
                                                    ? screenProperty.ADFee : '';

        // 税等 区分値取得
        // 水道料金税区分
        screenProperty.WortFeeTaxType               = String.isEmpty(screenProperty.WortFee)
                                                    ? '' : this.selectWortFeeTaxTypeList.getCheckValue();
        // 管理費税区分
        screenProperty.ManagementFeeTaxType         = String.isEmpty(screenProperty.ManagementFee)
                                                    ? '' : this.selectManagementFeeTaxTypeList.getCheckValue();
        // CATV税区分
        screenProperty.CATVTaxType                  = String.isEmpty(screenProperty.CATVFee)
                                                    ? '' : this.selectCATVTaxTypeList.getCheckValue();
        // 更新料税区分
        screenProperty.RenewalFeeTaxType            = String.isEmpty(screenProperty.RenewalFee)
                                                    ? '' : this.selectRenewalFeeTaxTypeList.getCheckValue();
        // 町会費税区分
        screenProperty.TownshipFeeTaxType           = String.isEmpty(screenProperty.TownshipFee)
                                                    ? '' : this.selectTownshipFeeTaxTypeList.getCheckValue();
        // ゴミ処理費税区分
        screenProperty.GarbageDisposalFeeTaxType    = String.isEmpty(screenProperty.GarbageDisposalFee)
                                                    ? '' : this.selectGarbageDisposalFeeTaxTypeList.getCheckValue();
        // 入町費税区分
        screenProperty.TownshipInitialFeeTaxType    = String.isEmpty(screenProperty.TownshipInitialFee)
                                                    ? '' : this.selectTownshipInitialFeeTaxTypeList.getCheckValue();
        // 鍵交換費税区分
        screenProperty.KeyExchangeFeeTaxType        = String.isEmpty(screenProperty.KeyExchangeFee)
                                                    ? '' : this.selectKeyExchangeFeeTaxTypeList.getCheckValue();
        // 駐輪場代税区分
        screenProperty.BicycleParkingFeeTaxType     = String.isEmpty(screenProperty.BicycleParkingFee)
                                                    ? '' : this.selectBicycleParkingFeeTaxTypeList.getCheckValue();
        // 定額修繕費税区分
        screenProperty.CleaningFeeTaxType           = String.isEmpty(screenProperty.CleaningFee)
                                                    ? '' : this.selectCleaningFeeTaxTypeList.getCheckValue();
        // 駐車場料金税区分
        screenProperty.ParkingFeeTaxType            = String.isEmpty(screenProperty.ParkingFee)
                                                    ? '' : this.selectParkingFeeTaxTypeList.getCheckValue();
        // 駐車場保証料金税区分
        screenProperty.ParkingDepositTaxType        = String.isEmpty(screenProperty.ParkingDeposit)
                                                    ? '' : this.selectParkingDepositTaxTypeList.getCheckValue();
        // 駐車場手数料税区分
        screenProperty.ParkingCompoundingFeeTaxType = String.isEmpty(screenProperty.ParkingCompoundingFee)
                                                    ? '' : this.selectParkingCompoundingFeeTaxTypeList.getCheckValue();
        // 小型バイク置場料金税区分
        screenProperty.BikeParkingSmallFeeTaxType   = String.isEmpty(screenProperty.BikeParkingSmallFee)
                                                    ? '' : this.selectBikeParkingSmallFeeTaxTypeList.getCheckValue();
        // 中型バイク置場料金税区分
        screenProperty.BikeParkingMediumFeeTaxType  = String.isEmpty(screenProperty.BikeParkingMediumFee)
                                                    ? '' : this.selectBikeParkingMediumFeeTaxTypeList.getCheckValue();
        // 大型バイク置場料金税区分
        screenProperty.BikeParkinLargeFeeTaxType    = String.isEmpty(screenProperty.BikeParkinLargeFee)
                                                    ? '' : this.selectBikeParkinLargeFeeTaxTypeList.getCheckValue();
        // 広告料税区分
        screenProperty.ADFeeTaxType                 = String.isEmpty(screenProperty.ADFee)
                                                    ? '' : this.selectADFeeTaxTypeList.getCheckValue();
        // 報酬形態
        screenProperty.RewardType                   = this.selectRewardTypeList.getCheckValue();

        // 火災保険
        screenProperty.FireInsurancePlan = null;
        Integer fireInsuranceCount = 1;
        for (ScreenFireInsuranceItem item : this.fireInsuranceItemList) {
            if (item.IsChecked2) {
                screenProperty.FireInsuranceCompany = item.AccountId;
                screenProperty.FireInsurancePlan = item.Id;
                this.saveFireInsuranceCheckedCount = fireInsuranceCount;
            }
            fireInsuranceCount++;
        }
        // 保証会社
        screenProperty.Guaranteeid = null;
        Integer guaranteePlanCount = 1;
        for (ScreenGuaranteePlanItem item : this.guaranteePlanItemList) {
            if (item.IsChecked2) {
                screenProperty.GuaranteeidCompany = item.AccountId;
                screenProperty.Guaranteeid = item.Id;
                this.saveGuaranteePlanCheckedCount = guaranteePlanCount;
            }
            guaranteePlanCount++;
        }

    }

    // 手動メンテ数の加算
    private void manualMaintenanceCount(datetime nowDateTime) {
        Boolean manualMaintenanceDuplicateFlg = false;   // 手動メンテ重複フラグ
        for(PropertyMaintenanceHistory__c  propertyMaintenanceHistory:propertyMaintenanceHistoryList){
            // 物件メンテナンス履歴にて本日更新で現ユーザが元付物件詳細から更新されている場合に件数を加算しない。
            if(propertyMaintenanceHistory.MaintenanceAction__c    == CommonConst.PROPERTY_MAINTENANCEACTION_ORIGINALPROPERTYDETAILS &&
               propertyMaintenanceHistory.MaintenanceStaff__c     == UserInfo.getUserId() &&
               propertyMaintenanceHistory.CreatedDate.date()      == nowDateTime.date()){
                manualMaintenanceDuplicateFlg = true;
                break;
            }
        }
        if(!manualMaintenanceDuplicateFlg){
            // 日報情報更新、手動メンテ数を1加算する。
            DailyReportUtil.upsertDailyReportManualMaintenance(); 
        }
    }

    // 料金の単位計算
    private String calcUnitFee(String feeUnit, String feeAny, String rentFee) {
        // 計算不要の場合は対応値を返却
        // 単位「円」は計算不要
        if (feeUnit == CommonConst.PROPERTY_FEEUNIT_YEN) {
            return feeAny;
        }
        // 単位「実費」は空白
        if (feeUnit == CommonConst.PROPERTY_FEEUNIT_ACTUALCOST) {
            return '';
        }
        // 入力値null/空は空白
        if (String.isEmpty(feeAny)) {
            return '';
        }
        // 賃料null/空は空白
        if (String.isEmpty(rentFee)) {
            return '';
        }


        // 計算前準備
        // 賃料Decimal変換
        Decimal rentFeeDec = CommonUtil.stringToDecimal(rentFee);

        // 金額計算
        Decimal calcFee;
        if (feeUnit == CommonConst.PROPERTY_FEEUNIT_MONTH) {
            // 単位「ヵ月」
            // 計算 賃料×ヵ月
            calcFee = rentFeeDec * CommonUtil.stringToDecimal(feeAny);
            // 切り上げ
            calcFee = calcFee.round(System.RoundingMode.UP);
        } else if (feeUnit == CommonConst.PROPERTY_FEEUNIT_RATE) {
            // 単位「％」
            // 計算 賃料×％÷100
            calcFee = rentFeeDec * CommonUtil.stringToDecimal(feeAny) / 100;
            // 切り上げ
            calcFee = calcFee.round(System.RoundingMode.UP);
        }
        // 計算値String変換
        String retFee = CommonUtil.decimalToString(calcFee);
        // null ⇒ 空白変換
        retFee = String.isEmpty(retFee) ? '' : retFee;
        // 計算値返却
        return retFee;
    }

    // Decimalのnull=>0変換
    private Decimal getNullToDecimalValue(Decimal dec) {
        return dec == null ? 0 : dec;
    }

    // SystemModStampのチェック
    private Boolean checkSystemModStamp(Id propertyId) {
        Datetime nowDatetime = this.getSystemModStamp(propertyId);
        if (nowDatetime != this.screenPropertyRecord.SystemModStamp) {
            return false;
        }
        return true;
    }
    // SystemModStampの取得
    private Datetime getSystemModStamp(Id propertyId) {
        List<Property__c> prop = [
            SELECT
                SystemModStamp
            FROM
                Property__c
            WHERE
                Id = :propertyId
        ];
        if (prop.size() == 0) {
            return null;
        }
        return prop[0].SystemModStamp;
    }


    // 物件レコード情報取得
    private Property__c selectProperty(Id propertyId){
        List<Property__c> targetProperty = [
            SELECT
                Id                                          // Id
                ,PropertyCode__c                            // 物件コード
                ,AllRentFee__c                              // 総賃料
                ,Score__c                                   // 点数
                ,IsMergeCompletedFlag__c                    // 名寄せ完了フラグ
                ,Building__c                                // 建物Id
                ,Name                                       // 部屋番号
                ,LivedType__c                               // 未入居種別
                ,LiveStatus__c                              // 現況
                ,FloorType__c                               // 地下階区分
                ,Floor__c                                   // 所在階
                ,RoomCount__c                               // 部屋数
                ,RoomLayout__c                              // 間取り
                ,RoomArea__c                                // 専有面積（㎡）
                ,BalconyArea__c                             // バルコニー面積
                ,BalconyDirection__c                        // バルコニー方向
                ,KeyPlace__c                                // 鍵所在
                ,ContractTermYear__c                        // 契約期間（年）
                ,ContractTermMonth__c                       // 契約期間（月）
                ,IsOwnCompanyPropertyFlag__c                // 自社物フラグ
                ,RentType__c                                // 定期借家区分
                ,RentTermYear__c                            // 定借期間（年）
                ,RentTermMonth__c                           // 定借期間（月）
                ,RentTermDay__c                             // 定借期間（日）
                ,RenovationComplateYear__c                  // リノベ施工完了（年）
                ,RenovationComplateMonth__c                 // リノベ施工完了（月）
                ,RenovationContent__c                       // リノベ施工内容
                ,FreeRentTermMonth__c                       // フリーレント期間（ヶ月）
                ,FreeRentContent__c                         // フリーレント内容
                ,SpecificExcellentRentBurdenUpperLimit__c   // 特優賃入居負担額上限
                ,SpecificExcellentRentBurdenLowerLimit__c   // 特優賃入居負担額下限
                ,SpecificExcellentRentFeeFluctuationType__c // 特優賃料金変動区分
                ,SpecificExcellentRentFeeUpwardRate__c      // 特優賃上昇率
                ,SpecificExcellentRentSupportYears__c       // 特優賃家賃補助年数
                ,SpecificExcellentRentRemarks__c            // 特優賃備考
                ,PropertyRemarksPublic__c                   // 物件備考（公開）
                ,PropertyRemarksPrivate__c                  // 物件備考（非公開）
                ,TransactionAspect__c                       // 取引態様
                ,DeliveryType__c                            // 引渡種別
                ,DeliveryYear__c                            // 引渡年
                ,DeliveryMonth__c                           // 引渡月
                ,DeliveryTiming__c                          // 引渡旬
                ,DeliveryDay__c                             // 引渡日
                ,DeliveryConsultation__c                    // 引渡・入居日（相談内容）
                ,PropertyComment__c                         // 物件コメント
                ,RepresentativeComment__c                   // 担当者コメント
                ,RentFee__c                                 // 賃料
                ,WortFee__c                                 // 水道料金
                ,WortFeeTaxType__c                          // 水道料金税区分
                ,SecurityDepositYen__c                      // 敷金（円）
                ,SecurityDepositMonth__c                    // 敷金（ヵ月）
                ,SecurityDepositUnit__c                     // 敷金単位
                ,RenewalFeeYen__c                           // 更新料（円）
                ,RenewalFeeMonth__c                         // 更新料（ヵ月）
                ,RenewalFeeUnit__c                          // 更新料単位
                ,RenewalFeeTaxType__c                       // 更新料税区分
                ,ManagementFee__c                           // 管理費
                ,ManagementFeeTaxType__c                    // 管理費税区分
                ,CATVFee__c                                 // CATV
                ,CATVTaxType__c                             // CATV税区分
                ,DepositYen__c                              // 保証料金（円）
                ,DepositMonth__c                            // 保証料金（ヵ月）
                ,DepositUnit__c                             // 保証金単位
                ,TownshipInitialFee__c                      // 入町費
                ,TownshipInitialFeeTaxType__c               // 入町費税区分
                ,TownshipFee__c                             // 町会費
                ,TownshipFeeTaxType__c                      // 町会費税区分
                ,TownshipFeePaymentType__c                  // 町会費支払区分
                ,GarbageDisposalFee__c                      // ゴミ処理費
                ,GarbageDisposalFeeTaxType__c               // ゴミ処理費税区分
                ,GarbageDisposalFeePaymentType__c           // ゴミ処理費支払区分
                ,KeyMoneyYen__c                             // 礼金（円）
                ,KeyMoneyMonth__c                           // 礼金（ヵ月）
                ,KeyMoneyUnit__c                            // 礼金単位
                ,KeyExchangeFee__c                          // 鍵交換費
                ,KeyExchangeFeeTaxType__c                   // 鍵交換費税区分
                ,BicycleParkingType__c                      // 駐輪場種別
                ,BicycleParkingFee__c                       // 駐輪場代
                ,BicycleParkingFeeTaxType__c                // 駐輪場代税区分
                ,CancellationActualFeeYen__c                // 敷引・償却（円）
                ,CancellationActualFeeMonth__c              // 敷引・償却（ヵ月）
                ,CancellationActualFeeRate__c               // 敷引・償却（％）
                ,CancellationActualFeeUnit__c               // 敷引・償却単位
                ,CleaningFeeYen__c                          // 定額修繕費（円）
                ,CleaningFeeMonth__c                        // 定額修繕費（ヵ月）
                ,CleaningFeeUnit__c                         // 定額修繕費単位
                ,CleaningFeeTaxType__c                      // 定額修繕費税区分
                ,CleaningFeePaymentType__c                  // 定額修繕費支払区分
                ,ParkingType__c                             // 駐車場種別
                ,ParkingFee__c                              // 駐車場料金
                ,ParkingFeeTaxType__c                       // 駐車場料金税区分
                ,ParkingDistance__c                         // 近隣駐車場までの距離
                ,ParkingDepositYen__c                       // 駐車場保証料金
                ,ParkingDepositMonth__c                     // 駐車場保証料金（ヵ月）
                ,ParkingDepositTaxType__c                   // 駐車場保証料金税区分
                ,ParkingDepositUnit__c                      // 駐車場保証料金単位
                ,ParkingCompoundingFeeYen__c                // 駐車場手数料（円）
                ,ParkingCompoundingFeeMonth__c              // 駐車場手数料（ヵ月）
                ,ParkingCompoundingFeeUnit__c               // 駐車場手数料単位
                ,ParkingCompoundingFeeTaxType__c            // 駐車場手数料税区分
                ,ParkingRemarksPublic__c                    // 駐車場備考（公開）
                ,ParkingRemarksPrivate__c                   // 駐車場備考（非公開）
                ,BikeStorageType__c                         // バイク置場種別
                ,BikeParkingSmallFee__c                     // 小型バイク置場料金
                ,BikeParkingSmallFeeTaxType__c              // 小型バイク置場料金税区分
                ,BikeParkingMediumFee__c                    // 中型バイク置場料金
                ,BikeParkingMediumFeeTaxType__c             // 中型バイク置場料金税区分
                ,BikeParkinLargeFee__c                      // 大型バイク置場料金
                ,BikeParkinLargeFeeTaxType__c               // 大型バイク置場料金税区分
                ,IsShortTermPenalty__c                      // 短期解約違約金有無
                ,ShortTermPenaltyLessYear__c                // 短期解約違約金未満（年）
                ,ShortTermPenaltyFee__c                     // 短期解約違約金
                ,ShortTermPenaltyLessYear2__c               // 短期解約違約金未満（年）２
                ,ShortTermPenaltyFee2__c                    // 短期解約違約金２
                ,MonetaryPublic__c                          // 金銭備考（公開）
                ,MonetaryPrivate__c                         // 金銭備考（非公開）
                ,FireInsuranceUseType__c                    // 火災保険料（加入義務）
                ,FireInsuranceCompany__c                    // 火災保険会社
                ,FireInsurancePlan__c                       // 火災保険タイトル
                ,GuaranteeidCompanyType__c                  // 保証会社（利用区分）
                ,GuaranteeidCompany__c                      // 保証会社
                ,Guaranteeid__c                             // 保証タイトル
                ,AthomePanoramaContentsId__c                // athomeパノラマコンテンツID
                ,AtHomePanoramaShop__c                      // athomeパノラマ掲載店舗Id
                ,AtHomePanoramaShop__r.Name                 // athomeパノラマ掲載店舗
                ,HomesPanoramaShop__r.Name                  // HOME'Sパノラマ掲載店舗
                ,SuumoPanoramaShop__r.Name                  // SUUMOパノラマ掲載店舗
                ,RewardType__c                              // 報酬形態
                ,RewardBurdenLender__c                      // 報酬負担貸主
                ,RewardBurdenBorrower__c                    // 報酬負担借主
                ,RewardSplitFormerSupplier__c               // 報酬配分元付
                ,RewardSplitCustomer__c                     // 報酬配分客付
                ,ADFeeYen__c                                // 広告料（円）
                ,ADFeeMonth__c                              // 広告料（ヵ月）
                ,ADFeeRate__c                               // 広告料（％）
                ,ADFeeUnit__c                               // 広告料単位
                ,ADFeeTaxType__c                            // 広告料税区分
                ,ADFeeComment__c                            // 広告料コメント
                ,ADRemarksPublic__c                         // 広告備考（公開）
                ,ADRemarksPrivate__c                        // 広告備考（非公開）
                ,ImportType__c                              // 取込区分
                ,MaintenancePropertyCode__c                 // メンテナンス物件コード
                ,WebPublishing__c                           // Web公開
                ,IsPropertyNameHiddenFlag__c                // 物件名非表示フラグ
                ,ManualMaintenanceDate__c                   // 手動最終メンテナンス日
                ,AutoMaintenanceDate__c                     // 自動最終メンテナンス日
                ,HomesPropertyFeature__c                        // HOME'S物件の特徴元
                ,HomesPropertyFeature__r.ExampleSentence__c     // HOME'S物件の特徴
                ,HomesRemarks__c                            // HOME'S備考
                ,SuumoNetCatch__c                               // SUUMOネット用キャッチ元
                ,SuumoNetCatch__r.ExampleSentence__c            // SUUMOネット用キャッチ
                ,SuumoNetCatchComment__c                        // SUUMOネット用キャッチコメント元
                ,SuumoNetCatchComment__r.ExampleSentence__c     // SUUMOネット用キャッチコメント
                ,SuumoRemarks__c                            // SUUMO備考
                ,AthomeRecommendComment__c                      // athomeおすすめコメント元
                ,AthomeRecommendComment__r.ExampleSentence__c   // athomeおすすめコメント
                ,AthomeRecommendCommentStaffId__c           // athomeおすすめコメントスタッフID
                ,AtHomeRemarks__c                           // athome備考
				,ChintaiMagazineComment__c					// CHINTAI雑誌コメント元 2022.03.25　CHINTAI対応追加
				,ChintaiMagazineComment__r.ExampleSentence__c // CHINTAI雑誌コメント 2022.03.25　CHINTAI対応追加
                ,ForeignID__c                               // 外部Id
                ,FormerSupplier__r.Id                           // 元付業者．ID
                ,FormerSupplier__r.Name                         // 元付業者．名前
                ,FormerSupplierPhone__c                         // 元付業者電話番号
                ,FormerSupplierFax__c                           // 元付業者Fax
                ,FormerSupplierPostalCode__c                    // 元付業者郵便番号
                ,FormerSupplierAddress__c                       // 元付業者住所
                ,FormerSupplierState__c                         // 元付業者都道府県
                ,FormerSupplierCity__c                          // 元付業者住所１（市区町村）
                ,FormerSupplierStreet__c                        // 元付業者住所２（番地）
                ,FormerSupplierEmail__c                         // 元付業者メール
                ,FormerSupplierRepresentative__c                // 元付業者担当者
                ,FormerSupplierRepresentativePhone__c           // 元付業者担当者電話番号
                ,FormerSupplier__r.RemarksPublic__c             // 元付業者備考
                ,FormerSupplier__r.IsMergeCompletedFlag__c      // 元付業者名寄せ完了フラグ
                ,Creditor__r.Id                                 // 貸主．ID
                ,Creditor__r.Name                               // 貸主．名前
                ,CreditorPhone__c                               // 貸主電話番号
                ,CreditorFax__c                                 // 貸主Fax
                ,CreditorPostalCode__c                          // 貸主郵便番号
                ,CreditorAddress__c                             // 貸主住所
                ,CreditorState__c                               // 貸主都道府県
                ,CreditorCity__c                                // 貸主住所１（市区町村）
                ,CreditorStreet__c                              // 貸主住所２（番地）
                ,CreditorEmail__c                               // 貸主メール
                ,CreditorRepresentative__c                      // 貸主担当者
                ,CreditorRepresentativePhone__c                 // 貸主担当者電話番号
                ,Creditor__r.RemarksPublic__c                   // 貸主備考
                ,Creditor__r.IsMergeCompletedFlag__c            // 貸主名寄せ完了フラグ
                ,Owner__r.Id                                    // 所有者．ID
                ,Owner__r.Name                                  // 所有者．名前
                ,OwnerPhone__c                                  // 所有者電話番号
                ,OwnerFax__c                                    // 所有者Fax
                ,OwnerPostalCode__c                             // 所有者郵便番号
                ,OwnerAddress__c                                // 所有者住所
                ,OwnerState__c                                  // 所有者都道府県
                ,OwnerCity__c                                   // 所有者住所１（市区町村）
                ,OwnerStreet__c                                 // 所有者住所２（番地）
                ,OwnerEmail__c                                  // 所有者メール
                ,OwnerRepresentative__c                         // 所有者担当者
                ,OwnerRepresentativePhone__c                    // 所有者担当者電話番号
                ,Owner__r.RemarksPublic__c                      // 所有者備考
                ,Owner__r.IsMergeCompletedFlag__c               // 所有者名寄せ完了フラグ
                ,PropertyDetailUrl__c                           // 物件詳細画面URL
                ,IsPermissionPublishing__c                      // 2020/5/8追加：掲載許可済みフラグ
                ,(
                    SELECT
                        Id                                      // Id
                        ,Property__c                            // 物件
                        ,IsRenovation__c                        // リノベーション
                        ,IsFreeRent__c                          // フリーレント
                        ,IsSpecialRent__c                       // 特定優良賃貸住宅
                        ,IsPluralCarParking__c                  // 駐車場2台可
                        ,IsQuietResidenceTown__c                // 閑静な住宅街
                        ,IsTowerMansion__c                      // タワーマンション
                        ,IsDesigners__c                         // デザイナーズ
                        ,IsBarrierFree__c                       // バリアフリー
                        ,IsOuterWallTile__c                     // 外壁タイル張り
                        ,IsCondominiumRental__c                 // 分譲賃貸
                        ,IsDampingStructure__c                  // 制震構造
                        ,IsSeismicStructure__c                  // 耐震構造
                        ,IsSeismicIsolationStructure__c         // 免震構造
                        ,IsFirstFloor__c                        // 1階の物件
                        ,IsSecondFloorOver__c                   // 2階以上
                        ,IsTopFloor__c                          // 最上階
                        ,IsElevator__c                          // エレベーター
                        ,IsPluralElevators__c                   // エレベーター2基
                        ,IsFrontService__c                      // フロントサービス
                        ,IsDeliveryBox__c                       // 宅配ボックス
                        ,IsCleaningBox__c                       // クリーニングボックス
                        ,IsCoinLaundry__c                       // コインランドリー
                        ,IsAnytimeTtrashArea__c                 // 24時間ゴミ出し可
                        ,IsInSiteTtrashArea__c                  // 敷地内ごみ置き場
                        ,IsSepticTank__c                        // 浄化槽
                        ,IsCornerRoom__c                        // 角部屋
                        ,IsBayWindow__c                         // 出窓
                        ,IsPrivateGarden__c                     // 専用庭
                        ,IsAutoLock__c                          // オートロック
                        ,IsAnytimeSecurity__c                   // 24時間セキュリティ
                        ,IsSecurityCompanyJoin__c               // セキュリティ会社加入済
                        ,IsDimpleKey__c                         // ディンプルキー
                        ,IsSurveillanceCamera__c                // 防犯カメラ
                        ,IsSecurityGlass__c                     // 防犯ガラス
                        ,IsMaisonette__c                        // メゾネット
                        ,IsLoft__c                              // ロフト
                        ,IsUndergroundRoom__c                   // 地下室
                        ,IsSoundproofRoom__c                    // 防音室
                        ,IsAllWesternStyleRoom__c               // オール洋室
                        ,IsBuiltInGarage__c                     // ビルトインガレージ
                        ,IsCarport__c                           // カーポート
                        ,IsGasStove__c                          // ガスコンロ付き
                        ,IsTwoGasStove__c                       // コンロ2口
                        ,IsMoreGasStove__c                      // コンロ3口以上
                        ,IsIhStove__c                           // IHコンロ
                        ,IsElectricStove__c                     // 電気コンロ
                        ,IsCityGas__c                           // 都市ガス
                        ,IsPropaneGas__c                        // プロパンガス
                        ,IsCounterKitchen__c                    // カウンターキッチン
                        ,IsSystemKitchen__c                     // システムキッチン
                        ,IsWaterPurifier__c                     // 浄水器
                        ,IsDishwasher__c                        // 食器洗い乾燥機
                        ,IsDisposer__c                          // ディスポーザー
                        ,IsSeparate__c                          // バス・トイレ別
                        ,IsShowerRoom__c                        // シャワールーム
                        ,IsMistSauna__c                         // ミストサウナ
                        ,IsTvBath__c                            // TV付浴室
                        ,IsReheating__c                         // 追焚機能
                        ,IsHotWaterFormula__c                   // 高温差湯式
                        ,IsBathroomDryer__c                     // 浴室乾燥機
                        ,IsBathroomFloorHeating__c              // 浴室床暖房
                        ,IsWashletToiletSeat__c                 // 温水洗浄便座
                        ,IsTanklessToilet__c                    // タンクレストイレ
                        ,IsShowerWashBasin__c                   // シャワー付洗面台
                        ,IsWashroomDscrete__c                   // 洗面所独立
                        ,IsFloorHeating__c                      // 床暖房
                        ,IsGasHeating__c                        // ガス暖房
                        ,IsKeroseneHeating__c                   // 灯油暖房
                        ,IsAllElectric__c                       // オール電化
                        ,IsAirConditioner__c                    // エアコン付き
                        ,IsFurniture__c                         // 家具付き
                        ,IsHomeAppliance__c                     // 家電付
                        ,IsWashingDryer__c                      // 洗濯乾燥機
                        ,IsBalcony__c                           // バルコニー
                        ,IsRoofBalcony__c                       // ルーフバルコニー
                        ,IsWoodDeck__c                          // ウッドデッキ
                        ,IsFlooring__c                          // フローリング
                        ,IsCushionFloor__c                      // クッションフロア
                        ,IsSolidWood__c                         // 無垢材使用
                        ,IsIndoorWashingMachineStorage__c       // 室内洗濯機置場
                        ,IsStormShutter__c                      // 雨戸
                        ,IsShutter__c                           // シャッター
                        ,IsElectricShutter__c                   // 電動シャッター
                        ,IsHighSash__c                          // ハイサッシ
                        ,IsSoundproofSash__c                    // 防音サッシ
                        ,IsPairGlass__c                         // 複層ガラス
                        ,IsShoesBox__c                          // シューズボックス
                        ,IsShoeCloak__c                         // シューズクローク
                        ,IsTrunkRoom__c                         // トランクルーム
                        ,IsUnderfloorStorage__c                 // 床下収納
                        ,IsWalkInCloset__c                      // ウォークインクローゼット
                        ,IsBSAntenna__c                         // BSアンテナ
                        ,IsCSAntenna__c                         // CSアンテナ
                        ,IsCATV__c                              // CATV
                        ,IsCATVInternet__c                      // CATVインターネット
                        ,IsCATVFree__c                          // CATV使用料不要
                        ,IsOpticalFiber__c                      // 光ファイバー
                        ,IsInternetFree__c                      // ネット使用料無料
                        ,IsMonitorIntercom__c                   // モニタ付インターホン
                        ,IsRentCreditPayment__c                 // 家賃カード決済可
                        ,IsInitialCostCreditPayment__c          // 初期費用カード決済可
                        ,IsITImportantDescription__c            // IT重説 対応物件
                        ,IsNoGuarantor__c                       // 保証人不要
                        ,IsCustomize__c                         // カスタマイズ可
                        ,IsDIY__c                               // DIY可
                        ,IsMusicalInstruments__c                // 楽器相談可
                        ,IsPet__c                               // ペット相談
                        ,IsLargePet__c                          // ペット（大型犬）
                        ,IsMiddlePet__c                         // ペット（中型犬）
                        ,IsSmallPet__c                          // ペット（小型犬）
                        ,IsCat__c                               // ペット（猫）
                        ,IsOtherPet__c                          // ペット（その他）
                        ,PetRemarks__c                          // ペット（その他）備考
                        ,IsTwoTenant__c                         // 2人入居可
                        ,IsWoman__c                             // 女性限定
                        ,IsLbgt__c                              // LGBTフレンドリー
                        ,IsElderly__c                           // 高齢者歓迎
                        ,IsRoomShare__c                         // ルームシェア可
                        ,IsMonthly__c                           // マンスリー可
                        ,IsOfficeAvailable__c                   // 事務所利用可
                        ,IsForeigner__c                         // 外国人契約可
                        ,IsStudent__c                           // 学生限定マンション
                        ,IsNotChild__c                          // 子供不可
                        ,IsWelfareAvailable__c                  // 生活保護契約可
                        ,IsCorporation__c                       // 法人契約限定
                        ,IsTwoStation__c                        // 2駅利用可
                        ,IsTwoTrainRoute__c                     // 2沿線利用可
                        ,IsThreeStation__c                      // 3駅以上利用可
                        ,IsThreeTrainRoute__c                   // 3沿線以上利用可
                        ,IsFrontStation__c                      // 駅前
                        ,IsParking__c                           // 駐車場あり
                        ,IsInSiteParking__c                     // 敷地内駐車場
                        ,IsBicycleParking__c                    // 駐輪場
                        ,IsBikeStorage__c                       // バイク置場
                        ,IsSmallBike__c                         // 小型バイク
                        ,IsMediumBike__c                        // 中型バイク
                        ,IsLargeBike__c                         // 大型バイク
                        ,IsSouth__c                             // 南向き
                        ,IsJanitor__c                           // 管理人あり
                        ,IsJanitorReside__c                     // 管理人（常駐）
                        ,IsJanitorCommuter__c                   // 管理人（通勤）
                        ,IsJanitorPatrol__c                     // 管理人（巡回）
                        ,IsTurnkey__c                           // 即入居可
                        ,IsNotFixedTermTenant__c                // 定期借家を含まない
                        ,ContractRemarks__c                     // 契約備考
                        ,FacilityRemarksPublic__c               // 設備備考（公開）
                        ,FacilityRemarksPrivate__c              // 設備備考（非公開）
                    FROM PropertyConditionsProperty__r
                )
                ,(  SELECT
                        Id
                    FROM PropertyPhotoProperty__r   // 物件写真
                )
                ,SystemModStamp
            FROM Property__c
            WHERE
                Id = :propertyId
        ];
        // レコードが取得できない場合はビジネスロジックExceptionを発行する
        if(targetProperty.isEmpty()){
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
            throw ex;
        }
        return targetProperty[0];
    }

    // 部屋情報取得
    private List<Room__c> selectRoom(Id propertyId){
        List<Room__c> room = [
            SELECT
                Id
                ,Property__c        // 物件
                ,Name               // 間取り詳細番号
                ,RoomType__c        // 部屋タイプ
                ,RoomFloorSpace__c  // 部屋帖数
            FROM Room__c            // 部屋
            WHERE
                Property__c = :propertyId
            ORDER BY
                Name
        ];
        if (room.isEmpty()){
            room = new List<Room__c>();
        }
        return room;
    }

    // 添付ファイルレコード情報取得
    private List<Attachment> selectPropertyAttachments(Id propertyId){
        List<Attachment> PropertyAttachments = [
            SELECT
                Id
                ,ParentId           // 参照先Id（物件Id）
                ,Name               // ファイル名
                ,LastModifiedDate   // 最終更新日
                ,BodyLength         // 内容の長さ
                ,ContentType        // コンテンツタイプ
            FROM Attachment         // 添付ファイル
            WHERE
                ParentId    = :propertyId
            ORDER BY
                LastModifiedDate
        ];
        if (PropertyAttachments.isEmpty()){
            PropertyAttachments = new List<Attachment>();
        }
        return PropertyAttachments;
    }

    // 物件メンテナンス履歴情報取得
    private List<PropertyMaintenanceHistory__c> selectPropertyMaintenanceHistory(Id propertyId){
        List<PropertyMaintenanceHistory__c> PropertyMaintenanceHistory = [
            SELECT
                Id
                ,CreatedDate                    // メンテナンス日時
                ,MaintenanceType__c             // メンテナンス区分
                ,MaintenanceStaff__r.Name       // メンテナンススタッフ
                ,MaintenanceCommentArea__c      // メンテナンスコメント
                ,MaintenanceAction__c           // メンテナンスアクション元画面
                ,MaintenanceStaff__c            // メンテナンススタッフID
                ,LastModifiedDate               // 更新日
            FROM PropertyMaintenanceHistory__c  // 物件メンテナンス履歴
            WHERE
                Property__c = :propertyId
            ORDER BY
                CreatedDate  DESC
            LIMIT
                1000
        ];
        if (PropertyMaintenanceHistory.isEmpty()){
            PropertyMaintenanceHistory = new List<PropertyMaintenanceHistory__c>();
        }
        return PropertyMaintenanceHistory;
    }

    // ポータルサイト掲載物件情報取得
    private List<PortalSitePostingProperty__c> selectPortalSitePostingProperty(Id propertyId){
        List<PortalSitePostingProperty__c> PortalSitePostingProperty = [
            SELECT
                Id 
                ,Shop__r.Name                      // 店舗．店舗名
                ,IsSuumo__c                        // SUUMO
                ,IsHomes__c                        // HOME'S
                ,IsAtHome__c                       // at home
				,IsChintaiNet__c					// CHINTAI 2022.03.25 CHINTAI対応追加
                ,IsChintaiPanoramaPosting__c        // CHINTAI系列パノラマ掲載フラグ 2022.04.07 CHINTAI対応追加
                ,Shop__r.IsChintaiPanoramaContract__c // 店舗．CHINTAIパノラマ掲載契約　2022.04.07 CHINTAI対応追加
                ,Shop__r.SuumoFtpServerAdress__c   // 店舗.SUUMO FTPサーバアドレス 
                ,Shop__r.HomesFtpServerAdress__c   // 店舗.HOME'S FTPサーバアドレス
                ,Shop__r.AtHomeFtpServerAdress__c  // 店舗.at home FTPサーバアドレス
                ,Shop__r.ChintaiWebApiAdress__c  	// 店舗.CHINTAI WEBAPIサーバアドレス 2022.03.25　CHINTAI対応追加
            FROM PortalSitePostingProperty__c      // ポータルサイト掲載物件
            WHERE
                Property__c = :propertyId
            ORDER BY
                Shop__r.SortOrder__c
        ];
        if (PortalSitePostingProperty.isEmpty()){
            PortalSitePostingProperty = new List<PortalSitePostingProperty__c>();
        }
        return PortalSitePostingProperty;
    }

	// 火災保険商品情報取得
	private List<InsuranceGuarantee__c> selectFireInsuranceItem(Id accountId){
		Id RecordTypeId = CommonUtil.getRecordTypeId('Item__c', CommonConst.ITEM_RECTYPE_FIRE_INSURANCE);
		List<InsuranceGuarantee__c> FireInsuranceItem = [
			SELECT Item__c
				,Item__r.Account__c				// 火災保険会社
				,Item__r.Account__r.Name		// 火災保険会社名
				,Item__r.ItemName__c			// 火災保険商品名
				,Item__r.FireInsuranceMonth__c	// 火災保険料月額
				,Item__r.FireInsuranceYear__c	// 火災保険料年額
				,Item__r.PaymentType__c			// 更新期間
				,Item__r.PaymentYear__c			// 更新年数
			FROM InsuranceGuarantee__c			// 取引先保険保証
			WHERE Account__c			= :accountId
			AND   Item__r.RecordTypeId	= :RecordTypeId
			ORDER BY Item__r.ItemName__c ASC	// 商品名 昇順_問合せNo0655でソート順変更
		];
		if (FireInsuranceItem.isEmpty()){
			FireInsuranceItem = new List<InsuranceGuarantee__c>();
		}
		return FireInsuranceItem;
	}

	// 保証商品情報取得
	private List<InsuranceGuarantee__c> selectGuaranteePlanItem(Id accountId){
		Id RecordTypeId = CommonUtil.getRecordTypeId('Item__c', CommonConst.ITEM_RECTYPE_GUARANTEE_PLAN);
		List<InsuranceGuarantee__c> GuaranteePlanItem = [
			SELECT Item__c
				,Item__r.Account__c					// 保証会社
				,Item__r.Account__r.Name			// 保証会社名
				,Item__r.ItemName__c				// 保証プラン名
				,Item__r.AssuranceContent__c		// 保証内容
				,Item__r.DirectDebitFee__c			// 手数料
				,Item__r.DirectDebitFeeTax__c		// 手数料（税込）
				,Item__r.DirectDebitFeeTaxType__c	// 手数料税区分
			FROM InsuranceGuarantee__c				// 取引先保険保証
			WHERE Account__c			= :accountId
			AND   Item__r.RecordTypeId	= :RecordTypeId
			ORDER BY Item__r.ItemName__c ASC		// 商品名 昇順_問合せNo0655でソート順変更
		];
		if (GuaranteePlanItem.isEmpty()){
			GuaranteePlanItem = new List<InsuranceGuarantee__c>();
		}
		return GuaranteePlanItem;
	}

	// 管理会社指定商品情報取得
	private List<ManagementCompanyItem__c> selectManagementCompanyItem(Id propertyId, Id accountId){
		List<ManagementCompanyItem__c> ManagementCompanyItem = [
			SELECT Id
				,ItemName__c        // 商品名
				,Amount__c          // 金額
				,AmountTax__c       // 金額（税込）
				,PaymentType__c     // 支払区分
				,TaxType__c         // 税区分
				,(SELECT Id
					FROM propertyManageCompayItemItem__r
					WHERE	Property__c = :propertyId
					AND		Account__c  = :accountId)
			FROM ManagementCompanyItem__c	// 管理会社指定商品
			WHERE Account__c	= :accountId
			ORDER BY ItemName__c ASC	// 商品名 昇順_問合せNo0655でソート順変更
				,PaymentType__c  ASC	// 支払区分 昇順_問合せNo0655でソート順変更
		];
		if (ManagementCompanyItem.isEmpty()){
			ManagementCompanyItem = new List<ManagementCompanyItem__c>();
		}
		return ManagementCompanyItem;
	}

    // 物件写真情報取得
    private PropertyPhoto__c selectAnyPhotoList(Id propertyId) {
        String sql = '';
        sql += 'SELECT Id ';
        for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PROPERTY; i++) { // 物件写真
        sql += '      ,PropertyPhotoFileName' + i + '__c ';
        sql += '      ,PropertyPhotoFilePath' + i + '__c ';
        sql += '      ,PropertyPhotoTag' + i + '__c ';
        sql += '      ,PropertyPhotoComment' + i + '__c ';
        }
        for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PRIVATE; i++) {  // 物件非公開
        sql += '      ,PrivatePhotoFileName' + i + '__c ';
        sql += '      ,PrivatePhotoFilePath' + i + '__c ';
        sql += '      ,PrivatePhotoType' + i + '__c ';
        sql += '      ,PrivatePhotoComment' + i + '__c ';
        }
        for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PANORAMA; i++) { // 物件パノラマ
        sql += '      ,PanoramaFileName' + i + '__c ';
        sql += '      ,PanoramaFilePath' + i + '__c ';
        sql += '      ,PanoramaTag' + i + '__c ';
        sql += '      ,PanoramaComment' + i + '__c ';
        }
        sql += '      ,RoomLayoutFileName__c ';                     // 物件間取り図
        sql += '      ,RoomLayoutFilePath__c ';
        sql += '      ,RoomLayoutMemoFileName__c ';                 // 物件間取り図（メモ有）
        sql += '      ,RoomLayoutMemoFilePath__c ';
        sql += '      ,Property__r.ForeignID__c ';
        sql += '      ,Property__r.Building__r.ForeignID__c ';
        sql += '  FROM PropertyPhoto__c ';
        sql += ' WHERE Property__c   = :propertyId ';
        List<PropertyPhoto__c> propertyPhoto = Database.query(sql);
        if (propertyPhoto.isEmpty()){
            propertyPhoto = new List<PropertyPhoto__c>();
            return new PropertyPhoto__c();
        }
        return propertyPhoto[0];
    }

    // 建物情報取得
    private Building__c selectBuilding(Id targetId){
        List<Building__c> building = [
            SELECT
                Id
                ,Name                       // 建物名
                ,GroundFloorCount__c        // 地上階数
                ,Station1__c                // 駅１
                ,Station2__c                // 駅２
                ,Station3__c                // 駅３
                ,TrainRoute1__c             // 沿線１
                ,TrainRoute2__c             // 沿線２
                ,TrainRoute3__c             // 沿線３
                ,StationWalkTime1__c        // 駅までの時間１（分）
                ,StationWalkTime2__c        // 駅までの時間２（分）
                ,StationWalkTime3__c        // 駅までの時間３（分）
                ,CaretakerType__c           // 管理人種別
                ,ForeignID__c               // 外部Id
                ,Supermarket__c             // スーパー
                ,ConvenienceStore__c        // コンビニ
                ,GeneralHospital__c         // 病院
                ,PrimarySchool1__c          // 小学校１
                ,PrimarySchool2__c          // 小学校２
                ,PrimarySchool3__c          // 小学校３
                ,JuniorHighSchool1__c       // 中学校１
                ,JuniorHighSchool2__c       // 中学校２
                ,JuniorHighSchool3__c       // 中学校３
                ,HighSchool__c              // 高校
                ,University__c              // 大学
                ,IsWebCooperationAvailableFlag__c // Web連携可能フラグ
            FROM Building__c        // 建物
            WHERE
                Id  = :targetId
        ];
        // レコードが取得できない場合はビジネスロジックExceptionを発行する
        if(building.isEmpty()){
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
            throw ex;
        }
        return building[0];
    }

    // 建物写真情報取得（スーモスコア計算用）
    private BuildingPhoto__c selectBuildingPhoto(Id targetBuildingId){
        String sql = '';
        sql += 'SELECT Id ';
        sql += '      ,AppearanceFileName__c ';         // 建物外観
        sql += '      ,AppearanceComment__c ';
        sql += '      ,AppearanceParseFileName__c ';    // 建物外観パース
        sql += '      ,AppearanceParseComment__c ';
        sql += '      ,EntranceFileName__c ';           // 建物エントランス
        sql += '      ,EntranceComment__c ';
        sql += '      ,LobbyFileName__c ';              // 建物ロビー
        sql += '      ,LobbyComment__c ';
        sql += '      ,ParkingFileName__c ';            // 建物駐車場
        sql += '      ,ParkingComment__c ';
        sql += '      ,OtherSharingFileName__c ';       // 建物その他共有
        sql += '      ,OtherSharingComment__c ';
        sql += '      ,MapFileName__c ';                // 建物地図
        sql += '      ,MapComment__c ';
        sql += '      ,OtherFileName__c ';              // 建物その他
        sql += '      ,OtherComment__c ';
        for (Integer i = 1; i <= CommonConst.MAXINDEX_BUILDING_SURROUNDING; i++) {  // 建物周辺
        sql += '      ,SurroundingFileName' + i + '__c ';
        sql += '      ,SurroundingTag' + i + '__c ';
        sql += '      ,SurroundingComment' + i + '__c ';
        sql += '      ,SurroundingPhotoName' + i + '__c ';
        sql += '      ,SurroundingDistance' + i + '__c ';
        }
        sql += '  FROM BuildingPhoto__c ';
        sql += ' WHERE Building__c = :targetBuildingId ';
        List<BuildingPhoto__c> buildingPhoto = Database.query(sql);
        if (buildingPhoto.isEmpty()){
            buildingPhoto = new List<BuildingPhoto__c>();
            return new BuildingPhoto__c();
        }
        return buildingPhoto[0];
    }

    
    // 火災保険の計算用データの取得
    private static Item__c selectFireInsuranceItemAllRentFee(Id FireInsuranceItemId){
        List<Item__c> FireInsuranceItemList = [
            SELECT  Id         
            ,       PaymentType__c              // 更新期間
            ,       FireInsuranceMonth__c       // 火災保険料(月額)                 
            FROM    Item__c                     // 商品
            WHERE   Id = :FireInsuranceItemId   // 商品ID
        ];

        if (FireInsuranceItemList.isEmpty()){
            return null;
        }
        return FireInsuranceItemList[0];
    }

    // 保証プランの計算用金額の取得
    private static Item__c selectDepositItem(Id DepositItemId){
        List<Item__c> DepositItemList = [
            SELECT  Id                              
            ,       ItemName__c                      // 商品名
            ,       Account__r.IsAllRentFeeType__c   // 総賃料区分
            ,       DirectDebitFeeTaxType__c         // 手数料税区分
            ,       DirectDebitFee__c                // 手数料
            ,       DirectDebitFeeTax__c             // 手数料(税込)
            ,      (SELECT   DepositRate__c          // 保証料(割合)
                    ,        DepositYen__c           // 保証料(金額)
                    ,        IsRentFeeType__c        // 賃料区分
                    FROM     ItemDetailItem__r       // 商品明細
                    LIMIT    1)
            FROM    Item__c                          // 商品
            WHERE   Id = :DepositItemId              // 商品ID
        ];

        if (DepositItemList.isEmpty()){
            return null;
        }
        return DepositItemList[0];
    }

    //ポータルサイト構築 追加 Start
    // 削除対象のおすすめ物件を取得しパノラマツアーの非表示の設定を行う。
    private static RecommendProperty__c recommendPropertyToursStatus(Id propertyId){
        //おすすめ物件
        List<RecommendProperty__c> recoProp = [
            SELECT 
                Id 
            FROM 
                RecommendProperty__c
            WHERE
                Property__c = :propertyId
        ];            
        if(recoProp.isempty()){
            return null;
        }
        // 削除対象のパノラマツアーを判断し非表示にする。
        Theta360bizApiUtil.callTheta360bizToursStatus(recoProp[0].id);
        return recoProp[0];
    }
    //ポータルサイト構築 追加 End

    /**
     * メンテナンス物件コード履歴を設定
     * @param String propertyId 物件ID
     */
    private void setPropertyCdHist(String propertyId) {

        // 名寄せ先に紐づく物件コード履歴を取得
        List<PropertyCodeHistory__c> propertyCdHistList = [SELECT Id
                                                                  , Property__c
                                                                  , HistoryProperty__c
                                                                  , HistoryMaintenancePropertyCode__c
                                                                  , HistoryImportDestination__c
                                                                  , InformationUpdateDate__c
                                                                  , SystemModStamp
                                                           FROM PropertyCodeHistory__c
                                                           WHERE Property__c = :propertyId
                                                           ORDER BY InformationUpdateDate__c DESC];

        // 明細を設定
        this.screenPropertyCdHistList = new List<ScreenPropertyCdHist>();
        List<ScreenPropertyCdHist> tmpList = new List<ScreenPropertyCdHist>();
        for (PropertyCodeHistory__c propertyCdHist : propertyCdHistList) {

            // 親を先頭行に表示
            if (propertyCdHist.Property__c == propertyCdHist.HistoryProperty__c) {
                this.screenPropertyCdHistList.add(new ScreenPropertyCdHist(propertyCdHist));
            } else {
                tmpList.add(new ScreenPropertyCdHist(propertyCdHist));
            }
        }
        this.screenPropertyCdHistList.addAll(tmpList);
    }

    /**
    * 物件更新履歴を更新
    * @param  String targetStr          更新した項目名
    */
    private void saveMaintenanceHistory(String targetStr) {
        Property__c prop = new Property__c();
        prop.Id = this.propertyId;

        prop.MaintenanceCommentArea__c              = '物件を更新しました。' + targetStr;          // メンテナンスコメント
        prop.MaintenanceType__c                     = CommonConst.MAINTENANCETYPE_MANUALCHG;     // メンテナンス区分
        prop.MaintenanceStartDateTime__c            = this.MaintenanceStartDateTime;             // メンテナンス開始時刻
        prop.MaintenanceEndDateTime__c              = CommonUtil.getNow();                       // メンテナンス終了時刻
        prop.MaintenanceStaff__c                    = UserInfo.getUserId();                      // メンテナンススタッフ（ログインユーザ）
        SecureDML.secureUpdate(prop);
    }

    // 画面表示用内部クラス（物件）
    public class ScreenProperty {
        // 以下、画面用の項目

        // ヘッダ用
        public String   titleName                               { get; set; }   // ヘッダー表示用取引先名
        public String   headerPropertyCode                      { get; set; }   // 物件コード
        public Decimal  headerAllRentFee                        { get; set; }   // 総賃料
        public Decimal  headerRentFee                           { get; set; }   // 賃料
        public Decimal  headerManagementFee                     { get; set; }   // 管理費
        public Decimal  headerSecurityDepositYen                { get; set; }   // 敷金
        public Decimal  headerDepositYen                        { get; set; }   // 保証金
        public Decimal  headerKeyMoneyYen                       { get; set; }   // 礼金
        public String   headerRoomLayout                        { get; set; }   // 間取り
        public Decimal  headerRoomArea                          { get; set; }   // 専有面積
        public String   headerPosting                           { get; set; }   // 掲載
        public Decimal  headerScore                             { get; set; }   // スーモスコア参考値
        // 建物名
        public Id       buildingId                              { get; set; }   // 建物Id
        public String   buildingName                            { get; set; }   // 建物名
        public String   groundFloorCount                        { get; set; }   // 地上階数
        // 物件
        public Id       Id                                      { get; set; }   // Id
        public String   PropertyCode                            { get; set; }   // 物件コード
        public Decimal  Score                                   { get; set; }   // 点数
        public Boolean  IsMergeCompletedFlag                    { get; set; }   // 名寄せ完了フラグ
        public Id       Building                                { get; set; }   // 建物
        public String   Name                                    { get; set; }   // 部屋番号
        public String   LivedType                               { get; set; }   // 未入居種別
        public String   LiveStatus                              { get; set; }   // 現況
        public String   FloorType                               { get; set; }   // 地下階区分
        public String   Floor                                   { get; set; }   // 所在階
        public String   RoomCount                               { get; set; }   // 部屋数
        public String   RoomLayout                              { get; set; }   // 間取り
        public String   RoomArea                                { get; set; }   // 専有面積（㎡）
        public String   BalconyArea                             { get; set; }   // バルコニー面積
        public String   BalconyDirection                        { get; set; }   // バルコニー方向
        public String   KeyPlace                                { get; set; }   // 鍵所在
        public String   ContractTermYear                        { get; set; }   // 契約期間（年）
        public String   ContractTermMonth                       { get; set; }   // 契約期間（月）
        public Boolean  IsOwnCompanyPropertyFlag                { get; set; }   // 自社物フラグ
        public String   RentType                                { get; set; }   // 定期借家区分
        public String   RentTermYear                            { get; set; }   // 定借期間（年）
        public String   RentTermMonth                           { get; set; }   // 定借期間（月）
        public String   RentTermDay                             { get; set; }   // 定借期間（日）
        public String   RenovationComplateYear                  { get; set; }   // リノベ施工完了（年）
        public String   RenovationComplateMonth                 { get; set; }   // リノベ施工完了（月）
        public String   RenovationContent                       { get; set; }   // リノベ施工内容
        public String   FreeRentTermMonth                       { get; set; }   // フリーレント期間（ヶ月）
        public String   FreeRentContent                         { get; set; }   // フリーレント内容
        public String   SpecificExcellentRentBurdenUpperLimit   { get; set; }   // 特優賃入居負担額上限
        public String   SpecificExcellentRentBurdenLowerLimit   { get; set; }   // 特優賃入居負担額下限
        public String   SpecificExcellentRentFeeFluctuationType { get; set; }   // 特優賃料金変動区分
        public String   SpecificExcellentRentFeeUpwardRate      { get; set; }   // 特優賃上昇率
        public String   SpecificExcellentRentSupportYears       { get; set; }   // 特優賃家賃補助年数
        public String   SpecificExcellentRentRemarks            { get; set; }   // 特優賃備考
        public String   PropertyRemarksPublic                   { get; set; }   // 物件備考（公開）
        public String   PropertyRemarksPrivate                  { get; set; }   // 物件備考（非公開）
        public String   TransactionAspect                       { get; set; }   // 取引態様
        public String   DeliveryType                            { get; set; }   // 引渡種別
        public String   DeliveryYear                            { get; set; }   // 引渡年
        public String   DeliveryMonth                           { get; set; }   // 引渡月
        public String   DeliveryTiming                          { get; set; }   // 引渡旬
        public String   DeliveryDay                             { get; set; }   // 引渡日
        public String   DeliveryConsultation                    { get; set; }   // 引渡・入居日（相談内容）
        public String   PropertyComment                         { get; set; }   // 物件コメント
        public String   RepresentativeComment                   { get; set; }   // 担当者コメント
        public String   RentFee                                 { get; set; }   // 賃料
        public String   WortFee                                 { get; set; }   // 水道料金
        public String   WortFeeTaxType                          { get; set; }   // 水道料金税区分
        public String   SecurityDepositYen                      { get; set; }   // 敷金（円）
        public String   SecurityDepositMonth                    { get; set; }   // 敷金（ヵ月）
        public String   SecurityDepositUnit                     { get; set; }   // 敷金単位
        public String   RenewalFeeYen                           { get; set; }   // 更新料（円）
        public String   RenewalFeeMonth                         { get; set; }   // 更新料（ヵ月）
        public String   RenewalFeeUnit                          { get; set; }   // 更新料単位
        public String   RenewalFeeTaxType                       { get; set; }   // 更新料税区分
        public String   ManagementFee                           { get; set; }   // 管理費
        public String   ManagementFeeTaxType                    { get; set; }   // 管理費税区分
        public String   CATVFee                                 { get; set; }   // CATV
        public String   CATVTaxType                             { get; set; }   // CATV税区分
        public String   DepositYen                              { get; set; }   // 保証料金（円）
        public String   DepositMonth                            { get; set; }   // 保証料金（ヵ月）
        public String   DepositUnit                             { get; set; }   // 保証金単位
        public String   TownshipInitialFee                      { get; set; }   // 入町費
        public String   TownshipInitialFeeTaxType               { get; set; }   // 入町費税区分
        public String   TownshipFee                             { get; set; }   // 町会費
        public String   TownshipFeeTaxType                      { get; set; }   // 町会費税区分
        public String   TownshipFeePaymentType                  { get; set; }   // 町会費支払区分
        public String   GarbageDisposalFee                      { get; set; }   // ゴミ処理費
        public String   GarbageDisposalFeeTaxType               { get; set; }   // ゴミ処理費税区分
        public String   GarbageDisposalFeePaymentType           { get; set; }   // ゴミ処理費支払区分
        public String   KeyMoneyYen                             { get; set; }   // 礼金（円）
        public String   KeyMoneyMonth                           { get; set; }   // 礼金（ヵ月）
        public String   KeyMoneyUnit                            { get; set; }   // 礼金単位
        public String   KeyExchangeFee                          { get; set; }   // 鍵交換費
        public String   KeyExchangeFeeTaxType                   { get; set; }   // 鍵交換費税区分
        public String   BicycleParkingType                      { get; set; }   // 駐輪場種別
        public String   BicycleParkingFee                       { get; set; }   // 駐輪場代
        public String   BicycleParkingFeeTaxType                { get; set; }   // 駐輪場代税区分
        public String   CancellationActualFeeYen                { get; set; }   // 敷引・償却（円）
        public String   CancellationActualFeeMonth              { get; set; }   // 敷引・償却（ヵ月）
        public String   CancellationActualFeeRate               { get; set; }   // 敷引・償却（％）
        public String   CancellationActualFeeUnit               { get; set; }   // 敷引・償却単位
        public String   CleaningFeeYen                          { get; set; }   // 定額修繕費（円）
        public String   CleaningFeeMonth                        { get; set; }   // 定額修繕費（ヵ月）
        public String   CleaningFeeUnit                         { get; set; }   // 定額修繕費単位
        public String   CleaningFeeTaxType                      { get; set; }   // 定額修繕費税区分
        public String   CleaningFeePaymentType                  { get; set; }   // 定額修繕費支払区分
        public String   ParkingType                             { get; set; }   // 駐車場種別
        public String   ParkingFee                              { get; set; }   // 駐車場料金
        public String   ParkingFeeTaxType                       { get; set; }   // 駐車場料金税区分
        public String   ParkingDistance                         { get; set; }   // 近隣駐車場までの距離
        public String   ParkingDepositYen                       { get; set; }   // 駐車場保証料金
        public String   ParkingDepositMonth                     { get; set; }   // 駐車場保証料金（ヵ月）
        public String   ParkingDepositTaxType                   { get; set; }   // 駐車場保証料金税区分
        public String   ParkingDepositUnit                      { get; set; }   // 駐車場保証料金単位
        public String   ParkingCompoundingFeeYen                { get; set; }   // 駐車場手数料（円）
        public String   ParkingCompoundingFeeMonth              { get; set; }   // 駐車場手数料（ヵ月）
        public String   ParkingCompoundingFeeUnit               { get; set; }   // 駐車場手数料単位
        public String   ParkingCompoundingFeeTaxType            { get; set; }   // 駐車場手数料税区分
        public String   ParkingRemarksPublic                    { get; set; }   // 駐車場備考（公開）
        public String   ParkingRemarksPrivate                   { get; set; }   // 駐車場備考（非公開）
        public String   BikeStorageType                         { get; set; }   // バイク置場種別
        public String   BikeParkingSmallFee                     { get; set; }   // 小型バイク置場料金
        public String   BikeParkingSmallFeeTaxType              { get; set; }   // 小型バイク置場料金税区分
        public String   BikeParkingMediumFee                    { get; set; }   // 中型バイク置場料金
        public String   BikeParkingMediumFeeTaxType             { get; set; }   // 中型バイク置場料金税区分
        public String   BikeParkinLargeFee                      { get; set; }   // 大型バイク置場料金
        public String   BikeParkinLargeFeeTaxType               { get; set; }   // 大型バイク置場料金税区分
        public String   IsShortTermPenalty                      { get; set; }   // 短期解約違約金有無
        public String   ShortTermPenaltyLessYear                { get; set; }   // 短期解約違約金未満（年）
        public String   ShortTermPenaltyFee                     { get; set; }   // 短期解約違約金
        public String   ShortTermPenaltyLessYear2               { get; set; }   // 短期解約違約金未満（年）２
        public String   ShortTermPenaltyFee2                    { get; set; }   // 短期解約違約金２
        public String   MonetaryPublic                          { get; set; }   // 金銭備考（公開）
        public String   MonetaryPrivate                         { get; set; }   // 金銭備考（非公開）
        public String   FireInsuranceUseType                    { get; set; }   // 火災保険料（加入義務）
        public String   FireInsuranceCompany                    { get; set; }   // 火災保険会社
        public Id       FireInsurancePlan                       { get; set; }   // 火災保険タイトル
        public String   GuaranteeidCompanyType                  { get; set; }   // 保証会社（利用区分）
        public Id       GuaranteeidCompany                      { get; set; }   // 保証会社
        public Id       Guaranteeid                             { get; set; }   // 保証タイトル
        public String   AthomePanoramaContentsId                { get; set; }   // athomeパノラマコンテンツID
        public Id       AtHomePanoramaShopId                    { get; set; }   // athomeパノラマ掲載店舗
        public String   AtHomePanoramaShop                      { get; set; }   // athomeパノラマ掲載店舗名
        public String   HomesPanoramaShop                       { get; set; }   // HOME'Sパノラマ掲載店舗名
        public String   SuumoPanoramaShop                       { get; set; }   // SUUMOパノラマ掲載店舗名
        public String	ChintaiPanoramaShop						{ get; set;	}	// CHINTAIパノラマ掲載店舗名 2022.03.25 CHINTAI対応追加
        public String   RewardType                              { get; set; }   // 報酬形態
        public String   RewardBurdenLender                      { get; set; }   // 報酬負担貸主
        public String   RewardBurdenBorrower                    { get; set; }   // 報酬負担借主
        public String   RewardSplitFormerSupplier               { get; set; }   // 報酬配分元付
        public String   RewardSplitCustomer                     { get; set; }   // 報酬配分客付
        public String   ADFeeYen                                { get; set; }   // 広告料（円）
        public String   ADFeeMonth                              { get; set; }   // 広告料（ヵ月）
        public String   ADFeeRate                               { get; set; }   // 広告料（％）
        public String   ADFeeUnit                               { get; set; }   // 広告料単位
        public String   ADFeeTaxType                            { get; set; }   // 広告料税区分
        public String   ADFeeComment                            { get; set; }   // 広告料コメント
        public String   ADRemarksPublic                         { get; set; }   // 広告備考（公開）
        public String   ADRemarksPrivate                        { get; set; }   // 広告備考（非公開）
        public String   ImportType                              { get; set; }   // 取込区分
        public String   MaintenancePropertyCode                 { get; set; }   // メンテナンス物件コード
        public String   WebPublishing                           { get; set; }   // Web公開
        public Boolean  IsPropertyNameHiddenFlag                { get; set; }   // 物件名非表示フラグ
        public Datetime ManualMaintenanceDate                   { get; set; }   // 手動最終メンテナンス日
        public Datetime AutoMaintenanceDate                     { get; set; }   // 自動最終メンテナンス日
        public Id       HomesPropertyFeatureOrg                 { get; set; }   // HOME'S物件の特徴元
        public String   HomesPropertyFeature                    { get; set; }   // HOME'S物件の特徴
        public String   HomesRemarks                            { get; set; }   // HOME'S備考
        public Id       SuumoNetCatchOrg                        { get; set; }   // SUUMOネット用キャッチ元
        public String   SuumoNetCatch                           { get; set; }   // SUUMOネット用キャッチ
        public Id       SuumoNetCatchCommentOrg                 { get; set; }   // SUUMOネット用キャッチコメント元
        public String   SuumoNetCatchComment                    { get; set; }   // SUUMOネット用キャッチコメント
        public String   SuumoRemarks                            { get; set; }   // SUUMO備考
        public Id       AthomeRecommendCommentOrg               { get; set; }   // athomeおすすめコメント元
        public String   AthomeRecommendComment                  { get; set; }   // athomeおすすめコメント
        public String   AthomeRecommendCommentStaffId           { get; set; }   // athomeおすすめコメントスタッフID
        public String   AtHomeRemarks                           { get; set; }   // athome備考
		public Id       ChintaiMagazineCommentOrg				{ get; set; }	// CHINTAI雑誌コメント元　2022.03.25　CHINTAI対応追加
        public String   ChintaiMagazineComment                  { get; set; }   // CHINTAI雑誌コメント 2022.03.25　CHINTAI対応追加
        public String   MaintenanceComment                      { get; set; }   // メンテナンスコメント
        public Datetime SystemModStamp                          { get; set; }   // System Mod Stamp
        public String   ForeignID                               { get; set; }   // 外部Id
        public String   BuildingForeignID                       { get; set; }   // 建物外部Id

        public Id       FormerSupplierId                        { get; set; }   // 元付業者Id
        public String   FormerSupplierName                      { get; set; }   // 元付業者名
        public String   FormerSupplierPhone                     { get; set; }   // 元付業者電話番号
        public String   FormerSupplierFax                       { get; set; }   // 元付業者Fax
        public String   FormerSupplierPostalCode                { get; set; }   // 元付業者郵便番号
        public String   FormerSupplierAddress                   { get; set; }   // 元付業者住所
        public String   FormerSupplierState                     { get; set; }   // 元付業者都道府県
        public String   FormerSupplierCity                      { get; set; }   // 元付業者住所１（市区町村）
        public String   FormerSupplierStreet                    { get; set; }   // 元付業者住所２（番地）
        public String   FormerSupplierEmail                     { get; set; }   // 元付業者メール
        public String   FormerSupplierRepresentative            { get; set; }   // 元付業者担当者
        public String   FormerSupplierRepresentativePhone       { get; set; }   // 元付業者担当者電話番号
        public String   FormerSupplierRemarks                   { get; set; }   // 元付業者備考
        public Boolean  FormerSupplierIsMergeCompletedFlag      { get; set; }   // 元付業者名寄せ完了フラグ
        public Id       OwnerId                                 { get; set; }   // 所有者Id
        public String   OwnerName                               { get; set; }   // 所有者名
        public String   OwnerPhone                              { get; set; }   // 所有者電話番号
        public String   OwnerFax                                { get; set; }   // 所有者Fax
        public String   OwnerPostalCode                         { get; set; }   // 所有者郵便番号
        public String   OwnerAddress                            { get; set; }   // 所有者住所
        public String   OwnerState                              { get; set; }   // 所有者都道府県
        public String   OwnerCity                               { get; set; }   // 所有者住所１（市区町村）
        public String   OwnerStreet                             { get; set; }   // 所有者住所２（番地）
        public String   OwnerEmail                              { get; set; }   // 所有者メール
        public String   OwnerRepresentative                     { get; set; }   // 所有者担当者
        public String   OwnerRepresentativePhone                { get; set; }   // 所有者担当者電話番号
        public String   OwnerRemarks                            { get; set; }   // 所有者備考
        public Boolean  OwnerIsMergeCompletedFlag               { get; set; }   // 所有者名寄せ完了フラグ
        public Id       CreditorId                              { get; set; }   // 貸主Id
        public String   CreditorName                            { get; set; }   // 貸主名
        public String   CreditorPhone                           { get; set; }   // 貸主電話番号
        public String   CreditorFax                             { get; set; }   // 貸主Fax
        public String   CreditorPostalCode                      { get; set; }   // 貸主郵便番号
        public String   CreditorAddress                         { get; set; }   // 貸主住所
        public String   CreditorState                           { get; set; }   // 貸主都道府県
        public String   CreditorCity                            { get; set; }   // 貸主住所１（市区町村）
        public String   CreditorStreet                          { get; set; }   // 貸主住所２（番地）
        public String   CreditorEmail                           { get; set; }   // 貸主メール
        public String   CreditorRepresentative                  { get; set; }   // 貸主担当者
        public String   CreditorRepresentativePhone             { get; set; }   // 貸主担当者電話番号
        public String   CreditorRemarks                         { get; set; }   // 貸主備考
        public Boolean  CreditorIsMergeCompletedFlag            { get; set; }   // 貸主名寄せ完了フラグ

        // 料金表示用（円⇔ヵ月）
        public String   SecurityDeposit                         { get; set; }   // 敷金
        public String   RenewalFee                              { get; set; }   // 更新料
        public String   Deposit                                 { get; set; }   // 保証料金
        public String   KeyMoney                                { get; set; }   // 礼金
        public String   CancellationActualFee                   { get; set; }   // 敷引・償却
        public String   CleaningFee                             { get; set; }   // 定額修繕費
        public String   ParkingDeposit                          { get; set; }   // 駐車場保証料金
        public String   ParkingCompoundingFee                   { get; set; }   // 駐車場手数料
        public String   ADFee                                   { get; set; }   // 広告料

        public String   RealnetproURL                           { get; set; }   // リアプロURL
        public String   DaiwalivingURL                          { get; set; }   // 大和リビングURL

        public Boolean  isPermissionPublishing                  { get; set; }   // 2020/5/8追加：掲載許可済みフラグ

        // 物件写真Id
        public Id       PropertyPhotoId { get; set; }
        // 部屋
        public List<ScreenRoom> ScreenRoomList { get; set; }
        // 物件条件
        public PropertyConditions__c PropertyConditions { get; set; }

        //問合せ278で追加　画面初期表示時取込区分
        public String initialInportType { get; set; }                      

        // ポータルサイト掲載用内部クラスのリスト(ポータルサイト掲載の明細部)
        public List<PortalSitePostingDetail> PortalSitePostingDetailList { get; set; } 

        // コンストラクタ
        public screenProperty(Property__c targetPropertyRecord, Building__c targetBuildingRecord, List<PortalSitePostingProperty__c> targetPortalSitePostingPropertyList, List<Room__c> targetRoomList){
            // 初期化
            this.ScreenRoomList = new List<ScreenRoom>();
            this.PropertyConditions = new PropertyConditions__c();
            this.IsMergeCompletedFlag = true;

            // データセット
            // ヘッダ部
            this.titleName = '';
            this.titleName                  += String.isEmpty(targetBuildingRecord.Name) ? '' : targetBuildingRecord.Name;
            this.titleName                  += ' ';
            this.titleName                  += String.isEmpty(targetPropertyRecord.Name) ? '' : targetPropertyRecord.Name;  // タイトル
            this.headerPropertyCode         = targetPropertyRecord.PropertyCode__c;         // 物件コード
            this.headerAllRentFee           = targetPropertyRecord.AllRentFee__c;           // 総賃料
            this.headerRentFee              = targetPropertyRecord.RentFee__c;              // 賃料
            this.headerManagementFee        = targetPropertyRecord.ManagementFee__c;        // 管理費
            this.headerSecurityDepositYen   = targetPropertyRecord.SecurityDepositYen__c;   // 敷金
            this.headerDepositYen           = targetPropertyRecord.DepositYen__c;           // 保証金
            this.headerKeyMoneyYen          = targetPropertyRecord.KeyMoneyYen__c;          // 礼金
            this.headerRoomLayout           = String.isEmpty(CommonUtil.decimalToString(targetPropertyRecord.RoomCount__c)) ? '' : CommonUtil.decimalToString(targetPropertyRecord.RoomCount__c);
            this.headerRoomLayout          += String.isEmpty(targetPropertyRecord.RoomLayout__c) ? '' : targetPropertyRecord.RoomLayout__c; // 間取り
            this.headerRoomArea             = targetPropertyRecord.RoomArea__c;             // 専有面積
            this.headerScore                = targetPropertyRecord.Score__c;                // スーモスコア参考値

            // 建物名
            this.buildingId                 = targetBuildingRecord.Id;
            this.buildingName               = targetBuildingRecord.Name;
            this.groundFloorCount           = CommonUtil.decimalToString(targetBuildingRecord.GroundFloorCount__c);

            // 物件
            this.Id                                         = targetPropertyRecord.Id;                                          // Id
            this.PropertyCode                               = targetPropertyRecord.PropertyCode__c;                             // 物件コード
            this.Score                                      = targetPropertyRecord.Score__c;                                    // 点数
            this.IsMergeCompletedFlag                       = targetPropertyRecord.IsMergeCompletedFlag__c;                     // 名寄せ完了フラグ
            this.Building                                   = targetBuildingRecord.Id;                                          // 建物
            this.Name                                       = targetPropertyRecord.Name;                                        // 部屋番号
            this.LivedType                                  = targetPropertyRecord.LivedType__c;                                // 未入居種別
            this.LiveStatus                                 = targetPropertyRecord.LiveStatus__c;                               // 現況
            this.FloorType                                  = targetPropertyRecord.FloorType__c;                                // 地下階区分
            this.Floor                                      = CommonUtil.decimalToString(targetPropertyRecord.Floor__c);                                    // 所在階
            this.RoomCount                                  = CommonUtil.decimalToString(targetPropertyRecord.RoomCount__c);                                // 部屋数
            this.RoomLayout                                 = targetPropertyRecord.RoomLayout__c;                               // 間取り
            this.RoomArea                                   = CommonUtil.decimalToString(targetPropertyRecord.RoomArea__c);                                 // 専有面積（㎡）
            this.BalconyArea                                = CommonUtil.decimalToString(targetPropertyRecord.BalconyArea__c);                              // バルコニー面積
            this.BalconyDirection                           = targetPropertyRecord.BalconyDirection__c;                         // バルコニー方向
            this.KeyPlace                                   = targetPropertyRecord.KeyPlace__c;                                 // 鍵所在
            this.ContractTermYear                           = CommonUtil.decimalToString(targetPropertyRecord.ContractTermYear__c);                         // 契約期間（年）
            this.ContractTermMonth                          = CommonUtil.decimalToString(targetPropertyRecord.ContractTermMonth__c);                        // 契約期間（月）
            this.IsOwnCompanyPropertyFlag                   = targetPropertyRecord.IsOwnCompanyPropertyFlag__c;                 // 自社物フラグ
            this.RentType                                   = targetPropertyRecord.RentType__c;                                 // 定期借家区分
            this.RentTermYear                               = CommonUtil.decimalToString(targetPropertyRecord.RentTermYear__c);                             // 定借期間（年）
            this.RentTermMonth                              = CommonUtil.decimalToString(targetPropertyRecord.RentTermMonth__c);                            // 定借期間（月）
            this.RentTermDay                                = CommonUtil.decimalToString(targetPropertyRecord.RentTermDay__c);                              // 定借期間（日）
            this.RenovationComplateYear                     = CommonUtil.decimalToString(targetPropertyRecord.RenovationComplateYear__c);                   // リノベ施工完了（年）
            this.RenovationComplateMonth                    = CommonUtil.decimalToString(targetPropertyRecord.RenovationComplateMonth__c);                  // リノベ施工完了（月）
            this.RenovationContent                          = targetPropertyRecord.RenovationContent__c;                        // リノベ施工内容
            this.FreeRentTermMonth                          = CommonUtil.decimalToString(targetPropertyRecord.FreeRentTermMonth__c);                        // フリーレント期間（ヶ月）
            this.FreeRentContent                            = targetPropertyRecord.FreeRentContent__c;                          // フリーレント内容
            this.SpecificExcellentRentBurdenUpperLimit      = CommonUtil.decimalToString(targetPropertyRecord.SpecificExcellentRentBurdenUpperLimit__c);    // 特優賃入居負担額上限
            this.SpecificExcellentRentBurdenLowerLimit      = CommonUtil.decimalToString(targetPropertyRecord.SpecificExcellentRentBurdenLowerLimit__c);    // 特優賃入居負担額下限
            this.SpecificExcellentRentFeeFluctuationType    = targetPropertyRecord.SpecificExcellentRentFeeFluctuationType__c;  // 特優賃料金変動区分
            this.SpecificExcellentRentFeeUpwardRate         = CommonUtil.decimalToString(targetPropertyRecord.SpecificExcellentRentFeeUpwardRate__c);       // 特優賃上昇率
            this.SpecificExcellentRentSupportYears          = CommonUtil.decimalToString(targetPropertyRecord.SpecificExcellentRentSupportYears__c);        // 特優賃家賃補助年数
            this.SpecificExcellentRentRemarks               = targetPropertyRecord.SpecificExcellentRentRemarks__c;             // 特優賃備考
            this.PropertyRemarksPublic                      = targetPropertyRecord.PropertyRemarksPublic__c;                    // 物件備考（公開）
            this.PropertyRemarksPrivate                     = targetPropertyRecord.PropertyRemarksPrivate__c;                   // 物件備考（非公開）
            this.TransactionAspect                          = targetPropertyRecord.TransactionAspect__c;                        // 取引態様
            this.DeliveryType                               = targetPropertyRecord.DeliveryType__c;                             // 引渡種別
            this.DeliveryYear                               = targetPropertyRecord.DeliveryYear__c;                             // 引渡年
            this.DeliveryMonth                              = targetPropertyRecord.DeliveryMonth__c;                            // 引渡月
            this.DeliveryTiming                             = targetPropertyRecord.DeliveryTiming__c;                           // 引渡旬
            this.DeliveryDay                                = targetPropertyRecord.DeliveryDay__c;                              // 引渡日
            this.DeliveryConsultation                       = targetPropertyRecord.DeliveryConsultation__c;                     // 引渡・入居日（相談内容）
            this.PropertyComment                            = targetPropertyRecord.PropertyComment__c;                          // 物件コメント
            this.RepresentativeComment                      = targetPropertyRecord.RepresentativeComment__c;                    // 担当者コメント
            this.RentFee                                    = CommonUtil.decimalToString(targetPropertyRecord.RentFee__c);                                  // 賃料
            this.WortFee                                    = CommonUtil.decimalToString(targetPropertyRecord.WortFee__c);                                  // 水道料金
            this.WortFeeTaxType                             = targetPropertyRecord.WortFeeTaxType__c;                           // 水道料金税区分
            this.SecurityDepositYen                         = CommonUtil.decimalToString(targetPropertyRecord.SecurityDepositYen__c);                       // 敷金（円）
            this.SecurityDepositMonth                       = CommonUtil.decimalToString(targetPropertyRecord.SecurityDepositMonth__c);                     // 敷金（ヵ月）
            this.SecurityDepositUnit                        = targetPropertyRecord.SecurityDepositUnit__c;                      // 敷金単位
            this.RenewalFeeYen                              = CommonUtil.decimalToString(targetPropertyRecord.RenewalFeeYen__c);                            // 更新料（円）
            this.RenewalFeeMonth                            = CommonUtil.decimalToString(targetPropertyRecord.RenewalFeeMonth__c);                          // 更新料（ヵ月）
            this.RenewalFeeUnit                             = targetPropertyRecord.RenewalFeeUnit__c;                           // 更新料単位
            this.RenewalFeeTaxType                          = targetPropertyRecord.RenewalFeeTaxType__c;                        // 更新料税区分
            this.ManagementFee                              = CommonUtil.decimalToString(targetPropertyRecord.ManagementFee__c);                            // 管理費
            this.ManagementFeeTaxType                       = targetPropertyRecord.ManagementFeeTaxType__c;                     // 管理費税区分
            this.CATVFee                                    = CommonUtil.decimalToString(targetPropertyRecord.CATVFee__c);                                  // CATV
            this.CATVTaxType                                = targetPropertyRecord.CATVTaxType__c;                              // CATV税区分
            this.DepositYen                                 = CommonUtil.decimalToString(targetPropertyRecord.DepositYen__c);                               // 保証料金（円）
            this.DepositMonth                               = CommonUtil.decimalToString(targetPropertyRecord.DepositMonth__c);                             // 保証料金（ヵ月）
            this.DepositUnit                                = targetPropertyRecord.DepositUnit__c;                              // 保証金単位
            this.TownshipInitialFee                         = CommonUtil.decimalToString(targetPropertyRecord.TownshipInitialFee__c);                       // 入町費
            this.TownshipInitialFeeTaxType                  = targetPropertyRecord.TownshipInitialFeeTaxType__c;                // 入町費税区分
            this.TownshipFee                                = CommonUtil.decimalToString(targetPropertyRecord.TownshipFee__c);                              // 町会費
            this.TownshipFeeTaxType                         = targetPropertyRecord.TownshipFeeTaxType__c;                       // 町会費税区分
            this.TownshipFeePaymentType                     = targetPropertyRecord.TownshipFeePaymentType__c;                   // 町会費支払区分
            this.GarbageDisposalFee                         = CommonUtil.decimalToString(targetPropertyRecord.GarbageDisposalFee__c);                       // ゴミ処理費
            this.GarbageDisposalFeeTaxType                  = targetPropertyRecord.GarbageDisposalFeeTaxType__c;                // ゴミ処理費税区分
            this.GarbageDisposalFeePaymentType              = targetPropertyRecord.GarbageDisposalFeePaymentType__c;            // ゴミ処理費支払区分
            this.KeyMoneyYen                                = CommonUtil.decimalToString(targetPropertyRecord.KeyMoneyYen__c);                              // 礼金（円）
            this.KeyMoneyMonth                              = CommonUtil.decimalToString(targetPropertyRecord.KeyMoneyMonth__c);                            // 礼金（ヵ月）
            this.KeyMoneyUnit                               = targetPropertyRecord.KeyMoneyUnit__c;                             // 礼金単位
            this.KeyExchangeFee                             = CommonUtil.decimalToString(targetPropertyRecord.KeyExchangeFee__c);                           // 鍵交換費
            this.KeyExchangeFeeTaxType                      = targetPropertyRecord.KeyExchangeFeeTaxType__c;                    // 鍵交換費税区分
            this.BicycleParkingType                         = targetPropertyRecord.BicycleParkingType__c;                       // 駐輪場種別
            this.BicycleParkingFee                          = CommonUtil.decimalToString(targetPropertyRecord.BicycleParkingFee__c);                        // 駐輪場代
            this.BicycleParkingFeeTaxType                   = targetPropertyRecord.BicycleParkingFeeTaxType__c;                 // 駐輪場代税区分
            this.CancellationActualFeeYen                   = CommonUtil.decimalToString(targetPropertyRecord.CancellationActualFeeYen__c);                 // 敷引・償却（円）
            this.CancellationActualFeeMonth                 = CommonUtil.decimalToString(targetPropertyRecord.CancellationActualFeeMonth__c);               // 敷引・償却（ヵ月）
            this.CancellationActualFeeRate                  = CommonUtil.decimalToString(targetPropertyRecord.CancellationActualFeeRate__c);                // 敷引・償却（％）
            this.CancellationActualFeeUnit                  = targetPropertyRecord.CancellationActualFeeUnit__c;                // 敷引・償却単位
            this.CleaningFeeYen                             = CommonUtil.decimalToString(targetPropertyRecord.CleaningFeeYen__c);                           // 定額修繕費（円）
            this.CleaningFeeMonth                           = CommonUtil.decimalToString(targetPropertyRecord.CleaningFeeMonth__c);                         // 定額修繕費（ヵ月）
            this.CleaningFeeUnit                            = targetPropertyRecord.CleaningFeeUnit__c;                          // 定額修繕費単位
            this.CleaningFeeTaxType                         = targetPropertyRecord.CleaningFeeTaxType__c;                       // 定額修繕費税区分
            this.CleaningFeePaymentType                     = targetPropertyRecord.CleaningFeePaymentType__c;                   // 定額修繕費支払区分
            this.ParkingType                                = targetPropertyRecord.ParkingType__c;                              // 駐車場種別
            this.ParkingFee                                 = CommonUtil.decimalToString(targetPropertyRecord.ParkingFee__c);                               // 駐車場料金
            this.ParkingFeeTaxType                          = targetPropertyRecord.ParkingFeeTaxType__c;                        // 駐車場料金税区分
            this.ParkingDistance                            = CommonUtil.decimalToString(targetPropertyRecord.ParkingDistance__c);                          // 近隣駐車場までの距離
            this.ParkingDepositYen                          = CommonUtil.decimalToString(targetPropertyRecord.ParkingDepositYen__c);                        // 駐車場保証料金
            this.ParkingDepositMonth                        = CommonUtil.decimalToString(targetPropertyRecord.ParkingDepositMonth__c);                      // 駐車場保証料金（ヵ月）
            this.ParkingDepositTaxType                      = targetPropertyRecord.ParkingDepositTaxType__c;                    // 駐車場保証料金税区分
            this.ParkingDepositUnit                         = targetPropertyRecord.ParkingDepositUnit__c;                       // 駐車場保証料金単位
            this.ParkingCompoundingFeeYen                   = CommonUtil.decimalToString(targetPropertyRecord.ParkingCompoundingFeeYen__c);                 // 駐車場手数料（円）
            this.ParkingCompoundingFeeMonth                 = CommonUtil.decimalToString(targetPropertyRecord.ParkingCompoundingFeeMonth__c);               // 駐車場手数料（ヵ月）
            this.ParkingCompoundingFeeUnit                  = targetPropertyRecord.ParkingCompoundingFeeUnit__c;                // 駐車場手数料単位
            this.ParkingCompoundingFeeTaxType               = targetPropertyRecord.ParkingCompoundingFeeTaxType__c;             // 駐車場手数料税区分
            this.ParkingRemarksPublic                       = targetPropertyRecord.ParkingRemarksPublic__c;                     // 駐車場備考（公開）
            this.ParkingRemarksPrivate                      = targetPropertyRecord.ParkingRemarksPrivate__c;                    // 駐車場備考（非公開）
            this.BikeStorageType                            = targetPropertyRecord.BikeStorageType__c;                          // バイク置場種別
            this.BikeParkingSmallFee                        = CommonUtil.decimalToString(targetPropertyRecord.BikeParkingSmallFee__c);                      // 小型バイク置場料金
            this.BikeParkingSmallFeeTaxType                 = targetPropertyRecord.BikeParkingSmallFeeTaxType__c;               // 小型バイク置場料金税区分
            this.BikeParkingMediumFee                       = CommonUtil.decimalToString(targetPropertyRecord.BikeParkingMediumFee__c);                     // 中型バイク置場料金
            this.BikeParkingMediumFeeTaxType                = targetPropertyRecord.BikeParkingMediumFeeTaxType__c;              // 中型バイク置場料金税区分
            this.BikeParkinLargeFee                         = CommonUtil.decimalToString(targetPropertyRecord.BikeParkinLargeFee__c);                       // 大型バイク置場料金
            this.BikeParkinLargeFeeTaxType                  = targetPropertyRecord.BikeParkinLargeFeeTaxType__c;                // 大型バイク置場料金税区分
            this.IsShortTermPenalty                         = targetPropertyRecord.IsShortTermPenalty__c;                       // 短期解約違約金有無
            this.ShortTermPenaltyLessYear                   = CommonUtil.decimalToString(targetPropertyRecord.ShortTermPenaltyLessYear__c);                 // 短期解約違約金未満（年）
            this.ShortTermPenaltyFee                        = CommonUtil.decimalToString(targetPropertyRecord.ShortTermPenaltyFee__c);                      // 短期解約違約金
            this.ShortTermPenaltyLessYear2                  = CommonUtil.decimalToString(targetPropertyRecord.ShortTermPenaltyLessYear2__c);                // 短期解約違約金未満（年）２
            this.ShortTermPenaltyFee2                       = CommonUtil.decimalToString(targetPropertyRecord.ShortTermPenaltyFee2__c);                     // 短期解約違約金２
            this.MonetaryPublic                             = targetPropertyRecord.MonetaryPublic__c;                           // 金銭備考（公開）
            this.MonetaryPrivate                            = targetPropertyRecord.MonetaryPrivate__c;                          // 金銭備考（非公開）
            this.FireInsuranceUseType                       = targetPropertyRecord.FireInsuranceUseType__c;                     // 火災保険料（加入義務）
            this.FireInsuranceCompany                       = targetPropertyRecord.FireInsuranceCompany__c;                     // 火災保険会社
            this.FireInsurancePlan                          = targetPropertyRecord.FireInsurancePlan__c;                        // 火災保険タイトル
            this.GuaranteeidCompanyType                     = targetPropertyRecord.GuaranteeidCompanyType__c;                   // 保証会社（利用区分）
            this.GuaranteeidCompany                         = targetPropertyRecord.GuaranteeidCompany__c;                       // 保証会社
            this.Guaranteeid                                = targetPropertyRecord.Guaranteeid__c;                              // 保証タイトル
            this.AthomePanoramaContentsId                   = targetPropertyRecord.AthomePanoramaContentsId__c;                 // athomeパノラマコンテンツID
            this.AtHomePanoramaShopId                       = targetPropertyRecord.AtHomePanoramaShop__c;                       // athomeパノラマ掲載店舗Id
            this.AtHomePanoramaShop                         = targetPropertyRecord.AtHomePanoramaShop__r.Name;                  // athomeパノラマ掲載店舗
            this.HomesPanoramaShop                          = targetPropertyRecord.HomesPanoramaShop__r.Name;                   // HOME'Sパノラマ掲載店舗
            this.SuumoPanoramaShop                          = targetPropertyRecord.SuumoPanoramaShop__r.Name;                   // SUUMOパノラマ掲載店舗
            this.RewardType                                 = targetPropertyRecord.RewardType__c;                               // 報酬形態
            this.RewardBurdenLender                         = CommonUtil.decimalToString(targetPropertyRecord.RewardBurdenLender__c);                       // 報酬負担貸主
            this.RewardBurdenBorrower                       = CommonUtil.decimalToString(targetPropertyRecord.RewardBurdenBorrower__c);                     // 報酬負担借主
            this.RewardSplitFormerSupplier                  = CommonUtil.decimalToString(targetPropertyRecord.RewardSplitFormerSupplier__c);                // 報酬配分元付
            this.RewardSplitCustomer                        = CommonUtil.decimalToString(targetPropertyRecord.RewardSplitCustomer__c);                      // 報酬配分客付
            this.ADFeeYen                                   = CommonUtil.decimalToString(targetPropertyRecord.ADFeeYen__c);                                 // 広告料（円）
            this.ADFeeMonth                                 = CommonUtil.decimalToString(targetPropertyRecord.ADFeeMonth__c);                               // 広告料（ヵ月）
            this.ADFeeRate                                  = CommonUtil.decimalToString(targetPropertyRecord.ADFeeRate__c);                                // 広告料（％）
            this.ADFeeUnit                                  = targetPropertyRecord.ADFeeUnit__c;                                // 広告料単位
            this.ADFeeTaxType                               = targetPropertyRecord.ADFeeTaxType__c;                             // 広告料税区分
            this.ADFeeComment                               = targetPropertyRecord.ADFeeComment__c;                             // 広告料コメント
            this.ADRemarksPublic                            = targetPropertyRecord.ADRemarksPublic__c;                          // 広告備考（公開）
            this.ADRemarksPrivate                           = targetPropertyRecord.ADRemarksPrivate__c;                         // 広告備考（非公開）
            this.ImportType                                 = targetPropertyRecord.ImportType__c;                               // 取込区分
            // 問合せ278で追加　データ取得時に取込区分を退避
            this.initialInportType                          = targetPropertyRecord.ImportType__c;
            this.MaintenancePropertyCode                    = targetPropertyRecord.MaintenancePropertyCode__c;                  // メンテナンス物件コード
            this.WebPublishing                              = targetPropertyRecord.WebPublishing__c;                            // Web公開
            this.IsPropertyNameHiddenFlag                   = targetPropertyRecord.IsPropertyNameHiddenFlag__c;                 // 物件名非表示フラグ
            this.ManualMaintenanceDate                      = targetPropertyRecord.ManualMaintenanceDate__c;                    // 手動最終メンテナンス日
            this.AutoMaintenanceDate                        = targetPropertyRecord.AutoMaintenanceDate__c;                      // 自動最終メンテナンス日
            this.HomesPropertyFeatureOrg                    = targetPropertyRecord.HomesPropertyFeature__c;                     // HOME'S物件の特徴元
            this.HomesPropertyFeature                       = targetPropertyRecord.HomesPropertyFeature__r.ExampleSentence__c;  // HOME'S物件の特徴
            this.HomesRemarks                               = targetPropertyRecord.HomesRemarks__c;                             // HOME'S備考
            this.SuumoNetCatchOrg                           = targetPropertyRecord.SuumoNetCatch__c;                            // SUUMOネット用キャッチ元
            this.SuumoNetCatch                              = targetPropertyRecord.SuumoNetCatch__r.ExampleSentence__c;         // SUUMOネット用キャッチ
            this.SuumoNetCatchCommentOrg                    = targetPropertyRecord.SuumoNetCatchComment__c;                     // SUUMOネット用キャッチコメント元
            this.SuumoNetCatchComment                       = targetPropertyRecord.SuumoNetCatchComment__r.ExampleSentence__c;  // SUUMOネット用キャッチコメント
            this.SuumoRemarks                               = targetPropertyRecord.SuumoRemarks__c;                             // SUUMO備考
            this.AthomeRecommendCommentOrg                  = targetPropertyRecord.AthomeRecommendComment__c;                   // athomeおすすめコメント元
            this.AthomeRecommendComment                     = targetPropertyRecord.AthomeRecommendComment__r.ExampleSentence__c;// athomeおすすめコメント
            this.AthomeRecommendCommentStaffId              = targetPropertyRecord.AthomeRecommendCommentStaffId__c;            // athomeおすすめコメントスタッフID
            this.AtHomeRemarks                              = targetPropertyRecord.AtHomeRemarks__c;                            // athome備考
            this.ChintaiMagazineCommentOrg                  = targetPropertyRecord.ChintaiMagazineComment__c;					// CHINTAI雑誌コメント元 2022.03.25　CHINTAI対応追加
            this.ChintaiMagazineComment                     = targetPropertyRecord.ChintaiMagazineComment__r.ExampleSentence__c;// CHINTAI雑誌コメント 2022.03.25　CHINTAI対応追加
            this.MaintenanceComment                         = '';                                                               // メンテナンスコメント
            this.isPermissionPublishing                     = targetPropertyRecord.IsPermissionPublishing__c; 		            // 2020/5/8追加：掲載許可済みフラグ
            this.SystemModStamp                             = targetPropertyRecord.SystemModStamp;                              // System Mod Stamp

            this.ForeignID                          = targetPropertyRecord.ForeignID__c;                            // 外部Id
            this.BuildingForeignID                  = targetBuildingRecord.ForeignID__c;                            // 建物外部Id

            this.FormerSupplierId                   = targetPropertyRecord.FormerSupplier__r.Id;                    // 元付業者Id
            this.FormerSupplierName                 = targetPropertyRecord.FormerSupplier__r.Name;                  // 元付業者名
            this.FormerSupplierPhone                = targetPropertyRecord.FormerSupplierPhone__c;                  // 元付業者電話番号
            this.FormerSupplierFax                  = targetPropertyRecord.FormerSupplierFax__c;                    // 元付業者Fax
            this.FormerSupplierPostalCode           = targetPropertyRecord.FormerSupplierPostalCode__c;             // 元付業者郵便番号
            this.FormerSupplierAddress              = targetPropertyRecord.FormerSupplierAddress__c;                // 元付業者住所
            this.FormerSupplierState                = targetPropertyRecord.FormerSupplierState__c;                  // 元付業者都道府県
            this.FormerSupplierCity                 = targetPropertyRecord.FormerSupplierCity__c;                   // 元付業者住所１（市区町村）
            this.FormerSupplierStreet               = targetPropertyRecord.FormerSupplierStreet__c;                 // 元付業者住所２（番地）
            this.FormerSupplierEmail                = targetPropertyRecord.FormerSupplierEmail__c;                  // 元付業者メール
            this.FormerSupplierRepresentative       = targetPropertyRecord.FormerSupplierRepresentative__c;         // 元付業者担当者
            this.FormerSupplierRepresentativePhone  = targetPropertyRecord.FormerSupplierRepresentativePhone__c;    // 元付業者担当者電話番号
            this.FormerSupplierRemarks              = targetPropertyRecord.FormerSupplier__r.RemarksPublic__c;      // 元付業者備考
            this.FormerSupplierIsMergeCompletedFlag = targetPropertyRecord.FormerSupplier__r.IsMergeCompletedFlag__c;   // 元付業者名寄せ完了フラグ
            this.CreditorId                         = targetPropertyRecord.Creditor__r.Id;                          // 貸主Id
            this.CreditorName                       = targetPropertyRecord.Creditor__r.Name;                        // 貸主名
            this.CreditorPhone                      = targetPropertyRecord.CreditorPhone__c;                        // 貸主電話番号
            this.CreditorFax                        = targetPropertyRecord.CreditorFax__c;                          // 貸主Fax
            this.CreditorPostalCode                 = targetPropertyRecord.CreditorPostalCode__c;                   // 貸主郵便番号
            this.CreditorAddress                    = targetPropertyRecord.CreditorAddress__c;                      // 貸主住所
            this.CreditorState                      = targetPropertyRecord.CreditorState__c;                        // 貸主都道府県
            this.CreditorCity                       = targetPropertyRecord.CreditorCity__c;                         // 貸主住所１（市区町村）
            this.CreditorStreet                     = targetPropertyRecord.CreditorStreet__c;                       // 貸主住所２（番地）
            this.CreditorEmail                      = targetPropertyRecord.CreditorEmail__c;                        // 貸主メール
            this.CreditorRepresentative             = targetPropertyRecord.CreditorRepresentative__c;               // 貸主担当者
            this.CreditorRepresentativePhone        = targetPropertyRecord.CreditorRepresentativePhone__c;          // 貸主担当者電話番号
            this.CreditorRemarks                    = targetPropertyRecord.Creditor__r.RemarksPublic__c;            // 貸主備考
            this.CreditorIsMergeCompletedFlag       = targetPropertyRecord.Creditor__r.IsMergeCompletedFlag__c;     // 貸主名寄せ完了フラグ
            this.OwnerId                            = targetPropertyRecord.Owner__r.Id;                             // 所有者Id
            this.OwnerName                          = targetPropertyRecord.Owner__r.Name;                           // 所有者名
            this.OwnerPhone                         = targetPropertyRecord.OwnerPhone__c;                           // 所有者電話番号
            this.OwnerFax                           = targetPropertyRecord.OwnerFax__c;                             // 所有者Fax
            this.OwnerPostalCode                    = targetPropertyRecord.OwnerPostalCode__c;                      // 所有者郵便番号
            this.OwnerAddress                       = targetPropertyRecord.OwnerAddress__c;                         // 所有者住所
            this.OwnerState                         = targetPropertyRecord.OwnerState__c;                           // 所有者都道府県
            this.OwnerCity                          = targetPropertyRecord.OwnerCity__c;                            // 所有者住所１（市区町村）
            this.OwnerStreet                        = targetPropertyRecord.OwnerStreet__c;                          // 所有者住所２（番地）
            this.OwnerEmail                         = targetPropertyRecord.OwnerEmail__c;                           // 所有者メール
            this.OwnerRepresentative                = targetPropertyRecord.OwnerRepresentative__c;                  // 所有者担当者
            this.OwnerRepresentativePhone           = targetPropertyRecord.OwnerRepresentativePhone__c;             // 所有者担当者電話番号
            this.OwnerRemarks                       = targetPropertyRecord.Owner__r.RemarksPublic__c;               // 所有者備考
            this.OwnerIsMergeCompletedFlag          = targetPropertyRecord.Owner__r.IsMergeCompletedFlag__c;        // 所有者名寄せ完了フラグ

            // 定借期間（年）「,」排除
            if (!String.isEmpty(this.RentTermYear)) {
                this.RentTermYear = this.RentTermYear.remove(',');
            }
            // リノベ施工完了（年）「,」排除
            if (!String.isEmpty(this.RenovationComplateYear)) {
                this.RenovationComplateYear = this.RenovationComplateYear.remove(',');
            }

            // 地下階区分初期化（未設定⇒地上）
            this.FloorType                      = String.isEmpty(this.FloorType)
                                                    ? CommonConst.PROPERTY_FLOORTYPE_GROUND
                                                    : this.FloorType;

            // 取引態様初期化（未設定⇒一般媒体）
            this.TransactionAspect              = String.isEmpty(this.TransactionAspect)
                                                    ? CommonConst.PROPERTY_TRANSACTIONASPECT_GENERALBROKERAGE
                                                    : this.TransactionAspect;

            // 駐輪場種別初期化（未設定⇒無）
            this.BicycleParkingType             = String.isEmpty(this.BicycleParkingType)
                                                    ? CommonConst.PROPERTY_BICYCLEPARKINGTYPE_NO
                                                    : this.BicycleParkingType;
            // 駐車場種別初期化（未設定⇒無）
            this.ParkingType                    = String.isEmpty(this.ParkingType)
                                                    ? CommonConst.PROPERTY_PARKINGTYPE_NO
                                                    : this.ParkingType;
            // バイク置場種別初期化（未設定⇒無）
            this.BikeStorageType                = String.isEmpty(this.BikeStorageType)
                                                    ? CommonConst.PROPERTY_BIKESTORAGETYPE_NO
                                                    : this.BikeStorageType;
            // 短期解約違約金初期化（未設定⇒無）
            this.IsShortTermPenalty             = String.isEmpty(this.IsShortTermPenalty)
                                                    ? CommonConst.PROPERTY_ISSHORTTERMPENALTY_NO
                                                    : this.IsShortTermPenalty;
            // 保証会社利用区分（未設定⇒無）
            this.GuaranteeidCompanyType         = String.isEmpty(this.GuaranteeidCompanyType)
                                                    ? CommonConst.PROPERTY_GUARANTEEIDCOMPANYTYPE_UNSET
                                                    : this.GuaranteeidCompanyType;

            // 支払区分初期化（未設定⇒月額, 未設定⇒未入居）
            this.TownshipFeePaymentType         = this.initPaymentType(this.TownshipFeePaymentType);            // 町会費支払区分
            this.GarbageDisposalFeePaymentType  = this.initPaymentType(this.GarbageDisposalFeePaymentType);     // ゴミ処理費支払区分
            this.CleaningFeePaymentType         = this.initCleaningFeePaymentType(this.CleaningFeePaymentType); // 定額修繕費支払区分

            // 税区分初期化（未設定⇒課税）
            this.WortFeeTaxType                 = this.initTaxType(this.WortFeeTaxType);                // 水道料金税区分
            this.RenewalFeeTaxType              = this.initTaxType(this.RenewalFeeTaxType);             // 更新料税区分                                                        
            this.ManagementFeeTaxType           = this.initManagementFeeTaxType(this.ManagementFeeTaxType); // 管理費税区分
            //this.ManagementFeeTaxType           = this.initTaxType(this.ManagementFeeTaxType);        // 管理費税区分
            this.CATVTaxType                    = this.initTaxType(this.CATVTaxType);                   // CATV税区分
            this.TownshipInitialFeeTaxType      = this.initTaxType(this.TownshipInitialFeeTaxType);     // 入町費税区分
            this.TownshipFeeTaxType             = this.initTaxType(this.TownshipFeeTaxType);            // 町会費税区分
            this.GarbageDisposalFeeTaxType      = this.initTaxType(this.GarbageDisposalFeeTaxType);     // ゴミ処理費税区分
            this.KeyExchangeFeeTaxType          = this.initTaxType(this.KeyExchangeFeeTaxType);         // 鍵交換費税区分
            this.BicycleParkingFeeTaxType       = this.initTaxType(this.BicycleParkingFeeTaxType);      // 駐輪場代税区分
            this.CleaningFeeTaxType             = this.initTaxType(this.CleaningFeeTaxType);            // 定額修繕費税区分
            this.ParkingFeeTaxType              = this.initTaxType(this.ParkingFeeTaxType);             // 駐車場料金税区分
            this.ParkingDepositTaxType          = this.initTaxType(this.ParkingDepositTaxType);         // 駐車場保証料金税区分
            this.ParkingCompoundingFeeTaxType   = this.initTaxType(this.ParkingCompoundingFeeTaxType);  // 駐車場手数料税区分
            this.BikeParkingSmallFeeTaxType     = this.initTaxType(this.BikeParkingSmallFeeTaxType);    // 小型バイク置場料金税区分
            this.BikeParkingMediumFeeTaxType    = this.initTaxType(this.BikeParkingMediumFeeTaxType);   // 中型バイク置場料金税区分
            this.BikeParkinLargeFeeTaxType      = this.initTaxType(this.BikeParkinLargeFeeTaxType);     // 大型バイク置場料金税区分
            this.ADFeeTaxType                   = this.initADFeeTaxType(this.ADFeeTaxType);             // 広告料税区分

            // 料金単位 初期化（未設定⇒円）
            this.SecurityDepositUnit        = this.initFeeUnit(this.SecurityDepositUnit);       // 敷金
            this.RenewalFeeUnit             = this.initFeeUnit(this.RenewalFeeUnit);            // 更新料
            this.DepositUnit                = this.initFeeUnit(this.DepositUnit);               // 保証料金
            this.KeyMoneyUnit               = this.initFeeUnit(this.KeyMoneyUnit);              // 礼金
            this.CancellationActualFeeUnit  = this.initFeeUnit(this.CancellationActualFeeUnit); // 敷引・償却
            this.ParkingDepositUnit         = this.initFeeUnit(this.ParkingDepositUnit);        // 駐車場保証料金
            this.ParkingCompoundingFeeUnit  = this.initFeeUnit(this.ParkingCompoundingFeeUnit); // 駐車場手数料
            this.CleaningFeeUnit            = this.initFeeUnit(this.CleaningFeeUnit);           // 定額修繕費
            this.ADFeeUnit                  = this.initFeeUnit(this.ADFeeUnit);                 // 広告料

            // 料金表示用（円⇔ヵ月）
            this.SecurityDeposit        = this.getFeeFromUnit(this.SecurityDepositUnit, this.SecurityDepositYen, this.SecurityDepositMonth, null);  // 敷金
            this.RenewalFee             = this.getFeeFromUnit(this.RenewalFeeUnit, this.RenewalFeeYen, this.RenewalFeeMonth, null);                 // 更新料
            this.Deposit                = this.getFeeFromUnit(this.DepositUnit, this.DepositYen, this.DepositMonth, null);                          // 保証料金
            this.KeyMoney               = this.getFeeFromUnit(this.KeyMoneyUnit, this.KeyMoneyYen, this.KeyMoneyMonth, null);                       // 礼金
            this.CancellationActualFee  = this.getFeeFromUnit(this.CancellationActualFeeUnit, this.CancellationActualFeeYen
                                                            , this.CancellationActualFeeMonth, this.CancellationActualFeeRate);                     // 敷引・償却
            this.ParkingDeposit         = this.getFeeFromUnit(this.ParkingDepositUnit, this.ParkingDepositYen, this.ParkingDepositMonth, null);     // 駐車場保証料金
            this.ParkingCompoundingFee  = this.getFeeFromUnit(this.ParkingCompoundingFeeUnit, this.ParkingCompoundingFeeYen
                                                            , this.ParkingCompoundingFeeMonth, null);                                               // 駐車場手数料
            this.CleaningFee            = this.getFeeFromUnit(this.CleaningFeeUnit, this.CleaningFeeYen, this.CleaningFeeMonth, null);              // 定額修繕費
            this.ADFee                  = this.getFeeFromUnit(this.ADFeeUnit, this.ADFeeYen, this.ADFeeMonth, this.ADFeeRate);                      // 広告料

            // at homeパノラマ掲載店舗
            this.AtHomePanoramaShopId   = String.isEmpty(this.AtHomePanoramaShopId)
                                                    ? null
                                                    : this.AtHomePanoramaShopId;

            // リアプロURL
            this.RealnetproURL = '';
            if (this.ImportType == CommonConst.PROPERTY_IMPORTTYPE_REALNETPRO) {
                this.RealnetproURL = targetPropertyRecord.PropertyDetailUrl__c;
            }
            // 大和リビングURL
            this.DaiwalivingURL = '';
            if (this.ImportType == CommonConst.PROPERTY_IMPORTTYPE_DAIWALIVING) {
                this.DaiwalivingURL = targetPropertyRecord.PropertyDetailUrl__c;
            }

            // 改行制御
            this.PropertyRemarksPrivate = String.isEmpty(this.PropertyRemarksPrivate) ? '' : this.PropertyRemarksPrivate.escapeHtml4().replaceAll('\n', '<br/>'); // 物件備考（非公開）
            this.ParkingRemarksPrivate  = String.isEmpty(this.ParkingRemarksPrivate)  ? '' : this.ParkingRemarksPrivate.escapeHtml4().replaceAll('\n', '<br/>');  // 駐車場備考（非公開）
            this.MonetaryPrivate        = String.isEmpty(this.MonetaryPrivate)        ? '' : this.MonetaryPrivate.escapeHtml4().replaceAll('\n', '<br/>');        // 金銭備考（非公開）
            this.ADRemarksPrivate       = String.isEmpty(this.ADRemarksPrivate)       ? '' : this.ADRemarksPrivate.escapeHtml4().replaceAll('\n', '<br/>');       // 広告備考（非公開）
            this.HomesPropertyFeature   = String.isEmpty(this.HomesPropertyFeature)   ? '' : this.HomesPropertyFeature.escapeHtml4().replaceAll('\n', '<br/>');   // HOME'S物件の特徴
            this.SuumoNetCatch          = String.isEmpty(this.SuumoNetCatch)          ? '' : this.SuumoNetCatch.escapeHtml4().replaceAll('\n', '<br/>');          // SUUMOネット用キャッチ
            this.SuumoNetCatchComment   = String.isEmpty(this.SuumoNetCatchComment)   ? '' : this.SuumoNetCatchComment.escapeHtml4().replaceAll('\n', '<br/>');   // SUUMOネット用キャッチコメント
            this.AthomeRecommendComment = String.isEmpty(this.AthomeRecommendComment) ? '' : this.AthomeRecommendComment.escapeHtml4().replaceAll('\n', '<br/>'); // athomeおすすめコメント
            this.ChintaiMagazineComment = String.isEmpty(this.ChintaiMagazineComment) ? '' : this.ChintaiMagazineComment.escapeHtml4().replaceAll('\n', '<br/>'); // CHINTAI雑誌コメント 2022.03.25　CHINTAI対応追加

            // 物件写真Id
            if (targetPropertyRecord.PropertyPhotoProperty__r.size() > 0) {
                this.PropertyPhotoId = targetPropertyRecord.PropertyPhotoProperty__r[0].Id;
            }

            // 部屋
            if (!targetRoomList.isEmpty()) {
                for (Room__c record : targetRoomList) {
                    this.ScreenRoomList.add(new ScreenRoom(record));
                }
            }

            // 物件条件
            if (!targetPropertyRecord.PropertyConditionsProperty__r.isEmpty()) {
                this.PropertyConditions = targetPropertyRecord.PropertyConditionsProperty__r[0];
            }
            
            // 物件条件の自動判定項目値の設定
            // 駅カウント
            Integer StationCount = 0;
            StationCount = StationCount + (String.isEmpty(targetBuildingRecord.Station1__c) ? 0 : 1);
            StationCount = StationCount + (String.isEmpty(targetBuildingRecord.Station2__c) ? 0 : 1);
            StationCount = StationCount + (String.isEmpty(targetBuildingRecord.Station3__c) ? 0 : 1);
            // 沿線カウント（種類カウント）
            Integer TrainRouteCount = 0;
            TrainRouteCount = TrainRouteCount + (String.isEmpty(targetBuildingRecord.TrainRoute1__c) ? 0 : 1);
            if (!String.isEmpty(targetBuildingRecord.TrainRoute2__c)
                && targetBuildingRecord.TrainRoute2__c != targetBuildingRecord.TrainRoute1__c) {
                TrainRouteCount = TrainRouteCount + 1;
            }
            if (!String.isEmpty(targetBuildingRecord.TrainRoute3__c)
                && targetBuildingRecord.TrainRoute3__c != targetBuildingRecord.TrainRoute1__c
                && targetBuildingRecord.TrainRoute3__c != targetBuildingRecord.TrainRoute2__c) {
                TrainRouteCount = TrainRouteCount + 1;
            }
            // ２駅利用可, ３駅利用可 設定
            this.PropertyConditions.IsTwoStation__c = false;
            this.PropertyConditions.IsThreeStation__c = false;
            if (StationCount == 3) {
                // 駅数3は ２駅利用可, ３駅利用可をTrue
                this.PropertyConditions.IsTwoStation__c = true;
                this.PropertyConditions.IsThreeStation__c = true;
            } else if (StationCount == 2) {
                // 駅数2は ２駅利用可をTrue
                this.PropertyConditions.IsTwoStation__c = true;
            }
            // ２沿線利用可, ３沿線利用可 設定
            this.PropertyConditions.IsTwoTrainRoute__c = false;
            this.PropertyConditions.IsThreeTrainRoute__c = false;
            if (TrainRouteCount == 3) {
                // 駅数3は ２沿線利用可, ３沿線利用可をTrue
                this.PropertyConditions.IsTwoTrainRoute__c = true;
                this.PropertyConditions.IsThreeTrainRoute__c = true;
            } else if (TrainRouteCount == 2) {
                // 駅数2は ２沿線利用可をTrue
                this.PropertyConditions.IsTwoTrainRoute__c = true;
            } 
            // 駅前 設定
            this.PropertyConditions.IsFrontStation__c = false;
            if (targetBuildingRecord.StationWalkTime1__c <= 1
                || targetBuildingRecord.StationWalkTime2__c <= 1
                || targetBuildingRecord.StationWalkTime3__c <= 1) {
                // 駅までの時間 1分以下でTrue
                this.PropertyConditions.IsFrontStation__c = true;
            }
            // 管理人種別 設定
            this.PropertyConditions.IsJanitor__c            = false;    // 管理人あり
            this.PropertyConditions.IsJanitorReside__c      = false;    // 管理人(常駐)
            this.PropertyConditions.IsJanitorCommuter__c    = false;    // 管理人(通勤)
            this.PropertyConditions.IsJanitorPatrol__c      = false;    // 管理人(巡回)
            if (targetBuildingRecord.CaretakerType__c == CommonConst.BUILDING_CARETAKERTYPE_RESIDE) {
                // 管理人種別「常駐」は 管理人あり, 管理人(常駐)をtrue
                this.PropertyConditions.IsJanitor__c = true;        // 管理人あり
                this.PropertyConditions.IsJanitorReside__c = true;  // 管理人(常駐)
            } else if (targetBuildingRecord.CaretakerType__c == CommonConst.BUILDING_CARETAKERTYPE_NORESIDE) {
                // 管理人種別「非常駐」は 管理人ありをtrue
                this.PropertyConditions.IsJanitor__c = true;        // 管理人あり
            } else if (targetBuildingRecord.CaretakerType__c == CommonConst.BUILDING_CARETAKERTYPE_PATROL) {
                // 管理人種別「巡回方式」は 管理人あり, 管理人(巡回)をtrue
                this.PropertyConditions.IsJanitor__c = true;        // 管理人あり
                this.PropertyConditions.IsJanitorPatrol__c = true;  // 管理人(巡回)
            } else if (targetBuildingRecord.CaretakerType__c == CommonConst.BUILDING_CARETAKERTYPE_COMMUTER) {
                // 管理人種別「通勤方式」は 管理人あり, 管理人(通勤)をtrue
                this.PropertyConditions.IsJanitor__c = true;        // 管理人あり
                this.PropertyConditions.IsJanitorCommuter__c = true;// 管理人(通勤)
            }
            // 敷地内駐車場 設定
            this.PropertyConditions.IsInSiteParking__c = false;
            if (this.ParkingType == CommonConst.PROPERTY_PARKINGTYPE_EMPTY_EXISTS
                || this.ParkingType == CommonConst.PROPERTY_PARKINGTYPE_NO_EMPTY) {
                // 駐車場種別「空有」「空無」でtrue
                this.PropertyConditions.IsInSiteParking__c = true;
            }
            // 駐車場空きあり 設定
            this.PropertyConditions.IsParking__c = false;
            if (this.ParkingType == CommonConst.PROPERTY_PARKINGTYPE_EMPTY_EXISTS
                 || this.ParkingType == CommonConst.PROPERTY_PARKINGTYPE_NEIGHBORHOOD_SECURE) {
                // 駐車場種別「空有」「近隣確保」でtrue
                this.PropertyConditions.IsParking__c = true;
            }
            // バイク置場, 大型バイク, 中型バイク, 小型バイク 設定
            this.PropertyConditions.IsBikeStorage__c = false;
            this.PropertyConditions.IsSmallBike__c = false;
            if (!String.isEmpty(this.BikeParkingSmallFee)) {
                // 小型バイク置場料金≠空白でバイク置場、小型バイクtrue
                this.PropertyConditions.IsBikeStorage__c = true;
                this.PropertyConditions.IsSmallBike__c = true;
            }
            this.PropertyConditions.IsMediumBike__c = false;
            if (!String.isEmpty(this.BikeParkingMediumFee)) {
                // 中型バイク置場料金≠空白でバイク置場、中型バイクtrue
                this.PropertyConditions.IsBikeStorage__c = true;
                this.PropertyConditions.IsMediumBike__c = true;
            }
            this.PropertyConditions.IsLargeBike__c = false;
            if (!String.isEmpty(this.BikeParkinLargeFee)) {
                // 大型バイク置場料金≠空白でバイク置場、大型バイクtrue
                this.PropertyConditions.IsBikeStorage__c = true;
                this.PropertyConditions.IsLargeBike__c = true;
            }
            // 1階, 2階以上, 最上階 設定
            this.PropertyConditions.IsFirstFloor__c         = false;
            this.PropertyConditions.IsSecondFloorOver__c    = false;
            this.PropertyConditions.IsTopFloor__c           = false;
            if (this.FloorType == CommonConst.PROPERTY_FLOORTYPE_GROUND) {
                if (CommonUtil.stringToDecimal(this.Floor) == 1) {
                    // 地下階区分「地上」かつ所在階「1」は 1階 true
                    this.PropertyConditions.IsFirstFloor__c = true;
                } else if (CommonUtil.stringToDecimal(this.Floor) >= 2) {
                    // 地下階区分「地上」かつ所在階「2」以上は 2階以上 true
                    this.PropertyConditions.IsSecondFloorOver__c = true;
                }
                if (this.Floor == this.groundFloorCount) {
                    // 地下階区分「地上」かつ所在階=地上階数は 最上階 true
                    this.PropertyConditions.IsTopFloor__c = true;
                }
            }
            // 南向き 設定
            this.PropertyConditions.IsSouth__c   = false;
            if (this.BalconyDirection == CommonConst.PROPERTY_BALCONYDIRECTION_SOUTHEAST
                || this.BalconyDirection == CommonConst.PROPERTY_BALCONYDIRECTION_SOUTH
                || this.BalconyDirection == CommonConst.PROPERTY_BALCONYDIRECTION_SOUTHWEST) {
                // バルコニー方向「南東」「南」「南西」はtrue
                this.PropertyConditions.IsSouth__c   = true;
            }
            // 即入居可 設定
            this.PropertyConditions.IsTurnkey__c = false;
            if (this.DeliveryType == CommonConst.PROPERTY_DELIVERYTYPE_IMMEDIATE) {
                // 引渡種別「即時」はtrue
                this.PropertyConditions.IsTurnkey__c = true;
            }
            // 定期借家を含まない 設定
            this.PropertyConditions.IsNotFixedTermTenant__c = false;
            if (this.RentType != CommonConst.PROPERTY_RENTTYPE_APPLICABLE) {
                // 定期借家区分≠「該当」はtrue
                this.PropertyConditions.IsNotFixedTermTenant__c = true;
            }
            
            // ポータルサイト掲載の明細部リストの初期化
            this.PortalSitePostingDetailList = new List<PortalSitePostingDetail>();
            if (targetPortalSitePostingPropertyList.size() != 0) {
                // 掲載（ヘッダ）の初期化
                this.headerPosting = CommonConst.STRING_EMPTY;

                String IsSuumo = CommonConst.STRING_EMPTY;
                String IsHomes = CommonConst.STRING_EMPTY;
                String IsAtHome = CommonConst.STRING_EMPTY;
				String IsChintai = CommonConst.STRING_EMPTY;	// 2022.03.25 CHINTAI対応追加
				ChintaiPanoramaShop = CommonConst.STRING_EMPTY;	// 2022.03.25 CHINTAI対応追加
                //ポータル掲載の明細と掲載（ヘッダ）の設定を行う
                for( PortalSitePostingProperty__c targetPortalSitePostingProperty : targetPortalSitePostingPropertyList){
                    // ポータルサイト掲載の明細設定
                    this.PortalSitePostingDetailList.add(new PortalSitePostingDetail(targetPortalSitePostingProperty));

                    // 掲載（ヘッダ）の設定
                    if (targetPortalSitePostingProperty.IsSuumo__c && String.isEmpty(IsSuumo)) {
                        IsSuumo = CommonConst.PORTALSITE_NAME_SUUMO;
                    }
                    if (targetPortalSitePostingProperty.IsHomes__c && String.isEmpty(IsHomes)) {
                        IsHomes = CommonConst.PORTALSITE_NAME_HOMES;
                    }
                    if (targetPortalSitePostingProperty.IsAtHome__c && String.isEmpty(IsAtHome)) {
                        IsAtHome = CommonConst.PORTALSITE_NAME_AT_HOME;
                    }
					// ▼ 2022.03.25 CHINTAI対応追加
					if (targetPortalSitePostingProperty.IsChintaiNet__c && String.isEmpty(IsChintai)) {
                        IsChintai = CommonConst.PORTALSITE_NAME_CHINTAI;
                    }
					// CHINTAIパノラマ掲載店舗に表示する店舗の登録
					if (targetPortalSitePostingProperty.IsChintaiPanoramaPosting__c && targetPortalSitePostingProperty.shop__r.IsChintaiPanoramaContract__c) {
						if (ChintaiPanoramaShop == CommonConst.STRING_EMPTY) {
							ChintaiPanoramaShop = targetPortalSitePostingProperty.shop__r.Name;
						} else {
							ChintaiPanoramaShop += ';' + targetPortalSitePostingProperty.shop__r.Name;
						}
					}
					// ▲ 2022.03.25 CHINTAI対応追加
                }
                // 掲載（ヘッダ）の設定
                String Posting = CommonConst.STRING_EMPTY;
                if (!String.isEmpty(IsSuumo)) {
                    Posting += IsSuumo;
                }
                if (!String.isEmpty(IsHomes)) {
                    if (!String.isEmpty(Posting)) {
                        Posting += ';';
                    }
                    Posting += IsHomes;
                }
                if (!String.isEmpty(IsAtHome)) {
                    if (!String.isEmpty(Posting)) {
                        Posting += ';';
                    }
                    Posting += IsAtHome;
                }
                // ▼ 2022.03.25 CHINTAI対応追加
				if (!String.isEmpty(IsChintai)) {
					if (!String.isEmpty(Posting)) {
						Posting += ';';
					}
					Posting += IsChintai;
				}
                // ▲ 2022.03.25 CHINTAI対応追加
                this.headerPosting  = Posting;
            }			
        }
        // 支払区分初期化
        private String initPaymentType(String paymentType) {
            if (String.isEmpty(paymentType)) {
                return CommonConst.PROPERTY_PAYMENTTYPE_MONTH;
            }
            return paymentType;
        }
        // 定額修繕費支払区分初期化
        private String initCleaningFeePaymentType(String paymentType) {
            if (String.isEmpty(paymentType)) {
                return CommonConst.PROPERTY_PAYMENTTYPE_BEFORE_OCCUPANCY;
            }
            return paymentType;
        }
        // 税区分初期化
        private String initTaxType(String taxType) {
            if (String.isEmpty(taxType)) {
                return CommonConst.PROPERTY_TAXTYPE_TAXABLE;
            }
            return taxType;
        }
        // 税区分初期化（管理費のみ非課税）
        private String initManagementFeeTaxType(String taxType) {
             if (String.isEmpty(taxType)) {
                 return CommonConst.PROPERTY_TAXTYPE_NOTAXABLE;                
            }else{
                 return taxType;
            }
        }
        // 税区分初期化(広告料)
        private String initADFeeTaxType(String taxType) {
            if (String.isEmpty(taxType)) {
                return CommonConst.PROPERTY_TAXTYPE_TAXINCLUDED;
            }
            return taxType;
        }
        // 料金単位初期化
        private String initFeeUnit(String feeUnit) {
            if (String.isEmpty(feeUnit)) {
                return CommonConst.PROPERTY_FEEUNIT_YEN;
            }
            return feeUnit;
        }
        // 単位に伴った金額表示内容の取得
        private String getFeeFromUnit(String feeUnit, String feeYen, String feeMonth, String feeRate) {
            if (feeUnit == CommonConst.PROPERTY_FEEUNIT_YEN) {
                return feeYen;
            } else if (feeUnit == CommonConst.PROPERTY_FEEUNIT_MONTH) {
                return feeMonth;
            } else if (feeUnit == CommonConst.PROPERTY_FEEUNIT_RATE) {
                return feeRate;
            } else if (feeUnit == CommonConst.PROPERTY_FEEUNIT_ACTUALCOST) {
                return '';
            }
            return '';
        }

    }

    /**
     * ポータルサイト掲載用内部クラス
     */
    public class PortalSitePostingDetail {
        public String    ShopName              { get; set; }    // 店舗.店舗名
        public boolean   IsSuumo               { get; set; }    // SUUMO
        public boolean   IsHomes               { get; set; }    // HOME'S
        public boolean   IsAtHome              { get; set; }    // at home
        public boolean   IsChintai             { get; set; }    // CHINTAI 2022.03.25　CHINTAI対応追加
        public String    IsSuumoFtp            { get; set; }    // 店舗.SUUMO FTPサーバアドレス
        public String    IsHomesFtp            { get; set; }    // 店舗.HOME'S FTPサーバアドレス
        public String    IsAtHomeFtp           { get; set; }    // 店舗.at home FTPサーバアドレス
        public String    IsChintaiWebApi       { get; set; }	// 店舗.CHINTAI WEBAPIサーバアドレス 2022.03.25　CHINTAI対応追加
        public String    unlistedSiteMsgOfShop { get; set; }    // 店舗の未掲載サイトメッセージ
       
        /**
         * コンストラクタ
         @param  PortalSitePostingProperty__c targetPortalSitePostingProperty ポータル掲載物件レコード
         */     
        public PortalSitePostingDetail(PortalSitePostingProperty__c targetPortalSitePostingProperty) {
            // 初期化
            this.ShopName              = targetPortalSitePostingProperty.shop__r.Name;                        // 店舗.店舗名
            this.IsSuumo               = targetPortalSitePostingProperty.IsSuumo__c;                          // SUUMO
            this.IsHomes               = targetPortalSitePostingProperty.IsHomes__c;                          // HOME'S
            this.IsAtHome              = targetPortalSitePostingProperty.IsAtHome__c;                         // at home
            this.IsChintai             = targetPortalSitePostingProperty.IsChintaiNet__c;                     // CHINTAI 2022.03.25　CHINTAI対応追加
            this.IsSuumoFtp            = targetPortalSitePostingProperty.shop__r.SuumoFtpServerAdress__c;     // 店舗.SUUMO FTPサーバアドレス
            this.IsHomesFtp            = targetPortalSitePostingProperty.shop__r.HomesFtpServerAdress__c;     // 店舗.HOME'S FTPサーバアドレス
            this.IsAtHomeFtp           = targetPortalSitePostingProperty.shop__r.AtHomeFtpServerAdress__c;    // 店舗.at home FTPサーバアドレス 
            this.IsChintaiWebApi       = targetPortalSitePostingProperty.shop__r.ChintaiWebApiAdress__c;		// 店舗.CHINTAI WEBAPIサーバアドレス 2022.03.25　CHINTAI対応追加
            this.unlistedSiteMsgOfShop = getChangeUnlistedSiteMsgOfShop();                                    // 店舗の未掲載サイトメッセージ   
        }
        /**
        * 店舗の未掲載サイトメッセージ変更
        * @param  なし
        * @return string 店舗の未掲載サイトメッセージ
        */
        private String getChangeUnlistedSiteMsgOfShop(){
            String unlistedSiteMsgOfShop = CommonConst.STRING_EMPTY;
            String msg = CommonConst.STRING_EMPTY;
            //FTPサーバアドレス(SUUMO,at home,HOME's)がNULLまたは半角全角スペースの場合メッセージを表示
            if(String.isBlank(this.IsSuumoFtp)){
                msg = CommonConst.PORTALSITE_NAME_SUUMO;
            }
            if(String.isBlank(this.IsHomesFtp)){
                if(String.isNotBlank(msg)){
                    msg += '・';
                }
                msg += CommonConst.PORTALSITE_NAME_HOMES;
            }
            if(String.isBlank(IsAtHomeFtp)){
                if(String.isNotBlank(msg)){
                    msg += '・';
                }
                msg += CommonConst.PORTALSITE_NAME_AT_HOME;
            }
			// ▼ 2022.03.25 CHINTAI対応追加
			if(String.isBlank(IsChintaiWebApi)){
                if(String.isNotBlank(msg)){
                    msg += '・';
                }
                msg += CommonConst.PORTALSITE_NAME_CHINTAI;
            }
			// ▲ 2022.03.25 CHINTAI対応追加
            if(String.isNotBlank(msg)){
               unlistedSiteMsgOfShop = CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_UNLISTED_SITE_MSG_OF_SHOP, msg);
            }
            return unlistedSiteMsgOfShop;
        }
    }

    // 画面表示用内部クラス（部屋）
    public class ScreenRoom {
        // チェック状態
        public Boolean IsChecked { get; set; }
        // 部屋
        public Room__c Room { get; set; }
        // コンストラクタ
        public screenRoom(Room__c room) {
            // 初期化
            this.isChecked = false;
            this.Room = room;
        }
    }

    // 画面表示用内部クラス（添付ファイル）
    public class ScreenPropertyAttachments {
        public List<Id>         Id                  { get; set; }   // Id
        public List<Id>         ParentId            { get; set; }   // 参照先Id（物件Id）
        public List<String>     Name                { get; set; }   // ファイル名
        public List<Datetime>   LastModifiedDate    { get; set; }   // 最終更新日
        public List<Integer>    BodyLength          { get; set; }   // ファイルサイズ
        public List<String>     ContentType         { get; set; }   // コンテンツタイプ
        public Integer          TotalBodyLength     { get; set; }   // ファイルサイズ合計
        // コンストラクタ
        public screenPropertyAttachments(List<Attachment> targetPropertyAttachments){
            this.Id                 = new List<Id>();       // Id
            this.ParentId           = new List<Id>();       // 参照先Id（物件Id）
            this.Name               = new List<String>();   // ファイル名
            this.LastModifiedDate   = new List<Datetime>(); // 最終更新日
            this.BodyLength         = new List<Integer>();  // ファイルサイズ
            this.ContentType        = new List<String>();   // コンテンツタイプ
            this.TotalBodyLength    = 0;                    // ファイルサイズ合計
            for (Attachment propertyAttachment : targetPropertyAttachments) {
                this.Id.add(                propertyAttachment.Id);                 // Id
                this.ParentId.add(          propertyAttachment.ParentId);           // 参照先Id（物件Id）
                this.Name.add(              propertyAttachment.Name);               // ファイル名
                this.LastModifiedDate.add(  propertyAttachment.LastModifiedDate);   // 最終更新日
                this.BodyLength.add(        propertyAttachment.BodyLength);         // ファイルサイズ
                this.ContentType.add(       propertyAttachment.ContentType);        // コンテンツタイプ
                this.TotalBodyLength     += propertyAttachment.BodyLength;          // ファイルサイズ合計
            }
        }
    }

    // 画面表示用内部クラス（火災保険）
    public class ScreenFireInsuranceItem {
        public Boolean IsChecked    { get; set; }   // チェック状態
        public Boolean IsChecked2   { get; set; }   // チェック状態コントローラ値渡し用
        public Id     Id            { get; set; }   // 商品Id
        public Id     AccountId     { get; set; }   // 取引先Id
        public String AccountName   { get; set; }   // 火災保険会社名
        public String ItemName      { get; set; }   // 火災保険商品名
        public String ItemFeeMonth  { get; set; }   // 火災保険料月額
        public String ItemFeeYear   { get; set; }   // 火災保険料年額
        public String PaymentType   { get; set; }   // 更新期間
        public String PaymentYear   { get; set; }   // 更新年数
        public String ItemFee       { get; set; }   // 火災保険料（月額/年額）
        public String Detail        { get; set; }   // プラン詳細
        // コンストラクタ
        public screenFireInsuranceItem(InsuranceGuarantee__c targetFireInsuranceItem, Id propertyFireInsurancePlan) {
            // データセット
            this.Id             = targetFireInsuranceItem.Item__c;
            this.AccountId      = targetFireInsuranceItem.Item__r.Account__c;
            this.AccountName    = targetFireInsuranceItem.Item__r.Account__r.Name;
            this.ItemName       = targetFireInsuranceItem.Item__r.ItemName__c;
            this.ItemFeeMonth   = CommonUtil.decimalToString(targetFireInsuranceItem.Item__r.FireInsuranceMonth__c);
            this.ItemFeeYear    = CommonUtil.decimalToString(targetFireInsuranceItem.Item__r.FireInsuranceYear__c);
            this.PaymentType    = targetFireInsuranceItem.Item__r.PaymentType__c;
            this.PaymentYear    = CommonUtil.decimalToString(targetFireInsuranceItem.Item__r.PaymentYear__c);
            // 選択状態
            this.IsChecked = targetFireInsuranceItem.Item__c == propertyFireInsurancePlan;
            this.IsChecked2= targetFireInsuranceItem.Item__c == propertyFireInsurancePlan;
            // プラン詳細
            if (this.PaymentType == CommonConst.ITEM_PAYMENTTYPE_MONTH) {
                this.ItemFee = this.ItemFeeMonth;
                this.Detail  = '月額料金 ' + this.ItemFeeMonth + '円';
            } else if (this.PaymentType == CommonConst.ITEM_PAYMENTTYPE_YEAR) {
                this.ItemFee = this.ItemFeeYear;
                this.Detail  = '年額料金 ' + this.ItemFeeYear + '円';
            }
        }
    }
    // 画面表示用内部クラス（保証プラン）
    public class ScreenGuaranteePlanItem {
        public Boolean IsChecked    { get; set; }   // チェック状態
        public Boolean IsChecked2   { get; set; }   // チェック状態コントローラ値渡し用
        public Id     Id            { get; set; }   // 商品Id
        public Id     AccountId     { get; set; }   // 取引先Id
        public String AccountName   { get; set; }   // 保証会社名
        public String ItemName      { get; set; }   // 保証プラン名
        public String Detail        { get; set; }   // 保証プラン詳細
        // コンストラクタ
        public screenGuaranteePlanItem(InsuranceGuarantee__c targetGuaranteePlanItem, Id propertyGuaranteePlanPlan) {
            // データセット
            this.Id             = targetGuaranteePlanItem.Item__c;
            this.AccountId      = targetGuaranteePlanItem.Item__r.Account__c;
            this.AccountName    = targetGuaranteePlanItem.Item__r.Account__r.Name;
            this.ItemName       = targetGuaranteePlanItem.Item__r.ItemName__c;
            this.Detail         = String.isEmpty(targetGuaranteePlanItem.Item__r.AssuranceContent__c)
                                ? '' : targetGuaranteePlanItem.Item__r.AssuranceContent__c;
            if (targetGuaranteePlanItem.Item__r.DirectDebitFeeTaxType__c == CommonConst.PROPERTY_TAXTYPE_TAXABLE) {
                if (targetGuaranteePlanItem.Item__r.DirectDebitFeeTax__c != null && targetGuaranteePlanItem.Item__r.DirectDebitFeeTax__c != null) {
                    this.Detail = this.Detail + '\n' + '口座振替手数料 ' + CommonUtil.decimalToString(targetGuaranteePlanItem.Item__r.DirectDebitFeeTax__c) + '円（税込）';
                }
            } else if (targetGuaranteePlanItem.Item__r.DirectDebitFeeTaxType__c == CommonConst.PROPERTY_TAXTYPE_NOTAXABLE) {
                if (targetGuaranteePlanItem.Item__r.DirectDebitFee__c != null && targetGuaranteePlanItem.Item__r.DirectDebitFee__c != null) {
                    this.Detail = this.Detail + '\n' + '口座振替手数料 ' + CommonUtil.decimalToString(targetGuaranteePlanItem.Item__r.DirectDebitFee__c) + '円';
                }
            }
            this.Detail = this.Detail.escapeHtml4().replaceAll('\n', '<br/>');
            // 選択状態
            this.IsChecked = this.Id == propertyGuaranteePlanPlan;
            this.IsChecked2= this.Id == propertyGuaranteePlanPlan;
        }
    }
    // 画面表示用内部クラス（管理会社指定商品）
    public class ScreenManagementCompanyItem {
        ManagementCompanyItem__c record { get; set; }   // 管理会社指定商品レコード
        public Boolean IsChecked    { get; set; }   // チェック状態
        public Id     Id            { get; set; }   // 商品Id
        public String ItemName      { get; set; }   // 商品名
        public String Amount        { get; set; }   // 金額
        public String AmountTax     { get; set; }   // 金額(税込)
        public String PaymentType   { get; set; }   // 支払区分
        public String TaxType       { get; set; }   // 税区分
        public String Detail        { get; set; }   // プラン詳細
        // コンストラクタ
        public screenManagementCompanyItem(ManagementCompanyItem__c targetManagementCompanyItem) {
            // データセット
            this.record         = targetManagementCompanyItem.clone();
            this.Id             = targetManagementCompanyItem.Id;
            this.Amount         = CommonUtil.decimalToString(targetManagementCompanyItem.Amount__c);
            this.AmountTax      = CommonUtil.decimalToString(targetManagementCompanyItem.AmountTax__c);
            this.ItemName       = targetManagementCompanyItem.ItemName__c;
            this.PaymentType    = targetManagementCompanyItem.PaymentType__c;
            this.TaxType        = targetManagementCompanyItem.TaxType__c;
            this.Detail = this.ItemName + ' ' + this.AmountTax + '円';
            if (this.PaymentType == CommonConst.MANAGEMENTCOMPANYITEM_PAYMENTTYPE_MONTH) {
                this.Detail = this.Detail + '/' + CommonConst.MANAGEMENTCOMPANYITEM_PAYMENTTYPE_MONTH;
            } else if (this.PaymentType == CommonConst.MANAGEMENTCOMPANYITEM_PAYMENTTYPE_YEAR) {
                this.Detail = this.Detail + '/' + CommonConst.MANAGEMENTCOMPANYITEM_PAYMENTTYPE_YEAR;
            }
            // 選択状態
            this.IsChecked = false;
            if (targetManagementCompanyItem.propertyManageCompayItemItem__r.size() > 0) {
                this.IsChecked = true;
            }
        }
    }

    // 写真情報内部クラス
    private class PhotoData {
        public String FileName  { get; set; }   // ファイル名
        public String FilePath  { get; set; }   // ファイルパス
        public String Tag       { get; set; }   // タグ
        public String Comment   { get; set; }   // コメント
        public Integer Index    { get; set; }   // 写真インデックス
    }
    // 写真情報処理用内部クラス
    public class ScreenAnyPhotoData {
        public String foreignId                 { get; set; }   // 外部Id（物件）
        public String buildingForeignId         { get; set; }   // 外部Id（建物）
        public AmazonS3Util.PhotoType photoType { get; set; }   // 写真種別
        public Integer photoCount               { get; set; }   // 写真登録数
        public List<PhotoData> photoDataList    { get; set; }   // 写真情報
        public ScreenAnyPhotoData() {
            // 初期化
            this.photoDataList  = new List<PhotoData>();
            this.photoCount = 0;
        }
        public ScreenAnyPhotoData(String foreignId, String buildingForeignId, AmazonS3Util.PhotoType photoType) {
            // 初期化
            this.photoDataList  = new List<PhotoData>();
            if (photoType == AmazonS3Util.PhotoType.PROPERTY_ROOMLAYOUT
             || photoType == AmazonS3Util.PhotoType.PROPERTY_ROOMLAYOUTMEMO) {
                this.photoDataList.add(new PhotoData());
            }
            this.photoType         = photoType;
            this.foreignId         = foreignId;
            this.buildingForeignId = buildingForeignId;
            this.photoCount = 0;
        }
        public ScreenAnyPhotoData(PropertyPhoto__c propertyPhoto, AmazonS3Util.PhotoType photoType) {
            // 初期化
            this.photoDataList  = new List<PhotoData>();
            // データセット
            this.photoType         = photoType;
            this.foreignId         = propertyPhoto.Property__r.ForeignID__c;
            this.buildingForeignId = propertyPhoto.Property__r.Building__r.ForeignID__c;
            this.photoCount = 0;
            PhotoData data;
            switch on photoType {
                when PROPERTY {
                    // 物件写真
                    for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PROPERTY; i++) {
                        data = new photoData();
                        data.FileName   = (String)propertyPhoto.get('PropertyPhotoFileName' + i + '__c');
                        data.FilePath   = (String)propertyPhoto.get('PropertyPhotoFilePath' + i + '__c');
                        data.Tag        = (String)propertyPhoto.get('PropertyPhotoTag' + i + '__c');
                        data.Comment    = (String)propertyPhoto.get('PropertyPhotoComment' + i + '__c');
                        data.Index      = i;
                        if (!String.isEmpty(data.FileName)) {
                            this.photoDataList.add(data);
                            photoCount += 1;
                        }
                    }
                }
                when PROPERTY_PRIVATE {
                    // 物件非公開写真
                    for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PRIVATE; i++) {
                        data = new photoData();
                        data.FileName   = (String)propertyPhoto.get('PrivatePhotoFileName' + i + '__c');
                        data.FilePath   = (String)propertyPhoto.get('PrivatePhotoFilePath' + i + '__c');
                        data.Tag        = (String)propertyPhoto.get('PrivatePhotoType' + i + '__c');
                        data.Comment    = (String)propertyPhoto.get('PrivatePhotoComment' + i + '__c');
                        data.Index      = i;
                        if (!String.isEmpty(data.FileName)) {
                            this.photoDataList.add(data);
                            photoCount += 1;
                        }
                    }
                }
                when PROPERTY_PANORAMA {
                    // 物件パノラマ写真
                    for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PANORAMA; i++) {
                        data = new photoData();
                        data.FileName   = (String)propertyPhoto.get('PanoramaFileName' + i + '__c');
                        data.FilePath   = (String)propertyPhoto.get('PanoramaFilePath' + i + '__c');
                        data.Tag        = (String)propertyPhoto.get('PanoramaTag' + i + '__c');
                        data.Comment    = (String)propertyPhoto.get('PanoramaComment' + i + '__c');
                        data.Index      = i;
                        if (!String.isEmpty(data.FileName)) {
                            this.photoDataList.add(data);
                            photoCount += 1;
                        }
                    }
                }
                when PROPERTY_ROOMLAYOUT {
                    // 間取り図
                    data = new photoData();
                    data.FileName   = propertyPhoto.RoomLayoutFileName__c;
                    //▼問合せNo0487で変更
                    // 同ファイル名の画像が更新されない（同ファイル名のキャッシュ）問題を防ぐため
                    data.FilePath   = CommonUtil.getCacheAvoidancePath(propertyPhoto.RoomLayoutFilePath__c);
                    //▲問合せNo0487で変更
                    data.Index      = 1;
                    this.photoDataList.add(data);
                    if (!String.isEmpty(data.FileName)) {
                        photoCount += 1;
                    }
                }
                when PROPERTY_ROOMLAYOUTMEMO {
                    // 間取り図（メモ有）
                    data = new photoData();
                    data.FileName   = propertyPhoto.RoomLayoutMemoFileName__c;
                    data.FilePath   = propertyPhoto.RoomLayoutMemoFilePath__c;
                    data.Index      = 1;
                    this.photoDataList.add(data);
                    if (!String.isEmpty(data.FileName)) {
                        photoCount += 1;
                    }
                }
            }
        }
    }

    // 画面表示用内部クラス（非公開写真アップロード状況）
    public class ScreenPrivatePhotoStats {
        public String Tag   { get; set; }   // 非公開写真タグ名
        public String Stats { get; set; }   // アップロード状況
        // コンストラクタ
        public ScreenPrivatePhotoStats(ScreenAnyPhotoData privatePhotoList, String tag) {
            // データセット
            this.Tag = tag;
            this.Stats = '未';
            for (PhotoData record : privatePhotoList.photoDataList) {
                if (record.Tag == tag) {
                    this.Stats = '済';
                }
            }
        }
    }

    // チェックボックス（単一選択）での選択リスト表示用クラス
    public class screenSelectList {
        public List<SelectOption> selectOptions { get; set; }   // セレクトオプション
        public List<String> valueList { get; set; }             // 値リスト
        public Map<String, String> nameMapList { get; set; }    // 値、表示名リスト
        public Map<String, Boolean> checkMapList { get; set; }  // 値、チェック状態リスト
        // コンストラクタ
        public screenSelectList(List<SelectOption> selectTypeList) {
            // 初期化
            this.valueList = new List<String>();
            this.nameMapList = new Map<String, String>();
            this.checkMapList = new Map<String, Boolean>();
            // データセット
            this.selectOptions = selectTypeList.clone();
            for (SelectOption option : selectTypeList) {
                String value = option.getValue();
                String label = option.getLabel();
                this.valueList.add(value);
                this.nameMapList.put(value, label);
                this.checkMapList.put(value, false);
            }
        }
        // 選択値の設定
        public void setCheckValue(String selectValue) {
            for (String value : this.valueList) {
                this.checkMapList.put(value, value == selectValue);
            }
        }
        // 選択値の取得
        public String getCheckValue() {
            String retValue = '';
            for (String value : this.valueList) {
                if (this.checkMapList.get(value)) {
                    retValue = value;
                }
            }
            return retValue;
        }
        // 対象チェック以外のチェック解除
        public void setOtherCheckCancel(String selectValue) {
            for (String value : this.valueList) {
                if (value != selectValue) {
                    this.checkMapList.put(value, false);
                }
            }
        }
    }

    /**
     * メンテナンス物件コード履歴用内部クラス
     */
    public class ScreenPropertyCdHist {

        // フィールド
        public PropertyCodeHistory__c Entity                      {get; set;} // エンティティ
        public String                 parentRowClass              {get; set;} // 親行クラス
        public Id                     Id                          {get; set;} // ID
        public Boolean                IsSelected                  {get; set;} // 選択行
        public String                 HistMaintenancePropertyCd   {get; set;} // 履歴メンテナンス物件コード
        public String                 HistImportDestination       {get; set;} // 履歴取込先
        public String                 InformationUpdateDate       {get; set;} // 情報更新日

        // 定数
        private final String PARENT_ROW_CLASS = 'parent-row'; // 親行（名寄せ先）クラス

        /**
         * コンストラクタ
         */
        public screenPropertyCdHist(PropertyCodeHistory__c propertyCdHist) {

            // 親行クラス
            this.parentRowClass            = (propertyCdHist.Property__c == propertyCdHist.HistoryProperty__c)
                                                ? PARENT_ROW_CLASS : CommonConst.STRING_EMPTY;
            
            // オブジェクト項目
            this.Entity                    = propertyCdHist;                                   // エンティティ
            this.Id                        = propertyCdHist.Id;                                // ID
            this.IsSelected                = false;                                            // 選択行
            this.HistMaintenancePropertyCd = propertyCdHist.HistoryMaintenancePropertyCode__c; // 履歴メンテナンス物件コード
            this.HistImportDestination     = propertyCdHist.HistoryImportDestination__c;       // 履歴取込先
        
            this.convertFieldsNull();
        }

        /**
         * フィールドのNULL値変換
         */
        private void convertFieldsNull() { 

            // NULL値チェックのみ
            HistMaintenancePropertyCd = String.isEmpty(HistMaintenancePropertyCd) ? CommonConst.STRING_EMPTY: HistMaintenancePropertyCd; // 履歴メンテナンス建物コード
            HistImportDestination     = String.isEmpty(HistImportDestination)     ? CommonConst.STRING_EMPTY: HistImportDestination;     // 履歴取込先
            
            // NULL値チェック後に処理有り
            // 情報更新日（"yyyy/MM/dd HH:mm"形式に変更）
            InformationUpdateDate     = Entity.InformationUpdateDate__c == null   ? CommonConst.STRING_EMPTY
                                                                                    : Entity.InformationUpdateDate__c.format('yyyy/MM/dd HH:mm');
        }
    }
}