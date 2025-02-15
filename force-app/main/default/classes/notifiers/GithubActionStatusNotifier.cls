public with sharing class GithubActionStatusNotifier extends AbstractMonitorNotifier {
    
    private static final Integer SUCCESS_RESPONSE_CODE = 200;
    private static final String CLI_JSON_STRING_PREPENDER = '@';

    public override void notify() {

        DispatchRequestModel requestModel = new DispatchRequestModel(this.request);

        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('callout:' + this.config.NamedCredential__c + requestModel.getEndpoint());
        req.setBody(JSON.serialize(requestModel));

        HttpResponse res = new Http().send(req);

        if (res.getStatusCode() != SUCCESS_RESPONSE_CODE) {
            throw new AbstractMonitorNotifier.MonitorNotifierException('Failed to notify Github for action ' + this.request.ActionId__c + ': ' + res.getBody());
        }
    }


    private class DispatchRequestModel {

        private transient SourceDataModel sourceModel;

        private String event_type;
        private DispatchPayloadModel client_payload;

        public DispatchRequestModel(MonitorRequest__c request) {
            
            this.sourceModel = (SourceDataModel)JSON.deserialize(request.SourceData__c.remove(CLI_JSON_STRING_PREPENDER), SourceDataModel.class);
            this.client_payload = new DispatchPayloadModel(request, this.sourceModel);
            this.event_type = sourceModel.eventType;
        }

        public String getEndpoint() {
            return '/repos/' + this.sourceModel.repo + '/dispatches';
        }
    }


    private class SourceDataModel {

        public String repo;
        public String eventType;
        public String checkRunId;
    }


    private class DispatchPayloadModel {

        private String checkRunId;
        private String actionId;

        public DispatchPayloadModel(MonitorRequest__c request, SourceDataModel sourceModel) {

            this.checkRunId = sourceModel.checkRunId;
            this.actionId = request.ActionId__c;
        }
    }
}