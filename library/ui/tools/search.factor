! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-search
USING: gadgets gadgets-editors gadgets-frames gadgets-labels
gadgets-panes gadgets-scrolling gadgets-theme generic help
inspector kernel sequences words ;

TUPLE: search-gadget pane input quot ;

: do-search ( apropos -- )
    dup search-gadget-input commit-editor-text dup empty? [
        2drop
    ] [
        over search-gadget-pane
        rot search-gadget-quot with-pane
    ] if ;

search-gadget H{ { T{ key-down f f "RETURN" } [ do-search ] } }
set-gestures

C: search-gadget ( quot -- )
    [ set-search-gadget-quot ] keep {
        { [ <pane> ] set-search-gadget-pane [ <scroller> ] @center }
        { [ "" <editor> ] set-search-gadget-input f @top }
    } make-frame* ;

M: search-gadget focusable-child* search-gadget-input ;

M: search-gadget pref-dim* drop { 400 500 } ;

: apropos-window
    [ apropos ] <search-gadget>
    "Apropos" open-titled-window ;

: search-help-window
    [ search-help. ] <search-gadget>
    "Search help" open-titled-window ;
