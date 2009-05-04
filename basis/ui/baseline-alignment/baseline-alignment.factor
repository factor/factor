! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel locals math math.functions math.order math.vectors
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

: ?supremum ( seq -- n/f )
    sift [ f ] [ supremum ] if-empty ;

: max-ascent ( seq -- n )
    [ ascent>> ] map ?supremum ;

: max-cap-height ( seq -- n )
    [ cap-height>> ] map ?supremum ;

: max-descent ( seq -- n )
    [ descent>> ] map ?supremum ;

: max-text-height ( seq -- y )
    [ ascent>> ] filter [ height>> ] map ?supremum ;

: max-graphics-height ( seq -- y )
    [ ascent>> not ] filter [ height>> ] map ?supremum 0 or ;

:: combine-metrics ( graphics-height ascent descent cap-height -- ascent' descent' )
    ascent [
        cap-height 2 / :> mid-line 
        graphics-height 2 /
        [ ascent mid-line - max mid-line + floor >integer ]
        [ descent mid-line + max mid-line - ceiling >integer ] bi
    ] [ f f ] if ;

: (measure-metrics) ( children sizes -- graphics-height ascent descent cap-height )
    [ <gadget-metrics> ] 2map
    {
        [ max-graphics-height ]
        [ max-ascent ]
        [ max-descent ]
        [ max-cap-height ]
    } cleave ;

PRIVATE>

:: align-baselines ( gadgets -- ys )
    gadgets [ dup pref-dim <gadget-metrics> ] map
    dup max-ascent 0 or :> max-ascent
    dup max-cap-height 0 or :> max-cap-height
    dup max-graphics-height :> max-graphics-height
    
    max-cap-height max-graphics-height + 2 /i :> critical-line
    critical-line max-ascent [-] :> text-leading
    max-ascent critical-line [-] :> graphics-leading

    [
        dup ascent>>
        [ ascent>> max-ascent swap - text-leading ]
        [ height>> max-graphics-height swap - 2/ graphics-leading ] if +
    ] map ;

: measure-metrics ( children sizes -- ascent descent )
    (measure-metrics) combine-metrics ;

: measure-height ( children sizes -- height )
    (measure-metrics) dup [ combine-metrics + ] [ 3drop ] if ;