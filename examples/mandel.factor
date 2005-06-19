! Graphical mandelbrot fractal renderer.
!
! To run this code, bootstrap Factor like so:
!
! ./f boot.image.le32
!     -libraries:sdl:name=libSDL.so
!     -libraries:sdl-gfx:name=libSDL_gfx.
!
! (But all on one line)
!
! Then, start Factor as usual (./f factor.image) and enter this
! at the listener:
!
! "examples/mandel.factor" run-file

IN: mandel
USE: compiler
USE: alien
USE: errors
USE: kernel
USE: lists
USE: math
USE: namespaces
USE: sdl
USE: sdl-event
USE: sdl-gfx
USE: sdl-video
USE: vectors
USE: prettyprint
USE: sequences
USE: io
USE: test

: f_ ( h s v i -- f ) >r swap rot >r 2dup r> 6 * r> - ;
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
        [ f_ t_ p swap     ( v p t ) ]
        [ f_ q  p -rot     ( q v p ) ]
        [ f_ t_ p swapd    ( p v t ) ]
        [ f_ q  p rot      ( p q v ) ]
        [ f_ t_ p swap rot ( t p v ) ]
        [ f_ q  p          ( v p q ) ]
    } mod-cond ;

[ 1/2 1/2 1/2 ] [ 0 0 1/2 hsv>rgb ] unit-test

[ 1/2 1/4 1/4 ] [ 0 1/2 1/2 hsv>rgb ] unit-test
[ 1/3 2/9 2/9 ] [ 0 1/3 1/3 hsv>rgb ] unit-test

[ 24/125 1/5 4/25 ] [ 1/5 1/5 1/5 hsv>rgb ] unit-test
[ 29/180 1/6 5/36 ] [ 1/5 1/6 1/6 hsv>rgb ] unit-test

[ 6/25 2/5 38/125 ] [ 2/5 2/5 2/5 hsv>rgb ] unit-test
[ 8/25 4/5 64/125 ] [ 2/5 3/5 4/5 hsv>rgb ] unit-test

[ 6/25 48/125 3/5 ] [ 3/5 3/5 3/5 hsv>rgb ] unit-test
[ 0 0 0 ] [ 3/5 1/5 0 hsv>rgb ] unit-test

[ 84/125 4/25 4/5 ] [ 4/5 4/5 4/5 hsv>rgb ] unit-test
[ 7/15 1/3 1/2 ] [ 4/5 1/3 1/2 hsv>rgb ] unit-test

[ 5/6 5/36 5/6 ] [ 5/6 5/6 5/6 hsv>rgb ] unit-test
[ 1/6 0 1/6 ] [ 5/6 1 1/6 hsv>rgb ] unit-test

[ 1 0 0 ] [ 1 1 1 hsv>rgb ] unit-test
[ 1/6 1/9 1/9 ] [ 1 1/3 1/6 hsv>rgb ] unit-test

: scale 255 * >fixnum ;

: scale-rgb ( r g b a -- n )
    scale
    swap scale 8 shift bitor
    swap scale 16 shift bitor
    swap scale 24 shift bitor ;

: sat 0.85 ;
: val 0.85 ;

: <color-map> ( nb-cols -- map )
    [
        dup [
            dup 360 * pick 1 + / 360 / sat val
            hsv>rgb 1.0 scale-rgb ,
        ] repeat
    ] make-vector nip ;

: absq >rect swap sq swap sq + ; inline

: iter ( c z nb-iter -- x )
    over absq 4 >= over 0 = or [
        nip nip
    ] [
        1 - >r sq dupd + r> iter
    ] ifte ;

: max-color 360 ;

SYMBOL: zoom-fact
SYMBOL: x-inc
SYMBOL: y-inc
SYMBOL: nb-iter
SYMBOL: cols
SYMBOL: center

: init-mandel ( -- )
    width get 200000 zoom-fact get * / x-inc set
    height get 150000 zoom-fact get * / y-inc set
    nb-iter get max-color min <color-map> cols set ;

: c ( i j -- c )
    >r
    x-inc get * center get real x-inc get width get 2 / * - + >float
    r>
    y-inc get * center get imaginary y-inc get height get 2 / * - + >float
    rect> ;

: render ( -- )
    [
        c 0 nb-iter get iter dup 0 = [
            drop 0
        ] [
            cols get [ length mod ] keep nth
        ] ifte
    ] with-pixels ; compiled

: event-loop ( event -- )
    dup SDL_WaitEvent [
        dup event-type SDL_QUIT = [
            drop
        ] [
            event-loop
        ] ifte
    ] [
        drop
    ] ifte ; compiled

: mandel ( -- )
    1280 1024 0 SDL_HWSURFACE  [
        [
            3.7 zoom-fact set
            -0.45 center set
            100 nb-iter set
            init-mandel
            [ render ] time
            "Done." print flush
        ] with-surface

        <event> event-loop
        SDL_Quit
    ] with-screen ;

mandel
