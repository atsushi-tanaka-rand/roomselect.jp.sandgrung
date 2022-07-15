// 条件完全一致物件バッチ
global with sharing class BD301005Batch implements Database.Batchable<Correspond__c> , Database.Stateful {

    /** 条件完全一致処理用オブジェクト */
    private Map<Id, Property__c> propMatchItemMap;                          // 物件（key:物件．ID、value:物件）
    private Map<Id, PropertyConditions__c> propCondMatchItemMap;            // 物件条件（key:物件．ID、value:物件条件）
    private Map<Id, Building__c> buildingMatchItemMap;                      // 建物（key:建物．ID、value:建物）
    private Map<Id, List<DesiredStation__c>> desiredStationMatchItemMap;    // 駅（key:希望路線．ID、value:希望駅）
    private Map<Id, Set<Id>> desiredJuniorHighSchoolMatchItemMap;           // 中学校（key:希望学区（エリア）．ID、value:学校．ID）
    private Map<Id, Set<Id>> desiredSchoolElementaryMatchItemMap;           // 小学校（key:希望学区（エリア）．ID、value:学校．ID）

    /** 定数 */
    private final String ERR_MAIL_SUBJECT = CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_PROCESS, '条件完全一致処理'); // 件名
    private final String SEMIKORON = ';';

    /** 登録値 */
    private Datetime currentDate;   // システム日付

    /** エラー処理用変数 */
    private Map<String, Exception> exMap; // 例外内容(key:スタックトレース、value:例外クラス)

    /** テストクラス用変数 */
    @TestVisible static Boolean isExecuteMethodErr          = false; // executeメソッド用
    @TestVisible static Boolean isSystemVariablesErrTest    = false; // システム変数用
    @TestVisible static Boolean isExactCondMatchPropErrTest = false; // 条件完全一致バッチ実行処理用

    //コンストラクタ
    global BD301005Batch(Set<Id> propIds) {

        // 物件の処理件数
        Decimal limitPropertySize = SystemConfig__c.getInstance().ExactConditionMatchBatchPropertySize__c;
        if (limitPropertySize == null || limitPropertySize == 0) {
            limitPropertySize = 200;
        }

        // 条件完全一致処理用オブジェクト取得
        this.propMatchItemMap = selectMatchProp(propIds, limitPropertySize.intValue()); // 物件
        this.propCondMatchItemMap = selectMatchPropCond(propMatchItemMap.keySet());     // 物件条件

        // 建物
        Set<Id> buildingIds = new Set<Id>();
        for (Property__c propertysBuilding : this.propMatchItemMap.values()) {
            buildingIds.add(propertysBuilding.Building__c);
        }
        this.buildingMatchItemMap = selectMatchBuilding(buildingIds);

        // 共通システム日付を取得
        this.currentDate = CommonUtil.getNow();

        // 例外内容を初期化
        this.exMap = new Map<String, Exception>();
    }

    //データ取得
    global Iterable<Correspond__c> start(Database.BatchableContext BC){

        // 対応（条件完全一致対象）を取得
        return this.selectMatchCorrespond();    
    }
        
    //開始
    global void execute(Database.BatchableContext BC, List<Correspond__c> correspondMatchProps){

        Savepoint sp = Database.setSavepoint();
        try {
            // 取引先・対応マップ（key:取引先.ID、value:対応.ID）
            Map<Id, Id> correspondMap = new Map<Id, Id>();
            for (Correspond__c orrespondMatchProp : correspondMatchProps) {
                correspondMap.put(orrespondMatchProp.AccountId__r.Id, orrespondMatchProp.Id);
            }

            // 対応に紐づく取引先を取得
            Map<Id, Account> accountMatchPropMap = selectMatchAccount(correspondMap.keySet());

            // 取引先に紐づく条件完全一致項目を取得
            setAccountsMatchInfo(accountMatchPropMap.values());

            // 登録オブジェクト
            RegistObjectExactCondMatch registObject; 
            List<RegistObjectExactCondMatch> registObjects = new List<RegistObjectExactCondMatch>();

            // 完全一致処理
            Building__c buildingMatchItem = new Building__c();
            PropertyConditions__c propCondMatchItem = new PropertyConditions__c();
            String buildingName = CommonConst.STRING_EMPTY;
            for (Account accountMatchProp : accountMatchPropMap.values()) {
				// ▼2021.10.08 No.307 対応で追加
				//「取引先」「お客様物件条件」の物件条件をListで取得する。
                List<propCond> propCondList = new List<propCOnd>();
				propCondList = addAccountCond(accountMatchProp);
				// ▲2021.10.08 No.307 対応で追加

                for (Property__c propMatchItem : this.propMatchItemMap.values()) {
					// ▼2021.10.08 No.307 対応で追加
					String propCondName = '';
                    Boolean hitFlg = false;
					//「取引先」「お客様物件条件」の物件条件と物件を比較する。
					for(propCond procon : propCondList){

						// 予約物件条件チェックがTRUEの場合は条件完全一致処理を実施
						if(!procon.isReservePropertyCond){
							continue;
						}
					// ▲2021.10.08 No.307 対応で追加

						// 物件に紐づく建物
						buildingMatchItem = new Building__c();
						if (this.buildingMatchItemMap.containsKey(propMatchItem.Building__c)) {
							buildingMatchItem = this.buildingMatchItemMap.get(propMatchItem.Building__c);
						}
	
						// ▼2021.10.08 No.307 対応で変更
						// 建物チェック
						if (!isMatchBuilding(proCon, buildingMatchItem)) {
							continue;
						}
						// ▲2021.10.08 No.307 対応で変更
	
						// ▼2021.10.08 No.307 対応で変更
						// 物件チェック
						if (!isMatchProp(proCon, propMatchItem)) {
							continue;
						}
						// ▲2021.10.08 No.307 対応で変更
	
						// 物件に紐づく物件条件
						propCondMatchItem = new PropertyConditions__c();
						if (this.propCondMatchItemMap.containsKey(propMatchItem.Id)) {
							propCondMatchItem = this.propCondMatchItemMap.get(propMatchItem.Id);
						}
	
						// ▼2021.10.08 No.307 対応で変更
						// 物件条件チェック
						if (!isMatchPropCond(proCon, propCondMatchItem)) {
							continue;
						}
						// ▲2021.10.08 No.307 対応で変更
	
						// ▼2021.10.08 No.307 対応で変更
						// 一般物チェック
						if (proCon.isIppambutsu) {
							if (propMatchItem.FormerSupplier__r.IppamGyobutsu__c != CommonConst.ACCOUNT_IPPANGYOBUTSU_IPPAN) {
								continue;
							}
						}
						// ▲2021.10.08 No.307 対応で変更
	
                        hitFlg = true;
						// 「取引先」「お客様物件条件」の物件条件名を「;」区切りでセットする。
                        if(!String.isBlank(proCon.Name)){
                            propCondName += proCon.Name + SEMIKORON; 
                        }
						
					}

					// ▼2021.10.08 No.307 対応で追加
					// 物件条件名の最後の「;」を削除する
					if(!String.isBlank(propCondName)){
						propCondName = propCondName.removeEnd(SEMIKORON);
					}
                    if(!hitFlg){
                        continue;
                    }

					// ▼2021.10.08 No.307 対応で追加

                    // 条件完全一致登録オブジェクトを取得
                    registObject = new RegistObjectExactCondMatch();

                    // 対応登録値
                    registObject.correspond.Id                                  = correspondMap.get(accountMatchProp.Id);    // 更新ID
                    registObject.correspond.PropertyIntroductionPossibleTime__c = this.currentDate;                          // 物件紹介可能時刻
                    registObject.correspond.EventDateTime__c                    = this.currentDate;                          // イベント時刻
                    registObject.correspond.ListViewDate__c                     = this.currentDate;                          // 一覧表示日時
                    registObject.correspond.PursuitDissolveSettingDate__c       = null;                                      // 追客解除設定日時
                    registObject.correspond.IsSupportedListShow__c              = false;                                     // 対応確認

                    // 対応明細登録値
                    registObject.correspondDeitail.Corresponds__c       = registObject.correspond.Id;                          // 対応
                    registObject.correspondDeitail.CorrespondType__c    = CommonConst.TASK_CORRESPONDTYPE_PROP_CAN_INTRODUCE;  // 対応種別
                    registObject.correspondDeitail.SupportedTitle__c    = CommonConst.TASK_CORRESPONDTYPE_PROP_CAN_INTRODUCE;  // 対応表題
                    registObject.correspondDeitail.SupportedDateTime__c = this.currentDate;                                    // 対応日時
                    // 対応内容
                    buildingName = (buildingMatchItem.Name == null) ? CommonConst.NOT_EXIST_BUILDING_NAME : buildingMatchItem.Name;
                    registObject.correspondDeitail.SupportedContent__c  = CommonUtil.callMessageCreate(CommonConst.MSG_PROP_I_PROP_CAN_INTRODUCE
                                                                                                       , buildingName
                                                                                                       , propMatchItem.Name);
					// ▼ 2022.01.27 No.307対応で追加　対応内容に物件条件名行を追加
					registObject.correspondDeitail.SupportedContent__c += CommonConst.LINE_FEED + '物件条件名：' + propCondName.replace(SEMIKORON, '、');
					// ▲ 2022.01.27 No.307対応で追加　対応内容に物件条件名行を追加

                    // 条件完全一致物件登録値
                    registObject.exactCondMatchProp.Property__c = propMatchItem.Id;				// 物件
                    registObject.exactCondMatchProp.Account__c = accountMatchProp.Id;			// 取引先
                    registObject.exactCondMatchProp.Status__c = null;							// ステータス
                    registObject.exactCondMatchProp.IntroductionImpression__c = null;			// 紹介感想
					// ▼2021.10.08 No.307 対応で追加
					registObject.exactCondMatchProp.PropertyConditionsName__c = propCondName;	// 物件条件名（「;」区切りで複数の物件条件名を羅列したもの）
					// ▲2021.10.08 No.307 対応で追加

                    registObjects.add(registObject);
                }
            }

            // 条件完全一致オブジェクトを登録
            upsertObjectExactCondMatch(registObjects);

            // テストクラスの例外処理
            // ※異なる例外を発生させる為、例外をスロー
            if (isExecuteMethodErr && Test.isRunningTest()) {
                throw new BusinessLogicException();
            }

        } catch (Exception e) {
            this.outDebugException(e);
            Database.rollback(sp);

            this.exMap.put(e.getStackTraceString(), e);
        }
    }
        
    //終了
    global void finish(Database.BatchableContext BC) {

        // 例外内容(key:スタックトレース、value:例外クラス)
        Map<String, Exception> tmpExMap;

        // 条件完全一致バッチ実行の削除(正常終了時のみ)
        if (this.exMap.size() == 0) {
            tmpExMap = this.delExactCondMatchBatExe(this.propMatchItemMap.keySet());
            if (tmpExMap.size() > 0) {
                this.exMap.putAll(tmpExMap);
            }
        }

        // バッチ起動フラグの停止
        tmpExMap = this.chgStopBd301005BatchFlg();
        if (tmpExMap.size() > 0) {
            this.exMap.putAll(tmpExMap);
        }

        // エラーメールの送信
        if (String.isNotBlank(SystemConfig__c.getInstance().ErrorEmailDestination__c)
            && this.exMap.size() > 0) {

            // body句の取得(表題 + 全エラーメッセージ)
            String textBody = 'エラー内容を確認して下さい。' + CommonConst.BREAK_CODE
                            + CommonConst.BREAK_CODE;

            for (Exception e : this.exMap.values()) {
                textBody += '【エラー内容】' + e.getMessage() + CommonConst.BREAK_CODE
                          + '【エラー箇所】' + e.getStackTraceString() + CommonConst.BREAK_CODE
                          + CommonConst.BREAK_CODE;
            }

            // エラーメールの送信
            MailUtil.MailData errMailData = new MailUtil.MailData();
            errMailData.toAddress   = new List<String>{SystemConfig__c.getInstance().ErrorEmailDestination__c};
            errMailData.ccAddress   = null;
            errMailData.fromAddress = null;
            errMailData.subject     = this.ERR_MAIL_SUBJECT;
            errMailData.textBody    = textBody;

            MailUtil.sendMail(new List<MailUtil.MailData>{errMailData});
        }
    }

    /**
    * 対応（条件完全一致対象）を取得
    * @return List<Correspond__c> 対応（条件完全一致対象）
    */
    private List<Correspond__c> selectMatchCorrespond() {

        // 条件完全一致対象の対応を取得
        List<Correspond__c> correspondMatchs = [SELECT Id 
                                                       , AccountId__r.Id
                                                FROM Correspond__c
                                                WHERE Status__c = :CommonConst.CORRESPOND_STATUS_PURSUITHOLD
                                                      AND ExactConditionMatch__c = :CommonConst.CORRESPOND_EXACT_CONDITION_MATCH_EXISTS];

        return correspondMatchs;
    }

    /**
    * 取引先（条件完全一致対象）を取得
    * @param  Set<Id> accountIds 取引先．ID
    * @return Map<Id, Account> key:取引先．ID、value:取引先
    */
    private Map<Id, Account> selectMatchAccount(Set<Id> accountIds) {

		// ▼2021.10.08 No.307 対応で変更
        // 対応に紐づく取引先を取得
        List<Account> accountMatchProp =
                [SELECT Id									// ID
						, IsReservePropertyConditions__c	// 予約物件条件
                        , PropertyConditionsName__c         // 物件条件名
                        , DesiredArea__c					// 希望地域
                        , DesiredTrainRoute1__c				// 希望路線１
                        , DesiredTrainRoute2__c				// 希望路線２
                        , DesiredTrainRoute3__c				// 希望路線３
                        , WalkingTime__c					// 徒歩
                        , RentFeeFrom__c					// 希望賃料（下限）
                        , RentFeeTo__c						// 希望賃料（上限）
                        , IsIncludeManagementFee__c			// 管理費込み
                        , IsIncludeParkingFee__c			// 駐車場代込み
                        , OccupancyAreaLowerLimit__c		// 占有面積（下限）
                        , OccupancyAreaUpperLimit__c		// 占有面積（上限）
                        , BuildingAge__c					// 築年数
                        , IsOneRoom__c						// ワンルーム
                        , Is1K__c							// 1K
                        , Is1DK__c							// 1DK
                        , Is1LDK1SLDK__c					// 1LDK/SLDK
                        , Is2K2DK__c						// 2K/DK
                        , Is2LDK2SLDK__c					// 2LDK/SLDK
                        , Is3K3DK__c						// 3K/DK
                        , Is3LDK3SLDK__c					// 3LDK/SLDK
                        , Is4K4DK4LDKFrom__c				// 4K/DK/LDK~
                        , IsWooden__c						// 木造
                        , IsLightweightSteel__c				// 軽量鉄骨
                        , IsSteel__c						// 鉄骨造
                        , IsRC__c							// RC
                        , IsSRC__c							// SRC
                        , IsNorth__c						// 北
                        , IsNorthEast__c					// 北東
                        , IsEast__c							// 東
                        , IsSouthEast__c					// 南東
                        , IsSouth__c						// 南
                        , IsSouthWest__c					// 南西
                        , IsWest__c							// 西
                        , IsNorthWest__c					// 北西
                        , IsNonDeposit__c					// 敷金/保証金なし
                        , IsNonKeyMoney__c					// 礼金なし
                        , IsNonCleaningFee__c				// 定額修繕費なし
                        , IsNonRenewalFee__c				// 更新料なし
                        , IsDetachedHouse__c				// 戸建て
                        , IsMaisonette__c					// メゾネット
                        , IsLoft__c							// ロフト
                        , IsDesigners__c					// デザイナーズ
                        , IsRenovation__c					// リノベーション
                        , IsCondominiumRental__c			// 分譲賃貸
                        , IsAllWestern__c					// オール洋間
                        , IsFirstFloor__c					// 1階
                        , IsSecondFloorOver__c				// 2階以上
                        , IsTopFloor__c						// 最上階
                        , IsCornerRoom__c					// 角部屋
                        , IsBalcony__c						// バルコニー
                        , IsRoofBalcony__c					// ルーフバルコニー
                        , IsPrivateGarden__c				// 専用庭
                        , IsParking__c						// 駐車場空きあり
                        , IsInSiteParking__c				// 敷地内駐車場
                        , IsPluralCarParking__c				// 駐車場2台可
                        , IsBuiltInGarage__c				// ビルトインガレージ
                        , IsCarport__c						// カーポート
                        , IsBicycleParking__c				// 駐輪場
                        , IsBikeStorage__c					// バイク可
                        , IsSmallBike__c					// 小型バイク
                        , IsMediumBike__c					// 中型バイク
                        , IsLargeBike__c					// 大型バイク
                        , IsElevator__c						// エレベーター
                        , IsDeliveryBox__c					// 宅配ボックス
                        , IsCounterKitchen__c				// カウンターキッチン
                        , IsSystemKitchen__c				// システムキッチン
                        , IsGasStove__c						// ガスコンロ
                        , IsElectricStove__c				// 電気コンロ
                        , IsInductionHeating__c				// IHコンロ
                        , IsTwoGasStove__c					// コンロ2口
                        , IsMoreGasStove__c					// コンロ3口以上
                        , IsSepalateBathAndRestroom__c		// バス・トイレ別
                        , IsAditionalBoiling__c				// 追焚機能
                        , IsDehumidifierForBathroom__c		// 浴室乾燥機
                        , IsWashlet__c						// 温水洗浄便座
                        , IsShowerWashBasin__c				// シャワー付き洗面台
                        , IsRegalLavatory__c				// 洗面所独立
                        , IsInnerLandry__c					// 室内洗濯機置場
                        , IsTownGas__c						// 都市ガス
                        , IsPropaneGas__c					// プロパンガス
                        , IsAllElectric__c					// オール電化
                        , IsAirConditioner__c				// エアコン
                        , IsFloorHeating__c					// 床暖房
                        , IsShoesBox__c						// シューズボックス
                        , IsShoeCloak__c					// シューズクローク
                        , IsWalkInCloset__c					// ウォークインクローゼット
                        , IsTrunkRoom__c					// トランクルーム
                        , IsBSAntenna__c					// BSアンテナ
                        , IsCSAntenna__c					// CSアンテナ
                        , IsCATV__c							// CATV
                        , IsInternetFree__c					// ネット使用料無料
                        , IsMonitorIntercom__c				// モニター付きインターホン
                        , IsAutoLock__c						// オートロック
                        , IsFurniture__c					// 家具付き
                        , IsHomeAppliance__c				// 家電付き
                        , IsNoGuarantor__c					// 保証人不要
                        , IsNonGuaranteeidCompany__c		// 保証会社不要
                        , IsMusicalInstruments__c			// 楽器相談可
                        , IsForeigner__c					// 外国人契約可
                        , IsWelfareAvailable__c				// 生活保護契約可
                        , IsOfficeAvailable__c				// 事務所利用可
                        , IsPet__c							// ペット可
                        , IsSmallPet__c						// ペット(小型犬)
                        , IsMiddlePet__c					// ペット(中型犬)
                        , IsLargePet__c						// ペット(大型犬)
                        , IsCat__c							// ペット(猫)
                        , IsOtherPet__c						// ペット(その他)
                        , IsTwoTenant__c					// 2人入居可
                        , IsRoomShare__c					// ルームシェア可
                        , IsIppambutsu__c					// 一般物
                        , IsElderly__c 						// 高齢者歓迎
                        , IsWoman__c						// 女性限定
                        , IsStudent__c						// 学生限定マンション
                        , DesiredJuniorHighSchoolArea__c	// 中学校希望学区（エリア）
                        , DesiredElementarySchoolArea__c	// 小学校希望学区（エリア）
						, (SELECT ap.Id									// ID
									, ap.IsReservePropertyConditions__c	// 予約物件条件
									, ap.Name							// お客様物件条件名
									, ap.DesiredArea__c					// 希望地域
									, ap.DesiredTrainRoute1__c			// 希望路線１
									, ap.DesiredTrainRoute2__c			// 希望路線２
									, ap.DesiredTrainRoute3__c			// 希望路線３
									, ap.WalkingTime__c					// 徒歩
									, ap.RentFeeFrom__c					// 希望賃料（下限）
									, ap.RentFeeTo__c					// 希望賃料（上限）
									, ap.IsIncludeManagementFee__c		// 管理費込み
									, ap.IsIncludeParkingFee__c			// 駐車場代込み
									, ap.OccupancyAreaLowerLimit__c		// 占有面積（下限）
									, ap.OccupancyAreaUpperLimit__c		// 占有面積（上限）
									, ap.BuildingAge__c					// 築年数
									, ap.IsOneRoom__c					// ワンルーム
									, ap.Is1K__c						// 1K
									, ap.Is1DK__c						// 1DK
									, ap.Is1LDK1SLDK__c					// 1LDK/SLDK
									, ap.Is2K2DK__c						// 2K/DK
									, ap.Is2LDK2SLDK__c					// 2LDK/SLDK
									, ap.Is3K3DK__c						// 3K/DK
									, ap.Is3LDK3SLDK__c					// 3LDK/SLDK
									, ap.Is4K4DK4LDKFrom__c				// 4K/DK/LDK~
									, ap.IsWooden__c					// 木造
									, ap.IsLightweightSteel__c			// 軽量鉄骨
									, ap.IsSteel__c						// 鉄骨造
									, ap.IsRC__c						// RC
									, ap.IsSRC__c						// SRC
									, ap.IsNorth__c						// 北
									, ap.IsNorthEast__c					// 北東
									, ap.IsEast__c						// 東
									, ap.IsSouthEast__c					// 南東
									, ap.IsSouth__c						// 南
									, ap.IsSouthWest__c					// 南西
									, ap.IsWest__c						// 西
									, ap.IsNorthWest__c					// 北西
									, ap.IsNonDeposit__c				// 敷金/保証金なし
									, ap.IsNonKeyMoney__c				// 礼金なし
									, ap.IsNonCleaningFee__c			// 定額修繕費なし
									, ap.IsNonRenewalFee__c				// 更新料なし
									, ap.IsDetachedHouse__c				// 戸建て
									, ap.IsMaisonette__c				// メゾネット
									, ap.IsLoft__c						// ロフト
									, ap.IsDesigners__c					// デザイナーズ
									, ap.IsRenovation__c				// リノベーション
									, ap.IsCondominiumRental__c			// 分譲賃貸
									, ap.IsAllWestern__c				// オール洋間
									, ap.IsFirstFloor__c				// 1階
									, ap.IsSecondFloorOver__c			// 2階以上
									, ap.IsTopFloor__c					// 最上階
									, ap.IsCornerRoom__c				// 角部屋
									, ap.IsBalcony__c 					// バルコニー
									, ap.IsRoofBalcony__c				// ルーフバルコニー
									, ap.IsPrivateGarden__c				// 専用庭
									, ap.IsParking__c					// 駐車場空きあり
									, ap.IsInSiteParking__c				// 敷地内駐車場
									, ap.IsPluralCarParking__c			// 駐車場2台可
									, ap.IsBuiltInGarage__c				// ビルトインガレージ
									, ap.IsCarport__c					// カーポート
									, ap.IsBicycleParking__c			// 駐輪場
									, ap.IsBikeStorage__c				// バイク可
									, ap.IsSmallBike__c					// 小型バイク
									, ap.IsMediumBike__c				// 中型バイク
									, ap.IsLargeBike__c					// 大型バイク
									, ap.IsElevator__c					// エレベーター
									, ap.IsDeliveryBox__c				// 宅配ボックス
									, ap.IsCounterKitchen__c			// カウンターキッチン
									, ap.IsSystemKitchen__c				// システムキッチン
									, ap.IsGasStove__c					// ガスコンロ
									, ap.IsElectricStove__c				// 電気コンロ
									, ap.IsInductionHeating__c			// IHコンロ
									, ap.IsTwoGasStove__c				// コンロ2口
									, ap.IsMoreGasStove__c				// コンロ3口以上
									, ap.IsSepalateBathAndRestroom__c	// バス・トイレ別
									, ap.IsAditionalBoiling__c			// 追焚機能
									, ap.IsDehumidifierForBathroom__c	// 浴室乾燥機
									, ap.IsWashlet__c					// 温水洗浄便座
									, ap.IsShowerWashBasin__c			// シャワー付き洗面台
									, ap.IsRegalLavatory__c				// 洗面所独立
									, ap.IsInnerLandry__c				// 室内洗濯機置場
									, ap.IsTownGas__c					// 都市ガス
									, ap.IsPropaneGas__c				// プロパンガス
									, ap.IsAllElectric__c				// オール電化
									, ap.IsAirConditioner__c			// エアコン
									, ap.IsFloorHeating__c				// 床暖房
									, ap.IsShoesBox__c					// シューズボックス
									, ap.IsShoeCloak__c					// シューズクローク
									, ap.IsWalkInCloset__c				// ウォークインクローゼット
									, ap.IsTrunkRoom__c					// トランクルーム
									, ap.IsBSAntenna__c					// BSアンテナ
									, ap.IsCSAntenna__c					// CSアンテナ
									, ap.IsCATV__c						// CATV
									, ap.IsInternetFree__c				// ネット使用料無料
									, ap.IsMonitorIntercom__c			// モニター付きインターホン
									, ap.IsAutoLock__c					// オートロック
									, ap.IsFurniture__c					// 家具付き
									, ap.IsHomeAppliance__c				// 家電付き
									, ap.IsNoGuarantor__c				// 保証人不要
									, ap.IsNonGuaranteeidCompany__c		// 保証会社不要
									, ap.IsMusicalInstruments__c		// 楽器相談可
									, ap.IsForeigner__c					// 外国人契約可
									, ap.IsWelfareAvailable__c			// 生活保護契約可
									, ap.IsOfficeAvailable__c			// 事務所利用可
									, ap.IsPet__c						// ペット可
									, ap.IsSmallPet__c					// ペット(小型犬)
									, ap.IsMiddlePet__c					// ペット(中型犬)
									, ap.IsLargePet__c					// ペット(大型犬)
									, ap.IsCat__c						// ペット(猫)
									, ap.IsOtherPet__c					// ペット(その他)
									, ap.IsTwoTenant__c					// 2人入居可
									, ap.IsRoomShare__c					// ルームシェア可
									, ap.IsIppambutsu__c				// 一般物
									, ap.IsElderly__c					// 高齢者歓迎
									, ap.IsWoman__c						// 女性限定
									, ap.IsStudent__c					// 学生限定マンション
									, ap.DesiredJuniorHighSchoolArea__c	// 中学校希望学区（エリア）
									, ap.DesiredElementarySchoolArea__c	// 小学校希望学区（エリア）
							FROM AccountPropertyConditionss__r ap
							WHERE ap.IsReservePropertyConditions__c = TRUE)
					FROM Account
					WHERE Id IN :accountIds
					];
		// ▲2021.10.08 No.307 対応で変更

        Map<Id, Account> correspondsAccountMap = new Map<Id, Account>();
        if (!accountMatchProp.isEmpty()) {
            correspondsAccountMap = new Map<Id, Account>(accountMatchProp);
        }

        return correspondsAccountMap;
    }

    /**
     * 希望駅（条件完全一致項目）を取得
     * @param  Set<Id> condDesiredTrainRoutes 希望路線
     * @return Map<Id, List<DesiredStation__c>> key:希望路線．ID、value:希望駅
     */
    private static Map<Id, List<DesiredStation__c>> selectMatchDesiredStation(Set<Id> condDesiredTrainRoutes) {

        List<DesiredStation__c> desiredStationsMatch = [SELECT DesiredTrainRoute__c      // 希望路線
                                                               , Station__c              // 駅
                                                               , Station__r.Latitude__c  // 緯度
                                                               , Station__r.Longitude__c // 経度
                                                        FROM DesiredStation__c
                                                        WHERE DesiredTrainRoute__c IN :condDesiredTrainRoutes];

        Map<Id, List<DesiredStation__c>> desiredStationMap = new Map<Id, List<DesiredStation__c>>();
        List<DesiredStation__c> desiredStations = new List<DesiredStation__c>();
        for (DesiredStation__c desiredStation : desiredStationsMatch) {
            // キー設定
            if (!desiredStationMap.containsKey(desiredStation.DesiredTrainRoute__c)) {
                desiredStationMap.put(desiredStation.DesiredTrainRoute__c, new List<DesiredStation__c>());
            }
            // 値設定
            desiredStations = desiredStationMap.get(desiredStation.DesiredTrainRoute__c);
            desiredStations.add(desiredStation);
            desiredStationMap.put(desiredStation.DesiredTrainRoute__c, desiredStations);
        }

        return desiredStationMap;
    } 

    /**
     * 希望学校（条件完全一致項目）を取得
     * @param  Set<Id> condDesiredSchoolAreas 希望学区（エリア）
     * @return Map<Id, Set<Id>> key:希望学区（エリア）．ID、value:学校．ID
     */
    private static Map<Id, Set<Id>> selectMatchDesiredSchool(Set<Id> condDesiredSchoolAreas) {

        List<DesiredSchool__c> desiredSchoolMatchs = [SELECT DesiredSchoolArea__c // 希望学区（エリア）
                                                             , School__c          // 学校
                                                      FROM DesiredSchool__c
                                                      WHERE DesiredSchoolArea__c IN :condDesiredSchoolAreas];

        Map<Id, Set<Id>> desiredSchoolMatchItemMap = new Map<Id, Set<Id>>();
        Set<Id> desiredSchoolIds = new Set<Id>();
        for (DesiredSchool__c desiredSchool : desiredSchoolMatchs) {            
            // キー設定
            if (!desiredSchoolMatchItemMap.containsKey(desiredSchool.DesiredSchoolArea__c)) {
                desiredSchoolMatchItemMap.put(desiredSchool.DesiredSchoolArea__c, new Set<Id>());
            }
            // 値設定
            desiredSchoolIds = desiredSchoolMatchItemMap.get(desiredSchool.DesiredSchoolArea__c);
            desiredSchoolIds.add(desiredSchool.School__c);
            desiredSchoolMatchItemMap.put(desiredSchool.DesiredSchoolArea__c, desiredSchoolIds);
        }

        return desiredSchoolMatchItemMap;
    } 

    /**
    * 物件（条件完全一致項目）を取得
    * @param  Set<Id> propIds 物件．ID
    * @param  Integer limitVal レコード取得件数
    * @return Map<Id, Property__c> key:物件．ID、value:物件（条件完全一致項目）
    */
    private Map<Id, Property__c> selectMatchProp(Set<Id> propIds, Integer limitVal) {

        List<Property__c> propMatchItem = 
                [SELECT Building__c                           // 建物
                        , RentFeeSearch__c                    // (検索用)賃料
                        , RentFeeSearchManagement__c          // (検索用)賃料管理費込
                        , RentFeeSearchParking__c             // (検索用)賃料駐車場込
                        , RentFeeSearchManagementParking__c   // (検索用)賃料管理費駐車場込
                        , RoomArea__c                         // 専有面積（㎡）
                        , RoomCount__c                        // 部屋数
                        , RoomLayout__c                       // 間取り（レイアウト）
                        , BalconyDirection__c                 // バルコニー方向
                        , SecurityDepositYenSearch__c         // (検索用)敷金(円)
                        , SecurityDepositMonthSearch__c       // (検索用)敷金(ヵ月)
                        , DepositYenSearch__c                 // (検索用)保証料金(円)
                        , DepositMonthSearch__c               // (検索用)保証料金(ヵ月)
                        , KeyMoneyYenSearch__c                // (検索用)礼金(円)
                        , KeyMoneyMonthSearch__c              // (検索用)礼金(ヵ月)
                        , CleaningFeeYenSearch__c             // (検索用)定額修繕費(円)
                        , CleaningFeeMonthSearch__c           // (検索用)定額修繕費(ヵ月)
                        , RenewalFeeYenSearch__c              // (検索用)更新料(円)
                        , RenewalFeeMonthSearch__c            // (検索用)更新料(ヵ月)
                        , GuaranteeidCompanyType__c           // 保証会社（利用区分）
                        , Name                                // 物件名
                        , FormerSupplier__r.IppamGyobutsu__c  // 一般/業物
                 FROM Property__c
                 WHERE Id IN :propIds
                       AND LiveStatus__c IN (:CommonConst.PROPERTY_LIVESTATUS_VACANCY
                                             , :CommonConst.PROPERTY_LIVESTATUS_SCHEDULEDTOLEAVE)
                 ORDER BY SystemModstamp
                 LIMIT :limitVal
                ];
        
        Map<Id, Property__c> propMap = new Map<Id, Property__c>();
        for (Property__c prop : propMatchItem) {
            propMap.put(prop.Id, prop);
        }

        return propMap;
    }

    /**
    * 建物（条件完全一致項目）を取得
    * @param  Set<Id> buildingIds 建物．ID
    * @return Map<Id, Building__c> key:建物．ID、value:建物（条件完全一致項目）
    */
    private Map<Id, Building__c> selectMatchBuilding(Set<Id> buildingIds) {

        List<Building__c> buildingMatchItem = 
                [SELECT Id                            // 建物
                        , StationLatitude1__c         // 駅１緯度
                        , StationLongitude1__c        // 駅１経度
                        , StationLatitude2__c         // 駅２緯度
                        , StationLongitude2__c        // 駅２経度
                        , StationLatitude3__c         // 駅３緯度
                        , StationLongitude3__c        // 駅３経度
                        , StationWalkTime1__c         // 駅までの時間（分）１
                        , StationWalkTime2__c         // 駅までの時間（分）２
                        , StationWalkTime3__c         // 駅までの時間（分）３
                        , JuniorHighSchool1__c        // 中学校１
                        , JuniorHighSchool2__c        // 中学校２
                        , JuniorHighSchool3__c        // 中学校３
                        , PrimarySchool1__c           // 小学校１
                        , PrimarySchool2__c           // 小学校２
                        , PrimarySchool3__c           // 小学校３
                        , BuildingAge__c              // 築年数
                        , Structure__c                // 建物構造
                        , PropertyType__c             // 物件種別
                        , District__c                 // 地区
                        , Name                        // 建物名      
                 FROM Building__c
                 WHERE Id IN :buildingIds
                ];
        
        Map<Id, Building__c> buildingMap = new Map<Id, Building__c>();
        for (Building__c building : buildingMatchItem) {
            buildingMap.put(building.Id, building);
        }

        return buildingMap;
    }
        
    /**
    * 物件条件（条件完全一致項目）を取得
    * @param  Set<Id> propIds 物件．ID
    * @return Map<Id, PropertyConditions__c> key:物件．ID、value:物件条件（条件完全一致項目）
    */
    private Map<Id, PropertyConditions__c> selectMatchPropCond(Set<Id> propIds) {

        List<PropertyConditions__c> propCondMatchItem = 
                [SELECT IsMaisonette__c                       // メゾネット
                        , IsLoft__c                           // ロフト
                        , IsDesigners__c                      // デザイナーズ
                        , IsRenovation__c                     // リノベーション
                        , IsCondominiumRental__c              // 分譲賃貸
                        , IsAllWesternStyleRoom__c            // オール洋間
                        , IsFirstFloor__c                     // 1階
                        , IsSecondFloorOver__c                // 2階以上
                        , IsTopFloor__c                       // 最上階
                        , IsCornerRoom__c                     // 角部屋
                        , IsBalcony__c                        // バルコニー
                        , IsRoofBalcony__c                    // ルーフバルコニー
                        , IsPrivateGarden__c                  // 専用庭
                        , IsParking__c                        // 駐車場空きあり
                        , IsInSiteParking__c                  // 敷地内駐車場
                        , IsPluralCarParking__c               // 駐車場2台可
                        , IsBuiltInGarage__c                  // ビルトインガレージ
                        , IsCarport__c                        // カーポート
                        , IsBicycleParking__c                 // 駐輪場
                        , IsBikeStorage__c                    // バイク可
                        , IsSmallBike__c                      // 小型バイク
                        , IsMediumBike__c                     // 中型バイク
                        , IsLargeBike__c                      // 大型バイク
                        , IsElevator__c                       // エレベーター
                        , IsDeliveryBox__c                    // 宅配ボックス
                        , IsCounterKitchen__c                 // カウンターキッチン
                        , IsSystemKitchen__c                  // システムキッチン
                        , IsGasStove__c                       // ガスコンロ
                        , IsElectricStove__c                  // 電気コンロ
                        , IsIhStove__c                        // IHコンロ
                        , IsTwoGasStove__c                    // コンロ2口
                        , IsMoreGasStove__c                   // コンロ3口以上
                        , IsSeparate__c                       // バス・トイレ別
                        , IsReheating__c                      // 追焚機能
                        , IsBathroomDryer__c                  // 浴室乾燥機
                        , IsWashletToiletSeat__c              // 温水洗浄便座
                        , IsShowerWashBasin__c                // シャワー付き洗面台
                        , IsWashroomDscrete__c                // 洗面所独立
                        , IsIndoorWashingMachineStorage__c    // 室内洗濯機置場
                        , IsCityGas__c                        // 都市ガス
                        , IsPropaneGas__c                     // プロパンガス
                        , IsAllElectric__c                    // オール電化
                        , IsAirConditioner__c                 // エアコン
                        , IsFloorHeating__c                   // 床暖房
                        , IsShoesBox__c                       // シューズボックス
                        , IsShoeCloak__c                      // シューズクローク
                        , IsWalkInCloset__c                   // ウォークインクローゼット
                        , IsTrunkRoom__c                      // トランクルーム
                        , IsBSAntenna__c                      // BSアンテナ
                        , IsCSAntenna__c                      // CSアンテナ
                        , IsCATV__c                           // CATV
                        , IsInternetFree__c                   // ネット使用料無料
                        , IsMonitorIntercom__c                // モニター付きインターホン
                        , IsAutoLock__c                       // オートロック
                        , IsFurniture__c                      // 家具付き
                        , IsHomeAppliance__c                  // 家電付き
                        , IsNoGuarantor__c                    // 保証人不要
                        , IsMusicalInstruments__c             // 楽器相談可
                        , IsForeigner__c                      // 外国人契約可
                        , IsWelfareAvailable__c               // 生活保護契約可
                        , IsOfficeAvailable__c                // 事務所利用可
                        , IsPet__c                            // ペット可
                        , IsSmallPet__c                       // ペット(小型犬)
                        , IsMiddlePet__c                      // ペット(中型犬)
                        , IsLargePet__c                       // ペット(大型犬)
                        , IsCat__c                            // ペット(猫)
                        , IsOtherPet__c                       // ペット(その他)
                        , IsTwoTenant__c                      // 2人入居可
                        , IsRoomShare__c                      // ルームシェア可
                        , IsElderly__c                        // 高齢者歓迎
                        , IsWoman__c                          // 女性限定
                        , IsStudent__c                        // 学生限定
                        , Property__c                         // 物件
                FROM PropertyConditions__c
                WHERE Property__r.Id IN :propIds
                ];
        
        Map<Id, PropertyConditions__c> propCondMap = new Map<Id, PropertyConditions__c>();
        for (PropertyConditions__c propCond : propCondMatchItem) {
            propCondMap.put(propCond.Property__c, propCond);
        }

        return propCondMap;
    }

    /**
    * 取引先に紐づく条件完全一致項目を設定
    * @param  List<Account> accountMatchProps 取引先
    */
    private void setAccountsMatchInfo(List<Account> accountMatchProps) {

        // オブジェクトの条件値を取得
        Set<Id> trainRoutes = new Set<Id>();           // 希望路線
        Set<Id> juniorHighSchoolIds = new Set<Id>();   // 中学校（希望学区エリア）
        Set<Id> elementarySchoolIds = new Set<Id>();   // 小学校（希望学区エリア）

        for (Account account : accountMatchProps) {
            trainRoutes.add(account.DesiredTrainRoute1__c);
            trainRoutes.add(account.DesiredTrainRoute2__c);
            trainRoutes.add(account.DesiredTrainRoute3__c);

            juniorHighSchoolIds.add(account.DesiredJuniorHighSchoolArea__c);
            elementarySchoolIds.add(account.DesiredElementarySchoolArea__c);

			// ▼2021.10.08 No.307 対応で追加
			for(AccountPropertyConditions__c apc : account.AccountPropertyConditionss__r){
				trainRoutes.add(apc.DesiredTrainRoute1__c);
				trainRoutes.add(apc.DesiredTrainRoute2__c);
				trainRoutes.add(apc.DesiredTrainRoute3__c);
	
				juniorHighSchoolIds.add(apc.DesiredJuniorHighSchoolArea__c);
				elementarySchoolIds.add(apc.DesiredElementarySchoolArea__c);
			}
			// ▲2021.10.08 No.307 対応で追加
        }

        // 希望駅
        this.desiredStationMatchItemMap = selectMatchDesiredStation(trainRoutes);

        // 中学校
        this.desiredJuniorHighSchoolMatchItemMap = selectMatchDesiredSchool(juniorHighSchoolIds);

        // 小学校
        this.desiredSchoolElementaryMatchItemMap = selectMatchDesiredSchool(elementarySchoolIds);
    }

