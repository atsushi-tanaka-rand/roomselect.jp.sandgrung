@isTest 
private class GA202002Test {

    @testSetup static void Setting(){

        School__c testSchool1 = new School__c(
            Name = 'テスト学校1'
            ,City__c = '港区'
            ,Type__c = '中学校'
        );
        School__c testSchool2 = new School__c(
            Name = 'テスト学校2'
            ,City__c = '港区'
            ,Type__c = '小学校'
        );
        List<School__c> testSchool = new List<School__c> {
            testSchool1
            ,testSchool2
        };
        insert testSchool;

    }

    @isTest static void juniorHighSchoolTest() {
        GA202002Controller controller = new GA202002Controller();
        GA202002ParameterClass parameter = new GA202002ParameterClass();
        parameter.juniorHighSchoolArea = '港区';
        parameter.elementarySchoolArea = '港区';
        School__c testSchool1 = new School__c(
            Name = 'テスト学校1'
            ,City__c = '港区'
            ,Type__c = '中学校'
        );
        School__c testSchool2 = new School__c(
            Name = 'テスト学校2'
            ,City__c = '港区'
            ,Type__c = '小学校'
        );
        List<School__c> testSchool = new List<School__c> {
            testSchool1
            ,testSchool2
        };
        insert testSchool;
        parameter.selectedSchool = testSchool;
        Parameter.isDrawing = true;
        Parameter.modalMode = 6;
        controller.Parameter = Parameter;
        controller.getSchool();
    }

    @isTest static void juniorHighSchoolRxceptionTest() {
        GA202002Controller controller = new GA202002Controller();
        GA202002ParameterClass parameter = new GA202002ParameterClass();
        parameter.elementarySchoolArea = '港区';
        School__c testSchool1 = new School__c(
            Name = 'テスト学校1'
            ,City__c = '港区'
            ,Type__c = '中学校'
        );
        School__c testSchool2 = new School__c(
            Name = 'テスト学校2'
            ,City__c = '港区'
            ,Type__c = '小学校'
        );
        List<School__c> testSchool = new List<School__c> {
            testSchool1
            ,testSchool2
        };
        insert testSchool;
        parameter.selectedSchool = testSchool;
        Parameter.isDrawing = true;
        Parameter.modalMode = 6;
        controller.Parameter = Parameter;
        controller.getSchool();
    }

    @isTest static void elementarySchoolTest() {
        GA202002Controller controller = new GA202002Controller();
        GA202002ParameterClass parameter = new GA202002ParameterClass();
        parameter.juniorHighSchoolArea = '港区';
        parameter.elementarySchoolArea = '港区';
        School__c testSchool1 = new School__c(
            Name = 'テスト学校1'
            ,City__c = '港区'
            ,Type__c = '中学校'
        );
        School__c testSchool2 = new School__c(
            Name = 'テスト学校2'
            ,City__c = '港区'
            ,Type__c = '小学校'
        );
        List<School__c> testSchool = new List<School__c> {
            testSchool1
            ,testSchool2
        };
        insert testSchool;
        parameter.selectedSchool = testSchool;
        Parameter.isDrawing = true;
        Parameter.modalMode = 7;
        controller.Parameter = Parameter;
        controller.getSchool();
    }

    @isTest static void ElementarySchoolRxceptionTest() {
        GA202002Controller controller = new GA202002Controller();
        GA202002ParameterClass parameter = new GA202002ParameterClass();
        parameter.juniorHighSchoolArea = '港区';
        School__c testSchool1 = new School__c(
            Name = 'テスト学校1'
            ,City__c = '港区'
            ,Type__c = '中学校'
        );
        School__c testSchool2 = new School__c(
            Name = 'テスト学校2'
            ,City__c = '港区'
            ,Type__c = '小学校'
        );
        List<School__c> testSchool = new List<School__c> {
            testSchool1
            ,testSchool2
        };
        insert testSchool;
        parameter.selectedSchool = testSchool;
        Parameter.isDrawing = true;
        Parameter.modalMode = 7;
        controller.Parameter = Parameter;
        controller.getSchool();
    }

    @isTest static void ModalmodeExceptionTest() {
        GA202002Controller controller = new GA202002Controller();
        GA202002ParameterClass parameter = new GA202002ParameterClass();
        parameter.juniorHighSchoolArea = '港区';
        parameter.elementarySchoolArea = '港区';
        School__c testSchool1 = new School__c(
            Name = 'テスト学校1'
            ,City__c = '港区'
            ,Type__c = '中学校'
        );
        School__c testSchool2 = new School__c(
            Name = 'テスト学校2'
            ,City__c = '港区'
            ,Type__c = '小学校'
        );
        List<School__c> testSchool = new List<School__c> {
            testSchool1
            ,testSchool2
        };
        insert testSchool;
        parameter.selectedSchool = testSchool;
        Parameter.isDrawing = true;
        Parameter.modalMode = 8;
        controller.Parameter = Parameter;
        controller.getSchool();
    }


    @isTest static void settingSelectTest() {
        GA202002Controller controller = new GA202002Controller();
        GA202002ParameterClass parameter = new GA202002ParameterClass();
        parameter.juniorHighSchoolArea = '港区';
        School__c testSchool1 = new School__c(
            Name = 'テスト学校1'
            ,City__c = '港区'
            ,Type__c = '中学校'
        );
        School__c testSchool2 = new School__c(
            Name = 'テスト学校2'
            ,City__c = '港区'
            ,Type__c = '小学校'
        );
        List<School__c> testSchool = new List<School__c> {
            testSchool1
            ,testSchool2
        };
        insert testSchool;
        parameter.selectedSchool = testSchool;
        Parameter.isDrawing = true;
        Parameter.modalMode = 6;
        controller.Parameter = Parameter;
        controller.getSchool();
        controller.settingSelect();
    }

    @isTest static void settingSelectExceptionTest() {
        GA202002Controller controller = new GA202002Controller();
        GA202002ParameterClass parameter = new GA202002ParameterClass();
        parameter.juniorHighSchoolArea = '港区';
        School__c testSchool1 = new School__c(
            Name = 'テスト学校1'
            ,City__c = '港区'
            ,Type__c = '中学校'
        );
        School__c testSchool2 = new School__c(
            Name = 'テスト学校2'
            ,City__c = '港区'
            ,Type__c = '小学校'
        );
        List<School__c> testSchool = new List<School__c> {
            testSchool1
            ,testSchool2
        };
        insert testSchool;
        Parameter.isDrawing = true;
        Parameter.modalMode = 6;
        controller.Parameter = Parameter;
        controller.getSchool();
        controller.settingSelect();
    }

}