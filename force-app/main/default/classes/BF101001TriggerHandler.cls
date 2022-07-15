// 自動追客メールテンプレートトリガーハンドラ
public with sharing class BF101001TriggerHandler {

    /** トリガから実行 */
    private boolean m_isExecuting = false;
    /** 新旧両方のトリガコール内のレコードの数 */
    private integer BatchSize = 0;

	/** レコードタイプ／自動追客メールテンプレート */
	private static final Id RECORDTYPE_ID_LINE = CommonUtil.getRecordTypeId(CommonUtil.getNamespace('AutoPursuitMailTemplate__c'), CommonConst.AUTO_PURSUIT_MAIL_TEMPLATE_LINE);
	private static final Id RECORDTYPE_ID_MAIL = CommonUtil.getRecordTypeId(CommonUtil.getNamespace('AutoPursuitMailTemplate__c'), CommonConst.AUTO_PURSUIT_MAIL_TEMPLATE_MAIL);

	// 更新前後フラグ（False：更新前、True：更新後）
	public Boolean updateBeforeOrAfterFlg = false;

	private Boolean wholeCompanyFlg = false;	//全社共通フラグ
	private Set<Id> shopIdSet = new Set<Id>();	//更新、登録対象店舗Idリスト
	private List<Id> idList = new List<Id>();	//アップサート対象IDリスト
	// 更新前、後の状態を保持するために外出し
	private Map<String, List<Integer>> allTimesMap = new Map<String, List<Integer>>();


	/** コンストラクタ */
	public BF101001TriggerHandler(boolean isExecuting, integer size){
		m_isExecuting = isExecuting;
		BatchSize = size;
	}

	/** 登録前処理 */
	public void onBeforeInsert(AutoPursuitMailTemplate__c[] newObjs){
		// 新規登録時チェック
		integrityCheckOnUpsert(newObjs);
	}

	/** 登録後処理 */
    public void onAfterInsert(AutoPursuitMailTemplate__c[] newObjs, Map<ID, AutoPursuitMailTemplate__c> newObjMap){
		// 処理なし
    }

    /** 更新前処理 */
    public void onBeforeUpdate(AutoPursuitMailTemplate__c[] oldObjs, Map<ID, AutoPursuitMailTemplate__c> oldObjMap, AutoPursuitMailTemplate__c[] newObjs, Map<ID, AutoPursuitMailTemplate__c> newObjMap){
		// 更新前チェック
		this.updateBeforeOrAfterFlg = false;
		integrityCheckOnUpsertBefore(oldObjs,newObjs,newObjMap);
		// 更新後チェック
		this.updateBeforeOrAfterFlg = true;
		integrityCheckOnUpsert(newObjs);
    }

    /** 更新後処理 */
    public void onAfterUpdate(AutoPursuitMailTemplate__c[] oldObjs, Map<ID, AutoPursuitMailTemplate__c> oldObjMap, AutoPursuitMailTemplate__c[] newObjs, Map<ID, AutoPursuitMailTemplate__c> newObjMap){
		// 処理なし
    }

    /** 削除前処理 */
    public void onBeforeDelete(AutoPursuitMailTemplate__c[] oldObjs, Map<ID, AutoPursuitMailTemplate__c> oldObjMap){
        // 削除時チェック
		integrityCheckOnUpsert(oldObjs);
    }

    /** 削除後処理 */
    public void onAfterDelete(AutoPursuitMailTemplate__c[] oldObjs, Map<ID, AutoPursuitMailTemplate__c> oldObjMap){   
        // 処理なし
    }

    /** 復元後処理 */
    public void onUndelete(AutoPursuitMailTemplate__c[] newObjs){  
        // 処理なし
    }

// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// ---------privateメソッド-----------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	/**
    * データ操作チェック
    * @param   AutoPursuitMailTemplate__c[]	objs 自動追客メールテンプレートオブジェクト
    * @return  なし
    */
	private void integrityCheckOnUpsert(AutoPursuitMailTemplate__c[] objs){
		// 入力チェック
		inputCheck(objs);
		
		// 回数に穴あきがあるかのチェック用のデータを作成
		List<AutoPursuitMailTemplate__c> existingRecordList = getAutoPursuitMailTemplateList();
		allTimesMap = getTimesMap(objs,existingRecordList);

		// 回数の重複と連続した番号になっているかの確認
		checkTemplateNothing(objs,allTimesMap);
	}

	/**
    * 更新前チェック
	* 回数の穴あきが更新することで発生するかのリストをため込む
    * @param   AutoPursuitMailTemplate__c[]	objs 自動追客メールテンプレートオブジェクト（変更前）
	* @param   AutoPursuitMailTemplate__c[] newObjs 自動追客メールテンプレートオブジェクト（変更後）
	* @param   Map<ID, AutoPursuitMailTemplate__c> objMap 自動追客メールテンプレートマップ
    * @return  なし
    */
	private void integrityCheckOnUpsertBefore(AutoPursuitMailTemplate__c[] objs,AutoPursuitMailTemplate__c[] newObjs,Map<ID, AutoPursuitMailTemplate__c> objMap){
		// 回数に穴あきがあるかのチェック用のデータを作成
		inputGetList(objs);
		List<AutoPursuitMailTemplate__c> existingRecordList = getAutoPursuitMailTemplateList();
		allTimesMap = getTimesMap(objs,existingRecordList);
	}
	
	/**
    * 送信対象と店舗の設定、開始回数と終了回数のチェック
    * @param   AutoPursuitMailTemplate__c[]	objs 自動追客メールテンプレートオブジェクト
    * @return  
    */
	private void inputCheck(AutoPursuitMailTemplate__c[] objs){
		for(AutoPursuitMailTemplate__c obj: objs){
			Boolean isErrorFlg = false;
			// チェック１
			// 送信対象と店舗の設定チェック
			if(CommonConst.PURSUIT_SEND_TARGET_WHOLE_COMPANY.equals(obj.SendTarget__c)){
				wholeCompanyFlg = true;
			}else if(obj.Shop__c == null){
				//送信対象が店舗かつ、店舗が空白の場合はエラーとする
				isErrorFlg = true;
				System.debug(CommonConst.MSG_MASTER_E_SAVE_NOT_SHOP+':data='+obj);
				obj.addError(CommonConst.MSG_MASTER_E_SAVE_NOT_SHOP);
			}else{
				shopIdSet.add(obj.Shop__c);
			}

			// チェック２
			// 開始回数と終了回数の確認
			if(Integer.valueOf(obj.End__c) < Integer.valueOf(obj.Start__c)){
				isErrorFlg = true;
				System.debug('開始回数と終了回数のエラー:data='+obj);
				obj.addError(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_LOWER_BOUND_EXCEED,'開始,終了'.split(',')));
			}

			// エラー有もしくは削除はidListをセットしない
			if (!(isErrorFlg || Trigger.isDelete)) {
				if(obj.Id != null)idList.add(obj.Id);	
			}
		}
	}
	/**
    * 送信対象と店舗の設定、開始回数と終了回数のチェック
    * @param   AutoPursuitMailTemplate__c[]	objs 自動追客メールテンプレートオブジェクト
    * @return  AutoPursuitMailTemplateClass チェック後のエラーとなっていない設定内容
    */
	private void inputGetList(AutoPursuitMailTemplate__c[] objs){
		for(AutoPursuitMailTemplate__c obj: objs){
			if(CommonConst.PURSUIT_SEND_TARGET_WHOLE_COMPANY.equals(obj.SendTarget__c)){
				wholeCompanyFlg = true;
			}else{
				shopIdSet.add(obj.Shop__c);
			}
			idList.add(obj.Id);
		}
	}
	
	/**
    * 変更対象のデータに関わるレコードを取得
    * @return  List<AutoPursuitMailTemplate__c>	自動追客メールテンプレートのチェック対象のデータ
    */
	private List<AutoPursuitMailTemplate__c> getAutoPursuitMailTemplateList(){
		if(wholeCompanyFlg){
			//送信対象が全社共通または、店舗が更新、登録対象の店舗かつ、更新対象でないレコードを取得
			return [SELECT Id, SendTarget__c, Start__c, End__c, Shop__c,RecordTypeId FROM AutoPursuitMailTemplate__c 
			WHERE  (SendTarget__c = :CommonConst.PURSUIT_SEND_TARGET_WHOLE_COMPANY
					OR (SendTarget__c = :CommonConst.PURSUIT_SEND_TARGET_SHOP AND Shop__c IN :shopIdSet))
			AND Id NOT IN :idList];
		}else{
			//店舗が更新、登録対象の店舗かつ、更新対象でないレコードを取得
			return [SELECT Id, SendTarget__c, Start__c, End__c, Shop__c,RecordTypeId FROM AutoPursuitMailTemplate__c 
			WHERE (SendTarget__c = :CommonConst.PURSUIT_SEND_TARGET_SHOP AND Shop__c IN :shopIdSet)
			AND Id NOT IN :idList];
		}

	}

	/**
    * 穴あきの対象を検索するためのマップ作成
	* @param   AutoPursuitMailTemplate__c[] objs 自動追客メールテンプレートオブジェクト
    * @param   List<AutoPursuitMailTemplate__c> existingRecordList チェック対象の自動追客メールテンプレート
    * @return  Map<String, List<Integer>> 各店舗 or 全社共通ごとの送信回数リストのマップ
    */
	private Map<String, List<Integer>> getTimesMap(AutoPursuitMailTemplate__c[] objs,List<AutoPursuitMailTemplate__c> existingRecordList){
		Map<String, List<Integer>> timesMap = new Map<String, List<Integer>>();	//各店舗 or 全社共通ごとの送信回数リストのマップ
		for(AutoPursuitMailTemplate__c existingRecord: existingRecordList){
			List<Integer> timesList = new List<Integer>();
			
			//レコードの開始から終了までを数字のリストとして保持する
			for(Integer i = Integer.valueOf(existingRecord.Start__c); i <= Integer.valueOf(existingRecord.End__c); i++){
				timesList.add(i);
			}

			//マップのキーとして、送信対象が全社共通の場合は"全社共通"、店舗の場合は店舗Idを指定する
			String mapKey = getMapKey(existingRecord);

			//送信回数リストマップを更新する
			if(timesMap.containsKey(mapKey)){
				timesMap.get(mapKey).addAll(timesList);
			}else{
				timesMap.put(mapKey, timesList);
			}
		}

		// 回数の重複と連続した番号になっているかの確認
		for(AutoPursuitMailTemplate__c obj: objs){
			
			//マップのキーとして、送信対象が全社共通の場合は"全社共通"、店舗の場合は店舗Idを指定する
			String mapKey = getMapKey(obj);

			if(! timesMap.containsKey(mapKey)){
				timesMap.put(mapKey, new List<Integer>());
			}
			//回数の重複があるか調査する
			for(Integer i = Integer.valueOf(obj.Start__c); i <= Integer.valueOf(obj.End__c); i++){
				if(timesMap.get(mapKey).contains(i)){
					if(Trigger.isDelete || (Trigger.isUpdate && this.updateBeforeOrAfterFlg == false)){
						// 削除、更新前時にMapのindexを削除
						integer index = timesMap.get(mapKey).indexOf(i);
						timesMap.get(mapKey).remove(index);
					}
				}else{
					if(!(Trigger.isDelete || (Trigger.isUpdate && this.updateBeforeOrAfterFlg == false))){
						// 削除、更新前以外無ければ追加
						timesMap.get(mapKey).add(i);
					}
					
				}
			}
		}
		return timesMap;
	}

	/**
    * 回数の穴あきチェック
	* @param   AutoPursuitMailTemplate__c[] objs エラーセット自動追客メールテンプレート
	* @param   Map<String, List<Integer>> timesMap 穴あきチェック用のマップ
	* @return  
    */
	private static void checkTemplateNothing(AutoPursuitMailTemplate__c[] objs,Map<String, List<Integer>> timesMap ){
		// 空のマップを設定する
		Map<ID, AutoPursuitMailTemplate__c> objMap = new Map<ID, AutoPursuitMailTemplate__c>();
		checkTemplateNothing(objs,timesMap,objMap);
	}
	/**
    * 回数の穴あきチェック
	* @param   AutoPursuitMailTemplate__c[] objs エラーセット自動追客メールテンプレート
	* @param   Map<String, List<Integer>> timesMap 穴あきチェック用のマップ
	* @param   Map<ID, AutoPursuitMailTemplate__c> objMap 更新前のエラーセット自動追客メールテンプレート（更新前以外は空）
	* @return  
    */
	private static void checkTemplateNothing(AutoPursuitMailTemplate__c[] objs,Map<String, List<Integer>> timesMap,Map<ID, AutoPursuitMailTemplate__c> objMap ){
		for(AutoPursuitMailTemplate__c obj: objs){

			//マップのキーとして、送信対象が全社共通の場合は"全社共通"、店舗の場合は店舗Idを指定する
			String mapKey = getMapKey(obj);

			List<Integer> mapKeytimesList = timesMap.get(mapKey);	// 回数のリストを取得
			if (mapKeytimesList.isEmpty()) {
				// 回数のリストが無ければ飛ばす。
				continue;
			}

			mapKeytimesList.sort();	// 開始と終了の回数を昇順に並べ替える
			Boolean isEmptyFlg = false;	// 回数有無フラグ（True：回数無、False：回数有）
			Boolean isHoleEmptyFlg = false;	// テンプレート回数の穴あきフラグ（True：抜けあり、False：抜け無）
			String  errorNoMessage = ''; // エラーメッセージ内容
			for (Integer count = 1; count <= mapKeytimesList[mapKeytimesList.size()-1]; count++) {
				if (!mapKeytimesList.contains(count)) {
					System.debug('データ＝' +mapKey+'：無し＝'+count);
					// 対象のメールテンプレートの回数が存在しない。
					// エラーメッセージセット（穴空きの番号を文言で保持するためにここで設定）
					errorNoMessage = errorNoMessage == '' ? String.valueOf(count.format()) : errorNoMessage+'、'+String.valueOf(count.format());
					isEmptyFlg = true;
					continue;
				}
				if (isEmptyFlg && mapKeytimesList.contains(count)) {
					System.debug('データ＝' +mapKey+'：隙間発生＝'+count);
					// テンプレート回数の穴あき状態（iiの昇順でテンプレート回数が無い後に番号があった状態）
					isHoleEmptyFlg = true;
				}
			}
			// 隙間がある場合エラー
			if(isHoleEmptyFlg){
				System.debug('隙間があるエラー:data='+obj);
				if(objMap.size() == 0 ){
					// 更新前以外
					obj.addError(CommonConst.MSG_MASTER_E_SAVE_TEMPLATE_NOTHING + errorNoMessage+'回目');
				}else {
					// 更新前のエラーはnewObjからセットする
					objMap.get(obj.Id).addError(CommonConst.MSG_MASTER_E_SAVE_TEMPLATE_NOTHING + errorNoMessage+'回目');	
				}
			}
		}
	}

	/**
    * 判定対象キーの取得
	* 　　全社共通：全社共通＋（自動追客メールテンプレート．レコードタイプ名）
	* 　　店舗　　：店舗ID　＋（自動追客メールテンプレート．レコードタイプ名）
	* @param   AutoPursuitMailTemplate__c autoPursuitMailTemplate 自動追客メールテンプレート
    * @return  String キーの内容
    */
	private static String getMapKey(AutoPursuitMailTemplate__c autoPursuitMailTemplate){
		String mapKey = '';
		//マップのキーとして、送信対象が全社共通の場合は"全社共通"、店舗の場合は店舗Idを指定する
		if(CommonConst.PURSUIT_SEND_TARGET_WHOLE_COMPANY.equals(autoPursuitMailTemplate.SendTarget__c)){
			mapKey = CommonConst.PURSUIT_SEND_TARGET_WHOLE_COMPANY;
		}else{
			mapKey = autoPursuitMailTemplate.Shop__c;
		}
		if(RECORDTYPE_ID_LINE.equals(autoPursuitMailTemplate.RecordTypeId)){
			mapKey += '_' + CommonConst.AUTO_PURSUIT_MAIL_TEMPLATE_LINE;
		}else{
			mapKey += '_' + CommonConst.AUTO_PURSUIT_MAIL_TEMPLATE_MAIL;
		}
		return mapKey;
	}
}