! Copyright (C) 2006, 2007 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.strings alien.syntax arrays
kernel math namespaces sequences io.encodings.string
io.encodings.utf8 io.encodings.ascii x11 x11.xlib x11.constants
specialized-arrays.int accessors ;
IN: x11.clipboard

! This code was based on by McCLIM's Backends/CLX/port.lisp
! and http://common-lisp.net/~crhodes/clx/demo/clipboard.lisp.

: XA_CLIPBOARD ( -- atom ) "CLIPBOARD" x-atom ;

: XA_UTF8_STRING ( -- atom ) "UTF8_STRING" x-atom ;

TUPLE: x-clipboard atom contents ;

: <x-clipboard> ( atom -- clipboard )
    "" x-clipboard boa ;

: selection-property ( -- n )
    "org.factorcode.Factor.SELECTION" x-atom ;

: convert-selection ( win selection -- )
    swap [ [ dpy get ] dip XA_UTF8_STRING selection-property ] dip
    CurrentTime XConvertSelection drop ;

: snarf-property ( prop-return -- string )
    dup *void* [ *void* utf8 alien>string ] [ drop f ] if ;

: window-property ( win prop delete? -- string )
    [ [ dpy get ] 2dip 0 -1 ] dip AnyPropertyType
    0 <Atom> 0 <int> 0 <ulong> 0 <ulong> f <void*>
    [ XGetWindowProperty drop ] keep snarf-property ;

: selection-from-event ( event window -- string )
    swap XSelectionEvent-property zero? [
        drop f
    ] [
        selection-property 1 window-property
    ] if ;

: own-selection ( prop win -- )
    [ dpy get ] 2dip CurrentTime XSetSelectionOwner drop
    flush-dpy ;

: set-targets-prop ( evt -- )
    dpy get swap
    [ XSelectionRequestEvent-requestor ] keep
    XSelectionRequestEvent-property
    "TARGETS" x-atom 32 PropModeReplace
    {
        "UTF8_STRING" "STRING" "TARGETS" "TIMESTAMP"
    } [ x-atom ] int-array{ } map-as
    4 XChangeProperty drop ;

: set-timestamp-prop ( evt -- )
    dpy get swap
    [ XSelectionRequestEvent-requestor ] keep
    [ XSelectionRequestEvent-property ] keep
    [ "TIMESTAMP" x-atom 32 PropModeReplace ] dip
    XSelectionRequestEvent-time <int>
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
    [ dpy get swap XSelectionRequestEvent-requestor 0 0 ] dip
    XSendEvent drop
    flush-dpy ;

: send-notify-success ( evt -- )
    dup XSelectionRequestEvent-property send-notify ;

: send-notify-failure ( evt -- )
    0 send-notify ;
