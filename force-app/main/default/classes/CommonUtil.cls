public class CommonUtil {

    /** 全角印字数 */
    public static final Integer FULL_WIDTH_PRINT_LENGTH = 2;
    /** 半角印字数 */
    public static final Integer HALF_WIDTH_PRINT_LENGTH = 2;
    
    //コンストラクタ
    public CommonUtil(){
        
    }

    //************************************************************ メッセージ・入力チェック関係 *****************************************************************
    
    /**
     * メッセージ内容作成
     * 
     * @param String       メッセージ本体
     *        List<String> 挿入文字列
     * @return 完成メッセージ
     * 
     */
    public static String callMessageCreate(String message, List<String> replacementStringList){
        String retMessage = message;

		// ▼ 2022.1.7 LINE連携対応より、Null Reference Exception の対応を追加
		String replaceStr;
		// ▲ 2022.1.7

        //List<String>の数だけ変換する
        for(Integer i = 0; i < replacementStringList.size(); i++){
            //変換用添え字
            String targetMessage = '{' + i + '}';

			// ▼ 2022.1.7 LINE連携対応より、Null Reference Exception の対応を追加・修正
			replaceStr = CommonConst.STRING_EMPTY;
			if (String.isNotEmpty(replacementStringList[i])) {
				replaceStr = replacementStringList[i];
			}
		
 			retMessage = retMessage.replace(targetMessage, replaceStr);
			// ▲ 2022.1.7
        }
 
        return retMessage;
    }
    
    /**
     * メッセージ内容作成(第2引数なし)
     * 
     * @param String       メッセージ本体
     * @return callMessageCreate
     * 
     */
    public static String callMessageCreate(String message){
        List<String> replacementStringList = new List<String>();
        return callMessageCreate(message, replacementStringList);
    }
    
    /**
     * メッセージ内容作成(第2引数 String)
     * 
     * @param String       メッセージ本体
     *        String       挿入文字列(一つ)
     * @return callMessageCreate
     * 
     */
    public static String callMessageCreate(String message, String replacementString){
        List<String> replacementStringList = new List<String>();
        replacementStringList.add(replacementString);
        return callMessageCreate(message, replacementStringList);
    }
    
    /**
     * メッセージ内容作成(第2引数 String、第3引数 String)
     * 
     * @param String       メッセージ本体
     *        String       挿入文字列(一つ目)
     *        String       挿入文字列(二つ目)
     * @return callMessageCreate
     * 
     */
    public static String callMessageCreate(String message, String replacementString1, String replacementString2){
        List<String> replacementStringList = new List<String>();
        replacementStringList.add(replacementString1);
        replacementStringList.add(replacementString2);
        return callMessageCreate(message, replacementStringList);
    }
    
    
    /**
     * メッセージ内容作成(第2引数 String、第3引数 String、第4引数 String)
     * 
     * @param String       メッセージ本体
     *        String       挿入文字列(一つ目)
     *        String       挿入文字列(二つ目)
     *        String       挿入文字列(三つ目)
     * @return callMessageCreate
     * 
     */
    public static String callMessageCreate(String message, String replacementString1, String replacementString2, String replacementString3){
        List<String> replacementStringList = new List<String>();
        replacementStringList.add(replacementString1);
        replacementStringList.add(replacementString2);
        replacementStringList.add(replacementString3);
        return callMessageCreate(message, replacementStringList);
    }
    
    
    /**
     * Exceptionメッセージ変換
     * 
     * @param    Exception エラー内容
     */
    public static void setErrorMessage(Exception e){
        
        if(e instanceof BusinessLogicException){//ビジネスロジックExceptionの場合
            
            BusinessLogicException b = (BusinessLogicException)e;
            
            for (Integer i = 0; i < b.errMessage.size(); i++){
                ApexPages.Message message = new ApexPages.Message(ApexPages.severity.ERROR, b.errMessage[i]);
                ApexPages.addMessage(message);
            }
            
        }else if(e instanceof OptimisticLockException){ //楽観ロックExceptionの場合
            
            ApexPages.Message message = new ApexPages.Message(ApexPages.severity.ERROR, callMessageCreate(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK));
            ApexPages.addMessage(message);
            
        } else { //それ以外のException(標準エラー)の場合
            
            String errorMessage;
            Boolean isUnexpectedError = false;
            
            if(e instanceof system.DmlException){ //DMLExceptionの場合
                
                if(e.getMessage().contains('ENTITY_IS_DELETED')){ //削除楽観ロックエラーの場合
                    
                    errorMessage = CommonConst.MSG_COM_E_NOTICE_DELETED;
                    
                }else if (e.getMessage().contains('関連しているため、削除できません')){ //使用済み削除エラーの場合
                    
                    showUsedDataDeleteMessage(e.getMessage());
                    return; //メソッド内でエラーを出力する


                }else if(e.getMessage().contains('入力された日付がスケジュールと重複しています。')){ //日付重複エラーの場合
                    
                        errorMessage = CommonConst.MSG_CUST_E_REGISTRATION_EVENT_DUPLICATE;
                    
                }else{
                    
                    isUnexpectedError = true;
                    errorMessage = 'データの処理中にエラーが発生しました。システム管理者に連絡してください。';
                    
                }
            } else if(e instanceof system.EmailException){ //メールのエラーの場合
                
                isUnexpectedError = true;
                errorMessage = 'メールの処理中にエラーが発生しました。システム管理者に連絡してください。';
                
            } else { //その他のエラーの場合
                
                isUnexpectedError = true;
                errorMessage = 'エラーが発生しました。システム管理者に連絡してください。';
                
            }
            
            //メッセージをページに出力
            ApexPages.Message message = new ApexPages.Message(ApexPages.severity.ERROR, errorMessage);
            ApexPages.addMessage(message);

            // 予期せぬエラーの場合、エラー詳細を追加出力
            if (isUnexpectedError) {
                message = new ApexPages.Message(ApexPages.severity.ERROR, 'Exception type caught : ' + e.getTypeName());
                ApexPages.addMessage(message);
                message = new ApexPages.Message(ApexPages.severity.ERROR, 'Message : ' + e.getMessage());
                ApexPages.addMessage(message);
                message = new ApexPages.Message(ApexPages.severity.ERROR, 'Cause : ' + e.getCause());
                ApexPages.addMessage(message);
                message = new ApexPages.Message(ApexPages.severity.ERROR, 'Line number : ' + e.getLineNumber());
                ApexPages.addMessage(message);
                message = new ApexPages.Message(ApexPages.severity.ERROR, 'getStackTraceString : ' + e.getStackTraceString());
                ApexPages.addMessage(message);
            }
            
        }
    }
    
    // privateメソッド  標準の使用されているレコード削除エラーを　文面を変更して、出力
    private static void showUsedDataDeleteMessage(String str){
        
        //名前(Name)の切り取り        
        String name = str.substringBetween('DELETE_FAILED, ', 'は、次の');        
        
        //エラー文にする箇所を切り取り        
        String cutStr = str.substringAfter(name + 'は、');//「Nameは、」の前の分を削除        
        cutStr = cutStr.substring(0, cutStr.length()-4);//最後の「: []」を削除        

        //「Nameは、」を区切り文字としてリストを作成        
        List<String> errorList = cutStr.split(name + 'は、');

        //オブジェクト毎 の処理
        for (Integer i = 0;  i < errorList.size() ; i++){
            
            //文字数制限をつける
            final Integer stringLengthLimit = 150;
            if(errorList[i].length() >= stringLengthLimit){        
                errorList[i] = errorList[i].substring(0,stringLengthLimit - 1);        
                errorList[i] += '（略）';//限界を超えたら（略)を付ける
            }
            
            //エラー出力
            ApexPages.Message message = new ApexPages.Message(ApexPages.severity.ERROR, errorList[i]);
            ApexPages.addMessage(message);
        }
    }                
    
    

    /** 
    メールアドレス入力チェック
    @String mailString チェック対象のメールアドレス
    @return Boolean チェックの結果がエラーの場合はTRUEを返却する
    **/
    public static Boolean isWrongMailString(String mailString){
        Boolean retError = false;

        //mailStringが空でない、かつ　'@'が1つでない場合はエラー
        if(!String.isEmpty(mailString) && mailString.countMatches('@') != 1){
            retError = true;
        }

        return retError;
    }

    
     /**
     * 禁止用語取得メソッド
     * @param  チェックする文字列
     * @return 含まれていた禁止用語
     */   
    public static List<BanWord__c> banWordList;     //禁止用語リスト
    public static String getContainBanWord(String item){ 
        
        //null対応
        if (String.isBlank(item)) {
            return null;
        }
        
	    //禁止用語リスト確認
	    if (banWordList == null){
	    	//禁止用語リストが空だった場合、禁止用語を取得
	    	banWordList = [SELECT BanWord__c 
                           FROM BanWord__c 
                           ORDER BY BanWord__c
                           LIMIT :CommonConst.GOVERNOR_SELECT_LIMIT];
	    }
	            
	    //禁止用語を入れる返却用リスト
	    List<String> returnList = new List<String>();
	            
	    //禁止用語数分ループ                                
	    for(BanWord__c banWordData : banWordList) {
	        if( item.contains(banWordData.BanWord__c)){
	            //禁止用語が含まれていた場合、返却用リストに入れる
	        	returnList.add('「' + banWordData.BanWord__c + '」');
	        }

	    }

	    //返却用文字列の作成
	    if (!returnList.isEmpty()){
	        //返却用リストが空でない場合、カンマ区切りの文字列にする
	    	return  String.join(returnList, ',');  	
	    }else{
	    	//返却用リストが空の場合はnullを返却する
	    	return null;
	    }
    }
    
    
    //************************************************************* データ型関係 *****************************************************************
    
     /**
     * 数値型から文字列に変換するメソッド
     * @param  変更する数値型
     * @return 変更された文字列
     */   
    public static String decimalToString(Decimal changeDecimal){ 
        String returnSt;
        
        if (changeDecimal == null){
            //引数がnullの場合、nullを返す
            returnSt =  null;
        }else if (changeDecimal.scale() != 0 ){
            //引数に小数が含まれる場合(整数部カンマ区切り＋小数部)
            returnSt = String.valueOf(changeDecimal.longValue().format()) + (String.valueOf(changeDecimal).right(changeDecimal.scale() + 1));
        }else{
            //引数に小数がない場合（そのままカンマ区切り）
            returnSt =  String.valueOf(changeDecimal.format());
        }
        return returnSt;
    }
    
    
     /**
     * 文字列から数値型に変換するメソッド
     * @param  変更する文字列
     * @return 変更された数値型
     */   
    public static Decimal stringToDecimal(String changeSring){ 
        Decimal returnDec;
        if (String.isEmpty(changeSring)){
            returnDec = null;
        }else{
            returnDec = Decimal.valueOf(changeSring.remove(','));
        }
	    return returnDec;
    }

	// ▼2022.02.02 No.0676 対応で追加、
	/**
	 * 文字列から数値型に変換するメソッド(空白やnullは0で返す。)
	 * @param  String changeSring
	 * @return 変更された数値型
	 */   
    public static Decimal stringToDecimalNullToZero(String changeSring){ 
		if(!isDecimal(changeSring,false)){
			// 数値変換できない場合0で返す。
			return 0;
		}
		return Decimal.valueOf(changeSring.remove(','));
    }
    // ▲2022.02.02
    
    /**
     * 数値型に変換可能か判別する
     * 
     * @param value 改行する文字列
     *        boolean nullを許容するか（trueで許容する）
     * @return 真偽値
     *
     */
    public static Boolean isDecimal(String pValue, Boolean pBlnNull){ 
        try{
            // 第二引数が偽の場合に、第一引数が偽だと偽を返す。
            if(pBlnNull == false){
                if(pValue == null){
                    return false;                
                }
                if(pValue.length() == 0){
                    return false;                
                }
            }
            
            if(pValue == null){
                return true;                
            }
            
            if(pValue.length() == 0){
                return true;                
            }
            
            // Decimal型への変換を試み、エラーとなる場合はTry-catchで偽を返す
            Decimal d = Decimal.valueOf(pValue);
            
            return true; 
            
        //例外  
        }catch(Exception e){
            return false;
        }
    }

    /**
     * 日付型に変換可能か判別する
     * 
     * @param value 改行する文字列
     *        boolean nullを許容するか（trueで許容する）
     * @return 真偽値
     *
     */
    public static Boolean isDate(String pValue, Boolean pBlnNull){ 
        try{
        
            // 第二引数が偽の場合に、第一引数が偽だと偽を返す。
            if(pBlnNull == false){
                if(pValue == null){
                    return false;                
                }
                if(pValue.length() == 0){
                    return false;                
                }
            }

            if(pValue == null){
                return true;                
            }
            if(pValue.length() == 0){
                return true;                
            }
            if(pValue.length() != 10){
                return false;                
            }
            
            // Date型への変換を試み、エラーとなる場合はTry-catchで偽を返す
            Date d = Date.valueOf(pValue.replaceAll('/', '-'));
            
            return true;
            
        //例外  
        }catch(Exception e){
            return false;
        }
    }

    /**
     * 指定した文字数を越えた際に改行(半角、全角に対応)
     * 
     * @param  String  inputVal     入力値
     * @param  Integer maxLength    最大桁数(全角文字での桁数)
     * @param  Integer breakLength  改行位置(全角文字での桁数)
     * @return 表示文字列
     */
    public String formatOutputValue(String inputVal, Integer maxLength, Integer breakLength) {

        // 半角での文字数に変換
        integer halfWidthMaxLength = 0;
        if(maxLength != null){
          halfWidthMaxLength = maxLength * 2;  
        }
        integer halfWidthBreakLength = breakLength * 2;       
        
        String ret = commonConst.STRING_EMPTY;

        if (String.isEmpty(inputVal)) {
            return ret;
        }                

        // 改行コード削除
        String wkStr = inputVal.replaceAll(commonConst.BREAK_CODE, commonConst.STRING_EMPTY);
        Integer sumLength = 0;
        Integer lineLength = 0;

        for(Integer i = 0 ; i < wkStr.length(); i++){
            // 一文字切り出し
            String oneChar = wkStr.substring(i, (i+1));
            Integer printLenght = getPrintLength(oneChar);
            
            // バイト長加算
            sumLength += printLenght;
            lineLength += printLenght;

            if(maxLength != null && halfWidthMaxLength < sumLength){
                // 桁あふれしたら終了
                break;
            }

            if(halfWidthBreakLength < lineLength){

                // 改行
                ret += commonConst.BREAK_TAG;
                lineLength = printLenght;
            }
            ret += oneChar;
        }

        return ret;
    }

    /**
     * 印字桁数の取得(1文字分)
     * 
     * @param  String oneChar 1文字
     * @return 印字桁数
     */
    public static Integer getPrintLength(String oneChar) {
        if (getByteLength(oneChar) > 1) {
            return FULL_WIDTH_PRINT_LENGTH;
        }
        return HALF_WIDTH_PRINT_LENGTH;
    }    
    
    /**
     * バイト長の取得
     * 
     * @param  String inputVal 入力値
     * @return バイト長
     */
    public static Integer getByteLength(String inputVal) {
        return Blob.valueOf(inputVal).size();
    }
    
    
    /**
    文字列の指定文字数　左から切抜き
    @String str 切り抜く文字列
    @String len 切り抜く文字数
    @return String 切り抜いた結果
    **/
    public static String subStringLeft(String str, Integer len) {
        if (str == null) {
            return null;
        } else if (str == '') {
            return '';
        } else {
            return str.substring(0, str.length() > len ? len : str.length());
        }
    }

    /**
    2つの文字列が異なるか比較
    @String str1 比較する文字列1
    @String str2 比較する文字列2
    @return Boolean 結果（2つの文字列が異なる…true,2つの文字列が異ならない…false）
    **/
    public static Boolean isDifferenceTwoString(String str1,String str2){
        //空文字の場合、nullに変化して比較
        String reStr1 = str1 == '' ? null : str1;
        String reStr2 = str2 == '' ? null : str2;
        Boolean result;

        if (reStr1 != reStr2){
            result = true;
        }else{
           result = false;
        }
        return result;

    }

	//▼ 2022.5.30 CHINTAI本対応後の対応(反響メール)
	/**
	 * 指定した文字以降の文字列の取得
	 * @param  String characterString 文字列
	 * @return String ':'以降の文字列
	 */
	public static String getcharacterString(String characterString) {
		Integer lastColonIndex = characterString.IndexOf(':');
		String stringAfterColon = '';
		if (lastColonIndex >= 0) {
			stringAfterColon = characterString.substring(lastColonIndex + 1);
		}
		return stringAfterColon;
	}
	//▲ 2022.5.30 CHINTAI本対応後の対応(反響メール)

	//▼ 2021.12.20 No.437 対応で追加
	/**
	 * nullを空として返す
	 * @param Object st 変換元の内容
	 * @return Object 変換後の内容
	 */
	public static Object changeNullToEmpty(Object st) {
		if (st == null) {
			return '';
		} else {
			return st;
		}
	}
	//▲ 2021.12.20 No.437 対応で追加

	// ▼ 2022.02.15 No0727 共通化
	/**
	 * nullを0として返す
	 * @param Decimal dec チェック内容
	 * @return Decimal 変更後の項目
	 */
	public static Decimal getNullToDecimalValue(Decimal dec) {
		return dec == null ? 0 : dec;
	}
	// ▲ 2022.02.15 No0727 共通化
    
    //************************************************************* 日付・時間 関係 *****************************************************************
    
    
    
    /**
     * 月初日付取得
     */
    public Date getMonthOfStartDay(Date prmDate) {
        return prmDate != null ? Date.newInstance(prmDate.year(), prmDate.month(), 1) : null;
    }

    
    /**
     * 月末日付取得
     */
    public Date getMonthOfEndDay(Date prmDate) {
        return prmDate != null ? Date.newInstance(prmDate.year(), prmDate.month() + 1 ,0) : null;
    }

    /**
     * 会計年度算出
     * 
     * @param  Date dateVal, Organization orgInfo
     * @return 会計年度
     * ※Organizationは以下で取得しておいたものを使用する。
     * Organization orgInfo = [SELECT FiscalYearStartMonth, UsesStartDateAsFiscalYearName FROM Organization WHERE id = :Userinfo.getOrganizationId()];
     * 
     * ※組織情報をテストで設定することができないので、カバレッジ率は100％になりません
     */
    public static integer calcFiscalYear(DateTime dateVal, Organization orgInfo) {

        Integer ret = null;
        if (orgInfo.FiscalYearStartMonth != 1) {
            if (dateVal.month() >= orgInfo.FiscalYearStartMonth) {
                if (orgInfo.UsesStartDateAsFiscalYearName) {//会計年度を開始月の年度にしてあるか、終了月の年度にしてあるか。
                    ret = dateVal.year();
                } else {
                    ret = dateVal.addYears(1).year();
                }
            } else {
                if (orgInfo.UsesStartDateAsFiscalYearName) {//会計年度を開始月の年度にしてあるか、終了月の年度にしてあるか。
                    ret = dateVal.addYears(-1).year();
                } else {
                    ret = dateVal.year();
                }
            }
        } else {
            ret = dateVal.year();
        }

        return ret;
    }

    /**
     * 会計年度開始日・終了日算出
     * 
     * @param  String fiscalYear    4桁の会計年度
     * @param  Organization orgInfo
     * @param  Boolean isStartDate  会計年度の開始日と終了日どちらを返すか（trueで開始日）
     * @return  会計年度開始日、終了日
     * ※Organizationは以下で取得しておいたものを使用する。
     * Organization orgInfo = [SELECT FiscalYearStartMonth, UsesStartDateAsFiscalYearName FROM Organization WHERE id = :Userinfo.getOrganizationId()];
     * 
     * ※組織情報をテストで設定することができないので、カバレッジ率は100％になりません
     */
    public static Date calcFiscalYearStartEndDate(String fiscalYear, Organization orgInfo ,Boolean isStartDate) {
        
        Date fiscalYearDate;
        Integer intFiscalYear = Integer.valueOf(fiscalYear);

        //会計年の開始月の1日を取得
        fiscalYearDate = fiscalYear != null ? Date.newInstance(intFiscalYear, orgInfo.FiscalYearStartMonth, 1) : null;

        if (orgInfo.UsesStartDateAsFiscalYearName) {//会計年度を開始月の年度にしてあるか、終了月の年度にしてあるか。
            //会計年度が開始月の年度の場合
            if(!isStartDate){
                fiscalYearDate = fiscalYearDate.addYears(1).addDays(-1);//会計年の開始月の翌年から1日引いた日付(11か月後の月末)を取得
            }
        }else{
            //会計年度が終了月の年度の場合
            if(isStartDate){
                fiscalYearDate = fiscalYearDate.addYears(-1);//会計年の開始月の1年前(会計年度が終了月の年度の開始月の1日)を取得
            }else{
                fiscalYearDate = fiscalYearDate.addDays(-1);//会計年の開始月の1日前(会計年度が終了月の年度の終了月の月末)を取得

            }
        }
        return fiscalYearDate;
    }


    /**
     * today()を使う際に使用するメソッド
     * システム設定→テストtodayに値が入っていると、todayの代わりにその値を返却する。
     */
    public static Date getToday(){
        Date retDate = System.today();
        
        Date testDate = SystemConfig__c.getInstance().TestDate__c;
        if (testDate != null){
            retDate = testDate;
        }
        return retDate;
    }
    
    /**
     * now()を使う際に使用するメソッド
     * システム設定→テスト日付に値が入っていると、nowの日付をその値を返却する。（時間はnowのまま）
     */
    
    public static DateTime getNow(){
        DateTime retNow = System.now();
        
        Date testDate = SystemConfig__c.getInstance().TestDate__c;
        if (testdate != null){
            retNow = DateTime.newInstance(testDate, retNow.time());
        }
        
        return retNow;
    }

	// ▼ 2022.02.04 LINE連携対応より、日時表示の修正
	/**
	 * 日本語表記の曜日の取得
	 * @param Datetime day 日付
	 * @return String 曜日
	 */
	public static String getJpnDayWeek(Datetime day) {

		// 実施チェック
		if (day == null) {
			return CommonConst.STRING_EMPTY;
		}

		// 曜日マップ（key:英語表記、value:日本語表記）
		Map<String, String> dayWeekMap = new Map<String, String> {
			'Mon'	=>	'月'
			, 'Tue'	=>	'火'
			, 'Wed'	=>	'水'
			, 'Thu'	=>	'木'
			, 'Fri'	=>	'金'
			, 'Sat'	=>	'土'
			, 'Sun'	=>	'日'
		};

		return dayWeekMap.get(day.format('E'));
	}
	// ▲ 2022.02.04
    
     /**
     * テストクラス用sleep
     * @param    millisec スリープ秒
     * 楽観ロックチェックのチェックなどでプログラムが早すぎてSystemModStampに差異が出なくなるのを防ぐ
     */
    public static void sleep(Integer millisec) {
    
        if(millisec == null || millisec < 0) {
            millisec = 0;
        }
        Long startTime = DateTime.now().getTime();
        Long finishTime = DateTime.now().getTime();
        while ((finishTime - startTime) < millisec) {
            finishTime = DateTime.now().getTime();
        }
    }

                
    
    //************************************************************* 情報の取得 関係 *****************************************************************
    
    
    /**
     * レコードタイプId取得
     * @param  オブジェクトAPI名
     * @param  レコードタイプのAPI名
     */
    public static Id getRecordTypeId(String objectName, String apiName) {
        String sql = '';
        sql += 'SELECT Id';
        sql += '  FROM RecordType';
        sql += ' WHERE SobjectType   = \'' + String.escapeSingleQuotes(objectName) + '\'';
        sql += '   AND DeveloperName = \'' + String.escapeSingleQuotes(apiName) + '\'';
        
        RecordType retRecordType = Database.query(sql);
        return retRecordType.Id;
    }
    


    /**
     * ユーザの店舗情報取得（現在日付基準）
     * @param  なし
     * @return ユーザが現在所属している店舗情報
     */
    public static Shop__c getStaffCurrentShop() {
        return getStaffCurrentShop(CommonUtil.getToday());
    }

    /**
     * ユーザの店舗情報取得（指定日基準）
     * @param  Date     targetDate  指定日付
     * @return ユーザが現在所属している店舗情報
     */
    public static Shop__c getStaffCurrentShop(Date targetDate) {
        try {
            //店舗異動より現在の組織階層コード取得
            String sql = '';
            sql += 'SELECT OrgzanizationHierarchy__r.OrganizationCode__c';
            sql += '  FROM ShopTransfer__c';
            sql += ' WHERE Staff__c      = \'' + String.escapeSingleQuotes(UserInfo.getUserId()) + '\'';
            sql += '   AND StartDate__c <= ' + String.valueOf(targetDate);
            sql += '   AND EndDate__c   >= ' + String.valueOf(targetDate);
            sql += ' ORDER BY';
            sql += '       StartDate__c DESC';
            List<ShopTransfer__c> shopTransferList = Database.query(sql);

            // 店舗異動が存在しない場合はエラー
            if (shopTransferList.size() == 0) {
                BusinessLogicException ex = new BusinessLogicException();

                //テストクラスの場合、エラーは出さない
                if (Test.isRunningTest()){
                    return null;
                }else{
                    ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_GET_AFFILIATION_SHOP));
                    throw ex;
   
                }
            }

            // 組織階層コードをLIKE検索用に編集
            String[] orgFilter = new String[]{};
            for (ShopTransfer__c st : shopTransferList) {
                orgFilter.add('%'+ st.OrgzanizationHierarchy__r.OrganizationCode__c + '%');
            }

            // 店舗情報取得
            Map<Id, Shop__c> shopMap = new Map<Id, Shop__c>(
                [SELECT id
                      , Name
                      , PortalSitePostingDistrict__c
                      , Phone__c
                      , Fax__c
                      , SystemUseStartDate__c
                      , SystemUseEndDate__c
                      , PotalCooperationStartDate__c
                      , PotalCooperationEndDate__c
                      , PostalCode__c
                      , Address__c
                      , State__c
                      , City__c
                      , Street__c
                      , Email__c
                      , IsShopType__c
                      , Homepage__c
                      , QualificationLicensesNumber__c
                      , AffiliationAssociation__c
                      , BusinessHours__c
                      , RegularHoliday__c
                      , InvoiceRegistNumber__c
                      , CompanyName__c
                   FROM Shop__c
                  WHERE Id IN (
                        SELECT Shop__c 
                          FROM OrganizationHierarchy__c
                         WHERE Shop__c != null
                           AND ExpandedOrganizationCode__c LIKE :orgFilter
                        )
               ORDER BY Name 
                ]);

            // 店舗が取得できない場合はエラー
            if (shopMap.size() == 0) {
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_GET_AFFILIATION_SHOP));
                throw ex;
            }

            // 取得結果判定
            Shop__c retShop = null;
            if (shopMap.size() > 1) {
                //複数店舗に所属の場合は、カスタム設定の店舗が対象
                if (!String.isBlank(UserSetting__c.getInstance(UserInfo.getUserId()).ShopId__c)) {
                    retShop = shopMap.get(UserSetting__c.getInstance(UserInfo.getUserId()).ShopId__c);
                    // カスタム設定の店舗が店舗異動に存在しない場合、名前昇順の1件目を返す
                    if (retShop == null){
                        retShop = shopMap.values()[0];
                    }
                } else {
                    retShop = shopMap.values()[0];
                }
            } else {
                //単一の場合は、名前昇順の1件目
                retShop = shopMap.values()[0];
            }
           return retShop;

        } catch(Exception ex) {
            throw ex;
        }
    }

    // ポータルサイト構築 追加 Start
    /**
     * ユーザの店舗情報取得（複数ユーザ対応）
     * @param  List<id> userIdList    ユーザIDList
	 * @param  Datetime startDateTime  開始日時
	 * @param  Datetime endDateTime    終了日時
     * @return ユーザが現在所属している店舗情報
     */
    public static Map<Id, List<ShopTransfer__c>>  getStaffCurrentShopMap(List<id> userIdList,Datetime startDateTime,Datetime endDateTime) {
        try {

            //店舗異動レコードを取得
            List<ShopTransfer__c> shopTransferList = [
				SELECT id
				,     OrgzanizationHierarchy__r.Shop__c
				,     OrgzanizationHierarchy__r.Shop__r.Name
				,     OrgzanizationHierarchy__r.Shop__r.PortalSitePostingDistrict__c
				,     OrgzanizationHierarchy__r.Shop__r.Phone__c
				,     OrgzanizationHierarchy__r.Shop__r.Fax__c
				,     OrgzanizationHierarchy__r.Shop__r.SystemUseStartDate__c
				,     OrgzanizationHierarchy__r.Shop__r.SystemUseEndDate__c
				,     OrgzanizationHierarchy__r.Shop__r.PotalCooperationStartDate__c
				,     OrgzanizationHierarchy__r.Shop__r.PotalCooperationEndDate__c
				,     OrgzanizationHierarchy__r.Shop__r.PostalCode__c
				,     OrgzanizationHierarchy__r.Shop__r.Address__c
				,     OrgzanizationHierarchy__r.Shop__r.State__c
				,     OrgzanizationHierarchy__r.Shop__r.City__c
				,     OrgzanizationHierarchy__r.Shop__r.Street__c
				,     OrgzanizationHierarchy__r.Shop__r.Email__c
				,     OrgzanizationHierarchy__r.Shop__r.IsShopType__c
				,     OrgzanizationHierarchy__r.Shop__r.Homepage__c
				,     OrgzanizationHierarchy__r.Shop__r.QualificationLicensesNumber__c
				,     OrgzanizationHierarchy__r.Shop__r.AffiliationAssociation__c
				,     OrgzanizationHierarchy__r.Shop__r.BusinessHours__c
				,     OrgzanizationHierarchy__r.Shop__r.RegularHoliday__c
				,     OrgzanizationHierarchy__r.Shop__r.InvoiceRegistNumber__c
				,     Staff__c
				,     StartDate__c
				,     EndDate__c 
				FROM  ShopTransfer__c
				WHERE Staff__c in :userIdList
				AND   OrgzanizationHierarchy__r.Shop__c != NULL // 店舗が空の店舗異動は取得しない。（総務部は対象外）
				AND	((StartDate__c <= :startDateTime.Date()	AND	EndDate__c   >= :startDateTime.Date())  
				OR	(StartDate__c <= :endDateTime.Date()	AND	EndDate__c   >= :endDateTime.Date()))  
				ORDER BY OrgzanizationHierarchy__r.Shop__r.name
            ];
            if(shopTransferList.size() == 0){
                return null;
            }
            
            // ユーザの店舗情報をまとめる
            map<Id, List<ShopTransfer__c>> shopTransferMap = new  map<Id, List<ShopTransfer__c>>();
            for (ShopTransfer__c shopTransfer : shopTransferList) {
                // ユーザIDを元にした店舗異動（店舗情報有）のマップをセットする
                if(shopTransferMap.containsKey(shopTransfer.staff__c)){
                     // セットされていれば対象ユーザIDのMapにListを追加する。
                    shopTransferMap.get(shopTransfer.Staff__c).add(shopTransfer);
                }else{
                    // セットされていなければユーザIDをキーとしてMapをセットする。
                    shopTransferMap.put(shopTransfer.Staff__c, new List<ShopTransfer__c>{shopTransfer});
                }
            }

            return shopTransferMap;

        } catch(Exception ex) {
            throw ex;
        }
    }
    // ポータルサイト構築 追加 end

    /**
    選択リスト型の選択できる値を取得
    オブジェクトと選択リスト項目を指定して、選択リストの有効な値を取得する
    @string obj 選択リストを取得してくるオブジェクトAPI名
    @string item 選択リストを取得してくる項目API名
    @Boolean hasBlank --なし--を一番上に追加するかどうか
    @return List<SelectOption> 対象の選択リストの値（有効なものに限る）
    **/
    public static List<SelectOption> getSelectOptionFromObject(String obj, String item, Boolean hasBlank){
        
        //項目の選択肢を取得
        List<Schema.PicklistEntry> pickList = new List<Schema.PicklistEntry>();
        Schema.SObjectType sobjtype = (Schema.SObjectType)Schema.getGlobalDescribe().get(obj);
        if(sobjtype != null){
            Map<String, Schema.SObjectField> fieldmap = sobjtype.getDescribe().fields.getMap();
            Schema.SObjectField f = (Schema.SObjectField)fieldmap.get(item);
            if(f != null){
                Schema.DescribeFieldResult r = f.getDescribe();
                pickList = r.getPicklistValues();
            }
        }
        
        //vfの選択肢を作成
		List<SelectOption> selectOption = new List<SelectOption>();
        
        if(hasBlank){
            selectOption.add(new SelectOption('', commonConst.SELECTION_LIST_NULL));
        }
        
        for (PicklistEntry p : pickList) {
            if (p.isActive()) {
                selectOption.add(new SelectOption(p.getValue(), p.getLabel()));
            }
        }
        return selectOption;
    }
    
    /**
    選択リスト型の選択できる値を取得
    オブジェクトと選択リスト項目を指定して、選択リストの有効な値を取得する
    --なし--を一番上に追加する
    @string obj 選択リストを取得してくるオブジェクトAPI名
    @string item 選択リストを取得してくる項目API名
    @return List<SelectOption> 対象の選択リストの値（有効なものに限る）
    **/
    public static List<SelectOption> getSelectOptionFromObject(String obj, String item){
        return getSelectOptionFromObject(obj, item, TRUE);
    }


    //再販対応 追加 Start
    public static List<SelectOption> getFillSelectOptionFromObject(String obj, String item, Boolean hasBlank, String removeOption){
        List<String> removeOptionList = new List<String>();
        removeOptionList.add(removeOption);
        return getFillSelectOptionFromObject(obj, item, hasBlank, removeOptionList);
    }

    /**
    選択リスト型の選択できる値を取得　指定された文字列は選択リストに含まない
    オブジェクトと選択リスト項目を指定して、選択リストの有効な値を取得する
    @string obj 選択リストを取得してくるオブジェクトAPI名
    @string item 選択リストを取得してくる項目API名
    @Boolean hasBlank --なし--を一番上に追加するかどうか
    @List<String> removeOptionList　選択リストに追加しない選択肢リスト
    @return List<SelectOption> 対象の選択リストの値（有効なものに限る）
    **/
    public static List<SelectOption> getFillSelectOptionFromObject(String obj, String item, Boolean hasBlank, List<String> removeOptionList){
        
        //項目の選択肢を取得
        List<Schema.PicklistEntry> pickList = getSelectObject(obj, item);
        
        //vfの選択肢を作成
		List<SelectOption> selectOption = new List<SelectOption>();
        
        if(hasBlank){
            selectOption.add(new SelectOption('', commonConst.SELECTION_LIST_NULL));
        }
        
        for (PicklistEntry p : pickList) {
            if (p.isActive() && !removeOptionList.contains(p.getLabel())) {
                selectOption.add(new SelectOption(p.getValue(), p.getLabel()));
            }
        }
        return selectOption;
    }

    //選択リスト値取得
    private static List<Schema.PicklistEntry> getSelectObject(String obj, String item){
        List<Schema.PicklistEntry> pickList = new List<Schema.PicklistEntry>();
        Schema.SObjectType sobjtype = (Schema.SObjectType)Schema.getGlobalDescribe().get(obj);
        if(sobjtype != null){
            Map<String, Schema.SObjectField> fieldmap = sobjtype.getDescribe().fields.getMap();
            Schema.SObjectField f = (Schema.SObjectField)fieldmap.get(item);
            if(f != null){
                Schema.DescribeFieldResult r = f.getDescribe();
                pickList = r.getPicklistValues();
            }
        }
        return pickList;
    }
    //再販対応 追加 End

    /**
     * 選択リスト型の選択できる値を指定したオブジェクトより取得
     * 　オブジェクトと値となる項目のAPI名と表示ラベルとなる項目のAPI名を指定し、選択リストの値を取得する
     * @param   String      obj         オブジェクトAPI名
     * @param   String      value       値となる項目のAPI名
     * @param   String      label       表示ラベルとなる項目のAPI名
     * @param   String      sortOrder   並び替えを行う、項目API名
     * @return  List<SelectOption> 対象の選択リストの値
     */
    public static List<SelectOption> getSelectOptionFromObjectData(String obj, String value, String lable, String sortOrder) {
        return getSelectOptionFromObjectData(obj, value, lable, sortOrder, TRUE);
    }

    /**
     * 選択リスト型の選択できる値を指定したオブジェクトより取得
     * 　オブジェクトと値となる項目のAPI名と表示ラベルとなる項目のAPI名を指定し、選択リストの値を取得する
     * @param   String      obj         オブジェクトAPI名
     * @param   String      value       値となる項目のAPI名
     * @param   String      label       表示ラベルとなる項目のAPI名
     * @param   String      sortOrder   並び替えを行う、項目API名
     * @param   Boolean     hasBlank --なし--を一番上に追加するかどうか
     * @return  List<SelectOption> 対象の選択リストの値
     */
    public static List<SelectOption> getSelectOptionFromObjectData(String obj, String value, String label, String sortOrder, Boolean hasBlank) {
        //　値を取得
        String sql = '';
        
        sql += 'SELECT ' + value;
        
        if (value != label) {
            sql += ', ' + label;
        }
        
        sql += '  FROM ' + obj;
        if (!String.isBlank(sortOrder)) {
        sql += ' ORDER BY ' + sortOrder + ' ASC NULLS LAST';
        }
        List<sObject> sObjList = Database.query(sql);

        //　取得した値にて選択リストを作成
        List<SelectOption> selectOption = new List<SelectOption>();
        if(hasBlank){
            selectOption.add(new SelectOption('', commonConst.SELECTION_LIST_NULL));
        }
        for (sObject sObj : sObjList) {
            selectOption.add(new SelectOption(String.valueOf(sObj.get(value)), String.valueOf(sObj.get(label))));
        }

        // 返却
        return selectOption;
    }


    
    /** 
    店舗選択リスト返却メソッド
    現在使用可能な店舗を取得し、選択リストを返却する。
    @String staffId　スタッフId
    @Boolean hasBlank --なし--を一番上に追加するかどうか
    @return 店舗選択リスト
    **/
    public static List<SelectOption> getShopSelectedOptionFromStaffId (String staffId, Boolean hasBlank){
        return getShopSelectedOptionFromStaffId(staffId, hasBlank, false, false);
    }
    
    /** 
    店舗選択リスト返却メソッド
    現在使用可能な店舗を取得し、選択リストを返却する。
    @String staffId　スタッフId
    @Boolean hasBlank --なし--を一番上に追加するかどうか
    @Boolean isOnlyShop 店舗のみ（ISを除外）
    @return 店舗選択リスト
    **/
    public static List<SelectOption> getShopSelectedOptionFromStaffId (String staffId, Boolean hasBlank, Boolean isOnlyShop){
        return getShopSelectedOptionFromStaffId(staffId, hasBlank, isOnlyShop, false);
    }
    
    /** 
    店舗選択リスト返却メソッド
    現在使用可能な店舗を取得し、選択リストを返却する。
    @String staffId　スタッフId
    @Boolean hasBlank --なし--を一番上に追加するかどうか
    @Boolean isOnlyShop 店舗のみ（ISを除外）
    @Boolean notCheckStart 開始日のチェックを行うかどうか
    @return 店舗選択リスト
    **/
    public static List<SelectOption> getShopSelectedOptionFromStaffId (String staffId, Boolean hasBlank, Boolean isOnlyShop, Boolean notCheckStart){
        
        List<SelectOption> selectShopList = new List<SelectOption>();// SelectOption型のListを宣言。
        String sql = '';    // 検索SQL
        List<ShopTransfer__c> stList = new List<ShopTransfer__c>(); // スタッフ指定時の店舗異動リスト
        String[] orgFilter = new String[]{};

        // スタッフが指定されている場合
        if(!String.isEmpty(staffId)){
            // 店舗異動より、スタッフの組織階層コードを取得
            List<ShopTransfer__c> shopTransferList = 
                     [SELECT OrgzanizationHierarchy__r.OrganizationCode__c
                        FROM ShopTransfer__c 
                       WHERE Staff__c      = :staffId
                         AND StartDate__c <= :CommonUtil.getToday()
                         AND EndDate__c   >= :CommonUtil.getToday()
                     ];
            // 組織階層コードをLIKE検索用に編集
            for (ShopTransfer__c st : shopTransferList) {
                orgFilter.add('%'+ st.OrgzanizationHierarchy__r.OrganizationCode__c + '%');
            }
        }    

        // 組織階層より店舗取得
        sql =  ' SELECT Shop__r.Id, Shop__r.Name';
        sql += '  FROM OrganizationHierarchy__c';
        sql += ' WHERE Shop__c != null';
        sql += '   AND Shop__r.SystemUseEndDate__c   >= '+ String.valueOf(CommonUtil.getToday());
        
        if( !notCheckStart ) {
            // 開始日を考慮する
            sql += '   AND Shop__r.SystemUseStartDate__c <= '+ String.valueOf(CommonUtil.getToday());
        }
        
        if( isOnlyShop ) {
            // 店舗に限定する
            sql += '   AND Shop__r.IsShopType__c = TRUE ';
        }

        if (orgFilter.size() > 0){
            // スタッフが指定され、店舗異動データが存在する場合
            sql += '   AND ExpandedOrganizationCode__c LIKE :orgFilter';
        }
        sql += ' ORDER BY Shop__r.SortOrder__c';

        List<OrganizationHierarchy__c> orgList = Database.query(sql);
        
        // -- なし -- を追加する。
        if(hasBlank){
            selectShopList.add(new SelectOption('',CommonConst.SELECTION_LIST_NULL));// 第一引数 ： 値が空 第二引数 ： '-- なし -- '
        }
        
        // 検索したListを回して、SelectOption型のListに追加。
        for(OrganizationHierarchy__c reccord : orgList){
            selectShopList.add(new SelectOption(reccord.Shop__r.Id, reccord.Shop__r.Name));// 第一引数 ： 値を設定 第二引数 : ラベル名(表示名)
        }
        // 選択リストを返す。
        return selectShopList;
    }

    /** 
    ユーザ選択リスト返却メソッド
    @String shopId　店舗Id
    @Boolean hasBlank --なし--を一番上に追加するかどうか   　  
    @return ユーザ選択リスト
    **/
    public static List<SelectOption> getUserSelectedOptionFromShopId(String shopId,Boolean hasBlank){
        List<String> shopIdList = new List<String>();
        // 店舗Idを複数のリストに収納して検索処理を実行
        shopIdList.add(shopId);
        return getUserSelectedOptionFromShopId(shopIdList,hasBlank);
    }

    /** 
    ユーザ選択リスト返却メソッド
    @List<String> shopId　店舗Id複数
    @Boolean hasBlank --なし--を一番上に追加するかどうか   　  
    @return ユーザ選択リスト
    **/
    public static List<SelectOption> getUserSelectedOptionFromShopId(List<String> shopId,Boolean hasBlank){
        
        List<SelectOption> SelectUserList = new List<SelectOption>();//セレクトオプション型のlistを宣言。

        // 検索SQL
        String sql = '';
        sql += 'SELECT    Id         '; // ユーザ名
        sql += ',         Name       '; // 氏名
        sql += 'FROM      User       '; 

        // 所属部署
        sql += '   WHERE Id IN (SELECT Staff__c ';
        sql += '                FROM ShopTransfer__c ';     //店舗異動
        sql += '                WHERE StartDate__c <= ' + String.valueOf(CommonUtil.getToday());
        sql += '                AND EndDate__c   >= ' + String.valueOf(CommonUtil.getToday());


        if (shopId.size() > 0){
            //店舗IDがある場合、店舗IDを条件に追加
            sql += '            AND OrgzanizationHierarchy__r.Shop__c in :shopId ';
        } else {
            //店舗IDがない場合、直接店舗と紐づいていない組織階層を除外
            sql += '            AND OrgzanizationHierarchy__r.Shop__c != null';
        }
        sql += ')';
        
        sql += '   ORDER BY Name';

        List<User> userList = Database.query(sql); // listを取得。

        // -- なし --を追加する。
        if(hasBlank){
            SelectUserList.add(new SelectOption('',CommonConst.SELECTION_LIST_NULL));// 第一引数 ： 値が空 第二引数 ： '-- なし -- '
        }

        // 検索したListを回して、SelectOption型のListに追加。
        for(User record : userList){
            SelectUserList.add(new SelectOption (record.Id, record.Name)); // 第一引数 ： 値を設定 第二引数 : ラベル名(表示名)
        }

        // 選択リストを返却する。
        return SelectUserList;
    }

    /**
     * 学校マスタのデータをリスト取得する
     * 　オブジェクトと値となる項目のAPI名と表示ラベルとなる項目のAPI名を指定し、選択リストの値を取得する（学校に）
     * @param   String      type       学校種別
     * @param   Boolean     hasBlank --なし--を一番上に追加するかどうか
     * @return  List<SelectOption> 対象の選択リストの値
     */
    public static List<SelectOption> getSelectOptionFromObjectData(String Type, Boolean hasBlank) {
        //　値を取得
        String sql = '';
        sql += 'SELECT    Id         '; // ユーザ名
        sql += ',         Name       '; // 氏名
        sql += 'FROM      School__c  '; 

        if (!String.isBlank(Type)) {
            sql += 'WHERE     Type__c  =:Type'; 
        }
        
        List<School__c> sObjList = Database.query(sql);

        //　取得した値にて選択リストを作成
        List<SelectOption> selectOption = new List<SelectOption>();
        if(hasBlank){
            selectOption.add(new SelectOption('', commonConst.SELECTION_LIST_NULL));
        }
        for (School__c sObj : sObjList) {
            selectOption.add(new SelectOption(sObj.Id, sObj.Name));
        }

        // 返却
        return selectOption;
    }
    
    
    /**
    動的クエリ用、ワイルドカード無効化
    @String str 入力パラメータ
    @return String ワイルドカードを無効化したString
    **/
    public static String convertDisableWildcard(String str){
        if (str == null) {
            return null;
        }
        //％と＿はSFのLIKE検索で用いると、ワイルドカード扱いとなるため、無効化する
        return str.replace('％', '%').replace('%', '\\%').replace('＿', '_').replace('_', '\\_');
    }
    
    
    /**
    文字数指定でランダム文字列（半角英数）の生成
    @String length 生成する文字列の長さ
    @return String 生成した文字列
    **/
    // 文字数指定でランダム文字列（半角英数）の生成
    public static string getRandomString(Integer length){
        String charList = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        String randomString = '';
        integer position;
        for(Integer i = 0; i <= length - 1; i++) {
            position = Integer.valueof(String.valueof(Math.roundToLong(charList.length()*Math.random()))) -1;
            if(position < 0){
                position = 0;
            }
            randomString += charList.substring(position,position+1);
        }
        return randomString;
    }

    /**
    文字列から地区を検索する処理
    @String searchWord 検索文字列
    @List<SelectOption> districtList 地区リスト
    @return String 地区名
    **/
    public static String getDistrict(String  searchWord,List<SelectOption> districtList){

        //万が一nullなら空白とする（null対策）
        searchWord = (searchWord == null) ? CommonConst.STRING_EMPTY : searchWord;
        
        //住所に含まれる地区を探す
        String districtString = CommonConst.STRING_EMPTY;
        for (SelectOption district : districtList) {
            String label = district.getLabel();

            //地区を発見した場合
            if (searchWord.contains(label)){

                // 暫定の地区と発見した地区を比較（文字列を比較し多い文字を決定する。）
                if(districtString.length() <= label.length()){
                    //地区の暫定決定
                    districtString = label;
                }
            }
        }

        //地区を見つけられなければ'その他'とする
        if (string.isBlank(districtString)) {
            districtString = CommonConst.BUILDING_DISTRICT_SONOTA;
        }

        //地区を返却する
        return districtString;
        
    }

    //▼問合せNo0449で追加
    /**
     * システム管理者のメールアドレスを取得
     * @param 
     * @return List<String> システム管理者のメールアドレスList
     */
    public static List<String> getAdministratorMailList(){
        // システム管理者の取得
        List<Profile> profileList = [SELECT Id 
                                     FROM Profile
                                     WHERE Name = :CommonConst.PROFILE_SYSTEM_ADMINISTRATOR];
 
        // メールアドレスの取得
        List<User> userList =  [SELECT Email
                                FROM User
                                WHERE ProfileId = :profileList];

        List<String> systemEmailList = new List<String>();
        for (User user : userList) {
            systemEmailList.add(user.Email);
        }
        return systemEmailList;
    }
    //▲問合せNo0449で追加

    //▼再販追加
    /**
     * シングルクォートのエスケープ（Null考慮)
     * @param String st 変換元の文字列
     * @return String 変換後の文字列
     */
    public static String escapeSingleQuotesEx(String st) {
        if (st == null) {
            return 'null';
        } else {
            return String.escapeSingleQuotes(st);
        }
    }
    //▲再販追加

    /**
     * Keyに紐づくValue（Set）を取得
     * @param List<SObject> objList    オブジェクト
     * @param String        objsMapKey オブジェクト．フィールド名（Mapキー）
     * @param String        objsSetKey オブジェクト．フィールド名（Setキー）
     * @return Map<String, Set<String>> Keyに紐づくValue（Set）
     */
    public static Map<String, Set<String>> getKeysSetVal(List<SObject> objList, String objsMapKey, String objsSetKey) {

        // 戻り値
        Map<String, Set<String>> keysValMap = new Map<String, Set<String>>();

        // 設定値
        String mapKeyVal;        // Mapキー値
        String setKeyVal;        // Setキー値
        Set<String> tmpValSet;   // Set値

        try {
            for (SObject obj : objList) {
                mapKeyVal = String.valueOf(obj.get(objsMapKey));
                setKeyVal = String.valueOf(obj.get(objsSetKey));

                // Key設定
                if (!keysValMap.containsKey(mapKeyVal)) {
                    keysValMap.put(mapKeyVal, new Set<String>());
                }
                
                // Value設定
                tmpValSet = keysValMap.get(mapKeyVal);
                tmpValSet.add(setKeyVal);
                keysValMap.put(mapKeyVal, tmpValSet);
            }
        } catch (Exception e) {
            System.debug('例外メッセージ:' + e.getMessage());
            System.debug('例外スタックトレース:' + e.getStackTraceString());
            keysValMap = new Map<String, Set<String>>();
        }

        return keysValMap;
    }

	// ▼ 2021.12.10 LINE連携対応より、追加
	/**
	 * IDに紐づくオブジェクトを取得
	 * @param List<SObject> objList    オブジェクト
	 * @param String        objsMapKey オブジェクト．フィールド名（Mapキー）
	 * @return Map<String, List<SObject>> Keyに紐づくオブジェクト
	 */
	public static Map<String, List<SObject>> getKeysObject(List<SObject> objList, String objsMapKey) {

		// 戻り値
		Map<String, List<SObject>> keysValMap = new Map<String, List<SObject>>();

		// 設定値
		String			mapKeyVal;	// Mapキー値
		List<SObject>	tmpValList;	// List値

		try {
			for (SObject obj : objList) {
				mapKeyVal = String.valueOf(obj.get(objsMapKey));

				// Key設定
				if (!keysValMap.containsKey(mapKeyVal)) {
					keysValMap.put(mapKeyVal, new List<SObject>());
				}
					
				// Value設定
				tmpValList = keysValMap.get(mapKeyVal);
				tmpValList.add(obj);
				keysValMap.put(mapKeyVal, tmpValList);
			}
		} catch (Exception e) {
			keysValMap = new Map<String, List<SObject>>();
		}

		return keysValMap;
	}
	// ▲ 2021.12.10
    //▼問合せNo0487で追加
    /**
     * 画像キャッシャ対応処理
     * ファイル名の画像が更新されない（同ファイル名のキャッシュ）問題を防ぐため
     * @param String        filePath ファイルパス
     * @return String       キャッシュ回避用ファイルパス
     */
    public static String getCacheAvoidancePath(String filePath) {
        // 空ならそのまま返却
        if(String.isEmpty(filePath)){
            return filePath;
        }
        // パスがあればパスの後ろにキャッシュ回避用の日付文字列をセット
        return filePath + '?' + CommonUtil.getNow().format('yyyyMMddhhmmss');
    }
    //▲問合せNo0487で追加

	
	//▼ 2021.12.20 No.437 対応で追加
	/*
	 * Api項目取得
	 * @param String objectApiName オブジェクト名
	 * @return String 項目カンマを含む
    */
	public static String getAPIName(String objectApiName){
		String apiName = '';
		for (Schema.SObjectField field : Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().values()) {
			apiName += field.getDescribe().getName(); 
			apiName += ',';
		}
		
		// 文字が取得できるか確認
		if(apiName.length() <= 0){
			return '';
		}

		apiName = apiName.substring(0, apiName.length()-1);//最後の「,」を削除        
		return apiName;
	}

	/**
     * 名前空間の設定
     * @param String apiName 名前空間判定Api名
     * @return string 名前空間
     */
	public static String getNamespace(String apiName){
		if(apiName.lastIndexOf('__c') <= 0){
			return apiName;
		}
		Schema.DescribeSObjectResult dsr = Property__c.getSObjectType().getDescribe();
		return dsr.getName().remove(dsr.getLocalName()) + apiName;
	}

	/**
     * ２つの文字間の内容を取得
	 * @param String extractionText 対象文字列
     * @param String searchStartText 検索開始位置
	 * @param String searchEndText 検索終了位置
     * @return string 検索間の文字
     */
	public static String getExtraction(String extractionText ,String searchStartText,String searchEndText){
		Integer startIndex =extractionText.IndexOf(searchStartText);
		Integer endIndex = extractionText.IndexOf(searchEndText);
		if(startIndex <= 0 || endIndex <= 0 ){
			return '';
		}
		
		return extractionText.substring(startIndex+searchStartText.length(), endIndex);
	}
	//▲ 2021.12.20 No.437 対応で追加

	// ▼ 2022.1.29 LINE連携対応より、コードの見直し
	/**
	 * 楽観ロックチェック
	 * @param SObject obj オブジェクト
	 * @return Boolean true:更新データ無し、false:更新データ有り
	 */
	public static Boolean isOptimisticLock(SObject obj) {
		return isOptimisticLock(new List<SObject>{obj}, obj.getSObjectType());
	}

	/**
	 * 楽観ロックチェック
	 * @param List<SObject> objList オブジェクト
	 * @return Boolean true:更新データ無し、false:更新データ有り
	 */
	public static Boolean isOptimisticLock(List<SObject> objList) {
		return isOptimisticLock(objList, objList.getSObjectType());
	}

	/**
	 * 楽観ロックチェック
	 * @param List<SObject>      objList  オブジェクト
	 * @param Schema.SObjectType fromName FROM区
	 * @return Boolean true:更新データ無し、false:更新データ有り
	 */
	public static Boolean isOptimisticLock(List<SObject> objList, Schema.SObjectType fromName) {
			
		// データ存在チェック
		if (objList.size() == 0) {
			return true;
		}

		final String CUSTOM_OBJ_ID = 'Id';
		final String SYSTEM_MODSTAMP = 'SystemModstamp';

		// 条件値を取得（key:カスタムオブジェクトID、value:SystemModstamp)
		Map<String, DateTime> condMap = new Map<String, DateTime>();
		for (SObject obj : objList) {

			// 実施対象外レコードチェック
			if (String.isBlank(obj.Id)) {
				continue;
			}

			condMap.put(String.valueOf(obj.get(CUSTOM_OBJ_ID))
						, Datetime.valueOf(obj.get(SYSTEM_MODSTAMP)));
		}

		// 全レコードが実施対象外の場合はtrueを返却
		if (condMap.size() == 0) {
			return true;
		}

		// 楽観ロックチェック用のクエリを作成
		String sql = CommonConst.STRING_EMPTY;
		sql += ' SELECT Id';
		sql += '       , SystemModstamp';
		sql += ' FROM ' + fromName;
		sql += ' WHERE ';

		// IDのみを条件に設定（※SystemModstampを追加しようとするとエラーになる為、後続でチェックする）
		for (String id : condMap.keySet()) {
			sql += ' Id = \'' + CommonUtil.escapeSingleQuotesEx(id) + '\'';
			sql += ' OR';
		}
		sql = sql.removeEnd('OR');

		// レコードの取得
		List<SObject> currentRecordList = Database.query(sql);

		// 楽観ロックチェック
		// 削除済みチェック
		if (currentRecordList.size() != condMap.size()) {
			return false;
		}
			
		// 更新済みチェック
		for (SObject currentRecord : currentRecordList) {
			if (condMap.get(currentRecord.Id) != Datetime.valueOf(currentRecord.get(SYSTEM_MODSTAMP))) {
				return false;
			}
		}
			
		return true;
	}
	// ▲ 2022.1.29

	//▼問合せNo0496で追加
    // チェックボックス（単一選択）での選択リスト表示用クラス
    public class screenSelectList {
        public List<SelectOption> selectOptions { get; set; }   // セレクトオプション
        public List<String> valueList { get; set; }             // 値リスト
        public Map<String, String> nameMapList { get; set; }    // 値、表示名リスト
        public Map<String, Boolean> checkMapList { get; set; }  // 値、チェック状態リスト
        // コンストラクタ
        public screenSelectList(List<SelectOption> selectTypeList) {
            // 初期化
            this.valueList = new List<String>();
            this.nameMapList = new Map<String, String>();
            this.checkMapList = new Map<String, Boolean>();
            // データセット
            this.selectOptions = selectTypeList.clone();
            for (SelectOption option : selectTypeList) {
                String value = option.getValue();
                String label = option.getLabel();
                this.valueList.add(value);
                this.nameMapList.put(value, label);
                this.checkMapList.put(value, false);
            }
        }
        // 選択値の設定
        public void setCheckValue(String selectValue) {
            for (String value : this.valueList) {
                this.checkMapList.put(value, value == selectValue);
            }
        }
        // 選択値の取得
        public String getCheckValue() {
            String retValue = '';
            for (String value : this.valueList) {
                if (this.checkMapList.get(value)) {
                    retValue = value;
                }
            }
            return retValue;
        }
        // 対象チェック以外のチェック解除
        public void setOtherCheckCancel(String selectValue) {
            for (String value : this.valueList) {
                if (value != selectValue) {
                    this.checkMapList.put(value, false);
                }
            }
        }
    }
    //▲問合せNo0496で追加

    //▼問合せNo0553で追加
    /**
     * 入力条件の複合内容付与
     * @param  Boolean  isAnd  計算に使用する物件オブジェクト
     * @return String          AND文
     */
    public static String andSet(Boolean isAnd){
        if (isAnd) {
            return ' AND ';
        }
        return CommonConst.STRING_EMPTY;
    }
    //▲問合せNo0553で追加
}