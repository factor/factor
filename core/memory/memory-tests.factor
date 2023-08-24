USING: accessors arrays byte-arrays effects kernel
kernel.private math memory namespaces quotations sequences
tools.test words ;
FROM: tools.memory => data-room code-room ;
IN: memory.tests

[ save-image-and-exit ] must-fail

[ "does/not/exist" save-image ] must-fail

! TODO: Disabled to get clean build and revisit.
! [
!     os windows? "C:\\windows\\hello-windows" "/usr/bin/hello-unix" ?
!     save-image
! ] must-fail

! Tests for 'instances'
[ [ ] instances ] must-infer
2 [ [ [ 3 throw ] instances ] must-fail ] times

! Tests for 'become'
{ } [ { } { } become ] unit-test

! Become something when it's on the data stack.
{ "replacer" } [
    "original" dup 1array { "replacer" } become
] unit-test

! Nested in aging
{ "replacer" } [
    "original" [ 5 [ 1array ] times ] [ 1array ] bi
    minor-gc
    { "replacer" } become 5 [ first ] times
] unit-test

! Also when it is nested in nursery
{ "replacer" } [
    minor-gc
    "original" [ 5 [ 1array ] times ] [ 1array ] bi { "replacer" } become
    5 [ first ] times
] unit-test

! Bug found on Windows build box, having too many words in the
! image breaks 'become'
[ 100000 [ f <uninterned-word> ] replicate { } { } become ] must-not-fail

! Bug: code heap collection had to be done when data heap was
! full, not just when code heap was full. If the code heap
! contained dead code blocks referring to large data heap
! objects, those large objects would continue to live on even
! if the code blocks were not reachable, as long as the code
! heap did not fill up.
: leak-step ( -- ) 800000 f <array> 1quotation call( -- obj ) drop ;

: leak-loop ( -- ) 100 [ leak-step ] times ;

{ } [ leak-loop ] long-unit-test

! Bug: allocation of large objects directly into tenured space
! can proceed past the high water mark.
!
! Suppose the nursery and aging spaces are mostly comprised of
! reachable objects. When doing a full GC, objects from young
! generations ere promoted *before* unreachable objects in
! tenured space are freed by the sweep phase. So if large object
! allocation filled up the heap past the high water mark, this
! promotion might trigger heap growth, even if most of those
! large objects are unreachable.
SYMBOL: foo

{ } [
    gc

    data-room tenured>> size>>

    10 [
        4 [ 120 1024 * f <array> ] replicate foo set-global
        100 [ 256 1024 * f <array> drop ] times
    ] times

    data-room tenured>> size>>
    assert=
] long-unit-test

! Perform one gc cycle. Then increase the stack height by 100 and
! force a gc cycle again.
SYMBOL: foo-var

: perform ( -- )
    { 1 2 3 } { 4 5 6 } <effect> drop ;

: deep-stack-minor-gc ( n -- )
    dup [
        dup 0 > [ 1 - deep-stack-minor-gc ] [
            drop 100000 [ perform ] times
        ] if
    ] dip foo-var set ;

{ } [
    minor-gc 100 deep-stack-minor-gc
] unit-test

! Bug #1289
TUPLE: tup2 a b c d ;

: inner ( k -- n )
    20 f <array> 20 f <array> assert=
    ! Allocates a byte array so large that the next allocation will
    ! trigger a gc.
    drop 2097103 <byte-array> ;

: outer ( -- lag )
    9 <iota> [ inner ] map
    ! D 0 is scrubbed, but if the branch calling 'inner' was
    ! called, then both D 0 and D 1 should have been scrubbed.
    0 9 1 tup2 boa ;

{ } [
    outer drop
] unit-test
