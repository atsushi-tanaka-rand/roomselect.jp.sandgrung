/**
 *申込登録（ipad）のコントローラ
 */
global inherited sharing class GA103001Controller {

    /** 共通クラス */    
    public GA102006ParameterClass GA102006Parameter{get; set;}       //郵便番号検索・住所検索モーダル
    public GA103001Modal1ParameterClass GA103001Modal1Parameter { get; set; }    //入居者モーダル用

    //パブリック変数
    public Boolean isNew { get; set; }                 //新規登録フラグ
    public Boolean isOpenError { get; set; }           //エラーフラグ
    public Boolean hasErrorMessage { get; set; }       //エラーメッセージ保有フラグ
    
    public ScreenItem screenTargetRecord { get; set; } //画面表示用の内部クラスレコード
    
    public Boolean isApp { get; set; }                 //アプリで表示してるフラグ
    public Boolean isChange { get; set; }              //変更有無フラグ
    public Boolean isConfirm { get; set; }             //確認画面フラグ
    public Boolean privacy { get; set; }               //個人情報に同意フラグ
    public String view2Param  { get; set; }            //view2に渡す申込パラメータ

    public Boolean hasBasicSection { get; set; }       //基本情報セクションタイトル項目表示フラグ
    public Boolean hasParkingSection { get; set; }     //駐車場セクションタイトル項目表示フラグ
    public Boolean hasBikeParkingSection { get; set; } //バイク置場タイトル項目表示フラグ    

    public List<Id> fireInsuranceIdList { get; set; }        //List<Id> 火災保険会社IdList(repeat用)
    public Item__c fireInsuranceRecord { get; set; }         //火災保険会社レコード
    public Boolean checkFireInsurance { get; set; }          //火災保険チェックボックス
    public List<ScreenGuaranteeItem> guaranteeDetailList { get; set; } //保証リスト
    public List<ScreenQuoteManageCompayItem> quoteManageCompayItemList { get; set; } //管理会社指定商品リスト

    public List<Tenant__c> tenantList { get; set; }      //入居者リスト
    public Integer selectedIndex { get; set; }           // 入居者インデックス
    private List<Tenant__c> deleteTenantList;            //削除用入居者リスト
    
    public String parentId { get; set;}    //署名用申込Id
    public Boolean isUpsert { get; set; }  //署名用更新フラグ

    public List<SelectOption> SelectStateList{ get; set; }               //個人都道府県選択リスト
    public List<SelectOption> SelectCompanyStateList{ get; set; }        //会社都道府県選択リスト
    public List<SelectOption> SelectAffiliationStateList{ get; set; }    //勤務先都道府県選択リスト
    public List<SelectOption> SelectJointGuarantorStateList{ get; set; } //連帯保証人都道府県リスト
    public List<SelectOption> SelectJointGuarantorAffiliationStateList{ get; set; } //連帯保証人勤務先都道府県リスト
    public List<SelectOption> SelectapplicationTypeList{ get; set; }     //更新種別選択リスト
    public List<SelectOption> SelectIsSpouseList{ get; set; }            //配偶者有無選択リスト
    public List<SelectOption> SelectResidenceTypeList{ get; set; }       //住居種別選択リスト
    public List<SelectOption> SelectIndustriesList{ get; set; }          //業種選択リスト
    public List<SelectOption> SelectJobTypeList{ get; set; }             //職種種別選択リスト
    public List<SelectOption> SelectCompanyIndustriesList{ get; set; }   //会社業種選択リスト
    public List<SelectOption> SelectInformalOfferList{ get; set; }       //内定有無選択リスト
    public List<SelectOption> SelectApplicantRelationshipList{ get; set; }       //連帯保証人と申込者との関係選択リスト
    public List<SelectOption> SelectJointGuarantorIsSpouseList{ get; set; }      //連帯保証人配偶者有無選択リスト
    public List<SelectOption> SelectJointGuarantorResidenceTypeList{ get; set; } //連帯保証人住居種別選択リスト
    public List<SelectOption> SelectJointGuarantorIndustriesList{ get; set; }    //連帯保証人業種選択リスト
    public List<SelectOption> SelectJointGuarantorJobTypeList{ get; set; }       //連帯保証人職種選択リスト
    //ラジオボタン値
    public String JointGuarantorRadioButton { get; set; }//連帯保証人OR緊急連絡先

    //メッセージ系
    public String MSG_COM_V_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_SAVE);} private set;}    //js用登録確認メッセージ
    public String MSG_COM_I_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);} private set;}    //js用登録完了メッセージ
    public String MSG_COM_V_DELETE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_DELETE);} private set;}    //js用削除確認メッセージ
    public String MSG_COM_I_DELETE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_DELETE);} private set;}    //js用削除完了メッセージ
    public String MSG_COM_I_CANCEL_CONFIRMATION {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_CANCEL_CONFIRMATION,'遷移');} private set;}    //口コミボタン変更確認メッセージ

    //プライベート変数
    private String applicationId;   //申込Idパラメータ
    private String accountId;       //取引先Idパラメータ
    private String propertyId;      //物件Idパラメータ
    private String correspondId;    //対応Idパラメータ 
    private String userId;          //担当者Idパラメータ 

    private String comeFrom;            //遷移元区分パラメータ
    private Account targetAccount;      //target取引先
    private Property__c targetProperty; //target物件
    private Application__c targetApplication; //target申込
    private Correspond__c targetCorrespond;//対応
    private Shop__c targetShop;         //店舗（TODO更新用）
    
    private Boolean isOpenModalCreate;    //新規モーダルフラグ
    private Integer modalNum;             //郵便番号のモーダルどの項目で使っているか

    //コンストラクタ
    public GA103001Controller(){
        try{
            //初期化            
            init();

        }catch(Exception e){
            //エラーを設定
            isOpenError = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    /**◇◇◇◇◇◇◇以下publicメソッド◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇**/
    //連帯保証人OR緊急連絡先ラジオボタン
    public List<SelectOption> getJointGuarantorRadioButtonSetting(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('連帯保証人', '連帯保証人'));
        options.add(new SelectOption('緊急連絡先', '緊急連絡先'));
        return options;
    }
    //以下郵便番号検索・住所検索用モーダル
    //------------------------------------------------------------------------------------

    //郵便番号検索個人用郵便番号モーダル分岐処理
    public void modal1() {
        modalNum = 1; 
        openModal();  
    }    
    public void modal2() {
        modalNum = 2;         
        openModal();  
    }
    public void modal3() {
        modalNum = 3;         
        openModal();  
    }
    public void modal4() {
        modalNum = 4;         
        openModal();  
    }
    public void modal5() {
        modalNum = 5;         
        openModal();  
    }
    //郵便番号検索モーダルopen処理
    public void openModal() {
        GA102006Parameter.isDrawing = true;
        GA102006Parameter.noFirst = true;
        GA102006Parameter.isAddressMoster = TRUE;       /** 住所マスタフラグ */
        //郵便番号個人用モーダル     
        if (modalNum == 1){
            GA102006Parameter.postalCode = this.screenTargetRecord.currentpostalCode;  //モーダルに渡す用郵便番号
            GA102006Parameter.state = this.screenTargetRecord.currentState;            //モーダルに渡す用都道府県
            GA102006Parameter.city = this.screenTargetRecord.currentCity;              //モーダルに渡す用市町村
            GA102006Parameter.street =null;           //モーダルに渡す用町域           
        }else if(modalNum == 2){
            //郵便番号個人用モーダル
            GA102006Parameter.postalCode = this.screenTargetRecord.companypostalCode;  //モーダルに渡す用郵便番号
            GA102006Parameter.state = this.screenTargetRecord.companyState;            //モーダルに渡す用都道府県
            GA102006Parameter.city = this.screenTargetRecord.companyCity;              //モーダルに渡す用市町村
            GA102006Parameter.street =null;           //モーダルに渡す用町域  
         }else if(modalNum == 3){
            GA102006Parameter.postalCode = this.screenTargetRecord.affiliationPostalCode;  //モーダルに渡す用郵便番号
            GA102006Parameter.state = this.screenTargetRecord.affiliationState;            //モーダルに渡す用都道府県
            GA102006Parameter.city = this.screenTargetRecord.affiliationCity;              //モーダルに渡す用市町村
            GA102006Parameter.street =null;           //モーダルに渡す用町域          
         }else if(modalNum == 4){
            GA102006Parameter.postalCode = this.screenTargetRecord.JointGuarantorPostalCode;  //モーダルに渡す用郵便番号
            GA102006Parameter.state = this.screenTargetRecord.JointGuarantorState;            //モーダルに渡す用都道府県
            GA102006Parameter.city = this.screenTargetRecord.JointGuarantorCity;              //モーダルに渡す用市町村
            GA102006Parameter.street =null;           //モーダルに渡す用町域    
        }else if(modalNum == 5){
            GA102006Parameter.postalCode = this.screenTargetRecord.jointGuarantorAffiliationPostalCode;  //モーダルに渡す用郵便番号
            GA102006Parameter.state = this.screenTargetRecord.jointGuarantorAffiliationState;            //モーダルに渡す用都道府県
            GA102006Parameter.city = this.screenTargetRecord.jointGuarantorAffiliationCity;              //モーダルに渡す用市町村
            GA102006Parameter.street =null;           //モーダルに渡す用町域    
        }
    }    

    //郵便番号検索モーダルclose処理
    public void closeModal() {
        //変更されたフラグTrue
        isChange = true;
         //郵便番号個人用モーダル
        if (modalNum == 1){
            this.screenTargetRecord.currentpostalCode = GA102006Parameter.postalCode;  /** 郵便番号 */   
            this.screenTargetRecord.currentState = GA102006Parameter.state;    /** 都道府県 */    
            this.screenTargetRecord.currentCity = GA102006Parameter.city +GA102006Parameter.street;    /** 市区町村 */  
            this.screenTargetRecord.currentStreet = null;    /** 町域 */  
        }else if (modalNum == 2){
            //郵便番号個人用モーダル
            this.screenTargetRecord.companypostalCode = GA102006Parameter.postalCode;  /** 郵便番号 */   
            this.screenTargetRecord.companyState = GA102006Parameter.state;    /** 都道府県 */    
            this.screenTargetRecord.companyCity = GA102006Parameter.city + GA102006Parameter.street;    /** 市区町村 */  
            this.screenTargetRecord.companyStreet = null;    /** 町域 */  
        }else if (modalNum == 3){
            //郵便番号勤務用モーダル
            this.screenTargetRecord.affiliationPostalCode = GA102006Parameter.postalCode;  /** 郵便番号 */   
            this.screenTargetRecord.affiliationState = GA102006Parameter.state;    /** 都道府県 */    
            this.screenTargetRecord.affiliationCity = GA102006Parameter.city + GA102006Parameter.street;    /** 市区町村 */  
            this.screenTargetRecord.affiliationStreet = null;    /** 町域 */  
        }else if (modalNum == 4){
            //郵便番号連帯保証人用モーダル
            this.screenTargetRecord.JointGuarantorPostalCode = GA102006Parameter.postalCode;  /** 郵便番号 */   
            this.screenTargetRecord.JointGuarantorState = GA102006Parameter.state;    /** 都道府県 */    
            this.screenTargetRecord.JointGuarantorCity = GA102006Parameter.city + GA102006Parameter.street;    /** 市区町村 */  
            this.screenTargetRecord.JointGuarantorStreet = null;    /** 町域 */  
        }else if (modalNum == 5){
            //郵便番号連帯保証人用モーダル
            this.screenTargetRecord.jointGuarantorAffiliationPostalCode = GA102006Parameter.postalCode;  /** 郵便番号 */   
            this.screenTargetRecord.jointGuarantorAffiliationState = GA102006Parameter.state;    /** 都道府県 */    
            this.screenTargetRecord.jointGuarantorAffiliationCity = GA102006Parameter.city + GA102006Parameter.street;    /** 市区町村 */  
            this.screenTargetRecord.jointGuarantorAffiliationStreet = null;    /** 町域 */  
        }
    }     
    //------------------------------------------------------------------------------------
    //郵便番号検索・住所検索用モーダルここまで
    

    //以下入居者モーダル------------------------------------------------------------------------------------
    //入居者(新規)モーダル起動
    public void openModalCreateTenant() {

        this.isOpenModalCreate = true;
        this.GA103001Modal1Parameter = new GA103001Modal1ParameterClass();
        GA103001Modal1Parameter.isDrawing = true;
        GA103001Modal1Parameter.noFirst = true;
        GA103001Modal1Parameter.applicationDate = screenTargetRecord.applicationDate; //誕生日計算用
        GA103001Modal1Parameter.tenantRecord = new Tenant__c();

        /*
        //レコードを新規作成
        GA103001Modal1Parameter.tenantRecord.Application__r = new Application__c(
              ApplicationDate__c = screenTargetRecord.applicationDate //誕生日計算用
            , Id                 = this.applicationId
        );
        */
    }
    //入居者(編集)モーダル起動
    public void openModalUpdateTenant() {

        this.isOpenModalCreate = false;
        this.GA103001Modal1Parameter = new GA103001Modal1ParameterClass();
        GA103001Modal1Parameter.isDrawing = true;
        GA103001Modal1Parameter.noFirst = true;
        GA103001Modal1Parameter.applicationDate = screenTargetRecord.applicationDate; //誕生日計算用
        
        // selectedIndexの添え字が対象のレコード
        GA103001Modal1Parameter.tenantRecord = tenantList[selectedIndex];   
    }
    //入居者リスト削除ボタン押下処理
    public void TenantRecordDelete(){
        //変更されたフラグtrue
        isChange = true;
        //新規作成ではないレコードは削除リストに追加
        if(!String.isEmpty(tenantList[selectedIndex].id)){
            this.deleteTenantList.add(tenantList[selectedIndex]);
        }
        tenantList.remove(selectedIndex);
    }
    //入居者画面モーダル終了
    public void closeTenantModal() {
        //変更されたフラグtrue
        isChange = true;
        if(isOpenModalCreate){
            //isOpenModalCreateがTRUEなら行追加
            this.tenantList.add(GA103001Modal1Parameter.tenantRecord);      
        }else{
            //いる？
            //tenantList[selectedIndex] = GA103001Modal1Parameter.tenantRecord;   
        } 
    }
    //ここまで入居者モーダル------------------------------------------------------------------------------------
    
    //年齢再計算
    public void ageRecalculate(){
        //契約者年齢と連帯保証人年齢再計算
        Application__c newAgeApp =new Application__c(ApplicationDate__c=screenTargetRecord.applicationDate,
                                                 Birthdate__c = screenTargetRecord.birthdate,
                                                 JointGuarantorBirthdate__c = screenTargetRecord.jointGuarantorBirthdate);
        newAgeApp.recalculateFormulas();
        screenTargetRecord.age = newAgeApp.Age__c;
        screenTargetRecord.jointGuarantorAge = newAgeApp.JointGuarantorAge__c;

        //入居者年齢再計算
        for(Integer i = 0 ;tenantList.size() > i ;i++ ){
            Application__c newAgeApp2 = new Application__c(
                  ApplicationDate__c = screenTargetRecord.applicationDate
                , Birthdate__c       = tenantList[i].Birthdate__c);
            newAgeApp2.recalculateFormulas();//数式を用いて再計算
            
            tenantList[i].Age__c = newAgeApp2.Age__c; //画面に再表示
        }        
    }
    
    //確認ボタン
    public void confirm(){
        try{
            BusinessLogicException ex = new BusinessLogicException();
            hasErrorMessage = false;         

            //アプリで開いている場合のみ必須チェック
            if (isApp){
                List<String> ContractRequiredItem = new List<String>();//契約者情報
                List<String> affiliationRequiredItem = new List<String>();//勤務先情報
                List<String> studentRequiredItem = new List<String>();//学歴情報
                List<String> jointGuarantorRequiredItem = new List<String>();//連帯保証人または緊急連絡先
                List<String> joinAffRequiredItem = new List<String>();//連帯保証人勤務先

                //●●●契約者情報●●●
                requiredItemCheck(ContractRequiredItem,String.ValueOf(screenTargetRecord.applicationDate),'申込日');
                requiredItemCheck(ContractRequiredItem,String.ValueOf(screenTargetRecord.tenantDesiredDate),'入居希望日');
                //個人・学生（申込種別が法人以外）
                if (screenTargetRecord.applicationType != CommonConst.APPLICATION_APPLICATIONTYPE_CORPORATION){
                    requiredItemCheck(ContractRequiredItem,screenTargetRecord.lastName,'姓');
                    requiredItemCheck(ContractRequiredItem,screenTargetRecord.firstName,'名');
                    requiredItemCheck(ContractRequiredItem,screenTargetRecord.lastNameKana,'姓(カナ)');
                    requiredItemCheck(ContractRequiredItem,screenTargetRecord.firstNameKana,'名(カナ)');
                    requiredItemCheck(ContractRequiredItem,String.ValueOf(screenTargetRecord.birthdate),'生年月日');
                    requiredItemCheck(ContractRequiredItem,screenTargetRecord.childrenCount,'子供');
                    requiredItemCheck(ContractRequiredItem,screenTargetRecord.currentpostalCode,'郵便番号(現住所)');
                    requiredItemCheck(ContractRequiredItem,screenTargetRecord.currentState,'都道府県');
                    requiredItemCheck(ContractRequiredItem,screenTargetRecord.currentCity,'住所1（市区町村・丁目まで）');
                    requiredItemCheck(ContractRequiredItem,screenTargetRecord.currentStreet,'住所2（番地以降）');
                    requiredItemCheck(ContractRequiredItem,screenTargetRecord.residenceType,'住居種別');
                    if(screenTargetRecord.residenceTermYear == null || screenTargetRecord.residenceTermMonth == null ){
                        ContractRequiredItem.add('住居期間(年/月)');
                    }
                //法人（申込種別が法人）
                }else{
                    requiredItemCheck(ContractRequiredItem,screenTargetRecord.companyName,'法人名');
                    requiredItemCheck(ContractRequiredItem,screenTargetRecord.companyNameKana,'法人名(カナ)');
                    requiredItemCheck(ContractRequiredItem,screenTargetRecord.companyIndustries,'会社業種');
                    requiredItemCheck(ContractRequiredItem,screenTargetRecord.companyCapital,'資本金');
                    if(screenTargetRecord.companyEstablishmentYear == null || screenTargetRecord.companyEstablishmentMonth == null ){
                        ContractRequiredItem.add('設立(年/月)');
                    }                   
                    requiredItemCheck(ContractRequiredItem,screenTargetRecord.companyPhone,'法人電話番号');
                    requiredItemCheck(ContractRequiredItem,screenTargetRecord.companyPostalCode,'郵便番号(現住所)');
                    requiredItemCheck(ContractRequiredItem,screenTargetRecord.companyState,'都道府県');
                    requiredItemCheck(ContractRequiredItem,screenTargetRecord.companyCity,'所在地１（市区町村・丁目まで）');
                    requiredItemCheck(ContractRequiredItem,screenTargetRecord.companyStreet,'所在地２（番地以降）');
                    requiredItemCheck(ContractRequiredItem,screenTargetRecord.corporationRepresentative,'担当者');
                    requiredItemCheck(ContractRequiredItem,screenTargetRecord.corporationRepresentativePhone,'電話番号');
                }
                //●●●勤務先情報●●●（申込種別が個人）
                if (screenTargetRecord.applicationType == CommonConst.APPLICATION_APPLICATIONTYPE_INDIVIDUAL){
                    requiredItemCheck(affiliationRequiredItem,screenTargetRecord.affiliation,'勤務先');
                    requiredItemCheck(affiliationRequiredItem,screenTargetRecord.industries,'業種');
                    requiredItemCheck(affiliationRequiredItem,screenTargetRecord.affiliationPostalCode,'郵便番号(現住所)');
                    requiredItemCheck(affiliationRequiredItem,screenTargetRecord.affiliationState,'都道府県');
                    requiredItemCheck(affiliationRequiredItem,screenTargetRecord.affiliationCity,'所在地１（市区町村・丁目まで）');
                    requiredItemCheck(affiliationRequiredItem,screenTargetRecord.affiliationStreet,'所在地２（番地以降）');
                    requiredItemCheck(affiliationRequiredItem,screenTargetRecord.affiliationPhone,'電話番号');
                    requiredItemCheck(affiliationRequiredItem,screenTargetRecord.jobType,'職種');
                    requiredItemCheck(affiliationRequiredItem,screenTargetRecord.annualIncome,'年収');
                    if(screenTargetRecord.continuedServiceYearsYear == null || screenTargetRecord.continuedServiceYearsMonth == null ){
                        affiliationRequiredItem.add('勤続年数(年/月)');
                    }
                }
                //●●●学歴情報●●●（申込種別が学生）
                if (screenTargetRecord.applicationType == CommonConst.APPLICATION_APPLICATIONTYPE_STUDENT){
                    requiredItemCheck(studentRequiredItem,screenTargetRecord.affiliationSchool,'現在学校名');
                }
                //●●●連帯保証人または緊急連絡先●●●
                requiredItemCheck(jointGuarantorRequiredItem,screenTargetRecord.jointGuarantorLastName,'姓');
                requiredItemCheck(jointGuarantorRequiredItem,screenTargetRecord.jointGuarantorFirstName,'名');
                requiredItemCheck(jointGuarantorRequiredItem,screenTargetRecord.jointGuarantorLastNameKana,'姓(カナ)');
                requiredItemCheck(jointGuarantorRequiredItem,screenTargetRecord.jointGuarantorFirstNameKana,'名(カナ)');
                requiredItemCheck(jointGuarantorRequiredItem,screenTargetRecord.jointGuarantorPostalCode,'郵便番号(現住所)');
                requiredItemCheck(jointGuarantorRequiredItem,screenTargetRecord.jointGuarantorState,'都道府県');
                requiredItemCheck(jointGuarantorRequiredItem,screenTargetRecord.jointGuarantorCity,'住所1（市区町村・丁目まで）');
                requiredItemCheck(jointGuarantorRequiredItem,screenTargetRecord.jointGuarantorStreet,'住所2（番地以降）');
                requiredItemCheck(jointGuarantorRequiredItem,String.ValueOf(screenTargetRecord.jointGuarantorBirthdate),'生年月日');
                requiredItemCheck(jointGuarantorRequiredItem,screenTargetRecord.applicantRelationship,'お申込者との関係');
                requiredItemCheck(jointGuarantorRequiredItem,screenTargetRecord.jointGuarantorResidenceType,'住居種別');

                //●●●連帯保証人勤務先●●●
                if (JointGuarantorRadioButton == '連帯保証人'){
                    requiredItemCheck(joinAffRequiredItem,screenTargetRecord.jointGuarantorAffiliation,'会社名');
                    requiredItemCheck(joinAffRequiredItem,screenTargetRecord.jointGuarantorIndustries,'業種');
                    requiredItemCheck(joinAffRequiredItem,screenTargetRecord.jointGuarantorAffiliationPostalCode,'郵便番号(現住所)');
                    requiredItemCheck(joinAffRequiredItem,screenTargetRecord.jointGuarantorAffiliationState,'都道府県');
                    requiredItemCheck(joinAffRequiredItem,screenTargetRecord.jointGuarantorAffiliationCity,'所在地1（市区町村・丁目まで）');
                    requiredItemCheck(joinAffRequiredItem,screenTargetRecord.jointGuarantorAffiliationStreet,'所在地2（番地以降）');
                    requiredItemCheck(joinAffRequiredItem,screenTargetRecord.jointGuarantorAffiliationPhone,'電話番号');
                    requiredItemCheck(joinAffRequiredItem,screenTargetRecord.jointGuarantorJobType,'職種');
                    requiredItemCheck(joinAffRequiredItem,screenTargetRecord.jointGuarantorAnnualIncome,'年収');
                    if(screenTargetRecord.jointGuarantorContinuedServiceYearsYear == null || screenTargetRecord.jointGuarantorContinuedServiceYearsMonth == null ){
                        joinAffRequiredItem.add('勤続年数(年/月)');
                    }                
                }

                //必須チェック
                //●●●契約者情報●●●
                if (!ContractRequiredItem.isEmpty()){
                    ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, '[契約者情報]の'+String.join(ContractRequiredItem, ',')));
                }
                //申込種別が法人以外の場合、契約者電話・携帯電話入力チェック
                if (screenTargetRecord.applicationType != CommonConst.APPLICATION_APPLICATIONTYPE_CORPORATION){
                    if (String.isBlank(screenTargetRecord.currentPhone) && String.isBlank(screenTargetRecord.currentMobilePhone)){
                        ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_INPUT,'[契約者情報]の電話番号、携帯番号','どちらか1つ'));
                    }
                }

                //●●●勤務先情報●●●
                if (!affiliationRequiredItem.isEmpty()){
                    ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, '[勤務先情報]の'+String.join(affiliationRequiredItem, ',')));
                }
                

                //●●●学歴情報●●●
                if (!studentRequiredItem.isEmpty()){
                    ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, '[学歴情報]の'+String.join(studentRequiredItem, ',')));
                }

                //●●●連帯保証人または緊急連絡先●●●
                if (!jointGuarantorRequiredItem.isEmpty()){
                    ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, '[連帯保証人または緊急連絡先]の'+String.join(jointGuarantorRequiredItem, ',')));
                }
                //連帯保証人電話・携帯電話入力チェック
                if (String.isBlank(screenTargetRecord.jointGuarantorPhone) && String.isBlank(screenTargetRecord.jointGuarantorMobilePhone)){
                    //連帯保証人の電話番号、携帯どちらも未入力の場合、エラーメッセージを表示
                    ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_INPUT,'[連帯保証人または緊急連絡先]の電話番号、携帯番号','どちらか1つ'));

                }

                //●●●連帯保証人勤務先●●●
                if (!joinAffRequiredItem.isEmpty()){
                    ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, '[連帯保証人勤務先]の'+String.join(joinAffRequiredItem, ',')));
                }
            }

            //ビジネスロジックExceptionにメッセージが1つ以上ある場合、ビジネスロジックException発行
            if (ex.hasMessage()){ 
                throw ex;
            }
            
            //フラグの初期化
            this.isConfirm = true;  //変更確認フラグ
            this.privacy   = false; //個人情報保護フラグ
            this.isUpsert  = false; //署名の更新フラグ設定

            
        }catch(Exception e){
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }

    //キャンセルボタン
    public void cancel(){
        isConfirm = false;
    }

    //保存ボタン
    public void save(){
        Savepoint sp = Database.setSavepoint();      //セーブポイント作成
        hasErrorMessage = false;
        try{
            if (!isNew){
                //編集でデータ取得できない場合、楽観ロックチェックExceptionを発行
                List<Application__c> checkOptimisticLockExceptionRecord = new List<Application__c>();
                checkOptimisticLockExceptionRecord = [ SELECT id
                                                            FROM Application__c
                                                            WHERE id = :applicationId
                                                            AND SystemModStamp = :this.targetApplication.systemModStamp ];                //楽観ロックチェック
                if (checkOptimisticLockExceptionRecord.isEmpty()){
                    OptimisticLockException ex = new OptimisticLockException();
                    throw ex;
                }
            }
            //保存処理実行
            //★申込
            //申込人数設定
            Integer tenaCount;
            if(screenTargetRecord.isTenantPersonInclude){
                tenaCount = tenantList.size() + 1;
            }else{
                tenaCount = tenantList.size();
            }
            Application__c upsertRecord = new Application__c(
                Rent__c=CommonUtil.stringToDecimal(screenTargetRecord.rentFee),//賃料
                WortFee__c=CommonUtil.stringToDecimal(screenTargetRecord.wortFeeTax),//水道料金
                SecurityDeposit__c=CommonUtil.stringToDecimal(screenTargetRecord.securityDepositYen),//敷金
                RenewalFeeYen__c=CommonUtil.stringToDecimal(screenTargetRecord.renewalFeeTax),//更新料(円)
                ManagementFee__c=CommonUtil.stringToDecimal(screenTargetRecord.managementFeeTax),//共益費
                CATV__c=CommonUtil.stringToDecimal(screenTargetRecord.catvFeeTax),//CATV
                Deposit__c=CommonUtil.stringToDecimal(screenTargetRecord.depositYen),//保証料金
                TownshipAdmissionFee__c=CommonUtil.stringToDecimal(screenTargetRecord.townshipInitialFeeTax),//入町費(税込)
                TownshipFee__c=CommonUtil.stringToDecimal(screenTargetRecord.townshipFeeTax),//町会費
                GarbageDisposalFee__c=CommonUtil.stringToDecimal(screenTargetRecord.garbageDisposalFeeTax),//ゴミ処理費
                KeyMoney__c=CommonUtil.stringToDecimal(screenTargetRecord.keyMoneyYen),//礼金
                KeyExchangeFee__c=CommonUtil.stringToDecimal(screenTargetRecord.keyExchangeFeeTax),//鍵交換費
                BicycleParkingFee__c=CommonUtil.stringToDecimal(screenTargetRecord.bicycleParkingFeeTax),//駐輪場代
                ActualFee__c=CommonUtil.stringToDecimal(screenTargetRecord.cancellationActualFeeYen),//償却
                CleaningFeeYen__c=CommonUtil.stringToDecimal(screenTargetRecord.cleaningFeeTax),//定額修繕費(円)
                //駐車場
                ParkingFee__c=CommonUtil.stringToDecimal(screenTargetRecord.parkingFeeTax),//駐車場料金
                ParkingDeposit__c=CommonUtil.stringToDecimal(screenTargetRecord.parkingDepositTax),//駐車場保証料金
                ParkingCommission__c=CommonUtil.stringToDecimal(screenTargetRecord.parkingCompoundingFeeYenTax),//駐車場手数料
                BikeStorageSmallFirstFee__c=CommonUtil.stringToDecimal(screenTargetRecord.bikeParkingSmallFeeTax),//バイク置き場代（小型）日割額
                BikeStorageMediumFirstFee__c=CommonUtil.stringToDecimal(screenTargetRecord.bikeParkingMediumFeeTax),//バイク置き場代（中型）日割額
                BikeStorageLargeFirstFee__c=CommonUtil.stringToDecimal(screenTargetRecord.bikeParkinLargeFeeTax),//バイク置き場代（大型）日割額
                //契約者情報（共通）
                ApplicationType__c=screenTargetRecord.applicationType,//申込種別
                ApplicationDate__c=screenTargetRecord.applicationDate,//申込日
                TenantDesiredDate__c=screenTargetRecord.tenantDesiredDate,//入居希望日
                IsTenantPersonInclude__c=screenTargetRecord.isTenantPersonInclude,//申込者本人含む
                TenantCount__c=tenaCount,//入居人数（本人含む）
                //連帯保証人
                JointGuarantorLastName__c=screenTargetRecord.jointGuarantorLastName,//連帯保証人姓
                JointGuarantorFirstName__c=screenTargetRecord.jointGuarantorFirstName,//連帯保証人名
                JointGuarantorLastNameKana__c=screenTargetRecord.jointGuarantorLastNameKana,//連帯保証人姓（カナ）
                JointGuarantorFirstNameKana__c=screenTargetRecord.jointGuarantorFirstNameKana,//連帯保証人名（カナ）
                JointGuarantorPostalCode__c=screenTargetRecord.jointGuarantorPostalCode,//郵便番号
                JointGuarantorState__c=screenTargetRecord.jointGuarantorState,//都道府県
                JointGuarantorCity__c=screenTargetRecord.jointGuarantorCity,//住所1（市町村）
                JointGuarantorStreet__c=screenTargetRecord.jointGuarantorStreet,//住所２（番地）
                JointGuarantorBirthdate__c=screenTargetRecord.jointGuarantorBirthdate,//生年月日
                JointGuarantorPhone__c=screenTargetRecord.jointGuarantorPhone,//電話番号
                JointGuarantorMobilePhone__c=screenTargetRecord.jointGuarantorMobilePhone,//携帯番号
                ApplicantRelationship__c=screenTargetRecord.applicantRelationship,//お申込者との関係
                JointGuarantorIsSpouse__c=screenTargetRecord.jointGuarantorIsSpouse,//配偶者有無
                JointGuarantorResidenceType__c=screenTargetRecord.jointGuarantorResidenceType,//住居種別           
                //車両情報
                CarMaker__c=screenTargetRecord.carMaker,//メーカー
                CarType__c=screenTargetRecord.carType,//車種
                CarColor__c=screenTargetRecord.carColor,//色
                RegistNumber__c=screenTargetRecord.registNumber,//ナンバー
                //火災保険リスト用
                IsFireInsurancePlanUse__c = checkFireInsurance//火災保険利用有無
            );
            //契約者情報（申込種別が法人以外）
            if (screenTargetRecord.applicationType != CommonConst.APPLICATION_APPLICATIONTYPE_CORPORATION){
                upsertRecord.LastName__c=screenTargetRecord.lastName;//姓
                upsertRecord.FirstName__c=screenTargetRecord.firstName;//名
                upsertRecord.LastNameKana__c=screenTargetRecord.lastNameKana;//姓（カナ）
                upsertRecord.FirstNameKana__c=screenTargetRecord.firstNameKana;//名（カナ）
                upsertRecord.Birthdate__c=screenTargetRecord.birthdate;//生年月日
                upsertRecord.Current__c=screenTargetRecord.currentpostalCode;//郵便番号
                upsertRecord.CurrentState__c=screenTargetRecord.currentState;//都道府県
                upsertRecord.CurrentCity__c=screenTargetRecord.currentCity;//現住所１（市区町村）
                upsertRecord.CurrentStreet__c=screenTargetRecord.currentStreet;//現住所２（番地）
                upsertRecord.CurrentPhone__c=screenTargetRecord.currentPhone;//電話番号
                upsertRecord.CurrentMobilePhone__c=screenTargetRecord.currentMobilePhone;//携帯番号
                upsertRecord.IsSpouse__c=screenTargetRecord.isSpouse;//配偶者有無
                upsertRecord.ChildrenCount__c=CommonUtil.stringToDecimal(screenTargetRecord.childrenCount);//子供
                upsertRecord.ResidenceTermYear__c=CommonUtil.stringToDecimal(screenTargetRecord.residenceTermYear);//住所期間（年）
                upsertRecord.ResidenceTermMonth__c=CommonUtil.stringToDecimal(screenTargetRecord.residenceTermMonth);//住所期間（月）
                upsertRecord.ResidenceType__c=screenTargetRecord.residenceType;//住居種別
            }else{
                //申込種別が法人
                upsertRecord.CompanyName__c=screenTargetRecord.companyName;//会社名
                upsertRecord.CompanyNameKana__c=screenTargetRecord.companyNameKana;//会社名（カナ）
                upsertRecord.CompanyIndustries__c=screenTargetRecord.companyIndustries;//会社業種
                upsertRecord.CompanyPostalCode__c=screenTargetRecord.companyPostalCode;//会社郵便番号
                upsertRecord.CompanyState__c=screenTargetRecord.companyState;//会社都道府県
                upsertRecord.CompanyCity__c=screenTargetRecord.companyCity;//会社住所１
                upsertRecord.CompanyStreet__c=screenTargetRecord.companyStreet;//会社住所２
                upsertRecord.CompanyPhone__c=screenTargetRecord.companyPhone;//会社電話番号
                upsertRecord.CompanyFax__c=screenTargetRecord.companyFax;//会社FAX
                upsertRecord.CompanyEstablishmentYear__c=screenTargetRecord.companyEstablishmentYear;//設立（年）
                upsertRecord.CompanyEstablishmentMonth__c=screenTargetRecord.companyEstablishmentMonth;//設立（月）
                upsertRecord.CompanyCapital__c=CommonUtil.stringToDecimal(screenTargetRecord.companyCapital);//資本金
                upsertRecord.CorporationRepresentative__c=screenTargetRecord.corporationRepresentative;//担当者（法人用）
                upsertRecord.CorporationRepresentativePhone__c=screenTargetRecord.corporationRepresentativePhone;//担当者（法人用）電話番号
                upsertRecord.CorporationDepartment__c=screenTargetRecord.corporationDepartment;//所属部署
                upsertRecord.CorporationPost__c=screenTargetRecord.corporationPost;//役職
            }
            //勤務先（申込種別が個人）
            if (screenTargetRecord.applicationType == CommonConst.APPLICATION_APPLICATIONTYPE_INDIVIDUAL){
                upsertRecord.Affiliation__c=screenTargetRecord.affiliation;//勤務先
                upsertRecord.AffiliationPostalCode__c=screenTargetRecord.affiliationPostalCode;//郵便番号
                upsertRecord.AffiliationState__c=screenTargetRecord.affiliationState;//都道府県
                upsertRecord.AffiliationCity__c=screenTargetRecord.affiliationCity;//住所1（市区町村）
                upsertRecord.AffiliationStreet__c=screenTargetRecord.affiliationStreet;//住所２（番地）
                upsertRecord.AffiliationPhone__c=screenTargetRecord.affiliationPhone;//電話番号
                upsertRecord.Industries__c=screenTargetRecord.industries;//業種
                upsertRecord.JobType__c=screenTargetRecord.jobType;//職種
                upsertRecord.Department__c=screenTargetRecord.department;//部署
                upsertRecord.Post__c=screenTargetRecord.post;//役職
                upsertRecord.AnnualIncome__c=CommonUtil.stringToDecimal(screenTargetRecord.annualIncome);//年収
                upsertRecord.ContinuedServiceYearsYear__c=CommonUtil.stringToDecimal(screenTargetRecord.continuedServiceYearsYear);//勤続年数（年）
                upsertRecord.ContinuedServiceYearsMonth__c=CommonUtil.stringToDecimal(screenTargetRecord.continuedServiceYearsMonth);//勤続年数（月）
            }
            //学歴情報（申込種別が学生）
            if (screenTargetRecord.applicationType == CommonConst.APPLICATION_APPLICATIONTYPE_STUDENT){
                upsertRecord.AffiliationSchool__c=screenTargetRecord.affiliationSchool;//現在学校名
                upsertRecord.PlannedEnrollment__c=screenTargetRecord.plannedEnrollment;//入学予定校
                upsertRecord.InformalOffer__c=screenTargetRecord.informalOffer;//内定有無
                upsertRecord.PassResultDate__c=screenTargetRecord.passResultDate;//合格発表日
            }
            //連帯保証人勤務先（ラジオボタンが連帯保証人のときのみ保存）
            if (JointGuarantorRadioButton == '連帯保証人'){
                upsertRecord.JointGuarantorAffiliation__c=screenTargetRecord.jointGuarantorAffiliation;//勤務先
                upsertRecord.JointGuarantorIndustries__c=screenTargetRecord.jointGuarantorIndustries;//業種
                upsertRecord.JointGuarantorAffiliationPostalCode__c=screenTargetRecord.jointGuarantorAffiliationPostalCode;//郵便番号
                upsertRecord.JointGuarantorAffiliationState__c=screenTargetRecord.jointGuarantorAffiliationState;//都道府県
                upsertRecord.JointGuarantorAffiliationCity__c=screenTargetRecord.jointGuarantorAffiliationCity;//住所
                upsertRecord.JointGuarantorAffiliationStreet__c=screenTargetRecord.jointGuarantorAffiliationStreet;//住所
                upsertRecord.JointGuarantorAffiliationPhone__c=screenTargetRecord.jointGuarantorAffiliationPhone;//電話番号
                upsertRecord.JointGuarantorDepartment__c=screenTargetRecord.jointGuarantorDepartment;//所属
                upsertRecord.JointGuarantorJobType__c=screenTargetRecord.jointGuarantorJobType;//職種
                upsertRecord.JointGuarantorPost__c=screenTargetRecord.jointGuarantorPost;//役職
                upsertRecord.JointGuarantorAnnualIncome__c=CommonUtil.stringToDecimal(screenTargetRecord.jointGuarantorAnnualIncome);//年収
                upsertRecord.JointGuarantorContinuedServiceYearsYear__c=CommonUtil.stringToDecimal(screenTargetRecord.jointGuarantorContinuedServiceYearsYear);//勤務年数（年）
                upsertRecord.JointGuarantorContinuedServiceYearsMonth__c=CommonUtil.stringToDecimal(screenTargetRecord.jointGuarantorContinuedServiceYearsMonth);//勤務年数（月）
                
            }
            if(!isNew){
                //既存申込を更新時
                upsertRecord.id=this.targetApplication.id;
            }else{
                // 税率取得（仲介手数料と駐車場紹介料は入力された内容から税込みを）
                decimal TaxRate = SystemConfig__c.getInstance().TaxRate__c;

                //申込を新規作成時
                upsertRecord.Account__c = accountId;
                upsertRecord.Property__c = propertyId;
                upsertRecord.Corresponds__c = correspondId;            //対応Id
                upsertRecord.CancellationActualFeeUnit__c = screenTargetRecord.cancellationActualFeeUnit;//敷引・償却単位
				// //火災保険（レコードがあるときのみ
				// if (fireInsuranceRecord != null){
				// 	upsertRecord.FireInsuranceTitle__c =  targetProperty.FireInsurancePlan__c;//火災保険タイトル
				// 	// ▼ 2022.02.15 No0727 金額代入の誤り修正	
				// 	upsertRecord.FireInsuranceMonth__c = fireInsuranceRecord.FireInsuranceMonth__c;//火災保険料(月額)
				// 	upsertRecord.FireInsuranceYear__c = fireInsuranceRecord.FireInsuranceYear__c;//火災保険料(年額)
				// 	// ▲ 2022.02.15 No0727 金額代入の誤り修正
				// }
                //口コミ売上修正画面用
                upsertRecord.IsReviewEntry__c=false;//口コミ
                upsertRecord.IsReviewRequestProhibited__c=false;//口コミ依頼拒否
                if (!string.isBlank( this.screenTargetRecord.rentFee)){
                    upsertRecord.BrokerageFirstFee__c=CommonUtil.stringToDecimal(this.screenTargetRecord.rentFee) + (CommonUtil.stringToDecimal(this.screenTargetRecord.rentFee) * (0.01 * TaxRate ));//仲介手数料
                }
                upsertRecord.ADFee__c=targetProperty.ADFeeTax__c;//広告料（税込
                upsertRecord.ParkingBrokerageFirstFee__c=CommonUtil.stringToDecimal(this.screenTargetRecord.ParkingFeeTax);   //駐車場紹介料
            }
            // 2022.02.15 No0727 賃料設定変更と総賃料の計算位置変更
			upsertRecord.RentFee__c=CommonUtil.stringToDecimal(this.screenTargetRecord.rentFee);//賃料
			// ▼ 2022.02.15 No0727 火災保険の登録タイミングの謝り
			//火災保険（レコードがあるときのみ
			if (fireInsuranceRecord != null){
				upsertRecord.FireInsuranceTitle__c =  fireInsuranceRecord.Id;//火災保険タイトル
				// ▼ 2022.02.15 No0727 金額代入の誤り修正	
				upsertRecord.FireInsuranceMonth__c = fireInsuranceRecord.FireInsuranceMonth__c;//火災保険料(月額)
				upsertRecord.FireInsuranceYear__c = fireInsuranceRecord.FireInsuranceYear__c;//火災保険料(年額)
				// ▲ 2022.02.15 No0727 金額代入の誤り修正
			}
			// ▲ 2022.02.15 No0727 火災保険の登録タイミングの謝り
            SecureDML.secureUpsert(upsertRecord);  

            
            //★申込商品明細（保証会社）
            if (guaranteeDetailList.size() != 0){
                List<ApplicantItemDetail__c> upsertItemDetailList = new List<ApplicantItemDetail__c>();
                for(ScreenGuaranteeItem a :guaranteeDetailList) {     
                    //%を取り除く   
                    if(a.firstFeeDepositRate != null){
                        a.firstFeeDepositRate = a.firstFeeDepositRate.replace('%', '');
                    }
                    if(a.depositRate != null){
                        a.depositRate = a.depositRate.replace('%', '');
                    }   
                    ApplicantItemDetail__c appItemDetail = new ApplicantItemDetail__c(
                        ProvisionalQuote__c = upsertRecord.id,
                        IsPlanUse__c = a.isPlanUse,                  //利用有無
                        GuaranteeidCompanyName__c = a.guaranteeidCompanyName,//保証会社名
                        GuaranteeidItemName__c = a.guaranteeidItemName,//保証プラン名
                        PlanDetail__c = a.planDetail,                 //プラン詳細
                        FirstFeeDepositRate__c = CommonUtil.stringToDecimal(a.firstFeeDepositRate),//初回保証料(割合)
                        FirstFeeDepositYen__c = a.firstFeeDepositYen, //初回保証料(金額)
                        DepositRate__c = CommonUtil.stringToDecimal(a.depositRate),//保証料(割合)
                        DepositYen__c = a.depositYen,                 //保証料(金額)
                        IsRentFeeType__c = (a.isRentFeeType == '総賃料') ? true : false,//賃料区分
                        DepositRemarks__c = a.dsepositRemarks         //備考
                    );
                    if(!isNew){
                        appItemDetail.id = a.id;
                        appItemDetail.IsPlanUse__c = a.isPlanUse;//利用有無
                    }
                    upsertItemDetailList.add(appItemDetail);
                }
                SecureDML.secureUpsert(upsertItemDetailList);
            }

            ///★申込指定会社商品
			// 2022.02.15 No0727 総賃料計算用に使用
			List<ApplicantQuoteManageCompayItem__c> upsertQuoteManageRecordList = new List<ApplicantQuoteManageCompayItem__c>();
            if (quoteManageCompayItemList.size() != 0){
                for(ScreenQuoteManageCompayItem a :quoteManageCompayItemList) {
                    ApplicantQuoteManageCompayItem__c appQuoteManage = new ApplicantQuoteManageCompayItem__c(
                        ProvisionalQuote__c = upsertRecord.id,
                        IsPlanUse__c =a.isPlanUse,
                        ItemName__c =a.itemName,
                        AmountTax__c = a.amountTax,
                        PaymentType__c =a.paymentType,
                        TaxType__c =a.taxType
                    );
                    if(!isNew){
                        appQuoteManage.id = a.id;
                        appQuoteManage.IsPlanUse__c =a.isPlanUse;
                    }
                    upsertQuoteManageRecordList.add(appQuoteManage);
                }
                SecureDML.secureUpsert(upsertQuoteManageRecordList);            
            }

            //★入居者リスト
            if (tenantList.size() != 0){
                List<Tenant__c> upsertTenantList = new List<Tenant__c>();
                for(Tenant__c a :tenantList) {
                    Tenant__c tenant = new Tenant__c(
                        Application__c = upsertRecord.id,
                        LastName__c = a.LastName__c,
                        FirstName__c = a.FirstName__c,
                        LastNameKana__c =a.LastNameKana__c,
                        FirstNameKana__c =a.FirstNameKana__c,
                        Birthdate__c =a.Birthdate__c,
                        Age__c = a.Age__c,
                        Relationship__c =a.Relationship__c,
                        JobType__c =a.JobType__c,
                        Remarks__c =a.Remarks__c
                    );
                    if(!isNew){
                        tenant.id = a.id;
                    }
                    upsertTenantList.add(tenant);
                }
                SecureDML.secureUpsert(upsertTenantList);
            }
            //★削除ボタンが押されたIdのある入居者リスト削除
            if (deleteTenantList.size() != 0){
                SecureDML.secureDelete(deleteTenantList);
            }
            //★対応（更新）
            saveCorrespond(upsertRecord);

            //★対応明細（新規作成）
            saveCorrespondDetail(upsertRecord);

			// ▼ 2022.02.15 No0727 総賃料計算
            upsertRecord.AllRentFee__c=CustomerUtil.calcAllRentApplication(upsertRecord,upsertQuoteManageRecordList);//総賃料
			SecureDML.secureUpdate(upsertRecord);
			// ▲ 2022.02.15 No0727 総賃料計算
            //署名用の項目設定
            parentId = upsertRecord.Id;  //申込Id

            //view2パラメータ設定
            view2Param = upsertRecord.id; //申込Id
            
        }catch(Exception e){
            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }
    
    
    //リモートアクションを用いた、電子サインの添付ファイル保存処理
    @RemoteAction
    global static void saveSignature(String signValue, String parentId, String attachmentId) {
        
        Savepoint sp = Database.setSavepoint();      //セーブポイント作成

        try{

            // 添付ファイル
            Attachment signAttachment = new Attachment();
            
            if (String.isNotBlank(attachmentId)) {  //Idがない場合、更新
                signAttachment.Id = attachmentId;
            } else {                                //Idがある場合、新規
                signAttachment.ParentID = parentId;
            }
            
            signAttachment.Body = EncodingUtil.base64Decode(signValue.replace('data:image/png;base64,', ''));
            signAttachment.contentType = 'image/png';
            signAttachment.Name = '電子サイン';
            signAttachment.OwnerId = UserInfo.getUserId();

            SecureDML.secureUpsert(signAttachment);

        } catch(Exception e){
            
            // 異常終了
            Database.rollback(sp);//処理をロールバック
            throw new BusinessLogicException('システムエラーが発生しました。' + e.getMessage());
        }
        
    }

    /**◇◇◇◇◇◇ここまでpublicメソッド◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇**/

    /******以下privateメソッド******************************************************************************/
   //初期化メソッド
    private void init(){
        this.isNew = false;             //新規作成フラグ
        this.isConfirm = false;         //確認画面フラグ
        this.isOpenError = false;
        this.hasErrorMessage = false;
        //火災保険Idリストを初期化
        fireInsuranceIdList =  new List<Id>();
        //保証会社リスト初期化
        guaranteeDetailList = new List<ScreenGuaranteeItem>();
        //指定会社商品リスト初期化
        quoteManageCompayItemList = new List<ScreenQuoteManageCompayItem>();
        //入居者関連
        tenantList = new List<Tenant__c>();         //入居者リスト初期化
        deletetenantList = new List<Tenant__c>();   //入居者削除用リスト初期化
        //郵便番号モーダル初期化
        GA102006Parameter = new GA102006ParameterClass();
        
        //パラメータ取得、isNewの設定、セクション表示設定 
        parmAndIsNewSetting();

        //店舗レコード取得
        targetShop = CommonUtil.getStaffCurrentShop();

        this.parentId = null; //保存時用の申込Id
    }

    //必須チェック（エラー項目のStringList、項目の中身、項目名）
    private List<String> requiredItemCheck(List<String> requiredItem ,String item,String itemName){
        List<String> returnList = requiredItem;        
        if (String.isBlank(item)){
            returnList.add(itemName);
        }
        return returnList;
    }

    //パラメータとisNewの設定
    private void parmAndIsNewSetting(){
        //○○パラメータ取得○○
        //申込Id
        this.applicationId = ApexPages.currentPage().getParameters().get('applicationId');
        //取引先Id
        this.accountId = ApexPages.currentPage().getParameters().get('accountId');
        //物件Id
        this.propertyId = ApexPages.currentPage().getParameters().get('propertyId');
        //対応Id
        this.correspondId = ApexPages.currentPage().getParameters().get('correspondId');
        //遷移元区分
        if(ApexPages.currentPage().getParameters().get('comeFrom') == 'App'){
            this.isApp = true;
        }else{
            this.isApp = false;
        }
        
        //担当者Id
        if(String.isBlank(this.userId)){
            this.userId = ApexPages.currentPage().getParameters().get('userId');
        }
        //パラメータの担当者IdとログインユーザIdが異なる場合エラー
        if(String.isNotBlank(this.userId)){
            if(this.userId != UserInfo.getUserId()){
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_LOGGING_DIFFERENT_USER, UserInfo.getName()));
                throw ex;   
            }
        }
		// ▼ 2022.03.01 No0739 同じ申込を2件以上登録できないように対応から申込があるかを確認する
		if(this.applicationId == null){
			this.applicationId = selectApplicationExistence(this.accountId,this.correspondId);
		}
		// ▲ 2022.03.01 No0739 同じ申込を2件以上登録できないように対応から申込があるかを確認する

        //申込Idが取得できない場合は新規登録フラグにTRUEを設定する
        if(this.applicationId == null){
            this.isNew = true;         
            //画面表示変数の設定（target取引先とtarget物件を設定し、内部クラスの画面項目をNewする）
            this.screenTargetRecord = new ScreenItem(selectAccountInfo(this.accountId),SelectPropertyInfo(this.propertyId));        
            JointGuarantorRadioButton = '連帯保証人';
        //申込Idが取得できた場合は新規登録フラグにFALSEを設定する
        } else {
            this.isNew = false;
            //画面表示変数の設定（target取引先を設定し、内部クラスの画面項目をNewする）
            this.screenTargetRecord = new ScreenItem(selectApplicationInfo(this.applicationId));
            if (screenTargetRecord.jointGuarantorAffiliation != null){
                JointGuarantorRadioButton = '連帯保証人';
            }else{
                JointGuarantorRadioButton = '緊急連絡先';
            }
        }

        //対応オブジェクト設定
        correspondSetting();
        //火災保険レコードfireInsuranceRecordがnullじゃないなら、火災保険リストIdにList<Id>に、
        if (fireInsuranceRecord != null){
            fireInsuranceIdList.add(fireInsuranceRecord.Id);
        }        
        //保証のリストを設定
        guaranteeSetting();
        //管理会社指定商品を設定
        quoteManageCompayItemSetting();
        //選択リスト設定
        selectListSetting();
        //入居者リスト設定
        tenantSetting();
        //項目の表示非表示設定（アプリ用）
        sectionTitle();
    }

    //対応オブジェクト設定
    private void correspondSetting(){
        List<Correspond__c> targetCorrespondList= [SELECT 
                            ShopStaff__c   //担当者(来店)
                           ,Status__c    //お客様ステータス
                            FROM Correspond__c
                            WHERE id =  :correspondId];            
        //レコード情報が取得できなければビジネスロジックException発行
        if( targetCorrespondList.isEmpty() ){
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
            throw ex;
        }
        targetCorrespond = targetCorrespondList[0];
    }

    //保証のリスト設定
    private void guaranteeSetting(){
        if (isNew){
            //商品明細を用いる（isNewがTrue）
             List<ItemDetail__c> ItemDetailList= [SELECT id,
                                    Name,                          //名称(非表示)
                                    Item__r.Account__r.Name,       //取引先名
                                    Item__r.ItemName__c,                  //商品名
                                    PlanDetail__c,                 //プラン詳細
                                    FirstFeeDepositRate__c,        //初回保証料(割合)
                                    FirstFeeDepositYen__c,         //初回保証料(金額)
                                    DepositRate__c,                //保証料(割合)
                                    DepositYen__c,                 //保証料(金額)
                                    IsRentFeeType__c,              //賃料区分
                                    DepositRemarks__c              //備考
                                    FROM ItemDetail__c
                                    WHERE Item__c =  :targetProperty.Guaranteeid__c
                                    AND Item__r.RecordTypeId = :commonUtil.getRecordTypeId('Item__c',commonConst.ITEM_RECTYPE_GUARANTEE_PLAN)
                                    ORDER BY Item__r.NameLink__c,Name];            
            for(ItemDetail__c a :ItemDetailList) {
                guaranteeDetailList.add(new ScreenGuaranteeItem(a));
            }

            if (!ItemDetailList.isEmpty()){
                guaranteeDetailList[0].isPlanUse=true;
            }

        }else{
            //申込商品明細を用いる（isNewがFalse）
             List<ApplicantItemDetail__c> appDetailList= [SELECT id,
                                    IsPlanUse__c,                  //利用有無
                                    GuaranteeidCompanyName__c,     //保証会社名
                                    GuaranteeidItemName__c,        //保証プラン名
                                    PlanDetail__c,                 //プラン詳細
                                    FirstFeeDepositRate__c,        //初回保証料(割合)
                                    FirstFeeDepositYen__c,         //初回保証料(金額)
                                    DepositRate__c,                //保証料(割合)
                                    DepositYen__c,                 //保証料(金額)
                                    IsRentFeeType__c,              //賃料区分
                                    DepositRemarks__c              //備考
                                    FROM ApplicantItemDetail__c
                                    WHERE ProvisionalQuote__c =  :this.applicationId
                                    ORDER BY IsPlanUse__c DESC,
                                        GuaranteeidCompanyName__c];

            for(ApplicantItemDetail__c b :appDetailList) {
                    guaranteeDetailList.add(new ScreenGuaranteeItem(b));
            }
        }
    }

    //指定会社商品リストの設定
    private void quoteManageCompayItemSetting(){
        if (isNew){
            //管理会社指定商品を用いる（isNewがTrue）
             List<ManagementCompanyItem__c> companyItemList= [SELECT id,
                                    Name,              //管理会社指定商品番号（非表示）
                                    Account__c,        //取引先（非表示）
                                    ItemName__c,       //商品名
                                    AmountTax__c,      //金額
                                    PaymentType__c,    //支払区分
                                    TaxType__c         //税区分
                                    //▼問合せNo0569で変更
                                    ,(
                                        SELECT
                                            Id
                                        ,   Item__c
                                        FROM propertyManageCompayItemItem__r        // 物件管理会社指定商品取得
                                        WHERE
                                            Property__c     = :targetProperty.Id
                                        AND Account__c      = :targetProperty.FormerSupplier__c
                                    )
                                    //▲問合せNo0569で変更
                                    FROM ManagementCompanyItem__c
                                    WHERE Account__c =  :targetProperty.FormerSupplier__c
                                    ORDER BY Name];            
            for(ManagementCompanyItem__c a :companyItemList) {
                quoteManageCompayItemList.add(new ScreenQuoteManageCompayItem(a));
            }

        }else{
            //申込指定商品を用いる（isNewがFalse）
             List<ApplicantQuoteManageCompayItem__c> quoteList= [SELECT id,
                                    IsPlanUse__c,                //利用有無
                                    ProvisionalQuote__c,         //申込番号（非表示）
                                    ItemName__c,                 //商品名
                                    AmountTax__c,                //金額（税込）
                                    PaymentType__c,              //支払い区分
                                    TaxType__c                   //税区分
                                    FROM ApplicantQuoteManageCompayItem__c
                                    WHERE ProvisionalQuote__c =  :this.applicationId
                                    ORDER BY IsPlanUse__c DESC,
                                        Name];

            for(ApplicantQuoteManageCompayItem__c b :quoteList) {
                    quoteManageCompayItemList.add(new ScreenQuoteManageCompayItem(b));
            }    
        }        
    }

    //入居者リスト設定
    private void tenantSetting(){
        if(!isNew){           
            tenantList = [SELECT id,
                                Application__r.Name,//申込番号（非表示）
                                //IsDeleted,          //削除フラグ（非表示）
                                FullName__c,        //氏名
                                LastName__c,
                                FirstName__c,
                                LastNameKana__c,
                                FirstNameKana__c,
                                FullNameKana__c,    //氏名（カナ）
                                Age__c,             //年齢
                                Birthdate__c,       //生年月日
                                Relationship__c,    //続柄
                                JobType__c,         //職種
                                Remarks__c          //備考
                        FROM Tenant__c
                        WHERE Application__r.Name=:targetApplication.Name
                        ORDER BY Age__c DESC]; 
        }       
    }
 
    //選択リスト設定
    private void selectListSetting(){
        //個人都道府県選択リスト設定
        this.SelectStateList = CommonUtil.getSelectOptionFromObject('Account', 'State__c');                
        //会社都道府県選択リスト設定
        this.SelectCompanyStateList = CommonUtil.getSelectOptionFromObject('Account', 'CompanyState__c'); 
        //勤務先都道府県選択リスト設定
        this.SelectAffiliationStateList = CommonUtil.getSelectOptionFromObject('Application__c', 'AffiliationState__c'); 
        //連帯保証人都道府県リスト設定
        this.SelectJointGuarantorStateList = CommonUtil.getSelectOptionFromObject('Application__c', 'JointGuarantorState__c');     
        //連帯保証人勤務先都道府県リスト設定
        this.SelectJointGuarantorAffiliationStateList = CommonUtil.getSelectOptionFromObject('Application__c', 'JointGuarantorAffiliationState__c');     
        //更新種別選択リスト設定
        this.SelectapplicationTypeList = CommonUtil.getSelectOptionFromObject('Application__c', 'ApplicationType__c',false);                
        //配偶者有無選択リスト設定
        this.SelectIsSpouseList = CommonUtil.getSelectOptionFromObject('Application__c', 'IsSpouse__c',false);
        //住居種別選択選択リスト設定
        this.SelectResidenceTypeList = CommonUtil.getSelectOptionFromObject('Application__c', 'ResidenceType__c');     
        //業種選択リスト設定
        this.SelectIndustriesList = CommonUtil.getSelectOptionFromObject('Application__c', 'Industries__c');     
        //職種選択リスト設定
        this.SelectJobTypeList = CommonUtil.getSelectOptionFromObject('Application__c', 'JobType__c'); 
        //会社業種選択リスト設定
        this.SelectCompanyIndustriesList = CommonUtil.getSelectOptionFromObject('Application__c', 'CompanyIndustries__c'); 
        //内定有無リスト設定
        this.SelectInformalOfferList = CommonUtil.getSelectOptionFromObject('Application__c', 'InformalOffer__c',false); 
        //保証人と申込者との関係選択リスト
        this.SelectApplicantRelationshipList = CommonUtil.getSelectOptionFromObject('Application__c', 'ApplicantRelationship__c');
        //保証人配偶者有無選択リスト
        this.SelectJointGuarantorIsSpouseList = CommonUtil.getSelectOptionFromObject('Application__c', 'JointGuarantorIsSpouse__c',false);
        //保証人住居種別選択リスト
        this.SelectJointGuarantorResidenceTypeList = CommonUtil.getSelectOptionFromObject('Application__c', 'JointGuarantorResidenceType__c');
        //保証人住居業種選択リスト
        this.SelectJointGuarantorIndustriesList = CommonUtil.getSelectOptionFromObject('Application__c', 'JointGuarantorIndustries__c');
        //保証人住居職種選択リスト
        this.SelectJointGuarantorJobTypeList = CommonUtil.getSelectOptionFromObject('Application__c', 'JointGuarantorJobType__c');
    }

    //セクションのタイトル項目を表示するかの判断  
    private void sectionTitle(){
        //基本情報
        if (!String.isEmpty(screenTargetRecord.rentFee) && screenTargetRecord.rentFee!='0') {
            hasBasicSection=true;
        }
        if(!String.isEmpty(screenTargetRecord.wortFeeTax) && screenTargetRecord.wortFeeTax!='0') {
            hasBasicSection=true;
        }
        if(!String.isEmpty(screenTargetRecord.securityDepositYen) && screenTargetRecord.securityDepositYen!='0') {
            hasBasicSection=true;
        }
        if(!String.isEmpty(screenTargetRecord.renewalFeeTax) && screenTargetRecord.renewalFeeTax!='0') {
            hasBasicSection=true;
        }
        if(!String.isEmpty(screenTargetRecord.managementFeeTax) && screenTargetRecord.managementFeeTax!='0') {
            hasBasicSection=true;
        }
        if(!String.isEmpty(screenTargetRecord.catvFeeTax) && screenTargetRecord.catvFeeTax!='0') {
            hasBasicSection=true;
        }
        if(!String.isEmpty(screenTargetRecord.depositYen) && screenTargetRecord.depositYen!='0') {
            hasBasicSection=true;
        }
        if(!String.isEmpty(screenTargetRecord.townshipInitialFeeTax) && screenTargetRecord.townshipInitialFeeTax!='0') {
            hasBasicSection=true;
        }
        if(!String.isEmpty(screenTargetRecord.townshipFeeTax) && screenTargetRecord.townshipFeeTax!='0') {
            hasBasicSection=true;
        }
        if(!String.isEmpty(screenTargetRecord.garbageDisposalFeeTax) && screenTargetRecord.garbageDisposalFeeTax!='0') {
            hasBasicSection=true;
        }
        if(!String.isEmpty(screenTargetRecord.keyMoneyYen) && screenTargetRecord.keyMoneyYen!='0') {
            hasBasicSection=true;
        }
        if(!String.isEmpty(screenTargetRecord.keyExchangeFeeTax) && screenTargetRecord.wortFeeTax!='0') {
            hasBasicSection=true;
        }
        if(!String.isEmpty(screenTargetRecord.bicycleParkingFeeTax) && screenTargetRecord.bicycleParkingFeeTax!='0') {
            hasBasicSection=true;
        }
        if(!String.isEmpty(screenTargetRecord.cancellationActualFeeYen) && screenTargetRecord.cancellationActualFeeYen!='0') {
            hasBasicSection=true;
        }
        if(!String.isEmpty(screenTargetRecord.cleaningFeeTax) && screenTargetRecord.cleaningFeeTax!='0') {
            hasBasicSection=true;
        }

        //駐車場
        if (!String.isEmpty(screenTargetRecord.parkingFeeTax) && screenTargetRecord.parkingFeeTax!='0') {
            hasParkingSection=true;
        }
        if(!String.isEmpty(screenTargetRecord.parkingDepositTax) && screenTargetRecord.parkingDepositTax!='0') {
            hasParkingSection=true;
        }
        if(!String.isEmpty(screenTargetRecord.parkingCompoundingFeeYenTax) && screenTargetRecord.parkingCompoundingFeeYenTax!='0') {
            hasParkingSection=true;
        }
        if(!String.isEmpty(screenTargetRecord.bikeParkingSmallFeeTax) && screenTargetRecord.bikeParkingSmallFeeTax!='0') {
            hasParkingSection=true;
            hasBikeParkingSection=true;
        }
        if(!String.isEmpty(screenTargetRecord.bikeParkingMediumFeeTax) && screenTargetRecord.bikeParkingMediumFeeTax!='0') {
            hasParkingSection=true;
            hasBikeParkingSection=true;
        }
        if(!String.isEmpty(screenTargetRecord.bikeParkinLargeFeeTax) && screenTargetRecord.bikeParkinLargeFeeTax!='0') {
            hasParkingSection=true;
            hasBikeParkingSection=true;
        }
    }
    
    
    
    
    //○○レコード情報取得○○
    //target取引先情報取得
    private Account selectAccountInfo(Id accountId){

                List<Account> targetAccountList = [SELECT id,
                                                    ContractType__c,        //契約形態
                                                    Name,                   //取引先名
                                                    NameKana__c,            //取引先名（カナ）
                                                    LastName__c,            //姓
                                                    FirstName__c,           //名
                                                    LastNameKana__c,        //姓（カナ）
                                                    FirstNameKana__c,       //名（カナ）
                                                    Birthdate__c,           //生年月日
                                                    Age__c,                 //年齢
                                                    PostalCode__c,          //郵便番号
                                                    State__c,               //都道府県
                                                    City__c,                //住所１（市区町村）
                                                    Street__c,              //住所２（番地）
                                                    Phone,                  //電話
                                                    CompanyName__c,         //会社名
                                                    CompanyNameKana__c,     //会社名（カナ）
                                                    CompanyIndustries__c,   //会社 業種
                                                    CompanyPostalCode__c,   //会社 郵便番号
                                                    CompanyState__c,        //会社 都道府県
                                                    CompanyCity__c,         //会社 住所１
                                                    CompanyStreet__c,       //会社 住所２
                                                    CorporationRepresentative__c,//担当者（法人用)
                                                    Department__c,          //所属部署
                                                    Post__c,                //役職
                                                    JobType__c,             //職種
                                                    AccountIndustry__c,             //業種
                                                    Affiliation__c,             //勤務先/学校
                                                    AffiliationPostalCode__c,//勤務先/学校　郵便番号
                                                    AffiliationState__c,//勤務先/学校　都道府県
                                                    AffiliationCity__c,//勤務先/学校　住所1
                                                    AffiliationStreet__c, //勤務先/学校　住所2
                                                    AffiliationPhone__c //勤務先/電話番号

                                                FROM Account
                                                WHERE id = :this.accountId]; 
        //レコード情報が取得できなければビジネスロジックException発行
        if( targetAccountList.isEmpty() ){
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
            throw ex;
        }

        targetAccount = targetAccountList[0];
        return targetAccountList[0];
    }

    //target物件情報取得
    private Property__c SelectPropertyInfo(Id propertyId){
        List<Property__c> targetPropertyList = [SELECT id,
                                                 Building__r.Name,          //建物名
                                                 Name,                      //部屋番号
                                                 Building__r.Address__c,    //住所
                                                 //基本情報
                                                 RentFee__c,                 //賃料
                                                 WortFeeTax__c,              //水道料金（税込）
                                                 SecurityDepositYen__c,      //敷金（円）
                                                 RenewalFee__c,              //更新料（税込）
                                                 ManagementFeeTax__c,        //管理費（税込）
                                                 CATVFeeTax__c,              //CATV（税込）
                                                 DepositYen__c,              //保証料金(円)
                                                 TownshipInitialFeeTax__c,   //入町費(税込)
                                                 TownshipFeeTax__c,          //町会費（税込）
                                                 GarbageDisposalFeeTax__c,   //ゴミ処理費(税込)
                                                 KeyMoneyYen__c,             //礼金(円)
                                                 KeyExchangeFeeTax__c,       //鍵交換費(税込)
                                                 BicycleParkingFeeTax__c,    //駐輪場代(税込)
                                                 CancellationActualFeeYen__c,//敷引・償却(円)
                                                 CancellationActualFeeUnit__c,//敷引・償却単位
                                                 CleaningFeeTax__c,          //定額修繕費(税込)
                                                 //駐車場情報
                                                 ParkingFeeTax__c,           //駐車場料金(税込)
                                                 ParkingDepositTax__c,       //駐車場保証料金(税込)
                                                 ParkingCompoundingFeeTax__c,//駐車場手数料(税込)
                                                 BikeParkingSmallFeeTax__c,  //小型バイク置場料金(税込)
                                                 BikeParkingMediumFeeTax__c, //中型バイク置場料金(税込)
                                                 BikeParkinLargeFeeTax__c,   //大型バイク���������������場料金(税込)
                                                 //火災保険リスト用
                                                 FireInsurancePlan__r.Account__r.Name,      //取引先名
                                                 FireInsurancePlan__r.ItemName__c,          //商品名
                                                 FireInsurancePlan__r.FireInsuranceMonth__c,//火災保険料(月額)
                                                 FireInsurancePlan__r.FireInsuranceYear__c, //火災保険料(年額)
                                                 //保証タイトル(リスト用)
                                                 Guaranteeid__c,
                                                 //管理会社指定商品用
                                                 FormerSupplier__c,
                                                 //更新時口コミ売上修正の初期表示にする用
                                                 BrokerageFeeTax__c,        //仲介手数料（税込）
                                                 ADFeeTax__c,//広告料（税込）
                                                 AllRentFee__c//総賃料

                                        FROM Property__c 
                                        WHERE id = :this.propertyId ];
        
        //レコード情報が取得できなければビジネスロジックException発行
        if( targetPropertyList.isEmpty() ){
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
            throw ex;
        }

        targetProperty = targetPropertyList[0];
        //火災保険会社レコードに代入
        fireInsuranceRecord = targetProperty.FireInsurancePlan__r;
        checkFireInsurance = true;//火災保険利用有無
    

        return targetPropertyList[0];
    }

    //target申込情報取得
    private Application__c selectApplicationInfo(Id applicationId){
        List<Application__c> targetApplicationList = [SELECT id,
                                                 Account__c,
                                                 Property__c,
                                                      
                                                 Name,                  //申込番号
                                                 Property__r.Building__r.Name, //建物名
                                                 Property__r.Name,      //部屋番号
                                                 Address__c,            //住所
                                                 //基本情報
                                                 Rent__c,               //賃料
                                                 WortFee__c,            //水道料金
                                                 SecurityDeposit__c,    //敷金
                                                 RenewalFeeYen__c,      //更新料(円)
                                                 ManagementFee__c,      //共益費
                                                 CATV__c,               //CATV
                                                 Deposit__c,            //保証料金
                                                 TownshipAdmissionFee__c,//入町費(税込)
                                                 TownshipFee__c,        //町会費
                                                 GarbageDisposalFee__c, //ゴミ処理費
                                                 KeyMoney__c,           //礼金
                                                 KeyExchangeFee__c,     //鍵交換費
                                                 BicycleParkingFee__c,  //駐輪場代
                                                 ActualFee__c,          //償却
                                                 CancellationActualFeeUnit__c,//敷引・償却単位
                                                 CleaningFeeYen__c,      //定額修繕費(円)
                                                 //駐車場情報
                                                 ParkingFee__c,                 //駐車場料金
                                                 ParkingDeposit__c,             //駐車場保証料金
                                                 ParkingCommission__c,   //駐車場手数料
                                                 BikeStorageSmallFirstFee__c,   //バイク置き場代（小型）日割額
                                                 BikeStorageMediumFirstFee__c,  //バイク置き場代（中型）日割額
                                                 BikeStorageLargeFirstFee__c,   //バイク置き場代（大型）日割額
                                                 //火災保険リスト用
                                                 FireInsuranceTitle__r.Account__r.Name,      //取引先名
                                                 FireInsuranceTitle__r.ItemName__c,          //商品名
                                                 FireInsuranceTitle__r.FireInsuranceMonth__c,//火災保険料(月額)
                                                 FireInsuranceTitle__r.FireInsuranceYear__c, //火災保険料(年額)
                                                 IsFireInsurancePlanUse__c,                  //火災保険利用有無
                                                //契約者情報
                                                 ApplicationType__c,        //申込種別
                                                 ApplicationDate__c,        //申込日
                                                 TenantDesiredDate__c,      //入居希望日
                                                 LastName__c,               //姓
                                                 FirstName__c,              //名
                                                 LastNameKana__c,           //姓（カナ）
                                                 FirstNameKana__c,          //名（カナ）
                                                 Birthdate__c,              //生年月日
                                                 Age__c,                    //年齢
                                                 Current__c,                //郵便番号
                                                 CurrentState__c,           //都道府県
                                                 CurrentCity__c,            //現住所１（市区町村）
                                                 CurrentStreet__c,          //現住所２（番地）
                                                 CurrentPhone__c,           //電話番号
                                                 CurrentMobilePhone__c,     //携帯番号
                                                 CompanyName__c,            //会社名
                                                 CompanyNameKana__c,        //会社名（カナ）
                                                 CompanyIndustries__c,      //会社 業種
                                                 CompanyPostalCode__c,      //会社 郵便番号
                                                 CompanyState__c,           //会社 都道府県
                                                 CompanyCity__c,            //会社 住所１
                                                 CompanyStreet__c,          //会社 住所２
                                                 CompanyPhone__c,           //会社 電話番号
                                                 CompanyFax__c,             //会社 FAX
                                                 CompanyEstablishmentYear__c,//設立（年）
                                                 CompanyEstablishmentMonth__c,//設立（月）
                                                 CompanyCapital__c,         //資本金
                                                 CorporationRepresentative__c,//担当者（法人用）
                                                 CorporationRepresentativePhone__c,//担当者（法人用）電話番号
                                                 CorporationDepartment__c,  //所属部署
                                                 CorporationPost__c,        //役職
                                                 IsTenantPersonInclude__c,  //申込者本人含む
                                                 TenantCount__c,            //入居人数（本人含め）
                                                 IsSpouse__c,               //配偶者有無
                                                 ChildrenCount__c,          //子供
                                                 ResidenceTermYear__c,      //住所期間（年）
                                                 ResidenceTermMonth__c,     //住所期間（月）
                                                 ResidenceType__c,          //住居種別
                                                 //勤務先情報
                                                 Affiliation__c,            //勤務先
                                                 AffiliationPostalCode__c,  //郵便番号
                                                 AffiliationState__c,       //都道府県
                                                 AffiliationCity__c,        //住所1（市区町村）
                                                 AffiliationStreet__c,      //住所２（番地）
                                                 AffiliationPhone__c,       //電話番号
                                                 Industries__c,             //業種
                                                 JobType__c,                //職種 
                                                 Department__c,             //部署
                                                 Post__c,                   //役職
                                                 AnnualIncome__c,           //年収
                                                 ContinuedServiceYearsYear__c,  //勤続年数（年）
                                                 ContinuedServiceYearsMonth__c, //勤続年数（月）
                                                 //学歴情報
                                                 AffiliationSchool__c,      //現在学校名
                                                 PlannedEnrollment__c,      //入学予定校
                                                 InformalOffer__c,          //内定有無
                                                 PassResultDate__c,         //合格発表日
                                                 //車両情報
                                                 CarMaker__c,               //メーカー
                                                 CarType__c,                //車種
                                                 CarColor__c,               //色
                                                 RegistNumber__c,           //ナンバー
                                                 //連帯保証人
                                                 JointGuarantorLastName__c,     //連帯保証人姓
                                                 JointGuarantorFirstName__c,    //連帯保証人名
                                                 JointGuarantorLastNameKana__c, //連帯保証人姓（カナ）
                                                 JointGuarantorFirstNameKana__c,//連帯保証人名（カナ）
                                                 JointGuarantorPostalCode__c,   //郵便番号
                                                 JointGuarantorState__c,        //都道府県
                                                 JointGuarantorCity__c,         //住所1（市町村）
                                                 JointGuarantorStreet__c,       //住所２（番地）
                                                 JointGuarantorBirthdate__c,    //生年月日
                                                 JointGuarantorAge__c,          //年齢
                                                 JointGuarantorPhone__c,        //電話番号
                                                 JointGuarantorMobilePhone__c,  //携帯番号
                                                 ApplicantRelationship__c,      //お申込者との関係
                                                 JointGuarantorIsSpouse__c,     //配偶者有無
                                                 JointGuarantorResidenceType__c,//住居種別
                                                 //連帯保証人勤務先
                                                 JointGuarantorAffiliation__c,          //勤務先
                                                 JointGuarantorIndustries__c,           //業種
                                                 JointGuarantorAffiliationPostalCode__c,//郵便番号
                                                 JointGuarantorAffiliationState__c,     //都道府県
                                                 JointGuarantorAffiliationCity__c,      //住所1
                                                 JointGuarantorAffiliationStreet__c,    //住所2
                                                 JointGuarantorAffiliationPhone__c,     //電話番号
                                                 JointGuarantorDepartment__c,           //所属
                                                 JointGuarantorJobType__c,              //職種
                                                 JointGuarantorPost__c,                 //役職
                                                 JointGuarantorAnnualIncome__c,         //年収
                                                 JointGuarantorContinuedServiceYearsYear__c,//勤務年数（年）
                                                 JointGuarantorContinuedServiceYearsMonth__c,//勤務年数（月）
                                                      
                                                 //添付ファイル（電子サイン）
                                                 (SELECT Id FROM attachments WHERE Name = '電子サイン' LIMIT 1),
                                                      
                                                 SystemModstamp 
                                        FROM Application__c 
                                        WHERE id = :this.applicationId ];
        //レコード情報が取得できなければビジネスロジックException発行
        if( targetApplicationList.isEmpty() ){
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
            throw ex;
        }
        
        targetApplication = targetApplicationList[0];

        //火災保険会社レコードに代入
        fireInsuranceRecord = targetApplication.FireInsuranceTitle__r;
        checkFireInsurance = targetApplication.IsFireInsurancePlanUse__c;
        //view2用のパラメータ設定
        view2Param = targetApplication.id;
        return targetApplicationList[0];    
    }

	// ▼ 2022.03.01 No0739 同じ申込を2件以上登録できないように対応から申込があるかを確認する
	/**
	* 申込があるかどうか確認
	* @param Id accountId 検索Id
	* @param Id correspondsId 検索Id
	* @return Id 申込ID
	*/
	private Id selectApplicationExistence(Id accountId,Id correspondsId){
		List<Application__c> targetApplicationList = [SELECT id
			FROM Application__c 
			WHERE Account__c = :accountId 
			AND   Corresponds__c = :correspondsId
			ORDER BY SystemModstamp DESC];
		//レコード情報が取得できなければビジネスロジックException発行
		if( targetApplicationList.isEmpty() ){
			return null;
		}
		return targetApplicationList[0].id;
	}
	// ▲ 2022.03.01 No0739 同じ申込を2件以上登録できないように対応から申込があるかを確認する

    //2020/6/23追加：対応保存用メソッド
    private void saveCorrespond(Application__c upsertRecord){
        Correspond__c updateCorr = new Correspond__c(
            Id = correspondId,
            EventDateTime__c = CommonUtil.getNow(), //イベント時刻
            IsSupportedListShow__c = false,         //対応確認フラグ（ランドレビュー：追加）
            Application__c = upsertRecord.Id        //申込（ランドレビュー：追加）
        );
    //申込新規作成時、来店済、来店後検討、来店後追客中の場合ステータスを"未収入金"に変更
        if (isNew || targetCorrespond.Status__c==CommonConst.CORRESPOND_STATUS_VISITED 
            || targetCorrespond.Status__c==CommonConst.CORRESPOND_STATUS_CONSIDERVISITING
            || targetCorrespond.Status__c==CommonConst.CORRESPOND_STATUS_VISITED_PURSUIT){
                updateCorr.Status__c=CommonConst.CORRESPOND_STATUS_UNEARNED;
            }
        SecureDML.secureUpdate(updateCorr);
    }


    //2020/6/23追加：対応明細保存用メソッド
    private void saveCorrespondDetail(Application__c upsertRecord){
        CorrespondDetail__c insertTask = new CorrespondDetail__c(
            CorrespondType__c = CommonConst.TASK_CORRESPONDTYPE_APPLICANT,          //対応種別：申込登録
            SupportedDateTime__c = commonUtil.getNow(),                             //対応日時:現在日時
            SupportedContent__c = '物件名：'+ screenTargetRecord.buildingName + ' ' + screenTargetRecord.propertyName
                                    + '\n申込日：' + screenTargetRecord.applicationDate,//対応内容：物件名 ○○○（改行）申込日：画面の申込日
            Shop__c = targetShop.id,                                                //店舗（ログインユーザのidに紐づく店舗）
            Staff__c = UserInfo.getUserId(),                                        //担当者：ログインユーザ
            Corresponds__c = correspondId                                           //対応Id：パラメータの対応Id
        );
        //申込新規作成時
        if(isNew){
            insertTask.SupportedTitle__c = '申込登録';           //対応表題：申込登録

        //既存申込更新時
        }else{
            insertTask.SupportedTitle__c = '申込更新';               //対応表題：申込更新
        }
        SecureDML.secureInsert(insertTask);
    }

    /******ここまでprivateメソッド******************************************************************************/
    
    //↓↓↓↓↓以下内部クラス↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓

    //■保証会社の内部クラス
    public class ScreenGuaranteeItem{
        public String guaranteeidCompanyName{get; set;}//保証会社名
        public String guaranteeidItemName{get; set;}   //保証プラン名
        public String planDetail{get; set;}            //プラン詳細
        public String firstFeeDepositRate{get; set;}   //初回保証料(割合)
        public Decimal firstFeeDepositYen{get; set;}   //初回保証料(金額)
        public String depositRate{get; set;}           //保証料(割合)
        public Decimal depositYen{get; set;}           //保証料(金額)
        public String isRentFeeType{get; set;}         //賃料区分（賃料or総賃料）
        public String dsepositRemarks{get; set;}       //備考
        public Boolean isPlanUse{get; set;}            //利用有無チェックボックス
        public Id id{get; set;}                        //id

        //商品明細から取得（isNewがTrue）
        public ScreenGuaranteeItem( ItemDetail__c targetItemDetail ){ 
            this.guaranteeidCompanyName = targetItemDetail.Item__r.Account__r.Name;             //保証会社名
            this.guaranteeidItemName = targetItemDetail.Item__r.ItemName__c;                    //保証プラン名
            this.planDetail = targetItemDetail.PlanDetail__c;                                   //プラン詳細
            this.firstFeeDepositRate = CommonUtil.decimalToString(targetItemDetail.FirstFeeDepositRate__c);//初回保証料(割合)
            this.firstFeeDepositYen = targetItemDetail.FirstFeeDepositYen__c;                   //初回保証料(金額)
            this.depositRate = CommonUtil.decimalToString(targetItemDetail.DepositRate__c);     //保証料(割合)       
            this.depositYen = targetItemDetail.DepositYen__c;                                   //保証料(金額)
            //賃料区分
            if(targetItemDetail.IsRentFeeType__c){
                //Trueの時は総賃料
                isRentFeeType = '総賃料';
            }else{
                //falseなら賃料
                isRentFeeType = '賃料';
            }
            this.dsepositRemarks = targetItemDetail.DepositRemarks__c;                          //備考
            this.isPlanUse = false;                                                             //利用有無チェックボックス
            //割合で値があるときのみ％を付ける
            if(!String.isBlank(this.firstFeeDepositRate)){
                this.firstFeeDepositRate=this.firstFeeDepositRate+'%';
            }  
            if(!String.isBlank(this.depositRate)){
                this.depositRate=this.depositRate+'%';
            }
        }     

        //申込商品明細から取得（isNewがFalse）
        public ScreenGuaranteeItem( ApplicantItemDetail__c targetApplicantItemDetail ){ 
            this.id = targetApplicantItemDetail.ID;      //id
            this.guaranteeidCompanyName = targetApplicantItemDetail.GuaranteeidCompanyName__c;      //保証会社名
            this.guaranteeidItemName = targetApplicantItemDetail.GuaranteeidItemName__c;            //保証プラン名
            this.planDetail = targetApplicantItemDetail.PlanDetail__c;                              //プラン詳細
            this.firstFeeDepositRate = CommonUtil.decimalToString(targetApplicantItemDetail.FirstFeeDepositRate__c);//初回保証料(割合)
            this.firstFeeDepositYen = targetApplicantItemDetail.FirstFeeDepositYen__c;//初回保証料(金額)
            this.depositRate = CommonUtil.decimalToString(targetApplicantItemDetail.DepositRate__c);//保証料(割合)
            this.depositYen = targetApplicantItemDetail.DepositYen__c;  //保証料(金額)
            //賃料区分
            if(targetApplicantItemDetail.IsRentFeeType__c){
                //Trueの時は総賃料
                isRentFeeType = '総賃料';
            }else{
                //falseなら賃料
                isRentFeeType = '賃料';
            }
            this.dsepositRemarks = targetApplicantItemDetail.DepositRemarks__c;                     //備考
            this.isPlanUse = targetApplicantItemDetail.IsPlanUse__c ;                               //利用有無チェックボックス
            if(!String.isBlank(this.firstFeeDepositRate)){
                this.firstFeeDepositRate=this.firstFeeDepositRate+'%';
              }  
            if(!String.isBlank(this.depositRate)){
                this.depositRate=this.depositRate+'%';
            }
        }

    }

    //■管理会社指定商品の内部クラス
    public class ScreenQuoteManageCompayItem{
        public String itemName{get; set;}       //商品名
        public Decimal amountTax{get; set;}      //金額（税込）
        public String paymentType{get; set;}    //支払い区分
        public String taxType{get; set;}        //税区分
        public Boolean isPlanUse{get; set;}     //利用有無（チェックボックス）
        public id id{get; set;}                 //id
        //管理会社指定商品（isNewがTreu）
        public ScreenQuoteManageCompayItem(ManagementCompanyItem__c targetCompanyItem){
            this.itemName = targetCompanyItem.ItemName__c;          //商品名
            this.amountTax = targetCompanyItem.AmountTax__c;        //金額（税込）
            this.paymentType = targetCompanyItem.PaymentType__c;    //支払い区分
            this.taxType = targetCompanyItem.TaxType__c;            //税区分
            //▼問合せNo0569で変更
            this.isPlanUse = false;                                 //利用無デフォルト値
            if (targetCompanyItem.propertyManageCompayItemItem__r.size() > 0) {
                if(targetCompanyItem.propertyManageCompayItemItem__r[0].Item__c == targetCompanyItem.Id){
                    this.isPlanUse = true;                          //利用有（チェックボックス）
                }
            }
            //▲問合せNo0569で変更
        }
        //申込指定商品（isNewがfalse）
        public ScreenQuoteManageCompayItem(ApplicantQuoteManageCompayItem__c targetApplicantItem){
            this.id = targetApplicantItem.id;                //id
            this.itemName = targetApplicantItem.ItemName__c;                //商品名
            this.amountTax = targetApplicantItem.AmountTax__c;//金額（税込）
            this.paymentType = targetApplicantItem.PaymentType__c;                        //支払い区分
            this.taxType = targetApplicantItem.TaxType__c;                                //税区分
            this.isPlanUse = targetApplicantItem.IsPlanUse__c;                            //利用有無（チェックボックス）
        }
    }

    //■表示用の内部クラス
    public class ScreenItem{    
        //以下、画面用の項目
        //建物情報
        public String propertyName{get; set;}           //物件名
        public String buildingName{get; set;}           //建物名
        public String address{get; set;}                //建物住所
        //基本情報
        public String rentFee{get; set;}                //賃料
        public String wortFeeTax{get; set;}             //水道料金（税込）
        public String securityDepositYen{get; set;}   //敷金（円）
        public String renewalFeeTax{get; set;}          //更新料（税込）
        public String managementFeeTax{get; set;}       //管理費（税込）
        public String catvFeeTax{get; set;}             //CATV（税込）
        public String depositYen{get; set;}             //保証料金(円)
        public String townshipInitialFeeTax{get; set;}  //入町費(税込)
        public String townshipFeeTax{get; set;}         //町会費（税込）
        public String garbageDisposalFeeTax{get; set;}  //ゴミ処理費（税込）
        public String keyMoneyYen{get; set;}            //礼金(円)
        public String keyExchangeFeeTax{get; set;}      //鍵交換費（税込）
        public String bicycleParkingFeeTax{get; set;}   //駐輪場代（税込）
        public String cancellationActualFeeYen{get; set;}//敷引・償却(円)
        public String cancellationActualFeeUnit{get; set;}//敷引・償却単位
        public String cleaningFeeTax{get; set;}         //定額修繕費（税込）
        //駐車場
        public String parkingFeeTax{get; set;}          //駐車場料金（税込）
        public String parkingDepositTax{get; set;}      //駐車場保証料金（税込）
        public String parkingCompoundingFeeYenTax{get; set;}//駐車場手数料（税込）
        public String bikeParkingSmallFeeTax{get; set;} //小型バイク置場料金（税込）
        public String bikeParkingMediumFeeTax{get; set;}//中型バイク置場料金（税込）
        public String bikeParkinLargeFeeTax{get; set;}  //定大型バイク置場料金（税込）
        //契約者情報
        public String applicationType{get; set;}         //申込種別
        public Date applicationDate{get; set;}           //申込日
        public Date tenantDesiredDate{get; set;}         //入居希望日
        public String lastName{get; set;}                //姓
        public String firstName{get; set;}               //名
        public String lastNameKana{get; set;}            //姓（カナ）
        public String firstNameKana{get; set;}           //名（カナ）
        public Date birthdate{get; set;}                 //生年月日
        public Decimal age{get; set;}                     //年齢
        public String currentpostalCode{get; set;}                 //郵便番号
        public String currentState{get; set;}            //都道府県
        public String currentCity{get; set;}             //現住所１（市区町村）
        public String currentStreet{get; set;}           //現住所２（番地）
        public String currentPhone{get; set;}            //電話番号
        public String currentMobilePhone{get; set;}      //携帯番号
        public String companyName{get; set;}             //会社名
        public String companyNameKana{get; set;}         //会社名（カナ）
        public String companyIndustries{get; set;}       //会社 業種
        public String companyPostalCode{get; set;}       //会社 郵便番号
        public String companyState{get; set;}            //会社 都道府県
        public String companyCity{get; set;}             //会社 住所１
        public String companyStreet{get; set;}           //会社 住所２
        public String companyPhone{get; set;}            //会社 電話番号
        public String companyFax{get; set;}              //会社 FAX
        public String companyEstablishmentYear{get; set;}//設立（年）
        public String companyEstablishmentMonth{get; set;}//設立（月）
        public String companyCapital{get; set;}          //資本金
        public String corporationRepresentative{get; set;}       //担当者（法人用）
        public String corporationRepresentativePhone{get; set;}  //担当者（法人用）電話番号
        public String corporationDepartment{get; set;}           //所属部署
        public String corporationPost{get; set;}                 //役職
        public Boolean isTenantPersonInclude{get; set;}          //申込者本人含む
        public String tenantCount{get; set;}                     //入居人数（本人含め）
        public String isSpouse{get; set;}                        //配偶者有無
        public String childrenCount{get; set;}                   //子供
        public String residenceTermYear{get; set;}               //住所期間（年）
        public String residenceTermMonth{get; set;}              //住所期間（月）
        public String residenceType{get; set;}                   //住居種別
        //勤務先情報
        public String affiliation{get; set;}                     //勤務先
        public String affiliationPostalCode{get; set;}           //郵便番号
        public String affiliationState{get; set;}                //都道府県
        public String affiliationCity{get; set;}                 //住所1（市区町村）
        public String affiliationStreet{get; set;}               //住所２（番地）
        public String affiliationPhone{get; set;}                //電話番号
        public String industries{get; set;}                      //業種
        public String jobType{get; set;}                         //職種
        public String department{get; set;}                      //部署
        public String post{get; set;}                            //役職
        public String annualIncome{get; set;}                    //年収
        public String continuedServiceYearsYear{get; set;}       //勤続年数（年）
        public String continuedServiceYearsMonth{get; set;}      //勤続年数（月）
        //学歴情報
        public String affiliationSchool{get; set;}               //現在学校名
        public String plannedEnrollment{get; set;}               //入学予定校
        public String informalOffer{get; set;}                   //内定有無
        public date passResultDate{get; set;}                    //合格発表日
        //車両情報
        public String carMaker{get; set;}                     //メーカー
        public String carType{get; set;}                      //車種
        public String carColor{get; set;}                     //色
        public String registNumber{get; set;}                 //登録ナンバー
        //連帯保証人
        public String jointGuarantorLastName{get; set;}     //連帯保証人姓
        public String jointGuarantorFirstName{get; set;}        //連帯保証人名
        public String jointGuarantorLastNameKana{get; set;}     //連帯保証人姓（カナ）
        public String jointGuarantorFirstNameKana{get; set;}    //連帯保証人名（カナ）
        public String jointGuarantorPostalCode{get; set;}       //郵便番号
        public String jointGuarantorState{get; set;}            //都道府県
        public String jointGuarantorCity{get; set;}             //住所1（市町村）
        public String jointGuarantorStreet{get; set;}           //住所２（番地）
        public Date jointGuarantorBirthdate{get; set;}          //生年月日
        public Decimal jointGuarantorAge{get; set;}              //年齢
        public String jointGuarantorPhone{get; set;}            //電話番号
        public String jointGuarantorMobilePhone{get; set;}      //携帯番号
        public String applicantRelationship{get; set;}          //お申込者との関係
        public String jointGuarantorIsSpouse{get; set;}         //配偶者有無
        public String jointGuarantorResidenceType{get; set;}    //住居種別
        //連帯保証人勤務先
        public String jointGuarantorAffiliation{get; set;}           //勤務先
        public String jointGuarantorIndustries{get; set;}            //業種
        public String jointGuarantorAffiliationPostalCode{get; set;} //郵便番号
        public String jointGuarantorAffiliationState{get; set;}      //都道府県
        public String jointGuarantorAffiliationCity{get; set;}       //住所1
        public String jointGuarantorAffiliationStreet{get; set;}     //住所2
        public String jointGuarantorAffiliationPhone{get; set;}      //電話番号
        public String jointGuarantorDepartment{get; set;}            //所属
        public String jointGuarantorJobType{get; set;}               //職種
        public String jointGuarantorPost{get; set;}                  //役職
        public String jointGuarantorAnnualIncome{get; set;}          //年収
        public String jointGuarantorContinuedServiceYearsYear{get; set;}    //勤務年数（年）
        public String jointGuarantorContinuedServiceYearsMonth{get; set;}   //勤務年数（月）
        //電子サイン
        public String attachmentId{get; set;} //電子サイン用 添付ファイルId

        //○○コンストラクタ○○
        //取引先・物件（isNewがTrue）
        public ScreenItem(Account targetAccount ,Property__c targetProperty ){
            //建物情報
            this.propertyName    = targetProperty.Name;                                                    //物件名                  
            this.buildingName    = targetProperty.Building__r.Name;                                        //建物名 
            this.address         = targetProperty.Building__r.Address__c;                                  //建物住所
            //基本情報
            this.rentFee         = commonUtil.decimalToString(targetProperty.RentFee__c);                  //賃料
            this.wortFeeTax         = commonUtil.decimalToString(targetProperty.WortFeeTax__c);            //水道料金(税込)
            this.securityDepositYen= commonUtil.decimalToString(targetProperty.SecurityDepositYen__c); //敷金（円）
            this.renewalFeeTax  = commonUtil.decimalToString(targetProperty.RenewalFee__c);                //更新料(税込)
            this.managementFeeTax   = commonUtil.decimalToString(targetProperty.ManagementFeeTax__c);      //管理費(税込)
            this.catvFeeTax         = commonUtil.decimalToString(targetProperty.CATVFeeTax__c);            //CATV(税込)
            this.depositYen      = commonUtil.decimalToString(targetProperty.DepositYen__c);               //保証料金(円)
            this.townshipInitialFeeTax= commonUtil.decimalToString(targetProperty.TownshipInitialFeeTax__c);//入町費(税込)
            this.townshipFeeTax     = commonUtil.decimalToString(targetProperty.TownshipFeeTax__c);         //町会費(税込)
            this.garbageDisposalFeeTax= commonUtil.decimalToString(targetProperty.GarbageDisposalFeeTax__c);//ゴミ処理費(税込)
            this.keyMoneyYen     = commonUtil.decimalToString(targetProperty.KeyMoneyYen__c);              //礼金(円)
            this.keyExchangeFeeTax  = commonUtil.decimalToString(targetProperty.KeyExchangeFeeTax__c);     //鍵交換費(税込)
            this.bicycleParkingFeeTax= commonUtil.decimalToString(targetProperty.BicycleParkingFeeTax__c); //駐輪場代(税込)
            this.cancellationActualFeeYen= commonUtil.decimalToString(targetProperty.CancellationActualFeeYen__c);//敷引・償却(円)
            this.cancellationActualFeeUnit = targetProperty.CancellationActualFeeUnit__c;                  //敷引・償却単位
            this.cleaningFeeTax  = commonUtil.decimalToString(targetProperty.CleaningFeeTax__c);           //定額修繕費(税込)
            //駐車場
            this.parkingFeeTax  = commonUtil.decimalToString(targetProperty.ParkingFeeTax__c);                          //駐車場料金(税込)
            this.parkingDepositTax  = commonUtil.decimalToString(targetProperty.ParkingDepositTax__c);                  //駐車場保証料金(税込)
            this.parkingCompoundingFeeYenTax  = commonUtil.decimalToString(targetProperty.ParkingCompoundingFeeTax__c); //駐車場手数料(税込)
            this.bikeParkingSmallFeeTax  = commonUtil.decimalToString(targetProperty.BikeParkingSmallFeeTax__c);        //小型バイク置場料金(税込)
            this.bikeParkingMediumFeeTax  = commonUtil.decimalToString(targetProperty.BikeParkingMediumFeeTax__c);      //中型バイク置場料金(税込)
            this.bikeParkinLargeFeeTax  = commonUtil.decimalToString(targetProperty.BikeParkinLargeFeeTax__c);          //定大型バイク置場料金(税込)
            //契約者情報
                //申込種別
            if (targetAccount.ContractType__c == '法人契約'){
                this.applicationType = '法人';
            }else if(targetAccount.JobType__c == '学生'){
                this.applicationType = '学生';
            }else{
                this.applicationType = '個人';
            }
            this.applicationDate = commonUtil.getToday();    //申込日
            this.tenantDesiredDate = null;                   //入居希望日
            
            this.lastName = targetAccount.LastName__c;//姓・名
            this.firstName =targetAccount.FirstName__c;//姓・名
            this.lastNameKana = targetAccount.LastNameKana__c;//姓・名(カナ)
            this.firstNameKana = targetAccount.FirstNameKana__c;//姓・名(カナ)
            this.birthdate = targetAccount.Birthdate__c;                    //生年月日
            this.age = targetAccount.Age__c;    //年齢
            this.currentpostalCode = targetAccount.PostalCode__c;           //郵便番号
            this.currentState = targetAccount.State__c;                     //都道府県
            this.currentCity = targetAccount.City__c;                       //現住所１（市区町村）
            this.currentStreet = targetAccount.Street__c;                   //現住所２（番地）  
            this.currentPhone = targetAccount.Phone;                        //電話番号
            this.currentMobilePhone = null;                                 //携帯番号
            this.companyName = targetAccount.CompanyName__c;                //会社名
            this.companyNameKana = targetAccount.CompanyNameKana__c;        //会社名（カナ）     
            this.companyIndustries = targetAccount.CompanyIndustries__c;    //会社 業種
            this.companyPostalCode = targetAccount.CompanyPostalCode__c;    //会社 郵便番号
            this.companyState = targetAccount.CompanyState__c;              //会社 都道府県
            this.companyCity = targetAccount.CompanyCity__c;                //会社 住所１  
            this.companyStreet = targetAccount.CompanyStreet__c;            //会社 住所２
            this.companyPhone = '';                                          //会社 電話番号
            this.companyFax = '';                                            //会社 FAX
            this.companyEstablishmentYear = '';                              //設立（年）            
            this.companyEstablishmentMonth = '';                             //設立（月）      
            this.companyCapital = '';                                        //資本金
            this.corporationRepresentative = targetAccount.CorporationRepresentative__c;   //担当者（法人用）
            this.corporationRepresentativePhone = targetAccount.CorporationRepresentative__c;//担当者（法人用）電話番号          
            this.corporationDepartment = targetAccount.Department__c;                      //所属部署
            this.corporationPost = targetAccount.Post__c;                                  //役職
            this.isTenantPersonInclude = false;                              //申込者本人含む
            this.tenantCount = '0';                                          //入居人数（本人含め）
            this.isSpouse = '無';                                            //配偶者有無人
            //勤務先情報
            this.affiliation  =targetAccount.Affiliation__c;                    //勤務先
            this.affiliationPostalCode =targetAccount.AffiliationPostalCode__c; //郵便番号
            this.affiliationState =targetAccount.AffiliationState__c;           //都道府県
            this.affiliationCity =targetAccount.AffiliationCity__c;             //住所1（市区町村）
            this.affiliationStreet =targetAccount.AffiliationStreet__c;         //住所２（番地）
            this.industries =targetAccount.AccountIndustry__c;                  //業種
            this.jobType =targetAccount.JobType__c;                             //職種
            this.affiliationPhone =targetAccount.AffiliationPhone__c;           //電話番号
            //学歴情報
            this.affiliationSchool  =targetAccount.Affiliation__c;           //現在学校名
            this.InformalOffer = '無';                                       //内定有無
            //連帯保証人
            this.jointGuarantorIsSpouse = '無';                              //連帯保証人本配偶者有無人
            //電子サイン
            this.attachmentId = '';                                          //添付ファイル
        }


        //申込（isNewがFalse）
        public ScreenItem(Application__c targetApplication){
            //建物情報
            this.propertyName    = targetApplication.Property__r.Name;                                     //物件名                  
            this.buildingName    = targetApplication.Property__r.Building__r.Name;                         //建物名 
            this.address         = targetApplication.Address__c;                                           //建物住所
            //基本情報
            this.rentFee         = commonUtil.decimalToString(targetApplication.Rent__c);                  //賃料
            this.wortFeeTax         = commonUtil.decimalToString(targetApplication.WortFee__c);            //水道料金
            this.securityDepositYen= commonUtil.decimalToString(targetApplication.SecurityDeposit__c);     //敷金
            this.renewalFeeTax  = commonUtil.decimalToString(targetApplication.RenewalFeeYen__c);          //更新料(円)
            this.managementFeeTax   = commonUtil.decimalToString(targetApplication.ManagementFee__c);      //共益費
            this.catvFeeTax         = commonUtil.decimalToString(targetApplication.CATV__c);               //CATV
            this.depositYen      = commonUtil.decimalToString(targetApplication.Deposit__c);               //保証料金
            this.townshipInitialFeeTax= commonUtil.decimalToString(targetApplication.TownshipAdmissionFee__c);//入町費(税込)
            this.townshipFeeTax     = commonUtil.decimalToString(targetApplication.TownshipFee__c);        //町会費
            this.garbageDisposalFeeTax= commonUtil.decimalToString(targetApplication.GarbageDisposalFee__c);//ゴミ処理費
            this.keyMoneyYen     = commonUtil.decimalToString(targetApplication.KeyMoney__c);              //礼金
            this.keyExchangeFeeTax  = commonUtil.decimalToString(targetApplication.KeyExchangeFee__c);     //鍵交換費
            this.bicycleParkingFeeTax= commonUtil.decimalToString(targetApplication.BicycleParkingFee__c); //駐輪場代
            this.cancellationActualFeeYen = commonUtil.decimalToString(targetApplication.ActualFee__c);    //償却
            this.cancellationActualFeeUnit = targetApplication.CancellationActualFeeUnit__c;               //敷引・償却単位
            this.cleaningFeeTax  = commonUtil.decimalToString(targetApplication.CleaningFeeYen__c);        //定額修繕費(円) 
            //駐車場
            this.parkingFeeTax  = commonUtil.decimalToString(targetApplication.ParkingFee__c);                              //駐車場料金
            this.parkingDepositTax  = commonUtil.decimalToString(targetApplication.ParkingDeposit__c);                      //駐車場保証料金
            this.parkingCompoundingFeeYenTax  = commonUtil.decimalToString(targetApplication.ParkingCommission__c);  //駐車場手数料
            this.bikeParkingSmallFeeTax  = commonUtil.decimalToString(targetApplication.BikeStorageSmallFirstFee__c);       //バイク置き場代（小型）日割額
            this.bikeParkingMediumFeeTax  = commonUtil.decimalToString(targetApplication.BikeStorageMediumFirstFee__c);     //バイク置き場代（中型）日割額
            this.bikeParkinLargeFeeTax  = commonUtil.decimalToString(targetApplication.BikeStorageLargeFirstFee__c);       //バイク置き場代（大型）日割額
            //契約者情報
            this.applicationType = targetApplication.ApplicationType__c;        //申込種別    
            this.applicationDate = targetApplication.ApplicationDate__c;        //申込日
            this.tenantDesiredDate = targetApplication.TenantDesiredDate__c;    //入居希望日
            this.lastName = targetApplication.LastName__c;                      //姓
            this.firstName = targetApplication.FirstName__c;                    //名
            this.lastNameKana = targetApplication.LastNameKana__c;              //姓（カナ）
            this.firstNameKana = targetApplication.FirstNameKana__c;            //名（カナ）
            this.birthdate = targetApplication.Birthdate__c;                    //生年月日
            this.age = targetApplication.Age__c;    //年齢
            this.currentpostalCode = targetApplication.Current__c;              //郵便番号
            this.currentState = targetApplication.CurrentState__c;              //都道府県
            this.currentCity = targetApplication.CurrentCity__c;                //現住所１（市区町村）
            this.currentStreet = targetApplication.CurrentStreet__c;            //現住所２（番地）  
            this.currentPhone = targetApplication.CurrentPhone__c;              //電話番号
            this.currentMobilePhone = targetApplication.CurrentMobilePhone__c;  //携帯番号
            this.companyName = targetApplication.CompanyName__c;                //会社名
            this.companyNameKana = targetApplication.CompanyNameKana__c;        //会社名（カナ）     
            this.companyIndustries = targetApplication.CompanyIndustries__c;    //会社 業種
            this.companyPostalCode = targetApplication.CompanyPostalCode__c;    //会社 郵便番号
            this.companyState = targetApplication.CompanyState__c;              //会社 都道府県
            this.companyCity = targetApplication.CompanyCity__c;                //会社 住所１  
            this.companyStreet = targetApplication.CompanyStreet__c;            //会社 住所２
            this.companyPhone = targetApplication.CompanyPhone__c;              //会社 電話番号
            this.companyFax = targetApplication.CompanyFax__c;                  //会社 FAX
            this.companyEstablishmentYear = targetApplication.CompanyEstablishmentYear__c;            //設立（年）            
            this.companyEstablishmentMonth = targetApplication.CompanyEstablishmentMonth__c;          //設立（月）      
            this.companyCapital = commonUtil.decimalToString(targetApplication.CompanyCapital__c);    //資本金    
            this.corporationRepresentative = targetApplication.CorporationRepresentative__c;          //担当者（法人用）
            this.corporationRepresentativePhone = targetApplication.CorporationRepresentativePhone__c;//担当者（法人用）電話番号          
            this.corporationDepartment = targetApplication.CorporationDepartment__c;                  //所属部署
            this.corporationPost = targetApplication.CorporationPost__c;                              //役職
            this.isTenantPersonInclude = targetApplication.IsTenantPersonInclude__c;                  //申込者本人含む
            //this.tenantCount =commonUtil.decimalToString(targetApplication.TenantCount__c);          //入居人数（本人含め）
             //配偶者有無人
            if(targetApplication.IsSpouse__c == null){
                this.isSpouse = '無';                                           
            }else{
                this.isSpouse = targetApplication.IsSpouse__c;                                            
            }
            this.childrenCount = commonUtil.decimalToString(targetApplication.ChildrenCount__c);           //子供
            this.residenceTermYear = commonUtil.decimalToString(targetApplication.ResidenceTermYear__c);   //住所期間（年）
            this.residenceTermMonth = commonUtil.decimalToString(targetApplication.ResidenceTermMonth__c); //住所期間（月）
            this.residenceType = targetApplication.ResidenceType__c;                                       //住居種別
            //勤務先情報
            this.affiliation = targetApplication.Affiliation__c;                     //勤務先    
            this.affiliationPostalCode = targetApplication.AffiliationPostalCode__c; //郵便番号    
            this.affiliationState = targetApplication.AffiliationState__c;           //都道府県    
            this.affiliationCity = targetApplication.AffiliationCity__c;             //住所1（市区町村）   
            this.affiliationStreet = targetApplication.AffiliationStreet__c;         //住所２（番地）
            this.affiliationPhone = targetApplication.AffiliationPhone__c;           //電話番号
            this.industries = targetApplication.Industries__c;                       //業種    
            this.jobType = targetApplication.JobType__c;                             //職種
            this.department = targetApplication.Department__c;                       //部署
            this.post = targetApplication.Post__c;                                   //役職    
            this.annualIncome =commonUtil.decimalToString(targetApplication.AnnualIncome__c);  //年収    
            this.continuedServiceYearsYear = commonUtil.decimalToString(targetApplication.ContinuedServiceYearsYear__c);   //勤続年数（年）  
            this.continuedServiceYearsMonth = commonUtil.decimalToString(targetApplication.ContinuedServiceYearsMonth__c); //勤続年数（月） 
            //学歴情報
            this.affiliationSchool = targetApplication.AffiliationSchool__c;         //現在学校名
            this.plannedEnrollment = targetApplication.PlannedEnrollment__c;         //入学予定校
            //内定有無
            if (targetApplication.InformalOffer__c == null){
                this.informalOffer = '無';        
            }else{
                this.informalOffer = targetApplication.InformalOffer__c;         
            }
            this.passResultDate = targetApplication.PassResultDate__c;                 //合格発表日
            //車両情報
            this.carMaker = targetApplication.CarMaker__c;                           //メーカー
            this.carType = targetApplication.CarType__c;                             //車種
            this.carColor = targetApplication.CarColor__c;                           //色
            this.registNumber = targetApplication.RegistNumber__c;                   //ナンバー   
            //連帯保証人
            this.jointGuarantorLastName = targetApplication.JointGuarantorLastName__c;      //連帯保証人姓
            this.jointGuarantorFirstName = targetApplication.JointGuarantorFirstName__c;        //連帯保証人名
            this.jointGuarantorLastNameKana = targetApplication.JointGuarantorLastNameKana__c;  //連帯保証人姓（カナ）
            this.jointGuarantorFirstNameKana = targetApplication.JointGuarantorFirstNameKana__c;//連帯保証人名（カナ）
            this.jointGuarantorPostalCode = targetApplication.JointGuarantorPostalCode__c;      //郵便番号
            this.jointGuarantorState = targetApplication.JointGuarantorState__c;                //都道府県
            this.jointGuarantorCity = targetApplication.JointGuarantorCity__c;                  //住所1（市町村）
            this.jointGuarantorStreet = targetApplication.JointGuarantorStreet__c;              //住所２（番地）
            this.jointGuarantorBirthdate = targetApplication.JointGuarantorBirthdate__c;        //生年月日
            this.jointGuarantorAge = targetApplication.JointGuarantorAge__c;//年齢
            this.jointGuarantorPhone = targetApplication.JointGuarantorPhone__c;                //電話番号
            this.jointGuarantorMobilePhone = targetApplication.JointGuarantorMobilePhone__c;    //携帯番号
            this.applicantRelationship = targetApplication.ApplicantRelationship__c;            //お申込者との関係
            //配偶者
            if(targetApplication.JointGuarantorIsSpouse__c == null){
                this.jointGuarantorIsSpouse = '無';                                            
            }else{
                this.jointGuarantorIsSpouse = targetApplication.JointGuarantorIsSpouse__c;                                         
  
            }
            this.jointGuarantorResidenceType = targetApplication.JointGuarantorResidenceType__c;//住居種別
            //連帯保証人勤務先
            this.jointGuarantorAffiliation = targetApplication.JointGuarantorAffiliation__c;                        //勤務先
            this.jointGuarantorIndustries = targetApplication.JointGuarantorIndustries__c;                          //業種
            this.jointGuarantorAffiliationPostalCode = targetApplication.JointGuarantorAffiliationPostalCode__c;    //郵便番号
            this.jointGuarantorAffiliationState = targetApplication.JointGuarantorAffiliationState__c;              //都道府県
            this.jointGuarantorAffiliationCity = targetApplication.JointGuarantorAffiliationCity__c;                //住所
            this.jointGuarantorAffiliationStreet = targetApplication.JointGuarantorAffiliationStreet__c;            //住所
            this.jointGuarantorAffiliationPhone = targetApplication.JointGuarantorAffiliationPhone__c;              //電話番号
            this.jointGuarantorDepartment = targetApplication.JointGuarantorDepartment__c;                          //所属
            this.jointGuarantorJobType = targetApplication.JointGuarantorJobType__c;                                //職種
            this.jointGuarantorPost = targetApplication.JointGuarantorPost__c;                                      //役職
            this.jointGuarantorAnnualIncome = commonUtil.decimalToString(targetApplication.JointGuarantorAnnualIncome__c);                             //年収
            this.jointGuarantorContinuedServiceYearsYear = commonUtil.decimalToString(targetApplication.JointGuarantorContinuedServiceYearsYear__c);   //勤務年数（年）
            this.jointGuarantorContinuedServiceYearsMonth = commonUtil.decimalToString(targetApplication.JointGuarantorContinuedServiceYearsMonth__c); //勤務年数（月）
            
            
            //電子サイン
            if (targetApplication.Attachments.size() > 0) {
                this.attachmentId = targetApplication.Attachments[0].Id; //添付ファイルId (添付ファイルは電子サインしかないはず)
            }

        }
    }
}