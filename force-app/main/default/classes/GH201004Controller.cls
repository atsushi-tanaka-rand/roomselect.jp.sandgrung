/**
 * 利用店舗選択画面のコントローラ
 */
public inherited sharing class GH201004Controller {
    /** public変数 */
    public Boolean isOpenError { get; set; }                        // 初期表示エラーフラグ
    public Boolean hasErrorMessage { get; set; }                    // エラーフラグ
    public String nowUserShop { get; set; }                         // ログインユーザの店舗
    public String nowUserShopName { get; set;}                      // ログインユーザの店舗名
    public list<SelectOption> usrShopSelectList { get; set; }       // 選択店舗リスト
    public String loginUserId { get; set; }                         // ログインユーザId
    public String MSG_COM_I_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);} private set;}    //js用保存完了メッセージ

    // コンストラクタ
    public GH201004Controller() {
        try {

            // 初期化
            init();

            // データ取得
            getData();


        } catch(Exception e) {

            //エラー設定
            this.isOpenError = true;
            //ビジネスロジックException発行
            CommonUtil.setErrorMessage(e);

        }
    }

    // 設定処理
    public void shopSetting(){
        try{
            // 更新用ユーザ設定レコード
            UserSetting__c upsertUserSetting = new UserSetting__c();

            // 更新するユーザ設定が既に存在するかどうか
            List<UserSetting__c> userSettingList = [ SELECT Id FROM UserSetting__c WHERE setupOwnerId = :this.loginUserId WITH SECURITY_ENFORCED];

            // Id設定
            if(userSettingList.size() != 0){
                upsertUserSetting.Id = userSettingList[0].Id;    // 存在する場合はIDを指定
            }
            
            // 項目設定
            upsertUserSetting.setupOwnerId = this.loginUserId;
	        upsertUserSetting.ShopId__c = this.nowUserShop;

            
            // 更新処理
            upsert getSecureRecord(upsertUserSetting);

            // データ取得(再描画用)
            getData();
            
        } catch(Exception e) {

            // エラー設定
            this.hasErrorMessage = true;
            // ビジネスロジックException発行
            CommonUtil.setErrorMessage(e);
        }
    }

    // 初期化メソッド
    private void init(){

        this.isOpenError = false;
        this.hasErrorMessage = false;
        this.nowUserShop = '';
        this.usrShopSelectList = new list<SelectOption>();

    }
    
    // データ取得メソッド
    private void getData() {
        
            // 店舗情報の取得
            Shop__c shop = CommonUtil.getStaffCurrentShop();
            this.nowUserShop     = shop.Id;
            this.nowUserShopName = shop.Name;

            // ログインユーザID取得
            this.loginUserId = UserInfo.getUserId();

            // 店舗選択リスト取得
            this.usrShopSelectList = CommonUtil.getShopSelectedOptionFromStaffId(this.loginUserId, false, false);        
    }

    /**
     * セキュアレコードを取得する
     * カスタム設定はSalesForceのバグにより、SecureDMLで処理できないため、ここでセキュリティチェックを行う。
     * ※ 登録／更新権限はこちらの方式でもチェック不可のため、参照権限のみチェックする
     */
    public class SecureDMLException extends Exception {}
    public static sObject getSecureRecord(sObject record) {
		if (record == null) throw new DMLException();

		// sObjectへのアクセス権限(CRUD)
		Schema.SObjectType type = record.getSObjectType();
		Schema.DescribeSObjectResult describe= type.getDescribe();
		if (!describe.isAccessible()) {
			throw new SecureDMLException('オブジェクトのアクセス権限がありません。:' + describe.getName());
		}

		// フィールドへのアクセス権限(FLS)
		String[] removedFieldNames = new String[] {};
		Map<String, Schema.SObjectField> fieldMap = describe.fields.getMap();
		for (String key: fieldMap.keySet()) {
			Schema.DescribeFieldResult fieldResult = fieldMap.get(key).getDescribe();

			//問合せNo0650で追加_パッケージにて利用店舗の変更にエラーとなるため2項目をチェック対象外
			if(describe.isCustomSetting() &&
			  (fieldResult.getName() == 'LastViewedDate' || fieldResult.getName() == 'LastReferencedDate')) {
				continue;
			}
			if (!fieldResult.isAccessible()) {
				removedFieldNames.add(describe.getName() + '.' + fieldResult.getName());
			}
		}
		if(!removedFieldNames.isEmpty()){
			throw new SecureDMLException('アクセス権限がない項目があります。:' + String.join(removedFieldNames, ','));
		}

		// アクセス可能な項目のみのレコードを取得
		return record;
	}

}