// ▼2021.10.08 No.307 対応で変更
    /**
    * 希望学校一致チェック
    * @param  Building__c	buildingMatchItem 建物（条件完全一致項目）
    * @param  propCond		proCon  「取引先」「お客様物件」の物件条件用のクラス
    * @return Boolean		true:一致、false:不一致
    */
    private Boolean isMatchDesiredSchool(Building__c buildingMatchItem, propCond proCon) {

        // 中学校希望学区（エリア）
        if (proCon.desiredJuniorHighSchoolArea != null) {

            // 中学校一覧を取得
            Set<Id> juniorhighScoolIds = new Set<Id>();
            if (this.desiredJuniorHighSchoolMatchItemMap.containsKey(proCon.desiredJuniorHighSchoolArea)) {
                juniorhighScoolIds = this.desiredJuniorHighSchoolMatchItemMap.get(proCon.desiredJuniorHighSchoolArea);
            }

            // 条件一致チェック
            if (!juniorhighScoolIds.contains(buildingMatchItem.JuniorHighSchool1__c)
                && !juniorhighScoolIds.contains(buildingMatchItem.JuniorHighSchool2__c)
                && !juniorhighScoolIds.contains(buildingMatchItem.JuniorHighSchool3__c)
               ) {
                return false;
            }
        }

        // 小学校希望学区（エリア）
        if (proCon.desiredElementarySchoolArea != null) {

            // 小学校一覧を取得
            Set<Id> primarySchoolId = new Set<Id>();
            if (desiredSchoolElementaryMatchItemMap.containsKey(proCon.desiredElementarySchoolArea)) {
                primarySchoolId = desiredSchoolElementaryMatchItemMap.get(proCon.desiredElementarySchoolArea);
            }

            // 条件一致チェック
            if (!primarySchoolId.contains(buildingMatchItem.PrimarySchool1__c)
                && !primarySchoolId.contains(buildingMatchItem.PrimarySchool2__c)
                && !primarySchoolId.contains(buildingMatchItem.PrimarySchool3__c)
               ) {
                return false;
            }
        }

        return true;
    }
