! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: inspector kernel help help.markup io io.styles models math.vectors
strings splitting namespaces parser quotations sequences vocabs words
continuations prettyprint listener debugger threads boxes
concurrency.flags math arrays generic accessors combinators
combinators.short-circuit combinators.smart
assocs fry generic.standard.engines.tuple
tools.vocabs concurrency.mailboxes vocabs.parser calendar
models.delay models.filter documents hashtables sets destructors lexer
ui.commands ui.gadgets ui.gadgets.editors ui.gadgets.labelled
ui.gadgets.panes ui.gadgets.buttons ui.gadgets.scrollers
ui.gadgets.packs ui.gadgets.tracks ui.gadgets.borders
ui.gadgets.frames ui.gadgets.grids ui.gadgets.status-bar
ui.gadgets.viewports ui.gadgets.wrappers ui.gestures ui.operations
ui.tools.browser ui.tools.debugger ui.gadgets.theme
ui.tools.inspector ui.tools.common ui ;
IN: ui.tools.listener

! If waiting is t, we're waiting for user input, and invoking
! evaluate-input resumes the thread.
TUPLE: interactor < source-editor
output history flag mailbox thread waiting help
completion-popup ;

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

: complete-IN:/USE:? ( tokens -- ? )
    2 short tail* { "IN:" "USE:" } intersects? ;

: chop-; ( seq -- seq' )
    { ";" } split1-last [ ] [ ] ?if ;

: complete-USING:? ( tokens -- ? )
    chop-; { "USING:" } intersects? ;

: up-to-caret ( caret document -- string )
    [ { 0 0 } ] 2dip doc-range ;

: vocab-completion? ( interactor -- ? )
    [ editor-caret* ] [ model>> ] bi up-to-caret " \r\n" split
    { [ complete-IN:/USE:? ] [ complete-USING:? ] } 1|| ;

: <word-model> ( interactor -- model )
    [ one-word-elt <element-model> 1/3 seconds <delay> ] keep
    '[
        _ dup vocab-completion?
        [ drop vocab ] [ interactor-use assoc-stack ] if
    ] <filter> ;

: <interactor> ( output -- gadget )
    interactor new-editor
        V{ } clone >>history
        <flag> >>flag
        dup <word-model> >>help
        swap >>output ;

M: interactor graft*
    [ call-next-method ] [ dup help>> add-connection ] bi ;

M: interactor ungraft*
    [ dup help>> remove-connection ] [ call-next-method ] bi ;

M: interactor model-changed
    2dup help>> eq? [
        dup completion-popup>>
        [ 2drop ] [ [ value>> ] dip show-summary ] if
    ] [ call-next-method ] if ;

GENERIC: (print-input) ( object -- )

M: input (print-input)
    dup presented associate
    [ string>> H{ { font-style bold } } format ] with-nesting nl ;

M: object (print-input)
    short. ;

: print-input ( object interactor -- )
    output>> [ (print-input) ] with-output-stream* ;

: add-interactor-history ( input interactor -- )
    over string>> empty? [ 2drop ] [ history>> adjoin ] if ;

: interactor-continue ( obj interactor -- )
    mailbox>> mailbox-put ;

: interactor-finish ( interactor -- )
    [ editor-string <input> ] keep
    [ print-input ]
    [ add-interactor-history ]
    [ clear-editor drop ]
    2tri ;

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

: interactor-call ( quot interactor -- )
    dup interactor-busy? [ 2drop ] [
        [ print-input ] [ interactor-continue ] 2bi
    ] if ;

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

TUPLE: listener-gadget < tool input output scroller popup ;

{ 550 700 } listener-gadget set-tool-dim

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
    [ listener-window* drop ] with-ui ;

\ listener-window H{ { +nullary+ t } } define-command

: (get-listener) ( quot -- listener )
    find-window
    [ [ raise-window ] [ gadget-child dup request-focus ] bi ]
    [ listener-window* ] if* ; inline

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
    [ [ editor-string <input> ] keep add-interactor-history ]
    [ control-value ]
    [ select-all ]
    tri ;

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

listener-gadget "multi-touch" f {
    { T{ up-action } refresh-all }
} define-command-map

listener-gadget "other" f {
    { T{ key-down f f "ESC" } hide-popup }
} define-command-map

M: listener-gadget graft*
    [ call-next-method ] [ restart-listener ] bi ;

M: listener-gadget ungraft*
    [ com-end ] [ call-next-method ] bi ;

! Foo
USING: summary ui.gadgets.labels ui.gadgets.tables colors ui.render
ui.gadgets.worlds ui.gadgets.glass tools.completion ui.gadgets
present ;
USE: tools.completion

