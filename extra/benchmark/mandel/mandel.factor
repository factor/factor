IN: benchmark.mandel
USING: arrays io kernel math namespaces sequences strings sbufs
math.functions math.parser io.files colors.hsv ;

: max-color 360 ; inline
: zoom-fact 0.8 ; inline
: width 640 ; inline
: height 480 ; inline
: nb-iter 40 ; inline
: center -0.65 ; inline

: scale 255 * >fixnum ; inline

: scale-rgb ( r g b -- n )
    rot scale rot scale rot scale 3array ;

: sat 0.85 ; inline
: val 0.85 ; inline

: <color-map> ( nb-cols -- map )
    dup [
        360 * swap 1+ / sat val
        3array hsv>rgb first3 scale-rgb
    ] curry* map ;

: iter ( c z nb-iter -- x )
    over absq 4.0 >= over zero? or
    [ 2nip ] [ 1- >r sq dupd + r> iter ] if ; inline

SYMBOL: cols

: x-inc width 200000 zoom-fact * / ; inline
: y-inc height 150000 zoom-fact * / ; inline

: c ( i j -- c )
    >r
    x-inc * center real x-inc width 2 / * - + >float
    r>
    y-inc * center imaginary y-inc height 2 / * - + >float
    rect> ; inline

: render ( -- )
    height [
        width swap [
            c 0 nb-iter iter dup zero? [
                drop "\0\0\0"
            ] [
                cols get [ length mod ] keep nth
            ] if %
        ] curry each
    ] each ;

: ppm-header ( w h -- )
    "P6\n" % swap # " " % # "\n255\n" % ;

: sbuf-size width height * 3 * 100 + ;

: mandel ( -- string )
    [
        sbuf-size <sbuf> building set
        width height ppm-header
        nb-iter max-color min <color-map> cols set
        render
        building get >string
    ] with-scope ;

: mandel-main ( -- )
    "mandel.ppm" resource-path <file-writer>
    [ mandel write ] with-stream ;

MAIN: mandel-main
