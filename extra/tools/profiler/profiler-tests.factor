IN: temporary
USING: tools.profiler tools.test kernel memory math threads ;

enable-profiler

[ ] [ [ 10 [ data-gc ] times ] profile ] unit-test

[ ] [ [ 1000 sleep ] profile ] unit-test 

[ ] [ profile. ] unit-test

[ ] [ vocabs-profile. ] unit-test

[ ] [ "kernel.private" vocab-profile. ] unit-test

[ ] [ \ + usage-profile. ] unit-test

disable-profiler
