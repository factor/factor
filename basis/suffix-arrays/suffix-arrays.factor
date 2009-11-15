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
 
: find-index ( begin suffix-array -- index/f )
    [ prefix<=> ] with search drop ;

: from-to ( index begin suffix-array -- from/f to/f )
    swap '[ _ head? not ]
    [ find-last-from drop dup [ 1 + ] when ]
    [ find-from drop ] 3bi ;

: <funky-slice> ( from/f to/f seq -- slice )
    [
        [ drop 0 or ] [ length or ] bi-curry bi*
        [ min ] keep
    ] keep <slice> ; inline

PRIVATE>

: >suffix-array ( seq -- array )
    [ suffixes ] map concat natural-sort ;

SYNTAX: SA{ \ } [ >suffix-array ] parse-literal ;

: query ( begin suffix-array -- matches )
    2dup find-index dup
    [ -rot [ from-to ] keep <funky-slice> [ seq>> ] map prune ]
    [ 3drop { } ] if ;
