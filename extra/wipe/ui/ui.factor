! Copyright (C) 2019 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays calendar continuations fonts kernel locals
math math.parser
models namespaces sequences threads timers
ui ui.gadgets ui.gadgets.borders ui.gadgets.buttons
ui.gadgets.flex-borders ui.gadgets.labels
ui.gadgets.scrollers ui.gadgets.tables ui.gadgets.tracks
ui.gadgets.worlds ui.gestures ui.windows.drop-target
wipe ;
IN: wipe.ui

TUPLE: task
    path
    { countdown initial: 30 }
    paused? ! Is countdown frozen?
    error
;

TUPLE: wipe-table < table
    new-tasks
    timer
;

SINGLETON: task-renderer

M: task-renderer column-alignment drop { 0 1 } ;
M: task-renderer filled-column drop 0 ;
M: task-renderer column-titles drop { "Path" "Countdown" } ;
M: task-renderer row-columns
    drop [ path>> ] [
        dup error>> [ drop "error" ] [
            countdown>> dup 1 < [ drop "wiping..." ] [ number>string ] if
        ] if
    ] bi 2array ;

: countdown-tasks ( seq -- )
    [ dup paused?>> [ [ 1 - ] change-countdown ] unless drop ] each ;

! This is where the actual file wiping is done. This means that during a
! long IO operation there may be user actions performed during the yield.
: run-expired ( seq -- )
    [
        dup countdown>> 1 < [
            [ path>> wipe ] [
                >>error 1 >>countdown t >>paused? drop
            ] recover
        ] [ drop ] if
    ] each ;

: reject-expired ( seq -- seq' )
    [ countdown>> 1 < ] reject ;

: name-timer-thread ( timer -- )
    thread>> "Wipe Countdown Timer" >>name drop ;

! TODO: only relayout if there were changes in the counters.
:: <countdown-timer> ( wipe-table -- timer )
    [
        ! Call change-model twice to show the "wiping..." caption.
        wipe-table model>> [ dup countdown-tasks ] models:change-model
        wipe-table model>> [
            dup run-expired reject-expired wipe-table new-tasks>> append
            f wipe-table new-tasks<<
        ] models:change-model
    ] f 1 seconds <timer> ;

: <wipe-table> ( -- table )
    f <model> task-renderer wipe-table new-table
        dup <countdown-timer> >>timer
        monospace-font >>font ;

M: wipe-table graft*
    [ timer>> dup start-timer name-timer-thread ] [ call-next-method ] bi ;

M: wipe-table ungraft*
    [ timer>> stop-timer ] [ call-next-method ] bi ;

: <task> ( path -- task )
    task new swap >>path ;

! If the timer is already running, that means that the user dropped some
! new files onto the table while there is a long wiping operation ongoing.
! In this case we must add the new files both to the current model to have
! them displayed immediately, and to the new-tasks list, because the
! current model value will be replaced by the timer quotation.
: add-tasks ( wipe-table files -- )
    [ <task> ] map [ append ] curry over timer>> quotation-running?>> [
        2dup change-new-tasks drop
    ] when [ model>> ] dip models:change-model ;

: <stop-button> ( wipe-table -- button )
    [ timer>> stop-timer drop ] curry "Stop" swap <border-button> ;

: <go-button> ( wipe-table -- button )
    [
        nip timer>> dup thread>> [ drop ] [
            dup start-timer name-timer-thread
        ] if
    ] curry "Go" swap <border-button> ;

CONSTANT: caption
    "Drop files or folders onto the table below to have their contents wiped after a delay."

CONSTANT: controls
    { normal-title-bar close-button minimize-button resize-handles }

:: <wipe-window-attributes> ( -- world-attributes )
    <wipe-table> :> table
    ui.windows.drop-target:world-attributes new
        "Wipe Files" >>title
        controls >>window-controls
        { 500 450 } >>pref-dim
        vertical <track>
            caption <label> { 0 2 } <border> f track-add
            horizontal <track>
                table <stop-button> 1/2 track-add
                table <go-button> 1/2 track-add
            f track-add
            table <scroller> 1 track-add
        { 2 0 } <flex-border>
        >>gadgets
        [ table swap add-tasks ] >>on-file-drop ;

: wipe-window ( -- )
    [ <wipe-window-attributes> <drop-target> open-world-window ] with-ui ;

MAIN: wipe-window
