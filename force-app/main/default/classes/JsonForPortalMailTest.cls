//Json→Apex取込の為のクラス
//自社ポータルからのjsonメール取得で使用
//テストクラス

@IsTest
public class JsonForPortalMailTest {
	
	static testMethod void testParse() {
		String json = '{ \"Property\":['+
		'  {\"PropertyCode\":\"506386\"},'+
		'  {\"PropertyCode\":\"506387\"},'+
		'  {\"PropertyCode\":\"506388\"} ],'+
		'\"Customer\":[  {'+
		'      \"MemberId\":\"12345678\",'+
		'      \"InquiryDateTime\":\"2020/07/01 00:00:00\",'+
		'      \"MailType\":\"反響\",'+
		'      \"InquiryType\" : \"最新の空室状況を知りたい\",'+
		'      \"textOther\" : \"その他\",'+
		'      \"Shop\":\"\",'+
		'      \"VisitDateTime\":\"\",'+
		'      \"VisitDateTime2\":\"\",'+
		'      \"LastName\":\"不動産\",'+
		'      \"FirstName\":\"花子\",'+
		'      \"LastName_kana\":\"フドウサン\",'+
		'      \"FirstName_kana\":\"ハナコ\",'+
		'      \"Email\":\"hanako.hudousan@rand.co.jp\",'+
		'      \"Phone\":\"000-0000-0000\",'+
		'      \"BirthDay" : "2000/01/01",'+	// 問合せNo0536で追加
		'      \"Zip\":\"460-0000\",'+
		'      \"State\":\"愛知県\",'+
		'      \"City\":\"名古屋市\",'+
		'      \"Street\":\"123\",'+
		'      \"ContactMeans\":\"17:00以降に電話希望\",'+
		'      \"InquiryContent\":\"物件の情報を詳しく知りたい\",'+
		'      \"DesireArea\":\"○○区\",'+
		'      \"RentFee\":\"下限なし\",'+
		'      \"RentFeeUpper\":\"上限なし\",'+
		'      \"RoomPlan\":[\"間取り\"],'+
		'      \"HomeMovingReason\":[\"引越し理由\"],'+
		'      \"HomeMovingReasonDissatisfaction\":\"\",'+
		'      \"OccupancyDesiredSeason\":\"引越し時期\",'+
		// ▼ 2022.2.2 LINE連携対応より、追加と修正
		'      \"LivePeople\":\"入居人数\",'+
		'	   \"lineReceiveEvent\":\"LINE受信イベント\",'+
		'	   \"lineId\":\"LINE ID\",'+
		'	   \"lineName\":\"LINE名\",'+
		'	   \"lineMessageType\":\"LINEメッセージタイプ\",'+
		'	   \"lineMessage\":\"LINEメッセージ\",'+
		'	   \"lineFileName\":\"LINEファイル名\",'+
		'	   \"lineFileUrl\":\"LINEファイルURL\",'+
		'	   \"lineThumbnailName\":\"LINEサムネイル名\",'+
		'	   \"lineThumbnailUrl\":\"LINEサムネイルURL\",'+
		'	   \"lineSendReceiveTime\":\"LINE送受信時間\"'+
		// ▲ 2022.2.2
		'  }]}';
		JsonForPortalMail obj = JsonForPortalMail.parse(json);
		System.assert(obj != null);

		// ▼ 2022.2.2 LINE連携対応より、追加
		System.assertEquals(obj.Customer[0].lineReceiveEvent,		'LINE受信イベント',		'LINE受信イベント取得テスト');
		System.assertEquals(obj.Customer[0].lineId,					'LINE ID',				'LINE ID取得テスト');
		System.assertEquals(obj.Customer[0].lineName,				'LINE名',				'LINE名取得テスト');
		System.assertEquals(obj.Customer[0].lineMessageType,		'LINEメッセージタイプ',	'LINEメッセージタイプ取得テスト');
		System.assertEquals(obj.Customer[0].lineMessage,			'LINEメッセージ',		'LINEメッセージ取得テスト');
		System.assertEquals(obj.Customer[0].lineFileName,			'LINEファイル名',		'LINEファイル名取得テスト');
		System.assertEquals(obj.Customer[0].lineFileUrl,			'LINEファイルURL',		'LINEファイルURL取得テスト');
		System.assertEquals(obj.Customer[0].lineThumbnailName,		'LINEサムネイル名',		'LINEサムネイル名取得テスト');
		System.assertEquals(obj.Customer[0].lineThumbnailUrl,		'LINEサムネイルURL',	'LINEサムネイルURL取得テスト');
		System.assertEquals(obj.Customer[0].lineSendReceiveTime,	'LINE送受信時間',		'LINE送受信時間取得テスト');
		// ▲ 2022.2.2
	}
}