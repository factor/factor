USING: sequences kernel math locals math.order math.ranges
accessors combinators.lib arrays namespaces combinators ;
IN: lcs

! Classic dynamic programming O(n^2) algorithm for the
! Longest Common Subsequence
! Slight modification to get Levenshtein distance

! j is row, i is column
! Going from str1 to str2
! str1 along side column, str2 along top row

:: lcs-step ( i j matrix old new change-cost -- )
    i j matrix nth nth
        i old nth j new nth = 0 change-cost ? +
    i j 1+ matrix nth nth 1+ ! insertion cost
    i 1+ j matrix nth nth 1+ ! deletion cost
    min min
    i 1+ j 1+ matrix nth set-nth ;

: lcs-initialize ( |str1| |str2| -- matrix )
    [ drop 0 <array> ] with map ;

: levenshtein-initialize ( |str1| |str2| -- matrix )
    [ [ + ] curry map ] with map ;

:: run-lcs ( old new quot change-cost -- matrix )
    [let | matrix [ old length 1+ new length 1+ quot call ] |
        old length [0,b) [| i |
            new length [0,b)
            [| j | i j matrix old new change-cost lcs-step ]
            each
        ] each matrix ] ;

: levenshtein ( old new -- n )
    [ levenshtein-initialize ] 1 run-lcs peek peek ;

TUPLE: retain item ;
TUPLE: delete item ;
TUPLE: insert item ;

TUPLE: trace-state old new table i j ;

: old-nth ( state -- elt )
    [ i>> 1- ] [ old>> ] bi nth ;

: new-nth ( state -- elt )
    [ j>> 1- ] [ new>> ] bi nth ;

: top-beats-side? ( state -- ? )
    [ [ i>> ] [ j>> 1- ] [ table>> ] tri nth nth ]
    [ [ i>> 1- ] [ j>> ] [ table>> ] tri nth nth ] bi > ;

: retained? ( state -- ? )
    {
        [ i>> 0 > ] [ j>> 0 > ]
        [ [ old-nth ] [ new-nth ] bi = ]
    } <-&& ;

: do-retain ( state -- state )
    dup old-nth retain boa ,
    [ 1- ] change-i [ 1- ] change-j ;

: inserted? ( state -- ? )
    [ j>> 0 > ]
    [ [ i>> zero? ] [ top-beats-side? ] or? ] and? ;

: do-insert ( state -- state )
    dup new-nth insert boa , [ 1- ] change-j ;

: deleted? ( state -- ? )
    [ i>> 0 > ]
    [ [ j>> zero? ] [ top-beats-side? not ] or? ] and? ;

: do-delete ( state -- state )
    dup old-nth delete boa , [ 1- ] change-i ;

: (trace-diff) ( state -- )
    {
        { [ dup retained? ] [ do-retain (trace-diff) ] }
        { [ dup inserted? ] [ do-insert (trace-diff) ] }
        { [ dup deleted? ] [ do-delete (trace-diff) ] }
        [ drop ] ! i=j=0
    } cond ;

: trace-diff ( old new table -- diff )
    [ ] [ first length 1- ] [ length 1- ] tri trace-state boa
    [ (trace-diff) ] { } make reverse ;

: diff ( old new -- diff )
    2dup [ lcs-initialize ] 2 run-lcs trace-diff ;

: lcs ( str1 str2 -- lcs )
    [ diff [ retain? ] filter ] keep [ item>> ] swap map-as ;
