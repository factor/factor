! Copyright (C) 2004, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USE: slots.private
USE: kernel.private
USE: math.private
IN: kernel

BUILTIN: callstack ;
BUILTIN: tuple ;
BUILTIN: wrapper { wrapped read-only } ;

PRIMITIVE: -rot ( x y z -- z x y )
PRIMITIVE: dup ( x -- x x )
PRIMITIVE: dupd ( x y -- x x y )
PRIMITIVE: drop ( x -- )
PRIMITIVE: nip ( x y -- y )
PRIMITIVE: over ( x y -- x y x )
PRIMITIVE: pick ( x y z -- x y z x )
PRIMITIVE: rot ( x y z -- y z x )
PRIMITIVE: swap ( x y -- y x )
PRIMITIVE: swapd ( x y z -- y x z )
PRIMITIVE: 2drop ( x y -- )
PRIMITIVE: 2dup ( x y -- x y x y )
PRIMITIVE: 2nip ( x y z -- z )
PRIMITIVE: 3drop ( x y z -- )
PRIMITIVE: 3dup ( x y z -- x y z x y z )
PRIMITIVE: 4drop ( w x y z -- )
PRIMITIVE: 4dup ( w x y z -- w x y z w x y z )

PRIMITIVE: (clone) ( obj -- newobj )
PRIMITIVE: eq? ( obj1 obj2 -- ? )
PRIMITIVE: <wrapper> ( obj -- wrapper )
PRIMITIVE: die ( -- )
PRIMITIVE: callstack>array ( callstack -- array )

