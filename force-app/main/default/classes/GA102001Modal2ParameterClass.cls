// 対応履歴画面
public with sharing class GA102001Modal2ParameterClass {
    /** 初回描画フラグ */
    public Boolean isDrawing{ get; set;}
    
    /** 描画実施済みフラグ */
    public Boolean noFirst{ get; set;}

    // /** 店舗区分（False:インサイドセール、True:インサイドセール以外） */
    // public Boolean isShopType { get;set; }                              

    /** 取引先ID */
    public String AccountId { get;set; }

    /** 対応ID */
    public String CorrespondId { get;set; }

    /** 対応明細ID */
    public String CorrespondDetailId { get;set; }

    /** 対応種別フラグ */
    public String CorrespondType { get;set; }

    /** ボタン押下ステータス */
    public String Status { get;set; }

    /** 2021.09.24 No.489 反響一覧登録フラグ */
    public Boolean echoInsertFlg { get;set; }

	// ▼ 2021.11.25 LINE連携対応より、対応種別表示フラグを追加
	public Boolean isDispCorrespondType { get;set; }
	// ▲ 2021.11.25

    //     /** ステータスフラグ */
    // public String Status { get;set; }

	public GA102001Modal10ParameterClass GA102001Paremeter10 { get; set; } // 予約物件条件用パラメータ  //2021.10.08 No.307 対応で追加

    public GA102001Modal2ParameterClass() {
        // 初期化処理
        // selectedShopList = new  List<String>();        
        isDrawing = false;
        noFirst = false;
        echoInsertFlg = false; // 2021.09.24 No.489 反響一覧登録フラグ初期化
		// ▼ 2021.11.25 LINE連携対応より、対応種別表示フラグを追加
		this.isDispCorrespondType = false;
		// ▲ 2021.11.25 
    }
}