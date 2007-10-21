! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs combinators continuations documents
ui.tools.workspace hashtables io io.styles kernel math
math.vectors models namespaces parser prettyprint quotations
sequences strings threads listener tuples ui.commands
ui.gadgets ui.gadgets.controls ui.gadgets.editors
ui.gadgets.presentations ui.gadgets.worlds ui.gestures ;
IN: ui.tools.interactor

TUPLE: interactor
history output
continuation quot busy?
vars
help ;

: interactor-use ( interactor -- seq )
    use swap interactor-vars at ;

: word-at-loc ( loc interactor -- word )
    over [
        [ control-model T{ one-word-elt } elt-string ] keep
        interactor-use assoc-stack
    ] [
        2drop f
    ] if ;

TUPLE: caret-help model gadget ;

: <caret-help> ( interactor -- caret-help )
    [ editor-caret 100 <delay> ] keep caret-help construct-boa
    dup dup caret-help-model add-connection ;

M: caret-help model-changed
    dup caret-help-gadget
    swap caret-help-model model-value over word-at-loc
    swap show-summary ;

: init-caret-help ( interactor -- )
    dup <caret-help> swap set-interactor-help ;

: init-interactor-history ( interactor -- )
    V{ } clone swap set-interactor-history ;

: <interactor> ( output -- gadget )
    <source-editor>
    { set-interactor-output set-gadget-delegate }
    interactor construct
    dup dup set-control-self
    dup init-interactor-history
    dup init-caret-help ;

M: interactor graft*
    dup delegate graft*
    dup interactor-help caret-help-model activate-model
    f swap set-interactor-busy? ;

M: interactor ungraft*
    dup interactor-help caret-help-model deactivate-model
    delegate ungraft* ;

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

: interactor-finish ( obj interactor -- )
    [ editor-string ] keep
    [ interactor-input. ] 2keep
    [ add-interactor-history ] keep
    dup control-model clear-doc
    interactor-continue ;

: interactor-eval ( interactor -- )
    [
        [ editor-string ] keep dup interactor-quot call
    ] in-thread drop ;

: interactor-eof ( interactor -- )
    f swap interactor-continue ;

: evaluate-input ( interactor -- )
    dup interactor-busy? [ drop ] [ interactor-eval ] if ;

: interactor-yield ( interactor quot -- obj )
    over set-interactor-quot
    f over set-interactor-busy?
    [ set-interactor-continuation stop ] curry callcc1 ;

M: interactor stream-readln
    [ interactor-finish ] interactor-yield ;

: interactor-call ( quot interactor -- )
    2dup interactor-input. interactor-continue ;

M: interactor stream-read
    swap dup zero? [
        2drop ""
    ] [
        >r stream-readln dup length r> min head
    ] if ;

M: interactor stream-read-partial
    stream-read ;

: save-vars ( interactor -- )
    { use in stdio lexer-factory } [ dup get ] H{ } map>assoc
    swap set-interactor-vars ;

: restore-vars ( interactor -- )
    namespace swap interactor-vars update ;

: go-to-error ( interactor error -- )
    dup parse-error-line 1- swap parse-error-col 2array
    over [ control-model validate-loc ] keep
    editor-caret set-model
    mark>caret ;

: handle-parse-error ( interactor error -- )
    dup parse-error? [ 2dup go-to-error delegate ] when
    swap find-workspace debugger-popup ;

: try-parse ( str interactor -- quot/error/f )
    [
        [
            [ restore-vars parse ] keep save-vars
        ] [
            >r f swap set-interactor-busy? drop r>
            dup delegate unexpected-eof? [ drop f ] when
        ] recover
    ] with-scope ;

: handle-interactive ( str/f interactor -- )
    tuck try-parse {
        { [ dup quotation? ] [ swap interactor-finish ] }
        { [ dup not ] [ drop "\n" swap user-input ] }
        { [ t ] [ handle-parse-error ] }
    } cond ;

M: interactor parse-interactive
    [ save-vars ] keep
    [ [ handle-interactive ] interactor-yield ] keep
    restore-vars ;

M: interactor pref-dim*
    0 over line-height 4 * 2array swap delegate pref-dim* vmax ;

: clear-input control-model clear-doc ;

interactor "interactor" f {
    { T{ key-down f f "RET" } evaluate-input }
    { T{ key-down f { C+ } "k" } clear-input }
} define-command-map
