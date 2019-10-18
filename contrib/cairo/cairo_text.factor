! A bit more complex cairo example
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
! "contrib/cario" require
! "cairo_text.factor" run-file

IN: cairo-text
SYMBOL: angle

USING: cairo cairo-sdl compiler errors kernel namespaces sdl lists math sequences alien ;

: draw-rect ( angle -- )
	cr get
        [ cairo_identity_matrix ] keep
	[ 160.0 120.0 cairo_translate ] keep
	[ swap cairo_rotate ] keep
	[ 0.0 50.0 cairo_translate ] keep
	[ -10.0 -10.0 20.0 20.0 cairo_rectangle ] keep
        cairo_fill ;

: clear-surface ( -- )
	cr get
        [ cairo_identity_matrix ] keep
	[ 0.0 0.0 0.0 cairo_set_source_rgb ] keep
	[ 0.0 0.0 320.0 240.0 cairo_rectangle ] keep
	cairo_fill ;

: draw-fan ( -- )
	10 [
		cr get over
		10 / dup dup
		cairo_set_source_rgb
		3 / angle get +
		draw-rect
	] each ;

: draw-cairo-text ( -- )
	cr get
	[ cairo_identity_matrix ] keep
	[ 160 80.0 cairo_translate ] keep
	[ angle get sin 3 / cairo_rotate ] keep
	[ -60.0 25.0 cairo_translate ] keep
	[ 0.0 0.5 1.0 cairo_set_source_rgb ] keep
	[ "serif" CAIRO_FONT_SLANT_NORMAL CAIRO_FONT_WEIGHT_BOLD cairo_select_font_face ] keep
	[ 45.0 cairo_set_font_size ] keep
	[ "Cairo" cairo_text_path ] keep
	[ cairo_fill_preserve ] keep
	[ 0.0 0.4 0.8 cairo_set_source_rgb ] keep
	[ 2.0 cairo_set_line_width ] keep
	cairo_stroke ;

: draw-factor-text ( -- )
	cr get
	[ cairo_identity_matrix ] keep
	[ 85.0 140.0 cairo_translate ] keep
	"Factor" cairo_show_text ;
	


: redraw ( -- )
	clear-surface
	draw-fan
	draw-cairo-text
	draw-factor-text
	;


: event-loop ( event -- )
	angle [ 0.1 + ] change
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
	0 angle set

    320 240 32 SDL_HWSURFACE  [
		set-up-cairo
        	"event" <c-object> event-loop
	SDL_Quit
    ] with-screen ;

cairo-sdl-test
