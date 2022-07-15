@isTest
public class CommonUtilTest {

    /**
    * テストに使用するレコードを作成する
    */
	@testSetup static void Setting() {

        // 取引先
        Account account = new Account(Name = 'テスト太郎');
        insert account;
    }

    @isTest static void testAll() {
        //
        CommonUtil testInsrance = new CommonUtil();
        //メソッド実行
        // ▼2022.02.09 No.0676 対応	テスト実行エラーのため修正
        CommonUtil.isDecimal(null,true);
        CommonUtil.isDecimal('',true);
        CommonUtil.isDecimal('1',true);
        CommonUtil.isDecimal('a',true);
        CommonUtil.isDecimal(null,false);
        CommonUtil.isDecimal('',false);
        CommonUtil.isDecimal('1',false);
        CommonUtil.isDecimal('a',false);
        // ▲2022.02.09 No.0676 対応

        testInsrance.formatOutputValue('aaaaaaa',1,1);
        CommonUtil.getPrintLength('a');
        CommonUtil.getPrintLength('あ');
        CommonUtil.getByteLength('a');
        testInsrance.getMonthOfStartDay(CommonUtil.getToday());
        testInsrance.getMonthOfEndDay(CommonUtil.getToday());
        CommonUtil.getSelectOptionFromObjectData('TrainRoute__c','Id','Name','SortOrder__c');


        BusinessLogicException ex = new BusinessLogicException();
        ex.addMessage(CommonUtil.callMessageCreate('メッセージ'));
        CommonUtil.callMessageCreate('メッセージ');
        CommonUtil.callMessageCreate('メッセージ', '置換文字');
        CommonUtil.callMessageCreate('メッセージ', '置換文字1', '置換文字2');
        CommonUtil.callMessageCreate('メッセージ', '置換文字1', '置換文字2', '置換文字3');

        
        CommonUtil.isWrongMailString('abcdxxxx.co.jp');
        CommonUtil.isWrongMailString('abcd@xxxx.co.jp');
        CommonUtil.getContainBanWord('abcdefg');

        CommonUtil.decimalToString(null);
        CommonUtil.decimalToString(1);
        CommonUtil.decimalToString(1.2);
        CommonUtil.stringToDecimal(null);
        CommonUtil.stringToDecimal('12345');
        CommonUtil.subStringLeft(null,5);
        CommonUtil.subStringLeft('',5);
        CommonUtil.subStringLeft('1234567890',5);
        CommonUtil.isDifferenceTwoString('a','a');
        CommonUtil.isDifferenceTwoString('a','b');

        Organization org = [SELECT FiscalYearStartMonth, UsesStartDateAsFiscalYearName FROM Organization WHERE id = :Userinfo.getOrganizationId()];
        CommonUtil.calcFiscalYear(System.today(), org);
        CommonUtil.calcFiscalYearStartEndDate('2020', org, true);
        CommonUtil.calcFiscalYearStartEndDate('2020', org, false);
        Datetime testDate = CommonUtil.getNow();
        CommonUtil.sleep(3);
        CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_CUSTOMER);
        CommonUtil.getSelectOptionFromObject('Account', 'State__c');
        CommonUtil.getRandomString(5);
        CommonUtil.getKeysSetVal([SELECT Id, Name FROM Account WHERE Name = 'テスト太郎'], 'Id', 'Name');
        CommonUtil.isOptimisticLock(new List<Account>([SELECT Id, SystemModstamp FROM Account WHERE Name = 'テスト太郎']));
		// ▼ 2022.02.09 LINE連携対応より、カバレッジ確保の為の追加
		CommonUtil.setErrorMessage(new OptimisticLockException());
		CommonUtil.stringToDecimalNullToZero('test');
		CommonUtil.isDate('test', false);
		CommonUtil.isDate('1234567890', false);
		CommonUtil.changeNullToEmpty(null);
		CommonUtil.getStaffCurrentShop();
		CommonUtil.getStaffCurrentShopMap(new List<Id>{null},testDate,testDate);	
		CommonUtil.getFillSelectOptionFromObject(FixedPhrase__c.getSObjectType().getDescribe().getName(), FixedPhrase__c.UsageScreen__c.getDescribe().getName(), true, CommonConst.FIXEDPHRASE_USAGESCREEN_POLICY_OF_PERSONAL_INFOMATION);
		CommonUtil.getShopSelectedOptionFromStaffId(CommonConst.STRING_EMPTY, true);
		CommonUtil.getShopSelectedOptionFromStaffId(CommonConst.STRING_EMPTY, true, true);
		CommonUtil.getUserSelectedOptionFromShopId(CommonConst.STRING_EMPTY, true);
		CommonUtil.getSelectOptionFromObjectData(CommonConst.SCHOOL_TYPE_PRIMARYSCHOOL, true);
		CommonUtil.convertDisableWildcard('test');
		CommonUtil.getDistrict('test', new List<SelectOption>(CommonUtil.getSelectOptionFromObject(Building__c.getSObjectType().getDescribe().getName(), Building__c.District__c.getDescribe().getName())));
		CommonUtil.getAdministratorMailList();
		CommonUtil.getCacheAvoidancePath('test');
		CommonUtil.getAPIName(Property__c.getSObjectType().getDescribe().getName());
		CommonUtil.getNamespace(Property__c.getSObjectType().getDescribe().getName());
		CommonUtil.getExtraction('test', 'e', 's');
		CommonUtil.andSet(true);
		CommonUtil.screenSelectList screenSelectList = new CommonUtil.screenSelectList(new List<SelectOption>(CommonUtil.getSelectOptionFromObject(Building__c.getSObjectType().getDescribe().getName(), Building__c.District__c.getDescribe().getName())));
		screenSelectList.setCheckValue('test');
		screenSelectList.getCheckValue();
		screenSelectList.setOtherCheckCancel('test');
		// ▲ 2022.02.09

