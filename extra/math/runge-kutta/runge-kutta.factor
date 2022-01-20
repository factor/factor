USING: kernel accessors combinators sequences sequences.generalizations
arrays math math.vectors ;
IN: math.runge-kutta

: runge-kutta-2-transform ( rk1 tx..n delta -- tx..n' delta )
    [ swap [ [ v*n ] keep prefix 1/2 v*n ] dip v+ 2 v*n ] keep ;

: runge-kutta-3-transform ( rk2 tx..n delta -- tx..n' delta )
    runge-kutta-2-transform ;

: runge-kutta-4-transform ( rk3 tx..n delta -- tx..n' delta )
    [ swapd [ v*n ] keep prefix v+ ] keep ;

: (runge-kutta) ( delta tx..n dx..n/dt -- rk )
    swapd dup length>> [ cleave ] dip narray swap v*n
    ; inline

: runge-kutta-differentials ( dx..n/dt -- seq )
    '[ _ (runge-kutta) ] ;

: runge-kutta-transforms ( tx..n delta dx..n/dt -- seq )
    spin
    [ { [ ]
      [ runge-kutta-2-transform ]
      [ runge-kutta-3-transform ]
      [ runge-kutta-4-transform ] } ] dip
    '[ _ runge-kutta-differentials compose ] map
    [ 2curry ] 2with map ;

: increment-time ( delta tx..n -- t+dtx..n )
    [ swap [ 0 ] 2dip '[ _ + ] change-nth ] keep ; inline

: increment-state-by-approximation ( rk4 t+dtx..n -- t+dtx'..n' )
    swap 0 prefix v+ ;

: (runge-kutta-4) ( dx..n/dt delta tx..n -- tx..n' )
    [
        ! set up the set of 4 equations
        ! NOTE differential functions and timestep are curried
        runge-kutta-transforms [ [ dup ] compose ] map

        ! using concat instead causes slow down by an order of magnitude
        [ ] [ compose ] reduce

        ! this will always produce 4 outputs with a duplication of the last result
        ! NOTE the dup is kept in the transform so that function
        ! can be used in higher-order estimation
        call( -- rk1 rk2 rk3 rk4 rk4 ) drop 4array 

        ! make array of zeroes of appropriate length to reduce into
        dup first length>> 0 <array>

        ! reduce the results to the estimated change for the timestep
        [ v+ ] reduce
        1/6 v*n
    ] 2keep
    increment-time
    increment-state-by-approximation
    ;

: time-limit-predicate ( t-limit -- quot: ( tx..n -- ? ) )
    '[ dup first _ <= ] ; inline

: <runge-kutta-4> ( dxn..n/dt delta initial-state t-limit -- seq )
    time-limit-predicate [ [ (runge-kutta-4) ] [ 3drop f ] if ] compose 2with follow ; inline
