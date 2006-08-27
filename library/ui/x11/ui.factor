! Copyright (C) 2005, 2006 Eduardo Cavazos and Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: x11
USING: arrays errors freetype gadgets
gadgets-listener hashtables kernel kernel-internals math
namespaces opengl sequences strings ;

! In the X11 backend, world-handle is a pair { window context }.
! The window is an X11 window ID, and the context is a
! GLX context pointer.

M: world expose-event nip relayout ;

: configured-loc ( event -- dim )
    dup XConfigureEvent-x swap XConfigureEvent-y 2array ;

: configured-dim ( event -- dim )
    dup XConfigureEvent-width swap XConfigureEvent-height 2array ;

M: world configure-event
    over configured-loc over set-world-loc
    swap configured-dim swap set-gadget-dim ;

: button&loc ( event -- button# loc )
    dup XButtonEvent-button
    over XButtonEvent-x
    rot XButtonEvent-y 2array ;

M: world button-down-event
    >r button&loc r> send-button-down ;

M: world button-up-event
    >r button&loc r> send-button-up ;

M: world wheel-event
    >r button&loc >r 4 = r> r> send-wheel ;

M: world enter-event motion-event ;

M: world leave-event 2drop forget-rollover ;

M: world motion-event
    >r dup XMotionEvent-x swap XMotionEvent-y 2array r>
    move-hand fire-motion ;

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
        { HEX: FF0D "RETURN"    }
        { HEX: FF8D "ENTER"     }
        { HEX: FF1B "ESCAPE"    }
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

: ignored-key? ( keycode -- ? )
    {
        HEX: FFE1 HEX: FFE2 HEX: FFE3 HEX: FFE4 HEX: FFE5
        HEX: FFE6 HEX: FFE7 HEX: FFE8 HEX: FFE9 HEX: FFEA
        HEX: FFEB HEX: FFEC HEX: FFED HEX: FFEE
    } member? ;

: key-code ( event -- keycode )
    lookup-string drop dup ignored-key? [
        drop f
    ] [
        dup key-codes hash [ ] [ ch>string ] ?if
    ] if ;

: event>gesture ( event quot -- gesture )
    >r dup XKeyEvent-state modifiers modifier swap key-code
    r> [ drop f ] if* ; inline

M: world key-down-event
    world-focus over [ <key-down> ] event>gesture [
        over handle-gesture
        [ swap lookup-string nip swap user-input ] [ 2drop ] if
    ] [
        2drop
    ] if* ;

M: world key-up-event
    world-focus swap [ <key-up> ] event>gesture dup
    [ swap handle-gesture drop ] [ 2drop ] if ;

M: world focus-in-event nip focus-world ;

M: world focus-out-event nip unfocus-world ;

M: world selection-notify-event
    [ world-handle first selection-from-event ] keep
    world-focus user-input ;

: supported-type? ( atom -- ? )
    { "STRING" "UTF8_STRING" "TEXT" }
    [ x-atom = ] contains-with? ;

M: world selection-request-event
    drop dup XSelectionRequestEvent-target {
        { [ dup supported-type? ] [ drop dup set-selection-prop send-notify-success ] }
        { [ dup "TARGETS" x-atom = ] [ drop dup set-targets-prop send-notify-success ] }
        { [ dup "TIMESTAMP" x-atom = ] [ drop dup set-timestamp-prop send-notify-success ] }
        { [ t ] [ drop send-notify-failure ] }
    } cond ;

: close-box? ( event -- ? )
    dup XClientMessageEvent-message_type "WM_PROTOCOLS" x-atom =
    swap XClientMessageEvent-data0 "WM_DELETE_WINDOW" x-atom =
    and ;

M: world client-event
    swap close-box? [
        dup world-handle
        >r close-world
        r> first2 destroy-window*
    ] [
        drop
    ] if ;

: gadget-window ( world -- )
    [
        dup world-loc over rect-dim glx-window >r
        [ register-window ] keep r> 2array
    ] keep set-world-handle ;

: event-loop ( -- )
    windows get empty? [
        [ do-events ] ui-try event-loop
    ] unless ;

IN: gadgets

: set-title ( string world -- )
    world-handle first dpy get -rot swap XStoreName drop ;

: open-window* ( world -- )
    dup gadget-window
    dup start-world
    world-handle first dup set-closable map-window ;

: raise-window ( world -- )
    dpy get swap world-handle first XRaiseWindow drop ;

: select-gl-context ( handle -- )
    dpy get swap first2 glXMakeCurrent
    [ "Failed to set current GLX context" throw ] unless ;

: flush-gl-context ( handle -- )
    dpy get swap first glXSwapBuffers ;

IN: shells

: ui ( -- )
    [
        f [
            init-timers
            init-clipboard
            restore-windows? [
                restore-windows
            ] [
                init-ui
                workspace-window
                drop
            ] if
            event-loop
        ] with-x
    ] with-freetype ;

IN: command-line

: default-shell "DISPLAY" os-env empty? "tty" "ui" ? ;
