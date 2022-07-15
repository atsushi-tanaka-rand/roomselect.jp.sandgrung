/**
 * ファイル送信
 */
public with sharing class GL101001Modal3ParameterClass {

	/** パラメータ */
	public Boolean		isDrawing		{get; set;} // 初回描画フラグ
	public Boolean		noFirst			{get; set;} // 描画実施済みフラグ
	public String		lineId			{get; set;} // LINE ID
	public String		message			{get; set;} // メッセージ
	public String		fileName		{get; set;} // ファイル名
	public String		filePath		{get; set;} // ファイルパス
	public String		thumbnailName	{get; set;} // サムネイル名
	public String		thumbnailPath	{get; set;} // サムネイルパス

	/**
	 * コンストラクタ
	 */
	public Gl101001Modal3ParameterClass() {

		// 初期化
		this.isDrawing		= false;
		this.noFirst		= false;
		this.lineId			= CommonConst.STRING_EMPTY;
		this.message		= CommonConst.STRING_EMPTY;
		this.fileName		= CommonConst.STRING_EMPTY;
		this.filePath		= CommonConst.STRING_EMPTY;
		this.thumbnailName	= CommonConst.STRING_EMPTY;
		this.thumbnailPath	= CommonConst.STRING_EMPTY;
	}
}