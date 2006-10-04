! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-listener
USING: compiler arrays gadgets gadgets-frames gadgets-labels
gadgets-panes gadgets-scrolling gadgets-text gadgets-theme
gadgets-tracks gadgets-workspace generic hashtables tools io
kernel listener math models namespaces parser prettyprint
sequences shells strings styles threads words memory ;

TUPLE: listener-gadget input output stack ;

: ui-listener-hook ( listener -- )
    >r datastack r> listener-gadget-stack set-model ;

: listener-stream ( listener -- stream )
    dup listener-gadget-input swap listener-gadget-output
    <duplex-stream> ;

: <listener-input> ( -- gadget )
    gadget get listener-gadget-output <interactor> ;

: <stack-display> ( -- gadget )
    gadget get listener-gadget-stack
    [ stack. ] "Stack" <labelled-pane> ;

: init-listener ( listener -- )
    f <model> swap set-listener-gadget-stack ;

: listener-thread ( listener -- )
    dup listener-stream [
        [ ui-listener-hook ] curry listener-hook set
        find-messages batch-errors set
        tty
    ] with-stream* ;

: start-listener ( listener -- )
    [ >r clear r> init-namespaces listener-thread ] in-thread
    drop ;

C: listener-gadget ( -- gadget )
    dup init-listener {
        { [ <scrolling-pane> ] set-listener-gadget-output [ <scroller> ] 4/6 }
        { [ <stack-display> ] f f 1/6 }
        { [ <listener-input> ] set-listener-gadget-input [ <scroller> "Input" <labelled-gadget> ] 1/6 }
    } { 0 1 } make-track* ;

M: listener-gadget focusable-child*
    listener-gadget-input ;

M: listener-gadget call-tool* ( input listener -- )
    >r input-string r> listener-gadget-input set-editor-text ;

M: listener-gadget tool-scroller
    listener-gadget-output find-scroller ;

M: listener-gadget tool-help
    drop "ui-listener" ;

: find-listener ( -- listener )
    listener-gadget find-workspace show-tool tool-gadget ;

: call-listener ( quot -- )
    find-listener listener-gadget-input interactor-call ;

: listener-run-files ( seq -- )
    dup empty? [
        drop
    ] [
        [ [ run-file ] each ] curry call-listener
    ] if ;

: listener-eof ( listener -- )
    listener-gadget-input f swap interactor-eval ;

: (listener-history) ( listener -- )
    dup listener-gadget-output [
        listener-gadget-input interactor-history
        [ dup print-input ] each
    ] with-stream* ;

: listener-history ( listener -- )
    [ [ (listener-history) ] curry ] keep
    call-listener ;

: clear-listener-output ( listener -- )
    [ listener-gadget-output [ pane-clear ] curry ] keep
    call-listener ;

: clear-listener-stack ( listener -- )
    [ clear ] swap call-listener ;

listener-gadget "Listener commands" {
    { "Restart" T{ key-down f { C+ } "r" } [ start-listener ] }
    { "Send EOF" T{ key-down f { C+ } "d" } [ listener-eof ] }
    { "History" T{ key-down f { C+ } "h" } [ listener-history ] }
    { "Clear output" T{ key-down f f "CLEAR" } [ clear-listener-output ] }
    { "Clear stack" T{ key-down f { C+ } "CLEAR" } [ clear-listener-stack ] }
} define-commands
