! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: threads kernel namespaces continuations combinators
sequences math namespaces.private continuations.private
concurrency.messaging quotations kernel.private words
sequences.private assocs models arrays accessors
generic generic.standard definitions ;
IN: tools.walker

SYMBOL: show-walker-hook ! ( status continuation thread -- )

! Thread local in thread being walked
SYMBOL: walker-thread

! Thread local in walker thread
SYMBOL: walking-thread
SYMBOL: walker-status
SYMBOL: walker-continuation
SYMBOL: walker-history

DEFER: start-walker-thread

: get-walker-thread ( -- status continuation thread )
    walker-thread tget [
        [ thread-variables walker-status swap at ]
        [ thread-variables walker-continuation swap at ]
        [ ] tri
    ] [
        f <model>
        f <model>
        2dup start-walker-thread
    ] if* ;

: show-walker ( -- thread )
    get-walker-thread
    [ show-walker-hook get call ] keep ;

: after-break ( object -- )
    {
        { [ dup continuation? ] [ (continue) ] }
        { [ dup quotation? ] [ call ] }
        { [ dup not ] [ "Single stepping abandoned" rethrow ] }
    } cond ;

: break ( -- )
    continuation callstack over set-continuation-call
    show-walker send-synchronous
    after-break ;

\ break t "break?" set-word-prop

: walk ( quot -- quot' )
    \ break prefix [ break rethrow ] recover ;

GENERIC: add-breakpoint ( quot -- quot' )

M: callable add-breakpoint
    dup [ break ] head? [ \ break prefix ] unless ;

M: array add-breakpoint
    [ add-breakpoint ] map ;

M: object add-breakpoint ;

: (step-into-quot) ( quot -- ) add-breakpoint call ;

: (step-into-if) ? (step-into-quot) ;

: (step-into-dispatch) nth (step-into-quot) ;

: (step-into-execute) ( word -- )
    {
        { [ dup "step-into" word-prop ] [ "step-into" word-prop call ] }
        { [ dup standard-generic? ] [ effective-method (step-into-execute) ] }
        { [ dup hook-generic? ] [ effective-method (step-into-execute) ] }
        { [ dup uses \ suspend swap member? ] [ execute break ] }
        { [ dup primitive? ] [ execute break ] }
        [ word-def (step-into-quot) ]
    } cond ;

\ (step-into-execute) t "step-into?" set-word-prop

: (step-into-continuation)
    continuation callstack >>call break ;

! Messages sent to walker thread
SYMBOL: step
SYMBOL: step-out
SYMBOL: step-into
SYMBOL: step-all
SYMBOL: step-into-all
SYMBOL: step-back
SYMBOL: abandon
SYMBOL: call-in

SYMBOL: +running+
SYMBOL: +suspended+
SYMBOL: +stopped+

: change-frame ( continuation quot -- continuation' )
    #! Applies quot to innermost call frame of the
    #! continuation.
    >r clone r> [
        >r clone r>
        [
            >r
            [ innermost-frame-scan 1+ ]
            [ innermost-frame-quot ] bi
            r> call
        ]
        [ drop set-innermost-frame-quot ]
        [ drop ]
        2tri
    ] curry change-call ; inline

: step-msg ( continuation -- continuation' )
    [
        2dup nth \ break = [
            nip
        ] [
            swap 1+ cut [ break ] swap 3append
        ] if
    ] change-frame ;

: step-out-msg ( continuation -- continuation' )
    [ nip \ break suffix ] change-frame ;

{
    { call [ (step-into-quot) ] }
    { (throw) [ drop (step-into-quot) ] }
    { execute [ (step-into-execute) ] }
    { if [ (step-into-if) ] }
    { dispatch [ (step-into-dispatch) ] }
    { continuation [ (step-into-continuation) ] }
} [ "step-into" set-word-prop ] assoc-each

{
    >n ndrop >c c>
    continue continue-with
    stop suspend (spawn)
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
                { [ dup array? ] [ add-breakpoint , \ break , ] }
                { [ dup word? ] [ literalize , \ (step-into-execute) , ] }
                [ , \ break , ]
            } cond %
        ] [ ] make
    ] change-frame ;

: status ( -- symbol )
    walker-status tget model-value ;

: set-status ( symbol -- )
    walker-status tget set-model ;

: keep-running ( -- )
    +running+ set-status ;

: walker-stopped ( -- )
    +stopped+ set-status ;

: step-into-all-loop ( -- )
    +running+ set-status
    [ status +running+ eq? ] [
        [
            {
                { step [ f ] }
                { step-out [ f ] }
                { step-into [ f ] }
                { step-all [ f ] }
                { step-into-all [ f ] }
                { step-back [ f ] }
                { f [ +stopped+ set-status f ] }
                [
                    [ walker-continuation tget set-model ]
                    [ step-into-msg ] bi
                ]
            } case
        ] handle-synchronous
    ] [ ] while ;

: step-back-msg ( continuation -- continuation' )
    walker-history tget
    [ pop* ]
    [ dup empty? [ drop ] [ nip pop ] if ] bi ;

: walker-suspended ( continuation -- continuation' )
    +suspended+ set-status
    [ status +suspended+ eq? ] [
        dup walker-history tget push
        dup walker-continuation tget set-model
        [
            {
                ! These are sent by the walker tool. We reply
                ! and keep cycling.
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
    [ status +stopped+ eq? not ] [
        [
            {
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

! For convenience
IN: syntax

: B break ;
