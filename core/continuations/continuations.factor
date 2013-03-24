! Copyright (C) 2003, 2011 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators combinators.private kernel
kernel.private make namespaces sequences vectors ;
IN: continuations

: with-datastack ( stack quot -- new-stack )
    [
        [ [ datastack ] dip swap [ { } like set-datastack ] dip ] dip
        swap [ call datastack ] dip
        swap [ set-datastack ] dip
    ] ( stack quot -- new-stack ) call-effect-unsafe ;

SYMBOL: original-error
SYMBOL: error
SYMBOL: error-continuation
SYMBOL: error-thread
SYMBOL: restarts

<PRIVATE

: catchstack* ( -- catchstack )
    CONTEXT-OBJ-CATCHSTACK context-object { vector } declare ; inline

! We have to defeat some optimizations to make continuations work
: dummy-1 ( -- obj ) f ;
: dummy-2 ( obj -- obj ) ;

: catchstack ( -- catchstack ) catchstack* clone ; inline

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
    datastack callstack retainstack namestack catchstack
    <continuation> ;

<PRIVATE

ERROR: not-a-continuation obj ;

: >continuation< ( continuation -- data call retain name catch )
    dup continuation? [ not-a-continuation ] unless
    { [ data>> ] [ call>> ] [ retain>> ] [ name>> ] [ catch>> ] } cleave ; inline

PRIVATE>

: ifcc ( capture restore -- )
    [ dummy-1 current-continuation ] 2dip [ dummy-2 ] prepose ?if ; inline

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
    [ [ return-continuation set ] prepose callcc0 ] with-scope ; inline

: return ( -- * )
    return-continuation get continue ;

GENERIC: compute-restarts ( error -- seq )

<PRIVATE

: save-error ( error -- )
    [ error set-global ]
    [ compute-restarts restarts set-global ] bi ;

PRIVATE>

GENERIC: error-in-thread ( error thread -- * )

SYMBOL: thread-error-hook ! ( error thread -- )

thread-error-hook [ [ die ] ] initialize

M: object error-in-thread ( error thread -- * )
    thread-error-hook get-global call( error thread -- * ) ;

: in-callback? ( -- ? ) CONTEXT-OBJ-IN-CALLBACK-P context-object ;

SYMBOL: callback-error-hook ! ( error -- * )

callback-error-hook [ [ die ] ] initialize

: rethrow ( error -- * )
    dup save-error
    catchstack* [
        in-callback?
        [ callback-error-hook get-global call( error -- * ) ]
        [ OBJ-CURRENT-THREAD special-object error-in-thread ]
        if
    ] [ pop continue-with ] if-empty ;

: recover ( ..a try: ( ..a -- ..b ) recovery: ( ..a error -- ..b ) -- ..b )
    [
        [
            [ catchstack* push ] dip
            call
            catchstack* pop*
        ] curry
    ] dip ifcc ; inline

: ignore-errors ( quot -- )
    [ drop ] recover ; inline

: cleanup ( try cleanup-always cleanup-error -- )
    [ compose [ dip rethrow ] curry recover ] [ drop ] 2bi call ; inline

ERROR: attempt-all-error ;

: attempt-all ( ... seq quot: ( ... elt -- ... obj ) -- ... obj )
    over empty? [
        attempt-all-error
    ] [
        [
            [ [ , f ] compose [ , drop t ] recover ] curry all?
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
    init-catchstack
    ! VM calls on error
    [
        ! 65 = self
        OBJ-CURRENT-THREAD special-object error-thread set-global
        current-continuation error-continuation set-global
        [ original-error set-global ] [ rethrow ] bi
    ] ERROR-HANDLER-QUOT set-special-object
    ! VM adds this to kernel errors, so that user-space
    ! can identify them
    "kernel-error" OBJ-ERROR set-special-object ;

PRIVATE>
