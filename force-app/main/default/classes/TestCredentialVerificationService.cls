@isTest
private class TestCredentialVerificationService {

    @TestSetup
    static void makeData(){
        //create contacts
        Contact c1 = new Contact(
            FirstName = 'Test',
            LastName = 'Cert Valid'
        );

        Contact c2 = new Contact(
            FirstName = 'Test',
            LastName = 'Cert Renew'
        );

        insert new List<Contact>{c1 ,c2};

        //create cert
        Certification__c cert = new Certification__c(
            Name = 'Test Cert'
        );

        insert cert;

        //create contact_cert records
        Contact_Certification__c cc1 = new Contact_Certification__c(
            Contact__c = c1.Id,
            Certification__c = cert.Id,
            isActive__c = true,
            Issue_Date__c = Date.today()
        );

        Contact_Certification__c cc2 = new Contact_Certification__c(
            Contact__c = c2.Id,
            Certification__c = cert.Id,
            isActive__c = false,
            Issue_Date__c = Date.today()
        );

        insert new List<Contact_Certification__c>{cc1, cc2};
    }

    @isTest
    static void nullInput(){
        Test.startTest();
        String res = CredentialVerificationService.verifyCredential('null', null);
        Test.stopTest();
        System.assertEquals('No record found', res);
    }

    @isTest
    static void inValidInput(){
        Test.startTest();
        String res = CredentialVerificationService.verifyCredential('cert', 'cert');
        Test.stopTest();
        System.assertEquals('No record found', res);
    }

    @isTest
    static void isRenewal(){
        List<Contact_Certification__c> check = [SELECT Name FROM Contact_Certification__c WHERE Contact__r.LastName = 'Cert Renew'];
        Test.startTest();
        String res = CredentialVerificationService.verifyCredential('Cert Renew', check[0].Name);
        Test.stopTest();
        System.assertEquals('Needs Renewal', res);
    }

    @isTest
    static void isValid(){
        List<Contact_Certification__c> check = [SELECT Name FROM Contact_Certification__c WHERE Contact__r.LastName = 'Cert Valid'];
        Test.startTest();
        String res = CredentialVerificationService.verifyCredential('Cert Valid', check[0].Name);
        Test.stopTest();
        System.assertEquals('Valid', res);
    }
}