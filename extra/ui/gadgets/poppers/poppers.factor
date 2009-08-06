! Copyright (C) 2009 Sam Anklesaria
! See http://factorcode.org/license.txt for BSD license.
USING: arrays accessors combinators kernel math
models models.combinators namespaces sequences
ui.gadgets ui.gadgets.controls ui.gadgets.layout
ui.gadgets.tracks ui.gestures ui.gadgets.line-support ;
EXCLUDE: ui.gadgets.editors => model-field ;
IN: ui.gadgets.poppers

TUPLE: popped < model-field { fatal? initial: t } ;
TUPLE: popped-editor < multiline-editor ;
: <popped> ( text -- gadget ) <basic> init-field popped-editor popped (new-field) swap >>model* ;

: set-expansion ( popped size -- ) over dup parent>> [ children>> index ] [ sizes>> ] bi set-nth relayout ;
: new-popped ( popped -- ) insertion-point "" <popped>
    [ rot 1 + f (track-add-at) ] keep [ relayout ] [ request-focus ] bi ;
: focus-prev ( popped -- ) dup parent>> children>> length 1 =
    [ drop ] [
        insertion-point [ 1 - dup -1 = [ drop 1 ] when ] [ children>> ] bi* nth
        [ request-focus ] [ editor>> end-of-document ] bi
    ] if ;
: initial-popped ( popper -- ) "" <popped> [ f track-add drop ] keep request-focus ;

TUPLE: popper < track { unfocus-hook initial: [ drop ] } ;
! list of strings is model (make shown objects implement sequence protocol)
: <popper> ( model -- popper ) vertical popper new-track swap >>model ;

M: popped handle-gesture swap {
    { gain-focus [ 1 set-expansion f ] }
    { lose-focus [ dup parent>>
        [ [ unfocus-hook>> call( a -- ) ] curry [ f set-expansion ] bi ]
        [ drop ] if* f
    ] }
    { T{ key-up f f "RET" } [ dup editor>> delete-previous-character new-popped f ] }
    { T{ key-up f f "BACKSPACE" } [ dup editor>> editor-string "" =
        [ dup fatal?>> [ [ focus-prev ] [ unparent ] bi ] [ t >>fatal? drop ] if ]
        [ f >>fatal? drop ] if f
    ] }
    [ swap call-next-method ]
} case ;

M: popper handle-gesture swap T{ button-down f f 1 } =
    [ hand-click# get 2 = [ initial-popped ] [ drop ] if ] [ drop ] if f ;

M: popper model-changed
    [ children>> [ unparent ] each ]
    [ [ value>> [ <popped> ] map ] dip [ f track-add ] reduce request-focus ] bi ;

M: popped pref-dim* editor>> [ pref-dim* first ] [ line-height ] bi 2array ;
M: popper focusable-child* children>> [ t ] [ first ] if-empty ;