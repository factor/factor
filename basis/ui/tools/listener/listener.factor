! Copyright (C) 2005, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs calendar combinators
combinators.short-circuit concurrency.flags
concurrency.mailboxes continuations destructors documents
documents.elements fonts fry hashtables help help.markup
help.tips io io.styles kernel lexer listener literals locals
math math.vectors models models.arrow models.delay namespaces
parser prettyprint sequences source-files.errors strings system
threads ui ui.commands ui.gadgets ui.gadgets.editors
ui.gadgets.glass ui.gadgets.labeled ui.gadgets.panes
ui.gadgets.scrollers ui.gadgets.status-bar ui.gadgets.toolbar
ui.gadgets.tracks ui.gestures ui.operations ui.pens.solid
ui.theme ui.tools.browser ui.tools.common ui.tools.debugger
ui.tools.error-list ui.tools.listener.completion
ui.tools.listener.history ui.tools.listener.popups vocabs
vocabs.loader vocabs.parser vocabs.refresh words ;
IN: ui.tools.listener

TUPLE: interactor < source-editor
    output history flag mailbox thread waiting token-model word-model popup ;

INSTANCE: interactor input-stream

: register-self ( interactor -- )
    <mailbox> >>mailbox
    self >>thread
    drop ;

: interactor-continuation ( interactor -- continuation )
    thread>> thread-continuation ;

: interactor-busy? ( interactor -- ? )
    {
        [ waiting>> ]
        [ thread>> dup [ thread-registered? ] when ]
    } 1&& not ;

SLOT: manifest

M: interactor manifest>>
    dup interactor-busy? [ drop f ] [
        interactor-continuation name>>
        manifest swap assoc-stack
    ] if ;

GENERIC: (word-at-caret) ( token completion-mode -- obj )

M: object (word-at-caret) 2drop f ;

M: vocab-completion (word-at-caret)
    drop
    [ dup vocab-exists? [ >vocab-link ] [ drop f ] if ]
    [ 2drop f ] recover ;

M: word-completion (word-at-caret)
    manifest>> [
        '[ _ _ search-manifest ] [ drop f ] recover
    ] [ drop f ] if* ;

M: vocab-word-completion (word-at-caret)
    vocab-name>> lookup-word ;

: word-at-caret ( token interactor -- obj )
    completion-mode (word-at-caret) ;

