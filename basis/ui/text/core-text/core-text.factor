! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors cache core-graphics.types core-text
core-text.fonts io.encodings.string io.encodings.utf16n kernel
locals math math.vectors namespaces sequences ui.text
ui.text.private ;
IN: ui.text.core-text

SINGLETON: core-text-renderer

<PRIVATE

: unscale ( m -- n )
    retina? get-global [ 2.0 / ] when ; inline

: scale ( m -- n )
    retina? get-global [ 2.0 * ] when ; inline

: scale-dim ( dim -- dim' )
    retina? get-global [ [ 2.0 / ] map ] when ; inline

: scale-metrics ( metrics -- metrics' )
    retina? get-global [
        clone
            [ 2.0 / ] change-width
            [ 2.0 / ] change-ascent
            [ 2.0 / ] change-descent
            [ 2.0 / ] change-height
            [ 2.0 / ] change-leading
            [ 2.0 / ] change-cap-height
            [ 2.0 / ] change-x-height
    ] when ; inline

PRIVATE>

M: core-text-renderer string-dim
    [ " " string-dim { 0 1 } v* ]
    [ cached-line dim>> scale-dim ]
    if-empty ;

M: core-text-renderer flush-layout-cache
    cached-lines get-global purge-cache ;

M: core-text-renderer string>image ( font string -- image loc )
    cached-line [ line>image ] [ loc>> scale-dim ] bi ;

M:: core-text-renderer x>offset ( x font string -- n )
    x font string
    [ 2drop 0 ] [
        cached-line line>>
        swap scale 0 <CGPoint> CTLineGetStringIndexForPosition
    ] if-empty
    2 * 0 swap string utf16n encode subseq
    utf16n decode length ;

M:: core-text-renderer offset>x ( n font string -- x )
    font string cached-line line>> 
    0 n string subseq utf16n encode length 2 / >integer
    f
    CTLineGetOffsetForStringIndex unscale ;

M: core-text-renderer font-metrics ( font -- metrics )
    cache-font-metrics ;

M: core-text-renderer line-metrics ( font string -- metrics )
    [ " " line-metrics clone 0 >>width ]
    [ cached-line metrics>> scale-metrics ]
    if-empty ;

core-text-renderer font-renderer set-global
