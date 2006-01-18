IN: scratchpad
USING: kernel parser words compiler sequences ;

"X11" "libX11" add-simple-library

{ 
    "xlib"
    "x"
    "rectangle"
    "draw-string"
    "concurrent-widgets"
    "glx"
    "gl"    
} [ "contrib/x11/" swap ".factor" append3 run-file ] each

{ "xlib" "x11" } [ words [ try-compile ] each ] each
