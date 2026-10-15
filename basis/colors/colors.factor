! Copyright (C) 2003, 2009 Slava Pestov.
! Copyright (C) 2008 Eduardo Cavazos.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors ascii arrays assocs combinators grouping
io.encodings.utf8 io.files kernel lexer math math.functions
math.parser math.parser.integer-float locals sequences splitting vocabs.loader ;
IN: colors

MIXIN: color

TUPLE: rgba
{ red read-only }
{ green read-only }
{ blue read-only }
{ alpha read-only } ;

C: <rgba> rgba

INSTANCE: rgba color

GENERIC: >rgba ( color -- rgba )

M: rgba >rgba ; inline

M: color red>> >rgba red>> ;
M: color green>> >rgba green>> ;
M: color blue>> >rgba blue>> ;
M: color alpha>> >rgba alpha>> ;

: >rgba-components ( object -- r g b a )
    >rgba { [ red>> ] [ green>> ] [ blue>> ] [ alpha>> ] } cleave ; inline

: opaque? ( color -- ? ) alpha>> 1 number= ;

CONSTANT: transparent T{ rgba f 0.0 0.0 0.0 0.0 }

: inverse-color ( color -- color' )
    >rgba-components [ [ 1.0 swap - ] tri@ ] dip <rgba> ;

: color= ( color1 color2 -- ? )
    [ >rgba-components 4array ] bi@ [ 0.00000001 ~ ] 2all? ;

! Formatting color metadata does not require executing floating-point operations.
ERROR: non-finite-color-component component ;

:: color-component>rational ( component -- rational )
    component float? [
        component double>bits :> bits
        bits -52 shift 0x7ff bitand :> exponent
        exponent 0x7ff = [ component non-finite-color-component ] when
        bits 0xfffffffffffff bitand :> significand
        exponent zero?
        [ significand -1074 ]
        [ significand 0x10000000000000 bitor exponent 1075 - ] if
        dup 0 < [ neg 1 swap shift / ] [ shift ] if
        bits 63 bit? [ neg ] when
    ] [ component ] if ;

: color-component>byte ( component -- byte )
    floating-point-supported? [ ] [ color-component>rational ] if
    255 * round >integer ;

<PRIVATE

: color-component-ratio ( component maximum -- float )
    floating-point-supported? [ /f ] [ ratio>binary64-bits bits>double ] if ;

: parse-line ( line -- name color )
    first4 [ [ string>number 255 color-component-ratio ] tri@ 1.0 <rgba> ] dip swap ;

: parse-colors ( lines -- assoc )
    [ "!" head? ] reject [
        [ blank? ] split-when harvest 3 cut "-" join suffix parse-line
    ] H{ } map>assoc ;

MEMO: colors ( -- assoc )
    {
        "vocab:colors/rgb.txt"
        "vocab:colors/css-colors.txt"
        "vocab:colors/factor-colors.txt"
        "vocab:colors/solarized-colors.txt"
    } [
        utf8 file-lines parse-colors
    ] [ assoc-union ] map-reduce ;

ERROR: invalid-hex-color hex ;

: hex>rgba ( hex -- rgba )
    dup length {
        { 6 [ 2 group [ hex> 255 color-component-ratio ] map first3 1.0 ] }
        { 8 [ 2 group [ hex> 255 color-component-ratio ] map first4 ] }
        { 3 [ [ digit> 15 color-component-ratio ] { } map-as first3 1.0 ] }
        { 4 [ [ digit> 15 color-component-ratio ] { } map-as first4 ] }
        [ drop invalid-hex-color ]
    } case <rgba> ;

: component>hex ( f -- s )
    color-component>byte >hex 2 CHAR: 0 pad-head ;

: (color>hex) ( seq -- hex )
    [ component>hex ] map concat "#" prepend ;

PRIVATE>

: color>hex ( color -- hex )
    >rgba-components dup
    floating-point-supported? [ ] [ color-component>rational ] if 1 number=
    [ drop 3array ] [ 4array ] if (color>hex) ;

: named-colors ( -- keys ) colors keys ;

: ?named-color ( name -- color/f ) colors at ;

ERROR: no-such-color name ;

: named-color ( name -- color )
    [ ?named-color ] [ no-such-color ] ?unless ;

: parse-color ( str -- color )
    "#" ?head [ hex>rgba ] [ named-color ] if ;

TUPLE: parsed-color string value ;

INSTANCE: parsed-color color

M: parsed-color >rgba value>> >rgba ;

SYNTAX: COLOR: scan-token dup parse-color parsed-color boa suffix! ;

{ "colors" "prettyprint" } "colors.prettyprint" require-when
