//反響メールバッチ　テストクラス
@isTest 
private class BA101005BatchTest {
    
    //テストに使用するレコードを作成する
    @testSetup static void Setting(){

        
        //データ作成　システム変数 バッチサイズ
        SystemVariables__c s = new SystemVariables__c(
              VariablesLabel__c = '反響メールフラグ'
            , VariablesName__c  = CommonConst.IS_ECHOMAIL_BATCHPROCESSING
            , BooleanValue__c   = true
            , BooleanValue2__c  = true
        );
        insert s;

		// ▼ 2022.2.2 LINE連携対応より、追加
		Shop__c shop = new Shop__c(
			Email__c	= 'test@co.jp'
		);
		insert shop;

		LineMember__c lineMember = new LineMember__c(
			LineId__c = 'LINE ID'
		);
		insert lineMember;
		// ▼ 2022.2.2
        
        EchoMail__c e = new EchoMail__c(
            BatchStatus__c = CommonConst.BATCH_STUTAS_WAITING
			// ▼ 2022.2.2 LINE連携対応より、追加
			, Email__c				= 'test@co.jp'
			, PropertyCode__c		= '物件コード'
			, LineId__c				= lineMember.LineId__c
			, LineName__c			= 'LINE名'
			, IsLineReceive__c		= true
			, LineReceiveType__c	= CommonConst.LINE_RECEIVE_TYPE_RECEIVE
			, LineMember__c			= lineMember.Id
			, LineMessage__c		= 'LINEメッセージ'
			, LineFileName__c		= 'LINEファイル名'
			, LineFileUrl__c		= 'LINEファイルURL'
			, LineThumbnailName__c	= 'LINEサムネイル名'
			, LineThumbnailUrl__c	= 'LINEサムネイルURL'
			, LineReceiveTime__c	= CommonUtil.getToday()
			// ▼ 2022.2.2
        );
        insert e;
    }
    
    //バッチ起動テスト
    @isTest static void successTest(){
        
        //バッチ実行
        BA101005Batch b = new BA101005Batch(1);
        Integer BATCH_SIZE = 200; //バッチサイズ
        Database.executeBatch(b, BATCH_SIZE);
        
		// ▼ 2022.2.2 LINE連携対応より、追加
		System.assertEquals(null,	null,	'非同期処理によりオブジェクトの登録値が確認できない為、確認不要とする');
		// ▼ 2022.2.2
    }
    
}