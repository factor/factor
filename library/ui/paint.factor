! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: alien arrays gadgets-layouts generic hashtables io kernel
lists math matrices namespaces sdl sequences strings styles
vectors ;

SYMBOL: clip

: >sdl-rect ( rectangle -- sdlrect )
    [ rect-loc first2 ] keep rect-dim first2 make-rect ;

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
    ] [ drop ] if ;

: paint-prop* ( gadget key -- value ) swap gadget-paint ?hash ;

: paint-prop ( gadget key -- value )
    over [
        2dup paint-prop* dup
        [ 2nip ] [ drop >r gadget-parent r> paint-prop ] if
    ] [
        2drop f
    ] if ;

: init-paint ( gadget -- gestures )
    dup gadget-paint
    [ ] [ {{ }} clone dup rot set-gadget-paint ] ?if ;

: set-paint-prop ( gadget value key -- )
    rot init-paint set-hash ;

: add-paint ( gadget hash -- )
    dup [ >r init-paint r> hash-update ] [ 2drop ] if ;

: fg ( gadget -- color )
    dup reverse-video paint-prop
    background foreground ? paint-prop ;

: bg ( gadget -- color )
    dup reverse-video paint-prop [
        foreground
    ] [
        dup rollover paint-prop rollover-bg background ?
    ] if paint-prop ;

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
    [ first2 ] 2apply [ 1 - ] 2apply ;

! Solid pen
M: solid draw-interior
    drop >r surface get r> [ rect>screen ] keep bg rgb boxColor ;

M: solid draw-boundary
    drop >r surface get r> [ rect>screen ] keep
    fg rgb rectangleColor ;

! Rollover only
TUPLE: rollover-only ;

C: rollover-only << solid >> over set-delegate ;

M: rollover-only draw-interior ( gadget interior -- )
    over rollover paint-prop
    [ delegate draw-interior ] [ 2drop ] if ;

M: rollover-only draw-boundary ( gadget boundary -- )
    over rollover paint-prop
    [ delegate draw-boundary ] [ 2drop ] if ;

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
    swap rect-dim @{ 1 1 1 }@ vmax
    over gradient-vector @{ 1 0 0 }@ =
    [ horiz-gradient ] [ vert-gradient ] if ;

! Bevel pen
TUPLE: bevel width ;

: x1/x2/y1 ( vector vector -- surface n n n )
    surface get -rot >r first2 r> first swap ;
: x1/x2/y2 ( vector vector -- surface n n n )
    surface get -rot >r first r> first2 ;
: x1/y1/y2 ( vector vector -- surface n n n )
    surface get -rot >r first2 r> second ;
: x2/y1/y2 ( vector vector -- surface n n n )
    surface get -rot >r second r> first2 swapd ;

SYMBOL: bevel-1
SYMBOL: bevel-2

: bevel-color ( gadget ? -- rgb )
    >r dup reverse-video paint-prop bevel-1 bevel-2
    r> [ swap ] when ? paint-prop rgb ;

: draw-bevel ( v1 v2 gadget -- )
    [ >r x1/x2/y1 r> f bevel-color hlineColor ] 3keep
    [ >r x1/x2/y2 r> t bevel-color hlineColor ] 3keep
    [ >r x1/y1/y2 r> f bevel-color vlineColor ] 3keep
    >r x2/y1/y2 r> t bevel-color vlineColor ;

M: bevel draw-boundary ( gadget boundary -- )
    #! Ugly code.
    bevel-width [
        >r origin get over rect-dim over v+ r>
        @{ 1 1 0 }@ n*v tuck v- @{ 1 1 0 }@ v- >r v+ r>
        rot draw-bevel
    ] each-with ;

M: gadget draw-gadget* ( gadget -- )
    dup
    dup interior paint-prop* draw-interior
    dup boundary paint-prop* draw-boundary ;

! Polygon pen
TUPLE: polygon points ;

: >short-array ( seq -- short-array )
    dup length <short-array> over length [
        [ tuck >r >r swap nth r> r> swap set-short-nth ] 3keep
    ] repeat nip ;

: polygon-x/y ( gadget polygon -- vx vy n )
    polygon-points [
        swap rect-dim over max-dim v- 2 v/n origin get v+
        swap [ v+ ] map-with
        dup [ first ] map swap [ second ] map
        [ >short-array ] 2apply
    ] keep length ;

: (polygon) ( gadget polygon -- surface vx vy n gadget )
    over >r surface get -rot polygon-x/y r> ;

M: polygon draw-boundary ( gadget polygon -- )
    (polygon) fg rgb polygonColor ;

M: polygon draw-interior ( gadget polygon -- )
    (polygon) bg rgb filledPolygonColor ;

: arrow-up    @{ @{ 3 0 0 }@ @{ 6 6 0 }@ @{ 0 6 0 }@ }@ ;
: arrow-right @{ @{ 0 0 0 }@ @{ 6 3 0 }@ @{ 0 6 0 }@ }@ ;
: arrow-down  @{ @{ 0 0 0 }@ @{ 6 0 0 }@ @{ 3 6 0 }@ }@ ;
: arrow-left  @{ @{ 0 3 0 }@ @{ 6 0 0 }@ @{ 6 6 0 }@ }@ ;

: arrow-right|
    @{
        @{ 0 0 0 }@ @{ 0 6 0 }@ @{ 6 3 0 }@
        @{ 6 6 0 }@ @{ 6 0 0 }@ @{ 6 3 0 }@
    }@ ;

: arrow-|left
    @{
        @{ 6 0 0 }@ @{ 6 6 0 }@ @{ 0 3 0 }@
        @{ 0 6 0 }@ @{ 0 0 0 }@ @{ 0 3 0 }@
    }@ ;

: <polygon-gadget> ( points -- gadget )
    dup max-dim @{ 1 1 0 }@ v+
    >r <polygon> <gadget> r> over set-rect-dim
    dup rot interior set-paint-prop ;
