global class googleApiUtilTest2OkHttpRequestMock implements HttpCalloutMock {
    /**
    * @description テストで返すレスポンスを設定する
    * @param req HTTPリクエストが渡される
    * @return GoogleAPI(駅設定)
    */
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{'+
                        '   "geocoded_waypoints" : ['+
                        '      {'+
                        '      },'+
                        '      {'+
                        '      }'+
                        '   ],'+
                        '   "routes" : ['+
                        '      {'+
                        '         "bounds" : {'+
                        '            "northeast" : {'+
                        '            },'+
                        '            "southwest" : {'+
                        '            }'+
                        '         },'+
                        '         "copyrights" : "",'+
                        '         "legs" : ['+
                        '            {'+
                        '               "distance" : {'+
                        '                  "text" : "0.3 km",'+
                        '                  "value" : 286'+
                        '               },'+
                        '               "duration" : {'+
                        '               },'+
                        '               "end_address" : "",'+
                        '               "end_location" : {'+
                        '               },'+
                        '               "start_address" : "",'+
                        '               "start_location" : {'+
                        '               },'+
                        '               "steps" : ['+
                        '                  {'+
                        '                  },'+
                        '                  {'+
                        '                  },'+
                        '                  {'+
                        '                  }'+
                        '               ],'+
                        '               "traffic_speed_entry" : [],'+
                        '               "via_waypoint" : []'+
                        '            }'+
                        '         ],'+
                        '         "overview_polyline" : {'+
                        '            "points" : ""'+
                        '         },'+
                        '         "summary" : "",'+
                        '         "warnings" : ['+
                        '            ""'+
                        '         ],'+
                        '         "waypoint_order" : []'+
                        '      }'+
                        '   ],'+
                        '   "status" : "OK"'+
                        '}'
                        );
        response.setStatusCode(200);
        return response; 
    }
}