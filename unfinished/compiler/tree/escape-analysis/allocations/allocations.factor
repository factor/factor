! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs namespaces sequences kernel math
combinators sets disjoint-sets fry stack-checker.state ;
IN: compiler.tree.escape-analysis.allocations

! A map from values to one of the following:
! - f -- initial status, assigned to values we have not seen yet;
!        may potentially become an allocation later
! - a sequence of values -- potentially unboxed tuple allocations
! - t -- not allocated in this procedure, can never be unboxed

SYMBOL: allocations

TUPLE: slot-access slot# value ;

C: <slot-access> slot-access

: (allocation) ( value -- value' allocations )
    allocations get ; inline

: allocation ( value -- allocation )
    (allocation) at dup slot-access? [
        [ slot#>> ] [ value>> allocation ] bi nth
        allocation
    ] when ;

: record-allocation ( allocation value -- )
    (allocation) set-at ;

: record-allocations ( allocations values -- )
    [ record-allocation ] 2each ;

! We track escaping values with a disjoint set.
SYMBOL: escaping-values

SYMBOL: +escaping+

: <escaping-values> ( -- disjoint-set )
    <disjoint-set> +escaping+ over add-atom ;

: init-escaping-values ( -- )
    <escaping-values> escaping-values set ;

: introduce-value ( values -- )
    escaping-values get add-atom ;

: introduce-values ( values -- )
    escaping-values get add-atoms ;

: <slot-value> ( -- value )
    <value> dup escaping-values get add-atom ;

: record-slot-access ( out slot# in -- )
    over zero? [ 3drop ] [
        <slot-access> swap record-allocation
    ] if ;

: merge-values ( in-values out-value -- )
    escaping-values get '[ , , equate ] each ;

: merge-slots ( values -- value )
    <slot-value> [ merge-values ] keep ;

: equate-values ( value1 value2 -- )
    escaping-values get equate ;

: add-escaping-value ( value -- )
    +escaping+ equate-values ;

: add-escaping-values ( values -- )
    escaping-values get
    '[ +escaping+ , equate ] each ;

: unknown-allocation ( value -- )
    [ add-escaping-value ]
    [ t swap record-allocation ]
    bi ;

: unknown-allocations ( values -- )
    [ unknown-allocation ] each ;

: escaping-value? ( value -- ? )
    +escaping+ escaping-values get equiv? ;

DEFER: copy-value

: copy-allocation ( allocation -- allocation' )
    {
        { [ dup not ] [ ] }
        { [ dup t eq? ] [ ] }
        [ [ <value> [ introduce-value ] [ copy-value ] [ ] tri ] map ]
    } cond ;

: copy-value ( from to -- )
    [ equate-values ]
    [ [ allocation copy-allocation ] dip record-allocation ]
    2bi ;

SYMBOL: escaping-allocations

: compute-escaping-allocations ( -- )
    allocations get
    [ drop escaping-value? ] assoc-filter
    escaping-allocations set ;

: escaping-allocation? ( value -- ? )
    escaping-allocations get key? ;

: unboxed-allocation ( value -- allocation/f )
    dup escaping-allocation? [ drop f ] [ allocation ] if ;

: unboxed-slot-access? ( value -- ? )
    (allocation) at dup slot-access?
    [ value>> unboxed-allocation >boolean ] [ drop f ] if ;

