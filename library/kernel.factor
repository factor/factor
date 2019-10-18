! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: kernel
USING: generic kernel-internals math math-internals ;

: 2swap ( x y z t -- z t x y ) rot >r rot r> ; inline

: clear ( -- ) V{ } set-datastack ;

GENERIC: hashcode ( obj -- n )
M: object hashcode drop 0 ;

GENERIC: equal? ( obj obj -- ? )
M: object equal? eq? ;

: = ( obj1 obj2 -- ? )
    2dup eq? [ 2drop t ] [ equal? ] if ; inline

GENERIC: <=> ( obj1 obj2 -- n )

GENERIC: clone ( obj -- cloned )
M: object clone ;

: set-boot ( quot -- ) 8 setenv ;

: ? ( cond true false -- true/false )
    rot [ drop ] [ nip ] if ; inline

: cpu ( -- cpu ) 7 getenv ; foldable
: os ( -- os ) 11 getenv ; foldable
: windows? ( -- ? ) os "windows" = ; foldable
: macosx? ( -- ? ) os "macosx" = ; foldable

: slip ( quot x -- x ) >r call r> ; inline

: 2slip ( quot x y -- x y ) >r >r call r> r> ; inline

: keep ( x quot -- x ) over >r call r> ; inline

: 2keep ( x y quot -- x y ) over >r pick >r call r> r> ; inline

: 3keep ( x y z quot -- x y z )
    >r 3dup r> swap >r swap >r swap >r call r> r> r> ;
    inline

: 2apply ( x y quot -- ) tuck 2slip call ; inline

: if* ( cond true false -- )
    pick [ drop call ] [ 2nip call ] if ; inline

: ?if ( default cond true false -- )
    >r >r [ nip r> r> drop call ] [ r> drop r> call ] if* ;
    inline

: unless ( cond false -- ) [ ] swap if ; inline

: unless* ( cond false -- )
    over [ drop ] [ nip call ] if ; inline

: when ( cond true -- ) [ ] if ; inline

: when* ( cond true -- ) dupd [ drop ] if ; inline

: >boolean ( obj -- ? ) t f ? ; inline
: and ( obj1 obj2 -- ? ) f ? ; inline
: or ( obj1 obj2 -- ? ) t swap ? ; inline
: xor ( obj1 obj2 -- ? ) [ not ] when ; inline

: with ( obj quot elt -- obj quot )
    pick pick >r >r swap call r> r> ; inline

: keep-datastack ( quot -- )
    datastack slip set-datastack drop ; inline

IN: kernel-internals

! These words are unsafe. Don't use them.
: declare ( spec -- ) drop ;

: array-capacity ( array -- n )
    1 slot { fixnum } declare ; inline

: array-nth ( n array -- elt )
    swap 2 fixnum+fast slot ; inline

: set-array-nth ( elt n array -- )
    swap 2 fixnum+fast set-slot ; inline

! Some runtime implementation details
: num-types ( -- n ) 19 ; inline
: tag-mask BIN: 111 ; inline
: num-tags 8 ; inline
: tag-bits 3 ; inline

: cell ( -- n ) 1 getenv ; foldable

: fixnum-tag  BIN: 000 ; inline
: bignum-tag  BIN: 001 ; inline
: word-tag    BIN: 010 ; inline
: object-tag  BIN: 011 ; inline
: ratio-tag   BIN: 100 ; inline
: float-tag   BIN: 101 ; inline
: complex-tag BIN: 110 ; inline
: wrapper-tag BIN: 111 ; inline

: array-type      8  ; inline
: hashtable-type  10 ; inline
: vector-type     11 ; inline
: string-type     12 ; inline
: sbuf-type       13 ; inline
: quotation-type  14 ; inline
: dll-type        15 ; inline
: alien-type      16 ; inline
: tuple-type      17 ; inline
: byte-array-type 18 ; inline

IN: kernel

: win32? ( -- ? ) windows? cell 4 = and ; foldable
: win64? ( -- ? ) windows? cell 8 = and ; foldable

IN: memory

: generations ( -- n ) 15 getenv ;
: image ( -- path ) 16 getenv ;
: save ( -- ) image save-image ;
