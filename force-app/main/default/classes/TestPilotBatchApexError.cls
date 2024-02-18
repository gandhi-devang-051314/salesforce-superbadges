@isTest
private class TestPilotBatchApexError {

    @TestSetup
    static void makeData(){

        Contact c1 = new Contact(
            FirstName = 'Test',
            LastName = 'Pilot 1',
            Pilot_Rating__c = 0
        );

        Contact c2 = new Contact(
            FirstName = 'Test',
            LastName = 'Pilot 2',
            Pilot_Rating__c = 0
        );

        insert new List<Contact>{c1, c2};
        
        Mission__c p1 = new Mission__c(
            Subject__c = 'Test Mission 1',
            Completion_Rating__c = 5, 
            Overall_Rating__c = 4.5, 
            Safety_Incidents__c = 0,
            Status__c = 'Complete', 
            Pilot__c = c1.Id
        );

        Mission__c p2 = new Mission__c(
            Subject__c = 'Test Mission 2',
            Completion_Rating__c = 5, 
            Overall_Rating__c = 4.5, 
            Safety_Incidents__c = 0,
            Status__c = 'Complete', 
            Pilot__c = c2.Id
        );

        insert new List<Mission__c>{p1, p2};
    }

    @isTest
    static void testBatchApex(){ 
        try {
            Test.startTest();
            Database.executeBatch(new PilotRatingBatch());
            Test.getEventBus().deliver();
            Test.stopTest();
        } catch (System.SObjectException e) {} 
        Test.getEventBus().deliver();
        System.assertEquals(2, [SELECT Id FROM Error_Log__c].size());
    }
}