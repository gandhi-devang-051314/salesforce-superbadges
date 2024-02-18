trigger HandleBatchClassError on BatchApexErrorEvent (after insert) {
    switch on Trigger.operationType {
        when AFTER_INSERT {
            BatchApexErrorHelper.afterInsert(Trigger.New);
        }
    }
}