/**
 * @File Name          : TD401001Controller.cls
 * @Description        : 一括確認(長期)物件一覧（帳票）のコントローラ
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 2022/4/14 09:55:00
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2020/3/11   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public inherited sharing class TD401001Controller {

/** パブリック変数 */

//帳票用
public String paramShopId { get; set; }//パラメータの店舗
public String shopName { get; set; }//店舗名(表示用)
public List<excelProperty> propertyAndPortalList { get; set; }//物件+ポータルサイト掲載物件リスト
public Datetime today { get; set; }//実行日

//エラー確認用
public Boolean isOpenError { get; set; }//エラーフラグ
public String errorMessage { get; set; }//出力エラーメッセージ

/** プライベート変数 */
private Integer searchLimit;//検索上限


    //コンストラクタ
    public TD401001Controller() {

        try{
            system.debug('コンストラクタ');
            errorMessage = '';//エラーメッセージ
            propertyAndPortalList = new List<excelProperty>();//出力する物件
            searchLimit = Integer.valueOf(SystemConfig__c.getInstance().BulkConfirmationPropertyMaxCount__c);//検索上限をカスタム設定から取得

            //パラメータの店舗取得
            this.paramShopId = Apexpages.currentPage().getParameters().get('targetShopsName');

            //出力する物件を取得
            propertyAndPortalList = getProperty();

        } catch (Exception e) {
            isOpenError = true; //エラーを設定
            CommonUtil.setErrorMessage(e);

            for(Apexpages.Message errMsg : ApexPages.getMessages()){//ページでAPEX:Messageが使えないため、ページのエラーを文字列にする
                this.errorMessage += errMsg.getDetail() + '&#13;&#10;';//Excelに出力するエラーメッセージ設定('&#13;&#10;'はExcel用改行コード)
            }
        } 
    }

    //出力する物件を取得
    public List<excelProperty> getProperty(){
        try {
            isOpenError = false;//エラーを初期化
            BusinessLogicException ex = new BusinessLogicException();//ビジネスロジックException準備

            //パラメータチェック
            if(String.isBlank(this.paramShopId)){
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
                throw ex;
            }

            //店舗名の取得
            Shop__c s = [SELECT Name
                         FROM Shop__c
                         WHERE Id = :paramShopId];
            shopName = s.Name;

            //検索用項目宣言
            today = commonUtil.getNow();
        
            //検索
            String sql = '';
            sql += 'SELECT BulkConfirmationDate__c';                 //一括確認日
            sql += '      ,Building__r.Name';                        //建物名
            sql += '      ,Building__r.Address__c';                  //住所
            sql += '      ,Name';                                    //部屋番号
            sql += '      ,LiveStatus__c';                           //現況
            sql += '      ,PhotoCount__c';                           //写真枚数
            sql += '      ,FormerSupplier__r.Name';                  //元付業者名
            sql += '      ,FormerSupplier__r.Phone';                 //電話番号(元付業者)
            sql += '      ,FormerSupplier__r.FixedTermSend__c';      //定期送信
            sql += '      ,SuumoPanoramaShop__c';                    //SUUMOパノラマ掲載店舗
            sql += '      ,HomesPanoramaShop__c';                    //HOME'Sパノラマ掲載店舗
            sql += '      ,AtHomePanoramaShop__c';                   //at homeパノラマ掲載店舗
            sql += '      ,(';
            sql += '      SELECT IsSuumo__c, IsHomes__c, IsAtHome__c, IsChintaiNet__c, IsChintaiPanoramaPosting__c, Shop__r.IsChintaiPanoramaContract__c'; // 2022.04.12 CHINTAI対応により、取得項目追加
            sql += '        FROM PortalSitePostingPropertyProperty__r';
            sql += '        WHERE Shop__c = \'' + CommonUtil.escapeSingleQuotesEx(this.paramShopId) + '\'';
            sql += '        LIMIT 1';
            sql += '      )';          
            sql += '  FROM Property__c';

            Datetime todayTime = today.addDays(-7);

            //取得条件
            sql += ' WHERE IsBulkConfirmation__c      = true';
            sql += '   AND BulkConfirmationDate__c <= :todayTime ';
            sql += '   AND 	Id IN (SELECT Property__c';
			sql += '				FROM PortalSitePostingProperty__c';
			sql += '				WHERE Shop__c = \'' + CommonUtil.escapeSingleQuotesEx(this.paramShopId) + '\'';
			sql += '      			)';

            //取得順序
			sql += '  ORDER BY';
            sql += '        BulkConfirmationDate__c ASC';
            
            //取得数
            sql += ' LIMIT :searchLimit';

            System.debug(sql);

            // 検索結果取得
            List<Property__c> searchResultList = Database.query(sql);

            system.debug('検索結果;' + searchResultList);

            //ビジネスロジックException発行
            if (ex.hasMessage()){ 
                throw ex;
            }
            
            //検索した結果Listを回す
			for(Property__c p : searchResultList) {
				this.propertyAndPortalList.add(new excelProperty(p, paramShopId));
            }

            system.debug('帳票リスト' + propertyAndPortalList);

            // 検索結果返却
            return propertyAndPortalList;

        } catch(Exception e) {
            isOpenError = true;//エラーを設定
            throw e;
        }
    }

    //↓↓↓↓↓以下内部クラス↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓

    //物件+ポータルサイト掲載物件用内部クラス
	public class excelProperty{

        //帳票の物件
        public Property__c propertyRecord { get; set; }
        //帳票のポータルサイト掲載物件
        public PortalSitePostingProperty__c portalRecord { get; set; }   
        //SUUMOパノラマ掲載店舗
        public String isSuumoPanoramaCheck { get; set; }
        //HOME'Sパノラマ掲載店舗
        public String isHomesPanoramaCheck { get; set; }
        //at homeパノラマ掲載店舗
        public String isAtHomePanoramaCheck { get; set; }
        // CHINTAIパノラマ掲載店舗
        public String isChintaiPanoramaCheck { get; set; } // 2022.04.12 CHINTAI対応追加
        //経過日数
        public Integer pastDates { get; set; }
        //建物名エスケープ
        public String buildingName { get; set; }
        //物件名エスケープ
        public String name { get; set; }
        //住所名エスケープ
        public String buildingAddress { get; set; }
        //元付業者名エスケープ
        public String formerSupplierName { get; set; }
        //定期送信
        public String FixedTermSend { get; set; }
        //現況エスケープ
        public String liveStatus { get; set; }
        
        //コンストラクタ（引数：物件, 店舗）
        public excelProperty(Property__c targetPropertyRecord, Id shopId){

            //実行日の取得
            Date today = commonUtil.getToday();

            //パノラマ掲載店舗のチェックボックスを初期化
            isSuumoPanoramaCheck = '';
            isHomesPanoramaCheck = '';
            isAtHomePanoramaCheck = '';
            isChintaiPanoramaCheck = '';
            
            //変数の物件に、引数の物件を設定
            propertyRecord = targetPropertyRecord;

            //変数のポータルサイト掲載物件に、引数のポータルサイト掲載物件を設定       
            portalRecord = targetPropertyRecord.PortalSitePostingPropertyProperty__r[0].clone(true, true);
                
            //パノラマ掲載店舗のチェックボックス化
            if(propertyRecord.SuumoPanoramaShop__c == shopId) {
                isSuumoPanoramaCheck = '〇';
            }
            else{
                isSuumoPanoramaCheck = '✕';
            }
        
            if(propertyRecord.HomesPanoramaShop__c == shopId) {
                isHomesPanoramaCheck = '〇';
            }
            else{
                isHomesPanoramaCheck = '✕';
            }
        
            if(propertyRecord.AtHomePanoramaShop__c == shopId) {
                isAtHomePanoramaCheck = '〇';
            }
            else{
                isAtHomePanoramaCheck= '✕';
            }

            // ▼ 2022.04.12 CHINTAI対応追加
            if(portalRecord.IsChintaiPanoramaPosting__c && portalRecord.Shop__r.IsChintaiPanoramaContract__c) {
                isChintaiPanoramaCheck = '〇';
            }
            else{
                isChintaiPanoramaCheck= '✕';
            }
            // ▲ 2022.04.12 CHINTAI対応追加

            //経過日数を取得
            Datetime dt = propertyRecord.BulkConfirmationDate__c;
            Date getDate = dt.date();
            pastDates = getDate.daysBetween(today);

            //建物名エスケープ
            if (String.isNotBlank(propertyRecord.Building__r.Name)){
				buildingName = propertyRecord.Building__r.Name.escapeXml();                
            }
            
            //物件名エスケープ
            if (String.isNotBlank(propertyRecord.Name)){
				name = propertyRecord.Name.escapeXml();            
            }

            //住所エスケープ
            if (String.isNotBlank(propertyRecord.Building__r.Address__c)){
				buildingAddress = propertyRecord.Building__r.Address__c.escapeXml();            
            }
            
            //業者名エスケープ   
            if (String.isNotBlank(propertyRecord.FormerSupplier__r.Name)){
				formerSupplierName = propertyRecord.FormerSupplier__r.Name.escapeXml();        
            }
            
            //定期送信エスケープ   
            if (String.isNotBlank(propertyRecord.FormerSupplier__r.FixedTermSend__c)){
				FixedTermSend = propertyRecord.FormerSupplier__r.FixedTermSend__c.escapeXml();        
            }

            //現況エスケープ   
            if (String.isNotBlank(propertyRecord.LiveStatus__c)){
				liveStatus = propertyRecord.LiveStatus__c.escapeXml();        
            }

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
}