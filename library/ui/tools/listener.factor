! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-listener
USING: arrays gadgets gadgets-frames gadgets-labels
gadgets-panes gadgets-scrolling
gadgets-text gadgets-theme gadgets-tiles gadgets-tracks generic
hashtables inspector io kernel listener math models
namespaces parser prettyprint sequences shells styles threads
words memory ;

TUPLE: listener-gadget input output stack ;

: ui-listener-hook ( listener -- )
    >r datastack r> listener-gadget-stack set-model ;

: listener-stream ( listener -- stream )
    dup listener-gadget-input swap listener-gadget-output
    <duplex-stream> ;

: listener-thread ( listener -- )
    dup listener-stream [
        [ ui-listener-hook ] curry listener-hook set tty
    ] with-stream* ;

: start-listener ( listener -- )
    [ >r clear r> init-namespaces listener-thread ] in-thread
    drop ;

: <pane-tile> ( model quot title -- gadget )
    >r <pane-control> <scroller> r> f <tile> ;

: <stack-tile> ( model title -- gadget )
    [ stack. ] swap <pane-tile> ;

: <listener-input> ( -- gadget )
    gadget get listener-gadget-output <interactor> ;

: <stack-display> ( -- gadget )
    gadget get listener-gadget-stack "Stack" <stack-tile> ;

: init-listener ( listener -- )
    f <model> swap set-listener-gadget-stack ;

C: listener-gadget ( -- gadget )
    dup init-listener {
        { [ <scrolling-pane> ] set-listener-gadget-output [ <scroller> ] 4/6 }
        { [ <stack-display> ] f f 1/6 }
        { [ <listener-input> ] set-listener-gadget-input [ <scroller> ] 1/6 }
    } { 0 1 } make-track* dup start-listener ;

M: listener-gadget focusable-child*
    listener-gadget-input ;

M: listener-gadget gadget-title drop "Listener" <model> ;

: listener-available? ( gadget -- ? )
    dup listener-gadget? [
        listener-gadget-input interactor-busy? not
    ] [
        drop f
    ] if ;

: clear-listener ( listener -- )
    listener-gadget-output pane-clear ;
