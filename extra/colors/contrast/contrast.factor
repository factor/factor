! Copyright (C) 2022 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: colors kernel math math.functions ;
IN: colors.contrast

<PRIVATE

: adjust-color ( u -- v )
    dup 0.03928 <= [ 12.92 / ] [ 0.055 + 1.055 / 2.4 ^ ] if ;

PRIVATE>

: relative-luminance ( color -- n )
    >rgba-components drop [ adjust-color ] tri@
    [ 0.2126 * ] [ 0.7152 * ] [ 0.0722 * ] tri* + + ;

: contrast-text-color ( color -- black/white )
    relative-luminance 0.179 > COLOR: black COLOR: white ? ;

: contrast-ratio ( color1 color2 -- n )
    [ relative-luminance ] bi@
    2dup < [ swap ] when [ 0.05 + ] bi@ / ;

: passes-AA? ( contrast large? -- ? )
    3.0 4.5 ? >= ;

: passes-AAA? ( contrast large? -- ? )
    4.5 7.0 ? >= ;
