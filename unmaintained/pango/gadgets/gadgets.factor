! Copyright (C) 2008 Matthew Willis.
! See http://factorcode.org/license.txt for BSD license.
USING: opengl.gadgets kernel
arrays
accessors ;

IN: pango.gadgets

TUPLE: pango-gadget < texture-gadget text font ;

M: pango-gadget cache-key* [ font>> ] [ text>> ] bi 2array ;

SYMBOL: pango-backend
HOOK: construct-pango pango-backend ( -- gadget )

: <pango> ( font text -- gadget )
    construct-pango
        swap >>text
        swap >>font ;
