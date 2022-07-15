/**
 * 禁止用語登録画面のコントローラ
 */
    
public inherited sharing class GFB01002Controller {

    //パブリック変数
    public ScreenBanWord screenTargetRecord { get; set; } //画面表示用の内部クラスレコード
    public Boolean isNew { get; set; }    //新規登録フラグ
    public Boolean isOpenError { get; set; }    //エラーフラグ
    public Boolean hasErrorMessage { get; set; }    //エラーメッセージ保有フラグ
    public String MSG_COM_V_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_SAVE);} private set;}    //js用保存確認メッセージ
    public String MSG_COM_I_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);} private set;}    //js用保存完了メッセージ
    public String MSG_COM_V_DELETE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_DELETE);} private set;}    //js用削除確認メッセージ
    public String MSG_COM_I_DELETE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_DELETE);} private set;}    //js用削除完了メッセージ
    
    //プライベート変数
    private ID targetId;    //対象ID

    //コンストラクタ
    public GFB01002Controller(){

        try{
            //初期化
            init();
            
            //対象IDを取得する
            this.targetId = ApexPages.currentPage().getParameters().get('id');
            
            //対象IDが取得できない場合は新規登録フラグにTRUEを設定する
            if(this.targetId == null){
                this.isNew = true;
                this.screenTargetRecord = new ScreenBanWord(new BanWord__c());
            
            //対象IDが取得できた場合は新規登録フラグにFALSEを設定する
            } else {
                this.isNew = false;
                this.screenTargetRecord = new ScreenBanWord(SelectRecordInfo(this.targetId)); 
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
            if (String.isBlank(screenTargetRecord.banWord)){
                requiredItem.add('禁止用語');
            }

            
            //入力チェック用リストが空ではない場合、ビジネスロジックException発行
            if (!requiredItem.isEmpty()){
                
                //項目名をカンマで区切って、ビジネスロジックException発行
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ',')));
                throw ex;
            }

            //重複がある場合、ビジネスロジックException発行
	    	List<BanWord__c> banWordList = [SELECT BanWord__c 
                           FROM BanWord__c 
                           WHERE id != :this.screenTargetRecord.targetRecord.Id 
                           AND BanWord__c = :screenTargetRecord.banWord];   
            //禁止用語数分ループ             
            if( banWordList.size() != 0){
                //禁止用語が重複していた場合、ビジネスロジックException発行
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_EXISTENCE, screenTargetRecord.banWord));
                throw ex;
            }                                

            
            //新規でない場合、データ取得処理を実施
            if (!isNew){
                List<BanWord__c> checkOptimisticLockExceptionRecord = new List<BanWord__c>();
                checkOptimisticLockExceptionRecord = [ SELECT id
                                                         FROM BanWord__c
                                                        WHERE id = :this.screenTargetRecord.targetRecord.Id
                                                          AND SystemModStamp = :this.screenTargetRecord.targetRecord.systemModStamp ];
                
                //データ取得できない場合、楽観ロックチェックExceptionを発行
                if (checkOptimisticLockExceptionRecord.isEmpty()){
                    OptimisticLockException ex2 = new OptimisticLockException();
                    throw ex2;
                }
            }

            //保存処理実行
            BanWord__c upsertRecord = new BanWord__c(
                 Id             = this.screenTargetRecord.targetRecord.Id
                ,BanWord__c           = this.screenTargetRecord.banWord

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
    }
    
    //レコード情報取得
    private BanWord__c SelectRecordInfo(Id targetId){
        List<BanWord__c> targetRecordList = [SELECT id,
                                                        Name,             //禁止用語番号
                                                        BanWord__c,   //禁止用語
                                                        SystemModStamp    
                                                   FROM BanWord__c 
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
    public class ScreenBanWord{
        private BanWord__c targetRecord;//レコード本体
        
        //以下、画面用の項目
        public String titleName { get; set; }    //ヘッダー表示用取引先名
        public String banWord{get; set;}
        public String name{get; set;}
 
        
        //コンストラクタ
        public ScreenBanWord(BanWord__c targetRecord){
            this.titleName = targetRecord.Name;
            this.targetRecord = targetRecord;
            this.name         = targetRecord.Name;
            this.banWord  = targetRecord.banWord__c;
        }
    }
}