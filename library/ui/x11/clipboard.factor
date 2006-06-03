! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: alien kernel math namespaces ;
IN: x11

! This code was inspired by McCLIM's Backends/CLX/port.lisp.

: selection-property ( -- n )
    "org.factorcode.Factor.SELECTION" x-atom ;

: convert-selection ( win selection -- n )
    >r >r dpy get r> XA_STRING selection-property r>
    CurrentTime XConvertSelection drop ;

: snarf-property ( prop-return -- string )
    dup *void* [ *char* ] [ drop f ] if ;

: window-property ( win prop delete? -- string )
    >r dpy get -rot 0 -1 r> AnyPropertyType
    0 <Atom> 0 <int> 0 <ulong> 0 <ulong> f <void*>
    [ XGetWindowProperty drop ] keep snarf-property ;

: selection-from-event ( event -- string )
    dup XSelectionEvent-property zero?
    [ drop f ] [ selection-property 1 window-property ] if ;

TUPLE: x-clipboard atom ;

M: x-clipboard paste-clipboard ( gadget clipboard -- )
    >r find-world world-handle first r> clipboard-atom
    convert-selection ;

: init-clipboard ( -- )
    XA_PRIMARY <x-clipboard> selection set-global
    "CLIPBOARD" x-atom <x-clipboard> clipboard set-global ;
