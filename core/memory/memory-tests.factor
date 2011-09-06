USING: accessors kernel kernel.private math memory prettyprint
io sequences tools.test words namespaces layouts classes
classes.builtin arrays quotations system ;
FROM: tools.memory => data-room code-room ;
IN: memory.tests

[ save-image-and-exit ] must-fail

! Tests for 'instances'
[ [ ] instances ] must-infer
2 [ [ [ 3 throw ] instances ] must-fail ] times

! Tests for 'become'
[ ] [ { } { } become ] unit-test

! Bug found on Windows build box, having too many words in the
! image breaks 'become'
[ ] [ 100000 [ f <uninterned-word> ] replicate { } { } become drop ] unit-test

! Bug: code heap collection had to be done when data heap was
! full, not just when code heap was full. If the code heap
! contained dead code blocks referring to large data heap
! objects, those large objects would continue to live on even
! if the code blocks were not reachable, as long as the code
! heap did not fill up.
: leak-step ( -- ) 800000 f <array> 1quotation call( -- obj ) drop ;

: leak-loop ( -- ) 100 [ leak-step ] times ;

[ ] [ leak-loop ] unit-test

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

[ ] [
    gc

    data-room tenured>> size>>
    
    10 [
        4 [ 120 1024 * f <array> ] replicate foo set-global
        100 [ 256 1024 * f <array> drop ] times
    ] times
    
    data-room tenured>> size>>
    assert=
] unit-test
