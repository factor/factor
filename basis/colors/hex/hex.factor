! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors colors formatting grouping kernel lexer math
math.parser sequences ;

IN: colors.hex

: hex>rgba ( hex -- rgba )
    2 group [ hex> 255 /f ] map first3 1.0 <rgba> ;

: rgba>hex ( rgba -- hex )
    [ red>> ] [ green>> ] [ blue>> ] tri
    [ 255 * >integer ] tri@ "%02X%02X%02X" sprintf ;

SYNTAX: HEXCOLOR: scan hex>rgba suffix! ;
