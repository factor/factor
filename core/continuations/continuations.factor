! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays vectors kernel kernel.private sequences
namespaces tuples math splitting sorting quotations assocs ;
IN: continuations

SYMBOL: error
SYMBOL: error-continuation
SYMBOL: restarts

<PRIVATE

: catchstack* ( -- catchstack )
    1 getenv { vector } declare ; inline

: >c ( continuation -- ) catchstack* push ;

: c> ( -- continuation ) catchstack* pop ;

: (catch) ( quot -- newquot )
    [ swap >c call c> drop ] curry ; inline

: (callcc1) 4 getenv f 4 setenv ; inline

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
        continuation-data
        continuation-call
        continuation-retain
        continuation-name
        continuation-catch
    } get-slots ;

: ifcc0 ( capture restore -- )
    #! After continuation is being captured, the stacks looks
    #! like:
    #! ( continuation r:capture r:restore )
    #! so the 'capture' branch is taken.
    #!
    #! Note that the continuation itself is not captured as part
    #! of the datastack.
    #!
    #! BUT...
    #!
    #! After the continuation is resumed, (continue) pushes f,
    #! so now, the stacks looks like:
    #! ( f r:capture r:restore )
    #! Execution begins right after the call to 'continuation'.
    #! The 'restore' branch is taken.
    >r >r continuation r> r> if* ; inline

: ifcc1 ( capture restore -- )
    [ (callcc1) ] swap compose ifcc0 ; inline

: callcc0 ( quot -- ) [ ] ifcc0 ; inline

: callcc1 ( quot -- obj ) [ ] ifcc1 ; inline

: set-walker-hook ( quot -- ) 3 setenv ; inline

: walker-hook ( -- quot ) 3 getenv f set-walker-hook ; inline

<PRIVATE

: (continue) ( continuation -- )
    >continuation<
    set-catchstack
    set-namestack
    set-retainstack
    >r set-datastack f r>
    set-callstack ;

: (continue-with) ( obj continuation -- )
    swap 4 setenv (continue) ;

PRIVATE>

: continue ( continuation -- )
    [
        walker-hook [ (continue-with) ] [ (continue) ] if*
    ] curry (throw) ;

: continue-with ( obj continuation -- )
    [
        walker-hook [ >r 2array r> ] when* (continue-with)
    ] 2curry (throw) ;

GENERIC: compute-restarts ( error -- seq )

<PRIVATE

: save-error ( error -- )
    dup error set-global
    compute-restarts restarts set-global ;

PRIVATE>

: rethrow ( error -- * )
    catchstack* empty? [ die ] when
    dup save-error c> continue-with ;

: catch ( try -- error/f )
    (catch) [ f ] compose callcc1 ; inline

: recover ( try recovery -- )
    >r (catch) r> ifcc1 ; inline

: cleanup ( try cleanup-always cleanup-error -- )
    >r [ compose (catch) ] keep r> compose
    [ dip rethrow ] curry ifcc1 ; inline

: attempt-all ( seq quot -- obj )
    [
        [ [ , f ] compose [ , drop t ] recover ] curry all?
    ] { } make peek swap [ rethrow ] when ; inline

TUPLE: condition restarts continuation ;

: <condition> ( error restarts cc -- condition )
    {
        set-delegate
        set-condition-restarts
        set-condition-continuation
    } condition construct ;

: throw-restarts ( error restarts -- restart )
    [ <condition> throw ] callcc1 2nip ;

: rethrow-restarts ( error restarts -- restart )
    [ <condition> rethrow ] callcc1 2nip ;

TUPLE: restart name obj continuation ;

C: <restart> restart

: restart ( restart -- )
    dup restart-obj swap restart-continuation continue-with ;

M: object compute-restarts drop { } ;

M: tuple compute-restarts delegate compute-restarts ;

M: condition compute-restarts
    [ delegate compute-restarts ] keep
    [ condition-restarts ] keep
    condition-continuation
    [ <restart> ] curry { } assoc>map
    append ;

<PRIVATE

: init-error-handler ( -- )
    V{ } clone set-catchstack
    ! VM calls on error
    [
        continuation error-continuation set-global rethrow
    ] 5 setenv
    ! VM adds this to kernel errors, so that user-space
    ! can identify them
    "kernel-error" 6 setenv ;

PRIVATE>
