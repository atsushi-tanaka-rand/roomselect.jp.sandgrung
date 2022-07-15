/**
 * @File Name          : CommonConst.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 2021/2/3 14:55:21
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2020/2/20   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
 * 1.1    2021/2/0    yoshiyuki.hirata@pmb.rand.co.jp        GOVERNOR_SELECT_LIMITを追加
**/
public class CommonConst {
    /** 空文字 */
    public static final String STRING_EMPTY = '';
    /** 改行コード */
    public static final String BREAK_CODE = '\r\n';
	public static final String JSON_BREAK_CODE	= '\\n'; // 2022.1.23 LINE連携対応より、JSON用の改行コードを追加
    /** 改行タグ */
    public static final String BREAK_TAG = '<br/>';
	public static final String HTML_MAIL_BREAK_TAG = '<br>'; // 2021.12.27 LINE連携対応より、HTMLメール用の改行コードを追加
    public static final String WORD_BREAK ='<wbr/>';        //問合せNo0496で追加（文章内にて改行を入れこむ場合）
    /** ラインフィード */
    public static final String LINE_FEED = '\n';

	// ▼ 2022.2.15 LINE連携対応より、不要なタグを削除
	// ▼ 2021.12.3 LINE連携対応より、HTMLメールのBODY句の標準形式を追加
	public static final String BASIC_HTML_MAIL_BODY = '<html><body>{0}</body></html>';
	// ▲ 2021.12.3
	// ▲ 2022.2.15
    
    //**プロファイル**
    public static final String PROFILE_PUBLIC_USER = '一般ユーザ';
    public static final String PROFILE_SYSTEM_ADMINISTRATOR = 'システム管理者';
    public static final String PROFILE_SYSTEM_ADMINISTRATOR_CUSTOM = 'システム管理者カスタム';

	/** ガバナ制限 */
	public static final Integer GOVERNOR_TOTAL_SEND_MAIL = 5000;
	public static final integer GOVERNOR_SELECT_LIMIT = 50000;		// 最大読み込みレコード件数
	//▼ 2021.12.20 No.437 対応で追加
    public static final Integer GOVERNOR_DML_LIMIT = 9950;			// DML ステートメント取得最大件数（非同期 Apex の制限）※セーブポイントも１カウントとなるため件数を少し減らした状態
	public static final Integer GOVERNOR_FIND_LIMIT = 2000;			// FIND取得最大件数
	//▲ 2021.12.20 No.437 対応で追加
	public static final String GOVERNOR_API_LIMIT_SIZE_MSG = 'Exceeded max size limit of 6000000'; // 2022.2.21 LINE連携対応より、追加

    /** レコードタイプ／取引先 */
    public static final String ACCOUNT_RECTYPE_SUPPLIER = 'SupplierRecordType';
    public static final String ACCOUNT_RECTYPE_CUSTOMER = 'CustomerRecordType';
    public static final String ACCOUNT_RECTYPE_FIRE_INSURANCE = 'FireInsuranceRecordType';
    public static final String ACCOUNT_RECTYPE_GUARANTEE = 'GuaranteeRecordType';
    public static final String ACCOUNT_RECTYPE_AUXILIARY = 'AuxiliaryRecordType';
    public static final String ACCOUNT_RECTYPE_PERSON_ACCOUNT = 'PersonAccount';

    /** レコードタイプ／商品 */
    public static final String ITEM_RECTYPE_GUARANTEE_PLAN = 'GuaranteePlanRecordType';
    public static final String ITEM_RECTYPE_FIRE_INSURANCE = 'FireInsuranceRecordType';
    public static final String ITEM_RECTYPE_AUXILIARY_ITEM = 'AuxiliaryItemRecordType';

    /** レコードタイプ／取引先保険保証 */
    public static final String INSURANCE_RECTYPE_GUARANTEE_FIREINSURANCE = 'FireInsuranceRecordType';
    public static final String INSURANCE_RECTYPE_GUARANTEE_GUARANTEE = 'GuaranteeRecordType';

	// ▼ 2022.03.11 No0515 定数追加
	/** レコードタイプ／自動追客メールテンプレート */
	public static final String AUTO_PURSUIT_MAIL_TEMPLATE_LINE = 'LineType';
	public static final String AUTO_PURSUIT_MAIL_TEMPLATE_MAIL = 'MailType';
	// ▲ 2022.03.11 No0515 定数追加

    /** 対応表題／対応明細 */
    public static final String CORRESPONDDETAIL_SUPPORTEDTITLE_LINE = 'LINE紐づけ'; // 2022.01,18 LINE連携対応より、追加

    /** 選択リスト　なし用 */
    public static final String SELECTION_LIST_NULL                      = '--なし--';

    /** 選択リスト　TODO　対応種別 */
    public static final String TASK_CORRESPONDTYPE_MEMO                 = 'メモ';
    public static final String TASK_CORRESPONDTYPE_APPOINTMENT          = 'アポイント確定';
    public static final String TASK_CORRESPONDTYPE_MAIL                 = 'メール';
    public static final String TASK_CORRESPONDTYPE_VISITED              = '来店済';
    public static final String TASK_CORRESPONDTYPE_CONSIDERVISITING     = '来店後検討';
    public static final String TASK_CORRESPONDTYPE_APPLICANT            = '申込登録';
    public static final String TASK_CORRESPONDTYPE_PURSUITHOLD          = '追客保留';
    public static final String TASK_CORRESPONDTYPE_TEL                  = '電話';
    public static final String TASK_CORRESPONDTYPE_MERGE                = '名寄せ';
    public static final String TASK_CORRESPONDTYPE_CANCEL               = 'キャンセル';
    public static final String TASK_CORRESPONDTYPE_CLOSE                = '終了';
    public static final String TASK_CORRESPONDTYPE_DEPOSIT              = '入金';
    public static final String TASK_CORRESPONDTYPE_PERSONDECISION       = '担当者決定';
    public static final String TASK_CORRESPONDTYPE_RELEASEHOLD          = '保留解除';
    public static final String TASK_CORRESPONDTYPE_ENDCONTRACT          = '契約完了';
    public static final String TASK_CORRESPONDTYPE_ECHOAGGREGATION      = '反響集約';
    public static final String TASK_CORRESPONDTYPE_RETURN               = '再来';
    public static final String TASK_CORRESPONDTYPE_CONTRACT             = '契約';
    public static final String TASK_CORRESPONDTYPE_CONFIRM              = '確認案内';
    public static final String TASK_CORRESPONDTYPE_TELCONTACT           = '電話連絡';
    public static final String TASK_CORRESPONDTYPE_SENDMAIL             = 'メール送信';
    public static final String TASK_CORRESPONDTYPE_OPPORTUNITY          = '商談';
    public static final String TASK_CORRESPONDTYPE_OTHER                = 'その他';
    public static final String TASK_CORRESPONDTYPE_AUTO_RECIVE          = '自動返信';
	public static final String TASK_CORRESPONDTYPE_AUTO_RECIVE_LINE		= '自動返信(LINE)';	// 2021.12.10 LINE連携対応より、追加

    //問合せNo295で追加
    public static final String TASK_CORRESPONDTYPE_APO_CANCEL           = 'アポキャンセル';
    public static final String TASK_CORRESPONDTYPE_PROP_CAN_INTRODUCE   = '物件紹介可能';
    public static final String TASK_CORRESPONDTYPE_SMS                  = 'SMS';
    public static final String TASK_CORRESPONDTYPE_LINE                 = 'LINE';

    /** 選択リスト　TODO　状況 */
    public static final String TASK_STATUS_NOTSTARTED                   = 'Not Started';
    public static final String TASK_STATUS_INPROGRESS                   = 'In Progress';
    public static final String TASK_STATUS_COMPLETED                    = 'Completed';
    public static final String TASK_STATUS_WAITINGONSOMEONEELSE         = 'Waiting on someone else';
    public static final String TASK_STATUS_DEFERRED                     = 'Deferred';

    /** 選択リスト　対応　ステータス */
    public static final String CORRESPOND_STATUS_NOTSUPPORTED       = '未対応';
    public static final String CORRESPOND_STATUS_PURSUIT            = '追客中';
    public static final String CORRESPOND_STATUS_APPOINTMENT        = 'アポイント確定';
    public static final String CORRESPOND_STATUS_VISITED            = '来店済';
    public static final String CORRESPOND_STATUS_CONSIDERVISITING   = '来店後検討';
    public static final String CORRESPOND_STATUS_UNEARNED           = '未収入金';
    public static final String CORRESPOND_STATUS_DEPOSIT            = '入金済';
    public static final String CORRESPOND_STATUS_AGREEMENT          = '契約完了';
    public static final String CORRESPOND_STATUS_PURSUITHOLD        = '追客保留中';
    public static final String CORRESPOND_STATUS_CLOSE              = '終了';
    public static final String CORRESPOND_STATUS_APOCANCEL          = 'アポイントキャンセル';
    public static final String CORRESPOND_STATUS_APOCANCEL_PURSUIT  = 'アポキャンセル後追客中';
    public static final String CORRESPOND_STATUS_VISITED_PURSUIT    = '来店後追客中';
    public static final String CORRESPOND_STATUS_APPLCANCEL         = '申込キャンセル';
    public static final String CORRESPOND_STATUS_APPLCANCEL_PURSUIT = '申込キャンセル後追客中';
    public static final String CORRESPOND_STATUS_ECHOAGGREGATION    = '反響集約';

    /** 選択リスト　対応　イベント */
	// ▼ 2021.11.24 LINE連携対応による追加  
	public static final string CORRESPOND_EVENT_LINE_RECEIVE		= 'LINE受信';
	public static final string CORRESPOND_EVENT_LINE_FRIEND_ADD		= 'LINE追加';
	// ▲ 2021.11.24
    public static final String CORRESPOND_EVENT_EMAIL               = 'メール受信';
    public static final String CORRESPOND_EVENT_VIEWED              = '閲覧あり';
    public static final String CORRESPOND_EVENT_OTHERSTAFFSUPPORTED = '他スタッフ対応';
    public static final String CORRESPOND_EVENT_NORESPONSE_MAIL     = '反応なし（ｘ日間）';
    public static final String CORRESPOND_EVENT_NORESPONSE_LINE_SMS = 'LINE・SMS送信日時_反応なし（ｘ日間）';
    public static final String CORRESPOND_EVENT_PURSUIT_VIEWED      = '追客(閲覧あり)';
    public static final String CORRESPOND_EVENT_PURSUIT_RESPONSE    = '追客(反応あり)';
    public static final String CORRESPOND_EVENT_PURSUIT_REMIND      = '追客(リマインド)';
    public static final String CORRESPOND_EVENT_NOCONTACT           = '電話つながらない';
    public static final String CORRESPOND_EVENT_NOTHING             = 'なし';
    public static final String CORRESPOND_EVENT_VISIT_RESERVATION   = '来店予約';
    public static final String CORRESPOND_EVENT_AUTO_RECIVE         = '自動返信';
    public static final String CORRESPOND_EVENT_PROPERTY_INTRODUCTION_POSSIBLE = '物件紹介可能';

	/** 選択リスト　対応　条件完全一致 */
    public static final String CORRESPOND_EXACT_CONDITION_MATCH_EXISTS    = 'する';
    public static final String CORRESPOND_EXACT_CONDITION_MATCH_NO        = 'しない';
    
    /** 選択リスト　対応明細　メール種別 */
    public static final String CORRESPONDDETAIL_MAILTYPE_RECEIVE            = '受信';
    public static final String CORRESPONDDETAIL_MAILTYPE_SEND               = '送信';
    public static final String CORRESPONDDETAIL_MAILTYPE_TIMESPECIFICATION  = '時間指定';
    public static final String CORRESPONDDETAIL_MAILTYPE_DRAFT              = '下書き';

