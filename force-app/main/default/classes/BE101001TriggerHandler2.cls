//対応トリガー
public with sharing class BE101001TriggerHandler2 {
/** トリガから実行 */
    private boolean m_isExecuting = false;
    /** 新旧両方のトリガコール内のレコードの数 */
    private integer BatchSize = 0;

    /** コンストラクタ */
    public BE101001TriggerHandler2(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    


    /** 登録前処理 */
    public void onBeforeInsert(Correspond__c[] newObjs){
        // イベントのステータスを設定
        setEventStatus(newObjs);
    }
    
    /** 登録後処理 */
    public void onAfterInsert(Correspond__c[] newObjs, Map<ID, Correspond__c> newObjMap){
        // 反響累計登録処理（共通クラス）
        DailyReportUtil.upsertEchoTotal_Correspond(newObjs);
        //対応差分作成
        insertCorrespondDifference(newObjs, 'C');
        
        //紹介メール情報、取引先の変更
        introMailAccounChange(newObjs,new Map<ID, Correspond__c>());//追加要望 追加
    }
    
    /** 更新前処理 */
    public void onBeforeUpdate(Correspond__c[] oldObjs, Map<ID, Correspond__c> oldObjMap, Correspond__c[] newObjs, Map<ID, Correspond__c> newObjMap){
        // イベントのステータスを設定
        setEventStatus(newObjs);
        //ステータス「追客保留中」ではなくなったとき、対応.条件完全一致を「しない」に自動で変更
        setExactConditionMatchFalse(newObjs);
    }

    /** 更新後処理 */
    public void onAfterUpdate(Correspond__c[] oldObjs, Map<ID, Correspond__c> oldObjMap, Correspond__c[] newObjs, Map<ID, Correspond__c> newObjMap){

        // 反響累計登録処理（共通クラス）
        DailyReportUtil.upsertEchoTotal_Correspond(newObjs);
        //対応差分作成
        insertCorrespondDifference(newObjs, 'U');

        //紹介メール情報、取引先の変更
        introMailAccounChange(newObjs,oldObjMap);//追加要望 追加

        // 空室予約物件の削除
        this.delVacancyReservationProp(newObjs, oldObjMap);
    }
    
    /** 削除前処理 */
    public void onBeforeDelete(Correspond__c[] oldObjs, Map<ID, Correspond__c> oldObjMap){

        //対応差分作成
        insertCorrespondDifference(oldObjs, 'D');
    }
    
    /** 削除後処理 */
    public void onAfterDelete(Correspond__c[] oldObjs, Map<ID, Correspond__c> oldObjMap){
    }
    
    /** 復元後処理 */
    public void onUndelete(Correspond__c[] newObjs){
    }

    //----------------------------privateメソッド--------------------------------------------------------------------------------
    //★対応差分作成----------------------------------------------------------------------------------------
    //対応差分作成    
    private void insertCorrespondDifference(Correspond__c[] objs,String crudCd){
        //対応差分リストの作成
        List<CorrespondDifference__c> corrDiffList = new List<CorrespondDifference__c>();
        
        for (Correspond__c corr : objs){
            //対応を元に対応差分作成
            CorrespondDifference__c corrDiff = createCorrDiff(corr, crudCd);

            if(corrDiff != null){
                //空じゃなければリストに作成
                corrDiffList.add(corrDiff);             
            }
        }
        //対応差分をinsert
        if(!corrDiffList.isEmpty()){
            //リストが空でなければisnert
            SecureDML.secureInsert(corrDiffList);
        }

    }

    //対応を元に対応差分作成
    private CorrespondDifference__c createCorrDiff(Correspond__c corr, String crudCd){
        CorrespondDifference__c corrDiff;

        //対応の取引先のレコードタイプが顧客の時のみ作成
        if (corr.AccountRecordType__c == CommonConst.ACCOUNT_RECTYPE_CUSTOMER){
            corrDiff = new CorrespondDifference__c();
			corrDiff.CorrespondId__c       = corr.Id;                    //対応Id
			corrDiff.AccountId__c          = corr.AccountId__c;          //取引先 
			corrDiff.Status__c             = corr.Status__c;             //ステータス
			corrDiff.CrudCd__c             = crudCd;                     //クラッドコード
			// ▼ 2022.03.03 未連携項目追加 No0748_LINE通知が上手く機能していない
			corrDiff.AccountRecordType__c=corr.AccountRecordType__c; //取引先レコードタイプ
			corrDiff.Application__c=corr.Application__c; //申込
			corrDiff.AppointmentStartDate__c=corr.AppointmentStartDate__c; //アポイント開始日0時
			corrDiff.BrowseDate__c=corr.BrowseDate__c; //閲覧日時
			corrDiff.District__c=corr.District__c; //地区
			corrDiff.EchoShopName__c=corr.EchoShopName__c; //反響担当店舗名
			corrDiff.EchoShop__c=corr.EchoShop__c; //反響担当店舗
			corrDiff.EchoStaffName__c=corr.EchoStaffName__c; //反響担当者名
			corrDiff.EchoStaff__c=corr.EchoStaff__c; //担当者（反響）
			corrDiff.EventDateTime__c=corr.EventDateTime__c; //イベント時刻
			corrDiff.Event__c=corr.Event__c; //イベント
			corrDiff.FirstInquiryMeans__c=corr.FirstInquiryMeans__c; //初回問合せ方法
			corrDiff.FirstInquiryProperty__c=corr.FirstInquiryProperty__c; //初回問合せ物件
			corrDiff.FirstVisitReservationCancelFlg__c=corr.FirstVisitReservationCancelFlg__c; //初回来店予約キャンセルフラグ
			corrDiff.FirstVisitReservationDate__c=corr.FirstVisitReservationDate__c; //初回来店予約日
			corrDiff.IsBrowseFlg__c=corr.IsBrowseFlg__c; //閲覧フラグ
			corrDiff.IsEchoNotCalculation__c=corr.IsEchoNotCalculation__c; //反響数非計算フラグ
			corrDiff.IsSupportedListShow__c=corr.IsSupportedListShow__c; //対応確認
			corrDiff.IsVisitNotCalculation__c=corr.IsVisitNotCalculation__c; //来店数非計算フラグ
			corrDiff.ListViewDate__c=corr.ListViewDate__c; //一覧表示日時
			corrDiff.Memo__c=corr.Memo__c; //メモ
			corrDiff.PhoneAbsenceDate__c=corr.PhoneAbsenceDate__c; //電話不在日時
			corrDiff.PhoneIncomingDate__c=corr.PhoneIncomingDate__c; //電話着信日時
			corrDiff.PhoneOutgoingDate__c=corr.PhoneOutgoingDate__c; //電話発信日時
			corrDiff.PortalSiteUrl__c=corr.PortalSiteUrl__c; //ポータルサイトURL
			corrDiff.PortalSite__c=corr.PortalSite__c; //ポータルサイト
			corrDiff.Property__c=corr.Property__c; //物件
			corrDiff.PursuitDissolveDate__c=corr.PursuitDissolveDate__c; //追客解除設定日時（保存用）
			corrDiff.PursuitDissolveSettingDate__c=corr.PursuitDissolveSettingDate__c; //追客解除設定日時
			corrDiff.ReceiveMailDateOther__c=corr.ReceiveMailDateOther__c; //メール受信日時（その他）
			corrDiff.ReceiveMailDatePortal__c=corr.ReceiveMailDatePortal__c; //メール受信日時（ポータル）
			corrDiff.SendMailDate__c=corr.SendMailDate__c; //メール送信日時
			corrDiff.ShopStaffName__c=corr.ShopStaffName__c; //来店担当者名
			corrDiff.ShopStaff__c=corr.ShopStaff__c; //担当者（来店）
			corrDiff.StaffSupportedFlg__c=corr.StaffSupportedFlg__c; //スタッフ対応フラグ
			corrDiff.StatusBeforePursuitHold__c=corr.StatusBeforePursuitHold__c; //追客保留前ステータス
			corrDiff.VisitDate__c=corr.VisitDate__c; //来店日（初回）
			corrDiff.VisitReason__c=corr.VisitReason__c; //来店理由（スタッフ欄）
			corrDiff.VisitReservationCancelDate__c=corr.VisitReservationCancelDate__c; //来店予約キャンセル日
			corrDiff.VisitReservationFlag__c=corr.VisitReservationFlag__c; //来店予約フラグ
			corrDiff.VisitShopName__c=corr.VisitShopName__c; //来店担当店舗名
			corrDiff.VisitShop__c=corr.VisitShop__c; //来店担当店舗
			// ▲ 2022.03.03 未連携項目追加 No0748_LINE通知が上手く機能していない
        }
        return corrDiff;
    }

	// ▼ 2021.11.24 LINE連携対応より、イベントの追加とソースの修正（※ステップ数とロジックの修正は時間がない為、保留）
	/**
	 * イベントステータスの設定
	 * @param Correspond__c[] newObjs 対応更新値
	 */
	private void setEventStatus(Correspond__c[] newObjs) {

		// ステータス情報（key:表示順位, value:対応日付項目）
		Map<EventStatus, CorrespondDateItem> statusMap;

		// 最新日付のステータスリスト
		List<EventStatus> latestStatus = new List<EventStatus>();

		// 並び替え対象の要素番号
		Integer swapTargetIdx = 0;
		Integer swapComparisonIdx = 0;

		// オブジェクト
		CorrespondDateItem sortTarget;     // 入れ替え対象
		CorrespondDateItem sortComparison; // 比較対象

		// ステータス（結果）
		EventStatus reaultStatus;

		// イベント設定処理
		for (Correspond__c correspond : newObjs) {

			latestStatus.clear();
			latestStatus.addAll(EventStatus.values());

			// デフォルト値を設定
			correspond.AutomaticReplyAfterPursuitFlg__c = false;

			// ステータス情報
			statusMap = new Map<EventStatus, CorrespondDateItem> {
				EventStatus.LINE_RECEIVE_DATE				=> new CorrespondDateItem(CommonConst.CORRESPOND_EVENT_LINE_RECEIVE						, correspond.lineReceiveDate__c) 
				, EventStatus.LINE_FRIEND_ADD_DATE			=> new CorrespondDateItem(CommonConst.CORRESPOND_EVENT_LINE_FRIEND_ADD					, correspond.LineFriendAddDate__c)
				, EventStatus.PORTAL_MAIL_RECIVE			=> new CorrespondDateItem(CommonConst.CORRESPOND_EVENT_EMAIL							, correspond.ReceiveMailDatePortal__c)
				, EventStatus.OTHER_MAIL_RECIVE				=> new CorrespondDateItem(CommonConst.CORRESPOND_EVENT_EMAIL							, correspond.ReceiveMailDateOther__c) 
				, EventStatus.VISIT_RESERVATION				=> new CorrespondDateItem(CommonConst.CORRESPOND_EVENT_VISIT_RESERVATION				, correspond.ReceiveMailDateVisitReservation__c)
				, EventStatus.PROPERTY_INTRODUCTON_POSSIBLE	=> new CorrespondDateItem(CommonConst.CORRESPOND_EVENT_PROPERTY_INTRODUCTION_POSSIBLE	, correspond.PropertyIntroductionPossibleTime__c)
				, EventStatus.BROWSE_DATE					=> new CorrespondDateItem(CommonConst.CORRESPOND_EVENT_PURSUIT_VIEWED					, correspond.BrowseDate__c)
				, EventStatus.AUTO_RECIVE					=> new CorrespondDateItem(CommonConst.CORRESPOND_EVENT_AUTO_RECIVE						, correspond.ThanksMailSettingSendDate__c)
				, EventStatus.NO_REACTION					=> new CorrespondDateItem(CommonConst.CORRESPOND_EVENT_NORESPONSE_MAIL					, correspond.SendMailDate__c)
				, EventStatus.SEND_LINE_SMS					=> new CorrespondDateItem(CommonConst.CORRESPOND_EVENT_NORESPONSE_LINE_SMS				, correspond.LineSmsSendDate__c)
				, EventStatus.NOT_CALLED					=> new CorrespondDateItem(CommonConst.CORRESPOND_EVENT_NOCONTACT						, correspond.PhoneAbsenceDate__c)
				, EventStatus.INCOMING_REACTION				=> new CorrespondDateItem(CommonConst.CORRESPOND_EVENT_PURSUIT_RESPONSE					, correspond.PhoneIncomingDate__c)
				, EventStatus.OUTGOING_REACTION				=> new CorrespondDateItem(CommonConst.CORRESPOND_EVENT_PURSUIT_RESPONSE					, correspond.PhoneOutgoingDate__c)
				, EventStatus.REMIND						=> new CorrespondDateItem(CommonConst.CORRESPOND_EVENT_PURSUIT_REMIND					, correspond.PursuitDissolveSettingDate__c)
				, EventStatus.NONE							=> new CorrespondDateItem(CommonConst.CORRESPOND_EVENT_NOTHING							, correspond.EndDate__c)
			};

			// 日付（降順）を取得
			for (EventStatus targetStatusKey : EventStatus.values()) {

				// ステータス情報存在チェック
				if (!statusMap.containsKey(targetStatusKey)) {
					continue;
				}
				sortTarget = statusMap.get(targetStatusKey);

				// 並び替え処理
				for (EventStatus comparisonStatusKey : EventStatus.values()) {

					// 実施チェック
					if (targetStatusKey.ordinal() >= comparisonStatusKey.ordinal()) {
						continue;
					}

					// ステータス情報存在チェック
					if (!statusMap.containsKey(comparisonStatusKey)) {
						continue;
					}
					sortComparison = statusMap.get(comparisonStatusKey);

					// 並び替え不要項目チェック
					if (sortComparison.dateVal == null) {
						continue;
					}

					// ステータス更新チェック
					if (sortTarget.dateVal == null || sortTarget.dateVal < sortComparison.dateVal) {

						// 並び替え対象の取得
						swapTargetIdx = latestStatus.indexOf(targetStatusKey);
						swapComparisonIdx = latestStatus.indexOf(comparisonStatusKey);
							
						// 並び替え
						if (swapTargetIdx < swapComparisonIdx) {
							latestStatus.remove(swapComparisonIdx);
							latestStatus.add(swapTargetIdx, comparisonStatusKey);
						}
					}
				}
			}

			// イベントの更新
			correspond.EventStatus__c = CommonConst.CORRESPOND_EVENT_NOTHING;
			reaultStatus = EventStatus.NONE;
			if (statusMap.get(latestStatus[0]).dateVal != null) {

				// 最新日付のステータスを設定
				correspond.EventStatus__c = statusMap.get(latestStatus[0]).dispStatus;
				reaultStatus = latestStatus[0];

				// ステータス = "追客（閲覧あり）" の次点最新日付がメール受信の場合は次点を優先表示
				if (latestStatus[0] == EventStatus.BROWSE_DATE
					&& (latestStatus[1] == EventStatus.PORTAL_MAIL_RECIVE || latestStatus[1] == EventStatus.OTHER_MAIL_RECIVE)
					&& statusMap.get(latestStatus[1]).dateVal != null) {
					correspond.EventStatus__c = statusMap.get(latestStatus[1]).dispStatus;
					reaultStatus = latestStatus[1];
				}
					
				// 最新日付が対応．閲覧日時、次点最新日付が対応．メール受信日時（来店予約）の場合、"来店予約"を表示
				if (latestStatus[0] == EventStatus.BROWSE_DATE
					&& (latestStatus[1] == EventStatus.VISIT_RESERVATION)
					&& statusMap.get(latestStatus[1]).dateVal != null) {
					correspond.EventStatus__c = statusMap.get(latestStatus[1]).dispStatus;
					reaultStatus = latestStatus[1];
				}

				// 最新日付が対応．物件紹介可能時刻、次点最新日付が対応．メール受信日時の場合、"メール受信"を表示
				if (latestStatus[0] == EventStatus.PROPERTY_INTRODUCTON_POSSIBLE
					&& (latestStatus[1] == EventStatus.PORTAL_MAIL_RECIVE || latestStatus[1] == EventStatus.OTHER_MAIL_RECIVE)
					&& statusMap.get(latestStatus[1]).dateVal != null) {
					correspond.EventStatus__c = statusMap.get(latestStatus[1]).dispStatus;
					reaultStatus = latestStatus[1];
				}

				// 最新日付が対応．閲覧日時、次点最新日付が対応．物件紹介可能時刻の場合、"物件紹介可能"を表示
				if (latestStatus[0] == EventStatus.BROWSE_DATE
					&& (latestStatus[1] == EventStatus.PROPERTY_INTRODUCTON_POSSIBLE)
					&& statusMap.get(latestStatus[1]).dateVal != null) {
					correspond.EventStatus__c = statusMap.get(latestStatus[1]).dispStatus;
					reaultStatus = latestStatus[1];
				}

				// ステータス = "追客（閲覧あり）" の次点最新日付が自動返信の場合は自動返信後追客フラグを設定
				if (latestStatus[0] == EventStatus.BROWSE_DATE
					&& latestStatus[1] == EventStatus.AUTO_RECIVE
					&& statusMap.get(latestStatus[1]).dateVal != null) {
					correspond.AutomaticReplyAfterPursuitFlg__c = true;
				}

				//▼ 2022.04.12 No0766 対応で追加
				// 閲覧日時が最新、次点がLINE受信日時
				// 物件紹介可能が最新、次点がLINE受信日時
				// LINE受信
				if ((latestStatus[0] == EventStatus.BROWSE_DATE || latestStatus[0] == EventStatus.PROPERTY_INTRODUCTON_POSSIBLE)
					&& (latestStatus[1] == EventStatus.LINE_RECEIVE_DATE)
					&& statusMap.get(latestStatus[1]).dateVal != null) {
					correspond.EventStatus__c = statusMap.get(latestStatus[1]).dispStatus;
					reaultStatus = latestStatus[1];
				}

				// 閲覧日時が最新、次点がLINEお友達登録日時
				// 物件紹介可能が最新、次点がLINEお友達登録日時
				// LINE追加
				if ((latestStatus[0] == EventStatus.BROWSE_DATE || latestStatus[0] == EventStatus.PROPERTY_INTRODUCTON_POSSIBLE)
					&& (latestStatus[1] == EventStatus.LINE_FRIEND_ADD_DATE)
					&& statusMap.get(latestStatus[1]).dateVal != null) {
					correspond.EventStatus__c = statusMap.get(latestStatus[1]).dispStatus;
					reaultStatus = latestStatus[1];
				}
				//▲ 2022.04.12 No0766 対応で追加
			}

			// 下位イベントチェック
			if (!correspond.StaffSupportedFlg__c && reaultStatus.ordinal() > EventStatus.OTHER_STAFF.ordinal()) {
				correspond.EventStatus__c = CommonConst.CORRESPOND_EVENT_OTHERSTAFFSUPPORTED;
			}
		}
	}
	// ▲ 2021.11.24

	// ▼ 2021.11.24 LINE連携対応より、イベントの追加とソースの修正
	/**
	 * イベント_ステータス
	 */
	public enum EventStatus {
		/** LINE追加 */
		LINE_FRIEND_ADD_DATE
		/** LINE受信 */
		, LINE_RECEIVE_DATE
		/** メール受信（ポータル） */
		, PORTAL_MAIL_RECIVE
		/** メール受信（その他） */
		, OTHER_MAIL_RECIVE
		/** 来店予約 */
		, VISIT_RESERVATION
		/** 物件紹介可能 */
		, PROPERTY_INTRODUCTON_POSSIBLE
		/** 追客(閲覧あり) */
		, BROWSE_DATE
		/** 自動返信 */
		, AUTO_RECIVE
		/** 他スタッフ対応 */
		, OTHER_STAFF
		/** 反応なし（メール送信） */
		, NO_REACTION
		/** 反応なし（LINE・SMS送信） */
		, SEND_LINE_SMS
		/** 電話つながらない */
		, NOT_CALLED
		/** 追客(反応あり)（電話着信） */
		, INCOMING_REACTION
		/** 追客(反応あり)（電話発信） */
		, OUTGOING_REACTION
		/** 追客(リマインド) */
		, REMIND
		/** なし */
		, NONE
		/** 入力無し */
		, NOINPUT
	}
	// ▲ 2021.11.24
    
        // 対応日付項目
    public class CorrespondDateItem {
        /** 日付値 */
        DateTime dateVal {set; get;}
        /** 表示ステータス */
        String dispStatus {set; get;}

        // コンストラクタ
        public CorrespondDateItem(String dispStatus, DateTime dateVal) {
            this.dispStatus = dispStatus;
            this.dateVal = dateVal;
       }
    }

    //ステータス「追客保留中」ではなくなったとき、対応.条件完全一致を「しない」に自動で変更
    private void setExactConditionMatchFalse(Correspond__c[] newObjs){
        for(Correspond__c corr : newObjs){
            if(corr.Status__c != CommonConst.CORRESPOND_STATUS_PURSUITHOLD){
                corr.ExactConditionMatch__c = 'しない';
            }
        }
    }

    //追加要望 追加 Start
    //★紹介メール情報・取引先の変更----------------------------------------------------------------------------------------
    private void introMailAccounChange(Correspond__c[] newObjs, Map<ID, Correspond__c> oldObjMap){
        Savepoint sp = Database.setSavepoint();      //セーブポイント作成
        try{
            List<Account> updateAccountList = new List<Account>();//更新取引先リスト
            List<IntroductionMailInformation__c> updateIntroMailList = new List<IntroductionMailInformation__c>();//更新用紹介メール情報リスト
            List<IntroductionMailInformation__c> deleteIntroMailList = new List<IntroductionMailInformation__c>();//削除用紹介メール情報リスト

            //権限取得
            Boolean isOpetionPorta = AuthorityCheckUtil.getAuthorityOptionPortal(false);
            if (!isOpetionPorta){
                return;
            }
            
            set<id> accIdSet = new set<id>(); 
            set<id> corrIdSet = new set<id>(); 
            for (Correspond__c corr : newObjs){
                accIdSet.add(corr.AccountId__c);
                corrIdSet.add(corr.id);
            }
            //取引先取得(取引先id,取引先)
            Map<id, Account> accountMap = getAccountMap(accIdSet);//変更された対応に紐づく取引先マップ
            //関連する紹介メール情報取得(対応id,紹介メール情報)
            Map<id, IntroductionMailInformation__c> introMailCorrMap = getIntroMailCorrMap(corrIdSet);//変更された対応に紐づく紹介メール情報マップ

            //▼問合せNo0429で追加
            // 取引先のレコードタイプ取得を外だし（ガバナ制限に引っかかるため）
            Id accountRecordTypeId = CommonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER);
            //▲問合せNo0429で追加
    
            //引数の対応をループ
            for(Correspond__c corr : newObjs){
                
                //取引先のIdがない　または　レコードタイプが顧客以外　または紹介メール情報と紐づかない場合は 処理を行わない
                if (   String.isBlank(corr.AccountId__c) 
                    || !(accountMap.get(corr.AccountId__c).RecordTypeId == accountRecordTypeId) //問合せNo0429で変更
                    || !introMailCorrMap.containsKey(corr.id)){
                    continue;
                }
                //紹介メール情報配信状況が「配信」
                if (accountMap.get(corr.AccountId__c).IntroMailInfoStatus__c == CommonConst_ptl.INTRODUCTION_SEND){

                    //（ステータスが「追客系」から変更された場合）　または　
                    //（「追客系」かつ メール送信日時 < メール受信日時（その他）の場合）　または													
                    //（「追客系」かつ 取引先．紹介メール手動配信変更日時< メール受信日時（その他））の場合													
                    if ((!isPursuit(corr.Status__c) && (isPursuit(oldObjMap.get(corr.id).Status__c) ))||
                        ( isPursuit(corr.Status__c) && (corr.SendMailDate__c < corr.ReceiveMailDateOther__c)) ||
                        ( isPursuit(corr.Status__c) && (accountMap.get(corr.AccountId__c).IntroMailIManualDeliveryChangeDatetime__c < corr.ReceiveMailDateOther__c))){
                
                        //●紹介メールを削除する
                        deleteIntroMailList.add(introMailCorrMap.get(corr.id));      //対応に関連する紹介メール情報を削除リストに追加
                        //●取引先を変更する
                        updateAccountList.add(new Account(id = corr.AccountId__c,
                                                        IntroMailInfoStatus__c = CommonConst_ptl.INTRODUCTION_SENDSTOP));//配信停止

                    //ステータスが「追客系」　かつ　!(メール送信日時 < メール受信日時 )
                    }else if (isPursuit(corr.Status__c) && !(corr.SendMailDate__c < corr.ReceiveMailDateOther__c)){
                    
                        //●紹介メール情報を更新する
                        updateIntroMailList.add(new IntroductionMailInformation__c(
                                                    id = introMailCorrMap.get(corr.id).id,
                                                    SendMailDate__c = corr.SendMailDate__c,
                                                    ReceiveMailDateOther__c =  corr.ReceiveMailDateOther__c,
                                                    Email__c = accountMap.get(corr.AccountId__c).Email__c));
        
                    }
                }
            }
            
            //紹介メール情報更新
            if (! updateIntroMailList.isEmpty()){
                SecureDML.secureUpdate(updateIntroMailList);
            }

            //紹介メール情報削除
            if (! deleteIntroMailList.isEmpty()){
            	SecureDML.secureDelete(deleteIntroMailList);
            }
          
            //取引先更新
            if (! updateAccountList.isEmpty()){
            	SecureDML.secureUpdate(updateAccountList);
            }
            

        }catch(Exception e){
            Database.rollback(sp);//処理をロールバック
        }
    }
    //パラメータが追客系か判断
    private Boolean isPursuit(String status){
        if (status == CommonConst.CORRESPOND_STATUS_PURSUIT ||
            status == CommonConst.CORRESPOND_STATUS_APPLCANCEL_PURSUIT ||
            status == CommonConst.CORRESPOND_STATUS_VISITED_PURSUIT ||
            status == CommonConst.CORRESPOND_STATUS_APOCANCEL_PURSUIT 
            ){
            
            return true;
        }else{
            return false;
        }
    }

    //取引先取得
    private Map<id, Account> getAccountMap(set<id> accIdSet){
        List<Account> accList = [SELECT id,
                                IntroMailInfoStatus__c,//配信状況
                                IntroMailIManualDeliveryChangeDatetime__c,//手動変更日時
                                Email__c,//メール
                                RecordTypeId
                            FROM Account WHERE id IN :accIdSet];
        
        Map<id, Account> accMap = new Map<id, Account>();
        for (Account acc : accList){
            accMap.put(acc.id, acc);
        }
        return accMap;
    }

    //紹介メール情報取得
    private Map<id, IntroductionMailInformation__c> getintroMailCorrMap(set<id> corrIdSet){
        List<IntroductionMailInformation__c> introList = [SELECT id,Account__c,Correspond__c
                                                        FROM IntroductionMailInformation__c 
                                                        WHERE Correspond__c IN :corrIdSet];
        
        Map<id, IntroductionMailInformation__c> introMailCorrMap = new Map<id, IntroductionMailInformation__c>();
        for (IntroductionMailInformation__c intro : introList){
            introMailCorrMap.put(intro.Correspond__c, intro);
        }
        return introMailCorrMap;
    }


    //追加要望 追加 End
    
    /**
     * 空室予約物件を削除
     * @param  Correspond__c[]        newObjs   対応更新後
     * @param  Map<ID, Correspond__c> oldObjMap 対応更新前
    */
    private void delVacancyReservationProp(Correspond__c[] newObjs, Map<ID, Correspond__c> oldObjMap) {

        Correspond__c oldObj;
        Set<Id> accountIdSet = new Set<Id>();
        
        // 削除対象の取引先を取得   
        for (Correspond__c newObj : newObjs) {
            oldObj = oldObjMap.get(newObj.Id);
            
            // ステータス変更チェック
            if (oldObj.Status__c == newObj.Status__c) {
                continue;
            }
            
            // ステータス変更値チェック
            if (newObj.Status__c != CommonConst.CORRESPOND_STATUS_CLOSE
                && newObj.Status__c != CommonConst.CORRESPOND_STATUS_UNEARNED) {
                continue;        
            }
            
            accountIdSet.add(newObj.AccountId__c);
        }
        
        // 空室予約物件を削除
        List<VacancyReservationProperty__c> delVacancyReservationPropList = [SELECT Id
                                                                             FROM VacancyReservationProperty__c
                                                                             WHERE Account__c IN :accountIdSet];
        
        if (!delVacancyReservationPropList.isEmpty()) {
            SecureDML.secureDelete(delVacancyReservationPropList);
        }
    }
}