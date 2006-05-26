IN: gadgets-launchpad
USING: gadgets gadgets-apropos gadgets-borders gadgets-browser
gadgets-buttons gadgets-labels gadgets-layouts gadgets-listener
gadgets-panes gadgets-presentations gadgets-scrolling
gadgets-theme help inspector io kernel memory namespaces
sequences ; 

: <launchpad> ( menu -- )
    [ first2 >r <label> [ drop ] r> append <bevel-button> ] map
    make-pile 1 over set-pack-fill { 5 5 0 } over set-pack-gap
    <default-border> dup highlight-theme ;

: pane-window ( quot title -- )
    >r make-pane <scroller> r> open-window ;

: handbook-window ( -- )
    T{ link f "handbook" } f show-object ;

: memory-window ( -- )
    [ heap-stats. terpri room. ] "Memory" pane-window ;

: articles-window ( -- )
    [ articles. ] "Help index" pane-window ;

: apropos-window ( -- )
    <apropos-gadget> "Apropos" open-window ;

: globals-window ( -- )
    global f show-object ;

: default-launchpad
    {
        { "Listener" [ listener-window ] }
        { "Documentation" [ handbook-window ] }
        { "Help index" [ articles-window ] }
        { "Browser" [ f browser-window ] }
        { "Apropos" [ apropos-window ] }
        { "Globals" [ globals-window ] }
        { "Memory" [ memory-window ] }
        { "Save image" [ save ] }
        { "Exit" [ 0 exit ] }
    } <launchpad> ;

: launchpad-window ( -- )
    default-launchpad "Factor" open-window ;