    /** 選択リスト　対応明細　電話状況 */
    public static final String CORRESPONDDETAIL_PHONESTATUS_ECHO        = '電話反響';
    public static final String CORRESPONDDETAIL_PHONESTATUS_CONTACT     = '電話連絡(繋がった)';
    public static final String CORRESPONDDETAIL_PHONESTATUS_NOCONTACT   = '電話連絡(繋がらない)';
    public static final String CORRESPONDDETAIL_PHONESTATUS_CALL        = '電話連絡';
    public static final String CORRESPONDDETAIL_PHONESTATUS_SEND_SMS    = 'SMS送信';
    public static final String CORRESPONDDETAIL_PHONESTATUS_RECEIVE_SMS = 'SMS受信';
    public static final String CORRESPONDDETAIL_PHONESTATUS_LINEECHO    = 'LINE反響';
    public static final String CORRESPONDDETAIL_PHONESTATUS_LIVEROECHO  = 'Livero反響';
    public static final String CORRESPONDDETAIL_PHONESTATUS_LINERECEIVE = 'LINE受信';
    public static final String CORRESPONDDETAIL_PHONESTATUS_LINESEND    = 'LINE送信';

    /** 選択リスト　対応明細　発信者 */
    public static final String CORRESPONDDETAIL_SENDER_STAFF = '担当者';
    public static final String CORRESPONDDETAIL_SENDER_CUSTOMER = 'お客様';

    /** 選択リスト　取引先　一般/業物 */
    public static final String ACCOUNT_IPPANGYOBUTSU_IPPAN          = '一般物';
    public static final String ACCOUNT_IPPANGYOBUTSU_GYOBUTSU       = '業物';
    public static final String ACCOUNT_IPPANGYOBUTSU_NOTHING        = '設定なし';

    /** 選択リスト　取引先　定期送信 */
    public static final String ACCOUNT_FixedTermSend_EXISTS   = '有';
    public static final String ACCOUNT_FixedTermSend_NO       = '無';
    public static final String ACCOUNT_FixedTermSend_NOTHING  = '設定なし';

    /** 選択リスト　取引先　紹介 */
    public static final String ACCOUNT_INTRODUCTION_REFUSED	= '紹介を断られた';
    public static final String ACCOUNT_INTRODUCTION_REJECT	= '紹介を断った';
    public static final String ACCOUNT_INTRODUCTION_NOTHING	= '設定なし';

    /** 選択リスト　商品明細　保証料支払方法 */
    public static final String ITEMDETAIL_DEPOSITPAYMENTTYPE_MONTH  = '月払';
    public static final String ITEMDETAIL_DEPOSITPAYMENTTYPE_YEAR   = '年払';

    /** 選択リスト　空室予約物件　空室状況 */
    public static final String VACANCY_STATUS_NONE  = '空室なし';
    public static final String VACANCY_STATUS_EXIST = '空室あり';
    
	// ▼ 2021.12.10 LINE連携対応より、追加  
	/** 選択リスト　反響メール　LINE種別 */
	public static final String LINE_RECEIVE_TYPE_ADD		= 'LINE追加';
	public static final String LINE_RECEIVE_TYPE_RECEIVE	= 'LINE受信';

    /** 選択リスト　問合せ御礼メール設定　送信種別 */
	public static final String THANKS_MAIL_SETTING_SEND_TYPE_MAIL	= 'メール';
	public static final String THANKS_MAIL_SETTING_SEND_TYPE_LINE	= 'LINE';
	// ▲ 2021.12.10

    /** S3画像アップロード共通部品 種別 */
    public static final String S3_PHOTOTYPE_BUILDING             = 'BUILDING';
    public static final String S3_PHOTOTYPE_PROPERTY             = 'PROPERTY';
    public static final String S3_PHOTOTYPE_SURROUNDING_FACILITY = 'SURROUNDING';
    public static final String S3_PHOTOTYPE_SCHOOL               = 'SCHOOL';
    public static final String S3_PHOTOTYPE_HOSPITAL             = 'HOSPITAL';
    public static final String S3_PHOTOTYPE_STATION              = 'STATION';

    /** S3画像 アップロード共通部品 写真種別*/
    public static final String S3_BUILDINGPHOTOTYPE_APPEARANCE        = 'APPEARANCE';
    public static final String S3_BUILDINGPHOTOTYPE_APPEARANCE_PARSE  = 'APPEARANCE_PARSE';
    public static final String S3_BUILDINGPHOTOTYPE_ENTRANCE          = 'ENTRANCE';
    public static final String S3_BUILDINGPHOTOTYPE_LOBBY             = 'LOBBY';
    public static final String S3_BUILDINGPHOTOTYPE_PARKING           = 'PARKING';
    public static final String S3_BUILDINGPHOTOTYPE_OTHERSHARING      = 'OTHERSHARING';
    public static final String S3_BUILDINGPHOTOTYPE_MAP               = 'MAP';
    public static final String S3_BUILDINGPHOTOTYPE_OTHER             = 'OTHER';
    public static final String S3_BUILDINGPHOTOTYPE_SURROUNDING       = 'SURROUNDING';
    public static final String S3_PROPERTYPHOTOTYPE_PROPERTPHOTO      = 'PROPERTPHOTO';
    public static final String S3_PROPERTYPHOTOTYPE_PANORAMA          = 'PANORAMA';
    public static final String S3_PROPERTYPHOTOTYPE_PRIVATEPHOTO      = 'PRIVATEPHOTO';
    public static final String S3_PROPERTYPHOTOTYPE_ROOMLAYOUT        = 'ROOMLAYOUT';
    public static final String S3_PROPERTYPHOTOTYPE_ROOMLAYOUTMEMO    = 'ROOMLAYOUTMEMO';    

    /** 選択リスト　建物　管理人種別 */
    public static final String BUILDING_CARETAKERTYPE_RESIDE    = '常駐';
    public static final String BUILDING_CARETAKERTYPE_NORESIDE  = '非常駐';
    public static final String BUILDING_CARETAKERTYPE_PATROL    = '巡回方式';
    public static final String BUILDING_CARETAKERTYPE_COMMUTER  = '通勤方式';
    
    /** 選択リスト　建物　地区 */
    public static final String BUILDING_DISTRICT_MINATO     ='港区';
    public static final String BUILDING_DISTRICT_MORIYAMA   ='守山区';
    public static final String BUILDING_DISTRICT_SHOWA      ='昭和区';
    public static final String BUILDING_DISTRICT_MIZUHO     ='瑞穂区';
    public static final String BUILDING_DISTRICT_NISHI      ='西区';
    public static final String BUILDING_DISTRICT_TIKUSA     ='千種区';
    public static final String BUILDING_DISTRICT_NAKA       ='中区';
    public static final String BUILDING_DISTRICT_NAKAGAWA   ='中川区';
    public static final String BUILDING_DISTRICT_NAKAMURA   ='中村区';
    public static final String BUILDING_DISTRICT_TENPAKU    ='天白区';
    public static final String BUILDING_DISTRICT_HIGASHI    ='東区';
    public static final String BUILDING_DISTRICT_MINAMI     ='南区';
    public static final String BUILDING_DISTRICT_ATUTA      ='熱田区';
    public static final String BUILDING_DISTRICT_KITA       ='北区';
    public static final String BUILDING_DISTRICT_MEITO      ='名東区';
    public static final String BUILDING_DISTRICT_MIDORI     ='緑区';
    public static final String BUILDING_DISTRICT_NAGAKUTE   ='長久手市';
    public static final String BUILDING_DISTRICT_OWAROASAHI ='尾張旭市';
    public static final String BUILDING_DISTRICT_NISSHIN    ='日進市';
    public static final String BUILDING_DISTRICT_KITANAGOYA ='北名古屋市';
    public static final String BUILDING_DISTRICT_SONOTA     ='その他';

    /** 選択リスト 建物 建物構造 */
    public static final String BUILDING_STRUCTURE_WOODEN            = '木造';
    public static final String BUILDING_STRUCTURE_BLOCK             = 'ブロック造';
    public static final String BUILDING_STRUCTURE_STEEL             = '鉄骨造';
    public static final String BUILDING_STRUCTURE_RC                = 'RC';
    public static final String BUILDING_STRUCTURE_SRC               = 'SRC';
    public static final String BUILDING_STRUCTURE_PC                = 'PC';
    public static final String BUILDING_STRUCTURE_HPC               = 'HPC';
    public static final String BUILDING_STRUCTURE_ALC               = 'ALC';
    public static final String BUILDING_STRUCTURE_LIGHTWEIGHTSTEEL  = '軽量鉄骨';
    public static final String BUILDING_STRUCTURE_OTHER             = 'その他';

    /** 選択リスト 建物 物件種別 */
    public static final String BUILDING_PROPERTYTYPE_MANSION            = 'マンション';
    public static final String BUILDING_PROPERTYTYPE_APARTMENT          = 'アパート';
    public static final String BUILDING_PROPERTYTYPE_DETACHEDHOUSE      = '一戸建て';
    public static final String BUILDING_PROPERTYTYPE_TERRACEDHOUSE      = 'テラスハウス';
    public static final String BUILDING_PROPERTYTYPE_TOWNHOUSE          = 'タウンハウス';
    public static final String BUILDING_PROPERTYTYPE_SHAREHOUSE         = 'シェアハウス';
    public static final String BUILDING_PROPERTYTYPE_DORMITORY_BOARDING = '寮・下宿';
    public static final String BUILDING_PROPERTYTYPE_OTHER              = 'その他';

    /** 選択リスト　物件　地下階区分 */
    public static final String PROPERTY_FLOORTYPE_GROUND    = '地上';
    public static final String PROPERTY_FLOORTYPE_UNGROUND  = '地下';

    /** 選択リスト　物件　バルコニー方向 */
    public static final String PROPERTY_BALCONYDIRECTION_NORTH      = '北';
    public static final String PROPERTY_BALCONYDIRECTION_NORTHEAST  = '北東';
    public static final String PROPERTY_BALCONYDIRECTION_EAST       = '東';
    public static final String PROPERTY_BALCONYDIRECTION_SOUTHEAST  = '南東';
    public static final String PROPERTY_BALCONYDIRECTION_SOUTH      = '南';
    public static final String PROPERTY_BALCONYDIRECTION_SOUTHWEST  = '南西';
    public static final String PROPERTY_BALCONYDIRECTION_WEST       = '西';
    public static final String PROPERTY_BALCONYDIRECTION_NORTHWEST  = '北西';

    /** 選択リスト　物件　現況 */
    public static final String PROPERTY_LIVESTATUS_RESIDENT         = '居住中';
    public static final String PROPERTY_LIVESTATUS_VACANCY          = '空室';
    public static final String PROPERTY_LIVESTATUS_INCOMPLETE       = '未完成';
    public static final String PROPERTY_LIVESTATUS_SCHEDULEDTOLEAVE = '退去予定';

    /** 選択リスト　物件　引渡種別 */
    public static final String PROPERTY_DELIVERYTYPE_IMMEDIATE      = '即時';
    public static final String PROPERTY_DELIVERYTYPE_CONSULTATION   = '相談';
    public static final String PROPERTY_DELIVERYTYPE_DUEDATE        = '期日指定';

