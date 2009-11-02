! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays alien.c-types assocs kernel sequences math math.functions
hints math.order math.libm math.floats.private fry combinators
byte-arrays accessors locals ;
QUALIFIED-WITH: alien.c-types c
IN: math.vectors

GENERIC: vneg ( u -- v )
M: object vneg [ neg ] map ;

GENERIC# v+n 1 ( u n -- v )
M: object v+n [ + ] curry map ;

GENERIC: n+v ( n v -- w )
M: object n+v [ + ] with map ;

GENERIC# v-n 1 ( u n -- w )
M: object v-n [ - ] curry map ;

GENERIC: n-v ( n v -- w )
M: object n-v [ - ] with map ;

GENERIC# v*n 1 ( u n -- v )
M: object v*n [ * ] curry map ;

GENERIC: n*v ( n v -- w )
M: object n*v [ * ] with map ;

GENERIC# v/n 1 ( u n -- v )
M: object v/n [ / ] curry map ;

GENERIC: n/v ( n v -- w )
M: object n/v [ / ] with map ;

GENERIC: v+  ( u v -- w )
M: object v+ [ + ] 2map ;

GENERIC: v-  ( u v -- w )
M: object v- [ - ] 2map ;

GENERIC: [v-] ( u v -- w )
M: object [v-] [ [-] ] 2map ;

GENERIC: v* ( u v -- w )
M: object v* [ * ] 2map ;

GENERIC: v/ ( u v -- w )
M: object v/ [ / ] 2map ;

<PRIVATE

: if-both-floats ( x y p q -- )
    [ 2dup [ float? ] both? ] 2dip if ; inline

PRIVATE>

GENERIC: vmax ( u v -- w )
M: object vmax [ [ float-max ] [ max ] if-both-floats ] 2map ;

GENERIC: vmin ( u v -- w )
M: object vmin [ [ float-min ] [ min ] if-both-floats ] 2map ;

GENERIC: v+- ( u v -- w )
M: object v+-
    [ t ] 2dip
    [ [ not ] 2dip pick [ + ] [ - ] if ] 2map
    nip ;

GENERIC: vs+ ( u v -- w )
M: object vs+ [ + ] 2map ;

GENERIC: vs- ( u v -- w )
M: object vs- [ - ] 2map ;

GENERIC: vs* ( u v -- w )
M: object vs* [ * ] 2map ;

GENERIC: vabs ( u -- v )
M: object vabs [ abs ] map ;

GENERIC: vsqrt ( u -- v )
M: object vsqrt [ >float fsqrt ] map ;

<PRIVATE

: bitandn ( x y -- z ) [ bitnot ] dip bitand ; inline

PRIVATE>

GENERIC: vbitand ( u v -- w )
M: object vbitand [ bitand ] 2map ;
GENERIC: vbitandn ( u v -- w )
M: object vbitandn [ bitandn ] 2map ;
GENERIC: vbitor ( u v -- w )
M: object vbitor [ bitor ] 2map ;
GENERIC: vbitxor ( u v -- w )
M: object vbitxor [ bitxor ] 2map ;
GENERIC: vbitnot ( u -- w )
M: object vbitnot [ bitnot ] 2map ;

GENERIC# vbroadcast 1 ( u n -- v )
M:: object vbroadcast ( u n -- v ) u length n u nth <repetition> u like ;

