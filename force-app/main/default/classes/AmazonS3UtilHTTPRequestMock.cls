@isTest
global class AmazonS3UtilHTTPRequestMock implements HttpCalloutMock {

    public Boolean errorFlg { get; set; }
    /**
    * コンストラクタ
    * @param errFlg エラー発生フラグ
    *
    */
    public AmazonS3UtilHTTPRequestMock(Boolean errFlg) {
    this.errorFlg = errFlg;
}

    /**
    * テストで返すレスポンスを設定する
    * @param req HTTPリクエスト
    * @return テストデータ
    */
    global HTTPResponse respond(HTTPRequest req) {
        // エラーフラグがtrueだった場合は通信エラーを投げる
        if (this.errorFlg) {
            throw new System.CalloutException('通信エラー');
        }

        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);//成功のステータスを返す
        return res;
    }
}