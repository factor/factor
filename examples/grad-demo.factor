! Gradient rendering demo.
!
! To run this code, bootstrap Factor like so:
!
! ./f boot.image.le32
!     -libraries:sdl:name=libSDL.so
!     -libraries:sdl-gfx:name=libSDL_gfx.so
!     -libraries:sdl-ttf:name=libSDL_ttf.so
!
! (But all on one line)
!
! Then, start Factor as usual (./f factor.image) and enter this
! at the listener:
!
! "examples/grad-demo.factor" run-file

IN: grad-demo
USE: streams
USE: sdl
USE: sdl-event
USE: sdl-gfx
USE: sdl-video
USE: sdl-ttf
USE: namespaces
USE: math
USE: kernel
USE: test
USE: compiler
USE: strings
USE: alien
USE: prettyprint
USE: lists

: draw-grad ( -- )
    [ over rgb ] with-pixels ; compiled

: grad-demo ( -- )
    640 480 0 SDL_HWSURFACE [
        TTF_Init
        [ draw-grad ] with-surface
        <event> event-loop
        SDL_Quit
    ] with-screen ;

grad-demo
