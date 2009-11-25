! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs sequences sorting binary-search fry math
math.order arrays classes combinators kernel functors math.functions
math.vectors ;
IN: sequences.cords

MIXIN: cord

TUPLE: generic-cord
    { head read-only } { tail read-only } ;
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

FUNCTOR: define-specialized-cord ( T C -- )

T-cord DEFINES-CLASS ${C}

WHERE

TUPLE: T-cord
    { head T read-only } { tail T read-only } ;
INSTANCE: T-cord cord

M: T cord-append
    2dup [ T instance? ] both?
    [ T-cord boa ] [ generic-cord boa ] if ; inline

;FUNCTOR

: cord-map ( cord quot -- cord' )
    [ [ head>> ] dip call ]
    [ [ tail>> ] dip call ] 2bi cord-append ; inline

: cord-2map ( cord cord quot -- cord' )
    [ [ [ head>> ] bi@ ] dip call ]
    [ [ [ tail>> ] bi@ ] dip call ] 3bi cord-append ; inline

: cord-both ( cord quot -- h t )
    [ [ head>> ] [ tail>> ] bi ] dip bi@ ; inline

: cord-2both ( cord cord quot -- h t )
    [ [ [ head>> ] bi@ ] dip call ]
    [ [ [ tail>> ] bi@ ] dip call ] 3bi ; inline

M: cord v+                [ v+                ] cord-2map ; inline
M: cord v-                [ v-                ] cord-2map ; inline
M: cord vneg              [ vneg              ] cord-map  ; inline
M: cord v+-               [ v+-               ] cord-2map ; inline
M: cord vs+               [ vs+               ] cord-2map ; inline
M: cord vs-               [ vs-               ] cord-2map ; inline
M: cord vs*               [ vs*               ] cord-2map ; inline
M: cord v*                [ v*                ] cord-2map ; inline
M: cord v/                [ v/                ] cord-2map ; inline
M: cord vmin              [ vmin              ] cord-2map ; inline
M: cord vmax              [ vmax              ] cord-2map ; inline
M: cord v.                [ v.                ] cord-2both + ; inline
M: cord vsqrt             [ vsqrt             ] cord-map  ; inline
M: cord sum               [ sum               ] cord-both + ; inline
M: cord vabs              [ vabs              ] cord-map  ; inline
M: cord vbitand           [ vbitand           ] cord-2map ; inline
M: cord vbitandn          [ vbitandn          ] cord-2map ; inline
M: cord vbitor            [ vbitor            ] cord-2map ; inline
M: cord vbitxor           [ vbitxor           ] cord-2map ; inline
M: cord vbitnot           [ vbitnot           ] cord-map  ; inline
M: cord vand              [ vand              ] cord-2map ; inline
M: cord vandn             [ vandn             ] cord-2map ; inline
M: cord vor               [ vor               ] cord-2map ; inline
M: cord vxor              [ vxor              ] cord-2map ; inline
M: cord vnot              [ vnot              ] cord-map  ; inline
M: cord vlshift           '[ _ vlshift        ] cord-map  ; inline
M: cord vrshift           '[ _ vrshift        ] cord-map  ; inline
M: cord (vmerge-head)     [ head>> ] bi@ (vmerge) cord-append ; inline
M: cord (vmerge-tail)     [ tail>> ] bi@ (vmerge) cord-append ; inline
M: cord v<=               [ v<=               ] cord-2map ; inline
M: cord v<                [ v<                ] cord-2map ; inline
M: cord v=                [ v=                ] cord-2map ; inline
M: cord v>                [ v>                ] cord-2map ; inline
M: cord v>=               [ v>=               ] cord-2map ; inline
M: cord vunordered?       [ vunordered?       ] cord-2map ; inline
M: cord vany?             [ vany?             ] cord-both or  ; inline
M: cord vall?             [ vall?             ] cord-both and ; inline
M: cord vnone?            [ vnone?            ] cord-both and ; inline

M: cord n+v [ n+v ] with cord-map ; inline
M: cord n-v [ n-v ] with cord-map ; inline
M: cord n*v [ n*v ] with cord-map ; inline
M: cord n/v [ n/v ] with cord-map ; inline
M: cord v+n '[ _ v+n ] cord-map ; inline
M: cord v-n '[ _ v-n ] cord-map ; inline
M: cord v*n '[ _ v*n ] cord-map ; inline
M: cord v/n '[ _ v/n ] cord-map ; inline

M: cord norm-sq  dup v. ; inline
M: cord norm     norm-sq sqrt ; inline
M: cord distance v- norm ; inline


