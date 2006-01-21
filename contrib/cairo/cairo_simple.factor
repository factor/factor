! A simple cairo example
!
! To run this code, bootstrap Factor like so:
!
! ./f boot.image.le32
!     -libraries:sdl:name=libSDL.so
!     -libraries:sdl-gfx:name=libSDL_gfx
!     -libraries:cairo:name=libcairo
!
! (But all on one line)
!
! Then, start Factor as usual (./f factor.image) and enter these
! at the listener:
!
! "/contrib/cairo/load.factor" run-resource
! "cairo_simple.factor" run-file

IN: cairo-simple
USE: cairo
USE: cairo-sdl
USE: compiler
USE: errors
USE: kernel
USE: namespaces
USE: sdl
USE: alien

: redraw ( -- )
	cr get
        [ cairo_identity_matrix ] keep
	[ 0.0 0.1 0.8 cairo_set_source_rgb ] keep	! set blue color
	[ 130.0 90.0 60.0 60.0 cairo_rectangle ] keep	! draw a rectangle
        cairo_fill ;					! and fill it


: event-loop ( event -- )
	[ redraw ] with-surface
	dup SDL_PollEvent
	[
		dup event-type SDL_QUIT = [
			drop
		] [
			event-loop
		] if
    ] [
        event-loop
    ] if ;

: cairo-sdl-test ( -- )
    320 240 32 SDL_HWSURFACE  [
		set-up-cairo
        	"event" <c-object> event-loop
		cr get cairo_destroy
	SDL_Quit
    ] with-screen ;

cairo-sdl-test
