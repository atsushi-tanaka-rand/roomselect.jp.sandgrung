/**
 * @File Name          : GH101003Controller.cls
 * @Description        : ユーザー異動登録画面のコントローラ
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              :
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 2020/3/31 18:39:30
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    2020/3/2   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
 **/
public with sharing class GH101003Controller {

//新規ユーザー異動モーダル
public GH101003Modal1ParameterClass GH101003Modal1Parameter{get; set;} 

/** パブリック変数 */
public Boolean isNew { get; set; }//新規登録フラグ
public Boolean isOpenError { get; set; }//エラーフラグ(初回のみ)
public Boolean hasErrorMessage { get; set; }//エラーメッセージ保有フラグ

/** 店舗異動情報の明細リスト */
public List<ScreenShopTransferInfo> shopTransferInfoRecordList { get; set; }

/** 新規ユーザー異動 */
//public List<screenShopTransfer> screenStInfoList { get; set; }//ユーザー異動情報
public List<ShopTransfer__c>  deleteStInfoList { get; set; }//削除リスト
public Integer stInfoIndex { get; set; }//明細行（リンク用）

/** メッセージ系 */
public String MSG_COM_V_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_SAVE);} private set;}    //js用保存確認メッセージ
public String MSG_COM_I_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);} private set;}    //js用保存完了メッセージ
public String MSG_COM_V_DELETE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_DELETE);} private set;}    //js用削除確認メッセージ
public String MSG_COM_I_DELETE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_DELETE);} private set;}    //js用削除完了メッセージ

/** プライベート変数 */
private Boolean modal1IsEdit;//新規ユーザー異動用編集フラグ

public GH101003Controller() {
	try{

		system.debug('コンストラクタ');

		//初期化
		init();

		//ユーザー異動情報List設定
		getShopTransferInfoList();

		system.debug('コンストラクタ2');

	} catch (Exception e) {
		isOpenError = true; //エラーを設定
		CommonUtil.setErrorMessage(e);
	}
}

//=====以下publicメソッド=================================================================
/**
* @description ★新規ユーザー異動モーダル(新規ボタン)
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/3/3 
* @return void 
**/
public void openNewShopTransferModal(){
	GH101003Modal1Parameter.isDrawing = true;
	GH101003Modal1Parameter.noFirst = true;
	GH101003Modal1Parameter.paramSTRecord = new ShopTransfer__c();
	GH101003Modal1Parameter.paramStaffName = '';
	GH101003Modal1Parameter.paramOrganizationName = '';
	GH101003Modal1Parameter.paramSTList = shopTransferInfoRecordList;
	GH101003Modal1Parameter.paramIndex = null;
	modal1IsEdit= false;
}

/**
* @description ★新規ユーザー異動モーダル(編集)
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/3/3 
* @return void 
**/
public void editShopTransferModal(){
	GH101003Modal1Parameter.isDrawing = true;
	GH101003Modal1Parameter.noFirst = true;
	modal1IsEdit= true;
	GH101003Modal1Parameter.paramSTRecord = shopTransferInfoRecordList[stInfoIndex].shopTransferRecord;
	GH101003Modal1Parameter.paramStaffName = shopTransferInfoRecordList[stInfoIndex].stringStaffName;
	GH101003Modal1Parameter.paramOrganizationName = shopTransferInfoRecordList[stInfoIndex].stringOrganizationName;
	GH101003Modal1Parameter.paramSTList = shopTransferInfoRecordList;
	GH101003Modal1Parameter.paramIndex = stInfoIndex;
}

/**
* @description ★新規ユーザー異動モーダルclose処理
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/3/3 
* @return void 
**/
public void closeNewShopTransferModal() {
	if (modal1IsEdit){ 
		this.shopTransferInfoRecordList[stInfoIndex].stringStaffName = GH101003Modal1Parameter.paramStaffName;
		this.shopTransferInfoRecordList[stInfoIndex].stringOrganizationName = GH101003Modal1Parameter.paramOrganizationName;
		this.shopTransferInfoRecordList[stInfoIndex].shopTransferRecord.Staff__c = GH101003Modal1Parameter.paramSTRecord.Staff__c;
		this.shopTransferInfoRecordList[stInfoIndex].shopTransferRecord.OrgzanizationHierarchy__c = GH101003Modal1Parameter.paramSTRecord.OrgzanizationHierarchy__c;
		this.shopTransferInfoRecordList[stInfoIndex].shopTransferRecord.StartDate__c = GH101003Modal1Parameter.paramSTRecord.StartDate__c;
		this.shopTransferInfoRecordList[stInfoIndex].shopTransferRecord.EndDate__c = GH101003Modal1Parameter.paramSTRecord.EndDate__c;
		this.shopTransferInfoRecordList[stInfoIndex].shopTransferRecord.StatusType__c = GH101003Modal1Parameter.paramSTRecord.StatusType__c;
		this.shopTransferInfoRecordList[stInfoIndex].shopTransferRecord.IsShopStaffType__c = GH101003Modal1Parameter.paramSTRecord.IsShopStaffType__c;
	}else{
		this.shopTransferInfoRecordList.add(new ScreenShopTransferInfo(GH101003Modal1Parameter.paramSTRecord, GH101003Modal1Parameter.paramStaffName, GH101003Modal1Parameter.paramOrganizationName));
		System.debug('新規明細' + shopTransferInfoRecordList);
	}
}


