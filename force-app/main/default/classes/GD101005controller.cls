//業者名寄せ画面のコントローラー
public with sharing class GD101005controller {

	//Public変数
	public Account targetRecord { get; set; } //画面表示用アカウントレコード
	public List<Selected> displayCandidateResult { get; set; } //名寄せ対象アカウントリスト
	public Integer mergeSelectedIndex { get; set; } //名寄せリストセットインデックス
	public Boolean isOpenError { get; set; } //エラーフラグ
	public Boolean hasErrorMessage { get; set; } //エラーメッセージ保有フラグ
	public String MSG_COM_V_EXECUTE_NON_MERGE { get { return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_EXECUTE_NON_MERGE); } private set; } //js用名寄せ不要確認メッセージ
	public String MSG_COM_I_NON_MERGE_END { get { return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_NON_MERGE_END); } private set; } //js用名寄せ不要完了メッセージ

	//Private変数
	private id targetAccountId;
	private List<Account> candidateResultList;

	public GD101005controller() {

		try{
			//店舗異動が取得できなければエラー
			CommonUtil.getStaffCurrentShop();
			//targetAccountIdを設定
			targetAccountId = ApexPages.currentPage().getParameters().get('Id');

			//レコード情報取得
			this.targetRecord = SelectRecordInfo(targetAccountId);

			//検索対象リスト取得
			this.candidateResultList = NameMergeUtil.getSupplierMergeList(targetRecord, null);

			//表示用リストをnewする。
			displayCandidateResult = new List<Selected>();
			Integer IndexCount = 0;

			//内部クラスSelectedにインデックスをセットする。
			for(Account candidate :candidateResultList) {
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

	//リスト表示用内部クラス
	public class Selected {

		public Account candidateResult { get; set; }
		public Integer setIndex { get; set; }

		public Selected(Account candidateResult, Integer setIndex) {
			this.candidateResult = candidateResult;
			this.setIndex = setIndex;
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
			Account margeCompletedFlagAccount = new Account(id = targetAccountId, IsMergeCompletedFlag__c = True);
			SecureDML.secureUpdate(margeCompletedFlagAccount);

		} catch(Exception e) {

			Database.rollback(sp);
			hasErrorMessage = true;
			CommonUtil.setErrorMessage(e);
		}

	}

	//レコード情報取得
	private Account SelectRecordInfo(Id targetAccountId) {
		List<Account> targetRecordList = [SELECT id, 
									      Name, 
									      SupplierType__c, 
									      PostalCode__c, 
									      Address__c, 
									      State__c, 
									      Email__c, 
									      Phone, 
									      IsMergeCompletedFlag__c, 
									      SystemModstamp
									      FROM Account
									      WHERE Id = :targetAccountId AND
									      RecordType.DeveloperName = :CommonConst.ACCOUNT_RECTYPE_SUPPLIER];

		//レコード情報が取得できなければビジネスロジックException発行
		if(targetRecordList.isEmpty()) {
			BusinessLogicException ex = new BusinessLogicException();
			ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
			throw ex;
		}

		return targetRecordList [0];

	}

	//楽観ロックチェックメソッド
	private void optimisticLockCheck(Account lockCheckTarget) {
		List<Account> checkOptimisticLockExceptionRecord = new List<Account>();
		checkOptimisticLockExceptionRecord = [SELECT id
											    FROM Account
											    WHERE id = :lockCheckTarget.Id
											    AND SystemModStamp = :lockCheckTarget.systemModStamp
		];

		if(checkOptimisticLockExceptionRecord.isEmpty()) {

			OptimisticLockException ex = new OptimisticLockException();
			throw ex;

		}

	}


}