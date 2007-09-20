IN: temporary
USING: tools.profiler tools.test kernel memory math threads
alien tools.profiler.private ;

enable-profiler

[ ] [ [ 10 [ data-gc ] times ] profile ] unit-test

[ ] [ [ 1000 sleep ] profile ] unit-test 

[ ] [ profile. ] unit-test

[ ] [ vocabs-profile. ] unit-test

[ ] [ "kernel.private" vocab-profile. ] unit-test

[ ] [ \ + usage-profile. ] unit-test

: callback-test "void" { } "cdecl" [ ] alien-callback ;

: indirect-test "void" { } "cdecl" alien-indirect ;

: foobar ;

[
    [ ] [ callback-test indirect-test ] unit-test
    foobar
] profile

[ 1 ] [ \ foobar profile-counter ] unit-test

disable-profiler
