! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
USING: alien arrays freetype gadgets-layouts generic hashtables
io kernel lists math namespaces opengl sdl sequences strings
styles vectors ;
IN: gadgets

: paint-prop* ( gadget key -- value ) swap gadget-paint ?hash ;

: paint-prop ( gadget key -- value )
    over [
        2dup paint-prop* dup
        [ 2nip ] [ drop >r gadget-parent r> paint-prop ] if
    ] [
        2drop f
    ] if ;

GENERIC: draw-gadget* ( gadget -- )

M: gadget draw-gadget* ( gadget -- ) drop ;

SYMBOL: interior
SYMBOL: boundary

GENERIC: draw-interior ( gadget interior -- )
GENERIC: draw-boundary ( gadget boundary -- )

SYMBOL: clip

: visible-children ( gadget -- seq ) clip get swap children-on ;

DEFER: draw-gadget

: (draw-gadget) ( gadget -- )
    dup dup interior paint-prop* draw-interior
    dup dup boundary paint-prop* draw-boundary
    dup draw-gadget*
    visible-children [ draw-gadget ] each ;

: do-clip ( gadget -- )
    >absolute clip [ rect-intersect dup ] change
    dup rect-loc swap rect-dim gl-set-clip ;

: with-translation ( gadget quot -- | quot: gadget -- )
    GL_MODELVIEW [
        >r dup rect-loc dup translate first3 glTranslated
        r> call
    ] do-matrix ; inline

: draw-gadget ( gadget -- )
    clip get over inside? [
        [
            dup do-clip [ dup (draw-gadget) ] with-translation
        ] with-scope
    ] when drop ;

: init-paint ( gadget -- gestures )
    dup gadget-paint
    [ ] [ {{ }} clone dup rot set-gadget-paint ] ?if ;

: set-paint-prop ( gadget value key -- )
    rot init-paint set-hash ;

: add-paint ( gadget hash -- )
    dup [ >r init-paint r> hash-update ] [ 2drop ] if ;

! Pen paint properties
M: f draw-interior 2drop ;
M: f draw-boundary 2drop ;

! Solid fill/border
TUPLE: solid ;

: rect>screen ( shape -- x1 y1 x2 y2 )
    >r origin get dup r> rect-dim v+ [ first2 ] 2apply ;

! Solid pen
M: solid draw-interior
    drop dup background paint-prop gl-color rect-dim gl-fill-rect ;

M: solid draw-boundary
    drop dup foreground paint-prop gl-color rect-dim gl-rect ;

! Gradient pen
TUPLE: gradient colors ;

M: gradient draw-interior ( gadget gradient -- )
    over gadget-orientation swap gradient-colors rot rect-dim
    gl-gradient ;

! Polygon pen
TUPLE: polygon points ;

M: polygon draw-boundary ( gadget polygon -- )
    swap foreground paint-prop gl-color
    polygon-points [ gl-poly ] each ;

M: polygon draw-interior ( gadget polygon -- )
    swap background paint-prop gl-color
    polygon-points [ gl-fill-poly ] each ;

: arrow-up    @{ @{ @{ 3 0 0 }@ @{ 6 6 0 }@ @{ 0 6 0 }@ }@ }@ ;
: arrow-right @{ @{ @{ 0 0 0 }@ @{ 6 3 0 }@ @{ 0 6 0 }@ }@ }@ ;
: arrow-down  @{ @{ @{ 0 0 0 }@ @{ 6 0 0 }@ @{ 3 6 0 }@ }@ }@ ;
: arrow-left  @{ @{ @{ 0 3 0 }@ @{ 6 0 0 }@ @{ 6 6 0 }@ }@ }@ ;

: arrow-right|
    @{ @{ @{ 6 0 0 }@ @{ 6 6 0 }@ }@ }@ arrow-right append ;

: arrow-|left
    @{ @{ @{ 1 0 0 }@ @{ 1 6 0 }@ }@ }@ arrow-left append ;

: <polygon-gadget> ( points -- gadget )
    dup @{ 0 0 0 }@ [ max-dim vmax ] reduce
    >r <polygon> <gadget> r> over set-rect-dim
    dup rot interior set-paint-prop ;

: gadget-font ( gadget -- font )
    [ font paint-prop ] keep
    [ font-style paint-prop ] keep
    [ font-size paint-prop ] keep
    >r lookup-font r> drop ;
