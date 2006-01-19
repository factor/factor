IN: scratchpad
USING: alien kernel parser compiler words sequences ;

{ { "cairo" "libcairo" }
  { "sdl-gfx" "libSDL_gfx" }
  { "sdl" "libSDL" } }
[ first2 add-simple-library ] each

{ "cairo" "cairo_sdl" }
[ "contrib/cairo/" swap ".factor" append3 run-file ] each

{ "cairo" "cairo-sdl" }
[ words [ try-compile ] each ] each
