public with sharing class BoatDataService {

    @AuraEnabled(cacheable=true)
    public static List<BoatType__c> getBoatTypes(){
        try {
            return [SELECT Name, Id FROM BoatType__c WITH SECURITY_ENFORCED ORDER BY Name];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable = true)
    public static List<Boat__c> getBoats(string boatTypeId){
        try {
            if (boatTypeId == '') {
                return [SELECT Name, Description__c, Geolocation__Latitude__s,Geolocation__Longitude__s, BoatType__c, Contact__r.Name, Price__c, Length__c, BoatType__r.Name, Picture__c FROM Boat__c WITH SECURITY_ENFORCED];
            }
            else{
                return [SELECT Name, Description__c, Geolocation__Latitude__s,Geolocation__Longitude__s, BoatType__c, Contact__r.Name, Price__c, Length__c, BoatType__r.Name, Picture__c FROM Boat__c WHERE BoatType__c = :boatTypeId WITH SECURITY_ENFORCED];
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string updateBoatList(Object data){
        try {
            List<Boat__c> updatedBoats = (List<Boat__c>) JSON.deserialize(
                JSON.serialize(data), 
                List<Boat__c>.class
            );
            update updatedBoats;
            return 'Boats updated successfully!';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable = true)
    public static string getBoatsByLocation(Decimal latitude, Decimal longitude, string boatTypeId){
        try {
            String query = 'SELECT Name, Geolocation__Latitude__s, Geolocation__Longitude__s FROM Boat__c ';

            if (String.isNotBlank(boatTypeId)) {
                query += 'WHERE BoatType__c = :boatTypeId ';
            }
            
            query += ' WITH SECURITY_ENFORCED ORDER BY DISTANCE(Geolocation__c, GEOLOCATION(:latitude, :longitude), \'mi\') LIMIT 10';

            return JSON.serialize(Database.query(query));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<BoatReview__c> getAllReviews(Id boatId){
        try {
            return [SELECT Id,Name,Comment__c,Rating__c,LastModifiedDate,CreatedDate,CreatedBy.Name,CreatedBy.SmallPhotoUrl, CreatedBy.CompanyName FROM BoatReview__c WITH SECURITY_ENFORCED];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Boat__c> getSimilarBoats(Id boatId, string similarBy){
        try {
            List<Boat__c> similarBoats = new List<Boat__c>();
            List<Boat__c> parentBoat = [SELECT Id, Length__c, Price__c, BoatType__c, BoatType__r.Name FROM Boat__c WHERE Id = :boatId WITH SECURITY_ENFORCED];

            if(parentBoat.isEmpty()){
                return similarBoats;
            }
            else if(similarBy == 'Length'){
                similarBoats = [SELECT Id, Contact__r.Name, Name, BoatType__c, BoatType__r.Name, Length__c, Price__c, Picture__c, Year_Built__c FROM Boat__c WHERE Id != :parentBoat.get(0).Id AND (Length__c >= :parentBoat.get(0).Length__c / 1.2) AND (Length__c <= :parentBoat.get(0).Length__c * 1.2) WITH SECURITY_ENFORCED];
            }
            else if(similarBy == 'Price'){
                similarBoats = [SELECT Id, Contact__r.Name, Name, BoatType__c, BoatType__r.Name, Length__c, Price__c, Picture__c, Year_Built__c FROM Boat__c WHERE Id != :parentBoat.get(0).Id AND (Price__c >= :parentBoat.get(0).Price__c / 1.2) AND (Price__c <= :parentBoat.get(0).Price__c * 1.2) WITH SECURITY_ENFORCED];
            }
            else if(similarBy == 'Type'){
                similarBoats = [SELECT Id, Contact__r.Name, Name, BoatType__c, BoatType__r.Name, Length__c, Price__c, Picture__c, Year_Built__c FROM Boat__c WHERE Id != :parentBoat.get(0).Id AND BoatType__c = :parentBoat.get(0).BoatType__c WITH SECURITY_ENFORCED];
            }
            return similarBoats;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}