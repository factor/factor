! Copyright (C) 2008, 2010 Slava Pestov, Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors classes functors kernel math math.vectors
sequences ;
IN: sequences.cords

MIXIN: cord

TUPLE: generic-cord
    { head read-only } { tail read-only } ; final
INSTANCE: generic-cord cord

M: cord length
    [ head>> length ] [ tail>> length ] bi + ; inline

M: cord virtual-exemplar head>> ; inline

M: cord virtual@
    2dup head>> length <
    [ head>> ] [ [ head>> length - ] [ tail>> ] bi ] if ; inline

INSTANCE: cord virtual-sequence

GENERIC: cord-append ( seq1 seq2 -- cord )

M: object cord-append
    generic-cord boa ; inline

<FUNCTOR: define-specialized-cord ( T C -- )

T-cord DEFINES-CLASS ${C}

WHERE

TUPLE: T-cord
    { head T read-only } { tail T read-only } ; final
INSTANCE: T-cord cord

M: T cord-append
    2dup [ T instance? ] both?
    [ T-cord boa ] [ generic-cord boa ] if ; inline

;FUNCTOR>

: cord-map ( cord quot -- cord' )
    [ [ head>> ] dip call ]
    [ [ tail>> ] dip call ] 2bi cord-append ; inline

:: cord-2map ( cord-a cord-b quot fallback -- cord' )
    cord-a cord-b 2dup [ cord? ] both? [
        [ [ head>> ] bi@ quot call ]
        [ [ tail>> ] bi@ quot call ] 2bi cord-append
    ] [ fallback call ] if ; inline

: cord-both ( cord quot -- h t )
    [ [ head>> ] [ tail>> ] bi ] dip bi@ ; inline

:: cord-2both ( cord-a cord-b quot combine fallback -- result )
    cord-a cord-b 2dup [ cord? ] both? [
        [ [ head>> ] bi@ quot call ]
        [ [ tail>> ] bi@ quot call ] 2bi combine call
    ] [ fallback call ] if ; inline

<PRIVATE
: split-shuffle ( shuf -- sh uf )
    dup length 2 /i cut* ; foldable
PRIVATE>

M: cord v+                [ v+                ] [ call-next-method ] cord-2map ; inline
M: cord v-                [ v-                ] [ call-next-method ] cord-2map ; inline
M: cord vneg              [ vneg              ] cord-map  ; inline
M: cord v+-               [ v+-               ] [ call-next-method ] cord-2map ; inline
M: cord vs+               [ vs+               ] [ call-next-method ] cord-2map ; inline
M: cord vs-               [ vs-               ] [ call-next-method ] cord-2map ; inline
M: cord vs*               [ vs*               ] [ call-next-method ] cord-2map ; inline
M: cord v*                [ v*                ] [ call-next-method ] cord-2map ; inline
M: cord v/                [ v/                ] [ call-next-method ] cord-2map ; inline
M: cord vmin              [ vmin              ] [ call-next-method ] cord-2map ; inline
M: cord vmax              [ vmax              ] [ call-next-method ] cord-2map ; inline
M: cord vdot              [ vdot              ] [ + ] [ call-next-method ] cord-2both ; inline
M: cord vsqrt             [ vsqrt             ] cord-map  ; inline
M: cord sum               [ sum               ] cord-both + ; inline
M: cord vabs              [ vabs              ] cord-map  ; inline
M: cord vbitand           [ vbitand           ] [ call-next-method ] cord-2map ; inline
M: cord vbitandn          [ vbitandn          ] [ call-next-method ] cord-2map ; inline
M: cord vbitor            [ vbitor            ] [ call-next-method ] cord-2map ; inline
M: cord vbitxor           [ vbitxor           ] [ call-next-method ] cord-2map ; inline
M: cord vbitnot           [ vbitnot           ] cord-map  ; inline
M: cord vand              [ vand              ] [ call-next-method ] cord-2map ; inline
M: cord vandn             [ vandn             ] [ call-next-method ] cord-2map ; inline
M: cord vor               [ vor               ] [ call-next-method ] cord-2map ; inline
M: cord vxor              [ vxor              ] [ call-next-method ] cord-2map ; inline
M: cord vnot              [ vnot              ] cord-map  ; inline
M: cord vlshift           '[ _ vlshift        ] cord-map  ; inline
M: cord vrshift           '[ _ vrshift        ] cord-map  ; inline
M: cord (vmerge-head)     [ head>> ] bi@ (vmerge) cord-append ; inline
M: cord (vmerge-tail)     [ tail>> ] bi@ (vmerge) cord-append ; inline
M: cord v<=               [ v<=               ] [ call-next-method ] cord-2map ; inline
M: cord v<                [ v<                ] [ call-next-method ] cord-2map ; inline
M: cord v=                [ v=                ] [ call-next-method ] cord-2map ; inline
M: cord v>                [ v>                ] [ call-next-method ] cord-2map ; inline
M: cord v>=               [ v>=               ] [ call-next-method ] cord-2map ; inline
M: cord vunordered?       [ vunordered?       ] [ call-next-method ] cord-2map ; inline
M: cord vany?             [ vany?             ] cord-both or  ; inline
M: cord vall?             [ vall?             ] cord-both and ; inline
M: cord vnone?            [ vnone?            ] cord-both and ; inline
M: cord vshuffle-elements
    [ [ head>> ] [ tail>> ] bi ] [ split-shuffle ] bi*
    [ vshuffle2-elements ] bi-curry@ 2bi cord-append ; inline

M: cord n+v [ n+v ] with cord-map ; inline
M: cord n-v [ n-v ] with cord-map ; inline
M: cord n*v [ n*v ] with cord-map ; inline
M: cord n/v [ n/v ] with cord-map ; inline
M: cord v+n '[ _ v+n ] cord-map ; inline
M: cord v-n '[ _ v-n ] cord-map ; inline
M: cord v*n '[ _ v*n ] cord-map ; inline
M: cord v/n '[ _ v/n ] cord-map ; inline

M: cord norm-sq [ norm-sq ] cord-both + ; inline
M: cord distance v- norm ; inline
