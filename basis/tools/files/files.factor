! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators io io.files kernel
math.parser sequences system vocabs.loader calendar math
symbols fry prettyprint ;
IN: tools.files

<PRIVATE

: ls-time ( timestamp -- string )
    [ hour>> ] [ minute>> ] bi
    [ number>string 2 CHAR: 0 pad-left ] bi@ ":" glue ;

: ls-timestamp ( timestamp -- string )
    [ month>> month-abbreviation ]
    [ day>> number>string 2 CHAR: \s pad-left ]
    [
        dup year>> dup now year>> =
        [ drop ls-time ] [ nip number>string ] if
        5 CHAR: \s pad-left
    ] tri 3array " " join ;

: read>string ( ? -- string ) "r" "-" ? ; inline

: write>string ( ? -- string ) "w" "-" ? ; inline

: execute>string ( ? -- string ) "x" "-" ? ; inline

HOOK: (directory.) os ( path -- lines )

PRIVATE>

: directory. ( path -- )
    [ (directory.) ] with-directory-files [ print ] each ;

SYMBOLS: device-name mount-point type
available-space free-space used-space total-space
percent-used percent-free ;

: percent ( real -- integer ) 100 * >integer ; inline

: file-system-spec ( file-system-info obj -- str )
    {
        { device-name [ device-name>> [ "" ] unless* ] }
        { mount-point [ mount-point>> [ "" ] unless* ] }
        { type [ type>> [ "" ] unless* ] }
        { available-space [ available-space>> [ 0 ] unless* ] }
        { free-space [ free-space>> [ 0 ] unless* ] }
        { used-space [ used-space>> [ 0 ] unless* ] }
        { total-space [ total-space>> [ 0 ] unless* ] }
        { percent-used [
            [ used-space>> ] [ total-space>> ] bi
            [ [ 0 ] unless* ] bi@ dup 0 =
            [ 2drop 0 ] [ / percent ] if
        ] }
    } case ;

: file-systems-info ( spec -- seq )
    file-systems swap '[ _ [ file-system-spec ] with map ] map ;

: print-file-systems ( spec -- )
    [ file-systems-info ]
    [ [ unparse ] map ] bi prefix simple-table. ;

: file-systems. ( -- )
    { device-name free-space used-space total-space percent-used mount-point }
    print-file-systems ;

{
    { [ os unix? ] [ "tools.files.unix" ] }
    { [ os windows? ] [ "tools.files.windows" ] }
} cond require
