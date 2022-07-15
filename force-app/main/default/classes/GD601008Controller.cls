/**
 *物件名寄せ比較のコントローラ
 */
public inherited sharing class GD601008Controller {
    //メッセージ
    public String MSG_COM_V_EXECUTE_MERGE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_EXECUTE_MERGE);} private set;}    //js用名寄せ確認メッセージ
    public String MSG_COM_I_MERGE_END {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_MERGE_END);} private set;}    //js用名寄せ完了メッセージ
    public String MSG_PROP_I_NOTICE_WEBPUBLISHING_NO {get{return CommonUtil.callMessageCreate(CommonConst.MSG_PROP_I_NOTICE_WEBPUBLISHING_NO);} private set;}    //js用web公開しない変更メッセージ
    public String MSG_PROP_I_NOTICE_DELETE_RECOMMEND {get{return CommonUtil.callMessageCreate(CommonConst.MSG_PROP_I_NOTICE_DELETE_RECOMMEND);} private set;}    //js用おすすめ物件削除メッセージ

    //パブリック変数
    public Boolean isOpenError { get; set; }           //エラーフラグ
    public Boolean hasErrorMessage { get; set; }       //エラーメッセージ保有フラグ
    public String transitionId { get; set; } //画面遷移用建物Id

    //物件リスト
    public Property__c leftProperty { get; set; }//左
    public Property__c rightProperty { get; set; }//右
    //物件写真リスト
    public ScreenAnyPhotoData leftPhoto { get; set; }//左
    public ScreenAnyPhotoData rightPhoto { get; set; }//右
    //間取り図
    public String leftRoomLayout{ get; set; }//左
    public String rightRoomLayout{ get; set; }//右
    //関連リスト
    public List<Room__c> leftRoomList { get; set; }//部屋
    public List<Room__c> rightRoomList { get; set; }
    public List<PropertyManageCompayItem__c> leftPMCIList { get; set; }//付帯商品
    public List<PropertyManageCompayItem__c> rightPMCIList { get; set; }
    public String leftAssuranceContentPlus{get; set;}//保証内容
    public String rightAssuranceContentPlus{get; set;}
    //添付ファイル
    public List<screenAttachment> leftAttachment{ get; set; }
    public List<screenAttachment> rightAttachment{ get; set; }
    //物件条件
    public List<String> leftConditionsFacility{ get; set; }
    public List<String> rightConditionsFacility{ get; set; }
    //物件条件（設備項目以外）
    public PropertyConditions__c leftConditions{ get; set; }
    public PropertyConditions__c rightConditions{ get; set; }
    //ラジオボタン値
    public String FormerSupplierRadioButton { get; set; }//元付セクション
    public String BasicInfoRadioButton { get; set; }//基本情報セクション
    public String pictureRadioButton { get; set;}// 画像・パノラマセクション
    public String floorPlanRadioButton { get; set;}// 間取り図セクション

    // web公開しないに変更時のメッセージ表示フラグ
    public Boolean IsWebPublishingNoMessageFlg { get; set; }// false:メッセージを表示しない、true:メッセージを表示する。

    // おすすめ物件削除時のメッセージ表示フラグ
    public Boolean IsDeleteRecommendPropertyMessageFlg { get; set; }// false:メッセージを表示しない、true:メッセージを表示する。

    //プライベート変数
    private String id1;   //物件IDパラメータ
    private String id2;  //物件IDパラメータ
    private Property__c ExchangeRecord;//左右入れ替え用（初期表示の際のみ使う）
     //Upsert用
    private PropertyPhoto__c leftPhotoUpsert; 
    private PropertyPhoto__c rightPhotoUpsert;
    private List<Attachment> leftAttachmentUpsert;
    private List<Attachment> rightAttachmentUpsert;
    // AmazonS3への接続に使用する情報
    private static String bucketName       { get{return SystemConfig__c.getInstance().S3BucketName__c;}         private set; }   // バケット名

    //ポータルサイト構築 追加 Start
    private Boolean isOpetionPortal;  // 自社ポータル権限
    private List<String> deleteRecommendPropertyURL;  // 名寄せ対象のパノラマツアーURL
    //ポータルサイト構築 追加 End
    // 定数
    private static final String IS_S3FILEMOVE_BATCHPROCESSING = CommonConst.IS_S3FILEMOVE_BATCHPROCESSING; //システム変数　項目名
    private static final String PHOTO_TYPE_PUBLIC = '公開';
    private static final String PHOTO_TYPE_PRIVATE = '非公開';
    private static final String PHOTO_TYPE_PANORAMA = 'パノラマ';

    //コンストラクタ
    public GD601008Controller() {
        try{

            this.isOpenError = false;
            this.hasErrorMessage = false;

            //店舗異動が取得できなければエラー
            CommonUtil.getStaffCurrentShop();

            //パラメータ取得        
            this.id1 = ApexPages.currentPage().getParameters().get('id1');//物件id1
            this.id2 = ApexPages.currentPage().getParameters().get('id2'); //物件id2
	
            //レコード情報取得
            this.isOpetionPortal = AuthorityCheckUtil.getAuthorityOptionPortal(false);         //自社ポータル権限を取得
            leftConditions = new PropertyConditions__c();
            rightConditions = new PropertyConditions__c();
            leftAttachment = new List<screenAttachment>();  
            rightAttachment = new List<screenAttachment>();
            leftPhotoUpsert = new PropertyPhoto__c();         
            rightPhotoUpsert = new PropertyPhoto__c();

            init();
     

        }catch(Exception e){
            //エラーを設定
            isOpenError = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    //************************************publicメソッド************************************************************************
    //元付ラジオボタン
    public List<SelectOption> getFormerSupplierRadioButtonSetting(){
        return initRadioButton();
    }
    //基本情報ラジオボタン
    public List<SelectOption> getBasicInfoRadioButtonSetting(){
        return initRadioButton();
    }
    // 画像・パノラマセクションラジオボタン
    public List<SelectOption> getPictureRadioButtonSetting(){
        return initRadioButton();
    }
    // 間取り図セクションラジオボタン
    public List<SelectOption> getFloorPlanRadioButtonSetting(){
        return initRadioButton();
    }
    // ラジオボタン初期化処理
    private List<SelectOption> initRadioButton() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('左', ''));
        options.add(new SelectOption('右', ''));
        return options;
    }
    //登録ボタン
    public void save(){
        Savepoint sp = Database.setSavepoint();      //セーブポイント作成
        hasErrorMessage = false;
        try{
            //楽観ロックチェック
            List<Property__c> leftCheckOptimisticLockExceptionRecord = new List<Property__c>();
            List<Property__c> rightCheckOptimisticLockExceptionRecord = new List<Property__c>();
            leftCheckOptimisticLockExceptionRecord = [ SELECT id
                                                        FROM Property__c
                                                    WHERE id = :leftProperty.Id
                                                        AND SystemModStamp = :leftProperty.systemModStamp ];
            rightCheckOptimisticLockExceptionRecord = [ SELECT id
                                                        FROM Property__c
                                                        WHERE id = :rightProperty.Id
                                                        AND SystemModStamp = :rightProperty.systemModStamp ];
            
            //どちらかのデータ取得できない場合、楽観ロックチェックExceptionを発行
            if (leftCheckOptimisticLockExceptionRecord.isEmpty() || rightCheckOptimisticLockExceptionRecord.isEmpty()) {
                OptimisticLockException ex = new OptimisticLockException();
                throw ex;
            }
            Property__c mergePro;//残す物件
            Property__c delPro;//消す物件
            List<PropertyManageCompayItem__c> mergePMCIList;//変更する物件管理会社指定
            List<PropertyManageCompayItem__c> delPMCIList;//消す物件管理会社指定
            List<Room__c> delRoomList;//消す部屋
            List<Attachment> delAttList;//消す添付
            Boolean pictureMoveFlg = false; // 写真移動フラグ
            Boolean floorPictureMoveFlg = false; // 間取り図移動フラグ
            PropertyPhoto__c unselectPicture = new PropertyPhoto__c(); // 選択されなかった写真
            PropertyPhoto__c selectPicture = new PropertyPhoto__c(); // 選択された写真
            PropertyPhoto__c unselectFloorPicture = new PropertyPhoto__c(); // 選択されなかった間取り図
            PropertyPhoto__c selectFloorPicture = new PropertyPhoto__c(); // 選択された間取り図
            List<String> unselectFilePassList = new List<String>(); //削除対象の写真のファイルパスのリスト
            if(leftPhotoUpsert.id == null) {
                SecureDML.secureInsert(leftPhotoUpsert);
                leftPhotoUpsert = SettingPhotoInfo(leftPhotoUpsert.Property__c, '左');
            }
            if(rightPhotoUpsert.id == null) {
                SecureDML.secureInsert(rightPhotoUpsert);
                rightPhotoUpsert = SettingPhotoInfo(rightPhotoUpsert.Property__c, '右');
            }

            //基本情報のチェック側に寄せる
            if(BasicInfoRadioButton=='左'){
                //残す側を左に設定
                mergePro = leftProperty;
                mergePMCIList = rightPMCIList;//物件管理会社指定のみ残す側を右に（寄せる場合、idを左にするため）
                selectPicture = leftPhotoUpsert;
                selectFloorPicture = leftPhotoUpsert;

                //右を消す側に設定
                delPro = rightProperty;
                delPMCIList = leftPMCIList;
                delRoomList = rightRoomList;
                delAttList = rightAttachmentUpsert;
                unselectPicture = rightPhotoUpsert;
                unselectFloorPicture = rightPhotoUpsert;

            }else{
                //残す側を右に設定
                mergePro = rightProperty;
                mergePMCIList = leftPMCIList;//残す側を左（寄せる場合、idを右にする）
                selectPicture = rightPhotoUpsert;
                selectFloorPicture = rightPhotoUpsert;
                //左を消す側に設定（物件条件、写真は主従関係なので省略）
                delPro = leftProperty;
                delPMCIList = rightPMCIList;
                delRoomList = leftRoomList;
                delAttList = leftAttachmentUpsert;
                unselectPicture = leftPhotoUpsert;
                unselectFloorPicture = leftPhotoUpsert;
            }
            //更新設定
            mergePro.MaintenanceCommentArea__c= mergePro.Name +'に'+delPro.Name +'を名寄せしました。';//メンテナンスコメント
            mergePro.MaintenanceType__c = CommonConst.MAINTENANCETYPE_NAMEIDENTIFICATION ;//メンテナンス区分
            mergePro.MaintenanceStaff__c =UserInfo.getUserid();//メンテナンススタッフ

            // 基本情報セクションが左であり、基本情報セクションと画像・パノラマセクションの値が違う場合
            if(pictureRadioButton != BasicInfoRadioButton) {
                pictureMoveFlg = true;
                if (BasicInfoRadioButton == '左') {
                    // 左に紐づいている物件写真を削除対象に設定
                    unselectPicture = leftPhotoUpsert;
                    selectPicture = rightPhotoUpsert;
                } else if(BasicInfoRadioButton == '右') {
                    // 右に紐づいている物件写真を削除対象に設定
                    unselectPicture = rightPhotoUpsert;
                    selectPicture = leftPhotoUpsert;
                }
            }
            // 基本情報セクションが左であり、基本情報セクションと間取り図セクションの値が違う場合
            if(floorPlanRadioButton != BasicInfoRadioButton) {
                floorPictureMoveFlg = true;
                if (BasicInfoRadioButton == '左') {
                    unselectFloorPicture = leftPhotoUpsert;
                    selectFloorPicture = rightPhotoUpsert;
                } else if(BasicInfoRadioButton == '右') {
                    unselectFloorPicture = rightPhotoUpsert;
                    selectFloorPicture = leftPhotoUpsert;
                }
            }
            // ポータルサイト利用権限ありの場合、削除対象の写真とファイルパスを取得
            if(SystemConfig__c.getInstance().UseAuthority_Portal__c) {
                // 削除対象の写真のファイルパスのリスト
                unselectFilePassList = getFilePassList(unselectPicture);
            }

            if (FormerSupplierRadioButton != BasicInfoRadioButton){             

                //元付
                mergePro.FormerSupplier__c = delPro.FormerSupplier__c;//元付業者
                mergePro.FireInsurancePlan__c =delPro.FireInsurancePlan__c;//火災保険
                mergePro.Guaranteeid__c =delPro.Guaranteeid__c;//保証
                if (delPMCIList.size() != 0){
                    SecureDML.secureDelete(delPMCIList);
                }
                if (mergePMCIList.size() != 0){//物件管理会社指定
                    for (PropertyManageCompayItem__c pmci : mergePMCIList){
                        pmci.Property__c = mergePro.id;
                    }
                    SecureDML.secureUpdate(mergePMCIList);
                }
            }

            //名寄せ完了フラグ更新
            if (NameMergeUtil.getPropertyMergeList(mergePro,delPro.Id).size() != 0){
                //リストあり…名寄せ完了フラグfalse
                mergePro.IsMergeCompletedFlag__c = false;
            }else{
                //リスト空…名寄せフラグtrue
                mergePro.IsMergeCompletedFlag__c = true;
            }

            // 残る物件がWeb公開がするの場合、メッセージ出力
            if(mergePro.WebPublishing__c == CommonConst.PROPERTY_WEBPUBLISHING_EXISTS) {
                IsWebPublishingNoMessageFlg = true;
            }

            // web公開の更新
            setWebPublishing(mergePro);

            // 基本情報と公開、非公開、パノラマ写真が異なる場合
            if(pictureMoveFlg) {
                // 名寄せにより削除される物件写真を残る側へ置き換える
                unselectPicture = replacePropertyPicture(selectPicture, unselectPicture);
                // 削除される側のat homeパノラマコンテンツID、パノラマ掲載店舗を残る側へ置き換える。
                mergePro.AthomePanoramaContentsId__c = String.isEmpty(delPro.AthomePanoramaContentsId__c) ? 
                                                    CommonConst.STRING_EMPTY : delPro.AthomePanoramaContentsId__c; //at homeパノラマコンテンツID
                mergePro.SuumoPanoramaShop__c = delPro.SuumoPanoramaShop__c; //SUUMOパノラマ掲載店舗
                mergePro.HomesPanoramaShop__c = delPro.HomesPanoramaShop__c; //HOME'Sパノラマ掲載店舗
                mergePro.AtHomePanoramaShop__c = delPro.AtHomePanoramaShop__c; //at homeパノラマ掲載店舗
            }

            // 基本情報と間取り図が異なる場合
            if(floorPictureMoveFlg) {
                // 名寄せにより削除される間取り図を残る側へ置き換える
                unselectFloorPicture = replacePropertyFloorPicture(selectFloorPicture, unselectFloorPicture);
            }

            //名寄せによる削除側でセットされている物件、お気に入り物件を残る側の物件に置き換える。
            updatePropertyId(delPro.Id,mergePro.id, delpro.PropertyCode__c, mergePro.PropertyCode__c, pictureMoveFlg);

            // 選ばれなかった物件写真に紐づくおすすめ物件データ削除
            if(unselectFilePassList.size() > 0){
                List<RecommendProperty__c> unselectRecommendPropertyList = getRecommendProperty(unselectFilePassList);
                // お気に入り物件が取得できた場合、削除
                if(unselectRecommendPropertyList.size() != 0) {
                    for(RecommendProperty__c recommendProp : unselectRecommendPropertyList) {
                        // パノラマツアーの非公開処理
                        this.deleteRecommendPropertyURL.add(recommendProp.PanoramaTourUrl__c);
                    }
                    // 削除処理
                    SecureDML.secureDelete(unselectRecommendPropertyList);
                    IsDeleteRecommendPropertyMessageFlg = true;
                }
            }
            
            // 建物写真の取得
            BuildingPhoto__c buildPhoto = getBuildPhoto(transitionId);

            // 建物作成
            Building__c build = new Building__c(id = transitionId);

            // SUUMOスコア再計算
            mergePro.Score__c = BuildingPropertyUtil.getSuumoScore(build, buildPhoto, mergePro, selectPicture);
            
            //更新
            SecureDML.secureUpdate(mergePro);
            
            //削除
            if (delRoomList.size() != 0){//部屋
                SecureDML.secureDelete(delRoomList);
            }
            if (delAttList.size() != 0){//添付
                SecureDML.secureDelete(delAttList);
            }

            // 物件写真を更新
            if(pictureMoveFlg) {
                // 残る物件の公開、非公開、パノラマ写真を削除
                AmazonS3Util.callPropertyPhotoDeleteType(mergePro.id,AmazonS3Util.PhotoType.PROPERTY);
                AmazonS3Util.callPropertyPhotoDeleteType(mergePro.id,AmazonS3Util.PhotoType.PROPERTY_PRIVATE);
                AmazonS3Util.callPropertyPhotoDeleteType(mergePro.id,AmazonS3Util.PhotoType.PROPERTY_PANORAMA);
            } else {
                AmazonS3Util.callPropertyPhotoDeleteType(delPro.id,AmazonS3Util.PhotoType.PROPERTY);
                AmazonS3Util.callPropertyPhotoDeleteType(delPro.id,AmazonS3Util.PhotoType.PROPERTY_PRIVATE);
                AmazonS3Util.callPropertyPhotoDeleteType(delPro.id,AmazonS3Util.PhotoType.PROPERTY_PANORAMA);
            }

            // 間取り図を更新
            if(floorPictureMoveFlg) {
                AmazonS3Util.callPropertyPhotoDeleteType(mergePro.id,AmazonS3Util.PhotoType.PROPERTY_ROOMLAYOUT);
                AmazonS3Util.callPropertyPhotoDeleteType(mergePro.id,AmazonS3Util.PhotoType.PROPERTY_ROOMLAYOUTMEMO);
            } else {
                AmazonS3Util.callPropertyPhotoDeleteType(delPro.id,AmazonS3Util.PhotoType.PROPERTY_ROOMLAYOUT);
                AmazonS3Util.callPropertyPhotoDeleteType(delPro.id,AmazonS3Util.PhotoType.PROPERTY_ROOMLAYOUTMEMO);
            }

            if(pictureMoveFlg) {
                SecureDML.secureUpdate(unselectPicture);
            }
            if(floorPictureMoveFlg) {
                SecureDML.secureUpdate(unselectFloorPicture);
            }

            // 写真の移動を行う
            pictureMovement(unselectPicture, selectPicture, unselectFloorPicture, selectFloorPicture
                            , pictureMoveFlg, floorPictureMoveFlg);

            // 削除される物件に紐づく物件写真のファイル名を取得
            PropertyPhoto__c propertyPhoto = selectPropertyPhotoData(delPro.id);
            // ファイル名をnullに書き換え、更新
            propertyPhoto = fileNameConvertNull(propertyPhoto);
            SecureDML.secureUpdate(propertyPhoto);

            SecureDML.secureDelete(delPro);//物件
      
        }catch(Exception e){
            if(sp != null) {
                Database.rollback(sp);//処理をロールバック
            }
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }

    }

    //ポータルサイト構築 追加 Start
    //登録処理後
    public void saveAfter(){
        // パノラマツアー非公開設定
        if (this.isOpetionPortal){
            try{
                // テストクラス実行時にパノラマツアーのURLをセットする。
                if (Test.isRunningTest()) {
                    this.deleteRecommendPropertyURL.add('testURL');
                }
                // 削除対象のパノラマツアーを判断し非表示にする。
                Theta360bizApiUtil.callTheta360bizToursStatus(this.deleteRecommendPropertyURL);
            }catch(Exception e){
                hasErrorMessage = true;//エラーを設定
                CommonUtil.setErrorMessage(e);

            }
        }
    }
    //ポータルサイト構築 追加 End

    //************************************privateメソッド************************************************************************
    //初期処理
    private void init(){
        //■物件、設備以外の物件条件、写真、間取り図取得

        selectPropertyInfo(Id1);
        selectPropertyInfo(Id2);

        //■左右の関連リスト取得
        //部屋
        leftRoomList = selectRoomInfo(leftProperty.Id);
        rightRoomList = selectRoomInfo(rightProperty.Id);
        //物件管理会社指定
        leftPMCIList = selectPMCIInfo(leftProperty.Id);
        rightPMCIList = selectPMCIInfo(rightProperty.Id);

        //保証会社
        if (!String.isBlank(leftProperty.Guaranteeid__c)){
            //内容の設定
            leftAssuranceContentPlus = assuranceContent(leftProperty);
        }
        if (!String.isBlank(rightProperty.Guaranteeid__c)){
            //内容の設定
            rightAssuranceContentPlus = assuranceContent(rightProperty);
        }

        //■物件条件設定
        if (leftProperty.PropertyConditionsProperty__r.size()!=0){
            leftConditionsFacility = propertyConditionsSetting(leftProperty.PropertyConditionsProperty__r);
        }
        if (rightProperty.PropertyConditionsProperty__r.size()!=0){
            rightConditionsFacility = propertyConditionsSetting(rightProperty.PropertyConditionsProperty__r);
        }

        //■添付ファイル
        selectAttachmentsInfo(leftProperty.id, '左');
        selectAttachmentsInfo(rightProperty.id, '右');
        if(leftAttachment.size() > rightAttachment.size()){
            Integer sa= leftAttachment.size() - rightAttachment.size();
            for(Integer i=0 ; i <sa * 3; i++){
                rightAttachment.add(new screenAttachment(new Attachment()));
            }
        }else if(rightAttachment.size() > leftAttachment.size()){
            Integer sa= rightAttachment.size() - leftAttachment.size();
            for(Integer i=0 ; i < sa * 3; i++){
                leftAttachment.add(new screenAttachment(new Attachment()));
            }
        }

        //遷移用Id
        transitionId = leftProperty.Building__c;

        // web公開しない変更メッセージフラグの初期化
        this.IsWebPublishingNoMessageFlg = false;
        this.IsDeleteRecommendPropertyMessageFlg = false;

        //ラジオボタン初期値
        FormerSupplierRadioButton= '左';
        BasicInfoRadioButton= '左';
        pictureRadioButton = '左';
        floorPlanRadioButton = '左';

        this.deleteRecommendPropertyURL = new List<String>();
    }
    //物件条件
    private List<String> propertyConditionsSetting(PropertyConditions__c proCon){
        List<String> strList = new List<String>();
        String str ='';
        //構造・工法・立地・環境（0）
        if (proCon.IsMaisonette__c){
            str += 'メゾネット、';
        }
        if (proCon.IsLoft__c){
            str += 'ロフト、';
        }
        if (proCon.IsDesigners__c){
            str += 'デザイナーズ、';
        }
        if(proCon.IsCondominiumRental__c){
            str += '分譲賃貸、';
        }
        if(proCon.IsAllWesternStyleRoom__c){
            str += 'オール洋間、';
        }
        if(proCon.IsTowerMansion__c){
            str += 'タワーマンション、';
        }
        if(proCon.IsBarrierFree__c){
            str += 'バリアフリー、';
        }
        if(proCon.IsOuterWallTile__c){
            str += '外壁タイル張り、';
        } 
        if(proCon.IsDampingStructure__c){
            str += '制震構造、';
        }
        if(proCon.IsSeismicStructure__c){
            str += '耐震構造、';
        }  
        if(proCon.IsSeismicIsolationStructure__c){
            str += '免震構造、';
        }
        if(proCon.IsUndergroundRoom__c){
            str += '地下室、';
        }
        if(proCon.IsSoundproofRoom__c){
            str += '防音室、';
        }
        if(proCon.IsUndergroundRoom__c){
            str += '地下室、';
        }
        if(proCon.IsSepticTank__c){
            str += '浄化槽、';
        }
        if(proCon.IsQuietResidenceTown__c){
            str += '閑静な住宅街、';
        }
        if(str != null){
            str =str.removeEnd('、');
        }
        strList.add(str);
        
        //フロア・庭・バルコニー（1）
        str = '';
        if(proCon.IsCornerRoom__c){
            str += '角部屋、';
        }
        if(proCon.IsBayWindow__c){
            str += '出窓、';
        }
        if(proCon.IsBayWindow__c){
            str += '出窓、';
        }
        if(proCon.IsPrivateGarden__c){
            str += '専用庭、';
        }
        if(proCon.IsBalcony__c){
            str += 'バルコニー、';
        }
        if(proCon.IsRoofBalcony__c){
            str += 'ルーフバルコニー、';
        }
        if(proCon.IsWoodDeck__c){
            str += 'ウッドデッキ、';
        }
        if(str != null){
            str =str.removeEnd('、');
        }
        strList.add(str);
        
        //駐車・駐輪共用部(2)
        str = '';
        if(proCon.IsBuiltInGarage__c){
            str += 'ビルトインガレージ、';
        }
        if(proCon.IsCarport__c){
            str += 'カーポート、';
        }
        if(proCon.IsElevator__c){
            str += 'エレベーター、';
        }
        if(proCon.IsPluralElevators__c){
            str += 'エレベーター2基、';
        }
        if(proCon.IsInSiteTtrashArea__c){
            str += '敷地内ゴミ置場、';
        }
        if(proCon.IsAnytimeTtrashArea__c){
            str += '24時間ゴミ出し可、';
        }
        if(proCon.IsFrontService__c){
            str += 'フロントサービス、';
        }
        if(proCon.IsDeliveryBox__c){
            str += '宅配ボックス、';
        }
        if(proCon.IsCleaningBox__c){
            str += 'クリーニングボックス、';
        }
        if(proCon.IsCoinLaundry__c){
            str += 'コインランドリー、';
        }
        if(str != null){
            str =str.removeEnd('、');
        }
        strList.add(str);

        //キッチン(3)
        str = '';
        if(proCon.IsCounterKitchen__c){
            str += 'カウンターキッチン、';
        }
        if(proCon.IsSystemKitchen__c){
            str += 'システムキッチン、';
        }
        if(proCon.IsGasStove__c){
            str += 'ガスコンロ、';
        }
        if(proCon.IsElectricStove__c){
            str += '電気コンロ、';
        }
        if(proCon.IsIhStove__c){
            str += 'IHコンロ、';
        }
        if(proCon.IsTwoGasStove__c){
            str += 'コンロ2口、';
        }
        if(proCon.IsMoreGasStove__c){
            str += 'コンロ3口以上、';
        }
        if(proCon.IsWaterPurifier__c){
            str += '浄水器、';
        }
        if(proCon.IsDishwasher__c){
            str += '食器洗い乾燥機、';
        }
        if(proCon.IsDisposer__c){
            str += 'ディスポーザー、';
        }
        if(str != null){
            str =str.removeEnd('、');
        }
        strList.add(str);

        //バス・トイレ洗面所(4)
        str = '';
        if(proCon.IsSeparate__c){
            str += 'バス・トイレ別、';
        }
        if(proCon.IsReheating__c){
            str += '追焚機能、';
        }
        if(proCon.IsHotWaterFormula__c){
            str += '高温差湯式、';
        }
        if(proCon.IsBathroomDryer__c){
            str += '浴室乾燥機、';
        }
        if(proCon.IsBathroomFloorHeating__c){
            str += '浴室床暖房、';
        }
        if(proCon.IsTvBath__c){
            str += 'TV付浴槽、';
        }
        if(proCon.IsWashletToiletSeat__c){
            str += '温水洗浄便座、';
        }
        if(proCon.IsTanklessToilet__c){
            str += 'タンクレストイレ、';
        }
        if(proCon.IsWashroomDscrete__c){
            str += '洗面所独立、';
        }
        if(proCon.IsShowerWashBasin__c){
            str += 'シャワー付き洗面台、';
        }
        if(proCon.IsShowerRoom__c){
            str += 'シャワールーム、';
        }
        if(proCon.IsMistSauna__c){
            str += 'ミストサウナ、';
        }
        if(proCon.IsIndoorWashingMachineStorage__c){
            str += '室内洗濯機置場、';
        }
        if(str != null){
            str =str.removeEnd('、');
        }
        strList.add(str);

        //光熱設備・空調(5)
        str = '';
        if(proCon.IsCityGas__c){
            str += '都市ガス、';
        }
        if(proCon.IsPropaneGas__c){
            str += 'プロパンガス、';
        }
        if(proCon.IsAllElectric__c){
            str += 'オール電化、';
        }
        if(proCon.IsAirConditioner__c){
            str += 'エアコン、';
        }
        if(proCon.IsFloorHeating__c){
            str += '床暖房、';
        }
        if(proCon.IsGasHeating__c){
            str += 'ガス暖房、';
        }
        if(proCon.IsKeroseneHeating__c){
            str += '灯油暖房、';
        }
        if(str != null){
            str =str.removeEnd('、');
        }
        strList.add(str);

        //家具・家電(6)
        str = '';
        if(proCon.IsFurniture__c){
            str += '家具付き、';
        }
        if(proCon.IsHomeAppliance__c){
            str += '家電付き、';
        }
        if(proCon.IsWashingDryer__c){
            str += '洗濯乾燥機';
        }
        if(str != null){
            str =str.removeEnd('、');
        }
        strList.add(str);

        //室内設備(7)
        str = '';
        if(proCon.IsFlooring__c){
            str += 'フローリング、';
        }
        if(proCon.IsCushionFloor__c){
            str += 'クッションフロア、';
        }
        if(proCon.IsSolidWood__c){
            str += '無垢材使用、';
        }
        if(proCon.IsStormShutter__c){
            str += '雨戸、';
        }
        if(proCon.IsShutter__c){
            str += 'シャッター、';
        }
        if(proCon.IsElectricShutter__c){
            str += '電動シャッター、';
        }
        if(proCon.IsHighSash__c){
            str += 'ハイサッシ、';
        }
        if(proCon.IsSoundproofSash__c){
            str += '防音サッシ、';
        }
        if(proCon.IsPairGlass__c){
            str += '複層ガラス、';
        }
        if(str != null){
            str =str.removeEnd('、');
        }
        strList.add(str);

         //収納(8)
         str = '';
        if(proCon.IsShoesBox__c){
            str += 'シューズボックス、';
        }
        if(proCon.IsShoeCloak__c){
            str += 'シューズクローク、';
        }
        if(proCon.IsWalkInCloset__c){
            str += 'ウォークインクローゼット、';
        }
        if(proCon.IsTrunkRoom__c){
            str += 'トランクルーム、';
        }
        if(proCon.IsUnderfloorStorage__c){
            str += '床下収納、';
        }
        if(str != null){
            str =str.removeEnd('、');
        }
        strList.add(str);

        //通信設備回線(9)
        str = '';
        if(proCon.IsBSAntenna__c){
            str += 'BSアンテナ、';
        }
        if(proCon.IsCSAntenna__c){
            str += 'CSアンテナ、';
        }
        if(proCon.IsCATV__c){
            str += 'CATV、';
        }
        if(proCon.IsCATVInternet__c){
            str += 'CATVインターネット、';
        }
        if(proCon.IsCATVFree__c){
            str += 'CATV使用料不要、';
        }
        if(proCon.IsOpticalFiber__c){
            str += '光ファイバー、';
        }
        if(proCon.IsInternetFree__c){
            str += 'ネット使用料無料、';
        }
        if(str != null){
            str =str.removeEnd('、');
        }
        strList.add(str);

        //セキュリティ(10)
        str = '';
        if(proCon.IsMonitorIntercom__c){
            str += 'モニター付きインターホン、';
        }
        if(proCon.IsAutoLock__c){
            str += 'オートロック、';
        }
        if(proCon.IsDimpleKey__c){
            str += 'ディンプルキー、';
        }
        if(proCon.IsSurveillanceCamera__c){
            str += '防犯カメラ、';
        }
        if(proCon.IsSecurityGlass__c){
            str += '防犯ガラス、';
        }
        if(proCon.IsAnytimeSecurity__c){
            str += '24時間セキュリティ、';
        }
        if(proCon.IsSecurityCompanyJoin__c){
            str += 'セキュリティ会社加入済、';
        }
        if(str != null){
            str =str.removeEnd('、');
        }
        strList.add(str);

        //入居条件支払方法(11)
        str = '';
        if(proCon.IsNoGuarantor__c){
            str += '保証人不要、';
        }
        if(proCon.IsMusicalInstruments__c){
            str += '楽器相談可、';
        }
        if(proCon.IsForeigner__c){
            str += '外国人契約可、';
        }
        if(proCon.IsWelfareAvailable__c){
            str += '生活保護契約可、';
        }
        if(proCon.IsOfficeAvailable__c){
            str += '事務所利用可、';
        }
        if(proCon.IsPet__c){
            str += 'ペット可、';
        }
        if(proCon.IsLargePet__c){
            str += 'ペット(小型犬)、';
        }
        if(proCon.IsMiddlePet__c){
            str += 'ペット(中型犬)、';
        }
        if(proCon.IsSmallPet__c){
            str += 'ペット(大型犬)、';
        }
        if(proCon.IsCat__c){
            str += 'ペット(猫)、';
        }
        if(proCon.IsOtherPet__c){
            str += 'ペット(その他)、';
        }
        if(proCon.IsTwoTenant__c){
            str += '2人入居可、';
        }
        if(proCon.IsRoomShare__c){
            str += 'ルームシェア可、';
        }
        if(proCon.IsMonthly__c){
            str += 'マンスリー可、';
        }
        if(proCon.IsCustomize__c){
            str += 'カスタマイズ可、';
        }
        if(proCon.IsDIY__c){
            str += 'DIY可、';
        }
        if(proCon.IsITImportantDescription__c){
            str += 'IT重説対応物件、';
        }
        if(proCon.IsRentCreditPayment__c){
            str += '家賃カード決済可、';
        }
        if(proCon.IsInitialCostCreditPayment__c){
            str += '初期費用カード決済可、';
        }
        if(proCon.IsWoman__c){
            str += '女性限定、';
        }
        if(proCon.IsStudent__c){
            str += '学生限定、';
        }
        if(proCon.IsCorporation__c){
            str += '法人契約限定';
        }
        if(proCon.IsElderly__c){
            str += '高齢者歓迎、';
        }
        if(proCon.IsLbgt__c){
            str += 'LGBTフレンドリー、';
        }
        if(proCon.IsNotChild__c){
            str += '子供不可、';
        }
        if(str != null){
            str =str.removeEnd('、');
        }
        strList.add(str);

        return strList;
    }
    

    //保証内容設定
    private String assuranceContent(Property__c pro){
        
        //口座振替手数料の表示（値があるなら改行、口座振替手数料を表示）
        String assuranceContentPlus = '';
        if (pro.Guaranteeid__r.DirectDebitFeeTax__c != null && pro.Guaranteeid__r.DirectDebitFeeTax__c != 0 ){
            
            //保証内容がなければ改行コードをプラス
            if (String.isNotBlank(pro.Guaranteeid__r.AssuranceContent__c)) {
            assuranceContentPlus += '<br/>';
            }
            
            assuranceContentPlus += '口座振替手数料　' + commonUtil.decimalToString(pro.Guaranteeid__r.DirectDebitFeeTax__c) + '円';
            //手数料税区分なら（税込）を追加
            if(pro.Guaranteeid__r.DirectDebitFeeTaxType__c == '課税'){
                assuranceContentPlus +=  '（税込）';
            }
        }
        return assuranceContentPlus;
    }
    
    
    //添付ファイル取得
    private void selectAttachmentsInfo(ID targetId,String leftOrRight){
        List<Attachment>  attachmentList =[SELECT Name,//名前
                                    ContentType,//コンテンツタイプ
                                    BodyLength,//本文の長さ
                                    ParentId,
                                    SystemModStamp 
                            FROM Attachment
                            WHERE ParentId = :targetId 
                            ORDER BY CreatedDate];
        if(leftOrRight=='左'){
            if(attachmentList.size() != 0 ){
                for ( Attachment at : attachmentList){
                    this.leftAttachment.add(new screenAttachment(at));
                }
                //Upsert用
                leftAttachmentUpsert = attachmentList;
            }else{
                this.leftAttachment = new List<screenAttachment>();
                //Upsert用
                leftAttachmentUpsert = new List<Attachment>();
            }

        }else if (leftOrRight=='右'){
            if(attachmentList.size() != 0 ){
                for ( Attachment at : attachmentList){
                    this.rightAttachment.add(new screenAttachment(at));
                }
                //Upsert用
                rightAttachmentUpsert = attachmentList;
            }else{
                this.rightAttachment = new List<screenAttachment>();
                //Upsert用
                rightAttachmentUpsert = new List<Attachment>();
            }
        }
    }

    //物件取得、左右レコード振り分け、写真設定、物件条件設定
    private void selectPropertyInfo(String propertyId){
        List<Property__c> propertyList = [
                SELECT id,
                    PropertyCode__c,//物件コード
                    Building__c,//名寄せ更新用
                    MaintenancePropertyCode__c,//メンテナンス物件コード
                    ForeignID__c,//外部ID
                    //元付
                    FormerSupplier__r.Name,//元付業者
                    FormerSupplierPostalCode__c,//郵便番号（元付業者）
                    FormerSupplierAddress__c,//住所（元付業者）
                    FormerSupplierPhone__c,//電話番号（元付業者）
                    FormerSupplierFax__c,//FAX（元付業者）
                    FormerSupplierEmail__c,//メール（元付業者）
                    //基本情報
                    PropertyPhotoCount__c,//物件写真枚数
                    Name,//部屋番号
                    FloorType__c,//地下階区分
                    Floor__c,//所在階
                    RoomCount__c,//部屋数
                    RoomLayout__c,//間取り
                    RoomArea__c,//専有面積
                    BalconyArea__c,//バルコニー面積
                    BalconyDirection__c,//バルコニー方向
                    IsOwnCompanyPropertyFlag__c,//自社物フラグ
                    //引渡情報
                    LiveStatus__c,//現況
                    DeliveryType__c,//引渡種別
                    DeliveryYear__c,//引渡年
                    DeliveryMonth__c,//引渡月
                    DeliveryTiming__c,//引渡旬
                    DeliveryDay__c,//引渡日
                    LivedType__c,//未入居種別              
                    ContractTermYear__c,//契約期間（年）
                    ContractTermMonth__c,//契約期間（月）
                    TransactionAspect__c,//取引態様
                    DeliveryConsultation__c,//引渡・入居（相談内容）
                    RentType__c,//定期借家区分
                    RentTermYear__c,//定借期間（年）
                    RentTermMonth__c,//定借期間（月）
                    RentTermDay__c,//定借期間（日）
                    //リノベ・フリーレント・特定優良賃貸住宅
                    RenovationComplateYear__c,//リノベ成功完了（年）
                    RenovationComplateMonth__c,//リノベ成功完了（月）
                    RenovationContent__c,//リノベ施工内容
                    FreeRentTermMonth__c,//フリーレント期間(ヵ月)
                    FreeRentContent__c,//フリーレント内容
                    SpecificExcellentRentBurdenUpperLimit__c,//特優賃入居負担額上限
                    SpecificExcellentRentBurdenLowerLimit__c,//特優賃入居負担額下限
                    SpecificExcellentRentFeeFluctuationType__c,//特優賃料金変動区分
                    SpecificExcellentRentFeeUpwardRate__c,//特優賃上昇率
                    SpecificExcellentRentSupportYears__c,//特優賃家賃補助年数
                    SpecificExcellentRentRemarks__c,//特優賃備考
                    //物件備考
                    PropertyRemarksPublic__c,//物件備考（公開）
                    PropertyRemarksPrivate__c,//物件備考（非公開）                  
                    //賃料等
                    RentFee__c,//賃料
                    ManagementFee__c,
                    ManagementFeeTax__c,//管理費（税込）
                    ManagementFeeTaxType__c,//管理費税区分
                    WortFee__c,
                    WortFeeTax__c,//水道料金（税込）
                    WortFeeTaxType__c,//水道料金税区分  
                    CATVFee__c,                
                    CATVFeeTax__c,//CATV（税込）
                    CATVTaxType__c,//CATV税区分
                    TownshipFeeTax__c,//町会費（税込）
                    TownshipFee__c,
                    TownshipFeeTaxType__c,//町会費税区分
                    TownshipFeePaymentType__c,//町会費支払区分  
                    GarbageDisposalFee__c,
                    GarbageDisposalFeeTax__c,//ゴミ処理費（税込）
                    GarbageDisposalFeeTaxType__c,//ゴミ処理費税区分
                    GarbageDisposalFeePaymentType__c,//ゴミ処理費支払区分
                    SecurityDepositYen__c,//敷金（円）
                    SecurityDepositMonth__c,//敷金（ヵ月）
                    SecurityDepositUnit__c,//敷金単位
                    DepositYen__c,//保証料金（円）
                    DepositMonth__c,//保証料金（ヵ月）
                    DepositUnit__c,//保証金単位
                    KeyMoneyYen__c,//礼金（円）
                    KeyMoneyMonth__c,//礼金（ヵ月）
                    KeyMoneyUnit__c,//礼金単位
                    CleaningFeeYen__c,
                    CleaningFeeTax__c,//定額修繕費（税込）
                    CleaningFeeMonth__c,//定額修繕費（ヵ月）
                    CleaningFeeUnit__c,//定額修繕費単位
                    CleaningFeeTaxType__c,//定額修繕費税区分
                    CleaningFeePaymentType__c,//定額修繕費支払区分
                    TownshipInitialFee__c,
                    TownshipInitialFeeTax__c,//入町費（税込）
                    TownshipInitialFeeTaxType__c,//入町費税区分
                    KeyExchangeFeeTax__c,//鍵交換費（税込）
                    KeyExchangeFee__c,
                    KeyExchangeFeeTaxType__c,//鍵交換費税区分
                    RenewalFeeYen__c,
                    RenewalFee__c,//更新料（税込）
                    RenewalFeeMonth__c,//更新料（ヵ月）
                    RenewalFeeUnit__c,//更新料単位
                    RenewalFeeTaxType__c,//更新料税区分
                    BicycleParkingFee__c,
                    BicycleParkingFeeTax__c,//駐輪場代（税込）
                    BicycleParkingFeeTaxType__c,//駐輪場代税区分
                    CancellationActualFeeYen__c,//敷引・償却（円）
                    CancellationActualFeeMonth__c,//敷引・償却（ヵ月）
                    CancellationActualFeeRate__c,//敷引・償却（％）
                    CancellationActualFeeUnit__c,//敷引・償却単位
                    IsShortTermPenalty__c,//短期解約違約金有無
                    ShortTermPenaltyLessYear__c,//短期解約違約金未満（年）
                    ShortTermPenaltyFee__c,//短期解約違約金
                    //駐車場
                    ParkingType__c,//駐車場種別
                    ParkingFee__c,
                    ParkingFeeTax__c,//駐車場料金（税込）
                    ParkingFeeTaxType__c,//駐車場料金税区分
                    ParkingDistance__c,//近隣駐車場までの距離
                    ParkingDepositYen__c,
                    ParkingDepositTax__c,//駐車場保証料金（税込）
                    ParkingDepositUnit__c,//駐車場保証料金単位区分
                    ParkingCompoundingFeeYen__c,
                    ParkingCompoundingFeeTax__c,//駐車場手数料（税込）
                    ParkingCompoundingFeeMonth__c,//駐車場手数料（ヵ月）
                    ParkingCompoundingFeeUnit__c,//駐車場手数料単位
                    ParkingRemarksPublic__c,//駐車場備考（公開）
                    ParkingRemarksPrivate__c,//駐車場備考（非公開）
                    BikeParkingSmallFee__c,
                    BikeParkingSmallFeeTax__c,//小型バイク置場料金（税込）
                    BikeParkingSmallFeeTaxType__c,//小型バイク置場料金税区分
                    BikeParkingMediumFee__c,
                    BikeParkingMediumFeeTax__c,//中型バイク置場料金（税込）
                    BikeParkingMediumFeeTaxType__c,//中型バイク置場料金税区分
                    BikeParkinLargeFee__c,
                    BikeParkinLargeFeeTax__c,//大型バイク置場料金（税込）
                    BikeParkinLargeFeeTaxType__c,//大型バイク置場料金税区分
                    MonetaryPublic__c,//金銭備考（公開）
                    MonetaryPrivate__c,//金銭備考（非公開）
                    //火災
                    FireInsuranceUseType__c,//火災保険（加入義務）
                    FireInsurancePlan__r.Account__r.Name,//火災保険会社名
                    FireInsurancePlan__r.ItemName__c,//火災保証タイトル
                    FireInsurancePlan__r.FireInsuranceMonth__c,//火災保険料（月額）
                    FireInsurancePlan__r.FireInsuranceYear__c,//火災保険料（年額）
                    //保証
                    GuaranteeidCompanyType__c,//保証会社（利用区分）
                    Guaranteeid__r.Account__r.Name,//保証会社
                    Guaranteeid__r.ItemName__c,//保証タイトル
                    Guaranteeid__r.AssuranceContent__c,//詳細
                    Guaranteeid__r.DirectDebitFeeTaxType__c,//手数料税区分
                    Guaranteeid__r.DirectDebitFeeTax__c,//保証料
                    //報酬・鍵所在
                    ADFeeYen__c,
                    ADFeeTax__c,//広告料（税込）
                    ADFeeUnit__c,//広告料単位
                    ADFeeTaxType__c,//広告料税区分
                    ADFeeComment__c,//広告料コメント
                    RewardType__c,//報酬形態
                    RewardBurdenLender__c,//報酬負担貸主
                    RewardBurdenBorrower__c,//報酬負担借主
                    RewardSplitFormerSupplier__c,//報酬負担元付
                    RewardSplitCustomer__c,//報酬負担客付
                    KeyPlace__c,//鍵所在
                    //写真
                    AthomePanoramaContentsId__c,//at homeパノラマコンテンツID
                    SuumoPanoramaShop__r.Name,//SUUMOパノラマ掲載店舗
                    HomesPanoramaShop__r.Name,//HOME'Sパノラマ掲載店舗
                    AtHomePanoramaShop__r.Name,//at homeパノラマ掲載店舗
                    SuumoPanoramaShop__c,//SUUMOパノラマ掲載店舗
                    HomesPanoramaShop__c,//HOME'Sパノラマ掲載店舗
                    AtHomePanoramaShop__c,//at homeパノラマ掲載店舗
                    //貸主・所有者
                    Creditor__r.Name,//貸主
                    CreditorPostalCode__c,//郵便番号
                    CreditorAddress__c,//住所
                    CreditorPhone__c,//電話番号
                    CreditorFax__c,//FAX
                    CreditorEmail__c,//メール
                    Owner__r.Name,//所有者
                    OwnerPhone__c,//所有者電話番号
                    OwnerFax__c,//所有者FAX
                    OwnerPostalCode__c,//所有者郵便番号
                    OwnerAddress__c,//所有者住所
                    OwnerEmail__c,//メール
                    //公開・ポータルサイト掲載
                    WebPublishing__c,//Web公開
                    IsPropertyNameHiddenFlag__c,//物件名非表示フラグ
                    ImportType__c,//取込区分
                    PropertyDetailUrl__c,//物件詳細画面URL
                    HomesPropertyFeature__r.ExampleSentence__c,//HOME'S物件の特徴
                    HomesRemarks__c,//HOME'S備考
                    SuumoNetCatch__r.ExampleSentence__c,//SUUMOネット用キャッチ
                    SuumoNetCatchComment__r.ExampleSentence__c,//SUUMOネット用キャッチコメント
                    SuumoRemarks__c,//SUUMO備考
                    AthomeRecommendComment__r.ExampleSentence__c,//at homeおすすめコメント
                    AthomeRecommendCommentStaffId__c,//at homeおすすめコメントスタッフID
                    AtHomeRemarks__c,//at home備考
					ChintaiMagazineComment__r.ExampleSentence__c, // CHINTAI雑誌コメント 2022.04.05 CHINTAI対応追加
                    //物件条件
                    (SELECT Id,
                            IsRenovation__c,//リノベーション（リノベセクション用）
                            IsFreeRent__c,//フリーレント（リノベセクション用）
                            IsSpecialRent__c,//特定優良賃貸住宅（リノベセクション用）
                            IsPluralCarParking__c,//駐車場2台可（駐車場・バイク置き場用）
                            //立地・環境
                            IsQuietResidenceTown__c,//閑静な住宅街
                            //構造・工法
                            IsTowerMansion__c,//タワーマンション
                            IsDesigners__c,//デザイナーズ
                            IsBarrierFree__c,//バリアフリー
                            IsOuterWallTile__c,//外壁タイル張り
                            IsCondominiumRental__c,//分譲賃貸
                            IsDampingStructure__c,//制震構造
                            IsSeismicStructure__c,//耐震構造
                            IsSeismicIsolationStructure__c,//免震構造
                            //共用部
                            IsElevator__c,//エレベーター
                            IsPluralElevators__c,//エレベーター2基
                            IsFrontService__c,//フロントサービス
                            IsDeliveryBox__c,//宅配ボックス
                            IsCleaningBox__c,//クリーニングボックス
                            IsCoinLaundry__c,//コインランドリー
                            IsAnytimeTtrashArea__c,//24時間ゴミ出し可
                            IsInSiteTtrashArea__c,//敷地内ゴミ置場
                            IsSepticTank__c,//浄化槽
                            //陽当り・採光
                            IsCornerRoom__c,//角部屋
                            IsBayWindow__c,//出窓
                            //庭
                            IsPrivateGarden__c,//専用庭
                            //管理・防犯
                            IsAutoLock__c,//オートロック
                            IsAnytimeSecurity__c,//24時間セキュリティ
                            IsSecurityCompanyJoin__c,//セキュリティ会社加入済
                            IsDimpleKey__c,//ディンプルキー
                            IsSurveillanceCamera__c,//防犯カメラ
                            IsSecurityGlass__c,//防犯ガラス
                            //間取り
                            IsMaisonette__c,//メゾネット
                            IsLoft__c,//ロフト
                            IsUndergroundRoom__c,//地下室
                            IsSoundproofRoom__c,//防音室
                            //キッチン
                            IsGasStove__c,//ガスコンロ
                            IsTwoGasStove__c,//コンロ2口
                            IsMoreGasStove__c,//コンロ3口以上
                            IsIhStove__c,//IHコンロ
                            IsElectricStove__c,//電気コンロ
                            IsCounterKitchen__c,//カウンターキッチン
                            IsSystemKitchen__c,//システムキッチン
                            IsWaterPurifier__c,//浄水器
                            IsDishwasher__c,//食器洗い乾燥機
                            IsDisposer__c,//ディスポーザー
                            IsCityGas__c,//都市ガス
                            IsPropaneGas__c,//プロパンガス
                            //浴室
                            IsSeparate__c,//バス・トイレ別
                            IsShowerRoom__c,//シャワールーム
                            IsMistSauna__c,//ミストサウナ
                            IsTvBath__c,//TV付浴槽
                            IsReheating__c,//追焚機能
                            IsHotWaterFormula__c,//高温差湯式
                            IsBathroomDryer__c,//浴室乾燥機
                            IsBathroomFloorHeating__c,//浴室床暖房
                            //トイレ
                            IsWashletToiletSeat__c,//温水洗浄便座
                            IsTanklessToilet__c,//タンクレストイレ
                            //洗面所
                            IsShowerWashBasin__c,//シャワー付き洗面台
                            IsWashroomDscrete__c,//洗面所独立
                            //冷暖房・空調
                            IsFloorHeating__c,//床暖房
                            IsGasHeating__c,//ガス暖房
                            IsKeroseneHeating__c,//灯油暖房
                            //光熱設備
                            IsAllElectric__c,//オール電化
                            //家具・家電
                            IsAirConditioner__c,//エアコン
                            IsFurniture__c,//家具付き
                            IsHomeAppliance__c,//家電付き
                            IsWashingDryer__c,//洗濯乾燥機
                            //バルコニー・テラス
                            IsBalcony__c,//バルコニー
                            IsRoofBalcony__c,//ルーフバルコニー
                            IsWoodDeck__c,//ウッドデッキ
                            //室内設備
                            IsFlooring__c,//フローリング
                            IsCushionFloor__c,//クッションフロア
                            IsStormShutter__c,//雨戸
                            IsShutter__c,//シャッター
                            IsElectricShutter__c,//電動シャッター
                            IsHighSash__c,//ハイサッシ
                            IsSoundproofSash__c,//防音サッシ
                            IsPairGlass__c,//複層ガラス
                            IsSolidWood__c,//無垢材使用
                            IsIndoorWashingMachineStorage__c,//室内洗濯機置場
                            //収納
                            IsWalkInCloset__c,//ウォークインクローゼット
                            IsShoesBox__c,//シューズボックス
                            IsTrunkRoom__c,//トランクルーム
                            IsUnderfloorStorage__c,//床下収納
                            //情報設備・回線
                            IsBSAntenna__c,//BSアンテナ
                            IsCSAntenna__c,//CSアンテナ
                            IsCATV__c,//CATV
                            IsCATVInternet__c,//CATVインターネット
                            IsCATVFree__c,//CATV使用料不要
                            IsOpticalFiber__c,//光ファイバー
                            IsInternetFree__c,//ネット使用料無料
                            //セキュリティ
                            IsMonitorIntercom__c,//モニター付きインターホン
                            //費用・入居・引渡・条件
                            IsRentCreditPayment__c,//家賃カード決済可
                            IsInitialCostCreditPayment__c,//初期費用カード決済可
                            IsITImportantDescription__c,//IT重説対応物件
                            IsNoGuarantor__c,//保証人不要
                            IsCustomize__c,//カスタマイズ可
                            IsDIY__c,//DIY可
                            IsMusicalInstruments__c,//楽器相談可
                            IsPet__c,//ペット可
                            IsTwoTenant__c,//2人入居可
                            IsWoman__c,//女性限定
                            IsLbgt__c,//LGBTフレンドリー
                            IsElderly__c,//高齢者歓迎
                            IsRoomShare__c,//ルームシェア可
                            IsMonthly__c,//マンスリー可
                            IsOfficeAvailable__c,//事務所利用可
                            //費用・入居・引渡・条件
                            IsForeigner__c,//外国人契約可
                            IsStudent__c,//学生限定
                            IsNotChild__c,//子供不可
                            IsWelfareAvailable__c,//生活保護契約可
                            IsCorporation__c,//法人契約限定
                            //階・フロア
                            IsFirstFloor__c,//1階
                            IsSecondFloorOver__c,//2階以上
                            IsTopFloor__c,//最上階
                            //費用・入居・引渡・条件
                            IsLargePet__c,//ペット(大型犬)
                            IsMiddlePet__c,//ペット(中型犬)
                            IsSmallPet__c,//ペット(小型犬)
                            IsCat__c,//ペット(猫)
                            IsOtherPet__c,//ペット(その他)
                            PetRemarks__c,//ペット(その他)備考
                            IsAllWesternStyleRoom__c,//オール洋間
                            IsCarport__c,//カーポート
                            IsBuiltInGarage__c,//ビルトインガレージ
                            IsShoeCloak__c//シューズクローク
                    FROM PropertyConditionsProperty__r),
                    //間取り図ファイルパス(物件写真)
                    (SELECT id, RoomLayoutFilePath__c FROM PropertyPhotoProperty__r LIMIT 1),
                   CreatedDate,
                   SystemModstamp  
        FROM Property__c 
        WHERE Id = :propertyId];
        //レコード情報が取得できなければビジネスロジックException発行
        if( propertyList.size()==0 ){
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
            throw ex;
        }

        //★取得1回目の場合、ExchangeListに入れる
        if (ExchangeRecord == null){
            ExchangeRecord = propertyList[0].clone(true,false,true,true);

        //★取得2回目の場合、どちらが古いかを比較し、左右のレコードに振り分けと、物件写真リストを取得。
        }else{
            //1回目のレコードが2回目より古い場合、1回目が左、2回目が右のレコードに入る
            if(ExchangeRecord.CreatedDate < propertyList[0].CreatedDate){
                leftProperty = ExchangeRecord.clone(true,false,true,true );
                rightProperty = propertyList[0].clone(true,false,true,true );
                
            //2回目のレコードが1回目より古い場合、2回目が左、1回目が右のレコードに入る
            }else{
                leftProperty = propertyList[0].clone(true,false,true,true );
                rightProperty = ExchangeRecord.clone(true,false,true,true );
            }
            
            //★物件条件設定
            if(leftProperty.PropertyConditionsProperty__r.size()!=0){
                leftConditions = leftProperty.PropertyConditionsProperty__r[0];
            }
            if(rightProperty.PropertyConditionsProperty__r.size()!=0){
                rightConditions = rightProperty.PropertyConditionsProperty__r[0];
            }
            //★物件写真リストの取得
            leftPhoto = new ScreenAnyPhotoData(SettingPhotoInfo(leftProperty.id,'左'));//左の写真
            rightPhoto = new ScreenAnyPhotoData(SettingPhotoInfo(rightProperty.id,'右'));//右の写真
            //写真枚数多い方と同じ枚数にする
            matchPhotoCount(leftPhoto.photoCount ,rightPhoto.photoCount ,PHOTO_TYPE_PUBLIC);//物件写真
            matchPhotoCount(leftPhoto.panoramaCount ,rightPhoto.panoramaCount ,PHOTO_TYPE_PANORAMA);//パノラマ写真
            matchPhotoCount(leftPhoto.privateCount ,rightPhoto.privateCount ,PHOTO_TYPE_PRIVATE);//非公開写真
            //★間取り図
            if (leftProperty.PropertyPhotoProperty__r.size()!=0){
                //▼問合せNo0487で変更
                leftRoomLayout = CommonUtil.getCacheAvoidancePath(leftProperty.PropertyPhotoProperty__r[0].RoomLayoutFilePath__c);
                //▲問合せNo0487で変更
            }else{
                leftRoomLayout = '';
            }
            if (rightProperty.PropertyPhotoProperty__r.size()!=0){
                //▼問合せNo0487で変更
                rightRoomLayout = CommonUtil.getCacheAvoidancePath(rightProperty.PropertyPhotoProperty__r[0].RoomLayoutFilePath__c);
                //▲問合せNo0487で変更
            }else{
                rightRoomLayout = '';
            }

        }
    }
    //部屋取得
    private List<Room__c> selectRoomInfo(Id targetId){
        List<Room__c> roomList =[SELECT Id,
                                        RoomFloorSpace__c,//部屋帖数
                                        RoomType__c//部屋タイプ
                                        FROM Room__c
                                        WHERE Property__c = :targetId];
        if (roomList.size() == 0 ){
            roomList =new List<Room__c>();
        }
        return roomList;
    }

    //物件管理会社指定取得
    private List<PropertyManageCompayItem__c> selectPMCIInfo(Id targetId){
        List<PropertyManageCompayItem__c> PMCIList = [SELECT Id,
                    Item__r.ItemName__c,//管理会社指定.商品名
                    Item__r.AmountTax__c,//管理会社指定.金額
                    Item__r.PaymentType__c//管理会社指定.支払区分
            FROM PropertyManageCompayItem__c
            WHERE Property__c = :targetId];
        if (PMCIList.size() == 0 ){
            PMCIList =new List<PropertyManageCompayItem__c>();
        }
        return PMCIList;
    }

    //写真枚数多い方と同じ枚数にする(左物件の写真枚数、右の写真枚数、普通の写真かパノラマ写真か非公開写真)
    private void matchPhotoCount(Integer left,Integer right,String photoType){
        //左>右
        if(left > right){         
            for(Integer i=0 ;i < left - right ;i++){
                if(photoType.equals(PHOTO_TYPE_PUBLIC)){
                    rightPhoto.photoDataList.add(new PhotoData());
                    rightPhoto.PhotoCount = left;                   
                }else if(photoType.equals(PHOTO_TYPE_PANORAMA)){
                    rightPhoto.panoramaDataList.add(new PhotoData());
                    rightPhoto.panoramaCount = left;  
                }else if(photoType.equals(PHOTO_TYPE_PRIVATE)){
                    rightPhoto.privateDataList.add(new PhotoData());
                    rightPhoto.privateCount = left; 
                }
                
            }
        //右>左
        }else if(right > left){
            for(Integer i=0 ;i < right - left ;i++){
                if(photoType.equals(PHOTO_TYPE_PUBLIC)){
                    leftPhoto.photoDataList.add(new PhotoData());
                    leftPhoto.PhotoCount = right;                   
                }else if(photoType.equals(PHOTO_TYPE_PANORAMA)){
                    leftPhoto.panoramaDataList.add(new PhotoData());
                    leftPhoto.panoramaCount = right;  
                }else if(photoType.equals(PHOTO_TYPE_PRIVATE)){
                    leftPhoto.privateDataList.add(new PhotoData());
                    leftPhoto.privateCount = right; 
                }
                
            }
        }
    }


    //物件写真取得
    private PropertyPhoto__c SettingPhotoInfo(String targetId,String leftOrRright){
        String sql = '';
        sql += 'SELECT Id ';
        for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PROPERTY; i++) { // 物件写真
            sql += '      ,PropertyPhotoFileName' + i + '__c ';//ファイル名：写真有無判定に使う
            sql += '      ,PropertyPhotoFilePath' + i + '__c ';//パス：表示につかう
            sql += '      ,PropertyPhotoTag' + i + '__c ';
            sql += '      ,PropertyPhotoComment' + i + '__c ';
        }
        for(Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PANORAMA; i++){//パノラマ写真
            sql += '      ,PanoramaFileName' + i + '__c ';
            sql += '      ,PanoramaFilePath' + i + '__c ';
            sql += '      ,PanoramaTag' + i + '__c ';
            sql += '      ,PanoramaComment' + i + '__c ';
        }
        for(Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PRIVATE; i++){//非公開写真
            sql += '      ,PrivatePhotoFileName' + i + '__c ';
            sql += '      ,PrivatePhotoFilePath' + i + '__c ';
            sql += '      ,PrivatePhotoType' + i + '__c ';
            sql += '      ,PrivatePhotoComment' + i + '__c ';
        }
        sql += '      ,RoomLayoutFileName__c ';                     // 物件間取り図
        sql += '      ,RoomLayoutMemoFileName__c ';                 // 物件間取り図（メモ有）
        sql += '      ,Property__r.ForeignID__c ';
        sql += '      ,Property__r.Building__r.ForeignID__c ';
        sql += '      ,ForeignID__c';
        sql += '      ,RoomLayoutFilePath__c';
        sql += '      ,RoomLayoutMemoFilePath__c';
        sql += '      ,Property__c';
        sql += ' FROM PropertyPhoto__c ';
        sql += ' WHERE Property__c   = :targetId ';

        List<PropertyPhoto__c> propertyPhoto = Database.query(sql);         

        if (propertyPhoto.isEmpty()){
            propertyPhoto = new List<PropertyPhoto__c>();
            if(leftOrRright == '左') {
                leftPhotoUpsert = new PropertyPhoto__c(Property__c = targetId);
            } else {
                rightPhotoUpsert = new PropertyPhoto__c(Property__c = targetId);
            }
            return new PropertyPhoto__c();
        }

        //登録用のレコードに入れておく
        if(leftOrRright == '左'){
            leftPhotoUpsert = propertyPhoto[0];
        }else{
            rightPhotoUpsert = propertyPhoto[0];

        }
        return propertyPhoto[0];

    }

    // 名寄せによる削除側でセットされている物件を残る側の物件に置き換える。
    private void updatePropertyId(Id delCorrespondId,Id mergeCorrespondId, String delProCode, String mergeProCode, Boolean pictureMoveFlg){

        updateAutoMaintenance(delCorrespondId,mergeCorrespondId);       // 削除側の自動メンテナンスレコードを残る側のidに更新
        updateCorrespondProperty(delCorrespondId,mergeCorrespondId);    // 削除側の物件Id、初回問合せ物件がセットされている対応を抜き出し残る側の物件Id、初回問合せ物件に更新する。
        updateFavoritePropertyId(delCorrespondId,mergeCorrespondId);    // 削除側の物件Idがセットされているお気に入り物件を抜き出し残る側の物件Idに更新する。
        updateProvisionalQuote(delCorrespondId,mergeCorrespondId);      // 削除側の物件Idがセットされている仮見積を抜き出し残る側の物件Idに更新する。
        updateApplication(delCorrespondId,mergeCorrespondId);           // 削除側の物件Idがセットされている申込を抜き出し残る側の物件Idに更新する。
        updateEchoMail(delCorrespondId,mergeCorrespondId);              // 削除側の物件Idがセットされている反響メールを抜き出し残る側の物件Idに更新する。
        //ポータルサイト構築　追加　start
        updateRecommendProperty(delProCode, mergeProCode,mergeCorrespondId, pictureMoveFlg);    // 削除側の物件Idがセットされているおすすめ物件を抜き出し残る側の物件Idに更新する。
        //ポータルサイト構築　追加　End
        deleteExactCondMatchProp(delCorrespondId);                      // 削除される物件を持つ条件完全一致物件を削除
        mergePropertyCdHist(mergeCorrespondId, delCorrespondId);        // 物件コード履歴の名寄せ
    }

    //削除側の自動メンテナンスレコードを残る側のidに更新
    private void updateAutoMaintenance(Id delCorrespondId,Id mergeCorrespondId){
        List<AutoMaintenance__c> changeAutoMaintenanceList =[SELECT id FROM AutoMaintenance__c WHERE Property__c = :delCorrespondId];

        // 削除側の物件が設定されていなければ処理を抜ける。
        if (changeAutoMaintenanceList.isEmpty()){
            return;
        }

        // 物件Idを更新する。
        for (AutoMaintenance__c changeAutoMaintenance :changeAutoMaintenanceList){
            changeAutoMaintenance.Property__c = mergeCorrespondId;
        }
        SecureDML.secureUpdate(changeAutoMaintenanceList);
    }

    // 削除側の物件Id、初回問合せ物件がセットされている対応を抜き出し残る側の物件Id、初回問合せ物件に更新する。
    private void updateCorrespondProperty(Id delCorrespondId,Id mergeCorrespondId){
        List<Correspond__c> changeCorrespondList =[SELECT id,Property__c,FirstInquiryProperty__c FROM Correspond__c WHERE Property__c = :delCorrespondId OR FirstInquiryProperty__c = :delCorrespondId];

        // 削除側の物件、初回問合せ物件が設定されていなければ処理を抜ける。
        if (changeCorrespondList.isEmpty()){
            return;
        }

        // 物件Id、初回問合せ物件を更新する。
        for (Correspond__c changeCorrespond :changeCorrespondList){
            // 物件IDが一致している場合
            if(changeCorrespond.Property__c == delCorrespondId){
                // 物件IDを更新する。
                changeCorrespond.Property__c = mergeCorrespondId;
            }
            
            // 初回問合せ物件が一致している場合
            if(changeCorrespond.FirstInquiryProperty__c == delCorrespondId){
                // 初回問合せ物件を更新する。
                changeCorrespond.FirstInquiryProperty__c = mergeCorrespondId;
            }
        }
        SecureDML.secureUpdate(changeCorrespondList);
    }

    // 削除側の物件Idがセットされているお気に入り物件を抜き出し残る側の物件Idに更新する。
    private void updateFavoritePropertyId(Id delCorrespondId,Id mergeCorrespondId){
        List<FavoriteProperty__c> changeFavoritePropertyList =[SELECT id,Property__c FROM FavoriteProperty__c WHERE Property__c = :delCorrespondId];

        // 削除側の物件が設定されていなければ処理を抜ける。
        if (changeFavoritePropertyList.isEmpty()){
            return;
        }

        // 物件Idを更新する。
        for (FavoriteProperty__c changeFavoriteProperty :changeFavoritePropertyList){
            changeFavoriteProperty.Property__c = mergeCorrespondId;
        }
        SecureDML.secureUpdate(changeFavoritePropertyList);
    }

    /**
     * 削除される物件を持つ条件完全一致物件を削除
     * @param Id delPropId  削除用物件ID
     */
    private void deleteExactCondMatchProp(Id delPropId) {

        List<ExactConditionMatchProperty__c> delExactCondMatchPropList =
                        [SELECT id
                         FROM ExactConditionMatchProperty__c
                         WHERE Property__c = :delPropId];

        // 対象レコードを削除
        SecureDML.secureDelete(delExactCondMatchPropList);
    }

    // 削除側の物件Idがセットされている仮見積を抜き出し残る側の物件Idに更新する。
    private void updateProvisionalQuote(Id delCorrespondId,Id mergeCorrespondId){
        List<ProvisionalQuote__c> changeProvisionalQuoteList =[SELECT id,Property__c FROM ProvisionalQuote__c WHERE Property__c = :delCorrespondId];

        // 削除側の物件が設定されていなければ処理を抜ける。
        if (changeProvisionalQuoteList.isEmpty()){
            return;
        }

        // 物件Idを更新する。
        for (ProvisionalQuote__c changeProvisionalQuote :changeProvisionalQuoteList){
            changeProvisionalQuote.Property__c = mergeCorrespondId;
        }
        SecureDML.secureUpdate(changeProvisionalQuoteList);
    }

    //ポータルサイト構築 追加 Start
    //ポータル権限がある場合、削除側の物件Idがセットされているおすすめ物件を抜き出し残る側の物件Idに更新して物件名寄せ差分を作成する。
    private void updateRecommendProperty(String delProCode,String mergeProCode,Id mergeCorrespondId, Boolean pictureMoveFlg){
        
        if(isOpetionPortal){            //ポータル権限がある場合
            List<RecommendProperty__c> deleteRecommendPropertyList =[SELECT Id, Property__c,PanoramaTourUrl__c,PhotoFileName__c,PhotoFilePath__c FROM RecommendProperty__c WHERE PropertyCode__c = :delProCode Limit 1];
            List<RecommendProperty__c> mergeRecommendPropertyList  =[SELECT Id, PhotoFileName__c, PanoramaTourUrl__c FROM RecommendProperty__c WHERE PropertyCode__c = :mergeProCode Limit 1];

            // マージ元におすすめ物件があり、マージ先におすすめ物件が無い場合、マージ元の情報をマージ先の情報に置き換える
            if(!deleteRecommendPropertyList.isEmpty() && mergeRecommendPropertyList.isEmpty()){
                deleteRecommendPropertyList[0].Property__c = mergeCorrespondId;
                deleteRecommendPropertyList[0].PropertyCode__c = mergeProCode;

                // マージ元の写真ファイルが建物以外のものであれば、おすすめ物件を削除しメッセージを出力
                if(!checkPhotoFileName(deleteRecommendPropertyList[0].PhotoFileName__c)){
                    this.deleteRecommendPropertyURL.add(deleteRecommendPropertyList[0].PanoramaTourUrl__c);    // APIにて非公開を行う判断のためにURLをセット
                    SecureDML.secureDelete(deleteRecommendPropertyList);
                    IsDeleteRecommendPropertyMessageFlg = true;       
                } else {
                    SecureDML.secureUpdate(deleteRecommendPropertyList);
                }
            }

            // マージ先のおすすめ物件があり、マージ元のおすすめ物件がある場合、
            if(!mergeRecommendPropertyList.isEmpty() && !deleteRecommendPropertyList.isEmpty()){
                Boolean recommendPropertyMoveFlg = false;
                // 選択した基本情報と画像が異なる場合かつマージ先写真ファイルが建物以外のもの
                if(pictureMoveFlg && !checkPhotoFileName(mergeRecommendPropertyList[0].PhotoFileName__c)) {
                    if(checkPhotoFileName(deleteRecommendPropertyList[0].PhotoFileName__c)) {
                        // マージ元の情報をマージ先の情報に置き換える
                        deleteRecommendPropertyList[0].Property__c = mergeCorrespondId;
                        deleteRecommendPropertyList[0].PropertyCode__c = mergeProCode;
                        SecureDML.secureUpdate(deleteRecommendPropertyList);
                        recommendPropertyMoveFlg = true;
                    } else {
                        // データの置き換えを行わない場合、おすすめ物件削除メッセージ出力
                        IsDeleteRecommendPropertyMessageFlg = true;
                    }
                    // マージ先おすすめ物件を削除
                    this.deleteRecommendPropertyURL.add(mergeRecommendPropertyList[0].PanoramaTourUrl__c);    // APIにて非公開を行う判断のためにURLをセット
                    SecureDML.secureDelete(mergeRecommendPropertyList);
                }
                if(!recommendPropertyMoveFlg) {
                    // マージ元のおすすめ物件を削除する。
                    this.deleteRecommendPropertyURL.add(deleteRecommendPropertyList[0].PanoramaTourUrl__c);    // APIにて非公開を行う判断のためにURLをセット
                    SecureDML.secureDelete(deleteRecommendPropertyList);
                }
            }

            // マージ先におすすめ物件があり、マージ元におすすめ物件がない場合
            if(!mergeRecommendPropertyList.isEmpty() && deleteRecommendPropertyList.isEmpty()){
                // 選択した基本情報と画像が異なる場合かつマージ先写真ファイルが建物以外のものであれば、マージ先おすすめ物件を削除しメッセージを出力
                if(pictureMoveFlg && !checkPhotoFileName(mergeRecommendPropertyList[0].PhotoFileName__c)) {
                    this.deleteRecommendPropertyURL.add(mergeRecommendPropertyList[0].PanoramaTourUrl__c);    // APIにて非公開を行う判断のためにURLをセット
                    SecureDML.secureDelete(mergeRecommendPropertyList);
                    IsDeleteRecommendPropertyMessageFlg = true;   
                }
            }

            //ここから物件名寄せ差分作成
            PropertyNameIdentificationDifference__c pNIDiff = new PropertyNameIdentificationDifference__c(
                PropertyCdOld__c = delProCode
                ,PropertyCdNew__c = mergeProCode
            );
            SecureDML.secureInsert(pNIDiff);

        }
    }

    // おすすめ物件写真ファイルの設定判定(True:セットする、False:セットしない)
    private Boolean checkPhotoFileName(String fileName){

        // 写真ファイルなし
        if(String.isEmpty(fileName)){
            return false;
        }

        // 公開写真（物件）
        if(fileName.Contains(CommonConst.S3_PROPERTYPHOTOTYPE_PROPERTPHOTO)){
            return false;
        }

        // 建物（外観）
        if(fileName.Contains(CommonConst.S3_BUILDINGPHOTOTYPE_APPEARANCE)){
            return true;
        }
            
        // 建物（エントランス）
        if(fileName.Contains(CommonConst.S3_BUILDINGPHOTOTYPE_ENTRANCE)){
            return true;
        }

        // 建物（ロビー）
        if(fileName.Contains(CommonConst.S3_BUILDINGPHOTOTYPE_LOBBY)){
            return true;
        }

        // 上記以外
        return false;
    }
    //ポータルサイト構築 追加 End

    // 削除側の物件Idがセットされている申込を抜き出し残る側の物件Idに更新する。
    private void updateApplication(Id delCorrespondId,Id mergeCorrespondId){
        List<Application__c> changeApplicationList =[SELECT id,Property__c FROM Application__c WHERE Property__c = :delCorrespondId];

        // 削除側の物件が設定されていなければ処理を抜ける。
        if (changeApplicationList.isEmpty()){
            return;
        }

        // 物件Idを更新する。
        for (Application__c changeApplication :changeApplicationList){
            changeApplication.Property__c = mergeCorrespondId;
        }
        SecureDML.secureUpdate(changeApplicationList);
    }

    // 削除側の物件Idがセットされている反響メールを抜き出し残る側の物件Idに更新する。
    private void updateEchoMail(Id delCorrespondId,Id mergeCorrespondId){
        List<EchoMail__c> changeEchoMailList =[SELECT id,Response__c FROM EchoMail__c WHERE Response__c = :delCorrespondId];

        // 削除側の物件が設定されていなければ処理を抜ける。
        if (changeEchoMailList.isEmpty()){
            return;
        }

        // 物件Idを更新する。
        for (EchoMail__c changeEchoMail :changeEchoMailList){
            changeEchoMail.Response__c = mergeCorrespondId;
        }
        SecureDML.secureUpdate(changeEchoMailList);
    }

    // web公開がするとなっていたらしないに変更
    private void setWebPublishing(Property__c mergeProperty){
        // web公開するの場合のみしないに変更
        if(mergeProperty.WebPublishing__c == CommonConst.PROPERTY_WEBPUBLISHING_EXISTS){
            mergeProperty.WebPublishing__c = CommonConst.PROPERTY_WEBPUBLISHING_NO;
        }
    }
                    
    /**
     * 物件コード履歴の名寄せ
     * @param Id updPropertyId 名寄せ先の物件.ID
     * @param Id delPropertyId 削除される物件.ID
     */
    private void mergePropertyCdHist(Id updPropertyId, Id delPropertyId) {

        // 削除対象の物件コード履歴を取得
        List<PropertyCodeHistory__c> mergeTargetPropertyCdHistList = 
            [SELECT Id
                    , Property__c
             FROM PropertyCodeHistory__c
             WHERE Property__c = :delPropertyId
            ];
        
        // 物件を更新
        for (PropertyCodeHistory__c mergeTargetPropertyCdHist : mergeTargetPropertyCdHistList) {
            mergeTargetPropertyCdHist.Property__c = updPropertyId;
        }

        // 物件コード履歴の名寄せ
        if (mergeTargetPropertyCdHistList.size() > 0) {
            SecureDML.secureUpdate(mergeTargetPropertyCdHistList);
        }
    }

    //******************************内部クラス*********************************************** */

    //添付ファイル
    public class screenAttachment {
        public String name { get; set; }//ファイル名
        public String detail { get; set; }//ファイル名詳細
        //コンストラクタ
        public screenAttachment(Attachment at){
            if(!String.isBlank(at.Name)){
                name = at.Name;
            }else{
                name = ' ';
            }
            if(at.BodyLength > 0 && !String.isBlank(String.ValueOf(at.BodyLength))){
                detail = at.SystemModStamp.format('yyyy/MM/dd') +'-' + byteConversion(at.BodyLength);
            }else{
                detail =' ';
            }
        }
        //バイト変換
        private String byteConversion(Decimal param){
            String reStr = '';
            Decimal div;

            if (param < 1024){
                div = 1;
                reStr = 'B';                      
            }else if ( 1024 <= param && param < 1048576){
                div = 1024;
                reStr = 'KB';
            }else if ( 1048576 <= param && param < 1073741824){
                div = 1048576;
                reStr = 'MB';
            }else if ( 1073741824  <= param && param < 1073741824*1024){
                div = 1073741824;
                reStr = 'GB';
            }else if ( 1073741824*1024 <= param ){
                div = 1073741824*1024;
                reStr = 'TB';
            }
            
            if (reStr != ''){
                reStr = CommonUtil.DecimalToString(param.divide(div, 1)) + reStr;
            }
            return reStr;
        }
    }
    // 写真情報内部クラス
    private class PhotoData {
        public String Tag       { get; set; }   // タグ
        public String FileName  { get; set; }   // ファイル名
        public String FilePath  { get; set; }   // ファイルパス
        public String Comment  { get; set; }   // コメント
    }

    public class ScreenAnyPhotoData{
        public Integer photoCount               { get; set; }   // 写真登録数
        public List<PhotoData> photoDataList    { get; set; }   // 写真情報
        public Integer panoramaCount               { get; set; }   // パノラマ写真登録数
        public List<PhotoData> panoramaDataList    { get; set; }   // パノラマ写真情報
        public Integer privateCount               { get; set; }   // 非公開写真登録数
        public List<PhotoData> privateDataList    { get; set; }   // 非公開写真情報

        public ScreenAnyPhotoData() {
            // 初期化
            this.photoDataList  = new List<PhotoData>();
        }
        public ScreenAnyPhotoData(PropertyPhoto__c propertyPhoto) {
            this.photoDataList  = new List<PhotoData>();
            this.panoramaDataList  = new List<PhotoData>();
            this.privateDataList  = new List<PhotoData>();

            String tagName = '';
            // データセット
            this.photoCount = 0;
            PhotoData data;
            // 物件写真
            for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PROPERTY; i++) {
                data = new photoData();
                data.Tag        = (String)propertyPhoto.get('PropertyPhotoTag' + i + '__c');               
                data.FileName   = (String)propertyPhoto.get('PropertyPhotoFileName' + i + '__c');
                data.FilePath   = (String)propertyPhoto.get('PropertyPhotoFilePath' + i + '__c');
                data.Comment    = (String)propertyPhoto.get('PropertyPhotoComment' + i + '__c');

                // ファイル名が空のデータは対象外とする
                if (String.isEmpty(data.FileName)) {
                    continue;
                }
                this.photoDataList.add(data);
                photoCount += 1;
            }
            // 非公開写真
            this.privateCount = 0;
            for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PRIVATE; i++) {
                data = new photoData();
                data.Tag        = (String)propertyPhoto.get('PrivatePhotoType' + i + '__c');               
                data.FileName   = (String)propertyPhoto.get('PrivatePhotoFileName' + i + '__c');
                data.FilePath   = (String)propertyPhoto.get('PrivatePhotoFilePath' + i + '__c');
                data.Comment    = (String)propertyPhoto.get('PrivatePhotoComment' + i + '__c');

                // ファイル名が空のデータは対象外とする
                if (String.isEmpty(data.FileName)) {
                    continue;
                }
                this.privateDataList.add(data);
                privateCount += 1;
            }
            // パノラマ写真
            this.panoramaCount = 0;
            PhotoData panoramaData;
            for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PANORAMA; i++) {
                panoramaData = new photoData();
                panoramaData.Tag        = (String)propertyPhoto.get('PanoramaTag' + i + '__c');               
                panoramaData.FileName   = (String)propertyPhoto.get('PanoramaFileName' + i + '__c');
                panoramaData.FilePath   = (String)propertyPhoto.get('PanoramaFilePath' + i + '__c');
                panoramaData.Comment    = (String)propertyPhoto.get('PanoramaComment' + i + '__c');

                // ファイル名が空のデータは対象外とする
                if (String.isEmpty(panoramaData.FileName)) {
                    continue;
                }
                this.panoramaDataList.add(panoramaData);
                panoramaCount += 1;
            }
        }

    }

    /**
    * 写真パスをS3ファイル移動オブジェクトに追加する
    * @param  PropertyPhoto__c unselectPicture 選択されなかった物件写真
    * @param  PropertyPhoto__c selectPicture 選択された物件写真
    * @param  PropertyPhoto__c unselectFloorPicture 選択されなかった間取り図
    * @param  PropertyPhoto__c selectFloorPicture 選択された間取り図
    * @param  Boolean pictureMoveFlg 写真移動フラグ true:移動する/false:移動しない
    * @param  Boolean floorPictureMoveFlg 間取り図移動フラグ true:移動する/false:移動しない
    */
    private void pictureMovement(PropertyPhoto__c unselectPicture, PropertyPhoto__c selectPicture
                ,PropertyPhoto__c unselectFloorPicture, PropertyPhoto__c selectFloorPicture
                ,Boolean pictureMoveFlg, Boolean floorPictureMoveFlg){


        List<S3FileMove__c> s3FileMoveList = new List<S3FileMove__c>(); 
        S3FileMove__c s3FileMove; 

        // 変更前のパスと、変更後のパスを入れた、S3ファイル移動レコードを、insertListに追加する
        
        if(pictureMoveFlg) {

            // 物件写真ファイルパス１
            if (String.isnotBlank(selectPicture.PropertyPhotoFilePath1__c)){
                s3FileMove = saveS3FileMove(selectPicture.PropertyPhotoFilePath1__c,selectPicture.Property__r.ForeignID__c,unselectPicture.Property__r.ForeignID__c);
                s3FileMoveList.add(s3FileMove);
            }
            // 物件写真ファイルパス２
            if (String.isnotBlank(selectPicture.PropertyPhotoFilePath2__c)){
                s3FileMove = saveS3FileMove(selectPicture.PropertyPhotoFilePath2__c,selectPicture.Property__r.ForeignID__c,unselectPicture.Property__r.ForeignID__c);
                s3FileMoveList.add(s3FileMove);
            }
            // 物件写真ファイルパス３
            if (String.isnotBlank(selectPicture.PropertyPhotoFilePath3__c)){
                s3FileMove = saveS3FileMove(selectPicture.PropertyPhotoFilePath3__c,selectPicture.Property__r.ForeignID__c,unselectPicture.Property__r.ForeignID__c);
                s3FileMoveList.add(s3FileMove);
            }
            // 物件写真ファイルパス４
            if (String.isnotBlank(selectPicture.PropertyPhotoFilePath4__c)){
                s3FileMove = saveS3FileMove(selectPicture.PropertyPhotoFilePath4__c,selectPicture.Property__r.ForeignID__c,unselectPicture.Property__r.ForeignID__c);
                s3FileMoveList.add(s3FileMove);
            }
            // 物件写真ファイルパス５
            if (String.isnotBlank(selectPicture.PropertyPhotoFilePath5__c)){
                s3FileMove = saveS3FileMove(selectPicture.PropertyPhotoFilePath5__c,selectPicture.Property__r.ForeignID__c,unselectPicture.Property__r.ForeignID__c);
                s3FileMoveList.add(s3FileMove);
            }
            // 物件写真ファイルパス６
            if (String.isnotBlank(selectPicture.PropertyPhotoFilePath6__c)){
                s3FileMove = saveS3FileMove(selectPicture.PropertyPhotoFilePath6__c,selectPicture.Property__r.ForeignID__c,unselectPicture.Property__r.ForeignID__c);
                s3FileMoveList.add(s3FileMove);
            }
            // 物件写真ファイルパス７
            if (String.isnotBlank(selectPicture.PropertyPhotoFilePath7__c)){
                s3FileMove = saveS3FileMove(selectPicture.PropertyPhotoFilePath7__c,selectPicture.Property__r.ForeignID__c,unselectPicture.Property__r.ForeignID__c);
                s3FileMoveList.add(s3FileMove);
            }
            // 物件写真ファイルパス８
            if (String.isnotBlank(selectPicture.PropertyPhotoFilePath8__c)){
                s3FileMove = saveS3FileMove(selectPicture.PropertyPhotoFilePath8__c,selectPicture.Property__r.ForeignID__c,unselectPicture.Property__r.ForeignID__c);
                s3FileMoveList.add(s3FileMove);
            }
            // 物件写真ファイルパス９
            if (String.isnotBlank(selectPicture.PropertyPhotoFilePath9__c)){
                s3FileMove = saveS3FileMove(selectPicture.PropertyPhotoFilePath9__c,selectPicture.Property__r.ForeignID__c,unselectPicture.Property__r.ForeignID__c);
                s3FileMoveList.add(s3FileMove);
            }
            // 物件写真ファイルパス１０
            if (String.isnotBlank(selectPicture.PropertyPhotoFilePath10__c)){
                s3FileMove = saveS3FileMove(selectPicture.PropertyPhotoFilePath10__c,selectPicture.Property__r.ForeignID__c,unselectPicture.Property__r.ForeignID__c);
                s3FileMoveList.add(s3FileMove);
            }
            // 物件写真ファイルパス１１
            if (String.isnotBlank(selectPicture.PropertyPhotoFilePath11__c)){
                s3FileMove = saveS3FileMove(selectPicture.PropertyPhotoFilePath11__c,selectPicture.Property__r.ForeignID__c,unselectPicture.Property__r.ForeignID__c);
                s3FileMoveList.add(s3FileMove);
            }
            // 物件写真ファイルパス１２
            if (String.isnotBlank(selectPicture.PropertyPhotoFilePath12__c)){
                s3FileMove = saveS3FileMove(selectPicture.PropertyPhotoFilePath12__c,selectPicture.Property__r.ForeignID__c,unselectPicture.Property__r.ForeignID__c);
                s3FileMoveList.add(s3FileMove);
            }
            // 物件写真ファイルパス１３
            if (String.isnotBlank(selectPicture.PropertyPhotoFilePath13__c)){
                s3FileMove = saveS3FileMove(selectPicture.PropertyPhotoFilePath13__c,selectPicture.Property__r.ForeignID__c,unselectPicture.Property__r.ForeignID__c);
                s3FileMoveList.add(s3FileMove);
            }
            // 物件写真ファイルパス１４
            if (String.isnotBlank(selectPicture.PropertyPhotoFilePath14__c)){
                s3FileMove = saveS3FileMove(selectPicture.PropertyPhotoFilePath14__c,selectPicture.Property__r.ForeignID__c,unselectPicture.Property__r.ForeignID__c);
                s3FileMoveList.add(s3FileMove);
            }
            // 物件写真ファイルパス１５
            if (String.isnotBlank(selectPicture.PropertyPhotoFilePath15__c)){
                s3FileMove = saveS3FileMove(selectPicture.PropertyPhotoFilePath15__c,selectPicture.Property__r.ForeignID__c,unselectPicture.Property__r.ForeignID__c);
                s3FileMoveList.add(s3FileMove);
            }
            // 物件写真ファイルパス１６
            if (String.isnotBlank(selectPicture.PropertyPhotoFilePath16__c)){
                s3FileMove = saveS3FileMove(selectPicture.PropertyPhotoFilePath16__c,selectPicture.Property__r.ForeignID__c,unselectPicture.Property__r.ForeignID__c);
                s3FileMoveList.add(s3FileMove);
            }
            // 物件写真ファイルパス１７
            if (String.isnotBlank(selectPicture.PropertyPhotoFilePath17__c)){
                s3FileMove = saveS3FileMove(selectPicture.PropertyPhotoFilePath17__c,selectPicture.Property__r.ForeignID__c,unselectPicture.Property__r.ForeignID__c);
                s3FileMoveList.add(s3FileMove);
            }
            // 物件写真ファイルパス１８
            if (String.isnotBlank(selectPicture.PropertyPhotoFilePath18__c)){
                s3FileMove = saveS3FileMove(selectPicture.PropertyPhotoFilePath18__c,selectPicture.Property__r.ForeignID__c,unselectPicture.Property__r.ForeignID__c);
                s3FileMoveList.add(s3FileMove);
            }
            // 物件写真ファイルパス１９
            if (String.isnotBlank(selectPicture.PropertyPhotoFilePath19__c)){
                s3FileMove = saveS3FileMove(selectPicture.PropertyPhotoFilePath19__c,selectPicture.Property__r.ForeignID__c,unselectPicture.Property__r.ForeignID__c);
                s3FileMoveList.add(s3FileMove);
            }
            // 物件写真ファイルパス２０
            if (String.isnotBlank(selectPicture.PropertyPhotoFilePath20__c)){
                s3FileMove = saveS3FileMove(selectPicture.PropertyPhotoFilePath20__c,selectPicture.Property__r.ForeignID__c,unselectPicture.Property__r.ForeignID__c);
                s3FileMoveList.add(s3FileMove);
            }

            // パノラマファイルパス１
            if (String.isnotBlank(selectPicture.PanoramaFilePath1__c)){
                s3FileMove = saveS3FileMove(selectPicture.PanoramaFilePath1__c,selectPicture.Property__r.ForeignID__c,unselectPicture.Property__r.ForeignID__c);
                s3FileMoveList.add(s3FileMove);
            }
            // パノラマファイルパス２
            if (String.isnotBlank(selectPicture.PanoramaFilePath2__c)){
                s3FileMove = saveS3FileMove(selectPicture.PanoramaFilePath2__c,selectPicture.Property__r.ForeignID__c,unselectPicture.Property__r.ForeignID__c);
                s3FileMoveList.add(s3FileMove);
            }
            // パノラマファイルパス３
            if (String.isnotBlank(selectPicture.PanoramaFilePath3__c)){
                s3FileMove = saveS3FileMove(selectPicture.PanoramaFilePath3__c,selectPicture.Property__r.ForeignID__c,unselectPicture.Property__r.ForeignID__c);
                s3FileMoveList.add(s3FileMove);
            }
            // パノラマファイルパス４
            if (String.isnotBlank(selectPicture.PanoramaFilePath4__c)){
                s3FileMove = saveS3FileMove(selectPicture.PanoramaFilePath4__c,selectPicture.Property__r.ForeignID__c,unselectPicture.Property__r.ForeignID__c);
                s3FileMoveList.add(s3FileMove);
            }
            // パノラマファイルパス５
            if (String.isnotBlank(selectPicture.PanoramaFilePath5__c)){
                s3FileMove = saveS3FileMove(selectPicture.PanoramaFilePath5__c,selectPicture.Property__r.ForeignID__c,unselectPicture.Property__r.ForeignID__c);
                s3FileMoveList.add(s3FileMove);
            }

            // 非公開写真ファイルパス１
            if (String.isnotBlank(selectPicture.PrivatePhotoFilePath1__c)){
                s3FileMove = saveS3FileMove(selectPicture.PrivatePhotoFilePath1__c,selectPicture.Property__r.ForeignID__c,unselectPicture.Property__r.ForeignID__c);
                s3FileMoveList.add(s3FileMove);
            }
            // 非公開写真ファイルパス２
            if (String.isnotBlank(selectPicture.PrivatePhotoFilePath2__c)){
                s3FileMove = saveS3FileMove(selectPicture.PrivatePhotoFilePath2__c,selectPicture.Property__r.ForeignID__c,unselectPicture.Property__r.ForeignID__c);
                s3FileMoveList.add(s3FileMove);
            }
            // 非公開写真ファイルパス３
            if (String.isnotBlank(selectPicture.PrivatePhotoFilePath3__c)){
                s3FileMove = saveS3FileMove(selectPicture.PrivatePhotoFilePath3__c,selectPicture.Property__r.ForeignID__c,unselectPicture.Property__r.ForeignID__c);
                s3FileMoveList.add(s3FileMove);
            }
            // 非公開写真ファイルパス４
            if (String.isnotBlank(selectPicture.PrivatePhotoFilePath4__c)){
                s3FileMove = saveS3FileMove(selectPicture.PrivatePhotoFilePath4__c,selectPicture.Property__r.ForeignID__c,unselectPicture.Property__r.ForeignID__c);
                s3FileMoveList.add(s3FileMove);
            }
            // 非公開写真ファイルパス５
            if (String.isnotBlank(selectPicture.PrivatePhotoFilePath5__c)){
                s3FileMove = saveS3FileMove(selectPicture.PrivatePhotoFilePath5__c,selectPicture.Property__r.ForeignID__c,unselectPicture.Property__r.ForeignID__c);
                s3FileMoveList.add(s3FileMove);
            }
            // 非公開写真ファイルパス６
            if (String.isnotBlank(selectPicture.PrivatePhotoFilePath6__c)){
                s3FileMove = saveS3FileMove(selectPicture.PrivatePhotoFilePath6__c,selectPicture.Property__r.ForeignID__c,unselectPicture.Property__r.ForeignID__c);
                s3FileMoveList.add(s3FileMove);
            }
            // 非公開写真ファイルパス７
            if (String.isnotBlank(selectPicture.PrivatePhotoFilePath7__c)){
                s3FileMove = saveS3FileMove(selectPicture.PrivatePhotoFilePath7__c,selectPicture.Property__r.ForeignID__c,unselectPicture.Property__r.ForeignID__c);
                s3FileMoveList.add(s3FileMove);
            }
            // 非公開写真ファイルパス８
            if (String.isnotBlank(selectPicture.PrivatePhotoFilePath8__c)){
                s3FileMove = saveS3FileMove(selectPicture.PrivatePhotoFilePath8__c,selectPicture.Property__r.ForeignID__c,unselectPicture.Property__r.ForeignID__c);
                s3FileMoveList.add(s3FileMove);
            }                
        }
        if(floorPictureMoveFlg) {
            // 間取り図ファイルパス
            if (String.isnotBlank(selectFloorPicture.RoomLayoutFilePath__c)){
                s3FileMove = saveS3FileMove(selectFloorPicture.RoomLayoutFilePath__c,selectFloorPicture.Property__r.ForeignID__c,unselectFloorPicture.Property__r.ForeignID__c);
                s3FileMoveList.add(s3FileMove);

                // 間取り図位置情報ファイルを移動するデータを作成する。
                String jsonFilePath = AmazonS3Util.extensionConvertJson(selectFloorPicture.RoomLayoutFilePath__c); 
                if(String.isnotBlank(jsonFilePath)){
                    s3FileMove = saveS3FileMove(jsonFilePath,selectFloorPicture.Property__r.ForeignID__c,unselectFloorPicture.Property__r.ForeignID__c);
                    s3FileMoveList.add(s3FileMove);
                }
            }
            // 間取り図メモファイルパス
            if (String.isnotBlank(selectFloorPicture.RoomLayoutMemoFilePath__c)){
                s3FileMove = saveS3FileMove(selectFloorPicture.RoomLayoutMemoFilePath__c,selectFloorPicture.Property__r.ForeignID__c,unselectFloorPicture.Property__r.ForeignID__c);
                s3FileMoveList.add(s3FileMove);
            }
        }

        // insertListが0より大きければ、insertする　
        if(s3FileMoveList.size() > 0 ) {
            insert s3FileMoveList;
            // バッチを実行
            S3PhotoMoveBatch b = new S3PhotoMoveBatch();
            Id batchJobId = Database.executeBatch(b, 50);
        }
    }

    /**
    * ファイルパスを成形し、S3ファイル移動オブジェクトに追加する
    * @param  String propertyPhotoPass ファイルパス
    * @param  String selectForeignIdProp 選択された写真の外部ID
    * @param  String unselectForeignIdProp 選択されなかった写真の外部ID
    * @return s3FileMove__c 移動する写真情報
    */
    private s3FileMove__c saveS3FileMove(String propertyPhotoPass,String selectForeignIdProp,
                                         String unselectForeignIdProp){
        s3FileMove__c saveDate = new s3FileMove__c();

        // 画像のパスを移動可能な状態に補正する。
        propertyPhotoPass = PropertyPhotoPass.replace('https://' + bucketName + '.s3.amazonaws.com/', CommonConst.STRING_EMPTY);
        // 建物の外部IDを移動元のファイルパスにする(移動元ファイルパスを生成)。
        string toPhotoFilePath = PropertyPhotoPass.replace(selectForeignIdProp,unselectForeignIdProp);

        // 登録内容を設定
        saveDate.FromPhotoFilePath__c = PropertyPhotoPass; // 移動元ファイルパス
        saveDate.ToPhotoFilePath__c = toPhotoFilePath;   // 移動先ファイルパス
        saveDate.BatchStatus__c = CommonConst.S3FILEMOVE_BATCHSTATUS_WAITING_PROCESSING;   // バッチステータス

        return saveDate;
    }

    /**
    * 写真のファイルパスをリストにまとめる
    * @param  PropertyPhoto__c propPhoto 物件写真
    * @return List<String> ファイルパスのリスト
    */
    private List<String> getFilePassList(PropertyPhoto__c propPhoto) {
        List<String> filePassList = new List<String>();
        // 物件写真
        if(propPhoto.PropertyPhotoFilePath1__c != null) {
            filePassList.add(propPhoto.PropertyPhotoFilePath1__c);
        }
        if(propPhoto.PropertyPhotoFilePath2__c != null) {
            filePassList.add(propPhoto.PropertyPhotoFilePath2__c);
        }
        if(propPhoto.PropertyPhotoFilePath3__c != null) {
            filePassList.add(propPhoto.PropertyPhotoFilePath3__c);
        }
        if(propPhoto.PropertyPhotoFilePath4__c != null) {
            filePassList.add(propPhoto.PropertyPhotoFilePath4__c);
        }
        if(propPhoto.PropertyPhotoFilePath5__c != null) {
            filePassList.add(propPhoto.PropertyPhotoFilePath5__c);
        }
        if(propPhoto.PropertyPhotoFilePath6__c != null) {
            filePassList.add(propPhoto.PropertyPhotoFilePath6__c);
        }
        if(propPhoto.PropertyPhotoFilePath7__c != null) {
            filePassList.add(propPhoto.PropertyPhotoFilePath7__c);
        }
        if(propPhoto.PropertyPhotoFilePath8__c != null) {
            filePassList.add(propPhoto.PropertyPhotoFilePath8__c);
        }
        if(propPhoto.PropertyPhotoFilePath9__c != null) {
            filePassList.add(propPhoto.PropertyPhotoFilePath9__c);
        }
        if(propPhoto.PropertyPhotoFilePath10__c != null) {
            filePassList.add(propPhoto.PropertyPhotoFilePath10__c);
        }
        if(propPhoto.PropertyPhotoFilePath11__c != null) {
            filePassList.add(propPhoto.PropertyPhotoFilePath11__c);
        }
        if(propPhoto.PropertyPhotoFilePath12__c != null) {
            filePassList.add(propPhoto.PropertyPhotoFilePath12__c);
        }
        if(propPhoto.PropertyPhotoFilePath13__c != null) {
            filePassList.add(propPhoto.PropertyPhotoFilePath13__c);
        }
        if(propPhoto.PropertyPhotoFilePath14__c != null) {
            filePassList.add(propPhoto.PropertyPhotoFilePath14__c);
        }
        if(propPhoto.PropertyPhotoFilePath15__c != null) {
            filePassList.add(propPhoto.PropertyPhotoFilePath15__c);
        }
        if(propPhoto.PropertyPhotoFilePath16__c != null) {
            filePassList.add(propPhoto.PropertyPhotoFilePath16__c);
        }
        if(propPhoto.PropertyPhotoFilePath17__c != null) {
            filePassList.add(propPhoto.PropertyPhotoFilePath17__c);
        }
        if(propPhoto.PropertyPhotoFilePath18__c != null) {
            filePassList.add(propPhoto.PropertyPhotoFilePath18__c);
        }
        if(propPhoto.PropertyPhotoFilePath19__c != null) {
            filePassList.add(propPhoto.PropertyPhotoFilePath19__c);
        }
        if(propPhoto.PropertyPhotoFilePath20__c != null) {
            filePassList.add(propPhoto.PropertyPhotoFilePath20__c);
        }
        // パノラマ写真
        if(propPhoto.PanoramaFilePath1__c != null) {
            filePassList.add(propPhoto.PanoramaFilePath1__c);
        }
        if(propPhoto.PanoramaFilePath2__c != null) {
            filePassList.add(propPhoto.PanoramaFilePath2__c);
        }
        if(propPhoto.PanoramaFilePath3__c != null) {
            filePassList.add(propPhoto.PanoramaFilePath3__c);
        }
        if(propPhoto.PanoramaFilePath4__c != null) {
            filePassList.add(propPhoto.PanoramaFilePath4__c);
        }
        if(propPhoto.PanoramaFilePath5__c != null) {
            filePassList.add(propPhoto.PanoramaFilePath5__c);
        }
        // 非公開写真
        if(propPhoto.PrivatePhotoFilePath1__c != null) {
            filePassList.add(propPhoto.PrivatePhotoFilePath1__c);
        }
        if(propPhoto.PrivatePhotoFilePath2__c != null) {
            filePassList.add(propPhoto.PrivatePhotoFilePath2__c);
        }
        if(propPhoto.PrivatePhotoFilePath3__c != null) {
            filePassList.add(propPhoto.PrivatePhotoFilePath3__c);
        }
        if(propPhoto.PrivatePhotoFilePath4__c != null) {
            filePassList.add(propPhoto.PrivatePhotoFilePath4__c);
        }
        if(propPhoto.PrivatePhotoFilePath5__c != null) {
            filePassList.add(propPhoto.PrivatePhotoFilePath5__c);
        }
        if(propPhoto.PrivatePhotoFilePath6__c != null) {
            filePassList.add(propPhoto.PrivatePhotoFilePath6__c);
        }
        if(propPhoto.PrivatePhotoFilePath7__c != null) {
            filePassList.add(propPhoto.PrivatePhotoFilePath7__c);
        }
        if(propPhoto.PrivatePhotoFilePath8__c != null) {
            filePassList.add(propPhoto.PrivatePhotoFilePath8__c);
        }        
        
        return filePassList;
    }

    /**
    * 写真ファイルパスが一致するおすすめ物件を取得
    * @param  List<String> filePassList 物件写真のファイルパスのリスト
    * @return List<RecommendProperty__c> 取得したおすすめ物件/取得できなかった場合は空のおすすめ物件
    */
    private List<RecommendProperty__c> getRecommendProperty(List<String> filePassList){
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
                                            WHERE PhotoFilePath__c in :filePassList];
        if (recoProList.isEmpty()){
            //おすすめ物件から取得できなかったら空を返す
            return new List<RecommendProperty__c>();
        }else{
            //取得できたらそれを返す
            return recoProList;
        }
    }

    /**
    * 物件に紐づく物件写真を取得
    * @param  Id targetId 物件のID
    * @return PropertyPhoto__c 取得した物件写真
    */
    private PropertyPhoto__c selectPropertyPhotoData(Id targetId){
        String sql = '';
        sql += 'SELECT Id ';
        for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PROPERTY; i++) {          // 物件写真
            sql += '      ,PropertyPhotoFileName' + i + '__c ';
            sql += '      ,PropertyPhotoTag' + i + '__c ';
            sql += '      ,PropertyPhotoComment' + i + '__c ';
        }
        for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PRIVATE; i++) {  // 物件非公開
            sql += '      ,PrivatePhotoFileName' + i + '__c ';
            sql += '      ,PrivatePhotoType' + i + '__c ';
            sql += '      ,PrivatePhotoComment' + i + '__c ';
        }
        for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PANORAMA; i++) { // 物件パノラマ
            sql += '      ,PanoramaFileName' + i + '__c ';
            sql += '      ,PanoramaTag' + i + '__c ';
            sql += '      ,PanoramaComment' + i + '__c ';
        }
        sql += '      ,RoomLayoutFileName__c ';                     // 物件間取り図
        sql += '      ,RoomLayoutMemoFileName__c ';                 // 物件間取り図（メモ有）
        sql += '      ,Property__r.ForeignID__c ';
        sql += '      ,Property__r.Building__r.ForeignID__c ';
        sql += '  FROM PropertyPhoto__c ';
        sql += ' WHERE Property__c   = :targetId ';
        List<PropertyPhoto__c> propertyPhotoList = new List<PropertyPhoto__c>();
        propertyPhotoList = Database.query(sql);

        if (propertyPhotoList.isEmpty()){
            return new PropertyPhoto__c();
        }
        return propertyPhotoList[0];
    }


    /**
    * 名寄せにより削除される物件写真を残る側へ置き換える
    * @param  PropertyPhoto__c selectPicture 選択された物件写真
    * @param  PropertyPhoto__c unselectPicture 選択されなかった物件写真
    * @return PropertyPhoto__c 選択されなかった写真
    */
    private PropertyPhoto__c replacePropertyPicture(PropertyPhoto__c selectPicture, PropertyPhoto__c unselectPicture) {
        
        // 物件写真ファイル名
        unselectPicture.PropertyPhotoFileName1__c = selectPicture.PropertyPhotoFileName1__c;
        unselectPicture.PropertyPhotoFileName2__c = selectPicture.PropertyPhotoFileName2__c;
        unselectPicture.PropertyPhotoFileName3__c = selectPicture.PropertyPhotoFileName3__c;
        unselectPicture.PropertyPhotoFileName4__c = selectPicture.PropertyPhotoFileName4__c;
        unselectPicture.PropertyPhotoFileName5__c = selectPicture.PropertyPhotoFileName5__c;
        unselectPicture.PropertyPhotoFileName6__c = selectPicture.PropertyPhotoFileName6__c;
        unselectPicture.PropertyPhotoFileName7__c = selectPicture.PropertyPhotoFileName7__c;
        unselectPicture.PropertyPhotoFileName8__c = selectPicture.PropertyPhotoFileName8__c;
        unselectPicture.PropertyPhotoFileName9__c = selectPicture.PropertyPhotoFileName9__c;
        unselectPicture.PropertyPhotoFileName10__c = selectPicture.PropertyPhotoFileName10__c;
        unselectPicture.PropertyPhotoFileName11__c = selectPicture.PropertyPhotoFileName11__c;
        unselectPicture.PropertyPhotoFileName12__c = selectPicture.PropertyPhotoFileName12__c;
        unselectPicture.PropertyPhotoFileName13__c = selectPicture.PropertyPhotoFileName13__c;
        unselectPicture.PropertyPhotoFileName14__c = selectPicture.PropertyPhotoFileName14__c;
        unselectPicture.PropertyPhotoFileName15__c = selectPicture.PropertyPhotoFileName15__c;
        unselectPicture.PropertyPhotoFileName16__c = selectPicture.PropertyPhotoFileName16__c;
        unselectPicture.PropertyPhotoFileName17__c = selectPicture.PropertyPhotoFileName17__c;
        unselectPicture.PropertyPhotoFileName18__c = selectPicture.PropertyPhotoFileName18__c;
        unselectPicture.PropertyPhotoFileName19__c = selectPicture.PropertyPhotoFileName19__c;
        unselectPicture.PropertyPhotoFileName20__c = selectPicture.PropertyPhotoFileName20__c;
        
        // 物件写真タグ
        unselectPicture.PropertyPhotoTag1__c = selectPicture.PropertyPhotoTag1__c;
        unselectPicture.PropertyPhotoTag2__c = selectPicture.PropertyPhotoTag2__c;
        unselectPicture.PropertyPhotoTag3__c = selectPicture.PropertyPhotoTag3__c;
        unselectPicture.PropertyPhotoTag4__c = selectPicture.PropertyPhotoTag4__c;
        unselectPicture.PropertyPhotoTag5__c = selectPicture.PropertyPhotoTag5__c;
        unselectPicture.PropertyPhotoTag6__c = selectPicture.PropertyPhotoTag6__c;
        unselectPicture.PropertyPhotoTag7__c = selectPicture.PropertyPhotoTag7__c;
        unselectPicture.PropertyPhotoTag8__c = selectPicture.PropertyPhotoTag8__c;
        unselectPicture.PropertyPhotoTag9__c = selectPicture.PropertyPhotoTag9__c;
        unselectPicture.PropertyPhotoTag10__c = selectPicture.PropertyPhotoTag10__c;
        unselectPicture.PropertyPhotoTag11__c = selectPicture.PropertyPhotoTag11__c;
        unselectPicture.PropertyPhotoTag12__c = selectPicture.PropertyPhotoTag12__c;
        unselectPicture.PropertyPhotoTag13__c = selectPicture.PropertyPhotoTag13__c;
        unselectPicture.PropertyPhotoTag14__c = selectPicture.PropertyPhotoTag14__c;
        unselectPicture.PropertyPhotoTag15__c = selectPicture.PropertyPhotoTag15__c;
        unselectPicture.PropertyPhotoTag16__c = selectPicture.PropertyPhotoTag16__c;
        unselectPicture.PropertyPhotoTag17__c = selectPicture.PropertyPhotoTag17__c;
        unselectPicture.PropertyPhotoTag18__c = selectPicture.PropertyPhotoTag18__c;
        unselectPicture.PropertyPhotoTag19__c = selectPicture.PropertyPhotoTag19__c;
        unselectPicture.PropertyPhotoTag20__c = selectPicture.PropertyPhotoTag20__c;

        // 物件写真コメント
        unselectPicture.PropertyPhotoComment1__c = selectPicture.PropertyPhotoComment1__c;
        unselectPicture.PropertyPhotoComment2__c = selectPicture.PropertyPhotoComment2__c;
        unselectPicture.PropertyPhotoComment3__c = selectPicture.PropertyPhotoComment3__c;
        unselectPicture.PropertyPhotoComment4__c = selectPicture.PropertyPhotoComment4__c;
        unselectPicture.PropertyPhotoComment5__c = selectPicture.PropertyPhotoComment5__c;
        unselectPicture.PropertyPhotoComment6__c = selectPicture.PropertyPhotoComment6__c;
        unselectPicture.PropertyPhotoComment7__c = selectPicture.PropertyPhotoComment7__c;
        unselectPicture.PropertyPhotoComment8__c = selectPicture.PropertyPhotoComment8__c;
        unselectPicture.PropertyPhotoComment9__c = selectPicture.PropertyPhotoComment9__c;
        unselectPicture.PropertyPhotoComment10__c = selectPicture.PropertyPhotoComment10__c;
        unselectPicture.PropertyPhotoComment11__c = selectPicture.PropertyPhotoComment11__c;
        unselectPicture.PropertyPhotoComment12__c = selectPicture.PropertyPhotoComment12__c;
        unselectPicture.PropertyPhotoComment13__c = selectPicture.PropertyPhotoComment13__c;
        unselectPicture.PropertyPhotoComment14__c = selectPicture.PropertyPhotoComment14__c;
        unselectPicture.PropertyPhotoComment15__c = selectPicture.PropertyPhotoComment15__c;
        unselectPicture.PropertyPhotoComment16__c = selectPicture.PropertyPhotoComment16__c;
        unselectPicture.PropertyPhotoComment17__c = selectPicture.PropertyPhotoComment17__c;
        unselectPicture.PropertyPhotoComment18__c = selectPicture.PropertyPhotoComment18__c;
        unselectPicture.PropertyPhotoComment19__c = selectPicture.PropertyPhotoComment19__c;
        unselectPicture.PropertyPhotoComment20__c = selectPicture.PropertyPhotoComment20__c;

        // 非公開写真ファイル名
        unselectPicture.PrivatePhotoFileName1__c = selectPicture.PrivatePhotoFileName1__c;
        unselectPicture.PrivatePhotoFileName2__c = selectPicture.PrivatePhotoFileName2__c;
        unselectPicture.PrivatePhotoFileName3__c = selectPicture.PrivatePhotoFileName3__c;
        unselectPicture.PrivatePhotoFileName4__c = selectPicture.PrivatePhotoFileName4__c;
        unselectPicture.PrivatePhotoFileName5__c = selectPicture.PrivatePhotoFileName5__c;
        unselectPicture.PrivatePhotoFileName6__c = selectPicture.PrivatePhotoFileName6__c;
        unselectPicture.PrivatePhotoFileName7__c = selectPicture.PrivatePhotoFileName7__c;
        unselectPicture.PrivatePhotoFileName8__c = selectPicture.PrivatePhotoFileName8__c;

        // 非公開写真種別（タグ）
        unselectPicture.PrivatePhotoType1__c = selectPicture.PrivatePhotoType1__c;
        unselectPicture.PrivatePhotoType2__c = selectPicture.PrivatePhotoType2__c;
        unselectPicture.PrivatePhotoType3__c = selectPicture.PrivatePhotoType3__c;
        unselectPicture.PrivatePhotoType4__c = selectPicture.PrivatePhotoType4__c;
        unselectPicture.PrivatePhotoType5__c = selectPicture.PrivatePhotoType5__c;
        unselectPicture.PrivatePhotoType6__c = selectPicture.PrivatePhotoType6__c;
        unselectPicture.PrivatePhotoType7__c = selectPicture.PrivatePhotoType7__c;
        unselectPicture.PrivatePhotoType8__c = selectPicture.PrivatePhotoType8__c;
                                                
        // 非公開写真コメント
        unselectPicture.PrivatePhotoComment1__c = selectPicture.PrivatePhotoComment1__c;
        unselectPicture.PrivatePhotoComment2__c = selectPicture.PrivatePhotoComment2__c;
        unselectPicture.PrivatePhotoComment3__c = selectPicture.PrivatePhotoComment3__c;
        unselectPicture.PrivatePhotoComment4__c = selectPicture.PrivatePhotoComment4__c;
        unselectPicture.PrivatePhotoComment5__c = selectPicture.PrivatePhotoComment5__c;
        unselectPicture.PrivatePhotoComment6__c = selectPicture.PrivatePhotoComment6__c;
        unselectPicture.PrivatePhotoComment7__c = selectPicture.PrivatePhotoComment7__c;
        unselectPicture.PrivatePhotoComment8__c = selectPicture.PrivatePhotoComment8__c;

        // パノラマファイル名
        unselectPicture.PanoramaFileName1__c = selectPicture.PanoramaFileName1__c;
        unselectPicture.PanoramaFileName2__c = selectPicture.PanoramaFileName2__c;
        unselectPicture.PanoramaFileName3__c = selectPicture.PanoramaFileName3__c;
        unselectPicture.PanoramaFileName4__c = selectPicture.PanoramaFileName4__c;
        unselectPicture.PanoramaFileName5__c = selectPicture.PanoramaFileName5__c;

        // パノラマタグ
        unselectPicture.PanoramaTag1__c = selectPicture.PanoramaTag1__c;
        unselectPicture.PanoramaTag2__c = selectPicture.PanoramaTag2__c;
        unselectPicture.PanoramaTag3__c = selectPicture.PanoramaTag3__c;
        unselectPicture.PanoramaTag4__c = selectPicture.PanoramaTag4__c;
        unselectPicture.PanoramaTag5__c = selectPicture.PanoramaTag5__c;

        // パノラマコメント
        unselectPicture.PanoramaComment1__c = selectPicture.PanoramaComment1__c;
        unselectPicture.PanoramaComment2__c = selectPicture.PanoramaComment2__c;
        unselectPicture.PanoramaComment3__c = selectPicture.PanoramaComment3__c;
        unselectPicture.PanoramaComment4__c = selectPicture.PanoramaComment4__c;
        unselectPicture.PanoramaComment5__c = selectPicture.PanoramaComment5__c;

        return unselectPicture;
    }

    /**
    * 名寄せにより削除される間取り図を残る側へ置き換える
    * @param  PropertyPhoto__c selectPicture 選択された間取り図
    * @param  PropertyPhoto__c unselectPicture 選択されなかった間取り図
    * @return PropertyPhoto__c 選択されなかった間取り図
    */
    private PropertyPhoto__c replacePropertyFloorPicture(PropertyPhoto__c selectFloorPicture, PropertyPhoto__c unselectFloorPicture) {

        // 間取り図ファイル名
        unselectFloorPicture.RoomLayoutFileName__c = selectFloorPicture.RoomLayoutFileName__c;
        // 間取り図メモファイル名
        unselectFloorPicture.RoomLayoutMemoFileName__c = selectFloorPicture.RoomLayoutMemoFileName__c;
        
        return unselectFloorPicture;
    }

    /**
    * 物件写真のファイル名をnullに書き換える
    * @param  PropertyPhoto__c propPhoto 物件写真
    * @return PropertyPhoto__c ファイル名をnullにした物件写真
    */
    private PropertyPhoto__c fileNameConvertNull(PropertyPhoto__c propPhoto) {
        
        // 物件写真ファイル名
        propPhoto.PropertyPhotoFileName1__c = null;
        propPhoto.PropertyPhotoFileName2__c = null;
        propPhoto.PropertyPhotoFileName3__c = null;
        propPhoto.PropertyPhotoFileName4__c = null;
        propPhoto.PropertyPhotoFileName5__c = null;
        propPhoto.PropertyPhotoFileName6__c = null;
        propPhoto.PropertyPhotoFileName7__c = null;
        propPhoto.PropertyPhotoFileName8__c = null;
        propPhoto.PropertyPhotoFileName9__c = null;
        propPhoto.PropertyPhotoFileName10__c = null;
        propPhoto.PropertyPhotoFileName11__c = null;
        propPhoto.PropertyPhotoFileName12__c = null;
        propPhoto.PropertyPhotoFileName13__c = null;
        propPhoto.PropertyPhotoFileName14__c = null;
        propPhoto.PropertyPhotoFileName15__c = null;
        propPhoto.PropertyPhotoFileName16__c = null;
        propPhoto.PropertyPhotoFileName17__c = null;
        propPhoto.PropertyPhotoFileName18__c = null;
        propPhoto.PropertyPhotoFileName19__c = null;
        propPhoto.PropertyPhotoFileName20__c = null;

        // 非公開写真ファイル名
        propPhoto.PrivatePhotoFileName1__c = null;
        propPhoto.PrivatePhotoFileName2__c = null;
        propPhoto.PrivatePhotoFileName3__c = null;
        propPhoto.PrivatePhotoFileName4__c = null;
        propPhoto.PrivatePhotoFileName5__c = null;
        propPhoto.PrivatePhotoFileName6__c = null;
        propPhoto.PrivatePhotoFileName7__c = null;
        propPhoto.PrivatePhotoFileName8__c = null;

        // パノラマファイル名
        propPhoto.PanoramaFileName1__c = null;
        propPhoto.PanoramaFileName2__c = null;
        propPhoto.PanoramaFileName3__c = null;
        propPhoto.PanoramaFileName4__c = null;
        propPhoto.PanoramaFileName5__c = null;

        // 間取り図ファイル名
        propPhoto.RoomLayoutFileName__c = null;
        // 間取り図メモファイル名
        propPhoto.RoomLayoutMemoFileName__c = null;

        return propPhoto;
    }

    /**
    * 建物写真を取得する
    * @param  String buildId 建物のid
    * @return BuildingPhoto__c 建物のidに紐づく建物写真
    */
    private BuildingPhoto__c getBuildPhoto(String buildId) {

        List<BuildingPhoto__c> buildPhotoList = [
            SELECT
                Id
                ,AppearanceFileName__c//建物外観
                ,EntranceFileName__c//エントランス写真ファイル名
                ,LobbyFileName__c//ロビー写真ファイル名
                ,ParkingFileName__c//駐車場写真ファイル名
                ,OtherSharingFileName__c//その他共有写真ファイル名
                ,SurroundingFileName1__c//周辺写真ファイル名１
                ,SurroundingFileName2__c//周辺写真ファイル名２
                ,SurroundingFileName3__c//周辺写真ファイル名３
                ,SurroundingFileName4__c//周辺写真ファイル名４
                ,SurroundingFileName5__c//周辺写真ファイル名５
            FROM
                BuildingPhoto__c
            WHERE
                Building__c = :buildId
        ];
        if (buildPhotoList.isEmpty()){
            return new BuildingPhoto__c();
        }
        return buildPhotoList[0];
    }

}