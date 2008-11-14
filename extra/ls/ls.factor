! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators io io.files kernel
math.parser sequences system vocabs.loader calendar
sequences.lib ;

IN: ls

: ls-time ( timestamp -- string )
    [ hour>> ] [ minute>> ] bi
    [ number>string 2 CHAR: 0 pad-left ] bi@ ":" splice ;

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

HOOK: execute>string os ( ? -- string )

M: object execute>string ( ? -- string ) "x" "-" ? ; inline

HOOK: permissions-string os ( -- str )

HOOK: (directory.) os ( path -- lines )

: directory. ( path -- )
    [ (directory.) ] with-directory-files [ print ] each ;

{
    { [ os unix? ] [ "ls.unix" ] }
    { [ os windows? ] [ "ls.windows" ] }
} cond require