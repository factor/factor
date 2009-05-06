! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel sequences math math.functions hints
math.order ;
IN: math.vectors

: vneg ( u -- v ) [ neg ] map ;

: v+n ( u n -- v ) [ + ] curry map ;
: n+v ( n u -- v ) [ + ] with map ;
: v-n ( u n -- v ) [ - ] curry map ;
: n-v ( n u -- v ) [ - ] with map ;

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

: vfloor    ( v -- _v_ ) [ floor    ] map ;
: vceiling  ( v -- ^v^ ) [ ceiling  ] map ;
: vtruncate ( v -- -v- ) [ truncate ] map ;

: vsupremum ( seq -- vmax ) [ ] [ vmax ] map-reduce ; 
: vinfimum ( seq -- vmin ) [ ] [ vmin ] map-reduce ; 

: v. ( u v -- x ) [ * ] [ + ] 2map-reduce ;
: norm-sq ( v -- x ) [ absq ] [ + ] map-reduce ;
: norm ( v -- x ) norm-sq sqrt ;
: normalize ( u -- v ) dup norm v/n ;

: distance ( u v -- x ) [ - absq ] [ + ] 2map-reduce sqrt ;

: set-axis ( u v axis -- w )
    [ [ zero? 2over ? ] dip swap nth ] map-index 2nip ;

: vlerp ( a b t -- a_t )
    [ lerp ] 3map ;

: vnlerp ( a b t -- a_t )
    [ lerp ] curry 2map ;

HINTS: vneg { array } ;
HINTS: norm-sq { array } ;
HINTS: norm { array } ;
HINTS: normalize { array } ;
HINTS: distance { array array } ;

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

HINTS: vlerp { array array array } ;
HINTS: vnlerp { array array object } ;
