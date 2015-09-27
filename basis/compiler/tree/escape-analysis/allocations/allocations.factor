! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators disjoint-sets fry kernel
namespaces sequences stack-checker.values ;
IN: compiler.tree.escape-analysis.allocations

SYMBOL: value-classes

: value-class ( value -- class ) value-classes get at ;

: set-value-class ( class value -- ) value-classes get set-at ;

SYMBOL: allocations

: (allocation) ( -- allocations )
    allocations get ; inline

: allocation ( value -- allocation )
    (allocation) at ;

: record-allocation ( allocation value -- )
    (allocation) set-at ;

: record-allocations ( allocations values -- )
    (allocation) '[ _ set-at ] 2each ;

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

: add-escaping-value ( value -- )
    [
        allocation {
            { [ dup not ] [ drop ] }
            { [ dup t eq? ] [ drop ] }
            [ [ add-escaping-value ] each ]
        } cond
    ]
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
    {
        { [ dup not ] [ ] }
        { [ dup t eq? ] [ ] }
        [ [ <value> [ introduce-value ] [ copy-value ] [ ] tri ] map ]
    } cond ;

: copy-value ( from to -- )
    [ equate-values ]
    [ [ allocation copy-allocation ] dip record-allocation ]
    2bi ;

: copy-values ( from to -- )
    [ copy-value ] 2each ;

: copy-slot-value ( out slot# in -- )
    allocation {
        { [ dup not ] [ 3drop ] }
        { [ dup t eq? ] [ 3drop ] }
        [ nth swap copy-value ]
    } cond ;

SYMBOL: escaping-allocations

: compute-escaping-allocations ( -- )
    allocations get escaping-values get
    '[ drop _ (escaping-value?) ] assoc-filter
    escaping-allocations set ;

: escaping-allocation? ( value -- ? )
    escaping-allocations get key? ;

: unboxed-allocation ( value -- allocation/f )
    dup escaping-allocation? [ drop f ] [ allocation ] if ;

: unboxed-slot-access? ( value -- ? )
    slot-accesses get at*
    [ value>> unboxed-allocation >boolean ] when ;
