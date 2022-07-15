/**
 * 定型文登録画面のコントローラ
 */
public inherited sharing class GF301002Controller {
    
    //パブリック変数
    public ScreenFixedPhrase screenTargetRecord { get; set; } //画面表示用の内部クラスレコード
    public Boolean isNew { get; set; }    //新規登録フラグ
    public Boolean isOpenError { get; set; }    //エラーフラグ
    public Boolean hasErrorMessage { get; set; }    //エラーメッセージ保有フラグ
    public List<SelectOption> selectUsageScreenList { get; set; }  //選択リスト
    public String MSG_COM_V_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_SAVE);} private set;}    //js用保存確認メッセージ
    public String MSG_COM_I_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);} private set;}    //js用保存完了メッセージ
    public String MSG_COM_V_DELETE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_DELETE);} private set;}    //js用削除確認メッセージ
    public String MSG_COM_I_DELETE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_DELETE);} private set;}    //js用削除完了メッセージ
    
    //プライベート変数
    private ID targetId;    //対象ID

    //コンストラクタ
    public GF301002Controller(){

        try{
            //初期化
            init();
            
            //対象IDを取得する
            this.targetId = ApexPages.currentPage().getParameters().get('id');
            
            //対象IDが取得できない場合は新規登録フラグにTRUEを設定する
            if(this.targetId == null){
                this.isNew = true;
                this.screenTargetRecord = new ScreenFixedPhrase(new FixedPhrase__c());
            
            //対象IDが取得できた場合は新規登録フラグにFALSEを設定する
            } else {
                this.isNew = false;
                this.screenTargetRecord = new ScreenFixedPhrase(SelectRecordInfo(this.targetId)); 
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
            
            //入力チェック
            List<String> requiredItem = new List<String>();
            if (String.isBlank(screenTargetRecord.name)){
                requiredItem.add('定型文名');
            }
            if (String.isBlank(screenTargetRecord.folder)){
                requiredItem.add('フォルダ');
            }
            if (String.isBlank(screenTargetRecord.subject)){
                requiredItem.add('件名');
            }
            if (String.isBlank(screenTargetRecord.text)){
                requiredItem.add('本文');
            }
            if (String.isBlank(screenTargetRecord.usageScreen)){
                requiredItem.add('使用画面');
            }
            
            //入力チェック用リストが空ではない場合、ビジネスロジックException発行
            if (!requiredItem.isEmpty()){
                
                //項目名をカンマで区切って、ビジネスロジックException発行
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ',')));
                throw ex;
            }
            
            //新規でない場合、データ取得処理を実施
            if (!isNew){
                List<FixedPhrase__c> checkOptimisticLockExceptionRecord = new List<FixedPhrase__c>();
                checkOptimisticLockExceptionRecord = [ SELECT id
                                                         FROM FixedPhrase__c
                                                        WHERE id = :this.screenTargetRecord.targetRecord.Id
                                                          AND SystemModStamp = :this.screenTargetRecord.targetRecord.systemModStamp ];
                
                //データ取得できない場合、楽観ロックチェックExceptionを発行
                if (checkOptimisticLockExceptionRecord.isEmpty()){
                    OptimisticLockException ex = new OptimisticLockException();
                    throw ex;
                }
            }

            //保存処理実行
            FixedPhrase__c upsertRecord = new FixedPhrase__c(
                 Id             = this.screenTargetRecord.targetRecord.Id
                ,Name           = this.screenTargetRecord.name
                ,Folder__c      = this.screenTargetRecord.folder
                ,Subject__c     = this.screenTargetRecord.subject
                ,Text__c        = this.screenTargetRecord.text
                ,UsageScreen__c  = this.screenTargetRecord.usageScreen
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

        //「使用画面」選択リスト設定
        
        //再販対応 追加 Start
        //項目の選択肢を取得
        this.selectUsageScreenList = CommonUtil.getFillSelectOptionFromObject('FixedPhrase__c','UsageScreen__c', true, commonConst.FIXEDPHRASE_USAGESCREEN_POLICY_OF_PERSONAL_INFOMATION);
        //再販対応 追加 End

        //店舗異動が取得できなければエラー
        CommonUtil.getStaffCurrentShop();
    }
    
    //レコード情報取得
    private FixedPhrase__c SelectRecordInfo(Id targetId){
        List<FixedPhrase__c> targetRecordList = [SELECT id,
                                                        Name,             //定型文名
                                                        Folder__c,        //フォルダ
                                                        Subject__c,       //件名
                                                        Text__c,          //本文
                                                        UsageScreen__c,       //使用画面
                                                        SystemModStamp    
                                                   FROM FixedPhrase__c 
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
    public class ScreenFixedPhrase{
        private FixedPhrase__c targetRecord;//レコード本体
        
        //以下、画面用の項目
        public String titleName { get; set; }    //ヘッダー表示用取引先名
        public String name{get; set;}
        public String folder{get; set;}
        public String subject{get; set;}
        public String text{get; set;}
        public String usageScreen{get; set;}
        
        //コンストラクタ
        public ScreenFixedPhrase(FixedPhrase__c targetRecord){
            this.titleName    = targetRecord.Name;
            this.targetRecord = targetRecord;
            this.name         = targetRecord.Name;           
            this.folder       = targetRecord.Folder__c;
            this.subject      = targetRecord.Subject__c;
            this.text         = targetRecord.Text__c;
            this.usageScreen  = targetRecord.UsageScreen__c;
        }
    }
}