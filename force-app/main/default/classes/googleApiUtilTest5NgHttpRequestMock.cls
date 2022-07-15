global class googleApiUtilTest5NgHttpRequestMock implements HttpCalloutMock {
    /**
    * @description テストで返すレスポンスを設定する
    * @param req HTTPリクエストが渡される
    * @return GoogleAPI(周辺施設設定)
    */
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{'+
                        '   "html_attributions" : ['+
                        '   ],'+
                        '   "results" : ['+
                        '   ],'+
                        '   "status" : "OK"'+
                        '}'
                        );
        response.setStatusCode(200);
        return response; 
    }
}