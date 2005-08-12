! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: kernel
USING: generic kernel-internals vectors ;

: 2drop ( x x -- ) drop drop ; inline
: 3drop ( x x x -- ) drop drop drop ; inline
: 2dup ( x y -- x y x y ) over over ; inline
: 3dup ( x y z -- x y z x y z ) pick pick pick ; inline
: rot ( x y z -- y z x ) >r swap r> swap ; inline
: -rot ( x y z -- z x y ) swap >r swap r> ; inline
: dupd ( x y -- x x y ) >r dup r> ; inline
: swapd ( x y z -- y x z ) >r swap r> ; inline
: 2swap ( x y z t -- z t x y ) rot >r rot r> ; inline
: nip ( x y -- y ) swap drop ; inline
: 2nip ( x y z -- z ) >r drop drop r> ; inline
: tuck ( x y -- y x y ) dup >r swap r> ; inline

: clear ( -- )
    #! Clear the datastack. For interactive use only; invoking
    #! this from a word definition will clobber any values left
    #! on the data stack by the caller.
    { } set-datastack ;

UNION: boolean POSTPONE: f POSTPONE: t ;
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

DEFER: wrapper?
BUILTIN: wrapper 14 wrapper? { 1 "wrapped" f } ;

M: wrapper = ( obj wrapper -- ? )
    over wrapper?
    [ swap wrapped swap wrapped = ] [ 2drop f ] ifte ;

! defined in parse-syntax.factor
DEFER: not
DEFER: t?

: >boolean t f ? ; inline
: and ( a b -- a&b ) f ? ; inline
: or ( a b -- a|b ) t swap ? ; inline

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

: slip ( quot x -- x | quot: -- )
    >r call r> ; inline

: 2slip ( quot x y -- x y | quot: -- )
    >r >r call r> r> ; inline

: keep ( x quot -- x | quot: x -- )
    over >r call r> ; inline

: 2keep ( x y quot -- x y | quot: x y -- )
    over >r pick >r call r> r> ; inline

: 3keep ( x y z quot -- x y z | quot: x y z -- )
    >r 3dup r> swap >r swap >r swap >r call r> r> r> ; inline

: while ( quot generator -- )
    #! Keep applying the quotation to the value produced by
    #! calling the generator until the generator returns f.
    2dup >r >r swap >r call dup [
        r> call r> r> while
    ] [
        r> 2drop r> r> 2drop
    ] ifte ; inline

: ifte* ( cond true false -- | true: cond -- | false: -- )
    #! [ X ] [ Y ] ifte* ==> dup [ X ] [ drop Y ] ifte
    pick [ drop call ] [ 2nip call ] ifte ; inline

: ?ifte ( default cond true false -- )
    #! [ X ] [ Y ] ?ifte ==> dup [ nip X ] [ drop Y ] ifte
    >r >r dup [
        nip r> r> drop call
    ] [
        drop r> drop r> call
    ] ifte ; inline

: unless ( cond quot -- | quot: -- )
    #! Execute a quotation only when the condition is f. The
    #! condition is popped off the stack.
    [ ] swap ifte ; inline

: unless* ( cond quot -- | quot: -- )
    #! If cond is f, pop it off the stack and evaluate the
    #! quotation. Otherwise, leave cond on the stack.
    over [ drop ] [ nip call ] ifte ; inline

: when ( cond quot -- | quot: -- )
    #! Execute a quotation only when the condition is not f. The
    #! condition is popped off the stack.
    [ ] ifte ; inline

: when* ( cond quot -- | quot: cond -- )
    #! If the condition is true, it is left on the stack, and
    #! the quotation is evaluated. Otherwise, the condition is
    #! popped off the stack.
    dupd [ drop ] ifte ; inline

: with ( obj quot elt -- obj quot )
    #! Utility word for each-with, map-with.
    pick pick >r >r swap call r> r> ; inline

: keep-datastack ( quot -- )
    datastack slip set-datastack drop ;
