! Copyright (C) 2008, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators disjoint-sets fry kernel
namespaces sequences stack-checker.values ;
IN: compiler.tree.escape-analysis.allocations

SYMBOL: value-classes

: value-class ( value -- class ) value-classes get at ;

: set-value-class ( class value -- ) value-classes get set-at ;

SYMBOL: allocations

: allocation ( value -- allocation )
    allocations get at ;

: record-allocation ( allocation value -- )
    allocations get set-at ;

: record-allocations ( allocations values -- )
    allocations get '[ _ set-at ] 2each ;

SYMBOL: slot-accesses

TUPLE: slot-access slot# value ;

C: <slot-access> slot-access

: record-slot-access ( out slot# in -- )
    <slot-access> swap slot-accesses get set-at ;

SYMBOL: escaping-values

SYMBOL: +escaping+

: <escaping-values> ( -- disjoint-set )
    <disjoint-set> +escaping+ over add-atom ;

: init-escaping-values ( -- )
    <escaping-values> escaping-values set ;

: (introduce-value) ( values escaping-values -- )
    2dup disjoint-set-member?
    [ 2drop ] [ add-atom ] if ; inline

: introduce-value ( values -- )
    escaping-values get (introduce-value) ;

: introduce-values ( values -- )
    escaping-values get '[ _ (introduce-value) ] each ;

: <slot-value> ( -- value )
    <value> dup introduce-value ;

: merge-values ( in-values out-value -- )
    escaping-values get equate-all-with ;

: merge-slots ( values -- value )
    <slot-value> [ merge-values ] keep ;

: equate-values ( value1 value2 -- )
    escaping-values get equate ;

DEFER: add-escaping-values

: add-escaping-value ( value -- )
    [ allocation dup boolean? [ drop ] [ add-escaping-values ] if ]
    [ +escaping+ equate-values ] bi ;

: add-escaping-values ( values -- )
    [ add-escaping-value ] each ;

: unknown-allocation ( value -- )
    [ add-escaping-value ]
    [ t swap record-allocation ]
    bi ;

: unknown-allocations ( values -- )
    [ unknown-allocation ] each ;

: (escaping-value?) ( value escaping-values -- ? )
    +escaping+ swap equiv? ; inline

: escaping-value? ( value -- ? )
    escaping-values get (escaping-value?) ;

DEFER: copy-value

: copy-allocation ( allocation -- allocation' )
    dup boolean? [
        [ <value> [ introduce-value ] [ copy-value ] [ ] tri ] map
    ] unless ;

:: (copy-value) ( from to allocations -- )
    from to equate-values
    from allocations at copy-allocation to allocations set-at ;

: copy-value ( from to -- )
    allocations get (copy-value) ;

: copy-values ( from to -- )
    allocations get '[ _ (copy-value) ] 2each ;

: copy-slot-value ( out slot# in -- )
    allocation dup boolean?
    [ 3drop ] [ nth swap copy-value ] if ;

SYMBOL: escaping-allocations

: compute-escaping-allocations ( -- )
    allocations get escaping-values get
    '[ _ (escaping-value?) ] filter-keys
    escaping-allocations set ;

: escaping-allocation? ( value -- ? )
    escaping-allocations get key? ;

: unboxed-allocation ( value -- allocation/f )
    dup escaping-allocation? [ drop f ] [ allocation ] if ;

: unboxed-slot-access? ( value -- ? )
    slot-accesses get at*
    [ value>> unboxed-allocation >boolean ] when ;
