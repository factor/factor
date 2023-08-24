USING: kernel sequences vocabs.loader help.vocabs ui
ui.gadgets ui.gadgets.buttons ui.gadgets.packs ui.gadgets.borders
ui.gadgets.scrollers ui.tools.listener accessors assocs ;
IN: demos

: demo-vocabs ( -- seq ) "demos" tagged values concat [ name>> ] map ;

: <run-vocab-button> ( vocab-name -- button )
    dup '[ drop [ _ run ] \ run call-listener ] <border-button> ;

: <demo-runner> ( -- gadget )
    <filled-pile> { 2 2 } >>gap demo-vocabs [ <run-vocab-button> add-gadget ] each ;

MAIN-WINDOW: demos { { title "Demos" } }
    <demo-runner> { 2 2 } <border> <scroller> >>gadgets ;
