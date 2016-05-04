USING: arrays math memory namespaces parser sequences tools.memory
tools.memory.private tools.test tools.time ;
IN: tools.memory.tests

{ } [ room. ] unit-test
{ } [ heap-stats. ] unit-test
{ t } [ [ gc gc ] collect-gc-events array? ] unit-test
{ } [ gc-events. ] unit-test
{ } [ gc-stats. ] unit-test
{ } [ gc-summary. ] unit-test
{ } [ callback-room. ] unit-test

! Each gc-event must reclaim something. #659
{ f } [
    [ "resource:basis/tools/memory/memory.factor" run-file ] time
    gc-events get [ space-reclaimed 0 < ] any?
] unit-test
