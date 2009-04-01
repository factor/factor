! Copyright (C) 2004, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel.private slots.private math.private ;
IN: kernel

DEFER: dip
DEFER: 2dip
DEFER: 3dip

! Stack stuff
: spin ( x y z -- z y x ) swap rot ; inline

: roll ( x y z t -- y z t x ) [ rot ] dip swap ; inline

: -roll ( x y z t -- t x y z ) swap [ -rot ] dip ; inline

: 2over ( x y z -- x y z x y ) pick pick ; inline

: clear ( -- ) { } set-datastack ;

! Combinators
GENERIC: call ( callable -- )

GENERIC: execute ( word -- )

GENERIC: ?execute ( word -- value )

M: object ?execute ;

DEFER: if

: ? ( ? true false -- true/false )
    #! 'if' and '?' can be defined in terms of each other
    #! because the JIT special-cases an 'if' preceeded by
    #! two literal quotations.
    rot [ drop ] [ nip ] if ; inline

: if ( ? true false -- ) ? call ;

! Single branch
: unless ( ? false -- )
    swap [ drop ] [ call ] if ; inline

: when ( ? true -- )
    swap [ call ] [ drop ] if ; inline

! Anaphoric
: if* ( ? true false -- )
    pick [ drop call ] [ 2nip call ] if ; inline

: when* ( ? true -- )
    over [ call ] [ 2drop ] if ; inline

: unless* ( ? false -- )
    over [ drop ] [ nip call ] if ; inline

! Default
: ?if ( default cond true false -- )
    pick [ drop [ drop ] 2dip call ] [ 2nip call ] if ; inline

! Slippers and dippers.
! Not declared inline because the compiler special-cases them

: slip ( quot x -- x )
    #! 'slip' and 'dip' can be defined in terms of each other
    #! because the JIT special-cases a 'dip' preceeded by
    #! a literal quotation.
    [ call ] dip ;

: 2slip ( quot x y -- x y )
    #! '2slip' and '2dip' can be defined in terms of each other
    #! because the JIT special-cases a '2dip' preceeded by
    #! a literal quotation.
    [ call ] 2dip ;

: 3slip ( quot x y z -- x y z )
    #! '3slip' and '3dip' can be defined in terms of each other
    #! because the JIT special-cases a '3dip' preceeded by
    #! a literal quotation.
    [ call ] 3dip ;

: dip ( x quot -- x ) swap slip ;

: 2dip ( x y quot -- x y ) -rot 2slip ;

: 3dip ( x y z quot -- x y z ) -roll 3slip ;

: 4dip ( w x y z quot -- w x y z ) swap [ 3dip ] dip ; inline

! Keepers
: keep ( x quot -- x ) over slip ; inline

: 2keep ( x y quot -- x y ) [ 2dup ] dip 2dip ; inline

: 3keep ( x y z quot -- x y z ) [ 3dup ] dip 3dip ; inline

! Cleavers
: bi ( x p q -- )
    [ keep ] dip call ; inline

: tri ( x p q r -- )
    [ [ keep ] dip keep ] dip call ; inline

! Double cleavers
: 2bi ( x y p q -- )
    [ 2keep ] dip call ; inline

: 2tri ( x y p q r -- )
    [ [ 2keep ] dip 2keep ] dip call ; inline

! Triple cleavers
: 3bi ( x y z p q -- )
    [ 3keep ] dip call ; inline

: 3tri ( x y z p q r -- )
    [ [ 3keep ] dip 3keep ] dip call ; inline

! Spreaders
: bi* ( x y p q -- )
    [ dip ] dip call ; inline

: tri* ( x y z p q r -- )
    [ [ 2dip ] dip dip ] dip call ; inline

! Double spreaders
: 2bi* ( w x y z p q -- )
    [ 2dip ] dip call ; inline

: 2tri* ( u v w x y z p q r -- )
    [ 4dip ] 2dip 2bi* ; inline

! Appliers
: bi@ ( x y quot -- )
    dup bi* ; inline

: tri@ ( x y z quot -- )
    dup dup tri* ; inline

! Double appliers
: 2bi@ ( w x y z quot -- )
    dup 2bi* ; inline

: 2tri@ ( u v w y x z quot -- )
    dup dup 2tri* ; inline

! Quotation building
: 2curry ( obj1 obj2 quot -- curry )
    curry curry ; inline

: 3curry ( obj1 obj2 obj3 quot -- curry )
    curry curry curry ; inline

: with ( param obj quot -- obj curry )
    swapd [ swapd call ] 2curry ; inline

: prepose ( quot1 quot2 -- compose )
    swap compose ; inline

! Curried cleavers
<PRIVATE

: [curry] ( quot -- quot' ) [ curry ] curry ; inline

PRIVATE>

: bi-curry ( x p q -- p' q' ) [ [curry] ] bi@ bi ; inline

: tri-curry ( x p q r -- p' q' r' ) [ [curry] ] tri@ tri ; inline

: bi-curry* ( x y p q -- p' q' ) [ [curry] ] bi@ bi* ; inline

: tri-curry* ( x y z p q r -- p' q' r' ) [ [curry] ] tri@ tri* ; inline

: bi-curry@ ( x y q -- p' q' ) [curry] bi@ ; inline

: tri-curry@ ( x y z q -- p' q' r' ) [curry] tri@ ; inline

! Booleans
: not ( obj -- ? ) [ f ] [ t ] if ; inline

: and ( obj1 obj2 -- ? ) over ? ; inline

: >boolean ( obj -- ? ) [ t ] [ f ] if ; inline

: or ( obj1 obj2 -- ? ) dupd ? ; inline

: xor ( obj1 obj2 -- ? ) [ f swap ? ] when* ; inline

: both? ( x y quot -- ? ) bi@ and ; inline

: either? ( x y quot -- ? ) bi@ or ; inline

: most ( x y quot -- z ) 2keep ? ; inline

! Loops
: loop ( pred: ( -- ? ) -- )
    [ call ] keep [ loop ] curry when ; inline recursive

: do ( pred body -- pred body )
    dup 2dip ; inline

: while ( pred: ( -- ? ) body: ( -- ) -- )
    swap do compose [ loop ] curry when ; inline

: until ( pred: ( -- ? ) body: ( -- ) -- )
    [ [ not ] compose ] dip while ; inline

! Object protocol
GENERIC: hashcode* ( depth obj -- code )

M: object hashcode* 2drop 0 ;

M: f hashcode* 2drop 31337 ;

: hashcode ( obj -- code ) 3 swap hashcode* ; inline

GENERIC: equal? ( obj1 obj2 -- ? )

M: object equal? 2drop f ;

TUPLE: identity-tuple ;

M: identity-tuple equal? 2drop f ;

: = ( obj1 obj2 -- ? )
    2dup eq? [ 2drop t ] [
        2dup both-fixnums? [ 2drop f ] [ equal? ] if
    ] if ; inline

GENERIC: clone ( obj -- cloned )

M: object clone ;

M: callstack clone (clone) ;

! Tuple construction
GENERIC: new ( class -- tuple )

GENERIC: boa ( ... class -- tuple )

! Error handling -- defined early so that other files can
! throw errors before continuations are loaded
GENERIC: throw ( error -- * )

ERROR: assert got expect ;

: assert= ( a b -- ) 2dup = [ 2drop ] [ assert ] if ;

<PRIVATE

: declare ( spec -- ) drop ;

: hi-tag ( obj -- n ) { hi-tag } declare 0 slot ; inline

: do-primitive ( number -- ) "Improper primitive call" throw ;

PRIVATE>
