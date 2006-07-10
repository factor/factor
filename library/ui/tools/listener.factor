! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-listener
USING: arrays gadgets gadgets-editors gadgets-frames
gadgets-labels gadgets-panes gadgets-presentations
gadgets-scrolling gadgets-theme gadgets-tiles gadgets-tracks
generic hashtables inspector io jedit kernel listener math
models namespaces parser prettyprint sequences shells styles
threads words ;

TUPLE: listener-gadget pane stack ;

: ui-listener-hook ( listener -- )
    >r datastack-hook get call r>
    listener-gadget-stack set-model ;

: listener-thread ( listener -- )
    dup listener-gadget-pane [
        [ ui-listener-hook ] curry listener-hook set tty
    ] with-stream* ;

: start-listener ( listener -- )
    [ >r clear r> init-namespaces listener-thread ] in-thread
    drop ;

: <pane-tile> ( model quot title -- gadget )
    >r <pane-control> <scroller> r> f <tile> ;

: <stack-tile> ( model title -- gadget )
    [ stack. ] swap <pane-tile> ;

: <stack-display> ( -- gadget )
    gadget get listener-gadget-stack "Stack" <stack-tile> ;

C: listener-gadget ( -- gadget )
    f <model> over set-listener-gadget-stack {
        { [ <input-pane> ] set-listener-gadget-pane [ <scroller> ] 5/6 }
        { [ <stack-display> ] f f 1/6 }
    } { 0 1 } make-track* dup start-listener ;

M: listener-gadget pref-dim*
    delegate pref-dim* { 600 600 } vmax ;

M: listener-gadget focusable-child* ( listener -- gadget )
    listener-gadget-pane ;

M: listener-gadget gadget-title drop "Listener" <model> ;

: listener-window ( -- ) <listener-gadget> open-window ;

: call-listener ( quot/string listener -- )
    listener-gadget-pane over quotation?
    [ pane-call ] [ replace-input ] if ;

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
