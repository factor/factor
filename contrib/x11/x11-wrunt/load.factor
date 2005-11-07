USING: kernel alien parser sequences words compiler ;

"X11" "libX11.so" "cdecl" add-library

[ "x.factor" "xlib.factor" "xutil.factor" "keysymdef.factor" "x-events.factor" 
  "glx.factor" "lesson2.factor" ] [ "contrib/x11/x11-wrunt/" swap append run-file ] each

"x11" words [ try-compile ] each

