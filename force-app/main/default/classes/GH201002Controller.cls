/* *
* 店舗登録画面
*/
public inherited sharing class GH201002Controller {
    
    //パブリック変数
    public ScreenShop screenTargetRecord { get; set; } //画面表示用の内部クラスレコード
    public Boolean isNew { get; set; }    //新規登録フラグ
    public Boolean isOpenError { get; set; }    //エラーフラグ
    public Boolean hasErrorMessage { get; set; }    //エラーメッセージ保有フラグ
    public List<SelectOption>  SelectStateList { get; set; }    //都道府県選択リスト
    public List<SelectOption>  SelectDistrictList { get; set; }    //取扱地区選択リスト
    public List<portalSiteStatement>  portalSiteStatementList { get; set; }    //ポータル明細リスト
    public Integer  portalSiteStatementWith { get; set; }    //ポータル明細セル割合
    public String MSG_COM_V_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_SAVE);} private set;}    //js用保存確認メッセージ
    public String MSG_COM_I_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);} private set;}    //js用保存完了メッセージ
    public String MSG_COM_V_DELETE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_DELETE);} private set;}    //js用削除確認メッセージ
    public String MSG_COM_I_DELETE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_DELETE);} private set;}    //js用削除完了メッセージ

    // ポータルサイト構築 追加 Start
    // 処理インデックス関連
    public Integer selectPhotoIndex             { get; set; }   // 対象写真インデックス

    // 写真処理関連
    public GD901001ParameterClass shopPhotoGD901001Parameter1 { get; set;}   // 店舗写真1
    public GD901001ParameterClass shopPhotoGD901001Parameter2 { get; set;}   // 店舗写真2
    public GD901001ParameterClass shopPhotoGD901001Parameter3 { get; set;}   // 店舗写真3
    public GD901001ParameterClass shopPhotoGD901001Parameter4 { get; set;}   // 店舗写真4
    public GD901001ParameterClass shopPhotoGD901001Parameter5 { get; set;}   // 店舗写真5
    public GD901001ParameterClass shopPhotoGD901001Parameter6 { get; set;}   // 店舗写真6
    public GD901001ParameterClass shopPhotoGD901001Parameter7 { get; set;}   // 店舗写真7
    public GD901001ParameterClass shopPhotoGD901001Parameter8 { get; set;}   // 店舗写真8
    // ポータルサイト構築 追加 End
    public GD901001ParameterClass shopPhotoGD901001ParameterAppearance { get; set;}   //問合せNo0535で追加　// 外観写真
    
    public GA102006ParameterClass GA102006Parameter{get; set;}
    
    //プライベート変数
    private ID targetId;    //対象ID
    
    //コンストラクタ
    public GH201002Controller(){
        
        try{
            //初期化
            init();
            
            //対象IDを取得する
            this.targetId = ApexPages.currentPage().getParameters().get('id');
            //this.targetId = 'a0a0T000000Cj6NQAS';
            
            
            //対象IDが取得できない場合は新規登録フラグにTRUEを設定する
            if(this.targetId == null){
                this.isNew = true;
                this.screenTargetRecord = new ScreenShop(new Shop__c());
                
                //対象IDが取得できた場合は新規登録フラグにFALSEを設定する
            } else {
                this.isNew = false;
                this.screenTargetRecord = new ScreenShop(SelectRecordInfo(this.targetId)); 

                // ポータルサイト構築 追加 Start
                // 店舗写真の取得
                setShopPhotoList();
                // ポータルサイト構築 追加 End
            }
            //ポータル明細情報取得
            selectportalSiteStatement(this.targetId); 
            
        } catch(Exception e) {
            
            //エラーを設定
            isOpenError = true;
            CommonUtil.setErrorMessage(e);
            
        }
    }
    
    
    
    //削除ボタン押下処理
    public void targetRecordDelete(){
        Savepoint sp = Database.setSavepoint();      //セーブポイント作成
        try{
            hasErrorMessage = false;

            // ポータルサイト構築 追加 Start
            // 写真情報削除
            AmazonS3Util.callShopPhotoDeleteAll(this.screenTargetRecord.targetRecord.id);
            // ポータルサイト構築 追加 End

            //レコード削除
            SecureDML.secureDelete(screenTargetRecord.targetRecord);
            
        }catch(Exception e){
            
            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
            
        }
    }    
    
    //保存ボタン押下処理
    public void targetRecordSave(){

        // 経度緯度取得
        getLongitudeLatitude();

        Savepoint sp = Database.setSavepoint();      //セーブポイント作成
        try{
            hasErrorMessage = false;
            
            //入力チェック
            List<String> requiredItem = new List<String>();
            if (String.isBlank(screenTargetRecord.name)){
                requiredItem.add('店舗名');
            }
            
            
            BusinessLogicException businessLogicException = new BusinessLogicException();
            //入力チェック用リストが空ではない場合、ビジネスロジックException発行
            if (!requiredItem.isEmpty()){
                
                //項目名をカンマで区切って、ビジネスロジックException発行
                businessLogicException.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ',')));
            
            }

            //メールアドレス入力チェック
            if(CommonUtil.isWrongMailString(screenTargetRecord.email)){

                //ビジネスロジックException発行
                businessLogicException.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_MAILADDRESS_VALIDATION, 'メールアドレス'));
            
            }

            //システム利用開始＜システム利用終了チェック
            if(screenTargetRecord.systemUseStartDate > screenTargetRecord.systemUseEndDate){

                //ビジネスロジックException発行                
                //終了日に開始日より前の日付が設定されています。終了日は開始日以降を設定してください。
                businessLogicException.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_DATE_TERM));
            
            }

            //ポータルサイト掲載開始＜ポータルサイト掲載終了チェック
            if(screenTargetRecord.potalCooperationStartDate > screenTargetRecord.potalCooperationEndDate){

                //ビジネスロジックException発行
                //終了日に開始日より前の日付が設定されています。終了日は開始日以降を設定してください。
                businessLogicException.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_DATE_TERM));
            
            }


            //Exceptionがあればthrow
            if(businessLogicException.hasMessage()){
                throw businessLogicException;
            }

            
            //新規でない場合、データ取得処理を実施
            if (!isNew){
                List<Shop__c> checkOptimisticLockExceptionRecord = new List<Shop__c>();
                checkOptimisticLockExceptionRecord = [ SELECT id
                                                      FROM Shop__c
                                                      WHERE id = :this.screenTargetRecord.targetRecord.Id
                                                      AND SystemModStamp = :this.screenTargetRecord.targetRecord.systemModStamp ];
                
                //データ取得できない場合、楽観ロックチェックExceptionを発行
                if (checkOptimisticLockExceptionRecord.isEmpty()){
                    OptimisticLockException optimisticLockException = new OptimisticLockException();
                    throw optimisticLockException;
                }
            }

            //保存処理実行
            Shop__c upsertRecord = new Shop__c(
                Id                 = this.screenTargetRecord.targetRecord.Id
                ,Name               = this.screenTargetRecord.name
                ,Email__c           = this.screenTargetRecord.email
                ,Phone__c           = this.screenTargetRecord.phone
                ,Fax__c             = this.screenTargetRecord.fax
                ,PostalCode__c      = this.screenTargetRecord.postalCode
                ,State__c           = this.screenTargetRecord.state
                ,City__c            = this.screenTargetRecord.city
                ,Street__c          = this.screenTargetRecord.street
                ,District__c        = this.screenTargetRecord.district
                ,BusinessHours__c   = this.screenTargetRecord.businessHours
                ,RegularHoliday__c  = this.screenTargetRecord.regularHoliday
                ,Homepage__c        = this.screenTargetRecord.homepage
                ,AffiliationAssociation__c   = this.screenTargetRecord.affiliationAssociation
                ,SystemUseStartDate__c       = this.screenTargetRecord.systemUseStartDate
                ,SystemUseEndDate__c         = this.screenTargetRecord.systemUseEndDate
                ,PotalCooperationStartDate__c= this.screenTargetRecord.potalCooperationStartDate
                ,PotalCooperationEndDate__c  = this.screenTargetRecord.potalCooperationEndDate
                ,SuumoCompanyCode__c         = this.screenTargetRecord.suumoCompanyCode
                ,SuumoBranchCode__c          = this.screenTargetRecord.suumoBranchCode
                ,AthomeYourCompanyId__c      = this.screenTargetRecord.athomeYourCompanyId
                ,AthomeYourShopId__c         = this.screenTargetRecord.athomeYourShopId
                ,HomesMemberNumber__c        = this.screenTargetRecord.homesMemberNumber
                ,InvoiceRegistNumber__c        = this.screenTargetRecord.invoiceRegistNumber
				,ChintaiCompanyCode__c        = this.screenTargetRecord.chintaiCompanyCode	// 2022.03.24 CHINTAI対応により追記
				,IsChintaiPanoramaContract__c = this.screenTargetRecord.isChintaiPanoramaContract	// 2022.03.24 CHINTAI対応により追記
                // ポータルサイト構築 追加 Start
                ,ShopIntroduce__c            = this.screenTargetRecord.shopIntroduce   // 店舗紹介
                ,Access__c                   = this.screenTargetRecord.access          // アクセス
                ,Parking__c                  = this.screenTargetRecord.parking         // 駐車場
                ,Longitude__c                = this.screenTargetRecord.longitude       // 経度
                ,Latitude__c                 = this.screenTargetRecord.latitude        // 緯度
                // ポータルサイト構築 追加 End
                ,CompanyName__c                 = this.screenTargetRecord.companyName                   // 会社名
                ,QualificationLicensesNumber__c = this.screenTargetRecord.qualificationLicensesNumber   // 資格免許番号
            );

            SecureDML.secureUpsert(upsertRecord);
        }catch(Exception e){
            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
            
        }
    }

    // ポータルサイト構築 追加 Start
    // 写真アップロード後処理
    public void updateShopPhoto() {
        try {
            this.hasErrorMessage = false;
            // SystemModStampの変更有無を取得する
            // 物件写真を更新する
            if(this.selectPhotoIndex == 1){
                AmazonS3Util.savePhoto(this.shopPhotoGD901001Parameter1);
            }else if(this.selectPhotoIndex == 2){
                AmazonS3Util.savePhoto(this.shopPhotoGD901001Parameter2);
            }else if(this.selectPhotoIndex == 3){
                AmazonS3Util.savePhoto(this.shopPhotoGD901001Parameter3);
            }else if(this.selectPhotoIndex == 4){
                AmazonS3Util.savePhoto(this.shopPhotoGD901001Parameter4);
            }else if(this.selectPhotoIndex == 5){
                AmazonS3Util.savePhoto(this.shopPhotoGD901001Parameter5);
            }else if(this.selectPhotoIndex == 6){
                AmazonS3Util.savePhoto(this.shopPhotoGD901001Parameter6);
            }else if(this.selectPhotoIndex == 7){
                AmazonS3Util.savePhoto(this.shopPhotoGD901001Parameter7);
            }else if(this.selectPhotoIndex == 8){
                AmazonS3Util.savePhoto(this.shopPhotoGD901001Parameter8);
            //▼問合せNo0535で追加
            }else if(this.selectPhotoIndex == 9){
                // 外観写真
                AmazonS3Util.savePhoto(this.shopPhotoGD901001ParameterAppearance);
                //▲問合せNo0535で追加
            }

            // 画像情報の再取得
            setShopPhoto();

        } catch(Exception e) {
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // 写真画像削除処理
    public void deleteShopPhoto(){
        try {
            this.hasErrorMessage = false;

            // 画像削除
            AmazonS3Util.callPhotoDelete(this.screenTargetRecord.targetRecord.Id
                                        , AmazonS3Util.PhotoType.SHOP, this.selectPhotoIndex);
            // 画像情報の再取得
            setShopPhoto();

        } catch(Exception e) {
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    // ポータルサイト構築 追加 End
    
    public void GA102006FormOpen() {
        GA102006Parameter.isDrawing = true;
        GA102006Parameter.noFirst = true;
        
        GA102006Parameter.isAddressMoster = TRUE;  /** 住所マスタフラグ */
        GA102006Parameter.postalCode = this.screenTargetRecord.postalCode;  /** 郵便番号 */     
        GA102006Parameter.state = this.screenTargetRecord.state;    /** 都道府県 */       
        GA102006Parameter.city = this.screenTargetRecord.city;    /** 市区町村 */  
        GA102006Parameter.street = null;    /** 町域 */    
    }
    
    public void GA102006FormClose() {
        this.screenTargetRecord.postalCode = GA102006Parameter.postalCode;  /** 郵便番号 */   
        this.screenTargetRecord.state = GA102006Parameter.state;    /** 都道府県 */    
        this.screenTargetRecord.city = GA102006Parameter.city + GA102006Parameter.street;    /** 市区町村 */  
        this.screenTargetRecord.street = null;    /** 町域 */  
        
    }
    
    //初期化メソッド
    private void init(){
        this.isNew = false;
        this.isOpenError = false;
        this.hasErrorMessage = false;

        //店舗異動が取得できなければエラー
        CommonUtil.getStaffCurrentShop();
        this.SelectStateList = CommonUtil.getSelectOptionFromObject('Shop__c','State__c');
        this.SelectDistrictList = CommonUtil.getSelectOptionFromObject('Shop__c','District__c');
        
        this.portalSiteStatementList = new List<portalSiteStatement>(); //ポータル明細リスト初期化
        this.portalSiteStatementWith = 0; //ポータル明細セル割合初期化
        
        this.GA102006Parameter = new GA102006ParameterClass();
    }
    
    //レコード情報取得
    private Shop__c SelectRecordInfo(Id targetId){
        List<Shop__c> targetRecordList = [SELECT id,
                                          Name,
                                          Email__c,
                                          Phone__c,
                                          Fax__c,
                                          PostalCode__c,
                                          State__c,
                                          City__c,
                                          Street__c,
                                          District__c,
                                          BusinessHours__c,
                                          RegularHoliday__c,
                                          Homepage__c,
                                          AffiliationAssociation__c,                                              
                                          SystemUseStartDate__c, 
                                          SystemUseEndDate__c,
                                          PotalCooperationStartDate__c,
                                          PotalCooperationEndDate__c,
                                          SuumoCompanyCode__c,
                                          SuumoBranchCode__c,
                                          AthomeYourCompanyId__c,
                                          AthomeYourShopId__c,
                                          HomesMemberNumber__c,
                                          InvoiceRegistNumber__c,
                                          PortalSitePostingDistrict__c,
                                          IsSuumoPropertyShow__c,
                                          IsHomesPropertyShow__c,
                                          IsAtHomePropertyShow__c,
										  // ▼ 2022.03.24 CHINTAI対応により追記
										  IsChintaiPropertyShow__c,
                                          ChintaiCompanyCode__c,
                                          IsChintaiPanoramaContract__c,
										  // ▲ 2022.03.24 CHINTAI対応により追記
                                          // ポータルサイト構築 変更 Start
                                          PhotoFileName1__c ,
                                          Photo1__c         ,
                                          PhotoFilePath1__c ,
                                          PhotoFileName2__c ,
                                          Photo2__c         ,
                                          PhotoFilePath2__c ,
                                          PhotoFileName3__c ,
                                          Photo3__c         ,
                                          PhotoFilePath3__c ,
                                          PhotoFileName4__c ,
                                          Photo4__c         ,
                                          PhotoFilePath4__c ,
                                          PhotoFileName5__c ,
                                          Photo5__c         ,
                                          PhotoFilePath5__c ,
                                          PhotoFileName6__c ,
                                          Photo6__c         ,
                                          PhotoFilePath6__c ,
                                          PhotoFileName7__c ,
                                          Photo7__c         ,
                                          PhotoFilePath7__c ,
                                          PhotoFileName8__c ,
                                          Photo8__c         ,
                                          PhotoFilePath8__c ,
                                          ShopIntroduce__c  ,
                                          Access__c         ,
                                          Parking__c        ,      
                                          ForeignID__c      ,
                                          Longitude__c      ,
                                          Latitude__c       ,
                                          Address__c        ,
                                          // ポータルサイト構築 変更 End 
                                          //▼問合せNo0535で追加 外観写真
                                          AppearancePhotoFileName__c  ,
                                          AppearancePhoto__c          ,
                                          AppearancePhotoFilePath__c  ,
                                          //▲問合せNo0535で追加
                                          CompanyName__c    ,
                                          QualificationLicensesNumber__c    ,
                                          SystemModStamp 
                                          FROM Shop__c 
                                          WHERE id = :this.targetId ];
        
        //レコード情報が取得できなければビジネスロジックException発行
        if( targetRecordList.isEmpty() ){
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
            throw ex;
        }
        
        return targetRecordList[0];
    }
    
    //ポータル明細情報取得 
    private void selectportalSiteStatement(Id targetId){

        List<AggregateResult> suumoCountList = new List<AggregateResult>();
        List<AggregateResult> homesCountList = new List<AggregateResult>();
        List<AggregateResult> athomeCountList = new List<AggregateResult>();
		List<AggregateResult> chintaiCountList = new List<AggregateResult>();	// 2022.03.24 CHINTAI対応により追記

        if(targetId != null){

        
        // 物件地区毎の件数(suumo)
        suumoCountList = [Select Property__r.Building__r.District__c // 物件地区
                                                ,Count(Id) suumoCountId // 件数
                                                From  PortalSitePostingProperty__c 
                                                WHERE IsSuumo__c = TRUE // 掲載するかどうか
                                                AND Shop__c = :this.targetId
                                                Group By Property__r.Building__r.District__c];
        
        // 物件地区毎の件数(homes)
        homesCountList = [Select Property__r.Building__r.District__c // 物件地区
                                                ,Count(Id) homesCountId // 件数
                                                From  PortalSitePostingProperty__c 
                                                WHERE IsHomes__c = TRUE  // 掲載するかどうか
                                                AND Shop__c = :this.targetId
                                                Group By Property__r.Building__r.District__c];
        
        // 物件地区毎の件数(athome)
        athomeCountList = [Select Property__r.Building__r.District__c // 物件地区
                                                 ,Count(Id) athomeCountId // 件数
                                                 From  PortalSitePostingProperty__c 
                                                 WHERE IsAtHome__c = TRUE  // 掲載するかどうか
                                                 AND Shop__c = :this.targetId
                                                 Group By Property__r.Building__r.District__c];
        }

		// ▼ 2022.03.24 CHINTAI対応により追記 
		// 物件地区毎の件数(CHINTAI)
		chintaiCountList = [Select Property__r.Building__r.District__c // 物件地区
												,Count(Id) chintaiCountId // 件数
												From  PortalSitePostingProperty__c
												WHERE IsChintaiNet__c = TRUE  // 掲載するかどうか
												AND Shop__c = :this.targetId
												Group By Property__r.Building__r.District__c];
		// ▲ 2022.03.24 CHINTAI対応により追記

        //  物件地区毎の件数map作成
        Map<String,Integer> suumoCountMap = new Map<String,Integer>();
        Map<String,Integer> homesCountMap = new Map<String,Integer>();
        Map<String,Integer> athomeCountMap = new Map<String,Integer>();
		Map<String, Integer> chintaiCountMap = new Map<String, Integer>();	// 2022.03.24 CHINTAI対応により追記

        /** 地区リストの選択リスト取得 */
        List<SelectOption> districtOption = CommonUtil.getSelectOptionFromObject('Shop__c', 'PortalSitePostingDistrict__c', FALSE);
        
        //  物件地区毎の件数map初期化
        for(SelectOption inDistrict : districtOption){
            suumoCountMap.put(inDistrict.getValue(), 0);
            homesCountMap.put(inDistrict.getValue(), 0);
            athomeCountMap.put(inDistrict.getValue(), 0);
			chintaiCountMap.put(inDistrict.getValue(), 0);	// 2022.03.24 CHINTAI対応により追記
        }
        
        //  物件地区毎の件数map設定(suumo)
        for(AggregateResult suumoCount : suumoCountList){
            suumoCountMap.put(String.valueOf(suumoCount.get('District__c')) , Integer.valueOf(suumoCount.get('suumoCountId')));
        }
        
        //  物件地区毎の件数map設定(homes)
        for(AggregateResult homesCount : homesCountList){
            if(homesCount.get('homesCountId') != ''){
                homesCountMap.put(String.valueOf(homesCount.get('District__c')), Integer.valueOf(homesCount.get('homesCountId')));
            }
        }
        
        //  物件地区毎の件数map設定(athome)
        for(AggregateResult athomeCount : athomeCountList){
            if(athomeCount.get('athomeCountId') != ''){
                athomeCountMap.put(String.valueOf(athomeCount.get('District__c')), Integer.valueOf(athomeCount.get('athomeCountId')));
            }
        }

		// ▼ 2022.03.24 CHINTAI対応により追記
		// 物件地区毎の件数map設定(CHINTAI)
		for(AggregateResult chintaiCount : chintaiCountList){
			if(chintaiCount.get('chintaiCountId') != ''){
				chintaiCountMap.put(String.valueOf(chintaiCount.get('District__c')), Integer.valueOf(chintaiCount.get('chintaiCountId')));
			}
		}
		// ▲ 2022.03.24 CHINTAI対応により追記
        
        // ポータル明細リストの初期化
        this.portalSiteStatementList = new List<portalSiteStatement>();
        
        // ポータル明細の設定
        for(SelectOption inDistrict : districtOption){
            // ポータル明細の初期化
            portalSiteStatement myPortalSiteStatement  = new portalSiteStatement();
            
            // ポータル明細の地区名を設定
            myPortalSiteStatement.district = inDistrict.getValue();
            
            // ポータル掲載地区の存在確認
            if(!String.isEmpty(this.screenTargetRecord.portalSitePostingDistrict)){
                
                // ポータル掲載地区の設定
                if(this.screenTargetRecord.portalSitePostingDistrict.contains(inDistrict.getValue())){
                    myPortalSiteStatement.maruBatsu = '○';
                }else{
                    myPortalSiteStatement.maruBatsu = '×';
                }
            }else{
                myPortalSiteStatement.maruBatsu = '×';
            }
            
            //ポータル明細の設定物件地区毎件数の設定
            myPortalSiteStatement.suumoCount = suumoCountMap.get(inDistrict.getValue());
            myPortalSiteStatement.homesCount = homesCountMap.get(inDistrict.getValue());
            myPortalSiteStatement.athomeCount = athomeCountMap.get(inDistrict.getValue());
			myPortalSiteStatement.chintaiCount = chintaiCountMap.get(inDistrict.getValue());	// 2022.03.24 CHINTAI対応により追記
            
            //ポータル明細をポータル明細リストに追加
            this.portalSiteStatementList.add(myPortalSiteStatement);
        }
        
        //ポータル明細リストのレイアウト設定
        if(this.portalSiteStatementList.size() > 0){
            // リスト幅を(100/地区数)%に設定
            this.portalSiteStatementWith = 100 / Integer.valueOf(this.portalSiteStatementList.size());
        }else{
            // リスト幅を0%に設定
            this.portalSiteStatementWith = 0;
        }
    }

    // ポータルサイト構築 追加 Start
    // 店舗写真の取得
    private void setShopPhotoList(){
        // コンポーネントパラメータ設定
        this.shopPhotoGD901001Parameter1 = setShopParameter(1);
        this.shopPhotoGD901001Parameter2 = setShopParameter(2);
        this.shopPhotoGD901001Parameter3 = setShopParameter(3);
        this.shopPhotoGD901001Parameter4 = setShopParameter(4);
        this.shopPhotoGD901001Parameter5 = setShopParameter(5);
        this.shopPhotoGD901001Parameter6 = setShopParameter(6);
        this.shopPhotoGD901001Parameter7 = setShopParameter(7);
        this.shopPhotoGD901001Parameter8 = setShopParameter(8);
        this.shopPhotoGD901001ParameterAppearance = setShopParameter(9);    //問合せNo0535で追加　外観写真
    }

    // アップロードの情報をセットする。
    private GD901001ParameterClass setShopParameter(Integer fileNo){
        GD901001ParameterClass photoGD901001Parameter = new GD901001ParameterClass();
        photoGD901001Parameter.isNew = this.isNew;
        photoGD901001Parameter.isMosaic = false;
        photoGD901001Parameter.photoType    = CommonConst_ptl.S3_PHOTOTYPE_SHOP;
        photoGD901001Parameter.photoSubType = CommonConst_ptl.S3_PHOTOTYPE_SHOP+ CommonUtil.decimalToString(fileNo);
        photoGD901001Parameter.parameter    = CommonUtil.decimalToString(fileNo);        // 処理対象番号
        photoGD901001Parameter.fileName = '';
        photoGD901001Parameter.filePath = '';
        photoGD901001Parameter.isArea = true;
        photoGD901001Parameter.height = '100%';
        photoGD901001Parameter.foreignId   = this.screenTargetRecord.foreignID;  // ニュースリリス外部ID

        return photoGD901001Parameter;

    }

    // 写真情報変更時の取得
    private void setShopPhoto(){
        Shop__c shopRecord = SelectRecordInfo(this.targetId);                   // 店舗情報取得

        this.screenTargetRecord.photoFileName1  = shopRecord.PhotoFileName1__c; // 写真ファイル名1
        this.screenTargetRecord.photo1          = shopRecord.Photo1__c;         // 写真1
        this.screenTargetRecord.photoFilePath1  = shopRecord.PhotoFilePath1__c; // 写真ファイルパス1
        this.screenTargetRecord.photoFileName2  = shopRecord.PhotoFileName2__c; // 写真ファイル名2
        this.screenTargetRecord.photo2          = shopRecord.Photo2__c;         // 写真2
        this.screenTargetRecord.photoFilePath2  = shopRecord.PhotoFilePath2__c; // 写真ファイルパス2
        this.screenTargetRecord.photoFileName3  = shopRecord.PhotoFileName3__c; // 写真ファイル名3
        this.screenTargetRecord.photo3          = shopRecord.Photo3__c;         // 写真3
        this.screenTargetRecord.photoFilePath3  = shopRecord.PhotoFilePath3__c; // 写真ファイルパス3
        this.screenTargetRecord.photoFileName4  = shopRecord.PhotoFileName4__c; // 写真ファイル名4
        this.screenTargetRecord.photo4          = shopRecord.Photo4__c;         // 写真4
        this.screenTargetRecord.photoFilePath4  = shopRecord.PhotoFilePath4__c; // 写真ファイルパス4
        this.screenTargetRecord.photoFileName5  = shopRecord.PhotoFileName5__c; // 写真ファイル名5
        this.screenTargetRecord.photo5          = shopRecord.Photo5__c;         // 写真5
        this.screenTargetRecord.photoFilePath5  = shopRecord.PhotoFilePath5__c; // 写真ファイルパス5
        this.screenTargetRecord.photoFileName6  = shopRecord.PhotoFileName6__c; // 写真ファイル名6
        this.screenTargetRecord.photo6          = shopRecord.Photo6__c;         // 写真6
        this.screenTargetRecord.photoFilePath6  = shopRecord.PhotoFilePath6__c; // 写真ファイルパス6
        this.screenTargetRecord.photoFileName7  = shopRecord.PhotoFileName7__c; // 写真ファイル名7
        this.screenTargetRecord.photo7          = shopRecord.Photo7__c;         // 写真7
        this.screenTargetRecord.photoFilePath7  = shopRecord.PhotoFilePath7__c; // 写真ファイルパス7
        this.screenTargetRecord.photoFileName8  = shopRecord.PhotoFileName8__c; // 写真ファイル名8
        this.screenTargetRecord.photo8          = shopRecord.Photo8__c;         // 写真8
        this.screenTargetRecord.photoFilePath8  = shopRecord.PhotoFilePath8__c; // 写真ファイルパス8
        //▼問合せNo0535で追加
        this.screenTargetRecord.appearancePhotoFileName  = shopRecord.AppearancePhotoFileName__c; // 外観写真ファイル名
        this.screenTargetRecord.appearancePhoto          = shopRecord.AppearancePhoto__c;         // 外観写真
        this.screenTargetRecord.appearancePhotoFilePath  = shopRecord.AppearancePhotoFilePath__c; // 外観写真ファイルパス
        //▲問合せNo0535で追加
        this.screenTargetRecord.foreignID       = shopRecord.ForeignID__c;      // 外部ID
        this.screenTargetRecord.targetRecord    = shopRecord;                   //ID
        
        // 写真情報のセット
        setShopPhotoList();
    }

    // 経度緯度をgoogleApiで取得
    private void getLongitudeLatitude(){
        
        //保存処理実行
        Shop__c setAddresRecord = new Shop__c(
            Id                 = this.screenTargetRecord.targetRecord.Id
            ,PostalCode__c      = this.screenTargetRecord.postalCode
            ,State__c           = this.screenTargetRecord.state
            ,City__c            = this.screenTargetRecord.city
            ,Street__c          = this.screenTargetRecord.street
            ,Longitude__c       = this.screenTargetRecord.longitude            // 経度
            ,Latitude__c        = this.screenTargetRecord.latitude             // 緯度
        );

        //都道府県、住所１（市区町村）、住所２（番地）が入力ある場合
        if(String.isNotEmpty(this.screenTargetRecord.state) 
        && String.isNotEmpty(this.screenTargetRecord.city) 
        && String.isNotEmpty(this.screenTargetRecord.street)){
            //数式再計算 (住所項目用←周辺情報取得で使用する)
            setAddresRecord.recalculateFormulas();
            // 緯度、経度取得
            Map<String,List<Double>> calculateDataMap = GoogleApiUtil.getLongitudeLatitude(setAddresRecord.Address__c);
            if(calculateDataMap != null){
                this.screenTargetRecord.latitude   = calculateDataMap.get(setAddresRecord.Address__c).get(0);     // 緯度
                this.screenTargetRecord.longitude  = calculateDataMap.get(setAddresRecord.Address__c).get(1);      // 経度
            }else{
                // 取れなければ０
                this.screenTargetRecord.longitude   = 0;     // 経度
                this.screenTargetRecord.latitude    = 0;     // 緯度
            }
        }else{
            // 取れなければ０
            this.screenTargetRecord.longitude   = 0;     // 経度
            this.screenTargetRecord.latitude    = 0;     // 緯度
        }           
        // ポータルサイト構築 追加 End
    }
    // ポータルサイト構築 追加 End
    
    //表示用の内部クラス
    public class ScreenShop{
        public Shop__c targetRecord { get; set; }//レコード本体
        
        //以下、画面用の項目
        public String titleName { get; set; }    //ヘッダー表示用取引先名
        public String name{get; set;}
        public String email{get; set;}
        public String phone{get; set;}
        public String fax{get; set;}
        public String postalCode{get; set;}
        public String state{get; set;}
        public String city{get; set;}
        public String street{get; set;}
        public String district{get; set;}
        public String businessHours{get; set;}
        public String regularHoliday{get; set;}
        public String homepage{get; set;}
        public String affiliationAssociation{get; set;}
        public Date systemUseStartDate{get; set;}
        public Date systemUseEndDate{get; set;}
        public Date potalCooperationStartDate{get; set;}
        public Date potalCooperationEndDate{get; set;}
        public String suumoCompanyCode{get; set;}
        public String suumoBranchCode{get; set;}
        public String athomeYourCompanyId{get; set;}
        public String athomeYourShopId{get; set;}
        public String homesMemberNumber{get; set;}
        public String invoiceRegistNumber{get; set;}
        public String portalSitePostingDistrict{get; set;}
        
        public Boolean isSuumoPropertyShow{get; set;}
        public Boolean isHomesPropertyShow{get; set;}
        public Boolean isAtHomePropertyShow{get; set;}

		// ▼ 2022.03.24 CHINTAI対応により追記
		public String chintaiCompanyCode{get; set;}
		public Boolean isChintaiPanoramaContract{get; set;}
		public Boolean isChintaiPropertyShow{get; set;}
		// ▲ 2022.03.24 CHINTAI対応により追記
        
        // ポータルサイト構築 追加 Start
        public String  photoFileName1  { get; set; }  // 写真ファイル名1
        public String  photo1          { get; set; }  // 写真1
        public String  photoFilePath1  { get; set; }  // 写真ファイルパス1
        public String  photoFileName2  { get; set; }  // 写真ファイル名2
        public String  photo2          { get; set; }  // 写真2
        public String  photoFilePath2  { get; set; }  // 写真ファイルパス2
        public String  photoFileName3  { get; set; }  // 写真ファイル名3
        public String  photo3          { get; set; }  // 写真3
        public String  photoFilePath3  { get; set; }  // 写真ファイルパス3
        public String  photoFileName4  { get; set; }  // 写真ファイル名4
        public String  photo4          { get; set; }  // 写真4
        public String  photoFilePath4  { get; set; }  // 写真ファイルパス4
        public String  photoFileName5  { get; set; }  // 写真ファイル名5
        public String  photo5          { get; set; }  // 写真5
        public String  photoFilePath5  { get; set; }  // 写真ファイルパス5
        public String  photoFileName6  { get; set; }  // 写真ファイル名6
        public String  photo6          { get; set; }  // 写真6
        public String  photoFilePath6  { get; set; }  // 写真ファイルパス6
        public String  photoFileName7  { get; set; }  // 写真ファイル名7
        public String  photo7          { get; set; }  // 写真7
        public String  photoFilePath7  { get; set; }  // 写真ファイルパス7
        public String  photoFileName8  { get; set; }  // 写真ファイル名8
        public String  photo8          { get; set; }  // 写真8
        public String  photoFilePath8  { get; set; }  // 写真ファイルパス8
        public String  shopIntroduce   { get; set; }  // 店舗紹介
        public String  access          { get; set; }  // アクセス
        public String  parking         { get; set; }  // 駐車場
        public String  foreignID       { get; set; }  // 外部ID
        public Decimal longitude       { get; set; }  // 経度
        public Decimal latitude        { get; set; }  // 緯度
        public String  address         { get; set; }  // 住所
         // ポータルサイト構築 追加 End
        //▼問合せNo0535で追加
        public String  appearancePhotoFileName  { get; set; }  // 外観写真ファイル名
        public String  appearancePhoto          { get; set; }  // 外観写真
        public String  appearancePhotoFilePath  { get; set; }  // 外観写真ファイルパス
        //▲問合せNo0535で追加

        public String  companyName                   { get; set; }   // 会社名
        public String  qualificationLicensesNumber   { get; set; }   // 資格免許番号

        //コンストラクタ
        public ScreenShop(Shop__c targetRecord){
            this.titleName     = targetRecord.Name;             //店舗名（タイトル用）
            this.targetRecord  = targetRecord;                 //ID
            this.name          = targetRecord.Name;             //店舗名      
            this.email         = targetRecord.Email__c;         //メール
            this.phone         = targetRecord.Phone__c;         //電話番号
            this.fax           = targetRecord.Fax__c;           //FAX
            this.postalCode    = targetRecord.PostalCode__c;    //郵便番号
            this.state         = targetRecord.State__c;         //都道府県
            this.city          = targetRecord.City__c;          //住所１（市区町村）      
            this.street        = targetRecord.Street__c;        //住所２（番地）
            this.district      = targetRecord.District__c;      //所在地区
            this.businessHours = targetRecord.BusinessHours__c; //営業時間   
            this.regularHoliday= targetRecord.RegularHoliday__c;//定休日
            this.homepage      = targetRecord.Homepage__c;      //店舗URL
            this.affiliationAssociation     = targetRecord.AffiliationAssociation__c;    //加盟協会      
            this.systemUseStartDate         = targetRecord.SystemUseStartDate__c;        //システム使用開始日
            this.systemUseEndDate           = targetRecord.SystemUseEndDate__c;          //システム使用終了日
            this.potalCooperationStartDate  = targetRecord.PotalCooperationStartDate__c; //ポータル連携開始日
            this.potalCooperationEndDate    = targetRecord.PotalCooperationEndDate__c;   //ポータル連携終了日
            this.suumoCompanyCode           = targetRecord.SuumoCompanyCode__c;          //SUUMO会社コード
            this.suumoBranchCode            = targetRecord.SuumoBranchCode__c;           //SUUMO支店コード
            this.athomeYourCompanyId        = targetRecord.AthomeYourCompanyId__c;       //at home貴社ＩＤ
            this.athomeYourShopId           = targetRecord.AthomeYourShopId__c;          //at home貴社店舗ＩＤ
            this.homesMemberNumber          = targetRecord.HomesMemberNumber__c;         //HOME'S会員番号
            this.invoiceRegistNumber        = targetRecord.InvoiceRegistNumber__c;     //インボイス制度登録番号     
            this.portalSitePostingDistrict  = targetRecord.PortalSitePostingDistrict__c;     //ポータル掲載地区  
            this.isSuumoPropertyShow  = targetRecord.IsSuumoPropertyShow__c;     //SUUMO物件名表示  
            this.isHomesPropertyShow  = targetRecord.IsHomesPropertyShow__c;     //HOME'S物件名表示  
            this.isAtHomePropertyShow  = targetRecord.IsAtHomePropertyShow__c;     //at home物件名表示
			// ▼ 2022.03.24 CHINTAI対応により追記  
			this.chintaiCompanyCode         = targetRecord.ChintaiCompanyCode__c;		// CHINTAI店舗コード
			this.isChintaiPanoramaContract = targetRecord.IsChintaiPanoramaContract__c;	// CHINTAIパノラマ掲載契約
			this.isChintaiPropertyShow = targetRecord.IsChintaiPropertyShow__c;		// CHINTAI物件名表示
			// ▲ 2022.03.24 CHINTAI対応により追記
            // ポータルサイト構築 追加 Start
            this.photoFileName1  = targetRecord.PhotoFileName1__c;  // 写真ファイル名1
            this.photo1          = targetRecord.Photo1__c;          // 写真1
            this.photoFilePath1  = targetRecord.PhotoFilePath1__c;  // 写真ファイルパス1
            this.photoFileName2  = targetRecord.PhotoFileName2__c;  // 写真ファイル名2
            this.photo2          = targetRecord.Photo2__c;          // 写真2
            this.photoFilePath2  = targetRecord.PhotoFilePath2__c;  // 写真ファイルパス2
            this.photoFileName3  = targetRecord.PhotoFileName3__c;  // 写真ファイル名3
            this.photo3          = targetRecord.Photo3__c;          // 写真3
            this.photoFilePath3  = targetRecord.PhotoFilePath3__c;  // 写真ファイルパス3
            this.photoFileName4  = targetRecord.PhotoFileName4__c;  // 写真ファイル名4
            this.photo4          = targetRecord.Photo4__c;          // 写真4
            this.photoFilePath4  = targetRecord.PhotoFilePath4__c;  // 写真ファイルパス4
            this.photoFileName5  = targetRecord.PhotoFileName5__c;  // 写真ファイル名5
            this.photo5          = targetRecord.Photo5__c;          // 写真5
            this.photoFilePath5  = targetRecord.PhotoFilePath5__c;  // 写真ファイルパス5
            this.photoFileName6  = targetRecord.PhotoFileName6__c;  // 写真ファイル名6
            this.photo6          = targetRecord.Photo6__c;          // 写真6
            this.photoFilePath6  = targetRecord.PhotoFilePath6__c;  // 写真ファイルパス6
            this.photoFileName7  = targetRecord.PhotoFileName7__c;  // 写真ファイル名7
            this.photo7          = targetRecord.Photo7__c;          // 写真7
            this.photoFilePath7  = targetRecord.PhotoFilePath7__c;  // 写真ファイルパス7
            this.photoFileName8  = targetRecord.PhotoFileName8__c;  // 写真ファイル名8
            this.photo8          = targetRecord.Photo8__c;          // 写真8
            this.photoFilePath8  = targetRecord.PhotoFilePath8__c;  // 写真ファイルパス8
            this.shopIntroduce   = targetRecord.ShopIntroduce__c;   // 店舗紹介
            this.access          = targetRecord.Access__c;          // アクセス
            this.parking         = targetRecord.Parking__c;         // 駐車場
            this.foreignID       = targetRecord.ForeignID__c;       // 外部ID
            this.longitude       = targetRecord.Longitude__c;       // 経度
            this.latitude        = targetRecord.Latitude__c;        // 緯度
            this.address         = targetRecord.Address__c;         // 住所
            // ポータルサイト構築 追加 End           
            //▼問合せNo0535で追加 
            this.appearancePhotoFileName     = targetRecord.AppearancePhotoFileName__c;         // 外観写真ファイル名
            this.appearancePhoto             = targetRecord.AppearancePhoto__c;                 // 外観写真
            this.appearancePhotoFilePath     = targetRecord.AppearancePhotoFilePath__c;         // 外観写真ファイルパス
            //▲問合せNo0535で追加
            this.companyName                 = targetRecord.CompanyName__c;                     // 会社名
            this.qualificationLicensesNumber = targetRecord.QualificationLicensesNumber__c;     // 資格免許番号

        }
    }
    
    //ポータル明細の内部クラス
    public class portalSiteStatement{
        
        //以下、画面用の項目
        public String district{get; set;}
        public String maruBatsu{get; set;}
        public Integer suumoCount{get; set;}
        public Integer homesCount{get; set;}
        public Integer athomeCount{get; set;}
        public Integer chintaiCount{get; set;}	// 2022.03.24 CHINTAI対応により追記
        
        //コンストラクタ
        public portalSiteStatement(){
        }
    }
}