public with sharing class DeploymentChecker extends APIChecker {
    
    private static final String DEPLOY_STATUS_ENDPOINT = '/services/data/v62.0/metadata/deployRequest/';

    protected override String getEndpoint() {
        return DEPLOY_STATUS_ENDPOINT + this.request.ActionId__c;
    }

    protected override AbstractActionChecker.Checkable deserializeResult(String responseBody) {
        return (DeployResponseModel) JSON.deserialize(responseBody, DeployResponseModel.class);
    }

    public class DeployResponseModel implements AbstractActionChecker.Checkable {

        public Metadata.DeployResult deployResult;

        public Boolean isFinished() {
            return this.deployResult.done;
        }
    }
}