! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs calendar combinators locals
source-files.errors colors.constants combinators.short-circuit
compiler.units help.tips concurrency.flags concurrency.mailboxes
continuations destructors documents documents.elements fry hashtables
help help.markup io io.styles kernel lexer listener math models sets
models.delay models.arrow namespaces parser prettyprint quotations
sequences strings threads vocabs vocabs.refresh vocabs.loader
vocabs.parser words debugger ui ui.commands ui.pens.solid ui.gadgets
ui.gadgets.glass ui.gadgets.buttons ui.gadgets.editors
ui.gadgets.labeled ui.gadgets.panes ui.gadgets.scrollers
ui.gadgets.status-bar ui.gadgets.tracks ui.gadgets.borders ui.gestures
ui.operations ui.tools.browser ui.tools.common ui.tools.debugger
ui.tools.listener.completion ui.tools.listener.popups
ui.tools.listener.history ui.images ui.tools.error-list
tools.errors.model ;
FROM: source-files.errors => all-errors ;
FROM: namespaces => set ;
IN: ui.tools.listener

! If waiting is t, we're waiting for user input, and invoking
! evaluate-input resumes the thread.
TUPLE: interactor < source-editor
output history flag mailbox thread waiting token-model word-model popup ;

: register-self ( interactor -- )
    <mailbox> >>mailbox
    self >>thread
    drop ;

: interactor-continuation ( interactor -- continuation )
    thread>> continuation>> value>> ;

: interactor-busy? ( interactor -- ? )
    #! We're busy if there's no thread to resume.
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

: vocab-exists? ( name -- ? )
    '[ _ { [ vocab ] [ find-vocab-root ] } 1|| ] [ drop f ] recover ;

GENERIC: (word-at-caret) ( token completion-mode -- obj )

M: vocab-completion (word-at-caret)
    drop dup vocab-exists? [ >vocab-link ] [ drop f ] if ;

M: word-completion (word-at-caret)
    manifest>> dup [
        '[ _ _ search-manifest ] [ drop f ] recover
    ] [ 2drop f ] if ;

M: char-completion (word-at-caret)
    2drop f ;

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

M: input (print-input)
    dup presented associate
    [ string>> H{ { font-style bold } } format ] with-nesting nl ;

M: word (print-input)
    "Command: "
    [
        "sans-serif" font-name set
        bold font-style set
    ] H{ } make-assoc format . ;

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
    interactor-read dup [ first ] when ;

: (call-listener) ( quot command listener -- )
    input>> dup interactor-busy? [ 3drop ] [
        [ print-input drop ]
        [ nip interactor-continue ]
        3bi
    ] if ;

M: interactor stream-read
    swap [
        drop ""
    ] [
        [ interactor-read dup [ "\n" join ] when ] dip short head
    ] if-zero ;

M: interactor stream-read-partial
    stream-read ;

M: interactor stream-read1
    dup interactor-read {
        { [ dup not ] [ 2drop f ] }
        { [ dup empty? ] [ drop stream-read1 ] }
        { [ dup first empty? ] [ 2drop CHAR: \n ] }
        [ nip first first ]
    } cond ;

M: interactor dispose drop ;

: go-to-error ( interactor error -- )
    [ line>> 1 - ] [ column>> ] bi 2array
    over set-caret
    mark>caret ;

TUPLE: listener-gadget < tool error-summary output scroller input ;

{ 600 700 } listener-gadget set-tool-dim

: find-listener ( gadget -- listener )
    [ listener-gadget? ] find-parent ;

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
        { "Press " { $command tool "common" show-error-list } " to view errors." }
        print-element
    ] unless-empty ;

: <error-summary> ( -- gadget )
    error-list-model get [ drop error-summary. ] <pane-control>
        COLOR: light-yellow <solid> >>interior ;

: init-error-summary ( listener -- listener )
    <error-summary> >>error-summary
    dup error-summary>> f track-add ;

: <listener-gadget> ( -- listener )
    vertical listener-gadget new-track
        add-toolbar
        init-input/output
        dup output>> <scroller> >>scroller
        dup scroller>> 1 track-add
        init-error-summary ;

M: listener-gadget focusable-child*
    input>> dup popup>> or ;

: wait-for-listener ( listener -- )
    #! Wait for the listener to start.
    input>> flag>> wait-for-flag ;

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
    get-ready-listener
    '[ _ _ _ dup wait-for-listener (call-listener) ]
    "Listener call" spawn drop ;

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
    [ parse-lines ] with-compilation-unit ;

: <debugger-popup> ( error continuation -- popup )
    over compute-restarts [ hide-glass ] <debugger> "Error" <labeled-gadget> ;

: debugger-popup ( interactor error continuation -- )
    [ one-line-elt ] 2dip <debugger-popup> show-listener-popup ;

: handle-parse-error ( interactor error -- )
    dup lexer-error? [ 2dup go-to-error error>> ] when
    error-continuation get
    debugger-popup ;

: try-parse ( lines interactor -- quot/error/f )
    [ drop parse-lines-interactive ] [
        2nip
        dup lexer-error? [
            dup error>> unexpected-eof? [ drop f ] when
        ] when
    ] recover ;

: handle-interactive ( lines interactor -- quot/f ? )
    [ nip ] [ try-parse ] 2bi {
        { [ dup quotation? ] [ nip t ] }
        { [ dup not ] [ drop "\n" swap user-input* drop f f ] }
        [ handle-parse-error f f ]
    } cond ;

M: interactor stream-read-quot
    [ interactor-yield ] keep {
        { [ over not ] [ drop ] }
        { [ over callable? ] [ drop ] }
        [
            [ handle-interactive ] keep swap
            [ interactor-finish ] [ nip stream-read-quot ] if
        ]
    } cond ;

: interactor-operation ( gesture interactor -- ? )
    [ token-model>> value>> ] keep word-at-caret
    [ nip ] [ gesture>operation ] 2bi
    dup [ invoke-command f ] [ 2drop t ] if ;

M: interactor handle-gesture
    {
        { [ over key-gesture? not ] [ call-next-method ] }
        { [ dup popup>> ] [ { [ pass-to-popup ] [ call-next-method ] } 2&& ] }
        { [ dup token-model>> value>> ] [ { [ interactor-operation ] [ call-next-method ] } 2&& ] }
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
    tip-of-the-day. nl
    { $strong "Press " { $snippet "F1" } " at any time for help." } print-content nl nl ;

: listener-thread ( listener -- )
    dup listener-streams [
        [ com-browse ] help-hook set
        '[ [ _ input>> ] 2dip debugger-popup ] error-hook set
        error-summary? off
        introduction.
        listener
        nl
        "The listener has exited. To start it again, click “Restart Listener”." print
    ] with-streams* ;

: start-listener-thread ( listener -- )
    '[
        _
        [ input>> register-self ]
        [ listener-thread ]
        bi
    ] "Listener" spawn drop ;

: restart-listener ( listener -- )
    #! Returns when listener is ready to receive input.
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
    auto-use? [ not ] change ;

\ com-auto-use H{ { +nullary+ t } { +listener+ t } } define-command

listener-gadget "toolbar" f {
    { f restart-listener }
    { T{ key-down f { A+ } "u" } com-auto-use }
    { T{ key-down f { A+ } "k" } clear-output }
    { T{ key-down f { A+ } "K" } clear-stack }
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

M: listener-gadget graft*
    [ call-next-method ] [ restart-listener ] bi ;

M: listener-gadget ungraft*
    [ com-end ] [ call-next-method ] bi ;
