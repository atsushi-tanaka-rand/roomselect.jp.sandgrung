// 店舗異動トリガーハンドラ
public with sharing class BA101009TriggerHandler {

	/** トリガから実行 */
	private boolean m_isExecuting = false;
	/** 新旧両方のトリガコール内のレコードの数 */
	private integer BatchSize = 0;

	// 自社ポータル権限フラグ
	private Boolean isOpetionPorta ;

	// 組織階層からの店舗情報取得用マップ
	private Map<Id, OrganizationHierarchy__c> shopTransferMap;

	//システム日付の取得
	Datetime getNow = CommonUtil.getNow();

	/** コンストラクタ */
	public BA101009TriggerHandler(boolean isExecuting, integer size){
		m_isExecuting = isExecuting;
		BatchSize = size;
		// 店舗取得（店舗異動が組織階層であるため）
		this.shopTransferMap = getOrganizationHierarchyMap();
		this.isOpetionPorta = AuthorityCheckUtil.getAuthorityOptionPortal(false);
	}

	/** 登録前処理 */
	public void onBeforeInsert(ShopTransfer__c[] newObjs){
		// 処理なし
	}

	/** 登録後処理 */
	public void onAfterInsert(ShopTransfer__c[] newObjs, Map<ID, ShopTransfer__c> newObjMap){     
		system.debug('-----------------------新規登録-------------------------');
		appointmentReceiptUpdateShopTransfer(newObjs);   
	}

	/** 更新前処理 */
	public void onBeforeUpdate(ShopTransfer__c[] oldObjs, Map<ID, ShopTransfer__c> oldObjMap, ShopTransfer__c[] newObjs, Map<ID, ShopTransfer__c> newObjMap){
		// 処理なし
	}

	/** 更新後処理 */
	public void onAfterUpdate(ShopTransfer__c[] oldObjs, Map<ID, ShopTransfer__c> oldObjMap, ShopTransfer__c[] newObjs, Map<ID, ShopTransfer__c> newObjMap){
		appointmentReceiptUpdateShopTransferUpdate(oldObjs, newObjs,  newObjMap);
	}

	/** 削除前処理 */
	public void onBeforeDelete(ShopTransfer__c[] oldObjs, Map<ID, ShopTransfer__c> oldObjMap){
		system.debug('-----------------------削除-------------------------');
		appointmentReceiptUpdateShopTransfer(oldObjs);   
	}

	/** 削除後処理 */
	public void onAfterDelete(ShopTransfer__c[] oldObjs, Map<ID, ShopTransfer__c> oldObjMap){   
		// 処理なし
	}

	/** 復元後処理 */
	public void onUndelete(ShopTransfer__c[] newObjs){  
		// 処理なし
	}

// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// ---------privateメソッド-----------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /**
    * 店舗の異動等に際して来店受付の予約不能数を変更する
    * @param   ShopTransfer__c[]        oldObjs
    * @param   ShopTransfer__c[]        newObjs
    * @param   Map<ID, ShopTransfer__c> newObjMap
    * @return  なし
    */
	private void appointmentReceiptUpdateShopTransferUpdate(ShopTransfer__c[] oldObjs, ShopTransfer__c[] newObjs, Map<ID, ShopTransfer__c> newObjMap){
		// 自社ポータル権限が無ければ処理しない
		if(!this.isOpetionPorta){
			return;
		}

		Savepoint sp = Database.setSavepoint();	//セーブポイント作成 
		try {
			Set<Id> ownerIdOldSet = new Set<Id>();
			Set<Id> ownerIdNewSet = new Set<Id>();
			Datetime searchStartDateOld;	// 来店受付絞り込み用、行動の開始日時
			Datetime searchEndDateOld;		// 来店受付絞り込み用、行動の終了日時
			Datetime searchStartDateNew;	// 来店受付絞り込み用、行動の開始日時
			Datetime searchEndDateNew;		// 来店受付絞り込み用、行動の終了日時

			List<shopTransfer> changeOldList  = new List<shopTransfer>();
			List<shopTransfer> changeNewList  = new List<shopTransfer>();
			// 変更前と後で相違がある対象を抽出（ユーザー異動登録からの場合一括で更新されるため）
			for(ShopTransfer__c oldShopTransfer : oldObjs){
				ShopTransfer__c newShopTransfer = newObjMap.get(oldShopTransfer.Id);

				if(oldShopTransfer.StartDate__c			  == newShopTransfer.StartDate__c && 
				oldShopTransfer.EndDate__c				  == newShopTransfer.EndDate__c && 
				oldShopTransfer.OrgzanizationHierarchy__c == newShopTransfer.OrgzanizationHierarchy__c &&
				oldShopTransfer.Staff__c				  == newShopTransfer.Staff__c){
					continue;
				}

				// 開始日、終了日、組織階層が相違
				// 最小の開始日時を取得
				if(searchStartDateOld > oldShopTransfer.StartDate__c || searchStartDateOld == null){
					searchStartDateOld = oldShopTransfer.StartDate__c;
				}
				// 最大の終了日時を取得
				if(searchEndDateOld < oldShopTransfer.EndDate__c || searchEndDateOld == null){
					searchEndDateOld = oldShopTransfer.EndDate__c;
				}
				// 最小の開始日時を取得
				if(searchStartDateNew > newShopTransfer.StartDate__c || searchStartDateNew == null){
					searchStartDateNew = newShopTransfer.StartDate__c;
				}
				// 最大の終了日時を取得
				if(searchEndDateNew < newShopTransfer.EndDate__c || searchEndDateNew == null){
					searchEndDateNew = newShopTransfer.EndDate__c;
				}

				OrganizationHierarchy__c oldShop = shopTransferMap.get(oldShopTransfer.OrgzanizationHierarchy__c);
				ownerIdOldSet.add(oldShopTransfer.Staff__c);
				changeOldList.add(new shopTransfer(oldShopTransfer.Staff__c,oldShop.Shop__c,oldShopTransfer.StartDate__c,oldShopTransfer.EndDate__c));

				OrganizationHierarchy__c newShop = shopTransferMap.get(newShopTransfer.OrgzanizationHierarchy__c);
				ownerIdNewSet.add(newShopTransfer.Staff__c);
				changeNewList.add(new shopTransfer(newShopTransfer.Staff__c,newShop.Shop__c,newShopTransfer.StartDate__c,newShopTransfer.EndDate__c));
            }   

			Map<Id,AppointmentReceipt__c> updateAppointmentReceiptMap = new Map<Id,AppointmentReceipt__c>(); 
			// 変更前の予約不能数リスト取得
			system.debug('-----------------------更新前データ-------------------------');
			updateAppointmentReceiptMap = setupdateAppointmentReceipt(ownerIdOldSet,searchStartDateOld,searchEndDateOld,changeOldList,updateAppointmentReceiptMap,false);

			system.debug('-----------------------更新後データ-------------------------');
			// 変更後の予約不能数リスト取得
			updateAppointmentReceiptMap = setupdateAppointmentReceipt(ownerIdNewSet,searchStartDateNew,searchEndDateNew,changeNewList,updateAppointmentReceiptMap,true);

			// 更新
			if(updateAppointmentReceiptMap.size() > 0){
				SecureDML.secureUpdate(updateAppointmentReceiptMap.values());
			}
		} catch (Exception e){
			System.debug('異常終了='+e);
			Database.rollback(sp);//処理をロールバック
		}
	}

    /**
    * 店舗の異動等に際して来店受付の予約不能数を変更する
    * 登録、削除対象
    * @param   ShopTransfer__c[] checkObjs 確認対象オブジェクト
    * @return  なし
    */
    private void appointmentReceiptUpdateShopTransfer(ShopTransfer__c[] checkObjs){
		// 自社ポータル権限が無ければ処理しない
		if(!this.isOpetionPorta){
			return;
		}
		Savepoint sp = Database.setSavepoint();	//セーブポイント作成 
		try {  
			Set<Id> ownerIdSet = new Set<Id>();
			Datetime searchStartDate;		// 来店受付絞り込み用、行動の開始日時
			Datetime searchEndDate;			// 来店受付絞り込み用、行動の終了日時
			List<shopTransfer> changeList  = new List<shopTransfer>();

			// 変更前と後で相違がある対象を抽出（ユーザー異動登録からの場合一括で更新されるため）
			for(ShopTransfer__c checkObj : checkObjs){
				// 開始日、終了日、組織階層が相違
				// 最小の開始日時を取得（検索用に時分秒を取り除く）
				if(searchStartDate > checkObj.StartDate__c || searchStartDate == null){
					searchStartDate = checkObj.StartDate__c;
				}
				// 最大の終了日時を取得（検索用に時分秒を取り除く）
				if(searchEndDate < checkObj.EndDate__c || searchEndDate == null){
					searchEndDate = checkObj.EndDate__c;
				}
				ownerIdSet.add(checkObj.Staff__c);
				OrganizationHierarchy__c Shop = shopTransferMap.get(checkObj.OrgzanizationHierarchy__c);
				changeList.add(new shopTransfer(checkObj.Staff__c,Shop.Shop__c,checkObj.StartDate__c,checkObj.EndDate__c));
			}   
			// 対象行動リスト取得
			Map<Id,AppointmentReceipt__c> updateAppointmentReceiptMap = new Map<Id,AppointmentReceipt__c>(); 
			updateAppointmentReceiptMap = setupdateAppointmentReceipt(ownerIdSet ,searchStartDate,searchEndDate, changeList,updateAppointmentReceiptMap,false);

			// 更新
			if(updateAppointmentReceiptMap.size() > 0){
				SecureDML.secureUpdate(updateAppointmentReceiptMap.values());
			}

		} catch (Exception e){
			System.debug('異常終了='+e);
			Database.rollback(sp);//処理をロールバック
		}
	}

    /**
    * 来店受付予約不能数の増減
    * @param     Set<Id> ownerIdSet                                        増減元の来店受付リスト
    * @param     Datetime searchStartDate                                  来店受付絞り込み用、行動の開始日時
    * @param     Datetime searchEndDate                                    来店受付絞り込み用、行動の終了日時
    * @param     List<shopTransfer> changeList                             店舗異動変更リスト
    * @param     Map<Id,AppointmentReceipt__c> updateAppointmentReceiptMap 増減加減中の来店受付のマップ
    * @param     Boolean updateBeforeOrAfterFlg                            更新前後フラグ（False：更新前、True：更新後）
    * @return    Map<Id,AppointmentReceipt__c>                             増減後の来店受付のマップ
    */
    private Map<Id,AppointmentReceipt__c>  setupdateAppointmentReceipt(
				Set<Id> ownerIdSet ,Datetime searchStartDate,Datetime searchEndDate,
				List<shopTransfer> changeList,
				Map<Id,AppointmentReceipt__c> updateAppointmentReceiptMap,
				Boolean updateBeforeOrAfterFlg){
		// 行動取得
		List<Event> eventList = PortalUtil.getEvent(ownerIdSet,searchStartDate,searchEndDate);
		if(eventList == null){
			return updateAppointmentReceiptMap;
		}

		// 行動範囲内の来店受付を取得
		List<AppointmentReceipt__c> appointmentReceiptList = getAppointmentReceiptList(eventList,changeList);
		if(appointmentReceiptList == null){
			return updateAppointmentReceiptMap;
		}

		// 来店受付件数の増減
		return setPpointmentReceiptReserveCanNotCount(appointmentReceiptList,changeList,eventList,updateAppointmentReceiptMap,updateBeforeOrAfterFlg); 

	}

    /**
    * 店舗情報取得
    * 組織階層から期間関係なく取得
    * @param   なし
    * @return  Map<Id, OrganizationHierarchy__c> 組織階層から店舗の情報を取得
    */
	private Map<Id, OrganizationHierarchy__c> getOrganizationHierarchyMap(){
		Map<Id, OrganizationHierarchy__c> organizationHierarchyMap = new Map<Id, OrganizationHierarchy__c>([
			SELECT id
			,     Shop__c
			FROM  OrganizationHierarchy__c
		]);
		if(organizationHierarchyMap.size() == 0){
			return null;
		}
		return organizationHierarchyMap;
	}

    /**
    * 行動の時間から来店受付の対象分を取得する。
    * @param   List<Event> eventList         行動リスト
    * @param   List<shopTransfer> changeList 店舗異動変更リスト
    * @return  List<AppointmentReceipt__c>   範囲内の来店受付
    */
	private List<AppointmentReceipt__c> getAppointmentReceiptList(List<Event> eventList ,List<shopTransfer> changeList){
		String wheresql = CommonConst.STRING_EMPTY;         // 条件文
		for(Event event : eventList){
			// 行動不可フラグfalseの場合
			if(!event.notDuplicated__c){
				// 次の行動へ
				continue;
			}
			
			// 現在日時より過去の行動は検索対象外にする
			if((this.getNow > event.StartDateTime || event.StartDateTime == null) && (this.getNow > event.EndDateTime || event.EndDateTime == null)){
				// 次の行動へ
				continue;
			}

			// 最小の開始日時が現在日時より下回ってるい場合
			Datetime searchStartDate = event.StartDateTime;
			if(this.getNow > searchStartDate ){
				// 検索開始日を現在日時でセットする。
				searchStartDate = this.getNow;
			}

			// 最大の終了日時が現在日時を下回っている場合
			Datetime searchEndDate = event.EndDateTime;
			if(this.getNow > searchEndDate){
				// 検索終了日を現在日時でセットする。
				searchEndDate = this.getNow;
			}

			for(shopTransfer change: changeList){
				// 店舗異動と行動で一致する場合条件式に加える
				if(event.OwnerId == change.ownerId &&
					(searchEndDate.date() >= change.startDate.date() &&
					searchStartDate.date() <= change.endDate.date()) ){
					if(String.isEmpty(wheresql)){
						wheresql = ' WHERE ';
					}else{
						wheresql += ' OR ';
					}
					wheresql += ' (Shop__c =\'' +change.shopId+ '\'  AND (ReceiptDate__c = ' + String.valueOf(searchStartDate.Date()) + ' AND ReceiptDate__c  = ' +  String.valueOf(searchEndDate.Date()) + ')) ';
				}
			}

		}

		// 条件式が取れない場合、実行しない
		if(String.isEmpty(wheresql)){
			return null;
		}

		String sql = '';
		sql += ' SELECT id ';
		sql += ' ,      Shop__c ';
		sql += ' ,      Shop__r.name ';
		sql += ' ,      ReceiptDate__c ';
		sql += ' ,      ReserveStartTime__c ';
		sql += ' ,      ReserveEndTime__c ';
		sql += ' ,      ReserveCanNotCount__c ';
		sql += ' FROM   AppointmentReceipt__c ';
		sql += wheresql;
		sql += ' ORDER BY Shop__c ';
		sql += ' ,        ReceiptDate__c ';
		sql += ' ,        ReserveStartTime__c ';

		List<AppointmentReceipt__c> appointmentReceiptList = Database.query(sql);
		if(appointmentReceiptList.isempty()){
			return null;
		}
		return appointmentReceiptList;
	} 

	/**
	* 来店受付予約不能数の増減
	* @param     List<AppointmentReceipt__c> appointmentReceiptList        増減元の来店受付リスト
	* @param     List<shopTransfer> changeList                             店舗異動変更リスト
	* @param     List<Event> eventList                                     対象行動リスト
	* @param     Map<Id,AppointmentReceipt__c> updateAppointmentReceiptMap 増減加減中の来店受付のマップ
	* @param     Boolean updateBeforeOrAfterFlg                            更新前後フラグ（False：更新前、True：更新後）
	* @return    Map<Id,AppointmentReceipt__c>                             増減後の来店受付のマップ
	*/
    private Map<Id,AppointmentReceipt__c> setPpointmentReceiptReserveCanNotCount( 
			List<AppointmentReceipt__c> appointmentReceiptList
			,List<shopTransfer> changeList
			,List<Event> eventList
			,Map<Id,AppointmentReceipt__c> updateAppointmentReceiptMap
			,Boolean updateBeforeOrAfterFlg){
		for(Event event : eventList){
			for(AppointmentReceipt__c appointmentReceipt : appointmentReceiptList){
				// 増減対象かチェック
				if(! checkReserveCanNotCountUp(event,appointmentReceipt,changeList)){
					// 対象でない場合次へ
					continue;
				}
				// Listの作成準備(更新対象項目の設定)
				Decimal changeReserveCanNotCount = PortalUtil.setReserveCanNotCount(appointmentReceipt.ReserveCanNotCount__c,updateBeforeOrAfterFlg);
				// system.debug('店舗異動トリガ店舗：'+ appointmentReceipt.Shop__r.name + '| 日：'+appointmentReceipt.ReceiptDate__c + '| 開始：'+ appointmentReceipt.ReserveStartTime__c + '|終了：' +appointmentReceipt.ReserveEndTime__c +  '|増減値：'+ changeReserveCanNotCount);
				if(changeReserveCanNotCount == 0){
					// 増減なければ更新しない
					continue;
				}
				if(updateAppointmentReceiptMap.containsKey(appointmentReceipt.Id)){
					// セットされていれば対象ユーザIDのMapに値を加える                    
					AppointmentReceipt__c targetAppointmentReceipt = updateAppointmentReceiptMap.get(appointmentReceipt.Id);
					targetAppointmentReceipt.ReserveCanNotCount__c += changeReserveCanNotCount;
					
					updateAppointmentReceiptMap.put(appointmentReceipt.Id,targetAppointmentReceipt);
				}else{
					// セットされていなければユーザIDをキーとしてMapをセットする。
					AppointmentReceipt__c targetAppointmentReceipt = new AppointmentReceipt__c(
						Id = appointmentReceipt.Id ,
						ReserveCanNotCount__c = appointmentReceipt.ReserveCanNotCount__c + changeReserveCanNotCount
					); 
					updateAppointmentReceiptMap.put(appointmentReceipt.Id, targetAppointmentReceipt);
				}
			}
		}
		return updateAppointmentReceiptMap;
	}

	/**
	* 予約不能数の増減対象かを判断する。
	* @param     Event event								対象行動リスト
	* @param     AppointmentReceipt__c appointmentReceipt	増減加減中の来店受付のマップ
	* @param     List<shopTransfer> changeList				店舗異動変更リスト
	* @return    Boolean 									増減対象フラグ（False：対象外、True：対象）
	*/
    private Boolean checkReserveCanNotCountUp(Event event, AppointmentReceipt__c appointmentReceipt,List<shopTransfer> changeList){
		Boolean countUpFlg = false;
		for (ShopTransfer shopTransfer :changeList) {
			if ((event.StartDateTime.date() >= shopTransfer.startDate.date() &&
				event.EndDateTime.date() <= shopTransfer.endDate.date()) && 
				event.ownerId == shopTransfer.ownerId && 
				appointmentReceipt.Shop__c == shopTransfer.shopId) {
				countUpFlg = true;
				break;
			}
		}
		if (!countUpFlg) {
			return false;		
		}
		// 増減対象かチェック
		if(! PortalUtil.checkReserveCanNotCountUp(event,appointmentReceipt)){
			// 対象でない場合次へ
			return false;
		}
		return true;
	}

    /**
     * 内部クラス
     */
	public class shopTransfer {
		private Id ownerId;			// ユーザID
		private Id shopId;			// 店舗ID
		private Datetime startDate;	// 開始日
		private Datetime endDate;	// 終了日
		
		public shopTransfer() {
			this.ownerId   = null;
			this.shopId    = null;
			this.startDate = null;
			this.endDate   = null;
		}

		public shopTransfer(ID staffId,ID shopId,Datetime startDate,Datetime endDate) {
			this.ownerId   = staffId;
			this.shopId    = shopId;
			this.startDate = startDate;
			this.endDate   = endDate;
		}
	}
}