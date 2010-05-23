! Copyright (C) 2005, 2010 Eduardo Cavazos and Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types ascii assocs classes.struct combinators
combinators.short-circuit command-line environment io.encodings.ascii
io.encodings.string io.encodings.utf8 kernel literals locals math
namespaces sequences specialized-arrays.instances.alien.c-types.uchar
strings ui ui.backend ui.clipboards ui.event-loop ui.gadgets
ui.gadgets.private ui.gadgets.worlds ui.gestures ui.pixel-formats
ui.pixel-formats.private ui.private x11 x11.clipboard x11.constants
x11.events x11.glx x11.io x11.windows x11.xim x11.xlib ;
FROM: unix.ffi => system ;
IN: ui.backend.x11

SINGLETON: x11-ui-backend

: XA_NET_WM_NAME ( -- atom ) "_NET_WM_NAME" x-atom ;

TUPLE: x11-handle-base glx ;
TUPLE: x11-handle < x11-handle-base window xic ;
TUPLE: x11-pixmap-handle < x11-handle-base pixmap glx-pixmap ;

C: <x11-handle> x11-handle
C: <x11-pixmap-handle> x11-pixmap-handle

M: world expose-event nip relayout ;

M: world configure-event
    swap [ event-loc >>window-loc ] [ event-dim >>dim ] bi
    ! In case dimensions didn't change
    relayout-1 ;

PIXEL-FORMAT-ATTRIBUTE-TABLE: glx-visual { $ GLX_USE_GL $ GLX_RGBA } H{
    { double-buffered { $ GLX_DOUBLEBUFFER } }
    { stereo { $ GLX_STEREO } }
    { color-bits { $ GLX_BUFFER_SIZE } }
    { red-bits { $ GLX_RED_SIZE } }
    { green-bits { $ GLX_GREEN_SIZE } }
    { blue-bits { $ GLX_BLUE_SIZE } }
    { alpha-bits { $ GLX_ALPHA_SIZE } }
    { accum-red-bits { $ GLX_ACCUM_RED_SIZE } }
    { accum-green-bits { $ GLX_ACCUM_GREEN_SIZE } }
    { accum-blue-bits { $ GLX_ACCUM_BLUE_SIZE } }
    { accum-alpha-bits { $ GLX_ACCUM_ALPHA_SIZE } }
    { depth-bits { $ GLX_DEPTH_SIZE } }
    { stencil-bits { $ GLX_STENCIL_SIZE } }
    { aux-buffers { $ GLX_AUX_BUFFERS } }
    { sample-buffers { $ GLX_SAMPLE_BUFFERS } }
    { samples { $ GLX_SAMPLES } }
}

M: x11-ui-backend (make-pixel-format)
    [ drop dpy get scr get ] dip
    >glx-visual-int-array glXChooseVisual ;

M: x11-ui-backend (free-pixel-format)
    handle>> XFree ;

M: x11-ui-backend (pixel-format-attribute)
    [ dpy get ] 2dip
    [ handle>> ] [ >glx-visual ] bi*
    [ 2drop f ] [
        first
        { int } [ glXGetConfig drop ] with-out-parameters
    ] if-empty ;

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
    state>> modifiers modifier ;

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
    [ event-modifiers ] [ 0 XLookupKeysym key-code ] bi <key-up> ;

M: world key-up-event
    [ key-up-event>gesture ] dip propagate-key-gesture ;

: mouse-event>gesture ( event -- modifiers button loc )
    [ event-modifiers ] [ button>> ] [ event-loc ] tri ;

M: world button-down-event
    [ mouse-event>gesture [ <button-down> ] dip ] dip
    send-button-down ;

M: world button-up-event
    [ mouse-event>gesture [ <button-up> ] dip ] dip
    send-button-up ;

: mouse-event>scroll-direction ( event -- pair )
    button>> {
        { 4 { 0 -1 } }
        { 5 { 0 1 } }
        { 6 { -1 0 } }
        { 7 { 1 0 } }
    } at ;

M: world scroll-event
    [ [ mouse-event>scroll-direction ] [ event-loc ] bi ] dip
    send-scroll ;

M: world enter-event motion-event ;

M: world leave-event 2drop forget-rollover ;

M: world motion-event
    [ event-loc ] dip move-hand fire-motion ;

M: world focus-in-event
    nip [ handle>> xic>> XSetICFocus ] [ focus-world ] bi ;

M: world focus-out-event
    nip [ handle>> xic>> XUnsetICFocus ] [ unfocus-world ] bi ;

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
    target>> XA_UTF8_STRING = utf8 ascii ? encode ;

: set-selection-prop ( evt -- )
    dpy get swap
    [ requestor>> ] keep
    [ property>> ] keep
    [ target>> 8 PropModeReplace ] keep
    [ selection>> clipboard-for-atom contents>> ] keep
    encode-clipboard dup length XChangeProperty drop ;

