! Copyright (C) 2010 Maximilian Lupke.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays ascii kernel math math.order math.parser sequences
sorting.human splitting ;
IN: semantic-versioning

<PRIVATE

: number<=> ( obj1 obj2 -- <=> )
    [ [ zero? ] trim-tail-slice ] bi@ <=> ;

: pre-release<=> ( obj1 obj2 -- <=> )
    2dup [ empty? ] either?
    [ [ length ] bi@ >=< ] [ human<=> ] if ;

PRIVATE>

: split-version ( string -- array )
    "+" split1 [
        dup [ [ digit? not ] [ CHAR: . = not ] bi and ] find [
            [ cut ] [ CHAR: - = [ rest [ f ] when-empty ] when ] bi*
        ] [ drop f ] if*
        [ "." split [ string>number 0 or ] map 3 0 pad-tail ] dip
    ] dip 3array ;

: version<=> ( version1 version2 -- <=> )
    [ split-version ] bi@
    2dup [ first ] bi@ number<=> dup +eq+ =
    [ drop [ second ] bi@ pre-release<=> ] [ 2nip ] if ;

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
