IN: optimizer.inlining.tests
USING: tools.test optimizer.inlining generic arrays math
sequences growable sbufs vectors sequences.private accessors kernel ;

\ word-flat-length must-infer
\ inlining-math-method must-infer
\ optimistic-inline? must-infer
\ find-identity must-infer
\ dispatching-class must-infer

! Make sure we have sane heuristics
: should-inline? ( generic class -- ? ) method flat-length 10 <= ;

[ t ] [ \ fixnum \ shift should-inline? ] unit-test
[ f ] [ \ array \ equal? should-inline? ] unit-test
[ f ] [ \ sequence \ hashcode* should-inline? ] unit-test
[ t ] [ \ array \ nth-unsafe should-inline? ] unit-test
[ t ] [ \ growable \ nth-unsafe should-inline? ] unit-test
[ t ] [ \ sbuf \ set-nth-unsafe should-inline? ] unit-test
[ t ] [ \ growable \ set-nth-unsafe should-inline? ] unit-test
[ t ] [ \ vector \ (>>length) should-inline? ] unit-test
