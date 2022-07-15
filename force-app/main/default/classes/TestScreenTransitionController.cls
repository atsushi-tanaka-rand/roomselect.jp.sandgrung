public class TestScreenTransitionController {
	public String[] selectSeni = new String[]{};
    public String param { get; set; }
    public String pageName { get; set; }
	public Boolean isChecked{get;set;}

    //コンストラクタ
    public TestScreenTransitionController(){
        
        //●申込登録　新規画面用（アプリケーション用のテスト）
        //pageName = 'GA103001View';
        //param    = 'accountId=0010T000003qjPjQAI&propertyId=a0N0T000000L7NJUA0';

    }    
    
	public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('画面遷移','画面遷移'));
        options.add(new SelectOption('新規タブ', '新規タブ'));
        options.add(new SelectOption('新規ウィンドウ', '新規ウィンドウ'));
        return options;
    }
        
    public String[] getSelectSeni() {
        return selectSeni;
    }   
    public void setSelectSeni(String[] selectSeni) {
        this.selectSeni = selectSeni;
    }
    


}