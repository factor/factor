! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
IN: xml
USING: kernel namespaces sequences words io errors hashtables
    strings parser arrays generic ;

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
    dup literalize \ run-process 2array >quotation define-compound ; parsing

: TAG:
    scan scan-word [
        swap "xtable" word-prop
        rot "/" split [ >r 2dup r> swap set-hash ] each 2drop
    ] f ; parsing


! * Common utility functions

: build-tag* ( items name -- tag )
    "" swap <name> "" over set-name-url
    swap >r H{ } r> <tag> ;

: build-tag ( item name -- tag )
    >r 1array r> build-tag* ;

: build-xml-doc ( tag -- xml-doc )
    T{ prolog f "1.0" "iso-8859-1" f } { } rot { } <xml-doc> ;

: children>string ( tag -- string )
    tag-children [ string? ] subset concat ;

: children-tags ( tag -- sequence )
    tag-children [ any-tag? ] subset ;

: first-child-tag ( tag -- tag )
    tag-children [ any-tag? ] find nip ;

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
: xml-each ( tag quot -- ) swap (xml-each) ; inline

GENERIC: (xml-map) ( quot tag -- tag ) inline
M: tag (xml-map)
    clone over >r swap call r> 
    swap [ tag-children [ (xml-map) ] map-with ] keep 
    [ set-tag-children ] keep ;
M: object (xml-map)
    swap call ;
M: xml-doc (xml-map)
    [ (xml-map) ] with-delegate ;
: xml-map ( tag quot -- tag ) swap (xml-map) ; inline

! : xml-subset ( tag quot -- tag )
!     V{ } clone rot [ ! this is wrong
!         [ swap >r call [ r> push ] [ r> 2drop ] if ] 3keep drop
!     ] xml-each 2drop ;
