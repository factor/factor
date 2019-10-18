! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: arrays errors gadgets gadgets-labels gadgets-theme
generic hashtables io kernel math models namespaces prettyprint
sequences test threads sequences words timers ;

! Assoc mapping aliens to gadgets
SYMBOL: windows

: window ( handle -- world ) windows get-global assoc ;

: window-focus ( handle -- gadget ) window world-focus ;

: register-window ( world handle -- )
    swap 2array windows get-global push ;

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
    dup reverse-video-theme ;

: open-window ( gadget title -- )
    >r f <model> [ <status-bar> ] keep r> <world>
    dup pref-dim over set-gadget-dim
    dup open-window* draw-world ;

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

: focus-world ( world -- )
    t over set-world-focused?
    dup raised-window
    focused-ancestors f focus-gestures ;

: unfocus-world ( world -- )
    f over set-world-focused?
    focused-ancestors f swap focus-gestures ;

: reset-world ( world -- )
    dup world-fonts clear-hash
    dup unfocus-world
    f over set-world-focus
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
