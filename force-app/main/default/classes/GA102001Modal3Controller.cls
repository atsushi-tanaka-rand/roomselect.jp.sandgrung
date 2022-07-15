/**
 * お気に入り物件画面
 */
public with sharing class GA102001Modal3Controller {
    //Public変数
        
    /** 共通クラス */    
    public GA102001Modal3ParameterClass Parameter { get; set; }
    
    public Boolean isOpenError { get; set; }           //エラーフラグ
    public Boolean hasErrorMessage { get; set; }       //エラーメッセージ保有フラグ

    public screenFavoriteProperty screenFavoriteProperty { get; set; }

    public List<SelectOption> selectStatus { get; set; }

    public String MSG_COM_V_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_SAVE);} private set;}   // 登録確認メッセージ
    public String MSG_COM_I_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);} private set;}   // 登録完了メッセ―じ

    public Boolean init{
        get{

            if (Parameter.isDrawing) {
                getSelectOption();
                Parameter.isDrawing = false;
                return false;
            }
            return true;
        }
    }
    /** お気に入り物件の取得 */    
    public void getSelectOption(){
        isOpenError = false;
        try{

            // ステータスのリストを取得
            selectStatus = CommonUtil.getSelectOptionFromObject('FavoriteProperty__c', 'Status__c');

            // お気に入り物件の取得
            List<FavoriteProperty__c> FavoriteProperty = new List<FavoriteProperty__c>();
            FavoriteProperty = getFavoritePropertyList(Parameter.FavoritePropertyId);

            // 各項目への設定
            for(FavoriteProperty__c selectData:FavoriteProperty){
                screenFavoriteProperty = new screenFavoriteProperty(selectData);
            }
            
        } catch (Exception e) {
            // エラーを設定
            isOpenError = true;
            CommonUtil.setErrorMessage(e);

        }
    }

    /**
     * 検索処理
     * 引数　　：　Id String お気に入り物件ID
     * 戻り値　：　List<FavoriteProperty__c> お気に入り物件のデータ
     */
     private List<FavoriteProperty__c> getFavoritePropertyList(String Id){
        string sql = '';
        sql += 'SELECT ID';                             // お気に入り番号（非表示）
        sql += '      ,systemModStamp               ';    // お気に入り物件.SystemModstamp（非表示）
        sql += '      ,Property__r.Building__r.name ';  // お気に入り物件.物件.建物.建物名
        sql += '      ,Property__r.name             ';  // お気に入り物件.物件.部屋番号
        sql += '      ,PropertyStatus__c            ';  // お気に入り物件.状況
        sql += '      ,Address__c                   ';  // お気に入り物件.住所
        sql += '      ,RentFee__c                   ';  // お気に入り物件.賃料
        sql += '      ,NearestStation__c            ';  // お気に入り物件.最寄駅
        sql += '      ,BuildingYM__c                ';  // お気に入り物件.築年
        sql += '      ,ParkingFee__c                ';  // お気に入り物件.駐車場
        sql += '      ,Status__c                    ';  // お気に入り物件.ステータス
        sql += '      ,PreviewImpression__c         ';  // お気に入り物件.内見感想
        sql += 'FROM   FavoriteProperty__c          ';  // お気に入り物件
        sql += 'WHERE  ID  = \'' + Id + '\'         ';  // お気に入り物件.ID

        return Database.query(sql);

     }
     
    /**
     * お気に入り物件更新処理
     */
    public void saveDate(){
        Savepoint sp = Database.setSavepoint();    // セーブポイント作成
        hasErrorMessage = false;
        try{

            //楽観ロックチェックExceptionを発行
            List<FavoriteProperty__c> checkOptimisticLockExceptionRecord = new List<FavoriteProperty__c>();
            checkOptimisticLockExceptionRecord = [ SELECT id
                                                        FROM FavoriteProperty__c
                                                        WHERE id = :Parameter.favoritePropertyId
                                                        AND SystemModStamp = :screenFavoriteProperty.systemModStamp ];                //楽観ロックチェック
            if (checkOptimisticLockExceptionRecord.isEmpty()){
                OptimisticLockException ex = new OptimisticLockException();
                throw ex;
            }

            // お気に入り物件の更新
            FavoriteProperty__c saveDate = new FavoriteProperty__c();

            saveDate.id = screenFavoriteProperty.Id;
            saveDate.Status__c = screenFavoriteProperty.Status;
            saveDate.PreviewImpression__c = screenFavoriteProperty.PreviewImpression;

            SecureDML.secureUpsert(savedate);

        }catch(Exception e){
            database.rollback(sp);
            hasErrorMessage = True;
            CommonUtil.setErrorMessage(e);
        }
    }

    
    /**
     * お気に入り物件表示用内部クラス
     */
    public class screenFavoriteProperty {
        private FavoriteProperty__c targetFavoritePropertyRecord;    //レコード本体（お気に入り物件）
        
        //以下、画面用の項目
        
        public String  Id                   { get; set; }    // お気に入りID（非表示）
        public datetime  systemModStamp     { get; set; }    // お気に入り物件.SystemModstamp（非表示）
        public String  PropertyBuildingname { get; set; }    // お気に入り物件.物件.建物.建物名
        public String  Propertyname         { get; set; }    // お気に入り物件.物件.部屋番号
        public String  Property             { get; set; }    // 建物名＋部屋番号
        public String  PropertyStatus       { get; set; }    // お気に入り物件.状況
        public String  Address              { get; set; }    // お気に入り物件.住所
        public String  RentFee              { get; set; }    // お気に入り物件.賃料
        public String  NearestStation       { get; set; }    // お気に入り物件.最寄駅
        public String  BuildingYM           { get; set; }    // お気に入り物件.築年
        public String  ParkingFee           { get; set; }    // お気に入り物件.駐車場
        public String  Status               { get; set; }    // お気に入り物件.ステータス
        public String  PreviewImpression    { get; set; }    // お気に入り物件.内見感想

        //コンストラクタ
        public screenFavoriteProperty(FavoriteProperty__c targetFavoritePropertyRecord){
            //レコードの連動
            this.Id                   = targetFavoritePropertyRecord.Id                           ; // お気に入りID（非表示）
            this.systemModStamp       = targetFavoritePropertyRecord.systemModStamp               ; // お気に入り物件.SystemModstamp（非表示）
            this.PropertyBuildingname = targetFavoritePropertyRecord.Property__r.Building__r.name ; // お気に入り物件.物件.建物.建物名
            this.Propertyname         = targetFavoritePropertyRecord.Property__r.name             ; // お気に入り物件.物件.部屋番号
            this.Property             = String.isEmpty(targetFavoritePropertyRecord.Property__r.Building__r.name)? CommonConst.STRING_EMPTY : targetFavoritePropertyRecord.Property__r.Building__r.name;
            this.Property            += String.isEmpty(targetFavoritePropertyRecord.Property__r.name )? CommonConst.STRING_EMPTY : ' '+targetFavoritePropertyRecord.Property__r.name;
            this.PropertyStatus       = targetFavoritePropertyRecord.PropertyStatus__c            ; // お気に入り物件.状況
            this.Address              = targetFavoritePropertyRecord.Address__c                   ; // お気に入り物件.住所
            this.RentFee              = CommonUtil.decimalToString(targetFavoritePropertyRecord.RentFee__c); // お気に入り物件.賃料
            this.NearestStation       = targetFavoritePropertyRecord.NearestStation__c            ; // お気に入り物件.最寄駅
            this.BuildingYM           = targetFavoritePropertyRecord.BuildingYM__c                ; // お気に入り物件.築年
            this.ParkingFee           = CommonUtil.decimalToString(targetFavoritePropertyRecord.ParkingFee__c); // お気に入り物件.駐車場
            this.Status               = targetFavoritePropertyRecord.Status__c                    ; // お気に入り物件.ステータス
            this.PreviewImpression    = targetFavoritePropertyRecord.PreviewImpression__c         ; // お気に入り物件.内見感想

        }
    }

}