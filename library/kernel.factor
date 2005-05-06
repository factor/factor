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

: cpu ( -- arch ) 7 getenv ;
: os ( -- os ) 11 getenv ;
: win32? ( -- ? ) os "win32" = ;
: unix? ( -- ? )
    os "freebsd" =
    os "linux" = or
    os "macosx" = or ;

: tag-mask BIN: 111 ; inline
: tag-bits 3 ; inline

: fixnum-tag  BIN: 000 ; inline
: bignum-tag  BIN: 001 ; inline
: cons-tag    BIN: 010 ; inline
: object-tag  BIN: 011 ; inline
