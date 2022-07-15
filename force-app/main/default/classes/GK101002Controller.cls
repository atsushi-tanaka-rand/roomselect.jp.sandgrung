/* *
 * HP会員詳細　のコントローラ
 */
public inherited sharing class GK101002Controller {

    //メッセージ系
    public String MSG_COM_I_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);} private set;}    //js用保存完了メッセージ
    public String MSG_COM_V_BLACKLIST_CHANGE {get{return CommonUtil.callMessageCreate(CommonConst_ptl.MSG_COM_V_BLACKLIST_CHANGE);} private set;}    //jsブラックリスト変更時保存確認
    public String MSG_COM_V_UPDATE_MEMBER {get{return CommonUtil.callMessageCreate(CommonConst_ptl.MSG_COM_V_UPDATE_MEMBER);} private set;}    //保存確認

    //パラメータ
    private id targetId;
    private String targetMemberId;

    //本会員
    public Member__c targetMember { get; set; } 
    //明細
    Transient public List<ScreenSearchHistory> ScreenSearchHistoryList { get; set;}         //検索履歴（内部クラス）
    Transient public List<BrowsingHistory__c> browsingHistoryList { get; set;}              //閲覧履歴
    Transient public List<PortalFavoriteProperty__c> portalFavoritePropertyList { get; set;}//ポータルお気に入り物件

    //編集可の項目
    public String memberIdEmail {get; set;}     //会員ID（メールアドレス）
    public String tell          {get; set;}     //電話番号
    public Boolean blackListFlg {get; set;}     //ブラックリストフラグ

    //フラグ類
    public Boolean hasErrorMessage {get; set;}  // エラーメッセージ保有フラグ
    public Boolean isOpenError {get; set;}      // 初期エラーフラグ
    public Boolean isOpetionPortal{ get; set; }    // 自社ポータル権限 

    //保存ボタン押下フラグ用
    final public string WITHDRAWAL{get{return CommonConst_ptl.MEMBER_MEMBERSTATU_WITHDRAWAL;} private set;}    //退会
    
    /** private変数 */
    
    final private Integer INDEX_LIMIT = 1000;   //検索上限数


    //コンストラクタ
    public GK101002Controller() {
        try{
            // 店舗異動情報の取得（画面操作権限の確認）
            CommonUtil.getStaffCurrentShop();

            //自社権限の取得
            this.isOpetionPortal = AuthorityCheckUtil.getAuthorityOptionPortal(true);

            //パラメータ取得
            getParm();


            // 初期化
            init();
            

        } catch(Exception e) {
            // エラー設定
            isOpenError = true;
            CommonUtil.setErrorMessage(e);
        }
    }


    //************************************************publicメソッド *************************************************************
    //保存ボタン押下
    public void save(){
        try {
            hasErrorMessage = false;
            //入力規則等のチェック
            saveCheck();

            Date today = CommonUtil.getToday();//本日日付取得

            //本会員更新
            updateMember(today);
            
            //本会員差分作成
            insertMemberDifference(today);

        } catch (Exception e) {
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    //************************************************privateメソッド *************************************************************
    //パラメータ取得
    private void getParm(){
        //対象IDを取得する
        this.targetId = ApexPages.currentPage().getParameters().get('id');
        this.targetMemberId = ApexPages.currentPage().getParameters().get('memberId');

        //パラメータがなければエラー
        if(String.isEmpty(this.targetId) || String.isEmpty(this.targetMemberId)){
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
            throw ex;
        }
    }
    
    //初期処理
    private void init(){
        //フラグ
        this.isOpenError = false;   //初期エラーフラグ
        
        //データ取得
        
        this.targetMember = selectMember();                  //本会員
        this.portalFavoritePropertyList = selectPortalFavoriteProperty(); //ポータルお気に入り物件
        this.browsingHistoryList = selectBrowsingHistory();               //閲覧履歴
        List<SearchHistory__c> searchList = selectSearchHistory();        //検索履歴(内部クラス用)

        //初期化
        this.ScreenSearchHistoryList= new List<ScreenSearchHistory>();    //表示用検索履歴
        this.memberIdEmail =targetMember.Email__c;      //会員ID（メールアドレス）
        this.tell          =targetMember.Tell__c;       //電話番号
        this.blackListFlg =targetMember.Blacklist__c;   //ブラックリストフラグ

        //検索履歴の内部クラス作成
        for(SearchHistory__c search : searchList){
            ScreenSearchHistoryList.add(new ScreenSearchHistory(search));
        }

    }

    //---------------------保存時メソッド-------------------------------------------------------------------
    //保存時チェック
    private void saveCheck(){
        BusinessLogicException ex = new BusinessLogicException();
        
        //会員ID（メールアドレス）がない場合エラー
        if (String.isEmpty(memberIdEmail)){
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, '会員ID'));
        }

        //電話番号がない場合エラー
        if (String.isEmpty(this.tell)){
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, '電話番号'));
        }

        // エラーあり
        if(ex.hasMessage()){
            throw ex;
        }

        //会員ID（メールアドレス）が他にレコードで既に登録されている場合エラー
        List<Member__c> mem = [SELECT id
                                FROM Member__c
                                WHERE id != :this.targetId
                                AND   Email__c = :this.memberIdEmail
                                AND (MemberStatus__c = :CommonConst_ptl.MEMBER_MEMBERSTATU_ADMISSION
                                OR blacklist__c = true) ];//現況が入会中　または　ブラックリストフラグがtrue
                                
        if (!mem.isEmpty()){
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_EXISTENCE, this.memberIdEmail));
            throw ex;
        }

        // 会員Idのメールアドレスの入力規則をチェックし、間違っていればエラー
        if(CommonUtil.isWrongMailString(memberIdEmail)){
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_MAILADDRESS_VALIDATION, '会員ID'));
            throw ex;
        }
        // 電話番号の桁数チェック（電話番号が10～11桁）
        if(this.tell.length() < 10 || this.tell.length() > 11 ){
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst_ptl.MSG_COM_E_MEMBER_TELL_LENGTH, '10,11'.split(',')));
            throw ex;
        }
        //楽観ロックチェック
        List<Member__c> checkOptimisticLockExceptionRecord = new List<Member__c>();
        checkOptimisticLockExceptionRecord = [ SELECT id
                                                 FROM Member__c
                                                WHERE id = :targetId
                                                  AND SystemModStamp = :this.targetMember.SystemModStamp ];
        
        if (checkOptimisticLockExceptionRecord.isEmpty()){
            OptimisticLockException ex2 = new OptimisticLockException();
            throw ex2;
        }
    }

    //本会員更新
    private void updateMember(Date today){
        Savepoint sp = Database.setSavepoint();      //セーブポイント作成
        try{
            Member__c updateMember = new Member__c();
            //固定項目
            updateMember.id = this.targetId;
            //変動項目
            updateMember.Email__c = this.memberIdEmail;      //メールアドレス（会員ID）
            updateMember.Tell__c  = this.tell;               //電話番号
            updateMember.Blacklist__c = this.blackListFlg;   //ブラックリストフラグ
            //ブラックリストフラグがtrue
            if (this.blackListFlg){//退会に変更
                updateMember.MemberStatus__c = CommonConst_ptl.MEMBER_MEMBERSTATU_WITHDRAWAL;//会員状況：退会
                updateMember.QuitDate__c =  today;  //退会日：本日日付
            }else{                 //入会のまま
                updateMember.MemberStatus__c = CommonConst_ptl.MEMBER_MEMBERSTATU_ADMISSION;//会員状況
                updateMember.QuitDate__c =  null;  //退会日：null
            }

            SecureDML.secureUpdate(updateMember);

        }catch(Exception e){
            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;
        }
    }

    //本会員差分作成
    private void insertMemberDifference(Date today){
        Savepoint sp = Database.setSavepoint();      //セーブポイント作成
        try{
            MemberDifference__c insertMemberDiff = new MemberDifference__c();
            //固定項目
            insertMemberDiff.CrudCd__c = 'U';                             //クラッドコード
            insertMemberDiff.LinkCd__c = 'StoH';                          //連携コード    
            insertMemberDiff.MemberId__c = this.targetMember.MemberId__c; //会員ID
            insertMemberDiff.Account__c = this.targetMember.Account__c;   //取引先
            //変動項目
            insertMemberDiff.Email__c = PortalUtil.encryption(this.memberIdEmail);   //暗号化したメールアドレス（会員ID）
            insertMemberDiff.Tell__c  = PortalUtil.encryption(this.tell);            //暗号化した電話番号
            insertMemberDiff.Blacklist__c = this.blackListFlg;            //ブラックリスト

            //ブラックリストフラグがtrue
            if (this.blackListFlg){//退会に変更
                insertMemberDiff.MemberStatus__c = CommonConst_ptl.MEMBER_MEMBERSTATU_WITHDRAWAL;//会員状況：退会
                insertMemberDiff.QuitDate__c =  today;  //退会日：本日日付
            }else{                 //入会のまま
                insertMemberDiff.MemberStatus__c = CommonConst_ptl.MEMBER_MEMBERSTATU_ADMISSION;//会員状況：入会
                insertMemberDiff.QuitDate__c =  null;  //退会日：null
            }

            SecureDML.secureInsert(insertMemberDiff);
            
        }catch(Exception e){
            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;
        }
    }

    //---------------------レコード取得メソッド-------------------------------------------------------------------
    
    //本会員取得
    private Member__c selectMember(){
        List<Member__c> memList = [SELECT id,            
                                        MemberId__c,        //本会員Id
                                        LastName__c,        //名
                                        FirstName__c,       //姓
                                        LastNameKana__c,    //名カナ
                                        FirstNameKana__c,   //姓カナ
                                        Tell__c,            //電話番号
                                        Fax__c,             //Fax
                                        Email__c,           //メール（会員Idとして表示）
                                        Password__c,        //パスワード
                                        Birthdate__c,       //生年月日
                                        Gender__c,          //性別
                                        Zip__c,             //郵便番号
                                        State__c,           //都道府県
                                        City__c,            //住所1
                                        Street__c,          //住所2
                                        Job__c,             //職業
                                        BloodType__c,       //血液型
                                        FamilyStructure__c, //家族構成
                                        OwnHouse__c,        //持ち家
                                        LivePeople__c,      //ご入居予定の人数
                                        DesireMoveIn__c,    //入居希望時期
                                        DesireTrainRouteStation__c,//希望の沿線・駅
                                        DesireArea__c,      //希望のエリア
                                        DesireRoomPlan__c,  //希望する間取り
                                        DesireRentFee__c,   //希望の家賃
                                        ManageFeeFlg__c,    //管理費・共益費込み
                                        RecommendMailFlg__c,//レコメンドメールフラグ
                                        HomeMovingReason__c,//引越理由
                                        Dissatisfaction__c, //不満理由
                                        Taste__c,           //趣味・嗜好
                                        Account__c,         //取引先
                                        JoinDate__c,        //入会日
                                        QuitDate__c,        //退会日
                                        QuitReason__c,      //退会理由
                                        QuitReasonOther__c, //退会理由（その他）
                                        QuitRemarks__c,     //退会備考
                                        Blacklist__c,       //ブラックリスト
                                        LastAccessDate__c,  //最終アクセス日時
                                        MemberStatus__c,    //会員状況
                                        Age__c,             //年齢
                                        SystemModStamp
                                    FROM Member__c 
                                    WHERE Id = :this.targetId
                                    LIMIT :1];
        //パラメータがなければエラー
        if(memList.isEmpty()){
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
            throw ex;
        }
        return memList[0];
    }
    
    //ポータルお気に入り物件取得
    private List<PortalFavoriteProperty__c> selectPortalFavoriteProperty(){
        List<PortalFavoriteProperty__c> favoriteList =[SELECT id,
                                                        BrowsingDate__c,    //登録日時
                                                        PropertyId__c,      //物件ID
                                                        PropertyId__r.Name, //物件名
                                                        PropertyId__r.Building__r.Name,//建物名
                                                        PropertyId__r.Building__r.Address__c//建物住所
                                                FROM PortalFavoriteProperty__c
                                                WHERE MemberId__c = :targetMemberId
                                                ORDER BY BrowsingDate__c  DESC      //お気に入り登録日時降順
                                                LIMIT :INDEX_LIMIT];
        if(favoriteList.isEmpty()){
            favoriteList = new List<PortalFavoriteProperty__c>();
        }    
        return favoriteList;   
    }
    
    //閲覧履歴取得
    private List<BrowsingHistory__c> selectBrowsingHistory(){
        List<BrowsingHistory__c> browsList = [SELECT id,
                                                  BrowsingDate__c,   //検索日時
                                                  PropertyId__r.Name,//物件名
                                                  PropertyId__r.Building__r.Name,     //建物名
                                                  PropertyId__r.Building__r.Address__c//建物住所
                                            FROM BrowsingHistory__c
                                            WHERE MemberId__c = :targetMemberId
                                            ORDER BY BrowsingDate__c  DESC      //閲覧日時降順
                                            LIMIT :INDEX_LIMIT];
        if(browsList.isEmpty()){
            browsList = new List<BrowsingHistory__c>();
        }    
        return browsList;
                                           
    }

    //検索履歴取得
    private List<SearchHistory__c> selectSearchHistory(){
        List<SearchHistory__c> searchList = [SELECT id,
                                                 SearchDate__c ,        //検索日時
                                                 TrainRouteStation__c,  //駅・沿線
                                                 Area__c,               //エリア
                                                 SearchHistoryDisplay1__c,  //検索履歴表示1
                                                 SearchHistoryDisplay2__c,  //検索履歴表示2
                                                 SearchHistoryDisplay3__c,  //検索履歴表示3
                                                 FreewordSearch__c          //フリーワード検索      追加要望　追加
                                            FROM SearchHistory__c
                                            WHERE MemberId__c = :targetMemberId
                                            ORDER BY SearchDate__c  DESC      //検索日時降順
                                            LIMIT :INDEX_LIMIT];
        if(searchList.isEmpty()){
            searchList = new List<SearchHistory__c>();
        }    
        return searchList;  
    }



    //************************************************内部クラス *************************************************************
    //表示用検索履歴
    public class ScreenSearchHistory{
        public SearchHistory__c searchHistory { get; set; }     //検索履歴
        public String searchHistoryDisplay  { get; set; }       //検索条件

        public ScreenSearchHistory(SearchHistory__c search){
            this.searchHistory = search;
            this.searchHistoryDisplay = createScreenSearchHistory(search);
        }

        //検索条件文字列作成
        private String createScreenSearchHistory(SearchHistory__c search){
            String reStr = '';
            
            reStr += (String.isBlank(search.TrainRouteStation__c) ? '' : search.TrainRouteStation__c + '/');//沿線・駅
            reStr += (String.isBlank(search.Area__c) ? '' : search.Area__c + '/');//エリア
            reStr += (String.isBlank(search.SearchHistoryDisplay1__c) ? '' : search.SearchHistoryDisplay1__c);
            reStr += (String.isBlank(search.SearchHistoryDisplay2__c) ?  ''  : search.SearchHistoryDisplay2__c);
            reStr += (String.isBlank(search.SearchHistoryDisplay3__c) ?  '' :search.SearchHistoryDisplay3__c);
            reStr += (String.isBlank(search.FreewordSearch__c) ?  '' :search.FreewordSearch__c);                    //フリーワード検索　    追加要望　追加
            if(String.isNotBlank(reStr)){
                reStr =reStr.removeEnd('/');
            }
            
            return reStr;
        }
    }
}