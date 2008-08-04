! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs namespaces sequences kernel math combinators sets
disjoint-sets fry stack-checker.state compiler.tree.copy-equiv ;
IN: compiler.tree.escape-analysis.allocations

! A map from values to sequences of values
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

! We track escaping values with a disjoint set.
SYMBOL: escaping-values

SYMBOL: +escaping+

: <escaping-values> ( -- disjoint-set )
    <disjoint-set> +escaping+ over add-atom ;

: init-escaping-values ( -- )
    copies get <escaping-values>
    [ '[ drop , add-atom ] assoc-each ]
    [ '[ , equate ] assoc-each ]
    [ nip escaping-values set ]
    2tri ;

: <slot-value> ( -- value )
    <value>
    [ introduce-value ]
    [ escaping-values get add-atom ]
    [ ]
    tri ;

: same-value ( in-value out-value -- )
    over [
        [ is-copy-of ] [ escaping-values get equate ] 2bi
    ] [ 2drop ] if ;

: record-slot-access ( out slot# in -- )
    over zero? [ 3drop ] [ allocation ?nth swap same-value ] if ;

: merge-values ( in-values out-value -- )
    escaping-values get '[ , , equate ] each ;

: merge-slots ( values -- value )
    dup [ ] contains? [
        <slot-value> [ merge-values ] keep
    ] [ drop f ] if ;

: add-escaping-values ( values -- )
    escaping-values get
    '[ +escaping+ , equate ] each ;

: escaping-value? ( value -- ? )
    +escaping+ escaping-values get equiv? ;

SYMBOL: escaping-allocations

: compute-escaping-allocations ( -- )
    allocations get
    [ drop escaping-value? ] assoc-filter
    escaping-allocations set ;

: escaping-allocation? ( value -- ? )
    escaping-allocations get key? ;
