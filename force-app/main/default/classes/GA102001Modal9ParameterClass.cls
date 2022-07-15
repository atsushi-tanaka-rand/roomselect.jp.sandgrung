//物件検索モーダル
public with sharing class GA102001Modal9ParameterClass {
	/** 初回描画フラグ */
	public Boolean isDrawing{ get; set;}

	/** 描画実施済みフラグ */
	public Boolean noFirst{ get; set;}

	/** お客様物件条件選択リスト */
	public List<Selectoption> spcSelectList{ get; set;}
	public String spcSelect{ get; set;}
	
	public GA102001Modal9ParameterClass() {
		// 初期化処理
		isDrawing = false;
		noFirst = false;
	}
}