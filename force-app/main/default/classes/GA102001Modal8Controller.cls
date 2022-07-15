/**
 * 条件完全一致物件画面
 */
public with sharing class GA102001Modal8Controller {
    //Public変数
        
    /** 共通クラス */    
    public GA102001Modal8ParameterClass Parameter { get; set; }
    
    public Boolean isOpenError { get; set; }           //エラーフラグ
    public Boolean hasErrorMessage { get; set; }       //エラーメッセージ保有フラグ

    public screenExactConditionMatchProperty screenExactConditionMatchProperty { get; set; }

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
    /** 条件完全一致物件の取得 */    
    public void getSelectOption(){
        isOpenError = false;
        try{

            // ステータスのリストを取得
            selectStatus = CommonUtil.getSelectOptionFromObject('ExactConditionMatchProperty__c', 'Status__c');

            // 条件完全一致物件の取得
            List<ExactConditionMatchProperty__c> exactConditionMatchProperty = new List<ExactConditionMatchProperty__c>();
            exactConditionMatchProperty = getExactConditionMatchPropertyList(Parameter.ExactConditionMatchPropertyId);

            // 各項目への設定
            for(ExactConditionMatchProperty__c selectData : ExactConditionMatchProperty){
                screenExactConditionMatchProperty = new screenExactConditionMatchProperty(selectData);
            }
            
        } catch (Exception e) {
            // エラーを設定
            isOpenError = true;
            CommonUtil.setErrorMessage(e);

        }
    }

    /**
     * 検索処理
     * 引数　　：　Id String条件完全一致物件ID
     * 戻り値　：　List<ExactConditionMatchProperty__c> 条件完全一致物件のデータ
     */
     private List<ExactConditionMatchProperty__c> getExactConditionMatchPropertyList(String Id){
        string sql = '';
        sql += 'SELECT ID';                               // 条件完全一致物件番号（非表示）
        sql += '      ,systemModStamp                 ';  // 条件完全一致物件.SystemModstamp（非表示）
        sql += '      ,Property__r.Building__r.name   ';  // 条件完全一致物件.物件.建物.建物名
        sql += '      ,Property__r.name               ';  // 条件完全一致物件.物件.部屋番号
        sql += '      ,PropertyStatus__c              ';  // 条件完全一致物件.状況
        sql += '      ,Address__c                     ';  // 条件完全一致物件.住所
        sql += '      ,RentFee__c                     ';  // 条件完全一致物件.賃料
        sql += '      ,NearestStation__c              ';  // 条件完全一致物件.最寄駅
        sql += '      ,BuildingYM__c                  ';  // 条件完全一致物件.築年
        sql += '      ,ParkingFee__c                  ';  // 条件完全一致物件.駐車場
        sql += '      ,Status__c                      ';  // 条件完全一致物件.ステータス
        sql += '      ,IntroductionImpression__c      ';  // 条件完全一致物件.紹介感想
        sql += 'FROM   ExactConditionMatchProperty__c ';  // 条件完全一致物件
        sql += 'WHERE  ID  = \'' + Id + '\'         ';    // 条件完全一致物件.ID

        return Database.query(sql);

     }
     
    /**
     * 条件完全一致物件更新処理
     */
    public void saveDate(){
        Savepoint sp = Database.setSavepoint();    // セーブポイント作成
        hasErrorMessage = false;
        try{
            //楽観ロックチェックExceptionを発行
            List<ExactConditionMatchProperty__c> checkOptimisticLockExceptionRecord = new List<ExactConditionMatchProperty__c>();
            checkOptimisticLockExceptionRecord = [ SELECT id
                                                   FROM ExactConditionMatchProperty__c
                                                   WHERE id = :Parameter.exactConditionMatchPropertyId
                                                   AND SystemModStamp = :screenExactConditionMatchProperty.systemModStamp ];                
            if (checkOptimisticLockExceptionRecord.isEmpty()){
                OptimisticLockException ex = new OptimisticLockException();
                throw ex;
            }

            // 条件完全一致物件の更新
            ExactConditionMatchProperty__c saveDate = new ExactConditionMatchProperty__c();

            saveDate.id = screenExactConditionMatchProperty.Id;
            saveDate.Status__c = screenExactConditionMatchProperty.Status;
            saveDate.IntroductionImpression__c = screenExactConditionMatchProperty.IntroductionImpression;

            SecureDML.secureUpsert(savedate);

        }catch(Exception e){
            database.rollback(sp);
            hasErrorMessage = True;
            CommonUtil.setErrorMessage(e);
        }
    }

    
    /**
     * 条件完全一致物件表示用内部クラス
     */
    public class screenExactConditionMatchProperty {
        //以下、画面用の項目
        public String  Id                     { get; set; }    // 条件完全一致物件ID（非表示）
        public datetime  systemModStamp       { get; set; }    // 条件完全一致物件.SystemModstamp（非表示）
        public String  PropertyBuildingname   { get; set; }    // 条件完全一致物件.物件.建物.建物名
        public String  Propertyname           { get; set; }    // 条件完全一致物件.物件.部屋番号
        public String  Property               { get; set; }    // 建物名＋部屋番号
        public String  PropertyStatus         { get; set; }    // 条件完全一致物件.状況
        public String  Address                { get; set; }    // 条件完全一致物件.住所
        public String  RentFee                { get; set; }    // 条件完全一致物件.賃料
        public String  NearestStation         { get; set; }    // 条件完全一致物件.最寄駅
        public String  BuildingYM             { get; set; }    // 条件完全一致物件.築年
        public String  ParkingFee             { get; set; }    // 条件完全一致物件.駐車場
        public String  Status                 { get; set; }    // 条件完全一致物件.ステータス
        public String  IntroductionImpression { get; set; }    // 条件完全一致物件.紹介感想

        //コンストラクタ
        public screenExactConditionMatchProperty(ExactConditionMatchProperty__c targetExactCondMatchPropRecord){
            //レコードの連動
            this.Id                     = targetExactCondMatchPropRecord.Id                           ; // 条件完全一致物件ID（非表示）
            this.systemModStamp         = targetExactCondMatchPropRecord.systemModStamp               ; // 条件完全一致物件.SystemModstamp（非表示）
            this.PropertyBuildingname   = targetExactCondMatchPropRecord.Property__r.Building__r.name ; // 条件完全一致物件.物件.建物.建物名
            this.Propertyname           = targetExactCondMatchPropRecord.Property__r.name             ; // 条件完全一致物件.物件.部屋番号
            this.Property               = String.isEmpty(targetExactCondMatchPropRecord.Property__r.Building__r.name)? CommonConst.STRING_EMPTY : targetExactCondMatchPropRecord.Property__r.Building__r.name;
            this.Property              += String.isEmpty(targetExactCondMatchPropRecord.Property__r.name )? CommonConst.STRING_EMPTY : ' '+targetExactCondMatchPropRecord.Property__r.name;
            this.PropertyStatus         = targetExactCondMatchPropRecord.PropertyStatus__c            ; // 条件完全一致物件.状況
            this.Address                = targetExactCondMatchPropRecord.Address__c                   ; // 条件完全一致物件.住所
            this.RentFee                = CommonUtil.decimalToString(targetExactCondMatchPropRecord.RentFee__c); // 条件完全一致物件.賃料
            this.NearestStation         = targetExactCondMatchPropRecord.NearestStation__c            ; // 条件完全一致物件.最寄駅
            this.BuildingYM             = targetExactCondMatchPropRecord.BuildingYM__c                ; // 条件完全一致物件.築年
            this.ParkingFee             = CommonUtil.decimalToString(targetExactCondMatchPropRecord.ParkingFee__c); // 条件完全一致物件.駐車場
            this.Status                 = targetExactCondMatchPropRecord.Status__c                    ; // 条件完全一致物件.ステータス
            this.IntroductionImpression = targetExactCondMatchPropRecord.IntroductionImpression__c         ; // 条件完全一致物件.紹介感想

        }
    }

}