! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.data classes.struct combinators.smart
kernel math math.functions math.order math.parser sequences
specialized-arrays io ;
FROM: alien.c-types => float ;
IN: benchmark.struct-arrays

STRUCT: point { x float } { y float } { z float } ;

SPECIALIZED-ARRAY: point

: xyz ( point -- x y z )
    [ x>> ] [ y>> ] [ z>> ] tri ; inline

: change-xyz ( point obj x: ( x obj -- x' ) y: ( y obj -- y' ) z: ( z obj -- z' ) -- point )
    tri-curry [ change-x ] [ change-y ] [ change-z ] tri* ; inline

: init-point ( n point -- n )
    over >fixnum >float
    [ sin >>x ] [ cos 3 * >>y ] [ sin sq 2 / >>z ] tri drop
    1 + ; inline

: make-points ( len -- points )
    point <c-array> dup 0 [ init-point ] reduce drop ; inline

: point-norm ( point -- norm )
    [ xyz [ absq ] tri@ ] sum-outputs sqrt ; inline

: normalize-point ( point -- )
    dup point-norm [ / ] [ / ] [ / ] change-xyz drop ; inline

: normalize-points ( points -- )
    [ normalize-point ] each ; inline

: max-point ( point1 point2 -- point1 )
    [ x>> max ] [ y>> max ] [ z>> max ] change-xyz ; inline

: <zero-point> ( -- point )
    0 0 0 point boa ; inline

: max-points ( points -- point )
    <zero-point> [ max-point ] reduce ; inline

: print-point ( point -- )
    [ xyz [ number>string ] tri@ ] output>array ", " join print ; inline

: struct-arrays-bench ( len -- )
    make-points [ normalize-points ] [ max-points ] bi print-point ;

: struct-arrays-benchmark ( -- )
    10 [ 500000 struct-arrays-bench ] times ;

MAIN: struct-arrays-benchmark
