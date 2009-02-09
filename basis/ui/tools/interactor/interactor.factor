! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs combinators continuations documents
hashtables io io.styles kernel math math.order math.vectors
models models.delay namespaces parser lexer prettyprint
quotations sequences strings threads listener classes.tuple
ui.commands ui.gadgets ui.gadgets.editors ui.gadgets.status-bar
ui.gadgets.presentations ui.gadgets.worlds ui.gestures call
definitions calendar concurrency.flags concurrency.mailboxes
ui.tools.workspace accessors sets destructors fry vocabs.parser ;
IN: ui.tools.interactor

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
        [ model>> T{ one-word-elt } elt-string ] keep
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

: clear-input ( interactor -- )
    model>> [ clear-doc ] call( model -- ) ;

: interactor-finish ( interactor -- )
    [ editor-string ] keep
    [ interactor-input. ] 2keep
    [ add-interactor-history ] keep
    clear-input ;

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

: handle-parse-error ( interactor error -- )
    dup lexer-error? [ 2dup go-to-error error>> ] when
    swap find-workspace debugger-popup ;

: try-parse ( lines interactor -- quot/error/f )
    [
        drop parse-lines-interactive
    ] [
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
    { T{ key-down f { C+ } "k" } clear-input }
} define-command-map
