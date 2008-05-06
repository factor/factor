USING: kernel sequences arrays math.intervals accessors
math.order sorting math assocs locals namespaces ;
IN: interval-maps

TUPLE: interval-map array ;

<PRIVATE
TUPLE: interval-node interval value ;

: fixup-value ( value ? -- value/f ? )
    [ drop f f ] unless* ;

: find-interval ( key interval-map -- i )
    [ interval>> from>> first <=> ] binsearch ;

GENERIC: >interval ( object -- interval )
M: number >interval [a,a] ;
M: sequence >interval first2 [a,b] ;
M: interval >interval ;

: all-intervals ( sequence -- intervals )
    [ >r >interval r> ] assoc-map ;

: ensure-disjoint ( intervals -- intervals )
    dup keys [ interval-intersect not ] monotonic?
    [ "Intervals are not disjoint" throw ] unless ;


PRIVATE>

: interval-at* ( key map -- value ? )
    array>> [ find-interval ] 2keep swapd nth
    [ nip value>> ] [ interval>> interval-contains? ] 2bi
    fixup-value ;

: interval-at ( key map -- value ) interval-at* drop ;
: interval-key? ( key map -- ? ) interval-at* nip ;

: <interval-map> ( specification -- map )
    all-intervals { } assoc-like
    [ [ first to>> ] compare ] sort ensure-disjoint
    [ interval-node boa ] { } assoc>map
    interval-map boa ;

:: coalesce ( assoc -- specification )
    ! Only works with integer keys, because they're discrete
    ! Makes 2array keys
    [
        assoc sort-keys unclip first2 dupd roll
        [| oldkey oldval key val | ! Underneath is start
            oldkey 1+ key =
            oldval val = and
            [ oldkey 2array oldval 2array , key ] unless
            key val
        ] assoc-each [ 2array ] bi@ ,
    ] { } make ;
