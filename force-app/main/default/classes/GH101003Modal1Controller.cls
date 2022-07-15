/**
 * @File Name          : GH101003Modal1Controller.cls
 * @Description        : ユーザー異動登録画面のモーダル用コントローラ
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 2020/3/31 15:49:48
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2020/3/3   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public inherited sharing class GH101003Modal1Controller {

    //Public変数
    public GH101003Modal1ParameterClass Parameter { get; set; } //パラメータクラス
    public Boolean isOpenError { get; set; }                    //画面起動時のエラーフラグ
    public Boolean hasErrorMessage { get; set; }                //エラーメッセージ保有フラグ
    //画面表示用
    public screenShopTransfer screenShopTransferRecord{ get; set; } 

    //エラー表示用ユーザー名
    public String userName{ get; set; }

    //選択リスト
    public List<SelectOption> SelectStaffList{ get; set; }                  //ユーザー名
    public List<SelectOption> SelectOrgzanizationHierarchyList{ get; set; } //組織階層
    public List<SelectOption> SelectStatusTypeList{ get; set; }             //入退社・異動情報
    public List<SelectOption> SelectStaffTypeList{ get; set; }              //役職

    
    /**
    * @description ページの初期表示時の処理
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/3/16 
    * @param Parameter.isDrawing 
    * @return Boolean 
    **/
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

    
    /**
    * @description ページの初期表示時の、具体的処理
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/3/16 
    * @return void 
    **/
    public void initAction() {
        try{
            //フラグ初期化
            this.isOpenError = null;     //isOpenErrorをfalseに
            this.hasErrorMessage = null; //isErrorMessageをfalseに
            
            ShopTransfer__c stRecord = new ShopTransfer__c();
            //パラメータを受け取る
            screenShopTransferRecord = new screenShopTransfer(Parameter.paramSTRecord);

            //選択リスト 
            getUserSelectedOption();//ユーザー名
            getOrgzanizationHierarchySelectedOption();//組織階層
            this.SelectStatusTypeList = CommonUtil.getSelectOptionFromObject('ShopTransfer__c', 'StatusType__c'); //入退社・異動情報 

            getStaffTypeRadioButton();//役職
            
        }catch (Exception e){
            //エラーを設定
            isOpenError = true;
            CommonUtil.setErrorMessage(e);        
        }
    }

   
    /**
    * @description ユーザー名の選択リスト設定
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/3/16 
    * @return List<SelectOption> 
    **/
    public List<SelectOption> getUserSelectedOption(){

        List<SelectOption> SelectUserList = new List<SelectOption>();

        // 検索SQL
        String sql = '';
        sql += 'SELECT    Id         '; // ユーザ名
        sql += ',         Name       '; // 氏名
        sql += 'FROM      User       '; 
        sql += '   WHERE IsActive = true ';//有効
        sql += '   AND   profile.id != null ';//プロファイルIdが設定されている。
        sql += '   ORDER BY Name';

        List<User> userList = Database.query(sql); // listを取得

        //-- なし --を追加
        SelectUserList.add(new SelectOption('',CommonConst.SELECTION_LIST_NULL));

        // 検索したListを回して、SelectOption型のListに追加
        for(User record : userList){
            SelectUserList.add(new SelectOption (record.Id, record.Name)); 
        }

        // 選択リストを返却
        this.SelectStaffList = SelectUserList;
        return SelectStaffList;
    }

    /**
    * @description 組織階層の選択リスト設定
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/3/16 
    * @return List<SelectOption> 
    **/
    public List<SelectOption> getOrgzanizationHierarchySelectedOption(){

        List<SelectOption> SelectOrgList = new List<SelectOption>();

        // 検索SQL
        String sql = '';
        sql += 'SELECT   Id                       '; // ID
        sql += ',        HierarchyCode__c         '; // 階層コード
        sql += ',        OrganizationName__c      '; // 組織名       
        sql += 'FROM     OrganizationHierarchy__c '; // 組織階層
        sql += 'ORDER BY HierarchyCode__c, HierarchyOrder__c';  // 階層コード, 同階層表示順

        List<OrganizationHierarchy__c> orgList = Database.query(sql); // listを取得

        //-- なし --を追加
        SelectOrgList.add(new SelectOption('',CommonConst.SELECTION_LIST_NULL));

        // 検索したListを回して、SelectOption型のListに追加
        for(OrganizationHierarchy__c record : orgList){
            SelectOrgList.add(new SelectOption (record.Id, record.HierarchyCode__c + '_' + record.OrganizationName__c)); 
        }

        // 選択リストを返却
        this.SelectOrgzanizationHierarchyList = SelectOrgList;
        return SelectOrgzanizationHierarchyList;
    }
   
    /**
    * @description 役職の選択リスト設定
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/3/16 
    * @return List<SelectOption> 
    **/
    public List<SelectOption> getStaffTypeRadioButton(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('true', '管理職'));
        options.add(new SelectOption('false', '一般社員'));
        this.SelectStaffTypeList = options;
        return SelectStaffTypeList;
    }

 
    /**
    * @description 設定ボタン押下処理
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/3/16 
    * @return void 
    **/
    public void setShopTransferInfo(){
        
        try{
            hasErrorMessage = false;
            BusinessLogicException ex = new BusinessLogicException();

            //入力チェック
            List<String> requiredInfo = new List<String>();
            if (String.isBlank(screenShopTransferRecord.staffName)){
                requiredInfo.add('ユーザー名');
            }
            if (String.isBlank(screenShopTransferRecord.orgzanizationHierarchy)){
                requiredInfo.add('組織階層');
            }
            if (String.isBlank(String.valueOf(screenShopTransferRecord.startDate))){
                requiredInfo.add('開始日');
            }
            if (String.isBlank(String.valueOf(screenShopTransferRecord.endDate))){
                requiredInfo.add('終了日');
            }

            // 開始日が終了日を上回る場合
            if( screenShopTransferRecord.endDate  < screenShopTransferRecord.startDate ){
                //終了日に開始日より前の日付が設定されています。終了日は開始日以降を設定してください。
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_DATE_TERM));
            }
            
            //入力チェック用リストが空ではない場合、ビジネスロジックException発行
            if (!requiredInfo.isEmpty()){
                //項目名をカンマで区切って、ビジネスロジックException発行
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredInfo, ',')));
            }

            // エラーあり
            if(ex.hasMessage()){
                throw ex;
            }

            //完全重複エラーチェック
            checkExistance();

            //重複エラーチェック(店舗・期間)
            checkDuplication();

            //ユーザー異動情報を渡す
            Parameter.paramSTRecord =  new ShopTransfer__c(
                Staff__c = screenShopTransferRecord.staffName,
                OrgzanizationHierarchy__c = screenShopTransferRecord.orgzanizationHierarchy,
                StartDate__c = screenShopTransferRecord.startDate,
                EndDate__c = screenShopTransferRecord.endDate,
                StatusType__c = screenShopTransferRecord.statusType,
                IsShopStaffType__c = screenShopTransferRecord.staffType);

                //ユーザー名を渡す
                User u = [SELECT Name FROM User WHERE Id = :screenShopTransferRecord.staffName];
                Parameter.paramStaffName = u.Name;

                system.debug('パラメータのユーザー名' + u.Name);

                //組織階層名を渡す
                OrganizationHierarchy__c org = [SELECT HierarchyCode__c, OrganizationName__c 
                                                FROM OrganizationHierarchy__c 
                                                WHERE Id = :screenShopTransferRecord.orgzanizationHierarchy];
                Parameter.paramOrganizationName = org.HierarchyCode__c + '_' + org.OrganizationName__c;

                system.debug('パラメータの組織階層名' + org.OrganizationName__c);
            
        }catch(Exception e){
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }

    /**
    * @description 完全重複エラーチェック
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/3/6 
    * @return void 
    **/
    public void checkExistance(){
        BusinessLogicException ex = new BusinessLogicException();

        //店舗異動情報の明細取得
        List<GH101003Controller.ScreenShopTransferInfo> checkExistList = Parameter.paramSTList;

        //店舗異動情報明細を回す
        for(integer i = 0; i < checkExistList.size(); i++) {

            if((i != Parameter.paramIndex)
            && (checkExistList[i].shopTransferRecord.Staff__c == screenShopTransferRecord.staffName) 
            && (checkExistList[i].shopTransferRecord.OrgzanizationHierarchy__c == screenShopTransferRecord.orgzanizationHierarchy)
            && (checkExistList[i].shopTransferRecord.StartDate__c == screenShopTransferRecord.startDate)
            && (checkExistList[i].shopTransferRecord.EndDate__c == screenShopTransferRecord.endDate)
            && (checkExistList[i].shopTransferRecord.IsShopStaffType__c == screenShopTransferRecord.staffType)){

                system.debug('完全重複あり'); 
            
                //ユーザー名の取得
                User u = [SELECT Name FROM User WHERE Id = :screenShopTransferRecord.staffName];
                userName = u.Name;

                //ビジネスロジックException発行
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_EXISTENCE,'「'+ userName +'」' ));
                throw ex;

            } else {   
                system.debug('完全重複なし');             
            }
        }
    }

    /**
    * @description 重複エラーチェック(店舗・期間)
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/3/6 
    * @return void 
    **/
    public void checkDuplication(){
        BusinessLogicException ex = new BusinessLogicException();

        //店舗異動情報の明細取得
        List<GH101003Controller.ScreenShopTransferInfo> checkDuplicateList = Parameter.paramSTList;

        //店舗異動情報明細を回す
        for(integer i = 0; i < checkDuplicateList.size(); i++){

            //重複レコードがあった場合
            if((i != Parameter.paramIndex)
            && (checkDuplicateList[i].shopTransferRecord.Staff__c == screenShopTransferRecord.staffName) 
            && (checkDuplicateList[i].shopTransferRecord.OrgzanizationHierarchy__c == screenShopTransferRecord.orgzanizationHierarchy)
            && (checkDuplicateList[i].shopTransferRecord.StartDate__c < screenShopTransferRecord.endDate)
             && (checkDuplicateList[i].shopTransferRecord.EndDate__c > screenShopTransferRecord.startDate)){

                system.debug('重複あり'); 

                //ビジネスロジックException発行
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_USER_E_SAVE_SHOP_TERM_DUPLICATE));
                throw ex;

            } else {
                system.debug('重複なし'); 
            }
        }
    }


    // 内部クラス
    public class screenShopTransfer {

    public String staffName {get; set;}                 //ユーザー名
    public String orgzanizationHierarchy {get; set;}    //組織階層
    public Date startDate {get; set;}                   //開始日
    public Date endDate {get; set;}                     //終了日
    public String statusType {get; set;}                //入退社・異動情報
    public Boolean staffType {get; set;}                //役職

        //コンストラクタ
        public screenShopTransfer(ShopTransfer__c stInfo){
            this.staffName = stInfo.Staff__c;
            this.orgzanizationHierarchy = stInfo.OrgzanizationHierarchy__c;
            this.startDate = stInfo.StartDate__c;
            this.endDate = stInfo.EndDate__c;
            this.statusType = stInfo.StatusType__c;
            this.staffType = stInfo.IsShopStaffType__c;
        }
    }
}