/**
 * Amazon S3関連共通クラス
 */
public with sharing class AmazonS3Util {

    /* 定数 */
    // 写真種別
    public enum PhotoType {
        PROPERTY                    // 物件
        ,PROPERTY_PRIVATE           // 物件非公開
        ,PROPERTY_PANORAMA          // 物件パノラマ
        ,PROPERTY_ROOMLAYOUT        // 間取り図
        ,PROPERTY_ROOMLAYOUTMEMO    // 間取り図（メモ有）
        ,BUILDING_APPEARANCE        // 建物外観
        ,BUILDING_APPEARANCEPARSE   // 建物外観パース
        ,BUILDING_ENTRANCE          // 建物エントランス
        ,BUILDING_LOBBY             // 建物ロビー
        ,BUILDING_PARKING           // 建物駐車場
        ,BUILDING_OTHERSHARING      // 建物その他共有
        ,BUILDING_MAP               // 建物地図
        ,BUILDING_OTHER             // 建物その他
        ,BUILDING_SURROUNDING       // 建物周辺
        ,SCHOOL                     // 学校
        ,HOSPITAL                   // 病院
        ,NEWSRELEASE                // ニュースリリース     // ポータルサイト構築 追加
        ,SHOP                       // 店舗     // ポータルサイト構築 追加
        ,SURROUNDING_FACILITY       // 周辺施設
    }

    // AmazonS3のフォルダ階層
    private static final String S3FOLDERPATH_BUILDING_PROPERTY  = SystemConfig__c.getInstance().S3RootDirectory__c + '/public/salesforce/photo/building_property/'; // 建物・物件
    private static final String S3FOLDERPATH_SHOOL              = SystemConfig__c.getInstance().S3RootDirectory__c + '/public/salesforce/photo/school/';            // 学校
    private static final String S3FOLDERPATH_HOSPITAL           = SystemConfig__c.getInstance().S3RootDirectory__c + '/public/salesforce/photo/hospital/';          // 病院
    private static final String S3FOLDERPATH_NEWS_RELEASE       = SystemConfig__c.getInstance().S3RootDirectory__c + '/public/salesforce/photo/news_release/';      // ニュースリリース　// ポータルサイト構築 追加
    private static final String S3FOLDERPATH_SHOP               = SystemConfig__c.getInstance().S3RootDirectory__c + '/public/salesforce/photo/shop/';              // 店舗　// ポータルサイト構築 追加
    private static final String S3FOLDERPATH_SURROUNDING        = SystemConfig__c.getInstance().S3RootDirectory__c + '/public/salesforce/photo/surrounding/';       // 周辺施設
	private static final String S3FOLDERPATH_CSV				= SystemConfig__c.getInstance().S3RootDirectory__c + '/public/salesforce/buckupCSV/';				// CSV置き場_2021.12.20 No.437 対応で追加

	// ▼ 2022.1.13 LINE連携対応より、追加と修正
	// AmazonS3への接続に使用する情報
	private static String bucketName		{ get{return SystemConfig__c.getInstance().S3BucketName__c;}		private set; }	// バケット名
	private static String accessKeyId		{ get{return SystemConfig__c.getInstance().S3AccessKey__c;}			private set; }	// アクセスキーID
	private static String secretAccessKey	{ get{return SystemConfig__c.getInstance().S3SecretAccessKey__c;}	private set; }	// シークレットアクセスキー
	private static String region			{ get{return SystemConfig__c.getInstance().S3Region__c;}			private set; }	// リージョン
	// ▲ 2022.1.13

    /**
     * コンストラクタ
     * @param  なし
     * @return なし
     */
    public AmazonS3Util() {

    }

    /**
     * 写真移動処理(移動のみでDB更新はなし)
     * @param  List<String>     fromPhotoPathList       コピー元の画像ファイルパス
     * @param  List<String>     toPhotoPathList         コピー先の画像ファイルパス
     */
    public static void callS3PhotoMoveNonDBUpdate(List<String> fromPhotoPathList, List<String> toPhotoPathList) {
        List<String> photoDelList = new List<String>();

        // ファイルコピー
        for (Integer i = 0; i < fromPhotoPathList.size(); i++) {
            if (String.isBlank(fromPhotoPathList[i]) || String.isBlank(toPhotoPathList[i])) {
                continue;
            }
            HTTPResponse response = AmazonS3Util.callCopyReqest(fromPhotoPathList[i], toPhotoPathList[i]);
            if (response.getStatusCode() == 200) {
                photoDelList.add(fromPhotoPathList[i]);
            }
        }

        // ファイル削除
        if (photoDelList.size() > 0) {
            HTTPResponse response = AmazonS3Util.callMultipleDeleteReqest(photoDelList);
        }        
    }

    /**
     * ファイルコピー処理（DB更新は無し）
     * @param  List<String>     fromPathList       コピー元のファイルパス
     * @param  List<String>     toPathList         コピー先のファイルパス
     */
    public static void callS3MoveNonDBUpdate(List<String> fromPathList, List<String> toPathList) {

        // ファイルコピー
        for (Integer i = 0; i < fromPathList.size(); i++) {
            if (String.isBlank(fromPathList[i]) || String.isBlank(toPathList[i])) {
                continue;
            }
            HTTPResponse response = AmazonS3Util.callCopyReqest(S3FOLDERPATH_BUILDING_PROPERTY + fromPathList[i], S3FOLDERPATH_BUILDING_PROPERTY + toPathList[i]);
        }

    }

    /**
     * 削除処理
     * @param  Id           targetId    物件Id or 建物Id or 学校Id or 病院Id or ニュースリリースId or 店舗Id
     * @param  PhotoType    photoType   写真種別
     * @param  Integer      photoIndex  写真インデックス（建物．周辺写真等 ｎ項目存在する場合のみ指定）
     * @return なし
     */
    public static void callPhotoDelete(Id targetId, PhotoType photoType) {
        AmazonS3Util.callPhotoDelete(targetId, photoType, 1);
    }
    public static void callPhotoDelete(Id targetId, PhotoType photoType, Integer photoIndex) {
        // 対象オブジェクト取得
        AnyPhotoData anyPhotoData = AmazonS3Util.getAnyPhotoData(targetId, photoType);

        // 削除ファイル名（フルパス）作成
        String deleteFile = anyPhotoData.filePath + '/' + anyPhotoData.photoDataList[photoIndex-1].fileName;

        // 削除対象レコードのクリア
        anyPhotoData.photoDataList[photoIndex-1] = new PhotoData();

        // ｎ件写真の場合、空情報の詰め処理（ニュースリリース、店舗は除く）
        if (anyPhotoData.photoDataList.size() > 1 && (photoType != AmazonS3Util.PhotoType.NEWSRELEASE && photoType != AmazonS3Util.PhotoType.SHOP)) {     // ポータルサイト構築 変更
            AmazonS3Util.trimPhotoData(anyPhotoData);
        }

        // AmazonS3の画像ファイル削除
        if (!Test.isRunningTest()) {
            AmazonS3Util.deleteS3File(deleteFile);
        }

        // photoTypeが間取り図の場合、位置情報ファイルも削除する。
        if(photoType == AmazonS3Util.PhotoType.PROPERTY_ROOMLAYOUT){
            String deleteFileRoomLayoutJson = AmazonS3Util.extensionConvertJson(deleteFile);
            if(String.isNotBlank(deleteFileRoomLayoutJson)){
                AmazonS3Util.deleteS3File(deleteFileRoomLayoutJson);
            }
        }

        // データ更新（対象箇所のクリア）
        AmazonS3Util.updateAnyPhotoData(anyPhotoData);
    }

    /**
     * 削除処理（物件写真全て）
     * @param  Id           targetId    物件Id
     * @return なし
     */
    public static void callPropertyPhotoDeleteAll(Id targetId) {
        List<Id> targetIdList = new List<Id>();
        targetIdList.add(targetId);
        AmazonS3Util.callPropertyPhotoDeleteAll(targetIdList);
    }
    public static void callPropertyPhotoDeleteAll(List<Id> targetIdList) {
        // 物件写真情報取得
        List<PropertyPhoto__c> propertyPhotoList = AmazonS3Util.selectPropertyPhotoData(targetIdList);

        // 物件写真内の登録されている全てのS3ファイル名（パス込）を取得
        List<String> filePathList = AmazonS3Util.getPropertyFilePathList(propertyPhotoList);

        // 削除対象がない場合処理終了
        if (filePathList.size() == 0) {
            return;
        }

        // AmazonS3の画像ファイル削除
        if (!Test.isRunningTest()) {
            AmazonS3Util.multipleDeleteS3File(filePathList);
        }

        // データ更新（物件写真の写真項目クリア）
        List<Id> propertyPhotoIdList = new List<Id>();
        for (PropertyPhoto__c propertyPhoto : propertyPhotoList) {
            propertyPhotoIdList.add(propertyPhoto.Id);
        }
        AmazonS3Util.clearPropertyPhotoData(propertyPhotoIdList);
    }

    //▼問合せNo0345で追加
    /**
     * 削除処理（物件のタイプ単位全て）
     * @param  Id           targetId    物件Id
     * @param  PhotoType    photoType   写真種類
     * @return なし
     */
    public static void callPropertyPhotoDeleteType(Id targetId,PhotoType photoType) {
        List<Id> targetIdList = new List<Id>();
        targetIdList.add(targetId);
        AmazonS3Util.callPropertyPhotoDeleteType(targetIdList,photoType);
    }
    public static void callPropertyPhotoDeleteType(List<Id> targetIdList,PhotoType photoType) {
        // 物件写真情報取得
        List<PropertyPhoto__c> propertyPhotoList = AmazonS3Util.selectPropertyPhotoData(targetIdList);

        // 物件写真内の登録されている全てのS3ファイル名（パス込）を取得
        List<String> filePathList = AmazonS3Util.getPropertyFilePathList(propertyPhotoList,photoType);

        // 削除対象がない場合処理終了
        if (filePathList.size() == 0) {
            return;
        }

        // AmazonS3の画像ファイル削除
        if (!Test.isRunningTest()) {
            AmazonS3Util.multipleDeleteS3File(filePathList);
        }

        // データ更新（物件写真の写真項目クリア）
        List<Id> propertyPhotoIdList = new List<Id>();
        for (PropertyPhoto__c propertyPhoto : propertyPhotoList) {
            propertyPhotoIdList.add(propertyPhoto.Id);
        }
        AmazonS3Util.clearPropertyPhotoData(propertyPhotoIdList,photoType);
    }
    //▲問合せNo0345で追加

    /**
     * 削除処理（建物写真と紐付く物件写真全て）
     * @param  Id           targetId    建物Id
     * @return なし
     */
    public static void callBuildingPhotoDeleteAll(Id targetId) {
        List<Id> targetIdList = new List<Id>();
        targetIdList.add(targetId);
        AmazonS3Util.callBuildingPhotoDeleteAll(targetIdList);
    }

    /**
     * 削除処理（建物写真と紐付く物件写真全て）
     * @param  List<Id>    targetIdList    建物Idのリスト
     * @return  なし
     */
    public static void callBuildingPhotoDeleteAll(List<Id> targetIdList) {
        // 対象建物に紐付く物件のIdと物件写真のId取得
        List<Id> propertyIdList      = new List<Id>();
        List<Id> propertyPhotoIdList = new List<Id>();
        List<Property__c> property = [
            SELECT
                    Id
                ,(
                SELECT
                    Id
                FROM
                    PropertyPhotoProperty__r
                )
            FROM
                Property__c
            WHERE
                Building__c IN :targetIdList
        ];
        for (Property__c record : property) {
            propertyIdList.add(record.Id);
            if (record.PropertyPhotoProperty__r.size() > 0) {
                propertyPhotoIdList.add(record.PropertyPhotoProperty__r[0].Id);
            }
        }

        // 物件写真情報取得
        List<PropertyPhoto__c> propertyPhotoList = AmazonS3Util.selectPropertyPhotoData(propertyIdList);

        // 物件写真内の登録されている全てのS3ファイル名（パス込）を取得
        List<String> propertyFilePathList = AmazonS3Util.getPropertyFilePathList(propertyPhotoList);

        // 建物写真情報取得
        List<BuildingPhoto__c> buildingPhotoList = AmazonS3Util.selectBuildingPhotoData(targetIdList);

        // 建物写真内の登録されている全てのS3ファイル名（パス込）を取得
        List<String> buildingFilePathList = AmazonS3Util.getBuildingFilePathList(buildingPhotoList);

        // 削除リストに物件のファイルを含める
        for (String fileName : propertyFilePathList) {
            buildingFilePathList.add(fileName);
        }

        // 削除対象がない場合処理終了
        if (buildingFilePathList.size() == 0) {
            return;
        }

        // AmazonS3の画像ファイル削除
        if (!Test.isRunningTest()) {
            AmazonS3Util.multipleDeleteS3File(buildingFilePathList);
        }

        // データ更新（物件写真の写真項目クリア）
        AmazonS3Util.clearPropertyPhotoData(propertyPhotoIdList);

        // データ更新（建物写真の写真項目クリア）
        List<Id> buildingPhotoIdList = new List<Id>();
        for (BuildingPhoto__c buildingPhoto : buildingPhotoList) {
            buildingPhotoIdList.add(buildingPhoto.Id);
        }
        AmazonS3Util.clearBuildingPhotoData(buildingPhotoIdList);
    }

    //▼問合せNo0345で追加
    /**
     * 削除処理（建物写真）
     * @param  Id           targetId    建物Id
     * @return なし
     */
    public static void callOnlyBuildingPhotoDeleteAll(Id targetId) {
        List<Id> targetIdList = new List<Id>();
        targetIdList.add(targetId);
        AmazonS3Util.callOnlyBuildingPhotoDeleteAll(targetIdList);    
    }
    //▲問合せNo0345で追加

    /**
     * 削除処理（建物写真）
     * @param  List<Id>    targetIdList    建物Idのリスト
     * @return  なし
     */
    public static void callOnlyBuildingPhotoDeleteAll(List<Id> targetIdList) {
        // 建物写真情報取得
        List<BuildingPhoto__c> buildingPhotoList = AmazonS3Util.selectBuildingPhotoData(targetIdList);

        // 建物写真内の登録されている全てのS3ファイル名（パス込）を取得
        List<String> buildingFilePathList = AmazonS3Util.getBuildingFilePathList(buildingPhotoList);

        // 削除対象がない場合処理終了
        if (buildingFilePathList.size() == 0) {
            return;
        }

        // AmazonS3の画像ファイル削除
        if (!Test.isRunningTest()) {
            AmazonS3Util.multipleDeleteS3File(buildingFilePathList);
        }

        // データ更新（建物写真の写真項目クリア）
        List<Id> buildingPhotoIdList = new List<Id>();
        for (BuildingPhoto__c buildingPhoto : buildingPhotoList) {
            buildingPhotoIdList.add(buildingPhoto.Id);
        }
        AmazonS3Util.clearBuildingPhotoData(buildingPhotoIdList);
    }

    // ポータルサイト構築 追加 Start
    /**
     * 削除処理（ニュースリリース写真）
     * @param  Id    targetId    ニュースリリースId
     * @return  なし
     */
    public static void callNewsReleasePhotoDeleteAll(Id targetId){
        // 削除対象データ取得
        List<NewsRelease__c> newsReleaseList = AmazonS3Util.selectNewsReleasePhotoData(targetId);
    
        // ニュースリリース削除対象取得
        List<string> newsReleasePhotoPathList = new List<String>();
        for (Integer i = 1; i <= CommonConst_ptl.MAXINDEX_NEWSRELEASE_RELEASE; i++) { 
            String filePath = S3FOLDERPATH_NEWS_RELEASE + newsReleaseList[0].ForeignID__c;
            String fileName = (String)newsReleaseList[0].get('ReleasePhotoFileName' + i + '__c');
            if (!String.isEmpty(fileName)) {
                newsReleasePhotoPathList.add(filePath + '/' + fileName);
            }
        }
        
        // 削除対象がない場合処理終了
        if (newsReleasePhotoPathList.size() == 0) {
            return;
        }
        
        // AmazonS3の画像ファイル削除
        if (!Test.isRunningTest()) {
            AmazonS3Util.multipleDeleteS3File(newsReleasePhotoPathList);
        }
    }

    /**
     * 削除処理（店舗写真）
     * @param  Id    targetId    店舗のId
     * @return  なし
     */
    public static void callShopPhotoDeleteAll(Id targetId){
        // 削除対象データ取得
        List<Shop__c> shopList = AmazonS3Util.selectShopPhotoData(targetId);
    
        // 店舗削除対象取得
        List<string> shopPhotoPathList = new List<String>();
        for (Integer i = 1; i <= CommonConst_ptl.MAXINDEX_SHOP; i++) { 
            String filePath = S3FOLDERPATH_SHOP + shopList[0].ForeignID__c;
            //▼問合せNo0535で追加　外観写真はAPI名が違うので別途設定
            String fileName = CommonConst.STRING_EMPTY;
            if(i == 9){
                fileName = (String)shopList[0].get('AppearancePhotoFileName__c');
            }else{
                fileName = (String)shopList[0].get('PhotoFileName' + i + '__c');
            }
            //▲問合せNo0535で追加
            if (!String.isEmpty(fileName)) {
                shopPhotoPathList.add(filePath + '/' + fileName);
            }
        }
        
        // 削除対象がない場合処理終了
        if (shopPhotoPathList.size() == 0) {
            return;
        }
        
        // AmazonS3の画像ファイル削除
        if (!Test.isRunningTest()) {
            AmazonS3Util.multipleDeleteS3File(shopPhotoPathList);
        }
    }
    // ポータルサイト構築 追加 End

    /**
     * 移動処理
     * @param  Id           targetMoveFromId    移動元の 物件Id or 建物Id or 学校Id or 病院Id
     * @param  Id           targetMoveToId      移動先の 物件Id or 建物Id or 学校Id or 病院Id
     * @param  PhotoType    photoType           写真種別（移動元・先）
     * @param  Integer      photoIndex          移動元の 写真インデックス（建物．周辺写真等 ｎ項目存在する場合のみ指定）
     * @return なし
     */
    public static void callPhotoMove(Id targetMoveFromId, Id targetMoveToId, PhotoType photoType) {
        AmazonS3Util.callPhotoMove(targetMoveFromId, targetMoveToId, photoType, 1);
    }
    public static void callPhotoMove(Id targetMoveFromId, Id targetMoveToId, PhotoType photoType, Integer photoIndex) {
        // 移動元インデックス初期化
        Integer moveFromIndex = photoIndex - 1;

        // 移動元（コピー元）オブジェクト取得
        AnyPhotoData moveFromAnyPhotoData = AmazonS3Util.getAnyPhotoData(targetMoveFromId, photoType);
        // 移動先（コピー先）オブジェクト取得
        AnyPhotoData moveToAnyPhotoData   = AmazonS3Util.getAnyPhotoData(targetMoveToId, photoType);

        // 移動先インデックス取得（ｎ件写真項目の場合）
        Integer moveToIndex = 0;
        if (moveToAnyPhotoData.photoDataList.size() > 1) {
            // ｎ件写真項目の場合
            for (Integer i = 0; i < moveToAnyPhotoData.photoDataList.size(); i++) {
                // 最初の空き項目のIndexを検索
                if (String.isEmpty(moveToAnyPhotoData.photoDataList[i].fileName)) {
                    moveToIndex = i;
                    break;
                }
            }
            // 移動先のｎ件全てに写真が登録済の場合、処理終了
            if (moveToIndex == 0 && !String.isEmpty(moveToAnyPhotoData.photoDataList[0].fileName)) {
                return;
            }
        }

        // 移動ファイルの拡張子取得
        String extension = AmazonS3Util.getExtension(moveFromAnyPhotoData.photoDataList[moveFromIndex].fileName);

        // 移動元ファイル名（フルパス）作成
        String moveFromFile = moveFromAnyPhotoData.filePath + '/' + moveFromAnyPhotoData.photoDataList[moveFromIndex].fileName;
        // 移動先ファイル名（フルパス）作成
        String moveToFile   = moveToAnyPhotoData.filePath   + '/' + AmazonS3Util.getNewFileName(photoType, moveToIndex, extension);
        // 移動先元ファイル名（フルパス）作成
        String moveToPrevFile = '';
        if (!String.isEmpty(moveToAnyPhotoData.photoDataList[moveToIndex].fileName)) {
            moveToPrevFile = moveToAnyPhotoData.filePath + '/' + moveToAnyPhotoData.photoDataList[moveToIndex].fileName;
        }

        // 移動元から移動先へコピー
        moveToAnyPhotoData.photoDataList[moveToIndex] = moveFromAnyPhotoData.photoDataList[moveFromIndex].clone();
        moveToAnyPhotoData.photoDataList[moveToIndex].fileName = AmazonS3Util.getFileName(moveToFile);
        // 移動元クリア
        moveFromAnyPhotoData.photoDataList[moveFromIndex] = new PhotoData();
        // クリア後ｎ件写真の場合、空情報の詰め処理
        if (moveFromAnyPhotoData.photoDataList.size() > 1) {
            AmazonS3Util.trimPhotoData(moveFromAnyPhotoData);
        }

        // 移動元から移動先へ画像ファイル移動（AmazonS3）
        if (!Test.isRunningTest()) {
            AmazonS3Util.moveS3File(moveFromFile, moveToFile, moveToPrevFile);
        }

        // データ更新（移動元のクリア）
        AmazonS3Util.updateAnyPhotoData(moveFromAnyPhotoData);
        // データ更新（移動先の更新）
        AmazonS3Util.updateAnyPhotoData(moveToAnyPhotoData);
    }

    /**
     * 複数移動処理
     * 以下をPhotoMoveMultipleParameterクラスに格納したリストで引数指定
     * @param  Id           targetMoveFromId    移動元の 物件Id or 建物Id or 学校Id or 病院Id
     * @param  Id           targetMoveToId      移動先の 物件Id or 建物Id or 学校Id or 病院Id
     * @param  PhotoType    photoType           写真種別（移動元・先）
     * @param  Integer      photoIndex          移動元の 写真インデックス（建物．周辺写真等 ｎ項目存在する場合のみ指定）
     * @return なし
     */
    public class PhotoMoveMultipleParameter {
        Id targetMoveFromId     { get; set; }
        Id targetMoveToId       { get; set; }
        PhotoType photoType     { get; set; }
        Integer photoIndex      { get; set; }
        String fromMapKey       { get; set; }   // 連続処理用のキー情報（Id＋写真種別の文字列）
        String toMapKey         { get; set; }   // 連続処理用のキー情報（Id＋写真種別の文字列）
        public PhotoMoveMultipleParameter(Id targetMoveFromId, Id targetMoveToId, PhotoType photoType) {
            this.setItems(targetMoveFromId, targetMoveToId, photoType, 1);
        }
        public PhotoMoveMultipleParameter(Id targetMoveFromId, Id targetMoveToId, PhotoType photoType, Integer photoIndex) {
            this.setItems(targetMoveFromId, targetMoveToId, photoType, photoIndex);
        }
        private void setItems(Id targetMoveFromId, Id targetMoveToId, PhotoType photoType, Integer photoIndex) {
            this.targetMoveFromId = targetMoveFromId;
            this.targetMoveToId = targetMoveToId;
            this.photoType = photoType;
            this.photoIndex = photoIndex;
            this.fromMapKey = String.valueOf(targetMoveFromId) + String.valueOf(photoType);
            this.toMapKey = String.valueOf(targetMoveToId) + String.valueOf(photoType);
        }
    }
    public static void callPhotoMoveMultiple(List<PhotoMoveMultipleParameter> paramList) {
        // 移動元・移動先の写真情報操作用のMap
        Map<String, AnyPhotoData> moveFromAnyPhotoDataMap = AmazonS3Util.getAnyPhotoData(paramList, true);
        Map<String, AnyPhotoData> moveToAnyPhotoDataMap   = AmazonS3Util.getAnyPhotoData(paramList, false);
        // 空情報の詰め処理を行う写真情報のキー保持用List
        List<String> trimTarget = new List<String>();
        // AmazonS3操作情報保持用のList群
        List<String> moveFromFileList   = new List<String>();   // 移動元ファイルパス
        List<String> moveToFileList     = new List<String>();   // 移動先ファイルパス
        List<String> moveToPrevFileList = new List<String>();   // 移動先の元ファイルパス
        // sfオブジェクト更新対象保持用のList
        List<AnyPhotoData> updatePhotoData = new List<AnyPhotoData>();

        for (PhotoMoveMultipleParameter param : paramList) {
            // 移動元インデックス初期化
            Integer moveFromIndex = param.photoIndex - 1;

            // 移動元（コピー元）オブジェクト取得
            AnyPhotoData moveFromAnyPhotoData = moveFromAnyPhotoDataMap.get(param.fromMapKey).clone();
            // 移動先（コピー先）オブジェクト取得
            AnyPhotoData moveToAnyPhotoData = moveToAnyPhotoDataMap.get(param.toMapKey).clone();

            // 移動先インデックス取得（ｎ件写真項目の場合）
            Integer moveToIndex = 0;
            if (moveToAnyPhotoData.photoDataList.size() > 1) {
                // ｎ件写真項目の場合
                for (Integer i = 0; i < moveToAnyPhotoData.photoDataList.size(); i++) {
                    // 最初の空き項目のIndexを検索
                    if (String.isEmpty(moveToAnyPhotoData.photoDataList[i].fileName)) {
                        moveToIndex = i;
                        break;
                    }
                }
                // 移動先のｎ件全てに写真が登録済の場合、処理終了
                if (moveToIndex == 0 && !String.isEmpty(moveToAnyPhotoData.photoDataList[0].fileName)) {
                    break;
                }
            }

            // 移動ファイルの拡張子取得
            String extension = AmazonS3Util.getExtension(moveFromAnyPhotoData.photoDataList[moveFromIndex].fileName);

            // 移動元ファイル名（フルパス）作成
            String moveFromFile = moveFromAnyPhotoData.filePath + '/' + moveFromAnyPhotoData.photoDataList[moveFromIndex].fileName;
            moveFromFileList.add(moveFromFile);
            // 移動先ファイル名（フルパス）作成
            String moveToFile   = moveToAnyPhotoData.filePath   + '/' + AmazonS3Util.getNewFileName(param.photoType, moveToIndex, extension);
            moveToFileList.add(moveToFile);
            // 移動先元ファイル名（フルパス）作成
            String moveToPrevFile = '';
            if (!String.isEmpty(moveToAnyPhotoData.photoDataList[moveToIndex].fileName)) {
                moveToPrevFile = moveToAnyPhotoData.filePath + '/' + moveToAnyPhotoData.photoDataList[moveToIndex].fileName;
            }
            moveToPrevFileList.add(moveToPrevFile);

            // 移動元から移動先へコピー
            moveToAnyPhotoData.photoDataList[moveToIndex] = moveFromAnyPhotoData.photoDataList[moveFromIndex].clone();
            moveToAnyPhotoData.photoDataList[moveToIndex].fileName = AmazonS3Util.getFileName(moveToFile);
            // 移動元クリア
            moveFromAnyPhotoData.photoDataList[moveFromIndex] = new PhotoData();
            // クリア後ｎ件写真の場合、空情報の詰め処理の対象として保存しておく
            if (moveFromAnyPhotoData.photoDataList.size() > 1) {
                trimTarget.add(param.fromMapKey);
            }

            // 処理結果をMapに格納
            moveFromAnyPhotoDataMap.put(param.fromMapKey, moveFromAnyPhotoData.clone());
            moveToAnyPhotoDataMap.put(param.toMapKey, moveToAnyPhotoData.clone());

        }

        // クリア後ｎ件写真の場合、空情報の詰め処理
        for (String key : trimTarget) {
            AnyPhotoData tempAnyPhotoData = moveFromAnyPhotoDataMap.get(key);
            AmazonS3Util.trimPhotoData(tempAnyPhotoData);
            moveFromAnyPhotoDataMap.put(key, tempAnyPhotoData.clone());
        }


        // 移動元から移動先へ画像ファイル移動（AmazonS3）
        if (!Test.isRunningTest()) {
            AmazonS3Util.multipleMoveS3File(moveFromFileList, moveToFileList, moveToPrevFileList);
        }

        // データ更新（移動元のクリア）/データ更新（移動先の更新）
        for (String key : moveFromAnyPhotoDataMap.keySet()) {
            updatePhotoData.add(moveFromAnyPhotoDataMap.get(key));
        }
        for (String key : moveToAnyPhotoDataMap.keySet()) {
            updatePhotoData.add(moveToAnyPhotoDataMap.get(key));
        }
        AmazonS3Util.updateAnyPhotoData(updatePhotoData);
    }

    /**
     * 移動処理
     * @param  String       targetMoveFromS3Path    移動元の AmazonS3のファイルパス ※バケット名以降からファイル名までの文字列
     * @param  Id           targetMoveToId          移動先の 物件Id or 建物Id or 学校Id or 病院Id
     * @param  PhotoType    photoType               写真種別（移動元・先）
     * @param  Integer      photoMoveToIndex        移動先の 写真インデックス（建物．周辺写真等 ｎ項目存在する場合のみ指定）
     * @return なし
     */
    public static void callPhotoMoveFromS3(String targetMoveFromS3Path, Id targetMoveToId, PhotoType photoType) {
        AmazonS3Util.callPhotoMoveFromS3(targetMoveFromS3Path, targetMoveToId, photoType, 0);
    }
    public static void callPhotoMoveFromS3(String targetMoveFromS3Path, Id targetMoveToId, PhotoType photoType, Integer photoMoveToIndex) {
        // 移動先（コピー先）オブジェクト取得
        AnyPhotoData moveToAnyPhotoData   = AmazonS3Util.getAnyPhotoData(targetMoveToId, photoType);

        Integer moveToIndex = photoMoveToIndex;
        if (moveToIndex > 0) {
            moveToIndex--;
        }
        // 移動先インデックスがｎ件の範囲外の場合、処理終了
        if (moveToIndex > moveToAnyPhotoData.photoDataList.size()) {
            return;
        }
        // 移動先の指定がない場合インデックス取得（ｎ件写真項目の場合）
        if (moveToIndex == 0
            && moveToAnyPhotoData.photoDataList.size() > 1) {
            // ｎ件写真項目の場合
            for (Integer i = 0; i < moveToAnyPhotoData.photoDataList.size(); i++) {
                // 最初の空き項目のIndexを検索
                if (String.isEmpty(moveToAnyPhotoData.photoDataList[i].fileName)) {
                    moveToIndex = i;
                    break;
                }
            }
            // 移動先のｎ件全てに写真が登録済の場合、処理終了
            if (moveToIndex == 0 && !String.isEmpty(moveToAnyPhotoData.photoDataList[0].fileName)) {
                return;
            }
        }

        // 移動ファイルの拡張子取得
        String extension = AmazonS3Util.getExtension(targetMoveFromS3Path);

        // 移動先ファイル名（フルパス）作成
        String moveToFile   = moveToAnyPhotoData.filePath + '/' + AmazonS3Util.getNewFileName(photoType, moveToIndex, extension);
        // 移動先元ファイル名（フルパス）作成
        String moveToPrevFile = '';
        if (!String.isEmpty(moveToAnyPhotoData.photoDataList[moveToIndex].fileName)) {
            moveToPrevFile = moveToAnyPhotoData.filePath + '/' + moveToAnyPhotoData.photoDataList[moveToIndex].fileName;
        }

        // 移動先にファイル名設定
        moveToAnyPhotoData.photoDataList[moveToIndex].fileName = AmazonS3Util.getFileName(moveToFile);

        // 移動元から移動先へ画像ファイル移動（AmazonS3）
        if (!Test.isRunningTest()) {
            AmazonS3Util.moveS3File(targetMoveFromS3Path, moveToFile, moveToPrevFile);
        }

        // データ更新（移動先の更新）
        AmazonS3Util.updateAnyPhotoData(moveToAnyPhotoData);
    }
    /**
     * 複数移動処理
     * 以下をPhotoMoveFromS3MultipleParameterクラスに格納したリストで引数指定
     * @param  String       targetMoveFromS3Path    移動元の AmazonS3のファイルパス ※バケット名以降からファイル名までの文字列
     * @param  Id           targetMoveToId          移動先の 物件Id or 建物Id or 学校Id or 病院Id
     * @param  PhotoType    photoType               写真種別（移動元・先）
     * @param  Integer      photoMoveToIndex        移動先の 写真インデックス（建物．周辺写真等 ｎ項目存在する場合のみ指定）
     * @return なし
     */
    public class PhotoMoveFromS3MultipleParameter {
        String targetMoveFromS3Path { get; set; }
        Id targetMoveToId           { get; set; }
        PhotoType photoType         { get; set; }
        Integer photoMoveToIndex    { get; set; }
        String targetMoveToTag      { get; set; }
        String targetMoveToComment  { get; set; }
        String toMapKey             { get; set; }   // 連続処理用のキー情報（Id＋写真種別の文字列）
        public PhotoMoveFromS3MultipleParameter(String targetMoveFromS3Path, Id targetMoveToId, PhotoType photoType) {
            this.setItems(targetMoveFromS3Path, targetMoveToId, photoType, 0);
        }
        public PhotoMoveFromS3MultipleParameter(String targetMoveFromS3Path, Id targetMoveToId, PhotoType photoType, Integer photoMoveToIndex) {
            this.setItems(targetMoveFromS3Path, targetMoveToId, photoType, photoMoveToIndex);
        }
        public PhotoMoveFromS3MultipleParameter(String targetMoveFromS3Path, Id targetMoveToId, PhotoType photoType, String tag, String comment) {
            this.setItems(targetMoveFromS3Path, targetMoveToId, photoType, 0, tag, comment);
        }
        public PhotoMoveFromS3MultipleParameter(String targetMoveFromS3Path, Id targetMoveToId, PhotoType photoType, Integer photoMoveToIndex, String tag, String comment) {
            this.setItems(targetMoveFromS3Path, targetMoveToId, photoType, photoMoveToIndex, tag, comment);
        }
        private void setItems(String targetMoveFromS3Path, Id targetMoveToId, PhotoType photoType, Integer photoMoveToIndex) {
            this.setItems(targetMoveFromS3Path, targetMoveToId, photoType, photoMoveToIndex, CommonConst.STRING_EMPTY, commonConst.STRING_EMPTY);
        }
        private void setItems(String targetMoveFromS3Path, Id targetMoveToId, PhotoType photoType, Integer photoMoveToIndex, String tag, String comment) {
            this.targetMoveFromS3Path   = targetMoveFromS3Path;
            this.targetMoveToId         = targetMoveToId;
            this.photoType              = photoType;
            this.photoMoveToIndex       = photoMoveToIndex;
            this.toMapKey               = String.valueOf(targetMoveToId) + String.valueOf(photoType);
            this.targetMoveToTag        = tag;
            this.targetMoveToComment    = comment;
        }
    }
    public static void callPhotoMoveFromS3Multiple(List<PhotoMoveFromS3MultipleParameter> paramList) {
        // 移動先（コピー先）の写真情報操作用のMap
        Map<String, AnyPhotoData> moveToAnyPhotoDataMap = AmazonS3Util.getAnyPhotoData(paramList);
        // AmazonS3操作情報保持用のList群
        List<String> moveFromFileList   = new List<String>();   // 移動元ファイルパス
        List<String> moveToFileList     = new List<String>();   // 移動先ファイルパス
        List<String> moveToPrevFileList = new List<String>();   // 移動先の元ファイルパス
        // sfオブジェクト更新対象保持用のList
        List<AnyPhotoData> updatePhotoData = new List<AnyPhotoData>();

        for (PhotoMoveFromS3MultipleParameter param : paramList) {

            // 移動先（コピー先）オブジェクト取得
            AnyPhotoData moveToAnyPhotoData = moveToAnyPhotoDataMap.get(param.toMapKey).clone();

            // 移動先インデックス取得（ｎ件写真項目の場合）
            Integer moveToIndex = param.photoMoveToIndex;
            if (moveToIndex > 0) {
                moveToIndex--;
            }
            // 移動先インデックスがｎ件の範囲外の場合、処理終了（次のレコード）
            if (moveToIndex > moveToAnyPhotoData.photoDataList.size()) {
                continue;
            }
            // 移動先の指定がない場合インデックス取得（ｎ件写真項目の場合）
            if (moveToIndex == 0
                && moveToAnyPhotoData.photoDataList.size() > 1) {
                // ｎ件写真項目の場合
                for (Integer i = 0; i < moveToAnyPhotoData.photoDataList.size(); i++) {
                    // 最初の空き項目のIndexを検索
                    if (String.isEmpty(moveToAnyPhotoData.photoDataList[i].fileName)) {
                        moveToIndex = i;
                        break;
                    }
                }
                // 移動先のｎ件全てに写真が登録済の場合、処理終了（次のレコード）
                if (moveToIndex == 0 && !String.isEmpty(moveToAnyPhotoData.photoDataList[0].fileName)) {
                    continue;
                }
            }

            // 移動ファイルの拡張子取得
            String extension = AmazonS3Util.getExtension(param.targetMoveFromS3Path);

            // 移動元ファイル名（フルパス）作成
            moveFromFileList.add(param.targetMoveFromS3Path);
            // 移動先ファイル名（フルパス）作成
            String moveToFile   = moveToAnyPhotoData.filePath   + '/' + AmazonS3Util.getNewFileName(param.photoType, moveToIndex, extension);
            moveToFileList.add(moveToFile);
            // 移動先元ファイル名（フルパス）作成
            String moveToPrevFile = '';
            if (!String.isEmpty(moveToAnyPhotoData.photoDataList[moveToIndex].fileName)) {
                moveToPrevFile = moveToAnyPhotoData.filePath + '/' + moveToAnyPhotoData.photoDataList[moveToIndex].fileName;
            }
            moveToPrevFileList.add(moveToPrevFile);

            // 移動先に設定
            moveToAnyPhotoData.photoDataList[moveToIndex].fileName = AmazonS3Util.getFileName(moveToFile);
            if (!String.isEmpty(param.targetMoveToTag)) {
                moveToAnyPhotoData.photoDataList[moveToIndex].tag     = param.targetMoveToTag;
            }
            if (!String.isEmpty(param.targetMoveToComment)) {
                moveToAnyPhotoData.photoDataList[moveToIndex].comment = param.targetMoveToComment;
            }
        }
        // 移動元から移動先へ画像ファイル移動（AmazonS3）
        if (!Test.isRunningTest()) {
            AmazonS3Util.multipleMoveS3File(moveFromFileList, moveToFileList, moveToPrevFileList);
        }

        // データ更新（移動先の更新）
        for (String key : moveToAnyPhotoDataMap.keySet()) {
            updatePhotoData.add(moveToAnyPhotoDataMap.get(key));
        }
        AmazonS3Util.updateAnyPhotoData(updatePhotoData);

    }

    /**
     * 自動メンテナンス差分用ファイル移動処理
     * 以下をAutoMaintePhotoMoveParameterクラスに格納したリストで引数指定
     * @param  String       targetMoveFromPath      移動元のファイルフルパス
     * @param  String       targetMoveToTag         設定するタグ
     * @param  String       targetMoveToComment     設定する
     * @param  String       targetMoveToPath        移動先のファイルフルパス
     * @param  String       targetMoveFileName      移動先のファイル名
     * @param  String       targeMoveToIndex        移動先のIndex   ※建物.周辺写真など
     * @param  String       targetPhotoType         写真タイプ
     * @param  String       isError                 エラーフラグ
     * @param  String       errorMsg                エラーメッセージ
     * @return なし
     */
    public class AutoMaintePhotoMoveDataParameter {
        public String targetMoveFromPath   { get; set; }   // 移動元
        public String targetMoveToTag      { get; set; }   // タグ
        public String targetMoveToComment  { get; set; }   // コメント
        public String targetMoveToPath     { get; set; }   // 移動先
        public String targetMoveFileName   { get; set; }   // 移動先ファイル名
        public Integer targeMoveToIndex    { get; set; }   // Index
        public PhotoType targetPhotoType   { get; set; }   // 写真タイプ
        public Boolean isError             { get; set; }   // エラーフラグ
        public String errorMsg             { get; set; }   // エラーメッセージ
        public AutoMaintePhotoMoveDataParameter(String fromPath, String toComment, String toTag, PhotoType photoType) {
            this.setItems(fromPath, toComment, toTag, 0, photoType);
        }
        public AutoMaintePhotoMoveDataParameter(String fromPath, String toComment, String toTag, Integer toIndex, PhotoType photoType) {
            setItems(fromPath, toComment, toTag, toIndex, photoType);
        }
        private void setItems(String fromPath, String toComment, String toTag, Integer toIndex, PhotoType photoType) {
            this.targetMoveFromPath  = fromPath;
            this.targetMoveToTag     = toTag;
            this.targetMoveToComment = toComment;
            this.targeMoveToIndex    = toIndex;
            this.targetPhotoType     = photoType;
            this.isError             = false;
            this.errorMsg            = CommonConst.STRING_EMPTY;
        }
    }
    public class AutoMaintePhotoMoveParameter {
        public Id targetMoveToId           { get; set; }    // 建物Id, 物件Id
        public String foreignId            { get; set; }    // 建物.外部ID or 建物.外部ID + 物件.外部ID
        public Boolean isError             { get; set; }    // エラーフラグ
        public String errorMsg             { get; set; }    // エラーメッセージ
        public List<AmazonS3Util.AutoMaintePhotoMoveDataParameter> photoList { get; set; }  // 写真データ
        public t_auto_maintenance_difference__c autoMainteDiff               { get; set; }  // 自動メンテナンス差分
        public AutoMaintePhotoMoveParameter() {
            this.photoList      = new List<AmazonS3Util.AutoMaintePhotoMoveDataParameter>();
        }
        public AutoMaintePhotoMoveParameter(Id moveToId, String foreignId, t_auto_maintenance_difference__c autoMainteDiff) {
            this.targetMoveToId = moveToId;
            this.foreignId      = foreignId;
            this.autoMainteDiff = autoMainteDiff;
            this.isError        = false;
            this.errorMsg       = CommonConst.STRING_EMPTY;
            this.photoList      = new List<AmazonS3Util.AutoMaintePhotoMoveDataParameter>();
        }
    }
    public static void callPhotoMoveAutoMainte(List<AutoMaintePhotoMoveParameter> paramList) {
        // 移動情報設定
        for (AutoMaintePhotoMoveParameter param : paramList) {
            for (AutoMaintePhotoMoveDataParameter movePhoto : param.photoList) { 
                // 移動元ファイル名
                if (!String.isEmpty(movePhoto.targetMoveFromPath)) {
                    String extension = AmazonS3Util.getExtension(movePhoto.targetMoveFromPath);
                    movePhoto.targetMoveFileName = AmazonS3Util.getNewFileName(movePhoto.targetPhotoType, movePhoto.targeMoveToIndex, extension);
                }

                // 移動先ファイルパス
                if (!String.isEmpty(movePhoto.targetMoveFileName)) {
                    movePhoto.targetMoveToPath   = S3FOLDERPATH_BUILDING_PROPERTY + param.foreignId   + '/' + movePhoto.targetMoveFileName;
                }
            }
        }
        // 写真移動
        AmazonS3Util.moveS3FileAutoMainte(paramList);

        // 建物写真・物件写真のデータ作成
        AmazonS3Util.upsertBuildingPropertyAutoMainteDiff(paramList);
    }

    //▼問合せNo0573で変更
    /**
     * ファイルパスからファイル名の取得
     * @param  String       filePath    ファイルパス
     * @return String       ファイル名
     */
    public static String getFileName(String filePath) {
        Integer lastSlIndex = filePath.lastIndexOf('/');
        String fileName = '';
        if (lastSlIndex >= 0) {
            fileName = filePath.substring(lastSlIndex+1);
        }
        return fileName;
    }
    //▲問合せNo0573で変更

    /**
     * AmazonS3のオブジェクト複数移動命令の同期実行
     */
    private static void moveS3FileAutoMainte(List<AutoMaintePhotoMoveParameter> paramList) {
        // ファイル移動
        for (AutoMaintePhotoMoveParameter param : paramList) {
            for (AutoMaintePhotoMoveDataParameter movePhoto : param.photoList) {
                if (!String.isBlank(movePhoto.targetMoveFromPath) && !String.isBlank(movePhoto.targetMoveToPath)) {
                    try {
                        HTTPResponse response = AmazonS3Util.callCopyReqest(movePhoto.targetMoveFromPath, movePhoto.targetMoveToPath);
                        if (response.getStatusCode() != 200 && response.getStatusCode() != 404) {
                            movePhoto.isError  = true;
                            movePhoto.errorMsg = '写真のコピーに失敗しました。' + response.getStatus();
                        }
                    } catch (Exception e) {
                        movePhoto.isError  = true;
                        movePhoto.errorMsg = e.getMessage();
                    }
                }
            }
        }

        // 写真をバックアップする為、一時的にコメントアウト
        // // 削除
        // List<String> deletePathList = new List<String>();
        // for (AutoMaintePhotoMoveParameter param : paramList) {
        //     for (AutoMaintePhotoMoveDataParameter movePhoto : param.photoList) {
        //         if (!movePhoto.isError && !String.isBlank(movePhoto.targetMoveFromPath) && !String.isBlank(movePhoto.targetMoveToPath)) {
        //             deletePathList.add(movePhoto.targetMoveFromPath);
        //         }
        //     }
        // }
        // if (deletePathList.size() > 0) {
        //     try {
        //         HTTPResponse response = AmazonS3Util.callMultipleDeleteReqest(deletePathList);
        //         if (response.getStatusCode() != 200) {
        //             for (AutoMaintePhotoMoveParameter param : paramList) {
        //                 param.isError  = true;
        //                 param.errorMsg = response.getStatus();
        //             }
        //         }
        //     } catch(Exception e) {
        //         for (AutoMaintePhotoMoveParameter param : paramList) {
        //             param.isError  = true;
        //             param.errorMsg = '写真の削除に失敗しました。' + e.getMessage();
        //         }
        //     }
        // }
        // 写真をバックアップする為、一時的にコメントアウト
    }

    /**
     * 建物写真・物件写真作成（自動メンテナンス用）
     * 
     */
    private static void upsertBuildingPropertyAutoMainteDiff(List<AutoMaintePhotoMoveParameter> paramList) {
        Set<Id> targetSetId = new Set<Id>();
        Map<Id, BuildingPhoto__c> buildingPhotoMap = new Map<Id, BuildingPhoto__c>();
        Map<Id, PropertyPhoto__c> propPhotoMap     = new Map<Id, PropertyPhoto__c>();

        // 移動先（コピー先）の写真情報操作用のMap
        for (AutoMaintePhotoMoveParameter param : paramList) {
            targetSetId.add(param.targetMoveToId);
        }

        // 建物写真・物件写真取得
        List<BuildingPhoto__c> buildingPhotoList = selectBildingPhotoBuildingId(targetSetId);
        List<PropertyPhoto__c> propPhotoList     = selectPropertyPhotoPropertyId(targetSetId);

        // Map作成
        for (BuildingPhoto__c obj : buildingPhotoList){
            buildingPhotoMap.put(obj.Building__c, obj);
        }
        for (PropertyPhoto__c obj : propPhotoList) {
            propPhotoMap.put(obj.Property__c, obj);
        }

        // 登録データ作成
        for (AutoMaintePhotoMoveParameter param : paramList) {
            for (AutoMaintePhotoMoveDataParameter movePhoto : param.photoList) { 

                //  エラーが出ていたら次ループ ※コピーエラー
                if (movePhoto.isError) {
                    continue;
                }

                switch on movePhoto.targetPhotoType {
                    when PROPERTY
                        ,PROPERTY_PRIVATE
                        ,PROPERTY_PANORAMA
                        ,PROPERTY_ROOMLAYOUT
                        ,PROPERTY_ROOMLAYOUTMEMO {
                        if (!propPhotoMap.containsKey(param.targetMoveToId)) {
                            PropertyPhoto__c propPhoto = new PropertyPhoto__c(Property__c = param.targetMoveToId);
                            propPhotoMap.put(param.targetMoveToId, propPhoto);
                        }
                    }
                    when BUILDING_APPEARANCE
                        ,BUILDING_APPEARANCEPARSE
                        ,BUILDING_ENTRANCE
                        ,BUILDING_LOBBY
                        ,BUILDING_PARKING
                        ,BUILDING_OTHERSHARING
                        ,BUILDING_MAP
                        ,BUILDING_OTHER
                        ,BUILDING_SURROUNDING {
                        if (!BuildingPhotoMap.containsKey(param.targetMoveToId)) {
                            BuildingPhoto__c propPhoto = new BuildingPhoto__c(Building__c = param.targetMoveToId);
                            buildingPhotoMap.put(param.targetMoveToId, propPhoto);
                        }
                    }
                }

                switch on movePhoto.targetPhotoType {
                    when PROPERTY {
                        // 物件写真
                        propPhotoMap.get(param.targetMoveToId).put('PropertyPhotoFileName' + movePhoto.targeMoveToIndex + '__c',  movePhoto.targetMoveFileName);
                        propPhotoMap.get(param.targetMoveToId).put('PropertyPhotoTag'      +  movePhoto.targeMoveToIndex + '__c', movePhoto.targetMoveToTag);
                        propPhotoMap.get(param.targetMoveToId).put('PropertyPhotoComment'  +  movePhoto.targeMoveToIndex + '__c', movePhoto.targetMoveToComment);			
                        propPhotoMap.get(param.targetMoveToId).put('PropertyPhotoLastModifiedDate__c',CommonUtil.getNow()); //問合せNo.0773 対応 2022/04/25
                    }
                    when PROPERTY_PRIVATE {
                        // 物件非公開
                        propPhotoMap.get(param.targetMoveToId).put('PrivatePhotoFileName' + movePhoto.targeMoveToIndex + '__c',  movePhoto.targetMoveFileName);
                        propPhotoMap.get(param.targetMoveToId).put('PrivatePhotoType'     +  movePhoto.targeMoveToIndex + '__c', movePhoto.targetMoveToTag);
                        propPhotoMap.get(param.targetMoveToId).put('PrivatePhotoComment'  +  movePhoto.targeMoveToIndex + '__c', movePhoto.targetMoveToComment);
                    }
                    when PROPERTY_PANORAMA {
                        // 物件パノラマ
                        propPhotoMap.get(param.targetMoveToId).put('PanoramaFileName' + movePhoto.targeMoveToIndex + '__c',  movePhoto.targetMoveFileName);
                        propPhotoMap.get(param.targetMoveToId).put('PanoramaTag'      +  movePhoto.targeMoveToIndex + '__c', movePhoto.targetMoveToTag);
                        propPhotoMap.get(param.targetMoveToId).put('PanoramaComment'  +  movePhoto.targeMoveToIndex + '__c', movePhoto.targetMoveToComment);
                    }
                    when PROPERTY_ROOMLAYOUT {
                        // 物件間取り図
                        propPhotoMap.get(param.targetMoveToId).RoomLayoutFileName__c = movePhoto.targetMoveFileName;
                    }
                    when PROPERTY_ROOMLAYOUTMEMO {
                        // 物件間取り図（メモ有）
                        propPhotoMap.get(param.targetMoveToId).RoomLayoutMemoFileName__c = movePhoto.targetMoveFileName;
                    }
                    when BUILDING_APPEARANCE {
                        // 建物外観
                        buildingPhotoMap.get(param.targetMoveToId).AppearanceFileName__c = movePhoto.targetMoveFileName;
                        buildingPhotoMap.get(param.targetMoveToId).AppearanceComment__c  = movePhoto.targetMoveToComment;
                    }
                    when BUILDING_APPEARANCEPARSE {
                        // 建物外観パース
                        buildingPhotoMap.get(param.targetMoveToId).AppearanceParseFileName__c = movePhoto.targetMoveFileName;
                        buildingPhotoMap.get(param.targetMoveToId).AppearanceParseComment__c  = movePhoto.targetMoveToComment;
                    }
                    when BUILDING_ENTRANCE {
                        // 建物エントランス
                        buildingPhotoMap.get(param.targetMoveToId).EntranceFileName__c = movePhoto.targetMoveFileName;
                        buildingPhotoMap.get(param.targetMoveToId).EntranceComment__c  = movePhoto.targetMoveToComment;
                    }
                    when BUILDING_LOBBY {
                        // 建物ロビー
                        buildingPhotoMap.get(param.targetMoveToId).LobbyFileName__c = movePhoto.targetMoveFileName;
                        buildingPhotoMap.get(param.targetMoveToId).LobbyComment__c  = movePhoto.targetMoveToComment;
                    }
                    when BUILDING_PARKING {
                        // 建物駐車場
                        buildingPhotoMap.get(param.targetMoveToId).ParkingFileName__c = movePhoto.targetMoveFileName;
                        buildingPhotoMap.get(param.targetMoveToId).ParkingComment__c  = movePhoto.targetMoveToComment;
                    }
                    when BUILDING_OTHERSHARING {
                        // 建物その他共有
                        buildingPhotoMap.get(param.targetMoveToId).OtherSharingFileName__c = movePhoto.targetMoveFileName;
                        buildingPhotoMap.get(param.targetMoveToId).OtherSharingComment__c  = movePhoto.targetMoveToComment;
                    }
                    when BUILDING_MAP {
                        // 建物地図
                        buildingPhotoMap.get(param.targetMoveToId).MapFileName__c = movePhoto.targetMoveFileName;
                        buildingPhotoMap.get(param.targetMoveToId).MapComment__c  = movePhoto.targetMoveToComment;
                    }
                    when BUILDING_OTHER {
                        // 建物その他
                        buildingPhotoMap.get(param.targetMoveToId).OtherFileName__c = movePhoto.targetMoveFileName;
                        buildingPhotoMap.get(param.targetMoveToId).OtherComment__c  = movePhoto.targetMoveToComment;
                    }
                    when BUILDING_SURROUNDING {
                        // 建物周辺
                        buildingPhotoMap.get(param.targetMoveToId).put('SurroundingFileName' + movePhoto.targeMoveToIndex + '__c',  movePhoto.targetMoveFileName);
                        buildingPhotoMap.get(param.targetMoveToId).put('SurroundingTag'      +  movePhoto.targeMoveToIndex + '__c', movePhoto.targetMoveToTag);
                        buildingPhotoMap.get(param.targetMoveToId).put('SurroundingComment'  +  movePhoto.targeMoveToIndex + '__c', movePhoto.targetMoveToComment);
                    }
                }
            }
        }
        if (propPhotoMap.size() > 0) {
            SecureDML.secureUpsert(propPhotoMap.values());
        }
        if (buildingPhotoMap.size() > 0) {
            SecureDML.secureUpsert(buildingPhotoMap.values());
        }
    }

    /**
     * ファイル名から拡張子の取得
     * @param  String       fileName    ファイル名
     * @return String       拡張子（.jpg 等）
     */
    private static String getExtension(String fileName) {
        Integer lastCommaIndex = fileName.lastIndexOf('.');
        String extension = '';
        if (lastCommaIndex >= 0) {
            extension = fileName.substring(lastCommaIndex);
        }
        return extension;
    }

    /**
     * ファイル名生成
     * @param  PhotoType    photoType       写真種別
     * @param  Integer      photoIndex      写真インデックス（ｎ項目写真以外の場合0）
     * @param  String       extension       拡張子（.jpg 等）
     * @return String       生成ファイル名
     */
    private static String getNewFileName(PhotoType photoType, Integer photoIndex, String extension) {
        String fileName = '';
        Integer index = 0;
        switch on photoType {
            when PROPERTY {                 // 物件
                fileName += CommonCONST.S3_PROPERTYPHOTOTYPE_PROPERTPHOTO;
                index = photoIndex + 1;
            }
            when PROPERTY_PRIVATE {         // 物件非公開
                fileName += CommonCONST.S3_PROPERTYPHOTOTYPE_PRIVATEPHOTO;
                index = photoIndex + 1;
            }
            when PROPERTY_PANORAMA {        // 物件パノラマ
                fileName += CommonCONST.S3_PROPERTYPHOTOTYPE_PANORAMA;
                index = photoIndex + 1;
            }
            when PROPERTY_ROOMLAYOUT {      // 間取り図
                fileName += CommonCONST.S3_PROPERTYPHOTOTYPE_ROOMLAYOUT;
            }
            when PROPERTY_ROOMLAYOUTMEMO {  // 間取り図（メモ有）
                fileName += CommonCONST.S3_PROPERTYPHOTOTYPE_ROOMLAYOUTMEMO;
            }
            when BUILDING_APPEARANCE {      // 建物外観
                fileName += CommonCONST.S3_BUILDINGPHOTOTYPE_APPEARANCE;
            }
            when BUILDING_APPEARANCEPARSE { // 建物外観パース
                fileName += CommonCONST.S3_BUILDINGPHOTOTYPE_APPEARANCE_PARSE;
            }
            when BUILDING_ENTRANCE {        // 建物エントランス
                fileName += CommonCONST.S3_BUILDINGPHOTOTYPE_ENTRANCE;
            }
            when BUILDING_LOBBY {           // 建物ロビー
                fileName += CommonCONST.S3_BUILDINGPHOTOTYPE_LOBBY;
            }
            when BUILDING_PARKING {         // 建物駐車場
                fileName += CommonCONST.S3_BUILDINGPHOTOTYPE_PARKING;
            }
            when BUILDING_OTHERSHARING {    // 建物その他共有
                fileName += CommonCONST.S3_BUILDINGPHOTOTYPE_OTHERSHARING;
            }
            when BUILDING_MAP {             // 建物地図
                fileName += CommonCONST.S3_BUILDINGPHOTOTYPE_MAP;
            }
            when BUILDING_OTHER {           // 建物その他
                fileName += CommonCONST.S3_BUILDINGPHOTOTYPE_OTHER;
            }
            when BUILDING_SURROUNDING {     // 建物周辺
                fileName += CommonCONST.S3_BUILDINGPHOTOTYPE_SURROUNDING;
                index = photoIndex + 1;
            }
            when SCHOOL {                   // 学校
                fileName += '';
            }
            when HOSPITAL {                 // 病院
                fileName += '';
            }
        }
        fileName += String.valueOf(index).leftPad(2, '0');
        DateTime now = CommonUtil.getNow();
        fileName += now.format('yyyyMMddhhmmss');
        fileName += extension;
        return fileName;
    }

    // 写真情報内部クラス
    private class PhotoData {
        public String fileName      { get; set; }   // ファイル名
        public String tag           { get; set; }   // タグ
        public String comment       { get; set; }   // コメント
        public String photoName     { get; set; }   // 写真名       ※建物写真．周辺写真 独自
        public Decimal distance     { get; set; }   // 距離         ※建物写真．周辺写真 独自
    }
    // 写真情報処理用内部クラス
    private class AnyPhotoData {
        public Id Id                { get; set; }   // Id
        public String foreignId     { get; set; }   // 外部Id
        public PhotoType photoType  { get; set; }   // 写真種別
        public String filePath      { get; set; }   // フォルダ名
        public List<PhotoData> photoDataList { get; set; }  // 写真情報
        public AnyPhotoData() {
            // 初期化
            this.photoDataList  = new List<PhotoData>();
        }
        // コンストラクタ（物件写真）
        public AnyPhotoData(PropertyPhoto__c propertyPhoto, PhotoType photoType) {
            // 初期化
            this.photoDataList  = new List<PhotoData>();
            // データセット
            this.Id         = propertyPhoto.Id;
            this.photoType  = photoType;
            this.foreignId  = propertyPhoto.Property__r.Building__r.ForeignID__c + '/' + propertyPhoto.Property__r.ForeignID__c;
            this.filePath   = S3FOLDERPATH_BUILDING_PROPERTY + this.foreignId;
            PhotoData data = new photoData();
            switch on photoType {
                when PROPERTY {
                    // 物件写真
                    for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PROPERTY; i++) {
                        data = new photoData();
                        data.fileName   = (String)propertyPhoto.get('PropertyPhotoFileName' + i + '__c');
                        data.tag        = (String)propertyPhoto.get('PropertyPhotoTag' + i + '__c');
                        data.comment    = (String)propertyPhoto.get('PropertyPhotoComment' + i + '__c');
                        this.photoDataList.add(data);
                    }
                }
                when PROPERTY_PRIVATE {
                    // 物件非公開写真
                    for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PRIVATE; i++) {
                        data = new photoData();
                        data.fileName   = (String)propertyPhoto.get('PrivatePhotoFileName' + i + '__c');
                        data.tag        = (String)propertyPhoto.get('PrivatePhotoType' + i + '__c');
                        data.comment    = (String)propertyPhoto.get('PrivatePhotoComment' + i + '__c');
                        this.photoDataList.add(data);
                    }
                }
                when PROPERTY_PANORAMA {
                    // 物件パノラマ写真
                    for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PANORAMA; i++) {
                        data = new photoData();
                        data.fileName   = (String)propertyPhoto.get('PanoramaFileName' + i + '__c');
                        data.tag        = (String)propertyPhoto.get('PanoramaTag' + i + '__c');
                        data.comment    = (String)propertyPhoto.get('PanoramaComment' + i + '__c');
                        this.photoDataList.add(data);
                    }
                }
                when PROPERTY_ROOMLAYOUT {
                    // 間取り図
                    data.fileName   = propertyPhoto.RoomLayoutFileName__c;
                    this.photoDataList.add(data);
                }
                when PROPERTY_ROOMLAYOUTMEMO {
                    // 間取り図（メモ有）
                    data.fileName   = propertyPhoto.RoomLayoutMemoFileName__c;
                    this.photoDataList.add(data);
                }
            }
        }
        // コンストラクタ（建物写真）
        public AnyPhotoData(BuildingPhoto__c buildingPhoto, PhotoType photoType) {
            // 初期化
            this.photoDataList  = new List<PhotoData>();
            // データセット
            this.Id         = buildingPhoto.Id;
            this.photoType  = photoType;
            this.foreignId  = buildingPhoto.Building__r.ForeignID__c;
            this.filePath   = S3FOLDERPATH_BUILDING_PROPERTY + this.foreignId;
            PhotoData data = new photoData();
            switch on photoType {
                when BUILDING_APPEARANCE {
                    // 外観
                    data.fileName   = buildingPhoto.AppearanceFileName__c;
                    data.comment    = buildingPhoto.AppearanceComment__c;
                    this.photoDataList.add(data);
                }
                when BUILDING_APPEARANCEPARSE {
                    // 外観パース
                    data.fileName   = buildingPhoto.AppearanceParseFileName__c;
                    data.comment    = buildingPhoto.AppearanceParseComment__c;
                    this.photoDataList.add(data);
                }
                when BUILDING_ENTRANCE {
                    // エントランス
                    data.fileName   = buildingPhoto.EntranceFileName__c;
                    data.comment    = buildingPhoto.EntranceComment__c;
                    this.photoDataList.add(data);
                }
                when BUILDING_LOBBY {
                    // ロビー
                    data.fileName   = buildingPhoto.LobbyFileName__c;
                    data.comment    = buildingPhoto.LobbyComment__c;
                    this.photoDataList.add(data);
                }
                when BUILDING_PARKING {
                    // 駐車場
                    data.fileName   = buildingPhoto.ParkingFileName__c;
                    data.comment    = buildingPhoto.ParkingComment__c;
                    this.photoDataList.add(data);
                }
                when BUILDING_OTHERSHARING {
                    // その他共有
                    data.fileName   = buildingPhoto.OtherSharingFileName__c;
                    data.comment    = buildingPhoto.OtherSharingComment__c;
                    this.photoDataList.add(data);
                }
                when BUILDING_MAP {
                    // 地図
                    data.fileName   = buildingPhoto.MapFileName__c;
                    data.comment    = buildingPhoto.MapComment__c;
                    this.photoDataList.add(data);
                }
                when BUILDING_OTHER {
                    // その他
                    data.fileName   = buildingPhoto.OtherFileName__c;
                    data.comment    = buildingPhoto.OtherComment__c;
                    this.photoDataList.add(data);
                }
                when BUILDING_SURROUNDING {
                    // 周辺写真
                    for (Integer i = 1; i <= CommonConst.MAXINDEX_BUILDING_SURROUNDING; i++) {
                        data = new photoData();
                        data.fileName   = (String)buildingPhoto.get('SurroundingFileName' + i + '__c');
                        data.tag        = (String)buildingPhoto.get('SurroundingTag' + i + '__c');
                        data.comment    = (String)buildingPhoto.get('SurroundingComment' + i + '__c');
                        data.photoName  = (String)buildingPhoto.get('SurroundingPhotoName' + i + '__c');
                        data.distance   = (Decimal)buildingPhoto.get('SurroundingDistance' + i + '__c');
                        this.photoDataList.add(data);
                    }
                }
            }
        }
        // コンストラクタ（学校）
        public AnyPhotoData(School__c school, PhotoType photoType) {
            // 初期化
            this.photoDataList  = new List<PhotoData>();
            // データセット
            this.Id         = school.Id;
            this.photoType  = photoType;
            this.foreignId  = school.ForeignID__c;
            this.filePath   = S3FOLDERPATH_SHOOL + this.foreignId;
            PhotoData data = new photoData();
            data.fileName   = school.PhotoFileName__c;
            this.photoDataList.add(data);
        }
        // コンストラクタ（病院）
        public AnyPhotoData(Hospital__c hospital, PhotoType photoType) {
            // 初期化
            this.photoDataList  = new List<PhotoData>();
            // データセット
            this.Id         = hospital.Id;
            this.photoType  = photoType;
            this.foreignId  = hospital.ForeignID__c;
            this.filePath   = S3FOLDERPATH_HOSPITAL + this.foreignId;
            PhotoData data = new photoData();
            data.fileName   = hospital.PhotoFileName__c;
            this.photoDataList.add(data);
        }
        // ポータルサイト構築 追加 Start
        // コンストラクタ（ニュースリリース）
        public AnyPhotoData(NewsRelease__c newsRelease, PhotoType photoType) {
            // 初期化
            this.photoDataList  = new List<PhotoData>();
            // データセット
            this.Id         = newsRelease.Id;
            this.photoType  = photoType;
            this.foreignId  = newsRelease.ForeignID__c;
            this.filePath   = S3FOLDERPATH_NEWS_RELEASE + this.foreignId;
            PhotoData data = new photoData();
            for (Integer i = 1; i <= CommonConst_ptl.MAXINDEX_NEWSRELEASE_RELEASE; i++) {
                data = new photoData();
                data.fileName   = (String)newsRelease.get('ReleasePhotoFileName' + i + '__c');
                this.photoDataList.add(data);
            }
        }
        // コンストラクタ（店舗）
        public AnyPhotoData(Shop__c shop, PhotoType photoType) {
            // 初期化
            this.photoDataList  = new List<PhotoData>();
            // データセット
            this.Id         = shop.Id;
            this.photoType  = photoType;
            this.foreignId  = shop.ForeignID__c;
            this.filePath   = S3FOLDERPATH_SHOP + this.foreignId;
            PhotoData data = new photoData();
            for (Integer i = 1; i <= CommonConst_ptl.MAXINDEX_SHOP; i++) {
                data = new photoData();
                //▼問合せNo0535で変更　外観写真はAPI名が違うので別途設定
                if(i == 9){
                    data.fileName   = (String)shop.get('AppearancePhotoFileName__c');
                }else{
                    data.fileName   = (String)shop.get('PhotoFileName' + i + '__c');
                }
                //▲問合せNo0535で変更
                this.photoDataList.add(data);
            }
        }
        // ポータルサイト構築 追加 End
        
        /**
         * コンストラクタ（周辺施設）
         */
        public AnyPhotoData(SurroundingFacility__c surroundingFacility, PhotoType photoType) {
            // 初期化
            this.photoDataList  = new List<PhotoData>();
            // データセット
            this.Id         = surroundingFacility.Id;
            this.photoType  = photoType;
            this.foreignId  = surroundingFacility.ForeignID__c;
            this.filePath   = S3FOLDERPATH_SURROUNDING + this.foreignId;
            PhotoData data = new photoData();
            data.fileName   = surroundingFacility.PhotoFileName__c;
            this.photoDataList.add(data);
        }
    }

    /**
     * 各種写真情報の取得
     * @param  Id           Id          対象オブジェクトのId
     * @param  PhotoType    photoType   写真種別
     */
    private static AnyPhotoData getAnyPhotoData(Id targetId, PhotoType photoType){
        AnyPhotoData anyPhotoData = new AnyPhotoData();
        String sql = '';
        switch on photoType {
            when PROPERTY
                ,PROPERTY_PRIVATE
                ,PROPERTY_PANORAMA
                ,PROPERTY_ROOMLAYOUT
                ,PROPERTY_ROOMLAYOUTMEMO {
                // 物件
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
                sql += ' WHERE Property__c = :targetId ';
                List<PropertyPhoto__c> propertyPhoto = Database.query(sql);
                anyPhotoData = new AnyPhotoData(propertyPhoto[0], photoType);
            }
            when BUILDING_APPEARANCE
                ,BUILDING_APPEARANCEPARSE
                ,BUILDING_ENTRANCE
                ,BUILDING_LOBBY
                ,BUILDING_PARKING
                ,BUILDING_OTHERSHARING
                ,BUILDING_MAP
                ,BUILDING_OTHER
                ,BUILDING_SURROUNDING {
                // 建物
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
                sql += '      ,Building__r.ForeignID__c ';
                sql += '  FROM BuildingPhoto__c ';
                sql += ' WHERE Building__c = :targetId ';
                List<BuildingPhoto__c> buildingPhoto = Database.query(sql);
                anyPhotoData = new AnyPhotoData(buildingPhoto[0], photoType);
            }
            when SCHOOL {
                // 学校
                sql += 'SELECT Id ';
                sql += '      ,PhotoFileName__c ';
                sql += '      ,ForeignID__c ';
                sql += '  FROM School__c ';
                sql += ' WHERE Id   = :targetId ';
                List<School__c> school = Database.query(sql);
                anyPhotoData = new AnyPhotoData(school[0], photoType);
            }
            when HOSPITAL {
                // 病院
                sql += 'SELECT Id ';
                sql += '      ,PhotoFileName__c ';
                sql += '      ,ForeignID__c ';
                sql += '  FROM Hospital__c ';
                sql += ' WHERE Id   = :targetId ';
                List<Hospital__c> hospital = Database.query(sql);
                anyPhotoData = new AnyPhotoData(hospital[0], photoType);
            }
            // ポータルサイト構築 追加 Start
            when NEWSRELEASE{
                // ニュースリリース
                sql += 'SELECT Id ';
                sql += '      ,ReleasePhotoFileName1__c ';
                sql += '      ,ReleasePhotoFileName2__c ';
                sql += '      ,ReleasePhotoFileName3__c ';
                sql += '      ,ReleasePhotoFileName4__c ';
                sql += '      ,ReleasePhotoFileName5__c ';
                sql += '      ,ReleasePhotoFileName6__c ';
                sql += '      ,ReleasePhotoFileName7__c ';  //2022.4.1 No754 サムネイル追加
                sql += '      ,ForeignID__c ';
                sql += '  FROM NewsRelease__c ';
                sql += ' WHERE Id   = :targetId ';
                List<NewsRelease__c> newsRelease = Database.query(sql);
                anyPhotoData = new AnyPhotoData(newsRelease[0], photoType);
            }
            when SHOP{
                // 店舗情報
                sql += 'SELECT Id ';
                sql += '      ,PhotoFileName1__c ';
                sql += '      ,PhotoFileName2__c ';
                sql += '      ,PhotoFileName3__c ';
                sql += '      ,PhotoFileName4__c ';
                sql += '      ,PhotoFileName5__c ';
                sql += '      ,PhotoFileName6__c ';
                sql += '      ,PhotoFileName7__c ';
                sql += '      ,PhotoFileName8__c ';
                sql += '      ,AppearancePhotoFileName__c ';    //問合せNo0535で追加
                sql += '      ,ForeignID__c ';
                sql += '  FROM Shop__c ';
                sql += ' WHERE Id   = :targetId ';
                List<Shop__c> shop = Database.query(sql);
                anyPhotoData = new AnyPhotoData(shop[0], photoType);
            }
            // ポータルサイト構築 追加 End
            when SURROUNDING_FACILITY {
                // 周辺施設
                sql = 'SELECT Id '
                    + '       , PhotoFileName__c '
                    + '       , ForeignID__c '
                    + 'FROM SurroundingFacility__c '
                    + 'WHERE Id = :targetId ';
                List<SurroundingFacility__c> surroundingFacilityList = Database.query(sql);
                anyPhotoData = new AnyPhotoData(surroundingFacilityList[0], photoType);
            }
        }
        return anyPhotoData;
    }

    /**
     * 各種写真情報の取得
     * @param  List<Id>           Id          対象オブジェクトのId
     * @param  List<PhotoType>    photoType   写真種別
     */
    private static Map<String, AnyPhotoData> getAnyPhotoData(List<PhotoMoveMultipleParameter> paramList, Boolean isFrom){
        List<Id> targetIdList = new List<Id>();
        List<PhotoType> photoTypeList = new List<PhotoType>();
        for (PhotoMoveMultipleParameter param : paramList) {
            if (isFrom) {
                targetIdList.add(param.targetMoveFromId);
            } else {
                targetIdList.add(param.targetMoveToId);
            }
            photoTypeList.add(param.photoType);
        }
        return getAnyPhotoData(targetIdList, photoTypeList);
    }
    private static Map<String, AnyPhotoData> getAnyPhotoData(List<PhotoMoveFromS3MultipleParameter> paramList){
        List<Id> targetIdList = new List<Id>();
        List<PhotoType> photoTypeList = new List<PhotoType>();
        for (PhotoMoveFromS3MultipleParameter param : paramList) {
            targetIdList.add(param.targetMoveToId);
            photoTypeList.add(param.photoType);
        }
        return getAnyPhotoData(targetIdList, photoTypeList);
    }
    private static Map<String, AnyPhotoData> getAnyPhotoData(List<Id> targetIdList, List<PhotoType> photoTypeList){

        // 返却値格納変数
        Map<String, AnyPhotoData> anyPhotoDataMap = new Map<String, AnyPhotoData>();

        // 取得対象のIdをオブジェクト（物件写真、建物写真、学校、病院、周辺施設）毎にリスト化
        List<Id> propIdList                = new List<Id>();
        List<Id> buildIdList               = new List<Id>();
        List<Id> schoolIdList              = new List<Id>();
        List<Id> hospitalIdList            = new List<Id>();
        for (Integer i = 0; i < targetIdList.size(); i++) {
            anyPhotoDataMap.put(String.valueOf(targetIdList[i]) + String.valueOf(photoTypeList[i]), new AnyPhotoData());
            PhotoType photoType = photoTypeList[i];
            switch on photoType {
                when PROPERTY
                    ,PROPERTY_PRIVATE
                    ,PROPERTY_PANORAMA
                    ,PROPERTY_ROOMLAYOUT
                    ,PROPERTY_ROOMLAYOUTMEMO {
                    propIdList.add(targetIdList[i]);
                }
                when BUILDING_APPEARANCE
                    ,BUILDING_APPEARANCEPARSE
                    ,BUILDING_ENTRANCE
                    ,BUILDING_LOBBY
                    ,BUILDING_PARKING
                    ,BUILDING_OTHERSHARING
                    ,BUILDING_MAP
                    ,BUILDING_OTHER
                    ,BUILDING_SURROUNDING {
                    buildIdList.add(targetIdList[i]);
                }
                when SCHOOL {
                    schoolIdList.add(targetIdList[i]);
                }
                when HOSPITAL {
                    hospitalIdList.add(targetIdList[i]);
                }
            }
        }

        // オブジェクト（物件写真、建物写真、学校、病院、周辺施設）毎にデータの取得
        List<PropertyPhoto__c> propPhotoList = new List<PropertyPhoto__c>();
        List<BuildingPhoto__c> buildPhotoList = new List<BuildingPhoto__c>();
        List<School__c> schoolList = new List<School__c>();
        List<Hospital__c> hospitalList = new List<Hospital__c>();
        String sql = '';
        if (propIdList.size() > 0) {
            // 物件
            sql = 'SELECT Id ';
            sql += '      ,Property__c';
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
            sql += ' WHERE Property__c IN :propIdList ';
            propPhotoList = Database.query(sql);
        }
        if (buildIdList.size() > 0) {
            // 建物
            sql = 'SELECT Id ';
            sql += '      ,Building__c';
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
            sql += '      ,Building__r.ForeignID__c ';
            sql += '  FROM BuildingPhoto__c ';
            sql += ' WHERE Building__c IN :buildIdList ';
            buildPhotoList = Database.query(sql);
        }
        if (schoolIdList.size() > 0) {
            // 学校
            sql = 'SELECT Id ';
            sql += '      ,PhotoFileName__c ';
            sql += '      ,ForeignID__c ';
            sql += '  FROM School__c ';
            sql += ' WHERE Id IN :schoolIdList ';
            schoolList = Database.query(sql);
        }
        if (hospitalIdList.size() > 0) {
            // 病院
            sql = 'SELECT Id ';
            sql += '      ,PhotoFileName__c ';
            sql += '      ,ForeignID__c ';
            sql += '  FROM Hospital__c ';
            sql += ' WHERE Id IN :hospitalIdList ';
            hospitalList = Database.query(sql);
        }

        // 写真情報の作成
        if (propPhotoList.size() > 0) {
            // 物件
            // SELECT結果分繰り返し
            for (PropertyPhoto__c propPhoto : propPhotoList) {
                // 対象Id＋写真種別を検索し、Mapへデータ追加していく
                for (Integer i = 0; i < targetIdList.size(); i++) {
                    if (targetIdList[i] == propPhoto.Property__c) {
                        String MapKey = String.valueOf(targetIdList[i]) + String.valueOf(photoTypeList[i]);
                        anyPhotoDataMap.put(MapKey, new AnyPhotoData(propPhoto, photoTypeList[i]));
                    }
                }
            }
        }
        if (buildPhotoList.size() > 0) {
            // 建物
            // SELECT結果分繰り返し
            for (BuildingPhoto__c buildPhoto : buildPhotoList) {
                // 対象Id＋写真種別を検索し、Mapへデータ追加していく
                for (Integer i = 0; i < targetIdList.size(); i++) {
                    if (targetIdList[i] == buildPhoto.Building__c) {
                        String MapKey = String.valueOf(targetIdList[i]) + String.valueOf(photoTypeList[i]);
                        anyPhotoDataMap.put(MapKey, new AnyPhotoData(buildPhoto, photoTypeList[i]));
                    }
                }
            }
        }
        if (schoolList.size() > 0) {
            // 学校
            // SELECT結果分繰り返し
            for (School__c school : schoolList) {
                // 対象Id＋写真種別を検索し、Mapへデータ追加していく
                for (Integer i = 0; i < targetIdList.size(); i++) {
                    if (targetIdList[i] == school.Id) {
                        String MapKey = String.valueOf(targetIdList[i]) + String.valueOf(photoTypeList[i]);
                        anyPhotoDataMap.put(MapKey, new AnyPhotoData(school, photoTypeList[i]));
                    }
                }
            }
        }
        if (hospitalList.size() > 0) {
            // 病院
            // SELECT結果分繰り返し
            for (Hospital__c hospital : hospitalList) {
                // 対象Id＋写真種別を検索し、Mapへデータ追加していく
                for (Integer i = 0; i < targetIdList.size(); i++) {
                    if (targetIdList[i] == hospital.Id) {
                        String MapKey = String.valueOf(targetIdList[i]) + String.valueOf(photoTypeList[i]);
                        anyPhotoDataMap.put(MapKey, new AnyPhotoData(hospital, photoTypeList[i]));
                    }
                }
            }
        }

        return anyPhotoDataMap;

    }

    /**
     * 1レコードｎ件の写真情報の空情報の詰め処理
     * （物件写真、建物周辺写真 等）
     */
    private static void trimPhotoData(AnyPhotoData anyPhotoData) {
        // 空以外の写真情報を取得
        List<PhotoData> trimPhotoList = new List<PhotoData>();
        for (PhotoData photo : anyPhotoData.photoDataList) {
            if (!String.isEmpty(photo.fileName)) {
                trimPhotoList.add(photo.clone());
            }
        }

        // 1から順に設定し直す
        for (Integer i=0; i < anyPhotoData.photoDataList.size(); i++) {
            if (i < trimPhotoList.size()) {
                anyPhotoData.photoDataList[i] = trimPhotoList[i].clone();
            } else {
                anyPhotoData.photoDataList[i] = new PhotoData();
            }
        }
    }

    /**
     * 各種写真情報の更新
     */
    private static void updateAnyPhotoData(AnyPhotoData anyPhotoData){

        PhotoType photoType = anyPhotoData.photoType;

        switch on photoType {
            when PROPERTY {
                // 物件写真
                PropertyPhoto__c propertyPhoto = new PropertyPhoto__c();
                propertyPhoto.Id = anyPhotoData.Id;
                for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PROPERTY; i++) {
                    propertyPhoto.put('PropertyPhotoFileName' + i + '__c', anyPhotoData.photoDataList[i-1].fileName);
                    propertyPhoto.put('PropertyPhotoTag' + i + '__c'     , anyPhotoData.photoDataList[i-1].tag);
                    propertyPhoto.put('PropertyPhotoComment' + i + '__c' , anyPhotoData.photoDataList[i-1].comment);
                }
                SecureDML.secureUpdate(propertyPhoto);
            }
            when PROPERTY_PRIVATE {
                // 物件非公開
                PropertyPhoto__c propertyPhoto = new PropertyPhoto__c();
                propertyPhoto.Id = anyPhotoData.Id;
                for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PRIVATE; i++) {
                    propertyPhoto.put('PrivatePhotoFileName' + i + '__c', anyPhotoData.photoDataList[i-1].fileName);
                    propertyPhoto.put('PrivatePhotoType' + i + '__c'    , anyPhotoData.photoDataList[i-1].tag);
                    propertyPhoto.put('PrivatePhotoComment' + i + '__c' , anyPhotoData.photoDataList[i-1].comment);
                }
                SecureDML.secureUpdate(propertyPhoto);
            }
            when PROPERTY_PANORAMA {
                // 物件パノラマ
                PropertyPhoto__c propertyPhoto = new PropertyPhoto__c();
                propertyPhoto.Id = anyPhotoData.Id;
                for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PANORAMA; i++) {
                    propertyPhoto.put('PanoramaFileName' + i + '__c', anyPhotoData.photoDataList[i-1].fileName);
                    propertyPhoto.put('PanoramaTag' + i + '__c'     , anyPhotoData.photoDataList[i-1].tag);
                    propertyPhoto.put('PanoramaComment' + i + '__c' , anyPhotoData.photoDataList[i-1].comment);
                }
                SecureDML.secureUpdate(propertyPhoto);
            }
            when PROPERTY_ROOMLAYOUT {
                // 物件間取り図
                PropertyPhoto__c propertyPhoto = new PropertyPhoto__c();
                propertyPhoto.Id = anyPhotoData.Id;
                propertyPhoto.RoomLayoutFileName__c = anyPhotoData.photoDataList[0].fileName;
                SecureDML.secureUpdate(propertyPhoto);
            }
            when PROPERTY_ROOMLAYOUTMEMO {
                // 物件間取り図（メモ有）
                PropertyPhoto__c propertyPhoto = new PropertyPhoto__c();
                propertyPhoto.Id = anyPhotoData.Id;
                propertyPhoto.RoomLayoutMemoFileName__c = anyPhotoData.photoDataList[0].fileName;
                SecureDML.secureUpdate(propertyPhoto);
            }
            when BUILDING_APPEARANCE {
                // 建物外観
                BuildingPhoto__c buildingPhoto = new BuildingPhoto__c();
                buildingPhoto.Id = anyPhotoData.Id;
                buildingPhoto.AppearanceFileName__c = anyPhotoData.photoDataList[0].fileName;
                buildingPhoto.AppearanceComment__c  = anyPhotoData.photoDataList[0].comment;
                SecureDML.secureUpdate(buildingPhoto);
            }
            when BUILDING_APPEARANCEPARSE {
                // 建物外観パース
                BuildingPhoto__c buildingPhoto = new BuildingPhoto__c();
                buildingPhoto.Id = anyPhotoData.Id;
                buildingPhoto.AppearanceParseFileName__c = anyPhotoData.photoDataList[0].fileName;
                buildingPhoto.AppearanceParseComment__c  = anyPhotoData.photoDataList[0].comment;
                SecureDML.secureUpdate(buildingPhoto);
            }
            when BUILDING_ENTRANCE {
                // 建物エントランス
                BuildingPhoto__c buildingPhoto = new BuildingPhoto__c();
                buildingPhoto.Id = anyPhotoData.Id;
                buildingPhoto.EntranceFileName__c = anyPhotoData.photoDataList[0].fileName;
                buildingPhoto.EntranceComment__c  = anyPhotoData.photoDataList[0].comment;
                SecureDML.secureUpdate(buildingPhoto);
            }
            when BUILDING_LOBBY {
                // 建物ロビー
                BuildingPhoto__c buildingPhoto = new BuildingPhoto__c();
                buildingPhoto.Id = anyPhotoData.Id;
                buildingPhoto.LobbyFileName__c = anyPhotoData.photoDataList[0].fileName;
                buildingPhoto.LobbyComment__c  = anyPhotoData.photoDataList[0].comment;
                SecureDML.secureUpdate(buildingPhoto);
            }
            when BUILDING_PARKING {
                // 建物駐車場
                BuildingPhoto__c buildingPhoto = new BuildingPhoto__c();
                buildingPhoto.Id = anyPhotoData.Id;
                buildingPhoto.ParkingFileName__c = anyPhotoData.photoDataList[0].fileName;
                buildingPhoto.ParkingComment__c  = anyPhotoData.photoDataList[0].comment;
                SecureDML.secureUpdate(buildingPhoto);
            }
            when BUILDING_OTHERSHARING {
                // 建物その他共有
                BuildingPhoto__c buildingPhoto = new BuildingPhoto__c();
                buildingPhoto.Id = anyPhotoData.Id;
                buildingPhoto.OtherSharingFileName__c = anyPhotoData.photoDataList[0].fileName;
                buildingPhoto.OtherSharingComment__c  = anyPhotoData.photoDataList[0].comment;
                SecureDML.secureUpdate(buildingPhoto);
            }
            when BUILDING_MAP {
                // 建物地図
                BuildingPhoto__c buildingPhoto = new BuildingPhoto__c();
                buildingPhoto.Id = anyPhotoData.Id;
                buildingPhoto.MapFileName__c = anyPhotoData.photoDataList[0].fileName;
                buildingPhoto.MapComment__c  = anyPhotoData.photoDataList[0].comment;
                SecureDML.secureUpdate(buildingPhoto);
            }
            when BUILDING_OTHER {
                // 建物その他
                BuildingPhoto__c buildingPhoto = new BuildingPhoto__c();
                buildingPhoto.Id = anyPhotoData.Id;
                buildingPhoto.OtherFileName__c = anyPhotoData.photoDataList[0].fileName;
                buildingPhoto.OtherComment__c  = anyPhotoData.photoDataList[0].comment;
                SecureDML.secureUpdate(buildingPhoto);
            }
            when BUILDING_SURROUNDING {
                // 建物周辺
                BuildingPhoto__c buildingPhoto = new BuildingPhoto__c();
                buildingPhoto.Id = anyPhotoData.Id;
                for (Integer i = 1; i <= CommonConst.MAXINDEX_BUILDING_SURROUNDING; i++) {
                    buildingPhoto.put('SurroundingFileName' + i + '__c'  , anyPhotoData.photoDataList[i-1].fileName);
                    buildingPhoto.put('SurroundingTag' + i + '__c'       , anyPhotoData.photoDataList[i-1].tag);
                    buildingPhoto.put('SurroundingComment' + i + '__c'   , anyPhotoData.photoDataList[i-1].comment);
                    buildingPhoto.put('SurroundingPhotoName' + i + '__c' , anyPhotoData.photoDataList[i-1].photoName);
                    buildingPhoto.put('SurroundingDistance' + i + '__c'  , anyPhotoData.photoDataList[i-1].distance);
                }
                SecureDML.secureUpdate(buildingPhoto);
            }
            when SCHOOL {
                // 学校
                School__c school = new School__c();
                school.Id = anyPhotoData.Id;
                school.PhotoFileName__c = anyPhotoData.photoDataList[0].fileName;
                SecureDML.secureUpdate(school);
            }
            when HOSPITAL {
                // 病院
                Hospital__c hospital = new Hospital__c();
                hospital.Id = anyPhotoData.Id;
                hospital.PhotoFileName__c = anyPhotoData.photoDataList[0].fileName;
                SecureDML.secureUpdate(hospital);
            }
            // ポータルサイト構築 追加 Start
            when NEWSRELEASE {
                // ニュースリリース
                newsRelease__c newsRelease = new newsRelease__c();
                newsRelease.Id = anyPhotoData.Id;
                for (Integer i = 1; i <= CommonConst_ptl.MAXINDEX_NEWSRELEASE_RELEASE; i++) {
                    newsRelease.put('ReleasePhotoFileName' + i + '__c', anyPhotoData.photoDataList[i-1].fileName);
                }
                SecureDML.secureUpdate(newsRelease);
            }
            when SHOP {
                // 店舗
                Shop__c shop = new Shop__c();
                shop.Id = anyPhotoData.Id;
                for (Integer i = 1; i <= CommonConst_ptl.MAXINDEX_SHOP; i++) {
                    //▼問合せNo0535で変更　外観写真はAPI名が違うので別途設定
                    if(i == 9){
                        shop.put('AppearancePhotoFileName__c', anyPhotoData.photoDataList[i-1].fileName);
                    }else{
                        shop.put('PhotoFileName' + i + '__c', anyPhotoData.photoDataList[i-1].fileName);
                    }
                    //▲問合せNo0535で変更
                }
                SecureDML.secureUpdate(shop);
            }
            // ポータルサイト構築 追加 End
            When SURROUNDING_FACILITY {
                // 周辺施設
                SurroundingFacility__c surroundingFacility = new SurroundingFacility__c();
                surroundingFacility.Id               = anyPhotoData.Id;
                surroundingFacility.PhotoFileName__c = anyPhotoData.photoDataList[0].fileName;

                SecureDML.secureUpdate(surroundingFacility);
            }
        }
    }

    /**
     * 各種写真情報の複数更新
     */
    private static void updateAnyPhotoData(List<AnyPhotoData> anyPhotoDataList){

        Map<Id, PropertyPhoto__c> propertyPhotoMap = new Map<Id, PropertyPhoto__c>();
        Map<Id, BuildingPhoto__c> buildingPhotoMap = new Map<Id, BuildingPhoto__c>();
        List<School__c> SchoolList = new List<School__c>();
        List<Hospital__c> HospitalList = new List<Hospital__c>();

        PropertyPhoto__c propertyPhoto = new PropertyPhoto__c();
        BuildingPhoto__c buildingPhoto = new BuildingPhoto__c();

        for (AnyPhotoData anyPhotoData : anyPhotoDataList) {
            switch on anyPhotoData.photoType {
                when PROPERTY
                    ,PROPERTY_PRIVATE
                    ,PROPERTY_PANORAMA
                    ,PROPERTY_ROOMLAYOUT
                    ,PROPERTY_ROOMLAYOUTMEMO {
                    // 物件
                    propertyPhoto = new PropertyPhoto__c();
                    if (propertyPhotoMap.containsKey(anyPhotoData.Id)) {
                        propertyPhoto = propertyPhotoMap.get(anyPhotoData.Id);
                    } else {
                        propertyPhoto.Id = anyPhotoData.Id;
                    }
                }
                when BUILDING_APPEARANCE
                    ,BUILDING_APPEARANCEPARSE
                    ,BUILDING_ENTRANCE
                    ,BUILDING_LOBBY
                    ,BUILDING_PARKING
                    ,BUILDING_OTHERSHARING
                    ,BUILDING_MAP
                    ,BUILDING_OTHER
                    ,BUILDING_SURROUNDING {
                    // 建物
                    buildingPhoto = new BuildingPhoto__c();
                    if (buildingPhotoMap.containsKey(anyPhotoData.Id)) {
                        buildingPhoto = buildingPhotoMap.get(anyPhotoData.Id);
                    } else {
                        buildingPhoto.Id = anyPhotoData.Id;
                    }
                }
            }
            switch on anyPhotoData.photoType {
                when PROPERTY {
                    // 物件写真
                    for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PROPERTY; i++) {
                        propertyPhoto.put('PropertyPhotoFileName' + i + '__c', anyPhotoData.photoDataList[i-1].fileName);
                        propertyPhoto.put('PropertyPhotoTag' + i + '__c'     , anyPhotoData.photoDataList[i-1].tag);
                        propertyPhoto.put('PropertyPhotoComment' + i + '__c' , anyPhotoData.photoDataList[i-1].comment);
                    }
                    propertyPhotoMap.put(propertyPhoto.Id, propertyPhoto);
                }
                when PROPERTY_PRIVATE {
                    // 物件非公開
                    for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PRIVATE; i++) {
                        propertyPhoto.put('PrivatePhotoFileName' + i + '__c', anyPhotoData.photoDataList[i-1].fileName);
                        propertyPhoto.put('PrivatePhotoType' + i + '__c'    , anyPhotoData.photoDataList[i-1].tag);
                        propertyPhoto.put('PrivatePhotoComment' + i + '__c' , anyPhotoData.photoDataList[i-1].comment);
                    }
                    propertyPhotoMap.put(propertyPhoto.Id, propertyPhoto);
                }
                when PROPERTY_PANORAMA {
                    // 物件パノラマ
                    for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PANORAMA; i++) {
                        propertyPhoto.put('PanoramaFileName' + i + '__c', anyPhotoData.photoDataList[i-1].fileName);
                        propertyPhoto.put('PanoramaTag' + i + '__c'     , anyPhotoData.photoDataList[i-1].tag);
                        propertyPhoto.put('PanoramaComment' + i + '__c' , anyPhotoData.photoDataList[i-1].comment);
                    }
                    propertyPhotoMap.put(propertyPhoto.Id, propertyPhoto);
                }
                when PROPERTY_ROOMLAYOUT {
                    // 物件間取り図
                    propertyPhoto.RoomLayoutFileName__c = anyPhotoData.photoDataList[0].fileName;
                    propertyPhotoMap.put(propertyPhoto.Id, propertyPhoto);
                }
                when PROPERTY_ROOMLAYOUTMEMO {
                    // 物件間取り図（メモ有）
                    propertyPhoto.RoomLayoutMemoFileName__c = anyPhotoData.photoDataList[0].fileName;
                    propertyPhotoMap.put(propertyPhoto.Id, propertyPhoto);
                }
                when BUILDING_APPEARANCE {
                    // 建物外観
                    buildingPhoto.AppearanceFileName__c = anyPhotoData.photoDataList[0].fileName;
                    buildingPhoto.AppearanceComment__c  = anyPhotoData.photoDataList[0].comment;
                    buildingPhotoMap.put(buildingPhoto.Id, buildingPhoto);
                }
                when BUILDING_APPEARANCEPARSE {
                    // 建物外観パース
                    buildingPhoto.AppearanceParseFileName__c = anyPhotoData.photoDataList[0].fileName;
                    buildingPhoto.AppearanceParseComment__c  = anyPhotoData.photoDataList[0].comment;
                    buildingPhotoMap.put(buildingPhoto.Id, buildingPhoto);
                }
                when BUILDING_ENTRANCE {
                    // 建物エントランス
                    buildingPhoto.EntranceFileName__c = anyPhotoData.photoDataList[0].fileName;
                    buildingPhoto.EntranceComment__c  = anyPhotoData.photoDataList[0].comment;
                    buildingPhotoMap.put(buildingPhoto.Id, buildingPhoto);
                }
                when BUILDING_LOBBY {
                    // 建物ロビー
                    buildingPhoto.LobbyFileName__c = anyPhotoData.photoDataList[0].fileName;
                    buildingPhoto.LobbyComment__c  = anyPhotoData.photoDataList[0].comment;
                    buildingPhotoMap.put(buildingPhoto.Id, buildingPhoto);
                }
                when BUILDING_PARKING {
                    // 建物駐車場
                    buildingPhoto.ParkingFileName__c = anyPhotoData.photoDataList[0].fileName;
                    buildingPhoto.ParkingComment__c  = anyPhotoData.photoDataList[0].comment;
                    buildingPhotoMap.put(buildingPhoto.Id, buildingPhoto);
                }
                when BUILDING_OTHERSHARING {
                    // 建物その他共有
                    buildingPhoto.OtherSharingFileName__c = anyPhotoData.photoDataList[0].fileName;
                    buildingPhoto.OtherSharingComment__c  = anyPhotoData.photoDataList[0].comment;
                    buildingPhotoMap.put(buildingPhoto.Id, buildingPhoto);
                }
                when BUILDING_MAP {
                    // 建物地図
                    buildingPhoto.MapFileName__c = anyPhotoData.photoDataList[0].fileName;
                    buildingPhoto.MapComment__c  = anyPhotoData.photoDataList[0].comment;
                    buildingPhotoMap.put(buildingPhoto.Id, buildingPhoto);
                }
                when BUILDING_OTHER {
                    // 建物その他
                    buildingPhoto.OtherFileName__c = anyPhotoData.photoDataList[0].fileName;
                    buildingPhoto.OtherComment__c  = anyPhotoData.photoDataList[0].comment;
                    buildingPhotoMap.put(buildingPhoto.Id, buildingPhoto);
                }
                when BUILDING_SURROUNDING {
                    // 建物周辺
                    for (Integer i = 1; i <= CommonConst.MAXINDEX_BUILDING_SURROUNDING; i++) {
                        buildingPhoto.put('SurroundingFileName' + i + '__c'  , anyPhotoData.photoDataList[i-1].fileName);
                        buildingPhoto.put('SurroundingTag' + i + '__c'       , anyPhotoData.photoDataList[i-1].tag);
                        buildingPhoto.put('SurroundingComment' + i + '__c'   , anyPhotoData.photoDataList[i-1].comment);
                        buildingPhoto.put('SurroundingPhotoName' + i + '__c' , anyPhotoData.photoDataList[i-1].photoName);
                        buildingPhoto.put('SurroundingDistance' + i + '__c'  , anyPhotoData.photoDataList[i-1].distance);
                    }
                    buildingPhotoMap.put(buildingPhoto.Id, buildingPhoto);
                }
                when SCHOOL {
                    // 学校
                    School__c school = new School__c();
                    school.Id = anyPhotoData.Id;
                    school.PhotoFileName__c = anyPhotoData.photoDataList[0].fileName;
                    schoolList.add(school);
                }
                when HOSPITAL {
                    // 病院
                    Hospital__c hospital = new Hospital__c();
                    hospital.Id = anyPhotoData.Id;
                    hospital.PhotoFileName__c = anyPhotoData.photoDataList[0].fileName;
                    hospitalList.add(hospital);
                }
            }
        }

        if (propertyPhotoMap.size() > 0) {
            SecureDML.secureUpdate(propertyPhotoMap.values());
        }
        if (buildingPhotoMap.size() > 0) {
            SecureDML.secureUpdate(buildingPhotoMap.values());
        }
        if (schoolList.size() > 0) {
            SecureDML.secureUpdate(schoolList);
        }
        if (hospitalList.size() > 0) {
            SecureDML.secureUpdate(hospitalList);
        }

    }

    /**
     * 物件写真情報の取得
     * @param  Id               targetId    物件オブジェクトのId
     * @return PropertyPhoto__c 取得結果
     */
    private static PropertyPhoto__c selectPropertyPhotoData(Id targetId){
        List<Id> targetIdList = new List<Id>();
        targetIdList.add(targetId);
        return selectPropertyPhotoData(targetIdList)[0];
    }
    private static List<PropertyPhoto__c> selectPropertyPhotoData(List<Id> targetIdList){
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
        sql += ' WHERE Property__c   IN :targetIdList ';
        List<PropertyPhoto__c> propertyPhoto = Database.query(sql);
        return propertyPhoto;
    }

    /**
     * 物件写真情報から写真名の一覧取得
     * @param  PropertyPhoto__c propertyPhoto   物件写真オブジェクト
     * @return List<String>     写真名の一覧
     */
    private static List<String> getPropertyFilePathList(PropertyPhoto__c propertyPhoto) {
        List<PropertyPhoto__c> propertyPhotoList = new List<PropertyPhoto__c>();
        propertyPhotoList.add(propertyPhoto);
        return getPropertyFilePathList(propertyPhotoList);
    }
    private static List<String> getPropertyFilePathList(List<PropertyPhoto__c> propertyPhotoList) {
        List<String> photoPathList = new List<String>();
        for (PropertyPhoto__c propertyPhoto : propertyPhotoList) {
            String filePath = S3FOLDERPATH_BUILDING_PROPERTY + propertyPhoto.Property__r.Building__r.ForeignID__c + '/' + propertyPhoto.Property__r.ForeignID__c;
            String fileName;
            for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PROPERTY; i++) {          // 物件写真
                fileName = (String)propertyPhoto.get('PropertyPhotoFileName' + i + '__c');
                if (!String.isEmpty(fileName)) {
                    photoPathList.add(filePath + '/' + fileName);
                }
            }
            for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PRIVATE; i++) {  // 物件非公開
                fileName = (String)propertyPhoto.get('PrivatePhotoFileName' + i + '__c');
                if (!String.isEmpty(fileName)) {
                    photoPathList.add(filePath + '/' + fileName);
                }
            }
            for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PANORAMA; i++) { // 物件パノラマ
                fileName = (String)propertyPhoto.get('PanoramaFileName' + i + '__c');
                if (!String.isEmpty(fileName)) {
                    photoPathList.add(filePath + '/' + fileName);
                }
            }
            fileName = propertyPhoto.RoomLayoutFileName__c;             // 物件間取り図
            if (!String.isEmpty(fileName)) {
                photoPathList.add(filePath + '/' + fileName);
                AmazonS3Util.extensionConvertJson(photoPathList,filePath + '/' + fileName);  //物件間取り図位置情報
            }
            fileName = propertyPhoto.RoomLayoutMemoFileName__c;         // 物件間取り図（メモ有）
            if (!String.isEmpty(fileName)) {
                photoPathList.add(filePath + '/' + fileName);
            }
        }
        return photoPathList;
    }

    /**
     * 間取り図フルパスの拡張子を位置情報ファイル（json）に変更しリストに追加する
     * @param  List<String>     filePathList ファイルパスリスト
     * @param  String           filePath     ファイルパス
     * @return String                        空：失敗 ファイルパスあり: 変更Jsonファイルパス                        
     */
    public static String extensionConvertJson(String filePath){
        List<String> filePathList = new List<String>();
        filePathList.add(filePath);
        return AmazonS3Util.extensionConvertJson(filePathList,filePath);
    }
    public static String extensionConvertJson(List<String> filePathList, String filePath){
        Integer extension = filePath.lastIndexOf('.');      // 拡張子の位置を取得
        if(extension == -1 ){
            // 失敗
            return '';
        }
        String jsonFilePath = filePath.substring(0,extension)+ '.json';
        filePathList.add(jsonFilePath);    // 拡張子以外を抜き出し「json」ファイルに置き換えリストに追加。
        return jsonFilePath;
    }

	//▼ 2021.12.20 No.437 対応で追加
	/**
	 * CSVアップロード命令
	 * @param  String     csvBody       CSVの内容
	 * @param  String     fileName      ファイル名
	 * @return HTTPResponse 実行結果
	 */
	public static HTTPResponse callS3Up(String csvBody, String fileName) {
		Map<String, String> paramMap =  new Map<String, String>();
		paramMap.put('Content-Length', String.valueOf(csvBody.length()));	
		return AmazonS3Util.callRestAPI('PUT', csvBody, S3FOLDERPATH_CSV + fileName,paramMap,  'text/csv', '',null);
	}
	//▲ 2021.12.20 No.437 対応で追加


    /**
     * 物件写真情報の写真関連項目のクリア
     * @param  Id               targetId    物件写真オブジェクトのId
     */
    private static void clearPropertyPhotoData(Id targetId) {
        List<Id> targetIdList = new List<Id>();
        targetIdList.add(targetId);
        AmazonS3Util.clearPropertyPhotoData(targetIdList);
    }
    private static void clearPropertyPhotoData(List<Id> targetIdList) {
        if (targetIdList.size() == 0) {
            return;
        }
        List<PropertyPhoto__c> propertyPhotoList = new List<PropertyPhoto__c>();
        for (Id targetId : targetIdList) {
            PropertyPhoto__c propertyPhoto = new PropertyPhoto__c();
            propertyPhoto.Id = targetId;
            for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PROPERTY; i++) {          // 物件写真
                propertyPhoto.put('PropertyPhotoFileName' + i + '__c', null);
                propertyPhoto.put('PropertyPhotoTag' + i + '__c'     , null);
                propertyPhoto.put('PropertyPhotoComment' + i + '__c' , null);
            }
            for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PRIVATE; i++) {  // 物件非公開
                propertyPhoto.put('PrivatePhotoFileName' + i + '__c', null);
                propertyPhoto.put('PrivatePhotoType' + i + '__c'    , null);
                propertyPhoto.put('PrivatePhotoComment' + i + '__c' , null);
            }
            for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PANORAMA; i++) { // 物件パノラマ
                propertyPhoto.put('PanoramaFileName' + i + '__c', null);
                propertyPhoto.put('PanoramaTag' + i + '__c'     , null);
                propertyPhoto.put('PanoramaComment' + i + '__c' , null);
            }
            propertyPhoto.RoomLayoutFileName__c     = null;     // 物件間取り図
            propertyPhoto.RoomLayoutMemoFileName__c = null;     // 物件間取り図（メモ有）
            propertyPhotoList.add(propertyPhoto);
        }
        SecureDML.secureUpdate(propertyPhotoList);
    }

    //▼問合せNo0345で追加
    /**
     * 物件写真情報から写真名の一覧取得（物件のタイプ単位全て）
     * @param  PropertyPhoto__c propertyPhoto   物件写真オブジェクト
     * @param  PhotoType        photoType       写真種類
     * @return List<String>     写真名の一覧
     */
    private static List<String> getPropertyFilePathList(PropertyPhoto__c propertyPhoto,PhotoType photoType) {
        List<PropertyPhoto__c> propertyPhotoList = new List<PropertyPhoto__c>();
        propertyPhotoList.add(propertyPhoto);
        return getPropertyFilePathList(propertyPhotoList,photoType);
    }
    private static List<String> getPropertyFilePathList(List<PropertyPhoto__c> propertyPhotoList,PhotoType photoType) {
        List<String> photoPathList = new List<String>();
        for (PropertyPhoto__c propertyPhoto : propertyPhotoList) {
            String filePath = S3FOLDERPATH_BUILDING_PROPERTY + propertyPhoto.Property__r.Building__r.ForeignID__c + '/' + propertyPhoto.Property__r.ForeignID__c;
            String fileName;
            switch on photoType {
                when PROPERTY {
                    // 物件写真
                    for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PROPERTY; i++) {          // 物件写真
                        fileName = (String)propertyPhoto.get('PropertyPhotoFileName' + i + '__c');
                        if (!String.isEmpty(fileName)) {
                            photoPathList.add(filePath + '/' + fileName);
                        }
                    }
                }
                when PROPERTY_PRIVATE {
                    // 物件非公開
                    for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PRIVATE; i++) {  // 物件非公開
                        fileName = (String)propertyPhoto.get('PrivatePhotoFileName' + i + '__c');
                        if (!String.isEmpty(fileName)) {
                            photoPathList.add(filePath + '/' + fileName);
                        }
                    }
                }
                when PROPERTY_PANORAMA {
                    // 物件パノラマ
                    for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PANORAMA; i++) { // 物件パノラマ
                        fileName = (String)propertyPhoto.get('PanoramaFileName' + i + '__c');
                        if (!String.isEmpty(fileName)) {
                            photoPathList.add(filePath + '/' + fileName);
                        }
                    }
                }
                when PROPERTY_ROOMLAYOUT {
                    fileName = propertyPhoto.RoomLayoutFileName__c;             // 物件間取り図
                    if (!String.isEmpty(fileName)) {
                        photoPathList.add(filePath + '/' + fileName);
                        AmazonS3Util.extensionConvertJson(photoPathList,filePath + '/' + fileName);  //物件間取り図位置情報
                    }
                }
                when PROPERTY_ROOMLAYOUTMEMO {
                    fileName = propertyPhoto.RoomLayoutMemoFileName__c;         // 物件間取り図（メモ有）
                    if (!String.isEmpty(fileName)) {
                        photoPathList.add(filePath + '/' + fileName);
                    }
                }
            }
        }
        return photoPathList;
    }

    /**
     * 物件写真情報の写真関連項目のクリア
     * @param  Id               targetId    物件写真オブジェクトのId
     * @param  PhotoType        photoType   写真種類
     */
    private static void clearPropertyPhotoData(Id targetId,PhotoType photoType) {
        List<Id> targetIdList = new List<Id>();
        targetIdList.add(targetId);
        AmazonS3Util.clearPropertyPhotoData(targetIdList,photoType);
    }
    private static void clearPropertyPhotoData(List<Id> targetIdList,PhotoType photoType) {
        if (targetIdList.size() == 0) {
            return;
        }
        List<PropertyPhoto__c> propertyPhotoList = new List<PropertyPhoto__c>();
        for (Id targetId : targetIdList) {
            PropertyPhoto__c propertyPhoto = new PropertyPhoto__c();
            propertyPhoto.Id = targetId;
            switch on photoType {
                when PROPERTY {
                    // 物件写真
                    for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PROPERTY; i++) {          // 物件写真
                        propertyPhoto.put('PropertyPhotoFileName' + i + '__c', null);
                        propertyPhoto.put('PropertyPhotoTag' + i + '__c'     , null);
                        propertyPhoto.put('PropertyPhotoComment' + i + '__c' , null);
                    }
                }
                when PROPERTY_PRIVATE {
                    // 物件非公開
                    for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PRIVATE; i++) {  // 物件非公開
                        propertyPhoto.put('PrivatePhotoFileName' + i + '__c', null);
                        propertyPhoto.put('PrivatePhotoType' + i + '__c'    , null);
                        propertyPhoto.put('PrivatePhotoComment' + i + '__c' , null);
                    }
                }
                when PROPERTY_PANORAMA {
                    for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PANORAMA; i++) { // 物件パノラマ
                        propertyPhoto.put('PanoramaFileName' + i + '__c', null);
                        propertyPhoto.put('PanoramaTag' + i + '__c'     , null);
                        propertyPhoto.put('PanoramaComment' + i + '__c' , null);
                    }
                }
            }
            propertyPhotoList.add(propertyPhoto);
        }
        SecureDML.secureUpdate(propertyPhotoList);
    }
    //▲問合せNo0345で追加

    /**
     * 建物写真情報の取得
     * @param  Id               Id      建物オブジェクトのId
     * @return BuildingPhoto__c 取得結果
     */
    private static BuildingPhoto__c selectBuildingPhotoData(Id targetId){
        List<Id> targetIdList = new List<Id>();
        targetIdList.add(targetId);
        return AmazonS3Util.selectBuildingPhotoData(targetIdList)[0];
    }
    private static List<BuildingPhoto__c> selectBuildingPhotoData(List<Id> targetIdList) {
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
        sql += '      ,Building__r.ForeignID__c ';
        sql += '  FROM BuildingPhoto__c ';
        sql += ' WHERE Building__c   IN :targetIdList ';
        List<BuildingPhoto__c> buildingPhoto = Database.query(sql);
        return buildingPhoto;
    }

    // ポータルサイト構築 追加 Start
    /**
     * ニュースリリース情報の取得
     * @param  Id               targetId      ニュースリリースのId
     * @return NewsRelease__c 取得結果
     */
    private static List<NewsRelease__c> selectNewsReleasePhotoData(Id targetId){
        String sql = '';
        sql += 'SELECT Id ';
        for (Integer i = 1; i <= CommonConst_ptl.MAXINDEX_NEWSRELEASE_RELEASE; i++) {  // ニュースリリース
        sql += ' ,    ReleasePhotoFileName' + i + '__c ';
        }
        sql += ' ,    ForeignID__c ';
        sql += ' FROM NewsRelease__c ';
        sql += ' WHERE Id   = :targetId ';
        List<NewsRelease__c> newsReleasePhotoList = Database.query(sql);
        return newsReleasePhotoList;
    }

    /**
     * 店舗情報の取得
     * @param  Id               targetId      店舗情報のId
     * @return Shop__c 取得結果
     */
    private static List<Shop__c> selectShopPhotoData(Id targetId){
        String sql = '';
        sql += 'SELECT Id ';
        // ▼問合せNo0535で変更
        // 店舗写真の9枚目（外観写真）はAPI 参照名で連番でないため除外
        for (Integer i = 1; i < CommonConst_ptl.MAXINDEX_SHOP; i++) {  // 店舗写真
        sql += ' ,    PhotoFileName' + i + '__c ';
        }
        sql += ' ,    AppearancePhotoFileName__c ';  // 外観写真
        // ▲問合せNo0535で変更
        sql += ' ,    ForeignID__c ';
        sql += ' FROM Shop__c ';
        sql += ' WHERE Id   = :targetId ';
        List<Shop__c> newsShopPhotoList = Database.query(sql);
        return newsShopPhotoList;
    }
    // ポータルサイト構築 追加 End

    /**
     * 建物写真情報から写真名の一覧取得
     * @param  BuildingPhoto__c buildingPhoto   建物オブジェクト
     * @return List<String>     写真名の一覧
     */
    private static List<String> getBuildingFilePathList(BuildingPhoto__c buildingPhoto) {
        List<BuildingPhoto__c> buildingPhotoList = new List<BuildingPhoto__c>();
        buildingPhotoList.add(buildingPhoto);
        return AmazonS3Util.getBuildingFilePathList(buildingPhotoList);
    }
    private static List<String> getBuildingFilePathList(List<BuildingPhoto__c> buildingPhotoList) {
        List<String> photoPathList = new List<String>();
        for (BuildingPhoto__c buildingPhoto : buildingPhotoList) {
            String filePath = S3FOLDERPATH_BUILDING_PROPERTY + buildingPhoto.Building__r.ForeignID__c;
            String fileName;
            fileName = buildingPhoto.AppearanceFileName__c;             // 建物外観
            if (!String.isEmpty(fileName)) {
                photoPathList.add(filePath + '/' + fileName);
            }
            fileName = buildingPhoto.AppearanceParseFileName__c;        // 建物外観パース
            if (!String.isEmpty(fileName)) {
                photoPathList.add(filePath + '/' + fileName);
            }
            fileName = buildingPhoto.EntranceFileName__c;               // 建物エントランス
            if (!String.isEmpty(fileName)) {
                photoPathList.add(filePath + '/' + fileName);
            }
            fileName = buildingPhoto.LobbyFileName__c;                  // 建物ロビー
            if (!String.isEmpty(fileName)) {
                photoPathList.add(filePath + '/' + fileName);
            }
            fileName = buildingPhoto.ParkingFileName__c;                // 建物駐車場
            if (!String.isEmpty(fileName)) {
                photoPathList.add(filePath + '/' + fileName);
            }
            fileName = buildingPhoto.OtherSharingFileName__c;           // 建物その他共有
            if (!String.isEmpty(fileName)) {
                photoPathList.add(filePath + '/' + fileName);
            }
            fileName = buildingPhoto.MapFileName__c;                    // 建物地図
            if (!String.isEmpty(fileName)) {
                photoPathList.add(filePath + '/' + fileName);
            }
            fileName = buildingPhoto.OtherFileName__c;                  // 建物その他
            if (!String.isEmpty(fileName)) {
                photoPathList.add(filePath + '/' + fileName);
            }
            for (Integer i = 1; i <= CommonConst.MAXINDEX_BUILDING_SURROUNDING; i++) {  // 建物周辺
                fileName = (String)buildingPhoto.get('SurroundingFileName' + i + '__c');
                if (!String.isEmpty(fileName)) {
                    photoPathList.add(filePath + '/' + fileName);
                }
            }
        }
        return photoPathList;
    }

    
    /**
     * 建物写真情報の写真関連項目のクリア
     * @param  Id               targetId    建物写真オブジェクトのId
     */
    private static void clearBuildingPhotoData(Id targetId) {
        List<Id> targetIdList = new List<Id>();
        targetIdList.add(targetId);
        AmazonS3Util.clearBuildingPhotoData(targetIdList);
    }
    private static void clearBuildingPhotoData(List<Id> targetIdList){
        List<BuildingPhoto__c> buildingPhotoList = new List<BuildingPhoto__c>();
        for (Id targetId : targetIdList) {
            BuildingPhoto__c buildingPhoto = new BuildingPhoto__c();
            buildingPhoto.Id = targetId;
            for (Integer i = 1; i <= CommonConst.MAXINDEX_BUILDING_SURROUNDING; i++) {  // 建物周辺
                buildingPhoto.put('SurroundingFileName' + i + '__c' , null);
                buildingPhoto.put('SurroundingTag' + i + '__c'      , null);
                buildingPhoto.put('SurroundingComment' + i + '__c'  , null);
                buildingPhoto.put('SurroundingPhotoName' + i + '__c', null);
                buildingPhoto.put('SurroundingDistance' + i + '__c' , null);
            }
            buildingPhoto.AppearanceFileName__c         = null;     // 建物外観
            buildingPhoto.AppearanceComment__c          = null;
            buildingPhoto.AppearanceParseFileName__c    = null;     // 建物外観パース
            buildingPhoto.AppearanceParseComment__c     = null;
            buildingPhoto.EntranceFileName__c           = null;     // 建物エントランス
            buildingPhoto.EntranceComment__c            = null;
            buildingPhoto.LobbyFileName__c              = null;     // 建物ロビー
            buildingPhoto.LobbyComment__c               = null;
            buildingPhoto.ParkingFileName__c            = null;     // 建物駐車場
            buildingPhoto.ParkingComment__c             = null;
            buildingPhoto.OtherSharingFileName__c       = null;     // 建物その他共有
            buildingPhoto.OtherSharingComment__c        = null;
            buildingPhoto.MapFileName__c                = null;     // 建物地図
            buildingPhoto.MapComment__c                 = null;
            buildingPhoto.OtherFileName__c              = null;     // 建物その他
            buildingPhoto.OtherComment__c               = null;            
            buildingPhotoList.add(buildingPhoto);
        }
        SecureDML.secureUpdate(buildingPhotoList);
    }



    /**
     * AmazonS3のオブジェクト移動命令の非同期実行
     */
    @future(callout=true)
    private static void moveS3File(String moveFromPath, String moveToPath, String moveToPrevPath) {
        // 移動元から移動先へコピー
        AmazonS3Util.callCopyReqest(moveFromPath, moveToPath);
        // 移動元ファイル・移動先の元ファイルを削除
        List<String> deletePathList = new List<String>();
        deletePathList.add(moveFromPath);
        if (!String.isEmpty(moveToPrevPath)) {
            deletePathList.add(moveToPrevPath);
        }
        if (!Test.isRunningTest()) {
            AmazonS3Util.callMultipleDeleteReqest(deletePathList);
        }
    }

    /**
     * AmazonS3のオブジェクト複数移動命令の非同期実行
     */
    @future(callout=true)
    private static void multipleMoveS3File(List<String> moveFromPathList, List<String> moveToPathList, List<String> moveToPrevPathList) {
        // 移動元から移動先へコピー
        for (Integer i = 0; i < moveFromPathList.size(); i++) {
            AmazonS3Util.callCopyReqest(moveFromPathList[i], moveToPathList[i]);
        }
        // 移動元ファイル・移動先の元ファイルを削除
        List<String> deletePathList = new List<String>();
        for (Integer i = 0; i < moveFromPathList.size(); i++) {
            deletePathList.add(moveFromPathList[i]);
            if (!String.isEmpty(moveToPrevPathList[i])) {
                deletePathList.add(moveToPrevPathList[i]);
            }
        }
        if (!Test.isRunningTest()) {
            AmazonS3Util.callMultipleDeleteReqest(deletePathList);
        }
    }

    /**
     * AmazonS3のオブジェクト削除命令の非同期実行
     */
    @future(callout=true)
    private static void deleteS3File(String deletePath) {
        AmazonS3Util.callDeleteReqest(deletePath);
    }

    /**
     * AmazonS3のオブジェクト複数削除命令の非同期実行
     */
    @future(callout=true)
    private static void multipleDeleteS3File(List<String> deletePathList) {
        AmazonS3Util.callMultipleDeleteReqest(deletePathList);
    }

    /**
     * AmazonS3のオブジェクト削除命令
     */
    private static void callDeleteReqest(String filePath) {
        AmazonS3Util.callRestAPI('DELETE', null, filePath, null, '', '', null);
    }

    /**
     * AmazonS3の複数オブジェクト削除命令
     */
    private static HTTPResponse callMultipleDeleteReqest(List<String> fileList) {
        // 削除オブジェクト指定のxml作成
        Xmlstreamwriter writer = new Xmlstreamwriter();
        writer.writeStartDocument('UTF-8', '1.0');      // <?xml version="1.0" encoding="UTF-8"?>
        writer.writeStartElement('', 'Delete', '');     // <Delete>
        writer.writeStartElement('', 'Quiet', '');      //   <Quiet>
        writer.writeCharacters('false');
        writer.writeEndElement();                       //   </Quiet>
        for (String key : fileList) {
            writer.writeStartElement('', 'Object', ''); //     <Object>
            writer.writeStartElement('', 'Key'   , ''); //       <Key>
            writer.writeCharacters(key);
            writer.writeEndElement();                   //       </Key>
            writer.writeEndElement();                   //     </Object>
        }
        writer.writeEndElement();                       // </Delet>
        writer.writeEndDocument();
        String xmlBody = writer.getXmlString();
        writer.close();

        // コンテンツサイズ取得
        Map<String, String> extHeader = new Map<String, String>{
            'Content-Length' => String.valueOf(Blob.valueOf(xmlBody).size())
        };

        // base64エンコードされたMD5ハッシュ値を取得
        String contentMd5 = EncodingUtil.base64Encode(Crypto.generateDigest('MD5', Blob.valueOf(xmlBody)));

        // 複数削除実行
        HTTPResponse response = AmazonS3Util.callRestAPI('POST', xmlBody, '?delete', null, 'application/xml', contentMd5, extHeader);
        return response;
    }

    /**
     * AmazonS3のオブジェクトコピー命令
     */
    private static HTTPResponse callCopyReqest(String copyFromFilePath, String copyToFilePath) {
        Map<String, String> extHeader = new Map<String, String> {
            'x-amz-copy-source' => '/' + AmazonS3Util.bucketName + '/' + copyFromFilePath
        };
        HTTPResponse response = AmazonS3Util.callRestAPI('PUT', null, copyToFilePath, new Map<String, String>(), '', '', extHeader);
        return response;
    }

    /**
     * AWSの基本RESTコールアウト
     */
    private static HTTPResponse callRestAPI(
        String command
        ,String body
        ,String resource
        ,Map<String, String> params
        ,String contentType
        ,String contentMd5
        ,Map<String, String> extHeader
    ) {
        // 現在日時取得
        String nowDateTime = DateTime.now().format('EEE, dd MMM yyyy HH:mm:ss ') + '+0900';

        // Httpリクエスト初期化
        String Signature = AmazonS3Util.getRestSignature(
                            command
                            ,contentMd5
                            ,contentType
                            ,nowDateTime
                            ,extHeader
                            ,resource);

        // Httpリクエスト作成
        HttpRequest request = new HttpRequest();
        request.setMethod(command);
        request.setHeader('Host'            , AmazonS3Util.bucketName + '.s3.amazonaws.com');
        request.setHeader('Date'            , nowDateTime);
        request.setHeader('Authorization'   , 'AWS ' + AmazonS3Util.accessKeyId + ':' + Signature);

        if (!String.isBlank(contentType)) {
            request.setHeader('Content-Type', contentType);
        }
        if (!String.isBlank(contentMd5)) {
            request.setHeader('Content-MD5', contentMd5);
        }
        if (extHeader != null) {
            for (String key : extHeader.keySet()) {
                request.setHeader(key, extHeader.get(key));
            }
        }
        if (params != null) {
            for (String key : params.keySet()) {
                request.setHeader(key, params.get(key));
            }
        }
        String endpoint = 'https://' + AmazonS3Util.bucketName + '.s3.amazonaws.com/' + resource;
        request.setEndpoint(endpoint);
        if(!String.isBlank(body)){
            request.setBody(body);
        }

        // Httpリクエスト送信
        Http http = new Http();
        HTTPResponse response = http.send(request);

        System.debug(response.getBody());

        // Httpレスポンス返却
        return response;
    }
    /**
     * REST用のsignature作成
     */
    private static String getRestSignature(
        String command
        ,String contentMd5
        ,String contentType
        ,String nowDateTime
        ,Map<String, String> params
        ,String resource
    ) {
        String canonicalizedAmzHeader = '';
        if (params != null) {
            for (String key : params.keySet()) {
                if (key.toLowerCase().indexOf('x-amz-') == -1) {
                    continue;
                }
                canonicalizedAmzHeader += key.toLowerCase() + ':' + params.get(key) + '\n';
            }
        }
        String stringToSign = command + '\n'
                            + AmazonS3Util.nullToBlank(contentMd5) + '\n'
                            + AmazonS3Util.nullToBlank(contentType) + '\n'
                            + nowDateTime + '\n'
                            + canonicalizedAmzHeader
                            + '/' + AmazonS3Util.bucketName + '/' + resource;


        return EncodingUtil.base64Encode(
            Crypto.generateMac(
                'HMacSHA1', 
                Blob.valueOf(stringToSign),
                Blob.valueOf(AmazonS3Util.secretAccessKey)
            )
        );
    }

    private static String nullToBlank(String str){
        if(String.isEmpty(str)){
            return '';
        }else{
            return str;
        }
    }

    /**
     * 写真保存処理
     * 
     * @param  String   photoType   ファイルの種類
     * @return なし
     */
    public static void savePhoto(GD901001ParameterClass GD901001param) {
        if (GD901001param.photoType == CommonConst.S3_PHOTOTYPE_BUILDING) {
            AmazonS3Util.saveBildingPhoto(GD901001param);
        } else if(GD901001param.photoType == CommonConst.S3_PHOTOTYPE_PROPERTY) {
            AmazonS3Util.savePropertyPhoto(GD901001param);
        } else if(GD901001param.photoType == CommonConst.S3_PHOTOTYPE_HOSPITAL) {
            AmazonS3Util.saveHospital(GD901001param);
        } else if(GD901001param.photoType == CommonConst.S3_PHOTOTYPE_SCHOOL) {
            AmazonS3Util.saveSchool(GD901001param);
        } else if(GD901001param.photoType == CommonConst.S3_PHOTOTYPE_STATION) {
            AmazonS3Util.saveStation(GD901001param);
        } else if(GD901001param.photoType == CommonConst.S3_PHOTOTYPE_SURROUNDING_FACILITY) {
            AmazonS3Util.saveSurrounding(GD901001param);
            // ポータルサイト構築 追加 Start
        } else if(GD901001param.photoType == CommonConst_ptl.S3_PHOTOTYPE_NEWSRELEASE) {
            AmazonS3Util.saveNewsReleasePhoto(GD901001param);
        } else if(GD901001param.photoType == CommonConst_ptl.S3_PHOTOTYPE_SHOP) {
            AmazonS3Util.saveShopPhoto(GD901001param);
            // ポータルサイト構築 追加 End
        }
    }

	// ▼ 2022.2.21 LINE連携対応より、追加
	/**
	 * ファイルの存在チェック
	 * @param String filePath ドメイン名からのファイルパス
	 * @return Boolean true:存在する、false:存在しない
	 */
	public static Boolean isExistsFile(String filePath) {

		HTTPResponse response;
		try {
			// ファイルの取得
			response = AmazonS3Util.callRestAPI(
				'GET'
				, null
				, filePath
				, new Map<String, String>()
				, CommonConst.STRING_EMPTY
				, CommonConst.STRING_EMPTY
				, null
			);
		} catch (CalloutException ex) {
			// コールアウト応答の最大サイズ対応
			// ※ファイルは存在している為、正常と判断
			if (CommonConst.GOVERNOR_API_LIMIT_SIZE_MSG.equals(ex.getMessage())) {
				return true;
			}

			// 上記以外は例外をスロー
			throw ex;
		}
		
		// 取得結果の返却
		return (response.getStatusCode() >= 200 && response.getStatusCode() <= 299);
	}
	// ▲ 2022.2.21

	// ▼ 2022.1.13 LINE連携対応より、追加
	/**
	 * バケット名の取得
	 * @return String バケット名
	 */
	public static String getBucketName() {
		return bucketName;
	}

	/**
	 * アクセスキーの取得
	 * @return String アクセスキー
	 */
	public static String getAccessKeyId() {
		return accessKeyId;
	}

	/**
	 * シークレットキーの取得
	 * @return String シークレットキー
	 */
	public static String getSecretAccessKey() {
		return secretAccessKey;
	}

	/**
	 * リージョンの取得
	 * @return String リージョン
	 */
	public static String getRegion() {
		return region;
	}

	/**
	 * AmazonS3のURLの取得
	 * @return String AmazonS3のURL
	 */
	public static String getS3Url() {
		return CommonUtil.callMessageCreate('https://{0}.s3.amazonaws.com/', bucketName);
	}

	/**
	 * AmazonS3のLINE連携用ドメインの取得
	 * @return String AmazonS3のLINE連携用ドメイン
	 */
	public static String getS3LineDomain() {
		return SystemConfig__c.getInstance().S3RootDirectory__c + '/public/salesforce/line/'; 
	}

	/**
	 * AmazonS3のLINE連携用URLの取得
	 * @return String AmazonS3のLINE連携用URL
	 */
	public static String getS3LineUrl() {
		return getS3Url() + getS3LineDomain(); 
	}
	// ▲ 2022.1.13

    /**
     * 建物写真 保存
     * @param   なし
     * @return  なし
     */
    private static void saveBildingPhoto(GD901001ParameterClass GD901001param) {
        // ファイル名を分割
        List<String> fileNameList = GD901001param.fileName.split(',');
        // タグ分割
        List<String> tagList      = GD901001param.fileTag.split(',');
        BuildingPhoto__c obj = new BuildingPhoto__c();

        // 写真オブジェクト取得
        Id BuildingId  = [SELECT ID FROM Building__c WHERE ForeignID__c = :GD901001param.foreignId LIMIT 1].Id;
        obj.Building__c = BuildingId;
        List<BuildingPhoto__c> photoObjList = AmazonS3Util.selectBildingPhotoBuildingId(BuildingId);

        if (photoObjList.size() > 0) {
            obj = photoObjList[0];
        }
        // データセット
        String fileName;
        for (Integer i = 0; i < fileNameList.size(); i++) {
            if (GD901001param.photoSubType == CommonConst.S3_BUILDINGPHOTOTYPE_APPEARANCE) {
                obj.AppearanceFileName__c = fileNameList[i];
            } else if(GD901001param.photoSubType == CommonConst.S3_BUILDINGPHOTOTYPE_APPEARANCE_PARSE) {
                obj.AppearanceParseFileName__c = fileNameList[i];
            } else if(GD901001param.photoSubType == CommonConst.S3_BUILDINGPHOTOTYPE_ENTRANCE) {
                obj.EntranceFileName__c = fileNameList[i];
            } else if(GD901001param.photoSubType == CommonConst.S3_BUILDINGPHOTOTYPE_LOBBY) {
                obj.LobbyFileName__c = fileNameList[i];
            } else if(GD901001param.photoSubType == CommonConst.S3_BUILDINGPHOTOTYPE_PARKING) {
                obj.ParkingFileName__c = fileNameList[i];
            } else if(GD901001param.photoSubType == CommonConst.S3_BUILDINGPHOTOTYPE_OTHERSHARING) {
                obj.OtherSharingFileName__c = fileNameList[i];
            } else if(GD901001param.photoSubType == CommonConst.S3_BUILDINGPHOTOTYPE_MAP) {
                obj.MapFileName__c = fileNameList[i];
            } else if(GD901001param.photoSubType == CommonConst.S3_BUILDINGPHOTOTYPE_OTHER) {
                obj.OtherFileName__c = fileNameList[i];
            } else if(GD901001param.photoSubType == CommonConst.S3_BUILDINGPHOTOTYPE_SURROUNDING) {
                for (Integer j = 1; j <= CommonConst.MAXINDEX_BUILDING_SURROUNDING; j++) {
                    fileName = (String)obj.get('SurroundingFileName' + j + '__c');
                    if (String.isEmpty(fileName)) {
                        obj.put('SurroundingFileName' + j + '__c'  , fileNameList[i]);
                        break;
                    }
                }
            }
        }
        SecureDML.secureUpsert(obj);
    }

    /**
     * 物件写真 保存
     * @param   なし
     * @return  なし
     */
    private static void savePropertyPhoto(GD901001ParameterClass GD901001param) {
        List<String> fileNameList = GD901001param.fileName.split(',');
        List<String> fileTagList  = GD901001param.fileTag.split(',');

        PropertyPhoto__c obj = new PropertyPhoto__c();
        obj.Property__c = [SELECT ID FROM Property__c WHERE ForeignID__c = :GD901001param.foreignId2].Id;

        //既存データ取得
        List<PropertyPhoto__c> objList = AmazonS3Util.selectPropertyPhotoPropertyId(obj.Property__c);
        if (objList.size() > 0) {
            obj = objList[0];
        }
        String fileName;
        for (Integer i = 0; i < fileNameList.size(); i++) {
            if (GD901001param.photoSubType == CommonConst.S3_PROPERTYPHOTOTYPE_PROPERTPHOTO) {  // 物件写真
                for (Integer j = 1; j <= CommonConst.MAXINDEX_PROPERTY_PROPERTY; j++) {          
                    fileName = (String)obj.get('PropertyPhotoFileName' + j + '__c');
                    if (String.isEmpty(fileName)) {
                        obj.put('PropertyPhotoFileName' + j + '__c', fileNameList[i]);
                        obj.put('PropertyPhotoFileName' + j + '__c', fileNameList[i]);
                        if ( i < fileTagList.size()) {
                            obj.put('PropertyPhotoTag' + j + '__c', AmazonS3Util.convLableingToTag(fileTagList[i]));
                        }
                        break;
                    }
                }

                obj.put('PropertyPhotoLastModifiedDate__c',CommonUtil.getNow()); //問合せNo.0773対応 2022/04/25 

            } else if(GD901001param.photoSubType == CommonConst.S3_PROPERTYPHOTOTYPE_PANORAMA) {    // パノラマ写真
                for (Integer j = 1; j <= CommonConst.MAXINDEX_PROPERTY_PANORAMA; j++) {          
                    fileName = (String)obj.get('PanoramaFileName' + j + '__c');
                    if (String.isEmpty(fileName)) {
                        obj.put('PanoramaFileName' + j + '__c', fileNameList[i]);
                        break;
                    }
                }
            } else if(GD901001param.photoSubType == CommonConst.S3_PROPERTYPHOTOTYPE_PRIVATEPHOTO) {    // 非公開写真
                for (Integer j = 1; j <= CommonConst.MAXINDEX_PROPERTY_PRIVATE; j++) {          
                    fileName = (String)obj.get('PrivatePhotoFileName' + j + '__c');
                    if (String.isEmpty(fileName)) {
                        obj.put('PrivatePhotoFileName' + j + '__c', fileNameList[i]);
                        break;
                    }
                }
            } else if(GD901001param.photoSubType == CommonConst.S3_PROPERTYPHOTOTYPE_ROOMLAYOUT) {
                obj.RoomLayoutFileName__c = fileNameList[i];
            } else if(GD901001param.photoSubType == CommonConst.S3_PROPERTYPHOTOTYPE_ROOMLAYOUTMEMO) {
                obj.RoomLayoutMemoFileName__c = fileNameList[i];
            }
        }
        SecureDML.secureUpsert(obj);
    }


    /**
     * ラベリング文字列変更
     */
    private static String convLableingToTag(String labeling) {
        String tag = null;
        if (labeling == CommonConst.PROPERTYPHOTO_LABELING_KITCHEN) {               // キッチン
            tag = CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_KITCHEN;
        } else if(labeling == CommonConst.PROPERTYPHOTO_LABELING_OTHERROOMS) {      // その他部屋・スペース
            tag = CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_OTHERROOM;
        } else if(labeling == CommonConst.PROPERTYPHOTO_LABELING_TOILET) {          // トイレ
            tag = CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_TOILET;
        } else if(labeling == CommonConst.PROPERTYPHOTO_LABELING_BATH) {            // バス・シャワールーム
            tag = CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_BATH;
        } else if(labeling == CommonConst.PROPERTYPHOTO_LABELING_BALCONY) {         // バルコニー
            tag = CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_BALCONY;
        } else if(labeling == CommonConst.PROPERTYPHOTO_LABELING_LIVING) {          // 居室・リビング
            tag = CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_LIVING;
        } else if(labeling == CommonConst.PROPERTYPHOTO_LABELING_ENTRANCE) {        // 玄関
            tag = CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_ENTRANCE;
        } else if(labeling == CommonConst.PROPERTYPHOTO_LABELING_STORAGE) {         // 収納
            tag = CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_STORAGE;
        } else if(labeling == CommonConst.PROPERTYPHOTO_LABELING_WASHBASIN) {       // 洗面設備
            tag = CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_WASHROOM;
        }
        return tag;
    }

    /**
     * 病院写真 保存
     * @param   なし
     * @return  なし
     */
    private static void saveHospital(GD901001ParameterClass GD901001param) {
        // ファイル名,パスをリスト化　※病院は写真1のみである為、複数の場合は要素数0のみ登録
        List<String> fileNameList = GD901001param.fileName.split(',');

        // 病院のデータは必ず存在する。※登録がないと、写真が登録できない仕様の為
        Hospital__c obj = [SELECT  ID , PhotoFileName__c
                             FROM  Hospital__c
                            WHERE  ForeignID__c = :GD901001param.foreignId
                            LIMIT  1
                          ];
        obj.PhotoFileName__c = fileNameList[0];
        SecureDML.secureUpsert(obj);
    }

    /**
     * 学校写真 保存
     * @param   なし
     * @return  なし
     */
    private static void saveSchool(GD901001ParameterClass GD901001param) {
        // ファイル名をリスト化　※学校は写真1のみである為、複数の場合は要素数0のみ登録
        List<String> fileNameList = GD901001param.fileName.split(',');

        // 学校のデータは必ず存在する。※登録がないと、写真が登録できない仕様の為
        School__c obj = [SELECT  ID , PhotoFileName__c
                           FROM  School__c
                          WHERE  ForeignID__c = :GD901001param.foreignId
                          LIMIT  1
                        ];
        obj.PhotoFileName__c = fileNameList[0];
        SecureDML.secureUpsert(obj);
    }

    /**
     * 駅写真 保存
     * @param   なし
     * @return  なし
     */
    private static void saveStation(GD901001ParameterClass GD901001param) {
        // ファイル名をリスト化　※駅は写真1のみである為、複数の場合は要素数0のみ登録
        List<String> fileNameList = GD901001param.fileName.split(',');

        // 駅のデータは必ず存在する。※登録がないと、写真が登録できない仕様の為
        Station__c obj = [SELECT  ID , PhotoFileName__c
                             FROM  Station__c
                            WHERE  ForeignID__c = :GD901001param.foreignId
                            LIMIT  1
                          ];
        obj.PhotoFileName__c = fileNameList[0];
        SecureDML.secureUpsert(obj);
    }

    /**
     * 周辺施設 保存
     * @param   なし
     * @return  なし
     */
    private static void saveSurrounding(GD901001ParameterClass GD901001param) {
        // ファイル名をリスト化　※学校は写真1のみである為、複数の場合は要素数0のみ登録
        List<String> fileNameList = GD901001param.fileName.split(',');

        // 周辺施設のデータは必ず存在する。※登録がないと、写真が登録できない仕様の為
        SurroundingFacility__c obj = [SELECT  ID , PhotoFileName__c
                                        FROM  SurroundingFacility__c
                                       WHERE  ForeignID__c = :GD901001param.foreignId
                                       LIMIT  1
                                    ];
        obj.PhotoFileName__c = fileNameList[0];
        SecureDML.secureUpsert(obj);
    }

    // ポータルサイト構築 追加 Start
    /**
     * ニュースリリース写真 保存
     * @param   なし
     * @return  なし
     */
    private static void saveNewsReleasePhoto(GD901001ParameterClass GD901001param) {
        // ファイル名をリスト化　※学校は写真1のみである為、複数の場合は要素数0のみ登録
        List<String> fileNameList = GD901001param.fileName.split(',');

        // 周辺施設のデータは必ず存在する。※登録がないと、写真が登録できない仕様の為
        NewsRelease__c obj = [SELECT ID , ReleasePhotoFileName1__c
                                        , ReleasePhotoFileName2__c
                                        , ReleasePhotoFileName3__c
                                        , ReleasePhotoFileName4__c
                                        , ReleasePhotoFileName5__c
                                        , ReleasePhotoFileName6__c
                                        , ReleasePhotoFileName7__c //2022.4.1 No754 サムネイル追加
                                        FROM  NewsRelease__c
                                        WHERE  ForeignID__c = :GD901001param.foreignId
                                        LIMIT  1
                                    ];

        String fileName = (String)obj.get('ReleasePhotoFileName' + GD901001param.parameter + '__c');
        if (String.isEmpty(fileName)) {
            obj.put('ReleasePhotoFileName' + GD901001param.parameter + '__c', fileNameList[0]);
        }
        
        SecureDML.secureUpsert(obj);
    }

    /**
     * 店舗写真 保存
     * @param   なし
     * @return  なし
     */
    private static void saveShopPhoto(GD901001ParameterClass GD901001param) {
        // ファイル名をリスト化　
        List<String> fileNameList = GD901001param.fileName.split(',');

        Shop__c obj = [SELECT ID , PhotoFileName1__c
                                 , PhotoFileName2__c
                                 , PhotoFileName3__c
                                 , PhotoFileName4__c
                                 , PhotoFileName5__c
                                 , PhotoFileName6__c
                                 , PhotoFileName7__c
                                 , PhotoFileName8__c
                                 , AppearancePhotoFileName__c   //問合せNo0535で追加
                                 FROM  Shop__c
                                 WHERE  ForeignID__c = :GD901001param.foreignId
                                 LIMIT  1
                            ];

        
        //▼問合せNo0535で変更 外観写真は含めない
        // 外観写真のみ
        if(GD901001param.parameter == '9'){
            obj.put('AppearancePhotoFileName__c', fileNameList[0]);
        }else{
            String fileName = (String)obj.get('PhotoFileName' + GD901001param.parameter + '__c');
            if (String.isEmpty(fileName)) {
                obj.put('PhotoFileName' + GD901001param.parameter + '__c', fileNameList[0]);
            }
        }
        //▲問合せNo0535で変更
        
        SecureDML.secureUpsert(obj);
    }
    // ポータルサイト構築 追加 End

    /**
     * 建物写真をSELECT
     * 　建物IDを元に、建物写真を取得する
     * @param   建物ID
     * @return  List<BuildingPhoto__c>   検索結果
     */
    private static List<BuildingPhoto__c> selectBildingPhotoBuildingId(Id targetId) {
        Set<Id> setId = new Set<Id>();
        setId.add(targetId);
        return selectBildingPhotoBuildingId(setId);
    }
     private static List<BuildingPhoto__c> selectBildingPhotoBuildingId(Set<Id> targetSetId) {
        return [SELECT ID
                    , Building__c
                    , AppearanceFileName__c
                    , AppearanceParseFileName__c
                    , EntranceFileName__c
                    , LobbyFileName__c
                    , ParkingFileName__c
                    , OtherSharingFileName__c
                    , MapFileName__c
                    , OtherFileName__c
                    , SurroundingFileName1__c
                    , SurroundingFileName2__c
                    , SurroundingFileName3__c
                    , SurroundingFileName4__c
                    , SurroundingFileName5__c
                    , ForeignID__c
                FROM  BuildingPhoto__c
                WHERE  Building__c IN :targetSetId
        ];
    }

    /**
     * 物件写真をSELECT
     * 　物件IDを元に、物件写真を取得する
     * @param   物件ID
     * @return  List<PropetyPhoto__c>   検索結果
     */
    private static List<PropertyPhoto__c> selectPropertyPhotoPropertyId(Id targetId) {
        Set<Id> setId = new Set<Id>();
        setId.add(targetId);
        return selectPropertyPhotoPropertyId(setId);
    }
    private static List<PropertyPhoto__c> selectPropertyPhotoPropertyId(Set<Id> targetSetId) {
        return [SELECT Id
                    , Property__c
                    , PropertyPhotoFileName1__c
                    , PropertyPhotoFileName2__c
                    , PropertyPhotoFileName3__c
                    , PropertyPhotoFileName4__c
                    , PropertyPhotoFileName5__c
                    , PropertyPhotoFileName6__c
                    , PropertyPhotoFileName7__c
                    , PropertyPhotoFileName8__c
                    , PropertyPhotoFileName9__c
                    , PropertyPhotoFileName10__c
                    , PropertyPhotoFileName11__c
                    , PropertyPhotoFileName12__c
                    , PropertyPhotoFileName13__c
                    , PropertyPhotoFileName14__c
                    , PropertyPhotoFileName15__c
                    , PropertyPhotoFileName16__c
                    , PropertyPhotoFileName17__c
                    , PropertyPhotoFileName18__c
                    , PropertyPhotoFileName19__c
                    , PropertyPhotoFileName20__c
                    , RoomLayoutFileName__c
                    , RoomLayoutMemoFileName__c
                    , PanoramaFileName1__c
                    , PanoramaFileName2__c
                    , PanoramaFileName3__c
                    , PanoramaFileName4__c
                    , PanoramaFileName5__c
                    , PrivatePhotoFileName1__c
                    , PrivatePhotoFileName2__c
                    , PrivatePhotoFileName3__c
                    , PrivatePhotoFileName4__c
                    , PrivatePhotoFileName5__c
                    , PrivatePhotoFileName6__c
                    , PrivatePhotoFileName7__c
                    , PrivatePhotoFileName8__c
                    , ForeignID__c
                    , ForeignIDAutoNumber__c
                FROM  PropertyPhoto__c
               WHERE  Property__c IN :targetSetId
        ];
    }
}