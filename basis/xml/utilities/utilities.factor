! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel namespaces sequences words io assocs
quotations strings parser lexer arrays xml.data xml.writer debugger
splitting vectors sequences.deep combinators fry ;
IN: xml.utilities

! * System for words specialized on tag names

TUPLE: process-missing process tag ;
M: process-missing error.
    "Tag <" write
    dup tag>> print-name
    "> not implemented on process process " write
    name>> print ;

: run-process ( tag word -- )
    2dup "xtable" word-prop
    [ dup main>> ] dip at* [ 2nip call ] [
        drop \ process-missing boa throw
    ] if ;

: PROCESS:
    CREATE
    dup H{ } clone "xtable" set-word-prop
    dup '[ _ run-process ] define ; parsing

: TAG:
    scan scan-word
    parse-definition
    swap "xtable" word-prop
    rot "/" split [ [ 2dup ] dip swap set-at ] each 2drop ;
    parsing


! * Common utility functions

: build-tag* ( items name -- tag )
    assure-name swap f swap <tag> ;

: build-tag ( item name -- tag )
    [ 1array ] dip build-tag* ;

: standard-prolog ( -- prolog )
    T{ prolog f "1.0" "UTF-8" f } ;

: build-xml ( tag -- xml )
    standard-prolog { } rot { } <xml> ;

: children>string ( tag -- string )
    children>> {
        { [ dup empty? ] [ drop "" ] }
        { [ dup [ string? not ] contains? ]
          [ "XML tag unexpectedly contains non-text children" throw ] }
        [ concat ]
    } cond ;

: children-tags ( tag -- sequence )
    children>> [ tag? ] filter ;

: first-child-tag ( tag -- tag )
    children>> [ tag? ] find nip ;

! * Accessing part of an XML document
! for tag- words, a start means that it searches all children
! and no star searches only direct children

: tag-named? ( name elem -- ? )
    dup tag? [ names-match? ] [ 2drop f ] if ;

: tags@ ( tag name -- children name )
    [ { } like ] dip assure-name ;

: deep-tag-named ( tag name/string -- matching-tag )
    assure-name '[ _ swap tag-named? ] deep-find ;

: deep-tags-named ( tag name/string -- tags-seq )
    tags@ '[ _ swap tag-named? ] deep-filter ;

: tag-named ( tag name/string -- matching-tag )
    ! like get-name-tag but only looks at direct children,
    ! not all the children down the tree.
    assure-name swap [ tag-named? ] with find nip ;

: tags-named ( tag name/string -- tags-seq )
    tags@ swap [ tag-named? ] with filter ;

: tag-with-attr? ( elem attr-value attr-name -- ? )
    rot dup tag? [ at = ] [ 3drop f ] if ;

: tag-with-attr ( tag attr-value attr-name -- matching-tag )
    assure-name '[ _ _ tag-with-attr? ] find nip ;

: tags-with-attr ( tag attr-value attr-name -- tags-seq )
    tags@ '[ _ _ tag-with-attr? ] filter children>> ;

: deep-tag-with-attr ( tag attr-value attr-name -- matching-tag )
    assure-name '[ _ _ tag-with-attr? ] deep-find ;

: deep-tags-with-attr ( tag attr-value attr-name -- tags-seq )
    tags@ '[ _ _ tag-with-attr? ] deep-filter ;

: get-id ( tag id -- elem ) ! elem=tag.getElementById(id)
    "id" deep-tag-with-attr ;

: deep-tags-named-with-attr ( tag tag-name attr-value attr-name -- tags )
    [ deep-tags-named ] 2dip tags-with-attr ;

: assert-tag ( name name -- )
    names-match? [ "Unexpected XML tag found" throw ] unless ;

: insert-children ( children tag -- )
    dup children>> [ push-all ]
    [ swap V{ } like >>children drop ] if ;

: insert-child ( child tag -- )
    [ 1vector ] dip insert-children ;
