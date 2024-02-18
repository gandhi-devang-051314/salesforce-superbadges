import { LightningElement, track, api, wire } from 'lwc';
import { getRecord, getFieldValue, notifyRecordUpdateAvailable } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {
    subscribe,
    unsubscribe,
    onError,
    setDebugFlag,
    isEmpEnabled,
} from 'lightning/empApi';
import ASSET_IDENTIFIER_FIELD from "@salesforce/schema/Asset.Asset_Identifier__c";
import STATUS_FIELD from "@salesforce/schema/Asset.Status";
import statusUpdate from '@salesforce/apex/DeliveryStatusUpdateFromEvent.statusUpdate';

export default class AssetDelivery extends LightningElement {
    statusValue;
    @api 
    recordId;
    recIdentifier;
    subscription = {};
    channelName = '/event/Asset_Delivery__e';

    @wire(getRecord, {recordId: "$recordId", fields: [ASSET_IDENTIFIER_FIELD, STATUS_FIELD]})
    asset({error, data}){
        if(data){
          this.recIdentifier = getFieldValue(data, ASSET_IDENTIFIER_FIELD);
          this.statusValue = getFieldValue(data, STATUS_FIELD);
        }else if(error){
          console.log(JSON.stringify(error)); 
        }
    }

    connectedCallback() {
        this.handleSubscribe();
        this.registerErrorListener();
    }

    renderedCallback(){
        //this.handleSubscribe();
    }

    handleSubscribe() {
        const messageCallback = (response)=>{
          console.log('New message received: ', JSON.stringify(response));
          this.handleEventMessage(response);
        };

        subscribe(this.channelName, -1, messageCallback).then((response) => {
            console.log(
                'Subscription request sent to: ',
                JSON.stringify(response.channel)
            );
            this.subscription = response;
            // this.toggleSubscribeButton(true);
        });
    }

    handleEventMessage(res){
      // console.log('response receieved!', JSON.parse(JSON.stringify(res)));
      if(res.data && res.data.payload){
        this.statusUpdateFromPlateformEvent(res.data.payload);
      }
    }
    
    async statusUpdateFromPlateformEvent(data){
        statusUpdate({assetIdentifier : data.Asset_Identifier__c, updatedStatus: data.Status__c})
        .then(data=>{
            this.showSuccessToast(data);
        })
        .catch(err=>{
            console.error('Status updation error', err);
            this.showErrorToast(err);
        });
        await notifyRecordUpdateAvailable([{recordId :this.recordId}]);
    }

    showSuccessToast(msg) {
        const event = new ShowToastEvent({
            title: 'Asset Status Updated!',
            message: msg,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    showErrorToast(err) {
        const event = new ShowToastEvent({
            title: 'Asset Status Updation Error',
            message: `Asset was not updated. ${err}`,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    registerErrorListener() {
      // Invoke onError empApi method
      onError((error) => {
          console.log('Received error from server: ', JSON.stringify(error));
          // Error contains the server-side error
      });
    }

    disconnectedCallback(){
      unsubscribe(this.subscription, (response) => {
          console.log('unsubscribe() response: ', JSON.stringify(response));
      });
    }
}