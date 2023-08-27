! Copyright (C) 2003, 2011 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes combinators combinators.private
kernel kernel.private make namespaces sequences vectors ;
IN: continuations

: with-datastack ( stack quot -- new-stack )
    [
        [ [ get-datastack ] dip swap [ { } like set-datastack ] dip ] dip
        swap [ call get-datastack ] dip
        swap [ set-datastack ] dip
    ] ( stack quot -- new-stack ) call-effect-unsafe ;

SYMBOL: original-error
SYMBOL: error
SYMBOL: error-continuation
SYMBOL: error-thread
SYMBOL: restarts

SINGLETON: no-op-restart

<PRIVATE

: (get-catchstack) ( -- catchstack )
    CONTEXT-OBJ-CATCHSTACK context-object { vector } declare ; inline

! We have to defeat some optimizations to make continuations work
: dummy-1 ( -- obj ) f ;
: dummy-2 ( obj -- obj ) ;

: get-catchstack ( -- catchstack ) (get-catchstack) clone ; inline

: (set-catchstack) ( catchstack -- )
    CONTEXT-OBJ-CATCHSTACK set-context-object ; inline

: set-catchstack ( catchstack -- )
    >vector (set-catchstack) ; inline

: init-catchstack ( -- )
    V{ } clone (set-catchstack) ;

PRIVATE>

TUPLE: continuation data call retain name catch ;

C: <continuation> continuation

: current-continuation ( -- continuation )
    get-datastack get-callstack get-retainstack get-namestack get-catchstack
    <continuation> ;

<PRIVATE

: >continuation< ( continuation -- data call retain name catch )
    continuation check-instance {
        [ data>> ] [ call>> ] [ retain>> ] [ name>> ] [ catch>> ]
    } cleave ; inline

PRIVATE>

: ifcc ( capture restore -- )
    [ dummy-1 current-continuation or* ] 2dip [ dummy-2 ] prepose if ; inline

: callcc0 ( quot -- ) [ drop ] ifcc ; inline

: callcc1 ( quot -- obj ) [ ] ifcc ; inline

<PRIVATE

: (continue) ( continuation -- * )
    [
        >continuation<
        set-catchstack
        set-namestack
        set-retainstack
        [ set-datastack ] dip
        set-callstack
    ] ( continuation -- * ) call-effect-unsafe ;

PRIVATE>

: continue-with ( obj continuation -- * )
    [
        swap OBJ-CALLCC-1 set-special-object
        >continuation<
        set-catchstack
        set-namestack
        set-retainstack
        [
            set-datastack drop
            OBJ-CALLCC-1 special-object
            f OBJ-CALLCC-1 set-special-object
            f
        ] dip
        set-callstack
    ] ( obj continuation -- * ) call-effect-unsafe ;

: continue ( continuation -- * )
    f swap continue-with ;

SYMBOL: return-continuation

: with-return ( quot -- )
    [ return-continuation ] dip [ with-variable ] 2curry callcc0 ; inline

: return ( -- * )
    return-continuation get continue ;

GENERIC: compute-restarts ( error -- seq )

<PRIVATE

: save-error ( error -- )
    [ error set-global ]
    [ compute-restarts restarts set-global ] bi ;

PRIVATE>

GENERIC: error-in-thread ( error thread -- * )

SYMBOL: thread-error-hook ! ( error thread -- * )

M: object error-in-thread
    thread-error-hook get-global call( error thread -- * ) ;

: in-callback? ( -- ? ) CONTEXT-OBJ-IN-CALLBACK-P context-object ;

SYMBOL: callback-error-hook ! ( error -- * )

: rethrow ( error -- * )
    dup save-error
    (get-catchstack) [
        in-callback?
        [ callback-error-hook get-global call( error -- * ) ]
        [ OBJ-CURRENT-THREAD special-object error-in-thread ]
        if
    ] [ pop continue-with ] if-empty ;

thread-error-hook [ [ die drop rethrow ] ] initialize

callback-error-hook [ [ die rethrow ] ] initialize

: recover ( ..a try: ( ..a -- ..b ) recovery: ( ..a error -- ..b ) -- ..b )
    [
        [
            [ (get-catchstack) push ] dip
            call
            (get-catchstack) pop*
        ] curry
    ] dip ifcc ; inline

: ignore-errors ( ... quot: ( ... -- ... ) -- ... )
    [ drop ] recover ; inline

: ignore-error ( ... quot: ( ... -- ... ) check: ( error -- ? ) -- ... )
    '[ dup @ [ drop ] [ rethrow ] if ] recover ; inline

: ignore-error/f ( ... quot: ( ... -- ... x ) check: ( error -- ? ) -- ... x/f )
    '[ dup @ [ drop f ] [ rethrow ] if ] recover ; inline

: cleanup ( try cleanup-always cleanup-error -- )
    [ '[ [ @ @ ] dip rethrow ] recover ] [ drop ] 2bi call ; inline

: finally ( try cleanup-always -- )
    [ ] cleanup ; inline

ERROR: attempt-all-error ;

: attempt-all ( ... seq quot: ( ... elt -- ... obj ) -- ... obj )
    over empty? [
        attempt-all-error
    ] [
        [
            '[ [ @ , f ] [ , drop t ] recover ] all?
        ] { } make last swap [ rethrow ] when
    ] if ; inline

TUPLE: condition error restarts continuation ;

C: <condition> condition

: throw-restarts ( error restarts -- restart )
    [ <condition> throw ] callcc1 2nip ;

: rethrow-restarts ( error restarts -- restart )
    [ <condition> rethrow ] callcc1 2nip ;

: throw-continue ( error -- )
    { { "Continue" t } } throw-restarts drop ;

TUPLE: restart name obj continuation ;

C: <restart> restart

: continue-restart ( restart -- * )
    [ obj>> ] [ continuation>> ] bi continue-with ;

M: object compute-restarts drop { } ;

M: condition compute-restarts
    [ error>> compute-restarts ]
    [
        [ restarts>> ]
        [ continuation>> [ <restart> ] curry ] bi
        { } assoc>map
    ] bi append ;

<PRIVATE

: init-error-handler ( -- )
    ! VM calls on error
    [
        OBJ-CURRENT-THREAD special-object error-thread set-global
        current-continuation error-continuation set-global
        [ original-error set-global ] [ rethrow ] bi
    ] ERROR-HANDLER-QUOT set-special-object ;

PRIVATE>
