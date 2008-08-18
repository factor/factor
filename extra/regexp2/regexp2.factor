! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel regexp2.backend regexp2.utils
regexp2.parser regexp2.nfa regexp2.dfa regexp2.traversal state-tables
regexp2.transition-tables ;
IN: regexp2

: default-regexp ( string -- regexp )
    regexp new
        swap >>raw
        <transition-table> >>nfa-table
        <transition-table> >>dfa-table
        <transition-table> >>minimized-table
        reset-regexp ;

: <regexp> ( string -- regexp )
    default-regexp
    {
        [ parse-regexp ]
        [ construct-nfa ]
        [ construct-dfa ]
        [ ]
    } cleave ;

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
