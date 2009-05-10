! Copyright (C) 2003, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays vectors kernel kernel.private sequences
namespaces make math splitting sorting quotations assocs
combinators combinators.private accessors words ;
IN: continuations

SYMBOL: error
SYMBOL: error-continuation
SYMBOL: error-thread
SYMBOL: restarts

<PRIVATE

: catchstack* ( -- catchstack )
    1 getenv { vector } declare ; inline

: >c ( continuation -- ) catchstack* push ;

: c> ( -- continuation ) catchstack* pop ;

! We have to defeat some optimizations to make continuations work
: dummy-1 ( -- obj ) f ;
: dummy-2 ( obj -- obj ) dup drop ;

: init-catchstack ( -- ) V{ } clone 1 setenv ;

PRIVATE>

: catchstack ( -- catchstack ) catchstack* clone ; inline

: set-catchstack ( catchstack -- ) >vector 1 setenv ; inline

TUPLE: continuation data call retain name catch ;

C: <continuation> continuation

: continuation ( -- continuation )
    datastack callstack retainstack namestack catchstack
    <continuation> ;

: >continuation< ( continuation -- data call retain name catch )
    {
        [ data>>   ]
        [ call>>   ]
        [ retain>> ]
        [ name>>   ]
        [ catch>>  ]
    } cleave ;

: ifcc ( capture restore -- )
    #! After continuation is being captured, the stacks looks
    #! like:
    #! ( f continuation r:capture r:restore )
    #! so the 'capture' branch is taken.
    #!
    #! Note that the continuation itself is not captured as part
    #! of the datastack.
    #!
    #! BUT...
    #!
    #! After the continuation is resumed, (continue-with) pushes
    #! the given value together with f,
    #! so now, the stacks looks like:
    #! ( value f r:capture r:restore )
    #! Execution begins right after the call to 'continuation'.
    #! The 'restore' branch is taken.
    [ dummy-1 continuation ] 2dip [ dummy-2 ] prepose ?if ; inline

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
    ] (( continuation -- * )) call-effect-unsafe ;

PRIVATE>

: continue-with ( obj continuation -- * )
    [
        swap 4 setenv
        >continuation<
        set-catchstack
        set-namestack
        set-retainstack
        [ set-datastack drop 4 getenv f 4 setenv f ] dip
        set-callstack
    ] (( obj continuation -- * )) call-effect-unsafe ;

: continue ( continuation -- * )
    f swap continue-with ;

SYMBOL: return-continuation

: with-return ( quot -- )
    [ [ return-continuation set ] prepose callcc0 ] with-scope ; inline

: return ( -- * )
    return-continuation get continue ;

: with-datastack ( stack quot -- newstack )
    [
        [
            [ [ { } like set-datastack ] dip call datastack ] dip
            continue-with
        ] (( stack quot continuation -- * )) call-effect-unsafe
    ] callcc1 2nip ;

GENERIC: compute-restarts ( error -- seq )

<PRIVATE

: save-error ( error -- )
    dup error set-global
    compute-restarts restarts set-global ;

PRIVATE>

SYMBOL: thread-error-hook

: rethrow ( error -- * )
    dup save-error
    catchstack* empty? [
        thread-error-hook get-global
        [ (( error -- * )) call-effect-unsafe ] [ die ] if*
    ] when
    c> continue-with ;

: recover ( try recovery -- )
    [ [ swap >c call c> drop ] curry ] dip ifcc ; inline

: ignore-errors ( quot -- )
    [ drop ] recover ; inline

: cleanup ( try cleanup-always cleanup-error -- )
    [ compose [ dip rethrow ] curry recover ] [ drop ] 2bi call ; inline

ERROR: attempt-all-error ;

: attempt-all ( seq quot -- obj )
    over empty? [
        attempt-all-error
    ] [
        [
            [ [ , f ] compose [ , drop t ] recover ] curry all?
        ] { } make peek swap [ rethrow ] when
    ] if ; inline

TUPLE: condition error restarts continuation ;

C: <condition> condition ( error restarts cc -- condition )

: throw-restarts ( error restarts -- restart )
    [ <condition> throw ] callcc1 2nip ;

: rethrow-restarts ( error restarts -- restart )
    [ <condition> rethrow ] callcc1 2nip ;

TUPLE: restart name obj continuation ;

C: <restart> restart

: restart ( restart -- * )
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
    V{ } clone set-catchstack
    ! VM calls on error
    [
        ! 63 = self
        63 getenv error-thread set-global
        continuation error-continuation set-global
        rethrow
    ] 5 setenv
    ! VM adds this to kernel errors, so that user-space
    ! can identify them
    "kernel-error" 6 setenv ;

PRIVATE>
