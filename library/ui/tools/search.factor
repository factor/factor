! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-search
USING: gadgets gadgets-frames gadgets-labels gadgets-panes
gadgets-scrolling gadgets-text gadgets-theme generic help
inspector kernel models sequences words ;

TUPLE: search-gadget input ;

: <search-pane> ( model quot -- )
    [ over empty? [ 2drop ] [ call ] if ] curry
    <pane-control> ;

C: search-gadget ( quot -- )
    >r f <model> dup r> {
        { [ <field> ] set-search-gadget-input f @top }
        { [ swap <search-pane> <scroller> ] f f @center }
    } make-frame* ;

M: search-gadget focusable-child* search-gadget-input ;

M: search-gadget pref-dim* drop { 400 500 } ;

: apropos-window
    [ apropos ] <search-gadget>
    "Apropos" open-titled-window ;

: search-help-window
    [ search-help. ] <search-gadget>
    "Search help" open-titled-window ;
