! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler.tree.tuple-unboxing

! This pass must run after escape analysis

! Mapping from values to sequences of values
SYMBOL: unboxed-tuples

: unboxed-tuple ( value -- unboxed-tuple )
    unboxed-tuples get at ;

GENERIC: unbox-tuples* ( node -- )

: value-info-slots ( info -- slots )
    #! Delegation.
    [ info>> ] [ class>> ] bi {
        { [ dup tuple class<= ] [ drop 2 tail ] }
        { [ dup complex class<= ] [ drop ] }
    } cond ;

: prepare-unboxed-values ( #push -- values )
    out-d>> first unboxed-allocation ;

: prepare-unboxed-info ( #push -- infos values )
    dup prepare-unboxed-values dup
    [ [ node-output-infos first value-info-slots ] dip ]
    [ 2drop f f ]
    if ;

: expand-#push ( #push infos values -- )
    [ [ literal>> ] dip #push ] 2map >>body drop ;

M: #push unbox-tuples* ( #push -- )
    dup prepare-unboxed-info dup [ expand-#push ] [ 3drop ] if ;

: expand-<tuple-boa> ( #call values -- quot )
    [ drop in-d>> peek #drop ]
    [ [ in-d>> but-last ] dip #copy ]
    2bi 2array ;

: expand-<complex> ( #call values -- quot )
    [ in-d>> ] dip #copy 1array ;

: expand-constructor ( #call values -- )
    [ drop ] [ ] [ drop word>> ] 2tri {
        { <tuple-boa> [ expand-<tuple-boa> ] }
        { <complex> [ expand-<complex> ] }
    } case unbox-tuples >>body ;

: unbox-constructor ( #call -- )
    dup prepare-unboxed-values dup
    [ expand-constructor ] [ 2drop ] if ;

: (flatten-values) ( values -- values' )
    [ dup unboxed-allocation [ (flatten-values) ] [ ] ?if ] map ;

: flatten-values ( values -- values' )
    (flatten-values) flatten ;

: flatten-value ( values -- values )
    1array flatten-values ;

: prepare-slot-access ( #call -- tuple-values slot-values outputs )
    [ in-d>> first flatten-value ]
    [
        [ dup in-d>> second node-value-info literal>> ]
        [ out-d>> first unboxed-allocation ]
        bi nth flatten-value
    ]
    [ out-d>> flatten-values ]
    tri ;

: slot-access-shuffle ( tuple-values slot-values outputs -- #shuffle )
    [ nip ] [ zip ] 2bi #shuffle ;

: unbox-slot-access ( #call -- )
    dup unboxed-slot-access? [
        dup
        [ in-d>> second 1array #drop ]
        [ prepare-slot-access slot-access-shuffle ]
        bi 2array unbox-tuples >>body
    ] when drop ;

M: #call unbox-tuples* ( #call -- )
    dup word>> {
        { \ <tuple-boa> [ unbox-<tuple-boa> ] }
        { \ <complex> [ unbox-<complex> ] }
        { \ slot [ unbox-slot-access ] }
        [ 2drop ]
    } case ;

M: #copy ... ;

M: #>r ... ;

M: #r> ... ;

M: #shuffle ... ;

M: #terrible ... ;

! These nodes never participate in unboxing
M: #return drop ;

M: #introduce drop ;

: unbox-tuples ( nodes -- nodes )
    dup [ unbox-tuples* ] each-node ;
