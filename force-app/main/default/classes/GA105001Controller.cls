/**
*  お客様紐づけ_お客様情報検索のコントローラ
*/
public inherited sharing class GA105001Controller {
    
    //******************************************************************** public変数 ********************************************************************

    // TRUE:検索モード FALSE:紐づけモード
    public Boolean isSearch{ get; set; }

    //受け取るパラメータ
    public Id correspondId{ get; set; }//対応Id 

    //渡すパラメータ
    public String mail{ get; set; }//対応メール
    
    //対応内容セクション表示内容(お客様紐づけモード時のみ表示)
    public CorrespondDetail__c targetCorrespondDetail{ get; set; }//対応

    //お客様情報検索セクション表示内容:入力項目
    public String searchAccountRecordType{ get; set; }//検索モード名（顧客or業者）
    public String searchResultAccountRecordType{ get; set; }//前回検索時の使用検索モード名（顧客or業者）
    public Boolean searchNoVisitShopChecked { get; set; } //来店担当店舗設定なしチェックボックス
    public String searchEchoShop{ get; set; }//反響担当店舗
    public String searchEchoStaff{ get; set; }//反響担当者
    public String searchVisitShop{ get; set; }//来店担当店舗
    public String searchShopStaff{ get; set; }//来店担当者
    public String searchAccountName{ get; set; }//お客様名/業者名
    public String searchEmail{ get; set; }//メール
    public String searchPhone{ get; set; }//電話番号
    public String searchComment{ get; set; }//コメント
    public List<SelectOption> selectShopList{ get; set; }//店舗選択リスト
    private Boolean isOpetionPortal { get; set; } // 自社ポータル権限
    
    //お客様情報検索セクション表示内容:各ステータスボタン
    public Map<string,Boolean> statusCheckedMap { get; set; }//ステータスチェック状態map
    public List<String> statusNameList{ get; set; }//ステータス名List

    //明細
    public List<searchAccountDetail> searchAccountDetailDisplayList { get; set; } //お客様リスト
    public Integer searchAccountDetailDisplayListCount { get; set; } //お客様リスト件数
    public String newVisitUrl{ get; set; }// 新規来店時URL
    public searchAccountDetail checkedSearchAccountDetail{ get; set; }//紐付け先の取引先
    
    // 表示用メッセージ 
    public String MSG_CUST_V_EXECUTE_CUSTOMER_LINKING {get{return CommonUtil.callMessageCreate(CommonConst.MSG_CUST_V_EXECUTE_CUSTOMER_LINKING);} private set;}    //js用保存確認メッセージ
    public String MSG_CUST_V_EXECUTE_CLIENT_LINKING {get{return CommonUtil.callMessageCreate(CommonConst.MSG_CUST_V_EXECUTE_CLIENT_LINKING);} private set;}    //js用保存確認メッセージ
    public String MSG_COM_I_MERGE_END_SENDSTOP { get { return CommonUtil.callMessageCreate(CommonConst_ptl.MSG_COM_I_MERGE_END_SENDSTOP); } private set; } //js用紹介メール情報削除メッセージ  //問合せNo0429で追加

    public Boolean isDeleteIntroMail { get; set; }//紹介メール情報削除メッセージフラグ  //問合せNo0429で追加
    
    //明細のソート機能  
    public List<String> sortIconStyle { get; set; }//明細のソート状況
    public Integer presseColumn{ get; set; }//明細のソート対象列
    public final String UP = 'up';
    public final String DOWN = 'down';
    public final String NONE = 'none';
    
    // ステータス ※タブレット用に短縮表示
    private final String CORRESPOND_STATUS_APOCANCEL_SHORT = 'アポキャンセル';  // アポイントキャンセル

    // エラーフラグ
    public Boolean isOpenError { get; set; }// エラーフラグ  
    public Boolean hasErrorMessage { get; set; } // エラーメッセージ保有フラグ   
    
    // 2020/7/6追加：ページング関連
    private Integer accountPageDisplayNumber = Integer.valueOf(SystemConfig__c.getInstance().AccountSearchDisplayMaxCount__c);  // 取引先の表示上限（１ページ）
    private List<Account> accountIdList { get; set; }               // 取引先の全IdList
    public List<SelectOption> accountPageingList { get; set; } // 取引先のページ選択用リスト
    public Integer accountPageCount { get; set; }              // 取引先のページ数
    public String selectAccountPageIndex { get; set; }         // 取引先のリスト選択中ページ番号（選択リストの値）
    private Integer currentAccountPageIndex { get; set; }      // 取引先の表示中ページ番号
    private List<Id> targetAccountIdList ;                     // 選択ページのIdリスト

    //******************************************************************** private変数 ********************************************************************
    //設定
    private Integer searchLimit; //検索上限
    
    //明細のソート機能
    private final Integer NumberOfColumns = 11;//明細の項目数

    //2020/5/25追加
    private Correspond__c targetCorrespond;//対象対応レコード
    private List<String> statusList;//対応の有効なステータスリスト

    private Boolean searchResultNoVisitShopChecked; //検索ボタン押下時の「来店担当店舗 設定なし」の値保持用
    private String searchResultEchoShop;            //反響担当店舗の値保持用
    private String searchResultEchoStaff;           //反響担当者の値保持用
    private String searchResultVisitShop;           //来店担当店舗の値保持用
    private String searchResultShopStaff;           //来店担当者の値保持用
    //2020/7/6変更：クラス変数に変更
    private List<String> statusSearchList;//検索時のステータスリスト

    private String memberId;

    //*********************************************************  publicメソッド  ************************************************************
    
    //コンストラクタ
    public GA105001Controller() {
        try{
            //初期化            
            init();
            //店舗異動が取得できなければエラー
            CommonUtil.getStaffCurrentShop();
            
            //パラメータ(対応Id)取得
            String paramId = ApexPages.currentPage().getParameters().get('Id');
            if (paramId instanceof Id) {
                this.correspondId = paramId;
            }

            //レコード情報取得
            this.isOpetionPortal = AuthorityCheckUtil.getAuthorityOptionPortal(false);         //自社ポータル権限を取得
            
            //お客様紐づけモード/検索モード設定
            if(String.isNotBlank(paramId)){
                
                isSearch = FALSE;
                
            }else{
                
                isSearch = TRUE;
            }
            
            //対応明細設定
            if(!isSearch){
                //お客様紐づけモードの場合対応明細設定
                List<CorrespondDetail__c> targetCorrespondDetailList = [SELECT Id
                                             ,CorrespondType__c//対応種別
                                             ,Email__c//メール
                                             ,SupportedDateTime__c//対応日時
                                             ,SupportedTitle__c//対応表題(メール件名)
                                             ,SupportedContent__c//対応内容(メール本文)
                                             ,Corresponds__r.systemModstamp//対応最終更新日時
                                             ,EchoMail__r.MemberID__c//反響メールの会員ID
                                             ,EchoMail__r.Phone__c//反響メールの電話番号
                                             ,EchoMail__r.FromPotalSite__c//反響メールのFROMポータルサイト
                                             FROM CorrespondDetail__c
                                             WHERE Corresponds__c = :correspondId//対応番号=対応Id
                                             ORDER BY SupportedDateTime__c DESC//対応日時(降順)
                                             LIMIT 1
                                            ];		
                
                //レコード情報が取得できなければビジネスロジックException発行
                if(targetCorrespondDetailList.isEmpty()) {
                    BusinessLogicException ex = new BusinessLogicException();
                    ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
                    throw ex;
                }


                //対応明細設定
                targetCorrespondDetail = targetCorrespondDetailList[0];
                this.mail = targetCorrespondDetail.Email__c;

            }
            //2020/5/25追加：パラメータの対応Idから対象対応の取得
            List<Correspond__c> targetCorrespondList = [SELECT id,District__c 
                                                    FROM Correspond__c
                                                    WHERE id = :correspondId];
            If (targetCorrespondList.size() != 0){
                this.targetCorrespond = targetCorrespondList[0];
            }                 
            //2020/5/25追加：対象となる有効ステータスの格納
            statusList = new List<String>();
            statusList.add(CommonConst.CORRESPOND_STATUS_NOTSUPPORTED); // 未対応
            statusList.add(CommonConst.CORRESPOND_STATUS_PURSUIT); // 追客中
            statusList.add(CommonConst.CORRESPOND_STATUS_APPOINTMENT); // アポイント確定
            statusList.add(CommonConst.CORRESPOND_STATUS_VISITED); // 来店済
            statusList.add(CommonConst.CORRESPOND_STATUS_CONSIDERVISITING); // 来店後検討
            statusList.add(CommonConst.CORRESPOND_STATUS_UNEARNED); // 未収入金
            statusList.add(CommonConst.CORRESPOND_STATUS_DEPOSIT); // 入金済
            statusList.add(CommonConst.CORRESPOND_STATUS_PURSUITHOLD); // 追客保留中
            statusList.add(CommonConst.CORRESPOND_STATUS_APOCANCEL); // アポイントキャンセル
            statusList.add(CommonConst.CORRESPOND_STATUS_APOCANCEL_PURSUIT); // アポキャンセル後追客中
            statusList.add(CommonConst.CORRESPOND_STATUS_VISITED_PURSUIT); // 来店後追客中
            statusList.add(CommonConst.CORRESPOND_STATUS_APPLCANCEL); // 申込キャンセル
            statusList.add(CommonConst.CORRESPOND_STATUS_APPLCANCEL_PURSUIT); // 申込キャンセル後追客中                       

            //新規入店用URL作成
            createNewVisitUrl();

        }catch(Exception e){//エラーを設定
            isOpenError = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    

    //2020/7/6追加：表示ページ選択処理（ページング）
    public void selectAccountPage() {
        
        // 選択ページのインデックス取得
        Integer selectIndex = Integer.valueOf(this.selectAccountPageIndex);
        
        // ページ更新
        setPageData(selectIndex);
    }

    //検索モード名ラジオボタン設定
    public List<SelectOption> getSearchAccountRecordTypeRadioButton(){
        List<SelectOption> options = new List<SelectOption>();//ラジオボタン初期化

        //ラジオボタン設定
        options.add(new SelectOption('顧客', '顧客'));
        options.add(new SelectOption('業者', '業者'));

        return options;
    }
    
    
    
    //検索
    public void searchAccount(){
        
        try{
            hasErrorMessage = FALSE;//エラーを初期化
            
            BusinessLogicException ex = new BusinessLogicException();//ビジネスロジックException準備
            
            //ステータスによる検索条件設定
            Boolean isStatusAllFalse = TRUE;
            
            if(searchAccountRecordType == '顧客'){//業者の場合検索条件に含まれない
                for( String statusName : statusNameList){
                    //全ステータスを確認し、ステータスによる検索条件設定を確認する
                    if(this.statusCheckedMap.get(statusName)){
                        isStatusAllFalse = FALSE;
                    }
                }
            }
            
            if(isStatusAllFalse
               && String.isEmpty(searchEchoShop)//反響担当店舗
               && String.isEmpty(searchEchoStaff)//反響担当者
               && String.isEmpty(searchVisitShop)//来店担当店舗
               && String.isEmpty(searchShopStaff)//来店担当者
               && String.isEmpty(searchAccountName)//お客様名/業者名
               && String.isEmpty(searchEmail)//メール
               && String.isEmpty(searchPhone)//電話番号
               && String.isEmpty(searchComment)//コメント
              ){
                  //検索条件を入力してください。
                  ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_NO_CONDITIONS ));
                  throw ex;
              }
            
            
            //検索用項目宣言
            Boolean isSearchCorrespond = FALSE;
            //バインド変数用テキスト
            String searchAccountNameText = '%'+ CommonUtil.convertDisableWildcard(searchAccountName.deleteWhitespace()) + '%';//名前からは空白文字を取り除く
            String searchCommentText     = '%'+ CommonUtil.convertDisableWildcard(searchComment)     + '%';
            String searchEmailText       = '%'+ CommonUtil.convertDisableWildcard(searchEmail)       + '%';
            String searchPhoneText       = '%'+ CommonUtil.convertDisableWildcard(searchPhone)       + '%';
            //対応の検索条件を保持
            this.searchResultNoVisitShopChecked = searchNoVisitShopChecked;//クラス変数に来店担当店舗 設定なしの値を保持
            this.searchResultEchoShop    = searchEchoShop;
            this.searchResultEchoStaff   = searchEchoStaff;
            this.searchResultVisitShop   = searchVisitShop;
            this.searchResultShopStaff   = searchShopStaff;

            if(isStatusAllFalse == FALSE
               || String.isNotEmpty(searchEchoShop)//反響担当店舗
               || String.isNotEmpty(searchEchoStaff)//反響担当者
               || String.isNotEmpty(searchVisitShop)//来店担当店舗
               || String.isNotEmpty(searchShopStaff)//来店担当者
               || searchNoVisitShopChecked//来店担当店舗設定なしがチェックされている
              ){
                  //対応ありの取引先を条件に設定
                  isSearchCorrespond = TRUE;
              }
              
            //ステータスリストの作成
            statusSearchList = new List<String>();
            for( String statusName : statusNameList){
                //ステータス名Listの長さだけ繰り返し、チェックされたステータスを取得する
                if(this.statusCheckedMap.get(statusName)){
                    if (statusName == CORRESPOND_STATUS_APOCANCEL_SHORT) {
                        statusSearchList.add(CommonConst.CORRESPOND_STATUS_APOCANCEL);

                    //2020/6/10追加：追客中選択時、以下のステータスも検索条件に追加
                    } else if (statusName == CommonConst.CORRESPOND_STATUS_PURSUIT){
                        statusSearchList.add(CommonConst.CORRESPOND_STATUS_PURSUIT);            //追客中
                        statusSearchList.add(CommonConst.CORRESPOND_STATUS_APOCANCEL_PURSUIT);  //アポキャンセル後追客
                        statusSearchList.add(CommonConst.CORRESPOND_STATUS_VISITED_PURSUIT);    //来店後追客
                        statusSearchList.add(CommonConst.CORRESPOND_STATUS_APPLCANCEL_PURSUIT); //申込キャンセル後追客

                    } else {
                        statusSearchList.add(statusName);
                    }
                }
            }
            
            //検索
            String sql = '';
            
            sql += 'SELECT';
            sql += ' Id';//Id

            //取得オブジェクト
            sql += '  FROM Account';//取引先
            
            //取得条件
            
            sql += ' WHERE ';
            
            //検索モード名（顧客or業者）によって取得条件を変更
            if(searchAccountRecordType == '顧客'){
                //レコードタイプ／取引先:顧客
                sql += '  RecordTypeId	 =\'' + CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_CUSTOMER) +'\'';
            }else if(searchAccountRecordType == '業者'){
                //レコードタイプ／取引先:管理会社・オーナー・サブリース,火災保険会社,保証会社,付帯業者
                sql += '  RecordTypeId	 IN(';
                sql += '\''  + CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_SUPPLIER) +'\'';
                sql += ',\'' + CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_FIRE_INSURANCE) +'\'';
                sql += ',\'' + CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_GUARANTEE) +'\'';
                sql += ',\'' + CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_AUXILIARY) +'\'';
                sql += ')';
            }
            
            //お客様名に入力がある場合
            //取引先名
            //取引先名（カナ）		
            if(!String.isEmpty(searchAccountName)){//お客様名/業者名
                sql += ' AND ';
                sql += ' ( ';
                sql +=  'NAME  LIKE :searchAccountNameText ';
                sql += ' OR ';
                sql +=  'NameKana__c  LIKE :searchAccountNameText ';
                sql += ' ) ';
            }
            
            
            //メールに入力がある場合
            //メール
            //メール２
            //メール３	
            if(!String.isEmpty(searchEmail)){//お客様名/業者名
                sql += ' AND ';
                sql += ' ( ';
                sql +=  'Email__c  LIKE :searchEmailText ';
                sql += ' OR ';
                sql +=  'Email2__c  LIKE :searchEmailText ';
                sql += ' OR ';
                sql +=  'Email3__c  LIKE :searchEmailText ';
                sql += ' ) ';
            }
            
            //電話番号に入力がある場合
            //電話番号
            //電話番号２
            //電話番号３			
            if(!String.isEmpty(searchPhone)){//お客様名/業者名
                sql += ' AND ';
                sql += ' ( ';
                sql +=  'Phone  LIKE :searchPhoneText ';
                sql += ' OR ';
                sql +=  'Phone2__c  LIKE :searchPhoneText ';
                sql += ' OR ';
                sql +=  'Phone3__c  LIKE :searchPhoneText ';
                sql += ' ) ';
            }
            
            
            //コメントに入力がある場合
            //コメント			
            if(!String.isEmpty(searchComment)){//お客様名/業者名
                sql += ' AND ';
                sql +=  'Comment__c  LIKE :searchCommentText ';
            }
            
            if(isSearchCorrespond){
                
                sql += ' AND ';
                sql +=  'ID IN ( SELECT AccountId__c FROM Correspond__c ';
                sql +=   createCorrespondSOQL();  //対応の条件
                sql += ' ) ';
            }
            
            //取得順序
            sql += ' ORDER BY';
            sql += '       Name ASC'; //取引先名(昇順)
            
            //取得数
            sql += ' LIMIT :searchLimit';


            //クエリ実行
            List<Account> searchResult = Database.query(sql);
            
            //絞る機能はなくなりました。対応がないものも表示します。

            //2020/7/6追加：エラーがない場合、取得した取引先Id全件をaccountIdListに代入
            accountIdList = searchResult;
            
            //検索結果表示
            searchAccountDetailDisplayList = new List<searchAccountDetail>();
            searchAccountDetailDisplayListCount = 0;

            searchResultAccountRecordType = searchAccountRecordType;//検索に使用した検索モードを保持

            searchPageSetting();

            //2020/7/6追加：現在のページ（0ページ目）の取引先の項目、対応Mapを設定し、ページ表示用のListを設定する。
            selectAccountPage();

            searchAccountDetailDisplayListCount = searchAccountDetailDisplayList.size();
            
            sortReset();//明細のソート状態初期化
            
        }catch(Exception e){
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }
    
    //お客様紐づけ
    public void accountLink(){
        Savepoint sp = Database.setSavepoint();      //セーブポイント作成
        try{
            hasErrorMessage = FALSE;//エラーを初期化
            
            //紐づけ先取引先の取得
            for(searchAccountDetail inSearchAccountDetail : searchAccountDetailDisplayList){
                if(inSearchAccountDetail.isCheckbox){
                    checkedSearchAccountDetail = inSearchAccountDetail;
                }
            }
            if(String.isEmpty(checkedSearchAccountDetail.Id)){
                BusinessLogicException ex = new BusinessLogicException();//ビジネスロジックException準備
                 
                List<Object> parameters = new List<Object> {'紐付けを行う場合', '紐付け先'};
                    
                ex.addMessage(String.format(CommonConst.MSG_COM_W_SELECTION, parameters));
                
                throw ex;
            }
            
            // 入力チェック
            BusinessLogicException contactEx = new BusinessLogicException();
            contactEx = this.checkInput(contactEx);

            // 入力チェック結果にエラーがある場合、例外をスローさせる
            if (contactEx.hasMessage()){         
                throw contactEx;
            }
                    
            //お客様紐づけ(対応作成)
            //保存用対応作成
            Correspond__c upCorrespond = new Correspond__c();
            
            upCorrespond.Id = correspondId;
            upCorrespond.AccountId__c = checkedSearchAccountDetail.Id;
            
            //業者紐づけの場合、ステータスは「終了」とする。
            if (searchResultAccountRecordType == '業者') {
                upCorrespond.Status__c              = CommonConst.CORRESPOND_STATUS_CLOSE;              // ステータス
                upCorrespond.StaffSupportedFlg__c   = true;                                             // スタッフ対応フラグ
                upCorrespond.IsSupportedListShow__c = true;                                             // 対応確認フラグ
                upCorrespond.IsBrowseFlg__c         = false;                                            // 閲覧フラグ
                upCorrespond.ListViewDate__c        = Datetime.newInstance(2999, 12, 31, 23, 59, 0);    // 一覧表示日時
            }
            
            //対応の楽観ロックチェック        
            List<Correspond__c> checkOptimisticLockExceptionRecord = new List<Correspond__c>();
            
            checkOptimisticLockExceptionRecord = [ SELECT id
                                                  FROM Correspond__c
                                                  WHERE id = :correspondId
                                                  AND SystemModStamp = :targetCorrespondDetail.Corresponds__r.systemModstamp ];
            
            //データ取得できない場合、楽観ロックチェックExceptionを発行
            if (checkOptimisticLockExceptionRecord.isEmpty()){
                OptimisticLockException optimisticLockex = new OptimisticLockException();
                throw optimisticLockex;
            }
            
            SecureDML.secureUpdate(upCorrespond); //お客様紐づけ(対応作成)

            //お客様紐づけ（本会員の更新）2020.10.30

            if(isOpetionPortal && !String.isBlank(targetCorrespondDetail.EchoMail__r.MemberID__c)){        //ポータル権限がある、かつ、反響メールの会員IDに値がある場合
                List<Member__c> echoMember = [SELECT id,MemberId__c,Email__c,Tell__c,QuitDate__c,BlackList__c,MemberStatus__c 
                FROM Member__c WHERE MemberId__c = :targetCorrespondDetail.EchoMail__r.MemberID__c];      //targetCorrespondDetail.EchoMail__r.MemberID__cから差分に必要なデータを取ってきてリストに入れる

                if (!echoMember.isEmpty()){      //リストにデータが取ってこれているか

                    List<MemberDifference__c> insertMemDiffList = new List<MemberDifference__c>();						//insert用本会員差分宣言
        
                    echoMember[0].Account__c = checkedSearchAccountDetail.Id;	//リスト内の本会員の取引先変更
                    SecureDML.secureUpdate(echoMember);

                    //ここから差分作成
                        MemberDifference__c memDiff = new MemberDifference__c(				//本会員差分の作成
                            CrudCd__c = 'U'               //クラッドコード
                            ,LinkCd__c = 'StoH'            //連携コード
                            ,MemberId__c = echoMember[0].MemberId__c //会員ID
                            ,Email__c = PortalUtil.encryption(echoMember[0].Email__c)        //メールアドレス（暗号化）
                            ,Tell__c  = PortalUtil.encryption(echoMember[0].Tell__c)         //電話番号（暗号化）
                            ,Account__c = checkedSearchAccountDetail.Id    //取引先
                            ,QuitDate__c = echoMember[0].QuitDate__c      //退会日
                            ,Blacklist__c = echoMember[0].BlackList__c     //ブラックリスト
                            ,MemberStatus__c = echoMember[0].MemberStatus__c      //会員状況
                            
                            );
    
                        SecureDML.secureInsert(memDiff); 
                }
            }

            //▼問合せNo0429で追加
            // お客様紐づけ（紹介メール情報削除）
            if(isOpetionPortal && String.isNotBlank(checkedSearchAccountDetail.introductionMailInformationId)){
                //メール受信した顧客の自動追客を解除
                //見紐づけの対応はメール受信でしかできない前提
                IntroductionMailInformation__c deleteIntroductionMailInformation = new IntroductionMailInformation__c();
                deleteIntroductionMailInformation.id = checkedSearchAccountDetail.introductionMailInformationId;
                SecureDML.secureDelete(deleteIntroductionMailInformation);
                this.isDeleteIntroMail = true ; // 削除メッセージを表示させるようにする
            }
            //▲問合せNo0429で追加

            //お客様紐づけ(お客様更新)
            //▼問合せNo0429で変更
            Account upAccount = checkedSearchAccountDetail.serchAccountRecord;
            Boolean isAccountUpdateFlg = false; //取引先更新フラグ
            Boolean isMergeCheckFlg = false; //名寄せ確認実行フラグ

            //名寄せ先の取引先にメールアドレスが登録済みでない場合
            if(!checkedSearchAccountDetail.isMailUpdateUnneededFlag){ 
                setAccountMail(upAccount,checkedSearchAccountDetail,targetCorrespondDetail, searchAccountRecordType);
                isAccountUpdateFlg = true;
                isMergeCheckFlg = true;             
            }

            //名寄せ先の取引先に電話番号が登録済みでない場合
            if(!checkedSearchAccountDetail.isPhoneUpdateUnneededFlag){ 
                setAccountPhone(upAccount,checkedSearchAccountDetail,targetCorrespondDetail, searchAccountRecordType);
                isAccountUpdateFlg = true;
                isMergeCheckFlg = true;     
            }

            if(String.isNotBlank(targetCorrespondDetail.Email__c)){
            // 紹介メール情報の削除で配信停止に設定する
                if (isOpetionPortal && this.isDeleteIntroMail){
                    upAccount.IntroMailInfoStatus__c = CommonConst_ptl.INTRODUCTION_SENDSTOP;//配信状況を配信停止に変更  
                    isAccountUpdateFlg = true;
                }
            }

            //取引先の楽観ロックチェック
            AccountoptimisticLockCheck(upAccount);

            //取引先の名寄せ確認
            if(isMergeCheckFlg){
                mergeAccount(upAccount, searchAccountRecordType);
            }

            //お客様紐づけ(取引先更新)
            if(isAccountUpdateFlg){
                SecureDML.secureUpdate(upAccount);
            }
            
            //▲問合せNo0429で変更
            
        }catch(Exception e){
            hasErrorMessage = true;//エラーを設定
            Database.rollback(sp);//処理をロールバック
            CommonUtil.setErrorMessage(e);
        }
    }
    
    //新規来店ボタン
    public void createNewVisitUrl(){
        
        //【Salesforceのドメイン】/?un=【ログインユーザ名】&startURL=/apex/GA202001View?userId=【ログインユーザのId】
        newVisitUrl = URL.getSalesforceBaseUrl().toExternalForm();
        newVisitUrl += '/?un=';
        newVisitUrl += UserInfo.getUserName();
        newVisitUrl += '&startURL=';

        //「startURL=」以降の文字列をurlEncode
        String startURLString = '/apex/GA202001View?';
        startURLString += 'userId=';
        startURLString += UserInfo.getUserId();

        newVisitUrl += EncodingUtil.urlEncode(startURLString, 'UTF-8');
        system.debug(newVisitUrl);

    }

    //*********************************************************  privateメソッド  ************************************************************

    //初期化
    private void init(){

        //対応明細メール初期化
        this.mail = '';


        //店舗選択リスト設定
        this.selectShopList = new List<SelectOption>();//店舗選択リスト初期化
        for(SelectOption inShopSelectedOption : CommonUtil.getShopSelectedOptionFromStaffId (null, TRUE)){//店舗取得
            
            if(inShopSelectedOption.getLabel() != CommonConst.SELECTION_LIST_NULL){//店舗SelectOptionのValue値設定
                inShopSelectedOption.setValue(inShopSelectedOption.getLabel());
            }
            
            this.selectShopList.add(inShopSelectedOption);//店舗選択リストに店舗を追加
        }
        
        //検索モード名を顧客に設定
        this.searchAccountRecordType = '顧客';  
        this.searchResultAccountRecordType  = '顧客';  
        
        //ステータスを設定
        statusNameList = new List<String>();//ステータス名List初期化
        statusCheckedMap = new Map<string,Boolean>();//ステータスチェック状態List初期化

        // 来店担当店舗 設定なしはチェックを外した状態を初期値
        this.searchNoVisitShopChecked = false;
        
        setStatusList();//ステータスを設定
        
        //お客様明細初期化
        searchAccountDetailDisplayList = new List<searchAccountDetail>();
        searchAccountDetailDisplayListCount = 0;

        // 検索上限取得
        searchLimit = Integer.valueOf(SystemConfig__c.getInstance().AccountSearchMaxCount__c);

        //紐付け先の取引先初期化
        this.checkedSearchAccountDetail = new searchAccountDetail();
        
        //明細のソート機能
        presseColumn = 0;//明細のソート列
        sortReset();//明細のソート状態初期化

        //2020/7/6追加：ページング関連初期化
        this.accountPageingList = new List<SelectOption>();
        this.selectaccountPageIndex = '0';
        this.currentaccountPageIndex = 0;
        this.accountPageCount = 0;
        this.targetAccountIdList = new List<Id>();
        this.AccountIdList = new List<Account>();

        this.isDeleteIntroMail = false; //問合せNo0429で追加
        
    }
    
    //明細のソート初期化
    private void sortReset(){
        
        //明細のソート作成
        sortIconStyle = new List<String>();

        //明細のソート初期化
        for(Integer i = 0 ; i < this.NumberOfColumns ; i++){
            sortIconStyle.add(this.NONE);
        }
        
        sortIconStyle[0] = this.UP;//明細のソートを1つめの明細の昇順に設定
    }
    
    //ステータスList設定
    private void setStatusList(){
        
        this.statusNameList.add(CommonConst.CORRESPOND_STATUS_NOTSUPPORTED);        // 未対応
        this.statusNameList.add(CommonConst.CORRESPOND_STATUS_PURSUIT);             // 追客中
        this.statusNameList.add(CommonConst.CORRESPOND_STATUS_PURSUITHOLD);         // 追客保留中
        this.statusNameList.add(CommonConst.CORRESPOND_STATUS_APPOINTMENT);         // アポイント確定
        this.statusNameList.add(CORRESPOND_STATUS_APOCANCEL_SHORT);                 // アポイントキャンセル
        this.statusNameList.add(CommonConst.CORRESPOND_STATUS_VISITED);             // 来店済
        this.statusNameList.add(CommonConst.CORRESPOND_STATUS_CONSIDERVISITING);    // 来店後検討
        this.statusNameList.add(CommonConst.CORRESPOND_STATUS_UNEARNED);            // 未収入金
        this.statusNameList.add(CommonConst.CORRESPOND_STATUS_DEPOSIT);             // 入金済
        this.statusNameList.add(CommonConst.CORRESPOND_STATUS_APPLCANCEL);          // 申込キャンセル
        this.statusNameList.add(CommonConst.CORRESPOND_STATUS_AGREEMENT);           // 契約完了
        this.statusNameList.add(CommonConst.CORRESPOND_STATUS_CLOSE);               // 終了
        
        for( String statusName : statusNameList){
            //ステータス名Listの長さだけ繰り返し、全ステータスの状態をfalseに設定する（初期選択なしとする）
            this.statusCheckedMap.put(statusName, false);
        }


    }

    //2020/7/6追加：ページ数初期設定（検索ボタン押下でデータ取得後時）
    private void searchPageSetting(){
        //ページ数設定
        this.accountPageCount = 0;
        if (this.accountPageDisplayNumber > 0) {
            this.accountPageCount = Integer.valueOf(Math.ceil(Double.valueOf(this.accountIdList.size()) / Double.valueOf(this.accountPageDisplayNumber)));
        }
        
        // ページ選択用のリストを作成
        this.accountPageingList = new List<SelectOption>();
        Integer i = 0;
        for (i = 0; i < this.accountPageCount; i++) {
            String label = '';
            label += (i * this.accountPageDisplayNumber + 1) + '～';
            label += this.accountIdList.size() < (i + 1) * this.accountPageDisplayNumber
                    ? this.accountIdList.size() : (i + 1) * this.accountPageDisplayNumber;
            label += '件目';
            SelectOption item = new SelectOption(String.valueOf(i), label);
            this.accountPageingList.add(item);
        }
        
        // ページ選択初期化
        this.selectAccountPageIndex = '0';
        // 現在ページ初期化
        this.currentAccountPageIndex = 0;
    }

    // 2020/7/6追加：ページ情報更新
    private void setPageData(Integer selectIndex) {
        try {

            // 選択ページのデータ開始位置インデックス取得
            Integer startIndex = selectIndex * this.accountPageDisplayNumber;
            
            // 選択したページの表示レコードのIdをtargetidListに追加
            this.targetAccountIdList = new List<Id>();
            for(Integer i = 0; i < this.accountPageDisplayNumber; i++) {
                if (this.AccountIdList.size() == startIndex + i) {
                    break;
                }
                this.targetAccountIdList.add(this.AccountIdList[startIndex + i].Id);
            }
            //取得したtargetIdリストで取引先を取得する
            List<Account> targetAccountList = selectPageChangeAccount();

            //取引先タイプが顧客のときのみ、対応を取得
            Map<Id, Correspond__c> correspondMap = new Map<Id, Correspond__c>();
            if (searchResultAccountRecordType == '顧客'){
                correspondMap = selectCorrespondChangePage(targetAccountList);
            }

            //画面表示用の画面取引先リストを初期化し、作成した内部クラスを新たにリストに追加
            searchAccountDetailDisplayList = new List<searchAccountDetail>();
            for (Account account: targetAccountList) {
                searchAccountDetailDisplayList.add(new searchAccountDetail(account, searchResultAccountRecordType, correspondMap));
            }
            
            // 現在表示ページの更新
            this.currentAccountPageIndex = selectIndex;
            
            
        } catch(Exception e) {
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
            throw e;
        }
    }

    //2020/7/6追加：ページ変更の取引先取得
    private List<Account> selectPageChangeAccount(){
            String sql = 'SELECT';
            sql += ' Id';//Id
            sql += ',Name';//取引先名
            sql += ',Phone';//電話番号
            sql += ',Phone2__c';//電話番号2
            sql += ',Phone3__c';//電話番号3
            sql += ',Email__c';//メール1
            sql += ',Email2__c';//メール2
            sql += ',Email3__c';//メール3
            sql += ',IsMergeCompletedFlag__c';//名寄せ完了フラグ
            sql += ',IsMergeUnnecessaryFlag__c';//名寄せ不要フラグ
            sql += ',SystemModstamp';//最終更新日時
            
            //取得項目
            if(searchResultAccountRecordType == '顧客'){
                sql += ',HomeMovingSeason__c';//引越時期
                sql += ',HomeMovingDate__c	';//引越時期（日付）までに
                //▼問合せNo0429で追加
                sql += ',(SELECT id           FROM IntroductionMailInformationAccount__r) '; //紹介メール情報 
                //▲問合せNo0429で追加
                
                sql += ',(SELECT';    
                sql += ' Id';//対応．Id
                sql += ' ,Status__c';//対応．ステータス
                sql += ',Event__c';//対応．イベント
                sql += ',CreatedDate';//対応．作成日
                sql += ',SystemModstamp';//対応．最終更新日
                sql += ',EchoStaff__r.NAME';//対応．担当者（反響）
                sql += ',ShopStaff__r.NAME';//対応．担当者（来店）
                sql += ',Memo__c';//対応．メモ
                sql += ' FROM CorrespondAccountId__r ';  
                sql +=   createCorrespondSOQL();  //対応の条件取得


            }else{//業者
                sql += ',SupplierType__c';//業者種別
                sql += ',Address__c';//住所
                
                //対応があるかの確認のため取得
                sql += ',(SELECT';    
                sql += ' Id';//対応．Id
                sql += ' FROM CorrespondAccountId__r ';  
            }

            sql += '     ORDER BY';
            sql += '     EventDateTime__c DESC'; //対応．イベント時刻(降順)
            sql += '     LIMIT 1'; //対応．イベント時刻(降順)
            sql +=      ')';
            
            sql += ' FROM Account '; 
            sql += ' WHERE Id IN :targetAccountIdList '; 

            sql += ' ORDER BY Name '; 
            //クエリ実行
            List<Account> searchResult = Database.query(sql);
            return searchResult;
    }

    //2020/7/6追加：対応Map取得
    private Map<Id, Correspond__c> selectCorrespondChangePage(List<Account> AccountList){
        //対応のIDリスト作成
        List<Id> correspondIdList = new List<Id>();
        for (Account acc : AccountList) {
            if (acc.CorrespondAccountId__r.size() > 0){
                correspondIdList.add(acc.CorrespondAccountId__r[0].Id);
            }
        }

        Map<Id, Correspond__c> correspondMap = new Map<Id, Correspond__c>();
        //対応明細の対応日時(最新)を取得し、Mapに格納
        if (correspondIdList.size() > 0){
            //▼再販修正
            correspondMap = new Map<Id, Correspond__c>(
                            [SELECT 
                                Id, 
                                (SELECT SupportedDateTime__c FROM CorrespondDetailCorresponds__r ORDER BY SupportedDateTime__c DESC LIMIT 1) 
                            FROM Correspond__c 
                            WHERE Id in :correspondIdList]);
            //▲再販修正
        }
        return correspondMap;
    }

    /**
     * 入力チェック
     * @param BusinessLogicException contactEx　例外
     * @return BusinessLogicException 例外
     */
    private BusinessLogicException checkInput(BusinessLogicException contactEx) {

        //取引先のメールアドレス、電話番号を更新するか判断する
        String contactError = judgeContactUpdate(checkedSearchAccountDetail, targetCorrespondDetail);  
        
        //紐づけ時、メール、電話番号の登録上限を超過した時エラーを投げる
        if(String.isNotEmpty(contactError)){                
            contactEx.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_CUST_W_EXECUTE_LINKING_MAILADDRESSANDTEL,contactError));             
        }

        return contactEx;   
    }

    /**
     * 取引先のメールアドレス、電話番号を更新するか判断する
     * @param searchAccountDetail linkingAccountDetail　紐づけ先の検索明細
     * @param CorrespondDetail__c linkingTargetCorrespondDetail 紐づけ元の対応明細
     * @return String 例外
     */
    private String judgeContactUpdate(searchAccountDetail linkingAccountDetail, CorrespondDetail__c linkingTargetCorrespondDetail){
        //メールアドレスが空白または登録済みの場合更新不要
        if(linkingTargetCorrespondDetail.Email__c == null
        ||linkingTargetCorrespondDetail.Email__c == linkingAccountDetail.mail1
        ||linkingTargetCorrespondDetail.Email__c == linkingAccountDetail.mail2
        ||linkingTargetCorrespondDetail.Email__c == linkingAccountDetail.mail3){
            linkingAccountDetail.isMailUpdateUnneededFlag = true; 
        }
        
        //反響メールでない、または、電話番号が空白または登録済みの場合更新不要
        if(linkingTargetCorrespondDetail.EchoMail__r.FromPotalSite__c  == null
        ||linkingTargetCorrespondDetail.EchoMail__r.Phone__c == null
        ||linkingTargetCorrespondDetail.EchoMail__r.Phone__c == linkingAccountDetail.phone
        ||linkingTargetCorrespondDetail.EchoMail__r.Phone__c == linkingAccountDetail.phone2
        ||linkingTargetCorrespondDetail.EchoMail__r.Phone__c == linkingAccountDetail.phone3){
            linkingAccountDetail.isPhoneUpdateUnneededFlag = true;
        }
        
        String errorMessage; 
        //メールアドレスが登録済みでないかつメールアドレス1~3が埋まっている場合
        if(!linkingAccountDetail.isMailUpdateUnneededFlag 
        && String.isNotBlank(linkingAccountDetail.mail1) 
        && String.isNotBlank(linkingAccountDetail.mail2) 
        && String.isNotBlank(linkingAccountDetail.mail3)){
            errorMessage = 'メールアドレス';
        }
        //電話番号が登録済みでないかつ電話番号1~3が埋まっている場合
        if(!linkingAccountDetail.isPhoneUpdateUnneededFlag 
        && String.isNotBlank(linkingAccountDetail.phone) 
        && String.isNotBlank(linkingAccountDetail.phone2) 
        && String.isNotBlank(linkingAccountDetail.phone3)){
            errorMessage = String.isBlank(errorMessage) ? '' : errorMessage + 'と';
            errorMessage += '電話番号';
        }
        
        return errorMessage;
    }

    /**
     * 紐づけ先の空項目にメールアドレスを設定。
     * @param Account upAccount 更新したい取引先
     * @param searchAccountDetail linkingAccountDetail 紐づけ先の検索明細
     * @param CorrespondDetail__c linkingTargetCorrespondDetail 紐づけ元の対応明細
     * @param String searchAccountMode 検索モード名（顧客or業者）
     */
    private void setAccountMail(Account upAccount, searchAccountDetail linkingAccountDetail, CorrespondDetail__c linkingTargetCorrespondDetail, String searchAccountMode){

       if(String.isBlank(linkingAccountDetail.mail1)){
            upAccount.Email__c = linkingTargetCorrespondDetail.Email__c;
            
       }else if(String.isBlank(linkingAccountDetail.mail2) && searchAccountMode != '業者'){
            upAccount.Email2__c = linkingTargetCorrespondDetail.Email__c;
           
       }else if(String.isBlank(linkingAccountDetail.mail3) && searchAccountMode != '業者'){
            upAccount.Email3__c = linkingTargetCorrespondDetail.Email__c;
       }
    }

    /**
     * 紐づけ先の空項目に電話番号を設定。
     * @param Account upAccount 更新したい取引先
     * @param searchAccountDetail linkingAccountDetail 紐づけ先の検索明細
     * @param CorrespondDetail__c linkingTargetCorrespondDetail 紐づけ元の対応明細
     * @param String searchAccountMode 検索モード名（顧客or業者）
     */
    private void setAccountPhone(Account upAccount, searchAccountDetail linkingAccountDetail, CorrespondDetail__c linkingTargetCorrespondDetail, String searchAccountMode){

        if(String.isBlank(linkingAccountDetail.phone)){
            upAccount.Phone = linkingTargetCorrespondDetail.EchoMail__r.Phone__c;
            
        }else if(String.isBlank(linkingAccountDetail.phone2) && searchAccountMode != '業者'){
            upAccount.Phone2__c = linkingTargetCorrespondDetail.EchoMail__r.Phone__c;

        }else if(String.isBlank(linkingAccountDetail.phone3) && searchAccountMode != '業者'){
            upAccount.Phone3__c = linkingTargetCorrespondDetail.EchoMail__r.Phone__c;
        }
    }

    /**
     * 取引先の名寄せ確認
     * @param Account upAccount　更新したい取引先
     * @param String searchAccountMode 検索モード名（顧客or業者）
     */ 
    private void mergeAccount(Account upAccount, String searchAccountMode){
                        
        List<Account> nameMergeList = new List<Account>();

        upAccount.IsMergeUnnecessaryFlag__c = false;

        //お客様、業者名寄の実施
        if(searchAccountMode != '業者'){
            nameMergeList = NameMergeUtil.getCustomerMergeList(upAccount, null);// 名寄せ確認
            
            if(nameMergeList.size() == 0){// 名寄せ確認の結果0件なら名寄せ完了
                upAccount.IsMergeCompletedFlag__c = true;
            } else {// 名寄せ確認の結果0件でないなら名寄せ未完了
                upAccount.IsMergeCompletedFlag__c = false;
                //2020.09.03 名寄せで一致対象とされた取引先の名寄せ不要フラグを更新
                NameMergeUtil.setCustomerMergeUnnecessaryFlag(nameMergeList);
            }            
        }
    }
    
    //2020/7/6追加：対応のsoql文作成
    private String createCorrespondSOQL(){
        String sql = '';

        //（画面．反響担当店舗に入力がある場合）																																							
        //対応．反響担当店舗．店舗名	
        Boolean isFirstWHERE=  true;
        if(!String.isEmpty(searchResultEchoShop)){//反響担当店舗
            if(isFirstWHERE){
                sql += ' WHERE ';
                isFirstWHERE = FALSE;
            }else{
                sql += ' AND ';
                
            }
            sql +=  'EchoShop__r.NAME  LIKE \'%' + CommonUtil.convertDisableWildcard(CommonUtil.escapeSingleQuotesEx(searchResultEchoShop))  + '%\' ';
        }
        
        //（画面．反響担当者に入力がある場合）																																							
        //対応．担当者（反響）．ユーザ名		
        if(!String.isEmpty(searchResultEchoStaff)){//反響担当者

            if(isFirstWHERE){
                sql += ' WHERE ';
                isFirstWHERE = FALSE;
            }else{
                sql += ' AND ';
                
            }
            sql +=  'EchoStaff__r.NAME  LIKE \'%' + CommonUtil.convertDisableWildcard(CommonUtil.escapeSingleQuotesEx(searchResultEchoStaff))  + '%\' ';
            
        }
        
        // 来店担当店舗 設定なしのチェックで条件を変える。
        if(searchResultNoVisitShopChecked){
            //来店店舗が設定されていない店舗を条件に追加する。
            if(isFirstWHERE){
                sql += ' WHERE ';
                isFirstWHERE = FALSE;
            }else{
                sql += ' AND ';
                
            }
            sql +=  'VisitShop__c =NULL ';
        }else{
            //（画面．来店担当店舗に入力がある場合）
            //対応．来店担当店舗．店舗名	
            if(!String.isEmpty(searchResultVisitShop)){//来店担当店舗
                if(isFirstWHERE){
                    sql += ' WHERE ';
                    isFirstWHERE = FALSE;
                }else{
                    sql += ' AND ';
                    
                }
                sql +=  'VisitShop__r.NAME  LIKE \'%' + CommonUtil.convertDisableWildcard(CommonUtil.escapeSingleQuotesEx(searchResultVisitShop))  + '%\' ';
                
            }
        
            //（画面．来店担当者に入力がある場合）
            //対応．担当者（来店）．ユーザ名	
            if(!String.isEmpty(searchResultShopStaff)){//来店担当者
                if(isFirstWHERE){
                    sql += ' WHERE ';
                    isFirstWHERE = FALSE;
                }else{
                    sql += ' AND ';
                    
                }
                sql +=  'ShopStaff__r.NAME  LIKE \'%' + CommonUtil.convertDisableWildcard(CommonUtil.escapeSingleQuotesEx(searchResultShopStaff))  + '%\' ';
                
            }
        }
        
        //対応.ステータス
        Boolean isFirstWHEREStatus = TRUE;
        if(statusSearchList.size() > 0){  
            if(isFirstWHERE){
                sql += ' WHERE ';
                isFirstWHERE = FALSE;
            }else{
                sql += ' AND ';
            }
            
            //追加要望 追加 Start
            if(this.isOpetionPortal){
                // 自社ポータル権限有
                sql += createCorrespondStatusSOQL();
            }else{
                // 自社ポータル権限無
                sql += ' Status__c IN ( ';

                for(String status : statusSearchList){
                    if(isFirstWHEREStatus){
                        sql += ' \'' + CommonUtil.escapeSingleQuotesEx(status) + '\'';
                        isFirstWHEREStatus = FALSE;
                    }else{
                        sql += ' , \'' + CommonUtil.escapeSingleQuotesEx(status) + '\'';
                    }
                }
                sql += '  )';    
            }
            //追加要望 追加 End
            
        }
        system.debug(sql);
        return sql;

    }

    //追加要望 追加 Start
    // 対応ステータスの条件設定（ステータスの状態で条件を一部変える）
    private String createCorrespondStatusSOQL(){
        String sql = '';
        Boolean isFirstWHEREStatus = TRUE;
        Boolean statusSearchPursuitFlg = false; //追客中が条件に含まれているか
        for(String status : this.statusSearchList){
            //追客中（他の追客中のステータスも対象）
            if(   status == CommonConst.CORRESPOND_STATUS_PURSUIT 
               || status == CommonConst.CORRESPOND_STATUS_APOCANCEL_PURSUIT 
               || status == CommonConst.CORRESPOND_STATUS_VISITED_PURSUIT 
               || status == CommonConst.CORRESPOND_STATUS_APPLCANCEL_PURSUIT ){  
                statusSearchPursuitFlg = true;
                continue;
            }else{
                if(isFirstWHEREStatus){
                    sql += ' Status__c IN ( ';
                    sql += ' \'' + CommonUtil.escapeSingleQuotesEx(status) + '\'';
                    isFirstWHEREStatus = FALSE;
                }else{
                    sql += ' , \'' + CommonUtil.escapeSingleQuotesEx(status) + '\'';
                }
            }
        }

        // 追客系以外のステータスがセットされている場合
        if(!isFirstWHEREStatus){
            sql += '  )  ';    

            // 追客中がチェックされている場合に検索条件を整える
            if(statusSearchPursuitFlg){
                sql = '  ( ' + sql;    
                sql += '  OR ';  
                sql += '  (  ';    
            }
        }

        // 追客中がチェックされている場合に追客の条件をセットする（取引先．紹介メール配信状況が「配信」以外のものを検索するため別でセット）
        if(statusSearchPursuitFlg){
            sql += ' Status__c IN ( ';
            sql += '   \'' + CommonConst.CORRESPOND_STATUS_PURSUIT + '\'';              //追客中
            sql += ' , \'' + CommonConst.CORRESPOND_STATUS_APOCANCEL_PURSUIT + '\'';    //アポキャンセル後追客
            sql += ' , \'' + CommonConst.CORRESPOND_STATUS_VISITED_PURSUIT + '\'';      //来店後追客
            sql += ' , \'' + CommonConst.CORRESPOND_STATUS_APPLCANCEL_PURSUIT + '\'';   //申込キャンセル後追客
            sql += '  )';   
            sql += ' AND AccountId__r.IntroMailInfoStatus__c != \'' + CommonUtil.escapeSingleQuotesEx(CommonConst_ptl.INTRODUCTION_SEND) + '\'';      // 紹介メール配信状況
            // 追客中以外のステータスが選択されている場合に条件を閉じる。
            if(!isFirstWHEREStatus){
                sql += '  ))';
            }
        }
        system.debug(sql);
        return sql;
    }
    //追加要望 追加 End

    // 取引先の楽観ロックチェック
    private void AccountoptimisticLockCheck(Account upAccount){
        //取引先の楽観ロックチェック
        List<Account> checkOptimisticLockExceptionAccountRecord = new List<Account>();
                            
        checkOptimisticLockExceptionAccountRecord = [ SELECT id
                                            FROM Account
                                            WHERE id = :upAccount.Id
                                            AND SystemModStamp = :upAccount.systemModstamp ];

        //データ取得できない場合、楽観ロックチェックExceptionを発行
        if (checkOptimisticLockExceptionAccountRecord.isEmpty()){
            OptimisticLockException optimisticLockex = new OptimisticLockException();
            throw optimisticLockex;
        }
    }


    //*********************************************************     内部クラス    ************************************************************
    
    //検索明細内部クラス
    public class searchAccountDetail{
        public Integer sortKey {get; set;}              //ソートキー 
        public String sortOrder {get; set;}             //ソート順
        public boolean isCheckbox { get; set; }//チェックボックス
        public String  searchAccountRecordType { get; set; }//取引先種別
        
        public Account serchAccountRecord  { get; set; }//取引先レコード本体
        
        public String  id { get; set; }//Id
        public String  name { get; set; }//取引先名
        public String  HomeMovingSeason { get; set; }//入居希望時期
        public Date    HomeMovingDate { get; set; }//入居希望日
        public String  status { get; set; }//対応．ステータス
        public String  event { get; set; }//対応．イベント
        public String  createdDate { get; set; }//対応．作成日
        public String  latestSupportedDateTime { get; set; }//対応明細．対応日時(最新)
        public String  echoStaff { get; set; }//対応．担当者（反響）
        public String  shopStaff { get; set; }//対応．担当者（来店）
        public String  memo { get; set; }//対応．メモ
        public String  supplierType { get; set; }//業者種別
        public String  address { get; set; }//住所
        public String  phone { get; set; }//電話番号1
        public String  phone2 { get; set; }//電話番号2
        public String  phone3 { get; set; }//電話番号3
        public String  mail1 { get; set; }//メール1
        public String  mail2 { get; set; }//メール2
        public String  mail3 { get; set; }//メール3
        public Boolean isPhoneUpdateUnneededFlag { get; set; }//電話更新不要フラグ
        public Boolean isMailUpdateUnneededFlag { get; set; }//メール更新不要フラグ
        public Boolean isMergeCompletedFlag { get; set; }//名寄せ完了フラグ

        public Id introductionMailInformationId { get; set; } //紹介メール情報ID //問合せNo0429で追加
        
        //コンストラクタ
        public searchAccountDetail(){

        }
        
        //コンストラクタ
        public searchAccountDetail(Account inAccount, String searchAccountRecordType, Map<Id, Correspond__c> correspondMap){
            this.serchAccountRecord = inAccount;
            searchAccountRecordType = searchAccountRecordType;//取引先種別
            this.isCheckbox = FALSE; //チェックボックス
            this.id = inAccount.Id; //Id
            this.name = inAccount.Name; //取引先名
            this.phone = inAccount.Phone; //電話番号
            this.isPhoneUpdateUnneededFlag = false; //電話更新不要フラグ
            this.isMailUpdateUnneededFlag = false;  //メール更新不要フラグ
            
            //取得項目
            if(searchAccountRecordType == '顧客'){//顧客用の設定
                if(inAccount.HomeMovingSeason__c == '即入居'){//入居希望時期が即入居以外の場合は設定しない
                    this.HomeMovingSeason = inAccount.HomeMovingSeason__c; //引越時期(入居希望時期)
                    
                }

                this.HomeMovingDate = inAccount.HomeMovingDate__c; //引越時期（日付）までに(入居希望日)
                
                if(inAccount.CorrespondAccountId__r.size() > 0){//対応の設定
                    this.status = inAccount.CorrespondAccountId__r[0].Status__c; //対応．ステータス
                    this.event = inAccount.CorrespondAccountId__r[0].Event__c; //対応．イベント
                     
                    this.CreatedDate = inAccount.CorrespondAccountId__r[0].CreatedDate.format('yyyy/MM/dd HH:mm', 'JST');//対応．作成日

                    //対応明細の対応日時(最新)があるか
                    Correspond__c cor = correspondMap.get(inAccount.CorrespondAccountId__r[0].Id);
                    if (cor.correspondDetailCorresponds__r.size() > 0){
                        if(cor.correspondDetailCorresponds__r[0].supportedDatetime__c != null){
                        this.latestSupportedDateTime = cor.correspondDetailCorresponds__r[0].supportedDatetime__c.format('yyyy/MM/dd HH:mm', 'JST');//対応明細．対応日時(最新)
                        }
                    }
                    this.echoStaff = inAccount.CorrespondAccountId__r[0].EchoStaff__r.NAME; //対応．担当者（反響）
                    this.shopStaff = inAccount.CorrespondAccountId__r[0].ShopStaff__r.NAME; //対応．担当者（来店）
                    this.memo = inAccount.CorrespondAccountId__r[0].Memo__c; //対応．メモ
                }
                //▼問合せNo0429で追加
                if(inAccount.IntroductionMailInformationAccount__r.size() > 0){
                    this.introductionMailInformationId = inAccount.IntroductionMailInformationAccount__r[0].Id; // 紹介メール情報．ID
                }
                //▲問合せNo0429で追加
                
            }else if(searchAccountRecordType == '業者'){//業者用の設定
                this.supplierType = inAccount.SupplierType__c; //業者種別
                this.address = inAccount.Address__c; //住所
            }
            
            this.mail1 = inAccount.Email__c;//メール1
            this.mail2 = inAccount.Email2__c;//メール2
            this.mail3 = inAccount.Email3__c;//メール3
            this.phone = inAccount.Phone;//電話番号1
            this.phone2 = inAccount.Phone2__c;//電話番号2
            this.phone3 = inAccount.Phone3__c;//電話番号3
            this.isMergeCompletedFlag = inAccount.IsMergeCompletedFlag__c;//名寄せ完了フラグ
        }
 
    }
    
    
}