    /** 選択リスト　物件　取引態様 */
    public static final String PROPERTY_TRANSACTIONASPECT_CREDITOR              = '貸主';
    public static final String PROPERTY_TRANSACTIONASPECT_PROXY                 = '代理';
    public static final String PROPERTY_TRANSACTIONASPECT_DEDICATEDBROKERAGE    = '専任媒介';
    public static final String PROPERTY_TRANSACTIONASPECT_GENERALBROKERAGE      = '一般媒介';

    /** 選択リスト　物件　定期借家区分 */
    public static final String PROPERTY_RENTTYPE_APPLICABLE     = '該当';
    public static final String PROPERTY_RENTTYPE_NOTAPPLICABLE  = '非該当';

    /** 選択リスト　物件　特優賃料金変動区分 */
    public static final String PROPERTY_SPECIFICEXCELLENTRENTFEEFLUCTUATIONTYPE_INCLINATION = '傾斜型';
    public static final String PROPERTY_SPECIFICEXCELLENTRENTFEEFLUCTUATIONTYPE_FLAT        = 'フラット型';

    /** 選択リスト　物件　未入居種別 */
    public static final String PROPERTY_LIVEDTYPE_LIVED    = '入居有';
    public static final String PROPERTY_LIVEDTYPE_NOTLIVED = '未入居';

    /** 選択リスト　物件　各種料金単位 */
    public static final String PROPERTY_FEEUNIT_YEN         = '円';
    public static final String PROPERTY_FEEUNIT_MONTH       = 'ヵ月';
    public static final String PROPERTY_FEEUNIT_RATE        = '%';
    public static final String PROPERTY_FEEUNIT_ACTUALCOST  = '実費';

    /** 選択リスト　物件　各種税区分 */
    public static final String PROPERTY_TAXTYPE_TAXABLE     = '課税';
    public static final String PROPERTY_TAXTYPE_NOTAXABLE   = '非課税';
    public static final String PROPERTY_TAXTYPE_TAXINCLUDED = '内税';
    public static final String PROPERTY_TAXTYPE_TAXEXCLUDED = '外税';

    /** 選択リスト　物件　メンテナンスアクション元画面 */
    public static final String PROPERTY_MAINTENANCEACTION_AUTOMAINTENANCE         = '自動メンテナンス';
    public static final String PROPERTY_MAINTENANCEACTION_ORIGINALPROPERTYDETAILS = '元付物件詳細';

    /** 選択リスト　物件　各種支払区分 */
    public static final String PROPERTY_PAYMENTTYPE_MONTH               = '月額';
    public static final String PROPERTY_PAYMENTTYPE_YEAR                = '年額';
    public static final String PROPERTY_PAYMENTTYPE_BEFORE_OCCUPANCY    = '入居前';
    public static final String PROPERTY_PAYMENTTYPE_AFTER_OCCUPANCY     = '入居後';

    /** 選択リスト　物件　駐車場種別 */
    public static final String PROPERTY_PARKINGTYPE_EMPTY_EXISTS        = '空有';
    public static final String PROPERTY_PARKINGTYPE_NO_EMPTY            = '空無';
    public static final String PROPERTY_PARKINGTYPE_NO                  = '無';
    public static final String PROPERTY_PARKINGTYPE_NEIGHBORHOOD_SECURE = '近隣確保';

    /** 選択リスト　物件　駐輪場種別 */
    public static final String PROPERTY_BICYCLEPARKINGTYPE_EXISTS   = '有';
    public static final String PROPERTY_BICYCLEPARKINGTYPE_NO       = '無';

    /** 選択リスト　物件　バイク置場種別 */
    public static final String PROPERTY_BIKESTORAGETYPE_EXISTS   = '有';
    public static final String PROPERTY_BIKESTORAGETYPE_NO       = '無';

    /** 選択リスト　物件　短期解約違約金有無 */
    public static final String PROPERTY_ISSHORTTERMPENALTY_EXISTS   = '有';
    public static final String PROPERTY_ISSHORTTERMPENALTY_NO       = '無';

    /** 選択リスト　物件　火災保険料(加入義務) */
    public static final String PROPERTY_FIREINSURANCEUSETYPE_EXISTS = '有';
    public static final String PROPERTY_FIREINSURANCEUSETYPE_NO     = '無';

    /** 選択リスト　物件　保証会社(利用区分)) */
    public static final String PROPERTY_GUARANTEEIDCOMPANYTYPE_UNSET    = '未設定';
    public static final String PROPERTY_GUARANTEEIDCOMPANYTYPE_REQUIRED = '利用必須';
    public static final String PROPERTY_GUARANTEEIDCOMPANYTYPE_POSSIBLE = '利用可';

    /** 選択リスト　物件　取込区分 */
    public static final String PROPERTY_IMPORTTYPE_MANUAL       = '手動';
    public static final String PROPERTY_IMPORTTYPE_REALNETPRO   = 'リアプロ';
    public static final String PROPERTY_IMPORTTYPE_DAIWALIVING  = '大和リビング';

    /** 選択リスト　物件　web公開 */
    public static final String PROPERTY_WEBPUBLISHING_EXISTS    = 'する';
    public static final String PROPERTY_WEBPUBLISHING_NO        = 'しない';

    /** 選択リスト 物件 間取り */
    public static final String PROPERTY_ROOMLAYOUT_R            = 'R';
    public static final String PROPERTY_ROOMLAYOUT_K            = 'K';
    public static final String PROPERTY_ROOMLAYOUT_DK           = 'DK';
    public static final String PROPERTY_ROOMLAYOUT_LK           = 'LK';
    public static final String PROPERTY_ROOMLAYOUT_LDK          = 'LDK';
    public static final String PROPERTY_ROOMLAYOUT_SK           = 'SK';
    public static final String PROPERTY_ROOMLAYOUT_SDK          = 'SDK';
    public static final String PROPERTY_ROOMLAYOUT_SLK          = 'SLK';
    public static final String PROPERTY_ROOMLAYOUT_SLDK         = 'SLDK';

    /** 選択リスト　物件写真　物件写真タグ */
    public static final String PROPERTYPHOTO_PROPERTYPHOTOTAG_LIVING        = '居室・リビング';
    public static final String PROPERTYPHOTO_PROPERTYPHOTOTAG_OTHERROOM     = 'その他部屋・スペース';
    public static final String PROPERTYPHOTO_PROPERTYPHOTOTAG_KITCHEN       = 'キッチン';
    public static final String PROPERTYPHOTO_PROPERTYPHOTOTAG_BATH          = 'バス・シャワールーム';
    public static final String PROPERTYPHOTO_PROPERTYPHOTOTAG_TOILET        = 'トイレ';
    public static final String PROPERTYPHOTO_PROPERTYPHOTOTAG_WASHROOM      = '洗面設備';
    public static final String PROPERTYPHOTO_PROPERTYPHOTOTAG_STORAGE       = '収納';
    public static final String PROPERTYPHOTO_PROPERTYPHOTOTAG_BALCONY       = 'バルコニー';
    public static final String PROPERTYPHOTO_PROPERTYPHOTOTAG_GARDEN        = '庭';
    public static final String PROPERTYPHOTO_PROPERTYPHOTOTAG_ENTRANCE      = '玄関';
    public static final String PROPERTYPHOTO_PROPERTYPHOTOTAG_SECURITY      = 'セキュリティ';
    public static final String PROPERTYPHOTO_PROPERTYPHOTOTAG_OTHERFACILITY = 'その他設備';
    public static final String PROPERTYPHOTO_PROPERTYPHOTOTAG_VIEW          = '眺望';
    public static final String PROPERTYPHOTO_PROPERTYPHOTOTAG_OTHER         = 'その他';

    /** 選択リスト　物件写真　自動メンテナンス差分間取図ファイル名 */
    public static final String PROPERTYPHOTO_ROOM_LAYOUT_FILE_NAME_DEFAULT  = '自動メンテ前';

    /** ラベリング結果 */
    public static final String PROPERTYPHOTO_LABELING_KITCHEN               = 'kitchen';        // キッチン
    public static final String PROPERTYPHOTO_LABELING_OTHERROOMS            = 'otherrooms';     // その他部屋・スペース
    public static final String PROPERTYPHOTO_LABELING_TOILET                = 'toilet';         // トイレ
    public static final String PROPERTYPHOTO_LABELING_BATH                  = 'bath';           // バス・シャワールーム
    public static final String PROPERTYPHOTO_LABELING_BALCONY               = 'balcony';        // バルコニー
    public static final String PROPERTYPHOTO_LABELING_LIVING                = 'living';         // 居室・リビング
    public static final String PROPERTYPHOTO_LABELING_ENTRANCE              = 'entrance';       // 玄関
    public static final String PROPERTYPHOTO_LABELING_STORAGE               = 'storage';        // 収納
    public static final String PROPERTYPHOTO_LABELING_WASHBASIN             = 'washbasin';      // 洗面設備

    /** 選択リスト　物件写真　パノラマ写真タグ */
    public static final String PROPERTYPHOTO_PANORAMATAG_EXTERIOR      = '建物外観';
    public static final String PROPERTYPHOTO_PANORAMATAG_ENTRANCE_HALL = 'エントランス';
    public static final String PROPERTYPHOTO_PANORAMATAG_ROBBY         = 'ロビー';
    public static final String PROPERTYPHOTO_PANORAMATAG_PARKING       = '駐車場';
    public static final String PROPERTYPHOTO_PANORAMATAG_OTHER_SHARED_AREA  = 'その他共有部分';
    public static final String PROPERTYPHOTO_PANORAMATAG_LIVING        = '居室・リビング';
    public static final String PROPERTYPHOTO_PANORAMATAG_OTHERROOM     = 'その他部屋・スペース';
    public static final String PROPERTYPHOTO_PANORAMATAG_KITCHEN       = 'キッチン';
    public static final String PROPERTYPHOTO_PANORAMATAG_BATH          = 'バス・シャワールーム';
    public static final String PROPERTYPHOTO_PANORAMATAG_TOILET        = 'トイレ';
    public static final String PROPERTYPHOTO_PANORAMATAG_WASHROOM      = '洗面設備';
    public static final String PROPERTYPHOTO_PANORAMATAG_STORAGE       = '収納';
    public static final String PROPERTYPHOTO_PANORAMATAG_BALCONY       = 'バルコニー';
    public static final String PROPERTYPHOTO_PANORAMATAG_GARDEN        = '庭';
    public static final String PROPERTYPHOTO_PANORAMATAG_ENTRANCE      = '玄関';
    public static final String PROPERTYPHOTO_PANORAMATAG_SECURITY      = 'セキュリティ';
    public static final String PROPERTYPHOTO_PANORAMATAG_OTHERFACILITY = 'その他設備';
    public static final String PROPERTYPHOTO_PANORAMATAG_VIEW          = '眺望';
    public static final String PROPERTYPHOTO_PANORAMATAG_OTHER         = 'その他';

    /** 選択リスト　物件写真　非公開写真タグ */
    public static final String PROPERTYPHOTO_PRIVATEPHOTOTAG_BREAKER    = 'ブレイカー';
    public static final String PROPERTYPHOTO_PRIVATEPHOTOTAG_KEY        = '鍵';
    public static final String PROPERTYPHOTO_PRIVATEPHOTOTAG_LIGHTING   = '照明';
    public static final String PROPERTYPHOTO_PRIVATEPHOTOTAG_OTHER      = 'その他';

