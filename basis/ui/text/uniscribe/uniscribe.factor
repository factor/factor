! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs cache kernel math math.vectors sequences fonts
namespaces opengl.textures ui.text ui.text.private ui.gadgets.worlds 
windows.uniscribe ;
IN: ui.text.uniscribe

SINGLETON: uniscribe-renderer

M: uniscribe-renderer string-dim
    [ " " string-dim { 0 1 } v* ]
    [ cached-script-string size>> ] if-empty ;

M: uniscribe-renderer flush-layout-cache
    cached-script-strings get purge-cache ;

: rendered-script-string ( font string -- texture )
    world get world-text-handle
    [ cached-script-string image>> { 0 0 } <texture> ]
    2cache ;

M: uniscribe-renderer draw-string ( font string -- )
    dup dup selection? [ string>> ] when empty?
    [ 2drop ] [ rendered-script-string draw-texture ] if ;

M: uniscribe-renderer x>offset ( x font string -- n )
    [ 2drop 0 ] [
        cached-script-string x>line-offset 0 = [ 1 + ] unless
    ] if-empty ;

M: uniscribe-renderer offset>x ( n font string -- x )
    [ 2drop 0 ] [ cached-script-string line-offset>x ] if-empty ;

M: uniscribe-renderer font-metrics ( font -- metrics )
    " " cached-script-string metrics>> clone f >>width ;

M: uniscribe-renderer line-metrics ( font string -- metrics )
    [ " " line-metrics clone 0 >>width ]
    [ cached-script-string metrics>> 50 >>width 10 >>cap-height 10 >>x-height ]
    if-empty ;

uniscribe-renderer font-renderer set-global
