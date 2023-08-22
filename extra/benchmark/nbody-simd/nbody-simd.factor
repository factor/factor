! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types kernel math math.constants
math.functions math.vectors math.vectors.simd.cords math.parser
combinators.smart sequences classes.struct specialized-arrays io ;
IN: benchmark.nbody-simd

: solar-mass ( -- x ) 4 pi sq * ; inline
CONSTANT: days-per-year 365.24

STRUCT: body
{ location double-4 }
{ velocity double-4 }
{ mass double } ;

SPECIALIZED-ARRAY: body

: <body> ( location velocity mass -- body )
    [ days-per-year v*n ] [ solar-mass * ] bi* body boa ; inline

: <jupiter> ( -- body )
    double-4{ 4.84143144246472090e00 -1.16032004402742839e00 -1.03622044471123109e-01 0.0 }
    double-4{ 1.66007664274403694e-03 7.69901118419740425e-03 -6.90460016972063023e-05 0.0 }
    9.54791938424326609e-04
    <body> ;

: <saturn> ( -- body )
    double-4{ 8.34336671824457987e00 4.12479856412430479e00 -4.03523417114321381e-01 0.0 }
    double-4{ -2.76742510726862411e-03 4.99852801234917238e-03 2.30417297573763929e-05 0.0 }
    2.85885980666130812e-04
    <body> ;

: <uranus> ( -- body )
    double-4{ 1.28943695621391310e01 -1.51111514016986312e01 -2.23307578892655734e-01 0.0 }
    double-4{ 2.96460137564761618e-03 2.37847173959480950e-03 -2.96589568540237556e-05 0.0 }
    4.36624404335156298e-05
    <body> ;

: <neptune> ( -- body )
    double-4{ 1.53796971148509165e01 -2.59193146099879641e01 1.79258772950371181e-01 0.0 }
    double-4{ 2.68067772490389322e-03 1.62824170038242295e-03 -9.51592254519715870e-05 0.0 }
    5.15138902046611451e-05
    <body> ;

: <sun> ( -- body )
    double-4{ 0 0 0 0 } double-4{ 0 0 0 0 } 1 <body> ;

: offset-momentum ( body offset -- body )
    vneg solar-mass v/n >>velocity ; inline

: init-bodies ( bodies -- )
    [ first ] [ [ [ velocity>> ] [ mass>> ] bi v*n ] [ v+ ] map-reduce ] bi
    offset-momentum drop ; inline

: <nbody-system> ( -- system )
    [ <sun> <jupiter> <saturn> <uranus> <neptune> ]
    body-array{ } output>sequence
    dup init-bodies ; inline

:: each-pair ( ... bodies pair-quot: ( ... other-body body -- ... ) each-quot: ( ... body -- ... ) -- )
    bodies [| body i |
        body each-quot call
        bodies i 1 + tail-slice [
            body pair-quot call
        ] each
    ] each-index ; inline

: update-position ( body dt -- )
    [ dup velocity>> ] dip '[ _ _ v*n v+ ] change-location drop ; inline

: mag ( dt body other-body -- mag d )
    [ location>> ] bi@ v- [ norm-sq dup sqrt * / ] keep ; inline

:: update-velocity ( other-body body dt -- )
    dt body other-body mag
    [ [ body ] 2dip '[ other-body mass>> _ * _ n*v v- ] change-velocity drop ]
    [ [ other-body ] 2dip '[ body mass>> _ * _ n*v v+ ] change-velocity drop ] 2bi ; inline

: advance ( system dt -- )
    [ '[ _ update-velocity ] [ drop ] each-pair ]
    [ '[ _ update-position ] each ]
    2bi ; inline

: inertia ( body -- e )
    [ mass>> ] [ velocity>> norm-sq ] bi * 0.5 * ; inline

: newton's-law ( other-body body -- e )
    [ [ mass>> ] bi@ * ] [ [ location>> ] bi@ distance ] 2bi / ; inline

: energy ( system -- x )
    [ 0.0 ] dip [ newton's-law - ] [ inertia + ] each-pair ; inline

: nbody ( n -- )
    >fixnum
    <nbody-system>
    [ energy number>string print ]
    [ '[ _ 0.01 advance ] times ]
    [ energy number>string print ] tri ;

: nbody-simd-benchmark ( -- ) 1000000 nbody ;

MAIN: nbody-simd-benchmark
