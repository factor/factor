! Copyright (C) 2006, 2010 Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.strings classes.struct
io.encodings.utf8 kernel namespaces sequences specialized-arrays x11
x11.X x11.xlib ;
SPECIALIZED-ARRAY: int
IN: x11.clipboard

! This code was based on by McCLIM's Backends/CLX/port.lisp
! and https://common-lisp.net/~crhodes/clx/demo/clipboard.lisp.

: XA_CLIPBOARD ( -- atom ) "CLIPBOARD" x-atom ;
: XA_UTF8_STRING ( -- atom ) "UTF8_STRING" x-atom ;
: XA_TARGETS ( -- atom ) "TARGETS" x-atom ;
: XA_TIMESTAMP ( -- atom ) "TIMESTAMP" x-atom ;
: XA_TEXT ( -- atom ) "TEXT" x-atom ;

TUPLE: x-clipboard atom contents ;

: <x-clipboard> ( atom -- clipboard )
    "" x-clipboard boa ;

: selection-property ( -- n )
    "org.factorcode.Factor.SELECTION" x-atom ;

: convert-selection ( win selection -- )
    swap [ [ dpy get ] dip XA_UTF8_STRING selection-property ] dip
    CurrentTime XConvertSelection drop ;

: snarf-property ( prop-return -- string )
    dup void* deref [ void* deref utf8 alien>string ] [ drop f ] if ;

: window-property ( win prop delete? -- string )
    [ [ dpy get ] 2dip 0 -1 ] dip AnyPropertyType
    0 Atom <ref> 0 int <ref> 0 ulong <ref> 0 ulong <ref> f void* <ref>
    [ XGetWindowProperty drop ] keep snarf-property ;

: selection-from-event ( event window -- string )
    swap property>> 0 =
    [ drop f ] [ selection-property 1 window-property ] if ;

: own-selection ( prop win -- )
    [ dpy get ] 2dip CurrentTime XSetSelectionOwner drop
    flush-dpy ;

: set-targets-prop ( evt -- )
    [ dpy get ] dip [ requestor>> ] [ property>> ] bi
    XA_TARGETS 32 PropModeReplace
    XA_UTF8_STRING XA_STRING XA_TARGETS XA_TIMESTAMP int-array{ } 4sequence
    4 XChangeProperty drop ;

: set-timestamp-prop ( evt -- )
    [ dpy get ] dip
    [ requestor>> ]
    [ property>> XA_TIMESTAMP 32 PropModeReplace ]
    [ time>> int <ref> ] tri
    1 XChangeProperty drop ;

: send-notify ( evt prop -- )
    XSelectionEvent new
    SelectionNotify >>type
    swap >>property
    over display>>   >>display
    over requestor>> >>requestor
    over selection>> >>selection
    over target>>    >>target
    over time>>      >>time
    [ [ dpy get ] dip requestor>> 0 0 ] dip
    XSendEvent drop
    flush-dpy ;

: send-notify-success ( evt -- )
    dup property>> send-notify ;

: send-notify-failure ( evt -- )
    0 send-notify ;
