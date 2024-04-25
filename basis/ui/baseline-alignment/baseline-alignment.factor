! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel locals math math.functions
math.order sequences ui.gadgets ;
IN: ui.baseline-alignment

SYMBOL: +baseline+

TUPLE: aligned-gadget < gadget baseline cap-height ;

GENERIC: baseline* ( gadget -- y )

GENERIC: baseline ( gadget -- y )

M: gadget baseline drop f ;

M: aligned-gadget baseline
    [ baseline>> ] [
        [ baseline* ] [ ] [ layout-state>> ] tri
        [ drop ] [ dupd baseline<< ] if
    ] ?unless ;

GENERIC: cap-height* ( gadget -- y )

GENERIC: cap-height ( gadget -- y )

M: gadget cap-height drop f ;

M: aligned-gadget cap-height
    [ cap-height>> ] [
        [ cap-height* ] [ ] [ layout-state>> ] tri
        [ drop ] [ dupd cap-height<< ] if
    ] ?unless ;

<PRIVATE

! Text has ascent/descent/cap-height slots, graphics does not.
TUPLE: gadget-metrics height ascent descent cap-height ;

: <gadget-metrics> ( gadget dim -- metrics )
    second swap [ baseline ] [ cap-height ] bi
    [ dup [ 2dup - ] [ f ] if ] dip
    gadget-metrics boa ; inline

: ?maximum ( seq -- n/f )
    sift [ f ] [ maximum ] if-empty ;

: max-ascent ( seq -- n/f )
    [ ascent>> ] map ?maximum ;

: max-cap-height ( seq -- n/f )
    [ cap-height>> ] map ?maximum ;

: max-descent ( seq -- n/f )
    [ descent>> ] map ?maximum ;

: max-graphics-height ( seq -- n )
    [ ascent>> ] reject [ height>> ] map ?maximum 0 or ;

:: combine-metrics ( graphics-height ascent descent cap-height -- ascent' descent' )
    ascent [
        cap-height 0 or 2 / :> mid-line
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
        [ height>> max-graphics-height swap - 2 /i graphics-leading ] if +
    ] map ;

: measure-metrics ( children sizes -- ascent descent )
    (measure-metrics) combine-metrics ;

: measure-height ( children sizes -- height )
    (measure-metrics) [ combine-metrics + ] [ 2drop ] if* ;

: measure-height-metrics ( children sizes -- height ascent descent )
    (measure-metrics) [ dup ] 3dip
    [ combine-metrics ] keep [ [ + nip ] 2keep ] when ;
