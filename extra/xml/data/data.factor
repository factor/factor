! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences sequences.private assocs arrays ;
IN: xml.data

TUPLE: name space tag url ;
C: <name> name

: ?= ( object/f object/f -- ? )
    2dup and [ = ] [ 2drop t ] if ;

: names-match? ( name1 name2 -- ? )
    [ name-space swap name-space ?= ] 2keep
    [ name-url swap name-url ?= ] 2keep
    name-tag swap name-tag ?= and and ;

: <name-tag> ( string -- name )
    f swap f <name> ;

: assure-name ( string/name -- name )
    dup name? [ <name-tag> ] unless ;

TUPLE: opener name attrs ;
C: <opener> opener

TUPLE: closer name ;
C: <closer> closer

TUPLE: contained name attrs ;
C: <contained> contained

TUPLE: comment text ;
C: <comment> comment

TUPLE: directive text ;
C: <directive> directive

TUPLE: instruction text ;
C: <instruction> instruction

TUPLE: prolog version encoding standalone ;
C: <prolog> prolog

TUPLE: xml prolog before after ;
: <xml> ( prolog before main after -- xml )
    { set-xml-prolog set-xml-before set-delegate set-xml-after }
    xml construct ;

TUPLE: attrs ;
: <attrs> ( alist -- attrs )
    attrs construct-delegate ;

: attr@ ( key alist -- index {key,value} )
    >r assure-name r>
    [ first names-match? ] curry* find ;

M: attrs at*
    attr@ nip [ second t ] [ f f ] if* ;
M: attrs set-at
    2dup attr@ nip [
        2nip set-second
    ] [
        >r assure-name swap 2array r> push
    ] if* ;

M: attrs assoc-size length ;
M: attrs new-assoc drop V{ } new <attrs> ;
M: attrs >alist delegate >alist ;

: >attrs ( assoc -- attrs )
    V{ } assoc-clone-like
    [ >r assure-name r> ] assoc-map
    <attrs> ;
M: attrs assoc-like
    drop dup attrs? [ >attrs ] unless ;

M: attrs clear-assoc
    delete-all ;
M: attrs delete-at
    tuck attr@ drop [ swap delete-nth ] [ drop ] if* ;

INSTANCE: attrs assoc

TUPLE: tag attrs children ;
: <tag> ( name attrs children -- tag )
    >r >r assure-name r> T{ attrs } assoc-like r>
    { set-delegate set-tag-attrs set-tag-children }
    tag construct ;

! For convenience, tags follow the assoc protocol too (for attrs)
M: tag at* tag-attrs at* ;
M: tag set-at tag-attrs set-at ;
M: tag new-assoc tag-attrs new-assoc ;
M: tag >alist tag-attrs >alist ;
M: tag delete-at tag-attrs delete-at ;
M: tag clear-assoc tag-attrs clear-assoc ;
M: tag assoc-size tag-attrs assoc-size ;
M: tag assoc-like tag-attrs assoc-like ;

INSTANCE: tag assoc

! They also follow the sequence protocol (for children)
M: tag nth tag-children nth ;
M: tag nth-unsafe tag-children nth-unsafe ;
M: tag set-nth tag-children set-nth ;
M: tag set-nth-unsafe tag-children set-nth-unsafe ;
M: tag length tag-children length ;

INSTANCE: tag sequence

! tag with children=f is contained
: <contained-tag> ( name attrs -- tag )
    f <tag> ;

PREDICATE: tag contained-tag tag-children not ;
PREDICATE: tag open-tag tag-children ;