		// ▼ 2022.02.15 No0727 追加
		CommonUtil.getNullToDecimalValue(0);
		// ▲ 2022.02.15 No0727 追加

		CommonUtil.getcharacterString('テスト  :  テスト対応中'); //2022.05.30 CHINTAI本対応後の対応(反響メール)
    }

	// ▼ 2022.02.09 LINE連携対応より、追加
	/**
	 * 日本語表記の曜日の取得テスト
	 */
	@isTest static void getJpnDayWeekTest() {

		// 曜日一覧の取得
		List<Datetime> dayWeekTimeList = new List<Datetime>();
		for (Integer dayCnt = 0; dayCnt < 7; dayCnt++) {
			dayWeekTimeList.add(CommonUtil.getNow().addDays(dayCnt));
		}
		dayWeekTimeList.add(null);
		
		// 曜日マップ（key:英語表記、value:日本語表記）
		Map<String, String> jpnDayWeekMap = new Map<String, String> {
			'Mon'	=> '月'
			, 'Tue'	=> '火'
			, 'Wed'	=> '水'
			, 'Thu'	=> '木'
			, 'Fri'	=> '金'
			, 'Sat'	=> '土'
			, 'Sun'	=> '日'
			, null	=> CommonConst.STRING_EMPTY
		};

		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		System.runAs(thisUser) {
			test.startTest();
			
			// 日本語表記の曜日の取得
			for (DateTime dayWeekTime : dayWeekTimeList) {
				String jpnDayWeek = CommonUtil.getJpnDayWeek(dayWeekTime);
				String targetJpnDayWeek = (dayWeekTime == null) ? null : dayWeekTime.format('E');
				System.assertEquals(jpnDayWeek, jpnDayWeekMap.get(targetJpnDayWeek), '取得した日付');
			}

			test.stopTest();
		}
	}

	/**
	 * キーに紐づくオブジェクトの取得テスト
	 */
	@isTest static void getKeysObjectTest() {
		
		// 取引先の取得
		List<Account> accountList = [
			SELECT
				Id
				, Name
			FROM Account
		];

		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		System.runAs(thisUser) {
			test.startTest();
			
			// キーに紐づくオブジェクトの取得
			Map<String, List<Account>> objMap = CommonUtil.getKeysObject(accountList, Account.Id.getDescribe().getName());
			for (Account account : accountList) {
				System.assertEquals(objMap.get(account.Id)[0], account, 'MAP設定値テスト');
			}

			// 例外テスト
			objMap = CommonUtil.getKeysObject(accountList, null);
			System.assertEquals(objMap, new Map<String, List<Account>>(), '例外テスト');

			test.stopTest();
		}
	}
	// ▲ 2022.02.09
}