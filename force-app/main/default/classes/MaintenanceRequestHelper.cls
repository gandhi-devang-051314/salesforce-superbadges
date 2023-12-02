public with sharing class MaintenanceRequestHelper {
    // public static void check(Map<Id, Case> oldMap){
    //     System.debug(oldMap);
    // }

    public static void updateworkOrders(Map<Id, Case> oldRecords, List<Case> updatedRecords){
        Set<Id> validCases = new Set<Id>();

        for (Case c : updatedRecords) {
            if(
                oldRecords.get(c.Id).Status != 'Closed' &&
                c.Status == 'Closed' &&
                (c.Type == 'Repair' || c.Type == 'Routine Maintenance')
            ){
                validCases.add(c.Id);
            }
        }

        if(!validCases.isEmpty()){

            //create Map of CaseId and Min(MaintainCycle) {Case -> Equipment_Maintenance_Item__c -> Equipment__r}
            Map<Id, Decimal> maintenanceCycles = new Map<Id, Decimal>();
            AggregateResult[] ar = [SELECT Maintenance_Request__c, MIN(Equipment__r.Maintenance_Cycle__c)cycle FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c IN :validCases GROUP BY Maintenance_Request__c];

            for(AggregateResult a : ar){
                maintenanceCycles.put((Id)a.get('Maintenance_Request__c'), (Decimal)a.get('cycle'));
            }
            

            //get ClosedCase data and generate New Case list from it
            Map<Id, Case> getClosedCases = new Map<Id, Case>([SELECT Id, Vehicle__c, Equipment__c, Equipment__r.Maintenance_Cycle__c,(SELECT Id,Equipment__c,Quantity__c FROM Equipment_Maintenance_Items__r) 
            FROM Case WHERE Id IN :validCases]);
            List<Case> ClosedCasesToBeInserted = new List<Case>();

            for (Case c : getClosedCases.values()) {
                Case nc = new Case(
                    ParentId = c.Id,
                    Status = 'New',
                    Subject = 'Routine Maintenance',
                    Type = 'Routine Maintenance',
                    Vehicle__c = c.Vehicle__c,
                    Equipment__c = c.Equipment__c,
                    Origin = 'Web',
                    Date_Reported__c = Date.Today(),
                    Date_Due__c = (getClosedCases.containskey(c.Id)) ? Date.Today().addDays((Integer) maintenanceCycles.get(c.Id)) : Date.Today().addDays((Integer) c.Equipment__r.maintenance_Cycle__c)
                );
                ClosedCasesToBeInserted.add(nc);
            }

            //time to insert ClosedCase
            insert ClosedCasesToBeInserted;


            //create equipment_maintenance_items for particular cases
            List<Equipment_Maintenance_Item__c> newEMIs = new List<Equipment_Maintenance_Item__c>();
            for (Case c : ClosedCasesToBeInserted) {
                for (Equipment_Maintenance_Item__c emi : getClosedCases.get(c.ParentId).Equipment_Maintenance_Items__r) {
                    Equipment_Maintenance_Item__c cloneEmi = emi.clone();
                    cloneEmi.Maintenance_Request__c = c.Id;
                    newEMIs.add(cloneEmi);
                }
            }

            //insert equipment_maintenance_items
            insert newEMIs;
        }
    }

}