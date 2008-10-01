! Copyright (C) 2008 Marc Fauconneau.
! See http://factorcode.org/license.txt for BSD license.
USING: parser kernel arrays math accessors sequences
math.vectors math.order sorting binary-search sets assocs fry ;
IN: suffix-arrays

! this suffix array is a sorted array of suffixes
! query is efficient through binary searches

: suffixes ( string -- suffixes-seq )
    dup length [ tail-slice ] with map ;

: >suffix-array ( seq -- array )
    [ suffixes ] map concat natural-sort ;

: SA{ \ } [ >suffix-array ] parse-literal ; parsing

: prefix<=> ( seq begin -- <=> )
    [ swap <=> ] [ head? ] 2bi [ drop +eq+ ] when ;
 
: find-index ( suffix-array begin -- index )
    '[ _ prefix<=> ] search drop ;

: from-to ( index suffix-array begin -- from to )
    '[ _ head? not ]
    [ find-last-from drop 1+ ]
    [ find-from drop ] 3bi ;

: query ( begin suffix-array -- matches )
    [ swap [ find-index ] 2keep from-to [ min ] keep ] keep
    <slice> [ seq>> ] map prune ;
