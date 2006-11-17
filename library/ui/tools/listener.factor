! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-listener
USING: compiler arrays gadgets gadgets-labels
gadgets-panes gadgets-scrolling gadgets-text gadgets-lists
gadgets-search gadgets-theme gadgets-tracks gadgets-workspace
generic hashtables tools io kernel listener math models
namespaces parser prettyprint sequences shells strings styles
threads words definitions help modules ;

TUPLE: listener-gadget input output stack use minibuffer ;

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

: hide-minibuffer ( listener -- )
    dup listener-gadget-minibuffer dup
    [ over track-remove ] [ drop ] if
    dup listener-gadget-input request-focus
    f swap set-listener-gadget-minibuffer ;

: show-minibuffer ( gadget listener -- )
    [ hide-minibuffer ] keep
    [ set-listener-gadget-minibuffer ] 2keep
    dupd track-add request-focus ;

: show-titled-minibuffer ( listener gadget title -- )
    <labelled-gadget> swap show-minibuffer ;

: show-word-search ( listener words -- )
    >r [ find-listener hide-minibuffer ]
    >r dup listener-gadget-input selected-word r>
    r> <word-search> "Word search" show-titled-minibuffer ;

: show-help-search ( listener -- )
    [ find-listener hide-minibuffer ]
    "" swap <help-search> "Help search" show-titled-minibuffer ;

: show-source-file-search ( listener action -- )
    [ find-listener hide-minibuffer ]
    "" swap <source-file-search>
    "Source file search" show-titled-minibuffer ;

: show-vocab-search ( listener action -- )
    [ find-listener hide-minibuffer ]
    >r dup listener-gadget-input selected-word r>
    <vocab-search> "Vocabulary search" show-titled-minibuffer ;

: show-module-search ( listener action -- )
    [ find-listener hide-minibuffer ]
    "" swap <module-search>
    "Module search" show-titled-minibuffer ;

: listener-history ( listener -- seq )
    listener-gadget-input interactor-history <reversed> ;

: history-action ( string -- )
    find-listener listener-gadget-input set-editor-text ;

: show-history ( listener -- )
    dup listener-gadget-input editor-text
    [ find-listener hide-minibuffer ]
    pick listener-history <history-search>
    "History search" show-titled-minibuffer ;

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

listener-gadget "popups" {
    {
        "Complete word"
        T{ key-down f f "TAB" }
        [ all-words show-word-search ]
    }
    {
        "Use vocabulary"
        T{ key-down f { C+ } "u" }
        [ show-vocab-search ]
    }
    {
        "History"
        T{ key-down f { C+ } "p" }
        [ show-history ]
    }
    {
        "Help search"
        T{ key-down f { C+ } "h" }
        [ show-help-search ]
    }
    {
        "Run module"
        T{ key-down f { C+ } "m" }
        [ show-module-search ]
    }
    {
        "Edit file"
        T{ key-down f { C+ } "e" }
        [ show-source-file-search ]
    }
    {
        "Hide minibuffer"
        T{ key-down f f "ESCAPE" }
        [ hide-minibuffer ]
    }
} define-commands
