! Copyright (C) 2008 Matthew Willis.
! See http://factorcode.org/license.txt for BSD license.
USING: pango.cairo cairo cairo.ffi
cairo.gadgets namespaces arrays
fry accessors ui.gadgets assocs
sequences shuffle opengl opengl.gadgets
alien.c-types kernel math ;
IN: pango.cairo.gadgets

SYMBOL: textures
SYMBOL: dims
SYMBOL: refcounts

: init-cache ( symbol -- )
    dup get [ drop ] [ H{ } clone swap set-global ] if ;

textures init-cache
dims init-cache
refcounts init-cache

TUPLE: pango-gadget < cairo-gadget text font ;

: cache-key ( gadget -- key )
    [ font>> ] [ text>> ] bi 2array ;

: refcount-change ( gadget quot -- )
    >r cache-key refcounts get
    [ [ 0 ] unless* ] r> compose change-at ;

: <pango-gadget> ( font text -- gadget )
    pango-gadget construct-gadget
        swap >>text
        swap >>font ;

: setup-layout ( {font,text} -- quot )
    first2 '[ , layout-font , layout-text ] ;

M: pango-gadget quot>> ( gadget -- quot )
    cache-key setup-layout [ show-layout ] compose
    [ with-pango ] curry ;

M: pango-gadget dim>> ( gadget -- dim )
    cache-key dims get [ setup-layout layout-size ] cache ;

M: pango-gadget graft* ( gadget -- ) [ 1+ ] refcount-change ;

M: pango-gadget ungraft* ( gadget -- ) [ 1- ] refcount-change ;

M: pango-gadget render* ( gadget -- ) 
    [ gen-texture ] [ cache-key textures get set-at ]
    [ call-next-method ] tri ;

M: pango-gadget tex>> ( gadget -- texture )
    dup cache-key textures get at 
    [ ] [ render* tex>> ] ?if ;

USE: ui.gadgets.panes
: hello "Sans 50" "hello" <pango-gadget> gadget. ;
