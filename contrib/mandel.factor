! Graphical mandelbrot fractal renderer.
! To run this code, start your interpreter like so:
!
! ./f -library:sdl=libSDL.so -library:sdl-gfx=libSDL_gfx.so
!
! Then, enter this at the interpreter prompt:
!
! "contrib/mandel.factor" run-file

IN: mandel

USE: alien
USE: combinators
USE: errors
USE: kernel
USE: lists
USE: logic
USE: math
USE: namespaces
USE: sdl
USE: stack
USE: vectors
USE: prettyprint
USE: stdio
USE: test

: scale 255 * >fixnum ;

: scale-rgba ( r g b -- n )
    scale
    swap scale 8 shift bitor
    swap scale 16 shift bitor
    swap scale 24 shift bitor ;

: sat 0.85 ;
: val 0.85 ;

: <color-map> ( nb-cols -- map )
    [,
        dup [
            360 * over succ / 360 / sat val
            hsv>rgb 1.0 scale-rgba ,
        ] times*
    ,] list>vector nip ;

: absq >rect swap sq swap sq + ;

: iter ( c z nb-iter -- x )
    over absq 4 >= over 0 = or [
        nip nip
    ] [
        pred >r sq dupd + r> iter
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

: c ( #{ i j } -- c )
    >rect >r
    x-inc get * center get real x-inc get width get 2 / * - + >float
    r>
    y-inc get * center get imaginary y-inc get height get 2 / * - + >float
    rect> ;

: render ( -- )
    init-mandel
    width get height get [
        c 0 nb-iter get iter dup 0 = [
            drop 0
        ] [
            cols get [ vector-length mod ] keep vector-nth
        ] ifte
    ] with-pixels ;

: mandel ( -- )
    1280 1024 32 SDL_HWSURFACE SDL_FULLSCREEN bitor SDL_SetVideoMode drop

    [
        3 zoom-fact set
        -0.65 center set
        50 nb-iter set
        [ render ] time
        "Done." print flush
    ] with-surface

    <event> event-loop
    SDL_Quit ;

mandel
