! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators fry kernel math math.functions math.order
math.ranges math.vectors namespaces opengl sequences ui.gadgets
ui.render ui.text ui.gadgets.scrollers ui.gadgets.viewports ;
IN: ui.gadgets.line-support

! Some code shared by table and editor gadgets
TUPLE: line-gadget < gadget
font selection-color
min-rows max-rows
min-cols max-cols ;

: new-line-gadget ( class -- gadget )
    new
        selection-color >>selection-color ;

GENERIC: line-leading ( gadget -- n )

M: line-gadget line-leading font>> font-metrics leading>> ;

GENERIC: line-height ( gadget -- n )

M: line-gadget line-height font>> font-metrics height>> ceiling ;

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
    [ -1/0. or * ] [ 1/.0 or * ] bi-curry* bi
    [ max ] [ min ] bi* ;

: em ( font -- x ) "m" text-width ;

PRIVATE>

: line-gadget-width ( pref-dim gadget -- w )
    [ first ] [ [ font>> em ] [ min-cols>> ] [ max-cols>> ] tri ] bi* clamp ;

: line-gadget-height ( pref-dim gadget -- h )
    [ second ] [ [ line-height ] [ min-rows>> ] [ max-rows>> ] tri ] bi* clamp ;

M: line-gadget pref-viewport-dim
    [ pref-dim ] [ ] bi
    [ line-gadget-width ]
    [ line-gadget-height ]
    2bi 2array ;

: visible-lines ( gadget -- n )
    [ visible-dim second ] [ line-height ] bi /i ;
