global class googleApiUtilTest1NgHttpRequestMock implements HttpCalloutMock {
    /**
    * @description テストで返すレスポンスを設定する
    * @param req HTTPリクエストが渡される
    * @return GoogleAPI(座標設定)　※Bodyが空の場合
    */
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{'+
                        '   "results" : ['+
                        // '      {'+
                        // '      }'+
                        '   ],'+
                        '   "status" : "NG"'+
                        '}'
                        );
        response.setStatusCode(200);
        return response; 
    }
}