! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel.private ;
IN: kernel

! Stack stuff
: spin ( x y z -- z y x ) swap rot ; inline

: roll ( x y z t -- y z t x ) >r rot r> swap ; inline

: -roll ( x y z t -- t x y z ) swap >r -rot r> ; inline

: 2over ( x y z -- x y z x y ) pick pick ; inline

: clear ( -- ) { } set-datastack ;

! Combinators
GENERIC: call ( callable -- )

DEFER: if

: ? ( ? true false -- true/false )
    #! 'if' and '?' can be defined in terms of each other
    #! because the JIT special-cases an 'if' preceeded by
    #! two literal quotations.
    rot [ drop ] [ nip ] if ; inline

: if ( ? true false -- ) ? call ;

: if* ( cond true false -- )
    pick [ drop call ] [ 2nip call ] if ; inline

: ?if ( default cond true false -- )
    pick [ roll 2drop call ] [ 2nip call ] if ; inline

: unless ( cond false -- )
    swap [ drop ] [ call ] if ; inline

: unless* ( cond false -- )
    over [ drop ] [ nip call ] if ; inline

: when ( cond true -- )
    swap [ call ] [ drop ] if ; inline

: when* ( cond true -- )
    over [ call ] [ 2drop ] if ; inline

: slip ( quot x -- x ) >r call r> ; inline

: 2slip ( quot x y -- x y ) >r >r call r> r> ; inline

: 3slip ( quot x y z -- x y z ) >r >r >r call r> r> r> ; inline

: dip ( obj quot -- obj ) swap slip ; inline

: keep ( x quot -- x ) over slip ; inline

: 2keep ( x y quot -- x y ) 2over 2slip ; inline

: 3keep ( x y z quot -- x y z )
    >r 3dup r> -roll 3slip ; inline

: 2apply ( x y quot -- ) tuck 2slip call ; inline

: while ( pred body tail -- )
    >r >r dup slip r> r> roll
    [ >r tuck 2slip r> while ]
    [ 2nip call ] if ; inline

! Object protocol
GENERIC: delegate ( obj -- delegate )

M: object delegate drop f ;

GENERIC: set-delegate ( delegate tuple -- )

GENERIC: hashcode* ( depth obj -- code )

M: object hashcode* 2drop 0 ;

: hashcode ( obj -- code ) 3 swap hashcode* ; inline

GENERIC: equal? ( obj1 obj2 -- ? )

M: object equal? 2drop f ;

: = ( obj1 obj2 -- ? )
    2dup eq? [ 2drop t ] [ equal? ] if ; inline

GENERIC: <=> ( obj1 obj2 -- n )

GENERIC: clone ( obj -- cloned )

M: object clone ;

M: callstack clone (clone) ;

! Tuple construction
GENERIC# get-slots 1 ( tuple slots -- ... )

GENERIC# set-slots 1 ( ... tuple slots -- )

GENERIC: construct-empty ( class -- tuple )

GENERIC: construct ( ... slots class -- tuple ) inline

GENERIC: construct-boa ( ... class -- tuple )

: construct-delegate ( delegate class -- tuple )
    >r { set-delegate } r> construct ; inline

! Quotation building
USE: tuples.private

: 2curry ( obj1 obj2 quot -- curry )
    curry curry ; inline

: 3curry ( obj1 obj2 obj3 quot -- curry )
    curry curry curry ; inline

: with ( param obj quot -- obj curry )
    swapd [ swapd call ] 2curry ; inline

: 3compose ( quot1 quot2 quot3 -- curry )
    compose compose ; inline

! Booleans
: not ( obj -- ? ) f eq? ; inline

: >boolean ( obj -- ? ) t f ? ; inline

: and ( obj1 obj2 -- ? ) over ? ; inline

: or ( obj1 obj2 -- ? ) dupd ? ; inline

: xor ( obj1 obj2 -- ? ) dup not swap ? ; inline

: both? ( x y quot -- ? ) 2apply and ; inline

: either? ( x y quot -- ? ) 2apply or ; inline

: compare ( obj1 obj2 quot -- n ) 2apply <=> ; inline

: most ( x y quot -- z )
    >r 2dup r> call [ drop ] [ nip ] if ; inline

! Error handling -- defined early so that other files can
! throw errors before continuations are loaded
: throw ( error -- * ) 5 getenv [ die ] or 1 (throw) ;

<PRIVATE

: declare ( spec -- ) drop ;

: do-primitive ( number -- ) "Improper primitive call" throw ;

PRIVATE>
