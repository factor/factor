! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel locals math math.order math.vectors
sequences ui.gadgets accessors ;
IN: ui.baseline-alignment

SYMBOL: +baseline+

GENERIC: baseline ( gadget -- y )

M: gadget baseline drop f ;

GENERIC: cap-height ( gadget -- y )

M: gadget cap-height drop f ;

<PRIVATE

! Text has ascent/descent/cap-height slots, graphics does not.
TUPLE: gadget-metrics height ascent descent cap-height ;

: <gadget-metrics> ( gadget dim -- metrics )
    second swap [ baseline ] [ cap-height ] bi
    [ dup [ 2dup - ] [ f ] if ] dip
    gadget-metrics boa ; inline

: max-ascent ( seq -- n )
    0 [ ascent>> [ max ] when* ] reduce ; inline

: max-descent ( seq -- n )
    0 [ descent>> [ max ] when* ] reduce ; inline

: max-text-height ( seq -- y )
    0 [ [ height>> ] [ ascent>> ] bi [ max ] [ drop ] if ] reduce ;

: max-graphics-height ( seq -- y )
    0 [ [ height>> ] [ ascent>> ] bi [ drop ] [ max ] if ] reduce ;

: combine-metrics ( graphics-height ascent descent -- ascent' descent' )
    [ [ [-] 2 /i ] keep ] dip [ + ] [ max ] bi-curry* bi ;

PRIVATE>

:: align-baselines ( gadgets -- ys )
    gadgets [ dup pref-dim <gadget-metrics> ] map
    dup max-ascent :> max-ascent
    dup max-graphics-height :> max-height
    max-height max-ascent [-] 2 /i :> offset-text
    max-ascent max-height [-] 2 /i :> offset-graphics
    [
        dup ascent>> [
            ascent>>
            max-ascent
            offset-text
        ] [
            height>>
            max-height
            offset-graphics
        ] if [ swap - ] dip +
    ] map ;

: measure-metrics ( children sizes -- ascent descent )
    [ <gadget-metrics> ] 2map
    [ max-graphics-height ] [ max-ascent ] [ max-descent ] tri
    combine-metrics ;

: measure-height ( children sizes -- height )
    measure-metrics + ;