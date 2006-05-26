! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: gadgets gadgets-labels gadgets-layouts gadgets-theme
hashtables kernel math namespaces queues sequences threads ;

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

: open-window ( gadget title -- )
    >r <status-bar> <world> dup prefer r> open-window* ;

: (open-tool) ( arg cons setter -- )
    >r call tuck r> call "Tool" open-window ; inline

: open-tool ( arg pred cons setter -- )
    rot drop (open-tool) ;

: call-tool ( arg gadget pred cons setter -- )
    >r >r find-parent dup [
        r> drop r> call
    ] [
        drop r> r> (open-tool)
    ] if ;
