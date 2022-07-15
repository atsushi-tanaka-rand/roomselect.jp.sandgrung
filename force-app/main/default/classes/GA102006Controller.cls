/**
 * 郵便番号検索・住所検索モーダル画面コントローラ
 */
public inherited sharing class GA102006Controller {

    //Public変数
    public GA102006ParameterClass Parameter { get; set; }   //パラメータクラス
    public Boolean isOpenError { get; set; }                //画面起動時のエラーフラグ
    public Boolean hasErrorMessage { get; set; }            //エラーメッセージ保有フラグ 
    public String screenText{ get; set;}                    //検索テキスト
    public List<DisplayAddress> targetList { get; set; }    //明細部のリスト
    public Integer index{ get; set;}                        //明細行のIndex  

    //private変数
    Integer searchLimit;//検索上限
    
    // ページの初期表示時の処理
    public Boolean init{
        get{
            if (Parameter.isDrawing) {
                initAction();
                Parameter.isDrawing = false;
                return false;
            }
            return true;
        }
    }
    
    // ページの初期表示時の、具体的処理
    public void initAction() {
        try{
            this.screenText = '';     //画面のテキストを空白に
            this.targetList = new List<DisplayAddress>();//明細部のリストをnullに
            this.isOpenError = null;     //isOpenErrorをfalseに
            this.hasErrorMessage = null; //isErrorMessageをfalseに
            
            //カスタム設定の郵便番号・住所検索検索上限を取得
            this.searchLimit = Integer.valueOf(SystemConfig__c.getInstance().PostalCodeAddressSearchMaxCount__c);//検索上限をカスタム設定から取得

            //郵便番号が空白でないとき
            if (!String.isBlank(Parameter.postalCode)){
                //parameterの郵便番号を格納
                this.screenText = Parameter.postalCode;
            }else{
                ///郵便番号が空白の場合、都道府県+市区町村+町域/大字を格納
                if (!String.isBlank(Parameter.state)){
                    this.screenText  =Parameter.state;    
                }
                if (!String.isBlank(Parameter.city)){
                    this.screenText  +=Parameter.city;    
                }            
                if (!String.isBlank(Parameter.street)){
                    this.screenText  +=Parameter.street;    
                }                                                     
            }
            //住所マスタフラグがnullのときエラー
            if (Parameter.isAddressMoster == null){
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
                throw ex;
            }

        }catch(Exception e){
            //エラーを設定
            isOpenError = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    //検索ボタン
    public void searchAddress(){
        try {
            hasErrorMessage = false;
            BusinessLogicException ex = new BusinessLogicException();
            String searchText = this.screenText.replace('-', '');//ハイフンを抜いた検索用文字列
            
            //3字以下の場合、ビジネスロジックException発行
            if (searchText.length() < 4){
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_INPUT_LENGTH_OR_MORE,'検索条件','4' ));
                throw ex;
            }
            //WHERE句用変数
            String searchPostalCord =      CommonUtil.convertDisableWildcard(searchText) + '%';//郵便番号WHERE用 
            String searchAddress    = '%'+ CommonUtil.convertDisableWildcard(searchText) + '%';//住所WHERE用

            //SOQLのLIMIT設定
            Integer sqlSearchLimit = searchLimit + 1;

            if (Parameter.isAddressMoster){
                //住所マスタから設定（住所マスタフラグがTrueの場合）
                List<Address__c> AddressList = [SELECT id,
                                                      PostalCodeFormat__c,            
                                                      Address__c,
                                                      State__c,
                                                      City__c,
                                                      Street__c
                                                FROM  Address__c 
                                                WHERE PostalCode__c LIKE :searchPostalCord 
                                                OR   Address__c LIKE :searchAddress
                                                ORDER BY PostalCode__c
                                                LIMIT :sqlSearchLimit];

                //件数超過エラー
                if(AddressList.size() > searchLimit){
                    ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_NOTICE_MAX_COUNT_OVER ));
                    throw ex;
                }

                //0件エラー
                if (AddressList.isEmpty()){
                    //レコード情報が取得できなければビジネスロジックException発行
                    ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_NO_DATA));
                    throw ex;
                }
                targetList = new List<DisplayAddress>();

                for(Address__c a :AddressList) {
                    targetList.add(new DisplayAddress(a));
                }

            }else{
                //国土地理協会住所マスタから設定（住所マスタフラグがFalseの場合）
                List<JapanGeographicDataCenterAddress__c> JapanGeographicDataCenterAddressList = [SELECT id,
                                                        PostalCodeFormat__c,            
                                                        PlaceName__c,
                                                        State__c,
                                                        City__c,  
                                                        OazaAlias__c, 
                                                        AzaName__c,
                                                        ChoazaCodeNew__c,
                                                        ObsoleteYM__c
                                                FROM JapanGeographicDataCenterAddress__c 
                                                WHERE (PostalCode__c LIKE :searchPostalCord
                                                OR   PlaceName__c LIKE :searchAddress)
                                                AND  ObsoleteYM__c = '000000' 
                                                ORDER BY PostalCode__c];
                //件数超過エラー
                if(JapanGeographicDataCenterAddressList.size() > searchLimit){
                    ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_NOTICE_MAX_COUNT_OVER ));
                    throw ex;
                }
                //0件エラー
                if (JapanGeographicDataCenterAddressList.isEmpty()){
                    //レコード情報が取得できなければビジネスロジックException発行
                    ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_NO_DATA));
                    throw ex;
                } 

                targetList = new List<DisplayAddress>();           
                
                for(JapanGeographicDataCenterAddress__c b :JapanGeographicDataCenterAddressList) {
                    targetList.add(new DisplayAddress(b));
                }
            }
        }catch (Exception e) {
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }

    //選択ボタン押下時、パラメータ送信
    public void clickSelect(){
        try{
            hasErrorMessage = false;            
            Parameter.postalCode    = String.isNotBlank(targetList[index].postalCode   ) ? targetList[index].postalCode    : '';
            Parameter.state         = String.isNotBlank(targetList[index].state        ) ? targetList[index].state         : '';
            Parameter.city          = String.isNotBlank(targetList[index].city         ) ? targetList[index].city          : '';   
            Parameter.street        = String.isNotBlank(targetList[index].street       ) ? targetList[index].street        : '';            
            Parameter.aza           = String.isNotBlank(targetList[index].aza          ) ? targetList[index].aza           : ''; 
            Parameter.choazaCodeNew = String.isNotBlank(targetList[index].choazaCodeNew) ? targetList[index].choazaCodeNew : '';    
            Parameter.obsoleteYM    = String.isNotBlank(targetList[index].obsoleteYM   ) ? targetList[index].obsoleteYM    : '';   
        }catch (Exception e) {
            hasErrorMessage = true;//エラーを設定  
        }

    } 


    // 内部クラス
    public class DisplayAddress {
        public string postalCode{ get; set; }   // 郵便番号
        public string address{ get; set; }      // 住所
        private string state;                   // 都道府県 
        private string city;                    // 市区町村
        private string street;                  // 町域/大字
        private string aza;                     // 字 
        private string choazaCodeNew;           // 町字コード 
        private string obsoleteYM;              // 廃止年月

        // 住所用コンストラクタ
        public DisplayAddress(Address__c targetRecord) {
            this.postalCode = targetRecord.PostalCodeFormat__c;   //郵便番号
            this.address = targetRecord.Address__c;               //住所
            this.state = targetRecord.State__c;                   //都道府県
            this.city = targetRecord.City__c;                     //市区町村名
            this.street = targetRecord.Street__c;                 //町域名
            this.aza = null;                               
            this.choazaCodeNew = null;
            this.obsoleteYM = null;   
        }
        // 国土地理院用コンストラクタ
        public DisplayAddress(JapanGeographicDataCenterAddress__c targetRecord) {
            this.postalCode = targetRecord.PostalCodeFormat__c;   //郵便番号
            this.address = targetRecord.PlaceName__c;             //地域
            this.state = targetRecord.State__c;                   //都道府県
            this.city = targetRecord.City__c;                     //市区郡町村
            this.street = targetRecord.OazaAlias__c;              //大字通称（町域/大字）
            this.aza = targetRecord.AzaName__c;                   //字名（○丁目など）
            this.choazaCodeNew = targetRecord.ChoazaCodeNew__c;   //町・字コード
            this.obsoleteYM = targetRecord.ObsoleteYM__c;         //廃止年月

        }

    }

    
}