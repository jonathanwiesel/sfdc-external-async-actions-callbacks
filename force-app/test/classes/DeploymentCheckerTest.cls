@isTest
private class DeploymentCheckerTest {
    
    @isTest static void testGetDeploymentInstance() {

        MonitorRequest__c request = new MonitorRequest__c(
            ActionType__c = 'Deploy'
        );

        Test.startTest();
        AbstractActionChecker checkerInstance = AbstractActionChecker.getInstance(request);
        Test.stopTest();

        Assert.isNotNull(checkerInstance);
        Assert.isTrue(checkerInstance instanceof DeploymentChecker, 'The returned instance should be of registered deployment type');
    }

    @isTest static void testErrorGetInstance() {

        MonitorRequest__c request = new MonitorRequest__c(
            ActionType__c = 'Whatever'
        );

        try {

            Test.startTest();
            AbstractActionChecker.getInstance(request);
            Test.stopTest();

            Assert.fail('It should have failed');

        } catch (Exception e) {

            Assert.isTrue(e instanceof AbstractActionChecker.ActionCheckerException, 'The error should be related with a checker exception');
        }
    }

    @isTest static void testCheckStatusSuccess() {

        Test.setMock(HttpCalloutMock.class, new MockHTTP(200, '{"deployResult": {"done": true}}'));

        MonitorRequest__c request = new MonitorRequest__c(
            ActionType__c = 'Deploy'
        );

        Test.startTest();
        AbstractActionChecker checkerInstance = AbstractActionChecker.getInstance(request);
        AbstractActionChecker.Checkable checkable = checkerInstance.checkStatus();
        Test.stopTest();

        Assert.isTrue(checkable.isFinished(), 'The check should be completed');

    }

    @isTest static void testCheckStatusError() {

        Test.setMock(HttpCalloutMock.class, new MockHTTP(500, '{}'));

        MonitorRequest__c request = new MonitorRequest__c(
            ActionType__c = 'Deploy'
        );

        try {

            Test.startTest();
            AbstractActionChecker checkerInstance = AbstractActionChecker.getInstance(request);
            AbstractActionChecker.Checkable checkable = checkerInstance.checkStatus();
            Test.stopTest();

            Assert.fail('It should have failed');

        } catch (Exception e) {

            Assert.isTrue(e instanceof APIChecker.APICheckerException, 'The error should be related with a API checker exception');
        }
    }
}