! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences arrays accessors grouping math.order
sorting binary-search math assocs locals namespaces make ;
IN: interval-maps

TUPLE: interval-map array ;

<PRIVATE

ALIAS: start first
ALIAS: end second
ALIAS: value third

: find-interval ( key interval-map -- interval-node )
    array>> [ start <=> ] with search nip ;

: interval-contains? ( key interval-node -- ? )
    first2 between? ;

: all-intervals ( sequence -- intervals )
    [ [ dup number? [ dup 2array ] when ] dip ] { } assoc-map-as ;

: disjoint? ( node1 node2 -- ? )
    [ end ] [ start ] bi* < ;

: ensure-disjoint ( intervals -- intervals )
    dup [ disjoint? ] monotonic?
    [ "Intervals are not disjoint" throw ] unless ;

: >intervals ( specification -- intervals )
    [ suffix ] { } assoc>map concat 3 group ;

PRIVATE>

: interval-at* ( key map -- value ? )
    [ drop ] [ find-interval ] 2bi
    [ nip ] [ interval-contains? ] 2bi
    [ value t ] [ drop f f ] if ;

: interval-at ( key map -- value ) interval-at* drop ;

: interval-key? ( key map -- ? ) interval-at* nip ;

: interval-values ( map -- values )
    array>> [ value ] map ;

: <interval-map> ( specification -- map )
    all-intervals [ first second ] sort-with
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
