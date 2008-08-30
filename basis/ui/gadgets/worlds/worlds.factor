! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs continuations kernel math models
namespaces opengl sequences io combinators math.vectors
ui.gadgets ui.gestures ui.render ui.backend ui.gadgets.tracks
debugger math.geometry.rect ;
IN: ui.gadgets.worlds

TUPLE: world < track
active? focused?
glass
title status
fonts handle
window-loc ;

: find-world ( gadget -- world ) [ world? ] find-parent ;

M: f world-status ;

: show-status ( string/f gadget -- )
    find-world world-status [ set-model ] [ drop ] if* ;

: hide-status ( gadget -- ) f swap show-status ;

: (request-focus) ( child world ? -- )
    pick parent>> pick eq? [
        >r >r dup parent>> dup r> r>
        [ (request-focus) ] keep
    ] unless focus-child ;

M: world request-focus-on ( child gadget -- )
    2dup eq?
    [ 2drop ] [ dup world-focused? (request-focus) ] if ;

: <world> ( gadget title status -- world )
    { 0 1 } world new-track
        t >>root?
        t >>active?
        H{ } clone >>fonts
        { 0 0 } >>window-loc
        swap >>status
        swap >>title
        swap 1 track-add
    dup request-focus ;

M: world layout*
    dup call-next-method
    dup world-glass [
        >r dup rect-dim r> (>>dim)
    ] when* drop ;

M: world focusable-child* gadget-child ;

M: world children-on nip children>> ;

: (draw-world) ( world -- )
    dup world-handle [
        [ dup init-gl ] keep draw-gadget
    ] with-gl-context ;

: draw-world? ( world -- ? )
    #! We don't draw deactivated worlds, or those with 0 size.
    #! On Windows, the latter case results in GL errors.
    dup world-active?
    over world-handle
    rot rect-dim [ 0 > ] all? and and ;

TUPLE: world-error error world ;

C: <world-error> world-error

SYMBOL: ui-error-hook

: ui-error ( error -- )
    ui-error-hook get [ call ] [ print-error ] if* ;

[ rethrow ] ui-error-hook set-global

: draw-world ( world -- )
    dup draw-world? [
        dup world [
            [
                (draw-world)
            ] [
                over <world-error> ui-error
                f swap set-world-active?
            ] recover
        ] with-variable
    ] [
        drop
    ] if ;

world H{
    { T{ key-down f { C+ } "x" } [ T{ cut-action } send-action ] }
    { T{ key-down f { C+ } "c" } [ T{ copy-action } send-action ] }
    { T{ key-down f { C+ } "v" } [ T{ paste-action } send-action ] }
    { T{ key-down f { C+ } "a" } [ T{ select-all-action } send-action ] }
    { T{ button-down f { C+ } 1 } [ T{ button-down f f 3 } swap resend-button-down ] }
    { T{ button-down f { A+ } 1 } [ T{ button-down f f 2 } swap resend-button-down ] }
    { T{ button-up f { C+ } 1 } [ T{ button-up f f 3 } swap resend-button-up ] }
    { T{ button-up f { A+ } 1 } [ T{ button-up f f 2 } swap resend-button-up ] }
} set-gestures

: close-global ( world global -- )
    dup get-global find-world rot eq?
    [ f swap set-global ] [ drop ] if ;
