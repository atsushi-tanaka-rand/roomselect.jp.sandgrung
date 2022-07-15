//入居者モーダルコントローラ
public class GA103001Modal1Controller {
        
    //Public変数
    public GA103001Modal1ParameterClass parameter { get; set; } //共通クラス
    public ModalScreenTenant  modalParameter{get; set; } //画面用の項目

    public Boolean isOpenError { get; set; } //画面遷移時のエラーフラグ
    public Boolean hasErrorMessage { get; set; } //エラーメッセージ保有フラグ 

    public List<SelectOption> SelectRelationshipList{ get; set; }    //続柄選択リスト
    public List<SelectOption> SelectJobTypeList{ get; set; }         //職種選択リスト
    
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
            modalParameter = new ModalScreenTenant(parameter.tenantRecord);
            //ここで設定します

            //続柄選択リスト設定
            this.SelectRelationshipList = CommonUtil.getSelectOptionFromObject('Tenant__c', 'Relationship__c');
            //職種選択リスト設定
            this.SelectJobTypeList = CommonUtil.getSelectOptionFromObject('Tenant__c', 'JobType__c');

        } catch (Exception e) {
            isOpenError = true;
            CommonUtil.setErrorMessage(e);
        }
    }
        
    //登録ボタン押下時処理
    public void closeTenantModal() {
        try{
            hasErrorMessage = false;
            BusinessLogicException ex = new BusinessLogicException();
            
            //入力チェック
            List<String> requiredItem = new List<String>();
            if (String.isBlank(modalParameter.lastName)){
                requiredItem.add('姓');
            }
            if (String.isBlank(modalParameter.firstName)){
                requiredItem.add('名');
            }
            if (String.isBlank(modalParameter.lastNameKana)){
                requiredItem.add('姓（カナ）');
            }
            if (String.isBlank(modalParameter.firstNameKana)){
                requiredItem.add('名（カナ）');
            }
            if (modalParameter.birthdate == null){
                requiredItem.add('生年月日');
            }
            //入力チェック用リストが空ではない場合、ビジネスロジックException発行
            if (!requiredItem.isEmpty()){
                //項目名をカンマで区切って、ビジネスロジックException発行
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ',')));
                throw ex;
            }

            //画面をパラメータに連携
            
            parameter.tenantRecord.LastName__c     = modalParameter.lastName;
            parameter.tenantRecord.FirstName__c    = modalParameter.firstName;
            parameter.tenantRecord.LastNameKana__c = modalParameter.lastNameKana;
            parameter.tenantRecord.FirstNameKana__c= modalParameter.firstNameKana;
            parameter.tenantRecord.Birthdate__c    = modalParameter.birthdate;
            parameter.tenantRecord.Age__c          = modalParameter.age;
            parameter.tenantRecord.Relationship__c = modalParameter.relationship;
            parameter.tenantRecord.JobType__c      = modalParameter.jobType;
            parameter.tenantRecord.Remarks__c      = modalParameter.remarks;
        

        } catch (Exception e) {
            hasErrorMessage = true; //エラーを設定
            CommonUtil.setErrorMessage(e);
        }
       
    }            
        
    
    //年齢再計算
    public void ageRecalculateTenant(){
        
        //年齢計算用に、あえて申込のレコードを用いる（入居者では申込__rが必要で、一時的な変数では数式計算の際に変更不可なため）
        /* 
        Application__c newAge = new Application__c(
              ApplicationDate__c = parameter.tenantRecord.Application__r.ApplicationDate__c
            , Birthdate__c       = modalParameter.birthdate);
        */
        Application__c newAge = new Application__c(
              ApplicationDate__c = parameter.applicationDate
            , Birthdate__c       = modalParameter.birthdate);
        newAge.recalculateFormulas();//数式を用いて再計算
        
        modalParameter.age = newAge.Age__c; //画面に再表示
    }
    


    //モーダル表示用クラス
    public class ModalScreenTenant{
        //画面項目
        public String lastName{get; set;}        //姓
        public String firstName{get; set;}       //名
        public String lastNameKana{get; set;}    //姓カナ
        public String firstNameKana{get; set;}   //名カナ
        public date birthdate{get; set;}       //生年月日
        public Decimal age{get; set;}             //年齢
        public String relationship{get; set;}    //続柄
        public String jobType{get; set;}         //職種
        public String remarks{get; set;}         //備考

        //コンストラクタ
        public ModalScreenTenant(Tenant__c tenantRecord){
            this.lastName     = tenantRecord.LastName__c;      //姓
            this.firstName    = tenantRecord.FirstName__c;     //名
            this.lastNameKana = tenantRecord.LastNameKana__c;  //姓カナ
            this.firstNameKana= tenantRecord.FirstNameKana__c;  //名カナ
            this.birthdate    = tenantRecord.Birthdate__c;     //生年月日
            this.age          = tenantRecord.Age__c;           //年齢
            this.relationship = tenantRecord.Relationship__c;  //続柄
            this.jobType      = tenantRecord.JobType__c;       //職種
            this.remarks      = tenantRecord.Remarks__c;       //備考

        }
        
    }  
  
}