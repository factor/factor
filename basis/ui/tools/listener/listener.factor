! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: inspector ui.tools.interactor ui.tools.inspector
ui.tools.workspace help.markup io io.styles
kernel models namespaces parser quotations sequences ui.commands
ui.gadgets ui.gadgets.editors ui.gadgets.labelled
ui.gadgets.panes ui.gadgets.buttons ui.gadgets.scrollers
ui.gadgets.tracks ui.gestures ui.operations vocabs words
prettyprint listener debugger threads boxes concurrency.flags
math arrays generic accessors combinators assocs ;
IN: ui.tools.listener

TUPLE: listener-gadget < track input output stack ;

: listener-output, ( listener -- listener )
  <scrolling-pane> >>output
  dup output>> <scroller> "Output" <labelled-gadget> 1 track-add ;

: listener-streams ( listener -- input output )
    [ input>> ] [ output>> <pane-stream> ] bi ;

: <listener-input> ( listener -- gadget )
    output>> <pane-stream> <interactor> ;

: listener-input, ( listener -- listener )
  dup <listener-input> >>input
  dup input>>
    { 0 100 } <limited-scroller>
    "Input" <labelled-gadget>
  f track-add ;

: welcome. ( -- )
   "If this is your first time with Factor, please read the " print
   "handbook" ($link) "." print nl ;

M: listener-gadget focusable-child*
    input>> ;

M: listener-gadget call-tool* ( input listener -- )
    >r string>> r> input>> set-editor-string ;

M: listener-gadget tool-scroller
    output>> find-scroller ;

: wait-for-listener ( listener -- )
    #! Wait for the listener to start.
    input>> flag>> wait-for-flag ;

: workspace-busy? ( workspace -- ? )
    listener>> input>> interactor-busy? ;

: listener-input ( string -- )
    get-workspace listener>> input>> set-editor-string ;

: (call-listener) ( quot listener -- )
    input>> interactor-call ;

: call-listener ( quot -- )
    [ workspace-busy? not ] get-workspace* listener>>
    [ dup wait-for-listener (call-listener) ] 2curry
    "Listener call" spawn drop ;

M: listener-command invoke-command ( target command -- )
    command-quot call-listener ;

M: listener-operation invoke-command ( target command -- )
    [ hook>> call ] keep operation-quot call-listener ;

: eval-listener ( string -- )
    get-workspace
    listener>> input>> [ set-editor-string ] keep
    evaluate-input ;

: listener-run-files ( seq -- )
    [
        [ [ run-file ] each ] curry call-listener
    ] unless-empty ;

: com-end ( listener -- )
    input>> interactor-eof ;

: clear-output ( listener -- )
    output>> pane-clear ;

\ clear-output H{ { +listener+ t } } define-command

: clear-stack ( listener -- )
    [ clear ] swap (call-listener) ;

GENERIC: word-completion-string ( word -- string )

M: word word-completion-string
    name>> ;

M: method-body word-completion-string
    "method-generic" word-prop word-completion-string ;

USE: generic.standard.engines.tuple

M: engine-word word-completion-string
    "engine-generic" word-prop word-completion-string ;

: use-if-necessary ( word seq -- )
    over vocabulary>> [
        2dup assoc-stack pick = [ 2drop ] [
            >r vocabulary>> vocab-words r> push
        ] if
    ] [ 2drop ] if ;

: insert-word ( word -- )
    get-workspace listener>> input>>
    [ >r word-completion-string r> user-input ]
    [ interactor-use use-if-necessary ]
    2bi ;

: quot-action ( interactor -- lines )
    dup control-value
    dup "\n" join pick add-interactor-history
    swap select-all ;

TUPLE: stack-display < track ;

: <stack-display> ( workspace -- gadget )
  listener>>
  { 0 1 } stack-display new-track
    over <toolbar> f track-add
    swap
      stack>> [ [ stack. ] curry try ] t "Data stack" <labelled-pane>
    1 track-add ;

M: stack-display tool-scroller
    find-workspace listener>> tool-scroller ;

: ui-listener-hook ( listener -- )
    >r datastack r> stack>> set-model ;

: ui-error-hook ( error listener -- )
    find-workspace debugger-popup ;

: ui-inspector-hook ( obj listener -- )
    find-workspace inspector-gadget
    swap show-tool inspect-object ;

: listener-thread ( listener -- )
    dup listener-streams [
        [ [ ui-listener-hook ] curry listener-hook set ]
        [ [ ui-error-hook ] curry error-hook set ]
        [ [ ui-inspector-hook ] curry inspector-hook set ] tri
        welcome.
        listener
    ] with-streams* ;

: start-listener-thread ( listener -- )
    [
        [ input>> register-self ] [ listener-thread ] bi
    ] curry "Listener" spawn drop ;

: restart-listener ( listener -- )
    #! Returns when listener is ready to receive input.
    {
        [ com-end ]
        [ clear-output ]
        [ input>> clear-input ]
        [ start-listener-thread ]
        [ wait-for-listener ]
    } cleave ;

: init-listener ( listener -- )
    f <model> swap (>>stack) ;

: <listener-gadget> ( -- gadget )
  { 0 1 } listener-gadget new-track
    dup init-listener
    listener-output,
    listener-input, ;
    
: listener-help ( -- ) "ui-listener" help-window ;

\ listener-help H{ { +nullary+ t } } define-command

listener-gadget "toolbar" f {
    { f restart-listener }
    { T{ key-down f f "CLEAR" } clear-output }
    { T{ key-down f { C+ } "CLEAR" } clear-stack }
    { T{ key-down f { C+ } "d" } com-end }
    { T{ key-down f f "F1" } listener-help }
} define-command-map

M: listener-gadget handle-gesture ( gesture gadget -- ? )
    2dup find-workspace workspace-page handle-gesture
    [ call-next-method ] [ 2drop f ] if ;

M: listener-gadget graft*
    [ call-next-method ] [ restart-listener ] bi ;

M: listener-gadget ungraft*
    [ com-end ] [ call-next-method ] bi ;
