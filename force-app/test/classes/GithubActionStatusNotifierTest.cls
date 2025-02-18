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
        
    }

    @isTest static void testNotifyError() {
        Assert.fail('Demo time for TDX');
    }
}