! Copyright (C) 2005, 2006 Eduardo Cavazos and Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: x11
USING: alien arrays errors gadgets hashtables io kernel math
namespaces prettyprint sequences strings threads ;

GENERIC: expose-event ( event window -- )

GENERIC: resize-event ( event window -- )

GENERIC: button-down-event ( event window -- )

GENERIC: button-up-event ( event window -- )

GENERIC: wheel-event ( event window -- )

GENERIC: motion-event ( event window -- )

GENERIC: key-down-event ( event window -- )

GENERIC: key-up-event ( event window -- )

GENERIC: client-event ( event window -- )

: next-event ( -- event )
    dpy get "XEvent" <c-object> dup >r XNextEvent drop r> ;

: mask-event ( mask -- event )
    >r dpy get r> "XEvent" <c-object> dup >r XMaskEvent drop r> ;

: events-queued ( mode -- n ) >r dpy get r> XEventsQueued ;

: next-event ( -- event )
    dpy get "XEvent" <c-object> dup >r XNextEvent drop r> ;

: wait-event ( -- event )
    QueuedAfterFlush events-queued 0 >
    [ next-event ] [ ui-step wait-event ] if ;

: wheel? ( event -- ? ) XButtonEvent-button { 4 5 } member? ;

: button-down-event$ ( event window -- )
    over wheel? [ wheel-event ] [ button-down-event ] if ;

: button-up-event$ ( event window -- )
    over wheel? [ 2drop ] [ button-up-event ] if ;

: handle-event ( event window -- )
    over XAnyEvent-type {
        { [ dup Expose = ] [ drop expose-event ] }
        { [ dup ConfigureNotify = ] [ drop resize-event ] }
        { [ dup ButtonPress = ] [ drop button-down-event$ ] }
        { [ dup ButtonRelease = ] [ drop button-up-event$ ] }
        { [ dup MotionNotify = ] [ drop motion-event ] }
        { [ dup KeyPress = ] [ drop key-down-event ] }
        { [ dup KeyRelease = ] [ drop key-up-event ] }
        { [ dup ClientMessage = ] [ drop client-event ] }
        { [ t ] [ 3drop ] }
    } cond ;

: event-loop ( -- )
    windows get hash-empty? [
        wait-event dup XAnyEvent-window windows get hash dup
        [ handle-event ] [ 2drop ] if event-loop
    ] unless ;

: char-array>string ( n <char-array> -- string )
    swap >string [ swap char-nth ] map-with ;

: buf-size 100 ;

: lookup-string ( event -- keysym string )
    buf-size "char" <c-array> [
        buf-size 0 <KeySym>
        [ f XLookupString ] keep
        *KeySym swap
    ] keep char-array>string ;
