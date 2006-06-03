! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: alien kernel math namespaces ;
IN: x11

! This code was inspired by McCLIM's Backends/CLX/port.lisp.

: selection-property ( -- n )
    dpy get "org.factorcode.Factor.SELECTION" f XInternAtom ;

: convert-selection ( win -- n )
    >r dpy get XA_PRIMARY XA_STRING selection-property r>
    CurrentTime XConvertSelection ;

: snarf-property ( length-return prop-return -- string )
    swap *ulong zero? [ drop f ] [ *char* ] if ;

: window-property ( win prop delete? -- string )
    >r >r >r dpy get r> r> 0 -1 r> AnyProperty
    0 <Atom> 0 <int> 0 <ulong> 0 <ulong> f <void*>
    [ XGetWindowProperty drop ] 2keep snarf-property ;

: selection-from-event ( event -- string )
    dup XSelectionEvent-property zero?
    [ drop f ] [ selection-property t window-property ] if ;
