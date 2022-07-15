//予約物件条件モーダル
public with sharing class GA102001Modal10ParameterClass {
	/** 初回描画フラグ */
	public Boolean isDrawing{ get; set;}

	/** 描画実施済みフラグ */
	public Boolean noFirst{ get; set;}

	/** お客様物件条件名リスト */
	public List<String> spcNameList{ get; set;}

	/** お客様物件条件Idリスト */
	public List<Id> spcIdList{ get; set;}

	/** 予約物件条件リスト */
	public List<Boolean> spcReservedList{ get; set;}
	public List<Boolean> befSpcReservedList{ get; set;}

	/** お客様物件条件Idリスト全チェックフラグ */
	public Boolean allSpcReserved{ get; set;}

	/** お客様物件取引先フラグリスト */
	public List<Boolean> spcAccountFlgList{ get; set;}

	/** お客様物件条件インデックスリスト */
	public List<Integer> spcIndexList{ get; set;}

	/** アクセス日時 */
	public Datetime openModalDate{ get; set;}

	public GA102001Modal10ParameterClass() {
		// 初期化処理
		isDrawing = false;
		noFirst = false;
	}
}