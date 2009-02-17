! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel locals math math.order math.vectors
sequences ui.gadgets accessors combinators ;
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

: max-cap-height ( seq -- n )
    0 [ cap-height>> [ max ] when* ] reduce ; inline

: max-descent ( seq -- n )
    0 [ descent>> [ max ] when* ] reduce ; inline

: max-text-height ( seq -- y )
    0 [ [ height>> ] [ ascent>> ] bi [ max ] [ drop ] if ] reduce ;

: max-graphics-height ( seq -- y )
    0 [ [ height>> ] [ ascent>> ] bi [ drop ] [ max ] if ] reduce ;

: (align-baselines) ( y max leading -- y' ) [ swap - ] dip + ;

:: combine-metrics ( graphics-height ascent descent cap-height -- ascent' descent' )
    cap-height 2 / :> mid-line 
    graphics-height 2 /
    [ ascent mid-line - max mid-line + >integer ]
    [ descent mid-line + max mid-line - >integer ] bi ;

PRIVATE>

:: align-baselines ( gadgets -- ys )
    gadgets [ dup pref-dim <gadget-metrics> ] map
    dup max-ascent :> max-ascent
    dup max-cap-height :> max-cap-height
    dup max-graphics-height :> max-graphics-height
    
    max-cap-height max-graphics-height + 2 /i :> critical-line
    critical-line max-ascent [-] :> text-leading
    max-ascent critical-line [-] :> graphics-leading

    [
        dup ascent>>
        [ ascent>> max-ascent text-leading ]
        [ height>> max-graphics-height graphics-leading ] if
        (align-baselines)
    ] map ;

: measure-metrics ( children sizes -- ascent descent )
    [ <gadget-metrics> ] 2map
    {
        [ max-graphics-height ]
        [ max-ascent ]
        [ max-descent ]
        [ max-cap-height ]
    } cleave
    combine-metrics ;

: measure-height ( children sizes -- height )
    measure-metrics + ;