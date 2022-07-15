// 業務日報　コントローラ
public inherited sharing class GE101001Controller {

    //Public変数
    public String addPropertyConfirmation { get; set; }// 物確（+：増／-：減）の宣言
    public String addPropertyResearch { get; set; }// 物調（+：増／-：減）の宣言    
    public DailyReport__c dailyReport { get; set; }// 入力フォームに表示する日報を宣言
    public List<DailyReport__c> dailyReportList { get; set; }// 31日前からの日報をリスト型で宣言
    public Date inputDate { get; set; }// 入力フォームに表示する日報の「業務日付」を設定する
    public Integer selectDailyReportIndex { get; set; }// ページ内で選択した、「DisplayDailyReport」が保持するインデックスの値
    
    public String MSG_COM_V_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_SAVE);} private set;}    //js用保存確認メッセージ
    public String MSG_COM_I_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);} private set;}    //js用保存完了メッセージ
    
    /** エラーフラグ */ 
    public Boolean isOpenError { get; set; }
    
    /** エラーメッセージ保有フラグ */ 
    public Boolean hasErrorMessage { get; set; } 
    
    // private 変数の宣言
    private Date todayDate = CommonUtil.getToday();// 現在の日付を取得
    private ID staffID = UserInfo.getUserId();// このページを開いたユーザのIDを取得
    private Shop__c staffCurrentShop;         // このページを開いたユーザが現在所属している店舗
    
    // コンストラクタ
    public GE101001Controller(){
        try{
       
            init();// 初期化

            
            //既存データがあればそれを表示
            DailyReport__c todayReportData = findTodayData();
            if( todayReportData != null){
                this.dailyReport = todayReportData;
            }else{
                this.dailyReport = new DailyReport__c();
                this.dailyReport.ReportDate__c = todayDate;
                this.dailyReport.Staff__c = staffID;
                this.dailyReport.Shop__c  = staffCurrentShop.ID;
            }
           
        }catch(Exception e){
            isOpenError = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
            
        }
    }

    // 過去日報の「選択」ボタン押下時に、選択した過去日報を入力フォームに設定する
    public void setSelectDailyReport(){
        dailyReport = dailyReportList[selectDailyReportIndex];
    }
    
    // 日報の「登録」ボタン押下処理
    public void save(){  
        Savepoint sp = Database.setSavepoint();//　rollback メソッドで使用して、データベースをその時点に復元できる savepoint変数 を設定
        try {
            
            hasErrorMessage = false;
            
            //ビジネスロジックException準備
            BusinessLogicException ex = new BusinessLogicException();
            

            //入力チェック
            
            List<String> requiredItem = new List<String>();

            if (String.isBlank(addPropertyConfirmation) && String.isBlank(addPropertyResearch)){
                //「物確（+：増／-：減）」と「物調（+：増／-：減）」の値がどちらもブランクの場合エラーに追加
                requiredItem.add('物確（+：増／-：減）と物調（+：増／-：減）のどちらかに');
            }
            
            //入力チェック用リストが空ではない場合、ビジネスロジックException発行
            if (!requiredItem.isEmpty()){
                //〇〇は入力必須です。
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ',')));
                throw ex;
            }
            
            // 「物確」の値がブランクの場合、「物確」の値を「0」に設定する
            if(string.isBlank(string.valueOf(dailyReport.PropertyConfirmation__c))){
                dailyReport.PropertyConfirmation__c = 0;
            }
            
            // 「物確（+：増／-：減）」の値がブランクの場合、「物確（+：増／-：減）」の値を「0」に設定する
            if(string.isBlank(addPropertyConfirmation)){
                addPropertyConfirmation = '0';
            }
            // 「物調」の値がブランクの場合、「物調」の値を「0」に設定する
            if(string.isBlank(string.valueOf(dailyReport.PropertyResearch__c))){
                dailyReport.PropertyResearch__c = 0;
            }
            
            // 「物調（+：増／-：減）」の値がブランクの場合、「物調（+：増／-：減）」の値を「0」に設定する
            if(string.isBlank(addPropertyResearch)){
                addPropertyResearch = '0';
            }
            
            // 取得した物確の値に入力フォームで記入した物確に追加する値を足す
            Decimal sumPropertyConfirmation = dailyReport.PropertyConfirmation__c + Integer.valueOf(addPropertyConfirmation);
            
            // 「物確」の値が範囲外の場合エラー
            if(sumPropertyConfirmation > 999 || 0 > sumPropertyConfirmation){
                List<Object> parameters = new List<Object> {'物確' , '0', '999'};
                //〇〇の値が範囲外となります。〇〇以上〇〇以下となるように設定ください
                    ex.addMessage(CommonUtil.callMessageCreate(String.format(CommonConst.MSG_COM_E_REGISTRATION_COUNT_RANGE, parameters)));
            }
            
            
            // 取得した物調の値に入力フォームで記入した物調に追加する値を足す
            Decimal sumPropertyResearch = dailyReport.PropertyResearch__c + Integer.valueOf(addPropertyResearch);

            // 「物調」の値が範囲外の場合エラー
            if(sumPropertyResearch > 999 || 0 > sumPropertyResearch){
                List<Object> parameters = new List<Object> {'物調' , '0', '999'};
                //〇〇の値が範囲外となります。〇〇以上〇〇以下となるように設定ください
                ex.addMessage(CommonUtil.callMessageCreate(String.format(CommonConst.MSG_COM_E_REGISTRATION_COUNT_RANGE, parameters)));
            }
            
            //ビジネスロジックException発行
            if (ex.hasMessage()){ 
                throw ex;
            }
            
            //新規作成でない場合、更新時間でのデータ取得処理を実施
            if (!String.isBlank(dailyReport.ID)){
                List<DailyReport__c> checkOptimisticLockExceptionRecord = new List<DailyReport__c>();

                checkOptimisticLockExceptionRecord = [ SELECT id
                                                      FROM DailyReport__c
                                                      WHERE id = :dailyReport.ID
                                                      AND SystemModStamp = :dailyReport.systemModStamp ];
                
                //データ取得できない場合、楽観ロックチェックExceptionを発行
                if (checkOptimisticLockExceptionRecord.isEmpty()){
                    OptimisticLockException OptimisticLockex = new OptimisticLockException();
                    throw OptimisticLockex;
                }
            }else{
                // 新規作成の場合、店舗、作成ユーザ、日付、期間でのデータ取得処理を実施
                List<DailyReport__c> checkExistence = new List<DailyReport__c>();

                checkExistence = [ SELECT id
                                   FROM DailyReport__c
                                   WHERE Shop__c = :staffCurrentShop.ID// このページを開いたユーザが現在所属している店舗ID
                                   AND Staff__c = :staffID// このページを開いたユーザのID
                                   AND ReportDate__c = :dailyReport.ReportDate__c];// 日付

                
                //データ取得できた場合、ビジネスロジックExceptionを発行
                if (!checkExistence.isEmpty()){
                    //エラーメッセージの作成

                    // 業務日付をyyyy-MM-dd形式に変換
                    Datetime reportDatetime = Datetime.newInstance(dailyReport.ReportDate__c.year(), dailyReport.ReportDate__c.month(), dailyReport.ReportDate__c.day());
                    String reportDatetime_Str = reportDatetime.format('yyyy-MM-dd');

                    //エラーメッセージの引数作成
                    String errorMessage = staffCurrentShop.NAME + '・' + UserInfo.getName() + '・' + reportDatetime_Str + 'のデータ';

                    // 〇〇は既に存在します。
                    ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_EXISTENCE, errorMessage)); 
                    throw ex;
                }
            }

            //日報の値を設定
            dailyReport.PropertyConfirmation__c = sumPropertyConfirmation;
            dailyReport.PropertyResearch__c = sumPropertyResearch;
                                         
            
            // 日報を登録
            SecureDML.secureUpsert(dailyReport);
            
            // 初期化処理
            // 業務日報履歴を再設定
            init();
            
            // 登録後に表示する日報を設定
            for(DailyReport__c inDailyReport : dailyReportList){

                if(String.isBlank(dailyReport.ID)){
                    // 新規登録の場合
                    if(inDailyReport.ReportDate__c == todayDate){
                        // 新規登録した、現在の日付の日報を表示
                        dailyReport = inDailyReport;
                    }
                }else if(inDailyReport.ID == dailyReport.ID){
                    // 新規登録でなかった場合、登録した日報を表示
                    dailyReport = inDailyReport;
                }
            }
        }catch(Exception e){
            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
            
        }
    }  
    
    //********************************************************************privateメソッド*****************************************************************
    
    // 初期化
    private void init(){
        isOpenError = FALSE;
        hasErrorMessage = FALSE;
        addPropertyConfirmation = '';
        addPropertyResearch = '';
        dailyReportList = new List<DailyReport__c>();
        
        // 店舗異動登録がないとエラー
        staffCurrentShop = CommonUtil.getStaffCurrentShop();// このページを開いたユーザが現在所属している店舗を取得
       
        // 業務日報履歴を設定
        setdailyReportList();
    }
    
    // 業務日報履歴を設定
    // 31日前からの日報を取得する
    private void setdailyReportList(){
       
        this.dailyReportList = [SELECT ID,Name
                           , ReportDate__c// 業務日付
                           , PropertyConfirmation__c// 物確
                           , PropertyResearch__c// 物調
                           , ManualMaintenanceCount__c// 手動メンテ数
                           , AutoMaintenanceCount__c// 自動メンテ数
                           , Electronic__c// 電物
                           , PhotoRegist__c// 写真入れ
                           , ImprovementPlan__c // 業務改善案
                           , SystemModStamp // 更新日時
                           , Staff__c // 従業員
                           FROM DailyReport__c 
                           WHERE ReportDate__c >= :todayDate.addDays(-31)// 今日から31日前の日付
                           AND Staff__c = :staffID// このページを開いたユーザのID
                           AND Shop__c = :staffCurrentShop.ID// このページを開いたユーザが現在所属している店舗ID
                           ORDER BY ReportDate__c DESC];  
         
    }
    
    //本日のデータの検索
    private DailyReport__c findTodayData() {
        
        for (DailyReport__c dailyReportData: this.dailyReportList) {
            if (dailyReportData.ReportDate__c == todayDate) {
                return dailyReportData;
            }
        }
        return null;
    }
    
  
}