    /** 選択リスト　建物写真　周辺写真タグ */
    public static final String BUILDINGPHOTO_SURROUNDINGTAG_SHOPPINGCENTER      = 'ショッピングセンター';
    public static final String BUILDINGPHOTO_SURROUNDINGTAG_DRAGSTORE           = 'ドラックストア';
    public static final String BUILDINGPHOTO_SURROUNDINGTAG_HOMECENTER          = 'ホームセンター';
    public static final String BUILDINGPHOTO_SURROUNDINGTAG_KIDERGARTEN         = '幼稚園・保育園';
    public static final String BUILDINGPHOTO_SURROUNDINGTAG_HOSPITAL            = '病院';
    public static final String BUILDINGPHOTO_SURROUNDINGTAG_POSTOFFICE          = '郵便局';
    public static final String BUILDINGPHOTO_SURROUNDINGTAG_GOVERNMENTOFFICE    = '役所';
    public static final String BUILDINGPHOTO_SURROUNDINGTAG_LIBRARY             = '図書館';
    public static final String BUILDINGPHOTO_SURROUNDINGTAG_BANK                = '銀行';
    public static final String BUILDINGPHOTO_SURROUNDINGTAG_POLICESTATION       = '警察署・交番';
    public static final String BUILDINGPHOTO_SURROUNDINGTAG_PARK                = '公園';
    public static final String BUILDINGPHOTO_SURROUNDINGTAG_RENTALVIDEO         = 'レンタルビデオ';
    public static final String BUILDINGPHOTO_SURROUNDINGTAG_RESTAURANT          = '飲食店';
    public static final String BUILDINGPHOTO_SURROUNDINGTAG_OTHER               = 'その他';

    /** 選択リスト　商品(火災保険)　更新期間 */
    public static final String ITEM_PAYMENTTYPE_MONTH   = '月型';
    public static final String ITEM_PAYMENTTYPE_YEAR    = '年型';

    /** 選択リスト　管理会社指定商品　支払区分 */
    public static final String MANAGEMENTCOMPANYITEM_PAYMENTTYPE_FIRST  = '初回';
    public static final String MANAGEMENTCOMPANYITEM_PAYMENTTYPE_MONTH  = '月額';
    public static final String MANAGEMENTCOMPANYITEM_PAYMENTTYPE_YEAR   = '年額';

    /** 選択リスト　メンテナンス区分 */
    public static final String MAINTENANCETYPE_MANUALADD = '手動追加';
    public static final String MAINTENANCETYPE_AUTHADD = '自動追加';
    public static final String MAINTENANCETYPE_VACANCYCHG = '空室変更';
    public static final String MAINTENANCETYPE_MANUALCHG = '手動変更';
    public static final String MAINTENANCETYPE_NAMEIDENTIFICATION = '名寄せ';
    public static final String MAINTENANCETYPE_AUTOCHG = '自動変更';

    /** 選択リスト　自動メンテナンス　種別 */
    public static final String AUTOMAINTENANCE_TYPE_ADDNEW = '新規追加';
    public static final String AUTOMAINTENANCE_TYPE_CONDITIONCHANGEUPDATE = '更新(条件変更)';
    public static final String AUTOMAINTENANCE_TYPE_OCCUPIEDTOVACANTUPDATE = '更新(居住中→空室)';
    public static final String AUTOMAINTENANCE_TYPE_ENDOFPOSTING = '掲載終了';

    /** 選択リスト　ToDo 優先度  */
    public static final String TASK_PRIORITY_HIGH = 'High';
    public static final String TASK_PRIORITY_NORMAL = 'Normal';

    /** 選択リスト　期間  */
    public static final String TERM_THIS_YEAR = '当年';
    public static final String TERM_PREVIOUS_YEAR = '前年';

    /** 選択リスト　周辺施設　施設区分 */
    public static final String SURROUDING_FACILITY_TYPE_HIGHSCHOOL = '高校';
    public static final String SURROUDING_FACILITY_TYPE_UNIVERSITY = '大学';
    public static final String SURROUDING_FACILITY_TYPE_CONVINIENTSTORE = 'コンビニ';
    public static final String SURROUDING_FACILITY_TYPE_SUPERMARKET = 'スーパー';
    public static final String SURROUDING_FACILITY_TYPE_NOTAPPLICABLE = '周辺施設対象外'; //2022.03.28 No0771 定数追加

    /** 選択リスト　学校　種別  */
    public static final String SCHOOL_TYPE_PRIMARYSCHOOL    = '小学校';
    public static final String SCHOOL_TYPE_JUNIORHIGHSCHOOL = '中学校';

    /** 選択リスト　商品　付帯商品種別 */
    public static final String AUXILIARY_ITEM_TYPE_DISINFECTION ='消毒';
    public static final String AUXILIARY_ITEM_TYPE_KEYEXCHANGE ='鍵交換';
    public static final String AUXILIARY_ITEM_TYPE_RELIABLESUPPORT ='安心サポート';
    public static final String AUXILIARY_ITEM_TYPE_FSHOT ='Fショット';
    public static final String AUXILIARY_ITEM_TYPE_ALSOKLOCK ='アルソック'; 

    /** 項目数　各種写真 */
    public static final Integer MAXINDEX_PROPERTY_PROPERTY      = 20;   // 物件写真．物件写真
    public static final Integer MAXINDEX_PROPERTY_PRIVATE       = 8;    // 物件写真．非公開写真
    public static final Integer MAXINDEX_PROPERTY_PANORAMA      = 5;    // 物件写真．パノラマ写真
    public static final Integer MAXINDEX_BUILDING_SURROUNDING   = 5;    // 建物写真．周辺写真

    /** 項目種別　建物写真　写真タグ */
    public static final String BUILDINGPHOTO_TAG_APPEARANCE         = '建物外観';
    public static final String BUILDINGPHOTO_TAG_APPEARANCE_PARSE   = '外観パース';
    public static final String BUILDINGPHOTO_TAG_ENTRANCE           = 'エントランス';
    public static final String BUILDINGPHOTO_TAG_LOBBY              = 'ロビー';
    public static final String BUILDINGPHOTO_TAG_PARKING            = '駐車場';
    public static final String BUILDINGPHOTO_TAG_OTHERSHARING       = 'その他共有部分';
    public static final String BUILDINGPHOTO_TAG_MAP                = '地図';
    public static final String BUILDINGPHOTO_TAG_OTHER              = 'その他';
    public static final String BUILDINGPHOTO_TAG_SURROUNDING        = '周辺写真';

    /** 日付固定 */
    public static final Datetime LAST_DATE = Datetime.parse('2999/12/31 12:59');

    /** 自動メンテナンス差分 自動メンテナンス区分 */
    public static final String AUTOMAINTEDIFF_AUTOMAINTETYPE_NEW                        = '1:新規';
    public static final String AUTOMAINTEDIFF_AUTOMAINTETYPE_PROPERTY_NEW               = '2:物件新規';
    public static final String AUTOMAINTEDIFF_AUTOMAINTETYPE_CHANGE_CONDITION           = '3:条件変更';
    public static final String AUTOMAINTEDIFF_AUTOMAINTETYPE_LIVESTATUS_EMPTY           = '4:居住中→空室';
    public static final String AUTOMAINTEDIFF_AUTOMAINTETYPE_POSTING_END                = '5:掲載終了';

    /** 自動メンテナンス差分 外部サイトコード */
    public static final String AUTOMAINTEDIFF_SITECODE_REALNETPRO  = '201';
    public static final String AUTOMAINTEDIFF_SITECODE_DAIWALIVING = '202';

    /** 選択リスト 自動メンテナンス クローリング元 */
    public static final String AUTOMAINTENANCE_CRAWLING_SOURCE_REALPRO         = 'リアプロ';
    public static final String AUTOMAINTENANCE_CRAWLING_SOURCE_DAIWALIVING     = '大和リビング';

    /** 自動メンテナンス差分.建物写真タグ */
    public static final String AUTOMAINTDIFF_BUILDINGPHOTOTAG_APPEARANCE       = '建物外観';
    public static final String AUTOMAINTDIFF_BUILDINGPHOTOTAG_APPEARANCE_PARSE = '外観パース';
    public static final String AUTOMAINTDIFF_BUILDINGPHOTOTAG_ENTRANCE         = 'エントランス';
    public static final String AUTOMAINTDIFF_BUILDINGPHOTOTAG_LOBBY            = 'ロビー';
    public static final String AUTOMAINTDIFF_BUILDINGPHOTOTAG_PARKING          = '駐車場';
    public static final String AUTOMAINTDIFF_BUILDINGPHOTOTAG_MAP              = '地図';
    public static final String AUTOMAINTDIFF_BUILDINGPHOTOTAG_OTHERSHARING     = 'その他共有部分';
    public static final String AUTOMAINTDIFF_BUILDINGPHOTOTAG_SURROUNDING      = '周辺写真';
    public static final String AUTOMAINTDIFF_BUILDINGPHOTOTAG_OTHER            = 'その他';

    /** 自動メンテナンス差分.物件写真タグ */
    public static final String AUTOMAINTEDIFF_PROPERTYPHOTOTAG_ROOMLAYOUT       = '間取り';
    public static final String AUTOMAINTEDIFF_PROPERTYPHOTOTAG_LIVING           = '居室・リビング';
    public static final String AUTOMAINTEDIFF_PROPERTYPHOTOTAG_OTHERROOM        = 'その他部屋・スペース';
    public static final String AUTOMAINTEDIFF_PROPERTYPHOTOTAG_KITCHEN          = 'キッチン';
    public static final String AUTOMAINTEDIFF_PROPERTYPHOTOTAG_BATH             = 'バス・シャワールーム';
    public static final String AUTOMAINTEDIFF_PROPERTYPHOTOTAG_TOILET           = 'トイレ';
    public static final String AUTOMAINTEDIFF_PROPERTYPHOTOTAG_WASHROOM         = '洗面設備';
    public static final String AUTOMAINTEDIFF_PROPERTYPHOTOTAG_STORAGE          = '収納';
    public static final String AUTOMAINTEDIFF_PROPERTYPHOTOTAG_BALCONY          = 'バルコニー';
    public static final String AUTOMAINTEDIFF_PROPERTYPHOTOTAG_GARDEN           = '庭';
    public static final String AUTOMAINTEDIFF_PROPERTYPHOTOTAG_ENTRANCE         = '玄関';
    public static final String AUTOMAINTEDIFF_PROPERTYPHOTOTAG_SECURITY         = 'セキュリティ';
    public static final String AUTOMAINTEDIFF_PROPERTYPHOTOTAG_OTHERFACILITY    = 'その他設備';
    public static final String AUTOMAINTEDIFF_PROPERTYPHOTOTAG_VIEW             = '眺望';
    public static final String AUTOMAINTEDIFF_PROPERTYPHOTOTAG_OTHER            = 'その他';

    /** 自動メンテナンス差分 部屋タイプ */
    public static final String AUTOMAINTEDIFF_ROOMTYPE_K                 = 'K';
    public static final String AUTOMAINTEDIFF_ROOMTYPE_DK                = 'DK';
    public static final String AUTOMAINTEDIFF_ROOMTYPE_LDK               = 'LDK';
    public static final String AUTOMAINTEDIFF_ROOMTYPE_JAPANESESTYLEROOM = '和室';
    public static final String AUTOMAINTEDIFF_ROOMTYPE_WESTERNSTYLEROOM  = '洋室';
    public static final String AUTOMAINTEDIFF_ROOMTYPE_S                 = 'S';
    public static final String AUTOMAINTEDIFF_ROOMTYPE_D                 = 'D';
    public static final String AUTOMAINTEDIFF_ROOMTYPE_L                 = 'L';
    public static final String AUTOMAINTEDIFF_ROOMTYPE_LD                = 'LD';
    
