USING: tools.test tools.memory memory ;
IN: tools.memory.tests

[ ] [ room. ] unit-test
[ ] [ heap-stats. ] unit-test
[ ] [ [ gc gc ] collect-gc-events ] unit-test
[ ] [ gc-events. ] unit-test
[ ] [ gc-stats. ] unit-test
[ ] [ gc-summary. ] unit-test
