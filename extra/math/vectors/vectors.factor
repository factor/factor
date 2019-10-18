! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel sequences math math.functions hints
float-arrays ;
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

HINTS: vneg { float-array array } ;
HINTS: norm-sq { float-array array } ;
HINTS: norm { float-array array } ;
HINTS: normalize { float-array array } ;

HINTS: n*v * { float-array array } ;
HINTS: v*n { float-array array } * ;
HINTS: n/v * { float-array array } ;
HINTS: v/n { float-array array } * ;

HINTS: v+ { float-array array } { float-array array } ;
HINTS: v- { float-array array } { float-array array } ;
HINTS: v* { float-array array } { float-array array } ;
HINTS: v/ { float-array array } { float-array array } ;
HINTS: vmax { float-array array } { float-array array } ;
HINTS: vmin { float-array array } { float-array array } ;
HINTS: v. { float-array array } { float-array array } ;
