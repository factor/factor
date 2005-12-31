USING: kernel alien parser sequences words compiler ;

"X11" "libX11.so" "cdecl" add-library

[ "x-constants.factor" "xlib.factor" "keysymdef.factor" "x-events.factor" "glx.factor" ] [ "contrib/x11/" swap append run-file ] each

"x11" words [ try-compile ] each
"xlib" words [ try-compile ] each
clear
