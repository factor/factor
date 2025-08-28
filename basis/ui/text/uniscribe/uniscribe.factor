! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors cache kernel math math.vectors namespaces
opengl sequences ui.text ui.text.private windows.uniscribe ;
IN: ui.text.uniscribe

SINGLETON: uniscribe-renderer

M: uniscribe-renderer string-dim
    [ " " string-dim { 0 1 } v* ]
    [ cached-script-string size>> scale-dim ] if-empty ;

M: uniscribe-renderer flush-layout-cache
    cached-script-strings get-global purge-cache ;

M: uniscribe-renderer string>image
    cached-script-string script-string>image { 0 0 } ;

M: uniscribe-renderer x>offset
    [ 2drop 0 ] [
        [ gl-scale ] 2dip cached-script-string x>line-offset 0 = [ 1 + ] unless
    ] if-empty ;

M: uniscribe-renderer offset>x
    [ 2drop 0 ] [ cached-script-string line-offset>x gl-unscale ] if-empty ;

M: uniscribe-renderer font-metrics
    " " cached-script-string metrics>> scale-metrics clone f >>width ;

M: uniscribe-renderer line-metrics
    [ " " line-metrics clone 0 >>width ]
    [ cached-script-string metrics>> scale-metrics 50 >>width 10 >>cap-height 10 >>x-height ]
    if-empty ;

uniscribe-renderer font-renderer set-global
