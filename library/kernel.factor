! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: kernel-internals USING: generic kernel vectors ;

: dispatch ( n vtable -- )
    #! This word is unsafe since n is not bounds-checked. Do not
    #! call it directly.
    vector-array array-nth call ;

IN: kernel

GENERIC: hashcode ( obj -- n )
M: object hashcode drop 0 ;

GENERIC: = ( obj obj -- ? )
M: object = eq? ;

GENERIC: clone ( obj -- obj )
M: object clone ;

: cpu ( -- arch )
    #! Returns one of "x86" or "unknown".
    7 getenv ;

: os ( -- arch )
    #! Returns one of "unix" or "win32".
    11 getenv ;

: set-boot ( quot -- )
    #! Set the boot quotation.
    8 setenv ;

: num-types ( -- n )
    #! One more than the maximum value from type primitive.
    19 ;

: ? ( cond t f -- t/f )
    #! Push t if cond is true, otherwise push f.
    rot [ drop ] [ nip ] ifte ; inline

: >boolean t f ? ; inline

: and ( a b -- a&b ) f ? ; inline
: not ( a -- ~a ) f t ? ; inline
: or ( a b -- a|b ) t swap ? ; inline
: xor ( a b -- a^b ) dup not swap ? ; inline

IN: syntax

! The canonical t is a heap-allocated dummy object. It is always
! the first in the image.
BUILTIN: t 7

! In the runtime, the canonical f is represented as a null
! pointer with tag 3. So
! f address . ==> 3
BUILTIN: f 9

IN: kernel
UNION: boolean f t ;
COMPLEMENT: general-t f

IN: alien

! See compiler/alien.factor for the rest; this needs to be here
! since primitive stack effects involve alien inputs/outputs.
BUILTIN: dll   15
BUILTIN: alien 16
