! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
USING: alien arrays freetype gadgets-layouts generic hashtables
io kernel lists math namespaces opengl sdl sequences strings
styles vectors ;
IN: gadgets

SYMBOL: clip

: visible-children ( gadget -- seq ) clip get swap children-on ;

GENERIC: draw-gadget* ( gadget -- )

: do-clip ( gadget -- )
    >absolute clip [ intersect dup ] change
    dup rect-loc swap rect-dim gl-set-clip ;

: with-translation ( gadget quot -- | quot: gadget -- )
    GL_MODELVIEW [
        >r dup rect-loc dup translate first3 glTranslated
        r> call
    ] do-matrix ; inline

: draw-gadget ( gadget -- )
    clip get over inside? [
        [
            dup do-clip [
                dup draw-gadget*
                visible-children [ draw-gadget ] each
            ] with-translation
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
    drop dup bg gl-color rect-dim gl-fill-rect ;

M: solid draw-boundary
    drop dup fg gl-color rect-dim @{ 1 1 0 }@ v- gl-rect ;

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
TUPLE: gradient direction colors ;

M: gradient draw-interior ( gadget gradient -- )
    dup gradient-direction swap gradient-colors rot rect-dim
    gl-gradient ;

M: gadget draw-gadget* ( gadget -- )
    dup
    dup interior paint-prop* draw-interior
    dup boundary paint-prop* draw-boundary ;

! Polygon pen
TUPLE: polygon points ;

M: polygon draw-boundary ( gadget polygon -- )
    swap fg gl-color polygon-points gl-poly ;

M: polygon draw-interior ( gadget polygon -- )
    swap bg gl-color polygon-points gl-fill-poly ;

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

: gadget-font ( gadget -- font )
    [ font paint-prop ] keep
    [ font-style paint-prop ] keep
    [ font-size paint-prop ] keep
    >r lookup-font r> drop ;
