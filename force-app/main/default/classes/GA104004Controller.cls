/**
 * 物件詳細
 */
public with sharing class GA104004Controller {
    /** パブリック変数 */
    public Property__c propertyTargetRecord { get; set; }   // 画面表示用の内部クラスレコード
    public ScreenAnyPhotoData publicPhotoData { get; set; } // 公開物件写真リスト
    public BuildingPhoto__c buildingPhotoData { get; set; } // 建物写真リスト
    
    // 項目
    public String facilityConditions { get; set; }          // 設備条件
    public Shop__c shopTargetRecord { get; set; }           // 店舗情報
    public String managementCompanyItem { get; set; }       // 管理会社指定商品文字列
    public String facilityRemarksPublic { get; set; }       // 設備備考（公開）
    
    // 帳票用
    public List<String> photoPageForRepeat {get; set;}      // 公開写真のページリピート用List
    public List<String> photoNumberForRepeat {get; set;}    // 公開写真の1ページ毎の写真リピート用List
    Public Integer sortPhotoCount {get; set;}               // 公開写真ページの写真数
    public List<PhotoData> sortPhotoDataListForT {get; set;}// 公開写真のリスト(帳票用)
    
    public String facilityConditionsNl { get; set; }        // 設備条件_改行版（帳票用）
    public String managementCompanyItemNl { get; set; }     // 管理会社指定商品文字列_改行版（帳票用）
    public String facilityRemarksPublicNl { get; set; }     // 設備備考（公開）_改行版（帳票用）
    public String monetaryPublicNl { get; set; }            // 条件備考_改行版（帳票用）
    public String parkingRemarksPublicNl { get; set; }      // 駐車場備考_改行版（帳票用）
    public String formerSupplierRemarksNl { get; set; }     // 備考_改行版（帳票用）
    public String aDFeeCommentNl { get; set; }              // 広告コメント_改行版（帳票用）
    public String propertyCommentNl { get; set; }           // 物件コメント_改行版（帳票用）
    public String representativeCommentNl { get; set; }     // 担当コメント_改行版（帳票用）
    public String keyPlaceNl { get; set; }                  // 鍵所在_改行版（帳票用）
    public String propertyRemarksPrivateNl { get; set; }    // 備考_改行版（帳票用）
    public String monetaryPrivateNl { get; set; }           // 金銭備考_改行版（帳票用）
    public String parkingRemarksPrivateNl { get; set; }     // 駐車場備考_改行版（帳票用）
    //▼問合せNo0486で追加
    public String fireInsuranceNameNl { get; set; }         // 火災保険_改行版（帳票用）
    public String guarantorCompanyNameNl { get; set; }      // 保証会社名_改行版（帳票用）
    public String guarantorCompanyItemNamrNl { get; set; }  // 保証会社プラン名_改行版（帳票用）
    //▲問合せNo0486で追加

    // フラグ関係
    public Boolean isOpenError { get; set; }        // エラーフラグ
    public Boolean hasErrorMessage { get; set; }    // エラーメッセージ保有フラグ
    public Boolean hasFavoriteFlg { get; set; }     // お気に入りフラグ

    // パラメータ関係
    public Id propertyId { get; set; }      // 物件ID
    public Id accountId { get; set; }       // 取引先ID
    public String motoCustomerFlg { get; set; } // お客様用フラグ（boolean変換前）
    public Boolean customerFlg { get; set; }    // お客様用フラグ
    public Boolean pictureFlg  { get; set; }    // 帳票画面用　写真印刷フラグ（true=写真印刷、false=1ページ目印刷）
    
    public String pictureAspectType1    {get; set;} // 画像縦横比　H→縦長　W→横長　間取り用
    Public String pictureAspectType2    {get; set;} // 画像縦横比　H→縦長　W→横長　外観用
    Public String pictureAspectType3    {get; set;} // 画像縦横比　H→縦長　W→横長　リビング用
    Public String pictureAspectTypeList {get; set;} // 画像縦横比　H→縦長　W→横長　公開写真List用

    // URL
    public String formLogoUrl { get{ return SystemConfig__c.getInstance().FormLogoPath__c; } }      // 帳票ロゴパス
    public Boolean formLogoIsAlive { get; set; }                                                    // 帳票ロゴの存在フラグ（VF起動時に状態取得、PDF側で使用）
    
    // メッセージ関係
    public String MSG_COM_V_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_SAVE);} private set;}   // 登録確認メッセージ
    public String MSG_COM_I_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);} private set;}   // 登録完了メッセ―じ
    public String MSG_PROP_I_BIKEPARKING_NOT_ALLRENTFEE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_PROP_I_BIKEPARKING_NOT_ALLRENTFEE);} private set;}

    //▼ 2021.09.08 No.556 対応で周辺施設のPDF出力情報を追加
    public String mapUrl       {get; set;} // 地図出力用URL

    public String primarySchoolNameAndDistanceNl { get; set; }             // 小学校（帳票用）
    public String juniorHighSchoolNameAndDistanceNl { get; set; }          // 中学校（帳票用）
    public String highSchoolNameAndDistanceNl { get; set; }                // 高校（帳票用）
    public String universityNameAndDistanceNl { get; set; }                // 大学（帳票用）
    public String convenienceStoreNameAndDistanceNl { get; set; }          // コンビニ（帳票用）
    public String supermarketNameAndDistanceNl { get; set; }               // スーパー（帳票用）
    public String generalHospitalNameAndDistanceNl { get; set; }           // 病院（帳票用）

    public Integer primarySchoolMargin { get; set;}                        // 小学校のmargin
    public Integer juniorHighSchoolMargin { get; set;}                     // 中学校のmargin
    public Integer highSchoolMargin { get; set;}                           // 高校のmargin
    public Integer universityMargin { get; set;}                           // 大学のmargin
    public Integer convenienceStoreMargin { get; set;}                     // コンビニのmargin
    public Integer supermarketMargin { get; set;}                          // スーパーのmargin
    public Integer generalHospitalMargin { get; set;}                      // 病院のmargin
    private final Integer LINE_HEIGHT = 30;                                // 行の高さ
    private final Integer DIV_HEIGHT = 170;                                // divの高さ
    //▲ 2021.09.08 No.556 対応

    /**
    * 初期表示処理
    */
    public GA104004Controller() {

        try {
            //初期化
            init();

            //パラメータを取得
            getParam();
            
            // 店舗情報を取得
            shopTargetRecord = commonUtil.getStaffCurrentShop();

            // 物件情報を取得
            propertyTargetRecord = selectPropertyRecordInfo(this.propertyId);

            // 物件写真情報を取得
            publicPhotoData = new ScreenAnyPhotoData(selectPropertyPhotoRecordInfo(this.propertyId), pictureAspectTypeList);

            // 建物写真情報を取得
            buildingPhotoData = selectBuildingPhotoRecordInfo(propertyTargetRecord.Building__r.Id);

            // 帳票用の写真ページの設定を行う
            setPhotoPageForT();
            
            
            // お気に入り設定判断
            // 取引先の指定がある場合のみ
            if ( String.isNotBlank(this.accountId) ) {

                // お気に入りフラグの設定
                hasFavoriteFlg = selectFavoriteRecordInfo(this.propertyId, this.accountId);
            }

            // 設備条件取得（共通部品）
            facilityConditions = BuildingPropertyUtil.getFacilityList(this.propertyId, '/');
            facilityConditionsNl = autoKaigyo(facilityConditions, 54);

            // 物件管理会社指定商品情報取得
            managementCompanyItem = selectPropertyManageCompayItem(this.propertyId);

            // 設備備考情報取得
            facilityRemarksPublic = selectPropertyConditionsData(this.propertyId);
            facilityRemarksPublicNl = autoKaigyo(facilityRemarksPublic, 54);

            // 帳票出力用に必要な文字情報を設定
            Integer retLength = 54;
            monetaryPublicNl = autoKaigyo(propertyTargetRecord.MonetaryPublic__c, retLength);
            parkingRemarksPublicNl = autoKaigyo(propertyTargetRecord.ParkingRemarksPublic__c, retLength);
            managementCompanyItemNl = autoKaigyo(managementCompanyItem, retLength);
            retLength = 40;
            formerSupplierRemarksNl = autoKaigyo(propertyTargetRecord.FormerSupplier__r.RemarksPublic__c, retLength);
            aDFeeCommentNl = autoKaigyo(propertyTargetRecord.ADFeeComment__c, retLength);
            propertyCommentNl = autoKaigyo(propertyTargetRecord.PropertyComment__c, retLength);
            representativeCommentNl = autoKaigyo(propertyTargetRecord.RepresentativeComment__c, retLength);
            keyPlaceNl = autoKaigyo(propertyTargetRecord.KeyPlace__c, retLength);
            propertyRemarksPrivateNl = autoKaigyo(propertyTargetRecord.PropertyRemarksPrivate__c, retLength);
            monetaryPrivateNl = autoKaigyo(propertyTargetRecord.MonetaryPrivate__c, retLength);
            parkingRemarksPrivateNl = autoKaigyo(propertyTargetRecord.ParkingRemarksPrivate__c, retLength);

            //▼問合せNo0486で追加
            // 帳票出力用に必要な文字情報を設定 火災保険と保証会社
            retLength = 25;
            fireInsuranceNameNl = autoKaigyo( propertyTargetRecord.FireInsurancePlan__r.Account__r.Name, retLength);
            guarantorCompanyNameNl = autoKaigyo(propertyTargetRecord.Guaranteeid__r.Account__r.Name, retLength);
            guarantorCompanyItemNamrNl = autoKaigyo(propertyTargetRecord.Guaranteeid__r.ItemName__c, retLength);
            //▲問合せNo0486で追加

            //▼ 2021.09.08 No.556 対応でPDFに写真と周辺施設を表示する処理を追加
            mapUrl = createMapUrl(); // PDF出力用地図のURLを作成

            retLength = 30;
            // 各周辺施設の施設名と距離の文字列を作成し、画面表示する際のmarginを計算
            createNameAndDistanceStrAndCalcMargin(retLength, propertyTargetRecord.Building__r);
            //▲ 2021.09.08 No.556 対応
        }catch (Exception e){
            // エラーを設定
            CommonUtil.setErrorMessage(e);  
            isOpenError = true;
        }
    }



    /**
     * お気に入りボタン 押下
     *  お気に入りの物件情報を保存する。
     */
    public void saveFavorite() {

        Savepoint sp = Database.setSavepoint();      //セーブポイント作成
        hasErrorMessage = false;
        BusinessLogicException ex = new BusinessLogicException();

        try{

            // お気に入り物件の登録処理
            FavoriteProperty__c FavoriteProperty = new FavoriteProperty__c();
            // 登録値設定
            FavoriteProperty.Property__c = propertyId;
            FavoriteProperty.Account__c = accountId;
            FavoriteProperty.Status__c = CommonConst.FAVORITEPROPERTY_STATUS_INTRODUCTION;
            // 登録処理     
            SecureDML.secureInsert(FavoriteProperty);

            // お気に入りフラグを更新
            hasFavoriteFlg = true;

        }catch(Exception e){
            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
            system.debug('e='+e);
        }
    }
    
    //****************************************************************************** privateメソッド *********************************************************************
    
    //初期化メソッド
    private void init(){

        // フラグ類
        isOpenError = false;
        hasErrorMessage = false;
        hasFavoriteFlg = false;
        customerFlg = false;
        this.publicPhotoData = new ScreenAnyPhotoData();
        
        // 縦横比
        this.pictureAspectType1    = 'W'; // 画像は全て横長を基本とする
        this.pictureAspectType2    = 'W'; 
        this.pictureAspectType3    = 'W';
    }
    
    // パラメータ取得
    private void getParam(){
        
        if (ApexPages.currentPage().getParameters().get('Id') instanceof Id){        
            this.propertyId      = ApexPages.currentPage().getParameters().get('Id');             // 必須
        }
        if (ApexPages.currentPage().getParameters().get('accountId') instanceof Id){
            this.accountId       = ApexPages.currentPage().getParameters().get('accountId');      // 任意
        }
        this.motoCustomerFlg = ApexPages.currentPage().getParameters().get('customerFlg');    // 任意
        if(this.motoCustomerFlg == 'true') {
            this.customerFlg = true;
        } else {
            this.customerFlg = false;
        }
        String motoPictureFlg = ApexPages.currentPage().getParameters().get('pictureFlg');    // 任意
        if(motoPictureFlg == 'true') {
            this.pictureFlg = true;
        } else {
            this.pictureFlg = false;
        }
        
        // パラメータの存在チェック（物件、取引先）
        checkInputParameter(this.propertyId, this.accountId);
        
        // パラメータを取得(画像の縦横比) ※pdfはcssが全然効かない。縦か横の長さを設定しないといけあい。
        // しかし、jsが使えない。よって前の画面で縦長か横長か判定し、その情報をパラメータで渡している。
        String pat1    =  ApexPages.currentPage().getParameters().get('pat1');
        String pat2    =  ApexPages.currentPage().getParameters().get('pat2');
        String pat3    =  ApexPages.currentPage().getParameters().get('pat3');
        String patList =  ApexPages.currentPage().getParameters().get('patList');
        
        // パラメータから縦横比を設定（あれば）
        this.pictureAspectType1    = String.isBlank(pat1)    ? this.pictureAspectType1    : pat1;
        this.pictureAspectType2    = String.isBlank(pat2)    ? this.pictureAspectType2    : pat2;
        this.pictureAspectType3    = String.isBlank(pat3)    ? this.pictureAspectType3    : pat3;
        this.pictureAspectTypeList = patList; //写真枚数が分からないので、初期化できない

        // 帳票ロゴの存在フラグを取得
        String buf    =  ApexPages.currentPage().getParameters().get('formLogoIsAlive');
        this.formLogoIsAlive = (String.isEmpty(buf) || buf.equals('true'))? true: false;
        this.formLogoIsAlive = String.isEmpty(formLogoUrl)? false: this.formLogoIsAlive;
    }
    

    // 物件ID、取引先IDの存在チェック
    private void checkInputParameter(String propertyId, String accountId) {

        // 物件情報の存在チェック
        List<Property__c> inputPropertyList = [SELECT Id FROM Property__c WHERE Id = :propertyId];
        
        //レコードが取得できない場合はビジネスロジックExceptionを発行する
        if(inputPropertyList.isEmpty()){
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
            throw ex;
        }

        if ( String.isNotBlank(accountId) ) {
            // 取引先情報の存在チェック
            List<Account> inputAccountList = [SELECT Id FROM Account WHERE Id = :accountId];
    
            // レコードが取得できない場合はビジネスロジックExceptionを発行する
            if(inputAccountList.isEmpty()){
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
                throw ex;
            }

        }

    }

    //お気に入り物件レコード情報取得
    private boolean selectFavoriteRecordInfo(Id propertyId, Id accountId){

        // お気に入り物件情報の存在チェック
        List<FavoriteProperty__c> inputFavoriteList = [SELECT Id 
                                                        FROM FavoriteProperty__c
                                                        WHERE
                                                            Property__c = :propertyId
                                                        AND Account__c = :accountId];

        // レコードが取得できない場合はお気に入り情報無しとして処理を行う
        if(inputFavoriteList.isEmpty()){
            return false;
        }

        return true;
    }

    // 物件情報取得
    private Property__c selectPropertyRecordInfo(String targetId){
  
        List<Property__c> targetPropertyList = [ 
            SELECT 
                Id
                ,Name
                ,RentFee__c
                ,ManagementFeeTax__c
                ,TownshipFeeTax__c
                ,WortFeeTax__c
                ,CATVFeeTax__c
                ,GarbageDisposalFeeTax__c
                ,BicycleParkingFeeTax__c
                ,ParkingFeeTax__c
                ,ParkingDepositTax__c
                ,BikeParkingSmallFeeTax__c
                ,BikeParkingMediumFeeTax__c
                ,BikeParkinLargeFeeTax__c
                ,SecurityDepositYen__c
                ,SecurityDepositMonth__c
                ,SecurityDepositUnit__c
                ,DepositYen__c
                ,DepositMonth__c
                ,DepositUnit__c
                ,KeyMoneyYen__c
                ,KeyMoneyMonth__c
                ,KeyMoneyUnit__c
                ,CancellationActualFeeYen__c
                ,CancellationActualFeeMonth__c
                ,CancellationActualFeeRate__c
                ,CancellationActualFeeUnit__c
                ,CleaningFeeYen__c
                ,CleaningFeeMonth__c
                ,CleaningFeeTax__c
                ,CleaningFeeUnit__c
                ,RenewalFeeYen__c
                ,RenewalFee__c
                ,RenewalFeeMonth__c
                ,RenewalFeeUnit__c
                ,TownshipInitialFeeTax__c
                ,KeyExchangeFeeTax__c
                ,ContractTermYear__c
                ,ContractTermMonth__c
                ,IsShortTermPenalty__c
                ,ShortTermPenaltyFee__c
                ,ShortTermPenaltyLessYear__c
                ,ShortTermPenaltyFee2__c
                ,ShortTermPenaltyLessYear2__c
                ,MonetaryPublic__c
                ,RoomLayout__c
                ,RoomCount__c
                ,BalconyDirection__c
                ,Floor__c
                ,RoomArea__c
                ,LiveStatus__c
                ,ParkingType__c
                ,RewardBurdenLender__c
                ,RewardBurdenBorrower__c
                ,RewardSplitFormerSupplier__c
                ,RewardSplitCustomer__c
                ,ADFeeTax__c
                ,ADFeeComment__c
                ,PropertyComment__c
                ,RepresentativeComment__c
                ,KeyPlace__c
                ,PropertyRemarksPrivate__c
                ,MonetaryPrivate__c
                ,ParkingRemarksPrivate__c
                ,TransactionAspect__c
                ,PropertyCode__c
                ,AllRentFee__c
                ,FireInsuranceUseType__c
                ,GuaranteeidCompanyType__c
                ,ParkingRemarksPublic__c
                ,BikeStorageType__c
                ,ParkingDistance__c
                // 元付業者
                ,FormerSupplier__r.Name
                ,FormerSupplierPhone__c
                ,FormerSupplierFax__c
                ,FormerSupplierEmail__c
                ,FormerSupplierPostalCode__c
                ,FormerSupplierAddress__c
                ,FormerSupplierDepartment__c
                ,FormerSupplierRepresentative__c
                ,FormerSupplierRepresentativePhone__c
                ,FormerSupplier__r.RemarksPublic__c
                // 建物
                ,Building__r.Id
                ,Building__r.Name                   // 建物名
                ,Building__r.PropertyType__c        // 物件種別
                ,Building__r.BuildingYMFormat__c    // 築年月
                ,Building__r.Structure__c           // 建物構造
                ,Building__r.GroundFloorCount__c    // 地上階数
                ,Building__r.PostalCode__c          // 郵便番号
                ,Building__r.Address__c             // 住所
                ,Building__r.TrainRoute1__r.Name    // 沿線１
                ,Building__r.Station1__r.Name       // 駅１
                ,Building__r.StationWalkTime1__c    // 駅までの時間（分）１
                //▼ 2021.09.08 No.556 対応で周辺施設の取得を追加
                ,Building__r.Longitude__c                          // 経度
                ,Building__r.Latitude__c                           // 緯度
                ,Building__r.PrimarySchool1__c                     // 小学校１Id
                ,Building__r.PrimarySchool1__r.NAME                // 小学校１
                ,Building__r.PrimarySchoolDistance1__c             // 小学校までの距離１
                ,Building__r.PrimarySchoolWalkTimeFormat1__c       // 小学校までの時間（分）１
                ,Building__r.PrimarySchool1__r.Longitude__c        // 小学校１経度
                ,Building__r.PrimarySchool1__r.Latitude__c         // 小学校１緯度
                ,Building__r.JuniorHighSchool1__c                  // 中学校１Id
                ,Building__r.JuniorHighSchool1__r.NAME             // 中学校１
                ,Building__r.JuniorHighSchoolDistance1__c          // 中学校までの距離１
                ,Building__r.JuniorHighSchoolWalkTimeFormat1__c    // 中学校までの時間（分）１
                ,Building__r.JuniorHighSchool1__r.Longitude__c     // 中学校１経度
                ,Building__r.JuniorHighSchool1__r.Latitude__c      // 中学校１緯度
                ,Building__r.HighSchool__c                         // 高校ID
                ,Building__r.HighSchool__r.NAME                    // 高校
                ,Building__r.HighSchoolDistance__c                 // 高校までの距離
                ,Building__r.HighSchoolWalkTimeFormat__c           // 高校までの時間（分）
                ,Building__r.HighSchool__r.Longitude__c            // 高校経度
                ,Building__r.HighSchool__r.Latitude__c             // 高校緯度
                ,Building__r.University__c                         // 大学ID
                ,Building__r.University__r.NAME                    // 大学
                ,Building__r.UniversityDistance__c                 // 大学までの距離
                ,Building__r.UniversityWalkTimeFormat__c           // 大学までの時間（分）
                ,Building__r.University__r.Longitude__c            // 大学経度
                ,Building__r.University__r.Latitude__c             // 大学緯度
                ,Building__r.ConvenienceStore__c                   // コンビニID
                ,Building__r.ConvenienceStore__r.NAME              // コンビニ
                ,Building__r.ConvenienceStoreDistance__c           // コンビニまでの距離
                ,Building__r.ConvenienceStoreWalkTimeFormat__c     // コンビニまでの時間（分）
                ,Building__r.ConvenienceStore__r.Longitude__c      // コンビニ経度
                ,Building__r.ConvenienceStore__r.Latitude__c       // コンビニ緯度
                ,Building__r.Supermarket__c                        // スーパーマーケットID
                ,Building__r.Supermarket__r.NAME                   // スーパーマーケット
                ,Building__r.SupermarketDistance__c                // スーパーマーケットまでの距離
                ,Building__r.SupermarketWalkTimeFormat__c          // スーパーマーケットまでの時間（分）
                ,Building__r.Supermarket__r.Longitude__c           // スーパーマーケット経度
                ,Building__r.Supermarket__r.Latitude__c            // スーパーマーケット緯度
                ,Building__r.GeneralHospital__c                    // 総合病院ID
                ,Building__r.GeneralHospital__r.NAME               // 総合病院
                ,Building__r.GeneralHospitalDistance__c            // 総合病院までの距離
                ,Building__r.GeneralHospitalWalkTimeFormat__c      // 総合病院までの時間（分）
                ,Building__r.GeneralHospital__r.Longitude__c       // 総合病院経度
                ,Building__r.GeneralHospital__r.Latitude__c        // 総合病院緯度
                //▲ 2021.09.08 No.556 対応
                // 商品（火災保険）
                ,FireInsurancePlan__r.Account__r.Name        // 火災保険会社名
                ,FireInsurancePlan__r.PaymentType__c         // 更新期間
                ,FireInsurancePlan__r.FireInsuranceMonth__c  // 火災保険料月額
                ,FireInsurancePlan__r.FireInsuranceYear__c   // 火災保険料年額
                ,FireInsurancePlan__r.PaymentYear__c         // 更新年数
                // 商品（保証）
                ,Guaranteeid__r.Account__r.Name         // 保証会社
                ,Guaranteeid__r.ItemName__c             // 商品名
            FROM Property__c
            WHERE
                Id = :targetId
            ORDER BY
                Name
                                        ];
       
        //レコードが取得できない場合はビジネスロジックExceptionを発行する
        if(targetPropertyList.isEmpty()){
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
            throw ex;
        }
        
        return targetPropertyList[0];

    }

    // 建物写真情報取得
    private BuildingPhoto__c selectBuildingPhotoRecordInfo(Id targetId){

        BuildingPhoto__c buildingPhoto = new BuildingPhoto__c();

        List<BuildingPhoto__c> buildingPhotoList = [ 
            SELECT 
                Id
                ,AppearanceFileName__c
                ,AppearanceFilePath__c
            FROM BuildingPhoto__c
            WHERE
                Building__c = :targetId
                                        ];
        if(!buildingPhotoList.isEmpty()){
            buildingPhoto = buildingPhotoList[0];

        }
        return buildingPhoto;
    }
    


    // 物件写真情報取得
    private PropertyPhoto__c selectPropertyPhotoRecordInfo(Id targetId){
    
        String sql = '';
        sql += 'SELECT Id ';
        for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PROPERTY; i++) { // 物件写真
            sql += '      ,PropertyPhotoFileName' + i + '__c ';
            sql += '      ,PropertyPhotoFilePath' + i + '__c ';
            sql += '      ,PropertyPhotoTag' + i + '__c '; 
        }
        sql += '      ,RoomLayoutFileName__c ';
        sql += '      ,RoomLayoutFilePath__c ';
        sql += '  FROM PropertyPhoto__c ';
        sql += ' WHERE Property__c   = :targetId ';

        List<PropertyPhoto__c> propertyPhoto = Database.query(sql);
        if (propertyPhoto.isEmpty()){
            propertyPhoto = new List<PropertyPhoto__c>();
            return new PropertyPhoto__c();
        }
        return propertyPhoto[0];
    }
    
    
    // 帳票用写真ページの設定
    private void setPhotoPageForT() {
        
        final Decimal PHOTO_NUMBER = 9; //1ページ当たりの写真枚数
        
        // ページ数の計算
        Decimal calcVal = (this.publicPhotoData.sortPhotoDataList.size() / PHOTO_NUMBER);
        Integer photoPageNum = (Integer)calcVal.round(System.RoundingMode.CEILING); //ページ数の計算
        
        // 帳票用のページ数　repeat用の変数設定
        photoPageForRepeat = new List<String>();
        for (Integer i = 0; i < photoPageNum; i++) {
            photoPageForRepeat.add('page');
        }
        
        // 帳票用の写真情報 repeat用の変数設定
        photoNumberForRepeat = new List<String>();
        for (Integer i = 0; i < PHOTO_NUMBER; i++) {
            photoNumberForRepeat.add('photo');
        }
        
        // 無理やり写真を表示するため、空の写真データをページ分挿入
        // ※例えば写真が21枚なら、3ページ分である27はrepaetの中で参照される。仮の値を入れておかないと添え字のエラーになる。
        this.sortPhotoCount = this.publicPhotoData.sortPhotoDataList.size(); // 本当の写真枚数を保存
        
        // 通常ページの写真をコピー
        sortPhotoDataListForT = new List<PhotoData>();
        for (Integer i = 0; i < sortPhotoCount; i++) {
            sortPhotoDataListForT.add(this.publicPhotoData.sortPhotoDataList[i]);
        }
        
        // 空の要素をページの最後まで追加
        Integer addPhotoNum = (Integer)(photoPageNum * PHOTO_NUMBER) - sortPhotoCount;
        for (Integer i = 0; i < addPhotoNum; i++) {
            sortPhotoDataListForT.add(new PhotoData());
        }
    }

    
    // 物件管理会社指定商品情報取得
    private String selectPropertyManageCompayItem(String targetId){

        List<PropertyManageCompayItem__c> propertyManageCompayItemList = [
            SELECT
                Item__r.ItemName__c,    //商品名
                Item__r.PaymentType__c, //支払区分
                Item__r.AmountTax__c    //税込み計算済価格
            FROM
                PropertyManageCompayItem__c
            WHERE
                Property__c     = :targetId
            ORDER BY
                Item__r.Name   // 商品番号
        ];
        
        String itemName = '';
        // 対象データを文字列に格納（"/"でコンカチ）
        if (!propertyManageCompayItemList.isEmpty()){
            
            itemName = BuildingPropertyUtil.createManagementCompanyItemString(propertyManageCompayItemList);
        }
        return itemName;
    }

    // 物件条件情報の取得
    private String selectPropertyConditionsData(Id targetId) {

        String biko = '';

        List<PropertyConditions__c> propertyConditionsList = [
            SELECT
                FacilityRemarksPublic__c
            FROM
                PropertyConditions__c
            WHERE
                Property__c = :targetId
        ];

        if (!propertyConditionsList.isEmpty()) {
            biko = propertyConditionsList[0].FacilityRemarksPublic__c;
        }
        return biko;
    }
    


    /**
     * 改行用メソッド（帳票出力用）
     *  PDF化時に文字が改行されなくなる為、改行コードを埋め込む
     */
    @testVisible private String autoKaigyo(String st, Integer kaigyoLength){

        String rtnSt = '';
        
        // null対応
        if (String.isBlank(st)) {
            return rtnSt;
        }
        
        Integer stLength = st.length();

        // 改行コード削除
        st = st.replaceAll('\r\n','');

        // 文字が空白、または文字数が指定改行文字数以下の場合はそのままの値を返す
        if(String.isBlank(st) || stLength <= kaigyoLength){
            rtnSt = st;
        }else{
            // 小数点を出す為にDecimal型で計算
            Decimal decimalStRows = Decimal.valueOf(stLength) / Decimal.valueOf(kaigyoLength);
            // 切り上げ処理で内容の行数を取得
            Integer stRows = Integer.valueOf(decimalStRows.round(System.RoundingMode.UP));
            // 最初の改行まで取得+改行コード付与
            rtnSt = st.substring(0, kaigyoLength) + '<wbr/>';
            // 2行目以降をループ処理
            for(Integer i = 1; i < stRows; i++){
                if(kaigyoLength*(i + 1) < stLength){
                    rtnSt += st.substring(kaigyoLength*i, kaigyoLength*(i + 1)) + '<wbr/>';
                }else{
                    // 最後の文字まで取得
                    rtnSt += st.substring(kaigyoLength*i);
                }
            }
        }
        return rtnSt;
    }

    //▼ 2021.09.08 No.556 対応でPDFに写真と周辺施設を表示する処理を追加
    /**
     * 改行用メソッド（帳票出力用）
     *  PDF化時に文字が改行されなくなる為、改行コードを埋め込む。単位(m)の位置で改行の箇所を調整する
     *  @param String 本文の文字列
     *  @param String 距離の文字列
     *  @param Integer 改行する文字数
     *  return 改行された文字列
     */
    @testVisible private String autoKaigyoAdjustDistance(String st, String distance, Integer kaigyoLength){

        String rtnSt = '';
        
        // null対応
        if (String.isBlank(st)) {
            return rtnSt;
        }
        
        Integer stLength = st.length();
        Integer distanceLength = distance.length();

        // 改行コード削除
        st = st.replaceAll('\r\n','');

        // 文字数が指定改行文字数以下の場合はそのままの値を返す
        if(stLength + distanceLength <= kaigyoLength){       
            return st + distance;
        }

        // 小数点を出す為にDecimal型で計算
        Decimal decimalStRows = Decimal.valueOf(stLength) / Decimal.valueOf(kaigyoLength);
        // 切り上げ処理で内容の行数を取得
        Integer stRows = Integer.valueOf(decimalStRows.round(System.RoundingMode.UP));
        // 文字列が改行文字列を下回っている場合、改行コードと距離を結合した文字列を返す
        if(stLength <= kaigyoLength) {
            return st + '<wbr/>' + distance;
        }

        // 最初の改行まで取得+改行コード付与
        rtnSt = st.substring(0, kaigyoLength) + '<wbr/>';
        // 2行目以降をループ処理
        for(Integer i = 1; i < stRows; i++){
            if(kaigyoLength*(i + 1) < stLength){
                rtnSt += st.substring(kaigyoLength*i, kaigyoLength*(i + 1)) + '<wbr/>';
            }else{
                // 最後の文字まで取得
                rtnSt += st.substring(kaigyoLength*i);
                // 最後の文字までの文字数 + 距離の文字列の文字数が改行文字数よりも大きい場合、改行コードを入れる
                if(st.substring(kaigyoLength*i).length() + distanceLength > kaigyoLength) {
                    rtnSt += '<wbr/>';
                }
                rtnSt += distance;
            }

        }
        return rtnSt;
    }

    /**
     * PDFに表示する地図のURLを作成する
     * return 地図のURL
     */
    private String createMapUrl() {
        String googleMapKey = SystemConfig__c.getInstance().GoogleMapKey__c; //googleMapのAPIキーをカスタム設定から取得
        String s3BucketName = SystemConfig__c.getInstance().S3BucketName__c; // S3BucketName__cをカスタム設定から取得
        String s3RootDirectory = SystemConfig__c.getInstance().S3RootDirectory__c; // S3RootDirectory__cをカスタム設定から取得
        String buildLatitude = String.valueOf(propertyTargetRecord.Building__r.Latitude__c);// 緯度
        String buildLongitude = String.valueOf(propertyTargetRecord.Building__r.Longitude__c); // 経度
        String baseUrl = CommonConst.ICON_URL;

        List<String> urlElements = new String[]{s3BucketName, s3RootDirectory};
        String iconUrl = String.format(baseUrl, urlElements);

        // 各アイコン画像URL
        String schoolIcon = iconUrl + 'School_icon.png';
        String convenienceStoreIcon = iconUrl + 'ConvenienceStore_icon.png';
        String supermarketIcon = iconUrl + 'ShoppingMall_icon.png';
        String generalHospital = iconUrl + 'Hospital_icon.png';
        String placeholder = 'https://maps.googleapis.com/maps/api/staticmap?' +
                                'center={0},{1}&zoom=14&size=640x640&scale=2&language=ja&markers={0},{1}';

        List<String> fillers = new String[]{buildLatitude, buildLongitude};
        // 小学校
        if(propertyTargetRecord.Building__r.PrimarySchool1__r.Latitude__c != null &&
            propertyTargetRecord.Building__r.PrimarySchool1__r.Longitude__c != null) {
            
            placeholder += '&markers=icon:' + schoolIcon + '|' + propertyTargetRecord.Building__r.PrimarySchool1__r.Latitude__c + ','
                            + propertyTargetRecord.Building__r.PrimarySchool1__r.Longitude__c;
        }

        // 中学校
        if(propertyTargetRecord.Building__r.JuniorHighSchool1__r.Latitude__c != null &&
            propertyTargetRecord.Building__r.JuniorHighSchool1__r.Longitude__c != null) {
            
            placeholder += '&markers=icon:' + schoolIcon + '|' + propertyTargetRecord.Building__r.JuniorHighSchool1__r.Latitude__c + ','
                            + propertyTargetRecord.Building__r.JuniorHighSchool1__r.Longitude__c;
        }

        // 高校
        if(propertyTargetRecord.Building__r.HighSchool__r.Latitude__c != null &&
            propertyTargetRecord.Building__r.HighSchool__r.Longitude__c != null) {
            
            placeholder += '&markers=icon:' + schoolIcon + '|' + propertyTargetRecord.Building__r.HighSchool__r.Latitude__c + ','
                            + propertyTargetRecord.Building__r.HighSchool__r.Longitude__c;
        }

        // 大学
        if(propertyTargetRecord.Building__r.University__r.Latitude__c != null &&
            propertyTargetRecord.Building__r.University__r.Longitude__c != null) {
            
            placeholder += '&markers=icon:' + schoolIcon + '|' + propertyTargetRecord.Building__r.University__r.Latitude__c + ','
                            + propertyTargetRecord.Building__r.University__r.Longitude__c;
        }

        // コンビニ
        if(propertyTargetRecord.Building__r.ConvenienceStore__r.Latitude__c != null &&
            propertyTargetRecord.Building__r.ConvenienceStore__r.Longitude__c != null) {
            
            placeholder += '&markers=icon:' + convenienceStoreIcon + '|' + propertyTargetRecord.Building__r.ConvenienceStore__r.Latitude__c + ','
                            + propertyTargetRecord.Building__r.ConvenienceStore__r.Longitude__c;
        }

        // スーパーマーケット
        if(propertyTargetRecord.Building__r.Supermarket__r.Latitude__c != null &&
            propertyTargetRecord.Building__r.Supermarket__r.Longitude__c != null) {
            
            placeholder += '&markers=icon:' + supermarketIcon + '|' + propertyTargetRecord.Building__r.Supermarket__r.Latitude__c + ','
                            + propertyTargetRecord.Building__r.Supermarket__r.Longitude__c;
        }

        // 総合病院
        if(propertyTargetRecord.Building__r.GeneralHospital__r.Latitude__c != null &&
            propertyTargetRecord.Building__r.GeneralHospital__r.Longitude__c != null) {
            
            placeholder += '&markers=icon:' + generalHospital + '|' + propertyTargetRecord.Building__r.GeneralHospital__r.Latitude__c + ','
                            + propertyTargetRecord.Building__r.GeneralHospital__r.Longitude__c;
        }

        String key = '&key=' + googleMapKey;
        String result = String.format(placeholder, fillers);
        result += key;
        return result;
    }

    /**
     * 施設名と距離の文字列を作成する
     * @param Integer 改行する文字数
     */
    private void createNameAndDistanceStrAndCalcMargin(Integer retLength, Building__c build) {
        primarySchoolNameAndDistanceNl = autoKaigyoAdjustDistance(build.PrimarySchool1__r.NAME + 'まで'
                                                                , build.PrimarySchoolDistance1__c + 'm', retLength);             // 小学校（帳票用）
        juniorHighSchoolNameAndDistanceNl = autoKaigyoAdjustDistance(build.JuniorHighSchool1__r.NAME+ 'まで'
                                                                    , build.JuniorHighSchoolDistance1__c + 'm', retLength);     // 中学校（帳票用）
        highSchoolNameAndDistanceNl = autoKaigyoAdjustDistance(build.HighSchool__r.NAME + 'まで'
                                                                , build.HighSchoolDistance__c + 'm', retLength);                        // 高校（帳票用）
        universityNameAndDistanceNl = autoKaigyoAdjustDistance(build.University__r.NAME + 'まで'
                                                                , build.UniversityDistance__c + 'm', retLength);                        // 大学（帳票用）
        convenienceStoreNameAndDistanceNl = autoKaigyoAdjustDistance(build.ConvenienceStore__r.NAME + 'まで'
                                                                    , build.ConvenienceStoreDistance__c + 'm', retLength);      // コンビニ（帳票用）
        supermarketNameAndDistanceNl = autoKaigyoAdjustDistance(build.Supermarket__r.NAME + 'まで'
                                                                , build.SupermarketDistance__c + 'm', retLength);                     // スーパー（帳票用）
        generalHospitalNameAndDistanceNl = autoKaigyoAdjustDistance(build.GeneralHospital__r.NAME + 'まで'
                                                                    , build.GeneralHospitalDistance__c + 'm', retLength);         // 病院（帳票用）

        // 各周辺施設の文字列を中央に配置するためにmarginの値を計算
        primarySchoolMargin = calcMargin(primarySchoolNameAndDistanceNl);
        juniorHighSchoolMargin = calcMargin(juniorHighSchoolNameAndDistanceNl);
        highSchoolMargin = calcMargin(highSchoolNameAndDistanceNl);
        universityMargin = calcMargin(universityNameAndDistanceNl);
        convenienceStoreMargin = calcMargin(convenienceStoreNameAndDistanceNl);
        supermarketMargin = calcMargin(supermarketNameAndDistanceNl);
        generalHospitalMargin = calcMargin(generalHospitalNameAndDistanceNl);
    }

    /**
     * 各周辺施設の文字列を中央に配置するためにmarginの値を計算
     * @param String 対象文字列
     * @return margin値
     */
    @testVisible private Integer calcMargin(String st) {

        // nullであった場合は空文字に変換
        st = st == null ? '' : st;

        Integer calcResult = 0;
        // 改行コードの数をカウント
        Integer lineBreakCount = st.countMatches('<wbr/>');
        // 1行目と徒歩の行の合計2を加算し、行の高さをかける
        Integer fontSizeCount = LINE_HEIGHT*(lineBreakCount + 2);
        // divの高さから計算結果を引き、margin-topを求めるため2で割る
        calcResult = (DIV_HEIGHT - fontSizeCount)/2;
        return calcResult;
    }
    //▲ 2021.09.08 No.556 対応
    
    // ********************************************************************** 内部クラス *********************************************************************

    // 写真情報内部クラス
    private class PhotoData {
        public String Tag        { get; set; }   // タグ
        public String FileName   { get; set; }   // ファイル名
        public String FilePath   { get; set; }   // ファイルパス
        public String AspectType { get; set; }   // 縦横比（W,T）
    }

    // 写真情報処理用内部クラス
    public class ScreenAnyPhotoData {
        public Integer photoCount               { get; set; }   // 写真登録数
        public List<PhotoData> photoDataList    { get; set; }   // 写真情報
        public List<PhotoData> sortPhotoDataList    { get; set; }   // 写真情報
        public PhotoData livingFile    { get; set; }      // 写真情報（画面表示用）
        public String roomLayoutFilePath        { get; set; }   // 間取図
        public ScreenAnyPhotoData() {
            
            // 初期化
            this.photoDataList  = new List<PhotoData>();
        }
        public ScreenAnyPhotoData(PropertyPhoto__c propertyPhoto, String patList) {
            
            // 初期化
            this.photoDataList  = new List<PhotoData>();
            this.sortPhotoDataList  = new List<PhotoData>();
            this.livingFile = new PhotoData();
            List<String> photoSortList = new List<String>();
            this.roomLayoutFilePath = '';
            String tagName = '';
            
            // データセット
            this.photoCount = 0;
            PhotoData data;

            // 物件写真
            for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PROPERTY; i++) {
                data = new photoData();
                tagName = (String)propertyPhoto.get('PropertyPhotoTag' + i + '__c');
                
                data.FileName   = (String)propertyPhoto.get('PropertyPhotoFileName' + i + '__c');
                data.FilePath   = (String)propertyPhoto.get('PropertyPhotoFilePath' + i + '__c');
                
                // ファイル名が空のデータは対象外とする
                if (String.isEmpty(data.FileName)) {
                    continue;
                }

                // タグを文字から並び順（リスト表示順）に置換
                if (tagName == CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_LIVING) {
                    data.Tag = 'a';   // 居室・リビング
                } else if (tagName == CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_OTHERROOM) {
                    data.Tag = 'b';   // その他部屋・スペース
                } else if (tagName == CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_KITCHEN) {
                    data.Tag = 'c';   // キッチン
                } else if (tagName == CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_BATH) {
                    data.Tag = 'd';   // バス・シャワールーム
                } else if (tagName == CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_TOILET) {
                    data.Tag = 'e';   // トイレ
                } else if (tagName == CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_WASHROOM) {
                    data.Tag = 'f';   // 洗面設備
                } else if (tagName == CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_STORAGE) {
                    data.Tag = 'g';   // 収納
                } else if (tagName == CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_BALCONY) {
                    data.Tag = 'h';   // バルコニー
                } else if (tagName == CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_GARDEN) {
                    data.Tag = 'i';   // 庭
                } else if (tagName == CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_ENTRANCE) {
                    data.Tag = 'j';   // 玄関
                } else if (tagName == CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_SECURITY) {
                    data.Tag = 'k';   // セキュリティ
                } else if (tagName == CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_OTHERFACILITY) {
                    data.Tag = 'l';   // その他設備 
                } else if (tagName == CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_VIEW) {
                    data.Tag = 'm';   // 眺望
                } else if (tagName == CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_OTHER) {
                    data.Tag = 'n';   // その他
                } else {
                    data.Tag = 'z';   // 空値（設定なし）
                }
                
                if (!String.isEmpty(data.FileName)) {
                    this.photoDataList.add(data);
                    photoSortList.add(data.Tag + '_' + data.FileName);
                    photoCount += 1;
                }
            }

            photoSortList.sort();
            String key = '';

            // タグ順（タグが同一であればファイル名順）で並び替えて再格納
            for (Integer i = 1; i <= photoDataList.size(); i++) {
                for (PhotoData sortPhoto : photoDataList) {
                    key = sortPhoto.Tag + '_' + sortPhoto.FileName;

                    // 画面表示用に、最初にヒットした「居住・リビング」画像情報を格納
                    if (sortPhoto.Tag == 'a' && String.isEmpty(livingFile.FilePath)) {
                        livingFile = sortPhoto;
                    }

                    if (key == photoSortList[i-1]) {
                        sortPhotoDataList.add(sortPhoto);
                        continue;
                    } 
                }
            }

            for (Integer i = 0; i < this.sortPhotoDataList.size(); i++) {
                if (this.sortPhotoDataList[i].FilePath == livingFile.FilePath) {
                    this.sortPhotoDataList.remove(i);
                    this.photoCount -= 1;
                    break;
                }
            }

            // 間取図の設定
            if (propertyPhoto.get('RoomLayoutFileName__c') <> '') {
                //▼問合せNo0487で変更
                roomLayoutFilePath = CommonUtil.getCacheAvoidancePath((String)propertyPhoto.get('RoomLayoutFilePath__c'));
                //▲問合せNo0487で変更
            }
            
            // 公開写真の縦横比設定
            if (String.isNotEmpty(patList)) {
                for (Integer i=0; i< this.sortPhotoDataList.size(); i++) {
                    this.sortPhotoDataList[i].AspectType = patList.subString(i, i + 1);
                }
            }
            
        }
    }
    
}