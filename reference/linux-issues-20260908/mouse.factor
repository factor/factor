! Run under a private Xvfb display with the GTK2 runtime on LD_LIBRARY_PATH.
USING: accessors alien alien.c-types alien.libraries alien.syntax arrays
continuations game.input game.input.gtk2 game.input.x11 gdk2.ffi
io kernel locals math namespaces sequences system x11 x11.xlib ;
IN: linux-issues.mouse

<< "xtst" "libXtst.so.6" cdecl add-library >>
LIBRARY: xtst
FUNCTION: int XTestFakeButtonEvent ( Display* display, uint button, int pressed, ulong delay )

:: button-event ( button pressed -- )
    dpy get button pressed 0 XTestFakeButtonEvent 0 > t assert=
    dpy get 0 XSync drop ;

:: check-button ( button -- )
    5 f <array> t button 1 - pick set-nth :> expected
    button 1 button-event
    [
        { gtk2-game-input-backend x11-game-input-backend } [
            game-input-backend [ read-mouse buttons>> expected assert= ] with-variable
        ] each
    ] [ button 0 button-event ] finally ;

gdk_display_manager_get f gdk_display_open
dup >boolean t assert= gdk_display_manager_set_default_display
f [
    { 1 2 3 4 5 } [ check-button ] each
    { gtk2-game-input-backend x11-game-input-backend } [
        game-input-backend [
            read-mouse buttons>> { f f f f f } assert=
        ] with-variable
    ] each
] with-x
"GTK2 and X11 mouse polling: all five buttons and releases passed" print
0 exit
