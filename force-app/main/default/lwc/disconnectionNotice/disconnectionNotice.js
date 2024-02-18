import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {
    subscribe,
    unsubscribe,
    onError,
    setDebugFlag,
    isEmpEnabled,
} from 'lightning/empApi';

export default class DisconnectionNotice extends LightningElement {
    subscription = {};
    status;
    identifier;
    channelName = '/event/Asset_Disconnection__e';

    connectedCallback() {
        this.handleSubscribe();
        this.registerErrorListener();
    }

    renderedCallback(){
        
    }

    handleSubscribe() {
        //Implement your subscribing solution here 
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

    disconnectedCallback() {
        //Implement your unsubscribing solution here
        // this.toggleSubscribeButton(false);

        unsubscribe(this.subscription, (response) => {
            console.log('unsubscribe() response: ', JSON.stringify(response));
        });
    }

    handleEventMessage(res){
        // console.log('response receieved!', JSON.parse(JSON.stringify(res)));
        if(res.data && res.data.payload){
            if(res.data.payload.Disconnected__c === true){
                this.status = 'Disconnected';
                this.showSuccessToast(res.data.payload.Asset_Identifier__c);
            }
            else if(res.data.payload.Disconnected__c === false){
                this.showErrorToast(res.data.payload.Asset_Identifier__c);
            }
        }
    }

    showSuccessToast(assetId) {
        const event = new ShowToastEvent({
            title: 'Success',
            message: 'Asset Id '+assetId+' is now disconnected',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    showErrorToast() {
        const event = new ShowToastEvent({
            title: 'Error',
            message: 'Asset was not disconnected. Try Again.',
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
}