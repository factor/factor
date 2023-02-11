! Copyright (C) 2010 Niklas Waern.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data combinators kernel namespaces x11
x11.X x11.xinput2.ffi ;
IN: x11.xinput2

: (xi2-available?) ( display -- ? )
    2 0 [ int <ref> ] bi@
    XIQueryVersion
    {
        { BadRequest [ f ] }
        { Success    [ t ] }
        [ "Internal Xlib error." throw ]
    } case ;

: xi2-available? ( -- ? ) dpy get (xi2-available?) ; inline
