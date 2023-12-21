public class Product2Extension {

    public List<ProductWrapper> productsToInsert {get;set;}

    public Product2Extension(ApexPages.StandardController controller){
        productsToInsert = new List<ProductWrapper>();
        addRows();
    }

    public void AddRows(){
        for ( Integer i=0; i<Constants.DEFAULT_ROWS; i++ ){
            productsToInsert.add( new ProductWrapper() );
        }
    }

    public List<ChartHelper.ChartData> GetInventory(){
        return ChartHelper.GetInventory();
    }

    public PageReference Save(){
        SavePoint transctionInstance = Database.setSavePoint();
        try {
            List<Product2> products = new List<Product2>();
            List<PriceBookEntry> priceBooks = new List<PriceBookEntry>();

            for (ProductWrapper p : productsToInsert){
                if(
                    p.productRecord != null && 
                    p.pricebookEntryRecord != null &&

                    //avoid using nested if make it anded all conditions logicality to get more readability and getting execution faster...

                    p.productRecord.Name != null &&
                    p.productRecord.Family != null &&
                    p.productRecord.Name != '' &&
                    p.productRecord.Family != '' &&
                    p.productRecord.Family != Constants.SELECT_ONE &&
                    p.productRecord.Initial_Inventory__c != null &&
                    p.pricebookEntryRecord.Unitprice != null
                ){
                    products.add(p.productRecord);

                    //to set the properties we need to make a new instance of PriceBookEntry from PriceWrapper class...
                    PriceBookEntry price = p.pricebookEntryRecord;
                    price.IsActive = true;
                    price.PriceBook2Id = Constants.STANDARD_PRICEBOOK_ID;
                    priceBooks.add(price);
                }
            }

            //null check and insert recors
            if(products != null && products.size() > 0){
                insert products;

                //assigning all products to their respective price books...
                for(Integer i = 0; i < priceBooks.size(); i++){
                    priceBooks[i].Product2Id = products[i].Id;
                }
                insert priceBooks;
            }
            else{
                apexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Constants.ERROR_MESSAGE));
                Database.RollBack(transctionInstance);
            }

            //rest of the code as given already...
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,productsToInsert.size()+' Inserted'));
            productsToInsert.clear();   //Do not remove
            addRows();  //Do not remove
        } catch (Exception e){
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Constants.ERROR_MESSAGE));
            Database.RollBack(transctionInstance);
        }
        return null;
    }

    public List<SelectOption> GetFamilyOptions(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE));

        for (PicklistEntry p : Constants.PRODUCT_FAMILY) {
            options.add(new SelectOption(p.getValue(), p.getLabel()));
        }
        return options;
    }

    public class ProductWrapper{
        public Product2 productRecord {get;set;}
        public PriceBookEntry pricebookEntryRecord {get;set;}
        public ProductWrapper(){
            productRecord = new Product2(Initial_Inventory__c = 0);
            pricebookEntryRecord = new PriceBookEntry(Unitprice = 0.0);
        }
    }
}