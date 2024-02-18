global class CredentialVerificationService {

    webservice static String verifyCredential(String lastName, String certificationName){

        if(lastName == null || certificationName == null){
            return 'No record found';
        }

        List<Contact> check = [SELECT Id, (SELECT Id, isActive__c FROM Contact_Certifications__r WHERE Name = :certificationName) FROM Contact WHERE LastName = :lastName];

        if(check.size() == 0 || check == null || check[0].Contact_Certifications__r.size() == 0 || check[0].Contact_Certifications__r == null){
            return 'No record found';
        }
        else{
            if(check[0].Contact_Certifications__r[0].isActive__c == true){
                return 'Valid';
            }
            else{
                return 'Needs Renewal';
            }
        }
    }
}