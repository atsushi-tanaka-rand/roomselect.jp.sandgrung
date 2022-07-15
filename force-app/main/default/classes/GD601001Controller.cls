/* *
* メンテナンス一覧のコントローラ
*/
public inherited sharing class GD601001Controller {
    
    /** パブリック変数 */
    
    /** 検索地区リスト */ 
    public List<SelectOption> searchDistrictList { get; set; } 
    
    /** 検索地区 */ 
    public String district { get; set; } 
    
    /** 金額下限 */ 
    public Decimal amountLowerLimit { get; set; } 
    
    /** 金額上限 */ 
    public Decimal amountUpperLimit { get; set; } 
    
    /** 取込日From */ 
    public Date fromImportDate { get; set; } 
    
    /** 取込日To */ 
    public Date toImportDate { get; set; } 
    
    /** 自動メンテ種別 */ 
    public String automaintenanceType { get; set; } 
    
    /** 自動メンテリスト */ 
    public List<AutoMaintenance__c> automaintenanceList { get; set; } 
    
    /** 選択インデックス */ 
    public Integer index { get; set; } 
    
    /** メンテナンス種別:新規追加 */ 
    public String  automaintenanceTypeAddnew { get; set; } 
    
    /** メンテナンス種別:更新(条件変更) */ 
    public String automaintenanceTypeConditionchangeupdate { get; set; } 
    
    /** メンテナンス種別:更新(居住中→空室) */ 
    public String automaintenanceTypeOccupiedtovacantupdate { get; set; } 
    
    /** メンテナンス種別:掲載終了 */ 
    public String automaintenanceTypeEndofposting { get; set; } 
    
    /** js用完了確認メッセージ */ 
    public String MSG_PROP_I_MAINTENANCE_COMPLETED { get { return CommonUtil.callMessageCreate(CommonConst.MSG_PROP_I_MAINTENANCE_COMPLETED); } private set; }
    
    
    /** エラーフラグ */ 
    public Boolean isOpenError { get; set; }
    
    /** エラーメッセージ保有フラグ */ 
    public Boolean hasErrorMessage { get; set; } 
    
    /** 検索用完了フラグ */ 
    public Boolean searchIsCompletedFlag { get; set; } 

    /** 検索用完了フラグ(出力用) */ 
    public String searchIsCompletedFlagString { get; set; } 
    
    /** 検索用地区 */ 
    public String searchDistrict { get; set; } 
    
    /** 検索用金額下限 */ 
    public Decimal searchAmountLowerLimit { get; set; } 
    
    /** 検索用金額上限 */ 
    public Decimal searchAmountUpperLimit { get; set; } 
    
    /** 検索用取込日From */ 
    public Date searchFromImportDate { get; set; } 
    
    /** 検索用取込日To */ 
    public Date searchToImportDate { get; set; } 
    
    /** 検索ボタン押下箇所 */ 
    public Boolean isUp  { get; set; } 
    
    
    /** プライベート変数 */
    
    /** 検索上限 */ 
    private Integer searchLimit; 
    
    public GD601001Controller(){
        try {
            //初期設定
            init();
            //店舗異動が取得できなければエラー
            CommonUtil.getStaffCurrentShop();
            //地区変更処理
            changeDistrict();
            
        }catch(Exception e){
            isOpenError = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
            
        }
    }
    
    //初期設定
    private void init(){
        try {
            //初期化
            isOpenError = FALSE;
            hasErrorMessage = FALSE;
            
            searchDistrictList = CommonUtil.getSelectOptionFromObject('Building__c', 'District__c');//検索地区リストを建物__cの地区__cから設定
            
            district = '';
            
            /** 金額下限 */ 
            amountLowerLimit = null;
            
            /** 金額上限 */ 
            amountUpperLimit = null;
            
            /** 取込日From */ 
            fromImportDate = null;
            
            /** 取込日To */ 
            toImportDate = null;
            
            /** 自動メンテ種別 */ 
            automaintenanceType = null;
            
            /** 自動メンテリスト */ 
            automaintenanceList = new List<AutoMaintenance__c>();
            
            /** メンテナンス種別:新規追加 */ 
            automaintenanceTypeAddnew = CommonConst.AUTOMAINTENANCE_TYPE_ADDNEW;
            
            /** メンテナンス種別:更新(条件変更) */ 
            automaintenanceTypeConditionchangeupdate = CommonConst.AUTOMAINTENANCE_TYPE_CONDITIONCHANGEUPDATE;
            
            /** メンテナンス種別:更新(居住中→空室) */ 
            automaintenanceTypeOccupiedtovacantupdate = CommonConst.AUTOMAINTENANCE_TYPE_OCCUPIEDTOVACANTUPDATE;
            
            /** メンテナンス種別:掲載終了 */ 
            automaintenanceTypeEndofposting = CommonConst.AUTOMAINTENANCE_TYPE_ENDOFPOSTING;
            
            /** 検索上限 */ 
            searchLimit = 1000; //repeatの最大である1000固定
            
        }catch(Exception e){
            isOpenError = true;//エラーを設定
            throw e;
        }
    }
    
    //地区変更処理
    public void changeDistrict(){
        try {
            hasErrorMessage = FALSE;//エラーを初期化
            //金額下限、金額上限にnullを設定
            
            /** 金額下限 */ 
            amountLowerLimit = null;
            
            /** 金額上限 */ 
            amountUpperLimit = null;
            
            if(district != ''){
                //検索用地区を使用して地区別メンテナンス条件から金額下限と金額上限を取得
                List<AreaMaintenanceCondition__c> areaMaintenanceCondition = [SELECT PropertyAmountLowerLimit__c//取扱い物件 金額(下限)
                                                                              ,PropertyAmountUpperLimit__c//取扱い物件 金額(上限)
                                                                              FROM  AreaMaintenanceCondition__c
                                                                              WHERE District__c = :district];
                
                if(areaMaintenanceCondition.size() > 0){
                    
                    /** 金額下限 */ 
                    amountLowerLimit = areaMaintenanceCondition[0].PropertyAmountLowerLimit__c;
                    
                    /** 金額上限 */ 
                    amountUpperLimit = areaMaintenanceCondition[0].PropertyAmountUpperLimit__c;
                }
            }
            
        }catch(Exception e){
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }
    
    //新規追加（残）押下処理
    public void addnewNotPastSearch(){
        try {
            hasErrorMessage = FALSE;//エラーを初期化
            //検索条件設定
            searchConditionSetting(automaintenanceTypeAddnew, FALSE, TRUE);

            //検索
            maintenanceSearch();
            
        }catch(Exception e){
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }
    
    //更新（居住中→空室）（残）
    public void occupiedtovacantupdateNotPastSearch(){
        try {
            hasErrorMessage = FALSE;//エラーを初期化
            //検索条件設定
            searchConditionSetting(automaintenanceTypeOccupiedtovacantupdate, FALSE, TRUE);
            
            //検索
            maintenanceSearch();
            
        }catch(Exception e){
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }
    
    //更新（条件変更）（当日）
    public void conditionchangeupdateNotPastSearch(){
        try {
            hasErrorMessage = FALSE;//エラーを初期化
            //検索条件設定
            searchConditionSetting(automaintenanceTypeConditionchangeupdate, null, TRUE);
            
            //検索
            maintenanceSearch();
            
        }catch(Exception e){
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }
    
    //掲載終了（当日）
    public void endofpostingNotPastSearch(){
        try {
            hasErrorMessage = FALSE;//エラーを初期化
            //検索条件設定
            searchConditionSetting(automaintenanceTypeEndofposting, null, TRUE);
            
            //検索
            maintenanceSearch();
            
        }catch(Exception e){
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }
    
    //新規追加
    public void addnewPastSearch(){
        try {
            hasErrorMessage = FALSE;//エラーを初期化
            //検索条件設定
            searchConditionSetting(automaintenanceTypeAddnew, TRUE, FALSE);
            //検索
            maintenanceSearch();
            
        }catch(Exception e){
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }
    
    //更新（居住中→空室）
    public void occupiedtovacantupdatePastSearch(){
        try {
            hasErrorMessage = FALSE;//エラーを初期化
            //検索条件設定
            searchConditionSetting(automaintenanceTypeOccupiedtovacantupdate, TRUE, FALSE);
            
            //検索
            maintenanceSearch();
            
        }catch(Exception e){
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }
    
    //更新（条件変更）
    public void conditionchangeupdatePastSearch(){
        try {
            hasErrorMessage = FALSE;//エラーを初期化
            //検索条件設定
            searchConditionSetting(automaintenanceTypeConditionchangeupdate, null, FALSE);
            
            //検索
            maintenanceSearch();
            
        }catch(Exception e){
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }
    
    //掲載終了
    public void endofpostingPastSearch(){
        try {
            hasErrorMessage = FALSE;//エラーを初期化
            //検索条件設定
            searchConditionSetting(automaintenanceTypeEndofposting, null, FALSE);
            
            //検索
            maintenanceSearch();
            
        }catch(Exception e){
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }
    
    //検索条件設定
    public void searchConditionSetting(String inAutomaintenanceType, boolean isCompletedFlag, boolean inIsUp){
        this.automaintenanceType = inAutomaintenanceType;//自動メンテ種別
        this.searchIsCompletedFlag = isCompletedFlag;//検索用完了フラグ

        //帳票のパラメータに使用するため検索用完了フラグを文字列にする
        if(isCompletedFlag == TRUE){
            this.searchIsCompletedFlagString = 'true';

        }else if(isCompletedFlag == FALSE){
            this.searchIsCompletedFlagString = 'false';

        }else if(isCompletedFlag == null){
            this.searchIsCompletedFlagString = 'null';
        }
        this.searchDistrict = this.district;//検索用地区
        this.searchAmountLowerLimit = this.amountLowerLimit;//検索用金額下限
        this.searchAmountUpperLimit = this.amountUpperLimit;//検索用金額上限
        this.searchFromImportDate = this.fromImportDate;//検索用取込日From
        this.searchToImportDate = this.toImportDate;//検索用取込日To
        this.isUp = inIsUp;//検索ボタン押下箇所
        
    }
    
    //検索条件設定
    public void maintenanceSearch(){
        try {
            hasErrorMessage = FALSE;//エラーを初期化
            BusinessLogicException ex = new BusinessLogicException();//ビジネスロジックException準備
            if(String.isNotBlank(String.valueOf(this.searchFromImportDate)) && String.isNotBlank(String.valueOf(this.searchToImportDate)) && this.searchToImportDate < this.searchFromImportDate){
                //終了日に開始日より前の日付が設定されています。終了日は開始日以降を設定してください。
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_DATE_TERM));
            }
            
            //ビジネスロジックException発行
            if (ex.hasMessage()){ 
                throw ex;
            }
            
            //検索用項目宣言
            Date today = commonUtil.getToday();
            Integer sqlSearchLimit = searchLimit;
            
            //日付時間型に変更用の項目宣言
            Time startTime = Time.newInstance(0, 0, 0, 0);
            Time endTime = Time.newInstance(23,59,59,999);
            
            Datetime searchFromImportDatetime;
            Datetime searchToImportDatetime;
            
            //検索
            String sql = '';
            
            //取得項目
            sql += 'SELECT Building__r.Name';//建物．建物名
            sql += ',Property__r.Name';//物件．部屋番号	
            sql += ',Property__r.Score__c';//物件．点数	
            sql += ',Property__r.PhotoCount__c';///物件．写真枚数	
            sql += ',Property__r.PhotoLastModifiedDate__c';//物件．写真最終更新日	
            sql += ',Property__r.ManualMaintenanceDate__c';//物件．手動最終メンテナンス日	
            sql += ',CrawlingSource__c';//クローリング元	
            sql += ',AutoMaintenance__c';//自動メンテナンス内容
            sql += ',Building__r.IsMergeCompletedFlag__c';//建物．名寄せ完了フラグ
            sql += ',Property__r.IsMergeCompletedFlag__c';//物件．名寄せ完了フラグ	
            sql += ',FormerSupplier__r.IsMergeCompletedFlag__c';//取引先．名寄せ完了フラグ	
            sql += ',SystemModStamp';//更新日時	
            sql += ',Building__c';//建物ID
            sql += ',Property__c';//物件ID
            sql += ',FormerSupplier__c';//取引先ID	
            
            //取得オブジェクト
            sql += '  FROM AutoMaintenance__c';//自動メンテナンス
            
            //取得条件
            
            //種別 ＝ 変数の自動メンテ種別
            sql += ' WHERE Type__c      = \'' + CommonUtil.escapeSingleQuotesEx(this.automaintenanceType) + '\'';
            
            //完了フラグ ＝ 変数の検索用完了フラグ
            if(this.searchIsCompletedFlag != null){
                sql += '   AND IsCompletedFlag__c = ' + this.searchIsCompletedFlag;
            }
            
            // 検索用地区が空白でなければ追加
            if(String.isNotBlank(this.searchDistrict)){
                //建物の地区 ＝ 検索用検索地区
                sql += '   AND District__c = \'' + CommonUtil.escapeSingleQuotesEx(this.searchDistrict) + '\'';
            }
            
            
            // 検索用金額下限がisNotBlankなら追加
            if(String.isNotBlank(String.valueOf(this.searchAmountLowerLimit))){
                //物件の賃料 ≧ 検索用金額下限
                sql += '   AND Property__r.RentFee__c   >= ' + this.searchAmountLowerLimit;
                
            }
            
            // 検索用金額上限がisNotBlankなら追加
            if(String.isNotBlank(String.valueOf(this.searchAmountUpperLimit))){
                //物件の賃料 ≦ 検索用金額上限
                sql += '   AND Property__r.RentFee__c   <= ' + this.searchAmountUpperLimit;
                
            }
            
            if(this.isUp){
                //検索↑四つ
                
                if(this.automaintenanceType == this.automaintenanceTypeConditionchangeupdate
                   || this.automaintenanceType == this.automaintenanceTypeEndofposting){
                       //更新条件変更 or 掲載終了 の場合
                       
                       //取込日 ＝ todayを加える
                       
                       //検索用取込日をtodayに設定する
                       searchFromImportDate = today;//検索用取込日From
                       searchToImportDate = today;//検索用取込日To
                       
                       // 検索用取込日From に今日の日付の開始時間を設定
                       searchFromImportDatetime = Datetime.newInstance(today, startTime);
                       sql += '   AND CreatedDate   >= :searchFromImportDatetime';
                       
                       // 検索用取込日To に今日の日付の終了時間を設定
                       searchToImportDatetime = Datetime.newInstance(today, endTime);
                       
                       //取込日 ≦ 検索用取込日To
                       sql += '   AND CreatedDate   <= :searchToImportDatetime';
                       
                   }
                //新規追加or更新（居住中→空室）の場合
                //なにもしない
                
            }else{
                //検索↓四つ
                
                // 検索用取込日From が isNotBlank なら追加
                if(String.isNotBlank(String.valueOf(this.searchFromImportDate))){
                    searchFromImportDatetime = Datetime.newInstance(searchFromImportDate, startTime);
                    //取込日 ≧ 検索用取込日From
                    sql += '   AND CreatedDate  >= :searchFromImportDatetime';
                }
                
                // 検索用取込日To が isNotBlankなら追加
                if(String.isNotBlank(String.valueOf(this.searchToImportDate))){
                    searchToImportDatetime = Datetime.newInstance(searchToImportDate, endTime);
                    //取込日 ≦ 検索用取込日To
                    sql += '   AND CreatedDate  <= :searchToImportDatetime';
                }
            }
            
            
            //取得順序
            sql += ' ORDER BY';
            sql += '       Building__r.Name,Property__r.Name ASC';
            
            //取得数
            sql += ' LIMIT :sqlSearchLimit';
            
            
            //取得
            List<AutoMaintenance__c> searchResultList = Database.query(sql);
            
            
            //検索結果を画面に反映
            index = 0;
            automaintenanceList = new List<AutoMaintenance__c>();
            for (AutoMaintenance__c searchResult : searchResultList){
                automaintenanceList.add(searchResult);
            }
            
        }catch(Exception e){
            hasErrorMessage = true;//エラーを設定
            throw e;
        }
    }
    
    //完了リンク押下
    public void maintenanceComplete(){
        Savepoint sp = Database.setSavepoint();      //セーブポイント作成
        try{
            hasErrorMessage = false;
            
            AutoMaintenance__c updateAutoMaintenanceRecord = new AutoMaintenance__c();
            
            updateAutoMaintenanceRecord.ID = automaintenanceList[index-1].ID;
            updateAutoMaintenanceRecord.IsCompletedFlag__c = TRUE;
            
            
            //楽観ロックチェック        
            List<AutoMaintenance__c> checkOptimisticLockExceptionRecord = new List<AutoMaintenance__c>();
            checkOptimisticLockExceptionRecord = [ SELECT id
                                                  FROM AutoMaintenance__c
                                                  WHERE id = :automaintenanceList[index-1].ID
                                                  AND SystemModStamp = :automaintenanceList[index-1].systemModStamp ];
            
            //データ取得できない場合、楽観ロックチェックExceptionを発行
            if (checkOptimisticLockExceptionRecord.isEmpty()){
                OptimisticLockException optimisticLockex = new OptimisticLockException();
                throw optimisticLockex;
            }
            
            SecureDML.secureUpdate(updateAutoMaintenanceRecord);
            // 日報登録、更新処理
            DailyReportUtil.upsertDailyReportMaintenance();

            maintenanceSearch();
            
        }catch(Exception e){
            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
            
        }
    }
}