! Run this file to write a Mandelbrot fractal to "mandel.ppm".

IN: mandel
USING: arrays compiler io kernel math namespaces sequences
strings test ;

: max-color 360 ; inline
: zoom-fact 0.8 ; inline
: width 640 ; inline
: height 480 ; inline
: nb-iter 40 ; inline
: center -0.65 ; inline

: f_ >r swap rot >r 2dup r> 6 * r> - ;
: p ( v s x -- v p x ) >r dupd neg 1 + * r> ;
: q ( v s f -- q ) * neg 1 + * ;
: t_ ( v s f -- t_ ) neg 1 + * neg 1 + * ;

: mod-cond ( p vector -- )
    #! Call p mod q'th entry of the vector of quotations, where
    #! q is the length of the vector. The value q remains on the
    #! stack.
    [ dupd length mod ] keep nth call ;

: hsv>rgb ( h s v -- r g b )
    pick 6 * >fixnum {
        [ f_ t_ p swap     ] ! v p t
        [ f_ q  p -rot     ] ! q v p
        [ f_ t_ p swapd    ] ! p v t
        [ f_ q  p rot      ] ! p q v
        [ f_ t_ p swap rot ] ! t p v
        [ f_ q  p          ] ! v p q
    } mod-cond ;

: scale 255 * >fixnum ; inline

: scale-rgb ( r g b -- n )
    rot scale rot scale rot scale 3array ;

: sat 0.85 ; inline
: val 0.85 ; inline

: <color-map> ( nb-cols -- map )
    dup [
        360 * swap 1+ / 360 / sat val
        hsv>rgb scale-rgb
    ] map-with ;

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
        width [
            2dup swap c 0 nb-iter iter dup zero? [
                drop "\0\0\0"
            ] [
                cols get [ length mod ] keep nth
            ] if %
        ] repeat
    ] repeat ;

: ppm-header ( w h -- )
    "P6\n" % swap # " " % # "\n255\n" % ;

: sbuf-size width height * 3 * 100 + ;

: run ( -- string )
    [
        sbuf-size <sbuf> building set
        width height ppm-header
        nb-iter max-color min <color-map> cols set
        render
        building get >string
    ] with-scope ;

: run>file ( file -- )
    "Generating " write dup write "..." print
    <file-writer> [ run write ] with-stream ;
