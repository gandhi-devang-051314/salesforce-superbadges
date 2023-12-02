trigger MaintenanceRequest on Case (after update) {
    switch on Trigger.OperationType {
        when AFTER_UPDATE {
            // MaintenanceRequestHelper.check(Trigger.oldMap);
            MaintenanceRequestHelper.updateworkOrders(Trigger.oldMap, Trigger.new);
        }
    }
}   