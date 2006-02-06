USING: kernel parser words compiler sequences ;

"xlib.factor" run-file "xlib" words [ try-compile ] each

"x.factor" run-file

"rectangle.factor" run-file

"draw-string.factor" run-file

"concurrent-widgets.factor" run-file

"glx.factor" run-file "x11" words [ try-compile ] each

"gl.factor" run-file