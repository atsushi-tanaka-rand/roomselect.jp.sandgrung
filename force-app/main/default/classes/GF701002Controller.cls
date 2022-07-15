/**
* 病院登録のクラス
*/
public inherited sharing class GF701002Controller {

    //Public変数
    
    //データ
    public displayHospital displayTargetRecord { get; set; } //　画面表示用の内部クラスレコード
    public Hospital__c targetHospital { get; set; } // 病院レコード
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
    public ScreenHospitalPhotoData hospitalPhotoData { get; set; }   // 写真情報
    public List<SelectOption> photoMosaicSelectOption { get; set; }
    public String selectIsMosaic { get; set; }

    //フラグ
    public Boolean isNew { get; set; } // 新規登録フラグ
    public Boolean isOpenError { get; set; } // エラーフラグ
    public Boolean hasErrorMessage { get; set; } //エラーメッセージ保有フラグ

    //ID
    public String targetId; //対象の病院ID

//＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
//publicメソッド
//＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊

    public GF701002Controller() {
        try{
            
            //初期化
            init();
            
            //パラメータ取得
            targetId  = ApexPages.currentPage().getParameters().get('Id');//パラメータの病院IDを取得
            
            //対象IDが取得できない場合は新規登録フラグにTRUEを設定する
            if(this.targetId == null){
                this.isNew = true;
                this.displayTargetRecord = new displayHospital(new Hospital__c());
            
            //対象IDが取得できた場合は新規登録フラグにFALSEを設定する
            } else {
                this.isNew = false;
                //データ取得
                getHospital(); //病院を取得
                getPhotoData(); //写真情報を取得

            }

        }catch(Exception e){
            isOpenError = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
            
        }
    }

    //保存ボタン押下処理
    public void saveHospital(){
        Savepoint sp = Database.setSavepoint();//セーブポイント作成
        try{
            //変数初期化
            hasErrorMessage = false;//エラーを初期化
            BusinessLogicException ex = new BusinessLogicException();//ビジネスロジックException準備
            
            //必須入力チェック
            List<String> requiredItem = new List<String>();//入力チェックリストを初期化

            if (String.isBlank(displayTargetRecord.hospitalName)){
                requiredItem.add('病院名');
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

            //新規でない場合、データ取得処理を実施
            if (!isNew){
                List<Hospital__c> checkOptimisticLockExceptionRecord = new List<Hospital__c>();
                checkOptimisticLockExceptionRecord = [ SELECT id
                                                         FROM Hospital__c
                                                        WHERE id = :this.displayTargetRecord.hospitalId
                                                          AND SystemModStamp = :this.displayTargetRecord.systemModstamp
                                                     ];
                
                //データ取得できない場合、楽観ロックチェックExceptionを発行
                if (checkOptimisticLockExceptionRecord.isEmpty()){
                    OptimisticLockException oex = new OptimisticLockException();
                    throw oex;
                }
            }

            //保存処理実行
            Hospital__c upSertHospital = new Hospital__c();//保存する病院を作成

            //画面入力内容を保存する病院に設定
            upSertHospital.ID                    = this.displayTargetRecord.hospitalId;// 病院Id
            upSertHospital.Name                  = this.displayTargetRecord.hospitalName;// 病院名
            upSertHospital.PostalCode__c         = this.displayTargetRecord.postalCode;// 郵便番号
            upSertHospital.State__c              = this.displayTargetRecord.state;// 都道府県
            upSertHospital.City__c               = this.displayTargetRecord.city;// 住所１（市区町村）
            upSertHospital.Street__c             = this.displayTargetRecord.street;// 住所2（町名・番地）
            upSertHospital.Phone__c              = this.displayTargetRecord.phone;// 電話番号
            upSertHospital.SickbedCount__c       = CommonUtil.stringToDecimal(this.displayTargetRecord.sickbedCount);// 病床数
            upSertHospital.Latitude__c           = this.displayTargetRecord.latitude;// 緯度
            upSertHospital.Longitude__c          = this.displayTargetRecord.longitude;// 経度
            upSertHospital.ClinicalDepartment__c = this.displayTargetRecord.clinicalDepartment;// 診療科目
            upSertHospital.Remarks__c            = this.displayTargetRecord.remarks;// 備考
  
            SecureDML.secureUpsert(upSertHospital);// 病院を保存

        }catch(Exception e){
            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
            
        }
    }

    //削除ボタン押下処理
    public void deleteHospital(){
        
        Savepoint sp = Database.setSavepoint();      //セーブポイント作成
        try{
            hasErrorMessage = false;//エラーを初期化
            
            SecureDML.secureDelete(targetHospital);//レコード削除
            
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
    public void updateHospitalPhoto() {
        try {
            // エラーフラグ初期化
            this.hasErrorMessage = false;

            // SystemModStampの変更有無を取得する
            Boolean isNotOptimisticLockError = this.checkSystemModStamp(this.targetId);

            // 写真を更新する
            AmazonS3Util.savePhoto(this.hospitalPhotoData.GD901001Parameter);
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
    public void deleteHospitalPhoto(){
        try {
            // エラーフラグ初期化
            this.hasErrorMessage = false;

            // SystemModStampの変更有無を取得する
            Boolean isNotOptimisticLockError = this.checkSystemModStamp(this.targetId);

            // 画像削除
            AmazonS3Util.callPhotoDelete(this.targetId, AmazonS3Util.PhotoType.HOSPITAL);
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
        this.hospitalPhotoData.GD901001Parameter.isMosaic = this.selectIsMosaic == 'true' ? true : false;
    }

//＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
//privateメソッド
//＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
    
    //初期設定
    private void init(){
        isNew = false;
        isOpenError = false;
        hasErrorMessage = false;
        //店舗異動が取得できなければエラー
        CommonUtil.getStaffCurrentShop();

        // 選択リストを取得
        stateOption = CommonUtil.getSelectOptionFromObject('Hospital__c', 'State__c'); //都道府県選択リスト取得

        // モーダルに渡すパラメータを初期化
        this.GA102006Parameter = new GA102006ParameterClass();

        // モザイク要否ラジオボタン設定（初期選択：モザイク無）
        this.photoMosaicSelectOption = new List<SelectOption>();
        this.photoMosaicSelectOption.add(new SelectOption('true', 'モザイク有'));
        this.photoMosaicSelectOption.add(new SelectOption('false', 'モザイクなし'));
        this.selectIsMosaic = 'false';
    }

    // 病院の取得
    private void getHospital(){
        //パラメータの病院IDを使用して病院を取得
        list<Hospital__c> myHospital = [SELECT Id
                                        ,Name// 病院名
                                        ,PostalCode__c// 郵便番号
                                        ,State__c// 都道府県
                                        ,City__c// 住所１（市区町村）
                                        ,Street__c// 住所２（町目・番地）
                                        ,Phone__c// 電話番号
                                        ,SickbedCount__c// 病床数
                                        ,Latitude__c// 緯度
                                        ,Longitude__c// 経度
                                        ,ClinicalDepartment__c// 診療科目
                                        ,Remarks__c// 備考
                                        ,SystemModStamp
                                        FROM Hospital__c WHERE ID = :targetId];
        
        if(myHospital.size() > 0){//病院が取得できれば表示用内部クラスに病院を設定
            targetHospital = myHospital[0];
            displayTargetRecord = new displayHospital(myHospital[0]);
        }else{//病院が取得できなければエラー
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
            throw ex;
        }
    }

    // 写真関連情報の取得・設定
    private void getPhotoData(){
        //パラメータの病院IDを使用して写真を取得
        list<Hospital__c> myPhoto = [SELECT Id
                                   ,PhotoFilePath__c// 写真ファイルパス
                                   ,PhotoFileName__c// 写真名
                                   ,ForeignID__c// 外部ID
                                   FROM Hospital__c WHERE ID = :targetId];
        
        if(myPhoto.size() > 0){
            this.hospitalPhotoData = new ScreenHospitalPhotoData(myPhoto[0], Boolean.valueOf(this.selectIsMosaic));
        }
    }

    // SystemModStampのチェック
    private Boolean checkSystemModStamp(Id hospitalId) {
        Datetime nowDatetime = this.getSystemModStamp(hospitalId);
        if (nowDatetime != this.displayTargetRecord.systemModstamp) {
            return false;
        }
        return true;
    }
    // SystemModStampの取得
    private Datetime getSystemModStamp(Id hospitalId) {
        List<Hospital__c> hospital = [
            SELECT
                SystemModStamp
            FROM
                Hospital__c
            WHERE
                Id = :hospitalId
        ];
        if (hospital.size() == 0) {
            return null;
        }
        return hospital[0].SystemModStamp;
    }

//＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
//内部クラス
//＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
    
    //画面表示用の病院の内部クラス
    public class displayHospital {
        public Hospital__c targetHospitalRecord { get; set; } //レコード本体
        
        //以下、画面用の項目
        public Id hospitalId { get; set; } //  病院Id
        public String hospitalName { get; set;} // 病院名
        public String postalCode { get; set;} // 郵便番号
        public String state { get; set;} // 都道府県
        public String city { get; set;} // 住所１（市区町村）
        public String street { get; set;} // 住所2（町名・番地）
        public String phone { get; set;} // 電話番号
        public String sickbedCount { get; set;} // 病床数
        public Decimal latitude { get; set;} // 緯度
        public Decimal longitude { get; set;} // 経度
        public String clinicalDepartment { get; set;} // 診療科目
        public String remarks { get; set; } // 備考
        public DateTime systemModstamp { get; set; } //  SystemModstamp
        
        //コンストラクタ
        public displayHospital(Hospital__c targetHospitalRecord){

            this.targetHospitalRecord = targetHospitalRecord;  //レコード本体(病院)

            this.hospitalId = targetHospitalRecord.Id; //  病院Id
            this.hospitalName = targetHospitalRecord.Name; // 病院名
            this.postalCode = targetHospitalRecord.PostalCode__c; // 病院
            this.state = targetHospitalRecord.State__c; // 都道府県
            this.city = targetHospitalRecord.City__c; // 住所１（市区町村）
            this.street = targetHospitalRecord.Street__c; // 住所2（町名・番地）
            this.phone = targetHospitalRecord.Phone__c; // 電話番号
            this.sickbedCount = CommonUtil.decimalToString(targetHospitalRecord.SickbedCount__c); // 病床数
            this.latitude = targetHospitalRecord.Latitude__c; // 緯度
            this.longitude = targetHospitalRecord.Longitude__c; // 経度
            this.clinicalDepartment = targetHospitalRecord.ClinicalDepartment__c; // 診療科目
            this.remarks = targetHospitalRecord.Remarks__c; // 備考

            this.systemModstamp = targetHospitalRecord.SystemModstamp;//  SystemModstamp
        }
    }

    // 写真情報内部クラス
    private class PhotoData {
        public String fileName  { get; set; }   // ファイル名
        public String filePath  { get; set; }   // ファイルパス
    }
    // 写真情報処理用内部クラス
    public class ScreenHospitalPhotoData {
        public GD901001ParameterClass GD901001Parameter { get; set; }
        public AmazonS3Util.PhotoType photoType { get; set; }   // 写真種別
        public PhotoData photoData              { get; set; }   // 写真情報
        public Boolean isNone                   { get; set; }   // 登録なしフラグ
        public ScreenHospitalPhotoData() {
            // 初期化
            this.photoData = new PhotoData();
            this.GD901001Parameter = new GD901001ParameterClass();
        }
        public ScreenHospitalPhotoData(Hospital__c hospital, Boolean isMosaic) {
            // 初期化
            this.photoData = new PhotoData();
            this.GD901001Parameter = new GD901001ParameterClass();
            this.isNone = true;
            // パラメータ設定
            this.GD901001Parameter.photoType = CommonConst.S3_PHOTOTYPE_HOSPITAL;
            this.GD901001Parameter.isArea = true;
            this.GD901001Parameter.isMosaic = isMosaic;
            this.GD901001Parameter.foreignId = hospital.ForeignID__c; // 病院の外部ID
            this.photoType = photoType;

            // データセット
            PhotoData data = new PhotoData();
            data.fileName = hospital.PhotoFileName__c;
            data.filePath = hospital.PhotoFilePath__c;
            this.photoData = data;

            if (!String.isEmpty(data.fileName)) {
                this.GD901001Parameter.fileName = data.fileName;
                this.GD901001Parameter.filePath = data.filePath;
                this.isNone = false;
            }
        }
    }
}