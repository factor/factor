USING: accessors arrays combinators combinators.extras kernel
literals math math.functions math.vectors sequences
sequences.extras sequences.generalizations
specialized-arrays.instances.alien.c-types.float typed vectors ;
IN: math.runge-kutta

CONSTANT: absolute-epsilon 0.00001
CONSTANT: relative-tolerance 0.0001

CONSTANT: butcher-tableau
    ! rk4(5) fehlberg method
    $[ { $[ float-array{ 0 } ]
      $[ float-array{ 2/9 2/9 } ]
      $[ float-array{ 1/3 1/12 1/4 } ]
      $[ float-array{ 3/4 69/128 -243/128 135/64 } ]
      $[ float-array{ 1 -17/12 27/4 -27/5 16/15 } ]
      $[ float-array{ 5/6 65/432 -5/16 13/16 4/27 5/144 } ] } [ >array ] map ]
CONSTANT: n-order-coefficients $[ float-array{ 1/150 0 -3/100 16/75 1/20 -6/25 } ]
CONSTANT: n-1-order-coefficients $[ float-array{ 47/450 0 12/25 32/225 1/30 6/25 } ]


: rk-order ( -- n ) butcher-tableau length 2 - ;

: coefficients-and-k-values-product ( k-seq butcher-row -- k*B_i )
    [ [ * ] with map ] 2map flip [ sum ] map ;
: (approximation-increment) ( k-seq butcher-row dt -- k*B_i A*h )
    [ unclip ]
    ! acc Bs A dt
    [ [ swap rest coefficients-and-k-values-product ] [ * ] 2bi* ] bi* ;
: approximation-increment ( k*B_i A*h x..nt -- x..nt' )
    [ but-last swap [ v+ ] unless-empty ] [ last + ] bi-curry bi* suffix ; 
TYPED: runge-kutta-stage-n ( accumulation: vector butcher-row: array dt: float x..nt: array -- x..nt': array )
    [ (approximation-increment) ] [ approximation-increment ] bi* ;
: retry-with-adapted-stepsize? ( n epsilon -- ? ) > ;
: (adapt-stepsize) ( n epsilon -- n' ) swap /f 1 rk-order 1 + /f ^ 0.9 * ;
: adapt-stepsize ( dt dx..dn error epsilon -- dt' ) 
    (adapt-stepsize) nip * ;
: (rk) ( k-seq coefficients -- rkn )
    [ flip ] [ '[ _ [ * ] 2map-sum ] map ] bi* ;
: rk ( k-seq -- rkn-1 rkn )
    [ n-1-order-coefficients (rk) ] [ n-order-coefficients (rk) ] bi ;
: higher-order-error ( rkn rkn-1 stepsize -- e )
    spin v- vabs maximum * ;

! executes the differential equations for each of the stages of approximation
TYPED:: runge-kutta-stages ( dt: float dx..n/dt: array x..nt: array -- k-seq: vector )
    butcher-tableau vector new 1vector [
      [ dt x..nt runge-kutta-stage-n dx..n/dt [ call( x -- x ) ] with map dt v*n ]
      [ drop swap suffix ] 2bi
    ] accumulate* last rest ;
: step-change-and-error ( dt dx..nt/dt x..nt -- dx..dn error )
    '[ _ _ runge-kutta-stages ] [ [ rk over ] [ higher-order-error ] bi* ] bi ;
: epsilon ( dx..dn -- epsilon )
    l2-norm relative-tolerance * absolute-epsilon + ;

! repeatedly approximates with adadptig stepsize until within tolerence
: (runge-kutta) ( dt dx..n/dt x..nt -- dx..dn' dt' )
    '[
        dup _ _ step-change-and-error over epsilon
        [ adapt-stepsize ] [ retry-with-adapted-stepsize? ] 3bi
    ] [ drop ] while ;
: runge-kutta-step ( dx..n' dt' x..nt -- x..nt+1 )
    [ suffix ] [ v+ ] bi* ;
: runge-kutta ( dt dx..n/dt x..nt -- dt' x..nt' )
    [ (runge-kutta) ] [ overd runge-kutta-step ] bi ;

: time-limit-predicate ( t-limit -- quot: ( x..nt -- ? ) )
    '[ dup last _ <= ] ; inline

: <runge-kutta> ( initial-delta dxn..n/dt initial-x..nt t-limit -- seq )
    time-limit-predicate [ [ runge-kutta ] [ 2drop f ] if ] compose with follow nip ; 