/**
* @description ★ユーザー異動削除
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/3/6 
* @return void 
**/
public void deleteShopTransferInfo(){
	try{
		hasErrorMessage = false;
		BusinessLogicException ex = new BusinessLogicException();

		//システム日付の取得
		Date getToday = CommonUtil.getToday();

		//ユーザー異動情報の明細がある場合
		if(shopTransferInfoRecordList.size() > 0){
			
			//削除処理
			for (Integer i=shopTransferInfoRecordList.size()-1; i >= 0; i--){
				//チェックボックスがTRUE
				if (shopTransferInfoRecordList[i].shopTransferCheck){

					//店舗異動Idがない場合
					if(shopTransferInfoRecordList[i].shopTransferRecord.Id == null){
						system.debug('レコードなし');
						//ユーザー異動情報リストから削除
						shopTransferInfoRecordList.remove(i);

					//店舗異動Idがある場合
					} else {
						system.debug('レコードあり');

						//削除エラーチェック
						if((shopTransferInfoRecordList[i].shopTransferRecord.StartDate__c <= getToday)
						&& (shopTransferInfoRecordList[i].shopTransferRecord.EndDate__c >= getToday)){

						//ビジネスロジックException発行
						ex.addMessage(CommonUtil.callMessageCreate(i+1 + '行目 ' + CommonConst.MSG_USER_E_DELETE_DURING_TERM));
						throw ex;

						} else {

						//削除用の店舗異動情報リストに追加
						deleteStInfoList.add(shopTransferInfoRecordList[i].shopTransferRecord);
						//ユーザー異動情報リストから削除
						shopTransferInfoRecordList.remove(i);
						system.debug('削除リスト；' + deleteStInfoList);
						}
					}
				}
			}
		}     
	} catch (Exception e) {
		hasErrorMessage = true;//エラーを設定  
		CommonUtil.setErrorMessage(e);
	}    
}


/**
* @description ★ユーザー異動保存
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/3/6 
* @return void 
**/
public void saveShopTransferInfo(){
	Savepoint sp = Database.setSavepoint();      //セーブポイント作成
	try{
		hasErrorMessage = false;

		system.debug('保存');

		//削除リストが空でなければ、リストを削除
		if(!deleteStInfoList.isEmpty()) {
			SecureDML.secureDelete(deleteStInfoList);
		}

		//ユーザー異動情報の明細がある場合
		if (shopTransferInfoRecordList.size() != 0){

			//upsert用の店舗異動リスト
			List<ShopTransfer__c> upsertShopTransferList = new List<ShopTransfer__c>();

			//店舗異動の楽観ロックチェック
			Set<Id> shopTransferCheckedSet = new Set<Id>();
			Map<Id, ShopTransfer__c> shopTransferCheckedMap = new Map<Id, ShopTransfer__c>();

			//upsert用の店舗異動リストに明細の情報を追加
            for(ScreenShopTransferInfo st :shopTransferInfoRecordList){

				ShopTransfer__c upsertShopTransfer = new ShopTransfer__c(
                    Staff__c = st.shopTransferRecord.Staff__c,
                    OrgzanizationHierarchy__c = st.shopTransferRecord.OrgzanizationHierarchy__c,
                    StartDate__c = st.shopTransferRecord.StartDate__c,
                    EndDate__c = st.shopTransferRecord.EndDate__c,
					StatusType__c = st.shopTransferRecord.StatusType__c,
					IsShopStaffType__c = st.shopTransferRecord.IsShopStaffType__c
				);
					
				//idがあれば、更新のためにId情報も追加
                if(st.shopTransferRecord.id != null){
						upsertShopTransfer.id = st.shopTransferRecord.id;
						shopTransferCheckedSet.add(st.shopTransferRecord.id);
						shopTransferCheckedMap.put(st.shopTransferRecord.id, st.shopTransferRecord);
                }
					upsertShopTransferList.add(upsertShopTransfer);
			}

			system.debug('更新リスト；' + upsertShopTransferList);

			//upsert用の店舗異動リストが空でなければ、明細の情報を保存(+ 楽観ロックチェック)
			if (!upsertShopTransferList.isEmpty()) {
            
				List<ShopTransfer__c> checkShopTransferData =[SELECT Id, SystemModstamp
												   	   FROM ShopTransfer__c
												   	   WHERE Id IN :shopTransferCheckedSet];
					
				for(ShopTransfer__c s: checkShopTransferData) {
					if(s.SystemModstamp != shopTransferCheckedMap.get(s.Id).SystemModstamp) {
						OptimisticLockException ex = new OptimisticLockException();
						throw ex;
					}
				}
				SecureDML.secureUpsert(upsertShopTransferList);
			}
		}
		getShopTransferInfoList();//ユーザー異動情報Listを再設定(SystemModstampを更新)

	} catch(Exception e){
		Database.rollback(sp);//処理をロールバック
		hasErrorMessage = true;//エラーを設定
		CommonUtil.setErrorMessage(e);
	}
}



