! DeJong attractor renderer.
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
! "examples/dejong.factor" run-file

! For details on DeJong attractors, see
! http://www.complexification.net/gallery/machines/peterdejong/

IN: dejong

USE: sdl
USE: sdl-event
USE: sdl-gfx
USE: sdl-video
USE: namespaces
USE: math
USE: kernel
USE: test
USE: compiler

SYMBOL: a
SYMBOL: b
SYMBOL: c
SYMBOL: d

: next-x ( x y -- x ) a get * sin swap b get * cos - ;
: next-y ( x y -- y ) swap c get * sin swap d get * cos - ;

: white ( -- rgb )
    HEX: ffffffff ;

: pixel ( #{ x y }# color -- )
    >r >r surface get r> >rect r> pixelColor ;

: iterate-dejong ( x y -- x y )
    2dup next-y >r next-x r> ;

: scale-dejong ( x y -- x y )
    swap width get 4 / * width get 2 / + >fixnum
    swap height get 4 / * height get 2 / + >fixnum ;

: draw-dejong ( x0 y0 iterations -- )
    [
        iterate-dejong 2dup scale-dejong rect> white pixel
    ] times 2drop ;

: dejong ( -- )
    ! Fiddle with these four values!
    1.4 a set
    -2.3 b set
    2.4 c set
    -2.1 d set

    640 480 32 SDL_HWSURFACE [
        [ 0 0 100000 draw-dejong ] with-surface

        <event> event-loop
        SDL_Quit
    ] with-screen ; compiled

[ dejong ] time
