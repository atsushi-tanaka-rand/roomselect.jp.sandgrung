//付帯商品登録のモーダル コントローラー画面

public inherited sharing class GF201002Controller {
    
    //Public変数
    public GF201002ParameterClass parameter { get; set; }// 共通クラス
    public ModalScreenItem modalParameter{get; set; }// 画面用の項目
    
    public Boolean isOpenError { get; set; } //画面遷移時のエラーフラグ
    public Boolean hasErrorMessage { get; set; } //エラーメッセージ保有フラグ 
    
    public List<SelectOption> selectAuxiliaryItemTypeList { get; set; } //商品区分選択リスト 
    
    
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
             modalParameter = new ModalScreenItem(parameter.targetItem,parameter.auxiliaryCompanyName);
             //課税を初期値に
             if(modalParameter.auxiliaryItemFeeTaxType == null){
                 modalParameter.auxiliaryItemFeeTaxType = '非課税';
             }
             //商品区分選択リスト設定
             selectAuxiliaryItemTypeList = CommonUtil.getSelectOptionFromObject('Item__c', 'AuxiliaryItemType__c');
         } catch (Exception e) {
             isOpenError = true;
             CommonUtil.setErrorMessage(e);
         }
     }
    
    //課税区分のラジオボタン
    public List<SelectOption> getAuxiliaryItemFeeTaxTypeRadioButton(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('課税', '課税'));
        options.add(new SelectOption('非課税', '非課税'));
        return options;
    }
    
     //設定ボタン押下時処理
     public void closeModal() {
         try{
             hasErrorMessage = false;
             BusinessLogicException ex = new BusinessLogicException();
            
             //入力チェック
             List<String> requiredItem = new List<String>();
             if(String.isBlank(modalParameter.itemName)){
                requiredItem.add('商品名');
             }
             if (String.isBlank(modalParameter.auxiliaryItemFeeCost)){
                 requiredItem.add('原価');
             }
             if (String.isBlank(modalParameter.auxiliaryItemFee)){
                 requiredItem.add('料金');
             }
             if (String.isBlank(modalParameter.auxiliaryItemType)){
                 requiredItem.add('商品区分');
             }

             //エラー出力
             if (!requiredItem.isEmpty()){
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ',')));
                throw ex;
             }
            
             //画面をパラメータに連携
             parameter.targetItem.AuxiliaryItemFeeTaxType__c     = String.valueOf(modalParameter.auxiliaryItemFeeTaxType);
             parameter.targetItem.ItemName__c                    = modalParameter.itemName;
             parameter.targetItem.AuxiliaryItemFeeCost__c        = CommonUtil.stringToDecimal(modalParameter.auxiliaryItemFeeCost);
             parameter.targetItem.AuxiliaryItemType__c           = modalParameter.auxiliaryItemType;
             parameter.targetItem.AuxiliaryItemFee__c            = CommonUtil.stringToDecimal(modalParameter.auxiliaryItemFee);
             parameter.targetItem.Remarks__c                     = modalParameter.remarks;
             parameter.targetItem.RecordTypeId                   = commonUtil.getRecordTypeId('Item__c',commonConst.ITEM_RECTYPE_AUXILIARY_ITEM);
         } catch (Exception e) {
             hasErrorMessage = true; //エラーを設定
             CommonUtil.setErrorMessage(e);
         }
     }
    
    //モーダルの表示項目
    public class ModalScreenItem{
        public String auxiliaryCompany{get; set;}       //付帯業者
        public String auxiliaryItemFeeTaxType{get; set;}     //課税区分
        public String itemName{get; set;}      //商品名
        public String auxiliaryItemFeeCost{get; set;}       //原価
        public String auxiliaryItemType{get; set;}      //商品区分
        public String auxiliaryItemFee{get; set;}       //料金
        public String remarks{get; set;}       // 備考
        
        // コンストラクタ
         public ModalScreenItem(Item__c item,String auxiliaryCompanyName){
             this.auxiliaryCompany = auxiliaryCompanyName;
             this.auxiliaryItemFeeTaxType = String.valueOf(item.AuxiliaryItemFeeTaxType__c);
             this.itemName = item.ItemName__c;
             this.auxiliaryItemFeeCost = CommonUtil.decimalToString(item.AuxiliaryItemFeeCost__c);
             this.auxiliaryItemType = item.AuxiliaryItemType__c;
             this.auxiliaryItemFee = CommonUtil.decimalToString(item.AuxiliaryItemFee__c);
             this.remarks = item.Remarks__c;
         }
    }
}