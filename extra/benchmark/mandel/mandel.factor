USING: arrays io kernel math math.functions math.order
math.parser sequences locals byte-arrays byte-vectors io.files
io.encodings.binary benchmark.mandel.params
benchmark.mandel.colors ;
IN: benchmark.mandel

: iter ( c z nb-iter -- x )
    dup 0 <= [ 2nip ] [
        over absq 4.0 >= [ 2nip ] [
            >r sq dupd + r> 1- iter
        ] if
    ] if ; inline recursive

: x-inc width  200000 zoom-fact * / ; inline
: y-inc height 150000 zoom-fact * / ; inline

: c ( i j -- c )
    [ x-inc * center real-part x-inc width 2 / * - + >float ]
    [ y-inc * center imaginary-part y-inc height 2 / * - + >float ] bi*
    rect> ; inline

:: render ( accum -- )
    height [
        width swap [
            c C{ 0.0 0.0 } nb-iter iter dup zero?
            [ drop B{ 0 0 0 } ] [ color-map [ length mod ] keep nth ] if
            accum push-all
        ] curry each
    ] each ; inline

:: ppm-header ( accum -- )
    "P6\n" accum push-all
    width number>string accum push-all
    " " accum push-all
    height number>string accum push-all
    "\n255\n" accum push-all ; inline

: buf-size ( -- n ) width height * 3 * 100 + ; inline

: mandel ( -- data )
    buf-size <byte-vector>
    [ ppm-header ] [ render ] [ B{ } like ] tri ;

: mandel-main ( -- )
    mandel "mandel.ppm" temp-file binary set-file-contents ;

MAIN: mandel-main
