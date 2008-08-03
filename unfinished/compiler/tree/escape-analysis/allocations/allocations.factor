! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs namespaces sequences kernel math combinators sets
fry stack-checker.state compiler.tree.copy-equiv
compiler.tree.escape-analysis.graph ;
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

! We track available values
SYMBOL: slot-graph

: merge-slots ( values -- value )
    dup [ ] contains? [
        <value>
        [ introduce-value ]
        [ slot-graph get add-edges ]
        [ ] tri
    ] [ drop f ] if ;

! A disqualified slot value is not available for unboxing. A
! tuple may be unboxed if none of its slots have been
! disqualified.

: disqualify ( slot-value -- )
    slot-graph get mark-vertex ;

SYMBOL: escaping-allocations

: compute-escaping-allocations ( -- )
    #! Any allocations involving unavailable slots are
    #! potentially escaping, and cannot be unboxed.
    allocations get
    slot-graph get marked-components
    '[ [ , key? ] contains? nip ] assoc-filter
    escaping-allocations set ;

: escaping-allocation? ( value -- ? )
    escaping-allocations get key? ;
