! SDL backend for cairo
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

IN: cairo-sdl
USING: hashtables ;
USE: compiler
USE: alien
USE: errors
USE: kernel
USE: lists
USE: math
USE: namespaces
USE: sdl
USE: vectors
USE: prettyprint
USE: io
USE: test
USE: syntax
USE: sequences
USE: cairo

SYMBOL: cr

: set-up-cairo ( -- )
	surface get surface-pixels		! get pointer to pixel data
	CAIRO_FORMAT_ARGB32			! only in argb32-mode both SDL and cairo agree on the pixel format
	surface get [ surface-w ] keep		! get surface width, keep it
	surface-h over 4 *			! get surface height (keep it) and calculate stride from the width
	cairo_image_surface_create_for_data
	cairo_create
	cr set ;
