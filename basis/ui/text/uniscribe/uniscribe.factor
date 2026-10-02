! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors cache destructors fonts fonts.shaping kernel locals math
math.order math.vectors namespaces opengl sequences ui.text
ui.text.private windows.uniscribe ;
FROM: windows.uniscribe.private => <script-string> ;
IN: ui.text.uniscribe

SINGLETON: uniscribe-renderer

M: uniscribe-renderer draws-selection-background? t ;

M: uniscribe-renderer string-dim
    cached-script-string size>> scale-dim ;

M: uniscribe-renderer measure-string-dim
    [ <script-string> &dispose size>> scale-dim ] with-destructors ;

M: uniscribe-renderer flush-layout-cache
    cached-script-strings get-global purge-cache ;

M: uniscribe-renderer string>image
    cached-script-string
    [ script-string>image ] [ origin>> { 0 0 } or scale-dim vneg ] bi ;

M: uniscribe-renderer x>offset
    [ gl-scale ] 2dip cached-script-string x>line-caret drop ;

M: uniscribe-renderer offset>x
    cached-script-string line-offset>x gl-unscale ;

M: uniscribe-renderer caret>x
    cached-script-string line-caret>x gl-unscale ;

M: uniscribe-renderer x>caret
    [ gl-scale ] 2dip cached-script-string x>line-caret ;

M:: uniscribe-renderer visual-caret-step ( n trailing? direction font string -- next affinity moved? )
    string aux>> font font-text-direction right-to-left = or [
        n trailing? direction font string cached-script-string uniscribe-visual-step
    ] [ n trailing? direction string logical-caret-step ] if ;

M:: uniscribe-renderer visual-caret-edge ( right? font string -- n trailing? )
    font string cached-script-string :> layout
    right? [ layout size>> first 1 + ] [ -1 ] if layout x>line-caret ;

M:: uniscribe-renderer selection-spans ( start end font string -- spans )
    font string start end f <selection> cached-script-string
    uniscribe-selection-spans [ [ gl-unscale ] map ] map ;

M:: uniscribe-renderer selection-caret ( start end right? font string -- n trailing? )
    start end font string selection-spans :> spans
    spans empty? [ start f ] [
        right? [ spans [ second ] map supremum ]
        [ spans [ first ] map infimum ] if font string x>caret
    ] if ;

M: uniscribe-renderer font-metrics
    " " cached-script-string metrics>> clone scale-metrics f >>width ;

M: uniscribe-renderer line-metrics
    cached-script-string metrics>> clone scale-metrics ;

uniscribe-renderer font-renderer set-global
