! Copyright (C) 2005, 2007 Eduardo Cavazos and Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays ui ui.gadgets ui.gestures ui.backend
ui.clipboards ui.gadgets.worlds assocs kernel math namespaces
opengl sequences strings x11.xlib x11.events x11.xim x11.glx
x11.clipboard x11.constants x11.windows io.utf8 combinators
debugger system command-line ui.render math.vectors tuples
opengl.gl ;
IN: ui.x11

TUPLE: x11-ui-backend ;

: XA_NET_WM_NAME "_NET_WM_NAME" x-atom ;

TUPLE: x11-handle window glx xic ;

C: <x11-handle> x11-handle

M: world expose-event nip relayout ;

M: world configure-event
    over configured-loc over set-world-loc
    swap configured-dim over set-gadget-dim
    ! In case dimensions didn't change
    relayout-1 ;

: modifiers
    {
        { S+ HEX: 1 }
        { C+ HEX: 4 }
        { A+ HEX: 8 }
    } ;
    
: key-codes
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
    } ;

: key-code ( keysym -- keycode action? )
    dup key-codes at [ t ] [ 1string f ] ?if ;

: event-modifiers ( event -- seq )
    XKeyEvent-state modifiers modifier ;

: key-down-event>gesture ( event world -- string gesture )
    dupd
    world-handle x11-handle-xic lookup-string
    >r swap event-modifiers r> key-code <key-down> ;

M: world key-down-event
    [ key-down-event>gesture ] keep world-focus
    [ send-gesture ] keep swap [ user-input ] [ 2drop ] if ;

: key-up-event>gesture ( event -- gesture )
    dup event-modifiers swap 0 XLookupKeysym key-code <key-up> ;

M: world key-up-event
    >r key-up-event>gesture r> world-focus send-gesture drop ;

: mouse-event>gesture ( event -- modifiers button loc )
    dup event-modifiers over XButtonEvent-button
    rot mouse-event-loc ;

M: world button-down-event
    >r mouse-event>gesture >r <button-down> r> r>
    send-button-down ;

M: world button-up-event
    >r mouse-event>gesture >r <button-up> r> r>
    send-button-up ;

: mouse-event>scroll-direction ( event -- pair )
    XButtonEvent-button {
        { 4 { 0 -1 } }
        { 5 { 0 1 } }
        { 6 { -1 0 } }
        { 7 { 1 0 } }
    } at ;

M: world wheel-event
    >r dup mouse-event>scroll-direction swap mouse-event-loc r>
    send-wheel ;

M: world enter-event motion-event ;

M: world leave-event 2drop forget-rollover ;

M: world motion-event
    >r dup XMotionEvent-x swap XMotionEvent-y 2array r>
    move-hand fire-motion ;

M: world focus-in-event
    nip
    dup world-handle x11-handle-xic XSetICFocus focus-world ;

M: world focus-out-event
    nip
    dup world-handle x11-handle-xic XUnsetICFocus unfocus-world ;

M: world selection-notify-event
    [ world-handle x11-handle-window selection-from-event ] keep
    world-focus user-input ;

: supported-type? ( atom -- ? )
    { "UTF8_STRING" "STRING" "TEXT" }
    [ x-atom = ] curry* contains? ;

: clipboard-for-atom ( atom -- clipboard )
    {
        { [ dup XA_PRIMARY = ] [ drop selection get ] }
        { [ dup XA_CLIPBOARD = ] [ drop clipboard get ] }
        { [ t ] [ drop <clipboard> ] }
    } cond ;

: encode-clipboard ( string type -- bytes )
    XSelectionRequestEvent-target XA_UTF8_STRING =
    [ encode-utf8 ] [ string>char-alien ] if ;

: set-selection-prop ( evt -- )
    dpy get swap
    [ XSelectionRequestEvent-requestor ] keep
    [ XSelectionRequestEvent-property ] keep
    [ XSelectionRequestEvent-target ] keep
    >r 8 PropModeReplace r>
    [
        XSelectionRequestEvent-selection
        clipboard-for-atom x-clipboard-contents
    ] keep encode-clipboard dup length XChangeProperty drop ;

M: world selection-request-event
    drop dup XSelectionRequestEvent-target {
        { [ dup supported-type? ] [ drop dup set-selection-prop send-notify-success ] }
        { [ dup "TARGETS" x-atom = ] [ drop dup set-targets-prop send-notify-success ] }
        { [ dup "TIMESTAMP" x-atom = ] [ drop dup set-timestamp-prop send-notify-success ] }
        { [ t ] [ drop send-notify-failure ] }
    } cond ;

: close-window ( handle -- )
    dup x11-handle-xic XDestroyIC
    dup x11-handle-glx destroy-glx
    x11-handle-window dup unregister-window
    destroy-window ;

M: world client-event
    swap close-box? [
        dup world-handle >r stop-world r> close-window
    ] [
        drop
    ] if ;

: gadget-window ( world -- )
    dup world-loc over rect-dim glx-window
    over "Factor" create-xic <x11-handle>
    2dup x11-handle-window register-window
    swap set-world-handle ;

: wait-event ( -- event )
    QueuedAfterFlush events-queued 0 > [
        next-event dup
        None XFilterEvent zero? [ drop wait-event ] unless
    ] [
        ui-step wait-event
    ] if ;

: do-events ( -- )
    wait-event dup XAnyEvent-window window dup
    [ [ 2dup handle-event ] assert-depth ] when 2drop ;

: event-loop ( -- )
    windows get empty? [
        [ do-events ] ui-try event-loop
    ] unless ;

: x-clipboard@ ( gadget clipboard -- prop win )
    x-clipboard-atom swap
    find-world world-handle x11-handle-window ;

M: x-clipboard copy-clipboard
    [ x-clipboard@ own-selection ] keep
    set-x-clipboard-contents ;

M: x-clipboard paste-clipboard
    >r find-world world-handle x11-handle-window
    r> x-clipboard-atom convert-selection ;

: init-clipboard ( -- )
    XA_PRIMARY <x-clipboard> selection set-global
    XA_CLIPBOARD <x-clipboard> clipboard set-global ;

: set-title-old ( dpy window string -- )
    dup [ 127 <= ] all? [ XStoreName drop ] [ 3drop ] if ;

: set-title-new ( dpy window string -- )
    >r
    XA_NET_WM_NAME XA_UTF8_STRING 8 PropModeReplace
    r> encode-utf8 dup length XChangeProperty drop ;

M: x11-ui-backend set-title ( string world -- )
    world-handle x11-handle-window swap dpy get -rot
    3dup set-title-old set-title-new ;

M: x11-ui-backend (open-world-window) ( world -- )
    dup gadget-window
    dup start-world
    world-handle x11-handle-window dup set-closable map-window ;

M: x11-ui-backend raise-window ( world -- )
    world-handle [
        dpy get swap x11-handle-window XRaiseWindow drop
    ] when* ;

M: x11-ui-backend select-gl-context ( handle -- )
    dpy get swap
    dup x11-handle-window swap x11-handle-glx glXMakeCurrent
    [ "Failed to set current GLX context" throw ] unless ;

M: x11-ui-backend flush-gl-context ( handle -- )
    dpy get swap x11-handle-window glXSwapBuffers ;

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

T{ x11-ui-backend } ui-backend set-global

[ "DISPLAY" os-env "ui" "listener" ? ]
main-vocab-hook set-global
