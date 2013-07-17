! Copyright (C) 2010 Maximilian Lupke.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays ascii kernel math.order math.parser
sequences sorting.human sorting.slots splitting ;
IN: semantic-versioning

<PRIVATE

: pre-release<=> ( obj1 obj2 -- <=> )
    2dup [ empty? ] either?
    [ [ length ] bi@ >=< ] [ human<=> ] if ;

PRIVATE>

TUPLE: version major minor patch pre-release build ;

C: <version> version

M: version <=>
    {
        { major>> <=> }
        { minor>> <=> }
        { patch>> <=> }
        { pre-release>> pre-release<=> }
    } compare-slots ;

: string>version ( string -- version )
    "." split1 "." split1 dup [ digit? not ] find
    [ [ cut ] [ CHAR: - = [ rest ] when ] bi* ] [ drop "" ] if*
    [ [ string>number 0 or ] tri@ ] dip
    CHAR: + over index [ cut rest ] [ "" ] if*
    <version> ;

: version<=> ( version1 version2 -- <=> )
    [ string>version ] bi@ <=> ;

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
