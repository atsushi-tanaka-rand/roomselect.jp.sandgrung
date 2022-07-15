//物件登録画面 の 文例選択モーダル
public inherited sharing class GA104006Modal2Controller {

    public GA104006Modal2ParameterClass parameter { get; set; } // パラメータ
    public ModalScreenRecord screenRecord { get; set; }         // 画面用の項目

    public Boolean isOpenError { get; set; }        // 画面遷移時のエラーフラグ
    public Boolean hasErrorMessage { get; set; }    // エラーメッセージ保有フラグ

    // 部屋タイプ表示用
    public List<SelectOption> selectFolderList { get; set; }   // フォルダ

    public Boolean isMaxSizeAlert { get; set; } //最大長アラートフラグ
    public String maxSizeAlertMsg {
        get {
            return '【Attention】' + this.parameter.returnItem + 'は' + String.valueOf(this.parameter.returnItemMaxLength) + '文字までです。残りの文字は切捨てられます。' ;
        }
        private set;
    }                                           //最大長アラート

    private static final String BLANK = 'blank'; //空の選択肢表示用

    // ページの初期表示処理実行用
    public Boolean init {
        get {
            if (this.parameter.isDrawing) {
                initAction();
                this.parameter.isDrawing = false;
                return false;
            }
            return true;
        }
    }

    // コンストラクタ
    public GA104006Modal2Controller() {
    }

    // ページの初期表示の具体的な処理
    public void initAction(){
        try{
            // 初期化
            this.isOpenError = false;
            this.hasErrorMessage = false;
            this.isMaxSizeAlert = false;

            // 画面項目を設定
            List<ExampleSentence__c> exampleSentences = selectExampleSentence();
            this.screenRecord = new ModalScreenRecord(exampleSentences);

            // フォルダリストの作成
            this.selectFolderList = new List<SelectOption>();
            this.selectFolderList.add(new SelectOption(BLANK,''));
            for (ExampleSentence__c record : exampleSentences) {
                SelectOption opt = new SelectOption(record.Folder__c, record.Folder__c);
                if (!this.selectFolderList.contains(opt)) {
                    this.selectFolderList.add(opt);
                }
            }

        } catch (Exception e) {
            this.isOpenError = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // 選択ボタン押下時処理
    public void closeModal() {
        try{
            this.hasErrorMessage = false;

            //選択文例をパラメータに格納
            this.parameter.Id = this.screenRecord.selectExampleSentence == BLANK ? null : this.screenRecord.selectExampleSentence;
            this.parameter.exampleSentence  = this.screenRecord.ExampleSentence.get(this.screenRecord.selectExampleSentence);

        } catch (Exception e) {
            this.hasErrorMessage = true; //エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }

    //文例情報取得
    private List<ExampleSentence__c> selectExampleSentence(){
        try {
            List<ExampleSentence__c> exampleSentences = [
                SELECT
                    Id
                    ,Folder__c              // フォルダ
                    ,Name                   // 文例名
                    ,ExampleSentence__c     // 文例内容
                FROM ExampleSentence__c     // 文例
                WHERE
                    Folder__c != null       // フォルダ未設定は参照しない
                AND Folder__c != ''
                AND UsageScreen__c = :CommonConst.EXAMPLESENTENCE_USAGESCREEN_REGISTPROPERTY  //使用画面が物件登録画面
                ORDER BY
                    Folder__c
                    ,Name
            ];
            return exampleSentences;
        } catch(Exception e) {
            //エラー設定
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
        return null;
    }

    // フォルダ変更処理
    public void changeFolder() {
        this.screenRecord.selectExampleSentence
            = this.screenRecord.Folder.get(this.screenRecord.selectFolder)[0].getValue();
            // 最大長警告フラグ初期化
            this.isMaxSizeAlert = false;
    }

    // 文例変更処理
    public void changeExampleSentence() {
        // 最大長警告フラグの設定
        this.isMaxSizeAlert = false;
        if (this.parameter.returnItemMaxLength > 0) {
            if (this.screenRecord.ExampleSentence.get(this.screenRecord.selectExampleSentence).length() > this.parameter.returnItemMaxLength) {
                // 選択した文例文の字列長が上限を超える場合アラート
                this.isMaxSizeAlert = true;
            }
        }
    }

    // 画面表示用クラス
    public class ModalScreenRecord {
        // public List<Id> Id { get; set; }                                // Id
        public Map<String, List<SelectOption>> Folder   { get; set; }   // フォルダ
        public Map<String, String> ExampleSentence      { get; set; }   // 文例内容
        public String selectFolder                      { get; set; }   // 選択フォルダ
        public String selectExampleSentence             { get; set; }   // 選択文例Id
        public ModalScreenRecord(List<ExampleSentence__c> exampleSentences) {
            // 初期化
            // this.Id                     = new List<Id>();
            this.Folder                 = new Map<String, List<SelectOption>>();
            List<SelectOption> initList = new List<SelectOption>();
            initList.add(new SelectOption(BLANK,''));
            this.Folder.put(BLANK, initList);
            this.ExampleSentence        = new Map<String, String>();
            this.ExampleSentence.put(BLANK,'');
            this.selectFolder           = BLANK;
            this.selectExampleSentence  = BLANK;
            // データセット
            for (ExampleSentence__c record : exampleSentences) {
                // フォルダ毎の文例選択リストのMap作成
                List<SelectOption> selectList;
                if (!this.Folder.containsKey(record.Folder__c)) {
                    selectList = new List<SelectOption>();
                    selectList.add(new SelectOption(BLANK, ''));
                } else {
                    selectList = this.Folder.get(record.Folder__c);
                }
                selectList.add(new SelectOption(record.Id, record.Name));
                this.Folder.put(record.Folder__c, selectList);
                // this.Id.add(record.Id);
                this.ExampleSentence.put(record.Id, record.ExampleSentence__c.escapeHtml4().replaceAll('\n', '<br/>'));
            }
        }
    }

}