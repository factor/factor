! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: threads kernel namespaces continuations combinators
sequences math namespaces.private continuations.private
concurrency.messaging quotations kernel.private words
sequences.private assocs models ;
IN: tools.walker

SYMBOL: walker-hook

! Thread local
SYMBOL: walker-thread

: get-walker-thread ( -- thread )
    walker-thread tget [
        walker-hook get [ "No walker hook" throw ] or call
        walker-thread tget
    ] unless* ;

: break ( -- )
    callstack [
        over set-continuation-call

        get-walker-thread send-synchronous {
            { [ dup continuation? ] [ (continue) ] }
            { [ dup quotation? ] [ call ] }
            { [ dup not ] [ "Single stepping abandoned" throw ] }
        } cond
    ] curry callcc0 ;

: walk ( quot -- ) \ break add* call ;

! Messages sent to walker thread
SYMBOL: step
SYMBOL: step-out
SYMBOL: step-into
SYMBOL: step-all
SYMBOL: step-into-all
SYMBOL: step-back
SYMBOL: detach
SYMBOL: abandon
SYMBOL: call-in

! Thread locals
SYMBOL: walker-status
SYMBOL: walker-continuation
SYMBOL: walker-history

SYMBOL: +running+
SYMBOL: +suspended+
SYMBOL: +stopped+

: change-frame ( continuation quot -- continuation' )
    #! Applies quot to innermost call frame of the
    #! continuation.
    over continuation-call clone
    [
        dup innermost-frame-scan 1+
        swap innermost-frame-quot
        rot call
    ] keep
    [ set-innermost-frame-quot ] keep
    over set-continuation-call ; inline

: step-msg ( continuation -- continuation' )
    [
        2dup nth \ break = [
            nip
        ] [
            swap 1+ cut [ break ] swap 3append
        ] if
    ] change-frame ;

: step-out-msg ( continuation -- continuation' )
    [ nip \ break add ] change-frame ;

GENERIC: (step-into) ( obj -- )

M: wrapper (step-into) wrapped break ;
M: object (step-into) break ;
M: callable (step-into) \ break add* break ;

: (step-into-if) ? walk ;

: (step-into-dispatch) nth walk ;

: (step-into-execute) ( word -- )
    dup "step-into" word-prop [
        call
    ] [
        dup primitive? [
            execute break
        ] [
            word-def walk
        ] if
    ] ?if ;

: (step-into-continuation)
    continuation callstack over set-continuation-call break ;

M: word (step-into) (step-into-execute) ;

{
    { call [ walk ] }
    { (throw) [ drop walk ] }
    { execute [ (step-into-execute) ] }
    { if [ (step-into-if) ] }
    { dispatch [ (step-into-dispatch) ] }
    { continuation [ (step-into-continuation) ] }
} [ "step-into" set-word-prop ] assoc-each

{
    >n ndrop >c c>
    continue continue-with
    stop yield suspend sleep (spawn)
    suspend
} [
    dup [ execute break ] curry
    "step-into" set-word-prop
] each

\ break [ break ] "step-into" set-word-prop

: step-into-msg ( continuation -- continuation' )
    [
        swap cut [
            swap % unclip literalize , \ (step-into) , %
        ] [ ] make
    ] change-frame ;

: status ( -- symbol )
    walker-status tget model-value ;

: set-status ( symbol -- )
    walker-status tget set-model ;

: detach-msg ( -- f )
    +stopped+ set-status ;

: keep-running ( continuation -- continuation )
    +running+ set-status
    dup continuation? [ dup walker-history tget push ] when ;

: walker-stopped ( -- )
    +stopped+ set-status
    [
        {
            { detach [ detach-msg ] }
            [ drop f ]
        } case
    ] handle-synchronous
    walker-stopped ;

: step-into-all-loop ( -- )
    +running+ set-status
    [ status +stopped+ eq? not ] [
        [
            {
                { detach [ detach-msg ] }
                { step [ f ] }
                { step-out [ f ] }
                { step-into [ f ] }
                { step-all [ f ] }
                { step-into-all [ f ] }
                { step-back [ f ] }
                { f [ walker-stopped ] }
                [ step-into-msg ]
            } case
        ] handle-synchronous
    ] [ ] while ;

: walker-suspended ( continuation -- continuation' )
    +suspended+ set-status
    [ status +suspended+ eq? ] [
        [
            {
                ! These are sent by the walker tool. We reply
                ! and keep cycling.
                { detach [ detach-msg ] }
                ! These change the state of the thread being
                ! interpreted, so we modify the continuation and
                ! output f.
                { step [ step-msg keep-running ] }
                { step-out [ step-out-msg keep-running ] }
                { step-into [ step-into-msg keep-running ] }
                { step-all [ keep-running ] }
                { step-into-all [ step-into-all-loop ] }
                { abandon [ drop f keep-running ] }
                ! Pass quotation to debugged thread
                { call-in [ nip keep-running ] }
                ! Pass previous continuation to debugged thread
                { step-back [ drop walker-history tget pop f ] }
            } case
        ] handle-synchronous
    ] [ ] while ;

: walker-loop ( -- )
    +running+ set-status
    [ status +stopped+ eq? not ] [
        [
            {
                { detach [ detach-msg ] }
                ! ignore these commands while the thread is
                ! running
                { step [ f ] }
                { step-out [ f ] }
                { step-into [ f ] }
                { step-all [ f ] }
                { step-into-all [ step-into-all-loop ] }
                { step-back [ f ] }
                { f [ walker-stopped f ] }
                ! thread hit a breakpoint and sent us the
                ! continuation, so we modify it and send it
                ! back.
                [ walker-suspended ]
            } case
        ] handle-synchronous
    ] [ ] while ;

: associate-thread ( walker -- )
    dup walker-thread tset
    [ f swap send ] curry self set-thread-exit-handler ;

: start-walker-thread ( status continuation -- thread' )
    [
        walker-continuation tset
        walker-status tset
        V{ } clone walker-history tset
        walker-loop
    ] 2curry
    "Walker on " self thread-name append spawn
    [ associate-thread ] keep ;
