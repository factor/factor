! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays gadgets kernel math namespaces sequences ;
IN: x11

! This code was inspired by McCLIM's Backends/CLX/port.lisp.

: selection-property ( -- n )
    "org.factorcode.Factor.SELECTION" x-atom ;

: convert-selection ( win selection -- n )
    swap >r >r dpy get r> XA_STRING selection-property r>
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
        r> selection-property 1 window-property
    ] if ;

: own-selection ( prop win -- )
    dpy get -rot CurrentTime XSetSelectionOwner drop ;

: clipboard-for-atom ( atom -- clipboard )
    {
        { [ dup XA_PRIMARY = ] [ drop selection get ] }
        { [ dup "CLIPBOARD" x-atom = ] [ drop clipboard get ] }
        { [ t ] [ drop <clipboard> ] }
    } cond ;

: set-selection-prop ( evt -- )
    dpy get swap
    [ XSelectionRequestEvent-requestor ] keep
    [ XSelectionRequestEvent-property ] keep
    >r XA_STRING 8 PropModeReplace r>
    XSelectionRequestEvent-selection
    clipboard-for-atom x-clipboard-contents
    dup length XChangeProperty drop ;

: set-targets-prop ( evt -- )
    dpy get swap
    [ XSelectionRequestEvent-requestor ] keep
    XSelectionRequestEvent-property
    "TARGETS" x-atom 32 PropModeReplace
    { "STRING" "TARGETS" "TIMESTAMP" } [ x-atom ] map >int-array
    32 XChangeProperty drop ;

: set-timestamp-prop ( evt -- )
    dpy get swap
    [ XSelectionRequestEvent-requestor ] keep
    [ XSelectionRequestEvent-property ] keep
    >r "TIMESTAMP" x-atom 32 PropModeReplace r>
    XSelectionRequestEvent-time 1array >int-array
    32 XChangeProperty drop ;

: send-notify ( evt prop -- )
    "XSelectionEvent" <c-object>
    SelectionNotify over set-XSelectionEvent-type
    [ set-XSelectionRequestEvent-property ] keep
    over XSelectionRequestEvent-requestor over set-XSelectionEvent-requestor
    over XSelectionRequestEvent-selection over set-XSelectionEvent-selection
    over XSelectionRequestEvent-target    over set-XSelectionEvent-target
    over XSelectionRequestEvent-time      over set-XSelectionEvent-time
    >r dpy get swap XSelectionRequestEvent-requestor 0 0 r>
    XSendEvent drop ;

: send-notify-success ( evt -- )
    dup XSelectionEvent-property send-notify ;

: send-notify-failure ( evt -- )
    0 send-notify ;

TUPLE: x-clipboard atom contents ;

C: x-clipboard ( atom -- clipboard )
    [ set-x-clipboard-atom ] keep
    "" over set-x-clipboard-contents ;

: x-clipboard@ ( gadget clipboard -- prop win )
    x-clipboard-atom swap find-world world-handle first ;

M: x-clipboard copy-clipboard ( string gadget clipboard -- )
    [ x-clipboard@ own-selection ] keep
    set-x-clipboard-contents ;

M: x-clipboard paste-clipboard ( gadget clipboard -- )
    >r find-world world-handle first r> x-clipboard-atom
    convert-selection ;

: init-clipboard ( -- )
    XA_PRIMARY <x-clipboard> selection set-global
    "CLIPBOARD" x-atom <x-clipboard> clipboard set-global ;
