USING: kernel sequences arrays accessors tuple-arrays
math.order sorting math assocs locals namespaces ;
IN: interval-maps

TUPLE: interval-map array ;

<PRIVATE
TUPLE: interval-node from to value ;

: fixup-value ( value ? -- value/f ? )
    [ drop f f ] unless* ;

: find-interval ( key interval-map -- i )
    [ from>> <=> ] binsearch ;

: interval-contains? ( object interval-node -- ? )
    [ from>> ] [ to>> ] bi between? ;

: all-intervals ( sequence -- intervals )
    [ >r dup number? [ dup 2array ] when r> ] assoc-map
    { } assoc-like ;

: disjoint? ( node1 node2 -- ? )
    [ to>> ] [ from>> ] bi* < ;

: ensure-disjoint ( intervals -- intervals )
    dup [ disjoint? ] monotonic?
    [ "Intervals are not disjoint" throw ] unless ;

: >intervals ( specification -- intervals )
    [ >r first2 r> interval-node boa ] { } assoc>map ;
PRIVATE>

: interval-at* ( key map -- value ? )
    array>> [ find-interval ] 2keep swapd nth
    [ nip value>> ] [ interval-contains? ] 2bi
    fixup-value ;

: interval-at ( key map -- value ) interval-at* drop ;
: interval-key? ( key map -- ? ) interval-at* nip ;

: <interval-map> ( specification -- map )
    all-intervals [ [ first second ] compare ] sort
    >intervals ensure-disjoint >tuple-array
    interval-map boa ;

:: coalesce ( alist -- specification )
    ! Only works with integer keys, because they're discrete
    ! Makes 2array keys
    [
        alist sort-keys unclip first2 dupd roll
        [| oldkey oldval key val | ! Underneath is start
            oldkey 1+ key =
            oldval val = and
            [ oldkey 2array oldval 2array , key ] unless
            key val
        ] assoc-each [ 2array ] bi@ ,
    ] { } make ;
