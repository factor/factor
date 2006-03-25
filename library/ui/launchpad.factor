IN: gadgets-launchpad
USING: gadgets gadgets-browser gadgets-borders gadgets-buttons
gadgets-labels gadgets-layouts gadgets-listener gadgets-panes
gadgets-scrolling gadgets-theme help inspector io kernel memory
namespaces sequences ; 

: <launchpad> ( menu -- )
    [ first2 >r <label> [ drop ] r> append <bevel-button> ] map
    make-pile 1 over set-pack-fill { 5 5 0 } over set-pack-gap
    <default-border> dup highlight-theme ;

: scratch-window ( quot -- )
    make-pane <scroller> "Scratch" simple-window ;

: handbook-window ( -- )
    T{ link f "handbook" } browser-window ;

: tutorial-window ( -- )
    T{ link f "tutorial" } browser-window ;

: default-launchpad
    {
        { "Listener" [ listener-window ] }
        { "Documentation" [ handbook-window ] }
        { "Tutorial" [ tutorial-window ] }
        { "Vocabularies" [ [ vocabs. ] scratch-window ] }
        { "Globals" [ global browser-window ] }
        { "Memory" [ [ heap-stats. terpri room. ] scratch-window ] }
        { "Save image" [ save ] }
        { "Exit" [ 0 exit ] }
    } <launchpad> ;

: launchpad-window ( -- )
    default-launchpad "Factor" simple-window ;
