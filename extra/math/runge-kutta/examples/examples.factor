USING: accessors arrays kernel math math.functions math.matrices
math.runge-kutta sequences ui.gadgets ui.gadgets.charts
ui.gadgets.charts.lines ui.gadgets.panes ui.theme ;
IN: math.runge-kutta.examples

: lorenz-dx/dt ( x..nt -- dx )
    first2 swap - 10 * ;

: lorenz-dy/dt ( x..nt -- dy )
    first3 28 swap - swapd * swap - ;

: lorenz-dz/dt ( x..nt -- dz )
    first3 [ * ] dip 2.666 * - ;

: <lorenz> ( -- delta dx..n/dt x..nt t-limit )
    0.01 { [ lorenz-dx/dt ] [ lorenz-dy/dt ] [ lorenz-dz/dt ] } { 2.0 1.0 1.0 0.0 } 150 ;


! : lorenz. ( -- )
!     chart new { { -20 20 } { -20 20 } } >>axes
!     line new link-color >>color
!              <lorenz> <runge-kutta> { 0 3 } cols-except >>data
!     add-gadget
!     gadget. ; 


:: rf-dx/dt ( x..nt gamma -- dx )
    x..nt first3 :> ( x y z )
    y z 1 - x sq + * gamma x * + ;

:: rf-dy/dt ( x..nt gamma -- dy )
    x..nt first3 :> ( x y z )
    x 3 z * 1 + x sq - * gamma y * + ;

:: rf-dz/dt ( x..nt alpha -- dz )
    x..nt first3 :> ( x y z )
    -2 z * alpha x y * + * ;

:: <rabinovich-fabrikant> ( gamma alpha -- delta dx..n/dt x..nt t-limit )
    0.01
    { [ gamma rf-dx/dt ] [ gamma rf-dy/dt ] [ alpha rf-dz/dt ] }
    { -1 0 0.5 0 } 1000 ;


! : rabinovich-fabrikant. ( -- )
!     chart new { { -2 2 } { -2 2 } } >>axes
!     line new link-color >>color
!              0.1 0.14 <rabinovich-fabrikant> <runge-kutta> { 0 3 } cols-except >>data
!              add-gadget
!     gadget. ;

CONSTANT: cyclically-symmetric-b 0.208186 ! >1 is stable, =1 is pitchfork bifurcation, <1 weird stuff

: cyclically-symmetric-dx/dt ( x..nt -- dx )
    first2 sin swap cyclically-symmetric-b * - ;

: cyclically-symmetric-dy/dt ( x..nt -- dy )
    rest first2 sin swap cyclically-symmetric-b * - ;

: cyclically-symmetric-dz/dt ( x..nt -- dz )
    first3 nip swap sin swap cyclically-symmetric-b * - ;

: <cyclically-symmetric> ( -- delta dx..n/dt x..nt t-limit )
    0.01
    { [ cyclically-symmetric-dx/dt ] [ cyclically-symmetric-dy/dt ] [ cyclically-symmetric-dz/dt ] }
    { 2.0 1.0 1.0 0.0 } 1000 ;

! : cyclically-symmetric. ( -- )
!     chart new { { -4 4 } { -4 4 } } >>axes
!     line new link-color >>color
!              <cyclically-symmetric> <runge-kutta> { 0 3 } cols-except >>data
!              add-gadget
!     gadget. ;

