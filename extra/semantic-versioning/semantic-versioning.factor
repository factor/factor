! Copyright (C) 2010 Maximilian Lupke.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays ascii combinators kernel math.order math.parser
sequences splitting ;
IN: semantic-versioning

: split-version ( string -- array )
    "." split first3 dup [ digit? not ] find
    [ cut [ [ string>number ] tri@ ] dip 4array ]
    [ drop [ string>number ] tri@ 3array ]
    if ;

! okay, not beautiful
: version<=> ( version1 version2 -- <=> )
    [ split-version ] bi@
    {
        { [ [ unclip ] bi@ swapd <=> dup +eq+ = not ] [ 2nip ] }
        { [ drop [ unclip ] bi@ swapd <=> dup +eq+ = not ] [ 2nip ] }
        { [ drop [ unclip ] bi@ swapd <=> dup +eq+ = not ] [ 2nip ] }
        { [ drop 2dup [ length ] bi@ >=< dup +eq+ = not ] [ 2nip ] }
        [ drop [ first ] bi@ <=> ]
    } cond ;
