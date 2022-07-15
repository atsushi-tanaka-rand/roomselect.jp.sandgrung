/**
* 小中学校登録のクラス
*/
public inherited sharing class GF501002Controller {

    //Public変数
    
    //データ
    public displaySchool displayTargetRecord { get; set; }    //画面表示用の内部クラスレコード
    public School__c targetSchool { get; set; } // 学校レコード
    public String targetJuniorHighSchool { get; set; } // 中学校区
    public List<SchoolArea__c> targetSchoolAddressList { get; set; } // 通学住所一覧
    public List<Advancement__c> targetPrimarySchoolList { get; set; } // 進学元小学校一覧
    public GA102006ParameterClass GA102006Parameter{get; set;} // 郵便番号検索・住所検索のパラメータ

    //選択リスト
    public List<SelectOption> stateOption { get; set; }//都道府県リスト

    //表示用メッセージ
    public String MSG_COM_V_SAVE                            {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_SAVE);}                            private set;}    //js用保存確認メッセージ
    public String MSG_COM_I_SAVE                            {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);}                            private set;}    //js用保存完了メッセージ
    public String MSG_COM_V_DELETE                          {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_DELETE);}                          private set;}    //js用削除確認メッセージ
    public String MSG_COM_I_DELETE                          {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_DELETE);}                          private set;}    //js用削除完了メッセージ
    public String MSG_COM_W_SELECTION_IMAGE_FILETYPE        {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SELECTION_IMAGE_FILETYPE);}        private set;}    //js用ファイルが画像ではない場合エラーメッセージ

    //写真処理関連
    public ScreenSchoolPhotoData schoolPhotoData            { get; set; }   // 写真情報
    public List<SelectOption> photoMosaicSelectOption { get; set; }
    public String selectIsMosaic { get; set; }

    //フラグ
    public Boolean isOpenError { get; set; } // エラーフラグ
    public Boolean hasErrorMessage { get; set; } //エラーメッセージ保有フラグ
    public Boolean isPrimarySchool { get; set; } // 小学校用項目表示フラグ

    //ID
    public String targetId; //対象の学校ID

//＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
//publicメソッド
//＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊

    public GF501002Controller() {
        try{
            
            //初期化
            init();
            
            //パラメータ取得
            targetId  = ApexPages.currentPage().getParameters().get('Id');//パラメータの学校IDを取得
            
            //データ取得
            getSchool();//学校を取得

            if(targetSchool.Type__c == CommonConst.SCHOOL_TYPE_JUNIORHIGHSCHOOL) {
                //種別:小学校
                getPrimarySchool();//進学元小学校を取得
                isPrimarySchool = false;
            } else if(targetSchool.Type__c == CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL) {
                //種別:中学校
                getJuniorHighSchool();//中学校区を取得
                getSchoolAddressList();//通学住所を取得
                isPrimarySchool = true;
            }   

            getPhotoData();//写真情報を取得

        }catch(Exception e){
            isOpenError = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
            
        }
    }

    //保存ボタン押下処理
    public void saveSchool(){
        Savepoint sp = Database.setSavepoint();//セーブポイント作成
        try{
            //変数初期化
            hasErrorMessage = false;//エラーを初期化
            BusinessLogicException ex = new BusinessLogicException();//ビジネスロジックException準備
            
            //必須入力チェック
            List<String> requiredItem = new List<String>();//入力チェックリストを初期化

            if (String.isBlank(displayTargetRecord.schoolName)){
                requiredItem.add('学校');
            }
            if (displayTargetRecord.latitude == 0){
                requiredItem.add('緯度');
            }
            if (displayTargetRecord.longitude == 0){
                requiredItem.add('経度');
            }

            if (!requiredItem.isEmpty()){//入力チェック用リストが空ではない場合、エラー追加                
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ',')));
            }
            
            //エラーをまとめて投げる
            if (ex.hasMessage()){ 
                throw ex;
            }

            //楽観ロックチェック
            List<School__c> checkOptimisticLockExceptionRecord = new List<School__c>();
            checkOptimisticLockExceptionRecord = [SELECT id
                                                  FROM School__c
                                                  WHERE id = :this.displayTargetRecord.schoolId
                                                  AND SystemModStamp = :this.displayTargetRecord.systemModStamp ];

            //データ取得できない場合、楽観ロックチェックExceptionを発行
            if (checkOptimisticLockExceptionRecord.isEmpty()){
                OptimisticLockException OptimisticLockex = new OptimisticLockException();
                throw OptimisticLockex;
            }

            //保存処理実行
            School__c upSertSchool = new School__c();//保存する学校を作成

            //画面入力内容を保存する学校に設定
            upSertSchool.ID                       = this.displayTargetRecord.schoolId;// 学校Id
            upSertSchool.Name                     = this.displayTargetRecord.schoolName;// 学校名
            upSertSchool.SchoolNameKana__c        = this.displayTargetRecord.schoolNameKana;// 建物名（カナ）
            upSertSchool.ShoolAbbreviationName__c = this.displayTargetRecord.schoolAbbreviationName;// 学校略称
            upSertSchool.PostalCode__c            = this.displayTargetRecord.postalCode;// 郵便番号
            upSertSchool.State__c                 = this.displayTargetRecord.state;// 都道府県
            upSertSchool.City__c                  = this.displayTargetRecord.city;// 住所１（市区町村）
            upSertSchool.Street__c                = this.displayTargetRecord.street;// 住所２（番地）
            upSertSchool.Phone__c                 = this.displayTargetRecord.phone;// 電話
            upSertSchool.Longitude__c             = this.displayTargetRecord.longitude;// 経度
            upSertSchool.Latitude__c              = this.displayTargetRecord.latitude;// 緯度
             
            SecureDML.secureUpsert(upSertSchool);// 学校を保存
 
        }catch(Exception e){
            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
            
        }
    }

    //郵便番号検索・住所検索 モーダル表示
    public void GA102006FormOpen() {
        GA102006Parameter.isDrawing = true;
        GA102006Parameter.noFirst = true;
        
        GA102006Parameter.isAddressMoster = TRUE;  //住所マスタフラグ
        GA102006Parameter.postalCode = this.displayTargetRecord.postalCode;  //郵便番号
        GA102006Parameter.state = this.displayTargetRecord.state;    //都道府県   
        GA102006Parameter.city = this.displayTargetRecord.city;    //市区町村
        GA102006Parameter.street = null;    //町域 
        
    }
    
    //郵便番号検索・住所検索 モーダル閉じる
    public void GA102006FormClose() {
        this.displayTargetRecord.postalCode = GA102006Parameter.postalCode;  // 郵便番号
        this.displayTargetRecord.state = GA102006Parameter.state;    //都道府県 
        this.displayTargetRecord.city = GA102006Parameter.city + GA102006Parameter.street + GA102006Parameter.aza ;    //市区町村   
        this.displayTargetRecord.street = null;    //町域 
    }

    // 写真情報アップロード後処理
    public void updateSchoolPhoto() {
        try {
            // エラーフラグ初期化
            this.hasErrorMessage = false;

            // SystemModStampの変更有無を取得する
            Boolean isNotOptimisticLockError = this.checkSystemModStamp(this.targetId);

            // 写真を更新する
            AmazonS3Util.savePhoto(this.schoolPhotoData.GD901001Parameter);
            // 写真情報の再読み込み
            this.getPhotoData();   

            // 写真更新前時点でSystemModStampに変更が無かった場合、SystemModStampを再取得する
            if (isNotOptimisticLockError) {
                this.displayTargetRecord.systemModStamp = this.getSystemModStamp(this.targetId);
            }
        } catch(Exception e) {
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // 写真情報削除処理
    public void deleteSchoolPhoto(){
        try {
            // エラーフラグ初期化
            this.hasErrorMessage = false;

            // SystemModStampの変更有無を取得する
            Boolean isNotOptimisticLockError = this.checkSystemModStamp(this.targetId);

            // 画像削除
            AmazonS3Util.callPhotoDelete(this.targetId, AmazonS3Util.PhotoType.SCHOOL);
            // 写真再読み込み
            this.getPhotoData();

            // 写真更新前時点でSystemModStampに変更が無かった場合、SystemModStampを再取得する
            if (isNotOptimisticLockError) {
                this.displayTargetRecord.systemModStamp = this.getSystemModStamp(this.targetId);
            }
        } catch(Exception e) {
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // モザイク処理要否の変更処理
    public void changeIsMoosaic() {
        this.schoolPhotoData.GD901001Parameter.isMosaic = this.selectIsMosaic == 'true' ? true : false;
    }

//＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
//privateメソッド
//＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
    
    //初期設定
    private void init(){
        //店舗異動が取得できなければエラー
        CommonUtil.getStaffCurrentShop();

        // 選択リストを取得
        stateOption = CommonUtil.getSelectOptionFromObject('School__c', 'State__c');

        // モーダルに渡すパラメータを初期化
        this.GA102006Parameter = new GA102006ParameterClass();

        // モザイク要否ラジオボタン設定（初期選択：モザイク無）
        this.photoMosaicSelectOption = new List<SelectOption>();
        this.photoMosaicSelectOption.add(new SelectOption('true', 'モザイク有'));
        this.photoMosaicSelectOption.add(new SelectOption('false', 'モザイクなし'));
        this.selectIsMosaic = 'false';
    }

    // 学校の取得
    private void getSchool(){
        //パラメータの学校IDを使用して学校を取得
        list<School__c> mySchool = [SELECT Id
                                    ,Name// 学校名
                                    ,SchoolNameKana__c// 学校名カナ
                                    ,ShoolAbbreviationName__c// 学校略称
                                    ,Type__c// 種別
                                    ,PostalCode__c// 郵便番号
                                    ,State__c// 都道府県
                                    ,City__c// 住所１（市区町村）
                                    ,Street__c// 住所2（町名・番地）
                                    ,Phone__c// 電話番号
                                    ,Latitude__c// 緯度
                                    ,Longitude__c// 経度
                                    ,SystemModStamp
                                    FROM School__c WHERE ID = :targetId];
        
        if(mySchool.size() > 0){//学校が取得できれば表示用内部クラスに建物を設定
            targetSchool = mySchool[0];
            displayTargetRecord = new displaySchool(mySchool[0]);
        }else{//学校が取得できなければエラー
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
            throw ex;
        }
    }

    // 中学校区の取得
    private void getJuniorHighSchool(){
        //パラメータの学校IDを使用して中学校区を取得
        List<Advancement__c> myJuniorHighSchool = [SELECT ID
                                                   ,JuniorHighSchool__r.Name// 中学校.学校名
                                                   FROM Advancement__c WHERE PrimarySchool__c = :targetId];

        List<String> juniorHighSchoolNames = new List<String>();
        for (Integer i = 0; i < myJuniorHighSchool.size(); i++) {
            juniorHighSchoolNames.add(myJuniorHighSchool[i].JuniorHighSchool__r.Name);
        }
        targetJuniorHighSchool = String.join(juniorHighSchoolNames, ';');
    }

    // 通学住所一覧の取得
    private void getSchoolAddressList(){
        targetSchoolAddressList = new List<SchoolArea__c>();// 通学住所一覧を初期化

        //パラメータの学校IDを使用して通学住所を取得
        targetSchoolAddressList = [SELECT ID
                                   ,Address__c// 住所
                                   FROM SchoolArea__c WHERE School__c = :targetId];
    }

    // 進学元小学校一覧の取得
    private void getPrimarySchool(){
        targetPrimarySchoolList = new List<Advancement__c>();// 進学元小学校一覧を初期化

        //パラメータの学校IDを使用して進学元小学校を取得
        targetPrimarySchoolList = [SELECT ID
                                   ,PrimarySchool__r.Name// 小学校.学校名
                                   FROM Advancement__c WHERE JuniorHighSchool__c = :targetId];
    }

    // 写真関連情報の取得・設定
    private void getPhotoData(){
        //パラメータの学校IDを使用して写真を取得
        list<School__c> myPhoto = [SELECT Id
                                   ,PhotoFilePath__c// 写真ファイルパス
                                   ,PhotoFileName__c// 写真名
                                   ,ForeignID__c// 外部ID
                                   FROM School__c WHERE ID = :targetId];
        
        if(myPhoto.size() > 0){
            this.schoolPhotoData = new ScreenSchoolPhotoData(myPhoto[0], Boolean.valueOf(this.selectIsMosaic));
        }
    }

    // SystemModStampのチェック
    private Boolean checkSystemModStamp(Id schoolId) {
        Datetime nowDatetime = this.getSystemModStamp(schoolId);
        if (nowDatetime != this.displayTargetRecord.systemModstamp) {
            return false;
        }
        return true;
    }
    // SystemModStampの取得
    private Datetime getSystemModStamp(Id schoolId) {
        List<School__c> school = [
            SELECT
                SystemModStamp
            FROM
                School__c
            WHERE
                Id = :schoolId
        ];
        if (school.size() == 0) {
            return null;
        }
        return school[0].SystemModStamp;
    }

//＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
//内部クラス
//＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
    
    //画面表示用の学校の内部クラス
    public class displaySchool {
        public School__c targetSchoolRecord { get; set; } //レコード本体
        
        //以下、画面用の項目
        public Id schoolId { get; set; } //  学校Id
        public String schoolName { get; set;} // 学校名
        public String schoolNameKana { get; set;} // 学校名カナ
        public String schoolAbbreviationName { get; set;} // 学校略称
        public String type { get; set;} // 種別
        public String postalCode { get; set;} // 郵便番号
        public String state { get; set;} // 都道府県
        public String city { get; set;} // 住所１（市区町村）
        public String street { get; set;} // 住所2（町名・番地）
        public String phone { get; set;} // 電話番号
        public Decimal latitude { get; set;} // 緯度
        public Decimal longitude { get; set;} // 経度
        public DateTime systemModstamp { get; set; } //  SystemModstamp
        
        //コンストラクタ
        public displaySchool(School__c targetSchoolRecord){

            this.targetSchoolRecord = targetSchoolRecord;  //レコード本体(学校)

            this.schoolId = targetSchoolRecord.Id; //  学校Id
            this.schoolName = targetSchoolRecord.Name; // 学校名
            this.schoolNameKana = targetSchoolRecord.SchoolNameKana__c; // 学校名カナ
            this.schoolAbbreviationName = targetSchoolRecord.ShoolAbbreviationName__c; // 学校略称
            this.type = targetSchoolRecord.Type__c; // 種別
            this.postalCode = targetSchoolRecord.PostalCode__c; // 郵便番号
            this.state = targetSchoolRecord.State__c; // 都道府県
            this.city = targetSchoolRecord.City__c; // 住所１（市区町村）
            this.street = targetSchoolRecord.Street__c;  // 住所2（町名・番地）
            this.phone = targetSchoolRecord.Phone__c;  // 電話番号
            this.latitude = targetSchoolRecord.Latitude__c; // 緯度
            this.longitude = targetSchoolRecord.Longitude__c; // 経度

            this.systemModstamp = targetSchoolRecord.SystemModstamp;//  SystemModstamp
            
        }
    }

    // 写真情報内部クラス
    private class PhotoData {
        public String fileName  { get; set; }   // ファイル名
        public String filePath  { get; set; }   // ファイルパス
    }
    // 写真情報処理用内部クラス
    public class ScreenSchoolPhotoData {
        public GD901001ParameterClass GD901001Parameter { get; set; }
        public AmazonS3Util.PhotoType photoType { get; set; }   // 写真種別
        public PhotoData photoData              { get; set; }   // 写真情報
        public Boolean isNone                   { get; set; }   // 登録なしフラグ
        public ScreenSchoolPhotoData() {
            // 初期化
            this.photoData = new PhotoData();
            this.GD901001Parameter = new GD901001ParameterClass();
        }
        public ScreenSchoolPhotoData(School__c school, Boolean isMosaic) {
            // 初期化
            this.photoData = new PhotoData();
            this.GD901001Parameter = new GD901001ParameterClass();
            this.isNone = true;
            // パラメータ設定
            this.GD901001Parameter.photoType    = CommonConst.S3_PHOTOTYPE_SCHOOL;
            this.GD901001Parameter.isArea       = true;
            this.GD901001Parameter.isMosaic     = isMosaic;
            this.GD901001Parameter.foreignId    = school.ForeignID__c; // 学校の外部ID
            this.photoType = photoType;

            // データセット
            PhotoData data = new PhotoData();
            data.fileName = school.PhotoFileName__c;
            data.filePath = school.PhotoFilePath__c;
            this.photoData = data;

            if (!String.isEmpty(data.fileName)) {
                this.GD901001Parameter.fileName = data.fileName;
                this.GD901001Parameter.filePath = data.filePath;
                this.isNone = false;
            }
        }
    }
}