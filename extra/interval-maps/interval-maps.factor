USING: kernel sequences arrays math.intervals accessors
math.order sorting math assocs  ;
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
    all-intervals ensure-disjoint
    [ [ first to>> ] compare ] sort
    [ interval-node boa ] { } assoc>map
    interval-map boa ;
