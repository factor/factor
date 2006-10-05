! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-listener
USING: compiler arrays gadgets gadgets-frames gadgets-labels
gadgets-panes gadgets-scrolling gadgets-text gadgets-lists
gadgets-search gadgets-theme gadgets-tracks gadgets-workspace
generic hashtables tools io kernel listener math models
namespaces parser prettyprint sequences shells strings styles
threads words ;

TUPLE: listener-gadget input output stack minibuffer use ;

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

: find-listener ( -- listener )
    listener-gadget find-workspace show-tool tool-gadget ;

: (call-listener) ( quot listener -- )
    listener-gadget-input interactor-call ;

: call-listener ( quot -- )
    find-listener (call-listener) ;

: listener-run-files ( seq -- )
    dup empty? [
        drop
    ] [
        [ [ run-file ] each ] curry call-listener
    ] if ;

: listener-eof ( listener -- )
    listener-gadget-input f swap interactor-eval ;

: clear-listener-output ( listener -- )
    [ listener-gadget-output [ pane-clear ] curry ] keep
    (call-listener) ;

: clear-listener-stack ( listener -- )
    [ clear ] swap (call-listener) ;

: hide-minibuffer ( listener -- )
    dup listener-gadget-minibuffer dup
    [ over track-remove ] [ drop ] if
    dup listener-gadget-input request-focus
    f swap set-listener-gadget-minibuffer ;

: show-minibuffer ( gadget listener -- )
    [ hide-minibuffer ] keep
    [ set-listener-gadget-minibuffer ] 2keep
    dupd track-add request-focus ;

: show-word-search ( listener action -- )
    >r dup listener-gadget-input selected-word r> <word-search>
    swap show-minibuffer ;

: show-list ( seq presenter action listener -- )
    >r >r >r <model> r> r> <list> <scroller> r>
    show-minibuffer ;

: show-history ( listener -- )
    [
        listener-gadget-input interactor-history <reversed>
        [ [ dup print-input ] make-pane ]
        [
            find-listener
            [ listener-gadget-input set-editor-text ] keep
            hide-minibuffer
        ]
    ] keep show-list ;

: insert-completion ( completion -- )
    find-listener [
        >r word-name r> listener-gadget-input user-input
    ] keep hide-minibuffer ;

listener-gadget "Toolbar" {
    { "Restart" T{ key-down f { C+ } "r" } [ start-listener ] }
    {
        "History"
        T{ key-down f { C+ } "h" }
        [ show-history ]
    }
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

listener-gadget "Listener commands" {
    {
        "Complete word"
        T{ key-down f f "TAB" }
        [ [ insert-completion ] show-word-search ]
    }
    {
        "Hide minibuffer"
        T{ key-down f f "ESCAPE" }
        [ hide-minibuffer ]
    }
} define-commands
