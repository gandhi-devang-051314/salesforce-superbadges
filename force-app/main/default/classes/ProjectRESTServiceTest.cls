@isTest
private class ProjectRESTServiceTest {

    @TestSetup
    static void makeData(){
        Account ac = new Account(
            Name = 'Test REST Account'
        );
        insert ac;

        Opportunity op = new Opportunity(
            AccountId = ac.Id,
            Name = 'Testing REST Op',
            Type = 'Testing REST Project',
            CloseDate = Date.today(),
            StageName = 'Prospecting',
            Amount = 999999999
        );
        insert op;
    }

    @isTest
    static void testProjectRESTServiceFail(){
        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/project';
        RestContext.request = req;

        Test.startTest();
        String res = ProjectRESTService.postProjectData(
            'Test Ref 123', 
            'Test Project', 
            'Testing REST Op', 
            Date.today(), 
            Date.today().addDays(1), 
            110000, 
            'Running'
        );
        Test.stopTest();

        System.assertEquals('Invalid id: Testing REST Op', res);
    }

    @isTest
    static void testProjectRESTServiceSuccess(){
        Opportunity op = [SELECT Id, Name FROM Opportunity WHERE Name = 'Testing REST Op'];
        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/project';
        RestContext.request = req;

        Test.startTest();
        String res = ProjectRESTService.postProjectData(
            'Test Ref 123', 
            'Test Project', 
            op.Id, 
            Date.today(), 
            Date.today().addDays(1), 
            110000, 
            'Running'
        );
        Test.stopTest();

        op = [SELECT DeliveryInstallationStatus__c FROM Opportunity WHERE Id = :op.Id];
        System.assertEquals('In progress', op.DeliveryInstallationStatus__c);
        System.assertEquals('OK', res);
    }
}