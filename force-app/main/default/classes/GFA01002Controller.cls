/* *
 * 地区別（店舗別）メンテナンス条件登録画面
 */
public inherited sharing class GFA01002Controller {
    
    //パブリック変数
    public ScreenAreaMaintenanceCondition screenTargetRecord { get; set; } //画面表示用の内部クラスレコード
    public Boolean isNew { get; set; }    //新規登録フラグ
    public Boolean isOpenError { get; set; }    //エラーフラグ
    public Boolean hasErrorMessage { get; set; }    //エラーメッセージ保有フラグ
    public List<SelectOption> SelectDistrictList { get; set; }  //選択リスト
    public String MSG_COM_V_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_SAVE);} private set;}    //js用保存確認メッセージ
    public String MSG_COM_I_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);} private set;}    //js用保存完了メッセージ
    public String MSG_COM_V_DELETE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_DELETE);} private set;}    //js用削除確認メッセージ
    public String MSG_COM_I_DELETE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_DELETE);} private set;}    //js用削除完了メッセージ
    //プライベート変数
    private ID targetId;    //対象ID

    //コンストラクタ
    public GFA01002Controller(){

        try{
            //初期化
            init();
            
            //対象IDを取得する
            this.targetId = ApexPages.currentPage().getParameters().get('id');
            
            //対象IDが取得できない場合は新規登録フラグにTRUEを設定する
            if(this.targetId == null){
                this.isNew = true;
                this.screenTargetRecord = new ScreenAreaMaintenanceCondition(new AreaMaintenanceCondition__c());
            
            //対象IDが取得できた場合は新規登録フラグにFALSEを設定する
            } else {
                this.isNew = false;
                this.screenTargetRecord = new ScreenAreaMaintenanceCondition(SelectRecordInfo(this.targetId)); 
            }
            
        } catch(Exception e) {
            
            //エラーを設定
            isOpenError = true;
            CommonUtil.setErrorMessage(e);
            
        }
    }

    
    //削除ボタン押下処理
    public void targetRecordDelete(){
        Savepoint sp = Database.setSavepoint();      //セーブポイント作成
        try{
            hasErrorMessage = false;
            //レコード削除
            SecureDML.secureDelete(screenTargetRecord.targetRecord);
            
        }catch(Exception e){
            
            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
            
        }
    }    
    
    //保存ボタン押下処理
    public void targetRecordSave(){
        Savepoint sp = Database.setSavepoint();      //セーブポイント作成
        try{
            hasErrorMessage = false;
            BusinessLogicException ex = new BusinessLogicException();

            Decimal maxMoney = CommonUtil.stringToDecimal(this.screenTargetRecord.propertyAmountUpperLimit);
            Decimal minMoney = CommonUtil.stringToDecimal(this.screenTargetRecord.propertyAmountLowerLimit);

            //入力チェック
            List<String> requiredItem = new List<String>();
            if (String.isBlank(screenTargetRecord.district)){
                requiredItem.add('地区');
            }
            
            //入力チェック用リストが空ではない場合、ビジネスロジックException発行
            if (!requiredItem.isEmpty()){
                
                //項目名をカンマで区切って、ビジネスロジックException発行
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ',')));
            }
            
            //地区重複チェック
            List<AreaMaintenanceCondition__c> checkDuplicateRecord = new List<AreaMaintenanceCondition__c>();
            checkDuplicateRecord = [ SELECT District__c
                                     FROM AreaMaintenanceCondition__c
                                     WHERE District__c = :this.screenTargetRecord.district
                                     AND Id != :this.targetId];
            if (!checkDuplicateRecord.isEmpty()){
            //空じゃない場合、ビジネスロジックException追加
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_EXISTENCE, this.screenTargetRecord.district)); 
            }
            

            //下限、上限どちらも記入されている場合、下限<上限かのチェック
            if (!String.isBlank(String.valueOf(screenTargetRecord.propertyAmountLowerLimit)) && 
                !String.isBlank(String.valueOf(screenTargetRecord.propertyAmountUpperLimit))){
                //下限>上限かの場合、ビジネスロジックException発行
                if (minMoney  >  maxMoney){
                    ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REGISTRATION_AMOUNT_SETTING));
                }
            }

            //ビジネスロジックExceptionにメッセージが1つ以上ある場合、ビジネスロジックException発行
            if (ex.hasMessage()){ 
                throw ex;
            }

            //新規でない場合、データ取得処理を実施
            if (!isNew){
                List<AreaMaintenanceCondition__c> checkOptimisticLockExceptionRecord = new List<AreaMaintenanceCondition__c>();
                checkOptimisticLockExceptionRecord = [ SELECT id
                                                         FROM AreaMaintenanceCondition__c
                                                        WHERE id = :this.screenTargetRecord.targetRecord.Id
                                                          AND SystemModStamp = :this.screenTargetRecord.targetRecord.systemModStamp ];
                
                //データ取得できない場合、楽観ロックチェックExceptionを発行
                if (checkOptimisticLockExceptionRecord.isEmpty()){
                    OptimisticLockException ex2 = new OptimisticLockException();
                    throw ex2;
                }
            }

            //保存処理実行
            AreaMaintenanceCondition__c upsertRecord = new AreaMaintenanceCondition__c(
                 Id                  = this.screenTargetRecord.targetRecord.Id
                ,District__c         = this.screenTargetRecord.district
                ,PropertyAmountLowerLimit__c = minMoney
                ,PropertyAmountUpperLimit__c = maxMoney
            );
            
            SecureDML.secureUpsert(upsertRecord);

        }catch(Exception e){
            
            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
            
        }
    }
    
    //初期化メソッド
    private void init(){
        this.isNew = false;
        this.isOpenError = false;
        this.hasErrorMessage = false;
        //店舗異動が取得できなければエラー
        CommonUtil.getStaffCurrentShop();
        this.SelectDistrictList = commonUtil.getSelectOptionFromObject('AreaMaintenanceCondition__c','District__c');
    }
    
    //レコード情報取得
    private AreaMaintenanceCondition__c SelectRecordInfo(Id targetId){
        List<AreaMaintenanceCondition__c> targetRecordList = [SELECT id,
                                                        Name,             //地区別メンテ条件番号
                                                        District__c,        //地区
                                                        PropertyAmountLowerLimit__c,       //取扱下限金額
                                                        PropertyAmountUpperLimit__c,       //取扱上限金額
                                                        SystemModStamp    
                                                   FROM AreaMaintenanceCondition__c 
                                                  WHERE id = :this.targetId ];
        
        //レコード情報が取得できなければビジネスロジックException発行
        if( targetRecordList.isEmpty() ){
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
            throw ex;
        }

        return targetRecordList[0];
    }
    
    //表示用の内部クラス
    public class ScreenAreaMaintenanceCondition{
        private AreaMaintenanceCondition__c targetRecord;//レコード本体
        
        //以下、画面用の項目
        public String titleName { get; set; }    //ヘッダー表示用地区
        public String name{get; set;}
        public String district{get; set;}
        public String propertyAmountLowerLimit{get; set;}
        public String propertyAmountUpperLimit{get; set;}
        
        //コンストラクタ
        public ScreenAreaMaintenanceCondition(AreaMaintenanceCondition__c targetRecord){
            this.titleName    = targetRecord.District__c;
            this.targetRecord = targetRecord;
            this.name         = targetRecord.Name;           
            this.district     = targetRecord.District__c;
            this.propertyAmountUpperLimit      = commonUtil.decimalToString(targetRecord.PropertyAmountUpperLimit__c);
            this.propertyAmountLowerLimit      = commonUtil.decimalToString(targetRecord.PropertyAmountLowerLimit__c);
        }
    }
}