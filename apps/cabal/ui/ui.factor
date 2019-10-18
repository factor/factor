USING: kernel io namespaces sequences math threads gadgets
       gadgets-panes gadgets-interactor gadgets-scrolling gadgets-tracks ;

IN: cabal.ui

TUPLE: cabal-gadget input output ;

: <cabal-input> ( -- gadget )
    gadget get cabal-gadget-output <pane-stream> <interactor> ;

C: cabal-gadget ( -- gadget )
    {
        {
            [ <scrolling-pane> ]
            set-cabal-gadget-output
            [ <scroller> ]
            5/6
        }
        {
            [ <cabal-input> ]
            set-cabal-gadget-input
            [ <scroller> ]
            1/6
        }
    } { 0 1 } make-track* ;

M: cabal-gadget pref-dim* drop { 550 650 } ;

: cabal-stream ( cabal -- stream )
    dup cabal-gadget-input swap cabal-gadget-output <pane-stream>
    <duplex-stream> ;

: incoming-loop ( stream -- ) dup stream-readln print incoming-loop ;

: outgoing-loop ( stream -- )
readln over stream-print dup stream-flush outgoing-loop ;

: cabal-thread ( -- )
    "cabal://" write readln 
    ":" split1 string>number <client> 
    [ outgoing-loop ] in-thread incoming-loop ;

: cabal-client ( -- )
    <cabal-gadget> dup "Cabal Client" open-window
    cabal-stream [ [ cabal-thread ] with-stream ] in-thread drop ;