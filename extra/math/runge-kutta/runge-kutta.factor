USING: accessors arrays combinators combinators.extras kernel
math math.functions math.vectors sequences sequences.extras
sequences.generalizations ;
IN: math.runge-kutta

CONSTANT: absolute-epsilon 0.0000001

CONSTANT: butcher-tableau
    ! rk4(5) fehlberg method
    { { 0 }
    { 1/4 1/4 }
    { 3/8 3/32 9/32 }
    { 12/13 1932/2197 -7200/2197 7296/2197 }
    { 1 439/216 -8 3680/513 -845/4104 }
    { 1/2 -8/27 2 -3544/2565 1859/4104 -11/40 } }
CONSTANT: n-order-coefficients { 16/135 0 6656/12825 28561/56430 -9/50 2/55 } 
CONSTANT: n-1-order-coefficients { 25/216 0 1408/2565 2197/4104 -1/5 0 }

! : butcher-tableau ( -- seq )
!     ! rk1(2) fehlberg method
!     { { 0 }
!     { 1/2 1/2 }
!     { 1 1/256 255/256 } } ;
! : n-order-coefficients ( -- seq )
!     { 1/512 255/256 1/512 } ;
! : n-1-order-coefficients ( -- seq )
!     { 1/256 255/256 0 } ; 

: rk-order ( -- n ) butcher-tableau length 2 - ;

: coefficients-and-k-values-product ( k-seq butcher-row -- k*B_i )
    [ [ * ] with map ] 2map flip [ sum ] map ;
: (approximation-increment) ( k-seq butcher-row dt -- k*B_i A*h )
    [ unclip ]
    ! acc Bs A dt
    [ [ swap rest coefficients-and-k-values-product ] [ * ] 2bi* ] bi* ;
: approximation-increment ( k*B_i A*h x..nt -- x..nt' )
    [ but-last swap [ v+ ] unless-empty ] [ last + ] bi-curry bi* suffix ; 
: runge-kutta-stage-n ( accumulation butcher-row dt x..nt -- x..nt' )
    [ (approximation-increment) ] [ approximation-increment ] bi* ;
: retry-with-adapted-stepsize? ( n -- ? ) absolute-epsilon > ;
: (adapt-stepsize) ( n -- n' ) absolute-epsilon swap /f 1 rk-order 1 + /f ^ 0.84 * ;
: adapt-stepsize ( dt dx..n error -- dt' ) 
    ! leaving relative tolerance unimplemented for now, so ignoring dx..n
    nip (adapt-stepsize) * ;
: (rk) ( k-seq coefficients -- rkn )
    [ flip ] [ '[ _ [ * ] 2map-sum ] map ] bi* ;
: rk ( k-seq -- rkn-1 rkn )
    [ n-1-order-coefficients (rk) ] [ n-order-coefficients (rk) ] bi ;
: higher-order-error ( rkn rkn-1 stepsize -- e )
    spin v- vabs maximum * ;

! executes the differential equations for each of the stages of approximation
:: runge-kutta-stages ( dt dx..n/dt x..nt -- k-seq )
    butcher-tableau V{ { } } [
      [ dt x..nt runge-kutta-stage-n dx..n/dt [ call( x -- x ) ] with map dt v*n ]
      [ drop swap suffix ] 2bi
    ] accumulate* last rest ;
: step-change-and-error ( dt dx..nt/dt x..nt -- dx..dn error )
    '[ _ _ runge-kutta-stages ] [ [ rk over ] [ higher-order-error ] bi* ] bi ;

! repeatedly approximates with adadptig stepsize until within tolerence
: (runge-kutta) ( dt dx..n/dt x..nt -- dx..dn' dt' )
    '[
        dup _ _ step-change-and-error
        [ adapt-stepsize ] [ retry-with-adapted-stepsize? ] 2bi
    ] [ drop ] while ;
: runge-kutta-step ( dx..n' dt' x..nt -- x..nt+1 )
    [ suffix ] [ v+ ] bi* ;
: runge-kutta ( dt dx..n/dt x..nt -- dt' x..nt' )
    [ (runge-kutta) ] [ overd runge-kutta-step ] bi ;

: time-limit-predicate ( t-limit -- quot: ( x..nt -- ? ) )
    '[ dup last _ <= ] ; inline

: <runge-kutta> ( initial-delta dxn..n/dt initial-x..nt t-limit -- seq )
    time-limit-predicate [ [ runge-kutta ] [ 2drop f ] if ] compose with follow nip ; 

