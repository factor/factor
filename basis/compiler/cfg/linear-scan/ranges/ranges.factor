USING: accessors arrays fry grouping kernel math math.order sequences ;
IN: compiler.cfg.linear-scan.ranges

! Data definitions
TUPLE: live-range from to ;

C: <live-range> live-range

! Range utilities
: intersect-range ( range1 range2 -- n/f )
    2dup [ from>> ] bi@ > [ swap ] when
    2dup [ to>> ] [ from>> ] bi* >=
    [ nip from>> ] [ 2drop f ] if ;

: range-covers? ( n range -- ? )
    [ from>> ] [ to>> ] bi between? ;

: split-range ( live-range n -- before after )
    [ [ from>> ] dip <live-range> ] [ 1 + swap to>> <live-range> ] 2bi ;

! Range sequence utilities
: extend-ranges? ( n ranges -- ? )
    [ drop f ] [ last from>> >= ] if-empty ;

: extend-ranges ( from to ranges -- )
    last [ max ] change-to [ min ] change-from drop ;

: add-new-range ( from to ranges -- )
    [ <live-range> ] dip push ;

: add-range ( from to ranges -- )
    2dup extend-ranges? [ extend-ranges ] [ add-new-range ] if ;

: ranges-cover? ( n ranges -- ? )
    [ range-covers? ] with any? ;

: intersect-ranges ( ranges1 ranges2 -- n/f )
    '[ _ [ intersect-range ] with map-find drop ] map-find drop ;

: shorten-ranges ( n ranges -- )
    dup empty? [ dupd add-new-range ] [ last from<< ] if ;

: split-last-range? ( last n -- ? )
    swap to>> <= ;

: split-last-range ( before after last n -- before' after' )
    split-range [ [ but-last ] dip suffix ] [ prefix ] bi-curry* bi* ;

: split-ranges ( live-ranges n -- before after )
    [ '[ from>> _ <= ] partition ]
    [
        [ over last ] dip 2dup split-last-range?
        [ split-last-range ] [ 2drop ] if
    ] bi ;

: valid-ranges? ( ranges -- ? )
    [ [ [ from>> ] [ to>> ] bi <= ] all? ]
    [ [ [ to>> ] [ from>> ] bi* <= ] monotonic? ] bi and ;

: fix-lower-bound ( n ranges -- ranges' )
    over '[ to>> _ >= ] filter [ first from<< ] keep ;

: fix-upper-bound ( n ranges -- ranges' )
    over '[ from>> _ <= ] filter [ last to<< ] keep ;

: ranges-endpoints ( ranges -- start end )
    [ first from>> ] [ last to>> ] bi ;
