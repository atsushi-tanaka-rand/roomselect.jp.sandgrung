// LINE会員トリガ
public with sharing class BL101001TriggerHandler {
	/** トリガから実行 */
	private boolean m_isExecuting = false;
	/** 新旧両方のトリガコール内のレコードの数 */
	private integer BatchSize = 0;

	/** コンストラクタ */
	public BL101001TriggerHandler(boolean isExecuting, integer size){
		m_isExecuting = isExecuting;
		BatchSize = size;
	}

	/** 登録前処理 */
	public void onBeforeInsert(LineMember__c[] newObjs){
	}
	
	/** 登録後処理 */
	public void onAfterInsert(LineMember__c[] newObjs, Map<ID, LineMember__c> newObjMap){
		// 対応の登録
		insertCorrespond(newObjs,newObjMap);
	}
	
	/** 更新前処理 */
	public void onBeforeUpdate(LineMember__c[] oldObjs, Map<ID, LineMember__c> oldObjMap, LineMember__c[] newObjs, Map<ID, LineMember__c> newObjMap){
	}
	
	/** 更新後処理 */
	public void onAfterUpdate(LineMember__c[] oldObjs, Map<ID, LineMember__c> oldObjMap, LineMember__c[] newObjs, Map<ID, LineMember__c> newObjMap){
	}
		
	/** 削除前処理 */
	public void onBeforeDelete(LineMember__c[] oldObjs, Map<ID, LineMember__c> oldObjMap){
	}
			
	/** 削除後処理 */
	public void onAfterDelete(LineMember__c[] oldObjs, Map<ID, LineMember__c> oldObjMap){
	}
	
	/** 復元後処理 */
	public void onUndelete(LineMember__c[] newObjs){
	}

	// ********************************
	// privateメソッド
	// ******************************** 
	/**
	 * 対応の新規登録
	 */
	private void insertCorrespond(LineMember__c[] newObjs, Map<ID, LineMember__c> newObjMap){
		List<Correspond__c> correspondList = new List<Correspond__c>();
		// 建物コード履歴差分の登録値を取得
		for (LineMember__c lineMember : newObjs) {
			Datetime now = CommonUtil.getNow();		
			Correspond__c correspond = new Correspond__c();

			correspond.EventDateTime__c = now;	// イベント時刻	
			correspond.IsSupportedListShow__c = true; // 対応確認
			correspond.IsBrowseFlg__c = true;	// 閲覧フラグ
			correspond.ListViewDate__c = CommonConst.LAST_DATE; // 一覧表示日時
			correspond.status__c = CommonConst.CORRESPOND_STATUS_NOTSUPPORTED;	// ステータス（未対応）
			correspond.LineFriendAddDate__c = now;// LINEお友達登録日時	
			correspond.LineMember__c = lineMember.Id;	// LINE会員ID
			correspond.FirstLineAddFlg__c = true;	// 初回LINE追加フラグ
			correspondList.add(correspond);
		}
		
		// 新規登録
		if(correspondList.size() > 0){
			SecureDML.secureInsert(correspondList);
		}
	}

}