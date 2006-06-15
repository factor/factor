IN: scratchpad
USING: alien kernel parser compiler words sequences ;

"cairo" "libcairo" add-simple-library

"/contrib/cairo/cairo.factor" run-resource

{ "cairo" } compile-vocabs
