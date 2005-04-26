! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: kernel
USING: generic kernel-internals vectors ;

UNION: boolean f t ;
COMPLEMENT: general-t f

GENERIC: hashcode ( obj -- n )
M: object hashcode drop 0 ;

GENERIC: = ( obj obj -- ? )
M: object = eq? ;

GENERIC: clone ( obj -- obj )
M: object clone ;

: cpu ( -- arch )
    #! Returns one of "x86", "ppc", or "unknown".
    7 getenv ;

: os ( -- arch )
    #! Returns one of "unix" or "win32".
    11 getenv ;

: set-boot ( quot -- )
    #! Set the boot quotation.
    8 setenv ;

: num-types ( -- n )
    #! One more than the maximum value from type primitive.
    21 ;

: ? ( cond t f -- t/f )
    #! Push t if cond is true, otherwise push f.
    rot [ drop ] [ nip ] ifte ; inline

: >boolean t f ? ; inline
: not ( a -- ~a ) f t ? ; inline

: and ( a b -- a&b ) f ? ; inline
: or ( a b -- a|b ) t swap ? ; inline
: xor ( a b -- a^b ) dup not swap ? ; inline
: implies ( a b -- a->b ) t ? ; inline
