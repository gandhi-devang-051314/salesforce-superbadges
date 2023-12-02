@isTest
public with sharing class MaintenanceRequestHelperTest {
    private static final string STATUS_NEW = 'New';
    private static final string WORKING = 'Working';
    private static final string CLOSED = 'Closed';
    private static final string REPAIR = 'Repair';
    private static final string REQUEST_ORIGIN = 'Web';
    private static final string REQUEST_TYPE = 'Routine Maintenance';
    private static final string REQUEST_SUBJECT = 'Testing subject';

    private static Vehicle__c createVehicle(){
        Vehicle__c Vehicle = new Vehicle__c(name = 'TestVehicle');
        return Vehicle;
    }

    private static Product2 createEquipment(){
        Product2 eq = new Product2(
            name = 'TestProduct',
            lifespan_months__c = 50,
            maintenance_cycle__c = 30,
            replacement_part__c = true
        );
        return eq;
    }

    private static Case createMaintenanceRequest(Id vehicleId, Id equipmentId){
        Case c = new Case(
            Type = REPAIR,
            Status = STATUS_NEW,
            Origin = REQUEST_ORIGIN,
            Subject = REQUEST_SUBJECT,
            Equipment__c = equipmentId,
            Vehicle__c = vehicleId
        );
        return c;
    }

    private static Equipment_Maintenance_Item__c createEquipmentItem(Id equipmentId, Id requestId){
        Equipment_Maintenance_Item__c emi = new Equipment_Maintenance_Item__c(
            Equipment__c = equipmentId,
            Maintenance_Request__c = requestId
        );
        return emi;
    }

    @isTest
    private static void testMaintenanceRequestPositive(){
        Vehicle__c vehicle = createVehicle();
        insert vehicle;

        Product2 equipment = createEquipment();
        insert equipment;

        case testCase = createMaintenanceRequest((Id)vehicle.Id, (Id)equipment.Id);
        insert testCase;

        Equipment_Maintenance_Item__c emi = createEquipmentItem((Id)equipment.Id, (Id)testCase.Id);
        insert emi;

        test.startTest();
        testCase.Status = CLOSED;
        update testCase;
        test.stopTest();

        Case newReq = [SELECT Id, Subject, Type, Equipment__c, Date_Reported__c, Vehicle__c, Date_Due__c FROM case WHERE Status = :STATUS_NEW];
        Equipment_Maintenance_Item__c newEmi = [SELECT Id FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c = :newReq.Id];

        System.assert(newEmi != null);
        System.assert(newReq.Subject != null);
        System.assertEquals(newReq.Type, REQUEST_TYPE);
        System.assertEquals(newReq.Equipment__c, equipment.Id);
        System.assertEquals(newReq.Vehicle__c, vehicle.Id);
        System.assertEquals(newReq.Date_Reported__c, System.Today());
    }

    @isTest
    private static void testMaintenanceRequestNegative(){
        Vehicle__c vehicle = createVehicle();
        insert vehicle;

        Product2 equipment = createEquipment();
        insert equipment;

        case testCase = createMaintenanceRequest((Id)vehicle.Id, (Id)equipment.Id);
        insert testCase;

        Equipment_Maintenance_Item__c emi = createEquipmentItem((Id)equipment.Id, (Id)testCase.Id);
        insert emi;

        test.startTest();
        testCase.Status = WORKING;
        update testCase;
        test.stopTest();

        List<Case> allReq = [SELECT Id FROM Case];
        Equipment_Maintenance_Item__c newEmi = [SELECT Id FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c = :testCase.Id];

        System.assert(newEmi != null);
        System.assert(allReq.size() == 1);
    }

    @isTest
    private static void testMaintenanceRequestBulk(){
        List<Vehicle__c> vehicleList = new List<Vehicle__c>();
        List<Product2> equipmentList = new List<Product2>();
        List<Equipment_Maintenance_Item__c> workPartList = new List<Equipment_Maintenance_Item__c>();
        List<Case> requestList = new List<Case>();
        List<Id> oldRequestIds = new List<Id>();

        for(Integer i = 0; i < 300; i++){
            vehicleList.add(createVehicle());
            equipmentList.add(createEquipment());
        }
        insert vehicleList;
        insert equipmentList;

        for(Integer i = 0; i < 300; i++){
            requestList.add(createMaintenanceRequest(vehicleList.get(i).Id, equipmentList.get(i).Id));
        }
        insert requestList;

        for(Integer i = 0; i < 300; i++){
            workPartList.add(createEquipmentItem(equipmentList.get(i).Id, requestList.get(i).Id));
        }
        insert workPartList;

        test.startTest();
        for(Case req : requestList){
            req.Status = CLOSED;
            oldRequestIds.add(req.Id);
        }
        update requestList;
        test.stopTest();

        List<Case> allRequests = [SELECT Id FROM Case WHERE Status =: STATUS_NEW];
        List<Equipment_Maintenance_Item__c> workParts = [SELECT Id FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c in: oldRequestIds];
        
        system.assert(allRequests.size() == 300);
    }
}