: <word-model> ( interactor -- model )
    [ token-model>> 1/3 seconds <delay> ]
    [ '[ _ word-at-caret ] ] bi
    <arrow> ;

: <interactor> ( -- gadget )
    interactor new-editor
        <flag> >>flag
        dup one-word-elt <element-model> >>token-model
        dup <word-model> >>word-model
        dup model>> <history> >>history ;

M: interactor graft*
    [ call-next-method ] [ dup word-model>> add-connection ] bi ;

M: interactor ungraft*
    [ dup word-model>> remove-connection ] [ call-next-method ] bi ;

M: interactor model-changed
    2dup word-model>> eq? [
        dup popup>>
        [ 2drop ] [ [ value>> ] dip show-summary ] if
    ] [ call-next-method ] if ;

M: interactor stream-element-type drop +character+ ;

GENERIC: (print-input) ( object -- )

SYMBOL: listener-input-style
H{
    { font-style bold }
    { foreground $ text-color }
} listener-input-style set-global

SYMBOL: listener-word-style
H{
    { font-name "sans-serif" }
    { font-style bold }
    { foreground $ text-color }
} listener-word-style set-global

M: input (print-input)
    dup presented associate [
        string>> listener-input-style get-global format
    ] with-nesting nl ;

M: word (print-input)
    "Command: " listener-word-style get-global format . ;

: print-input ( object interactor -- )
    output>> [ (print-input) ] with-output-stream* ;

: interactor-continue ( obj interactor -- )
    mailbox>> mailbox-put ;

: interactor-finish ( interactor -- )
    [ history>> history-add ] keep
    [ print-input ]
    [ clear-editor drop ]
    [ model>> clear-undo drop ] 2tri ;

: interactor-eof ( interactor -- )
    dup interactor-busy? [
        f over interactor-continue
    ] unless drop ;

: evaluate-input ( interactor -- )
    dup interactor-busy? [ drop ] [
        [ control-value ] keep interactor-continue
    ] if ;

: interactor-yield ( interactor -- obj )
    dup thread>> self eq? [
        {
            [ t >>waiting drop ]
            [ flag>> raise-flag ]
            [ mailbox>> mailbox-get ]
            [ f >>waiting drop ]
        } cleave
    ] [ drop f ] if ;

: interactor-read ( interactor -- lines )
    [ interactor-yield ] [ interactor-finish ] bi ;

M: interactor stream-readln
    interactor-read ?first ;

: (call-listener) ( quot command listener -- )
    input>> dup interactor-busy? [ 3drop ] [
        [ print-input drop ]
        [ nip interactor-continue ]
        3bi
    ] if ;

M:: interactor stream-read-unsafe ( n buf interactor -- count )
    n [ 0 ] [
        drop
        interactor interactor-read dup [ "\n" join ] when
        n short [ head-slice 0 buf copy ] keep
    ] if-zero ;

M: interactor stream-read1
    dup interactor-read {
        { [ dup not ] [ 2drop f ] }
        { [ dup empty? ] [ drop stream-read1 ] }
        { [ dup first empty? ] [ 2drop CHAR: \n ] }
        [ nip first first ]
    } cond ;

M: interactor stream-read-until ( seps stream -- seq sep/f )
    swap '[
        _ interactor-read [
            "\n" join CHAR: \n suffix
            [ _ member? ] dupd find
            [ [ head ] when* ] dip dup not
        ] [ f f f ] if*
    ] [ drop ] produce swap [ concat "" prepend-as ] dip ;

M: interactor dispose drop ;

: go-to-error ( interactor error -- )
    [ line>> 1 - ] [ column>> ] bi 2array
    over set-caret
    mark>caret ;

TUPLE: listener-gadget < tool error-summary output scroller input ;

listener-gadget default-font-size  { 50 58 } n*v set-tool-dim

: listener-streams ( listener -- input output )
    [ input>> ] [ output>> <pane-stream> ] bi ;

: init-input/output ( listener -- listener )
    <interactor>
    [ >>input ] [ pane new-pane t >>scrolls? >>output ] bi
    dup listener-streams >>output drop ;

: error-summary. ( -- )
    error-counts keys [
        H{ { table-gap { 3 3 } } } [
            [ [ [ icon>> write-image ] with-cell ] each ] with-row
        ] tabular-output
        last-element off
        { "Press " { $command tool "common" show-error-list } " to view errors." }
        print-element
    ] unless-empty ;

: <error-summary> ( -- gadget )
    error-list-model get [ drop error-summary. ] <pane-control>
    error-summary-background <solid> >>interior ;

: init-error-summary ( listener -- listener )
    <error-summary> >>error-summary
    dup error-summary>> f track-add ;

: add-listener-area ( listener -- listener )
    dup output>> margins <scroller> >>scroller
    dup scroller>> white-interior 1 track-add ;

: <listener-gadget> ( -- listener )
    vertical listener-gadget new-track with-lines
    add-toolbar
    init-input/output
    add-listener-area
    init-error-summary ;

M: listener-gadget focusable-child*
    input>> dup popup>> or ;

: wait-for-listener ( listener -- )
    input>> flag>> 5 seconds wait-for-flag-timeout ;

: listener-busy? ( listener -- ? )
    input>> interactor-busy? ;

: listener-window* ( -- listener )
    <listener-gadget>
    dup "Listener" open-status-window ;

: listener-window ( -- )
    [ listener-window* drop ] with-ui ;

\ listener-window H{ { +nullary+ t } } define-command

