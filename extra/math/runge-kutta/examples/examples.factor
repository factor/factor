USING: accessors arrays kernel math math.matrices
math.runge-kutta sequences ui.gadgets ui.gadgets.charts
ui.gadgets.charts.lines ui.gadgets.panes ui.theme ;
IN: math.runge-kutta.examples

: lorenz-dx/dt ( tx..n -- dx )
    rest first2
    swap - 10 * ;

: lorenz-dy/dt ( tx..n -- dy )
    rest first3
    28 swap - swapd * swap - ;

: lorenz-dz/dt ( tx..n -- dz )
    rest first3
    [ * ] dip 8/3 * - ;

: <lorenz> ( -- dx..n/dt delta tx..n t-limit )
    { [ lorenz-dx/dt ] [ lorenz-dy/dt ] [ lorenz-dz/dt ] } 0.01 { 0 0 1 21/20 } 150 ;


: lorenz. ( -- )
    chart new { { -20 20 } { -20 20 } } >>axes
    line new link-color >>color
             <lorenz> <runge-kutta-4> { 0 3 } cols-except >>data
    add-gadget
    gadget. ;


:: rf-dx/dt ( tx..n gamma -- dx )
    tx..n rest first3 :> ( x y z )
    y z 1 - x sq + * gamma x * + ;

:: rf-dy/dt ( tx..n gamma -- dy )
    tx..n rest first3 :> ( x y z )
    x 3 z * 1 + x sq - * gamma y * + ;

:: rf-dz/dt ( tx..n alpha -- dz )
    tx..n rest first3 :> ( x y z )
    -2 z * alpha x y * + * ;

:: <rabinovich-fabrikant> ( gamma alpha -- dx..n/dt delta tx..n t-limit )
    gamma '[ _ rf-dx/dt ] gamma '[ _ rf-dy/dt ] alpha '[ _ rf-dz/dt ]
    3array
    0.01 { 0 -1 0 0.5 } 150 ;


: rabinovich-fabrikant. ( -- )
    chart new { { -2 2 } { -2 2 } } >>axes
    line new link-color >>color
             0.1 0.14 <rabinovich-fabrikant> <runge-kutta-4> { 0 3 } cols-except >>data
             add-gadget
    gadget. ;
