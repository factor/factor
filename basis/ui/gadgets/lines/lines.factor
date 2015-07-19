! Copyright (C) 2015 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors colors.constants kernel ui.pens.solid ;
IN: ui.gadgets.lines

<PRIVATE

CONSTANT: line-color COLOR: grey75

PRIVATE>

: with-lines ( track -- track )
    dup orientation>> >>gap 
    line-color <solid> >>interior ;

: white-interior ( track -- track )
    COLOR: white <solid> >>interior ;