: (get-listener) ( quot -- listener )
    find-window [
        [ raise-window ]
        [
            gadget-child
            [ ]
            [ input>> scroll>caret ]
            [ input>> request-focus ] tri
        ] bi
    ] [ listener-window* ] if* ; inline

: get-listener ( -- listener )
    [ listener-gadget? ] (get-listener) ;

: show-listener ( -- )
    get-listener drop ;

\ show-listener H{ { +nullary+ t } } define-command

: get-ready-listener ( -- listener )
    [
        {
            [ listener-gadget? ]
            [ listener-busy? not ]
        } 1&&
    ] (get-listener) ;

GENERIC: listener-input ( obj -- )

M: input listener-input string>> listener-input ;

M: string listener-input
    get-listener input>>
    [ set-editor-string ] [ request-focus ] bi ;

: call-listener ( quot command -- )
    get-ready-listener '[
        _ _ _ dup wait-for-listener
        [ (call-listener) ] with-ctrl-break
    ] "Listener call" spawn drop ;

M: listener-command invoke-command ( target command -- )
    [ command-quot ] [ nip ] 2bi call-listener ;

M: listener-operation invoke-command ( target command -- )
    [ operation-quot ] [ nip command>> ] 2bi call-listener ;

: eval-listener ( string -- )
    get-listener input>> [ set-editor-string ] keep
    evaluate-input ;

: listener-run-files ( seq -- )
    [
        '[ _ [ run-file ] each ]
        \ listener-run-files
        call-listener
    ] unless-empty ;

: com-end ( listener -- )
    input>> interactor-eof ;

: clear-output ( listener -- )
    output>> pane-clear ;

\ clear-output H{ { +listener+ t } } define-command

: clear-stack ( listener -- )
    [ [ clear ] \ clear ] dip (call-listener) ;

: use-if-necessary ( word manifest -- )
    2dup [ vocabulary>> ] dip and [
        manifest [
            [ vocabulary>> use-vocab ]
            [ dup name>> associate use-words ] bi
        ] with-variable
    ] [ 2drop ] if ;

M: word accept-completion-hook
    interactor>> manifest>> use-if-necessary ;

M: object accept-completion-hook 2drop ;

: quot-action ( interactor -- lines )
    [ history>> history-add drop ] [ control-value ] [ select-all ] tri
    parse-lines-interactive ;

: do-recall? ( table error -- ? )
    [ selection>> value>> not ] [ lexer-error? ] bi* and ;

: recall-lexer-error ( interactor error -- )
    over recall-previous go-to-error ;

: make-restart-hook-quot ( error interactor -- quot )
    over '[
        dup hide-glass
        _ do-recall? [ _ _ recall-lexer-error ] when
    ] ;

: frame-debugger ( debugger -- labeled )
    "Error" debugger-color <framed-labeled-gadget> ;

:: <debugger-popup> ( error continuation interactor -- popup )
    error
    continuation
    error compute-restarts
    error interactor make-restart-hook-quot
    <debugger> frame-debugger ;

: debugger-popup ( interactor error continuation -- )
    pick <debugger-popup> one-line-elt swap show-listener-popup ;

