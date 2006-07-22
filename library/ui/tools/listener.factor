! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-listener
USING: arrays gadgets gadgets-frames gadgets-labels
gadgets-panes gadgets-presentations gadgets-scrolling
gadgets-text gadgets-theme gadgets-tiles gadgets-tracks generic
hashtables inspector io jedit kernel listener math models
namespaces parser prettyprint sequences shells styles threads
words ;

TUPLE: listener-gadget input output stack ;

: ui-listener-hook ( listener -- )
    >r datastack-hook get call r>
    listener-gadget-stack set-model ;

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
    [ [ 32 margin set stack. ] with-scope ] swap <pane-tile> ;

: <listener-input> ( listener -- gadget )
    listener-gadget-input <scroller> "Input" f <tile> ;

: <stack-display> ( listener -- gadget )
    listener-gadget-stack "Stack" <stack-tile> ;

: <listener-bar> ( listener -- gadget )
    dup {
        { [ <listener-input> ] f f 2/3 }
        { [ <stack-display> ] f f 1/3 }
    } { 1 0 } make-track ;

: init-listener ( listener -- )
    f <model> over set-listener-gadget-stack
    <scrolling-pane> over set-listener-gadget-output
    dup listener-gadget-output <interactor>
    swap set-listener-gadget-input ;

C: listener-gadget ( -- gadget )
    dup init-listener {
        { [ gadget get listener-gadget-output <scroller> ] f f 5/6 }
        { [ gadget get <listener-bar> ] f f 1/6 }
    } { 0 1 } make-track* dup start-listener ;

M: listener-gadget pref-dim*
    delegate pref-dim* { 700 500 } vmax ;

M: listener-gadget focusable-child* ( listener -- gadget )
    listener-gadget-input ;

M: listener-gadget gadget-title drop "Listener" <model> ;

: listener-window ( -- ) <listener-gadget> open-window ;

: call-listener ( quot/string listener -- )
    listener-gadget-input over quotation?
    [ interactor-call ] [ set-editor-text ] if ;

: listener-tool
    [ listener-gadget? ]
    [ <listener-gadget> ]
    [ call-listener ] ;

: listener-run-files ( seq -- )
    dup empty? [
        drop
    ] [
        [ [ run-file ] each ] curry listener-tool call-tool
    ] if ;

M: input show ( input -- )
    input-string listener-tool call-tool ;

M: object show ( object -- )
    [ inspect ] curry listener-tool call-tool ;
