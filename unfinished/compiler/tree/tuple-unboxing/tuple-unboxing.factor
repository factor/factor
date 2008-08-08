! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces assocs accessors kernel combinators
classes.algebra sequences sequences.deep slots.private
classes.tuple.private math math.private arrays
compiler.tree
compiler.tree.intrinsics
compiler.tree.combinators
compiler.tree.escape-analysis.simple
compiler.tree.escape-analysis.allocations ;
IN: compiler.tree.tuple-unboxing

! This pass must run after escape analysis

GENERIC: unbox-tuples* ( node -- node/nodes )

: unbox-output? ( node -- values )
    out-d>> first unboxed-allocation ;

: (expand-#push) ( object value -- nodes )
    dup unboxed-allocation dup [
        [ object-slots ] [ drop ] [ ] tri*
        [ (expand-#push) ] 2map
    ] [
        drop #push
    ] if ;

: expand-#push ( #push -- nodes )
    [ literal>> ] [ out-d>> first ] bi (expand-#push) ;

M: #push unbox-tuples* ( #push -- nodes )
    dup unbox-output? [ expand-#push ] when ;

: unbox-<tuple-boa> ( #call -- nodes )
    dup unbox-output? [ in-d>> 1 tail* #drop ] when ;

: unbox-<complex> ( #call -- nodes )
    dup unbox-output? [ drop { } ] when ;

: (flatten-values) ( values -- values' )
    [ dup unboxed-allocation [ (flatten-values) ] [ ] ?if ] map ;

: flatten-values ( values -- values' )
    (flatten-values) flatten ;

: flatten-value ( values -- values )
    [ unboxed-allocation ] [ 1array ] bi or ;

: prepare-slot-access ( #call -- tuple-values outputs slot-values )
    [ in-d>> first flatten-value ]
    [ out-d>> flatten-values ]
    [
        out-d>> first slot-accesses get at
        [ slot#>> ] [ value>> ] bi allocation nth flatten-value
    ] tri ;

: slot-access-shuffle ( tuple-values outputs slot-values -- #shuffle )
    [ drop ] [ zip ] 2bi #shuffle ;

: unbox-slot-access ( #call -- nodes )
    dup out-d>> first unboxed-slot-access? [
        [ in-d>> second 1array #drop ]
        [ prepare-slot-access slot-access-shuffle ]
        bi 2array
    ] when ;

M: #call unbox-tuples*
    dup word>> {
        { \ <immutable-tuple-boa> [ unbox-<tuple-boa> ] }
        { \ <complex> [ unbox-<complex> ] }
        { \ slot [ unbox-slot-access ] }
        [ drop ]
    } case ;

M: #copy unbox-tuples*
    [ flatten-values ] change-in-d
    [ flatten-values ] change-out-d ;

M: #>r unbox-tuples*
    [ flatten-values ] change-in-d
    [ flatten-values ] change-out-r ;

M: #r> unbox-tuples*
    [ flatten-values ] change-in-r
    [ flatten-values ] change-out-d ;

M: #shuffle unbox-tuples*
    [ flatten-values ] change-in-d
    [ flatten-values ] change-out-d
    [ unzip [ flatten-values ] bi@ zip ] change-mapping ;

M: #terminate unbox-tuples*
    [ flatten-values ] change-in-d ;

! These nodes never participate in unboxing
M: #return unbox-tuples* ;

M: #introduce unbox-tuples* ;

: unbox-tuples ( nodes -- nodes ) [ unbox-tuples* ] map-nodes ;