: try-parse ( lines -- quot/f )
    [ parse-lines-interactive ] [ nip '[ _ rethrow ] ] recover ;

M: interactor stream-read-quot ( stream -- quot/f )
    dup interactor-yield dup array? [
        over interactor-finish try-parse
        [ ] [ stream-read-quot ] ?if
    ] [ nip ] if ;

: interactor-operation ( gesture interactor -- ? )
    [ token-model>> value>> ] keep word-at-caret
    [ nip ] [ gesture>operation ] 2bi
    [ invoke-command f ] [ drop t ] if* ;

M: interactor handle-gesture
    {
        { [ over key-gesture? not ] [ call-next-method ] }
        { [ dup popup>> ] [ { [ pass-to-popup ] [ call-next-method ] } 2&& ] }
        {
            [ dup token-model>> value>> ]
            [ { [ interactor-operation ] [ call-next-method ] } 2&& ]
        }
        [ call-next-method ]
    } cond ;

interactor "interactor" f {
    { T{ key-down f f "RET" } evaluate-input }
    { T{ key-down f { C+ } "k" } clear-editor }
} define-command-map

interactor "completion" f {
    { T{ key-down f f "TAB" } code-completion-popup }
    { T{ key-down f { C+ } "p" } recall-previous }
    { T{ key-down f { C+ } "n" } recall-next }
    { T{ key-down f { C+ } "r" } history-completion-popup }
} define-command-map

: introduction. ( -- )
    [
        H{ { font-size $ default-font-size } } [
            { $tip-of-the-day } print-element nl
            { $strong "Press " { $snippet "F1" } " at any time for help." } print-element nl
            version-info print-element
        ] with-style
    ] with-default-style nl nl ;

: listener-thread ( listener -- )
    dup listener-streams [
        [ com-browse ] help-hook set
        '[ [ _ input>> ] 2dip debugger-popup ] error-hook set
        error-summary? off
        introduction.
        listener
        nl
        "The listener has exited. To start it again, click “Restart Listener”." print
    ] with-input-output+error-streams* ;

: start-listener-thread ( listener -- )
    '[
        _
        [ input>> register-self ]
        [ listener-thread ]
        bi
    ] "Listener" spawn drop ;

: restart-listener ( listener -- )
    ! Returns when listener is ready to receive input.
    {
        [ com-end ]
        [ clear-output ]
        [ input>> clear-editor ]
        [ start-listener-thread ]
        [ wait-for-listener ]
    } cleave ;

: com-help ( -- ) "help.home" com-browse ;

\ com-help H{ { +nullary+ t } } define-command

: com-auto-use ( -- )
    auto-use? toggle ;

\ com-auto-use H{ { +nullary+ t } { +listener+ t } } define-command

: com-file-drop ( -- files )
    dropped-files get-global ;

\ com-file-drop H{ { +nullary+ t } { +listener+ t } } define-command

listener-gadget "toolbar" f {
    { f restart-listener }
    { T{ key-down f { A+ } "u" } com-auto-use }
    { T{ key-down f { A+ } "k" } clear-output }
    { T{ key-down f { S+ A+ } "k" } clear-stack }
    { T{ key-down f { C+ } "d" } com-end }
    { T{ key-down f f "F1" } com-help }
} define-command-map

listener-gadget "scrolling"
"The listener's scroller can be scrolled from the keyboard."
{
    { T{ key-down f { A+ } "UP" } com-scroll-up }
    { T{ key-down f { A+ } "DOWN" } com-scroll-down }
    { T{ key-down f { A+ } "PAGE_UP" } com-page-up }
    { T{ key-down f { A+ } "PAGE_DOWN" } com-page-down }
} define-command-map

listener-gadget "multi-touch" f {
    { up-action refresh-all }
} define-command-map

listener-gadget "touchbar" f {
    { f refresh-all }
    { f com-auto-use }
    { f com-help }
} define-command-map

listener-gadget "file-drop" "Files can be drag-and-dropped onto the listener."
{
    { T{ file-drop f f } com-file-drop }
} define-command-map

M: listener-gadget graft*
    [ call-next-method ] [ restart-listener ] bi ;

M: listener-gadget ungraft*
    [ com-end ] [ call-next-method ] bi ;

<PRIVATE

:: make-font-style ( family size -- assoc )
    H{ } clone
        family font-name pick set-at
        size font-size pick set-at ;

PRIVATE>

:: set-listener-font ( family size -- )
    get-listener input>> :> inter
    family size make-font-style
    inter output>> make-span-stream :> ostream
    ostream inter output<<
    inter [
        clone
        family >>name
        size >>size
    ] change-font f >>line-height drop
    ostream output-stream set ;
