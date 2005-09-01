! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic hashtables io kernel lists math matrices
namespaces sdl sequences strings styles vectors ;

SYMBOL: clip

: >sdl-rect ( rectangle -- sdlrect )
    [ rect-loc 2unseq ] keep rect-dim 2unseq make-rect ;

: set-clip ( rect -- )
    #! The top/left corner of the clip rectangle is the location
    #! of the gadget on the screen. The bottom/right is the
    #! intersected clip rectangle.
    surface get swap >sdl-rect SDL_SetClipRect drop ;

: visible-children ( gadget -- seq ) clip get swap children-on ;

GENERIC: draw-gadget* ( gadget -- )

: do-clip ( gadget -- )
    >absolute clip [ intersect dup ] change set-clip ;

: draw-gadget ( gadget -- )
    clip get over inside? [
        [
            dup do-clip dup translate dup draw-gadget*
            visible-children [ draw-gadget ] each
        ] with-scope
    ] [ drop ] ifte ;

: paint-prop* ( gadget key -- value ) swap gadget-paint ?hash ;

: paint-prop ( gadget key -- value )
    over [
        2dup paint-prop* dup
        [ 2nip ] [ drop >r gadget-parent r> paint-prop ] ifte
    ] [
        2drop f
    ] ifte ;

: set-paint-prop ( gadget value key -- )
    pick gadget-paint ?set-hash swap set-gadget-paint ;

: fg ( gadget -- color )
    dup reverse-video paint-prop
    background foreground ? paint-prop ;

: bg ( gadget -- color )
    dup reverse-video paint-prop [
        foreground
    ] [
        dup rollover paint-prop rollover-bg background ?
    ] ifte paint-prop ;

! Pen paint properties
SYMBOL: interior
SYMBOL: boundary

GENERIC: draw-interior ( gadget interior -- )
GENERIC: draw-boundary ( gadget boundary -- )

M: f draw-interior 2drop ;
M: f draw-boundary 2drop ;

! Solid fill/border
TUPLE: solid ;

: rect>screen ( shape -- x1 y1 x2 y2 )
    >r origin get dup r> rect-dim v+
    >r 2unseq r> 2unseq >r 1 - r> 1 - ;

! Solid pen
M: solid draw-interior
    drop >r surface get r> [ rect>screen ] keep bg rgb boxColor ;

M: solid draw-boundary
    drop >r surface get r> [ rect>screen ] keep
    fg rgb rectangleColor ;

! Rollover only
TUPLE: rollover-only ;

C: rollover-only << solid f >> over set-delegate ;

M: rollover-only draw-interior ( gadget interior -- )
    over rollover paint-prop
    [ delegate draw-interior ] [ 2drop ] ifte ;

M: rollover-only draw-boundary ( gadget boundary -- )
    over rollover paint-prop
    [ delegate draw-boundary ] [ 2drop ] ifte ;

! Gradient pen
TUPLE: gradient vector from to ;

: gradient-color ( gradient prop -- color )
    over gradient-from 1 pick - v*n
    >r swap gradient-to n*v r> v+ ;

: (gradient-x) ( gradient dim y -- x1 x2 y color )
    dup pick second / >r rot r> gradient-color >r
    >r >r origin get first r> origin get v+ first
    r> origin get second + r> ;

: gradient-x ( gradient dim y -- )
    >r >r >r surface get r> r> r> (gradient-x) rgb hlineColor ;

: vert-gradient ( gradient dim -- )
    dup second [ 3dup gradient-x ] repeat 2drop ;

: (gradient-y) ( gradient dim x -- x y1 y2 color )
    dup pick first / >r rot r> gradient-color
    >r origin get first + origin get second rot
    origin get v+ second r> ;

: gradient-y ( gradient dim x -- )
    >r >r >r surface get r> r> r> (gradient-y) rgb vlineColor ;

: horiz-gradient ( gradient dim -- )
    dup first [ 3dup gradient-y ] repeat 2drop ;

M: gradient draw-interior ( gadget gradient -- )
    swap rect-dim { 1 1 1 } vmax
    over gradient-vector { 1 0 0 } =
    [ horiz-gradient ] [ vert-gradient ] ifte ;

! Bevel pen
TUPLE: bevel width ;

: x1/x2/y1 surface get pick pick >r 2unseq r> first swap ;
: x1/x2/y2 surface get pick pick >r first r> 2unseq ;
: x1/y1/y2 surface get pick pick >r 2unseq r> second ;
: x2/y1/y2 surface get pick pick >r second r> 2unseq swapd ;

SYMBOL: bevel-1
SYMBOL: bevel-2

: bevel-up ( gadget -- rgb )
    dup reverse-video paint-prop bevel-1 bevel-2 ? paint-prop rgb ;

: bevel-down ( gadget -- rgb )
    dup reverse-video paint-prop bevel-2 bevel-1 ? paint-prop rgb ;

: draw-bevel ( v1 v2 gadget -- )
    [ >r x1/x2/y1 r> bevel-up   hlineColor ] keep
    [ >r x1/x2/y2 r> bevel-down hlineColor ] keep
    [ >r x1/y1/y2 r> bevel-up   vlineColor ] keep
    [ >r x2/y1/y2 r> bevel-down vlineColor ] keep
    3drop ;

M: bevel draw-boundary ( gadget boundary -- )
    #! Ugly code.
    bevel-width [
        >r origin get over rect-dim over v+ r>
        { 1 1 0 } n*v tuck v- { 1 1 0 } v- >r v+ r>
        rot draw-bevel
    ] each-with ;

M: gadget draw-gadget* ( gadget -- )
    dup
    dup interior paint-prop* draw-interior
    dup boundary paint-prop* draw-boundary ;

: <plain-gadget> ( -- gadget )
    <gadget> dup << solid f >> interior set-paint-prop ;

: <etched-gadget> ( -- gadget )
    <plain-gadget> dup << solid f >> boundary set-paint-prop ;

: <bevel-gadget> ( -- gadget )
    <plain-gadget> dup << bevel f 2 >> boundary set-paint-prop ;

: draw-line ( from to color -- )
    >r >r >r surface get r> 2unseq r> 2unseq r> rgb lineColor ;

: draw-fanout ( from tos color -- )
    -rot [ >r 2dup r> rot draw-line ] each 2drop ;
