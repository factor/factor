! Copyright (C) 2005, 2008 Eduardo Cavazos and Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types arrays ui ui.gadgets
ui.gestures ui.backend ui.clipboards ui.gadgets.worlds ui.render
ui.event-loop assocs kernel math namespaces opengl sequences
strings x11.xlib x11.events x11.xim x11.glx x11.clipboard
x11.constants x11.windows io.encodings.string io.encodings.ascii
io.encodings.utf8 combinators combinators.short-circuit command-line
math.vectors classes.tuple opengl.gl threads math.geometry.rect
environment ascii ;
IN: ui.x11

SINGLETON: x11-ui-backend

: XA_NET_WM_NAME ( -- atom ) "_NET_WM_NAME" x-atom ;

TUPLE: x11-handle-base glx ;
TUPLE: x11-handle < x11-handle-base xic window ;
TUPLE: x11-pixmap-handle < x11-handle-base pixmap glx-pixmap ;

C: <x11-handle> x11-handle
C: <x11-pixmap-handle> x11-pixmap-handle

M: world expose-event nip relayout ;

M: world configure-event
    over configured-loc >>window-loc
    swap configured-dim >>dim
    ! In case dimensions didn't change
    relayout-1 ;

CONSTANT: modifiers
    {
        { S+ HEX: 1 }
        { C+ HEX: 4 }
        { A+ HEX: 8 }
    }

CONSTANT: key-codes
    H{
        { HEX: FF08 "BACKSPACE" }
        { HEX: FF09 "TAB"       }
        { HEX: FF0D "RET"       }
        { HEX: FF8D "ENTER"     }
        { HEX: FF1B "ESC"       }
        { HEX: FFFF "DELETE"    }
        { HEX: FF50 "HOME"      }
        { HEX: FF51 "LEFT"      }
        { HEX: FF52 "UP"        }
        { HEX: FF53 "RIGHT"     }
        { HEX: FF54 "DOWN"      }
        { HEX: FF55 "PAGE_UP"   }
        { HEX: FF56 "PAGE_DOWN" }
        { HEX: FF57 "END"       }
        { HEX: FF58 "BEGIN"     }
        { HEX: FFBE "F1"        }
        { HEX: FFBF "F2"        }
        { HEX: FFC0 "F3"        }
        { HEX: FFC1 "F4"        }
        { HEX: FFC2 "F5"        }
        { HEX: FFC3 "F6"        }
        { HEX: FFC4 "F7"        }
        { HEX: FFC5 "F8"        }
        { HEX: FFC6 "F9"        }
    }

: key-code ( keysym -- keycode action? )
    dup key-codes at [ t ] [ 1string f ] ?if ;

: event-modifiers ( event -- seq )
    XKeyEvent-state modifiers modifier ;

: valid-input? ( string gesture -- ? )
    over empty? [ 2drop f ] [
        mods>> { f { S+ } } member? [
            [ { [ 127 = not ] [ CHAR: \s >= ] } 1&& ] all?
        ] [
            [ { [ 127 = not ] [ CHAR: \s >= ] [ alpha? not ] } 1&& ] all?
        ] if
    ] if ;

: key-down-event>gesture ( event world -- string gesture )
    dupd
    handle>> xic>> lookup-string
    [ swap event-modifiers ] dip key-code <key-down> ;

M: world key-down-event
    [ key-down-event>gesture ] keep
    [ propagate-key-gesture drop ]
    [ 2over valid-input? [ nip user-input ] [ 3drop ] if ]
    3bi ;

: key-up-event>gesture ( event -- gesture )
    dup event-modifiers swap 0 XLookupKeysym key-code <key-up> ;

M: world key-up-event
    [ key-up-event>gesture ] dip propagate-key-gesture ;

: mouse-event>gesture ( event -- modifiers button loc )
    [ event-modifiers ]
    [ XButtonEvent-button ]
    [ mouse-event-loc ]
    tri ;

M: world button-down-event
    [ mouse-event>gesture [ <button-down> ] dip ] dip
    send-button-down ;

M: world button-up-event
    [ mouse-event>gesture [ <button-up> ] dip ] dip
    send-button-up ;

: mouse-event>scroll-direction ( event -- pair )
    XButtonEvent-button {
        { 4 { 0 -1 } }
        { 5 { 0 1 } }
        { 6 { -1 0 } }
        { 7 { 1 0 } }
    } at ;

M: world wheel-event
    [ [ mouse-event>scroll-direction ] [ mouse-event-loc ] bi ] dip
    send-wheel ;

M: world enter-event motion-event ;

M: world leave-event 2drop forget-rollover ;

M: world motion-event
    [ [ XMotionEvent-x ] [ XMotionEvent-y ] bi 2array ] dip
    move-hand fire-motion ;

M: world focus-in-event
    nip
    dup handle>> xic>> XSetICFocus focus-world ;

M: world focus-out-event
    nip
    dup handle>> xic>> XUnsetICFocus unfocus-world ;

M: world selection-notify-event
    [ handle>> window>> selection-from-event ] keep
    user-input ;

: supported-type? ( atom -- ? )
    { "UTF8_STRING" "STRING" "TEXT" }
    [ x-atom = ] with any? ;

: clipboard-for-atom ( atom -- clipboard )
    {
        { XA_PRIMARY [ selection get ] }
        { XA_CLIPBOARD [ clipboard get ] }
        [ drop <clipboard> ]
    } case ;

