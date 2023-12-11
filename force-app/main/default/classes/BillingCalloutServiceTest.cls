@isTest
private class BillingCalloutServiceTest {
    
    @TestSetup
    static void makeData(){
        ServiceCredentials__c testToken = new ServiceCredentials__c();
        testToken.Name = 'BillingServiceCredential';
        testToken.Username__c = 'TEST SOAP USER';
        testToken.Password__c = 'TEST SOAP PASSWORD';
        insert testToken;
        
        Account ac = new Account(
            Name = 'TEST SOAP CALL ACCOUNT'
        );
        insert ac;

        Opportunity op = new Opportunity(
            AccountId = ac.Id,
            Name = 'TEST SOAP CALL OPPORTUNITY',
            Type = 'New Project',
            CloseDate = Date.today(),
            StageName = 'Prospecting',
            Amount = 999999999
        );
        insert op;

        Project__c pr = new Project__c();
        pr.Name = 'TEST SOAP CALL PROJECT';
        pr.ProjectRef__c = 'TEST_SOAP_999999999';
        pr.Billable_Amount__c = 999999999;
        pr.Status__c = 'Running';
        pr.Opportunity__c =op.Id;
        insert pr;
    }

    @isTest
    static void testBillingCalloutSuccess(){
        List<Project__c> testProjects = [SELECT Id FROM Project__c WHERE Name = 'TEST SOAP CALL PROJECT'];
        for (Project__c pr : testProjects) {
            pr.Status__c = 'Billable';
        }
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new BillingCalloutServiceMock());
        update testProjects;
        Test.stopTest();

        testProjects = [SELECT Status__c FROM Project__c WHERE Name = 'TEST SOAP CALL PROJECT'];
        System.assertEquals('Billable', testProjects[0].Status__c);
    }

    @isTest
    static void testBillingCalloutFail(){
        List<Project__c> testProjects = [SELECT Id FROM Project__c WHERE Name = 'TEST SOAP CALL PROJECT'];
        for (Project__c pr : testProjects) {
            pr.Status__c = 'Running';
        }
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new BillingCalloutServiceMockFailure());
        update testProjects;
        Test.stopTest();

        testProjects = [SELECT Status__c FROM Project__c WHERE Name = 'TEST SOAP CALL PROJECT'];
        System.assertEquals('Running', testProjects[0].Status__c);
    }
}