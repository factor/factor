! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors colors combinators formatting grouping kernel
lexer math math.parser sequences vocabs.loader ;

IN: colors.hex

ERROR: invalid-hex-color hex ;

: hex>rgba ( hex -- rgba )
    dup length {
        { 6 [ 2 group [ hex> 255 /f ] map first3 1.0 ] }
        { 8 [ 2 group [ hex> 255 /f ] map first4 ] }
        { 3 [ [ digit> 15 /f ] { } map-as first3 1.0 ] }
        { 4 [ [ digit> 15 /f ] { } map-as first4 ] }
        [ drop invalid-hex-color ]
    } case <rgba> ;

: rgba>hex ( rgba -- hex )
    [ red>> ] [ green>> ] [ blue>> ] tri
    [ 255 * >integer ] tri@ "%02X%02X%02X" sprintf ;

TUPLE: hex-color < color hex value ;

M: hex-color >rgba value>> >rgba ;

SYNTAX: HEXCOLOR: scan-token dup hex>rgba hex-color boa suffix! ;

{ "colors.hex" "prettyprint" } "colors.hex.prettyprint" require-when