// ▲2021.10.08 No.307 対応で変更	

// ▼2021.10.08 No.307 対応で変更
    /**
    * 希望駅一致チェック
    * @param  Building__c	buildingMatchItem 建物（条件完全一致項目）
    * @param  propCond		proCon  「取引先」「お客様物件」の物件条件用のクラス
    * @return Boolean		true:一致、false:不一致
    */
    private Boolean isMatchDesiredStation(Building__c buildingMatchItem, propCond proCon) {

        // 希望路線
        List<Id> desiredTrainRouteIds = new List<Id>{proCon.desiredTrainRoute1
                                                     , proCon.desiredTrainRoute2
                                                     , proCon.desiredTrainRoute3};

        Integer noneDesiredTrainRouteCnt = 0;
        List<DesiredStation__c> accountsStations = new List<DesiredStation__c>();
        for (Id desiredTrainRouteId : desiredTrainRouteIds) {

            // 未選択
            if (!this.desiredStationMatchItemMap.containsKey(desiredTrainRouteId)) {
                noneDesiredTrainRouteCnt++;
                continue;
            }
            accountsStations = this.desiredStationMatchItemMap.get(desiredTrainRouteId);

            // 希望駅単位でチェック
            for (DesiredStation__c accountsStation : accountsStations) {

                // 駅1
                if (accountsStation.Station__r.Latitude__c == buildingMatchItem.StationLatitude1__c
                    && accountsStation.Station__r.Longitude__c == buildingMatchItem.StationLongitude1__c
                   ) {
                    // 駅のみ
                    if (proCon.walkingTime == null) {
                        return true;
                    }

                    // 徒歩含む
                    if (buildingMatchItem.StationWalkTime1__c <= Integer.valueOf(proCon.walkingTime)) {
                        return true;
                    }
                }

                // 駅2
                if (accountsStation.Station__r.Latitude__c == buildingMatchItem.StationLatitude2__c
                    && accountsStation.Station__r.Longitude__c == buildingMatchItem.StationLongitude2__c
                   ) {
                    // 駅のみ
                    if (proCon.walkingTime == null) {
                        return true;
                    }
 
                    // 徒歩含む
                    if (buildingMatchItem.StationWalkTime2__c <= Integer.valueOf(proCon.walkingTime)) {
                        return true;
                    }
                }

                // 駅3
                if (accountsStation.Station__r.Latitude__c == buildingMatchItem.StationLatitude3__c
                    && accountsStation.Station__r.Longitude__c == buildingMatchItem.StationLongitude3__c
                   ) {
                    // 駅のみ
                    if (proCon.walkingTime == null) {
                        return true;
                    }
 
                    // 徒歩含む
                    if (buildingMatchItem.StationWalkTime3__c <= Integer.valueOf(proCon.walkingTime)) {
                        return true;
                    }
                }
            }
        }

        // 徒歩のみ
        if (noneDesiredTrainRouteCnt == desiredTrainRouteIds.size()
            && proCon.walkingTime != null
           ) {

            if (buildingMatchItem.StationWalkTime1__c <= Integer.valueOf(proCon.walkingTime)
                || buildingMatchItem.StationWalkTime2__c <= Integer.valueOf(proCon.walkingTime)
                || buildingMatchItem.StationWalkTime3__c <= Integer.valueOf(proCon.walkingTime)
               ) {
                return true;
            }
        }

        // 希望路線と徒歩が未選択
        if (noneDesiredTrainRouteCnt == desiredTrainRouteIds.size()
			// ▼2022.01.27 No.307 対応で変更 徒歩が未選択と判定されない不具合対応
            && (proCon.walkingTime == null || proCon.walkingTime == '999')
			// ▲2022.01.27 No.307 対応で変更
           ) {
            return true;
        }

        return false;
    }
