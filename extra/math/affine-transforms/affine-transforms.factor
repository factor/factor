! (c)2009 Joe Groff, see BSD license
USING: accessors arrays combinators combinators.short-circuit kernel
math math.functions math.vectors sequences ;
IN: math.affine-transforms

TUPLE: affine-transform
    { x read-only }
    { y read-only }
    { origin read-only } ;
C: <affine-transform> affine-transform

CONSTANT: identity-transform T{ affine-transform f
                                { 1.0 0.0 } { 0.0 1.0 } { 0.0 0.0 } }

: axes ( a -- a' )
    [ x>> ] [ y>> ] bi { 0.0 0.0 } <affine-transform> ;

: a.v ( a v -- v )
    [ [ x>> ] [ first  ] bi* v*n ]
    [ [ y>> ] [ second ] bi* v*n ]
    [ drop origin>> ] 2tri
    v+ v+ ;

: <identity> ( -- a )
    { 1.0 0.0 } { 0.0 1.0 } { 0.0 0.0 } <affine-transform> ;
: <translation> ( origin -- a )
    [ { 1.0 0.0 } { 0.0 1.0 } ] dip <affine-transform> ;
: <rotation> ( theta -- transform )
    [ cos ] [ sin ] bi
    [ 2array ] [ neg swap 2array ] 2bi { 0.0 0.0 } <affine-transform> ;
: <scale> ( x y -- transform )
    [ 0.0 2array ] [ 0.0 swap 2array ] bi* { 0.0 0.0 } <affine-transform> ;

: center-rotation ( transform center -- transform )
    [ [ x>> ] [ y>> ] [ ] tri ] dip [ vneg a.v ] [ v+ ] bi
    <affine-transform> ;

: flatten-transform ( transform -- array )
    [ x>> ] [ y>> ] [ origin>> ] tri 3append ;

: |a| ( a -- det )
    [ [ x>> first  ] [ y>> second ] bi * ]
    [ [ x>> second ] [ y>> first  ] bi * ] bi - ;

: (inverted-axes) ( a -- x y )
    [ [ y>> second     ] [ x>> second neg ] bi 2array ]
    [ [ y>> first  neg ] [ x>> first      ] bi 2array ]
    [ |a| ] tri
    [ v/n ] curry bi@ ;

: inverse-axes ( a -- a^-1 )
    (inverted-axes) { 0.0 0.0 } <affine-transform> ;

: inverse-transform ( a -- a^-1 )
    [ inverse-axes [ x>> ] [ y>> ] [ ] tri ] [ origin>> ] bi
    a.v vneg <affine-transform> ;

: transpose-axes ( a -- a^T )
    [ [ x>> first  ] [ y>> first  ] bi 2array ]
    [ [ x>> second ] [ y>> second ] bi 2array ]
    [ origin>> ] tri <affine-transform> ;

: a. ( a a -- a )
    {
        [ [ transpose-axes x>> ] [ x>> ] bi* vdot ]
        [ [ transpose-axes y>> ] [ x>> ] bi* vdot ]
        [ [ transpose-axes x>> ] [ y>> ] bi* vdot ]
        [ [ transpose-axes y>> ] [ y>> ] bi* vdot ]
        [ origin>> a.v ]
    } 2cleave
    [ [ 2array ] 2bi@ ] dip <affine-transform> ;

: a~ ( a b epsilon -- ? )
    {
        [ [ [ x>>      ] bi@ ] dip v~ ]
        [ [ [ y>>      ] bi@ ] dip v~ ]
        [ [ [ origin>> ] bi@ ] dip v~ ]
    } 3&& ;
