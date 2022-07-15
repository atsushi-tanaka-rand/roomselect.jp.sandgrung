global class GK101003TestHttpRequestMock implements HttpCalloutMock {
    /**
    * @description テストで返すレスポンスを設定する
    * @param req HTTPリクエストが渡される
    * @return 認証データ
    */
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        
        response.setHeader('Content-Type', 'application/json');
        // ツアーの情報
        response.setBody(
                        '{'+
                        '"user_access_key_id": "9TK1PJ8JDWYYWGZHTB9D", ' + 
                        '"total_count": "1000",'+
                        '"response_count": "2",'+
                        '"tours": ['+
                        '{'+
                            '"id": "BjR",'+
                            '"created_by": "1r0i1776ba",'+
                            '"custom_key": "T40000163",'+
                            '"uri": "https://api.theta360.biz/tours/BjR",'+
                            '"published": "true",'+
                            '"title": "ツアータイトル１",'+
                            '"posted_at": "2015-01-01T00:00:00.000Z",'+
                            '"updated_at": "2015-01-01T00:00:00.000Z",'+
                            '"deleted_at": "",'+
                            '"view_uri": "https://r81572704.theta360.biz/t/aaaaaaa-1856-11eb-85a7-0a60eb835eb0-1",'+
                            '"custom_view_uri": "https://subdomain.theta360.biz/t/T40000163?custom_key=true",'+
                            '"embed_code": "<blockquote data-width=\\\"958\\\" data-height=\\\"478\\\" class=\\\"ricoh-theta-tour-image\\\" ><a href=\\\"https://subdomain.theta360.biz/t/8a096c0a-47bd-11e5-9a21-0a314a6fbcfa-1\\\"></a></blockquote><script async src=\\\"https://subdomain.theta360.biz/t_widgets.js\\\" charset=\\\"utf-8\\\"></script>",'+
                            '"custom_embed_code": "<blockquote data-width=\\\"958\\\" data-height=\\\"478\\\" class=\\\"ricoh-theta-tour-image\\\" ><a href=\\\"https://subdomain.theta360.biz/t/T40000163?custom_key=true\\\"></a></blockquote><script async src=\\\"https://subdomain.theta360.biz/t_widgets.js\\\" charset=\\\"utf-8\\\"></script>",'+
                            '"note": "物件番号A0000056",'+
                            '"location": {'+
                            '"address": "XX県XX市XX町１－１　XXビルXX号室",'+
                            '"geometry": {'+
                                '"latitude": "12.12345678",'+
                                '"longitude": "123.12345678"'+
                            '}'+
                            '},'+
                            '"scenes": ['+
                            '{'+
                                '"sphere_id": "AiQ",'+
                                '"title": "エントランス",'+
                                '"first_view": {'+
                                '"hlookat": "90.12345",'+
                                '"vlookat": "45.12345",'+
                                '"fov": "55.12345"'+
                                '},'+
                                '"telops": ['+
                                '{'+
                                    '"text": "sample telop"'+
                                '}'+
                                '],'+
                                '"annotations": ['+
                                '{'+
                                    '"hlookat": "10.0",'+
                                    '"vlookat": "20.0",'+
                                    '"plane_id": "555",'+
                                    '"text": "あああ"'+
                                '}'+
                                '],'+
                                '"links": ['+
                                '{'+
                                    '"hlookat": "90.12345",'+
                                    '"vlookat": "45.12345",'+
                                    '"destination": {'+
                                    '"sphere_id": "2"'+
                                    '}'+
                                '}'+
                                '],'+
                                '"children": ['+
                                '{'+
                                    '"sphere_id": "123",'+
                                    '"title": "リビング家具入り",'+
                                    '"telops": ['+
                                    '{'+
                                        '"text": "sample telop"'+
                                    '}'+
                                    '],'+
                                    '"annotations": ['+
                                    '{'+
                                        '"hlookat": "10.0",'+
                                        '"vlookat": "20.0",'+
                                        '"plane_id": "555",'+
                                        '"text": "あああ"'+
                                    '}'+
                                    ']'+
                                '}'+
                                ']'+
                            '}'+
                            '],'+
                            '"maps": ['+
                            '{'+
                                '"plane_id": "333",'+
                                '"markers": ['+
                                '{'+
                                    '"sphere_id": "333",'+
                                    '"x": "0.5",'+
                                    '"y": "0.8",'+
                                    '"radar": {'+
                                    '"direction": "180.0"'+
                                    '}'+
                                '}'+
                                ']'+
                            '}'+
                            '],'+
                            '"bottom": {'+
                            '"type": "playersetting",'+
                            '"plane_id": "444"'+
                            '}'+
                        '}'+
                        ']'+
                    '}'
        );         
        response.setStatusCode(200);
        return response; 
    }
}