USING: kernel fry sequences vocabs.loader help.vocabs ui
ui.gadgets ui.gadgets.buttons ui.gadgets.packs ui.gadgets.borders
ui.gadgets.scrollers ui.tools.listener accessors ;
IN: demos

: demo-vocabs ( -- seq ) "demos" tagged [ second ] map concat [ name>> ] map ;

: <run-vocab-button> ( vocab-name -- button )
    dup '[ drop [ _ run ] \ run call-listener ] <border-button> ;

: <demo-runner> ( -- gadget )
    <pile> 1 >>fill { 2 2 } >>gap demo-vocabs [ <run-vocab-button> add-gadget ] each ;

: demos ( -- ) [ <demo-runner> { 2 2 } <border> <scroller> "Demos" open-window ] with-ui ;

MAIN: demos