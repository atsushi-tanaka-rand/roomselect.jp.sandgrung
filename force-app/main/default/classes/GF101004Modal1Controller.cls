//保証会社プラン登録画面　の　商品明細用モーダル
public class GF101004Modal1Controller {
    
    //Public変数
    public GF101004Modal1ParameterClass parameter { get; set; } //共通クラス
    public ModalScreenItem  modalParameter{get; set; } //画面用の項目

    public Boolean isOpenError { get; set; } //画面遷移時のエラーフラグ
    public Boolean hasErrorMessage { get; set; } //エラーメッセージ保有フラグ        
    
    // ページの初期表示時の処理
    public Boolean init{
        get{
            if (Parameter.isDrawing) {
                initAction();
                parameter.isDrawing = false;
                return false;
            }
            return true;
        }
    }
    
    //ページの初期表示の具体的な処理
    public void initAction(){
        try{
            //初期化
            isOpenError = false;
            hasErrorMessage = false;
            
            //パラメータから画面項目を設定
            modalParameter = new ModalScreenItem(parameter.targetItemDetail);
        } catch (Exception e) {
            isOpenError = true;
            CommonUtil.setErrorMessage(e);
        }
    }
        
    //保証料金の母数 ラジオボタン（VFオプション）
    public List<SelectOption> getIsRentFeeTypeRadioButton(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('true', '総賃料'));
        options.add(new SelectOption('false', '賃料'));
        return options;
    }
    
    //設定ボタン押下時処理
    public void closeModal() {
        system.debug('設定ボタン開始');
        
        try{
            hasErrorMessage = false;
            BusinessLogicException ex = new BusinessLogicException();
            
            //入力チェック
            List<String> requiredItem = new List<String>();
            if (String.isBlank(modalParameter.planDetail)){
                requiredItem.add('プラン名');
            }
            if (!requiredItem.isEmpty()){   
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ','))); //項目名をカンマで区切る
            }
            
            //値の二重入力チェック1
            if (!String.isBlank(modalParameter.firstFeeDepositRate) && !String.isBlank(modalParameter.firstFeeDepositYen)) {
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_NOT_SELECTION, '初回保証料(％),初回保証料(円)')); 
            }
            
            //値の二重入力チェック2
            if (!String.isBlank(modalParameter.depositRate) && !String.isBlank(modalParameter.depositYen)) {
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_NOT_SELECTION, '月額保証料(％),月額保証料(円)')); 
            }


            
            //エラー出力
            if (ex.hasMessage()) {
                throw ex;
            }
            
            
            
            //画面をパラメータに連携
            parameter.targetItemDetail.PlanDetail__c          = modalParameter.planDetail;
            parameter.targetItemDetail.IsRentFeeType__c       = Boolean.valueOf(modalParameter.isRentFeetype);
            parameter.targetItemDetail.FirstFeeDepositRate__c = CommonUtil.stringToDecimal(modalParameter.firstFeeDepositRate);
            parameter.targetItemDetail.FirstFeeDepositYen__c  = CommonUtil.stringToDecimal(modalParameter.firstFeeDepositYen);
            parameter.targetItemDetail.DepositRate__c         = CommonUtil.stringToDecimal(modalParameter.depositRate);
            parameter.targetItemDetail.DepositYen__c          = CommonUtil.stringToDecimal(modalParameter.depositYen);
            parameter.targetItemDetail.DepositRemarks__c      = modalParameter.depositRemarks;
            
            system.debug('ここで最後hasErrorMessage:' + hasErrorMessage);
        } catch (Exception e) {
            hasErrorMessage = true; //エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }    
    
    
    //モーダル表示用クラス
    public class ModalScreenItem{
        //画面項目
        public String planDetail{get; set;}
        public String isRentFeeType{get; set;}
        public String firstFeeDepositRate{get; set;}
        public String firstFeeDepositYen{get; set;}
        public String depositRate{get; set;}
        public String depositYen{get; set;}
        public String depositRemarks{get; set;}       
        
        //コンストラクタ
        public ModalScreenItem(ItemDetail__c itemDetail){
            this.planDetail          = itemDetail.PlanDetail__c;
            this.isRentFeeType       = String.valueOf(itemDetail.IsRentFeeType__c);
            this.firstFeeDepositRate = CommonUtil.decimalToString(itemDetail.FirstFeeDepositRate__c);
            this.firstFeeDepositYen  = CommonUtil.decimalToString(itemDetail.FirstFeeDepositYen__c);
            this.depositRate         = CommonUtil.decimalToString(itemDetail.DepositRate__c);
            this.depositYen          = CommonUtil.decimalToString(itemDetail.DepositYen__c);
            this.depositRemarks      = itemDetail.DepositRemarks__c;
        }
    }    
    
    
}