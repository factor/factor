! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators generalizations
io.files io.unix.files math.parser sequences.lib calendar math
kernel sequences unix.groups unix.users combinators.cleave
strings combinators.short-circuit unicode.case ;
IN: ls

TUPLE: ls-info path user group size ;

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

: execute-string ( str bools -- str' )
    swap {
        { { t t } [ >lower ] }
        { { t f } [ >upper ] }
        { { f t } [ drop "x" ] }
        [ 2drop "-" ]
    } case ;

: permissions-string ( permissions -- str )
    {
        [ type>> file-type>ch 1string ]
        [ user-read? read>string ]
        [ user-write? write>string ]
        [ [ uid? ] [ user-execute? ] bi 2array "s" execute-string ]      
        [ group-read? read>string ]
        [ group-write? write>string ]
        [ [ gid? ] [ group-execute? ] bi 2array "s" execute-string ]      
        [ other-read? read>string ]
        [ other-write? write>string ]
        [ [ sticky? ] [ other-execute? ] bi 2array "t" execute-string ]      
    } <arr> concat ;

: ls ( path -- lines )
    [ [ [
        "" directory-files [
            dup file-info
            {
                [ permissions-string ]
                [ nlink>> number>string 3 CHAR: \s pad-left ]
                ! [ uid>> ]
                ! [ gid>> ]
                [ size>> number>string 15 CHAR: \s pad-left ]
                [ modified>> ls-timestamp ]
            } <arr> swap suffix " " join
        ] map
    ] with-group-cache ] with-user-cache ] with-directory ;
