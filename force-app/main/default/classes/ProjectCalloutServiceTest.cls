@isTest
private class ProjectCalloutServiceTest {

    @TestSetup
    static void makeDataForTesting(){
        ServiceTokens__c token = new ServiceTokens__c();
        token.Name = 'ProjectServiceToken';
        token.Token__c = 'TestToken';
        insert token;

        Account acc = new Account(
            Name = 'Testing Account'
        );
        insert acc;

        Opportunity oppSuccess = new Opportunity(
            AccountId = acc.Id,
            Name = 'Testing OppSuccess',
            Type = 'New Project',
            CloseDate = Date.today(),
            StageName = 'Submitted Project',
            Amount = 999999999
        );
        insert oppSuccess;

        Opportunity oppFailure = new Opportunity(
            AccountId = acc.Id,
            Name = 'Testing OppFailure',
            Type = 'New Project',
            CloseDate = Date.today(),
            StageName = 'Resubmit Project',
            Amount = 999999999
        );
        insert oppFailure;
    }

    @isTest
    static void testPMSCalloutFailure(){
        Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = 'Testing OppFailure' LIMIT 1];
        List<Id> oppIds = new List<Id>();
        oppIds.add(opp.Id);
        
        Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMockFailure());

        Test.startTest();
            ProjectCalloutService.PostOpportunityToPMS(oppIds);
        Test.stopTest();

        opp = [SELECT StageName FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals('Resubmit Project', opp.StageName);
    }

    @isTest
    static void testPMSCalloutSuccess(){
        Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = 'Testing OppSuccess' LIMIT 1];
        List<Id> oppIds = new List<Id>();
        oppIds.add(opp.Id);
        
        Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock());

        Test.startTest();
            ProjectCalloutService.PostOpportunityToPMS(oppIds);
        Test.stopTest();

        opp = [SELECT StageName FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals('Submitted Project', opp.StageName);
    }
}