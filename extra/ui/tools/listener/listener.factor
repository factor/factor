! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: inspector ui.tools.interactor ui.tools.inspector
ui.tools.workspace help.markup io io.streams.duplex io.styles
kernel models namespaces parser quotations sequences ui.commands
ui.gadgets ui.gadgets.editors ui.gadgets.labelled
ui.gadgets.panes ui.gadgets.buttons ui.gadgets.scrollers
ui.gadgets.tracks ui.gestures ui.operations vocabs words
prettyprint listener debugger threads generator ;
IN: ui.tools.listener

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
   "cookbook" ($link) "." print nl ;

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

M: listener-command invoke-command ( target command -- )
    command-quot call-listener ;

M: listener-operation invoke-command ( target command -- )
    [ operation-hook call ] keep operation-quot call-listener ;

: eval-listener ( string -- )
    get-listener
    listener-gadget-input [ set-editor-string ] keep
    evaluate-input ;

: listener-run-files ( seq -- )
    dup empty? [
        drop
    ] [
        [ [ [ run-file ] each ] no-parse-hook ] curry
        call-listener
    ] if ;

: com-EOF ( listener -- )
    listener-gadget-input interactor-eof ;

: clear-output ( listener -- )
    [ listener-gadget-output [ pane-clear ] curry ] keep
    (call-listener) ;

: clear-stack ( listener -- )
    [ clear ] swap (call-listener) ;

: word-completion-string ( word listener -- string )
    >r dup word-name swap word-vocabulary dup vocab-words r>
    listener-gadget-input interactor-use memq?
    [ drop ] [ [ "USE: " % % " " % % ] "" make ] if ;

: insert-word ( word -- )
    get-listener [ word-completion-string ] keep
    listener-gadget-input user-input ;

: quot-action ( interactor -- quot )
    dup editor-string swap
    2dup add-interactor-history
    select-all ;

TUPLE: stack-display ;

: <stack-display> ( -- gadget )
    stack-display construct-empty
    g workspace-listener swap [
        dup <toolbar> f track,
        listener-gadget-stack [ stack. ]
        "Data stack" <labelled-pane> 1 track,
    ] { 0 1 } build-track ;

M: stack-display tool-scroller
    find-workspace workspace-listener tool-scroller ;

: ui-listener-hook ( listener -- )
    >r datastack r> listener-gadget-stack set-model ;

: ui-error-hook ( error listener -- )
    find-workspace debugger-popup ;

: ui-inspector-hook ( obj listener -- )
    find-workspace inspector-gadget
    swap show-tool inspect-object ;

: listener-thread ( listener -- )
    dup listener-stream [
        dup [ ui-listener-hook ] curry listener-hook set
        dup [ ui-error-hook ] curry error-hook set
        [ ui-inspector-hook ] curry inspector-hook set
        [ yield ] compiler-hook set
        welcome.
        listener
    ] with-stream* ;

: restart-listener ( listener -- )
    [ >r clear r> init-namespaces listener-thread ] in-thread
    drop ;

: init-listener ( listener -- )
    f <model> swap set-listener-gadget-stack ;

: <listener-gadget> ( -- gadget )
    listener-gadget construct-empty
    dup init-listener
    [ listener-output, listener-input, ] { 0 1 } build-track
    dup restart-listener ;

: listener-help "ui-listener" help-window ;

\ listener-help H{ { +nullary+ t } } define-command

listener-gadget "toolbar" f {
    { f restart-listener }
    { T{ key-down f f "CLEAR" } clear-output }
    { T{ key-down f { C+ } "CLEAR" } clear-stack }
    { T{ key-down f { C+ } "d" } com-EOF }
    { T{ key-down f f "F1" } listener-help }
} define-command-map

M: listener-gadget handle-gesture* ( gadget gesture delegate -- ? )
    3dup drop swap find-workspace workspace-page handle-gesture
    [ default-gesture-handler ] [ 3drop f ] if ;
