USING: cairo.pango cairo cairo.ffi cairo.gadgets
alien.c-types kernel math ;
IN: cairo.pango.gadgets

: (pango-gadget) ( setup show -- gadget )
    [ drop layout-size ]
    [ compose [ with-pango ] curry <cached-cairo> ] 2bi ;

: <pango-gadget> ( quot -- gadget )
    [ cr layout pango_cairo_show_layout ] (pango-gadget) ;

USING: prettyprint sequences ui.gadgets.panes ;
: hello-pango ( -- )
    50 [ 6 + ] map [
        "Sans Bold " swap unparse append
        [ layout-font "Hello, Pango!" layout-text ] curry
        <pango-gadget> gadget.
    ] each ;

MAIN: hello-pango
