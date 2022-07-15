global class googleApiUtilTest3NgHttpRequestMock implements HttpCalloutMock {
    /**
    * @description テストで返すレスポンスを設定する
    * @param req HTTPリクエストが渡される
    * @return GoogleAPI(小中学校設定)
    */
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{'+
                        '   "geocoded_waypoints" : ['+
                        '   ],'+
                        '   "routes" : ['+
                        '   ],'+
                        '   "status" : "OK"'+
                        '}'
                        );
        response.setStatusCode(200);
        return response; 
    }
}