    /** 自動メンテナンス差分 バッチステータス */
    public static final String AUTOMAINTEDIFF_BATCHSTATUS_1  = '1：バッチ1未処理';
    public static final String AUTOMAINTEDIFF_BATCHSTATUS_2  = '2：バッチ2未処理';
    public static final String AUTOMAINTEDIFF_BATCHSTATUS_S  = '99：バッチ処理終了';
    public static final String AUTOMAINTEDIFF_BATCHSTATUS_E1 = '-1：バッチ1エラー';
    public static final String AUTOMAINTEDIFF_BATCHSTATUS_E2 = '-2：バッチ2エラー';

    /** S3ファイル移動 バッチステータス */
    public static final String S3FILEMOVE_BATCHSTATUS_WAITING_PROCESSING = '1：処理待ち';
    public static final String S3FILEMOVE_BATCHSTATUS_ERROR              = '-1：エラー';

	// ▼ 2021.11.10 LINE連携対応による追加
	/** LINE会員 ステータス */
	public static final String LINE_MEMBER_STATUS_DONE_CORRESPOND	= '対応済';
	public static final String LINE_MEMBER_STATUS_NOT_REPLIED		= '未返信';
	public static final String LINE_MEMBER_STATUS_DONE_REPLIED		= '返信済';

	/** LINE履歴 送信区分 */
	public static final String LINE_HISTORY_SEND_TYPE_MANAGER	= '担当者';
	public static final String LINE_HISTORY_SEND_TYPE_CUSTOMER	= '顧客';
	// ▲ 2021.11.10

    /** 選択リスト 来店カード 代理会社有無 */
    public static final String VISITCARD_ISPROXYCOMPANY_EXISTS                  = '有';
    public static final String VISITCARD_ISPROXYCOMPANY_NO                      = '無';

    /** 選択リスト 来店カード 駐車場 */
    public static final String VISITCARD_PARKING_EXISTS                         = '有';
    public static final String VISITCARD_PARKING_NO                             = '無';

    /** 選択リスト 来店カード 事前にネット */
    public static final String VISITCARD_SITEVIEW_SAW                           = '見た';
    public static final String VISITCARD_SITEVIEW_NOTSAW                        = '見ていない';

    /** 選択リスト　お気に入り物件　ステータス */
    public static final String FAVORITEPROPERTY_STATUS_INTRODUCTION      = '紹介';
    public static final String FAVORITEPROPERTY_STATUS_PREVIEW           = '内見';

    /** 反響メール取込　メールアドレス */
    public static final String EMAIL_SUMO       = SystemConfig__c.getInstance().EmailSumo__c;
    public static final String EMAIL_HOMES      = SystemConfig__c.getInstance().EmailHomes__c;
    public static final String EMAIL_ATHOME     = SystemConfig__c.getInstance().EmailAthome__c;
    public static final String EMAIL_ERROR      = 'mailer-daemon@salesforce.com';
    public static final String EMAIL_CHINTAI     = SystemConfig__c.getInstance().EmailChintai__c; //2022/3/7 CHINTAI対応による追加


    /** 反響メール バッチステータス */
    public static final String BATCH_STUTAS_WAITING    = '処理待ち'; 
    public static final String BATCH_STUTAS_COMPLETED  = '完了'; 

    /** 対応　初回問合せ方法 */
    public static final String FIRSTINQUIRYMEANS_MAIL = 'メール';
    public static final String FIRSTINQUIRYMEANS_PHONE = '電話';
    public static final String FIRSTINQUIRYMEANS_LINE = 'LINE';
    
    /** 店舗名(IS) */
    public static final String SHOP_NAME_IS = 'IS';

    /** システム変数　項目名 */
    public static final String IS_AUTOMAINTENANCE_BATCHPROCESSING = 'IsAutoMaintenanceBatchProcessing';
    public static final String IS_AUTOMAINTENANCE_BATCHPROCESSING2 = 'IsAutoMaintenanceBatchProcessing2';
    public static final String IS_AUTOMAINTENANCE_BATCHPROCESSING3 = 'IsAutoMaintenanceBatchProcessing3';
    public static final String IS_AUTOMAINTENANCE_BATCHPROCESSING4 = 'IsAutoMaintenanceBatchProcessing4';
    public static final String IS_AUTOMAINTENANCE_BATCHPROCESSING5 = 'IsAutoMaintenanceBatchProcessing5';
    public static final String IS_S3FILEMOVE_BATCHPROCESSING = 'IsS3FileMoveBatchProcessing';
    public static final String PORTALPROCESSCHECKBOX_DISTRICT = 'PortalProcessCheckbox_District';
    public static final String PORTALPROCESSCHECKBOX_SHOP = 'PortalProcessCheckbox_Shop';
    public static final String IS_ECHOMAIL_BATCHPROCESSING = 'IsEchoMailBatchProcessing';
    public static final String IS_EXACT_COND_MATCH_PROP_BATCH_PROCESSING = 'IsExactCondMatchPropBatchProcessing';

    /** 選択リスト 申込 申込種別 */
    public static final String APPLICATION_APPLICATIONTYPE_INDIVIDUAL = '個人';
    public static final String APPLICATION_APPLICATIONTYPE_STUDENT = '学生';
    public static final String APPLICATION_APPLICATIONTYPE_CORPORATION = '法人';

    /** ポータルサイト　ポータルサイト名 */
    public static final String PORTALSITE_NAME_SUUMO   = 'SUUMO';
    public static final String PORTALSITE_NAME_HOMES   = 'HOME\'S';
    public static final String PORTALSITE_NAME_AT_HOME = 'at home';
	public static final String PORTALSITE_NAME_CHINTAI = 'CHINTAI'; //2022/3/16 CHINTAI対応による追加
	public static final String PORTALSITE_NAME_WOMANCHINTAI = 'Woman.CHINTAI'; //2022/3/16 CHINTAI対応による追加
	
    /** 選択リスト　ポータルサイト　 選択肢タイプ*/
    public static final String PORTALSITE_SELECTIONTYPE_SCREEN = '画面表示';
    public static final String PORTALSITE_SELECTIONTYPE_LIVERO = 'Livero';

    /** 選択リスト　文例　 使用画面*/
    public static final String EXAMPLESENTENCE_USAGESCREEN_SENDMAIL = 'メール送信画面';
	public static final String EXAMPLESENTENCE_LINE_EXCLUSIVE		= 'LINE専用画面'; // 2021.11.10 LINE連携対応による追加
    public static final String EXAMPLESENTENCE_USAGESCREEN_REGISTPROPERTY = '物件登録画面';

    /** 選択リスト　定型文　 使用画面*/
    public static final String FIXEDPHRASE_USAGESCREEN_SENDMAIL = 'メール送信画面'; 
	public static final String FIXEDPHRASE_LINE_EXCLUSIVE		= 'LINE専用画面'; // 2021.11.10 LINE連携対応による追加
    public static final String FIXEDPHRASE_USAGESCREEN_POLICY_OF_PERSONAL_INFOMATION = '個人情報の取扱方針';   
    
    //▼問合せNo295で追加
    /** 選択リスト　アポキャンセル理由 */
    public static final String APOCANCEL_LAST_MINUTE_CANCELLATION = 'ドタキャン';
    public static final String APOCANCEL_OTHER_DECISION = '他決';
    public static final String APOCANCEL_OTHER = 'その他';
    //▲問合せNo295で追加

    /** 選択リスト (初回)案内方法 */
    public static final String GUIDANCE_METHOD_STORE_GUIDE          = '店頭案内';
    public static final String GUIDANCE_METHOD_LOCAL_GUIDE          = '現地案内';
    public static final String GUIDANCE_METHOD_ONLINE_OPPORTUNITY   = 'オンライン商談';
    public static final String GUIDANCE_METHOD_ONLINE_PREVIEW       = 'オンライン内見';

	// ▼ 2022.1.31 LINE連携対応より、HTMLメール用置換文字キーワードの追加とコードの見直し
	/** 置換文字キーワード */
	public static final String REPLACE_KEY_CUSTOMER_NAME			= '{お客様名}';
	public static final String REPLACE_KEY_IN_CHARGE_NAME			= '{担当者名}';
	public static final String REPLACE_KEY_SHOP_NAME				= '{店舗名}';
	public static final String REPLACE_KEY_POSTAL_CODE				= '{郵便番号}';
	public static final String REPLACE_KEY_SHOP_ADDRESS_1			= '{店舗住所１}';
	public static final String REPLACE_KEY_SHOP_ADDRESS_2			= '{店舗住所２}';
	public static final String REPLACE_KEY_PHONE_NUMBER				= '{電話番号}';
	public static final String REPLACE_KEY_FAX						= '{FAX}';
	public static final String REPLACE_KEY_BUSINESS_HOURS			= '{営業時間}';
	public static final String REPLACE_KEY_REGULAR_HOLIDAY			= '{定休日}';
	public static final String REPLACE_KEY_SHOP_HP					= '{店舗HP}';
	public static final String REPLACE_KEY_ECHOMAIL_PROPERTY_URL	= '{反響メール物件URL}';
	public static final String REPLACE_KEY_ECHOMAIL_GREETING		= '{あいさつ}';
		
	/** 挨拶 */
	public static final String GREETING_MORNING	= 'おはようございます。';
	public static final String GREETING_NOON	= 'こんにちは。';
	public static final String GREETING_EVENING	= 'こんばんは。';
	public static final String GREETING_NIGHT	= '夜分遅くに失礼いたします。';

    /** HTML・テキストメール用置換文字キーワード */ // 2022.2.15 LINE連携対応より、コメントの修正
	public static final String REPLACE_KEY_LINE_INTRODUCTION_URL	= '{LINE紹介URL}';
	public static final String REPLACE_KEY_VISIT_RESERVATION_URL	= '{来店予約URL}';
	public static final String REPLACE_KEY_HTML_BODY				= '{本文}';
	// ▲ 2022.1.31

    /** 行動オブジェクト */
    public static final String SUBJECT_REGULARHOLIDAY = '定休日';
    /** 行動オブジェクト 件名*/
    public static final String SUBJECT_HOLIDAY = '【休み】';        // No.601 休みの追加
    

    /** 自動メンテナンス内容 */
    public static final String NOTICE_ITEM_FACILITY_REMARKS_PRIVATE = '設備備考（非公開）';
    public static final String NOTICE_ITEM_PROP_REMARKS_PRIVATE = '物件備考（非公開）';
    public static final String NOTICE_ITEM_ROOM_LAYOUT = '間取り図';
    public static final String NOTICE_ITEM_PARKING_TYPE = '駐車場種別';
    public static final String NOTICE_ITEM_CHECK_TRUE = 'あり';
    public static final String NOTICE_ITEM_CHECK_FALSE = 'なし';

    /** 元付物件詳細 */
    public static final String SAVE_BULK_PROPERTY_UPDATE = '物件を';
    public static final String SAVE_BULK_RESIDENT_UPDATE = '物件を居住中に';
    public static final String ITEM_PROPERTY = '物件';

    /** 条件完全一致 */
    public static final String NOT_EXIST_BUILDING_NAME = '建物無し';