// ▲2021.10.08 No.307 対応で変更	

// ▼2021.10.08 No.307 対応で変更
    /**
    * 建物一致チェック
    * @param  propCond		proCon「取引先」「お客様物件」の物件条件用のクラス
    * @param  Building__c	buildingMatchItem 建物（条件完全一致項目）
    * @return Boolean		true:一致、false:不一致
    */
    private Boolean isMatchBuilding(propCond proCon, Building__c buildingMatchItem) {

        // 希望学校チェック
        if (!isMatchDesiredSchool(buildingMatchItem, proCon)) {
            return false;
        }

        // 希望駅チェック
        if (!isMatchDesiredStation(buildingMatchItem, proCon)) {
            return false;
        }

        // 地区
        if (!String.isBlank(proCon.desiredArea)) {
            String[] desiredAreas = proCon.desiredArea.split('( |　)+');
            if (!desiredAreas.contains(buildingMatchItem.District__c)) {
                return false;
            }
        }

        // 築年数
        if (proCon.buildingAge != null) {
            if (buildingMatchItem.BuildingAge__c == null
                || buildingMatchItem.BuildingAge__c > Integer.valueOf(proCon.buildingAge)) {
                return false;
            }
        }
         
        // 構造
        if (!isMatchBuildingStructure(proCon, buildingMatchItem)) {
            return false;
        }
        
        // 戸建て
        if (proCon.isDetachedHouse) {
            if (buildingMatchItem.PropertyType__c != CommonConst.BUILDING_PROPERTYTYPE_DETACHEDHOUSE) {
                return false;
            }
        }

        return true;
    }
// ▲2021.10.08 No.307 対応で変更	

// ▼2021.10.08 No.307 対応で変更
    /**
    * 物件一致チェック
    * @param  propCond		proCon 「取引先」「お客様物件」の物件条件用のクラス
    * @param  Property__c	propMatchItem    物件（条件完全一致項目）
    * @return Boolean		true:一致、false:不一致
    */
    private Boolean isMatchProp(propCond proCon, Property__c propMatchItem) {

        // 占有面積（下限）
        if (proCon.occupancyAreaLowerLimit != null) {
            if (propMatchItem.RoomArea__c == null
                || propMatchItem.RoomArea__c < Integer.valueOf(proCon.occupancyAreaLowerLimit)) {
                return false;
            }
        }

        // 占有面積（上限）
        if (proCon.occupancyAreaUpperLimit != null) {
            if (propMatchItem.RoomArea__c == null
                || propMatchItem.RoomArea__c > Integer.valueOf(proCon.occupancyAreaUpperLimit)) {
                return false;
            }
        }
        
        // 間取り
        if (!isMatchRoomLayout(proCon, propMatchItem)) {
            return false;
        }

        // 方角
        if (!isMatchDirection(proCon, propMatchItem)) {
            return false;
        }

        // 希望賃料
        if (!isMatchDesiredRent(proCon, propMatchItem)) {
            return false;
        }

        // 敷金/保証金なし
        if (proCon.isNonDeposit) {
            if (propMatchItem.SecurityDepositYenSearch__c != 0
                || propMatchItem.SecurityDepositMonthSearch__c != 0
                || propMatchItem.DepositYenSearch__c != 0
                || propMatchItem.DepositMonthSearch__c != 0) {
                return false;
            }
        }

        // 礼金なし
        if (proCon.isNonKeyMoney) {
            if (propMatchItem.KeyMoneyYenSearch__c != 0 
                || propMatchItem.KeyMoneyMonthSearch__c != 0) {
                return false;
            }
        }

        // 定額修繕費なし
        if (proCon.isNonCleaningFee) {
            if (propMatchItem.CleaningFeeYenSearch__c != 0 
                || propMatchItem.CleaningFeeMonthSearch__c != 0) {
                return false;
            }
        }
        
        // 更新料なし
        if (proCon.isNonRenewalFee) {
            if (propMatchItem.RenewalFeeYenSearch__c != 0
                || propMatchItem.RenewalFeeMonthSearch__c != 0) {
                return false;
            }
        }

        // 保証会社不要
        if (proCon.isNonGuaranteeidCompany) {
            if (propMatchItem.GuaranteeidCompanyType__c != CommonConst.PROPERTY_GUARANTEEIDCOMPANYTYPE_POSSIBLE) {
                return false;
            }
        }

        return true;
    }
// ▲2021.10.08 No.307 対応で変更	

// ▼2021.10.08 No.307 対応で変更
    /**
    * 物件条件一致チェック
    * @param  propCond				proCon 「取引先」「お客様物件」の物件条件用のクラス
    * @param  PropertyConditions__c	propCondMatchItem 物件条件（条件完全一致項目）
    * @return Boolean				true:一致、false:不一致
    */
    private Boolean isMatchPropCond(propCond proCon, PropertyConditions__c propCondMatchItem) {

        // 構造
        if (!isMatchPropCondStructure(proCon, propCondMatchItem)) {
            return false;
        }

        // フロア
        if (!isMatchFloor(proCon, propCondMatchItem)) {
            return false;
        }

        // バルコニー
        if (!isMatchBalcony(proCon, propCondMatchItem)) {
            return false;
        }

        // 専用庭
        if (proCon.isPrivateGarden) {
            if (!propCondMatchItem.IsPrivateGarden__c) {
                return false;
            }
        }

        // 駐車
        if (!isMatchParking(proCon, propCondMatchItem)) {
            return false;
        }

        // 駐輪/バイク
        if (!isMatchBicycleParking(proCon, propCondMatchItem)) {
            return false;
        }

        // 共用
        if (!isMatchShared(proCon, propCondMatchItem)) {
            return false;
        }

        // キッチン
        if (!isMatchKitchen(proCon, propCondMatchItem)) {
            return false;
        }

        // バス・トイレ
        if (!isMatchBathToilet(proCon, propCondMatchItem)) {
            return false;
        }

        // 光熱設備
        if (!isMatchLightHeatFacility(proCon, propCondMatchItem)) {
            return false;
        }

        // 収納
        if (!isMatchStorage(proCon, propCondMatchItem)) {
            return false;
        }

        // 通信設備
        if (!isMatchCommunicationFacility(proCon, propCondMatchItem)) {
            return false;
        }

        // セキュリティ
        if (!isMatchSecurity(proCon, propCondMatchItem)) {
            return false;
        }

        // 家具
        if (!isMatchFurniture(proCon, propCondMatchItem)) {
            return false;
        }

        // 入居条件
        if (!isMatchCondMoveIn(proCon, propCondMatchItem)) {
            return false;
        }

        return true;
    }
// ▲2021.10.08 No.307 対応で変更	

// ▼2021.10.08 No.307 対応で変更
    /**
    * 間取り一致チェック
    * @param  propCond		proCon 「取引先」「お客様物件」の物件条件用のクラス
    * @param  Property__c	propMatchItem    物件（条件完全一致項目）
    * @return Boolean		true:一致、false:不一致
    */
    private Boolean isMatchRoomLayout(propCond proCon, Property__c propMatchItem) {

        // 未選択チェック
        if (!proCon.isOneRoom 
            && !proCon.is1K
            && !proCon.is1DK
            && !proCon.is1LDK1SLDK
            && !proCon.is2K2DK
            && !proCon.is2LDK2SLDK
            && !proCon.is3K3DK
            && !proCon.is3LDK3SLDK
            && !proCon.is4K4DK4LDKFrom) {
            return true;
        }
        
        // ワンルーム
        if (proCon.isOneRoom) {
            if (propMatchItem.RoomCount__c == 1
                && propMatchItem.RoomLayout__c == CommonConst.PROPERTY_ROOMLAYOUT_R) {
                return true;
            }
        }

        // 1K
        if (proCon.is1K) {
            if (propMatchItem.RoomCount__c == 1
                &&(propMatchItem.RoomLayout__c == CommonConst.PROPERTY_ROOMLAYOUT_K
                   || propMatchItem.RoomLayout__c == CommonConst.PROPERTY_ROOMLAYOUT_SK)
               ) {
                return true;
            }
        }
        
        // 1DK
        if (proCon.is1DK) {
            if (propMatchItem.RoomCount__c == 1
                && (propMatchItem.RoomLayout__c == CommonConst.PROPERTY_ROOMLAYOUT_DK
                    || propMatchItem.RoomLayout__c == CommonConst.PROPERTY_ROOMLAYOUT_LK
                    || propMatchItem.RoomLayout__c == CommonConst.PROPERTY_ROOMLAYOUT_SDK
                    || propMatchItem.RoomLayout__c == CommonConst.PROPERTY_ROOMLAYOUT_SLK)
               ) {
                return true;
            }
        }

        // 1LDK/SLDK
        if (proCon.is1LDK1SLDK) {
            if (propMatchItem.RoomCount__c == 1
                && (propMatchItem.RoomLayout__c == CommonConst.PROPERTY_ROOMLAYOUT_LDK
                    || propMatchItem.RoomLayout__c == CommonConst.PROPERTY_ROOMLAYOUT_SLDK)
               ) {
                return true;
            }
        }

        // 2K/DK
        if (proCon.is2K2DK) {
            if (propMatchItem.RoomCount__c == 2
                && (propMatchItem.RoomLayout__c == CommonConst.PROPERTY_ROOMLAYOUT_K
                    || propMatchItem.RoomLayout__c == CommonConst.PROPERTY_ROOMLAYOUT_DK
                    || propMatchItem.RoomLayout__c == CommonConst.PROPERTY_ROOMLAYOUT_LK
                    || propMatchItem.RoomLayout__c == CommonConst.PROPERTY_ROOMLAYOUT_SK
                    || propMatchItem.RoomLayout__c == CommonConst.PROPERTY_ROOMLAYOUT_SDK
                    || propMatchItem.RoomLayout__c == CommonConst.PROPERTY_ROOMLAYOUT_SLK)
               ) {
                return true;
            }
        }

        // 2LDK/SLDK
        if (proCon.is2LDK2SLDK) {
            if (propMatchItem.RoomCount__c == 2
                && (propMatchItem.RoomLayout__c == CommonConst.PROPERTY_ROOMLAYOUT_LDK
                    || propMatchItem.RoomLayout__c == CommonConst.PROPERTY_ROOMLAYOUT_SLDK)
               ) {
                return true;
            }
        }

        // 3K/DK
        if (proCon.is3K3DK) {
            if (propMatchItem.RoomCount__c == 3
                && (propMatchItem.RoomLayout__c == CommonConst.PROPERTY_ROOMLAYOUT_K
                    || propMatchItem.RoomLayout__c == CommonConst.PROPERTY_ROOMLAYOUT_DK
                    || propMatchItem.RoomLayout__c == CommonConst.PROPERTY_ROOMLAYOUT_LK
                    || propMatchItem.RoomLayout__c == CommonConst.PROPERTY_ROOMLAYOUT_SK
                    || propMatchItem.RoomLayout__c == CommonConst.PROPERTY_ROOMLAYOUT_SDK
                    || propMatchItem.RoomLayout__c == CommonConst.PROPERTY_ROOMLAYOUT_SLK)
               ) {
                return true;
            }
        }

        // 3LDK/SLDK
        if (proCon.is3LDK3SLDK) {
            if (propMatchItem.RoomCount__c == 3
                && (propMatchItem.RoomLayout__c == CommonConst.PROPERTY_ROOMLAYOUT_LDK
                    || propMatchItem.RoomLayout__c == CommonConst.PROPERTY_ROOMLAYOUT_SLDK)
               ) {
                return true;
            }
        }

        // 4K/DK/LDK~
        if (proCon.is4K4DK4LDKFrom) {
            if (propMatchItem.RoomCount__c >= 4
                && (propMatchItem.RoomLayout__c == CommonConst.PROPERTY_ROOMLAYOUT_K
                    || propMatchItem.RoomLayout__c == CommonConst.PROPERTY_ROOMLAYOUT_DK
                    || propMatchItem.RoomLayout__c == CommonConst.PROPERTY_ROOMLAYOUT_LK
                    || propMatchItem.RoomLayout__c == CommonConst.PROPERTY_ROOMLAYOUT_LDK
                    || propMatchItem.RoomLayout__c == CommonConst.PROPERTY_ROOMLAYOUT_SK
                    || propMatchItem.RoomLayout__c == CommonConst.PROPERTY_ROOMLAYOUT_SDK
                    || propMatchItem.RoomLayout__c == CommonConst.PROPERTY_ROOMLAYOUT_SLK
                    || propMatchItem.RoomLayout__c == CommonConst.PROPERTY_ROOMLAYOUT_SLDK)
               ) {
                return true;
            }
        }

        return false;
    }
// ▲2021.10.08 No.307 対応で変更	

// ▼2021.10.08 No.307 対応で変更
    /**
    * 構造（建物）一致チェック
    * @param  propCond		proCon  「取引先」「お客様物件」の物件条件用のクラス
    * @param  Building__c	buildingMatchItem 建物（条件完全一致項目）
    * @return Boolean		true:一致、false:不一致
    */
    private Boolean isMatchBuildingStructure(propCond proCon, Building__c buildingMatchItem) {

        // 未選択チェック
        if (!proCon.isWooden
            && !proCon.isLightweightSteel
            && !proCon.isSteel
            && !proCon.isRC
            && !proCon.isSRC) {
            return true;
        }

        // 木造
        if (proCon.isWooden) {
            if (buildingMatchItem.Structure__c == CommonConst.BUILDING_STRUCTURE_WOODEN) {
                return true;
            }
        }

        // 軽量鉄骨
        if (proCon.isLightweightSteel) {
            if (buildingMatchItem.Structure__c == CommonConst.BUILDING_STRUCTURE_LIGHTWEIGHTSTEEL) {
                return true;
            }
        }

        // 鉄骨造
        if (proCon.isSteel) {
            if (buildingMatchItem.Structure__c == CommonConst.BUILDING_STRUCTURE_STEEL) {
                return true;
            }
        }

        // RC
        if (proCon.isRC) {
            if (buildingMatchItem.Structure__c == CommonConst.BUILDING_STRUCTURE_RC) {
                return true;
            }
        }

        // SRC
        if (proCon.isSRC) {
            if (buildingMatchItem.Structure__c == CommonConst.BUILDING_STRUCTURE_SRC) {
                return true;
            }
        }

        return false;
    }
// ▲2021.10.08 No.307 対応で変更	

