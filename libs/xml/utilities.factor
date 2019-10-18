! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
IN: xml-utils
USING: kernel namespaces sequences words io errors hashtables
    strings parser arrays generic xml-data xml-writer ;

! * System for words specialized on tag names

TUPLE: process-missing process tag ;
M: process-missing error.
    "Tag <" write
    process-missing-tag print-name
    "> not implemented on process process " write
    dup process-missing-process word-name print ;

: run-process ( tag word -- )
    2dup "xtable" word-prop
    >r dup name-tag r> hash* [ 2nip call ] [
        drop <process-missing> throw
    ] if ;

: PROCESS:
    CREATE
    dup H{ } clone "xtable" set-word-prop
    dup [ run-process ] curry define-compound ; parsing

: TAG:
    scan scan-word [
        swap "xtable" word-prop
        rot "/" split [ >r 2dup r> swap set-hash ] each 2drop
    ] f ; parsing


! * Common utility functions

: build-tag* ( items name -- tag )
    "" swap "" <name>
    swap >r H{ } r> <tag> ;

: build-tag ( item name -- tag )
    >r 1array r> build-tag* ;

: build-xml-doc ( tag -- xml-doc )
    T{ prolog f "1.0" "iso-8859-1" f } { } rot { } <xml-doc> ;

: children>string ( tag -- string )
    tag-children
    dup [ str-elem? ] all?
    [ "XML tag unexpectedly contains non-text children" throw ] unless
    [ [ write-str-elem ] each ] string-out ;

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
M: xml-doc (xml-each)
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
M: xml-doc (xml-map)
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
    [ swap call ] keep f ? ;
M: xml-doc (xml-find)
    delegate (xml-find) ;
: xml-find ( tag quot -- tag ) ! quot: tag -- ?
    swap (xml-find) ; inline

GENERIC: (xml-inject) ( quot tag -- ) inline
M: tag (xml-inject)
    tag-children [
        swap [ call ] keep
        swap [ (xml-inject) ] keep
    ] inject ;
M: object (xml-inject) 2drop ;
M: xml-doc (xml-inject) delegate (xml-inject) ;
: xml-inject ( tag quot -- ) ! quot: tag -- tag
    swap (xml-inject) ; inline

! * Accessing part of an XML document

: prop-name ( tag name -- seq/f )
    #! gets the property with the first matching name
    swap tag-props [
        hash-keys [ over names-match? ] find
    ] keep hash 2nip ;

: <name-tag> ( string -- name )
    f swap f <name> ;

: prop-name-tag ( hash string -- seq/f )
    <name-tag> prop-name ;

: get-id ( tag id -- elem ) ! elem=tag.getElementById(id)
    swap [
        dup tag? [
            "id" prop-name-tag
            [ string? ] subset concat
            over =
        ] [ drop f ] if
    ] xml-find nip ;

: (get-tag) ( name elem -- name ? )
    dup tag? [ dupd names-match? ] [ drop f ] if ;

: get-name-tag ( tag name -- matching-tag )
    swap [ (get-tag) ] xml-find nip ;

: get-name-tags ( tag name -- seq )
    swap [ (get-tag) ] xml-subset nip ;

: get-tag ( tag string -- matching-tag ) <name-tag> get-name-tag ;
: get-tags ( tag string -- seq ) <name-tag> get-name-tags ;

: find-name-tag ( tag name -- matching-tag )
    ! like get-name-tag but only looks at direct children,
    ! not all the children down the tree.
    swap tag-children [ (get-tag) nip ] find-with nip ;

: find-name-tags ( tag name -- seq )
    swap tag-children [ (get-tag) nip ] subset-with ;

: find-tag ( tag string -- matching-tag ) <name-tag> find-name-tag ;
: find-tags ( tag string -- seq ) <name-tag> find-name-tags ;

: assert-tag ( name name -- )
    names-match? [ "Unexpected XML tag found" throw ] unless ;
