! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: inspector help help.markup io io.styles kernel models
strings namespaces parser quotations sequences vocabs words
continuations prettyprint listener debugger threads boxes
concurrency.flags math arrays generic accessors combinators
assocs fry generic.standard.engines.tuple combinators.short-circuit
tools.vocabs concurrency.mailboxes vocabs.parser calendar
models.delay documents hashtables sets destructors lexer
ui.commands ui.gadgets ui.gadgets.editors ui.gadgets.labelled
ui.gadgets.panes ui.gadgets.buttons ui.gadgets.scrollers
ui.gadgets.packs ui.gadgets.tracks ui.gadgets.borders
ui.gadgets.frames ui.gadgets.grids ui.gadgets.status-bar
ui.gestures ui.operations ui.tools.browser
ui.tools.debugger ui.tools.inspector ui.tools.common ui ;
IN: ui.tools.listener

! If waiting is t, we're waiting for user input, and invoking
! evaluate-input resumes the thread.
TUPLE: interactor < source-editor
output history flag mailbox thread waiting help ;

: register-self ( interactor -- )
    <mailbox> >>mailbox
    self >>thread
    drop ;

: interactor-continuation ( interactor -- continuation )
    thread>> continuation>> value>> ;

: interactor-busy? ( interactor -- ? )
    #! We're busy if there's no thread to resume.
    [ waiting>> ]
    [ thread>> dup [ thread-registered? ] when ]
    bi and not ;

: interactor-use ( interactor -- seq )
    dup interactor-busy? [ drop f ] [
        use swap
        interactor-continuation name>>
        assoc-stack
    ] if ;

: <help-model> ( interactor -- model ) caret>> 1/3 seconds <delay> ;

: <interactor> ( output -- gadget )
    interactor new-editor
        V{ } clone >>history
        <flag> >>flag
        dup <help-model> >>help
        swap >>output ;

M: interactor graft*
    [ call-next-method ] [ dup help>> add-connection ] bi ;

M: interactor ungraft*
    [ dup help>> remove-connection ] [ call-next-method ] bi ;

: word-at-loc ( loc interactor -- word )
    over [
        [ model>> one-word-elt elt-string ] keep
        interactor-use assoc-stack
    ] [
        2drop f
    ] if ;

M: interactor model-changed
    2dup help>> eq? [
        swap value>> over word-at-loc swap show-summary
    ] [
        call-next-method
    ] if ;

: write-input ( string input -- )
    <input> presented associate
    [ H{ { font-style bold } } format ] with-nesting ;

: interactor-input. ( string interactor -- )
    output>> [
        dup string? [ dup write-input nl ] [ short. ] if
    ] with-output-stream* ;

: add-interactor-history ( str interactor -- )
    over empty? [ 2drop ] [ history>> adjoin ] if ;

: interactor-continue ( obj interactor -- )
    mailbox>> mailbox-put ;

: interactor-finish ( interactor -- )
    [ editor-string ] keep
    [ interactor-input. ] 2keep
    [ add-interactor-history ] keep
    clear-editor ;

: interactor-eof ( interactor -- )
    dup interactor-busy? [
        f over interactor-continue
    ] unless drop ;

: evaluate-input ( interactor -- )
    dup interactor-busy? [
        dup control-value over interactor-continue
    ] unless drop ;

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

: interactor-call ( quot interactor -- )
    dup interactor-busy? [
        2dup interactor-input.
        2dup interactor-continue
    ] unless 2drop ;

M: interactor stream-read
    swap dup zero? [
        2drop ""
    ] [
        [ interactor-read dup [ "\n" join ] when ] dip short head
    ] if ;

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
    [ line>> 1- ] [ column>> ] bi 2array
    over set-caret
    mark>caret ;

TUPLE: listener-gadget < track input output scroller popup ;

: find-listener ( gadget -- listener )
    [ listener-gadget? ] find-parent ;

: listener-streams ( listener -- input output )
    [ input>> ] [ output>> ] bi <pane-stream> ;

: <listener-input> ( listener -- gadget )
    output>> <pane-stream> <interactor> ;

: init-listener ( listener -- listener )
    <scrolling-pane> >>output
    dup <listener-input> >>input ;

: <listener-scroller> ( listener -- scroller )
    <frame>
        over output>> @top grid-add
        swap input>> @center grid-add
    <scroller> ;

: <listener-gadget> ( -- gadget )
    { 0 1 } listener-gadget new-track
        add-toolbar
        init-listener
        dup <listener-scroller> >>scroller
        dup scroller>> 1 track-add ;

M: listener-gadget focusable-child*
    [ popup>> ] [ input>> ] bi or ;

: wait-for-listener ( listener -- )
    #! Wait for the listener to start.
    input>> flag>> wait-for-flag ;

: listener-busy? ( listener -- ? )
    input>> interactor-busy? ;

: listener-window* ( -- listener )
    <listener-gadget>
    dup "Listener" open-status-window ;

: listener-window ( -- )
    listener-window* drop ;

: (get-listener) ( quot -- listener )
    find-window
    [ gadget-child ] [ listener-window* ] if* ; inline