// ▼2021.10.08 No.307 対応で変更	
    /**
    * 方角一致チェック
    * @param  propCond		proCon 「取引先」「お客様物件」の物件条件用のクラス
    * @param  Property__c	propMatchItem    物件（条件完全一致項目）
    * @return Boolean		true:一致、false:不一致
    */
    private Boolean isMatchDirection(propCond proCon, Property__c propMatchItem) {

        // 未選択チェック
        if (!proCon.isNorth
            && !proCon.isNorthEast
            && !proCon.isEast
            && !proCon.isSouthEast
            && !proCon.isSouth
            && !proCon.isSouthWest
            && !proCon.isWest
            && !proCon.isNorthWest) {
            return true;
        }

        // 北
        if (proCon.isNorth) {
            if (propMatchItem.BalconyDirection__c == CommonConst.PROPERTY_BALCONYDIRECTION_NORTH) {
                return true;
            }
        }

        // 北東
        if (proCon.isNorthEast) {
            if (propMatchItem.BalconyDirection__c == CommonConst.PROPERTY_BALCONYDIRECTION_NORTHEAST) {
                return true;
            }
        }

        // 東
        if (proCon.isEast) {
            if (propMatchItem.BalconyDirection__c == CommonConst.PROPERTY_BALCONYDIRECTION_EAST) {
                return true;
            }
        }

        // 南東
        if (proCon.isSouthEast) {
            if (propMatchItem.BalconyDirection__c == CommonConst.PROPERTY_BALCONYDIRECTION_SOUTHEAST) {
                return true;
            }
        }

        // 南
        if (proCon.isSouth) {
            if (propMatchItem.BalconyDirection__c == CommonConst.PROPERTY_BALCONYDIRECTION_SOUTH) {
                return true;
            }
        }
        
        // 南西
        if (proCon.isSouthWest) {
            if (propMatchItem.BalconyDirection__c == CommonConst.PROPERTY_BALCONYDIRECTION_SOUTHWEST) {
                return true;
            }
        }
        
        // 西
        if (proCon.isWest) {
            if (propMatchItem.BalconyDirection__c == CommonConst.PROPERTY_BALCONYDIRECTION_WEST) {
                return true;
            }
        }

        // 北西
        if (proCon.isNorthWest) {
            if (propMatchItem.BalconyDirection__c == CommonConst.PROPERTY_BALCONYDIRECTION_NORTHWEST) {
                return true;
            }
        }

        return false;
    }
// ▲2021.10.08 No.307 対応で変更	

// ▼2021.10.08 No.307 対応で変更	
    /**
    * 希望賃料一致チェック
    * @param  propCond		proCon 「取引先」「お客様物件」の物件条件用のクラス
    * @param  Property__c	propMatchItem    物件（条件完全一致項目）
    * @return Boolean		true:一致、false:不一致
    */
    private Boolean isMatchDesiredRent(propCond proCon, Property__c propMatchItem) {

        Decimal chkRent = null;
        if (!proCon.isIncludeManagementFee && !proCon.isIncludeParkingFee) {
            // 賃料
            chkRent = propMatchItem.RentFeeSearch__c;
        } else if (proCon.isIncludeManagementFee && !proCon.isIncludeParkingFee) {
            // 賃料 + 管理費
            chkRent = propMatchItem.RentFeeSearchManagement__c;
        } else if (!proCon.isIncludeManagementFee && proCon.isIncludeParkingFee) {
            // 賃料 + 駐車場
            chkRent = propMatchItem.RentFeeSearchParking__c;
        } else if (proCon.isIncludeManagementFee && proCon.isIncludeParkingFee) {
            // 賃料 + 管理費 + 駐車場
            chkRent = propMatchItem.RentFeeSearchManagementParking__c;
        }

        // 希望賃料（下限）
        if (proCon.rentFeeFrom != null) {
            if (chkRent == null || chkRent < proCon.rentFeeFrom) {
                return false;
            }
        }

        // 希望賃料（上限）
        if (proCon.rentFeeTo != null) {
            if (chkRent == null || chkRent > proCon.rentFeeTo) {
                return false;
            }
        }

        return true;
    }
// ▲2021.10.08 No.307 対応で変更	

// ▼2021.10.08 No.307 対応で変更    
    /**
    * 構造（物件条件）一致チェック
	* @param  propCond    			proCon 「取引先」「お客様物件」の物件条件用のクラス
    * @param  PropertyConditions__c propCondMatchItem 物件条件（条件完全一致項目）
    * @return Boolean               true:一致、false:不一致
    */
    private Boolean isMatchPropCondStructure(propCond proCon, PropertyConditions__c propCondMatchItem) {

        // メゾネット
        if (proCon.isMaisonette) {
            if (!propCondMatchItem.IsMaisonette__c) {
                return false;
            }
        }
        
        // ロフト
        if (proCon.isLoft) {
            if (!propCondMatchItem.IsLoft__c) {
                return false;
            }
        }
            
        // デザイナーズ
        if (proCon.isDesigners) {
            if (!propCondMatchItem.IsDesigners__c) {
                return false;
            }
        }
            
        // リノベーション
        if (proCon.isRenovation) {
            if (!propCondMatchItem.IsRenovation__c) {
                return false;
            }
        }
            
        // 分譲賃貸
        if (proCon.isCondominiumRental) {
            if (!propCondMatchItem.IsCondominiumRental__c) {
                return false;
            }
        }
            
        // オール洋間
        if (proCon.isAllWestern) {
            if (!propCondMatchItem.IsAllWesternStyleRoom__c) {
                return false;
            }
        }

        return true;
    }
// ▲2021.10.08 No.307 対応で変更	

// ▼2021.10.08 No.307 対応で変更	
    /**
    * フロア一致チェック
    * @param  propCond     			proCon 「取引先」「お客様物件」の物件条件用のクラス
    * @param  PropertyConditions__c propCondMatchItem 物件条件（条件完全一致項目）
    * @return Boolean               true:一致、false:不一致
    */
    private Boolean isMatchFloor(propCond proCon, PropertyConditions__c propCondMatchItem) {

        // 1階
        if (proCon.isFirstFloor) {
            if (!propCondMatchItem.IsFirstFloor__c) {
                return false;
            }
        }

        // 2階以上
        if (proCon.isSecondFloorOver) {
            if (!propCondMatchItem.IsSecondFloorOver__c) {
                return false;
            }
        }

        // 最上階
        if (proCon.isTopFloor) {
            if (!propCondMatchItem.IsTopFloor__c) {
                return false;
            }
        }

        // 角部屋
        if (proCon.isCornerRoom) {
            if (!propCondMatchItem.IsCornerRoom__c) {
                return false;
            }
        }

        return true;
    }
// ▲2021.10.08 No.307 対応で変更	

// ▼2021.10.08 No.307 対応で変更	
    /**
    * バルコニー一致チェック
    * @param  propCond				proCon 「取引先」「お客様物件」の物件条件用のクラス
    * @param  PropertyConditions__c	propCondMatchItem 物件条件（条件完全一致項目）
    * @return Boolean				true:一致、false:不一致
    */
    private Boolean isMatchBalcony(propCond proCon, PropertyConditions__c propCondMatchItem) {

        // バルコニー
        if (proCon.isBalcony) {
            if (!propCondMatchItem.IsBalcony__c) {
                return false;
            }
        }

        // ルーフバルコニー
        if (proCon.isRoofBalcony) {
            if (!propCondMatchItem.IsRoofBalcony__c) {
                return false;
            }
        }

        return true;
    }
// ▲2021.10.08 No.307 対応で変更	

// ▼2021.10.08 No.307 対応で変更	
    /**
    * 駐車一致チェック
    * @param  propCond     			proCon 「取引先」「お客様物件」の物件条件用のクラス
    * @param  PropertyConditions__c	propCondMatchItem 物件条件（条件完全一致項目）
    * @return Boolean				true:一致、false:不一致
    */
    private Boolean isMatchParking(propCond proCon, PropertyConditions__c propCondMatchItem) {

        // 駐車場空きあり
        if (proCon.isParking) {
            if (!propCondMatchItem.IsParking__c) {
                return false;
            }
        }

        // 敷地内駐車場
        if (proCon.isInSiteParking) {
            if (!propCondMatchItem.IsInSiteParking__c) {
                return false;
            }
        }

        // 駐車場2台可
        if (proCon.isPluralCarParking) {
            if (!propCondMatchItem.IsPluralCarParking__c) {
                return false;
            }
        }

        // ビルトインガレージ
        if (proCon.isBuiltInGarage) {
            if (!propCondMatchItem.IsBuiltInGarage__c) {
                return false;
            }
        }

        // カーポート
        if (proCon.isCarport) {
            if (!propCondMatchItem.IsCarport__c) {
                return false;
            }
        }

        return true;
    }
// ▲2021.10.08 No.307 対応で変更	

// ▼2021.10.08 No.307 対応で変更	
    /**
    * 駐輪/バイク一致チェック
    * @param  propCond				proCon 「取引先」「お客様物件」の物件条件用のクラス
    * @param  PropertyConditions__c	propCondMatchItem 物件条件（条件完全一致項目）
    * @return Boolean				true:一致、false:不一致
    */
    private Boolean isMatchBicycleParking(propCond proCon, PropertyConditions__c propCondMatchItem) {

        // 駐輪場
        if (proCon.isBicycleParking) {
            if (!propCondMatchItem.IsBicycleParking__c) {
                return false;
            }
        }

        // バイク可
        if (proCon.isBikeStorage) {
            if (!propCondMatchItem.IsBikeStorage__c
                && !propCondMatchItem.IsSmallBike__c
                && !propCondMatchItem.IsMediumBike__c
                && !propCondMatchItem.IsLargeBike__c) {
                return false;
            }
        }

        // 小型バイク
        if (proCon.isSmallBike) {
            if (!propCondMatchItem.IsSmallBike__c
                && !propCondMatchItem.IsMediumBike__c
                && !propCondMatchItem.IsLargeBike__c) {
                return false;
            }
        }

        // 中型バイク
        if (proCon.isMediumBike) {
            if (!propCondMatchItem.IsMediumBike__c
                && !propCondMatchItem.IsLargeBike__c) {
                return false;
            }
        }

        // 大型バイク
        if (proCon.isLargeBike) {
            if (!propCondMatchItem.IsLargeBike__c) {
                return false;
            }
        }

        return true;
    }
// ▲2021.10.08 No.307 対応で変更	

// ▼2021.10.08 No.307 対応で変更	
    /**
    * 共用一致チェック
    * @param  propCond     proCon 「取引先」「お客様物件」の物件条件用のクラス
    * @param  PropertyConditions__c propCondMatchItem 物件条件（条件完全一致項目）
    * @return Boolean               true:一致、false:不一致
    */
    private Boolean isMatchShared(propCond proCon, PropertyConditions__c propCondMatchItem) {

        // エレベーター
        if (proCon.isElevator) {
            if (!propCondMatchItem.IsElevator__c) {
                return false;
            }
        }

        // 宅配ボックス
        if (proCon.isDeliveryBox) {
            if (!propCondMatchItem.IsDeliveryBox__c) {
                return false;
            }
        }

        return true;
    }
// ▲2021.10.08 No.307 対応で変更	

// ▼2021.10.08 No.307 対応で変更	
    /**
    * キッチン一致チェック
    * @param  propCond     proCon 「取引先」「お客様物件」の物件条件用のクラス
    * @param  PropertyConditions__c propCondMatchItem 物件条件（条件完全一致項目）
    * @return Boolean               true:一致、false:不一致
    */
    private Boolean isMatchKitchen(propCond proCon, PropertyConditions__c propCondMatchItem) {

        // カウンターキッチン
        if (proCon.isCounterKitchen) {
            if (!propCondMatchItem.IsCounterKitchen__c) {
                return false;
            }
        }

        // システムキッチン
        if (proCon.isSystemKitchen) {
            if (!propCondMatchItem.IsSystemKitchen__c) {
                return false;
            }
        }

        // ガスコンロ
        if (proCon.isGasStove) {
            if (!propCondMatchItem.IsGasStove__c) {
                return false;
            }
        }

        // 電気コンロ
        if (proCon.isElectricStove) {
            if (!propCondMatchItem.IsElectricStove__c) {
                return false;
            }
        }

        // IHコンロ
        if (proCon.isInductionHeating) {
            if (!propCondMatchItem.IsIhStove__c) {
                return false;
            }
        }

        // コンロ2口
        if (proCon.isTwoGasStove) {
            if (!propCondMatchItem.IsTwoGasStove__c
                && !propCondMatchItem.IsMoreGasStove__c) {
                return false;
            }
        }

        // コンロ3口以上
        if (proCon.isMoreGasStove) {
            if (!propCondMatchItem.IsMoreGasStove__c) {
                return false;
            }
        }

        return true;
    }
// ▲2021.10.08 No.307 対応で変更	

// ▼2021.10.08 No.307 対応で変更	
    /**
    * バス・トイレ一致チェック
    * @param  propCond     proCon 「取引先」「お客様物件」の物件条件用のクラス
    * @param  PropertyConditions__c propCondMatchItem 物件条件（条件完全一致項目）
    * @return Boolean               true:一致、false:不一致
    */
    private Boolean isMatchBathToilet(propCond proCon, PropertyConditions__c propCondMatchItem) {

        // バス・トイレ別
        if (proCon.isSepalateBathAndRestroom) {
            if (!propCondMatchItem.IsSeparate__c) {
                return false;
            }
        }

        // 追焚機能
        if (proCon.isAditionalBoiling) {
            if (!propCondMatchItem.IsReheating__c) {
                return false;
            }
        }

        // 浴室乾燥機
        if (proCon.isDehumidifierForBathroom) {
            if (!propCondMatchItem.IsBathroomDryer__c) {
                return false;
            }
        }

        // 温水洗浄便座
        if (proCon.isWashlet) {
            if (!propCondMatchItem.IsWashletToiletSeat__c) {
                return false;
            }
        }

        // シャワー付き洗面台
        if (proCon.isShowerWashBasin) {
            if (!propCondMatchItem.IsShowerWashBasin__c) {
                return false;
            }
        }

        // 洗面所独立
        if (proCon.isRegalLavatory) {
            if (!propCondMatchItem.IsWashroomDscrete__c) {
                return false;
            }
        }

        // 室内洗濯機置場
        if (proCon.isInnerLandry) {
            if (!propCondMatchItem.IsIndoorWashingMachineStorage__c) {
                return false;
            }
        }

        return true;
    }
// ▲2021.10.08 No.307 対応で変更	

// ▼2021.10.08 No.307 対応で変更	
    /**
    * 光熱設備一致チェック
    * @param  propCond     proCon 「取引先」「お客様物件」の物件条件用のクラス
    * @param  PropertyConditions__c propCondMatchItem 物件条件（条件完全一致項目）
    * @return Boolean               true:一致、false:不一致
    */
    private Boolean isMatchLightHeatFacility(propCond proCon, PropertyConditions__c propCondMatchItem) {

        // 都市ガス
        if (proCon.isTownGas) {
            if (!propCondMatchItem.IsCityGas__c) {
                return false;
            }
        }

        // プロパンガス
        if (proCon.isPropaneGas) {
            if (!propCondMatchItem.IsPropaneGas__c) {
                return false;
            }
        }

        // オール電化
        if (proCon.isAllElectric) {
            if (!propCondMatchItem.IsAllElectric__c) {
                return false;
            }
        }

        // エアコン
        if (proCon.isAirConditioner) {
            if (!propCondMatchItem.IsAirConditioner__c) {
                return false;
            }
        }

        // 床暖房
        if (proCon.isFloorHeating) {
            if (!propCondMatchItem.IsFloorHeating__c) {
                return false;
            }
        }

        return true;
    }
// ▲2021.10.08 No.307 対応で変更	

// ▼2021.10.08 No.307 対応で変更	
    /**
    * 収納一致チェック
    * @param  propCond     proCon 「取引先」「お客様物件」の物件条件用のクラス
    * @param  PropertyConditions__c propCondMatchItem 物件条件（条件完全一致項目）
    * @return Boolean               true:一致、false:不一致
    */
    private Boolean isMatchStorage(propCond proCon, PropertyConditions__c propCondMatchItem) {

        // シューズボックス
        if (proCon.isShoesBox) {
            if (!propCondMatchItem.IsShoesBox__c) {
                return false;
            }
        }

        // シューズクローク
        if (proCon.isShoeCloak) {
            if (!propCondMatchItem.IsShoeCloak__c) {
                return false;
            }
        }

        // ウォークインクローゼット
        if (proCon.isWalkInCloset) {
            if (!propCondMatchItem.IsWalkInCloset__c) {
                return false;
            }
        }

        // トランクルーム
        if (proCon.isTrunkRoom) {
            if (!propCondMatchItem.IsTrunkRoom__c) {
                return false;
            }
        }

        return true;
    }
