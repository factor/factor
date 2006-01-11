! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: math
USING: arrays generic kernel sequences ;

: vneg ( v -- v ) [ neg ] map ;

: n*v ( n v -- v ) [ * ] map-with ;
: v*n ( v n -- v ) swap n*v ;
: n/v ( n v -- v ) [ / ] map-with ;
: v/n ( v n -- v ) swap [ swap / ] map-with ;

: v+   ( v v -- v ) [ + ] 2map ;
: v-   ( v v -- v ) [ - ] 2map ;
: v*   ( v v -- v ) [ * ] 2map ;
: v/   ( v v -- v ) [ / ] 2map ;
: vmax ( v v -- v ) [ max ] 2map ;
: vmin ( v v -- v ) [ min ] 2map ;

: v. ( v v -- x ) 0 [ * + ] 2reduce ;
: norm-sq ( v -- n ) 0 [ absq + ] reduce ;
: norm ( vec -- n ) norm-sq sqrt ;
: normalize ( vec -- uvec ) dup norm v/n ;

: sum ( v -- n ) 0 [ + ] reduce ;
: product ( v -- n ) 1 [ * ] reduce ;

: set-axis ( x y axis -- v )
    dup length [ >r 0 = pick pick ? r> swap nth ] 2map 2nip ;
