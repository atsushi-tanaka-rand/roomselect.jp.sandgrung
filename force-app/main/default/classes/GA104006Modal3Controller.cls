//物件登録画面 の おすすめ物件モーダル
public inherited sharing class GA104006Modal3Controller {

    public GA104006Modal3ParameterClass parameter { get; set; } // パラメータ

    public Boolean isOpenError { get; set; }        // 画面遷移時のエラーフラグ
    public Boolean hasErrorMessage { get; set; }    // エラーメッセージ保有フラグ

    public ScreenRecommendProperty screenRecoPro { get; set; }    //表示用おすすめ物件
    public List<ScreenPhoto> screenPhotoList { get; set; }//表示用写真リスト
    //再販対応 追加 Start
    public Boolean isUseAuthorityPanoramaTour{ get; set; }
    //再販対応 追加 Emd

    // ページの初期表示処理実行用
    public Boolean init {
        get {
            if (this.parameter.isDrawing) {
                initAction();
                this.parameter.isDrawing = false;
                return false;
            }
            return true;
        }
    }    
    public GA104006Modal3Controller() {
    }
    // ページの初期表示の具体的な処理
    public void initAction(){
        try{
            // 初期化 //問合せNo0440で変更
            changePublicInitialize();
            //再販対応 追加 Start
            isUseAuthorityPanoramaTour = parameter.isUseAuthorityPanoramaTour;
            //再販対応 追加 End
            
            //パラメータのおすすめ物件を取得
            screenRecoPro = new ScreenRecommendProperty(parameter.recoPro);

            //表示用写真設定
            setPhotoList();

        } catch (Exception e) {
            this.isOpenError = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    //----------------------------publicメソッド------------------------------------------------------------------
    //登録ボタン押下
    public void registrationCleck(){
       Savepoint sp = Database.setSavepoint();      //セーブポイント作成
        try{
            hasErrorMessage = false;
            //画面の値を項目に入れる
            setReturnRecoPro();

            //DB更新フラグがtrueの場合、ここでDBを更新する。
            if (parameter.IsUpsertDB){
                checkOptimistic();  //楽観ロックチェック
                SecureDML.secureUpsert(parameter.recoPro);
            }
    
        }catch(Exception e){ 
            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }        

    }

    //----------------------------privateメソッド------------------------------------------------------------------
    //---------------------------表示用の写真設定系---------------------------
    //表示用写真設定
    private void setPhotoList(){
        this.screenPhotoList = new List<ScreenPhoto>();
        
        //外観写真・エントランス・ロビー取得、表示用写真リストに追加
        BuildingPhoto__c builPhoto = getBuildingPhoto();   
        if (builPhoto != null){
            //タグ設定
            if (String.isNotBlank(builPhoto.AppearanceFileName__c)){
                this.screenPhotoList.add(new ScreenPhoto(builPhoto.AppearanceFileName__c, builPhoto.AppearanceFilePath__c, '建物外観'));   
            }
            if (String.isNotBlank(builPhoto.EntranceFileName__c)){
                this.screenPhotoList.add(new ScreenPhoto(builPhoto.EntranceFileName__c, builPhoto.EntranceFilePath__c, 'エントランス'));   
            }
            if (String.isNotBlank(builPhoto.LobbyFileName__c)){
                this.screenPhotoList.add(new ScreenPhoto(builPhoto.LobbyFileName__c, builPhoto.LobbyFilePath__c, 'ロビー'));   
            }
        }

        //物件写真取得、表示用写真リストに追加
        PropertyPhoto__c proPhoto = getPropertyPhoto();    
        if (proPhoto != null){
            for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PROPERTY; i++) { 

                String PhotoFileName = (String)proPhoto.get('PropertyPhotoFileName' + i + '__c');
                String PhotoFilePath = (String)proPhoto.get('PropertyPhotoFilePath' + i + '__c');
                String PhotoTag      = (String)proPhoto.get('PropertyPhotoTag' + i + '__c');

                //物件公開写真iに値がある
                if (String.isNotEmpty(PhotoFileName)){
                    this.screenPhotoList.add(new ScreenPhoto(PhotoFileName, PhotoFilePath, PhotoTag));   
                }
            }  
        }
        
        //表示用写真のチェックボックスを設定
        for (ScreenPhoto scPhot : screenPhotoList){
            //既存の写真ファイル名
            String existPhotoFileName = parameter.recoPro.PhotoFileName__c;
            //既存の写真ファイル名がnullでない　かつ　既存の写真ファイル名が対象のファイルパス名と一致する
            if (String.isNotBlank(existPhotoFileName) && existPhotoFileName == scPhot.fileName){
                scPhot.checkBox = true;
                break;
            }
        }
    }

    //---------------------------保存時系---------------------------
    //返却の項目を設定
    private void setReturnRecoPro(){
        //画面の値を項目に入れる（写真の有無をチェックするため先行して写真ファイルのセットを行う）
        setReturnPhoto();                                                           //写真ファイル名、写真ファイルパス //問合せNo0440で変更
        //項目がnullの場合のみ格納
        if (String.isBlank(parameter.recoPro.UserId__c)){
            parameter.recoPro.UserId__c = UserInfo.getUserId();                     //登録ユーザ
        }
        if (String.isBlank(parameter.recoPro.ShopId__c)){
            parameter.recoPro.ShopId__c = CommonUtil.getStaffCurrentShop().Id;      //登録店舗
        }
        parameter.recoPro.DisplayFlag__c = true;                                    //表示フラグ
        parameter.recoPro.propertyCode__c = parameter.propertyCode;                 //物件コード
        parameter.recoPro.Comment__c = screenRecoPro.comment;                       //コメント
        //再販対応 追加 Start
        //パノラマツアー権限があれば保存
        if (isUseAuthorityPanoramaTour){
            parameter.recoPro.HomesImportkey__c = screenRecoPro.homesImportkey;     //HOME'Sインポートキー 
            parameter.recoPro.PanoramaTourUrl__c = screenRecoPro.panoramaTourUrl;   //パノラマツアーURL    
        }else{//なければ空
            parameter.recoPro.HomesImportkey__c = '';                               //HOME'Sインポートキー 
            parameter.recoPro.PanoramaTourUrl__c = '';                              //パノラマツアーURL    
        }
        //再販対応 追加 End
        parameter.recoPro.Property__c = parameter.propertyId;                       //物件Id
    }

    //チェックされている写真取得
    private void setReturnPhoto(){
        String fileName = '';   //写真ファイル名
        String filePath = '';   //写真ファイルパス

        //チェックされている写真を取得
        for (ScreenPhoto scPhoto : screenPhotoList){
            if (scPhoto.checkBox){
                fileName = scPhoto.fileName;        //写真ファイル名
                filePath = scPhoto.filePath;        //写真ファイルパス
                break;
            }
        }

        //表示写真リストが空でないのに写真が選択されていない場合、エラー
        BusinessLogicException ex = new BusinessLogicException();
        if (String.isBlank(fileName) && !screenPhotoList.isEmpty()){
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_NO_SELECTION,'写真'));
            throw ex;
        }

        //パラメータの項目に設定
        parameter.recoPro.PhotoFileName__c = fileName;
        parameter.recoPro.PhotoFilePath__c = filePath;  
    }

    //楽観ロックチェック
    private void checkOptimistic(){
        //パラメータのお気に入り物件にIdがある場合、楽観ロックチェックを行う
        if (String.isNotBlank(parameter.recoPro.Id)){
            List<RecommendProperty__c> checkRecoPro = [SELECT Id 
                                                        FROM RecommendProperty__c 
                                                        WHERE Id = :parameter.recoPro.Id
                                                        AND SystemModStamp = :parameter.recoPro.SystemModStamp];
            //SystemModStampが一致する同一Idレコードが取得できなかった場合、エラー
            if (checkRecoPro.isEmpty()){
                OptimisticLockException ex = new OptimisticLockException();
                throw ex;
            }
        }
    }

    //public変数を初期化 //問合せNo0440で変更
    private void changePublicInitialize(){
        //viewstateに残るためpublic値をnullにしておく
        screenRecoPro = null;
        this.isOpenError = false;
        this.hasErrorMessage = false;
        screenPhotoList = new List<ScreenPhoto>();
    }
    
    //---------------------------レコード取得系---------------------------
    //建物外観・エントランス・ロビー写真取得
    private BuildingPhoto__c getBuildingPhoto(){
        //建物Idが空でなかったら建物写真を取得
        if (String.isNotBlank(parameter.buildingId)){
            List<BuildingPhoto__c> builPhotoList = [SELECT id,
                                                AppearanceFilePath__c,  //外観写真ファイルパス
                                                AppearanceFileName__c,  //外観写真ファイル名
                                                EntranceFilePath__c,    //エントランスファイルパス
                                                EntranceFileName__c,    //エントランスファイル名
                                                LobbyFilePath__c,       //ロビーファイルパス
                                                LobbyFileName__c        //ロビーファイル名
                                        FROM BuildingPhoto__c
                                        WHERE Building__c = :parameter.buildingId
                                        LIMIT 1]; 
            //建物写真があれば返却
            if (! builPhotoList.isEmpty()){
                return builPhotoList[0];
            }
        }
        return null;
    }

    //物件写真取得
    private PropertyPhoto__c getPropertyPhoto(){
        Id proId = parameter.propertyId;//スコープ内に変数を宣言しないと条件に使えないため取得
        String sql = '';
        sql += 'SELECT Id ';
        for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PROPERTY; i++) { // 物件写真
        sql += '      ,PropertyPhotoFileName' + i + '__c '; //公開写真ファイル名
        sql += '      ,PropertyPhotoFilePath' + i + '__c '; //公開写真ファイルパス
        sql += '      ,PropertyPhotoTag' + i + '__c '; //公開写真ファイルパス
        }
        sql += '  FROM PropertyPhoto__c ';
        sql += ' WHERE Property__c   = :proId ';
        sql += ' LIMIT 1';

        List<PropertyPhoto__c> propertyPhotoList = Database.query(sql);
        if (! propertyPhotoList.isEmpty()){
            return propertyPhotoList[0];
        }else{
            return null;
        }
        
    }

    //----------------------------内部クラス------------------------------------------------------------------
    //おすすめ物件表示用の内部クラス
    public class ScreenRecommendProperty{
        private RecommendProperty__c targetRecord;//レコード本体
        
        //以下、画面用の項目
        public String panoramaTourUrl { get; set; } //パノラマツアーURL
        public String homesImportkey{get; set;}     //HOME'Sインポートキー
        public String comment{get; set;}            //コメント

        //コンストラクタ
        public ScreenRecommendProperty(RecommendProperty__c targetRecord){
            this.panoramaTourUrl = targetRecord.PanoramaTourUrl__c;
            this.homesImportkey  = targetRecord.HomesImportkey__c;
            this.comment         = targetRecord.Comment__c;           
        }
    }

    //写真内部クラス
    public class ScreenPhoto{
        public Boolean checkBox { get; set; }    //チェックボックス
        public String fileName { get; set; }    //ファイル名
        public String filePath { get; set; }    //ファイルパス
        public String photoTag { get; set; }    //写真タグ

        public ScreenPhoto(String paraFileName, String paraFilePath, String paraPhotoTag){
            this.checkBox = false;
            this.fileName = paraFileName;
            this.filePath = paraFilePath;
            this.photoTag = paraPhotoTag;
        }
    }

    
}