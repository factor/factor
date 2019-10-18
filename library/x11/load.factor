! Copyright (C) 2005, 2006 Eduardo Cavazos
! See http://factorcode.org/license.txt for BSD license.
USING: kernel parser words compiler sequences ;

{
    "/library/x11/xlib.factor"
    "/library/x11/glx.factor"
    "/library/x11/constants.factor"
    "/library/x11/utilities.factor"
    "/library/x11/events.factor"
    "/library/x11/glx-utils.factor"
    "/library/x11/windows.factor"
    "/library/x11/ui.factor"
} [ run-resource ] each

{ "x11" } compile-vocabs