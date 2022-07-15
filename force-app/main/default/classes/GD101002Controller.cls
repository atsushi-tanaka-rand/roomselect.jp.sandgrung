/**
 * 業者登録画面コントローラ
 */
public inherited sharing class GD101002Controller {

    /** 共通クラス */    
    public GA102006ParameterClass GA102006Parameter{get; set;}       //郵便番号検索・住所検索モーダル
    public GD101003ParameterClass GD101003Parameter{get; set;}       //保証プランモーダル
    public GD101004ParameterClass GD101004Parameter{get; set;}       //火災保険プランモーダル
    public GD101002Modal1ParameterClass GD101002Modal1Parameter{get; set;}       //管理会社指定商品プランモーダル
    public GD101002Modal2ParameterClass GD101002Modal2Parameter{get; set;}       // 業者プラン一括変更画面
    //パブリック変数
    public Boolean isNew { get; set; }    //新規登録フラグ
    public Boolean isOpenError { get; set; }    //エラーフラグ
    public Boolean hasErrorMessage { get; set; }    //エラーメッセージ保有フラグ
    public Boolean isSaveFinish { get; set; }//2020/5/15：保存ボタン処理終了フラグ
    //画面表示
    public ScreenAccount screenTargetRecord { get; set; } //取引先
    public List<ScreenGuarantee> screenGuaranteeList { get; set; } //保証リスト
    public List<ScreenFireInsurance> screenFireList { get; set; } //火災保険リスト
    public List<ScreenManagementCompanyItem> screenManaComItemList { get; set; } //管理会社指定商品
    public List<Building__c> buildingList { get; set; } //建物（物件経由）
    //削除リスト
    public List<InsuranceGuarantee__c>  deleteGuaranteeList { get; set; } //2020/5/15：保証削除リスト（火災保険と一緒にしていたのを別に変更）
    public List<InsuranceGuarantee__c>  deleteInsuranceList { get; set; } //2020/5/15：火災保険削除リスト（保証と一緒にしていたのを別に変更）
    public List<ManagementCompanyItem__c>  deleteManaComItemList { get; set; } //管理会社指定商品リスト
    //明細行（リンク用）
    public Integer manaComItemIndex { get; set; }    //管理会社指定商品明細行のindex
    
    public ID targetId{ get; set; }    //対象ID（メール画面で渡すため、public）

    //選択リスト
    public List<SelectOption> SelectStateList{ get; set; }              //都道府県
    public List<SelectOption> SelectIppamGyobutsuList{ get; set; }      //一般/業物
    public List<SelectOption> SelectFixedTermSendList{ get; set; }      //定期送信
    public List<SelectOption> SelectIntroductionList{ get; set; }       //紹介
    public List<SelectOption> SelectGuarantorAgencyCompanyTypeList{ get; set; }//保証人代行会社区分
    public List<SelectOption> SelectRenewalFeeShowList{ get; set; }     //更新料表記
    public List<SelectOption> SelectCleaningFeeShowList{ get; set; }    //定額補修費表記
    public List<SelectOption> SelectDembutsuStatusList{ get; set; }     //電物ステータス
    public List<SelectOption> SelectImportTypeList{ get; set; }         //取込区分
    //メッセージ系
    public String MSG_COM_V_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_SAVE);} private set;}    //js用保存確認メッセージ
    public String MSG_COM_I_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);} private set;}    //js用保存完了メッセージ
    public String MSG_COM_V_DELETE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_DELETE);} private set;}    //js用削除確認メッセージ
    public String MSG_COM_I_DELETE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_DELETE);} private set;}    //js用削除完了メッセージ
    public String MSG_COM_I_PROPERTY_SAVE_BULKUPDATE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_PROPERTY_SAVE_BULKUPDATE);} private set;}    //2020/5/15：保証火災項目の更新メッセージ
    public String MSG_COM_I_SAVEBUTTON { get; set; } //2020/5/15：物件の保証保険の項目更新完了メッセージ(判定用)
    public String MSG_SELECTED_ONE_GUARANTEEID_COMPANY { // 保証会社プランはいずれか１つだけ選択してください。
        get{ return CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_REGISTRATION_MULTI_SELECTION, '保証会社プラン'); }
        private set; }
    public String MSG_SELECTED_ONE_FIRE_INSURANCE_COMPANY { // 火災保険会社プランはいずれか１つだけ選択してください。
        get{ return CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_REGISTRATION_MULTI_SELECTION, '火災保険会社プラン'); }
        private set; }
    public String MSG_SELECTED_ONE_MANAGEMENT_COMPANY_ITEM { // 管理会社指定商品はいずれか１つだけ選択してください。
        get{ return CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_REGISTRATION_MULTI_SELECTION, '管理会社指定商品'); }
        private set; }


    //プライベート変数
    private Boolean modal4IsEdit;//管理会社指定商品モーダルが編集で開かれた？フラグ
    private Id correspondId;//対応Id
    private Set<Id> updateGuaranteeItemIdSet;//2020/5/15：保証商品Id更新用セット
    private Set<Id> updateInsuranceItemIdSet;//2020/5/15：火災保険商品Id更新セット
    private Integer selectLimit;//2020/5/15：保証保険の削除時の、紐付けされている物件の取得の最大数
    private Integer selectBuildingLimit;//2020/7/3：業者に紐付けされている建物取得時の最大数  
    private Id RecordTypeIdFireInsurance; // 火災保険のレコードタイプ
    private Id RecordTypeIdGuarantee;     // 保証のレコードタイプ

    // 定数　問合せ278で追加
    private final String REALNETPRO = CommonConst.PROPERTY_IMPORTTYPE_REALNETPRO;       // リアプロ
    private final String DAIWALIVING = CommonConst.PROPERTY_IMPORTTYPE_DAIWALIVING;     // 大和リビング
    private final String MANUAL = CommonConst.PROPERTY_IMPORTTYPE_MANUAL;               // 手動
    private final String SELECTION_LIST_NULL = CommonConst.SELECTION_LIST_NULL;         // --なし--

    //コンストラクタ
    public GD101002Controller(){
        try{
            //初期化
            init();
        
            //対象IDを取得する
            this.targetId = ApexPages.currentPage().getParameters().get('id');

            // 火災、保証のレコードタイプを取得
            this.RecordTypeIdFireInsurance = CommonUtil.getRecordTypeId('InsuranceGuarantee__c', CommonConst.INSURANCE_RECTYPE_GUARANTEE_FIREINSURANCE);  // 火災保険
            this.RecordTypeIdGuarantee = CommonUtil.getRecordTypeId('InsuranceGuarantee__c', CommonConst.INSURANCE_RECTYPE_GUARANTEE_GUARANTEE);          // 保証

            //2020/5/15：業者登録_物件更新最大検索数を取込
            this.selectLimit = Integer.valueOf(SystemConfig__c.getInstance().SupplierRegist_PropertyUpdateMaxCount__c);

            //2020/7/3：業者登録_建物最大件数を取込
            this.selectBuildingLimit = Integer.valueOf(SystemConfig__c.getInstance().SupplierRegist_BuildingMaxCount__c);

            //対象IDが取得できない場合は新規登録フラグにTRUEを設定する
            if(this.targetId == null){
                this.isNew = true;
                this.screenTargetRecord = new ScreenAccount(new Account());
            
            //対象IDが取得できた場合は新規登録フラグにFALSEを設定する
            } else {
                this.isNew = false;
                this.screenTargetRecord = new ScreenAccount(selectRecordInfo(targetId));

          
            }

            //選択リスト設定
            this.SelectStateList                      = CommonUtil.getSelectOptionFromObject('Account', 'State__c');           //都道府県          
            this.SelectIppamGyobutsuList              = CommonUtil.getSelectOptionFromObject('Account', 'IppamGyobutsu__c');   //一般/業物                
            this.SelectFixedTermSendList              = CommonUtil.getSelectOptionFromObject('Account', 'FixedTermSend__c');   //定期送信              
            this.SelectIntroductionList               = CommonUtil.getSelectOptionFromObject('Account', 'Introduction__c');    //紹介            
            this.SelectGuarantorAgencyCompanyTypeList = CommonUtil.getSelectOptionFromObject('Account', 'GuarantorAgencyCompanyType__c');//保証人代行会社区分                
            this.SelectRenewalFeeShowList             = CommonUtil.getSelectOptionFromObject('Account', 'RenewalFeeShow__c');  //更新料表記             
            this.SelectCleaningFeeShowList            = CommonUtil.getSelectOptionFromObject('Account', 'CleaningFeeShow__c'); //定額補修費表記               
            this.SelectDembutsuStatusList             = CommonUtil.getSelectOptionFromObject('Account', 'DembutsuStatus__c');  //電物ステータス             
            this.SelectImportTypeList                 = CommonUtil.getSelectOptionFromObject('Account', 'ImportType__c',true);//取込区分　問合せ278で第三引数をfalse→trueに変更
            
            
        } catch(Exception e) {
            
            //エラーを設定
            isOpenError = true;
            CommonUtil.setErrorMessage(e);
            
        }
    }

    //◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇  publicメソッド ◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇v
    //★郵便番号検索モーダルopen処理
    public void openModal() {
        GA102006Parameter.isDrawing = true;
        GA102006Parameter.noFirst = true;
        GA102006Parameter.isAddressMoster = true;       /** 住所マスタフラグ */
        //郵便番号個人用モーダル     
        GA102006Parameter.postalCode = this.screenTargetRecord.postalCode;//モーダルに渡す用郵便番号
        GA102006Parameter.state = this.screenTargetRecord.state;            //モーダルに渡す用都道府県
        GA102006Parameter.city = this.screenTargetRecord.city;              //モーダルに渡す用市町村
        GA102006Parameter.street =null;           //モーダルに渡す用町域           
    }    

    //★郵便番号検索モーダルclose処理
    public void closeModal() {
        //郵便番号個人用モーダル
        this.screenTargetRecord.postalCode = GA102006Parameter.postalCode;  /** 郵便番号 */   
        this.screenTargetRecord.state = GA102006Parameter.state;    /** 都道府県 */    
        this.screenTargetRecord.city = GA102006Parameter.city + GA102006Parameter.street;    /** 市区町村 */  
        this.screenTargetRecord.street = null;    /** 町域 */  
    }

    /**
     * 保証会社プランの業者プラン一括変更画面の起動
     */
    public void openSupplierPlanBulkChgGuaranteeidCorp() {

        // 画面パラメータ
        Id     chkChgOriginalId;   // 変更元Id
        String chkChgOriginalName; // 変更元名
        
        // 明細選択値の取得
        for (screenGuarantee dto : screenGuaranteeList){
            if (dto.guaranteeCheck) {
                chkChgOriginalId   = dto.guaranteeItem.id;
                chkChgOriginalName = dto.guaranteeItem.Account__r.Name + ' ' + dto.guaranteeItem.ItemName__c;
                break;
            }
        }

        // 業者プラン一括変更画面の起動
        this.openSupplierPlanBulkChg(GD101002Modal2ParameterClass.dispKind.guaranteeidCorp
                                     , chkChgOriginalId
                                     , chkChgOriginalName);
    }

    /**
     * 火災保険会社プランの業者プラン一括変更画面の起動
     */
    public void openSupplierPlanBulkChgFireInsuranceCorp() {

        // 画面パラメータ
        Id     chkChgOriginalId;   // 変更元Id
        String chkChgOriginalName; // 変更元名
        
        // 明細選択値の取得
        for (ScreenFireInsurance dto : screenFireList){
            if (dto.fireCheck) {
                chkChgOriginalId   = dto.fireItem.id;
                chkChgOriginalName = dto.fireItem.Account__r.Name + ' ' + dto.fireItem.ItemName__c;
                break;
            }
        }

        // 業者プラン一括変更画面の起動
        this.openSupplierPlanBulkChg(GD101002Modal2ParameterClass.dispKind.fireInsuranceCorp
                                     , chkChgOriginalId
                                     , chkChgOriginalName);
    }

    /**
     * 管理会社指定商品の業者プラン一括変更画面の起動
     */
    public void openSupplierPlanBulkChgManaCorpItem() {
        
        // 画面パラメータ
        Id     chkChgOriginalId;   // 変更元Id
        String chkChgOriginalName; // 変更元名
        
        // 明細選択値の取得
        for (ScreenManagementCompanyItem dto : screenManaComItemList){
            if (dto.manaComItemCheck) {
                chkChgOriginalId   = dto.manaComItemRecord.id;
                chkChgOriginalName = dto.manaComItemRecord.ItemName__c;
                break;
            }
        }

        // 業者プラン一括変更画面の起動
        this.openSupplierPlanBulkChg(GD101002Modal2ParameterClass.dispKind.manaCorpItem
                                     , chkChgOriginalId
                                     , chkChgOriginalName);
    }

    /**
     * 業者プラン一括変更画面の起動
     * @param GD101002Modal2ParameterClass.DispKind dispKind        画面種別
     * @param Id                                    chgOriginalId   変更元Id
     * @param String                                chgOriginalName 変更元名
     */
    public void openSupplierPlanBulkChg(GD101002Modal2ParameterClass.DispKind dispKind
                                        , Id chgOriginalId
                                        , String chgOriginalName) {

        // パラメータの設定
        this.GD101002Modal2Parameter = new GD101002Modal2ParameterClass();
        this.GD101002Modal2Parameter.accountId       = this.targetId;                // 取引先.Id
        this.GD101002Modal2Parameter.accountName     = this.screenTargetRecord.name; // 取引先.取引先名
        this.GD101002Modal2Parameter.chgOriginalId   = chgOriginalId;                // 変更元Id
        this.GD101002Modal2Parameter.chgOriginalName = chgOriginalName;              // 変更元名
        this.GD101002Modal2Parameter.openDispKind    = dispKind;                     // 画面種別
        this.GD101002Modal2Parameter.isDrawing       = true;                         // 初回描画フラグ
        this.GD101002Modal2Parameter.noFirst         = true;                         // 描画実施済みフラグ
    }

    /**
     * 業者プラン一括変更画面のクローズ処理
     */
    public void closeSupplierPlanBulkChg() {
        
        // 画面種別に応じた明細のチェックボックスの初期化
        switch on this.GD101002Modal2Parameter.openDispKind {
            when guaranteeidCorp {
                for (screenGuarantee screenGuarantee : screenGuaranteeList){
                    screenGuarantee.guaranteeCheck = false;
                }
            }
            when FireInsuranceCorp {
                for (ScreenFireInsurance screenFire : screenFireList){
                    screenFire.fireCheck = false;
                }
            }
            when manaCorpItem {
                for (ScreenManagementCompanyItem screenManaComItem : screenManaComItemList){
                    screenManaComItem.manaComItemCheck = false;
                }
            }
        }

        // 業者プラン一括変更画面の初期化
        this.GD101002Modal2Parameter = new GD101002Modal2ParameterClass();
    }

    //★保証プランモーダル(追加ボタン)
    public void openGuaranteeModal(){
        GD101003Parameter.isDrawing = true;
        GD101003Parameter.noFirst = true; 
    }
    //★保証プランモーダルclose処理
    public void closeGuaranteeModal() {
        for(Item__c g :GD101003Parameter.itemList){
            this.screenGuaranteeList.add(new ScreenGuarantee(g));
        }
    }
    //★保証プラン削除
    public void deleteGuarantee(){
        try{
            hasErrorMessage = false;
            BusinessLogicException ex = new BusinessLogicException();
            //リスト1件以上
            if(screenGuaranteeList.size() > 0){
                //チェック1件以上
                Set<ID> idSet = new Set<ID>();  //☑の取引先保険保証のある、商品Id入れるリスト
                Set<ID> getIdSet = new Set<ID>(); //取得した物件のId入れるリスト
                //保証プラン明細リストをの中から、
                for (screenGuarantee g : screenGuaranteeList){
                    //チェックボックスがTRUEで、取引先保険保証のidがある場合,取引先保険保証のIDをIDセットに追加
                    if (g.guaranteeCheck && String.isNotEmpty(g.guaranteeRecord.id)){
                        idSet.add(g.guaranteeItem.id);//idSetに商品Id追加 
                    }
                }
                //IdSetを条件に 物件に検索をかける。結果が帰ってくる場合はエラーあり。
                //2020/5/15：条件に現況=退去予定OR空室と元付業者=対象の元付業者を追加
                List<AggregateResult> alist =[SELECT Guaranteeid__c  //保証タイトル
                                              FROM Property__c 
                                              WHERE Guaranteeid__c 
                                              IN :idSet 
                                              AND FormerSupplier__c = :this.targetId 
                                              AND (LiveStatus__c = :CommonConst.PROPERTY_LIVESTATUS_SCHEDULEDTOLEAVE 
                                              OR LiveStatus__c = :CommonConst.PROPERTY_LIVESTATUS_VACANCY) 
                                              GROUP BY Guaranteeid__c];                
                                              
                //取得してきた物件を回す
                for (AggregateResult a : alist) {
                    //getIdSetに追加
                    getIdSet.add((id)a.get('Guaranteeid__c')); 
                }
                //全明細を回して、エラーメッセージを追加。
                for (screenGuarantee g: screenGuaranteeList){
                    if (g.guaranteeCheck){
                        //getIdSetに含まれていたらエラー
                        if (getIdSet.contains(g.guaranteeItem.id)){
                            String errorMessage='';
                            //エラーメッセージ作成
                            if (String.isNotEmpty(g.guaranteeItem.Account__r.Name)){
                                errorMessage += '「' + g.guaranteeItem.Account__r.Name;
                            }
                            if (String.isNotEmpty(g.guaranteeItem.ItemName__c)){
                                if (String.isNotEmpty(errorMessage)){
                                    errorMessage += ' ';
                                }
                                errorMessage += g.guaranteeItem.ItemName__c ;
                            }
                            if (String.isNotEmpty(errorMessage)){
                                errorMessage += '」は';
                            }
                            
                            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_CANNOT_DELETE_LINKED,errorMessage + '物件'));
                        }
                    }
                }
                //ビジネスロジックExceptionにメッセージが1つ以上ある場合、ビジネスロジックException発行
                if (ex.hasMessage()){ 
                    throw ex;
                }
                //エラーがなかったら削除処理
                for (Integer i=screenGuaranteeList.size()-1; i >= 0; i--){
                    //チェックボックスがTRUE
                    if (screenGuaranteeList[i].guaranteeCheck){
                        //取引先保険保証のidがある場合は削除リストに追加
                        if (String.isNotEmpty(screenGuaranteeList[i].guaranteeRecord.id)){
                            deleteGuaranteeList.add(screenGuaranteeList[i].guaranteeRecord);//削除リストに追加　2020/5/15：保険保証削除リストから保証削除リストに変更
                            updateGuaranteeItemIdSet.add(screenGuaranteeList[i].guaranteeItem.id);//2020/5/15：保証商品更新IdセットにIdを追加
                        }
                        screenGuaranteeList.remove(i);//保証プランの明細リストから削除
                    }
                }
            }       
        }catch (Exception e) {
            hasErrorMessage = true;//エラーを設定  
            CommonUtil.setErrorMessage(e);
        }    
    }

    //★火災保険プランモーダル(追加ボタン)
    public void openFireModal(){
        GD101004Parameter.isDrawing = true;
        GD101004Parameter.noFirst = true; 
    }
    //★火災保険プランモーダルclose処理
    public void closeFireModal() {
        for(Item__c f :GD101004Parameter.itemList){
            this.screenFireList.add(new ScreenFireInsurance(f));
        }
    }
    //★火災プラン削除
    public void deleteFire(){
        try{
            hasErrorMessage = false;
            BusinessLogicException ex = new BusinessLogicException();
            if(screenFireList.size() > 0){
                //チェック1件以上
                Set<ID> idSet = new Set<ID>();  //☑の取引先保険保証のある、商品Id入れるリスト
                Set<ID> getIdSet = new Set<ID>(); //取得した物件のId入れるリスト
               
                //火災プラン明細リストをの中から、
                for (screenFireInsurance f : screenFireList){
                    //チェックボックスがTRUEで、取引先保険保証のidがある場合,取引先保険保証のIDをIDセットに追加
                    if (f.fireCheck && String.isNotEmpty(f.fireRecord.id)){
                        idSet.add(f.fireItem.id);//idSetに商品ID追加 
                    }
                }
                //IdSetを条件に 物件に検索をかける。結果が帰ってくる場合はエラーあり。
                //2020/5/15：条件に現況=退去予定OR空室と元付業者=対象の業者を追加
                List<AggregateResult> alist =[SELECT FireInsurancePlan__c //火災保険タイトル
                                              FROM Property__c 
                                              WHERE FireInsurancePlan__c 
                                              IN :idSet
                                              AND FormerSupplier__c = :this.targetId 
                                              AND (LiveStatus__c = :CommonConst.PROPERTY_LIVESTATUS_SCHEDULEDTOLEAVE 
                                              OR LiveStatus__c = :CommonConst.PROPERTY_LIVESTATUS_VACANCY) 
                                              GROUP BY FireInsurancePlan__c];
                //取得してきた物件を回す
                for (AggregateResult a : alist) {
                    //getIdSetに追加
                    getIdSet.add((id)a.get('FireInsurancePlan__c')); 
                }
                //全明細を回して、エラーメッセージを追加。
                for (screenfireInsurance f: screenFireList){
                    if (f.fireCheck){
                        //getIdSetに含まれていたらエラー
                        if (getIdSet.contains(f.fireItem.id)){
                            String errorMessage='';
                            //エラーメッセージ作成
                            if (String.isNotEmpty(f.fireItem.Account__r.Name)){
                                errorMessage += '「' + f.fireItem.Account__r.Name;
                            }
                            if (String.isNotEmpty(f.fireItem.ItemName__c)){
                                if (String.isNotEmpty(errorMessage)){
                                    errorMessage += ' ';
                                }
                                errorMessage += f.fireItem.ItemName__c ;
                            }
                            if (String.isNotEmpty(errorMessage)){
                                errorMessage += '」は';
                            }
                            
                            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_CANNOT_DELETE_LINKED,errorMessage + '物件'));
                        }
                    }
                }
                //ビジネスロジックExceptionにメッセージが1つ以上ある場合、ビジネスロジックException発行
                if (ex.hasMessage()){ 
                    throw ex;
                }
                //エラーがなかったら削除処理
                for (Integer i=screenFireList.size()-1; i >= 0; i--){
                    //チェックボックスがTRUE
                    if (screenFireList[i].fireCheck){
                        //取引先保険保証のidがある場合は削除リストに追加
                        if (String.isNotEmpty(screenFireList[i].fireRecord.id)){
                            deleteInsuranceList.add(screenFireList[i].fireRecord);//削除リストに追加　2020/5/15：保証保険削除リストから保険削除リストに変更
                            updateInsuranceItemIdSet.add(screenFireList[i].fireItem.id);//2020/5/15：火災保険商品更新IdセットにIdを追加
                        }
                        screenFireList.remove(i);//火災プランの明細リストから削除
                    }
                }
            }      
        }catch (Exception e) {
            hasErrorMessage = true;//エラーを設定  
            CommonUtil.setErrorMessage(e);
        }    
    }
    //★管理会社指定商品プランモーダル(追加ボタン)
    public void openManagementCompanyItemModal(){
        GD101002Modal1Parameter.isDrawing = true;
        GD101002Modal1Parameter.noFirst = true;
        GD101002Modal1Parameter.paramMCIRecird = new ManagementCompanyItem__c();
        modal4IsEdit= false;
    }
    //★管理会社指定商品プランモーダル(編集)
    public void editManagementCompanyItemModal(){
        GD101002Modal1Parameter.isDrawing = true;
        GD101002Modal1Parameter.noFirst = true;
        modal4IsEdit= true;
        GD101002Modal1Parameter.paramMCIRecird = screenManaComItemList[manaComItemIndex].manaComItemRecord;
    }
    //★管理会社指定商品プランモーダルclose処理
    public void closeManagementCompanyItemModal() {
        if (modal4IsEdit){ 
            this.screenManaComItemList[manaComItemIndex].manaComItemRecord.ItemName__c = GD101002Modal1Parameter.paramMCIRecird.ItemName__c;
            this.screenManaComItemList[manaComItemIndex].manaComItemRecord.Amount__c = GD101002Modal1Parameter.paramMCIRecird.Amount__c;
            this.screenManaComItemList[manaComItemIndex].manaComItemRecord.TaxType__c = GD101002Modal1Parameter.paramMCIRecird.TaxType__c;
            this.screenManaComItemList[manaComItemIndex].manaComItemRecord.PaymentType__c = GD101002Modal1Parameter.paramMCIRecird.PaymentType__c;
            
            screenManaComItemList[manaComItemIndex].manaComItemRecord.recalculateFormulas();
            this.screenManaComItemList[manaComItemIndex].manaComItemAmount = CommonUtil.decimalToString(this.screenManaComItemList[manaComItemIndex].manaComItemRecord.AmountTax__c);
            if(String.isNotBlank(this.screenManaComItemList[manaComItemIndex].manaComItemAmount)){
                this.screenManaComItemList[manaComItemIndex].manaComItemAmount += '円';
            }
        }else{
            this.screenManaComItemList.add(new ScreenManagementCompanyItem(GD101002Modal1Parameter.paramMCIRecird));
        }
    }
    //★管理会社指定商品削除
    public void deleteManaComItem(){
        try{
            hasErrorMessage = false;
            BusinessLogicException ex = new BusinessLogicException();
            //リスト1件以上
            
            if(screenManaComItemList.size() > 0){
                //チェック1件以上
                Set<ID> idSet = new Set<ID>();  //☑の管理会社指定商品Id入れるリスト
                Set<ID> getIdSet = new Set<ID>(); //取得した物件管理会社指定のId入れるリスト
                
                //管理会社指定商品明細リストをの中から、
                for (ScreenManagementCompanyItem mana : screenManaComItemList){
                    //チェックボックスがTRUEで、管理会社指定商品Idがある？
                    if (mana.manaComItemCheck && String.isNotEmpty(mana.manaComItemRecord.id)){
                        idSet.add(mana.manaComItemRecord.id);//idSetに管理会社指定商品ID追加 
                    }
                }
                //IdSetを条件に 物件管理会社指定に検索をかける。結果が帰ってくる場合はエラーあり。
                List<AggregateResult> alist =[SELECT Item__c //管理会社指定プラン
                                                FROM PropertyManageCompayItem__c 
                                                WHERE  Item__c
                                                IN :idSet
                                                GROUP BY Item__c];
                //取得してきた物件を回す
                for (AggregateResult a : alist) {
                    //getIdSetに追加
                    getIdSet.add((id)a.get('Item__c')); 
                }
                //全明細を回して、エラーメッセージを追加。
                for (ScreenManagementCompanyItem mana: screenManaComItemList){
                    if (mana.manaComItemCheck){
                        //getIdSetに含まれていたらエラー
                        if (getIdSet.contains(mana.manaComItemRecord.id)){
                            String errorMessage='';
                            //エラーメッセージ作成
                            if (String.isNotEmpty(mana.manaComItemRecord.ItemName__c)){
                                errorMessage = '「' + mana.manaComItemRecord.ItemName__c + '」は';
                            }                            
                            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_CANNOT_DELETE_LINKED,errorMessage + '物件管理会社指定'));
                        }
                    }
                }
                //ビジネスロジックExceptionにメッセージが1つ以上ある場合、ビジネスロジックException発行
                if (ex.hasMessage()){ 
                    throw ex;
                }
                //エラーがなかったら削除処理
                for (Integer i=screenManaComItemList.size()-1; i >= 0; i--){
                    //チェックボックスがTRUE
                    if (screenManaComItemList[i].manaComItemCheck){
                        //2021/4/12:管理会社指定商品のidがある場合は削除リストに追加
                        if (String.isNotEmpty(screenManaComItemList[i].manaComItemRecord.id)){
                            deleteManaComItemList.add(screenManaComItemList[i].manaComItemRecord);
                        }
                        screenManaComItemList.remove(i);//管理会社指定商品明細リストから削除
                    }
                }
            }     

        }catch (Exception e) {
            hasErrorMessage = true;//エラーを設定  
            CommonUtil.setErrorMessage(e);
        }    
    }

    //★保存
    public void save(){ 
        try{
            Savepoint sp = Database.setSavepoint();      //セーブポイント作成
            BusinessLogicException ex = new BusinessLogicException();
            hasErrorMessage = false;

            //2020/5/15：退去予定OR空室以外の物件の紐付けがある場合、nullにしてから削除を行う　ここから▼
            //●削除保証リストが空でない場合
            if (deleteGuaranteeList.size() != 0){
               //保証項目の更新が必要な物件が取得
                List<Property__c> updateGuaranteePropertyList =[SELECT Id,Guaranteeid__c 
                                                            FROM Property__c
                                                            WHERE Guaranteeid__c IN :updateGuaranteeItemIdSet 
                                                            AND FormerSupplier__c = :this.targetId  
                                                            LIMIT :selectLimit + 1]; 
                Boolean isUpdateGuaranteeFinal = false;
                //更新メッセージ設定      
                if (updateGuaranteePropertyList.size() <= selectLimit){
                    //50件以下
                    MSG_COM_I_SAVEBUTTON =  CommonUtil.callMessageCreate(MSG_COM_I_PROPERTY_SAVE_BULKUPDATE, '保証プラン','全');
                    isUpdateGuaranteeFinal = true;
                }else{
                    //51件以上
                    //メッセージ追加
                    updateGuaranteePropertyList.remove(selectLimit); //最後の一つをついでに除去(removeの引数はindexなのでselectLimit+1番目が除去される)
                    MSG_COM_I_SAVEBUTTON =  CommonUtil.callMessageCreate(MSG_COM_I_PROPERTY_SAVE_BULKUPDATE, '保証プラン',CommonUtil.decimalToString(selectLimit));
                }

                //物件の保証関連項目をnullに変更
                for(Property__c p : updateGuaranteePropertyList){
                    p.Guaranteeid__c = null;//保証タイトル
                    p.GuaranteeidCompany__c = null;//保証会社
                    p.GuaranteeidCompanyType__c = null;//保証会社（利用区分）
                }
                SecureDML.secureUpdate(updateGuaranteePropertyList); 

                //更新が50件以下の場合
                if (isUpdateGuaranteeFinal == true){
                    SecureDML.secureDelete(deleteGuaranteeList);//取引先保険保証（保証分）削除
                    deleteGuaranteeList.clear();
                }        
            
            //●火災保険削除リストが空でない場合
            }else if (deleteInsuranceList.size() != 0){
                //火災保険項目の更新が必要な物件を取得
                List<Property__c> updateInsurancePropertyList =[SELECT Id,FireInsurancePlan__c 
                            FROM Property__c
                            WHERE FireInsurancePlan__c IN :updateInsuranceItemIdSet
                            AND FormerSupplier__c = :this.targetId  
                            LIMIT :selectLimit + 1]; 
                //●火災の削除リストがある場合
                Boolean isUpdateInsuranceFinal=false;
                //更新メッセージ設定                                           
                if (updateInsurancePropertyList.size() <= selectLimit){
                    //50件以下
                    MSG_COM_I_SAVEBUTTON =  CommonUtil.callMessageCreate(MSG_COM_I_PROPERTY_SAVE_BULKUPDATE, '火災保険プラン','全');
                    isUpdateInsuranceFinal =true;
                }else{
                    //51件以上
                    //メッセージ追加
                    MSG_COM_I_SAVEBUTTON =  CommonUtil.callMessageCreate(MSG_COM_I_PROPERTY_SAVE_BULKUPDATE, '火災保険プラン',CommonUtil.decimalToString(selectLimit));
                    updateInsurancePropertyList.remove(selectLimit); //最後の一つをついでに除去(removeの引数はindexなのでselectLimit+1番目が除去される)
                }

                //物件の火災関連項目をnullに変更
                for(Property__c p : updateInsurancePropertyList){
                    p.FireInsurancePlan__c = null;//火災タイトル
                    p.FireInsuranceCompany__c = null;//火災会社
                    p.FireInsuranceUseType__c = null;//火災保険(加入義務)
                }
                SecureDML.secureUpdate(updateInsurancePropertyList); 

                //更新が50件以下の場合
                if (isUpdateInsuranceFinal == true){
                    SecureDML.secureDelete(deleteInsuranceList);//取引先保険保証（火災分）削除
                    deleteInsuranceList.clear();
                }         
                //2020/5/15：退去予定OR空室以外の物件の紐付けがある場合、nullにしてから削除を行う　ここまで▲
                //2020/5/15：削除処理が終わっている場合、保存処理
            }else{
                //完了メッセージ設定
                MSG_COM_I_SAVEBUTTON = MSG_COM_I_SAVE;//2020/5/15：保存が完了しました。

                // メールアドレス:メールアドレスの入力規則をチェックし、間違っていればエラー
                if(CommonUtil.isWrongMailString(screenTargetRecord.email)){
                    ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_MAILADDRESS_VALIDATION, 'メールアドレス'));
                }

                //入力チェック
                List<String> requiredItem = new List<String>();
                //取引先名(Name)はオブジェクトに必須
                if (String.isBlank(screenTargetRecord.name)){
                    requiredItem.add('業者名');
                }
                //基本情報：電話番号
                if (String.isBlank(screenTargetRecord.phone)){
                    requiredItem.add('電話番号');
                }
                //取引先名(Name)はオブジェクトに必須
                if (String.isBlank(screenTargetRecord.representative)){
                    requiredItem.add('担当者名');
                }
                
                //入力チェック用リストが空ではない場合、ビジネスロジックException発行
                if (!requiredItem.isEmpty()){
                    //項目名をカンマで区切って、ビジネスロジックException発行
                    ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ',')));
                }

                //同一の業者が既に存在していたらエラー（業者名、電話番号、住所が完全一致）
                List<Account> DuplicationCheckRecord = new List<Account>();
                                        String address = screenTargetRecord.state + screenTargetRecord.city + ' ' + screenTargetRecord.street;
                DuplicationCheckRecord = [ SELECT id
                                        FROM Account
                                        WHERE Name = :screenTargetRecord.Name
                                        AND Address__c = :address
                                        AND Phone = :screenTargetRecord.phone
                                        LIMIT 1];
                //重複するレコードがあった
                if (! DuplicationCheckRecord.isEmpty()){
                    //新規時は必ずエラー、編集時は取得したidがtargetIdと違えばエラー
                    if(DuplicationCheckRecord[0].id != this.targetId || isNew){
                        ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_EXISTENCE,'「'+ screenTargetRecord.name +'」' ));
                    }
                }  
                //火災・保証重複既にある？フラグ（メッセージに主語がないためメッセージを重複させな）
                Boolean isAlreadyDuplication =false;
                //保証重複チェック
                if(screenGuaranteeList.size() != 0){
                    Set<ID> itemId = new Set<ID>();
                    for(screenGuarantee guar:screenGuaranteeList){
                        if(!itemId.contains(guar.guaranteeItem.id)){
                            //setに含まれてなかったらこの商品idをsetに追加
                            itemId.add(guar.guaranteeItem.id);
                        }else{
                            isAlreadyDuplication = true;
                            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SELECTION_DUPLICATE));
                            break;
                        }
                    }
                }
                //火災保険重複チェック
                if(screenFireList.size() != 0  && ! isAlreadyDuplication){
                    Set<ID> itemId = new Set<ID>();
                    for(screenFireInsurance fire:screenFireList){
                        if(!itemId.contains(fire.fireItem.id)){
                            //setに含まれてなかったらこの商品idをsetに追加
                            itemId.add(fire.fireItem.id);
                        }else{
                            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SELECTION_DUPLICATE));
                            break;
                        }
                    }
                }

                //楽観ロックチェック
                if (!isNew){
                    List<Account> checkOptimisticLockExceptionRecord = new List<Account>();
                    checkOptimisticLockExceptionRecord = [ SELECT id
                                                            FROM Account
                                                            WHERE id = :screenTargetRecord.targetRecord.Id
                                                            AND SystemModStamp = :screenTargetRecord.targetRecord.systemModStamp ];
                    
                    //データ取得できない場合、楽観ロックチェックExceptionを発行
                    if (checkOptimisticLockExceptionRecord.isEmpty()){
                        OptimisticLockException ex2 = new OptimisticLockException();
                        throw ex2;
                    }
                }

                // 問合せ278で追加 初期表示がリアプロ、大和リビングの場合を除き、リアプロ、大和リビングが選択された場合、エラー
                if((screenTargetRecord.importType == REALNETPRO && screenTargetRecord.initialInportType != REALNETPRO) 
                || (screenTargetRecord.importType == DAIWALIVING && screenTargetRecord.initialInportType != DAIWALIVING)) {
                    ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_INPORT_DESTINATION_CAN_NOT_CHANGE, screenTargetRecord.importType));
                }

                // 初期表示が--なし--の場合を除き、--なし--が選択された場合、エラー
                if(String.isBlank(screenTargetRecord.importType) && String.isNotBlank(screenTargetRecord.initialInportType)) {
                    ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_INPORT_DESTINATION_CAN_NOT_CHANGE, SELECTION_LIST_NULL));
                }

                //ビジネスロジックExceptionにメッセージが1つ以上ある場合、ビジネスロジックException発行
                if (ex.hasMessage()){ 
                    throw ex;
                }

                //取引先、保証会社プランリスト、火災保険会社プランリスト、管理会社指定商品リスト、対応
                //●取引先
                Account upsertAcc = new Account(
                    Name = screenTargetRecord.name,      //取引先名
                    PostalCode__c = screenTargetRecord.postalCode,//郵便番号
                    //基本情報
                    NameKana__c = screenTargetRecord.nameKana,//取引先名カナ
                    IsOwner__c = screenTargetRecord.isOwner,//オーナー
                    IsManagementCompany__c = screenTargetRecord.isManagementCompany,//管理会社
                    IsSubLease__c = screenTargetRecord.isSubLease,//サブリース
                    Phone = screenTargetRecord.phone,//電話番号
                    Fax = screenTargetRecord.fax,//Fax
                    Email__c = screenTargetRecord.email,//メール
                    State__c = screenTargetRecord.state,//都道府県○
                    City__c = screenTargetRecord.city,//住所1
                    Street__c = screenTargetRecord.street,//住所2
                    RemarksPublic__c = screenTargetRecord.remarksPublic,//公開備考
                    RemarksPrivate__c  = screenTargetRecord.remarksPrivate,//非公開備考
                    IppamGyobutsu__c = screenTargetRecord.ippamGyobutsu,//一般/業物○
                    FixedTermSend__c = screenTargetRecord.fixedTermSend,//定期送信○
                    Introduction__c = screenTargetRecord.introduction,//紹介○
                    //GuarantorAgencyCompanyType__c = screenTargetRecord.guarantorAgencyCompanyType,//保証人代行会社区分○
                    RenewalFeeShow__c = screenTargetRecord.renewalFeeShow,//更新料表記○
                    CleaningFeeShow__c = screenTargetRecord.cleaningFeeShow,//定額補修費表記○
                    //担当者情報
                    Representative__c = screenTargetRecord.representative,//担当者
                    RepresentativePhone__c = screenTargetRecord.representativePhone,//取引先担当者電話番号
                    //電物
                    DembutsuDate__c = screenTargetRecord.dembutsuDate,//電物日
                    DembutsuStatus__c = screenTargetRecord.dembutsuStatus,//電物ステータス○
                    DembutsuStaff__c = screenTargetRecord.dembutsuStaff,//電物担当者
                    DembutsuEventMemo__c = screenTargetRecord.dembutsuEventMemo,//電物イベントメモ
                    //クローリング
                    ImportType__c = screenTargetRecord.importType,//取込区分○
                    MaintenanceSupplierCode__c = screenTargetRecord.maintenanceSupplierCode,//メンテナンス業者コード
                    //ポータル掲載設定
                    at_home_press_ban__c = screenTargetRecord.atHomePressBan, //at home掲載不可
                    HOME_S_press_ban__c = screenTargetRecord.homesPressBan,   //HOME'S 掲載不可
                    SUUMO_press_ban__c = screenTargetRecord.suumoPressBan,    //SUUMO掲載不可
					Chintai_press_ban__c = screenTargetRecord.chintaiPressBan, //CHINTAI掲載不可  2022.04.06 CHINTAI対応追加
                    Our_HP_press_ban__c = screenTargetRecord.ourHpPressBan    //自社HP掲載不可
                );
                if(!isNew){
                    //新規じゃない
                    upsertAcc.id = this.targetId;
                }else{
                    upsertAcc.RecordTypeId = CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_SUPPLIER);
                }
                // 問合せ278で追加　手動に変更した場合、メンテナンス業者コードをnullに変更
                if(this.screenTargetRecord.importType == MANUAL && screenTargetRecord.initialInportType != MANUAL) {
                    upsertAcc.MaintenanceSupplierCode__c = null;// メンテナンス業者コード
                } else {
                    upsertAcc.MaintenanceSupplierCode__c = this.screenTargetRecord.maintenanceSupplierCode;// メンテナンス業者コード
                }
                
                ///名寄せ完了フラグ設定
                setMergeCompletedFlag(upsertAcc); //中で、必要があれば名寄完了フラグを設定してくれる。
                secureDML.secureUpsert(upsertAcc);

                //●対応（新規作成時のみ）
                if(isNew){
                    Correspond__c insertCorr = new Correspond__c(
                        AccountId__c = upsertAcc.id,//取引先Id
                        Status__c = '終了',//ステータス
                        EventDateTime__c = commonUtil.getToday(),//イベント日時
                        District__c = '-',//地区
                        StaffSupportedFlg__c = true,//スタッフ対応フラグ
                        IsSupportedListShow__c = true,//対応確認
                        IsBrowseFlg__c = true,//閲覧フラグ
                        ListViewDate__c = DateTime.newInstance(2999,12,31,12,59,0)//一覧表示日時
                    );
                    SecureDML.secureInsert(insertCorr);
                }
                
                //●管理会社指定商品削除リストの削除
                if(deleteManaComItemList.size() != 0){
                    SecureDML.secureDelete(deleteManaComItemList);
                }

                //●取引先保険保証upsert
                List<InsuranceGuarantee__c> upsertGuarList = new List<InsuranceGuarantee__c>();
                List<InsuranceGuarantee__c> upsertInsList = new List<InsuranceGuarantee__c>();
                //火災
                if (screenFireList.size() != 0){
                    for( screenFireInsurance fire :screenFireList){
                        InsuranceGuarantee__c upsertFire = new InsuranceGuarantee__c(
                            Account__c = upsertAcc.id,
                            Item__c = fire.fireItem.id,
                            RecordTypeId = this.RecordTypeIdFireInsurance
                        );
                        //idがある？
                        if(fire.fireItem.id != null){
                            upsertFire.id = fire.fireRecord.id;
                        }
                        upsertInsList.add(upsertFire);
                    }
                    SecureDML.secureUpsert(upsertInsList);
                }
                //保証
                if (screenGuaranteeList.size() != 0){
                    for( ScreenGuarantee guar :screenGuaranteeList){
                        InsuranceGuarantee__c upsertGuar = new InsuranceGuarantee__c(
                            Account__c = upsertAcc.id,
                            Item__c = guar.guaranteeItem.id,
                            RecordTypeId = this.RecordTypeIdGuarantee
                        );
                        //idがある？
                        if(guar.guaranteeRecord.id != null){
                            upsertGuar.id = guar.guaranteeRecord.id;
                        }
                        upsertGuarList.add(upsertGuar);
                    }
                    SecureDML.secureUpsert(upsertGuarList);
                }

                //管理会社指定商品
                if (screenManaComItemList.size() != 0){
                    List<ManagementCompanyItem__c> upsertManaComItemList = new List<ManagementCompanyItem__c>();
                    for( screenManagementCompanyItem mci :screenManaComItemList){
                        ManagementCompanyItem__c upsertManaComItem = new ManagementCompanyItem__c(
                            Account__c = upsertAcc.id,
                            ItemName__c = mci.manaComItemRecord.ItemName__c,
                            Amount__c = mci.manaComItemRecord.Amount__c,
                            TaxType__c = mci.manaComItemRecord.TaxType__c,
                            PaymentType__c = mci.manaComItemRecord.PaymentType__c
                        );
                        //idがある？
                        if(mci.manaComItemRecord.id != null){
                            upsertManaComItem.id = mci.manaComItemRecord.id;
                        }
                        upsertManaComItemList.add(upsertManaComItem);
                    }
                    SecureDML.secureUpsert(upsertManaComItemList);
                }

                //バッチ実施チェック
                if (this.isExecuteBatch(upsertAcc, screenTargetRecord.targetRecord)) {
                    //完了メッセージの文言を追加
                    MSG_COM_I_SAVEBUTTON += CommonConst.BREAK_TAG + CommonUtil.callMessageCreate(CommonConst.MSG_ACC_I_TRADER_REGIST_SEND_MAIL);

                    //掲載設定を取得
                    Boolean isDispSuumo = (upsertAcc.SUUMO_press_ban__c == true) ? false: true;
                    Boolean isDispHomes = (upsertAcc.HOME_S_press_ban__c == true) ? false: true;
                    Boolean isDispAtHome = (upsertAcc.at_home_press_ban__c == true) ? false: true;
					Boolean isDispChintai = (upsertAcc.Chintai_press_ban__c == true) ? false: true;  // 2022.04.06 CHINTAI対応追加
                    Boolean isDispOurHp =  (upsertAcc.Our_HP_press_ban__c == true) ? false: true;

                    // 変更フラグ
                    Boolean isChgSuumo = (upsertAcc.SUUMO_press_ban__c != screenTargetRecord.targetRecord.SUUMO_press_ban__c);
                    Boolean isChgHomes = (upsertAcc.HOME_S_press_ban__c != screenTargetRecord.targetRecord.HOME_S_press_ban__c);
                    Boolean isChgAtHome = (upsertAcc.at_home_press_ban__c != screenTargetRecord.targetRecord.at_home_press_ban__c);
					Boolean isChgChintai = (upsertAcc.Chintai_press_ban__c != screenTargetRecord.targetRecord.Chintai_press_ban__c);    // 2022.04.06 CHINTAI対応追加
                    Boolean isChgOurHp = (upsertAcc.Our_HP_press_ban__c != screenTargetRecord.targetRecord.Our_HP_press_ban__c);

                    //バッチ
                    BD301004Batch b = new BD301004Batch(upsertAcc.id, isDispSuumo, isDispHomes, isDispAtHome, isDispOurHp
                    									, upsertAcc.Name, isChgSuumo, isChgHomes, isChgAtHome, isChgOurHp);
                    Database.executeBatch(b, SystemConfig__c.getInstance().FormerSupplierPropChgSendMailBatSize__c.intValue());
                }

                //保存処理終了
                this.isSaveFinish = true;
            }

        }catch(Exception e){
            //Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }
        
    }

    //★削除
    public void deleteButton(){
        Savepoint sp = Database.setSavepoint();      //セーブポイント作成

        //取引先レコードとそれに紐づくレコードを削除
        try{
            hasErrorMessage = false;
            BusinessLogicException ex = new BusinessLogicException();
            //この取引先が物件と紐づいていたらエラー
            List<Property__c> proRecord =[SELECT id 
                                    FROM Property__c 
                                    WHERE FormerSupplier__c = :targetId];
            if (proRecord.size() != 0){              
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_CANNOT_DELETE_LINKED,'「'+screenTargetRecord.name + '」は物件'));
            }
            //対応明細が1件以上ならエラー
            if(!isNew){
                List<CorrespondDetail__c> corrRecord=[SELECT id       
                                                FROM CorrespondDetail__c
                                                WHERE Corresponds__c = :correspondId];
                if(corrRecord.size()!=0){
                    ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_NOTICE_USED));
                }
            }
        
            //ビジネスロジックExceptionにメッセージが1つ以上ある場合、ビジネスロジックException発行
            if (ex.hasMessage()){ 
                throw ex;
            }
            //対応削除
            List<Correspond__c> delCorr =[SELECT id
                                            FROM Correspond__c
                                            WHERE id = :correspondId
                                            ORDER BY LastModifiedDate DESC
                                            LIMIT 1];
            //レコード削除
            if (delCorr.size() != 0){
                SecureDML.secureDelete(delCorr);
            }
            SecureDML.secureDelete(screenTargetRecord.targetRecord);

        }catch(Exception e){
            
            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
            
        }
    }
    //◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇  privateメソッド ◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇v
    //初期化メソッド
    private void init(){
        this.isNew = false;
        this.isOpenError = false;
        this.hasErrorMessage = false;
        this.isSaveFinish = false;//2020/5/15：保存処理終わったフラグ（保存で使う）

        //店舗異動が取得できなければエラー
        CommonUtil.getStaffCurrentShop();
        GA102006Parameter = new GA102006ParameterClass();//郵便番号モーダル初期化
        GD101003Parameter = new GD101003ParameterClass();//保証プランモーダル初期化
        GD101004Parameter = new GD101004ParameterClass();//火災保険プランモーダル初期化
        GD101002Modal1Parameter = new GD101002Modal1ParameterClass();//管理会社指定商品プランモーダル初期化

        this.screenGuaranteeList = new List<ScreenGuarantee>();//保証リスト初期化
        this.screenFireList = new List<screenFireinsurance>();//火災保険リスト初期化
        this.screenManaComItemList = new List<screenManagementCompanyItem>();//管理会社指定商品初期化
        this.buildingList = new List<Building__c>();//建物リスト初期化

        
        this.deleteInsuranceList = new List<InsuranceGuarantee__c>();//2020/5/15：取引先保険保証の削除リスト初期化（火災）
        this.deleteGuaranteeList = new List<InsuranceGuarantee__c>();//2020/5/15：取引先保険保証の削除リスト初期化（保証）
        this.updateGuaranteeItemIdSet = new Set<Id>();//2020/5/15：保証商品Id更新用セット初期化
        this.updateInsuranceItemIdSet = new Set<Id>();//2020/5/15：火災保険商品Id削除セット初期化

        //this.deleteInsuranceGuaranteeList = new List<InsuranceGuarantee__c>();//取引先保険保証の削除リスト初期化
        this.deleteManaComItemList = new List<ManagementCompanyItem__c>();//管理会社指定商品の削除リスト初期化
    }
    //取引先レコード情報取得
    private Account selectRecordInfo(Id targetId){
        List<Account> targetRecordList = [SELECT id,
                                                Name,      //取引先名
                                                Address__c,//住所
                                                PostalCode__c,//郵便番号
                                                //基本情報
                                                NameKana__c,//取引先名カナ
                                                IsOwner__c,//オーナー
                                                IsManagementCompany__c,//管理会社
                                                IsSubLease__c,//サブリース
                                                Phone,//電話番号
                                                Fax,//Fax
                                                Email__c,//メール
                                                State__c,//都道府県○
                                                City__c,//住所1
                                                Street__c,//住所2
                                                RemarksPublic__c,//公開備考
                                                RemarksPrivate__c,//非公開備考
                                                IppamGyobutsu__c,//一般/業物○
                                                FixedTermSend__c,//定期送信○
                                                Introduction__c,//紹介○
                                                GuarantorAgencyCompanyType__c,//保証人代行会社区分○
                                                RenewalFeeShow__c,//更新料表記○
                                                CleaningFeeShow__c,//定額補修費表記○
                                                //担当者情報
                                                Representative__c,//担当者
                                                RepresentativePhone__c,//取引先担当者電話番号
                                                //電物
                                                DembutsuDate__c,//電物日
                                                DembutsuStatus__c,//電物ステータス○
                                                DembutsuStaff__c,//電物担当者
                                                DembutsuEventMemo__c,//電物イベントメモ
                                                //クローリング
                                                ImportType__c,//取込区分○
                                                MaintenanceSupplierCode__c,//メンテナンス業者コード
                                                SystemModStamp,
                                                //ポータル掲載設定
                                                at_home_press_ban__c,//at home掲載不可  
                                                HOME_S_press_ban__c, //HOME'S 掲載不可
                                                SUUMO_press_ban__c,  //SUUMO掲載不可
												Chintai_press_ban__c, //CHINTAI掲載不可  2022.04.06 CHINTAI対応追加
                                                Our_HP_press_ban__c, //自社HP掲載不可

                                                //対応
                                                (SELECT id FROM CorrespondAccountId__r ORDER BY LastModifiedDate LIMIT 1)
                                            FROM Account 
                                            WHERE id = :this.targetId];
        
        //レコード情報が取得できなければビジネスロジックException発行
        if( targetRecordList.isEmpty() ){
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
            throw ex;
        }
        //関連レコードの取得（建物、取引先保険保証、物件管理会社指定）：サブクエリのデータ量が多すぎてエラーが出たため分割
        selectSubQueryInfo();
        //対応Id
        for(correspond__c corr :targetRecordList[0].CorrespondAccountId__r){
            correspondId = corr.id;
        }
        Account targetAccount = targetRecordList[0];
        return targetRecordList[0];
    }
	//関連レコードの取得（建物、取引先保険保証、物件管理会社指定）：サブクエリのデータ量が多すぎてエラーが出たため分割
	private void selectSubQueryInfo(){
		//取引先保険保証
		List<InsuranceGuarantee__c> insGuarList =[
			SELECT id,
					Item__r.Account__r.Name,
					Item__r.DirectDebitFeeTax__c,
					Item__r.Remarks__c, 
					Item__r.AssuranceContent__c,
					Item__r.ItemName__c,
					Item__r.FireInsurance__c,
					Item__r.DirectDebitFeeTaxType__c,
					RecordTypeId
			FROM InsuranceGuarantee__c
			WHERE Account__c = :this.targetId
			ORDER BY Item__r.ItemName__c ASC];	//問合せNo0655でソート順追加

		//管理会社指定商品
		List<ManagementCompanyItem__c> mciList = [
			SELECT id, 
					ItemName__c, 
					Amount__c,
					AmountTax__c,
					TaxType__c,
					PaymentType__c 
			FROM ManagementCompanyItem__c
			WHERE Account__c = :this.targetId
			ORDER BY ItemName__c ASC,
				PaymentType__c ASC];	//問合せNo0655でソート順追加
		//建物
    	List<Building__c> builList =[
			SELECT id,
					Name,
					Address__c,
					Structure__c,
					BuildingYMFormat__c,
					TrainRoute1__r.Name,
					Station1__r.Name,
					StationWalkTimeFormat1__c 
			FROM Building__c
			WHERE Id IN (SELECT Building__c FROM property__c WHERE FormerSupplier__c =:targetId) 
			ORDER BY Name ASC
			LIMIT :selectBuildingLimit];

        //保証・火災リストを追加
        if (insGuarList.size() != 0){
            
            for(InsuranceGuarantee__c g :insGuarList){
                if (g.Item__c != null){
                    //レコードタイプが火災なら火災リストに追加
                    if(g.RecordTypeId == this.RecordTypeIdFireInsurance){
                        this.screenFireList.add(new ScreenFireInsurance(g));
                    }else{
                        this.screenGuaranteeList.add(new ScreenGuarantee(g));
                    }
                }
            }
        }

        //建物を建物レコードに追加
        if (builList.size() != 0){
            for (Building__c b :builList){
                this.buildingList.add(b);
            }
        }

        //管理会社指定商品リストを追加 
        if (mciList.size() != 0){
            for(ManagementCompanyItem__c m :mciList){
                this.screenManaComItemList.add(new ScreenManagementCompanyItem(m));
            }  
        }
    }

    //名寄せ完了フラグ設定
    private void setMergeCompletedFlag (Account upSertAccount){  
        // 新規作成の場合か、編集時に 業者名or電話番号or「都道府県＋住所1＋住所2」の値が変更されていた場合に、名寄せの確認を行う
        if(isNew
        || CommonUtil.isDifferenceTwoString(upSertAccount.Name, this.screenTargetRecord.targetRecord.Name)//業者名
        || CommonUtil.isDifferenceTwoString(upSertAccount.Phone, this.screenTargetRecord.targetRecord.Phone)//電話
        || CommonUtil.isDifferenceTwoString(upSertAccount.State__c, this.screenTargetRecord.targetRecord.State__c)//都道府県
        || CommonUtil.isDifferenceTwoString(upSertAccount.City__c, this.screenTargetRecord.targetRecord.City__c)//住所1
        || CommonUtil.isDifferenceTwoString(upSertAccount.Street__c, this.screenTargetRecord.targetRecord.Street__c)//住所2
        ){
            // 名寄せ確認に数式(住所項目)を使用しているので、確認前に数式の再計算を行う
            upSertAccount.recalculateFormulas();
            //名寄せ対象を取得
            List<Account> nameMergeList = NameMergeUtil.getSupplierMergeList(upSertAccount, null);// 名寄せ対象のListが返却されてくる

            if(nameMergeList.size() == 0){// 名寄せ確認の結果0件なら名寄せ完了
                upSertAccount.IsMergeCompletedFlag__c = true;
                
            } else {// 名寄せ確認の結果0件でないなら名寄せ未完了
                upSertAccount.IsMergeCompletedFlag__c = false;
            }
        }
    } 

    //バッチ実施チェック
    private Boolean isExecuteBatch(Account dispAcc, Account oldAcc) {

        //SUUMO
        if (dispAcc.SUUMO_press_ban__c != oldAcc.SUUMO_press_ban__c && dispAcc.SUUMO_press_ban__c) {
            return true;
        }
            
        //HOME'S
        if (dispAcc.HOME_S_press_ban__c != oldAcc.HOME_S_press_ban__c && dispAcc.HOME_S_press_ban__c) {
            return true;
        }
            
        //at home
        if (dispAcc.at_home_press_ban__c != oldAcc.at_home_press_ban__c && dispAcc.at_home_press_ban__c) {
            return true;
        }

		// ▼ 2022.04.06 CHINTAI対応追加
		if (dispAcc.Chintai_press_ban__c != oldAcc.Chintai_press_ban__c && dispAcc.Chintai_press_ban__c) {
			return true;
		}
		// ▲ 2022.04.06 CHINTAI対応追加
            
        //自社HP
        if (dispAcc.Our_HP_press_ban__c != oldAcc.Our_HP_press_ban__c) {
            return true;
        }
        return false;
    }

    //◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇  内部クラス ◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇v
    //◆管理会社指定商品リスト内部クラス
    public class ScreenManagementCompanyItem{
        public ManagementCompanyItem__c manaComItemRecord{ get; set; }//レコード本体
        public Boolean manaComItemCheck{ get; set; }//チェックボックス
        public String manaComItemAmount{ get; set; }//金額
        //コンストラクタ
        public ScreenManagementCompanyItem(ManagementCompanyItem__c ItemRecord){
            this.manaComItemRecord = ItemRecord;
            this.manaComItemCheck=false;//チェックボックスfalse
            manaComItemRecord.recalculateFormulas();
            this.manaComItemAmount = CommonUtil.decimalToString(manaComItemRecord.AmountTax__c);
            if(String.isNotBlank(this.manaComItemAmount)){
                this.manaComItemAmount += '円';
            }
        }
    }
    
    //◆保証リストの内部クラス
    public class ScreenGuarantee{
        public InsuranceGuarantee__c guaranteeRecord{ get; set; }//取引先保険保証（upsert用）
        public Item__c guaranteeItem { get; set; }    //商品（表示）
        public Boolean guaranteeCheck{ get; set; }//チェックボックス
        public String assuranceContentPlus{ get; set; }//保証内容
        //コンストラクタ

        //元から用
        public ScreenGuarantee(InsuranceGuarantee__c GuaranteeRecord){
            this.guaranteeRecord    = GuaranteeRecord;//取引先保険保証レコード
            this.guaranteeItem = GuaranteeRecord.Item__r;//商品レコード
            this.guaranteeCheck=false;//チェックボックスfalse
            this.assuranceContentPlus = assuranceContent(this.guaranteeItem);
        }
        //モーダルで追加された用
        public ScreenGuarantee(Item__c itemRecord){
            this.guaranteeRecord = new InsuranceGuarantee__c();
            this.guaranteeRecord.Item__c = itemRecord.id;    //取引先保険保証レコードの商品idを代入
            this.guaranteeItem = itemRecord;//商品レコード
            this.guaranteeCheck=false;//チェックボックスfalse
            this.assuranceContentPlus = assuranceContent(this.guaranteeItem);
        }

        //保証内容の設定
        private String assuranceContent(Item__c item){
            String assuranceContentPlus = '';

            //口座振替手数料の表示（値があるなら改行、口座振替手数料を表示）
            if (item.DirectDebitFeeTax__c != null && item.DirectDebitFeeTax__c != 0 ){
                
                //保証内容がなければ改行コードをプラス
                if (String.isNotBlank(item.AssuranceContent__c)) {
                    assuranceContentPlus += '<br/>';
                }
                
                assuranceContentPlus += '口座振替手数料 ' + commonUtil.decimalToString(item.DirectDebitFeeTax__c) + '円';
                //手数料税区分なら（税込）を追加
                if(item.DirectDebitFeeTaxType__c == '課税'){
                    assuranceContentPlus +=  '（税込）';
                }
            }
            return assuranceContentPlus;
        }
    }

    //◆火災保険リスト内部クラス
    public class ScreenFireInsurance{
        public InsuranceGuarantee__c fireRecord{ get; set; }//取引先保険保証（upsert用）
        public Item__c fireItem { get; set; }    //商品（表示）
        public Boolean fireCheck{ get; set; }//チェックボックス
        //コンストラクタ

        //元から用
        public ScreenFireInsurance(InsuranceGuarantee__c FireInsuranceRecord){
            this.fireRecord    = FireInsuranceRecord;//取引先保険保証レコード
            this.fireItem = FireInsuranceRecord.Item__r;//商品レコード
            this.fireCheck=false;//チェックボックスfalse
        }
        //モーダルで追加された用
        public ScreenFireInsurance(Item__c itemRecord){
            this.fireRecord = new InsuranceGuarantee__c();
            this.fireRecord.Item__c = itemRecord.id;    //取引先保険保証レコードの商品idを代入
            this.fireItem = itemRecord;//商品レコード
            this.fireCheck=false;//チェックボックスfalse
        }
    }
       
    //◆取引先表示用の内部クラス
    public class ScreenAccount{
        public Account targetRecord{ get; set; }//レコード本体
        
        public String titleName { get; set; }    //ヘッダー表示用取引先名
        public String name{ get; set; }      //取引先名
        public String address{ get; set; }//住所
        public String postalCode{ get; set; }//郵便番号
        //基本情報
        public String nameKana{ get; set; }//取引先名カナ
        public Boolean isOwner{ get; set; }//オーナー
        public Boolean isManagementCompany{ get; set; }//管理会社
        public Boolean isSubLease{ get; set; }//サブリース
        public String phone{ get; set; }//電話番号
        public String fax{ get; set; }//Fax
        public String email{ get; set; }//メール
        public String state{ get; set; }//都道府県○
        public String city{ get; set; }//住所1
        public String street{ get; set; }//住所2
        public String remarksPublic{ get; set; }//公開備考
        public String remarksPrivate{ get; set; }//非公開備考
        public String ippamGyobutsu{ get; set; }//一般/業物○
        public String fixedTermSend{ get; set; }//定期送信○
        public String introduction{ get; set; }//紹介○
        public String guarantorAgencyCompanyType{ get; set; }//保証人代行会社区分○
        public String renewalFeeShow{ get; set; }//更新料表記○
        public String cleaningFeeShow{ get; set; }//定額補修費表記○
        //担当者情報
        public String representative{ get; set; }//担当者
        public String representativePhone{ get; set; }//取引先担当者電話番号
        //電物
        public Date dembutsuDate{ get; set; }//電物日
        public String dembutsuStatus{ get; set; }//電物ステータス○
        public String dembutsuStaff{ get; set; }//電物担当者
        public String dembutsuEventMemo{ get; set; }//電物イベントメモ
        //クローリング
        public String importType{ get; set; }//取込区分○
        public String maintenanceSupplierCode{ get; set; }//メンテナンス業者コード
        public String initialInportType{ get; set; }//問合せ278で追加　画面初期表示時取込区分
        //ポータル掲載設定
        public Boolean atHomePressBan{ get; set; } //at home掲載不可
        public Boolean homesPressBan{ get; set; }  //HOME'S 掲載不可
        public Boolean suumoPressBan{ get; set; }  //SUUMO掲載不可
		public Boolean chintaiPressBan{ get; set; }  //CHINTAI掲載不可	 2022.04.06 CHINTAI対応追加
        public Boolean ourHpPressBan{ get; set; }  //自社HP掲載不可
        
        //コンストラクタ
        public ScreenAccount(Account targetRecord){
            this.titleName    = targetRecord.Name;//ヘッダー表示用取引先名
            this.targetRecord = targetRecord;

            this.name         = targetRecord.Name;       //取引先名
            this.address      = targetRecord.Address__c;//住所    
            this.postalCode   = targetRecord.PostalCode__c;//郵便番号
            //基本情報
            this.nameKana     = targetRecord.NameKana__c;//取引先名カナ
            this.isOwner      = targetRecord.IsOwner__c;//オーナー
            this.isManagementCompany = targetRecord.IsManagementCompany__c;//管理会社
            this.isSubLease   = targetRecord.IsSubLease__c;   //サブリース        
            this.phone        = targetRecord.Phone;//電話番号
            this.fax          = targetRecord.Fax;//Fax
            this.email        = targetRecord.Email__c;//メール
            this.state        = targetRecord.State__c;//都道府県○
            this.city         = targetRecord.City__c;//住所1
            this.street       = targetRecord.Street__c;//住所2
            this.remarksPublic= targetRecord.RemarksPublic__c;   //公開備考        
            this.remarksPrivate= targetRecord.RemarksPrivate__c;//非公開備考
            this.ippamGyobutsu= targetRecord.IppamGyobutsu__c;//一般/業物○
            this.fixedTermSend= targetRecord.FixedTermSend__c;//定期送信○
            this.introduction = targetRecord.Introduction__c;//紹介○
            this.guarantorAgencyCompanyType = targetRecord.GuarantorAgencyCompanyType__c;//保証人代行会社区分○
            this.renewalFeeShow             = targetRecord.RenewalFeeShow__c; //更新料表記○      
            this.cleaningFeeShow            = targetRecord.CleaningFeeShow__c;//定額補修費表記○
            //担当者情報
            this.representative      = targetRecord.Representative__c;//担当者
            this.representativePhone = targetRecord.RepresentativePhone__c;//取引先担当者電話番号
           //電物
            this.dembutsuDate      = targetRecord.DembutsuDate__c;//電物日
            this.dembutsuStatus    = targetRecord.DembutsuStatus__c;//電物ステータス○
            this.dembutsuStaff     = targetRecord.DembutsuStaff__c;//電物担当者
            this.dembutsuEventMemo = targetRecord.DembutsuEventMemo__c;//電物イベントメモ
            //クローリング
            this.importType        = targetRecord.ImportType__c;//取込区分○
            this.maintenanceSupplierCode= targetRecord.MaintenanceSupplierCode__c;//メンテナンス業者コード
            // 問合せ278で追加　データ取得時に取込区分を退避
            this.initialInportType = targetRecord.ImportType__c;
            //ポータル掲載設定
            this.atHomePressBan = targetRecord.at_home_press_ban__c; //at home掲載不可
            this.homesPressBan  = targetRecord.HOME_S_press_ban__c;  //HOME'S 掲載不可
            this.suumoPressBan  = targetRecord.SUUMO_press_ban__c;   //SUUMO掲載不可
			this.chintaiPressBan  = targetRecord.Chintai_press_ban__c;   //CHINTAI掲載不可	 2022.04.06 CHINTAI対応追加
            this.ourHpPressBan  = targetRecord.Our_HP_press_ban__c;  //自社HP掲載不可
        }
    }


}