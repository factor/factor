IN: scratchpad
USING: alien compiler kernel parser sequences words ;

"X11" "libX11" add-simple-library

{ 
    "xlib"
    "x"
    "rectangle"
    "draw-string"
    "concurrent-widgets"
    "glx"
    "gl"    
} [ "/contrib/x11/" swap ".factor" append3 run-resource ] each

! { "xlib" "x11" } [ words [ try-compile ] each ] each
