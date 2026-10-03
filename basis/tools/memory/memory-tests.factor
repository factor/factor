USING: accessors arrays assocs continuations kernel layouts literals math memory
namespaces parser sequences tools.memory tools.memory.private
tools.test tools.time vm ;

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

{ t t t } [
    get-code-blocks code-block-stats nip
    [ CODE-BLOCK-UNOPTIMIZED of 0 > ]
    [ CODE-BLOCK-OPTIMIZED of 0 > ]
    [ CODE-BLOCK-PIC of 0 > ] tri
] unit-test

${ 64-bit? 80 64 ? } [ "hello \u{snowman}" total-size ] unit-test

! A retained failure must not keep the full code-heap snapshot alive.
{ f } [
    [ [ "code-block snapshot test" throw ] with-code-blocks ] [
        drop error-continuation get name>> namestack>vector
        [ \ code-blocks swap at code-blocks? ] any?
    ] recover
] unit-test

! Nested inspections restore the outer snapshot after their own cleanup.
{ t t } [
    [
        [ \ code-blocks get code-blocks? ] with-code-blocks
        \ code-blocks get code-blocks?
    ] with-code-blocks
] unit-test
