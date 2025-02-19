@isTest
private class GithubActionStatusNotifierTest {
    
    @isTest static void testGetGithubNotifierInstance() {

        MonitorRequest__c request = new MonitorRequest__c(
            Provider__c = 'Github'
        );

        Test.startTest();
        AbstractMonitorNotifier notifierInstance = AbstractMonitorNotifier.getInstance(request);
        Test.stopTest();

        Assert.isNotNull(notifierInstance);
        Assert.isTrue(notifierInstance instanceof GithubActionStatusNotifier, 'The returned instance should be of registered Github type');
    }

    @isTest static void testErrorGetInstance() {

        MonitorRequest__c request = new MonitorRequest__c(
            Provider__c = 'Whatever'
        );

        try {

            Test.startTest();
            AbstractMonitorNotifier.getInstance(request);
            Test.stopTest();

            Assert.fail('It should have failed');

        } catch (Exception e) {

            Assert.isTrue(e instanceof AbstractMonitorNotifier.MonitorNotifierException, 'The error should be related with a notifier exception');
        }
    }

    @isTest static void testNotifySuccess() {

        MonitorRequest__c request = new MonitorRequest__c(
            Provider__c = 'Github',
            SourceData__c = GithubActionStatusNotifier.CLI_JSON_STRING_PREPENDER + '{"checkRunId": "123", "repo": "john/doe", "eventType": "deploy-check"}'
        );

        AbstractMonitorNotifier instance = AbstractMonitorNotifier.getInstance(request);

        Test.setMock(HttpCalloutMock.class, new MockHTTP(GithubActionStatusNotifier.SUCCESS_RESPONSE_CODE, '{"deployResult": {"done": true}}'));
        Test.startTest();
            try {
                instance.notify();
            } catch (Exception e) {
                Assert.fail('It should not have failed: ' + e.getMessage());
            }
            
        Test.stopTest();
    }

    @isTest static void testNotifyError() {
        
        MonitorRequest__c request = new MonitorRequest__c(
            Provider__c = 'Github',
            SourceData__c = GithubActionStatusNotifier.CLI_JSON_STRING_PREPENDER + '{"checkRunId": "123", "repo": "john/doe", "eventType": "deploy-check"}'
        );

        AbstractMonitorNotifier instance = AbstractMonitorNotifier.getInstance(request);

        Test.setMock(HttpCalloutMock.class, new MockHTTP(403, '{"error": "not authorized"}'));
        Test.startTest();
            try {
                instance.notify();
                Assert.fail('It should have failed');
            } catch (Exception e) {
                Assert.isTrue(e instanceof AbstractMonitorNotifier.MonitorNotifierException, 'The error should be related with a notifier exception');
            }
            
        Test.stopTest();
    }
}