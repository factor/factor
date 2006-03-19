USING: kernel parser words compiler sequences ;

{
    "/library/x11/xlib.factor"
    "/library/x11/x.factor"
    "/library/x11/glx.factor"
    "/library/x11/constants.factor"
} [ run-resource ] each

{ "x11" } [ words [ try-compile ] each ] each