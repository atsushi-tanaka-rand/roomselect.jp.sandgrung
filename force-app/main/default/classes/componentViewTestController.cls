public class componentViewTestController {
    public GH201003ParameterClass GH201003Parameter{get; set;}
    public GA104007ParameterClass GA104007Parameter{get; set;}
    public GA102006ParameterClass GA102006Parameter{get; set;}
    public GD101004ParameterClass GD101004Parameter{get; set;}
    public GD101003ParameterClass GD101003Parameter{get; set;}
    public GD301003ParameterClass GD301003Parameter{get; set;}
    public GD301003ParameterClass sekiiatodekesuParameter{get; set;}

    public componentViewTestController(){
        this.GH201003Parameter = new GH201003ParameterClass();
        GH201003Parameter.isShopMode = FALSE;
        //GH201003Parameter.selectedShopOrDistrictList.add('hogehoge');

        this.GA104007Parameter = new GA104007ParameterClass();
        //GA104007Parameter.selectedTrainRoute = [SELECT NAME, ID FROM TrainRoute__c WHERE NAME = 'テスト0001'];
        //GA104007Parameter.selectedTrainRoute = new TrainRoute__c();
        //GA104007Parameter.selectedStation = [SELECT NAME FROM Station__c WHERE TrainRoute__r.NAME = :GA104007Parameter.selectedTrainRoute.NAME];
        //GA104007Parameter.selectedStation.add( new Station__c(Name = 'hogehoge', TrainRoute__c = GA104007Parameter.selectedTrainRoute.ID));

        this.GA102006Parameter = new GA102006ParameterClass();

        this.GD101004Parameter = new GD101004ParameterClass();

        this.GD101003Parameter = new GD101003ParameterClass();

        this.GD301003Parameter = new GD301003ParameterClass();
        
        this.sekiiatodekesuParameter = new GD301003ParameterClass();
    }
    
    public void GH201003FormOpen() {
        GH201003Parameter.isDrawing = true;
        GH201003Parameter.noFirst = true;
    }
    
    public void GH201003FormClose() {
        System.debug('GH201003のモーダルが閉じられました');
    }

    public void GA104007FormOpen() {
        GA104007Parameter.isDrawing = true;
        GA104007Parameter.noFirst = true;
    }

    public void GA104007FormClose() {
        System.debug('GA104007のモーダルが閉じられました');
    }

    public void GA102006FormOpen() {
        //郵便番号検索・住所検索
        GA102006Parameter.isAddressMoster = false;
        GA102006Parameter.isDrawing = true;
        GA102006Parameter.noFirst = true;
    }
    
    public void GA102006FormClose() {
        System.debug('GA102006のモーダルが閉じられました');
    }

    public void GD101004FormOpen() {
        //火災保険会社選択
        GD101004Parameter.isDrawing = true;
        GD101004Parameter.noFirst = true;
    }
    
    public void GD101004FormClose() {
        System.debug('GD101004のモーダルが閉じられました');
    }

    public void GD101003FormOpen() {
        //保証会社選択
        GD101003Parameter.isDrawing = true;
        GD101003Parameter.noFirst = true;
    }
    
    public void GD101003FormClose() {
        System.debug('GD101003のモーダルが閉じられました');
    }

    public void GD301003FormOpen() {
        //業者登録
        GD301003Parameter.isDrawing = true;
        GD301003Parameter.noFirst   = true;

        GD301003Parameter.supplierType = GD301003ParameterClass.SupplierConst.CREDITOR;//業者タイプを選択

        sekiiatodekesuParameter.isDrawing = true;
        sekiiatodekesuParameter.noFirst   = true;

        sekiiatodekesuParameter.supplierType = GD301003ParameterClass.SupplierConst.CREDITOR;//業者タイプを選択
    }
    
    public void GD301003FormClose() {
        System.debug('GD301003のモーダルが閉じられました');
        system.debug('返却されたレコード：'+GD301003Parameter.accountRecord);
    }

}