public class CustomerUtil {
    public CustomerUtil() {

    }
    public static final Id customerId = CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_CUSTOMER);
	
	// 検索条件で使用するステータスの設定 ▼ 2022.04.20 No0768 対応で追加
	public static final	Set<String> notApplicableStatus = new Set<String>{
		CommonConst.CORRESPOND_STATUS_CLOSE,			// 終了
		CommonConst.CORRESPOND_STATUS_AGREEMENT,		// 契約完了
		CommonConst.CORRESPOND_STATUS_ECHOAGGREGATION	// 反響集約
	};
	// ▲ 2022.04.20 No0768 対応で追加

	// ▼ 2022.1.27 LINE連携対応より、追加
	/**
	 * 対応の特定ステータス返却
	 * @param Id correspondId 対応ID
	 * @return String 変更したステータス
	 */
	public static String changeSpecificStatus(Id correspondId) {

		// 対応の取得
		Correspond__c correspond = getCorrespond(correspondId);

		// ステータス変更値の取得
		String chgStatus = changeSpecificStatus(
			correspond.Status__c
			, correspond.StatusBeforePursuitHold__c
			, correspond.AccountId__r.RecordTypeId
		);

		return chgStatus;
	}
	// ▲ 2022.1.27

	/*
    * 対応の特定ステータス返却
    * 
    * @param  String status                  ステータスの値
    * @param  String statusBeforePursuitHold 対象の追客保留前ステータスの値
	* @param  Id accountRecordType           取引先のレコードタイプ
    * @return returnStatus                   変更したステータス
    */
    public static String changeSpecificStatus(String status, String statusBeforePursuitHold,Id accountRecordType){
        String returnStatus = status;
		// ▼ 2022.1.29 LINE連携対応より、LINEと取引先が未紐づけの場合も処理を継続するよう修正
		//取引先のレコードタイプが顧客じゃない場合
		if (accountRecordType != customerId && String.isNotBlank(accountRecordType)){
			return returnStatus;//元のパラメータをそのまま返す
		}
		// ▲ 2022.1.29

        //特定のステータスの場合、ステータスを変更する
        if      (status == CommonConst.CORRESPOND_STATUS_NOTSUPPORTED) {    // 「未対応」⇒「追客中」
            returnStatus = CommonConst.CORRESPOND_STATUS_PURSUIT;
        }   
        else if (status == CommonConst.CORRESPOND_STATUS_APOCANCEL) {       // 「アポイントキャンセル」⇒「アポキャンセル後追客中」
            returnStatus = CommonConst.CORRESPOND_STATUS_APOCANCEL_PURSUIT;
        }
        else if (status == CommonConst.CORRESPOND_STATUS_APPLCANCEL) {      // 「申込キャンセル」⇒「申込キャンセル後追客中」
            returnStatus = CommonConst.CORRESPOND_STATUS_APPLCANCEL_PURSUIT;
        }
        else if (status == CommonConst.CORRESPOND_STATUS_CONSIDERVISITING) {// 「来店後検討」⇒「来店後追客中」
            returnStatus = CommonConst.CORRESPOND_STATUS_VISITED_PURSUIT;
        } 
        else if (status == CommonConst.CORRESPOND_STATUS_CLOSE) {// 2020/6/19追加：「終了」⇒「追客中」
            returnStatus = CommonConst.CORRESPOND_STATUS_PURSUIT;
        }
        else if (status == CommonConst.CORRESPOND_STATUS_PURSUITHOLD) {     // 「追客保留中」⇒　追客保留前ステータスの値によって変更
            returnStatus = changeStatusToStatusBeforePursuitHold(statusBeforePursuitHold);
        }
        return returnStatus;
    }

    /**
     * 追客保留中に担当者から電話・メール等をした際、ステータスを追客保留前ステータスの値によって変更する
     * 
     * @param  String statusBeforePursuitHold 対象の追客保留前ステータスの値
     * @return returnStatus                   変更したステータス
     */
    public static String changeStatusToStatusBeforePursuitHold(String statusBeforePursuitHold){
        String returnStatus = '';
        //保留前ステータスが追客中
        if (statusBeforePursuitHold == CommonConst.CORRESPOND_STATUS_PURSUIT){
            //ステータスを 追客中に
            returnStatus = CommonConst.CORRESPOND_STATUS_PURSUIT;
            
        //保留前ステータスが アポイントキャンセル or アポイントキャンセル後追客中
        }else if (statusBeforePursuitHold == CommonConst.CORRESPOND_STATUS_APOCANCEL
                ||statusBeforePursuitHold == CommonConst.CORRESPOND_STATUS_APOCANCEL_PURSUIT){
            //ステータスを アポイントキャンセル後追客中に
            returnStatus = CommonConst.CORRESPOND_STATUS_APOCANCEL_PURSUIT;
            
        //保留前ステータスが 来店後検討 or 来店後追客中
        }else if (statusBeforePursuitHold == CommonConst.CORRESPOND_STATUS_CONSIDERVISITING
                ||statusBeforePursuitHold == CommonConst.CORRESPOND_STATUS_VISITED_PURSUIT){
            //ステータスを 来店後追客中に
            returnStatus = CommonConst.CORRESPOND_STATUS_VISITED_PURSUIT;
        
        //保留前ステータスが 申込キャンセル or 申込キャンセル後追客中
        }else if (statusBeforePursuitHold == CommonConst.CORRESPOND_STATUS_APPLCANCEL
                ||statusBeforePursuitHold == CommonConst.CORRESPOND_STATUS_APPLCANCEL_PURSUIT){
            //ステータスを 申込キャンセル後追客中に
            returnStatus = CommonConst.CORRESPOND_STATUS_APPLCANCEL_PURSUIT;
        }
        return returnStatus;
    }

	// ▼ 2022.1.27 LINE連携対応より、追加
	/**
	 * ステータスに応じた一覧表示日時の設定
	 * @param  String	targetStatus	対象ステータス
	 * @param  Id		correspondId	対応ID
	 * @return Datetime 一覧表示日時
	 */
	public static Datetime setListViewDateWhenCorrespondCheck(String targetStatus, Id correspondId){

		// 対応の取得
		Correspond__c correspond = getCorrespond(correspondId);

		// 一覧表示日時の取得
		return setListViewDateWhenCorrespondCheck(targetStatus, correspond);
	}
	// ▲ 2022.1.27

    /**
     * ステータスごとに一覧表示日時を返却する（対応確認時の動き）
     * 対応レコードが引数で渡されたとき用
     * 
     * @param  String        status   ステータス
     * @param  Correspond__c corr  対応（★取引先レコード（必須）、★アポイント開始日0時の項目（必須）、追客解除設定日時（保存用）を使用）
     * @return Datetime 日付時間（一覧表示日時）
     */
    public static Datetime setListViewDateWhenCorrespondCheck(String status, Correspond__c corr){
        Id accountRecordType = corr.AccountId__r.RecordTypeId;
        Datetime AppointStart = corr.AppointmentStartDate__c;
        Datetime pursuitDissolveDate = corr.PursuitDissolveDate__c;
        return setListViewDateWhenCorrespondCheck(status, accountRecordType, AppointStart, pursuitDissolveDate);
    }

    /**
    * ステータスごとに一覧表示日時を返却する（対応確認時の動き） (オーバーロード)
    * 対応の変更項目が複雑で項目単位でしか引数が用意できいないとき用
    * 
    * @param String   status            　 ステータス
    * @param Id       accountRecordType    取引先レコードタイプId
    * @param Datetime AppointStart         アポイント開始日0時
    * @param Datetime pursuitDissolveDate  追客解除設定日時（保存用）
    * @return Datetime 日付時間（一覧表示日時）
    */
    public static Datetime setListViewDateWhenCorrespondCheck(String status, Id accountRecordType, Datetime AppointStart, Datetime pursuitDissolveDate){
		// ▼ 2022.1.29 LINE連携対応より、LINEと取引先が未紐づけの場合も処理を継続するよう修正
		//★取引先のレコードタイプが顧客じゃない
		if (accountRecordType != customerId && String.isNotBlank(accountRecordType)){
			// 返：最終日(2999/12/31)
			return CommonConst.LAST_DATE;           	
		}
		// ▲ 2022.1.29

        //★ステータスが追客系（追客中、アポキャンセル後追客保留中、申込キャンセル後追客中、来店後追客中）
        if (   status == CommonConst.CORRESPOND_STATUS_PURSUIT
            || status == CommonConst.CORRESPOND_STATUS_APOCANCEL_PURSUIT 
            || status == CommonConst.CORRESPOND_STATUS_VISITED_PURSUIT
            || status == CommonConst.CORRESPOND_STATUS_APPLCANCEL_PURSUIT
            ){
            // 返：現在日時の翌日0時
            Date tomorrow = CommonUtil.getToday().addDays(1); 
            Time zeroTime = Time.newInstance(0, 0, 0, 0);

            return Datetime.newInstance(tomorrow, zeroTime);

        //★ステータスが追客保留中
        }else if (status == CommonConst.CORRESPOND_STATUS_PURSUITHOLD){
            // 返：対応.追客解除設定日時（保存用）
            return pursuitDissolveDate;
            
        //★ステータスがアポイント確定
        }else if (status == CommonConst.CORRESPOND_STATUS_APPOINTMENT && AppointStart != null){
            // 返：対応.アポイント開始日0時の前日
            return AppointStart.addDays(-1);

        //★それ以外
        }else{
            // 返：最終日(2999/12/31)
            return CommonConst.LAST_DATE;
        }
    }

	// ▼ 2022.02.15 No0727 申込、入金画面の同処理の共通化
    /**
     * 総賃料の計算（物件外）
     * @param  Application__c                 application            計算に使用するオブジェクト
     * @param  List<ApplicantQuoteManageCompayItem__c> manageItemList   計算に使用する申込指定商品オブジェクト
     * @return Decimal                                               計算結果
     */
    public static Decimal calcAllRentApplication(Application__c application, List<ApplicantQuoteManageCompayItem__c> manageItemList) {
		Decimal allRent = 0;
        application.recalculateFormulas(); // 数式項目の再計算
		allRent += CommonUtil.getNullToDecimalValue(application.Rent__c);		// 家賃
		allRent += CommonUtil.getNullToDecimalValue(application.WortFee__c);			// 水道料金
		allRent += CommonUtil.getNullToDecimalValue(application.ManagementFee__c);	// 共益費
		allRent += CommonUtil.getNullToDecimalValue(application.CATV__c);				// CATV
		allRent += CommonUtil.getNullToDecimalValue(application.TownshipFee__c);		// 町会費
		allRent += CommonUtil.getNullToDecimalValue(application.GarbageDisposalFee__c);	// ゴミ処理費
		allRent += CommonUtil.getNullToDecimalValue(application.BicycleParkingFee__c);	// 駐輪場料金
		allRent += CommonUtil.getNullToDecimalValue(application.BikeStorageSmallFirstFee__c);// バイク置き場代（小型）日割額
		allRent += CommonUtil.getNullToDecimalValue(application.BikeStorageMediumFirstFee__c);// バイク置き場代（中型）日割額
		allRent += CommonUtil.getNullToDecimalValue(application.BikeStorageLargeFirstFee__c);// バイク置き場代（大型）日割額
		allRent += CommonUtil.getNullToDecimalValue(application.ParkingFee__c);	// 駐車場料金
        for (ApplicantQuoteManageCompayItem__c item : manageItemList) {  // 管理会社指定商品※月額で利用区分にチェック有
            if (item.PaymentType__c == CommonConst.MANAGEMENTCOMPANYITEM_PAYMENTTYPE_MONTH &&
			   (item.IsPlanUse__c)) {
                // 支払区分「月額」で利用有無がtrueの商品の料金のみ計上
				allRent += CommonUtil.getNullToDecimalValue(item.AmountTax__c);
			}
		}

		allRent += CommonUtil.getNullToDecimalValue(application.FireInsuranceMonth__c);	// 火災保険料

		return allRent;
	}
	/**
	* 付帯保証金額計算
	* @param ItemDetail__c itemDetail 商品明細
	* @param Decimal rentFee 賃料
	* @param Decimal allRentFee 総賃料
	* @return Decimal 付帯保証料
	*/
	public static Decimal depositPlanCalculation(ItemDetail__c itemDetail,Decimal rentFee , Decimal allRentFee){
		Decimal returnMoney =null; 

		Decimal rentFeeRate = (itemDetail.Item__r.RentFeeRate__c==null ? 0 : itemDetail.Item__r.RentFeeRate__c /100); // 賃料割合（保証会社）
		Decimal firstFeeDepositRate = (itemDetail.FirstFeeDepositRate__c==null ? 0 : itemDetail.FirstFeeDepositRate__c /100); // 初回保証料(割合)
		Decimal firstFeeDepositYen  = (itemDetail.FirstFeeDepositYen__c==null ? 0 : itemDetail.FirstFeeDepositYen__c); // 初回保証料(金額)
		// 初回保証料(割合)
		if (firstFeeDepositRate > 0) {
			if (! itemDetail.IsRentFeeType__c){
				// 賃料
				returnMoney = rentFee==null ? 0 : rentFee * rentFeeRate * firstFeeDepositRate;
	
			}else {
				//総賃料
				 allRentFee = (allRentFee ==null ? 0 : allRentFee);
				Decimal directDebitFeeTax = 0;
				if (itemDetail.Item__r.Account__r.IsAllRentFeeType__c) {
					// 総賃料に口座手数料を含む場合セット
					directDebitFeeTax = (itemDetail.Item__r.DirectDebitFeeTax__c==null ? 0 : itemDetail.Item__r.DirectDebitFeeTax__c);
				}
				returnMoney = (allRentFee + directDebitFeeTax) * (rentFeeRate * firstFeeDepositRate);
			}
		}else if(firstFeeDepositYen > 0){
			// 初回保証料(金額)
			returnMoney = firstFeeDepositYen * rentFeeRate;
		}

		if (returnMoney.scale() != 0 ){
			//引数に小数が含まれる場合
			returnMoney = returnMoney.intValue();
		}
		return returnMoney;
	}

	/**
	* 選択リスト値の金額返却
	* @param Map<Id, Decimal> auxiliaryMap　金額検索マップ
	* @param Id auxiliaryId 検索Id
	* @return String 金額（画面表示用）
	*/
	public static String returnScreenMoney(Map<Id, Decimal> auxiliaryMap,Id auxiliaryId){
		String returnScreenMoney = commonUtil.decimalToString(auxiliaryMap.get(auxiliaryId)); 
		return returnScreenMoney =='0' ? null : returnScreenMoney;
	}
	
	/**
     * その他付帯商品名の選択リストを作成
	 * @param String auxiliaryItemType その他付帯商品種別
	 * @param Map<Id, Item__c> etceteraAuxiliaryItemMap その他付帯商品のマップ
	 * @return List<SelectOption> 選択リスト
     */
	public static List<SelectOption> getEtceteraAuxiliaryItemNameListFromType(String auxiliaryItemType,Map<Id, Item__c> etceteraAuxiliaryItemMap) {
		List<SelectOption> selectOptionList = new List<SelectOption>();

		// --なし--の追加
		selectOptionList.add(new SelectOption('', commonConst.SELECTION_LIST_NULL));

		// 種別が一致する付帯商品を選択リストに追加
		for (Id key: etceteraAuxiliaryItemMap.keySet()) {
			Item__c item = etceteraAuxiliaryItemMap.get(key);
			if (String.isEmpty(auxiliaryItemType) || item.AuxiliaryItemType__c.equals(auxiliaryItemType)) {
				selectOptionList.add(new SelectOption(item.Id, getEtceteraAuxiliaryItemName(item)));
			}
		}

		return selectOptionList;
	}

	/**
	 * Decimal⇒Stringのコンバート
	 * @param Decimal val 変換値
	 * @return String 変換後（カンマ付き、0⇒Null変換）
	 */
	public static String decimalToStringEx(Decimal val) {
		String str = CommonUtil.decimalToString(val);
		str = (str == '0') ? null : str;
		return str;
	}

	/**
	* 付帯保証プランのデータ取得
	* @return List<ItemDetail__c> 付帯保証プランのリスト（商品明細）
	*/
	public static List<ItemDetail__c> getDepositPlan(){
		return [
			SELECT 	id
			,		AuxiliaryDepositPlanName__c 			// 付帯保証プラン
			,		IsRentFeeType__c 						// 賃料区分 True:総賃料/False：賃料 
			,		FirstFeeDepositRate__c 					// 初回保証料(割合)
			,		FirstFeeDepositYen__c					// 初回保証料(金額)
			,		Item__r.RentFeeRate__c 					// 賃料割合（保証会社）
			,		Item__r.Account__r.IsAllRentFeeType__c	// 総賃料区分 総賃料に口座手数料を含むか含まないかを判断に使用 True:含む /False:含まない
			,		Item__r.DirectDebitFeeTax__c			// 手数料(税込)
			FROM 	ItemDetail__c
			WHERE 	Item__r.RecordType.DeveloperName = :commonConst.ITEM_RECTYPE_GUARANTEE_PLAN // レコードタイプ：保証プラン
			AND 	Item__r.IsAuxiliary__c = true];	// 付帯商品区分
	}

	/**
	* 付帯火災保険のデータ取得
	* @return List<Item__c> 付帯火災保険のリスト（商品）
	*/
	public static List<Item__c> getFireInsuranceList(){
		return[
			SELECT 	id
			,		ItemName__c				// 商品名
			,		FireInsuranceContent__c	// 火災保険料
			,		InsuranceFeeRate__c 	// 保険料割合（火災保険）
			FROM 	Item__c
			WHERE 	RecordType.DeveloperName = :CommonConst.ITEM_RECTYPE_FIRE_INSURANCE // レコードタイプ：火災保険プラン
			AND 	IsAuxiliary__c = true];	// 付帯商品区分
	}

	/**
	 * その他付帯商品の一覧を検索
	 * @return Map<Id, Item__c> 付帯商品のMap
	 */
	public static Map<Id, Item__c> searchEtceteraAuxiaryItemRecode() {
		// 検索実行
		Map<Id, Item__c> records = new Map<Id, Item__c>([
			SELECT Id
			, AuxiliaryItemType__c			// 付帯商品種別
			, Account__r.Name				// 付帯業者名
			, ItemName__c					// 商品名
			, auxiliaryItemFeeTaxType__c	// 付帯料金税区分
			, auxiliaryItemFeeTax__c		// 付帯料金(税込)
			FROM Item__c
			WHERE RecordTypeId = :CommonUtil.getRecordTypeId(CommonUtil.getNamespace('Item__c'), CommonConst.ITEM_RECTYPE_AUXILIARY_ITEM)
			ORDER BY  AuxiliaryItemType__c, Account__r.Name, ItemName__c
		]);
		return records;
	}
	// ▲ 2022.02.15 No0727

	//▼ 2022.05.25 No0827 対応で変更
	//▼ 2022.04.20 No0768 対応で追加
	/**
	 * 有効な対応が無い場合に新規登録する処理
	 * @param Id LineId LINE会員ID
	 * @param Boolean notApplicableStatusInsertFlg 無効なステータスの対応から新規登録を行うかのフラグ「反響集約」「契約完了」「終了」
	 * @return Correspond__c LINE会員の対応ID
	*/
	public static Correspond__c checkCorrespondLine(Id LineId,Boolean notApplicableStatusInsertFlg) {
		// LINE会員から対応が存在するか取得
		List<Correspond__c> selectCorrespondList = [
			SELECT ID,Status__c,LineMember__c,LineReceiveDate__c,LineFriendAddDate__c,EventDateTime__c,ReceiveMailDatePortal__c,ReceiveMailDateOther__c,ThanksMailSettingSendDate__c
			,EchoShop__c,EchoShop__r.Email__c,FirstInquiryMeans__c
			 FROM Correspond__c 
			WHERE LineMember__c = :LineId 
			ORDER BY systemModstamp DESC
		];

		// LINE会員に紐づいている取引先を取得
		LineMember__c getAccountID = [SELECT ID,Account__c FROM LineMember__c WHERE ID =: LineId LIMIT 1]; 

		// LINE会員と対応が紐づいていない
		if (selectCorrespondList.size() == 0){
			// 新規登録
			return setInserCorrespondLine(LineId,getAccountID);
		}else if(notApplicableStatusInsertFlg){ 
			Correspond__c notStatusCorrespond = new Correspond__c();
			for (Correspond__c selectCorrespond : selectCorrespondList) {
				if(notApplicableStatus.contains(selectCorrespond.Status__c) && notStatusCorrespond.Id == null){
					// 無効なステータス
					// 無効なステータスを元に対応を登録
					notStatusCorrespond = selectCorrespond;
				}else {
					// 有効なステータスがあれば
					return selectCorrespond;
				}
			}
			if (notStatusCorrespond.Id != null) {
				return setInserCorrespondLine(notStatusCorrespond,getAccountID);
			}
			
		}

		// LINE会員と対応の紐づきあり
		return selectCorrespondList[0];
	}
	//▲ 2022.05.25 No0827 対応で変更
	

	/**
	 * 対応が無い、無効なステータスの場合に新規登録する処理
	 * @param Id LineId LINE会員ID
	 * @return Correspond__c 新規登録後対応
	*/
	private static Correspond__c setInserCorrespondLine(Id LineId,LineMember__c getAccountID) {
		Correspond__c correspond = new Correspond__c();
		Datetime now = CommonUtil.getNow();
		correspond.LineMember__c = LineId;	// LINE会員ID
		correspond.FirstLineAddFlg__c = true;	// 初回LINE追加フラグ
		correspond.status__c = CommonConst.CORRESPOND_STATUS_NOTSUPPORTED;	// ステータス（未対応）
		correspond.EventDateTime__c = now;	// イベント時刻	
		correspond.ListViewDate__c = now.addDays(1); // 一覧表示日時
		correspond.AccountId__c = getAccountID.Account__c; // 取引先
		SecureDML.secureInsert(correspond);
		return correspond;
	}
	/**
	 * 対応が「反響集約」「終了」「契約完了」場合に新規登録する処理
	 * @param Correspond__c selectCorrespond 対応
	 * @return Correspond__c 新規登録後対応
	*/
	private static Correspond__c setInserCorrespondLine(Correspond__c selectCorrespond,LineMember__c getAccountID) {
		Correspond__c correspond = new Correspond__c();

		correspond.LineMember__c = selectCorrespond.LineMember__c;	// LINE会員ID
		correspond.FirstLineAddFlg__c = true;	// 初回LINE追加フラグ
		correspond.LineReceiveDate__c = selectCorrespond.LineReceiveDate__c; //	LINE受信日時	
		correspond.LineFriendAddDate__c = selectCorrespond.LineFriendAddDate__c;// LINEお友達登録日時	
		correspond.status__c = CommonConst.CORRESPOND_STATUS_PURSUIT;	// ステータス（追客中）
		correspond.EchoShop__c = selectCorrespond.EchoShop__c; // 反響担当店舗	
		correspond.FirstInquiryMeans__c = selectCorrespond.FirstInquiryMeans__c;// 初回問合せ方法	
		correspond.EventDateTime__c = CommonUtil.getNow();	// イベント時刻	
		correspond.ListViewDate__c = CustomerUtil.setListViewDateWhenCorrespondCheck(CommonConst.CORRESPOND_STATUS_PURSUIT, selectCorrespond.id); // 一覧表示日時
		correspond.ReceiveMailDatePortal__c = selectCorrespond.ReceiveMailDatePortal__c;	// メール受信日時（ポータル）		※メールで判断：反響メール.お問い合わせ日時
		correspond.ReceiveMailDateOther__c = selectCorrespond.ReceiveMailDateOther__c;		// メール受信日時（その他）		※メールで判断：反響メール.お問い合わせ日時
		correspond.ThanksMailSettingSendDate__c = selectCorrespond.ThanksMailSettingSendDate__c;// 問合せ御礼メール送信日時		システム日付（日時）
		correspond.AccountId__c = getAccountID.Account__c; // 取引先

		SecureDML.secureInsert(correspond);
		return correspond;
	}
	//▲ 2022.04.20 No0768 対応で追加

	// ▼ 2022.1.27 LINE連携対応より、追加
	/**
	 * 対応の取得
	 * @param Id condId 対応ID
	 * @return Correspond__c 対応
	 */
	private static Correspond__c getCorrespond(Id condId) {

		List<Correspond__c> correspondList = [
			SELECT
				Id
				, Status__c
				, StatusBeforePursuitHold__c
				, AppointmentStartDate__c
				, PursuitDissolveDate__c
				, AccountId__r.RecordTypeId
			FROM
				Correspond__c
			WHERE
				Id = :condId
		];

		if (correspondList.isEmpty()) {
			return new Correspond__c();
		}

		return correspondList[0];
	}
	// ▲ 2022.1.27

	// ▼ 2022.02.15 No0727 申込、入金画面の同処理の共通化
	/**
	 * 商品（カスタム）オブジェクトからその他付帯商品名を作成
	 * @param Item__c item 商品
	 * @return String その他付帯商品名
	 */
	private static String getEtceteraAuxiliaryItemName(Item__c item) {
		String ret = '';
		ret += item.Account__r.Name + '/';	// 付帯業者名
		ret += item.ItemName__c + '/\\';	// 商品名
		// 付帯料金
		if (item.auxiliaryItemFeeTax__c != null) {
			ret += CommonUtil.decimalToString(item.auxiliaryItemFeeTax__c);
		}
		return ret;
	}

	/**
	 * 付帯商品クラス
	 */
	public class AuxiliaryItem {
		// プロパティ
		public Id      auxiliaryItemId      { get; set; }   // 付帯商品Id
		public String  auxiliaryItemType    { get; set; }   // 付帯商品種別
		public String  auxiliaryItemAccount { get; set; }   // 付帯業者
		public String  auxiliaryItemName    { get; set; }   // 付帯商品
		public String  auxiliaryItemFee     { get; set; }   // 販売価格

		// 取得用プロパティ
		public Decimal auxiliaryItemFeeDec  {
			get {
				if (String.isEmpty(auxiliaryItemFee)) {
					return null;
				} else {
					return commonUtil.stringToDecimal(auxiliaryItemFee);
				}
			}
		}

		// コンストラクタ１
		public AuxiliaryItem() {}

		// コンストラクタ２．申込オブジェクトから
		public AuxiliaryItem(Application__c targetRecord, Integer idx) {
			switch on idx {
				when 1 {
					this.auxiliaryItemId        =     (Id) targetRecord.AuxiliaryItem1__c;                          // 付帯商品Id
					this.auxiliaryItemType      = (String) targetRecord.AuxiliaryItem1__r.AuxiliaryItemType__c;     // 付帯商品種別
					this.auxiliaryItemAccount   = (String) targetRecord.AuxiliaryItem1__r.Account__r.Name;          // 付帯業者
					this.auxiliaryItemName      = (String) targetRecord.AuxiliaryItem1__r.ItemName__c;              // 付帯商品
					this.auxiliaryItemFee       = CommonUtil.decimalToString(targetRecord.auxiliaryItemFee1__c);    // 販売価格

				} when 2 {
					this.auxiliaryItemId        =     (Id) targetRecord.AuxiliaryItem2__c;                          // 付帯商品Id
					this.auxiliaryItemType      = (String) targetRecord.AuxiliaryItem2__r.AuxiliaryItemType__c;     // 付帯商品種別
					this.auxiliaryItemAccount   = (String) targetRecord.AuxiliaryItem2__r.Account__r.Name;          // 付帯業者
					this.auxiliaryItemName      = (String) targetRecord.AuxiliaryItem2__r.ItemName__c;              // 付帯商品
					this.auxiliaryItemFee       = CommonUtil.decimalToString(targetRecord.auxiliaryItemFee2__c);    // 販売価格

				} when 3 {
					this.auxiliaryItemId        =     (Id) targetRecord.AuxiliaryItem3__c;                          // 付帯商品Id
					this.auxiliaryItemType      = (String) targetRecord.AuxiliaryItem3__r.AuxiliaryItemType__c;     // 付帯商品種別
					this.auxiliaryItemAccount   = (String) targetRecord.AuxiliaryItem3__r.Account__r.Name;          // 付帯業者
					this.auxiliaryItemName      = (String) targetRecord.AuxiliaryItem3__r.ItemName__c;              // 付帯商品
					this.auxiliaryItemFee       = CommonUtil.decimalToString(targetRecord.auxiliaryItemFee3__c);    // 販売価格

				} when 4 {
					this.auxiliaryItemId        =     (Id) targetRecord.AuxiliaryItem4__c;                          // 付帯商品Id
					this.auxiliaryItemType      = (String) targetRecord.AuxiliaryItem4__r.AuxiliaryItemType__c;     // 付帯商品種別
					this.auxiliaryItemAccount   = (String) targetRecord.AuxiliaryItem4__r.Account__r.Name;          // 付帯業者
					this.auxiliaryItemName      = (String) targetRecord.AuxiliaryItem4__r.ItemName__c;              // 付帯商品
					this.auxiliaryItemFee       = CommonUtil.decimalToString(targetRecord.auxiliaryItemFee4__c);    // 販売価格

				} when 5 {
					this.auxiliaryItemId        =     (Id) targetRecord.AuxiliaryItem5__c;                          // 付帯商品Id
					this.auxiliaryItemType      = (String) targetRecord.AuxiliaryItem5__r.AuxiliaryItemType__c;     // 付帯商品種別
					this.auxiliaryItemAccount   = (String) targetRecord.AuxiliaryItem5__r.Account__r.Name;          // 付帯業者
					this.auxiliaryItemName      = (String) targetRecord.AuxiliaryItem5__r.ItemName__c;              // 付帯商品
					this.auxiliaryItemFee       = CommonUtil.decimalToString(targetRecord.auxiliaryItemFee5__c);    // 販売価格

				} when 6 {
					this.auxiliaryItemId        =     (Id) targetRecord.AuxiliaryItem6__c;                          // 付帯商品Id
					this.auxiliaryItemType      = (String) targetRecord.AuxiliaryItem6__r.AuxiliaryItemType__c;     // 付帯商品種別
					this.auxiliaryItemAccount   = (String) targetRecord.AuxiliaryItem6__r.Account__r.Name;          // 付帯業者
					this.auxiliaryItemName      = (String) targetRecord.AuxiliaryItem6__r.ItemName__c;              // 付帯商品
					this.auxiliaryItemFee       = CommonUtil.decimalToString(targetRecord.auxiliaryItemFee6__c);    // 販売価格

				} when 7 {
					this.auxiliaryItemId        =     (Id) targetRecord.AuxiliaryItem7__c;                          // 付帯商品Id
					this.auxiliaryItemType      = (String) targetRecord.AuxiliaryItem7__r.AuxiliaryItemType__c;     // 付帯商品種別
					this.auxiliaryItemAccount   = (String) targetRecord.AuxiliaryItem7__r.Account__r.Name;          // 付帯業者
					this.auxiliaryItemName      = (String) targetRecord.AuxiliaryItem7__r.ItemName__c;              // 付帯商品
					this.auxiliaryItemFee       = CommonUtil.decimalToString(targetRecord.auxiliaryItemFee7__c);    // 販売価格

				} when 8 {
					this.auxiliaryItemId        =     (Id) targetRecord.AuxiliaryItem8__c;                          // 付帯商品Id
					this.auxiliaryItemType      = (String) targetRecord.AuxiliaryItem8__r.AuxiliaryItemType__c;     // 付帯商品種別
					this.auxiliaryItemAccount   = (String) targetRecord.AuxiliaryItem8__r.Account__r.Name;          // 付帯業者
					this.auxiliaryItemName      = (String) targetRecord.AuxiliaryItem8__r.ItemName__c;              // 付帯商品
					this.auxiliaryItemFee       = CommonUtil.decimalToString(targetRecord.auxiliaryItemFee8__c);    // 販売価格

				} when 9 {
					this.auxiliaryItemId        =     (Id) targetRecord.AuxiliaryItem9__c;                          // 付帯商品Id
					this.auxiliaryItemType      = (String) targetRecord.AuxiliaryItem9__r.AuxiliaryItemType__c;     // 付帯商品種別
					this.auxiliaryItemAccount   = (String) targetRecord.AuxiliaryItem9__r.Account__r.Name;          // 付帯業者
					this.auxiliaryItemName      = (String) targetRecord.AuxiliaryItem9__r.ItemName__c;              // 付帯商品
					this.auxiliaryItemFee       = CommonUtil.decimalToString(targetRecord.auxiliaryItemFee9__c);    // 販売価格

				} when 10 {
					this.auxiliaryItemId        =     (Id) targetRecord.AuxiliaryItem10__c;                          // 付帯商品Id
					this.auxiliaryItemType      = (String) targetRecord.AuxiliaryItem10__r.AuxiliaryItemType__c;     // 付帯商品種別
					this.auxiliaryItemAccount   = (String) targetRecord.AuxiliaryItem10__r.Account__r.Name;          // 付帯業者
					this.auxiliaryItemName      = (String) targetRecord.AuxiliaryItem10__r.ItemName__c;              // 付帯商品
					this.auxiliaryItemFee       = CommonUtil.decimalToString(targetRecord.auxiliaryItemFee10__c);    // 販売価格
				}
			}
		}

		// コンストラクタ３．商品（カスタム）オブジェクトから
		public AuxiliaryItem(Item__c item, String auxiliaryItemFee) {
			this.auxiliaryItemId        = item.Id;                      // 付帯商品Id
			this.auxiliaryItemType      = item.AuxiliaryItemType__c;    // 付帯商品種別
			this.auxiliaryItemAccount   = item.Account__r.Name;         // 付帯業者
			this.auxiliaryItemName      = item.ItemName__c;             // 付帯商品
			this.auxiliaryItemFee       = auxiliaryItemFee;             // 販売価格
		}
	}
	// ▲ 2022.02.15 No0727 
}