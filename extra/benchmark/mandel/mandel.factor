! Copyright (C) 2005, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: io kernel math math.functions sequences prettyprint
io.files io.files.temp io.encodings io.encodings.ascii
io.encodings.binary fry benchmark.mandel.params
benchmark.mandel.colors ;
IN: benchmark.mandel

: x-scale ( -- x ) width  200000 zoom-fact * / ; inline
: y-scale ( -- y ) height 150000 zoom-fact * / ; inline

: scale ( x y -- z ) [ x-scale * ] [ y-scale * ] bi* rect> ; inline

: c ( i j -- c ) scale center width height scale 2 / - + ; inline

: count-iterations ( z max-iterations step-quot test-quot -- #iters )
    '[ drop @ dup @ ] find-last-integer nip ; inline

: pixel ( c -- iterations )
    [ C{ 0.0 0.0 } max-iterations ] dip
    '[ sq _ + ] [ absq 4.0 >= ] count-iterations ; inline

: color ( iterations -- color )
    [ color-map [ length mod ] keep nth ] [ B{ 0 0 0 } ] if* ; inline

: render ( -- )
    height <iota> [ width <iota> swap '[ _ c pixel color write ] each ] each ; inline

: ppm-header ( -- )
    ascii encode-output
    "P6\n" write width pprint bl height pprint "\n255\n" write
    binary encode-output ; inline

: mandel-benchmark ( -- )
    "mandel.ppm" temp-file binary [ ppm-header render ] with-file-writer ;

MAIN: mandel-benchmark
