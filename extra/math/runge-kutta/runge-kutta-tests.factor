USING: math math.runge-kutta sequences tools.test ;

! 1-dimensional exponential increase of x with t
! initial state at { t x } of { 0 1 } with time step of 1
! x is always increasing by x so dx/dt is just the x value from the initial state
! gradient at beginning of interval
{ { 1 } } [ { 0 1 } 1 { [ second ] } (runge-kutta) ] unit-test
! gradient at midpoint of interval using previous estimation
{ { 3 } } [ { 1 } { 0 1 } 1 runge-kutta-2-transform { [ second ] } (runge-kutta) ] unit-test
! again gradient at midpoint of interval using previous estimation
{ { 5 } } [ { 3 } { 0 1 } 1 runge-kutta-3-transform { [ second ] } (runge-kutta) ] unit-test
! gradient at end of interval using previous estimation
{ { 6 } } [ { 5 } { 0 1 } 1 runge-kutta-4-transform { [ second ] } (runge-kutta) ] unit-test

! the summation of vectors for each stage, divided by 6, added to inital
{ 7/2 } [ { 6 5 3 1 } 0 [ + ] reduce 6 / 1 + ] unit-test
{ { 1 7/2 } } [ { [ second ] } 1 { 0 1 } (runge-kutta-4) ] unit-test

! alters time dimension by delta
{ { 1 1 2 3 } } [ 1 { 0 1 2 3 } increment-time ] unit-test

! alters spatial dimensions by approximation
{ { 1 3/2 7/3 13/4 } } [ { 1/2 1/3 1/4 } { 1 1 2 3 } increment-state-by-approximation ] unit-test
