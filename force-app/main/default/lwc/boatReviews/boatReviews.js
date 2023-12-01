import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAllReviews from '@salesforce/apex/BoatDataService.getAllReviews';

export default class BoatReviews extends NavigationMixin(LightningElement){
    boatId;
    error;
    boatReviews;
    isLoading;
    
    @api
    get recordId(){ 
        return this.boatId;
    }
    set recordId(value) {
        this.setAttribute('boatId', value);
        this.boatId = value;
        this.getReviews();
    }
    
    get reviewsToShow(){
        return this.boatReviews != undefined && this.boatReviews != null && this.boatReviews.length > 0;
    }
    
    @api
    refresh(){ 
        this.getReviews();
    }
    
    getReviews(){ 
        if(this.boatId){
            getAllReviews({boatId : this.boatId})
            .then(data=>{
                this.boatReviews = data;
                this.error = undefined;
            })
            .catch(err=>{
                this.error = err;
            })
            .finally(()=>{
                this.isLoading = false;
            })
        }
        else{
            return;
        }
    }
    
    navigateToRecord(event){  
        event.preventDefault();
        event.stopPropogation();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes:{
                recordId: event.target.dataset.recordId,
                objectApiName: 'User',
                actionName: 'view'
            }
        });
    }
}