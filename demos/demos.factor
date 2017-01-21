! Copyright (C) 2017 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays charts charts.lines colors.constants
kernel literals math math.constants math.functions sequences ui
ui.gadgets ;
IN: charts.demos

CONSTANT: -pi $[ pi neg ]

: sine-wave ( steps -- seq )
    [ iota ] keep
    pi 2 * swap / [ * pi - dup sin 2array ] curry map
    ${ pi $[ pi sin ] } suffix ;

: chart-demo ( -- )
    chart new ${ ${ -pi pi } { -1 1 } } >>axes
    line new COLOR: blue >>color 40 sine-wave >>data
    add-gadget "Chart" open-window ;

MAIN: chart-demo

! chart new line new COLOR: blue >>color { { 0 100 } { 100 0 } { 100 50 } { 150 50 } { 200 100 } } >>data add-gadget "Chart" open-window
