! Copyright (C) 2010 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel math math.order math.polynomials
opengl.demo-support opengl.gl sequences ui.gadgets
ui.gadgets.panes ui.render arrays ;
IN: math.splines.viewer

<PRIVATE
: eval-polynomials ( polynomials-seq n -- xy-sequence )
    [
        [ 1 + <iota> ] keep [
            /f swap [ polyval ] with map
        ] curry with map
    ] curry map concat ;
PRIVATE>

TUPLE: spline-gadget < gadget polynomials steps spline-dim ;

M: spline-gadget pref-dim* spline-dim>> ;

M:: spline-gadget draw-gadget* ( gadget -- )
    0 0 0 glColor3f

    gadget [ polynomials>> ] [ steps>> ] bi eval-polynomials :> pts

    pts [ first ] [ max ] map-reduce  :> x-max
    pts [ first ] [ min ] map-reduce  :> x-min
    pts [ second ] [ max ] map-reduce :> y-max
    pts [ second ] [ min ] map-reduce :> y-min

    pts [
        [ first x-min - x-max x-min - / gadget spline-dim>> first * ]
        [ second y-min - y-max y-min - / gadget spline-dim>> second * ] bi 2array
    ] map :> pts

    GL_LINE_STRIP [
        pts [
            first2 neg gadget spline-dim>> second + glVertex2f
        ] each ]
    do-state ;

:: <spline-gadget> ( polynomials dim steps -- gadget )
    spline-gadget new
    dim >>spline-dim
    polynomials >>polynomials
    steps >>steps ;

: spline. ( curve dim steps -- )
    <spline-gadget> gadget. ;
