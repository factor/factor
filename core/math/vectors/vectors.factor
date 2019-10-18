! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel sequences math math.functions ;
IN: math.vectors

: vneg ( u -- v ) [ neg ] map ;

: v*n ( u n -- v ) [ * ] curry map ;
: n*v ( n u -- v ) [ * ] curry* map ;
: v/n ( u n -- v ) [ / ] curry map ;
: n/v ( n u -- v ) [ / ] curry* map ;

: v+   ( u v -- w ) [ + ] 2map ;
: v-   ( u v -- w ) [ - ] 2map ;
: [v-] ( u v -- w ) [ [-] ] 2map ;
: v*   ( u v -- w ) [ * ] 2map ;
: v/   ( u v -- w ) [ / ] 2map ;
: vmax ( u v -- w ) [ max ] 2map ;
: vmin ( u v -- w ) [ min ] 2map ;

: v. ( u v -- x ) 0 [ * + ] 2reduce ;
: norm-sq ( v -- x ) 0 [ absq + ] reduce ;
: norm ( v -- x ) norm-sq sqrt ;
: normalize ( u -- v ) dup norm v/n ;

: set-axis ( u v axis -- w )
    dup length [ >r zero? pick pick ? r> swap nth ] 2map 2nip ;

: sum ( seq -- n ) 0 [ + ] reduce ;
: product ( seq -- n ) 1 [ * ] reduce ;

: infimum ( seq -- n ) dup first [ min ] reduce ;
: supremum ( seq -- n ) dup first [ max ] reduce ;
