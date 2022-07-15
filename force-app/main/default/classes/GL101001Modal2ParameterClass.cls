/**
 * 文例集モーダルパラメータクラス
 */
public with sharing class GL101001Modal2ParameterClass {

	/** パラメータ */
	public GL101001Controller.ScreenExampleSentence screenExampleSentence {get; set;} // 文例集情報

	public Boolean isDrawing	{get; set;} // 初回描画フラグ
	public Boolean noFirst		{get; set;} // 描画実施済みフラグ

	/**
	* コンストラクタ
	*/
	public gl101001Modal2ParameterClass() {

		// 初期化
		this.screenExampleSentence = new GL101001Controller.ScreenExampleSentence();
		this.isDrawing	= false;
		this.noFirst	= false;
	}
}