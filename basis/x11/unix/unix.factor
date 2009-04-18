! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.backend.unix namespaces system x11 x11.xlib ;
IN: x11.unix

SYMBOL: dpy-fd

M: unix init-x-io dpy get XConnectionNumber <fd> dpy-fd set-global ;

M: unix wait-for-display dpy-fd get +input+ wait-for-fd ;