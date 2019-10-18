! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: kernel
USING: generic kernel-internals math math-internals ;

: 2swap ( x y z t -- z t x y ) rot >r rot r> ; inline

: roll ( x y z t -- y z t x ) >r rot r> swap ; inline

: -roll ( x y z t -- t x y z ) swap >r -rot r> ; inline

: clear ( -- ) V{ } set-datastack ;

GENERIC: hashcode* ( n obj -- code )

M: object hashcode* 2drop 0 ;

: hashcode ( obj -- code ) 3 swap hashcode* ; inline

GENERIC: equal? ( obj1 obj2 -- ? )

M: object equal? 2drop f ;

: = ( obj1 obj2 -- ? )
    2dup eq? [ 2drop t ] [ equal? ] if ; inline

GENERIC: <=> ( obj1 obj2 -- n )

GENERIC: clone ( obj -- cloned )
M: object clone ;

: set-boot ( quot -- ) 8 setenv ;

: ? ( cond true false -- true/false )
    rot [ drop ] [ nip ] if ; inline

: slip ( quot x -- x ) >r call r> ; inline

: 2slip ( quot x y -- x y ) >r >r call r> r> ; inline

: 3slip ( quot x y -- x y ) >r >r >r call r> r> r> ; inline

: keep ( x quot -- x ) over slip ; inline

: 2keep ( x y quot -- x y ) pick pick 2slip ; inline

: 3keep ( x y z quot -- x y z )
    >r 3dup r> -roll 3slip ; inline

: 2apply ( x y quot -- ) tuck 2slip call ; inline

: if* ( cond true false -- )
    pick [ drop call ] [ 2nip call ] if ; inline

: ?if ( default cond true false -- )
    pick [ roll 2drop call ] [ 2nip call ] if ; inline

: unless ( cond false -- ) [ ] swap if ; inline

: unless* ( cond false -- )
    over [ drop ] [ nip call ] if ; inline

: when ( cond true -- ) [ ] if ; inline

: when* ( cond true -- ) dupd [ drop ] if ; inline

: >boolean ( obj -- ? ) t f ? ; inline

: and ( obj1 obj2 -- ? ) f ? ; inline

: or ( obj1 obj2 -- ? ) dupd ? ; inline

: xor ( obj1 obj2 -- ? ) [ not ] when ; inline

: both? ( x y quot -- ? ) 2apply and ; inline

: either? ( x y quot -- ? ) 2apply or ; inline

: compare ( obj1 obj2 quot -- n ) 2apply <=> ; inline

: with ( obj quot elt -- obj quot )
    [ swap call ] 3keep drop ; inline

: cell ( -- n ) 1 getenv ; foldable
: cpu ( -- cpu ) 7 getenv ; foldable
: os ( -- os ) 11 getenv ; foldable
: image ( -- path ) 16 getenv ;
: vm ( -- path ) 17 getenv ;
: windows? ( -- ? ) os [ "windows" = ] keep "wince" = or ; foldable
: wince? ( -- ? ) os "wince" = ; foldable
: win32? ( -- ? ) wince? not windows? cell 4 = and f ? ; foldable
: win64? ( -- ? ) windows? cell 8 = and ; foldable
: winnt? windows? wince? not and ; foldable
: macosx? ( -- ? ) os "macosx" = ; foldable

: embedded? ( -- ? ) 19 getenv ;

IN: kernel-internals

! These words are unsafe. Don't use them.
: declare ( spec -- ) drop ;
