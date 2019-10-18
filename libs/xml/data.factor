! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: kernel generic ;
IN: xml-data

TUPLE: name space tag url ;

: ?= ( object/f object/f -- ? )
    2dup and [ = ] [ 2drop t ] if ;

: names-match? ( name1 name2 -- ? )
    [ name-space swap name-space ?= ] 2keep
    [ name-url swap name-url ?= ] 2keep
    name-tag swap name-tag ?= and and ;

TUPLE: opener name attrs ;
TUPLE: closer name ;
TUPLE: contained name attrs ;
TUPLE: comment text ;
TUPLE: directive text ;
TUPLE: instruction text ;
TUPLE: prolog version encoding standalone ;

TUPLE: xml prolog before after ;
C: xml ( prolog before main after -- xml )
    [ set-xml-after ] keep
    [ set-delegate ] keep
    [ set-xml-before ] keep
    [ set-xml-prolog ] keep ;

TUPLE: tag attrs children ;
C: tag ( name attrs children -- tag )
    [ set-tag-children ] keep
    [ set-tag-attrs ] keep
    [ set-delegate ] keep ;

! tag with children=f is contained
: <contained-tag> ( name attrs -- tag )
    f <tag> ;

PREDICATE: tag contained-tag tag-children not ;
PREDICATE: tag open-tag tag-children ;