    /** 都道府県の緯度・経度情報 */
    public static final Map<String, Decimal> DISTRICTS_LATITUDE = new Map<String, Decimal> {
          '北海道'   =>  43.06417, '青森県'   =>  40.82444, '岩手県'   =>  39.70361, '宮城県'   =>  38.26889, '秋田県'   => 39.71861
        , '山形県'   =>  38.24056, '福島県'   =>  37.75   , '茨城県'   =>  36.34139, '栃木県'   =>  36.56583, '群馬県'   => 36.39111
        , '埼玉県'   =>  35.85694, '千葉県'   =>  35.60472, '東京都'   =>  35.68944, '神奈川県' =>  35.44778, '新潟県'   => 37.90222
        , '富山県'   =>  36.69528, '石川県'   =>  36.59444, '福井県'   =>  36.06528, '山梨県'   =>  35.66389, '長野県'   => 36.65139
        , '岐阜県'   =>  35.39111, '静岡県'   =>  34.97694, '愛知県'   =>  35.18028, '三重県'   =>  34.73028, '滋賀県'   => 35.00444
        , '京都府'   =>  35.02139, '大阪府'   =>  34.68639, '兵庫県'   =>  34.69139, '奈良県'   =>  34.68528, '和歌山県' => 34.22611
        , '鳥取県'   =>  35.50361, '島根県'   =>  35.47222, '岡山県'   =>  34.66167, '広島県'   =>  34.39639, '山口県'   => 34.18583
        , '徳島県'   =>  34.06583, '香川県'   =>  34.34028, '愛媛県'   =>  33.84167, '高知県'   =>  33.55972, '福岡県'   => 33.60639
        , '佐賀県'   =>  33.24944, '長崎県'   =>  32.74472, '熊本県'   =>  32.78972, '大分県'   =>  33.23806, '宮崎県'   => 31.91111
        , '鹿児島県' =>  31.56028, '沖縄県'   =>  26.2125
    };
    public static final Map<String, Decimal> DISTRICTS_LONGITUDE = new Map<String, Decimal> {
          '北海道'   => 141.34694, '青森県'   => 140.74   , '岩手県'   => 141.1525 , '宮城県'   => 140.87194, '秋田県'   => 140.1025
        , '山形県'   => 140.36333, '福島県'   => 140.46778, '茨城県'   => 140.44667, '栃木県'   => 139.88361, '群馬県'   => 139.06083
        , '埼玉県'   => 139.64889, '千葉県'   => 140.12333, '東京都'   => 139.69167, '神奈川県' => 139.6425 , '新潟県'   => 139.02361
        , '富山県'   => 137.21139, '石川県'   => 136.62556, '福井県'   => 136.22194, '山梨県'   => 138.56833, '長野県'   => 138.18111
        , '岐阜県'   => 136.72222, '静岡県'   => 138.38306, '愛知県'   => 136.90667, '三重県'   => 136.50861, '滋賀県'   => 135.86833
        , '京都府'   => 135.75556, '大阪府'   => 135.52   , '兵庫県'   => 135.18306, '奈良県'   => 135.83278, '和歌山県' => 135.1675
        , '鳥取県'   => 134.23833, '島根県'   => 133.05056, '岡山県'   => 133.935  , '広島県'   => 132.45944, '山口県'   => 131.47139
        , '徳島県'   => 134.55944, '香川県'   => 134.04333, '愛媛県'   => 132.76611, '高知県'   => 133.53111, '福岡県'   => 130.41806
        , '佐賀県'   => 130.29889, '長崎県'   => 129.87361, '熊本県'   => 130.74167, '大分県'   => 131.6125 , '宮崎県'   => 131.42389
        , '鹿児島県' => 130.55806, '沖縄県'   => 127.68111
    };

	// ▼ 2021.11.10 LINE連携対応より、拡張子とMIME情報を追加
	/** 拡張子 */
	public static final String EXTENSION_MP4	=	'mp4';
	public static final String EXTENSION_MOV	=	'mov';
	public static final String EXTENSION_JPG	=	'jpg';
	public static final String EXTENSION_JPEG	=	'jpeg';
	public static final String EXTENSION_PNG	=	'png';
	public static final String EXTENSION_HEIC	=	'heic';
	public static final String EXTENSION_HEIF	=	'heif';
	public static final String EXTENSION_TXT	=	'txt';
	public static final String EXTENSION_CSV	=	'csv';
	public static final String EXTENSION_PDF	=	'pdf';
	public static final String EXTENSION_XLS	=	'xls';
	public static final String EXTENSION_XLSX	=	'xlsx';
	public static final String EXTENSION_PPT	=	'ppt';
	public static final String EXTENSION_PPTX	=	'pptx';
	public static final String EXTENSION_DOC	=	'doc';
	public static final String EXTENSION_DOCX	=	'docx';

	/** MIMEマップ（key:拡張子、value:MIME） */
	public static final Map<String, String> MIME_MAP = new Map<String, String>{
		EXTENSION_MP4	=>	'video/mp4',
		EXTENSION_MOV	=>	'video/quicktime',
		EXTENSION_JPG	=>	'image/jpeg',
		EXTENSION_JPEG	=>	'image/jpeg',
		EXTENSION_PNG	=>	'image/png',
		EXTENSION_HEIC	=>	'image/heic',
		EXTENSION_HEIF	=>	'image/heic',
		EXTENSION_TXT	=>	'text/plain',
		EXTENSION_CSV	=>	'text/csv',
		EXTENSION_PDF	=>	'application/pdf',
		EXTENSION_XLS	=>	'application/vnd.ms-excel',
		EXTENSION_XLSX	=>	'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
		EXTENSION_PPT	=>	'application/vnd.ms-powerpoint',
		EXTENSION_PPTX	=>	'application/vnd.openxmlformats-officedocument.presentationml.presentation',
		EXTENSION_DOC	=>	'application/msword',
		EXTENSION_DOCX	=>	'application/vnd.openxmlformats-officedocument.wordprocessingml.document'		
	};
	// ▲ 2021.11.10

    /** クラッドコード */
    public static final String CRUD_CD_CREATE = 'C';
    public static final String CRUD_CD_READ   = 'R';
    public static final String CRUD_CD_UPDATE = 'U';
    public static final String CRUD_CD_DELETE = 'D';

    /** 業者プラン一括変更画面 */
    public static final String SUPPLIER_PLAN_BULK_CHG_PLAN = 'プラン';
    public static final String SUPPLIER_PLAN_BULK_CHG_ITEM = '商品';

    //▼問合せNo0536で追加
    /** 選択リスト 引越時期 */
    public static final String HOME_MOVING_SEASON_TURNKEY = '即入居';
    public static final String HOME_MOVING_SEASON_OTHER   = 'その他';
    //▲問合せNo0536で追加

    /** ダミー物件情報 */
    public static final String DUMMY_PROP_NAME          = '99999';
    public static final String DUMMY_PROP_MAINT_PROP_CD = '手動登録';

    /** 明細セクションスタイル */
    public static final String OPEN_SECTION_ICON = 'open';
    public static final String SECTION_NONE      = 'display: none;';

	/** 内部バッチ実行数 */
	public static final Integer DATA_CAPACITY_MAINTENANCE_BATCHSIZE = 200;	// データ容量削除バッチ実行数_2021.12.20 No.437 対応で追加

	// ▼ 2022.01.28 LINE連携対応より、追加
	/** ポータルサイトURL */
	public static final String PORTAL_SITE_URL_DETAIL = SystemConfig__c.getInstance().PortalSiteURL__c + 'detail'; // 詳細画面
	// ▲ 2022.01.28
	// ▼ 2022.01.29 LINE連携対応より、追加
    public static final String LINE_EXCLUSIVE_JS_BREAK_CD   = '{LINE専用改行コード}';
    // ▲ 2022.01.29

	// ▼ 2022.03.11 No0515 定数追加
	/** 選択リスト　自動追客メールテンプレート　送信対象 */
	public static final String PURSUIT_SEND_TARGET_WHOLE_COMPANY = '全社共通';
	public static final String PURSUIT_SEND_TARGET_SHOP = '店舗';
	// ▲ 2022.03.11 No0515 定数追加

