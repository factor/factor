! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs namespaces sequences kernel math combinators sets
disjoint-sets fry stack-checker.state compiler.tree.copy-equiv ;
IN: compiler.tree.escape-analysis.allocations

! A map from values to one of the following:
! - f -- initial status, assigned to values we have not seen yet;
!        may potentially become an allocation later
! - a sequence of values -- potentially unboxed tuple allocations
! - t -- not allocated locally, can never be unboxed

SYMBOL: allocations

: (allocation) resolve-copy allocations get ; inline

: allocation ( value -- allocation ) (allocation) at ;

: record-allocation ( allocation value -- ) (allocation) set-at ;

: record-allocations ( allocations values -- )
    [ record-allocation ] 2each ;

! We track escaping values with a disjoint set.
SYMBOL: escaping-values

SYMBOL: +escaping+

: <escaping-values> ( -- disjoint-set )
    <disjoint-set> +escaping+ over add-atom ;

: init-escaping-values ( -- )
    copies get assoc>disjoint-set +escaping+ over add-atom
    escaping-values set ;

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
