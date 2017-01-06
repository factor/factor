! Copyright (C) 2016-2017 Alexander Ilin.

USING: kernel ui.gadgets ;
IN: charts

TUPLE: chart < gadget ;

M: chart pref-dim* drop { 300 300 } ;

! Return the bottom-left and top-right corners of the visible area.
: chart-axes ( chart -- seq )
    drop { { 0 300 } { 0 300 } } ;

! There are several things to do to present data on the screen.
! Map the data coordinates to the screen coordinates.
! Cut off data outside the presentation window.
! Remove redundant points from the drawing pass.

! chart new line new COLOR: blue >>color { { 0 100 } { 100 0 } { 100 50 } { 150 50 } { 200 100 } } >>data add-gadget gadget.
