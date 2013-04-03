! Copyright (C) 2003, 2009 Slava Pestov.
! Copyright (C) 2008 Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel locals math sequences ;
IN: colors

TUPLE: color ;

TUPLE: rgba < color
{ red read-only }
{ green read-only }
{ blue read-only }
{ alpha read-only } ;

C: <rgba> rgba

GENERIC: >rgba ( color -- rgba )

M: rgba >rgba ( rgba -- rgba ) ; inline

M: color red>> ( color -- red ) >rgba red>> ;
M: color green>> ( color -- green ) >rgba green>> ;
M: color blue>> ( color -- blue ) >rgba blue>> ;

: >rgba-components ( object -- r g b a )
    >rgba { [ red>> ] [ green>> ] [ blue>> ] [ alpha>> ] } cleave ; inline

: opaque? ( color -- ? ) alpha>> 1 number= ;

CONSTANT: transparent T{ rgba f 0.0 0.0 0.0 0.0 }

: linear-gradient ( color1 color2 percent -- color )
    [ 1.0 swap - * ] [ * ] bi-curry swapd
    [ [ >rgba-components drop ] [ tri@ ] bi* ] 2bi@
    [ + ] tri-curry@ tri* 1.0 <rgba> ;

:: sample-linear-gradient ( colors percent -- color )
    colors length :> num-colors
    num-colors 1 - percent * >integer :> left-index
    1.0 num-colors 1 - / :> cell-range
    percent left-index cell-range * - cell-range / :> alpha
    left-index colors nth :> left-color
    left-index 1 + num-colors mod colors nth :> right-color
    left-color right-color alpha linear-gradient ;

: inverse-color ( color -- color' )
    >rgba-components [ [ 1.0 swap - ] tri@ ] dip <rgba> ;
