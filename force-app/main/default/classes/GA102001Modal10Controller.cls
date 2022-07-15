/**
 * 予約物件条件モーダル
 */
public with sharing class GA102001Modal10Controller {

	/** 共通クラス */
	public GA102001Modal10ParameterClass Parameter { get; set; }

	/** エラーフラグ */ 
	public Boolean isOpenError { get; set; }

	/** エラーメッセージ保有フラグ */ 
	public Boolean hasErrorMessage { get; set; }

	public Boolean init{
		get{
			if (Parameter.isDrawing) {
				Parameter.isDrawing = false;
				return false;
			}
			return true;
		}
	}

	public GA102001Modal10Controller() {
	}

	/**
	 * OKボタン押下時の処理
	 */
	public void clickOk(){
		//VFからチェックリストの値を取得
		String checkListJoin = Apexpages.currentPage().getParameters().get('checkList');
		//チェックリストの値の型を修正
		List<String> checkStringList = new List<String>();
		checkStringList = checkListJoin.split(',');
		List<Boolean> checkList = new List<Boolean>();
		for(String checkString : checkStringList){
			checkList.add(Boolean.valueOf(checkString));
		}
		//パラメータにチェックリストの値をセット
		Parameter.spcReservedList = checkList.clone();
	}
}