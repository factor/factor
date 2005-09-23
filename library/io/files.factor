! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: io
USING: hashtables kernel lists namespaces sequences strings ;

! Words for accessing filesystem meta-data.

: path+ ( path path -- path ) "/" swap append3 ;

: exists? ( file -- ? ) stat >boolean ;

: directory? ( file -- ? ) stat car ;

: directory ( dir -- list )
    (directory)
    {{ [[ "." "." ]] [[ ".." ".." ]] }}
    swap remove-all string-sort ;

: file-length ( file -- length ) stat third ;

: file-extension ( filename -- extension )
    "." split cdr dup [ peek ] when ;

: resource-path ( path -- path )
    "resource-path" get [ "." ] unless* swap path+ ;

: <resource-stream> ( path -- stream )
    #! Open a file path relative to the Factor source code root.
    resource-path <file-reader> ;
