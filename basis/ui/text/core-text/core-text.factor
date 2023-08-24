! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors cache core-graphics.types core-text
core-text.fonts io.encodings.string io.encodings.utf16 kernel
math math.vectors namespaces opengl sequences ui.text
ui.text.private ;
IN: ui.text.core-text
SINGLETON: core-text-renderer

<PRIVATE

: scale-dim ( dim -- dim' )
    gl-scale-factor get-global [ [ gl-unscale ] map ] when ; inline

: scale-metrics ( metrics -- metrics' )
    gl-scale-factor get-global [
        clone
            [ gl-unscale ] change-width
            [ gl-unscale ] change-ascent
            [ gl-unscale ] change-descent
            [ gl-unscale ] change-height
            [ gl-unscale ] change-leading
            [ gl-unscale ] change-cap-height
            [ gl-unscale ] change-x-height
    ] when ; inline

PRIVATE>

M: core-text-renderer string-dim
    [ " " string-dim { 0 1 } v* ]
    [ cached-line dim>> scale-dim ]
    if-empty ;

M: core-text-renderer flush-layout-cache
    cached-lines get-global purge-cache ;

M: core-text-renderer string>image
    cached-line [ line>image ] [ loc>> scale-dim ] bi ;

M:: core-text-renderer x>offset ( x font string -- n )
    x font string
    [ 2drop 0 ] [
        cached-line line>>
        swap gl-scale 0 <CGPoint> CTLineGetStringIndexForPosition
        2 * 0 swap string utf16n encode subseq
        utf16n decode length
    ] if-empty ;

M:: core-text-renderer offset>x ( n font string -- x )
    font string cached-line line>>
    0 n string subseq utf16n encode length 2 /i
    f
    CTLineGetOffsetForStringIndex gl-unscale ;

M: core-text-renderer font-metrics
    cache-font-metrics ;

M: core-text-renderer line-metrics
    [ " " line-metrics clone 0 >>width ]
    [ cached-line metrics>> scale-metrics ]
    if-empty ;

core-text-renderer font-renderer set-global
