//Json→Apex取込の為のクラス
//周辺情報取得で使用
//GoogleApi（距離取得）用
public class JsonForGetDistance {

    public List<Geocoded_waypoints> geocoded_waypoints;
	public List<Routes> routes;
	public String status;

    public class Geocoded_waypoints {
		public String geocoder_status;
		public String place_id;
		public List<String> types;
	}


    public class Routes {
        public Bounds bounds;
        public String copyrights;
        public List<Legs> legs;
        public Polyline overview_polyline;
        public String summary;
        public List<String> warnings;
        public List<Traffic_speed_entry> waypoint_order;
	}


	public class Steps {
		public Distance distance;
		public Distance duration;
		public Northeast end_location;
		public String html_instructions;
		public Polyline polyline;
		public Northeast start_location;
		public String travel_mode;
		public String maneuver;
	}

	public class Traffic_speed_entry {
	}

	public class Legs {
		public Distance distance;
		public Distance duration;
		public String end_address;
		public Northeast end_location;
		public String start_address;
		public Northeast start_location;
		public List<Steps> steps;
		public List<Traffic_speed_entry> traffic_speed_entry;
		public List<Traffic_speed_entry> via_waypoint;
	}



	public class Bounds {
		public Northeast northeast;
		public Northeast southwest;
	}

	public class Polyline {
		public String points;
	}



	public class Distance {
		public String text;
		public Integer value;
	}

	public class Northeast {
		public Double lat;
		public Double lng;
	}

	
	public static JsonForGetDistance parse(String json) {
		return (JsonForGetDistance) System.JSON.deserialize(json, JsonForGetDistance.class);
	}
}