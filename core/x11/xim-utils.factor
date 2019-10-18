! Copyright (C) 2007 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: x11
USING: alien arrays byte-arrays errors hashtables io kernel math
namespaces prettyprint sequences strings test threads utf8 ;

SYMBOL: xim

: init-xim ( classname -- )
    dpy get f rot dup XOpenIM
    [ "XOpenIM() failed" throw ] unless* xim set-global ;

: close-xim ( -- )
    xim get-global XCloseIM drop f xim set-global ;

: with-xim ( quot -- )
    >r "Factor" init-xim r> [ close-xim ] cleanup ;

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
    buf-size <byte-array> keybuf set
    0 <KeySym> keysym set ;

: finish-lookup ( len -- string keysym )
    keybuf get swap head decode-utf8 >string
    keysym get *KeySym ;

: lookup-string ( event xic -- string keysym )
    [
        prepare-lookup
        swap keybuf get buf-size keysym get 0 <int>
        Xutf8LookupString
        finish-lookup
    ] with-scope ;
