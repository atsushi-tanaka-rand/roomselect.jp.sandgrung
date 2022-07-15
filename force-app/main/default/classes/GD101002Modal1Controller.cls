public class GD101002Modal1Controller {

    //Public変数
    public GD101002Modal1ParameterClass Parameter { get; set; }   //パラメータクラス
    public Boolean isOpenError { get; set; }                //画面起動時のエラーフラグ
    public Boolean hasErrorMessage { get; set; }            //エラーメッセージ保有フラグ
    //画面表示用
    public screenManagementCompanyItem screenMciRecord{ get; set; } 

    //選択リスト
    public List<SelectOption> SelectTaxTypeList{ get; set; }          //税区分
    public List<SelectOption> SelectPaymentTypeList{ get; set; }      //支払区分

    // ページの初期表示時の処理
    public Boolean init{
        get{
            if (Parameter.isDrawing) {
                initAction();
                Parameter.isDrawing = false;
                return false;
            }
            return true;
        }
    }
    
    // ページの初期表示時の、具体的処理
    public void initAction() {
        try{
            //フラグ初期化
            this.isOpenError = null;     //isOpenErrorをfalseに
            this.hasErrorMessage = null; //isErrorMessageをfalseに
            
            ManagementCompanyItem__c mciRecord = new ManagementCompanyItem__c();
            //パラメータを受け取る
            screenMciRecord = new screenManagementCompanyItem(Parameter.paramMCIRecird);

            //選択リスト
            this.SelectTaxTypeList = CommonUtil.getSelectOptionFromObject('ManagementCompanyItem__c', 'TaxType__c');      //税区分          
            this.SelectPaymentTypeList = CommonUtil.getSelectOptionFromObject('ManagementCompanyItem__c', 'PaymentType__c');//支払区分              

        }catch (Exception e){
            //エラーを設定
            isOpenError = true;
            CommonUtil.setErrorMessage(e);        
        }
    }

    //登録ボタン
    public void register(){
        
        try{
            hasErrorMessage = false;
            BusinessLogicException ex = new BusinessLogicException();

            //入力チェック
            List<String> requiredItem = new List<String>();
            if (String.isBlank(screenMciRecord.itemName)){
                requiredItem.add('商品名');
            }
            if (String.isBlank(screenMciRecord.amount)){
                requiredItem.add('金額');
            }
            if (String.isBlank(screenMciRecord.taxType)){
                requiredItem.add('税区分');
            }
            if (String.isBlank(screenMciRecord.paymentType)){
                requiredItem.add('支払区分');
            }
            
            //入力チェック用リストが空ではない場合、ビジネスロジックException発行
            if (!requiredItem.isEmpty()){
                //項目名をカンマで区切って、ビジネスロジックException発行
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ',')));
                throw ex;
            }

            Parameter.paramMCIRecird =  new ManagementCompanyItem__c(
                ItemName__c = screenMciRecord.itemName,
                Amount__c = commonUtil.stringToDecimal(screenMciRecord.amount),
                TaxType__c = screenMciRecord.taxType,
                PaymentType__c = screenMciRecord.paymentType);
            
        }catch(Exception e){
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }
    // 内部クラス
    public class screenManagementCompanyItem {
    public String itemName{get; set;}    //商品名
    public String amount{get; set;}      //金額
    public String taxType{get; set;}     //税区分
    public String paymentType{get; set;} //支払区分
    //商品内容

        //コンストラクタ
        public screenManagementCompanyItem(ManagementCompanyItem__c mcItem) {
            this.itemName = mcItem.ItemName__c;//商品名
            this.amount = commonUtil.decimalToString(mcItem.Amount__c);//金額
            this.taxType = mcItem.TaxType__c;//税区分
            this.paymentType = mcItem.PaymentType__c;//支払区分
            //商品内容
        }
    }
}