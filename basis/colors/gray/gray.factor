! Copyright (C) 2008 Eduardo Cavazos.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors colors kernel math ;
IN: colors.gray

TUPLE: gray { gray read-only } { alpha read-only } ;

C: <gray> gray

INSTANCE: gray color

M: gray >rgba
    [ gray>> dup dup ] [ alpha>> ] bi <rgba> ; inline

M: gray red>> gray>> ;

M: gray green>> gray>> ;

M: gray blue>> gray>> ;

GENERIC: >gray ( color -- gray )

M: object >gray >rgba >gray ;

M: rgba >gray
    >rgba-components [
        [ 0.3 * ] [ 0.59 * ] [ 0.11 * ] tri* + +
    ] dip <gray> ;
