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
    [
        dup [
            360 * over succ / 360 / sat val
            hsv>rgb 1.0 scale-rgba ,
        ] times*
    ] make-list list>vector nip ;

: absq >rect swap sq swap sq + ; inline

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
    width get height get [
        c 0 nb-iter get iter dup 0 = [
            drop 0
        ] [
            cols get [ vector-length mod ] keep vector-nth
        ] ifte
    ] with-pixels ; compiled

: mandel ( -- )
    640 480 32 SDL_HWSURFACE [
        [
            0.8 zoom-fact set
            -0.65 center set
            100 nb-iter set
            init-mandel
            [ render ] time
            "Done." print flush
        ] with-surface

        <event> event-loop
        SDL_Quit
    ] with-screen ;

mandel
