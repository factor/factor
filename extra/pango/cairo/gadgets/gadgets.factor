! Copyright (C) 2008 Matthew Willis.
! See http://factorcode.org/license.txt for BSD license.
USING: pango.cairo pango.gadgets
cairo.gadgets arrays namespaces
fry accessors ui.gadgets
sequences opengl.gadgets
kernel pango.layouts ;

IN: pango.cairo.gadgets

TUPLE: pango-cairo-gadget < pango-gadget ;

SINGLETON: pango-cairo-backend
pango-cairo-backend pango-backend set-global

M: pango-cairo-backend construct-pango
    pango-cairo-gadget construct-gadget ;

: setup-layout ( gadget -- quot )
    [ font>> ] [ text>> ] bi
    '[ , layout-font , layout-text ] ;

M: pango-cairo-gadget render* ( gadget -- ) 
    setup-layout [ layout-size dup ]
    [ 
        '[ [ @ show-layout ] with-pango-cairo ]
    ] bi render-cairo render-bytes* ;
