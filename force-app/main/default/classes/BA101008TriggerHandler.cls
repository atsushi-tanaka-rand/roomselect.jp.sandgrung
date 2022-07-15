//行動トリガハンドラ
public with sharing class BA101008TriggerHandler {

    // 00:00:00.000の時間
    private static final Time TIME_ZERO = Time.newInstance(0, 0, 0, 0);

    /** トリガから実行 */    
    private boolean m_isExecuting = false;
    /** 新旧両方のトリガコール内のレコードの数 */
    private integer BatchSize = 0;

    // 更新前後フラグ（False：更新前、True：更新後）
    private Boolean updateBeforeOrAfterFlg = false;

    /** 重複更新フラグ */
    public Static boolean isDuplicateUpdate = false;

    /** 来店受付更新対象リスト */ // 問合せNo0439で追加
    private Map<Id,AppointmentReceipt__c> updateAppointmentReceiptMap;  
    
    /** コンストラクタ */
    public BA101008TriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    
    /** 登録前処理 */
    public void onBeforeInsert(Event[] newObjs){
        isEventDatetimeDuplicate(newObjs);
    }

    /** 登録後処理 */
    public void onAfterInsert(Event[] newObjs, Map<ID, Event> newObjMap){     
        appointmentReceiptUpdate(newObjs);  // 問合せNo0439で変更 共通化
    }
    
    /** 更新前処理 */
    public void onBeforeUpdate(Event[] oldObjs, Map<ID, Event> oldObjMap, Event[] newObjs, Map<ID, Event> newObjMap){
        // 重複更新対応
        if (isDuplicateUpdate) {
            return;
        }
        isEventDatetimeDuplicate(newObjs);    
    }
     /** 更新後処理 */
    public void onAfterUpdate(Event[] oldObjs, Map<ID, Event> oldObjMap, Event[] newObjs, Map<ID, Event> newObjMap){
        // 重複更新対応
        if (isDuplicateUpdate) {
            return;
        }
        //▼問合せNo0439で変更
        Savepoint sp = Database.setSavepoint();      //セーブポイント作成        

        try {
            this.updateAppointmentReceiptMap = new Map<Id,AppointmentReceipt__c>();
            this.updateBeforeOrAfterFlg = false;
            appointmentReceiptReserveCanNotCount(oldObjs);     
            // 来店受付予約不能数算出処理
            this.updateBeforeOrAfterFlg = true;
            appointmentReceiptReserveCanNotCount(newObjs);

            List<AppointmentReceipt__c> updateAppointmentReceiptList = updateAppointmentReceiptMap.values();
            if(updateAppointmentReceiptList.size() > 0){
                // 更新
                SecureDML.secureUpdate(updateAppointmentReceiptList);
            }
            
        } catch (Exception e){
            System.debug('異常終了='+e);
            Database.rollback(sp);//処理をロールバック
        }
        //▲問合せNo0439で変更
    }
    /** 削除前処理 */
    public void onBeforeDelete(Event[] oldObjs, Map<ID, Event> oldObjMap){
        appointmentReceiptUpdate(oldObjs);   // 問合せNo0439で変更 共通化
    }
    /** 削除後処理 */
    public void onAfterDelete(Event[] oldObjs, Map<ID, Event> oldObjMap){   
    }

     /** 復元後処理 */
    public void onUndelete(Event[] newObjs){  
    }

    // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    // ---------privateメソッド-----------------------------------------------
    // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
    /**
     * スケジュールの重複チェック
     * @param  Event  Objs     行動Obj(newObjs)
     * @return 
     */
    private void isEventDatetimeDuplicate(Event[] Objs) {
                
        Savepoint sp = Database.setSavepoint();      //セーブポイント作成     

        try {
            Boolean isDuplicate = false;            // newObjs内で重複レコードがあるか
            List<Event> dbSearchList = new List<Event>();//DB検索用リスト
            Event targetEvent = null;

            List<Id> userIdList = new List<Id>();   // 行動のユーザIDList
            Datetime searchStartDate;               // DBの行動絞り込み用、行動の開始日時
            Datetime searchEndDate;                 // DBの行動絞り込み用、行動の終了日時
            
            // ▼ newObjs内を検索
            for (Integer i = 0; i < objs.size(); i++) {
                isDuplicate =false;
                for (Integer j = 0; j < objs.size(); j++) {
                    // 自分自身はスキップ
                    if (i == j) {
                        continue;
                    }
    
                    // リスト内判定
                    if(judgeEventDatetimeDuplicate(objs[i], objs[j])) {
                        objs[i].addError(CommonConst.MSG_CUST_E_REGISTRATION_EVENT_DUPLICATE);
                        isDuplicate = true;
                        break;
                    }
                }
    
                // 自身に対象で無ければ、DB検索対象に追加
                if (!isDuplicate) {
                    targetEvent = objs[i];
                    dbSearchList.add(targetEvent);

                    // ユーザの一覧を生成
                    if(!userIdList.contains(targetEvent.OwnerId)){
                        userIdList.add(targetEvent.OwnerId);
                    }
                    // 最小の開始日時を取得
                    if(searchStartDate > targetEvent.StartDateTime || searchStartDate == null){
                        searchStartDate = targetEvent.StartDateTime;
                    }
                    // 最大の終了日時を取得
                    if(searchEndDate < targetEvent.EndDateTime || searchEndDate == null){
                        searchEndDate = targetEvent.EndDateTime;
                    }
                }
            }
            // ▲ newObjs内を検索
      
            // ▼ DBを検索
            // 検索SQL作成
            String sql = '';
            sql += ' SELECT Id, OwnerId, StartDateTime, EndDateTime ';   // 行動ID、任命先Id、開始日時、終了日時
            sql += ' FROM  EVENT ';                                      // 行動
            sql += ' WHERE  notDuplicated__c = true ';      //重複不可フラグがtrue
            sql += ' AND    OwnerId IN :userIdList';        //任命先Idが一致
            sql += ' AND    StartDateTime < :searchEndDate ';  // 日付が期間内      
            sql += ' AND    EndDateTime > :searchStartDate '; 
               

            // 検索実行＆結果返却
            List<Event> eventList =  Database.query(sql); 

            //重複する行動は、エラーとする
            for(Event target : dbSearchList){
                for(Event event : eventList){                
                    if(judgeEventDatetimeDuplicate(target,event)){                                        
                        target.addError(CommonConst.MSG_CUST_E_REGISTRATION_EVENT_DUPLICATE);
                        break;
                    } 
                }                        
            }
            // ▲ DBを検索            
        } catch (Exception e){
            System.debug('異常終了='+e);
            Database.rollback(sp);//処理をロールバック
        }
    }

    /**
     * スケジュールが重複しているか判定する
     * @param  Event targetEvent    行動Obj
     * @param  Event event     行動Obj
     * @return Boolean 重複である：true、重複でない：false
     */
    private Boolean judgeEventDatetimeDuplicate(Event targetEvent, Event event) {
        Boolean isDuplicate = false;
        if(targetEvent.notDuplicated__c == true
            && ((targetEvent.Id == null && event.Id == null) || targetEvent.Id != event.Id)
            && targetEvent.ownerId == event.ownerId
            && targetEvent.startDateTime < event.endDateTime
            && targetEvent.endDateTime > event.startDateTime){                                       
                isDuplicate = true;
        } 
        return isDuplicate;
    }

    //▼問合せNo0439で追加
    // 予約不能数更新処理
    private void appointmentReceiptUpdate(Event[] Objs){
        Savepoint sp = Database.setSavepoint();      //セーブポイント作成        

        try {
            this.updateAppointmentReceiptMap = new Map<Id,AppointmentReceipt__c>();
            appointmentReceiptReserveCanNotCount(Objs); 
            List<AppointmentReceipt__c> updateAppointmentReceiptList = updateAppointmentReceiptMap.values();
            if(updateAppointmentReceiptList.size() > 0){
                // 更新
                SecureDML.secureUpdate(updateAppointmentReceiptList);
            }
        } catch (Exception e){
            System.debug('異常終了='+e);
            Database.rollback(sp);//処理をロールバック
        }
    }
    //▲問合せNo0439で追加
    
    // 予約不能数計算処理
    //
    private void appointmentReceiptReserveCanNotCount(Event[] Objs) {
                
        List<Event> updateList = new List<Event>();		// 行動の来店受付メンテ不要の変更対象リスト
        List<Id> userIdList = new List<Id>();			// 行動のユーザIDList
        Datetime searchStartDate;						// 来店受付絞り込み用、行動の開始日時（日付のみ）
        Datetime searchEndDate;							// 来店受付絞り込み用、行動の終了日時（日付のみ）
        
        for(Event event : Objs){
            // 来店受付メンテ不要が立っていれば、来店受付の更新をしない
            if(event.AppointmentReceiptNoMaintenance__c){
                Event addEvent = new Event(Id = event.Id);//更新する行動
                addEvent.AppointmentReceiptNoMaintenance__c = false;
                //追加する
                updateList.add(addEvent);
                continue;
            }

            // ユーザの一覧を生成
            if(!userIdList.contains(Event.OwnerId)){
                userIdList.add(Event.OwnerId);
            }
            // 最小の開始日時を取得（検索用に時分秒を取り除く）
            if(searchStartDate > event.StartDateTime || searchStartDate == null){
                searchStartDate = event.StartDateTime;
            }
            // 最大の終了日時を取得（検索用に時分秒を取り除く）
            if(searchEndDate < event.EndDateTime || searchEndDate == null){
                searchEndDate = event.EndDateTime;
            }
        }

		//▼ 2022.02.09 No0601 対応で店舗情報の取得方法を修正
        // 有効な店舗を取得
		Map<Id, List<ShopTransfer__c>> shopTransferMap = new  Map<Id, List<ShopTransfer__c>>();
        shopTransferMap = CommonUtil.getStaffCurrentShopMap(userIdList,searchStartDate,searchEndDate);

        // 有効な店舗が取得できない場合終了
        if(shopTransferMap == null){
            return;
        }
		// 店舗IDをリストに取得
		List<Id> shopIdList = new List<Id>();// 店舗IDList
		for(id userId : userIdList){
			List<ShopTransfer__c> shopTransferList = shopTransferMap.get(userId);
			for(ShopTransfer__c shopTransfer :shopTransferList){
				if(!shopIdList.contains(shopTransfer.OrgzanizationHierarchy__r.Shop__c)){
					shopIdList.add(shopTransfer.OrgzanizationHierarchy__r.Shop__c);
				}
			}
		}
		// 対象の行動から大まかな来店受付を取得する（ガバナ制限の回避）
		List<AppointmentReceipt__c> appointmentReceiptList = [
			SELECT id
			,     Shop__c
			,     ReceiptDate__c
			,     ReserveStartTime__c
			,     ReserveEndTime__c
			,     ReserveCanNotCount__c
			FROM  AppointmentReceipt__c
			WHERE Shop__c in :shopIdList
			AND (ReceiptDate__c >= :searchStartDate.Date() AND ReceiptDate__c<= :searchEndDate.Date())
			ORDER BY Shop__c
			,        ReceiptDate__c
			,        ReserveStartTime__c                               
		];
		//▲ 2022.02.09 No0601 対応で店舗情報の取得方法を修正
        // 行動でループ
        for(Event obj: Objs){
            // 行動不可フラグfalseの場合
            if(!obj.notDuplicated__c){
                // 次の行動へ
                continue;
            }
            // 更新対象の来店受付を取得
            for(AppointmentReceipt__c appointmentReceipt : appointmentReceiptList){
                // 増減対象かチェック
                if(! PortalUtil.checkReserveCanNotCountUp(obj,shopIdList,appointmentReceipt,shopTransferMap)){
                    // 対象でない場合次へ
                    continue;
                }
                // Listの作成準備(更新対象項目の設定)
                Decimal changeReserveCanNotCount = PortalUtil.setReserveCanNotCount(appointmentReceipt.ReserveCanNotCount__c,this.updateBeforeOrAfterFlg);
				// system.debug('行動トリガ店舗：'+ appointmentReceipt.shop__c + '| 日：'+appointmentReceipt.ReceiptDate__c + '| 開始：'+ appointmentReceipt.ReserveStartTime__c + '|終了：' +appointmentReceipt.ReserveEndTime__c +  '|増減値：'+ changeReserveCanNotCount);
                if(changeReserveCanNotCount == 0){
                    // 増減なければ更新しない
                    continue;
                }

                //▼問合せNo0439で変更
                if(this.updateAppointmentReceiptMap.containsKey(appointmentReceipt.Id)){
                    // セットされていれば対象ユーザIDのMapに値を加える                    
                    AppointmentReceipt__c targetAppointmentReceipt = this.updateAppointmentReceiptMap.get(appointmentReceipt.Id);
                    targetAppointmentReceipt.ReserveCanNotCount__c += changeReserveCanNotCount;
                    
                    this.updateAppointmentReceiptMap.put(appointmentReceipt.Id,targetAppointmentReceipt);
                    
                }else{
                    // セットされていなければユーザIDをキーとしてMapをセットする。
                    AppointmentReceipt__c targetAppointmentReceipt = new AppointmentReceipt__c(
                        Id = appointmentReceipt.Id ,
                        ReserveCanNotCount__c = appointmentReceipt.ReserveCanNotCount__c + changeReserveCanNotCount
                        ); 
                    this.updateAppointmentReceiptMap.put(appointmentReceipt.Id, targetAppointmentReceipt);
                }
                //▲問合せNo0439で変更
            }
            
        }

        //行動の更新
        // 空でなければ更新する
        if (!updateList.isEmpty()) {
            isDuplicateUpdate = true;  //重複更新フラグをTrueにする
            SecureDML.secureUpdate(updateList);
            isDuplicateUpdate = false; //重複更新フラグをFalseにする
        }

    }
}