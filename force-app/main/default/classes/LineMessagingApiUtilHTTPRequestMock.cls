/**
 * LINE Messaging API関連共通HTTPRequestモッククラス
 */
@isTest
global with sharing class LineMessagingApiUtilHTTPRequestMock implements HttpCalloutMock {

	/** エラーフラグ */
	public Boolean isRequestErr { get; set; }

	/**
	 * コンストラクタ
	 * @param Boolean isRequestErr リクエストエラー（true:エラー有り、false:エラー無し）
	 */
	public lineMessagingApiUtilHTTPRequestMock(Boolean isRequestErr) {
		this.isRequestErr = isRequestErr;
	}

	/**
	 * レスポンス
	 * @param HTTPRequest request リクエスト
	 * @return HTTPResponse レスポンス
	 */
	global HTTPResponse respond(HTTPRequest request) {

		HttpResponse response = new HttpResponse();
		response.setHeader('Content-Type', 'application/json');
		response.setStatusCode(200);

		// エラー処理チェック
		if (this.isRequestErr) {
			response.setStatusCode(404);
		}

		return response;
	}
}