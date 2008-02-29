! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: threads kernel namespaces continuations combinators
sequences math namespaces.private continuations.private
concurrency.messaging quotations kernel.private words
sequences.private assocs models ;
IN: tools.walker

SYMBOL: new-walker-hook ! ( -- )
SYMBOL: show-walker-hook ! ( thread -- )

! Thread local
SYMBOL: walker-thread
SYMBOL: walking-thread

: get-walker-thread ( -- thread )
    walker-thread tget [
        dup show-walker-hook get call
    ] [
        new-walker-hook get call
        walker-thread tget
    ] if* ;

: break ( -- )
    continuation callstack over set-continuation-call

    get-walker-thread send-synchronous {
        { [ dup continuation? ] [ (continue) ] }
        { [ dup quotation? ] [ call ] }
        { [ dup not ] [ "Single stepping abandoned" throw ] }
    } cond ;

\ break t "break?" set-word-prop

: add-breakpoint ( quot -- quot' )
    dup [ break ] head? [ \ break add* ] unless ;

: walk ( quot -- ) add-breakpoint call ;

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

\ (step-into-execute) t "step-into?" set-word-prop

: (step-into-continuation)
    continuation callstack over set-continuation-call break ;

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
SYMBOL: +detached+

: change-frame ( continuation quot -- continuation' )
    #! Applies quot to innermost call frame of the
    #! continuation.
    >r clone r>
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
            swap % unclip {
                { [ dup \ break eq? ] [ , ] }
                { [ dup quotation? ] [ add-breakpoint , \ break , ] }
                { [ dup word? ] [ literalize , \ (step-into-execute) , ] }
                { [ t ] [ , \ break , ] }
            } cond %
        ] [ ] make
    ] change-frame ;

: status ( -- symbol )
    walker-status tget model-value ;

: set-status ( symbol -- )
    walker-status tget set-model ;

: unassociate-thread ( -- )
    walker-thread walking-thread tget thread-variables delete-at
    [ ] walking-thread tget set-thread-exit-handler ;

: detach-msg ( -- )
    +detached+ set-status
    unassociate-thread ;

: keep-running ( -- )
    +running+ set-status ;

: walker-stopped ( -- )
    +stopped+ set-status
    [ status +stopped+ eq? ] [
        [
            {
                { detach [ detach-msg ] }
                [ drop ]
            } case f
        ] handle-synchronous
    ] [ ] while ;

: step-into-all-loop ( -- )
    +running+ set-status
    [ status +running+ eq? ] [
        [
            {
                { detach [ detach-msg f ] }
                { step [ f ] }
                { step-out [ f ] }
                { step-into [ f ] }
                { step-all [ f ] }
                { step-into-all [ f ] }
                { step-back [ f ] }
                { f [ +stopped+ set-status f ] }
                [
                    dup walker-continuation tget set-model
                    step-into-msg
                ]
            } case
        ] handle-synchronous
    ] [ ] while ;

: step-back-msg ( continuation -- continuation' )
    walker-history tget dup pop*
    empty? [ drop walker-history tget pop ] unless ;

: walker-suspended ( continuation -- continuation' )
    +suspended+ set-status
    [ status +suspended+ eq? ] [
        dup walker-history tget push
        dup walker-continuation tget set-model
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
                { step-back [ step-back-msg ] }
            } case f
        ] handle-synchronous
    ] [ ] while ;

: walker-loop ( -- )
    +running+ set-status
    [ status +detached+ eq? not ] [
        [
            {
                { detach [ detach-msg f ] }
                ! ignore these commands while the thread is
                ! running
                { step [ f ] }
                { step-out [ f ] }
                { step-into [ f ] }
                { step-all [ f ] }
                { step-into-all [ step-into-all-loop f ] }
                { step-back [ f ] }
                { abandon [ f ] }
                { f [ walker-stopped f ] }
                ! thread hit a breakpoint and sent us the
                ! continuation, so we modify it and send it
                ! back.
                [ walker-suspended ]
            } case
        ] handle-synchronous
    ] [ ] while ;

: associate-thread ( walker -- )
    walker-thread tset
    [ f walker-thread tget send-synchronous drop ]
    self set-thread-exit-handler ;

: start-walker-thread ( status continuation -- thread' )
    self [
        walking-thread tset
        walker-continuation tset
        walker-status tset
        V{ } clone walker-history tset
        walker-loop
    ] 3curry
    "Walker on " self thread-name append spawn
    [ associate-thread ] keep ;
