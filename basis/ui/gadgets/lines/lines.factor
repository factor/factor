! Copyright (C) 2015 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors colors.constants kernel ui.gadgets.colors ui.pens.solid ;
IN: ui.gadgets.lines

: with-lines ( track -- track )
    dup orientation>> >>gap 
    line-color <solid> >>interior ;

: white-interior ( track -- track )
    COLOR: white <solid> >>interior ;
