! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces sequences words io assocs
quotations strings parser arrays xml.data xml.writer debugger
splitting ;
IN: xml.utilities

! * System for words specialized on tag names

TUPLE: process-missing process tag ;
M: process-missing error.
    "Tag <" write
    process-missing-tag print-name
    "> not implemented on process process " write
    dup process-missing-process word-name print ;

: run-process ( tag word -- )
    2dup "xtable" word-prop
    >r dup name-tag r> at* [ 2nip call ] [
        drop \ process-missing construct-boa throw
    ] if ;

: PROCESS:
    CREATE
    dup H{ } clone "xtable" set-word-prop
    dup [ run-process ] curry define-compound ; parsing

: TAG:
    scan scan-word
    parse-definition
    swap "xtable" word-prop
    rot "/" split [ >r 2dup r> swap set-at ] each 2drop ;
    parsing


! * Common utility functions

: build-tag* ( items name -- tag )
    "" swap "" <name>
    swap >r { } r> <tag> ;

: build-tag ( item name -- tag )
    >r 1array r> build-tag* ;

: build-xml ( tag -- xml )
    T{ prolog f "1.0" "iso-8859-1" f } { } rot { } <xml> ;

: children>string ( tag -- string )
    tag-children
    dup [ string? ] all?
    [ "XML tag unexpectedly contains non-text children" throw ] unless
    concat ;

: children-tags ( tag -- sequence )
    tag-children [ tag? ] subset ;

: first-child-tag ( tag -- tag )
    tag-children [ tag? ] find nip ;

! * Utilities for searching through XML documents
! These all work from the outside in, top to bottom.

: with-delegate ( object quot -- object )
    over clone >r >r delegate r> call r>
    [ set-delegate ] keep ; inline

GENERIC# xml-each 1 ( quot tag -- ) inline
M: tag xml-each
    [ call ] 2keep
    swap tag-children [ swap xml-each ] curry* each ;
M: object xml-each
    call ;
M: xml xml-each
    >r delegate r> xml-each ;

GENERIC# xml-map 1 ( quot tag -- tag ) inline
M: tag xml-map
    swap clone over >r swap call r> 
    swap [ tag-children [ swap xml-map ] curry* map ] keep 
    [ set-tag-children ] keep ;
M: object xml-map
    call ;
M: xml xml-map
    swap [ swap xml-map ] with-delegate ;

: xml-subset ( quot tag -- seq ) ! quot: tag -- ?
    V{ } clone rot [
        swap >r [ swap call ] 2keep rot r>
        swap [ [ push ] keep ] [ nip ] if
    ] xml-each nip ;

GENERIC# xml-find 1 ( quot tag -- tag ) inline
M: tag xml-find
    [ call ] 2keep swap rot [
        f swap
        [ nip over >r swap xml-find r> swap dup ] find
        2drop ! leaves result of quot
    ] unless nip ;
M: object xml-find
    keep f ? ;
M: xml xml-find
    >r delegate r> xml-find ;

GENERIC# xml-inject 1 ( quot tag -- ) inline
M: tag xml-inject
    swap [
        swap [ call ] keep
        [ xml-inject ] keep
    ] change-each ;
M: object xml-inject 2drop ;
M: xml xml-inject >r delegate >r xml-inject ;

! * Accessing part of an XML document

: get-id ( tag id -- elem ) ! elem=tag.getElementById(id)
    swap [
        dup tag?
        [ "id" swap at over = ]
        [ drop f ] if
    ] xml-find nip ;

: (get-tag) ( name elem -- ? )
    dup tag? [ names-match? ] [ 2drop f ] if ;

: tag-named* ( tag name/string -- matching-tag )
    assure-name swap [ dupd (get-tag) ] xml-find nip ;

: tags-named* ( tag name/string -- tags-seq )
    assure-name swap [ dupd (get-tag) ] xml-subset nip ;

: tag-named ( tag name/string -- matching-tag )
    ! like get-name-tag but only looks at direct children,
    ! not all the children down the tree.
    assure-name swap [ (get-tag) ] curry* find nip ;

: tags-named ( tag name/string -- tags-seq )
    assure-name swap [ (get-tag) ] curry* subset ;

: assert-tag ( name name -- )
    names-match? [ "Unexpected XML tag found" throw ] unless ;
