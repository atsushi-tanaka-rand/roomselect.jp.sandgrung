/**
 * 文例集選択
 */
public class GL101001Modal2Controller {

	/** パラメータ */
	public GL101001Modal2ParameterClass parameter {get; set;}

	/** 画面項目 */
	public GL101001Controller.ScreenExampleSentence screenExampleSentence {get; set;} // 文例集情報

	/**
	* ページ描画時処理
	* @return Boolean true:初回以外の描画、false:初回描画
	*/
	public Boolean init {
		get {
			// 初回描画処理
			if (this.parameter.isDrawing) {

				// パラメータの設定
				this.screenExampleSentence	= this.parameter.screenExampleSentence;
				this.parameter.isDrawing	= false;

				return false;
			}

			return true;
		}
	}
}