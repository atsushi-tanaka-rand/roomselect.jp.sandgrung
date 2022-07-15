//Json→Apex取込の為のクラス
//おすすめ物件一覧の情報取得用
//
public class JsonForGetTheta360biz {
    public String user_access_key_id;

    public Integer total_count;
    public Integer response_count;
    public List<tours> tours;

    public class tours{
        public String id;
        public String created_by;
        public String custom_key;
        public String uri;
        public String published;
        public String title;
        public String posted_at;
        public String updated_at;
        public String deleted_at;
        public String view_uri;
        public String custom_view_uri;
        public String embed_code;
        public String custom_embed_code;
        public String note;
    }


    // public JsonForGetTheta360biz (String json) {
    //     System.JSON.deserialize(json, JsonForGetTheta360biz.class);
    //     system.debug(System.JSON.deserialize(json, JsonForGetTheta360biz.class));
    // }
    public static JsonForGetTheta360biz parse(String json) {
		return (JsonForGetTheta360biz) System.JSON.deserialize(json, JsonForGetTheta360biz.class);
	}
}