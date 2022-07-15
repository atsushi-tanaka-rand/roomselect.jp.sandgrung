//Json→Apex取込の為のクラス
//自社ポータルからのjsonメール取得で使用
//

public class JsonForPortalMail {

	public List<Property> Property;
	public List<Customer> Customer;

    public class Customer {
        public String  MemberId;                        // 会員ID
        public String  InquiryDateTime;                 // お問合せ日時
        public String  MailType;                        // メール種別
        public String  InquiryType;                     // お問合せ区分
		public String  textOther;                       // その他の問合せ内容
		public String  textOther2;                      // その他、お問い合わせ
        public String  Shop;                            // 来店店舗
        public String  VisitDateTime;                   // 来店希望日時第１希望
        public String  VisitDateTime2;                  // 来店希望日時第２希望
        public String  LastName;                        // 姓
        public String  FirstName;                       // 名
        public String  LastName_kana;                   // セイ
        public String  FirstName_kana;                  // メイ
        public String  Email;                           // メールアドレス
        public String  Phone;                           // 電話番号
        public String  BirthDay;                        // 生年月日 問合せNo0536で追加
        public String  Zip;                             // 郵便番号
        public String  State;                           // 都道府県
        public String  City;                            // 市区町村
        public String  Street;                          // 番地・建物
        public String  ContactMeans;                    // 希望の連絡方法
        public String  InquiryContent;                  // 希望の連絡方法
        public String  DesireArea;                      // エリア
        public String  RentFee;                         // 希望賃料下限
        public String  RentFeeUpper;                    // 希望賃料上限
		public List<String>  RoomPlan;                  // 間取り
        public List<String>  HomeMovingReason;          // 引越し理由
        public String  HomeMovingReasonDissatisfaction; // 現状不満理由
        public String  OccupancyDesiredSeason;          // 引越し時期
        public String  LivePeople;                      // 入居人数
		// ▼ 2021.12.10 LINE連携対応より、追加
		public String	lineReceiveEvent;				// LINE受信イベント
		public String	lineId;							// LINE ID
		public String	lineName;						// LINE名
		public String	lineMessageType;				// LINEメッセージ種別
		public String	lineMessage;					// LINEメッセージ
		public String	lineFileName;					// LINEファイル名
		public String	lineFileUrl;					// LINEファイルURL
		public String	lineThumbnailName;				// LINEサムネイル名
		public String	lineThumbnailUrl;				// LINEサムネイルURL
		public String	lineSendReceiveTime;			// LINE送信受信時刻
		// ▲ 2021.12.10
    }
	

	public class Property {
		public String PropertyCode;
	}

	
	public static JsonForPortalMail parse(String json) {
		return (JsonForPortalMail) System.JSON.deserialize(json, JsonForPortalMail.class);
	}
}