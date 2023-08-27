USING: namespaces assocs sequences compiler.tree.builder
compiler.tree.dead-code compiler.tree.def-use compiler.tree
compiler.tree.combinators compiler.tree.propagation
compiler.tree.cleanup compiler.tree.escape-analysis
compiler.tree.tuple-unboxing compiler.tree.debugger
compiler.tree.recursive compiler.tree.normalization
compiler.tree.checker tools.test kernel math stack-checker.state
accessors combinators io prettyprint words sequences.deep
sequences.private arrays classes kernel.private shuffle
math.private ;
IN: compiler.tree.dead-code.tests

: count-live-values ( quot -- n )
    build-tree
    analyze-recursive
    normalize
    propagate
    cleanup-tree
    escape-analysis
    unbox-tuples
    compute-def-use
    remove-dead-code
    0 swap [
        dup
        [ #push? ] [ #introduce? ] bi or
        [ out-d>> length + ] [ drop ] if
    ] each-node ;

{ 3 } [ [ 1 2 3 ] count-live-values ] unit-test

{ 1 } [ [ drop ] count-live-values ] unit-test

{ 0 } [ [ 1 drop ] count-live-values ] unit-test

{ 1 } [ [ 1 2 drop ] count-live-values ] unit-test

{ 3 } [ [ [ 1 ] [ 2 ] if ] count-live-values ] unit-test

{ 1 } [ [ [ 1 ] [ 2 ] if drop ] count-live-values ] unit-test

{ 2 } [ [ [ 1 ] [ dup ] if drop ] count-live-values ] unit-test

{ 2 } [ [ 1 + ] count-live-values ] unit-test

{ 0 } [ [ 1 2 + drop ] count-live-values ] unit-test

{ 3 } [ [ 1 + 3 + ] count-live-values ] unit-test

{ 0 } [ [ 1 2 + 3 + drop ] count-live-values ] unit-test

{ 4 } [ [ [ 1 ] [ 2 ] if 3 + ] count-live-values ] unit-test

{ 1 } [ [ [ 1 ] [ 2 ] if 3 + drop ] count-live-values ] unit-test

{ 0 } [ [ [ ] call ] count-live-values ] unit-test

{ 1 } [ [ [ 1 ] call ] count-live-values ] unit-test

{ 2 } [ [ [ 1 ] [ 2 ] compose call ] count-live-values ] unit-test

{ 0 } [ [ [ 1 ] [ 2 ] compose call + drop ] count-live-values ] unit-test

{ 3 } [ [ 10 [ ] times ] count-live-values ] unit-test

: optimize-quot ( quot -- quot' )
    build-tree
    analyze-recursive
    normalize
    propagate
    cleanup-tree
    escape-analysis
    unbox-tuples
    compute-def-use
    remove-dead-code
    "no-check" get [ dup check-nodes ] unless nodes>quot ;

{ [ drop 1 ] } [ [ [ 1 ] dip drop ] optimize-quot ] unit-test

{ [ stream-read1 drop 1 2 ] } [ [ stream-read1 [ 1 2 ] dip drop ] optimize-quot ] unit-test

{ [ over >R + R> ] } [ [ [ + ] [ drop ] 2bi ] optimize-quot ] unit-test

{ [ [ ] [ ] if ] } [ [ [ 1 ] [ 2 ] if drop ] optimize-quot ] unit-test

: flushable-1 ( a b -- c ) 2drop f ; flushable
: flushable-2 ( a b -- c ) 2drop f ; flushable

{ [ 2nip [ ] [ ] if ] } [
    [ [ flushable-1 ] [ flushable-2 ] if drop ] optimize-quot
] unit-test

: non-flushable-3 ( a b -- c ) 2drop f ;

{ [ [ 2drop ] [ non-flushable-3 drop ] if ] } [
    [ [ flushable-1 ] [ non-flushable-3 ] if drop ] optimize-quot
] unit-test

{ [ [ f ] [ f ] if ] } [ [ [ f ] [ f ] if ] optimize-quot ] unit-test

[ [ dup [ 3 throw ] [ ] if ] optimize-quot ] must-not-fail

{ [ [ . ] [ drop ] if ] } [ [ [ dup . ] [ ] if drop ] optimize-quot ] unit-test

{ [ f ] } [ [ f dup [ ] [ ] if ] optimize-quot ] unit-test

[ [ over [ ] [ dup [ "X" throw ] [ "X" throw ] if ] if ] optimize-quot ] must-not-fail

: boo ( a b -- c ) 2drop f ;

{ [ dup 4 eq? [ nip ] [ boo ] if ] } [ [ dup dup 4 eq? [ drop nip ] [ drop boo ] if ] optimize-quot ] unit-test

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

{ [ drop "WRAP" [ "REC" drop "REC" ] label ] } [
    [ call-recursive-dce-1 ] optimize-quot squish
] unit-test

: produce-a-value ( -- a ) f ;

: call-recursive-dce-2 ( a -- b )
    drop
    produce-a-value dup . call-recursive-dce-2 ; inline recursive

{ [ "WRAP" [ produce-a-value . "REC" ] label ] } [
    [ f call-recursive-dce-2 drop ] optimize-quot squish
] unit-test

{ [ "WRAP" [ produce-a-value . "REC" ] label ] } [
    [ f call-recursive-dce-2 ] optimize-quot squish
] unit-test

: call-recursive-dce-3 ( a -- )
    call-recursive-dce-3 ; inline recursive

{ [ [ drop "WRAP" [ "REC" ] label ] [ . ] if ] } [
    [ [ call-recursive-dce-3 ] [ . ] if ] optimize-quot squish
] unit-test

{ [ drop "WRAP" [ "REC" ] label ] } [
    [ call-recursive-dce-3 ] optimize-quot squish
] unit-test

: call-recursive-dce-4 ( a -- b )
    call-recursive-dce-4 ; inline recursive

{ [ drop "WRAP" [ "REC" ] label ] } [
    [ call-recursive-dce-4 ] optimize-quot squish
] unit-test

{ [ drop "WRAP" [ "REC" ] label ] } [
    [ call-recursive-dce-4 drop ] optimize-quot squish
] unit-test

[ [ f call-recursive-dce-3 swap ] optimize-quot ] must-not-fail

: call-recursive-dce-5 ( -- ) call-recursive-dce-5 ; inline recursive

[ [ call-recursive-dce-5 swap ] optimize-quot ] must-not-fail

[ [ [ 0 -rot set-nth-unsafe ] curry each-integer-from ] optimize-quot ] must-not-fail

: call-recursive-dce-6 ( i quot: ( ..a -- ..b ) -- i )
    dup call [ drop ] [ call-recursive-dce-6 ] if ; inline recursive

[ [ [ ] curry [ ] swap compose call-recursive-dce-6 ] optimize-quot ] must-not-fail

[ [ [ ] rot [ . ] curry pick [ roll 2drop call ] [ 2nip call ] if ] optimize-quot ] must-not-fail

{ [ drop ] } [ [ array? drop ] optimize-quot ] unit-test

{ [ drop ] } [ [ array instance? drop ] optimize-quot ] unit-test

{
    [ f <array> drop ]
    [ f <array> drop ]
    [ drop ]
} [
    ! Not flushed because the first argument to <array> can be
    ! something random which would cause an exception.
    [ f <array> drop ] optimize-quot

    ! This call is not flushed because the integer can be outside
    ! array-capacity-interval
    [ { integer } declare f <array> drop ] optimize-quot

    ! Flushed because the declaration guarantees that the integer is
    ! within the array-capacity-interval.
    [ { integer-array-capacity } declare f <array> drop ] optimize-quot
] unit-test

{ [ f <array> drop ] } [ [ f <array> drop ] optimize-quot ] unit-test

: call-recursive-dce-7 ( obj -- elt ? )
    dup 5 = [ t ] [ dup [ call-recursive-dce-7 ] [ drop f f ] if ] if ; inline recursive

[ [ call-recursive-dce-7 ] optimize-quot ] must-not-fail

{ [ /i ] } [ [ /mod drop ] optimize-quot ] unit-test

{ [ mod ] } [ [ /mod nip ] optimize-quot ] unit-test

{ [ fixnum/i ] } [ [ { fixnum fixnum } declare /mod drop ] optimize-quot ] unit-test

{ [ fixnum-mod ] } [ [ { fixnum fixnum } declare /mod nip ] optimize-quot ] unit-test

{ [ bignum/i ] } [ [ { bignum bignum } declare /mod drop ] optimize-quot ] unit-test

{ [ bignum-mod ] } [ [ { bignum bignum } declare /mod nip ] optimize-quot ] unit-test

{ [ /i ] } [ [ /mod drop ] optimize-quot ] unit-test

{ [ mod ] } [ [ /mod nip ] optimize-quot ] unit-test