    /**--------------------------------------------------------- メッセージコード（ここから） ---------------------------------------------------------*/
    public static final String MSG_COM_W_INPUT_LENGTH_OR_MORE = '{0}は{1}文字以上入力してください。';
    public static final String MSG_COM_W_SELECTION_OR_MORE = '{0}は{1}個以上選択してください。';
    public static final String MSG_COM_W_SELECTION_OR_LESS = '{0}は{1}個以内で選択してください。';
    public static final String MSG_COM_W_SELECTION_DUPLICATE = '選択済のデータが確認されました。選択対象のご確認をお願いします。';
    public static final String MSG_COM_W_SEARCH_DATE_TERM = '終了日に開始日より前の日付が設定されています。終了日は開始日以降を設定してください。';
    public static final String MSG_COM_V_NON_AUTHORITY = '権限がありません。';
    public static final String MSG_COM_W_TOTAL_RATE = '{0}の合計が100%になるように入力してください。';
    public static final String MSG_COM_V_NO_SELECTION = '{0}の選択がありませんがよろしいですか？';
    public static final String MSG_COM_W_SEARCH_NO_CONDITIONS = '検索条件を入力してください。';
    public static final String MSG_COM_W_SEARCH_RESULT_LIMIT_OVER = '該当データが最大取得可能件数を超過しています。検索条件を絞り込み、再度検索を実行頂きますようお願いします。';
    public static final String MSG_COM_W_SEARCH_NO_DATA = '該当データが存在しません。';
    public static final String MSG_COM_V_DELETE = '削除します。よろしいですか？';
    public static final String MSG_COM_V_SAVE = '保存します。よろしいですか？';
    public static final String MSG_COM_I_SAVE = '保存が完了しました。';
    public static final String MSG_COM_I_DELETE = '削除が完了しました。';
    public static final String MSG_COM_V_OUTPUT = '出力します。よろしいですか？';
    public static final String MSG_COM_V_EXECUTE_MERGE = '名寄せを実施します。よろしいですか？';
    public static final String MSG_COM_W_EXECUTE_MERGE = '電話番号、またはメールに空き項目が存在しない為、名寄せが実施できません。';
    public static final String MSG_COM_I_MERGE_END = '名寄せが完了しました。';
    public static final String MSG_COM_V_EXECUTE_NON_MERGE = '名寄せ不要に更新します。よろしいですか？';
    public static final String MSG_COM_I_NON_MERGE_END = '名寄せ不要で更新しました。';
    public static final String MSG_COM_V_SENDMAIL = 'メール送信します。よろしいですか？';
    public static final String MSG_COM_I_SENDMAIL = 'メール送信が完了しました。';
    public static final String MSG_COM_E_SENDMAIL = 'メール送信に失敗しました。';
    public static final String MSG_COM_V_SENDMAIL_SCHEDULE = '{0}にメール送信します。よろしいですか？';
    public static final String MSG_COM_V_EXECUTE_SENDMAIL_SCHEDULE = '送信の時間指定が設定されています。設定されてた時間ではなく、即時送信を実施してよろしいですか？';
    public static final String MSG_COM_W_SELECTION_IMAGE_FILETYPE = '画像以外のファイルが選択されています。画像ファイルを選択してください。';
    public static final String MSG_COM_W_INPUT = '{0}は{1}を入力してください。';
    public static final String MSG_COM_W_SELECTION = '{0}は{1}を選択してください。';
    public static final String MSG_COM_W_REQUIRED = '{0}は入力必須です。';
    public static final String MSG_COM_W_EXISTENCE = '{0}は既に存在します。';
    public static final String MSG_COM_W_CANNOT_DELETE_LINKED = '{0}に紐づいているため、削除できません。';
    public static final String MSG_COM_V_UPDATE = '{0}更新します。よろしいですか？';
    public static final String MSG_COM_V_REGISTRATION = '{0}登録します。よろしいですか？';
    public static final String MSG_COM_E_REGISTRATION_ROHIBITED_TERMS = '禁止用語{0}が含まれています。入力内容を変更してください。';
    public static final String MSG_COM_W_REGISTRATION_AMOUNT_SETTING = '下限金額に上限金額以上の金額が設定されています。下限金額は上限金額以下の金額を設定してください。';
    public static final String MSG_COM_E_REGISTRATION_PLURAL_SELECTION = '{0}、{1}はいずれか１つだけ選択してください。';
    public static final String MSG_COM_E_REGISTRATION_MULTI_SELECTION = '{0}はいずれか１つだけ選択してください。';
    public static final String MSG_COM_V_BULKREGISTRATION = '一括確認を行います。よろしいですか？';
    public static final String MSG_COM_I_SAVE_CANCEL = '{0}キャンセルします。よろしいですか？';
    public static final String MSG_COM_I_SAVE_CANCEL_COMPLATED = 'キャンセルしました。';
    public static final String MSG_USER_E_SAVE_SHOP_TERM_DUPLICATE = '同一の店舗名でシステム使用期間が重複したレコードが存在するため、保存できません。';
    public static final String MSG_CUST_I_NOTICE_MERGE = '【Attention】 氏名・メールアドレス・電話番号のいずれか、または全てが一致するお客様情報が存在します。　「名寄せ」　を実施してください。';
    public static final String MSG_CUST_V_EXECUTE_CUSTOMER_LINKING = 'お客様紐付けを行います。よろしいですか？';
    public static final String MSG_CUST_V_EXECUTE_CLIENT_LINKING = '業者紐付けを行います。よろしいですか？';
	// ▼2022.01.18 LINE連携より、追加
	public static final String MSG_CUST_V_EXECUTE_ACCOUNT_LINKING = '取引先との紐づけを行います。よろしいですか？'; 
	public static final String MSG_CUST_V_EXECUTE_ACCOUNT_REGISTER_LINKING = '取引先の登録と紐づけを行います。よろしいですか？';
	public static final String MSG_CUST_I_EXECUTE_LINKING_ACCOUNTS_END = '紐づけされた取引先には、対応が複数存在します。';
	// ▼ 2022.2.15 LINE連携より、仕様変更で未使用となった項目を削除
	// ▲ 2022.2.15
	public static final String MSG_CUST_I_EXECUTE_ACCOUNT_LINKING_END = '取引先と紐づけされました。';
	// ▲2022.01.18
	public static final String MSG_CUST_E_ALREADY_LINKING_LINE_MEMBER = '既に紐づけが完了しているLINE会員です。'; // 2022.1.29 LINE連携対応より、追加
    public static final String MSG_CUST_I_EXECUTE_LINKING_END = '紐付けが完了しました。';
    public static final String MSG_CUST_W_SELECTION_LINKING_ACCOUNT_NUMBER = 'お客様紐付けを行う取引先の選択は１件にしてください。';
    public static final String MSG_REPORT_V_EXECUTE_CALC = '再計算を実施します。よろしいですか？';
    public static final String MSG_PROP_V_EXECUTE_FACILITY_IMPORT = '周辺施設を取り込みます。よろしいですか？';
    public static final String MSG_PROP_I_FACILITY_IMPORT_END = '周辺施設の取り込みが完了しました。';
    public static final String MSG_PROP_W_SELECTION_MERGE_PROPERTY_NUMBER = '名寄せを行う物件の選択は２件にしてください。';
    public static final String MSG_PROP_V_REACQUISITION_SURROUNDING_INFO = '学校、周辺施設、路線の情報を再取得します。よろしいですか？';
    public static final String MSG_PROP_E_SAVE_ADDRESS_MASTER_NOT_EXIST = '入力された住所がマスタに存在しません。住所選択補助画面より住所を選択してください。';
    public static final String MSG_PROP_E_SELECTION_PORTALSITE_POSTING_ANYONE = '各ポータルサイトの『物件名表示』『非表示』のいずれか一つを選択してください。';
    public static final String MSG_PROP_E_SELECTION_PORTALSITE_POSTING_CHOOSE = '全ての店舗の掲載方法を選択してください。';
    public static final String MSG_PROP_E_PANORAMA_POSTING = 'パノラマ掲載先と掲載先のチェックを確認してください。';
	public static final String MSG_PROP_E_BROKERAGEFEE_RATE = '報酬負担貸主と報酬負担借主の合計が100を超えないように入力にしてください。'; // 2022.02.02 No.0676 対応で追加
    public static final String MSG_PROP_I_DUPLICATE_ECHO = '【Attention】対応状況に集約を必要とする内容が含まれています、「反響集約」してください。';
    public static final String MSG_COM_W_OPTIMISTIC_LOCK = '他の処理で登録・更新されました。画面を更新してください。';
    public static final String MSG_COM_E_SYSTEM_PARAMETER = 'パラメータが不正です。システム管理者にお問い合わせください。';
    public static final String MSG_COM_E_SYSTEM_EXCEPTION = '処理中に以下のエラーが発生しました。システム管理者にお問い合わせください。{0}';
    public static final String MSG_COM_I_MERGE_HISTORY = '{0}に{1}を名寄せしました。';
    public static final String MSG_COM_I_MERGE_HISTORY_BUILDING = '{0}に{1}を名寄せしました。メンテナンス建物コード:{2}を{3}へ変更しました。';
    public static final String MSG_COM_I_MERGE_HISTORY_PROPERTY = '{0}に{1}を名寄せしました。メンテナンス物件コード:{2}を{3}へ変更しました。';
    public static final String MSG_COM_E_NOTICE_USED = '既に使用されているため、削除できません。';
    public static final String MSG_COM_E_EXECUTE_PRESS = '{0}ボタンを押下してください。';
    public static final String MSG_COM_E_NOTICE_SAVE = '内容が変更されています、先に{0}ボタンを押下してください。';
    public static final String MSG_COM_E_NOT_SELECTION = '{0}はいずれか片方のみを設定してください。';
    public static final String MSG_PROP_E_INPUT_ACCOUNT_NOTHING = '取引先{0}が「管理会社」「オーナー」「サブリース」の元付業者として取引先に登録されていません。取引先の登録を再確認してください。';
    public static final String MSG_CUST_I_ECHO_INTEGRATION = '{0}を集約しますがよろしいでしょうか';
    public static final String MSG_CUST_I_UNNECESSARY_ECHO_INTEGRATION = '反響集約不要に更新します。よろしいですか？';
    public static final String MSG_COM_I_CANCEL_CONFIRMATION = '変更内容は保存されていません、{0}してよろしいでしょうか';
    public static final String MSG_COM_E_REGISTRATION_ROHIBITED_TERMS_MULTI = '{0}に、禁止用語{1}が含まれています。入力内容を変更してください。';
    public static final String MSG_COM_E_REGISTRATION_COUNT_RANGE = '{0}の値が範囲外となります。{1}以上{2}以下となるように設定ください';
    public static final String MSG_COM_E_MAILADDRESS_VALIDATION = '{0}に含まれる\'@\'の数は1つである必要があります。';
    public static final String MSG_COM_E_GET_AFFILIATION_SHOP = '所属店舗の取得に失敗しました。システム管理者に連絡してください。';
    public static final String MSG_PROP_E_FEE_LIMIT_OVER = '{0}の金額が最大桁数を超過しています。';
    public static final String MSG_PROP_I_MAINTENANCE_COMPLETED = 'メンテナンスを完了状態にします。よろしいですか?';
    public static final String MSG_CUST_I_EXECUTE_APPLICATION_OPEN = '対象物件を反映しました。続けて申込画面を開きますか？';
    public static final String MSG_CUST_I_REGISTRATION_PROPERTY_REFLECTION = '対象物件を反映しました。';
    public static final String MSG_CUST_E_REGISTRATION_DATETIME = '{0}は日付として認識できませんでした。';
    public static final String MSG_CUST_E_REGISTRATION_EVENT_DUPLICATE = '入力された日付がスケジュールと重複しています。';
    public static final String MSG_CUST_E_REGISTRATION_TWOREQUIRED = '{0}が入力されている場合、{1}を必ず入力してください。';
    public static final String MSG_PROP_E_REQUIRED_ROOMLAYOUT = 'web公開には間取り図の登録が必要です。';
    public static final String MSG_COM_E_FILESELECT_MULTIPLE   = '複数ファイルが選択されました。単一ファイルを選択してください。';
    public static final String MSG_COM_E_FILEEXTENSION_NON_JPG = 'ファイルの拡張子が不正です。jpg / jpegファイルを選択してください。';
    public static final String MSG_COM_E_FILEUPLOAD_CONTAIN = 'アップロードに失敗したファイルが存在します。システム管理者に連絡してください。';
    public static final String MSG_COM_E_FILEUPLOAD_ALL     = 'ファイルのアップロードに失敗しました。システム管理者に連絡してください。';
    public static final String MSG_COM_E_CASE_CANNOT_INPUT = '{0}の場合、{1}は入力できません。';
    public static final String MSG_COM_E_CASE_CANNOT_SELECT = '{0}の場合、{1}は選択できません。';
    public static final String MSG_COM_E_LOWER_LIMIT = '{0}には、{1}以上を入力してください。';
    public static final String MSG_PROP_E_TEMPSAVE_WEBPUBLISHING = '{0}ではWEB公開をすることができません。'; //2022/05/09  問合せNo.0809対応
    public static final String MSG_PROP_E_SURROUNDING_ASYNCHRONOUS_ERROR_WAIT = '現在非同期で周辺情報を取得中です。時間をおいて画面を開きなおしてください。';
    public static final String MSG_COM_W_LOWER_BOUND_EXCEED = '{0}は{1}を超えた値を入力できません。';
    public static final String MSG_COM_W_NO_SELECTION = '{0}を選択してください。';
    public static final String MSG_COM_I_REGISTRATION = '{0}様、登録ありがとうございました。　このままの状態でスタッフにお渡しください。';
    public static final String MSG_PROP_E_BUILDING_NO_WEBCOOPERATIONAVALIABLE = '建物情報にweb公開に必要な情報が不足しています。';
    public static final String MSG_PROP_W_INPUT_POSTINGDISTRICT_UPPERLIMIT = '掲載地区は、店舗および地区に紐つく物件を全て更新するため、チェック毎に登録ボタンを押下してください。';
    public static final String MSG_COM_I_RESPONSE_CONFIRMATION = '確認しました。';
    public static final String MSG_COM_I_NO_RESPONSE_CONFIRMATION = '担当者が決まっていない、もしくはご担当ではないため対応確認できません。';
    public static final String MSG_PROP_I_IMPORT_END = '取り込みが完了しました。';
    public static final String MSG_COM_W_SENDPALNDATETIME_OLD = '送信予定日時には未来の日時を入力してください。';
    public static final String MSG_PROP_I_PROPERTY_LINKING_COMPLETED_MULTIPLE = '物件を紐づけました。続けて処理を行う場合対応を1件選択して行ってください。';
    public static final String MSG_PROP_I_PROPERTY_LINKING_COMPLETED = '物件を紐づけました。続けて申込を行いますか？';
    public static final String MSG_PROP_I_PROPERTY_LINKING = '物件の紐づけを行います。よろしいですか？';
    public static final String MSG_PROP_E_PROPERTY_LINKING_RESIDENCE = '居住中の物件が選択されています。居住中となっている物件は申込できません。';
    public static final String MSG_COM_E_NOTICE_DELETED = 'すでに削除されています。';
    public static final String MSG_COM_E_NOTICE_USED_CANNOT_DELETED = 'このデータは使用されているため、削除できません。';
    public static final String MSG_COM_E_NOTICE_MAX_COUNT_OVER = '該当データが最大取得可能件数を超過しています。';
    public static final String MSG_CUST_W_EXECUTE_LINKING_MAILADDRESSANDTEL = '紐付け先の{0}に空き項目が存在しない為、紐付けが実施できません。紐付け先の{0}を整理したのちに紐付けを行ってください。';
    public static final String MSG_PROP_E_NOTICE_PERSONNEL_UNCONFIGURED = '担当者を設定してください。';
    public static final String MSG_USER_E_SAVE_TERM_DUPLICATE = 'システム使用期間が重複したレコードが存在するため、保存できません。';
    public static final String MSG_USER_E_DELETE_DURING_TERM = 'システム使用期間中のレコードは削除できません。';
    public static final String MSG_PROP_W_USED_PROPERTY_CANNOT_MERGE = 'この物件はポータルサイト掲載中の物件です。';
    public static final String MSG_COM_I_BULKREGISTRATION = '{0}件の一括確認を行いました。引き続き一括確認を行ってください。';
    public static final String MSG_COM_I_PORTALDELETE = '{0}件のポータル連携物件を削除しました。引き続き処理を行ってください。';
    public static final String MSG_COM_I_PORTALINSERT = '{0}件のポータル連携物件を登録しました。引き続き処理を行ってください。';
    public static final String MSG_COM_V_RELEASEHOLD = '保留解除しますか？';
    public static final String MSG_COM_E_LOGGING_DIFFERENT_USER = 'スタッフ{0}でログインしています。ログアウト後に再度QRコードをスキャンしてください。';
    public static final String MSG_COM_E_USER_DISABLED_APPOINTMENTS = 'アポイント確定が行えませんでした、確定するユーザが無効となっています。';
    public static final STring MSG_PROP_E_AUTOMAINTE_NONEBUILDING   = '建物情報が存在しない新規物件が連携されました。';
    public static final STring MSG_CUST_E_SET_PROPERTY = '既に他の対応で物件が紐づいているため紐づけできません。';
    public static final String MSG_COM_I_PROPERTYBULKUPDATE = '{0}件の物件更新を行いました。引き続き名寄せを行ってください。';
    public static final String MSG_COM_I_PROPERTY_SAVE_BULKUPDATE = '{0}を使用している物件を{1}件更新しました。続けて保存ボタンを押下してください。';
    public static final String MSG_COM_W_PROPERTYSETTING_REQUIRED = '{0}で{1}が設定されています。{2}を設定してください。';
    public static final String MSG_CUST_I_ECHO_AGGREGATION_END = '{0}の対応を{1}の対応に集約しました。';
    public static final String MSG_PROP_I_NOTICE_WEBPUBLISHING_NO = '名寄せによって、Web公開が『' + PROPERTY_WEBPUBLISHING_NO + '』に変更されました。物件のメンテナンスを行ってください。'; // web公開の固定文言「しない」を使用
    public static final String MSG_PROP_I_BIKEPARKING_NOT_ALLRENTFEE = 'バイク置場の料金は上記、総賃料に含まれておりません。';
    public static final String MSG_PROP_W_BYTE = '部屋番号の文字サイズが超過しています。全角3バイト、半角1バイトとして、10バイト以下にしてください';
    public static final String MSG_PROP_I_NOTICE_UPDATE = '{0}の更新がありました。';
    public static final String MSG_PROP_I_NOTICE_UPDATE_PARAM = '{0}変更：{1}→{2}';
    public static final String MSG_CUST_E_REGISTRATION_TIME_DUPLICATE = '{0}と{1}の日時が重複しています。';
    public static final String MSG_ACC_I_TRADER_REGIST_SEND_MAIL = 'ポータル掲載設定が変更されました。' + BREAK_TAG + '管理物件の掲載先を変更します。完了後にメールが送信されます。';
    public static final String MSG_ACC_I_TRADER_REGIST_MAIL_SUBJECT = '掲載先の変更が完了しました';
    public static final String MSG_ACC_I_TRADER_REGIST_MAIL_TEXT_BODY = '元付業者  {0}' + BREAK_CODE + '管理物件の掲載先を変更しました。';
    public static final String MSG_ACC_W_SEND_MAIL_LIMIT_SUBJECT = 'メールの送信件数が4000件を超えました';
    public static final String MSG_ACC_W_SEND_MAIL_LIMIT_TEXT_BODY = 'メールの送信件数が4000件を超えました。' + CommonConst.BREAK_CODE + 'Salesforceで1 日にメールを送信できるのは 5,000 件までです。' + CommonConst.BREAK_CODE + '上限に達する前に、対応方法をご検討ください。';
    //問合せNo341で追加
    public static final String MSG_ACC_W_SITUATION_ECHO_TELEPHONE = '【Attention】状況で' + CORRESPONDDETAIL_PHONESTATUS_ECHO + 'が選択されています。反響担当者を設定し、' + CORRESPONDDETAIL_PHONESTATUS_ECHO + 'を登録してください。';
    public static final String MSG_ACC_W_TEL_SENDER = '状況で' + CORRESPONDDETAIL_PHONESTATUS_ECHO + 'が選択されています。' + CORRESPONDDETAIL_PHONESTATUS_ECHO + 'を登録してください。';
    public static final String MSG_COM_V_DELETE_IMAGE = '{0}の写真を全て削除します、よろしいですか？'; //問合せNo0345で追加
    public static final String MSG_COM_W_NO_SELECTED = '{0}を選択してください。';
    public static final String MSG_PROP_W_UPD_LIMIT_OVER = '更新可能上限に達しました。' + BREAK_TAG + '一度更新を行ってください。';
    public static final String MSG_COM_I_UPD = '{0}を更新しました。';
    public static final String MSG_PROP_I_PROP_CAN_INTRODUCE = '物件が紹介可能になりました。' + LINE_FEED + '物件：{0} {1}';
    // 問合せNo411で追加
    public static final String MSG_ACC_W_SITUATION_ECHO_LINE = '【Attention】状況で' + CORRESPONDDETAIL_PHONESTATUS_LINEECHO + 'が選択されています。反響担当者を設定し、' + CORRESPONDDETAIL_PHONESTATUS_LINEECHO + 'を登録してください。';
    public static final String MSG_ACC_W_LINE_SENDER = '状況で' + CORRESPONDDETAIL_PHONESTATUS_LINEECHO + 'が選択されています。' + CORRESPONDDETAIL_PHONESTATUS_LINEECHO + 'を登録してください。';
    public static final String MSG_ACC_W_SITUATION_ECHO_LIVERO = '【Attention】状況で' + CORRESPONDDETAIL_PHONESTATUS_LIVEROECHO + 'が選択されています。反響担当者を設定し、' + CORRESPONDDETAIL_PHONESTATUS_LIVEROECHO + 'を登録してください。';
    public static final String MSG_ACC_W_LIVERO_SENDER = '状況で' + CORRESPONDDETAIL_PHONESTATUS_LIVEROECHO + 'が選択されています。' + CORRESPONDDETAIL_PHONESTATUS_LIVEROECHO + 'を登録してください。';
    // 問合せNo278で追加
    public static final String MSG_COM_E_INPORT_DESTINATION_CAN_NOT_CHANGE = '取込先は{0}に変更できません。';
    // 問合せNo0449で追加
    public static final String MSG_ACC_E_RECEIVE_MAIL_ERROR = 'メールサービス処理でエラーが発生しました。';
    // 問合せNo0374で追加
    public static final String MSG_PROP_I_NOTICE_DELETE_RECOMMEND = '名寄せによって、おすすめ物件が削除されました。物件のメンテナンスを行ってください。';
    // 問合せNo0491で追加　問合せNo0549で変更
    public static final String MSG_PROP_I_ROOMLAYOUT_AUTOANALYSIS = '間取り図のAI解析を使用しますか？';
    //問合せNo0403で追加
    public static final String MSG_COM_I_UNLISTED_SITE_MSG_OF_SHOP = 'この店舗は、{0}の掲載を行っておりません。';
    // 問合せNo0496で追加
    public static final String MSG_CUST_I_PROVISIONALQUOTE_FREE_NOT_INPUT = '{0}は{1}が入力されている場合、{2}も入力してください。';
    public static final String MSG_COM_E_PROCESS = '{0}でエラーが発生しました。';
    public static final String MSG_COM_I_PROPERTY_BULK_CHG = '物件に紐づいている{0}の一括変更を行います。よろしいですか？';
    public static final String MSG_COM_I_EMAIL_AFTER_PROCESSING = '{0}を実施中です。' + BREAK_TAG + '完了後にメールが送信されます。';
    public static final String MSG_PROP_I_PROCESS_END = '{0}が完了しました。';
    public static final String MSG_PROP_W_EXISTS_MAINT_PROP_HIST = 'この建物に紐付く物件に自動メンテナンスコードが存在する物件が存在します。' + BREAK_TAG
                                                                 + 'メンテナンスコードを削除しない場合は対象物件が自動メンテされた際に新規で建物が作成されます。' + BREAK_TAG
                                                                 + '必要に応じてメンテナンスコードの削除を行ってください。';
	// ▼ 2021.11.10 LINE連携対応による追加
	public static final String MSG_COM_I_SEND_CONFIRM				= '{0}を送信します。よろしいですか？';
	public static final String MSG_COM_I_SEND_COMPLETED				= '{0}を送信しました。';
	public static final String MSG_ACC_I_RELEASE_LINKING_CONFIRM	= '取引先との紐づけを解除します。よろしいですか？';
	public static final String MSG_COM_E_NOT_SET_CONFIG				= '{0}が設定されていません。システム管理者にお問い合わせください。';
	public static final String MSG_CON_E_XML_HTTP_REQUEST			= 'XMLHttpRequestに失敗しました。ステータス:{0}';
	public static final String MSG_ACC_E_NOT_MOVE_LINE_EXCLUSIVE	= 'LINE会員ではない為、LINE専用画面を開けません。';
	public static final String MSG_COM_E_CANT_SELECTED_EXTENSION	= 'ファイルの拡張子が不正です。{0}ファイルを選択してください。';
	// ▲ 2021.11.10

