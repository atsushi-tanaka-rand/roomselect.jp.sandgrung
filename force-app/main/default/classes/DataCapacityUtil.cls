/**
 * データ容量削減_共通クラス
 **/
public with sharing class DataCapacityUtil {

	/*
	* 検索時刻の取得
	* スケジューラの名前に「物件メンテナンス履歴削除+処理日付+_yyyyMMddHHmmss」のyyyyMMddHHmmssを抜き出し日付として返す
	* @param Id triggerId スケジューラID
	* @param Datetime searcstandardDateTime 検索時刻の標準
	* @return Datetime 検索用時刻
	*/
	public static Datetime getSearchDateTime(Id triggerId,Datetime searcstandardDateTime){
		Datetime searcOwnCompanyManageModDate;
		try {
			// IDからバッチ名を取得（検索時刻を抜き出す用）
			CronTrigger CronTrigger = [SELECT CronJobDetailId FROM CronTrigger WHERE ID = :triggerId LIMIT 1];
			CronJobDetail CronJobDetail = [SELECT Name FROM CronJobDetail WHERE ID = :CronTrigger.CronJobDetailId LIMIT 1];
			Integer lastSlIndex = CronJobDetail.Name.lastIndexOf('_');
			if (lastSlIndex >= 0) {
				String processingDate = CronJobDetail.Name.substring(lastSlIndex+1);
				// 対象のスケジューラに時刻が設定されているか判断（yyyyMMddHHmm）もしくは（yyyyMMddHHmmss）であるか
				if(processingDate.length() == 14 || processingDate.length() == 12){
					String triggerYear =  processingDate.substring(0,4);
					String triggerMonth =  processingDate.substring(4,6);
					String triggerDay =  processingDate.substring(6,8);
					String triggerTime =  processingDate.substring(8,10);
					String triggerMinute =  processingDate.substring(10,12);
					String triggerSecond =   processingDate.length() == 12 ? '00':processingDate.substring(12,14);
					// 日付時間型に生成
					searcOwnCompanyManageModDate = Datetime.valueOf(triggerYear + '-' + triggerMonth + '-' + triggerDay + ' ' + triggerMinute + ':' + triggerMinute + ':' + triggerSecond);
				}
			}
		} catch (Exception ex) {
			// 取れなければ検索時刻の標準をセット
			searcOwnCompanyManageModDate = searcstandardDateTime;
		}


		if(searcOwnCompanyManageModDate == null){
			// 取れなければ検索時刻の標準をセット
			searcOwnCompanyManageModDate = searcstandardDateTime;
		}
			
		system.debug('getSearchDateTime='+searcOwnCompanyManageModDate);
		return searcOwnCompanyManageModDate;
	}

	/*
	* 会計年度開始日取得
	* @param Datetime now 年度取得日付
	* @return Datetime 会計年度開始日
	*/
	public static Datetime getFiscalFirstDate(Datetime now){
		Organization orgInfo = [SELECT FiscalYearStartMonth, UsesStartDateAsFiscalYearName FROM Organization WHERE id = :Userinfo.getOrganizationId()];
		String targetYear = String.valueOf(CommonUtil.calcFiscalYear(now.date(), orgInfo));
		return CommonUtil.calcFiscalYearStartEndDate(targetYear, orgInfo, true);
	}

	/*
	* データ削除バッチ実行
	* @param String CSVFaile CSV成型ファイル群
	* @param String fileName CSVファイル名
	* @param sObject[] delteteList 削除リスト
	* @return Boolean 結果
	*/
	public static String dataCapacityExecution(String CSVFaile,String fileName,sObject[] delteteList) {
		try {
			if (delteteList.size() > 0){
				HttpResponse response = new HttpResponse();
				if (!Test.isRunningTest()) {
					response = AmazonS3Util.callS3Up(CSVFaile, fileName);
				}else{
					// テストクラスのみ
					response.setHeader('Content-Type', 'application/json');
					response.setStatusCode(200);//成功のステータスを返す
				}
				
				if (response.getStatusCode() != 200 && response.getStatusCode() != 404) {
					System.debug(response.toString());
					return 'CSVアップロードに失敗しました。：' +  CommonUtil.getExtraction(response.getBody(),'<Message>','</Message>');
				}

				// 削除実行
				Savepoint sp = Database.setSavepoint();
				try {
					// 対象データ削除
					SecureDML.secureDelete(delteteList);
				} catch (Exception ex) {
					Database.rollback(sp);
					return ex.getMessage();
				}
			}
		} catch (Exception ex) {
			return ex.getMessage();
		}
		return '';
	}

	/*
	* エラーメールの文面成型
	* @param String errorMessage エラーメッセージ
	* @param String batchName バッチ名
	* @return Datetime 会計年度開始日
	*/
	public static void mailMessageMolding(String errorMessage,String batchName){
		//  エラーメール文言作成
		String sendMessage = '';
		sendMessage = CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_PROCESS, batchName) +'\n';
		sendMessage += '\n';
		sendMessage += '【エラーメッセージ】\n';
		sendMessage += errorMessage;

		// エラーメール送信
		MailUtil.sendErrorMail(sendMessage,CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_PROCESS, batchName) );
	}

	/*
	 * FInd取得のリストを物件メンテナンス履歴へ成型
	 * @param List<Object> targetList　Findから取得したデータ
	 * @return List<PropertyMaintenanceHistory__c> 物件メンテナンス履歴リスト
    */
	public static List<PropertyMaintenanceHistory__c> setFindToList(List<Object> targetList){
		List<PropertyMaintenanceHistory__c> PropertyMaintenanceHistoryList = new List<PropertyMaintenanceHistory__c>();
		System.debug(targetList);
		for (Object target : targetList) {
			PropertyMaintenanceHistoryList =  (List<PropertyMaintenanceHistory__c>) JSON.deserialize(JSON.serializePretty(target), List<PropertyMaintenanceHistory__c>.class);
			System.debug(PropertyMaintenanceHistoryList);
		}
		return PropertyMaintenanceHistoryList;
	}

	/*
	 * 物件メンテナンス履歴取得＿居住中であり、2か月前の自社管理修正日
	 * @param Datetime searchDateTime 自社管理修正日
	 * @return String SOQL文
    */
	public static String selectPropertyOwnCompanyManageModDate(Datetime searchDateTime){
		String soql ='';
		//現況 = 居住中であり、2か月前の自社管理修正日の物件メンテナンス履歴を取得
		soql += 'SELECT ';
		soql += ' OwnCompanyManageModDate__c ';
		soql += ' FROM Property__c'; 
		soql += ' WHERE LiveStatus__c = \''+ commonConst.PROPERTY_LIVESTATUS_RESIDENT +'\'';
		soql += ' AND   OwnCompanyManageModDate__c < ' + searchDateTime.formatGmt('yyyy-MM-dd\'T\'hh:mm:ss.SSS\'Z\''); 
		// 並び：物件．自社管理修正日降順
		soql += ' ORDER BY OwnCompanyManageModDate__c DESC ';
		soql += ' LIMIT 1';
		
		return soql;
	}

	/*
	 * 物件メンテナンス履歴取得＿居住中であり、2か月前の自社管理修正日
	 * @param String apiName 全項目
	 * @param Datetime searchDateTime 実施時間
	 * @return String SOQL文
    */
	public static String selectPropertyMaintenanceHistory(String apiName,Datetime searchDateTime){
		String soql ='';
		//現況 = 居住中であり、2か月前の自社管理修正日の物件メンテナンス履歴を取得
		soql += 'SELECT ';
		soql += apiName;
		soql += ' , Property__r.OwnCompanyManageModDate__c ';
		soql += ' FROM PropertyMaintenanceHistory__c'; 
		soql += ' WHERE Property__r.LiveStatus__c = \''+ commonConst.PROPERTY_LIVESTATUS_RESIDENT +'\'';
		soql += ' AND   Property__r.OwnCompanyManageModDate__c < ' + searchDateTime.formatGmt('yyyy-MM-dd\'T\'hh:mm:ss.SSS\'Z\''); 
		// 並び：１．物件ID昇順、２，物件．自社管理修正日降順、３．物件メンテナンス履歴降順
		soql += ' ORDER BY Property__c ';
		soql += ' , Property__r.OwnCompanyManageModDate__c DESC ';
		soql += ' , CreatedDate DESC ';
		soql += ' LIMIT ' + CommonConst.GOVERNOR_DML_LIMIT;
		
		return soql;
	}

	/*
	 * 物件メンテナンス履歴取得＿掲載終了の重複
	 * @param String apiName 全項目
	 * @param Datetime searchDateTime 実施時間
	 * @return  List<List<SObject>> 実行結果
    */
	public static List<List<SObject>> selectPropertyMaintenanceHistoryPostingEnd(String apiName,Datetime searchDateTime){
		// Description を SOSL検索
		String findQuery = '';
		// メンテナンスコメントが「掲載終了」であり自社管理修正日が1か月前のデータ
		findQuery += 'FIND \'' + CommonConst.AUTOMAINTENANCE_TYPE_ENDOFPOSTING + '\' IN ALL FIELDS RETURNING ' +  CommonUtil.getNamespace('PropertyMaintenanceHistory__c');
		findQuery += '('+ apiName ;
		findQuery += ' WHERE Property__r.OwnCompanyManageModDate__c <= ' + searchDateTime.formatGmt('yyyy-MM-dd\'T\'hh:mm:ss.SSS\'Z\''); 
		findQuery += ' ORDER BY Property__c ';
		findQuery += ' , Property__r.OwnCompanyManageModDate__c DESC ';
		findQuery += ' , CreatedDate DESC ';
		findQuery += ' LIMIT ' + CommonConst.GOVERNOR_FIND_LIMIT + ' )';	// ※Findは2000件まで
		return Search.query(findQuery);
	}

	/*
	 * 自動メンテナンスデータ取得
	 * @param String apiName 全項目
	 * @param Datetime searchDateTime 実施時間
	 * @return String SOQL文
    */
	public static String selectAutoMaintenance(String apiName,Datetime searchDateTime){
		String soql ='';
		// 現在時刻から2か月前の自動メンテナンスを取得
		soql += 'SELECT ';
		soql += apiName;    
		soql += ' FROM AutoMaintenance__c'; //自動メンテナンス
		soql += ' WHERE CreatedDate < ' + searchDateTime.formatGmt('yyyy-MM-dd\'T\'hh:mm:ss.SSS\'Z\''); 
		soql += ' ORDER BY ImportDatetime__c DESC'; 
		soql += ' ,Building__r.Name ASC'; 
		soql += ' ,Property__r.Name ASC'; 
		soql += ' LIMIT ' + CommonConst.GOVERNOR_DML_LIMIT;
		return soql;
	}

	/*
	 * 閲覧履歴データ取得
	 * @param String apiName 全項目
	 * @param Datetime fiscalFirstDate 実施時間
	 * @return String SOQL文
    */
	public static String selectBrowsingHistory(String apiName,Datetime fiscalFirstDate){
		String soql ='';
		soql += 'SELECT ';  
		soql += apiName;
		soql += ' FROM BrowsingHistory__c'; 
		soql += ' WHERE BrowsingDate__c < :fiscalFirstDate'; 
		soql += ' ORDER BY BrowsingDate__c DESC ';
		soql += ' LIMIT ' + CommonConst.GOVERNOR_DML_LIMIT;
        
		return soql;   
	}
	/*
	 * CSVのバックアップデータ成型（掲載終了）
	 * @param List<PropertyMaintenanceHistory__c> targetList　物件メンテナンス履歴リスト（掲載終了）
	 * @return String ファイル内容
    */
	public static String setCsvPropertyMaintenanceHistoryPostingEnd(List<PropertyMaintenanceHistory__c> targetList){
		String cSVList = '';
		// メインデータループ
		for(PropertyMaintenanceHistory__c PropertyHistory : targetList){
			cSVList += setCsvPropertyMaintenanceData(PropertyHistory);
		}
		return cSVList;
	}

	/*
	 * CSVのバックアップデータ成型
	 * @param List<AutoMaintenance__c> targetList　自動メンテナンスリスト
	 * @param List<AutoMaintenance__c> delteteList 削除実行自動メンテナンス
	 * @return String ファイル内容
    */
	public static String setCsvAutoMaintenance(List<AutoMaintenance__c> targetList,List<AutoMaintenance__c> delteteList){
		String cSVList = '';
		// メインデータループ
		for(AutoMaintenance__c AutoMaintenance : targetList){
			AutoMaintenance__c delteteData = new AutoMaintenance__c();
			delteteData.Id = AutoMaintenance.Id;
			cSVList += CommonUtil.changeNullToEmpty(AutoMaintenance.Id) + ',';
			cSVList += CommonUtil.changeNullToEmpty(AutoMaintenance.OwnerId) + ',';
			cSVList += CommonUtil.changeNullToEmpty(AutoMaintenance.IsDeleted) + ',';
			cSVList += CommonUtil.changeNullToEmpty(AutoMaintenance.Name) + ',';
			cSVList += CommonUtil.changeNullToEmpty(AutoMaintenance.CreatedDate) + ',';
			cSVList += CommonUtil.changeNullToEmpty(AutoMaintenance.CreatedById) + ',';
			cSVList += CommonUtil.changeNullToEmpty(AutoMaintenance.LastModifiedDate) + ',';
			cSVList += CommonUtil.changeNullToEmpty(AutoMaintenance.LastModifiedById) + ',';
			cSVList += CommonUtil.changeNullToEmpty(AutoMaintenance.SystemModstamp) + ',';
			cSVList += CommonUtil.changeNullToEmpty(AutoMaintenance.LastViewedDate) + ',';
			cSVList += CommonUtil.changeNullToEmpty(AutoMaintenance.LastReferencedDate) + ',';
			cSVList += CommonUtil.changeNullToEmpty(AutoMaintenance.AutoMaintenance__c) + ',';
			cSVList += CommonUtil.changeNullToEmpty(AutoMaintenance.Building__c) + ',';
			cSVList += CommonUtil.changeNullToEmpty(AutoMaintenance.CrawlingSource__c) + ',';
			cSVList += CommonUtil.changeNullToEmpty(AutoMaintenance.District__c) + ',';
			cSVList += CommonUtil.changeNullToEmpty(AutoMaintenance.FormerSupplier__c) + ',';
			cSVList += CommonUtil.changeNullToEmpty(AutoMaintenance.ImportDatetime__c) + ',';
			cSVList += CommonUtil.changeNullToEmpty(AutoMaintenance.IsCompletedFlag__c) + ',';
			cSVList += CommonUtil.changeNullToEmpty(AutoMaintenance.Property__c) + ',';
			cSVList += CommonUtil.changeNullToEmpty(AutoMaintenance.Type__c) + ',';
			cSVList += CommonUtil.changeNullToEmpty(AutoMaintenance.AutoMaintenanceDifference__c) + ',';
			cSVList += CommonUtil.changeNullToEmpty(AutoMaintenance.DistrictError__c);

			// 改行
			cSVList += CommonConst.BREAK_CODE;

			delteteList.add(delteteData);
		}

		return cSVList;
	}

	/*
	 * CSVのバックアップデータ成型
	 * @param List<BrowsingHistory__c> targetList　閲覧履歴リスト
	 * @param List<BrowsingHistory__c> delteteList 削除対象閲覧履歴
	 * @return String ファイル内容
    */
	public static String setCsvBrowsingHistory(List<BrowsingHistory__c> targetList,List<BrowsingHistory__c> delteteList){
		String cSVList = '';
		// メインデータループ
		for(BrowsingHistory__c BrowsingHistory : targetList){
			BrowsingHistory__c delteteData = new BrowsingHistory__c();
			delteteData.id = BrowsingHistory.id;
			cSVList += CommonUtil.changeNullToEmpty(BrowsingHistory.Id) + ',';
			cSVList += CommonUtil.changeNullToEmpty(BrowsingHistory.OwnerId) + ',';
			cSVList += CommonUtil.changeNullToEmpty(BrowsingHistory.IsDeleted) + ',';
			cSVList += CommonUtil.changeNullToEmpty(BrowsingHistory.Name) + ',';
			cSVList += CommonUtil.changeNullToEmpty(BrowsingHistory.CreatedDate) + ',';
			cSVList += CommonUtil.changeNullToEmpty(BrowsingHistory.CreatedById) + ',';
			cSVList += CommonUtil.changeNullToEmpty(BrowsingHistory.LastModifiedDate) + ',';
			cSVList += CommonUtil.changeNullToEmpty(BrowsingHistory.LastModifiedById) + ',';
			cSVList += CommonUtil.changeNullToEmpty(BrowsingHistory.SystemModstamp) + ',';
			cSVList += CommonUtil.changeNullToEmpty(BrowsingHistory.LastViewedDate) + ',';
			cSVList += CommonUtil.changeNullToEmpty(BrowsingHistory.LastReferencedDate) + ',';
			cSVList += CommonUtil.changeNullToEmpty(BrowsingHistory.BrowsingDate__c) + ',';
			cSVList += CommonUtil.changeNullToEmpty(BrowsingHistory.BrowsingHistoryId__c) + ',';
			cSVList += CommonUtil.changeNullToEmpty(BrowsingHistory.IsDeleted__c) + ',';
			cSVList += CommonUtil.changeNullToEmpty(BrowsingHistory.MemberCoId__c) + ',';
			cSVList += CommonUtil.changeNullToEmpty(BrowsingHistory.MemberId__c) + ',';
			cSVList += CommonUtil.changeNullToEmpty(BrowsingHistory.PropertyCd__c) + ',';
			cSVList += CommonUtil.changeNullToEmpty(BrowsingHistory.PropertyId__c) + ',';
			cSVList += CommonUtil.changeNullToEmpty(BrowsingHistory.SessionKey__c) + ',';
			cSVList += CommonUtil.changeNullToEmpty(BrowsingHistory.UseAuthorityPortalForReport__c);

			// 改行
			cSVList += CommonConst.BREAK_CODE;

			delteteList.add(delteteData);
		}

		return cSVList;
	}

	/*
	 * CSVのバックアップデータ成型
	 * @param PropertyMaintenanceHistory__c PropertyHistory 物件メンテナンス履歴
	 * @return String ファイル内容
    */
	public static String setCsvPropertyMaintenanceData(PropertyMaintenanceHistory__c PropertyHistory){
		String cSVList = '';
		cSVList += CommonUtil.changeNullToEmpty(PropertyHistory.id) + ',';
		cSVList += CommonUtil.changeNullToEmpty(PropertyHistory.IsDeleted) + ',';
		cSVList += CommonUtil.changeNullToEmpty(PropertyHistory.Name) + ',';
		cSVList += CommonUtil.changeNullToEmpty(PropertyHistory.CreatedDate) + ',';
		cSVList += CommonUtil.changeNullToEmpty(PropertyHistory.CreatedById) + ',';
		cSVList += CommonUtil.changeNullToEmpty(PropertyHistory.LastModifiedDate) + ',';
		cSVList += CommonUtil.changeNullToEmpty(PropertyHistory.LastModifiedById) + ',';
		cSVList += CommonUtil.changeNullToEmpty(PropertyHistory.SystemModstamp) + ',';
		cSVList += CommonUtil.changeNullToEmpty(PropertyHistory.LastViewedDate) + ',';
		cSVList += CommonUtil.changeNullToEmpty(PropertyHistory.LastReferencedDate) + ',';
		cSVList += CommonUtil.changeNullToEmpty(PropertyHistory.Property__c) + ',';
		cSVList += CommonUtil.changeNullToEmpty(PropertyHistory.MaintenanceAction__c) + ',';
		cSVList += CommonUtil.changeNullToEmpty(PropertyHistory.MaintenanceCommentArea__c) + ',';
		cSVList += CommonUtil.changeNullToEmpty(PropertyHistory.MaintenanceEndDateTime__c) + ',';
		cSVList += CommonUtil.changeNullToEmpty(PropertyHistory.MaintenanceStaff__c) + ',';
		cSVList += CommonUtil.changeNullToEmpty(PropertyHistory.MaintenanceStartDateTime__c) + ',';
		cSVList += CommonUtil.changeNullToEmpty(PropertyHistory.MaintenanceType__c);

		// 改行
		cSVList += CommonConst.BREAK_CODE;
		return cSVList;
	}
}