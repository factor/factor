! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs continuations kernel math models
call namespaces opengl sequences io combinators
combinators.short-circuit fry math.vectors math.rectangles cache
ui.gadgets ui.gestures ui.render ui.text ui.text.private
ui.backend ui.gadgets.tracks ;
IN: ui.gadgets.worlds

TUPLE: world < track
active? focused?
layers
title status
text-handle handle images
window-loc ;

: find-world ( gadget -- world/f ) [ world? ] find-parent ;

: show-status ( string/f gadget -- )
    find-world dup [
        status>> dup [ set-model ] [ 2drop ] if
    ] [ 2drop ] if ;

: hide-status ( gadget -- ) f swap show-status ;

ERROR: no-world-found ;

: find-gl-context ( gadget -- )
    find-world dup
    [ handle>> select-gl-context ] [ no-world-found ] if ;

: (request-focus) ( child world ? -- )
    pick parent>> pick eq? [
        [ dup parent>> dup ] 2dip
        [ (request-focus) ] keep
    ] unless focus-child ;

M: world request-focus-on ( child gadget -- )
    2dup eq?
    [ 2drop ] [ dup focused?>> (request-focus) ] if ;

: new-world ( gadget title status class -- world )
    vertical swap new-track
        t >>root?
        t >>active?
        { 0 0 } >>window-loc
        swap >>status
        swap >>title
        swap 1 track-add
    dup init-text-rendering
    dup request-focus ;

: <world> ( gadget title status -- world )
    world new-world ;

: as-big-as-possible ( world gadget -- )
    dup [ { 0 0 } >>loc over dim>> >>dim ] when 2drop ; inline

M: world layout*
    [ call-next-method ]
    [ dup layers>> [ as-big-as-possible ] with each ] bi ;

M: world focusable-child* gadget-child ;

M: world children-on nip children>> ;

M: world remove-gadget
    2dup layers>> memq?
    [ layers>> delq ] [ call-next-method ] if ;

: (draw-world) ( world -- )
    dup handle>> [
        {
            [ init-gl ]
            [ draw-gadget ]
            [ finish-text-rendering ]
            [ images>> [ purge-cache ] when* ]
        } cleave
    ] with-gl-context ;

: draw-world? ( world -- ? )
    #! We don't draw deactivated worlds, or those with 0 size.
    #! On Windows, the latter case results in GL errors.
    { [ active?>> ] [ handle>> ] [ dim>> [ 0 > ] all? ] } 1&& ;

TUPLE: world-error error world ;

C: <world-error> world-error

SYMBOL: ui-error-hook

: ui-error ( error -- )
    ui-error-hook get [ call( error -- ) ] [ die drop ] if* ;

ui-error-hook [ [ rethrow ] ] initialize

: draw-world ( world -- )
    dup draw-world? [
        dup world [
            [ (draw-world) ] [
                over <world-error> ui-error
                f >>active? drop
            ] recover
        ] with-variable
    ] [ drop ] if ;

world H{
    { T{ key-down f { C+ } "z" } [ undo-action send-action ] }
    { T{ key-down f { C+ } "Z" } [ redo-action send-action ] }
    { T{ key-down f { C+ } "x" } [ cut-action send-action ] }
    { T{ key-down f { C+ } "c" } [ copy-action send-action ] }
    { T{ key-down f { C+ } "v" } [ paste-action send-action ] }
    { T{ key-down f { C+ } "a" } [ select-all-action send-action ] }
    { T{ button-down f { C+ } 1 } [ drop T{ button-down f f 3 } button-gesture ] }
    { T{ button-down f { A+ } 1 } [ drop T{ button-down f f 2 } button-gesture ] }
    { T{ button-down f { M+ } 1 } [ drop T{ button-down f f 2 } button-gesture ] }
    { T{ button-up f { C+ } 1 } [ drop T{ button-up f f 3 } button-gesture ] }
    { T{ button-up f { A+ } 1 } [ drop T{ button-up f f 2 } button-gesture ] }
    { T{ button-up f { M+ } 1 } [ drop T{ button-up f f 2 } button-gesture ] }
} set-gestures

PREDICATE: specific-button-up < button-up #>> ;
PREDICATE: specific-button-down < button-down #>> ;
PREDICATE: specific-drag < drag #>> ;

: generalize-gesture ( gesture -- )
    clone f >># button-gesture ;

M: world handle-gesture ( gesture gadget -- ? )
    2dup call-next-method [
        {
            { [ over specific-button-up? ] [ drop generalize-gesture f ] }
            { [ over specific-button-down? ] [ drop generalize-gesture f ] }
            { [ over specific-drag? ] [ drop generalize-gesture f ] }
            [ 2drop t ]
        } cond
    ] [ 2drop f ] if ;

: close-global ( world global -- )
    [ get-global find-world eq? ] keep '[ f _ set-global ] when ;
