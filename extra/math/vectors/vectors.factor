! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel sequences math math.functions hints
math.order ;
IN: math.vectors

: vneg ( u -- v ) [ neg ] map ;

: v*n ( u n -- v ) [ * ] curry map ;
: n*v ( n u -- v ) [ * ] with map ;
: v/n ( u n -- v ) [ / ] curry map ;
: n/v ( n u -- v ) [ / ] with map ;

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
    [ >r zero? 2over ? r> swap nth ] map-index 2nip ;

HINTS: vneg { array } ;
HINTS: norm-sq { array } ;
HINTS: norm { array } ;
HINTS: normalize { array } ;

HINTS: n*v { object array } ;
HINTS: v*n { array object } ;
HINTS: n/v { array } ;
HINTS: v/n { array object } ;

HINTS: v+ { array array } ;
HINTS: v- { array array } ;
HINTS: v* { array array } ;
HINTS: v/ { array array } ;
HINTS: vmax { array array } ;
HINTS: vmin { array array } ;
HINTS: v. { array array } ;
