USING: cairo locals ;

IN: cairo.samples

SYMBOL: cr
:: cairo-samp ( cr -- )
    [let | |
        cr 10.0 cairo_set_line_width
        cr 50.0 50.0 20.0 0.0 3.0 cairo_arc
        cr 1.0 1.0 0.0 1.0 cairo_set_source_rgba
        cr cairo_stroke
        cr cairo_fill
    ] ;