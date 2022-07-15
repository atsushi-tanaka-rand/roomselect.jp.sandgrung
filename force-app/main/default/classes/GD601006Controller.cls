//建物名寄せ画面のコントローラー
public with sharing class GD601006Controller {

	//Public変数
	public Building__c targetRecord { get; set; }                             //画面表示用建物レコード
	public List<Selected> displayCandidateResult { get; set; }                //建物名寄せ対象リスト
	public List<DisplayProperty> displayPropertyCandidateResult { get; set; } //物件名寄せ対象リスト
	public Integer mergeSelectedIndex { get; set; } //建物名寄せリストインデックス
	public String inputMode    { get; set; }     //画面モード名
    
    public String propertyMergeId1 {get; set;} //物件名寄せ対象1
    public String propertyMergeId2 {get; set;} //物件名寄せ対象2
    
	public Boolean allSelected { get; set; }     //物件名寄せ全選択チェックボックス
	public Boolean isOpenError { get; set; }     //エラーフラグ
	public Boolean hasErrorMessage { get; set; } //エラーメッセージ保有フラグ
    
	public String MSG_COM_V_EXECUTE_NON_MERGE { get { return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_EXECUTE_NON_MERGE); } private set; } //js用名寄せ不要確認メッセージ
	public String MSG_COM_I_NON_MERGE_END { get { return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_NON_MERGE_END); } private set; } //js用名寄せ不要完了メッセージ

	//Private変数
	private id targetBuildingId;
	private List<Building__c> candidateResultList;

    //コンストラクタ
	public GD601006Controller() {

		try{
			//店舗異動が取得できなければエラー
			CommonUtil.getStaffCurrentShop();
			//targetBuldingIdを設定
			targetBuildingId = ApexPages.currentPage().getParameters().get('Id');

			//モードを取得
			inputMode = ApexPages.currentPage().getParameters().get('Mode');
			if((inputMode != '建物名寄せ') & (inputMode != '物件名寄せ')) {
				BusinessLogicException ex = new BusinessLogicException();
				ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
				throw ex;
			}

			//レコード情報取得
			this.targetRecord = SelectRecordInfo(targetBuildingId);

			//物件名寄せ表示用リストを作る。
			displayPropertyCandidateResult = new List<DisplayProperty>();

			for(property__c candidate :targetRecord.PropertyBuilding__r) {
				DisplayProperty a1 = new DisplayProperty(candidate);
				displayPropertyCandidateResult.add(a1);
			}

			//建物名寄せ対象リスト取得
			this.candidateResultList = NameMergeUtil.getBuildingMergeList(targetRecord, null);

			//建物名寄せ表示用リストをnewする。
			displayCandidateResult = new List<Selected>();
			Integer IndexCount = 0;

			//建物名寄せ表示用内部クラスにインデックスをセットする。
			for(Building__c candidate :candidateResultList) {
				Selected a1 = new Selected(candidate, Indexcount);
				displayCandidateResult.add(a1);
				IndexCount += 1;

			}

		} catch(Exception e) {

			//エラーを設定
			isOpenError = true;
			CommonUtil.setErrorMessage(e);

		}

	}

	//名寄せ不要メソッド
	public void margeCompleted() {


		Savepoint sp = Database.setSavepoint();

		try{
			hasErrorMessage = false;

			//楽観ロックチェック
			optimisticLockCheck(targetRecord);

			//名寄せ完了フラグ更新
			Building__c margeCompletedFlagBuilding = new Building__c(id = targetBuildingId, IsMergeCompletedFlag__c = True);
			SecureDML.secureUpdate(margeCompletedFlagBuilding);

		} catch(Exception e) {

			Database.rollback(sp);
			hasErrorMessage = true;
			CommonUtil.setErrorMessage(e);
		}

	}

	//物件対象チェック数確認
	public void checkSelectedNumber() {

		try{
            //初期化
			hasErrorMessage = false;
            propertyMergeId1 = null;
            propertyMergeId2 = null;

			//チェックボックスカウンター宣言
			Integer checkboxNum = 0;

			//チェックボックスカウント
			for(DisplayProperty property :displayPropertyCandidateResult) {
				if(property.isSelected == true) {
					checkboxNum += 1;
                    
                    //名寄せ比較画面へのパラメータ設定
                    if (checkboxNum == 1) {
                        propertyMergeId1 = property.candidatePropertyResult.Id;
                    } else if (checkboxNum == 2) {
                        propertyMergeId2 = property.candidatePropertyResult.Id;
                    }
				}

			}

			//チェックボックスの数が２かどうかチェック
			if(checkboxNum != 2) {
				BusinessLogicException ex = new BusinessLogicException();
				ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_PROP_W_SELECTION_MERGE_PROPERTY_NUMBER));
				throw ex;
			}

		} catch(Exception e) {
			hasErrorMessage = true;
			CommonUtil.setErrorMessage(e);
		}

	}


    //*********************************************  privateメソッド  **********************************************************

	//レコード情報取得
	private Building__c SelectRecordInfo(Id targetBuildingId) {
		List<Building__c> targetRecordList = [SELECT id, 
										      Name, 
										      BuildName2__c, 
										      BuildName3__c, 
										      BuildKana__c, 
										      BuildKana2__c, 
										      BuildKana3__c, 
										      PostalCode__c, 
										      Address__c, 
										      IsMergeCompletedFlag__c, 
										      SystemModstamp,
                                              (SELECT
										       Id, 
										       Name, 
										       LiveStatus__c, 
										       RoomLayout__c, 
										       RentFee__c, 
										       PhotoCount__c, 
										       RoomArea__c, 
										       RoomCount__c, 
										       IsMergeCompletedFlag__c
										       FROM PropertyBuilding__r
                                               ORDER BY Name ASC
                                              )
                                              FROM Building__c
										      WHERE Id = :targetBuildingId];

		//レコード情報が取得できなければビジネスロジックException発行
		if(targetRecordList.isEmpty()) {
			BusinessLogicException ex = new BusinessLogicException();
			ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
			throw ex;
		}

		return targetRecordList [0];

	}

	//楽観ロックチェックメソッド
	private void optimisticLockCheck(Building__c lockCheckTarget) {
		List<Building__c> checkOptimisticLockExceptionRecord = new List<Building__c>();
		checkOptimisticLockExceptionRecord = [SELECT id
										      FROM Building__c
										      WHERE id = :lockCheckTarget.Id
										      AND SystemModStamp = :lockCheckTarget.systemModStamp
		];

		if(checkOptimisticLockExceptionRecord.isEmpty()) {

			OptimisticLockException ex = new OptimisticLockException();
			throw ex;

		}

	}
    
    
    //***************************************** 内部クラス ***********************************************

	//物件名寄せリスト表示用内部クラス
	public class DisplayProperty {

		public property__c candidatePropertyResult { get; set; }
		public boolean isSelected { get; set; }

		public DisplayProperty(property__c candidatePropertyResult) {

			isSelected = False;
			this.candidatePropertyResult = candidatePropertyResult;
		}

	}

	//建物名寄せリスト表示用内部クラス
	public class Selected {

		public Building__c candidateResult { get; set; }
		public Integer setIndex { get; set; }

		public Selected(Building__c candidateResult, Integer setIndex) {
			this.candidateResult = candidateResult;
			this.setIndex = setIndex;
		}

	}
}