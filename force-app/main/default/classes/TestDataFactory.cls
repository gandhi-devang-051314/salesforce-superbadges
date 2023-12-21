/**
 * @name TestDataFactory
 * @description Contains methods to construct and/or validate commonly used records
**/
public with sharing class TestDataFactory {

    /**
     * @name ConstructCollaborationGroup
     * @description
    **/
    public static CollaborationGroup ConstructCollaborationGroup(){
        CollaborationGroup chatter = new CollaborationGroup(
            Name = 'TEST'+Constants.INVENTORY_ANNOUNCEMENTS,
            CollaborationType = 'Public'
        );
        return chatter;
    }

    /**
     * @name CreateProducts
     * @description Constructs a list of Product2 records for unit tests
    **/
    public static List<Product2> ConstructProducts(Integer cnt){
        List<Product2> products = new List<Product2>();
        for(Integer i = 0; i < cnt; i++){
            Product2 p = new Product2(
                Name = 'Test Product'+i,
                Initial_Inventory__c = 10,
                IsActive = true,
                Family = Constants.PRODUCT_FAMILY.get(math.mod(i, 4)).getValue()
            );
            products.add(p);
        }
        return products;
    }

    /**
     * @name CreatePricebookEntries
     * @description Constructs a list of PricebookEntry records for unit tests
    **/
    public static List<PricebookEntry> ConstructPricebookEntries(List<Product2> prods){
        List<PricebookEntry> priceBooks = new List<PricebookEntry>();
        for(Product2 p : prods){
            PricebookEntry pe = new PricebookEntry();
            pe.PriceBook2Id = Constants.STANDARD_PRICEBOOK_ID;
            pe.IsActive = true;
            pe.Product2Id = p.Id;
            pe.Unitprice = 999999999;
            priceBooks.add(pe);
        }
        return priceBooks;
    }

    /**
     * @name CreateAccounts
     * @description Constructs a list of Account records for unit tests
    **/
    public static List<Account> ConstructAccounts(Integer cnt){
        List<Account> accounts = new List<Account>();
        for(Integer i = 0; i < cnt; i++){
            Account a = new Account(
                Name = 'Test Account'+i
            );
            accounts.add(a);
        }
        return accounts;
    }

    /**
     * @name CreateContacts
     * @description Constructs a list of Contacxt records for unit tests
    **/
    public static List<Contact> ConstructContacts(Integer cnt, List<Account> accts){
        List<Contact> contacts = new List<Contact>();
        for(Integer i = 0; i < cnt; i++){
            Contact c = new Contact(
                LastName = 'Test Contact'+i,
                AccountId = accts.get(Math.mod(i, accts.size())).Id
            );
            contacts.add(c);
        }
        return contacts;
    }

    /**
     * @name CreateOrders
     * @description Constructs a list of Order records for unit tests
    **/
    public static List<Order> ConstructOrders(Integer cnt, List<Account> accts){
        List<Order> orders = new List<Order>();
        for(Integer i = 0; i < cnt; i++){
            Order o = new Order();
            o.AccountId = accts.get(Math.mod(i, accts.size())).Id;
            o.PriceBook2Id = Constants.STANDARD_PRICEBOOK_ID;
            o.Status = 'Draft';
            o.EffectiveDate = System.today();
            orders.add(o);
        }
        return orders;
    }

    /**
     * @name CreateOrderItems
     * @description Constructs a list of OrderItem records for unit tests
    **/
    public static List<OrderItem> ConstructOrderItems(Integer cnt, List<PriceBookEntry> pbes, List<Order> ords){
        List<OrderItem> orderItems = new List<OrderItem>();
        for(Integer i = 0; i < cnt; i++){
            OrderItem oi = new OrderItem();
            oi.PricebookEntryId = pbes.get(Math.mod(i, pbes.size())).Id;
            oi.OrderId = ords.get(Math.mod(i, ords.size())).Id;
            oi.Quantity = Constants.DEFAULT_ROWS;
            oi.Unitprice = 999999999;            
            orderItems.add(oi);
        }
        return orderItems;
    }

    /**
     * @name SetupTestData
     * @description Inserts accounts, contacts, Products, PricebookEntries, Orders, and OrderItems.
    **/
    public static void InsertTestData(Integer cnt){
        //get called all functions of the same class and get data to be inserted...

        CollaborationGroup chatterGroup = TestDataFactory.ConstructCollaborationGroup();
        insert chatterGroup;

        List<Product2> products = TestDataFactory.ConstructProducts(cnt);
        insert products;

        List<PriceBookEntry> priceBooks = TestDataFactory.ConstructPricebookEntries(products);
        insert priceBooks;

        List<Account> accounts = TestDataFactory.ConstructAccounts(cnt);
        insert accounts;

        List<Contact> contacts = TestDataFactory.ConstructContacts(cnt, accounts);
        insert contacts;

        List<Order> orders = TestDataFactory.ConstructOrders(cnt, accounts);
        insert orders;

        List<OrderItem> orderItems = TestDataFactory.ConstructOrderItems(cnt, priceBooks, orders);
        insert orderItems;
    }

    public static void VerifyQuantityOrdered(Product2 originalProduct, Product2 updatedProduct, Integer qtyOrdered){
        System.assertEquals(updatedProduct.Quantity_Ordered__c, (originalProduct.Quantity_Ordered__c + qtyOrdered));
    }
}