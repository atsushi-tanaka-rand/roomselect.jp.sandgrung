/* *
 * HP会員一覧　のコントローラ
 */
public inherited sharing class GK101001Controller {
    
    /** public変数 */
    
    //検索条件
    public String MemberStatusRadioButton { get; set; }//ラジオボタン　入会中or退会済or全て
    public String searchMemberId { get; set; }    // 会員ID
    public String searchName { get; set; }        // 氏名
    public String searchTel { get; set; }         // 電話番号 
    //明細関係
    Transient public List<Member__c> memberList { get; set; }   // 本会員明細リスト
    public String selectedParm { get; set; }              // 選択された明細のリンクパラメータ
    
    //フラグ類
    public Boolean hasErrorMessage {get; set;}                      // エラーメッセージ保有フラグ
    public Boolean isOpenError {get; set;}                          // 初期エラーフラグ
    public Boolean isOpetionPortal{ get; set; }    // 自社ポータル権限 
    
    /** private変数 */
    //検索上限数
    final private Integer INDEX_LIMIT = 1000;


    //コンストラクタ
    public GK101001Controller() {
        try{
            
            // 店舗異動情報の取得（画面操作権限の確認）
            CommonUtil.getStaffCurrentShop();

            //ポータルサイト構築 追加 Start
            this.isOpetionPortal = AuthorityCheckUtil.getAuthorityOptionPortal(true);
            
            // 初期化
            init();
            

        } catch(Exception e) {
            // エラー設定
            isOpenError = true;
            CommonUtil.setErrorMessage(e);
        }

    }
    //************************************************************************** publicメソッド *************************************************************
    //会員状況ラジオボタン
    public List<SelectOption> getMemberStatusRadioButtonSetting(){
        List<SelectOption> options = new List<SelectOption>();
        //入会
        options.add(new SelectOption( CommonConst_ptl.MEMBER_MEMBERSTATU_ADMISSION ,'入会中'));
        //退会d
        options.add(new SelectOption(CommonConst_ptl.MEMBER_MEMBERSTATU_WITHDRAWAL ,'退会済'));
        options.add(new SelectOption('全て', '全て'));
        return options;
    }

    // 検索ボタン処理
    public void search() {
        try{
            // エラーフラグ初期化
            hasErrorMessage = false;
            
            // 検索結果を表示用にコピー
            memberList = searchMembr();

            // 明細選択を初期化
            selectedParm = null;
    

        }catch(Exception e){
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    
    
    //************************************************************************** privateメソッド *************************************************************
    
    // 初期化
    private void init() {
                
        // 変数初期化
        searchMemberId = '';                    //検索用会員ID
        searchName = '';                        //検索用氏名
        searchTel = '';                         //検索用電話番号
        MemberStatusRadioButton = CommonConst_ptl.MEMBER_MEMBERSTATU_ADMISSION;//入会中 会員状況ラジオボタン

        // エラーメッセージフラグ初期化
        hasErrorMessage = false;
        isOpenError = false;
    }

    private List<Member__c> searchMembr(){
        // SQL用変数作成
        String soqlEMail  = '%'+ CommonUtil.convertDisableWildcard(searchMemberId) + '%';     //メールアドレス（検索状況の会員Id）
        String soqlName   = '%'+ CommonUtil.convertDisableWildcard((searchName.replace(' ', '')).replace('　', ''))   + '%';       //氏名
        String soqlTel    = '%'+ CommonUtil.convertDisableWildcard(searchTel)     + '%';      //電話番号

        //whereフラグ
        Boolean whereFlg = false;
                
        // 検索SQL作成
        String sql = '';
        sql += 'SELECT  Id'; 
        sql += '      , MemberId__c';      // 会員Id
        sql += '      , LastName__c';      // 姓
        sql += '      , FirstName__c';      // 名
        sql += '      , Email__c';         // メールアドレス（会員Id項目に表示）
        sql += '      , Tell__c';             // 電話番号
        sql += '      , LastAccessDate__c'; // 最終ログイン
        sql += '      , JoinDate__c';      // 入会日
        sql += '      , QuitDate__c';      // 退会日            
        sql += '  FROM Member__c';
        
        //検索条件　会員状況
        String ADMISSION = CommonConst_ptl.MEMBER_MEMBERSTATU_ADMISSION;//入会
        String WITHDRAWAL = CommonConst_ptl.MEMBER_MEMBERSTATU_WITHDRAWAL;//退会

        if (MemberStatusRadioButton == ADMISSION){//入会
            sql += whereOrAnd(whereFlg);
            sql += '   MemberStatus__c = :ADMISSION'; 
            whereFlg = true;

        }else if (MemberStatusRadioButton == WITHDRAWAL){//退会済
            sql += whereOrAnd(whereFlg);
            sql += '   MemberStatus__c = :WITHDRAWAL'; 
            whereFlg = true;
        }

        //検索条件　メールアドレス
        if (!String.isEmpty(searchMemberId)){
            sql += whereOrAnd(whereFlg);
            sql += '   Email__c LIKE :soqlEMail'; 
            whereFlg = true;
        }

        //検索条件　氏名
        if (!String.isEmpty(searchName)){
            sql += whereOrAnd(whereFlg);
            sql += '   FullName__c LIKE :soqlName';
            whereFlg = true;
        }

        //検索条件　電話番号
        if (!String.isEmpty(searchTel)){
            sql += whereOrAnd(whereFlg);
            sql += '   Tell__c LIKE :soqlTel'; 
            whereFlg = true;
        }

        sql += ' ORDER BY JoinDate__c DESC ';
        sql += ' LIMIT :INDEX_LIMIT';

        // 検索実行＆結果返却
        List<Member__c> searchResultList = Database.query(sql);
        
        // 検索結果件数チェック
        if (searchResultList.size() == 0) {
            // ビジネスロジックException発行
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_NO_DATA));
            throw ex;
        }

        return searchResultList;
    }
    
    //SOQLのWHEREかANDか
    private string whereOrAnd(Boolean whereFlg){
        String reStr;
        if (whereFlg == true){
            reStr = ' AND ';
        }else{
            reStr = ' WHERE ';
        }
        return reStr;
    }

}