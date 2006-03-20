IN: x11
USING: arrays freetype gadgets gadgets-launchpad
gadgets-layouts gadgets-listener hashtables kernel
kernel-internals math namespaces opengl sequences x11 ;

: draw-glx-world ( world -- )
    dup world-handle first2 [ draw-world ] with-glx-context ;

M: world handle-expose-event ( event world -- )
    nip draw-glx-world ;

M: world handle-resize-event ( event world -- )
    >r
    dup XConfigureEvent-width swap XConfigureEvent-height 0
    3array
    r> set-gadget-dim ;

: gadget-window ( world -- window )
    dup rect-dim first2 choose-visual [
        create-window 2dup windows get set-hash dup map-window
    ] keep create-context 2array swap set-world-handle ;

IN: gadgets

: repaint-handle ( handle -- )
    drop ; ! windows get hash draw-glx-world ;

: in-window ( gadget status dim title -- )
    >r <world> r> drop gadget-window ;

IN: shells

: ui ( -- )
    [
        f [
            launchpad-window
            listener-window
            event-loop
        ] with-x
    ] with-freetype ;

IN: kernel

! : default-shell "DISPLAY" getenv empty? "tty" "ui" ? ;
