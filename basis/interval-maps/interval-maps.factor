! Copyright (C) 2008 Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs binary-search classes grouping
kernel make math math.order sequences sequences.private
sorting ;
IN: interval-maps

! Intervals are triples of { start end value }
TUPLE: interval-map { array array read-only } ;

<PRIVATE

: find-interval ( key interval-map -- interval-node )
    array>> [ first-unsafe <=> ] with search nip ; inline

: interval-contains? ( key interval-node -- ? )
    first2-unsafe between? ; inline

: all-intervals ( sequence -- intervals )
    [ [ dup number? [ dup 2array ] when ] dip ] { } assoc-map-as ;

: disjoint? ( node1 node2 -- ? )
    [ second-unsafe ] [ first-unsafe ] bi* < ;

: ensure-disjoint ( intervals -- intervals )
    dup [ disjoint? ] monotonic?
    [ "Intervals are not disjoint" throw ] unless ;

: >intervals ( specification -- intervals )
    [ suffix ] { } assoc>map concat 3 group ;

PRIVATE>

: interval-at* ( key map -- value ? )
    interval-map check-instance
    [ drop ] [ find-interval ] 2bi
    [ nip ] [ interval-contains? ] 2bi
    [ third-unsafe t ] [ drop f f ] if ; inline

: interval-at ( key map -- value ) interval-at* drop ; inline

: interval-key? ( key map -- ? ) interval-at* nip ; inline

: interval-values ( map -- values )
    interval-map check-instance array>> [ third-unsafe ] map ;

: <interval-map> ( specification -- map )
    all-intervals [ first-unsafe second-unsafe ] sort-by
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
