! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: math
USING: arrays generic kernel sequences ;

: vneg ( u -- v ) [ neg ] map ;

: n*v ( n u -- v ) [ * ] map-with ;
: v*n ( n u -- v ) swap n*v ;
: n/v ( n u -- v ) [ / ] map-with ;
: v/n ( u n -- v ) swap [ swap / ] map-with ;

: v+   ( u v -- w ) [ + ] 2map ;
: v-   ( u v -- w ) [ - ] 2map ;
: [v-] ( u v -- w ) [ [-] ] 2map ;
: v*   ( u v -- w ) [ * ] 2map ;
: v/   ( u v -- w ) [ / ] 2map ;
: vmax ( u v -- w ) [ max ] 2map ;
: vmin ( u v -- w ) [ min ] 2map ;

: v. ( v v -- x ) 0 [ * + ] 2reduce ;
: norm-sq ( v -- x ) 0 [ absq + ] reduce ;
: norm ( vec -- x ) norm-sq sqrt ;
: normalize ( u -- v ) dup norm v/n ;

: set-axis ( u v axis -- w )
    dup length [ >r zero? pick pick ? r> swap nth ] 2map 2nip ;

: sum ( seq -- n ) 0 [ + ] reduce ;
: product ( seq -- n ) 1 [ * ] reduce ;

: infimum ( seq -- n ) 1./0. [ min ] reduce ;
: supremum ( seq -- n ) -1./0. [ max ] reduce ;
