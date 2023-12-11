public class BillingCalloutService {
    static final ServiceCredentials__c token  = ServiceCredentials__c.getInstance('BillingServiceCredential');

    public static void callBillingService(Map<Id,Project__c> oldProjectRecords, List<Project__c> newProjectRecords){
        List<Project__c> projectsForSync = new List<Project__c>();
        for (Project__c pr : newProjectRecords) {
            if(
                pr.Status__c == 'Billable' && 
                oldProjectRecords.get(pr.Id).Status__c != pr.Status__c
            ){
                projectsForSync.add(pr);
            }
        }

        if (projectsForSync.size() > 0) {
            syncProjectsViaSOAPCall(JSON.serialize(projectsForSync));
        }
    }

    //future method doesn't support the Lists so converting into stringify json...
    @future(callout = true)
    static void syncProjectsViaSOAPCall(String jsonProjects){
        List<Project__c> projects = (List<Project__c>)JSON.deserialize(jsonProjects, List<Project__c>.class); //just to ensure that Test class is work as expected else we can use untyped also...
        List<Project__c> projectsToBeUpdated = new List<Project__c>();

        //invoice and projectToSync is generated from Apex class given by WSDL file... (called that class as BillingServiceProxy)
        for (Project__c pr : projects) {
            //get invoice instance for callout purpose...
            BillingServiceProxy.InvoicesPortSoap11 invoice = new BillingServiceProxy.InvoicesPortSoap11();

            //syncing the changes for SOAP callout and update DML...
            BillingServiceProxy.project projectToSync = new BillingServiceProxy.project();
            projectToSync.projectid = pr.ProjectRef__c;
            projectToSync.billAmount = pr.Billable_Amount__c;
            projectToSync.username = token.Username__c;
            projectToSync.password = token.Password__c;

            String res = invoice.billProject(projectToSync);
            if(res == 'OK'){
                pr.Status__c = 'Billed';
                projectsToBeUpdated.add(pr);
            }

            if(projectsToBeUpdated.size() > 0){
                update projectsToBeUpdated;
            }
        }
    }
}