USING: kernel sequences arrays accessors
math.order sorting math assocs locals namespaces ;
IN: interval-maps

TUPLE: interval-map array ;

<PRIVATE
TUPLE: interval-node from to value ;
: range ( node -- from to ) [ from>> ] [ to>> ] bi ;

: fixup-value ( value ? -- value/f ? )
    [ drop f f ] unless* ;

: find-interval ( key interval-map -- i )
    [ from>> <=> ] binsearch ;

GENERIC: >interval ( object -- 2array )
M: number >interval dup 2array ;
M: sequence >interval ;

: all-intervals ( sequence -- intervals )
    [ >r >interval r> ] assoc-map ;

: disjoint? ( node1 node2 -- ? )
    [ to>> ] [ from>> ] bi* < ;

: ensure-disjoint ( intervals -- intervals )
    dup [ disjoint? ] monotonic?
    [ "Intervals are not disjoint" throw ] unless ;

: interval-contains? ( object interval-node -- ? )
    range between? ;
PRIVATE>

: interval-at* ( key map -- value ? )
    array>> [ find-interval ] 2keep swapd nth
    [ nip value>> ] [ interval-contains? ] 2bi
    fixup-value ;

: interval-at ( key map -- value ) interval-at* drop ;
: interval-key? ( key map -- ? ) interval-at* nip ;

: <interval-map> ( specification -- map )
    all-intervals { } assoc-like
    [ [ first second ] compare ] sort
    [ >r first2 r> interval-node boa ] { } assoc>map
    ensure-disjoint interval-map boa ;

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
