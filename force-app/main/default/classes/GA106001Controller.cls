/* *
 * 指定メール一覧　のコントローラ
 */
public inherited sharing class GA106001Controller {
    
    /** public変数 */
    
    //選択リスト
    public List<SelectOption> selectFolderList { get;set; }   // フォルダ
    
    //検索ボタン関係
    public Date  receivedDate { get; set; }   // 受信日
    public String folderName { get; set; }    // フォルダ
    public String fromAddress { get; set; }   // 送信元
    public String toAddress { get; set; }     // 宛先
    public String subject { get; set; }       // 件名
    
    //明細関係
    Transient public List<EchoMail__c> echoMailList { get; set; }   // 明細リスト
    public String selectedEchoMailId { get; set; }                  // 選択された明細のId

    //選択されたメール関係
    public EchoMail__c selectedEchoMail {get; set;}       // 選択された反響メール
    public Boolean hasAttachment {get; set;}              // 添付ファイルがあるか
    public String  attachmentName {get; set;}             // 添付ファイル名（複数ある場合はカンマ区切り）
    public String  attachmentId {get; set;}               // 添付ファイルId（複数ある場合はカンマ区切り）
    
    //フラグ類
    public Boolean hasErrorMessage {get; set;}                      // エラーメッセージ保有フラグ
    public Boolean isOpenError {get; set;}                          // 初期エラーフラグ
    
    /** private変数 */
    // 定数
    private Integer initSearchIndexLimit;   // 初期検索 明細限界
    private Integer normalSearchIndexLimit; // 通常検索 明細限界
    
    //コンストラクタ
    public GA106001Controller() {
        try{
            
            // 店舗異動情報の取得（画面操作権限の確認）
            CommonUtil.getStaffCurrentShop();
            
            // 初期化
            init();
            
            // 初期検索
            searchMail(initSearchIndexLimit);

        } catch(Exception e) {
            // エラー設定
            isOpenError = true;
            CommonUtil.setErrorMessage(e);
        }

    }

    // 検索ボタン処理
    public void search() {
        try{
            // エラーフラグ初期化
            hasErrorMessage = false;
            
            // 通常検索
            searchMail(normalSearchIndexLimit);

        }catch(Exception e){
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    
    // 選択ボタン処理
    public void selectItem() {
        try{
            // エラーフラグ初期化
            hasErrorMessage = false;
            

            // Idを元にSELECTを実行(明細にBody__cを持たせるとビューステートが厳しいため)
            selectedEchoMail = [SELECT Id, SpecifiedMailFolder__c, FromEmail__c, Email__c, Subject__c, Body__c, InquiryDateTime__c
            FROM EchoMail__c WHERE ID = :selectedEchoMailId];

            // 添付ファイル名設定
            setAttachmentName();

        }catch(Exception e){
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // 添付ファイル取得
    public void downloadFile() {
        try{
            // エラーフラグ初期化
            hasErrorMessage = false;

            // 添付ファイルId取得
            setAttachmentId();


        } catch (Exception e) {
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    
    //************************************************************************** privateメソッド *************************************************************
    
    // 初期化
    private void init() {
        
        // 選択リスト
        setSelectFolderList(); 
        
        // 変数初期化
        receivedDate = null;
        folderName = '';
        fromAddress = '';
        toAddress = '';
        subject = '';
        hasAttachment = false;
        
        // システム設定から取得
        initSearchIndexLimit   = Integer.valueOf(SystemConfig__c.getInstance().SpecifiedMail_InitSearchMaxCount__c);
        normalSearchIndexLimit = Integer.valueOf(SystemConfig__c.getInstance().SpecifiedMail_NormalSearchMaxCount__c);
        
        // エラーメッセージフラグ初期化
        hasErrorMessage = false;
        isOpenError = false;
    }

    // フォルダ選択リスト設定
    private void setSelectFolderList() {

        // フォルダをグルーピングして取得
        List<AggregateResult> aList = [SELECT FOlder__c FROM SpecifiedMailSetting__c GROUP BY Folder__c ORDER BY Folder__c LIMIT :CommonConst.GOVERNOR_SELECT_LIMIT ];

        // 選択リストを作成
        selectFolderList = new List<SelectOption>();

        // なしを追加
        selectfolderList.add(new SelectOption('', CommonConst.SELECTION_LIST_NULL));

        for (AggregateResult a: aList) {
            String folderName = (String)a.get('Folder__c');
            selectFolderList.add(new SelectOption(folderName, folderName));
        }
    }

    
    // 検索処理
    private void searchMail(Integer indexLimit) {
            
            // SQL用変数作成
            Date receivedDateForSearch = receivedDate;
            String folderNameString    = folderName;
            String fromAddressString   = '%'+ CommonUtil.convertDisableWildcard(fromAddress) + '%';
            String toAddressString     = '%'+ CommonUtil.convertDisableWildcard(toAddress)   + '%';
            String subjectString       = '%'+ CommonUtil.convertDisableWildcard(subject)     + '%';
            
            // 検索SQL作成
            String sql = '';
            sql += 'SELECT  Id'; 
            sql += '      , SpecifiedMailFolder__c';      // 指定メールフォルダ
            sql += '      , FromEmail__c';                // 送信元
            sql += '      , Email__c';                    // 宛先
            sql += '      , Subject__c';                  // 件名
            sql += '      , InquiryDateTime__c';          // 受信日（作成日）
            sql += '  FROM EchoMail__c';
            sql += ' WHERE     isSpecifiedMail__c = true'; //指定メールに限る
            
            //検索条件　受信日
            if (receivedDateForSearch != null){
                sql += '   AND DAY_ONLY(InquiryDateTime__c) = :receivedDateForSearch'; 
            }
            //検索条件　フォルダ
            if (!String.isEmpty(folderName)){
                sql += '   AND SpecifiedMailFolder__c = :folderNameString'; 
            }
            //検索条件　送信元
            if (!String.isEmpty(fromAddress)){
                sql += '   AND FromEmail__c LIKE :fromAddressString'; 
            }
            //検索条件　宛先
            if (!String.isEmpty(toAddress)){
                sql += '   AND Email__c LIKE :toAddressString'; 
            }
            //検索条件　件名
            if (!String.isEmpty(subject)){
                sql += '   AND Subject__c LIKE :subjectString'; 
            }
            sql += ' ORDER BY InquiryDateTime__c DESC';
            sql += ' LIMIT :indexLimit';

            // 検索実行＆結果返却
            List<EchoMail__c> searchResultList = Database.query(sql);
            
            // 検索結果件数チェック
            if (searchResultList.size() == 0) {
                // ビジネスロジックException発行
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_NO_DATA));
                throw ex;
            }
            
            // 検索結果を表示用にコピー
            echoMailList = searchResultList;

            
            // 明細選択を初期化
            selectedEchoMailId = null;
            selectedEchoMail = null;
            hasAttachment = false;
    }

    // 添付ファイル名設定
    private void setAttachmentName() {

        // 添付ファイル取得
        List<Attachment> attachmentList = [SELECT Name  FROM Attachment WHERE ParentId = :selectedEchoMail.Id];

        // 添付ファイルフラグ設定, 添付ファイル名生成
        if (attachmentList.isEmpty()) {
            hasAttachment = false;
        } else {
            hasAttachment = true;

            //添付ファイル名生成
            List<String> nameList = new List<String>();
            for (Attachment a: attachmentList) {
                nameList.add(a.Name);
            }
            attachmentName = String.join(nameList, ',');
        }
    }

    // 添付ファイルId設定 (直前に取得するため、Nameの取得とタイミングを分割)
    private void setAttachmentId() {

        // 添付ファイル取得
        List<Attachment> attachmentList = [SELECT Id FROM Attachment WHERE ParentId = :selectedEchoMail.Id];

        // データがない場合はエラー
        if (attachmentList.size() == 0) {
            BusinessLogicException b = new BusinessLogicException();
            b.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_NO_DATA));
            throw b;
        }

        //添付ファイルId生成
        List<String> idList = new List<String>();
        for (Attachment a: attachmentList) {
            idList.add(a.Id);
        }
        attachmentId = String.join(idList, ',');
    }

}