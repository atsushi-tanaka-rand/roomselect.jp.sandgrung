/**
 * 担当者選択画面
 */
public with sharing class GA102001Modal1Controller {
    //Public変数
        
    /** 共通クラス */    
    public GA102001Modal1ParameterClass Parameter { get; set; }
    
    public Boolean isOpenError { get; set; }           //エラーフラグ
    public Boolean hasErrorMessage { get; set; }       //エラーメッセージ保有フラグ

    public List<SelectOption> selectEchoStaffList { get;set; }  // 反響担当者_担当者
    public List<SelectOption> selectEchoShopList { get;set; }   // 反響担当者_店舗
    public List<SelectOption> selectShopStaffList { get;set; }  // 来店担当者_担当者
    public List<SelectOption> selectVisitShopList { get;set; }  // 来店担当者_店舗

    public String MSG_COM_V_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_SAVE);} private set;}   // 登録確認メッセージ
    public String MSG_COM_I_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);} private set;}   // 登録完了メッセ―じ

    public String echoStaff { get;set; }        // 反響担当者_取引先
    public String echoShop { get;set; }         // 反響担当者_店舗
    public String shopStaff { get;set; }        // 来店担当者_担当者
    public String visitShop { get;set; }        // 来店担当者_店舗

    public String beforEchoStaff { get;set; }   // 変更前反響担当者_取引先
    public String beforShopStaff { get;set; }   // 変更前来店担当者_担当者

    public String echoStaffName { get;set; }    // 反響担当者_取引先名
    public String echoShopName { get;set; }     // 反響担当者_店舗名
    public String shopStaffName { get;set; }    // 来店担当者_担当者名
    public String visitShopName { get;set; }    // 来店担当者_店舗名

    public String loginStaff { get;set; }       // ログインユーザ(登録用)
    public String loginShop { get;set; }        // ログインユーザ店舗

    public Boolean EchoInputFlg {get;set; }      // 反響入力可否フラグ 
    public Boolean ShopInputFlg {get;set; }      // 店舗入力可否フラグ
    
    public Boolean statusFlg = false;             //ステータスフラグ

    public Datetime systemModStamp ;  // 楽観ロックチェック用
    
    public Boolean init{
        get{
            if (Parameter.isDrawing) {
                getSelectOption();
                Parameter.isDrawing = false;
                return false;
            }
            return true;
         
        }
    }

    /** リストの生成 */    
    public void getSelectOption(){
        isOpenError = false;
        try{
            // ログインユーザから店舗を取得する
            // 店舗情報の取得
            Shop__c shop = CommonUtil.getStaffCurrentShop();
            loginShop = shop.id;                            // 店舗名
            loginStaff = UserInfo.getUserId();

            if (!String.isblank(Parameter.CorrespondId)){
                // 対応IDからすでに登録されているか判断
                List<Correspond__c> Correspond = new List<Correspond__c>();
                Correspond = selectRecordInfo(Parameter.CorrespondId);

                // 取れてきた担当者と店舗を設定
                if (Correspond[0].EchoStaff__c != null ){
                    echoStaff = Correspond[0].EchoStaff__c;     // 反響担当者_取引先
                    echoStaffName = Correspond[0].EchoStaff__r.Name;
                    beforEchoStaff = echoStaff;
                }else {
                    echoStaff = CommonConst.STRING_EMPTY;
                    echoStaffName = CommonConst.STRING_EMPTY;
                    beforEchoStaff = CommonConst.STRING_EMPTY;
                }
                if (Correspond[0].EchoShop__c != null ){
                    echoShop = Correspond[0].EchoShop__c;       // 反響担当者_店舗
                    echoShopName = Correspond[0].EchoShop__r.Name;
                }else {
                    echoShop = CommonConst.STRING_EMPTY;
                    echoShopName = CommonConst.STRING_EMPTY;
                }
                if (Correspond[0].ShopStaff__c != null ){       
                    shopStaff = Correspond[0].ShopStaff__c;     // 来店担当者_担当者
                    shopStaffName = Correspond[0].ShopStaff__r.Name;
                    beforShopStaff = shopStaff;
                } else {
                    shopStaff = CommonConst.STRING_EMPTY;
                    shopStaffName = CommonConst.STRING_EMPTY;
                    beforShopStaff = CommonConst.STRING_EMPTY ;
                }
                if (Correspond[0].VisitShop__c != null ){
                    visitShop = Correspond[0].VisitShop__c;     // 来店担当者_店舗
                    visitShopName = Correspond[0].VisitShop__r.Name;
                } else {
                    visitShop = CommonConst.STRING_EMPTY;
                    visitShopName = CommonConst.STRING_EMPTY;
                }

                // ステータスにより反響各項目の入力可否を制御→20200828 全ステータスで入力できるよう変更                
                    EchoInputFlg = true;                
                
                // ステータスにより来店各項目の入力可否を制御
                if ( Correspond[0].Status__c == CommonConst.CORRESPOND_STATUS_ECHOAGGREGATION){
                    // 反響集約は入力不可 
                    ShopInputFlg = false;
                }else{
                    // 上記以外は入力可
                    ShopInputFlg = true;
                }
                //来店済み以降のステータスか判定する
                if(Correspond[0].Status__c == CommonConst.CORRESPOND_STATUS_VISITED|| //来店済み
                Correspond[0].Status__c == CommonConst.CORRESPOND_STATUS_UNEARNED|| //'未収入金'
                Correspond[0].Status__c == CommonConst.CORRESPOND_STATUS_APPLCANCEL|| //'申込キャンセル'
                Correspond[0].Status__c == CommonConst.CORRESPOND_STATUS_APPLCANCEL_PURSUIT|| //'申込キャンセル後追客'
                Correspond[0].Status__c == CommonConst.CORRESPOND_STATUS_DEPOSIT|| //'入金済'
                Correspond[0].Status__c == CommonConst.CORRESPOND_STATUS_AGREEMENT|| //'契約完了'
                Correspond[0].Status__c == CommonConst.CORRESPOND_STATUS_CONSIDERVISITING|| //'来店後検討'
                Correspond[0].Status__c == CommonConst.CORRESPOND_STATUS_VISITED_PURSUIT //'来店後追客中'
                ){
                statusFlg = true;
                }

                systemModStamp = Correspond[0].systemModStamp;
            }else{
                // 対応がない場合はセットを行わずスルー
                EchoInputFlg = true;
                ShopInputFlg = false;
                echoShop = CommonConst.STRING_EMPTY;
                echoStaff = CommonConst.STRING_EMPTY;
                visitShop = CommonConst.STRING_EMPTY;
                shopStaff = CommonConst.STRING_EMPTY;
            }

            // 各リストの生成
            selectEchoShopList = new List<SelectOption>();     //リストの初期化
            selectEchoStaffList = new List<SelectOption>();     //リストの初期化
            selectShopStaffList = new List<SelectOption>();     //リストの初期化
            selectVisitShopList = new List<SelectOption>();     //リストの初期化
            
            // 反響担当者_店舗のリストをセット
            selectEchoShopList = CommonUtil.getShopSelectedOptionFromStaffId(CommonConst.STRING_EMPTY,True);
            // 反響担当者_取引先のリストをセット
            if (string.isBlank(echoShop)){
                selectEchoStaffList.add(new SelectOption(CommonConst.STRING_EMPTY,CommonConst.SELECTION_LIST_NULL));
                selectEchoShopList.add(new SelectOption(CommonConst.STRING_EMPTY,CommonConst.SELECTION_LIST_NULL));
            }else {
                selectEchoStaffList = CommonUtil.getUserSelectedOptionFromShopId(echoShop,True);
                selectEchoShopList = CommonUtil.getShopSelectedOptionFromStaffId(CommonConst.STRING_EMPTY,True);
            }
            
            // 来店担当者_店舗のリストをセット
            selectVisitShopList = CommonUtil.getShopSelectedOptionFromStaffId(CommonConst.STRING_EMPTY,True);
            // 来店担当者_担当者のリストをセット
            if (string.isBlank(visitShop)){
                selectShopStaffList.add(new SelectOption(CommonConst.STRING_EMPTY,CommonConst.SELECTION_LIST_NULL));
            }else {
                selectShopStaffList = CommonUtil.getUserSelectedOptionFromShopId(visitShop,True);
            }
        } catch (Exception e) {
            // エラーを設定
            isOpenError = true;
            CommonUtil.setErrorMessage(e);

        }
    }

    /**
     * 反響担当者_店舗のリストをセット
     */
     public void getEchoShopList(){
        hasErrorMessage = false;
        try{
            // 反響担当者_店舗のリストをセット
            if (string.isBlank(echoShop)){
                selectEchoStaffList = new List<SelectOption>();     //リストの初期化
                selectEchoStaffList.add(new SelectOption(CommonConst.STRING_EMPTY,CommonConst.SELECTION_LIST_NULL));
            }else {
                selectEchoStaffList = CommonUtil.getUserSelectedOptionFromShopId(echoShop,True);
            }
        } catch (Exception e) {
            // エラーを設定
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
     }

    /**
     * 来店担当者_店舗のリストを変更
     */
     public void getVisitShopList(){
        hasErrorMessage = false;
        try{
            // 来店担当者_担当者のリストをセット
            if (string.isBlank(visitShop)){
                selectShopStaffList = new List<SelectOption>();     //リストの初期化
                selectShopStaffList.add(new SelectOption(CommonConst.STRING_EMPTY,CommonConst.SELECTION_LIST_NULL));
            }else {
                selectShopStaffList = CommonUtil.getUserSelectedOptionFromShopId(visitShop,True);
            }
        } catch (Exception e) {
            // エラーを設定
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);

        }
     }
    
    /**
     * 取引先のレコードタイプ取得
     * 引数　　：  Id string 取引先ID
     * 戻り値　：  取引先のレコードタイプ
     */
    private String setAccountListRecordTypeId(String Id){
            
        // 対応IDから来店担当者を取得
        List<Account> AccountList = [
                        SELECT Id
                        ,      RecordTypeId
                        FROM Account
                        WHERE Id = :Id
                       ];
        if (AccountList.size() > 0){
            return AccountList[0].RecordTypeId;
        }
        return CommonConst.STRING_EMPTY;
    }
    
    /**
     * 登録処理
     */
    public void saveDate(){
        Savepoint sp = Database.setSavepoint();      //セーブポイント作成
        hasErrorMessage = false;
        try{
            // 新規はチェックしない
            if(!String.isBlank(Parameter.CorrespondId)){
                //楽観ロックチェックExceptionを発行
                List<Correspond__c> checkOptimisticLockExceptionRecord = new List<Correspond__c>();
                checkOptimisticLockExceptionRecord = [ SELECT id
                                                            FROM Correspond__c
                                                            WHERE id = :Parameter.CorrespondId
                                                            AND SystemModStamp = :systemModStamp ];                //楽観ロックチェック
                if (checkOptimisticLockExceptionRecord.isEmpty()){
                    OptimisticLockException ex = new OptimisticLockException();
                    throw ex;
                }
            }
            
            BusinessLogicException inputCheckException = new BusinessLogicException();
            // 入力のチェック
            inputCheckException = inputCheck();
            // エラーあり
            if(inputCheckException.hasMessage()){
                throw inputCheckException;
            }
            // 対応の登録
            saveCorrespond(Parameter.CorrespondId,Parameter.AccountId);
            // ToDoの登録
            saveCorrespondDetail(Parameter.CorrespondId,Parameter.AccountId);

        }catch(Exception e){
            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }

    }

    /**
     * 検索処理
     * 引数　　：　Id String 対応ID
     * 戻り値　：　List<Correspond__c> 対応のデータ
     */
    private List<Correspond__c> selectRecordInfo(string Id){

        // 検索SQL作成
        String sql = CommonConst.STRING_EMPTY;
        sql += 'SELECT Id                     '; // 対応.Id（非表示）
        sql += '      ,Name                   '; // 対応.対応番号（非表示）
        sql += '      ,Status__c              '; // 対応.ステータス

        sql += '      ,EchoStaff__c           '; // 対応.担当者（反響）
        sql += '      ,EchoStaff__r.Name      '; // 対応.担当者（反響）.氏名
        sql += '      ,EchoShop__r.Name       '; // 対応.反響担当店舗.店舗名
        sql += '      ,EchoStaff__r.Department'; // 対応.ユーザ.部署

        sql += '      ,ShopStaff__c           '; // 対応.担当者（来店）
        sql += '      ,ShopStaff__r.Name      '; // 対応.担当者（来店）.氏名
        sql += '      ,VisitShop__r.Name      '; // 対応.来店担当店舗.店舗名
        sql += '      ,ShopStaff__r.Department'; // 対応.ユーザ.部署

        sql += '      ,systemModStamp         '; // systemModStamp

        sql += ' FROM  Correspond__c         ';
        sql += ' WHERE Id = \'' + Id + '\'';         //対応ID
    
        // 検索実行＆結果返却
        return Database.query(sql);

    }


    /**
     * 入力チェック
     * 引数　　：　
     * 戻り値　：  エラー有無
     */
     private BusinessLogicException inputCheck(){
        BusinessLogicException inputCheckException = new BusinessLogicException();

        // 反響店舗のみ入力がない
        if ((echoShop == null && echoStaff != null)){
            inputCheckException.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_CUST_E_REGISTRATION_TWOREQUIRED,'反響担当者','反響店舗'));
        }
        
        // 反響担当者のみ入力がない
        if ((echoShop != null && echoStaff == null)){
            inputCheckException.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_CUST_E_REGISTRATION_TWOREQUIRED,'反響店舗','反響担当者'));
        }
        
        // 来店店舗のみ入力がない場合
        if ((visitShop == null && shopStaff != null)){
            inputCheckException.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_CUST_E_REGISTRATION_TWOREQUIRED,'来店担当者','来店店舗'));
        }

        // 来店担当者のみ入力がない場合
        if ((visitShop != null && shopStaff == null)){
            inputCheckException.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_CUST_E_REGISTRATION_TWOREQUIRED,'来店店舗','来店担当者'));
        }

        // 新規作成時のみチェック
        if (String.isblank(Parameter.CorrespondId)){
            // 反響担当者、反響店舗の入力がない
            if (echoShop == null && echoStaff == null){
                inputCheckException.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED,'反響店舗、反響担当者'));
            }
        }

        //更新時反響担当者または来店担当者をなしに設定した場合エラー
        if(statusFlg == true && visitShop == null && shopStaff == null){
            inputCheckException.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED,'来店店舗、来店担当者'));
        }

        return inputCheckException;
     }


    /**
     * 更新処理(対応)
     * 引数　　：　Id String 対応ID
     *        ：  AccountId String 取引先
     * 戻り値　：  
     */
    private Boolean saveCorrespond(String Id,String AccountId){
        // 保存処理
        Correspond__c saveData = new Correspond__c();

        // 更新の場合対応IDをセット
        if (!string.isBlank(Id)){
            saveData.Id = Id;
            
        }else{
            // 新規登録時に必要
            saveData.Status__c = CommonConst.CORRESPOND_STATUS_NOTSUPPORTED;    // ステータス「未対応」
            saveData.ListViewDate__c = CommonConst.LAST_DATE;       // 一覧表示日時
            saveData.AccountId__c = AccountId;       // 取引先ID
            
        }

        saveData.EventDateTime__c = CommonUtil.getNow(); // イベント時刻
        if (string.isBlank(echoStaff) ){
            saveData.EchoStaff__c   = null;             // 担当者（反響）
        }else {
            saveData.EchoStaff__c   = echoStaff;        // 担当者（反響）
        }
        
        if (string.isBlank(shopStaff) ){
            saveData.ShopStaff__c   = null;             // 担当者（来店）
        }else{
            saveData.ShopStaff__c   = shopStaff;        // 担当者（来店）
        }

        if (string.isBlank(echoShop) ){
            saveData.EchoShop__c     = null;            // 反響担当店舗
        }else{
            saveData.EchoShop__c     = echoShop;        // 反響担当店舗
        }

        if (string.isBlank(visitShop) ){
            saveData.VisitShop__c   = null;             // 来店担当店舗
        }else{
            saveData.VisitShop__c   = visitShop;        // 来店担当店舗
        }

        SecureDML.secureUpsert(saveData);

        return True;
    }
    
    /**
     * 登録処理(対応明細)
     * 引数　　：　CorrespondId String 対応Id
     *        ：  AccountId String 取引先
     * 戻り値　：  
     */
    private Boolean saveCorrespondDetail(String CorrespondId,String AccountId){
        // 保存処理
        CorrespondDetail__c saveData = new CorrespondDetail__c();

        String setName = CommonConst.STRING_EMPTY;        // 選択ユーザ名         

        // 保存項目
        saveData.CorrespondType__c      = CommonConst.TASK_CORRESPONDTYPE_PERSONDECISION; // 対応種別
        saveData.SupportedDateTime__c   = CommonUtil.getNow();                  // 対応日時
        saveData.SupportedTitle__c      = CommonConst.TASK_CORRESPONDTYPE_PERSONDECISION; // 対応表題

        string SupportedContentmsg = CommonConst.STRING_EMPTY;    //文言設定用
        // 〇〇を反響担当者に設定しました。●●を来店担当者に設定しました。

        // 各項目が入っていなければ空に統一する。
        if (String.isBlank(beforEchoStaff)){beforEchoStaff=CommonConst.STRING_EMPTY;} 
        if (String.isBlank(echoStaff)){echoStaff=CommonConst.STRING_EMPTY;}
        if (String.isBlank(beforshopStaff)){beforshopStaff=CommonConst.STRING_EMPTY;}
        if (String.isBlank(shopStaff)){shopStaff=CommonConst.STRING_EMPTY;}

        if (beforEchoStaff != echoStaff ){
            setName = getListValue(selectEchoStaffList,echoStaff);
            if (!string.isBlank(setName)){
                // 項目が取れていれば文言をセットする。
                SupportedContentmsg += setName + 'を反響担当者に設定しました。';   // 対応内容 反響変更あり    
            }else{
                SupportedContentmsg += '反響担当者を外しました。';   // 対応内容 反響変更
            }            
        }

        if (beforshopStaff != shopStaff ){
            setName = getListValue(selectShopStaffList,shopStaff);
            if (!string.isBlank(setName)){
                // 項目が取れていれば文言をセットする。
                SupportedContentmsg+= setName + 'を来店担当者に設定しました。';   // 対応内容 来店変更あり
            }else{
                SupportedContentmsg  += '来店担当者を外しました。';   // 対応内容 来店変更あり
            }
        }
        saveData.SupportedContent__c = SupportedContentmsg;

        saveData.Shop__c                = loginShop;                            // 店舗
        saveData.Staff__c               = loginStaff;                           // 担当者
        if (String.isBlank(CorrespondId)){
            // 新規時は対応IDがないので取りに行く
            List<Correspond__c> CorrespondList = [
                SELECT Id
                FROM Correspond__c
                WHERE AccountId__c = :AccountId
           ];
            if (CorrespondList.size() > 0){
                saveData.Corresponds__c = CorrespondList[0].Id;
                Parameter.CorrespondId = CorrespondList[0].Id;
            }
            
        }else {
            saveData.Corresponds__c     = CorrespondId;                         // 対応ID    
        }
        

        SecureDML.secureInsert(saveData);

        return True;
    }

    /**
     * 選択リストの表示値を判定して返す
     * 引数　　：  selectDateList List<SelectOption> 取りたい選択リスト
     *        ：  Id String 対象のID
     * 戻り値　：  取れてきた一覧の表示値
     */
    private String getListValue(List<SelectOption> selectDateList ,String Id){
        if (string.isBlank(Id)){
            return CommonConst.STRING_EMPTY;
        }
        for (SelectOption selectDate : selectDateList) {
            if (selectDate.getvalue() == id){
                return selectDate.getLabel();
            }    
        }
        return CommonConst.STRING_EMPTY;
    }
}