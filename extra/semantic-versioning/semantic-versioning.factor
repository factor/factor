! Copyright (C) 2010 Maximilian Lupke.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays ascii kernel math.order math.parser sequences splitting
;
IN: semantic-versioning

: split-version ( string -- array )
    "." split first3 dup [ digit? not ] find
    [ cut [ [ string>number ] tri@ ] dip 4array ]
    [ drop [ string>number ] tri@ 3array ]
    if ;

: version<=> ( version1 version2 -- <=> )
    [ split-version ] bi@ drop-prefix
    2dup [ length 0 = ] either?
    [ [ length ] bi@ >=< ] [ [ first ] bi@ <=> ] if ;

: version< ( version1 version2 -- ? )
    version<=> +lt+ = ;

: version<= ( version1 version2 -- ? )
    version<=> [ +lt+ = ] [ +eq+ = ] either? ;

: version= ( version1 version2 -- ? )
    version<=> +eq+ = ;

: version>= ( version1 version2 -- ? )
    version<=> [ +gt+ = ] [ +eq+ = ] either? ;

: version> ( version1 version2 -- ? )
    version<=> +gt+ = ;
