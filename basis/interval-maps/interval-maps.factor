! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs binary-search grouping kernel
locals make math math.order sequences sequences.private sorting ;
IN: interval-maps

TUPLE: interval-map { array array read-only } ;

<PRIVATE

ALIAS: start first-unsafe
ALIAS: end second-unsafe
ALIAS: value third-unsafe

: find-interval ( key interval-map -- interval-node )
    array>> [ start <=> ] with search nip ; inline

: interval-contains? ( key interval-node -- ? )
    first2-unsafe between? ; inline

: all-intervals ( sequence -- intervals )
    [ [ dup number? [ dup 2array ] when ] dip ] { } assoc-map-as ;

: disjoint? ( node1 node2 -- ? )
    [ end ] [ start ] bi* < ;

: ensure-disjoint ( intervals -- intervals )
    dup [ disjoint? ] monotonic?
    [ "Intervals are not disjoint" throw ] unless ;

: >intervals ( specification -- intervals )
    [ suffix ] { } assoc>map concat 3 group ;

ERROR: not-an-interval-map obj ;

: check-interval-map ( map -- map )
    dup interval-map? [ not-an-interval-map ] unless ; inline

PRIVATE>

: interval-at* ( key map -- value ? )
    check-interval-map
    [ drop ] [ find-interval ] 2bi
    [ nip ] [ interval-contains? ] 2bi
    [ value t ] [ drop f f ] if ; inline

: interval-at ( key map -- value ) interval-at* drop ;

: interval-key? ( key map -- ? ) interval-at* nip ;

: interval-values ( map -- values )
    check-interval-map array>> [ value ] map ;

: <interval-map> ( specification -- map )
    all-intervals [ first-unsafe second-unsafe ] sort-with
    >intervals ensure-disjoint interval-map boa ;

: <interval-set> ( specification -- map )
    dup zip <interval-map> ;

:: coalesce ( alist -- specification )
    ! Only works with integer keys, because they're discrete
    ! Makes 2array keys
    [
        alist sort-keys unclip swap [ first2 dupd ] dip
        [| oldkey oldval key val | ! Underneath is start
            oldkey 1 + key =
            oldval val = and
            [ oldkey 2array oldval 2array , key ] unless
            key val
        ] assoc-each [ 2array ] bi@ ,
    ] { } make ;
