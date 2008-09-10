! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays io kernel math math.functions math.order
math.parser sequences byte-arrays byte-vectors io.files
io.encodings.binary fry namespaces benchmark.mandel.params
benchmark.mandel.colors ;
IN: benchmark.mandel

: x-inc width  200000 zoom-fact * / ; inline
: y-inc height 150000 zoom-fact * / ; inline

: c ( i j -- c )
    [ x-inc * center real-part x-inc width 2 / * - + >float ]
    [ y-inc * center imaginary-part y-inc height 2 / * - + >float ] bi*
    rect> ; inline

: count-iterations ( z max-iterations step-quot test-quot -- #iters )
    '[ drop @ dup @ ] find-last-integer nip ; inline

: pixel ( c -- iterations )
    [ C{ 0.0 0.0 } max-iterations ] dip
    '[ sq , + ] [ absq 4.0 >= ] count-iterations ; inline

: color ( iterations -- color )
    [ color-map [ length mod ] keep nth ] [ B{ 0 0 0 } ] if* ; inline

: render ( -- )
    height [ width swap '[ , c pixel color % ] each ] each ; inline

: ppm-header ( -- )
    "P6\n" % width # " " % height # "\n255\n" % ; inline

: buf-size ( -- n ) width height * 3 * 100 + ; inline

: mandel ( -- data )
    buf-size <byte-vector>
    [ building [ ppm-header render ] with-variable ] [ B{ } like ] bi ;

: mandel-main ( -- )
    mandel "mandel.ppm" temp-file binary set-file-contents ;

MAIN: mandel-main