: get-listener ( -- listener )
    [ listener-gadget? ] (get-listener) ;

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

: (call-listener) ( quot listener -- )
    input>> interactor-call ;

: call-listener ( quot -- )
    get-ready-listener
    '[ _ _ dup wait-for-listener (call-listener) ]
    "Listener call" spawn drop ;

M: listener-command invoke-command ( target command -- )
    command-quot call-listener ;

M: listener-operation invoke-command ( target command -- )
    [ hook>> call ] keep operation-quot call-listener ;

: eval-listener ( string -- )
    get-listener input>> [ set-editor-string ] keep
    evaluate-input ;

: listener-run-files ( seq -- )
    [
        '[ _ [ run-file ] each ] call-listener
    ] unless-empty ;

: com-end ( listener -- )
    input>> interactor-eof ;

: clear-output ( listener -- )
    output>> pane-clear ;

\ clear-output H{ { +listener+ t } } define-command

: clear-stack ( listener -- )
    [ clear ] swap (call-listener) ;

GENERIC: word-completion-string ( word -- string )

M: word word-completion-string name>> ;

: method-completion-string ( word -- string )
    "method-generic" word-prop word-completion-string ;

M: method-body word-completion-string method-completion-string ;

M: engine-word word-completion-string method-completion-string ;

: use-if-necessary ( word seq -- )
    2dup [ vocabulary>> ] dip and [
        2dup [ assoc-stack ] keep = [ 2drop ] [
            [ vocabulary>> vocab-words ] dip push
        ] if
    ] [ 2drop ] if ;

: insert-word ( word -- )
    get-listener input>>
    [ [ word-completion-string ] dip user-input* drop ]
    [ interactor-use use-if-necessary ]
    2bi ;

: quot-action ( interactor -- lines )
    [ control-value ] keep
    [ [ "\n" join ] dip add-interactor-history ]
    [ select-all ]
    2bi ;

: hide-popup ( listener -- )
    dup popup>> track-remove
    f >>popup
    request-focus ;

: show-popup ( gadget listener -- )
    dup hide-popup
    over >>popup
    over f track-add drop
    request-focus ;

: show-titled-popup ( listener gadget title -- )
    [ find-listener hide-popup ] <closable-gadget>
    swap show-popup ;

: debugger-popup ( error listener -- )
    swap dup compute-restarts
    [ find-listener hide-popup ] <debugger>
    "Error" show-titled-popup ;

: handle-parse-error ( interactor error -- )
    dup lexer-error? [ 2dup go-to-error error>> ] when
    swap find-listener debugger-popup ;

: try-parse ( lines interactor -- quot/error/f )
    [ drop parse-lines-interactive ] [
        2nip
        dup lexer-error? [
            dup error>> unexpected-eof? [ drop f ] when
        ] when
    ] recover ;

: handle-interactive ( lines interactor -- quot/f ? )
    tuck try-parse {
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

interactor "interactor" f {
    { T{ key-down f f "RET" } evaluate-input }
    { T{ key-down f { C+ } "k" } clear-editor }
} define-command-map

: welcome. ( -- )
    "If this is your first time with Factor, please read the " print
    "handbook" ($link) ". To see a list of keyboard shortcuts," print
    "press F1." print nl ;

: listener-thread ( listener -- )
    dup listener-streams [
        [ com-follow ] help-hook set
        '[ _ debugger-popup ] error-hook set
        welcome.
        listener
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

: listener-help ( -- ) "ui-listener" com-follow ;

\ listener-help H{ { +nullary+ t } } define-command

: com-auto-use ( -- )
    auto-use? [ not ] change ;

\ com-auto-use H{ { +nullary+ t } { +listener+ t } } define-command

listener-gadget "misc" "Miscellaneous commands" {
    { T{ key-down f f "F1" } listener-help }
} define-command-map

listener-gadget "toolbar" f {
    { f restart-listener }
    { T{ key-down f { A+ } "u" } com-auto-use }
    { T{ key-down f { A+ } "k" } clear-output }
    { T{ key-down f { A+ } "K" } clear-stack }
    { T{ key-down f { C+ } "d" } com-end }
} define-command-map

listener-gadget "scrolling"
"The listener's scroller can be scrolled from the keyboard."
{
    { T{ key-down f { A+ } "UP" } com-scroll-up }
    { T{ key-down f { A+ } "DOWN" } com-scroll-down }
    { T{ key-down f { A+ } "PAGE_UP" } com-page-up }
    { T{ key-down f { A+ } "PAGE_DOWN" } com-page-down }
} define-command-map

\ refresh-all
H{ { +nullary+ t } { +listener+ t } } define-command

listener-gadget "multi-touch" f {
    { T{ up-action } refresh-all }
} define-command-map

listener-gadget "workflow" f {
    { T{ key-down f f "ESC" } hide-popup }
    { T{ key-down f f "F2" } refresh-all }
} define-command-map

M: listener-gadget graft*
    [ call-next-method ] [ restart-listener ] bi ;

M: listener-gadget ungraft*
    [ com-end ] [ call-next-method ] bi ;

M: listener-gadget pref-dim*
    drop { 550 700 } ;