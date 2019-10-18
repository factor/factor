! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: arrays errors gadgets gadgets-labels gadgets-theme
generic assocs io kernel math models namespaces prettyprint
sequences test threads sequences words timers assocs ;

! Assoc mapping aliens to gadgets
SYMBOL: windows

: window ( handle -- world ) windows get-global at ;

: window-focus ( handle -- gadget ) window world-focus ;

: register-window ( world handle -- )
    #! Add the new window just below the topmost window. Why?
    #! So that if the new window doesn't actually receive focus
    #! (eg, we're using focus follows mouse and the mouse is not
    #! in the new window when it appears) Factor doesn't get
    #! confused and send workspace operations to the new window,
    #! etc.
    swap 2array windows get-global push
    windows get-global dup length 1 >
    [ [ length 1- dup 1- ] keep exchange ] [ drop ] if ;

: unregister-window ( handle -- )
    windows get-global
    [ first = not ] subset-with
    windows set-global  ;

: raised-window ( world -- )
    windows get-global [ second eq? ] find-with drop
    windows get-global [ length 1- ] keep exchange ;

! Presentation help bar
: <status-bar> ( model -- gadget )
    [ "" like ] <filter>
    <label-control>
    dup reverse-video-theme
    t over set-gadget-root? ;

DEFER: draw-world ! defined in ui.factor

: open-window ( gadget title -- )
    >r f <model> [ 100 <delay> <status-bar> ] keep r> <world>
    dup pref-dim over set-gadget-dim
    dup open-window*
    dup draw-world ;

: find-window ( quot -- world )
    windows get 1 <column>
    [ world-gadget swap call ] find-last-with nip ; inline

: start-world ( world -- )
    dup graft
    dup relayout
    dup world-title over set-title
    world-gadget request-focus ;

: close-global ( world global -- )
    dup get-global find-world rot eq?
    [ f swap set-global ] [ drop ] if ;

: focus-gestures ( new old -- )
    drop-prefix <reversed>
    T{ lose-focus } swap each-gesture
    T{ gain-focus } swap each-gesture ;

: focus-world ( world -- )
    t over set-world-focused?
    dup raised-window
    focus-path f focus-gestures ;

: unfocus-world ( world -- )
    f over set-world-focused?
    focus-path f swap focus-gestures ;

: reset-world ( world -- )
    dup world-fonts clear-assoc
    dup unfocus-world
    f swap set-world-handle ;

: stop-world ( world -- )
    dup ungraft
    dup hand-clicked close-global
    dup hand-gadget close-global
    dup free-fonts
    reset-world ;

: restore-windows ( -- )
    windows get [ 1 <column> >array ] keep delete-all
    [ dup reset-world open-window* ] each
    forget-rollover ;

: restore-windows? ( -- ? )
    windows get [ empty? not ] [ f ] if* ;
