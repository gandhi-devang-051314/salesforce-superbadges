@isTest
private class TestAssetService {

    @TestSetup
    static void makeData(){

        //needed for assets
        Account a = new Account(
            Name = 'Test Account'
        );

        insert a;

        Contact c = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = a.Id
        );

        insert c;

        //assets
        Asset a1 = new Asset(
            Name = 'Test Asset 1',
            Asset_Identifier__c = '99999',
            AccountId = a.Id,
            ContactId = c.Id
        );

        Asset a2 = new Asset(
            Name = 'Test Asset 2',
            Asset_Identifier__c = '98989',
            AccountId = a.Id,
            ContactId = c.Id
        );

        Asset a3 = new Asset(
            Name = 'Test Asset 3',
            Asset_Identifier__c = '97979',
            AccountId = a.Id,
            ContactId = c.Id
        );

        insert new List<Asset>{a1, a2, a3};

        //insurances
        Insurance__c i1 = new Insurance__c(
            Active__c = true,
            Coverage__c = 'Comprehensive',
            Asset__c = a3.Id
        );
        
        Insurance__c i2 = new Insurance__c(
            Active__c = true,
            Coverage__c = 'Comprehensive',
            Asset__c = a1.Id
        );
        
        insert new List<Insurance__c>{i1, i2};

        //claims
        Claim__c c1 = new Claim__c(
            Type__c = 'Loss',
            Asset__c = a1.Id,
            Insurance__c = i2.Id
        );

        insert c1;
    }

    @isTest
    static void nullAssetIdentifier(){
        Test.startTest();
        String res = AssetService.reportLostDevice(null);
        Test.stopTest();
        System.assertEquals('No device found.', res);
    }

    @isTest
    static void notFoundAssetIdentifier(){
        Test.startTest();
        String res = AssetService.reportLostDevice('95678');
        Test.stopTest();
        System.assertEquals('No device found.', res);
    }

    @isTest
    static void alreadyClaimFiled(){
        Test.startTest();
        String res = AssetService.reportLostDevice('99999');
        Test.stopTest();
        List<Claim__c> c = [SELECT Name FROM Claim__c WHERE Asset__r.Asset_Identifier__c = '99999'];
        System.assertEquals(''+c[0].Name+' already filed.', res);
    }

    @isTest
    static void noCoverage(){
        Test.startTest();
        String res = AssetService.reportLostDevice('98989');
        Test.stopTest();
        System.assertEquals('No coverage. Asset status adjusted to Lost.', res);
    }

    @isTest
    static void normalCase(){
        Test.startTest();
        String res = AssetService.reportLostDevice('97979');
        Test.stopTest();
        List<Claim__c> c = [SELECT Name FROM Claim__c WHERE Asset__r.Asset_Identifier__c = '97979'];
        System.assertEquals(1, c.size());
    }
}