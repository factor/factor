! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs sequences sorting binary-search math
math.order arrays classes combinators kernel functors ;
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
