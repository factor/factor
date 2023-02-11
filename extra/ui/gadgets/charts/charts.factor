! Copyright (C) 2016-2017 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
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
