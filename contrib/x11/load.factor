
USING: kernel parser words compiler sequences ;

"./xlib.factor" run-file
"xlib" words [ try-compile ] each
clear

"./x.factor" run-file