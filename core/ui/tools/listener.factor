! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-listener
USING: arrays compiler gadgets gadgets-labels gadgets-panes
gadgets-scrolling gadgets-text gadgets-theme gadgets-tracks
gadgets-buttons gadgets-workspace gadgets-interactor generic
hashtables tools io kernel listener math models namespaces
parser prettyprint sequences shells strings styles threads words
definitions help errors quotations operations ;

TUPLE: listener-gadget input output stack ;

: listener-output, ( -- )
    <scrolling-pane> g-> set-listener-gadget-output
    <scroller> "Output" <labelled-gadget> 1 track, ;

: listener-stream ( listener -- stream )
    dup listener-gadget-input
    swap listener-gadget-output <pane-stream>
    <duplex-stream> ;

: <listener-input> ( listener -- gadget )
    listener-gadget-output <pane-stream> <interactor> ;

: listener-input, ( -- )
    g <listener-input> g-> set-listener-gadget-input
    <scroller> "Input" <labelled-gadget> f track, ;

: welcome. ( -- )
    "If this is your first time with the Factor UI," print
    "please read " write
    "ui-tools" ($link) " and " write
    "ui-listener" ($link) "." print nl
    "If you are completely new to Factor, start with the " print
    "tutorial" ($link) "." print nl ;

: init-listener ( listener -- )
    f <model> swap set-listener-gadget-stack ;

C: listener-gadget ( -- gadget )
    dup init-listener
    [ listener-output, listener-input, ] { 0 1 } build-track ;

M: listener-gadget focusable-child*
    listener-gadget-input ;

M: listener-gadget call-tool* ( input listener -- )
    >r input-string r> listener-gadget-input set-editor-string ;

M: listener-gadget tool-scroller
    listener-gadget-output find-scroller ;

: workspace-busy? ( workspace -- ? )
    workspace-listener listener-gadget-input interactor-busy? ;

: get-listener ( -- listener )
    [ workspace-busy? not ] get-workspace* workspace-listener ;

: listener-input ( string -- )
    get-listener listener-gadget-input set-editor-string ;

: (call-listener) ( quot listener -- )
    listener-gadget-input interactor-call ;

: call-listener ( quot -- )
    get-listener (call-listener) ;

: ?in-listener ( quot command -- )
    in-listener? [ call-listener ] [ call ] if ;

M: word invoke-command ( target command -- )
    [ command-quot ] keep ?in-listener ;

M: operation invoke-command ( target command -- )
    [ operation-hook call ] keep
    [
        swap literalize ,
        dup operation-translator %
        dup operation-command ,
    ] [ ] make swap ?in-listener ;

: eval-listener ( string -- )
    get-listener
    listener-gadget-input [ set-editor-string ] keep
    evaluate-input ;

: listener-run-files ( seq -- )
    dup empty? [
        drop
    ] [
        [ run-files recompile ] curry call-listener
    ] if ;

: com-EOF ( listener -- )
    listener-gadget-input interactor-eof ;

: clear-output ( listener -- )
    [ listener-gadget-output [ pane-clear ] curry ] keep
    (call-listener) ;

: clear-stack ( listener -- )
    [ clear ] swap (call-listener) ;

: word-completion-string ( word listener -- string )
    >r dup word-name swap word-vocabulary dup vocab r>
    listener-gadget-input interactor-use memq?
    [ drop ] [ [ "USE: " % % " " % % ] "" make ] if ;

: insert-word ( word -- )
    get-listener [ word-completion-string ] keep
    listener-gadget-input user-input ;

: quot-action ( interactor -- quot )
    dup editor-string swap
    2dup add-interactor-history
    select-all ;
