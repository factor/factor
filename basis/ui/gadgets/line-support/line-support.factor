! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators fry kernel math math.order
math.ranges math.vectors namespaces opengl sequences ui.gadgets
ui.render ui.text ;
IN: ui.gadgets.line-support

! Some code shared by table and editor gadgets
SLOT: font

GENERIC: line-leading ( gadget -- n )

M: gadget line-leading font>> font-metrics leading>> ;

GENERIC: line-height ( gadget -- n )

M: gadget line-height font>> font-metrics height>> ;

: y>line ( y gadget -- n )
    [ line-leading ] [ line-height ] bi
    [ [ - ] keep ] dip + /i ;

: line>y ( n gadget -- y )
    [ line-height ] [ line-leading ] bi
    [ + * ] keep - ;

: validate-line ( m gadget -- n )
    control-value [ drop f ] [ length 1- min 0 max ] if-empty ;

: visible-line ( gadget quot -- n )
    '[
        [ clip get @ origin get [ second ] bi@ - ] dip
        y>line
    ] keep validate-line ; inline

: first-visible-line ( gadget -- n )
    [ loc>> ] visible-line ;

: last-visible-line ( gadget -- n )
    [ [ loc>> ] [ dim>> ] bi v+ ] visible-line 1+ ;

: each-slice-index ( from to seq quot -- )
    [ [ <slice> ] [ drop [a,b) ] 3bi ] dip 2each ; inline

GENERIC: draw-line ( line index gadget -- )

: draw-lines ( gadget -- )
    {
        [ first-visible-line ]
        [ last-visible-line ]
        [ control-value ]
        [ [ line-leading ] [ line-height ] bi + ]
        [ ]
    } cleave '[
        0 over _ * 2array
        [ _ draw-line ] with-translation
    ] each-slice-index ;