! Copyright (C) 2016-2017 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel ui.gadgets ;
IN: charts

TUPLE: chart < gadget ;

M: chart pref-dim* drop { 300 300 } ;

! Return the x and y ranges of the visible area.
: chart-axes ( chart -- seq )
    drop { { 0 300 } { 0 300 } } ;

! Return the { width height } of the visible area, in pixels.
: chart-dim ( chart -- seq ) dim>> ;

! There are several things to do to present data on the screen.
! Map the data coordinates to the screen coordinates.
! Cut off data outside the presentation window. When cutting off vertically, split the line into segments and add new points if necessary. Return an array of line segments.
! Remove redundant points from the drawing pass.

! chart new line new COLOR: blue >>color { { 0 100 } { 100 0 } { 100 50 } { 150 50 } { 200 100 } } >>data add-gadget "Chart" open-window
