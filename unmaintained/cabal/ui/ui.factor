USING: kernel
       io
       io.streams.duplex
       io.sockets
       namespaces sequences math math.parser threads quotations splitting
       ui
       ui.gadgets 
       ui.gadgets.panes
       ui.gadgets.scrollers
       ui.gadgets.tracks
       ui.tools.interactor ;

IN: cabal.ui

TUPLE: cabal-gadget input output ;

: <cabal-input> ( -- gadget )
    gadget get cabal-gadget-output <pane-stream> <interactor> ;

: <cabal-gadget> ( -- gadget )
cabal-gadget construct-empty
dup
[ <scrolling-pane> over dupd set-cabal-gadget-output <scroller> 5/6 track,
  <cabal-input>    over dupd set-cabal-gadget-input  <scroller> 1/6 track,
  drop ]
curry
{ 0 1 }
build-track ;

M: cabal-gadget pref-dim* drop { 550 650 } ;

: cabal-stream ( cabal -- stream )
    dup cabal-gadget-input swap cabal-gadget-output <pane-stream>
    <duplex-stream> ;

: incoming-loop ( stream -- ) dup stream-readln print incoming-loop ;

: outgoing-loop ( stream -- )
readln over stream-print dup stream-flush outgoing-loop ;

: cabal-thread ( -- )
    "cabal://" write readln 
    ":" split1 string>number <inet> <client> 
    [ outgoing-loop ] in-thread incoming-loop ;

: cabal-client ( -- )
    <cabal-gadget> dup "Cabal Client" open-window
    cabal-stream [ [ cabal-thread ] with-stream ] in-thread drop ;

: cabal-client* ( -- ) [ cabal-client ] with-ui ;

MAIN: cabal-client*