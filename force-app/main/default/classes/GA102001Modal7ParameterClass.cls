public with sharing class GA102001Modal7ParameterClass {
    /** 初回描画フラグ */
    public Boolean isDrawing{ get; set;}

    /** 描画実施済みフラグ */
    public Boolean noFirst{ get; set;}

    /** 取引先ID */
    public Id accountId { get;set; }

    /** 対応 */
    public Correspond__c correspond { get;set; }

    //取引先        
    /** 紹介メール追客開始日時 */
    public Datetime introMailInfoFirstSendDatetime{ get;set; }
    
    //紹介メール情報
    /** Id */
    public Id introMailInfoId { get;set; }

    /** SystemModStamp */
    public Datetime introMailInfoSystemModStamp { get;set; }
	// ▼ 2021.11.30 LINE連携対応より、送信区分とLINE会員を追加
	public Boolean	isSendLine		{get; set;}
	public Id		lineMemberId	{get; set;}
	// ▲ 2021.11.30

    public GA102001Modal7ParameterClass() {
        // 初期化処理    
        accountId = null;
        correspond = new Correspond__c();
        introMailInfoFirstSendDatetime = null;
        introMailInfoId = null;
        introMailInfoSystemModStamp = null;
        isDrawing = false;
        noFirst = false;
		// ▼ 2021.11.30 LINE連携対応より、送信区分とLINE会員を追加
		this.isSendLine 	= false;
		this.lineMemberId	= null;
		// ▲ 2021.11.30
    }
}