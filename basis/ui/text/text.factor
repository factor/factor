! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs cache combinators fonts kernel
locals math math.order namespaces opengl opengl.gl opengl.textures
sequences strings system ui.gadgets.worlds ui.render vocabs ;
IN: ui.text

<PRIVATE

: scale-dim ( dim -- dim' )
    gl-scale-factor get-global [ [ gl-unscale ] map ] when ; inline

: scale-metrics ( metrics -- metrics )
    gl-scale-factor get-global [
        [ dup [ gl-unscale ] when ] change-width
        [ dup [ gl-unscale ] when ] change-ascent
        [ dup [ gl-unscale ] when ] change-descent
        [ dup [ gl-unscale ] when ] change-height
        [ dup [ gl-unscale ] when ] change-leading
        [ dup [ gl-unscale ] when ] change-cap-height
        [ dup [ gl-unscale ] when ] change-x-height
    ] when ; inline

SYMBOL: font-renderer

: world-text-handle ( world -- handle )
    dup text-handle>> [ <cache-assoc> >>text-handle ] unless
    text-handle>> ;

HOOK: flush-layout-cache font-renderer ( -- )

[ flush-layout-cache ] flush-layout-cache-hook set-global

HOOK: string-dim font-renderer ( font string -- dim )

: string-width ( font string -- w ) string-dim first ; inline

: string-height ( font string -- h ) string-dim second ; inline

HOOK: free-fonts font-renderer ( world -- )

: combine-text-dim ( dim1 dim2 -- dim3 )
    [ first2 ] bi@ swapd [ max ] [ + ] 2bi* 2array ; inline

PRIVATE>

HOOK: x>offset font-renderer ( x font string -- n )

HOOK: offset>x font-renderer ( n font string -- x )

HOOK: selection-spans font-renderer ( start end font string -- spans )

M:: object selection-spans ( start end font string -- spans )
    start end [ font string offset>x ] bi@
    [ min ] [ max ] 2bi 2array 1array ;

GENERIC: text-dim ( font text -- dim )

M: string text-dim string-dim ;

M: array text-dim
    [ { 0 0 } ] 2dip [ string-dim combine-text-dim ] with each ;

: text-width ( font text -- w ) text-dim first ;

: text-height ( font text -- h ) text-dim second ;

HOOK: font-metrics font-renderer ( font -- metrics )

HOOK: line-metrics font-renderer ( font string -- metrics )

HOOK: string>image font-renderer ( font string -- image loc )

<PRIVATE

: string-empty? ( obj -- ? )
    dup selection? [ string>> ] when empty? ;

:: draw-string-gl3 ( font string -- )
    font string string>image :> ( image loc )
    image dim>> scale-dim :> dim
    image make-texture-gl3 :> tex-id
    loc dim tex-id image upside-down?>> gl3-draw-texture
    tex-id delete-texture ;

: draw-string-default ( font string -- )
    gl3-mode? get-global [
        draw-string-gl3
    ] [
        world get world-text-handle
        [ string>image <texture> ] 2cache
        draw-texture
    ] if ;

HOOK: draw-string* font-renderer ( font string -- )

M: object draw-string* draw-string-default ;

: draw-string ( font string -- )
    dup string-empty? [ 2drop ] [ draw-string* ] if ;

:: draw-selection-rects ( spans color y height -- )
    color gl-color
    spans [
        [ gl-round ] map first2 :> ( left right )
        left y 2array right left - 1 max height 2array gl-fill-rect
    ] each ;

HOOK: draw-selected-string font-renderer ( font selection height -- )

:: draw-selected-string-default ( font selection height -- )
    selection [ start>> ] [ end>> ] [ string>> ] tri :> ( start end string )
    start end font string selection-spans selection color>> 0 height draw-selection-rects
    font selection draw-string ;

M: object draw-selected-string draw-selected-string-default ;

PRIVATE>

GENERIC: draw-text ( font text -- )

M: string draw-text draw-string ;

M: selection draw-text draw-string ;

M: array draw-text
    '[
        _ _ [
            [ draw-string ]
            [ string-height 0.0 swap 2array gl-translate ] 2bi
        ] with each
    ] with-matrix ;

{
    { [ os macos? ] [ "ui.text.core-text" ] }
    { [ os windows? ] [ "ui.text.directwrite" ] }
    { [ os unix? ] [ "ui.text.pango" ] }
} cond require