M: world selection-request-event
    drop dup target>> {
        { [ dup supported-type? ] [ drop dup set-selection-prop send-notify-success ] }
        { [ dup "TARGETS" x-atom = ] [ drop dup set-targets-prop send-notify-success ] }
        { [ dup "TIMESTAMP" x-atom = ] [ drop dup set-timestamp-prop send-notify-success ] }
        [ drop send-notify-failure ]
    } cond ;

M: x11-ui-backend (close-window) ( handle -- )
    [ xic>> XDestroyIC ]
    [ glx>> destroy-glx ]
    [ window>> [ unregister-window ] [ destroy-window ] bi ]
    tri ;

M: world client-event
    swap close-box? [ ungraft ] [ drop ] if ;

: gadget-window ( world -- )
    dup
    [ [ [ window-loc>> ] [ dim>> ] bi ] dip handle>> glx-window ]
    with-world-pixel-format swap
    dup "Factor" create-xic
    <x11-handle>
    [ window>> register-window ] [ >>handle drop ] 2bi ;

: wait-event ( -- event )
    QueuedAfterFlush events-queued 0 > [
        next-event dup
        None XFilterEvent 0 = [ drop wait-event ] unless
    ] [ wait-for-display wait-event ] if ;

M: x11-ui-backend do-events
    wait-event dup XAnyEvent>> window>> window dup
    [ handle-event ] [ 2drop ] if ;

: x-clipboard@ ( gadget clipboard -- prop win )
    atom>> swap
    find-world handle>> window>> ;

M: x-clipboard copy-clipboard
    [ x-clipboard@ own-selection ] keep
    contents<< ;

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

: set-class ( dpy window -- )
    XA_WM_CLASS XA_UTF8_STRING 8 PropModeReplace "Factor"
    utf8 encode dup length XChangeProperty drop ;

M: x11-ui-backend set-title ( string world -- )
    handle>> window>> swap
    [ dpy get ] 2dip [ set-title-old ] [ set-title-new ] 3bi ;

: make-fullscreen-msg ( world ? -- msg )
    XClientMessageEvent <struct>
    ClientMessage >>type
    dpy get >>display
    "_NET_WM_STATE" x-atom >>message_type
    swap _NET_WM_STATE_ADD _NET_WM_STATE_REMOVE ? >>data0
    swap handle>> window>> >>window
    32 >>format
    "_NET_WM_STATE_FULLSCREEN" x-atom >>data1 ;

M: x11-ui-backend (set-fullscreen) ( world ? -- )
    [ dpy get root get 0 SubstructureNotifyMask ] 2dip
    make-fullscreen-msg XSendEvent drop ;

M: x11-ui-backend (open-window) ( world -- )
    dup gadget-window
    handle>> window>>
    [ set-closable ] [ dpy get swap set-class ] [ map-window ] tri ;

M: x11-ui-backend raise-window* ( world -- )
    handle>> [
        dpy get swap window>>
        [ RevertToPointerRoot CurrentTime XSetInputFocus drop ]
        [ XRaiseWindow drop ]
        2bi
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
    dup [ [ dim>> ] [ handle>> ] bi* glx-pixmap ] with-world-pixel-format
    <x11-pixmap-handle> >>handle drop ;

M: x11-ui-backend (close-offscreen-buffer) ( handle -- )
    dpy get swap
    [ glx-pixmap>> glXDestroyGLXPixmap ]
    [ pixmap>> XFreePixmap drop ]
    [ glx>> glXDestroyContext ] 2tri ;

M: x11-ui-backend offscreen-pixels ( world -- alien w h )
    [ [ dim>> ] [ handle>> pixmap>> ] bi pixmap-bits ] [ dim>> first2 ] bi ;

M: x11-ui-backend (with-ui) ( quot -- )
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

<PRIVATE
: escape-' ( string -- string' )
    [ dup CHAR: ' = [ drop "'\\''" ] [ 1string ] if ] { } map-as concat ;

: xmessage ( string -- )
    escape-' "/usr/bin/env xmessage '" "'" surround system drop ;
PRIVATE>

M: x11-ui-backend system-alert
    "\n\n" glue xmessage ;

: black ( -- xcolor ) 0 0 0 0 0 0 XColor <struct-boa> ; inline

M:: x11-ui-backend (grab-input) ( handle -- )
    handle window>>                                                  :> wnd
    dpy get                                                          :> dpy
    dpy wnd uchar-array{ 0 0 0 0 0 0 0 0 } 8 8 XCreateBitmapFromData :> pixmap
    dpy pixmap dup black dup 0 0 XCreatePixmapCursor                 :> cursor

    dpy wnd 1 NoEventMask GrabModeAsync dup wnd cursor CurrentTime XGrabPointer drop

    dpy cursor XFreeCursor drop
    dpy pixmap XFreePixmap drop ;

M: x11-ui-backend (ungrab-input)
    drop dpy get CurrentTime XUngrabPointer drop ;

x11-ui-backend ui-backend set-global

[ "DISPLAY" os-env "ui.tools" "listener" ? ]
main-vocab-hook set-global
