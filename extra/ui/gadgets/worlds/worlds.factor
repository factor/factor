! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs continuations kernel math models
namespaces opengl sequences io combinators math.vectors
ui.gadgets ui.gestures ui.render ui.backend inspector ;
IN: ui.gadgets.worlds

TUPLE: world
active? focused?
glass
title status
fonts handle
loc ;

: find-world [ world? ] find-parent ;

M: f world-status ;

: show-status ( string/f gadget -- )
    find-world world-status [ set-model ] [ drop ] if* ;

: show-summary ( object gadget -- )
    >r [ summary ] [ "" ] if* r> show-status ;

: hide-status ( gadget -- ) f swap show-status ;

: (request-focus) ( child world ? -- )
    pick gadget-parent pick eq? [
        >r >r dup gadget-parent dup r> r>
        [ (request-focus) ] keep
    ] unless focus-child ;

M: world request-focus-on ( child gadget -- )
    2dup eq?
    [ 2drop ] [ dup world-focused? (request-focus) ] if ;

: <world> ( gadget title status -- world )
    t H{ } clone { 0 0 } {
        set-gadget-delegate
        set-world-title
        set-world-status
        set-world-active?
        set-world-fonts
        set-world-loc
    } world construct
    t over set-gadget-root?
    dup request-focus ;

M: world equal? 2drop f ;

M: world hashcode* drop world hashcode* ;

M: world pref-dim*
    delegate pref-dim* [ >fixnum ] map { 1024 768 } vmin ;

M: world layout*
    dup delegate layout*
    dup world-glass [
        >r dup rect-dim r> set-layout-dim
    ] when* drop ;

M: world focusable-child* gadget-child ;

M: world children-on nip gadget-children ;

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

TUPLE: world-error world ;

: <world-error> ( error world -- error )
    { set-delegate set-world-error-world }
    world-error construct ;

SYMBOL: ui-error-hook

: ui-error ( error -- ) ui-error-hook get call ;

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

: focus-gestures ( new old -- )
    drop-prefix <reversed>
    T{ lose-focus } swap each-gesture
    T{ gain-focus } swap each-gesture ;

M: world graft*
    dup (open-world-window)
    dup world-title over set-title
    request-focus ;
