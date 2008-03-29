! Copyright (C) 2004, 2008 Slava Pestov.
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

! Single branch
: unless ( cond false -- )
    swap [ drop ] [ call ] if ; inline

: when ( cond true -- )
    swap [ call ] [ drop ] if ; inline

! Anaphoric
: if* ( cond true false -- )
    pick [ drop call ] [ 2nip call ] if ; inline

: when* ( cond true -- )
    over [ call ] [ 2drop ] if ; inline

: unless* ( cond false -- )
    over [ drop ] [ nip call ] if ; inline

! Default
: ?if ( default cond true false -- )
    pick [ roll 2drop call ] [ 2nip call ] if ; inline

! Slippers
: slip ( quot x -- x ) >r call r> ; inline

: 2slip ( quot x y -- x y ) >r >r call r> r> ; inline

: 3slip ( quot x y z -- x y z ) >r >r >r call r> r> r> ; inline

: dip ( obj quot -- obj ) swap slip ; inline

! Keepers
: keep ( x quot -- x ) over slip ; inline

: 2keep ( x y quot -- x y ) 2over 2slip ; inline

: 3keep ( x y z quot -- x y z )
    >r 3dup r> -roll 3slip ; inline

! Cleavers
: bi ( x p q -- p[x] q[x] )
    >r keep r> call ; inline

: tri ( x p q r -- p[x] q[x] r[x] )
    >r pick >r bi r> r> call ; inline

! Double cleavers
: 2bi ( x y p q -- p[x,y] q[x,y] )
    >r 2keep r> call ; inline

: 2tri ( x y p q r -- p[x,y] q[x,y] r[x,y] )
    >r >r 2keep r> 2keep r> call ; inline

! Triple cleavers
: 3bi ( x y z p q -- p[x,y,z] q[x,y,z] )
    >r 3keep r> call ; inline

: 3tri ( x y z p q r -- p[x,y,z] q[x,y,z] r[x,y,z] )
    >r >r 3keep r> 3keep r> call ; inline

! Spreaders
: bi* ( x y p q -- p[x] q[y] )
    >r swap slip r> call ; inline

: tri* ( x y z p q r -- p[x] q[y] r[z] )
    >r rot >r bi* r> r> call ; inline

! Double spreaders
: 2bi* ( w x y z p q -- p[w,x] q[y,z] )
    >r -rot 2slip r> call ; inline

! Appliers
: bi@ ( x y p -- p[x] p[y] )
    tuck 2slip call ; inline

: tri@ ( x y z p -- p[x] p[y] p[z] )
    tuck >r bi@ r> call ; inline

! Double appliers
: 2bi@ ( w x y z p -- p[w,x] p[y,z] )
    dup -roll 3slip call ; inline

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

: both? ( x y quot -- ? ) bi@ and ; inline

: either? ( x y quot -- ? ) bi@ or ; inline

: compare ( obj1 obj2 quot -- n ) bi@ <=> ; inline

: most ( x y quot -- z )
    >r 2dup r> call [ drop ] [ nip ] if ; inline

! Error handling -- defined early so that other files can
! throw errors before continuations are loaded
: throw ( error -- * ) 5 getenv [ die ] or 1 (throw) ;

<PRIVATE

: declare ( spec -- ) drop ;

: do-primitive ( number -- ) "Improper primitive call" throw ;

PRIVATE>

! Deprecated
: 2apply bi@ ; inline
