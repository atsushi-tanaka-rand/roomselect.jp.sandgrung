/**
 * 業者選択モーダル画面コントローラ
 */

public inherited sharing class GD301003Controller {

    //Public変数
    public GD301003ParameterClass Parameter { get; set; }   //パラメータクラス
    public Boolean isOpenError { get; set; }                //画面起動時のエラーフラグ
    public Boolean hasErrorMessage { get; set; }            //エラーメッセージ保有フラグ

    public String accountScreenText{ get; set;}             //保証会社選択検索テキスト
    public String telScreenText{ get; set;}                 //プラン名検索テキスト
    public String mailScreenText{ get; set;}                //保証内容検索テキスト
    public Boolean ownerIsDisabled{ get; set;}              //オーナーisDisabled
    public Boolean managementCompanyIsDisabled{ get; set;}  //管理会社isDisabled
    public Boolean subleaseIsDisabled{ get; set;}           //サブリースisDisabled

    public Boolean ownerCheck{ get; set;}               //オーナーチェックボックス
    public Boolean managementCompanyCheck{ get; set;}   //管理会社チェックボックス
    public Boolean subleaseCheck{ get; set;}            //サブリースチェックボックス

    public Integer index{ get; set; }                          //明細行
    public List<DisplayAccount> targetList { get; set; }       //明細部のリスト

    
    //private変数
    private GD301003ParameterClass.SupplierConst supplierType;  //業者種別
    private List<DisplayAccount> disAccountList;                //一時保存用
    Integer searchLimit;                                        //検索上限
    
    
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
            
            //パラメータ取得
            this.supplierType = Parameter.supplierType;
            
            //上限取得
            this.searchLimit = Integer.valueOf(SystemConfig__c.getInstance().SupplierSearchMaxCount__c);//検索上限をカスタム設定から取得
            
            //業者種別設定
            if(supplierType == GD301003ParameterClass.SupplierConst.FORMER_SUPPLIER){
                
                //元付業者
                ownerIsDisabled = false;              //オーナー  isDisabled
                managementCompanyIsDisabled =false;   //管理会社  isDisabled
                subleaseIsDisabled = true;            //サブリースisDisabled    
                
                ownerCheck = true;                    //オーナー  チェックボックス
                managementCompanyCheck =true;         //管理会社  チェックボックス
                subleaseCheck = false;                //サブリースチェックボックス
                
            }else if(supplierType == GD301003ParameterClass.SupplierConst.CREDITOR){
                
                //貸主
                ownerIsDisabled = false;               //オーナーisDisabled
                managementCompanyIsDisabled =false;    //管理会社isDisabled
                subleaseIsDisabled = false;            //サブリースisDisabled

                ownerCheck = true;               //オーナーチェックボックス
                managementCompanyCheck =true;    //管理会社チェックボックス
                subleaseCheck = true;            //サブリースチェックボックス
                
            }else if(supplierType == GD301003ParameterClass.SupplierConst.OWNER){
                
                //所有者
                ownerIsDisabled = false;              //オーナーisDisabled
                managementCompanyIsDisabled =true;    //管理会社isDisabled
                subleaseIsDisabled = true;            //サブリースisDisabled   
                
                ownerCheck = true;                //オーナーチェックボックス
                managementCompanyCheck =false;    //管理会社チェックボックス
                subleaseCheck = false;            //サブリースチェックボックス
                
            }else{
                
                //パラメータがない場合、エラー
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
                throw ex;
                
            }
            
            //画面のテキストを空白に
            this.accountScreenText= '';     
            this.telScreenText    = '';     
            this.mailScreenText   = '';     
           
            this.targetList = new List<DisplayAccount>();//明細部のリストを初期化
            this.index = 0;
            
        }catch(Exception e){
            
            //エラーを設定
            isOpenError = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    //検索ボタン
    public void search(){
        try {
            hasErrorMessage = false;//エラーフラグ初期化
            BusinessLogicException ex = new BusinessLogicException();
            
            //一時保存用明細リスト
            disAccountList = new List<DisplayAccount>();

            //SELECT（業者種別ごとに回す必要がある）
            if (ownerCheck){
                selectSOQL('IsOwner__c', 'オーナー');
            }
            if(subleaseCheck){
                selectSOQL('IsSubLease__c', 'サブリース');
            }
            if(managementCompanyCheck){
                selectSOQL('IsManagementCompany__c', '管理会社');
            }
            
            //一時保存のレコード情報が0ならビジネスロジックException発行
            if (disAccountList.size() == 0){     
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_NO_DATA));
                throw ex;
            }
            
            //一時保存のレコード情報が件数超過の場合Exeption発行
            if(disAccountList.size() > searchLimit){
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_NOTICE_MAX_COUNT_OVER ));
                throw ex;
            }
            
            //画面表示
            index = 0;
            this.targetList = new List<DisplayAccount>();
            
            //明細作成
            for (DisplayAccount dacc : disAccountList) {
                targetList.add(dacc);
            }


        }catch (Exception e) {
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }

    
    //選択ボタン押下
    public void selectButton(){
        try{
            hasErrorMessage = false;            
            Parameter.accountRecord = targetList[index].screenAccount;
        }catch (Exception e) {
            hasErrorMessage = true;//エラーを設定  
        }
    }

    //★privateメソッド
    //検索メソッド
    private void selectSOQL(String ApiName, String supType){

        //クエリ用変数設定
        String recordType = CommonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_SUPPLIER);
        String accountText= '%'+ CommonUtil.convertDisableWildcard(accountScreenText) + '%';
        String telText    = '%'+ CommonUtil.convertDisableWildcard(telScreenText) + '%';
        String mailText   = '%'+ CommonUtil.convertDisableWildcard(mailScreenText) + '%';
        String soql = '';
        
        //クエリ作成
        soql = 'SELECT id,';
        soql += '         Name,';
        soql += '         Phone,';
        soql += '         Email__c,';
        soql += '         Address__c,';
        soql += '         Representative__c,';
        soql += '         RepresentativePhone__c,';
        soql += '         RemarksPublic__c,';

        soql += '         Fax,';
        soql += '         PostalCode__c,';
        soql += '         State__c,';
        soql += '         City__c,';
        soql += '         Street__c,';
        soql += '         IsMergeCompletedFlag__c';

        soql += ' FROM Account';
        soql += ' WHERE RecordTypeId = :recordType';//レコードタイプ
        soql += ' AND ' + ApiName + ' = true';//業者種別

        //動的検索部分クエリ作成
        Boolean isLikeSearch = (String.isNotEmpty(accountScreenText)) || (String.isNotEmpty(telScreenText)) || (String.isNotEmpty(mailScreenText));//検索条件あり
        Boolean isAnd = false; //ANDが必要かどうか      //問合せNo0553で変更
        
        if (isLikeSearch) {
            soql += ' AND  ';
            if(!String.isEmpty(accountScreenText)){
                soql += '     (   Name LIKE :accountText';
                soql += '     OR NameKana__c LIKE :accountText';
                soql += '     )';
                isAnd = true;
            }
            if(!String.isEmpty(telScreenText)){
                soql += CommonUtil.andSet(isAnd);   //問合せNo0553で変更
                soql += '       Phone LIKE :telText';
                isAnd = true;
            }
            if(!String.isEmpty(mailScreenText)){
                soql += CommonUtil.andSet(isAnd);   //問合せNo0553で変更
                soql += '       Email__c LIKE :mailText';
            }       
        }
        soql += ' ORDER BY Name';
        soql += ' LIMIT :searchLimit';

        List<Account> accountList = Database.query(soql);
        
        //一時保存のレコードに取得したレコードを追加
        for (Account acc: accountList) {
            disAccountList.add(new DisplayAccount(acc,supType));
        }    
    }


    
    // 内部クラス
    public class DisplayAccount {
        
        public Account screenAccount{get; set;}     //取引先
        public String screenSupplierType{get; set;} //業者種別
        
        //コンストラクタ
        public DisplayAccount(Account acc,String supType) {
            this.screenAccount = acc;
            this.screenSupplierType  = supType;
        }
    }
}