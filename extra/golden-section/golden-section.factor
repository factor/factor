
USING: accessors arrays colors kernel math math.constants
math.functions math.order namespaces opengl.gl processing.shapes
sequences ui ui.gadgets.cartesian ;

IN: golden-section

: omega ( i -- omega ) phi 1 - * 2 * pi * ;

: x ( i -- x ) [ omega cos ] [ 0.5 * ] bi * ;
: y ( i -- y ) [ omega sin ] [ 0.5 * ] bi * ;

: center ( i -- point ) [ x ] [ y ] bi 2array ;

: radius ( i -- radius ) pi * 720 / sin 10 * ;

: color ( i -- i ) dup 360.0 / dup 0.25 1 rgba boa fill-color set ;

: line-width ( i -- i ) dup radius 0.5 * 1 max glLineWidth ;

: draw ( i -- ) [ center ] [ radius 1.5 * 2 * ] bi draw-circle ;

: dot ( i -- ) color line-width draw ;

: golden-section ( -- ) 720 <iota> [ dot ] each ;

: <golden-section> ( -- gadget )
    <cartesian>
        {  600 600 }       >>pdim
        { -400 400 }       x-range
        { -400 400 }       y-range
        [ golden-section ] >>action ;

MAIN-WINDOW: golden-section-window
    { { title "Golden Section" } }
    <golden-section> >>gadgets ;
