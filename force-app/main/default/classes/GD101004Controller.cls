/**
 * 火災保険会社選択モーダル画面コントローラ
 */
public inherited sharing class GD101004Controller {

    //Public変数
    public GD101004ParameterClass Parameter { get; set; }   //パラメータクラス
    public Boolean isOpenError { get; set; }                //画面起動時のエラーフラグ
    public Boolean hasErrorMessage { get; set; }            //エラーメッセージ保有フラグ
    
    public String accountScreenText{ get; set;}             //火災保険会社選択検索テキスト
    public String itemNameScreenText{ get; set;}            //プラン名検索テキスト
    public String fireInsuranceScreenText{ get; set;}       //保証内容検索テキスト
    
    public List<DisplayItem> targetList { get; set; }       //明細部のリスト
    public Boolean headerCheckbox{ get; set;}               //明細ヘッダチェックボックス
    
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
            //フラグ初期化
            this.isOpenError = null;     //isOpenErrorをfalseに
            this.hasErrorMessage = null; //isErrorMessageをfalseに
            
            
            //画面のテキストを空白に
            this.accountScreenText       = '';     
            this.itemNameScreenText      = '';     
            this.fireInsuranceScreenText = '';     

            this.targetList = new List<DisplayItem>();//明細部のリストを初期化
            this.headerCheckbox = false;
        }catch(Exception e){
            //エラーを設定
            isOpenError = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    //検索ボタン
    public void search(){
        try {
            hasErrorMessage = false;//エラーフラグ初期化
            BusinessLogicException ex = new BusinessLogicException();

            //クエリ用変数設定
            String recordType = CommonUtil.getRecordTypeId('Item__c', commonConst.ITEM_RECTYPE_FIRE_INSURANCE);
            String accountText       = '%'+ CommonUtil.convertDisableWildcard(accountScreenText)       +'%';
            String itemNameText      = '%'+ CommonUtil.convertDisableWildcard(itemNameScreenText)      +'%';
            String fireInsuranceText = '%'+ CommonUtil.convertDisableWildcard(fireInsuranceScreenText) +'%';
            String soql = '';
            
            //クエリ作成
            soql = 'SELECT id,';
            soql += '         Account__r.Name,';
            soql += '         ItemName__c,';
            soql += '         FireInsurance__c,';
            soql += '         Remarks__c';
            soql += ' FROM Item__c';
            soql += ' WHERE RecordTypeId = :recordType';
 
            //動的検索部分クエリ作成
            Boolean isLikeSearch = (String.isNotEmpty(accountScreenText)) || (String.isNotEmpty(itemNameScreenText)) || (String.isNotEmpty(fireInsuranceScreenText));//検索条件あり
            Boolean isAnd = false; //ANDが必要かどうか      //問合せNo0553で変更
            
            if (isLikeSearch) {
                soql += ' AND  ';

                if (!String.isEmpty(accountScreenText)){
                    soql += '     (   Account__r.Name LIKE :accountText';
                    soql += '     OR Account__r.NameKana__c LIKE :accountText';
                    soql += '     )';
                    isAnd = true;
                }
                if (!String.isEmpty(itemNameScreenText)) {
                    soql += CommonUtil.andSet(isAnd);   //問合せNo0553で変更
                    soql += '        ItemName__c LIKE :itemNameText';
                    isAnd = true;
                }
                if (!String.isEmpty(fireInsuranceScreenText)) {
                    soql += CommonUtil.andSet(isAnd);   //問合せNo0553で変更
                    soql += '        FireInsurance__c LIKE :fireInsuranceText';
                }
                
            }     
            soql += ' ORDER BY Account__r.Name,ItemName__c';
            List<Item__c> itemList = Database.query(soql);

            //取得時エラー
            if (itemList.isEmpty()){
                //レコード情報が取得できなければビジネスロジックException発行
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_NO_DATA));
                throw ex;
            }
            
            //明細作成
            this.targetList = new List<DisplayItem>();
            for (Item__c item: itemList) {
                targetList.add(new DisplayItem(item));
            }


        }catch (Exception e) {
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }

    //選択ボタン押下
    public void selectButton(){
        try{
            hasErrorMessage = false;
            BusinessLogicException ex = new BusinessLogicException();
            //検索結果データ1件以上
            if(targetList.size() > 0){
                //チェック1件以上
                List<Item__c> retrunList = new List<Item__c>();
                Boolean isChecked = false;  //チェック1件以上ある？フラグ
                for( DisplayItem it : targetList ){
                    //チェックボックスがTRUEのものだけ返却用リストに追加
                    if(it.checkBox){
                        retrunList.add(it.item);
                        isChecked = true;
                    }
                }
                //チェック0件の場合、エラー出力
                if(! isChecked){
                    ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SELECTION_OR_MORE,'チェックボックス','1'));
                    throw ex;
                }
                Parameter.itemList = retrunList;
                //system.debug('返却：'+Parameter.itemList);
            }else{
                //検索結果が0件の場合、エラー
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SELECTION_OR_MORE,'チェックボックス','1'));
                throw ex;
            }       
        }catch (Exception e) {
            hasErrorMessage = true;//エラーを設定  
            CommonUtil.setErrorMessage(e);
        }
    }

    // 内部クラス
    public class DisplayItem {
        public Boolean checkBox{ get; set;} //チェックボックス
        public Item__c item{get; set;}      //商品

        //コンストラクタ
        public DisplayItem(Item__c targetItem) {
            this.checkBox = false;
            this.item     = targetItem;    
        }
    }
}