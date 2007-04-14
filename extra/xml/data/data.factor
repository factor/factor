! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences sequences.private assocs arrays
delegate.protocols delegate vectors ;
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

TUPLE: tag attrs children ;

TUPLE: attrs alist ;
C: <attrs> attrs

: attr@ ( key alist -- index {key,value} )
    >r assure-name r> attrs-alist
    [ first names-match? ] with find ;

M: attrs at*
    attr@ nip [ second t ] [ f f ] if* ;
M: attrs set-at
    2dup attr@ nip [
        2nip set-second
    ] [
        >r assure-name swap 2array r>
        [ attrs-alist ?push ] keep set-attrs-alist
    ] if* ;

M: attrs assoc-size attrs-alist length ;
M: attrs new-assoc drop V{ } new <attrs> ;
M: attrs >alist attrs-alist ;

: >attrs ( assoc -- attrs )
    dup [
        V{ } assoc-clone-like
        [ >r assure-name r> ] assoc-map
    ] when <attrs> ;
M: attrs assoc-like
    drop dup attrs? [ >attrs ] unless ;

M: attrs clear-assoc
    f swap set-attrs-alist ;
M: attrs delete-at
    tuck attr@ drop [ swap attrs-alist delete-nth ] [ drop ] if* ;

M: attrs clone
    attrs-alist clone <attrs> ;

INSTANCE: attrs assoc

: <tag> ( name attrs children -- tag )
    >r >r assure-name r> T{ attrs } assoc-like r>
    { set-delegate set-tag-attrs set-tag-children }
    tag construct ;

! For convenience, tags follow the assoc protocol too (for attrs)
CONSULT: assoc-protocol tag tag-attrs ;
INSTANCE: tag assoc

! They also follow the sequence protocol (for children)
CONSULT: sequence-protocol tag tag-children ;
INSTANCE: tag sequence

M: tag like
    over tag? [ drop ] [
        [ delegate ] keep tag-attrs
        rot dup [ V{ } like ] when <tag>
    ] if ;

M: tag clone
    [ delegate clone ] keep [ tag-attrs clone ] keep
    tag-children clone
    { set-delegate set-tag-attrs set-tag-children } tag construct ;

TUPLE: xml prolog before main after ;
: <xml> ( prolog before main after -- xml )
    { set-xml-prolog set-xml-before set-delegate set-xml-after }
    xml construct ;

CONSULT: sequence-protocol xml delegate ;
INSTANCE: xml sequence

CONSULT: assoc-protocol xml delegate ;
INSTANCE: xml assoc

<PRIVATE
: tag>xml ( xml tag -- newxml )
    swap [ dup xml-prolog swap xml-before rot ] keep xml-after <xml> ;

: seq>xml ( xml seq -- newxml )
    over delegate like tag>xml ;
PRIVATE>

M: xml clone
    [ xml-prolog clone ] keep [ xml-before clone ] keep
    [ delegate clone ] keep xml-after clone <xml> ;

M: xml like
    swap dup xml? [ nip ] [
        dup tag? [ tag>xml ] [ seq>xml ] if
    ] if ;

! tag with children=f is contained
: <contained-tag> ( name attrs -- tag )
    f <tag> ;

PREDICATE: contained-tag < tag tag-children not ;
PREDICATE: open-tag < tag tag-children ;
