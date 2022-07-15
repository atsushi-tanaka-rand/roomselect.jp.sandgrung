/**
 * ファイル送信モーダル
 */
public with sharing class GL101001Modal3Controller {

	/** パラメータ */
	public GL101001Modal3ParameterClass parameter {get; set;}

	/** メッセージ格納クラス */
	public Msgs msgs {get; set;}

	/** S3 認証情報 */
	public String s3Credential	{get; set;} // 認証情報
	public String s3Timestamp	{get; set;} // タイムスタンプ
	public String s3Path		{get; set;} // パス

	public Map<String, String> s3SignatureMap	{get; set;} // 署名
	public Map<String, String> s3PolicyMap		{get; set;} // ポリシー
	public Map<String, String> s3ContentTypeMap	{get; set;} // コンテンツタイプ

	public String s3FileStorageDomein	{get; set;} // ファイル格納ドメイン
	public String s3FileStorageURL		{get; set;} // ファイル格納URL（ファイル名は除く

	/** 拡張子情報 */
	public List<String> videoExtension	{get; set;}	// 動画拡張子
	public List<String> imgExtension	{get; set;}	// 画像拡張子

	/** フラグ */
	public Boolean isOpenError {get; set;} // エラーフラグ

	/**
	 * ページ描画時処理
	 * @return Boolean true:初回以外の描画、false:初回描画
	 */
	public Boolean init {
		get {
			if (this.parameter.isDrawing) {
				this.parameter.isDrawing = false;

				try {

					// Apexプロパティの初期化
					this.setInitApexProperty();

					// S3接続情報の設定
					BusinessLogicException ex = this.setS3ConnectionInfo();
					if (ex.hasMessage()) {
						throw ex;
					}

				} catch(Exception ex) {
					// エラーメッセージの表示・設定
					this.isOpenError = true;
					CommonUtil.setErrorMessage(ex);
				}

				return false;
			}
			return true;
		}
	}

	/**
	 * Apexプロパティの初期化
	 */
	private void setInitApexProperty() {

		// メッセージ格納クラス
		msgs = new Msgs();

		// フラグ
		this.isOpenError = false;

		// S3 認証情報
		this.s3Credential			= CommonConst.STRING_EMPTY;
		this.s3Timestamp			= CommonConst.STRING_EMPTY;
		this.s3Path					= CommonConst.STRING_EMPTY;
		this.s3SignatureMap			= new Map<String, String>();
		this.s3PolicyMap			= new Map<String, String>();
		this.s3ContentTypeMap		= CommonConst.MIME_MAP;
		this.s3FileStorageDomein	= CommonConst.STRING_EMPTY;
		this.s3FileStorageURL		= CommonConst.STRING_EMPTY;

		// 拡張子情報
		this.videoExtension	= LineMessagingApiUtil.getVideoExtension();
		this.imgExtension	= LineMessagingApiUtil.getImgExtension();
	}

	/**
	 * Amazon S3の接続情報の設定
	 * @return BusinessLogicException 入力規則用例外クラス
	 */
	private BusinessLogicException setS3ConnectionInfo() {

		BusinessLogicException ex = new BusinessLogicException();

		// S3情報の存在チェック
		if (!this.isExistsS3ConnectionInfo()) {
			ex.addMessage(this.msgs.getNotSetS3Config());
			return ex;
		}

		// S3接続情報
		String region		= AmazonS3Util.getRegion();
		String bucket		= AmazonS3Util.getBucketName();
		String secretKey	= AmazonS3Util.getSecretAccessKey();
		String accessKey	= AmazonS3Util.getAccessKeyId();

		// 日付の取得
		Datetime dSysDate	= Datetime.now();
		String	 sSysDate	= dSysDate.formatGMT('yyyyMMdd');
		this.s3Timestamp	= sSysDate + 'T000000Z';

		// 認証情報の取得
		this.s3Credential = CommonUtil.callMessageCreate(
			'{0}/{1}/{2}/s3/aws4_request',
			accessKey,
			sSysDate,
			region
		);
		
		// MIMEに応じた接続情報の取得
		for (String key : this.s3ContentTypeMap.keySet()) {

			// S3ポリシーの取得
			String base64Policy = this.getBase64S3Policy(
				dSysDate
				, bucket
				, this.s3Credential
				, this.s3Timestamp
				, this.s3ContentTypeMap.get(key)
			);
			this.s3PolicyMap.put(key, base64Policy);

			// 署名値の取得
			Blob	kSecret		= Blob.valueof('AWS4' + secretKey);
			Blob	kDate		= Crypto.generateMac('hmacSHA256', Blob.valueOf(sSysDate), kSecret);
			Blob	kRegion		= Crypto.generateMac('hmacSHA256', Blob.valueOf(region), kDate);
			Blob	kService	= Crypto.generateMac('hmacSHA256', Blob.valueOf('s3'), kRegion);
			Blob	kSigning	= Crypto.generateMac('hmacSHA256', Blob.valueOf('aws4_request'), kService);
			String	signature	= EncodingUtil.convertToHex(Crypto.generateMac('hmacSHA256', Blob.valueof(base64Policy), kSigning));

			this.s3SignatureMap.put(key, signature);
		}

		// S3パスの取得
		this.s3Path = AmazonS3Util.getS3Url();

		// ファイル格納ドメイン
		this.s3FileStorageDomein = AmazonS3Util.getS3LineDomain() + this.parameter.lineId + '/';

		// ファイル格納URL
		this.s3FileStorageURL = this.s3Path + this.s3FileStorageDomein;

		return ex;
	}

	/**
	 * Amazon S3の接続情報の存在チェック
	 * @return true:接続情報有り、false:接続情報無し
	 */
	private Boolean isExistsS3ConnectionInfo() {

		// リージョン
		if (String.isBlank(AmazonS3Util.getRegion())) {
			return false;
		}

		// バケット名
		if (String.isBlank(AmazonS3Util.getBucketName())) {
			return false;
		}

		// シークレットキー
		if (String.isBlank(AmazonS3Util.getSecretAccessKey())) {
			return false;
		}

		// アクセスキー
		if (String.isBlank(AmazonS3Util.getAccessKeyId())) {
			return false;
		}
		
		return true;
	}

	/**
	 * S3ポリシーのBase64値の取得
	 * @param Datetime	sysDate			システム日付
	 * @param String	bucket			バケット
	 * @param String	credential		認証情報スコープ
	 * @param String	signatureDate	署名日付
	 * @param String	contentType		コンテンツタイプ
	 * @return String S3ポリシーのBase64値
	 */
	private String getBase64S3Policy(
		Datetime sysDate
		, String bucket
		, String credential
		, String signatureDate
		, String contentType
	) {

		// 有効期限
		String expiration = sysDate.addDays(1).formatGMT('yyyy-MM-dd') + 'T00:00:00.000Z';

		// ポリシー
		// expiration							有効期限
		// conditions							条件キー
		// bucket								バケット
		// acl									アクセスコントロールリスト
		// x-amz-algorithm						署名用ハッシュアルゴリズム
		// x-amz-credential						認証情報スコープ
		// success_action_status				正常終了時のステータスコード
		// x-amz-date							署名作成用日付
		// starts-with($key)					先頭一致（key）
		// starts-with($Content-Disposition)	先頭一致（ダウンロード方法）
		// starts-with($Content-Type)			先頭一致（コンテンツタイプ）
		String policyBase =
			'{'
			+ '	"expiration": "{0}",'
			+ '	"conditions":['
			+ '		{"bucket"					: "{1}"},'
			+ '		{"acl"						: "public-read"},'
			+ '		{"x-amz-algorithm"			: "AWS4-HMAC-SHA256"},'
			+ '		{"x-amz-credential"			: "{2}"},'
			+ '		{"success_action_status"	: "200"},'
			+ '		{"x-amz-date"				: "{3}"},'
			+ '		["starts-with", "$key"					, ""],'
			+ '		["starts-with", "$Content-Disposition"	, ""],'
			+ '		["starts-with", "$Content-Type"			, "{4}"]'
			+ '	]'
			+ '}';

		// 置換値
		List<String> placeholderList = new List<String> {
			expiration
			, bucket
			, credential
			, signatureDate
			, contentType
		};

		// S3ポリシーの取得
		String polisy = CommonUtil.callMessageCreate(policyBase, placeholderList);
		return EncodingUtil.base64Encode(Blob.valueOf(polisy));
	}

	
	/**
	 * メッセージ格納クラス
	 */
	public class Msgs {

		/** メッセージ */
		private final String DELETE_COMPLETED			= CommonConst.MSG_COM_V_DELETE;
		private final String NO_SELECTED_FILE			= CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_NO_SELECTION, 'ファイル');
		private final String SEND_FILE_CONFIRM			= CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SEND_CONFIRM, 'ファイル');
		private final String ERR_GET_THUMBNAIL			= CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_PROCESS, 'サムネイルの自動作成');
		private final String NOT_SET_S3_CONFIG			= CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_NOT_SET_CONFIG, 'AmazonS3への接続情報');
		private final String ERR_XML_HTTP_REQUEST		= CommonConst.MSG_CON_E_XML_HTTP_REQUEST;
		private final String ERR_FILEUPLOAD_ALL			= CommonConst.MSG_COM_E_FILEUPLOAD_ALL;
		private final String ERR_FILEUPLOAD_CONTAIN		= CommonConst.MSG_COM_E_FILEUPLOAD_CONTAIN;
		private final String CANT_SELECTED_EXTENSION	= CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_CANT_SELECTED_EXTENSION, String.join(new List<String>(CommonConst.MIME_MAP.keySet()), ' / '));

		/** 削除完了 */
		public String getDeleteCompleted() {
			return this.DELETE_COMPLETED;
		}

		/** ファイル未選択 */
		public String getNoSelectedFile() {
			return this.NO_SELECTED_FILE;
		}

		/** ファイル送信確認 */
		public String getSendFileConfirm() {
			return this.SEND_FILE_CONFIRM;
		}

		/** サムネイルの取得失敗 */
		public String getErrGetThumbnail() {
			return this.ERR_GET_THUMBNAIL;
		}

		/** S3設定の未定義 */
		public String getNotSetS3Config() {
			return this.NOT_SET_S3_CONFIG;
		}

		/** XmlHttpRequestエラー */
		public String getErrXmlHttpRequest() {
			return this.ERR_XML_HTTP_REQUEST;
		}

		/** ファイルアップロードエラー（全ファイル） */
		public String getErrFileuploadAll() {
			return this.ERR_FILEUPLOAD_ALL;
		}

		/** ファイルアップロードエラー（一部） */
		public String getErrFileuploadContain() {
			return this.ERR_FILEUPLOAD_CONTAIN;
		}

		/** 選択不可拡張子 */
		public String getErrNotSelectedExtension() {
			return this.CANT_SELECTED_EXTENSION;
		}
	}
}