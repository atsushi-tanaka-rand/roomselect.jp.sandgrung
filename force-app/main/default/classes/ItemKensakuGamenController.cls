public class  ItemKensakuGamenController{

    public ItemKensakuGamenController(ApexPages.StandardController controller) { } 

    /* 検索結果リスト */
    public List<Product2> results {get;set;}
    /*VisualForceとAPEXをバインドさせるためにget,setを記述*/

    /* 検索条件取得用 */
    public Product2 conditions {get;set;}
    /*VisualForceとAPEXをバインドさせるためにget,setを記述*/
  
    public ItemKensakuGamenController(){
       this.results = new List<Product2>();
       this.conditions = new Product2();
    }
    /* 商品オブジェクトの空の配列を生成 */
    /* 検索条件の空のインスタンスを生成 */

    public void search(){
      try {
          String conditionSql = this.getWhere();
               /* getWhereメソッド（条件）を呼び出し変数conditionSqlni追加*/
          String soql = 
                'SELECT ' 
              + 'Id,Name,Family,ProductCode '
              + 'FROM Product2 ' + conditionSql;
  
              this.results = database.query(soql);
                 /* 変数soql(SELECT文)のクエリ実行し結果を変数resultsに追加 */
  
          } catch(DmlException e) { 
              ApexPages.addMessages(e); 
          } catch(Exception e) {
              ApexPages.addMessages(e);
          }
    }

    private String getWhere() {
       List<String> param = new List<String>();
             /* 空の変数paramを生成 */
       if (this.conditions.Name != null) {
           param.add('Name LIKE \'%' + this.conditions.Name + '%\'');
             /* 名前の条件が空でなければ名前を文字列に追加し変数paramに代入*/
       }
       if (!String.isBlank(this.conditions.Family)) {
           param.add('Family = \'' + this.conditions.Family + '\'');
             /* 商品ファミリーが文字列ではなくかつ空でなければ変数paramに追加 */
       }
       if (this.conditions.ProductCode != null) {
           param.add('ProductCode LIKE \'%' + this.conditions.ProductCode + '%\'');
             /* 商品コードが空でなければ文字列に代入し変数paramに追加 */
       }
       if (param.isEmpty()) {
           return '';
             /* 変数paramが空であれば空白を返す */
       }
       return 'WHERE ' + String.join(param, ' AND ');
          /* 上記のそれぞれの変数paramを’AND’で連結（文字列）して返す */
      }

    public void save(){

    }
  }