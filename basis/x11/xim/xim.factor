! Copyright (C) 2007, 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.strings arrays byte-arrays
hashtables io io.encodings.string kernel math namespaces
sequences strings continuations x11 x11.xlib specialized-arrays.uint
accessors io.encodings.utf16n ;
IN: x11.xim

SYMBOL: xim

: (init-xim) ( classname medifier -- im )
    XSetLocaleModifiers [ "XSetLocaleModifiers() failed" throw ] unless
    [ dpy get f ] dip dup XOpenIM ;

: init-xim ( classname -- )
    dup "" (init-xim)
    [ nip ]
    [ "@im=none" (init-xim) [ "XOpenIM() failed" throw ] unless* ] if*
    xim set-global ;

: close-xim ( -- )
    xim get-global XCloseIM drop f xim set-global ;

: with-xim ( quot -- )
    [ "Factor" init-xim ] dip [ close-xim ] [ ] cleanup ; inline

: create-xic ( window classname -- xic )
    [
        [ xim get-global XNClientWindow ] dip
        XNFocusWindow over
        XNInputStyle XIMPreeditNothing XIMStatusNothing bitor
        XNResourceName
    ] dip
    XNResourceClass over 0 XCreateIC
    [ "XCreateIC() failed" throw ] unless* ;

CONSTANT: buf-size 100

SYMBOL: keybuf
SYMBOL: keysym

: prepare-lookup ( -- )
    buf-size <uint-array> keybuf set
    0 <KeySym> keysym set ;

: finish-lookup ( len -- string keysym )
    keybuf get swap 2 * head utf16n decode
    keysym get *KeySym ;

: lookup-string ( event xic -- string keysym )
    [
        prepare-lookup
        swap keybuf get buf-size keysym get 0 <int>
        XwcLookupString
        finish-lookup
    ] with-scope ;
