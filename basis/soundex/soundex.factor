! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences grouping assocs kernel ascii tr ;
IN: soundex

TR: soundex-tr
    ch>upper
    "AEHIOUWYBFPVCGJKQSXZDTLMNR"
    "00000000111122222222334556" ;

: remove-duplicates ( seq -- seq' )
    #! Remove _consecutive_ duplicates (unlike prune which removes
    #! all duplicates).
    [ 2 <clumps> [ = ] assoc-reject values ] [ first ] bi prefix ;

: first>upper ( seq -- seq' ) 1 head >upper ;
: trim-first ( seq -- seq' ) dup first [ = ] curry trim-head ;
: remove-zeroes ( seq -- seq' ) CHAR: 0 swap remove ;
: remove-non-alpha ( seq -- seq' ) [ alpha? ] filter ;
: pad-4 ( first seq -- seq' ) "000" 3append 4 head ;

: soundex ( string -- soundex )
    remove-non-alpha [ f ] [
        [ first>upper ]
        [
            soundex-tr
            [ "" ] [ trim-first ] if-empty
            [ "" ] [ remove-duplicates ] if-empty
            remove-zeroes
        ] bi
        pad-4
    ] if-empty ;
