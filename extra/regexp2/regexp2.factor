! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel math math.ranges
sequences regexp2.backend regexp2.utils memoize
regexp2.parser regexp2.nfa regexp2.dfa regexp2.traversal
regexp2.transition-tables ;
IN: regexp2

: default-regexp ( string -- regexp )
    regexp new
        swap >>raw
        <transition-table> >>nfa-table
        <transition-table> >>dfa-table
        <transition-table> >>minimized-table
        reset-regexp ;

: construct-regexp ( regexp -- regexp' )
    {
        [ parse-regexp ]
        [ construct-nfa ]
        [ construct-dfa ]
        [ ]
    } cleave ;

: match ( string regexp -- pair )
    <dfa-traverser> do-match return-match ;

: matches? ( string regexp -- ? )
    dupd match [ [ length ] [ range-length 1- ] bi* = ] [ drop f ] if* ;

: match-head ( string regexp -- end ) match length>> 1- ;

MEMO: <regexp> ( string -- regexp )
    default-regexp construct-regexp ;

MEMO: <iregexp> ( string -- regexp )
    default-regexp
    t >>case-insensitive
    construct-regexp ;

: R! CHAR: ! <regexp> ; parsing
: R" CHAR: " <regexp> ; parsing
: R# CHAR: # <regexp> ; parsing
: R' CHAR: ' <regexp> ; parsing
: R( CHAR: ) <regexp> ; parsing
: R/ CHAR: / <regexp> ; parsing
: R@ CHAR: @ <regexp> ; parsing
: R[ CHAR: ] <regexp> ; parsing
: R` CHAR: ` <regexp> ; parsing
: R{ CHAR: } <regexp> ; parsing
: R| CHAR: | <regexp> ; parsing
