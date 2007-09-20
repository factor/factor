! Copyright (C) 2006, 2007 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.syntax arrays kernel math
namespaces sequences io.utf8 x11.xlib x11.constants ;
IN: x11.clipboard

! This code was based on by McCLIM's Backends/CLX/port.lisp
! and http://common-lisp.net/~crhodes/clx/demo/clipboard.lisp.

: XA_CLIPBOARD "CLIPBOARD" x-atom ;

: XA_UTF8_STRING "UTF8_STRING" x-atom ;

TUPLE: x-clipboard atom contents ;

: <x-clipboard> ( atom -- clipboard )
    "" x-clipboard construct-boa ;

: selection-property ( -- n )
    "org.factorcode.Factor.SELECTION" x-atom ;

: convert-selection ( win selection -- )
    swap >r >r dpy get r> XA_UTF8_STRING selection-property r>
    CurrentTime XConvertSelection drop ;

: snarf-property ( prop-return -- string )
    dup *void* [ *char* ] [ drop f ] if ;

: window-property ( win prop delete? -- string )
    >r dpy get -rot 0 -1 r> AnyPropertyType
    0 <Atom> 0 <int> 0 <ulong> 0 <ulong> f <void*>
    [ XGetWindowProperty drop ] keep snarf-property ;

: selection-from-event ( event window -- string )
    >r XSelectionEvent-property zero? [
        r> drop f
    ] [
        r> selection-property 1 window-property decode-utf8
    ] if ;

: own-selection ( prop win -- )
    dpy get -rot CurrentTime XSetSelectionOwner drop
    flush-dpy ;

: set-targets-prop ( evt -- )
    dpy get swap
    [ XSelectionRequestEvent-requestor ] keep
    XSelectionRequestEvent-property
    "TARGETS" x-atom 32 PropModeReplace
    {
        "UTF8_STRING" "STRING" "TARGETS" "TIMESTAMP"
    } [ x-atom ] map >c-int-array
    4 XChangeProperty drop ;

: set-timestamp-prop ( evt -- )
    dpy get swap
    [ XSelectionRequestEvent-requestor ] keep
    [ XSelectionRequestEvent-property ] keep
    >r "TIMESTAMP" x-atom 32 PropModeReplace r>
    XSelectionRequestEvent-time 1array >c-int-array
    1 XChangeProperty drop ;

: send-notify ( evt prop -- )
    "XSelectionEvent" <c-object>
    SelectionNotify over set-XSelectionEvent-type
    [ set-XSelectionEvent-property ] keep
    over XSelectionRequestEvent-display   over set-XSelectionEvent-display
    over XSelectionRequestEvent-requestor over set-XSelectionEvent-requestor
    over XSelectionRequestEvent-selection over set-XSelectionEvent-selection
    over XSelectionRequestEvent-target    over set-XSelectionEvent-target
    over XSelectionRequestEvent-time      over set-XSelectionEvent-time
    >r dpy get swap XSelectionRequestEvent-requestor 0 0 r>
    XSendEvent drop
    flush-dpy ;

: send-notify-success ( evt -- )
    dup XSelectionRequestEvent-property send-notify ;

: send-notify-failure ( evt -- )
    0 send-notify ;
