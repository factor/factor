! (c)2009 Joe Groff, see BSD license
USING: accessors arrays literals math math.affine-transforms
math.functions multiline sequences svg tools.test xml xml.traversal ;
IN: svg.tests

{ 1.0 2.25 } { -3.0 4.0 } { 5.5 0.5 } <affine-transform> 1array [
    "matrix ( 1 +2.25 -3  , 0.4e+1  ,5.5, 5e-1 )" svg-transform>affine-transform
] unit-test

{ 1.0 0.0 } { 0.0 1.0 } { 5.0 10.0 } <affine-transform> 1array [
    "translate(5.0, 1e1 )" svg-transform>affine-transform
] unit-test

{ 1.0 0.0 } { 0.0 1.0 } { 5.0 10.0 } <affine-transform> 1array [
    "translate( 5.0  1e+1)" svg-transform>affine-transform
] unit-test

{ 2.0 0.0 } { 0.0 2.0 } { 0.0 0.0 } <affine-transform> 1array [
    "scale(2.0)" svg-transform>affine-transform
] unit-test

{ 2.0 0.0 } { 0.0 4.0 } { 0.0 0.0 } <affine-transform> 1array [
    "scale(2.0 4.0)" svg-transform>affine-transform
] unit-test

{ 2.0 0.0 } { 0.0 4.0 } { 0.0 0.0 } <affine-transform> 1array [
    "scale(2.0 4.0)" svg-transform>affine-transform
] unit-test

[ t ] [
    "skewX(45)" svg-transform>affine-transform
    { 1.0 0.0 } { 1.0 1.0 } { 0.0 0.0 } <affine-transform> 0.001 a~
] unit-test

[ t ] [
    "skewY(-4.5e1)" svg-transform>affine-transform
    { 1.0 -1.0 } { 0.0 1.0 } { 0.0 0.0 } <affine-transform> 0.001 a~
] unit-test

[ t ] [
    "rotate(30)" svg-transform>affine-transform
    { $[ 0.75 sqrt ] 0.5            }
    { -0.5           $[ 0.75 sqrt ] }
    {  0.0           0.0            } <affine-transform> 
    0.001 a~
] unit-test

[ t ] [
    "rotate(30 1.0,2.0)" svg-transform>affine-transform
    { $[  30 degrees cos ] $[ 30 degrees sin ] }
    { $[ -30 degrees sin ] $[ 30 degrees cos ] } {
        $[ 1.0 30 degrees cos 1.0 * - 30 degrees sin 2.0 * + ]
        $[ 2.0 30 degrees cos 2.0 * - 30 degrees sin 1.0 * - ]
    } <affine-transform> 0.001 a~
] unit-test

{ $[  30 degrees cos ] $[ 30 degrees sin ] }
{ $[ -30 degrees sin ] $[ 30 degrees cos ] }
{ 1.0 2.0 } <affine-transform> 1array [
    "translate(1 2) rotate(30)" svg-transform>affine-transform
] unit-test

[ {
    T{ moveto f { 1.0  1.0 } f }
    T{ lineto f { 3.0 -1.0 } f }

    T{ lineto f { 2.0  2.0 } t }
    T{ lineto f { 2.0 -2.0 } t }
    T{ lineto f { 2.0  2.0 } t }

    T{ vertical-lineto f -9.0 t }
    T{ vertical-lineto f  1.0 t }
    T{ horizontal-lineto f 9.0 f }
    T{ horizontal-lineto f 8.0 f }

    T{ closepath }

    T{ moveto f { 0.0 0.0 } f }

    T{ curveto f { -4.0 0.0 } { -8.0 4.0 } { -8.0 8.0 } f }
    T{ curveto f { -8.0 4.0 } { -12.0 8.0 } { -16.0 8.0 } f }

    T{ smooth-curveto f { 0.0 2.0 } { 2.0 0.0 } t }

    T{ quadratic-bezier-curveto f { -2.0 0.0 } { 0.0 -2.0 } f }
    T{ quadratic-bezier-curveto f { -3.0 0.0 } { 0.0  3.0 } f }

    T{ smooth-quadratic-bezier-curveto f { 1.0 2.0 } t }
    T{ smooth-quadratic-bezier-curveto f { 3.0 4.0 } t }

    T{ elliptical-arc f { 5.0 6.0 } 7.0 t f { 8.0 9.0 } f }
} ] [
    <"
    M 1.0,+1 3,-10e-1  l 2 2, 2 -2, 2 2   v -9 1 H 9 8  z 
    M 0 0  C -4.0 0.0 -8.0 4.0 -8.0 8.0  -8.0 4.0 -12.0 8.0 -16.0 8.0
    s 0.0,2.0 2.0,0.0
    Q -2 0 0 -2 -3. 0 0 3
    t 1 2 3 4
    A 5 6 7 1 0 8 9
    "> svg-path>array
] unit-test

STRING: test-svg-string
<svg xmlns="http://www.w3.org/2000/svg">
        <path transform="translate(1 2)" d="M -1 -1 l 2 2" />
</svg>
;

: test-svg-path ( -- obj )
    test-svg-string string>xml body>> children-tags first ;

[ { T{ moveto f { -1.0 -1.0 } f } T{ lineto f { 2.0 2.0 } t } } ]
[ test-svg-path tag-d ] unit-test

[ T{ affine-transform f { 1.0 0.0 } { 0.0 1.0 } { 1.0 2.0 } } ]
[ test-svg-path tag-transform ] unit-test
