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
    make-pile 1 over set-pack-fill { 5 5 0 } over set-pack-gap
    <default-border> dup highlight-theme ;

: pane-window ( quot title -- )
    >r make-pane <scroller> r> open-titled-window ;

: handbook-window ( -- )
    T{ link f "handbook" } show ;

: memory-window ( -- )
    [ heap-stats. terpri room. ] "Memory" pane-window ;

: articles-window ( -- )
    [ articles. ] "Help index" pane-window ;

: types-window ( -- )
    [ builtins get [ ] subset [ help ] word-outliner ]
    "Types" pane-window ;

: classes-window ( -- )
    [ classes [ help ] word-outliner ]
    "Classes" pane-window ;

: primitives-window ( -- )
    [ all-words [ primitive? ] subset [ help ] word-outliner ]
    "Primitives" pane-window ;

: apropos-window ( -- )
    [ apropos ] <search-gadget> open-window ;

: globals-window ( -- )
    global show ;

: default-launchpad
    {
        { "Listener" [ listener-window ] }
        { "Documentation" [ handbook-window ] }
        { "Help index" [ articles-window ] }
        { "Browser" [ f browser-window ] }
        { "Apropos" [ apropos-window ] }
        { "Globals" [ globals-window ] }
        { "Types" [ types-window ] }
        { "Classes" [ classes-window ] }
        { "Primitives" [ primitives-window ] }
        { "Memory" [ memory-window ] }
        { "Save image" [ save ] }
        { "Exit" [ 0 exit ] }
    } <launchpad> ;

: launchpad-window ( -- )
    default-launchpad open-window ;
