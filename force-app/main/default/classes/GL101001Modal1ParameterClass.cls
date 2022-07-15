/**
 * 定型文モーダルパラメータクラス
 */
public with sharing class GL101001Modal1ParameterClass {

	/** パラメータ */
	public GL101001Controller.ScreenFixedPhrase screenFixedPhrase {get; set;} // 定型文情報

	public Id		correspondId	{get; set;} // 対応ID
	public Boolean	isDrawing		{get; set;} // 初回描画フラグ
	public Boolean	noFirst			{get; set;} // 描画実施済みフラグ

	/**
	* コンストラクタ
	*/
	public gl101001Modal1ParameterClass() {

		// 初期化
		this.screenFixedPhrase = new GL101001Controller.ScreenFixedPhrase();

		this.correspondId	= null;
		this.isDrawing		= false;
		this.noFirst		= false;
	}
}