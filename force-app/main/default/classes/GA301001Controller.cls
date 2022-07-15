/* *
* メール送信保留一覧のコントローラ
*/
public inherited sharing class GA301001Controller {
    
    /** パブリック変数 */
    
    /** 検索店舗ID */ 
    public String searchShopID{ get; set; }                              
    
    /** メール下書きリスト */ 
    public List<MailDraft__c> mailDraftList { get; set; }  
    
    /** メール時間指定送信リスト */
    public List<MailTimeSpecificationSending__c> mailTimeSpecificationSendingList { get; set; }  
    
    /** 店舗選択リスト */ 
    public List<SelectOption> selectOptionShopList { get; set; }      
    
    /** エラーフラグ */ 
    public Boolean isOpenError { get; set; }
    
    /** エラーメッセージ保有フラグ */ 
    public Boolean hasErrorMessage { get; set; } 
    
    //コンストラクタ
    public GA301001Controller() {
        try {
            //初期設定
            init();
        }catch(Exception e){
            isOpenError = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
            
        }
    }
    
    //初期設定
    private void init(){
        try {
            searchShopId = CommonUtil.getStaffCurrentShop().Id;//ユーザの店舗名取得
            
            //初期化
            mailDraftList = new List<MailDraft__c>();

            selectOptionShopList = new List<SelectOption>();
            isOpenError = FALSE;
            hasErrorMessage = FALSE;

            //選択リスト設定            
            selectOptionShopList = CommonUtil.getShopSelectedOptionFromStaffId(null, false);
            

        }catch(Exception e){
            isOpenError = true;//エラーを設定
            throw e;
        }
    }
    
    //店舗からメールを取得
    public void searchMail(){
        try {
            
            hasErrorMessage = false;//エラー設定を初期化
            
            BusinessLogicException ex = new BusinessLogicException();//ビジネスロジックException準備
            
            //検索一時保管場所
            List<MailDraft__c> aList = new List<MailDraft__c>();
            List<MailTimeSpecificationSending__c> bList = new List<MailtimeSpecificationSending__c>();

            //検索対象の店舗のメール下書きリストを取得
            aList = [SELECT ID, Account__c, Account__r.NAME, Subject__c, SystemModStamp, LastModifiedBy.Name, Correspond__r.EchoStaff__r.Name FROM MailDraft__c WHERE Shop__c = :searchShopID ORDER BY SystemModStamp DESC];
            
            //検索対象の店舗のメール時間指定送信リストを取得
            bList = [SELECT ID, Account__c, Account__r.NAME, Subject__c, SystemModStamp, SendingDateTime__c, LastModifiedBy.Name, Correspond__r.EchoStaff__r.Name  FROM MailTimeSpecificationSending__c WHERE Shop__c = :searchShopID ORDER BY SystemModStamp DESC];
            
            //メール下書きリストもメール時間指定送信リストも0件の場合エラー
            if(aList.size() == 0 && bList.size() == 0){
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_NO_DATA));
            }
            
            //ビジネスロジックException発行
            if (ex.hasMessage()){ 
                throw ex;
            }
            
            //画面表示
            mailDraftList = new List<MailDraft__c>();
            mailTimeSpecificationSendingList = new List<MailTimeSpecificationSending__c>();
            for (MailDraft__c a: alist) {
                mailDraftList.add(a);
            }
            for (MailTimeSpecificationSending__c b: blist) {
                mailTimeSpecificationSendingList.add(b);
            }
            
        }catch(Exception e){
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }
}