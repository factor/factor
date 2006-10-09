! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-listener
USING: compiler arrays gadgets gadgets-frames gadgets-labels
gadgets-panes gadgets-scrolling gadgets-text gadgets-lists
gadgets-search gadgets-theme gadgets-tracks gadgets-workspace
generic hashtables tools io kernel listener math models
namespaces parser prettyprint sequences shells strings styles
threads words definitions help ;

TUPLE: listener-gadget input output stack minibuffer ;

: ui-listener-hook ( listener -- )
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

: minibuffer-action ( quot -- quot )
    [ find-listener hide-minibuffer ] swap append ;

: show-word-search ( listener action -- )
    minibuffer-action
    >r dup listener-gadget-input selected-word r>
    <word-search> "Word search" <labelled-gadget>
    swap show-minibuffer ;

: show-source-files-search ( listener action -- )
    minibuffer-action
    "" swap <source-files-search>
    "Source file search" <labelled-gadget>
    swap show-minibuffer ;

: show-vocabs-search ( listener action -- )
    minibuffer-action
    >r dup listener-gadget-input selected-word r>
    <vocabs-search> "Vocabulary search" <labelled-gadget>
    swap show-minibuffer ;

: show-list ( seq presenter action listener -- )
    >r minibuffer-action <list> <scroller> r> show-minibuffer ;

: listener-history ( listener -- seq )
    listener-gadget-input interactor-history <reversed> ;

: show-history ( listener -- )
    [
        listener-gadget-input <model>
        [ [ dup print-input ] make-pane ]
        [ listener-gadget-input set-editor-text ]
    ] keep show-list ;

: insert-completion ( completion -- )
    word-name find-listener listener-gadget-input user-input ;

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

listener-gadget "Completion commands" {
    {
        "Complete word"
        T{ key-down f f "TAB" }
        [ [ insert-completion ] show-word-search ]
    }
    {
        "Edit file"
        T{ key-down f { C+ } "e" }
        [ [ edit-file ] show-source-files-search ]
    }
    {
        "Use vocabulary"
        T{ key-down f { C+ } "u" }
        [ [ [ use+ ] curry call-listener ] show-vocabs-search ]
    }
    {
        "Hide minibuffer"
        T{ key-down f f "ESCAPE" }
        [ hide-minibuffer ]
    }
} define-commands
