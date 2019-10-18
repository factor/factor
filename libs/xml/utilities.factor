! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
IN: xml-utils
USING: kernel namespaces sequences words io errors assocs
quotations strings parser arrays generic xml-data xml-writer ;

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
        drop <process-missing> throw
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

GENERIC: (xml-each) ( quot tag -- ) inline
M: tag (xml-each)
    [ swap call ] 2keep
    tag-children [ (xml-each) ] each-with ;
M: object (xml-each)
    swap call ;
M: xml (xml-each)
    delegate (xml-each) ;
: xml-each ( tag quot -- ) ! quot: tag --
    swap (xml-each) ; inline

GENERIC: (xml-map) ( quot tag -- tag ) inline
M: tag (xml-map)
    clone over >r swap call r> 
    swap [ tag-children [ (xml-map) ] map-with ] keep 
    [ set-tag-children ] keep ;
M: object (xml-map)
    swap call ;
M: xml (xml-map)
    [ (xml-map) ] with-delegate ;
: xml-map ( tag quot -- tag ) ! quot: tag -- tag
    swap (xml-map) ; inline

: xml-subset ( quot tag -- seq ) ! quot: tag -- ?
    V{ } clone rot [
        swap >r [ swap call ] 2keep rot r>
        swap [ [ push ] keep ] [ nip ] if
    ] xml-each nip ;

GENERIC: (xml-find) ( quot tag -- tag ) inline
M: tag (xml-find)
    [ swap call ] 2keep rot [
        tag-children f swap
        [ nip over >r (xml-find) r> swap dup ] find
        2drop ! leaves result of quot
    ] unless nip ;
M: object (xml-find)
    swap keep f ? ;
M: xml (xml-find)
    delegate (xml-find) ;
: xml-find ( tag quot -- tag ) ! quot: tag -- ?
    swap (xml-find) ; inline

GENERIC: (xml-inject) ( quot tag -- ) inline
M: tag (xml-inject)
    tag-children [
        swap [ call ] keep
        swap [ (xml-inject) ] keep
    ] change-each ;
M: object (xml-inject) 2drop ;
M: xml (xml-inject) delegate (xml-inject) ;
: xml-inject ( tag quot -- ) ! quot: tag -- tag
    swap (xml-inject) ; inline

! * Manipulating tag attribute

: find-attr ( key alist -- {key,value} )
    [ first names-match? ] find-with nip ;
: get-attr ( key alist -- value )
    find-attr [ second ] [ f ] if* ;
: set-attr ( value key alist -- )
    2dup find-attr [
        2nip 1 swap set-nth
    ] [
        >r swap 2array r> push
    ] if* ;

: <name-tag> ( string -- name )
    f swap f <name> ;

GENERIC: assure-name ( string/name -- name )
M: name assure-name ;
M: string assure-name <name-tag> ;

: tag-attr ( tag name/string -- string/f )
    #! gets the attribute with the first matching name
    assure-name swap tag-attrs get-attr ;

! * Accessing part of an XML document

: get-id ( tag id -- elem ) ! elem=tag.getElementById(id)
    swap [
        dup tag?
        [ "id" tag-attr over = ]
        [ drop f ] if
    ] xml-find nip ;

: (get-tag) ( name elem -- name ? )
    dup tag? [ dupd names-match? ] [ drop f ] if ;

: tag-named* ( tag name/string -- matching-tag )
    assure-name swap [ (get-tag) ] xml-find nip ;

: tags-named* ( tag name/string -- tags-seq )
    assure-name swap [ (get-tag) ] xml-subset nip ;

: tag-named ( tag name/string -- matching-tag )
    ! like get-name-tag but only looks at direct children,
    ! not all the children down the tree.
    assure-name swap tag-children
    [ (get-tag) nip ] find-with nip ;

: tags-named ( tag name/string -- tags-seq )
    assure-name swap tag-children
    [ (get-tag) nip ] subset-with ;

: assert-tag ( name name -- )
    names-match? [ "Unexpected XML tag found" throw ] unless ;
