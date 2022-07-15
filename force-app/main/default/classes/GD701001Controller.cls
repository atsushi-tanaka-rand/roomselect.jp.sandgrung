/* *
 * 手動メンテ一覧画面のコントローラ
 */
public inherited sharing class GD701001Controller {
    /** パブリック変数 */
    public Id shopId { get; set; }                                  // 店舗ID
    public String FormerSupplier { get; set; }                      // 元付業者
    public String Districts { get; set; }                           // 地区
    public String SearchDistricts { get; set; }                     // 地区（検索時の値）
    public List<Account> accountRecordList { get; set; }            // 明細リスト
    public Integer AccountIndex { get; set; }                       // 明細行Index
    public Boolean hasErrorMessage {get; set;}                      // エラーメッセージ保有フラグ
    public Boolean isOpenError {get; set;}                          // 初期エラー

    // private変数
    private List<Account> searchResultList { get; set;}             // 検索結果一時保存場所
    private Integer indexLimit;                                     // 明細上限
    
    /** 共通クラス */
    public GH201003ParameterClass GH201003Paremeter { get; set; }   // 店舗・地区選択引渡パラメータ

    public GD701001Controller() {
        try{
            
            // 明細上限
            indexLimit = Integer.valueOf(SystemConfig__c.getInstance().ManualLimit__c);
            
            // 元付業者初期化
            FormerSupplier = '';

            // 店舗・地区選択引渡パラメータ初期化
            GH201003Paremeter = new GH201003ParameterClass();

            // エラーメッセージフラグ初期化
            hasErrorMessage = false;

            // 店舗情報の取得
            Shop__c shop = CommonUtil.getStaffCurrentShop();

            shopId = shop.Id;                               // 店舗ID
            //2020.05.27　地区の初期表示処理削除 
            //Districts = shop.PortalSitePostingDistrict__c;  // 地区
            //if (String.isBlank(shop.PortalSitePostingDistrict__c)) {
            //    SearchDistricts = '';
            //    Districts = '';
            //} else {
            //    SearchDistricts = Districts.replace(';', '_');  // 検索地区の退避（「;」区切り⇒「_」区切りにして退避）
            //}

        
			system.debug(Districts);
        } catch(Exception e) {
            // エラー設定
            isOpenError = true;
            CommonUtil.setErrorMessage(e);
        }

    }

    // 検索ボタン処理
    public void search() {
        try{
            // 検索処理
            searchAccount();

            // 検索結果件数チェック
            if (searchResultList.size() == 0) {
                // ビジネスロジックException発行
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_NO_DATA));
                throw ex;
            }
            
            // 検索結果を画面に表示
            AccountIndex = 0;
            accountRecordList = new List<Account>();
            for (Account searchResult : searchResultList) {
                accountRecordList.add(searchResult);
            }
            
            // 空物件追加
            initPropertyFormerSupplier();

            // 検索地区の退避（「;」区切り⇒「_」区切りにして退避）
            SearchDistricts = Districts.replace(';', '_');

        }catch(Exception e){
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // 店舗・地区選択モーダルopen処理
    public void openModal() {
        GH201003Paremeter.selectedShopOrDistrictList = Districts.Split(';');
        GH201003Paremeter.isShopMode = false;
        GH201003Paremeter.isDrawing = true;
        GH201003Paremeter.noFirst = true;
    }
    
    // 店舗・地区選択モーダルclose処理
    public void closeModal() {
        Districts = '';
        for(String District : GH201003Paremeter.selectedShopOrDistrictList){
            if (Districts != '') {
                Districts += ';';
            }
            Districts += District;
        }
    }

    // 検索処理
    private void searchAccount() {
        try{
            // 選択地区のリスト作成
            List<String> DistrictList = Districts.Split(';');
            
            // SQL用String作成
            String FormerSupplierString = '%'+ CommonUtil.convertDisableWildcard(FormerSupplier) + '%';
            
            // 検索SQL作成
            String sql = '';
            sql += 'SELECT Id';
            sql += '      ,Name';
            sql += '      ,Phone';
            sql += '      ,Representative__c';
            sql += '      ,RepresentativePhone__c';
            sql += '      ,Address__c';
            sql += '      ,Email__c';
            sql += '      ,(';
            sql += '      SELECT Id, ManualMaintenanceDate__c';
            sql += '        FROM PropertyFormerSupplier__r';
            if (!String.isEmpty(Districts)){
                sql += '         WHERE Building__r.District__c IN :DistrictList';
            }
            sql += '       ORDER BY';
            sql += '             ManualMaintenanceDate__c DESC NULLS LAST'; //問合せNo.0795対応、手動最終メンテナンス日を表示する
            sql += '       LIMIT 1';
            sql += '       )';
            sql += '  FROM Account';
            sql += ' WHERE RecordType.DeveloperName = \'' + CommonConst.ACCOUNT_RECTYPE_SUPPLIER + '\'';
            sql += '   AND Name    LIKE :FormerSupplierString ';
            if (!String.isEmpty(Districts)){
                sql += '   AND Id      IN (SELECT FormerSupplier__c';
                sql += '                     FROM Property__c';
                sql += '                      WHERE Building__r.District__c IN :DistrictList';
                sql += '                  )';
            }
            sql += ' LIMIT ' + indexLimit;
                
            // 検索実行＆結果返却
            searchResultList = Database.query(sql);
        }catch(Exception e){
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // 空物件追加処理
    private void initPropertyFormerSupplier() {
        // 明細リスト内の物件の初期化（0件であれば空レコードをセット）
        for (Account acc : accountRecordList) {
            if (acc.PropertyFormerSupplier__r.isEmpty()){
                acc.PropertyFormerSupplier__r.add(new Property__c());
            }
        }
    }

}