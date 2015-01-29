! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel namespaces sequences ui.gadgets.frames
ui.gadgets.grids ui.gadgets.icons ui.gadgets.theme ;
IN: ui.gadgets.corners

CONSTANT: @center { 1 1 }
CONSTANT: @left { 0 1 }
CONSTANT: @right { 2 1 }
CONSTANT: @top { 1 0 }
CONSTANT: @bottom { 1 2 }

CONSTANT: @top-left { 0 0 }
CONSTANT: @top-right { 2 0 }
CONSTANT: @bottom-left { 0 2 }
CONSTANT: @bottom-right { 2 2 }

SYMBOL: name

: corner-image ( name -- image )
    [ name get "-" ] dip 3append theme-image ;

: corner-icon ( name -- icon )
    corner-image <icon> ;

: /-----\ ( corner -- corner )
    "top-left" corner-icon @top-left grid-add
    "top-middle" corner-icon @top grid-add
    "top-right" corner-icon @top-right grid-add ;

: |-----| ( gadget corner -- corner )
    "left-edge" corner-icon @left grid-add
    swap @center grid-add
    "right-edge" corner-icon @right grid-add ;

: \-----/ ( corner -- corner )
    "bottom-left" corner-icon @bottom-left grid-add
    "bottom-middle" corner-icon @bottom grid-add
    "bottom-right" corner-icon @bottom-right grid-add ;

: make-corners ( class name quot -- corners )
    [ [ [ 3 3 ] dip new-frame { 1 1 } >>filled-cell ] dip name ] dip
    with-variable ; inline
