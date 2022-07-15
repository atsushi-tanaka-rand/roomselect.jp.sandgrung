/* *
* 自動メンテナンス一覧のコントローラ
*/
public inherited sharing class TD601001Controller {
    
    //******************************************************************** public変数 ********************************************************************
    
    //自動メンテナンス設定用
    public String automaintenanceType { get; set; }                      //自動メンテ種別
    public Boolean searchIsCompletedFlag { get; set; }                   //検索用完了フラグ 
    public String searchDistrict { get; set; }                           //検索用地区（エスケープした表示用）
    public Decimal searchAmountLowerLimit { get; set; }                  //検索用金額下限
    public Decimal searchAmountUpperLimit { get; set; }                  //検索用金額上限
    public Date searchFromImportDate { get; set; }                       //検索用取込日From
    public Date searchToImportDate { get; set; }                         //検索用取込日To
    public Boolean isUp  { get; set; }                                   //検索ボタン押下箇所
    public List<ScreenAutoMaintenance> screenAutoMaintenanceList { get; set; }//出力用（日本時間で表示用するため）          

    //定数
    public String  automaintenanceTypeAddnew { get; set; }               //メンテナンス種別:新規追加
    public String automaintenanceTypeConditionchangeupdate { get; set; } //メンテナンス種別:更新(条件変更)
    public String automaintenanceTypeOccupiedtovacantupdate { get; set; }//メンテナンス種別:更新(居住中→空室)
    public String automaintenanceTypeEndofposting { get; set; }          //メンテナンス種別:掲載終了
    
    //エラー確認用
    public Boolean isOpenError { get; set; }                             //エラーフラグ
    public String errorMessage { get; set; }                             //出力エラーメッセージ
    
    //******************************************************************** private関数 ********************************************************************
    
    private Integer searchLimit;                                         //検索上限（エスケープしない）
    private String searchDistrict_sql;                                   //検索用地区
    
    //******************************************************************** public関数 ********************************************************************
    
    //コンストラクタ
    public TD601001Controller(){
        
        try {
            init();//初期化
            getmaintenance();//遷移前と同条件で再検索する
        }catch(Exception e){
            isOpenError = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
            
            for(Apexpages.Message errMsg : ApexPages.getMessages()){//ページでAPEX:Messageが使えないため、ページのエラーを文字列にする
                this.errorMessage += errMsg.getDetail() + '&#13;&#10;';//Excelに出力するエラーメッセージ設定('&#13;&#10;'はExcel用改行コード)
            }
        }
    }
    
    //初期化
    public void init(){
        this.screenAutoMaintenanceList = new List<ScreenAutoMaintenance>();
        errorMessage = '';//エラーメッセージ
        searchLimit = Integer.valueOf(SystemConfig__c.getInstance().AutoMaintenanceSearchMaxCount__c);//検索上限をカスタム設定から取得
        
        //パラメータ取得
        this.automaintenanceType = Apexpages.currentPage().getParameters().get('automaintenanceType');//自動メンテ種別

        if(Apexpages.currentPage().getParameters().get('isUp') == 'true'){//検索ボタン押下箇所
            this.isUp = TRUE;
        }else{
            this.isUp = FALSE;
        }
        
        if(String.isNotBlank(Apexpages.currentPage().getParameters().get('fromImportDate')) && !this.isUp){//検索用取込日From(検索にに使用する場合のみ設定)
            this.searchFromImportDate =  Date.valueOf(Apexpages.currentPage().getParameters().get('fromImportDate').replaceAll('/', '-'));
        }else{
            this.searchFromImportDate = null;
        }
        
        if(String.isNotBlank(Apexpages.currentPage().getParameters().get('toImportDate')) && !this.isUp){//検索用取込日To(検索に使用する場合のみ設定)
            this.searchToImportDate =  Date.valueOf(Apexpages.currentPage().getParameters().get('toImportDate').replaceAll('/', '-'));
        }else{
            this.searchToImportDate = null;
        }

        this.searchDistrict = Apexpages.currentPage().getParameters().get('district');//表示用地区
        this.searchDistrict_sql = Apexpages.currentPage().getParameters().get('district');//検索用地区
        if (String.isNotBlank(this.searchDistrict)){
            this.searchDistrict = this.searchDistrict.escapeXml();
        }
        this.searchAmountLowerLimit = CommonUtil.stringToDecimal(Apexpages.currentPage().getParameters().get('amountLowerLimit'));//検索用金額下限
        
        this.searchAmountUpperLimit = CommonUtil.stringToDecimal(Apexpages.currentPage().getParameters().get('amountUpperLimit'));//検索用金額上限
        
        if(Apexpages.currentPage().getParameters().get('isCompletedFlag') == 'true'){//検索用完了フラグ
            this.searchIsCompletedFlag = TRUE;
        }else if(Apexpages.currentPage().getParameters().get('isCompletedFlag') == 'false'){
            this.searchIsCompletedFlag = FALSE;
        }else{
            this.searchIsCompletedFlag = null;
        }
        
        automaintenanceTypeAddnew = CommonConst.AUTOMAINTENANCE_TYPE_ADDNEW;//メンテナンス種別:新規追加
        automaintenanceTypeConditionchangeupdate = CommonConst.AUTOMAINTENANCE_TYPE_CONDITIONCHANGEUPDATE;//メンテナンス種別:更新(条件変更)
        automaintenanceTypeOccupiedtovacantupdate = CommonConst.AUTOMAINTENANCE_TYPE_OCCUPIEDTOVACANTUPDATE;//メンテナンス種別:更新(居住中→空室)
        automaintenanceTypeEndofposting = CommonConst.AUTOMAINTENANCE_TYPE_ENDOFPOSTING;//メンテナンス種別:掲載終了
        
    }
    
    //出力するメンテナンス一覧を取得
    public void getmaintenance(){
        try {
            isOpenError = FALSE;//エラーを初期化
            BusinessLogicException ex = new BusinessLogicException();//ビジネスロジックException準備
            
            //パラメータチェック
            if(String.isBlank(this.automaintenanceType)
               ||(this.automaintenanceType != automaintenanceTypeAddnew //メンテナンス種別:新規追加
                  &&this.automaintenanceType != automaintenanceTypeConditionchangeupdate//メンテナンス種別:更新(条件変更)
                  &&this.automaintenanceType != automaintenanceTypeOccupiedtovacantupdate//メンテナンス種別:更新(居住中→空室)
                  &&this.automaintenanceType != automaintenanceTypeEndofposting //メンテナンス種別:掲載終了
                 )){
                     ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
                 }
            
            //検索用項目宣言
            Date today = commonUtil.getToday();
            
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
            sql += ',Property__r.PropertyCode__c';//物件．物件コード	
            sql += ',CrawlingSource__c';//クローリング元	
            sql += ',AutoMaintenance__c';//自動メンテナンス内容
            sql += ',SystemModStamp';//更新日時	
            
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
            if(String.isNotBlank(this.searchDistrict_sql)){
                //建物の地区 ＝ 検索用検索地区
                sql += '   AND District__c = \'' + CommonUtil.escapeSingleQuotesEx(this.searchDistrict_sql) + '\'';
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
                       //検索用取込日をtodayに設定する
                       searchFromImportDate = today;//検索用取込日From
                       searchToImportDate = today;//検索用取込日To
                       
                       // 検索用取込日From に今日の日付の開始時間を設定
                       searchFromImportDatetime = Datetime.newInstance(today, startTime);
                       sql += '   AND ImportDatetime__c   >= :searchFromImportDatetime';
                       
                       // 検索用取込日To に今日の日付の終了時間を設定
                       searchToImportDatetime = Datetime.newInstance(today, endTime);
                       
                       //取込日 ≦ 検索用取込日To
                       sql += '   AND ImportDatetime__c   <= :searchToImportDatetime';
                       
                   }
                //新規追加or更新（居住中→空室）の場合
                //なにもしない
                
            }else{
                //検索↓四つ
                // 検索用取込日From が isNotBlank なら追加
                if(String.isNotBlank(String.valueOf(this.searchFromImportDate))){
                    searchFromImportDatetime = Datetime.newInstance(searchFromImportDate, startTime);
                    //取込日 ≧ 検索用取込日From
                    sql += '   AND ImportDatetime__c   >= :searchFromImportDatetime';
                }
                
                // 検索用取込日To が isNotBlankなら追加
                if(String.isNotBlank(String.valueOf(this.searchToImportDate))){
                    searchToImportDatetime = Datetime.newInstance(searchToImportDate, endTime);
                    //取込日 ≦ 検索用取込日To
                    sql += '   AND ImportDatetime__c   <= :searchToImportDatetime';
                }
            }
            
            //取得順序
            sql += ' ORDER BY';
            sql += '       Building__r.Name,Property__r.Name ASC';
            
            //取得数
            sql += ' LIMIT :searchLimit';
            
            
            system.debug('sql' + sql);

            //取得
            List<AutoMaintenance__c> searchResultList = Database.query(sql);

            //ビジネスロジックException発行
            if (ex.hasMessage()){ 
                throw ex;
            }
            //結果を内部クラスに入れる
            if (searchResultList.size()!= 0){
                for(AutoMaintenance__c res : searchResultList){
                    screenAutoMaintenanceList.add(new ScreenAutoMaintenance(res));
                }
            }
            system.debug('owari');
        }catch(Exception e){
            isOpenError = true;//エラーを設定
            throw e;
        }
    }
    
    //帳票出力用
    public String getXmlVer(){
        return '<?xml version="1.0"?>' + '\r\n';
    }

    //帳票出力用
    public String getXmlapp(){
        return '<?mso-application progid="Excel.Sheet"?>' + '\r\n';
    }

    //出力用内部クラス
    public class ScreenAutoMaintenance{
        public AutoMaintenance__c autoMaintenance{ get;set; }//レコード
        public String updateDate{ get;set; }//最終更新日
        public String contents{get;set; }//自動メンテナンス内容
        public String propertyName {get;set; }//物件名エスケープ
        public String buildingName {get;set; }//建物名エスケープ
        public String crawlingSource {get;set; }//クローリング元エスケープ

        public ScreenAutoMaintenance(AutoMaintenance__c res){
            if(res.id != null){
                this.autoMaintenance = res;
                this.updateDate = res.SystemModStamp.format('yyyy/MM/dd HH:mm', 'JST');
                //自動メンテナンス内容が空でない場合、エスケープ処理を行う
                if (String.isNotBlank(res.AutoMaintenance__c)){
                    this.contents = res.AutoMaintenance__c.escapeXml();
                }

                if(res.AutoMaintenance__c != null){
                    this.contents = res.AutoMaintenance__c.replace('\r\n','&#13;&#10;');//メンテナンス内容の改行コードを帳票出力用に変更する
                }

                //物件名が空でない場合、エスケープ処理を行う
                if (String.isNotBlank(res.Property__r.Name)){
                    propertyName = res.Property__r.Name.escapeXml();
                }

                //建物名が空でない場合、エスケープ処理を行う
                if (String.isNotBlank(res.Building__r.Name)){
                    buildingName = res.Building__r.Name.escapeXml();
                }

                //クローリング元が空でない場合、エスケープ処理を行う
                if (String.isNotBlank(res.CrawlingSource__c)){
                    crawlingSource = res.CrawlingSource__c.escapeXml();
                }

            }
        }
        

    }
}