// ▲2021.10.08 No.307 対応で変更	

// ▼2021.10.08 No.307 対応で変更	
    /**
    * 通信設備一致チェック
    * @param  propCond     proCon 「取引先」「お客様物件」の物件条件用のクラス
    * @param  PropertyConditions__c propCondMatchItem 物件条件（条件完全一致項目）
    * @return Boolean               true:一致、false:不一致
    */
    private Boolean isMatchCommunicationFacility(propCond proCon, PropertyConditions__c propCondMatchItem) {

        // BSアンテナ
        if (proCon.isBSAntenna) {
            if (!propCondMatchItem.IsBSAntenna__c) {
                return false;
            }
        }

        // CSアンテナ
        if (proCon.isCSAntenna) {
            if (!propCondMatchItem.IsCSAntenna__c) {
                return false;
            }
        }

        // CATV
        if (proCon.isCATV) {
            if (!propCondMatchItem.IsCATV__c) {
                return false;
            }
        }

        // ネット使用料無料
        if (proCon.isInternetFree) {
            if (!propCondMatchItem.IsInternetFree__c) {
                return false;
            }
        }

        return true;
    }
// ▲2021.10.08 No.307 対応で変更	

// ▼2021.10.08 No.307 対応で変更	
    /**
    * セキュリティ一致チェック
    * @param  propCond              proCon  「取引先」「お客様物件」の物件条件用のクラス
    * @param  PropertyConditions__c propCondMatchItem 物件条件（条件完全一致項目）
    * @return Boolean               true:一致、false:不一致
    */
    private Boolean isMatchSecurity(propCond proCon, PropertyConditions__c propCondMatchItem) {

        // モニター付きインターホン
        if (proCon.isMonitorIntercom) {
            if (!propCondMatchItem.IsMonitorIntercom__c) {
                return false;
            }
        }

        // オートロック
        if (proCon.isAutoLock) {
            if (!propCondMatchItem.IsAutoLock__c) {
                return false;
            }
        }

        return true;
    }
// ▲2021.10.08 No.307 対応で変更	

// ▼2021.10.08 No.307 対応で変更	
    /**
    * 家具一致チェック
    * @param  propCond              proCon  「取引先」「お客様物件」の物件条件用のクラス
    * @param  PropertyConditions__c propCondMatchItem 物件条件（条件完全一致項目）
    * @return Boolean               true:一致、false:不一致
    */
    private Boolean isMatchFurniture(propCond proCon, PropertyConditions__c propCondMatchItem) {

        // 家具付き
        if (proCon.isFurniture) {
            if (!propCondMatchItem.IsFurniture__c) {
                return false;
            }
        }

        // 家電付き
        if (proCon.isHomeAppliance) {
            if (!propCondMatchItem.IsHomeAppliance__c) {
                return false;
            }
        }

        return true;
    }
// ▲2021.10.08 No.307 対応で変更	

// ▼2021.10.08 No.307 対応で変更	
    /**
    * 入居条件一致チェック
    * @param  propCond              proCon  「取引先」「お客様物件」の物件条件用のクラス
    * @param  PropertyConditions__c propCondMatchItem 物件条件（条件完全一致項目）
    * @return Boolean               true:一致、false:不一致
    */
    private Boolean isMatchCondMoveIn(propCond proCon, PropertyConditions__c propCondMatchItem) {

        // 保証人不要
        if (proCon.isNoGuarantor) {
            if (!propCondMatchItem.IsNoGuarantor__c) {
                return false;
            }
        }

        // 楽器相談可
        if (proCon.isMusicalInstruments) {
            if (!propCondMatchItem.IsMusicalInstruments__c) {
                return false;
            }
        }

        // 外国人契約可
        if (proCon.isForeigner) {
            if (!propCondMatchItem.IsForeigner__c) {
                return false;
            }
        }

        // 生活保護契約可
        if (proCon.isWelfareAvailable) {
            if (!propCondMatchItem.IsWelfareAvailable__c) {
                return false;
            }
        }

        // 事務所利用可
        if (proCon.isOfficeAvailable) {
            if (!propCondMatchItem.IsOfficeAvailable__c) {
                return false;
            }
        }

        // ペット
        if (!isMatchPets(proCon, propCondMatchItem)) {
            return false;
        }

        // 2人入居可
        if (proCon.isTwoTenant) {
            if (!propCondMatchItem.IsTwoTenant__c) {
                return false;
            }
        }

        // ルームシェア可
        if (proCon.isRoomShare) {
            if (!propCondMatchItem.IsRoomShare__c) {
                return false;
            }
        }

        // 高齢者歓迎
        if (proCon.isElderly) {
            if (!propCondMatchItem.IsElderly__c) {
                return false;
            }
        }

        // 女性限定
        if (proCon.isWoman) {
            if (!propCondMatchItem.IsWoman__c) {
                return false;
            }
        }

        // 学生限定マンション
        if (proCon.isStudent) {
            if (!propCondMatchItem.IsStudent__c) {
                return false;
            }
        }

        return true;
    }
// ▲2021.10.08 No.307 対応で変更	

// ▼2021.10.08 No.307 対応で変更	
    /**
    * ペット一致チェック
    * @param  propCond              proCon  「取引先」「お客様物件」の物件条件用のクラス
    * @param  PropertyConditions__c propCondMatchItem 物件条件（条件完全一致項目）
    * @return Boolean               true:一致、false:不一致
    */
    private Boolean isMatchPets(propCond proCon, PropertyConditions__c propCondMatchItem) {

        // ペット可
        if (proCon.isPet) {
            if (!propCondMatchItem.IsPet__c
                && !propCondMatchItem.IsSmallPet__c
                && !propCondMatchItem.IsMiddlePet__c
                && !propCondMatchItem.IsLargePet__c
                && !propCondMatchItem.IsCat__c
                && !propCondMatchItem.IsOtherPet__c) {
                return false;
            }
        }

        // ペット(小型犬)
        if (proCon.isSmallPet) {
            if (!propCondMatchItem.IsSmallPet__c
                && !propCondMatchItem.IsMiddlePet__c
                && !propCondMatchItem.IsLargePet__c) {
                return false;
            }
        }

        // ペット(中型犬)
        if (proCon.isMiddlePet) {
            if (!propCondMatchItem.IsMiddlePet__c
                && !propCondMatchItem.IsLargePet__c) {
                return false;
            }
        }

        // ペット(大型犬)
        if (proCon.isLargePet) {
            if (!propCondMatchItem.IsLargePet__c) {
                return false;
            }
        }

        // ペット(猫)
        if (proCon.isCat) {
            if (!propCondMatchItem.IsCat__c) {
                return false;
            }
        }

        // ペット(その他)
        if (proCon.isOtherPet) {
            if (!propCondMatchItem.IsOtherPet__c) {
                return false;
            }
        }

        return true;
    }
// ▲2021.10.08 No.307 対応で変更

    /**
    * 条件完全一致オブジェクトを登録
    * @param  List<RegistObjectExactCondMatch> registObjects 条件完全一致登録オブジェクト
    */
    private void upsertObjectExactCondMatch(List<RegistObjectExactCondMatch> registObjects) {

        // 実施チェック
        if (registObjects.size() == 0) {
            return;
        }

        // 条件値（取引先ID、物件ID）を取得
        List<Id> condPropIds;
        Map<Id, List<Id>> condIdMap = new Map<Id, List<Id>>();
        for (RegistObjectExactCondMatch registObject : registObjects) {
            // キー設定
            if (!condIdMap.containsKey(registObject.exactCondMatchProp.Account__c)) {
                condIdMap.put(registObject.exactCondMatchProp.Account__c, new List<Id>());
            }
            // 値設定
            condPropIds = condIdMap.get(registObject.exactCondMatchProp.Account__c);
            condPropIds.add(registObject.exactCondMatchProp.Property__c);
            condIdMap.put(registObject.exactCondMatchProp.Account__c, condPropIds);
        }

        // 条件完全一致物件の重複レコードを取得
        String sql = CommonConst.STRING_EMPTY;
		// ▼2021.10.08 No.307 対応で変更
        sql += 'SELECT id, Property__c, Account__c, PropertyConditionsName__c ';
		// ▲2021.10.08 No.307 対応で変更
        sql += 'FROM ExactConditionMatchProperty__c ';
        sql += 'WHERE ';

        // 条件：取引先ID、且つ物件IDが一致
        String condDiv = CommonConst.STRING_EMPTY;
        String condPropDiv = CommonConst.STRING_EMPTY;
        for (Id accountId : condIdMap.keySet()) {

            condDiv += 'OR (Account__c = \'' + accountId + '\'';
            condDiv += '    AND ( ';

            for (Id propId : condIdMap.get(accountId)) {
                condPropDiv += 'OR Property__c = \'' + propId + '\'';
            }

            condPropDiv = condPropDiv.removeStart('OR');
            condDiv += condPropDiv + ')) ';
        }
        condDiv = condDiv.removeStart('OR');

        sql += condDiv;
        List<ExactConditionMatchProperty__c> existsExactCondMatchProps = Database.query(sql);

        // 重複レコードの取引先ID、物件IDのキーを取得
        Set<Id> tmpDuplicatePropIds;
        Map<Id, Set<Id>> duplicateKeyMap = new Map<Id, Set<Id>>();

        // ▼2021.10.08 No.307 対応で追加
        // 条件完全一致物件の物件条件名を保持するMap key:取引先ID + 物件ID、value:物件条件名
        Map<String, String> propCondNameMap = new Map<String, String>();
        // 条件完全一致物件の物件条件名を保持するMap key:取引先ID + 物件ID、value:条件完全一致物件のID
        Map<String, Id> existsMatchPropsIdMap = new Map<String, Id>();
        // ▲2021.10.08 No.307 対応で追加

        for (ExactConditionMatchProperty__c duplicateRecord : existsExactCondMatchProps) {
            // キー設定
            if (!duplicateKeyMap.containsKey(duplicateRecord.Account__c)) {
                duplicateKeyMap.put(duplicateRecord.Account__c, new Set<Id>());
            }
            // 値を設定
            tmpDuplicatePropIds = duplicateKeyMap.get(duplicateRecord.Account__c);
            tmpDuplicatePropIds.add(duplicateRecord.Property__c);
            duplicateKeyMap.put(duplicateRecord.Account__c, tmpDuplicatePropIds);

            // ▼2021.10.08 No.307 対応で追加
            // 条件完全一致物件の物件条件名をセットする。
            String propCondNameMapKeyName = String.valueOf(duplicateRecord.Account__c) + String.valueOf(duplicateRecord.Property__c);
            propCondNameMap.put(propCondNameMapKeyName, duplicateRecord.PropertyConditionsName__c);
            existsMatchPropsIdMap.put(propCondNameMapKeyName, duplicateRecord.id);
            // ▲2021.10.08 No.307 対応で追加
        }

        // 登録値リスト
        Map<Id, Correspond__c> updCorrespondMap = new Map<Id, Correspond__c>();                                         // 対応（key:対応ID、value:対応）
        List<ExactConditionMatchProperty__c> registObjectExactCondMatchs = new List<ExactConditionMatchProperty__c>();  // 条件完全一致物件
        List<CorrespondDetail__c> registCorrespondDeitails = new List<CorrespondDetail__c>();                           // 対応明細

        // ▼2021.10.08 No.307 対応で追加
        // 物件条件名更新用リスト　条件完全一致物件
        String propCondNameMapKeyName;
        List<ExactConditionMatchProperty__c> updatePropCondiNameList = new List<ExactConditionMatchProperty__c>();
        // ▲2021.10.08 No.307 対応で追加

        // 登録・更新対象チェック
        Set<Id> duplicatePropIds;
        for (RegistObjectExactCondMatch registObject : registObjects) {

            // 重複値チェック
            if (duplicateKeyMap.containsKey(registObject.exactCondMatchProp.Account__c)) {
                duplicatePropIds = duplicateKeyMap.get(registObject.exactCondMatchProp.Account__c);
                if (duplicatePropIds.contains(registObject.exactCondMatchProp.Property__c)) {
                    // ▼2021.10.08 No.307 対応で変更
                    // 物件条件名が一致するかチェック
                    propCondNameMapKeyName = String.valueOf(registObject.exactCondMatchProp.Account__c) + String.valueOf(registObject.exactCondMatchProp.Property__c);
                    // 既存の物件条件名
                    String existpropCondName = propCondNameMap.get(propCondNameMapKeyName);
                    // 物件条件が同じ場合は更新しない
                    if(existpropCondName == registObject.exactCondMatchProp.PropertyConditionsName__c){
                        continue;
                    } else { // 物件条件名が変更されている場合はUPSERT用のListに追加
                        ExactConditionMatchProperty__c ecmp = registObject.exactCondMatchProp;
                        ecmp.id = existsMatchPropsIdMap.get(propCondNameMapKeyName);
                        updatePropCondiNameList.add(ecmp);
                        continue;
                    }
                    // ▲2021.10.08 No.307 対応で変更
                }
            }

            // 登録値を取得
            // 対応は1度のみ更新
            if (!updCorrespondMap.containsKey(registObject.correspond.Id)) {
                updCorrespondMap.put(registObject.correspond.Id, registObject.correspond); 
            }

            registCorrespondDeitails.add(registObject.correspondDeitail);       // 対応明細
            registObjectExactCondMatchs.add(registObject.exactCondMatchProp);   // 条件完全一致物件
        }

        // 登録・更新
        SecureDML.secureUpdate(updCorrespondMap.values());
        SecureDML.secureInsert(registCorrespondDeitails);
        SecureDML.secureInsert(registObjectExactCondMatchs);

        // ▼2021.10.08 No.307 対応で追加
        // 物件条件名が変更されているレコードを更新
        if(updatePropCondiNameList.size() > 0){
            SecureDML.secureUpdate(updatePropCondiNameList);
        }
        // ▲2021.10.08 No.307 対応で追加
    }

    /**
    * 条件完全一致登録オブジェクト
    */
    private class RegistObjectExactCondMatch {
        /** オブジェクト一覧 */
        public Correspond__c correspond {get; set;}                           // 対応
        public CorrespondDetail__c correspondDeitail {get; set;}              // 対応明細
        public ExactConditionMatchProperty__c exactCondMatchProp {get; set;}  // 条件完全一致物件

        /**
        * コンストラクタ
        */
        public RegistObjectExactCondMatch() {
            correspond = new Correspond__c();
            correspondDeitail = new CorrespondDetail__c();
            exactCondMatchProp = new ExactConditionMatchProperty__c();
        }
    }

    /**
    * 条件完全一致バッチ実行の取得
    * @param Set<Id> propertyIdSet 物件ID
    * @return List<ExactConditionMatchBatchExecution__c> 条件完全一致バッチ実行
    */
    private List<ExactConditionMatchBatchExecution__c> selectExactCondMatchBatExe(Set<Id> propertyIdSet) {

        // 条件完全一致バッチ実行の取得
        List<ExactConditionMatchBatchExecution__c> ecmbeList =
            [SELECT Id
                    , Property__c
             FROM ExactConditionMatchBatchExecution__c
             WHERE PropertyId__c = :propertyIdSet];

        // 取得件数チェック
        if (ecmbeList.isEmpty()) {
            ecmbeList = new List<ExactConditionMatchBatchExecution__c>();
        }

        return ecmbeList;
    }

    /**
     * 条件完全一致物件バッチフラグの停止
     * @return Map<String, Exception> 例外内容(key:スタックトレース、value:例外クラス)
     */
    private Map<String, Exception> chgStopBd301005BatchFlg() {

        Map<String, Exception> exMap = new Map<String, Exception>();

        try {
            // システム変数を取得
            List<SystemVariables__c> systemVariablesList = [SELECT Id
                                                                   , BooleanValue__c
                                                            FROM SystemVariables__c
                                                            WHERE VariablesName__c = :CommonConst.IS_EXACT_COND_MATCH_PROP_BATCH_PROCESSING];

            // テストクラスの例外処理
            // ※異なる例外を発生させる為、空リストの削除を実施
            if (isSystemVariablesErrTest && Test.isRunningTest()) {
                systemVariablesList = null;
                SecureDML.secureUpdate(systemVariablesList);
            }

            // フラグを更新
            if (!systemVariablesList.isEmpty()) {
                systemVariablesList[0].BooleanValue__c  = false;
                SecureDML.secureUpdate(systemVariablesList);
            }

        } catch (Exception e) {
            // エラー情報の出力 + 取得
            this.outDebugException(e);
            exMap.put(e.getStackTraceString(), e);
        }

        return exMap;
    }

    /**
     * 条件完全一致バッチ実行の削除
     * @param Set<Id> propertyIdSet 物件Id
     * @return Map<String, Exception> 例外内容(key:スタックトレース、value:例外クラス)
     */
    private Map<String, Exception> delExactCondMatchBatExe(Set<Id> propertyIdSet) {

        Map<String, Exception> exMap = new Map<String, Exception>();

        try {

            // 削除対象の条件完全一致実行の取得
            List<ExactConditionMatchBatchExecution__c> delEcmbeList;
            delEcmbeList = this.selectExactCondMatchBatExe(propertyIdSet);

            // テストクラスの例外処理
            // ※異なる例外を発生させる為、多重削除を実施
            if (isExactCondMatchPropErrTest && Test.isRunningTest()) {
                SecureDML.secureDelete(delEcmbeList);
            }

            // 条件完全一致実行の削除
            if (delEcmbeList.size() > 0) {
                SecureDML.secureDelete(delEcmbeList);
            }

        } catch (Exception e) {
            // エラー情報の出力 + 取得
            this.outDebugException(e);
            exMap.put(e.getStackTraceString(), e);
        }

        return exMap;
    }

    /**
     * 例外の出力
     * @param Exception e 例外クラス
     */
    private void outDebugException(Exception e) {
        System.debug('例外メッセージ:' + e.getMessage());
        System.debug('例外スタックトレース:' + e.getStackTraceString());
    }