GENERIC# vshuffle-elements 1 ( u perm -- v )
M: object vshuffle-elements
    over length 0 pad-tail
    swap [ '[ _ nth ] ] keep map-as ;

GENERIC# vshuffle-bytes 1 ( u perm -- v )
M: object vshuffle-bytes
    underlying>> [
        swap [ '[ 15 bitand _ nth ] ] keep map-as
    ] curry change-underlying ;

GENERIC: vshuffle ( u perm -- v )
M: array vshuffle ( u perm -- v )
    vshuffle-elements ; inline

GENERIC# vlshift 1 ( u n -- w )
M: object vlshift '[ _ shift ] map ;
GENERIC# vrshift 1 ( u n -- w )
M: object vrshift neg '[ _ shift ] map ;

GENERIC# hlshift 1 ( u n -- w )
M: object hlshift '[ _ <byte-array> prepend 16 head ] change-underlying ;
GENERIC# hrshift 1 ( u n -- w )
M: object hrshift '[ _ <byte-array> append 16 tail* ] change-underlying ;

GENERIC: (vmerge-head) ( u v -- h )
M: object (vmerge-head) over length 2 /i '[ _ head-slice ] bi@ [ zip ] keep concat-as ;
GENERIC: (vmerge-tail) ( u v -- t )
M: object (vmerge-tail) over length 2 /i '[ _ tail-slice ] bi@ [ zip ] keep concat-as ;

GENERIC: (vmerge) ( u v -- h t )
    [ (vmerge-head) ] [ (vmerge-tail) ] 2bi ; inline

GENERIC: vmerge ( u v -- w )
M: object vmerge [ zip ] keep concat-as ;

GENERIC: vand ( u v -- w )
M: object vand [ and ] 2map ;

GENERIC: vandn ( u v -- w )
M: object vandn [ [ not ] dip and ] 2map ;

GENERIC: vor  ( u v -- w )
M: object vor  [ or  ] 2map ;

GENERIC: vxor ( u v -- w )
M: object vxor [ xor ] 2map ;

GENERIC: vnot ( u -- w )
M: object vnot [ not ] map ;

GENERIC: vall? ( v -- ? )
M: object vall? [ ] all? ;

GENERIC: vany? ( v -- ? )
M: object vany? [ ] any? ;

GENERIC: vnone? ( v -- ? )
M: object vnone? [ not ] all? ;

GENERIC: v<  ( u v -- w )
M: object v<  [ <   ] 2map ;

GENERIC: v<= ( u v -- w )
M: object v<= [ <=  ] 2map ;

GENERIC: v>= ( u v -- w )
M: object v>= [ >=  ] 2map ;

GENERIC: v>  ( u v -- w )
M: object v>  [ >   ] 2map ;

GENERIC: vunordered? ( u v -- w )
M: object vunordered? [ unordered? ] 2map ;

GENERIC: v=  ( u v -- w )
M: object v=  [ =   ] 2map ;

GENERIC: v? ( mask true false -- result )
M: object v? 
    [ vand ] [ vandn ] bi-curry* bi vor ; inline

:: vif ( mask true-quot false-quot -- result )
    {
        { [ mask vall?  ] [ true-quot  call ] }
        { [ mask vnone? ] [ false-quot call ] }
        [ mask true-quot call false-quot call v? ]
    } cond ; inline

: vfloor    ( u -- v ) [ floor ] map ;
: vceiling  ( u -- v ) [ ceiling ] map ;
: vtruncate ( u -- v ) [ truncate ] map ;

: vsupremum ( seq -- vmax ) [ ] [ vmax ] map-reduce ; inline
: vinfimum ( seq -- vmin ) [ ] [ vmin ] map-reduce ; inline

GENERIC: v. ( u v -- x )
M: object v. [ conjugate * ] [ + ] 2map-reduce ;

GENERIC: norm-sq ( v -- x )
M: object norm-sq [ absq ] [ + ] map-reduce ;

GENERIC: norm ( v -- x )
M: object norm norm-sq sqrt ;

: normalize ( u -- v ) dup norm v/n ; inline

GENERIC: distance ( u v -- x )
M: object distance [ - absq ] [ + ] 2map-reduce sqrt ;

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
    [ 2bi@ ] [ call ] bi* ; inline

: vlerp ( a b t -- a_t )
    [ over v- ] dip v* v+ ; inline

: vnlerp ( a b t -- a_t )
    [ over v- ] dip v*n v+ ; inline

: vbilerp ( aa ba ab bb {t,u} -- a_tu )
    [ first vnlerp ] [ second vnlerp ] bi-curry
    [ 2bi@ ] [ call ] bi* ; inline

: v~ ( a b epsilon -- ? )
    [ ~ ] curry 2all? ; inline

HINTS: M\ object vneg { array } ;
HINTS: M\ object norm-sq { array } ;
HINTS: M\ object norm { array } ;
HINTS: M\ object distance { array array } ;

HINTS: M\ object n*v { object array } ;
HINTS: M\ object v*n { array object } ;
HINTS: M\ object n/v { object array } ;
HINTS: M\ object v/n { array object } ;

HINTS: M\ object v+ { array array } ;
HINTS: M\ object v- { array array } ;
HINTS: M\ object v* { array array } ;
HINTS: M\ object v/ { array array } ;
HINTS: M\ object vmax { array array } ;
HINTS: M\ object vmin { array array } ;
HINTS: M\ object v. { array array } ;

HINTS: vlerp { array array array } ;
HINTS: vnlerp { array array object } ;

HINTS: bilerp { object object object object array } ;
HINTS: trilerp { object object object object object object object object array } ;

