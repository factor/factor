USING: kernel parser words compiler sequences ;

{
    "xlib" "x" "rectangle" "draw-string"
    "concurrent-widgets" "glx"  "gl"
} [ "/contrib/x11/" swap ".factor" append3 run-resource ] each

{ "xlib" "x11" } [ words [ try-compile ] each ] each