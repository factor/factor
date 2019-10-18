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
    6 getenv { vector } declare ; inline

: >c ( continuation -- ) catchstack* push ;

: c> ( -- continuation ) catchstack* pop ;

PRIVATE>

: catchstack ( -- catchstack ) catchstack* clone ; inline

: set-catchstack ( catchstack -- ) >vector 6 setenv ; inline

TUPLE: continuation data retain call name catch c ;

C: <continuation> continuation

: continuation ( -- continuation )
    datastack retainstack callstack namestack catchstack f
    <continuation> ; inline

: >continuation< ( continuation -- data retain call name catch c )
    [ continuation-data ] keep
    [ continuation-retain ] keep
    [ continuation-call ] keep
    [ continuation-name ] keep
    [ continuation-catch ] keep
    continuation-c ; inline

: ifcc ( terminator balance -- )
    >r >r f [ continuation nip t ] call r> r> if ; inline

: callcc0 ( quot -- ) [ ] ifcc ; inline

: callcc1 ( quot -- obj ) callcc0 ; inline

: set-walker-hook ( quot -- ) 2 setenv ; inline

: walker-hook ( -- quot ) 2 getenv f set-walker-hook ; inline

<PRIVATE

: (continue) ( continuation -- )
    >continuation<
    drop
    set-catchstack
    set-namestack
    set-callstack
    set-retainstack
    set-datastack ; inline

: (continue-with) ( obj continuation -- )
    #! There's no good way to avoid this code duplication!
    swap 9 setenv
    >continuation<
    drop
    set-catchstack
    set-namestack
    set-callstack
    set-retainstack
    set-datastack
    9 getenv swap ; inline

PRIVATE>

: continue ( continuation -- )
    walker-hook [ (continue-with) ] [ (continue) ] if* ;
    inline

: continue-with ( obj continuation -- )
    walker-hook [ >r 2array r> ] when* (continue-with) ;
    inline

M: continuation clone
    [ continuation-data clone ] keep
    [ continuation-retain clone ] keep
    [ continuation-call clone ] keep
    [ continuation-name clone ] keep
    [ continuation-catch clone ] keep
    continuation-c clone <continuation> ;

: catch ( try -- error/f )
    [ >c call f c> drop f ] callcc1 nip ; inline

GENERIC: compute-restarts ( error -- seq )

<PRIVATE

: save-error ( error -- )
    dup error set-global
    compute-restarts restarts set-global ;

PRIVATE>

: rethrow ( error -- )
    catchstack* empty?
    [ die ] [ dup save-error c> continue-with ] if ;

: cleanup ( try cleanup -- )
    [ >c >r call c> drop r> call ]
    [ >r nip call r> rethrow ] ifcc ;
    inline

: recover ( try recovery -- )
    [ >c drop call c> drop ]
    [ rot drop swap call ] ifcc ; inline

: attempt-all ( seq quot -- obj )
    [
        [ [ , f ] append [ , drop t ] recover ] curry all?
    ] { } make peek swap [ rethrow ] when ;

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

: error-handler ( error trace -- )
    continuation [ set-continuation-c ] keep
    dup continuation-data 2 head* over set-continuation-data
    error-continuation set-global
    dup save-error rethrow ;

: init-error-handler ( -- )
    V{ } clone set-catchstack
    ! kernel calls on error
    [ error-handler ] 5 setenv
    "kernel-error" 12 setenv ;

: find-xt ( xt xtmap -- word )
    [ second - ] binsearch* first ;

PRIVATE>

: find-xts ( seq -- newseq )
    xt-map 2 <groups> [ find-xt ] curry map ;
