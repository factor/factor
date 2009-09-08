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

<PRIVATE

: 2tetra@ ( p q r s t u v w quot -- )
    dup [ [ 2bi@ ] curry 4dip ] dip 2bi@ ; inline

PRIVATE>

: trilerp ( aaa baa aba bba aab bab abb bbb {t,u,v} -- a_tuv )
    [ first lerp ] [ second lerp ] [ third lerp ] tri-curry
    [ 2tetra@ ] [ 2bi@ ] [ call ] tri* ;

: bilerp ( aa ba ab bb {t,u} -- a_tu )
    [ first lerp ] [ second lerp ] bi-curry
    [ 2bi@ ] [ call ] bi* ;

: vlerp ( a b t -- a_t )
    [ lerp ] 3map ;

: vnlerp ( a b t -- a_t )
    [ lerp ] curry 2map ;

: vbilerp ( aa ba ab bb {t,u} -- a_tu )
    [ first vnlerp ] [ second vnlerp ] bi-curry
    [ 2bi@ ] [ call ] bi* ;

: v~ ( a b epsilon -- ? )
    [ ~ ] curry 2all? ;

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

HINTS: bilerp { object object object object array } ;
HINTS: trilerp { object object object object object object object object array } ;
