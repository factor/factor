! Copyright (C) 2004, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: threads kernel namespaces continuations combinators
sequences math namespaces.private continuations.private
concurrency.messaging quotations kernel.private words
sequences.private assocs models models.arrow arrays accessors
generic generic.standard definitions make sbufs
tools.continuations parser tools.annotations fry ;
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
        [ variables>> walker-status of ]
        [ variables>> walker-continuation of ]
        [ ] tri
    ] [
        f <model>
        f <model>
        2dup start-walker-thread
    ] if* ;

: walk ( quot -- quot' )
    \ break prefix [ break rethrow ] recover ;

<< \ walk t "no-compile" set-word-prop >>

break-hook [
    [
        get-walker-thread
        [ show-walker-hook get call ] keep
        send-synchronous
    ]
] initialize

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

: status ( -- symbol )
    walker-status tget value>> ;

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
                    [ continuation-step-into ] bi
                ]
            } case
        ] handle-synchronous
    ] while ;

: continuation-step-back ( continuation -- continuation' )
    walker-history tget
    [ pop* ]
    [ [ nip pop ] unless-empty ] bi ;

: walker-suspended ( continuation -- continuation' )
    +suspended+ set-status
    [ status +suspended+ eq? ] [
        dup walker-history tget push
        dup walker-continuation tget set-model
        [
            {
                ! These are sent by the walker tool. We reply
                ! and keep cycling.
                { step [ continuation-step keep-running ] }
                { step-out [ continuation-step-out keep-running ] }
                { step-into [ continuation-step-into keep-running ] }
                { step-all [ keep-running ] }
                { step-into-all [ step-into-all-loop ] }
                { abandon [ drop f keep-running ] }
                ! Pass quotation to debugged thread
                { call-in [ keep-running ] }
                ! Pass previous continuation to debugged thread
                { step-back [ continuation-step-back ] }
            } case f
        ] handle-synchronous
    ] while ;

: walker-loop ( -- )
    +running+ set-status
    [ status +stopped+ eq? ] [
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
    ] until ;

: associate-thread ( walker -- )
    walker-thread tset
    [ f walker-thread tget send-synchronous drop ]
    self exit-handler<< ;

: start-walker-thread ( status continuation -- thread' )
    self [
        walking-thread tset
        walker-continuation tset
        walker-status tset
        V{ } clone walker-history tset
        walker-loop
    ] 3curry
    "Walker on " self name>> append spawn
    [ associate-thread ] keep ;

: breaklist+ ( word -- ) 
    "breaklist" get-global swap suffix "breaklist" set-global ;

: breakpoint ( word -- )
    dup breaklist+
    [ add-breakpoint ] annotate ;

: breakpoint-if ( word quot: ( ... -- ... ? ) -- )
    over breaklist+
    '[ [ _ [ [ break ] when ] ] dip 3append ] annotate ;

: breakpoint-after ( word n -- )
    0 1array swap '[
        [
            0 _ [ 1 + dup ] change-nth-unsafe
            _ >= [ break ] when
        ] prepend
    ] annotate ;

! For convenience
IN: syntax

SYNTAX: B \ break suffix! ;

SYNTAX: B: scan-word definition
    [ break "now press O I to land inside the parsing word" drop ]
    prepose call( accum -- accum ) ;
