! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel system unicode.case
io.unix.files io.files.listing generalizations ;
IN: io.files.listing.unix

M: unix execute-string ( str bools -- str' )
    swap {
        { { t t } [ >lower ] }
        { { t f } [ >upper ] }
        { { f t } [ drop "x" ] }
        [ 2drop "-" ]
    } case ;

M: unix permissions-string ( permissions -- str )
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
    } cleave 10 narray concat ;

M: unix ls ( path -- lines )
        [ [
            dup file-info
            {
                [ permissions-string ]
                [ nlink>> number>string 3 CHAR: \s pad-left ]
                ! [ uid>> ]
                ! [ gid>> ]
                [ size>> number>string 15 CHAR: \s pad-left ]
                [ modified>> ls-timestamp ]
            } cleave 4 narray swap suffix " " join
        ] map
    ] with-group-cache ] with-user-cache ;
