! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: kernel
USING: generic kernel-internals math math-internals ;

: 2swap ( x y z t -- z t x y ) rot >r rot r> ; inline

: clear V{ } set-datastack ;

GENERIC: hashcode ( obj -- n ) flushable
M: object hashcode drop 0 ;

GENERIC: hashcode* ( n obj -- n ) flushable
M: object hashcode* nip hashcode ;

GENERIC: = ( obj obj -- ? ) flushable
M: object = eq? ;

GENERIC: <=> ( obj1 obj2 -- n ) flushable

GENERIC: clone ( obj -- obj ) flushable
M: object clone ;

: set-boot ( quot -- ) 8 setenv ;

: ? ( cond t f -- t/f ) rot [ drop ] [ nip ] if ; inline

: >boolean t f ? ; inline
: and ( a b -- a&b ) f ? ; inline
: or ( a b -- a|b ) t swap ? ; inline

: cpu ( -- arch ) 7 getenv ; foldable
: os ( -- os ) 11 getenv ; foldable
: windows? ( -- ? ) os "windows" = ; inline
: macosx? os "macosx" = ; inline

: slip >r call r> ; inline

: 2slip >r >r call r> r> ; inline

: keep over >r call r> ; inline

: 2keep over >r pick >r call r> r> ; inline

: 3keep >r 3dup r> swap >r swap >r swap >r call r> r> r> ;
inline

: 2apply tuck 2slip call ; inline

: if* pick [ drop call ] [ 2nip call ] if ; inline

: ?if >r >r [ nip r> r> drop call ] [ r> drop r> call ] if* ;
inline

: unless [ ] swap if ; inline

: unless* over [ drop ] [ nip call ] if ; inline

: when [ ] if ; inline

: when* dupd [ drop ] if ; inline

: with ( obj quot elt -- obj quot )
    pick pick >r >r swap call r> r> ; inline

: keep-datastack datastack slip set-datastack drop ; inline

IN: kernel-internals

! These words are unsafe. Don't use them.
: declare ( types -- ) drop ;

: array-capacity 1 slot { fixnum } declare ; inline
: array-nth swap 2 fixnum+fast slot ; inline
: set-array-nth swap 2 fixnum+fast set-slot ; inline

: make-tuple <tuple> [ 2 set-slot ] keep ; flushable

! Some runtime implementation details
: num-types 19 ; inline
: tag-mask BIN: 111 ; inline
: num-tags 8 ; inline
: tag-bits 3 ; inline

: fixnum-tag  BIN: 000 ; inline
: bignum-tag  BIN: 001 ; inline
: word-tag    BIN: 010 ; inline
: object-tag  BIN: 011 ; inline
: ratio-tag   BIN: 100 ; inline
: float-tag   BIN: 101 ; inline
: complex-tag BIN: 110 ; inline
: wrapper-tag BIN: 111 ; inline

: cell 17 getenv ; foldable

IN: kernel

: win32? windows? cell 4 = and ; inline
: win64? windows? cell 8 = and ; inline

IN: memory

: generations ( -- n ) 15 getenv ;
: image ( -- path ) 16 getenv ;
: save ( -- ) image save-image ;
