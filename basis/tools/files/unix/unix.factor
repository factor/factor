! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators combinators.smart
io.files.info.unix kernel math math.order math.parser sequences
strings system tools.files tools.files.private unicode
unix.groups unix.stat unix.users ;
IN: tools.files.unix

<PRIVATE

: unix-execute>string ( str bools -- str' )
    swap {
        { { t t } [ >lower ] }
        { { t f } [ >upper ] }
        { { f t } [ drop "x" ] }
        [ 2drop "-" ]
    } case ;

: permissions-string ( permissions -- str )
    [
        {
            [ type>> file-type>ch 1string ]
            [ user-read? read>string ]
            [ user-write? write>string ]
            [ [ uid? ] [ user-execute? ] bi 2array "s" unix-execute>string ]
            [ group-read? read>string ]
            [ group-write? write>string ]
            [ [ gid? ] [ group-execute? ] bi 2array "s" unix-execute>string ]
            [ other-read? read>string ]
            [ other-write? write>string ]
            [ [ sticky? ] [ other-execute? ] bi 2array "t" unix-execute>string ]
        } cleave
    ] output>array concat ;

: mode>symbol ( mode -- ch )
    S_IFMT bitand
    {
        { [ dup S_IFDIR = ] [ drop "/" ] }
        { [ dup S_IFIFO = ] [ drop "|" ] }
        { [ dup any-execute? ] [ drop "*" ] }
        { [ dup S_IFLNK = ] [ drop "@" ] }
        { [ dup S_IFWHT = ] [ drop "%" ] }
        { [ dup S_IFSOCK = ] [ drop "=" ] }
        [ drop "" ]
    } cond ;

M: unix (directory.)
    <listing-tool>
        {
            +permissions+ +nlinks+ +user+ +group+
            +file-size+ +file-date+ +file-name+
        } >>specs
        { { directory-entry>> name>> <=> } } >>sort
    [ [ list-files ] with-group-cache ] with-user-cache ;

M: unix file-spec>string
    {
        { +file-name/type+ [
            directory-entry>> [ name>> ] [ file-type>trailing ] bi append
        ] }
        { +permissions+ [ file-info>> permissions-string ] }
        { +nlinks+ [ file-info>> nlink>> number>string ] }
        { +user+ [ file-info>> uid>> user-name ] }
        { +group+ [ file-info>> gid>> group-name ] }
        { +uid+ [ file-info>> uid>> number>string ] }
        { +gid+ [ file-info>> gid>> number>string ] }
        [ call-next-method ]
    } case ;

PRIVATE>
