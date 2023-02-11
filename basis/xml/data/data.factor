! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators
combinators.short-circuit delegate delegate.protocols kernel
sequences slots strings vectors words ;
IN: xml.data

TUPLE: interpolated var ;
C: <interpolated> interpolated

TUPLE: name
    { space maybe{ string } }
    { main string }
    { url maybe{ string } } ;
C: <name> name

: ?= ( object/f object/f -- ? )
    2dup and [ = ] [ 2drop t ] if ;

: names-match? ( name1 name2 -- ? )
    {
        [ [ space>> ] bi@ ?= ]
        [ [ url>> ] bi@ ?= ]
        [ [ main>> ] bi@ ?= ]
    } 2&& ;

: <simple-name> ( string -- name )
    "" swap f <name> ;

: <null-name> ( string -- name )
    f swap f <name> ;

: assure-name ( string/name -- name )
    dup name? [ <null-name> ] unless ;

TUPLE: attrs { alist sequence } ;
C: <attrs> attrs

: attr@ ( key alist -- index {key,value} )
    [ assure-name ] dip alist>>
    [ first names-match? ] with find ;

M: attrs at*
    attr@ nip [ second t ] [ f f ] if* ;
M: attrs set-at
    2dup attr@ nip [
        2nip set-second
    ] [
        [ assure-name swap 2array ] dip
        [ alist>> ?push ] keep alist<<
    ] if* ;

M: attrs assoc-size alist>> length ;
M: attrs new-assoc drop <vector> <attrs> ;
M: attrs >alist alist>> ;

: >attrs ( assoc -- attrs )
    dup [
        V{ } assoc-clone-like
        [ [ assure-name ] dip ] assoc-map
    ] when <attrs> ;
M: attrs assoc-like
    drop dup attrs? [ >attrs ] unless ;

M: attrs clear-assoc
    f >>alist drop ;
M: attrs delete-at
    [ nip ] [ attr@ drop ] 2bi
    [ swap alist>> remove-nth! drop ] [ drop ] if* ;

M: attrs clone
    alist>> clone <attrs> ;

INSTANCE: attrs assoc

TUPLE: opener { name name } { attrs attrs } ;
C: <opener> opener

TUPLE: closer { name name } ;
C: <closer> closer

TUPLE: contained { name name } { attrs attrs } ;
C: <contained> contained

TUPLE: comment { text string } ;
C: <comment> comment

TUPLE: cdata { text string } ;
C: <cdata> cdata

TUPLE: directive ;

TUPLE: element-decl < directive
    { name string }
    { content-spec string } ;
C: <element-decl> element-decl

TUPLE: attlist-decl < directive
    { name string }
    { att-defs string } ;
C: <attlist-decl> attlist-decl

TUPLE: entity-decl < directive
    { name string }
    { def string }
    { pe? boolean } ;
C: <entity-decl> entity-decl

TUPLE: system-id { system-literal string } ;
C: <system-id> system-id

TUPLE: public-id { pubid-literal string } { system-literal string } ;
C: <public-id> public-id

UNION: id system-id public-id ;

TUPLE: dtd
    { directives sequence }
    { entities assoc }
    { parameter-entities assoc } ;
C: <dtd> dtd

TUPLE: doctype-decl < directive
    { name string }
    { external-id maybe{ id } }
    { internal-subset maybe{ dtd } } ;
C: <doctype-decl> doctype-decl

TUPLE: notation-decl < directive
    { name string }
    { id string } ;
C: <notation-decl> notation-decl

TUPLE: instruction { text string } ;
C: <instruction> instruction

TUPLE: prolog
    { version string }
    { encoding string }
    { standalone boolean } ;
C: <prolog> prolog

TUPLE: tag
    { name name }
    { attrs attrs }
    { children sequence } ;

: <tag> ( name attrs children -- tag )
    [ assure-name ] [ T{ attrs } assoc-like ] [ ] tri*
    tag boa ;

: attr ( tag/xml name -- string )
    swap attrs>> at ;

: set-attr ( tag/xml value name -- )
    rot attrs>> set-at ;

! They also follow the sequence protocol (for children)
CONSULT: sequence-protocol tag children>> ;
INSTANCE: tag sequence

! They also follow the assoc protocol (for attributes)
CONSULT: assoc-protocol tag attrs>> ;
INSTANCE: tag assoc

CONSULT: name tag name>> ;

M: tag like
    over tag? [ drop ] [
        [ name>> ] keep attrs>>
        rot dup [ V{ } like ] when <tag>
    ] if ;

MACRO: clone-slots ( class -- quot )
    [
        "slots" word-prop
        [ name>> reader-word '[ _ execute clone ] ] map
        '[ _ cleave ]
    ] [ '[ _ boa ] ] bi compose ;

M: tag clone
    tag clone-slots ;

TUPLE: xml
    { prolog prolog }
    { before sequence }
    { body tag }
    { after sequence } ;
C: <xml> xml

CONSULT: sequence-protocol xml body>> ;
INSTANCE: xml sequence

CONSULT: tag xml body>> ;

CONSULT: name xml body>> ;

<PRIVATE
: tag>xml ( xml tag -- newxml )
    [ [ prolog>> ] [ before>> ] [ after>> ] tri ] dip
    swap <xml> ;

: sequence>xml ( xml seq -- newxml )
    over body>> like tag>xml ;
PRIVATE>

M: xml clone
    xml clone-slots ;

M: xml like
    swap dup xml? [ nip ] [
        dup tag? [ tag>xml ] [ sequence>xml ] if
    ] if ;

! tag with children=f is contained
: <contained-tag> ( name attrs -- tag )
    f <tag> ;

PREDICATE: contained-tag < tag children>> empty? ;
PREDICATE: open-tag < tag children>> empty? not ;

TUPLE: unescaped string ;
C: <unescaped> unescaped

UNION: xml-data
    tag comment cdata string directive instruction unescaped ;

TUPLE: xml-chunk seq ;
C: <xml-chunk> xml-chunk

CONSULT: sequence-protocol xml-chunk seq>> ;
INSTANCE: xml-chunk sequence
