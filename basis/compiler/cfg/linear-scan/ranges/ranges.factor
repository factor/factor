USING: accessors kernel math math.order sequences ;
IN: compiler.cfg.linear-scan.ranges

! Data definitions
TUPLE: live-range from to ;

C: <live-range> live-range

! Range utilities
: range-covers? ( n range -- ? )
    [ from>> ] [ to>> ] bi between? ;

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

: shorten-ranges ( n ranges -- )
    dup empty? [ dupd add-new-range ] [ last from<< ] if ;
