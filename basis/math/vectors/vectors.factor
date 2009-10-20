! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays alien.c-types assocs kernel sequences math math.functions
hints math.order math.libm math.floats.private fry combinators
byte-arrays accessors locals ;
QUALIFIED-WITH: alien.c-types c
IN: math.vectors

MIXIN: simd-128
MIXIN: simd-256

GENERIC: element-type ( obj -- c-type )
M: object element-type drop f ; inline

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

<PRIVATE

: if-both-floats ( x y p q -- )
    [ 2dup [ float? ] both? ] 2dip if ; inline

PRIVATE>

: vmax ( u v -- w ) [ [ float-max ] [ max ] if-both-floats ] 2map ;
: vmin ( u v -- w ) [ [ float-min ] [ min ] if-both-floats ] 2map ;

: v+- ( u v -- w )
    [ t ] 2dip
    [ [ not ] 2dip pick [ + ] [ - ] if ] 2map
    nip ;

<PRIVATE

: 2saturate-map ( u v quot -- w )
    pick element-type '[ @ _ c-type-clamp ] 2map ; inline

PRIVATE>

: vs+ ( u v -- w ) [ + ] 2saturate-map ;
: vs- ( u v -- w ) [ - ] 2saturate-map ;
: vs* ( u v -- w ) [ * ] 2saturate-map ;

: vabs ( u -- v ) [ abs ] map ;
: vsqrt ( u -- v ) [ >float fsqrt ] map ;

<PRIVATE

: fp-bitwise-op ( x y seq quot -- z )
    swap element-type {
        { c:double [ [ [ double>bits ] bi@ ] dip call bits>double ] }
        { c:float  [ [ [ float>bits ] bi@ ] dip call bits>float   ] }
        [ drop call ]
    } case ; inline

: fp-bitwise-unary ( x seq quot -- z )
    swap element-type {
        { c:double [ [ double>bits ] dip call bits>double ] }
        { c:float  [ [ float>bits  ] dip call bits>float  ] }
        [ drop call ]
    } case ; inline

: element>bool ( x seq -- ? )
    element-type [ [ f ] when-zero ] when ; inline

: bitandn ( x y -- z ) [ bitnot ] dip bitand ; inline

GENERIC: new-underlying ( underlying seq -- seq' )

: change-underlying ( seq quot -- seq' )
    '[ underlying>> @ ] keep new-underlying ; inline

PRIVATE>

: vbitand ( u v -- w ) over '[ _ [ bitand ] fp-bitwise-op ] 2map ;
: vbitandn ( u v -- w ) over '[ _ [ bitandn ] fp-bitwise-op ] 2map ;
: vbitor ( u v -- w ) over '[ _ [ bitor ] fp-bitwise-op ] 2map ;
: vbitxor ( u v -- w ) over '[ _ [ bitxor ] fp-bitwise-op ] 2map ;
: vbitnot ( u -- w ) dup '[ _ [ bitnot ] fp-bitwise-unary ] map ;

:: vbroadcast ( u n -- v ) u length n u nth <repetition> u like ;

: vshuffle-elements ( u perm -- v )
    swap [ '[ _ nth ] ] keep map-as ;

: vshuffle-bytes ( u perm -- v )
    underlying>> [
        swap [ '[ 15 bitand _ nth ] ] keep map-as
    ] curry change-underlying ;

GENERIC: vshuffle ( u perm -- v )
M: array vshuffle ( u perm -- v )
    vshuffle-elements ; inline
M: simd-128 vshuffle ( u perm -- v )
    vshuffle-bytes ; inline

: vlshift ( u n -- w ) '[ _ shift ] map ;
: vrshift ( u n -- w ) neg '[ _ shift ] map ;

: hlshift ( u n -- w ) '[ _ <byte-array> prepend 16 head ] change-underlying ;
: hrshift ( u n -- w ) '[ _ <byte-array> append 16 tail* ] change-underlying ;

: (vmerge-head) ( u v -- h )
    over length 2 /i '[ _ head-slice ] bi@ [ zip ] keep concat-as ;
: (vmerge-tail) ( u v -- t )
    over length 2 /i '[ _ tail-slice ] bi@ [ zip ] keep concat-as ;

: (vmerge) ( u v -- h t )
    [ (vmerge-head) ] [ (vmerge-tail) ] 2bi ; inline

: vmerge ( u v -- w ) [ zip ] keep concat-as ;

: vand ( u v -- w )  over '[ [ _ element>bool ] bi@ and ] 2map ;
: vandn ( u v -- w ) over '[ [ _ element>bool ] bi@ [ not ] dip and ] 2map ;
: vor  ( u v -- w )  over '[ [ _ element>bool ] bi@ or  ] 2map ;
: vxor ( u v -- w )  over '[ [ _ element>bool ] bi@ xor ] 2map ;
: vnot ( u -- w )    dup '[ _ element>bool not ] map ;

: vall? ( v -- ? ) dup '[ _ element>bool ] all? ;
: vany? ( v -- ? ) dup '[ _ element>bool ] any? ;
: vnone? ( v -- ? ) dup '[ _ element>bool not ] all? ;

: v<  ( u v -- w ) [ <   ] 2map ;
: v<= ( u v -- w ) [ <=  ] 2map ;
: v>= ( u v -- w ) [ >=  ] 2map ;
: v>  ( u v -- w ) [ >   ] 2map ;
: vunordered? ( u v -- w ) [ unordered? ] 2map ;
: v=  ( u v -- w ) [ =   ] 2map ;

: v? ( mask true false -- w )
    [ vand ] [ vandn ] bi-curry* bi vor ; inline

: vfloor    ( u -- v ) [ floor ] map ;
: vceiling  ( u -- v ) [ ceiling ] map ;
: vtruncate ( u -- v ) [ truncate ] map ;

: vsupremum ( seq -- vmax ) [ ] [ vmax ] map-reduce ; 
: vinfimum ( seq -- vmin ) [ ] [ vmin ] map-reduce ; 

: v. ( u v -- x ) [ conjugate * ] [ + ] 2map-reduce ;
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
    [ 2tetra@ ] [ 2bi@ ] [ call ] tri* ; inline

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
