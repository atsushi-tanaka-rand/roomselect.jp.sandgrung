global class googleApiUtilTest7OK2HttpRequestMock implements HttpCalloutMock {
    /**
    * @description テストで返すレスポンスを設定する
    * @param req HTTPリクエストが渡される
    * @return GoogleAPI(周辺施設設定)
    */
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{'+
                        '   "html_attributions" : [],'+
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
                        '   "next_page_token" : "CrQCJAEAAFp-goO5_oizO0vcvNGDryLJl7kvAdDBGcbFI6nvCfEECSDj2kt5Vn023gT-aQ5p81sY1YA4Fv7djlrReDPZwm60AYz048aDRPvbh4jUGHB9tyHq9qTbKB13189E4-veDQG0yY4Y7X7Ji7t2sT4LmwSfzV62s1UUMVOYiKXAlG7VMaO3AHOepH9BChW2nChKvuAmm5xehWGfiDho24euKUyuGiEMeXz3hmQ6e7LB1ea2GEq5Yw4xLwSGAWBB2GmQ4mbfpX1Z2O2Q2gFYFiZtPX0teNfr0ZvB49JvgGkzzMkXCjBv0AzqK8OxjeyprjaCjLdP595NY4wO9jCkyPV53xGRBDPFABoFeMy8p8Qbs-mlcBP87qPbkqSiLFG8VqSCje0DqbsaCYJXaUX_oXa-IvMSEPMCNj0HixdNx83sRgVqKDcaFPwEDTTcLd2dniSj4Xz08cM7gmpT",'+
                        '   "results" : ['+
                        '      {'+
                        '         "geometry" : {'+
                        '            "location" : {'+
                        '               "lat" : 40.001,'+
                        '               "lng" : 146.001'+
                        '            }'+
                        '         },'+
                        '         "id" : "23258a68c37fc9c309ad2853625afa316bcc402c",'+
                        '         "name" : "周辺施設１",'+
                        '         "photos" : ['+
                        '         ],'+
                        '         "place_id" : "testPlaceId",'+
                        '         "plus_code" : {'+
                        '         }'+
                        '      },'+
                        //'   ],'+
                        '      {'+
                        '         "geometry" : {'+
                        '            "location" : {'+
                        '               "lat" : 35.005,'+
                        '               "lng" : 136.005'+
                        '            }'+
                        '         },'+
                        '         "id" : "23258a68c37fc9c309ad2853625afa316bcc402e",'+
                        '         "name" : "周辺施設２",'+
                        '         "photos" : ['+
                        '         ],'+
                        '         "place_id" : "testPlaceId2",'+
                        '         "plus_code" : {'+
                        '         }'+
                        '      },'+
                        '      {'+
                        '         "geometry" : {'+
                        '            "location" : {'+
                        '               "lat" : 35.005,'+
                        '               "lng" : 136.005'+
                        '            }'+
                        '         },'+
                        '         "id" : "23258a68c37fc9c309ad2853625afa316bcc402f",'+
                        '         "name" : "周辺施設３",'+
                        '         "photos" : ['+
                        '         ],'+
                        '         "place_id" : "testPlaceId3",'+
                        '         "plus_code" : {'+
                        '         }'+
                        '      }'+
                       '    ],'+
                        '   "status" : "OK"'+
                        '}'
                        );
        response.setStatusCode(200);
        return response; 
    }
}