    // 問合せNo0566で追加
    public static final String ICON_URL = 'https://{0}.s3.amazonaws.com/{1}/public/salesforce/photo/SurroundingFacilityIcon/';
    /// ▼2021.10.08 No.307 対応で追加
    public static final String MSG_COM_V_ADD_PROPERTYCONDITIONS = '物件条件を追加します。よろしいですか？';
    public static final String MSG_COM_V_DELETE_PROPERTYCONDITIONS = '表示している物件条件を削除します。よろしいですか？';
    public static final String MSG_COM_I_E_NG_PROPERTY_SAMENAME = 'ご入力いただいた物件条件名が既に存在します。';
    public static final String MSG_COM_I_E_NG_PROPERTYCONDITIONSNAME_EMPTY = '物件条件名が未入力です。';

	// ▼ 2022.03.11 No0515 メッセージ追加
	public static final String MSG_MASTER_E_SAVE_NOT_SHOP = '送信対象が店舗のため、店舗は入力必須です。';
	public static final String MSG_MASTER_E_SAVE_TEMPLATE_NOTHING = 'テンプレートの設定がされていない送信回数が存在するため、保存できません。';
	// ▲ 2022.03.11 No0515 メッセージ追加

    //2022.04.12 No.782 問合せNo0782_建物画面の沿線名と駅名の登録について 追加
    public static final String MSG_PROP_E_SAVE_STATION_DUPLICATE = '同一の駅が選択されたため、保存できません。';
    /**--------------------------------------------------------- メッセージコード（ここまで） ---------------------------------------------------------*/
}