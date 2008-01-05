! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs combinators continuations documents
ui.tools.workspace hashtables io io.styles kernel math
math.vectors models namespaces parser prettyprint quotations
sequences strings threads listener tuples ui.commands ui.gadgets
ui.gadgets.editors ui.gadgets.presentations ui.gadgets.worlds
ui.gestures definitions ;
IN: ui.tools.interactor

TUPLE: interactor
history output
continuation quot busy?
help ;

: interactor-use ( interactor -- seq )
    use swap
    interactor-continuation continuation-name
    assoc-stack ;

: init-caret-help ( interactor -- )
    dup editor-caret 100 <delay> swap set-interactor-help ;

: init-interactor-history ( interactor -- )
    V{ } clone swap set-interactor-history ;

: <interactor> ( output -- gadget )
    <source-editor>
    interactor construct-editor
    tuck set-interactor-output
    dup init-interactor-history
    dup init-caret-help ;

M: interactor graft*
    dup delegate graft*
    dup dup interactor-help add-connection
    f swap set-interactor-busy? ;

M: interactor ungraft*
    dup dup interactor-help remove-connection
    delegate ungraft* ;

: word-at-loc ( loc interactor -- word )
    over [
        [ gadget-model T{ one-word-elt } elt-string ] keep
        interactor-use assoc-stack
    ] [
        2drop f
    ] if ;

M: interactor model-changed
    2dup interactor-help eq? [
        swap model-value over word-at-loc swap show-summary
    ] [
        delegate model-changed
    ] if ;

: write-input ( string input -- )
    <input> presented associate
    [ H{ { font-style bold } } format ] with-nesting ;

: interactor-input. ( string interactor -- )
    interactor-output [
        dup string? [ dup write-input nl ] [ short. ] if
    ] with-stream* ;

: add-interactor-history ( str interactor -- )
    over empty? [ 2drop ] [ interactor-history push-new ] if ;

: interactor-continue ( obj interactor -- )
    t over set-interactor-busy?
    interactor-continuation schedule-thread-with ;

: clear-input ( interactor -- ) gadget-model clear-doc ;

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
        [
            [ control-value ] keep interactor-continue
        ] in-thread
    ] unless drop ;

: interactor-yield ( interactor -- obj )
    f over set-interactor-busy?
    [ set-interactor-continuation stop ] curry callcc1 ;

M: interactor stream-readln
    [ interactor-yield ] keep interactor-finish first ;

: interactor-call ( quot interactor -- )
    dup interactor-busy? [
        2dup interactor-input.
        2dup interactor-continue
    ] unless 2drop ;

M: interactor stream-read
    swap dup zero? [
        2drop ""
    ] [
        >r stream-readln dup length r> min head
    ] if ;

M: interactor stream-read-partial
    stream-read ;

: go-to-error ( interactor error -- )
    dup parse-error-line 1- swap parse-error-col 2array
    over set-caret
    mark>caret ;

: handle-parse-error ( interactor error -- )
    dup parse-error? [ 2dup go-to-error delegate ] when
    swap find-workspace debugger-popup ;

: try-parse ( lines interactor -- quot/error/f )
    [
        drop parse-lines-interactive
    ] [
        >r f swap set-interactor-busy? drop r>
        dup delegate unexpected-eof? [ drop f ] when
    ] recover ;

: handle-interactive ( lines interactor -- quot/f ? )
    tuck try-parse {
        { [ dup quotation? ] [ nip t ] }
        { [ dup not ] [ drop "\n" swap user-input f f ] }
        { [ t ] [ handle-parse-error f f ] }
    } cond ;

M: interactor stream-read-quot
    [ interactor-yield ] keep {
        { [ over not ] [ drop ] }
        { [ over callable? ] [ drop ] }
        { [ t ] [
            [ handle-interactive ] keep swap
            [ interactor-finish ] [ nip stream-read-quot ] if
        ] }
    } cond ;

M: interactor pref-dim*
    0 over line-height 4 * 2array swap delegate pref-dim* vmax ;

interactor "interactor" f {
    { T{ key-down f f "RET" } evaluate-input }
    { T{ key-down f { C+ } "k" } clear-input }
} define-command-map
