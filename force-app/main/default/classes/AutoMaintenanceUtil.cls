//自動メンテナンス作成 バッチ用、Utilクラス
public class AutoMaintenanceUtil {

    
    /** 登録・更新フラグ */
    private static boolean IsUpsert = false; 
    /** 名寄せ確認フラグ */
    private static boolean IsNameMearge = false;
    /** 写真エラーMap */
    private static Map<Id, String> PhotoMoveErroMap  = new Map<Id, String>();
    private static Map<Id, String> AutoBuildingIdMap = new Map<Id, String>();

    /** 定数 */
    private static final Integer MAX_ROOOM_COUNT                      = 10;
    private static final Integer MAX_BUILDING_PHOTO_COUNT             = 10;
    private static final Integer MAX_PROPERTY_PHOTO_COUNT             = 10;
    private static final Integer MAX_BUILDING_PHOTO_SURROUNDING_COUNT = 5;
    private static final Integer SURROUNDINGBACH_PROCESS_COUNT        = (Integer)SystemConfig__c.getInstance().SurroundingBatchProcessCount__c;
    private static final Id      RECORDTYPE_ID_SUPPLIER               = CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_SUPPLIER);
    private static final String S3FOLDERPATH_BUILDING_PROPERTY  = SystemConfig__c.getInstance().S3RootDirectory__c + '/public/salesforce/photo/building_property/'; // 建物・物件
    private static final String STATE_ALL                       = SystemConfig__c.getInstance().State__c;        // 都道府県のリスト（;区切り）
    private static final String STATE_SEPARATOR                 = ';';

    // クローリング写真格納元
    public static final String S3FOLDERPATH_DAIWALIVING = SystemConfig__c.getInstance().S3RootDirectory__c + '/crawling/daiwaliving/';   //末尾に営業所が追加されます。
    public static final String S3FOLDERPATH_REALNETPRO  = SystemConfig__c.getInstance().S3RootDirectory__c + '/crawling/realnetpro/';

    // 地区設定用
    private static List<SelectOption> districtList = CommonUtil.getSelectOptionFromObject('Building__c', 'District__c');
    
    // セーブポイント
    public static Savepoint savePoint;

    // 変換情報クラス
    private static ConvInfo convInfo;

    /**
     * バッチ１用メソッド
     * 関連レコードの作成、更新
     *  建物, 物件, 業者, 物件条件, 部屋, ×建物写真, ×物件写真, ×自動メンテナンス, ×建物物件差分
     * t_auto_maintenance_difference__c[]
     * Map<ID, t_auto_maintenance_difference__c>
     */
    public static void processAutoMaintenanceBatch1(t_auto_maintenance_difference__c[] newObjs) {
        
        try {
            // 変換情報の設定
            setConvInfo(newObjs);

            // コードSetの作成
            Set<String> supplierCodeSet = new Set<String>();    // 業者
            Set<String> buildingCodeSet = new Set<String>();    // 建物
            Set<String> propertyCodeSet = new Set<String>();    // 物件
            for (t_auto_maintenance_difference__c obj : newObjs) {
                if(String.isNotBlank(obj.MaintenanceSupplierCode__c)){
                    supplierCodeSet.add(obj.MaintenanceSupplierCode__c);
                }
                if(String.isNotBlank(obj.MaintenanceBuildingCode__c)){
                    buildingCodeSet.add(obj.MaintenanceBuildingCode__c);
                }
                if(String.isNotBlank(obj.MaintenancePropertyCode__c)){
                    propertyCodeSet.add(obj.MaintenancePropertyCode__c);
                }
            }

            //更新対象　変数宣言
            Map<String, Building__c> upsertBuildingMap = new Map<String, Building__c>();      // 建物Map
            Map<String, Account>     upsertSupplierMap = new Map<String, Account>();          // 業者Map
            Map<String, Property__c> upsertPropertyMap = new Map<String, Property__c>();      // 物件Map

            Map<String, String> changeAutoMaintenanceMessageMap = new Map<String, String>();  // 変更文言取得Map

            // 建物Map作成（メンテナンスコードをキーとした建物Map）
            Map<String, Building__c> databaseBuildingMap = selectBuildingMap(buildingCodeSet);

            // 物件Map作成（メンテナンスコードをキーとした物件Map）
            Map<String, Property__c> databasePropertyMap = selectPropertyMap(propertyCodeSet);

            // 連携不要データ判定（newObjsは1件であるという前提で処理しています。）
            if (isUnnecessaryData(newObjs, databaseBuildingMap, databasePropertyMap)) {
                return;
            }

            // 登録&更新 建物
            upsertBuildingMap = upsertBuilding(buildingCodeSet, newObjs, databaseBuildingMap, databasePropertyMap);

            // 登録&更新 業者
            upsertSupplierMap = upsertSupplier(supplierCodeSet, newObjs);

            // 登録&更新 物件
            upsertPropertyMap = upsertProperty(propertyCodeSet, newObjs, databasePropertyMap, upsertSupplierMap, upsertBuildingMap, databaseBuildingMap, changeAutoMaintenanceMessageMap);

            // 登録&更新 物件条件
            upsertPropertyCondition(propertyCodeSet, newObjs, upsertPropertyMap, databaseBuildingMap, databasePropertyMap,changeAutoMaintenanceMessageMap);

            // 登録 部屋
            insertRoom(newObjs, upsertPropertyMap, databaseBuildingMap, databasePropertyMap);

            // 更新 自動メンテナンス差分
            updateBatchStatus(newObjs, CommonConst.AUTOMAINTEDIFF_BATCHSTATUS_2, AutoBuildingIdMap, changeAutoMaintenanceMessageMap ); //バッチ2開始のために、ステータス2に変更

        } catch(Exception e) {
            // GoogleApiUtilのSavePointでAutoMaintenanceUtilのSavePointを上書き
            // 注意：GoogleApiUtilにてオブジェクトの登録&更新が始まる為、SavePointには、GoogleApiUtilのSavePonitを使用する
            savePoint = GoogleApiUtil.savePoint;
            throw e;
        }
    }

    /**
     * バッチ２用メソッド
     * 関連レコードの作成、更新
     *  ×建物, ×物件, ×業者, ×物件条件, ×部屋, 建物写真, 物件写真, 自動メンテナンス, 建物物件差分
     * t_auto_maintenance_difference__c[]
     * Map<ID, t_auto_maintenance_difference__c>
     */
    public static void processAutoMaintenanceBatch2(t_auto_maintenance_difference__c[] newObjs) {

        // 変換情報の設定
        setConvInfo(newObjs);

        // コードSetの作成
        Set<String> supplierCodeSet = new Set<String>();    // 業者
        Set<String> buildingCodeSet = new Set<String>();    // 建物
        Set<String> propertyCodeSet = new Set<String>();    // 物件
        for (t_auto_maintenance_difference__c obj : newObjs) {
            if(String.isNotBlank(obj.MaintenanceSupplierCode__c)){
                supplierCodeSet.add(obj.MaintenanceSupplierCode__c);
            }
            if(String.isNotBlank(obj.MaintenanceBuildingCode__c)){
                buildingCodeSet.add(obj.MaintenanceBuildingCode__c);
            }
            if(String.isNotBlank(obj.MaintenancePropertyCode__c)){
                propertyCodeSet.add(obj.MaintenancePropertyCode__c);
            }
        }
        
        // Map作成
        Map<String, Building__c>      buildingMap    = getBuildingMap(buildingCodeSet);    // 建物Map
        Map<String, Account>          supplierMap    = getSupplierMap(supplierCodeSet);    // 業者Map
        Map<String, Property__c>      propertyMap    = getPropertyMap(propertyCodeSet);    // 物件Map
        Map<String, BuildingPhoto__c> buildPhotoMap  = getBuildPhotoMap(buildingCodeSet);  // 建物写真Map
        Map<String, PropertyPhoto__c> propPhotoMap   = getPropPhotoMap(propertyCodeSet);   // 物件写真Map

        // 写真の移動 & 登録 ※HTTP通信を行う為、１番最初に実施 その為、
        //   ①このメソッドより上でDB更新はできません
        //   ②このメソッドより下でhttpコールアウトはできません
        moveBuildingPropertyPhoto(newObjs, buildingMap, propertyMap, supplierMap, propPhotoMap, buildPhotoMap);
        
        // Suumoスコア登録
        buildPhotoMap  = getBuildPhotoMap(BuildingCodeSet);  // 建物写真Map
        propPhotoMap   = getPropPhotoMap(PropertyCodeSet);   // 物件写真Map
        updateSuumoScore(newObjs, buildingMap, buildPhotoMap, propertyMap, propPhotoMap);

        // 建物物件差分
        propertyMap    = getPropertyMap(PropertyCodeSet);
        upsertBuildingProeryDiff(newObjs, propertyMap);

        // 自動メンテナンス登録
        insertAutoMaintenance(newObjs, buildingMap, propertyMap, supplierMap);

        // 自動メンテナンス差分更新
        updateBatchStatusBatch2(newObjs);

        // 自動メンテナンス差分削除
        deleteAutoMaintenanceDifference(newObjs);
    }

	//▼ No.614 システム変数の更新を共通化
	/**
	 * システム変数オブジェクト更新
	 * @param  string isAutomaintenanceBatchprocessing システム変数　項目名
	 * @return なし
	 */   
	public static void chengeSystemVariablesFlg(string isAutomaintenanceBatchprocessing){
		try {
			// システム変数オブジェクト更新
			SystemVariables__c SystemVariablesData;
			SystemVariablesData = [SELECT Id ,BooleanValue__c FROM SystemVariables__c  WHERE VariablesName__c = :isAutomaintenanceBatchprocessing];
			SystemVariablesData.BooleanValue__c  = false;
			SecureDML.secureUpdate(SystemVariablesData);
		} catch (Exception ex) {
			//  エラーメール送信
			String errorMessage = '';
			errorMessage = CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_PROCESS, '自動メンテナンスバッチ実行') +'\n';
			errorMessage += '\n';
			errorMessage += '【エラーメッセージ】\n';
			errorMessage += ex.getMessage();
			MailUtil.sendErrorMail(errorMessage,CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_PROCESS, '自動メンテナンスバッチ実行') );
		}
			
	}
	//▲ No.614 システム変数の更新を共通化
    //********************************************************************************  privateメソッド  *************************************************************************************************

    /**
     * 変換情報の設定
     * @param t_auto_maintenance_difference__c[] autoMaintenanceDiffAry 自動メンテナンス差分
     */
    private static void setConvInfo(t_auto_maintenance_difference__c[] autoMaintenanceDiffAry) {

        // メンテナンスコードの取得
        Set<String> buildingCodeSet = new Set<String>();    // 建物
        Set<String> propertyCodeSet = new Set<String>();    // 物件

        for (t_auto_maintenance_difference__c obj : autoMaintenanceDiffAry) {
            
            // 建物
            if(String.isNotBlank(obj.MaintenanceBuildingCode__c)){
                buildingCodeSet.add(obj.MaintenanceBuildingCode__c);
            }

            // 物件
            if(String.isNotBlank(obj.MaintenancePropertyCode__c)){
                propertyCodeSet.add(obj.MaintenancePropertyCode__c);
            }
        }
                                  
        // コード履歴の取得
        List<BuildingCodeHistory__c> buildingCdHistList = selectBuildingCdHist(buildingCodeSet); // 建物
        List<PropertyCodeHistory__c> propertyCdHistList = selectPropertyCdHist(propertyCodeSet); // 物件

        // 変換情報の設定
        convInfo = new ConvInfo(buildingCdHistList, propertyCdHistList);
    }
    

    /**
     * 建物作成・更新
     * @param   Set<String>         BuildingCodeSet                     建物のメンテナンスコード
     * @param   t_auto_maintenance_difference__c[]  newObjs             対象の自動メンテナンス差分
     * @param   Map<String, Building__c>            databaseBuildingMap 既存建物（key:メンテナンス建物コード、value:建物）
     * @param   Map<String, Property__c>            databasePropertyMap 既存物件（key:メンテナンス物件コード、value:物件）
     * @return  Map<String, Building__c>                    更新対象の建物Map
     */
    private static Map<String, Building__c> upsertBuilding(Set<String> BuildingCodeSet, t_auto_maintenance_difference__c[] newObjs
                                                           , Map<String, Building__c> databaseBuildingMap, Map<String, Property__c> databasePropertyMap) {

		// ダミー物件情報
        Property__c dummyProperty;

        // 建物コード履歴の更新値マップ（key:メンテナンス建物コード、value:情報更新日）
        Map<String, Datetime> updMaintenanceBuildingCdMap = new Map<String, Datetime>();

        // 建物UPSERT作成
        List<Building__c> newBuildingList = new List<Building__c>();            // 新規建物リスト
        Map<String, Building__c> upsertBuildingMap = new Map<String, Building__c>();
        for (t_auto_maintenance_difference__c diffObj : newObjs) {
            // 条件変更、掲載終了の場合、更新対象外
            if (diffObj.AutoMaintenanceType__c == CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_CHANGE_CONDITION || diffObj.AutoMaintenanceType__c == CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_POSTING_END) {
                continue;
            }
            
            // メンテナンス建物コードが存在しない場合はスキップ
            if (diffObj.MaintenanceBuildingCode__c == null) {
                continue;
            }

            // 建物コード履歴の更新値を設定
            updMaintenanceBuildingCdMap.put(diffObj.MaintenanceBuildingCode__c, diffObj.InfoModifiedDate__c);

            // 登録データ作成　※建物メンテナンスコードを確認し、既に作成済みの場合は処理不要
            if (!upsertBuildingMap.containsKey(diffOBj.MaintenanceBuildingCode__c)) {
                // 建物既存データ設定
                Building__c building = new Building__c();
                if (databaseBuildingMap.containskey(diffObj.MaintenanceBuildingCode__c)) {
                    building = databaseBuildingMap.get(diffObj.MaintenanceBuildingCode__c);
                }

                // 登録データ作成
                building = setBuildingData(building, diffObj);
                upsertBuildingMap.put(diffObj.MaintenanceBuildingCode__c, building);

                
                // 新規の場合は名寄せ検索対象
                if (building.Id == null) {
                    newBuildingList.add(building);
                }

                // 周辺情報取得で住所項目を使うので、数式再計算
                building.recalculateFormulas();
                
            }
        }

        // 新規建物処理
        Map<String, Property__c> dummyPropertyMap = new Map<String, Property__c>();
        if (newBuildingList.size() > 0) {
            // 名寄せフラグ設定
            NameMergeUtil.setBuildingMergeCompletedFlag(newBuildingList);

            // 建物のみ連携対象外、且つ物件は連携対象の場合、ダミー物件を作成する
            // ※既存物件は連携対象外に紐づかせる為の対応
            if (databasePropertyMap.size() > 0) {

                // ダミー物件情報の取得
                for (Building__c newBuilding : newBuildingList) {
                    dummyProperty = new Property__c(
                        Name = CommonConst.DUMMY_PROP_NAME                                  // 部屋番号
                        , MaintenancePropertyCode__c = CommonConst.DUMMY_PROP_MAINT_PROP_CD // メンテナンス物件コード
                        , LiveStatus__c = Commonconst.PROPERTY_LIVESTATUS_VACANCY           // 現況
                    );
                    dummyPropertyMap.put(newBuilding.MaintenanceBuildingCode__c, dummyProperty);
                }
            }
        }
      
        // 周辺情報の取得
        if (!Test.isRunningTest()) {
            //周辺情報取得　呼び出し
            GoogleApiUtil.getPeripheralInformation(newBuildingList);
        }
        //　注意：住所項目を使うので、呼び出す前に数式再計算を行うこと
        //　注意：このメソッドはhttpコールアウトを行い、周辺情報をinsertします。よって
        //　   ①このメソッドより上でDB更新はできません
        //　   ②このメソッドより下でhttpコールアウトはできません
        // 建物更新 ※エラー以外は登録/更新
        if (upsertBuildingMap.size() > 0) {
            SecureDML.secureUpsert(upsertBuildingMap.values());

            // ダミー物件の登録
            if (dummyPropertyMap.size() > 0) {

                // 建物IDの設定
                for (String maintenanceBuildingCd : dummyPropertyMap.keySet()) {
                    dummyProperty = dummyPropertyMap.get(maintenanceBuildingCd);
                    dummyProperty.Building__c = upsertBuildingMap.get(maintenanceBuildingCd).Id;
                	dummyPropertyMap.put(maintenanceBuildingCd, dummyProperty); 
                }

                SecureDML.secureInsert(dummyPropertyMap.values());
            }

            // 登録された建物の変換情報を設定
            convInfo.setNewMaintBuildingCd(upsertBuildingMap.values());
        }

        // 建物コード履歴の情報更新日を更新
        if (updMaintenanceBuildingCdMap.size() > 0) {
            updateBuildingCdHistInfoUpdateDate(updMaintenanceBuildingCdMap);
        }

        // 建物更新後データ再取得
        upsertBuildingMap = selectBuildingMap(BuildingCodeSet);

        return upsertBuildingMap;
    }    
    
    /**
     * 建物コード履歴の情報更新日を更新
     * @param Map<String, Datetime> updMap 更新値マップ（key:名寄せ元のメンテナンス建物コード、value:情報更新日）
     */
    private static void updateBuildingCdHistInfoUpdateDate(Map<String, Datetime> updMap) {

        // 建物コード履歴の取得
        List<BuildingCodeHistory__c> buildingCdHistList = selectBuildingCdHist(updMap.keySet());
        
        // 情報更新日を設定
        for (BuildingCodeHistory__c buildingCdHist : buildingCdHistList) {
            buildingCdHist.InformationUpdateDate__c = updMap.get(buildingCdHist.HistoryMaintenanceBuildingCode__c);
        }
        
        // 建物コード履歴の更新
        if (buildingCdHistList.size() > 0) {
            SecureDML.secureUpdate(buildingCdHistList);
        }
    }

    /**
     * 物件コード履歴の更新
     * @param Map<String, t_auto_maintenance_difference__c> updInfoMap 更新情報（key:メンテナンス物件コード、key:自動メンテナンス差分）
     */
    private static void updatePropertyCdHist(Map<String, t_auto_maintenance_difference__c> updInfoMap) {

        // 名寄せ先のMAPの作成(key:物件ID、value：物件)
        Set<Id> mergeDestinationIdSet = convInfo.getPropertyIds(updInfoMap.keySet());

        // 物件コード履歴の取得
        // ※物件更新処理で物件コード履歴の親レコードが更新された場合は1件、子レコードが更新された場合は2件
        List<PropertyCodeHistory__c> propertyCdHistList = selectPropertyCdHist(updInfoMap.keySet()
                                                                               , mergeDestinationIdSet);

        // 物件コード履歴の更新値設定
        for (PropertyCodeHistory__c propertyCdHist : propertyCdHistList) {

            // 自動メンテナンス差分のメンテナンス物件コードの取得
            String keyMaintPropCd = propertyCdHist.HistoryMaintenancePropertyCode__c;
            if (!updInfoMap.containsKey(keyMaintPropCd)) {
                keyMaintPropCd = convInfo.getMaintPropertyCd(propertyCdHist.HistoryProperty__c);
            }

            // 名寄せ先のCrowデータチェック
            if (propertyCdHist.HistoryImportDestination__c != null
                && propertyCdHist.HistoryMaintenancePropertyCode__c != keyMaintPropCd) {
                continue;
            }

            // 自動メンテナンス差分情報の取得
            t_auto_maintenance_difference__c mergeOriginalVal = updInfoMap.get(keyMaintPropCd);

            // 取込先
            String importType = CommonConst.PROPERTY_IMPORTTYPE_REALNETPRO;
            if (mergeOriginalVal.ExternalSiteCd__c == CommonConst.AUTOMAINTEDIFF_SITECODE_DAIWALIVING) {
                importType = CommonConst.PROPERTY_IMPORTTYPE_DAIWALIVING;
            }

            // 更新情報
            propertyCdHist.HistoryImportDestination__c = importType;                            // 取込先
            propertyCdHist.InformationUpdateDate__c    = mergeOriginalVal.InfoModifiedDate__c;  // 情報更新日
            propertyCdHist.HistoryPropertyDetailUrl__c = mergeOriginalVal.PropertyDetailUrl__c; // 履歴物件詳細画面URL
        }
        
        // 物件コード履歴の更新
        if (propertyCdHistList.size() > 0) {
            SecureDML.secureUpdate(propertyCdHistList);
        }
    }

    /**
     * 業者作成・更新
     * @param   Set<String>         SupplierCodeSet         業者のメンテナンスコード
     * @param   t_auto_maintenance_difference__c[]  newObjs 対象の自動メンテナンス差分
     * @return  Map<String, Account>                        更新対象の業者Map
     */
    private static Map<String, Account> upsertSupplier(Set<String> SupplierCodeSet, t_auto_maintenance_difference__c[] newObjs) {
        
        // 都道府県リスト作成（システム設定より取得）
        List<String> stateList = STATE_ALL.split(STATE_SEPARATOR);

        // 業者取得
        List<Account> supplierList = selectSupplierList(SupplierCodeSet);
        Map<String, Account> databaseSupplierMap = new Map<String, Account>();
        for (Account obj: supplierList) {
            databaseSupplierMap.put(obj.MaintenanceSupplierCode__c, obj);
        }

        // 業者登録情報作成
        List<Account> nmSupplierList = new List<Account>();
        Map<String, Account> upsertSupplierMap = new Map<String, Account>();
        for (t_auto_maintenance_difference__c obj : newObjs) {
            Account supplier = new Account();

            // メンテナンス業者コードが存在しない場合はスキップ
            if (obj.MaintenanceSupplierCode__c == null) {
                continue;
            }

            // 条件変更の場合、更新対象外
            if (obj.AutoMaintenanceType__c == CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_CHANGE_CONDITION) {
                continue;
            }

            // 登録データ作成　※業者メンテナンスコメントを確認し、既に作成済みの場合は処理不要
            if (!upsertSupplierMap.containsKey(obj.MaintenanceSupplierCode__c)) {
                // 既存値取得
                if (databaseSupplierMap.containsKey(obj.MaintenanceSupplierCode__c)) {
                    supplier = databaseSupplierMap.get(obj.MaintenanceSupplierCode__c);
                }

                // 業者項目設定
                IsUpsert     = false;
                IsNameMearge = false;
                // 更新値設定
                supplier = setSupplierData(supplier, obj, stateList);
                if (IsUpsert) {
                    upsertSupplierMap.put(obj.MaintenanceSupplierCode__c, supplier);
                }

                // 名寄せ検索対象追加
                if (IsNameMearge) {
                    nmSupplierList.add(supplier);
                }
            }
        }

        // 名寄せフラグ設定
        if (nmSupplierList.size() > 0) {
            NameMergeUtil.setAccountMergeCompletedFlag(nmSupplierList);
        }

        // 業者の登録
        if (upsertSupplierMap.size() > 0) {
            SecureDML.secureUpsert(upsertSupplierMap.values());
        }

        // 業者登録後データ再取得 ※keyはメンテナンス業者コード
        supplierList = selectSupplierList(SupplierCodeSet);
        upsertSupplierMap = new Map<String, Account>();
        for (Account obj : supplierList) {
            upsertSupplierMap.put(obj.MaintenanceSupplierCode__c, obj);
        }
        return upsertSupplierMap;
    }
    

    /**
     * 物件作成・更新
     * @param   Set<String>         PropertyCodeSet         物件のメンテナンスコード
     * @param   t_auto_maintenance_difference__c[]  newObjs 対象の自動メンテナンス差分
     * @param   Map<String, Account    > upsertSupplierMap  更新対象の業者Map
     * @param   Map<String, Building__c> upsertBuildingMap  更新対象の建物Map
     * @param   Map<String, Building__c> databaseBuildingMap 既存の建物Map
     * @param   Map<String, String     > changeAutoMaintenanceMessageMap 駐車場種別相違メッセージ取得
     * @return  Map<String, Property__c>                    更新対象の物件Map
     */
    private static Map<String, Property__c> upsertProperty(Set<String> PropertyCodeSet, t_auto_maintenance_difference__c[] newObjs
                                                            ,Map<String, Property__c> databasePropertyMap
                                                            ,Map<String, Account    > upsertSupplierMap
                                                            ,Map<String, Building__c> upsertBuildingMap
                                                            ,Map<String, Building__c> databaseBuildingMap
                                                            ,Map<String, String> changeAutoMaintenanceMessageMap ) {

        // 物件コード履歴更新値マップ（key:メンテナンス物件コード、value:自動メンテナンス差分）
        Map<String, t_auto_maintenance_difference__c> updPropertyHistCdMap = new Map<String, t_auto_maintenance_difference__c>();

        // 物件UPSERT作成
        List<Property__c> nmPropertyList = new List<Property__c>();
        Map<String, Property__c> upsertPropertyMap = new Map<String, Property__c>();
        // List<t_auto_maintenance_difference__c> updateDiffList = new List<t_auto_maintenance_difference__c>();
        for (t_auto_maintenance_difference__c diffObj : newObjs) {
            // メンテナンス物件コードが存在しない場合はスキップ
            if (diffObj.MaintenancePropertyCode__c == null) {
                continue;
            }

            // 物件コード履歴の更新値を設定
            updPropertyHistCdMap.put(diffObj.MaintenancePropertyCode__c, diffObj);

            // 登録データ作成　※メンテナンス物件コードを確認し、既に登録データ作成済みの場合は処理不要
            if (!upsertPropertyMap.containskey(diffObj.MaintenancePropertyCode__c)) {

                // 既存データ設定
                Property__c propData = new Property__c();
                if (databasePropertyMap.containskey(diffObj.MaintenancePropertyCode__c)) {
                    propData = databasePropertyMap.get(diffObj.MaintenancePropertyCode__c);
                }

                IsUpsert = false;

                // 建物ID ※メンテナンス区分：物件新規,掲載終了で建物IDが存在しない場合はエラーとする。
                Id buildingId = null;
                if (diffObj.MaintenanceBuildingCode__c != null && upsertBuildingMap.containsKey(diffObj.MaintenanceBuildingCode__c)) {
                    
                    // 新規物件の場合は自動メンテナンス建物ID、既存物件の場合は既存建物IDを設定
                    buildingId = upsertBuildingMap.get(diffObj.MaintenanceBuildingCode__c).Id;
                    if (propData.Id != null) {
                        buildingId = propData.Building__c;
                    }
                }

                // 掲載終了で建物IDが取得できていなければ建物IDをセットする。
                if (diffObj.AutoMaintenanceType__c == CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_POSTING_END && string.isBlank(buildingId)){
                    buildingId = propData.Building__c;
                }
                

                if (buildingId == null && 
                    (diffObj.AutoMaintenanceType__c == CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_PROPERTY_NEW || 
                     diffObj.AutoMaintenanceType__c == CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_POSTING_END)) {
                    BusinessLogicException ex = new BusinessLogicException();
                    ex.setMessage(CommonUtil.callMessageCreate(CommonConst.MSG_PROP_E_AUTOMAINTE_NONEBUILDING));
                    throw ex;
                }

                //既存の建物IDと新規に発行される建物IDが異なる場合は、自動メンテナンス差分の建物IDに登録
                if (buildingId != propData.Building__c && buildingId != null &&  propData.Building__c != null) {
                    AutoBuildingIdMap.put(diffObj.Id, propData.Building__c);
                }

                // 業者ID
                Id supplierId  = null;
                if (diffObj.MaintenanceSupplierCode__c != null && upsertSupplierMap.containsKey(diffObj.MaintenanceSupplierCode__c)) {
                    supplierId = upsertSupplierMap.get(diffObj.MaintenanceSupplierCode__c).Id;
                }
                

                // 更新値設定（総賃料計算の為、金額系項目は第三引数へも反映しています。）
                Property__c upsertPropData = new Property__c();
                boolean existsBuildingFlg = false;  // 建物の存在有無フラグ
                if(diffObj.AutoMaintenanceType__c == CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_POSTING_END){
                    // 掲載終了の場合trueとする。
                    existsBuildingFlg = true;
                }else{
                    // 掲載終了以外はメンテナンス建物コードの有無で判定をする。
                    existsBuildingFlg = databaseBuildingMap.containsKey(diffObj.MaintenanceBuildingCode__c);
                }
                upsertPropData = setPropertyData(buildingId, supplierId, propData, diffObj, existsBuildingFlg, databasePropertyMap.containskey(diffObj.MaintenancePropertyCode__c), changeAutoMaintenanceMessageMap);
                if (IsUpsert) {
                    // 総賃料計算（掲載終了以外）
                    if (diffObj.AutoMaintenanceType__c != CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_POSTING_END) {
                        upsertPropData.AllRentFee__c = getPropertyAllRent(diffObj, propData);
                    }
                    // 更新用のMapへ追加
                    upsertPropertyMap.put(diffObj.MaintenancePropertyCode__c , upsertPropData);
                }

                // 名寄せ検索対象設定
                if (upsertPropData.Id == null) {
                    nmPropertyList.add(upsertPropData);
                }
            }
        }
        // 名寄せフラグ設定
        if (nmPropertyList.size() > 0) {
            NameMergeUtil.setPropertyMergeCompletedFlag(nmPropertyList);
        }

        // 物件を登録
        if (upsertPropertyMap.size() > 0) {
            SecureDML.secureUpsert(upsertPropertyMap.values());

            // 登録された物件の変換情報を設定
            convInfo.setNewMaintPropertyCd(upsertPropertyMap.values());
        }

        // 物件コード履歴の更新
        if (updPropertyHistCdMap.size() > 0) {
            updatePropertyCdHist(updPropertyHistCdMap);
        }

        // 物件の登録後データ再取得 ※Keyはメンテナンスコード
        upsertPropertyMap = selectPropertyMap(PropertyCodeSet);

        return upsertPropertyMap;

    }


    /**
     * 総賃料計算
     * @param   t_auto_maintenance_difference__c    newObj      対象の自動メンテナンス差分
     * @param   Property__c                         property    対象の物件
     * @return  なし
     */
    private static Decimal getPropertyAllRent(t_auto_maintenance_difference__c newObj, Property__c property) {

        // 管理会社指定商品Map作成
        Set<String> maintPropCdSet = new Set<String>();
        maintPropCdSet.add(newObj.MaintenancePropertyCode__c);
        Map<String, List<ManagementCompanyItem__c>> databaseManagementCompanyItemMap = new Map<String, List<ManagementCompanyItem__c>>();
        databaseManagementCompanyItemMap = getManagementCompanyItemMap(maintPropCdSet);

        // 物件に紐づく管理会社指定商品取得
        List<ManagementCompanyItem__c> manageItemList = databaseManagementCompanyItemMap.get(newObj.MaintenancePropertyCode__c);
        if (manageItemList == null) {
            manageItemList = new List<ManagementCompanyItem__c>();
        }

        // 計算用
        Property__c calcProp = new Property__c();
        calcProp.RentFee__c                         = property.RentFee__c;
        calcProp.WortFee__c                         = property.WortFee__c;
        calcProp.WortFeeTaxType__c                  = property.WortFeeTaxType__c;
        calcProp.ManagementFee__c                   = property.ManagementFee__c;
        calcProp.ManagementFeeTaxType__c            = property.ManagementFeeTaxType__c;
        calcProp.CATVFee__c                         = property.CATVFee__c;
        calcProp.CATVTaxType__c                     = property.CATVTaxType__c;
        calcProp.TownshipFee__c                     = property.TownshipFee__c;
        calcProp.TownshipFeeTaxType__c              = property.TownshipFeeTaxType__c;
        calcProp.TownshipFeePaymentType__c          = property.TownshipFeePaymentType__c;
        calcProp.GarbageDisposalFee__c              = property.GarbageDisposalFee__c;
        calcProp.GarbageDisposalFeeTaxType__c       = property.GarbageDisposalFeeTaxType__c;
        calcProp.GarbageDisposalFeePaymentType__c   = property.GarbageDisposalFeePaymentType__c;
        calcProp.BicycleParkingFee__c               = property.BicycleParkingFee__c;
        calcProp.BicycleParkingFeeTaxType__c        = property.BicycleParkingFeeTaxType__c;
        calcProp.BicycleParkingType__c              = property.BicycleParkingType__c;
        calcProp.ParkingFee__c                      = property.ParkingFee__c;
        calcProp.ParkingFeeTaxType__c               = property.ParkingFeeTaxType__c;
        calcProp.ParkingType__c                     = property.ParkingType__c;
        calcProp.BikeParkingSmallFee__c             = property.BikeParkingSmallFee__c;
        calcProp.BikeParkingSmallFeeTaxType__c      = property.BikeParkingSmallFeeTaxType__c;
        calcProp.BikeParkingMediumFee__c            = property.BikeParkingMediumFee__c;
        calcProp.BikeParkingMediumFeeTaxType__c     = property.BikeParkingMediumFeeTaxType__c;
        calcProp.BikeParkinLargeFee__c              = property.BikeParkinLargeFee__c;
        calcProp.BikeParkinLargeFeeTaxType__c       = property.BikeParkinLargeFeeTaxType__c;
        calcProp.FireInsuranceUseType__c            = property.FireInsuranceUseType__c;
        calcProp.GuaranteeidCompanyType__c          = property.GuaranteeidCompanyType__c;

        // 火災保険情報の取得
        Item__c fireInsuranceItem;
        fireInsuranceItem = selectFireInsuranceItem(property.FireInsurancePlan__c);
        
        // 保証の情報を取得
        Item__c DepositItem;
        DepositItem = selectDepositItem(property.Guaranteeid__c);

        // 総賃料計算
        return BuildingPropertyUtil.calcAllRent(calcProp, manageItemList, fireInsuranceItem, DepositItem);

    }

    /**
     * 物件条件 作成・更新
     * @param   Set<String>         PropertyCodeSet         物件のメンテナンスコード
     * @param   t_auto_maintenance_difference__c[]  newObjs 対象の自動メンテナンス差分
     * @param   Map<String, Property__c> upsertPropertyMap  更新対象の物件Map
     * @param   Map<String, Building__c>　databaseBuildingMap  既存の建物Map
     * @param   Map<String, Property__c>　databasePropertyMap  既存の物件Map
     * @param   Map<String, String>       changeAutoMaintenanceMessageMap  設備と条件との相違メッセージ取得
     */
    private static void upsertPropertyCondition(Set<String> PropertyCodeSet, t_auto_maintenance_difference__c[] newObjs, Map<String, Property__c> upsertPropertyMap, Map<String, Building__c> databaseBuildingMap, Map<String, Property__c> databasePropertyMap, Map<String, String> changeAutoMaintenanceMessageMap) {
        
        // 物件条件の取得
        Set<Id> propertyIdSet = convInfo.getPropertyIds(PropertyCodeSet);
        List<PropertyConditions__c> propCondList = selectPropCond(propertyIdSet); 
        Map<String, PropertyConditions__c> propCondMap = new Map<String, PropertyConditions__c>();  // ※Keyは物件のメンテナンスコード
        
        // 物件条件のMap作成 
        for (PropertyConditions__c obj : propCondList) {
            propCondMap.put(convInfo.getMaintPropertyCd(obj.Property__c), obj);
        }

        // 物件条件の更新値
        List<PropertyConditions__c> upsertPropCondList = new List<PropertyConditions__c>();
        for (t_auto_maintenance_difference__c diffObj : newObjs) {
            PropertyConditions__c propCond = new PropertyConditions__c();

            // メンテナンス物件コードが存在しない場合はスキップ
            if (diffObj.MaintenancePropertyCode__c == null) {
                continue;
            }

            // 既存データ設定
            if (propCondMap.containsKey(diffObj.MaintenancePropertyCode__c)) {
                propCond = propCondMap.get(diffObj.MaintenancePropertyCode__c);
            }

            // 物件変更時、且つリアプロのみ
            if(diffObj.AutoMaintenanceType__c == CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_CHANGE_CONDITION
               && diffObj.ExternalSiteCd__c == CommonConst.AUTOMAINTEDIFF_SITECODE_REALNETPRO) {
                // 設備相違文言設定
                BuildingPropertyUtil.changeFacilityMessage(propCond, diffObj.Facility__c, diffObj.ExternalSiteCd__c
                                                           , ';', changeAutoMaintenanceMessageMap, diffObj.MaintenancePropertyCode__c);
            }

            // 項目値設定
            IsUpsert = false;
            // 物件のデータを取得できない場合は登録対象外
            if (upsertPropertyMap.containsKey(diffObj.MaintenancePropertyCode__c)) {
                Id propId = upsertPropertyMap.get(diffObj.MaintenancePropertyCode__c).Id;
                propCond = setPropCondData(propId, propCond, diffObj, databaseBuildingMap.containsKey(diffObj.MaintenanceBuildingCode__c), databasePropertyMap.containsKey(diffObj.MaintenancePropertyCode__c)
                                           , changeAutoMaintenanceMessageMap);
            }
            if (IsUpsert) {
                upsertPropCondList.add(propCond);
            }
        }
        if (upsertPropCondList.size() > 0) {
            SecureDML.secureUpsert(upsertPropCondList);
        }
    }    


    /**
     * 部屋 作成・更新
     * @param   t_auto_maintenance_difference__c[]  newObjs 対象の自動メンテナンス差分
     * @param   Map<String, Property__c> upsertPropertyMap  更新対象の物件Map
     */
    private static void insertRoom(t_auto_maintenance_difference__c[] newObjs, Map<String, Property__c> upsertPropertyMap, Map<String, Building__c> databaseBuildingMap, Map<String, Property__c> databasePropertyMap) {
        
        List<Room__c> upsertRoomList = new List<Room__c>();
        for (t_auto_maintenance_difference__c diffObj : newObjs) {
            List<Room__c> roomList = new List<Room__c>();

            // メンテナンス物件コードが存在しない場合はスキップ
            if (diffObj.MaintenancePropertyCode__c == null) {
                continue;
            }

            // 大和リビングの場合はスキップ
            if(diffObj.ExternalSiteCd__c == CommonConst.AUTOMAINTEDIFF_SITECODE_DAIWALIVING) {
                continue;  
            }

            // 新規以外は登録対象外
            if (databaseBuildingMap.containsKey(diffObj.MaintenanceBuildingCode__c) &&
                databasePropertyMap.containsKey(diffObj.MaintenancePropertyCode__c)) {
                continue;
            } 

            // 部屋の登録データ作成 ※物件のデータを取得できない場合は登録対象外
            if (upsertPropertyMap.containsKey(diffObj.MaintenancePropertyCode__c)) {
                roomList = setRoomData(upsertPropertyMap.get(diffObj.MaintenancePropertyCode__c).Id, diffObj);
                if (roomList.size() > 0) {
                    upsertRoomList.addAll(roomList);
                }
            }
        }
        
        // 部屋の登録
        if (upsertRoomList.size() > 0) {
            SecureDML.secureUpsert(upsertRoomList);
        }

    }

    /**
     * 建物Map取得
     * @param   Set<String>              メンテナンス建物コード
     * @return  Map<String, Building__c> 建物MAP
     */
    private static Map<String, Building__c> getBuildingMap(Set<String> BuildingCodeSet) {
        return selectBuildingMap(BuildingCodeSet);
    }

    /**
     * 物件Map取得
     * @param   Set<String>              メンテナンス物件コード
     * @return  Map<String, Property__c> 物件MAP
     */
    private static Map<String, Property__c> getPropertyMap(Set<String> PropertyCodeSet) {
        return selectPropertyMap(PropertyCodeSet);
    }

    /**
     * 業者Map取得
     * @param   Set<String>          メンテナンス業者コード
     * @return  Map<String, Account> 業者Map
     */
    private static Map<String, Account> getSupplierMap(Set<String> supplierCodeSet) {
        Map<String, Account> supplierMap = new Map<String, Account>();
        List<Account> supplierList       = selectSupplierList(supplierCodeSet);
        for (Account obj : supplierList) {
            supplierMap.put(obj.MaintenanceSupplierCode__c, obj);
        }
        return supplierMap;
    }

    /**
     * 物件写真Map
     * @param   Set<String> propertyCodeSet   メンテナンス物件コード
     * @return  Map<String, PropertyPhoto__c> 物件写真MAP
     */
    private static Map<String, PropertyPhoto__c> getPropPhotoMap(Set<String> propertyCodeSet) {

        // 物件写真の取得
        Set<Id> propertyIdSet = convInfo.getPropertyIds(propertyCodeSet);
        List<PropertyPhoto__c> propertyPhotoList = selectPropertyPotoList(propertyIdSet);

        // 物件写真マップの作成（key:メンテナンス物件コード、value:物件写真）
        Map<String, PropertyPhoto__c> propPhotoMap = new Map<String, PropertyPhoto__c>();
        for (PropertyPhoto__c obj : propertyPhotoList) {
            propPhotoMap.put(convInfo.getMaintPropertyCd(obj.Property__c), obj);
        }
        return propPhotoMap;
    }

    /**
     * 建物写真Map
     * @param   Set<String> buildingCodeSet メンテナンス建物コード
     * @return  Map<String, BuildingPhoto__c> 物件写真MAP
     */
    private static Map<String, BuildingPhoto__c> getBuildPhotoMap(Set<String> buildingCodeSet) {

        // 建物写真の取得
        Set<Id> buildingIdSet = convInfo.getBuildingIds(buildingCodeSet);
        List<BuildingPhoto__c> buildingPhotoList = selectBuildingPhotoList(buildingIdSet);
        
        // 建物写真のマップ作成（key:メンテナンス建物コード、value:建物写真）
        Map<String, BuildingPhoto__c> buildPhotoMap = new Map<String, BuildingPhoto__c>();
        for (BuildingPhoto__c obj : buildingPhotoList) {
            buildPhotoMap.put(convInfo.getMaintBuildingCd(obj.Building__c), obj);
        }
        return buildPhotoMap;
    }

    /**
     * 管理会社指定商品Map取得
     * @param   Set<String> maintPropCdSet                  メンテナンス物件コード
     * @return  Map<String, List<ManagementCompanyItem__c>> 物件MAP
     */
    private static Map<String, List<ManagementCompanyItem__c>> getManagementCompanyItemMap(Set<String> maintPropCdSet) {
        Map<String, List<ManagementCompanyItem__c>> ManagementCompanyItemListMap = new Map<String, List<ManagementCompanyItem__c>>();

        // 物件管理会社指定商品の取得
        Set<Id> propertyId = convInfo.getPropertyIds(maintPropCdSet);
        List<PropertyManageCompayItem__c> PropertyManageCompayItemList = selectPropertyManageCompayItemList(propertyId);
       
        Set<Id> ManagementCompanyItemId = new Set<Id>();
        for (PropertyManageCompayItem__c PropertyManageCompayItem : PropertyManageCompayItemList) {
            ManagementCompanyItemId.add(PropertyManageCompayItem.Item__c);
        }
        List<ManagementCompanyItem__c> AllManagementCompanyItemList = [SELECT Id, PaymentType__c, AmountTax__c FROM ManagementCompanyItem__c WHERE Id IN :ManagementCompanyItemId];
 
        Map<Id, ManagementCompanyItem__c> ManagementCompanyItemMap = new  Map<Id, ManagementCompanyItem__c>();
        for(ManagementCompanyItem__c manageItem : AllManagementCompanyItemList){
            ManagementCompanyItemMap.put(manageItem.id, manageItem);
        }
 
         for(String maintenancePropertyCode : maintPropCdSet){
             List<ManagementCompanyItem__c> ManagementCompanyItemList = new List<ManagementCompanyItem__c>();
             
             for (PropertyManageCompayItem__c obj : PropertyManageCompayItemList) {
                 if(maintenancePropertyCode == obj.Property__r.MaintenancePropertyCode__c){
                     //管理会社指定商品設定
                    ManagementCompanyItemList.add(ManagementCompanyItemMap.get(obj.Item__c));
                 }
             }
            ManagementCompanyItemListMap.put(maintenancePropertyCode, ManagementCompanyItemList);
         }
         return ManagementCompanyItemListMap;
    }

    /**
     * 建物写真・物件写真の移動・登録処理
     * @param   t_auto_maintenance_difference__c[]  newObjs 対象の自動メンテナンス差分
     * @param   Map<String, Property__c>        buildingMap      建物Map
     * @param   Map<String, Property__c>        propertyMap      物件Map
     * @param   Map<String, Account>            supplierMap      業者Map
     * @param   Map<String, PropertyPhoto__c>   propPhotoMap     物件写真Map
     * @param   Map<String, BuildingPhoto__c>   buildingPhotoMap 建物写真Map
     */
    private static void moveBuildingPropertyPhoto(t_auto_maintenance_difference__c[] newObjs, Map<String, Building__c> buildingMap, Map<String, Property__c> propertyMap,  Map<String, Account> supplierMap, Map<String, PropertyPhoto__c> propPhotoMap, Map<String, BuildingPhoto__c> buildingPhotoMap) {
        List<AmazonS3Util.AutoMaintePhotoMoveParameter> s3MovePhotoList = new List<AmazonS3Util.AutoMaintePhotoMoveParameter>();

        // 建物写真のリスト作成
        List<AmazonS3Util.AutoMaintePhotoMoveParameter> buildingPhotoList = setBuildingPhotoMoveList(newObjs, buildingMap, buildingPhotoMap);
        if (buildingPhotoList.size() > 0) {
            s3MovePhotoList.addAll(buildingPhotoList);
        }

        // 物件写真のリスト作成
        List<AmazonS3Util.AutoMaintePhotoMoveParameter> porpPhotoList = setPropertyPhotoMoveList(newObjs, propertyMap, propPhotoMap);
        if (porpPhotoList.size() > 0) {
            s3MovePhotoList.addAll(porpPhotoList);
        }

        // 物件写真のリスト作成　※建物がつけ変わったもののみ
        s3PhotoMoveNoneDbUpdate(newObjs, propertyMap, propPhotoMap);

        // 写真移動 & 物件写真 & 建物写真作成
        if (s3MovePhotoList.size() > 0 && !Test.isRunningTest()) {
            AmazonS3Util.callPhotoMoveAutoMainte(s3MovePhotoList);
        }

        // 写真移動 エラーメッセージ作成
        if (s3MovePhotoList.size() > 0) {
            insertErrorAutoMaintenanceMovePhoto(s3MovePhotoList, buildingMap, propertyMap, supplierMap);
        }
    }

    /**
     * 物件写真移動命令　※DB変更なし
     */
    private static void s3PhotoMoveNoneDbUpdate(t_auto_maintenance_difference__c[] newObjs, Map<String, Property__c> propertyMap, Map<String, PropertyPhoto__c> propPhotoMap) {
        // 移動情報
        List<String> fromPhotoPathList = new List<String>();
        List<String> toPhotoPathList   = new List<String>();
        String fileName;

        // 旧物件IDの物件情報を取得
        Set<Id> buildingSetId = new Set<Id>();
        for (t_auto_maintenance_difference__c obj : newObjs) {
            if (obj.BuildingId__c != null) {
                buildingSetId.add(obj.BuildingId__c);
            }
        }
        // 対象データなしであれば処理終了
        if (buildingSetId.size() == 0) {
            return;
        }

        // 旧物件の情報取得
        List<Building__c> builsingList = [SELECT Id, ForeignID__c FROM Building__c WHERE Id = :buildingSetId];
        Map<String, Building__c> oldBuildingMap = new Map<String, Building__c>();
        for (Building__c obj : builsingList) {
            oldBuildingMap.put(obj.Id, obj);
        }

        // 移動リスト作成
        for (t_auto_maintenance_difference__c obj : newObjs) {
            // スキップ
            if (obj.MaintenancePropertyCode__c == null ||                       // メンテナンス物件コードNULL
                obj.BuildingId__c              == null ||                       // 旧建物IDが空
                !oldBuildingMap.containsKey(obj.BuildingId__c) ||               // 旧建物がない
                !propertyMap.containsKey(obj.MaintenancePropertyCode__c) ||     // 物件がなし
                !propPhotoMap.containsKey(obj.MaintenancePropertyCode__c)){     // 物件写真が存在しない
                continue;
            }

            // 新・旧 外部IDを取得
            String prevBuildingForeignId = oldBuildingMap.get(obj.BuildingId__c).ForeignID__c;
            String newBuildingForeignId  = propertyMap.get(obj.MaintenancePropertyCode__c).Building__r.ForeignID__c;
            String propForeignId         = propertyMap.get(obj.MaintenancePropertyCode__c).ForeignID__c;
            
            PropertyPhoto__c propPhoto = propPhotoMap.get(obj.MaintenancePropertyCode__c);
            // 物件写真
            for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PROPERTY; i++) {
                fileName = (String)propPhoto.get('PropertyPhotoFileName' + i + '__c');
                if (String.isEmpty(fileName)){
                    break;
                }
                // 移動対象のパス追加
                fromPhotoPathList.add(S3FOLDERPATH_BUILDING_PROPERTY + prevBuildingForeignId + '/' + propForeignId + '/' + fileName);
                toPhotoPathList.add(S3FOLDERPATH_BUILDING_PROPERTY + newBuildingForeignId + '/' + propForeignId + '/' + fileName);
            }
            // 非公開写真
            for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PRIVATE; i++) {
                fileName = (String)propPhoto.get('PrivatePhotoFileName' + i + '__c');
                if (String.isEmpty(fileName)){
                    break;
                }
                // 移動対象のパス追加
                fromPhotoPathList.add(S3FOLDERPATH_BUILDING_PROPERTY + prevBuildingForeignId + '/' + propForeignId + '/' + fileName);
                toPhotoPathList.add(S3FOLDERPATH_BUILDING_PROPERTY + newBuildingForeignId + '/' + propForeignId + '/' + fileName);
            }
            // パノラマ写真
            for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PANORAMA; i++) {
                fileName = (String)propPhoto.get('PanoramaFileName' + i + '__c');
                if (String.isEmpty(fileName)){
                    break;
                }
                // 移動対象のパス追加
                fromPhotoPathList.add(S3FOLDERPATH_BUILDING_PROPERTY + prevBuildingForeignId + '/' + propForeignId + '/' + fileName);
                toPhotoPathList.add(S3FOLDERPATH_BUILDING_PROPERTY + newBuildingForeignId + '/' + propForeignId + '/' + fileName);
            }
            // 間取り
            fileName = (String)propPhoto.get('RoomLayoutFileName__c');
            if (!String.isEmpty(fileName)){
                fromPhotoPathList.add(S3FOLDERPATH_BUILDING_PROPERTY + prevBuildingForeignId + '/' + propForeignId + '/' + fileName);
                toPhotoPathList.add(S3FOLDERPATH_BUILDING_PROPERTY + newBuildingForeignId + '/' + propForeignId + '/' + fileName);
            }
            // // 間取りメモ
            fileName = (String)propPhoto.get('RoomLayoutMemoFileName__c');
            if (!String.isEmpty(fileName)){
                fromPhotoPathList.add(S3FOLDERPATH_BUILDING_PROPERTY + prevBuildingForeignId + '/' + propForeignId + '/' + fileName);
                toPhotoPathList.add(S3FOLDERPATH_BUILDING_PROPERTY + newBuildingForeignId + '/' + propForeignId + '/' + fileName);
            }
        }
        if (fromPhotoPathList.size() > 0) {
            AmazonS3Util.callS3PhotoMoveNonDBUpdate(fromPhotoPathList, toPhotoPathList);
        }
    }

    /**
     * 建物写真の移動命令用List作成
     * @param   t_auto_maintenance_difference__c[]  newObjs 対象の自動メンテナンス差分
     * @param   Map<String, Property__c> buildingMap            更新対象の建物Map
     * @param   Map<String, BuildingPhoto__c> buildingPhotoMap  更新対象の建物写真Map
     */
    private static List<AmazonS3Util.AutoMaintePhotoMoveParameter> setBuildingPhotoMoveList(t_auto_maintenance_difference__c[] newObjs, Map<String, Building__c> buildingMap, Map<String, BuildingPhoto__c> buildingPhotoMap) {
        List<AmazonS3Util.AutoMaintePhotoMoveParameter> s3MovePhotoList = new List<AmazonS3Util.AutoMaintePhotoMoveParameter>();
        
        for (t_auto_maintenance_difference__c obj : newObjs) {
            // スキップ
            if (obj.MaintenanceBuildingCode__c == null ||                                               // メンテナンス建物コードがNULL
                obj.AutoMaintenanceType__c     != CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_NEW ||      // 新規登録以外
                !buildingMap.containsKey(obj.MaintenanceBuildingCode__c) ||                             // 建物が存在しない
                buildingPhotoMap.containsKey(obj.MaintenanceBuildingCode__c)) {                         // 建物写真が既に存在する
                continue;
            }

            // 大和リビングはスキップ
            if (obj.ExternalSiteCd__c == CommonConst.AUTOMAINTEDIFF_SITECODE_DAIWALIVING) {         
                continue;
            }

            // 自動メンテナンス用写真移動クラス作成
            Id buildingId    = buildingMap.get(obj.MaintenanceBuildingCode__c).Id;
            String foreignId = buildingMap.get(obj.MaintenanceBuildingCode__c).ForeignID__c;
            AmazonS3Util.AutoMaintePhotoMoveParameter autoPhotoMove = new AmazonS3Util.AutoMaintePhotoMoveParameter(buildingId, foreignId, obj);

            // クローリング写真フォルダパス
            String fromFolderPath = getCrowlingFolderPath(obj);

            // 写真設定
            Integer surroundingIdx = 1;
            for (Integer i = 1; i <= MAX_BUILDING_PHOTO_COUNT; i++) {
                String fromFileName = (String)obj.get('BuildingPhotoFileName' + i + '__c');
                String fromTag      = (String)obj.get('BuildingTag' + i + '__c');
                String fromComment  = ''; //写真コメントは連携しないことになりました。(2020.0528)

                // データが存在しなければ、処理終了
                if (String.isEmpty(fromFileName) && String.isEmpty(fromTag) && String.isEmpty(fromComment)){
                    break;
                }

                // 移動元のファイルパス生成
                String fromFilePath = CommonConst.STRING_EMPTY;
                if (!String.isEmpty(fromFileName)) {
                    fromFilePath = String.join(new List<String>{fromFolderPath, fromFileName}, '');
                }

                // AmazonS3Util.PhotoType設定
                Integer toIndex = 0;
                AmazonS3Util.PhotoType photoType;
                if (fromTag == CommonConst.AUTOMAINTDIFF_BUILDINGPHOTOTAG_APPEARANCE) {                 // 建物外観
                    photoType = AmazonS3Util.PhotoType.BUILDING_APPEARANCE;
                } else if(fromTag == CommonConst.AUTOMAINTDIFF_BUILDINGPHOTOTAG_APPEARANCE_PARSE) {     // 外観パース
                    photoType = AmazonS3Util.PhotoType.BUILDING_APPEARANCEPARSE;
                } else if(fromTag == CommonConst.AUTOMAINTDIFF_BUILDINGPHOTOTAG_ENTRANCE) {             // エントランス
                    photoType = AmazonS3Util.PhotoType.BUILDING_ENTRANCE;
                } else if(fromTag == CommonConst.AUTOMAINTDIFF_BUILDINGPHOTOTAG_LOBBY) {                // ロビー
                    photoType =  AmazonS3Util.PhotoType.BUILDING_LOBBY;  
                } else if(fromTag == CommonConst.AUTOMAINTDIFF_BUILDINGPHOTOTAG_PARKING) {              // 駐車場
                    photoType =  AmazonS3Util.PhotoType.BUILDING_PARKING;
                } else if(fromTag == CommonConst.AUTOMAINTDIFF_BUILDINGPHOTOTAG_MAP) {                  // 地図
                    photoType =  AmazonS3Util.PhotoType.BUILDING_MAP;
                } else if(fromTag == CommonConst.AUTOMAINTDIFF_BUILDINGPHOTOTAG_OTHERSHARING) {         // その他共有部分
                    photoType =  AmazonS3Util.PhotoType.BUILDING_OTHERSHARING;
                } else if(fromTag == CommonConst.AUTOMAINTDIFF_BUILDINGPHOTOTAG_SURROUNDING) {          // 周辺写真
                    if (surroundingIdx > MAX_BUILDING_PHOTO_SURROUNDING_COUNT) {
                        continue;
                    }
                    photoType =  AmazonS3Util.PhotoType.BUILDING_SURROUNDING;
                    toIndex = surroundingIdx;
                    surroundingIdx++;
                } else {                                                                                // その他
                    photoType =  AmazonS3Util.PhotoType.BUILDING_OTHER;
                }

                // 写真移動パラメタ追加
                AmazonS3Util.AutoMaintePhotoMoveDataParameter photo = new AmazonS3Util.AutoMaintePhotoMoveDataParameter(fromFilePath, fromComment, null, toIndex, photoType);
                autoPhotoMove.photoList.add(photo);
            }
            s3MovePhotoList.add(autoPhotoMove);
        }
        return s3MovePhotoList;
    }

    /**
     * 物件写真の移動命令List作成
     * @param   t_auto_maintenance_difference__c[]  newObjs 対象の自動メンテナンス差分
     * @param   Map<String, Property__c> propertyMap   物件Map
     * @param   Map<String, Property__c> propPhotoMap  物件写真Map
     */
    private static List<AmazonS3Util.AutoMaintePhotoMoveParameter> setPropertyPhotoMoveList(t_auto_maintenance_difference__c[] newObjs, Map<String, Property__c> propertyMap, Map<String, PropertyPhoto__c> propPhotoMap) {
            List<AmazonS3Util.AutoMaintePhotoMoveParameter> s3MovePhotoList = new List<AmazonS3Util.AutoMaintePhotoMoveParameter>();

        for (t_auto_maintenance_difference__c obj : newObjs) {
            // スキップ
            if (obj.MaintenancePropertyCode__c == null ||                    // メンテナンス物件コードNULL
               !propertyMap.containsKey(obj.MaintenancePropertyCode__c)) {   // 物件
                continue;
            }

            // 自動メンテナンス用写真移動クラス作成
            Id PropertyId    = propertyMap.get(obj.MaintenancePropertyCode__c).Id;
            String foreignId = propertyMap.get(obj.MaintenancePropertyCode__c).Building__r.ForeignID__c + '/'
                             + propertyMap.get(obj.MaintenancePropertyCode__c).ForeignID__c;
            AmazonS3Util.AutoMaintePhotoMoveParameter autoPhotoMove = new AmazonS3Util.AutoMaintePhotoMoveParameter(PropertyId, foreignId, obj);

            // クローリング写真フォルダパス
            String fromFolderPath = getCrowlingFolderPath(obj);

            // 新規の場合（写真の登録がない場合）
            if (!propPhotoMap.containsKey(obj.MaintenancePropertyCode__c)) {
                for (Integer i = 1; i <= MAX_PROPERTY_PHOTO_COUNT; i++) {
                    String fromFileName = (String)obj.get('PropertyPhotoFileName' + i + '__c');
                    String fromTag      = (String)obj.get('PropertyTag' + i + '__c');
                    String fromComment  = ''; //写真コメントは連携しないことになりました。(2020.0528)

                    // データが存在しなければ、処理終了
                    if (String.isEmpty(fromFileName) && String.isEmpty(fromTag) && String.isEmpty(fromComment)){
                        break;
                    }

                    // 移動元のファイルパス生成
                    String fromFilePath;
                    if (!String.isEmpty(fromFileName)) {
                        fromFilePath = String.join(new List<String>{fromFolderPath, fromFileName}, '');
                    }

                    // 物件写真タグ設定
                    String settingTag;
                    if (fromTag == CommonConst.AUTOMAINTEDIFF_PROPERTYPHOTOTAG_LIVING) {                // 居室・リビング
                        settingTag = CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_LIVING;
                    } else if (fromTag == CommonConst.AUTOMAINTEDIFF_PROPERTYPHOTOTAG_OTHERROOM) {      // その他部屋・スペース
                        settingTag = CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_OTHERROOM;
                    } else if (fromTag == CommonConst.AUTOMAINTEDIFF_PROPERTYPHOTOTAG_KITCHEN) {        // キッチン
                        settingTag = CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_KITCHEN;
                    } else if (fromTag == CommonConst.AUTOMAINTEDIFF_PROPERTYPHOTOTAG_BATH) {           // バス・シャワールーム
                        settingTag = CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_BATH;
                    } else if (fromTag == CommonConst.AUTOMAINTEDIFF_PROPERTYPHOTOTAG_TOILET) {         // トイレ
                        settingTag = CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_TOILET;
                    } else if (fromTag == CommonConst.AUTOMAINTEDIFF_PROPERTYPHOTOTAG_WASHROOM) {       // 洗面設備
                        settingTag = CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_WASHROOM;
                    } else if (fromTag == CommonConst.AUTOMAINTEDIFF_PROPERTYPHOTOTAG_STORAGE) {        // 収納
                        settingTag = CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_STORAGE;
                    } else if (fromTag == CommonConst.AUTOMAINTEDIFF_PROPERTYPHOTOTAG_BALCONY) {        // バルコニー
                        settingTag = CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_BALCONY;
                    } else if (fromTag == CommonConst.AUTOMAINTEDIFF_PROPERTYPHOTOTAG_GARDEN) {         // 庭
                        settingTag = CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_GARDEN;
                    } else if (fromTag == CommonConst.AUTOMAINTEDIFF_PROPERTYPHOTOTAG_ENTRANCE) {       // 玄関
                        settingTag = CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_ENTRANCE;
                    } else if (fromTag == CommonConst.AUTOMAINTEDIFF_PROPERTYPHOTOTAG_SECURITY) {       // セキュリティ
                        settingTag = CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_SECURITY;
                    } else if (fromTag == CommonConst.AUTOMAINTEDIFF_PROPERTYPHOTOTAG_OTHERFACILITY) {  // その他設備
                        settingTag = CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_OTHERFACILITY;
                    } else if (fromTag == CommonConst.AUTOMAINTEDIFF_PROPERTYPHOTOTAG_VIEW) {           // 眺望
                        settingTag = CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_VIEW;
                    } else {                                                                            // その他
                        settingTag = CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_OTHER;
                    }

                    // 写真移動の共通部品クラスに格納
                    AmazonS3Util.AutoMaintePhotoMoveDataParameter photo = new AmazonS3Util.AutoMaintePhotoMoveDataParameter(fromFilePath, fromComment, settingTag, i, AmazonS3Util.photoType.PROPERTY);
                    autoPhotoMove.photoList.add(photo);
                }
            }

            // 間取り
            PropertyPhoto__c propPhotoData = new PropertyPhoto__c();
            if (propPhotoMap.containsKey(obj.MaintenancePropertyCode__c)){
                propPhotoData = propPhotoMap.get(obj.MaintenancePropertyCode__c);
            }
            if (obj.RoomLayoutFileName__c != null && propPhotoData.RoomLayoutFileName__c == null) {
                String fromFilePath = String.join(new List<String>{fromFolderPath, obj.RoomLayoutFileName__c}, '');
                AmazonS3Util.AutoMaintePhotoMoveDataParameter photo = new AmazonS3Util.AutoMaintePhotoMoveDataParameter(fromFilePath, null, null, AmazonS3Util.PhotoType.PROPERTY_ROOMLAYOUT);
                autoPhotoMove.photoList.add(photo);
                s3MovePhotoList.add(autoPhotoMove);
            }
        }
        return s3MovePhotoList;
    }

    /**
     * 自動メンテナンス作成（写真移動エラー）
     * @param   List<AmazonS3Util.AutoMaintePhotoMoveParameter> 自動メンテナンス差分写真移動パラメタ
     */
    private static void insertErrorAutoMaintenanceMovePhoto(List<AmazonS3Util.AutoMaintePhotoMoveParameter> photoMoveList, Map<String, Building__c> buildingMap, Map<String, Property__c> propertyMap,  Map<String, Account> supplierMap) {
        List<t_auto_maintenance_difference__c> errorList = new List<t_auto_maintenance_difference__c>();
        PhotoMoveErroMap = new Map<Id, String>();   // ※エラーMap
        for (AmazonS3Util.AutoMaintePhotoMoveParameter photoMove : photoMoveList) {
            // S3削除エラー
            if (photoMove.isError) {
                errorList.add(photoMove.autoMainteDiff);
                PhotoMoveErroMap.put(photoMove.autoMainteDiff.Id, photoMove.errorMsg);
                continue;
            }
            // S3コピーエラー
            for (AmazonS3Util.AutoMaintePhotoMoveDataParameter photo : photoMove.photoList) {
                if (photo.isError && !PhotoMoveErroMap.containsKey(photoMove.autoMainteDiff.Id)) {
                    errorList.add(photoMove.autoMainteDiff);
                    PhotoMoveErroMap.put(photoMove.autoMainteDiff.Id, photo.errorMsg);
                }
            }
        }
        if (errorList.size() > 0) {
            insertErrorAutoMaintenance(errorList, PhotoMoveErroMap, buildingMap, propertyMap, supplierMap);
        }
    }

    /**
     * Suumoスコアの更新
     * @param   t_auto_maintenance_difference__c    newObjs             自動メンテナンス差分写真移動パラメタ
     * @param   Map<String, Property__c>            buildingMap         建物Map
     * @param   Map<String, BuildingPhoto__c>       buildPhotoMap       建物写真Map
     * @param   Map<String, Property__c>            propertyMap         物件Map
     * @param   Map<String, PropertyPhoto__c>       propPhotoMap        物件写真Map
     * @return  なし
     */
    private static void updateSuumoScore(t_auto_maintenance_difference__c[] newObjs, Map<String, Building__c> buildingMap, Map<String, BuildingPhoto__c> buildPhotoMap, Map<String, Property__c> propertyMap, Map<String, PropertyPhoto__c> propPhotoMap) {

        //スーモスコア計算
        List<Property__c> propList = new List<Property__c>();//スーモスコア更新用物件リスト
        for (t_auto_maintenance_difference__c obj : newObjs) {
            if(String.isBlank(obj.MaintenancePropertyCode__c) || obj.AutoMaintenanceType__c == CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_POSTING_END ){//メンテナンス物件コードがないもしくは掲載が終了している場合は計算を行わない
                continue;
            }
             Building__c build              = buildingMap.get(obj.MaintenanceBuildingCode__c);      // 建物
             BuildingPhoto__c BuildPhoto    = buildPhotoMap.get(obj.MaintenanceBuildingCode__c);    // 建物写真
             Property__c prop               = propertyMap.get(obj.MaintenancePropertyCode__c);      // 物件
             PropertyPhoto__c propPhoto     = propPhotoMap.get(obj.MaintenancePropertyCode__c);     // 物件写真

             Integer score = 0; //スーモスコア
             score = BuildingPropertyUtil.getSuumoScore(build, BuildPhoto, prop, propPhoto);
             propList.add(new Property__c(Id = prop.Id, Score__c = score));             
        }
        // 物件upsert
        if (propList.size() > 0) {
            SecureDML.secureUpdate(propList);
        }
    }

    /**
     * 建物物件差分の作成
     * @param   t_auto_maintenance_difference__c[]  newObjs 対象の自動メンテナンス差分
     * @param   Map<String, Property__c> propertyMap   物件Map
     */
    private static void upsertBuildingProeryDiff(t_auto_maintenance_difference__c[] newObjs, Map<String, Property__c> propertyMap) {
        Set<Id> propSetId = new Set<Id>();
        for (t_auto_maintenance_difference__c obj : newObjs) {
            if ((obj.AutoMaintenanceType__c == CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_CHANGE_CONDITION || 
                 obj.AutoMaintenanceType__c == CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_POSTING_END) && 
                propertyMap.containskey(obj.MaintenancePropertyCode__c) && 
                propertyMap.get(obj.MaintenancePropertyCode__c).WebPublishing__c == CommonConst.PROPERTY_WEBPUBLISHING_EXISTS &&
                !PhotoMoveErroMap.containskey(obj.Id)) {
                propSetId.add(propertyMap.get(obj.MaintenancePropertyCode__c).Id);
            }
        }
        if (propSetId.size() > 0) {
            BuildingPropertyUtil.createBuildingPropertyDifference(propSetId);
        }
    }

    /**
     * 自動メンテナンス差分の削除
     * @param   なし
     * @return  なし
     */
    private static void deleteAutoMaintenanceDifference(t_auto_maintenance_difference__c[] newObjs) {
        // 削除
        List<String> newObjsIdList = new List<String>();//自動メンテナンス差分今回処理対象のIdリスト
        for(t_auto_maintenance_difference__c newObj : newObjs){
            newObjsIdList.add(newObj.Id);
        }
        
        List<t_auto_maintenance_difference__c> deleteList = [
            SELECT Id
              FROM t_auto_maintenance_difference__c
             WHERE BatchStatus__c = :CommonConst.AUTOMAINTEDIFF_BATCHSTATUS_S
             AND Id IN :newObjsIdList
        ];
        
        if (deleteList.size() > 0 ) {
            SecureDML.secureDelete(deleteList);
        }
    }

    /**
     * 物件管理会社指定商品の削除
     * @param   Id  PropertyId  物件管理会社指定商品削除対象の物件ID
     * @return  なし
     */
    private static void deletePropertyManageCompayItem(Id PropertyId) {
        // 削除        
        List<PropertyManageCompayItem__c> deleteList = [
            SELECT Id
              FROM PropertyManageCompayItem__c
             WHERE Property__c = :PropertyId
        ];
        
        if (deleteList.size() > 0 ) {
            SecureDML.secureDelete(deleteList);
        }
    }

    /**
     * 自動メンテナンス登録処理
     * @param   t_auto_maintenance_difference__c[]  newObjs 対象の自動メンテナンス差分
     * @param   Map<String, Building__c> propertyMap   建物Map
     * @param   Map<String, Property__c> propertyMap   物件Map
     * @param   Map<String, Account__c>  propertyMap   元付業者Map
     */
     private static void insertAutoMaintenance(t_auto_maintenance_difference__c[] newObjs, Map<String, Building__c> buildingMap, Map<String, Property__c> propertyMap, Map<String, Account> supplierMap){
        List<AutoMaintenance__c> autoMaintList = new List<AutoMaintenance__c>();
        for (t_auto_maintenance_difference__c obj : newObjs) {
            if (PhotoMoveErroMap.containsKey(obj.Id)) {
                continue;
            }
            AutoMaintenance__c autoMaint = new AutoMaintenance__c();

            // 建物ID取得
            Id buildingId = null;
            if (obj.MaintenanceBuildingCode__c != null && buildingMap.containsKey(obj.MaintenanceBuildingCode__c)){
                buildingId = buildingMap.get(obj.MaintenanceBuildingCode__c).Id;
            }

            // 掲載終了で建物IDが取得できていなければ建物IDをセットする。
            if (obj.AutoMaintenanceType__c == CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_POSTING_END && string.isBlank(buildingId)){
                buildingId = propertyMap.get(obj.MaintenancePropertyCode__c).Building__c;
            }

            // 物件ID取得
            Id propertyId     = null;
            if (obj.MaintenancePropertyCode__c != null && propertyMap.containsKey(obj.MaintenancePropertyCode__c)){
                propertyId = propertyMap.get(obj.MaintenancePropertyCode__c).Id;
            }

            // 元付業者ID取得
            Id supplierId = null;
            if (obj.MaintenanceSupplierCode__c != null && supplierMap.containsKey(obj.MaintenanceSupplierCode__c)){
                supplierId = supplierMap.get(obj.MaintenanceSupplierCode__c).Id;
            }
            // 自動メンテナンス登録
            autoMaint = setAutoMaintData(buildingId, propertyId, supplierId, obj);
            autoMaintList.add(autoMaint);
        }
        if (autoMaintList.size() > 0) {
            SecureDML.secureInsert(autoMaintList);
        }
    }

    /**
     * 自動メンテナンス差分ステータス更新
     * @param   t_auto_maintenance_difference__c[]  newObjs 対象の自動メンテナンス差分
     */
    private static void updateBatchStatusBatch2(t_auto_maintenance_difference__c[] newObjs) {
        List<t_auto_maintenance_difference__c> successList = new List<t_auto_maintenance_difference__c>();
        List<t_auto_maintenance_difference__c> errorList   = new List<t_auto_maintenance_difference__c>();

        // リスト作成
        for (t_auto_maintenance_difference__c obj : newObjs) {
            if (PhotoMoveErroMap.containsKey(obj.Id)) {
                // エラー
                errorList.add(obj);
            } else {
                // 成功
                successList.add(obj);
            }
        }

        // 更新
        if (successList.size() > 0) {
            updateBatchStatus(successList, CommonConst.AUTOMAINTEDIFF_BATCHSTATUS_S);
        }
        if (errorList.size() > 0) {
            updateBatchStatus(errorList, CommonConst.AUTOMAINTEDIFF_BATCHSTATUS_E2);
        }
    }

    /**
     * 建物MAPの取得
     * @param   Set<String>         BuildingCodeSet     建物のメンテナンスコード
     * @return  Map<String, Building__c> 建物（key:メンテナンス建物コード、value:建物）
     */
    private static Map<String, Building__c> selectBuildingMap(Set<String> BuildingCodeSet) {

        // 名寄せ先の建物IDの取得
        Set<Id> condIdSet = convInfo.getBuildingIds(BuildingCodeSet);

        // 建物の取得
        List<Building__c> buildingList = selectBuildingList(condIdSet);

        // 名寄せ元のメンテナンス建物コードをkeyとした建物MAPの取得
        Map<String, Building__c> buildingMap = new Map<String, Building__c>();
        for (Building__c building : buildingList) {
            buildingMap.put(convInfo.getMaintBuildingCd(building.Id), building);
        }

        return buildingMap;
    }

    /**
     * 建物取得
     * @param   Set<Id>            buildingIdSet        建物のID
     * @return  List<Building__c>                       建物リスト
     */
    private static List<Building__c> selectBuildingList(Set<Id> buildingIdSet) {

        return [SELECT ID
                     , MaintenanceBuildingCode__c
                     , Address__c
                     , Name
                     , BuildKana__c
                     , ChoazaCode__c
                     , State__c
                     , City__c
                     , Street__c
                     , Latitude__c
                     , Longitude__c
                     , BuildingYM__c
                     , PropertyType__c
                     , Structure__c
                     , GroundFloorCount__c
                     , UndergroundFloorCount__c
                     , HouseCount__c
                     , CaretakerType__c
                     , BuildingRemarksPrivate__c
                     , ForeignID__c
                 FROM Building__c
                 WHERE Id IN :buildingIdSet];
    }

    /**
     * 建物コード履歴の取得
     * @param  Set<String> condHistoryMaintenanceBuildingCodeSet 履歴メンテナンス建物コード
     * @return List<BuildingCodeHistory__c> 建物コード履歴
     */
    private static List<BuildingCodeHistory__c> selectBuildingCdHist(Set<String> condHistoryMaintenanceBuildingCodeSet) {

        // 建物コード履歴の取得
        List<BuildingCodeHistory__c> buildingCdHistList =
            [SELECT Id
                    , Building__c
                    , MaintenanceBuildingCode__c
                    , InformationUpdateDate__c
                    , HistoryMaintenanceBuildingCode__c
             FROM BuildingCodeHistory__c
             WHERE HistoryMaintenanceBuildingCode__c = :condHistoryMaintenanceBuildingCodeSet
                   AND HistoryMaintenanceBuildingCode__c != null];
        
        // 初期化処理
        if (buildingCdHistList.isEmpty()) {
            buildingCdHistList = new List<BuildingCodeHistory__c>();
        }
        
        return buildingCdHistList;
    }

    /**
     * 物件MAPの取得
     * @param Set<String> maintPropertyCdSet メンテナンス物件コード
     * @return Map<String, Property__c> 物件MAP（key:メンテナンス物件コード、value:物件）
     */
    private static Map<String, Property__c> selectPropertyMap(Set<String> maintPropertyCdSet) {

        // 名寄せ先の物件IDの取得
        Set<Id> condIdSet = convInfo.getPropertyIds(maintPropertyCdSet);

        // 物件の取得
        List<Property__c> propertyList = selectPropertyList(condIdSet);

        // 名寄せ元のメンテナンス物件コードをkeyとした物件MAPの取得
        Map<String, Property__c> propertyMap = new Map<String, Property__c>();
        for (Property__c property : propertyList) {
            propertyMap.put(convInfo.getMaintPropertyCd(property.Id), property);
        }

        return propertyMap;
    }

    /**
     * 物件取得
     * @param   Set<Id>             propertyIdSet     物件のID
     * @return  List<Property__c>                     物件リスト
     */
    private static List<Property__c> selectPropertyList(Set<Id> propertyIdSet) {
        return [SELECT Id
                     , ForeignID__c                         // 外部ID
                     , LiveStatus__c                        // 現況
                     , DeliveryType__c                      // 引渡種別
                     , DeliveryYear__c                      // 引渡 年
                     , DeliveryMonth__c                     // 引渡 月
                     , DeliveryDay__c                       // 引渡 日
                     , DeliveryTiming__c                    // 引渡 旬
                     , PropertyRemarksPrivate__c            // 物件備考（非公開）
                     , RentFee__c                           // 賃料
                     , ManagementFee__c                     // 管理費
                     , ManagementFeeTaxType__c              // 管理費税区分
                     , SecurityDepositYen__c                // 敷金(円)
                     , SecurityDepositMonth__c              // 敷金(ヵ月)
                     , SecurityDepositUnit__c               // 敷金単位
                     , KeyMoneyYen__c                       // 礼金(円)
                     , KeyMoneyMonth__c                     // 礼金(ヵ月)
                     , KeyMoneyUnit__c                      // 礼金単位
                     , DepositYen__c                        // 保証料金(円)
                     , DepositMonth__c                      // 保証料金(ヵ月)
                     , DepositUnit__c                       // 保証金単位
                     , CancellationActualFeeYen__c          // 敷引・償却(円)
                     , CancellationActualFeeMonth__c        // 敷引・償却(ヵ月)
                     , CancellationActualFeeRate__c         // 敷引・償却(%)
                     , CancellationActualFeeUnit__c         // 敷引・償却単位
                     , RenewalFeeYen__c                     // 更新料(円)
                     , RenewalFeeMonth__c                   // 更新料(ヵ月)
                     , RenewalFeeUnit__c                    // 更新料単位
                     , RenewalFeeTaxType__c                 // 更新料税区分
                     , KeyExchangeFee__c                    // 鍵交換費
                     , KeyExchangeFeeTaxType__c             // 鍵交換費税区分
                     , WortFee__c                           // 水道料金
                     , WortFeeTaxType__c                    // 水道料金税区分
                     , TownshipFee__c                       // 町会費
                     , TownshipFeeTaxType__c                // 町会費税区分
                     , TownshipFeePaymentType__c            // 町会費支払区分
                     , CATVFee__c                           // CATV
                     , CATVTaxType__c                       // CATV税区分
                     , CleaningFeeYen__c                    // 定額修繕費(円)
                     , CleaningFeeMonth__c                  // 定額修繕費(ヵ月)
                     , CleaningFeeUnit__c                   // 定額修繕費単位
                     , CleaningFeeTaxType__c                // 定額修繕費税区分
                     , CleaningFeePaymentType__c            // 定額修繕費支払区分
                     , FireInsuranceUseType__c              // 火災保険(加入義務)
                     , FireInsurancePlan__c                 // 火災保険タイトル
                     , GuaranteeidCompanyType__c            // 保証会社(利用区分)
                     , Guaranteeid__c                       // 保証タイトル
                     , MonetaryPrivate__c                   // 金銭備考(非公開)
                     , ParkingType__c                       // 駐車場種別
                     , ParkingDistance__c                   // 近隣駐車場までの距離
                     , ParkingFee__c                        // 駐車場料金
                     , ParkingFeeTaxType__c                 // 駐車場料金税区分
                     , ParkingRemarksPrivate__c             // 駐車場備考(非公開)
                     , KeyPlace__c                          // 鍵所在
                     , RewardBurdenLender__c                // 報酬負担貸主
                     , RewardBurdenBorrower__c              // 報酬負担借主
                     , RewardSplitFormerSupplier__c         // 報酬配分元付
                     , RewardSplitCustomer__c               // 報酬配分客付
                     , ADFeeYen__c                          // 広告料(円)
                     , ADFeeMonth__c                        // 広告料(ヵ月)
                     , ADFeeRate__c                         // 広告料(%)
                     , ADFeeUnit__c                         // 広告料単位
                     , ADFeeTaxType__c                      // 広告料税区分
                     , ADRemarksPrivate__c                  // 広告備考(非公開)
                     , BikeParkingSmallFee__c               // 小型バイク置場料金
                     , BikeParkingSmallFeeTaxType__c        // 小型バイク置場料金税区分
                     , BikeParkingMediumFee__c              // 中型バイク置場料金
                     , BikeParkingMediumFeeTaxType__c       // 中型バイク置場料金税区分
                     , BikeParkinLargeFee__c                // 大型バイク置場料金
                     , BikeParkinLargeFeeTaxType__c         // 大型バイク置場料金税区分
                     , GarbageDisposalFeePaymentType__c     // ゴミ処理費支払区分
                     , GarbageDisposalFeeTaxType__c         // ゴミ処理費税区分
                     , GarbageDisposalFee__c                // ゴミ処理費
                     , BicycleParkingFee__c                 // 駐輪場料金
                     , BicycleParkingType__c                // 駐輪場種別
                     , BicycleParkingFeeTaxType__c          // 駐輪場代税区分
                     , TransactionAspect__c                 // 取引態様
                     , WebPublishing__c                     // web公開
                     , IsPermissionPublishing__c            // 掲載許可済みフラグ
                     , IsBulkConfirmation__c                // 一括確認チェック
                     , BulkConfirmationDate__c              // 一括確認日
                     , OwnCompanyManageModDate__c           // 自社管理修正日
                     , AutoMaintenanceDate__c               // 自動最終メンテナンス日
                     , TemporarySaveDate__c                 // 一時保存日
                     , Building__c                          // 建物
                     , Building__r.ForeignID__c             // 建物.外部ID
                     , FormerSupplier__c                    // 元付業者
                     , FormerSupplier__r.ForeignID__c       // 元付業者.外部ID
                     , MaintenancePropertyCode__c           // 物件メンテナンスコード
                     , SuumoNetCatch__c                     //SUUMOネット用キャッチ
                     , SuumoNetCatchComment__c              // SUUMOネット用キャッチコメント
                     , AutoMaintenanceDiffRoomLayoutFileName__c // 自動メンテナンス差分間取図ファイル名
                     , PropertyCode__c                          // 物件コード
                     , ImportType__c                            // 取込先
                     , PropertyDetailUrl__c                     // 物件詳細画面URL
                     , CrawlingDataModifiedDate__c              // クローリングデータ更新日
                  FROM Property__c
                 WHERE Id IN :propertyIdSet
        ];
    }

    /**
     * 物件コード履歴の取得
     * @param  Set<String> condHistMaintenancePropertyCdSet 履歴メンテナンス物件コード
     * @return List<PropertyCodeHistory__c> 物件コード履歴
     */
    private static List<PropertyCodeHistory__c> selectPropertyCdHist(Set<String> condHistMaintenancePropertyCdSet) {
        return selectPropertyCdHist(condHistMaintenancePropertyCdSet, new Set<Id>());
    }

    /**
     * 物件コード履歴の取得
     * @param  Set<String> condHistMaintenancePropertyCdSet 履歴メンテナンス物件コード
     * @param  Set<Id>     condHistPropertyIdSet            履歴物件
     * @return List<PropertyCodeHistory__c> 物件コード履歴
     */
    private static List<PropertyCodeHistory__c> selectPropertyCdHist(Set<String> condHistMaintenancePropertyCdSet
                                                                     , Set<Id> condHistPropertyIdSet) {

        // 物件コード履歴の取得
        List<PropertyCodeHistory__c> propertyCdHistList =
            [SELECT Id
                    , Property__c                       // 物件
                    , MaintenancePropertyCode__c        // メンテナンス物件コード
                    , InformationUpdateDate__c          // 情報更新日
                    , HistoryProperty__c                // 履歴物件
                    , HistoryMaintenancePropertyCode__c // 履歴メンテナンス物件コード
                    , HistoryImportDestination__c       // 履歴取込先
                    , HistoryPropertyDetailUrl__c       // 履歴物件詳細画面URL
             FROM PropertyCodeHistory__c
             WHERE (HistoryMaintenancePropertyCode__c = :condHistMaintenancePropertyCdSet
                    AND HistoryMaintenancePropertyCode__c != null)
                   OR HistoryProperty__c = :condHistPropertyIdSet];
        
        // 初期化処理
        if (propertyCdHistList.isEmpty()) {
            propertyCdHistList = new List<PropertyCodeHistory__c>();
        }
        
        return propertyCdHistList;
    }

    /**
     * 物件管理会社指定商品取得
     * @param   Set<Id> propertyIdSet             物件のID
     * @return  List<PropertyManageCompayItem__c> 物件管理会社指定商品リスト
     */
    private static List<PropertyManageCompayItem__c> selectPropertyManageCompayItemList(Set<Id> propertyIdSet) {
        return [SELECT Id
                      ,Property__r.MaintenancePropertyCode__c
                      ,Item__c//管理会社指定商品.Id
                  FROM PropertyManageCompayItem__c
                 WHERE Property__c IN :propertyIdSet
        ];
    }

    /**
     * 業者取得
     * @param   Set<String>         supplierCodeSet     業者メンテナンスコード
     * @return　List<Account>                           業者のリスト
     */
    private static List<Account> selectSupplierList(Set<String> supplierCodeSet) {
        return [SELECT Id                           // ID
                     , RecordTypeId                 // レコードタイプId
                     , MaintenanceSupplierCode__c   // メンテナンス業者コード
                     , Name                         // 取引先名
                     , Phone                        // 電話番号
                     , Fax                          // 取引先 FAX
                     , Representative__c            // 取引先担当者
                     , RemarksPrivate__c            // 備考(非公開)
                     , Address__c                   // 住所
                  FROM Account
                 WHERE MaintenanceSupplierCode__c IN :supplierCodeSet];
    }


    /**
     * 物件条件取得
     * @param    Set<Id>                      propertyIdSet     物件ID
     * @return   List<PropertyConditions__c>                    物件条件のリスト
     */
    private static List<PropertyConditions__c> selectPropCond(Set<Id> propertyIdSet) {
        return [SELECT  Id
                      , Property__c
                      , Property__r.MaintenancePropertyCode__c
                      , FacilityRemarksPrivate__c
                      , IsQuietResidenceTown__c                 // 閑静な住宅街
                      , IsTowerMansion__c                       // タワーマンション
                      , IsDesigners__c                          // デザイナーズ
                      , IsBarrierFree__c                        // バリアフリー
                      , IsOuterWallTile__c                      // 外壁タイル張り
                      , IsCondominiumRental__c                  // 分譲賃貸
                      , IsDampingStructure__c                   // 制震構造
                      , IsSeismicStructure__c                   // 耐震構造
                      , IsSeismicIsolationStructure__c          // 免震構造
                      , IsTopFloor__c                           // 最上階
                      , IsElevator__c                           // エレベーター
                      , IsPluralElevators__c                    // エレベーター2基
                      , IsFrontService__c                       // フロントサービス
                      , IsDeliveryBox__c                        // 宅配ボックス
                      , IsCleaningBox__c                        // クリーニングボックス
                      , IsCoinLaundry__c                        // コインランドリー
                      , IsAnytimeTtrashArea__c                  // 24時間ゴミ出し可
                      , IsInSiteTtrashArea__c                   // 敷地内ゴミ置場
                      , IsSepticTank__c                         // 浄化槽
                      , IsPluralCarParking__c                   // 駐車場2台可
                      , IsBicycleParking__c                     // 駐輪場
                      , IsCornerRoom__c                         // 角部屋
                      , IsBayWindow__c                          // 出窓
                      , IsPrivateGarden__c                      // 専用庭
                      , IsAutoLock__c                           // オートロック
                      , IsAnytimeSecurity__c                    // 24時間セキュリティ
                      , IsSecurityCompanyJoin__c                // セキュリティ会社加入済
                      , IsDimpleKey__c                          // ディンプルキー
                      , IsSurveillanceCamera__c                 // 防犯カメラ
                      , IsSecurityGlass__c                      // 防犯ガラス
                      , IsMaisonette__c                         // メゾネット
                      , IsLoft__c                               // ロフト
                      , IsUndergroundRoom__c                    // 地下室
                      , IsSoundproofRoom__c                     // 防音室
                      , IsGasStove__c                           // ガスコンロ
                      , IsTwoGasStove__c                        // コンロ2口
                      , IsMoreGasStove__c                       // コンロ3口以上
                      , IsIhStove__c                            // IHコンロ
                      , IsElectricStove__c                      // 電気コンロ
                      , IsCounterKitchen__c                     // カウンターキッチン
                      , IsSystemKitchen__c                      // システムキッチン
                      , IsWaterPurifier__c                      // 浄水器
                      , IsDishwasher__c                         // 食器洗い乾燥機
                      , IsDisposer__c                           // ディスポーザー
                      , IsCityGas__c                            // 都市ガス
                      , IsPropaneGas__c                         // プロパンガス
                      , IsSeparate__c                           // バス・トイレ別
                      , IsShowerRoom__c                         // シャワールーム
                      , IsMistSauna__c                          // ミストサウナ
                      , IsTvBath__c                             // TV付浴槽
                      , IsReheating__c                          // 追焚機能
                      , IsHotWaterFormula__c                    // 高温差湯式
                      , IsBathroomDryer__c                      // 浴室乾燥機
                      , IsBathroomFloorHeating__c               // 浴室床暖房
                      , IsWashletToiletSeat__c                  // 温水洗浄便座
                      , IsTanklessToilet__c                     // タンクレストイレ
                      , IsShowerWashBasin__c                    // シャワー付き洗面台
                      , IsWashroomDscrete__c                    // 洗面所独立
                      , IsFloorHeating__c                       // 床暖房
                      , IsGasHeating__c                         // ガス暖房
                      , IsKeroseneHeating__c                    // 灯油暖房
                      , IsAllElectric__c                        // オール電化
                      , IsAirConditioner__c                     // エアコン
                      , IsFurniture__c                          // 家具付き
                      , IsHomeAppliance__c                      // 家電付き
                      , IsWashingDryer__c                       // 洗濯乾燥機
                      , IsBalcony__c                            // バルコニー
                      , IsRoofBalcony__c                        // ルーフバルコニー
                      , IsWoodDeck__c                           // ウッドデッキ
                      , IsFlooring__c                           // フローリング
                      , IsCushionFloor__c                       // クッションフロア
                      , IsStormShutter__c                       // 雨戸
                      , IsShutter__c                            // シャッター
                      , IsElectricShutter__c                    // 電動シャッター
                      , IsHighSash__c                           // ハイサッシ
                      , IsSoundproofSash__c                     // 防音サッシ
                      , IsPairGlass__c                          // 複層ガラス
                      , IsSolidWood__c                          // 無垢材使用
                      , IsIndoorWashingMachineStorage__c        // 室内洗濯機置場
                      , IsWalkInCloset__c                       // ウォークインクローゼット
                      , IsShoesBox__c                           // シューズボックス
                      , IsTrunkRoom__c                          // トランクルーム
                      , IsUnderfloorStorage__c                  // 床下収納
                      , IsBSAntenna__c                          // BSアンテナ
                      , IsCSAntenna__c                          // CSアンテナ
                      , IsCATV__c                               // CATV
                      , IsCATVInternet__c                       // CATVインターネット
                      , IsCATVFree__c                           // CATV使用料不要
                      , IsOpticalFiber__c                       // 光ファイバー
                      , IsInternetFree__c                       // ネット使用料無料
                      , IsMonitorIntercom__c                    // モニター付きインターホン
                      , IsRenovation__c                         // リノベーション
                      , IsRentCreditPayment__c                  // 家賃カード決済可
                      , IsInitialCostCreditPayment__c           // 初期費用カード決済可
                      , IsITImportantDescription__c             // IT重説対応物件
                      , IsNoGuarantor__c                        // 保証人不要
                      , IsCustomize__c                          // カスタマイズ可
                      , IsDIY__c                                // DIY可
                      , IsMusicalInstruments__c                 // 楽器相談可
                      , IsPet__c                                // ペット可
                      , IsTwoTenant__c                          // 2人入居可
                      , IsWoman__c                              // 女性限定
                      , IsLbgt__c                               // LGBTフレンドリー
                      , IsElderly__c                            // 高齢者歓迎
                      , IsRoomShare__c                          // ルームシェア可
                      , IsMonthly__c                            // マンスリー可
                      , IsOfficeAvailable__c                    // 事務所利用可
                      , IsFreeRent__c                           // フリーレント
                      , IsSpecialRent__c                        // 特定優良賃貸住宅
                      , IsForeigner__c                          // 外国人契約可
                      , IsStudent__c                            // 学生限定
                      , IsNotChild__c                           // 子供不可
                      , IsWelfareAvailable__c                   // 生活保護契約可
                      , IsCorporation__c                        // 法人契約限定
                      , IsTwoStation__c                         // 2駅利用可
                      , IsTwoTrainRoute__c                      // 2沿線利用可
                      , IsThreeStation__c                       // 3駅以上利用可
                      , IsThreeTrainRoute__c                    // 3沿線以上利用可
                      , IsFrontStation__c                       // 駅前
                      , IsFirstFloor__c                         // 1階
                      , IsSecondFloorOver__c                    // 2階以上
                      , IsParking__c                            // 駐車場空きあり
                      , IsInSiteParking__c                      // 敷地内駐車場
                      , IsBikeStorage__c                        // バイク可
                      , IsSmallBike__c                          // 小型バイク
                      , IsMediumBike__c                         // 中型バイク
                      , IsLargeBike__c                          // 大型バイク
                      , IsSouth__c                              // 南向き
                      , IsJanitor__c                            // 管理人有
                      , IsJanitorReside__c                      // 管理人(常駐)
                      , IsJanitorCommuter__c                    // 管理人(通勤)
                      , IsJanitorPatrol__c                      // 管理人(巡回)
                      , IsTurnkey__c                            // 即入居可
                      , IsLargePet__c                           // ペット(大型犬)
                      , IsMiddlePet__c                          // ペット(中型犬)
                      , IsSmallPet__c                           // ペット(小型犬)
                      , IsCat__c                                // ペット(猫)
                      , IsOtherPet__c                           // ペット(その他)
                      , IsNotFixedTermTenant__c                 // 定期借家を含まない
                      , IsAllWesternStyleRoom__c                // オール洋間
                      , IsBuiltInGarage__c                      // ビルトインガレージ
                      , IsCarport__c                            // カーポート
                      , IsShoeCloak__c                          // シューズクローク
                  FROM  PropertyConditions__c
                 WHERE  Property__c IN (SELECT ID 
                                          FROM Property__c
                                         WHERE Id IN :propertyIdSet
                                       )
        ];
    }

    /**
     * 物件写真取得
     * @param   Set<Id>                propertyIdSet    物件のID
     * @return  List<PropertyPhoto__c>                  物件写真リスト
     */
    private static List<PropertyPhoto__c> selectPropertyPotoList(Set<Id> propertyIdSet) {
        //SQL用 全項目取得String作成
        List<String> itemList = New List<String>();
        Map<String, Schema.sObjectField> omap = PropertyPhoto__c.SObjecttype.getDescribe().fields.getMap();
        for(String s: omap.keySet()) {
            itemList.add(s);
        }
        String items =  String.join(itemList, ',');
        
        //SQL作成
        String soql ='';
        soql += ' SELECT ' + items; // 全項目
        soql += '   FROM PropertyPhoto__c';                                // 物件写真
        soql += '  WHERE Property__c IN (SELECT Id FROM Property__c WHERE Id IN :propertyIdSet)';
        List<PropertyPhoto__c> propPhotoList = Database.query(soql);
        return propPhotoList;
    }

    /**
     * 建物写真取得
     * @param   Set<Id>                buildingIdSet     建物のID
     * @return  List<BuildingPhoto__c>                   建物写真リスト
     */
    private static List<BuildingPhoto__c> selectBuildingPhotoList(Set<Id> buildingIdSet) {
        return [SELECT Id
                     , Building__c                              // 建物
                     , AppearanceFileName__c                    // 建物外観
                     , EntranceFileName__c                      // エントランス
                     , LobbyFileName__c                         // ロビー
                     , ParkingFileName__c                       // 駐車場
                     , OtherSharingFileName__c                  // その他共有部分
                     , SurroundingFileName1__c	                // 周辺写真ファイル名１
                     , SurroundingFileName2__c	                // 周辺写真ファイル名２
                     , SurroundingFileName3__c	                // 周辺写真ファイル名３
                     , SurroundingFileName4__c	                // 周辺写真ファイル名４
                     , SurroundingFileName5__c	                // 周辺写真ファイル名５
                  FROM BuildingPhoto__c
                 WHERE Building__c IN (SELECT ID 
                                          FROM Building__c
                                         WHERE Id IN :buildingIdSet
                                       )
        ];        
    }

    /**
     * 火災保険の計算用データの取得
     * @param       FireInsuranceItemId   Id    火災保険の商品を取得するId
     * @return      Item__c   火災の商品
     */
    private static Item__c selectFireInsuranceItem(Id FireInsuranceItemId){
        List<Item__c> FireInsuranceItemList = [
            SELECT  Id         
            ,       PaymentType__c              // 更新期間
            ,       FireInsuranceMonth__c       // 火災保険料(月額)                 
            FROM    Item__c                     // 商品
            WHERE   Id = :FireInsuranceItemId   // 商品ID
        ];

        if (FireInsuranceItemList.isEmpty()){
            return null;
        }
        return FireInsuranceItemList[0];
    }

    /**
     * 保証会プランの計算用データの取得
     * @param       DepositItemId   Id    保証会社の商品を取得するId
     * @return      Item__c   保証の商品
     */
    private static Item__c selectDepositItem(Id DepositItemId){
        List<Item__c> DepositItemList = [
            SELECT  Id                              
            ,       ItemName__c                      // 商品名
            ,       Account__r.IsAllRentFeeType__c   // 総賃料区分
            ,       DirectDebitFeeTaxType__c         // 手数料税区分
            ,       DirectDebitFee__c                // 手数料
            ,       DirectDebitFeeTax__c             // 手数料(税込)
            ,      (SELECT   DepositRate__c          // 保証料(割合)
                    ,        DepositYen__c           // 保証料(金額)
                    ,        IsRentFeeType__c        // 賃料区分
                    FROM     ItemDetailItem__r       // 商品明細
                    Limit    1)
            FROM    Item__c                          // 商品
            WHERE   Id = :DepositItemId              // 商品ID
        ];

        if (DepositItemList.isEmpty()){
            return null;
        }
        return DepositItemList[0];
    }

    /**
     * 業者の項目設定
     * @param       Account                             acc         既存業者データ
     * @param       t_auto_maintenance_difference__c    diff        自動メンテナンス差分
     * @param       List<String>                        stateList   都道府県リスト
     * @return      Account                             取引先の更新値
     */
    private static Account setSupplierData(Account acc, t_auto_maintenance_difference__c diff, List<String> stateList) {
        Account supplier = new Account();

        // ▼ 新規時設定項目 ※既存データの有無で判定
        if (acc == (new Account())) {
            supplier.MaintenanceSupplierCode__c = diff.MaintenanceSupplierCode__c;                      // メンテナンス業者コード
            supplier.recordTypeId               = RECORDTYPE_ID_SUPPLIER;                               // レコードタイプID（管理会社・オーナー・サブリース）
            supplier.IsManagementCompany__c     = true;                                                 // 管理会社
            IsUpsert = true;
            // 取込区分
            if (diff.ExternalSiteCd__c == CommonConst.AUTOMAINTEDIFF_SITECODE_REALNETPRO) {         // リアプロ
                supplier.ImportType__c = CommonConst.PROPERTY_IMPORTTYPE_REALNETPRO;
            } else if(diff.ExternalSiteCd__c == CommonConst.AUTOMAINTEDIFF_SITECODE_DAIWALIVING) {  // 大和リビング
                supplier.ImportType__c = CommonConst.PROPERTY_IMPORTTYPE_DAIWALIVING;
            }
        }
        // ▲ 新規時設定項目

        // ▼ 更新時設定項目
        if (acc != (new Account())) {
            supplier.Id = acc.Id;   // 取引先ID
        }
        // ▲ 更新時設定項目

        // ▼ 変更時登録項目
        // 取引先名
        if (acc.Name != diff.ManagementCompanyName__c && String.isNotBlank(diff.ManagementCompanyName__c)) {
            supplier.Name = diff.ManagementCompanyName__c;
            IsNameMearge = true;
            IsUpsert = true;
        }

        // リアプロのみ
        if (diff.ExternalSiteCd__c == CommonConst.AUTOMAINTEDIFF_SITECODE_REALNETPRO) {         
            // 電話番号
            if (acc.Phone != diff.ManagementCompanyPhone__c && String.isNotBlank(diff.ManagementCompanyPhone__c)) {
                supplier.Phone = diff.ManagementCompanyPhone__c;
                IsNameMearge = true;
                IsUpsert = true;
            }

            // FAX
            if (acc.Fax != diff.ManagementCompanyFax__c && String.isNotBlank(diff.ManagementCompanyFax__c)) {
                supplier.Fax = diff.ManagementCompanyFax__c;
                IsUpsert = true;
            }
        }   

        // 取引先担当者
        if (acc.Representative__c != diff.ManagementCompanyStaffName__c) {
            supplier.Representative__c = diff.ManagementCompanyStaffName__c;
            if (supplier.Representative__c == null) {
                supplier.Representative__c = '担当';
            }
            IsUpsert = true;
        }

        // ▲ 変更時登録項目

        // ▼ 特殊条件項目
        // リアプロのみ
        if (diff.ExternalSiteCd__c == CommonConst.AUTOMAINTEDIFF_SITECODE_REALNETPRO) {         
            // 備考
            List<String> remarksList = new List<String>();
            remarksList.add(t_auto_maintenance_difference__c.ManagementCompanyLicense__c.getDescribe().getlabel()); // 管理会社
            remarksList.add(':');
            remarksList.add(diff.ManagementCompanyLicense__c);
            remarksList.add(CommonConst.BREAK_CODE);
            remarksList.add(t_auto_maintenance_difference__c.ManagementCompanyRemarks__c.getDescribe().getlabel()); // 管理会社備考
            remarksList.add(':');
            remarksList.add(diff.ManagementCompanyRemarks__c);
            String remarks = String.join(remarksList, '');
            if (acc.RemarksPrivate__c != remarks) {
                supplier.RemarksPrivate__c = remarks;
                IsUpsert = true;
            }

            // 住所 ※住所の変更があった場合、都道府県,住所１,住所２に分けて登録
            if (acc.Address__c != diff.ManagementCompanyAddress__c) {
                if (String.isBlank(diff.ManagementCompanyAddress__c)) {
                    supplier.State__c  = null;  // 都道府県
                    supplier.City__c   = null;  // 住所１
                    supplier.Street__c = null;  // 住所２
                } else {
                    // 都道府県
                    supplier.State__c = getState(stateList, diff.ManagementCompanyAddress__c);  // 都道府県 ※住所より抜き出し
                    // 住所１,住所２　※住所1の最大桁数以降は住所2へ格納
                    String addressTmp   = diff.ManagementCompanyAddress__c.replace(supplier.State__c, CommonConst.STRING_EMPTY);
                    Integer cityLength   = Account.City__c.getDescribe().getLength();
                    Integer streetLength = Account.Street__c.getDescribe().getLength();
                    if (String.isNotBlank(addressTmp)) {
                        supplier.City__c = addressTmp.left(cityLength);
                    }
                    if (addressTmp.length() > cityLength) {
                        supplier.Street__c = addressTmp.mid(cityLength + 1, streetLength);
                    }
                }
                IsUpsert = true;
            }
        }
        // ▲ 特殊条件項目

        // 返却
        return supplier;
    }



    /**
     * 建物の項目設定
     * @param   Building__c                         oldBuilding  現在の建物のデータ
     * @param   t_auto_maintenance_difference__c    diff         自動メンテナンス差分（クローリングのデータ）
     * @return  Building__c                                      建物の更新値
     */
    private static Building__c setBuildingData(Building__c oldBuilding, t_auto_maintenance_difference__c diff) {
        Building__c buildingData = new Building__c();   // 返却用

        // ▼ 共通設定項目
        buildingData.Id = oldBuilding.Id;                                           // 建物ID
        if(String.isNotBlank(diff.BuildingName__c)){
            buildingData.Name = diff.BuildingName__c;                               // 建物名
        }
        // リアプロのみ
        if (diff.ExternalSiteCd__c == CommonConst.AUTOMAINTEDIFF_SITECODE_REALNETPRO) {         
            if(String.isNotBlank(diff.BuildKana__c)){
                buildingData.BuildKana__c = diff.BuildKana__c;                      // 建物名カナ
            }
        }
        if(String.isNotBlank(diff.BuildingYM__c)){
            buildingData.BuildingYM__c = diff.BuildingYM__c;                        // 築年月
        }
        if(String.isNotBlank(diff.PropertyType__c)){
            buildingData.PropertyType__c = diff.PropertyType__c;                    // 物件種別
        }
        if(String.isNotBlank(diff.Structure__c)){
            buildingData.Structure__c = diff.Structure__c;                          // 建物構造
        }
        if(diff.GroundFloorCount__c != null){
            buildingData.GroundFloorCount__c = diff.GroundFloorCount__c;            // 地上階数
        }
        
        // リアプロのみ
        if (diff.ExternalSiteCd__c == CommonConst.AUTOMAINTEDIFF_SITECODE_REALNETPRO) {         
            if(diff.UndergroundFloorCount__c != null){
                buildingData.UndergroundFloorCount__c = diff.UndergroundFloorCount__c;  // 地下階数
            }
            if(diff.HouseCount__c != null){
                buildingData.HouseCount__c = diff.HouseCount__c;                        // 棟総戸数
            }
            if(String.isNotBlank(diff.CaretakerType__c)){
                buildingData.CaretakerType__c = diff.CaretakerType__c;                  // 管理人種別
            }
        }
        // ▲ 共通設定項目

        // ▼ 新規時設定項目
        if (oldBuilding.Id == null) {
            // 取込区分
            if (diff.ExternalSiteCd__c == CommonConst.AUTOMAINTEDIFF_SITECODE_REALNETPRO) {         // リアプロ
                buildingData.ImportType__c = CommonConst.PROPERTY_IMPORTTYPE_REALNETPRO;
            } else if(diff.ExternalSiteCd__c == CommonConst.AUTOMAINTEDIFF_SITECODE_DAIWALIVING) {  // 大和リビング
                buildingData.ImportType__c = CommonConst.PROPERTY_IMPORTTYPE_DAIWALIVING;
            }
            buildingData.MaintenanceBuildingCode__c = diff.MaintenanceBuildingCode__c;  // メンテナンスコード
            // リアプロのみ
            if (diff.ExternalSiteCd__c == CommonConst.AUTOMAINTEDIFF_SITECODE_REALNETPRO) {         
                buildingData.ChoazaCode__c = diff.ChoazaCode__c;                            // 町字コード
            }
            buildingData.State__c    = diff.State__c;                                   // 都道府県
            buildingData.City__c     = diff.City__c;                                    // 住所１(市区町村)
            buildingData.Street__c   = diff.Street__c;                                  // 住所２(番地)
            buildingData.District__c = CommonUtil.getDistrict(String.join(new List<String>{diff.City__c, diff.Street__c}, ''),districtList); // 地区を設定
            // リアプロのみ
            if (diff.ExternalSiteCd__c == CommonConst.AUTOMAINTEDIFF_SITECODE_REALNETPRO) {         
                buildingData.Latitude__c = diff.Latitude__c;                                // 緯度
                buildingData.Longitude__c = diff.Longitude__c;                              // 経度
            }
            buildingData.IsFirstSurroundingImportFlag__c = false;                       // 初回周辺取込フラグ
            buildingData.IsWebCooperationAvailableFlag__c = false;                      // Web連携可能フラグ
        }
        // ▲ 新規時設定項目

        // ▼ 変更時設定項目　※掲載終了 以外
        if (diff.AutoMaintenanceType__c != CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_POSTING_END) {
            // 建物備考(非公開)
            if(oldBuilding.BuildingRemarksPrivate__c != diff.BuildingRemarksPrivate__c && (diff.ExternalSiteCd__c == CommonConst.AUTOMAINTEDIFF_SITECODE_REALNETPRO)){  // リアプロ
                buildingData.BuildingRemarksPrivate__c  = diff.BuildingRemarksPrivate__c;   // 建物備考(非公開)
            }
        }
        return buildingData;
    }

    /**
     * 物件の項目設定
     * @param  Id                                   BuildingId     建物ID
     * @param  Id                                   supplierId     取引先ID
     * @param  Property__c                          property       現在の物件のデータ
     * @param  t_auto_maintenance_difference__c     diff           自動メンテナンス差分(クローリングのデータ)
     * @param  Boolean                              existsBuilding  既存の建物の存在有無
     * @param  Boolean                              existsProperty  既存の物件の存在有無
     * @param  Map<String, String>                  changeAutoMaintenanceMessageMap 駐車場種別相違メッセージ取得
     * @return Property__c                                         物件の更新値
     */
    private static Property__c setPropertyData(Id buildingId, Id supplierId, Property__c property, t_auto_maintenance_difference__c diff, Boolean existsBuilding, Boolean existsProperty, Map<String, String> changeAutoMaintenanceMessageMap ) {
        Decimal fee;
        Decimal feeAny;
        String taxType;
        Property__c propData  = new Property__c();

        // ▼ 共通設定項目
        propData.Id                          = property.Id;                          // 物件ID
        propData.AutoMaintenanceDate__c      = CommonUtil.getNow();                  // 自動最終メンテナンス日
        
        if (BuildingId != null) {
            propData.Building__c             = BuildingId;                           // 建物ID
        }
        // メンテナンス関連項目
        propData.MaintenanceType__c = property.Id == null ? CommonConst.MAINTENANCETYPE_AUTHADD : CommonConst.MAINTENANCETYPE_AUTOCHG;  // メンテナンス区分
        propData.MaintenanceCommentArea__c = diff.AutoMaintenanceContent__c;    // メンテナンスコメント
          
        // 取込先
        String importType = CommonConst.STRING_EMPTY;
        if (diff.ExternalSiteCd__c == CommonConst.AUTOMAINTEDIFF_SITECODE_REALNETPRO) {
            // リアプロ
            importType = CommonConst.PROPERTY_IMPORTTYPE_REALNETPRO;
        } else if(diff.ExternalSiteCd__c == CommonConst.AUTOMAINTEDIFF_SITECODE_DAIWALIVING) {
            // 大和リビング
            importType = CommonConst.PROPERTY_IMPORTTYPE_DAIWALIVING;
        }
        // ▲ 共通設定項目

        // 名寄せ先連携時のクローリング情報更新チェック
        if (property.ImportType__c == null
            || property.MaintenancePropertyCode__c == diff.MaintenancePropertyCode__c) {

            // 物件詳細画面URL
            if (String.isNotBlank(diff.PropertyDetailUrl__c) && diff.PropertyDetailUrl__c != property.PropertyDetailUrl__c) {
                propData.PropertyDetailUrl__c = diff.PropertyDetailUrl__c;
                IsUpsert = true;
            }

            // 取込先
            if (importType != property.ImportType__c) {
                propData.ImportType__c = importType;
                IsUpsert = true;
            }

            // クローリングデータ更新日
            if (diff.InfoModifiedDate__c != property.CrawlingDataModifiedDate__c) {
                propData.CrawlingDataModifiedDate__c = diff.InfoModifiedDate__c;
                IsUpsert = true;
            }
        }

        //▼ 登録時の設定
        if (!existsBuilding || !existsProperty) {

            propData.MaintenancePropertyCode__c = diff.MaintenancePropertyCode__c;    // メンテナンス物件コード
            propData.Name = diff.PropertyName__c;                                     // 部屋番号
            propData.Floor__c = diff.Floor__c;                                        // 所在階
            // リアプロのみ
            if (diff.ExternalSiteCd__c == CommonConst.AUTOMAINTEDIFF_SITECODE_REALNETPRO) {         
                propData.BalconyDirection__c = diff.BalconyDirection__c;                  // バルコニー方向
            }
            propData.RoomArea__c = diff.RoomArea__c;                                  // 専有面積
            // リアプロのみ
            if (diff.ExternalSiteCd__c == CommonConst.AUTOMAINTEDIFF_SITECODE_REALNETPRO) {         
                propData.BalconyArea__c = diff.BalconyArea__c;                            // バルコニー面積
            }
            propData.RoomCount__c = diff.RoomCount__c;                                // 部屋数
            propData.RoomLayout__c = diff.RoomLayout__c;                              // 間取り
            propData.TransactionAspect__c = CommonConst.PROPERTY_TRANSACTIONASPECT_GENERALBROKERAGE;    // 取引態様（一般媒介を設定）
            propData.DeliveryType__c = diff.DeliveryType__c;                          // 引渡種別
            propData.DeliveryYear__c = diff.DeliveryYear__c;                          // 引渡 年
            propData.DeliveryMonth__c = diff.DeliveryMonth__c;                        // 引渡 月
            propData.DeliveryDay__c = diff.DeliveryDay__c;                            // 引渡 日
            propData.DeliveryTiming__c = diff.DeliveryTiming__c;                      // 引渡 旬
            propData.ImportType__c               = importType;                        // 取込先
            propData.CrawlingDataModifiedDate__c = diff.InfoModifiedDate__c;          // クローリングデータ更新日
            propData.PropertyDetailUrl__c        =  diff.PropertyDetailUrl__c;        // 物件詳細画面URL

            // リアプロのみ
            if (diff.ExternalSiteCd__c == CommonConst.AUTOMAINTEDIFF_SITECODE_REALNETPRO) {         
                // 町会費
                propData.TownshipFee__c = diff.TownshipFee__c;
                property.TownshipFee__c = diff.TownshipFee__c;
                // 町会費税区分
                taxType = String.isEmpty(diff.TownshipFeeTaxType__c) ? CommonConst.PROPERTY_TAXTYPE_NOTAXABLE : diff.TownshipFeeTaxType__c;
                propData.TownshipFeeTaxType__c = taxType;
                property.TownshipFeeTaxType__c = taxType;
                // 町会費支払区分
                propData.TownshipFeePaymentType__c = diff.TownshipFeePaymentType__c;
                property.TownshipFeePaymentType__c = diff.TownshipFeePaymentType__c;
                // 保証会社（利用区分）
                propData.GuaranteeidCompanyType__c = diff.GuaranteeidCompanyType__c;
            }
            IsUpsert = true;
            
        }
        //▲ 登録時項目設定

        //▼ 変更時項目設定　※条件変更以外
        if(diff.AutoMaintenanceType__c != CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_CHANGE_CONDITION){
 
            //▼ 変更時項目設定　※掲載終了時以外
            if(diff.AutoMaintenanceType__c != CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_POSTING_END){
                // 元付業者・取引態様
                if (property.FormerSupplier__c != supplierId) {
                    propData.FormerSupplier__c    = supplierId;                     // 元付業者

                    // 元付業者が変わっている場合、火災保険、保証会社を初期化する。
                    if(property.FormerSupplier__c != null){
                        propData.FireInsuranceUseType__c = null;                        // 火災保険(加入義務) 
                        propData.FireInsuranceCompany__c = null;                        // 火災保険会社
                        propData.FireInsurancePlan__c = null;                           // 火災保険タイトル
                        propData.GuaranteeidCompanyType__c = null;                      // 保証会社（利用区分）
                        propData.GuaranteeidCompany__c = null;                          // 保証会社
                        propData.Guaranteeid__c = null;                                 // 保証タイトル
    
                        // 総賃料計算する用の火災、保証のデータを初期化する。
                        property.FireInsuranceUseType__c = null;                        // 火災保険(加入義務) 
                        property.FireInsuranceCompany__c = null;                        // 火災保険会社
                        property.FireInsurancePlan__c = null;                           // 火災保険タイトル
                        property.GuaranteeidCompanyType__c = null;                      // 保証会社（利用区分）
                        property.GuaranteeidCompany__c = null;                          // 保証会社
                        property.Guaranteeid__c = null;                                 // 保証タイトル
                    }
                    if (String.isNotBlank(property.Id)){
                        deletePropertyManageCompayItem(property.Id);                // 物件管理会社指定商品の削除対象の物件Idをセット
                    }
                    
                    IsUpsert = true;
                }

                // リアプロのみ
                if (diff.ExternalSiteCd__c == CommonConst.AUTOMAINTEDIFF_SITECODE_REALNETPRO) {         
                    // 	更新料(ヵ月)
                    if (property.RenewalFeeMonth__c != diff.RenewalFeeMonth__c) {
                        propData.RenewalFeeMonth__c = diff.RenewalFeeMonth__c;
                        property.RenewalFeeMonth__c = diff.RenewalFeeMonth__c;
                        // (検索用)更新料(ヵ月)
                        propData.RenewalFeeMonthSearch__c = propData.RenewalFeeMonth__c == null ? 0 : propData.RenewalFeeMonth__c;
                        IsUpsert = true;
                    }
                    // 	更新料単位
                    if (property.RenewalFeeUnit__c != diff.RenewalFeeUnit__c) {
                        propData.RenewalFeeUnit__c = diff.RenewalFeeUnit__c;
                        property.RenewalFeeUnit__c = diff.RenewalFeeUnit__c;
                        IsUpsert = true;
                    }
                    // 	更新料税区分
                    taxType = String.isEmpty(diff.RenewalFeeTaxType__c) ? CommonConst.PROPERTY_TAXTYPE_NOTAXABLE : diff.RenewalFeeTaxType__c;
                    if (property.RenewalFeeTaxType__c != taxType) {
                        propData.RenewalFeeTaxType__c = taxType;
                        property.RenewalFeeTaxType__c = taxType;
                        IsUpsert = true;
                    }
                    // 更新料(円)
                    feeAny = diff.RenewalFeeUnit__c == CommonConst.PROPERTY_FEEUNIT_MONTH
                                                    ? diff.RenewalFeeMonth__c :  diff.RenewalFeeYen__c; 
                    fee = calcUnitFee(diff.RenewalFeeUnit__c, feeAny, diff.RentFee__c);
                    if (property.RenewalFeeYen__c != fee) {
                        propData.RenewalFeeYen__c = fee;
                        property.RenewalFeeYen__c = fee;
                        // (検索用)更新料(円)
                        propData.RenewalFeeYenSearch__c = propData.RenewalFeeYen__c == null ? 0 : propData.RenewalFeeYen__c;
                        IsUpsert = true;
                    }
                    // 鍵交換費
                    if (property.KeyExchangeFee__c != diff.KeyExchangeFee__c) {
                        propData.KeyExchangeFee__c = diff.KeyExchangeFee__c;
                        property.KeyExchangeFee__c = diff.KeyExchangeFee__c;
                        IsUpsert = true;
                    }
                    // 鍵交換費税区分
                    taxType = String.isEmpty(diff.KeyExchangeFeeTaxType__c) ? CommonConst.PROPERTY_TAXTYPE_NOTAXABLE : diff.KeyExchangeFeeTaxType__c;
                    if (property.KeyExchangeFeeTaxType__c != taxType) {
                        propData.KeyExchangeFeeTaxType__c = taxType;
                        property.KeyExchangeFeeTaxType__c = taxType;
                        IsUpsert = true;
                    }
                    // 水道料金
                    if (property.WortFee__c != diff.WortFee__c) {
                        propData.WortFee__c = diff.WortFee__c;
                        property.WortFee__c = diff.WortFee__c;
                        IsUpsert = true;
                    }
                    // 水道料金税区分
                    taxType = String.isEmpty(diff.WortFeeTaxType__c) ? CommonConst.PROPERTY_TAXTYPE_NOTAXABLE : diff.WortFeeTaxType__c;
                    if (property.WortFeeTaxType__c != taxType) {
                        propData.WortFeeTaxType__c = taxType;
                        property.WortFeeTaxType__c = taxType;
                        IsUpsert = true;
                    }
                    // CATV
                    if (property.CATVFee__c != diff.CATVFee__c) {
                        propData.CATVFee__c = diff.CATVFee__c;
                        property.CATVFee__c = diff.CATVFee__c;
                        IsUpsert = true;
                    }
                    // CATV税区分
                    taxType = String.isEmpty(diff.CATVTaxType__c) ? CommonConst.PROPERTY_TAXTYPE_NOTAXABLE : diff.CATVTaxType__c;
                    if (property.CATVTaxType__c != taxType) {
                        propData.CATVTaxType__c = taxType;
                        property.CATVTaxType__c = taxType;
                        IsUpsert = true;
                    }
                }

                // 駐車場料金
                if (property.ParkingFee__c != diff.ParkingFee__c ) {
                    propData.ParkingFee__c = diff.ParkingFee__c;
                    property.ParkingFee__c = diff.ParkingFee__c;
                    IsUpsert = true;
                }
                
                // 駐車場料金税区分
                if(diff.ExternalSiteCd__c != CommonConst.AUTOMAINTEDIFF_SITECODE_DAIWALIVING) {// 大和リビング以外の場合
                    taxType = String.isEmpty(diff.ParkingFeeTaxType__c) ? CommonConst.PROPERTY_TAXTYPE_NOTAXABLE : diff.ParkingFeeTaxType__c;
                    if (property.ParkingFeeTaxType__c != taxType) {
                        propData.ParkingFeeTaxType__c = taxType;
                        property.ParkingFeeTaxType__c = taxType;
                        IsUpsert = true;
                    }
                } else if(!existsBuilding || !existsProperty){// 大和リビングかつ新規の場合
                    propData.ParkingFeeTaxType__c = CommonConst.PROPERTY_TAXTYPE_NOTAXABLE;
                    property.ParkingFeeTaxType__c = CommonConst.PROPERTY_TAXTYPE_NOTAXABLE;
                    IsUpsert = true;
                }
                // 鍵所在
                if (property.KeyPlace__c != diff.KeyPlace__c) {
                    propData.KeyPlace__c = diff.KeyPlace__c;
                    IsUpsert = true;
                }
            }
            //▲ 変更時項目設定　※掲載終了時以外
            
            // 現況 ※掲載終了時は"居住中"固定 
            if (diff.AutoMaintenanceType__c == CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_POSTING_END) {
                propData.LiveStatus__c = CommonConst.PROPERTY_LIVESTATUS_RESIDENT;
                IsUpsert = true;
            } else if(property.LiveStatus__c != diff.LiveStatus__c) {
                // 掲載終了時以外は、自動メンテナンスレコードで"未完成"が設定されてきた場合、"空室"固定
                if (diff.LiveStatus__c == CommonConst.PROPERTY_LIVESTATUS_INCOMPLETE){
                    propData.LiveStatus__c = CommonConst.PROPERTY_LIVESTATUS_VACANCY;
                }else{
                    // "未完成"でなければ、自動メンテナンス差分の設定値
                    propData.LiveStatus__c = diff.LiveStatus__c;
                }
                IsUpsert = true;
            }     
        
        }
        //▲ 変更時項目設定　※条件変更以外

		//▼ 変更時項目設定　※条件変更かつ掲載終了の場合 2022.04.05 No0723 対応
		if(diff.AutoMaintenanceType__c == CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_CHANGE_CONDITION ||
			diff.AutoMaintenanceType__c == CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_POSTING_END){

			propData.IsBulkConfirmation__c = false;                       // 一括確認チェック
			propData.BulkConfirmationDate__c = null;                      // 一括確認日
			propData.OwnCompanyManageModDate__c = CommonUtil.getNow();    // 自社管理修正日
			propData.TemporarySaveDate__c = null;                         // 一時保存日
			IsUpsert = true;
		}
		//▲ 変更時項目設定　※条件変更かつ掲載終了の場合 2022.04.05 No0723 対応

        //▼ 変更時項目設定　※掲載終了時以外
        if (diff.AutoMaintenanceType__c != CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_POSTING_END) {
            // 物件備考(非公開)
            if (property.PropertyRemarksPrivate__c != diff.PropertyRemarksPrivate__c) {
                propData.PropertyRemarksPrivate__c = diff.PropertyRemarksPrivate__c;
                IsUpsert = true;

                // 変更通知メッセージを設定
                if (diff.AutoMaintenanceType__c  == CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_CHANGE_CONDITION) {
                    setNoticeMsg(changeAutoMaintenanceMessageMap, diff.MaintenancePropertyCode__c, CommonConst.NOTICE_ITEM_PROP_REMARKS_PRIVATE);
                }
            }
            // 賃料
            if (property.RentFee__c != diff.RentFee__c) {
                propData.RentFee__c = diff.RentFee__c;
                property.RentFee__c = diff.RentFee__c;
                IsUpsert = true;
            }
            // 管理費
            if (property.ManagementFee__c != diff.ManagementFee__c) {
                propData.ManagementFee__c = diff.ManagementFee__c;
                property.ManagementFee__c = diff.ManagementFee__c;
                IsUpsert = true;
            }
            // 管理費税区分
            taxType = String.isEmpty(diff.ManagementFeeTaxType__c) ? CommonConst.PROPERTY_TAXTYPE_NOTAXABLE : diff.ManagementFeeTaxType__c;
            if (property.ManagementFeeTaxType__c != taxType) {
                propData.ManagementFeeTaxType__c = taxType;
                property.ManagementFeeTaxType__c = taxType;
                IsUpsert = true;
            }
            // 敷金単位
            if (property.SecurityDepositUnit__c != diff.SecurityDepositUnit__c) {
                propData.SecurityDepositUnit__c = diff.SecurityDepositUnit__c;
                property.SecurityDepositUnit__c = diff.SecurityDepositUnit__c;
                IsUpsert = true;
            }
            // 敷金(ヶ月)
            if (property.SecurityDepositMonth__c != diff.SecurityDepositMonth__c) {
                propData.SecurityDepositMonth__c = diff.SecurityDepositMonth__c;
                property.SecurityDepositMonth__c = diff.SecurityDepositMonth__c;
                // (検索用)敷金(ヵ月)
                propData.SecurityDepositMonthSearch__c = propData.SecurityDepositMonth__c == null ? 0 : propData.SecurityDepositMonth__c;
                IsUpsert = true;
            }
            // 敷金(円)
            feeAny = diff.SecurityDepositUnit__c == CommonConst.PROPERTY_FEEUNIT_MONTH
                                                ? diff.SecurityDepositMonth__c :  diff.SecurityDepositYen__c; 
            fee = calcUnitFee(diff.SecurityDepositUnit__c, feeAny, diff.RentFee__c);
            if (property.SecurityDepositYen__c != fee) {
                propData.SecurityDepositYen__c = fee;
                property.SecurityDepositYen__c = fee;
                // (検索用)敷金(円)
                propData.SecurityDepositYenSearch__c = propData.SecurityDepositYen__c == null ? 0 : propData.SecurityDepositYen__c;
                IsUpsert = true;
            }
            // 礼金単位
            if (property.KeyMoneyUnit__c != diff.KeyMoneyUnit__c) {
                propData.KeyMoneyUnit__c = diff.KeyMoneyUnit__c;
                property.KeyMoneyUnit__c = diff.KeyMoneyUnit__c;
                IsUpsert = true;
            }
            // 礼金(ヶ月)
            if (property.KeyMoneyMonth__c != diff.KeyMoneyMonth__c) {
                propData.KeyMoneyMonth__c = diff.KeyMoneyMonth__c;
                property.KeyMoneyMonth__c = diff.KeyMoneyMonth__c;
                // (検索用)礼金(ヵ月)
                propData.KeyMoneyMonthSearch__c = propData.KeyMoneyMonth__c == null ? 0 : propData.KeyMoneyMonth__c;
                IsUpsert = true;
            }
            // 礼金(円)
            feeAny = diff.KeyMoneyUnit__c == CommonConst.PROPERTY_FEEUNIT_MONTH
                                        ? diff.KeyMoneyMonth__c :  diff.KeyMoneyYen__c; 
            fee = calcUnitFee(diff.KeyMoneyUnit__c, feeAny, diff.RentFee__c);
            if (property.KeyMoneyYen__c != fee) {
                propData.KeyMoneyYen__c = fee;
                property.KeyMoneyYen__c = fee;
                // (検索用)礼金(円)
                propData.KeyMoneyYenSearch__c = propData.KeyMoneyYen__c == null ? 0 : propData.KeyMoneyYen__c;
                IsUpsert = true;
            }
            // リアプロのみ
            if (diff.ExternalSiteCd__c == CommonConst.AUTOMAINTEDIFF_SITECODE_REALNETPRO) {         
                // 保証料金単位
                if (property.DepositUnit__c != diff.DepositUnit__c) {
                    propData.DepositUnit__c = diff.DepositUnit__c;
                    property.DepositUnit__c = diff.DepositUnit__c;
                    IsUpsert = true;
                }
                // 保証料金(ヶ月)
                if (property.DepositMonth__c != diff.DepositMonth__c) {
                    propData.DepositMonth__c = diff.DepositMonth__c;
                    property.DepositMonth__c = diff.DepositMonth__c;
                    // (検索用)保証料金(ヵ月)
                    propData.DepositMonthSearch__c = propData.DepositMonth__c == null ? 0 : propData.DepositMonth__c;
                    IsUpsert = true;
                }
                // 保証料金(円)
                feeAny = diff.DepositUnit__c == CommonConst.PROPERTY_FEEUNIT_MONTH
                                            ? diff.DepositMonth__c :  diff.DepositYen__c; 
                fee = calcUnitFee(diff.DepositUnit__c, feeAny, diff.RentFee__c);
                if (property.DepositYen__c != fee) {
                    propData.DepositYen__c = fee;
                    property.DepositYen__c = fee;
                    // (検索用)保証料金(円)
                    propData.DepositYenSearch__c = propData.DepositYen__c == null ? 0 : propData.DepositYen__c;
                    IsUpsert = true;
                }
                // 敷引・償却単位
                if (property.CancellationActualFeeUnit__c != diff.CancellationActualFeeUnit__c) {
                    propData.CancellationActualFeeUnit__c = diff.CancellationActualFeeUnit__c;
                    property.CancellationActualFeeUnit__c = diff.CancellationActualFeeUnit__c;
                    IsUpsert = true;
                }
                // 敷引・償却(ヵ月)
                if (property.CancellationActualFeeMonth__c != diff.CancellationActualFeeMonth__c) {
                    propData.CancellationActualFeeMonth__c = diff.CancellationActualFeeMonth__c;
                    property.CancellationActualFeeMonth__c = diff.CancellationActualFeeMonth__c;
                    IsUpsert = true;
                }
                // 敷引・償却(%)
                if (property.CancellationActualFeeRate__c != diff.CancellationActualFeeRate__c) {
                    propData.CancellationActualFeeRate__c = diff.CancellationActualFeeRate__c;
                    property.CancellationActualFeeRate__c = diff.CancellationActualFeeRate__c;
                    IsUpsert = true;
                }
                // 敷引・償却(円)
                if (diff.CancellationActualFeeUnit__c == CommonConst.PROPERTY_FEEUNIT_MONTH) {
                    feeAny = diff.CancellationActualFeeMonth__c;
                } else if(diff.CancellationActualFeeUnit__c == CommonConst.PROPERTY_FEEUNIT_RATE) {
                    feeAny = diff.CancellationActualFeeRate__c;
                } else if(diff.CancellationActualFeeUnit__c == CommonConst.PROPERTY_FEEUNIT_YEN) {
                    feeAny = diff.CancellationActualFeeYen__c;
                }
                fee = calcUnitFee(diff.CancellationActualFeeUnit__c, feeAny, diff.RentFee__c);
                if (property.CancellationActualFeeYen__c != fee) {
                    propData.CancellationActualFeeYen__c = fee;
                    property.CancellationActualFeeYen__c = fee;
                    IsUpsert = true;
                }
                
                // 定額修繕費(円)
                feeAny = diff.CleaningFeeUnit__c == CommonConst.PROPERTY_FEEUNIT_MONTH
                                                ? diff.CleaningFeeMonth__c : diff.CleaningFeeYen__c; 
                fee = calcUnitFee(diff.CleaningFeeUnit__c, feeAny, diff.RentFee__c);
                if (property.CleaningFeeYen__c != fee) {
                    propData.CleaningFeeYen__c = fee;
                    property.CleaningFeeYen__c = fee;
                    // (検索用)定額修繕費(円)
                    propData.CleaningFeeYenSearch__c = propData.CleaningFeeYen__c == null ? 0 : propData.CleaningFeeYen__c;
                    IsUpsert = true;
                }

                // 定額修繕費(ヵ月)
                if (property.CleaningFeeMonth__c != diff.CleaningFeeMonth__c) {
                    propData.CleaningFeeMonth__c = diff.CleaningFeeMonth__c;
                    property.CleaningFeeMonth__c = diff.CleaningFeeMonth__c;
                    // (検索用)定額修繕費(ヵ月)
                    propData.CleaningFeeMonthSearch__c = propData.CleaningFeeMonth__c == null ? 0 : propData.CleaningFeeMonth__c;
                    IsUpsert = true;
                }
                // 定額修繕費単位
                if (property.CleaningFeeUnit__c != diff.CleaningFeeUnit__c) {
                    propData.CleaningFeeUnit__c = diff.CleaningFeeUnit__c;
                    property.CleaningFeeUnit__c = diff.CleaningFeeUnit__c;
                    IsUpsert = true;
                }
                // 定額修繕費税区分
                taxType = String.isEmpty(diff.CleaningFeeTaxType__c) ? CommonConst.PROPERTY_TAXTYPE_NOTAXABLE : diff.CleaningFeeTaxType__c;
                if (property.CleaningFeeTaxType__c != taxType) {
                    propData.CleaningFeeTaxType__c = taxType;
                    property.CleaningFeeTaxType__c = taxType;
                    IsUpsert = true;
                }
                // 定額修繕費支払区分
                if (property.CleaningFeePaymentType__c != diff.CleaningFeePaymentType__c) {
                    propData.CleaningFeePaymentType__c = diff.CleaningFeePaymentType__c;
                    property.CleaningFeePaymentType__c = diff.CleaningFeePaymentType__c;
                    IsUpsert = true;
                }
            }
            // 金銭備考(非公開)
            if (property.MonetaryPrivate__c != diff.MonetaryRemarksPrivate__c) {
                propData.MonetaryPrivate__c = diff.MonetaryRemarksPrivate__c;
                IsUpsert = true;
            }
            //大和リビング時に更新しない
            if(diff.ExternalSiteCd__c != CommonConst.AUTOMAINTEDIFF_SITECODE_DAIWALIVING) {  // 大和リビング以外
                // 駐車場種別
                if (property.ParkingType__c != diff.ParkingType__c) {
                    propData.ParkingType__c = diff.ParkingType__c;
                    
                    IsUpsert = true;

                    // 条件変更のみ
                    if(diff.AutoMaintenanceType__c == CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_CHANGE_CONDITION){
                        // 空白は「無」と同義
                        // 駐車場種別が違っていれば変更のメッセージをセットする。
                        String propertyParkingType =  String.isBlank(property.ParkingType__c) ? CommonConst.PROPERTY_PARKINGTYPE_NO : property.ParkingType__c;
                        String diffParkingType =  String.isBlank(diff.ParkingType__c) ? CommonConst.PROPERTY_PARKINGTYPE_NO : diff.ParkingType__c;
                        if(propertyParkingType != diffParkingType){
                            String msg = getMapValue(changeAutoMaintenanceMessageMap, diff.MaintenancePropertyCode__c);
                            List<String> msgParam = new List<String> {CommonConst.NOTICE_ITEM_PARKING_TYPE
                                                                      , propertyParkingType
                                                                      , diffParkingType};
                            msg += CommonUtil.callMessageCreate(CommonConst.MSG_PROP_I_NOTICE_UPDATE_PARAM, msgParam) + CommonConst.BREAK_CODE;
                            changeAutoMaintenanceMessageMap.put(diff.MaintenancePropertyCode__c, msg);
                        }
                        
                    }
                }
                // 近隣駐車場までの距離
                if (property.ParkingDistance__c != diff.ParkingDistance__c) {
                    propData.ParkingDistance__c = diff.ParkingDistance__c;
                    IsUpsert = true;
                }
            }
            
            // 駐車場備考(非公開)
            if (property.ParkingRemarksPrivate__c != diff.ParkingRemarksPrivate__c) {
                propData.ParkingRemarksPrivate__c = diff.ParkingRemarksPrivate__c;
                IsUpsert = true;
            }

            // リアプロのみ
            if (diff.ExternalSiteCd__c == CommonConst.AUTOMAINTEDIFF_SITECODE_REALNETPRO) {        
                // 報酬負担貸主
                if (property.RewardBurdenLender__c != diff.RewardBurdenLender__c) {
                    propData.RewardBurdenLender__c = diff.RewardBurdenLender__c;
                    IsUpsert = true;
                }

				//▼ 条件変更のみ時、報酬負担借主は変更しない 2022/04/06 No0723　対応
				if(diff.AutoMaintenanceType__c != CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_CHANGE_CONDITION){
					 // 報酬負担借主
					 if (property.RewardBurdenBorrower__c != diff.RewardBurdenBorrower__c) {
						propData.RewardBurdenBorrower__c = diff.RewardBurdenBorrower__c;
						IsUpsert = true;
					}
				}
				//▲ 条件変更のみ時、報酬負担借主は変更しない 2022/04/06 No0723　対応

                // 報酬配分元付
                if (property.RewardSplitFormerSupplier__c != diff.RewardSplitFormerSupplier__c) {
                    propData.RewardSplitFormerSupplier__c = diff.RewardSplitFormerSupplier__c;
                    IsUpsert = true;
                }
                // 報酬配分客付
                if (property.RewardSplitCustomer__c != diff.RewardSplitCustomer__c) {
                    propData.RewardSplitCustomer__c = diff.RewardSplitCustomer__c;
                    IsUpsert = true;
                }
                // 広告料単位
                if (property.ADFeeUnit__c != diff.ADFeeUnit__c) {
                    propData.ADFeeUnit__c = diff.ADFeeUnit__c;
                    property.ADFeeUnit__c = diff.ADFeeUnit__c;
                    IsUpsert = true;
                }
                // 広告料(ヵ月)
                if (property.ADFeeMonth__c != diff.ADFeeMonth__c) {
                    propData.ADFeeMonth__c = diff.ADFeeMonth__c;
                    property.ADFeeMonth__c = diff.ADFeeMonth__c;
                    IsUpsert = true;
                }
                // 広告料(%)
                if (property.ADFeeRate__c != diff.ADFeeRate__c) {
                    propData.ADFeeRate__c = diff.ADFeeRate__c;
                    property.ADFeeRate__c = diff.ADFeeRate__c;
                    IsUpsert = true;
                }
                // 広告料税区分
                taxType = String.isEmpty(diff.ADFeeTaxType__c) ? CommonConst.PROPERTY_TAXTYPE_TAXINCLUDED : diff.ADFeeTaxType__c;
                if (property.ADFeeTaxType__c != taxType) {
                    propData.ADFeeTaxType__c = taxType;
                    property.ADFeeTaxType__c = taxType;
                    IsUpsert = true;
                }
                // 広告料(円)
                if (diff.ADFeeUnit__c == CommonConst.PROPERTY_FEEUNIT_MONTH) {
                    feeAny = diff.ADFeeMonth__c;
                } else if(diff.ADFeeUnit__c == CommonConst.PROPERTY_FEEUNIT_RATE) {
                    feeAny = diff.ADFeeRate__c;
                } else if(diff.ADFeeUnit__c == CommonConst.PROPERTY_FEEUNIT_YEN) {
                    feeAny = diff.ADFeeYen__c;
                }
                fee = calcUnitFee(diff.ADFeeUnit__c, feeAny, diff.RentFee__c);
                if (property.ADFeeYen__c != fee) {
                    propData.ADFeeYen__c = fee;
                    property.ADFeeYen__c = fee;
                    IsUpsert = true;
                }
            }
            // 広告備考(非公開)
            if (property.ADRemarksPrivate__c != diff.ADRemarksPrivate__c) {
                propData.ADRemarksPrivate__c = diff.ADRemarksPrivate__c;
                IsUpsert = true;
            }

            // その他の税区分
            if (!existsBuilding || !existsProperty) {
                    propData.GarbageDisposalFeeTaxType__c = CommonConst.PROPERTY_TAXTYPE_NOTAXABLE;         // ゴミ処理費税区分
                    propData.TownshipInitialFeeTaxType__c = CommonConst.PROPERTY_TAXTYPE_NOTAXABLE;         // 入町費税区分
                    propData.BicycleParkingFeeTaxType__c = CommonConst.PROPERTY_TAXTYPE_NOTAXABLE;          // 駐輪場代税区分
                    propData.ParkingDepositTaxType__c = CommonConst.PROPERTY_TAXTYPE_NOTAXABLE;             // 駐車場保証料金税区分
                    propData.ParkingCompoundingFeeTaxType__c = CommonConst.PROPERTY_TAXTYPE_NOTAXABLE;      // 駐車場手数料税区分
                    propData.BikeParkingSmallFeeTaxType__c = CommonConst.PROPERTY_TAXTYPE_NOTAXABLE;        // 小型バイク置場料金税区分
                    propData.BikeParkingMediumFeeTaxType__c = CommonConst.PROPERTY_TAXTYPE_NOTAXABLE;       // 中型バイク置場料金税区分
                    propData.BikeParkinLargeFeeTaxType__c = CommonConst.PROPERTY_TAXTYPE_NOTAXABLE;         // 大型バイク置場料金税区分
                    property.GarbageDisposalFeeTaxType__c = CommonConst.PROPERTY_TAXTYPE_NOTAXABLE;         // ゴミ処理費税区分
                    property.TownshipInitialFeeTaxType__c = CommonConst.PROPERTY_TAXTYPE_NOTAXABLE;         // 入町費税区分
                    property.BicycleParkingFeeTaxType__c = CommonConst.PROPERTY_TAXTYPE_NOTAXABLE;          // 駐輪場代税区分
                    property.ParkingDepositTaxType__c = CommonConst.PROPERTY_TAXTYPE_NOTAXABLE;             // 駐車場保証料金税区分
                    property.ParkingCompoundingFeeTaxType__c = CommonConst.PROPERTY_TAXTYPE_NOTAXABLE;      // 駐車場手数料税区分
                    property.BikeParkingSmallFeeTaxType__c = CommonConst.PROPERTY_TAXTYPE_NOTAXABLE;        // 小型バイク置場料金税区分
                    property.BikeParkingMediumFeeTaxType__c = CommonConst.PROPERTY_TAXTYPE_NOTAXABLE;       // 中型バイク置場料金税区分
                    property.BikeParkinLargeFeeTaxType__c = CommonConst.PROPERTY_TAXTYPE_NOTAXABLE;         // 大型バイク置場料金税区分
                    IsUpsert = true;
            }
            
            // (検索用)賃料 関連
            Decimal calcRentFee       = property.RentFee__c       != diff.RentFee__c       ? propData.RentFee__c       : property.RentFee__c;       //賃料
            Decimal calcManagementFee = property.ManagementFee__c != diff.ManagementFee__c ? propData.ManagementFee__c : property.ManagementFee__c; //管理費
            Decimal calcParkingFee    = property.ParkingFee__c    != diff.ParkingFee__c    ? propData.ParkingFee__c    : property.ParkingFee__c;    //駐車場
   
            //条件変更の場合は、現在の物件データの駐車場料金を使う(駐車場料金を更新しないため)
            if(diff.AutoMaintenanceType__c == CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_CHANGE_CONDITION){
                calcParkingFee = property.ParkingFee__c;
            }

            calcRentFee       = calcRentFee       == null ? 0 : calcRentFee;        //賃料
            calcManagementFee = calcManagementFee == null ? 0 : calcManagementFee;  //管理費
            calcParkingFee    = calcParkingFee    == null ? 0 : calcParkingFee;     //駐車場
        
            propData.RentFeeSearch__c                  = calcRentFee;                                      //賃料
            propData.RentFeeSearchManagement__c        = calcRentFee + calcManagementFee;                  //賃料管理費込
            propData.RentFeeSearchParking__c           = calcRentFee +                     calcParkingFee; //賃料駐車場込          
            propData.RentFeeSearchManagementParking__c = calcRentFee + calcManagementFee + calcParkingFee; //賃料管理費駐車場込
            
        }
        //▲ 変更時項目設定　※掲載終了時以外


        // web公開
        if (!existsBuilding || !existsProperty ||
           (diff.AutoMaintenanceType__c == CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_CHANGE_CONDITION && diff.WebPublishing__c == commonConst.PROPERTY_WEBPUBLISHING_NO && property.IsPermissionPublishing__c == false) ||
            diff.AutoMaintenanceType__c == CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_LIVESTATUS_EMPTY ||
            diff.AutoMaintenanceType__c == CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_POSTING_END) {
            propData.WebPublishing__c = CommonConst.PROPERTY_WEBPUBLISHING_NO;
            IsUpsert = true;
            }
        
        // 間取り図を設定
        if (property.AutoMaintenanceDiffRoomLayoutFileName__c != diff.RoomLayoutFileName__c
            || property.AutoMaintenanceDiffRoomLayoutFileName__c == CommonConst.PROPERTYPHOTO_ROOM_LAYOUT_FILE_NAME_DEFAULT) {
            propData.AutoMaintenanceDiffRoomLayoutFileName__c = diff.RoomLayoutFileName__c;
            IsUpsert = true;

            // 変更通知メッセージを設定
            if (diff.AutoMaintenanceType__c == CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_CHANGE_CONDITION
                && property.AutoMaintenanceDiffRoomLayoutFileName__c != CommonConst.PROPERTYPHOTO_ROOM_LAYOUT_FILE_NAME_DEFAULT) {
                setNoticeMsg(changeAutoMaintenanceMessageMap, diff.MaintenancePropertyCode__c, CommonConst.NOTICE_ITEM_ROOM_LAYOUT);
            }
        }

        // 返却
        return propData;
    }
    

    /**
     * 物件条件の項目設定
     * @param  Id                                   propId      物件Id
     * @param  PropertyConditions__c                oldPropCond 物件条件
     * @param  t_auto_maintenance_difference__c     diff        自動メンテナンス差分(クローリングのデータ)
     * @param  Boolean                              existsBuilding  既存の建物の存在有無
     * @param  Boolean                              existsProperty  既存の物件の存在有無
     * @param  Map<String, String>                  changeAutoMaintenanceMessageMap  物件条件と自動メンテナンス差分の相違メッセージ取得
     * @return PropertyConditions__c                            物件条件の更新値
     */
    private static PropertyConditions__c setPropCondData(Id propId, PropertyConditions__c oldPropCond, t_auto_maintenance_difference__c diff, Boolean existsBuilding, Boolean existsProperty
                                                         , Map<String, String> changeAutoMaintenanceMessageMap){
        PropertyConditions__c propCondData = new PropertyConditions__c();

        // ▼ 共通設定項目
        propCondData.Id          = oldPropCond.Id;  // 物件条件ID
        propCondData.Property__c = propId;          // 物件ID
        // ▲ 共通設定項目

        //▼問合せ400で変更
        // ▼ 新規登録時項目設定
        if (!existsBuilding || !existsProperty) {
            if(diff.ExternalSiteCd__c == CommonConst.AUTOMAINTEDIFF_SITECODE_REALNETPRO){         // リアプロ
            	// 設備設定
                BuildingPropertyUtil.setFacility(propCondData, diff.Facility__c, ';');
            }
            propCondData.IsITImportantDescription__c = true;
            IsUpsert = true;
        }
        // ▲ 新規登録時項目設定
        //▲問合せ400で変更
  
        // ▼ 変更時設定項目
        if (oldPropCond.FacilityRemarksPrivate__c != diff.FacilityRemarksPrivate__c) {
            propCondData.FacilityRemarksPrivate__c = diff.FacilityRemarksPrivate__c;    // 設備備考(非公開)
            IsUpsert = true;

            // 変更通知メッセージを設定
            if (diff.AutoMaintenanceType__c  == CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_CHANGE_CONDITION) {
                setNoticeMsg(changeAutoMaintenanceMessageMap, diff.MaintenancePropertyCode__c, CommonConst.NOTICE_ITEM_FACILITY_REMARKS_PRIVATE);
            }
        }
        // ▲ 変更時設定項目

        // 返却
        return propCondData;
    }
    
    
    /**
     * 部屋の項目設定
     * @param  ID                                   PropertyId   物件ID
     * @param  t_auto_maintenance_difference__c     diff        自動メンテナンス差分(クローリングのデータ)
     * @return List<Room__c>                                    部屋の登録値
     */
    private static List<Room__c> setRoomData(Id PropertyId, t_auto_maintenance_difference__c diff) {
        List<Room__c> roomList = new List<Room__c>();

        // 部屋数分LOOP
        for (Integer i = 1; i <= MAX_ROOOM_COUNT; i++) {
            Room__c room = new Room__c();

            // 自動メンテナンス差分よりデータ取得
            String  roomType  = (String)diff.get('RoomType' + i + '__c');
            Decimal roomSpace = (Decimal)diff.get('RoomFloorSpace' + i + '__c');
            // 設定有無チェック ※データが無ければ処理終了
            if (String.isEmpty(roomType) && roomSpace == null){
                break;
            }

            // 値を設定&リストへ追加
            room.Property__c       = PropertyId;    // 物件ID
            room.RoomType__c       = roomType;      // 部屋タイプ
            room.RoomFloorSpace__c = roomSpace;     // 部屋帖数
            roomList.add(room);
        }

        // 返却
        return roomList;
    }

    /**
     * 自動メンテナンスの項目設定
     * @param  ID       buidingId       建物ID
     * @param  ID       propertyId      物件ID
     * @param  ID       supplierId       元付業者ID
     * @param  t_auto_maintenance_difference__c     diff        自動メンテナンス差分(クローリングのデータ)
     * @return AutoMaintenance__c                               自動メンテナンスの登録値
     */
    private static AutoMaintenance__c setAutoMaintData(Id buidingId, Id propertyId, Id supplierId, t_auto_maintenance_difference__c diff) {
        AutoMaintenance__c autoMaint = new AutoMaintenance__c();


        // 条件別設定項目
        setAutoMaintenanceType(autoMaint, diff);// 種別
        setAutoMaintenanceCrawlingSource(autoMaint, diff);// クローリング元

        // 共通設定項目
        setAutoMaintenanceName(autoMaint, diff);// Name
        
        autoMaint.Building__c        = buidingId;                       // 建物ID
        autoMaint.Property__c        = propertyId;                      // 物件ID
        autoMaint.FormerSupplier__c  = supplierId;                      // 元付業者ID
        autoMaint.ImportDatetime__c  = diff.InfoModifiedDate__c;        // 取込日
        String autoMaintenance = String.isBlank(diff.AutoMaintenanceContent__c) ? '' : diff.AutoMaintenanceContent__c ;
        autoMaint.AutoMaintenance__c = autoMaintenance ;                // 自動メンテナンス内容
        autoMaint.IsCompletedFlag__c = false;                           // 完了フラグ

        // 返却
        return autoMaint;
    }
    

   /**
     * 自動メンテナンス項目設定　種別
     * @param  autoMaint   自動メンテナンス(更新する項目)
     * @param  diff        自動メンテナンス差分(クローリングのデータ)
     */
    private static void setAutoMaintenanceType(AutoMaintenance__c autoMaint, t_auto_maintenance_difference__c diff) {
        
        if (diff.AutoMaintenanceType__c == CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_NEW ||
            diff.AutoMaintenanceType__c == CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_PROPERTY_NEW) {
            // 1:新規 or 2:物件新規 ⇒ 新規追加
            autoMaint.Type__c = CommonConst.AUTOMAINTENANCE_TYPE_ADDNEW;
        } else if(diff.AutoMaintenanceType__c == CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_CHANGE_CONDITION) {
            // 3:条件変更 ⇒ 更新(条件変更)
            autoMaint.Type__c = CommonConst.AUTOMAINTENANCE_TYPE_CONDITIONCHANGEUPDATE;
        } else if(diff.AutoMaintenanceType__c == CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_LIVESTATUS_EMPTY) {
            // 4:居住中→空室 ⇒ 更新(居住中→空室)
            autoMaint.Type__c = CommonConst.AUTOMAINTENANCE_TYPE_OCCUPIEDTOVACANTUPDATE;
        } else if(diff.AutoMaintenanceType__c == CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_POSTING_END) {
            // 5:掲載終了 ⇒ 掲載終了
            autoMaint.Type__c = CommonConst.AUTOMAINTENANCE_TYPE_ENDOFPOSTING;
        }
        
    }

   /**
     * 自動メンテナンス項目設定　クローリング元
     * @param  autoMaint   自動メンテナンス(更新する項目)
     * @param  diff        自動メンテナンス差分(クローリングのデータ)
     */
    private static void setAutoMaintenanceCrawlingSource(AutoMaintenance__c autoMaint, t_auto_maintenance_difference__c diff) {
        if (diff.ExternalSiteCd__c == CommonConst.AUTOMAINTEDIFF_SITECODE_REALNETPRO) {
            autoMaint.CrawlingSource__c = CommonConst.AUTOMAINTENANCE_CRAWLING_SOURCE_REALPRO;
        } else if(diff.ExternalSiteCd__c == CommonConst.AUTOMAINTEDIFF_SITECODE_DAIWALIVING) {
            autoMaint.CrawlingSource__c = CommonConst.AUTOMAINTENANCE_CRAWLING_SOURCE_DAIWALIVING;
        }
    }

   /**
     * 自動メンテナンス項目設定　クローリング元
     * @param  autoMaint   自動メンテナンス(更新する項目)
     * @param  diff        自動メンテナンス差分(クローリングのデータ)
     */
    private static void setAutoMaintenanceName(AutoMaintenance__c autoMaint, t_auto_maintenance_difference__c diff) {
        
        //NameのString作成
        String autoMaintName = CommonConst.STRING_EMPTY;
        autoMaintName       += autoMaint.CrawlingSource__c == null ? CommonConst.STRING_EMPTY : autoMaint.CrawlingSource__c;
        autoMaintName       += String.isEmpty(autoMaintName)       ? CommonCOnst.STRING_EMPTY : ':';
        autoMaintName       += autoMaint.Type__c == null           ? CommonConst.STRING_EMPTY : autoMaint.Type__c;
        autoMaintName       += String.isEmpty(autoMaintName)       ? CommonCOnst.STRING_EMPTY : ':';
        autoMaintName       += diff.CrawlingId__c == null          ? CommonConst.STRING_EMPTY : String.valueOf(diff.CrawlingId__c);
        
        //Name項目に設定
        autoMaint.Name               = autoMaintName;
    }

    /**
     * 料金の単位計算
     * @param  String   feeUnit     料金の単位（円,ヵ月,%,実費）
     * @param  Decimal  feeAny      円,　ヵ月,　%　いずれかの値
     * @param  Decimal  rentFee     賃料
     * @return Decimal              計算結果
     */
    private static Decimal calcUnitFee(String feeUnit, Decimal feeAny, Decimal rentFee) {
        // 計算不要の場合は対応値を返却
        // 単位「円」は計算不要
        if (feeUnit == CommonConst.PROPERTY_FEEUNIT_YEN) {
            return feeAny;
        }
        // 単位「実費」は空白
        if (feeUnit == CommonConst.PROPERTY_FEEUNIT_ACTUALCOST) {
            return null;
        }
        // 入力値null/空は空白
        if (feeAny == null) {
            return null;
        }
        // 賃料null/空は空白
        if (rentFee == null) {
            return null;
        }

        // 金額計算
        Decimal calcFee;
        if (feeUnit == CommonConst.PROPERTY_FEEUNIT_MONTH) {
            // 単位「ヵ月」
            // 計算 賃料×ヵ月
            calcFee = rentFee * feeAny;
            // 切り上げ
            calcFee = calcFee.round(System.RoundingMode.UP);
        } else if (feeUnit == CommonConst.PROPERTY_FEEUNIT_RATE) {
            // 単位「％」
            // 計算 賃料×％÷100
            calcFee = rentFee * feeAny / 100;
            // 切り上げ
            calcFee = calcFee.round(System.RoundingMode.UP);
        }
        // 計算値返却
        return calcFee;
    }

    /**
     * 住所より都道府県を取得する
     * @param  List<String>   cityList      都道府県リスト
     * @param  String         address       分割対象の住所
     * @return String                       都道府県
     */
    private static String getState(List<String> stateList, String address) {
        String state;

        // NULLならばそのまま返却
        if (String.isBlank(address)) {
            return address;
        }

        // 正規表現文字列作成
        String stateRegStr = String.join(stateList, '|');
        stateRegStr = '^(' + stateRegStr + ')';

        //住所より、都道府県を取得
        Pattern statePattern = Pattern.compile(stateRegStr);
        Matcher stateMatcher   = statePattern.matcher(address);
        if (stateMatcher.find()) {
            state = stateMatcher.group();
        }
        return state;
    }

    /**
     * クローリング写真のフォルダパス取得
     * @param  t_auto_maintenance_difference__c obj 自動メンテナンス差分(クローリングのデータ)
     * @return folderPath                           フォルダ
     */
    private static String getCrowlingFolderPath(t_auto_maintenance_difference__c obj) {
        String folderPath = CommonConst.STRING_EMPTY;
        if (obj.ExternalSiteCd__c == CommonConst.AUTOMAINTEDIFF_SITECODE_REALNETPRO) {         // リアプロ
            folderPath = S3FOLDERPATH_REALNETPRO;
        } else if(obj.ExternalSiteCd__c == CommonConst.AUTOMAINTEDIFF_SITECODE_DAIWALIVING) {  // 大和リビング
            if (!String.isBlank(obj.MaintenanceSupplierCode__c)) {
                List<String> businessCode = obj.MaintenanceSupplierCode__c.split('-');
                folderPath = String.join(new List<String>{S3FOLDERPATH_DAIWALIVING, businessCode[1], '/'}, '');
            }
        }
        return folderPath;
    }

    
    //********************************************************************************  バッチ用メソッド  *************************************************************************************************
    
    
    /**
     * 自動メンテナンス差分ステータスの更新
     * @param  targetList   更新対象の自動メンテナンス差分のList
     * @param  batchStatus  更新するステータス名
     * @param  Map<String, String>       changeAutoMaintenanceMessageMap  設備と条件との相違、駐車場種別相違メッセージ取得
     */
    public static void updateBatchStatus(List<t_auto_maintenance_difference__c> targetList, String batchStatus, Map<Id, String> autoBuildingIdMap, Map<String, String> changeAutoMaintenanceMessageMap) {
        //更新用変数の宣言
        List<t_auto_maintenance_difference__c> updateList = new List<t_auto_maintenance_difference__c>();
        
        //更新対象の作成
        for (t_auto_maintenance_difference__c target: targetList) {
            t_auto_maintenance_difference__c updateData = new t_auto_maintenance_difference__c();
            updateData.Id             = target.Id;
            updateData.BatchStatus__c = batchStatus;
            updateData.BuildingId__c  = autoBuildingIdMap.get(target.Id);
            // 物件条件の変更がある場合に自動メンテナンス内容を追記する。
            if (target.AutoMaintenanceType__c == CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_CHANGE_CONDITION) {
                updateData.AutoMaintenanceContent__c = setAutoMaintenanceContent(target,changeAutoMaintenanceMessageMap);
            }

            updateList.add(updateData);
        }
        
        //更新
        if (!updateList.isEmpty()) {
            SecureDML.secureUpdate(updateList);
        }
    }
    public static void updateBatchStatus(List<t_auto_maintenance_difference__c> targetList, String batchStatus) {
        
        //更新用変数の宣言
        List<t_auto_maintenance_difference__c> updateList = new List<t_auto_maintenance_difference__c>();
        
        //更新対象の作成
        for (t_auto_maintenance_difference__c target: targetList) {
            t_auto_maintenance_difference__c updateData = new t_auto_maintenance_difference__c(
                Id = target.Id
                ,BatchStatus__c = batchStatus 
            );
            updateList.add(updateData);
        }
        
        //更新
        if (!updateList.isEmpty()) {
            SecureDML.secureUpdate(updateList);
        }
    }

    /**
     * 自動メンテナンス作成（エラー用）
     * @param  diff         自動メンテナンス差分(クローリングのデータ)
     * @param  errorMessage エラーメッセージ
     * @param   Map<String, Property__c>        buildingMap  建物Map
     * @param   Map<String, Property__c>        propertyMap  物件Map
     * @param   Map<String, Account>            propPhotoMap 業者Map
     */
    public static void insertErrorAutoMaintenance(List<t_auto_maintenance_difference__c> diffList, Map<Id, String> errorMessageMap, Map<String, Building__c> buildingMap, Map<String, Property__c> propertyMap, Map<String, Account> supplierMap) {
        //登録用変数宣言
        List<AutoMaintenance__c> insertAutoMaintenanceList = new List<AutoMaintenance__c>();
        
        //登録データの作成
        for (t_auto_maintenance_difference__c diff: diffList) {
            String errorMessage = 'エラーが発生しました。システム管理者に連絡してください。' + '\n'
                                + getErrMsgDiffInfo(diff, propertyMap)
                                + errorMessageMap.get(diff.Id);
            AutoMaintenance__c autoMainte = setAutoMaintDataForError(diff, errorMessage);
            if (buildingMap.containskey(diff.MaintenanceBuildingCode__c)) {
                autoMainte.Building__c = buildingMap.get(diff.MaintenanceBuildingCode__c).Id;                       // 建物ID
            }
            if (propertyMap.containskey(diff.MaintenancePropertyCode__c)) {
                autoMainte.Property__c = propertyMap.get(diff.MaintenancePropertyCode__c).Id;                      // 物件ID
            }
            if (supplierMap.containskey(diff.MaintenanceSupplierCode__c)) {
                autoMainte.FormerSupplier__c = supplierMap.get(diff.MaintenanceSupplierCode__c).Id;                // 元付業者ID
            }
            insertAutoMaintenanceList.add(autoMainte);
        }
        //登録
        if (!insertAutoMaintenanceList.isEmpty()) {
            SecureDML.secureInsert(insertAutoMaintenanceList);
        }
    }
    public static void insertErrorAutoMaintenance(List<t_auto_maintenance_difference__c> diffList, Map<Id, String> errorMessageMap) {

        // 変換情報の設定
        setConvInfo(diffList);

        // コードSetを取得
        Set<String> buildingCodeSet = new Set<String>(); // 建物
        Set<String> propertyCodeSet = new Set<String>(); // 物件
        for (t_auto_maintenance_difference__c diff : diffList) {
            if(String.isNotBlank(diff.MaintenanceBuildingCode__c)){
                buildingCodeSet.add(diff.MaintenanceBuildingCode__c);
            }
            if(String.isNotBlank(diff.MaintenancePropertyCode__c)){
                propertyCodeSet.add(diff.MaintenancePropertyCode__c);
            }
        }

        // 建物を取得（Key:メンテナンス建物コード、Value:建物）
        Map<String, Building__c> buildingMap = selectBuildingMap(buildingCodeSet);

        // 物件を取得（Key:メンテナンス物件コード、Value:物件）
        Map<String, Property__c> propertyMap = selectPropertyMap(propertyCodeSet);

        //登録用変数宣言
        List<AutoMaintenance__c> insertAutoMaintenanceList = new List<AutoMaintenance__c>();
        
        //登録データの作成
        AutoMaintenance__c autoMaintenance = new AutoMaintenance__c();
        for (t_auto_maintenance_difference__c diff: diffList) {
            String errorMessage = 'エラーが発生しました。システム管理者に連絡してください。' + '\n'
                                + getErrMsgDiffInfo(diff, propertyMap)
                                + errorMessageMap.get(diff.Id);
        
            // 自動メンテナンスの項目設定
            autoMaintenance = setAutoMaintDataForError(diff, errorMessage);

            // 地区を設定
            if (buildingMap.containskey(diff.MaintenanceBuildingCode__c)) {
                autoMaintenance.Building__c = buildingMap.get(diff.MaintenanceBuildingCode__c).Id;
            } else {
                // 新規作成でのエラー時は地区（エラー時）を参照
                autoMaintenance.DistrictError__c = CommonUtil.getDistrict(String.join(new List<String>{diff.City__c, diff.Street__c}, ''), districtList);
            }
            insertAutoMaintenanceList.add(autoMaintenance);
        }
        
        //登録
        if (!insertAutoMaintenanceList.isEmpty()) {
            SecureDML.secureInsert(insertAutoMaintenanceList);
        }
    }

    /**
     * 自動メンテナンスの項目設定（エラー用）
     * @param  diff         自動メンテナンス差分(クローリングのデータ)
     * @param  errorMessage エラーメッセージ
     * @return AutoMaintenance__c 新規作成した自動メンテナンス
     */
    private static AutoMaintenance__c setAutoMaintDataForError(t_auto_maintenance_difference__c diff, String errorMessage) {
        AutoMaintenance__c autoMaint = new AutoMaintenance__c();

        //条件別設定項目
        setAutoMaintenanceType(autoMaint, diff);           // 種別
        setAutoMaintenanceCrawlingSource(autoMaint, diff); // クローリング元

        //共通設定項目
        setAutoMaintenanceName(autoMaint, diff);           // Name
        
        autoMaint.ImportDatetime__c  = diff.InfoModifiedDate__c;        // 取込日
        autoMaint.IsCompletedFlag__c = false;                           // 完了フラグ
        autoMaint.AutoMaintenance__c = errorMessage;                    // 自動メンテナンス内容
        
        //エラー用項目
        autoMaint.AutoMaintenanceDifference__c = diff.Id;               // 自動メンテナンス差分
        
        // 返却
        return autoMaint;
    }

    /**
     * 処理不要判定と自動メンテナンス差分の後処理
     * @param  t_auto_maintenance_difference__c[]   autoMainteDiff      自動メンテナンス差分
     * @param  Map<String, Building__c>             atabaseBuildingMap  建物
     * @param  Map<String, Property__c>             databasePropertyMap 物件
     * @return Boolean                              true:連携不要, false:連携必要
     */
    private static Boolean isUnnecessaryData(t_auto_maintenance_difference__c[] autoMainteDiff, Map<String, Building__c> databaseBuildingMap, Map<String, Property__c> databasePropertyMap) {
        // 返却値初期化（処理必要）
        Boolean isUnnecessary = false;

        // 建物存在なしフラグ（メンテナンスコードがありデータ存在しない）
        Boolean isBuildingNotExists = autoMainteDiff[0].MaintenanceBuildingCode__c != null && databaseBuildingMap.size() == 0;
        // 物件存在なしフラグ（メンテナンスコードがありデータ存在しない）
        Boolean isPropertyNotExists = autoMainteDiff[0].MaintenancePropertyCode__c != null && databasePropertyMap.size() == 0;

        // 掲載終了 で メンテナンスコードに紐づく建物、物件がなければ処理不要
        if (autoMainteDiff[0].AutoMaintenanceType__c == CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_POSTING_END
        && (isBuildingNotExists || isPropertyNotExists)) {
            isUnnecessary = true;
        }

        // 条件変更、居住中→空室 で メンテナンスコードに紐づく建物、物件がなければ処理不要
        if ((autoMainteDiff[0].AutoMaintenanceType__c == CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_CHANGE_CONDITION
            || autoMainteDiff[0].AutoMaintenanceType__c == CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_LIVESTATUS_EMPTY)
        && (isBuildingNotExists || isPropertyNotExists)) {
            isUnnecessary = true;
        }

        // 処理不要であれば自動メンテナンス差分を処理
        if (isUnnecessary) {
            // 自動メンテナンス差分 ステータス更新（処理終了）
            updateBatchStatus(autoMainteDiff, CommonConst.AUTOMAINTEDIFF_BATCHSTATUS_S);
            // 自動メンテナンス差分削除
            deleteAutoMaintenanceDifference(autoMainteDiff);
        }

        return isUnnecessary;
    }

    /**
     * 自動メンテナンス差分の内容に物件条件と設備で相違となった文言をセットする（自動メンテナンスの内容に追加する用）。
     * @param  t_auto_maintenance_difference__c target                      更新対象の自動メンテナンス差分のList
     * @param  Map<String, String>              changeAutoMaintenanceMessageMap  設備と条件との相違、駐車場種別との相違メッセージ取得
     * @return String                                                       自動メンテナンス内容＋差異のあったメッセージ
     */
    private static String setAutoMaintenanceContent(t_auto_maintenance_difference__c target,Map<String, String> changeAutoMaintenanceMessageMap){
        String autoMaintenanceContent = String.isBlank(target.AutoMaintenanceContent__c) ? '' : target.AutoMaintenanceContent__c + commonConst.BREAK_CODE ;
        autoMaintenanceContent += String.isBlank(changeAutoMaintenanceMessageMap.get(target.MaintenancePropertyCode__c)) ? '' : changeAutoMaintenanceMessageMap.get(target.MaintenancePropertyCode__c) ;
        return autoMaintenanceContent;
    } 

    /**
     * 通知メッセージを設定
     * @param  Map<String, String> changeAutoMaintenanceMessageMap 自動メンテナンス条件との相違メッセージ
     * @param  String              mapKey                          自動メンテナンス条件との相違メッセージのKey
     * @param  String              itemName                        相違メッセージ用項目名
     */
    private static void setNoticeMsg(Map<String, String> changeAutoMaintenanceMessageMap, String mapKey, String itemName) {

        // 累積メッセージを取得
        String msg = getMapValue(changeAutoMaintenanceMessageMap, mapKey);

        // 追加メッセージを付与
        msg += CommonUtil.callMessageCreate(CommonConst.MSG_PROP_I_NOTICE_UPDATE, itemName) + CommonConst.BREAK_CODE;

        // 通知メッセージを設定
        changeAutoMaintenanceMessageMap.put(mapKey, msg);
    }

    /**
     * マップの値を取得
     * @param  Map<String, String> changeAutoMaintenanceMessageMap 自動メンテナンス条件との相違メッセージ
     * @param  String              mapKey                          自動メンテナンス条件との相違メッセージのKey
     */
    private static String getMapValue(Map<String, String> changeAutoMaintenanceMessageMap, String mapKey) {
        return (changeAutoMaintenanceMessageMap.containsKey(mapKey)) ? changeAutoMaintenanceMessageMap.get(mapKey):
                                                                       CommonConst.STRING_EMPTY;
    }
    
    /**
     * エラーメッセージ（自動メンテナンス差分情報）を取得
     * @param  t_auto_maintenance_difference__c diff        自動メンテナンス差分
     * @param  Map<Id, String>                  propertyMap 物件情報（Key:メンテナンス物件コード、Value:物件）
     * @return String                                       エラーメッセージ（自動メンテナンス差分情報）
     */
    private static String getErrMsgDiffInfo(t_auto_maintenance_difference__c diff, Map<String, Property__c> propertyMap) {

        // 物件コードを取得
        String propCd = CommonConst.STRING_EMPTY;
        if (propertyMap.containsKey(diff.MaintenancePropertyCode__c)) {
            propCd = propertyMap.get(diff.MaintenancePropertyCode__c).PropertyCode__c;
        }

        // エラーメッセージリスト
        List<String> errMsgList = new List<String> {propCd                      // 物件コード
                                                    , diff.BuildingName__c      // 建物名
                                                    , diff.PropertyName__c      // 号室
                                                    , diff.PropertyDetailUrl__c // 物件詳細画面URL
                                                   };

        // 改行区切りで表示
        String result = CommonConst.STRING_EMPTY;
        for (String msg : errMsgList) {

            if (String.isBlank(msg)) {
                continue;
            }
            result += msg + CommonConst.LINE_FEED;
        }

        return result;        
    }

	//▼ No.614 エラーメール送信追加
	/**
	 * 自動メンテナンスエラーメール送信
	 * @param  string errorMessage エラーメッセージ
	 * @return なし
	 */   
	private static void sendIncomingMailErrors(string errorMessage){
		// カスタム設定「エラーメール送信先」取得
		String errorEmailDestination = SystemConfig__c.getInstance().ErrorEmailDestination__c;
		// システム管理者のメールアドレスを取得
		List<String> systemEmailList = CommonUtil.getAdministratorMailList();
		if(String.isNotEmpty(errorEmailDestination)){
			// カスタム設定「エラーメール送信先」があればリストに含める。
			systemEmailList.add(errorEmailDestination);
		}
					
		// エラーメール送信
		MailUtil.MailData errorMailData = new MailUtil.MailData();
		errorMailData.toAddress = systemEmailList;
		errorMailData.ccAddress = null;
		errorMailData.fromAddress = null;
		errorMailData.subject = CommonConst.MSG_ACC_E_RECEIVE_MAIL_ERROR;
		errorMailData.textBody = errorMessage;

		MailUtil.sendMail(new List<MailUtil.MailData> {errorMailData});
			
	}
	//▲ No.614 エラーメール送信追加

    /**
     * 変換情報
     * ※自動メンテナンスのバッチサイズが1件の為、変換情報も1件を対象に作成
     */
    public class ConvInfo {

        /** メンテナンス建物コード情報 */
        private Map<String, Id> maintBuildCdToBuildIdMap { get; set;} // メンテナンス建物コード → 建物ID
        private Map<Id, String> buildIdToMaintBuildCdMap { get; set;} // 建物ID → メンテナンス建物コード

        /** メンテナンス物件コード情報 */
        private Map<String, Id> maintPropCdToPropIdMap   { get; set;} // メンテナンス物件コード → 物件ID
        private Map<Id, String> propIdToMaintPropCdMap   { get; set;} // 物件ID → メンテナンス物件コード

        /**
         * コンストラクタ
         * @param List<BuildingCodeHistory__c> buildCdHistList 建物コード履歴
         * @param List<PropertyCodeHistory__c> propCdHistList  物件コード履歴
         */
        public ConvInfo(List<BuildingCodeHistory__c> buildCdHistList
                        , List<PropertyCodeHistory__c> propCdHistList) {

            // 初期化
            this.maintBuildCdToBuildIdMap = new Map<String, Id>();
            this.buildIdToMaintBuildCdMap = new Map<Id, String>();
            this.maintPropCdToPropIdMap   = new Map<String, Id>();
            this.propIdToMaintPropCdMap   = new Map<Id, String>();

            // 変換情報の設定
            this.setMaintBuildingCd(buildCdHistList); // メンテナンス建物コード情報
            this.setMaintPropertyCd(propCdHistList);  // メンテナンス物件コード情報
        }

        /**
         * 新規作成されたメンテナンス建物コード情報の設定
         * @param List<Building__c> buildingList 建物
         */
        public void setNewMaintBuildingCd(List<Building__c> buildingList) {

            // 変換情報の設定（履歴メンテナンス建物コード ⇔ 建物ID）
            for (Building__c building : buildingList) {

                // 建物更新時は未設定
                if (String.isBlank(building.MaintenanceBuildingCode__c)) {
                    continue;
                }

                // メンテナンス建物コード → 建物ID
                this.maintBuildCdToBuildIdMap.put(building.MaintenanceBuildingCode__c, building.Id);

                // 建物ID → メンテナンス建物コード
                this.buildIdToMaintBuildCdMap.put(building.Id, building.MaintenanceBuildingCode__c);
            }
        }

        /**
         * メンテナンス建物コード情報の設定
         * @param List<BuildingCodeHistory__c> buildCdHistList 建物コード履歴
         */
        public void setMaintBuildingCd(List<BuildingCodeHistory__c> buildCdHistList) {

            // 変換情報の設定（履歴メンテナンス建物コード ⇔ 建物ID）
            for (BuildingCodeHistory__c buildCdHist : buildCdHistList) {

                // メンテナンス建物コード → 建物ID
                this.maintBuildCdToBuildIdMap.put(buildCdHist.HistoryMaintenanceBuildingCode__c
                                                  , buildCdHist.Building__c);

                // 建物ID → メンテナンス建物コード
                this.buildIdToMaintBuildCdMap.put(buildCdHist.Building__c
                                                  , buildCdHist.HistoryMaintenanceBuildingCode__c);
            }
        }

        /**
         * 新規作成されたメンテナンス物件コード情報の設定
         * @param List<Property__c> propertyList 物件
         */
        public void setNewMaintPropertyCd(List<Property__c> propertyList) {

            // 変換情報の設定（履歴メンテナンス物件コード ⇔ 物件ID）
            for (Property__c property : propertyList) {

                // 物件更新時は未設定
                if (String.isBlank(property.MaintenancePropertyCode__c)) {
                    continue;
                }

                // メンテナンス物件コード → 物件ID
                this.maintPropCdToPropIdMap.put(property.MaintenancePropertyCode__c, property.Id);

                // 物件ID → メンテナンス物件コード
                this.propIdToMaintPropCdMap.put(property.Id, property.MaintenancePropertyCode__c);
            }
        }

        /**
         * メンテナンス物件コード情報の設定
         * @param List<PropertyCodeHistory__c> propCdHistList 物件コード履歴
         */
        public void setMaintPropertyCd(List<PropertyCodeHistory__c> propCdHistList) {
            
            // 変換情報の設定（履歴メンテナンス物件コード ⇔ 物件ID）
            for (PropertyCodeHistory__c propCdHist : propCdHistList) {

                // メンテナンス物件コード → 物件ID
                this.maintPropCdToPropIdMap.put(propCdHist.HistoryMaintenancePropertyCode__c
                                                , propCdHist.Property__c);

                // 物件ID → メンテナンス物件コード
                this.propIdToMaintPropCdMap.put(propCdHist.Property__c
                                                , propCdHist.HistoryMaintenancePropertyCode__c);
            }
        }

        /**
         * 建物IDの一括取得
         * @param Set<String> maintBuildCdSet メンテナンス建物コード
         * @return Set<Id> 建物ID
         */
        public Set<Id> getBuildingIds(Set<String> maintBuildCdSet) {

            Set<Id> buildIdSet = new Set<Id>();

            // メンテナンス建物コードに紐づく建物IDの取得
            for (String maintBuildCd : maintBuildCdSet) {
                if (this.maintBuildCdToBuildIdMap.containsKey(maintBuildCd)) {
                    buildIdSet.add(this.maintBuildCdToBuildIdMap.get(maintBuildCd));
                }
            }

            return buildIdSet;
        }

        /**
         * メンテナンス建物コードの取得
         * @param Id buildId 建物ID
         * @return String メンテナンス建物コード
         */
        public String getMaintBuildingCd(Id buildId) {

            String maintBuildCd = CommonConst.STRING_EMPTY;

            // 建物IDに紐づくメンテナンス建物コードの取得
            if (this.buildIdToMaintBuildCdMap.containsKey(buildId)) {
                maintBuildCd = this.buildIdToMaintBuildCdMap.get(buildId);
            }

            return maintBuildCd;
        }

        /**
         * 物件IDの一括取得
         * @param Set<String> maintPropCdSet メンテナンス物件コード
         * @return Set<Id> 物件ID
         */
        public Set<Id> getPropertyIds(Set<String> maintPropCdSet) {

            Set<Id> propIdSet = new Set<Id>();

            // メンテナンス物件コードに紐づく物件IDの取得
            for (String maintPropCd : maintPropCdSet) {
                if (this.maintPropCdToPropIdMap.containsKey(maintPropCd)) {
                    propIdSet.add(this.maintPropCdToPropIdMap.get(maintPropCd));
                }
            }

            return propIdSet;
        }

        /**
         * メンテナンス物件コードの取得
         * @param Id propId 物件ID
         * @return String メンテナンス物件コード
         */
        public String getMaintPropertyCd(Id propId) {
            
            String maintPropCd = CommonConst.STRING_EMPTY;

            // 物件IDに紐づくメンテナンス物件コードの取得
            if (this.propIdToMaintPropCdMap.containsKey(propId)) {
                maintPropCd = this.propIdToMaintPropCdMap.get(propId);
            }

            return maintPropCd;
        }
    }
}