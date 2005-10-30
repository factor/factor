! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: io
USING: hashtables kernel lists math namespaces sequences strings
styles ;

! Words for accessing filesystem meta-data.

: path+ ( path path -- path ) "/" swap append3 ;

: exists? ( file -- ? ) stat >boolean ;

: directory? ( file -- ? ) stat car ;

: directory ( dir -- list )
    (directory)
    H{ [[ "." "." ]] [[ ".." ".." ]] }
    swap remove-all string-sort ;

: file-length ( file -- length ) stat third ;

: file-extension ( filename -- extension )
    "." split dup length 1 <= [ drop f ] [ peek ] if ;

: resource-path ( path -- path )
    "resource-path" get [ "." ] unless* swap path+ ;

: <resource-stream> ( path -- stream )
    #! Open a file path relative to the Factor source code root.
    resource-path <file-reader> ;

DEFER: directory.

: file-style ( text path -- text style )
    dup directory? [
        >r "/" append r>
        dup [ directory. ] curry outline swons unit
    ] [
        f
    ] if swap file swons swons ;

: file. ( dir name -- )
    tuck path+ file-style format ;

: directory. ( dir -- )
    dup directory [ file. terpri ] each-with ;
