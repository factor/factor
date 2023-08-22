! Copyright (C) 2008 Marc Fauconneau.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors binary-search kernel math math.order parser
sequences sets sorting ;
IN: suffix-arrays

<PRIVATE

: suffixes ( string -- suffixes-seq )
    dup length <iota> [ tail-slice ] with map ;

: prefix<=> ( begin seq -- <=> )
    [ <=> ] [ swap head? ] 2bi [ drop +eq+ ] when ;

: find-index ( begin suffix-array -- index/f )
    [ prefix<=> ] with search drop ;

: query-from ( index begin suffix-array -- from )
    swap '[ _ head? not ] find-last-from drop [ 1 + ] [ 0 ] if* ;

: query-to ( index begin suffix-array -- to )
    [ swap '[ _ head? not ] find-from drop ] [ length or ] bi ;

: query-range ( index begin suffix-array -- from to )
    [ query-from ] [ query-to ] 3bi [ min ] keep ;

: (query) ( index begin suffix-array -- matches )
    [ query-range ] keep <slice> [ seq>> ] map members ;

PRIVATE>

: >suffix-array ( seq -- suffix-array )
    members [ suffixes ] map concat sort ;

SYNTAX: SA{ \ } [ >suffix-array ] parse-literal ;

: query ( begin suffix-array -- matches )
    [ find-index ] 2keep '[ _ _ (query) ] [ { } ] if* ;
