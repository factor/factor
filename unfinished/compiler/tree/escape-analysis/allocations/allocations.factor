! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs namespaces sequences kernel math combinators sets
stack-checker.state compiler.tree.copy-equiv ;
IN: compiler.tree.escape-analysis.allocations

SYMBOL: escaping

! A map from values to sequences of values or 'escaping'
SYMBOL: allocations

: allocation ( value -- allocation )
    resolve-copy allocations get at ;

: record-allocation ( allocation value -- )
    {
        { [ dup not ] [ 2drop ] }
        { [ over not ] [ allocations get delete-at drop ] }
        [ allocations get set-at ]
    } cond ;

: record-allocations ( allocations values -- )
    [ record-allocation ] 2each ;

: record-slot-access ( out slot# in -- )
    over zero? [ 3drop ] [ allocation ?nth swap is-copy-of ] if ;

! A map from values to sequences of values
SYMBOL: slot-merging

: merge-slots ( values -- value )
    dup [ ] contains? [
        <value>
        [ introduce-value ]
        [ slot-merging get set-at ]
        [ ] tri
    ] [ drop f ] if ;

! If an allocation's slot appears in this set, the allocation
! is disqualified from unboxing.
SYMBOL: disqualified

: disqualify ( slot-value -- )
    [ disqualified get conjoin ]
    [ slot-merging get at [ disqualify ] each ] bi ;

: escaping-allocation? ( value -- ? )
    allocation [ [ disqualified get key? ] contains? ] [ t ] if* ;
