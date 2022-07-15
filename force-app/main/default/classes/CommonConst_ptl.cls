public class CommonConst_ptl {
    /** 反響メール取込　メールアドレス */
    public static final String EMAIL_PORTAL       = SystemConfig__c.getInstance().EmaiPortal__c;


    /** 選択リスト 本会員　会員状況 */
    public static final String MEMBER_MEMBERSTATU_ADMISSION            = '入会';
    public static final String MEMBER_MEMBERSTATU_WITHDRAWAL           = '退会';
    public static final String CALENDAR_APPOINTMENTRECEIPTMANAGEMENT ='HP来店予約管理';

    /** チェック時文言 ニュースリリース 固定表示フラグ */
    public static final String NEWSRELEASE_FIXEDDISPLAYFLAG_FIXED = '固定';

    /** 選択リスト ニュースリリース 公開状況  */
    public static final String NEWSRELEASE_RELEASESTATUS_PUBLIC  = '公開';
    public static final String NEWSRELEASE_RELEASESTATUS_PRIVATE = '非公開';

    /** 選択リスト ニュースリリース テンプレート  */
    public static final String NEWSRELEASE_TEMPLATE_1       = 'テンプレート１';
    public static final String NEWSRELEASE_TEMPLATE_2       = 'テンプレート２';
    public static final String NEWSRELEASE_TEMPLATE_NOTHING = 'テンプレートなし';

    // ▲ 2022.04.01 No754 カテゴリ選択リストを追加
    /** 選択リスト ニュースリリース カテゴリ  */
    public static final String NEWSRELEASE_NOTICE               = 'お知らせ';
    public static final String NEWSRELEASE_REALESTTECOLUMN      = '不動産コラム';
    public static final String NEWSRELEASE_LOCALINFORMATION     = '地域情報';
    public static final String NEWSRELEASE_EVENTCMPAIGN         = 'イベント・キャンペーン';
    // ▲ 2022.04.01 No754 カテゴリ選択リストを追加
    
    /** 選択リスト　定型文　 使用画面*/
    public static final String FIXEDPHRASE_USAGESCREEN_NEWSRELEASE = 'ニュースリリース';   

    /** 選択リスト　反響メール 自社ポータル用_メール種別*/
    public static final String ECHOMAIL_MAILTYPE_ECHOMAIL = '反響';   
    public static final String ECHOMAIL_MAILTYPE_VISITRESERVATION = '来店予約';   
    public static final String ECHOMAIL_MAILTYPE_VISITRESERVATIONCHANCEL = '来店予約キャンセル';   
    public static final String ECHOMAIL_MAILTYPE_INQUIRY = '問合せ';   

    /** S3画像アップロード共通部品 種別 */
    public static final String S3_PHOTOTYPE_NEWSRELEASE            = 'NEWSRELEASE';
    public static final String S3_PHOTOTYPE_SHOP                   = 'SHOP';

    /** S3画像 アップロード共通部品 写真種別*/
    public static final String S3_PROPERTYPHOTOTYPE_NEWSRELEASE    = 'NEWSIMAGE';  
    
    /** 項目数　各種写真 */
    public static final Integer MAXINDEX_NEWSRELEASE_RELEASE      = 7;   // ニュースリリース．掲載写真枚数  2022.4.1 No754 サムネイル追加するため値を変更（6→7）
    public static final Integer MAXINDEX_SHOP                     = 9;   // 店舗．写真枚数 // 問合せNo0535で変更（外観写真追加分）

    /** おすすめ物件 パノラマツアー登録 */
    public static final String PANORAMA_TOUR_REGISTER_AVAILABLE     = '有';    // 有
    public static final String PANORAMA_TOUR_REGISTER_NOT_AVAILABLE = '無';    // 無

    //追加要望 追加 Start
    /** 取引先 紹介メール配信状況 */
    public static final String INTRODUCTION_SEND     = '配信'; 
    public static final String INTRODUCTION_SENDSTOP = '配信停止'; 
    //追加要望 追加 End

    /**--------------------------------------------------------- メッセージコード（ここから） ---------------------------------------------------------*/
    public static final String MSG_COM_V_BLACKLIST_CHANGE = 'ブラックリストフラグをONにします。該当会員は強制退会となり、今後同一IDでの登録ができなくなりますがよろしいですか？';
    public static final String MSG_COM_V_UPDATE_MEMBER = '会員IDを変更する場合、HP会員は変更前のIDでログインできなくなります。本当に保存してよろしいですか？';
    public static final String MSG_COM_E_MEMBER_TELL_LENGTH = '電話番号は数字のみで{0}～{1}桁で入力してください。';
    public static final String MSG_COM_E_SYSTEM_USEAUTHORITY = 'このページは利用できません。{0}が必要です。';
    public static final String NEWS_E_SAVE_DISPLAY_FLAG_DUPLICATE = '別のニュースリリースで固定表示がされています。';
    public static final String MSG_COM_E_NON_NEWS_PREVIEW_PARAM = 'プレビューボタンを再押下してください。';
    public static final String MSG_COM_E_OPTIONAL_PERMISSION_CHECK = 'この機能は利用できません。{0}が必要です。';
    public static final String MSG_COM_W_SELECTION_ONLY_ONE = '{0}は1件のみ選択してください。';
    public static final String MSG_COM_W_REMOVE_RECOMMENDATION = 'おすすめ物件登録を解除します。よろしいですか？';
    public static final String MSG_COM_I_REMOVE_RECOMMENDATION = 'おすすめ物件登録を解除しました。';
    public static final String MSG_COM_W_SELECTION_REMOVE_RECOMMENDATION = '一度に解除可能な件数は50件までです。';
    public static final String MSG_COM_W_SELECTION_DELETE_RECOMMENDATION = '一度に削除可能な件数は50件までです。';
    public static final String MSG_COM_E_PANORAMATOUR_PRIVATE = '{0}に失敗しました。パノラマツアーを非公開にできませんでした。';
    public static final String MSG_COM_E_PANORAMATOUR_PRIVATE_MULTIPLE = '一部{0}に失敗しました。パノラマツアーを非公開にできませんでした。';

    //追加要望　追加
    public static final String MSG_COM_V_DELETE_SENDMAILSTATUS = '自動追客メールを配信停止し、一覧から削除します。よろしいですか？';
    public static final String MSG_COM_I_DELETE_SENDMAILSTATUS = '自動追客メールを削除しました。';
    public static final String MSG_COM_I_MERGE_END_SENDSTOP = '自動追客を配信停止にしました。';
    //追加要望 追加 End
    /**--------------------------------------------------------- メッセージコード（ここまで） ---------------------------------------------------------*/
}