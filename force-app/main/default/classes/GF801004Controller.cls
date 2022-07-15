/* *
 * 火災保険プラン登録画面のコントローラ
 */
public inherited sharing class GF801004Controller {
    //Public変数
    public GF801004ParameterClass parameter { get; set; }// 共通クラス
    public ModalScreenItem modalParameter{get; set; }// 画面用の項目
    
    public Boolean isOpenError { get; set; } //画面遷移時のエラーフラグ
    public Boolean hasErrorMessage { get; set; } //エラーメッセージ保有フラグ 

    //ラジオボタンのリスト値
    public List<SelectOption> SelectIsAuxiliaryList { get; set; } //付帯商品区分
    public List<SelectOption> SelectPaymentTypeList { get; set; } //更新期間

    //ページの初期表示時の処理
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
            modalParameter = new ModalScreenItem(parameter.targetItem,parameter.companyName);

            //ラジオボタンを初期値に
            if(parameter.targetItem == (new Item__c())){
                modalParameter.isAuxiliary = true;
                modalParameter.paymentType = CommonConst.ITEM_PAYMENTTYPE_YEAR;
            }

            //ラジオボタンのリスト値設定
            getIsAuxiliaryRadioButton();
            getPaymentTypeRadioButton();

        } catch (Exception e) {
            isOpenError = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    //付帯商品区分のリスト設定
    public List<SelectOption> getIsAuxiliaryRadioButton(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('true', '付帯商品'));
        options.add(new SelectOption('false', '付帯商品以外'));
        this.SelectIsAuxiliaryList = options;
        return SelectIsAuxiliaryList;
    }

    //更新期間のリスト設定
    public List<SelectOption> getPaymentTypeRadioButton(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(CommonConst.ITEM_PAYMENTTYPE_YEAR, '年更新'));
        options.add(new SelectOption(CommonConst.ITEM_PAYMENTTYPE_MONTH, '月更新'));
        this.SelectPaymentTypeList = options;
        return SelectPaymentTypeList;
    }

    //設定ボタン押下時処理
    public void closeModal() {
        try{
            hasErrorMessage = false;
            BusinessLogicException ex = new BusinessLogicException();
           
            //入力チェック
            List<String> requiredItem = new List<String>();
            if(String.isBlank(modalParameter.itemName)){
                requiredItem.add('火災保険プラン');
            }
            if (modalParameter.isAuxiliary == true) {
                //付帯商品の場合、必須
                if(String.isBlank(modalParameter.insuranceFeeRate)){
                    requiredItem.add('紹介料の割合(保険料に対する割合)');
                }
            }
            if(String.isBlank(modalParameter.insuranceFee)){
                requiredItem.add('保険料');
            }
            if (modalParameter.paymentType == CommonConst.ITEM_PAYMENTTYPE_YEAR) {
                //年型の場合、必須
                if(String.isBlank(modalParameter.paymentYear)){
                    requiredItem.add('更新期間');
                }
            }

            //エラー出力
            if (!requiredItem.isEmpty()){
               ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ',')));
               throw ex;
            }

            //画面をパラメータに連携
            parameter.targetItem.ItemName__c = modalParameter.itemName;
            parameter.targetItem.IsAuxiliary__c  = modalParameter.isAuxiliary;
            parameter.targetItem.InsuranceFeeRate__c = CommonUtil.stringToDecimal(modalParameter.insuranceFeeRate);
            if (modalParameter.paymentType == CommonConst.ITEM_PAYMENTTYPE_YEAR) {
                //年型の場合
                parameter.targetItem.FireInsuranceYear__c = CommonUtil.stringToDecimal(modalParameter.insuranceFee);
                //問合せ390で変更
                parameter.targetItem.FireInsuranceMonth__c = null;
            } else if (modalParameter.paymentType == CommonConst.ITEM_PAYMENTTYPE_MONTH) {
                //月型の場合
                parameter.targetItem.FireInsuranceMonth__c = CommonUtil.stringToDecimal(modalParameter.insuranceFee);
				//問合せ390で変更
                parameter.targetItem.FireInsuranceYear__c = null;
            }
            parameter.targetItem.PaymentType__c = modalParameter.paymentType;
            parameter.targetItem.PaymentYear__c = CommonUtil.stringToDecimal(modalParameter.paymentYear);
            parameter.targetItem.HouseGoodsDeposit__c = CommonUtil.stringToDecimal(modalParameter.houseGoodsDeposit);
            parameter.targetItem.TenantCompensation__c = CommonUtil.stringToDecimal(modalParameter.tenantCompensation);
            parameter.targetItem.FireInsurance__c = modalParameter.fireInsurance;
            parameter.targetItem.RecordTypeId = commonUtil.getRecordTypeId('Item__c',commonConst.ITEM_RECTYPE_FIRE_INSURANCE);

        } catch (Exception e) {
            hasErrorMessage = true; //エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }

    //モーダルの表示項目
    public class ModalScreenItem{
        public String companyName{get; set;}       //火災保険会社
        public String itemName{get; set;}       //火災保証プラン
        public Boolean isAuxiliary{get; set;}       //付帯商品区分
        public String insuranceFeeRate{get; set;}       //紹介料の割合
        public String insuranceFee{get; set;}       //保険料
        public String paymentType{get; set;}       //更新期間
        public String paymentYear{get; set;}       //更新年数
        public String houseGoodsDeposit{get; set;}       //家財保証額
        public String tenantCompensation{get; set;}       //借家人賠償額
        public String fireInsurance{get; set;}       //保険内容

        // コンストラクタ
        public ModalScreenItem(Item__c item,String companyName){
            this.companyName = companyName;
            this.itemName = item.ItemName__c;
            this.isAuxiliary = item.IsAuxiliary__c;
            this.insuranceFeeRate = CommonUtil.decimalToString(item.InsuranceFeeRate__c);
            this.paymentType = item.PaymentType__c;
            if (this.paymentType == CommonConst.ITEM_PAYMENTTYPE_YEAR){
                //年型の場合
                this.paymentYear = CommonUtil.decimalToString(item.PaymentYear__c);
                this.insuranceFee = CommonUtil.decimalToString(item.FireInsuranceYear__c);
            } else if (this.paymentType == CommonConst.ITEM_PAYMENTTYPE_MONTH) {
                //月型の場合
                this.paymentYear = CommonConst.STRING_EMPTY;
                this.insuranceFee = CommonUtil.decimalToString(item.FireInsuranceMonth__c);
            }
            this.houseGoodsDeposit = CommonUtil.decimalToString(item.HouseGoodsDeposit__c);
            this.tenantCompensation = CommonUtil.decimalToString(item.TenantCompensation__c);
            this.fireInsurance = item.FireInsurance__c;
         }
    }
}