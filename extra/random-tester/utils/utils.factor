USING: arrays assocs combinators.lib continuations kernel
math math.functions namespaces quotations random sequences
sequences.private shuffle ;
IN: random-tester.utils

: %chance ( n -- ? )
    100 random > ;

: 10% ( -- ? ) 10 %chance ;
: 20% ( -- ? ) 20 %chance ;
: 30% ( -- ? ) 30 %chance ;
: 40% ( -- ? ) 40 %chance ;
: 50% ( -- ? ) 50 %chance ;
: 60% ( -- ? ) 60 %chance ;
: 70% ( -- ? ) 70 %chance ;
: 80% ( -- ? ) 80 %chance ;
: 90% ( -- ? ) 90 %chance ;

: call-if ( quot ? -- ) swap when ; inline

: with-10% ( quot -- ) 10% call-if ; inline
: with-20% ( quot -- ) 20% call-if ; inline
: with-30% ( quot -- ) 30% call-if ; inline
: with-40% ( quot -- ) 40% call-if ; inline
: with-50% ( quot -- ) 50% call-if ; inline
: with-60% ( quot -- ) 60% call-if ; inline
: with-70% ( quot -- ) 70% call-if ; inline
: with-80% ( quot -- ) 80% call-if ; inline
: with-90% ( quot -- ) 90% call-if ; inline

: random-key keys random ;
: random-value [ random-key ] keep at ;

: do-one ( seq -- ) random call ; inline
