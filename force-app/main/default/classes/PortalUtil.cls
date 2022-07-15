//ポータル共通メソッド
public class PortalUtil{

	// 00:00:00.000の時間 //問合せNo0601で追加
	private static final Time TIME_ZERO = Time.newInstance(0, 0, 0, 0);

	public PortalUtil() {
	}

	//暗号化
	public static String encryption(String param){

		// 初期化ベクトル
		Blob exampleIv = Blob.valueOf(SystemConfig__c.getInstance().ExampleIv__c);
		// 暗号化キー取得
		Blob cryptoKey = Blob.valueOf(SystemConfig__c.getInstance().HerokuSecretAccessKey__c);
		// 暗号化対象の平文をバイナリ変換
		Blob data = Blob.valueOf(param);
		// 初期化ベクトルと暗号鍵を使って平文を暗号化する
		Blob encrypted = Crypto.encrypt('AES256', cryptoKey, exampleIv, data);
		// 暗号化結果をバイナリ⇒文字列変換
		String encryptedParam = EncodingUtil.base64Encode(encrypted);

		return encryptedParam;
	}
	

	//復号化
	public static String decryption(String param){
		// 初期化ベクトル
		Blob exampleIv = Blob.valueOf(SystemConfig__c.getInstance().ExampleIv__c);
		// 復号化キー取得
		Blob cryptoKey = Blob.valueOf(SystemConfig__c.getInstance().HerokuSecretAccessKey__c);
		// 文字列変換⇒バイナリ
		Blob decryptedParam = EncodingUtil.base64Decode(param);
		//復号化
		Blob decrypted = Crypto.decrypt('AES256', cryptoKey, exampleIv, decryptedParam);
		//文字列に変換
		String decryptedString = decrypted.toString();
		return decryptedString;
	}

	//▼問合せNo0601で共通化
	/**
	* 予約不能数の増減対象かを判断する。
	* @param   Event event                               行動
	* @param   List<Id> shopIdList                       店舗ID
	* @param   AppointmentReceipt__c appointmentReceipt  来店受付
	* @param   Map<Id, List<ShopTransfer__c>> shopTransferMap 取引先に紐づく店舗異動情報
	* @return  Boolean True：増減、False：増減なし
	*/
	public static Boolean checkReserveCanNotCountUp(Event event, List<Id> shopIdList, AppointmentReceipt__c appointmentReceipt,Map<Id, List<ShopTransfer__c>> shopTransferMap){
		if(!shopIdList.contains(appointmentReceipt.Shop__c)){
			return false;
		}
		Boolean countUpFlg = false;
		// 店舗異動と一致する行動を確認
		List<ShopTransfer__c> shopTransferList =shopTransferMap.get(event.ownerId);
		for (ShopTransfer__c shopTransfer :shopTransferList) {
			if ((event.StartDateTime.date() >= shopTransfer.StartDate__c &&
				event.EndDateTime.date() <= shopTransfer.EndDate__c) && 
				appointmentReceipt.Shop__c == shopTransfer.OrgzanizationHierarchy__r.Shop__c) {
				countUpFlg = true;
				break;
			}
		}
		if (!countUpFlg) {
			return false;		
		}
		return checkReserveCanNotCountUp(event,appointmentReceipt);
	}
	public static Boolean checkReserveCanNotCountUp(Event event, AppointmentReceipt__c appointmentReceipt){
		// 終日行動がTrueの場合、開始時間を最小、終了時間を最大時間までセットする
		DateTime StartDateTime = event.StartDateTime;
		DateTime endDateTime = event.EndDateTime;        
		if(event.IsAllDayEvent){
			StartDateTime = Datetime.newInstance(event.StartDateTime.date(), Time.newInstance(0,0,0,0));
			endDateTime   = Datetime.newInstance(event.EndDateTime.date(), Time.newInstance(23,59,59,999));            
		}
		Datetime reserveStartDateTime = Datetime.newInstance(appointmentReceipt.ReceiptDate__c, appointmentReceipt.ReserveStartTime__c);
		Datetime reserveEndDateTime   = Datetime.newInstance(appointmentReceipt.ReceiptDate__c, appointmentReceipt.ReserveEndTime__c);
		if (appointmentReceipt.ReserveEndTime__c.hour() == TIME_ZERO.hour() && appointmentReceipt.ReserveEndTime__c.minute() == TIME_ZERO.minute()) {
			// 時間が00:00の場合は1日加算
			reserveEndDateTime = reserveEndDateTime.addDays(1);
		}
		// 行動時間に来店受付の時間が重なるか判断
		if(StartDateTime <= reserveStartDateTime && endDateTime >= reserveEndDateTime){
			// カウント増減する
			return true;
		}
		return false;
	}

	/**
	* トリガーの状態により予約不能数の増減をセットする
	* @param   Decimal reserveCanNotCount     現状の予約不能数
	* @param   Boolean updateBeforeOrAfterFlg 更新前後フラグ（False：更新前、True：更新後）
	* @return  Decimal 増減後の値
	*/
	public static Decimal setReserveCanNotCount(Decimal reserveCanNotCount,Boolean updateBeforeOrAfterFlg){
		Decimal changeReserveCanNotCount = 0;
		if(reserveCanNotCount <= 0 && 
			((Trigger.isUpdate && !updateBeforeOrAfterFlg) || 
			(Trigger.isDelete && Trigger.isBefore))){
			// 減算時に０は何もしない（変更前、削除時）
			return changeReserveCanNotCount;
		}
		
		if(Trigger.isInsert){
			// 新規登録後（加算）
			changeReserveCanNotCount += 1;
		}else if(Trigger.isUpdate && !updateBeforeOrAfterFlg){	
			// 更新前処理（減算）
			changeReserveCanNotCount -= 1;
		}else if(Trigger.isUpdate && updateBeforeOrAfterFlg){		
			// 更新後処理（加算）
			changeReserveCanNotCount += 1;
		}else if(Trigger.isDelete && Trigger.isBefore){		
			// 削除前処理（減算）
			changeReserveCanNotCount -= 1;
		}
		return changeReserveCanNotCount;
	}

	/*
	* 店舗異動の期間から行動を取得
	* @param   Set<Id> ownerIdSet      ユーザID
	* @param   Datetime startDateTime  開始日時
	* @param   Datetime endDateTime    終了日時
	* @return  List<Event> 対象の行動リスト
	*/
	public static List<Event> getEvent(Set<Id> ownerIdSet,Datetime startDateTime,Datetime endDateTime){
		List<Event> eventList = [
			SELECT	id
			,		StartDateTime						//開始日
			,		EndDateTime							//終了日
			,		notDuplicated__c					//重複不可フラグ
			,		AppointmentReceiptNoMaintenance__c	//来店受付メンテ不要 
			,		IsAllDayEvent						//終日行動 
			,		OwnerId
			FROM  Event
			WHERE OwnerId in :ownerIdSet
			AND	(DAY_ONLY(StartDateTime) >= :startDateTime.Date()
			AND	DAY_ONLY(EndDateTime)   <= :endDateTime.Date())  
			AND	Subject = :CommonConst.SUBJECT_HOLIDAY    
			ORDER BY 	OwnerId
			,			StartDateTime
		];
		if(eventList.isempty()){
			return null;
		}
		return eventList;
	}
	//▲問合せNo0601で共通化

}