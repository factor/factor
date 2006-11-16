! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
IN: xml
USING: kernel namespaces sequences words io errors hashtables
    strings parser arrays ;

! * Easy XML generation for more literal things
! should this be rewritten?

: text ( string -- )
    chars>entities add-child ;

: tag ( string attr-quot contents-quot -- )
    >r swap >r make-hash r> swap r> 
    -rot dupd <opener> process
    slip
    <closer> process ; inline

: comment ( string -- )
    <comment> add-child ;

: make-xml ( quot -- vector )
    #! Produces a tree of XML from a quotation to generate it
    [ init-xml call xml-stack get first second ] with-scope ; inline

! * System for words specialized on tag names

TUPLE: process-missing process tag ;
M: process-missing error.
    "Tag <" write
    process-missing-tag tag-name write
    "> not implemented on process process " write
    dup process-missing-process word-name print ;

: run-process ( tag word -- )
    2dup "xtable" word-prop
    >r dup tag-name name-tag r> hash* [ 2nip call ] [
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
