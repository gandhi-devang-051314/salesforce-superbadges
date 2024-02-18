@RestResource(urlMapping='/lost/*')
global with sharing class AssetService {

    @HttpPost
    global static String reportLostDevice(String assetIdentifier){

        if(String.isBlank(assetIdentifier)){
            return 'No device found.';
        }

        List<Asset> getAssetStatus = [SELECT Id, Status, (SELECT Id, Active__c, Coverage__c FROM Insurances__r) FROM Asset WHERE Asset_Identifier__c = :assetIdentifier];

        if(getAssetStatus.size() == 0){
            return 'No device found.';
        }

        if(getAssetStatus[0].Status != 'Lost'){
            getAssetStatus[0].Status = 'Lost';
            update getAssetStatus;
        }

        List<Insurance__c> getInsurances = getAssetStatus[0].Insurances__r;

        if(getInsurances.size() == 0){
            return 'No coverage. Asset status adjusted to Lost.';
        }
        else{
            Map<Id, Insurance__c> insuranceMapForId = new Map<Id, Insurance__c>(getInsurances);
    
            List<Claim__c> getLossClaims = [SELECT Id, Name FROM Claim__c WHERE Type__c = 'Loss' AND Asset__c = :getAssetStatus[0].Id AND Insurance__c IN :insuranceMapForId.keySet()];

            if(getLossClaims.size() > 0){
                return getLossClaims[0].Name+' already filed.';
            }

            List<Claim__c> createClaims = new List<Claim__c>();
            for (Insurance__c ins : getInsurances) {
                if(ins.Active__c == true && ins.Coverage__c == 'Comprehensive'){
                    Claim__c c = new Claim__c(
                        Insurance__c = ins.Id,
                        Asset__c = getAssetStatus[0].Id,
                        Type__c = 'Loss',
                        Status__c = 'New'
                    );
                    createClaims.add(c);
                    break;
                }
            }

            if(createClaims.size() > 0 && createClaims != null){
                insert createClaims;
                List<Claim__c> getNewClaimName = [SELECT Name FROM Claim__c WHERE Id = :createClaims[0].Id];
                return getNewClaimName[0].Name;
            }
            else{
                return 'No coverage. Asset status adjusted to Lost.';
            }
        }
    }
}