/**
 * 定型文選択
 */
public with sharing class GL101001Modal1Controller {

	/* パラメータ */
	public GL101001Modal1ParameterClass parameter {get; set;} // 定型文選択画面パラメータ

	/** 画面項目 */
	public GL101001Controller.ScreenFixedPhrase screenFixedPhrase {get; set;} // 定型文情報

	/* フラグ */
	public Boolean hasErrorMessage {get; set;} // エラーメッセージ保有フラグ

	/**
	 * ページ描画時処理
	 * @return Boolean true:初回以外の描画、false:初回描画
	 */
	public Boolean init {
		get {
			// 初回描画処理
			if (this.parameter.isDrawing) {

				// パラメータの設定
				this.screenFixedPhrase		= this.parameter.screenFixedPhrase;
				this.parameter.isDrawing	= false;

				// エラーメッセージ保有フラグの初期化
				this.hasErrorMessage = this.hasErrorMessage;

				return false;
			}
			return true;
		}
	}

	/**
	 * 定型文押下
	 */
	public void clickFixedPhrase() {

		Savepoint sp = Database.setSavepoint();
		this.hasErrorMessage = false;

		try {
			// 選択されたフォルダ、定型文を取得
			List<GL101001Controller.FixedPhraseValue> fixedPhraseList = this.screenFixedPhrase.fixedPhraseMap.get(this.screenFixedPhrase.selectedKey);
			GL101001Controller.FixedPhraseValue fixedPhraseValue = fixedPhraseList[this.screenFixedPhrase.selectedValueIdx];

			// 本文の置換処理
			String replaceVal = MailUtil.getMailReplaceText(
				fixedPhraseValue.text
				, this.parameter.correspondId
			);

			// 新規メッセージへの設定（※改行コードをJS用に置換）
			this.screenFixedPhrase.replaceVal = replaceVal.replaceAll(
				CommonConst.LINE_FEED
				, CommonConst.LINE_EXCLUSIVE_JS_BREAK_CD
			);

		} catch(Exception e) {
			// エラーメッセージの表示・設定
			this.hasErrorMessage = true;
			CommonUtil.setErrorMessage(e);

			// ロールバック
			Database.rollback(sp);
		}
	}
}