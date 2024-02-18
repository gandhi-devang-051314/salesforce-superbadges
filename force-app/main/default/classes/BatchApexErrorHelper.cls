public with sharing class BatchApexErrorHelper {

    public static void afterInsert(List<BatchApexErrorEvent> batchErrors){
        Set<Id> asyncApexJobIds = new Set<Id>();

        for (BatchApexErrorEvent err : batchErrors) {
            asyncApexJobIds.add(err.AsyncApexJobId);
        }

        Map<Id, AsyncApexJob> apexJobs = new Map<Id, AsyncApexJob>([SELECT Id, ApexClass.Name FROM AsyncApexJob WHERE Id IN :asyncApexJobIds]);

        List<Error_Log__c> errLogs = new List<Error_Log__c>();
        for (BatchApexErrorEvent evt : batchErrors) {
            if(apexJobs.get(evt.AsyncApexJobId).ApexClass.Name == 'PilotRatingBatch'){

                for (String i : evt.JobScope.split(',')) {
                    Error_Log__c errLog = new Error_Log__c();
                    errLog.Async_Apex_Job_Id__c = evt.AsyncApexJobId;
                    errLog.Job_Scope__c = i;
                    errLog.Type__c = evt.ExceptionType;
                    errLog.Stacktrace__c = evt.StackTrace;
                    errLog.Message__c = 'Error Triggerd by PilotRatingBatch Apex';
                    errLogs.add(errLog);
                }
            }
        }

        try {
            insert errLogs;
        } catch (Exception e) {
            System.debug('Error while inserting Error Logs from Trigger!'+e.getMessage());
        }
    }
}