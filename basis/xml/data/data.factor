! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences sequences.private assocs arrays
delegate.protocols delegate vectors accessors multiline
macros words quotations combinators ;
IN: xml.data

TUPLE: name space main url ;
C: <name> name

: ?= ( object/f object/f -- ? )
    2dup and [ = ] [ 2drop t ] if ;

: names-match? ( name1 name2 -- ? )
    [ [ space>> ] bi@ ?= ]
    [ [ url>> ] bi@ ?= ]
    [ [ main>> ] bi@ ?= ] 2tri and and ;

: <simple-name> ( string -- name )
    f swap f <name> ;

: assure-name ( string/name -- name )
    dup name? [ <simple-name> ] unless ;

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

TUPLE: attrs alist ;
C: <attrs> attrs

: attr@ ( key alist -- index {key,value} )
    >r assure-name r> alist>>
    [ first names-match? ] with find ;

M: attrs at*
    attr@ nip [ second t ] [ f f ] if* ;
M: attrs set-at
    2dup attr@ nip [
        2nip set-second
    ] [
        >r assure-name swap 2array r>
        [ alist>> ?push ] keep (>>alist)
    ] if* ;

M: attrs assoc-size alist>> length ;
M: attrs new-assoc drop V{ } new-sequence <attrs> ;
M: attrs >alist alist>> ;

: >attrs ( assoc -- attrs )
    dup [
        V{ } assoc-clone-like
        [ >r assure-name r> ] assoc-map
    ] when <attrs> ;
M: attrs assoc-like
    drop dup attrs? [ >attrs ] unless ;

M: attrs clear-assoc
    f >>alist drop ;
M: attrs delete-at
    tuck attr@ drop [ swap alist>> delete-nth ] [ drop ] if* ;

M: attrs clone
    alist>> clone <attrs> ;

INSTANCE: attrs assoc

TUPLE: tag name attrs children ;

: <tag> ( name attrs children -- tag )
    [ assure-name ] [ T{ attrs } assoc-like ] [ ] tri*
    tag boa ;

! For convenience, tags follow the assoc protocol too (for attrs)
CONSULT: assoc-protocol tag tag-attrs ;
INSTANCE: tag assoc

! They also follow the sequence protocol (for children)
CONSULT: sequence-protocol tag children>> ;
INSTANCE: tag sequence

CONSULT: name tag name>> ;

M: tag like
    over tag? [ drop ] [
        [ name>> ] keep tag-attrs
        rot dup [ V{ } like ] when <tag>
    ] if ;

MACRO: clone-slots ( class -- tuple )
    [
        "slots" word-prop
        [ reader>> 1quotation [ clone ] compose ] map
        [ cleave ] curry
    ] [ [ boa ] curry ] bi compose ;

M: tag clone
    tag clone-slots ;

TUPLE: xml prolog before body after ;
C: <xml> xml

CONSULT: sequence-protocol xml body>> ;
INSTANCE: xml sequence

CONSULT: assoc-protocol xml body>> ;
INSTANCE: xml assoc

CONSULT: tag xml body>> ;

CONSULT: name xml body>> ;

<PRIVATE
: tag>xml ( xml tag -- newxml )
    >r [ prolog>> ] [ before>> ] [ after>> ] tri r>
    swap <xml> ;

: seq>xml ( xml seq -- newxml )
    over body>> like tag>xml ;
PRIVATE>

M: xml clone
   xml clone-slots ;

M: xml like
    swap dup xml? [ nip ] [
        dup tag? [ tag>xml ] [ seq>xml ] if
    ] if ;

! tag with children=f is contained
: <contained-tag> ( name attrs -- tag )
    f <tag> ;

PREDICATE: contained-tag < tag children>> not ;
PREDICATE: open-tag < tag children>> ;
