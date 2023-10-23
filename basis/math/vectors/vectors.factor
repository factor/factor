! Copyright (C) 2005, 2010 Slava Pestov, Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays assocs combinators grouping kernel math
math.functions math.libm math.order sequences ;
QUALIFIED-WITH: alien.c-types c
IN: math.vectors

GENERIC: vneg ( v -- w )
M: object vneg [ neg ] map ; inline

GENERIC#: v+n 1 ( v n -- w )
M: object v+n [ + ] curry map ; inline

GENERIC: n+v ( n v -- w )
M: object n+v [ + ] with map ; inline

GENERIC#: v-n 1 ( v n -- w )
M: object v-n [ - ] curry map ; inline

GENERIC: n-v ( n v -- w )
M: object n-v [ - ] with map ; inline

GENERIC#: v*n 1 ( v n -- w )
M: object v*n [ * ] curry map ; inline

GENERIC: n*v ( n v -- w )
M: object n*v [ * ] with map ; inline

GENERIC#: v/n 1 ( v n -- w )
M: object v/n [ / ] curry map ; inline

GENERIC: n/v ( n v -- w )
M: object n/v [ / ] with map ; inline

GENERIC: v+ ( u v -- w )
M: object v+ [ + ] 2map ; inline

GENERIC: v- ( u v -- w )
M: object v- [ - ] 2map ; inline

GENERIC: [v-] ( u v -- w )
M: object [v-] [ [-] ] 2map ; inline

GENERIC: v* ( u v -- w )
M: object v* [ * ] 2map ; inline

GENERIC: v*high ( u v -- w )

<PRIVATE
: (h+) ( v -- w ) 2 <groups> [ first2 + ] map ;
PRIVATE>

GENERIC: v*hs+ ( u v -- w )
M: object v*hs+ [ * ] 2map (h+) ; inline

GENERIC: v/ ( u v -- w )
M: object v/ [ / ] 2map ; inline

GENERIC: v^ ( u v -- w )
M: object v^ [ ^ ] 2map ; inline

GENERIC: v^n ( v n -- w )
M: object v^n [ ^ ] curry map ; inline

GENERIC: n^v ( n v -- w )
M: object n^v [ ^ ] with map ; inline

GENERIC: vavg ( u v -- w )
M: object vavg [ + 2 / ] 2map ; inline

GENERIC: vmax ( u v -- w )
M: object vmax [ max ] 2map ; inline

GENERIC: vmin ( u v -- w )
M: object vmin [ min ] 2map ; inline

GENERIC: v+- ( u v -- w )
M: object v+-
    [ t ] 2dip
    [ [ not ] 2dip pick [ + ] [ - ] if ] 2map
    nip ; inline

GENERIC: vs+ ( u v -- w )
M: object vs+ [ + ] 2map ; inline

GENERIC: vs- ( u v -- w )
M: object vs- [ - ] 2map ; inline

GENERIC: vs* ( u v -- w )
M: object vs* [ * ] 2map ; inline

GENERIC: vabs ( v -- w )
M: object vabs [ abs ] map ; inline

GENERIC: vsqrt ( v -- w )
M: object vsqrt [ >float fsqrt ] map ; inline

GENERIC: vsad ( u v -- n )
M: object vsad [ - abs ] [ + ] 2map-reduce ; inline

<PRIVATE

: bitandn ( x y -- z ) [ bitnot ] dip bitand ; inline

PRIVATE>

GENERIC: vbitand ( u v -- w )
M: object vbitand [ bitand ] 2map ; inline
GENERIC: vbitandn ( u v -- w )
M: object vbitandn [ bitandn ] 2map ; inline
GENERIC: vbitor ( u v -- w )
M: object vbitor [ bitor ] 2map ; inline
GENERIC: vbitxor ( u v -- w )
M: object vbitxor [ bitxor ] 2map ; inline
GENERIC: vbitnot ( v -- w )
M: object vbitnot [ bitnot ] map ; inline

GENERIC#: vbroadcast 1 ( u n -- v )
M:: object vbroadcast ( u n -- v ) u length n u nth <repetition> u like ; inline

