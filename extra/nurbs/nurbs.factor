! Copyright (C) 2009 Joe Groff
! See https://factorcode.org/license.txt for BSD license
USING: accessors alien.c-types grouping kernel math
math.order ranges math.vectors math.vectors.homogeneous
sequences specialized-arrays ;
SPECIALIZED-ARRAY: alien.c-types:float
IN: nurbs

TUPLE: nurbs-curve
    { order integer }
    control-points
    knots
    (knot-constants) ;

: ?recip ( n -- 1/n )
    dup zero? [ recip ] unless ;

:: order-index-knot-constants ( curve order index -- knot-constants )
    curve knots>> :> knots
    index order 1 - + knots nth :> knot_i+k-1
    index             knots nth :> knot_i
    index order +     knots nth :> knot_i+k
    index 1 +         knots nth :> knot_i+1

    knot_i+k-1 knot_i   - ?recip :> c1
    knot_i+1   knot_i+k - ?recip :> c2

    knot_i   c1 * neg :> c3
    knot_i+k c2 * neg :> c4

    c1 c2 c3 c4 float-array{ } 4sequence ;

: order-knot-constants ( curve order -- knot-constants )
    2dup [ knots>> length ] dip - <iota>
    [ order-index-knot-constants ] 2with map ;

: knot-constants ( curve -- knot-constants )
    2 over order>> [a..b]
    [ order-knot-constants ] with map ;

: update-knots ( curve -- curve )
    dup knot-constants >>(knot-constants) ;

: <nurbs-curve> ( order control-points knots -- nurbs-curve )
    f nurbs-curve boa update-knots ;

: knot-interval ( nurbs-curve t -- index )
    [ knots>> ] dip [ > ] curry find drop 1 - ;

: clip-range ( from to sequence -- from' to' )
    length min [ 0 max ] dip ;

:: eval-base ( knot-constants bases t -- base )
    knot-constants first t * knot-constants third + bases first *
    knot-constants second t * knot-constants fourth + bases second *
    + ;

: eval-curve ( base-values control-points -- value )
    [ n*v ] 2map { 0.0 0.0 0.0 } [ v+ ] binary-reduce h>v ;

:: eval-bases ( curve t interval values order -- values' )
    order 2 - curve (knot-constants)>> nth :> all-knot-constants
    interval order interval + all-knot-constants clip-range :> ( from to )
    from to all-knot-constants subseq :> knot-constants
    values { 0.0 } { 0.0 } surround 2 <clumps> :> bases

    knot-constants bases [ t eval-base ] 2map :> values'
    order curve order>> =
    [ values' from to curve control-points>> subseq eval-curve ]
    [ curve t interval 1 - values' order 1 + eval-bases ] if ;

: eval-nurbs ( nurbs-curve t -- value )
    2dup knot-interval 1 - { 1.0 } 2 eval-bases ;
