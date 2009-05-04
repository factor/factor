! Copyright (C) 2008, 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays calendar combinators fry io io.directories
io.files.info kernel math math.parser prettyprint sequences system
vocabs.loader sorting.slots calendar.format ;
IN: tools.files

<PRIVATE

: dir-or-size ( file-info -- str )
    dup directory? [
        drop "<DIR>" 20 CHAR: \s pad-tail
    ] [
        size>> number>string 20 CHAR: \s pad-head
    ] if ;

: listing-time ( timestamp -- string )
    [ hour>> ] [ minute>> ] bi
    [ number>string 2 CHAR: 0 pad-head ] bi@ ":" glue ;

: listing-date ( timestamp -- string )
    [ month>> month-abbreviation ]
    [ day>> number>string 2 CHAR: \s pad-head ]
    [
        dup year>> dup now year>> =
        [ drop listing-time ] [ nip number>string ] if
        5 CHAR: \s pad-head
    ] tri 3array " " join ;

: read>string ( ? -- string ) "r" "-" ? ; inline

: write>string ( ? -- string ) "w" "-" ? ; inline

: execute>string ( ? -- string ) "x" "-" ? ; inline

PRIVATE>

SYMBOLS: +file-name+ +file-name/type+ +permissions+ +file-type+
+nlinks+ +file-size+ +file-date+ +file-time+ +file-datetime+
+uid+ +gid+ +user+ +group+ +link-target+ +unix-datetime+
+directory-or-size+ ;

TUPLE: listing-tool path specs sort ;

TUPLE: file-listing directory-entry file-info ;

C: <file-listing> file-listing

: <listing-tool> ( path -- listing-tool )
    listing-tool new
        swap >>path
        { +file-name+ } >>specs ;

: list-slow? ( listing-tool -- ? )
    specs>> { +file-name+ } sequence= not ;

ERROR: unknown-file-spec symbol ;

HOOK: file-spec>string os ( file-listing spec -- string )

M: object file-spec>string ( file-listing spec -- string )
    {
        { +file-name+ [ directory-entry>> name>> ] }
        { +directory-or-size+ [ file-info>> dir-or-size ] }
        { +file-size+ [ file-info>> size>> number>string ] }
        { +file-date+ [ file-info>> modified>> listing-date ] }
        { +file-time+ [ file-info>> modified>> listing-time ] }
        { +file-datetime+ [ file-info>> modified>> timestamp>ymdhms ] }
        [ unknown-file-spec ]
    } case ;

: list-files-fast ( listing-tool -- array )
    path>> [ [ name>> 1array ] map ] with-directory-entries ; inline

: list-files-slow ( listing-tool -- array )
    [ path>> ] [ sort>> ] [ specs>> ] tri '[
            [ dup name>> file-info file-listing boa ] map
            _ [ sort-by ] when*
            [ _ [ file-spec>string ] with map ] map
    ] with-directory-entries ; inline

: list-files ( listing-tool -- array ) 
    dup list-slow? [ list-files-slow ] [ list-files-fast ] if ; inline

HOOK: (directory.) os ( path -- lines )

: directory. ( path -- ) (directory.) simple-table. ;

SYMBOLS: +device-name+ +mount-point+ +type+
+available-space+ +free-space+ +used-space+ +total-space+
+percent-used+ +percent-free+ ;

: percent ( real -- integer ) 100 * >integer ; inline

: file-system-spec ( file-system-info obj -- str )
    {
        { +device-name+ [ device-name>> "" or ] }
        { +mount-point+ [ mount-point>> "" or ] }
        { +type+ [ type>> "" or ] }
        { +available-space+ [ available-space>> 0 or ] }
        { +free-space+ [ free-space>> 0 or ] }
        { +used-space+ [ used-space>> 0 or ] }
        { +total-space+ [ total-space>> 0 or ] }
        { +percent-used+ [
            [ used-space>> ] [ total-space>> ] bi
            [ 0 or ] bi@ dup 0 =
            [ 2drop 0 ] [ / percent ] if
        ] }
    } case ;

: file-systems-info ( spec -- seq )
    file-systems swap '[ _ [ file-system-spec ] with map ] map ;

: print-file-systems ( spec -- )
    [ file-systems-info ]
    [ [ unparse ] map ] bi prefix simple-table. ;

: file-systems. ( -- )
    {
        +device-name+ +available-space+ +free-space+ +used-space+
        +total-space+ +percent-used+ +mount-point+
    } print-file-systems ;

{
    { [ os unix? ] [ "tools.files.unix" ] }
    { [ os windows? ] [ "tools.files.windows" ] }
} cond require
