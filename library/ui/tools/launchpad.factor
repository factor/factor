! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-launchpad
USING: gadgets gadgets-borders gadgets-browser
gadgets-buttons gadgets-labels gadgets-listener gadgets-panes
gadgets-presentations gadgets-scrolling gadgets-search
gadgets-theme generic help inspector io kernel memory namespaces
prettyprint sequences words ;

: <launchpad> ( menu -- )
    [ first2 >r <label> [ drop ] r> append <bevel-button> ] map
    make-pile 1 over set-pack-fill { 5 5 } over set-pack-gap
    <default-border> dup highlight-theme ;

: pane-window ( quot title -- )
    >r make-pane <scroller> r> open-titled-window ;

: handbook-window ( -- )
    T{ link f "handbook" } show ;

: memory-window ( -- )
    [ heap-stats. terpri room. ] "Memory" pane-window ;

: globals-window ( -- )
    global show ;

: default-launchpad
    {
        { "Listener" [ listener-window ] }
        { "Browser" [ browser-window ] }
        { "Documentation" [ handbook-window ] }
        { "Globals" [ globals-window ] }
        { "Memory" [ memory-window ] }
        { "Save image" [ save ] }
        { "Exit" [ 0 exit ] }
    } <launchpad> ;

: launchpad-window ( -- )
    default-launchpad open-window ;
