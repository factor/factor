! Copyright (C) 2008 Marc Fauconneau.
! See http://factorcode.org/license.txt for BSD license.
USING: parser kernel arrays math accessors sequences
math.vectors math.order sorting binary-search sets assocs fry ;
IN: suffix-arrays

<PRIVATE
: suffixes ( string -- suffixes-seq )
    dup length [ tail-slice ] with map ;

: prefix<=> ( begin seq -- <=> )
    [ <=> ] [ swap head? ] 2bi [ drop +eq+ ] when ;
 
: find-index ( begin suffix-array -- index )
    [ prefix<=> ] with search drop ;

: from-to ( index begin suffix-array -- from to )
    swap '[ _ head? not ]
    [ find-last-from drop 1+ ]
    [ find-from drop ] 3bi ;
PRIVATE>

: >suffix-array ( seq -- array )
    [ suffixes ] map concat natural-sort ;

: SA{ \ } [ >suffix-array ] parse-literal ; parsing

: query ( begin suffix-array -- matches )
    [ [ find-index ] 2keep from-to [ min ] keep ] keep
    <slice> [ seq>> ] map prune ;
