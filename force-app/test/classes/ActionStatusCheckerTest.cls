@isTest
private class ActionStatusCheckerTest {

    private static MonitorRequest__c monitorReq = new MonitorRequest__c(
        ActionId__c = 'test',
        Provider__c = 'Github',
        ActionType__c = 'TEST_ACTION',
        SourceId__c = 'test',
        MonitorFrequency__c = 1,
        Status__c = 'Requested'
    );

    @isTest static void testAvoidRunAlreadyProcessed() {

        monitorReq.Status__c = 'Cancelled';
        insert monitorReq;

        Test.startTest();
        ActionStatusChecker.enqueue(new MonitorRequest__c[]{monitorReq});
        Test.stopTest();

        MonitorRequest__c committedRec = [SELECT LastActionCheckDate__c FROM MonitorRequest__c];
        Assert.isNull(monitorReq.LastActionCheckDate__c, 'Since it was already processed, it should not have updated the date');
    }

    @isTest static void testMonitorStillPending() {

        Boolean pending = true;

        AbstractActionChecker.mockedChecker = new MockActionChecker(pending);
        AbstractMonitorNotifier.mockedNotifier = new MockMonitorNotifier(null);

        Test.startTest();
        ActionStatusChecker.enqueue(new MonitorRequest__c[]{monitorReq});
        Test.stopTest();

        MonitorRequest__c[] committedRec = [SELECT Status__c, LastErrorDetail__c, LastActionCheckDate__c FROM MonitorRequest__c];
        Assert.areEqual(1, committedRec.size(), 'The record should have been committed to db');
        Assert.isNull(committedRec[0].LastErrorDetail__c, 'There should be no error');
        Assert.isNotNull(committedRec[0].LastActionCheckDate__c, 'The check date should have been updated');
        Assert.areEqual('Monitoring', committedRec[0].Status__c, 'The record should still be monitoring since is not fiinished');
    }

    @isTest static void testMonitorFinished() {

        Boolean pending = false;

        AbstractActionChecker.mockedChecker = new MockActionChecker(pending);
        AbstractMonitorNotifier.mockedNotifier = new MockMonitorNotifier(null);

        Test.startTest();
        ActionStatusChecker.enqueue(new MonitorRequest__c[]{monitorReq});
        Test.stopTest();

        MonitorRequest__c[] committedRec = [SELECT Status__c, LastErrorDetail__c, LastActionCheckDate__c FROM MonitorRequest__c];
        Assert.areEqual(1, committedRec.size(), 'The record should have been committed to db');
        Assert.isNull(committedRec[0].LastErrorDetail__c, 'There should be no error');
        Assert.isNotNull(committedRec[0].LastActionCheckDate__c, 'The check date should have been updated');
        Assert.areEqual('Completed', committedRec[0].Status__c, 'The record should be completed since notification was made');
    }

    @isTest static void testError() {

        Boolean pending = false;
        String errorMsg = 'Controlled error';

        AbstractActionChecker.mockedChecker = new MockActionChecker(pending);
        AbstractMonitorNotifier.mockedNotifier = new MockMonitorNotifier(errorMsg);

          

        ActionStatusChecker instance = new ActionStatusChecker(monitorReq);

        try {

            Test.startTest(); 
            ActionStatusChecker.enqueue(new MonitorRequest__c[]{monitorReq});
            Test.stopTest();

            Assert.fail('Should have thrown an exception');

        } catch (Exception e) {

            Assert.areEqual(errorMsg, e.getMessage(), 'The error should be the one from the notifier mock class');
        }

        

        MonitorRequest__c[] committedRec = [SELECT Status__c, LastErrorDetail__c, LastActionCheckDate__c FROM MonitorRequest__c];
        Assert.areEqual(1, committedRec.size(), 'The record should have been committed to db');
        Assert.isTrue(committedRec[0].LastErrorDetail__c.startsWith(errorMsg), 'There should be an error from the notifier');
        Assert.isNotNull(committedRec[0].LastActionCheckDate__c, 'The check date should have been updated');
        Assert.areEqual('Error', committedRec[0].Status__c, 'The record should be in error state since notification failed');
    }


    private class MockActionChecker extends AbstractActionChecker implements AbstractActionChecker.Checkable {

        private Boolean isPending;

        public MockActionChecker(Boolean isPending) {
            this.isPending = isPending;
        }

        public Boolean isFinished() {
            return !this.isPending;
        }

        public override AbstractActionChecker.Checkable checkStatus() {
            return this;
        }
    }

    private class MockMonitorNotifier extends AbstractMonitorNotifier {

        private String failMsg;

        public MockMonitorNotifier(String failMsg) {
            this.failMsg = failMsg;
        }

        public override void notify() {
            if (String.isNotBlank(this.failMsg)) {
                throw new MockException(this.failMsg);
            }
        }
    }

    private class MockException extends Exception {}
}