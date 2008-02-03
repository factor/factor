! Copyright (C) 2007 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types arrays byte-arrays hashtables
io kernel math namespaces sequences strings
continuations x11.xlib ;
IN: x11.xim

SYMBOL: xim

: init-xim ( classname -- )
    dpy get f rot dup XOpenIM
    [ "XOpenIM() failed" throw ] unless* xim set-global ;

: close-xim ( -- )
    xim get-global XCloseIM drop f xim set-global ;

: with-xim ( quot -- )
    >r "Factor" init-xim r> [ close-xim ] [ ] cleanup ;

: create-xic ( window classname -- xic )
    >r >r xim get-global
    XNClientWindow r>
    XNFocusWindow over
    XNInputStyle XIMPreeditNothing XIMStatusNothing bitor
    XNResourceName r>
    XNResourceClass over 0 XCreateIC
    [ "XCreateIC() failed" throw ] unless* ;

: buf-size 100 ;

SYMBOL: keybuf
SYMBOL: keysym

: prepare-lookup ( -- )
    buf-size "ulong" <c-array> keybuf set
    0 <KeySym> keysym set ;

: finish-lookup ( len -- string keysym )
    keybuf get swap c-ulong-array> >string
    keysym get *KeySym ;

: lookup-string ( event xic -- string keysym )
    [
        prepare-lookup
        swap keybuf get buf-size keysym get 0 <int>
        XwcLookupString
        finish-lookup
    ] with-scope ;
