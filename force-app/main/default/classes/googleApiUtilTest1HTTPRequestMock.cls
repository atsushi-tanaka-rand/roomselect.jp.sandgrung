global class googleApiUtilTest1HTTPRequestMock implements HttpCalloutMock {
    /**
    * @description テストで返すレスポンスを設定する
    * @param req HTTPリクエストが渡される
    * @return GoogleAPI(座標設定)
    */
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{'+
                        '   "results" : ['+
                        '      {'+
                        '         "address_components" : ['+
                        '            {'+
                        '               "long_name" : "１３",'+
                        '               "short_name" : "１３",'+
                        '               "types" : [ "premise" ]'+
                        '            },'+
                        '            {'+
                        '               "long_name" : "３",'+
                        '               "short_name" : "３",'+
                        '               "types" : [ "political", "sublocality", "sublocality_level_4" ]'+
                        '            },'+
                        '            {'+
                        '               "long_name" : "２丁目",'+
                        '               "short_name" : "２丁目",'+
                        '               "types" : [ "political", "sublocality", "sublocality_level_3" ]'+
                        '            },'+
                        '            {'+
                        '               "long_name" : "安土町",'+
                        '               "short_name" : "安土町",'+
                        '               "types" : [ "political", "sublocality", "sublocality_level_2" ]'+
                        '            },'+
                        '            {'+
                        '               "long_name" : "中央区",'+
                        '               "short_name" : "中央区",'+
                        '               "types" : [ "political", "sublocality", "sublocality_level_1" ]'+
                        '            },'+
                        '            {'+
                        '               "long_name" : "大阪市",'+
                        '               "short_name" : "大阪市",'+
                        '               "types" : [ "locality", "political" ]'+
                        '            },'+
                        '            {'+
                        '               "long_name" : "大阪府",'+
                        '               "short_name" : "大阪府",'+
                        '               "types" : [ "administrative_area_level_1", "political" ]'+
                        '            },'+
                        '            {'+
                        '               "long_name" : "日本",'+
                        '               "short_name" : "JP",'+
                        '               "types" : [ "country", "political" ]'+
                        '            },'+
                        '            {'+
                        '               "long_name" : "541-0052",'+
                        '               "short_name" : "541-0052",'+
                        '               "types" : [ "postal_code" ]'+
                        '            }'+
                        '         ],'+
                        '         "formatted_address" : "日本、〒541-0052 大阪府大阪市中央区安土町２丁目３?１３",'+
                        '         "geometry" : {'+
                        '            "location" : {'+
                        '               "lat" : 111.222,'+
                        '               "lng" : 33.4444'+
                        '            },'+
                        '            "location_type" : "ROOFTOP",'+
                        '            "viewport" : {'+
                        '               "northeast" : {'+
                        '                  "lat" : 34.68547738029149,'+
                        '                  "lng" : 135.5063746802915'+
                        '               },'+
                        '               "southwest" : {'+
                        '                  "lat" : 34.6827794197085,'+
                        '                  "lng" : 135.5036767197085'+
                        '               }'+
                        '            }'+
                        '         },'+
                        '         "place_id" : "ChIJ3bELox_nAGARHsyc1skIEro",'+
                        '         "plus_code" : {'+
                        '            "compound_code" : "MGM4+M2 日本、大阪府 大阪市",'+
                        '            "global_code" : "8Q6QMGM4+M2"'+
                        '         },'+
                        '         "types" : [ "street_address" ]'+
                        '      }'+
                        '   ],'+
                        '   "status" : "OK"'+
                        '}'
                        );
        response.setStatusCode(200);
        return response; 
    }
}