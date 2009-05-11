! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs continuations kernel math models
namespaces opengl opengl.textures sequences io combinators
combinators.short-circuit fry math.vectors math.rectangles cache
ui.gadgets ui.gestures ui.render ui.backend ui.gadgets.tracks
ui.pixel-formats destructors literals ;
IN: ui.gadgets.worlds

CONSTANT: default-world-pixel-format-attributes
    { windowed double-buffered T{ depth-bits { value 16 } } }

TUPLE: world < track
    active? focused? grab-input?
    layers
    title status status-owner
    text-handle handle images
    window-loc
    pixel-format-attributes ;

TUPLE: world-attributes
    { world-class initial: world }
    grab-input?
    title
    status
    gadgets
    { pixel-format-attributes initial: $ default-world-pixel-format-attributes } ;

: <world-attributes> ( -- world-attributes )
    world-attributes new ; inline

: find-world ( gadget -- world/f ) [ world? ] find-parent ;

: show-status ( string/f gadget -- )
    dup find-world dup [
        dup status>> [
            [ (>>status-owner) ] [ status>> set-model ] bi
        ] [ 3drop ] if
    ] [ 3drop ] if ;

: hide-status ( gadget -- )
    dup find-world dup [
        [ status-owner>> eq? ] keep
        '[ f _ [ (>>status-owner) ] [ status>> set-model ] 2bi ] when
    ] [ 2drop ] if ;

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

: new-world ( class -- world )
    vertical swap new-track
        t >>root?
        t >>active?
        { 0 0 } >>window-loc
        f >>grab-input? ;

: apply-world-attributes ( world attributes -- world )
    {
        [ title>> >>title ]
        [ status>> >>status ]
        [ pixel-format-attributes>> >>pixel-format-attributes ]
        [ grab-input?>> >>grab-input? ]
        [ gadgets>> [ 1 track-add ] each ]
    } cleave ;

: <world> ( world-attributes -- world )
    [ world-class>> new-world ] keep apply-world-attributes
    dup request-focus ;

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

SYMBOL: flush-layout-cache-hook

flush-layout-cache-hook [ [ ] ] initialize

GENERIC: begin-world ( world -- )
GENERIC: end-world ( world -- )

GENERIC: resize-world ( world -- )

M: world begin-world
    drop ;
M: world end-world
    drop ;
M: world resize-world
    drop ;

M: world (>>dim)
    [ call-next-method ]
    [
        dup handle>>
        [ select-gl-context resize-world ]
        [ drop ] if*
    ] bi ;

GENERIC: draw-world* ( world -- )

M: world draw-world*
    check-extensions
    {
        [ init-gl ]
        [ draw-gadget ]
        [ text-handle>> [ purge-cache ] when* ]
        [ images>> [ purge-cache ] when* ]
    } cleave ;

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
            [
                dup handle>> [ draw-world* ] with-gl-context
                flush-layout-cache-hook get call( -- )
            ] [
                over <world-error> ui-error
                f >>active? drop
            ] recover
        ] with-variable
    ] [ drop ] if ;

world
action-gestures [
    [ [ { C+ } ] dip f <key-down> ]
    [ '[ _ send-action ] ]
    bi*
] H{ } assoc-map-as
H{
    { T{ button-down f { C+ } 1 } [ drop T{ button-down f f 3 } button-gesture ] }
    { T{ button-down f { A+ } 1 } [ drop T{ button-down f f 2 } button-gesture ] }
    { T{ button-down f { M+ } 1 } [ drop T{ button-down f f 2 } button-gesture ] }
    { T{ button-up f { C+ } 1 } [ drop T{ button-up f f 3 } button-gesture ] }
    { T{ button-up f { A+ } 1 } [ drop T{ button-up f f 2 } button-gesture ] }
    { T{ button-up f { M+ } 1 } [ drop T{ button-up f f 2 } button-gesture ] }
} assoc-union set-gestures

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

M: world world-pixel-format-attributes
    pixel-format-attributes>> ;

M: world check-world-pixel-format
    2drop ;

: with-world-pixel-format ( world quot -- )
    [ dup dup world-pixel-format-attributes <pixel-format> ]
    dip [ 2dup check-world-pixel-format ] prepose with-disposal ; inline

