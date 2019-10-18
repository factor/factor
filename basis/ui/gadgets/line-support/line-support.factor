! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators fry kernel math
math.functions math.order math.ranges math.vectors namespaces
opengl sequences ui.gadgets ui.gadgets.scrollers
ui.gadgets.viewports ui.render ui.text ui.theme ;
IN: ui.gadgets.line-support

! Some code shared by table and editor gadgets
TUPLE: line-gadget < gadget
    font selection-color
    min-rows max-rows
    min-cols max-cols
    line-leading line-height
    pref-viewport-dim ;

: new-line-gadget ( class -- gadget )
    new selection-color >>selection-color ;

GENERIC: line-leading* ( gadget -- n )

M: line-gadget line-leading* font>> font-metrics leading>> ;

GENERIC: line-leading ( gadget -- n )

M: line-gadget line-leading
    dup line-leading>>
    [ ] [
        [ line-leading* ] [ ] [ layout-state>> ] tri
        [ drop ] [ dupd line-leading<< ] if
    ] ?if ;

GENERIC: line-height* ( gadget -- n )

M: line-gadget line-height* font>> font-metrics height>> ceiling ;

GENERIC: line-height ( gadget -- n )

M: line-gadget line-height
    dup line-height>>
    [ ] [
        [ line-height* ] [ ] [ layout-state>> ] tri
        [ drop ] [ dupd line-height<< ] if
    ] ?if ;

: y>line ( y gadget -- n ) line-height /i ;

: line>y ( n gadget -- y ) line-height * >integer ;

: validate-line ( m gadget -- n )
    control-value [ drop f ] [ length 1 - min 0 max ] if-empty ;

: valid-line? ( n gadget -- ? )
    control-value length 1 - 0 swap between? ;

: visible-line ( gadget quot -- n )
    '[
        [ clip get @ origin get [ second ] bi@ - ] dip
        y>line
    ] keep validate-line ; inline

: first-visible-line ( gadget -- n )
    [ loc>> ] visible-line ;

: last-visible-line ( gadget -- n )
    [ [ loc>> ] [ dim>> ] bi v+ ] visible-line 1 + ;

: each-slice-index ( from to seq quot -- )
    [ [ <slice> ] [ drop [a,b) ] 3bi ] dip 2each ; inline

GENERIC: draw-line ( line index gadget -- )

: draw-lines ( gadget -- )
    {
        [ first-visible-line ]
        [ last-visible-line ]
        [ control-value ]
        [ line-height ]
        [ ]
    } cleave '[
        0 over _ * >integer 2array
        [ _ draw-line ] with-translation
    ] each-slice-index ;

<PRIVATE

: clamp ( dim unit min max -- dim' )
    [ -1/0. or * ] [ 1/0. or * ] bi-curry* bi
    [ max ] [ min ] bi* ;

: em ( font -- x ) "m" text-width ;

PRIVATE>

: line-gadget-width ( pref-dim gadget -- w )
    [ first ] [ [ font>> em ] [ min-cols>> ] [ max-cols>> ] tri ] bi* clamp ;

: line-gadget-height ( pref-dim gadget -- h )
    [ second ] [ [ line-height ] [ min-rows>> ] [ max-rows>> ] tri ] bi* clamp ;

: pref-viewport-dim* ( gadget -- dim )
    [ pref-dim ] [ ] bi
    [ line-gadget-width ]
    [ line-gadget-height ]
    2bi 2array ; inline

M: line-gadget pref-viewport-dim
    dup pref-viewport-dim>>
    [ ] [
        [ pref-viewport-dim* ] [ ] [ layout-state>> ] tri
        [ drop ] [ dupd pref-viewport-dim<< ] if
    ] ?if ;

: visible-lines ( gadget -- n )
    [ visible-dim second ] [ line-height ] bi /i ;