//-----以下privateメソッド-----------------------------------------------------------------
/**
 * @description 初期化メソッド
 * @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/3/2
 * @return void
 **/
private void init(){
	try {
		//初期化
		isNew = false;
		isOpenError = false;
		hasErrorMessage = false;
		//店舗異動が取得できなければエラー
		CommonUtil.getStaffCurrentShop();
		//新規ユーザー異動モーダル初期化
		GH101003Modal1Parameter = new GH101003Modal1ParameterClass();
		//ユーザー異動の削除リスト初期化
		this.deleteStInfoList = new List<ShopTransfer__c>();

	} catch(Exception e) {
		isOpenError = true;//エラーを設定
		throw e;
	}
}

/**
 * @description ユーザー異動情報List設定
 * @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/3/2
 * @return void
 **/
private void getShopTransferInfoList(){
	try{
		hasErrorMessage = false;

        system.debug('ユーザー異動情報リスト取得');
        
        //内部クラスのリストを作成
		this.shopTransferInfoRecordList = new List<ScreenShopTransferInfo>();

		//システム日付の取得
		Date getToday = CommonUtil.getToday();

		// データ取得SQL作成
		String sql = '';
		sql += 'SELECT Id';
		sql += '      ,Name';
		sql += '      ,Staff__r.Name';
		sql += '      ,OrgzanizationHierarchy__r.HierarchyCode__c';
		sql += '      ,OrgzanizationHierarchy__r.OrganizationName__c';
		sql += '      ,StartDate__c';
		sql += '      ,EndDate__c';
		sql += '      ,StatusType__c';
		sql += '      ,IsShopStaffType__c';
		sql += '      ,SystemModstamp';
		sql += '       FROM ShopTransfer__c';
		sql += '       WHERE (StartDate__c <= :getToday ';
		sql += '            AND EndDate__c   >= :getToday ';
		sql += '      	      )';
		sql += '   		  OR StartDate__c >= :getToday ';
		sql += '   	   ORDER BY Staff__r.Name, StartDate__c, EndDate__c';

		// データ取得
		List<ShopTransfer__c> shopTransferList = Database.query(sql);

        system.debug('ユーザー異動' + sql);
        
        //取得したデータの明細を回す
		for(ShopTransfer__c s : shopTransferList) {
			this.shopTransferInfoRecordList.add(new ScreenShopTransferInfo(s));
		}

	}catch(Exception e) {
		hasErrorMessage = true;
		CommonUtil.setErrorMessage(e);
		throw e;
	}
}

//↓↓↓↓↓以下内部クラス↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓

/** 店舗異動情報明細の内部クラス */
public class ScreenShopTransferInfo {

//レコード本体
public ShopTransfer__c shopTransferRecord { get; set; }
//チェックボックス
public Boolean shopTransferCheck { get; set; }
//ユーザー名
public String stringStaffName { get; set; }
//組織階層名
public String stringOrganizationName { get; set; }

//コンストラクタ（引数：店舗異動）
public ScreenShopTransferInfo(ShopTransfer__c targetShopTransferRecord){

    //レコード設定
    this.shopTransferRecord = targetShopTransferRecord;
    //チェックボックス初期化
	this.shopTransferCheck = false;
	//ユーザー名
	this.stringStaffName = shopTransferRecord.Staff__r.Name;
	//組織階層名
	this.stringOrganizationName = shopTransferRecord.OrgzanizationHierarchy__r.HierarchyCode__c + '_' 
								+ shopTransferRecord.OrgzanizationHierarchy__r.OrganizationName__c;

}

//コンストラクタ（引数：店舗異動, ユーザー名, 組織階層名）
public ScreenShopTransferInfo(ShopTransfer__c paramShopTransferRecord, String paramStaff, String paramOrganizationName){
	
	//レコード設定
	this.shopTransferRecord = paramShopTransferRecord;
	//チェックボックス初期化
	this.shopTransferCheck = false;
	//ユーザー名
	this.stringStaffName = paramStaff;
	//組織階層名
	this.stringOrganizationName = paramOrganizationName;

}
}
	

}