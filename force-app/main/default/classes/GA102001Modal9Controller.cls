/**
 * 物件検索モーダル
 */
public with sharing class GA102001Modal9Controller {

	/** 共通クラス */
	public GA102001Modal9ParameterClass Parameter { get; set; }

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

	public GA102001Modal9Controller() {
	}
}