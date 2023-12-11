@RestResource(urlMapping = '/project/*')
global with sharing class ProjectRESTService {

    @HttpPost
    global static String postProjectData(String ProjectRef, String ProjectName, String OpportunityId, Date StartDate, Date EndDate, Double Amount, String Status){
        SavePoint point = Database.setSavePoint();
        try {
            Project__c pr = new Project__c();
            pr.ProjectRef__c = ProjectRef;
            pr.Name = ProjectName;
            pr.Opportunity__c = OpportunityId;
            pr.Start_Date__c = StartDate;
            pr.End_Date__c = EndDate;
            pr.Billable_Amount__c = Amount;
            pr.Status__c = Status;
            upsert pr;

            Opportunity op = new Opportunity(
                Id = OpportunityId,
                DeliveryInstallationStatus__c = 'In progress'
            );
            update op;

            return 'OK';
        } catch (Exception e) {
            Database.rollback(point);
            return e.getMessage();
        }
    }
}