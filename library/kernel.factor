! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: kernel
USING: generic kernel-internals vectors ;

: 2swap ( x y z t -- z t x y ) rot >r rot r> ; inline

: clear ( -- )
    #! Clear the datastack. For interactive use only; invoking
    #! this from a word definition will clobber any values left
    #! on the data stack by the caller.
    { } set-datastack ;

UNION: boolean POSTPONE: f POSTPONE: t ;

GENERIC: hashcode ( obj -- n ) flushable
M: object hashcode drop 0 ;

GENERIC: = ( obj obj -- ? ) flushable
M: object = eq? ;

GENERIC: clone ( obj -- obj ) flushable
M: object clone ;

: set-boot ( quot -- )
    #! Set the boot quotation.
    8 setenv ;

: num-types ( -- n )
    #! One more than the maximum value from type primitive.
    21 ; inline

: ? ( cond t f -- t/f )
    #! Push t if cond is true, otherwise push f.
    rot [ drop ] [ nip ] ifte ; inline

M: wrapper = ( obj wrapper -- ? )
    over wrapper?
    [ swap wrapped swap wrapped = ] [ 2drop f ] ifte ;

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
: num-tags 8 ; inline
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