: encode-clipboard ( string type -- bytes )
    XSelectionRequestEvent-target
    XA_UTF8_STRING = utf8 ascii ? encode ;

: set-selection-prop ( evt -- )
    dpy get swap
    [ XSelectionRequestEvent-requestor ] keep
    [ XSelectionRequestEvent-property ] keep
    [ XSelectionRequestEvent-target ] keep
    [ 8 PropModeReplace ] dip
    [
        XSelectionRequestEvent-selection
        clipboard-for-atom contents>>
    ] keep encode-clipboard dup length XChangeProperty drop ;

M: world selection-request-event
    drop dup XSelectionRequestEvent-target {
        { [ dup supported-type? ] [ drop dup set-selection-prop send-notify-success ] }
        { [ dup "TARGETS" x-atom = ] [ drop dup set-targets-prop send-notify-success ] }
        { [ dup "TIMESTAMP" x-atom = ] [ drop dup set-timestamp-prop send-notify-success ] }
        [ drop send-notify-failure ]
    } cond ;

M: x11-ui-backend (close-window) ( handle -- )
    dup xic>> XDestroyIC
    dup glx>> destroy-glx
    window>> dup unregister-window
    destroy-window ;

M: world client-event
    swap close-box? [ ungraft ] [ drop ] if ;

: gadget-window ( world -- )
    dup window-loc>> over rect-dim glx-window
    over "Factor" create-xic rot <x11-handle>
    2dup window>> register-window
    >>handle drop ;

: wait-event ( -- event )
    QueuedAfterFlush events-queued 0 > [
        next-event dup
        None XFilterEvent zero? [ drop wait-event ] unless
    ] [
        ui-wait wait-event
    ] if ;

M: x11-ui-backend do-events
    wait-event dup XAnyEvent-window window dup
    [ handle-event ] [ 2drop ] if ;

: x-clipboard@ ( gadget clipboard -- prop win )
    atom>> swap
    find-world handle>> window>> ;

M: x-clipboard copy-clipboard
    [ x-clipboard@ own-selection ] keep
    (>>contents) ;

M: x-clipboard paste-clipboard
    [ find-world handle>> window>> ] dip atom>> convert-selection ;

: init-clipboard ( -- )
    XA_PRIMARY <x-clipboard> selection set-global
    XA_CLIPBOARD <x-clipboard> clipboard set-global ;

: set-title-old ( dpy window string -- )
    dup [ 127 <= ] all? [ XStoreName drop ] [ 3drop ] if ;

: set-title-new ( dpy window string -- )
    [ XA_NET_WM_NAME XA_UTF8_STRING 8 PropModeReplace ] dip
    utf8 encode dup length XChangeProperty drop ;

M: x11-ui-backend set-title ( string world -- )
    handle>> window>> swap
    [ dpy get ] 2dip [ set-title-old ] [ set-title-new ] 3bi ;

M: x11-ui-backend set-fullscreen* ( ? world -- )
    handle>> window>> "XClientMessageEvent" <c-object>
    tuck set-XClientMessageEvent-window
    swap _NET_WM_STATE_ADD _NET_WM_STATE_REMOVE ?
    over set-XClientMessageEvent-data0
    ClientMessage over set-XClientMessageEvent-type
    dpy get over set-XClientMessageEvent-display
    "_NET_WM_STATE" x-atom over set-XClientMessageEvent-message_type
    32 over set-XClientMessageEvent-format
    "_NET_WM_STATE_FULLSCREEN" x-atom over set-XClientMessageEvent-data1
    [ dpy get root get 0 SubstructureNotifyMask ] dip XSendEvent drop ;

M: x11-ui-backend (open-window) ( world -- )
    dup gadget-window
    handle>> window>> dup set-closable map-window ;

M: x11-ui-backend raise-window* ( world -- )
    handle>> [
        dpy get swap window>> XRaiseWindow drop
    ] when* ;

M: x11-handle select-gl-context ( handle -- )
    dpy get swap
    [ window>> ] [ glx>> ] bi glXMakeCurrent
    [ "Failed to set current GLX context" throw ] unless ;

M: x11-handle flush-gl-context ( handle -- )
    dpy get swap window>> glXSwapBuffers ;

M: x11-pixmap-handle select-gl-context ( handle -- )
    dpy get swap
    [ glx-pixmap>> ] [ glx>> ] bi glXMakeCurrent
    [ "Failed to set current GLX context" throw ] unless ;

M: x11-pixmap-handle flush-gl-context ( handle -- )
    drop ;

M: x11-ui-backend (open-offscreen-buffer) ( world -- )
    dup dim>> glx-pixmap <x11-pixmap-handle> >>handle drop ;
M: x11-ui-backend (close-offscreen-buffer) ( handle -- )
    dpy get swap
    [ glx-pixmap>> glXDestroyGLXPixmap ]
    [ pixmap>> XFreePixmap drop ]
    [ glx>> glXDestroyContext ] 2tri ;

M: x11-ui-backend offscreen-pixels ( world -- alien w h )
    [ [ dim>> ] [ handle>> pixmap>> ] bi pixmap-bits ] [ dim>> first2 ] bi ;

M: x11-ui-backend ui ( -- )
    [
        f [
            [
                init-clipboard
                start-ui
                event-loop
            ] with-xim
        ] with-x
    ] ui-running ;

M: x11-ui-backend beep ( -- )
    dpy get 100 XBell drop ;

x11-ui-backend ui-backend set-global

[ "DISPLAY" os-env "ui" "listener" ? ]
main-vocab-hook set-global
