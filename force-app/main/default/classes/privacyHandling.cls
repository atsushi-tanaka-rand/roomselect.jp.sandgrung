/**
 * 郵便番号検索・住所検索モーダル画面コントローラ
 */
public class privacyHandling {

    //Public変数
    public String addressSignature  { get; set; }   //署名用住所
    public String phonSignature  { get; set; }      //署名用電話番号
    public String faxSignature  { get; set; }       //署名用FAX
    public String emailSignature  { get; set; }     //署名用Email
    public String staffSignature  { get; set; }     //署名用担当者
    public FixedPhrase__c fixPhrase   { get; set; }       // 定型文（個人情報の取扱方針）
    public String formLogoUrl { get{ return SystemConfig__c.getInstance().FormLogoPath__c; } }      // 帳票ロゴパス

    public privacyHandling(){
        //署名用項目
        this.addressSignature  = SystemConfig__c.getInstance().AddressSignature__c;   //署名用住所
        this.phonSignature     = SystemConfig__c.getInstance().PhoneSignature__c;  //署名用電話番号
        this.faxSignature      = SystemConfig__c.getInstance().FaxSignature__c;  //署名用FAX
        this.staffSignature    = SystemConfig__c.getInstance().StaffSignature__c;  //署名用担当者

        // 定型文（個人情報の取扱方針）
        List<FixedPhrase__c> fixedPhraseList= [
            SELECT PersonalInformation__c 
            FROM FixedPhrase__c 
            WHERE UsageScreen__c =: CommonConst.FIXEDPHRASE_USAGESCREEN_POLICY_OF_PERSONAL_INFOMATION 
            LIMIT 1
        ];
        if (fixedPhraseList.size() > 0) {
            this.fixPhrase = fixedPhraseList[0];
        } else {
            this.fixPhrase = new FixedPhrase__c();
        }
        
    }

}