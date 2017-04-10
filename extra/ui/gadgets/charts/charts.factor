! Copyright (C) 2016-2017 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel sequences ui.gadgets ;
IN: ui.gadgets.charts

TUPLE: chart < gadget axes ;

M: chart pref-dim* drop { 300 300 } ;

! Return the x and y ranges of the visible area.
: chart-axes ( chart -- seq )
    [ dim>> ] [ axes>> ] bi [
        nip
    ] [
        [ 0 swap 2array ] map
    ] if* ;

! Return the { width height } of the visible area, in pixels.
: chart-dim ( chart -- seq ) dim>> ;

! There are several things to do to present data on the screen.
! Map the data coordinates to the screen coordinates.
! Cut off data outside the presentation window. When cutting off vertically, split the line into segments and add new points if necessary. Return an array of line segments.
! Remove redundant points from the drawing pass.
