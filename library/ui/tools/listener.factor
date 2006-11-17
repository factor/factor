! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-listener
USING: arrays compiler gadgets gadgets-labels
gadgets-panes gadgets-scrolling gadgets-text
gadgets-theme gadgets-tracks gadgets-workspace
generic hashtables tools io kernel listener math models
namespaces parser prettyprint sequences shells strings styles
threads words definitions help ;

TUPLE: listener-gadget input output stack use ;

: ui-listener-hook ( listener -- )
    use get over set-listener-gadget-use
    >r datastack r> listener-gadget-stack set-model ;

: listener-stream ( listener -- stream )
    dup listener-gadget-input
    swap listener-gadget-output <pane-stream>
    <duplex-stream> ;

: <listener-input> ( -- gadget )
    gadget get listener-gadget-output
    <pane-stream> <interactor> ;

: <stack-display> ( -- gadget )
    gadget get listener-gadget-stack
    [ stack. ] "Stack" <labelled-pane> ;

: init-listener ( listener -- )
    f <model> swap set-listener-gadget-stack ;

: welcome. ( -- )
    "If this is your first time with Factor, please read " print
    "ui-tools" ($link) ", and especially " write
    "ui-listener" ($link) "." print terpri ;

: listener-thread ( listener -- )
    dup listener-stream [
        [ ui-listener-hook ] curry listener-hook set
        find-messages batch-errors set
        welcome.
        tty
    ] with-stream* ;

: start-listener ( listener -- )
    [ >r clear r> init-namespaces listener-thread ] in-thread
    drop ;

C: listener-gadget ( -- gadget )
    dup init-listener {
        {
            [ <scrolling-pane> ]
            set-listener-gadget-output
            [ <scroller> ]
            4/6
        }
        { [ <stack-display> ] f f 1/6 }
        {
            [ <listener-input> ]
            set-listener-gadget-input
            [ <scroller> "Input" <labelled-gadget> ]
            1/6
        }
    } { 0 1 } make-track* ;

M: listener-gadget focusable-child*
    listener-gadget-input ;

M: listener-gadget call-tool* ( input listener -- )
    >r input-string r> listener-gadget-input set-editor-text ;

M: listener-gadget tool-scroller
    listener-gadget-output find-scroller ;

M: listener-gadget tool-help
    drop "ui-listener" ;

: workspace-busy? ( workspace -- ? )
    listener-gadget swap find-tool nip tool-gadget
    listener-gadget-input interactor-busy? ;

: find-listener ( -- listener )
    listener-gadget
    [ workspace-busy? not ] find-workspace*
    show-tool tool-gadget ;

: (call-listener) ( quot listener -- )
    listener-gadget-input interactor-call ;

: call-listener ( quot -- )
    find-listener (call-listener) ;

: eval-listener ( string -- )
    find-listener
    listener-gadget-input [ set-editor-text ] keep
    interactor-commit ;

: listener-run-files ( seq -- )
    dup empty? [
        drop
    ] [
        [ run-files recompile ] curry call-listener
    ] if ;

: listener-eof ( listener -- )
    listener-gadget-input f swap interactor-eval ;

: clear-listener-output ( listener -- )
    [ listener-gadget-output [ pane-clear ] curry ] keep
    (call-listener) ;

: clear-listener-stack ( listener -- )
    [ clear ] swap (call-listener) ;

listener-gadget "toolbar" {
    { "Restart" f [ start-listener ] }
    {
        "Clear output"
        T{ key-down f f "CLEAR" }
        [ clear-listener-output ]
    }
    {
        "Clear stack"
        T{ key-down f { C+ } "CLEAR" }
        [ clear-listener-stack ]
    }
    { "Send EOF" T{ key-down f { C+ } "d" } [ listener-eof ] }
} define-commands
