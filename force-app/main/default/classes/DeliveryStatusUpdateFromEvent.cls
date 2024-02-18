public class DeliveryStatusUpdateFromEvent {

    @AuraEnabled
    public static String statusUpdate(String assetIdentifier, String updatedStatus){
        try {
            if(assetIdentifier != null){
                List<Asset> asset = [SELECT Id, Status, Asset_Identifier__c FROM Asset WHERE Asset_Identifier__c = :assetIdentifier];
                asset[0].Status = updatedStatus;
                update asset;
                return 'Status Updated Successfully for asset identifier'+assetIdentifier;
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}