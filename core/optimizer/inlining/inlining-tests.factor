IN: optimizer.inlining.tests
USING: tools.test optimizer.inlining generic arrays math
sequences growable sbufs vectors sequences.private accessors kernel ;

\ word-flat-length must-infer
\ inlining-math-method must-infer
\ optimistic-inline? must-infer
\ find-identity must-infer
\ dispatching-class must-infer

! Make sure we have sane heuristics
[ t ] [ \ fixnum \ shift method should-inline? ] unit-test
[ f ] [ \ array \ equal? method should-inline? ] unit-test
[ f ] [ \ sequence \ hashcode* method should-inline? ] unit-test
[ t ] [ \ array \ nth-unsafe method should-inline? ] unit-test
[ t ] [ \ growable \ nth-unsafe method should-inline? ] unit-test
[ t ] [ \ sbuf \ set-nth-unsafe method should-inline? ] unit-test
[ t ] [ \ growable \ set-nth-unsafe method should-inline? ] unit-test
[ t ] [ \ growable \ set-nth method should-inline? ] unit-test
[ t ] [ \ vector \ (>>length) method should-inline? ] unit-test
