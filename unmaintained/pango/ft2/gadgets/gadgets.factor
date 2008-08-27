! Copyright (C) 2008 Matthew Willis.
! See http://factorcode.org/license.txt for BSD license.
USING: pango.ft2 pango.gadgets opengl.gadgets
accessors kernel opengl.gl libc
sequences namespaces ui.gadgets pango.layouts ;
IN: pango.ft2.gadgets

TUPLE: pango-ft2-gadget < pango-gadget ;

SINGLETON: pango-ft2-backend
pango-ft2-backend pango-backend set-global

M: pango-ft2-backend construct-pango
    pango-ft2-gadget construct-gadget ;

M: pango-ft2-gadget render*
    [
        [ text>> layout-text ] [ font>> layout-font ] bi
        layout render-layout
    ] with-ft2-layout [ GL_ALPHA render-bytes* ] keep free ;
