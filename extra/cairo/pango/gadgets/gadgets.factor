USING: cairo.pango cairo cairo.ffi cairo.gadgets
alien.c-types kernel math ;
IN: cairo.pango.gadgets

: (pango-gadget) ( setup show -- gadget )
    [ drop layout-size ]
    [ compose [ with-pango ] curry <cached-cairo> ] 2bi ;

: <pango-gadget> ( quot -- gadget )
    [ cr layout pango_cairo_show_layout ] (pango-gadget) ;

USING: prettyprint sequences ui.gadgets.panes
threads ;
: hello-pango ( -- )
    50 [ 6 + ] map [
        "Sans " swap unparse append
        [ 
            cr 0 1 0.2 0.6 cairo_set_source_rgba
            layout-font "今日は、 Pango!" layout-text
        ] curry
        <pango-gadget> gadget. yield
    ] each ;

MAIN: hello-pango
