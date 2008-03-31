! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: optimizer.pattern-match
USING: kernel sequences inference namespaces generic
combinators classes classes.algebra inference.dataflow ;

! Funny pattern matching
SYMBOL: @

: match-@ ( value -- ? )
    #! All @ must be eq
    @ get [ eq? ] [ @ set t ] if* ;

: match-class ( value spec -- ? )
    >r node get swap node-class r> class< ;

: value-match? ( value spec -- ? )
    {
        { [ dup @ eq? ] [ drop match-@ ] }
        { [ dup class? ] [ match-class ] }
        { [ over value? not ] [ 2drop f ] }
        { [ t ] [ swap value-literal = ] }
    } cond ;

: node-match? ( node values pattern -- ? )
    [
        rot node set @ off
        [ value-match? ] 2all?
    ] with-scope ;

: in-d-match? ( node pattern -- ? )
    >r dup node-in-d r> node-match? ;
