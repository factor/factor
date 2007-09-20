
USING: kernel namespaces arrays x11.xlib mortar slot-accessors x x.font ;

IN: x.gc

SYMBOL: <gc>

<gc> { "dpy" "ptr" "font" } accessors define-independent-class

<gc> "create" !( <gc> -- gc ) [
new-empty dpy get >>dpy
dpy get $ptr  dpy get $default-root $id  0 f XCreateGC >>ptr
"6x13" <font> new* >>font
] add-class-method

<gc> {

"set-subwindow-mode" !( gc mode -- gc )
  [ >r dup $dpy $ptr over $ptr r> XSetSubwindowMode drop ]

"set-function" !( gc function -- gc )
  [ >r dup $dpy $ptr over $ptr r> XSetFunction drop ]

"set-foreground" !( gc foreground -- gc )
  [ >r dup $dpy $ptr over $ptr r> lookup-color XSetForeground drop ]

} add-methods