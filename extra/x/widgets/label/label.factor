
USING: kernel x11.xlib mortar slot-accessors x.gc x.widgets ;

IN: x.widgets.label

SYMBOL: <label>

<label> <widget> { "gc" "text" } accessors define-simple-class

<label> "create" !( text <label> -- label ) [
new-empty swap >>text <gc> new* >>gc ExposureMask >>mask <- init-widget
] add-class-method

<label> "handle-expose" !( event label -- ) [
  nip <- clear dup $gc { 20 20 } pick $text <---- draw-string
] add-method
