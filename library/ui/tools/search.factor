! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-search
USING: gadgets gadgets-editors gadgets-frames gadgets-labels
gadgets-panes gadgets-scrolling gadgets-theme generic help
inspector kernel sequences words ;

TUPLE: search-gadget scroller input quot ;

: search-gadget-pane ( apropos -- pane )
    search-gadget-scroller scroller-gadget ;

: do-search ( apropos -- )
    dup search-gadget-input commit-editor-text dup empty? [
        2drop
    ] [
        over search-gadget-pane
        rot search-gadget-quot with-pane
    ] if ;

M: search-gadget gadget-gestures
    drop H{
        { T{ key-down f f "RETURN" } [ do-search ] }
    } ;

C: search-gadget ( quot -- )
    [ set-search-gadget-quot ] keep {
        { [ <pane> <scroller> ] set-search-gadget-scroller @center }
        { [ "" <editor> ] set-search-gadget-input @top }
    } make-frame* ;

M: search-gadget focusable-child* search-gadget-input ;

M: search-gadget pref-dim* drop { 400 500 } ;

: apropos-window
    [ apropos ] <search-gadget>
    "Apropos" <titled-gadget>
    open-window ;

: search-help-window
    [ search-help. ] <search-gadget>
    "Search help" <titled-gadget>
    open-window ;
