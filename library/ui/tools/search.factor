! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-search
USING: arrays gadgets gadgets-frames gadgets-labels
gadgets-panes gadgets-scrolling gadgets-text gadgets-theme
generic help tools kernel models sequences words
gadgets-borders ;

TUPLE: search-gadget input ;

: <search-pane> ( model quot -- )
    [ over empty? [ 2drop ] [ call ] if ] curry
    <pane-control> ;

: <search-bar> ( field -- gadget )
    {
        { [ "Search: " <label> ] f f @left }
        { f f f @center }
    } make-frame ;

C: search-gadget ( quot -- )
    >r f <model> dup r> {
        { [ <field> ] set-search-gadget-input [ <search-bar> ] @top }
        { [ swap <search-pane> <scroller> ] f f @center }
    } make-frame* ;

M: search-gadget focusable-child* search-gadget-input ;
