USING: tools.test tools.memory memory arrays ;
IN: tools.memory.tests

[ ] [ room. ] unit-test
[ ] [ heap-stats. ] unit-test
[ t ] [ [ gc gc ] collect-gc-events array? ] unit-test
[ ] [ gc-events. ] unit-test
[ ] [ gc-stats. ] unit-test
[ ] [ gc-summary. ] unit-test
[ ] [ callback-room. ] unit-test
