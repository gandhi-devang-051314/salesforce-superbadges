@RestResource(urlMapping='/ProductZoning/*')
global with sharing class ProductZoningService {

    @HttpGet
    global static String getPermissableZone(){
        RestRequest req = RestContext.request;
        String countryCode = req.headers.get('CountryCode');
        String ProductCode = req.params.get('ProductCode');

        if(countryCode == null){
            countryCode = 'US';
        }

        List<Product2> getProductFamilyInfo= [SELECT Id, ProductCode, Family FROM Product2 WHERE ProductCode = :ProductCode];

        if(getProductFamilyInfo.size() == 0){
            return 'ProductCode is missing or doesn\'t exist';
        }

        List<Product_Geo_Mapping__mdt> getPermissableFlyZone = [SELECT Permissible_Fly_Zone__c FROM Product_Geo_Mapping__mdt WHERE Country_Code__c = :countryCode AND Product_Family__c = :getProductFamilyInfo[0].Family];

        if(getPermissableFlyZone.size() == 0){
            return 'Confirm with the local authorities';
        }

        return ''+getPermissableFlyZone[0].Permissible_Fly_Zone__c+' zones only';
    }
}