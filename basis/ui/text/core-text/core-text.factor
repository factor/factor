! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs accessors alien core-graphics.types core-text
core-text.fonts kernel hashtables namespaces sequences ui.text
ui.text.private destructors combinators core-foundation
core-foundation.strings math math.vectors init colors
colors.constants cache arrays images ;
IN: ui.text.core-text

SINGLETON: core-text-renderer

M: core-text-renderer string-dim
    [ " " string-dim { 0 1 } v* ]
    [ cached-line dim>> ]
    if-empty ;

M: core-text-renderer flush-layout-cache
    cached-lines get-global purge-cache ;

M: core-text-renderer string>image ( font string -- image loc )
    cached-line [ line>image ] [ loc>> ] bi ;

M: core-text-renderer x>offset ( x font string -- n )
    [ 2drop 0 ] [
        cached-line line>>
        swap 0 <CGPoint> CTLineGetStringIndexForPosition
    ] if-empty ;

M: core-text-renderer offset>x ( n font string -- x )
    cached-line line>> swap f
    CTLineGetOffsetForStringIndex ;

M: core-text-renderer font-metrics ( font -- metrics )
    cache-font-metrics ;

M: core-text-renderer line-metrics ( font string -- metrics )
    [ " " line-metrics clone 0 >>width ]
    [ cached-line metrics>> ]
    if-empty ;

core-text-renderer font-renderer set-global
