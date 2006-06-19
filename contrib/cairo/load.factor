IN: scratchpad
USING: alien kernel parser compiler words sequences ;

"cairo" "libcairo" add-simple-library

PROVIDE: cairo { "/contrib/cairo/cairo.factor" } ;

{ "cairo" } compile-vocabs
