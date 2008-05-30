! Copyright (C) 2008 Matthew Willis.
! See http://factorcode.org/license.txt for BSD license.
USING: cairo.pango cairo cairo.ffi cairo.gadgets
alien.c-types kernel math ;
IN: cairo.pango.gadgets

: (pango-gadget) ( setup show -- gadget )
    [ drop layout-size ]
    [ compose [ with-pango ] curry <cairo-gadget> ] 2bi ;

: <pango-gadget> ( quot -- gadget )
    [ cr layout pango_cairo_show_layout ] (pango-gadget) ;

USING: prettyprint sequences ui.gadgets.panes
threads io.backend io.encodings.utf8 io.files ;
: hello-pango ( -- )
    50 [ 6 + ] map [
        "Sans " swap unparse append
        [ 
            cr 0 1 0.2 0.6 cairo_set_source_rgba
            layout-font "今日は、 Pango!" layout-text
        ] curry
        <pango-gadget> gadget. yield
    ] each
    [ 
        "resource:extra/cairo/pango/gadgets/gadgets.factor"
        normalize-path utf8 file-contents layout-text
    ] <pango-gadget> gadget. ;

MAIN: hello-pango
