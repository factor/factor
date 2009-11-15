! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences sequences.private assocs arrays
delegate.protocols delegate vectors accessors multiline
macros words quotations combinators slots fry strings ;
IN: xml.data

TUPLE: interpolated var ;
C: <interpolated> interpolated

UNION: nullable-string string POSTPONE: f ;

TUPLE: name
    { space nullable-string }
    { main string }
    { url nullable-string } ;
C: <name> name

: ?= ( object/f object/f -- ? )
    2dup and [ = ] [ 2drop t ] if ;

: names-match? ( name1 name2 -- ? )
    [ [ space>> ] bi@ ?= ]
    [ [ url>> ] bi@ ?= ]
    [ [ main>> ] bi@ ?= ] 2tri and and ;

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
        [ alist>> ?push ] keep (>>alist)
    ] if* ;

M: attrs assoc-size alist>> length ;
M: attrs new-assoc drop V{ } new-sequence <attrs> ;
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

TUPLE: directive ;

TUPLE: element-decl < directive
    { name string }
    { content-spec string } ;
C: <element-decl> element-decl

TUPLE: attlist-decl < directive
    { name string }
    { att-defs string } ;
C: <attlist-decl> attlist-decl

UNION: boolean t POSTPONE: f ;

TUPLE: entity-decl < directive
    { name string }
    { def string }
    { pe? boolean } ;
C: <entity-decl> entity-decl

TUPLE: system-id { system-literal string } ;
C: <system-id> system-id

TUPLE: public-id { pubid-literal string } { system-literal string } ;
C: <public-id> public-id

UNION: id system-id public-id POSTPONE: f ;

TUPLE: dtd
    { directives sequence }
    { entities assoc }
    { parameter-entities assoc } ;
C: <dtd> dtd

UNION: dtd/f dtd POSTPONE: f ;

TUPLE: doctype-decl < directive
    { name string }
    { external-id id }
    { internal-subset dtd/f } ;
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

CONSULT: name tag name>> ;

M: tag like
    over tag? [ drop ] [
        [ name>> ] keep attrs>>
        rot dup [ V{ } like ] when <tag>
    ] if ;

MACRO: clone-slots ( class -- tuple )
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

TUPLE: unescaped string ;
C: <unescaped> unescaped

UNION: xml-data
    tag comment string directive instruction unescaped ;

TUPLE: xml-chunk seq ;
C: <xml-chunk> xml-chunk

CONSULT: sequence-protocol xml-chunk seq>> ;
INSTANCE: xml-chunk sequence