// ▼2021.10.08 No.307 対応で追加	
	/**
     * 取引先用物件条件を追加
     * @param Account  取引先
     * @return List<propCond>  取引先、お客様物件の物件条件用のクラスのList
     */
	private List<propCond> addAccountCond(Account account){
		List<propCond> pcList = new List<propCond>();

		propCond pc1 = new propCond();
		pc1.isReservePropertyCond = account.IsReservePropertyConditions__c;			//予約物件条件
		pc1.desiredTrainRoute1 = account.DesiredTrainRoute1__c;						//希望路線１
		pc1.desiredTrainRoute2 = account.DesiredTrainRoute2__c;						//希望路線2
		pc1.desiredTrainRoute3 = account.DesiredTrainRoute3__c;						//希望路線3
		pc1.desiredElementarySchoolArea = account.DesiredElementarySchoolArea__c;	//小学校希望学区
		pc1.desiredJuniorHighSchoolArea = account.DesiredJuniorHighSchoolArea__c;	//中学校希望学区
		pc1.Name = account.PropertyConditionsName__c;								//物件条件名
		pc1.is1DK = account.Is1DK__c;												//1DK
		pc1.is1K = account.Is1K__c;													//1K
		pc1.is1LDK1SLDK = account.Is1LDK1SLDK__c;									//1LDK/SLDK
		pc1.isFirstFloor = account.IsFirstFloor__c;									//1階
		pc1.is2K2DK = account.Is2K2DK__c;											//2K/DK
		pc1.is2LDK2SLDK = account.Is2LDK2SLDK__c;									//2LDK/SLDK
		pc1.isSecondFloorOver = account.IsSecondFloorOver__c;						//2階以上
		pc1.isTwoTenant = account.IsTwoTenant__c;									//2人入居可
		pc1.is3K3DK = account.Is3K3DK__c;											//3K/DK
		pc1.is3LDK3SLDK = account.Is3LDK3SLDK__c;									//3LDK/SLDK
		pc1.is4K4DK4LDKFrom = account.Is4K4DK4LDKFrom__c;							//4K/DK/LDK~
		pc1.isBSAntenna = account.IsBSAntenna__c;									//BSアンテナ
		pc1.isCATV = account.IsCATV__c;												//CATV
		pc1.isCSAntenna = account.IsCSAntenna__c;									//CSアンテナ
		pc1.isInductionHeating = account.IsInductionHeating__c;						//IHコンロ
		pc1.isRC = account.IsRC__c;													//RC
		pc1.isSRC = account.IsSRC__c;												//SRC
		pc1.isWalkInCloset = account.IsWalkInCloset__c;								//ウォークインクローゼット
		pc1.isAirConditioner = account.IsAirConditioner__c;							//エアコン
		pc1.isElevator = account.IsElevator__c;										//エレベーター
		pc1.isAutoLock = account.IsAutoLock__c;										//オートロック
		pc1.isAllElectric = account.IsAllElectric__c;								//オール電化
		pc1.isAllWestern = account.IsAllWestern__c;									//オール洋間
		pc1.isCarport = account.IsCarport__c;										//カーポート
		pc1.isCounterKitchen = account.IsCounterKitchen__c;							//カウンターキッチン
		pc1.isGasStove = account.IsGasStove__c;										//ガスコンロ
		pc1.isTwoGasStove = account.IsTwoGasStove__c;								//コンロ2口
		pc1.isMoreGasStove = account.IsMoreGasStove__c;								//コンロ3口以上
		pc1.isSystemKitchen = account.IsSystemKitchen__c;							//システムキッチン
		pc1.isShowerWashBasin = account.IsShowerWashBasin__c;						//シャワー付き洗面台
		pc1.isShoeCloak = account.IsShoeCloak__c;									//シューズクローク
		pc1.isShoesBox = account.IsShoesBox__c;										//シューズボックス
		pc1.isDesigners = account.IsDesigners__c;									//デザイナーズ
		pc1.isTrunkRoom = account.IsTrunkRoom__c;									//トランクルーム
		pc1.isInternetFree = account.IsInternetFree__c;								//ネット使用料無料
		pc1.isBikeStorage = account.IsBikeStorage__c;								//バイク可
		pc1.isSepalateBathAndRestroom = account.IsSepalateBathAndRestroom__c;		//バス・トイレ別
		pc1.isBalcony = account.IsBalcony__c;										//バルコニー
		pc1.isBuiltInGarage = account.IsBuiltInGarage__c;							//ビルトインガレージ
		pc1.isPropaneGas = account.IsPropaneGas__c;									//プロパンガス
		pc1.isOtherPet = account.IsOtherPet__c;										//ペット(その他)
		pc1.isSmallPet = account.IsSmallPet__c;										//ペット(小型犬)
		pc1.isLargePet = account.IsLargePet__c;										//ペット(大型犬)
		pc1.isMiddlePet = account.IsMiddlePet__c;									//ペット(中型犬)
		pc1.isCat = account.IsCat__c;												//ペット(猫)
		pc1.isPet = account.IsPet__c;												//ペット可
		pc1.isMaisonette = account.IsMaisonette__c;									//メゾネット
		pc1.isMonitorIntercom = account.IsMonitorIntercom__c;						//モニター付きインターホン
		pc1.isRenovation = account.IsRenovation__c;									//リノベーション
		pc1.isRoofBalcony = account.IsRoofBalcony__c;								//ルーフバルコニー
		pc1.isRoomShare = account.IsRoomShare__c;									//ルームシェア可
		pc1.isLoft = account.IsLoft__c;												//ロフト
		pc1.isOneRoom = account.IsOneRoom__c;										//ワンルーム
		pc1.isIppambutsu = account.IsIppambutsu__c;									//一般物
		pc1.isWashlet = account.IsWashlet__c;										//温水洗浄便座
		pc1.isFurniture = account.IsFurniture__c;									//家具付き
		pc1.isHomeAppliance = account.IsHomeAppliance__c;							//家電付き
		pc1.isForeigner = account.IsForeigner__c;									//外国人契約可
		pc1.isCornerRoom = account.IsCornerRoom__c;									//角部屋
		pc1.isStudent = account.IsStudent__c;										//学生限定マンション
		pc1.isMusicalInstruments = account.IsMusicalInstruments__c;					//楽器相談可
		pc1.isIncludeManagementFee = account.IsIncludeManagementFee__c;				//管理費込み
		pc1.desiredArea = account.DesiredArea__c;									//希望地域
		pc1.isLightweightSteel = account.IsLightweightSteel__c;						//軽量鉄骨
		pc1.isDetachedHouse = account.IsDetachedHouse__c;							//戸建て
		pc1.isNonRenewalFee = account.IsNonRenewalFee__c;							//更新料なし
		pc1.isElderly = account.IsElderly__c;										//高齢者歓迎
		pc1.isTopFloor = account.IsTopFloor__c;										//最上階
		pc1.isOfficeAvailable = account.IsOfficeAvailable__c;						//事務所利用可
		pc1.isInnerLandry = account.IsInnerLandry__c;								//室内洗濯機置場
		pc1.isWoman = account.IsWoman__c;											//女性限定
		pc1.isSmallBike = account.IsSmallBike__c;									//小型バイク
		pc1.isFloorHeating = account.IsFloorHeating__c;								//床暖房
		pc1.isWelfareAvailable = account.IsWelfareAvailable__c;						//生活保護契約可
		pc1.isWest = account.IsWest__c;												//西
		pc1.occupancyAreaLowerLimit = account.OccupancyAreaLowerLimit__c;			//占有面積（下限）
		pc1.occupancyAreaUpperLimit = account.OccupancyAreaUpperLimit__c;			//占有面積（上限）
		pc1.isPrivateGarden = account.IsPrivateGarden__c;							//専用庭
		pc1.isRegalLavatory = account.IsRegalLavatory__c;							//洗面所独立
		pc1.isLargeBike = account.IsLargeBike__c;									//大型バイク
		pc1.isDeliveryBox = account.IsDeliveryBox__c;								//宅配ボックス
		pc1.buildingAge = account.BuildingAge__c;									//築年数
		pc1.isMediumBike = account.IsMediumBike__c;									//中型バイク
		pc1.isPluralCarParking = account.IsPluralCarParking__c;						//駐車場2台可
		pc1.isParking = account.IsParking__c;										//駐車場空きあり
		pc1.isIncludeParkingFee = account.IsIncludeParkingFee__c;					//駐車場代込み
		pc1.isBicycleParking = account.IsBicycleParking__c;							//駐輪場
		pc1.rentFeeFrom = account.RentFeeFrom__c;									//賃料から
		pc1.rentFeeTo = account.RentFeeTo__c;										//賃料まで
		pc1.isAditionalBoiling = account.IsAditionalBoiling__c;						//追焚機能
		pc1.isNonCleaningFee = account.IsNonCleaningFee__c;							//定額修繕費なし
		pc1.isSteel = account.IsSteel__c;											//鉄骨造
		pc1.isElectricStove = account.IsElectricStove__c;							//電気コンロ
		pc1.walkingTime = account.WalkingTime__c;									//徒歩
		pc1.isTownGas = account.IsTownGas__c;										//都市ガス
		pc1.isEast = account.IsEast__c;												//東
		pc1.isSouth = account.IsSouth__c;											//南
		pc1.isSouthWest = account.IsSouthWest__c;									//南西
		pc1.isSouthEast = account.IsSouthEast__c;									//南東
		pc1.isNonDeposit = account.IsNonDeposit__c;									//敷金/保証金なし
		pc1.isInSiteParking = account.IsInSiteParking__c;							//敷地内駐車場
		pc1.isCondominiumRental = account.IsCondominiumRental__c;					//分譲賃貸
		pc1.isNonGuaranteeidCompany = account.IsNonGuaranteeidCompany__c;			//保証会社不要
		pc1.isNoGuarantor = account.IsNoGuarantor__c;								//保証人不要
		pc1.isNorth = account.IsNorth__c;											//北
		pc1.isNorthWest = account.IsNorthWest__c;									//北西
		pc1.isNorthEast = account.IsNorthEast__c;									//北東
		pc1.isWooden = account.IsWooden__c;											//木造
		pc1.isDehumidifierForBathroom = account.IsDehumidifierForBathroom__c;		//浴室乾燥機
		pc1.isNonKeyMoney = account.IsNonKeyMoney__c;								//礼金なし

		pcList.add(pc1);

		for(AccountPropertyConditions__c apc : account.AccountPropertyConditionss__r){
			propCond pc2 = new propCond();
			pc2.isReservePropertyCond = apc.IsReservePropertyConditions__c;				//予約物件条件
			pc2.desiredTrainRoute1 = apc.DesiredTrainRoute1__c;						    //希望路線１
			pc2.desiredTrainRoute2 = apc.DesiredTrainRoute2__c;					    	//希望路線2
			pc2.desiredTrainRoute3 = apc.DesiredTrainRoute3__c;					    	//希望路線3
			pc2.desiredElementarySchoolArea = apc.DesiredElementarySchoolArea__c;   	//小学校希望学区
			pc2.desiredJuniorHighSchoolArea = apc.DesiredJuniorHighSchoolArea__c;   	//中学校希望学区
			pc2.Name = apc.Name;														//物件条件名
			pc2.is1DK = apc.Is1DK__c;													//1DK
			pc2.is1K = apc.Is1K__c;														//1K
			pc2.is1LDK1SLDK = apc.Is1LDK1SLDK__c;										//1LDK/SLDK
			pc2.isFirstFloor = apc.IsFirstFloor__c;										//1階
			pc2.is2K2DK = apc.Is2K2DK__c;												//2K/DK
			pc2.is2LDK2SLDK = apc.Is2LDK2SLDK__c;										//2LDK/SLDK
			pc2.isSecondFloorOver = apc.IsSecondFloorOver__c;							//2階以上
			pc2.isTwoTenant = apc.IsTwoTenant__c;										//2人入居可
			pc2.is3K3DK = apc.Is3K3DK__c;												//3K/DK
			pc2.is3LDK3SLDK = apc.Is3LDK3SLDK__c;										//3LDK/SLDK
			pc2.is4K4DK4LDKFrom = apc.Is4K4DK4LDKFrom__c;								//4K/DK/LDK~
			pc2.isBSAntenna = apc.IsBSAntenna__c;										//BSアンテナ
			pc2.isCATV = apc.IsCATV__c;													//CATV
			pc2.isCSAntenna = apc.IsCSAntenna__c;										//CSアンテナ
			pc2.isInductionHeating = apc.IsInductionHeating__c;							//IHコンロ
			pc2.isRC = apc.IsRC__c;														//RC
			pc2.isSRC = apc.IsSRC__c;													//SRC
			pc2.isWalkInCloset = apc.IsWalkInCloset__c;									//ウォークインクローゼット
			pc2.isAirConditioner = apc.IsAirConditioner__c;								//エアコン
			pc2.isElevator = apc.IsElevator__c;											//エレベーター
			pc2.isAutoLock = apc.IsAutoLock__c;											//オートロック
			pc2.isAllElectric = apc.IsAllElectric__c;									//オール電化
			pc2.isAllWestern = apc.IsAllWestern__c;										//オール洋間
			pc2.isCarport = apc.IsCarport__c;											//カーポート
			pc2.isCounterKitchen = apc.IsCounterKitchen__c;								//カウンターキッチン
			pc2.isGasStove = apc.IsGasStove__c;											//ガスコンロ
			pc2.isTwoGasStove = apc.IsTwoGasStove__c;									//コンロ2口
			pc2.isMoreGasStove = apc.IsMoreGasStove__c;									//コンロ3口以上
			pc2.isSystemKitchen = apc.IsSystemKitchen__c;								//システムキッチン
			pc2.isShowerWashBasin = apc.IsShowerWashBasin__c;							//シャワー付き洗面台
			pc2.isShoeCloak = apc.IsShoeCloak__c;										//シューズクローク
			pc2.isShoesBox = apc.IsShoesBox__c;											//シューズボックス
			pc2.isDesigners = apc.IsDesigners__c;										//デザイナーズ
			pc2.isTrunkRoom = apc.IsTrunkRoom__c;										//トランクルーム
			pc2.isInternetFree = apc.IsInternetFree__c;									//ネット使用料無料
			pc2.isBikeStorage = apc.IsBikeStorage__c;									//バイク可
			pc2.isSepalateBathAndRestroom = apc.IsSepalateBathAndRestroom__c;			//バス・トイレ別
			pc2.isBalcony = apc.IsBalcony__c;											//バルコニー
			pc2.isBuiltInGarage = apc.IsBuiltInGarage__c;								//ビルトインガレージ
			pc2.isPropaneGas = apc.IsPropaneGas__c;										//プロパンガス
			pc2.isOtherPet = apc.IsOtherPet__c;											//ペット(その他)
			pc2.isSmallPet = apc.IsSmallPet__c;											//ペット(小型犬)
			pc2.isLargePet = apc.IsLargePet__c;											//ペット(大型犬)
			pc2.isMiddlePet = apc.IsMiddlePet__c;										//ペット(中型犬)
			pc2.isCat = apc.IsCat__c;													//ペット(猫)
			pc2.isPet = apc.IsPet__c;													//ペット可
			pc2.isMaisonette = apc.IsMaisonette__c;										//メゾネット
			pc2.isMonitorIntercom = apc.IsMonitorIntercom__c;							//モニター付きインターホン
			pc2.isRenovation = apc.IsRenovation__c;										//リノベーション
			pc2.isRoofBalcony = apc.IsRoofBalcony__c;									//ルーフバルコニー
			pc2.isRoomShare = apc.IsRoomShare__c;										//ルームシェア可
			pc2.isLoft = apc.IsLoft__c;													//ロフト
			pc2.isOneRoom = apc.IsOneRoom__c;											//ワンルーム
			pc2.isIppambutsu = apc.IsIppambutsu__c;										//一般物
			pc2.isWashlet = apc.IsWashlet__c;											//温水洗浄便座
			pc2.isFurniture = apc.IsFurniture__c;										//家具付き
			pc2.isHomeAppliance = apc.IsHomeAppliance__c;								//家電付き
			pc2.isForeigner = apc.IsForeigner__c;										//外国人契約可
			pc2.isCornerRoom = apc.IsCornerRoom__c;										//角部屋
			pc2.isStudent = apc.IsStudent__c;											//学生限定マンション
			pc2.isMusicalInstruments = apc.IsMusicalInstruments__c;						//楽器相談可
			pc2.isIncludeManagementFee = apc.IsIncludeManagementFee__c;					//管理費込み
			pc2.desiredArea = apc.DesiredArea__c;										//希望地域
			pc2.isLightweightSteel = apc.IsLightweightSteel__c;							//軽量鉄骨
			pc2.isDetachedHouse = apc.IsDetachedHouse__c;								//戸建て
			pc2.isNonRenewalFee = apc.IsNonRenewalFee__c;								//更新料なし
			pc2.isElderly = apc.IsElderly__c;											//高齢者歓迎
			pc2.isTopFloor = apc.IsTopFloor__c;											//最上階
			pc2.isOfficeAvailable = apc.IsOfficeAvailable__c;							//事務所利用可
			pc2.isInnerLandry = apc.IsInnerLandry__c;									//室内洗濯機置場
			pc2.isWoman = apc.IsWoman__c;												//女性限定
			pc2.isSmallBike = apc.IsSmallBike__c;										//小型バイク
			pc2.isFloorHeating = apc.IsFloorHeating__c;									//床暖房
			pc2.isWelfareAvailable = apc.IsWelfareAvailable__c;							//生活保護契約可
			pc2.isWest = apc.IsWest__c;													//西
			pc2.occupancyAreaLowerLimit = apc.OccupancyAreaLowerLimit__c;				//占有面積（下限）
			pc2.occupancyAreaUpperLimit = apc.OccupancyAreaUpperLimit__c;				//占有面積（上限）
			pc2.isPrivateGarden = apc.IsPrivateGarden__c;								//専用庭
			pc2.isRegalLavatory = apc.IsRegalLavatory__c;								//洗面所独立
			pc2.isLargeBike = apc.IsLargeBike__c;										//大型バイク
			pc2.isDeliveryBox = apc.IsDeliveryBox__c;									//宅配ボックス
			pc2.buildingAge = apc.BuildingAge__c;										//築年数
			pc2.isMediumBike = apc.IsMediumBike__c;										//中型バイク
			pc2.isPluralCarParking = apc.IsPluralCarParking__c;							//駐車場2台可
			pc2.isParking = apc.IsParking__c;											//駐車場空きあり
			pc2.isIncludeParkingFee = apc.IsIncludeParkingFee__c;						//駐車場代込み
			pc2.isBicycleParking = apc.IsBicycleParking__c;								//駐輪場
			pc2.rentFeeFrom = apc.RentFeeFrom__c;										//賃料から
			pc2.rentFeeTo = apc.RentFeeTo__c;											//賃料まで
			pc2.isAditionalBoiling = apc.IsAditionalBoiling__c;							//追焚機能
			pc2.isNonCleaningFee = apc.IsNonCleaningFee__c;								//定額修繕費なし
			pc2.isSteel = apc.IsSteel__c;												//鉄骨造
			pc2.isElectricStove = apc.IsElectricStove__c;								//電気コンロ
			pc2.walkingTime = apc.WalkingTime__c;										//徒歩
			pc2.isTownGas = apc.IsTownGas__c;											//都市ガス
			pc2.isEast = apc.IsEast__c;													//東
			pc2.isSouth = apc.IsSouth__c;												//南
			pc2.isSouthWest = apc.IsSouthWest__c;										//南西
			pc2.isSouthEast = apc.IsSouthEast__c;										//南東
			pc2.isNonDeposit = apc.IsNonDeposit__c;										//敷金/保証金なし
			pc2.isInSiteParking = apc.IsInSiteParking__c;								//敷地内駐車場
			pc2.isCondominiumRental = apc.IsCondominiumRental__c;						//分譲賃貸
			pc2.isNonGuaranteeidCompany = apc.IsNonGuaranteeidCompany__c;				//保証会社不要
			pc2.isNoGuarantor = apc.IsNoGuarantor__c;									//保証人不要
			pc2.isNorth = apc.IsNorth__c;												//北
			pc2.isNorthWest = apc.IsNorthWest__c;										//北西
			pc2.isNorthEast = apc.IsNorthEast__c;										//北東
			pc2.isWooden = apc.IsWooden__c;												//木造
			pc2.isDehumidifierForBathroom = apc.IsDehumidifierForBathroom__c;			//浴室乾燥機
			pc2.isNonKeyMoney = apc.IsNonKeyMoney__c;									//礼金なし
			
			pcList.add(pc2);			
		}

		return pcList;
	}

	// 取引先、お客様物件の物件条件用のクラス
	public class propCond{

		public Id desiredTrainRoute1 { get; set; }					//希望路線１
        public Id desiredTrainRoute2 { get; set; }					//希望路線2
        public Id desiredTrainRoute3 { get; set; }					//希望路線3
        public Id desiredElementarySchoolArea { get; set; }			//小学校希望学区
        public Id desiredJuniorHighSchoolArea { get; set; }			//中学校希望学区

		public Boolean isReservePropertyCond { get; set; }			//予約物件条件
		public String Name { get; set; }							//物件条件名
		public Boolean is1DK { get; set; }							//1DK
		public Boolean is1K { get; set; }							//1K
		public Boolean is1LDK1SLDK { get; set; }					//1LDK/SLDK
		public Boolean isFirstFloor { get; set; }					//1階
		public Boolean is2K2DK { get; set; }						//2K/DK
		public Boolean is2LDK2SLDK { get; set; }					//2LDK/SLDK
		public Boolean isSecondFloorOver { get; set; }				//2階以上
		public Boolean isTwoTenant { get; set; }					//2人入居可
		public Boolean is3K3DK { get; set; }						//3K/DK
		public Boolean is3LDK3SLDK { get; set; }					//3LDK/SLDK
		public Boolean is4K4DK4LDKFrom { get; set; }				//4K/DK/LDK~
		public Boolean isBSAntenna { get; set; }					//BSアンテナ
		public Boolean isCATV { get; set; }							//CATV
		public Boolean isCSAntenna { get; set; }					//CSアンテナ
		public Boolean isInductionHeating { get; set; }				//IHコンロ
		public Boolean isRC { get; set; }							//RC
		public Boolean isSRC { get; set; }							//SRC
		public Boolean isWalkInCloset { get; set; }					//ウォークインクローゼット
		public Boolean isAirConditioner { get; set; }				//エアコン
		public Boolean isElevator { get; set; }						//エレベーター
		public Boolean isAutoLock { get; set; }						//オートロック
		public Boolean isAllElectric { get; set; }					//オール電化
		public Boolean isAllWestern { get; set; }					//オール洋間
		public Boolean isCarport { get; set; }						//カーポート
		public Boolean isCounterKitchen { get; set; }				//カウンターキッチン
		public Boolean isGasStove { get; set; }						//ガスコンロ
		public Boolean isTwoGasStove { get; set; }					//コンロ2口
		public Boolean isMoreGasStove { get; set; }					//コンロ3口以上
		public Boolean isSystemKitchen { get; set; }				//システムキッチン
		public Boolean isShowerWashBasin { get; set; }				//シャワー付き洗面台
		public Boolean isShoeCloak { get; set; }					//シューズクローク
		public Boolean isShoesBox { get; set; }						//シューズボックス
		public Boolean isDesigners { get; set; }					//デザイナーズ
		public Boolean isTrunkRoom { get; set; }					//トランクルーム
		public Boolean isInternetFree { get; set; }					//ネット使用料無料
		public Boolean isBikeStorage { get; set; }					//バイク可
		public Boolean isSepalateBathAndRestroom { get; set; }		//バス・トイレ別
		public Boolean isBalcony { get; set; }						//バルコニー
		public Boolean isBuiltInGarage { get; set; }				//ビルトインガレージ
		public Boolean isPropaneGas { get; set; }					//プロパンガス
		public Boolean isOtherPet { get; set; }						//ペット(その他)
		public Boolean isSmallPet { get; set; }						//ペット(小型犬)
		public Boolean isLargePet { get; set; }						//ペット(大型犬)
		public Boolean isMiddlePet { get; set; }					//ペット(中型犬)
		public Boolean isCat { get; set; }							//ペット(猫)
		public Boolean isPet { get; set; }							//ペット可
		public Boolean isMaisonette { get; set; }					//メゾネット
		public Boolean isMonitorIntercom { get; set; }				//モニター付きインターホン
		public Boolean isRenovation { get; set; }					//リノベーション
		public Boolean isRoofBalcony { get; set; }					//ルーフバルコニー
		public Boolean isRoomShare { get; set; }					//ルームシェア可
		public Boolean isLoft { get; set; }							//ロフト
		public Boolean isOneRoom { get; set; }						//ワンルーム
		public Boolean isIppambutsu { get; set; }					//一般物
		public Boolean isWashlet { get; set; }						//温水洗浄便座
		public Boolean isFurniture { get; set; }					//家具付き
		public Boolean isHomeAppliance { get; set; }				//家電付き
		public Boolean isForeigner { get; set; }					//外国人契約可
		public Boolean isCornerRoom { get; set; }					//角部屋
		public Boolean isStudent { get; set; }						//学生限定マンション
		public Boolean isMusicalInstruments { get; set; }			//楽器相談可
		public Boolean isIncludeManagementFee { get; set; }			//管理費込み
		public String desiredArea { get; set; }						//希望地域
		public Boolean isLightweightSteel { get; set; }				//軽量鉄骨
		public Boolean isDetachedHouse { get; set; }				//戸建て
		public Boolean isNonRenewalFee { get; set; }				//更新料なし
		public Boolean isElderly { get; set; }						//高齢者歓迎
		public Boolean isTopFloor { get; set; }						//最上階
		public Boolean isOfficeAvailable { get; set; }				//事務所利用可
		public Boolean isInnerLandry { get; set; }					//室内洗濯機置場
		public Boolean isWoman { get; set; }						//女性限定
		public Boolean isSmallBike { get; set; }					//小型バイク
		public Boolean isFloorHeating { get; set; }					//床暖房
		public Boolean isWelfareAvailable { get; set; }				//生活保護契約可
		public Boolean isWest { get; set; }							//西
		public String occupancyAreaLowerLimit { get; set; }			//占有面積（下限）
		public String occupancyAreaUpperLimit { get; set; }			//占有面積（上限）
		public Boolean isPrivateGarden { get; set; }				//専用庭
		public Boolean isRegalLavatory { get; set; }				//洗面所独立
		public Boolean isLargeBike { get; set; }					//大型バイク
		public Boolean isDeliveryBox { get; set; }					//宅配ボックス
		public String buildingAge { get; set; }						//築年数
		public Boolean isMediumBike { get; set; }					//中型バイク
		public Boolean isPluralCarParking { get; set; }				//駐車場2台可
		public Boolean isParking { get; set; }						//駐車場空きあり
		public Boolean isIncludeParkingFee { get; set; }			//駐車場代込み
		public Boolean isBicycleParking { get; set; }				//駐輪場
		public Decimal rentFeeFrom { get; set; }					//賃料から
		public Decimal rentFeeTo { get; set; }						//賃料まで
		public Boolean isAditionalBoiling { get; set; }				//追焚機能
		public Boolean isNonCleaningFee { get; set; }				//定額修繕費なし
		public Boolean isSteel { get; set; }						//鉄骨造
		public Boolean isElectricStove { get; set; }				//電気コンロ
		public String walkingTime { get; set; }						//徒歩
		public Boolean isTownGas { get; set; }						//都市ガス
		public Boolean isEast { get; set; }							//東
		public Boolean isSouth { get; set; }						//南
		public Boolean isSouthWest { get; set; }					//南西
		public Boolean isSouthEast { get; set; }					//南東
		public Boolean isNonDeposit { get; set; }					//敷金/保証金なし
		public Boolean isInSiteParking { get; set; }				//敷地内駐車場
		public Boolean isCondominiumRental { get; set; }			//分譲賃貸
		public Boolean isNonGuaranteeidCompany { get; set; }		//保証会社不要
		public Boolean isNoGuarantor { get; set; }					//保証人不要
		public Boolean isNorth { get; set; }						//北
		public Boolean isNorthWest { get; set; }					//北西
		public Boolean isNorthEast { get; set; }					//北東
		public Boolean isWooden { get; set; }						//木造
		public Boolean isDehumidifierForBathroom { get; set; }		//浴室乾燥機
		public Boolean isNonKeyMoney { get; set; }					//礼金なし

		// コンストラクタ
		public propCond(){
		}
	}
// ▲2021.10.08 No.307 対応で追加	
}