<PRIVATE
PRIMITIVE: (call) ( quot -- )
PRIMITIVE: (execute) ( word -- )
PRIMITIVE: (identity-hashcode) ( obj -- code )
PRIMITIVE: become ( old new -- )
PRIMITIVE: c-to-factor ( -- )
PRIMITIVE: callstack-bounds ( -- start end )
PRIMITIVE: check-datastack ( array in# out# -- ? )
PRIMITIVE: compute-identity-hashcode ( obj -- )
PRIMITIVE: context-object ( n -- obj )
PRIMITIVE: fpu-state ( -- )
PRIMITIVE: innermost-frame-executing ( callstack -- obj )
PRIMITIVE: innermost-frame-scan ( callstack -- n )
PRIMITIVE: lazy-jit-compile ( -- )
PRIMITIVE: leaf-signal-handler ( -- )
PRIMITIVE: set-callstack ( callstack -- * )
PRIMITIVE: set-context-object ( obj n -- )
PRIMITIVE: set-datastack ( array -- )
PRIMITIVE: set-fpu-state ( -- )
PRIMITIVE: set-innermost-frame-quotation ( n callstack -- )
PRIMITIVE: set-retainstack ( array -- )
PRIMITIVE: set-special-object ( obj n -- )
PRIMITIVE: signal-handler ( -- )
PRIMITIVE: special-object ( n -- obj )
PRIMITIVE: strip-stack-traces ( -- )
PRIMITIVE: tag ( object -- n )
PRIMITIVE: unwind-native-frames ( -- )
PRIVATE>

DEFER: dip
DEFER: 2dip
DEFER: 3dip

! Stack stuff
: 2over ( x y z -- x y z x y ) pick pick ; inline

: clear ( -- ) { } set-datastack ;

! Combinators
GENERIC: call ( callable -- )

GENERIC: execute ( word -- )

DEFER: if

: ? ( ? true false -- true/false )
    ! 'if' and '?' can be defined in terms of each other
    ! because the JIT special-cases an 'if' preceded by
    ! two literal quotations.
    rot [ drop ] [ nip ] if ; inline

: if ( ..a ? true: ( ..a -- ..b ) false: ( ..a -- ..b ) -- ..b ) ? call ;

! Single branch
: unless ( ..a ? false: ( ..a -- ..a ) -- ..a )
    swap [ drop ] [ call ] if ; inline

: when ( ..a ? true: ( ..a -- ..a ) -- ..a )
    swap [ call ] [ drop ] if ; inline

! Anaphoric
: if* ( ..a ? true: ( ..a ? -- ..b ) false: ( ..a -- ..b ) -- ..b )
    pick [ drop call ] [ 2nip call ] if ; inline

: when* ( ..a ? true: ( ..a ? -- ..a ) -- ..a )
    over [ call ] [ 2drop ] if ; inline

: unless* ( ..a ? false: ( ..a -- ..a x ) -- ..a x )
    over [ drop ] [ nip call ] if ; inline

! Dippers.
! Not declared inline because the compiler special-cases them

: dip ( x quot -- x ) swap [ call ] dip ;

: 2dip ( x y quot -- x y ) swap [ dip ] dip ;

: 3dip ( x y z quot -- x y z ) swap [ 2dip ] dip ;

: 4dip ( w x y z quot -- w x y z ) swap [ 3dip ] dip ; inline

! Misfits
: tuck ( x y -- y x y ) dup -rot ; inline

: rotd ( w x y z -- x y w z ) [ rot ] dip ; inline

: -rotd ( w x y z -- y w x z ) [ -rot ] dip ; inline

: roll ( w x y z -- x y z w ) rotd swap ; inline

: -roll ( w x y z -- z w x y ) swap -rotd ; inline

: spin ( x y z -- z y x ) -rot swap ; inline

: 4spin ( w x y z -- z y x w ) -roll spin ; inline

: nipd ( x y z -- y z ) [ nip ] dip ; inline

: overd ( x y z -- x y x z ) [ over ] dip ; inline

: pickd ( w x y z -- w x y w z ) [ pick ] dip ; inline

: 2nipd ( w x y z -- y z ) [ 2drop ] 2dip ; inline

: 3nipd ( v w x y z -- y z ) [ 3drop ] 2dip ; inline

: 3nip ( w x y z -- z ) 2nip nip ; inline

: 4nip ( v w x y z -- z ) 2nip 2nip ; inline

: 5nip ( u v w x y z -- z ) 3nip 2nip ; inline

: 5drop ( v w x y z -- ) 4drop drop ; inline

: reach ( w x y z -- w x y z w ) [ pick ] dip swap ; inline

! Keepers
: keep ( ..a x quot: ( ..a x -- ..b ) -- ..b x )
    over [ call ] dip ; inline

: 2keep ( ..a x y quot: ( ..a x y -- ..b ) -- ..b x y )
    [ 2dup ] dip 2dip ; inline

: 3keep ( ..a x y z quot: ( ..a x y z -- ..b ) -- ..b x y z )
    [ 3dup ] dip 3dip ; inline

: 4keep ( ..a w x y z quot: ( ..a w x y z -- ..b ) -- ..b w x y z )
    [ 4dup ] dip 4dip ; inline

: keepd ( ..a x y quot: ( ..a x y -- ..b ) -- ..b x )
    2keep drop ; inline

: keepdd ( ..a x y z quot: ( ..a x y z -- ..b ) -- ..b x )
    3keep 2drop ; inline

: 2keepd ( ..a x y z quot: ( ..a x y z -- ..b ) -- ..b x y )
    3keep drop ; inline

: ?call ( ..a obj/f quot: ( ..a obj -- ..a obj' )  -- ..a obj'/f ) dupd when ; inline

: ?or ( obj1 obj2 -- obj1/obj2 first? ) over [ drop t ] [ nip f ] if ; inline

: ?or* ( obj1 obj2 -- obj2/obj1 second? ) swap ?or ; inline

: ?transmute ( old quot: ( old -- new/f ) -- new/old new? ) keep ?or ; inline

: transmute ( old quot: ( old -- new/f ) -- new/old ) ?transmute drop ; inline

! Default

: ?when ( ..a default cond: ( ..a default -- ..a new/f ) true: ( ..a new -- ..a x ) -- ..a default/x )
    [ ?transmute ] dip when ; inline

: ?unless ( ..a default cond: ( ..a default -- ..a new/f ) false: ( ..a default -- ..a x ) -- ..a default/x )
    [ ?transmute ] dip unless ; inline

: ?if ( ..a default cond: ( default -- new/f ) true: ( ..a new -- ..b ) false: ( ..a default -- ..b ) -- ..b )
    [ ?transmute ] 2dip if ; inline

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

: 2tri@ ( u v w x y z quot -- )
    dup dup 2tri* ; inline

! Quotation building
: 2curry ( obj1 obj2 quot -- curried )
    curry curry ; inline

: 3curry ( obj1 obj2 obj3 quot -- curried )
    curry curry curry ; inline

: with ( param obj quot -- obj curried )
    swapd [ swapd call ] 2curry ; inline

: 2with ( param1 param2 obj quot -- obj curried )
    with with ; inline

: withd ( param obj quot -- obj curried )
    swapd [ -rotd call ] 2curry ; inline

: prepose ( quot1 quot2 -- composed )
    swap compose ; inline

! Curried cleavers
<PRIVATE

: currier ( quot -- quot' ) [ curry ] curry ; inline

PRIVATE>

: bi-curry ( x p q -- p' q' ) [ currier ] bi@ bi ; inline

: tri-curry ( x p q r -- p' q' r' ) [ currier ] tri@ tri ; inline

: bi-curry* ( x y p q -- p' q' ) [ currier ] bi@ bi* ; inline

: tri-curry* ( x y z p q r -- p' q' r' ) [ currier ] tri@ tri* ; inline

: bi-curry@ ( x y q -- p' q' ) currier bi@ ; inline

: tri-curry@ ( x y z q -- p' q' r' ) currier tri@ ; inline

! Booleans
UNION: boolean POSTPONE: t POSTPONE: f ;

: >boolean ( obj -- ? ) [ t ] [ f ] if ; inline

: not ( obj -- ? ) [ f ] [ t ] if ; inline

: and ( obj1 obj2 -- obj2/f ) over ? ; inline

: and* ( obj1 obj2 -- obj1/f ) swap and ; inline

: ?and ( obj quot -- obj/f ) keep and ; inline

: or ( obj1 obj2 -- obj1/obj2 ) dupd ? ; inline

: or* ( obj1 obj2 -- obj2/obj1 ) swap or ; inline

: xor ( obj1 obj2 -- obj1/obj2/f ) [ f swap ? ] when* ; inline

: both? ( x y quot -- ? ) bi@ and ; inline

: either? ( x y quot -- ? ) bi@ or ; inline

: most ( x y quot -- z ) 2keep ? ; inline

: negate ( quot -- quot' ) [ not ] compose ; inline

! Loops
: loop ( ... pred: ( ... -- ... ? ) -- ... )
    [ call ] keep [ loop ] curry when ; inline recursive

: do ( pred body -- pred body )
    dup 2dip ; inline

: while ( ..a pred: ( ..a -- ..b ? ) body: ( ..b -- ..a ) -- ..b )
    swap do compose [ loop ] curry when ; inline

: while* ( ..a pred: ( ..a -- ..b ? ) body: ( ..b ? -- ..a ) -- ..b )
    [ [ dup ] compose ] dip while drop ; inline

: until ( ..a pred: ( ..a -- ..b ? ) body: ( ..b -- ..a ) -- ..b )
    [ negate ] dip while ; inline

! Object protocol
GENERIC: hashcode* ( depth obj -- code ) flushable

M: object hashcode* 2drop 0 ; inline

M: f hashcode* 2drop 31337 ; inline

: hashcode ( obj -- code ) 3 swap hashcode* ; inline

GENERIC: equal? ( obj1 obj2 -- ? )

M: object equal? 2drop f ; inline

TUPLE: identity-tuple ;

M: identity-tuple equal? 2drop f ; inline

: identity-hashcode ( obj -- code )
    dup tag 0 eq? [
        dup tag 1 eq? [ drop 0 ] [
            dup (identity-hashcode) dup 0 eq? [
                drop dup compute-identity-hashcode
                (identity-hashcode)
            ] [ nip ] if
        ] if
    ] unless ; inline

M: identity-tuple hashcode* nip identity-hashcode ; inline

: = ( obj1 obj2 -- ? )
    2dup eq? [ 2drop t ] [
        2dup both-fixnums? [ 2drop f ] [ equal? ] if
    ] if ; inline

: same? ( x y quot -- ? ) bi@ = ; inline

GENERIC: clone ( obj -- cloned )

M: object clone ; inline

M: callstack clone (clone) ; inline

! Tuple construction
GENERIC: new ( class -- tuple )

GENERIC: boa ( slots... class -- tuple )

! Error handling -- defined early so that other files can
! throw errors before continuations are loaded
GENERIC: throw ( error -- * )

ERROR: assert got expect ;

: assert= ( a b -- ) 2dup = [ 2drop ] [ assert ] if ;

<PRIVATE

: declare ( spec -- ) drop ;

: do-primitive ( number -- ) "Improper primitive call" throw ;

! Special object count and identifiers must be kept in sync with:
!   vm/objects.hpp
CONSTANT: special-object-count 85

CONSTANT: OBJ-WALKER-HOOK 3

CONSTANT: OBJ-CALLCC-1 4

CONSTANT: ERROR-HANDLER-QUOT 5

CONSTANT: OBJ-CELL-SIZE 7
CONSTANT: OBJ-CPU 8
CONSTANT: OBJ-OS 9

CONSTANT: OBJ-ARGS 10
CONSTANT: OBJ-STDIN 11
CONSTANT: OBJ-STDOUT 12

CONSTANT: OBJ-IMAGE 13
CONSTANT: OBJ-EXECUTABLE 14

CONSTANT: OBJ-EMBEDDED 15
CONSTANT: OBJ-EVAL-CALLBACK 16
CONSTANT: OBJ-YIELD-CALLBACK 17
CONSTANT: OBJ-SLEEP-CALLBACK 18

CONSTANT: OBJ-STARTUP-QUOT 20
CONSTANT: OBJ-GLOBAL 21
CONSTANT: OBJ-SHUTDOWN-QUOT 22

CONSTANT: JIT-PROLOG 23
CONSTANT: JIT-PRIMITIVE-WORD 24
CONSTANT: JIT-PRIMITIVE 25
CONSTANT: JIT-WORD-JUMP 26
CONSTANT: JIT-WORD-CALL 27
CONSTANT: JIT-IF-WORD 28
CONSTANT: JIT-IF 29
CONSTANT: JIT-SAFEPOINT 30
CONSTANT: JIT-EPILOG 31
CONSTANT: JIT-RETURN 32
CONSTANT: JIT-UNUSED 33
CONSTANT: JIT-PUSH-LITERAL 34
CONSTANT: JIT-DIP-WORD 35
CONSTANT: JIT-DIP 36
CONSTANT: JIT-2DIP-WORD 37
CONSTANT: JIT-2DIP 38
CONSTANT: JIT-3DIP-WORD 39
CONSTANT: JIT-3DIP 40
CONSTANT: JIT-EXECUTE 41
CONSTANT: JIT-DECLARE-WORD 42

CONSTANT: C-TO-FACTOR-WORD 43
CONSTANT: LAZY-JIT-COMPILE-WORD 44
CONSTANT: UNWIND-NATIVE-FRAMES-WORD 45
CONSTANT: GET-FPU-STATE-WORD 46
CONSTANT: SET-FPU-STATE-WORD 47
CONSTANT: SIGNAL-HANDLER-WORD 48
CONSTANT: LEAF-SIGNAL-HANDLER-WORD 49
CONSTANT: WIN-EXCEPTION-HANDLER 50

CONSTANT: OBJ-SAMPLE-CALLSTACKS 51

CONSTANT: REDEFINITION-COUNTER 52

CONSTANT: CALLBACK-STUB 53

CONSTANT: PIC-LOAD 54
CONSTANT: PIC-TAG 55
CONSTANT: PIC-TUPLE 56
CONSTANT: PIC-CHECK-TAG 57
CONSTANT: PIC-CHECK-TUPLE 58
CONSTANT: PIC-HIT 59
CONSTANT: PIC-MISS-WORD 60
CONSTANT: PIC-MISS-TAIL-WORD 61

CONSTANT: MEGA-LOOKUP 62
CONSTANT: MEGA-LOOKUP-WORD 63
CONSTANT: MEGA-MISS-WORD 64

CONSTANT: OBJ-UNDEFINED 65

CONSTANT: OBJ-STDERR 66

CONSTANT: OBJ-STAGE2 67

CONSTANT: OBJ-CURRENT-THREAD 68

CONSTANT: OBJ-THREADS 69
CONSTANT: OBJ-RUN-QUEUE 70
CONSTANT: OBJ-SLEEP-QUEUE 71

CONSTANT: OBJ-VM-COMPILER 72

CONSTANT: OBJ-WAITING-CALLBACKS 73

CONSTANT: OBJ-SIGNAL-PIPE 74

CONSTANT: OBJ-VM-COMPILE-TIME 75

CONSTANT: OBJ-VM-VERSION 76
CONSTANT: OBJ-VM-GIT-LABEL 77

CONSTANT: OBJ-CANONICAL-TRUE 78

CONSTANT: OBJ-BIGNUM-ZERO 79
CONSTANT: OBJ-BIGNUM-POS-ONE 80
CONSTANT: OBJ-BIGNUM-NEG-ONE 81

! Context object count and identifiers must be kept in sync with:
!   vm/contexts.hpp

CONSTANT: context-object-count 4

CONSTANT: CONTEXT-OBJ-NAMESTACK 0
CONSTANT: CONTEXT-OBJ-CATCHSTACK 1
CONSTANT: CONTEXT-OBJ-CONTEXT 2
CONSTANT: CONTEXT-OBJ-IN-CALLBACK-P 3

! Runtime errors must be kept in sync with:
!   basis/debugger/debugger.factor
!   vm/errors.hpp

! VM adds this to kernel errors, so that user-space can identify them.
CONSTANT: KERNEL-ERROR 0xfac7

CONSTANT: kernel-error-count 20

CONSTANT: ERROR-EXPIRED 0
CONSTANT: ERROR-IO      1
CONSTANT: ERROR-NOT-IMPLEMENTED 2
CONSTANT: ERROR-TYPE 3
CONSTANT: ERROR-DIVIDE-BY-ZERO 4
CONSTANT: ERROR-SIGNAL 5
CONSTANT: ERROR-ARRAY-SIZE 6
CONSTANT: ERROR-OUT-OF-FIXNUM-RANGE 7
CONSTANT: ERROR-FFI 8
CONSTANT: ERROR-UNDEFINED-SYMBOL 9
CONSTANT: ERROR-DATASTACK-UNDERFLOW 10
CONSTANT: ERROR-DATASTACK-OVERFLOW 11
CONSTANT: ERROR-RETAINSTACK-UNDERFLOW 12
CONSTANT: ERROR-RETAINSTACK-OVERFLOW 13
CONSTANT: ERROR-CALLSTACK-UNDERFLOW 14
CONSTANT: ERROR-CALLSTACK-OVERFLOW 15
CONSTANT: ERROR-MEMORY 16
CONSTANT: ERROR-FP-TRAP 17
CONSTANT: ERROR-INTERRUPT 18
CONSTANT: ERROR-CALLBACK-SPACE-OVERFLOW 19

PRIMITIVE: callstack-for ( context -- array )
PRIMITIVE: retainstack-for ( context -- array )
PRIMITIVE: datastack-for ( context -- array )

: context ( -- context )
    CONTEXT-OBJ-CONTEXT context-object ; inline

PRIVATE>

: get-callstack ( -- callstack )
    context callstack-for ; inline

: get-datastack ( -- array )
    context datastack-for ; inline

: get-retainstack ( -- array )
    context retainstack-for ; inline