: <summary-gadget> ( model -- gadget )
    [ summary ] <filter> <label-control> ;

TUPLE: completion-popup < wrapper table interactor element ;

: find-completion-popup ( gadget -- popup )
    [ completion-popup? ] find-parent ;

SINGLETON: completion-renderer
M: completion-renderer row-columns drop present 1array ;
M: completion-renderer row-value drop ;

: <completion-model> ( editor quot -- model )
    [ one-word-elt <element-model> 1/3 seconds <delay> ] dip
    '[ @ keys 1000 short head ] <filter> ;

M: completion-popup hide-glass-hook
    interactor>> f >>completion-popup request-focus ;

: hide-completion-popup ( popup -- )
    find-world hide-glass ;

: completion-loc/doc ( popup -- loc doc )
    interactor>> [ editor-caret* ] [ model>> ] bi ;

: accept-completion ( item table -- )
    find-completion-popup
    [ [ present ] [ completion-loc/doc ] bi* one-word-elt set-elt-string ]
    [ hide-completion-popup ]
    bi ;

: <completion-table> ( interactor quot -- table )
    <completion-model> <table>
        monospace-font >>font
        t >>selection-required?
        completion-renderer >>renderer
        dup '[ _ accept-completion ] >>action ;

: <completion-scroller> ( object -- object )
    <limited-scroller>
        { 300 120 } >>min-dim
        { 300 120 } >>max-dim ;

: <completion-popup> ( interactor quot -- popup )
    [ completion-popup new-gadget ] 2dip
    [ drop >>interactor ] [ <completion-table> >>table ] 2bi
    dup table>> <completion-scroller> add-gadget
    white <solid> >>interior ;

completion-popup H{
    { T{ key-down f f "ESC" } [ hide-completion-popup ] }
    { T{ key-down f f "TAB" } [ table>> row-action ] }
    { T{ key-down f f " " } [ table>> row-action ] }
} set-gestures

CONSTANT: completion-popup-offset { -4 0 }

: (completion-popup-loc) ( interactor element -- loc )
    [ drop screen-loc ] [
        [ [ [ editor-caret* ] [ model>> ] bi ] dip prev-elt ] [ drop ] 2bi
        loc>point
    ] 2bi v+ completion-popup-offset v+ ;

: completion-popup-loc-1 ( interactor element -- loc )
    [ (completion-popup-loc) ] [ drop caret-dim ] 2bi v+ ;

: completion-popup-loc-2 ( interactor element popup -- loc )
    [ (completion-popup-loc) ] dip pref-dim { 0 1 } v* v- ;

: completion-popup-fits? ( interactor element popup -- ? )
    [ [ completion-popup-loc-1 ] dip pref-dim v+ ]
    [ 2drop find-world dim>> ]
    3bi [ second ] bi@ <= ;

: completion-popup-loc ( interactor element popup -- loc )
    3dup completion-popup-fits?
    [ drop completion-popup-loc-1 ]
    [ completion-popup-loc-2 ]
    if ;

: show-completion-popup ( interactor quot element -- )
    [ nip ] [ drop <completion-popup> ] 3bi
    [ nip >>completion-popup drop ]
    [ [ 2drop find-world ] [ 2nip ] [ completion-popup-loc ] 3tri ] 3bi
    show-glass ;

: word-completion-popup ( interactor -- )
    dup vocab-completion?
    [ vocabs-matching ] [ words-matching ] ? '[ [ { } ] _ if-empty ]
    one-word-elt show-completion-popup ;

: history-matching ( interactor -- alist )
    history>>
    [ dup string>> { { CHAR: \n CHAR: \s } } substitute ] { } map>assoc
    <reversed> ;

: history-completion-popup ( interactor -- )
    dup '[ drop _ history-matching ] one-line-elt show-completion-popup ;

: pass-to-popup? ( gesture interactor -- ? )
    [ [ key-down? ] [ key-up? ] bi or ]
    [ completion-popup>> ]
    bi* and ;

M: interactor handle-gesture
    2dup pass-to-popup? [
        2dup completion-popup>>
        focusable-child resend-gesture
        [ call-next-method ] [ 2drop f ] if
    ] [ call-next-method ] if ;

: selected-word ( editor -- word )
    dup completion-popup>> [
        [ table>> selected-row drop ] [ hide-completion-popup ] bi
    ] [
        selected-token dup search [ ] [ no-word ] ?if
    ] ?if ;

interactor "completion" f {
    { T{ key-down f f "TAB" } word-completion-popup }
    { T{ key-down f { C+ } "p" } history-completion-popup }
} define-command-map