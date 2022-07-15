/**
 * 文例登録画面のコントローラ
 */
public inherited sharing class GF401002Controller {

    //パブリック変数
    public ScreenExampleSentence screenTargetRecord { get; set; } //画面表示用の内部クラスレコード
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
    public GF401002Controller(){

        try{
            //初期化
            init();
            //店舗異動が取得できなければエラー
            CommonUtil.getStaffCurrentShop();

            //対象IDを取得する
            this.targetId = ApexPages.currentPage().getParameters().get('id');
            
            //対象IDが取得できない場合は新規登録フラグにTRUEを設定する
            if(this.targetId == null){
                this.isNew = true;
                this.screenTargetRecord = new ScreenExampleSentence(new ExampleSentence__c());
            
            //対象IDが取得できた場合は新規登録フラグにFALSEを設定する
            } else {
                this.isNew = false;
                this.screenTargetRecord = new ScreenExampleSentence(SelectRecordInfo(this.targetId)); 
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
            
            //入力チェック
            List<String> requiredItem = new List<String>();
            if (String.isBlank(screenTargetRecord.name)){
                requiredItem.add('文例名');
            }
            if (String.isBlank(screenTargetRecord.folder)){
                requiredItem.add('フォルダ');
            }
            if (String.isBlank(screenTargetRecord.exampleSentence)){
                requiredItem.add('文例');
            }
            if (String.isBlank(screenTargetRecord.usageScreen)){
                requiredItem.add('使用画面');
            }
            
            //入力チェック用リストが空ではない場合
            if (!requiredItem.isEmpty()){
                //項目名をカンマで区切って、エラーを追加
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ',')));
            }

            //禁止用語チェック
            for(Integer i = 0; i < 1; i++){
                String banWord;
                String banItem;
                switch on i {
                    when 0 { 
                        banWord = CommonUtil.getContainBanWord(screenTargetRecord.exampleSentence);
                        banItem = '文例';
                    }
                }

               if (banWord != null){  
                    ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_REGISTRATION_ROHIBITED_TERMS_MULTI,banItem,banWord ));
               }
            }
            
            //ビジネスロジックExceptionにメッセージが1つ以上ある場合、ビジネスロジックException発行
            if (ex.hasMessage()){ 
                throw ex;
            }
            
            
            //新規でない場合、データ取得処理を実施
            if (!isNew){
                List<ExampleSentence__c> checkOptimisticLockExceptionRecord = new List<ExampleSentence__c>();
                checkOptimisticLockExceptionRecord = [ SELECT id
                                                        FROM ExampleSentence__c
                                                        WHERE id = :this.screenTargetRecord.targetRecord.Id
                                                        AND SystemModStamp = :this.screenTargetRecord.targetRecord.systemModStamp ];
                
                //データ取得できない場合、楽観ロックチェックExceptionを発行
                if (checkOptimisticLockExceptionRecord.isEmpty()){
                    OptimisticLockException ex2 = new OptimisticLockException();
                    throw ex2;
                }
            }


            //保存処理実行
            ExampleSentence__c upsertRecord = new ExampleSentence__c(
                 Id                  = this.screenTargetRecord.targetRecord.Id
                ,Name                = this.screenTargetRecord.name
                ,Folder__c           = this.screenTargetRecord.folder
                ,ExampleSentence__c  = this.screenTargetRecord.exampleSentence
                ,UsageScreen__c  = this.screenTargetRecord.usageScreen
            );
            
            SecureDML.secureUpsert(upsertRecord);
        }catch(Exception e){
            
            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;//エラーを設定
            system.debug(e);
            CommonUtil.setErrorMessage(e);
            
        }
    }
    
    //初期化メソッド
    private void init(){
        this.isNew = false;
        this.isOpenError = false;
        this.hasErrorMessage = false;
        //「使用画面」選択リスト設定
        this.selectUsageScreenList = commonUtil.getSelectOptionFromObject('ExampleSentence__c','UsageScreen__c');
    }
    
    //レコード情報取得
    private ExampleSentence__c SelectRecordInfo(Id targetId){
        List<ExampleSentence__c> targetRecordList = [SELECT id,
                                                        Name,                 //文例名
                                                        Folder__c,            //フォルダ
                                                        ExampleSentence__c,   //文例
                                                        UsageScreen__c,       //使用画面
                                                        SystemModStamp    
                                                   FROM ExampleSentence__c 
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
    public class ScreenExampleSentence{
        private ExampleSentence__c targetRecord;//レコード本体
        
        //以下、画面用の項目
        public String titleName{get; set;}
        public String name{get; set;}
        public String folder{get; set;}
        public String exampleSentence{get; set;}
        public String usageScreen{get; set;}
        
        //コンストラクタ
        public ScreenExampleSentence(ExampleSentence__c targetRecord){
            this.titleName = targetRecord.Name;
            this.targetRecord = targetRecord;
            this.name         = targetRecord.Name;
            this.folder  = targetRecord.Folder__c;
            this.exampleSentence  = targetRecord.ExampleSentence__c;
            this.usageScreen  = targetRecord.UsageScreen__c;
        }
    }
}