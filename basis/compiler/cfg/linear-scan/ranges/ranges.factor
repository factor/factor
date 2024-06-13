USING: arrays grouping kernel math math.order sequences ;
IN: compiler.cfg.linear-scan.ranges

! Range utilities
: intersect-range ( r1 r2 -- n/f )
    [ [ first ] bi@ > ] 2check [ swap ] when
    [ [ second ] [ first ] bi* >= ] 2check
    [ nip first ] [ 2drop f ] if ;

: split-range ( range n -- before after )
    swap first2 pick 1 + [ swap 2array ] 2bi@  ;

! Range sequence utilities
: add-new-range ( from to ranges -- )
    [ 2array ] dip push ;

: extend-last? ( to ranges -- ? )
    [ drop f ] [ last first 1 - >= ] if-empty ;

: add-range ( from to ranges -- )
    [ extend-last? ] 2check [
        [ nip last second 2array ] keep set-last
    ] [ add-new-range ] if ;

: ranges-cover? ( n ranges -- ? )
    [ first2 between? ] with any? ;

: intersect-ranges ( ranges1 ranges2 -- n/f )
    '[ _ [ intersect-range ] with map-find drop ] map-find drop ;

: shorten-ranges ( n ranges -- )
    [ empty? ] 1check [
        dupd add-new-range
    ] [
        [ last second 2array ] keep set-last
    ] if ;

: split-last-range ( before after last n -- before' after' )
    split-range [ [ but-last ] dip suffix ] [ prefix ] bi-curry* bi* ;

: split-last-range? ( last n -- ? )
    swap second <= ;

: split-ranges ( ranges n -- before after )
    [ '[ first _ <= ] partition ]
    [
        [ over last ] dip 2dup split-last-range?
        [ split-last-range ] [ 2drop ] if
    ] bi ;

: valid-ranges? ( ranges -- ? )
    [ [ first2 <= ] all? ]
    [ [ [ second ] [ first ] bi* <= ] monotonic? ] bi and ;

: fix-lower-bound ( n ranges -- ranges' )
    over '[ second _ >= ] filter unclip second swapd 2array prefix ;

: fix-upper-bound ( n ranges -- ranges' )
    over '[ first _ <= ] filter unclip-last first rot 2array suffix ;

: ranges-endpoints ( ranges -- start end )
    [ first first ] [ last last ] bi ;
