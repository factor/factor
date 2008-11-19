
USING: kernel io namespaces arrays sequences
       x11.xlib mortar slot-accessors x x.widgets ;

IN: x.widgets.wm.child

SYMBOL: <wm-child>

<wm-child> <widget> { } define-simple-class

<wm-child> "create" !( id <wm-child> -- wm-child ) [ 
  new-empty swap >>id dpy get >>dpy PropertyChangeMask >>mask
  <- add-to-save-set
  0 <-- set-border-width
  <- add-to-window-table
  dup $mask <-- select-input
] add-class-method

<wm-child> "handle-property" !( event wm-child -- ) [
  drop
  "child handle-property :: atom name = " write
  XPropertyEvent-atom get-atom-name print flush
] add-method