! Copyright (C) 2005, 2010 Eduardo Cavazos, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.data classes.struct fry kernel literals math
math.vectors namespaces sequences x11 x11.X x11.events x11.glx
x11.xlib ;
IN: x11.windows

CONSTANT: create-window-mask
    flags{ CWBackPixel CWBorderPixel CWColormap CWEventMask }

: create-colormap ( visinfo -- colormap )
    [ dpy get root get ] dip visual>> AllocNone
    XCreateColormap ;

CONSTANT: event-mask
    flags{
        ExposureMask
        StructureNotifyMask
        KeyPressMask
        KeyReleaseMask
        ButtonPressMask
        ButtonReleaseMask
        PointerMotionMask
        FocusChangeMask
        EnterWindowMask
        LeaveWindowMask
        PropertyChangeMask
    }

: window-attributes ( visinfo -- attributes )
    XSetWindowAttributes new
    0 >>background_pixel
    0 >>border_pixel
    event-mask >>event_mask
    swap create-colormap >>colormap ;

: set-size-hints ( window -- )
    XSizeHints new
    USPosition >>flags
    [ dpy get ] 2dip XSetWMNormalHints ;

: auto-position ( window loc -- )
    { 0 0 } = [ drop ] [ set-size-hints ] if ;

: >xy ( pair -- x y ) first2 [ >integer ] bi@ ;

: create-window ( loc dim visinfo -- window )
    pick [
        [ [ [ dpy get root get ] dip >xy ] dip { 1 1 } vmax >xy 0 ] dip
        [ depth>> InputOutput ] keep
        [ visual>> create-window-mask ] keep
        window-attributes XCreateWindow
        dup
    ] dip auto-position ;

: glx-window ( loc dim visual -- window glx )
    [ create-window ] [ create-glx ] bi ;

: create-pixmap ( dim visual -- pixmap )
    [ [ { 0 0 } swap ] dip create-window ] [
        drop [ dpy get ] 2dip first2 24 XCreatePixmap
        [ "Failed to create offscreen pixmap" throw ] unless*
    ] 2bi ;

: (create-glx-pixmap) ( pixmap visual -- pixmap glx-pixmap )
    [ drop ] [
        [ dpy get ] 2dip swap glXCreateGLXPixmap
        [ "Failed to create offscreen GLXPixmap" throw ] unless*
    ] 2bi ;

: create-glx-pixmap ( dim visual -- pixmap glx-pixmap )
    [ create-pixmap ] [ (create-glx-pixmap) ] bi ;

: glx-pixmap ( dim visual -- glx pixmap glx-pixmap )
    [ nip create-glx ] [ create-glx-pixmap ] 2bi ;

: destroy-window ( win -- )
    dpy get swap XDestroyWindow drop ;

: set-closable ( win -- )
    dpy get swap XA_WM_DELETE_WINDOW Atom <ref> 1
    XSetWMProtocols drop ;

: map-window ( win -- ) dpy get swap XMapWindow drop ;

: unmap-window ( win -- ) dpy get swap XUnmapWindow drop ;

: pixmap-bits ( dim pixmap -- alien )
    swap first2 '[ dpy get _ 0 0 _ _ AllPlanes ZPixmap XGetImage ] call
    [ XImage-pixels ] [ XDestroyImage drop ] bi ;
