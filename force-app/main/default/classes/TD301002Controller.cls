/* *
* 退去予定更新（帳票）のコントローラ
*/
public inherited sharing class TD301002Controller {
    //*****public変数*****

    //自動メンテナンス設定用
    public List<ScreenScheduledToLeave> propertyList { get; set; }                  //物件リスト
    public Date today { get; set; }                                      //実行日
    //エラー確認用      
    public Boolean isOpenError { get; set; }                             //エラーフラグ
    public String errorMessage { get; set; }                             //出力エラーメッセージ
    
    //private変数
   
    private Integer searchLimit;                                         //検索上限
    
    //******************************************************************** public関数 ********************************************************************
    
    //コンストラクタ
    public TD301002Controller(){
        
        try {
            errorMessage = '';//エラーメッセージ
            propertyList = new List<ScreenScheduledToLeave>();//出力する物件
            searchLimit = Integer.valueOf(SystemConfig__c.getInstance().LeaveScheduleMaxCount__c);//検索上限をカスタム設定から取得
           
            getProperty();//出力する物件を取得
        }catch(Exception e){
            isOpenError = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
            
            for(Apexpages.Message errMsg : ApexPages.getMessages()){//ページでAPEX:Messageが使えないため、ページのエラーを文字列にする
                this.errorMessage += errMsg.getDetail() + '&#13;&#10;';//Excelに出力するエラーメッセージ設定('&#13;&#10;'はExcel用改行コード)
            }
        }
    }
     //出力する物件を取得
     public void getProperty(){
        try {
            isOpenError = false;//エラーを初期化
            BusinessLogicException ex = new BusinessLogicException();//ビジネスロジックException準備
            
            //検索用項目宣言
            today = commonUtil.getToday();
            
            
            //検索
            List<Property__c> searchResultList= [SELECT Building__r.District__c//地区
                        ,DeliveryYear__c//引渡年
                        ,DeliveryMonth__c//引渡月
                        ,DeliveryDay__c//引渡日
                        ,DeliveryTiming__c//引渡旬
                        ,Building__r.Name//建物名
                        ,Building__r.Address__c//住所
                        ,Name//部屋番号
                        ,PropertyCode__c//物件コード
                        ,DeliveryDateView__c //引渡日（表示用）
                FROM Property__c 
                WHERE LiveStatus__c = :CommonConst.PROPERTY_LIVESTATUS_SCHEDULEDTOLEAVE //現況=退去予定
                AND DeliveryType__c = :CommonConst.PROPERTY_DELIVERYTYPE_DUEDATE //引渡種別=期日指定
                ORDER BY Building__r.District__c,DeliveryDateSort__c//地区、引渡日（順序用）
                LIMIT :searchLimit
                ];
 

            //ビジネスロジックException発行
            if (ex.hasMessage()){ 
                throw ex;
            }

            //検索した結果Listを回す
			for(Property__c p : searchResultList) {
				this.propertyList.add(new ScreenScheduledToLeave(p));
            }

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
    public class ScreenScheduledToLeave{
        public Property__c property { get;set; }//レコード
        public String name  { get;set; }//物件名エスケープ
        public String buildingName  { get;set; }//建物名エスケープ
        public String buildingDistrict  { get;set; }//地区エスケープ
        public String buildingAddress  { get;set; }//住所エスケープ
        //コンストラクタ
        public ScreenScheduledToLeave(Property__c pro){
            if(pro.id != null){
                this.property = pro;
                //物件名が空でない
                if (String.isNotBlank(pro.Name)){
                    name = pro.Name.escapeXml();
                }
                //建物名が空でない
                if (String.isNotBlank(pro.Building__r.Name)){
                    buildingName = pro.Building__r.Name.escapeXml();
                }
                //地区が空でない
                if (String.isNotBlank(pro.Building__r.District__c)){
                    buildingDistrict = pro.Building__r.District__c.escapeXml();
                }
                //住所が空でない
                if (String.isNotBlank(pro.Building__r.Address__c)){
                    buildingAddress = pro.Building__r.Address__c.escapeXml();
                }
            }
        }
    }
}