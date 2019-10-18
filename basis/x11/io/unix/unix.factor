! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.backend.unix io.backend.unix.multiplexers
namespaces system x11 x11.xlib x11.io
accessors threads sequences kernel ;
IN: x11.io.unix

SYMBOL: dpy-fd

M: unix init-x-io dpy get XConnectionNumber <fd> dpy-fd set-global ;

M: unix wait-for-display dpy-fd get +input+ wait-for-fd ;

M: unix awaken-event-loop
    dpy-fd get [ fd>> mx get remove-input-callbacks [ resume ] each ] when* ;