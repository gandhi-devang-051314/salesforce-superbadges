public with sharing class ProjectCalloutService {

    @InvocableMethod(label = 'Post Opportunity To PMS')
    public static void PostOpportunityToPMS(List<Id> oppIds){
        if(oppIds.size() > 0){
            Opportunity opp = [SELECT Id, Name, Account.Name, CloseDate, Amount FROM Opportunity WHERE Id = :oppIds[0]];
            String serviceToken = ServiceTokens__c.getValues('ProjectServiceToken').Token__c;
            System.enqueueJob(new QueueablePMSCall(opp, serviceToken));
        }
    }

    class QueueablePMSCall implements Queueable, Database.AllowsCallouts{

        private String serviceToken;
        private String inputData;
        private Id oppId;

        public QueueablePMSCall(Opportunity opp, String serviceToken){
            this.serviceToken = serviceToken;
            this.oppId = opp.Id;
            this.inputData = JSON.serialize(new inputJsonData(opp));
        }

        public void execute(QueueableContext qc){
            PmsRestCall(serviceToken, inputData ,oppId);
        }
    }

    @future(callout = true)
    private static void PmsRestCall(String serviceToken, String inputData, Id oppId){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndPoint('callout:ProjectService');
        req.setMethod('POST');
        req.setHeader('token', serviceToken);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(inputData);

        HttpResponse res = http.send(req);

        Opportunity opp = new Opportunity(Id = oppId);
        if(res.getStatusCode() == 201){
            opp.StageName = 'Submitted Project';
            System.debug('PMS REST callout success for oppId ->'+oppId);
        }
        else{
            opp.StageName = 'Resubmit Project';
            System.debug('PMS REST callout failure for oppId ->'+oppId);
        }
        update opp;
    }

    public class inputJsonData{
        String opportunityId;
        String opportunityName;
        String accountName;
        String closeDate;
  		Decimal amount;

        public inputJsonData(Opportunity opp){
            this.opportunityId = opp.Id;
            this.opportunityName = opp.Name;
            this.accountName = opp.Account.Name;
            this.closeDate = String.ValueOf(opp.CloseDate);
            this.amount = opp.Amount;
        }
    }
}