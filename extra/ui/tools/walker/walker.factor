! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs ui.tools.listener ui.tools.traceback
ui.tools.workspace inspector kernel models namespaces
prettyprint quotations sequences threads tools.interpreter
ui.commands ui.gadgets ui.gadgets.labelled ui.gadgets.tracks
ui.gestures ui.gadgets.buttons ui.gadgets.panes
prettyprint.config prettyprint.backend continuations ;
IN: ui.tools.walker

TUPLE: walker model interpreter history ;

: update-stacks ( walker -- )
    dup walker-interpreter interpreter-continuation
    swap walker-model set-model ;

: with-walker ( walker quot -- )
    over >r >r walker-interpreter r> call r>
    update-stacks ; inline

: walker-active? ( walker -- ? )
    walker-interpreter interpreter-continuation >boolean ;

: walker-command ( gadget quot -- )
    over walker-active? [ with-walker ] [ 2drop ] if ; inline

: save-interpreter ( walker -- )
    dup walker-interpreter interpreter-continuation clone
    swap walker-history push ;

: com-step ( walker -- )
    dup save-interpreter [ step ] walker-command ;

: com-into ( walker -- )
    dup save-interpreter [ step-into ] walker-command ;

: com-out ( walker -- )
    dup save-interpreter [ step-out ] walker-command ;

: com-back ( walker -- )
    dup walker-history
    dup empty? [ drop ] [ pop swap call-tool* ] if ;

: reset-walker ( walker -- )
    <interpreter> over set-walker-interpreter
    V{ } clone over set-walker-history
    update-stacks ;

: <walker> ( -- gadget )
    f <model> f f walker construct-boa [
        toolbar,
        g walker-model <traceback-gadget> 1 track,
    ] { 0 1 } build-track
    dup reset-walker ;

M: walker call-tool* ( continuation walker -- )
    [ restore ] with-walker ;

: com-inspect ( walker -- )
    dup walker-active? [
        walker-interpreter interpreter-continuation
        [ inspect ] curry call-listener
    ] [
        drop
    ] if ;

: com-continue ( walker -- )
    #! Reset walker first, in case step-all ends up calling
    #! the walker again.
    dup walker-interpreter swap reset-walker step-all ;

: walker-help "ui-walker" help-window ;

\ walker-help H{ { +nullary+ t } } define-command

walker "toolbar" f {
    { T{ key-down f { A+ } "s" } com-step }
    { T{ key-down f { A+ } "i" } com-into }
    { T{ key-down f { A+ } "o" } com-out }
    { T{ key-down f { A+ } "b" } com-back }
    { T{ key-down f { A+ } "c" } com-continue }
    { T{ key-down f f "F1" } walker-help }
} define-command-map

walker "other" f {
    { T{ key-down f { A+ } "n" } com-inspect }
} define-command-map

[ walker call-tool stop ] break-hook set-global
