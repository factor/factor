! Copyright (C) 2017 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays charts charts.lines colors.constants
kernel literals locals math math.constants math.functions
sequences ui ui.gadgets ;
IN: charts.demos

CONSTANT: -pi $[ pi neg ]

: sine-wave ( steps -- seq )
    [ iota ] keep
    pi 2 * swap / [ * pi - dup sin 2array ] curry map
    ${ pi $[ pi sin ] } suffix ;

: cosine-wave ( steps -- seq )
    [ iota ] keep
    pi 2 * swap / [ * pi - dup cos 2array ] curry map
    ${ pi $[ pi cos ] } suffix ;

<PRIVATE

:: (chart-demo) ( n -- )
    chart new ${ ${ -pi pi } { -1 1 } } >>axes
    line new COLOR: blue >>color n sine-wave >>data add-gadget
    line new COLOR: red >>color n cosine-wave >>data add-gadget
    "Chart" open-window ;

PRIVATE>

: chart-demo ( -- ) 40 (chart-demo) ;

MAIN: chart-demo

! chart new line new COLOR: blue >>color { { 0 100 } { 100 0 } { 100 50 } { 150 50 } { 200 100 } } >>data add-gadget "Chart" open-window
