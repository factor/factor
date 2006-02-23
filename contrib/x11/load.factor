USING: kernel parser words compiler sequences ;

{
    "rectangle" "xlib" "x" "draw-string"
    "concurrent-widgets" "glx"  "gl"
} [ "/contrib/x11/" swap ".factor" append3 run-resource ] each

{ "xlib" "x11" } [ words [ try-compile ] each ] each