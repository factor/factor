! Copyright (C) 2005, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs cache colors combinators
combinators.short-circuit concurrency.promises continuations
destructors kernel literals math models namespaces opengl
sequences strings ui.backend ui.gadgets ui.gadgets.tracks
ui.gestures ui.pixel-formats ui.render ;
IN: ui.gadgets.worlds

SYMBOLS:
    close-button
    minimize-button
    maximize-button
    resize-handles
    small-title-bar
    normal-title-bar
    textured-background
    dialog-window ;

CONSTANT: default-world-pixel-format-attributes
    {
        windowed
        double-buffered
    }

CONSTANT: default-world-window-controls
    {
        normal-title-bar
        close-button
        minimize-button
        maximize-button
        resize-handles
    }

TUPLE: world < track
    active? focused? grab-input? fullscreen?
    saved-position
    layers
    title status status-owner
    text-handle handle images
    window-loc
    pixel-format-attributes
    background-color
    promise
    window-controls
    window-resources ;

TUPLE: world-attributes
    { world-class initial: world }
    grab-input?
    { title string initial: "Factor Window" }
    status
    gadgets
    { pixel-format-attributes initial: $ default-world-pixel-format-attributes }
    { window-controls initial: $ default-world-window-controls }
    pref-dim
    { fill initial: 1 }
    { orientation initial: $ vertical } ;

: <world-attributes> ( -- world-attributes )
    world-attributes new ; inline

: find-world ( gadget -- world/f ) [ world? ] find-parent ;

: grab-input ( gadget -- )
    find-world dup grab-input?>>
    [ drop ] [
        t >>grab-input?
        dup focused?>> [ handle>> (grab-input) ] [ drop ] if
    ] if ;

: ungrab-input ( gadget -- )
    find-world dup grab-input?>>
    [
        f >>grab-input?
        dup focused?>> [ handle>> (ungrab-input) ] [ drop ] if
    ] [ drop ] if ;

: show-status ( string/f gadget -- )
    dup find-world dup [
        dup status>> [
            [ status-owner<< ] [ status>> set-model ] bi
        ] [ 3drop ] if
    ] [ 3drop ] if ;

: hide-status ( gadget -- )
    dup find-world dup [
        [ status-owner>> eq? ] keep
        '[ f _ [ status-owner<< ] [ status>> set-model ] 2bi ] when
    ] [ 2drop ] if ;

: window-resource ( resource -- resource )
    dup world get-global window-resources>> push ;

: set-gl-context ( world -- )
    [ world set-global ]
    [ handle>> select-gl-context ] bi ;

: with-gl-context ( world quot -- )
    '[ set-gl-context @ ]
    [ handle>> flush-gl-context gl-error ] bi ; inline

ERROR: no-world-found ;

: find-gl-context ( gadget -- )
    find-world [ set-gl-context ] [ no-world-found ] if* ;

: (request-focus) ( child world ? -- )
    pick parent>> pick eq? [
        [ dup parent>> dup ] 2dip
        [ (request-focus) ] keep
    ] unless focus-child ;

M: world request-focus-on
    2dup eq?
    [ 2drop ] [ dup focused?>> (request-focus) ] if ;

: new-world ( class -- world )
    vertical swap new-track
        t >>root?
        f >>active?
        { 0 0 } >>window-loc
        f >>grab-input?
        V{ } clone >>window-resources
        <promise> >>promise ;

: initial-background-color ( attributes -- color )
    window-controls>> textured-background swap member-eq?
    [ T{ rgba f 0.0 0.0 0.0 0.0 } ]
    [ T{ rgba f 1.0 1.0 1.0 1.0 } ] if ;

GENERIC#: apply-world-attributes 1 ( world attributes -- world )

M: world apply-world-attributes
    {
        [ title>> >>title ]
        [ status>> >>status ]
        [ pixel-format-attributes>> >>pixel-format-attributes ]
        [ window-controls>> >>window-controls ]
        [ initial-background-color >>background-color ]
        [ grab-input?>> >>grab-input? ]
        [ gadgets>> dup sequence? [ [ 1 track-add ] each ] [ 1 track-add ] if ]
        [ pref-dim>> >>pref-dim ]
        [ fill>> >>fill ]
        [ orientation>> >>orientation ]
    } cleave ;

: <world> ( world-attributes -- world )
    [ world-class>> new-world ] keep apply-world-attributes
    dup request-focus ;

: as-big-as-possible ( world gadget -- )
    dup [ { 0 0 } >>loc over dim>> >>dim ] when 2drop ; inline

M: world layout*
    [ call-next-method ]
    [ dup layers>> [ as-big-as-possible ] with each ] bi ;

M: world focusable-child* children>> [ t ] [ first ] if-empty ;

M: world children-on nip children>> ;

M: world remove-gadget
    2dup layers>> member-eq?
    [ layers>> remove-eq! drop ] [ call-next-method ] if ;

SYMBOL: flush-layout-cache-hook

flush-layout-cache-hook [ [ ] ] initialize

GENERIC: begin-world ( world -- )
GENERIC: end-world ( world -- )
GENERIC: resize-world ( world -- )

M: world begin-world drop ;
M: world end-world drop ;
M: world resize-world drop ;

M: world dim<<
    [ call-next-method ]
    [
        dup active?>> [
            dup handle>>
            [ [ set-gl-context ] [ resize-world ] bi ]
            [ drop ] if
        ] [ drop ] if
    ] bi ;

GENERIC: draw-world* ( world -- )

M: world draw-world*
    {
        [ gl-draw-init ]
        [ draw-gadget ]
        [ text-handle>> [ purge-cache ] when* ]
        [ images>> [ purge-cache ] when* ]
    } cleave ;

: draw-world? ( world -- ? )
    ! We don't draw deactivated worlds, or those with 0 size.
    ! On Windows, the latter case results in GL errors.
    { [ active?>> ] [ handle>> ] [ dim>> [ 0 > ] all? ] } 1&& ;

TUPLE: world-error error world ;

C: <world-error> world-error

SYMBOL: ui-error-hook ! ( error -- )

: ui-error ( error -- )
    ui-error-hook get [ call( error -- ) ] [ die drop ] if* ;

ui-error-hook [ [ rethrow ] ] initialize

: draw-world ( world -- )
    dup draw-world? [
        [
            dup [ draw-world* ] with-gl-context
            flush-layout-cache-hook get call( -- )
        ] [
            swap f >>active? <world-error> rethrow
        ] recover
    ] [ drop ] if ;

world
action-gestures [
    [ [ { C+ } ] dip f <key-down> ]
    [ '[ _ send-action ] ]
    bi*
] H{ } assoc-map-as
H{
    { T{ key-down f { S+ } "DELETE" } [ \ cut-action send-action ] }
    { T{ key-down f { S+ } "INSERT" } [ \ paste-action send-action ] }
    { T{ key-down f { C+ } "INSERT" } [ \ copy-action send-action ] }
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

M: world handle-gesture
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
