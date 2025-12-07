! Copyright (C) 2005, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel math.vectors models models.product
models.range opengl sequences ui.gadgets ;
IN: ui.gadgets.viewports

TUPLE: viewport < gadget { constraint initial: { 1 1 } } ;

: find-viewport ( gadget -- viewport )
    [ viewport? ] find-parent ;

: <viewport> ( content model -- viewport )
    viewport new
        swap >>model
        t >>clipped?
        swap add-gadget ;

M: viewport layout*
    [ gadget-child ]
    [ [ dim>> ] [ gadget-child pref-dim ] bi vmax ] bi >>dim drop ;

M: viewport focusable-child*
    gadget-child ;

: scroll-position ( scroller -- loc )
    model>> [ range-value ] product-value v>integer ;

M: viewport model-changed
    nip
    [ relayout-1 ]
    [
        [ gadget-child ]
        [ scroll-position vneg ]
        [ constraint>> ]
        tri v* [ gl-round ] map >>loc drop
    ] bi ;

: visible-dim ( gadget -- dim )
    dup parent>> viewport? [ parent>> ] when dim>> ;