GENERIC#: vshuffle-elements 1 ( v perm -- w )
M: object vshuffle-elements
    over length 0 pad-tail
    swap [ '[ _ nth ] ] keep map-as ; inline

GENERIC#: vshuffle2-elements 1 ( u v perm -- w )
M: object vshuffle2-elements
    [ append ] dip vshuffle-elements ; inline

GENERIC#: vshuffle-bytes 1 ( v perm -- w )

GENERIC: vshuffle ( v perm -- w )
M: array vshuffle
    vshuffle-elements ; inline

GENERIC#: vlshift 1 ( v n -- w )
M: object vlshift '[ _ shift ] map ; inline
GENERIC#: vrshift 1 ( v n -- w )
M: object vrshift neg '[ _ shift ] map ; inline

GENERIC#: hlshift 1 ( v n -- w )
GENERIC#: hrshift 1 ( v n -- w )

GENERIC: (vmerge-head) ( u v -- h )
M: object (vmerge-head) over length 2 /i '[ _ head-slice ] bi@ [ zip ] keep concat-as ; inline
GENERIC: (vmerge-tail) ( u v -- t )
M: object (vmerge-tail) over length 2 /i '[ _ tail-slice ] bi@ [ zip ] keep concat-as ; inline

: (vmerge) ( u v -- h t )
    [ (vmerge-head) ] [ (vmerge-tail) ] 2bi ; inline

GENERIC: vmerge ( u v -- w )
M: object vmerge [ zip ] keep concat-as ; inline

GENERIC: vand ( u v -- w )
M: object vand [ and ] 2map ; inline

GENERIC: vandn ( u v -- w )
M: object vandn [ [ not ] dip and ] 2map ; inline

GENERIC: vor ( u v -- w )
M: object vor [ or ] 2map ; inline

GENERIC: vxor ( u v -- w )
M: object vxor [ xor ] 2map ; inline

GENERIC: vnot ( v -- w )
M: object vnot [ not ] map ; inline

GENERIC: vall? ( v -- ? )
M: object vall? [ ] all? ; inline

GENERIC: vcount ( v -- count )
M: object vcount [ ] count ; inline

GENERIC: vany? ( v -- ? )
M: object vany? [ ] any? ; inline

GENERIC: vnone? ( v -- ? )
M: object vnone? [ not ] all? ; inline

GENERIC: v< ( u v -- w )
M: object v< [ < ] 2map ; inline

GENERIC: v<= ( u v -- w )
M: object v<= [ <= ] 2map ; inline

GENERIC: v>= ( u v -- w )
M: object v>= [ >= ] 2map ; inline

GENERIC: v> ( u v -- w )
M: object v> [ > ] 2map ; inline

GENERIC: vunordered? ( u v -- w )
M: object vunordered? [ unordered? ] 2map ; inline

GENERIC: v= ( u v -- w )
M: object v= [ = ] 2map ; inline

GENERIC: v? ( mask true false -- result )
M: object v?
    [ vand ] [ vandn ] bi-curry* bi vor ; inline

: vif ( mask true-quot: ( -- vector ) false-quot: ( -- vector ) -- result )
    {
        { [ pick vall? ] [ drop nip call ] }
        { [ pick vnone? ] [ 2nip call ] }
        [ [ call ] dip call v? ]
    } cond ; inline

: v>integer ( v -- w ) [ >integer ] map ;
: vfloor ( v -- w ) [ floor ] map ;
: vceiling ( v -- w ) [ ceiling ] map ;
: vtruncate ( v -- w ) [ truncate ] map ;

: vmaximum ( seq -- vmax ) [ ] [ vmax ] map-reduce ; inline
: vminimum ( seq -- vmin ) [ ] [ vmin ] map-reduce ; inline

ALIAS: vsupremum vmaximum deprecated
ALIAS: vinfimum vminimum deprecated

GENERIC: vdot ( u v -- x )
M: object vdot [ * ] [ + ] 2map-reduce ; inline

GENERIC: hdot ( u v -- x )
M: object hdot [ conjugate * ] [ + ] 2map-reduce ; inline

GENERIC: norm-sq ( v -- x )
M: object norm-sq [ absq ] [ + ] map-reduce ; inline

: l1-norm ( k -- x ) [ abs ] map-sum ; inline

: l2-norm ( k -- x ) norm-sq sqrt ; inline

ALIAS: norm l2-norm

: l-infinity-norm ( k -- x ) supremum ; inline

: p-norm-default ( k p -- x )
    [ [ [ abs ] dip ^ ] curry map-sum ] keep recip ^ ; inline

: p-norm ( k p -- x )
    {
        { [ dup 1 = ] [ drop l1-norm ] }
        { [ dup 2 = ] [ drop l2-norm ] }
        { [ dup fp-infinity? ] [ drop supremum ] }
        [ p-norm-default ]
    } cond ;

: normalize ( v -- w ) dup l2-norm v/n ; inline

GENERIC: distance ( u v -- x )
M: object distance [ - absq ] [ + ] 2map-reduce sqrt ; inline

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

: vclamp ( v min max -- w )
    rot vmin vmax ; inline

: cross ( vec1 vec2 -- vec3 )
    [ [ { 1 2 0 } vshuffle ] [ { 2 0 1 } vshuffle ] bi* v* ]
    [ [ { 2 0 1 } vshuffle ] [ { 1 2 0 } vshuffle ] bi* v* ] 2bi v- ; inline

:: normal ( vec1 vec2 vec3 -- vec4 )
    vec2 vec1 v- vec3 vec1 v- cross normalize ; inline

: proj ( v u -- w )
    [ [ vdot ] [ norm-sq ] bi / ] keep n*v ;

: perp ( v u -- w )
    dupd proj v- ;

: angle-between ( v u -- a )
    [ normalize ] bi@ hdot acos ;
