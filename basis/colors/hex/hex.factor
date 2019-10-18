! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors colors combinators formatting grouping kernel
lexer math math.parser sequences ;

IN: colors.hex

: hex>rgba ( hex -- rgba )
    dup length {
        { 6 [ 2 group [ hex> 255 /f ] map first3 1.0 ] }
        { 8 [ 2 group [ hex> 255 /f ] map first4 ] }
        { 3 [ [ digit> 15 /f ] { } map-as first3 1.0 ] }
        { 4 [ [ digit> 15 /f ] { } map-as first4 ] }
    } case <rgba> ;

: rgba>hex ( rgba -- hex )
    [ red>> ] [ green>> ] [ blue>> ] tri
    [ 255 * >integer ] tri@ "%02X%02X%02X" sprintf ;

SYNTAX: HEXCOLOR: scan-token hex>rgba suffix! ;
