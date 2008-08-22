USING: namespaces assocs sequences compiler.tree.builder
compiler.tree.dead-code compiler.tree.def-use compiler.tree
compiler.tree.combinators compiler.tree.propagation
compiler.tree.cleanup compiler.tree.escape-analysis
compiler.tree.tuple-unboxing compiler.tree.debugger
compiler.tree.normalization compiler.tree.checker tools.test
kernel math stack-checker.state accessors combinators io
prettyprint words sequences.deep sequences.private ;
IN: compiler.tree.dead-code.tests

\ remove-dead-code must-infer

: count-live-values ( quot -- n )
    build-tree
    normalize
    propagate
    cleanup
    escape-analysis
    unbox-tuples
    compute-def-use
    remove-dead-code
    0 swap [
        dup
        [ #push? ] [ #introduce? ] bi or
        [ out-d>> length + ] [ drop ] if
    ] each-node ;

[ 3 ] [ [ 1 2 3 ] count-live-values ] unit-test

[ 1 ] [ [ drop ] count-live-values ] unit-test

[ 0 ] [ [ 1 drop ] count-live-values ] unit-test

[ 1 ] [ [ 1 2 drop ] count-live-values ] unit-test

[ 3 ] [ [ [ 1 ] [ 2 ] if ] count-live-values ] unit-test

[ 1 ] [ [ [ 1 ] [ 2 ] if drop ] count-live-values ] unit-test

[ 2 ] [ [ [ 1 ] [ dup ] if drop ] count-live-values ] unit-test

[ 2 ] [ [ 1 + ] count-live-values ] unit-test

[ 0 ] [ [ 1 2 + drop ] count-live-values ] unit-test

[ 3 ] [ [ 1 + 3 + ] count-live-values ] unit-test

[ 0 ] [ [ 1 2 + 3 + drop ] count-live-values ] unit-test

[ 4 ] [ [ [ 1 ] [ 2 ] if 3 + ] count-live-values ] unit-test

[ 1 ] [ [ [ 1 ] [ 2 ] if 3 + drop ] count-live-values ] unit-test

[ 0 ] [ [ [ ] call ] count-live-values ] unit-test

[ 1 ] [ [ [ 1 ] call ] count-live-values ] unit-test

[ 2 ] [ [ [ 1 ] [ 2 ] compose call ] count-live-values ] unit-test

[ 0 ] [ [ [ 1 ] [ 2 ] compose call + drop ] count-live-values ] unit-test

[ 3 ] [ [ 10 [ ] times ] count-live-values ] unit-test

: optimize-quot ( quot -- quot' )
    build-tree
    normalize
    propagate
    cleanup
    escape-analysis
    unbox-tuples
    compute-def-use
    remove-dead-code
    "no-check" get [ dup check-nodes ] unless nodes>quot ;

[ [ drop 1 ] ] [ [ >r 1 r> drop ] optimize-quot ] unit-test

[ [ read drop 1 2 ] ] [ [ read >r 1 2 r> drop ] optimize-quot ] unit-test

[ [ over >r + r> ] ] [ [ [ + ] [ drop ] 2bi ] optimize-quot ] unit-test

[ [ [ ] [ ] if ] ] [ [ [ 1 ] [ 2 ] if drop ] optimize-quot ] unit-test

: flushable-1 ( a b -- c ) 2drop f ; flushable
: flushable-2 ( a b -- c ) 2drop f ; flushable

[ [ 2nip [ ] [ ] if ] ] [
    [ [ flushable-1 ] [ flushable-2 ] if drop ] optimize-quot
] unit-test

: non-flushable-3 ( a b -- c ) 2drop f ;

[ [ [ 2drop ] [ non-flushable-3 drop ] if ] ] [
    [ [ flushable-1 ] [ non-flushable-3 ] if drop ] optimize-quot
] unit-test

[ [ [ f ] [ f ] if ] ] [ [ [ f ] [ f ] if ] optimize-quot ] unit-test

[ ] [ [ dup [ 3 throw ] [ ] if ] optimize-quot drop ] unit-test

[ [ [ . ] [ drop ] if ] ] [ [ [ dup . ] [ ] if drop ] optimize-quot ] unit-test

[ [ f ] ] [ [ f dup [ ] [ ] if ] optimize-quot ] unit-test

[ ] [ [ over [ ] [ dup [ "X" throw ] [ "X" throw ] if ] if ] optimize-quot drop ] unit-test

: boo ( a b -- c ) 2drop f ;

[ [ dup 4 eq? [ nip ] [ boo ] if ] ] [ [ dup dup 4 eq? [ drop nip ] [ drop boo ] if ] optimize-quot ] unit-test

: squish ( quot -- quot' )
    [
        {
            { [ dup word? ] [ dup vocabulary>> [ drop "REC" ] unless ] }
            { [ dup wrapper? ] [ dup wrapped>> vocabulary>> [ drop "WRAP" ] unless ] }
            [ ]
        } cond
    ] deep-map ;

: call-recursive-dce-1 ( a -- b )
    [ call-recursive-dce-1 drop ] [ call-recursive-dce-1 ] bi ; inline recursive

[ [ "WRAP" [ dup >r "REC" drop r> "REC" ] label ] ] [
    [ call-recursive-dce-1 ] optimize-quot squish
] unit-test

: produce-a-value ( -- a ) f ;

: call-recursive-dce-2 ( a -- b )
    drop
    produce-a-value dup . call-recursive-dce-2 ; inline recursive

[ [ "WRAP" [ produce-a-value . "REC" ] label ] ] [
    [ f call-recursive-dce-2 drop ] optimize-quot squish
] unit-test

[ [ "WRAP" [ produce-a-value dup . drop "REC" ] label ] ] [
    [ f call-recursive-dce-2 ] optimize-quot squish
] unit-test

: call-recursive-dce-3 ( a -- )
    call-recursive-dce-3 ; inline recursive

[ [ [ drop "WRAP" [ "REC" ] label ] [ . ] if ] ] [
    [ [ call-recursive-dce-3 ] [ . ] if ] optimize-quot squish
] unit-test

[ [ drop "WRAP" [ "REC" ] label ] ] [
    [ call-recursive-dce-3 ] optimize-quot squish
] unit-test

: call-recursive-dce-4 ( a -- b )
    call-recursive-dce-4 ; inline recursive

[ [ "WRAP" [ "REC" ] label ] ] [
    [ call-recursive-dce-4 ] optimize-quot squish
] unit-test

[ [ drop "WRAP" [ "REC" ] label ] ] [
    [ call-recursive-dce-4 drop ] optimize-quot squish
] unit-test

[ ] [ [ f call-recursive-dce-3 swap ] optimize-quot drop ] unit-test

: call-recursive-dce-5 ( -- ) call-recursive-dce-5 ; inline recursive

[ ] [ [ call-recursive-dce-5 swap ] optimize-quot drop ] unit-test

[ ] [ [ [ 0 -rot set-nth-unsafe ] curry (each-integer) ] optimize-quot drop ] unit-test

: call-recursive-dce-6 ( i quot: ( i -- ? ) -- i )
    dup call [ drop ] [ call-recursive-dce-6 ] if ; inline recursive

[ ] [ [ [ ] curry [ ] swap compose call-recursive-dce-6 ] optimize-quot drop ] unit-test

[ ] [ [ [ ] rot [ . ] curry pick [ roll 2drop call ] [ 2nip call ] if ] optimize-quot drop ] unit-test
