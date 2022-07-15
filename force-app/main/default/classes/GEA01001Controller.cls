/*
* 目標値登録のコントローラ
*/
global inherited sharing class GEA01001Controller {
    
    //******************************************************************** public変数 ********************************************************************
    
    //画面表示用クラス
    public displayCompanyGoal displayCompanyGoal { get; set; }// 全社目標表示用内部クラス
    public List<displayShopGoal> displayShopGoalList { get; set; }// 店舗目標表示用内部クラス
    public displayIS displayIS { get; set; }//IS表示
    
    //検索条件
    public String targetYear { get; set; }// 対象年月
    
    //月別反響目標
    public Decimal companyGoalRateSum { get; set; }

    // 表示月（会計年度期首月からスタートする月のリスト）
    public Integer[] displayMonths { get; set; }
    
    //チェックボックス
    public Boolean isShopAllChecked { get; set; }// 月別再計算対象一括チェック
    
    //セクション表示フラグ
    public Boolean isCompanyGoalView { get; set; }
    public Boolean isShopGoalEchoView { get; set; }
    
    
    //エラーフラグ
    public Boolean isOpenError { get; set; } //エラーフラグ
    public Boolean hasErrorMessage { get; set; } //エラーメッセージ保有フラグ
    
    //表示メッセージ
    
    public String MSG_COM_V_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_SAVE);} private set;}   // js用登録確認メッセージ
    public String MSG_COM_I_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);} private set;}   // js用登録完了メッセージ
    public String MSG_REPORT_V_EXECUTE_CALC {get{return CommonUtil.callMessageCreate(CommonConst.MSG_REPORT_V_EXECUTE_CALC);} private set;}   // js用確認メッセージ
    
    //******************************************************************** Private変数 ********************************************************************
    private Date fiscalFirstDate;//会計年度開始日
    private Date fiscalLastDate; //会計年度終了日
    public String viewedTargetYear { get; set; }// 表示中対象年月
    private Date todayDate ;//本日日付
    private Integer firscalYearStartMonth;          // 会計年度期首月
    //******************************************************************** publicメソッド ********************************************************************
    
    
    //コンストラクタ
    public GEA01001Controller() {
        try{
            init();//初期化
        }catch(Exception e){
            //エラーを設定
            isOpenError = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    
    //作成または表示
    public void setDisplay() {
        try{
            hasErrorMessage = false;
            BusinessLogicException ex = new BusinessLogicException();
            
            //入力チェック
            List<String> requiredItem = new List<String>();
            
            if (String.isBlank(this.targetYear)){
                requiredItem.add('対象年');

                //ビジネスロジックException発行
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ',')));

                throw ex;
            }

            this.isShopGoalEchoView = TRUE;//店舗目標反響表示
            this.displayCompanyGoal = new displayCompanyGoal(this.firscalYearStartMonth);// 全社目標表示用内部クラス
            this.displayShopGoalList = new List<displayShopGoal>();        // 店舗目標表示用内部クラス
            this.displayIS = new displayIS(this.firscalYearStartMonth);        // 店舗目標表示用内部クラス
            this.isCompanyGoalView = TRUE;//全社目標セクションを表示する
            calcFiscalYear();//会計年度の開始日と終了日を算出
            this.viewedTargetYear = this.targetYear;//表示する対象年を保持する
            
            getCompanyGoal();//全社目標を取得
            getShopGoal();//店舗目標を取得
            calcCompanyGoalRateSum();//全社目標の月別反響目標を計算
            calculateShopGoalRateSum();//店舗目標の数式を計算
        }catch(Exception e){
            //エラーを設定
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    
    //反響/物確切替
    public void changeDisplayShopGoal() {
        try{
            hasErrorMessage = false;
            this.isShopGoalEchoView = !this.isShopGoalEchoView;
        }catch(Exception e){
            //エラーを設定
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    
    //全社目標保存
    public void saveCompanyGoal() {
        Savepoint sp = Database.setsavepoint();
        hasErrorMessage = False;
        try{
            
            hasErrorMessage = false;
            BusinessLogicException ex = new BusinessLogicException();
            
            //入力チェック
            List<String> requiredItem = new List<String>();
            
            if (String.isBlank(this.displayCompanyGoal.janRate)){
                requiredItem.add('1月');
            }
            
            if (String.isBlank(this.displayCompanyGoal.febRate)){
                requiredItem.add('2月');
            }
            
            if (String.isBlank(this.displayCompanyGoal.marRate)){
                requiredItem.add('3月');
            }
            
            if (String.isBlank(this.displayCompanyGoal.aprRate)){
                requiredItem.add('4月');
            }
            
            if (String.isBlank(this.displayCompanyGoal.mayRate)){
                requiredItem.add('5月');
            }
            
            if (String.isBlank(this.displayCompanyGoal.junRate)){
                requiredItem.add('6月');
            }
            
            if (String.isBlank(this.displayCompanyGoal.julRate)){
                requiredItem.add('7月');
            }
            
            if (String.isBlank(this.displayCompanyGoal.augRate)){
                requiredItem.add('8月');
            }
            
            if (String.isBlank(this.displayCompanyGoal.sepRate)){
                requiredItem.add('9月');
            }
            
            if (String.isBlank(this.displayCompanyGoal.octRate)){
                requiredItem.add('10月');
            }
            
            if (String.isBlank(this.displayCompanyGoal.novRate)){
                requiredItem.add('11月');
            }
            
            if (String.isBlank(this.displayCompanyGoal.decRate)){
                requiredItem.add('12月');
            }
            
            if (String.isBlank(this.displayCompanyGoal.callRate) || this.displayCompanyGoal.callRate == '0'){
                requiredItem.add('ISの呼込率(%)');
            }
            
            if (String.isBlank(this.displayCompanyGoal.applicantRate) || this.displayCompanyGoal.applicantRate == '0'){
                requiredItem.add('全体の申込率(%)');
            }
            
            
            //入力チェック用リストが空ではない場合、ビジネスロジックException発行
            if (!requiredItem.isEmpty()){
                hasErrorMessage = true;
                
                //項目名をカンマで区切って、ビジネスロジックException発行
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, '月別反響目標割合の' + String.join(requiredItem, ',')));
            }
            
            //7月(%)～6月(%)の合計が100ではない場合エラー
            calcCompanyGoalRateSum();                       // チェック前に再計算を実施
            if(companyGoalRateSum != 100){
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_TOTAL_RATE, '月別反響目標割合'));
            }
            
            //ビジネスロジックExceptionにメッセージが1つ以上ある場合、ビジネスロジックException発行
            if (ex.hasMessage()){ 
                throw ex;
            }
            
            //楽観ロックチェック
            if(this.displayCompanyGoal.id != null){
                List<CompanyGoal__c> checkOptimisticLockExceptionRecord = new List<CompanyGoal__c>();
                checkOptimisticLockExceptionRecord = [ SELECT id
                                                      FROM CompanyGoal__c
                                                      WHERE id = :this.displayCompanyGoal.id
                                                      AND SystemModStamp = :this.displayCompanyGoal.systemModstamp ];
                
                //データ取得できない場合、楽観ロックチェックExceptionを発行
                if (checkOptimisticLockExceptionRecord.isEmpty()){
                    OptimisticLockException ex2 = new OptimisticLockException();
                    throw ex2;
                }
            }
            
            //保存用全店目標設定
            CompanyGoal__c saveCompanyGoal = new CompanyGoal__c();
            
            if(this.displayCompanyGoal.id != null){
                saveCompanyGoal.Id = this.displayCompanyGoal.id;//カスタムオブジェクトID
            }
            
            
            saveCompanyGoal.TargetYear__c = this.viewedTargetYear;//対象年
            saveCompanyGoal.EchoCount__c = CommonUtil.stringToDecimal(this.displayCompanyGoal.echoCount);//反響数
            saveCompanyGoal.CallRate__c = CommonUtil.stringToDecimal(this.displayCompanyGoal.callRate);//呼込率
            saveCompanyGoal.ApplicantRate__c = CommonUtil.stringToDecimal(this.displayCompanyGoal.applicantRate);//申込率
            saveCompanyGoal.JanRate__c = CommonUtil.stringToDecimal(this.displayCompanyGoal.janRate);//1月
            saveCompanyGoal.FebRate__c = CommonUtil.stringToDecimal(this.displayCompanyGoal.febRate);//2月
            saveCompanyGoal.MarRate__c = CommonUtil.stringToDecimal(this.displayCompanyGoal.marRate);//3月
            saveCompanyGoal.AprRate__c = CommonUtil.stringToDecimal(this.displayCompanyGoal.aprRate);//4月
            saveCompanyGoal.MayRate__c = CommonUtil.stringToDecimal(this.displayCompanyGoal.mayRate);//5月
            saveCompanyGoal.JunRate__c = CommonUtil.stringToDecimal(this.displayCompanyGoal.junRate);//6月
            saveCompanyGoal.JulRate__c = CommonUtil.stringToDecimal(this.displayCompanyGoal.julRate);//7月
            saveCompanyGoal.AugRate__c = CommonUtil.stringToDecimal(this.displayCompanyGoal.augRate);//8月
            saveCompanyGoal.SepRate__c = CommonUtil.stringToDecimal(this.displayCompanyGoal.sepRate);//9月
            saveCompanyGoal.OctRate__c = CommonUtil.stringToDecimal(this.displayCompanyGoal.octRate);//10月
            saveCompanyGoal.NovRate__c = CommonUtil.stringToDecimal(this.displayCompanyGoal.novRate);//11月
            saveCompanyGoal.DecRate__c = CommonUtil.stringToDecimal(this.displayCompanyGoal.decRate);//12月
            
            SecureDML.secureUpsert(saveCompanyGoal);
            
            //再登録処理用準備
            this.displayCompanyGoal.Id = saveCompanyGoal.Id;
            this.displayCompanyGoal.systemModstamp = [SELECT SystemModStamp FROM CompanyGoal__c WHERE Id = :saveCompanyGoal.Id][0].SystemModStamp;//最終更新日時
            
        }catch(Exception e){
            //エラーを設定
            database.rollback(sp);
            hasErrorMessage = True;
            CommonUtil.setErrorMessage(e);
        }
    }
    
    
    //店舗目標(反響)保存
    public void saveEchoShopGoal() {
        Savepoint sp = Database.setsavepoint();
        hasErrorMessage = False;
        try{
            List<ShopGoal__c> saveShopGoalList =  new  List<ShopGoal__c>();
            
            //入力チェック準備
            BusinessLogicException ex = new BusinessLogicException();
            
            //楽観ロックチェック準備
            List<Id> displayShopGoalIdList = new  List<Id>();
            
            for(displayShopGoal displayShopGoal : displayShopGoalList){
                
                //楽観ロックチェック用IdList設定
                displayShopGoalIdList.add(displayShopGoal.Id);
                
                //入力チェック
                List<String> requiredItem = new List<String>();

                if (String.isBlank(displayShopGoal.averageUnitPrice)){
                    requiredItem.add('平均単価');
                }
                if (String.isBlank(displayShopGoal.echoCountGoal)){
                    requiredItem.add('呼込数');
                }
                
                
                //入力チェック用リストが空ではない場合、ビジネスロジックException発行
                if (!requiredItem.isEmpty()){
                    hasErrorMessage = true;
                    
                    //項目名をカンマで区切って、ビジネスロジックException発行
                    ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ',')));
                }
            }
            
            //ビジネスロジックExceptionにメッセージが1つ以上ある場合、ビジネスロジックException発行
            if (ex.hasMessage()){ 
                throw ex;
            }
            
            List<ShopGoal__c> ShopGoalList = [SELECT Id, systemModstamp FROM ShopGoal__c WHERE Id IN :displayShopGoalIdList ];
            
            MAP<Id,Datetime> ShopGoalSystemModstampMap = new  MAP<Id,Datetime>();
            
            for(ShopGoal__c shopGoal : ShopGoalList){
                ShopGoalSystemModstampMap.put(shopGoal.Id, shopGoal.systemModstamp);
            }
            
            //楽観ロックチェック実施
            for(displayShopGoal displayShopGoal : displayShopGoalList){
                if( displayShopGoal.systemModstamp != ShopGoalSystemModstampMap.get(displayShopGoal.id)){
                    OptimisticLockException OptimisticLockException = new OptimisticLockException();
                    throw OptimisticLockException;
                }
                
            }
            
            //保存用店舗目標設定
            for(displayShopGoal displayShopGoal : displayShopGoalList){
                
                CompanyGoal__c saveCompanyGoal = new CompanyGoal__c();
                
                if(this.displayCompanyGoal.id != null){
                    saveCompanyGoal.Id = this.displayCompanyGoal.id;//カスタムオブジェクトID
                }
                
                
                
                
                ShopGoal__c saveShopGoal = new ShopGoal__c();
                
                if(displayShopGoal.Id != null){//更新の場合のみIdを設定する
                    saveShopGoal.Id = displayShopGoal.Id;//店舗目標ID
                }else{//新規作成の場合のみ全社目標を設定する
                    saveShopGoal.CompanyGoal__c = displayCompanyGoal.Id;//全社目標ID
                }
                
                
                saveShopGoal.Shop__c = displayShopGoal.shop;//店舗ID
                
                saveShopGoal.SalesGoal__c = CommonUtil.stringToDecimal(displayShopGoal.salesGoal);//売上目標
                saveShopGoal.AverageUnitPrice__c = CommonUtil.stringToDecimal(displayShopGoal.averageUnitPrice);//平均単価
                saveShopGoal.EchoCountGoal__c = CommonUtil.stringToDecimal(displayShopGoal.echoCountGoal);//反響数（目標）
                saveShopGoal.EchoCountJan__c = CommonUtil.stringToDecimal(displayShopGoal.echoCountJan);//反響数（1月）
                saveShopGoal.EchoCountFeb__c = CommonUtil.stringToDecimal(displayShopGoal.echoCountFeb);//反響数（2月）
                saveShopGoal.EchoCountMar__c = CommonUtil.stringToDecimal(displayShopGoal.echoCountMar);//反響数（3月）
                saveShopGoal.EchoCountApr__c = CommonUtil.stringToDecimal(displayShopGoal.echoCountApr);//反響数（4月）
                saveShopGoal.EchoCountMay__c = CommonUtil.stringToDecimal(displayShopGoal.echoCountMay);//反響数（5月）
                saveShopGoal.EchoCountJun__c = CommonUtil.stringToDecimal(displayShopGoal.echoCountJun);//反響数（6月）
                saveShopGoal.EchoCountJul__c = CommonUtil.stringToDecimal(displayShopGoal.echoCountJul);//反響数（7月）
                saveShopGoal.EchoCountAug__c = CommonUtil.stringToDecimal(displayShopGoal.echoCountAug);//反響数（8月）
                saveShopGoal.EchoCountSep__c = CommonUtil.stringToDecimal(displayShopGoal.echoCountSep);//反響数（9月）
                saveShopGoal.EchoCountOct__c = CommonUtil.stringToDecimal(displayShopGoal.echoCountOct);//反響数（10月）
                saveShopGoal.EchoCountNov__c = CommonUtil.stringToDecimal(displayShopGoal.echoCountNov);//反響数（11月）
                saveShopGoal.EchoCountDec__c = CommonUtil.stringToDecimal(displayShopGoal.echoCountDec);//反響数（12月）
                
                saveShopGoalList.add(saveShopGoal);
            }

            SecureDML.secureUpsert(saveShopGoalList);
            
            //表示している店舗目標に保存結果を反映する
            List<Id> savedShopGoalIdList = new List<Id>();
            
            for(ShopGoal__c savedShopGoal : saveShopGoalList){
                savedShopGoalIdList.add(savedShopGoal.Id);
            }
            
            MAP<Id,Datetime> savedShopGoalSystemModstampMap = new  MAP<Id,Datetime>();
            
            for(ShopGoal__c shopGoal : [SELECT Id, SystemModstamp FROM ShopGoal__c WHERE ID = :savedShopGoalIdList]){
                savedShopGoalSystemModstampMap.put(shopGoal.Id, shopGoal.systemModstamp);
            }
            
            for(displayShopGoal displayShopGoal : displayShopGoalList){
                for(ShopGoal__c savedShopGoal : saveShopGoalList){
                    if(savedShopGoal.Shop__c == displayShopGoal.shop){//店舗が同じ目標が同店舗目標
                        displayShopGoal.Id = savedShopGoal.Id;
                        displayShopGoal.systemModstamp = savedShopGoalSystemModstampMap.get(savedShopGoal.Id);
                    }
                }
            }
            
            //IS店舗表を再計算
            calcDisplayIS();
            
            //再計算の結果を全社目標に保存する
            saveCompanyGoalEchoCount();
            
        }catch(Exception e){
            //エラーを設定
            database.rollback(sp);
            hasErrorMessage = True;
            CommonUtil.setErrorMessage(e);
        }
    }
    
    //店舗目標(物確)保存
    public void savePropertyConfirmationShopGoal() {
        Savepoint sp = Database.setsavepoint();
        hasErrorMessage = False;
        try{
            List<ShopGoal__c> saveShopGoalList =  new  List<ShopGoal__c>();
            
            //入力チェック準備
            BusinessLogicException ex = new BusinessLogicException();
            
            //楽観ロックチェック準備
            List<Id> displayShopGoalIdList = new  List<Id>();
            
            for(displayShopGoal displayShopGoal : displayShopGoalList){
                
                //楽観ロックチェック用IdList設定
                displayShopGoalIdList.add(displayShopGoal.Id);
                
                //入力チェック
                List<String> requiredItem = new List<String>();
                if (String.isBlank(displayShopGoal.propertyConfirmationCountGoal)){
                    requiredItem.add('物確数（目標）');
                }
                
                
                //入力チェック用リストが空ではない場合、ビジネスロジックException発行
                if (!requiredItem.isEmpty()){
                    hasErrorMessage = true;
                    
                    //項目名をカンマで区切って、ビジネスロジックException発行
                    ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ',')));
                }
            }
            
            //ビジネスロジックExceptionにメッセージが1つ以上ある場合、ビジネスロジックException発行
            if (ex.hasMessage()){ 
                throw ex;
            }
            
            List<ShopGoal__c> ShopGoalList = [SELECT Id, systemModstamp FROM ShopGoal__c WHERE Id IN :displayShopGoalIdList ];
            
            MAP<Id,Datetime> ShopGoalSystemModstampMap = new  MAP<Id,Datetime>();
            
            for(ShopGoal__c shopGoal : ShopGoalList){
                ShopGoalSystemModstampMap.put(shopGoal.Id, shopGoal.systemModstamp);
            }
            
            //楽観ロックチェック実施
            for(displayShopGoal displayShopGoal : displayShopGoalList){
                if( displayShopGoal.systemModstamp != ShopGoalSystemModstampMap.get(displayShopGoal.id)){
                    OptimisticLockException OptimisticLockException = new OptimisticLockException();
                    throw OptimisticLockException;
                }
                
            }
            
            //保存用店舗目標設定
            for(displayShopGoal displayShopGoal : displayShopGoalList){
                
                CompanyGoal__c saveCompanyGoal = new CompanyGoal__c();
                
                if(this.displayCompanyGoal.id != null){
                    saveCompanyGoal.Id = this.displayCompanyGoal.id;//カスタムオブジェクトID
                }
                
                ShopGoal__c saveShopGoal = new ShopGoal__c();
                
                if(displayShopGoal.Id != null){//更新の場合のみIdを設定する
                    saveShopGoal.Id = displayShopGoal.Id;//店舗目標ID
                }else{//新規作成の場合のみ全社目標を設定する
                    saveShopGoal.CompanyGoal__c = displayCompanyGoal.Id;//全社目標ID
                }
                
                
                saveShopGoal.Shop__c = displayShopGoal.shop;//店舗ID
                
                saveShopGoal.SalesGoal__c = CommonUtil.stringToDecimal(displayShopGoal.salesGoal);//売上目標
                saveShopGoal.AverageUnitPrice__c = CommonUtil.stringToDecimal(displayShopGoal.averageUnitPrice);//平均単価
                saveShopGoal.PropertyConfirmationCountGoal__c = CommonUtil.stringToDecimal(displayShopGoal.propertyConfirmationCountGoal);//物確数（目標）
                saveShopGoal.PropertyConfirmationCountJan__c = CommonUtil.stringToDecimal(displayShopGoal.propertyConfirmationCountJan);//物確数（1月）
                saveShopGoal.PropertyConfirmationCountFeb__c = CommonUtil.stringToDecimal(displayShopGoal.propertyConfirmationCountFeb);//物確数（2月）
                saveShopGoal.PropertyConfirmationCountMar__c = CommonUtil.stringToDecimal(displayShopGoal.propertyConfirmationCountMar);//物確数（3月）
                saveShopGoal.PropertyConfirmationCountApr__c = CommonUtil.stringToDecimal(displayShopGoal.propertyConfirmationCountApr);//物確数（4月）
                saveShopGoal.PropertyConfirmationCountMay__c = CommonUtil.stringToDecimal(displayShopGoal.propertyConfirmationCountMay);//物確数（5月）
                saveShopGoal.PropertyConfirmationCountJun__c = CommonUtil.stringToDecimal(displayShopGoal.propertyConfirmationCountJun);//物確数（6月）
                saveShopGoal.PropertyConfirmationCountJul__c = CommonUtil.stringToDecimal(displayShopGoal.propertyConfirmationCountJul);//物確数（7月）
                saveShopGoal.PropertyConfirmationCountAug__c = CommonUtil.stringToDecimal(displayShopGoal.propertyConfirmationCountAug);//物確数（8月）
                saveShopGoal.PropertyConfirmationCountSep__c = CommonUtil.stringToDecimal(displayShopGoal.propertyConfirmationCountSep);//物確数（9月）
                saveShopGoal.PropertyConfirmationCountOct__c = CommonUtil.stringToDecimal(displayShopGoal.propertyConfirmationCountOct);//物確数（10月）
                saveShopGoal.PropertyConfirmationCountNov__c = CommonUtil.stringToDecimal(displayShopGoal.propertyConfirmationCountNov);//物確数（11月）
                saveShopGoal.PropertyConfirmationCountDec__c = CommonUtil.stringToDecimal(displayShopGoal.propertyConfirmationCountDec);//物確数（12月）
                
                saveShopGoalList.add(saveShopGoal);
            }

            SecureDML.secureUpsert(saveShopGoalList);
            
            //表示している店舗目標に保存結果を反映する
            List<Id> savedShopGoalIdList = new List<Id>();
            
            for(ShopGoal__c savedShopGoal : saveShopGoalList){
                savedShopGoalIdList.add(savedShopGoal.Id);
            }
            
            MAP<Id,Datetime> savedShopGoalSystemModstampMap = new  MAP<Id,Datetime>();
            
            for(ShopGoal__c shopGoal : [SELECT Id, SystemModstamp FROM ShopGoal__c WHERE ID = :savedShopGoalIdList]){
                savedShopGoalSystemModstampMap.put(shopGoal.Id, shopGoal.systemModstamp);
            }
            
            for(displayShopGoal displayShopGoal : displayShopGoalList){
                for(ShopGoal__c savedShopGoal : saveShopGoalList){
                    if(savedShopGoal.Shop__c == displayShopGoal.shop){//店舗が同じ目標が同店舗目標
                        displayShopGoal.Id = savedShopGoal.Id;
                        displayShopGoal.systemModstamp = savedShopGoalSystemModstampMap.get(savedShopGoal.Id);
                    }
                }
            }
            
            //IS店舗表を再計算
            calcDisplayIS();
            
            
        }catch(Exception e){
            //エラーを設定
            database.rollback(sp);
            hasErrorMessage = True;
            CommonUtil.setErrorMessage(e);
        }
    }
    
    //月別反響目標計算
    public void calcCompanyGoalRateSum(){


        this.companyGoalRateSum = 0;

        //入力されている値を合計する
        if(String.isNotBlank(this.displayCompanyGoal.janRate)){//1月
            this.companyGoalRateSum += CommonUtil.stringToDecimal(this.displayCompanyGoal.janRate);
        }

        if(String.isNotBlank(this.displayCompanyGoal.febRate)){//2月
            this.companyGoalRateSum += CommonUtil.stringToDecimal(this.displayCompanyGoal.febRate);
        }

        if(String.isNotBlank(this.displayCompanyGoal.marRate)){//3月
            this.companyGoalRateSum += CommonUtil.stringToDecimal(this.displayCompanyGoal.marRate);
        }

        if(String.isNotBlank(this.displayCompanyGoal.aprRate)){//4月
            this.companyGoalRateSum += CommonUtil.stringToDecimal(this.displayCompanyGoal.aprRate);
        }

        if(String.isNotBlank(this.displayCompanyGoal.mayRate)){//5月
            this.companyGoalRateSum += CommonUtil.stringToDecimal(this.displayCompanyGoal.mayRate);
        }

        if(String.isNotBlank(this.displayCompanyGoal.junRate)){//6月
            this.companyGoalRateSum += CommonUtil.stringToDecimal(this.displayCompanyGoal.junRate);
        }

        if(String.isNotBlank(this.displayCompanyGoal.julRate)){//7月
            this.companyGoalRateSum += CommonUtil.stringToDecimal(this.displayCompanyGoal.julRate);
        }

        if(String.isNotBlank(this.displayCompanyGoal.augRate)){//8月
            this.companyGoalRateSum += CommonUtil.stringToDecimal(this.displayCompanyGoal.augRate);
        }

        if(String.isNotBlank(this.displayCompanyGoal.sepRate)){//9月
            this.companyGoalRateSum += CommonUtil.stringToDecimal(this.displayCompanyGoal.sepRate);
        }

        if(String.isNotBlank(this.displayCompanyGoal.octRate)){//10月
            this.companyGoalRateSum += CommonUtil.stringToDecimal(this.displayCompanyGoal.octRate);
        }

        if(String.isNotBlank(this.displayCompanyGoal.novRate)){//11月
            this.companyGoalRateSum += CommonUtil.stringToDecimal(this.displayCompanyGoal.novRate);
        }

        if(String.isNotBlank(this.displayCompanyGoal.decRate)){//12月
            this.companyGoalRateSum += CommonUtil.stringToDecimal(this.displayCompanyGoal.decRate);
        }
        
    }
    
    //店舗呼込/物確計算
    public void calculateShopGoalRateSum(){
        //全店舗再計算
        for(displayShopGoal displayShopGoal : displayShopGoalList){

            //計算用の値を設定する
            displayShopGoal.calcDisplayShopGoal = new ShopGoal__c();
            
            displayShopGoal.calcDisplayShopGoal.EchoCountJan__c = CommonUtil.stringToDecimal(displayShopGoal.echoCountJan);//反響数（1月）
            displayShopGoal.calcDisplayShopGoal.EchoCountFeb__c = CommonUtil.stringToDecimal(displayShopGoal.echoCountFeb);//反響数（2月）
            displayShopGoal.calcDisplayShopGoal.EchoCountMar__c = CommonUtil.stringToDecimal(displayShopGoal.echoCountMar);//反響数（3月）
            displayShopGoal.calcDisplayShopGoal.EchoCountApr__c = CommonUtil.stringToDecimal(displayShopGoal.echoCountApr);//反響数（4月）
            displayShopGoal.calcDisplayShopGoal.EchoCountMay__c = CommonUtil.stringToDecimal(displayShopGoal.echoCountMay);//反響数（5月）
            displayShopGoal.calcDisplayShopGoal.EchoCountJun__c = CommonUtil.stringToDecimal(displayShopGoal.echoCountJun);//反響数（6月）
            displayShopGoal.calcDisplayShopGoal.EchoCountJul__c = CommonUtil.stringToDecimal(displayShopGoal.echoCountJul);//反響数（7月）
            displayShopGoal.calcDisplayShopGoal.EchoCountAug__c = CommonUtil.stringToDecimal(displayShopGoal.echoCountAug);//反響数（8月）
            displayShopGoal.calcDisplayShopGoal.EchoCountSep__c = CommonUtil.stringToDecimal(displayShopGoal.echoCountSep);//反響数（9月）
            displayShopGoal.calcDisplayShopGoal.EchoCountOct__c = CommonUtil.stringToDecimal(displayShopGoal.echoCountOct);//反響数（10月）
            displayShopGoal.calcDisplayShopGoal.EchoCountNov__c = CommonUtil.stringToDecimal(displayShopGoal.echoCountNov);//反響数（11月）
            displayShopGoal.calcDisplayShopGoal.EchoCountDec__c = CommonUtil.stringToDecimal(displayShopGoal.echoCountDec);//反響数（12月）
            
            displayShopGoal.calcDisplayShopGoal.PropertyConfirmationCountJan__c = CommonUtil.stringToDecimal(displayShopGoal.propertyConfirmationCountJan);//物確数（1月）
            displayShopGoal.calcDisplayShopGoal.PropertyConfirmationCountFeb__c = CommonUtil.stringToDecimal(displayShopGoal.propertyConfirmationCountFeb);//物確数（2月）
            displayShopGoal.calcDisplayShopGoal.PropertyConfirmationCountMar__c = CommonUtil.stringToDecimal(displayShopGoal.propertyConfirmationCountMar);//物確数（3月）
            displayShopGoal.calcDisplayShopGoal.PropertyConfirmationCountApr__c = CommonUtil.stringToDecimal(displayShopGoal.propertyConfirmationCountApr);//物確数（4月）
            displayShopGoal.calcDisplayShopGoal.PropertyConfirmationCountMay__c = CommonUtil.stringToDecimal(displayShopGoal.propertyConfirmationCountMay);//物確数（5月）
            displayShopGoal.calcDisplayShopGoal.PropertyConfirmationCountJun__c = CommonUtil.stringToDecimal(displayShopGoal.propertyConfirmationCountJun);//物確数（6月）
            displayShopGoal.calcDisplayShopGoal.PropertyConfirmationCountJul__c = CommonUtil.stringToDecimal(displayShopGoal.propertyConfirmationCountJul);//物確数（7月）
            displayShopGoal.calcDisplayShopGoal.PropertyConfirmationCountAug__c = CommonUtil.stringToDecimal(displayShopGoal.propertyConfirmationCountAug);//物確数（8月）
            displayShopGoal.calcDisplayShopGoal.PropertyConfirmationCountSep__c = CommonUtil.stringToDecimal(displayShopGoal.propertyConfirmationCountSep);//物確数（9月）
            displayShopGoal.calcDisplayShopGoal.PropertyConfirmationCountOct__c = CommonUtil.stringToDecimal(displayShopGoal.propertyConfirmationCountOct);//物確数（10月）
            displayShopGoal.calcDisplayShopGoal.PropertyConfirmationCountNov__c = CommonUtil.stringToDecimal(displayShopGoal.propertyConfirmationCountNov);//物確数（11月）
            displayShopGoal.calcDisplayShopGoal.PropertyConfirmationCountDec__c = CommonUtil.stringToDecimal(displayShopGoal.propertyConfirmationCountDec);//物確数（12月）
            
            //数式の再計算
            displayShopGoal.calcDisplayShopGoal.recalculateFormulas();

            displayShopGoal.echoCountTotal = CommonUtil.decimalToString(displayShopGoal.calcDisplayShopGoal.EchoCountTotal__c);
            
            //物確の目標数を設定
            displayShopGoal.propertyConfirmationCountGoal = CommonUtil.decimalToString(displayShopGoal.calcDisplayShopGoal.PropertyConfirmationCountTotal__c);
        }
        //結果をIS店舗表時に反映
        calcDisplayIS();
    }
    
    //店舗売上目標計算
    public void calculateShopGoalSales(){
        //平均単価と反響数（割振）に値が入っている場合、売上目標を(平均単価×反響数（割振）)×申込率×呼込率（万単位以下は四捨五入）で再計算。
        
        Decimal applicantRate = 0;//申込率
        Decimal callRate = 0;//呼込率
        
        //入力されている場合設定する
        if(String.isNotBlank(displayCompanyGoal.applicantRate)){//申込率
            applicantRate = CommonUtil.stringToDecimal(displayCompanyGoal.applicantRate);
        }
        if(String.isNotBlank(displayCompanyGoal.callRate)){//呼込数
            callRate = CommonUtil.stringToDecimal(displayCompanyGoal.callRate);
        }

        
        //%に直す
        applicantRate = applicantRate/100;
        callRate = callRate/100;
        
        //全店舗再計算
        for(displayShopGoal displayShopGoal : displayShopGoalList){

            //入力されている場合設定する
            Decimal averageUnitPrice = 0; 
            Decimal echoCountGoal = 0;

            if(String.isNotBlank(displayShopGoal.averageUnitPrice)){//申込率
                averageUnitPrice = CommonUtil.stringToDecimal(displayShopGoal.averageUnitPrice);
            }
            if(String.isNotBlank(displayShopGoal.echoCountGoal)){//反響数
                echoCountGoal = CommonUtil.stringToDecimal(displayShopGoal.echoCountGoal);
            }
            
            Decimal salesGoal;//売上目標
            
            if(averageUnitPrice > 0 && echoCountGoal > 0){
                salesGoal = (averageUnitPrice*echoCountGoal)*applicantRate*callRate;
                
                //万単位以下は四捨五入
                salesGoal = (salesGoal/10000).setScale(0, RoundingMode.HALF_UP)*10000;//万単位以下を一時的に小数にして四捨五入を実施
                
                displayShopGoal.salesGoal = CommonUtil.decimalToString(salesGoal);
            }else{//平均単価と反響数（割振）に値が入っていない場合0に設定
                displayShopGoal.salesGoal = '0';
            }
            
            
        }
        //結果をIS店舗表時に反映
        calcDisplayIS();
    }
    
    //月別再計算
    public void calculateShopGoalEchoCount(){
        //呼込数×月別反響目標割合（小数点切り捨て）が7月～6月に入力される。
        
        
        Decimal janRate = 0;
        if(String.isNotBlank(displayCompanyGoal.janRate)){
            janRate = CommonUtil.stringToDecimal(displayCompanyGoal.janRate);//1月
        }
        janRate = janRate/100;//%に直す
        
        Decimal febRate = 0;
        if(String.isNotBlank(displayCompanyGoal.febRate)){
            febRate = CommonUtil.stringToDecimal(displayCompanyGoal.febRate);//2月
        }
        febRate = febRate/100;//%に直す
        
        Decimal marRate = 0;
        if(String.isNotBlank(displayCompanyGoal.marRate)){
            marRate =  CommonUtil.stringToDecimal(displayCompanyGoal.marRate);//3月
        }
        marRate = marRate/100;//%に直す
        
        Decimal aprRate = 0;
        if(String.isNotBlank(displayCompanyGoal.aprRate)){
            aprRate =  CommonUtil.stringToDecimal(displayCompanyGoal.aprRate);//4月
        }
        aprRate = aprRate/100;//%に直す
        
        Decimal mayRate = 0;
        if(String.isNotBlank(displayCompanyGoal.mayRate)){
            mayRate =  CommonUtil.stringToDecimal(displayCompanyGoal.mayRate);//5月
        }
        mayRate = mayRate/100;//%に直す
        
        Decimal junRate = 0;
        if(String.isNotBlank(displayCompanyGoal.junRate)){
            junRate =  CommonUtil.stringToDecimal(displayCompanyGoal.junRate);//6月
        }
        junRate = junRate/100;//%に直す
        
        Decimal julRate = 0;
        if(String.isNotBlank(displayCompanyGoal.julRate)){
            julRate =  CommonUtil.stringToDecimal(displayCompanyGoal.julRate);//7月
        }
        julRate = julRate/100;//%に直す
        
        Decimal augRate = 0;
        if(String.isNotBlank(displayCompanyGoal.augRate)){
            augRate =  CommonUtil.stringToDecimal(displayCompanyGoal.augRate);//8月
        }
        augRate = augRate/100;//%に直す
        
        Decimal sepRate = 0;
        if(String.isNotBlank(displayCompanyGoal.sepRate)){
            sepRate =  CommonUtil.stringToDecimal(displayCompanyGoal.sepRate);//9月
        }
        sepRate = sepRate/100;//%に直す
        
        Decimal octRate = 0;
        if(String.isNotBlank(displayCompanyGoal.octRate)){
            octRate =  CommonUtil.stringToDecimal(displayCompanyGoal.octRate);//10月
        }
        octRate = octRate/100;//%に直す
        
        Decimal novRate = 0;
        if(String.isNotBlank(displayCompanyGoal.novRate)){
            novRate =  CommonUtil.stringToDecimal(displayCompanyGoal.novRate);//11月
        }
        novRate = novRate/100;//%に直す
        
        Decimal decRate = 0;
        if(String.isNotBlank(displayCompanyGoal.decRate)){
            decRate =  CommonUtil.stringToDecimal(displayCompanyGoal.decRate);//12月
        }
        decRate = decRate/100;//%に直す
        
        //全店舗再計算
        for(displayShopGoal displayShopGoal : displayShopGoalList){
            if(displayShopGoal.isCheckbox){

                Decimal echoCountGoal = 0;

                //入力されているの場合設定する
                if(String.isNotBlank(displayShopGoal.echoCountGoal)){//反響数
                    echoCountGoal = CommonUtil.stringToDecimal(displayShopGoal.echoCountGoal);
                }
                
                Decimal echoCountJan = janRate*echoCountGoal;
                Decimal echoCountFeb = febRate*echoCountGoal;
                Decimal echoCountMar = marRate*echoCountGoal;
                Decimal echoCountApr = aprRate*echoCountGoal;
                Decimal echoCountMay = mayRate*echoCountGoal;
                Decimal echoCountJun = junRate*echoCountGoal;
                Decimal echoCountJul = julRate*echoCountGoal;
                Decimal echoCountAug = augRate*echoCountGoal;
                Decimal echoCountSep = sepRate*echoCountGoal;
                Decimal echoCountOct = octRate*echoCountGoal;
                Decimal echoCountNov = novRate*echoCountGoal;
                Decimal echoCountDec = decRate*echoCountGoal;
                
                //小数点以下切り捨て
                echoCountJan = echoCountJan.setScale(0, RoundingMode.DOWN);
                echoCountFeb = echoCountFeb.setScale(0, RoundingMode.DOWN);
                echoCountMar = echoCountMar.setScale(0, RoundingMode.DOWN);
                echoCountApr = echoCountApr.setScale(0, RoundingMode.DOWN);
                echoCountMay = echoCountMay.setScale(0, RoundingMode.DOWN);
                echoCountJun = echoCountJun.setScale(0, RoundingMode.DOWN);
                echoCountJul = echoCountJul.setScale(0, RoundingMode.DOWN);
                echoCountAug = echoCountAug.setScale(0, RoundingMode.DOWN);
                echoCountSep = echoCountSep.setScale(0, RoundingMode.DOWN);
                echoCountOct = echoCountOct.setScale(0, RoundingMode.DOWN);
                echoCountNov = echoCountNov.setScale(0, RoundingMode.DOWN);
                echoCountDec = echoCountDec.setScale(0, RoundingMode.DOWN);
                
                Decimal echoCountGoalSetScale = echoCountJan;
                
                echoCountGoalSetScale += echoCountFeb;
                echoCountGoalSetScale += echoCountMar;
                echoCountGoalSetScale += echoCountApr;
                echoCountGoalSetScale += echoCountMay;
                echoCountGoalSetScale += echoCountJun;
                echoCountGoalSetScale += echoCountJul;
                echoCountGoalSetScale += echoCountAug;
                echoCountGoalSetScale += echoCountSep;
                echoCountGoalSetScale += echoCountOct;
                echoCountGoalSetScale += echoCountNov;
                echoCountGoalSetScale += echoCountDec;
                
                Decimal echoCountfraction = echoCountGoal - echoCountGoalSetScale;
                
                //端数を最終月に寄せる
                echoCountJun += echoCountfraction;//反響数（6月）
                
                displayShopGoal.echoCountJan = CommonUtil.decimalToString(echoCountJan);//反響数（1月）
                displayShopGoal.echoCountFeb = CommonUtil.decimalToString(echoCountFeb);//反響数（2月）
                displayShopGoal.echoCountMar = CommonUtil.decimalToString(echoCountMar);//反響数（3月）
                displayShopGoal.echoCountApr = CommonUtil.decimalToString(echoCountApr);//反響数（4月）
                displayShopGoal.echoCountMay = CommonUtil.decimalToString(echoCountMay);//反響数（5月）
                displayShopGoal.echoCountJun = CommonUtil.decimalToString(echoCountJun);//反響数（6月）
                displayShopGoal.echoCountJul = CommonUtil.decimalToString(echoCountJul);//反響数（7月）
                displayShopGoal.echoCountAug = CommonUtil.decimalToString(echoCountAug);//反響数（8月）
                displayShopGoal.echoCountSep = CommonUtil.decimalToString(echoCountSep);//反響数（9月）
                displayShopGoal.echoCountOct = CommonUtil.decimalToString(echoCountOct);//反響数（10月）
                displayShopGoal.echoCountNov = CommonUtil.decimalToString(echoCountNov);//反響数（11月）
                displayShopGoal.echoCountDec = CommonUtil.decimalToString(echoCountDec);//反響数（12月）
                
                
            }
        }
        //結果を呼込数(合計)に反映
        calculateShopGoalRateSum();
        
        //結果をIS店舗表時に反映
        calcDisplayIS();
    }
    
    
    //*********************************************************  privateメソッド  ************************************************************
    
    
    //初期化処理
    private void init(){
        //店舗異動が取得できなければエラー
        CommonUtil.getStaffCurrentShop();
        this.isCompanyGoalView = FALSE;//全社目標セクション非表示
        this.isShopGoalEchoView = TRUE;//店舗目標反響表示
        this.displayCompanyGoal = new displayCompanyGoal(this.firscalYearStartMonth);// 全社目標表示用内部クラス
        this.displayShopGoalList = new List<displayShopGoal>();        // 店舗目標表示用内部クラス
        this.displayIS = new displayIS(this.firscalYearStartMonth);        // 店舗目標表示用内部クラス
        this.todayDate = CommonUtil.getToday(); // 本日
        
        //現在の年度と会計年度期首月を設定
        Organization orgInfo = [SELECT FiscalYearStartMonth, UsesStartDateAsFiscalYearName FROM Organization WHERE id = :Userinfo.getOrganizationId()];
        this.targetYear = String.valueOf(CommonUtil.calcFiscalYear(todayDate, orgInfo));
        this.firscalYearStartMonth = orgInfo.FiscalYearStartMonth;

        // 表示月の登録（会計年度期首月から順番）
        this.displayMonths = new List<Integer>();
        for (Integer idx = 0; idx < 12; idx++) {
            this.displayMonths.add(GEA01001Controller.idxToMonth(this.firscalYearStartMonth, idx));
        }
    }
    
    //会計年度の開始日と終了日を算出
    private void calcFiscalYear(){

        //年をDATE型の範囲内に修正
        if(CommonUtil.stringToDecimal(this.targetYear) < 1700){
            this.targetYear = '1700';
        }else if(CommonUtil.stringToDecimal(this.targetYear) > 4000){
            this.targetYear = '4000';
        }

        Organization orgInfo = [SELECT FiscalYearStartMonth, UsesStartDateAsFiscalYearName FROM Organization WHERE id = :Userinfo.getOrganizationId()];
        this.fiscalFirstDate = CommonUtil.calcFiscalYearStartEndDate(this.targetYear, orgInfo, true);
        this.fiscalLastDate = CommonUtil.calcFiscalYearStartEndDate(this.targetYear, orgInfo, false); 
    }
    
    //全社目標取得
    private void getCompanyGoal() {
        List <CompanyGoal__c> companyGoalList = [SELECT Id//カスタムオブジェクト ID
                                                 ,SystemModstamp//System Modstamp
                                                 ,TargetYear__c//対象年
                                                 ,EchoCount__c//反響数
                                                 ,CallRate__c//呼込率
                                                 ,ApplicantRate__c//申込率
                                                 ,JanRate__c//1月
                                                 ,FebRate__c//2月
                                                 ,MarRate__c//3月
                                                 ,AprRate__c//4月
                                                 ,MayRate__c//5月
                                                 ,JunRate__c//6月
                                                 ,JulRate__c//7月
                                                 ,AugRate__c//8月
                                                 ,SepRate__c//9月
                                                 ,OctRate__c//10月
                                                 ,NovRate__c//11月
                                                 ,DecRate__c//12月
                                                 FROM CompanyGoal__c
                                                 WHERE TargetYear__c = :targetYear
                                                ];
        
        
        if (!companyGoalList.isEmpty()){//全社目標取得できた場合設定する
            this.displayCompanyGoal = new displayCompanyGoal(companyGoalList[0], this.firscalYearStartMonth);     // 全社目標表示用内部クラス更新
        }else{
            this.displayCompanyGoal = new displayCompanyGoal(this.firscalYearStartMonth);        // 全社目標表示用内部クラス新規
        }
        
    }
    
    //全店舗目標取得
    private void getShopGoal() {
        //対象全店舗取得
        List<Shop__c> shopList = [SELECT Id
                                  ,NAME 
                                  ,(SELECT Id
                                    ,Name//店舗目標番号
                                    ,SystemModstamp//System Modstamp
                                    ,CompanyGoal__c//全社目標
                                    ,Shop__c//店舗
                                    ,SalesGoal__c//売上目標
                                    ,AverageUnitPrice__c//平均単価
                                    ,EchoCountGoal__c//反響数（目標）
                                    ,PropertyConfirmationCountGoal__c//物確数（目標）
                                    ,EchoCountJan__c//反響数（1月）
                                    ,EchoCountFeb__c//反響数（2月）
                                    ,EchoCountMar__c//反響数（3月）
                                    ,EchoCountApr__c//反響数（4月）
                                    ,EchoCountMay__c//反響数（5月）
                                    ,EchoCountJun__c//反響数（6月）
                                    ,EchoCountJul__c//反響数（7月）
                                    ,EchoCountAug__c//反響数（8月）
                                    ,EchoCountSep__c//反響数（9月）
                                    ,EchoCountOct__c//反響数（10月）
                                    ,EchoCountNov__c//反響数（11月）
                                    ,EchoCountDec__c//反響数（12月）
                                    ,PropertyConfirmationCountJan__c//物確数（1月）
                                    ,PropertyConfirmationCountFeb__c//物確数（2月）
                                    ,PropertyConfirmationCountMar__c//物確数（3月）
                                    ,PropertyConfirmationCountApr__c//物確数（4月）
                                    ,PropertyConfirmationCountMay__c//物確数（5月）
                                    ,PropertyConfirmationCountJun__c//物確数（6月）
                                    ,PropertyConfirmationCountJul__c//物確数（7月）
                                    ,PropertyConfirmationCountAug__c//物確数（8月）
                                    ,PropertyConfirmationCountSep__c//物確数（9月）
                                    ,PropertyConfirmationCountOct__c//物確数（10月）
                                    ,PropertyConfirmationCountNov__c//物確数（11月）
                                    ,PropertyConfirmationCountDec__c//物確数（12月）
                                    ,EchoCountTotal__c//反響数（合計）
                                    ,PropertyConfirmationCountTotal__c//物確数（合計）
                                    FROM ShopGoalShop__r
                                    WHERE CompanyGoal__c = :displayCompanyGoal.id
                                   )
                                  FROM  Shop__c
                                  WHERE IsShopType__c = TRUE //店舗区分
                                  //年度が被っている
                                  AND (
                                      (SystemUseEndDate__c   >= :this.fiscalFirstDate )
                                      AND
                                      (SystemUseStartDate__c <= :this.fiscalLastDate  )
                                  )
                                  AND SystemUseStartDate__c <= :this.todayDate //開始日が過去
                                  ORDER BY SortOrder__c ASC
                                 ];
        for(Shop__c shop : shopList){
            displayShopGoalList.add(new displayShopGoal(shop, this.firscalYearStartMonth));
        }
    }    
    
    //IS店舗情報計算
    private void calcDisplayIS(){
        this.displayIS = new displayIS(this.firscalYearStartMonth);// 店舗目標表示用内部クラス

        
        Decimal echoCountGoalSum = 0;//反響数合計（目標）
        Decimal echoCountJanSum = 0;//反響数合計（1月）
        Decimal echoCountFebSum = 0;//反響数合計（2月）
        Decimal echoCountMarSum = 0;//反響数合計（3月）
        Decimal echoCountAprSum = 0;//反響数合計（4月）
        Decimal echoCountMaySum = 0;//反響数合計（5月）
        Decimal echoCountJunSum = 0;//反響数合計（6月）
        Decimal echoCountJulSum = 0;//反響数合計（7月）
        Decimal echoCountAugSum = 0;//反響数合計（8月）
        Decimal echoCountSepSum = 0;//反響数合計（9月）
        Decimal echoCountOctSum = 0;//反響数合計（10月）
        Decimal echoCountNovSum = 0;//反響数合計（11月）
        Decimal echoCountDecSum = 0;//反響数合計（12月）
        Decimal echoCountTotalSum = 0;//反響数（合計）合計
        Decimal echoCountCallRate = 0;//呼込数

        //呼込数計算用の値取得
        
        Decimal callRate = 0;//呼込率
        
        //入力されている場合設定する
        if(String.isNotBlank(displayCompanyGoal.callRate)){//呼込数
            callRate = CommonUtil.stringToDecimal(displayCompanyGoal.callRate);
        }
        
        for(displayShopGoal displayShopGoal : displayShopGoalList){
            if(String.isNotBlank(displayShopGoal.echoCountGoal)){//反響数合計（目標）
                echoCountGoalSum += CommonUtil.stringToDecimal(displayShopGoal.echoCountGoal);
            }
            if(String.isNotBlank(displayShopGoal.echoCountJan)){//反響数合計（1月）
                echoCountJanSum += CommonUtil.stringToDecimal(displayShopGoal.echoCountJan);
            }
            if(String.isNotBlank(displayShopGoal.echoCountFeb)){//反響数合計（2月）
                echoCountFebSum += CommonUtil.stringToDecimal(displayShopGoal.echoCountFeb);
            }
            if(String.isNotBlank(displayShopGoal.echoCountMar)){//反響数合計（3月）
                echoCountMarSum += CommonUtil.stringToDecimal(displayShopGoal.echoCountMar);//反響数合計（3月）
            }
            if(String.isNotBlank(displayShopGoal.echoCountApr)){//反響数合計（4月）
                echoCountAprSum += CommonUtil.stringToDecimal(displayShopGoal.echoCountApr);
            }
            if(String.isNotBlank(displayShopGoal.echoCountMay)){//反響数合計（5月）
                echoCountMaySum += CommonUtil.stringToDecimal(displayShopGoal.echoCountMay);
            }
            if(String.isNotBlank(displayShopGoal.echoCountJun)){//反響数合計（6月）
                echoCountJunSum += CommonUtil.stringToDecimal(displayShopGoal.echoCountJun);
            }
            if(String.isNotBlank(displayShopGoal.echoCountJul)){//反響数合計（7月）
                echoCountJulSum += CommonUtil.stringToDecimal(displayShopGoal.echoCountJul);
            }
            if(String.isNotBlank(displayShopGoal.echoCountAug)){//反響数合計（8月）
                echoCountAugSum += CommonUtil.stringToDecimal(displayShopGoal.echoCountAug);
            }
            if(String.isNotBlank(displayShopGoal.echoCountSep)){//反響数合計（9月）
                echoCountSepSum += CommonUtil.stringToDecimal(displayShopGoal.echoCountSep);
            }
            if(String.isNotBlank(displayShopGoal.echoCountOct)){//反響数合計（10月）
                echoCountOctSum += CommonUtil.stringToDecimal(displayShopGoal.echoCountOct);
            }
            if(String.isNotBlank(displayShopGoal.echoCountNov)){//反響数合計（11月）
                echoCountNovSum += CommonUtil.stringToDecimal(displayShopGoal.echoCountNov);
            }
            if(String.isNotBlank(displayShopGoal.echoCountDec)){//反響数合計（12月）
                echoCountDecSum += CommonUtil.stringToDecimal(displayShopGoal.echoCountDec);
            }


            echoCountTotalSum += displayShopGoal.calcDisplayShopGoal.EchoCountTotal__c;//反響数（合計）合計
        }
        
        this.displayIS.echoCountGoalSum = CommonUtil.decimalToString(echoCountGoalSum);//反響数合計（目標）
        this.displayIS.echoCountJanSum = CommonUtil.decimalToString(echoCountJanSum);//反響数合計（1月）
        this.displayIS.echoCountFebSum = CommonUtil.decimalToString(echoCountFebSum);//反響数合計（2月）
        this.displayIS.echoCountMarSum = CommonUtil.decimalToString(echoCountMarSum);//反響数合計（3月）
        this.displayIS.echoCountAprSum = CommonUtil.decimalToString(echoCountAprSum);//反響数合計（4月）
        this.displayIS.echoCountMaySum = CommonUtil.decimalToString(echoCountMaySum);//反響数合計（5月）
        this.displayIS.echoCountJunSum = CommonUtil.decimalToString(echoCountJunSum);//反響数合計（6月）
        this.displayIS.echoCountJulSum = CommonUtil.decimalToString(echoCountJulSum);//反響数合計（7月）
        this.displayIS.echoCountAugSum = CommonUtil.decimalToString(echoCountAugSum);//反響数合計（8月）
        this.displayIS.echoCountSepSum = CommonUtil.decimalToString(echoCountSepSum);//反響数合計（9月）
        this.displayIS.echoCountOctSum = CommonUtil.decimalToString(echoCountOctSum);//反響数合計（10月）
        this.displayIS.echoCountNovSum = CommonUtil.decimalToString(echoCountNovSum);//反響数合計（11月）
        this.displayIS.echoCountDecSum = CommonUtil.decimalToString(echoCountDecSum);//反響数合計（12月）
        
        this.displayIS.echoCountTotalSum = CommonUtil.decimalToString(echoCountTotalSum);//反響数（合計）合計
        
        //呼込数を計算「呼込数：反響数＊（画面上部のISの呼込率（％））※四捨五入」
        callRate = callRate/100;//%に直す

        echoCountCallRate = echoCountGoalSum * callRate;//反響数＊（画面上部のISの呼込率（％））
        echoCountCallRate = echoCountCallRate.setScale(0, RoundingMode.HALF_UP);//四捨五入

        this.displayIS.echoCountCallRate = CommonUtil.decimalToString(echoCountCallRate);//呼込数

        //全社目標の反響数に反響数（合計）合計設定
        this.displayCompanyGoal.echoCount = CommonUtil.decimalToString(echoCountTotalSum);//全社目標反響数
    }
    
    //全社目標の反響数のみ保存
    private void saveCompanyGoalEchoCount() {

        //楽観ロックチェック
        if(this.displayCompanyGoal.id != null){
            List<CompanyGoal__c> checkOptimisticLockExceptionRecord = new List<CompanyGoal__c>();
            checkOptimisticLockExceptionRecord = [ SELECT id
                                                  FROM CompanyGoal__c
                                                  WHERE id = :this.displayCompanyGoal.id
                                                  AND SystemModStamp = :this.displayCompanyGoal.systemModstamp ];
            
            //データ取得できない場合、楽観ロックチェックExceptionを発行
            if (checkOptimisticLockExceptionRecord.isEmpty()){
                OptimisticLockException ex2 = new OptimisticLockException();
                throw ex2;
            }
        }
        
        //保存用全店目標設定
        CompanyGoal__c saveCompanyGoal = new CompanyGoal__c();
        
        saveCompanyGoal.Id = this.displayCompanyGoal.id;//カスタムオブジェクトID
        
        saveCompanyGoal.EchoCount__c = CommonUtil.stringToDecimal(this.displayCompanyGoal.echoCount);//反響数のみ更新
        
        SecureDML.secureUpsert(saveCompanyGoal);
        
        //再登録処理用準備
        this.displayCompanyGoal.Id = saveCompanyGoal.Id;
        this.displayCompanyGoal.systemModstamp = [SELECT SystemModStamp FROM CompanyGoal__c WHERE Id = :saveCompanyGoal.Id][0].SystemModStamp;//最終更新日時
        
    }

    // インデックス（月の表示順0始まり）から月数に変換
    private static Integer idxToMonth(Integer firscalYearStartMonth, Integer idx) {
        Integer month = firscalYearStartMonth + idx;
        month = (month > 12) ? month - 12 : month;
        return month;
    }

    // 月数からインデックスに変換
    private static Integer monthToIdx(Integer firscalYearStartMonth, Integer month) {
        Integer idx = month - firscalYearStartMonth;
        idx = (idx < 0) ? idx + 12 : idx;
        return idx;
    }

    // Decimal型からString方への変換（Nullの場合はブランクに変更）
    private static String decimalToStringEx(Decimal dec) {
        if (dec == null) {
            return CommonConst.STRING_EMPTY;
        } else {
            return CommonUtil.decimalToString(dec);
        }
    }

    //***************************************************** 内部クラス *****************************************************************
    
    //全社目標の内部クラス
    public class displayCompanyGoal{
        public String id { get; set; }//カスタムオブジェクト ID
        public Datetime systemModstamp { get; set; }//System Modstamp
        public String targetYear { get; set; }//対象年
        public String echoCount { get; set; }//反響数
        public String callRate { get; set; }//呼込率
        public String applicantRate { get; set; }//申込率
        public String[] rates { get; set; }                     // 月別レートのリスト

        // リストに登録するようになったため、get/set先を変更
        public String janRate { get { return getRate(1);  } set { setRate(1, value);  } }       // 1月
        public String febRate { get { return getRate(2);  } set { setRate(2, value);  } }       // 2月
        public String marRate { get { return getRate(3);  } set { setRate(3, value);  } }       // 3月
        public String aprRate { get { return getRate(4);  } set { setRate(4, value);  } }       // 4月
        public String mayRate { get { return getRate(5);  } set { setRate(5, value);  } }       // 5月
        public String junRate { get { return getRate(6);  } set { setRate(6, value);  } }       // 6月
        public String julRate { get { return getRate(7);  } set { setRate(7, value);  } }       // 7月
        public String augRate { get { return getRate(8);  } set { setRate(8, value);  } }       // 8月
        public String sepRate { get { return getRate(9);  } set { setRate(9, value);  } }       // 9月
        public String octRate { get { return getRate(10); } set { setRate(10, value); } }       // 10月
        public String novRate { get { return getRate(11); } set { setRate(11, value); } }       // 11月
        public String decRate { get { return getRate(12); } set { setRate(12, value); } }       // 12月

        // ***** Private変数 *****
        private Integer firscalYearStartMonth;       // 会計年度期首月

        //コンストラクタ(新規)
        public displayCompanyGoal(){
        }
        
        public displayCompanyGoal(Integer firscalYearStartMonth){
            this.firscalYearStartMonth = firscalYearStartMonth;     // 会計年度期首月
            rates = new List<String>();
            for (Integer i = 0; i < 12; i++) {
                rates.add('');
            }
        } 
        
        //コンストラクタ(全社目標)
        public displayCompanyGoal(CompanyGoal__c inCompanyGoal, Integer firscalYearStartMonth){

            this.id = inCompanyGoal.Id; //全社目標ID
            this.systemModstamp = inCompanyGoal.SystemModstamp; //System Modstamp
            this.targetYear = inCompanyGoal.TargetYear__c;//対象年
            this.echoCount = CommonUtil.decimalToString(inCompanyGoal.EchoCount__c);//反響数
            this.callRate = CommonUtil.decimalToString(inCompanyGoal.CallRate__c);//呼込率
            this.applicantRate = CommonUtil.decimalToString(inCompanyGoal.ApplicantRate__c);//申込率
            
            this.firscalYearStartMonth = firscalYearStartMonth;     // 会計年度期首月

            // 月別レートのリストへ登録
            rates = new List<String>();
            for (Integer i = 0; i < 12; i++) {
                Integer month = GEA01001Controller.idxToMonth(this.firscalYearStartMonth, i);
                rates.add(getRateFromCompanyGoal(inCompanyGoal, month));
            }
        }

        // 月を指定してレートを取得
        private String getRate(Integer month) {
            return this.rates[GEA01001Controller.monthToIdx(this.firscalYearStartMonth, month)];
        }

        // 月を指定してレートを登録
        private void setRate(Integer month, String value) {
            String val = (value == null)? CommonConst.STRING_EMPTY: value;
            this.rates[GEA01001Controller.monthToIdx(this.firscalYearStartMonth, month)] = val;
        }

        // 全社目標からレートを取得（月指定）
        private String getRateFromCompanyGoal(CompanyGoal__c inCompanyGoal, Integer month) {
            Decimal rate;
            switch on month {
                when 1  { rate = inCompanyGoal.janRate__c; }     // 1月
                when 2  { rate = inCompanyGoal.febRate__c; }     // 2月
                when 3  { rate = inCompanyGoal.marRate__c; }     // 3月
                when 4  { rate = inCompanyGoal.aprRate__c; }     // 4月
                when 5  { rate = inCompanyGoal.mayRate__c; }     // 5月
                when 6  { rate = inCompanyGoal.junRate__c; }     // 6月
                when 7  { rate = inCompanyGoal.julRate__c; }     // 7月
                when 8  { rate = inCompanyGoal.augRate__c; }     // 8月
                when 9  { rate = inCompanyGoal.sepRate__c; }     // 9月
                when 10 { rate = inCompanyGoal.octRate__c; }     // 10月
                when 11 { rate = inCompanyGoal.novRate__c; }     // 11月
                when 12 { rate = inCompanyGoal.decRate__c; }     // 12月
            }
            return GEA01001Controller.decimalToStringEx(rate);
        }
    }
    
    //店舗目標の内部クラス
    public class displayShopGoal{
        public String id { get; set; }//店舗目標ID
        public String shop { get; set; }//店舗ID
        public String companyGoal { get; set; }//全社目標ID
        
        public ShopGoal__c calcDisplayShopGoal { get; set; }//数式項目計算用店舗目標
        public String echoCountTotal { get; set; }//数式項目表示用:呼込数(合計)
        
        public String name { get; set; }//店舗名
        public Datetime systemModstamp { get; set; }//System Modstamp
        public boolean isCheckbox { get; set; }//チェックボックス
        
        public String salesGoal { get; set; }//売上目標
        public String averageUnitPrice { get; set; }//平均単価
        public String echoCountGoal { get; set; }//反響数（目標）
        public String propertyConfirmationCountGoal { get; set; }//物確数（目標）
        public String[] echoCounts { get; set; }                    // 月別反響数のリスト
        public String[] propertyConfirmationCounts { get; set; }    // 月別物確数のリスト

        // リストに登録するようになったため、get/set先を変更
        public String echoCountJan { get { return getEchoCount(1);  } set { setEchoCount(1, value);  } }       // 反響数（1月）
        public String echoCountFeb { get { return getEchoCount(2);  } set { setEchoCount(2, value);  } }       // 反響数（2月）
        public String echoCountMar { get { return getEchoCount(3);  } set { setEchoCount(3, value);  } }       // 反響数（3月）
        public String echoCountApr { get { return getEchoCount(4);  } set { setEchoCount(4, value);  } }       // 反響数（4月）
        public String echoCountMay { get { return getEchoCount(5);  } set { setEchoCount(5, value);  } }       // 反響数（5月）
        public String echoCountJun { get { return getEchoCount(6);  } set { setEchoCount(6, value);  } }       // 反響数（6月）
        public String echoCountJul { get { return getEchoCount(7);  } set { setEchoCount(7, value);  } }       // 反響数（7月）
        public String echoCountAug { get { return getEchoCount(8);  } set { setEchoCount(8, value);  } }       // 反響数（8月）
        public String echoCountSep { get { return getEchoCount(9);  } set { setEchoCount(9, value);  } }       // 反響数（9月）
        public String echoCountOct { get { return getEchoCount(10); } set { setEchoCount(10, value); } }       // 反響数（10月）
        public String echoCountNov { get { return getEchoCount(11); } set { setEchoCount(11, value); } }       // 反響数（11月）
        public String echoCountDec { get { return getEchoCount(12); } set { setEchoCount(12, value); } }       // 反響数（12月）
        public String propertyConfirmationCountJan { get { return getPropertyConfirmationCount(1);  } set { setPropertyConfirmationCount(1, value);  } }       // 物確数（1月）
        public String propertyConfirmationCountFeb { get { return getPropertyConfirmationCount(2);  } set { setPropertyConfirmationCount(2, value);  } }       // 物確数（2月）
        public String propertyConfirmationCountMar { get { return getPropertyConfirmationCount(3);  } set { setPropertyConfirmationCount(3, value);  } }       // 物確数（3月）
        public String propertyConfirmationCountApr { get { return getPropertyConfirmationCount(4);  } set { setPropertyConfirmationCount(4, value);  } }       // 物確数（4月）
        public String propertyConfirmationCountMay { get { return getPropertyConfirmationCount(5);  } set { setPropertyConfirmationCount(5, value);  } }       // 物確数（5月）
        public String propertyConfirmationCountJun { get { return getPropertyConfirmationCount(6);  } set { setPropertyConfirmationCount(6, value);  } }       // 物確数（6月）
        public String propertyConfirmationCountJul { get { return getPropertyConfirmationCount(7);  } set { setPropertyConfirmationCount(7, value);  } }       // 物確数（7月）
        public String propertyConfirmationCountAug { get { return getPropertyConfirmationCount(8);  } set { setPropertyConfirmationCount(8, value);  } }       // 物確数（8月）
        public String propertyConfirmationCountSep { get { return getPropertyConfirmationCount(9);  } set { setPropertyConfirmationCount(9, value);  } }       // 物確数（9月）
        public String propertyConfirmationCountOct { get { return getPropertyConfirmationCount(10); } set { setPropertyConfirmationCount(10, value); } }       // 物確数（10月）
        public String propertyConfirmationCountNov { get { return getPropertyConfirmationCount(11); } set { setPropertyConfirmationCount(11, value); } }       // 物確数（11月）
        public String propertyConfirmationCountDec { get { return getPropertyConfirmationCount(12); } set { setPropertyConfirmationCount(12, value); } }       // 物確数（12月）

        // ***** Private変数 *****
        private Integer firscalYearStartMonth;                      // 会計年度期首月

        //店名と店舗目標
        //コンストラクタ(店舗)
        public displayShopGoal(Shop__c inShop, Integer firscalYearStartMonth){
            
            init();//共通初期設定
            
            this.name = inShop.Name;//店舗名
            this.shop = inShop.Id;//店舗Id
            this.firscalYearStartMonth = firscalYearStartMonth;     // 会計年度期首月
            
            echoCounts = new List<String>();
            propertyConfirmationCounts = new List<String>();

            if(inShop.ShopGoalShop__r.size() > 0){
                this.id = inShop.ShopGoalShop__r[0].Id; //店舗目標ID
                this.systemModstamp = inShop.ShopGoalShop__r[0].SystemModstamp;//System Modstamp
                this.salesGoal = CommonUtil.decimalToString(inShop.ShopGoalShop__r[0].SalesGoal__c);//売上目標
                this.averageUnitPrice = CommonUtil.decimalToString(inShop.ShopGoalShop__r[0].AverageUnitPrice__c);//平均単価
                this.echoCountGoal = CommonUtil.decimalToString(inShop.ShopGoalShop__r[0].EchoCountGoal__c);//反響数（目標）
                this.propertyConfirmationCountGoal = CommonUtil.decimalToString(inShop.ShopGoalShop__r[0].PropertyConfirmationCountGoal__c);//物確数（目標）


                // 月別反響数／物確数のリストへ登録
                ShopGoal__c shopGoal = inShop.ShopGoalShop__r[0];
                for (Integer i = 0; i < 12; i++) {
                    Integer month = GEA01001Controller.idxToMonth(this.firscalYearStartMonth, i);
                    echoCounts.add(getEchoCountFromShop(shopGoal, month));
                    propertyConfirmationCounts.add(getPropertyConfirmationCountFromShop(shopGoal, month));
                }

            } else {
                for (Integer i = 0; i < 12; i++) {
                    echoCounts.add('');
                    propertyConfirmationCounts.add('');
                }
            }
        }
        
        //共通初期設定
        private void init(){
            this.isCheckbox = FALSE;
        }

        // 月を指定して反響数を取得
        private String getEchoCount(Integer month) {
            return this.echoCounts[GEA01001Controller.monthToIdx(this.firscalYearStartMonth, month)];
        }

        // 月を指定して反響数を登録
        private void setEchoCount(Integer month, String value) {
            String val = (value == null)? CommonConst.STRING_EMPTY: value;
            this.echoCounts[GEA01001Controller.monthToIdx(this.firscalYearStartMonth, month)] = val;
        }

        // 店舗目標から反響数を取得（月指定）
        private String getEchoCountFromShop(ShopGoal__c shopGoal, Integer month) {
            Decimal echoCount;
            switch on month {
                when 1  { echoCount = shopGoal.EchoCountJan__c; }     // 1月
                when 2  { echoCount = shopGoal.EchoCountFeb__c; }     // 2月
                when 3  { echoCount = shopGoal.EchoCountMar__c; }     // 3月
                when 4  { echoCount = shopGoal.EchoCountApr__c; }     // 4月
                when 5  { echoCount = shopGoal.EchoCountMay__c; }     // 5月
                when 6  { echoCount = shopGoal.EchoCountJun__c; }     // 6月
                when 7  { echoCount = shopGoal.EchoCountJul__c; }     // 7月
                when 8  { echoCount = shopGoal.EchoCountAug__c; }     // 8月
                when 9  { echoCount = shopGoal.EchoCountSep__c; }     // 9月
                when 10 { echoCount = shopGoal.EchoCountOct__c; }     // 10月
                when 11 { echoCount = shopGoal.EchoCountNov__c; }     // 11月
                when 12 { echoCount = shopGoal.EchoCountDec__c; }     // 12月
            }
            return GEA01001Controller.decimalToStringEx(echoCount);
        }

        // 月を指定して物確数を取得
        private String getPropertyConfirmationCount(Integer month) {
            return this.propertyConfirmationCounts[GEA01001Controller.monthToIdx(this.firscalYearStartMonth, month)];
        }

        // 月を指定して物確数を登録
        private void setPropertyConfirmationCount(Integer month, String value) {
            String val = (value == null)? CommonConst.STRING_EMPTY: value;
            this.propertyConfirmationCounts[GEA01001Controller.monthToIdx(this.firscalYearStartMonth, month)] = val;
        }

        // 店舗目標から物確数を取得（月指定）
        private String getPropertyConfirmationCountFromShop(ShopGoal__c shopGoal, Integer month) {
            Decimal propertyConfirmationCount;
            switch on month {
                when 1  { propertyConfirmationCount = shopGoal.PropertyConfirmationCountJan__c; }     // 1月
                when 2  { propertyConfirmationCount = shopGoal.PropertyConfirmationCountFeb__c; }     // 2月
                when 3  { propertyConfirmationCount = shopGoal.PropertyConfirmationCountMar__c; }     // 3月
                when 4  { propertyConfirmationCount = shopGoal.PropertyConfirmationCountApr__c; }     // 4月
                when 5  { propertyConfirmationCount = shopGoal.PropertyConfirmationCountMay__c; }     // 5月
                when 6  { propertyConfirmationCount = shopGoal.PropertyConfirmationCountJun__c; }     // 6月
                when 7  { propertyConfirmationCount = shopGoal.PropertyConfirmationCountJul__c; }     // 7月
                when 8  { propertyConfirmationCount = shopGoal.PropertyConfirmationCountAug__c; }     // 8月
                when 9  { propertyConfirmationCount = shopGoal.PropertyConfirmationCountSep__c; }     // 9月
                when 10 { propertyConfirmationCount = shopGoal.PropertyConfirmationCountOct__c; }     // 10月
                when 11 { propertyConfirmationCount = shopGoal.PropertyConfirmationCountNov__c; }     // 11月
                when 12 { propertyConfirmationCount = shopGoal.PropertyConfirmationCountDec__c; }     // 12月
            }
            return GEA01001Controller.decimalToStringEx(propertyConfirmationCount);
        }
    }
    
    //IS店舗表示用クラス
    public class displayIS{
        public String name { get; set; }//店舗名
        
        public String echoCountGoalSum { get; set; }//反響数合計（目標）
        public String echoCountCallRate { get; set; }//呼込数
        public String echoCountTotalSum { get; set; }//反響数（合計）合計
        public String[] echoCountSums { get; set; }                 // 月別反響数合計のリスト

        // リストに登録するようになったため、get/set先を変更
        public String echoCountJanSum { get { return getEchoCountSum(1);  } set { setEchoCountSum(1, value);  } }       // 反響数合計（1月）
        public String echoCountFebSum { get { return getEchoCountSum(2);  } set { setEchoCountSum(2, value);  } }       // 反響数合計（2月）
        public String echoCountMarSum { get { return getEchoCountSum(3);  } set { setEchoCountSum(3, value);  } }       // 反響数合計（3月）
        public String echoCountAprSum { get { return getEchoCountSum(4);  } set { setEchoCountSum(4, value);  } }       // 反響数合計（4月）
        public String echoCountMaySum { get { return getEchoCountSum(5);  } set { setEchoCountSum(5, value);  } }       // 反響数合計（5月）
        public String echoCountJunSum { get { return getEchoCountSum(6);  } set { setEchoCountSum(6, value);  } }       // 反響数合計（6月）
        public String echoCountJulSum { get { return getEchoCountSum(7);  } set { setEchoCountSum(7, value);  } }       // 反響数合計（7月）
        public String echoCountAugSum { get { return getEchoCountSum(8);  } set { setEchoCountSum(8, value);  } }       // 反響数合計（8月）
        public String echoCountSepSum { get { return getEchoCountSum(9);  } set { setEchoCountSum(9, value);  } }       // 反響数合計（9月）
        public String echoCountOctSum { get { return getEchoCountSum(10); } set { setEchoCountSum(10, value); } }       // 反響数合計（10月）
        public String echoCountNovSum { get { return getEchoCountSum(11); } set { setEchoCountSum(11, value); } }       // 反響数合計（11月）
        public String echoCountDecSum { get { return getEchoCountSum(12); } set { setEchoCountSum(12, value); } }       // 反響数合計（12月）

        // ***** Private変数 *****
        private Integer firscalYearStartMonth;          // 会計年度期首月

        //コンストラクタ()
        public displayIS(){
            this.name = CommonConst.SHOP_NAME_IS;//IS固定
        }
        public displayIS(Integer firscalYearStartMonth){
            this.name = CommonConst.SHOP_NAME_IS;//IS固定
            this.firscalYearStartMonth = firscalYearStartMonth;     // 会計年度期首月

            // 月別反響数合計のリストへ登録（0固定）
            echoCountSums = new List<string>();
            for (Integer i = 0; i < 12; i++) {
                echoCountSums.add(CommonUtil.decimalToString(0));
            }
        }

        // 月を指定して反響数を取得
        private String getEchoCountSum(Integer month) {
            return this.echoCountSums[GEA01001Controller.monthToIdx(this.firscalYearStartMonth, month)];
        }

        // 月を指定して反響数を登録
        private void setEchoCountSum(Integer month, String value) {
            String val = (value == null)? CommonConst.STRING_EMPTY: value;
            this.echoCountSums[GEA01001Controller.monthToIdx(this.firscalYearStartMonth, month)] = val;
        }
        
    }
}