! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: gadgets gadgets-labels gadgets-layouts gadgets-theme
gadgets-viewports hashtables kernel math namespaces queues
sequences threads ;

: layout-queued ( -- )
    invalid dup queue-empty? [
        drop
    ] [
        deque dup layout
        find-world [ dup world-handle set ] when*
        layout-queued
    ] if ;

: init-ui ( -- )
    H{ } clone \ timers set-global
    <queue> \ invalid set-global ;
    
: ui-step ( -- )
    do-timers
    [ layout-queued ] make-hash hash-values
    [ dup world-handle [ draw-world ] [ drop ] if ] each
    10 sleep ;

: close-global ( world global -- )
    dup get-global find-world rot eq?
    [ f swap set-global ] [ drop ] if ;

: close-world ( world -- )
    dup hand-clicked close-global
    dup hand-gadget close-global
    f over request-focus* dup remove-notify
    dup free-fonts f swap set-world-handle ;

: <status-bar> ( -- gadget ) "" <label> dup highlight-theme ;

GENERIC: gadget-title ( gadget -- string )

M: gadget gadget-title drop "Factor" ;

M: world gadget-title world-gadget gadget-title ;

TUPLE: titled-gadget title ;

M: titled-gadget gadget-title titled-gadget-title ;

C: titled-gadget ( title gadget -- )
    [ >r <viewport> r> set-gadget-delegate ] keep
    [ set-titled-gadget-title ] keep ;

: update-title ( gadget -- )
    dup gadget-parent dup world?
    [ >r gadget-title r> set-title ] [ 2drop ] if ;

: open-window ( gadget -- )
    [ <status-bar> <world> dup prefer ] keep
    gadget-title open-window* ;

: open-titled-window ( gadget title -- )
    <titled-gadget> open-window ;

: (open-tool) ( arg cons setter -- )
    >r call tuck r> call open-window ; inline

: open-tool ( arg pred cons setter -- )
    rot drop (open-tool) ;

: call-tool ( arg gadget pred cons setter -- )
    >r >r find-parent dup [
        r> drop r> call
    ] [
        drop r> r> (open-tool)
    ] if ;
