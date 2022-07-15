//Json→Apex取込の為のクラス
//周辺情報取得で使用
//GoogleApi（周辺情報取得）用
public class JsonForGetSurroundingFacilities {
	public class Geometry {
		public Location location;
		public Viewport viewport;
	}

	public class Photos {
		public Integer height;
		public List<String> html_attributions;
		public String photo_reference;
		public Integer width;
	}

	public class Plus_code {
		public String compound_code;
		public String global_code;
	}

	public List<Html_attributions> html_attributions;
	public String next_page_token;
	public List<Results> results;
	public String status;

	public class Results {
		public Geometry geometry;
		public String icon;
		public String id;
		public String name;
		public Opening_hours opening_hours;
		public List<Photos> photos;
		public String place_id;
		public Plus_code plus_code;
		public Double rating;
		public String reference;
		public String scope;
		public List<String> types;
		public Integer user_ratings_total;
		public String vicinity;
	}

	public class Opening_hours {
		public Boolean open_now;
	}

	public class Viewport {
		public Location northeast;
		public Location southwest;
	}

	public class Html_attributions {
	}

	public class Location {
		public Double lat;
		public Double lng;
	}

	
	public static JsonForGetSurroundingFacilities parse(String json) {
		return (JsonForGetSurroundingFacilities) System.JSON.deserialize(json, JsonForGetSurroundingFacilities.class);
	}
}