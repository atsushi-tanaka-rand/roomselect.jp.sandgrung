/**
 * LINE Messaging API関連共通クラス
 */
public with sharing class LineMessagingApiUtil {

	/** LINE送信設定 */
	private static final String LINE_MESSAGING_API_URL			= SystemConfig__c.getInstance().LineMessagingApiUrl__c;
	private static final String LONG_TERM_CHANNEL_ACCESS_TOKEN	= SystemConfig__c.getInstance().LongTermChannelAccessToken__c;

	/** ファイル送信設定値 */
	private static final String LINK_LABEL_DOWNLOAD		= 'ダウンロードする';
	private static final String LINK_LABEL_DISP_FILE	= 'ファイルを表示する';
	private static final String FILE_DOWNLOAD_PARAM		= '?openExternalBrowser=1';

	/** サムネイル画像名 */
	private static final String THUMBNAIL_ICON_TEXT		= 'icon_text.jpg';
	private static final String THUMBNAIL_ICON_CSV		= 'icon_csv.jpg';
	private static final String THUMBNAIL_ICON_PDF		= 'icon_pdf.jpg';
	private static final String THUMBNAIL_ICON_EXCEL	= 'icon_excel.jpg';
	private static final String THUMBNAIL_ICON_PPT		= 'icon_ppt.jpg';
	private static final String THUMBNAIL_ICON_WORD		= 'icon_word.jpg';

	/** 拡張子 */
	private static final List<String> VIDEO_EXTENSION	= getMimeKindExtension('video');
	private static final List<String> IMG_EXTENSION		= getMimeKindExtension('image');

	/** ファイル送信マップ（key:拡張子、value:送信値） */
	private static final Map<String, String[]> SEND_FILE_MAP = new Map<String, String[]>{
		CommonConst.EXTENSION_TXT	=>	new String[]{LINK_LABEL_DOWNLOAD,	FILE_DOWNLOAD_PARAM,		THUMBNAIL_ICON_TEXT},
		CommonConst.EXTENSION_CSV	=>	new String[]{LINK_LABEL_DOWNLOAD,	FILE_DOWNLOAD_PARAM,		THUMBNAIL_ICON_CSV},
		CommonConst.EXTENSION_PDF	=>	new String[]{LINK_LABEL_DISP_FILE,	CommonConst.STRING_EMPTY,	THUMBNAIL_ICON_PDF},
		CommonConst.EXTENSION_XLS	=>	new String[]{LINK_LABEL_DOWNLOAD,	FILE_DOWNLOAD_PARAM,		THUMBNAIL_ICON_EXCEL},
		CommonConst.EXTENSION_XLSX	=>	new String[]{LINK_LABEL_DOWNLOAD,	FILE_DOWNLOAD_PARAM,		THUMBNAIL_ICON_EXCEL},
		CommonConst.EXTENSION_PPT	=>	new String[]{LINK_LABEL_DOWNLOAD,	FILE_DOWNLOAD_PARAM,		THUMBNAIL_ICON_PPT},
		CommonConst.EXTENSION_PPTX	=>	new String[]{LINK_LABEL_DOWNLOAD,	FILE_DOWNLOAD_PARAM,		THUMBNAIL_ICON_PPT},
		CommonConst.EXTENSION_DOC	=>	new String[]{LINK_LABEL_DOWNLOAD,	FILE_DOWNLOAD_PARAM,		THUMBNAIL_ICON_WORD},
		CommonConst.EXTENSION_DOCX	=>	new String[]{LINK_LABEL_DOWNLOAD,	FILE_DOWNLOAD_PARAM,		THUMBNAIL_ICON_WORD}	
	};

	/** ファイル送信マップインデックス */
	public enum SendFileMapIdx {
		LINK_LABEL				// リンクラベル値
		, DOWNLOAD_PARAM		// ダウンロードパラメータ
		, THUMBNAIL_IMG_NAME	// サムネイル画像名
	}

	/**
	 * 動画拡張子の取得
	 * @return List<String> 動画拡張子
	 */
	public static List<String> getVideoExtension() {
		return VIDEO_EXTENSION;
	}

	/**
	 * 画像拡張子の取得
	 * @return List<String> 画像拡張子
	 */
	public static List<String> getImgExtension() {
		return IMG_EXTENSION;
	}

	/**
	 * 拡張子の取得
	 * @param String fileName ファイル名
	 * @return String 拡張子
	 */
	public static String getExtension(String fileName) {

		// 実施チェック
		if (String.isBlank(fileName)) {
			return CommonConst.STRING_EMPTY;
		}

		// ファイルの拡張子の取得
		Integer	extensionIdx	= fileName.lastIndexOf('.');
		String	extension		= fileName.substring(extensionIdx + 1);

		return extension.toLowerCase();
	}

	/**
	 * ファイル名の取得
	 * @param String filePath ファイルパス
	 * @return String ファイル名
	 */
	public static String getFileName(String filePath) {

		// 実施チェック
		if (String.isBlank(filePath)) {
			return CommonConst.STRING_EMPTY;
		}

		// ファイル名の取得
		Integer	fileNameIdx	= filePath.lastIndexOf('/');
		String	fileName	= filePath.substring(fileNameIdx + 1);

		return fileName;
	}

	/**
	 * テキストメッセージの送信
	 * @param String lineUserId		LINE USER ID
	 * @param String textVal		テキストメッセージ
	 * @param String splitBreakCd	改行コードの分割値
	 * @return HttpResponse 送信結果
	 */
	public static HttpResponse sendTextMsg(
		String lineUserId
		, String textMsg
		, String splitBreakCd
	) {

		// JSON用改行コードの文字列の取得
		String jsonTextMsg = getJsonBreakCodeText(textMsg, splitBreakCd);

		// JSON値の取得
		String msgsJson = '{'
						+ '	"type"	:	"text",'
						+ '	"text"	:	"{0}"'
						+ '}';

		msgsJson = CommonUtil.callMessageCreate(msgsJson, jsonTextMsg);

		// LINEメッセージの送信
		return sendLine(lineUserId, msgsJson);
	}

	/**
	 * 画像メッセージの送信
	 * @param String lineUserId			LINE USER ID
	 * @param String imgUrl				画像URL
	 * @param String thumbnailImageUrl	サムネイル画像URL
	 * @return HttpResponse 送信結果
	 */
	public static HttpResponse sendImgMsg(
		String lineUserId
		, String imgUrl
		, String thumbnailImageUrl
	) {
		// S3ファイルの存在チェック
		if(!isExistsS3File(lineUserId, new List<String>{imgUrl, thumbnailImageUrl})) {
			BusinessLogicException ex = new BusinessLogicException();
			ex.addMessage(CommonConst.MSG_COM_E_FILEUPLOAD_CONTAIN);
			throw ex;
		}

		// JSON値の取得
		String msgsJson = '{'
						+ '	"type"					:	"image",'
						+ '	"originalContentUrl"	:	"{0}",'
						+ '	"previewImageUrl"		:	"{1}"'
						+ '}';

		msgsJson = CommonUtil.callMessageCreate(msgsJson, imgUrl, thumbnailImageUrl);

		// LINEメッセージの送信
		return sendLine(lineUserId, msgsJson);
	}

	/**
	 * 動画メッセージの送信
	 * @param String lineUserId			LINE USER ID
	 * @param String videoUrl			動画URL
	 * @param String thumbnailImageUrl	サムネイル画像URL
	 * @return HttpResponse 送信結果
	 */
	public static HttpResponse sendVideoMsg(
		String lineUserId
		, String videoUrl
		, String thumbnailImageUrl
	) {
		// S3ファイルの存在チェック
		if(!isExistsS3File(lineUserId, new List<String>{videoUrl, thumbnailImageUrl})) {
			BusinessLogicException ex = new BusinessLogicException();
			ex.addMessage(CommonConst.MSG_COM_E_FILEUPLOAD_CONTAIN);
			throw ex;
		}

		// JSON値の取得
		String msgsJson = '{'
						+ '	"type"					:	"video",'
						+ '	"originalContentUrl"	:	"{0}",'
						+ '	"previewImageUrl"		:	"{1}"'
						+ '}';

		msgsJson = CommonUtil.callMessageCreate(msgsJson, videoUrl, thumbnailImageUrl);

		// LINEメッセージの送信
		return sendLine(lineUserId, msgsJson);
	}

	/**
	 * ファイルメッセージの送信
	 * @param String lineUserId	LINE USER ID
	 * @param String fileName	ファイル名
	 * @param String fileUrl	ファイルURL
	 * @return HttpResponse 送信結果
	 */
	public static HttpResponse sendFileMsg(String lineUserId,String fileName, String fileUrl) {

		// S3ファイルの存在チェック
		if(!isExistsS3File(lineUserId, new List<String>{fileUrl})) {
			BusinessLogicException ex = new BusinessLogicException();
			ex.addMessage(CommonConst.MSG_COM_E_FILEUPLOAD_CONTAIN);
			throw ex;
		}

		// ファイル情報の取得
		String	 extension		= getExtension(fileName);
		String[] sendFileInfo	= SEND_FILE_MAP.get(extension);

		// パラメータの取得
		String thumbnailImgUrl	= getTemplateIconPath() + sendFileInfo[SendFileMapIdx.THUMBNAIL_IMG_NAME.ordinal()];
		String linkLabel		= sendFileInfo[SendFileMapIdx.LINK_LABEL.ordinal()];
		String s3fileUrl		= fileUrl + sendFileInfo[SendFileMapIdx.DOWNLOAD_PARAM.ordinal()];

		List<String> param = new List<String>{
			thumbnailImgUrl		// サムネイル画像URL
			, fileName			// 送信されたファイル名
			, linkLabel			// リンク用ラベル
			, s3fileUrl			// 格納先のS3ファイルURL
		};

		// JSON値の取得
		String msgsJson = '{'
						+ '	"type": "template",'
						+ '	"altText": "ファイルが送信されました。",'
						+ '	"template": {'
						+ '		"type": "buttons",'
						+ '		"thumbnailImageUrl": "{0}",'
						+ '		"imageAspectRatio": "rectangle",'
						+ '		"imageSize": "contain",'
						+ '		"imageBackgroundColor": "#FFFFFF",'
						+ '		"text": "{1}",'
						+ '		"actions": [{'
						+ '			"type": "uri",'
						+ '			"label": "{2}",'
						+ '			"uri": "{3}"'
						+ '		}]'
						+ '	}'
						+ '}';

		msgsJson = CommonUtil.callMessageCreate(msgsJson, param);

		// LINEメッセージの送信
		return sendLine(lineUserId, msgsJson);
	}

	/**
	 * LINEの送信
	 * @param String lineUserId	LINE USER ID
	 * @param String msgsJson	メッセージ部のJSON値
	 * @return HttpResponse 送信結果
	 */
	private static HttpResponse sendLine(String lineUserId, String msgsJson) {

		BusinessLogicException ex = new BusinessLogicException();

		// LINE送信設定の存在チェック
		if (!isExistsSendLineConfig()) {
			ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_NOT_SET_CONFIG, 'LINEへの接続情報'));
			throw ex;
		}

		// BODY値の取得
		String bodyJson = '{'
						+ '	"to"		:	"{0}",'
						+ '	"messages"	:	[{1}]'
						+ '}';

		bodyJson = CommonUtil.callMessageCreate(bodyJson, lineUserId, msgsJson);

		// リクエスト情報の設定
		// ※指定ログイン情報作成の警告が表示されているが、パッケージ化時の個別設定等の調査が必要な為、放置
		HttpRequest request = new HttpRequest();
		request.setEndpoint(LINE_MESSAGING_API_URL);
		request.setMethod('POST');
		request.setHeader('Content-Type', 'application/json;');
		request.setHeader('Authorization', 'Bearer ' + LONG_TERM_CHANNEL_ACCESS_TOKEN);
		request.setBody(bodyJson);

		// LINEの送信
		Http http = new Http();
		HttpResponse response = http.send(request);

		// 送信エラーチェック
		if (response.getStatusCode() < 200 || response.getStatusCode() > 299) {
			ex.addMessage('LINEの送信に失敗しました。');
			ex.addMessage('【ステータス】:' + response.getStatus());
			ex.addMessage('【ステータスコード】:' + response.getStatusCode());
			ex.addMessage('【レスポンス】:' + response.getBody());
			throw ex;
		}

		return response;
	}

	/**
	 * LINE送信設定の存在チェック
	 * @return Boolean true:存在する、false:存在しない
	 */
	private static Boolean isExistsSendLineConfig() {

		// LINE MessagingAPI URL
		if (String.isBlank(LINE_MESSAGING_API_URL)) {
			return false;
		}

		// 長期チャネルアクセストークン
		if (String.isBlank(LONG_TERM_CHANNEL_ACCESS_TOKEN)) {
			return false;
		}

		return true;
	}

	/**
	 * MIME種別に応じた拡張子の取得
	 * @param String mimeKind MIME種別
	 * @return List<String> MIME種別
	 */
	private static List<String> getMimeKindExtension(String mimeKind) {

		// MIME種別に前方一致した拡張子の取得
		List<String> mimeKindList = new List<String>();
		for (String extension : CommonConst.MIME_MAP.keySet()) {

			if (CommonConst.MIME_MAP.get(extension).indexOf(mimeKind) == 0) {
				mimeKindList.add(extension);
			}
		}

		return mimeKindList;
	}

	/**
	 * テンプレート用アイコンパスの取得
	 * @return String テンプレート用アイコンパス
	 */
	private static String getTemplateIconPath() {
		return AmazonS3Util.getS3LineUrl() + 'TemplateIcon/';
	}

	/**
	 * JSON用改行コードの文字列の取得
	 * @param String text			文字列
	 * @param String splitBreakCd	分割用の改行コード
	 * @return String JSON用改行コードの文字列
	 */
	private static String getJsonBreakCodeText(String text, String splitBreakCd) {

		// JSON用文字列
		String jsonTextMsg = CommonConst.STRING_EMPTY;

		// Apexに設定された改行コードをJSON用に変換
		// ※Stringの置換関数（replace、remove等）はエスケープ後の値に変換される為、使用不可
		String[] breakTextAry = text.split(splitBreakCd);
		for (Integer breakIdx = 0; breakIdx < breakTextAry.size(); breakIdx++) {

			jsonTextMsg += breakTextAry[breakIdx];

			// 最終行以外は改行コードを付与
			if (breakIdx + 1 < breakTextAry.size()) {
				jsonTextMsg += CommonConst.JSON_BREAK_CODE;
			}
		}

		return jsonTextMsg;
	}

	/**
	 * S3ファイルの存在チェック
	 * @param String		lineUserId		LINE USER ID
	 * @param List<String>	filePathList	ファイルパス
	 * @return Boolean true:存在する、false:存在しない
	 */
	private static Boolean isExistsS3File(String lineUserId, List<String> filePathList) {

		String s3Path; 
		for (String filePath : filePathList) {

			// 引数チェック
			if (String.isBlank(filePath)) {
				return false;
			}

			// S3パスの取得
			s3Path = AmazonS3Util.getS3LineDomain() + lineUserId + '/' + getFileName(filePath);

			// ファイルの存在チェック
			if (!AmazonS3Util.isExistsFile(s3Path)) {
				return false;
			}
		}

		return true;
	}
}