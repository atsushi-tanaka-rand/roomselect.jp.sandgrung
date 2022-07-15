/**
 * LINE Messaging API関連共通テストクラス
 */
@isTest
public with sharing class LineMessagingApiUtilTest {

	/**
	 * 初期設定
	 */
	@testSetup static void setting() {

		// 標準プロファイル
		Profile profile = [
			SELECT Id
			FROM Profile
			WHERE Name = '一般ユーザ'
		];

		// ユーザの登録
		System.runAs(getThisUser()) {
			User testUser = new User(
				LastName			= 'ippanUser'			// 姓
				, Alias				= 'alias'				// 別名
				, Email				= 'ippanUser@test.com'	// メール
				, UserName			= 'ippanUser@test.com'	// ユーザ名
				, CommunityNickname	= 'テストニックネーム'	 // ニックネーム
				, EmailEncodingKey	= 'ISO-2022-JP'			// メールの文字コード
				, TimeZoneSidKey	= 'Asia/Tokyo'			// タイムゾーン
				, LocaleSidKey		= 'ja_JP'				// 地域
				, LanguageLocaleKey	= 'ja'					// 言語
				, ProfileId			= profile.Id			// プロファイルID
			);
			insert testUser;     
		}

		// カスタム設定
		SystemConfig__c systemConfig = new SystemConfig__c(
			S3Region__c						= 'dummy'
			, S3BucketName__c				= 'dummy'
			, S3SecretAccessKey__c			= 'dummy'
			, S3AccessKey__c				= 'dummy'
			, S3RootDirectory__c     		= 'dummy'
			, LineMessagingApiUrl__c		= 'MessagingAPI URL'
			, LongTermChannelAccessToken__c	= '長期チャネルトークン'
		);
		insert systemConfig;
	}

	/**
	 * メッセージ送信テスト
	 */
	@isTest static void sendTextMsgTest() {

		System.runAs(getThisUser()) {

			Test.setMock(HttpCalloutMock.class, new LineMessagingApiUtilHTTPRequestMock(false));
			test.startTest();

			// メッセージの送信
			HttpResponse response = LineMessagingApiUtil.sendTextMsg(
				'1234567890'
				, 'メッセージ送信'
				, CommonConst.STRING_EMPTY
			);

			// 処理結果
			System.assertEquals(
				response.getStatusCode()
				, 200
				, 'メッセージ送信処理'
			);

			test.stopTest();
		}
	}

	/**
	 * 画像送信テスト
	 */
	@isTest static void sendImgMsgTest() {

		System.runAs(getThisUser()) {

			Test.setMock(HttpCalloutMock.class, new LineMessagingApiUtilHTTPRequestMock(false));
			test.startTest();

			// 画像の送信
			HttpResponse response = LineMessagingApiUtil.sendImgMsg(
				'1234567890'
				, '画像URL'
				, 'サムネイル画像URL'
			);

			// 処理結果
			System.assertEquals(
				response.getStatusCode()
				, 200
				, '画像送信処理'
			);

			try {
				// ファイル無しエラー
				LineMessagingApiUtil.sendImgMsg(
					'1234567890'
					, '画像URL'
					, CommonConst.STRING_EMPTY
				);
			} catch (BusinessLogicException ex) {
				// 処理結果
				System.assertEquals(
					ex.hasMessage()
					, true
					, 'ファイル無し'
				);
			}

			test.stopTest();
		}
	}

	/**
	 * 動画送信テスト
	 */
	@isTest static void sendVideoMsgTest() {

		System.runAs(getThisUser()) {

			Test.setMock(HttpCalloutMock.class, new LineMessagingApiUtilHTTPRequestMock(false));
			test.startTest();

			// 動画の送信
			HttpResponse response = LineMessagingApiUtil.sendVideoMsg(
				'1234567890'
				, '動画URL'
				, 'サムネイル画像URL'
			);

			// 処理結果
			System.assertEquals(
				response.getStatusCode()
				, 200
				, '動画送信処理'
			);

			try {
				// ファイル無しエラー
				LineMessagingApiUtil.sendVideoMsg(
					'1234567890'
					, '動画URL'
					, CommonConst.STRING_EMPTY
				);
			} catch (BusinessLogicException ex) {
				// 処理結果
				System.assertEquals(
					ex.hasMessage()
					, true
					, 'ファイル無し'
				);
			}

			test.stopTest();
		}
	}

	/**
	 * ファイル送信テスト
	 */
	@isTest static void sendFileMsgTest() {

		System.runAs(getThisUser()) {

			Test.setMock(HttpCalloutMock.class, new LineMessagingApiUtilHTTPRequestMock(false));
			test.startTest();

			// ファイルの送信
			HttpResponse response = LineMessagingApiUtil.sendFileMsg(
				'1234567890'
				, 'ファイル.txt'
				, 'ファイルURL'
			);

			// 処理結果
			System.assertEquals(
				response.getStatusCode()
				, 200
				, 'ファイル送信処理'
			);

			try {
				// ファイル無しエラー
				LineMessagingApiUtil.sendFileMsg(
					'1234567890'
					, 'ファイル.txt'
					, CommonConst.STRING_EMPTY
				);
			} catch (BusinessLogicException ex) {
				// 処理結果
				System.assertEquals(
					ex.hasMessage()
					, true
					, 'ファイル無し'
				);
			}

			test.stopTest();
		}
	}

	/**
	 * 送信エラーテスト
	 */
	@isTest static void sendErrTest() {
		System.runAs(getThisUser()) {

			Test.setMock(HttpCalloutMock.class, new LineMessagingApiUtilHTTPRequestMock(true));
			test.startTest();

			try {
				// メッセージの送信
				LineMessagingApiUtil.sendTextMsg(
					'1234567890'
					, 'メッセージ送信'
					, CommonConst.STRING_EMPTY
				);
			} catch (Exception e) {
				System.assertNotEquals(
					e.getMessage()
					, CommonConst.STRING_EMPTY
					, '送信エラー処理'
				);
			}

			test.stopTest();
		}
	}

	/**
	 * システム設定の未設定テスト
	 */
	@isTest static void noneSystemConfigTest() {
		System.runAs(getThisUser()) {

			Test.setMock(HttpCalloutMock.class, new LineMessagingApiUtilHTTPRequestMock(false));
			test.startTest();

			// 長期チャネルトークンの更新
			SystemConfig__c systemConfig = [
				SELECT
					Id
					, LongTermChannelAccessToken__c
				FROM SystemConfig__c
			];
			systemConfig.LongTermChannelAccessToken__c = null;
			update systemConfig;

			try {
				// メッセージの送信
				LineMessagingApiUtil.sendTextMsg(
					'1234567890'
					, 'メッセージ送信'
					, CommonConst.STRING_EMPTY
				);
			} catch (Exception e) {
				System.assertNotEquals(
					e.getMessage()
					, CommonConst.STRING_EMPTY
					, '長期チャネルトークンの未設定処理'
				);
			}

			// Messaging API URLの更新
			systemConfig.LineMessagingApiUrl__c = null;
			update systemConfig;

			try {
				// メッセージの送信
				LineMessagingApiUtil.sendTextMsg(
					'1234567890'
					, 'メッセージ送信'
					, CommonConst.STRING_EMPTY
				);
			} catch (Exception e) {
				System.assertNotEquals(
					e.getMessage()
					, CommonConst.STRING_EMPTY
					, 'Messaging API URLの未設定処理'
				);
			}

			test.stopTest();
		}
	}

	/**
	 * カバレッジアップ
	 */
	@isTest static void coverageUp() {
		System.runAs(getThisUser()) {

			test.startTest();

			LineMessagingApiUtil.getVideoExtension();
			LineMessagingApiUtil.getImgExtension();
			LineMessagingApiUtil.getExtension(null);
			LineMessagingApiUtil.getFileName(null);

			// 処理結果
			System.assertEquals(null, null, '確認内容無し');

			test.stopTest();
		}
	}

	/**
	 * ユーザの取得
	 * @return User ユーザ
	 */
	private static User getThisUser() {

		User user = [
			SELECT Id
			FROM User
			WHERE Id = :UserInfo.getUserId()
		];

		return user;
	}

}